# C910 IDU IR 阶段——标量浮点重命名表 `ct_idu_ir_frt`

> **定位**：`ct_idu_ir_frt` 是 IR（寄存器重命名）阶段三个重命名表之一，专门
> 管理浮点架构寄存器 f0–f31 的重命名。读完本文档应能独立理解：表结构与表项
> 格式、四个内部 IR 槽的写端口逻辑、33 个逻辑映射表项与 64 项浮点物理寄存器池的区别、
> 三源操作数（srcf0/srcf1/srcf2）及 FMA 就绪位
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

1. **建立并维护 freg（浮点架构寄存器编号 f0–f31）→ 浮点物理寄存器的映射**。本模块和 `ct_idu_rf_prf_fregfile.v` 在信号及内部单元名中沿用 `vreg`，但这里的 `vreg` 是浮点 PRF 的内部物理编号，不能据此把它解释为架构向量寄存器。
   每个架构寄存器对应一张"表项"，表项记录当前最新的重命名目标物理寄存器及其就绪状态。
2. **查表**：为本周期进入 IR 重命名逻辑的最多四个内部槽（inst0–inst3）之
   srcf0/srcf1/srcf2 提供物理寄存器编号及就绪/写回标志。四个内部槽不等价于
   “每周期发射四条架构指令”，其形成还受上游宽度和拆分逻辑约束。
3. **同周期包内旁路**：若同一发射包中较早的指令写入了某架构寄存器，后续指令对同一架构
   寄存器的读取直接旁路，无需等待下周期写入表项。
4. **提供 rel_freg / rel_ereg**：把目的逻辑寄存器更新前的旧物理映射随指令送往
   后续 RTU/PST 退休与释放协议；本输出本身不表示在 IR、发射或执行完成时立即释放。
5. **支持 flush/reset 恢复**：接收 RTU/PST 送来的退休态映射重建推测映射，或在 sync_reset 时
   恢复到初始映射（架构 f_i → 物理浮点项 i）。

### 1.2 33 个映射表项不等于 33 个物理寄存器

这里必须区分三个概念：

- RISC-V 架构定义了 32 个浮点架构寄存器 f0–f31。
- `ir_frt` 实例化 `reg_0`–`reg_32` 共 33 个**逻辑映射表项**。前 32 项对应 f0–f31；`reg_32` 是供内部拆分/扩展编码使用的特殊槽，不是第 33 个架构浮点寄存器。
- `ct_idu_rf_prf_fregfile.v` 实现的是 64 项、每项 64 位的**浮点物理寄存器文件**。物理编号在接口上为 7 位，但有效池规模由 64 项 PRF/PST 结构决定，不能从 7 位编码推导出 128 项。

RISC-V 的 F/D 浮点寄存器组与 V 向量寄存器组在架构上是不同的寄存器文件。当前 RTL
也分别存在 `ct_idu_rf_prf_fregfile.v` 与 `ct_idu_rf_prf_vregfile.v`；后者的有效读数据
路径在开源配置中被常量化，和 `ct_idu_ir_vrt.v` 的占位实现相呼应。因此，本文后续看到
`vreg` 这个内部字段名时，应读作"FRT 使用的 7 位物理编号"，而不是"F/V 共享寄存器"。

### 1.3 在 IR 三表体系中的位置

```
IR 阶段重命名表
├── ct_idu_ir_rt    整数重命名表（x0–x31 → preg，整数 PRF）
├── ct_idu_ir_frt   标量浮点重命名表（f0–f31 → 内部 vreg 编码，浮点 PRF） ← 本文档
└── reg_e           EREG 当前物理版本（fflags 等状态贡献链；单个 5 位映射寄存器）
```

---

## 2. 与整数重命名表 ir_rt 的对比

