# C910 整数物理寄存器状态表详解（ct_rtu_pst_preg）

> RTL 源文件：
> - `ct_rtu_pst_preg.v`（8637 行，RTU 最大文件：preg0 固定逻辑 +
>   preg1~95 的 95 个 entry 实例 + 分配指针 + 汇总）
> - `ct_rtu_pst_preg_entry.v`（577 行，单项的生命周期状态机）
>
> 整数物理编号空间是 preg0~preg95，共 96 项。preg0 对应 x0，当前 RTL 将它
> 硬连为已退休、已写回且永不进入空闲池；preg1~95 才由 95 个完整 PST entry
> 跟踪状态。
> 它是寄存器重命名的"下半场"：IDU 的 RAT 负责"分配映射"（`docs/idu/08_ir_rt.md`），
> PST 负责"何时安全地收回"。

---

## 1. 问题背景：物理寄存器的生死簿

重命名消除假依赖的代价是：每条具有**有效整数目的寄存器**且目的不是 x0 的指令，
通常需要占用一个新 preg；是否实际请求分配仍由 IDU 创建控制决定。旧 preg 必须
**等到确认再无人需要它**才能回收。"再无人需要"的精确时刻是：

> 写同一逻辑寄存器的**下一条指令退休**时——此后任何 flush 都不可能回滚到
> 需要旧值的状态。

所以每个可动态分配的 preg 表项记着 `rel_preg`（我退休时该放生的前任）。这就是
allocate-on-rename / free-on-next-writer-retire 方案，与 MIPS R10K 同宗。

preg0 是这个通用规则的结构特例。`ct_rtu_pst_preg.v` 直接令：

```verilog
preg0_cur_state_dealloc     = 1'b0;
preg0_dreg                  = 32'b1;  // 恢复矩阵中固定映射到 x0
preg0_rel_preg_expand       = 96'b0;
preg0_retired_released_wb   = 1'b1;
```

因此它没有 IID、`rel_preg` 或五态生命周期，也不会被空闲选择器分给普通目的
寄存器。后文所说“每项 FSM”默认指 preg1~95。

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
| RELEASE | 下一任写者已退休，本 preg 等 WB 且不再被 SDIQ 引用后回收 | 仍可能被尚未读取 store data 的 SDIQ 项引用 |

**flush 行为是关键**（L288-307）：ALLOC/WF_ALLOC 态遇 `rtu_yy_xx_flush` 回
DEALLOC（推测分配作废）；**RETIRE 态不受 flush 影响**（体系结构状态必须保住）。
这一条就是"重命名表恢复"的本质：flush 后，每个逻辑寄存器的映射 =
处于 RETIRE 态的那个 preg。

**写回子状态机**（L333-382，IDLE/WB 两态）独立运行：执行单元的
`wb_preg_expand[95:0]`（`docs/iu/08_rbus.md` 的 96 位独热）置 WB。回收的最终
条件不是裸的 `RELEASE && WB`，而是
`RELEASE && WB && !x_dealloc_mask`（或 release 到来时已满足该条件而直达
DEALLOC，L300-303）。**未写回或仍被 SDIQ 引用的 preg 都不能回收**，否则
新生产者可能在旧写回落地前覆盖它，或 store-data 消费者可能读到新一代的值。
这正是 retire.v 的 `retire_flush_pipeline_empty` 检查（04 第 3 节）在
PREG 单项粒度上的一个输入来源：
`x_retired_released_wb`（L567-571）向 flush 状态机汇报"我这没有悬空写回"。

## 3. 表项信息与退休匹配（entry.v:384-560）

每项寄存：`iid[6:0]`（生产者）、`dst_reg[4:0]`（逻辑寄存器号）、
`rel_preg[6:0]`（前任 preg）。

**退休匹配的时序优化**（L463-516，注释 "compare retire inst iid before
retire"）：ROB 提前一拍给出 `retire_inst0/1/2_iid_updt_val`，每个 ALLOC 态
表项**预比较**自己的 iid 并锁存 match 位；真正退休拍只需
`retire_vld = retire_inst*_preg_vld && match`（L521-526）一层与门。
preg1~95 共 95 个有状态项各自包含 3 路 7 位退休 IID 预比较；preg0 没有该
比较逻辑。预比较结果被移出真正退休拍的组合路径。

退休瞬间两个动作同时发生：

