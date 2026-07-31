# C910 IDU 依赖项单元（dep）详解

> RTL 源文件：
> - `ct_idu_dep_reg_entry.v`（标量源 src0/src1 依赖项，377 行）
> - `ct_idu_dep_reg_src2_entry.v`（标量源 src2 依赖项，425 行）
> - `ct_idu_dep_vreg_entry.v`（向量源 srcv0/srcv1 依赖项，364 行）
> - `ct_idu_dep_vreg_srcv2_entry.v`（向量源 srcv2 依赖项，469 行）

---

## 目录

1. [模块概述：依赖项在唤醒机制中的角色](#1-模块概述)
2. [标量依赖项 dep_reg_entry（核心基础）](#2-标量依赖项-dep_reg_entry)
   - 2.1 状态寄存器与数据总线
   - 2.2 时钟门控策略
   - 2.3 推测唤醒（rdy）：核心逻辑
   - 2.4 Load 旁路匹配（lsu_match）
   - 2.5 写回确认位（wb）
   - 2.6 物理寄存器号（preg）
   - 2.7 flush 处理
3. [src2 依赖项 dep_reg_src2_entry](#3-src2-依赖项-dep_reg_src2_entry)
   - 3.1 与 dep_reg_entry 的差异：mla_rdy
   - 3.2 MLA 旁路路径
4. [向量依赖项 dep_vreg_entry](#4-向量依赖项-dep_vreg_entry)
   - 4.1 向量执行流水线的多阶推测唤醒
   - 4.2 向量 Load 推测唤醒
   - 4.3 向量写回确认
5. [向量 srcv2 依赖项 dep_vreg_srcv2_entry](#5-向量-srcv2-依赖项-dep_vreg_srcv2_entry)
   - 5.1 VMLA 累加源的特殊路径
   - 5.2 vdsp_fwd 与同周期旁路
6. [四种 dep 单元全面对比](#6-四种-dep-单元全面对比)
7. [依赖项与发射就绪的关系](#7-依赖项与发射就绪的关系)
8. [完整唤醒时序图](#8-完整唤醒时序图)

---

## 1. 模块概述

### 1.1 为什么需要 dep 单元

乱序执行（Out-of-Order Execution）的核心挑战是**RAW（先写后读）数据依赖**。指令 B 读取的源操作数可能正在被指令 A 计算中，B 必须等 A 的结果就绪才能执行。

在 C910 中，指令从 dispatch（分派）到 issue（发射）期间驻留在**发射队列（Issue Queue）**里。每条等待发射的指令需要实时追踪其每个源操作数的就绪状态。`dep_*_entry` 就是承担这一任务的**最小构件**——每个源操作数对应一个 dep 实例。

### 1.2 dep 单元在系统中的位置

```
Dispatch
   |
   v
+------------------+  +------+  +------+  +------+
|  aiq_entry       |  | dep  |  | dep  |  | dep  |   <-- src0/src1/src2 各一个
|  (AIQ 发射队列)  |--| _reg |  | _reg |  | _reg |
|                  |  | _ent |  | _ent |  | _src2|
+------------------+  +------+  +------+  +------+
                          ^         ^
                          |         |
              各执行单元写回广播总线（preg + vld）

+------------------+  +-------+  +-------+  +-------+  +-------+
|  viq_entry       |  | dep   |  | dep   |  | dep   |  | dep   |
|  (VIQ 向量队列)  |--| _vreg |  | _vreg |  | _vreg |  | _vreg |
|                  |  | _ent  |  | _ent  |  | _srcv2|  | _ent  |
+------------------+  +-------+  +-------+  +-------+  +-------+
                       srcv0      srcv1       srcv2      srcvm
```

### 1.3 dep 单元的职责

每个 dep 单元追踪**单个源操作数**的状态，对外提供：

| 输出信号 | 含义 |
|----------|------|
| `x_read_rdy` | `rdy_update` 的组合值；既是正常更新路径的寄存器下一状态，也可在锁存前被上层读取 |
| `x_read_rdy_for_issue` | 当前组合时刻可参与队列 ready 判断，包含若干已由上层预匹配的快速旁路条件 |
| `x_read_rdy_for_bypass` | 当前存储的 `rdy` 值；该模块中等于 `rdy`，不额外证明数据此刻位于哪条数据总线 |
| `x_read_wb` | `wb_update` 的组合值，表示已存储写回状态或本拍匹配到确认写回 |
| `x_read_preg/vreg` | 所监听的物理寄存器号 |
| `x_read_lsu_match` | 本源与当前 AG 阶段 load 目标匹配 |

**关键设计哲学**：dep 单元区分两类"就绪"：
- **推测就绪（rdy）**：调度侧认为结果将在消费者所需窗口可用，使该源可以参与发射资格判断；它仍可能被 `rdy_clear` 撤销。
- **确认就绪（wb）**：该 dep 叶子已观察到对应 PRF 写回接口，或由创建状态告知已写回；它是源状态，不是全局 PRF 有效位。

若所有消费者都等 `wb` 才参与选择，会错过执行结果已经可旁路、但尚未完成 PRF 确认的窗口。`rdy` 与快速条件用于缩短这种等待；能改善多少吞吐取决于工作负载、端口竞争和投机撤销率，不能由该局部逻辑宣称“最大化”。

---

## 2. 标量依赖项 dep_reg_entry

`ct_idu_dep_reg_entry` 是最基础的依赖项单元，用于 AIQ（整数发射队列）和 LSIQ（访存发射队列）的 src0/src1 源操作数。理解它是理解全部四种 dep 单元的钥匙。

### 2.1 状态寄存器与数据总线

#### 寄存器存储

```verilog
// 行 101-104
reg             lsu_match;   // load 旁路匹配标志
reg     [6 :0]  preg;        // 源操作数的物理寄存器号（7 位编码；整数 PRF 实现 96 项）
reg             rdy;         // 推测就绪位
reg             wb;          // 写回确认位
```

四个寄存器保存一个源操作数在 dep 叶子中的持久状态：
- `preg`：存放"我在等谁产生结果"，即源操作数重命名后的物理寄存器编号
- `rdy`：预测结果将就绪（但可能尚未真正写入 PRF）
- `wb`：结果已确实写入 PRF
- `lsu_match`：前一拍 AG 匹配结果的锁存值，用于与当前 DC load-forward 有效条件配对

#### 创建总线解码（dispatch 写入）

```verilog
// 行 227-230
assign x_create_lsu_match           = x_create_data[9];
assign x_create_preg[6:0]           = x_create_data[8:2];
assign x_create_wb                  = x_create_data[1];
assign x_create_rdy                 = x_create_data[0];
```

dispatch 时，上层（`aiq_entry` 等）将打包好的 10 位 `x_create_data` 送入，dep 单元解包：

| 位域 | 字段 | 说明 |
|------|------|------|
| [9] | lsu_match | 上层随创建总线提供的初始 LSU 匹配状态；本叶子不负责推导该初值 |
| [8:2] | preg[6:0] | 7 位物理寄存器号 |
| [1] | wb | 上层提供的创建时写回确认状态 |
| [0] | rdy | dispatch 时是否推测就绪 |

#### 读出总线编码

```verilog
// 行 232-237
assign x_read_data[11]              = x_read_lsu_match;
assign x_read_data[10]              = x_read_rdy_for_bypass;
assign x_read_data[9]               = x_read_rdy_for_issue;
assign x_read_data[8:2]             = x_read_preg[6:0];
assign x_read_data[1]               = x_read_wb;
assign x_read_data[0]               = x_read_rdy;
```

读出为 12 位，比创建总线多出 `rdy_for_bypass` 和 `rdy_for_issue`。还需注意，读出的 `rdy` 和 `wb` 也不是简单回送寄存器：RTL 分别连接 `rdy_update` 和 `wb_update`，因此可以在本拍匹配事件锁存前反映更新结果。只有 `preg` 是直接回送已存储编号。

### 2.2 时钟门控策略

dep 单元会在每个需要追踪源依赖的发射队列表项中实例化，数量较多。当前 RTL 的
AIQ0 和 AIQ1 各有 8 项，每项各追踪 3 个标量源；AIQ1 的 src2 使用带 `mla_rdy`
的 `dep_reg_src2_entry` 变体。LSIQ 等队列还会按自己的源数复用相同结构。为降低动态
功耗，每个 dep 单元都有精细的时钟门控：

```verilog
// 行 186
assign dep_clk_en = x_gateclk_write_en || gateclk_entry_vld && (!rdy || !wb);
```

**本地门控请求解读**：
- `x_gateclk_write_en`：有新指令写入时必须开启时钟
- `gateclk_entry_vld && (!rdy || !wb)`：entry 有效（有指令驻留）**且**（rdy 或 wb 还未全部置 1）时才需要检查唤醒

当 entry 有效且 `rdy=wb=1`，又没有创建请求时，`dep_clk_en` 为 0，表示该叶子不再主动请求 `dep_clk` 翻转。这里不能写成“单元完全关闭”：

- `gated_clk_cell` 还接收 `cp0_yy_clk_en`、`cp0_idu_icg_en` 和扫描使能，最终门控行为受这些输入共同决定；
- 物理寄存器号比较和 OR 树是组合逻辑，广播输入变化时仍可能产生组合翻转；门控直接抑制的是 `rdy/wb/lsu_match` 等状态触发器的时钟活动；
- 动态功耗减少多少需要门级活动率或功耗分析，不能由 `local_en=0` 定量推出。

还要注意公开 `gated_clk_cell.v` 的实现分支：定义 `C910_USE_TSMC28_ICG` 时才例化
技术 ICG；否则 `clk_out` 直接等于 `clk_in`。因此默认 RTL 仿真里可能看不到
`dep_clk_en=0` 导致停钟，而综合网表是否真正门控取决于所用宏和综合流程。

```verilog
// 行 205
assign write_clk_en = x_gateclk_idx_write_en;
```

`preg` 寄存器使用独立的 `write_clk`，其本地使能为 `x_gateclk_idx_write_en`。在一个 entry 驻留期内，`preg` 只在创建写入时更新；最终时钟仍受该门控单元的全局、模块和扫描输入控制。

### 2.3 推测唤醒（rdy）：核心逻辑

这是整个 dep 单元最重要的部分，也是乱序调度的精髓所在。

#### 监听端口全景

dep_reg_entry 同时监听 **7 条写回/广播总线**：

```verilog
// 行 247-261
assign alu0_data_ready   = ctrl_xx_rf_pipe0_preg_lch_vld_dupx
                           && (dp_xx_rf_pipe0_dst_preg_dupx[6:0] == preg[6:0]);
assign alu1_data_ready   = ctrl_xx_rf_pipe1_preg_lch_vld_dupx
                           && (dp_xx_rf_pipe1_dst_preg_dupx[6:0] == preg[6:0]);
assign mult_data_ready   = iu_idu_ex2_pipe1_mult_inst_vld_dupx
                           && (iu_idu_ex2_pipe1_preg_dupx[6:0] == preg[6:0]);
assign div_data_ready    = iu_idu_div_inst_vld
                           && (iu_idu_div_preg_dupx[6:0] == preg[6:0]);
assign load_data_ready   = lsu_idu_dc_pipe3_load_inst_vld_dupx
                           && (lsu_idu_dc_pipe3_preg_dupx[6:0] == preg[6:0]);
assign vfpu0_data_ready  = vfpu_idu_ex1_pipe6_mfvr_inst_vld_dupx
                           && (vfpu_idu_ex1_pipe6_preg_dupx[6:0] == preg[6:0]);
assign vfpu1_data_ready  = vfpu_idu_ex1_pipe7_mfvr_inst_vld_dupx
                           && (vfpu_idu_ex1_pipe7_preg_dupx[6:0] == preg[6:0]);
```

每条 `xxx_data_ready` 都是同一模式：**有效信号 AND 目标物理寄存器号与本源号匹配**。匹配就意味着"产生我所需结果的指令正在广播"。

下表汇总所有 data_ready 信号的来源：

| 信号 | 执行单元 | 广播时刻 | 说明 |
|------|----------|----------|------|
| `alu0_data_ready` | ALU0（pipe0） | `preg_lch_vld` 接口有效时 | 目的 preg 与本源匹配；“latch”是接口阶段名，不等同于本模块确认 PRF 已写入 |
| `alu1_data_ready` | ALU1（pipe1） | `preg_lch_vld` 接口有效时 | 同上 |
| `mult_data_ready` | 乘法器（pipe1） | `ex2_pipe1_mult_inst_vld` 有效时 | EX2 接口上的乘法目的 preg 匹配；不从该信号单独推导总乘法延迟 |
| `div_data_ready` | 除法器 | `iu_idu_div_inst_vld` 有效时 | `ct_iu_div` 将该信号接到 `div_wb_inst_vld`，表示除法结果到达其 WB 有效窗口 |
| `load_data_ready` | LSU（pipe3） | DC load 接口有效时 | DC 阶段 load 目的 preg 匹配；该信号不含 cache-hit 位，也不直接证明数据已返回 |
| `vfpu0_data_ready` | VFPU0（pipe6） | MFVR EX1 接口有效时 | MFVR 目的标量 preg 匹配 |
| `vfpu1_data_ready` | VFPU1（pipe7） | MFVR EX1 阶段 | 同上 |

#### 唤醒聚合与推测就绪更新

```verilog
// 行 267-273
assign data_ready = alu0_data_ready
                    || alu1_data_ready
                    || mult_data_ready
                    || div_data_ready
                    || load_data_ready
                    || vfpu0_data_ready
                    || vfpu1_data_ready;

// 行 275
assign wake_up = wb;   // wb=1 说明结果早已写回，直接唤醒

// 行 284
assign rdy_update = (rdy || data_ready || wake_up) && !rdy_clear;
```

`rdy_update` 是组合函数。在没有 flush 和创建写入抢占时，它会在 `dep_clk` 的有效边沿写入 `rdy`；与此同时，它还直接输出为 `x_read_rdy`，所以本拍组合逻辑已经可以观察到该值。置位来源为：
1. `rdy` 已经是 1（保持）
2. `data_ready`：某个执行单元广播了匹配的物理寄存器号（推测唤醒）
3. `wake_up = wb`：已存储的写回确认位为 1

最后的 `&& !rdy_clear` 对上述保持/置位项统一生效，因此在**正常状态更新路径**中，`rdy_clear=1` 会使 `rdy_update=0`。顺序逻辑另有更高层优先级：异步复位优先，其后是 flush，再后是 `x_write_en`，最后才采用 `rdy_update`；所以不能把 `rdy_clear` 描述成对创建写入和 flush 也无条件最高优先。

**为什么 wake_up = wb？**

它保证一个已保存为 `wb=1` 的驻留源最终也保持 `rdy=1`。这是一条状态一致性补充路径；至于创建时为什么会形成某种 `wb/rdy` 组合，由上层创建数据决定，不能仅凭此叶子假设某个组合“理论上不会发生”。

#### Load 相关信号的相对时序

```
AG 观察窗口：
  lsu_idu_ag_pipe3_load_inst_vld && 目的 preg 匹配
    -> lsu_match_update = 1
    -> x_read_lsu_match 当拍组合为 1
    -> 若 dep_clk 有有效边沿且未被 flush/create 抢占，lsu_match 锁存为 1

后续 DC 观察窗口：
  load_inst_vld && 目的 preg 匹配
    -> load_data_ready = 1
    -> rdy_update / x_read_rdy 可组合置 1

  load_fwd_inst_vld && 已锁存 lsu_match
    -> load_issue_data_ready = 1
    -> x_read_rdy_for_issue 当拍可组合置 1
```

这组逻辑体现“阶段广告 + 快速旁路资格”的投机调度思路，但 dep 叶子看不到 cache-hit、miss、replay 或返回数据本身。因此不能仅凭 `load_inst_vld` 写成“已知命中”，也不能固定断言消费者下一拍必然发射。消费者还要通过队列冻结、端口资源、年龄优先和上层取消条件。

#### 撤销机制（rdy_clear）

```verilog
// 行 277
assign rdy_clear = x_rdy_clr;
```

`x_rdy_clr` 由上层队列传入。它可用于撤销不再成立的投机就绪，load miss/replay 是典型原因，但该叶子无法识别清除的具体原因。在没有 flush/create 抢占且 `dep_clk` 产生有效边沿时，`rdy_clear=1` 使本拍 `x_read_rdy=0`，并使锁存后的 `rdy` 变为 0。

这是典型的投机唤醒：先按预期的数据返回时机唤醒依赖者，条件不再成立时用
`rdy_clear` 撤销。它把比较和选择提前到数据真正到达之前，但具体节省多少周期取决于
LSU 流水级、命中路径和消费者所在队列，不能仅凭该 dep 模块固定写成 1~2 周期。

#### 三个"就绪"信号的区别

```verilog
// 行 286-291
assign x_read_rdy           = rdy_update;          // 组合更新值/正常路径下一状态
assign x_read_rdy_for_issue = rdy || alu0_issue_data_ready
                                  || alu1_issue_data_ready
                                  || load_issue_data_ready;  // 本拍可发射
assign x_read_rdy_for_bypass = rdy;                // 本拍可旁路读
```

| 信号 | 时序 | 含义 |
|------|------|------|
| `x_read_rdy` | `rdy_update` 组合值 | 正常更新路径的下一状态，同时可在锁存前被打包输出；不是“只能下一拍使用” |
| `x_read_rdy_for_issue` | `rdy` 或特定快速条件 | 直接参与当前队列表项的 `x_rdy` 组合判断；它描述调度资格，不是 EX 级事后确认 |
| `x_read_rdy_for_bypass` | 仅为已存储 `rdy` | 不含本拍 ALU/load 快速项；名称中的 bypass 是接口用途，不能单独证明操作数数据已到达 |

**旁路就绪信号**：

```verilog
// 行 263-265
assign alu0_issue_data_ready = alu0_reg_fwd_vld;
assign alu1_issue_data_ready = alu1_reg_fwd_vld;
assign load_issue_data_ready = lsu_idu_dc_pipe3_load_fwd_inst_vld_dupx && lsu_match;
```

- `alu0/1_reg_fwd_vld`：传入某个 dep 实例的上游预匹配结果。AIQ/LSIQ 顶层按 entry 和源拆分该信号，因此叶子无需再次比较 preg；不能把它误写成不区分目标号的全局有效位。
- `load_issue_data_ready`：DC load-forward 接口有效，且前一拍锁存的 AG 目的号匹配。它表示调度侧认可这条快速路径，数据选择本身不在 dep 模块内完成。

所以 `rdy_for_issue` 中看不到 ALU preg 比较，不是因为它接受了一个未经区分的全局广播，而是比较已经在上层形成了面向具体 entry/source 的位。核查波形时应同时观察该实例的 `preg`、上层匹配向量及传入的 `alu*_reg_fwd_vld`。

### 2.4 Load 旁路匹配（lsu_match）

```verilog
// 行 308-323
assign lsu_match_update = lsu_idu_ag_pipe3_load_inst_vld
                          && (lsu_idu_ag_pipe3_preg_dupx[6:0] == preg[6:0]);
assign x_read_lsu_match = lsu_match_update;

always @(posedge dep_clk or negedge cpurst_b)
begin
  if(!cpurst_b)            lsu_match <= 1'b0;
  else if(flush)           lsu_match <= 1'b0;
  else if(x_write_en)      lsu_match <= x_create_lsu_match;
  else                     lsu_match <= lsu_match_update;
end
```

`lsu_match` 的作用是区分"当前这条 load 是不是正在产生我所需数据的那条"。

**为什么需要 lsu_match？**

`load_issue_data_ready = lsu_idu_dc_pipe3_load_fwd_inst_vld_dupx && lsu_match`

该 RTL 在 AG 接口比较目的号并锁存 `lsu_match`，后续 DC 快速条件只需与该 1 位状态相与，不再在 `load_issue_data_ready` 表达式中比较 7 位 preg。这是可以确认的逻辑分段。它通常有利于缩短 DC 到队列 ready 的组合锥，但“早一拍”要求 AG/DC 正常逐拍推进，“降低了多少关键路径延迟”则需要流水停顿波形和 STA 证明。

**lsu_match 的生命周期**：
1. AG 观察窗口：load 有效且目标与本源匹配，`lsu_match_update=1`。
2. 随后的合格 `dep_clk` 边沿：若没有 flush/create 抢占，`lsu_match` 锁存该组合值。
3. 后续 DC forward 窗口：`load_fwd_vld && lsu_match` 形成快速发射条件。
4. 在正常更新路径中，若下一次采样时 `lsu_match_update=0`，锁存值回到 0；若门控时钟没有产生边沿，寄存器保持原值，不能笼统写成无条件“下一拍清零”。

读出给上层的是 `lsu_match_update`（组合逻辑，即时反映 AG 阶段状态），而不是寄存器 `lsu_match`，这样上层在同一拍就能获取最新匹配结果。

### 2.5 写回确认位（wb）

```verilog
// 行 333-342
assign pipe0_wb = iu_idu_ex2_pipe0_wb_preg_vld_dupx
                  && (iu_idu_ex2_pipe0_wb_preg_dupx[6:0] == preg[6:0]);
assign pipe1_wb = iu_idu_ex2_pipe1_wb_preg_vld_dupx
                  && (iu_idu_ex2_pipe1_wb_preg_dupx[6:0] == preg[6:0]);
assign pipe3_wb = lsu_idu_wb_pipe3_wb_preg_vld_dupx
                  && (lsu_idu_wb_pipe3_wb_preg_dupx[6:0] == preg[6:0]);
assign write_back = wb || pipe0_wb || pipe1_wb || pipe3_wb;
assign wb_update  = wb || write_back;
```

wb 监听 3 条**确认写回总线**：

| 信号 | 来源 | 写回时机 |
|------|------|----------|
| `pipe0_wb` | IU EX2 pipe0 | ALU0 结果写入 PRF |
| `pipe1_wb` | IU EX2 pipe1 | ALU1/MUL 结果写入 PRF |
| `pipe3_wb` | LSU WB pipe3 | load 结果写入 PRF（cache 确认命中后） |

本叶子的 `wb_update` 只显式比较 pipe0、pipe1 和 LSU pipe3 三组确认写回接口；没有单独把 `iu_idu_div_inst_vld` 接入 `wb_update`。`ct_iu_div` 又把 `iu_idu_div_inst_vld` 定义为 `div_wb_inst_vld`，所以除法完成可直接置 `rdy`。除法结果最终通过哪一路通用 PRF 写端口使 `wb` 置位，应沿 IU 写回连接继续核对，不能在此凭“应该”补出一条 RTL 中不存在的隐含路径。

**wb 与 rdy 的关系**：
- `rdy` 是乐观预测，可能是推测结果
- 对同一个驻留 entry，`wb` 通过 OR 逻辑单调保持为 1；新创建可用 `x_create_wb` 重新初始化，复位和 flush 则把它设为 1
- `rdy` 可以被 `rdy_clear` 撤销，但 `wb` 不可撤销

当已存储 `wb=1` 且 `rdy_clear=0` 时，`wake_up` 使 `rdy_update=1`。这维持 `wb=>rdy` 的稳态关系；不能把它解释为“门控时钟漏采样后的绝对补救保证”，因为实际锁存仍取决于门控边沿和顺序逻辑优先级。

### 2.6 物理寄存器号（preg）

```verilog
// 行 364-372
assign x_read_preg[6:0] = preg[6:0];
always @(posedge write_clk or negedge cpurst_b)
begin
  if(!cpurst_b)      preg[6:0] <= 7'b0;
  else if(x_write_en) preg[6:0] <= x_create_preg[6:0];
  else               preg[6:0] <= preg[6:0];
end
```

preg 使用独立的 `write_clk`（仅 dispatch 时开启），因为 preg 一旦写入就不变——该源操作数对应的物理寄存器号在 dispatch 时由寄存器重命名确定，之后只有发射出队或 flush 时才废弃，中间不会改变。

独立本地使能使 `preg` 不必随依赖状态更新而反复接收时钟。它减少的是这组状态触发器的潜在时钟活动；实际功耗收益需结合门控实现和活动率确认。

### 2.7 flush 处理

```verilog
// rdy 寄存器（行 293-303）
always @(posedge dep_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    rdy <= 1'b1;   // 复位为 1
  else if(rtu_idu_flush_fe || rtu_idu_flush_is)
    rdy <= 1'b1;   // flush 也为 1
  else if(x_write_en)
    rdy <= x_create_rdy;
  else
    rdy <= rdy_update;
end
```

复位和 flush 均将 `rdy`、`wb` 置 **1**（而非 0），`lsu_match` 置 **0**。

**为什么空闲状态取 1？**

发射条件还会与 entry `vld` 相与，因此空 entry 不会仅凭 dep 为 1 被发射。把 `rdy/wb` 复位和 flush 值设为 1，使无效/被清空表项在重新创建前呈现“依赖不阻塞”的中性状态，并使 `(!rdy || !wb)` 为 0，便于关闭本地状态时钟请求。真正创建新项时，`x_write_en` 会装入上层给出的初值。

---

## 3. src2 依赖项 dep_reg_src2_entry

`ct_idu_dep_reg_src2_entry` 处理整数指令的第三个源操作数 src2（通常是 store 的数据源，或乘加指令的累加源）。

### 3.1 与 dep_reg_entry 的差异：mla_rdy

src2 变体沿用普通标量 dep 的 preg、`rdy`、`wb`、`lsu_match` 和通用广播匹配结构，并扩展创建/读出总线，增加 **`mla_rdy`** 状态及 MLA 专用输入。这里说“沿用结构”比“唯一差异”更准确，因为端口宽度、位域位置和 `rdy_for_issue` 表达式也随之改变。

新增的寄存器：

```verilog
// 行 107
reg mla_rdy;  // Multiply-Accumulate 乘累加指令的专用就绪位
```

新增的接口信号：

```verilog
// 行 88-97（输入）
input mla_reg_fwd_vld;    // MLA 专用转发有效
input x_entry_mla;        // 本 entry 是否是 MLA 指令
// 行 102（输出）
output [12:0] x_read_data;  // 比 dep_reg_entry 多 1 位（mla_rdy）
```

创建总线也多 1 位：

```verilog
// 行 239-243
assign x_create_lsu_match = x_create_data[10];  // 位 10（原来是 9）
assign x_create_mla_rdy   = x_create_data[9];   // 新增
assign x_create_preg[6:0] = x_create_data[8:2];
assign x_create_wb        = x_create_data[1];
assign x_create_rdy       = x_create_data[0];
```

### 3.2 MLA 旁路路径

```verilog
// 行 328-330
assign mla_issue_data_ready = x_entry_mla && mla_reg_fwd_vld;
assign mla_data_ready       = mla_issue_data_ready;
```

**为什么 MLA 的 src2 需要特殊处理？**

这里的 MLA 是 RTL 内部由 `x_entry_mla` 标识、具有专用累加源旁路协议的乘加类操作。不能直接把它等同于任意 ISA 指令名：例如浮点 `fmadd` 走哪组源和哪条执行管线，必须再由译码和 pipe 映射确认。概念上，乘加依赖链可写成以下伪操作：

```
MLA P3, P1, P2, P3   // 伪代码：P3 = P1 * P2 + P3
MLA P4, P5, P6, P3   // 第二条的累加源依赖上一条的新目的物理寄存器
```

这里用 `P*` 强调调度器实际比较的是重命名后的物理寄存器号。若只允许确认写回后发射，生产者到消费者间隔会更长；专用就绪路径的目标是让消费者在上游确认可旁路时更早进入候选集合。

`mla_reg_fwd_vld` 由上层按具体 entry/source 送入。这个 dep 叶子只用它更新 `mla_rdy` 和 `rdy_for_issue`，并不携带或选择 MLA 结果数据；真正的数据前递位于 RF/IU 数据通路。因此这里能确认的是“存在 MLA 专用调度资格”，不能仅凭这个 1 位信号断言转发的是哪一级中间结果或比普通 ALU 路径提前固定几拍。

```verilog
// 行 337
assign mla_rdy_update = (mla_rdy || mla_data_ready || wake_up) && !rdy_clear;
```

`mla_rdy_update` 与普通 `rdy_update` 使用相同的“旧值 OR 就绪源 OR `wb`，再由 `rdy_clear` 清除”形式，但两个状态不是互相替代：普通 `rdy` 仍由通用 `data_ready` 更新，`mla_rdy` 额外记录 MLA 专用条件。和 `rdy` 一样，`x_read_mla_rdy` 输出的是组合更新值，顺序锁存还受 flush/create 优先级约束。

#### rdy_for_issue 的扩展

```verilog
// 行 302-306
assign x_read_rdy_for_issue = rdy || mla_rdy
                                  || alu0_issue_data_ready
                                  || alu1_issue_data_ready
                                  || load_issue_data_ready
                                  || mla_issue_data_ready;
```

发射条件中增加了 `mla_rdy` 和 `mla_issue_data_ready`：只要 MLA 转发路径本拍有效，src2 即视为可发射。

---

## 4. 向量依赖项 dep_vreg_entry

`ct_idu_dep_vreg_entry` 处理源码中 VIQ 的向量寄存器源依赖（srcv0/srcv1/srcvm）。结构与 dep_reg_entry 高度相似，但监听的执行单元不同。当前发布 RTL 同时将 `ct_idu_id_decd.v` 的 `x_vec_inst` 和 `ct_cp0_regs.v` 的 `misa_vector` 固定为 0，因此本节描述的是**保留的向量微结构通路**，不能据此认定当前配置已对软件开放 RVV。

### 4.1 向量执行流水线的多阶推测唤醒

`dep_vreg_entry` 监听 VFPU 的 **EX1、EX2、EX3** 三组数据有效/目标寄存器广播。
这些广播对应不同的预计可用窗口，使等待项不必只依赖最终 EX5 写回；但不同 VFPU
指令的实际延迟并不完全相同，不能统一概括为"都在 5 拍以上"。

```verilog
// 行 239-250
assign vfpu0_ex3_data_ready = vfpu_idu_ex1_pipe6_data_vld_dupx
                              && (vfpu_idu_ex1_pipe6_vreg_dupx[6:0] == vreg[6:0]);
assign vfpu0_ex4_data_ready = vfpu_idu_ex2_pipe6_data_vld_dupx
                              && (vfpu_idu_ex2_pipe6_vreg_dupx[6:0] == vreg[6:0]);
assign vfpu0_ex5_data_ready = vfpu_idu_ex3_pipe6_data_vld_dupx
                              && (vfpu_idu_ex3_pipe6_vreg_dupx[6:0] == vreg[6:0]);
// pipe7 对称
```

**命名说明**：局部信号 `ex3_data_ready`/`ex4_data_ready`/`ex5_data_ready`
分别由 VFPU EX1/EX2/EX3 接口驱动。这些名字表达的是调度侧预期的后续可用窗口，
而不是证明所有 VFPU 指令都严格经过同一条固定五级延迟路径。

| 局部匹配信号 | 输入接口 | RTL 可以确认的含义 |
|--------------|----------|--------------------|
| `vfpu0_ex3_data_ready` | VFPU EX1 | EX1 广播的目的 vreg 与等待源匹配 |
| `vfpu0_ex4_data_ready` | VFPU EX2 | EX2 广播的目的 vreg 与等待源匹配 |
| `vfpu0_ex5_data_ready` | VFPU EX3 | EX3 广播的目的 vreg 与等待源匹配 |

**为什么要监听多个阶段？**

从调度角度看，只有最终写回才唤醒会增加生产者到消费者的间隔；过早唤醒又可能让
消费者在数据尚未可旁路时占用选择机会。C910 为多个流水阶段提供匹配广播，依赖项
在接收到与自身物理号相等的广播时置 `rdy`，并由实际旁路条件和清除路径继续约束。
这里是"多窗口投机唤醒"，不是无条件广播所有可能时刻。

### 4.2 向量 Load 推测唤醒

```verilog
// 行 251-254
assign load_data_ready       = lsu_idu_dc_pipe3_vload_inst_vld_dupx
                               && (lsu_idu_dc_pipe3_vreg_dupx[6:0] == vreg[6:0]);
assign load_issue_data_ready = lsu_idu_dc_pipe3_vload_fwd_inst_vld && lsu_match;
```

向量 load（vload）沿用与标量相同的结构模式：DC 接口的目的 vreg 匹配可更新 `rdy`，AG 匹配的锁存值与 DC forward 有效共同形成快速发射条件。它同样不在 dep 内检查 cache hit，也不选择实际旁路数据。

注意向量依赖使用 `vreg` 而非 `preg`，接口编号同样为 7 位。7 位只是编码宽度；
当前 RTU 的 vreg/freg PST 结构各为 64 项，不能写成实现了 128 项向量物理寄存器。

```verilog
// 行 295-296（lsu_match 更新）
assign lsu_match_update = lsu_idu_ag_pipe3_vload_inst_vld
                          && (lsu_idu_ag_pipe3_vreg_dupx[6:0] == vreg[6:0]);
```

### 4.3 向量写回确认

```verilog
// 行 320-328
assign pipe3_wb = lsu_idu_wb_pipe3_wb_vreg_vld_dupx
                  && (lsu_idu_wb_pipe3_wb_vreg_dupx[6:0] == vreg[6:0]);
assign pipe6_wb = vfpu_idu_ex5_pipe6_wb_vreg_vld_dupx
                  && (vfpu_idu_ex5_pipe6_wb_vreg_dupx[6:0] == vreg[6:0]);
assign pipe7_wb = vfpu_idu_ex5_pipe7_wb_vreg_vld_dupx
                  && (vfpu_idu_ex5_pipe7_wb_vreg_dupx[6:0] == vreg[6:0]);
```

向量写回监听 pipe3（vload）、pipe6（VFPU0 EX5）、pipe7（VFPU1 EX5）共 3 条总线，对应向量结果可能来自的路径。

**与标量的对比**：标量 dep_reg_entry 监听 pipe0/pipe1/pipe3 的写回（整数 + load），而向量 dep_vreg_entry 监听 pipe3/pipe6/pipe7 的写回（向量 load + 两路 VFPU）——反映了两种数据类型在 C910 微架构中的执行路径分布。

### 4.4 dep_vreg_entry 没有的东西

与 dep_reg_entry 相比，dep_vreg_entry **不监听**：
- ALU（alu0/alu1）：ALU 只产生标量整数结果
- MUL/DIV：乘除法只写标量 PRF
- MFVR 源：MFVR 是向量→标量移动，目的端是标量 preg，不写向量 vreg

dep_vreg_entry **也没有** `rdy_for_issue` 中的 ALU 旁路项，因为向量指令的发射和旁路逻辑不依赖整数 ALU 转发。

---

## 5. 向量 srcv2 依赖项 dep_vreg_srcv2_entry

`ct_idu_dep_vreg_srcv2_entry` 处理向量乘加指令的第三个源（累加源 srcv2），是向量版的 dep_reg_src2_entry。

### 5.1 VMLA 累加源的特殊路径

与标量 MLA 类似，保留的向量乘加（VMLA）通路处理累加源依赖。下例只是行为伪代码，不能在当前 `misa_vector=0` 的配置中直接当作可执行 RVV 指令：

```
vmacc v0, v1, v2   // v0 = v1 * v2 + v0  (srcv2 = v0)
vmacc v0, v3, v4   // v0 = v3 * v4 + v0  (srcv2 = v0)
```

dep_vreg_srcv2_entry 为此增加了 `mla_rdy` 和一组专用的 VMLA 唤醒信号。

#### 新增接口

```verilog
// 行 72-75（输入）
input ctrl_xx_rf_pipe6_vmla_lch_vld_dupx;  // pipe6 VMLA RF latch 有效
input ctrl_xx_rf_pipe7_vmla_lch_vld_dupx;  // pipe7 VMLA RF latch 有效
input [6:0] dp_xx_rf_pipe6_dst_vreg_dupx;  // pipe6 VMLA 目标向量寄存器
input [6:0] dp_xx_rf_pipe7_dst_vreg_dupx;  // pipe7 VMLA 目标向量寄存器
// 行 88-89
input vfpu0_vreg_fwd_vld;  // VFPU0 向量寄存器转发有效
input vfpu1_vreg_fwd_vld;  // VFPU1 向量寄存器转发有效
// 行 91-101（fmla 专用有效信号）
input vfpu_idu_ex1_pipe6_fmla_data_vld_dupx;
input vfpu_idu_ex2_pipe6_fmla_data_vld_dupx;
// pipe7 对称
input x_entry_vmla;  // 本 entry 是否是 VMLA 指令
```

### 5.2 VMLA mla_rdy 的多层唤醒

```verilog
// 行 367-394
assign vfpu0_fmla_data_ready = x_entry_vmla
                               && vfpu_idu_ex2_pipe6_fmla_data_vld_dupx
                               && (vfpu_idu_ex2_pipe6_vreg_dupx[6:0] == vreg[6:0])
                            || x_entry_vmla
                               && vfpu_idu_ex1_pipe6_fmla_data_vld_dupx
                               && (vfpu_idu_ex1_pipe6_vreg_dupx[6:0] == vreg[6:0]);
assign vfpu1_fmla_data_ready = // pipe7 对称

assign vfpu0_vmla_data_ready = x_entry_vmla
                               && ctrl_xx_rf_pipe6_vmla_lch_vld_dupx
                               && (dp_xx_rf_pipe6_dst_vreg_dupx[6:0] == vreg[6:0]);
assign vfpu1_vmla_data_ready = // pipe7 对称

assign vfpu0_vdsp_fwd_data_ready = x_entry_vmla && vfpu0_vreg_fwd_vld;
assign vfpu1_vdsp_fwd_data_ready = x_entry_vmla && vfpu1_vreg_fwd_vld;

assign mla_data_ready = vfpu0_fmla_data_ready
                        || vfpu1_fmla_data_ready
                        || vfpu0_vmla_data_ready
                        || vfpu1_vmla_data_ready
                        || vfpu0_vdsp_fwd_data_ready
                        || vfpu1_vdsp_fwd_data_ready;
```

按布尔条件展开，共有 8 个原始条件：pipe6/7 各有 FMLA EX1 匹配、FMLA EX2 匹配、VMLA latch 匹配和 `vdsp_fwd`。实现中每条 pipe 的两个 FMLA 条件先 OR 成一个 `vfpu*_fmla_data_ready`，所以 `mla_data_ready` 最终写成 6 个局部信号的 OR。计数时应说明采用“原始条件”还是“聚合后局部信号”，否则“6 路”和“8 路”会看似矛盾。

**各唤醒源含义**：

| 信号 | 时机 | 说明 |
|------|------|------|
| FMLA EX1 匹配条件 | VFPU EX1 接口 | 接口有效且目的 vreg 与等待源相等；具体结果何时到达数据旁路需结合 VFPU |
| FMLA EX2 匹配条件 | VFPU EX2 接口 | 同上，处于另一接口窗口；不能仅按局部变量名判断哪个“更早” |
| `vfpu*_vmla_data_ready` | RF latch 控制接口 | `x_entry_vmla`、VMLA latch 有效和目的号匹配 |
| `vfpu*_vdsp_fwd_data_ready` | 当拍组合输入 | 上游已预匹配的 `vreg_fwd_vld`；本叶子不再比较 vreg |

**全部需要 `x_entry_vmla` 门控**：这些专用条件只对标记为 VMLA 的 entry 有效。普通向量源仍使用常规 `data_ready`；本模块不能从这些控制位证明某条架构指令一定映射成 VMLA。

### 5.3 vdsp_fwd 同周期旁路

```verilog
// 行 323-325
assign x_read_rdy_for_issue = rdy || mla_rdy || load_issue_data_ready
                                           || vfpu0_vdsp_fwd_data_ready
                                           || vfpu1_vdsp_fwd_data_ready;
```

`vdsp_fwd_data_ready` 表示当拍 VFPU 转发条件与目标向量寄存器号匹配，srcv2 的
`rdy_for_issue` 可组合成立。这里的"当拍组合可见"不等于生产者到消费者零周期：
消费者仍需经过队列选择、RF 锁存和执行接口；准确的端到端间隔应从波形测量。

---

## 6. 四种 dep 单元全面对比

### 6.1 接口宽度对比

| 模块 | `x_create_data` | `x_read_data` | 额外状态寄存器 | 额外接口信号 |
|------|-----------------|---------------|----------------|-------------|
| `dep_reg_entry` | 10 位 | 12 位 | - | `alu0/1_reg_fwd_vld` |
| `dep_reg_src2_entry` | 11 位 | 13 位 | `mla_rdy` | 上述 + `mla_reg_fwd_vld`, `x_entry_mla` |
| `dep_vreg_entry` | 10 位 | 12 位 | - | 无 ALU/DIV/MUL 相关 |
| `dep_vreg_srcv2_entry` | 11 位 | 13 位 | `mla_rdy` | `vfpu0/1_vreg_fwd_vld`, `fmla_data_vld`, `vmla_lch_vld`, `x_entry_vmla` |

### 6.2 推测唤醒（data_ready）监听端口对比

| 端口 | dep_reg | dep_reg_src2 | dep_vreg | dep_vreg_srcv2 |
|------|---------|--------------|----------|----------------|
| ALU0（pipe0） | Y（RF latch） | Y | - | - |
| ALU1（pipe1） | Y（RF latch） | Y | - | - |
| MUL（pipe1 EX2） | Y | Y | - | - |
| DIV | Y | Y | - | - |
| LSU load（DC） | Y（DC阶段） | Y | Y（vload DC） | Y（vload DC） |
| VFPU0 MFVR（EX1） | Y（标量目标） | Y | - | - |
| VFPU1 MFVR（EX1） | Y（标量目标） | Y | - | - |
| VFPU0 EX1/2/3 | - | - | Y（3级） | Y（3级） |
| VFPU1 EX1/2/3 | - | - | Y（3级） | Y（3级） |
| VMLA fmla EX1/2 | - | - | - | Y（仅 vmla entry） |
| VMLA RF latch | - | - | - | Y（仅 vmla entry） |
| vdsp_fwd | - | - | - | Y（仅 vmla entry） |

### 6.3 写回确认（wb）监听端口对比

| 端口 | dep_reg | dep_reg_src2 | dep_vreg | dep_vreg_srcv2 |
|------|---------|--------------|----------|----------------|
| IU pipe0 WB | Y | Y | - | - |
| IU pipe1 WB | Y | Y | - | - |
| LSU pipe3 WB（标量） | Y | Y | - | - |
| LSU pipe3 WB（向量） | - | - | Y | Y |
| VFPU0 pipe6 EX5 WB | - | - | Y | Y |
| VFPU1 pipe7 EX5 WB | - | - | Y | Y |

### 6.4 发射就绪（rdy_for_issue）旁路路径对比

| 路径 | dep_reg | dep_reg_src2 | dep_vreg | dep_vreg_srcv2 |
|------|---------|--------------|----------|----------------|
| rdy（寄存器值） | Y | Y | Y | Y |
| mla_rdy | - | Y | - | Y |
| alu0 旁路转发 | Y | Y | - | - |
| alu1 旁路转发 | Y | Y | - | - |
| load 旁路转发（lsu_match） | Y | Y | Y | Y |
| mla_issue_data_ready | - | Y | - | - |
| vdsp_fwd（pipe6/7） | - | - | - | Y（仅 vmla） |

---

## 7. 依赖项与发射就绪的关系

### 7.1 entry 可发射的条件

每个发射队列 entry 维护多个 dep 单元（每个有效源一个）。源就绪是 entry ready 的必要条件，但不是充分条件；冻结、队列 stall、执行资源忙以及年龄约束也可能阻止该项成为可仲裁候选。

```
entry ready = entry_vld
              && !entry_freeze
              && all_required_sources_rdy_for_issue
              && queue_specific_resource_conditions
              && queue_specific_age_conditions
```

以 AIQ entry 为例（简化伪逻辑）：

```verilog
// AIQ0 entry 的实际核心形式
assign x_rdy = vld
               && !frz
               && !ctrl_aiq0_stall
               && !(div && iu_idu_div_busy)
               && src0_rdy_for_issue
               && src1_rdy_for_issue
               && src2_rdy_for_issue;
```

AIQ0/AIQ1/BIQ 都直接把 `read_src*_data` 中的 `rdy_for_issue` 位接入本拍 `x_rdy` 组合逻辑。LSIQ 还先形成 `x_raw_rdy`，再用 `agevec & x_other_raw_rdy` 屏蔽同类型中更年轻的 ready 项。因此“源都 ready”只说明通过数据依赖关口，不等于已经获得 issue grant。

### 7.2 三个就绪信号的使用场景

```
x_read_rdy：
  = rdy_update；表达普通 ready 状态的组合更新值。
  是否被某一级用于创建旁路或下一状态，要看具体上层打包连接。

x_read_rdy_for_issue：
  = 已存储 rdy OR 该变体支持的本拍快速条件。
  在 AIQ/BIQ/LSIQ 等 entry 中直接参与当前 x_rdy。

x_read_rdy_for_bypass：
  = 已存储 rdy。
  用于需要“排除本拍快速项”的旁路创建/传递语义；它本身不是数据 MUX 控制。
```

### 7.3 推测唤醒与取消的完整流程

```
                    Dispatch 时
                        |
             x_create_rdy / x_create_wb 写入
                        |
              每周期检查 data_ready（多路比较器并行）
                        |
               有匹配 → rdy = 1（推测就绪）
                        |
                  entry 进入可发射集合
                        |
            发射选择逻辑选中 → 指令发射（issue）
                        |
              +---------------------------+
              |                           |
       条件持续成立                 上游判定投机失效
              |                           |
       候选继续参与仲裁              x_rdy_clr = 1
              |                           |
       后续确认写回                 组合 rdy_update=0；
                                   合格边沿后 rdy=0
```

### 7.4 新指令 dispatch 时 dep 初始状态

| 情况 | x_create_rdy | x_create_wb | 含义 |
|------|--------------|-------------|------|
| 上层判定源已写回 | 1 | 1 | 创建时按已确认就绪初始化 |
| 上层判定源尚未就绪 | 0 | 0 | 等待后续匹配广播或专用快速条件 |
| 上层另行提供 LSU 初始匹配 | 由上层决定 | 通常由上层决定 | 还需结合 `x_create_lsu_match`；叶子不推导这些初值之间的合法组合 |

dispatch 时的初始值由 IDU 上层重命名/创建数据通路打包进 `x_create_data`。要确认某类指令的具体初值，应追踪对应队列的 `create_src*_data` 赋值，不能仅由 dep 叶子反推。

---

## 8. 完整唤醒时序图

### 8.1 ALU 匹配广播如何影响标量依赖者

```
同一组合观察窗口：
  ctrl_xx_rf_pipe0_preg_lch_vld_dupx = 1
  dp_xx_rf_pipe0_dst_preg_dupx = P10
  dep.preg = P10
    -> alu0_data_ready = 1
    -> rdy_update = x_read_rdy = 1（若 rdy_clear=0）

同拍快速条件（另一条上层预匹配路径）：
  本 entry/source 的 alu0_reg_fwd_vld = 1
    -> x_read_rdy_for_issue = 1
    -> 可直接参与 entry.x_rdy 组合判断

后续合格 dep_clk 边沿：
  若未发生 flush/create 抢占，rdy <= rdy_update
```

因此不存在一条适用于所有消费者的固定“广播后两周期发射”结论：上层预匹配的 `alu*_reg_fwd_vld` 可以让 `rdy_for_issue` 在本拍成立，注册 `rdy` 则为后续周期保留状态。最终 issue 时刻还取决于队列选择和执行端口。

### 8.2 Load 推测唤醒与撤销

```
Cycle:   1      2      3      4      5      6
         |      |      |      |      |      |
Load:    ...    AG接口 DC接口 WB接口
                |      |
                |      +--> lsu_idu_dc_pipe3_load_inst_vld = 1
                |           （阶段有效；不含 cache-hit 或 SRAM-return 证明）
                |                |
                |            load_data_ready = 1
                |                |
                |            Consumer rdy_update = 1
                |                |
                +--> lsu_match_update（AG 阶段预匹配）= 1
                         |
                     次拍 lsu_match = 1

若上游维持该投机：
  rdy 或 load_issue_data_ready 可继续参与 entry.x_rdy；
  是否当拍/后续发射由仲裁决定。

若上游撤销该投机：
  x_rdy_clr=1 -> 当拍 rdy_update=0；
  在正常更新边沿后，已存储 rdy 清零并等待新的就绪事件。
```

### 8.3 向量 FPU 多阶唤醒

```
VFPU EX1 接口有效且 vreg 匹配
  -> 局部信号 vfpu*_ex3_data_ready

VFPU EX2 接口有效且 vreg 匹配
  -> 局部信号 vfpu*_ex4_data_ready

VFPU EX3 接口有效且 vreg 匹配
  -> 局部信号 vfpu*_ex5_data_ready

任一条件有效
  -> data_ready
  -> rdy_update / x_read_rdy
```

VFPU 的 EX1/EX2/EX3 接口都可参与物理号匹配并更新就绪状态，对应调度侧的多个
预计可用窗口。具体哪一路对某条指令有效以及数据最终在哪拍可旁路，必须结合 VFPU
控制信号和该指令的执行类型判断，不能用一条固定五拍时序覆盖全部指令。

### 8.4 VMLA 累加源的条件关系

```
对 pipe6/pipe7 分别计算：
  x_entry_vmla
    && FMLA EX1/EX2 接口有效
    && 接口目的 vreg == dep.vreg
      -> vfpu*_fmla_data_ready

  x_entry_vmla
    && VMLA latch 接口有效
    && latch 目的 vreg == dep.vreg
      -> vfpu*_vmla_data_ready

  x_entry_vmla && 上游预匹配的 vfpu*_vreg_fwd_vld
      -> vfpu*_vdsp_fwd_data_ready

上述聚合条件任一成立：
  -> mla_data_ready
  -> mla_rdy_update

其中 vdsp_fwd 条件还直接参与 x_read_rdy_for_issue。
```

这些条件为保留的 VMLA 源依赖提供多个阶段观察窗口。它们是否改善了多少链式吞吐，需要先启用并验证相应向量配置，再测量生产者到消费者间隔；当前 `x_vec_inst=0`/`misa_vector=0` 配置下不能把这一结构直接写成已获得的运行性能。

---

## 总结

dep 单元是 C910 乱序唤醒机制的最小原子单元，四种变体覆盖了标量、向量、普通源、乘加累加源四种场景：

1. **dep_reg_entry**：最基础，7 路推测唤醒 + ALU 旁路 + load 推测 + rdy_clear 撤销
2. **dep_reg_src2_entry**：在 1 基础上增加 MLA 专用快速路径（mla_rdy）
3. **dep_vreg_entry**：向量版，监听 VFPU 3 阶广播（6路）+ vload 推测
4. **dep_vreg_srcv2_entry**：在 3 基础上增加 VMLA 专用状态；原始条件按阶段展开为 8 个，聚合后 `mla_data_ready` OR 6 个局部信号

所有 dep 单元共享相似的设计框架：**推测就绪（rdy）**参与发射选择，
**确认写回（wb）**记录数据已进入 PRF，**lsu_match**保存 load 目标匹配，
**时钟门控**在无需更新时减少翻转，**rdy_clear**撤销不再成立的投机就绪。
这些机制缩短了常见依赖链，但是否接近最优必须由实际 IPC、发射空洞和生产者到消费者
间隔来验证，不能从局部 RTL 直接得出。
