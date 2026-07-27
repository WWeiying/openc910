# C910 整数物理寄存器状态表详解（ct_rtu_pst_preg）

> RTL 源文件：
> - `ct_rtu_pst_preg.v`（8637 行，RTU 最大文件：96 项例化 + 分配指针 + 汇总）
> - `ct_rtu_pst_preg_entry.v`（577 行，单项的生命周期状态机）
>
> PST（Physical register Status Table）跟踪 96 个整数物理寄存器各自的状态。
> 它是寄存器重命名的"下半场"：IDU 的 RAT 负责"分配映射"（doc/idu/08_ir_rt.md），
> PST 负责"何时安全地收回"。

---

## 1. 问题背景：物理寄存器的生死簿

重命名消除假依赖的代价是：每个写寄存器的指令占用一个新 preg，旧 preg 必须
**等到确认再无人需要它**才能回收。"再无人需要"的精确时刻是：

> 写同一逻辑寄存器的**下一条指令退休**时——此后任何 flush 都不可能回滚到
> 需要旧值的状态。

所以每个 preg 表项记着 `rel_preg`（我退休时该放生的前任）。这就是
allocate-on-rename / free-on-next-writer-retire 方案，与 MIPS R10K 同宗。

## 2. 表项生命周期状态机（entry.v:185-331）

```verilog
parameter DEALLOC=00001; WF_ALLOC=00010; ALLOC=00100; RETIRE=01000; RELEASE=10000;
```

```
            进入IDU分配寄存器        派遣(create)         生产者退休
 DEALLOC ───────────────► WF_ALLOC ─────────► ALLOC ─────────► RETIRE
   ▲                          │flush            │flush            │
   │                          ▼                 ▼                 │下任退休(release)
   │◄─────────────────────  DEALLOC ◄─────── DEALLOC             ▼
   │                                            (release且已wb则直达)
   └────────────── wb到位 ──────────────────────────────────── RELEASE
```

各状态含义（L260-266 注释）：

| 状态 | 含义 | 谁能用这个 preg 的值 |
|------|------|---------------------|
| DEALLOC | 空闲，可被 IDU 领走 | 无人 |
| WF_ALLOC | 已被 IDU 的空闲列表预取，还没派遣给指令 | 无人 |
| ALLOC | 已分配给某条在飞指令（推测态） | 该指令的消费者 |
| RETIRE | 生产者已退休（体系结构态），preg 现在**是**某逻辑寄存器的正身 | 所有人 |
| RELEASE | 下一任写者已退休，本 preg 等写回位确认后回收 | 无人（已有新正身） |

**flush 行为是关键**（L288-307）：ALLOC/WF_ALLOC 态遇 `rtu_yy_xx_flush` 回
DEALLOC（推测分配作废）；**RETIRE 态不受 flush 影响**（体系结构状态必须保住）。
这一条就是"重命名表恢复"的本质：flush 后，每个逻辑寄存器的映射 =
处于 RETIRE 态的那个 preg。

**写回子状态机**（L333-382，IDLE/WB 两态）独立运行：执行单元的
`wb_preg_expand[95:0]`（doc/iu/08_rbus.md 的 96 位独热）置 WB。回收的最终
条件是 `RELEASE && WB`（或 release 时已 WB 直达 DEALLOC，L300-303）——
**没写回的 preg 不能回收**，否则新主人可能在旧写回落地前读到撕裂值。
这正是 retire.v 的 `pipeline_empty` 检查（04 第 3 节）在单项粒度上的体现：
`x_retired_released_wb`（L567-571）向 flush 状态机汇报"我这没有悬空写回"。

## 3. 表项信息与退休匹配（entry.v:384-560）

每项寄存：`iid[6:0]`（生产者）、`dst_reg[4:0]`（逻辑寄存器号）、
`rel_preg[6:0]`（前任 preg）。

**退休匹配的时序优化**（L463-516，注释 "compare retire inst iid before
retire"）：ROB 提前一拍给出 `retire_inst0/1/2_iid_updt_val`，每个 ALLOC 态
表项**预比较**自己的 iid 并锁存 match 位；真正退休拍只需
`retire_vld = retire_inst*_preg_vld && match`（L521-526）一层与门。
96 项 × 3 路的 7 位比较被移出退休关键路径。

退休瞬间两个动作同时发生：

```verilog
// 1. 放生前任：rel_preg 独热展开后输出（L535-546）
assign x_rel_preg_expand = {96{ALLOC && retire_vld}} & rel_preg_expand;
   // 顶层把 96 项的 rel_preg_expand 按位或 → 命中项收到 release_vld
// 2. 自己转正：ALLOC → RETIRE
```

**重命名表恢复位图**（L548-560）：

```verilog
assign x_dreg[31:0] = {32{RETIRE 态}} & dst_reg_expand[31:0];
```

每项输出"我是逻辑寄存器 X 的正身"位图，顶层汇总成 32×96 的恢复矩阵给 IDU：
`rtu_yy_xx_flush` 时 RAT 直接按它整表重写。**恢复不需要 walk ROB、不需要
checkpoint**——RETIRE 态本身就是持久化的映射快照。这是 PST 方案相对
checkpoint 方案的核心优势（代价是每项一个 5 态 FSM）。

## 4. 顶层职责（ct_rtu_pst_preg.v）

8637 行的构成：96 个 entry 例化（约 5000 行）+ 以下逻辑：

- **空闲 preg 选择**：从 DEALLOC 态位图中挑出 4 个（IDU 每拍最多要 4 个新
  preg），用前导 1 选择树；选中项进 WF_ALLOC；
- **分配寄存器**：`rtu_idu_alloc_pipedown` 系列把预选 preg 推给 IDU 的
  rename 级（这就是 WF_ALLOC 态存在的原因——分配延迟被流水化了，
  IDU 手里始终攥着几个备用 preg）；
- 7 路写回位图（IU pipe0/1、LSU pipe3、VFPU 等）按位或后分发各项；
- `rtu_idu_no_alloc_preg`（空闲不足反压 IDU，Backend Stall 的另一来源）；
- 汇总 `pst_retire_retired_reg_wb`（全部已退休项均已写回）给 flush 状态机。

复位细节（entry.v:255, 446-449）：`x_reset_mapped` 的 32 项复位即 RETIRE 态
并映射到 x0~x31（dst_reg=自身号），其余 64 项 DEALLOC——开机时逻辑寄存器
就有正身。

## 5. 数量核算

96 preg = 32 体系结构正身（RETIRE 态常驻）+ 64 在飞重命名额度。
ROB 64 项 × 折叠后实际在飞写寄存器指令数与之匹配——**preg 不足与 ROB 满
几乎同时发生**，资源配比是设计点而非巧合。

## 6. Verdi 观察建议

层次：`...x_ct_rtu_top.x_ct_rtu_pst_preg.x_ct_rtu_pst_preg_entryN`

| 信号 | 看什么 |
|------|--------|
| `lifecycle_cur_state[4:0]` | 单 preg 的五态轮转 |
| `wb_cur_state` | 写回先于/晚于退休的两种次序 |
| `retire_inst0_iid_match` | 预比较锁存的时序优化 |
| 顶层 `rtu_idu_no_alloc_preg` | preg 枯竭反压 |
| flush 拍各项状态 | ALLOC 集体跳回 DEALLOC、RETIRE 纹丝不动 |

选一个频繁使用的 entry（如 entry40 附近），跑 hello_world 看完整生命周期：
DEALLOC→WF_ALLOC→ALLOC→RETIRE→（下任退休）→RELEASE→DEALLOC。