```verilog
// 1. 放生前任：rel_preg 独热展开后输出（L535-546）
assign x_rel_preg_expand = {96{ALLOC && retire_vld}} & rel_preg_expand;
   // 顶层汇总 preg1~95 的 96 位展开结果；preg0 的贡献固定为全 0
// 2. 自己转正：ALLOC → RETIRE
```

**重命名表恢复位图**（L548-560）：

```verilog
assign x_dreg[31:0] = {32{RETIRE 态}} & dst_reg_expand[31:0];
```

每个有状态项输出“我是逻辑寄存器 X 的正身”位图，preg0 另以
`preg0_dreg=32'b1` 固定贡献 x0 映射。顶层先转置形成 32 组 96 位 one-hot
恢复向量 `r0_preg_expand~r31_preg_expand`，再各用 `ct_rtu_encode_96` 编成
7 位物理号，最终通过 224 位 `rtu_idu_rt_recover_preg` 送给 IDU。
`rtu_yy_xx_flush` 时 RAT 按这 32 个物理号整表重写。这里必须准确区分
“PST 保存状态”和“RAT 保存映射”：PST 不是一份按逻辑寄存器索引的 RAT
checkpoint，也不存在 `PST[x1]=p45` 这种直接表项；它由每个物理寄存器项保存
生命周期和目的逻辑寄存器号，所有处于 RETIRE 态的项共同**导出**已提交映射。
因此恢复不需要 walk ROB，也不需要在每个分支保存一份 RAT checkpoint；代价是
preg1~95 每项一个 5 态 FSM，以及恢复端的位图转置、96-to-7 编码和 224 位宽总线。

## 4. SDIQ dealloc mask：写回完成仍不一定能释放

整数源掩码 `idu_rtu_pst_preg_dealloc_mask[95:0]` 来自 IDU 的 12 项 SDIQ。
`ct_idu_is_sdiq.v` 将每个有效 SDIQ 项保存的 store-data 整数源 preg 展开为
96 位独热，再对 12 项逐位 OR，寄存后送给 RTU：

```text
SDIQ entry0..11 的 src0 preg 独热位图
                  │
                  └──逐位 OR──> idu_rtu_pst_preg_dealloc_mask[95:0]
                                      │
PST pregN: x_dealloc_mask <───────────┘
```

PREG entry 内部使用：

```verilog
wb_cur_state_wb_masked = (wb_cur_state == WB) && !x_dealloc_mask;
```

这揭示了一个容易漏掉的生命周期边界：store 指令已经从一般调度路径前进后，
其待写入内存的数据仍可能由 SDIQ 保存“物理寄存器号”，而不是已经复制好的最终数据。
即使该 preg 的生产者已写回、后继写者也已退休，只要 SDIQ 中还有一项可能按这个号
读取 store data，preg 就不能回到 DEALLOC。`x_dealloc_mask` 表示
“仍有队列消费者引用”，不是“数据尚未写回”，两者必须分开观察。

波形上若看到某 entry 长时间停在 RELEASE，应按以下顺序判断：

1. `wb_cur_state == WB` 是否已经成立；
2. 对应位 `idu_rtu_pst_preg_dealloc_mask[N]` 是否仍为 1；
3. 若掩码为 1，对齐 SDIQ 的 pop、源寄存器选择和 mask 更新拍；
4. 掩码解除后，下一次受门控时钟驱动的生命周期更新才会回到 DEALLOC。

因此，PREG 释放延迟既可能是生产者写回延迟，也可能是 store-data 消费延迟。
只看 WB 端口会漏掉后一类物理寄存器压力。

## 5. 顶层职责（ct_rtu_pst_preg.v）

8637 行的构成：preg0 的固定状态逻辑、preg1~95 的 95 个 entry 例化，以及
以下分配与汇总逻辑：

- **空闲 preg 选择**：顶层维护 `alloc_preg0~3` 四个**按 IR 槽位编号的预分配
  输出寄存器**，但当前整数 PST 只有三条彼此独立的新空闲项选择链：
  `dealloc_preg0`、`dealloc_preg1`、`dealloc_preg2`。源码中完整的第四条
  `dealloc_preg3` 前导选择链已被注释，不能据四个输出端口反推每拍可领取四个
  不同的新 preg；
- **分配寄存器**：`rtu_idu_alloc_pipedown` 系列把预选 preg 推给 IDU 的
  rename 级（这就是 WF_ALLOC 态存在的原因——分配延迟被流水化了，
  IDU 手里始终攥着几个备用 preg）；