| 维度 | `ct_idu_ir_rt`（整数表） | `ct_idu_ir_frt`（标量浮点表） |
|------|--------------------------|-------------------------------|
| 架构寄存器 | x0–x31（5 位） | f0–f31（6 位，bit5 表示 split 目的） |
| 物理寄存器 | preg（7 位，整数 PRF） | 内部 vreg 编码（7 位，其中标量浮点类别进入 64 项浮点 PRF） |
| 查表逻辑槽位 | 33（reg_0–reg_32） | 33（reg_0–reg_32） |
| 动态 dep 实例 | 32（reg_1–reg_32；x0/reg_0 为常量） | 33（reg_0–reg_32；f0 不是常量寄存器） |
| 表项子模块 | `ct_idu_dep_reg_src2_entry` | `ct_idu_dep_vreg_srcv2_entry` |
| 源操作数数量 | src0, src1, src2（但 src2 = 自身 dst，用于 MLA 场景） | srcf0, srcf1, srcf2（三个独立查表路径）|
| FMA/MLA 就绪位 | `mla_rdy`（仅 src0、src2 携带） | `mla_rdy`（srcf0、srcf2 携带，srcf1 无 mla_rdy） |
| 就绪/写回广播接口 | pipe0/pipe1 的整数 preg 广播 | pipe6/pipe7 与 pipe3 的统一 `vreg` 编号广播；对 FRT 表项而言，新映射由 6 位浮点物理编号高位补 0 形成 |
| wb 更新来源 | IU EX2 写回 | VFPU EX5 写回 + LSU pipe3 写回 |
| 额外 ereg | 无 | 有 EREG 当前映射（`fflags` 等推测状态贡献的物理版本，生成 `rel_ereg`） |
| fmov 旁路 | `mov` 信号 | `fmov` 信号（且有完整 fmov_bypass_over_instN 保护链） |
| 复位初始映射 | x_i → preg_i（0–31，reg_32 → 0） | f_i → 浮点物理项 i（0–31，reg_32 → 0） |

**关键相同点**：
- 两表均以架构寄存器编号低 5 位（[4:0]）索引 reg_0–reg_31，bit5=1 对应 reg_32。
- 均使用 `ct_rtu_expand_32` 将 5 位目的寄存器展开成 32 位 one-hot 向量，再
  通过 bit[5] 判断是否写 reg_32。
- 均支持四槽普通写和恢复写。普通写数据 MUX 的源码顺序是 3 > 2 > 1 > 0 >
  recover/default，但恢复有效时普通写条件被压低，功能协议下两者互斥。
- 均有 `freg_entry_no_rdy` / `preg_entry_no_rdy` 门控信号驱动顶层时钟门。

---

## 3. 端口说明

### 3.1 控制类输入

| 信号 | 位宽 | 说明 |
|------|------|------|
| `ctrl_ir_stall` | 1 | IR 阶段停顿；stall 时禁止写入表（但门控使能仍有效） |
| `ctrl_rt_instX_vld` | 1×4 | inst0–inst3 在本周期是否有效 |
| `rtu_yy_xx_flush` | 1 | 全局 flush，触发从 PST 提供的退休态映射恢复 |
| `rtu_idu_flush_fe/is` | 1×2 | 前端/IS 阶段 flush，传递给表项内部 flush ready/wb 位 |
| `ifu_xx_sync_reset` | 1 | 同步复位，恢复出厂初始映射 |

### 3.2 指令数据通路输入（以 inst0 为例，inst1–inst3 类似）

