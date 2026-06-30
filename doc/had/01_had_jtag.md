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
10. [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

### 1.1 这一层做什么

JTAG/IR 层是 HAD 的"接入层"，负责把调试器的引脚电平变成"对某个调试寄存器的读/写"。流程：

```
调试器拨动 TMS  →  TAP 状态机走到 Shift-IR / Shift-DR / Update 等状态
Shift-IR 阶段   →  serial 把 16 位移进 HACR
ir 译码         →  HACR → bank/index/core → 选中某个寄存器（ir_xx_*_reg_sel）
Shift-DR 阶段   →  serial 按选中寄存器宽度把数据移入/移出
Update 阶段     →  把移入的值真正写进寄存器
```

整个过程就是 IEEE 1149.1 的标准 TAP 流程，但 IR 不是标准的 BYPASS/IDCODE，而是玄铁自定义的 16 位 HACR。

### 1.2 时钟域划分

- **`tclk` 域**（JTAG 时钟）：TAP 状态机、串行移位器。
- **`cpuclk` / `forever_coreclk` 域**（CPU 时钟）：寄存器更新、指令注入。

`Update-IR`/`Update-DR` 这两个事件需要跨域送进 CPU 域去真正写寄存器，因此用专门的同步器（`ct_had_sync_3flop`、`sync_level2pulse`）。这是本层最容易出错的地方，也是 RTL 注释反复强调的地方（`ct_had_sm.v:255-261`）。

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
| out | `sm_update_ir` / `sm_update_dr` | Update 脉冲（`:54-55`）|
| out | `sm_ir_update_hacr` | 跨到 CPU 域的 HACR 更新使能（`:50`）|
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
| in | `sm_xx_write_en` | 写使能（影响奇偶/TDO）（`:68`）|
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
| 输入控制 | `sm_update_dr` / `sm_update_ir` | TAP 的 Update 脉冲（`:67-68`）|
| 输入禁用 | `ctrl_xx_dbg_disable` | 本核调试被禁用时屏蔽（`:64`）|
| 输出选通 | `ir_xx_*_reg_sel`（约 25 个）| 本核选中寄存器（`:71-93`）|
| 输出 go/ex | `x_ir_xx_go` / `x_ir_xx_ex` | 注入执行/退出（已 & core_sel，`:98-99`）|
| 输出 DR 写 | `x_sm_xx_update_dr_en` | DR 写脉冲（已 & core_sel，`:100`）|
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
| `parity` | 1 位 | `ct_had_serial.v:75` | 读 DR 时算奇偶 |
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

现态/次态寄存器在 `tclk` 上升沿、`trst_b` 异步复位到 RESET（`ct_had_sm.v:120-127`）。次态由 `tms_i` 驱动，完全遵循 IEEE 1149.1 标准图（`:130-219`）。其中本设计在 RESET 态需要 `io_sm_tap_en && !tms_i` 才进入 IDLE（`:135-137`）。

### 4.3 三类输出

1. **送 serial 的移位/捕获信号**（同在 `tclk` 域，无需同步，注释 `:249-250`）：
   - `sm_serial_shift_ir = sm5_shift_ir`（`:251`）
   - `sm_serial_shift_dr = sm5_shift_dr`（`:252`）
   - `sm_serial_capture_dr = sm5_capture_dr`（`:253`）

2. **TDO 输出使能**：在 `tclk` 下降沿，当 `sm5_shift_dr && ir_sm_hacr_rw`（即正在 shift-DR 且是读操作）时拉高 `tdo_en`（`:233-243`）。

3. **跨到 CPU 域的 Update 信号**：`sm_update_ir`/`sm_update_dr` 经 `ct_had_sync_3flop` 同步成 `sm_update_ir_cpu`（`:264-271`），再产生 `sm_ir_update_hacr`（`:296`）。这是把 JTAG 域的"提交"事件安全地带进 CPU 域。

### 4.4 DR 写使能与读出特例

`sm_xx_write_en = !ir_sm_hacr_rw`（`ct_had_sm.v:319`）。注释解释了一个易踩的坑（`:313-318`）：忽略 JTAG 接口类型、只用 HACR[7]（即 rw 位）判断读/写，否则 "this will couse PCFIFO cannot be read out!"——即如果用接口类型判断会导致 PCFIFO 读不出来。

### 4.5 时钟门控

`sm_clk_en = sm_update_ir_cpu ^ update_ir_cpu_ff1`（`:323`）——只在 Update-IR 事件跨域到来的那一拍产生时钟。`gated_clk_cell x_had_sm_gated_clk`（`:326-334`）据此门控 `sm_clk`。

DBGFIFO2 读：`dbgfifo2_read_ren = (ir_sm_hacr_rw && ir_xx_dbgfifo2_reg_sel) && sm_ir_update_hacr_ff1`（`:343-344`）——读 dbgfifo2 时每次 Update-IR 产生一个推进读指针的脉冲。

---

## 5. JTAG 物理 IO（ct_had_io）

`ct_had_io.v` 极简，就是引脚到内部的直连（`:67-71`）：

```verilog
assign io_serial_tdi    = pad_had_jtg_tdi;   // TDI → serial
assign had_pad_jtg_tdo  = serial_io_tdo;     // serial → TDO 引脚
assign had_pad_jtg_tdo_en = sm_io_tdo_en;    // TDO 使能
assign io_sm_tap_en     = 1'b1;              // TAP 恒使能
```

文件头部的 ASCII 框图（`:48-66`）画出 JTAG_2 与 JTAG_5 两种接口的复用关系。本配置中 `io_sm_tap_en` 恒为 1，意味着 TAP 始终使能。

---

## 6. 串行移位（ct_had_serial）

### 6.1 按选中寄存器决定移位宽度（is what + why）

不同调试寄存器宽度不同，移位时必须按其有效宽度从低位串入，否则位会错位。`ct_had_serial.v:123-148` 按 `ir_xx_*_reg_sel` 把寄存器分成 4 类宽度：

| 宽度 | 选择条件 | 行 | 代表寄存器 |
|------|----------|----|-----------|
| 8 位 | `serial_shifter_8_sel` | `:123-128` | OTC、MBCA、MBCB、BAMA、BAMB |
| 16 位 | `serial_shifter_16_sel` | `:130-131` | CSR |
| 64 位 | `serial_shifter_64_sel` | `:138-148` | PIPEFIFO、BABA、BABB、WBBR、PC、PCFIFO、DADDR、DBGFIFO、DBGFIFO2、DDATA |
| 32 位 | `serial_shifter_32_sel`（其余）| `:133-136` | 缺省（如 HCR/HSR/ID）|

不同宽度的移位实现见 `:150-154`：8 位时 `{56'b0, tdi, serial_shifter[7:1]}`，64 位时 `{tdi, serial_shifter[63:1]}`，从最低位移入。

### 6.2 三种移位/捕获行为

`ct_had_serial.v:156-175` 的组合块按 TAP 状态选择移位器下一值：
- `shift_ir`：只移低 16 位 `{tdi, serial_shifter[15:1]}`（HACR 是 16 位）（`:166-167`）。
- `capture_dr`：把 `regs_serial_data[63:0]` 并行装入移位器（把寄存器读值准备好移出）（`:168-169`）。
- `shift_dr`：按宽度移位（`:170-171`）。

移位器在 `tclk` 上升沿采样（`:179-182`），`serial_xx_data = serial_shifter`（`:185`）。

### 6.3 奇偶与 TDO

- **奇偶**（`:190-198`）：capture-DR 时 `parity<=1`，shift-DR 读出时每移一位异或一次 `serial_shifter[0]`，给调试器做完整性校验。
- **TDO**（`:204-212`）：在 `tclk` 下降沿，读 DR 时把 `serial_shifter[0]` 送出；复位/IDLE 时 TDO=1（`:206-207`）。

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

`ir_core0/1/2/3_sel = (hacr_reg[1:0]==N)`（`:210-213`）。再与 `sysio_had_dbg_mask[N]` 取反相与得 `ir_coreN_priv_sel`（`:215-218`）——被掩码禁用的核读回 0。读回数据按选中核多路选择（`:220-223`），bank3 与 ID 走 common_regs（`:229-234`）。

---

## 8. 私有侧 HACR 与 core 选择（ct_had_private_ir）

### 8.1 为什么每核要有一份 HACR 副本

共用侧的 HACR 被所有核看到，但只有"被选中的那个核"才应真正执行注入/退出/写 DR。私有侧 `ct_had_private_ir` 维护本核的 `hacr_f`，并用 `core_sel` 把所有动作门控到本核：

```verilog
core_sel   = (hacr_f[1:0] == biu_had_coreid[1:0]);  // (:262)
x_ir_xx_ex = ir_xx_ex && core_sel;                  // (:263)
x_ir_xx_go = ir_xx_go && core_sel;                  // (:264)
```

`biu_had_coreid` 是本核的物理 ID，只有 HACR 的 core 字段等于它，本核才动作。这就是多核选择的落点。

### 8.2 go/ex 位

`hacr_f[14]=go`（注入并执行）、`hacr_f[13]=ex`（退出 debug）（`ct_had_private_ir.v:258-259`）。它们与 `core_sel` 相与后送 ctrl FSM 作为"注入指令执行/退出 debug"的触发（见 `03_had_ctrl_ddc.md`）。

### 8.3 跨域 Update 与 dbg_disable 门控

私有侧用 `sync_level2pulse` 把 `sm_update_ir`/`sm_update_dr` 同步到本核 `forever_coreclk` 域（`:174-198`），再与 `!ctrl_xx_dbg_disable` 相与（`:188,:206`）——本核调试被禁用时不响应任何更新。这是 TEE/安全控制的落点。

`x_sm_xx_update_dr_en = update_dr_ff1 & !hacr_rw & core_sel`（`:326`）——DR 写脉冲，要求是写操作且本核被选中。这是各寄存器/断点/DDC 写入的统一时钟脉冲。

### 8.4 私有侧寄存器选通参数表（`ct_had_private_ir.v:237-304`）

比共用侧多了：HCR=13、HSR=14、IR=20、BYPASS=12（bank0）；MBIR=27（bank1）；EVENT_OE=2、EVENT_IE=3、PIPESEL=6（bank2）。这些是每核私有的控制/状态寄存器。

### 8.5 FIFO 读脉冲与退出寄存器

```verilog
x_ir_ctrl_pcfifo_read_pulse   = pcfifo_read   && update_hacr_ff1 && core_sel;  // (:321)
x_ir_ctrl_pipefifo_read_pulse = pipefifo_read && update_hacr_ff1 && core_sel;  // (:322)
x_ir_ctrl_dbgfifo_read_pulse  = dbgfifo_read  && update_hacr_ff1 && core_sel;  // (:323)
```

每次对 FIFO 类寄存器做"读"操作 + Update-IR，就产生一个推进读指针的脉冲。

`ir_ctrl_exit_dbg_reg`（`:328-332`）：选中 WBBR/PC/IR/CSR/BYPASS 任一即为"退出类"寄存器，配合 go+ex 触发退出 debug。

---

## 9. 跨时钟域同步（ct_had_sync_3flop）

### 9.1 慢→快单脉冲同步器（is what + how）

`ct_had_sync_3flop.v` 把 clk2 域的一个电平变化，安全地变成 clk1 域的一个**单拍脉冲**。结构（`:50-89`）：

1. clk2 域先打一拍 `sync_ff_clk2`（`:58-64`）；
2. clk1 域连打三拍 `sync_ff1/2/3_clk1`（`:66-78`）做亚稳态收敛；
3. 再打一拍 `sync_ff4_clk1`（`:81-87`）；
4. `sync_out = !sync_ff4_clk1 && sync_ff3_clk1`（`:89`）——上升沿检测，产生单脉冲。

注释明确约束方向："slow clock --> fast clock"（`:55`）。HAD 中用它把 JTAG（慢）的 Update 事件送进 CPU（快）域。

### 9.2 与 sync_level2pulse 的分工

- `ct_had_sm` 用 `ct_had_sync_3flop`（共用侧，cpuclk）。
- `ct_had_private_ir` 用 `sync_level2pulse`（私有侧，coreclk，带 ack 握手），见 `ct_had_private_ir.v:174-207`。

两者都把"JTAG 域的提交"变成"CPU 域的单脉冲"，区别在私有侧用了 level-to-pulse 带握手，确保慢时钟脉冲被快时钟可靠捕获。

---

## 设计取舍小结

| 取舍 | 选择 | 出处 | 理由 |
|------|------|------|------|
| TAP 状态编码 | 6 位、UPDATE_IR/DR 用独立位 | `ct_had_sm.v:108-114,225,227` | Update 位可直接做跨域同步信号 |
| 读/写判断 | 只用 HACR[15] rw 位，不看接口类型 | `ct_had_sm.v:313-319` | 否则 PCFIFO 读不出（注释明示）|
| HACR 宽度 | 16 位，含 bank/index/core/rw/go/ex | `ct_had_ir.v:237-240`、`ct_had_private_ir.v:257-269` | 窄 IR 覆盖大量寄存器与多核 |
| 复位指向 ID | `16'h8200` | `ct_had_ir.v:181` | 上电即可读版本，握手简单 |
| 移位宽度自适应 | 按选中寄存器分 8/16/32/64 | `ct_had_serial.v:123-154` | 不同寄存器宽度不同，避免错位 |
| 每核 HACR 副本 + core_sel | 私有侧独立译码 | `ct_had_private_ir.v:262-264` | 多核精确选择，只有目标核动作 |
| 跨域同步 | sync_3flop（共用）/ level2pulse（私有）| `ct_had_sync_3flop.v`、`ct_had_private_ir.v:174-207` | JTAG↔CPU 慢→快安全握手 |
| 时钟门控 | Update 事件才开时钟 | `ct_had_sm.v:323-334`、`ct_had_ir.v:157-165` | 调试单元绝大多数时间空闲 |

---

## 覆盖声明

本篇覆盖 HAD 的 JTAG/IR 接入层全部 6 个文件：TAP 状态机（`ct_had_sm.v`）、引脚 IO（`ct_had_io.v`）、串行移位（`ct_had_serial.v`）、共用/私有 HACR 译码（`ct_had_ir.v`/`ct_had_private_ir.v`）、跨域同步（`ct_had_sync_3flop.v`）。所有状态编码、位宽、字段、参数均带 file:line，可逐条对照 RTL 核验，未做任何虚构。HACR 各 go/ex/exit_dbg 位如何驱动停核/注入/退出，详见 `03_had_ctrl_ddc.md`。
