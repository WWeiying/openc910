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
12. [设计取舍小结](#设计取舍小结)

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
| `cpuclk` | in | 1 | 36 | 门控后时钟（仅写 PMP 时翻转） |
| `cpurst_b` | in | 1 | 37 | 低有效复位 |

---

## 3. 参数与关键寄存器

### 3.1 参数

```verilog
parameter ADDR_WIDTH = 28+1;   // 行 137，= 29
```

`ADDR_WIDTH=29`。其中 28 = `PA_WIDTH(40) - 12`，即物理地址去掉低 12 位（4KB 页内偏移）
后剩下的页帧位数；额外 +1 位用于 NAPOT 编码（末尾那个区分大小的"1"）和 TOR 比较，
所以地址寄存器是 29 位宽 `[28:0]`。

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
| L | Lock：① 写保护该区 cfg/addr；② 让 R/W/X **对 M 态也强制生效** | 一旦置 1，只有复位能清 |

**L 锁位的双重作用**是 PMP 安全模型的核心：

1. **写保护**：L=1 后该区的 pmpcfg 和 pmpaddr 都不能再被软件改写（见第 6、9 节）。
2. **对 M 态强制**：正常情况下 M 态对命中区也是"默认全通"的特例之外——但只要区命中，
   M 态就按该区 R/W/X 执行（见 `02_pmp_match.md`）。L 的意义是让这种限制**不可撤销**，
   于是 M 态固件能把自己的代码段锁成只读，且无法再解锁，实现真正的"固件自保护"与
   "secure boot 后不可篡改"。

---

## 6. 锁定后只复位能改：写使能里的 !lock

每个 cfg 的写使能都带 `&& !pmpNcfg_lock`。以 entry0 为例（行 146）：

```verilog
assign pmp_updt_pmp0cfg = pmp_csr_wen[0] && !pmp0cfg_lock;
```

含义：**只有当该区未被锁定时，写 pmpcfg0 才能更新 entry0**。一旦 `pmp0cfg_lock=1`，
`pmp_updt_pmp0cfg` 恒为 0，always 块走到 else 分支保持原值（行 165-172），任何 CSR 写
都被忽略。

唯一能清掉 lock 的路径是复位（行 149-156，`!cpurst_b` 时所有位清 0）。这正是
"**锁定后只复位能改**"——硬件层面保证锁定区在运行期间绝对不可篡改，符合
RISC-V "L 位 sticky（粘滞），只能由复位清除"的规定。

8 个区完全对称：entry1 行 175、entry2 行 204、……entry7 行 349，写使能都是
`pmp_csr_wen[0] && !pmpNcfg_lock`（注意 8 个 cfg 都看 `pmp_csr_wen[0]`，因为它们共享
同一个 pmpcfg0 CSR，靠各自 lock 独立保护）。

> 关键细节：8 个 cfg 字节写的是**同一个 CSR**（pmpcfg0），一次写会同时更新 8 个区——
> 但每个区各自的 lock 独立把关。所以即便一次写 pmpcfg0，已锁定的区纹丝不动，
> 未锁定的区被更新。

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

标准 pmpaddr CSR 里存的是"物理地址右移 2 位"（即按 4 字节字编址，因为 NA4 最小粒度 4B）。
但 OpenC910 的最小 PMP 粒度是 **4KB**（NA4 未实现，见 `02_pmp_match.md`），所以地址寄存器
只需保存到页帧级别。具体对应关系：

- 物理地址 PA[39:12] = 28 位页帧号；
- pmpaddr CSR 软件视角里，PA[39:12] 落在 CSR 的 bit[37:10] 附近（PA 右移 2 后页帧位上移）；
- RTL 取 `wdata[37:9]` 这 29 位存入寄存器，其中高 28 位是页帧号，最低 1 位（bit 9 对应的位）
  是 NAPOT 编码用的"区分大小的连续 1 的最低位"。

读回时反向左移（行 522）：

```verilog
| {64{pmp_csr_sel[2]}} & {{(64-ADDR_WIDTH-9){1'b0}}, pmpaddr0_value[28:0], 9'b0}
```

把 29 位寄存器值放回 bit[37:9]，低 9 位补 0，高位补 0。**低 9 位恒读 0** 正是 4KB 粒度的
体现——软件写进去的低于 4KB 粒度的地址位被丢弃、读回为 0（WARL：Write-Any-Read-Legal）。

> 一句话：标准 pmpaddr 以 4B 为粒度，C910 只支持 4KB，于是地址寄存器只保存页帧级的高位，
> 低 9 位（对应 4B→4KB 的差，2^9 倍）永远读 0，物理上省了 9 个触发器/区。

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
读这些 CSR 全返回 0，写被丢弃。**这是用最小代价保留 CSR 兼容性**：软件探测 16 个区时
不会报非法 CSR，但实际只有 8 个有效。

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

每路用 `{64{sel}}` 把 one-hot 位扩成 64 位掩码，与对应值相与后全部相或。地址类回值统一
左移 9 位（`pmpaddrN_value, 9'b0`），低 9 位补 0（4KB 粒度），与第 8 节写入路径对称。

---

## 设计取舍小结

| 决策 | 取舍 | 原因 |
|------|------|------|
| cfg 拆 5 个 reg 存储，保留位不存 | 面积 | bit[6:5] 恒 0，无需触发器，读回补 0 即可 |
| 写使能带 `!lock` | 安全 | 实现 L 位 sticky，锁定后只复位可清，防运行期篡改 |
| pmpaddr 写还看下一区 TOR+Lock | 安全正确性 | 防止改 pmpaddr_i 间接改动被锁 TOR 区的下界，堵住绕锁漏洞 |
| 地址寄存器只存 [37:9]（29 位），低 9 位读 0 | 面积 | 仅支持 4KB 粒度，无需保存 4B 级低位，省 9 触发器/区 |
| entry8~15、pmpcfg2 硬连 0 | 兼容 vs 面积 | 保留 16 区 CSR 兼容，实际 8 区，未实现区零成本恒 OFF |
| 8 个 cfg 共享 pmpcfg0 写、各自 lock 把关 | 符合 RV64 | 一个 pmpcfg CSR 打包 8 区，写一次全更新，靠 lock 区分 |

*文档覆盖 ct_pmp_regs.v 全部 542 行逻辑。*
