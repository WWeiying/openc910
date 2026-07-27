# C910 HAD 总览 模块详细教学文档

> RTL 源目录：`C910_RTL_FACTORY/gen_rtl/had/rtl/`（共 22 个 `.v` 文件，约 7158 行）
>
> 顶层文件：`ct_had_common_top.v`（343 行，共用/JTAG 侧）、`ct_had_private_top.v`（1078 行，每核私有侧）
>
> 本篇是 HAD 子系统的"思想总览"，建议先读完本篇建立全局认识，再按 `README.md` 的学习路径深入各模块。

---

## 目录

1. [模块概述](#1-模块概述)
2. [硬件调试的核心思想：停核 → 注入指令 → 借指令窥探 → 恢复](#2-硬件调试的核心思想停核--注入指令--借指令窥探--恢复)
3. [HAD v2.3 与 RISC-V Debug Spec 的区别](#3-had-v23-与-risc-v-debug-spec-的区别)
4. [整体结构与数据流](#4-整体结构与数据流)
5. [多核 halt-all 与交叉触发](#5-多核-halt-all-与交叉触发)
6. [HACR 寻址模型（bank/index/core）](#6-hacr-寻址模型bankindexcore)
7. [关键设计决策汇总](#7-关键设计决策汇总)
8. [文件清单与阅读建议](#8-文件清单与阅读建议)

---

## 1. 模块概述

### 1.1 HAD 是什么

HAD（**H**ardware **A**ssisted **D**ebug / 玄铁硬件调试单元）是 C910 的片上调试控制器。外部调试器（如 T-HEAD DebugServer + ICE）通过 **JTAG** 五线接口与 HAD 通信，HAD 再与 CPU 核内各单元（IFU/IDU/IU/LSU/MMU/RTU/CP0）以及簇级单元（CIU/L2C）交互，从而实现：

- **Run-control（运行控制）**：让 CPU 停下来（进入 debug mode）、单步、继续运行。
- **状态查看与修改**：读写通用寄存器、CSR、PC、内存。
- **断点**：2 个硬件地址断点（带地址掩码、范围取反、过 N 次计数、条件类型），加上"不可撤销断点"（non-IRV bkpt）。
- **Trace（跟踪）**：PC-FIFO 记录控制流、OTC 指令计数采样、pipeline FIFO 记录流水线事件、debug-info FIFO 抓取全核调试快照。
- **多核协同**：通过 ETM 交叉触发，让一个核进入 debug 时其他核一起进入（halt-all）。

HAD 实现的是**玄铁/C-SKY 自有调试协议（HAD v2.3）**，而**不是** RISC-V Debug Spec（0.13/1.0）。这一点在阅读时必须时刻牢记：寄存器命名、寻址方式、状态机交互都遵循玄铁体系。版本号 `2.3` 硬编码在 `id_reg[11:8] = 4'b1011`（`ct_had_regs.v:436` 与 `ct_had_common_regs.v:156`）。

### 1.2 共用侧 vs 私有侧

HAD 的代码按物理位置分为两半：

| 侧 | 顶层 | 时钟域 | 内容 |
|----|------|--------|------|
| 共用侧（common） | `ct_had_common_top.v` | JTAG `tclk` + `forever_cpuclk` | TAP 状态机、IO 引脚、串行移位、IR/HACR 译码、ETM 交叉触发、RSR/ID/DMS 共用寄存器、簇级 debug-info FIFO |
| 私有侧（private） | `ct_had_private_top.v` | 核 `cpuclk` / `forever_coreclk` | 2 个断点比较器、调试控制 FSM、DDC 通道、PC-FIFO、寄存器堆（HCR/HSR/CPUSCR…）、trace、event、debug-info FIFO、non-IRV 断点、私有 IR 译码 |

JTAG 信号在 `tclk` 域，CPU 在 `cpuclk` 域，二者之间通过专门的 CDC 同步单元（`ct_had_sync_3flop.v`、`sync_level2pulse`）跨域。

---

## 2. 硬件调试的核心思想：停核 → 注入指令 → 借指令窥探 → 恢复

这一节讲的是**所有 run-control 调试器（不止玄铁）的通用原理**，理解它之后，HAD 的所有寄存器和状态机都会变得自然。

### 2.1 问题：调试器想"看"和"改" CPU 的内部状态

调试器想要：读 x1~x31、读写 PC、读写 CSR、读写内存。但 CPU 的寄存器堆、PC、内存控制器都深藏在流水线内部，JTAG 引脚根本接不到它们。

直接为每个寄存器都拉一根线到 JTAG 是不现实的（成本爆炸）。**业界的统一解法是：不直接接线，而是借用 CPU 自己的执行能力。**

### 2.2 四步法

**第一步：停核（halt）。**
调试器通过 JTAG 发出调试请求。HAD 把请求送给 RTU（退休单元），RTU 在一个安全的指令边界让流水线停下来，CPU 进入 **debug mode**（`rtu_yy_xx_dbgon = 1`）。此时 CPU 不再执行用户程序，但流水线、寄存器堆都还在、值都还保留着。

在 C910 中，进入 debug 的请求来源很多（见 `ct_had_ctrl.v:445-510`）：
- 异步请求 `had_rtu_xx_jdbreq`（调试器随时按下"暂停"）；
- 同步请求 `had_rtu_hw_dbgreq`（DR 位置 1、或总线 sdb 请求）；
- 硬件断点请求 `had_rtu_inst_bkpt_dbgreq` / `had_rtu_data_bkpt_dbgreq`；
- trace 计满请求 `had_rtu_trace_dbgreq`；
- 事件（跨核）请求 `had_rtu_event_dbgreq`；
- non-IRV 断点 `had_rtu_non_irv_bkpt_dbgreq`。

**第二步：注入指令（inject instruction）。**
CPU 停在 debug mode 后，HAD 可以往 IFU 的取指通路"喂"一条它指定的指令，而不是从内存正常取指。具体机制：HAD 把一条 32 位指令写进 IR 寄存器（`ct_had_regs.v:578-590`，输出 `had_ifu_ir`），然后置 `had_ifu_ir_vld`（`ct_had_ctrl.v:656`）。CPU 就会**执行这一条由调试器给定的指令**，执行完又停回 debug mode。

**第三步：借指令窥探（peek via instruction）。**
要读寄存器 x5？注入一条把 x5 搬到某个"调试可见"位置的指令，让 CPU 执行，结果落到 **WBBR**（Write-Back Bus Register，回写总线寄存器，`ct_had_regs.v:547-559`），调试器再通过 JTAG 把 WBBR 移出来即可。

要写寄存器 x5？反过来：调试器把值写进 WBBR，注入一条"把 WBBR 的值写进 x5"的指令。

要读写内存？这正是 **DDC（Debug Data Channel）** 自动化的事情：硬件自动合成 `mv`/`sd` 指令序列搬数据（见 §3.3 与 `03_had_ctrl_ddc.md`）。

要读写 PC/CSR？通过 **CPUSCR**（CPU Scan Chain，CPU 影子扫描链：WBBR/PC/IR/CSR，`ct_had_regs.v:542-613`）。

**核心洞见**：调试器**不需要**为每个内部状态拉专线，只需要两样东西——(a) 能让 CPU 停下；(b) 能让 CPU 执行任意一条它指定的指令并把结果留在一个可移位的寄存器（WBBR）里。有了这两样，CPU 的全部架构状态都"可见可改"了。这就是"借指令窥探"。

**第四步：恢复（resume）。**
调试完毕，调试器恢复被它破坏的现场（PC、被借用的寄存器），然后发出退出命令。HAD 置 `had_yy_xx_exit_dbg` 与 `had_ifu_pcload`（`ct_had_ctrl.v:625-627`），CPU 从 CPUSCR 里的 PC 重新取指，回到用户程序。退出条件见 `ct_had_ctrl.v:609-613`。

### 2.3 一句话总结

> 调试 = **停核**（halt）→ **注入指令**（让 CPU 替我干活）→ **借指令把内部状态搬到 WBBR/CPUSCR 再移出**（窥探/修改）→ **恢复现场并继续**（resume）。

HAD 的寄存器（IR、WBBR、PC、CSR、HCR、HSR）和状态机（TAP、DDC FSM、ctrl FSM）全都是为这四步服务的。

---

## 3. HAD v2.3 与 RISC-V Debug 的区别

HAD 完成的事情（停核/注入/窥探/恢复）与 RISC-V Debug Spec 在**原理上一致**，但在**协议、寄存器、寻址**上完全不同。

### 3.1 接口与寻址

| 维度 | RISC-V Debug Spec | HAD v2.3 |
|------|-------------------|----------|
| 物理接口 | JTAG，DTM(DMI) | JTAG 五线（`tclk/trst_b/tms/tdi/tdo`），见 `ct_had_io.v` |
| 寻址核心寄存器 | DM 通过 DMI 访问 `data0..`、`dmcontrol`、`abstractcs`… | **HACR**（16 位指令寄存器）选 bank+index+core，见 §6、`ct_had_ir.v:237-286` |
| 注入指令的方式 | Program Buffer / Abstract Command | 直接写 IR 寄存器 + `had_ifu_ir_vld` 注入（`ct_had_regs.v:578-590`, `ct_had_ctrl.v:656`） |
| 数据通道 | `data0..datan` 抽象数据寄存器 | **WBBR** + CPUSCR + **DDC**（硬件合成搬内存）|
| 内存访问 | System Bus Access 或 abstract memory | DDC 自动 `mv/sd` 序列（`ct_had_ddc_dp.v:105-108`）|

### 3.2 寄存器命名

HAD 用玄铁的命名体系，与 RISC-V 完全不重叠：

- **HCR**（HAD Control Register，控制寄存器，`ct_had_regs.v:618-658`）—— 相当于 RISC-V 的 `dmcontrol` + 断点配置。
- **HSR**（HAD Status Register，状态寄存器，`ct_had_regs.v:660-836`）—— 记录"为什么进 debug"的各种 sticky 位（mbo/swo/to/dro/adro…）。
- **HAD_ID**（`ct_had_regs.v:396-441`）—— 版本/能力描述，类似 `dmstatus`/`hartinfo`。
- **CPUSCR**（WBBR/PC/IR/CSR）—— RISC-V 没有完全对应物，是玄铁"借指令窥探"的核心载体。
- **HACR**（HAD Command Register / 指令寄存器）—— JTAG IR，决定本次 DR 访问哪个寄存器。

### 3.3 v2.3 的两个增量特性

`id_reg[11:8] = 4'b1011`（=2.3）相对早期版本新增（注释见 `ct_had_regs.v:433-435`）：

1. **DCC/DDC handshake**：调试数据通道，硬件自动合成 `mv x1,x1` / `mv x2,x2` / `sd x2,0(x1)` 序列搬内存，地址递增可循环（`ct_had_ddc_ctrl.v`、`ct_had_ddc_dp.v`）。免去调试器逐条手工注入搬运指令的开销。
2. **TEE support**：可信执行环境支持，体现为 `tee_mask`（`ct_had_common_regs.v:108,114,166`，本配置中暂时接 0）与每核 dbg-disable 掩码。

---

## 4. 整体结构与数据流

### 4.1 共用侧数据流（JTAG → 寄存器）

```
JTAG 引脚                 ct_had_io        ct_had_sm (TAP 状态机)
pad_had_jtg_tdi  ───────► io_serial_tdi
pad_had_jtg_tms  ──────────────────────►  tms_i → tap5_cur_st
pad_had_jtg_tdo  ◄──────  serial_io_tdo
        │
        ▼
ct_had_serial (64 位移位寄存器)
  - shift_ir: 把 16 位移进 HACR (IR)
  - shift_dr: 把数据移进 DR（按选中寄存器宽度 8/16/32/64）
  - capture_dr: 把寄存器读值并行装入移位器
        │serial_xx_data[63:0]
        ▼
ct_had_ir (HACR 译码)
  - hacr_reg[15:0]: bit15=rw, [6:4]=bank, [12:8]=index, [1:0]=core
  - 产生 ir_xx_*_reg_sel（哪个寄存器被选中）
  - 产生 ir_corex_wdata（写数据广播给各核）
        │
        ├──► common_regs (RSR/ID/DMS, 共用)
        └──► 各核 private 侧 (通过 ir_corex_wdata + sm_update_dr/ir)
```

### 4.2 私有侧数据流（核内调试）

```
ir_corex_wdata + sm_update_dr/ir
        │
        ▼
ct_had_private_ir  (每核 HACR 副本 hacr_f[15:0])
  - core_sel = (hacr_f[1:0] == biu_had_coreid)  ← 只有被选中的核才响应
  - 产生本核 ir_xx_*_reg_sel、x_ir_xx_ex/go、x_sm_xx_update_dr_en
        │
        ▼
ct_had_regs (HCR/HSR/CPUSCR/断点基址掩码/event 使能)  ◄──► ct_had_ctrl (调试控制 FSM)
        │                                                      │
   断点比较 ct_had_bkpt × 2, ct_had_nirv_bkpt                  ├─► had_rtu_*_dbgreq (各种停核请求)
   DDC ct_had_ddc_ctrl + ct_had_ddc_dp (搬内存)               ├─► had_ifu_ir / had_ifu_ir_vld (注入指令)
   trace ct_had_trace, PC-FIFO ct_had_pcfifo                  ├─► had_idu_wbbr_data/vld (窥探结果回写)
   debug-info ct_had_dbg_info                                 └─► had_yy_xx_exit_dbg / had_ifu_pcload (恢复)
        │
        ▼
   x_regs_serial_data[63:0] → 经 ir → serial → tdo 移出给调试器
```

### 4.3 与 CPU 各单元的接口

HAD 私有侧从各单元收集状态、向各单元发出控制：
- **RTU**：发出各类 `had_rtu_*_dbgreq` 停核请求；收 `rtu_yy_xx_dbgon`（已进 debug）、`rtu_yy_xx_retire0_normal`（正常退休一条）等。
- **IFU**：`had_ifu_ir`（注入的指令）、`had_ifu_ir_vld`、`had_ifu_pc`、`had_ifu_pcload`。
- **IDU**：`had_idu_wbbr_data/vld`（窥探结果）。
- **CP0**：`cp0_yy_priv_mode`（特权级，断点条件用）、`cp0_had_cpuid_0`（构造 ID）。
- **LSU/MMU**：断点地址比较、debug-info 收集。

---

## 5. 多核 halt-all 与交叉触发

C910 是多核设计（本 RTL 实例化 core0/core1，core2/3 接 0，但架构支持 4 核）。调试器经常需要"一停全停"（halt-all）：在一个核命中断点时，其他核也一起停下，便于观察整个系统的一致状态。

实现机制在 **ETM 交叉触发**（`ct_had_etm.v` + `ct_had_etm_if.v` + `ct_had_event.v`）：

1. 每个核的 `ct_had_event` 在进入/退出 debug 时，产生 `x_enter_dbg_req_o` / `x_exit_dbg_req_o`。
2. `ct_had_etm` 是一个交叉开关（`ct_had_etm.v:151-190`）：把每个核的 enter/exit 请求广播给**其他所有核**，并用 `tee` 域相等做门控（同一安全域才互相触发）。
3. 目标核的 `ct_had_event` 收到 `x_enter_dbg_req_i`，经 2 拍 CDC 同步（`ct_had_event.v:104-118`），再受软件使能位 `regs_event_enter_ie/oe` 门控，最终产生本核的 `event_ctrl_enter_dbg` → 送 ctrl FSM → 发停核请求。

跨核请求工作在专门的 gated `event_clk` 域（`ct_had_etm.v:199-207`），低功耗：没有跨核事件时该时钟不翻转。

簇级 debug-info 快照也由"任一核 ack 进入 debug"触发：`had_dbg_ack_pc = OR(四核 ack)`（`ct_had_common_dbg_info.v:111-114`）。

详见 `04_had_trace.md`。

---

## 6. HACR 寻址模型（bank/index/core）

HACR（HAD Command Register，即 JTAG 的 16 位 IR）是整个 HAD 的"地址总线"。每次调试器先 shift-IR 写 16 位 HACR 选定一个寄存器，再 shift-DR 读/写它。

16 位 HACR 字段（`ct_had_ir.v:195`, `:237-240`, `ct_had_private_ir.v:257-269`）：

| 位 | 名称 | 含义 |
|----|------|------|
| `[15]` | rw | 1=读，0=写（`ir_sm_hacr_rw`，`ct_had_ir.v:195`）|
| `[14]` | go | 注入指令并执行（`ir_xx_go`，`ct_had_private_ir.v:258`）|
| `[13]` | ex | 退出 debug（与 go 配合，`ir_xx_ex`，`ct_had_private_ir.v:259`）|
| `[12:8]` | index | 寄存器索引（bank 内编号）|
| `[6:4]` | bank | bank 选择（0/1/2/3）|
| `[1:0]` | core | 核选择（与 `biu_had_coreid` 比较）|

复位值 `16'h8200`（`ct_had_ir.v:181`, `ct_had_private_ir.v:229`）：bit15=1（读），bank0、index=2（HAD_ID）——上电默认指向只读的 ID 寄存器，调试器一连上就能读到版本。

bank/index → 寄存器的映射（部分，`ct_had_private_ir.v:237-304`）：
- bank0：ID(2)、OTC(3)、MBCA(4)、MBCB(5)、PCFIFO(6)、BABA(7)、BABB(8)、BAMA(9)、BAMB(10)、HCR(13)、HSR(14)、WBBR(17)、PC(19)、IR(20)、CSR(21)、DADDR(24)、DDATA(25)
- bank1：MBIR(27)
- bank2：EVENT_OE(2)、EVENT_IE(3)、DBGFIFO(4)、PIPEFIFO(5)、PIPESEL(6)
- bank3（共用）：DBGFIFO2(0)、RSR(1)、DMS(2)

详见 `01_had_jtag.md`。

---

## 7. 关键设计决策汇总

| 决策 | 内容 | 出处 | 为什么 |
|------|------|------|--------|
| 借指令窥探 | 不为每个寄存器拉专线，而是注入指令 + WBBR/CPUSCR 搬运 | `ct_had_regs.v:547-613` | 极大降低布线/面积成本，CPU 已有执行能力 |
| TAP 用 6 位独热风格编码 | `tap5_cur_st[5:0]`，UPDATE_IR/DR 用单独 1 位（bit4/bit5） | `ct_had_sm.v:101-118,225,227` | UPDATE 位单独成位以方便跨域同步 |
| HACR 16 位、bank/index/core | 一个 IR 编码"寄存器地址+操作+核" | `ct_had_ir.v:237-286` | 用极窄的 IR 覆盖大量调试寄存器与多核 |
| 复位 HACR 指向 ID | `16'h8200` | `ct_had_ir.v:181` | 上电即可读版本，握手简单 |
| DDC 硬件搬内存 | FSM 自动合成 `mv x1,x1`/`mv x2,x2`/`sd x2,0(x1)`，地址 +8 循环 | `ct_had_ddc_ctrl.v:78-199`, `ct_had_ddc_dp.v:92-108` | 免去调试器逐条注入，块搬运高效 |
| 2 个硬件断点 + N 次计数 | BABA/BAMA + BABB/BAMB，8 位 MBC 计数器 | `id_reg[15:12]=2` `ct_had_regs.v:419`; `ct_had_bkpt.v:272-287` | 支持"第 N 次命中才停"，常用于循环调试 |
| non-IRV 断点 | 不可撤销断点，命中即不可恢复执行 | `ct_had_nirv_bkpt.v` | 用于不能被推测执行撤销的关键断点 |
| PC-FIFO 深度 16，可多写 | 每周期最多 3 条改流指令入队，溢出丢最旧 | `ct_had_pcfifo.v:101`(DEPTH=16), `:162-178` | 3-wide 退休需要多端口入队 |
| 全核 halt-all 用 ETM 交叉触发 | 跨核 enter/exit 广播，tee 域门控 | `ct_had_etm.v:151-190` | 多核一致停核 |
| 时钟门控贯穿全模块 | `gated_clk_cell` + `sm_clk_en` 等 | `ct_had_sm.v:323-334` 等 | 调试单元绝大多数时间空闲，省功耗 |
| TEE/版本号硬编码 | v2.3 = `4'b1011` | `ct_had_regs.v:436` | 与软件 DebugServer 协议对齐 |

---

## 8. 文件清单与阅读建议

| 文件 | 行数 | 归属篇章 |
|------|------|----------|
| `ct_had_sm.v` | 353 | `01_had_jtag.md` |
| `ct_had_ir.v` | 313 | `01_had_jtag.md` |
| `ct_had_private_ir.v` | 354 | `01_had_jtag.md` |
| `ct_had_io.v` | 79 | `01_had_jtag.md` |
| `ct_had_serial.v` | 226 | `01_had_jtag.md` |
| `ct_had_sync_3flop.v` | 95 | `01_had_jtag.md` |
| `ct_had_bkpt.v` | 328 | `02_had_breakpoint.md` |
| `ct_had_nirv_bkpt.v` | 153 | `02_had_breakpoint.md` |
| `ct_had_ctrl.v` | 711 | `03_had_ctrl_ddc.md` |
| `ct_had_ddc_ctrl.v` | 205 | `03_had_ctrl_ddc.md` |
| `ct_had_ddc_dp.v` | 117 | `03_had_ctrl_ddc.md` |
| `ct_had_pcfifo.v` | 300 | `04_had_trace.md` |
| `ct_had_trace.v` | 130 | `04_had_trace.md` |
| `ct_had_etm.v` | 220 | `04_had_trace.md` |
| `ct_had_etm_if.v` | 126 | `04_had_trace.md` |
| `ct_had_event.v` | 182 | `04_had_trace.md` |
| `ct_had_regs.v` | 980 | `05_had_regs.md` |
| `ct_had_common_regs.v` | 184 | `05_had_regs.md` |
| `ct_had_common_top.v` | 342 | `05_had_regs.md` |
| `ct_had_private_top.v` | 1078 | `05_had_regs.md` |
| `ct_had_dbg_info.v` | 452 | `04_had_trace.md` / `05_had_regs.md` |
| `ct_had_common_dbg_info.v` | 230 | `04_had_trace.md` / `05_had_regs.md` |

**推荐学习路径**：本篇（00）→ JTAG/IR（01，搞清楚调试器怎么寻址）→ ctrl/DDC（03，搞清楚停核/注入/窥探/恢复怎么实现）→ 断点（02）→ trace（04）→ 寄存器堆（05，把所有寄存器字段对齐）。

---

## 覆盖声明

本篇为 HAD 子系统总览，覆盖核心调试思想、HAD v2.3 与 RISC-V Debug 的区别、整体数据流、多核 halt-all、HACR 寻址模型与关键设计决策。各模块的端口级、信号级、行号级细节见 `01`~`05` 各分篇。本篇所有结构性结论均可在对应 RTL 文件中按所标行号核对，未对 RTL 行为做任何虚构。
