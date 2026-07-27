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
| `x_read_rdy` | 推测就绪位（用于下周期发射条件判断的 rdy 寄存器更新值） |
| `x_read_rdy_for_issue` | 本周期可发射（含旁路路径） |
| `x_read_rdy_for_bypass` | 本周期可旁路读取（数据已在 PRF 或转发网络） |
| `x_read_wb` | 结果已写回 PRF |
| `x_read_preg/vreg` | 所监听的物理寄存器号 |
| `x_read_lsu_match` | 本源与当前 AG 阶段 load 目标匹配 |

**关键设计哲学**：dep 单元区分两类"就绪"：
- **推测就绪（rdy）**：预测结果将在未来某时刻可用，允许指令被选中发射（乐观策略）。
- **确认就绪（wb）**：结果已真正写入 PRF，任何人都可无条件读取。

这两层设计是乱序调度追求低延迟的关键——等 wb 才发射则太保守，提前预测（rdy）再配合旁路网络则可最大化吞吐。

---

## 2. 标量依赖项 dep_reg_entry

`ct_idu_dep_reg_entry` 是最基础的依赖项单元，用于 AIQ（整数发射队列）和 LSIQ（访存发射队列）的 src0/src1 源操作数。理解它是理解全部四种 dep 单元的钥匙。

### 2.1 状态寄存器与数据总线

#### 寄存器存储

```verilog
// 行 101-104
reg             lsu_match;   // load 旁路匹配标志
reg     [6 :0]  preg;        // 源操作数的物理寄存器号（7 位，支持 128 项 PRF）
reg             rdy;         // 推测就绪位
reg             wb;          // 写回确认位
```

四个寄存器完整描述一个源操作数的当前状态：
- `preg`：存放"我在等谁产生结果"，即源操作数重命名后的物理寄存器编号
- `rdy`：预测结果将就绪（但可能尚未真正写入 PRF）
- `wb`：结果已确实写入 PRF
- `lsu_match`：该源恰好是某条正在流水线中的 load 的目标（用于精确 load-to-use 旁路）

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
| [9] | lsu_match | 该源是否已知正在被某 load 产生（dispatch 时就能确定） |
| [8:2] | preg[6:0] | 7 位物理寄存器号 |
| [1] | wb | dispatch 时结果是否已写回（寄存器已分配但结果早已可用） |
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

读出为 12 位，比写入多 2 位（`rdy_for_bypass` 和 `rdy_for_issue`），因为这两位是组合逻辑计算得到的实时状态，不需要存储。

### 2.2 时钟门控策略

dep 单元为每个入口（发射队列 entry）实例化，数量众多（AIQ 一般 16 entry，每 entry 3 个 src，共 48 个 dep_reg_entry 实例）。为降低动态功耗，每个 dep 单元都有精细的时钟门控：

```verilog
// 行 186
assign dep_clk_en = x_gateclk_write_en || gateclk_entry_vld && (!rdy || !wb);
```

**门控逻辑解读**：
- `x_gateclk_write_en`：有新指令写入时必须开启时钟
- `gateclk_entry_vld && (!rdy || !wb)`：entry 有效（有指令驻留）**且**（rdy 或 wb 还未全部置 1）时才需要检查唤醒

**设计精髓**：一旦 `rdy=1` 且 `wb=1`（源已完全就绪且写回），该 dep 单元就关掉时钟，不再参与任何比较运算，节省功耗。这是"依赖已解决则静默"的功耗优化原则。

```verilog
// 行 205
assign write_clk_en = x_gateclk_idx_write_en;
```

`preg` 寄存器使用独立的写时钟（`write_clk`），只在有新指令 dispatch 时才开启，因为 preg 一旦写入就不再变化。

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
| `alu0_data_ready` | ALU0（pipe0） | RF latch 阶段（EX末） | ALU 锁存写回寄存器文件时 |
| `alu1_data_ready` | ALU1（pipe1） | RF latch 阶段（EX末） | 同上 |
| `mult_data_ready` | 乘法器（pipe1） | EX2 阶段 | 乘法两周期延迟，EX2 广播 |
| `div_data_ready` | 除法器 | 完成时 | 不定周期，完成即广播 |
| `load_data_ready` | LSU（pipe3） | DC 阶段（data cache） | load 推测唤醒，此时数据尚未从 cache 返回 |
| `vfpu0_data_ready` | VFPU0（pipe6） | MFVR EX1 阶段 | 向量→标量移动指令，EX1 即广播 |
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