| 信号 | 位宽 | 说明 |
|------|------|------|
| `dp_frt_inst0_dstf_reg[5:0]` | 6 | 目的浮点架构寄存器（bit5=1 表示 split/向量隐式 dst） |
| `dp_frt_inst0_dstf_vld` | 1 | 目的 freg 有效 |
| `dp_frt_inst0_dst_freg[5:0]` | 6 | 新分配的标量浮点物理寄存器编号；写入 7 位统一依赖项字段时高位补 0 |
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
| `vfpu_idu_ex1_pipe6/7_data_vld_dupx`，`vreg_dupx` | EX1 广播有效且统一物理号匹配时，进入当拍 `rdy_update` |
| `vfpu_idu_ex2_pipe6/7_data_vld_dupx`，`vreg_dupx` | EX2 广播有效且物理号匹配时，进入 `rdy_update` |
| `vfpu_idu_ex3_pipe6/7_data_vld_dupx`，`vreg_dupx` | EX3 广播有效且物理号匹配时，进入 `rdy_update`；不能仅由信号名给所有指令固定延迟 |
| `vfpu_idu_ex5_pipe6/7_wb_vreg_dupx`，`_vld_dupx` | VFPU EX5 最终写回，更新 wb 位 |
| `lsu_idu_ag_pipe3_vload_inst_vld`，`vreg_dupx` | LSU AG 的统一 `vload` 接口匹配，用于形成当拍/保存的 lsu_match |
| `lsu_idu_dc_pipe3_vload_inst_vld_dupx`，`vreg_dupx` | LSU DC 广播匹配，进入 `rdy_update` |
| `lsu_idu_wb_pipe3_wb_vreg_dupx`，`_vld_dupx` | LSU pipe3 写回，更新 wb 位 |
| `ctrl_xx_rf_pipe6/7_vmla_lch_vld_dupx` | VFPU MLA 锁存有效，更新 mla_rdy（专用于 VMLA 场景） |
| `dp_xx_rf_pipe6/7_dst_vreg_dupx` | VFPU RF 阶段目的 vreg（与上述配合使用） |

### 3.4 输出

| 信号 | 位宽 | 说明 |
|------|------|------|
| `frt_dp_instX_srcfY_data` | srcf0/1: 9 位；srcf2: 10 位 | 源操作数的统一物理编号和就绪标志；FRT 输出的类别位为 0 |
| `frt_dp_instX_rel_freg[6:0]` | 7 | 目的更新前的旧标量浮点物理映射，进入 RTU/PST 退休释放协议 |
| `frt_dp_instX_rel_ereg[4:0]` | 5 | 旧 EREG 映射，进入 RTU/PST 退休释放协议 |
| `frt_dp_inst01_srcf2_match` 等 | 1×6 | 四槽两两组合的六条 srcf2 同包 RAW 命中信号 |

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
[8:2]  x_create_vreg[6:0]  — 统一依赖项使用的 7 位物理编号字段；FRT 创建时为 `{1'b0, dst_freg[5:0]}`
[1]    x_create_wb         — 写回位初始值（r_vld = 1 表示恢复时认为已写回）
[0]    x_create_rdy        — 就绪位初始值（r_vld = 1 表示恢复时认为就绪）
```

在 `ir_frt` 中：

```verilog
// 行 3853（以 reg_0 为例）
assign r_vld = frt_recover_updt_vld;
assign reg_0_create_data[10:0] = {1'b0, r_vld, 1'b0, reg_0_create_freg[5:0], {2{r_vld}}};
```

- **正常重命名写入**（inst 写入新映射）：`r_vld = 0`，
  `create_data = {1'b0, 1'b0, 1'b0, dst_freg[5:0], 2'b00}`
  — rdy=0、wb=0 说明该物理寄存器结果尚未产生，源依赖该 vreg 的指令需等待。
- **Flush/Reset 恢复**：`r_vld = 1`，`create_data = {1'b0, 1'b1, 1'b0, vreg, 2'b11}`，
  把 `rdy/wb` 状态编码为 1。它表达“退休映射应可从 PRF 读取”的跨模块协议，不是本 entry
  对 PRF 内容做过一次独立验证。

### 4.3 表项读出格式 [12:0]

```
[12]   x_read_lsu_match   — 当前是否有 LSU load 正在处理同一 vreg
[11]   x_read_rdy_for_bypass — bypass 用就绪位（= rdy 本身）
[10]   x_read_rdy_for_issue  — issue 用就绪位（含 mla_rdy / lsu fwd 等更早就绪信号）
[9]    x_read_mla_rdy     — MLA/FMA 专用调度就绪状态；与普通 rdy 的具体周期差取决于生产者事件
[8:2]  x_read_vreg[6:0]   — 当前映射的统一 7 位物理编号
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

