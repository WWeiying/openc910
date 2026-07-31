# C910 PMU 顶层 ct_hpcp_top 模块详细教学文档

> RTL 文件：`C910_RTL_FACTORY/gen_rtl/pmu/rtl/ct_hpcp_top.v`（4404 行）

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键寄存器（CSR 地址表）](#3-参数与关键寄存器csr-地址表)
4. [CSR 访问：EX1/EX2 状态机与完成时序](#4-csr-访问ex1ex2-状态机与完成时序)
5. [CSR 写译码与 64 位读 MUX](#5-csr-写译码与-64-位读-mux)
6. [标准计数器视图、自定义 S 别名与 mcntwen 投影](#6-标准计数器视图自定义-s-别名与-mcntwen-投影)
7. [事件信号 rename 与增量产生](#7-事件信号-rename-与增量产生)
8. [控制寄存器 MHPMCR 与 TME/TS 区间剖析](#8-控制寄存器-mhpmcr-与-tmets-区间剖析)
9. [L2 计数器借道与 BIU 交互](#9-l2-计数器借道与-biu-交互)
10. [向各单元广播计数使能](#10-向各单元广播计数使能)
11. [门控时钟](#11-门控时钟)
12. [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 职责

`ct_hpcp_top` 是 PMU 的顶层；`hpcp` 是该实现使用的模块和信号名前缀，
RTL 本身没有给出一个应当扩写成固定英文全称的定义。它把前面各章的子模块
连成完整的性能监测单元，主要职责如下：

1. **CSR 接口**：通过 CP0 总线（`cp0_hpcp_*` / `hpcp_cp0_*`）访问 PMU
   寄存器，并用 EX1/EX2 状态机区分请求接收、执行等待和完成。
2. **寄存器堆**：例化 18 个计数器（`ct_hpcp_cnt`）、16 个事件寄存器
   （`ct_hpcp_event`）、31 个溢出状态寄存器（`ct_hpcp_cntof_reg`）和
   31 个中断使能寄存器（`ct_hpcp_cntinten_reg`）；两条 32 位向量的 bit1
   均在顶层固定为 0。
3. **事件采集**：从 IFU/IDU/LSU/MMU/RTU/BIU 各单元收集事件信号，rename 后算出 42 个事件增量，分发给计数器。
4. **多种 CSR 视图**：提供标准 Machine 计数器、标准 User 只读计数器地址，
   以及 C910 自定义的 Supervisor 别名和控制接口；访问权限由 CP0 另行检查。
5. **区间控制**：基于 MHPMSP/MHPMEP、退休槽 PC 和 TME/TS 状态控制
   `hpcp_cnt_en`。边界处还受退休分组、停止信号延迟和计数器内部流水影响。
6. **L2 计数代理**：把对 L2 cache 计数器的访问转发给 BIU/CIU 并回填结果。
7. **使能广播**：向 IFU、IDU、LSU、MMU、RTU 广播 `hpcp_xx_cnt_en`。
   该信号只反映 debug 与已寄存特权过滤状态，不等价于“至少一个计数器正在
   计数”。

### 1.2 在 SoC 中的位置

```
  CP0 (CSR 总线) ──cp0_hpcp_*──► ct_hpcp_top ──hpcp_cp0_*──► CP0 (读数据/中断)
                                     ▲   │
        IFU/IDU/LSU/MMU/RTU 事件 ────┘   └──hpcp_xx_cnt_en──► 各单元
                                     ▲   │
                  BIU/CIU (L2) ◄─hpcp_biu_*─┘ biu_hpcp_*─►（L2 计数/时间/溢出）
```

从功能连接上看，绝大多数事件由被监测单元输出给 PMU，计数结果不反馈到普通
指令执行数据通路；但 TME 区间、广播使能和溢出中断仍有控制连接。事件 tap 会
增加源信号扇出，门控和计数逻辑也占用物理资源。是否进入关键路径、频率影响和
功耗开销只能由目标配置的 STA、面积和功耗报告确认，不能从“旁路监听”四个字
推出“几乎无影响”。

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
| `cp0_hpcp_src0[63:0]` | input | 64 | 155 | CSR 指令原始源操作数；L2/溢出代理写数据生成会使用 |
| `cp0_hpcp_op[3:0]` | input | 4 | 150 | 操作码（bit3=写） |
| `cp0_hpcp_sel` | input | 1 | 154 | CSR 访问请求 |
| `cp0_hpcp_mcntwen[31:0]` | input | 32 | 149 | M 授权 S 访问的位图 |
| `cp0_hpcp_pmdm/pmds/pmdu` | input | 1 | 151~153 | 特权过滤位 |
| `cp0_hpcp_int_disable` | input | 1 | 148 | CP0 全局中断关闭状态；当前只采样为 event36 |
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

地址参数列出了 `MHPMEVT3`=0x323 到 `MHPMEVT31`=0x33F，但
`ct_hpcp_event` 实例和写译码只实现 3~18。19~31 只有参数或其他控制位并不
意味着存在对应事件寄存器和 64 位计数主体。

### 3.3 计数器（`ct_hpcp_top.v:940~1045`）

| 视图 | 周期 | 退休 | HPM3..18 |
|------|------|------|----------|
| M (机器) | MCYCLE 0xB00 | MINSTRET 0xB02 | MHPMCNT3 0xB03 … 0xB12 |
| S (监管) | SCYCLE 0x5E0 | SINSTRET 0x5E2 | SHPMCNT3 0x5E3 … 0x5F2 |
| U (用户) | CYCLE 0xC00 | INSTRET 0xC02 | HPMCNT3 0xC03 … 0xC12 |
| S 控制 | SCNTINTEN 0x5C4 / SCNTOF 0x5C5 / SCNTINHBT 0x5C8 / SHPMCR 0x5C9 / SHPMSP 0x5CA / SHPMEP 0x5CB | | |

`TIME`=0xC01 的读数据来自 `biu_hpcp_time`。PMU 顶层没有维护一只本地
`time` 计数器；该时间值由 BIU 路径送入，时间源本身应继续沿 BIU/SoC 连线
追踪。

标准属性必须分开看：

- `mcycle/minstret/mhpmcounter*`、`mhpmevent*`、`mcountinhibit` 和
  `cycle/time/instret/hpmcounter*` 地址属于 RISC-V 性能计数框架；
- `SCYCLE/SINSTRET/SHPMCNT*`、`SCNT*`、`SHPM*`、`MCNTWEN`、
  `MCNTINTEN/MCNTOF`、`MHPMCR/MHPMSP/MHPMEP` 是本实现提供的扩展接口，
  不能把整个地址表统称为标准 M/S/U 三视图。

---

## 4. CSR 访问：EX1/EX2 状态机与完成时序

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

**状态含义**：

1. EX1 是空闲/请求观察状态；当 `cp0_hpcp_sel=1` 时，下一次有效
   `hpcp_clk` 边沿把 `cur_state` 置为 EX2；
2. EX2 是执行或等待状态。本地访问在 EX2 组合地产生
   `hpcp_cp0_cmplt=1`；L2 映射计数器和 `MCNTOF/SCNTOF` 则等待
   `l2cnt_cmplt_ff`；
3. 完成条件成立后，下一次有效 `hpcp_clk` 边沿回到 EX1；
4. `rtu_yy_xx_flush` 在状态寄存器更新处优先强制回 EX1。

因此可以称它为“两状态控制器”，但不能把每个 CSR 从发射到完成的总延迟一律
写死为“两拍”。本地访问与远端访问的等待长度不同，CP0 请求保持方式和门控
时钟边沿也会影响外部观察到的周期数。

完成条件在本地和远端之间复用同一个 EX2 状态（`ct_hpcp_top.v:4336`）：

```verilog
assign hpcp_cp0_cmplt = (l2cnt_sel && cnt_bit_mask[0] || ofcnt_sel)
                      ? l2cnt_cmplt_ff && (cur_state == EX2)  // L2: 等返回
                      : (cur_state == EX2);                    // 本地: 立即完成
```

写使能 `hpcp_wen = cp0_hpcp_op[3] && (cur_state == EX2)`。它保证写译码只在
EX2 有效，却**不保证远端等待时只出现一个周期**：若 L2 操作在 EX2 停留多拍，
`hpcp_wen` 会持续有效。`MCNTOF/SCNTOF` 的本地 sticky 位另用
`l2cnt_cmplt_ff` 限定真正提交；映射计数器的本地影子计数寄存器可能在等待期
重复收到写使能，但 `cnt_mask` 已使软件读值选择 BIU 返回路径。分析波形时应把
“译码写使能”“本地状态真正改变”“远端请求完成”分别观察。

---

## 5. CSR 写译码与 64 位读 MUX

**写译码**（`ct_hpcp_top.v:1221~1273`）：每个寄存器一条 `xxx_wen = (cp0_hpcp_index == XXX) && hpcp_wen`。注意计数器写译码同时匹配 M 与 S 地址（`ct_hpcp_top.v:1247`）：

```verilog
assign mcycle_wen = ((cp0_hpcp_index == MCYCLE) || (cp0_hpcp_index == SCYCLE)) && hpcp_wen;
```

因为 M 地址和 C910 自定义 S 地址在顶层被译码到同一物理计数器。权限是否合法
不是由这条 OR 译码决定，而是在 CP0 CSR 合法性逻辑中先行判断。

**读 MUX**（`ct_hpcp_top.v:4056~4193`）：一个大 `case(cp0_hpcp_index)` 把所有可读地址映射到对应 `xxx_value`，输出 `data_out`。M/S/U 三套计数器地址都指向同一个 `mhpmcntN_value`（`ct_hpcp_top.v:4135~4189`）。最终：

```verilog
// ct_hpcp_top.v:4339
assign hpcp_cp0_data = (l2cnt_sel && cnt_bit_mask[0]) ? biu_hpcp_rdata[63:0] : data_out[63:0];
```

即：若当前计数器索引的 `cnt_mask` 位为 1，数据选择 BIU 返回；否则选择本地
组合读 MUX。`hpcp_cp0_data` 的组合值与“访问已经完成”是两个概念，消费者应
在 `hpcp_cp0_cmplt` 所定义的完成点采纳数据。

---

## 6. 标准计数器视图、自定义 S 别名与 mcntwen 投影

这里不能简单概括为“RISC-V 规定三套地址”。标准框架提供 Machine 计数器和
低特权级读取用的 `cycle/time/instret/hpmcounter*` 地址；C910 又增加一套
`SCYCLE/SINSTRET/SHPMCNT*` 和 `SCNT*/SHPM*` 地址，使 S 态可在授权范围内
直接管理共享物理状态。

- **同物理、多地址**：读 MUX 中 `MHPMCNT3`/`SHPMCNT3`/`HPMCNT3` 都返回 `mhpmcnt3_value`（`ct_hpcp_top.v:4137/4155/4174`）；写译码 M/S 地址都置 `mhpmcnt3_wen`（`ct_hpcp_top.v:1250`）。

- **mcntwen 投影到自定义 S 视图**：M 态可通过 `MCNTWEN` 设置 32 位授权
  位图。S 视图中的若干控制值会与该位图相与：

```verilog
assign scntinten_value = cntinten_value & {32'b0,cp0_hpcp_mcntwen};   // S 看到的中断使能
assign scntinhbt_value = {...} & {32'b0,cp0_hpcp_mcntwen};            // S 看到的 inhibit
assign scntof_value    = cntof_value    & {32'b0,cp0_hpcp_mcntwen};   // S 看到的溢出
```

S 态写 `SCNTINHBT` 时也只能改 `mcntwen` 授权的位，其余位保持 M 设置（`ct_hpcp_top.v:2567`）。

从体系结构用途看，这提供了 M 态向 S 态委派部分计数器控制权的机制。准确边界
由 CP0 的 `mcounteren/scounteren/MCNTWEN` 检查共同决定；顶层读 MUX 返回
同一物理值，并不能单独证明某个当前特权级有权访问。

- **SCE 位的精确作用域**：`hpcp_cp0_sce=sce`，M 态写 MHPMCR 可修改它，
  S 态写 SHPMCR 保持原值。CP0 中
  `regs_iui_hpcp_scr_inv` 只用 SCE 检查 `SHPMCR/SHPMSP/SHPMEP`；
  SCYCLE/SHPMCNT 等访问另由计数器授权逻辑约束。因此不能写成“SCE 是所有
  S 态 PMU 访问的总开关”。

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

- **TME=00**：令 `hpcp_cnt_en=1`，即允许计数器更新；实际是否计数仍受
  debug、特权过滤、`mcountinhibit`、事件号、L2 映射和事件增量限制。
- **TME=01（trigger/stop）**：起点匹配置 TS；终点匹配先进入
  `hpcp_stop_vld_ff`，下一拍才按优先级清 TS。它不是“终点组合匹配瞬间立即停”。
- **TME=10（范围状态）**：任一退休槽在范围内产生 `start_vld`，任一退休槽
  在范围外产生 `end_vld`。TS 更新中 `end_vld` 优先于 `start_vld`，所以同一
  退休组同时包含区间内外槽位时，最终清 TS。
- **TME=11**：`hpcp_cnt_en` 的三个条件都不成立，RTL 表现为关闭全局更新；
  文档不能把该编码默认为另一种有效区间模式。

### 8.3 起止 PC 比较逻辑

MHPMSP/MHPMEP 写入时保存 `[63:1]`，读回时 bit0 强制为 0，所以比较粒度是
2 字节半字边界。高位合法条件是写数据 `[63:39]` 全 0 或全 1；比较主体使用
保存值对应的 `[39:1]`，并结合每个退休槽的 `offset[2:0]` 和 `inst_num` 处理
一个退休项覆盖多个架构指令时的边界关系。三个退休槽分别比较，随后 OR 成
trigger/stop/start/end 条件。

这套逻辑可用于无插桩的 PC 区间观测，但不能把它简化成数学上无歧义的
`[start,end]` 开闭区间。TS 的优先级为：

```text
MHPMCR/SHPMCR 软件写 > trigger > 延迟后的 stop > end > start > 保持
```

计数器又把事件增量寄存一拍，且更新拍重新检查当前 `hpcp_cnt_en`。因此要判断
起点、终点指令本身及其同组指令是否被计入，必须同时查看退休槽、TS、
`cnt_en_ff/cnt_adder_ff` 和计数值波形，不能只依据软件设定的两个地址下结论。

`ts` 使用 `forever_cpuclk` 更新，而不是顶层 `hpcp_clk`；这能从结构上避免
TS 寄存器依赖 `hpcp_clk_en` 才采样边界条件。是否真正“自由运行”仍取决于 SoC
对 `forever_cpuclk` 的定义和上层电源管理。

---

## 9. L2 计数器借道与 BIU 交互

L2 cache 物理上属于 CIU/BIU，其性能计数器不在 PMU 内。C910 用"借道某个可编程计数器索引"的方式让软件用统一的 hpmcounter 接口访问 L2 计数。

### 9.1 cnt_mask 与事件索引

`ct_hpcp_top.v:4199~4270`：当软件把某可编程计数器的事件号写成 L2 事件（写 `mhpmeventN` 且 `hpcp_wdata[5:2]==4'b0100`，即事件号 16~19 区段），`cnt_mask_set` 置位，对应 `cnt_mask[x]=1`，并把该计数器索引记进 `cnt0/1/2/3_event_index`（4 个 L2 子计数器：read access / read miss / write access / write miss，由 `hpcp_wdata[1:0]` 选）。

`cnt_mask[x]=1` 的效果：

1. 关闭该计数器在核内的累加（`!cnt_mask[x]` 在 `mhpmcntN_en` 里，`ct_hpcp_top.v:1300`）——避免重复计数；
2. 读该计数器时返回 BIU 数据而非本地值（`ct_hpcp_top.v:4339`）；
3. 溢出与中断改用 L2 来源 `l2of_int`（`ct_hpcp_top.v:3024`）。

这里有两个软件必须遵守、但 RTL 没有自动纠正的映射约束：

1. 四个 L2 事件各只有一个 `cntN_event_index`。若先把 HPM3 映射到 event16，
   又把 HPM4 映射到 event16，event16 的索引会改成 4，但 HPM3 的
   `cnt_mask[3]` 仍保持 1；HPM3 于是处于“本地已屏蔽、远端索引已转走”的
   悬空状态；
2. 若一个已映射槽直接从 event16 改为 event17，同周期 `cnt_mask_set` 与
   `cnt_mask_clr` 都可能成立，而状态机优先执行 set。新 event17 索引会记录该
   槽，旧 event16 索引可能仍保留同一槽，形成重复/陈旧映射。

稳妥的软件顺序是：先把旧 `mhpmeventN` 写成 0 或其他非 L2 事件，让 clear
分支撤销旧映射；再写新的 16~19 事件。并且四种 L2 事件各只分配给一个 HPM
槽。

### 9.2 向 BIU 发请求

`ct_hpcp_top.v:4288~4353`：把 CSR 操作翻译成 `hpcp_biu_op[15:0]`（含 L2 计数器索引 `l2cnt_reg_idx`、写使能 `l2of_wen`、op），`hpcp_biu_sel` 拉起请求，`hpcp_biu_cnt_en[3:0]` 是 4 个 L2 子计数器的计数使能（同样受 dbgon/cnt_mode_dis/hpcp_cnt_en 门控，`ct_hpcp_top.v:4296~4299`）。

返回时，`biu_hpcp_cmplt` 在 `hpcp_clk` 边沿形成单周期
`l2cnt_cmplt_ff`，该寄存值才参与 CP0 完成和 MCNTOF 本地写提交。
`biu_hpcp_l2of_int` 的四位镜像用“当前值 XOR 上次保存值”检测**任何变化**，
不是只检测 0→1 上升沿；变化时按四个事件索引重建 32 位 `l2of_int`。

体系结构意图是让 L2 计数通过 HPM 槽访问，但它并非与本地计数器“完全相同”：
访问需要远端完成，四种事件存在一对一索引限制，MCNTOF/SCNTOF 整体也被
路由到 BIU，映射和清除顺序必须由软件维护。

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

**是什么**：该广播严格等于
`!rtu_yy_xx_dbgon && !cnt_mode_dis`。其中 `cnt_mode_dis` 是已寄存的特权过滤
状态。

它没有包含 TME/TS 的 `hpcp_cnt_en`，也没有包含任一
`mcountinhibit`、事件号或 `cnt_mask`。所以即使 TME 区间尚未开启、所有 HPM
事件号都是 0，广播仍可能为 1。各接收单元可用它门控部分事件生成逻辑，但
具体哪些逻辑被门控要回到各模块逐一确认。RTL 可证明存在广播门控条件，不能
仅据此量化节能，更不能称“默认零开销”。

---

## 11. 门控时钟

PMU 顶层控制时钟 `hpcp_clk` 的局部使能聚合了控制寄存器写、CP0 访问、
BIU 完成、L2 溢出镜像变化、flush、本地溢出通知和特权过滤变化等条件
（`ct_hpcp_top.v:1067~1086`）。这份列表不是“所有性能事件”的 OR；普通事件
计数由各 `ct_hpcp_cnt` 实例自己的门控时钟处理。

因此空闲时可能关闭的是顶层控制状态时钟，不能概括成“整个 PMU 时钟停摆”。
计数器和事件寄存器分别从 `forever_cpuclk` 生成局部时钟。目标实现是否使用
真实 ICG、实际关闭比例和功耗收益，需要结合综合配置、门级网表和功耗分析。

---

## 本章小结

HPCP 顶层把 CSR 访问、事件选择、计数更新、区间控制、L2 代理和溢出中断组织在一起。访问沿 EX1/EX2 控制推进，本地计数器可在 EX2 完成，映射到 L2 的访问则在同一状态框架中等待远端返回，因此相同状态数不代表固定相同延迟。标准 M/U 地址与 C910 自定义 S 级接口共享底层计数状态，但合法性还取决于 CP0 提供的多组 enable、委派和特权条件，不能只看最终读 MUX。`cnt_mask` 选择 L2 代理时同时关闭对应本地采样，并切换读值与 overflow 来源。

TME/TS 用退休 PC 建立 trigger、stop 和 range 计数窗口，其优先级、停止延迟、同组多退休以及计数器前级打一拍都会影响边界是否包含某个事件。顶层、事件寄存器和各计数器都有局部门控结构；普通程序结果不依赖计数值，但事件信号扇出、区间比较、overflow 中断以及实际门控单元仍会进入面积和时序实现，不能笼统声称监测“绝对零影响”。验证一个性能计数结果时，应把 CSR 配置、事件源、特权与 debug 过滤、TME/TS 状态、L2 映射、增量流水和计数器写入放在同一时间轴上，先确认口径，再解释数值。
