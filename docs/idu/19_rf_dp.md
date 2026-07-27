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
   - [pipe6_decd — VFPU0（向量/浮点）](#57-pipe6_decd--vfpu0向量浮点)
   - [pipe7_decd — VFPU1（向量/浮点）](#58-pipe7_decd--vfpu1向量浮点)
6. [立即数与操作数最终组装](#6-立即数与操作数最终组装)
7. [送往各执行单元的接口](#7-送往各执行单元的接口)
8. [特殊共享寄存器端口设计](#8-特殊共享寄存器端口设计)

---

## 1. 模块概述

**文件路径**：`C910_RTL_FACTORY/gen_rtl/idu/rtl/ct_idu_rf_dp.v`（4379 行）

`ct_idu_rf_dp`（RF Data Path）是 IDU（指令分发单元）流水线中 **RF（Register File Read）阶段**的核心数据通路模块。它在 IS 阶段（发射队列发射）和 EX 阶段（各执行单元执行）之间扮演数据汇聚与最终分发的角色。

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

- **`xiq_xx_issue_en`**：本周期是否发射（使能信号，打开门控时钟并锁存数据）
- **`xiq_xx_gateclk_issue_en`**：门控时钟使能（比 issue_en 提前一个半周期）
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

PRF 在上一周期（IS 阶段末）完成寄存器读取，将结果传入 rf_dp。整数管线使用 64 位 `prf_dp_rf_pipeX_srcY_data`；向量管线分为 `_fr`（浮点标量）、`_vr0`（向量下半）、`_vr1`（向量上半）三路，每路 64 位，合计 128 位向量寄存器。

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

为什么需要多副本？物理寄存器比较网络在面积/时序约束下无法用单一驱动覆盖所有下游，通过 5 路寄存器复制（dup）减少扇出，降低时序压力。

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
| `idu_vfpu_rf_pipe6_` | VFPU0 | `srcv0..srcvm` (fr/vr0/vr1), `eu_sel[11:0]`, `func[19:0]` |
| `idu_vfpu_rf_pipe7_` | VFPU1 | 同 pipe6 |

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
| `x_ct_idu_rf_pipe6_decd` | `ct_idu_rf_pipe6_decd` | 3806 | VIQ0 | VFPU0 | 1971 |
| `x_ct_idu_rf_pipe7_decd` | `ct_idu_rf_pipe7_decd` | 4213 | VIQ1 | VFPU1 | 2036 |

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

rf_dp 为每条管线单独设置门控时钟，只有在对应发射队列有发射时才打开：

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

这种共享时钟设计（`rf_pipe03_clk`、`rf_pipe15_clk`、`rf_pipe36_clk`、`rf_pipe47_clk`）体现了 C910 跨管线寄存器端口复用的优化思想：**整数三操作数指令（mla/sc.w等）的第三源操作数寄存器编号，通过与 store 数据/访存管线共享物理寄存器读端口来节省面积**。

---

## 5. 逐管线讲解

### 5.1 pipe0_decd — ALU0 + 特殊/CSR

**功能单元**：ALU0（加减/移位/逻辑）、DIV（除法）、SPECIAL（AUIPC/ECALL/EBREAK/VSETVL 等）、CP0（CSR 操作）

#### 译码器端口

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

这个 21 位 one-hot 编码让 ALU 的输出选择电路变为简单的多路选择器，可以在设计时最小化关键路径延迟。

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

注意 VSETVL/VSETVLI 走 pipe0（SPECIAL 路径），因为它修改 vl/vtype 等向量 CSR，与普通 CSR 写路径统一处理。

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

这里使用 `rf_pipe03_clk` 共享时钟（行 2906-2928），保证 src2 的物理寄存器编号在 pipe0 或 pipe3 发射时都能正确更新。

#### 输出到 CP0

```verilog
// 行 2320-2325
assign idu_cp0_rf_iid[6:0]    = rf_pipe0_data[AIQ0_IID:AIQ0_IID-6];
assign idu_cp0_rf_opcode[31:0] = rf_pipe0_data[AIQ0_OPCODE:AIQ0_OPCODE-31];
assign idu_cp0_rf_preg[6:0]   = rf_pipe0_data[AIQ0_DST_PREG:AIQ0_DST_PREG-6];
assign idu_cp0_rf_src0[63:0]  = rf_pipe0_src0_data_no_fwd;  // 不含前递
assign idu_cp0_rf_func[4:0]   = pipe0_decd_func[4:0];
```

注意 `idu_cp0_rf_src0` 使用 `_no_fwd` 版本——CP0 访问（CSR 读写）要求操作数来源严格可信，即使当前寄存器未写回 PRF 也不接受前递（防止 WB 阶段前推的不稳定值被 CSR 采用），而是使用 HAD 调试接口或 PRF 直接读出：

```verilog
// 行 2232-2234
assign rf_pipe0_src0_data_no_fwd = (had_idu_wbbr_vld)
                                   ? had_idu_wbbr_data   // HAD 写回路径
                                   : prf_dp_rf_pipe0_src0_data;
```

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

这是最简单的译码器，174 行，仅处理分支和跳转指令。

#### 译码器端口

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

#### 译码器端口

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
  pipe3_decd_lsfifo    = 1'b0;   // 原子不走 FIFO（需严格顺序）
end

// amoswap.w / amoadd.w / ... （行 224-244）
32'b00001????????????010?????0101111,  // amoswap.w
32'b00000????????????010?????0101111,  // amoadd.w
// ...
```

原子操作（AMO）关闭 lsfifo，确保它们以严格顺序执行，不被乱序合并。

#### 向量 load 解码

向量 load（vle*/vlse*/vluxei* 等）在 pipe3 decode，其 `inst_type=2'b10`，表示目的寄存器是向量寄存器（dst_vreg 有效）。

#### 地址偏移量的 +1 预计算

```verilog
// pipe3_decd_offset_plus：提前计算 offset+1，用于非对齐访问的第二次访问
assign pipe3_decd_offset_plus = {1'b0, pipe3_decd_offset[11:0]} + 13'h1;
```

非对齐 load/store 可能需要两次 cache 访问，第二次访问的地址 = 第一次 + 1（在 cache 行边界处增1）。提前计算避免了 EX 阶段的关键路径加法。

#### src3（mask 向量寄存器 srcvm）

向量 load 指令还有一个 mask 操作数（vm，来自 v0 寄存器）。pipe3 保有独立的 `srcvm` 源路径：

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

pipe4 是所有 pipe_decd 中**最复杂的**（1507 行），因为 store 地址路径要处理：普通 store、原子条件 store（SC）、内存屏障（FENCE/FENCE.I）、TLB 刷新（SFENCE.VMA）、向量 store、非对齐 store 等众多情况。

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

这段逻辑保证 store data（pipe5）不能早于 store address（pipe4）执行到 LSU——即使两者在 RF 阶段同时就绪，store data 也必须等地址已经进入 store 队列后才真正发送数据。

#### 非对齐处理

```verilog
assign rf_pipe5_unalign_with_lsu_dc = rf_pipe5_data[SDIQ_UNALIGN]
                                      || rf_pipe5_staddr_create_stq
                                         && lsu_idu_dc_staddr_unalign;
```

当 store address 因非对齐被拆分时，store data 也需要知道这一事实以进行正确的数据拆分。

#### 向量 store 数据

```verilog
assign idu_lsu_rf_pipe5_srcv0_fr[63:0]  = rf_pipe5_srcv0_fr_data;   // 浮点标量部分
assign idu_lsu_rf_pipe5_srcv0_vr0[63:0] = rf_pipe5_srcv0_vr0_data;  // 向量低 64 位
assign idu_lsu_rf_pipe5_srcv0_vr1[63:0] = rf_pipe5_srcv0_vr1_data;  // 向量高 64 位
assign idu_lsu_rf_pipe5_srcv0_vld        = rf_pipe5_data[SDIQ_SRCV0_VLD];
assign idu_lsu_rf_pipe5_srcv0_fr_vld     = !rf_pipe5_data[SDIQ_SRCV0_VREG]; // 1=标量浮点
```

通过 `srcv0_fr_vld` 区分 store 数据是浮点标量（单个 64 位）还是向量寄存器（128 位，分两半传输）。

---

### 5.7 pipe6_decd — VFPU0（向量/浮点）

**功能单元**：VFPU0（Vector Floating Point Unit 0）

这是除 pipe7 外代码量最大的译码器（1971 行），需要支持 RISC-V 标准 F/D 扩展（单/双精度浮点）和 V 扩展（RVV，向量浮点）的全部运算。

#### 译码器端口

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

// 向量浮点执行单元（7 位，VEC_EU_WIDTH=12，上 7 位）
// pipe6_decd_eu_sel[11:0] 中 [11:5] 用于向量单元标识
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

#### 向量源操作数 MUX（4 路）

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
// srcv1, srcv2, srcvm 完全对称...
```

共 12 路 64 位 MUX，是 rf_dp 中逻辑最"宽"的部分。

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

#### 向量 FMA（vmla）类型

```verilog
assign idu_vfpu_rf_pipe6_mla_srcv2_vreg[6:0] = rf_pipe6_data[VIQ0_SRCV2_VREG:...];
assign idu_vfpu_rf_pipe6_mla_srcv2_vld       = rf_pipe6_data[VIQ0_SRCV2_VLD];
assign idu_vfpu_rf_pipe6_vmla_type[2:0]      = rf_pipe6_data[VIQ0_VMLA_TYPE:...];
assign idu_vfpu_rf_pipe6_split_num[6:0]      = rf_pipe6_data[VIQ0_SPLIT_NUM:...];
```

向量 FMA 的结果寄存器同时也是第三源，`vmla_type` 编码了具体的 FMA 变体（vfmadd/vfmsub/vfnmsub/vfnmadd）；`split_num` 记录当前指令是拆分执行的第几片（向量宽度超过硬件单元宽度时指令被拆分）。

---

### 5.8 pipe7_decd — VFPU1（向量/浮点）

**功能单元**：VFPU1（Vector Floating Point Unit 1）

pipe7 与 pipe6 结构基本对称，都从 VIQ（向量发射队列）发射，都有 4 个向量源操作数，都输出 12 位 eu_sel 和 20 位 func。

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

### 6.4 向量立即数（vimm）

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
  - srcv0_fr/vr0/vr1    : 向量 store 数据（三路）
  - srcv0_vld / srcv0_fr_vld : 向量数据有效标志
  - stdata1_vld         : 双字 store 第二数据有效
  - unalign             : 非对齐
  - sdiq_entry[11:0]    : store 队列条目
```

### 7.3 VFPU（pipe6/pipe7）接口汇总

```
idu_vfpu_rf_pipe6_*:
  - iid[6:0]
  - dst_vld/preg/vreg/dste_vld/ereg  : 目的（整数/向量/扩展）
  - eu_sel[11:0]         : 执行单元（12 位 one-hot）
  - func[19:0]           : 功能码
  - imm0[2:0]            : 浮点舍入模式
  - vimm[4:0]/vimm_vld   : 向量立即数
  - ready_stage[2:0]     : 结果就绪阶段
  - inst_type[5:0]       : 指令类型（精度）
  - oper_size[2:0]       : 操作精度
  - mla_srcv2_vreg[6:0]/mla_srcv2_vld : FMA 第三操作数
  - vmla_type[2:0]       : FMA 变体
  - split_num[6:0]       : 向量拆分序号
  - vlmul/vsew/vl        : 向量配置
  - vm_bit               : mask 位（来自操作码[25]）
  - srcv0/v1/v2_fr[63:0] : 浮点标量部分
  - srcv0/v1/v2_vr0/vr1  : 向量数据（低/高 64 位）
  - srcvm_vr0/vr1        : mask 寄存器数据
```

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

### 8.2 为什么这样共享是安全的

以 `rf_pipe03_clk` 为例：
- pipe0（AIQ0 整数）有 src2 的情形：仅限于 MLA 类扩展指令（需要 pipe3 读端口空闲）
- pipe3（LSIQ load）有 src1 的情形：访存指令（src1 = 偏移寄存器），不需要 src2
- 两者在同一周期同时使用的可能性极低；即使同时发射，ctrl 模块也会通过 `ctrl_dp_rf_pipeX_other_lch_fail` 协调，确保不会发生冲突

### 8.3 目的寄存器 5 副本（dup0~dup4）

```verilog
reg [6:0] rf_pipe0_dst_preg_dup0;
reg [6:0] rf_pipe0_dst_preg_dup1;
// ... 到 dup4，共 5 份
```

这 5 份副本分别驱动不同的前递比较网络扇出区域（每个执行管线或发射队列各需要一份），通过寄存器复制而非总线共享，保证时序收敛。

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
