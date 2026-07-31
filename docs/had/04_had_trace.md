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
8. [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 这一层做什么

本篇所覆盖的模块同时包含运行时记录、计数触发、跨核事件和 debug-entry 快照。PCFIFO/PIPEFIFO 可以在正常运行时积累数据；OTC 计数到阈值后会主动请求进入 debug；DBGFIFO/DBGFIFO2 则是在 debug ack 附近抓取一次快照。因此不能把整层笼统描述成“不停核 trace”。

| 功能 | 模块 | 一句话 |
|------|------|--------|
| 控制流记录 | `ct_had_pcfifo` | 记录退休改流槽携带的 next PC；16 项满后保留最近条目 |
| 指令计数触发 | `ct_had_trace` | 用 8 位 OTC 倒计数，在计数已经为 0 的下一次合格退休上请求 debug |
| 双核交叉触发 | `ct_had_etm` + `ct_had_etm_if` + `ct_had_event` | 当前实例只连接 core0/core1；四核表达式中的 core2/3 输入固定为 0 |
| 调试快照 | `ct_had_dbg_info` + `ct_had_common_dbg_info` | 抓取一组预定义核内向量和 CIU/L2C 向量，不等于保存全部微结构状态 |

### 1.2 与 ctrl 的接口

PC-FIFO 和 trace 都受 `ct_had_ctrl` 的使能/读写脉冲驱动（`ctrl_pcfifo_wen/ren`、`ctrl_trace_en`，见 `ct_had_ctrl.v:427-436,404-415`）；trace 计满产生 `trace_ctrl_req` → ctrl → `had_rtu_trace_dbgreq`。跨核 event 产生 `event_ctrl_enter_dbg`/`exit_dbg` → ctrl。

---

## 2. 端口说明

### 2.1 ct_had_pcfifo

| 方向 | 信号 | 含义 |
|------|------|------|
| in | `ctrl_pcfifo_wen` / `ctrl_pcfifo_ren` | 写/读使能（来自 ctrl）|
| in | `rtu_had_xx_pcfifo_inst0/1/2_chgflow` | 三发退休各自是否改流指令，`ct_had_pcfifo.v:24,26,28` |
| in | `rtu_had_xx_pcfifo_inst0/1/2_next_pc[38:0]` | 省略架构 PC bit0 的 next-PC 编码；写 FIFO 时补回低位 0，`:25,27,29,140-156` |
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
| etm | `core0/1_enter/exit_dbg_req_o` | 当前顶层接入的两个核发出的进/出请求 |
| etm | `core0/1_enter/exit_dbg_req_i` | 交叉组合并经 event_clk 寄存后送回两个核的请求 |
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
| out | `x_dbg_ack_pc` | `rtu_had_dbg_ack_info` 延迟一拍后的电平，送簇级捕获逻辑，`:54,:412-446` |

---

## 3. 参数与 FIFO 深度

| FIFO | 深度 | 宽度 | 指针宽 | 出处 |
|------|------|------|--------|------|
| PC-FIFO | **16** | `PA_WIDTH`（40）| 5 | `ct_had_pcfifo.v:99-102` |
| PIPEFIFO（流水线事件）| **16** | 64 | 5 | `ct_had_dbg_info.v:207-209` |
| DBGFIFO（核内快照读窗）| 7 个 64 位分片 | 64 | 3 | `ct_had_dbg_info.v:371-382`（源码参数拼作 `DBG_DPETH`）|
| DBGFIFO2（簇级快照读窗）| 6 个 64 位分片 | 64 | 3 | `ct_had_common_dbg_info.v:117-132` |
| OTC 计数器 | — | 8 位 | — | `ct_had_trace.v:47` |

PC-FIFO 和 PIPEFIFO 的物理写端各有三个槽，指针可 +1/+2/+3。PCFIFO 接受任意三槽 `chgflow_valid` 组合；PIPEFIFO 的 create 译码只识别 `001/011/111`，依赖上游有效槽按 slot0 开始连续压紧。DBGFIFO/DBGFIFO2 则不是可连续入队多份快照的普通 FIFO：它们各只保存**最近一次宽快照**，再将其切成 7/6 个 64 位读片。

---

## 4. PC-FIFO：16 项控制流记录

PC-FIFO 记录 RTU 标为 `chgflow` 的退休槽及其 `next_pc`。它提供最近改流点的目标序列，但没有记录每条未改流指令、分支源 PC、taken 位和时间戳，所以仅靠 PCFIFO 一般不能无歧义重建完整动态指令轨迹。

输入的 `next_pc[38:0]` 省略了恒为 0 的架构 `PC[0]`。PC-FIFO 写入 40 位条目
时执行 `{next_pc[38:0],1'b0}`，所以 FIFO 内和最终读出的低 40 位已经恢复成
完整字节地址，不能再左移一次。

### 4.1 写入：3 条同时入队

三个退休槽的 `chgflow/next_pc` 先寄存一拍；`ctrl_pcfifo_wen` 也单独寄存一拍，从而在同一后续周期共同控制写入：

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

当剩余空间不足以容纳本批 1~3 个条目时，rptr 按溢出量前移，使新条目覆盖最旧内容；显式读也使 rptr +1。模块计算 empty/full，却没有把它们输出给软件；空 FIFO 上仍然允许读，读数据可能是复位值或旧数组内容，同时 wptr/rptr都会前移以维持 empty 关系。调试软件必须按协议掌握可读条目数，不能从数据值本身判断有效性。

### 4.4 读出与符号扩展

```verilog
assign pcfifo_regs_data = mmu_xx_mmu_en ? {符号扩展 pcfifo_dout} : {零扩展 pcfifo_dout};  // :218-219
```

MMU 开启时虚地址要符号扩展到 64 位（高位补 `pcfifo_dout[WIDTH-1]`），关闭时物理地址零扩展。读出经 regs（`ct_had_regs.v:951`）→serial→tdo。

---

## 5. OTC：指令计数采样 trace

RTL 只给出寄存器名 OTC，没有定义 `O/T/C` 的英文展开，本文不自行解释缩写。其有效实现是一个 8 位、软件可写的退休倒计数器。

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

计数和请求的精确相位容易产生 off-by-one 误解：

- 写入 0：第一次 `trace_vld` 就请求；
- 写入 1：第一次合格退休把 1 减到 0，不请求；第二次合格退休才请求；
- 写入 N：先经过 N 次合格退休递减，再在第 N+1 次合格退休上请求。

计数器到 0 后不会自动重装；`trace_ctrl_req` 在每个后续 `trace_vld` 周期都可再次为 1，通常由进入 debug 使 `trace_vld` 关闭。若希望下一轮固定间隔采样，软件退出 debug 前需要重新写 OTC。`inst_bkpt_dbgreq` 只阻止递减，不直接加入 `trace_ctrl_req` 表达式；同拍请求优先级还要结合 ctrl 的 `!ctrl_regs_update_mbo` 状态更新逻辑观察。

---

## 6. 跨核交叉触发：etm + etm_if + event

当前公开配置提供 core0/core1 之间的可配置交叉触发。只有双方相应 EVENT_OE/IE 位开启时，才会表现为“一核进入后另一核也请求进入”；它不是无条件的全系统 halt-all。

### 6.1 ct_had_event：单核的进/出事件收发

每个核一份。**输出侧**：本核进/出 debug 时，经软件使能位门控后发出请求（`ct_had_event.v:142-172`）：

```verilog
always @(...) enter_dbg_req_o <= ctrl_event_dbgenter;        // 本核进 debug（ack）  :152-158
assign x_enter_dbg_req_o = enter_dbg_req_o && regs_event_enter_oe;  // OE 门控        :160,172
// exit 对称：exit_dbg_req_o && regs_event_exit_oe                                   :142-150,171
```

**输入侧**：来自 ETM 的请求先在 `forever_coreclk` 上打两拍。enter 输入经 IE 门控后锁存，直到本核 `dbgon` 才清；exit 输入没有本地 sticky 寄存器，只是同步电平与 IE 的组合：

```verilog
always @(...) // x_enter_dbg_req_i_sync & regs_event_enter_ie → enter_dbg_req_i      :124-132
assign event_ctrl_enter_dbg = enter_dbg_req_i;                                       :134
assign event_ctrl_exit_dbg  = x_exit_dbg_req_i_sync & regs_event_exit_ie;            :135
```

OE/IE 四个使能位控制本核发送/接收。该链路没有端到端 ack 回送给发起核；可靠性依赖请求经寄存后具有足够电平宽度以及共享/相关时钟环境。

### 6.2 ct_had_etm：交叉开关

源码保留四核 OR 表达式和 `tee` 相等比较，但模块端口、`ct_had_etm_if` 实例和顶层连接只有 core0/core1。core2/core3 的 `_o_ff` 与 `event_clk_en` 固定为 0，四个 `tee` 又全部固定为 0。因此当前有效行为等价于 core0 与 core1 互相转发：

```verilog
assign core0_enter_dbg_req =
       core1_enter_dbg_req_o_ff && (core0_tee == core1_tee)     // core1 进 → core0 收
    || core2_enter_dbg_req_o_ff && (core0_tee == core2_tee)
    || core3_enter_dbg_req_o_ff && (core0_tee == core3_tee);    // :151-154
```

四核式可以看成参数化/历史扩展痕迹，不能描述成当前已实现的 N×N 四核交叉开关。`tee` 比较逻辑虽然存在，但输入固定为 0，所以当前没有动态安全域隔离能力，所有已接入核总被视为同域。若未来扩到四核或启用 TEE，必须同时补端口、实例、顶层连线和安全状态来源，不能只解除 core2/3 常量。

### 6.3 ct_had_etm_if：跨域同步 + event_clk

当前每个已接入核一份 `ct_had_etm_if`。它在 `event_clk` 上各寄存一次本核输出请求和交叉 OR 后的输入请求；真正到每核 `forever_coreclk` 后，`ct_had_event` 还会再打两拍。源码中原拟使用的 `sync_level2pulse` 实例已经注释，当前没有 ack 握手。

```verilog
assign event_clk_en = core0_event_clk_en | core1_... | ...;    // :192-195
gated_clk_cell x_ct_event_io_gated_clk(.local_en(event_clk_en), .clk_out(event_clk), ...);  // :199-207
```

`x_event_clk_en` OR 了 raw 与寄存后的 enter/exit 请求，用意是让 event_clk 至少覆盖请求捕获和清除。逻辑上可以称为“按事件申请门控时钟”；不能称为“平时零开销”或保证时钟物理不翻转，因为默认行为级 `gated_clk_cell` 可能直通，组合网络和同步寄存器也仍有面积/漏电成本。

### 6.4 完整一停全停链路

```
核 A 命中断点 → ctrl_event_dbgenter(ack) → event.enter_dbg_req_o (OE 门控)
   → etm_if 同步 → etm 交叉开关广播 → 核 B 的 enter_dbg_req_i
   → event 2 拍同步 + IE 门控 → event_ctrl_enter_dbg → 核 B 的 ctrl
   → had_rtu_event_dbgreq → 核 B 停核
```

退出路径结构近似对称，但 enter 接收端有 sticky 保持到 `dbgon`，exit 接收端是同步电平组合；两者的保持行为并不完全对称。

---

## 7. PIPEFIFO 与 debug-info 快照

`ct_had_dbg_info` 一个文件里含**两个独立 FIFO**：流水线事件 FIFO（PIPEFIFO）与单核调试快照 FIFO（DBGFIFO）。

### 7.1 PIPEFIFO：可选采样三类流水线事件

由 2 位 PIPESEL 选择一种数据格式：

```verilog
assign had_idu_debug_id_inst_en     = (pipesel == 2'b01) && ctrl_pipefifo_wen;  // 译码指令信息
assign had_rtu_debug_retire_info_en = (pipesel == 2'b10) && ctrl_pipefifo_wen;  // 退休信息
assign had_lsu_dbg_info_en          = (pipesel == 2'b11) && ctrl_pipefifo_wen;  // load/store 信息
```

对应三类源数据在 `:230-244` 的 case 里选进 `pipefifo_din_0/1/2`：
- `2'b01`：IDU 三条译码指令信息（40 位）；
- `2'b10`：RTU 三条退休指令信息（64 位）；
- `2'b11`：LSU store 数据和 store 地址各占一个 FIFO 条目；第三槽固定 0且无效。

PIPEFIFO 也是 16 深、最多三槽入队并在满时丢最旧条目。它的 `create_one/two/thr` 只识别 `001/011/111`，这对 IDU/RTU依赖有效槽压紧，对 LSU 则自然生成 `011`。PIPESEL=0 不采样。当前 `had_lsu_dbg_info_en` 只打开这条 store-info 路径；私有顶层另有 `had_lsu_pctrace_en`/`bus_trace_en` 固定为 0，不能把 PIPEFIFO 描述成完整 load/store/bus trace。

### 7.2 DBGFIFO：进入 debug 时抓核内导出向量

`rtu_had_dbg_ack_info` 先寄存为 `dbg_ack_pc_f`；当该延迟电平为 1时，408 位核内向量每拍都会重采样。若 ack 只维持一拍，就是一次延迟快照；若维持多拍，则最后保存的是最后一个有效采样周期。该向量只包含各模块专门导出的 debug-info 字段，不是“全核全部寄存器”：

```verilog
assign xx_dgb_info[407:0] = {mmu_had_debug_info[33:0],     // MMU
                             rtu_had_debug_info[42:0],      // RTU
                             cp0_had_debug_info[3:0],       // CP0
                             iu_had_debug_info[9:0],         // IU
                             idu_had_debug_info[49:0],       // IDU
                             lsu_had_debug_info[183:0],      // LSU
                             ifu_had_debug_info[82:0]};      // IFU
```

408 位切成 7 个 64 位读片，最后一片仅低 24 位有效、高 40 位补 0。它是单份快照的串行读窗，不是 7 份历史快照队列。读指针到 7 后需要一个无读使能的时钟机会才能按 `dbg_rptr_done` 清零；软件应严格读 7 次并留出复位指针阶段，避免动态索引越界。

### 7.3 簇级快照 ct_had_common_dbg_info

共用侧对称地抓**簇级**（CIU + L2C）快照（`ct_had_common_dbg_info.v:166-184`）：

```verilog
parameter DBG_INFO_WIDTH = 337;
assign xx_dbg_info[336:0] = {l2c_had_dbg_info[43:0], ciu_had_dbg_info[292:0]};  // :166-171
```

触发条件是 core0/core1 的 `dbg_ack_pc` 之 OR 的上升沿；core2/3 同步值固定为 0，而且 core0/1 的原同步器代码已注释，当前直接连线。若两个核的 ack 重叠并使 OR 一直为高，只在第一个上升沿捕获一次。337 位补成 384 位、分为 6 个读片，最高读片的高 47 位补 0。它同样只保存最近一次簇级快照；连续第 7 次读取前需要让 done 逻辑重置指针。`dbginfo_clk` 的物理门控仍取决于工艺宏实现。

## 本章小结

HAD 的 trace 与诊断结构包含三种不同的数据保存语义。PCFIFO 是真正的 16 项循环队列，每周期可接收最多三条退休改流记录，空间不足时覆盖最旧项以保留最近路径；PIPEFIFO 也是 16 项队列，但通过 PIPESEL 在 IDU、RTU、LSU 三类采样源之间复用。DBGFIFO 和 DBGFIFO2 则分别保存一次 408 位核内快照和一次 337 位 CIU/L2C 快照，再通过多次窄寄存器读取完成分片访问，它们不是多项历史 FIFO。读取快照时还要遵守各自的分片数和读指针复位时机，不能把连续动态索引当成任意深度的历史记录。

OTC 从写入值开始对合格退休事件逐次递减，写入 N 后先经历 N 次递减，在第 N+1 个合格退休点形成请求，而且不会自动重装。trace 使能时 `pop1_disa` 限制一次只处理一条退休记录，使计数与路径记录保持逐条对应。双核 event/ETM 允许当前实例化的 core0 和 core1 按 OE/IE 配置互相广播和响应，core2/3 及动态 TEE 只保留常量占位。event 和 trace 活动会提出局部时钟门控请求，但最终物理时钟行为仍取决于 `gated_clk_cell` 的完整控制输入。理解这些保存、计数和触发语义后，才能区分“最近路径队列”“按源选择的采样队列”和“调试确认附近的一次性快照”，避免用同一种 FIFO 模型解释所有诊断寄存器。