注意：依赖项子模块内部沿用 7 位 `vreg[6:0]` 统一接口；FRT 的创建数据实际是
`{1'b0, reg_X_create_freg[5:0]}`。FRT 向后级输出时同样显式构造
`{1'b0, instX_srcfY_read_freg[5:0]}`，所以本路径当前有效编号为 0–63，
最高位恒为 0。不能写成“依靠 bit6 区分 64 项浮点物理寄存器”，也不能因为
内部字段名叫 `vreg` 就把它解释成架构向量寄存器号。

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
| LSU DC 阶段 `vload_inst_vld` 广播与表项物理号匹配 | 组合读值/后续 rdy 状态获得 data-ready 条件 |
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

- `x_entry_vmla` 在 33 个表项实例上固定为 1，使 dep 叶子不会按“当前表项类型”屏蔽
  FMLA/VMLA 专用匹配输入；它不表示 33 个表项当前都持有 VMLA 指令。
- FRT 查询端最终还用 `dp_frt_inst*_fmla` 限定 `mla_rdy` 是否作为 srcf2 的专用就绪位。
  因而这是一条为 FMA 累加源保留的调度状态路径，不是所有浮点/向量源无条件提前就绪。

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

三条 wb 来源是 LSU pipe3 的 `wb_vreg` 广播、VFPU pipe6 EX5 和 VFPU pipe7 EX5。
这些是统一物理编号接口名；对本 FRT 来说，只有编号与当前高位为 0 的浮点映射匹配
时才置位，不能仅凭信号名把本表描述成“管理向量 load 目的”。
一旦写回，wb 位就置 1 并保持（直到表项被新指令覆写）。

### 5.4 lsu_match

```verilog
// entry 模块 行 343–358
assign lsu_match_update = lsu_idu_ag_pipe3_vload_inst_vld
                          && (lsu_idu_ag_pipe3_vreg_dupx == vreg);
```

这里需要区分组合输出和保存状态：

- `x_read_lsu_match` 直接等于当拍 `lsu_match_update`，表示 AG 广播在当前组合周期
  是否命中本表项；
- `lsu_match` 触发器在有效 `dep_clk` 边沿保存该命中，供下一阶段
  `load_issue_data_ready = dc_fwd_vld && lsu_match` 使用；
- 在 `ir_frt` 顶层，`lsu_idu_dc_pipe3_vload_fwd_inst_vld` 被固定为 0，
  因而本模块读取表项时不会通过这条 DC-forward 条件把
  `x_read_rdy_for_issue` 拉高。普通 `load_data_ready` 匹配仍可进入
  `rdy_update`，不能概括成“FRT 完全不接收 LSU 就绪信息”。

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
- **bit5=1 且低 5 位为 0**：目的是内部扩展编码槽，写 reg_32（利用
  expand[0] && bit5 的组合，强制写第 32 项）。

因此 reg32 是由 6 位内部逻辑编号 32 选择的额外映射槽。邻接 split 数据通路支持“用于内部
拆分/扩展目的”的解释，但不能把它泛化成任意超出 f31 的溢出槽；bit5=1 且低 5 位非 0 时，
`expand[0]` 不成立，也不会写 reg32。

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

数据 MUX 的源码顺序是 **inst3 > inst2 > inst1 > inst0 > recover/default**。正常协议中
`frt_recover_updt_vld` 会抑制四路普通 gateclk write 条件，所以恢复不是功能上的最低优先级；
若互斥条件被破坏，才会按源码 MUX 顺序选择普通槽位数据。

这反映了"程序序更晚的指令覆盖更早的指令的目的寄存器"的重命名原则：
在同一周期内如果两条指令写同一架构寄存器（WAW 依赖），以最新的那条为准。

### 6.4 ereg 写逻辑

`fflags` 等隐式状态贡献对应的当前 EREG 映射只有一个专用 5 位寄存器
`reg_e`，不是 33 个按逻辑寄存器编号索引的表项。`frm` 是指令读取的舍入模式，
不应写成每条浮点指令通过 EREG 产生的新值：

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

