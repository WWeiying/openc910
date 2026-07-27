# C910 HAD Trace / 跨核触发 模块详细教学文档

> RTL 源文件：
> - `C910_RTL_FACTORY/gen_rtl/had/rtl/ct_had_pcfifo.v`（300 行，16 项控制流 PC-FIFO）
> - `C910_RTL_FACTORY/gen_rtl/had/rtl/ct_had_trace.v`（130 行，OTC 指令计数采样）
> - `C910_RTL_FACTORY/gen_rtl/had/rtl/ct_had_etm.v`（220 行，多核交叉触发开关）
> - `C910_RTL_FACTORY/gen_rtl/had/rtl/ct_had_etm_if.v`（126 行，单核 ETM 接口同步）
> - `C910_RTL_FACTORY/gen_rtl/had/rtl/ct_had_event.v`（182 行，进/出 debug 事件收发）
> - `C910_RTL_FACTORY/gen_rtl/had/rtl/ct_had_dbg_info.v`（452 行，PIPEFIFO + 单核 debug-info 快照）
> - `C910_RTL_FACTORY/gen_rtl/had/rtl/ct_had_common_dbg_info.v`（230 行，簇级 debug-info 快照）
>
> 前置阅读：`00_had_overview.md` §5（多核 halt-all 与交叉触发）

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与 FIFO 深度](#3-参数与-fifo-深度)
4. [PC-FIFO：16 项控制流记录](#4-pc-fifo16-项控制流记录)
5. [OTC：指令计数采样 trace](#5-otc指令计数采样-trace)
6. [跨核交叉触发：etm + etm_if + event](#6-跨核交叉触发etm--etm_if--event)
7. [PIPEFIFO 与 debug-info 快照](#7-pipefifo-与-debug-info-快照)
8. [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

### 1.1 这一层做什么

Trace 层让调试器**不停核也能观察 CPU 的运行轨迹**，并在多核间协调停核。它包含四组互相独立的功能：

| 功能 | 模块 | 一句话 |
|------|------|--------|
| 控制流记录 | `ct_had_pcfifo` | 把分支/跳转的目标 PC 记进 16 项 FIFO，供回溯执行路径 |
| 指令计数采样 | `ct_had_trace` | 用 8 位 OTC 计数器，每退休 N 条指令请求一次停核（采样式 trace）|
| 跨核 halt-all | `ct_had_etm` + `ct_had_etm_if` + `ct_had_event` | 一个核进/出 debug 时广播给其他核，一停全停 / 一起退 |
| 调试快照 | `ct_had_dbg_info` + `ct_had_common_dbg_info` | 进入 debug 时抓取全核（含 IFU/LSU/IDU/MMU…）与簇级（CIU/L2C）状态快照 |

### 1.2 与 ctrl 的接口

PC-FIFO 和 trace 都受 `ct_had_ctrl` 的使能/读写脉冲驱动（`ctrl_pcfifo_wen/ren`、`ctrl_trace_en`，见 `ct_had_ctrl.v:427-436,404-415`）；trace 计满产生 `trace_ctrl_req` → ctrl → `had_rtu_trace_dbgreq`。跨核 event 产生 `event_ctrl_enter_dbg`/`exit_dbg` → ctrl。

---

## 2. 端口说明

### 2.1 ct_had_pcfifo

| 方向 | 信号 | 含义 |
|------|------|------|
| in | `ctrl_pcfifo_wen` / `ctrl_pcfifo_ren` | 写/读使能（来自 ctrl）|
| in | `rtu_had_xx_pcfifo_inst0/1/2_chgflow` | 三发退休各自是否改流指令，`ct_had_pcfifo.v:24,26,28` |
| in | `rtu_had_xx_pcfifo_inst0/1/2_next_pc[38:0]` | 改流目标的半字地址，保存字节 PC `[39:1]`，`:25,27,29` |
| in | `mmu_xx_mmu_en` | MMU 开（决定读出符号扩展），`:22` |
| out | `pcfifo_regs_data[63:0]` | 读出给 regs→serial→tdo，`:44` |

### 2.2 ct_had_trace

| 方向 | 信号 | 含义 |
|------|------|------|
| in | `ctrl_trace_en` | trace 使能，`ct_had_trace.v:35` |
| in | `ir_xx_otc_reg_sel` / `ir_xx_wdata` | JTAG 写 OTC 初值，`:37,38` |
| in | `rtu_yy_xx_retire0_normal` / `rtu_had_xx_split_inst` / `rtu_yy_xx_dbgon` | 退休/split/已 debug，`:41,39,40` |
| in | `inst_bkpt_dbgreq` | 有断点请求时不计数，`:36` |
| out | `trace_ctrl_req` | trace 计满请求（送 ctrl），`:43` |
| out | `trace_regs_otc[7:0]` | 当前 OTC 值（供读出），`:44` |

### 2.3 ct_had_etm / ct_had_etm_if / ct_had_event

| 模块 | 信号 | 含义 |
|------|------|------|
| etm | `coreN_enter/exit_dbg_req_o` | 各核发出的进/出请求（输入到交叉开关）|
| etm | `coreN_enter/exit_dbg_req_i` | 广播给各核的进/出请求（输出）|
| etm | `event_clk` (gated) | 跨核事件门控时钟，`ct_had_etm.v:199-207` |
| event | `regs_event_enter_ie/oe` `exit_ie/oe` | 软件使能：是否接收/发出进出事件，`ct_had_event.v:43-46` |
| event | `x_enter/exit_dbg_req_i` / `_o` | 与 etm 对接的进/出请求 | 
| event | `event_ctrl_enter_dbg` / `exit_dbg` | 送 ctrl 的最终事件，`:50,51` |

### 2.4 ct_had_dbg_info（关键端口）

| 方向 | 信号 | 含义 |
|------|------|------|
| in | `ctrl_pipefifo_wen/ren` / `ctrl_dbgfifo_ren` | PIPEFIFO 写读 / DBGFIFO 读，`ct_had_dbg_info.v:23,22,21` |
| in | `{ifu,lsu,idu,iu,cp0,rtu,mmu}_had_debug_info` | 各单元的调试快照向量 | 
| in | `rtu_had_dbg_ack_info` | 进 debug ack（触发快照）`:46` |
| out | `pipefifo_regs_data` / `dbgfifo_regs_data` | 两个 FIFO 读出，`:44,24` |
| out | `x_dbg_ack_pc` | 本核已进 debug（送簇级），`:54` |

---

## 3. 参数与 FIFO 深度

| FIFO | 深度 | 宽度 | 指针宽 | 出处 |
|------|------|------|--------|------|
| PC-FIFO | **16** | `PA_WIDTH`（40）| 5 | `ct_had_pcfifo.v:99-102` |
| PIPEFIFO（流水线事件）| **16** | 64 | 5 | `ct_had_dbg_info.v:207-209` |
| DBGFIFO（单核快照）| 7 项 | 64 | 3 | `ct_had_dbg_info.v:371-373`（DBG_DPETH=7）|
| DBGFIFO2（簇级快照）| 6 项 | 64 | 3 | `ct_had_common_dbg_info.v:117-119` |
| OTC 计数器 | — | 8 位 | — | `ct_had_trace.v:47` |

PC-FIFO 和 PIPEFIFO 都是 **3-wide 入队**（每周期最多 3 条改流/事件入队），所以指针逻辑要处理 +1/+2/+3 三种增量，这是它们最复杂的地方。

---

## 4. PC-FIFO：16 项控制流记录

PC-FIFO 记录"分支/跳转改流后落到哪个 PC"，调试器读出后就能重建执行路径。难点是**一周期最多 3 条改流指令同时入队**（C910 三发退休）。

输入的 `next_pc[38:0]` 省略了恒为 0 的架构 `PC[0]`。PC-FIFO 写入 40 位条目
时执行 `{next_pc[38:0],1'b0}`，所以 FIFO 内和最终读出的低 40 位已经恢复成
完整字节地址，不能再左移一次。

### 4.1 写入：3 条同时入队

退休时每条指令带 `chgflow`（是否改流）和 `next_pc`（目标）。先打一拍收集（`ct_had_pcfifo.v:118-156`）：

```verilog
assign chgflow_valid_pre[2:0] = {inst2_chgflow, inst1_chgflow, inst0_chgflow};  // :118-120
// pcfifo_din_0/1/2 各自锁存对应 next_pc（左移 1 位补 0 对齐字节地址）          :140-156
```

根据本周期改流条数分三类（`:162-172`）：

```verilog
assign create_three = &chgflow_valid[2:0];                       // 3 条
assign create_two   = (chgflow_valid == 3'b110/101/011);         // 2 条
assign create_one   = (chgflow_valid == 3'b100/010/001);         // 1 条
```

入队用写指针的三个候选位置 `wptr_0/1/2`（`:259-261`）配合 one-hot 选择 `wptr_sel_*`（`:174-178`）把 1~3 个 din 写进 16 个 `pcfifo_reg`（`:181-199` 的 generate）。

### 4.2 写指针：变增量

```verilog
assign wptr_inc = create_three ? 2'b11 : create_two ? 2'b10 : 2'b01;   // :254-257
// 写指针一次 +1/+2/+3
```

### 4.3 溢出丢最旧

PC-FIFO 满时新数据**覆盖最旧**，靠读指针 rptr 跟着前移实现（`:266-294`）：

```verilog
assign rptr_inc_3 = create_vld && pcfifo_full && create_three;                   // :266-267
assign rptr_inc_2 = create_vld && (one_entry_left && create_three || pcfifo_full && create_two);  // :268-270
assign rptr_inc_1 = create_vld && (two_entry_left && create_three || ... || pcfifo_full && create_one)
                 || ctrl_pcfifo_ren;                                             // :271-275
```

含义：当 FIFO 将满而新一批入队，rptr 同步前移把最旧的条目"挤掉"。trace 记录天然是"环形覆盖"语义——只关心最近的控制流，旧的可以丢。读出（`ctrl_pcfifo_ren`）时 rptr 也 +1。

### 4.4 读出与符号扩展

```verilog
assign pcfifo_regs_data = mmu_xx_mmu_en ? {符号扩展 pcfifo_dout} : {零扩展 pcfifo_dout};  // :218-219
```

MMU 开启时虚地址要符号扩展到 64 位（高位补 `pcfifo_dout[WIDTH-1]`），关闭时物理地址零扩展。读出经 regs（`ct_had_regs.v:951`）→serial→tdo。

---

## 5. OTC：指令计数采样 trace

OTC（**O**ver**T**ake **C**ounter / 指令计数器）实现"每退休 N 条指令就停一次"的采样式 trace。8 位计数器（`ct_had_trace.v:47`）。

### 5.1 trace 有效条件

```verilog
assign trace_vld = rtu_yy_xx_retire0_normal &&     // 正常退休
                  !rtu_had_xx_split_inst &&         // 非 split（或 split 最后一条）
                  !rtu_yy_xx_dbgon &&                // 不在 debug
                   ctrl_trace_en;                    // trace 使能          :77-80
```

注释 `:73-74` 点明：trace 使能时 CPU 每周期只退休一条（配合 `had_rtu_pop1_disa`），保证逐条计数精确。

### 5.2 计数器递减与请求

```verilog
assign trace_counter_eq_0 = trace_counter == 8'b0;                      // :89
assign trace_counter_dec  = trace_vld && !trace_counter_eq_0 && !inst_bkpt_dbgreq;  // :90

always @(...)                                                           // :97-107
  if      (x_sm_xx_update_dr_en && ir_xx_otc_reg_sel) trace_counter <= ir_xx_wdata[7:0]; // JTAG 写 N
  else if (trace_counter_dec)                         trace_counter <= trace_counter - 1;
  
assign trace_ctrl_req = trace_vld && trace_counter_eq_0;                // :123 计到 0 请求停核
```

调试器写入 N，每退休一条减 1，减到 0 且又有一条退休时产生 `trace_ctrl_req`，经 ctrl 变成 `had_rtu_trace_dbgreq`（`ct_had_ctrl.v:484`）。这样调试器可以"运行 N 条指令后停下看一眼"，反复采样。`!inst_bkpt_dbgreq` 保证断点优先于 trace。

---

## 6. 跨核交叉触发：etm + etm_if + event

多核 halt-all：一个核命中断点进 debug 时，让其他核一起停（`00_had_overview.md §5`）。这条链由三个模块接力。

### 6.1 ct_had_event：单核的进/出事件收发

每个核一份。**输出侧**：本核进/出 debug 时，经软件使能位门控后发出请求（`ct_had_event.v:142-172`）：

```verilog
always @(...) enter_dbg_req_o <= ctrl_event_dbgenter;        // 本核进 debug（ack）  :152-158
assign x_enter_dbg_req_o = enter_dbg_req_o && regs_event_enter_oe;  // OE 门控        :160,172
// exit 对称：exit_dbg_req_o && regs_event_exit_oe                                   :142-150,171
```

**输入侧**：收到其他核广播的请求，经 2 拍同步（`:104-118`）+ 软件使能位 IE 门控后，产生本核的进/出事件：

```verilog
always @(...) // x_enter_dbg_req_i_sync & regs_event_enter_ie → enter_dbg_req_i      :124-132
assign event_ctrl_enter_dbg = enter_dbg_req_i;                                       :134
assign event_ctrl_exit_dbg  = x_exit_dbg_req_i_sync & regs_event_exit_ie;            :135
```

OE/IE 四个使能位（enter/exit × out/in）来自 EVENT_OE/EVENT_IE 寄存器（`ct_had_regs.v:506-540`），让软件精细控制"本核是否广播 / 是否响应"跨核事件。

### 6.2 ct_had_etm：交叉开关

把每个核的 `_o`（输出）请求广播给**其他所有核**的 `_i`（输入），并用 `tee` 安全域相等做门控（`ct_had_etm.v:151-190`）：

```verilog
assign core0_enter_dbg_req =
       core1_enter_dbg_req_o_ff && (core0_tee == core1_tee)     // core1 进 → core0 收
    || core2_enter_dbg_req_o_ff && (core0_tee == core2_tee)
    || core3_enter_dbg_req_o_ff && (core0_tee == core3_tee);    // :151-154
```

每个核收"其他三核"的请求之或——这就是 N×N 交叉开关。`tee` 相等门控保证只有同安全域的核才互相触发（本配置 tee 全接 0，`:146-149`，即都同域）。exit 链对称（`:172-190`）。core2/3 在本 RTL 不实例化（`_o_ff`/`clk_en` 接 0，`:130-142`）。

### 6.3 ct_had_etm_if：跨域同步 + event_clk

每核一份接口模块，做 `_o`/`_i` 的跨时钟同步（`ct_had_etm_if.v:78-110`），并产生本核的 `event_clk_en`（`:112-115`）。所有核的 `event_clk_en` 之或驱动 gated `event_clk`（`ct_had_etm.v:192-207`）：

```verilog
assign event_clk_en = core0_event_clk_en | core1_... | ...;    // :192-195
gated_clk_cell x_ct_event_io_gated_clk(.local_en(event_clk_en), .clk_out(event_clk), ...);  // :199-207
```

**低功耗要点**：没有跨核事件时 `event_clk` 不翻转。整个交叉触发网络在专门的门控时钟域运行，平时零开销。

### 6.4 完整一停全停链路

```
核 A 命中断点 → ctrl_event_dbgenter(ack) → event.enter_dbg_req_o (OE 门控)
   → etm_if 同步 → etm 交叉开关广播 → 核 B 的 enter_dbg_req_i
   → event 2 拍同步 + IE 门控 → event_ctrl_enter_dbg → 核 B 的 ctrl
   → had_rtu_event_dbgreq → 核 B 停核
```

退出对称，实现"一起退"。

---

## 7. PIPEFIFO 与 debug-info 快照

`ct_had_dbg_info` 一个文件里含**两个独立 FIFO**：流水线事件 FIFO（PIPEFIFO）与单核调试快照 FIFO（DBGFIFO）。

### 7.1 PIPEFIFO：可选采样三类流水线事件

由 PIPESEL 寄存器（`ct_had_dbg_info.v:200-202`）选择采样哪一类：

```verilog
assign had_idu_debug_id_inst_en     = (pipesel == 2'b01) && ctrl_pipefifo_wen;  // 译码指令信息
assign had_rtu_debug_retire_info_en = (pipesel == 2'b10) && ctrl_pipefifo_wen;  // 退休信息
assign had_lsu_dbg_info_en          = (pipesel == 2'b11) && ctrl_pipefifo_wen;  // load/store 信息
```

对应三类源数据在 `:230-244` 的 case 里选进 `pipefifo_din_0/1/2`：
- `2'b01`：IDU 三条译码指令信息（40 位）；
- `2'b10`：RTU 三条退休指令信息（64 位）；
- `2'b11`：LSU 的 store 数据 + store 地址。

PIPEFIFO 也是 16 深 3-wide 入队，指针逻辑与 PC-FIFO 同构（`:255-365`，同样的 create_one/two/thr + 满覆盖）。

### 7.2 DBGFIFO：进入 debug 时抓全核快照

进入 debug 时（`rtu_had_dbg_ack_info` 打一拍 `dbg_ack_pc_f`，`:412-419`），把**全核各单元的调试向量**一次性锁进 408 位快照（`:404-410`）：

```verilog
assign xx_dgb_info[407:0] = {mmu_had_debug_info[33:0],     // MMU
                             rtu_had_debug_info[42:0],      // RTU
                             cp0_had_debug_info[3:0],       // CP0
                             iu_had_debug_info[9:0],         // IU
                             idu_had_debug_info[49:0],       // IDU
                             lsu_had_debug_info[183:0],      // LSU
                             ifu_had_debug_info[82:0]};      // IFU
```

408 位切成 7 个 64 位条目（`:375-382`），调试器通过 DBGFIFO 寄存器逐条读出（`ctrl_dbgfifo_ren` 推进读指针，`:430-441`）。这给调试器一张"进入 debug 那一刻全核状态"的全景照片。

### 7.3 簇级快照 ct_had_common_dbg_info

共用侧对称地抓**簇级**（CIU + L2C）快照（`ct_had_common_dbg_info.v:166-184`）：

```verilog
parameter DBG_INFO_WIDTH = 337;
assign xx_dbg_info[336:0] = {l2c_had_dbg_info[43:0], ciu_had_dbg_info[292:0]};  // :166-171
```

触发条件是**任一核 ack 进入 debug**（`had_dbg_ack_pc = OR(四核 dbg_ack_pc_sync)`，`:111-114`）。337 位补齐成 6 个 64 位条目（DBGFIFO2，深度 6，`:117-119,181-184`），经 DBGFIFO2 寄存器读出。整个簇级快照 FIFO 也在 gated `dbginfo_clk` 域（`:203-216`），平时不翻转。

---

## 设计取舍小结

| 决策 | 内容 | 出处 | 为什么 |
|------|------|------|--------|
| PC-FIFO 深度 16，3-wide | 每周期最多 3 条改流入队，满则覆盖最旧 | `ct_had_pcfifo.v:99-101,254-294` | 三发退休需多端口入队；trace 只关心最近路径 |
| OTC 采样 trace | 8 位计数，退休 N 条停一次 | `ct_had_trace.v:97-123` | "运行 N 条看一眼"反复采样，比逐条停高效 |
| trace 逐条退休 | trace 使能时 pop1_disa | `ct_had_trace.v:73-74`,`ct_had_ctrl.v:531` | 保证计数精确 |
| 跨核交叉开关 + tee 门控 | 每核收其他三核进/出请求之或，同域才触发 | `ct_had_etm.v:151-190` | 一停全停 / 一起退，且安全域隔离 |
| OE/IE 四使能位 | 软件控制本核是否广播/响应 | `ct_had_event.v:160,135`；`ct_had_regs.v:506-540` | 灵活配置 halt-all 参与度 |
| event_clk 门控 | 无跨核事件不翻转 | `ct_had_etm.v:192-207` | 交叉触发网络平时零功耗 |
| PIPESEL 可选采样 | 一套 FIFO 复用采 IDU/RTU/LSU 三类 | `ct_had_dbg_info.v:200-244` | 节省面积，按需观察某一类事件 |
| 进 debug 抓全核+簇级快照 | 408 位核内 + 337 位簇级 | `ct_had_dbg_info.v:404-410`；`ct_had_common_dbg_info.v:166-171` | 给调试器进入瞬间的全景状态 |

---

## 覆盖声明

本篇覆盖 PC-FIFO（16 深、3-wide 入队、满覆盖、符号扩展读出）、OTC 采样 trace（8 位计数请求）、跨核交叉触发链（event→etm_if→etm，OE/IE 门控、event_clk）、PIPEFIFO（PIPESEL 三类采样）与 debug-info 快照（核内 408 位 / 簇级 337 位）。所有 FIFO 深度、向量宽度、状态与行号均按 RTL 实读标注，未对行为虚构。停核请求如何汇聚见 `03_had_ctrl_ddc.md`，寄存器字段见 `05_had_regs.md`。