`rdy_update` 是 `rdy` 寄存器的下一拍值，触发条件（三选一，优先级相同，任一满足即置 1）：
1. `rdy` 已经是 1（保持）
2. `data_ready`：某个执行单元广播了匹配的物理寄存器号（推测唤醒）
3. `wake_up = wb`：若结果已确认写回，即使从未经过 data_ready，也补充置 rdy

**为什么 wake_up = wb？**

考虑 dispatch 时一条指令依赖的源已经写回（wb=1，rdy=0 的情况理论上不应发生，但 wb 置 1 后 rdy 需同步），或者对于 div 这类不定延迟指令，div 写回 wb 后，晚 dispatch 的指令可能直接走 wake_up 路径而不是 data_ready 路径。

#### 推测唤醒时序（以 load-to-use 为例）

```
Cycle:    N      N+1    N+2    N+3    N+4
          |      |      |      |      |
Load:     AG     DC     WB     -      -
           \      \
            \      \-- load_data_ready 广播（DC 阶段，数据从 cache 取出）
             \
              \-- lsu_match 置 1（AG 阶段，地址已知）

Consumer:  wait   wait  [rdy=1  issue   EX
                          通过 load_data_ready 唤醒]
```

load 在 DC 阶段（数据还未从 cache 读出完毕，但已知命中）广播唤醒信号，下游指令在下一拍（WB 阶段）就能发射，利用 WB→EX 的旁路转发网络。这就是"推测"——预测 cache 命中并提前唤醒，如果 cache miss 则需撤销（rdy_clear 机制）。

#### 撤销机制（rdy_clear）

```verilog
// 行 277
assign rdy_clear = x_rdy_clr;
```

`x_rdy_clr` 由上层（is_lsiq 等）传入。当 load 推测唤醒后发现 cache miss，上层广播 `x_rdy_clr=1`，`rdy_update` 因 `!rdy_clear` 条件变为 0，下一拍 `rdy` 清 0，该指令重新进入等待状态。

**这是乱序处理器最精妙的机制之一**：先假设最优情况（cache 命中），唤醒依赖者，若假设错误则撤销——比保守等待 cache 完成再唤醒节省了宝贵的 1-2 周期。

#### 三个"就绪"信号的区别

```verilog
// 行 286-291
assign x_read_rdy           = rdy_update;          // 下拍 rdy 寄存器的值
assign x_read_rdy_for_issue = rdy || alu0_issue_data_ready
                                  || alu1_issue_data_ready
                                  || load_issue_data_ready;  // 本拍可发射
assign x_read_rdy_for_bypass = rdy;                // 本拍可旁路读
```

| 信号 | 时序 | 含义 |
|------|------|------|
| `x_read_rdy` | 组合逻辑，代表下一拍 rdy 寄存器值 | 发射队列 entry 判断"下周期能否被选中"的依据 |
| `x_read_rdy_for_issue` | 纯组合逻辑，本拍可用 | 已发射指令在 EX 阶段读 PRF 时，确认数据可旁路 |
| `x_read_rdy_for_bypass` | 仅 `rdy` | 纯粹的寄存器状态，不含当拍旁路推断 |

**旁路就绪信号**：

```verilog
// 行 263-265
assign alu0_issue_data_ready = alu0_reg_fwd_vld;
assign alu1_issue_data_ready = alu1_reg_fwd_vld;
assign load_issue_data_ready = lsu_idu_dc_pipe3_load_fwd_inst_vld_dupx && lsu_match;
```

- `alu0/1_reg_fwd_vld`：ALU 结果本拍在寄存器转发网络上可用（EX 与 IS 之间单周期旁路）
- `load_issue_data_ready`：load 数据本拍可转发（DC 阶段完成），且该源确实匹配该 load（通过 `lsu_match`）

