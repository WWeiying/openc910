# C910 退休控制详解（ct_rtu_retire）

> RTL 源文件：`C910_RTL_FACTORY/gen_rtl/rtu/rtl/ct_rtu_retire.v`（2201 行）
>
> retire 是 RTU 的指挥部：决定每拍退休几条、处理异常/中断/调试的优先级、
> 运行**flush 状态机**（全核错误恢复的总开关）、并输出性能监控事件。
> 这是理解 C910 控制流的最后一块拼图。

---

## 1. 退休判定（L1143-1181）

```verilog
// L1161-1164
assign retire_inst0_normal_retire = rob_retire_inst0_vld && !rob_retire_inst0_expt_vld;
assign retire_inst1_normal_retire = rob_retire_inst1_vld;   // inst1/2 永远正常
assign retire_inst2_normal_retire = rob_retire_inst2_vld;
```

**异常/中断/调试只可能命中 inst0**（L1186 注释）——rob_rt 在排布退休窗口时
已保证：有特殊事件的指令必然被排成单独退休或排在第一位。这把异常处理简化成
"只看队头"。

**单退休模式 srt**（L1143-1155）：中断、调试、CTC flush、split spec fail、
CSR 配置（cp0_rtu_srt_en）时退化为每拍 1 条——所有难缠的场景都用"放慢"
换"简单"，这是 C910 控制逻辑反复出现的策略。

## 2. 异常与中断仲裁（L1183-1302）

```verilog
// 中断：必须打在非拆分、非 intmask 的指令上（L1198-1200）
assign retire_expt_int = rob_retire_inst0_int_vld && !split && !intmask;
// 向量：中断置位 bit5，异常用缓冲里的 vec（L1205-1207）
assign retire_expt_vec[5:0] = int ? {1'b1, int_vec[4:0]} : {2'b0, expt_vec[3:0]};
```

`intmask` 是 ROB 表项里的创建期标记（IDU 标注的不可中断指令，如原子序列），
**中断在 RTU 退休口注入**而非取指口——这样中断天然精确（epc = 队头 PC），
代价是中断延迟多几拍（等队头退休）。

**mtval 的多源选择**（L1212-1239）按场景：异步异常用物理地址；中断为 0；
取指页错用 cur_pc（高半字跨页时用 next_pc 的 4K 对齐，L1228-1230 处理
32 位指令跨页的 corner case）；其余用异常缓冲带来的 mtval。

优先级（L1242-1257）：调试请求 > 中断 > 异常（`retire_expt_vld` 里
`!dbgreq_ack` 排除调试）；MMU 的 bad_vpn 通知（L1246-1248）让 MMU 同步
作废对应 TLB 项。

## 3. flush 状态机（L1860-1990）—— 全核恢复总指挥

```verilog
parameter FLUSH_IDLE=00001; FLUSH_IS=00010; FLUSH_FE=00100; WF_EMPTY=01000;
          FLUSH_BE=10000;   FLUSH_IS_BE=10010; FLUSH_FE_BE=10100;
```

两类触发（L1874-1880）：

- `retire_inst0_flush`：异常/中断/指令flush（CSR写副作用、vsetvl）/调试/异步异常
  → 走 **FLUSH_FE** 路线（前端要转向 trap 入口或重取）；
- `retire_inst0_mispred`：误预测分支正常退休
  → 走 **FLUSH_IS** 路线（IFU 早在 EX2 已被 BJU 重定向过了，
  前端不用动，只需冲洗 IS/RF 和后端——这就是"早重定向+晚清理"的下半场，
  对应 doc/iu/02_bju.md 第 2.6 节）。

```
                  ┌─ pipeline已空 ─► FLUSH_FE_BE ─► IDLE   (一拍合并完成)
 IDLE ─ flush触发 ┤
                  └─ 未空 ─► FLUSH_FE ─┬─ 空 ─► FLUSH_BE ─► IDLE
                                       └─ 未空 ─► WF_EMPTY(等) ─► FLUSH_BE ─► IDLE
 IDLE ─ mispred ──► FLUSH_IS(_BE) 同构
```

**为什么 BE（后端 flush）要等 pipeline empty？**（L1888-1889）

```verilog
assign retire_flush_pipeline_empty = pst_retire_retired_reg_wb      // 已退休指令的写回全部落地
                                     && lsu_rtu_all_commit_data_vld; // 已提交 store 数据就位
```

后端 flush 会恢复重命名表、按 PST 回收 preg。若某条**已退休**指令的数据还
在写回途中（如长延迟除法、未完成的 store 提交），此刻回滚会丢失体系结构
状态。所以必须等"该留下的都落定"才动手清"该清除的"。`x_retired_released_wb`
（pst entry 信号，见 05）就是为这次检查准备的。

