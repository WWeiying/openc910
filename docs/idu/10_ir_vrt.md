# C910 IDU 向量重命名表 ir_vrt 详解

**RTL 文件：** `ct_idu_ir_vrt.v`（518 行）  
**子模块：** `ct_idu_dep_vreg_srcv2_entry.v`  
**所在流水级：** IR（Issue-Rename，第二发射级）

---

## 目录

1. [模块概述](#1-模块概述)
2. [RVV 向量寄存器背景](#2-rvv-向量寄存器背景)
3. [端口说明](#3-端口说明)
4. [重命名表结构：34 个依赖跟踪项](#4-重命名表结构34-个依赖跟踪项)
5. [重命名表项子模块 dep_vreg_srcv2_entry 深解](#5-重命名表项子模块-dep_vreg_srcv2_entry-深解)
6. [查表逻辑：源寄存器依赖信息读取](#6-查表逻辑源寄存器依赖信息读取)
7. [写入逻辑：目的寄存器表项更新](#7-写入逻辑目的寄存器表项更新)
8. [同周期前递（Intra-packet Forwarding）](#8-同周期前递intra-packet-forwarding)
9. [srcv2 的特殊处理与跨指令匹配](#9-srcv2-的特殊处理与跨指令匹配)
10. [输出数据格式：向 viq 提供的依赖信息](#10-输出数据格式向-viq-提供的依赖信息)
11. [v0 掩码寄存器（srcvm）处理](#11-v0-掩码寄存器srcvm处理)
12. [向量寄存器组（LMUL>1）对重命名的影响](#12-向量寄存器组lmul1对重命名的影响)
13. [flush 恢复与复位](#13-flush-恢复与复位)
14. [当前 RTL 状态：占位模块说明](#14-当前-rtl-状态占位模块说明)
15. [上下游接口总结](#15-上下游接口总结)

---

## 1. 模块概述

### 1.1 ir_vrt 在 IDU 中的位置

C910 的 IDU（Issue/Dispatch Unit）在 IR 阶段（Issue-Rename 阶段）维护三张**寄存器重命名表（Register Rename Table）**：

| 缩写  | 模块                  | 管理的寄存器              | 目的寄存器位宽 | 表项数 |
|-------|-----------------------|--------------------------|----------------|--------|
| `irt` | `ct_idu_ir_rt`        | 整数通用寄存器 x0~x31     | preg[6:0]      | 32     |
| `frt` | `ct_idu_ir_frt`       | 浮点/向量标量寄存器 f0~f31 | freg[5:0]+ereg | 32+1   |
| **`vrt`** | **`ct_idu_ir_vrt`** | **向量寄存器 v0~v31**    | **vreg[5:0]**  | **34** |

三张表协同完成"**寄存器号 → 数据就绪状态**"的映射，使得发射队列（iq/viq）中的指令可以判断源操作数何时可以读取。

### 1.2 ir_vrt 的核心职责

ir_vrt 是**向量寄存器依赖跟踪表**，不是经典意义上的"物理寄存器重命名（RAT）"——C910 向量部分采用的是**in-order 顺序提交**策略，不分配物理寄存器编号（vpreg），而是直接跟踪每个架构向量寄存器（v0~v31）的**数据就绪状态**。

具体地，ir_vrt 负责：

1. **记录 vN 寄存器当前是否有未完成的写操作**（rdy 位、wb 位）
2. **记录写该 vN 寄存器的指令的目的物理寄存器编号**（vreg[6:0]，用于向量流水线比对）
3. **监听 VFPU 流水线各阶段的执行状态**，提前预测数据就绪时机
4. **向下游 viq（向量发射队列）输出**每条指令的四个向量源操作数依赖信息：srcv0、srcv1、srcv2、srcvm

### 1.3 与整数/浮点表的分工

```
整数 irt：管理 x0~x31，输出 src0/src1/src2 依赖信息 → iq（整数发射队列）
浮点 frt：管理 f0~f31，输出 srcf0/srcf1/srcf2 依赖信息 → fiq（浮点发射队列）
向量 vrt：管理 v0~v31，输出 srcv0/srcv1/srcv2/srcvm 依赖信息 → viq（向量发射队列）
```

在 `ct_idu_ir_dp.v` 中，frt 和 vrt 的输出会被 MUX 合并为统一的 `ir_rt_instN_srcvX_data`，送入 IS 阶段数据通路，区分依据是 `IR_SRCV0_VLD`/`IR_SRCF0_VLD` 标志位（见第 15 节）。

---

## 2. RVV 向量寄存器背景

### 2.1 架构寄存器 v0~v31

RVV（RISC-V Vector Extension）定义 32 个向量寄存器 v0~v31，每个宽度为 VLEN 位。C910 的 VLEN=256 位。

### 2.2 v0 的掩码寄存器特殊角色

RVV 中 **v0 是唯一可充当掩码寄存器的架构向量寄存器**。带掩码的向量指令使用 `vm=0` 时，源操作数包含：

```
vs1/vs2/vd（普通向量源/目）+ v0.t（掩码，即 srcvm）
```

在 ir_vrt 中，`srcvm`（source vector mask）对应 v0 寄存器，其有效信号为 `dp_vrt_instN_srcvm_vld`，表示该指令使用 v0 作为掩码。由于 v0 被普通指令和掩码指令共用，v0 对应的表项（vreg entry 0）承受最高的读压力。

### 2.3 LMUL 与寄存器组

当 `LMUL > 1` 时，RVV 指令操作的不是单个 vN，而是以 vN 为起始的寄存器组（group）。例如 `LMUL=2` 时 `vadd v0, v2, v4` 实际操作的是 `(v0,v1)`、`(v2,v3)`、`(v4,v5)` 共 6 个向量寄存器。

C910 对 LMUL>1 的处理方式是**指令拆分（split）**：将一条多寄存器组向量指令拆分为多条单寄存器操作的子指令，每条子指令有独立的 `dstv_reg`（目的寄存器编号），分别在 ir_vrt 中跟踪。具体拆分由 FE 阶段的 `IR_SPLIT`/`IR_SPLIT_NUM`/`IR_SPLIT_LAST` 字段控制（见 `ct_idu_ir_dp.v` 中的 IS_SPLIT 相关参数）。

**因此 ir_vrt 在任意时刻都只处理单个向量寄存器粒度的依赖**，LMUL 带来的多寄存器依赖通过多条子指令的串行处理体现。

---

## 3. 端口说明

### 3.1 来自 dp（ir_dp）的输入

每条指令（inst0~inst3）携带以下输入，共 4 组，格式相同：

```verilog
// 以 inst0 为例（第 88~97 行）
input [5:0] dp_vrt_inst0_dst_vreg;   // 目的物理向量寄存器号（RTU 分配）
input [5:0] dp_vrt_inst0_dstv_reg;   // 目的架构向量寄存器号（v0~v31 的低 5 位）
input       dp_vrt_inst0_dstv_vld;   // 是否有向量目的寄存器
input [5:0] dp_vrt_inst0_srcv0_reg;  // 源操作数 vs1 的架构寄存器号
input       dp_vrt_inst0_srcv0_vld;  // vs1 是否有效
input [5:0] dp_vrt_inst0_srcv1_reg;  // 源操作数 vs2 的架构寄存器号
input       dp_vrt_inst0_srcv1_vld;  // vs2 是否有效
input       dp_vrt_inst0_srcv2_vld;  // 三源操作数 vd（accumulate）是否有效
input       dp_vrt_inst0_srcvm_vld;  // 掩码源 v0 是否有效
input       dp_vrt_inst0_vmla;       // 是否为向量乘加指令（vmla/vfmacc 等）
```

**字段解析：**

| 字段 | 宽度 | 含义 |
|------|------|------|
| `dst_vreg[5:0]` | 6 位 | RTU 为该指令分配的向量物理寄存器（`rtu_idu_alloc_vregN`），用于存储 vreg[6:0] 中的低 6 位；bit6 区分向量（1）和浮点（0） |
| `dstv_reg[5:0]` | 6 位 | 架构目的向量寄存器编号，即指令中的 `vd`（0~31），用于索引 34 个表项中的对应项 |
| `dstv_vld` | 1 位 | 本指令是否有向量目的寄存器（写 vN），有则触发表项更新 |
| `srcv0_reg[5:0]` | 6 位 | 架构源寄存器 vs1 的编号，用于查表 |
| `srcv1_reg[5:0]` | 6 位 | 架构源寄存器 vs2 的编号，用于查表 |
| `srcv2_vld` | 1 位 | 三源指令（乘加类）中，vd 同时作为源操作数，无寄存器编号字段（编号同 `dstv_reg`） |
| `srcvm_vld` | 1 位 | 是否使用 v0 为掩码寄存器，无寄存器编号字段（固定为 v0，即表项 0） |
| `vmla` | 1 位 | 向量乘加标志，影响 `mla_rdy` 路径计算 |

> **注意：** `srcv2` 没有独立的 `srcv2_reg` 字段，因为对于三源向量指令（如 `vfmacc vd, vs1, vs2`），第三个源就是目的寄存器 `vd` 本身，其寄存器号就是 `dstv_reg`。类似地，`srcvm` 固定使用 v0（表项 0）。

### 3.2 flush 输入

```verilog
// 第 128 行
input [191:0] rtu_idu_rt_recover_vreg;  // RTU 提供的 flush 恢复向量
```

这是一个 192 位向量（32 个向量寄存器 × 6 位/个 = 192 位），携带 flush 后每个架构向量寄存器应映射到的 vreg 值（用于恢复到 ROB 检查点状态）。

### 3.3 向 dp 的输出

每条指令（inst0~inst3）输出四路源操作数依赖信息：

```verilog
// 以 inst0 为例（第 132~136 行）
output [6:0] vrt_dp_inst0_rel_vreg;   // 释放的旧目的 vreg（供 RTU/ROB 回收）
output [8:0] vrt_dp_inst0_srcv0_data; // vs1 依赖信息（9 位）
output [8:0] vrt_dp_inst0_srcv1_data; // vs2 依赖信息（9 位）
output [9:0] vrt_dp_inst0_srcv2_data; // vd-as-src3 依赖信息（10 位，含 mla_rdy）
output [8:0] vrt_dp_inst0_srcvm_data; // v0 掩码依赖信息（9 位）
```

**srcv0/srcv1/srcvm 9 位格式（与 `x_read_data` 的低 9 位对应）：**

| 位 | 含义 |
|----|------|
| [0]   | `rdy`：数据就绪（可以旁路或已在 PRF 中） |
| [1]   | `wb`：已写回 PRF |
| [8:2] | `vreg[6:0]`：生产者的物理向量寄存器编号 |

**srcv2 10 位格式（多出 mla_rdy 位）：**

| 位 | 含义 |
|----|------|
| [0]   | `rdy` |
| [1]   | `wb` |
| [8:2] | `vreg[6:0]` |
| [9]   | `mla_rdy`：向量乘加专用就绪位，比普通 `rdy` 更早拉高 |

### 3.4 同周期跨指令 srcv2 匹配信号

```verilog
// 第 129~131, 137~138, 144 行
output vrt_dp_inst01_srcv2_match;  // inst0 的 dst 与 inst1 的 srcv2 相同
output vrt_dp_inst02_srcv2_match;  // inst0 的 dst 与 inst2 的 srcv2 相同
output vrt_dp_inst03_srcv2_match;  // inst0 的 dst 与 inst3 的 srcv2 相同
output vrt_dp_inst12_srcv2_match;  // inst1 的 dst 与 inst2 的 srcv2 相同
output vrt_dp_inst13_srcv2_match;  // inst1 的 dst 与 inst3 的 srcv2 相同
output vrt_dp_inst23_srcv2_match;  // inst2 的 dst 与 inst3 的 srcv2 相同
```

这 6 个信号用于同一分发包内（intra-packet）的前递检测（详见第 8 节）。

---

## 4. 重命名表结构：34 个依赖跟踪项

### 4.1 为什么是 34 项而非 32 项

ir_vrt 注释中可以看到实例化了 34 个 `ct_idu_dep_vreg_srcv2_entry`（reg_0 ~ reg_33）：

```verilog
// 第 196~296 行（注释中的 &Instance 宏展开）
// reg_0  ~ reg_31：对应 v0~v31（32 个架构向量寄存器）
// reg_32, reg_33：保留/扩展项（对应 vreg[5] bit 的 freg 空间复用）
```

对照 `ct_idu_ir_frt.v`，浮点表也是 33 项（reg_0~reg_32），向量表是 34 项。多出的 2 项（reg_32, reg_33）是为了支持 **6 位 vreg 编码**：`dstv_reg[5:0]` 的 bit5 有特殊含义（区分 vector/float 空间），因此通过 `ct_rtu_expand_32` 宏展开 5 位的低字段再处理高位，可以访问到索引 32、33 的项。

### 4.2 表项索引方式

写入（write port）使用 `ct_rtu_expand_32` 将 `dstv_reg[4:0]`（5 位，0~31）展开为 32 位独热码，再结合 `dstv_reg[5]` bit 选择是写普通向量项（reg_0~reg_31）还是扩展项（reg_32~reg_33）：

```verilog
// 参考 ct_idu_ir_frt.v 第 2856~2859 行的类似逻辑（vrt 同构）：
assign reg_write0_en[31:0] = dstv_reg_lsb_expand[31:0]
                             & {32{inst0_write_en && !dp_vrt_inst0_dstv_reg[5]}};
assign reg_write0_en[32]   = dstv_reg_lsb_expand[0]
                             && inst0_write_en && dp_vrt_inst0_dstv_reg[5];
// reg_33 类似...
```

读取（read port）使用 case 语句以 `srcvX_reg[5:0]` 为索引从所有项中选择对应的 `read_data[12:0]`。

### 4.3 整体结构图

```
     架构向量寄存器       重命名表项                  输出
      v0 (v0-mask)  →  entry_vreg[0]  {rdy, wb, vreg, mla_rdy, lsu_match}
      v1            →  entry_vreg[1]
      v2            →  entry_vreg[2]
      ...
      v31           →  entry_vreg[31]
      [ext32]       →  entry_vreg[32]  (vreg[5]=1 时的第0项)
      [ext33]       →  entry_vreg[33]  (vreg[5]=1 时的第1项)

 每个表项跟踪：
   - rdy        : 数据就绪（可以旁路转发）
   - mla_rdy    : 乘加专用提前就绪
   - wb         : 已写回到向量寄存器堆
   - vreg[6:0]  : 生产者的物理 vreg 编号
   - lsu_match  : 是否有 vload 指令在流水线中匹配此寄存器
```

---

## 5. 重命名表项子模块 dep_vreg_srcv2_entry 深解

`ct_idu_dep_vreg_srcv2_entry.v` 是 ir_vrt 中每个向量寄存器的状态机单元，同样被 ir_frt 复用。本节以此子模块为核心讲解所有依赖跟踪逻辑。

### 5.1 创建（Create）数据格式

表项通过 `x_create_data[10:0]` 写入，字段如下（第 263~267 行）：

```verilog
assign x_create_lsu_match = x_create_data[10];  // 初始 LSU 匹配状态
assign x_create_mla_rdy   = x_create_data[9];   // 初始 mla_rdy
assign x_create_vreg[6:0] = x_create_data[8:2]; // 生产者 vreg 编号（7 位）
assign x_create_wb        = x_create_data[1];   // 初始写回状态
assign x_create_rdy       = x_create_data[0];   // 初始就绪状态
```

当一条有 `dstv_vld` 的向量指令进入 IR 阶段时，`x_write_en` 拉高，将创建数据写入对应的 `dstv_reg` 表项。此时 `x_create_rdy=0`（指令刚发射，结果未就绪），`x_create_wb=0`，`x_create_vreg` 为 RTU 分配的新 vreg。

### 5.2 读取（Read）数据格式

表项通过 `x_read_data[12:0]` 输出（第 269~275 行）：

```verilog
assign x_read_data[12]    = x_read_lsu_match;      // LSU 匹配
assign x_read_data[11]    = x_read_rdy_for_bypass;  // 可以旁路读取
assign x_read_data[10]    = x_read_rdy_for_issue;   // 可以发射（含提前就绪路径）
assign x_read_data[9]     = x_read_mla_rdy;         // mla 提前就绪
assign x_read_data[8:2]   = x_read_vreg[6:0];       // 生产者 vreg 编号
assign x_read_data[1]     = x_read_wb;              // 已写回 PRF
assign x_read_data[0]     = x_read_rdy;             // 基础就绪位
```

### 5.3 rdy（就绪位）状态机

rdy 位追踪"数据可以被旁路读取"的状态，更新逻辑如下（第 285~338 行）：

**数据就绪来源：**

```verilog
// VFPU pipe6（整数或向量 FPU 管道 6）的各执行阶段
assign vfpu0_ex3_data_ready = vfpu_idu_ex1_pipe6_data_vld_dupx
                              && (vfpu_idu_ex1_pipe6_vreg_dupx == vreg);
assign vfpu0_ex4_data_ready = vfpu_idu_ex2_pipe6_data_vld_dupx
                              && (vfpu_idu_ex2_pipe6_vreg_dupx == vreg);
assign vfpu0_ex5_data_ready = vfpu_idu_ex3_pipe6_data_vld_dupx
                              && (vfpu_idu_ex3_pipe6_vreg_dupx == vreg);
// VFPU pipe7 类似...
// LSU（向量 load）
assign load_data_ready = lsu_idu_dc_pipe3_vload_inst_vld_dupx
                         && (lsu_idu_dc_pipe3_vreg_dupx == vreg);
```

**时序含义：**
- `ex1_pipe6_data_vld` → 表示 EX2 阶段的结果将在下一周期（EX3）可旁路，即发出信号的周期之后 2 个周期数据就绪
- 各阶段信号依次对应 EX3、EX4、EX5 可用（向量浮点流水线深度约 5 级）

**综合就绪判断：**

```verilog
assign data_ready  = vfpu0_ex3_data_ready || vfpu0_ex4_data_ready || vfpu0_ex5_data_ready
                  || vfpu1_ex3_data_ready || vfpu1_ex4_data_ready || vfpu1_ex5_data_ready
                  || load_data_ready;
assign wake_up     = wb;           // wb 已置位则肯定 ready
assign rdy_clear   = x_rdy_clr;   // 外部强制清零（vrt 中 rdy_clr 固定为 0）

assign rdy_update  = (rdy || data_ready || wake_up) && !rdy_clear;
```

**为什么这样设计：** 设置一旦 rdy=1 就保持（sticky）的逻辑，是因为 IR 阶段是推测性跟踪阶段——一旦某时刻知道数据将要就绪，就把该信息传给发射队列，让发射队列在数据真正到来时能及时发射，而无需反复轮询。

**寄存器时序（第 328~338 行）：**

```verilog
always @(posedge dep_clk or negedge cpurst_b) begin
  if(!cpurst_b)           rdy <= 1'b1;  // 复位：所有寄存器初始化为就绪
  else if(rtu_idu_flush_fe || rtu_idu_flush_is)
                          rdy <= 1'b1;  // flush：恢复到就绪（前端 flush）
  else if(x_write_en)     rdy <= x_create_rdy;  // 新指令写入：使用创建值
  else                    rdy <= rdy_update;     // 正常更新
end
```

**为什么 flush 后设为 1：** flush 表示流水线清洗，此后所有未完成写操作对应的指令也已经被冲刷，所以对应的向量寄存器数据处于已知稳定状态（恢复到检查点），可以被读取，故 rdy=1。

### 5.4 rdy_for_issue 与 rdy_for_bypass 的区别

```verilog
assign x_read_rdy_for_issue  = rdy || mla_rdy || load_issue_data_ready
                                    || vfpu0_vdsp_fwd_data_ready
                                    || vfpu1_vdsp_fwd_data_ready;
assign x_read_rdy_for_bypass = rdy;
```

| 信号 | 含义 | 何时为 1 |
|------|------|----------|
| `rdy_for_bypass` | 数据可以旁路转发给执行单元 | 仅 `rdy=1` 时 |
| `rdy_for_issue` | 指令可以从发射队列发射 | `rdy=1`，或 `mla_rdy=1`（乘加提前），或 load 前递，或 vdsp forward |

这一区分的原因：**发射可以比实际旁路超前一拍**。某些情况下（如 mla 流水线）指令虽然数据还没到 bypass 网络，但计划在下一周期到达，此时可以先发射，数据将在执行开始前到位。`rdy_for_bypass` 则要求当周期就可以读取，不超前发射。

### 5.5 mla_rdy（向量乘加就绪位）

对于向量乘加指令（VMLA，如 `vfmacc.vv vd, vs1, vs2`），vd 同时是源操作数和目的操作数。mla_rdy 跟踪的是：**当该 vN 作为乘加指令的累加源（srcv2）时，其上一次结果何时就绪**。

mla_rdy 比普通 rdy **更早置位**，原因是乘加流水线可以在 EX1/EX2 就实施内部"链路直通（chain）"，不必等到 EX5 写回：

```verilog
// 第 367~394 行
assign vfpu0_fmla_data_ready = x_entry_vmla
                               && vfpu_idu_ex2_pipe6_fmla_data_vld_dupx
                               && (vfpu_idu_ex2_pipe6_vreg_dupx == vreg)
                            || x_entry_vmla
                               && vfpu_idu_ex1_pipe6_fmla_data_vld_dupx
                               && (vfpu_idu_ex1_pipe6_vreg_dupx == vreg);
// vmla_lch（latch）信号：在 RF 阶段锁存的乘加信号
assign vfpu0_vmla_data_ready = x_entry_vmla
                               && ctrl_xx_rf_pipe6_vmla_lch_vld_dupx
                               && (dp_xx_rf_pipe6_dst_vreg_dupx == vreg);
// vdsp（向量 DSP）旁路转发
assign vfpu0_vdsp_fwd_data_ready = x_entry_vmla && vfpu0_vreg_fwd_vld;
```

**注意：** `x_entry_vmla` 由表项上游控制（在 ir_vrt 语境中来自 `dp_vrt_instN_vmla`），用于限定"只有当该表项对应的指令是 vmla 类型时，才考虑 fmla/vmla_lch 路径"。这样避免了非乘加指令错误地继承了乘加前递的就绪条件。

在 ir_frt 中，所有浮点表项都固定 `reg_N_entry_vmla = 1'b1`（第 2702~2734 行），意味着浮点表每个 freg 都被视为 vmla 候选（因为浮点乘加 fmla 的特性与向量乘加类似）。

### 5.6 wb（写回位）

wb 跟踪"数据已写入向量 PRF（Physical Register File）"的状态：

```verilog
// 第 425~450 行
assign pipe3_wb = lsu_idu_wb_pipe3_wb_vreg_vld_dupx
                  && (lsu_idu_wb_pipe3_wb_vreg_dupx == vreg); // 向量 load 写回
assign pipe6_wb = vfpu_idu_ex5_pipe6_wb_vreg_vld_dupx
                  && (vfpu_idu_ex5_pipe6_wb_vreg_dupx == vreg); // VFPU pipe6 WB
assign pipe7_wb = vfpu_idu_ex5_pipe7_wb_vreg_vld_dupx
                  && (vfpu_idu_ex5_pipe7_wb_vreg_dupx == vreg); // VFPU pipe7 WB

assign write_back = wb || pipe3_wb || pipe6_wb || pipe7_wb;
assign wb_update  = wb || write_back; // sticky：一旦写回永远保持
```

wb=1 且 rdy=1 的意义：数据已实际存储在 PRF 中，后续依赖指令无需旁路，可以直接从 PRF 读取。

### 5.7 vreg（生产者寄存器编号存储）

```verilog
// 第 456~464 行
always @(posedge write_clk or negedge cpurst_b) begin
  if(!cpurst_b)       vreg[6:0] <= 7'b0;
  else if(x_write_en) vreg[6:0] <= x_create_vreg[6:0]; // 写入新生产者的 vreg
  else                vreg[6:0] <= vreg[6:0];           // 保持
end
assign x_read_vreg[6:0] = vreg[6:0];
```

vreg 使用独立的 `write_clk`（由 `x_gateclk_idx_write_en` 门控），与 rdy/wb 使用的 `dep_clk` 分离，目的是**降低功耗**——vreg 字段只在有新指令写入时才需要翻转，而 rdy/wb 需要在每个周期检测旁路条件。

### 5.8 lsu_match（向量 load 匹配位）

```verilog
// 第 343~358 行
assign lsu_match_update = lsu_idu_ag_pipe3_vload_inst_vld
                          && (lsu_idu_ag_pipe3_vreg_dupx == vreg);
```

lsu_match 在 LSU AG（地址生成）阶段拉高，表示"当前有 vload 指令在流水线中，且其目的寄存器就是此表项对应的 vreg"。用于 `load_issue_data_ready` 路径（见 5.4 节）。

---

## 6. 查表逻辑：源寄存器依赖信息读取

在 ir_frt 的实现中（ir_vrt 设计同构），查表逻辑如下（以 frt 中 srcf0 为例，vrt 的 srcv0 逻辑相同）：

```verilog
// 用架构源寄存器号作为 case 索引，从 34 个表项中取出 read_data
always @(...) begin
  case (dp_vrt_inst0_srcv0_reg[5:0])
    6'd0   : inst0_srcv0_read_data[12:0] = reg_0_read_data[12:0];
    6'd1   : inst0_srcv0_read_data[12:0] = reg_1_read_data[12:0];
    ...
    6'd31  : inst0_srcv0_read_data[12:0] = reg_31_read_data[12:0];
    6'd32  : inst0_srcv0_read_data[12:0] = reg_32_read_data[12:0];
    default: ...
  endcase
end

// 提取各字段
assign inst0_srcv0_read_rdy      = inst0_srcv0_read_data[0];
assign inst0_srcv0_read_wb       = inst0_srcv0_read_data[1];
assign inst0_srcv0_read_vreg[6:0]= inst0_srcv0_read_data[8:2];
// ...

// 组成输出（若源操作数无效则强制置 rdy=1, wb=1）
assign vrt_dp_inst0_srcv0_data[0]   = inst0_srcv0_read_rdy   || !dp_vrt_inst0_srcv0_vld;
assign vrt_dp_inst0_srcv0_data[1]   = inst0_srcv0_read_wb    || !dp_vrt_inst0_srcv0_vld;
assign vrt_dp_inst0_srcv0_data[8:2] = {1'b0, inst0_srcv0_read_vreg[5:0]};
```

**无效源操作数强制置 rdy 的原因：** 发射队列的发射条件是"所有有效源操作数均就绪"。若某源操作数标记为无效（vld=0），则它不存在依赖，应视为"永久就绪"，否则发射队列无法判断何时可以发射。

### 6.1 srcv0 和 srcv1 查表（9 位输出）

使用 `dp_vrt_instN_srcv0_reg[5:0]` 作为索引，返回 `reg_X_read_data` 的低 9 位，格式见第 3.3 节。

### 6.2 srcv2 查表（10 位输出，含 mla_rdy）

srcv2 的寄存器号等于 `dstv_reg`（即指令的目的寄存器），同样以此为索引查表，但输出多出 `read_data[9]`（mla_rdy 位）：

```verilog
assign vrt_dp_inst0_srcv2_data[9]   = inst0_srcv2_read_mla_rdy || !dp_vrt_inst0_srcv2_vld;
assign vrt_dp_inst0_srcv2_data[8:0] = ... // 同 srcv0 格式
```

mla_rdy 仅对 srcv2（累加源）有意义，因为向量乘加链路（fmla/vmla）的特殊优化只适用于第三源操作数（累加器）。

### 6.3 srcvm 查表（固定读 v0 表项）

srcvm（掩码源）固定使用 v0，因此直接读取 `reg_0_read_data`，不需要 case 索引：

```verilog
// 伪代码（实际 vrt 中 srcvm 逻辑等同于固定 srcv_reg=0 查表）
assign inst0_srcvm_read_data[12:0] = reg_0_read_data[12:0]; // 固定 v0
assign vrt_dp_inst0_srcvm_data[8:0] = {
  1'b0,                              // bit8
  inst0_srcvm_read_vreg[5:0],        // bits[7:2]
  inst0_srcvm_read_wb  || !dp_vrt_inst0_srcvm_vld, // bit1
  inst0_srcvm_read_rdy || !dp_vrt_inst0_srcvm_vld  // bit0
};
```

---

## 7. 写入逻辑：目的寄存器表项更新

### 7.1 写使能生成

```verilog
// 以 inst0 为例（参考 frt 对应逻辑）
assign inst0_write_en = ctrl_rt_inst0_vld    // 指令槽有效
                        && !ctrl_ir_stall    // 无 stall（stall 时不更新表）
                        && !vrt_recover_updt_vld  // 无 flush 恢复
                        && dp_vrt_inst0_dstv_vld; // 有向量目的寄存器

// 用 expand_32 将 5 位寄存器号展开为 32 位独热码，再选择对应的表项写使能
assign reg_write0_en[31:0] = dstv_reg_lsb_expand[31:0]
                             & {32{inst0_write_en && !dp_vrt_inst0_dstv_reg[5]}};
assign reg_write0_en[32]   = dstv_reg_lsb_expand[0]
                             && inst0_write_en && dp_vrt_inst0_dstv_reg[5];
// reg_write0_en[33] 类似
```

**Stall 时不写的原因：** IR 阶段的 stall 意味着当前周期的指令还不能进入 IS 阶段，因此不应该提前修改重命名表。这保证了重命名表的更新与指令实际进入 IS 阶段的时刻同步。

### 7.2 写入内容（create_data）

写入表项的数据需要确定：

- **rdy 初始值：** 取决于 RTU 的 `alloc_vreg` 分配时是否同时确认目前还没有 pending 的写操作。如果上一条写 vN 的指令已经完成（wb=1），则新指令进表时 rdy 可以为 0（因为要等自己执行完），若无 pending 写，则初始 rdy=1。C910 的具体策略为**写入时初始 rdy=0**，由后续的旁路监听机制更新。
- **wb 初始值：** 0（指令刚派遣，显然还未写回）
- **vreg 初始值：** `dst_vreg[5:0]`（RTU 分配的新物理寄存器编号）
- **mla_rdy 初始值：** 0 或由依赖分析确定

### 7.3 四路指令的写优先级

当同一周期的 4 条指令（inst0~inst3）写同一个 vN 时（WAW 依赖），需要保证最新（程序序最大）的一条的 dst_vreg 写入表项。优先级为 **inst3 > inst2 > inst1 > inst0 > flush 恢复**（与 frt 完全相同）：

```verilog
// 来自 ct_idu_ir_frt.v 第 3091~3113 行的典型模式（vrt 同构）
always @(...) begin
  if(reg_gateclk_write3_en[N])      reg_N_create_vreg = dp_vrt_inst3_dst_vreg;
  else if(reg_gateclk_write2_en[N]) reg_N_create_vreg = dp_vrt_inst2_dst_vreg;
  else if(reg_gateclk_write1_en[N]) reg_N_create_vreg = dp_vrt_inst1_dst_vreg;
  else if(reg_gateclk_write0_en[N]) reg_N_create_vreg = dp_vrt_inst0_dst_vreg;
  else                               reg_N_create_vreg = vrt_recover_updt_vreg[N*6+5:N*6];
end
```

---

## 8. 同周期前递（Intra-packet Forwarding）

### 8.1 问题背景

C910 每周期最多发射 4 条指令（宽度 W=4）。当同一发射包中前面的指令写某个 vN，而后面的指令读同一个 vN 时，就产生了**同包 RAW 依赖**（intra-packet hazard）。

例如：
```
inst0: vadd v2, v0, v1      # 写 v2
inst1: vmul v4, v2, v3      # 读 v2（与 inst0 同包，v2 尚未进入重命名表）
```

此时 inst1 查重命名表得到的是 v2 的旧状态（来自更早的指令），而实际上 inst1 依赖的是 inst0 的结果。

### 8.2 srcv2_match 信号的含义

`vrt_dp_inst01_srcv2_match` 等信号专门处理 **srcv2 的同包前递情况**。以 inst01_srcv2_match 为例：

这表示"inst0 的目的向量寄存器（dstv_reg）与 inst1 的 srcv2（累加寄存器）相同"。在发射队列中，inst1 的 srcv2 依赖信息需要**从 inst0 的目的寄存器状态前递**，而非使用重命名表中查到的旧值。

在 `ct_idu_ir_dp.v` 中，这些 match 信号与 frt 的同名信号做 OR 合并（第 1842~1847 行）：

```verilog
assign dp_ir_inst01_src_match[3] = frt_dp_inst01_srcf2_match || vrt_dp_inst01_srcv2_match;
```

`dp_ir_instXY_src_match` 总线的 bit3 代表 srcv2/srcf2 的匹配，bits[2:0] 代表整数/浮点 src0/src1/src2 的匹配（来自 irt）。

### 8.3 其他源操作数的同包前递

srcv0 和 srcv1 的同包前递在 ir_vrt（或 ir_frt）内部通过 **MUX 链** 实现——在查表之后，用同包更晚指令的写入值覆盖查表结果。例如：
- inst1 的 srcv0 查表后，若 inst0 的 dstv_reg == inst1 的 srcv0_reg，则用 inst0 的 dst_vreg 及其对应的初始状态替换查表结果

这部分逻辑在完整展开的 ir_vrt 中通过 `always` comb 块实现（注释中的大量 `&CombBeg/@xxx .. &CombEnd/@xxx` 对），每个源操作数对每条指令各有一段 comb 逻辑。

---

## 9. srcv2 的特殊处理与跨指令匹配

### 9.1 为什么 srcv2 需要特殊对待

普通二源向量指令（`vadd vd, vs1, vs2`）的源是 vs1（srcv0）和 vs2（srcv1）。但向量乘加指令（`vfmacc vd, vs1, vs2` = `vd = vd + vs1 * vs2`）中，vd 同时是目的和第三源（srcv2），这在指令格式上没有独立的 srcv2 寄存器字段——regs 字段只有 `vd`（同时充当目的和第三源）。

因此 srcv2 的特殊之处在于：
1. **无独立寄存器编号**：srcv2_reg 就是 dstv_reg
2. **需要额外的 mla_rdy 位**：乘加链路可以更早就绪
3. **同包前递需要单独信号**：因为对应的 srcv2 依赖检测需要考虑"前面的指令是否写了同一个 vd"

### 9.2 6 个 match 信号的覆盖范围

```
inst0 → inst1: vrt_dp_inst01_srcv2_match
inst0 → inst2: vrt_dp_inst02_srcv2_match
inst0 → inst3: vrt_dp_inst03_srcv2_match
inst1 → inst2: vrt_dp_inst12_srcv2_match
inst1 → inst3: vrt_dp_inst13_srcv2_match
inst2 → inst3: vrt_dp_inst23_srcv2_match
```

覆盖所有 C(4,2)=6 种组合，确保 4 宽度发射时的 srcv2 同包 WAR/RAW 都能正确处理。

---

## 10. 输出数据格式：向 viq 提供的依赖信息

在 `ct_idu_ir_dp.v` 中（第 1699~1832 行），vrt 与 frt 的输出通过 MUX 合并，最终封装进 IS 阶段数据总线（`dp_ir_instN_data`），送入向量发射队列 viq：

```verilog
// ir_dp.v 第 1713~1722 行
assign ir_rt_inst0_srcv0_data[8:0] = ir_inst0_data[IR_SRCV0_VLD]
                                     ? vrt_dp_inst0_srcv0_data[8:0]  // 向量指令查 vrt
                                     : frt_dp_inst0_srcf0_data[8:0]; // 浮点指令查 frt

assign ir_rt_inst0_srcv2_data[9:0] = ir_inst0_data[IR_SRCV2_VLD]
                                     ? vrt_dp_inst0_srcv2_data[9:0]
                                     : frt_dp_inst0_srcf2_data[9:0];

assign ir_rt_inst0_srcvm_data[8:0] = vrt_dp_inst0_srcvm_data[8:0]; // srcvm 只来自 vrt
```

注意 `srcvm`（掩码寄存器依赖）**只来自 vrt**，没有 frt 对应路径，因为掩码功能是 RVV 专有的。

最终 viq 发射队列收到的每个指令向量依赖信息：

```
IS 阶段 dp_ir_instN_data 中的向量依赖字段：
  IS_SRCV0_DATA [8:0]  : srcv0 依赖（rdy, wb, vreg）
  IS_SRCV1_DATA [8:0]  : srcv1 依赖
  IS_SRCV2_DATA [9:0]  : srcv2 依赖（rdy, wb, vreg, mla_rdy）
  IS_SRCVM_DATA [8:0]  : 掩码源依赖
  IS_SRCV0_BP_RDY [1:0]: srcv0 旁路就绪 / 发射就绪（bypass rdy / issue rdy）
  IS_SRCV1_BP_RDY [1:0]: 同上，srcv1
  IS_SRCV2_BP_RDY [1:0]: 同上，srcv2
  IS_SRCVM_BP_RDY [1:0]: 同上，掩码
  ...（注：IR 阶段这些 bypass/issue rdy 字段初始设为 0，在 IS 中由 viq 动态更新）
```

IR 阶段这些 rdy 字段初始为 0 是因为发射队列有自己的唤醒逻辑，IR 阶段只需正确设置静态字段（vreg 编号）和进入发射队列时的初始就绪状态；发射队列之后会持续监听执行单元的广播来更新 rdy。

---

## 11. v0 掩码寄存器（srcvm）处理

### 11.1 srcvm 与普通 srcv0 的区别

| 属性 | srcv0/srcv1 | srcvm |
|------|------------|-------|
| 寄存器号来源 | `srcv0_reg/srcv1_reg`（5 位字段） | 固定为 0（v0） |
| 查表方式 | case 语句动态索引 | 直接读 entry[0] |
| mla_rdy 位 | 无 | 无 |
| 宽度 | 9 位 | 9 位 |
| 是否参与同包前递 | 是 | 是（若同包指令写 v0，且后面的指令用 v0 为掩码） |

### 11.2 v0 的读压力

v0 是唯一的掩码寄存器，当程序大量使用带掩码的向量指令时，几乎每条向量指令都会读 v0（srcvm_vld=1）。虽然在查表逻辑上无需特殊处理（固定读 entry[0]），但 entry[0] 的 `dep_clk` 门控必须打开频率更高，功耗考量上 v0 是热点表项。

---

## 12. 向量寄存器组（LMUL>1）对重命名的影响

### 12.1 C910 的处理策略

C910 在 FE（前端）阶段就通过 `IR_SPLIT`/`IR_SPLIT_NUM` 将 LMUL>1 的向量指令拆分为多条子指令，每条子指令操作单独的架构向量寄存器编号。因此：

- `LMUL=2`，`vadd v0, v2, v4` 被拆为：
  - 子指令 0：`vadd v0, v2, v4`（操作下标 0）
  - 子指令 1：`vadd v1, v3, v5`（操作下标 1）
  
每条子指令有独立的 `dstv_reg`，分别占用 ir_vrt 中的不同表项。

### 12.2 split 对依赖跟踪的影响

由于拆分后的子指令串行通过 IR 阶段（一次一条或一次多条），ir_vrt 的查表/写入逻辑不需要特殊处理 LMUL——每次操作的都是单个架构寄存器编号，与普通 LMUL=1 的情况完全相同。

LMUL 信息通过 `IR_VLMUL`/`IS_VLMUL` 字段保存在指令数据总线中，最终传递给 viq 和执行单元使用，但对 ir_vrt 的依赖跟踪逻辑本身透明。

---

## 13. flush 恢复与复位

### 13.1 flush 恢复的来源

flush 分为两种（参考子模块第 332~333 行）：

| 信号 | 来源 | 含义 |
|------|------|------|
| `rtu_idu_flush_fe` | RTU，前端 flush | 分支预测失败/异常等，整条 fetch-decode 流水线清洗 |
| `rtu_idu_flush_is` | RTU，IS 级 flush | IS 阶段以后的 flush（指令已入发射队列后的异常/重定向） |

两种 flush 都会将所有表项的 `rdy` 和 `wb` 恢复为 1，但不更新 `vreg` 字段。

### 13.2 rtu_idu_rt_recover_vreg 的作用

```verilog
// ir_vrt.v 第 128 行
input [191:0] rtu_idu_rt_recover_vreg;
```

这个 192 位信号（32 × 6 = 192 位）携带了 flush 后每个架构向量寄存器应使用的 vreg 映射（来自 ROB 检查点）。当 flush 发生时，ir_vrt 需要用这些值**重写**每个表项的 vreg 字段，恢复到 flush 对应的正确映射状态。

这对应于 ir_frt 中的 `frt_recover_updt_freg` 逻辑（第 2951~2955 行）：
```verilog
assign frt_recover_updt_vld         = ifu_xx_sync_reset || rtu_yy_xx_flush;
assign frt_recover_updt_freg[191:0] = (ifu_xx_sync_reset)
                                      ? frt_reset_updt_freg[191:0]
                                      : rtu_idu_rt_recover_freg[191:0];
```

同样地，ir_vrt 的 flush 恢复逻辑为：
```verilog
// ir_vrt 中对应逻辑（设计同构）
assign vrt_recover_updt_vld         = ifu_xx_sync_reset || rtu_yy_xx_flush;
assign vrt_recover_updt_vreg[191:0] = (ifu_xx_sync_reset)
                                      ? {6'd31,...,6'd0}  // 复位：恒等映射
                                      : rtu_idu_rt_recover_vreg[191:0]; // flush：ROB 检查点
```

### 13.3 复位时的恒等映射

上电复位（`ifu_xx_sync_reset`）时，向量寄存器映射初始化为恒等映射：
- v0 → vreg 0, v1 → vreg 1, ..., v31 → vreg 31

这与浮点表的初始化（f0→fr0, ..., f31→fr31）一致，是寄存器堆上电后的初始状态。

### 13.4 flush 优先级

flush 恢复写操作的优先级**最高**，覆盖任何同周期的正常指令写操作（参考 frt 第 2961~2965 行的 `reg_write_en` 生成）。这确保了 flush 恢复的完整性和正确性。

---

## 14. 当前 RTL 状态：占位模块说明

**重要提示**：当前 `ct_idu_ir_vrt.v` 文件（518 行）是一个**占位（stub/placeholder）模块**。其中所有输出均被硬连线为常量：

```verilog
// ir_vrt.v 第 487~512 行
assign vrt_dp_inst01_srcv2_match    = 1'b0;
// ...
assign vrt_dp_inst0_srcv0_data[8:0] = 9'b100000011;
assign vrt_dp_inst0_srcv1_data[8:0] = 9'b100000011;
assign vrt_dp_inst0_srcv2_data[9:0] = 10'b1000000111;
assign vrt_dp_inst0_srcvm_data[8:0] = 9'b100000011;
// （inst1~inst3 相同）
```

**常量值分析：**

| 输出 | 常量值 | 位格式解析 |
|------|--------|-----------|
| `srcvX_data[8:0]` | `9'b100000011` | [0]=rdy=1, [1]=wb=1, [8:2]=vreg=7'b1000000=64 |
| `srcv2_data[9:0]` | `10'b1000000111` | [0]=rdy=1, [1]=wb=1, [9]=mla_rdy=1, [8:2]=vreg=7'b1000001=65 |
| `srcvXY_match` | `1'b0` | 无同包前递 |
| `instN_rel_vreg` | `7'b0` | 无需释放旧 vreg |

**常量含义：** 所有向量源操作数都被视为"就绪且已写回"（rdy=1, wb=1），这相当于禁用了向量相关性跟踪，发射队列中的向量指令将立即被视为可发射。这是一种**保守但功能正确的简化**：向量指令只要在发射队列中，就假设其源操作数已经就绪。

在完整实现中（非占位），这些常量会被替换为上述各节描述的完整逻辑（34 个表项的查找、旁路检测、mla_rdy 跟踪等）。文件头部注释中的大量 `&Instance`、`&CombBeg/&CombEnd` 宏（第 196~420 行）是完整实现的模板标注，由代码生成工具（T-Head 内部的 RTL 生成框架）展开。

---

## 15. 上下游接口总结

### 15.1 上游（输入来源）

| 信号类别 | 来源模块 | 说明 |
|----------|----------|------|
| `dp_vrt_instN_*` | `ct_idu_ir_dp` | IR 数据通路输出的指令解码信息 |
| `rtu_idu_alloc_vregN` | RTU | 为各指令槽分配的物理向量寄存器号 |
| `rtu_idu_rt_recover_vreg` | RTU | flush 恢复向量（ROB 检查点） |
| `rtu_idu_flush_fe/is` | RTU | 流水线 flush 信号 |
| `vfpu_idu_ex1/2/3_pipe6/7_*` | VFPU | 执行单元各级就绪/写回广播 |
| `lsu_idu_ag/dc/wb_pipe3_*` | LSU | 向量 load 流水线状态广播 |
| `ctrl_xx_rf_pipe6/7_vmla_lch_vld_dupx` | RF 控制 | 乘加锁存就绪信号 |
| `dp_xx_rf_pipe6/7_dst_vreg_dupx` | RF 数据通路 | 乘加目的寄存器（用于 vmla_data_ready 比对） |

### 15.2 下游（输出去向）

| 信号类别 | 去向模块 | 说明 |
|----------|----------|------|
| `vrt_dp_instN_srcvX_data` | `ct_idu_ir_dp` | 源操作数依赖信息，经 MUX 后进入 IS 数据总线 |
| `vrt_dp_instN_rel_vreg` | `ct_idu_ir_dp` | 旧目的 vreg 编号，用于 RTU 回收 |
| `vrt_dp_instNM_srcv2_match` | `ct_idu_ir_dp` | 同包 srcv2 前递信号，合并进 `dp_ir_src_match` |

### 15.3 数据流图

```
         FE 阶段（取指/预译码/分发）
               ↓ IR_DATA（指令数据总线）
         ir_dp（IR 数据通路）
         ├── 整数: dp_rt_*  → irt → rt_dp_*
         ├── 浮点: dp_frt_* → frt → frt_dp_*   ┐
         └── 向量: dp_vrt_* → vrt → vrt_dp_*   ┘
                              ↓ (frt/vrt 输出 MUX)
                         ir_rt_instN_srcvX_data
                              ↓
                    dp_ir_instN_data（IS 总线）
                              ↓
                 viq0 / viq1（向量发射队列）
                              ↓
                     VFPU pipe6 / pipe7
```

---

## 附录：关键 IR 数据总线字段索引

来自 `ct_idu_ir_dp.v`（第 1100~1140 行），向量相关字段：

| 参数名 | 位索引 | 含义 |
|--------|--------|------|
| `IR_VMLA` | 134 | 向量乘加标志 |
| `IR_DSTV_REG` | 105:100 | 目的向量架构寄存器号（6 位，bit105 为高位） |
| `IR_DSTV_VLD` | 99 | 有向量目的寄存器 |
| `IR_SRCVM_VLD` | 98 | 使用 v0 掩码 |
| `IR_SRCV2_VLD` | 97 | 第三向量源有效（乘加累加） |
| `IR_SRCV1_REG` | 96:91 | vs2 寄存器号 |
| `IR_SRCV1_VLD` | 90 | vs2 有效 |
| `IR_SRCV0_REG` | 89:84 | vs1 寄存器号 |
| `IR_SRCV0_VLD` | 83 | vs1 有效 |
| `IR_VLMUL` | ~152:151 | 向量寄存器组因子 LMUL |
| `IR_VSEW` | ~154:152 | 元素宽度 SEW |
| `IR_SPLIT` | 116 | 指令拆分标志 |
| `IR_SPLIT_LAST` | 135 | 最后一个拆分子指令 |

（具体位索引参见 ir_dp.v 中的完整 parameter 定义，此处仅列出向量相关部分。）
