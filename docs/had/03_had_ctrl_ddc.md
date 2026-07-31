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
4. [进入 debug：请求生成与完成边界](#4-进入-debug请求生成与完成边界)
5. [SQC 顺序限定与断点/trace 使能](#5-sqc-顺序限定与断点trace-使能)
6. [指令注入：go / WBBR 回写](#6-指令注入go--wbbr-回写)
7. [退出 debug：exit / pcload](#7-退出-debugexit--pcload)
8. [HSR 状态位更新](#8-hsr-状态位更新)
9. [DDC 连续内存写入通道](#9-ddc-连续内存写入通道)
10. [debug-disable 与时钟门控](#10-debug-disable-与时钟门控)
11. [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 这一层做什么

`ct_had_ctrl` 是 HAD 私有侧的控制汇聚点。它接收断点、trace、event、HCR 和外部总线请求，生成送往 RTU/CP0/IFU/寄存器组的控制信号。把它教学性地归纳成“停核 → 注入 → 读写状态 → 恢复”有助于理解，但这四步并不是一个集中式四状态 FSM：进入 debug 的最终状态转换由 RTU 完成，注入指令也要经过 IFU、IDU、执行单元和退休链路。

1. 给各 HAD 功能模块（断点/trace/pcfifo/pipefifo）发使能与读写脉冲；
2. 向 RTU 发各类停核请求（`had_rtu_*_dbgreq`）；
3. 通知 HSR 更新对应状态位（mbo/swo/to/dro/adro…）；
4. 退出 debug 的逻辑（`had_yy_xx_exit_dbg` / `had_ifu_pcload`）。

`ct_had_ddc_ctrl` + `ct_had_ddc_dp` 实现 RTL 命名为 DDC 的数据写入通道。当前有效数据通路固定生成两条 `addi rd,rs1,0` 和一条 `sd x2,0(x1)`，把调试器写入的 DDATA 以 8 字节为单位存入从 DADDR 开始的连续地址。现有 RTL 没有 DDC load 指令、内存读回状态或双向流控制，所以只能称为**连续内存写入序列**，不能概括成通用双向“搬内存”引擎。

### 1.2 三者的协作

```
ct_had_bkpt/nirv/trace/event  ──(请求)──►  ct_had_ctrl ──► had_rtu_*_dbgreq ──► RTU 停核
                                              │
JTAG (go/ex via ir)  ─────────────────────────┤──► had_ifu_ir_vld（注入）/ had_ifu_pcload（恢复）
                                              │
ct_had_ddc_ctrl (FSM) ──(addr/data/stw sel)──┤──► ct_had_ddc_dp 合成 addi/addi/sd → IR/WBBR/FFY
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
| `had_rtu_non_irv_bkpt_dbgreq` | non-IRV 路径请求；仍需 RTU 接受并受 debug-disable 约束 | `:202` |
| `had_rtu_dbg_req_en` | 告知 RTU“可能出现新请求”，源码注释用于启用 single-retire 并屏蔽可能被 flush 的请求 | `:196` |
| `had_rtu_pop1_disa` | trace 或普通断点启用时限制多槽退休；具体退休控制在 RTU 实现 | `:203` |
| `had_rtu_xx_tme` | HCR.TME 的直通状态 | `:207` |
| `had_cp0_xx_dbg` | 汇总后的 CP0 debug 唤醒/活动请求，且在本地受 `!ctrl_xx_dbg_disable` 门控 | `:191` |

#### 注入 / 退出

| 信号 | 含义 | 行号 |
|------|------|------|
| `had_ifu_ir_vld` | 注入指令有效（go）| `:192` |
| `had_yy_xx_exit_dbg` | 退出 debug | `:209` |
| `had_ifu_pcload` | 退出时让 IFU 从 CPUSCR.PC 取指 | `:193` |
| `x_ir_xx_go` / `x_ir_xx_ex` | 当前本地 HACR 的 go/ex **电平**并经 `core_sel` 门控；真正事务脉冲还需 `x_sm_xx_update_dr_en` | `:111,:110` |
| `ir_ctrl_exit_dbg_reg` | 选中可退出寄存器 | `:81` |

#### HSR 更新脉冲（到 regs）

`ctrl_regs_update_{adro,dro,mbo,swo,to,pro}`、`ctrl_regs_set_sq{a,b}`、`ctrl_regs_bkpt{a,b}_vld`、`ctrl_regs_freeze_pcfifo`、`ctrl_regs_exit_dbg`（`:177-188`）。

### 2.2 ct_had_ddc_ctrl / ct_had_ddc_dp 端口

| 模块 | 信号 | 含义 |
|------|------|------|
| ddc_ctrl | `regs_xx_ddc_en` | HCR.DDCEN 使能，`ct_had_ddc_ctrl.v:38` |
| ddc_ctrl | `ir_xx_daddr_reg_sel` / `ir_xx_ddata_reg_sel` | JTAG 扫入地址/数据，`:36,:37` |
| ddc_ctrl | `rtu_yy_xx_retire0_normal` | retire0 正常退休电平；FSM 把它当作当前注入步骤完成条件，但接口没有携带指令身份标签，`:39` |
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

## 4. 进入 debug：请求生成与完成边界

RTL 注释沿用三类历史分法：异步 `jdbreq`、硬件同步 `hw_dbgreq`、memory/trace 同步请求。当前端口还单列 event 和 non-IRV。分类只是便于组织来源，不代表优先级，也不表示信号拉高时处理器已经停住。判断“进入 debug 完成”应继续观察 RTU 的 `rtu_had_dbgreq_ack` 和 `rtu_yy_xx_dbgon`。

### 4.1 异步请求 jdbreq

```verilog
assign async_dbg_req     = adr_set_req && !rtu_yy_xx_dbgon;   // :553
assign had_rtu_xx_jdbreq = async_dbg_req;                     // :487
```

HCR.ADR 经 `adr_set_req` 直接进入 `async_dbg_req`，只用 `!rtu_yy_xx_dbgon` 屏蔽。`ctrl_regs_update_adro` 同样直接取 `async_dbg_req`，所以 HSR.adro 记录的是“异步请求已经提出”，不是 RTU 已经确认停核。`had_rtu_xx_jdbreq` 名称中的“异步”描述其请求方式；准确停在哪个指令边界仍由 RTU 控制。

### 4.2 同步请求 hw_dbgreq（DR / sdb）

```verilog
assign sdb_req = !biu_had_sdb_req_b;                          // :473
assign had_rtu_hw_dbgreq = (dr_set_req || sdb_req) && !rtu_yy_xx_dbgon;  // :476
```

HCR.DR 先寄存为 `dr_set_req`，外部低有效 `biu_had_sdb_req_b` 则组合取反为 `sdb_req`；二者 OR 后产生 `had_rtu_hw_dbgreq`。本模块只提出同步请求，“安全指令边界”由 RTU 的退休/flush 条件实现，不能从这条组合赋值单独证明。

### 4.3 断点 / trace 请求

```verilog
assign inst_bkpt_dbgreq = (mem_bkpta_inst_req || mem_bkptb_inst_req) && regs_ctrl_fdb && !rtu_yy_xx_dbgon;  // :481
assign had_rtu_inst_bkpt_dbgreq = (mem_bkpta_inst_req_raw || mem_bkptb_inst_req_raw) && regs_ctrl_fdb && !rtu_yy_xx_dbgon;  // :507
assign had_rtu_data_bkpt_dbgreq = (mem_bkpta_data_req_raw || mem_bkptb_data_req_raw) && regs_ctrl_fdb && !rtu_yy_xx_dbgon;  // :508
assign had_rtu_trace_dbgreq = trace_req && !rtu_yy_xx_dbgon;  // :484
```

送 RTU 的 inst/data breakpoint 信号使用 raw 版；内部 `inst_bkpt_dbgreq/data_bkpt_dbgreq` 则使用寄存版，并参与 PCFIFO、状态更新和 CP0 请求。A 请求在 SQC[1]=1 时被抑制为最终停核而用于解锁 B；B 请求在 SQC[0]=1 或 FRZC=1 时被抑制为最终停核而用于解锁 trace/冻结 PCFIFO。两条路径都受 `regs_ctrl_fdb` 和 `!dbgon` 门控。

### 4.4 跨核事件 / non-IRV

```verilog
assign had_rtu_event_dbgreq    = event_req && !rtu_yy_xx_dbgon;   // :499（event_req 打一拍 :491-497）
assign had_rtu_non_irv_bkpt_dbgreq = non_irv_bkpt_vld && !rtu_yy_xx_dbgon;  // :510
```

`had_rtu_dbg_req_en` 只 OR 了 DR、ADR、event-enter 和 `non_irv_bkpt_vld`，没有把所有 raw breakpoint/trace 信号都列入；它是对 RTU 的模式提示，不是“任意 debug 请求有效”的总 OR。`had_rtu_pop1_disa` 在 TME 或 NIRVEN=0 且 A/B 普通断点配置非零时有效。源码注释称其使 RTU one-by-one retire；具体如何限制第二、第三退休槽要在 RTU 侧验证，不能只按信号名理解成简单“禁双发”。

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

SQC[1]=1 时，A 的普通停核请求被 `mem_bkpta_*_req = ... && !SQC[1]` 抑制；但 A 的合格请求可以在正常 retire0 条件下置位 `sqa`，并使 `bkptb_sqc_en` 成立。换言之，A 在这种模式下主要充当“第一阶段触发器”，B 才是下一阶段。`ctrl_bkptb_en` 是寄存输出，`ctrl_bkptb_en_raw` 是同拍组合输出，波形上会相差一个寄存级。

### 5.2 trace 使能

```verilog
assign trace_sqc_en = !regs_ctrl_sqc[0]
                   ||  regs_ctrl_sqc[0] && rtu_yy_xx_retire0_normal
                       && !inst_bkpt_dbgreq && (bkptb_ctrl_inst_req || bkptb_ctrl_data_req)  // B 先命中
                   ||  regs_ctrl_sqb;                                          // :399-402
```

SQC[0]=1 时，B 的普通停核请求被抑制，并在合格命中后置位 `sqb`，进而使 trace 有效。只有相应 SQC 位和各功能 enable 同时配置时，才能形成教学上所说的 `A → B → trace` 链；SQC 两位不是一个自动按阶段前进的独立 FSM，而是借助 HSR sticky 位保存“前置条件已发生”。

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

`had_ifu_ir_vld` 是一拍注入有效请求，指令内容来自 `had_ifu_ir`。本模块没有“执行完成”输入，也没有在 `ctrl_go_noex` 中等待退休；完成与重新保持 debug 的行为分布在 IFU/RTU。因而看波形时应串联：

```text
x_sm_xx_update_dr_en && IR selected && go && !ex && dbgon
    -> go_noex
    -> 下一拍 ctrl_go_noex / had_ifu_ir_vld
    -> IFU debug instruction path
    -> IDU/执行/写回/RTU retirement
```

不能仅看到 `had_ifu_ir_vld` 就认为指令已执行完毕。

### 6.2 WBBR 回写：取回窥探结果

WBBR 是 HAD 与整数数据通路之间的 64 位交换寄存器。它既可作为注入指令的源操作数，也可接收 CPU 数据通路的回传值。它的三个写源有明确优先级：

```verilog
else if (sm_xx_update_dr_en && ir_xx_wbbr_reg_sel)  wbbr_reg <= ir_xx_wdata;      // 调试器写入
else if (ddc_regs_update_wbbr)                      wbbr_reg <= ddc_regs_wbbr;    // DDC 写入
else if (idu_had_wb_vld)                            wbbr_reg <= idu_had_wb_data;  // CPU 执行结果回写
```

`had_idu_wbbr_vld = ffy && dbgon` 实际表示 **IDU 的 pipe0 source0 改用 WBBR 数据**：`ct_idu_rf_dp.v:2232-2234` 在该信号有效时用 `had_idu_wbbr_data` 替代 PRF source0。它不是“允许结果写回 WBBR”的阀门；结果回 WBBR使用相反方向的 `idu_had_wb_vld/data`。这个双向机制解释了 DDC 为何能用编码上看似 `addi x1,x1,0` 的指令把 WBBR 内容装入 x1：指令的 source0 被 WBBR 覆盖，执行结果再写入目标物理寄存器。

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

主动退出要求 go、ex、Update-DR 写脉冲、退出类寄存器选择和当前 dbgon 同时满足；event 退出只要求 `event_ctrl_exit_dbg && dbgon`。组合 `exit_dbg` 先寄存为 `ctrl_exit_dbg`，下一拍同时驱动寄存器清理、RTU 退出通知和 IFU PC load。`had_ifu_pcload` 表示请求 IFU装载 HAD 保存的 PC；“已经恢复用户程序”还需观察 IFU 接受、后续取指及 `dbgon` 清除。

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

## 9. DDC 连续内存写入通道

DDC 把“DADDR 装入 x1、DDATA 装入 x2、执行 64 位 store、地址加 8”固化成状态机。调试器先写起始 DADDR，再按协议提供 DDATA。当前 RTL只实现写方向，不包含 load-to-DDATA/readback 对称流程。

### 9.1 状态机（9 态）

`ct_had_ddc_ctrl.v:78-145`，状态定义与转移：

```
IDLE        : DDCEN=1 → ADDR_WATI                         (:106-110)
ADDR_WATI   : 等调试器扫入地址(addr_ready) → ADDR_LD       (:111-115)
ADDR_LD     : 合成 addi x1,x1,0，把地址送 WBBR、置 FFY → DATA_WAIT         (:116-117)
DATA_WAIT   : 地址装载完成且数据就绪 → DATA_LD；可重装地址；DDCEN=0 → IDLE  (:118-126)
DATA_LD     : 合成 addi x2,x2,0，数据送 WBBR、置 FFY → STW_WAIT           (:127-128)
STW_WAIT    : 等任一 retire0_normal，被协议解释为 data-load 完成 → STW_LD (:129-133)
STW_LD      : 合成 "sd x2,0(x1)" 到 IR → STW_FINISH                      (:134-135)
STW_FINISH  : 等 sd 退休(stw_inst_retire) → ADDR_GEN                     (:136-140)
ADDR_GEN    : 地址 +8，回 ADDR_LD（循环搬下一个 8 字节）                  (:141-142)
```

`ADDR_WATI` 是源码中的实际状态名拼写，语义是 `ADDR_WAIT`。`addr_ready/data_ready` 是对应寄存器的 Update-DR 写脉冲。FSM 没有注入指令 IID 或 opcode 回传，`addr_ld_finish`、`data_ld_finish`、`stw_inst_retire` 都只观察通用 `rtu_yy_xx_retire0_normal`；其正确性依赖 debug 注入协议保证等待期间退休的正是预期指令。

DDCEN 的撤销也不是全状态异步终止：只有 IDLE/DATA_WAIT 分支检查它。若在 ADDR_LD、STW_WAIT 或 STW_FINISH 中清 DDCEN，FSM 仍按当前转移/退休条件继续，可能直到回到 DATA_WAIT 才退出。软件应在稳定等待点改变 DDCEN。

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
assign ddc_regs_ir = ddc_ctrl_dp_addr_sel ? 32'h00008093                       // addi x1,x1,0 :105-106
                   : ddc_ctrl_dp_data_sel  ? 32'h00010113                       // addi x2,x2,0 :107
                                           : 32'h0020b023;                      // sd x2,0(x1) :108
assign ddc_regs_ffy = ddc_ctrl_dp_addr_sel || ddc_ctrl_dp_data_sel;            // :110
```

机制解读：
- **ADDR_LD**：把 DADDR 的低 `PA_WIDTH` 位零扩展到 WBBR；当前 `PA_WIDTH=40`，故 RTL 写成 `{24'b0,daddr_reg[39:0]}`。FFY=1 使 IDU pipe0 source0 取 WBBR，`addi x1,x1,0` 的结果于是把地址装入 x1。
- **DATA_LD**：把 DDATA 放进 WBBR并同样置 FFY，`addi x2,x2,0` 把数据装入 x2。
- **STW_LD**：注入 `sd x2,0(x1)`，把 x2（数据）存到 x1（地址）指向的内存——一次 8 字节写完成。
- **ADDR_GEN**：地址 +8，循环回 ADDR_LD 搬下一个字。

每个 DDC 合成指令的注入复用 `ct_had_ctrl` 的 go 通道：`ddc_inst_go = regs_xx_ddc_en && ddc_xx_update_ir && rtu_yy_xx_dbgon`（`ct_had_ctrl.v:642-644`），和普通 go 一起经 `go_in_dbg`（`:646`）触发 `had_ifu_ir_vld`。WBBR/IR/CSR 的更新也走 DDC 专用通道（`ct_had_regs.v:553`,`584`,`603`）。

> `mv` 是 `addi rd,rs,0` 的汇编伪指令。这里必须保留“编码指令”和“实际数据来源”的区别：编码中的 rs1 是 x1/x2，但 FFY 使 source0 由 WBBR 覆盖。当前 RTL没有生成 load 的分支，不能推导出对称读内存协议。

### 9.3 为什么 DDC 值得做成硬件

从体系结构意图看，硬化地址自增、IR/WBBR/CSR 更新和退休等待，可以减少调试器逐项组织注入事务的控制负担，适合连续灌入代码或数据。RTL 能确认 `id_reg[16]=1`、固定三指令序列和 +8 循环；“具体减少多少 JTAG 往返、吞吐提升多少”需要协议级实测，不能从状态数直接给出数值结论，也不能把它扩展成 dump 内存功能。

---

## 10. debug-disable 与时钟门控

### 10.1 debug-disable

```verilog
always @(posedge forever_coreclk ...) ctrl_out_dbg_disable <= x_had_dbg_mask;  // :675-681
assign ctrl_xx_dbg_disable = ctrl_tee_dbg_disable || ctrl_out_dbg_disable;     // :683
assign had_rtu_dbg_disable = ctrl_xx_dbg_disable;                             // :687
```

`x_had_dbg_mask` 在 `forever_coreclk` 上采样成 `ctrl_out_dbg_disable`，再与当前固定为 0 的 `ctrl_tee_dbg_disable` 合并。本地明确受 disable 门控的是 `had_cp0_xx_dbg`，同时 `had_rtu_dbg_disable` 把禁用状态送给 RTU；各个 `had_rtu_*_dbgreq` 输出本身并非全部在 `ct_had_ctrl` 内直接与 disable 相与。因此正确判断是“请求可能仍在 HAD→RTU 接口出现，但 RTU 同时收到禁止标志”，而不是“所有请求信号都变成 0”。私有 IR 的 Update 动作也在 `ct_had_private_ir` 中被 `ctrl_xx_dbg_disable` 屏蔽。

### 10.2 顶层 ICG

```verilog
assign had_clk_en = ir_ctrl_had_clk_en | event_ctrl_had_clk_en;   // :693
always @(...) // had_clk_en_ff：有事置 1，PM=11(reset-on)才清       :695-703
assign had_xx_clk_en = had_clk_en | had_clk_en_ff;                // :704
```

`had_clk_en_ff` 是一个粘滞保持位：IR/DR raw 同步活动或 event 活动会置 1；只有当前无新活动且 `regs_ctrl_pm==2'b11` 时清 0。`PM=11` 在现行寄存器逻辑中只由复位或 `ifu_had_reset_on` 产生，普通 pipeline idle 是 HSR.PS，而不会清这个 sticky。因此它可能在首次调试活动后长期保持，不能理解为“事务结束或 CPU 空闲就关 HAD 时钟”。`had_xx_clk_en` 只是顶层门控请求；默认行为级 `gated_clk_cell` 可能直通时钟，真实物理门控和功耗效果取决于工艺宏/编译配置。

## 本章小结

HAD 控制层把调试器写入的 HACR 电平、Update-DR 事件、断点、trace、event、non-IRV 请求和 RTU 确认组织成一条有明确边界的调试生命周期。HACR 表达持续控制意图，Update-DR 提供一次事务脉冲，控制器据此分别形成 jdbreq、硬件请求、断点、trace、event 和 non-IRV 接口；其中断点使用 raw 组合路径尽早通知 RTU。SQC 可以把 A、B 和 trace 组织为顺序触发链，同周期出现多类事件时，内存断点相关更新又通过 `!update_mbo` 条件优先于软件断点和 trace 状态更新。`go` 表示请求注入执行，`go+ex` 表示退出请求，但只有 RTU 接受后，处理器才真正进入可安全注入、交换状态或恢复执行的阶段。

WBBR 同时接收调试器写入、DDC 写入和 CPU 回写，FFY 打开时则在 IDU RF 级把 WBBR 数据覆盖到 source0。DDC 的九态状态机通过 WBBR 依次准备地址和数据，注入 `addi/addi/sd` 序列，并在每次 64 位 store 后把地址增加 8；当前 RTL 没有对应 load/readback 状态，因此它是连续写内存通道，不是双向 DMA。外部 `x_had_dbg_mask` 经 coreclk 采样后形成 debug-disable，并分别送往 CP0、RTU 和私有 IR 门控；请求接口本身不一定全部在 HAD 内被直接拉低，所以必须与 RTU 的 disable 输入合看。IR/DR 或 event 活动还会置位顶层时钟请求的 sticky 状态，普通 pipeline idle 不会清除它，只有 PM=11 的 reset-on 状态才清零；物理门控效果仍由 `gated_clk_cell` 实现决定。将请求、优先级、确认、寄存器方向和注入指令按时间顺序连接起来，能够避免把任一控制位误当成已经完成的调试动作。