注意 `rdy_for_issue` 不进行 preg 比较——`alu0/1_reg_fwd_vld` 是全局信号，不区分物理寄存器号。这是因为上层发射逻辑在决定发射时已经做了匹配，`rdy_for_issue` 此时只是"旁路网络本拍有结果"的确认标志。

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

若有多条 load 正在流水线中，DC 阶段可能不止一条 load 完成，但只有目标物理寄存器与本源匹配的那条 load 才能为本指令提供旁路。`lsu_match` 提前在 **AG 阶段**（比 DC 阶段早一拍）锁存匹配结果，避免 DC 阶段再做一次比较，降低关键路径延迟。

**lsu_match 的生命周期**：
1. AG 阶段：检测到 load 进入流水线且目标与本源匹配 → `lsu_match_update=1`
2. 下一拍（DC 阶段）：`lsu_match=1` 已锁存，配合 `load_fwd_vld` 形成旁路就绪
3. 若无新 load 或新 load 不匹配，`lsu_match_update=0`，`lsu_match` 在下拍清 0

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

注意 wb 不监听 div 专用写回——div 延迟不定，其写回通过 `div_data_ready`（对 rdy）和一条隐含路径处理。实际上，div 完成时应该有 preg 广播，wb 由 pipe0 或 pipe1 其中一条检测到（div 结果最终写回到 pipe0 或 pipe1 的 PRF 端口）。

**wb 与 rdy 的关系**：
- `rdy` 是乐观预测，可能是推测结果
- `wb` 是保守确认，一旦置 1 永不清 0（除 flush 外）
- `rdy` 可以被 `rdy_clear` 撤销，但 `wb` 不可撤销

当 `wb=1` 时，`wake_up = wb = 1`，会将 `rdy` 也强制拉高（见 `rdy_update = ... || wake_up`）。这确保了即使某个 dep 单元在 data_ready 广播时因为 clk 关闭而错过了唤醒（理论上不应发生，但作为安全保障），最终写回时也一定能唤醒。

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

独立写时钟减少了 preg 存储阵列的翻转次数，对于 7 位宽的寄存器阵列而言是有效的功耗优化。

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

**为什么 rdy/wb 复位为 1？**

空闲的 dep 单元（没有有效指令时）需要"默认就绪"，否则发射队列的选择逻辑会因为空 entry 的 dep 单元为 0 而误判该 entry 不可发射。把空 entry 的 dep 置 1 是"不持有有效指令则不产生阻塞"的安全设计。

---

## 3. src2 依赖项 dep_reg_src2_entry

`ct_idu_dep_reg_src2_entry` 处理整数指令的第三个源操作数 src2（通常是 store 的数据源，或乘加指令的累加源）。

### 3.1 与 dep_reg_entry 的差异：mla_rdy

src2 完全继承了 dep_reg_entry 的全部逻辑，唯一新增的是 **mla_rdy** 寄存器及其相关逻辑。

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

乘加指令（MLA：Multiply-Accumulate，如 `fmadd`/`madd`）有三个源：src0（乘数1）、src1（乘数2）、src2（累加源）。在乘加链（accumulation chain）中，前一条 MLA 的**结果**是下一条 MLA 的 **src2（累加源）**：

```
MLA r3, r1, r2, r3   // r3 = r1 * r2 + r3  (src2 = r3)
MLA r3, r4, r5, r3   // r3 = r4 * r5 + r3  (src2 = r3)
MLA r3, r6, r7, r3   // r3 = r6 * r7 + r3  (src2 = r3)
```

这三条指令形成依赖链，若按普通路径等待，每条 MLA 都要等前一条完全写回才能发射，严重限制吞吐。

通过 `mla_reg_fwd_vld`（MLA 专用转发有效信号），前一条 MLA 在执行中的某个阶段可以将**中间结果**转发给等待的下一条 MLA，使下一条 MLA 的 src2 提前就绪——这是 MLA 指令链的专用优化，比普通 ALU 旁路路径更激进。

