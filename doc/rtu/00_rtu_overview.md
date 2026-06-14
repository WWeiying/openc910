# C910 RTU 总览（ct_rtu_top）

> RTL 源文件：`C910_RTL_FACTORY/gen_rtl/rtu/rtl/ct_rtu_top.v`（2475 行）
>
> 与 IU/IFU 顶层一样，ct_rtu_top 是结构性顶层，例化 6 个子模块并连线。
> RTU 的全部智慧在子模块里，但接口分组值得在这里先看全。

---

## 1. RTU 解决什么问题

乱序核把指令打乱执行，但体系结构状态（寄存器、PC、CSR）必须表现得像顺序
执行一样。这要求三件事，分别由 RTU 的三大件承担：

| 问题 | 答案 | 模块 |
|------|------|------|
| 谁先谁后？乱序完成的指令如何按序生效 | ROB：按程序序排队，队头完成才退休 | ct_rtu_rob |
| 异常指令后面的指令已经执行了怎么办 | 异常缓冲 + flush 状态机：退休时才认账，之后全部作废重来 | ct_rtu_rob_expt / ct_rtu_retire |
| 旧物理寄存器何时能给新指令用 | PST：跟踪每个 preg 的生命周期，新映射退休后才释放旧映射 | ct_rtu_pst_* |

```
ct_rtu_top
 ├── x_ct_rtu_rob       (ROB 64项 + 3个退休读项 + 异常缓冲 + 退休PC)   L1826
 │     ├── ct_rtu_rob_entry ×64 + ×3
 │     ├── ct_rtu_rob_rt   （退休读出与 PC 重建）
 │     └── ct_rtu_rob_expt （最老异常仲裁）
 ├── x_ct_rtu_retire    (退休判定/异常仲裁/flush状态机)                L2133
 ├── x_ct_rtu_pst_preg  (整数 96 preg 状态表)                          L1554
 ├── x_ct_rtu_pst_ereg  (ereg 状态表，T-Head 扩展寄存器)               L1623
 ├── x_ct_rtu_pst_vreg  (向量 64 vreg 状态表)                          L1679
 └── x_ct_rtu_pst_freg  (浮点 64 freg 状态表，复用 pst_vreg 模块)      L1749
```

注意浮点 freg 状态表**复用 ct_rtu_pst_vreg 模块**（例化两次，L1679/L1749），
就像 IU 的两个 ALU——C910 的浮点和向量寄存器堆物理独立但管理逻辑同构。

---

## 2. IID：贯穿全核的指令身份证

RTU 文档里处处是 IID（Instruction ID），先把它讲透：

- **7 位 = 1 位 wrap + 6 位 ROB 索引**。低 6 位直接是 ROB 表项号（64 项）；
  最高位是"圈数奇偶"标志，每当分配指针绕回 entry0 时翻转；
- IDU 派遣时从 RTU 领取 IID（`rtu_idu_rob_inst0~3_iid`，rob.v:4376-4379），
  指令带着它走完一生：发射队列年龄比较、执行单元完成汇报、LSU 顺序检查，
  最后退休时用它定位 ROB 表项；
- **年龄比较**靠 `ct_rtu_compare_iid`（见 07_encode_compare.md）：wrap 位相同
  比大小、不同则反过来——环形空间中只要在飞指令数 < 64，比较恒正确。

为什么不直接用 ROB 指针比较？因为消费 IID 的地方（BJU、LSU、发射队列）远离
ROB，没法实时知道头尾指针；自带 wrap 位让任意两个 IID 可以**就地**比出老幼。

---

## 3. 接口分组

### 3.1 IDU → RTU：创建（派遣拍）

| 信号组 | 说明 |
|--------|------|
| `idu_rtu_rob_create0~3_en/dp_en/gateclk_en/data[39:0]` | 每拍最多创建 4 个 ROB 表项（IDU 一拍派遣最多 4 条指令；折叠时更多条指令进同一项） |
| `idu_rtu_pst_dis_inst0~3_*`（preg_iid/dst_reg/rel_preg、vreg/ereg 同构） | PST 分配信息：新 preg 给哪条指令(iid)、对应哪个逻辑寄存器(dst_reg)、退休时该释放哪个旧 preg(rel_preg) |
| 返回：`rtu_idu_rob_inst0~3_iid`、`rtu_idu_rob_full/empty`、`rtu_idu_srt_en` | IID 发放、满反压、单退休模式 |

### 3.2 七条管线 → RTU：完成（乱序）

| 来源 | 信号 | 异常能力 |
|------|------|----------|
| IU pipe0 | `iu_rtu_pipe0_cmplt/iid` + 全套异常字段 | 异常/flush/vsetvl/efpc |
| IU pipe1 | `iu_rtu_pipe1_cmplt/iid` | 无 |
| IU pipe2 | `iu_rtu_pipe2_cmplt/iid/abnormal/bht_mispred/jmp_mispred` | 误预测 |
| LSU pipe3(load)/pipe4(store) | `lsu_rtu_wb_pipe3/4_cmplt/iid` + expt/mtval/spec_fail/bkpt/no_spec_* | 访存异常/顺序违例 |
| VFPU pipe6/7 | `vfpu_rtu_pipe6/7_cmplt/iid` | 无（浮点异常走 fflags 不 trap） |

