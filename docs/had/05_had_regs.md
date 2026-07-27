# C910 HAD 寄存器堆与顶层 模块详细教学文档

> RTL 源文件：
> - `C910_RTL_FACTORY/gen_rtl/had/rtl/ct_had_regs.v`（980 行，私有侧寄存器堆：HCR/HSR/CPUSCR/断点基址/版本 ID/MBIR）
> - `C910_RTL_FACTORY/gen_rtl/had/rtl/ct_had_common_regs.v`（184 行，共用侧：RSR/ID/DMS）
> - `C910_RTL_FACTORY/gen_rtl/had/rtl/ct_had_common_top.v`（342 行，共用侧顶层）
> - `C910_RTL_FACTORY/gen_rtl/had/rtl/ct_had_private_top.v`（1078 行，每核私有侧顶层）
> - `C910_RTL_FACTORY/gen_rtl/had/rtl/ct_had_dbg_info.v`（452 行，单核 debug-info，本篇侧重其 debug 快照寄存器角色）
>
> 前置阅读：`00_had_overview.md`（HACR 寻址、四步法）、`03_had_ctrl_ddc.md`（HCR/HSR 字段如何被 ctrl 使用）

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口与寄存器总览](#2-端口与寄存器总览)
3. [HAD_ID：版本与能力描述](#3-had_id版本与能力描述)
4. [HCR：HAD 控制寄存器](#4-hcrhad-控制寄存器)
5. [HSR：HAD 状态寄存器（进 debug 原因）](#5-hsrhad-状态寄存器进-debug-原因)
6. [CPUSCR：WBBR / PC / IR / CSR 影子扫描链](#6-cpuscrwbbr--pc--ir--csr-影子扫描链)
7. [断点基址寄存器与 MBIR](#7-断点基址寄存器与-mbir)
8. [共用侧寄存器：RSR / ID / DMS](#8-共用侧寄存器rsr--id--dms)
9. [顶层组织：common_top 与 private_top](#9-顶层组织common_top-与-private_top)
10. [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

### 1.1 这一层做什么

寄存器堆是 HAD 的"状态载体"。`03_had_ctrl_ddc.md` 的控制逻辑读写这些寄存器、`02_had_breakpoint.md` 的断点用它们的字段、`01_had_jtag.md` 的 HACR 寻址选中它们。本篇把所有寄存器的**字段定义、读写时机、对外接口**对齐到位。

寄存器按物理位置分两套（与 `00_had_overview.md §1.2` 的共用/私有侧一致）：

| 套 | 文件 | 寄存器 |
|----|------|--------|
| 私有侧（每核一份）| `ct_had_regs.v` | HCR, HSR, CPUSCR(WBBR/PC/IR/CSR), BABA/BABB/BAMA/BAMB, EVENT_OE/IE, MBIR, HAD_ID(私有副本) |
| 共用侧（全簇一份）| `ct_had_common_regs.v` | RSR, HAD_ID(共用), DMS, DBGFIFO2 数据 |

参数：`ADDRW=PA_WIDTH`（物理地址宽 40），`DATAW=64`（`ct_had_regs.v:408-409`）。

### 1.2 寄存器读出统一出口

所有私有寄存器读出在一个大 MUX 里按 `ir_xx_*_reg_sel` 选出（`ct_had_regs.v:946-969`），再打一拍成 `x_regs_serial_data`（`:971-974`）送 serial→tdo。共用侧对称（`ct_had_common_regs.v:174-178`）。这是"调试器读寄存器"的最后一公里。

---

## 2. 端口与寄存器总览

`ct_had_regs.v` 的寄存器声明集中在 `:228-271`。关键寄存器一览：

| 寄存器 | 位宽 | 声明行 | 写逻辑 | 读出行 |
|--------|------|--------|--------|--------|
| `baba_reg`/`babb_reg` | 64 | `:228-229` | `:448-470` | `:952-953` |
| `bama_reg`/`bamb_reg` | 8 | `:230-231` | `:477-500` | `:954-955` |
| `wbbr_reg` | 64 | `:270` | `:547-559` | `:956` |
| `pc` | 64 | `:261` | `:564-573` | `:957` |
| `ir_reg` | 32 | `:258` | `:578-588` | `:958` |
| `csr_reg`(ffy/fdb) | 16 | `:240,239` | `:593-613` | `:959` |
| `hcr_*` | 32 | `:242-253` | `:620-650` | `:960` |
| HSR 各位 | — | `:232-269` | `:665-852` | `:961` |
| `mbir_idx` | 2 | `:259` | `:838-850` | `:962` |
| `event_*_ie/oe` | — | `:234-237` | `:506-540` | `:965-966` |

主要对外接口输出：`had_ifu_ir`/`had_ifu_pc`（注入/恢复 PC，`:590,862`）、`had_idu_wbbr_data/vld`（窥探回写，`:868-869`）、`had_yy_xx_bkpt*_base/mask/rc`（断点配置给 RTU/LSU，`:925-934`）。

---

## 3. HAD_ID：版本与能力描述

HAD_ID 是只读的能力描述寄存器（复位 HACR 默认就指向它，见 `00_had_overview.md §6`）。字段布局注释在 `ct_had_regs.v:396-407`，赋值在 `:413-441`：

| 位 | 字段 | 值 | 含义 |
|----|------|----|----|
| `[31:28]` | JTAG 接口类型 | 0 | — |
| `[27:26]` | CPU 指令架构 | `cp0_had_cpuid_0[27:26]`（CSKY V3）| `:414` |
| `[18]` | HACR 宽度 | 1 | HACR 为 16 位 |
| `[17]` | BANK1 | 0 | `:417` |
| `[16]` | DDC | **1** | 支持 DDC（v2.3 增量）`:418` |
| `[15:12]` | BKPT_NUM | **2** | 2 个硬件断点 `:419` |
| `[11:8]` | HAD_VERSION | **`4'b1011`** | **版本 2.3** `:436` |
| `[7:4]` | HAD_VER(ISA) | `0100` | 960 系 `:439` |
| `[3:0]` | ID_VERSION | `0011` | `:441` |

`id_reg[11:8]=4'b1011` 就是 HAD v2.3 的硬编码版本号，RTL 注释列出了 0000→1011 的演进历史（`:421-436`），v2.3 相对前代新增 **DCC handshake** 与 **TEE support**。共用侧 `ct_had_common_regs.v:132-161` 有一份对称的 ID（多了 `[19]=1` 表示有 RSR）。

---

## 4. HCR：HAD 控制寄存器

HCR（HAD Control Register）= RISC-V 的 `dmcontrol` + 断点配置。写逻辑 `ct_had_regs.v:620-650`，打包 `:655-658`，字段拆给下游 `:880-896`：

| 位 | 字段 | 信号 | 作用 |
|----|------|------|------|
| `[31]` | NICVEN / NIRVEN | `regs_xx_nirven`（`:896`）| non-IRV 断点使能 |
| `[21]` | ADR | `regs_ctrl_adr`（`:880`）| 异步调试请求 |
| `[20]` | DDCEN | `regs_xx_ddc_en`（`:882`）| DDC 通道使能 |
| `[17:16]` | SQC | `regs_ctrl_sqc`（`:884`）| 顺序限定（A→B→trace 链）|
| `[15]` | DR | `regs_ctrl_dr`（`:886`）| 同步调试请求 |
| `[14]` | IDRE | `hcr_idre` | （内部）|
| `[13]` | TME | `regs_ctrl_tme`（`:888`）| trace 模式使能 |
| `[12]` | FRZC | `regs_ctrl_frzc`（`:890`）| 冻结 PCFIFO |
| `[11]` | RCB | `had_yy_xx_bkptb_rc`（`:934`）| 断点 B 范围取反 |
| `[10:6]` | BCB | `regs_xx_bcb`（`:892`）| 断点 B 条件类型 |
| `[5]` | RCA | `had_yy_xx_bkpta_rc`（`:932`）| 断点 A 范围取反 |
| `[4:0]` | BCA | `regs_xx_bca`（`:894`）| 断点 A 条件类型 |

这张表把断点（§7 的基址掩码）与控制（§4 的请求/SQC/trace）的"开关"集中在一个 32 位寄存器里。`hcr_jtgr/jtgw_int_en` 硬接 0（`:652-653`，本配置不用 JTAG 中断）。

---

## 5. HSR：HAD 状态寄存器（进 debug 原因）

HSR（HAD Status Register）记录"为什么进 debug"的各种 sticky 位 + CPU 死因。打包在 `ct_had_regs.v:833-836`。每个位由 ctrl 的脉冲置 1、退出 debug（`ctrl_regs_exit_dbg`）清 0——典型 sticky 行为。

### 5.1 进入原因 sticky 位

| 位组 | 含义 | set 条件（行号）|
|------|------|-----------------|
| `adro` | 异步请求进入 | `ctrl_regs_update_adro`，`:703-713` |
| `dro` | DR 同步进入 | `:716-726` |
| `mbo` | 内存断点进入 | `:729-739` |
| `swo` | 软件断点指令进入 | `:742-752` |
| `to` | trace 计满进入 | `:755-765` |
| `frzo` | PCFIFO 已冻结 | `:768-778` |
| `sqb`/`sqa` | SQC 链中 B/A 已发生 | `:781-804`（sticky，供 SQC 判定）|
| `pro` | 被动（跨核事件）请求 | `:822-832` |

调试器读 HSR 就知道"这次是谁把核停下来的"。

### 5.2 CPU 状态 / 死因位

```verilog
// 进 debug 那一刻锁存 CPU 状态（dbg_ack_pc 时）                      :665-685
inst_not_wb, rob_not_empty, iq_not_empty, idu_stall,
bus_dead, ifu_dead, exe_dead
```

这些位帮调试器判断 CPU 是"正常停"还是"卡死"（总线死/取指死/执行死），是 v2.2 引入的 "cpu dead reason"（ID 注释 `:430`）。

### 5.3 PM：功耗/调试态

```verilog
always @(...)                                                        :807-819
  reset/ifu_reset_on → pm=2'b11(全空闲);
  rtu_yy_xx_dbgon    → pm=2'b10(debug);
  低功耗模式          → pm=2'b01;
  否则                → pm=2'b00(运行)
```

PM 同时驱动顶层 ICG 的关时钟判定（`pm==2'b11` 才关，`ct_had_ctrl.v:701`）和 `had_biu_jdb_pm`（`:941`）。

---

## 6. CPUSCR：WBBR / PC / IR / CSR 影子扫描链

CPUSCR（CPU Scan Chain，CPU 影子扫描链）是"借指令窥探"的核心载体（`00_had_overview.md §2.2`）。四个寄存器：

### 6.1 WBBR（回写总线寄存器）

三个写源，优先级从高到低（`ct_had_regs.v:547-559`，§见 `03_had_ctrl_ddc.md §6.2`）：调试器扫入 → DDC 写入 → CPU 执行结果回写（`idu_had_wb_vld`）。读出 `:956`，回写阀门 `had_idu_wbbr_vld = ffy && dbgon`（`:869`）。

### 6.2 PC

```verilog
always @(...)                                                       :564-573
  rtu_had_xx_dbg_ack_pc → pc <= {RTU 给的 PC，按 mmu_en 决定符号扩展};  // 进 debug 锁存当前 PC
  pc_wen(调试器写)       → pc <= ir_xx_wdata;
```

`pc_wen` 要求在 debug 中（`:562`）。退出时 `had_ifu_pc = pc_reg[ADDRW-1:1]`（`:862`）让 IFU 从这个 PC 重新取指。调试器可改 PC 实现"跳到任意地址继续"。

### 6.3 IR（注入指令寄存器）

```verilog
always @(...)                                                       :578-588
  调试器写 / DDC 写(ddc_xx_update_ir) → ir_reg <= 指令;
assign had_ifu_ir = ir_reg;                                         :590
```

调试器或 DDC 把要执行的 32 位指令写进 IR，配合 ctrl 的 `had_ifu_ir_vld` 注入执行。

### 6.4 CSR（ffy/fdb）

```verilog
assign csr_reg = {7'b0, ffy, fdb, 7'b0};                            :613
```

- **ffy**（`[8]`）：决定注入指令的结果是否回写 WBBR（`had_idu_wbbr_vld`，`:869`）；DDC 在 mv 阶段置 ffy（`ct_had_ddc_dp.v:110`）。
- **fdb**（`[7]`）：内存断点总使能（`regs_ctrl_fdb`，`:875`），断点请求都要 `&& regs_ctrl_fdb`（`ct_had_ctrl.v:481-482,507-508`）。

CSR 这两个位虽小，却是"窥探回写开关"与"断点总开关"，串起断点与注入两条主线。

---

## 7. 断点基址寄存器与 MBIR

### 7.1 BABA/BAMA/BABB/BAMB

64 位基址 + 8 位掩码，每个断点一对（`ct_had_regs.v:448-500`），通过 `had_yy_xx_bkpt*_base/mask/rc`（`:925-934`）送 RTU/LSU 做地址比较。语义（掩码扩区间 + RC 取反）详见 `02_had_breakpoint.md §5`。BAMA/BAMB 复位为 0（低功耗，`:475,490`）。

### 7.2 MBIR：哪个断点命中

```verilog
always @(...)                                                       :838-850
  ctrl_regs_bkpta_vld → mbir_idx <= 2'b01;   // 断点 A 命中
  ctrl_regs_bkptb_vld → mbir_idx <= 2'b10;   // 断点 B 命中
  exit_dbg            → mbir_idx <= 2'b0;
assign mbir_reg = {30'b0, mbir_idx};                                :852
```

MBIR（Memory Breakpoint Index Register）让调试器读出"刚才是 A 还是 B 触发的"。命中信息由 ctrl 给（`ct_had_ctrl.v:564-569`，含 non-IRV 的 `nirv_bkpta`），位于 bank1 index27（`00_had_overview.md §6`）。

---

## 8. 共用侧寄存器：RSR / ID / DMS

`ct_had_common_regs.v`（全簇一份）：

### 8.1 RSR（Reset Status Register）

```verilog
assign rsr_data = {28'b0, core_rst[3:0] | tee_mask[3:0]};           :114
```

每核一位复位状态（`core_rst0/1` 在各核复位时置 1，`:86-100`；core2/3 接 1，`:102-104`）。调试器读 RSR 知道哪些核刚复位过。`tee_mask` 本配置接 0（`:108`）。

### 8.2 HAD_ID（共用副本）

与私有侧对称（`:132-161`），但 `[19]=1` 表示"有 RSR"（`:135`）。版本同为 2.3（`:156`）。

### 8.3 DMS（Debug Mask / debug-disable）

```verilog
assign dms_data = {28'b0, sysio_had_dbg_mask[3:0] & ~tee_mask[3:0]};  :166
assign core0_had_dbg_mask = sysio_had_dbg_mask[0];                    :168
assign core1_had_dbg_mask = sysio_had_dbg_mask[1];                    :169
```

DMS 是**每核 debug-disable 掩码**：系统级 `sysio_had_dbg_mask` 哪一位置 1，对应核的调试就被整体关闭。`core0/1_had_dbg_mask` 送各核私有侧（最终成 `ct_had_ctrl.v:680` 的 `x_had_dbg_mask`），决定该核停核请求是否被屏蔽（`03_had_ctrl_ddc.md §10.1`）。这是 v2.3 "TEE support" 的体现之一（虽然本配置 tee_mask=0）。

---

## 9. 顶层组织：common_top 与 private_top

### 9.1 ct_had_common_top（共用/JTAG 侧）

实例化（`ct_had_common_top.v`）：`ct_had_sm`（TAP，`:172`）、`ct_had_io`（引脚，`:194`）、`ct_had_serial`（移位，`:205`）、`ct_had_ir`（HACR 译码，`:235`）、`ct_had_etm`（跨核触发，`:274`）、`ct_had_common_regs`（RSR/ID/DMS，`:290`）、`ct_had_common_dbg_info`（簇级快照，`:310`）。它在 JTAG `tclk` + `forever_cpuclk` 域，是"接入层 + 共用寄存器 + 跨核"的容器。

### 9.2 ct_had_private_top（每核私有侧）

实例化（`ct_had_private_top.v`，每核一份）：

| 实例 | 模块 | 行号 | 归属文档 |
|------|------|------|----------|
| `x_ct_had_bkpta` | ct_had_bkpt | `:544` | 02 |
| `x_ct_had_bkptb` | ct_had_bkpt | `:591` | 02 |
| `x_ct_had_ctrl` | ct_had_ctrl | `:638` | 03 |
| `x_ct_had_ddc_ctrl` | ct_had_ddc_ctrl | `:737` | 03 |
| `x_ct_had_ddc_dp` | ct_had_ddc_dp | `:754` | 03 |
| `x_ct_had_pcfifo` | ct_had_pcfifo | `:771` | 04 |
| `x_ct_had_regs` | ct_had_regs | `:787` | 05 |
| `x_ct_had_trace` | ct_had_trace | `:893` | 04 |
| `x_ct_had_event` | ct_had_event | `:909` | 04 |
| `x_ct_had_dbg_info` | ct_had_dbg_info | `:931` | 04/05 |
| `x_ct_had_nirv_bkpt` | ct_had_nirv_bkpt | `:973` | 02 |
| `x_ct_had_private_ir` | ct_had_private_ir | `:993` | 01 |

它在核 `cpuclk` / `forever_coreclk` 域，是整个核内调试逻辑的容器。两个 bkpt 实例分别接 A/B 的 HCR 字段与 BABA/BAMA 配置——这就是"2 个硬件断点"在 RTL 上的体现。

### 9.3 多核掩码与连接

私有侧通过 `biu_had_coreid` 与 HACR 的 core 字段比较决定是否响应（`ct_had_private_ir.v`，见 `01_had_jtag.md §8`）；共用侧通过 `core_rst`/`sysio_had_dbg_mask` 的每核位（RSR/DMS）做多核状态/掩码管理。本 RTL 实例化 core0/core1，core2/3 在 ID/RSR/etm 里接常量（`ct_had_common_regs.v:102-104`、`ct_had_etm.v:130-142`），但寄存器字段宽度（4 位）为 4 核预留。

---

## 设计取舍小结

| 决策 | 内容 | 出处 | 为什么 |
|------|------|------|--------|
| 共用/私有分两套寄存器 | RSR/ID/DMS 全簇共用；HCR/HSR/CPUSCR 每核私有 | `ct_had_common_regs.v` / `ct_had_regs.v` | 共用信息一份即可，核私有状态各自独立 |
| HAD_ID 硬编码能力位 | 版本 2.3、BKPT_NUM=2、DDC=1 | `ct_had_regs.v:413-441` | 与软件 DebugServer 协议对齐，上电即可读 |
| HCR 集中所有控制开关 | 断点 RC/BC + 请求 DR/ADR + SQC/TME/DDCEN | `ct_had_regs.v:655-658,880-896` | 一个寄存器涵盖断点与运行控制，寻址简单 |
| HSR sticky + 死因位 | 进入原因位 + cpu dead reason | `ct_had_regs.v:665-836` | 调试器一次读出"为何进、是否卡死" |
| CPUSCR 影子扫描链 | WBBR/PC/IR/CSR 四件套 | `ct_had_regs.v:542-613` | 借指令窥探的统一载体，覆盖全架构状态 |
| WBBR 三写源 + ffy 阀门 | 调试器/DDC/CPU 回写，ffy 控回写 | `:547-559,869` | 同寄存器服务"写参数"与"取结果" |
| MBIR 记录命中索引 | A=01/B=10 | `:838-852` | 多断点时区分谁触发 |
| DMS 每核 debug-disable | sysio 掩码可关某核调试 | `ct_had_common_regs.v:166-169` | 安全/TEE/量产场景禁用 |
| 4 位多核字段预留 | core_rst/dbg_mask/etm 4 路 | `ct_had_common_regs.v:106`,`ct_had_etm.v` | 架构支持 4 核，本配置用 2 核 |

---

## 覆盖声明

本篇覆盖 `ct_had_regs.v`（HAD_ID 能力位、HCR 控制字段、HSR sticky 进入原因与死因位、CPUSCR=WBBR/PC/IR/CSR、BABA/BAMA/MBIR、读出 MUX）与 `ct_had_common_regs.v`（RSR/ID/DMS），并梳理 `ct_had_common_top.v`/`ct_had_private_top.v` 的实例化结构与多核掩码。所有字段位、值、信号与行号均按 RTL 实读标注，未对行为虚构。各字段如何被控制逻辑使用见 `03_had_ctrl_ddc.md`，断点字段语义见 `02_had_breakpoint.md`，快照 FIFO 见 `04_had_trace.md`。
