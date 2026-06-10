# C910 IDU 前递网络 rf_fwd 详解

## 目录

1. [模块概述：前递的原理与必要性](#1-模块概述前递的原理与必要性)
2. [前递的时序原理](#2-前递的时序原理)
3. [前递单元 fwd_preg：标量寄存器前递](#3-前递单元-fwd_preg标量寄存器前递)
4. [前递单元 fwd_vreg：向量寄存器前递](#4-前递单元-fwd_vreg向量寄存器前递)
5. [前递网络全景：rf_fwd 的例化结构](#5-前递网络全景rf_fwd-的例化结构)
6. [各管线的前递源分析](#6-各管线的前递源分析)
7. [多端口优先级与互斥保证](#7-多端口优先级与互斥保证)
8. [特殊前递逻辑：MLA/VMLA 与 CP0 禁用](#8-特殊前递逻辑mlavmla-与-cp0-禁用)
9. [前递与唤醒的配合](#9-前递与唤醒的配合)
10. [标量 vs 向量前递网络规模对比](#10-标量-vs-向量前递网络规模对比)

---

## 1. 模块概述：前递的原理与必要性

### 1.1 RAW 真依赖问题

在乱序超标量处理器中，发射队列（Issue Queue）会将已就绪的指令调度到各功能管线执行。但"就绪"只代表**物理寄存器（PRF）中已有有效值**，而执行单元产生结果后，通常需要 1~N 个周期才能把结果写回 PRF。

若指令 B 依赖指令 A 的结果（RAW 真依赖），而 A 刚刚执行完毕尚未写回 PRF，B 就必须**等到 A 写回后才能被唤醒发射**——这会浪费若干个周期的流水线时间，成为乱序执行中的性能瓶颈。

**前递（Forwarding / Bypass）** 解决的正是这个问题：

> 当指令 B 在 RF 阶段读取其源操作数时，如果此时某条执行单元恰好产出了与 B 的源物理寄存器号相同的目标寄存器的最新值，就直接将执行单元输出的数据旁路（Bypass）到 B 的操作数输入，而无需等待那个值写回 PRF 再读出。

### 1.2 C910 的背靠背执行

C910 是一颗乱序 4 发射处理器，在理想情况下，相邻两条存在 RAW 依赖的整数指令可以**背靠背执行（back-to-back）**，即：

- 周期 N：指令 A 进入 EX1 执行，产出结果
- 周期 N：指令 B 在 RF 阶段读操作数，此时通过前递网络拿到 A 在 EX1 产出的结果

这样 A 的结果不必等写回 PRF，B 就已经得到了正确的操作数，节省了 1~几个周期的停顿。

### 1.3 rf_fwd 在流水线中的位置

```
  发射队列 (IQ)
       |
  唤醒逻辑 (Wakeup)  ← 感知哪些物理寄存器即将就绪
       |
  调度/发射 (Issue)
       |
  RF 读取阶段 (RF Read)
       |     ↑
  前递网络 rf_fwd  ← 本模块：在 RF 读出数据的同时判断是否需要旁路
       |
  执行单元 (EX1, EX2, ..., LSU, VFPU)
       |
  写回 PRF (Writeback)
```

`ct_idu_rf_fwd` 是 RF 阶段操作数选择的核心：对每条已调度指令的每个源操作数，并行地与所有执行单元在各个阶段产出的写回端口做比较，确定是否命中旁路并选出最新数据。

---

## 2. 前递的时序原理

### 2.1 各执行单元的前递点

C910 存在多条功能管线，每条管线有各自的执行延迟。rf_fwd 汇聚了这些管线在**不同执行阶段**的输出，作为前递候选：

| 信号前缀 | 来源单元 | 管线号 | 阶段 | 时序含义 |
|---|---|---|---|---|
| `iu_idu_ex1_pipe0_fwd_preg` | IU（整数单元） | pipe0 | EX1 | ALU 在 EX1 产出，最快的前递 |
| `iu_idu_ex2_pipe0_wb_preg` | IU | pipe0 | EX2/WB | ALU 两拍延迟后写回 |
| `iu_idu_ex1_pipe1_fwd_preg` | IU | pipe1 | EX1 | 同上，另一个整数流水 |
| `iu_idu_ex2_pipe1_wb_preg` | IU | pipe1 | EX2/WB | |
| `lsu_idu_da_pipe3_fwd_preg` | LSU（访存单元） | pipe3 | DA（数据获取） | load 数据从 cache 取回 |
| `lsu_idu_wb_pipe3_wb_preg` | LSU | pipe3 | WB | load 最终写回 |
| `vfpu_idu_ex3_pipe6_fwd_vreg` | VFPU（向量浮点） | pipe6 | EX3 | 向量最早前递点 |
| `vfpu_idu_ex4_pipe6_fwd_vreg` | VFPU | pipe6 | EX4 | |
| `vfpu_idu_ex5_pipe6_fwd_vreg` | VFPU | pipe6 | EX5 | 向量最晚前递点 |
| `vfpu_idu_ex3_pipe7_fwd_vreg` | VFPU | pipe7 | EX3 | |
| `vfpu_idu_ex4_pipe7_fwd_vreg` | VFPU | pipe7 | EX4 | |
| `vfpu_idu_ex5_pipe7_fwd_vreg` | VFPU | pipe7 | EX5 | |

### 2.2 前递时序示意

以整数 ALU pipe0 背靠背执行为例：

```
周期:      T      T+1     T+2     T+3
           |------|-------|-------|-------|
指令A:     [RF]   [EX1]  [EX2]  [WB→PRF]
                   ↑产出结果
指令B:             [RF]         ← rf_fwd 在此时从 EX1 前递拿到 A 的结果
                   ↓ 通过 fwd_src_sel[0] 前递 data
                   [EX1]  [EX2]  ...
```

`fwd_src_sel[0]`（pipe0 EX1 前递）命中时，B 的操作数不从 PRF 读取，而是直接使用 A 在 EX1 产出的数据。如果 A、B 相差两个周期，则使用 `fwd_src_sel[1]`（pipe0 EX2/WB）。

对于 load 指令（pipe3），数据从 cache 返回在 DA 阶段或 WB 阶段，因此提供两个前递点（`da_pipe3_fwd` 和 `wb_pipe3_wb`）。

对于 VFPU（pipe6/7），向量运算延迟长达 5 拍（EX1~EX5），因此提供 EX3/EX4/EX5 三个前递点，让后续向量指令在尽可能早的时机拿到数据。

---

## 3. 前递单元 fwd_preg：标量寄存器前递

### 3.1 模块定义

文件：`ct_idu_rf_fwd_preg.v`

```verilog
// 行 17-39：模块端口
module ct_idu_rf_fwd_preg(
  iu_idu_ex1_pipe0_fwd_preg,       // pipe0 EX1 产出的目的物理寄存器号 [6:0]
  iu_idu_ex1_pipe0_fwd_preg_data,  // pipe0 EX1 产出的数据 [63:0]
  iu_idu_ex1_pipe0_fwd_preg_vld,   // pipe0 EX1 前递有效
  ...（共 6 个写回端口，每端口有 preg/data/vld 三个信号）
  x_src_reg,    // 待查询的源物理寄存器号 [6:0]（来自 dp，即当前发射指令的 src）
  x_src_data,   // 输出：前递得到的操作数数据 [63:0]
  x_src_no_fwd  // 输出：=1 表示没有任何前递命中，需要从 PRF 读取
);
```

该模块是**整个前递网络的基本计算单元**。它接受一个源寄存器号 `x_src_reg`，与 6 个写回端口逐一比较，选出匹配的数据。

### 3.2 比较逻辑（fwd_src_sel 生成）

```verilog
// 行 95-107：6 路前递选择位
//0: pipe0 ex1, 1: pipe0 ex2, 2: pipe1 ex1, 3: pipe1 ex2, 4: pipe3 da, 5: pipe3 wb
assign fwd_src_sel[0] = iu_idu_ex1_pipe0_fwd_preg_vld
                        && (x_src_reg[6:0] == iu_idu_ex1_pipe0_fwd_preg[6:0]);
assign fwd_src_sel[1] = iu_idu_ex2_pipe0_wb_preg_vld
                        && (x_src_reg[6:0] == iu_idu_ex2_pipe0_wb_preg[6:0]);
assign fwd_src_sel[2] = iu_idu_ex1_pipe1_fwd_preg_vld
                        && (x_src_reg[6:0] == iu_idu_ex1_pipe1_fwd_preg[6:0]);
assign fwd_src_sel[3] = iu_idu_ex2_pipe1_wb_preg_vld
                        && (x_src_reg[6:0] == iu_idu_ex2_pipe1_wb_preg[6:0]);
assign fwd_src_sel[4] = lsu_idu_da_pipe3_fwd_preg_vld
                        && (x_src_reg[6:0] == lsu_idu_da_pipe3_fwd_preg[6:0]);
assign fwd_src_sel[5] = lsu_idu_wb_pipe3_wb_preg_vld
                        && (x_src_reg[6:0] == lsu_idu_wb_pipe3_wb_preg[6:0]);
```

每一路的逻辑是：**该端口有效（vld=1）** 且 **目的物理寄存器号等于源物理寄存器号**，则该路命中。

由于 C910 采用**物理寄存器重命名（RAT）**，比较的是 7 位物理寄存器号而非 5 位逻辑寄存器号，因此不存在 WAR/WAW 误命中的问题——同一物理寄存器号在任何时刻只有一条"进行中"的写入。

### 3.3 无前递标志

```verilog
// 行 109
assign x_src_no_fwd = !(|fwd_src_sel[5:0]);
```

`x_src_no_fwd = 1` 表示没有任何端口命中，操作数应该从 PRF 正常读取。

### 3.4 数据选择（case 语句）

```verilog
// 行 120-128：one-hot case，互斥选择数据
always @(...) begin
  case (fwd_src_sel[5:0])
    6'b000001: x_src_data[63:0] = iu_idu_ex1_pipe0_fwd_preg_data[63:0]; // pipe0 EX1
    6'b000010: x_src_data[63:0] = iu_idu_ex2_pipe0_wb_preg_data[63:0];  // pipe0 EX2
    6'b000100: x_src_data[63:0] = iu_idu_ex1_pipe1_fwd_preg_data[63:0]; // pipe1 EX1
    6'b001000: x_src_data[63:0] = iu_idu_ex2_pipe1_wb_preg_data[63:0];  // pipe1 EX2
    6'b010000: x_src_data[63:0] = lsu_idu_da_pipe3_fwd_preg_data[63:0]; // pipe3 DA
    6'b100000: x_src_data[63:0] = lsu_idu_wb_pipe3_wb_preg_data[63:0];  // pipe3 WB
    default  : x_src_data[63:0] = {64{1'bx}};                           // 无命中，don't care
  endcase
end
```

关键设计要点：
- **case 使用 one-hot 编码，而非优先级编码**。这意味着设计者假定同一周期内不会有两路同时命中同一个物理寄存器。这一假设在 C910 的 ROB/重命名机制保证下是正确的：同一物理寄存器号不可能在同一周期被两个不同的执行单元产出有效结果。
- `default` 输出 `{64{1'bx}}`，是 X 值传播的标准做法，便于仿真时发现错误。
- 整个 case 是纯组合逻辑，没有时序延迟，前递在当周期内完成。

### 3.5 标量前递逻辑结构图

```
                  x_src_reg [6:0]
                       │
              ┌────────┼────────┬────────┬────────┬────────┐
              │        │        │        │        │        │
           == preg  == preg  == preg  == preg  == preg  == preg
           pipe0E1  pipe0E2  pipe1E1  pipe1E2  pipe3DA  pipe3WB
              │ vld    │ vld    │ vld    │ vld    │ vld    │ vld
              AND     AND     AND     AND     AND     AND
              │        │        │        │        │        │
         sel[0]    sel[1]    sel[2]    sel[3]    sel[4]    sel[5]
              └────────┴────────┴────────┴────────┴────────┘
                                     │
                              6-bit one-hot
                                     │
                          ┌──────────┴──────────┐
                          │  case (fwd_src_sel)  │
                          │   one-hot MUX        │
                          └──────────┬──────────┘
                                     │
                               x_src_data [63:0]
                                     │
                              x_src_no_fwd = !(|sel)
```

---

## 4. 前递单元 fwd_vreg：向量寄存器前递

### 4.1 模块定义

文件：`ct_idu_rf_fwd_vreg.v`

```verilog
// 行 17-45：模块端口（精简列出）
module ct_idu_rf_fwd_vreg(
  // VFPU pipe6 的三个前递点：EX3/EX4/EX5
  vfpu_idu_ex3_pipe6_fwd_vreg, vfpu_idu_ex3_pipe6_fwd_vreg_data, vfpu_idu_ex3_pipe6_fwd_vreg_vld,
  vfpu_idu_ex4_pipe6_fwd_vreg, vfpu_idu_ex4_pipe6_fwd_vreg_data, vfpu_idu_ex4_pipe6_fwd_vreg_vld,
  vfpu_idu_ex5_pipe6_fwd_vreg,                                    vfpu_idu_ex5_pipe6_fwd_vreg_vld,
  vfpu_idu_ex5_pipe6_wb_vreg_data,
  // VFPU pipe7 的三个前递点
  vfpu_idu_ex3_pipe7_fwd_vreg, ...
  vfpu_idu_ex4_pipe7_fwd_vreg, ...
  vfpu_idu_ex5_pipe7_fwd_vreg, ...
  // LSU pipe3：向量 load 的两个前递点
  lsu_idu_da_pipe3_fwd_vreg,  lsu_idu_da_pipe3_fwd_vreg_data,  lsu_idu_da_pipe3_fwd_vreg_vld,
  lsu_idu_wb_pipe3_fwd_vreg,  lsu_idu_wb_pipe3_wb_vreg_data,   lsu_idu_wb_pipe3_fwd_vreg_vld,
  x_srcv_reg,   // 源向量物理寄存器号 [6:0]
  x_srcv_data,  // 输出前递数据 [63:0]
  x_srcv_no_fwd // 输出：无前递命中
);
```

### 4.2 向量前递比较逻辑（8 路）

```verilog
// 行 115-130：8 路前递选择位
//0: pipe6 ex3, 1: pipe6 ex4, 2: pipe6 ex5, 3: pipe7 ex3,
//4: pipe7 ex4, 5: pipe7 ex5, 6: pipe3 da  7: pipe3 wb
assign fwd_srcv_sel[0] = vfpu_idu_ex3_pipe6_fwd_vreg_vld
                         && (x_srcv_reg[6:0] == vfpu_idu_ex3_pipe6_fwd_vreg[6:0]);
assign fwd_srcv_sel[1] = vfpu_idu_ex4_pipe6_fwd_vreg_vld
                         && (x_srcv_reg[6:0] == vfpu_idu_ex4_pipe6_fwd_vreg[6:0]);
assign fwd_srcv_sel[2] = vfpu_idu_ex5_pipe6_fwd_vreg_vld
                         && (x_srcv_reg[6:0] == vfpu_idu_ex5_pipe6_fwd_vreg[6:0]);
assign fwd_srcv_sel[3] = vfpu_idu_ex3_pipe7_fwd_vreg_vld
                         && (x_srcv_reg[6:0] == vfpu_idu_ex3_pipe7_fwd_vreg[6:0]);
assign fwd_srcv_sel[4] = vfpu_idu_ex4_pipe7_fwd_vreg_vld
                         && (x_srcv_reg[6:0] == vfpu_idu_ex4_pipe7_fwd_vreg[6:0]);
assign fwd_srcv_sel[5] = vfpu_idu_ex5_pipe7_fwd_vreg_vld
                         && (x_srcv_reg[6:0] == vfpu_idu_ex5_pipe7_fwd_vreg[6:0]);
assign fwd_srcv_sel[6] = lsu_idu_da_pipe3_fwd_vreg_vld
                         && (x_srcv_reg[6:0] == lsu_idu_da_pipe3_fwd_vreg[6:0]);
assign fwd_srcv_sel[7] = lsu_idu_wb_pipe3_fwd_vreg_vld
                         && (x_srcv_reg[6:0] == lsu_idu_wb_pipe3_fwd_vreg[6:0]);
```

向量前递有 **8 路**（vs 标量的 6 路），多出的两路来自 VFPU 的延长流水线（EX3~EX5 三拍）。

### 4.3 向量数据选择

```verilog
// 行 145-155
case (fwd_srcv_sel[7:0])
  8'b00000001: x_srcv_data = vfpu_idu_ex3_pipe6_fwd_vreg_data; // pipe6 EX3
  8'b00000010: x_srcv_data = vfpu_idu_ex4_pipe6_fwd_vreg_data; // pipe6 EX4
  8'b00000100: x_srcv_data = vfpu_idu_ex5_pipe6_wb_vreg_data;  // pipe6 EX5(WB)
  8'b00001000: x_srcv_data = vfpu_idu_ex3_pipe7_fwd_vreg_data; // pipe7 EX3
  8'b00010000: x_srcv_data = vfpu_idu_ex4_pipe7_fwd_vreg_data; // pipe7 EX4
  8'b00100000: x_srcv_data = vfpu_idu_ex5_pipe7_wb_vreg_data;  // pipe7 EX5(WB)
  8'b01000000: x_srcv_data = lsu_idu_da_pipe3_fwd_vreg_data;   // pipe3 DA
  8'b10000000: x_srcv_data = lsu_idu_wb_pipe3_wb_vreg_data;    // pipe3 WB
  default    : x_srcv_data = {64{1'bx}};
endcase
```

同样是 one-hot case，同一周期只会有一路命中。

### 4.4 与标量前递的关键差异

| 特性 | fwd_preg（标量） | fwd_vreg（向量） |
|------|---------|---------|
| 数据宽度 | 64-bit | 64-bit（**每次只传 64-bit 分片**，因此要多次例化） |
| 前递路数 | 6 路（sel[5:0]） | 8 路（sel[7:0]） |
| 整数管线来源 | pipe0/pipe1（EX1/EX2） | 无（向量不走整数管线） |
| 向量管线来源 | 无 | pipe6/pipe7 各三点（EX3/4/5） |
| LSU 来源 | 有（标量 load） | 有（向量/浮点 load） |
| 注意点 | 无 | 一个向量寄存器需分 vr0/vr1/fr 多个 64-bit 分片实例化 |

**为什么每次只传 64-bit？**

C910 的向量寄存器（VREG）宽度为 128-bit（vr0+vr1 各 64-bit），浮点寄存器（FREG）则以 fr 分片传递。为了节省布线面积，`fwd_vreg` 的接口始终是 64-bit，在 `rf_fwd` 顶层对同一个向量源操作数**分别例化 fr/vr0/vr1 三个 `fwd_vreg` 单元**，每个单元只负责一个 64-bit 分片。

---

## 5. 前递网络全景：rf_fwd 的例化结构

### 5.1 顶层模块概览

文件：`ct_idu_rf_fwd.v`（1999 行）

`rf_fwd` 自身没有独立的逻辑计算，全部由例化的 `fwd_preg`/`fwd_vreg` 单元完成，顶层只负责：

1. **汇聚**来自 IU/LSU/VFPU 的所有前递源信号（作为输入端口）
2. **分发**来自 dp（dispatch）的各管线各源寄存器号（作为输入）
3. **例化**大量 `fwd_preg`/`fwd_vreg` 单元，将两者连接
4. **收集**每个单元输出的 `data` 和 `no_fwd`，送回 dp（作为输出）
5. 处理少量**特殊逻辑**（MLA、VMLA、CP0 禁用等）

### 5.2 例化的管线×源×分片全表

下表统计了 rf_fwd 中所有 `fwd_preg` 和 `fwd_vreg` 的例化情况：

#### 标量前递（fwd_preg 例化）

| 管线 | src0 | src1 | 说明 |
|------|------|------|------|
| pipe0 | x_ct_idu_rf_fwd_preg_pipe0_src0 | x_ct_idu_rf_fwd_preg_pipe0_src1 | 整数 ALU 管线 0 |
| pipe1 | x_ct_idu_rf_fwd_preg_pipe1_src0 | x_ct_idu_rf_fwd_preg_pipe1_src1 | 整数 ALU 管线 1（含 MLA）|
| pipe2 | x_ct_idu_rf_fwd_preg_pipe2_src0 | x_ct_idu_rf_fwd_preg_pipe2_src1 | 分支/其他整数 |
| pipe3 | x_ct_idu_rf_fwd_preg_pipe3_src0 | x_ct_idu_rf_fwd_preg_pipe3_src1 | LSU 标量地址/数据 |
| pipe4 | x_ct_idu_rf_fwd_preg_pipe4_src0 | x_ct_idu_rf_fwd_preg_pipe4_src1 | LSU 第二发射槽 |
| pipe5 | x_ct_idu_rf_fwd_preg_pipe5_src0 | — | VFPU 混合指令标量源 |

共 **11 个** `fwd_preg` 实例。

#### 向量前递（fwd_vreg 例化）

每个向量源需要 fr/vr0/vr1 三个分片，每个分片一个 `fwd_vreg` 实例：

| 管线 | 源 | fr | vr0 | vr1 | 说明 |
|------|----|----|-----|-----|------|
| pipe3 | srcvm | — | x_ct_idu_rf_fwd_vreg_vr0_pipe3_srcvm | x_ct_idu_rf_fwd_vreg_vr1_pipe3_srcvm | LSU 向量掩码源 |
| pipe4 | srcvm | — | x_ct_idu_rf_fwd_vreg_vr0_pipe4_srcvm | x_ct_idu_rf_fwd_vreg_vr1_pipe4_srcvm | |
| pipe5 | srcv0 | x_ct_idu_rf_fwd_vreg_fr_pipe5_srcv0 | x_ct_idu_rf_fwd_vreg_vr0_pipe5_srcv0 | x_ct_idu_rf_fwd_vreg_vr1_pipe5_srcv0 | VFPU 混合标量/向量 |
| pipe6 | srcv0 | fr | vr0 | vr1 | VFPU 管线 6 源操作数 0 |
| pipe6 | srcv1 | fr | vr0 | vr1 | VFPU 管线 6 源操作数 1 |
| pipe6 | srcv2 | fr | vr0 | vr1 | VFPU 管线 6 源操作数 2（含 VMLA 特殊） |
| pipe6 | srcvm | — | vr0 | vr1 | VFPU 管线 6 掩码源 |
| pipe7 | srcv0 | fr | vr0 | vr1 | VFPU 管线 7（同上镜像） |
| pipe7 | srcv1 | fr | vr0 | vr1 | |
| pipe7 | srcv2 | fr | vr0 | vr1 | |
| pipe7 | srcvm | — | vr0 | vr1 | |

共 **约 34 个** `fwd_vreg` 实例。

**合计约 45 个前递比较单元**，构成整个前递网络。

### 5.3 结构示意图

```
                         ct_idu_rf_fwd (顶层)
  ┌─────────────────────────────────────────────────────────────┐
  │                                                             │
  │  来自执行单元的前递源（输入）                                │
  │  iu_idu_ex1/ex2_pipe0/1_*  lsu_idu_da/wb_pipe3_*           │
  │  vfpu_idu_ex3/4/5_pipe6/7_*                                 │
  │         │                                                   │
  │         ├──────────────────────────────────────────┐        │
  │         │         每个 fwd_preg/fwd_vreg 实例      │        │
  │         │  ┌────────────────────────────────────┐  │        │
  │         │  │  fwd_preg_pipe0_src0               │  │        │
  │         │  │  x_src_reg = dp_fwd_rf_pipe0_src0  │──┼──→ fwd_dp_rf_pipe0_src0_data  │
  │         ├──│  (全部 6 路前递源都接入)             │  │    fwd_dp_rf_pipe0_src0_no_fwd│
  │         │  └────────────────────────────────────┘  │        │
  │         │                                          │        │
  │         │  ┌────────────────────────────────────┐  │        │
  │         │  │  fwd_vreg_fr_pipe6_srcv0            │──┼──→ fwd_dp_rf_pipe6_srcv0_vreg_fr_data
  │         ├──│  x_srcv_reg = dp_fwd_rf_pipe6_srcv0│  │    fwd_dp_rf_pipe6_srcv0_no_fwd     │
  │         │  └────────────────────────────────────┘  │        │
  │         │                                          │        │
  │         │  （...其余约 43 个实例，结构类似...）       │        │
  │         └──────────────────────────────────────────┘        │
  │                                                             │
  │  来自 dp 的寄存器号（输入）：dp_fwd_rf_pipe*_src*_preg/vreg  │
  │  输出至 dp：fwd_dp_rf_pipe*_src*_data / _no_fwd             │
  └─────────────────────────────────────────────────────────────┘
```

---

## 6. 各管线的前递源分析

### 6.1 标量管线（pipe0~pipe5）

所有标量前递单元都接入**相同的 6 路写回源**（pipe0/pipe1 各 EX1/EX2，pipe3 DA/WB），代码结构完全相同，只有 `x_src_reg` 和 `x_src_data`/`x_src_no_fwd` 连接不同的管线信号。

以 pipe0 src0 为例（行 502-524），每个 `fwd_preg` 例化都完整地将所有 6 路前递源接入：

```verilog
ct_idu_rf_fwd_preg  x_ct_idu_rf_fwd_preg_pipe0_src0 (
  // 整数 pipe0/pipe1 EX1/EX2 前递源（4路）
  .iu_idu_ex1_pipe0_fwd_preg      (iu_idu_ex1_pipe0_fwd_preg      ),
  .iu_idu_ex1_pipe0_fwd_preg_data (iu_idu_ex1_pipe0_fwd_preg_data ),
  .iu_idu_ex1_pipe0_fwd_preg_vld  (iu_idu_ex1_pipe0_fwd_preg_vld  ),
  // ...（pipe1 EX1, pipe0/1 EX2 类似）
  // LSU pipe3 DA/WB 前递源（2路）
  .lsu_idu_da_pipe3_fwd_preg      (lsu_idu_da_pipe3_fwd_preg      ),
  // ...
  // 待查询的源寄存器号及输出
  .x_src_reg  (dp_fwd_rf_pipe0_src0_preg[6:0] ),  // 来自 dp
  .x_src_data (fwd_dp_rf_pipe0_src0_data[63:0]),  // 送回 dp
  .x_src_no_fwd(fwd_dp_rf_pipe0_src0_no_fwd   )
);
```

**为什么每个管线的 src 都接入所有写回源？**

因为在乱序核中，pipe0 的 src0 可能依赖 pipe1 产出的结果，也可能依赖 LSU 产出的结果——依赖关系与发射到哪条管线无关。因此每个 src 都需要与**所有可能的写回端口**比较。

### 6.2 标量前递源总结

| 前递点索引 | 信号来源 | 执行单元 | 阶段 | 特点 |
|-----------|---------|---------|------|------|
| sel[0] | iu pipe0 | 整数 ALU | EX1 | 最快，背靠背 |
| sel[1] | iu pipe0 | 整数 ALU | EX2/WB | 两拍延迟 |
| sel[2] | iu pipe1 | 整数 ALU | EX1 | 最快，背靠背 |
| sel[3] | iu pipe1 | 整数 ALU | EX2/WB | 两拍延迟 |
| sel[4] | lsu pipe3 | 访存 | DA（数据获取） | load 命中 L1 |
| sel[5] | lsu pipe3 | 访存 | WB | load 最终确认 |

### 6.3 向量管线（pipe5~pipe7）

向量管线包含 VFPU（pipe6/pipe7）和混合管线（pipe5 用于 FPU/向量标量源）。它们的前递单元使用 `fwd_vreg`，前递源来自：

- VFPU pipe6/pipe7 各 3 个执行阶段（EX3/EX4/EX5）
- LSU pipe3 向量 load 的 DA/WB 阶段

| 前递点索引 | 信号来源 | 阶段 |
|-----------|---------|------|
| sel[0] | vfpu pipe6 | EX3 |
| sel[1] | vfpu pipe6 | EX4 |
| sel[2] | vfpu pipe6 | EX5 |
| sel[3] | vfpu pipe7 | EX3 |
| sel[4] | vfpu pipe7 | EX4 |
| sel[5] | vfpu pipe7 | EX5 |
| sel[6] | lsu pipe3 | DA |
| sel[7] | lsu pipe3 | WB |

**注意：向量前递没有整数 EX1/EX2 的来源。** 这是因为向量操作数只能来自向量执行单元或向量 load，不可能来自整数 ALU（整数 ALU 写入的是标量物理寄存器，而向量源操作数读的是向量物理寄存器，寄存器号空间不同）。

### 6.4 pipe3/pipe4 的 srcvm（向量掩码源）特殊设计

pipe3（LSU）和 pipe4（第二 LSU 槽）有一个特殊的向量掩码源 `srcvm`，用于向量 store/load 的掩码寄存器。

```verilog
// 行 744-843：pipe3 srcvm 的例化（timing optimization 注释）
//timing optimiation: cannot fwd from vfpu to lsu srcvm
ct_idu_rf_fwd_vreg  x_ct_idu_rf_fwd_vreg_vr0_pipe3_srcvm (
  ...
  .vfpu_idu_ex3_pipe6_fwd_vreg_vld  (1'b0),  // ← VFPU 来源全部强制为 0！
  .vfpu_idu_ex4_pipe6_fwd_vreg_vld  (1'b0),
  .vfpu_idu_ex5_pipe6_fwd_vreg_vld  (1'b0),
  ...同样对 pipe7 也置 0
  .lsu_idu_da_pipe3_fwd_vreg_vld    (lsu_idu_da_pipe3_fwd_vreg_vld),  // LSU 来源正常
  .lsu_idu_wb_pipe3_fwd_vreg_vld    (lsu_idu_wb_pipe3_fwd_vreg_vld),
```

这是一处**显式的时序优化**：注释写明 `cannot fwd from vfpu to lsu srcvm`，说明 VFPU 结果前递到 LSU 管线的 srcvm 会产生过长的关键路径，因此设计者主动断开了这条前递路径。

代价是：若 LSU 向量操作的掩码寄存器依赖 VFPU 产出的结果，就不能通过前递获得，发射时需要等待 PRF 写回后才能读取（这由唤醒逻辑保证）。

---

## 7. 多端口优先级与互斥保证

### 7.1 为何采用 one-hot case 而非优先级编码

`fwd_preg` 和 `fwd_vreg` 都使用 `case` 语句以 one-hot 方式选择数据，而不是 `casex` 或优先级 MUX。这一设计的前提是：

> **在同一时刻，不可能有两个写回端口同时将结果写入同一物理寄存器。**

C910 通过 ROB（重排序缓冲）和物理寄存器重命名保证了这一点：每条指令在分配时拿到一个全局唯一的新物理寄存器号，直到它退休前该号不会被复用。因此不同执行单元同时在两条流水线中持有相同目的物理寄存器号是不可能发生的。

### 7.2 "最新值"问题

理论上，如果一个物理寄存器同时在 EX1 和 EX2 阶段都有有效信号（即同一条指令在 EX1 产出并流到 EX2），两路都会命中同一个 preg 号。但实际上，**前递源的 `vld` 信号会在正确的时刻使能**，EX1 和 EX2 的 vld 在时间上是互斥的：

- EX1 vld 在指令执行的第 1 个周期有效
- EX2/WB vld 在后续周期有效

由于 `rf_fwd` 是在 **RF 阶段**（同一个周期内的组合逻辑）运行的，且每条指令只在 RF 阶段运行一次，因此对于同一条指令的 RAW 依赖，在该周期内只会有一路 vld 有效。

### 7.3 default 分支的意义

```verilog
default: x_src_data = {64{1'bx}};
```

当 `fwd_src_sel` 全为 0（没有命中）时，`x_src_no_fwd = 1`，上层逻辑会选择从 PRF 读取的数据，而不使用 `x_src_data`。因此 `default` 输出 X 是合理的——它不会被实际使用，同时便于仿真发现意外命中。

---

## 8. 特殊前递逻辑：MLA/VMLA 与 CP0 禁用

### 8.1 pipe5 src0：MLA（乘累加）特殊前递

```verilog
// 行 1047-1051
assign fwd_dp_rf_pipe5_src0_no_fwd = fwd_dp_rf_pipe5_src0_no_fwd_raw
                                     && (!dp_fwd_rf_pipe1_mla
                                          || iu_idu_pipe1_mla_src2_no_fwd
                                          || cp0_idu_src2_fwd_disable);
assign fwd_dp_rf_pipe5_src0_no_fwd_expt_mla = fwd_dp_rf_pipe5_src0_no_fwd_raw;
```

pipe5 的 src0 在当前周期对应 pipe1 的 **src2（即 MLA 的累加操作数）**。正常情况下，如果 pipe1 执行的是 MLA（乘累加）指令，src2 的前递有特殊处理：

- `dp_fwd_rf_pipe1_mla = 1`：pipe1 当前是 MLA 指令
- `iu_idu_pipe1_mla_src2_no_fwd`：由 IU 内部前递判断的结果
- `cp0_idu_src2_fwd_disable`：CP0 控制位，可以禁用 src2 前递

当三个条件组合后，`no_fwd` 会被修改，用于通知 dp 是否需要等待 PRF 值。同时输出 `_expt_mla`（exclude MLA）版本，供不需要考虑 MLA 特殊情况的判断使用。

**为什么需要这个特殊逻辑？**

MLA 的 src2 是累加操作数，其生命周期跨越多拍，与普通 ALU 结果的前递时序不同，需要额外判断。

### 8.2 pipe6/pipe7 srcv2：VMLA 内部前递

```verilog
// 行 1500-1503：pipe6 srcv2
assign fwd_dp_rf_pipe6_srcv2_no_fwd = fwd_dp_rf_pipe6_srcv2_no_fwd_fr
                                      && (!dp_fwd_rf_pipe6_vmla
                                          || vfpu_idu_pipe6_vmla_srcv2_no_fwd
                                          || cp0_idu_srcv2_fwd_disable);

// 行 1916-1919：pipe7 srcv2（对称）
assign fwd_dp_rf_pipe7_srcv2_no_fwd = fwd_dp_rf_pipe7_srcv2_no_fwd_fr
                                      && (!dp_fwd_rf_pipe7_vmla
                                          || vfpu_idu_pipe7_vmla_srcv2_no_fwd
                                          || cp0_idu_srcv2_fwd_disable);
```

VMLA（向量乘累加）的 srcv2 是累加向量，其前递逻辑与 MLA 类似：

- `dp_fwd_rf_pipe6_vmla = 1`：pipe6 当前是 VMLA
- `vfpu_idu_pipe6_vmla_srcv2_no_fwd`：VFPU 内部判断 srcv2 是否无法前递
- `cp0_idu_srcv2_fwd_disable`：CP0 可禁用向量 srcv2 前递

**VMLA 内部前递的含义：** VFPU 的 pipe6/7 在执行 VMLA 时，EX 阶段内部已经对 srcv2 做了某种前递（即 VFPU 流水线内部的 bypass），`vfpu_idu_pipe6_vmla_srcv2_no_fwd` 反映了这个内部状态。IDU 的 rf_fwd 需要与之配合，避免双重前递或前递缺失。

### 8.3 pipe3/pipe4 srcvm：expt_vmla

```verilog
// 行 843：pipe3 srcvm
assign fwd_dp_rf_pipe3_srcvm_no_fwd_expt_vmla = fwd_dp_rf_pipe3_srcvm_no_fwd_vr0;

// 行 1010：pipe4 srcvm
assign fwd_dp_rf_pipe4_srcvm_no_fwd_expt_vmla = fwd_dp_rf_pipe4_srcvm_no_fwd_vr0;
```

`_expt_vmla` 后缀表示"不考虑 VMLA 特殊情况"的 no_fwd 信号，由调用方（dp）在需要区分 VMLA 和非 VMLA 场景时使用。由于 pipe3/pipe4 的 srcvm 的 VFPU 前递已经在例化时被强制清零，`fwd_dp_rf_pipe3_srcvm_no_fwd_vr0` 即反映纯 LSU 路径的前递状态。

---

## 9. 前递与唤醒的配合

### 9.1 唤醒（Wakeup）与前递的职责分工

| 机制 | 位置 | 职责 | 信号类型 |
|------|------|------|---------|
| 唤醒（Wakeup） | 发射队列（IQ） | 决定**何时**可以发射一条指令 | 广播目的寄存器号，IQ 比较后置就绪位 |
| 前递（Forwarding） | RF 阶段（rf_fwd） | 决定**操作数数据从哪里来** | 比较后选出旁路数据或标记需从 PRF 读取 |

这两个机制是**解耦的**，但需要协调：

- 唤醒逻辑可以在"预测"基础上提前唤醒（speculative wakeup），允许下一拍就发射
- 前递网络保证，当指令被发射并进入 RF 阶段时，数据确实可以从旁路获得

### 9.2 唤醒超前于前递的情况

以整数背靠背为例：

```
周期 N:   指令 A 进入 EX1
          → 同时唤醒信号广播：物理寄存器 Rp5 即将在 EX1 结束时就绪
          → 依赖 Rp5 的指令 B 在 IQ 中被标记就绪

周期 N+1: 指令 B 被调度发射，进入 RF 阶段
          → rf_fwd 中 fwd_preg 检测到 iu_ex1_pipe0_fwd_preg = Rp5，vld=1
          → fwd_src_sel[0] 命中，x_src_data = EX1 产出的数据
          → x_src_no_fwd = 0，B 用旁路数据而非 PRF 数据
```

如果唤醒了但前递没有命中（例如执行单元产生了异常取消了结果），前递会输出 `no_fwd=1`，dp 此时会从 PRF 读取数据，而 PRF 中可能还不是最新值——这种情况由刷新机制或保守唤醒策略处理。

### 9.3 no_fwd 信号的下游使用

rf_fwd 输出的 `fwd_dp_rf_pipe*_src*_no_fwd` 信号送回 dp 模块（`ct_idu_id_dp` 或 `ct_idu_rf_dp`），dp 根据该信号决定：

- `no_fwd = 0`：使用 `fwd_dp_rf_*_data`（前递数据）作为该操作数
- `no_fwd = 1`：使用从 PRF 读出的数据

这个多路选择器在 dp 模块中实现，不在 rf_fwd 中。rf_fwd 只负责**检测是否命中**并**输出旁路数据**。

---

## 10. 标量 vs 向量前递网络规模对比

### 10.1 规模数字对比

| 维度 | 标量 | 向量 |
|------|------|------|
| 前递单元类型 | fwd_preg | fwd_vreg |
| 前递路数 | 6（6-bit sel） | 8（8-bit sel） |
| 每源例化数量 | 1 个 | 3 个（fr/vr0/vr1） |
| 前递源来自 | IU(EX1/EX2) + LSU(DA/WB) | VFPU(EX3/4/5) + LSU(DA/WB) |
| 标量例化总数 | 11 | — |
| 向量例化总数 | — | ~34 |
| 数据宽度 | 64-bit | 64-bit×3=192-bit（三片合） |

### 10.2 向量网络更大的原因

1. **数据宽度更宽**：向量寄存器为 128-bit 数据（vr0+vr1），加上浮点分量 fr，需要 3 倍的 fwd_vreg 实例。
2. **前递路数更多**：VFPU 流水线深度为 5 拍（EX1~EX5），但前递只暴露 EX3/EX4/EX5 三点，标量 ALU 只有 2 拍（EX1/EX2），各提供 1 个前递点。因此向量多出 pipe6+pipe7 共 6 个前递点（取代标量的 4 个整数前递点）。
3. **操作数数量更多**：向量指令常有 srcv0/srcv1/srcv2/srcvm 四个源操作数，标量只有 src0/src1 两个。

### 10.3 面积与时序分析

| 方面 | 影响 |
|------|------|
| 面积 | ~45 个前递单元，每单元含 6/8 路比较器和 64-bit MUX，总面积可观但均为组合逻辑 |
| 关键路径 | 物理寄存器号 7-bit 比较 → OR/case 选择 → 64-bit 数据输出；通常 2~3 FO4 |
| 时序优化 | pipe3/pipe4 srcvm 的 VFPU 路径被截断（`vld = 1'b0`），避免跨域长路径 |

---

## 附录：关键信号速查表

### 输入信号

| 信号 | 宽度 | 含义 |
|------|------|------|
| `dp_fwd_rf_pipe{0-5}_src{0-1}_preg` | 7-bit | dp 发送的待查源物理寄存器号（标量） |
| `dp_fwd_rf_pipe{5-7}_srcv{0-2}_vreg` | 7-bit | dp 发送的待查源物理寄存器号（向量） |
| `dp_fwd_rf_pipe{6-7}_srcvm_vreg` | 7-bit | dp 发送的向量掩码源寄存器号 |
| `iu_idu_ex1_pipe{0-1}_fwd_preg` | 7-bit | 整数管线 EX1 产出的目的物理寄存器号 |
| `iu_idu_ex1_pipe{0-1}_fwd_preg_vld` | 1-bit | EX1 前递有效 |
| `iu_idu_ex1_pipe{0-1}_fwd_preg_data` | 64-bit | EX1 产出的数据 |
| `iu_idu_ex2_pipe{0-1}_wb_preg` | 7-bit | 整数管线 EX2/WB 写回物理寄存器号 |
| `lsu_idu_da_pipe3_fwd_preg` | 7-bit | LSU DA 阶段标量前递寄存器号 |
| `lsu_idu_wb_pipe3_wb_preg` | 7-bit | LSU WB 阶段标量写回寄存器号 |
| `lsu_idu_da_pipe3_fwd_vreg` | 7-bit | LSU DA 阶段向量前递寄存器号 |
| `vfpu_idu_ex{3-5}_pipe{6-7}_fwd_vreg` | 7-bit | VFPU 各阶段向量前递寄存器号 |
| `dp_fwd_rf_pipe1_mla` | 1-bit | pipe1 当前为 MLA 指令标志 |
| `dp_fwd_rf_pipe{6-7}_vmla` | 1-bit | pipe6/7 当前为 VMLA 指令标志 |
| `cp0_idu_src2_fwd_disable` | 1-bit | CP0 禁用标量 src2 前递 |
| `cp0_idu_srcv2_fwd_disable` | 1-bit | CP0 禁用向量 srcv2 前递 |

### 输出信号

| 信号 | 宽度 | 含义 |
|------|------|------|
| `fwd_dp_rf_pipe{0-5}_src{0-1}_data` | 64-bit | 标量前递数据输出 |
| `fwd_dp_rf_pipe{0-5}_src{0-1}_no_fwd` | 1-bit | =1 无前递命中，用 PRF 数据 |
| `fwd_dp_rf_pipe{5-7}_srcv{0-2}_vreg_{fr/vr0/vr1}_data` | 64-bit | 向量前递数据各分片 |
| `fwd_dp_rf_pipe{5-7}_srcv{0-2}_no_fwd` | 1-bit | 向量无前递命中 |
| `fwd_dp_rf_pipe{6-7}_srcvm_vreg_{vr0/vr1}_data` | 64-bit | 向量掩码前递数据 |
| `fwd_dp_rf_pipe{3-4}_srcvm_no_fwd_expt_vmla` | 1-bit | 掩码源无前递（排除 VMLA） |
| `fwd_dp_rf_pipe5_src0_no_fwd_expt_mla` | 1-bit | src0 无前递（排除 MLA） |
| `iu_idu_pipe1_mla_src2_no_fwd` | 1-bit | IU 内部 MLA src2 前递判断（直通） |

---

## 小结

`ct_idu_rf_fwd` 是 C910 IDU 中消除 RAW 写后读依赖停顿、实现背靠背执行的核心组件。其设计要点如下：

1. **标准化的单元化结构**：`fwd_preg`/`fwd_vreg` 是两类完全复用的叶子单元，每个单元只做一件事——判断一个源寄存器号是否命中某条写回路径并选出数据。

2. **全覆盖的前递矩阵**：顶层 rf_fwd 通过 ~45 个例化，将所有管线（pipe0~7）的所有源（src0/src1/srcv0/srcv1/srcv2/srcvm）与所有写回端口（6路标量/8路向量）之间的前递关系全部覆盖，形成一张完整的前递网络。

3. **one-hot 设计保证互斥**：依托物理寄存器重命名机制，同一周期内不会有两路同时命中同一物理寄存器，因此可以安全使用 one-hot case，同时降低了关键路径延迟。

4. **时序敏感的路径截断**：pipe3/pipe4 的 srcvm 主动断开了 VFPU 到 LSU 的前递路径（时序过长），体现了功能正确性与时序约束之间的工程折衷。

5. **MLA/VMLA 特殊前递**：乘累加指令的累加源有单独的前递判断逻辑，允许 VFPU/IU 内部前递与 IDU 前递协同工作，对外提供普通版本和 expt 版本两种 no_fwd 信号。