写回（数据就绪）通知与完成分开：`iu_rtu_ex2_pipe0/1_wb_preg_vld/expand[95:0]`、
`lsu_rtu_wb_pipe3_wb_preg_*`、`vfpu_rtu_ex5_pipe6/7_wb_vreg_*` → 直接进 PST
置写回位。**ROB 收 cmplt（按 iid），PST 收 wb（按 preg）**——再次印证
完成与写回的双轨制（doc/iu/07_cbus.md）。

### 3.3 RTU → 全核：退休与 flush

| 信号 | 说明 |
|------|------|
| `rtu_yy_xx_retire0/1/2` | 三条退休有效（HPCP 数 minstret 的源头之一） |
| `rtu_yy_xx_flush` | **后端 flush**：恢复重命名表、清发射队列、清 PST 推测状态 |
| `rtu_ifu_flush / rtu_idu_flush_fe / rtu_iu_flush_fe` | 前端 flush |
| `rtu_idu_flush_is / rtu_idu_flush_stall` | IS 级 flush（误预测专用，比 flush_fe 轻） |
| `rtu_ifu_xx_expt_vld/expt_vec`、`rtu_ifu_chgflw_*` | 异常向量与重定向 PC → IFU 转向 trap 入口 |
| `rtu_iu_rob_read0/1/2_pcfifo_vld` | 退休跳转时弹 PCFIFO（doc/iu/03） |
| `rtu_lsu_expt_flush/eret_flush/spec_fail_flush/spec_fail_iid` | 告诉 LSU flush 的原因（决定 LSU 内部哪些项作废） |
| `rtu_hpcp_*`（retire pc/inst num/condbr/jmp 等） | 性能计数事件源 |
| `rtu_cp0_*` | 异常进入 CP0：epc/mtval/vec、vstart/vl 更新 |

---

## 4. 一条指令在 RTU 的一生

```
派遣拍 : IDU 发 rob_create*（40 位打包：pc_offset/bju/store/fold数/vl...）
         → ROB[create_ptr] 写入，vld=1, cmplt_cnt=折叠条数
         同拍 PST 表项 ALLOC（记录 iid/dst_reg/rel_preg）
执行后 : 执行单元 cmplt 报来（按 iid 找到表项）→ cmplt_cnt 递减，到 0 置 cmplt
         （ALU 类被 CBUS"推定完成"，见 doc/iu/07_cbus.md）
         数据写回 → PST 对应 preg 的 wb 状态置 WB
退休窗 : 表项滑入 3 个 retire read entry（rob_rt），按序检查：
         头项 cmplt？ 无异常？ → retire0/1/2 拉高
         - PC 重建：cur_pc += pc_offset（跳转则取 PCFIFO 弹出的目标）
         - PST：新 preg ALLOC→RETIRE，旧 preg（rel_preg）释放→等 DEALLOC
         - 有异常/误预测 → 启动 flush 状态机（见 04_retire.md）
```

---

## 5. 核心机制速通（子文档精华浓缩）

> 读完本节即可对 RTU 有完整认识；源码级细节进 01~07 子文档。

### 5.1 ROB：40 位瘦表项 + 指令折叠（详见 01）

64 项 × 仅 40 位。教科书 ROB 该存的三样东西全被外包：

| 教科书存 | C910 放哪 |
|----------|----------|
| 完整 PC | 不存，只存 3 位 pc_offset（增量重建，见 5.2）；跳转目标在 IU 的 PCFIFO |
| 结果数据 | PRF（写回即入） |
| 异常向量/mtval | 单独 1 项异常缓冲（见 5.3） |

**ROB 只管"序"，不管"值"**——这是 RTU 全部设计的纲。

**折叠**：一项最多装 3 条相邻简单指令（IDU 折叠派遣），`cmplt_cnt[1:0]`
跟踪剩余未完成数，7 条管线的完成同拍命中同一项时一次减 1~3。退休口
3 项/拍 × 3 条/项 = 峰值 9 条/拍。BJU/LSU/CSR 指令不折叠（一项一条），
其完成直接清零计数。

完成端口零译码：7 管线的 iid 低 6 位各自 expand_64 成独热位图，第 N 位
直连 entryN——"端口"就是 7 个位图的按位或。

指针照例三套：64 位独热创建指针（移位即步进）+ 4 个二进制 iid（派遣时
发给 IDU，wrap 位自然溢出形成）+ 退休弹出指针。满判定用计数器，
阈值 61（留 4 项给在途创建）。

### 5.2 退休 PC 增量重建（详见 02）

RTU 维护一个**退休游标 rob_cur_pc**：

```
非跳转项退休: cur_pc += pc_offset（本项折叠指令总长，半字数）
跳转项退休:   cur_pc = PCFIFO 弹出的真实目标
```

