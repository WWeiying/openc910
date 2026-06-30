# C910 PMU 计数器与溢出 模块详细教学文档

> RTL 文件：
> - `C910_RTL_FACTORY/gen_rtl/pmu/rtl/ct_hpcp_cnt.v`（153 行）—— 单个 64 位计数器
> - `C910_RTL_FACTORY/gen_rtl/pmu/rtl/ct_hpcp_cntof_reg.v`（63 行）—— 单 bit 溢出标志位 `cntof[x]`
> - `C910_RTL_FACTORY/gen_rtl/pmu/rtl/ct_hpcp_cntinten_reg.v`（57 行）—— 单 bit 溢出中断使能位 `cntinten[x]`
> - 计数器的使能 / 抑制 / 特权过滤逻辑位于 `ct_hpcp_top.v`，本文一并讲解

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键寄存器](#3-参数与关键寄存器)
4. [64 位计数器主体（ct_hpcp_cnt）](#4-64-位计数器主体ct_hpcp_cnt)
5. [溢出检测与单拍脉冲（cnt_overflow）](#5-溢出检测与单拍脉冲cnt_overflow)
6. [计数器使能链：mcountinhibit / cnt_mask / 事件号](#6-计数器使能链mcountinhibit--cnt_mask--事件号)
7. [特权过滤 PMDM/PMDS/PMDU（cnt_mode_dis）](#7-特权过滤-pmdmpmdspmducnt_mode_dis)
8. [溢出标志寄存器 mcntof（ct_hpcp_cntof_reg）](#8-溢出标志寄存器-mcntofct_hpcp_cntof_reg)
9. [溢出中断使能 mcntinten（ct_hpcp_cntinten_reg）与中断生成](#9-溢出中断使能-mcntintenct_hpcp_cntinten_reg与中断生成)
10. [固定 2 + 可编程 16 的计数器编制](#10-固定-2--可编程-16-的计数器编制)
11. [门控时钟](#11-门控时钟)
12. [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

### 1.1 职责

PMU 真正"数数"的地方就是计数器。C910 实现了 **18 个 64 位计数器**：

- **2 个固定计数器**：`mcycle`（周期数）、`minstret`（退休指令数）；
- **16 个可编程计数器**：`mhpmcnt3`~`mhpmcnt18`，各自计数一种由 `mhpmeventN` 选定的事件。

虽然 RISC-V 体系结构定义了 HPM3~HPM31 共 29 个可编程槽位，但 C910 只**物理实现到 HPM18**（`ct_hpcp_top.v:1300~1315`、计数器例化到 `x_hpcp_mhpmcnt18`，`ct_hpcp_top.v:4010`）。HPM19~31 的 CSR 地址虽有参数定义，但例化部分被 `//&Instance` 注释掉（`ct_hpcp_top.v:4026~4051`），读回为 0。

每个计数器对应三个并列的 1 bit 状态位，分布在三个独立的微模块里：

| 微模块 | 作用 | 对应 CSR 位 |
|--------|------|------------|
| `ct_hpcp_cnt` | 64 位计数主体 + 溢出脉冲 | mcycle/minstret/mhpmcntN |
| `ct_hpcp_cntof_reg` | 该计数器是否已溢出（sticky） | mcntof[x]/scntof[x] |
| `ct_hpcp_cntinten_reg` | 该计数器溢出时是否产生中断 | mcntinten[x]/scntinten[x] |

### 1.2 设计要点

- **统一 64 位 + 4 位增量**：所有计数器都是 64 位，每拍可加 0~8（4 位增量），见 `02_hpcp_events.md`。
- **溢出 sticky + 单拍脉冲**：计数器内部产生一拍宽的进位脉冲 `cnt_of`，外部的 `cntof_reg` 把它锁存成 sticky 标志，是溢出中断"采样剖析"的基石。
- **多级使能门控**：debug、特权过滤、`mcountinhibit`、软件 mask、事件号非 0，全部串进每个计数器的使能，缺一不数。

---

## 2. 端口说明

### 2.1 ct_hpcp_cnt 端口（`ct_hpcp_cnt.v:17~44`）

| 端口名 | 方向 | 宽度 | 说明 |
|--------|------|------|------|
| `forever_cpuclk` | input | 1 | 自由运行时钟 |
| `cpurst_b` | input | 1 | 低有效复位 |
| `cp0_hpcp_icg_en` | input | 1 | 模块级门控使能 |
| `pad_yy_icg_scan_en` | input | 1 | DFT 扫描强开门控 |
| `cnt_clk_en` | input | 1 | 计数器局部门控使能 |
| `cnt_en` | input | 1 | 本计数器使能（含特权/inhibit/mask/事件号） |
| `hpcp_cnt_en` | input | 1 | 全局计数总开关（来自 TME/TS 状态机） |
| `cnt_adder[3:0]` | input | 4 | 本拍增量（来自 adder_sel 或固定值） |
| `cnt_wen` | input | 1 | CSR 写计数器使能 |
| `hpcp_wdata[63:0]` | input | 64 | CSR 写数据 |
| `cnt_value[63:0]` | output | 64 | 计数器当前值 |
| `cnt_of` | output | 1 | 溢出脉冲（单拍） |

### 2.2 ct_hpcp_cntof_reg 端口（`ct_hpcp_cntof_reg.v:17~34`）

| 端口名 | 方向 | 宽度 | 说明 |
|--------|------|------|------|
| `hpcp_clk` | input | 1 | PMU 门控后时钟 |
| `cpurst_b` | input | 1 | 复位 |
| `cntof_wen_x` | input | 1 | 写本溢出标志使能 |
| `hpcp_wdata_x` | input | 1 | 写值（该 bit） |
| `counter_overflow_x` | input | 1 | 计数器溢出脉冲（来自 cnt） |
| `l2cnt_cmplt_ff` | input | 1 | L2 访问完成（写仲裁条件） |
| `cntof_x` | output | 1 | 该计数器 sticky 溢出标志 |

### 2.3 ct_hpcp_cntinten_reg 端口（`ct_hpcp_cntinten_reg.v:17~30`）

| 端口名 | 方向 | 宽度 | 说明 |
|--------|------|------|------|
| `hpcp_clk` | input | 1 | PMU 门控后时钟 |
| `cpurst_b` | input | 1 | 复位 |
| `cntinten_wen_x` | input | 1 | 写本中断使能位 |
| `hpcp_wdata_x` | input | 1 | 写值（该 bit） |
| `cntinten_x` | output | 1 | 该计数器溢出中断使能 |

---

## 3. 参数与关键寄存器

| 项目 | 值 | 出处 | 说明 |
|------|----|----|----|
| 计数器位宽 | 64 | `ct_hpcp_cnt.v:50` `reg [63:0] counter` | 全部计数器统一 64 位 |
| 增量位宽 | 4 | `ct_hpcp_cnt.v:33` | 每拍 +0~8 |
| 固定计数器数 | 2 | mcycle/minstret | 周期、退休指令 |
| 可编程计数器数 | 16 | mhpmcnt3~18 | `ct_hpcp_top.v:1300~1315` |
| 溢出标志位宽 | 32 | `ct_hpcp_top.v:284` `l2of_int` 等 | bit0=CY,bit2=IR,bit3~=HPM |

`ct_hpcp_cnt` 内部寄存器（`ct_hpcp_cnt.v:46~50`）：

| 寄存器 | 宽度 | 含义 |
|--------|------|------|
| `counter` | 64 | 计数值 |
| `cnt_en_ff` | 1 | 使能打一拍 |
| `cnt_adder_ff` | 4 | 增量打一拍 |
| `cnt_overflow` | 1 | 溢出脉冲寄存 |

---

## 4. 64 位计数器主体（ct_hpcp_cnt）

### 4.1 计数主逻辑

`ct_hpcp_cnt.v:116~140`：

```verilog
always @(posedge cnt_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    counter[63:0] <= 64'b0;
  else if(cnt_wen)                                       // 1. CSR 写优先
    counter[63:0] <= hpcp_wdata[63:0];
  else if(cnt_en_ff && hpcp_cnt_en && (|cnt_adder_ff[3:0])) // 2. 使能且增量非0 才加
    counter[63:0] <= counter_adder[63:0];
  else
    counter[63:0] <= counter[63:0];                      // 3. 保持
end

assign counter_adder[64:0] = {1'b0,counter[63:0]} + {61'b0,cnt_adder_ff[3:0]};
```

**是什么**：优先级为「软件写 > 累加 > 保持」。累加条件三项缺一不可：本计数器使能 `cnt_en_ff`、全局总开关 `hpcp_cnt_en`、本拍增量非 0 `(|cnt_adder_ff)`。`counter_adder` 用 65 位加法，第 64 位 `[64]` 就是进位/溢出。

**为什么 `cnt_en` 和 `cnt_adder` 都打一拍**（`ct_hpcp_cnt.v:94~111`）：使能与增量在 `cnt_en` 有效那拍被寄存成 `cnt_en_ff`/`cnt_adder_ff`，下一拍才参与累加。这样把"事件发生"与"计数更新"切成两个时钟级，缓和组合路径（事件加法器 → MUX → 64 位加法 链很长），换取更高频率。代价是计数有 1 拍固定延迟，但对统计无影响（长期累加，常数偏移可忽略）。

### 4.2 软件写优先

`cnt_wen` 时直接把 `hpcp_wdata` 写进计数器，用于软件清零或预置（例如把计数器预置成接近溢出的值，使其在指定事件数后触发中断采样）。

---

## 5. 溢出检测与单拍脉冲（cnt_overflow）

`ct_hpcp_cnt.v:128~144`：

```verilog
always @(posedge cnt_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
    cnt_overflow <= 1'b0;
  else if(cnt_overflow)                                  // 已置位则下拍自动清（单拍宽）
    cnt_overflow <= 1'b0;
  else if(cnt_en_ff && hpcp_cnt_en && (|cnt_adder_ff[3:0]))
    cnt_overflow <= counter_adder[64];                   // 取 65 位加法的进位
  else
    cnt_overflow <= cnt_overflow;
end

assign cnt_of = cnt_overflow;
```

**是什么**：当 64 位加法产生进位（`counter_adder[64]=1`，即计数器从 0xFFFF...F 回卷）时，`cnt_overflow` 置 1 一拍，下一拍自动清 0，因此 `cnt_of` 是**单拍脉冲**。

**为什么做成单拍脉冲而非电平**：sticky 的"已溢出"状态由外部 `ct_hpcp_cntof_reg` 负责保存（见第 8 节）。`cnt_of` 只需通知"刚刚发生了一次溢出"，单拍脉冲正好；若用电平会和 sticky 标志职责重叠，且影响下次溢出的检测。

---

## 6. 计数器使能链：mcountinhibit / cnt_mask / 事件号

每个计数器的 `cnt_en` 在 `ct_hpcp_top` 拼出，把多个关断条件串成与逻辑。

固定计数器（`ct_hpcp_top.v:1297~1298`）：

```verilog
assign mcycle_en   = !rtu_yy_xx_dbgon && !cnt_mode_dis && !mcntinhbt_value[0];
assign minstret_en = !rtu_yy_xx_dbgon && !cnt_mode_dis && !mcntinhbt_value[2];
```

可编程计数器（`ct_hpcp_top.v:1300~1315`，以 cnt3 为例）：

```verilog
assign mhpmcnt3_en = !rtu_yy_xx_dbgon       // 1. 不在调试态
                  && !cnt_mode_dis          // 2. 当前特权未被过滤
                  && !cnt_mask[3]           // 3. 未被软件 mask（L2 借道时用）
                  && !mcntinhbt_value[3]    // 4. mcountinhibit 未抑制
                  && (|mhpmevt3_value[5:0]);// 5. 事件号非 0
```

**逐项含义**：

1. **`rtu_yy_xx_dbgon`**：核进入调试模式时停止所有计数（调试期间不该污染性能数据）。
2. **`cnt_mode_dis`**：特权过滤，见第 7 节。
3. **`cnt_mask[x]`**：软件 mask 位。当某个可编程计数器被"借去"做 L2 计数索引时，`cnt_mask` 把它在核内的累加关掉，避免双重计数（详见 `03_hpcp_top.md`）。
4. **`mcntinhbt_value[x]`**：RISC-V `mcountinhibit` 寄存器对应位，软件可逐计数器暂停计数而不丢失已计数值。位映射见 `ct_hpcp_top.v:2563`：bit0=CY、bit2=IR、bit3~31=HPM3~31。
5. **事件号非 0**：未配置事件（号 0）的可编程计数器不计数，等价于关闭。

注意 bit1 恒为 0（`ct_hpcp_top.v:2563` 中 `{hpm[28:0], ir, 1'b0, cy}`），对应 RISC-V 中 `time` 不可被 inhibit、且没有 hpmcounter1 槽位的约定。

---

## 7. 特权过滤 PMDM/PMDS/PMDU（cnt_mode_dis）

RISC-V 允许 PMU 按当前特权级选择性计数。C910 用 `MHPMCR` 寄存器的 PMDM/PMDS/PMDU 三位实现"在某特权级下停止计数"。

`ct_hpcp_top.v:1287~1289`：

```verilog
assign cnt_mode_dis_pre = (cp0_yy_priv_mode[1:0] == 2'b11) && cp0_hpcp_pmdm   // M 态且 PMDM
                       || (cp0_yy_priv_mode[1:0] == 2'b01) && cp0_hpcp_pmds   // S 态且 PMDS
                       || (cp0_yy_priv_mode[1:0] == 2'b00) && cp0_hpcp_pmdu;  // U 态且 PMDU
```

随后寄存一拍成 `cnt_mode_dis`（`ct_hpcp_top.v:1279~1285`）。

**是什么**：当前若处于 M 态且 PMDM=1（或 S/U 态对应位为 1），`cnt_mode_dis=1`，所有计数器本拍停止累加。

**为什么**：性能分析常希望只统计用户态、或排除内核/异常处理的影响。例如设 PMDM=PMDS=1、PMDU=0，则计数器只在用户态前进，得到纯用户态的 IPC。该过滤是全局的（对所有 18 个计数器同时生效，也对 L2 借道计数生效，见 `ct_hpcp_top.v:4296~4299`）。

---

## 8. 溢出标志寄存器 mcntof（ct_hpcp_cntof_reg）

每个计数器配一个 `ct_hpcp_cntof_reg`，保存 sticky 的溢出标志。

`ct_hpcp_cntof_reg.v:48~56`：

```verilog
always @(posedge hpcp_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
      cntof_x <= 1'b0;
  else if(cntof_wen_x && l2cnt_cmplt_ff)     // 软件写（需 L2 仲裁完成）
      cntof_x <= hpcp_wdata_x;
  else
      cntof_x <= cntof_x | counter_overflow_x; // sticky：一旦溢出就保持
end
```

**是什么**：`cntof_x = cntof_x | counter_overflow_x`——溢出脉冲一旦到来就把标志置 1 并保持，直到软件写 0 清除。这就是 RISC-V Sscofpmf 风格的 `scountovf` / C910 的 `mcntof` 寄存器对应位。

**为什么 sticky**：溢出脉冲只有一拍，软件不可能轮询到。sticky 标志让软件在中断里能确定"是哪个计数器溢出了"，从而知道当前采样点对应哪个事件——这是溢出中断采样剖析（sampling profiling）的关键。

**为什么写需要 `l2cnt_cmplt_ff`**：`mcntof` 的某些位可能映射到 L2 计数器溢出（`cnt_mask` 借道），写清这些位要等 L2 访问完成（`l2cnt_cmplt_ff`）才能安全提交，避免与 L2 返回的数据竞争。

顶层把 32 个 `cntof[x]` 与 L2 溢出信息合并，`bit1`、`cntof[1]` 恒 0（`ct_hpcp_top.v:3048`），整体形成 `mcntof_value`/`scntof_value`（`ct_hpcp_top.v:3022~3027`）。

---

## 9. 溢出中断使能 mcntinten（ct_hpcp_cntinten_reg）与中断生成

每个计数器配一个 `ct_hpcp_cntinten_reg`，保存"溢出是否产生中断"。

`ct_hpcp_cntinten_reg.v:42~50`：

```verilog
always @(posedge hpcp_clk or negedge cpurst_b)
begin
  if(!cpurst_b)
      cntinten_x <= 1'b0;
  else if(cntinten_wen_x)
      cntinten_x <= hpcp_wdata_x;
  else
      cntinten_x <= cntinten_x;
end
```

一个普通的可写 1 bit 寄存器，对应 `mcntinten` 的某位。

**中断如何产生**（`ct_hpcp_top.v:3024,3042`）：

```verilog
assign cntof_int[31:0]  = cntof[31:0] & (~cnt_mask[31:0]) | l2of_int[31:0] & cnt_mask[31:0];
assign hpcp_cp0_int_vld = |(cntinten_value[31:0] & cntof_int[31:0]);
```

**是什么**：把"已溢出且使能了中断"的位逐一求与再或起来——只要有任何一个使能了中断的计数器溢出，`hpcp_cp0_int_vld=1`，PMU 向 CP0 拉起溢出中断（PMU overflow interrupt）。

**采样剖析流程**：软件把某计数器预置成"再发生 N 次目标事件就溢出"，开启该位的 `mcntinten`；当第 N 次事件到来计数器回卷，`cntof` 置位、`hpcp_cp0_int_vld` 触发中断；中断处理程序读 PC 即得"每 N 次事件采一个样本点"，多次采样后构成热点剖析（perf record 的硬件基础）。

---

## 10. 固定 2 + 可编程 16 的计数器编制

| 计数器 | 例化名 | CSR(M/S/U) | 事件 | 增量来源 |
|--------|--------|-----------|------|---------|
| mcycle | `x_hpcp_mcycle` (`ct_hpcp_top.v:3703`) | B00/5E0/C00 | 周期 | 恒 1 |
| minstret | `x_hpcp_minstret` (`ct_hpcp_top.v:3722`) | B02/5E2/C02 | 退休指令 | 0~6 |
| mhpmcnt3~18 | `x_hpcp_mhpmcnt3`~`18` | B03~B12 等 | 可编程 | adder_sel |

固定计数器不经 `adder_sel`：mcycle 增量恒 `4'b1`（每拍 +1），minstret 增量是同周期 0~3 条退休指令的 `instN_num` 加权和（`ct_hpcp_top.v:1330`，一条退休项可代表多条因 RVC 等合并的指令）。

可编程计数器的增量来自第 6 节使能控制 + `02_hpcp_events.md` 的 `adder_sel`。

溢出聚合（`ct_hpcp_top.v:3440~3443`）把 18 个 `_of` 脉冲拼成 `counter_overflow[31:0]`：bit0=mcycle、bit1=0、bit2=minstret、bit3~18=mhpmcnt3~18、bit19~31 恒 0（对应未实现的 HPM19~31）。

---

## 11. 门控时钟

`ct_hpcp_cnt` 每个实例自带门控（`ct_hpcp_cnt.v:74~91`）：

```verilog
assign clk_en = cnt_clk_en || cnt_en_ff;
```

`cnt_clk_en = cnt_en || cnt_wen || cnt_of`（顶层，如 `ct_hpcp_top.v:2322`）——只有"要计数 / 要被写 / 刚溢出"时才打开该计数器时钟。

**为什么**：18 个 64 位计数器是 PMU 的功耗大头。绝大多数计数器在某次实验中并未被配置事件（事件号 0、`cnt_en=0`），用每计数器独立门控可让未使用的计数器时钟完全停摆，几乎零动态功耗。这是 PMU "默认不开销" 设计哲学的体现。

---

## 设计取舍小结

- **统一 64 位计数器 + 4 位增量**：所有计数器同构，易于复用例化；65 位加法的最高位天然就是溢出位（`ct_hpcp_cnt.v:140`），不需额外比较器。
- **使能/增量打一拍**：用 1 拍延迟换关键路径（事件加法 → 42 选 1 → 64 位加法）的时序裕量，对长期统计无精度影响。
- **溢出 sticky + 单拍脉冲分工**：`ct_hpcp_cnt` 出单拍脉冲，`ct_hpcp_cntof_reg` 做 sticky 保存，职责清晰；sticky 标志是采样剖析能定位"哪个事件溢出"的前提。
- **多级使能串联**：debug、特权过滤、mcountinhibit、软件 mask、事件号 5 道闸门串联（`ct_hpcp_top.v:1300`），既满足 RISC-V 规范（mcountinhibit、特权过滤），又支持 L2 借道时关闭核内重复计数。
- **逐计数器门控时钟**：未配置的计数器时钟停摆，PMU 默认近零功耗。
- **只实现 HPM3~18**：在面积与可用计数器数之间折中——16 个可编程计数器足以同时观测多数性能维度，省下 HPM19~31 的面积。

---

*文档覆盖 ct_hpcp_cnt.v 全部 153 行逻辑、ct_hpcp_cntof_reg.v 全部 63 行逻辑、ct_hpcp_cntinten_reg.v 全部 57 行逻辑，并含 ct_hpcp_top.v 中计数器使能/特权过滤/溢出聚合的相关逻辑。*