EREG 只有一个当前映射，不需要按 32 个体系结构寄存器分别建表，因为这里跟踪
的是一条全局、按程序序串联的状态贡献版本链。只有译码/控制置
`dste_vld` 的操作才分配新 EREG，并非每条浮点指令都无条件分配；具体异常位
数据由 VFPU 后续写入 EREG 数据文件。

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
| [8:2] | 统一物理编号（7 位；类别高位补 0，低 6 位为标量浮点物理索引） |

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
| [8:2] | 统一物理编号（当前 FRT 高位为 0） |

srcf2 在 FMA 中对应第三源/累加项，因此 RTL 为它保留独立 `mla_rdy`，而 srcf0/srcf1
没有该位。`mla_rdy` 监听 FMLA EX1/EX2、VMLA latch 和专用 forward 条件，普通
`rdy` 监听另一组阶段广播。两者谁先成立以及相差几拍取决于生产者类型和有效窗口；
局部 RTL 不能统一写成“必然早 1 周期”。

---

## 8. 三源操作数与 FMA mla_rdy 机制

### 8.1 为什么浮点需要三个源

整数表 `ir_rt` 中的 src2 是目的寄存器（用于查询"旧映射"以便释放），
并非真正独立的源操作数。

浮点/向量表 `ir_frt` 中的 srcf2 是**真正独立的第三个源寄存器**，对应：

- RISC-V F 扩展：`FMADD.S rd, rs1, rs2, rs3`（rs3 = srcf2）
- RISC-V F 扩展：`FMSUB.S`, `FNMSUB.S`, `FNMADD.S` 等融合乘加变体
- RISC-V V 扩展：`vmacc.vv`, `vfmacc.vv` 等向量乘加累加指令

在 C910 IR 内部的四个派遣槽中，每个槽最多可以携带 srcf0、srcf1、srcf2
三个浮点源，且三者都需要取得重命名后的物理编号和依赖状态。“四个槽”来自
IR/IS 内部对拆分微操作和原始指令的统一承载，不能直接改写成“处理器每周期
发射四条架构指令”；上游 ID 原始输入最多三条，实际执行发射还受各队列和管线
端口限制。

### 8.2 mla_rdy 的工作原理

```
FMLA 专用匹配：
  x_entry_vmla
  && (FMLA EX1 或 EX2 接口有效)
  && 接口目的物理号 == 表项 vreg
    -> mla_data_ready
    -> mla_rdy_update

普通就绪匹配：
  VFPU EX1/EX2/EX3 或 LSU DC 接口有效
  && 接口目的物理号 == 表项 vreg
    -> data_ready
    -> rdy_update

确认写回：
  LSU pipe3 WB 或 VFPU pipe6/7 EX5 WB 匹配
    -> wb_update
```

核心 RTL（entry 模块行 367–395）：

```verilog
// FMLA EX1/EX2 接口任一有效且目的号匹配，可更新该表项的 mla_rdy
assign vfpu0_fmla_data_ready = x_entry_vmla
                               && vfpu_idu_ex2_pipe6_fmla_data_vld_dupx
                               && (vfpu_idu_ex2_pipe6_vreg_dupx == vreg)
                            || x_entry_vmla
                               && vfpu_idu_ex1_pipe6_fmla_data_vld_dupx
                               && (vfpu_idu_ex1_pipe6_vreg_dupx == vreg);
```

`ir_frt` 的常量 1 使每个物理浮点表项都能记录专用匹配，但某条消费者查询是否采用
`mla_rdy` 仍由 `dp_frt_inst*_fmla` 限定。整数 RT 的相应 entry-type 输入连接方式
不同，不能把两个表的门控层级混为一谈。当前 RVV 总译码关闭，文中的 VMLA 接口属于
保留结构；标量 F/D 的 FMA 路径仍可有效。

---

## 9. 同周期包内依赖旁路

FRT 同周期看到的 inst0–inst3 是四个按程序序排列的 IR 派遣槽，不应简称为
“四发射”。若 inst1 的 srcf0 与 inst0 的 dstf_reg 相同，inst1 不能只使用
周期开始时表内的旧映射，因为 inst0 的新映射要在时钟沿才写入表项；组合逻辑
必须先把 inst0 当拍分配的新物理号旁路给 inst1。这是**同派遣包映射旁路**
（intra-packet rename bypass），处理的是 RAT 更新的同拍可见性，不是执行结果
数据的数值前递。

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

