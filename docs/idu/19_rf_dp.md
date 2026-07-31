# C910 IDU RF 数据通路（rf_dp）详解

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [操作数来源选择（PRF 读出 vs 前递）](#3-操作数来源选择prf-读出-vs-前递)
4. [各管线译码器全景](#4-各管线译码器全景)
5. [逐管线讲解](#5-逐管线讲解)
   - [pipe0_decd — ALU0 + 特殊/CSR](#51-pipe0_decd--alu0--特殊csr)
   - [pipe1_decd — ALU1 + 乘法](#52-pipe1_decd--alu1--乘法)
   - [pipe2_decd — BJU 分支](#53-pipe2_decd--bju-分支)
   - [pipe3_decd — LSU load / 地址生成](#54-pipe3_decd--lsu-load--地址生成)
   - [pipe4_decd — LSU store 地址](#55-pipe4_decd--lsu-store-地址)
   - [pipe5 数据通路（无 pipe5_decd）](#56-pipe5-数据通路无-pipe5_decd)
   - [pipe6_decd — VFPU pipe6（当前标量浮点，向量译码保留）](#57-pipe6_decd--vfpu-pipe6当前标量浮点向量译码保留)
   - [pipe7_decd — VFPU pipe7（当前标量浮点，向量控制保留）](#58-pipe7_decd--vfpu-pipe7当前标量浮点向量控制保留)
6. [立即数与操作数最终组装](#6-立即数与操作数最终组装)
7. [送往各执行单元的接口](#7-送往各执行单元的接口)
8. [特殊共享寄存器端口设计](#8-特殊共享寄存器端口设计)

---

## 1. 模块概述

**文件路径**：`C910_RTL_FACTORY/gen_rtl/idu/rtl/ct_idu_rf_dp.v`（4379 行）

`ct_idu_rf_dp`（RF Data Path）是 IDU（指令分发单元）流水线中 **RF（Register File Read）阶段**的核心数据通路模块。它在 IS 阶段（发射队列发射）和 EX 阶段（各执行单元执行）之间扮演数据汇聚与最终分发的角色。

> **当前有效配置边界**：本文件内部保留 `_vr0/_vr1`、VREG、VMLA、VDIV 等向量数据和控制网络，但当前 `ct_idu_id_decd.v` 的 `x_vec_inst=0`，`ct_cp0_regs.v` 的 `misa_vector=0`。更关键的是，`ct_idu_rf_dp` 模块端口表对 VFPU 只导出 pipe6/7 的标量 `_fr` 操作数，内部 `idu_vfpu_rf_pipe*_srcv*_vr0/vr1` 只是 wire，没有作为该模块 output 进入当前 `ct_idu_top`→VFPU 接口。因此，当前活跃路径是标量 F/D 浮点；下文 VR0/VR1、向量 mask 和向量功能码段落用于解释保留 RTL，不能描述成当前实例已经工作的 128 位 RVV 数据通路。

### 在流水线中的位置

```
   IS 阶段
  (AIQ/BIQ/LSIQ/SDIQ/VIQ 发射队列)
          |
          | issue_en + issue_read_data
          v
  +------------------+
  |   ct_idu_rf_dp   |  <-- RF 阶段
  |   (RF Data Path) |
  +------------------+
     |    |    |    |   |    |    |
     v    v    v    v   v    v    v
    IU   IU   IU   LSU LSU VFPU VFPU
   p0   p1   p2   p3  p4  p6   p7
  (ALU0)(ALU1)(BJU)(LD)(ST)(VP0)(VP1)
```

### 核心职责

| 职责 | 说明 |
|------|------|
| **管线寄存器** | 将发射队列读出的条目锁存到 RF 阶段寄存器（`rf_pipeX_data`） |
| **源操作数选择** | 根据 `_WB` 位在 PRF 读出数据与前递（forwarding）数据之间二选一 |
| **源操作数就绪检测** | 若指定源尚无法前递，产生 `src_no_rdy` 信号，通知控制路径撤销本次发射 |
| **RF 阶段译码** | 为每条执行管线调用独立的 `pipe_decd` 子模块，将操作码再次细化译码 |
| **操作数组装** | 将最终确定的数据（PRF 或前递）与立即数合并，送到执行单元 |
| **目的寄存器广播** | 复制目的物理寄存器编号（`dst_preg_dup0..4`），供前递网络比较 |

---

## 2. 端口说明

### 2.1 输入：来自各发射队列（Issue Queue）

每个发射队列（IQ）在发射时提供两类信息：

- **`xiq_xx_issue_en`**：本周期存在最终选中的发射项；在对应 RF 时钟沿锁存功能数据
- **`xiq_xx_gateclk_issue_en`**：RF 局部时钟活动请求，通常由比最终 issue 更宽松的
  “存在非冻结有效项/bypass gateclk”条件生成；RTL 没有定义它固定提前一个半周期
- **`xiq_dp_issue_entry`**：发射队列条目编号
- **`xiq_dp_issue_read_data`**：发射队列中该条目存储的全部信息（操作数就绪位、物理寄存器号、即时写回位、IID、操作码等）

各发射队列及其数据宽度：

| 发射队列 | 信号前缀 | 数据宽度 | 对应管线 |
|----------|----------|----------|----------|
| AIQ0（整数队列0） | `aiq0_` | 227 bit | pipe0 |
| AIQ1（整数队列1） | `aiq1_` | 214 bit | pipe1 |
| BIQ（分支队列） | `biq_`  | 82 bit  | pipe2 |
| LSIQ（访存队列） | `lsiq_` | 163 bit | pipe3/pipe4 |
| SDIQ（store 数据队列） | `sdiq_` | 27 bit | pipe5 |
| VIQ0（向量队列0） | `viq0_` | 151 bit | pipe6 |
| VIQ1（向量队列1） | `viq1_` | 150 bit | pipe7 |

### 2.2 输入：来自 PRF（物理寄存器堆）

PRF 读数据通过 `prf_*_rf_*` 接口进入 `rf_dp`。整数源为 64 位；pipe6/7 内部兼容网络分为 `_fr`、`_vr0`、`_vr1` 三类 64 位数据，其中 VR0/VR1 可组成保留的 128 位向量数据。当前顶层只把 `_fr` 操作数导出给 VFPU，所以不能把内部三类 wire 都视作当前有效执行接口。

```
// 示例：pipe0 整数读出
input [63:0] prf_dp_rf_pipe0_src0_data;
input [63:0] prf_dp_rf_pipe0_src1_data;

// pipe1 特殊：使用 prf_xx_rf_pipe1（时序优化，独立读端口）
input [63:0] prf_xx_rf_pipe1_src0_data;
input [63:0] prf_xx_rf_pipe1_src1_data;

// pipe6 向量读出（4 个源操作数，每个三路）
input [63:0] prf_dp_rf_pipe6_srcv0_vreg_fr_data;
input [63:0] prf_dp_rf_pipe6_srcv0_vreg_vr0_data;
input [63:0] prf_dp_rf_pipe6_srcv0_vreg_vr1_data;
// ...（srcv1, srcv2, srcvm 同理）
```

### 2.3 输入：来自前递网络（fwd）

`ct_idu_rf_fwd` 模块会在 RF 阶段实时比较当前执行中指令的目的寄存器与本条指令的源寄存器，若匹配则提供数据并清零 `_no_fwd` 标志：

- **`fwd_dp_rf_pipeX_srcY_data`**：前递数据（64 位）
- **`fwd_dp_rf_pipeX_srcY_no_fwd`**：1 表示此源无法前递（PRF 数据也尚未写回，发射失败）

### 2.4 输出：PRF 和 fwd 的物理寄存器索引

rf_dp 向 PRF 和前递模块输出当前 RF 阶段指令的物理寄存器编号，使两者能在同周期完成读取/比较：

```
output [6:0] dp_prf_rf_pipe0_src0_preg;   // 向 PRF 发出读地址
output [6:0] dp_fwd_rf_pipe0_src0_preg;   // 向前递网络发出比较地址
```

### 2.5 输出：目的寄存器（多副本）

```
output [6:0] dp_xx_rf_pipe0_dst_preg_dup0;  // dup0..dup4 五个副本
```

多副本把同一逻辑值分配给不同扇出网络，是常见的物理实现友好写法，可为综合/布局布线提供分散驱动负载的机会。RTL 能证明存在 5 份寄存副本；“单一驱动一定无法实现”或“已经满足目标时序”仍需网表、布局和 STA 结果支持。

### 2.6 输出：送执行单元

各管线向对应执行单元的输出：

| 前缀 | 目标 | 典型信号 |
|------|------|----------|
| `idu_iu_rf_pipe0_` | IU（ALU0/特殊） | `src0/src1/src2`, `func`, `rslt_sel`, `eu_sel` |
| `idu_iu_rf_pipe1_` | IU（ALU1/乘法） | 同上 + `mult_func`, `mla_src2_preg` |
| `idu_iu_rf_pipe2_` | IU（BJU） | `src0/src1`, `func`, `offset` |
| `idu_lsu_rf_pipe3_` | LSU（load） | `src0/src1`, `offset`, `inst_type/size` |
| `idu_lsu_rf_pipe4_` | LSU（store addr） | `src0/src1`, `fence_mode`, `sync_fence` 等 |
| `idu_lsu_rf_pipe5_` | LSU（store data） | `src0`, `srcv0_fr/vr0/vr1` |
| `idu_vfpu_rf_pipe6_` | VFPU pipe6 | 当前模块 output 包含标量 `srcv0/1/2_fr` 及控制；VR0/VR1 是内部保留 wire |
| `idu_vfpu_rf_pipe7_` | VFPU pipe7 | 同样以标量 `_fr` 输出为当前有效数据接口 |

---

## 3. 操作数来源选择（PRF 读出 vs 前递）

### 3.1 核心机制

发射队列中每个源操作数保存两个关键元数据：

- **`_VLD`**（Valid）：该源操作数是否存在（有些指令不使用全部源）
- **`_WB`**（Written Back）：在发射时，该物理寄存器是否**已经完成写回**到 PRF

发射时若 `_WB=1`，PRF 的读出结果在 RF 阶段即可直接使用；若 `_WB=0`，说明生产者指令还在执行管线中，需依赖前递网络。

```
// pipe0 src0 选择逻辑（行 2221-2230）
always @(fwd_dp_rf_pipe0_src0_data or prf_dp_rf_pipe0_src0_data
         or rf_pipe0_data[AIQ0_SRC0_WB])
begin
  if(rf_pipe0_data[AIQ0_SRC0_WB])
    rf_pipe0_src0_data = prf_dp_rf_pipe0_src0_data;  // PRF 已写回
  else
    rf_pipe0_src0_data = fwd_dp_rf_pipe0_src0_data;  // 依赖前递
end
```

### 3.2 三路操作数选择框图

```
         AIQ0_SRC0_WB
              |
    0 --------+-------- 1
    |                   |
    v                   v
fwd_src0_data    prf_src0_data
    \                   /
     \                 /
      +-- MUX 2选1 --+
              |
              v
      rf_pipe0_src0_data
              |
              v
      idu_iu_rf_pipe0_src0   --> IU
```

### 3.3 立即数注入（src1 特殊处理）

src1 有三种来源，通过三路 MUX 选择：

```
// pipe0 src1 选择逻辑（行 2243-2257）
always @(...)
begin
  if(!rf_pipe0_data[AIQ0_SRC1_VLD])
    rf_pipe0_src1_data = pipe0_decd_src1_imm;   // 立即数
  else if(rf_pipe0_data[AIQ0_SRC1_WB])
    rf_pipe0_src1_data = prf_dp_rf_pipe0_src1_data;  // PRF
  else
    rf_pipe0_src1_data = fwd_dp_rf_pipe0_src1_data;  // 前递
end
```

立即数由 RF 阶段译码器（`pipe0_decd`）从操作码中提取，在 RF 阶段才展开为完整的 64 位值。这样做的原因：IS 阶段只需存储压缩的操作码，在 RF 阶段解码出全宽立即数，节省发射队列存储面积。

### 3.4 src_no_rdy：发射撤销机制

若某个源既无法前递（`no_fwd=1`）又未写回 PRF（`WB=0`），则该指令必须撤销本次发射，等待下一周期：

```
// pipe0 就绪检测（行 2236-2238）
assign rf_pipe0_src0_no_rdy = rf_pipe0_data[AIQ0_SRC0_VLD]
                               && !rf_pipe0_data[AIQ0_SRC0_WB]
                               && fwd_dp_rf_pipe0_src0_no_fwd;

assign dp_ctrl_rf_pipe0_src_no_rdy = rf_pipe0_src0_no_rdy
                                     || rf_pipe0_src1_no_rdy
                                     || rf_pipe0_src2_no_rdy;
```

撤销时同时清除发射队列对应条目的就绪位（`dp_aiq0_rf_rdy_clr`），以便下一周期重新参与发射仲裁。

---

## 4. 各管线译码器全景

### 4.1 实例化位置汇总

| 实例名 | 模块名 | 行号 | 来源队列 | 对应执行单元 | 代码行数 |
|--------|--------|------|----------|-------------|---------|
| `x_ct_idu_rf_pipe0_decd` | `ct_idu_rf_pipe0_decd` | 2201 | AIQ0 | ALU0 + DIV + SPECIAL + CP0 | 734 |
| `x_ct_idu_rf_pipe1_decd` | `ct_idu_rf_pipe1_decd` | 2497 | AIQ1 | ALU1 + MULT | 673 |
| `x_ct_idu_rf_pipe2_decd` | `ct_idu_rf_pipe2_decd` | 2725 | BIQ  | BJU | 174 |
| `x_ct_idu_rf_pipe3_decd` | `ct_idu_rf_pipe3_decd` | 2949 | LSIQ | LSU load/AGU | 750 |
| `x_ct_idu_rf_pipe4_decd` | `ct_idu_rf_pipe4_decd` | 3176 | LSIQ | LSU store 地址 | 1507 |
| —（无 pipe5_decd）        | —                      | —    | SDIQ | LSU store 数据 | — |
| `x_ct_idu_rf_pipe6_decd` | `ct_idu_rf_pipe6_decd` | 3806 | VIQ0 | VFPU pipe6 | 1971 |
| `x_ct_idu_rf_pipe7_decd` | `ct_idu_rf_pipe7_decd` | 4213 | VIQ1 | VFPU pipe7 | 2036 |

### 4.2 为什么没有 pipe5_decd？

pipe5 是 **store data 路径**，对应 SDIQ（Store Data Issue Queue）。SDIQ 的数据结构极简（仅 27 位）：

```
// SDIQ 参数（行 1918-1936）
parameter SDIQ_WIDTH           = 27;
parameter SDIQ_STDATA1_VLD     = 23;  // 是否有第二个 store 数据
parameter SDIQ_UNALIGN         = 22;  // 非对齐
parameter SDIQ_SRCV0_LSU_MATCH = 21;  // 向量源操作数匹配 LSU
...
parameter SDIQ_SRC0_VLD        = 0;
```

SDIQ 存储的唯一任务是**把 store 数据（整数或向量）送到 LSU 的 store 数据缓冲**，不需要进一步的功能单元选择或复杂控制信号生成。store 的地址计算已经在 pipe4 完成，store 数据路径仅需：

1. 选择正确的源操作数（整数 `src0` 或向量 `srcv0_fr/vr0/vr1`）
2. 检查 store 地址是否已写入 store 队列（`staddr_no_rdy` 逻辑）
3. 处理非对齐合并

这些逻辑都内联在 `rf_dp` 中（行 3473-3527），不需要独立译码器。

### 4.3 共享门控时钟

rf_dp 使用多组局部门控时钟；相应 issue/gateclk 条件作为 `local_en` 请求寄存器更新：

```verilog
// pipe0 独立时钟
assign rf_pipe0_clk_en = aiq0_xx_gateclk_issue_en;

// pipe03 共享时钟（pipe0 的 src2 借用 pipe3 的 src1 读端口）
assign rf_pipe03_clk_en = lsiq_xx_gateclk_issue_en
                          || aiq0_xx_gateclk_issue_en;

// pipe15 共享时钟（pipe1 的 src2 借用 pipe5 的 src0 读端口）
assign rf_pipe15_clk_en = sdiq_xx_gateclk_issue_en
                          || aiq1_xx_gateclk_issue_en;
```

这些共享时钟域配合后文的地址寄存器复用，使不同管线在互斥/有优先级的条件下共用 PRF 读地址资源。例如 pipe0 src2 与 pipe3 src1、pipe1 src2 与 pipe5 src0 共用对应地址寄存路径。它提供减少独立读端口需求的结构基础；实际面积节省和门控行为还受 PRF 实现、全局/模块/扫描使能影响。

精确地说，上述 `*_clk_en` 都只是 `gated_clk_cell.local_en`。公共门控模型的功能使能为
`global_en && (module_en || local_en)`，扫描使能还可打开工艺 ICG；未定义
`C910_USE_TSMC28_ICG` 时当前 RTL 模型直接透传输入时钟。因此不能从某个
`*_gateclk_issue_en=0` 单独推出物理时钟已停止，也不能把该信号与 `issue_en` 解释为固定相差若干周期。

---

## 5. 逐管线讲解

### 5.1 pipe0_decd — ALU0 + 特殊/CSR

**功能单元**：ALU0（加减/移位/逻辑）、DIV（除法）、SPECIAL（AUIPC/ECALL/EBREAK/VSETVL 等）、CP0（CSR 操作）

#### pipe0 译码器端口

```verilog
// 输入（行 2201-2209）
ct_idu_rf_pipe0_decd x_ct_idu_rf_pipe0_decd (
  .pipe0_decd_eu_sel   (pipe0_decd_eu_sel  ),  // [3:0] 执行单元选择
  .pipe0_decd_expt_vld (pipe0_decd_expt_vld),  // 异常有效（强制发特殊）
  .pipe0_decd_func     (pipe0_decd_func    ),  // [4:0] 功能码
  .pipe0_decd_imm      (pipe0_decd_imm     ),  // [5:0] 移位立即数
  .pipe0_decd_opcode   (pipe0_decd_opcode  ),  // [31:0] 操作码（输入）
  .pipe0_decd_sel      (pipe0_decd_sel     ),  // [20:0] ALU 结果选择
  .pipe0_decd_src1_imm (pipe0_decd_src1_imm)   // [63:0] 展开的立即数
);
```

#### 执行单元编码

```verilog
parameter ALU     = 4'b0001;  // 普通整数运算
parameter DIV     = 4'b0010;  // 除法
parameter SPECIAL = 4'b0100;  // 特殊指令（AUIPC/系统调用/向量配置）
parameter CP0     = 4'b1000;  // CSR 读写
```

#### ALU 结果选择（rslt_sel，21 位 one-hot）

```verilog
parameter ADDER_ADD   = 21'h000001;  // 加法
parameter ADDER_ADDW  = 21'h000002;  // 加法（32位）
parameter ADDER_SUB   = 21'h000004;  // 减法
parameter ADDER_SUBW  = 21'h000008;  // 减法（32位）
parameter ADDER_SLT   = 21'h000010;  // 有符号比较
parameter SHIFTER_SL  = 21'h000020;  // 左移
parameter SHIFTER_SR  = 21'h000040;  // 右移
parameter LOGIC_AND   = 21'h000400;  // 与
parameter LOGIC_OR    = 21'h000800;  // 或
parameter LOGIC_XOR   = 21'h001000;  // 异或
parameter LOGIC_LUI   = 21'h002000;  // 加载高位立即数
parameter MISC_MV     = 21'h008000;  // 寄存器移动
...
```

这个 21 位 one-hot 结果选择编码允许下游用按位资格信号组织候选结果选择，避免在执行端再次做紧凑编码译码。它通常有利于并行选择，但位宽、布线和扇出也会产生代价；是否缩短关键路径必须以综合和 STA 为准。

#### 特殊情况：异常优先

```verilog
// 行 194-209
if(decd_expt_vld) begin
  pipe0_decd_eu_sel = SPECIAL;  // 强制路由到特殊处理单元
  pipe0_decd_func   = SPECIAL_NOP;
  pipe0_decd_sel    = NON_ALU;
end
```

当 IS 阶段已检测到该指令带有异常标记（如非法指令异常），RF 阶段不做实际运算，直接交给特殊指令路径处理。

#### 特殊指令 func 编码

```verilog
parameter SPECIAL_NOP          = 5'b00000;
parameter SPECIAL_ECALL        = 5'b00010;
parameter SPECIAL_EBREAK       = 5'b00011;
parameter SPECIAL_AUIPC        = 5'b00100;
parameter SPECIAL_PSEUDO_AUIPC = 5'b00101;
parameter SPECIAL_VSETVLI      = 5'b00110;  // 向量配置（立即数 vl）
parameter SPECIAL_VSETVL       = 5'b00111;  // 向量配置（寄存器 vl）
```

译码表保留 VSETVL/VSETVLI 对应的 pipe0 SPECIAL 功能码；若向量功能启用，这类指令会更新 VL/VTYPE 状态。当前 `x_vec_inst=0`、`misa_vector=0`，不能把该保留功能码描述成当前配置可执行的有效 VSETVL 路径。

#### src2（第三操作数）：跨管线借用

pipe0 支持最多三个源操作数（如某些扩展指令）。src2 没有独立的 PRF 读端口，而是**借用 pipe3（访存管线）的 src1 读端口**：

```verilog
// 行 2270-2276
assign rf_pipe0_src2_data = rf_pipe0_data[AIQ0_SRC2_WB]
                            ? prf_dp_rf_pipe3_src1_data   // 借用 pipe3 的 PRF 数据
                            : fwd_dp_rf_pipe3_src1_data;  // 借用 pipe3 的前递数据

assign rf_pipe0_src2_no_rdy = rf_pipe0_data[AIQ0_SRC2_VLD]
                               && !rf_pipe0_data[AIQ0_SRC2_WB]
                               && fwd_dp_rf_pipe3_src1_no_fwd;
```

这里使用 `rf_pipe03_clk` 驱动共享地址寄存器。更新 always 块对 pipe0 src2 和 pipe3 src1 请求有显式优先级，RF 控制还会在同时争用时让低优先级路径 launch fail；正确性来自“优先级 + 冲突检测 + 重调度”的组合，而不是共享时钟本身自动保证。

#### 输出到 CP0

```verilog
// 行 2320-2325
assign idu_cp0_rf_iid[6:0]    = rf_pipe0_data[AIQ0_IID:AIQ0_IID-6];
assign idu_cp0_rf_opcode[31:0] = rf_pipe0_data[AIQ0_OPCODE:AIQ0_OPCODE-31];
assign idu_cp0_rf_preg[6:0]   = rf_pipe0_data[AIQ0_DST_PREG:AIQ0_DST_PREG-6];
assign idu_cp0_rf_src0[63:0]  = rf_pipe0_src0_data_no_fwd;  // 不含前递
assign idu_cp0_rf_func[4:0]   = pipe0_decd_func[4:0];
```

`idu_cp0_rf_src0` 的确连接 `rf_pipe0_src0_data_no_fwd`。该信号只在 `had_idu_wbbr_vld` 时选择 HAD WBBR 数据，否则选择 PRF 读数据：

```verilog
// 行 2232-2234
assign rf_pipe0_src0_data_no_fwd = (had_idu_wbbr_vld)
                                   ? had_idu_wbbr_data   // HAD 写回路径
                                   : prf_dp_rf_pipe0_src0_data;
```

RTL 能直接证明 CP0 接口没有使用普通 `fwd_dp_rf_pipe0_src0_data` MUX；至于设计动机是 CSR 稳定性、调试覆盖还是其他协议约束，需规格说明支持。也不能据此说“未写回时 CP0 仍可安全使用旧 PRF 值”：源 ready/launch 条件仍必须由控制和依赖逻辑保证。

---

### 5.2 pipe1_decd — ALU1 + 乘法

**功能单元**：ALU1（与 ALU0 等价的第二整数 ALU）、MULT（乘法器）

#### 执行单元编码（2 位）

```verilog
parameter ALU  = 2'b01;
parameter MULT = 2'b10;
```

pipe1 只用 2 位 eu_sel（vs pipe0 的 4 位），因为它不需要 DIV 和 CP0 路径。

#### mult_func 乘法功能码（8 位）

pipe1 特有的 `pipe1_decd_mult_func[7:0]` 编码区分所有乘法变体：

```verilog
// 行 144-155（ct_idu_rf_pipe1_decd.v）
assign decd_mult_mula_muls     = ({decd_op[27:26],decd_op[4]} == 3'b0);

assign pipe1_decd_mult_func[0] = (decd_op[13:12] != 2'b00) && decd_op[4]; // mulh/mulhsu/mulhu
assign pipe1_decd_mult_func[1] = decd_op[3] && !decd_mult_mula_muls;       // mulw
assign pipe1_decd_mult_func[2] = ...;  // mulw 或 mulhu
assign pipe1_decd_mult_func[3] = ...;
assign pipe1_decd_mult_func[4] = decd_op[27];   // mula/muls 变体选择
assign pipe1_decd_mult_func[5] = !decd_op[4];   // 32/64 位区分
assign pipe1_decd_mult_func[6] = decd_mult_mula_muls;   // multiply-accumulate
assign pipe1_decd_mult_func[7] = decd_op[25] && !decd_op[4]; // 有符号位
```

支持的乘法指令：`mul`, `mulh`, `mulhsu`, `mulhu`, `mulw`（标准 RV64M），以及 C910 扩展的 `mula`（multiply-accumulate）、`muls`（multiply-subtract）、`mulaw`/`mulsw`（32位 MAC）、`mulah`/`mulsh`（高半字 MAC）。

#### MLA（Multiply-Accumulate）特殊处理

乘累加指令（mula/muls）需要三个源操作数：乘数 src0、被乘数 src1、累加数 src2。src2 同样借用 pipe5 的 src0 读端口：

```verilog
// 行 2561-2567
assign rf_pipe1_src2_data = rf_pipe1_data[AIQ1_SRC2_WB]
                            ? prf_dp_rf_pipe5_src0_data   // 借用 pipe5
                            : fwd_dp_rf_pipe5_src0_data;

assign rf_pipe1_src2_no_rdy = rf_pipe1_data[AIQ1_SRC2_VLD]
                               && !rf_pipe1_data[AIQ1_SRC2_WB]
                               && fwd_dp_rf_pipe5_src0_no_fwd;
```

注意：使用 `rf_pipe15_clk` 共享时钟，并且当 `rtu_idu_flush_fe || rtu_idu_flush_is` 时**不**允许 pipe1 写入 pipe5 的共享寄存器（防止 flush 后脏数据污染 store data 路径）：

```verilog
// 行 3376-3387
else if(rf_pipe1_prf_src2_preg_updt_vld
        && !(rtu_idu_flush_fe || rtu_idu_flush_is))
  rf_pipe5_prf_src0_preg <= aiq1_dp_issue_read_data[AIQ1_SRC2_PREG:...];
else if(rf_pipe5_prf_src0_preg_updt_vld)
  rf_pipe5_prf_src0_preg <= sdiq_dp_issue_read_data[SDIQ_SRC0_PREG:...];
```

#### mla_src2 寄存器编号广播

```verilog
assign idu_iu_rf_pipe1_mla_src2_preg[6:0] = rf_pipe1_data[AIQ1_SRC2_PREG:AIQ1_SRC2_PREG-6];
assign idu_iu_rf_pipe1_mla_src2_vld       = rf_pipe1_data[AIQ1_MLA];
```

IU 收到这两个信号后，可在 MLA 完成后将积累结果重新写入 src2 对应的物理寄存器。

---

### 5.3 pipe2_decd — BJU 分支

**功能单元**：BJU（Branch Jump Unit）

该译码器共 174 行，功能范围集中在分支和跳转路径。代码行数只用于说明阅读规模；是否是物理上“最简单”的模块仍需看综合逻辑。

#### pipe2 译码器端口

```verilog
ct_idu_rf_pipe2_decd x_ct_idu_rf_pipe2_decd (
  .pipe2_decd_func     (pipe2_decd_func    ),  // [7:0] 分支类型
  .pipe2_decd_offset   (pipe2_decd_offset  ),  // [20:0] 跳转偏移（签名展开）
  .pipe2_decd_opcode   (pipe2_decd_opcode  ),  // [31:0] 操作码（输入）
  .pipe2_decd_src1_imm (pipe2_decd_src1_imm)   // [63:0] 恒为0（BJU 不使用立即数作 src1）
);
```

注意：`pipe2_decd_src1_imm` 在 RTL 中固定为 `64'b0`，表示 BJU 的 src1 永远来自寄存器（用于比较），偏移量通过独立的 `offset` 信号传递。

#### 分支类型编码（8 位 one-hot）

```verilog
// 16 位压缩指令
10'b101???_??01: decd_16_func = 8'b01_000000;  // c.j    无条件跳转
10'b110???_??01: decd_16_func = 8'b00_100000;  // c.beqz 等于零跳转
10'b111???_??01: decd_16_func = 8'b00_010000;  // c.bnez 不等零跳转
10'b1000??_??10: decd_16_func = 8'b10_000000;  // c.jr   间接跳转
10'b1001??_??10: decd_16_func = 8'b10_000000;  // c.jalr 带链接间接跳转

// 32 位标准指令
15'b??????????11011: func = 8'b01000000;  // jal
15'b???????00011001: func = 8'b10000000;  // jalr
15'b???????00011000: func = 8'b00100000;  // beq
15'b???????00111000: func = 8'b00_010000; // bne
15'b???????10011000: func = 8'b00001000;  // blt
15'b???????10111000: func = 8'b00000010;  // bge
15'b???????11011000: func = 8'b00000100;  // bltu
15'b???????11111000: func = 8'b00000001;  // bgeu
```

#### 偏移量提取

针对不同格式（J-type、B-type、JALR 等）的偏移量从操作码中各取不同 bit：

```verilog
// JAL：imm[20|10:1|11|19:12]<<1（20 位有符号）
6'h01: offset = {decd_op[31], decd_op[19:12], decd_op[20], decd_op[30:21], 1'b0};
// JALR：imm[11:0]（12 位有符号）
6'h02: offset = {{9{decd_op[31]}}, decd_op[31:20]};
// BEQ/BNE 等：imm[12|10:5|4:1|11]<<1（13 位有符号）
6'h04: offset = {{8{decd_op[31]}}, decd_op[31], decd_op[7], decd_op[30:25], decd_op[11:8], 1'b0};
```

#### 附加信息（直通字段）

```verilog
assign idu_iu_rf_pipe2_length  = rf_pipe2_data[BIQ_LENGTH];  // 指令长度（16/32 bit）
assign idu_iu_rf_pipe2_pid     = rf_pipe2_data[BIQ_PID:BIQ_PID-4]; // 管线 ID
assign idu_iu_rf_pipe2_rts     = rf_pipe2_data[BIQ_RTS];   // return stack pop
assign idu_iu_rf_pipe2_pcall   = rf_pipe2_data[BIQ_PCALL]; // push call stack
```

BJU 需要 `rts`/`pcall` 信息来更新返回地址栈（RAS）。

---

### 5.4 pipe3_decd — LSU load / 地址生成

**功能单元**：LSU load 端（包括普通 load、原子 load、浮点 load）

#### pipe3 译码器端口

```verilog
ct_idu_rf_pipe3_decd x_ct_idu_rf_pipe3_decd (
  .pipe3_decd_atomic       (),  // 是否原子操作
  .pipe3_decd_inst_fls     (),  // float load store
  .pipe3_decd_inst_ldr     (),  // 是否 ldr 类（偏移寄存器寻址）
  .pipe3_decd_inst_size    (),  // [1:0] 访存宽度：BYTE/HALF/WORD/DWORD
  .pipe3_decd_inst_type    (),  // [1:0] 类型：普通/原子/向量
  .pipe3_decd_lsfifo       (),  // 是否使用 LS FIFO（有序访存）
  .pipe3_decd_off_0_extend (),  // 偏移量是否做 0 扩展（无符号）
  .pipe3_decd_offset       (),  // [11:0] 地址偏移量
  .pipe3_decd_offset_plus  (),  // [12:0] 偏移量+1（非对齐预加）
  .pipe3_decd_opcode       (),  // 输入操作码
  .pipe3_decd_shift        (),  // [3:0] 偏移移位量（ldr 指令用）
  .pipe3_decd_sign_extend  ()   // 符号位扩展标志
);
```

#### 访存指令分类

```
inst_type[1:0]:
  2'b00 = 普通 load（lb/lh/lw/ld/lbu/lhu/lwu）
  2'b01 = 原子 LR（lr.w / lr.d）
  2'b10 = 向量 load（vle8/vle16/vle32/vle64 等）

inst_size[1:0]:
  BYTE(2'b00) / HALF(2'b01) / WORD(2'b10) / DWORD(2'b11)
```

#### 原子操作解码

```verilog
// lr.w（行 209-222）
32'b00010??00000?????010?????0101111: begin
  pipe3_decd_atomic    = 1'b1;
  pipe3_decd_inst_type = 2'b01;  // 原子
  pipe3_decd_inst_size = 2'b10;  // WORD
  pipe3_decd_offset    = 12'b0;  // 原子无偏移
  pipe3_decd_lsfifo    = 1'b0;   // 原子不走该 LS FIFO 模式
end

// amoswap.w / amoadd.w / ... （行 224-244）
32'b00001????????????010?????0101111,  // amoswap.w
32'b00000????????????010?????0101111,  // amoadd.w
// ...
```

这些原子操作的译码将 `lsfifo` 置 0，说明它们不走该 LS FIFO 模式。原子性和内存顺序不能由这一位单独“确保”，还依赖 LSU 的原子状态机、LQ/SQ/WMB、Cache/总线事务及退休约束。

#### 保留的向量 load 解码

pipe3 decode 表中保留向量 load 编码，匹配时 `inst_type=2'b10` 并使用 VREG 目的字段。当前向量总译码关闭，因此这是保留能力说明，不是当前有效指令流。

#### Boundary 路径的 `offset + 0x10` 预计算

```verilog
// 实际 RTL：12 位 offset 符号扩展到 13 位后加 0x10
assign pipe3_decd_offset_plus[12:0]
       = {pipe3_decd_offset[11], pipe3_decd_offset[11:0]} + 13'h10;
```

该值不是 `offset+1`，也不能解释为“cache line 地址加 1”。在 `ct_lsu_ld_ag.v` 中，`ld_ag_va_plus = base + sign_extend(offset_plus)`，并且只在

```text
ld_ag_boundary_unmask && ld_ag_ld_inst && !ld_ag_secd && !ld_ag_inst_ldr
```

时由 `ld_ag_va_plus_sel` 选中；其他情况使用普通 `base + shifted_offset`。因此它是特定首段 boundary load 的 `offset+16 byte` 地址候选。为何边界步长为 16 字节要结合 LSU boundary 拆分规则理解，不能误写成 64 B cache line 或统一的第二次访问地址。把加法放在译码侧可能缩短 AG 侧某些组合路径，但实际时序收益仍需 STA 验证。

#### src3（mask 向量寄存器 srcvm）

保留向量 load 格式还包含 mask 源 `srcvm`。pipe3 内部为其保留源路径：

```verilog
// 行 2976-2981
assign rf_pipe3_srcvm_vr0_data = rf_pipe3_data[LSIQ_SRCVM_WB]
                                  ? prf_dp_rf_pipe6_srcv2_vreg_vr0_data  // 借用 pipe6 srcv2 读端口
                                  : fwd_dp_rf_pipe3_srcvm_vreg_vr0_data;
```

这里 srcvm 的 PRF 数据也是借用 pipe6 的读端口（`prf_dp_rf_pipe6_srcv2`），体现了读端口共享。

---

### 5.5 pipe4_decd — LSU store 地址

**功能单元**：LSU store 地址端（包括普通 store、fence、sfence.vma、AMO 写端、向量 store 地址）

pipe4_decd 覆盖普通 store、SC/AMO 相关控制、FENCE/FENCE.I、SFENCE.VMA、非对齐处理以及保留向量 store 字段，功能分支较多。源代码行数可以帮助定位阅读范围，但不能作为面积、逻辑深度或“最复杂”排序的证据；这些结论应由综合统计和 STA 给出。

#### 独特的输入：CP0 广播控制

```verilog
ct_idu_rf_pipe4_decd x_ct_idu_rf_pipe4_decd (
  .cp0_lsu_fencei_broad_dis  (),  // 是否禁用 FENCE.I 广播
  .cp0_lsu_fencerw_broad_dis (),  // 是否禁用 FENCE.RW 广播
  .cp0_lsu_tlb_broad_dis     (),  // 是否禁用 TLB 广播
  .pipe4_decd_dst_preg       (),  // 目的物理寄存器（SC 指令需要）
  ...
);
```

这是 pipe4 独有的：fence 类指令的广播行为可被 CP0 动态关闭（例如在核间通信不必要时）。

#### 关键控制信号

| 信号 | 含义 |
|------|------|
| `pipe4_decd_st` | 是否为 store 操作（非 fence/sc） |
| `pipe4_decd_atomic` | 是否原子（SC.W/SC.D） |
| `pipe4_decd_sync_fence` | 同步屏障（FENCE.TSO 等） |
| `pipe4_decd_icc` | instruction cache coherence（SC 写成功时触发 I$ 失效） |
| `pipe4_decd_mmu_req` | 是否需要 MMU 地址翻译 |
| `pipe4_decd_inst_flush` | 是否冲刷 I$ (FENCE.I) |
| `pipe4_decd_inst_share` | 是否共享内存（AMO 强序） |
| `pipe4_decd_inst_mode` | 访存模式（普通/原子/向量） |
| `pipe4_decd_fence_mode` | 屏障模式（4 位，标识 pred/succ） |

#### FENCE 指令广播控制逻辑

```verilog
// 行 134-139（pipe4_decd）
assign fence_mode_sel = (decd_op[27] || decd_op[25] || decd_op[23] || decd_op[21])
                        ? 4'b1111   // FENCE.TSO 或有非标准 pred/succ：全广播
                        : 4'b1100;  // 标准 FENCE：仅广播 RW
```

#### SC（Store Conditional）特殊处理

```verilog
// sc.w（行 272-293）
32'b00011????????????010?????0101111: begin
  pipe4_decd_atomic    = 1'b1;
  pipe4_decd_icc       = pipe4_decd_dst_preg[6];  // 目的寄存器高位决定
  pipe4_decd_st        = 1'b1;
  pipe4_decd_mmu_req   = 1'b1;
  pipe4_decd_inst_mode = pipe4_decd_dst_preg[5:4]; // 编码在目的寄存器中
  pipe4_decd_fence_mode= pipe4_decd_dst_preg[3:0];
  ...
end
```

SC 指令的 aq/rl 位（获取/释放语义）被编码在译码时提前保存的目的物理寄存器编号的高几位中（这是 IS 阶段为了节省 LSIQ 条目面积的设计）。

#### store 地址偏移量

store 指令（S-type）的偏移量格式与 load（I-type）不同：

```verilog
// sb/sh/sw/sd 偏移量：imm[11:5|4:0] 分布在 inst[31:25] 和 [11:7]
pipe4_decd_offset = {decd_op[31:25], decd_op[11:7]};
```

#### SFENCE.VMA 模式

```verilog
// 行 144-156（pipe4_decd）
if(rs1_is_zero && rs2_is_zero)   sfence_inst_mode = 2'b00;  // 全 TLB flush
else if(rs1_is_zero)              sfence_inst_mode = 2'b01;  // ASID 级 flush
else if(rs2_is_zero)              sfence_inst_mode = 2'b10;  // VA 级 flush
else                              sfence_inst_mode = 2'b11;  // VA+ASID 精确 flush
```

根据 SFENCE.VMA 的 rs1（VA）和 rs2（ASID）是否为 x0，决定 TLB 刷新的粒度，影响 TLB 广播范围。

---

### 5.6 pipe5 数据通路（无 pipe5_decd）

**功能单元**：LSU store 数据（将数据写入 store 队列）

pipe5 从 SDIQ（Store Data Issue Queue）发射，仅包含数据操作数信息，没有独立译码器。

#### 核心逻辑：staddr_no_rdy（store 地址就绪检测）

```verilog
// 行 3477-3490
// staddr 已在 store 队列中
assign rf_pipe5_staddr_in_stq = !rf_pipe5_data[SDIQ_STDATA1_VLD]
                                  && rf_pipe5_data[SDIQ_STADDR0_IN_STQ]
                               || rf_pipe5_data[SDIQ_STDATA1_VLD]
                                  && rf_pipe5_data[SDIQ_STADDR1_IN_STQ];

// staddr 指令此时正由 pipe4 写入 store 队列（LSU dc 信号）
assign rf_pipe5_staddr_create_stq = lsu_idu_dc_staddr_vld
                                    && (lsu_idu_dc_sdiq_entry == dp_sdiq_rf_lch_entry)
                                    && (lsu_idu_dc_staddr1_vld == rf_pipe5_data[SDIQ_STDATA1_VLD]);

// 若 staddr 尚未在队列中，store data 不能执行
assign rf_pipe5_staddr_no_rdy = !(rf_pipe5_data[SDIQ_LOAD]
                                  || rf_pipe5_staddr_in_stq
                                  || rf_pipe5_staddr_create_stq);
```

这段逻辑把 store-data 的放行条件限定为三类之一：该项是特殊的 `SDIQ_LOAD`，
匹配的 staddr 已由 `STADDR*_IN_STQ` 状态确认在 STQ 中，或者 LSU DC 本拍正在以
相同 `sdiq_entry` 和 data-half 标志创建该 staddr。因而普通 store-data 不能在
没有匹配地址进展证明时先行；但它不一定要多等一个完整周期到地址“早已在 STQ”，
`rf_pipe5_staddr_create_stq` 明确允许与地址的 DC 创建事件同拍衔接。最终 LSU
是否接收还受 pipe5 launch-valid、stall、取消和下游队列条件约束，本方程只定义
地址就绪这一项。

#### 非对齐处理

```verilog
assign rf_pipe5_unalign_with_lsu_dc = rf_pipe5_data[SDIQ_UNALIGN]
                                      || rf_pipe5_staddr_create_stq
                                         && lsu_idu_dc_staddr_unalign;
```

当 store address 因非对齐被拆分时，store data 也需要知道这一事实以进行正确的数据拆分。

#### FREG/VREG 兼容的 store-data 通道

```verilog
assign idu_lsu_rf_pipe5_srcv0_fr[63:0]  = rf_pipe5_srcv0_fr_data;   // 浮点标量部分
assign idu_lsu_rf_pipe5_srcv0_vr0[63:0] = rf_pipe5_srcv0_vr0_data;  // 向量低 64 位
assign idu_lsu_rf_pipe5_srcv0_vr1[63:0] = rf_pipe5_srcv0_vr1_data;  // 向量高 64 位
assign idu_lsu_rf_pipe5_srcv0_vld        = rf_pipe5_data[SDIQ_SRCV0_VLD];
assign idu_lsu_rf_pipe5_srcv0_fr_vld     = !rf_pipe5_data[SDIQ_SRCV0_VREG]; // 1=标量浮点
```

`srcv0_fr_vld` 区分标量浮点 FREG 数据与保留 VREG 数据。当前标量浮点 store 使用 64 位 `fr`；内部 VR0/VR1 可以表示两个 64 位向量片段，但当前 RVV 译码关闭，不能把它们写成正在工作的 128 位向量 store 接口。

---

### 5.7 pipe6_decd — VFPU pipe6（当前标量浮点，向量译码保留）

**功能单元**：VFPU pipe6。当前有效配置执行标量 F/D 浮点；模块中仍保留向量功能码和数据字段。

译码器包含标准 F/D 标量浮点分支以及大量保留向量编码。代码中出现某种编码不等于当前配置支持“V 扩展全部运算”：上游向量总判定被固定关闭，且当前顶层未把 VR0/VR1 操作数导出到 VFPU。

#### pipe6 译码器端口

```verilog
ct_idu_rf_pipe6_decd x_ct_idu_rf_pipe6_decd (
  .pipe6_decd_eu_sel      (),  // [11:0] 执行单元选择（12 位 one-hot）
  .pipe6_decd_func        (),  // [19:0] 功能码（20 位）
  .pipe6_decd_imm0        (),  // [2:0] 浮点舍入模式（RM）
  .pipe6_decd_inst_type   (),  // [5:0] 指令类型（标量/向量，精度）
  .pipe6_decd_opcode      (),  // 操作码（输入）
  .pipe6_decd_oper_size   (),  // [2:0] 操作数精度（half/single/double）
  .pipe6_decd_ready_stage (),  // [2:0] 结果就绪阶段（1/2/3 级流水）
  .pipe6_decd_vimm        ()   // [4:0] 向量立即数
);
// 还有 vsew[1:0] 作为输入（向量元素宽度）
```

#### 执行单元选择（12 位，5+7 位划分）

```verilog
// 标量浮点执行单元（5 位 one-hot，行 116-129）
parameter FSPU  = 5'b00001;  // FP Special Unit（fmv/fsgnj/fclass）
parameter FADD  = 5'b00010;  // FP Adder
parameter FCNVT = 5'b00100;  // FP Converter
parameter FDSU  = 5'b01000;  // FP Divide/Sqrt
parameter FMAU  = 5'b10000;  // FP Multiply-Accumulate

// 保留的向量执行单元编码（7 位，位于 eu_sel[11:5]）
```

#### 功能码编码（20 位）

pipe6/pipe7 的 func 是精心设计的位字段，例如 FDIV/FSQRT：

```verilog
// FDIV/FSQRT（行 146-156）
// [19:17] = 精度（010=half, 001=single, 011=double, 000=向量）
// [1:0]   = 操作（01=div, 10=sqrt）
parameter FDIVH  = 20'b0010_00000000000000_01;  // half div
parameter FSQRTH = 20'b0010_00000000000000_10;  // half sqrt
parameter FDIVS  = 20'b0010_10000000000000_01;  // single div
parameter FSQRTS = 20'b0010_10000000000000_10;  // single sqrt
parameter FDIVD  = 20'b0011_00000000000000_01;  // double div
parameter FSQRTD = 20'b0011_00000000000000_10;  // double sqrt
```

向量 FP 加法器的 func（行 228-250）：
```verilog
parameter VFADD    = 20'b0000_0001_0000_0000_0000;
parameter VFSUB    = 20'b0000_0000_1000_0000_0000;
parameter VFWADD   = 20'b0000_0111_0000_0000_0000;  // widen add
parameter VFMIN    = 20'b0000_0000_0001_0000_0000;
parameter VFMAX    = 20'b0000_0000_0010_0000_0000;
parameter VFEQ     = 20'b0000_0000_0100_0000_0001;  // compare equal
parameter VFLT     = 20'b0000_0000_0100_0000_0010;  // compare less than
parameter VFLE     = 20'b0000_0000_0100_0000_0100;  // compare less-equal
parameter VFREDSUM = 20'b0000_0001_0000_0000_0010;  // reduction sum
```

#### ready_stage（结果就绪阶段）

```verilog
// pipe6_decd_ready_stage[2:0]：指示该指令结果几拍后可用
// 3'b001 = 1 级流水（简单操作如 fmv）
// 3'b010 = 2 级流水（fadd）
// 3'b100 = 多级流水（fmul/fmadd/fdiv）
```

该信号告知 VFPU 和前递网络何时可以将结果回送，是 VFPU 内部流水线调度的关键信息。

#### 操作数精度（inst_type/oper_size）

```verilog
// inst_type[5:0] = {3'b0, scalar_size[2:0]}
// oper_size[2:0] = scalar_size[2:0]
// scalar_size[2] = 1  表示 half 精度（16 位）
// scalar_size[1] = 1  表示 single 精度（32 位）
// scalar_size[0] = 1  表示 double 精度（64 位）

assign decd_scalar_size = {(decd_op[26:25] == 2'b10),  // half
                           (decd_op[26:25] == 2'b00),  // single
                           (decd_op[26:25] == 2'b01)}; // double
```

#### 内部保留的向量源操作数 MUX

pipe6 有 4 个向量源操作数（srcv0/srcv1/srcv2/srcvm），每个都分三路（fr/vr0/vr1）：

```verilog
// 行 3825-3857
// 每路：WB 位决定来自 PRF 还是前递
assign rf_pipe6_srcv0_fr_data  = rf_pipe6_data[VIQ0_SRCV0_WB]
                                  ? prf_dp_rf_pipe6_srcv0_vreg_fr_data
                                  : fwd_dp_rf_pipe6_srcv0_vreg_fr_data;
assign rf_pipe6_srcv0_vr0_data = rf_pipe6_data[VIQ0_SRCV0_WB]
                                  ? prf_dp_rf_pipe6_srcv0_vreg_vr0_data
                                  : fwd_dp_rf_pipe6_srcv0_vreg_vr0_data;
assign rf_pipe6_srcv0_vr1_data = rf_pipe6_data[VIQ0_SRCV0_WB]
                                  ? prf_dp_rf_pipe6_srcv0_vreg_vr1_data
                                  : fwd_dp_rf_pipe6_srcv0_vreg_vr1_data;
// srcv1、srcv2、srcvm 使用类似的 PRF/forward 选择模式，字段和用途并非完全相同
```

源码内部形成多组 64 位候选 MUX，包含 `_fr/_vr0/_vr1`。其中只有 `_fr` 是当前模块到 VFPU 的 output；“逻辑最宽”若用于物理比较仍需综合后的位宽、裁剪结果和面积报告支持。

#### 源不就绪判断（4 路）

```verilog
// 行 3859-3870
assign rf_pipe6_srcv0_no_rdy = rf_pipe6_data[VIQ0_SRCV0_VLD]
                               && !rf_pipe6_data[VIQ0_SRCV0_WB]
                               && fwd_dp_rf_pipe6_srcv0_no_fwd;
// srcv1, srcv2, srcvm 同理
assign dp_ctrl_rf_pipe6_src_no_rdy = rf_pipe6_srcv0_no_rdy
                                     || rf_pipe6_srcv1_no_rdy
                                     || rf_pipe6_srcv2_no_rdy
                                     || rf_pipe6_srcvm_no_rdy;
```

#### srcvm 与 srcv2 的共享寄存器设计

srcv2（第三向量操作数，用于 FMA = fused multiply-add）和 srcvm（mask 寄存器）的 PRF 读端口被 pipe3 的 srcvm 借用（同样用 `rf_pipe36_clk` 共享时钟，行 3684-3706）：

```verilog
// pipe6 srcv2 的 PRF 地址寄存器（rf_pipe36_clk）
always @(posedge rf_pipe36_clk ...) begin
  if(rf_pipe6_prf_srcv2_vreg_updt_vld)        // 来自 VIQ0
    rf_pipe6_prf_srcv2_vreg_fr <= viq0...[VIQ0_SRCV2_VREG-1:...];
  else if(rf_pipe3_prf_srcvm_vreg_updt_vld)   // 来自 LSIQ pipe3 借用
    rf_pipe6_prf_srcv2_vreg_fr <= lsiq_dp_pipe3...[LSIQ_SRCVM_VREG-1:...];
```

#### 保留的向量 FMA（vmla）类型

```verilog
assign idu_vfpu_rf_pipe6_mla_srcv2_vreg[6:0] = rf_pipe6_data[VIQ0_SRCV2_VREG:...];
assign idu_vfpu_rf_pipe6_mla_srcv2_vld       = rf_pipe6_data[VIQ0_SRCV2_VLD];
assign idu_vfpu_rf_pipe6_vmla_type[2:0]      = rf_pipe6_data[VIQ0_VMLA_TYPE:...];
assign idu_vfpu_rf_pipe6_split_num[6:0]      = rf_pipe6_data[VIQ0_SPLIT_NUM:...];
```

在保留 VMLA 格式中，目的寄存器可同时作为累加源，`vmla_type` 区分 FMA 变体，`split_num` 标识拆分片序号。当前 RVV 关闭且 VR0/VR1 未导出到 VFPU，因此这些字段不构成当前有效向量 FMA 数据通路。

---

### 5.8 pipe7_decd — VFPU pipe7（当前标量浮点，向量控制保留）

**功能单元**：VFPU pipe7。

pipe7 与 pipe6 共享 VIQ→RF→VFPU 的基本数据格式和译码框架，但不能概括为完全对称：VIQ 宽度、VDIV/VMUL-unsplit 属性、共享端口和冲突控制不同。当前两路 VIQ 也承载标量浮点；内部四源向量网络属于保留结构。

#### pipe7 与 pipe6 的关键差异

| 特性 | pipe6 (VIQ0) | pipe7 (VIQ1) |
|------|-------------|-------------|
| 发射队列宽度 | 151 位 | 150 位 |
| VIQ 独有字段 | `VDIV`（向量除法标记，行 1946） | `VMUL_UNSPLIT`（向量乘法未拆分标记，行 1997） |
| 控制信号 | `dp_ctrl_rf_pipe6_vmul` | `dp_ctrl_rf_pipe7_vmul_unsplit` |
| srcvm PRF 共享 | 借用 pipe3 srcvm（`rf_pipe36_clk`） | 借用 pipe4 srcvm（`rf_pipe47_clk`） |

```verilog
// pipe7 特有：
assign dp_ctrl_rf_pipe7_vmul_unsplit = rf_pipe7_data[VIQ1_VMUL_UNSPLIT];
// pipe6 特有：
assign dp_ctrl_rf_pipe6_vmul         = rf_pipe6_data[VIQ0_VMUL];
```

`VMUL_UNSPLIT`：向量乘法在无需拆分时置 1，ctrl 模块据此判断是否需要等待全部分片完成。

#### pipe7 srcv2 借用 pipe4 读端口

```verilog
// 行 4091-4113（rf_pipe47_clk）
always @(posedge rf_pipe47_clk ...) begin
  if(rf_pipe7_prf_srcv2_vreg_updt_vld)
    rf_pipe7_prf_srcv2_vreg_fr <= viq1...[VIQ1_SRCV2_VREG-1:...];
  else if(rf_pipe4_prf_srcvm_vreg_updt_vld)  // 借用 pipe4 srcvm
    rf_pipe7_prf_srcv2_vreg_fr <= lsiq_dp_pipe4...[LSIQ_SRCVM_VREG-1:...];
```

对称地，pipe4 的 fwd_srcv2 地址也在 `rf_pipe47_clk` 域共享（行 4151-4161）。

---

## 6. 立即数与操作数最终组装

### 6.1 整数管线立即数展开

整数立即数在 RF 阶段由各 `pipe_decd` 从 32 位操作码展开为完整 64 位：

```verilog
// pipe0（行 107-118，ct_idu_rf_pipe0_decd.v）
case(decd_imm_sel[4:0])
  5'h01: src1_imm = {44'b0, decd_op[31:12]};          // U-type imm20（lui/auipc）
  5'h02: src1_imm = {{52{decd_op[31]}}, decd_op[31:20]}; // I-type imm12（addi等）
  5'h04: src1_imm = {{58{decd_op[12]}}, decd_op[12], decd_op[6:2]}; // C.imm6（16位）
  5'h08: src1_imm = {{54{caddisp[9]}}, caddisp};       // C.addi16sp 偏移
  5'h10: src1_imm = {54'b0, caddi4spn};                // C.addi4spn 偏移（无符号）
```

### 6.2 移位立即数（pipe0/pipe1 特有）

```verilog
// 行 123-126（pipe0_decd）
// pipe0_decd_imm：移位量（6 位）
assign decd_ext_offset = decd_op[31:26] - decd_op[25:20]; // 扩展移位计算
assign pipe0_decd_imm  = decd_op[13] ? decd_ext_offset : {4'b0, decd_op[26:25]};
```

该字段用于 C910 扩展的位域提取指令（ext 系列）。

### 6.3 浮点舍入模式

```verilog
// pipe6_decd（行 98）
assign pipe6_decd_imm0[2:0] = decd_op[14:12];  // RM 字段（000=RNE, 001=RTZ, ...）
```

### 6.4 保留的向量立即数（vimm）

```verilog
// pipe6_decd vimm[4:0]：来自操作码 rs1 字段，用于 vslideup.vi/vmv.vi 等
assign pipe6_decd_vimm[4:0] = decd_op[19:15];

// 有效标志：当 srcv1 无效时（!VIQ0_SRCV1_VLD），说明使用立即数而非寄存器
assign idu_vfpu_rf_pipe6_vimm_vld = !rf_pipe6_data[VIQ0_SRCV1_VLD];
```

---

## 7. 送往各执行单元的接口

### 7.1 IU（pipe0/pipe1/pipe2）接口汇总

```
idu_iu_rf_pipe0_*:
  - iid[6:0]         : 指令 ID（用于 ROB 追踪）
  - opcode[31:0]      : 原始操作码（IU 可能需要进一步处理）
  - dst_vld / dst_preg[6:0]  : 目的物理寄存器
  - dstv_vld / dst_vreg[6:0] : 目的向量物理寄存器（mtvr/mfvr 用）
  - func[4:0]        : 功能码
  - eu_sel[3:0]      : 执行单元选择
  - rslt_sel[20:0]   : ALU 输出选择（one-hot）
  - src0/src1/src2[63:0] : 操作数数据
  - src1_no_imm[63:0]: 不含立即数替换的 src1（用于某些需要寄存器值的情况）
  - imm[5:0]         : 移位立即数
  - special_imm[19:0]: 特殊立即数（AUIPC/CSR 等）
  - alu_short        : 指令是否为短整数 ALU（1 级流水）
  - expt_vld/expt_vec: 异常
  - pid[4:0]         : 管线 ID（用于按序 commit）
  - vlmul/vsew/vl    : 向量配置（VSETVL 后更新）

idu_iu_rf_pipe1_* 额外：
  - mult_func[7:0]   : 乘法功能码
  - mla_src2_preg[6:0]: MLA 第三操作数物理寄存器号
  - mla_src2_vld     : 是否有效

idu_iu_rf_pipe2_*（BJU）：
  - func[7:0]        : 分支类型
  - offset[20:0]     : 跳转偏移
  - length/rts/pcall : 分支辅助信息
```

### 7.2 LSU（pipe3/pipe4/pipe5）接口汇总

```
idu_lsu_rf_pipe3_*（load）:
  - src0/src1[63:0]     : 基地址寄存器 + 偏移寄存器
  - offset[11:0]        : 立即数偏移
  - shift[3:0]          : 寄存器偏移移位量
  - offset_plus[12:0]   : 偏移+1（非对齐用）
  - inst_type/size      : 访存类型和宽度
  - sign_extend         : 符号扩展
  - atomic/inst_fls/lsfifo: 控制标志
  - spec_fail/no_spec   : 投机状态
  - oldest              : 年龄最老标志（ROB 头部）
  - already_da          : 地址已转换（TLB hit）
  - bkpta/bkptb_data    : 断点匹配

idu_lsu_rf_pipe4_*（store addr）额外：
  - inst_str/inst_share/inst_flush/inst_mode
  - fence_mode[3:0]
  - sync_fence/icc/mmu_req/atomic
  - sdiq_entry[11:0]    : 对应的 store data 队列条目
  - staddr/inst_code[31:0]
  - lsfifo / no_spec

idu_lsu_rf_pipe5_*（store data）:
  - src0[63:0]          : 整数 store 数据
  - srcv0_fr/vr0/vr1    : FREG/VREG 兼容通道；当前浮点标量使用 fr，向量部分为保留路径
  - srcv0_vld / srcv0_fr_vld : 兼容通道有效及 FREG 类别标志
  - stdata1_vld         : 双字 store 第二数据有效
  - unalign             : 非对齐
  - sdiq_entry[11:0]    : store 队列条目
```

### 7.3 VFPU（pipe6/pipe7）当前输出与内部保留字段

```
idu_vfpu_rf_pipe6_*:
  - iid[6:0]
  - dst_vld/preg/vreg/dste_vld/ereg  : 目的（整数/向量/扩展）
  - eu_sel[11:0]         : 执行单元（12 位 one-hot）
  - func[19:0]           : 功能码
  - imm0[2:0]            : 浮点舍入模式
  - vimm[4:0]/vimm_vld   : 保留向量立即数控制
  - ready_stage[2:0]     : 结果就绪阶段
  - inst_type[5:0]       : 指令类型（精度）
  - oper_size[2:0]       : 操作精度
  - mla_srcv2_vreg[6:0]/mla_srcv2_vld : FMA 第三操作数
  - vmla_type[2:0]       : FMA 变体
  - split_num[6:0]       : 向量拆分序号
  - vlmul/vsew/vl        : 向量配置
  - vm_bit               : mask 位（来自操作码[25]）
  - srcv0/v1/v2_fr[63:0] : 当前导出给 VFPU 的标量浮点操作数
  - srcv0/v1/v2_vr0/vr1  : rf_dp 内部保留 wire，当前不是模块 output
  - srcvm_vr0/vr1        : rf_dp 内部保留 mask 数据 wire
```

上表中的控制字段有些仍是模块 output，但只有在有效译码产生相应指令时才有功能意义。判断“当前硬件支持什么”必须同时看译码总开关、顶层端口连接和执行单元实例，不能只看字段名字。

---

## 8. 特殊共享寄存器端口设计

C910 rf_dp 中最具独特性的设计是**跨管线物理寄存器读端口共享**。这一设计核心思想是：在流片面积受限的情况下，某些不常同时出现的访问模式可以共享相同的物理读端口寄存器存储。

### 8.1 四组共享时钟域

| 共享时钟 | 域名 | 哪两个管线共享 | 共享的物理寄存器 |
|---------|------|---------------|----------------|
| `rf_pipe03_clk` | pipe0 OR pipe3 | pipe0 src2 / pipe3 src1 | `rf_pipe3_prf_src1_preg`、`rf_pipe3_fwd_src1_preg` |
| `rf_pipe15_clk` | pipe1 OR pipe5 | pipe1 src2 / pipe5 src0 | `rf_pipe5_prf_src0_preg`、`rf_pipe5_fwd_src0_preg` |
| `rf_pipe36_clk` | pipe3 OR pipe6 | pipe3 srcvm / pipe6 srcv2 | `rf_pipe6_prf_srcv2_vreg_*`、`rf_pipe6_fwd_srcv2_vreg` |
| `rf_pipe47_clk` | pipe4 OR pipe7 | pipe4 srcvm / pipe7 srcv2 | `rf_pipe7_prf_srcv2_vreg_*`、`rf_pipe7_fwd_srcv2_vreg` |

### 8.2 共享冲突如何被处理

共享并不依赖“两个请求很少同时发生”的概率假设。以整数端口为例，`rf_ctrl` 明确生成：

```text
pipe3_preg_lch_fail = pipe3_src1_vld && pipe0_src2_vld
pipe5_preg_lch_fail = pipe5_src0_vld && pipe1_src2_vld
```

即 pipe0 src2 优先于 pipe3 src1，pipe1 src2 优先于 pipe5 src0；低优先级项在 RF launch 检查失败后回队重调度。向量兼容端口也有 pipe6 srcv2 优先于 pipe3 srcvm、pipe7 srcv2 优先于 pipe4 srcvm 的同类规则。共享地址寄存器的 always 块必须与该优先级一致阅读：时钟只提供更新边界，冲突检测与失败重调度才防止两条请求把同一个物理端口当作同时可用。

### 8.3 目的寄存器 5 副本（dup0~dup4）

```verilog
reg [6:0] rf_pipe0_dst_preg_dup0;
reg [6:0] rf_pipe0_dst_preg_dup1;
// ... 到 dup4，共 5 份
```

这 5 份副本为综合和布局布线提供分散高扇出负载的结构。它通常用于降低单个寄存器输出的扇出压力，但副本与具体物理区域的对应关系、以及是否已经时序收敛，必须从综合网表、布局和 STA 报告确认，RTL 本身不能保证。

---

## 附录：IQ 条目字段偏移参考

### AIQ0 主要字段偏移

| 字段 | bit | 含义 |
|------|-----|------|
| `AIQ0_VL` | 226 | 向量长度 VL[7:0] |
| `AIQ0_LCH_PREG` | 218 | 锁存物理寄存器 |
| `AIQ0_SPECIAL` | 217 | 特殊指令标记 |
| `AIQ0_ALU_SHORT` | 103 | ALU 短路径 |
| `AIQ0_DIV` | 95 | 除法指令 |
| `AIQ0_SRC2_VLD` | 41 | 第三源有效 |
| `AIQ0_SRC1_VLD` | 40 | 第二源有效 |
| `AIQ0_SRC0_VLD` | 39 | 第一源有效 |
| `AIQ0_IID` | 38 | 指令 ID (7 bit) |
| `AIQ0_OPCODE` | 31 | 操作码 (32 bit) |

### LSIQ 主要字段偏移

| 字段 | bit | 含义 |
|------|-----|------|
| `LSIQ_VL` | 162 | 向量长度 |
| `LSIQ_ALREADY_DA` | 128 | 已完成地址翻译 |
| `LSIQ_UNALIGN_2ND` | 127 | 非对齐第二次 |
| `LSIQ_SPEC_FAIL` | 126 | 投机失败 |
| `LSIQ_SPLIT` | 123 | 拆分指令 |
| `LSIQ_SDIQ_ENTRY` | 122 | 对应 store data 条目 |
| `LSIQ_STADDR` | 110 | 是否为 store 地址 |
| `LSIQ_PC` | 109 | PC[14:0] |
| `LSIQ_STORE` | 89 | 是否 store |
| `LSIQ_LOAD` | 88 | 是否 load |

### VIQ0 主要字段偏移

| 字段 | bit | 含义 |
|------|-----|------|
| `VIQ0_VL` | 150 | 向量长度 |
| `VIQ0_VMUL` | 137 | 向量乘法标记 |
| `VIQ0_VDIV` | 135 | 向量除法标记 |
| `VIQ0_VMLA_TYPE` | 118 | FMA 类型（3 bit） |
| `VIQ0_SPLIT_NUM` | 115 | 拆分序号（7 bit） |
| `VIQ0_MFVR` | 107 | move from vector reg |
| `VIQ0_VMLA` | 106 | 是否 FMA 类型 |
| `VIQ0_SRCV2_VLD` | 41 | 第三源（FMA 累加）有效 |
| `VIQ0_SRCV1_VLD` | 40 | 第二源有效（或立即数） |
| `VIQ0_SRCV0_VLD` | 39 | 第一源有效 |

---

*本文档基于 C910 RTL 源码 `ct_idu_rf_dp.v` 及其 7 个子译码器模块分析整理。*
