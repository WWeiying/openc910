# C910 IDU IR 阶段——浮点/向量标量重命名表 `ct_idu_ir_frt`

> **定位**：`ct_idu_ir_frt` 是 IR（寄存器重命名）阶段三个重命名表之一，专门
> 管理浮点与向量标量寄存器（架构寄存器 f0–f31 以及向量扩展中的 v0–v0 的标量
> 视图）。读完本文档应能独立理解：表结构与表项格式、四发射写端口逻辑、33 条
> 物理寄存器 vreg 的概念、三源操作数（srcf0/srcf1/srcf2）及 FMA 就绪位
> mla_rdy、同周期包内依赖旁路、flush/reset 恢复，以及向量/浮点发射队列需要
> 的依赖信息（dep_info）。
>
> RTL 源文件：`C910_RTL_FACTORY/gen_rtl/idu/rtl/ct_idu_ir_frt.v`（共 6114 行）
> 表项子模块：`ct_idu_dep_vreg_srcv2_entry.v`

---

## 目录

1. [模块概述](#1-模块概述)
2. [与整数重命名表 ir_rt 的对比](#2-与整数重命名表-ir_rt-的对比)
3. [端口说明](#3-端口说明)
4. [寄存器重命名表结构](#4-寄存器重命名表结构)
5. [表项子模块 ct_idu_dep_vreg_srcv2_entry](#5-表项子模块-ct_idu_dep_vreg_srcv2_entry)
6. [写端口逻辑（分配与更新）](#6-写端口逻辑分配与更新)
7. [读端口逻辑（查表）](#7-读端口逻辑查表)
8. [三源操作数与 FMA mla_rdy 机制](#8-三源操作数与-fma-mla_rdy-机制)
9. [同周期包内依赖旁路](#9-同周期包内依赖旁路)
10. [fmov 指令的特殊旁路链](#10-fmov-指令的特殊旁路链)
11. [目的寄存器的 rel_freg / rel_ereg 生成](#11-目的寄存器的-rel_freg--rel_ereg-生成)
12. [依赖信息参数（dep_info）](#12-依赖信息参数dep_info)
13. [Flush 与 Reset 恢复](#13-flush-与-reset-恢复)
14. [时钟门控](#14-时钟门控)
15. [关键信号速查表](#15-关键信号速查表)

---

## 1. 模块概述

### 1.1 职责

`ct_idu_ir_frt` 在 IR 阶段完成以下工作：

1. **建立并维护 freg（浮点架构寄存器编号 f0–f31）→ vreg（物理向量寄存器编号）的映射**。
   每个架构寄存器对应一张"表项"，表项记录当前最新的重命名目标物理寄存器及其就绪状态。
2. **查表**：每周期为 4 条待发射指令（inst0–inst3）的最多三个源操作数（srcf0/srcf1/srcf2）
   提供重命名后的物理寄存器编号及就绪/写回标志。
3. **同周期包内旁路**：若同一发射包中较早的指令写入了某架构寄存器，后续指令对同一架构
   寄存器的读取直接旁路，无需等待下周期写入表项。
4. **提供 rel_freg / rel_ereg**：供退休单元（RTU）/发射队列在指令完成后释放老映射使用。
5. **支持 flush/reset 恢复**：接收 RTU 送来的检查点（PST）重建映射，或在 sync_reset 时
   恢复到初始映射（freg_i → vreg_i）。

### 1.2 为什么比整数表大——浮点与向量寄存器空间共享

C910 遵循 RISC-V V 扩展的设计规范：**浮点寄存器 f0–f31 与向量寄存器 v0–v31 共享同一套
物理向量寄存器文件（VFPU 侧的 PRF）**。因此：

- 架构上看：浮点指令写 f0–f31（6 位架构编号，`dp_frt_instX_dstf_reg[5:0]`），范围 0–31。
  向量元素操作（包括浮点向量）的目的寄存器同样落在同一 vreg 空间。
- 物理上看：物理向量寄存器（vreg）以 7 位宽编码（`[6:0]`），支持多于 32 个物理寄存器，
  从而提供寄存器重命名所需的寄存器池空间。
- **第 33 条特殊表项**（`reg_32`）：`dstf_reg[5]` 为 1 时，该指令向量目的寄存器采用
  显式分配（由上游传入 `dst_freg[5:0]`，不经本表查映射），专门处理向量扩展中超出 f0–f31
  范围的隐式依赖（split 指令）。`reg_32` 的 create_freg 取 `frt_recover_updt_freg` 的
  第 0 位（即 6'd0），复位时不做恢复，始终从 0 初始化。

由于浮点与向量共享 vreg 物理寄存器文件，`ir_frt` 管理的 33 个表项（`reg_0`–`reg_32`）
所记录的物理寄存器 vreg 宽度为 **7 位**，而整数表 `ir_rt` 记录的物理寄存器 preg 宽度
同样是 7 位（但物理寄存器文件不同）。

### 1.3 在 IR 三表体系中的位置

```
IR 阶段重命名表
├── ct_idu_ir_rt    整数重命名表（x0–x31 → preg，整数 PRF）
├── ct_idu_ir_frt   浮点/向量标量重命名表（f0–f31 → vreg，向量 PRF） ← 本文档
└── ct_idu_ir_rt_e  扩展状态寄存器重命名表（frm/fsr 等）
```

---

## 2. 与整数重命名表 ir_rt 的对比

| 维度 | `ct_idu_ir_rt`（整数表） | `ct_idu_ir_frt`（浮点/向量表） |
|------|--------------------------|-------------------------------|
| 架构寄存器 | x0–x31（5 位） | f0–f31（6 位，bit5 表示 split 目的） |
| 物理寄存器 | preg（7 位，整数 PRF） | vreg（7 位，向量/浮点 PRF） |
| 表项数 | 33（reg_0–reg_32） | 33（reg_0–reg_32） |
| 表项子模块 | `ct_idu_dep_preg_entry` | `ct_idu_dep_vreg_srcv2_entry` |
| 源操作数数量 | src0, src1, src2（但 src2 = 自身 dst，用于 MLA 场景） | srcf0, srcf1, srcf2（三个独立查表路径）|
| FMA/MLA 就绪位 | `mla_rdy`（仅 src0、src2 携带） | `mla_rdy`（srcf0、srcf2 携带，srcf1 无 mla_rdy） |
| 执行管线 | pipe0/pipe1（整数） | pipe6/pipe7（VFPU 向量/浮点）+ pipe3（LSU 向量 load）|
| wb 更新来源 | IU EX2 写回 | VFPU EX5 写回 + LSU pipe3 写回 |
| 额外 ereg | 无 | 有 `ereg`（浮点状态扩展寄存器，rel_ereg 用） |
| fmov 旁路 | `mov` 信号 | `fmov` 信号（且有完整 fmov_bypass_over_instN 保护链） |
| 复位初始映射 | freg_i → preg_i（0–31 + 32=0） | freg_i → vreg_i（0–31，reg_32 → 0） |

**关键相同点**：
- 两表均以架构寄存器编号低 5 位（[4:0]）索引 reg_0–reg_31，bit5=1 对应 reg_32。
- 均使用 `ct_rtu_expand_32` 将 5 位目的寄存器展开成 32 位 one-hot 向量，再
  通过 bit[5] 判断是否写 reg_32。
- 均支持四写端口（inst0–inst3），写优先级 3 > 2 > 1 > 0 > recover。
- 均有 `freg_entry_no_rdy` / `preg_entry_no_rdy` 门控信号驱动顶层时钟门。

---

## 3. 端口说明

### 3.1 控制类输入

| 信号 | 位宽 | 说明 |
|------|------|------|
| `ctrl_ir_stall` | 1 | IR 阶段停顿；stall 时禁止写入表（但门控使能仍有效） |
| `ctrl_rt_instX_vld` | 1×4 | inst0–inst3 在本周期是否有效 |
| `rtu_yy_xx_flush` | 1 | 全局 flush，触发从 PST 检查点恢复 |
| `rtu_idu_flush_fe/is` | 1×2 | 前端/IS 阶段 flush，传递给表项内部 flush ready/wb 位 |
| `ifu_xx_sync_reset` | 1 | 同步复位，恢复出厂初始映射 |

### 3.2 指令数据通路输入（以 inst0 为例，inst1–inst3 类似）

| 信号 | 位宽 | 说明 |
|------|------|------|
| `dp_frt_inst0_dstf_reg[5:0]` | 6 | 目的浮点架构寄存器（bit5=1 表示 split/向量隐式 dst） |
| `dp_frt_inst0_dstf_vld` | 1 | 目的 freg 有效 |
| `dp_frt_inst0_dst_freg[5:0]` | 6 | 目的物理 vreg（入表的新物理寄存器编号） |
| `dp_frt_inst0_dste_vld` | 1 | 目的扩展寄存器（ereg）有效（浮点状态，如 fflags） |
| `dp_frt_inst0_dst_ereg[4:0]` | 5 | 目的扩展寄存器物理编号 |
| `dp_frt_inst0_srcfX_reg[5:0]` | 6×3 | srcf0/1/2 浮点架构寄存器 |
| `dp_frt_inst0_srcfX_vld` | 1×3 | srcf0/1/2 有效 |
| `dp_frt_inst0_fmla` | 1 | 本指令是否是浮点 MLA（融合乘加类），控制 mla_rdy 使用 |
| `dp_frt_inst0_fmov` | 1 | 本指令是否是浮点 MOV，控制 srcf0 读出值向包内后续指令旁路 |
| `dp_rt_dep_info[16:0]` | 17 | 包内依赖掩码，抑制不应旁路的同架构寄存器匹配 |

> **注**：inst3 没有 `fmov` 输入端口（从端口声明可见），因为 inst3 是包内最后一条
> 指令，其 fmov 旁路信息不会被后续指令使用，无需传入。

### 3.3 执行管线反馈输入（表项就绪位更新来源）

| 信号组 | 说明 |
|--------|------|
| `vfpu_idu_ex1_pipe6/7_data_vld_dupx`，`vreg_dupx` | VFPU pipe6/7 在 EX1 阶段产生数据（3 周期指令，EX1 等效于 EX3-2），更新 rdy |
| `vfpu_idu_ex2_pipe6/7_data_vld_dupx`，`vreg_dupx` | VFPU EX2 阶段产生数据（4 周期指令） |
| `vfpu_idu_ex3_pipe6/7_data_vld_dupx`，`vreg_dupx` | VFPU EX3 阶段产生数据（5 周期指令） |
| `vfpu_idu_ex5_pipe6/7_wb_vreg_dupx`，`_vld_dupx` | VFPU EX5 最终写回，更新 wb 位 |
| `lsu_idu_ag_pipe3_vload_inst_vld`，`vreg_dupx` | LSU AG 阶段向量 load 启动，用于 lsu_match |
| `lsu_idu_dc_pipe3_vload_inst_vld_dupx`，`vreg_dupx` | LSU DC 阶段向量 load，更新 rdy |
| `lsu_idu_wb_pipe3_wb_vreg_dupx`，`_vld_dupx` | LSU pipe3 写回，更新 wb 位 |
| `ctrl_xx_rf_pipe6/7_vmla_lch_vld_dupx` | VFPU MLA 锁存有效，更新 mla_rdy（专用于 VMLA 场景） |
| `dp_xx_rf_pipe6/7_dst_vreg_dupx` | VFPU RF 阶段目的 vreg（与上述配合使用） |

### 3.4 输出

| 信号 | 位宽 | 说明 |
|------|------|------|
| `frt_dp_instX_srcfY_data` | srcf0/1: 9 位；srcf2: 10 位 | 源操作数依赖信息（vreg + 就绪标志）|
| `frt_dp_instX_rel_freg[6:0]` | 7 | 该指令目的寄存器所关联的"旧映射"物理 vreg，供 RTU 释放 |
| `frt_dp_instX_rel_ereg[4:0]` | 5 | 旧扩展寄存器编号，供 RTU 释放 |
| `frt_dp_inst01_srcf2_match` 等 | 1×5 | srcf2 的同包旁路命中信号，传递给依赖信息生成逻辑 |

---

## 4. 寄存器重命名表结构

### 4.1 整体组织

```
ct_idu_ir_frt
├── reg_0  (freg 0)  → ct_idu_dep_vreg_srcv2_entry
├── reg_1  (freg 1)  → ct_idu_dep_vreg_srcv2_entry
├── ...
├── reg_31 (freg 31) → ct_idu_dep_vreg_srcv2_entry
└── reg_32 (split/向量隐式 dst 的特殊条目)
                     → ct_idu_dep_vreg_srcv2_entry

另有一个独立的 ereg 寄存器（单个 5 位寄存器，不用表项子模块）
```

共 **33 个 `ct_idu_dep_vreg_srcv2_entry` 实例** + 1 个 ereg 寄存器。

### 4.2 表项（create_data）编码——写入格式 [10:0]

每次写入表项时送入的 `x_create_data[10:0]`：

```
[10]   x_create_lsu_match  — LSU match 位（在 ir_frt 中写入时置 0，因为 ir 阶段不需要）
[9]    x_create_mla_rdy    — MLA 就绪位初始值（ir 阶段新指令写入时 = r_vld，即恢复时为 1）
[8:2]  x_create_vreg[6:0]  — 新物理向量寄存器编号（7 位）
[1]    x_create_wb         — 写回位初始值（r_vld = 1 表示恢复时认为已写回）
[0]    x_create_rdy        — 就绪位初始值（r_vld = 1 表示恢复时认为就绪）
```

在 `ir_frt` 中：

```verilog
// 行 3853（以 reg_0 为例）
assign r_vld = frt_recover_updt_vld;
assign reg_0_create_data[10:0] = {1'b0, r_vld, 1'b0, reg_0_create_freg[5:0], {2{r_vld}}};
```

- **正常发射**（inst 写入新映射）：`r_vld = 0`，`create_data = {1'b0, 1'b0, 1'b0, vreg, 2'b00}`
  — rdy=0、wb=0 说明该物理寄存器结果尚未产生，源依赖该 vreg 的指令需等待。
- **Flush/Reset 恢复**：`r_vld = 1`，`create_data = {1'b0, 1'b1, 1'b0, vreg, 2'b11}`
  — rdy=1、wb=1 说明恢复后认为结果已在 PRF，指令可立刻读取。

### 4.3 表项读出格式 [12:0]

```
[12]   x_read_lsu_match   — 当前是否有 LSU load 正在处理同一 vreg
[11]   x_read_rdy_for_bypass — bypass 用就绪位（= rdy 本身）
[10]   x_read_rdy_for_issue  — issue 用就绪位（含 mla_rdy / lsu fwd 等更早就绪信号）
[9]    x_read_mla_rdy     — MLA 专用就绪位（比普通 rdy 早 1 周期）
[8:2]  x_read_vreg[6:0]   — 当前映射的物理 vreg
[1]    x_read_wb          — 结果已写回 PRF
[0]    x_read_rdy         — 预测结果已就绪（可前递）
```

顶层 `ir_frt` 使用 `reg_X_read_data[12:0]` 访问读出值，各字段拆分：

```verilog
// 行 3995–3998（inst0 srcf0 为例）
assign inst0_srcf0_read_rdy       = inst0_srcf0_read_data[0];
assign inst0_srcf0_read_wb        = inst0_srcf0_read_data[1];
assign inst0_srcf0_read_freg[5:0] = inst0_srcf0_read_data[7:2];  // 注：只取低 6 位
assign inst0_srcf0_read_mla_rdy   = inst0_srcf0_read_data[9];
```

注意：读出的 vreg 为 7 位（`x_read_vreg[6:0]`），但 `ir_frt` 向 IQ 传出的
`frt_dp_instX_srcfY_data[8:2]` 也是 7 位（其中 [8]=1'b0 填充，[7:2]=vreg[5:0]），
实际有效位宽 6 位（覆盖 0–63 的 vreg 物理寄存器空间使用 bit6 区分）。

---

## 5. 表项子模块 `ct_idu_dep_vreg_srcv2_entry`

该模块是 `ir_frt` 中每个架构浮点寄存器对应的"动态状态跟踪器"，其核心包含四个状态寄存器：

### 5.1 rdy（就绪位）

```verilog
// entry 模块 行 319–338
assign rdy_update = (rdy || data_ready || wake_up) && !rdy_clear;
```

更新逻辑：

| 条件 | 动作 |
|------|------|
| flush_fe 或 flush_is | rdy ← 1 |
| 新指令写入（x_write_en） | rdy ← x_create_rdy（正常分配时 =0） |
| VFPU pipe6/7 EX1/2/3 播报 vreg 匹配 | rdy ← 1 |
| LSU DC 阶段 load 完成且 vreg 匹配 | rdy ← 1 |
| wb=1（结果已写回 PRF） | rdy ← 1（wake_up = wb） |

**为什么要有 rdy 和 wb 两个位**：`rdy` 表示"预测可前递"（在管线某中间阶段就绪，
可提前唤醒 IQ 中的依赖者）；`wb` 表示"已落盘 PRF"（依赖者可直接读 PRF）。

### 5.2 mla_rdy（融合乘加专用就绪位）

```verilog
// entry 模块 行 367–395
assign vfpu0_fmla_data_ready = x_entry_vmla
                               && vfpu_idu_ex2_pipe6_fmla_data_vld_dupx
                               && (vfpu_idu_ex2_pipe6_vreg_dupx == vreg)
                            || x_entry_vmla
                               && vfpu_idu_ex1_pipe6_fmla_data_vld_dupx
                               && (vfpu_idu_ex1_pipe6_vreg_dupx == vreg);
// vfpu1 类似...
assign vfpu0_vmla_data_ready  = x_entry_vmla
                                && ctrl_xx_rf_pipe6_vmla_lch_vld_dupx
                                && (dp_xx_rf_pipe6_dst_vreg_dupx == vreg);
```

- `x_entry_vmla`：在 `ir_frt` 中对所有 33 个表项**恒置 1**（行 2702–2734），意味着
  浮点/向量表的所有表项都支持 VMLA 提前就绪机制。
- 浮点 FMA（fused multiply-add）的累加数 srcf2 需要在第一次乘法完成之前就准备好，
  使用 `fmla_data_vld` 信号在 EX1/EX2 阶段就将 `mla_rdy` 置 1，让 FMA 可以更早接收
  累加源（srcf2）。这样可减少 FMA 流水线因等待 srcf2 而引入的气泡。

### 5.3 wb（写回位）

```verilog
// entry 模块 行 425–449
assign pipe3_wb = lsu_idu_wb_pipe3_wb_vreg_vld_dupx
                  && (lsu_idu_wb_pipe3_wb_vreg_dupx == vreg);
assign pipe6_wb = vfpu_idu_ex5_pipe6_wb_vreg_vld_dupx
                  && (vfpu_idu_ex5_pipe6_wb_vreg_dupx == vreg);
assign pipe7_wb = vfpu_idu_ex5_pipe7_wb_vreg_vld_dupx
                  && (vfpu_idu_ex5_pipe7_wb_vreg_dupx == vreg);
```

三条 wb 来源：LSU pipe3（向量 load 写回）、VFPU pipe6 EX5、VFPU pipe7 EX5。
一旦写回，wb 位就置 1 并保持（直到表项被新指令覆写）。

### 5.4 lsu_match

```verilog
// entry 模块 行 343–358
assign lsu_match_update = lsu_idu_ag_pipe3_vload_inst_vld
                          && (lsu_idu_ag_pipe3_vreg_dupx == vreg);
```

记录"当前有一条 LSU load 正在 AG 阶段处理本 vreg"，用于 load-use 旁路判断。
`ir_frt` 中旁路信号 `lsu_idu_dc_pipe3_vload_fwd_inst_vld` 恒置 0（行 2741），
意味着**IR 阶段不使用 load 旁路**（因为 IR 是顺序流水，指令还未进 IQ，
旁路仅在 IS/RF 阶段生效）。

---

## 6. 写端口逻辑（分配与更新）

### 6.1 写使能生成

```verilog
// 行 2852–2855（inst0 为例）
assign inst0_write_en = ctrl_rt_inst0_vld
                        && !ctrl_ir_stall
                        && !frt_recover_updt_vld
                        &&  dp_frt_inst0_dstf_vld;
```

- stall 时不写（但门控使能 `inst0_gateclk_write_en` 忽略 stall，用于时序优化）。
- flush/recover 时优先 recover，屏蔽正常写入。

### 6.2 目的寄存器译码到 33 位 one-hot

```verilog
// 行 2817（抽取低 5 位索引）
assign dp_frt_inst0_dstf_reg_lsb[4:0] = dp_frt_inst0_dstf_reg[4:0];

// 行 2856–2859（one-hot 展开后按 bit5 分叉）
assign reg_write0_en[31:0] = dp_frt_inst0_dstf_reg_lsb_expand[31:0]
                             & {32{inst0_write_en && !dp_frt_inst0_dstf_reg[5]}};
assign reg_write0_en[32]   = dp_frt_inst0_dstf_reg_lsb_expand[0]
                             && inst0_write_en && dp_frt_inst0_dstf_reg[5];
```

- **bit5=0**：目的是普通浮点寄存器 f0–f31，通过 `ct_rtu_expand_32` 展开为 32 位
  one-hot，写对应的 reg_0–reg_31。
- **bit5=1**：目的是 split 隐式目的（超出 f0–f31 范围），统一写 reg_32（利用
  expand[0] && bit5 的组合，强制写第 32 项）。

这种设计使得 reg_32 作为"溢出槽"，专门收纳 split 向量指令的隐式目的寄存器依赖。

### 6.3 四写端口优先级与数据选择

每个 reg_X 的写数据通过 always @(comb) 块实现优先级仲裁（以 reg_0 为例）：

```verilog
// 行 3102–3113
if(reg_gateclk_write3_en[0])
    reg_0_create_freg = dp_frt_inst3_dst_freg[5:0];
else if(reg_gateclk_write2_en[0])
    reg_0_create_freg = dp_frt_inst2_dst_freg[5:0];
else if(reg_gateclk_write1_en[0])
    reg_0_create_freg = dp_frt_inst1_dst_freg[5:0];
else if(reg_gateclk_write0_en[0])
    reg_0_create_freg = dp_frt_inst0_dst_freg[5:0];
else
    reg_0_create_freg = frt_recover_updt_freg[5:0];
```

**优先级 inst3 > inst2 > inst1 > inst0 > recover**。

这反映了"程序序更晚的指令覆盖更早的指令的目的寄存器"的重命名原则：
在同一周期内如果两条指令写同一架构寄存器（WAW 依赖），以最新的那条为准。

### 6.4 ereg 写逻辑

浮点状态寄存器（fflags/frm 等）的目的 ereg 只有一个专用 5 位寄存器（不是 33 个表项）：

```verilog
// 行 3887–3914
if(ctrl_rt_inst3_vld && dp_frt_inst3_dste_vld && !frt_recover_updt_vld)
    reg_e_create_ereg = dp_frt_inst3_dst_ereg;
else if(ctrl_rt_inst2_vld && dp_frt_inst2_dste_vld && !frt_recover_updt_vld)
    reg_e_create_ereg = dp_frt_inst2_dst_ereg;
...
else
    reg_e_create_ereg = frt_recover_updt_ereg;
```

ereg 只有一个当前值，不需要 per-架构寄存器的表结构，因为浮点状态寄存器在
RISC-V 架构上是隐式写入（每条浮点指令都可能修改 fflags），本质上是单一的
"当前写入者追踪"。

---

## 7. 读端口逻辑（查表）

### 7.1 通用模式

每个源操作数（inst0_srcf0/1/2、inst1_srcf0/1/2 ... inst3_srcf2）各有一个
33-to-1 的 case 查表块，以 `dp_frt_instX_srcfY_reg[5:0]` 为索引，
选出对应 `reg_N_read_data[12:0]`：

```verilog
// 行 3956–3992（inst0 srcf0 为例）
case (dp_frt_inst0_srcf0_reg[5:0])
  6'd0  : inst0_srcf0_read_data = reg_0_read_data;
  6'd1  : inst0_srcf0_read_data = reg_1_read_data;
  ...
  6'd32 : inst0_srcf0_read_data = reg_32_read_data;
  default: inst0_srcf0_read_data = {13{1'bx}};
endcase
```

注意这里支持 6'd32（对应 split 目的槽），但架构浮点寄存器只有 f0–f31（0–31），
f32 作为 split 源索引不会出现在正常 RISC-V 指令的 srcf 字段，因此 `default`
在正常运行中不会被命中。

### 7.2 输出打包

读出数据经过字段拆分后打包为 src_data 输出：

**srcf0 / srcf1 输出格式（9 位）**：

```verilog
// 行 4000–4004（inst0 srcf0）
assign frt_dp_inst0_srcf0_data[0]   = inst0_srcf0_read_rdy || !dp_frt_inst0_srcf0_vld;
assign frt_dp_inst0_srcf0_data[1]   = inst0_srcf0_read_wb  || !dp_frt_inst0_srcf0_vld;
assign frt_dp_inst0_srcf0_data[8:2] = {1'b0, inst0_srcf0_read_freg[5:0]};
```

| 位 | 含义 |
|----|------|
| [0] | rdy（就绪）或源无效（认为就绪） |
| [1] | wb（已写回）或源无效 |
| [8:2] | 物理 vreg（7 位，高位补 0） |

**srcf2 输出格式（10 位，比 srcf0/1 多 1 位 mla_rdy）**：

```verilog
// 行 4179–4186（inst0 srcf2）
assign frt_dp_inst0_srcf2_data[9]   = inst0_srcf2_read_rdy || !dp_frt_inst0_srcf2_vld;
assign frt_dp_inst0_srcf2_data[0]   = inst0_srcf2_read_mla_rdy && dp_frt_inst0_fmla
                                      || !dp_frt_inst0_srcf2_vld;
assign frt_dp_inst0_srcf2_data[1]   = inst0_srcf2_read_wb  || !dp_frt_inst0_srcf2_vld;
assign frt_dp_inst0_srcf2_data[8:2] = {1'b0, inst0_srcf2_read_freg[5:0]};
```

| 位 | 含义 |
|----|------|
| [9] | rdy（普通就绪） |
| [0] | mla_rdy（FMA 提前就绪），仅在 fmla=1 时有效 |
| [1] | wb（已写回） |
| [8:2] | 物理 vreg |

**设计原因**：srcf2 在浮点 FMA（`fadd` fma 形式）中扮演累加项（a*b+c 中的 c），
VFPU 管线允许乘法结果产生后 1 周期内完成加法，因此 srcf2 的 `mla_rdy` 可以比
普通 `rdy` 早 1 个周期置位。只有 srcf2 而非 srcf0/srcf1 需要这个额外的 mla_rdy
位，因为在 FMA 中乘数 srcf0/srcf1 必须在乘法开始前就绪，而 srcf2（累加数）
可以更晚到来。

---

## 8. 三源操作数与 FMA mla_rdy 机制

### 8.1 为什么浮点需要三个源

整数表 `ir_rt` 中的 src2 是目的寄存器（用于查询"旧映射"以便释放），
并非真正独立的源操作数。

浮点/向量表 `ir_frt` 中的 srcf2 是**真正独立的第三个源寄存器**，对应：

- RISC-V F 扩展：`FMADD.S rd, rs1, rs2, rs3`（rs3 = srcf2）
- RISC-V F 扩展：`FMSUB.S`, `FNMSUB.S`, `FNMADD.S` 等融合乘加变体
- RISC-V V 扩展：`vmacc.vv`, `vfmacc.vv` 等向量乘加累加指令

在 C910 的 4 发射窗口中，每条指令最多可以有 srcf0、srcf1、srcf2 三个浮点源，
且它们都需要独立查表获取重命名后的物理 vreg 和就绪状态。

### 8.2 mla_rdy 的工作原理

```
                        VFPU Pipe（FMA）时序示意
                        
  周期：       N     N+1    N+2    N+3    N+4    N+5
  FMA A:   [EX1] [EX2]  [EX3]  [EX4]  [EX5]   WB
                  ↑                      ↑
            fmla_data_vld         ex5_wb_vreg_vld
            mla_rdy←1                  wb←1
  
  FMA B（依赖 FMA A 的结果 → 等待 srcf2）：
    正常发射：等到 rdy=1（EX3 后）才能发射，需等 N+2 周期
    FMA 优化：等到 mla_rdy=1（EX2 后）即可发射，早 1 周期
```

核心 RTL（entry 模块行 367–395）：

```verilog
// FMA A 在 EX1/EX2 阶段播报 fmla_data_vld，使依赖其结果的 FMA B 的 mla_rdy 提前置 1
assign vfpu0_fmla_data_ready = x_entry_vmla
                               && vfpu_idu_ex2_pipe6_fmla_data_vld_dupx
                               && (vfpu_idu_ex2_pipe6_vreg_dupx == vreg)
                            || x_entry_vmla
                               && vfpu_idu_ex1_pipe6_fmla_data_vld_dupx
                               && (vfpu_idu_ex1_pipe6_vreg_dupx == vreg);
```

`ir_frt` 中所有表项的 `x_entry_vmla` 均固定为 1（行 2702–2734），确保所有浮点
/向量寄存器都能使用 mla_rdy 机制，而整数表 `ir_rt` 的对应信号来自 `dp_rt_instX_mla`，
只有标记为乘加指令的条目才启用该机制。

---

## 9. 同周期包内依赖旁路

C910 每周期最多发射 4 条指令（inst0–inst3），这 4 条指令按程序序排列。
若 inst1 的 srcf0 与 inst0 的 dstf_reg 相同，inst1 不能从表中读到正确的物理 vreg
（因为 inst0 的写操作将在本周期末才生效），必须在组合逻辑阶段做**包内旁路（intra-packet bypass）**。

### 9.1 旁路使能条件

以 inst2 的 srcf0 为例，它可能旁路 inst0 或 inst1 的结果：

```verilog
// 行 4892–4901
assign frt_inst2_srcf0_match_inst0 =
            ctrl_rt_inst2_vld && dp_frt_inst2_srcf0_vld
         && ctrl_rt_inst0_vld && dp_frt_inst0_dstf_vld
         && (dp_frt_inst0_dstf_reg[5:0] == dp_frt_inst2_srcf0_reg[5:0])
         && !dp_rt_dep_info[DEP_INST02_VREG_MASK];   // 依赖掩码排除
assign frt_inst2_srcf0_match_inst1 =
            ctrl_rt_inst2_vld && dp_frt_inst2_srcf0_vld
         && ctrl_rt_inst1_vld && dp_frt_inst1_dstf_vld
         && (dp_frt_inst1_dstf_reg[5:0] == dp_frt_inst2_srcf0_reg[5:0])
         && !dp_rt_dep_info[DEP_INST12_VREG_MASK];
```

`dp_rt_dep_info` 中的各位用于屏蔽"架构寄存器相同但实际上不是真依赖"的情况
（如 split 指令产生的隐式目的与正常源的"假匹配"），详见第 12 节。

### 9.2 旁路数据选择（srcf0/1 的简单情况）

当有旁路命中（且不是 fmov 场景）时，直接使用同包中较早指令的 `dst_freg`，
并将 rdy/wb 置 0（因为该指令还未执行，结果未就绪）：

```verilog
// 行 4933–4946
if(frt_inst2_srcf0_match_inst1) begin
    frt_dp_inst2_srcf0_data[0]   = 1'b0;  // rdy=0
    frt_dp_inst2_srcf0_data[1]   = 1'b0;  // wb=0
    frt_dp_inst2_srcf0_data[8:2] = {1'b0, dp_frt_inst1_dst_freg[5:0]};  // 新 vreg
end
else if(frt_inst2_srcf0_match_inst0) begin
    frt_dp_inst2_srcf0_data[0]   = 1'b0;
    frt_dp_inst2_srcf0_data[1]   = 1'b0;
    frt_dp_inst2_srcf0_data[8:2] = {1'b0, dp_frt_inst0_dst_freg[5:0]};
end
```

**为什么旁路时 rdy/wb 置 0**：被旁路的 inst1/inst0 此刻还未执行，其结果
当然尚未就绪。inst2 进入 IQ 后会等待 inst1/inst0 产生结果（通过广播唤醒机制）。

### 9.3 srcf2 的包内旁路带附加信号

srcf2 的旁路逻辑更复杂，因为需要同时确定 `frt_dp_instXY_srcf2_match` 标志
（用于 dep_info 生成）：

```verilog
// 行 5284–5324（inst2 srcf2 部分旁路逻辑）
else if(frt_inst2_srcf2_match_inst1) begin
    frt_dp_inst2_srcf2_data[9]   = 1'b0;   // rdy=0
    frt_dp_inst2_srcf2_data[0]   = 1'b0;   // mla_rdy=0
    frt_dp_inst2_srcf2_data[1]   = 1'b0;   // wb=0
    frt_dp_inst2_srcf2_data[8:2] = {1'b0, dp_frt_inst1_dst_freg[5:0]};
    
    frt_dp_inst12_srcf2_match    = 1'b1;   // 通知 dep_info：inst2.srcf2 依赖 inst1.dst
    frt_dp_inst02_srcf2_match    = 1'b0;
end
```

`srcf2_match` 信号输出到 `ct_idu_dp` 用于生成发射队列的 srcv1 依赖掩码
（`DEP_INST12_SRCV1_MASK` 等参数），以便 IS 阶段正确跟踪包内 srcf2 依赖。

---

## 10. fmov 指令的特殊旁路链

`fmov`（浮点 move 指令，形如 `fmv.d rd, rs1`）是一种特殊情况：其目的寄存器的
物理 vreg **来自 srcf0 所指向的旧映射**（即 fmov 并不申请新的 vreg，而是复用
源寄存器已有的 vreg 映射）。因此：

- `dp_frt_inst0_fmov = 1` 时，inst0 写入表的 vreg = `inst0_srcf0_read_freg`
  （而非上游分配器分配的新 vreg）。
- 如果 inst1 的 srcf0 命中 inst0 的 dstf_reg，且 inst0 是 fmov，则 inst1 应
  取 fmov 所指向的**原始 vreg**（而非 inst0 的"新" dst_freg）。

```verilog
// 行 4656–4684（inst1 srcf2 旁路 inst0 fmov 场景）
if(frt_inst1_srcf2_match_inst0 && dp_frt_inst0_fmov) begin
    frt_dp_inst1_srcf2_data[9]   = frt_inst0_fmov_dst_rdy;
    frt_dp_inst1_srcf2_data[0]   = frt_inst0_fmov_dst_mla_rdy;
    frt_dp_inst1_srcf2_data[1]   = frt_inst0_fmov_dst_wb;
    frt_dp_inst1_srcf2_data[8:2] = {1'b0, frt_inst0_fmov_dst_freg[5:0]};
    
    frt_dp_inst01_srcf2_match    = 1'b0;  // 旁路有效但不是"真依赖"标记
end
else if(frt_inst1_srcf2_match_inst0) begin   // 非 fmov 正常依赖
    ...
    frt_dp_inst01_srcf2_match    = 1'b1;
end
```

fmov 的"穿透读"来自：

```verilog
// 行 4007–4010
assign frt_inst0_fmov_dst_rdy       = inst0_srcf0_read_rdy;
assign frt_inst0_fmov_dst_mla_rdy   = inst0_srcf0_read_mla_rdy;
assign frt_inst0_fmov_dst_wb        = inst0_srcf0_read_wb;
assign frt_inst0_fmov_dst_freg[5:0] = inst0_srcf0_read_freg[5:0];
```

即 fmov 的"目的寄存器就绪信息"实际上就是其源寄存器（srcf0）的就绪信息。

**fmov_bypass_over_inst1 保护**：如果 inst1 的 dstf_reg 与 inst0 的 srcf0_reg 相同，
则 inst0 的 fmov_dst_freg 实际上已经被 inst1 覆盖，此时不应再将 inst0 的 fmov
旁路信息透传给 inst2（否则 inst2 会拿到错误的 vreg）：

```verilog
// 行 4905–4908
assign frt_inst0_fmov_bypass_over_inst1 =
    dp_frt_inst0_fmov
    && !(dp_frt_inst1_dstf_vld
         && (dp_frt_inst0_srcf0_reg[5:0] == dp_frt_inst1_dstf_reg[5:0]));
```

---

## 11. 目的寄存器的 rel_freg / rel_ereg 生成

`rel_freg`（release freg）是指 RTU 在指令退休时需要释放的"旧物理 vreg 映射"。
重命名的本质是：新指令写 f5 时，先读出 f5 当前对应的旧 vreg（旧映射），将
旧 vreg 记录在 IQ 项中，等新指令退休后再释放旧 vreg 回物理寄存器池。

### 11.1 普通目的寄存器（bit5=0）

```verilog
// 行 4266–4268（inst0 rel_freg）
assign frt_dp_inst0_rel_freg[6:0] = dp_frt_inst0_dstf_reg[5]
                                    ? {1'b0, dp_frt_inst0_dst_freg[5:0]}
                                    : {1'b0, inst0_dstf_read_freg[5:0]};
```

- **bit5=0（普通）**：从表中读 `dstf_reg` 对应的当前映射（`inst0_dstf_read_freg`），
  即"我覆盖了 fN，原来 fN 映射的是哪个 vreg"。
- **bit5=1（split）**：直接使用 `dst_freg`（上游已经算好了新 vreg），无需查表读旧映射。

### 11.2 同包旁路下的 rel_freg

若 inst1 与 inst0 写同一个 freg（inst1_dstf_match_inst0），则 inst0 的旧映射
同样是 inst1 需要的旧映射（因为 inst0 此时还未生效，表中读出的仍是 inst0 写之前的值）：

```verilog
// 行 4787–4790
if(frt_inst1_dstf_match_inst0)
    frt_dp_inst1_rel_freg = {1'b0, dp_frt_inst0_dst_freg[5:0]};
else
    frt_dp_inst1_rel_freg = {1'b0, inst1_dstf_read_freg[5:0]};
```

这里 `dp_frt_inst0_dst_freg`（而非 inst1 查表结果）被用作 inst1 的 rel_freg，
因为 inst0 会在本周期末更新 freg 表，inst1 的"旧映射"其实是 inst0 写入后的映射。

### 11.3 ereg 的 rel_ereg

ereg 只有一个全局值，旁路逻辑如下（以 inst2 为例）：

```verilog
// 行 5447–5460
assign frt_inst2_dste_match_inst0 = ctrl_rt_inst2_vld && dp_frt_inst2_dste_vld
                                 && ctrl_rt_inst0_vld && dp_frt_inst0_dste_vld;
assign frt_inst2_dste_match_inst1 = ...
// 行 5453–5459
if(frt_inst2_dste_match_inst1)
    frt_dp_inst2_rel_ereg = dp_frt_inst1_dst_ereg;
else if(frt_inst2_dste_match_inst0)
    frt_dp_inst2_rel_ereg = dp_frt_inst0_dst_ereg;
else
    frt_dp_inst2_rel_ereg = reg_e_read_ereg;
```

若同包内多条浮点指令都修改浮点状态（dste_vld），则按程序序的旧值是前一条指令
的 dst_ereg。

---

## 12. 依赖信息参数（dep_info）

`dp_rt_dep_info[16:0]` 由上游 `ct_idu_dp` 生成并传入，每一位是一个掩码，用于
在包内旁路匹配时**关闭不该旁路的假匹配**。

```verilog
// 行 827–845（参数定义）
parameter DEP_INST01_SRC0_MASK  = 0;   // inst1.src0 不从 inst0.dst 旁路
parameter DEP_INST01_SRC1_MASK  = 1;   // inst1.src1 不从 inst0.dst 旁路
parameter DEP_INST12_SRC0_MASK  = 2;
parameter DEP_INST12_SRC1_MASK  = 3;
parameter DEP_INST23_SRC0_MASK  = 4;
parameter DEP_INST23_SRC1_MASK  = 5;
parameter DEP_INST02_PREG_MASK  = 6;   // inst2 的整数寄存器不从 inst0 旁路
parameter DEP_INST13_PREG_MASK  = 7;
parameter DEP_INST01_VREG_MASK  = 8;   // inst1 的向量寄存器不从 inst0 旁路（srcf2 用）
parameter DEP_INST12_VREG_MASK  = 9;
parameter DEP_INST23_VREG_MASK  = 10;
parameter DEP_INST13_VREG_MASK  = 11;
parameter DEP_INST02_VREG_MASK  = 12;
parameter DEP_INST03_VREG_MASK  = 13;
parameter DEP_INST01_SRCV1_MASK = 14;  // srcf1（srcV1）的特殊掩码
parameter DEP_INST12_SRCV1_MASK = 15;
parameter DEP_INST23_SRCV1_MASK = 16;
```

**应用举例**：`DEP_INST12_VREG_MASK = 9` 对应 inst2 的 srcf0 旁路 inst1 dst 的场景。
若 dp 判定这是 split 指令的隐式源/目的对（不应旁路），置该位为 1，`frt` 中的旁路匹配
条件则通过 `&& !dp_rt_dep_info[DEP_INST12_VREG_MASK]` 屏蔽。

`DEP_INST12_SRCV1_MASK = 15` 是专门为 srcf1 设置的掩码，因为向量指令中
srcf1（srcV1）有特殊的依赖约束：

```verilog
// 行 5102–5107（inst2 srcf1 旁路 inst1 dst 的条件）
assign frt_inst2_srcf1_match_inst1 =
            ctrl_rt_inst2_vld && dp_frt_inst2_srcf1_vld
         && ctrl_rt_inst1_vld && dp_frt_inst1_dstf_vld
         && (dp_frt_inst1_dstf_reg[5:0] == dp_frt_inst2_srcf1_reg[5:0])
         && !(dp_rt_dep_info[DEP_INST12_VREG_MASK]
           || dp_rt_dep_info[DEP_INST12_SRCV1_MASK]);  // srcf1 有双重掩码
```

srcf1 同时受 `VREG_MASK` 和 `SRCV1_MASK` 约束，比 srcf0 更严格，原因是向量
multiply-accumulate 指令中 srcf1 的位置有特殊的隐式依赖语义，需要更精细的控制。

---

## 13. Flush 与 Reset 恢复

### 13.1 恢复触发条件

```verilog
// 行 2951–2957
assign frt_recover_updt_vld         = ifu_xx_sync_reset || rtu_yy_xx_flush;
assign frt_recover_updt_freg[191:0] = (ifu_xx_sync_reset)
                                     ? frt_reset_updt_freg[191:0]
                                     : rtu_idu_rt_recover_freg[191:0];
assign frt_recover_updt_ereg[4:0]   = (ifu_xx_sync_reset)
                                     ? 5'd0 : rtu_idu_rt_recover_ereg[4:0];
```

| 触发源 | 恢复数据来源 | 含义 |
|--------|-------------|------|
| `ifu_xx_sync_reset` | `frt_reset_updt_freg`（硬编码初始映射） | 处理器复位，重建 f_i→vreg_i 映射 |
| `rtu_yy_xx_flush` | `rtu_idu_rt_recover_freg`（PST 检查点） | 分支误预测或异常 flush，恢复到最近提交点 |

### 13.2 恢复映射格式

```verilog
// 行 2946–2950（复位初始映射）
assign frt_reset_updt_freg[191:0] =
         {6'd31, 6'd30, 6'd29, 6'd28, ..., 6'd1, 6'd0};
```

`frt_reset_updt_freg` 是一个 192 位向量（32 个 6 位字段），表示 f0→vreg_0,
f1→vreg_1, ..., f31→vreg_31 的初始一一映射。`rtu_idu_rt_recover_freg[191:0]`
具有相同的格式，由 RTU 中的 PST（Physical State Table/Checkpoint）提供。

每个表项的写入（reg_N_create_freg）从 `frt_recover_updt_freg` 中取对应字段：

```
freg[5:0]（6 位）×32 个寄存器 = 192 位
frt_recover_updt_freg[5:0]    → reg_0_create_freg（f0 的恢复映射）
frt_recover_updt_freg[11:6]   → reg_1_create_freg（f1 的恢复映射）
...
frt_recover_updt_freg[191:186] → reg_31_create_freg（f31 的恢复映射）
```

reg_32 在恢复时取 `6'd0`（行 3846），表示 split 槽复位到默认值。

### 13.3 表项内 flush 处理

在 `ct_idu_dep_vreg_srcv2_entry` 中，`flush_fe` 或 `flush_is` 会将 rdy/wb/mla_rdy
全部置 1（行 332–333, 410, 444），使得 flush 后所有寄存器对依赖者来说都"已就绪"，
避免悬挂的依赖。这与 `frt_recover_updt_vld` 时 `r_vld=1` 写入 rdy=1/wb=1 的效果一致。

---

## 14. 时钟门控

`ir_frt` 使用两级时钟门控以降低动态功耗：

### 14.1 顶层时钟门控

```verilog
// 行 852–872
assign frt_clk_en = rtu_idu_flush_fe
                    || rtu_idu_flush_is
                    || vfpu_idu_ex5_pipe6_wb_vreg_vld_dupx
                    || vfpu_idu_ex5_pipe7_wb_vreg_vld_dupx
                    || lsu_idu_wb_pipe3_wb_vreg_vld_dupx
                    || inst0_gateclk_write_en
                    || inst1_gateclk_write_en
                    || inst2_gateclk_write_en
                    || inst3_gateclk_write_en
                    || frt_recover_updt_vld
                    || freg_entry_no_rdy;
```

`freg_entry_no_rdy = !(&reg_read_rdy_bypass[32:0])` — 只要还有任何表项的 rdy 不为 1，
顶层时钟就必须保持开启（因为表项内部仍在等待就绪信号的传播）。

### 14.2 表项级门控

每个 `ct_idu_dep_vreg_srcv2_entry` 内有两个独立门控：

- `dep_clk`：由 `x_gateclk_write_en || gateclk_entry_vld && (!rdy || !wb)` 使能，
  驱动 rdy/wb/lsu_match/mla_rdy 寄存器的时钟。
- `write_clk`：由 `x_gateclk_idx_write_en` 使能，仅驱动 vreg 寄存器的时钟，
  仅在写入时开启。

这种双时钟域设计使得在无写入时，vreg 寄存器的时钟完全关闭，进一步节省功耗。

---

## 15. 关键信号速查表

### 15.1 src_data 位域总结

| 字段 | srcf0 位 | srcf1 位 | srcf2 位 | 说明 |
|------|---------|---------|---------|------|
| rdy | [0] | [0] | [9] | 物理寄存器结果预期就绪 |
| mla_rdy | 无 | 无 | [0] | FMA 累加源提前就绪 |
| wb | [1] | [1] | [1] | 结果已写回 PRF |
| vreg | [8:2] | [8:2] | [8:2] | 物理向量寄存器编号（7 位） |

注意 srcf2 的位域布局与 srcf0/srcf1 不同：rdy 在 bit[9] 而非 bit[0]，
bit[0] 被 mla_rdy 占用。这是为了与发射队列 viq 的接口约定一致。

### 15.2 包内旁路信号汇总

| 信号 | 含义 |
|------|------|
| `frt_dp_inst01_srcf2_match` | inst1.srcf2 依赖 inst0.dst，且 inst0 非 fmov |
| `frt_dp_inst02_srcf2_match` | inst2.srcf2 依赖 inst0.dst（可能经 inst1 fmov 中转）|
| `frt_dp_inst03_srcf2_match` | inst3.srcf2 依赖 inst0.dst |
| `frt_dp_inst12_srcf2_match` | inst2.srcf2 依赖 inst1.dst |
| `frt_dp_inst13_srcf2_match` | inst3.srcf2 依赖 inst1.dst |
| `frt_dp_inst23_srcf2_match` | inst3.srcf2 依赖 inst2.dst（inst2 为 fmov 时会追溯）|

这些信号只针对 srcf2，是因为 srcf2 作为 FMA 累加源，其包内依赖会影响 viq
中的 srcv1_dep_mask 生成，而 srcf0/srcf1 的包内依赖已经足够通过 rdy=0 的
方式隐含表达。

### 15.3 写端口条件汇总

| 端口 | 主条件 | 屏蔽条件 |
|------|--------|---------|
| inst0 写 freg 表 | `ctrl_rt_inst0_vld && dp_frt_inst0_dstf_vld` | `ctrl_ir_stall \|\| frt_recover_updt_vld` |
| inst0 写 ereg | `ctrl_rt_inst0_vld && dp_frt_inst0_dste_vld` | `ctrl_ir_stall \|\| frt_recover_updt_vld` |
| recover 写所有表项 | `frt_recover_updt_vld` | 无（最高优先级）|
| reg_32 特殊 | bit5=1 的目的寄存器强制写 reg_32 | 与 reg_0–31 互斥 |

---

> **延伸阅读**：
> - `ct_idu_dep_vreg_srcv2_entry.v`：理解 rdy/wb/mla_rdy 三位在管线各阶段的更新时序。
> - `ct_idu_ir_rt.v`：对比整数表，重点关注 src2 与 srcf2 的概念差异。
> - `ct_idu_is_viq*.v`：了解 ir_frt 产生的依赖信息如何在发射队列中被消费。
> - `ct_idu_dp.v`：了解 dep_info 的生成逻辑，特别是 split 指令的掩码策略。
