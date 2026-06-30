# C910 HAD 调试控制与 DDC 数据通道 模块详细教学文档

> RTL 源文件：
> - `C910_RTL_FACTORY/gen_rtl/had/rtl/ct_had_ctrl.v`（711 行，调试控制核心：停核请求 / 指令注入 / 退出 / HSR 更新）
> - `C910_RTL_FACTORY/gen_rtl/had/rtl/ct_had_ddc_ctrl.v`（205 行，DDC 调试数据通道状态机）
> - `C910_RTL_FACTORY/gen_rtl/had/rtl/ct_had_ddc_dp.v`（117 行，DDC 数据通路：地址/数据寄存器 + 指令合成）
>
> 配套：`ct_had_regs.v`（WBBR/IR/HCR/HSR），相关行号文中标注。
>
> 前置阅读：`00_had_overview.md` §2（停核→注入→窥探→恢复四步法）、`02_had_breakpoint.md`（断点请求来源）

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键信号](#3-参数与关键信号)
4. [进入 debug：四类停核请求](#4-进入-debug四类停核请求)
5. [SQC 顺序限定与断点/trace 使能](#5-sqc-顺序限定与断点trace-使能)
6. [指令注入：go / WBBR 回写](#6-指令注入go--wbbr-回写)
7. [退出 debug：exit / pcload](#7-退出-debugexit--pcload)
8. [HSR 状态位更新](#8-hsr-状态位更新)
9. [DDC 调试数据通道（搬内存）](#9-ddc-调试数据通道搬内存)
10. [debug-disable 与时钟门控](#10-debug-disable-与时钟门控)
11. [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

### 1.1 这一层做什么

`ct_had_ctrl` 是 HAD 私有侧的"大脑"，把 `00_had_overview.md §2` 的四步法（停核 → 注入 → 窥探 → 恢复）真正落成 RTL。RTL 顶部注释把它的职责分成四块（`ct_had_ctrl.v:341-345`）：

1. 给各 HAD 功能模块（断点/trace/pcfifo/pipefifo）发使能与读写脉冲；
2. 向 RTU 发各类停核请求（`had_rtu_*_dbgreq`）；
3. 通知 HSR 更新对应状态位（mbo/swo/to/dro/adro…）；
4. 退出 debug 的逻辑（`had_yy_xx_exit_dbg` / `had_ifu_pcload`）。

`ct_had_ddc_ctrl` + `ct_had_ddc_dp` 实现 **DDC（Debug Data Channel，调试数据通道）**：HAD v2.3 的增量特性。它用一个状态机**硬件自动合成 `mv`/`sd` 指令序列**搬内存，免去调试器逐条手工注入搬运指令（`00_had_overview.md §3.3`）。

### 1.2 三者的协作

```
ct_had_bkpt/nirv/trace/event  ──(请求)──►  ct_had_ctrl ──► had_rtu_*_dbgreq ──► RTU 停核
                                              │
JTAG (go/ex via ir)  ─────────────────────────┤──► had_ifu_ir_vld（注入）/ had_ifu_pcload（恢复）
                                              │
ct_had_ddc_ctrl (FSM) ──(addr/data/stw sel)──┤──► ct_had_ddc_dp 合成 mv/sd → ir_reg/wbbr/ffy
                                              │       (经 ddc_xx_update_ir 触发 go_in_dbg)
ct_had_regs (WBBR/IR/HCR/HSR) ◄──────────────┘
```

---

## 2. 端口说明

### 2.1 ct_had_ctrl 关键端口（按职责分组）

#### 请求输入（来自断点/trace/event/总线）

| 信号 | 含义 | 行号 |
|------|------|------|
| `bkpta/bkptb_ctrl_inst_req(_raw)` | 断点 A/B 取指请求（同步/raw）| `:119-125` |
| `bkpta/bkptb_ctrl_data_req(_raw)` | 断点 A/B 数据请求 | 同上 |
| `bkpta/bkptb_ctrl_xx_ack` | 断点 ack | `:121,:126` |
| `non_irv_bkpt_vld` / `nirv_bkpta` | non-IRV 命中 / 是否 A | `:138,:137` |
| `trace_ctrl_req` | trace 计满请求 | `:158` |
| `event_ctrl_enter_dbg` / `event_ctrl_exit_dbg` | 跨核事件进/出 | `:130,:131` |
| `biu_had_sdb_req_b` | 总线 sdb 调试请求（低有效）| `:116` |
| `regs_ctrl_dr` / `regs_ctrl_adr` | HCR.DR / HCR.ADR 同步/异步请求 | `:140,:139` |

#### 停核请求输出（到 RTU）

| 信号 | 含义 | 行号 |
|------|------|------|
| `had_rtu_xx_jdbreq` | 异步调试请求（调试器"暂停"）| `:206` |
| `had_rtu_hw_dbgreq(_gateclk)` | 同步请求（DR 置位 / sdb）| `:199,:200` |
| `had_rtu_inst_bkpt_dbgreq` / `had_rtu_data_bkpt_dbgreq` | 断点请求 | `:201,:194` |
| `had_rtu_trace_dbgreq` | trace 计满请求 | `:204` |
| `had_rtu_event_dbgreq` | 跨核事件请求 | `:197` |
| `had_rtu_non_irv_bkpt_dbgreq` | 不可撤销断点请求 | `:202` |
| `had_rtu_dbg_req_en` / `had_rtu_pop1_disa` / `had_rtu_xx_tme` | 单步退休模式 / 禁双发 / trace 模式 | `:196,:203,:207` |
| `had_cp0_xx_dbg` | 唤醒低功耗 CPU | `:191` |

#### 注入 / 退出

| 信号 | 含义 | 行号 |
|------|------|------|
| `had_ifu_ir_vld` | 注入指令有效（go）| `:192` |
| `had_yy_xx_exit_dbg` | 退出 debug | `:209` |
| `had_ifu_pcload` | 退出时让 IFU 从 CPUSCR.PC 取指 | `:193` |
| `x_ir_xx_go` / `x_ir_xx_ex` | JTAG HACR 的 go/ex 位（脉冲）| `:111,:110` |
| `ir_ctrl_exit_dbg_reg` | 选中可退出寄存器 | `:81` |

#### HSR 更新脉冲（到 regs）

`ctrl_regs_update_{adro,dro,mbo,swo,to,pro}`、`ctrl_regs_set_sq{a,b}`、`ctrl_regs_bkpt{a,b}_vld`、`ctrl_regs_freeze_pcfifo`、`ctrl_regs_exit_dbg`（`:177-188`）。

### 2.2 ct_had_ddc_ctrl / ct_had_ddc_dp 端口

| 模块 | 信号 | 含义 |
|------|------|------|
| ddc_ctrl | `regs_xx_ddc_en` | HCR.DDCEN 使能，`ct_had_ddc_ctrl.v:38` |
| ddc_ctrl | `ir_xx_daddr_reg_sel` / `ir_xx_ddata_reg_sel` | JTAG 扫入地址/数据，`:36,:37` |
| ddc_ctrl | `rtu_yy_xx_retire0_normal` | 合成指令退休（推进 FSM），`:39` |
| ddc_ctrl→dp | `ddc_ctrl_dp_addr_sel/data_sel/addr_gen` | FSM 当前阶段，`:41-43` |
| ddc_ctrl→regs | `ddc_regs_update_wbbr/csr` / `ddc_xx_update_ir` | 更新 WBBR/CSR/IR，`:44-46` |
| ddc_dp | `daddr_reg/ddata_reg` | 64 位地址/数据寄存器，`ct_had_ddc_dp.v:49-50` |
| ddc_dp→regs | `ddc_regs_ir/wbbr/ffy/daddr/ddata` | 合成指令 / 搬运值 / ffy 位，`:42-46` |

---

## 3. 参数与关键信号

`ct_had_ddc_ctrl` 的状态机有 9 个状态（`ct_had_ddc_ctrl.v:78-86`），见 §9。`ct_had_ddc_dp` 参数 `DATAW=64`、`ADDRW=PA_WIDTH`（`ct_had_ddc_dp.v:71-72`）。

HCR 中与 ctrl 相关的字段（`ct_had_regs.v:880-896`）：

| 字段 | 信号 | 含义 |
|------|------|------|
| HCR.ADR (`hcr[21]`) | `regs_ctrl_adr` | 异步调试请求 |
| HCR.DDCEN (`hcr[20]`) | `regs_xx_ddc_en` | DDC 使能 |
| HCR.SQC (`hcr[17:16]`) | `regs_ctrl_sqc[1:0]` | 顺序限定 |
| HCR.DR (`hcr[15]`) | `regs_ctrl_dr` | 同步调试请求 |
| HCR.TME (`hcr[13]`) | `regs_ctrl_tme` | trace 模式使能 |
| HCR.FRZC (`hcr[12]`) | `regs_ctrl_frzc` | 冻结 PCFIFO |
| CPUSCR.CSR.FDB | `regs_ctrl_fdb` | 内存断点总使能（fdb）|

---

## 4. 进入 debug：四类停核请求

RTL 注释把停核请求分成三大类（`ct_had_ctrl.v:448-453`），加上 non-IRV 实际是四类：

### 4.1 异步请求 jdbreq

```verilog
assign async_dbg_req     = adr_set_req && !rtu_yy_xx_dbgon;   // :553
assign had_rtu_xx_jdbreq = async_dbg_req;                     // :487
```

调试器随时按下"暂停"——HCR.ADR（`regs_ctrl_adr`，`:471`）置位即产生异步请求。它会立刻更新 HSR.adro（`:551`）。

### 4.2 同步请求 hw_dbgreq（DR / sdb）

```verilog
assign sdb_req = !biu_had_sdb_req_b;                          // :473
assign had_rtu_hw_dbgreq = (dr_set_req || sdb_req) && !rtu_yy_xx_dbgon;  // :476
```

HCR.DR 置位（打一拍成 `dr_set_req`，`:463-469`）或总线 sdb 请求触发，是"在安全指令边界停"的同步请求。

### 4.3 断点 / trace 请求

```verilog
assign inst_bkpt_dbgreq = (mem_bkpta_inst_req || mem_bkptb_inst_req) && regs_ctrl_fdb && !rtu_yy_xx_dbgon;  // :481
assign had_rtu_inst_bkpt_dbgreq = (mem_bkpta_inst_req_raw || mem_bkptb_inst_req_raw) && regs_ctrl_fdb && !rtu_yy_xx_dbgon;  // :507
assign had_rtu_data_bkpt_dbgreq = (mem_bkpta_data_req_raw || mem_bkptb_data_req_raw) && regs_ctrl_fdb && !rtu_yy_xx_dbgon;  // :508
assign had_rtu_trace_dbgreq = trace_req && !rtu_yy_xx_dbgon;  // :484
```

注意断点请求都用 **raw 版**（`:501-505` 把 `*_raw` 与 SQC/FRZC 过滤后给 RTU），且都要 `regs_ctrl_fdb`（fdb 是内存断点总开关）。`02_had_breakpoint.md §8` 解释了为什么用 raw。

### 4.4 跨核事件 / non-IRV

```verilog
assign had_rtu_event_dbgreq    = event_req && !rtu_yy_xx_dbgon;   // :499（event_req 打一拍 :491-497）
assign had_rtu_non_irv_bkpt_dbgreq = non_irv_bkpt_vld && !rtu_yy_xx_dbgon;  // :510
```

`had_rtu_dbg_req_en`（`:536-539`）在"可能有新请求"时让 RTU 进入单步退休模式并屏蔽会被 flush 的请求；`had_rtu_pop1_disa`（`:531-532`）在 trace/断点使能时禁止 RTU 双发退休，保证逐条停核精度。

---

## 5. SQC 顺序限定与断点/trace 使能

SQC（Sequence Condition，顺序限定，HCR[17:16]）让 A/B 断点和 trace 形成**触发链**：必须前一个先命中，后一个才使能。

### 5.1 断点 A/B 使能

```verilog
assign ctrl_bkpta_en = |regs_xx_bca[4:0];                 // :356 (BCA 非零即使能)
assign bkptb_en      = |regs_xx_bcb[4:0];                 // :369

assign bkptb_sqc_en = !regs_ctrl_sqc[1]                                       // sqc[1]=0：无约束
                   ||  regs_ctrl_sqc[1] && rtu_yy_xx_retire0_normal
                       && !inst_bkpt_dbgreq && (bkpta_ctrl_inst_req || bkpta_ctrl_data_req)  // 必须 A 先命中
                   ||  regs_ctrl_sqa;                                          // 或 A 已经发生过(sticky)
                                                                              // :371-374
```

含义（注释 `:363-368`）：SQC[1]=1 时，**断点 B 在断点 A 命中之前不会使能**。这样能表达"先到 A 点、再到 B 点才停"的顺序断点。`regs_ctrl_sqa`（HSR.sqa，sticky）记住 A 已经发生过。

### 5.2 trace 使能

```verilog
assign trace_sqc_en = !regs_ctrl_sqc[0]
                   ||  regs_ctrl_sqc[0] && rtu_yy_xx_retire0_normal
                       && !inst_bkpt_dbgreq && (bkptb_ctrl_inst_req || bkptb_ctrl_data_req)  // B 先命中
                   ||  regs_ctrl_sqb;                                          // :399-402
```

对称地，SQC[0]=1 时 **trace 在断点 B 命中之前不使能**（注释 `:393-397`）。于是 SQC 串起一条 `A → B → trace` 的触发链。

`ctrl_bkptb_en`/`ctrl_trace_en` 都打一拍后输出（`:377-385`、`:404-412`）。

---

## 6. 指令注入：go / WBBR 回写

### 6.1 go：执行一条注入指令

进入 debug 后，调试器把一条 32 位指令写进 IR 寄存器（`ct_had_regs.v:578-590`，输出 `had_ifu_ir`），再通过 HACR 的 go 位（不带 ex）触发执行：

```verilog
assign go_noex = !x_ir_xx_ex && x_ir_xx_go
              && x_sm_xx_update_dr_en && ir_xx_ir_reg_sel   // 写 IR 寄存器这次更新是个脉冲
              && rtu_yy_xx_dbgon;                            // 必须已在 debug      :638-640

assign go_in_dbg = go_noex || ddc_inst_go;                  // :646
always @(...) ctrl_go_noex <= go_in_dbg;                    // :648-654（打一拍）
assign had_ifu_ir_vld = ctrl_go_noex;                       // :656
```

`had_ifu_ir_vld` 置 1 时，IFU 不从内存取指，而是执行 IR 寄存器里这条指令，执行完又停回 debug。这正是"借指令窥探/修改"的注入动作。

### 6.2 WBBR 回写：取回窥探结果

注入的指令把目标值搬到 WBBR（Write-Back Bus Register）。WBBR 的写源有三个（`ct_had_regs.v:547-559`）：

```verilog
else if (sm_xx_update_dr_en && ir_xx_wbbr_reg_sel)  wbbr_reg <= ir_xx_wdata;      // 调试器写入
else if (ddc_regs_update_wbbr)                      wbbr_reg <= ddc_regs_wbbr;    // DDC 写入
else if (idu_had_wb_vld)                            wbbr_reg <= idu_had_wb_data;  // CPU 执行结果回写
```

第三条 `idu_had_wb_vld` 就是"注入的指令执行后，结果回到 WBBR"。回写阀门由 `had_idu_wbbr_vld = ffy && rtu_yy_xx_dbgon`（`ct_had_regs.v:869`）控制：CSR 的 ffy 位决定这次注入是否要把结果送回 WBBR。调试器随后用 JTAG 把 WBBR 移出（`regs_data_out` 经 serial→tdo，`ct_had_regs.v:956`）。

---

## 7. 退出 debug：exit / pcload

```verilog
assign exit_dbg_active = x_ir_xx_ex && x_ir_xx_go
                      && x_sm_xx_update_dr_en && ir_ctrl_exit_dbg_reg
                      && rtu_yy_xx_dbgon;                  // :609-611
assign exit_dbg = exit_dbg_active || event_ctrl_exit_dbg && rtu_yy_xx_dbgon;  // :613

always @(...) ctrl_exit_dbg <= exit_dbg;                   // :615-621（打一拍）
assign ctrl_regs_exit_dbg = ctrl_exit_dbg;                // :623（清 HSR sticky 位）
assign had_yy_xx_exit_dbg = ctrl_exit_dbg;                // :625（通知 RTU 退出）
assign had_ifu_pcload     = ctrl_exit_dbg;                // :627（IFU 从 CPUSCR.PC 重新取指）
```

退出条件：HACR 同时给 go+ex，且选中可退出寄存器（`ir_ctrl_exit_dbg_reg`），且当前在 debug。也可由跨核 `event_ctrl_exit_dbg` 触发（halt-all 的对称：一起退）。`had_ifu_pcload` 让 IFU 从 CPUSCR 的 PC（`pc_reg`，`ct_had_regs.v:862`）重新取指，回到用户程序——这就是四步法的"恢复"。`ctrl_regs_exit_dbg` 同时把 HSR 里所有 sticky 进入原因位清掉（`ct_had_regs.v` 各 `ctrl_regs_exit_dbg` 分支）。

---

## 8. HSR 状态位更新

ctrl 在合适时机给 regs 发脉冲，记录"为什么进 debug"（这些位在 HSR 里是 sticky，退出时清；详见 `05_had_regs.md`）：

| HSR 位 | 触发脉冲 | 条件（行号）|
|--------|----------|-------------|
| adro（异步）| `ctrl_regs_update_adro` | `async_dbg_req`，`:551` |
| dro（DR 同步）| `ctrl_regs_update_dro` | `dr_set_req && !dbgon`，`:556` |
| mbo（内存断点）| `ctrl_regs_update_mbo` | 断点 ack 且 fdb，或 non-IRV，`:559-562` |
| swo（软件断点指令）| `ctrl_regs_update_swo` | bkpt 指令退休，mbkpt 优先级更高时不置，`:574-577` |
| to（trace）| `ctrl_regs_update_to` | `trace_req`，mbkpt 优先时不置，`:581` |
| frzo（冻结 pcfifo）| `ctrl_regs_freeze_pcfifo` | bkptB 命中且 FRZC，`:584-585` |
| sqb / sqa | `ctrl_regs_set_sqb/sqa` | bkptB/A 命中且 SQC 对应位，`:588-593` |
| pro（被动请求）| `ctrl_regs_update_pro` | `event_req`，`:596` |
| bkpta/b_vld（MBIR）| `ctrl_regs_bkpta/b_vld` | 哪个断点命中，`:564-569` |

注意优先级处理：`ctrl_regs_update_swo` 和 `ctrl_regs_update_to` 都带 `!ctrl_regs_update_mbo`（`:576,:581`）——**内存断点优先级高于软件断点和 trace**（注释 `:572,:580`）。

---

## 9. DDC 调试数据通道（搬内存）

要读写内存，传统做法是调试器逐条注入 `mv`/`sd` 指令。DDC 把这套**自动化成一个状态机**：调试器只扫入"起始地址 + 一串数据"，硬件循环合成搬运指令。

### 9.1 状态机（9 态）

`ct_had_ddc_ctrl.v:78-145`，状态定义与转移：

```
IDLE        : DDCEN=1 → ADDR_WATI                         (:106-110)
ADDR_WATI   : 等调试器扫入地址(addr_ready) → ADDR_LD       (:111-115)
ADDR_LD     : 合成 "mv x1,x1" 到 IR，并把地址送 WBBR、置 ffy → DATA_WAIT  (:116-117)
DATA_WAIT   : 地址装载完成且数据就绪 → DATA_LD；可重装地址；DDCEN=0 → IDLE  (:118-126)
DATA_LD     : 合成 "mv x2,x2" 到 IR，数据送 WBBR、置 ffy → STW_WAIT       (:127-128)
STW_WAIT    : 等 "mv x2,x2" 退休(data_ld_finish) → STW_LD                (:129-133)
STW_LD      : 合成 "sd x2,0(x1)" 到 IR → STW_FINISH                      (:134-135)
STW_FINISH  : 等 sd 退休(stw_inst_retire) → ADDR_GEN                     (:136-140)
ADDR_GEN    : 地址 +8，回 ADDR_LD（循环搬下一个 8 字节）                  (:141-142)
```

`addr_ready`/`data_ready` 来自调试器对 DADDR/DDATA 寄存器的 Update-DR（`:149-150`）；FSM 推进靠合成指令的 `rtu_yy_xx_retire0_normal`（`:157-171`）。

### 9.2 数据通路：地址/数据寄存器 + 指令合成

`ct_had_ddc_dp.v`：

```verilog
// 地址寄存器：扫入 or 自增 8
always @(posedge cpuclk)
  if (x_sm_xx_update_dr_en && ir_xx_daddr_reg_sel) daddr_reg <= ir_xx_wdata;   // 调试器扫入  :90-91
  else if (ddc_ctrl_dp_addr_gen)                   daddr_reg <= daddr_reg + 64'b1000;  // +8  :92-93

// 送 WBBR：addr 阶段送地址，否则送数据
assign ddc_regs_wbbr = ddc_ctrl_dp_addr_sel ? {24'b0,daddr_reg[ADDRW-1:0]} : ddata_reg;  // :101-102

// 合成指令送 IR
assign ddc_regs_ir = ddc_ctrl_dp_addr_sel ? 32'h00008093                       // mv x1, x1  :105-106
                   : ddc_ctrl_dp_data_sel  ? 32'h00010113                       // mv x2, x2  :107
                                           : 32'h0020b023;                      // sd x2,0(x1) :108
assign ddc_regs_ffy = ddc_ctrl_dp_addr_sel || ddc_ctrl_dp_data_sel;            // :110
```

机制解读：
- **ADDR_LD**：把扫入的地址放进 WBBR，注入 `mv x1,x1`（且 ffy=1），CPU 执行后把 WBBR（=地址）写进 x1。
- **DATA_LD**：把数据放进 WBBR，注入 `mv x2,x2`，CPU 把数据写进 x2。
- **STW_LD**：注入 `sd x2,0(x1)`，把 x2（数据）存到 x1（地址）指向的内存——一次 8 字节写完成。
- **ADDR_GEN**：地址 +8，循环回 ADDR_LD 搬下一个字。

每个 DDC 合成指令的注入复用 `ct_had_ctrl` 的 go 通道：`ddc_inst_go = regs_xx_ddc_en && ddc_xx_update_ir && rtu_yy_xx_dbgon`（`ct_had_ctrl.v:642-644`），和普通 go 一起经 `go_in_dbg`（`:646`）触发 `had_ifu_ir_vld`。WBBR/IR/CSR 的更新也走 DDC 专用通道（`ct_had_regs.v:553`,`584`,`603`）。

> 注：这里的 `mv x1,x1`/`mv x2,x2` 是配合 WBBR 回写机制的"把 WBBR 写进目标寄存器"的注入指令编码；`sd x2,0(x1)` 完成实际的内存写。读内存时序对称（用 load 把内存搬进 WBBR 再移出），由调试器配合 DADDR/DDATA 协议驱动。

### 9.3 为什么 DDC 值得做成硬件

块搬内存（dump 一段内存、灌一段代码）动辄上千字节。逐条手工注入意味着每 8 字节都要 JTAG 来回握手 3 次（mv/mv/sd），延迟巨大。DDC 把"地址自增 + 合成指令 + 等退休"做成硬件状态机后，调试器只需连续扫入数据流，吞吐大幅提升。这正是 v2.3 把 DDC 写进 ID 能力位（`id_reg[16]=1`，`ct_had_regs.v:418`）的原因。

---

## 10. debug-disable 与时钟门控

### 10.1 debug-disable

```verilog
always @(posedge forever_coreclk ...) ctrl_out_dbg_disable <= x_had_dbg_mask;  // :675-681
assign ctrl_xx_dbg_disable = ctrl_tee_dbg_disable || ctrl_out_dbg_disable;     // :683
assign had_rtu_dbg_disable = ctrl_xx_dbg_disable;                             // :687
```

`x_had_dbg_mask` 来自共用侧 DMS 寄存器（`sysio_had_dbg_mask`，`ct_had_common_regs.v:166-169`），允许系统级把某核的调试整体关闭（安全/量产场景）。本配置中 TEE 的 `ctrl_tee_dbg_disable` 接 0（`:667`）。被 disable 时所有停核请求不会唤醒 CPU（`had_cp0_xx_dbg` 末项 `&& !ctrl_xx_dbg_disable`，`:522`）。

### 10.2 顶层 ICG

```verilog
assign had_clk_en = ir_ctrl_had_clk_en | event_ctrl_had_clk_en;   // :693
always @(...) // had_clk_en_ff：有事置 1，PM=11(全空闲)才清          :695-703
assign had_xx_clk_en = had_clk_en | had_clk_en_ff;                // :704
```

HAD 绝大多数时间空闲，时钟门控贯穿全模块。只有 JTAG 有动作或跨核事件来时才开时钟；当 PM 指示 CPU 完全空闲（`regs_ctrl_pm==2'b11`）才关回。

---

## 设计取舍小结

| 决策 | 内容 | 出处 | 为什么 |
|------|------|------|--------|
| 四类停核请求统一汇聚 | jdbreq/hw/bkpt/trace/event/non-IRV | `ct_had_ctrl.v:476-510` | 不同来源、统一接口送 RTU，RTU 只需一套停核机制 |
| 断点请求用 raw 路径 | `*_raw` 组合早一拍送 RTU | `:507-508` | RTU 越早收到越能精确在指令边界停 |
| SQC 触发链 | A→B→trace 顺序限定 | `:371-374,:399-402` | 表达"先 A 后 B 再 trace"复杂断点 |
| 内存断点优先于软件断点/trace | swo/to 带 `!update_mbo` | `:576,:581` | 同周期多事件时给出确定优先级 |
| go/ex 复用 HACR 位 | go=注入执行，go+ex=退出 | `:638,:609` | 一个 IR 编码覆盖注入与退出，协议简洁 |
| WBBR 三写源 | 调试器/DDC/CPU 回写 | `ct_had_regs.v:547-559` | 一个寄存器同时服务"写入参数"与"取回结果" |
| DDC 硬件搬内存 | 9 态 FSM 合成 mv/mv/sd，地址 +8 循环 | `ct_had_ddc_ctrl.v:78-145`,`ct_had_ddc_dp.v:92-108` | 块搬运免去逐条 JTAG 握手，吞吐高 |
| debug-disable | DMS 掩码可整体关核调试 | `ct_had_ctrl.v:675-687` | 安全/量产场景禁用调试 |
| 顶层 ICG | 空闲不翻转，PM=11 才关 | `ct_had_ctrl.v:693-704` | 调试单元长期空闲，省功耗 |

---

## 覆盖声明

本篇覆盖 `ct_had_ctrl.v`（四类停核请求、SQC 顺序限定、go 注入、WBBR 回写、退出/pcload、HSR 状态更新、debug-disable、ICG）与 DDC 通道 `ct_had_ddc_ctrl.v`（9 态状态机）/`ct_had_ddc_dp.v`（地址自增、mv/mv/sd 指令合成）。所有状态名、指令编码、信号与行号均按 RTL 实读标注，未对行为虚构。断点请求的产生见 `02_had_breakpoint.md`，寄存器字段对齐见 `05_had_regs.md`。
