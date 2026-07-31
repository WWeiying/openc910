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
CSR 配置（cp0_rtu_srt_en）等场景只允许退休窗口的 inst0 槽前进。严格说这是
“每拍最多弹出 1 个 ROB 退休项”，不是无条件等于“每拍 1 条架构指令”：
若该项是非 split 的合法折叠项，架构退休数仍由它的 `inst_num` 决定；若是
split 微操作，HPCP 会用 `!split` 将其排除在 `minstret` 之外。SRT 简化的是
并行退休槽之间的边界处理，不会把 `inst_num` 强制改写成 1。

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
`!dbgreq_ack` 排除调试）。对异常向量高两位为 `2'b11` 的 MMU 类异常，RTU
还输出 `rtu_mmu_expt_vld` 和 `rtu_mmu_bad_vpn=mtval[38:12]`。当前 MMU RTL
在 `ct_mmu_regs.v` 中用它更新 `meh_vpn`，即记录发生异常的 VPN，供后续
MMU/TLB 管理操作使用；这条通路本身不是“立即作废对应 TLB 项”的硬件命令。

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
  对应 `docs/iu/02_bju.md` 第 2.6 节）。

```
                  ┌─ 保留状态已就绪 ─► FLUSH_FE_BE ─► IDLE
 IDLE ─ flush触发 ┤
                  └─ 尚未就绪 ─► FLUSH_FE ─┬─ 就绪 ─► FLUSH_BE ─► IDLE
                                           └─ 未就绪 ─► WF_EMPTY ─► FLUSH_BE ─► IDLE
 IDLE ─ mispred ──► FLUSH_IS(_BE) 同构
```

**`retire_flush_pipeline_empty` 到底表示什么？**（L1888-1889）

```verilog
assign retire_flush_pipeline_empty = pst_retire_retired_reg_wb      // 已退休指令的写回全部落地
                                     && lsu_rtu_all_commit_data_vld; // 已提交 store 数据就位
```

这个名字容易被误读成“所有执行流水级 valid 都为 0”，但 RTL 并没有逐级检查
全核流水线。它只检查两类**恢复时必须保留的状态是否已经可见**：

1. `pst_retire_retired_reg_wb`：PREG、FREG、当前活动配置下的 VREG PST 以及
   EREG PST 的 `retired/released` 写回条件全部满足；
2. `lsu_rtu_all_commit_data_vld`：LSU 已提交存储所需的数据全部有效。

PST 单项的 `x_retired_released_wb` 仅在该项处于 `ALLOC && retire_vld`、
`RETIRE` 或 `RELEASE` 时返回自己的 WB 状态，其他生命周期状态返回 1。也就是说，
它检查的是 flush 必须保留或正确回收的物理版本，不是在统计任意在飞执行是否结束。
指令只有完成后才可能从 ROB 正常退休，因此这里也不应举成“已经退休但除法仍未完成”；
ROB 完成、结果写回到物理存储、PST 观察到 WB 以及成为可恢复体系结构状态，是四个
相关但不能混为一谈的时序概念。

各状态的全核动作（L1894-1905 注释 + L1959-1988 输出）：

| 状态 | 输出 | 动作 |
|------|------|------|
| FLUSH_IS | `rtu_idu_flush_is` | 清 IDU IS/RF 级与 ptag 池，ID 级开始 stall |
| FLUSH_FE | `rtu_ifu_flush / rtu_idu_flush_fe / rtu_iu_flush_fe` | 清 IFU 全部 + IDU 各级；IU 的 PCFIFO 清错误路径项、BJU 解除 ifu_mispred_stall |
| WF_EMPTY | （仅 stall） | 等 PST 保留版本 WB 条件与 LSU committed-data 条件同时满足 |
| FLUSH_BE | **`rtu_yy_xx_flush`** | 向连接该全局恢复信号的模块发出后端恢复脉冲；各模块按自己的局部语义恢复映射或清推测状态 |
| 整个非 IDLE 期 | `rtu_idu_flush_stall`、`rtu_iu_flush_chgflw_mask` | ID 停止放行；压制错误路径分支的 chgflw（见 `docs/iu/02_bju.md` 第 2.5 节） |

**flush 原因通报 LSU**（L2018-2051）：`rtu_lsu_expt_flush / eret_flush /
spec_fail_flush + spec_fail_iid`——LSU 内部已提交的 store 不能被 flush 清掉，
但 spec fail 场景下违例 load 之后的项要精确作废，LSU 需要知道"为什么 flush"
来决定清到哪。异步 flush（调试注入，L1993-2016）额外令 PST 的 WB 状态机
进入 WB，并通知 LSU 执行异步清理；这是一种**控制状态上的强制完成语义**，
不应表述成异步脉冲替执行单元真正产生了一次数据写回。

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
  报表之间的最后一级对应关系。`rtu_hpcp_instN_vld` 在计数使能时直接锁存
  `rob_retire_instN_vld`；HPCP 侧对 minstret 再屏蔽 `split`，但这里没有
  额外用 `!expt_vld` 屏蔽。普通 benchmark 热点区通常没有同步异常，对异常
  指令本身的计数边界则应另做定向测试。
- **异步异常 FSM**（L2072 起，AE_IDLE/WFC/WFI/EXPT）：总线错误等异步事件
  挂起等待，择机打在某次退休上。

## 5. 把误预测恢复的完整时序串起来

结合 `docs/iu/02_bju.md`，C910 误预测恢复可按下面的控制阶段理解：

```
EX1  BJU 检出 mispred，年龄合格
EX2  iu_ifu_chgflw → IFU 重定向取指；iu_yy_xx_cancel；idu/ifu_mispred_stall↑
...  IFU 可开始获得重定向路径数据；IDU 的 mispred stall/flush 控制限制其继续进入后端。
     旧路径在飞操作如何被 cancel、禁止提交或等待后续 flush，由各接收模块的局部逻辑决定，
     不能用一个全局信号概括成“所有错误路径写回都在同拍消失”
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
| `retire_flush_pipeline_empty` | PST 保留版本 WB 与 LSU committed-data 的合取；不是全流水级空闲检测 |
| `pst_retire_retired_reg_wb` | 把 WF_EMPTY 原因进一步分解到物理寄存器状态 |
| `lsu_rtu_all_commit_data_vld` | 把 WF_EMPTY 原因进一步分解到已提交 store 数据 |
| `rtu_yy_xx_flush` | 后端恢复脉冲；只有实际连接并实现相应分支的模块才按局部语义响应 |
| `rtu_yy_xx_retire0/1/2` | 三个 ROB 退休槽有效；直接反映的是退休项数 |
| `rob_retire_inst0/1/2_num`、`split` | 非 split 有效槽按 `inst_num` 计入 HPCP `minstret` 增量；split 微操作退出不增加该计数 |

例如 `retire0=1, retire1=0, retire2=0` 且 `inst0_num=3`，含义是弹出一个折叠
ROB 项、在该项 `split=0` 时退休三条架构指令，而不是 IPC=1。相反，三个
valid 都为 1、三项 `inst_num=1` 且均为非 split，在普通无异常区间才对应三条
架构指令。画退休性能曲线时建议同时画“ROB 槽数”“split 槽数”和“按
`!split && inst_num` 加权的 minstret 增量”，前两者用于判断退休端结构利用率，
后者用于普通 benchmark 的 IPC；异常测试还应同时画 `rob_retire_inst0_expt_vld`。

建议把本表 5 个信号 + BJU 的 `bju_chgflw_vld` + IDU 的 `mispred_stall` 存成
一个 Verdi group，跑 bench_br_bimodal 一次看全误预测恢复的两幕剧。