- **slot3 复用补位**：当槽 3 需要刷新，而位置槽 0 或槽 1 本拍不需要刷新时，
  `dealloc_preg3_vld` 复用对应的 `dealloc_preg0` 或 `dealloc_preg1` 选择结果。
  这是“4 个位置接口、最多 3 个不同新整数目的”的端口组织：前端一拍最多接收
  3 条体系结构指令，第四个 IR 槽来自 split 微操作；split 使某条指令占两个
  位置时，并不会让当拍需要的不同整数目的寄存器数增加到 4。端口 3 因而需要
  独立的位置语义，却不需要第四个独立空闲项选择器；
- 3 路整数 PREG 写回位图，即 IU pipe0、IU pipe1 和 LSU pipe3，按有效位屏蔽后
  逐位 OR，再把每一位分发给对应 entry；VFPU 的浮点结果使用 FREG 路径，
  不能计入当前 PREG 模块的直接写回端口；
- 输出 `rtu_idu_alloc_preg0~3` 及各自的 `_vld`。当前 RTL 中没有
  `rtu_idu_no_alloc_preg`；IDU 根据有效目的槽所需的分配口是否有效形成
  `ctrl_ir_preg_stall`，并另有 `ctrl_top_ir_preg_not_vld` 表示四个**位置输出**
  未全部有效。后者是接口就绪汇总，不能解释成四条独立空闲选择链都已耗尽；
- 汇总 `pst_retire_retired_reg_wb`。该信号是 PREG、活动 VREG PST、FREG 和
  EREG 的聚合条件，不是只检查整数 PREG，也不是所有执行流水线为空。

复位细节不能概括成“96 个 entry 中 32 个置 RETIRE”，因为 preg0 根本不是
entry。准确结构是：preg0 固定映射 x0；preg1~31 的 31 个 entry 通过
`x_reset_mapped=1` 进入 RETIRE 并映射 x1~x31；preg32~95 的 64 个 entry
进入 DEALLOC。逻辑上仍是 32 个已提交映射和 64 个空闲物理编号。

## 6. 数量核算

复位后可以核算为 1 个固定 preg0 映射 + 31 个 RETIRE entry + 64 个 DEALLOC
entry，逻辑上合计 32 个已提交映射和 64 个空闲编号。运行中仍可把 96 理解为
“32 个当前提交映射所需的基线容量，加上最多 64 个处于其他生命周期或等待回收
的物理版本”，但后半部分不等于 64 条在飞整数写指令：

- ROB 项可能没有整数目的，也可能代表折叠指令；
- FP/EREG 目的使用其他 PST；
- preg 可能停在 WF_ALLOC、ALLOC 或 RELEASE；
- SDIQ dealloc mask 会让已写回的旧版本继续占用物理容量。

所以，`rtu_idu_rob_full` 与 `ctrl_ir_preg_stall` 哪个先出现，取决于 workload 的
整数目的密度、结果延迟、覆盖写频率、store-data 引用寿命和退休速度，不能从
“64 个额外 preg 与 64 个 ROB 项”推导出二者几乎同时发生。

## 7. Verdi 观察建议

层次：`...x_ct_rtu_top.x_ct_rtu_pst_preg.x_ct_rtu_pst_preg_entryN`

| 信号 | 看什么 |
|------|--------|
| `lifecycle_cur_state[4:0]` | 单 preg 的五态轮转 |
| `wb_cur_state` | 写回先于/晚于退休的两种次序 |
| `retire_inst0_iid_match` | 预比较锁存的时序优化 |
| 顶层 `rtu_idu_alloc_preg0~3_vld` | 四个位置预分配输出是否有效；slot3 可能复用 slot0/1 的空闲选择链 |
| IDU `ctrl_ir_preg_stall` | 当前有效目的槽是否真的因缺少对应 preg 而停顿 |
| `x_dealloc_mask` / `idu_rtu_pst_preg_dealloc_mask[N]` | RELEASE 项是否仍被 SDIQ 引用 |
| flush 拍各项状态 | ALLOC 集体跳回 DEALLOC、RETIRE 纹丝不动 |

选一个频繁使用的 entry（如 entry40 附近），跑 hello_world 看完整生命周期：
DEALLOC→WF_ALLOC→ALLOC→RETIRE→（下任退休）→RELEASE→DEALLOC。