`srcf2_match` 信号输出到 `ct_idu_ir_dp`，与 VRT 的 srcv2 match 做 OR 后进入
`dp_ir_instXY_src_match[3]`；整数 RT 的三源匹配占 `[2:0]`。这些跨槽关系再随
依赖信息进入 IS 阶段，不能把 bit3 简称成“srcv1 依赖掩码”。

---

## 10. fmov 指令的特殊旁路链

`fmov` 标记来自译码识别的 zero-delay move 候选：当前译码方程匹配
`fsgnj.d` 伪 move（`rs1==rs2`、`rd!=rs1`），并受
`cp0_idu_zero_delay_move_disable` 控制。这里必须把两件事分开：

1. **FRT 拍后映射更新**仍写 `dp_frt_instN_dst_freg`，即 RTU 提供的新目的浮点
   物理索引；表项写数据 MUX没有因 `fmov` 改成源映射。
2. **同包较新消费者的组合旁路**可以直接使用 fmov 的 srcf0 旧映射及其
   ready/wb，而不用等待 move 把相同数值复制到新目的物理项。

所以这是同包 move 穿透/依赖消除优化，不是“fmov 不分配新物理寄存器”。

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

fmov 的“语义目的值来源”辅助信号来自：

```verilog
// 行 4007–4010
assign frt_inst0_fmov_dst_rdy       = inst0_srcf0_read_rdy;
assign frt_inst0_fmov_dst_mla_rdy   = inst0_srcf0_read_mla_rdy;
assign frt_inst0_fmov_dst_wb        = inst0_srcf0_read_wb;
assign frt_inst0_fmov_dst_freg[5:0] = inst0_srcf0_read_freg[5:0];
```

这些 `frt_inst0_fmov_dst_*` 只服务同包后续源选择：从数值语义上，move 的目的值
等于 srcf0，所以后续消费者可直接指向 srcf0 的生产者。它们没有连接到
reg0–reg32 的表项创建数据，不能据此说 FRT 拍后目的映射也变成源物理号。

**fmov_bypass_over_inst1 保护**：如果 inst1 的 dstf_reg 与 inst0 的 srcf0_reg
相同，inst1 会建立该逻辑源的新版本；更重要的是，原 srcf0 物理项的释放生命周期
也随新的覆盖关系变化。此时 RTL 禁止 inst2 跨过 inst1 继续直接别名到 inst0
看到的旧 srcf0 映射，转而保留对合适新生产者的依赖：

```verilog
// 行 4905–4908
assign frt_inst0_fmov_bypass_over_inst1 =
    dp_frt_inst0_fmov
    && !(dp_frt_inst1_dstf_vld
         && (dp_frt_inst0_srcf0_reg[5:0] == dp_frt_inst1_dstf_reg[5:0]));
```

---

## 11. 目的寄存器的 rel_freg / rel_ereg 生成

`rel_freg` 是目的更新前的旧标量浮点物理映射。重命名的本质是：新指令写 f5
时，先读出 f5 当前对应的旧物理项，将其随指令送入 RTU/PST 协议；通常等覆盖者
退休并满足恢复安全条件后，旧项才可回到空闲池。`rel_freg` 只是编号数据，
不是本模块发出的“立即释放”脉冲。

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

若同一批内部槽中多条操作都产生状态贡献（`dste_vld=1`），后槽的旧版本就是
前一有效槽新分配的 `dst_ereg`。这是重命名映射的包内旁路，不是异常位数据从
前一条执行指令直接旁路到后一条。

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
| `ifu_xx_sync_reset` | `frt_reset_updt_freg`（硬编码初始映射） | 同步复位时重建架构 f_i→物理浮点项 i 映射 |
| `rtu_yy_xx_flush` | `rtu_idu_rt_recover_freg`（PST 退休态映射） | flush 时恢复到已退休的精确映射 |

### 13.2 恢复映射格式

```verilog
// 行 2946–2950（复位初始映射）
assign frt_reset_updt_freg[191:0] =
         {6'd31, 6'd30, 6'd29, 6'd28, ..., 6'd1, 6'd0};
```

