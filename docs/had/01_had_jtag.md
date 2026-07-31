# C910 HAD JTAG/IR 模块详细教学文档

> RTL 源文件：
> - `C910_RTL_FACTORY/gen_rtl/had/rtl/ct_had_sm.v`（353 行，TAP 状态机）
> - `C910_RTL_FACTORY/gen_rtl/had/rtl/ct_had_ir.v`（313 行，共用侧 16 位 HACR 译码）
> - `C910_RTL_FACTORY/gen_rtl/had/rtl/ct_had_private_ir.v`（354 行，私有侧 HACR 副本）
> - `C910_RTL_FACTORY/gen_rtl/had/rtl/ct_had_io.v`（79 行，JTAG 引脚 IO）
> - `C910_RTL_FACTORY/gen_rtl/had/rtl/ct_had_serial.v`（226 行，串行移位）
> - `C910_RTL_FACTORY/gen_rtl/had/rtl/ct_had_sync_3flop.v`（95 行，跨时钟域同步）
>
> 前置阅读：`00_had_overview.md` §2（停核/注入/窥探/恢复）、§6（HACR 寻址模型）

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键寄存器](#3-参数与关键寄存器)
4. [TAP 状态机（ct_had_sm）](#4-tap-状态机ct_had_sm)
5. [JTAG 物理 IO（ct_had_io）](#5-jtag-物理-ioct_had_io)
6. [串行移位（ct_had_serial）](#6-串行移位ct_had_serial)
7. [16 位 HACR 译码（ct_had_ir）](#7-16-位-hacr-译码ct_had_ir)
8. [私有侧 HACR 与 core 选择（ct_had_private_ir）](#8-私有侧-hacr-与-core-选择ct_had_private_ir)
9. [跨时钟域同步（ct_had_sync_3flop）](#9-跨时钟域同步ct_had_sync_3flop)
10. [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 这一层做什么

JTAG/IR 层是 HAD 的“接入层”，负责把调试器在 `TMS/TDI/TCLK` 上给出的串行事务，转换为 HACR 选择、调试寄存器串行读写以及后续的 CPU 时钟域动作。这里必须区分“串行数据已经移入”“HACR 已在 CPU 域更新”和“目标寄存器已经执行动作”三个时刻：

```
调试器驱动 TMS   →  TAP 状态机进入 Shift-IR / Shift-DR / Update 等状态
Shift-IR         →  16 位命令先进入 serial_shifter[15:0]
Update-IR        →  Update-IR 电平跨域，在 CPU 域形成脉冲并更新 HACR
HACR 译码        →  bank/index/core/rw/go/ex 共同决定目标和动作
Capture/Shift-DR →  按目标寄存器的有效宽度装入并串行移出，或串行移入待写数据
Update-DR        →  私有侧跨域、延迟并产生目标寄存器写使能
```

`ct_had_sm` 的 16 状态图和 TMS 转移关系采用 IEEE 1149.1 风格的 TAP 骨架；但本 RTL 的指令/数据路径是项目自定义协议：16 位 HACR 同时承载寄存器选择、核选择、读写与 `go/ex` 控制，TDO 也只在“读 DR”时使能。因此，可以称为 **JTAG/TAP 风格的 HAD 串行调试接口**，不能仅凭状态机相同就断言整个接口完整符合 IEEE 1149.1、支持标准 BYPASS/IDCODE 指令或可直接被任意标准 JTAG 工具识别。

### 1.2 时钟域划分

- **`tclk` 域**（JTAG 时钟）：TAP 状态机、串行移位器。
- **`cpuclk` / `forever_coreclk` 域**（CPU 时钟）：寄存器更新、指令注入。

`sm_update_ir`/`sm_update_dr` 在 `ct_had_sm` 端是 **TCLK 域的 Update 状态电平**，不是 CPU 域单拍脉冲。共用侧只对 Update-IR 实例化 `ct_had_sync_3flop`；共用侧 Update-DR 同步逻辑已被注释。每核私有侧则分别用 `sync_level2pulse` 把两个状态电平变为 `forever_coreclk` 域脉冲，再在 `cpuclk` 上寄存一拍后形成实际读写控制。因而分析波形时不能把原始 `sm_update_*`、同步后的 `x_update_*_cpu_raw` 和再延迟一拍的 `update_*_ff1` 当作同一拍事件。

---

## 2. 端口说明

### 2.1 ct_had_sm（TAP 状态机）主要端口

| 方向 | 信号 | 含义 |
|------|------|------|
| in | `pad_had_jtg_tms` | JTAG TMS，驱动状态跳转（`ct_had_sm.v:44`）|
| in | `tclk` / `trst_b` | JTAG 时钟 / 复位（`:46-47`）|
| in | `forever_cpuclk` / `cpurst_b` | CPU 自由时钟 / 复位（用于跨域，`:39,:65`）|
| in | `io_sm_tap_en` | TAP 使能（`ct_had_io.v` 中恒为 1，`:41`）|
| in | `ir_sm_hacr_rw` | 当前 HACR 的读写位，决定 TDO 使能（`:42`）|
| out | `sm_serial_shift_ir/dr` `sm_serial_capture_dr` | 给 serial 的移位/捕获控制（`:51-53`）|
| out | `sm_update_ir` / `sm_update_dr` | TCLK 域 Update-IR/DR **状态电平**；各状态通常持续一个 TCLK 周期，但它们尚不是 CPU 域脉冲（`:54-55,260-261`）|
| out | `sm_ir_update_hacr` | Update-IR 经共用侧同步后得到的 `forever_cpuclk` 域单拍脉冲（`:50,263-296`）|
| out | `sm_xx_write_en` | DR 写使能（`:56`）|
| out | `sm_io_tdo_en` | TDO 输出使能（`:49`）|

### 2.2 ct_had_io（引脚）端口

| 方向 | 信号 | 含义 |
|------|------|------|
| in | `pad_had_jtg_tdi` | JTAG TDI（`ct_had_io.v:28`）|
| in | `serial_io_tdo` | serial 移出的数据（`:29`）|
| in | `sm_io_tdo_en` | TDO 使能（`:30`）|
| out | `had_pad_jtg_tdo` / `had_pad_jtg_tdo_en` | JTAG TDO 引脚及其使能（`:31-32`）|
| out | `io_serial_tdi` | 送给 serial 的 TDI（`:33`）|
| out | `io_sm_tap_en` | TAP 使能（恒 1，`:34`）|

### 2.3 ct_had_serial（串行移位）端口

| 方向 | 信号 | 含义 |
|------|------|------|
| in | `io_serial_tdi` | 串行输入（`ct_had_serial.v:47`）|
| in | `ir_xx_*_reg_sel`（多个）| 选中的寄存器，决定移位宽度（`:48-63`）|
| in | `regs_serial_data[63:0]` | capture-DR 时并行装入的寄存器读值（`:64`）|
| in | `sm_serial_shift_ir/dr` `sm_serial_capture_dr` | 来自 TAP 的控制（`:65-67`）|
| in | `sm_xx_write_en` | 由 HACR bit15 取反得到的“当前事务为写”电平；这里只用于判定读移位时的 parity/TDO 行为（`:68,190-211`）|
| out | `serial_io_tdo` | 串行输出（`:71`）|
| out | `serial_xx_data[63:0]` | 移入的数据，送 ir/各寄存器（`:72`）|

### 2.4 ct_had_ir（共用侧 HACR）端口分组

| 组 | 信号 | 含义 |
|----|------|------|
| 输入数据 | `serial_xx_data[63:0]` | 移入的 HACR/写数据（`ct_had_ir.v:62`）|
| 输入读回 | `common_regs_data`、`core0/1_regs_serial_data[63:0]` | 各源的读数据（`:56-58`）|
| 输入掩码 | `sysio_had_dbg_mask[3:0]` | 每核调试禁用掩码（`:64`）|
| 输入控制 | `sm_ir_update_hacr` | HACR 更新使能（`:63`）|
| 输出选通 | `ir_xx_*_reg_sel`（约 20 个）| 选中寄存器（`:67-89`）|
| 输出核选 | `ir_xx_core0/1/2/3_sel` | 核选择（`:71-74`）|
| 输出数据 | `ir_corex_wdata[63:0]` | 广播给各核的写数据（`:65`）|
| 输出读回 | `regs_serial_data[63:0]` | 汇总给 serial 的读数据（`:90`）|
| 输出 rw | `ir_sm_hacr_rw` | HACR 读写位（`:66`）|

### 2.5 ct_had_private_ir（私有侧 HACR）端口分组

| 组 | 信号 | 含义 |
|----|------|------|
| 输入 | `ir_corex_wdata[63:0]` | 来自共用侧的广播数据（`ct_had_private_ir.v:66`）|
| 输入核 ID | `biu_had_coreid[1:0]` | 本核 ID，用于 core_sel（`:61`）|
| 输入控制 | `sm_update_dr` / `sm_update_ir` | 来自 TAP 的 TCLK 域 Update 状态电平，进入本模块后才同步成 coreclk 域脉冲（`:67-68,173-207`）|
| 输入禁用 | `ctrl_xx_dbg_disable` | 本核调试被禁用时屏蔽（`:64`）|
| 输出选通 | `ir_xx_*_reg_sel`（约 25 个）| 本核选中寄存器（`:71-93`）|
| 输出 go/ex | `x_ir_xx_go` / `x_ir_xx_ex` | 注入执行/退出（已 & core_sel，`:98-99`）|
| 输出 DR 写 | `x_sm_xx_update_dr_en` | Update-DR 同步脉冲经 `cpuclk` 再寄存一拍后，与写方向和 `core_sel` 相与所得的目标核写使能（`:100,209-219,326`）|
| 输出 FIFO 读 | `x_ir_ctrl_*fifo_read_pulse` | 三个 FIFO 读脉冲（`:95-97`）|
| 输出 clk_en | `ir_ctrl_had_clk_en` | HAD 时钟使能（`:70`）|
| 输出退出 | `ir_ctrl_exit_dbg_reg` | 选中"退出类"寄存器（`:69`）|

---

## 3. 参数与关键寄存器

| 寄存器/参数 | 宽度/值 | 文件:行 | 说明 |
|-------------|---------|---------|------|
| `tap5_cur_st` / `tap5_nxt_st` | `[5:0]` | `ct_had_sm.v:59-60` | TAP 现态/次态，6 位编码 |
| `hacr_reg`（共用）| `[15:0]`，复位 `16'h8200` | `ct_had_ir.v:93,181` | 共用侧 HACR |
| `hacr_f`（私有）| `[15:0]`，复位 `16'h8200` | `ct_had_private_ir.v:103,229` | 每核 HACR 副本 |
| `serial_shifter` | `[63:0]` | `ct_had_serial.v:76` | 64 位串行移位器 |
| `parity` | 1 位、无显式复位 | `ct_had_serial.v:75,190-198` | 读 DR 时内部累积奇偶；当前 RTL 未将它接到输出或写回路径 |
| `hacr_index` | `[4:0]` = `hacr[12:8]` | `ct_had_ir.v:240`、`ct_had_private_ir.v:269` | 寄存器索引 |

**复位值 `16'h8200` 的含义**：bit15=1（读）、bank=0（`[6:4]=0`）、index=2（`[12:8]=2`=ID_NUM）、core=0。即上电默认指向只读 HAD_ID。注释明写 "Async reset to point to HAD_ID"（`ct_had_ir.v:181`）。

---

## 4. TAP 状态机（ct_had_sm）

### 4.1 状态编码（is what）

`ct_had_sm.v:101-118` 定义了 16 个标准 TAP 状态，用 6 位编码：

```
TAP5_RESET          = 6'b000000   TAP5_IDLE           = 6'b000001
TAP5_SELECT_DR_SCAN = 6'b000011   TAP5_SELECT_IR_SCAN = 6'b000010
TAP5_CAPTURE_IR     = 6'b000110   TAP5_SHIFT_IR       = 6'b000100
TAP5_EXIT1_IR       = 6'b000101   TAP5_UPDATE_IR      = 6'b010000
TAP5_CAPTURE_DR     = 6'b001011   TAP5_SHIFT_DR       = 6'b001010
TAP5_EXIT1_DR       = 6'b001000   TAP5_UPDATE_DR      = 6'b100000
TAP5_PAUSE_IR       = 6'b001101   TAP5_EXIT2_IR       = 6'b001111
TAP5_PAUSE_DR       = 6'b001100   TAP5_EXIT2_DR       = 6'b001110
```

**为什么 UPDATE_IR/UPDATE_DR 用单独 1 位**（bit4=`010000`、bit5=`100000`）？注释直接说明（`ct_had_sm.v:108-109,113-114`）："UPDATE_IR change to 1 bit reg to sync."。即把 Update 状态映射到独立的一个位，便于直接用该位做跨时钟域同步信号，无需额外译码：
- `sm5_update_ir = tap5_cur_st[4]`（`:225`）
- `sm5_update_dr = tap5_cur_st[5]`（`:227`）

### 4.2 状态转移（how）

现态寄存器在 `tclk` 上升沿更新，并由 `trst_b` 异步复位到 RESET（`ct_had_sm.v:120-127`）。次态由 `tms_i` 驱动，16 个状态的转移拓扑与经典 IEEE 1149.1 TAP 图一致（`:130-219`）。这句话只描述**状态拓扑**，不等于证明整个 HAD 串行协议符合 IEEE 1149.1。RESET 态只有在 `io_sm_tap_en && !tms_i` 时进入 IDLE；当前 `ct_had_io` 将 `io_sm_tap_en` 固定为 1，所以实际条件退化为 `TMS=0`。

### 4.3 三类输出

1. **送 serial 的移位/捕获信号**（同在 `tclk` 域，无需同步，注释 `:249-250`）：
   - `sm_serial_shift_ir = sm5_shift_ir`（`:251`）
   - `sm_serial_shift_dr = sm5_shift_dr`（`:252`）
   - `sm_serial_capture_dr = sm5_capture_dr`（`:253`）

2. **TDO 输出使能**：在 `tclk` 下降沿，当 `sm5_shift_dr && ir_sm_hacr_rw`（即正在 shift-DR 且是读操作）时拉高 `tdo_en`（`:233-243`）。

3. **跨到 CPU 域的 Update 信号**：
   - `sm_update_ir = sm5_update_ir`、`sm_update_dr = sm5_update_dr` 都只是直接导出的 TCLK 域状态电平（`:260-261`）。
   - 共用侧仅实例化 Update-IR 同步器，得到 `sm_update_ir_cpu` 并直接输出为 `sm_ir_update_hacr`（`:263-296`）。
   - 源码中共用侧 Update-DR 同步实例被注释（`:281-288`）；Update-DR 由每核 `ct_had_private_ir` 自行同步。

所以“Update 信号已经导出”不等于“CPU 域已经接受”，更不等于“目标寄存器写入完成”。

### 4.4 DR 写使能与读出特例

`sm_xx_write_en = !ir_sm_hacr_rw`（`ct_had_sm.v:319`），而 `ir_sm_hacr_rw` 实际来自 `hacr_reg[15]`（`ct_had_ir.v`）。`ct_had_sm.v:314` 写着 “HACR[7]”，但这与现有译码 RTL 不一致，是遗留注释；文档和调试脚本应以 **bit15：1=读、0=写** 为准。该段注释真正表达的设计意图是：读写方向只由 HACR 的 `rw` 字段决定，不再叠加旧 JTAG 接口类型，否则会破坏 PCFIFO 的读出流程。

### 4.5 时钟门控

`sm_clk_en = sm_update_ir_cpu ^ update_ir_cpu_ff1`（`:323`）是同步脉冲及其寄存值的异或。对于正常单拍 `sm_update_ir_cpu`，它会在脉冲拉高和随后拉低的两个相邻阶段都请求 `sm_clk`，使 `update_ir_cpu_ff1` 能先置 1、再清 0；不能简单写成“只开一拍”。此外，仓库默认 `gated_clk_cell` 的行为级分支可能把 `clk_out` 直接接到 `clk_in`，真实物理门控效果取决于所选工艺宏/编译配置，RTL 逻辑上的 `local_en` 不能直接等同于综合后的时钟功耗节省。

DBGFIFO2 读：`dbgfifo2_read_ren = (ir_sm_hacr_rw && ir_xx_dbgfifo2_reg_sel) && sm_ir_update_hacr_ff1`（`:343-344`）。这里使用的是已延迟的 Update-IR 事件和新 HACR 的译码，语义是“选中 DBGFIFO2 的读事务在 Update-IR 后触发一次读取”，不是等待 Shift-DR 完成后才推进。

---

## 5. JTAG 物理 IO（ct_had_io）

`ct_had_io.v` 极简，就是引脚到内部的直连（`:67-71`）：

```verilog
assign io_serial_tdi    = pad_had_jtg_tdi;   // TDI → serial
assign had_pad_jtg_tdo  = serial_io_tdo;     // serial → TDO 引脚
assign had_pad_jtg_tdo_en = sm_io_tdo_en;    // TDO 使能
assign io_sm_tap_en     = 1'b1;              // TAP 恒使能
```

文件头部的 ASCII 框图保留了 JTAG_2/JTAG_5 的历史接口说明；但当前有效逻辑只有四个连续赋值，没有运行时接口选择器。本配置中 `io_sm_tap_en` 恒为 1，表示状态机不再由该信号关闭；这不代表所有调试动作都无条件有效，后续仍受 HACR 核选择、外部 debug mask 和每核 debug-disable 路径约束。

---

## 6. 串行移位（ct_had_serial）

### 6.1 按选中寄存器决定移位宽度（is what + why）

不同调试寄存器宽度不同，移位时必须选择对应的有效位数。`ct_had_serial.v:123-148` 按 `ir_xx_*_reg_sel` 把寄存器分成 4 类宽度：

| 宽度 | 选择条件 | 行 | 代表寄存器 |
|------|----------|----|-----------|
| 8 位 | `serial_shifter_8_sel` | `:123-128` | OTC、MBCA、MBCB、BAMA、BAMB |
| 16 位 | `serial_shifter_16_sel` | `:130-131` | CSR |
| 64 位 | `serial_shifter_64_sel` | `:138-148` | PIPEFIFO、BABA、BABB、WBBR、PC、PCFIFO、DADDR、DBGFIFO、DBGFIFO2、DDATA |
| 32 位 | `serial_shifter_32_sel`（其余）| `:133-136` | 缺省（如 HCR/HSR/ID）|

不同宽度的移位实现见 `:150-154`。以 8 位为例：

```verilog
{56'b0, tdi, serial_shifter[7:1]}
```

每拍原 bit0 被移出到 TDO 方向，原 bit7:1 下移到 bit6:0，新 TDI 放入 bit7。因此准确表述是：**最低有效位先移出，TDI 从所选宽度的最高有效位移入**。源码注释 “data shift from the lowest bit” 描述的是移出顺序，不是说 TDI 写入 bit0。若主机希望写入数值 `D[W-1:0]`，通常应按 `D[0]、D[1]…` 的顺序在 TDI 上发送，经过 W 拍后内部位序才恢复为 `D[W-1:0]`。

### 6.2 三种移位/捕获行为

`ct_had_serial.v:156-175` 的组合块按 TAP 状态选择移位器下一值：
- `shift_ir`：只移低 16 位 `{tdi, serial_shifter[15:1]}`（HACR 是 16 位）（`:166-167`）。
- `capture_dr`：把 `regs_serial_data[63:0]` 并行装入移位器（把寄存器读值准备好移出）（`:168-169`）。
- `shift_dr`：按宽度移位（`:170-171`）。

移位器在 `tclk` 上升沿采样（`:179-182`），且该寄存器没有显式复位；在第一次有效 Shift/Capture 前其仿真值可能未知。`serial_xx_data = serial_shifter`（`:185`）只是当前 64 位移位寄存器的并行观察值，真正使用多少位由目标寄存器决定。

### 6.3 奇偶与 TDO

- **内部奇偶累积**（`:190-198`）：Capture-DR 时置 1，读方向 Shift-DR 时逐位异或当前 bit0。该 `parity` 没有显式复位，也没有连到模块端口、TDO 或寄存器回读，因此当前 RTL 只能证明“内部计算了 parity”，不能说调试器收到了校验位或协议完成了奇偶校验。
- **TDO 数据寄存器**（`:204-212`）：`trst_b` 复位时置 1；仅在 `sm_serial_shift_dr && !sm_xx_write_en` 的 TCLK 下降沿采样 `serial_shifter[0]`，其余时间保持原值，不是每次进入 IDLE 都重新置 1。
- **TDO 引脚使能**：还需同时观察 `sm_io_tdo_en`。只有 Shift-DR 且 HACR 为读方向时外部 TDO 才被声明有效；RTL没有实现 Shift-IR 的 TDO 读出。

---

## 7. 16 位 HACR 译码（ct_had_ir）

### 7.1 HACR 更新

`ct_had_ir.v:178-186`：在 `ir_clk` 上升沿，当 `sm_ir_update_hacr` 有效时把 `serial_xx_data[15:0]` 写进 `hacr_reg`；复位指向 `16'h8200`。`ir_clk` 由 `gated_clk_cell` 在 `sm_ir_update_hacr` 使能下产生（`:157-165`），平时不翻转。

### 7.2 字段拆解

```verilog
ir_sm_hacr_rw  = hacr_reg[15];        // 读/写         (:195)
bank0_sel      = hacr_reg[6:4] == 0;  // bank 选择     (:237)
bank2_sel      = hacr_reg[6:4] == 2;  //               (:238)
bank3_sel      = hacr_reg[6:4] == 3;  //               (:239)
hacr_index     = hacr_reg[12:8];      // 寄存器索引    (:240)
ir_core0_sel   = hacr_reg[1:0]==00;   // 核选择        (:210-213)
```

### 7.3 寄存器选通参数表（共用侧，`ct_had_ir.v:242-286`）

bank0（`:242-272`）：ID=2、OTC=3、MBCA=4、MBCB=5、PCFIFO=6、BABA=7、BABB=8、BAMA=9、BAMB=10、WBBR=17、PC=19、CSR=21、DADDR=24、DDATA=25。

bank2（`:274-278`）：DBGFIFO=4、PIPEFIFO=5。

bank3（`:280-286`）：DBGFIFO2=0、RWR(RSR)=1、DMS=2。

每个 `ir_xx_X_reg_sel = bankN_sel && (hacr_index == X_NUM)`。

### 7.4 核选择与读回汇总

`ir_core0/1/2/3_sel = (hacr_reg[1:0]==N)`，随后私有数据读选择再与 `!sysio_had_dbg_mask[N]` 相与。当前有效实现需要注意三层边界：

1. 顶层只向共用 HAD 接入 core0/core1 的私有读数据，`rdata_2/rdata_3` 在 `ct_had_ir` 内固定为 0；因此 core 字段虽保留 2 位，当前实例并不是四核私有调试实现。
2. `sysio_had_dbg_mask` 只门控 `regs_core_serial_data` 的私有核读回。`bank3` 和 ID 走 `common_regs_data` 时，`ir_common_sel` 使用未加 mask 的 `ir_coreN_sel`；所以不能笼统说“mask 后所有调试读都返回 0”。
3. `core0_dbg_disable` 到 `core3_dbg_disable` 在本模块内均固定为 0。真正的每核动作禁用主要落在私有侧 `ctrl_xx_dbg_disable` 和其它控制路径，不能把这个占位信号当成当前有效安全门控。

---

## 8. 私有侧 HACR 与 core 选择（ct_had_private_ir）

### 8.1 为什么每核要有一份 HACR 副本

共用侧把 `ir_corex_wdata` 广播到每个已实例化私有 HAD。每个私有侧 `ct_had_private_ir` 都会在本地 Update-IR 脉冲到来时更新自己的 `hacr_f`；并不是只有目标核才保存 HACR。真正把有副作用动作限制到目标核的是后续 `core_sel`：

```verilog
core_sel   = (hacr_f[1:0] == biu_had_coreid[1:0]);  // (:262)
x_ir_xx_ex = ir_xx_ex && core_sel;                  // (:263)
x_ir_xx_go = ir_xx_go && core_sel;                  // (:264)
```

`biu_had_coreid` 是本实例看到的核 ID。`x_ir_xx_go`、`x_ir_xx_ex`、`x_sm_xx_update_dr_en` 和 FIFO 读脉冲都带 `core_sel`；而部分纯译码信号 `ir_xx_*_reg_sel` 本身并不带 `core_sel`，使用方必须结合相应动作使能理解，不能看到某个 `reg_sel=1` 就断言该核已经执行读写。

### 8.2 go/ex 位

`hacr_f[14]=go`（注入并执行）、`hacr_f[13]=ex`（退出 debug）（`ct_had_private_ir.v:258-259`）。它们与 `core_sel` 相与后送 ctrl FSM 作为"注入指令执行/退出 debug"的触发（见 `03_had_ctrl_ddc.md`）。

### 8.3 跨域 Update 与 dbg_disable 门控

私有侧用 `sync_level2pulse` 把 `sm_update_ir`/`sm_update_dr` 同步到本核 `forever_coreclk` 域（`:174-198`），再与 `!ctrl_xx_dbg_disable` 相与（`:188,:206`）。准确边界是：禁用信号屏蔽了 `x_update_*_cpu`，从而阻止 HACR 更新、DR 写脉冲和后续动作；但同步器内部的 `x_update_*_cpu_raw` 仍可能产生，`ir_ctrl_had_clk_en` 也直接使用 raw 信号。当前 RTL 中 TEE 专用禁用输入还存在固定值路径，安全语义应结合顶层连线审查，不能仅凭模块名断言完整 TEE 策略。

`x_sm_xx_update_dr_en = update_dr_ff1 & !hacr_rw & core_sel`（`:326`）。其中 `update_dr_ff1` 是同步脉冲在 `cpuclk` 上再寄存一拍后的值；`hacr_rw` 来自此前已经保存的本地 HACR。它是各私有寄存器写入常用的统一使能，但是否真正改变某个寄存器，还需同时满足该寄存器的 `ir_xx_*_reg_sel` 及其本地写条件。

### 8.4 私有侧寄存器选通参数表（`ct_had_private_ir.v:237-304`）

比共用侧多了：HCR=13、HSR=14、IR=20、BYPASS=12（bank0）；MBIR=27（bank1）；EVENT_OE=2、EVENT_IE=3、PIPESEL=6（bank2）。这些是每核私有的控制/状态寄存器。

### 8.5 FIFO 读脉冲与退出寄存器

```verilog
x_ir_ctrl_pcfifo_read_pulse   = pcfifo_read   && update_hacr_ff1 && core_sel;  // (:321)
x_ir_ctrl_pipefifo_read_pulse = pipefifo_read && update_hacr_ff1 && core_sel;  // (:322)
x_ir_ctrl_dbgfifo_read_pulse  = dbgfifo_read  && update_hacr_ff1 && core_sel;  // (:323)
```

每次用“读方向 HACR”选中 FIFO 类寄存器并完成 Update-IR 后，`update_hacr_ff1` 在下一拍配合新 HACR 译码产生读取脉冲。这个脉冲与后续 Shift-DR 是否完整移出数据没有完成握手；调试器必须遵守先选择/触发、再 Capture/Shift 的协议顺序。

`ir_ctrl_exit_dbg_reg`（`:328-332`）：选中 WBBR/PC/IR/CSR/BYPASS 任一即为"退出类"寄存器，配合 go+ex 触发退出 debug。

---

## 9. 跨时钟域同步（ct_had_sync_3flop）

### 9.1 慢→快单脉冲同步器（is what + how）

`ct_had_sync_3flop.v` 针对源码注明的“慢 `clk2` 到快 `clk1`”场景，把源域电平的上升沿转换成目标域单拍脉冲。结构（`:50-89`）：

1. clk2 域先打一拍 `sync_ff_clk2`（`:58-64`）；
2. clk1 域连打三拍 `sync_ff1/2/3_clk1`（`:66-78`）做亚稳态收敛；
3. 再打一拍 `sync_ff4_clk1`（`:81-87`）；
4. `sync_out = !sync_ff4_clk1 && sync_ff3_clk1`（`:89`）——上升沿检测，产生单脉冲。

注释明确约束方向 `"slow clock --> fast clock"`。该结构没有请求保持/返回确认协议；其可靠性依赖源 Update 电平足够宽、能够被目标时钟采到，以及慢到快的使用假设。它不是适用于任意异步窄脉冲的通用无损同步器。

### 9.2 与 sync_level2pulse 的分工

- `ct_had_sm` 只对共用侧 Update-IR 使用 `ct_had_sync_3flop`。
- `ct_had_private_ir` 对 Update-IR/DR 各使用一个 `sync_level2pulse`，然后用 `cpuclk` 再寄存一拍。

`sync_level2pulse` 端口虽名为 `sync_ack`，但在此处两个 ack 仅成为未使用的本地线，没有返回到 `ct_had_sm` 或 TCLK 源端。因此当前集成只能称为“电平同步加边沿检测”，不能称为端到端请求/确认握手，也不能据此承诺所有任意宽度脉冲都不会丢失。

## 本章小结

HAD 的 JTAG/IR 接入层把串行调试事务转换为 CPU 时钟域可消费的寄存器选择和更新事件。TAP 使用 6 位状态编码，并为 `UPDATE_IR` 和 `UPDATE_DR` 保留可直接译码的状态位；复位后的 16 位 HACR 为 `16'h8200`，因此初始选择指向 ID 寄存器。随后，HACR 用 `rw/core/bank/index/go/ex` 描述读写方向、目标核心、寄存器组、寄存器编号和控制动作。共用侧向所有已实例化的私有 HAD 广播 HACR，每个私有侧保存自己的副本，再用 HACR 中的 core 字段与本核 ID 比较，决定更新是否具有本核副作用；当前顶层只有 core0 和 core1 两套私有 HAD，所以 2 位 core 编码不能单独证明四核调试逻辑已经实现。

TAP 的 capture、shift 和 update 只完成串行协议阶段划分，真正的本地寄存器更新还要经过跨时钟域同步和边沿检测。共用侧同步 Update-IR，私有侧分别同步 Update-IR 和 Update-DR；这些路径没有返回到 TCLK 源端的端到端确认，因此可靠性依赖慢到快同步假设和源电平宽度，不能按无损异步事件队列理解。数据移位遵循最低有效位先输出、TDI 从当前选择宽度最高位移入的规则，访问 8、16、32 或 64 位寄存器时必须使用匹配的移位长度。有效读写方向由 HACR[15] 决定，源码中的 HACR[7] 和 JTAG_2 等历史注释不参与当前译码；`go/ex` 也只是发起控制请求，不能越过 RTU 的停核确认直接改变处理器执行状态。Update 活动还会提出局部时钟门控请求，但最终物理门控效果取决于 `gated_clk_cell` 的实现。从串行命令到进入 debug、注入指令和退出恢复的后半段链路由 `03_had_ctrl_ddc.md` 继续说明。