```verilog
// 行 337
assign mla_rdy_update = (mla_rdy || mla_data_ready || wake_up) && !rdy_clear;
```

`mla_rdy` 的更新逻辑与 `rdy` 完全对称，只是唤醒源变成了 `mla_data_ready`（而非 `data_ready`）。

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

`ct_idu_dep_vreg_entry` 处理向量指令（VIQ 中）的源向量寄存器依赖（srcv0/srcv1/srcvm）。结构与 dep_reg_entry 高度相似，但监听的执行单元完全不同。

### 4.1 向量执行流水线的多阶推测唤醒

向量 FPU（VFPU）执行延迟比整数 ALU 长得多（通常 5 拍以上），因此需要更多阶段的推测唤醒广播。dep_vreg_entry 监听 VFPU 的 **EX1、EX2、EX3** 三个阶段：

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

**命名说明**：信号名为 `ex3_data_ready`/`ex4_data_ready`/`ex5_data_ready`，但驱动它们的输入来自 `ex1`/`ex2`/`ex3` 阶段——这是因为 VFPU 总延迟 5 拍（EX1~EX5），在 EX1 广播时，结果将在 EX3 完成（即再等 2 拍），依此类推。

| 信号名 | 输入来自 | 结果实际就绪时刻 | 等待周期 |
|--------|----------|------------------|----------|
| `vfpu0_ex3_data_ready` | VFPU EX1 广播 | EX3 结束（EX5 写回） | 等 2 拍 |
| `vfpu0_ex4_data_ready` | VFPU EX2 广播 | EX4 结束 | 等 1 拍 |
| `vfpu0_ex5_data_ready` | VFPU EX3 广播 | EX5 结束（即将写回） | 等 0 拍 |

**为什么要监听多个阶段？**

考虑一条 5 拍向量指令（EX1~EX5）：
- 如果只在 EX5 唤醒（保守策略），依赖者需要在 EX5 后才能发射，浪费发射窗口
- 如果在 EX1 就唤醒（激进策略），依赖者发射后需等 2 拍旁路转发

C910 的策略是：**所有可能的就绪时刻都广播**，让依赖者尽早被选中发射，由旁路网络保证数据实际到位时可用。这是高性能处理器的标准做法。

### 4.2 向量 Load 推测唤醒

```verilog
// 行 251-254
assign load_data_ready       = lsu_idu_dc_pipe3_vload_inst_vld_dupx
                               && (lsu_idu_dc_pipe3_vreg_dupx[6:0] == vreg[6:0]);
assign load_issue_data_ready = lsu_idu_dc_pipe3_vload_fwd_inst_vld && lsu_match;
```

向量 load（vload）与标量 load 逻辑相同：DC 阶段广播推测唤醒，配合 `lsu_match`（AG 阶段预匹配）实现旁路。

注意向量使用 `vreg` 而非 `preg`，向量寄存器号同样 7 位（支持最多 128 项向量物理寄存器文件）。

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

与标量 MLA 类似，向量乘加（VMLA：Vector Multiply-Accumulate，如 RISC-V V 扩展的 `vmacc`）形成依赖链：

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

VMLA 的 mla_rdy 拥有 **6 个独立的唤醒源**（每路 VFPU 3 个：fmla EX1、fmla EX2、vmla RF latch）加上 2 个旁路就绪信号（vdsp_fwd），共 8 个路径。这比标量 MLA 的 src2 处理复杂得多。

**各唤醒源含义**：

| 信号 | 时机 | 说明 |
|------|------|------|
| `fmla_data_ready`（EX1） | VFPU EX1 | 浮点乘加中间结果在 EX1 可转发给新 VMLA |
| `fmla_data_ready`（EX2） | VFPU EX2 | 更早的转发窗口 |
| `vmla_vmla_data_ready` | RF latch | 向量 MAC 结果写入 RF latch 时（最晚唤醒） |
| `vdsp_fwd_data_ready` | 当拍 | VDSP 转发路径本拍可用，立即发射 |

