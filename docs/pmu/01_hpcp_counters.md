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
12. [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 职责

PMU 真正"数数"的地方就是计数器。C910 实现了 **18 个 64 位计数器**：

- **2 个固定计数器**：`mcycle`（周期数）、`minstret`（退休指令数）；
- **16 个可编程计数器**：`mhpmcnt3`~`mhpmcnt18`，各自计数一种由 `mhpmeventN` 选定的事件。

虽然 RISC-V 体系结构为 HPM3~HPM31 预留了 29 个可编程槽位，但 C910
当前 RTL 只例化到 HPM18（`ct_hpcp_top.v:1300~1315,4010`）。HPM19~31
仍有地址参数、`mcountinhibit` 位、溢出状态位和中断使能位，但没有
`ct_hpcp_cnt` 或 `ct_hpcp_event` 实例，也没有本地计数值读 MUX 分支。若请求
通过 CP0 合法性检查到达 PMU，未命中的读 MUX 默认返回 0；这不等于所有外围
控制位都不存在。

计数主体、overflow sticky 状态和 interrupt-enable 状态使用不同模块，但三组
资源并非逐槽完全同构：只有 18 个计数主体；`cntof_reg` 与
`cntinten_reg` 都例化于 bit0、2~31，bit1 由顶层固定为 0。

| 微模块 | 作用 | 对应 CSR 位 |
|--------|------|------------|
| `ct_hpcp_cnt` | 64 位计数主体 + 溢出脉冲 | mcycle/minstret/mhpmcntN |
| `ct_hpcp_cntof_reg` | 保存本地或软件写入的 sticky 状态；映射槽读/中断可切到 L2 镜像 | mcntof[x]/scntof[x]，无 bit1 实例 |
| `ct_hpcp_cntinten_reg` | 保存该槽是否允许 overflow 状态请求中断 | mcntinten[x]/scntinten[x] |

### 1.2 设计要点

- **统一 64 位 + 4 位增量接口**：4 位接口能表示 0~15；当前普通事件
  `eventNN_adder` 的结构上限为 8，`minstret_adder` 三个 2 位项相加的表达式
  上限为 9。
- **事件采样与计数更新分级**：`cnt_en/cnt_adder` 先进入
  `cnt_en_ff/cnt_adder_ff`，下一次有效计数时钟边沿才更新 64 位计数值。
- **溢出通知与 sticky 状态分层**：`ct_hpcp_cnt` 输出短脉冲，
  `ct_hpcp_cntof_reg` 保存软件可读状态；中断还要再与 `cntinten` 相与。
- **多级使能**：debug、已寄存的特权过滤、`mcountinhibit`、L2 映射 mask、
  事件号以及 TME/TS 分布在事件捕获和实际更新两个阶段，不能笼统理解为一个
  同拍组合使能。

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
| `cnt_adder[3:0]` | input | 4 | 当前事件采样拍的候选增量；先寄存，后用于更新 |
| `cnt_wen` | input | 1 | CSR 写计数器使能 |
| `hpcp_wdata[63:0]` | input | 64 | CSR 写数据 |
| `cnt_value[63:0]` | output | 64 | 计数器当前值 |
| `cnt_of` | output | 1 | 已寄存的溢出通知；正常连续时钟下保持一个 `cnt_clk` 周期 |

### 2.2 ct_hpcp_cntof_reg 端口（`ct_hpcp_cntof_reg.v:17~34`）

| 端口名 | 方向 | 宽度 | 说明 |
|--------|------|------|------|
| `hpcp_clk` | input | 1 | PMU 门控后时钟 |
| `cpurst_b` | input | 1 | 复位 |
| `cntof_wen_x` | input | 1 | 写本溢出标志使能 |
| `hpcp_wdata_x` | input | 1 | 写值（该 bit） |
| `counter_overflow_x` | input | 1 | 计数器溢出脉冲（来自 cnt） |
| `l2cnt_cmplt_ff` | input | 1 | BIU 完成脉冲的寄存值；所有 MCNTOF/SCNTOF 写的提交条件 |
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
| 增量位宽 | 4 | `ct_hpcp_cnt.v:33` | 可表示 0~15；当前普通事件最大 8 |
| 固定计数器数 | 2 | mcycle/minstret | 周期、退休指令 |
| 可编程计数器数 | 16 | mhpmcnt3~18 | `ct_hpcp_top.v:1300~1315` |
| 溢出/中断索引宽度 | 32 | `cntof[31:0]`、`cntinten[31:0]` | bit0=CY、bit1 两向量都固定 0、bit2=IR、bit3~31=HPM 槽 |

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

**是什么**：对 `counter` 寄存器本身，优先级为「软件写 > 累加 > 保持」。
累加使用的是上一采样拍保存的 `cnt_en_ff/cnt_adder_ff`，同时还要求更新拍的
`hpcp_cnt_en=1`。`counter_adder[64]` 是无符号 65 位加法的进位，低 64 位
自然回卷。

**事件拍和更新拍如何对应**（`ct_hpcp_cnt.v:91~125`）：

1. `cnt_en=1` 时，当前 `cnt_adder` 与使能在边沿进入 `*_ff`；
2. 同一个边沿，`counter` 读取的仍是旧 `*_ff`，所以处理的是上一拍事件；
3. `cnt_en=0` 时，`cnt_en_ff` 清 0，但 `cnt_adder_ff` 保持旧值；旧增量不会被
   重复使用，因为真正累加还要求 `cnt_en_ff=1`；
4. 内部门控 `clk_en = cnt_clk_en || cnt_en_ff` 特意包含待处理的
   `cnt_en_ff`，即使外部 `cnt_en` 已下降，仍给最后一个已捕获事件一次更新
   边沿。

这种分级客观上切断了“事件组合逻辑到 64 位加法器”的同拍路径，但是否因此
达到更高频率需要时序报告证明。它也不是对所有测量窗口都“无影响”：
`hpcp_cnt_en` 没有随增量一起寄存，TME/TS 在事件捕获后、计数更新前关闭时，
待处理增量可被抑制；软件写计数器时，待处理增量也会被写优先级覆盖。因此做
短区间或精确边界测量时必须考虑这一级延迟。

### 4.2 软件写优先

`cnt_wen` 时直接把 `hpcp_wdata` 写进计数器。注意溢出寄存器有另一段独立
`always` 块，它没有把 `cnt_wen` 放在判断条件中：若软件写与一个旧的待处理
增量同拍出现，计数值采用软件写值，但溢出检测仍可能依据**写前的**
`counter + cnt_adder_ff` 产生进位通知。这是 RTL 的确切并发语义，不应把
“软件写优先”扩展解释成“软件写同时取消溢出检测”。

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

**是什么**：当一次有效更新的 65 位加法产生进位时，`cnt_overflow` 在边沿
置 1。下一次 `cnt_clk` 有效边沿首先命中 `else if(cnt_overflow)` 并清 0。
在正常连续供给时钟的条件下，它表现为一个 `cnt_clk` 周期宽的脉冲；若模块级
时钟被关闭，状态会保持到下一个有效边沿，不能把“单拍”脱离时钟域理解为固定
墙上时间。

清零分支优先于新的进位检测，因此 `cnt_overflow=1` 的清零边沿不会同时接受
另一笔进位。正常计数值刚回卷后不可能仅靠最大 15 的增量立刻再次回卷，但分析
强制写值或异常激励时应知道这一优先级。

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

1. **`rtu_yy_xx_dbgon`**：信号为 1 时阻止新事件进入各计数器；已经进入
   `cnt_en_ff` 的事件是否完成，还取决于更新拍的 `hpcp_cnt_en` 和写优先级。
2. **`cnt_mode_dis`**：特权过滤，见第 7 节。
3. **`cnt_mask[x]`**：它不是通用软件可写 mask CSR，而是顶层在
   `mhpmeventN=16~19` 时维护的内部 L2 映射状态。置位后关闭该槽的本地
   `ct_hpcp_cnt` 采样，并把读数和溢出来源切到 L2 路径。
4. **`mcntinhbt_value[x]`**：RISC-V `mcountinhibit` 寄存器对应位，软件可逐计数器暂停计数而不丢失已计数值。位映射见 `ct_hpcp_top.v:2563`：bit0=CY、bit2=IR、bit3~31=HPM3~31。
5. **事件号非 0**：号 0 阻止新事件采样；它不会追溯取消上一拍已经进入
   `cnt_en_ff` 的事件。

注意 bit1 恒为 0（`ct_hpcp_top.v:2563` 中 `{hpm[28:0], ir, 1'b0, cy}`），对应 RISC-V 中 `time` 不可被 inhibit、且没有 hpmcounter1 槽位的约定。

---

## 7. 特权过滤 PMDM/PMDS/PMDU（cnt_mode_dis）

C910 用自定义控制位 PMDM/PMDS/PMDU 实现按当前特权级停止计数。标准
RISC-V 的 `mcountinhibit` 负责逐计数器抑制，但这组三个 PMD 位及其
`MHPMCR` 编码属于实现扩展，不应笼统归为标准 RISC-V 语义。

`ct_hpcp_top.v:1287~1289`：

```verilog
assign cnt_mode_dis_pre = (cp0_yy_priv_mode[1:0] == 2'b11) && cp0_hpcp_pmdm   // M 态且 PMDM
                       || (cp0_yy_priv_mode[1:0] == 2'b01) && cp0_hpcp_pmds   // S 态且 PMDS
                       || (cp0_yy_priv_mode[1:0] == 2'b00) && cp0_hpcp_pmdu;  // U 态且 PMDU
```

随后寄存一拍成 `cnt_mode_dis`（`ct_hpcp_top.v:1279~1285`）。

**是什么**：`cnt_mode_dis_pre` 组合判断当前特权级，随后在 `hpcp_clk`
边沿进入 `cnt_mode_dis`。顶层用 `cnt_mode_dis_pre ^ cnt_mode_dis` 打开该
边沿所需的门控时钟。因此它是**寄存后的过滤状态**，不能描述成特权级变化的
同一组合瞬间立刻关闭。计数器本身又有一拍事件寄存级，边界归属要沿波形逐级看。

**体系结构用途**：性能分析常希望主要统计用户态，或排除内核/异常处理。
例如设 PMDM=PMDS=1、PMDU=0，稳定处于 U 态时允许计数，稳定处于 M/S 态时
阻止新事件采样。由于 `cnt_mode_dis` 和计数器事件各有寄存级，特权切换边界
附近仍可能有尾部归属效应，所以“纯用户态 IPC”应通过足够长的窗口或波形校准，
不能只凭三个位的静态配置保证逐周期精确分界。该过滤对 18 个本地计数器和
L2 借道计数使能都生效。

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

**是什么**：无软件写提交时，`cntof_x` 执行
`cntof_x | counter_overflow_x`，因此一次溢出会把它保持为 1。软件并非只能
写 0：当写条件成立时，目标位直接等于 `hpcp_wdata_x`，所以软件也能写 1。
`MCNTOF/SCNTOF` 是 C910 的寄存器接口，不能直接等同于后来的标准
Sscofpmf `scountovf` 语义。

**为什么保存 sticky 状态**：溢出通知只维持到后续有效计数时钟边沿，软件不能
可靠地靠轮询捕获这种短暂内部通知。sticky 状态把“曾发生”保存下来，使软件
在中断处理或轮询时识别槽位。它能标识哪个槽的 overflow 状态有效，但不能把
中断入口 PC 变成精确事件 PC。

**为什么写需要 `l2cnt_cmplt_ff`**：顶层把任何 `MCNTOF/SCNTOF` 访问都
归入 `ofcnt_sel` 并发往 BIU，不只是在目标位映射到 L2 时才等待。BIU 的
`biu_hpcp_cmplt` 先寄存成单周期 `l2cnt_cmplt_ff`，已例化的 31 个
`ct_hpcp_cntof_reg` 才在该边沿统一提交软件写；bit1 始终是顶层常量 0。
这里能由 RTL 证明的是
“本地写与远端事务使用同一完成点”；“避免竞争”是对设计目的的解释。

软件写分支优先于 sticky OR。若同一提交边沿 `counter_overflow_x=1`，写值会
覆盖这次新溢出，后者不会再被 OR 进去。清溢出状态时若计数器仍在运行，软件应
先暂停或接受这一竞争窗口。

顶层把 32 个本地 `cntof[x]` 与 L2 溢出镜像按 `cnt_mask` 逐位选择，
`cntof[1]` 单独连为 0。bit19~31 虽没有本地计数器进位源，却仍例化了
`cntof_reg`，软件可通过 MCNTOF 写这些位；若相应 `cntinten` 也置 1，纯软件
写出的状态同样会参与中断 OR。这是“未实现计数器”与“未实现控制位”必须区分
的一个细节。

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

**是什么**：`hpcp_cp0_int_vld` 是组合电平，不是单拍中断请求。只要
`cntinten_value & cntof_int` 仍有任一位为 1，它就持续拉高；清溢出状态或关掉
对应中断使能后才会撤销。`cntof_int` 对普通槽选择本地 sticky 位，对
`cnt_mask=1` 的 L2 映射槽选择 `l2of_int` 镜像。

**采样剖析流程**：软件可预置计数器并打开 `cntinten`，让累计值跨越
`2^64` 时请求中断。由于事件增量可能大于 1，回卷可能跨过而不是精确命中阈值；
事件还经过计数寄存级、sticky 状态和 CP0/RTU 中断入口，所以异常入口看到的 PC
是采样点附近的执行位置，不是产生那次事件的精确退休 PC。要实现类似
`perf record` 的完整功能，还需要中断号分派、上下文保存、重装周期和软件采样
框架，不能仅凭这几个 RTL 寄存器宣称已经等价。

---

## 10. 固定 2 + 可编程 16 的计数器编制

| 计数器 | 例化名 | CSR(M/S/U) | 事件 | 增量来源 |
|--------|--------|-----------|------|---------|
| mcycle | `x_hpcp_mcycle` (`ct_hpcp_top.v:3703`) | B00/5E0/C00 | 允许计数的周期事件 | 原始增量恒 1 |
| minstret | `x_hpcp_minstret` (`ct_hpcp_top.v:3722`) | B02/5E2/C02 | 非 split 退休项代表的架构指令数 | 表达式 0~9 |
| mhpmcnt3~18 | `x_hpcp_mhpmcnt3`~`18` | B03~B12 等 | 可编程 | adder_sel |

固定计数器不经 `adder_sel`。`mcycle_adder=1` 只是候选增量；实际更新还受
两级使能控制。`minstret_adder` 对三个槽分别执行：

```text
(retire_instN_vld && !retire_instN_split) ? retire_instN_num : 0
```

再把三个 2 位值相加。`inst_num` 表示一个 ROB 退休项覆盖的架构指令数，来源于
IDU 的指令折叠信息；它不是“RVC 指令长度”，也不能把折叠泛化成只由 RVC
产生。三个 2 位项在表达式层面的上限是 9，具体可达组合由 IDU 创建和 RTU
退休约束决定。

可编程计数器的增量来自第 6 节使能控制 + `02_hpcp_events.md` 的 `adder_sel`。

溢出聚合（`ct_hpcp_top.v:3440~3443`）把 18 个 `_of` 脉冲拼成 `counter_overflow[31:0]`：bit0=mcycle、bit1=0、bit2=minstret、bit3~18=mhpmcnt3~18、bit19~31 恒 0（对应未实现的 HPM19~31）。

---

## 11. 门控时钟

`ct_hpcp_cnt` 每个实例自带门控（`ct_hpcp_cnt.v:74~91`）：

```verilog
assign clk_en = cnt_clk_en || cnt_en_ff;
```

顶层给每个实例的 `cnt_clk_en` 为
`cnt_en || cnt_wen || cnt_of`，实例内部再与 `cnt_en_ff` 相或。四项分别覆盖
“采样新事件”“软件写值”“清除已拉高的溢出通知”和“提交上一拍已采样事件”。
少写最后一项会让 `cnt_en` 刚下降时的尾部事件无法落入计数器。

结构意图是在无采样、无写、无待处理事件和无溢出清除时关闭该实例时钟。
“64 位计数器是功耗大头”“几乎零动态功耗”都需要门级功耗报告支持，RTL
只能证明存在门控条件。另需注意工程中的 `gated_clk_cell` 可能有功能模型或
直通替代实现；只有目标综合配置采用真实 ICG 时，门控才具有物理功耗含义。

---

## 本章小结

HPCP 的计数主体统一为 64 位状态加 4 位增量，内部用 65 位加法同时得到新值和进位溢出。事件使能与增量先打一拍，再在下一拍更新计数器；标准 `mcountinhibit`、C910 PMD 扩展、debug 状态、事件号和 L2 映射共同决定前级采样，TME/TS 区间又可能在更新拍再次门控。这个寄存边界降低了事件组合路径直接进入 64 位加法器的压力，但会形成明确的尾部语义：短窗口关闭、trigger/stop 边界和 CSR 写并发时，前一拍已经锁存的增量可能在后一拍被计入或被写值覆盖，必须按 RTL 优先级解释。

计数器溢出先产生单拍 pulse，再由独立 overflow 寄存器保存 sticky 标志，并由 interrupt-enable 位决定是否汇总为中断。当前只实例化 HPM3 至 HPM18 共 16 个可编程计数主体，HPM19 至 HPM31 不存在同等计数器，尽管部分更高位控制状态仍可在寄存器中出现。每个计数器都有局部门控结构，但物理门控和功耗收益取决于综合配置。读取性能数据时，应同时记录事件选择、特权过滤、区间控制、L2 代理状态、CSR 写入和 overflow 清除，避免把某个 64 位差值误认为未经门控的原始事件总数。