各状态的全核动作（L1894-1905 注释 + L1959-1988 输出）：

| 状态 | 输出 | 动作 |
|------|------|------|
| FLUSH_IS | `rtu_idu_flush_is` | 清 IDU IS/RF 级与 ptag 池，ID 级开始 stall |
| FLUSH_FE | `rtu_ifu_flush / rtu_idu_flush_fe / rtu_iu_flush_fe` | 清 IFU 全部 + IDU 各级；IU 的 PCFIFO 清错误路径项、BJU 解除 ifu_mispred_stall |
| WF_EMPTY | （仅 stall） | 等已退休写回排空 |
| FLUSH_BE | **`rtu_yy_xx_flush`** | 恢复重命名表（PST 的 dreg 位图）、清 PST 推测项、清各发射队列/执行单元 vld、解除 mispred stall |
| 整个非 IDLE 期 | `rtu_idu_flush_stall`、`rtu_iu_flush_chgflw_mask` | ID 停止放行；压制错误路径分支的 chgflw（doc/iu/02 第 2.5 节的 mask 来源） |

**flush 原因通报 LSU**（L2018-2051）：`rtu_lsu_expt_flush / eret_flush /
spec_fail_flush + spec_fail_iid`——LSU 内部已提交的 store 不能被 flush 清掉，
但 spec fail 场景下违例 load 之后的项要精确作废，LSU 需要知道"为什么 flush"
来决定清到哪。异步 flush（调试注入，L1993-2016）则连已提交项也强制写回完成。

## 4. 其余职责速览

- **预测器退休训练**（L1440-1527）：条件分支/RAS/间接跳转的退休信息回送 IFU
  （`rtu_ifu_retire_condbr/rts/jmp` 系列）——IFU 的某些预测结构按退休序训练
  （与 BJU 的执行期训练互补）；no_spec 系列（L1496）训练 LSU 数据推测。
- **vl 退休更新**（L1529 起）：vsetvl 类退休时把新 vl/vtype 提交 CP0。
- **调试接口**（L1585-1734）：调试请求同样只打 inst0，dbg_mode_on 期间
  压制异常输出。
- **性能监控**（L1736 起）：`rtu_hpcp_*` 事件——退休数、条件分支/误预测、
  间接跳转/误预测、store/load 退休等。**tb.v 与 HPCP 的 retired inst（
  minstret）、Cond Branch Misp 等计数全部源于这里**，这是 RTL 与你的 perf
  报表之间的最后一级对应关系。
- **异步异常 FSM**（L2072 起，AE_IDLE/WFC/WFI/EXPT）：总线错误等异步事件
  挂起等待，择机打在某次退休上。

## 5. 把误预测恢复的完整时序串起来

结合 doc/iu/02_bju.md，C910 误预测全流程（最终版）：

```
EX1  BJU 检出 mispred，年龄合格
EX2  iu_ifu_chgflw → IFU 重定向取指；iu_yy_xx_cancel；idu/ifu_mispred_stall↑
...  新路径指令填满 IBUF/ID，被 stall 挡在 ID；错误路径指令陆续完成（被 cancel 压制写回）
退休拍 误预测分支到达 ROB 头正常退休 → retire_inst0_mispred=1
T+1  FLUSH_IS（或管线已空直接 FLUSH_IS_BE）→ 清 IS/RF
T+2~ WF_EMPTY 等已退休写回落地
T+n  FLUSH_BE: rtu_yy_xx_flush 一拍脉冲 → 重命名表恢复、PST/发射队列清推测态、
     mispred_stall 解除 → 新路径指令从 ID 倾泻而下
```

## 6. Verdi 观察建议

层次：`...x_ct_rtu_top.x_ct_rtu_retire`

| 信号 | 看什么 |
|------|--------|
| `flush_cur_state[4:0]` | 状态机轨迹：01→04→08→10→01（FE 路线） |
| `retire_inst0_mispred` vs `retire_expt_vld` | 两类触发的区分 |
| `retire_flush_pipeline_empty` | WF_EMPTY 卡多久 = 写回排空时间 |
| `rtu_yy_xx_flush` | 全核最重要的单 bit：所有模块的推测状态在它的上升沿蒸发 |
| `rtu_yy_xx_retire0/1/2` | 退休带宽（IPC 直接体现） |

建议把本表 5 个信号 + BJU 的 `bju_chgflw_vld` + IDU 的 `mispred_stall` 存成
一个 Verdi group，跑 bench_br_bimodal 一次看全误预测恢复的两幕剧。