一拍退休 3 项时 inst1/inst2 的 PC 是级联选择：前面有跳转就从其目标起算，
否则累加 offset。实现上"addend 选择打拍、窄加法后置"，退休关键路径只剩
一个 39+5 位加法器。异常返回（rte）时游标直接装 CP0 的 EPC。
**一个加法器替代了 64×39 位 PC 存储**——这就是 ROB 敢不存 PC 的底气。

### 5.3 异常单项擂台（详见 03）

精确异常只需要"最老的未退休异常"，所以异常现场（70 位：iid/vec/mtval/
spec_fail/mispred/vsetvl…）只存**一项**。4 条能报异常的管线（IU pipe0、
BJU pipe2、LSU pipe3/4）每次 abnormal 完成都来挑战：10 个 compare_iid
两两比较，比现任擂主老才换人。退休 inst0 的 iid 与擂主匹配时按类型处置：

- expt_vld=1 → 真异常，走 trap；
- 只有 mispred/spec_fail/flush 标记 → 非 trap 的 flush 流程。

误预测、LSU 顺序违例、vsetvl flush **复用同一套擂台**——它们都需要
"最老者退休时触发恢复"的语义。

### 5.4 flush 状态机（详见 04）—— 全核恢复总指挥

```
触发A 异常/中断/CSR副作用/调试 → FLUSH_FE 路线（前端要转向）
触发B 误预测分支正常退休       → FLUSH_IS 路线（IFU 早被 BJU 重定向过，只清 IS/RF）

IDLE → FLUSH_FE(或IS) → [WF_EMPTY 等待] → FLUSH_BE → IDLE
                ↑ pipeline 已空时可合并为一拍（FLUSH_FE_BE/IS_BE）
```

**FLUSH_BE 必须等 pipeline empty**：已退休指令的写回（慢除法、store 提交）
还在途中时不能回滚——"该留的先落定，再清该清的"。检查项 =
`pst_retired_reg_wb && lsu_all_commit_data_vld`。

各状态动作：FLUSH_IS 清 IDU IS/RF；FLUSH_FE 加清 IFU 和 IDU 全级；
FLUSH_BE 发出全核最重要的单 bit **rtu_yy_xx_flush**——重命名表恢复、
PST/发射队列/执行单元的推测态在这一拍全部蒸发。整个非 IDLE 期间
ID 级 stall、错误路径分支的 chgflw 被 mask。

中断在退休口注入（只打 inst0，且天然精确 epc）；中断/调试/拆分指令
spec fail 都强制单退休模式（srt）——难场景用"放慢"换"简单"。

### 5.5 PST：preg 五态生命周期（详见 05/06）

96 项整数 preg（= 32 体系结构正身 + 64 重命名额度），每项一个状态机：

```
DEALLOC(空闲) → WF_ALLOC(IDU已预取) → ALLOC(已派给指令,推测态)
   → RETIRE(生产者退休,我是某逻辑寄存器的正身) 
   → RELEASE(下任写者退休,等写回确认) → DEALLOC
```

三条铁律：

1. **flush 时 ALLOC/WF_ALLOC 回 DEALLOC，RETIRE 纹丝不动**——
   "重命名表恢复"不需要 walk ROB 或 checkpoint：每个 RETIRE 态项输出
   "我是逻辑寄存器 X"的位图，flush 拍 RAT 整表重写即可；
2. **旧 preg 在"下一任写者退休"时释放**：每项记着 rel_preg（前任），
   自己退休的同拍把前任送进 RELEASE；
3. **没写回不回收**（RELEASE 还要等 WB 位）——否则新主人可能读到撕裂值；
   这也是 flush 状态机 WF_EMPTY 检查的单项粒度来源。

退休匹配做了时序前移：ROB 提前一拍给退休 iid，各项预比较锁存 match 位，
退休拍只剩一层与门。vreg(64×2，向量/浮点复用同一模块)/ereg(32) 同构。

### 5.6 机制联动图

```
            完成(iid)            退休判定           flush
7管线 ──► ROB cmplt_cnt ──► retire 0/1/2 ──┬─► PC游标前进(5.2)
                ▲                          ├─► PST: ALLOC→RETIRE + 释放前任(5.5)
异常完成 ──► 擂台(5.3) ──退休命中──► flush FSM(5.4) ──► rtu_yy_xx_flush
                                                          └─► RAT按RETIRE位图恢复
```

## 6. Verdi 观察层次

```
tb...x_ct_core.x_ct_rtu_top
 ├ x_ct_rtu_rob            ← rob_entry_num[6:0]（占用数）、rob_full
 │  ├ x_ct_rtu_rob_rt      ← rob_cur_pc（退休PC）、retire_inst0_cur_pc
 │  └ x_ct_rtu_rob_expt    ← expt_entry_vld/iid（挂起的最老异常）
 ├ x_ct_rtu_retire         ← flush_cur_state[4:0]（flush 状态机）
 └ x_ct_rtu_pst_preg       ← 任一 entry 的 lifecycle_cur_state[4:0]
```

入门三件套：`rtu_yy_xx_retire0/1/2` + `rob_entry_num` + `flush_cur_state`，
跑 coremark 看退休节拍与 ROB 水位；跑 exception case 看 flush 状态机走一圈。
