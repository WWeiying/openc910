# C910 IDU — `ct_idu_id_dp` 模块详解

> RTL 文件：`C910_RTL_FACTORY/gen_rtl/idu/rtl/ct_idu_id_dp.v`（1773 行）
>
> 本文档对全部逻辑逐块讲解，包含体系结构原理、关键信号位域定义、子模块关系，以及向下游 IR 阶段输出数据的完整组织过程。

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与位域定义](#3-参数与位域定义)
4. [子模块实例化全景](#4-子模块实例化全景)
5. [指令数据的接收与流水线寄存器](#5-指令数据的接收与流水线寄存器)
6. [指令类型判断与控制路径反馈](#6-指令类型判断与控制路径反馈)
7. [译码结果的组织（Normal Data Path）](#7-译码结果的组织normal-data-path)
8. [异常数据通路（Expt Data Path）](#8-异常数据通路expt-data-path)
9. [Split Long 数据通路](#9-split-long-数据通路)
10. [Split Short 数据通路（×3）](#10-split-short-数据通路3)
11. [Fence 数据通路](#11-fence-数据通路)
12. [pipedown 数据选择（MUX 到 IR）](#12-pipedown-数据选择mux-到-ir)
13. [相关性信息（dep_info）打包](#13-相关性信息dep_info打包)
14. [调试与 HAD 接口](#14-调试与-had-接口)
15. [完整数据流总结](#15-完整数据流总结)

---

## 1. 模块概述

### 1.1 在流水线中的位置

```
IFU
 │  ifu_idu_ib_inst{0,1,2}_data[72:0]（73 位宽，含 PC、指令编码、向量状态）
 ▼
IBUF（指令缓冲）
 │
 ▼
┌────────────────────────────────────────────────┐
│              ct_idu_id_dp                      │  ← 本模块（ID 阶段数据通路）
│  ┌────────────┐  ┌──────────────┐              │
│  │ id_decd ×3 │  │ id_split_long│              │
│  └────────────┘  ├──────────────┤              │
│                  │id_split_short│              │
│                  │  ×3          │              │
│                  └──────────────┘              │
│        ↕ 控制信号双向                           │
│              ct_idu_id_ctrl                    │
└────────────────────────────────────────────────┘
 │  dp_id_pipedown_inst{0,1,2,3}_data[177:0]（4 条微操 178 位宽）
 ▼
IR 阶段（重命名 / 发射）
```

### 1.2 职责划分：数据通路 vs 控制通路

C910 IDU 严格将 ID 阶段的**数据通路**与**控制通路**分开实现：

| 模块 | 职责 |
|------|------|
| `ct_idu_id_dp`（本模块） | 接收指令、驱动译码器、拼接/选择微操数据，向 IR 输出 178 位宽指令包 |
| `ct_idu_id_ctrl` | 决定哪些指令有效、是否 stall、是否 pipedown，生成控制信号反馈给 dp |

这种分离使时序路径清晰，避免控制逻辑与数据拼接逻辑相互影响，也便于综合工具单独优化每条路径。

### 1.3 三发射与拆分机制

C910 是三发射超标量处理器，ID 阶段同时处理最多 **3 条原始指令**（inst0/1/2）。但某些 RISC-V 指令在流水线中需要被**拆分为多条微操作（µop）**：

- **split_short**：一条原始指令拆分为 **2 条** µop（同周期完成拆分，纯组合逻辑）
- **split_long**：一条原始指令（inst0）拆分为最多 **4 条** µop（需要多个周期，含状态机）

拆分后，IR 阶段仍维持 4 个槽位（inst0～inst3），供重命名使用。`ct_idu_id_dp` 的核心任务之一就是**将各来源的 µop 正确地填入这 4 个槽位**。

---

## 2. 端口说明

### 2.1 来自上游 / 配置的输入

| 端口 | 宽度 | 来源 | 说明 |
|------|------|------|------|
| `ifu_idu_ib_inst{0,1,2}_data` | 73 | IBUF | 三条原始指令数据（73 位宽，含 PC、opcode、向量 CSR 快照等） |
| `ifu_idu_ib_pipedown_gateclk` | 1 | IBUF | 指令即将 pipedown，驱动门控时钟使能 |
| `fence_dp_inst{0,1,2}_data` | 178 | fence 模块 | fence 型指令展开后的微操数据 |
| `cp0_idu_cskyee` | 1 | CP0 | 玄铁扩展指令使能 |
| `cp0_idu_frm` | 3 | CP0 | 浮点舍入模式 |
| `cp0_idu_fs` | 2 | CP0 | 浮点寄存器状态位 |
| `cp0_idu_vill` | 1 | CP0 | 向量非法标志 |
| `cp0_idu_vs` | 2 | CP0 | 向量寄存器状态位 |
| `cp0_idu_vstart` | 7 | CP0 | 向量起始元素索引 |
| `cp0_idu_zero_delay_move_disable` | 1 | CP0 | 禁止零延迟 move 优化 |
| `cp0_yy_hyper` | 1 | CP0 | Hypervisor 模式 |

### 2.2 来自控制路径的输入

| 端口 | 宽度 | 说明 |
|------|------|------|
| `ctrl_dp_id_inst{0,1,2}_vld` | 1×3 | 三条指令各自是否有效（控制异常检测） |
| `ctrl_dp_id_pipedown_1_inst` | 1 | 本周期仅 1 条指令 pipedown（inst0 → 来自寄存器 id_inst1） |
| `ctrl_dp_id_pipedown_2_inst` | 1 | 本周期 2 条指令 pipedown（inst0/1 → 来自 id_inst2/ib_inst0） |
| `ctrl_dp_id_pipedown_3_inst` | 1 | 本周期 3 条指令 pipedown（使用 ib 新数据） |
| `ctrl_dp_id_stall` | 1 | ID 阶段 stall，不更新流水线寄存器 |
| `ctrl_dp_id_debug_id_pipedown3` | 1 | 调试通路：捕获 pipedown 时刻 |
| `ctrl_split_long_id_inst_vld` | 1 | 传递给 split_long 子模块，指示其当前有效指令 |
| `ctrl_split_long_id_stall` | 1 | 传递给 split_long 子模块，stall 信号 |

### 2.3 向控制路径的输出

| 端口 | 宽度 | 说明 |
|------|------|------|
| `dp_ctrl_id_inst{0,1,2}_normal` | 1×3 | 各指令是否为普通指令（非 fence/split） |
| `dp_ctrl_id_inst{0,1,2}_fence` | 1×3 | 各指令是否为 fence 型 |
| `dp_ctrl_id_inst{0,1,2}_split_short` | 1×3 | 各指令是否为 split_short 型 |
| `dp_ctrl_id_inst{0,1,2}_split_long` | 1×3 | 各指令是否为 split_long 型 |
| `split_long_ctrl_id_stall` | 1 | split_long 模块向控制路径反馈是否需要 stall |
| `split_long_ctrl_inst_vld` | 4 | split_long 输出各条微操的有效性 |

### 2.4 向 IR 阶段的输出

| 端口 | 宽度 | 说明 |
|------|------|------|
| `dp_id_pipedown_inst{0,1,2,3}_data` | 178×4 | 四个 IR 槽位的完整指令数据 |
| `dp_id_pipedown_dep_info` | 17 | 四条微操之间的相关性掩码向量 |

### 2.5 向 Fence 模块的输出

| 端口 | 宽度 | 说明 |
|------|------|------|
| `dp_fence_id_inst` | 32 | inst0 的原始指令编码 |
| `dp_fence_id_fence_type` | 3 | fence 类型（来自 id_decd0 译码结果） |
| `dp_fence_id_pc` | 15 | inst0 的 PC |
| `dp_fence_id_vl/vlmul/vsew` | 8/2/3 | 向量执行状态快照 |
| `dp_fence_id_bkpta/bkptb_inst` | 1×2 | 断点标志 |

---

## 3. 参数与位域定义

### 3.1 ID 阶段数据格式（73 位宽，来自 IBUF）

```
参数名            位域   含义
ID_VL_PRED  = 72  [72]   向量长度预测有效
ID_VL       = 71  [71:64] 向量长度 vl（8 位）
ID_PC       = 63  [63:49] PC[15:1]（15 位，字节对齐后右移 1 位）
ID_VSEW     = 48  [48:46] 向量元素宽度 vsew（3 位）
ID_VLMUL    = 45  [45:44] 向量 LMUL（2 位）
ID_NO_SPEC  = 43  [43]    不可推测执行标志
ID_BKPTA_INST=42  [42]    断点 A 命中
ID_BKPTB_INST=41  [41]    断点 B 命中
ID_SPLIT_SHORT=40 [40]    需 split_short 处理
ID_FENCE    = 39  [39]    fence 型指令
ID_SPLIT_LONG=38  [38]    需 split_long 处理
ID_HIGH_HW_EXPT=37[37]    高优先级硬件异常
ID_EXPT_VEC = 36  [36:33] 异常向量号（4 位）
ID_EXPT_VLD = 32  [32]    IFU 阶段异常有效
ID_OPCODE   = 31  [31:0]  32 位指令编码
```

> **设计原因**：IBUF 向 IDU 传递的不仅是原始指令编码，还附带了 IFU 阶段已检测到的异常信息（取指异常）和向量状态快照（避免每次读 CSR）。这种"将上下文随数据一起传递"的设计是高性能处理器的常见手法，减少了 ID 阶段对 CSR 堆的直接依赖。

### 3.2 IR 阶段数据格式（178 位宽，向下游传递）

```
参数名              位域    含义
IR_VL_PRED  =177   [177]   向量长度预测
IR_VL       =176   [176:169] 向量长度（8 位）
IR_VMB      =168   [168]   向量掩码位
IR_PC       =167   [167:153] PC（15 位）
IR_VSEW     =152   [152:150] vsew
IR_VLMUL    =149   [149:148] vlmul
IR_FMLA     =147   [147]   浮点乘加指令标志
IR_SPLIT_NUM=146   [146:140] split 序号（7 位）
IR_NO_SPEC  =139   [139]   不可推测执行
IR_MLA      =138   [138]   整数乘加标志
IR_DST_X0   =137   [137]   目的寄存器为 x0
IR_ILLEGAL  =136   [136]   非法指令
IR_SPLIT_LAST=135  [135]   split 序列最后一条
IR_VMLA     =134   [134]   向量乘加标志
IR_IID_PLUS =133   [133:130] 指令 ID 加法偏移
IR_BKPTB_INST=129  [129]   断点 B
IR_BKPTA_INST=128  [128]   断点 A
IR_FMOV     =127   [127]   浮点 MOV 指令
IR_MOV      =126   [126]   整数 MOV 指令（用于零延迟 move 优化）
IR_EXPT     =125   [125:119] 异常信息（高优先级标志+向量号+有效位）
IR_LENGTH   =118   [118]   指令长度（16/32 位）
IR_INTMASK  =117   [117]   中断屏蔽
IR_SPLIT    =116   [116]   split 指令标志
IR_INST_TYPE=115   [115:106] 10 位独热执行单元类型
IR_DSTV_REG =105   [105:100] 向量目的寄存器（6 位）
IR_DSTV_VLD = 99   [99]    向量目的有效
IR_SRCVM_VLD= 98   [98]    向量掩码源有效
IR_SRCV2_VLD= 97   [97]    向量源 2 有效
IR_SRCV1_REG= 96   [96:91] 向量源 1 寄存器
IR_SRCV1_VLD= 90   [90]    向量源 1 有效
IR_SRCV0_REG= 89   [89:84] 向量源 0 寄存器
IR_SRCV0_VLD= 83   [83]    向量源 0 有效
IR_DSTE_VLD = 82   [82]    扩展目的寄存器有效
IR_DSTF_REG = 81   [81:76] 浮点目的寄存器（6 位）
IR_DSTF_VLD = 75   [75]    浮点目的有效
IR_SRCF2_REG= 74   [74:69] 浮点源 2 寄存器
IR_SRCF2_VLD= 68   [68]    浮点源 2 有效
IR_SRCF1_REG= 67   [67:62] 浮点源 1 寄存器
IR_SRCF1_VLD= 61   [61]    浮点源 1 有效
IR_SRCF0_REG= 60   [60:55] 浮点源 0 寄存器
IR_SRCF0_VLD= 54   [54]    浮点源 0 有效
IR_DST_REG  = 53   [53:48] 整数目的寄存器（6 位）
IR_DST_VLD  = 47   [47]    整数目的有效
IR_SRC2_VLD = 46   [46]    整数源 2 有效（立即数标志）
IR_SRC1_REG = 45   [45:40] 整数源 1 寄存器
IR_SRC1_VLD = 39   [39]    整数源 1 有效
IR_SRC0_REG = 38   [38:33] 整数源 0 寄存器
IR_SRC0_VLD = 32   [32]    整数源 0 有效
IR_OPCODE   = 31   [31:0]  32 位原始指令编码
```

> **从 73 位扩展到 178 位的原因**：ID 阶段的译码器（id_decd）对原始指令进行完整分析，产生大量控制字段（寄存器号、有效位、执行单元类型、特殊指令标志等）。这些字段在 IR 阶段（重命名）及后续执行阶段都需要用到，因此全部打包进一个宽总线，避免后续阶段重复逻辑。178 位的宽度是 C910 整个后端数据通路的标准"指令包"宽度。

### 3.3 相关性信息格式（17 位宽）

```verilog
// 行 497–515
parameter DEP_INST01_SRC0_MASK  = 0;   // inst0→inst1 整数源0 读写相关
parameter DEP_INST01_SRC1_MASK  = 1;   // inst0→inst1 整数源1 读写相关
parameter DEP_INST12_SRC0_MASK  = 2;   // inst1→inst2 整数源0
parameter DEP_INST12_SRC1_MASK  = 3;   // inst1→inst2 整数源1
parameter DEP_INST23_SRC0_MASK  = 4;   // inst2→inst3 整数源0
parameter DEP_INST23_SRC1_MASK  = 5;   // inst2→inst3 整数源1
parameter DEP_INST02_PREG_MASK  = 6;   // inst0→inst2 整数目的相关
parameter DEP_INST13_PREG_MASK  = 7;   // inst1→inst3 整数目的相关
parameter DEP_INST01_VREG_MASK  = 8;   // inst0→inst1 向量寄存器相关
parameter DEP_INST12_VREG_MASK  = 9;   // inst1→inst2 向量寄存器相关
parameter DEP_INST23_VREG_MASK  = 10;  // inst2→inst3 向量寄存器相关
parameter DEP_INST13_VREG_MASK  = 11;  // inst1→inst3 向量寄存器相关
parameter DEP_INST02_VREG_MASK  = 12;  // inst0→inst2 向量寄存器相关
parameter DEP_INST03_VREG_MASK  = 13;  // inst0→inst3 向量寄存器相关
parameter DEP_INST01_SRCV1_MASK = 14;  // inst0→inst1 向量源1相关
parameter DEP_INST12_SRCV1_MASK = 15;  // inst1→inst2 向量源1相关
parameter DEP_INST23_SRCV1_MASK = 16;  // inst2→inst3 向量源1相关
```

> **用途**：当一条指令被 split 为多条 µop 后，这些 µop 之间天然存在数据相关（后条 µop 使用前条 µop 的部分结果）。`dep_info` 向 IR 阶段的重命名单元提前告知这些相关，使其在寄存器重命名时能正确处理 RAW 依赖，不必等到读操作数阶段才发现。

### 3.4 执行单元类型参数（10 位独热码）

```verilog
// 行 520–529
parameter ALU    = 10'b0000000001;  // 整数 ALU
parameter BJU    = 10'b0000000010;  // 分支跳转单元
parameter MULT   = 10'b0000000100;  // 乘法器
parameter DIV    = 10'b0000001000;  // 除法器
parameter LSU    = 10'b0000010000;  // 访存单元（单路）
parameter LSU_P5 = 10'b0000110000;  // 访存单元（双路）
parameter PIPE67 = 10'b0001000000;  // P6+P7 协处理器
parameter PIPE6  = 10'b0010000000;  // P6 浮点/向量
parameter PIPE7  = 10'b0100000000;  // P7 浮点/向量
parameter SPECIAL= 10'b1000000000;  // 特殊（异常/fence）
```

---

## 4. 子模块实例化全景

```
ct_idu_id_dp
│
├── x_ct_idu_id_decd0  (行 750)  ──── 对 id_inst0 进行完整 RISC-V 译码
├── x_ct_idu_id_decd1  (行 804)  ──── 对 id_inst1 进行完整 RISC-V 译码
├── x_ct_idu_id_decd2  (行 858)  ──── 对 id_inst2 进行完整 RISC-V 译码
│
├── x_ct_idu_id_split_long   (行 1341) ── inst0 的长拆分（最多 4 µop，含状态机）
│
├── x_ct_idu_id_split_short0 (行 1415) ── inst0 的短拆分（2 µop，纯组合逻辑）
├── x_ct_idu_id_split_short1 (行 1444) ── inst1 的短拆分
└── x_ct_idu_id_split_short2 (行 1473) ── inst2 的短拆分
```

### 4.1 为什么设置三个并行译码器

C910 三发射需要在同一周期对三条指令同时进行译码，才能保证每周期最多三条指令流向 IR。每个译码器接收一条 32 位指令编码，输出寄存器号、执行单元类型、特殊标志等几十路信号。三个译码器并行工作，面积换吞吐。

### 4.2 为什么只有一个 split_long 但有三个 split_short

- `split_long` 需要状态机跨多个周期执行，硬件代价高。C910 规定 split_long 指令（如向量多发指令）只能出现在 inst0 槽位（由控制路径保证），因此只需一个实例。
- `split_short` 是纯组合逻辑（当拍产生两条 µop），三条原始指令中任一条都可能需要短拆分，因此每条指令配备一个独立的 split_short 实例。

### 4.3 子模块接口汇总

| 子模块 | 主要输入 | 主要输出 |
|--------|----------|----------|
| `id_decd{0,1,2}` | `id_inst{N}_inst[31:0]`、向量 CSR 快照 | 寄存器号(×多路)、执行类型、拆分类型、特殊标志 |
| `id_split_long` | `id_inst0_data[...]`、`id_inst0_split_long_type[9:0]` | 4×178 位 µop 数据 + 17 位 dep_info |
| `id_split_short{0,1,2}` | `id_inst{N}_data[...]`、`id_inst{N}_split_short_type[6:0]` | 2×178 位 µop 数据 + 4 位 dep_info |

---

## 5. 指令数据的接收与流水线寄存器

### 5.1 来自 IBUF 的直接连接（行 537–539）

```verilog
// 行 537–539
assign dp_ib_inst0_data[ID_WIDTH-1:0] = ifu_idu_ib_inst0_data[ID_WIDTH-1:0];
assign dp_ib_inst1_data[ID_WIDTH-1:0] = ifu_idu_ib_inst1_data[ID_WIDTH-1:0];
assign dp_ib_inst2_data[ID_WIDTH-1:0] = ifu_idu_ib_inst2_data[ID_WIDTH-1:0];
```

这三个 `dp_ib_*` 信号是 IBUF 输出的**当前周期**新数据（本周期写入 id_inst 寄存器前的组合值）。

### 5.2 pipedown 时的指令槽位重映射（行 544–555）

这是 id_dp 最核心的设计之一：**三条指令的槽位分配取决于本周期 pipedown 的指令数量**。

```verilog
// 行 544–555
assign dp_id_inst0_data[ID_WIDTH-1:0] =
    {ID_WIDTH{ctrl_dp_id_pipedown_1_inst}} & id_inst1_data[ID_WIDTH-1:0]
  | {ID_WIDTH{ctrl_dp_id_pipedown_2_inst}} & id_inst2_data[ID_WIDTH-1:0]
  | {ID_WIDTH{ctrl_dp_id_pipedown_3_inst}} & dp_ib_inst0_data[ID_WIDTH-1:0];

assign dp_id_inst1_data[ID_WIDTH-1:0] =
    {ID_WIDTH{ctrl_dp_id_pipedown_1_inst}} & id_inst2_data[ID_WIDTH-1:0]
  | {ID_WIDTH{ctrl_dp_id_pipedown_2_inst}} & dp_ib_inst0_data[ID_WIDTH-1:0]
  | {ID_WIDTH{ctrl_dp_id_pipedown_3_inst}} & dp_ib_inst1_data[ID_WIDTH-1:0];

assign dp_id_inst2_data[ID_WIDTH-1:0] =
    {ID_WIDTH{ctrl_dp_id_pipedown_1_inst}} & dp_ib_inst0_data[ID_WIDTH-1:0]
  | {ID_WIDTH{ctrl_dp_id_pipedown_2_inst}} & dp_ib_inst1_data[ID_WIDTH-1:0]
  | {ID_WIDTH{ctrl_dp_id_pipedown_3_inst}} & dp_ib_inst2_data[ID_WIDTH-1:0];
```

**映射规则表**：

| 条件 | dp_id_inst0_data 来源 | dp_id_inst1_data 来源 | dp_id_inst2_data 来源 |
|------|-----------------------|-----------------------|-----------------------|
| `pipedown_1_inst`（上周期发出 2 条） | id_inst1 | id_inst2 | ib_inst0（新） |
| `pipedown_2_inst`（上周期发出 1 条） | id_inst2 | ib_inst0（新） | ib_inst1（新） |
| `pipedown_3_inst`（正常 3 发射） | ib_inst0（新） | ib_inst1（新） | ib_inst2（新） |

> **体系结构原理**：当上周期由于 split 或 stall 只发出了部分指令时，剩余指令仍保存在 id_inst 寄存器中（inst1、inst2 是"留下来"的），下一周期继续从这些剩余指令开始处理，并从 IBUF 补充新指令填满空槽位。这种设计避免了 IBUF 中已取出的指令被浪费，最大化流水线利用率。

### 5.3 门控时钟（行 560–600）

```verilog
// 行 560–561
assign id_inst_clk_en = ifu_idu_ib_pipedown_gateclk
                        || ctrl_dp_id_inst0_vld;
```

门控时钟单元 `x_id_inst_gated_clk` 只有在两种情况下才开启时钟：
1. IBUF 有新指令即将 pipedown（`ib_pipedown_gateclk`）
2. inst0 当前有效（说明 ID 阶段正在处理，可能需要更新寄存器）

这是典型的**活动驱动门控时钟**（activity-gated clock）设计，当 IDU 空闲时（如指令缓冲为空）可关闭这部分时钟，显著降低动态功耗。

```verilog
// 行 583–600
always @(posedge id_inst_clk or negedge cpurst_b)
begin
  if(!cpurst_b) begin
    id_inst0_data <= {ID_WIDTH{1'b0}};
    ...
  end
  else if(!ctrl_dp_id_stall) begin
    id_inst0_data <= dp_id_inst0_data;   // 正常更新
    ...
  end
  else begin
    id_inst0_data <= id_inst0_data;      // stall 时保持
    ...
  end
end
```

**Stall 保持语义**：当控制路径发出 stall（例如 split_long 仍在展开、或下游 IR 满载），id_inst 寄存器保持当前值，等待下一个非 stall 周期再更新。由于门控时钟使能已经包含了 `ctrl_dp_id_inst0_vld`，stall 时寄存器的"保持"行为通过 else 分支明确表达（而非依赖时钟关闭），保证功能正确性。

---

## 6. 指令类型判断与控制路径反馈

### 6.1 指令类型分类（行 699–724）

```verilog
// 行 699–707
assign dp_id_inst0_normal = !id_inst0_data[ID_FENCE]
                          && !id_inst0_data[ID_SPLIT_SHORT]
                          && !id_inst0_data[ID_SPLIT_LONG];
// inst1、inst2 类似
```

每条指令被分为四类互斥（在这里 fence/split_short/split_long 三者互斥，normal 是其补集）：

```
指令类型
├── normal    ：普通指令，经译码器直接打包发往 IR
├── fence     ：内存屏障类，由专用 fence 模块处理后结果注入
├── split_short：当拍拆分为 2 条 µop（纯组合逻辑）
└── split_long ：需多周期展开为 2~4 条 µop
```

> **注意**：breakpoint（bkpt）、IFU 取指异常（expt）和非法指令（illegal）**不设置 split/fence 位**，因此它们被归类为 normal（尽管后续数据通路会用 expt_data 替换 decd_data）。这样控制路径只需判断一个 normal 信号，简化了流程。

### 6.2 向控制路径的输出（行 710–724）

```verilog
assign dp_ctrl_id_inst0_fence       = id_inst0_data[ID_FENCE];
assign dp_ctrl_id_inst0_split_short = id_inst0_data[ID_SPLIT_SHORT];
assign dp_ctrl_id_inst0_split_long  = id_inst0_data[ID_SPLIT_LONG];
assign dp_ctrl_id_inst0_normal      = dp_id_inst0_normal;
```

控制路径（`ct_idu_id_ctrl`）根据这些信号决定：
- 是否插入 stall（split_long 需要多周期）
- 本周期实际 pipedown 几条指令
- 是否通知 fence 模块接管

---

## 7. 译码结果的组织（Normal Data Path）

### 7.1 向译码器喂入数据（行 732–747）

```verilog
// 行 732–734
assign id_inst0_inst[31:0] = id_inst0_data[ID_OPCODE:ID_OPCODE-31]; // [31:0]
assign id_inst1_inst[31:0] = id_inst1_data[31:0];
assign id_inst2_inst[31:0] = id_inst2_data[31:0];

// 向量 CSR 快照分解（行 736–746）
assign id_inst0_vsew[1:0]  = id_inst0_data[ID_VSEW-1:ID_VSEW-2];   // [47:46]
assign id_inst0_vlmul[1:0] = id_inst0_data[ID_VLMUL:ID_VLMUL-1];   // [45:44]
assign id_inst0_vl[7:0]    = id_inst0_data[ID_VL:ID_VL-7];         // [71:64]
```

IBUF 已将取指时刻的向量 CSR（vtype、vl）快照进了 73 位数据包，这里将其分解后和 opcode 一起送入 id_decd。**这样译码器的向量指令判断不需要读 CSR 堆**，减少了关键路径延迟并避免了 CSR 写-读竞争。

### 7.2 三个译码器并行工作

三个 `ct_idu_id_decd` 实例结构完全相同，仅连接到不同的 inst 信号：

| 实例 | 行号 | 处理指令 | 主要输出前缀 |
|------|------|----------|-------------|
| `x_ct_idu_id_decd0` | 750 | `id_inst0` | `id_inst0_*` |
| `x_ct_idu_id_decd1` | 804 | `id_inst1` | `id_inst1_*` |
| `x_ct_idu_id_decd2` | 858 | `id_inst2` | `id_inst2_*` |

每个译码器输出以下信号（以 decd0 为例）：

| 信号 | 宽度 | 含义 |
|------|------|------|
| `id_inst0_dst_reg` | 5 | 整数目的寄存器号 |
| `id_inst0_dst_vld` | 1 | 整数目的有效 |
| `id_inst0_dst_x0` | 1 | 目的为 x0（写入无效） |
| `id_inst0_src0/1_reg` | 5×2 | 整数源寄存器号 |
| `id_inst0_src0/1/2_vld` | 1×3 | 整数源有效（src2_vld 实为立即数标志） |
| `id_inst0_dstf_reg` | 5 | 浮点目的寄存器号 |
| `id_inst0_dstf/dste_vld` | 1×2 | 浮点/扩展目的有效 |
| `id_inst0_srcf0/1/2_reg` | 5×3 | 浮点源寄存器号 |
| `id_inst0_srcf0/1/2_vld` | 1×3 | 浮点源有效 |
| `id_inst0_dstv_reg` | 5 | 向量目的寄存器号 |
| `id_inst0_dstv_vld` | 1 | 向量目的有效 |
| `id_inst0_srcv0/1_reg` | 5×2 | 向量源 0/1 寄存器号 |
| `id_inst0_srcv0/1_vld` | 1×2 | 向量源 0/1 有效 |
| `id_inst0_srcv2/srcvm_vld` | 1×2 | 向量源 2（vd 作为 src）和 mask 有效 |
| `id_inst0_inst_type` | 10 | 独热执行单元类型 |
| `id_inst0_split_long_type` | 10 | split_long 操作类型 |
| `id_inst0_split_short_type` | 7 | split_short 操作类型 |
| `id_inst0_length` | 1 | 指令长度（0=16位压缩指令，1=32位） |
| `id_inst0_illegal` | 1 | 非法指令 |
| `id_inst0_fence_type` | 3 | fence 类型 |
| `id_inst0_mov/fmov` | 1×2 | 整数/浮点 MOV（零延迟 move 候选） |
| `id_inst0_mla/fmla/vmla` | 1×3 | 整数/浮点/向量乘加 |
| `id_inst0_vmb` | 1 | 向量掩码位 |

### 7.3 译码结果打包为 IR 格式（行 919–1001，`id_decd_inst0_data`）

```verilog
// 行 954–998（以 inst0 为例）
always @(...)
begin
  id_decd_inst0_data[IR_WIDTH-1:0]                = {IR_WIDTH{1'b0}};
  if(1'b1) begin
  id_decd_inst0_data[IR_VL_PRED]                  = id_inst0_data[ID_VL_PRED];
  id_decd_inst0_data[IR_VL:IR_VL-7]               = id_inst0_data[ID_VL:ID_VL-7];
  id_decd_inst0_data[IR_VMB]                      = id_inst0_vmb;
  id_decd_inst0_data[IR_PC:IR_PC-14]              = id_inst0_data[ID_PC:ID_PC-14];
  // ... 所有 IR 字段依次赋值
  id_decd_inst0_data[IR_DST_REG:IR_DST_REG-5]     = {1'b0, id_inst0_dst_reg[4:0]};
  id_decd_inst0_data[IR_SRC0_REG:IR_SRC0_REG-5]   = {1'b0, id_inst0_src0_reg[4:0]};
  id_decd_inst0_data[IR_OPCODE:IR_OPCODE-31]      = id_inst0_data[ID_OPCODE:ID_OPCODE-31];
  end
end
```

**关键设计细节**：

1. **寄存器号宽度扩展**：译码器输出 5 位寄存器号（`id_inst0_dst_reg[4:0]`），打包时补零扩展为 6 位（`{1'b0, id_inst0_dst_reg[4:0]}`）。多出的 1 位预留给重命名后的物理寄存器号扩展空间，或向量组寄存器（LMUL>1 时 vd/vs 需要更多位）。

2. **从 `id_inst0_data` 直接转抄的字段**：PC、VL、VSEW、VLMUL、NO_SPEC、BKPTA/B、OPCODE 等本来已在 73 位数据包中，不经译码器，直接转抄到 178 位格式对应位置。

3. **来自译码器的字段**：所有寄存器号、有效位、执行类型、特殊标志（mov、mla、fmla、vmla 等）均来自 id_decd 输出。

4. **`if(1'b1)`** 是编译器指令（`&CombBeg`/`&CombEnd` 宏生成的架构）的固定模式，确保 always 块内的赋值在任何情况下都执行（即无条件赋值）。

三个 `id_decd_instN_data` 的打包逻辑完全对称（行 919–1001 为 inst0，1003–1087 为 inst1，1089–1172 为 inst2）。

---

## 8. 异常数据通路（Expt Data Path）

### 8.1 异常检测（行 1179–1221）

```verilog
// 行 1179–1187
assign id_expt_inst0_expt_vld = ctrl_dp_id_inst0_vld
                                && (id_inst0_data[ID_EXPT_VLD] || id_inst0_illegal);
```

两种情况触发异常通路：
1. `ID_EXPT_VLD`：IFU 阶段已检测到异常（取指对齐错误、页错误等）
2. `id_inst0_illegal`：译码器检测到非法指令

两者的区别还在于优先级：
```verilog
// 行 1189–1194
assign id_expt_inst0_high_hw_expt = id_inst0_data[ID_EXPT_VLD]
                                    && id_inst0_data[ID_HIGH_HW_EXPT];
```
`HIGH_HW_EXPT` 指高优先级硬件异常（如精确异常），需要在异常数据包中单独标注，供 RTU 正确处理中断/异常优先级。

### 8.2 异常向量号选择（行 1197–1222）

```verilog
// 行 1197–1204
always @(id_inst0_data[36:32])
begin
  if(id_inst0_data[ID_EXPT_VLD])
    id_expt_inst0_expt_vec[4:0] = {1'b0, id_inst0_data[ID_EXPT_VEC:ID_EXPT_VEC-3]};
  else  // illegal
    id_expt_inst0_expt_vec[4:0] = 5'd2;  // RISC-V 非法指令异常向量为 2
end
```

当 IFU 异常有效时使用其向量号（4 位，符号扩展为 5 位）；否则（纯非法指令）固定使用 RISC-V 规定的异常向量 2（Illegal Instruction）。

### 8.3 异常数据包打包（行 1227–1315）

与 decd_data 打包类似，但字段集合不同：
- 保留：PC、VL、VSEW、VLMUL、BKPTA/B、LENGTH、OPCODE
- **新增**：`IR_ILLEGAL`（非法指令标志）、`IR_EXPT`（高优先级异常）、异常向量号+有效位
- **强制**：`IR_INST_TYPE = SPECIAL`（异常指令固定路由到特殊执行单元）
- **省略**：寄存器号字段（异常不需要读写寄存器）

```verilog
// 行 1251
id_expt_inst0_data[IR_INST_TYPE:IR_INST_TYPE-9] = SPECIAL;
```

> **原理**：异常处理不需要执行 ALU/LSU 操作，强制指定 SPECIAL 类型后，后端发射逻辑会将其路由到异常处理路径（通常是 CSR/特权模式流水线），由 RTU 统一处理。

### 8.4 normal vs expt 数据选择（行 1320–1328）

```verilog
// 行 1320–1328
assign id_normal_inst0_data[IR_WIDTH-1:0] = (id_expt_inst0_expt_vld)
    ? id_expt_inst0_data[IR_WIDTH-1:0]
    : id_decd_inst0_data[IR_WIDTH-1:0];
```

这是一个关键的数据多路选择：**异常优先于译码结果**。一旦检测到异常（无论来自 IFU 还是译码器），就用异常数据包替换译码结果，确保异常信息能正确传递到 IR 阶段处理，而不是发出错误的寄存器操作。

---

## 9. Split Long 数据通路

### 9.1 实例化（行 1341–1369）

```verilog
// 行 1341（仅 inst0）
ct_idu_id_split_long  x_ct_idu_id_split_long (
  ...
  .dp_split_long_inst   (id_inst0_data[31:0]          ),  // 32 位指令编码
  .dp_split_long_type   (id_inst0_split_long_type[9:0]),  // 由 decd0 给出
  .dp_split_long_vlmul  (id_inst0_data[45:44]         ),
  .dp_split_long_vsew   (id_inst0_data[48:46]         ),
  .dp_split_long_vl     (id_inst0_data[71:64]         ),
  .dp_split_long_vl_pred(id_inst0_data[72]            ),
  .dp_split_long_pc     (id_inst0_data[63:49]         ),
  ...
  .split_long_dp_inst0_data(split_long_dp_inst0_data  ),  // µop 0
  .split_long_dp_inst1_data(split_long_dp_inst1_data  ),  // µop 1
  .split_long_dp_inst2_data(split_long_dp_inst2_data  ),  // µop 2
  .split_long_dp_inst3_data(split_long_dp_inst3_data  ),  // µop 3
  .split_long_dp_dep_info  (split_long_dp_dep_info    ),  // 17 位相关信息
  .split_long_ctrl_id_stall(split_long_ctrl_id_stall  ),  // 请求 stall
  .split_long_ctrl_inst_vld(split_long_ctrl_inst_vld  )   // 各 µop 有效掩码
);
```

**只处理 inst0**：split_long 只接收 `id_inst0_data` 的数据。由 `id_inst0_split_long_type[9:0]` 告知具体的拆分类型（是哪类向量指令，需要产生哪些 µop）。

**为何需要 stall**：split_long 内含状态机，一条原始指令可能需要 2~4 个周期才能产生全部 µop。在这些周期里，`split_long_ctrl_id_stall=1` 使 ID 阶段暂停接收新指令，保持 inst0 不变，直到 `split_long_ctrl_inst_vld` 指示所有 µop 已就绪。

### 9.2 异常覆盖（行 1383–1407）

```verilog
// 行 1392–1407
always @(...)
begin
  if(!id_expt_inst0_expt_vld) begin
    // 无异常：使用 split_long 模块输出
    id_split_long_inst0_data = split_long_dp_inst0_data;
    id_split_long_inst1_data = split_long_dp_inst1_data;
    id_split_long_inst2_data = split_long_dp_inst2_data;
    id_split_long_inst3_data = split_long_dp_inst3_data;
    id_split_long_dep_info   = split_long_dp_dep_info;
  end
  else begin
    // 有异常：所有 4 个槽位都填入异常数据包，相关性清零
    id_split_long_inst0_data = id_expt_inst0_data;
    id_split_long_inst1_data = id_expt_inst0_data;
    id_split_long_inst2_data = id_expt_inst0_data;
    id_split_long_inst3_data = id_expt_inst0_data;
    id_split_long_dep_info   = {DEP_WIDTH{1'b0}};
  end
end
```

**原理**：如果 inst0 本身携带异常，split_long 产生的 µop 序列没有意义，必须用异常数据包覆盖所有 4 个槽位，确保 IR 阶段只看到异常信息。相关性清零是因为异常处理不涉及寄存器写操作，下游无需追踪这些 µop 间的数据相关。

---

## 10. Split Short 数据通路（×3）

### 10.1 三个实例（行 1415/1444/1473）

```verilog
// inst0 → split_short0 (行 1415)
ct_idu_id_split_short  x_ct_idu_id_split_short0 (
  .dp_split_short_inst  (id_inst0_data[31:0]           ),
  .dp_split_short_type  (id_inst0_split_short_type[6:0]),
  ...
  .split_short_dp_inst0_data(split_short0_dp_inst0_data),  // µop_a（主操作）
  .split_short_dp_inst1_data(split_short0_dp_inst1_data),  // µop_b（副操作）
  .split_short_dp_dep_info  (split_short0_dp_dep_info  )   // 4 位相关信息
);

// inst1 → split_short1 (行 1444)
// inst2 → split_short2 (行 1473)
// 结构相同，仅连接 id_inst1/id_inst2 数据
```

split_short 是**纯组合逻辑**，一拍内完成拆分，输出固定两条 µop。`split_short_type[6:0]` 由对应的 id_decd 译码器给出，编码了具体的拆分方式（如先 fence 后操作、先清零后运算等）。

**dep_info 格式（4 位）**：
```
bit 0: inst0→inst1 整数源 0 相关
bit 1: inst0→inst1 整数源 1 相关
bit 2: inst0→inst1 向量寄存器相关
bit 3: inst0→inst1 向量源 1 相关
```

### 10.2 异常覆盖（行 1501–1559，各 split_short 实例）

与 split_long 相同的模式——若对应 inst 有异常，两条 µop 均替换为异常数据包，dep_info 清零：

```verilog
// 行 1508–1519（split_short0 for inst0）
if(!id_expt_inst0_expt_vld) begin
  id_split_short0_inst0_data = split_short0_dp_inst0_data;
  id_split_short0_inst1_data = split_short0_dp_inst1_data;
  id_split_short0_dep_info   = split_short0_dp_dep_info;
end
else begin
  id_split_short0_inst0_data = id_expt_inst0_data;  // 异常覆盖
  id_split_short0_inst1_data = id_expt_inst0_data;
  id_split_short0_dep_info   = 4'b0;
end
```

---

## 11. Fence 数据通路

### 11.1 向 Fence 模块提供数据（行 1567–1574）

```verilog
// 行 1567–1574
assign dp_fence_id_inst[31:0]   = id_inst0_data[ID_OPCODE:ID_OPCODE-31];
assign dp_fence_id_bkpta_inst   = id_inst0_data[ID_BKPTA_INST];
assign dp_fence_id_bkptb_inst   = id_inst0_data[ID_BKPTB_INST];
assign dp_fence_id_vlmul[1:0]   = id_inst0_data[ID_VLMUL:ID_VLMUL-1];
assign dp_fence_id_vsew[2:0]    = id_inst0_data[ID_VSEW:ID_VSEW-2];
assign dp_fence_id_vl[7:0]      = id_inst0_data[ID_VL:ID_VL-7];
assign dp_fence_id_vl_pred      = id_inst0_data[ID_VL_PRED];
assign dp_fence_id_pc[14:0]     = id_inst0_data[ID_PC:ID_PC-14];
assign dp_fence_id_fence_type   = id_inst0_fence_type[2:0];  // 来自 decd0
```

**Fence 只使用 inst0**：fence 型指令（FENCE、FENCE.I、AMO 等）由控制路径保证只出现在 inst0 位置（通过 stall 将其他指令排开）。id_dp 将 inst0 的原始信息送往专用 fence 模块处理，后者异步（或经寄存器）返回 `fence_dp_inst{0,1,2}_data`，最多产生 3 条 µop 注入 IR 槽位。

---

## 12. pipedown 数据选择（MUX 到 IR）

这是 id_dp 最复杂的部分：将不同来源的 µop 数据选入 inst0～inst3 四个 IR 槽位。

### 12.1 inst0 槽位（行 1582–1586，纯组合逻辑）

```verilog
// 行 1582–1586
assign dp_id_pipedown_inst0_data[IR_WIDTH-1:0] =
    {IR_WIDTH{dp_id_inst0_normal}}            & id_normal_inst0_data[IR_WIDTH-1:0]
  | {IR_WIDTH{id_inst0_data[ID_SPLIT_SHORT]}} & id_split_short0_inst0_data[IR_WIDTH-1:0]
  | {IR_WIDTH{id_inst0_data[ID_SPLIT_LONG]}}  & id_split_long_inst0_data[IR_WIDTH-1:0]
  | {IR_WIDTH{id_inst0_data[ID_FENCE]}}       & fence_dp_inst0_data[IR_WIDTH-1:0];
```

inst0 槽位的 MUX 逻辑最简单（assign 实现），按互斥选择：

| inst0 类型 | inst0 槽位填入 |
|------------|---------------|
| normal | `id_normal_inst0_data`（decd 或 expt） |
| split_short | `id_split_short0_inst0_data`（µop_a） |
| split_long | `id_split_long_inst0_data`（µop 0） |
| fence | `fence_dp_inst0_data` |

### 12.2 inst1 槽位（行 1591–1614）

```verilog
// 行 1601–1612
if(id_inst0_data[ID_FENCE])
  dp_id_pipedown_inst1_data = fence_dp_inst1_data;
else if(id_inst0_data[ID_SPLIT_SHORT])
  dp_id_pipedown_inst1_data = id_split_short0_inst1_data;   // inst0 的 µop_b
else if(id_inst0_data[ID_SPLIT_LONG])
  dp_id_pipedown_inst1_data = id_split_long_inst1_data;     // inst0 的 µop 1
else if(id_inst1_data[ID_SPLIT_SHORT])
  dp_id_pipedown_inst1_data = id_split_short1_inst0_data;   // inst1 的 µop_a
else
  dp_id_pipedown_inst1_data = id_normal_inst1_data;         // inst1 普通译码
```

inst1 槽位的选择规则（优先级从高到低）：

| 条件 | inst1 槽位填入 | 说明 |
|------|---------------|------|
| inst0 是 fence | fence 模块的 µop1 | fence 独占后续槽位 |
| inst0 是 split_short | inst0 拆分的第 2 条 µop | inst0 占用 inst1 槽 |
| inst0 是 split_long | inst0 拆分的第 2 条 µop | inst0 占用 inst1 槽 |
| inst1 是 split_short | inst1 拆分的第 1 条 µop | inst1 自己开始展开 |
| 否则 | inst1 普通译码结果 | 正常三发射 |

### 12.3 inst2 槽位（行 1619–1650）

```verilog
// 行 1631–1649
if(id_inst0_data[ID_FENCE])
  dp_id_pipedown_inst2_data = fence_dp_inst2_data;
else if(id_inst0_data[ID_SPLIT_LONG])
  dp_id_pipedown_inst2_data = id_split_long_inst2_data;
else if(id_inst0_data[ID_SPLIT_SHORT] && id_inst1_data[ID_SPLIT_SHORT])
  dp_id_pipedown_inst2_data = id_split_short1_inst0_data;   // inst1 的 µop_a
else if(id_inst0_data[ID_SPLIT_SHORT])
  dp_id_pipedown_inst2_data = id_normal_inst1_data;         // inst1 普通指令
else if(id_inst1_data[ID_SPLIT_SHORT])
  dp_id_pipedown_inst2_data = id_split_short1_inst1_data;   // inst1 的 µop_b
else if(id_inst2_data[ID_SPLIT_SHORT])
  dp_id_pipedown_inst2_data = id_split_short2_inst0_data;   // inst2 的 µop_a
else
  dp_id_pipedown_inst2_data = id_normal_inst2_data;
```

inst2 槽位需要处理更多组合情况（inst0 split + inst1 split 同时存在的情形）：

| 条件 | inst2 槽位填入 |
|------|---------------|
| inst0 fence | fence µop2 |
| inst0 split_long | split_long µop2 |
| inst0 split_short **且** inst1 split_short | inst1 的 µop_a（inst0 µop_a/b 占 slot0/1，inst1 µop_a 到 slot2） |
| inst0 split_short（inst1 普通） | inst1 的普通译码结果 |
| inst1 split_short | inst1 的 µop_b |
| inst2 split_short | inst2 的 µop_a |
| 否则 | inst2 普通译码结果 |

### 12.4 inst3 槽位（行 1655–1678）

```verilog
// 行 1664–1677
if(id_inst0_data[ID_SPLIT_LONG])
  dp_id_pipedown_inst3_data = id_split_long_inst3_data;
else if(id_inst0_data[ID_SPLIT_SHORT] && id_inst1_data[ID_SPLIT_SHORT])
  dp_id_pipedown_inst3_data = id_split_short1_inst1_data;   // inst1 的 µop_b
else if(id_inst0_data[ID_SPLIT_SHORT])
  dp_id_pipedown_inst3_data = id_normal_inst2_data;
else if(id_inst1_data[ID_SPLIT_SHORT])
  dp_id_pipedown_inst3_data = id_normal_inst2_data;
else  // inst2 split_short 或普通
  dp_id_pipedown_inst3_data = id_split_short2_inst1_data;
```

| 条件 | inst3 槽位填入 |
|------|---------------|
| inst0 split_long | split_long µop3 |
| inst0 split_short **且** inst1 split_short | inst1 的 µop_b |
| inst0 split_short（inst1 普通） | inst2 普通译码结果 |
| inst1 split_short | inst2 普通译码结果 |
| inst2 split_short 或普通 | inst2 的 µop_b |

### 12.5 各场景下四槽位分配全景图

**场景 1：全部普通指令（无 split/fence）**
```
slot0 = inst0_normal
slot1 = inst1_normal
slot2 = inst2_normal
slot3 = inst2_split_short1_data（inst2 无 split 时实际为 split_short2_inst1_data，
         但控制路径此时 inst3 无效）
```

**场景 2：inst0 split_short**
```
slot0 = inst0_split_short0_inst0  (µop_a)
slot1 = inst0_split_short0_inst1  (µop_b)
slot2 = inst1_normal
slot3 = inst2_normal
```

**场景 3：inst0 split_short + inst1 split_short**
```
slot0 = inst0_split_short0_inst0  (inst0 µop_a)
slot1 = inst0_split_short0_inst1  (inst0 µop_b)
slot2 = inst1_split_short1_inst0  (inst1 µop_a)
slot3 = inst1_split_short1_inst1  (inst1 µop_b)
```

**场景 4：inst1 split_short（inst0 普通）**
```
slot0 = inst0_normal
slot1 = inst1_split_short1_inst0  (inst1 µop_a)
slot2 = inst1_split_short1_inst1  (inst1 µop_b)
slot3 = inst2_normal
```

**场景 5：inst2 split_short（inst0/1 普通）**
```
slot0 = inst0_normal
slot1 = inst1_normal
slot2 = inst2_split_short2_inst0  (inst2 µop_a)
slot3 = inst2_split_short2_inst1  (inst2 µop_b)
```

**场景 6：inst0 split_long**
```
slot0 = split_long_inst0  (µop0)
slot1 = split_long_inst1  (µop1)
slot2 = split_long_inst2  (µop2)
slot3 = split_long_inst3  (µop3)
inst1/inst2 的数据不使用（控制路径已确保 split_long 时只有 inst0 有效）
```

**场景 7：inst0 fence**
```
slot0 = fence_dp_inst0_data
slot1 = fence_dp_inst1_data
slot2 = fence_dp_inst2_data
slot3 = 不使用（fence 最多 3 µop）
```

---

## 13. 相关性信息（dep_info）打包

### 13.1 dep_info 的作用

当多条 µop 同周期发往 IR 时，它们之间可能存在数据相关：例如 inst0 的 µop_b 写了寄存器 x5，inst1 的 µop_a 读了 x5。ID 阶段已可以检测这些相关，用 dep_info 向 IR 阶段传递，避免 IR 阶段（重命名）重复比较。

### 13.2 dep_info 组装（行 1683–1768）

```verilog
// 行 1752–1767（主选择逻辑）
if(id_inst0_data[ID_SPLIT_LONG])
  dp_id_pipedown_dep_info = id_split_long_dep_info;
else if(id_inst0_data[ID_SPLIT_SHORT] && id_inst1_data[ID_SPLIT_SHORT])
  dp_id_pipedown_dep_info = id_inst01_split_short_dep_info;  // 两个 split_short 合并
else if(id_inst0_data[ID_SPLIT_SHORT])
  dp_id_pipedown_dep_info = id_inst0_split_short_dep_info;
else if(id_inst1_data[ID_SPLIT_SHORT])
  dp_id_pipedown_dep_info = id_inst1_split_short_dep_info;
else if(id_inst2_data[ID_SPLIT_SHORT])
  dp_id_pipedown_dep_info = id_inst2_split_short_dep_info;
else
  dp_id_pipedown_dep_info = {DEP_WIDTH{1'b0}};
```

对于普通三发射（无 split），dep_info 全零——因为三条独立原始指令之间的相关由 IR 阶段的比较器网络负责检测（不在 ID 阶段提前计算）。

**`id_inst01_split_short_dep_info` 的合并（行 1684–1700）**：

```verilog
// 行 1687–1697
id_inst01_split_short_dep_info[DEP_INST01_SRC0_MASK]  = id_split_short0_dep_info[0];
id_inst01_split_short_dep_info[DEP_INST01_SRC1_MASK]  = id_split_short0_dep_info[1];
id_inst01_split_short_dep_info[DEP_INST01_VREG_MASK]  = id_split_short0_dep_info[2];
id_inst01_split_short_dep_info[DEP_INST01_SRCV1_MASK] = id_split_short0_dep_info[3];

id_inst01_split_short_dep_info[DEP_INST23_SRC0_MASK]  = id_split_short1_dep_info[0];
id_inst01_split_short_dep_info[DEP_INST23_SRC1_MASK]  = id_split_short1_dep_info[1];
id_inst01_split_short_dep_info[DEP_INST23_VREG_MASK]  = id_split_short1_dep_info[2];
id_inst01_split_short_dep_info[DEP_INST23_SRCV1_MASK] = id_split_short1_dep_info[3];
```

当 inst0 和 inst1 都是 split_short 时，IR 的 slot0/1 来自 inst0 的两条 µop，slot2/3 来自 inst1 的两条 µop。因此 inst0 的 split_short dep_info（描述 slot0→slot1 相关）被映射到 DEP_INST01 位，inst1 的 split_short dep_info（描述 slot2→slot3 相关）被映射到 DEP_INST23 位。

对于只有 inst1 是 split_short 的情形（行 1715–1726），inst1 的 dep_info 描述的是 slot1→slot2 相关，故映射到 DEP_INST12 位：

```verilog
id_inst1_split_short_dep_info[DEP_INST12_SRC0_MASK]  = id_split_short1_dep_info[0];
id_inst1_split_short_dep_info[DEP_INST12_SRC1_MASK]  = id_split_short1_dep_info[1];
id_inst1_split_short_dep_info[DEP_INST12_VREG_MASK]  = id_split_short1_dep_info[2];
id_inst1_split_short_dep_info[DEP_INST12_SRCV1_MASK] = id_split_short1_dep_info[3];
```

类似地，inst2 split_short 时映射到 DEP_INST23（行 1728–1739）。

---

## 14. 调试与 HAD 接口

### 14.1 HAD（Hardware Auxiliary Debugger）调试数据（行 605–692）

```verilog
// 行 605
assign debug_id_inst_clk_en = ctrl_dp_id_debug_id_pipedown3;

// 行 627–688
always @(posedge debug_id_inst_clk or negedge cpurst_b)
begin
  ...
  else if(ctrl_dp_id_debug_id_pipedown3) begin
    debug_id_inst0[31:0] <= id_inst0_data[31:0];   // 捕获 opcode
    debug_id_inst0_info  <= dp_id_inst0_info;       // 捕获类型标志
  end
end
```

`idu_had_id_inst{0,1,2}_info[39:0]` = `{debug_info[7:0], debug_opcode[31:0]}`

**info 字段含义**（行 653–669）：
```
info[0] = id_instN_data[32]  = ID_EXPT_VLD（IFU 异常）
info[1] = id_instN_data[39]  = ID_FENCE
info[2] = id_instN_data[40]  = ID_SPLIT_SHORT
info[3] = id_instN_data[41]  = ID_BKPTB_INST
info[7:4] = 4'b0
```

**原理**：HAD 是 C910 的片上调试接口（类似 JTAG/DM 在 RTL 层的封装）。`ctrl_dp_id_debug_id_pipedown3` 在调试单步或断点停止时由控制路径拉高，触发 debug 寄存器捕获当时的指令信息。由于调试信号使用了独立的门控时钟（`debug_id_inst_clk`，只在调试 pipedown3 时开），正常执行时这条路径完全关闭，不消耗动态功耗，也不影响时序关键路径。

---

## 15. 完整数据流总结

### 15.1 从 IBUF 到 IR 的端到端数据流

```
IBUF (ifu_idu_ib_inst{0,1,2}_data[72:0])
  │
  │  pipedown_N_inst 决定槽位对齐（行 544–555）
  ▼
id_inst{0,1,2}_data[72:0]  ← ID 阶段流水线寄存器（id_inst_clk 门控）
  │
  ├──►  id_decd{0,1,2}  ──────────────────────────────────────────────┐
  │     (译码器×3，并行)                                                │
  │     输出：寄存器号、exec_type、特殊标志、split_type                  │
  │                                                                    │
  ├──►  id_split_long   ───────────────────────────────┐              │
  │     (仅 inst0，含状态机)                            │              │
  │     输出：4×178位 µop + 17位 dep_info               │              │
  │                                                    │              │
  ├──►  id_split_short{0,1,2}  ──────────────────┐    │              │
  │     (纯组合逻辑，各对应 inst{0,1,2})           │    │              │
  │     输出：2×178位 µop + 4位 dep_info           │    │              │
  │                                               │    │              │
  └──►  dp_fence_id_* → fence 模块 → fence_dp_inst{0,1,2}_data       │
                                                  │    │              │
                                                  ▼    ▼              ▼
                                         ┌────────────────────────────────┐
                                         │  pipedown MUX（inst0~3 选择）   │
                                         │  行 1582–1678                  │
                                         └────────────────────────────────┘
                                                       │
                                    ┌──────────────────┼──────────────────┐
                                    ▼                  ▼                  ▼
                          dp_id_pipedown_inst0    inst1    inst2    inst3
                          [177:0]×4                                      │
                                                                         ▼
                                                               dp_id_pipedown_dep_info[16:0]
                                                                         │
                                                                         ▼
                                                                      IR 阶段
```

### 15.2 各路径互斥关系

同一个 inst 槽位的 fence/split_short/split_long/normal 标志由 IBUF 在取指时根据预译码结果设置，四者互斥。`id_dp` 在译码阶段不重新判断，而是直接读取这些位做 MUX 选择，减少了关键路径上的逻辑深度。

### 15.3 异常插入点

```
id_decd_instN_data ─┐
                     ├─ MUX（expt_vld 选择）─► id_normal_instN_data
id_expt_instN_data ─┘

split_long_dp_* ────┐
                    ├─ MUX（expt_vld 选择）─► id_split_long_inst*_data
id_expt_inst0_data ─┘

split_shortN_dp_* ──┐
                    ├─ MUX（expt_vld 选择）─► id_split_shortN_inst*_data
id_expt_instN_data ─┘
```

异常覆盖发生在进入最终 pipedown MUX 之前，因此 pipedown MUX 本身不需要关心异常，只需关心 split/fence/normal 类型。

### 15.4 关键时序路径分析

```
IBUF 输出
  → id_inst 寄存器（一级寄存）
  → id_decd 译码（组合逻辑，最深路径）
  → id_decd_instN_data 打包
  → expt MUX
  → pipedown MUX（inst1~3 有多层 if-else）
  → dp_id_pipedown_instN_data（寄存器输入）
  → IR 阶段寄存
```

整个路径在一个时钟周期内完成。`id_split_long` 因为含状态机，其输出 `split_long_dp_inst*_data` 在 stall 周期内保持稳定，不在关键路径上。split_short 是纯组合逻辑，其延迟与 id_decd 类似，需要仔细约束。

---

## 附录：信号命名规律

| 前缀/中缀 | 含义 |
|-----------|------|
| `dp_ib_*` | data path → instruction buffer |
| `dp_id_*` | data path → ID 阶段内部 |
| `id_decd_instN_data` | ID 阶段译码后的 instN 数据包（178 位） |
| `id_expt_instN_data` | ID 阶段异常数据包（178 位） |
| `id_normal_instN_data` | 最终普通路径数据（decd 或 expt 二选一） |
| `id_split_long_instN_data` | split_long 输出第 N 条 µop（已覆盖异常） |
| `id_split_shortM_instN_data` | 第 M 路 split_short 输出第 N 条 µop |
| `split_long_dp_*` | split_long 子模块输出到 dp |
| `split_shortM_dp_*` | 第 M 路 split_short 子模块输出到 dp |
| `dp_id_pipedown_instN_data` | 最终向 IR 下发的第 N 条微操数据 |
| `dp_fence_id_*` | data path → fence 模块（ID 阶段） |
| `ctrl_dp_id_*` | control → data path（ID 阶段） |
| `dp_ctrl_id_*` | data path → control（ID 阶段） |
