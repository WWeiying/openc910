# C910 PMP 寄存器堆（ct_pmp_regs）模块详细教学文档

> RTL 文件：`C910_RTL_FACTORY/gen_rtl/pmp/rtl/ct_pmp_regs.v`（约 542 行）
>
> 相关文件：`ct_pmp_top.v`（CSR 译码、写使能来源）、`ct_pmp_acc.v`（消费 cfg/addr 输出）；配置宏 `cpu/rtl/cpu_cfig.h`（`PA_WIDTH 40`）

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键寄存器](#3-参数与关键寄存器)
4. [pmpcfg：每区一个配置字节](#4-pmpcfg每区一个配置字节)
5. [R/W/X 与 L 锁位的语义](#5-rwx-与-l-锁位的语义)
6. [锁定后只复位能改：写使能里的 !lock](#6-锁定后只复位能改写使能里的-lock)
7. [pmpcfg0 的打包布局（8 字节拼 64 位）](#7-pmpcfg0-的打包布局8-字节拼-64-位)
8. [pmpaddr：地址寄存器与 4KB 粒度移位](#8-pmpaddr地址寄存器与-4kb-粒度移位)
9. [pmpaddr 写使能：相邻区 TOR 锁定保护](#9-pmpaddr-写使能相邻区-tor-锁定保护)
10. [entry8~15 与 pmpcfg2 全硬连 0](#10-entry815-与-pmpcfg2-全硬连-0)
11. [读回通路：one-hot 选择](#11-读回通路one-hot-选择)
12. [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 职责

`ct_pmp_regs` 是 PMP 的寄存器堆。它存放 8 个 PMP 区的配置和地址：

- 8 个 **pmpcfg 字节**（拆成 `pmpNcfg_readable / writable / executeable / addr_mode / lock`
  五个 reg，N=0~7）；
- 8 个 **pmpaddr 寄存器**（`pmpaddr0_value`~`pmpaddr7_value`，各 29 位）。

它对外做三件事：
1. 接收 `ct_pmp_top` 译码出的写使能 `pmp_csr_wen` 和写数据 `cp0_pmp_wdata`，更新寄存器；
2. 把配置打包成 `pmpcfg0_value`（64 位）和 `pmpcfg2_value`（64 位，恒 0）输出；
3. 通过 `pmp_csr_sel` one-hot 把被选中的 CSR 读回值组成 `pmp_cp0_data` 返回 CP0。

### 1.2 位置

```
ct_pmp_top
   │  pmp_csr_wen / pmp_csr_sel / cp0_pmp_wdata
   ▼
ct_pmp_regs ──► pmpcfg0_value, pmpcfg2_value   （广播给 5 个 ct_pmp_acc）
            ──► pmpaddr0_value ~ pmpaddr7_value （广播给 5 个 ct_pmp_acc）
            ──► pmp_cp0_data                    （读回 CP0）
```

这是 PMP 中**唯一带时序状态**的模块（其余全是组合逻辑）。

---

## 2. 端口说明

### 2.1 写入接口

| 端口 | 方向 | 位宽 | 行号 | 含义 |
|------|------|------|------|------|
| `cp0_pmp_wdata` | in | 64 | 35 | 要写入的 CSR 数据 |
| `pmp_csr_wen` | in | 18 | 39 | 写使能 one-hot（bit0=cfg0, bit1=cfg2, bit2~17=addr0~15） |
| `pmp_csr_sel` | in | 18 | 38 | 读选择 one-hot（同上编码） |

### 2.2 读出 / 广播接口

| 端口 | 方向 | 位宽 | 行号 | 含义 |
|------|------|------|------|------|
| `pmp_cp0_data` | out | 64 | 40 | 读出的 CSR 值，回 CP0 |
| `pmpcfg0_value` | out | 64 | 49 | entry0~7 的配置打包字 |
| `pmpcfg2_value` | out | 64 | 50 | entry8~15 配置（恒 0） |
| `pmpaddr0_value`~`7_value` | out | 29 each | 41-48 | 8 个地址寄存器值 |

### 2.3 时钟复位

| 端口 | 方向 | 位宽 | 行号 | 含义 |
|------|------|------|------|------|
| `cpuclk` | in | 1 | 36 | 顶层门控后的状态时钟；正常功能模式下由 PMP CSR 写请求触发，扫描/门控控制还可改变其行为 |
| `cpurst_b` | in | 1 | 37 | 低有效复位 |

---

## 3. 参数与关键寄存器

### 3.1 参数

```verilog
parameter ADDR_WIDTH = 28+1;   // 行 137，= 29
```

`ADDR_WIDTH=29`。这里不能把它简单理解为“28 位页号再额外加 1 位”。寄存器实际保存
软件写入 `pmpaddr` CSR 的 `[37:9]`：

- 内部 `[28:1]` = CSR `[37:10]`，在比较器中与 `PA[39:12]` 对齐；
- 内部 `[0]` = CSR `[9]`，NAPOT 用它及更高位的连续 1 编码 4KB 以上的范围；
- CSR `[8:0]` 不保存，读回补 0。

因此 29 位来自“保留 CSR `[37:9]`”这一实现切片。TOR 比较只使用内部 `[28:1]`，NAPOT
mask 译码使用完整 `[28:0]`；两种模式对最低保存位的用法不同。

### 3.2 寄存器清单（行 53-100）

每个 entry 的配置被拆成 5 个独立 reg（以 entry0 为例，行 53-57）：

| reg | 位宽 | 含义 |
|-----|------|------|
| `pmp0cfg_readable` | 1 | R：可读 |
| `pmp0cfg_writable` | 1 | W：可写 |
| `pmp0cfg_executeable` | 1 | X：可执行 |
| `pmp0cfg_addr_mode[1:0]` | 2 | A：匹配模式 OFF/TOR/NA4/NAPOT |
| `pmp0cfg_lock` | 1 | L：锁位 |

8 个 entry 共 8 组。另有 8 个 `pmpaddrN_value[28:0]`（行 93-100）。

---

## 4. pmpcfg：每区一个配置字节

RV64 中每个 PMP 区的配置是 **1 个字节**（8 位），8 个区刚好打包进一个 64 位 CSR
（pmpcfg0）。单个配置字节的布局（RISC-V 标准）：

```
 bit:  7    6   5    4    3    2    1    0
      [L] [ 0  0 ] [ A1 A0 ] [X] [W] [R]
```

- bit[2:0] = R/W/X 权限；
- bit[4:3] = A 匹配模式；
- bit[6:5] = 保留（写 0，RTL 中打包时填 `2'b0`）；
- bit[7]   = L 锁位。

RTL 把这 8 位拆成 5 个 reg 存储（不存保留的 bit[6:5]，读回时补 0）。

以 entry0 的写入为例（行 157-164）：

```verilog
else if(pmp_updt_pmp0cfg)
begin
  pmp0cfg_readable       <= cp0_pmp_wdata[0];     // R
  pmp0cfg_writable       <= cp0_pmp_wdata[1];     // W
  pmp0cfg_executeable    <= cp0_pmp_wdata[2];     // X
  pmp0cfg_addr_mode[1:0] <= cp0_pmp_wdata[4:3];   // A
  pmp0cfg_lock           <= cp0_pmp_wdata[7];     // L
end
```

entry1 取 `wdata[15:8]`（行 188-192），entry2 取 `wdata[23:16]`（行 217-221），
……每个 entry 在 64 位写数据里占连续 8 位，逐区右移 8。

---

## 5. R/W/X 与 L 锁位的语义

| 位 | 含义 | 备注 |
|----|------|------|
| R | 命中此区时允许读 | |
| W | 命中此区时允许写 | RISC-V 规定 `W=1,R=0` 为保留组合（硬件不强制，软件应避免） |
| X | 命中此区时允许执行（取指） | |
| L | Lock：① 阻止该区 cfg/addr 的后续更新；② 由 MMU 消费端决定 M 模式是否可旁路 R/W/X | 一旦置 1，当前 RTL 只有复位路径能清 |

**L 锁位的双重作用**是 PMP 安全模型的核心：

1. **写保护**：L=1 后该区的 pmpcfg 和 pmpaddr 都不能再被软件改写（见第 6、9 节）。
2. **控制 M 模式旁路**：`ct_pmp_acc` 无论 L 为 0 还是 1，都会返回命中项的 R/W/X/L；
   MMU 消费端在“有效模式为 M 且 L=0”时旁路 R/W/X 限制，在 L=1 时不旁路。也就是说，
   “L 使权限约束 M 模式”是 PMP 与 MMU 联合实现的结果，不是寄存器堆本身发出拒绝。

固件可以据此构造自保护区，但“锁住一个区”不自动等于“安全启动不可篡改”：还必须正确
配置范围、权限、启动顺序，并保证其他主设备也受相应系统级保护。

---

## 6. 锁定后只复位能改：写使能里的 !lock

每个 cfg 的写使能都带 `&& !pmpNcfg_lock`。以 entry0 为例（行 146）：

```verilog
assign pmp_updt_pmp0cfg = pmp_csr_wen[0] && !pmp0cfg_lock;
```

含义：**只有当该区未被锁定时，写 pmpcfg0 才能在下一个 `cpuclk` 上升沿更新 entry0**。
一旦 `pmp0cfg_lock=1`，`pmp_updt_pmp0cfg` 恒为 0；顶层仍可能译码到这次写请求并打开
门控时钟，但该 entry 的 always 块只保持原值。这里要区分“CSR 写请求到达”“门控时钟被
请求打开”和“某个 entry 的状态实际更新”三个事件。

唯一能清掉 lock 的路径是复位（行 149-156，`!cpurst_b` 时所有位清 0）。这正是
"**锁定后只复位能改**"——硬件层面保证锁定区在运行期间绝对不可篡改，符合
RISC-V "L 位 sticky（粘滞），只能由复位清除"的规定。

8 个区完全对称：entry1 行 175、entry2 行 204、……entry7 行 349，写使能都是
`pmp_csr_wen[0] && !pmpNcfg_lock`（注意 8 个 cfg 都看 `pmp_csr_wen[0]`，因为它们共享
同一个 pmpcfg0 CSR，靠各自 lock 独立保护）。

> 关键细节：8 个 cfg 字节写的是**同一个 CSR**（pmpcfg0）。一次有效写会让所有未锁定
> entry 在同一个 `cpuclk` 上升沿分别采样各自的写数据切片；已锁定 entry 保持原值。
> “同时更新”指同一时钟沿的并行状态更新，不是按 entry0 到 entry7 依次执行。

---

## 7. pmpcfg0 的打包布局（8 字节拼 64 位）

读回和广播时，8 个 entry 的配置要重新拼成 64 位。行 384-391：

```verilog
assign pmpcfg0_value[31:0] = {
  pmp3cfg_lock,2'b0,pmp3cfg_addr_mode[1:0],pmp3cfg_executeable,pmp3cfg_writable,pmp3cfg_readable,  // [31:24] entry3
  pmp2cfg_lock,2'b0,pmp2cfg_addr_mode[1:0],pmp2cfg_executeable,pmp2cfg_writable,pmp2cfg_readable,  // [23:16] entry2
  pmp1cfg_lock,2'b0,pmp1cfg_addr_mode[1:0],pmp1cfg_executeable,pmp1cfg_writable,pmp1cfg_readable,  // [15:8]  entry1
  pmp0cfg_lock,2'b0,pmp0cfg_addr_mode[1:0],pmp0cfg_executeable,pmp0cfg_writable,pmp0cfg_readable}; // [7:0]   entry0
assign pmpcfg0_value[63:32] = { ... entry7, entry6, entry5, entry4 ... };  // 行 388-391
```

每个字节按 `{L, 2'b0, A[1:0], X, W, R}` 重组，保留位回填 `2'b0`。8 个字节从低到高对应
entry0~7。这份 `pmpcfg0_value` 同时用于：
- CSR 读回（行 520）；
- 广播给 5 个 `ct_pmp_acc` 做权限判定（acc 直接按位切片取各 entry 的 R/W/X/A）。

打包顺序很重要：`ct_pmp_acc` 取 entry_i 的权限就是切 `pmpcfg0_value[8i+7 : 8i]`，
所以打包与解包必须严格对齐字节位置。

---

## 8. pmpaddr：地址寄存器与 4KB 粒度移位

### 8.1 寄存器宽度与写入（以 pmpaddr0 为例，行 402-411）

```verilog
assign pmp_updt_pmpaddr0 = pmp_csr_wen[2] && !pmpcfg0_value[7] && !(pmpcfg0_value[15] && (pmpcfg0_value[12:11]==2'b01));
always @(posedge cpuclk or negedge cpurst_b)
  if(!cpurst_b)        pmpaddr0_value <= 0;
  else if(pmp_updt_pmpaddr0) pmpaddr0_value[28:0] <= cp0_pmp_wdata[37:9];  // ADDR_WIDTH+8:9 = 37:9
  else                 pmpaddr0_value <= pmpaddr0_value;
```

注意写入取的是 `cp0_pmp_wdata[ADDR_WIDTH+8 : 9]` = `wdata[37:9]`（29 位）。

### 8.2 为什么是 [37:9] 而不是 [55:0]？—— 4KB 粒度

标准 `pmpaddr` 编码以物理地址右移 2 位后的数值为基础。当前 RTL 只保存 CSR `[37:9]`，
并在读回时把 `[8:0]` 补 0。具体对应关系是：

- 物理地址 PA[39:12] = 28 位页帧号；
- `PA[39:12]` 对应 `pmpaddr[37:10]`，写入内部寄存器 `[28:1]`；
- `pmpaddr[9]` 写入内部 `[0]`，用于 NAPOT 的 4KB/8KB 大小分界；
- `pmpaddr[8:0]` 被丢弃，不能影响匹配；
- TOR 比较连内部 `[0]` 也不使用，所以 TOR 的有效上下界按 4KB 对齐；
- NAPOT 从内部 `[0]` 开始译码连续 1，最小可表达的有效范围为 4KB。

读回时反向左移（行 522）：

```verilog
| {64{pmp_csr_sel[2]}} & {{(64-ADDR_WIDTH-9){1'b0}}, pmpaddr0_value[28:0], 9'b0}
```

把 29 位寄存器值放回 bit[37:9]，低 9 位和更高的未实现位补 0。由 RTL 可以直接确认：
软件写入的 CSR `[8:0]` 不被保存，随后读回为 0。本文将其称为“当前 RTL 的读写掩码行为”；
是否满足某一版特权架构对不同 A 模式的全部 WARL 读回要求，还需用对应规范版本和定向测试
单独确认，不能只因“写后读为合法值”就下结论。

> 一句话：该实现保留 `pmpaddr[37:9]`，丢弃 `[8:0]`；比较器再按 TOR 或 NAPOT 解释保留下来
> 的位。由源码可推断少存了低 9 位状态，但具体面积收益必须以综合结果为准。

---

## 9. pmpaddr 写使能：相邻区 TOR 锁定保护

pmpaddr 的写使能不仅看自己区的 lock，还要看**下一个区**是否锁定且为 TOR 模式。
再看 pmpaddr0（行 402）：

```verilog
assign pmp_updt_pmpaddr0 = pmp_csr_wen[2]
                         && !pmpcfg0_value[7]                              // 本区(entry0) 未锁
                         && !(pmpcfg0_value[15] && (pmpcfg0_value[12:11]==2'b01)); // entry1 未"锁定且 TOR"
```

- `pmpcfg0_value[7]` = entry0 的 L；
- `pmpcfg0_value[15]` = entry1 的 L；
- `pmpcfg0_value[12:11]` = entry1 的 A 模式，`2'b01` = TOR。

**为什么要看下一个区？** 因为 TOR（Top Of Range）模式下，entry_i 的下界是
`pmpaddr[i-1]`、上界是 `pmpaddr[i]`。也就是说 **entry1（若为 TOR）的下界就是 pmpaddr0**。
如果 entry1 被锁定为 TOR，那么改 pmpaddr0 等于偷偷改动了被锁区 entry1 的覆盖范围——
这会绕过锁定。所以规范要求：**当 pmpaddr_{i} 是某个被锁定 TOR 区的下界时，pmpaddr_{i} 也
不可写**。RTL 用 `!(下一个区.L && 下一个区.A==TOR)` 精确实现了这条保护。

8 个区依此类推（pmpaddr1 看 entry2，行 414；……pmpaddr6 看 entry7，行 474；pmpaddr7
看 entry8，而 entry8 在 pmpcfg2 里恒 0，行 486）。

---

## 10. entry8~15 与 pmpcfg2 全硬连 0

虽然 CSR 接口预留了 16 个区，但 OpenC910 只实现 8 个。entry8~15 的地址寄存器全部硬连 0
（行 498-505）：

```verilog
assign pmpaddr8_value[28:0]  = {ADDR_WIDTH{1'b0}};
... 
assign pmpaddr15_value[28:0] = {ADDR_WIDTH{1'b0}};
```

pmpcfg2（承载 entry8~15 的配置）也恒 0（行 393）：

```verilog
assign pmpcfg2_value[63:0] = 64'b0;
```

效果：entry8~15 的匹配模式恒为 OFF（A=0），永不命中、永不影响判权——等于"不存在"。
读这些 CSR 在本模块返回 0，写请求没有对应状态更新逻辑。顶层仍会译码这些地址并可能打开
一次门控时钟。源码没有提供“为什么保留这些译码”的设计说明，也不应仅凭本模块断言所有
软件探测行为或非法指令行为；可以确定的只是该 PMP 数据通路中 entry8~15 不可配置且不匹配。

---

## 11. 读回通路：one-hot 选择

CSR 读回是一个 18 路 one-hot 与或选择（行 520-537）：

```verilog
assign pmp_cp0_data[63:0] =
    {64{pmp_csr_sel[0]}} & pmpcfg0_value[63:0]                                  // pmpcfg0
  | {64{pmp_csr_sel[1]}} & pmpcfg2_value[63:0]                                  // pmpcfg2 (=0)
  | {64{pmp_csr_sel[2]}} & {..., pmpaddr0_value[28:0], 9'b0}                    // pmpaddr0
  | ...
  | {64{pmp_csr_sel[17]}} & {..., pmpaddr15_value[28:0], 9'b0};                 // pmpaddr15
```

每路用 `{64{sel}}` 把 one-hot 位扩成 64 位掩码，与对应值相与后全部相或。地址类回值把
内部值放回 CSR `[37:9]`，并把低 9 位补 0，与第 8 节写入切片对称。这是一条纯组合读数据
路径；它没有独立的 `read_valid` 或 `read_complete`，读请求是否成立由顶层 CP0/CSR 通路保证。

---

## 本章小结

每个有效 PMP entry 只保存 cfg 中实际使用的 `L/A/X/W/R` 五类状态，保留位 `[6:5]` 不进入触发器，读回时补 0。pmpcfg0 的一次 64 位写同时覆盖八个字节槽，但每个 entry 都用自己的 lock 决定是否接受更新；L 一旦置位只能由复位清除。pmpaddr_i 的写使能除检查本项 lock 外，还检查下一项是否处于锁定 TOR 模式，因为 TOR_i 的下界来自 pmpaddr_{i-1}，修改前一地址也可能间接改变已锁区域。这个相邻依赖是判断锁定正确性的关键，不能只检查目标地址寄存器自己的 L 位。

当前地址寄存器只保存 CSR 地址字段 `[37:9]`，低 9 位读回为 0，比较粒度与这种页号级接口一致。entry8 至 entry15 和 pmpcfg2 没有实际配置状态，硬连为 0；地址被译码不等于存在可命中的 PMP 区域。CSR 指令是否合法仍由 CP0 顶层决定，PMP 本章只描述进入模块后的状态更新和读回。定向验证应覆盖未锁写入、L 置位后的 cfg/address 写、下一锁定 TOR 对前一地址的保护、复位解锁以及未实现 entry 的恒零行为。