**全部需要 `x_entry_vmla` 门控**：这些唤醒路径只对 VMLA 指令有意义。普通向量指令的 srcv2 不走这些快速路径，使用常规的 data_ready（7 路 VFPU/load 推测唤醒）。

### 5.3 vdsp_fwd 同周期旁路

```verilog
// 行 323-325
assign x_read_rdy_for_issue = rdy || mla_rdy || load_issue_data_ready
                                           || vfpu0_vdsp_fwd_data_ready
                                           || vfpu1_vdsp_fwd_data_ready;
```

`vdsp_fwd_data_ready` 是最激进的旁路路径——当 VFPU 转发网络**本拍就有**目标向量寄存器的结果时，srcv2 立即视为可发射，无需等待任何唤醒广播。这是为高吞吐向量乘加链专门设计的零延迟转发路径。

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

每个发射队列 entry 维护多个 dep 单元（每个源一个）。entry 的发射条件是**所有源**的 dep 单元都报告就绪：

```
entry 可发射 = entry_vld
              && dep_src0.rdy_for_issue
              && dep_src1.rdy_for_issue
              && dep_src2.rdy_for_issue  (若有)
              && (其他条件，如资源可用)
```

以 AIQ entry 为例（简化伪逻辑）：

```verilog
assign entry_issue_en = entry_vld
                        && src0_dep.x_read_rdy_for_issue
                        && src1_dep.x_read_rdy_for_issue
                        && src2_dep.x_read_rdy_for_issue
                        && issue_slot_avail;
```

所有 dep 单元必须**同时**报告 `rdy_for_issue=1`，才能进入选择仲裁（select）阶段。这是**AND 逻辑**，任何一个源未就绪都会阻止发射。

### 7.2 三个就绪信号的使用场景

```
发射选择仲裁（select）：
  使用 x_read_rdy（次拍 rdy 寄存器值）
  → 选中哪个 entry 在下一拍发射

发射执行确认（issue）：
  使用 x_read_rdy_for_issue（含旁路，本拍结合旁路信号判断）
  → 已选中的 entry 在本拍是否真的能发射（防止旁路出现后撤销）

PRF 读取旁路（bypass）：
  使用 x_read_rdy_for_bypass（仅 rdy 寄存器）
  → 指令被发射后，读 PRF 时是否需要旁路转发
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
              +---------+---------+
              |                   |
           命中 cache          cache miss
              |                   |
          顺利执行           x_rdy_clr = 1
              |                   |
          wb 写回              rdy 清 0
                            指令重新等待唤醒
                                  |
                       真正写回后 wb=1 再次唤醒
```

### 7.4 新指令 dispatch 时 dep 初始状态

| 情况 | x_create_rdy | x_create_wb | 含义 |
|------|--------------|-------------|------|
| 源已就绪（RAT 显示已 wb） | 1 | 1 | 源寄存器已在 PRF，无需等待 |
| 源正在执行，预计很快就绪 | 0 | 0 | 需要等待唤醒广播 |
| 源是当周期 load 目标（提前知道） | 0（或 1） | 0 | 等 DC 阶段推测唤醒 |

dispatch 时的初始值由 RAT（寄存器别名表）和发射队列的创建逻辑（`is_aiq`/`is_lsiq` 中的 dp 模块）计算后打包进 `x_create_data` 传入。

---

## 8. 完整唤醒时序图

### 8.1 ALU 指令唤醒标量依赖者

```
Cycle:    1       2       3       4       5
          |       |       |       |       |
Producer  Issue  EX1/RF_latch  (写回 PRF)
(ALU0):         |
                +--> ctrl_xx_rf_pipe0_preg_lch_vld_dupx = 1
                     dp_xx_rf_pipe0_dst_preg_dupx = P10
                          |
Consumer               当 preg==P10：
(dep_reg):              alu0_data_ready = 1
                          |
                       rdy_update = 1 → 次拍 rdy=1
                                         |
                                     entry 进入可发射集合 → Issue
```

ALU 指令在 EX 末（RF latch 阶段）广播，依赖者在下一拍 rdy=1，再下一拍可被选中发射。整个唤醒延迟约 2 周期（广播→rdy→issue）。