`frt_reset_updt_freg` 是一个 192 位向量（32 个 6 位字段），表示架构
f0→物理浮点项 0、f1→物理浮点项 1，直到 f31→物理浮点项 31 的初始一一映射。
源码内部复用 `vreg` 这个统一字段名，不应因此把它写成架构向量寄存器映射。
`rtu_idu_rt_recover_freg[191:0]` 具有相同字段格式，由 RTU 的 PST 退休状态产生；
它不是 `ir_frt` 内保存的分支检查点副本。

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

在 `ct_idu_dep_vreg_srcv2_entry` 中，`flush_fe` 或 `flush_is` 将该叶子的
`rdy/wb/mla_rdy` 置 1、`lsu_match` 置 0。flush 同时使相应流水/队列表项失效，因此
这些 1 是无效项的中性状态，不表示被冲刷指令的结果真的写入 PRF。恢复更新创建表项
时也可装入 ready/writeback 初值，但其映射有效性仍由 FRT 恢复控制决定。

---

## 14. 时钟门控

`ir_frt` 具有顶层和表项级两层本地时钟请求：

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

`freg_entry_no_rdy = !(&reg_read_rdy_bypass[32:0])`。只要任一表项的 bypass-ready 为
0，它就使 `frt_clk_en=1`，让顶层本地请求保持有效；最终技术时钟是否开启还受
global/module/scan 和 ICG 实现分支控制。

### 14.2 表项级门控

每个 `ct_idu_dep_vreg_srcv2_entry` 内有两个独立门控：

- `dep_clk`：由 `x_gateclk_write_en || gateclk_entry_vld && (!rdy || !wb)` 使能，
  驱动 rdy/wb/lsu_match/mla_rdy 寄存器的时钟。
- `write_clk`：由 `x_gateclk_idx_write_en` 使能，仅驱动 vreg 寄存器的时钟，
  仅在写入时开启。

这不是两个异步“时钟域”，而是同一源时钟下的两级/分组门控请求。`write_clk` 的
`local_en=0` 可避免该项主动请求索引寄存器时钟，但 `module_en` 可覆盖 local；
未定义 `C910_USE_TSMC28_ICG` 时公开 RTL 还会直接旁路输入时钟。实际停钟和功耗
收益必须从编译配置、综合网表和活动率报告确认。

---

## 15. 关键信号速查表

### 15.1 src_data 位域总结

| 字段 | srcf0 位 | srcf1 位 | srcf2 位 | 说明 |
|------|---------|---------|---------|------|
| rdy | [0] | [0] | [9] | 物理寄存器结果预期就绪 |
| mla_rdy | 无 | 无 | [0] | FMA 累加源提前就绪 |
| wb | [1] | [1] | [1] | 结果已写回 PRF |
| 物理编号 | [8:2] | [8:2] | [8:2] | 统一接口宽度为 7 位；当前 FRT 输出高位固定为 0，低 6 位表示 64 项标量浮点 PRF 编号 |

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
| recover 写所有表项 | `frt_recover_updt_vld` | 普通四槽写使能均含 `!frt_recover_updt_vld`，因此功能协议上恢复与普通写互斥 |
| reg_32 特殊 | `dstf_reg[5]=1` 且 `dstf_reg[4:0]=0` 时写 reg_32 | 与 reg_0–31 写路径互斥；bit5=1 且低 5 位非 0 时不命中 reg_32 |

---

> **延伸阅读**：
> - `ct_idu_dep_vreg_srcv2_entry.v`：理解 rdy/wb/mla_rdy 三位在管线各阶段的更新时序。
> - `ct_idu_ir_rt.v`：对比整数表，重点关注 src2 与 srcf2 的概念差异。
> - `ct_idu_is_viq*.v`：了解 ir_frt 产生的依赖信息如何在发射队列中被消费。
> - `ct_idu_id_dp.v` 与 `ct_idu_ir_dp.v`：了解 dep_info 的传递、重命名结果选择和 split 指令的掩码策略。
