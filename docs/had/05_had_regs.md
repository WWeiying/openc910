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
10. [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 这一层做什么

寄存器堆是 HAD 的"状态载体"。`03_had_ctrl_ddc.md` 的控制逻辑读写这些寄存器、`02_had_breakpoint.md` 的断点用它们的字段、`01_had_jtag.md` 的 HACR 寻址选中它们。本篇把所有寄存器的**字段定义、读写时机、对外接口**对齐到位。

寄存器按物理位置分两套（与 `00_had_overview.md §1.2` 的共用/私有侧一致）：

| 套 | 文件 | 寄存器 |
|----|------|--------|
| 私有侧（每核一份）| `ct_had_regs.v` | HCR, HSR, CPUSCR(WBBR/PC/IR/CSR), BABA/BABB/BAMA/BAMB, EVENT_OE/IE, MBIR, HAD_ID(私有副本) |
| 共用侧（当前双核簇一份）| `ct_had_common_regs.v` | RSR 状态、HAD_ID 共用视图、DMS 外部 mask 视图、DBGFIFO2 数据 |

参数：`ADDRW=PA_WIDTH`（物理地址宽 40），`DATAW=64`（`ct_had_regs.v:408-409`）。

### 1.2 寄存器读出统一出口

所有私有寄存器读出用 one-hot 风格 OR-MUX 组合（`ct_had_regs.v:946-969`），再在无显式复位的 `cpuclk` 寄存器中打一拍成为 `x_regs_serial_data`。如果错误地同时选中多个寄存器，结果是按位 OR，不会仲裁出唯一一个。共用侧 `common_regs_data` 则是纯组合 OR-MUX，没有同样的输出寄存级。二者最终由 `ct_had_ir` 根据 HACR core/bank 选择后，在 Capture-DR 装入串行移位器。

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

主要对外接口输出：`had_ifu_ir`/`had_ifu_pc`（注入指令/恢复 PC）、`had_idu_wbbr_data/vld`（WBBR 作为 IDU source0 的覆盖输入）、`had_yy_xx_bkpt*_base/mask/rc`（送 IFU/LSU 比较，比较结果之后随流水线到 RTU）。`had_ifu_pc[38:0]` 省略架构 PC bit0：它直接取 `pc_reg[39:1]`，接收方需要按半字粒度理解。

---

## 3. HAD_ID：版本与能力描述

HAD_ID 是只读的能力描述寄存器（复位 HACR 默认就指向它，见 `00_had_overview.md §6`）。字段布局注释在 `ct_had_regs.v:396-407`，赋值在 `:413-441`：

| 位 | 字段 | 值 | 含义 |
|----|------|----|----|
| `[31:28]` | JTAG 接口类型 | 0 | — |
| `[27:26]` | CPU 指令架构编码 | 私有 ID 透传 `cp0_had_cpuid_0[27:26]` | `:414` |
| `[18]` | HACR 宽度 | 1 | HACR 为 16 位 |
| `[17]` | BANK1 能力标志 | 0 | `:417` |
| `[16]` | DDC | **1** | 支持 DDC（v2.3 增量）`:418` |
| `[15:12]` | BKPT_NUM | **2** | 2 个硬件断点 `:419` |
| `[11:8]` | 源码框图名 `HAD_REVISION` | **`4'b1011`** | 邻近注释称 “version 2.3” `:433-436` |
| `[7:4]` | 源码框图名 `HAD_VERSION` / 注释称 ISA version | `0100` | 注释枚举中对应 960 `:438-439` |
| `[3:0]` | ID_VERSION | `0011` | `:441` |

`id_reg[11:8]=1011` 邻近注释明确标为 version 2.3，并列出 “add DCC handshake / add TEE support”。这里源码写的是 **DCC**，不能擅自改成 DDC；同时当前集成的 TEE 动态输入多处固定为 0，所以版本注释描述协议演进，不等于当前配置已启用所有安全域功能。

还有两个容易忽略的不一致：

- `id_reg[17]` 报告 BANK1=0，但 `ct_had_private_ir` 仍有 bank1/index27 的 MBIR 译码，`ct_had_regs` 也提供 MBIR 读回。这可能是兼容/遗留路径，软件能力探测应以 ID 标志为准，RTL研究则应承认该物理路径仍存在。
- 私有 ID 的 `[27:26]` 来自 CPUID；共用 ID 将其固定为 `2'b10`。两份 ID 不是逐 bit 完全对称。

---

## 4. HCR：HAD 控制寄存器

HCR 是项目私有的 32 位 HAD 控制寄存器。它在概念上同时承担运行控制、断点条件和 trace 配置，但字段和访问协议不等同于 RISC-V Debug Specification 的 `dmcontrol`，不能直接做寄存器级类比。

| 位 | 字段 | 信号 | 作用 |
|----|------|------|------|
| `[31]` | RTL 寄存变量 `hcr_nicven`，输出名 `regs_xx_nirven` | `regs_xx_nirven`（`:896`）| 选择 non-IRV 断点路径 |
| `[21]` | ADR | `regs_ctrl_adr`（`:880`）| 异步调试请求 |
| `[20]` | DDCEN | `regs_xx_ddc_en`（`:882`）| DDC 通道使能 |
| `[17:16]` | SQC | `regs_ctrl_sqc`（`:884`）| 顺序限定（A→B→trace 链）|
| `[15]` | DR | `regs_ctrl_dr`（`:886`）| 同步调试请求 |
| `[14]` | IDRE | `hcr_idre` | 当前仅保存并读回；全仓库没有其它功能使用点 |
| `[13]` | TME | `regs_ctrl_tme`（`:888`）| trace 模式使能 |
| `[12]` | FRZC | `regs_ctrl_frzc`（`:890`）| 冻结 PCFIFO |
| `[11]` | RCB | `had_yy_xx_bkptb_rc`（`:934`）| 断点 B 范围取反 |
| `[10:6]` | BCB | `regs_xx_bcb`（`:892`）| 断点 B 条件类型 |
| `[5]` | RCA | `had_yy_xx_bkpta_rc`（`:932`）| 断点 A 范围取反 |
| `[4:0]` | BCA | `regs_xx_bca`（`:894`）| 断点 A 条件类型 |

HCR 写入时一次性覆盖所有已实现字段；未实现/保留位读回为 0。ADR/DR 是保持寄存位，不会因 RTU ack 或退出 debug 自动清除，软件需要显式重写 HCR 清位，否则退出后仍可能再次提出请求。`hcr_jtgr/jtgw_int_en` 固定为 0，表示打包位置存在但当前无 JTAG 读写中断功能。

---

## 5. HSR：HAD 状态寄存器（进 debug 原因）

HSR 混合了三类不同语义：请求/触发原因 sticky 位、debug ack 时采样的流水线状态位，以及持续更新的 `ps/pm` 状态。不能把 32 位全部称为“进 debug 原因”。完整打包顺序为：

| 位 | 信号 | 更新语义 |
|----|------|----------|
| `[31:21]` | 0 | 保留，固定 0 |
| `[20]` | `idu_stall` | `rtu_had_xx_dbg_ack_pc` 时采样 |
| `[19]` | `iq_not_empty` | debug ack 时采样 `!idu_had_iq_empty` |
| `[18]` | `rob_not_empty` | debug ack 时采样 `!rtu_had_rob_empty` |
| `[17]` | `inst_not_wb` | debug ack 时采样 RTU 输入 |
| `[16]` | `pro` | event 请求 sticky |
| `[15]` | `bus_dead` | debug ack 时采样 `!(ifu_no_op && lsu_no_op)` |
| `[14]` | `ifu_dead` | debug ack 时采样 `biu_idle && ifu_no_inst` |
| `[13]` | `exe_dead` | debug ack 时采样 RTU 输入 |
| `[12]` | `ps` | 每拍更新的 pipeline idle 指示，1=idle |
| `[11:10]` | 0 | 保留，固定 0 |
| `[9:2]` | `adro,dro,mbo,swo,to,frzo,sqb,sqa` | set 优先、退出 debug 清除的 sticky 位 |
| `[1:0]` | `pm` | 当前 reset/debug/low-power/run 编码 |

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

这些 sticky 位多在请求或本地命中条件出现时置位，并不全都等待 `rtu_had_dbgreq_ack`。同一次 debug 过程中也可能累计多个原因，因此 HSR更准确地表示“已观察到哪些触发/请求状态”，不保证只有一个 one-hot 的最终停核原因。各 always block中 set 分支优先于 exit-clear 分支，同拍同时出现时保持为 1。

### 5.2 CPU 状态 / 死因位

```verilog
// 进 debug 那一刻锁存 CPU 状态（dbg_ack_pc 时）                      :665-685
inst_not_wb, rob_not_empty, iq_not_empty, idu_stall,
bus_dead, ifu_dead, exe_dead
```

虽然信号名含 `dead`，当前逻辑没有超时计数器或死锁证明：

- `bus_dead` 只是 ack 当拍 IFU/LSU 并非同时 `no_op`；
- `ifu_dead` 是 IFU/LSU 都 no-op 且 IFU no-inst；
- `exe_dead` 直接采样 RTU 提供的状态。

它们是进入 debug 附近的诊断分类快照，可辅助判断停顿位置，但不能单独证明处理器“卡死”。`inst_not_wb/ROB/IQ/stall` 同理是现场状态，而非性能计数。

### 5.3 PM：功耗/调试态

```verilog
always @(...)                                                        :807-819
  reset/ifu_reset_on → pm=2'b11(reset-on 状态);
  rtu_yy_xx_dbgon    → pm=2'b10(debug);
  低功耗模式          → pm=2'b01;
  否则                → pm=2'b00(运行)
```

`pm=01` 只要 `cp0_had_lpmd_b` 任一 bit 为 0，`pm=10` 要求 `dbgon`，`pm=11` 仅在复位或 `ifu_had_reset_on` 时出现，不能解释为一般“CPU 全空闲”；普通 pipeline idle 由独立的 `ps` 表示。这意味着 `had_clk_en_ff` 一旦被调试活动置位，不会因为普通 `ps=1` 自动清除，只有 PM 回到 11 才清。PM 同时输出到 BIU。

---

## 6. CPUSCR：WBBR / PC / IR / CSR 影子扫描链

源码注释把这一组称为 `CPUSCR scan chain`，并写着包括 WBBR、PSR、PC、IR、CSR；但当前有效寄存器和私有 IR 端口中没有可访问的 PSR 数据寄存器，只有 PC、IR、CSR 和 WBBR。因此本文只描述实际存在的四项，不把注释中的 PSR 当成已实现功能。

### 6.1 WBBR（回写总线寄存器）

三个写源优先级从高到低为：调试器 Update-DR、DDC、IDU writeback。`had_idu_wbbr_vld = ffy && dbgon` 是 WBBR→IDU 的 source0 覆盖有效，不是 IDU→WBBR 的回写阀门；反向捕获由 `idu_had_wb_vld` 独立控制。IDU 的回传值是多个执行写回端口按 valid 掩码后 OR 的结果，协议依赖 debug 注入期间只有预期写回源有效，若多个源同拍有效，WBBR看到的是按位 OR 而非优先选择。

### 6.2 PC

```verilog
always @(...)                                                       :564-573
  rtu_had_xx_dbg_ack_pc → pc <= {RTU 给的 PC，按 mmu_en 决定符号扩展};  // 进 debug 锁存当前 PC
  pc_wen(调试器写)       → pc <= ir_xx_wdata;
```

debug ack 捕获优先于同拍调试器 PC 写入。捕获时把 RTU 的半字 PC 补 bit0=0，并按当时 `mmu_en` 对高位符号/零扩展；软件写则可写完整 64 位。输出到 IFU时只取 `[PA_WIDTH-1:1]`，高于 PA_WIDTH 的软件写入位不会进入 IFU，架构 bit0 也不在接口中传输。`had_ifu_pcload` 另行触发装载，单看 `had_ifu_pc` 变化不表示 IFU 已接受。

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

- **ffy**（`[8]`）：在 debug 中使 IDU pipe0 source0 使用 WBBR 数据，而不是 PRF source0；DDC 在两个 `addi` 装载阶段置 ffy。
- **fdb**（`[7]`）：内存断点总使能（`regs_ctrl_fdb`，`:875`），断点请求都要 `&& regs_ctrl_fdb`（`ct_had_ctrl.v:481-482,507-508`）。

DDC 更新 CSR 时会同时把 `fdb` 强制清 0，而不是保留软件原值。JTAG CSR 写优先于同拍 DDC 更新。因而 FFY 是注入源操作数选择，FDB 是普通内存断点请求总门控，两者都不是通用架构 CSR。

---

## 7. 断点基址寄存器与 MBIR

### 7.1 BABA/BAMA/BABB/BAMB

基址寄存器可读写 64 位，但比较接口只输出低 `PA_WIDTH=40` 位；高 24 位不参与当前 IFU/LSU 比较。8 位 BAMA/BAMB 是低地址 bit 的比较使能，1=比较、0=忽略，不保证形成连续区间。BAMA/BAMB 复位为 0意味着低 8 位全忽略，而不是精确单地址匹配。

### 7.2 MBIR：哪个断点命中

```verilog
always @(...)                                                       :838-850
  ctrl_regs_bkpta_vld → mbir_idx <= 2'b01;   // 断点 A 命中
  ctrl_regs_bkptb_vld → mbir_idx <= 2'b10;   // 断点 B 命中
  exit_dbg            → mbir_idx <= 2'b0;
assign mbir_reg = {30'b0, mbir_idx};                                :852
```

源码没有在本文件给出 MBIR 英文展开；其功能是保存 A/B 索引。A 的 set 分支优先于 B，同拍两者都有效时记录 `01`。它位于物理存在的 bank1/index27 译码路径，但 HAD_ID.BANK1 报告 0，使用时需注意前述能力标志不一致。

---

## 8. 共用侧寄存器：RSR / ID / DMS

`ct_had_common_regs.v`（全簇一份）：

### 8.1 RSR（Reset Status Register）

```verilog
assign rsr_data = {28'b0, core_rst[3:0] | tee_mask[3:0]};           :114
```

core0/core1 的 bit 在对应低有效复位期间异步置 1，并在复位释放后的第一个 `forever_cpuclk` 上清 0；它不是长期保留“曾经复位过”的 sticky 历史。core2/core3 固定为 1，更适合解释成当前未接入槽的占位状态，不能当成两颗真实核持续处于复位。`tee_mask` 当前固定为 0。

### 8.2 HAD_ID（共用副本）

共用副本 `[19]=1` 表示有 RSR，并把 `[27:26]` 固定为 `2'b10`；私有副本该字段透传 CPUID。其余主要版本/能力常量相近，但不应称为完全对称。

### 8.3 DMS（Debug Mask / debug-disable）

```verilog
assign dms_data = {28'b0, sysio_had_dbg_mask[3:0] & ~tee_mask[3:0]};  :166
assign core0_had_dbg_mask = sysio_had_dbg_mask[0];                    :168
assign core1_had_dbg_mask = sysio_had_dbg_mask[1];                    :169
```

DMS 在当前 RTL中是对外部 `sysio_had_dbg_mask[3:0]` 的**只读观察窗口**，没有 JTAG Update-DR 写逻辑。core0/core1 mask 不经过 `tee_mask`，直接送私有侧；DMS读值才与 `~tee_mask` 相与。由于 tee_mask 固定为 0，两者当前相同。mask 的效果通过私有 IR 更新门控、CP0 debug 请求门控和送 RTU 的 `had_rtu_dbg_disable` 共同实现；不能只看某一条 request 是否仍拉高来判断禁用失效。

---

## 9. 顶层组织：common_top 与 private_top

### 9.1 ct_had_common_top（共用/JTAG 侧）

common_top 实例化 TAP、串行移位、HACR 译码、双核 ETM、common regs 和簇级快照。它还保留 APB PC-trace 端口，但 `ct_had_pctrace_busif` 实例已注释，当前 `pready_had=1`、`perr_had=0`、`prdata_had=0`；所以 APB 访问只得到立即完成的零数据，不存在有效 PC-trace APB 从设备。

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

它在核 `cpuclk/forever_coreclk` 域组织核内调试逻辑。私有顶层还保留 PC-trace/bus-trace 占位接口，但 `had_lsu_pctrace_en=0`、`had_lsu_bus_trace_en=0`；只有 PIPESEL=LSU 时的 `had_lsu_dbg_info_en` 可使 `had_lsu_dbg_en` 有效。

### 9.3 多核掩码与连接

私有侧通过 `biu_had_coreid` 与 HACR core 字段比较后门控有副作用动作。当前 `openC910.v` 只实例化 core0/core1 的私有 HAD，共用顶层也只接两核读回/ack/event。core2/3 的 RSR/ETM/读回路径是常量占位。2 位 core 编码和 4 位状态向量只能证明 RTL保留了四槽编码空间，不能据此宣称当前架构已经实现或验证四核 HAD。

## 本章小结

HAD 寄存器层分成簇级共用部分和每核私有部分。RSR、ID、DMS 等共用信息只保存一份，HCR、HSR、CPUSCR、WBBR 和断点相关状态则由每个已实例化核心独立维护。ID 寄存器硬编码报告版本 2.3、两个硬件断点和 DDC 能力；HCR 集中控制断点 RC/BC、调试请求、SQC、trace 和 DDC；HSR 同时容纳 sticky 触发原因、RTU 确认快照以及动态 PS/PM。因而读取状态位前必须先判断它属于命令配置、锁存原因、确认时刻快照还是实时处理器状态，不能仅凭 `dead` 等字段名称推导为死锁检测器。

CPUSCR 当前只开放 WBBR、PC、IR 和 CSR 四类交换对象，源码注释中的 PSR 没有接入。WBBR 的输入方向包括调试器、DDC 和 CPU 回写，输出方向可在 FFY 控制下覆盖 IDU source0；MBIR 另外用 `01` 和 `10` 记录 A、B 断点命中来源。DMS 只是外部 debug mask 的只读视图，实际禁用门控分布在私有 IR、CP0 和 RTU。共用寄存器虽然保留四个 core 槽位，但当前私有 HAD 和事件网络只实例化 core0/core1，core2/core3 为常量占位；源码中被注释的 PC-trace/APB 路径也不构成当前功能。只有同时核对能力字段、顶层实例和有效数据通路，才能判断软件可见寄存器是否对应当前可执行的调试流程。