### 8.2 Load 推测唤醒与撤销

```
Cycle:   1      2      3      4      5      6
         |      |      |      |      |      |
Load:    Issue  AG     DC     WB
                |      |
                |      +--> lsu_idu_dc_pipe3_load_inst_vld = 1
                |           (DC 阶段推测唤醒，数据从 SRAM 取出中)
                |                |
                |            load_data_ready = 1
                |                |
                |            Consumer rdy_update = 1
                |                |
                +--> lsu_match_update（AG 阶段预匹配）= 1
                         |
                     次拍 lsu_match = 1

情况A（cache 命中）：
         5      6      7
         |      |      |
Consumer          rdy=1  Issue  EX（数据通过转发）

情况B（cache miss）：
         5      6      7      ...    N
         |      |      |             |
Consumer       rdy=1  x_rdy_clr=1  load WB  data_ready=1  rdy=1  Issue
                      rdy→0         （重新走 wb 路径）
```

### 8.3 向量 FPU 多阶唤醒

```
Cycle:  1     2     3     4     5     6     7     8
        |     |     |     |     |     |     |     |
VFPU:  Issue EX1   EX2   EX3   EX4   EX5   WB
              |     |     |
              |     |     +--> vfpu_ex3_data_ready（EX3 阶段，来自 EX1 广播）
              |     |              dep: rdy=1（若 Consumer 等到 EX3 才 dispatch）
              |     |
              |     +--> vfpu_ex4_data_ready（EX4 阶段，来自 EX2 广播）
              |
              +--> vfpu_ex5_data_ready（EX5 阶段，来自 EX3 广播）
                          |
                       最晚一拍唤醒（结果即将写回）

              （3 个广播窗口，确保无论何时 dispatch，Consumer 尽早唤醒）
```

向量 FPU 5 拍延迟中，EX1/EX2/EX3 三个阶段都广播唤醒信号，对应依赖者将在 EX3/EX4/EX5 结束后实际拿到数据。这三路唤醒信号覆盖了依赖者可能在不同时刻 dispatch 进发射队列的所有情况。

### 8.4 VMLA 累加链唤醒

```
Cycle:  1     2     3     4     5     6     7
        |     |     |     |     |     |     |
VMLA1: Issue EX1   EX2   EX3   EX4   EX5   WB(v0)
              |     |                  |
              |     |          ctrl_rf_pipe6_vmla_lch → vmla_data_ready
              |     |                  |
              |     +--> fmla_ex2_data_ready (EX2 阶段)
              |
              +--> fmla_ex1_data_ready (EX1 阶段)

                        +--> vdsp_fwd_data_ready（同周期转发）

VMLA2（srcv2=v0）:
        各唤醒路径任一触发 → mla_rdy = 1 → 提前发射
```

通过 fmla、vmla、vdsp_fwd 三类共 6 个唤醒源，VMLA 链的 srcv2 能在前一条 VMLA 完成后尽可能快地发射，最大化向量乘加链的吞吐率。

---

## 总结

dep 单元是 C910 乱序唤醒机制的最小原子单元，四种变体覆盖了标量、向量、普通源、乘加累加源四种场景：

1. **dep_reg_entry**：最基础，7 路推测唤醒 + ALU 旁路 + load 推测 + rdy_clear 撤销
2. **dep_reg_src2_entry**：在 1 基础上增加 MLA 专用快速路径（mla_rdy）
3. **dep_vreg_entry**：向量版，监听 VFPU 3 阶广播（6路）+ vload 推测
4. **dep_vreg_srcv2_entry**：在 3 基础上增加 VMLA 链专用多级唤醒（6路 mla_rdy 路径）

所有 dep 单元共享相同的设计框架：**推测就绪（rdy）** 驱动发射选择，**确认写回（wb）** 作为最终保障，**lsu_match** 实现精确 load 旁路，**时钟门控**在源就绪后关闭无用开销，**rdy_clear** 实现推测唤醒的无损撤销。这套机制的组合使得 C910 能在保证正确性的前提下，将执行延迟压缩到接近理论最优。
