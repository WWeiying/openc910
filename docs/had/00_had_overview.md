# C910 HAD 总览 模块详细教学文档

> RTL 源目录：`C910_RTL_FACTORY/gen_rtl/had/rtl/`（共 22 个 `.v` 文件，约 7158 行）
>
> 顶层文件：`ct_had_common_top.v`（342 行，共用/JTAG 侧）、`ct_had_private_top.v`（1078 行，每核私有侧）
>
> 本篇是 HAD 子系统的"思想总览"，建议先读完本篇建立全局认识，再按 `README.md` 的学习路径深入各模块。

---

## 目录

1. [模块概述](#1-模块概述)
2. [硬件调试的核心思想：停核 → 注入指令 → 借指令窥探 → 恢复](#2-硬件调试的核心思想停核--注入指令--借指令窥探--恢复)
3. [HAD v2.3 与 RISC-V Debug 的区别](#3-had-v23-与-risc-v-debug-的区别)
4. [整体结构与数据流](#4-整体结构与数据流)
5. [多核 halt-all 与交叉触发](#5-多核-halt-all-与交叉触发)
6. [HACR 寻址模型（bank/index/core）](#6-hacr-寻址模型bankindexcore)
7. [关键设计决策汇总](#7-关键设计决策汇总)
8. [文件清单与阅读建议](#8-文件清单与阅读建议)

---

## 1. 模块概述

### 1.1 HAD 是什么

HAD 是 C910 RTL 对项目私有硬件调试子系统的统一前缀。公开源码没有给出 `H/A/D` 的正式英文展开，因此“Hardware Assisted Debug”可以作为常见理解，但不作为由本 RTL 证明的寄存器/协议名称。外部调试器通过 TCLK/TMS/TDI/TDO/TRST 形式的串行接口访问 HAD；该接口采用经典 16 状态 TAP 拓扑，但数据协议是自定义 HACR/DR 访问，并不能仅凭五线接口就宣称完整 IEEE 1149.1 兼容。

- **Run-control**：向 RTU提出多类 debug 请求、观察 ack/dbgon、请求退出和重新装载 PC。
- **注入与状态交换**：通过 IR 注入 32 位指令，WBBR在 HAD 与 IDU之间双向交换整数数据，PC/CSR 等由专用调试寄存器控制。
- **断点**：A/B 两套地址断点配置和本地过滤/计数；实际地址比较在 IFU/LSU。另有 RTL 命名为 non-IRV 的退休元数据路径。
- **Trace/诊断**：PCFIFO、PIPEFIFO、OTC 倒计数触发，以及核内/CIU-L2C 快照读窗。
- **双核协同**：当前实例在 core0/core1 之间转发可配置 enter/exit 事件；core2/3 是常量占位。

当前寄存器、HACR 寻址和注入通路是项目私有实现，不是由公开 RTL中的 RISC-V Debug Module/DMI 寄存器构成。`id_reg[11:8]=4'b1011` 邻近源码注释标为 version 2.3；字段框图把 `[11:8]` 命名为 `HAD_REVISION`、`[7:4]` 命名为 `HAD_VERSION`，文档应保留这种源码层次，而不是把两个字段混为一个版本号。

### 1.2 共用侧 vs 私有侧

HAD 的代码按物理位置分为两半：

| 侧 | 顶层 | 时钟域 | 内容 |
|----|------|--------|------|
| 共用侧（common） | `ct_had_common_top.v` | `tclk` + `forever_cpuclk` | TAP、IO、串行移位、HACR 译码、双核 ETM、RSR/ID/DMS 视图、簇级快照；APB PC-trace 从设备已注释并返回固定零 |
| 私有侧（private） | `ct_had_private_top.v` | `cpuclk` / `forever_coreclk` | 两个断点过滤/计数实例、控制逻辑、DDC 连续 store 通道、PCFIFO、寄存器、OTC/event/PIPEFIFO/快照、non-IRV、私有 HACR 副本 |

TAP 状态/串行移位在 `tclk` 域，调试寄存器动作在 CPU/core 时钟域。共用侧只同步 Update-IR；每核私有侧同步 Update-IR/DR。`sync_level2pulse` 虽输出名为 ack，但当前实例没有把 ack 反馈到 TCLK 源端，所以这是慢电平到快域的同步/边沿检测，不是端到端握手。

---

## 2. 硬件调试的核心思想：停核 → 注入指令 → 借指令窥探 → 恢复

这一节是理解 HAD 的教学抽象，不是对所有 run-control 调试器实现方式的穷尽描述。不同体系可能使用抽象命令、程序缓冲区、系统总线访问或专用扫描链；C910 这里的关键特征是 RTU 停核、IFU 指令注入和 WBBR 数据交换。

### 2.1 问题：调试器想"看"和"改" CPU 的内部状态

调试器想要：读 x1~x31、读写 PC、读写 CSR、读写内存。但 CPU 的寄存器堆、PC、内存控制器都深藏在流水线内部，JTAG 引脚根本接不到它们。

为每个状态设计独立串行可见路径会增加连线、选择和验证成本。C910 的取舍之一是复用 CPU 执行数据通路，通过少量调试寄存器与注入指令访问更多状态。这是体系结构层面的设计动机，不是由单条 RTL赋值给出的面积测量结论。

### 2.2 四步法

**第一步：停核（halt）。**
调试器或内部事件让 HAD提出请求；RTU根据退休槽、split、flush 和 debug-disable 等条件确认，并用 ack/dbgon 表示后续状态。请求线拉高、RTU ack 和 `rtu_yy_xx_dbgon=1` 是三个不同阶段。文档不能把“提出请求”写成“已经安全停核”，也不能笼统保证所有内部瞬态状态都原样保留。

在 C910 中，进入 debug 的请求来源很多（见 `ct_had_ctrl.v:445-510`）：
- 异步请求 `had_rtu_xx_jdbreq`（调试器随时按下"暂停"）；
- 同步请求 `had_rtu_hw_dbgreq`（DR 位置 1、或总线 sdb 请求）；
- 硬件断点请求 `had_rtu_inst_bkpt_dbgreq` / `had_rtu_data_bkpt_dbgreq`；
- trace 计满请求 `had_rtu_trace_dbgreq`；
- 事件（跨核）请求 `had_rtu_event_dbgreq`；
- non-IRV 断点 `had_rtu_non_irv_bkpt_dbgreq`。

**第二步：注入指令（inject instruction）。**
在 debug mode 中，调试器先写 32 位 IR，再以 HACR `go=1,ex=0` 配合 Update-DR 产生一拍 `had_ifu_ir_vld`。这是向 IFU提出注入有效；指令是否完成、何时写回和退休仍要沿 IFU→IDU→执行/LSU→RTU 观察。`ct_had_ctrl` 本身没有“本条注入完成”的握手状态，不能把 `had_ifu_ir_vld` 同拍解释成“执行完又停回”。

**第三步：借指令窥探（peek via instruction）。**
要读整数值，可组织一条产生整数/LSU 写回的注入指令；在 debug 中，IDU把有效写回数据通过 `idu_had_wb_data/vld` 送到 WBBR。调试器随后读 WBBR。因为写回汇总是多个端口按 valid 掩码后按位 OR，协议必须保证目标注入期间只有预期写回源有效。

要写整数寄存器，调试器把值放入 WBBR并置 CPUSCR.CSR.FFY；IDU pipe0 source0 随后使用 WBBR而非 PRF 数据。再注入如 `addi x5,src,0` 的合适指令，执行结果写入目标寄存器。FFY控制的是 **WBBR→IDU source0**，不是“允许结果回 WBBR”。

当前 DDC只自动生成 `addi x1,x1,0`、`addi x2,x2,0`、`sd x2,0(x1)`，配合 WBBR source0 覆盖完成连续 8 字节写入和地址 +8。它没有自动 load/readback 状态。其它内存读写能力若由普通注入指令实现，应与 DDC 固定序列分开描述。

HAD 保存的 PC、注入 IR、WBBR 和仅含 FFY/FDB 的 16 位调试 CSR 位于源码所称 CPUSCR scan chain。这里的 CSR 不是任意架构 CSR 文件；访问架构 CSR仍需合适的注入指令和回写路径。源码注释还列出 PSR，但当前有效寄存器/端口没有 PSR 数据项。

**核心洞见**：少量显式调试寄存器加上受控指令执行，可以复用现有数据通路扩大可访问状态范围。但“全部架构状态都可见可改”需要指令集、特权、异常、浮点/向量状态和回写路径共同支持，不能由 HAD 这几个模块单独证明。公开 RTL直接证明的是 IR、PC、WBBR、FFY/FDB 以及若干诊断向量的连接。

**第四步：恢复（resume）。**
退出命令要求 HACR `go+ex`、Update-DR、退出类寄存器选择和 dbgon 同时有效，或由 event-exit 触发。`ctrl_exit_dbg` 下一拍同时驱动 RTU exit 和 IFU pcload。此时只是提出退出/装载 PC 请求；确认恢复应继续看 dbgon 清除和 IFU后续有效取指。

### 2.3 一句话总结

> 调试 = **停核**（halt）→ **注入指令**（让 CPU 替我干活）→ **借指令把内部状态搬到 WBBR/CPUSCR 再移出**（窥探/修改）→ **恢复现场并继续**（resume）。

HAD 的寄存器（IR、WBBR、PC、CSR、HCR、HSR）和状态机（TAP、DDC FSM、ctrl FSM）全都是为这四步服务的。

---

## 3. HAD v2.3 与 RISC-V Debug 的区别

下面的对照只用于建立概念坐标，不是本地 RTL 的标准一致性证明，也不用于断言某一版外部规范的全部可选功能。C910 HAD 的字段和时序必须以本仓库 RTL为准。

### 3.1 接口与寻址

| 维度 | RISC-V Debug Spec | HAD v2.3 |
|------|-------------------|----------|
| 物理接口 | JTAG，DTM(DMI) | JTAG 五线（`tclk/trst_b/tms/tdi/tdo`），见 `ct_had_io.v` |
| 寻址核心寄存器 | DM 通过 DMI 访问 `data0..`、`dmcontrol`、`abstractcs`… | **HACR**（16 位指令寄存器）选 bank+index+core，见 §6、`ct_had_ir.v:237-286` |
| 注入指令的方式 | Program Buffer / Abstract Command | 直接写 IR 寄存器 + `had_ifu_ir_vld` 注入（`ct_had_regs.v:578-590`, `ct_had_ctrl.v:656`） |
| 数据通道 | `data0..datan` 等抽象数据寄存器 | WBBR + CPUSCR；DDC固定连续 store 序列 |
| 内存访问 | 可由规范定义的 abstract/system-bus 等机制提供 | 当前 DDC自动 `addi/addi/sd` 写方向；其它访问依赖普通注入/系统集成 |

### 3.2 寄存器命名

HAD 用玄铁的命名体系，与 RISC-V 完全不重叠：

- **HCR**：项目私有 32 位控制字，混合请求、断点、trace 和 DDC 配置；只能作功能层粗略类比，不能等同 `dmcontrol`。
- **HSR**：混合原因 sticky、debug-ack 快照和动态 PS/PM 状态，不是 one-hot 原因码。
- **HAD_ID**：项目能力/版本编码；与标准 `dmstatus/hartinfo` 没有寄存器级对应关系。
- **CPUSCR**：源码对 WBBR/PC/IR/CSR 一组调试寄存器的称呼。
- **HACR**：源码中的 16 位命令/选择字；公开 RTL未定义 “HAD Command Register” 的正式英文展开。

### 3.3 v2.3 源码注释与当前实现边界

`id_reg[11:8] = 4'b1011`（=2.3）相对早期版本新增（注释见 `ct_had_regs.v:433-435`）：

1. 注释原文是 **DCC handshake**，不能与模块名 DDC 自动视为同一个缩写。当前私有 Update-IR/DR 同步也没有把 ack 返回 TCLK 源端，因此不要据此宣称端到端 DDC/JTAG 握手完整实现。
2. 注释写 **TEE support**，但当前 `tee_mask`、ETM tee 值和 `ctrl_tee_dbg_disable` 均固定为 0。有效的 debug-disable 来源是外部 `sysio_had_dbg_mask`。这说明代码保留能力/演进痕迹，不等于当前配置启用了动态 TEE 隔离。

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
  - shift_ir: 16 位先进入 serial_shifter；Update-IR 跨域后才更新 HACR
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
  - 每个已实例化核都可更新本地 hacr_f
  - core_sel 只门控 go/ex、DR 写和 FIFO 读等有副作用动作
        │
        ▼
ct_had_regs (HCR/HSR/CPUSCR/断点基址掩码/event 使能)  ◄──► ct_had_ctrl (调试控制 FSM)
        │                                                      │
   断点过滤/计数 ct_had_bkpt × 2, non-IRV                     ├─► had_rtu_*_dbgreq (各种请求)
   DDC ct_had_ddc_ctrl + ct_had_ddc_dp (连续 store)           ├─► had_ifu_ir / had_ifu_ir_vld (注入请求)
   OTC trace, PCFIFO, PIPEFIFO                                ├─► had_idu_wbbr_data/vld (WBBR source0 输入)
   debug-info ct_had_dbg_info                                 └─► had_yy_xx_exit_dbg / had_ifu_pcload (恢复)
        │
        ▼
   x_regs_serial_data[63:0] → 经 ir → serial → tdo 移出给调试器
```

### 4.3 与 CPU 各单元的接口

HAD 私有侧从各单元收集状态、向各单元发出控制：
- **RTU**：发出各类 `had_rtu_*_dbgreq` 停核请求；收 `rtu_yy_xx_dbgon`（已进 debug）、`rtu_yy_xx_retire0_normal`（正常退休一条）等。
- **IFU**：`had_ifu_ir`（注入的指令）、`had_ifu_ir_vld`、`had_ifu_pc`、`had_ifu_pcload`。
- **IDU**：HAD→IDU 的 `had_idu_wbbr_data/vld` 用于覆盖 pipe0 source0；IDU→HAD 的 `idu_had_wb_data/vld` 用于捕获 writeback。
- **CP0**：`cp0_yy_priv_mode`（特权级，断点条件用）、`cp0_had_cpuid_0`（构造 ID）。
- **IFU/LSU**：分别做指令 PC 和数据访问地址断点比较；MMU enable 还影响 PC/基址的符号扩展解释。

---

## 5. 多核 halt-all 与交叉触发

当前顶层实例化 core0/core1 两套私有 HAD。core 字段虽有 2 位，ETM也保留四核 OR 表达式，但 core2/3 的请求、ack、读回和时钟使能均为常量或不存在端口。这只能称为“四槽编码/扩展骨架”，不能断言已经实现或验证四核调试。

实现机制在 **ETM 交叉触发**（`ct_had_etm.v` + `ct_had_etm_if.v` + `ct_had_event.v`）：

1. 每个核的 `ct_had_event` 在进入/退出 debug 时，产生 `x_enter_dbg_req_o` / `x_exit_dbg_req_o`。
2. `ct_had_etm` 当前有效行为是 core0/core1 互相转发；四个 tee 值固定为 0，动态安全域门控未启用。
3. 目标核输入在 `forever_coreclk` 打两拍，再受本核 enter-IE 门控并锁存到 dbgon。发送端使用 OE，接收端使用 IE；不是同一侧同时检查 IE/OE。

ETM 以 raw/寄存 event 申请 `event_clk`。逻辑意图是事件驱动门控；默认行为级 `gated_clk_cell` 可能直通，不能从 `local_en` 单独保证物理时钟不翻转或“零开销”。

簇级快照由 core0/core1 ack 的 OR 上升沿触发；core2/3 ack 固定为 0。若两个 ack 重叠使 OR 不产生第二个上升沿，只捕获一次。

详见 `04_had_trace.md`。

---

## 6. HACR 寻址模型（bank/index/core）

HACR 是源码保存的 16 位命令/选择字。Shift-IR 只移动串行数据，进入 Update-IR 且跨到 CPU 域后才更新 HACR；之后按目标宽度进行 Capture/Shift-DR，写方向再经 Update-DR 形成目标核写使能。

16 位 HACR 字段（`ct_had_ir.v:195`, `:237-240`, `ct_had_private_ir.v:257-269`）：

| 位 | 名称 | 含义 |
|----|------|------|
| `[15]` | rw | 1=读，0=写（`ir_sm_hacr_rw`，`ct_had_ir.v:195`）|
| `[14]` | go | 注入指令并执行（`ir_xx_go`，`ct_had_private_ir.v:258`）|
| `[13]` | ex | 退出 debug（与 go 配合，`ir_xx_ex`，`ct_had_private_ir.v:259`）|
| `[12:8]` | index | 寄存器索引（bank 内编号）|
| `[7]` | reserved | 当前译码不用；`ct_had_sm` 中称 HACR[7] 为 rw 的注释已过时，实际 rw 是 bit15 |
| `[6:4]` | bank | bank 选择（0/1/2/3）|
| `[3:2]` | reserved | 当前寄存器选择/core 比较逻辑不使用 |
| `[1:0]` | core | 核选择（与 `biu_had_coreid` 比较）|

复位值 `16'h8200`（`ct_had_ir.v:181`, `ct_had_private_ir.v:229`）：bit15=1（读），bank0、index=2（HAD_ID）——上电默认指向只读的 ID 寄存器，调试器一连上就能读到版本。

bank/index → 寄存器的映射（部分，`ct_had_private_ir.v:237-304`）：
- bank0：ID(2)、OTC(3)、MBCA(4)、MBCB(5)、PCFIFO(6)、BABA(7)、BABB(8)、BAMA(9)、BAMB(10)、HCR(13)、HSR(14)、WBBR(17)、PC(19)、IR(20)、CSR(21)、DADDR(24)、DDATA(25)
- bank1：物理译码有 MBIR(27)，但 HAD_ID.BANK1=0，属于能力位与残留路径不一致点
- bank2：EVENT_OE(2)、EVENT_IE(3)、DBGFIFO(4)、PIPEFIFO(5)、PIPESEL(6)
- bank3（共用）：DBGFIFO2(0)、RSR(1)、DMS(2)

详见 `01_had_jtag.md`。

---

## 7. 关键设计决策汇总

| 决策 | 内容 | 出处 | 为什么 |
|------|------|------|--------|
| 注入式状态交换 | 注入指令 + WBBR/PC/IR/CSR 复用执行数据通路 | `ct_had_regs.v:542-613`、IDU source/writeback 接口 | 可减少专用访问路径；可达状态范围仍受注入/回写能力限制 |
| TAP 6 位自定义编码 | 16 个状态不是整体 one-hot；仅 UPDATE_IR/DR 各占独立 bit4/bit5 | `ct_had_sm.v:101-118,225-227` | 便于直接把 Update 状态电平送同步器 |
| HACR 16 位、bank/index/core | 一个 IR 编码"寄存器地址+操作+核" | `ct_had_ir.v:237-286` | 用极窄的 IR 覆盖大量调试寄存器与多核 |
| 复位 HACR 指向 ID | `16'h8200` | `ct_had_ir.v:181` | 上电即可读版本，握手简单 |
| DDC 固定连续 store | FSM 合成 `addi/addi/sd`，地址 +8；没有 load/readback 状态 | `ct_had_ddc_ctrl.v:78-199`、`ct_had_ddc_dp.v:76-110` | 固化调试写入序列；吞吐收益需协议实测 |
| 2 个硬件断点 + N 次计数 | BABA/BAMA + BABB/BAMB，8 位 MBC 计数器 | `id_reg[15:12]=2` `ct_had_regs.v:419`; `ct_had_bkpt.v:272-287` | 支持"第 N 次命中才停"，常用于循环调试 |
| non-IRV 路径 | 退休元数据直接锁存请求，绕过 BC/MBC/SQC/FDB | `ct_had_nirv_bkpt.v`、`ct_had_ctrl.v:510` | 仍会被 flush 清除，并受 RTU 接受/debug-disable 约束 |
| PC-FIFO 深度 16，可多写 | 每周期最多 3 条改流指令入队，溢出丢最旧 | `ct_had_pcfifo.v:101`(DEPTH=16), `:162-178` | 3-wide 退休需要多端口入队 |
| 双核 event 交叉触发 | core0/core1 可互发 enter/exit；core2/3/动态 tee 未接入 | `ct_had_etm.v:126-190` | 是否“一停都停”取决于双方 OE/IE 配置 |
| 时钟门控请求 | 多处 `gated_clk_cell + local_en`；HAD 顶层 sticky 只在 PM=11 reset-on 清 | `ct_had_ctrl.v:693-704` 等 | 物理门控/功耗效果依赖所选 ICG 宏 |
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

## 本章小结

综合当前有效 RTL，HAD 应理解为一套跨越 JTAG 接入、调试请求仲裁、停核确认、
指令注入、断点、事件触发和诊断快照的协同系统，而不是一个收到 `go` 后立即停核
的单一状态机。JTAG/HACR 负责表达控制意图，私有 HAD 将请求送往 RTU，只有
RTU 在可接受的精确边界返回确认后，核心才真正进入调试状态；随后 DDC、WBBR
和指令注入通路才能交换数据或执行调试指令。当前实例边界是双核，DDC 只实现
连续 64 位 store，non-IRV 请求仍会被 flush 清除，FFY 只控制 WBBR 对 source0
的覆盖，而 DBGFIFO 类读窗保存的是一次宽快照而非完整架构状态历史。各级
`local_en` 只表示逻辑提出门控时钟请求，实际物理时钟行为仍由门控单元及全局、
模块和扫描使能共同决定。沿着这条完整生命周期阅读，才能把“提出请求”“RTU
接受”“进入 debug”“执行注入”和“退出恢复”区分为不同事件。
