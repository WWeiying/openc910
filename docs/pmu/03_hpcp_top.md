# C910 PMU 顶层 ct_hpcp_top 模块详细教学文档

> RTL 文件：`C910_RTL_FACTORY/gen_rtl/pmu/rtl/ct_hpcp_top.v`（4404 行）

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键寄存器（CSR 地址表）](#3-参数与关键寄存器csr-地址表)
4. [CSR 访问：两拍状态机与读写时序](#4-csr-访问两拍状态机与读写时序)
5. [CSR 写译码与 64 位读 MUX](#5-csr-写译码与-64-位读-mux)
6. [M/S/U 三视图与 mcntwen 投影](#6-msu-三视图与-mcntwen-投影)
7. [事件信号 rename 与增量产生](#7-事件信号-rename-与增量产生)
8. [控制寄存器 MHPMCR 与 TME/TS 区间剖析](#8-控制寄存器-mhpmcr-与-tmets-区间剖析)
9. [L2 计数器借道与 BIU 交互](#9-l2-计数器借道与-biu-交互)
10. [向各单元广播计数使能](#10-向各单元广播计数使能)
11. [门控时钟](#11-门控时钟)
12. [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

### 1.1 职责

`ct_hpcp_top`（HPCP = Hardware Performance Counter & Profiling）是 PMU 的顶层，把前面三章讲的子模块连成完整的硬件性能监测单元。它的职责：

1. **CSR 接口**：通过 CP0 总线（`cp0_hpcp_*` / `hpcp_cp0_*`）实现所有 PMU 寄存器的读写，含一个两拍握手状态机。
2. **寄存器堆**：例化 18 个计数器（`ct_hpcp_cnt`）、16 个事件寄存器（`ct_hpcp_event`）、32 个溢出标志（`ct_hpcp_cntof_reg`）、32 个中断使能（`ct_hpcp_cntinten_reg`），以及 MHPMCR/MHPMSP/MHPMEP/mcountinhibit 等控制寄存器。
3. **事件采集**：从 IFU/IDU/LSU/MMU/RTU/BIU 各单元收集事件信号，rename 后算出 42 个事件增量，分发给计数器。
4. **M/S/U 三视图**：同一组物理计数器，按 RISC-V 规范在 Machine/Supervisor/User 三个特权空间提供不同地址、不同可见性的视图。
5. **区间剖析**：基于 MHPMSP/MHPMEP（起止 PC）和 TME 模式，实现"只统计某 PC 区间"的硬件功能。
6. **L2 计数代理**：把对 L2 cache 计数器的访问转发给 BIU/CIU 并回填结果。
7. **使能广播**：向 6 个单元广播 `hpcp_xx_cnt_en`，告诉它们 PMU 是否在采集（让各单元决定是否产生事件信号，省功耗）。

### 1.2 在 SoC 中的位置

```
  CP0 (CSR 总线) ──cp0_hpcp_*──► ct_hpcp_top ──hpcp_cp0_*──► CP0 (读数据/中断)
                                     ▲   │
        IFU/IDU/LSU/MMU/RTU 事件 ────┘   └──hpcp_xx_cnt_en──► 各单元
                                     ▲   │
                  BIU/CIU (L2) ◄─hpcp_biu_*─┘ biu_hpcp_*─►（L2 计数/时间/溢出）
```

PMU 不在任何关键执行路径上，它只"旁路监听"各单元广播的事件信号，因此对核的功能与频率几乎无影响。

---

## 2. 端口说明

端口很多（`ct_hpcp_top.v:17~263`），按功能分组列出代表性信号。

### 2.1 系统与时钟

| 端口 | 方向 | 宽度 | 行号 | 说明 |
|------|------|------|------|------|
| `forever_cpuclk` | input | 1 | 159 | 自由运行时钟 |
| `cpurst_b` | input | 1 | 158 | 低有效复位 |
| `cp0_hpcp_icg_en` | input | 1 | 146 | 模块级门控使能 |
| `pad_yy_icg_scan_en` | input | 1 | 210 | DFT 扫描强开门控 |

### 2.2 CP0（CSR）接口

| 端口 | 方向 | 宽度 | 行号 | 说明 |
|------|------|------|------|------|
| `cp0_hpcp_index[11:0]` | input | 12 | 147 | CSR 地址 |
| `cp0_hpcp_wdata[63:0]` | input | 64 | 156 | 写数据 |
| `cp0_hpcp_src0[63:0]` | input | 64 | 155 | 源操作数（L2 写用） |
| `cp0_hpcp_op[3:0]` | input | 4 | 150 | 操作码（bit3=写） |
| `cp0_hpcp_sel` | input | 1 | 154 | CSR 访问请求 |
| `cp0_hpcp_mcntwen[31:0]` | input | 32 | 149 | M 授权 S 访问的位图 |
| `cp0_hpcp_pmdm/pmds/pmdu` | input | 1 | 151~153 | 特权过滤位 |
| `cp0_hpcp_int_disable` | input | 1 | 148 | 中断禁用（event36） |
| `cp0_yy_priv_mode[1:0]` | input | 2 | 157 | 当前特权级 |
| `hpcp_cp0_data[63:0]` | output | 64 | 255 | 读数据 |
| `hpcp_cp0_cmplt` | output | 1 | 254 | 访问完成握手 |
| `hpcp_cp0_int_vld` | output | 1 | 256 | 溢出中断有效 |
| `hpcp_cp0_sce` | output | 1 | 257 | S 态计数使能（SCE 位） |

### 2.3 事件输入（采样源）

来自 IFU（`ifu_hpcp_*`，icache/btb/frontend_stall）、IDU（`idu_hpcp_*`，指令类型/流水有效/backend_stall）、LSU（`lsu_hpcp_*`，dcache/stall/replay）、MMU（`mmu_hpcp_*`，TLB miss）、RTU（`rtu_hpcp_inst0/1/2_*`，退休信息/分支/PC），共约 80 个输入端口（`ct_hpcp_top.v:160~249`）。

### 2.4 BIU（L2）接口

| 端口 | 方向 | 宽度 | 行号 | 说明 |
|------|------|------|------|------|
| `biu_hpcp_rdata[127:0]` | input | 128 | 144 | L2 计数读回数据 |
| `biu_hpcp_cmplt` | input | 1 | 142 | L2 访问完成 |
| `biu_hpcp_time[63:0]` | input | 64 | 145 | `time` CSR 来源 |
| `biu_hpcp_l2of_int[3:0]` | input | 4 | 143 | L2 溢出中断 |
| `hpcp_biu_op[15:0]` | output | 16 | 251 | L2 操作（含索引/op） |
| `hpcp_biu_sel` | output | 1 | 252 | L2 访问请求 |
| `hpcp_biu_wdata[63:0]` | output | 64 | 253 | L2 写数据 |
| `hpcp_biu_cnt_en[3:0]` | output | 4 | 250 | 4 个 L2 计数使能 |

### 2.5 使能广播输出

`hpcp_ifu_cnt_en` / `hpcp_idu_cnt_en` / `hpcp_lsu_cnt_en` / `hpcp_mmu_cnt_en` / `hpcp_rtu_cnt_en`（`ct_hpcp_top.v:258~262`）。

---

## 3. 参数与关键寄存器（CSR 地址表）

CSR 地址参数定义于 `ct_hpcp_top.v:897~1045`。下表为全部 PMU CSR 地址（带行号）。

### 3.1 Machine 模式控制（`ct_hpcp_top.v:902~908`）

| CSR | 地址 | 行号 | 作用 |
|-----|------|------|------|
| MCNTINHBT | 0x320 | 902 | mcountinhibit，逐计数器抑制 |
| MCNTWEN | 0x7C9 | 903 | M 授权 S 访问位图 |
| MCNTINTEN | 0x7CA | 904 | 溢出中断使能 |
| MCNTOF | 0x7CB | 905 | 溢出标志 (sticky) |
| MHPMCR | 0x7F0 | 906 | PMU 控制（TME/TS/SCE/PMD*） |
| MHPMSP | 0x7F1 | 907 | 区间起点 PC |
| MHPMEP | 0x7F2 | 908 | 区间终点 PC |

### 3.2 事件选择（`ct_hpcp_top.v:910~938`）

`MHPMEVT3`=0x323 … `MHPMEVT18`=0x332 … `MHPMEVT31`=0x33F（仅 3~18 实现）。

### 3.3 计数器（`ct_hpcp_top.v:940~1045`）

| 视图 | 周期 | 退休 | HPM3..18 |
|------|------|------|----------|
| M (机器) | MCYCLE 0xB00 | MINSTRET 0xB02 | MHPMCNT3 0xB03 … 0xB12 |
| S (监管) | SCYCLE 0x5E0 | SINSTRET 0x5E2 | SHPMCNT3 0x5E3 … 0x5F2 |
| U (用户) | CYCLE 0xC00 | INSTRET 0xC02 | HPMCNT3 0xC03 … 0xC12 |
| S 控制 | SCNTINTEN 0x5C4 / SCNTOF 0x5C5 / SCNTINHBT 0x5C8 / SHPMCR 0x5C9 / SHPMSP 0x5CA / SHPMEP 0x5CB | | |

U 模式独有 `TIME`=0xC01（`ct_hpcp_top.v:1015`），数据直接来自 `biu_hpcp_time`。

---

## 4. CSR 访问：两拍状态机与读写时序

`ct_hpcp_top.v:1091~1121`：

```verilog
parameter EX1 = 2'b01;
parameter EX2 = 2'b10;
...
case(cur_state)
  EX1: if(cp0_hpcp_sel) next_state = EX2; else EX1;
  EX2: if(hpcp_cp0_cmplt) next_state = EX1; else EX2;
endcase
```

**是什么**：PMU 的 CSR 访问是两拍握手——EX1 等请求 `cp0_hpcp_sel`，进入 EX2 执行并产生完成 `hpcp_cp0_cmplt`，再回 EX1。flush（`rtu_yy_xx_flush`）会强制回 EX1。

**为什么两拍**：普通 PMU 寄存器一拍就能读，但访问 L2 计数器或溢出标志时需要把请求发到 BIU、等 L2 返回（`biu_hpcp_cmplt`），这是多拍操作。统一用 EX2 等待 `hpcp_cp0_cmplt`，让本地寄存器（一拍完成）和 L2（多拍完成）共用同一握手协议（`ct_hpcp_top.v:4336`）：

```verilog
assign hpcp_cp0_cmplt = (l2cnt_sel && cnt_bit_mask[0] || ofcnt_sel)
                      ? l2cnt_cmplt_ff && (cur_state == EX2)  // L2: 等返回
                      : (cur_state == EX2);                    // 本地: 立即完成
```

写使能 `hpcp_wen = cp0_hpcp_op[3] && (cur_state == EX2)`（`ct_hpcp_top.v:1219`），保证写只在 EX2 执行一次。

---

## 5. CSR 写译码与 64 位读 MUX

**写译码**（`ct_hpcp_top.v:1221~1273`）：每个寄存器一条 `xxx_wen = (cp0_hpcp_index == XXX) && hpcp_wen`。注意计数器写译码同时匹配 M 与 S 地址（`ct_hpcp_top.v:1247`）：

```verilog
assign mcycle_wen = ((cp0_hpcp_index == MCYCLE) || (cp0_hpcp_index == SCYCLE)) && hpcp_wen;
```

因为 M/S 视图共享同一物理计数器。

**读 MUX**（`ct_hpcp_top.v:4056~4193`）：一个大 `case(cp0_hpcp_index)` 把所有可读地址映射到对应 `xxx_value`，输出 `data_out`。M/S/U 三套计数器地址都指向同一个 `mhpmcntN_value`（`ct_hpcp_top.v:4135~4189`）。最终：

```verilog
// ct_hpcp_top.v:4339
assign hpcp_cp0_data = (l2cnt_sel && cnt_bit_mask[0]) ? biu_hpcp_rdata[63:0] : data_out[63:0];
```

即：若读的是被借道为 L2 计数的计数器，返回 BIU 数据，否则返回本地 `data_out`。

---

## 6. M/S/U 三视图与 mcntwen 投影

RISC-V 规定同一组性能计数器在 M/S/U 三态有不同地址且可见性不同。C910 用 **一组物理寄存器 + 三套地址 + mcntwen 位图** 实现。

- **同物理、多地址**：读 MUX 中 `MHPMCNT3`/`SHPMCNT3`/`HPMCNT3` 都返回 `mhpmcnt3_value`（`ct_hpcp_top.v:4137/4155/4174`）；写译码 M/S 地址都置 `mhpmcnt3_wen`（`ct_hpcp_top.v:1250`）。

- **mcntwen 投影到 S 视图**：M 态可通过 `MCNTWEN`(0x7C9) 设置一个 32 位位图，决定哪些计数器对 S 态可见/可写。S 态读到的控制寄存器是 M 值与 `mcntwen` 的按位与（`ct_hpcp_top.v:2619/2564/3027`）：

```verilog
assign scntinten_value = cntinten_value & {32'b0,cp0_hpcp_mcntwen};   // S 看到的中断使能
assign scntinhbt_value = {...} & {32'b0,cp0_hpcp_mcntwen};            // S 看到的 inhibit
assign scntof_value    = cntof_value    & {32'b0,cp0_hpcp_mcntwen};   // S 看到的溢出
```

S 态写 `SCNTINHBT` 时也只能改 `mcntwen` 授权的位，其余位保持 M 设置（`ct_hpcp_top.v:2567`）。

**为什么**：操作系统（S 态）需要管理给用户的计数器，但不能越权改 M 态保留的计数器。`mcntwen` 让 M 态精确地把部分计数器"委派"给 S 态，是 PMU 虚拟化/权限隔离的硬件基础。

- **SCE 位**：`hpcp_cp0_sce = sce`（`ct_hpcp_top.v:4343`），MHPMCR 里的 SCE 位决定 S 态能否使用 PMU；它只能在 M 态修改（`ct_hpcp_top.v:2382` 注释 "sce can be modified on m-mode"）。

---

## 7. 事件信号 rename 与增量产生

`ct_hpcp_top.v:1126~1212` 把各单元的 `xxx_hpcp_yyy` 输入统一 rename 成内部 `hpcp_*` 名字（纯连线，方便后续逻辑书写与维护）。例如：

```verilog
assign hpcp_retire_inst0_vld = rtu_hpcp_inst0_vld;
assign hpcp_icache_access    = ifu_hpcp_icache_access;
```

随后第 1324~1463 行把这些信号组合成 minstret 增量与 42 个事件增量。这部分（多 bit 加法器、42 种事件清单）已在 `02_hpcp_events.md` 详解。

---

## 8. 控制寄存器 MHPMCR 与 TME/TS 区间剖析

### 8.1 MHPMCR 位定义（`ct_hpcp_top.v:2365`）

```verilog
assign mhpmcr_value = {ts, sce, 48'b0, pmdm, 1'b0, pmds, pmdu, 8'b0, tme[1:0]};
//                      63   62          11        9    8           1:0
```

| 位 | 名称 | 作用 |
|----|------|------|
| 63 | TS | 计数器触发状态（区间内=1） |
| 62 | SCE | S 态 PMU 使能 |
| 11 | PMDM | M 态禁计数 |
| 9 | PMDS | S 态禁计数 |
| 8 | PMDU | U 态禁计数 |
| 1:0 | TME | 触发模式 |

### 8.2 TME 三种触发模式

`hpcp_cnt_en` 是全局计数总开关（`ct_hpcp_top.v:1291`）：

```verilog
assign hpcp_cnt_en = (tme == 2'b00)        // 自由计数
                  || (tme == 2'b01) && ts  // PC 匹配模式：进区间才计
                  || (tme == 2'b10) && ts; // PC 范围模式：在范围内才计
```

- **TME=00**：自由运行，永远计数（常规用法）。
- **TME=01（trigger/stop by PC）**：退休 PC == MHPMSP 时 `ts←1` 开始计数，PC == MHPMEP 时停止（`ct_hpcp_top.v:2471~2477,2398~2403`）。即"从起点 PC 数到终点 PC"。
- **TME=10（PC 范围）**：退休 PC 落在 [MHPMSP, MHPMEP] 区间内则计数，离开即停（`ct_hpcp_top.v:2479~2485`）。

### 8.3 起止 PC 比较逻辑

MHPMSP/MHPMEP 各存一个 PC（`ct_hpcp_top.v:2495~2543`），与 3 条退休指令的 PC 做减法比较（`ct_hpcp_top.v:2422~2469`）。因为一拍退休 3 条，必须对 inst0/1/2 同时比较，任一命中即触发（`trigger_vld`/`stop_vld`/`start_vld`/`end_vld`）。`hpmsp_high_vld`/`hpmep_high_vld` 校验高位是 PC 的合法符号扩展（`ct_hpcp_top.v:2515,2541`）。

**为什么**：这套机制让软件不必插桩，就能"只统计某函数/某循环"的性能。设好 MHPMSP=函数入口、MHPMEP=函数出口、TME=01，硬件自动只在函数执行期间累加计数器——这是"圈区间做性能分析"的硬件支撑。

`ts` 用 `forever_cpuclk` 而非门控时钟更新（`ct_hpcp_top.v:2392`），保证区间触发不受 PMU 门控影响。

---

## 9. L2 计数器借道与 BIU 交互

L2 cache 物理上属于 CIU/BIU，其性能计数器不在 PMU 内。C910 用"借道某个可编程计数器索引"的方式让软件用统一的 hpmcounter 接口访问 L2 计数。

### 9.1 cnt_mask 与事件索引

`ct_hpcp_top.v:4199~4270`：当软件把某可编程计数器的事件号写成 L2 事件（写 `mhpmeventN` 且 `hpcp_wdata[5:2]==4'b0100`，即事件号 16~19 区段），`cnt_mask_set` 置位，对应 `cnt_mask[x]=1`，并把该计数器索引记进 `cnt0/1/2/3_event_index`（4 个 L2 子计数器：read access / read miss / write access / write miss，由 `hpcp_wdata[1:0]` 选）。

`cnt_mask[x]=1` 的效果：

1. 关闭该计数器在核内的累加（`!cnt_mask[x]` 在 `mhpmcntN_en` 里，`ct_hpcp_top.v:1300`）——避免重复计数；
2. 读该计数器时返回 BIU 数据而非本地值（`ct_hpcp_top.v:4339`）；
3. 溢出与中断改用 L2 来源 `l2of_int`（`ct_hpcp_top.v:3024`）。

### 9.2 向 BIU 发请求

`ct_hpcp_top.v:4288~4353`：把 CSR 操作翻译成 `hpcp_biu_op[15:0]`（含 L2 计数器索引 `l2cnt_reg_idx`、写使能 `l2of_wen`、op），`hpcp_biu_sel` 拉起请求，`hpcp_biu_cnt_en[3:0]` 是 4 个 L2 子计数器的计数使能（同样受 dbgon/cnt_mode_dis/hpcp_cnt_en 门控，`ct_hpcp_top.v:4296~4299`）。

返回时 `biu_hpcp_cmplt` 置 `l2cnt_cmplt_ff`（`ct_hpcp_top.v:4324`），驱动两拍状态机完成握手，`biu_hpcp_rdata` 作为读数据。L2 溢出 `biu_hpcp_l2of_int` 经边沿检测后并入 `l2of_int`（`ct_hpcp_top.v:2998~3020`）。

**为什么这么绕**：让软件无需感知 L2 计数器在物理上属于别的单元——配置/读取/中断都走和片上计数器完全相同的 hpmcounter/mhpmevent/mcntof CSR 接口，只是 PMU 在后台把它代理到 BIU。统一的软件视图，物理上分布实现。

---

## 10. 向各单元广播计数使能

`ct_hpcp_top.v:4345~4377`：

```verilog
assign hpcp_xx_cnt_en  = !rtu_yy_xx_dbgon && !cnt_mode_dis;
assign hpcp_ifu_cnt_en = hpcp_xx_cnt_en;
assign hpcp_idu_cnt_en = hpcp_xx_cnt_en;
assign hpcp_lsu_cnt_en = hpcp_xx_cnt_en;
assign hpcp_mmu_cnt_en = hpcp_xx_cnt_en;
assign hpcp_rtu_cnt_en = hpcp_xx_cnt_en;
```

**是什么**：当不在调试态、且当前特权未被过滤时，告诉各单元"PMU 在采集"。

**为什么**：各单元产生事件信号（如 IFU 拉出 icache_access 脉冲）本身也耗功耗与翻转。PMU 把"是否在采集"广播出去，各单元可在 PMU 不工作时停止产生事件信号，进一步降功耗。这是 PMU 旁路式设计的延伸——不仅自己默认零开销，也尽量不让被监测单元为它额外开销。

---

## 11. 门控时钟

PMU 顶层时钟 `hpcp_clk` 的局部使能聚合了所有可能需要时钟的事件（`ct_hpcp_top.v:1067~1086`）：任何 CSR 写、CSR 访问 `cp0_hpcp_sel`、L2 返回、计数器溢出 `(|counter_overflow)`、特权过滤状态翻转等，才打开 PMU 时钟。空闲时整个 PMU 控制逻辑时钟停摆。各计数器/事件寄存器又各自带门控（见 `01`、`02` 章）。

---

## 设计取舍小结

- **两拍握手统一本地与 L2 访问**：用同一个 EX1/EX2 状态机覆盖一拍可完成的本地寄存器和多拍的 L2 访问（`ct_hpcp_top.v:1091,4336`），软件协议统一。
- **一组物理寄存器 + 三套地址 + mcntwen**：M/S/U 三视图共享物理计数器，靠地址映射和 `mcntwen` 位图区分可见性（`ct_hpcp_top.v:2619,4137`），既合规又省面积。
- **TME/TS + MHPMSP/MHPMEP 区间剖析**：硬件自动"只统计某 PC 区间"，无需软件插桩（`ct_hpcp_top.v:2471~2490`），是函数/循环级性能分析的关键。
- **L2 计数借道**：物理在 BIU 的 L2 计数器被代理成普通 hpmcounter，软件视图统一（`ct_hpcp_top.v:4288~4353`）；用 `cnt_mask` 关核内重复计数。
- **多级门控 + 使能广播**：PMU 自身默认近零功耗，并把"是否采集"广播给被监测单元，连锁降功耗（`ct_hpcp_top.v:1067,4345`）。
- **旁路式架构**：PMU 只监听各单元广播的事件，不在任何执行关键路径上，对核功能/频率无影响。

---

*文档覆盖 ct_hpcp_top.v 全部 4404 行逻辑（其中 1469~4051 行为 adder_sel / event / cnt / cntinten / cntof 各子模块的规则化重复例化，已在对应分章详解，本文按机制归纳）。*
