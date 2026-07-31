# C910 IDU 前递网络 rf_fwd 详解

## 目录

1. [模块概述：前递的原理与必要性](#1-模块概述前递的原理与必要性)
2. [前递的时序原理](#2-前递的时序原理)
3. [前递单元 fwd_preg：标量寄存器前递](#3-前递单元-fwd_preg标量寄存器前递)
4. [前递单元 fwd_vreg：向量寄存器前递](#4-前递单元-fwd_vreg向量寄存器前递)
5. [前递网络全景：rf_fwd 的例化结构](#5-前递网络全景rf_fwd-的例化结构)
6. [各管线的前递源分析](#6-各管线的前递源分析)
7. [多端口 one-hot 协议与违例表现](#7-多端口-one-hot-协议与违例表现)
8. [特殊前递逻辑：MLA/VMLA 与 CP0 禁用](#8-特殊前递逻辑mlavmla-与-cp0-禁用)
9. [前递与唤醒的配合](#9-前递与唤醒的配合)
10. [标量 vs 向量前递网络规模对比](#10-标量-vs-向量前递网络规模对比)

---

## 1. 模块概述：前递的原理与必要性

### 1.1 RAW 真依赖问题

在乱序超标量处理器中，发射队列（Issue Queue）会将满足选择条件的指令调度到各功能管线执行。这里的“源就绪”不只表示数据已经写入物理寄存器文件（PRF），还可能表示调度器根据生产者阶段判断：数据将在消费者需要它的时刻通过旁路到达。前一种是已写回就绪，后一种是推测或旁路就绪；`rf_fwd` 负责消费者进入 RF 数据选择路径后，判断当前连接的旁路源是否真正命中。

若只把“已经写回 PRF”作为源就绪条件，那么依赖 A 的指令 B 即使能在执行旁路上及时拿到结果，也仍会等到 A 写回后才发射。C910 的 dep 唤醒和 `rf_fwd` 前递共同用于避免这类过度保守的等待。

**前递（Forwarding / Bypass）** 解决的正是这个问题：

> 当指令 B 在 RF 阶段读取其源操作数时，如果此时某条执行单元恰好产出了与 B 的源物理寄存器号相同的目标寄存器的最新值，就直接将执行单元输出的数据旁路（Bypass）到 B 的操作数输入，而无需等待那个值写回 PRF 再读出。

### 1.2 C910 的背靠背执行

C910 是一颗乱序 4 发射处理器，在理想情况下，相邻两条存在 RAW 依赖的整数指令可以**背靠背执行（back-to-back）**，即：

- 周期 N：指令 A 进入 EX1 执行，产出结果
- 周期 N：指令 B 在 RF 阶段读操作数，此时通过前递网络拿到 A 在 EX1 产出的结果

这样 A 的结果不必先写回 PRF、再由 B 读出。具体缩短多少周期取决于生产者类型、可用的前递阶段、消费者的发射时刻以及是否发生取消，不能由这个组合模块单独概括成固定的 1 个或若干个周期。

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

`ct_idu_rf_fwd` 是 RF 阶段操作数选择的一部分：对顶层为各 pipe、各源显式例化的查询通道，并行比较源物理寄存器号与该叶子单元所连接的前递候选。它输出“是否命中”以及命中数据；最终选择 PRF 数据还是前递数据的多路器位于下游 RF 数据通路。这里的“全部”只能理解为 RTL 明确接入该叶子单元的候选，不能外推为任意执行阶段都存在旁路。

---

## 2. 前递的时序原理

### 2.1 各执行单元的前递点

C910 存在多条功能管线，每条管线有各自的执行延迟。rf_fwd 汇聚了这些管线在**不同执行阶段**的输出，作为前递候选：

| 信号前缀 | 来源单元 | 管线号 | 阶段 | 时序含义 |
|---|---|---|---|---|
| `iu_idu_ex1_pipe0_fwd_preg` | IU（整数单元） | pipe0 | EX1 | EX1 前递候选；是否有效由同名 `vld` 决定 |
| `iu_idu_ex2_pipe0_wb_preg` | IU | pipe0 | EX2/WB | EX2/WB 候选；接口名不单独证明某类 ALU 固定两拍 |
| `iu_idu_ex1_pipe1_fwd_preg` | IU | pipe1 | EX1 | pipe1 的 EX1 候选 |
| `iu_idu_ex2_pipe1_wb_preg` | IU | pipe1 | EX2/WB | |
| `lsu_idu_da_pipe3_fwd_preg` | LSU（访存单元） | pipe3 | DA | LSU 在 DA 接口声明可前递的标量结果；仅由信号名不能进一步断言数据一定直接来自 D-cache |
| `lsu_idu_wb_pipe3_wb_preg` | LSU | pipe3 | WB | LSU WB 接口的写回候选 |
| `vfpu_idu_ex3_pipe6_fwd_vreg` | VFPU（向量浮点） | pipe6 | EX3 | pipe6 EX3 候选 |
| `vfpu_idu_ex4_pipe6_fwd_vreg` | VFPU | pipe6 | EX4 | |
| `vfpu_idu_ex5_pipe6_fwd_vreg` | VFPU | pipe6 | EX5 | pipe6 EX5 候选 |
| `vfpu_idu_ex3_pipe7_fwd_vreg` | VFPU | pipe7 | EX3 | |
| `vfpu_idu_ex4_pipe7_fwd_vreg` | VFPU | pipe7 | EX4 | |
| `vfpu_idu_ex5_pipe7_fwd_vreg` | VFPU | pipe7 | EX5 | |

### 2.2 前递时序示意

以下是 `fwd_src_sel[0]` 命中的一种理想化背靠背关系。它是接口关系示意，不是对所有 ALU 指令、stall/flush 场景都成立的固定周期表：

```
周期:      T      T+1     T+2     T+3
           |------|-------|-------|-------|
指令A:     [RF]   [EX1]  [EX2]  [WB→PRF]
                   ↑产出结果
指令B:             [RF]         ← rf_fwd 在此时从 EX1 前递拿到 A 的结果
                   ↓ 通过 fwd_src_sel[0] 前递 data
                   [EX1]  [EX2]  ...
```

`fwd_src_sel[0]` 命中时，B 的候选操作数来自 pipe0 EX1 数据。若观察时刻改为 EX2/WB 候选有效且目的号匹配，则 `fwd_src_sel[1]` 命中。不能仅用“A、B 相差两个周期”决定选择位，因为 stall、replay 和不同操作类型都会改变有效窗口。

对于 LSU pipe3，网络接入 DA 前递接口和 WB 接口两个候选点（`da_pipe3_fwd` 与 `wb_pipe3_wb`）。DA 候选有效的精确条件由 LSU 产生的 `*_vld` 决定；`rf_fwd` 本身既不判断 cache hit/miss，也不判断数据来自 cache、store forwarding 还是其他 LSU 内部路径。

对于 VFPU（pipe6/7），前递网络接收 EX3/EX4/EX5 三组前递接口。多个接口用于覆盖
不同执行类型和流水时刻，不能反推所有向量/浮点指令都具有固定五拍延迟。

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

比较对象是 7 位物理寄存器号，而不是 5 位架构寄存器号。寄存器重命名消除了以架构寄存器名为基础的 WAR/WAW 假依赖；但“本叶子单元同拍至多命中一路”仍是跨模块协议条件，还依赖物理目的寄存器在安全释放前不被重新分配、各生产者阶段的 `vld` 互斥关系正确，以及取消/刷新及时撤销无效结果。`ct_idu_rf_fwd_preg` 只做比较和选择，不在本地检查这些条件。

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
    default  : x_src_data[63:0] = {64{1'bx}};                           // 全零或非 one-hot
  endcase
end
```

关键设计要点：
- **case 使用 one-hot 编码，而非优先级编码**。叶子单元假定 `fwd_src_sel` 为全零或 one-hot；它不会在多路命中时替调用者决定哪一路更新。
- 全零是正常的“无前递”状态：此时 `x_src_no_fwd=1`，下游应使用 PRF 数据。多位为 1 是协议违例：此时 `x_src_no_fwd=0`，但 `x_src_data` 落入 `default` 并成为 X，便于 RTL 仿真暴露错误。因而不能把 `default` 只解释成“无命中 don't care”。
- 该叶子单元内部没有寄存器，比较和 64 位数据选择在同一组合周期传播；这不等于物理延迟为零。`源号比较 → 命中向量 → 数据 MUX → 下游锁存` 仍可能是 RF 级的重要时序路径，实际裕量必须看综合/STA。

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

向量前递叶子接入 **8 路**候选，标量叶子接入 6 路。8 路由 pipe6/7 各三个 VFPU 阶段接口以及 LSU 的 DA/WB 两个接口组成；这个接口计数描述网络拓扑，不能单凭 `EX3/EX4/EX5` 名称推导某类指令的固定执行延迟。

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

这里同样采用全零或 one-hot 的接口协议。RTL 不含优先级编码或多命中仲裁；若多个有效候选同时携带同一 `vreg`，数据输出会走 `default` 变为 X。

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

从本文件的连接关系看，`fwd_vreg` 叶子一次只处理一个 64 位分片；顶层按具体源的需要分别连接 `fr`、`vr0`、`vr1`。`vr0/vr1` 可组合成保留向量通路的两个 64 位部分，`fr` 是浮点寄存器分片。分片化缩短单个叶子的总线宽度是可以从 RTL 确认的结构事实；“这样做是为了节省多少布线面积”属于实现动机推断，需布局布线或设计说明才能定量确认。

还要区分**保留结构**与**当前可执行 ISA**：当前 RTL 中 `ct_idu_id_decd.v` 将 `x_vec_inst` 固定为 `1'b0`，`ct_cp0_regs.v` 将 `misa_vector` 固定为 `1'b0`。因此这些 `vreg`/VMLA 通路说明的是源码保留的向量微结构接口，不能写成当前配置已经对软件开放 RVV；标量浮点 F/D 相关的 `fr` 通路不应因此一并视为关闭。

---

## 5. 前递网络全景：rf_fwd 的例化结构

### 5.1 顶层模块概览

文件：`ct_idu_rf_fwd.v`（1999 行）

`rf_fwd` 的主体由 `fwd_preg`/`fwd_vreg` 叶子实例构成，顶层除连线外还包含 MLA/VMLA `no_fwd` 修正等少量组合逻辑。其职责可分为：

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

按实际模块例化语句计数，共 **29 个** `fwd_vreg` 实例。不是每个源都同时具有 `fr/vr0/vr1` 三片，例如 `srcvm` 只连接 `vr0/vr1`。

与 11 个 `fwd_preg` 相加，顶层共有 **40 个**前递叶子实例。

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

11 个标量前递叶子都接入**同一组 6 路候选**（pipe0/pipe1 各 EX1、EX2/WB，pipe3 DA、WB）。这些候选不全是“最终写回源”：EX1 和 DA 是前递接口，EX2/WB 与 LSU WB 是较后阶段接口。叶子结构相同，区别在于被查询的 `x_src_reg` 以及各自输出连接。

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

**为什么每个标量查询源都接入这 6 路候选？**

因为消费者被发往哪条 pipe，不决定它的生产者来自哪条 pipe；例如 pipe0 的 src0 可能依赖 pipe1 或 LSU。这里的 6 路是本 RTL 为标量叶子统一连接的候选集合，不应扩写为处理器中“所有可能执行阶段”。

### 6.2 标量前递源总结

| 前递点索引 | 信号来源 | 执行单元 | 阶段 | 特点 |
|-----------|---------|---------|------|------|
| sel[0] | iu pipe0 | 整数单元 | EX1 | EX1 `vld` 且目的号匹配 |
| sel[1] | iu pipe0 | 整数单元 | EX2/WB | EX2/WB `vld` 且目的号匹配 |
| sel[2] | iu pipe1 | 整数单元 | EX1 | EX1 `vld` 且目的号匹配 |
| sel[3] | iu pipe1 | 整数单元 | EX2/WB | EX2/WB `vld` 且目的号匹配 |
| sel[4] | lsu pipe3 | LSU | DA | DA forward `vld` 且目的号匹配；不等价于本地判定 L1 hit |
| sel[5] | lsu pipe3 | LSU | WB | WB `vld` 且目的号匹配 |

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

这是 RTL 注释标为 `timing optimization` 的显式路径裁剪：pipe3/pipe4 `srcvm` 实例把 VFPU 前递有效位接为 0，因此这些叶子只可能命中 LSU 来源。可以确定的是“VFPU→LSU srcvm 不在该前递矩阵中”；是否因为哪一段具体连线“过长”、减少了多少延迟，仍需 STA 路径报告支持。

直接后果是：这些 `srcvm` 叶子不能从 VFPU 候选得到数据。相关指令何时可发射、是否必须等到 PRF 写回，以及是否存在其他专用路径，要结合 dep 就绪逻辑和下游数据选择确认；`rf_fwd` 叶子本身不提供“最终一定等待到正确值”的控制保证。

---

## 7. 多端口 one-hot 协议与违例表现

### 7.1 为何采用 one-hot case 而非优先级编码

`fwd_preg` 和 `fwd_vreg` 都使用 `case` 语句以 one-hot 方式选择数据，而不是 `casex` 或优先级 MUX。这一设计的前提是：

> **前递叶子要求：对同一个被查询物理寄存器，同一组合采样时刻的候选命中向量必须是全零或 one-hot。**

重命名和物理寄存器生命周期管理是满足该条件的重要基础：不同有效目的通常不会同时拥有同一个仍在使用的物理寄存器号。但 one-hot 还依赖执行流水级 `vld` 的定义、结果取消以及物理寄存器释放/复用时点。这个叶子模块没有 assertion、仲裁器或优先级 MUX 来独立证明条件成立，因此文档应把它称为**上游必须维持的协议不变量**，而不是本模块自行实现的保证。

### 7.2 "最新值"问题

若同一生产者对应的 EX1 前递有效与后续 EX2/WB 有效在同一采样时刻重叠，且两者携带同一目的号，叶子会看到多命中。设计期望各阶段 `vld` 的窗口以及流水级推进关系避免这种重叠：

- EX1 vld 在指令执行的第 1 个周期有效
- EX2/WB vld 在后续周期有效

上述两条是按接口命名得到的阶段关系说明，不是 `rf_fwd` 内部的互斥逻辑。消费者是否只经过一次 RF 级也不能反向证明生产者候选互斥；可靠核查方法是在波形或 assertion 中验证 `$onehot0(fwd_src_sel)`，并同时观察 flush/cancel 与各候选 `vld`。

### 7.3 default 分支的意义

```verilog
default: x_src_data = {64{1'bx}};
```

当 `fwd_src_sel` 全为 0 时，`x_src_no_fwd=1`，正常下游选择 PRF 数据而不使用 `x_src_data`。当选择向量多位为 1 时，`x_src_no_fwd=0`，但数据仍为 X；这使协议违例更容易传播并在仿真中暴露。因而 `default` 同时覆盖“正常无命中”和“异常多命中”，分析 X 时必须结合选择向量区分。

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

- 唤醒逻辑可以根据生产者阶段形成投机或快速就绪，使消费者更早进入候选集合；是否同拍或下一拍发射取决于具体队列
- 前递网络在候选 `vld` 和目的号匹配时给出旁路数据；调度与取消协议必须保证消费者真正需要数据时存在合法来源

### 9.2 唤醒超前于前递的情况

以下只表达“唤醒资格必须与数据前递窗口对齐”，不把它固定成某两个绝对周期：

```
调度观察窗口：
  A 的目的 preg = Rp5
  对应队列 entry/source 的快速 ready 条件成立
    -> B 可进入 ready/仲裁集合

RF 前递观察窗口：
  B 的源 preg = Rp5
  某个候选 vld = 1 且候选目的 preg = Rp5
    -> 对应 fwd_src_sel 单 bit 命中
    -> x_src_no_fwd = 0
    -> 下游选择该候选数据

若两组窗口没有按流水线协议对齐：
  上游必须阻止错误 issue、清除投机 ready，或执行 flush/replay
```

如果消费者已被投机唤醒，但 RF 观察窗口没有合法前递命中，`no_fwd=1` 只会使数据通路选择 PRF 候选；它不会自行判断 PRF 中的数据是否已更新。正确性依赖上游在投机条件失效时阻止发射、清除 ready 或 flush/replay。因而分析波形时必须同时看队列 issue、ready clear、flush/cancel、PRF 写回和 `no_fwd`，不能把 `no_fwd` 当作恢复机制。

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
| 向量例化总数 | — | 29 |
| 数据宽度 | 64-bit | 64-bit×3=192-bit（三片合） |

### 10.2 向量网络更大的原因

1. **数据宽度更宽**：向量寄存器为 128-bit 数据（vr0+vr1），加上浮点分量 fr，需要 3 倍的 fwd_vreg 实例。
2. **前递路数更多**：VFPU 每条 pipe 暴露 EX3/EX4/EX5 三个前递接口，标量侧则接收 IU 与 LSU 的若干前递/写回接口。路数差异反映了生产者类型和可用窗口不同，不等价于所有指令共享固定流水深度。
3. **操作数数量更多**：向量指令常有 srcv0/srcv1/srcv2/srcvm 四个源操作数，标量只有 src0/src1 两个。

### 10.3 面积与时序分析

| 方面 | 影响 |
|------|------|
| 面积 | 40 个前递叶子实例；每个含 6 路或 8 路比较和 64 位选择逻辑。具体门数、共享优化及占比需综合报告确认 |
| 关键路径 | 物理寄存器号比较 → 命中向量 → 数据选择；实际 FO4/时延必须由综合时序报告确认 |
| 时序优化 | pipe3/pipe4 `srcvm` 的 VFPU 有效输入被固定为 0；RTL 注释将其标为 timing optimization，但具体关键路径收益需 STA 确认 |

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

2. **显式例化的前递矩阵**：顶层通过 11 个标量叶子和 29 个向量/浮点分片叶子，为各 pipe 的已连接源建立比较网络。它覆盖的是源码明确列出的连接，并非任意 pipe、任意源到任意生产者的全交叉矩阵。

3. **one-hot 协议而非本地仲裁**：叶子假定选择向量为全零或 one-hot。重命名是维持该不变量的基础之一，执行阶段有效窗口、取消和寄存器复用协议同样必须正确；是否比优先级结构更快需综合结果确认。

4. **时序敏感的路径裁剪**：pipe3/pipe4 的 `srcvm` 实例不接收 VFPU 有效候选。源码明确把它标为 timing optimization；因此相关消费者必须依赖其他就绪/写回路径，不能假定存在 VFPU→LSU 掩码源直接旁路。

5. **MLA/VMLA 特殊前递**：乘累加指令的累加源有单独的前递判断逻辑，允许 VFPU/IU 内部前递与 IDU 前递协同工作，对外提供普通版本和 expt 版本两种 no_fwd 信号。
