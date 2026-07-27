# C910 PMP 地址匹配与权限判定（ct_pmp_comp_hit + ct_pmp_acc）模块详细教学文档

> RTL 文件：
> - `C910_RTL_FACTORY/gen_rtl/pmp/rtl/ct_pmp_comp_hit.v`（约 136 行）—— 单区地址匹配
> - `C910_RTL_FACTORY/gen_rtl/pmp/rtl/ct_pmp_acc.v`（约 306 行）—— 单通道权限判定（含 8 个 comp_hit）
>
> 相关文件：`ct_pmp_top.v`（例化 5 个 acc）、`ct_pmp_regs.v`（提供 cfg/addr）；配置宏 `cpu/rtl/cpu_cfig.h`（`PA_WIDTH 40`）

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键信号](#3-参数与关键信号)
4. [四种匹配模式与 NA4 未实现](#4-四种匹配模式与-na4-未实现)
5. [TOR 模式：用上一区地址做下界](#5-tor-模式用上一区地址做下界)
6. [NAPOT 模式：末尾连续 1 编码基址+大小](#6-napot-模式末尾连续-1-编码基址大小)
7. [4KB 粒度](#7-4kb-粒度)
8. [8 个并行检查器与下界链](#8-8-个并行检查器与下界链)
9. [优先级编码：低编号区优先](#9-优先级编码低编号区优先)
10. [M 态默认全通与锁定规则约束](#10-m-态默认全通与锁定规则约束)
11. [有效特权模式与 MPRV](#11-有效特权模式与-mprv)
12. [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

### 1.1 职责

这两个模块共同完成"给一个物理地址，在当前特权级下能不能 R/W/X"的判定：

- **`ct_pmp_comp_hit`**：对**单个 PMP 区**做地址匹配——给定区的 `pmpaddr` 和匹配模式 A，
  判断输入物理地址 `mmu_pmp_pa_y` 是否落在该区范围内，输出 1 位 `pmp_mmu_hit_x`。
- **`ct_pmp_acc`**：一条访问检查通道。内部例化 **8 个 `ct_pmp_comp_hit`**（entry0~7），
  收集 8 位命中向量，做**优先级编码**选出最低编号的命中区，取其 R/W/X/L 作为权限结果
  `pmp_mmu_flg_y[3:0]`；若无区命中，用特权级相关的默认值。

`ct_pmp_top` 例化 5 个 `ct_pmp_acc`（对应 5 个并发物理地址），故全 PMP 内部共
8×5 = 40 个 `ct_pmp_comp_hit`。**这两个模块全是组合逻辑**，当拍出结果。

### 1.2 位置

```
ct_pmp_acc (一条通道)
  ├── addr_match_modeN  ← pmpcfg0_value 切片
  ├── ct_pmp_comp_hit ×8  ← pmpaddrN_value + mmu_pmp_pa_y → pmp_mmu_hitN
  │       (entry0..7，下界链相连)
  ├── pmp_hit[7:0]  汇聚 8 个命中
  ├── 优先级编码 casez  → 选最低命中区的 R/W/X/L
  └── pmp_mmu_flg_y[3:0]  = {L, X, W, R}  → 回 MMU
```

---

## 2. 端口说明

### 2.1 ct_pmp_comp_hit 端口

| 端口 | 方向 | 位宽 | 行号 | 含义 |
|------|------|------|------|------|
| `addr_match_mode_x` | in | 2 | 25 | 该区的 A 模式（OFF/TOR/NA4/NAPOT） |
| `mmu_pmp_pa_y` | in | 28 | 27 | 待检查物理地址 PA[39:12] |
| `pmpaddr_x_value` | in | 29 | 28 | 该区地址寄存器值 |
| `mmu_addr_ge_bottom_x` | in | 1 | 26 | 下界比较：地址 ≥ 本区下界（来自上一区，TOR 用） |
| `mmu_addr_ge_upaddr_x` | out | 1 | 29 | 地址 ≥ 本区 pmpaddr（作为下一区的下界，TOR 用） |
| `pmp_mmu_hit_x` | out | 1 | 30 | 本区命中 |

### 2.2 ct_pmp_acc 端口

| 端口 | 方向 | 位宽 | 行号 | 含义 |
|------|------|------|------|------|
| `cur_priv_mode` | in | 2 | 35 | 当前特权模式 |
| `cp0_pmp_mpp` | in | 2 | 34 | mstatus.MPP（MPRV 生效时用） |
| `pmp_mprv_status_y` | in | 1 | 37 | 本通道 MPRV 是否生效（顶层算好） |
| `mmu_pmp_pa_y` | in | 28 | 36 | 待检查物理地址 |
| `pmpaddr0_value`~`7_value` | in | 29 each | 38-45 | 8 区地址 |
| `pmpcfg0_value` / `pmpcfg2_value` | in | 64 each | 46-47 | 配置打包字 |
| `pmp_mmu_flg_y` | out | 4 | 48 | 权限结果 {L, X, W, R} |

---

## 3. 参数与关键信号

`ct_pmp_comp_hit` 参数（行 49）：

```verilog
parameter ADDR_WIDTH = `PA_WIDTH-12;   // = 40-12 = 28
```

`ADDR_WIDTH=28`，即页帧号位数。地址寄存器 `pmpaddr_x_value` 是 29 位 `[28:0]`，其中
`[28:1]`（28 位）对齐页帧号，`[0]` 是 NAPOT 的最低编码位。

`ct_pmp_acc` 关键 wire：

| 信号 | 位宽 | 行号 | 含义 |
|------|------|------|------|
| `cp0_priv_mode` | 2 | 64 | 有效特权模式（含 MPRV 选择） |
| `cp0_mach_mode` | 1 | 62 | 有效模式是否 M 态 |
| `pmp_hit[15:0]` | 16 | 84 | 命中向量（高 8 位恒 0） |
| `pmp_default_flg[3:0]` | 4 | 83 | 无命中时的默认权限 |
| `addr_match_mode0`~`7` | 2 each | 54-61 | 各区 A 模式（从 cfg 切片） |
| `mmu_addr_ge_bottom0`~`7` | 1 each | 66-73 | 各区 TOR 下界比较结果 |
| `mmu_addr_ge_upaddr0`~`7` | 1 each | 74-81 | 各区 ≥pmpaddr，喂给下一区 |

---

## 4. 四种匹配模式与 NA4 未实现

A 字段 2 位，RISC-V 定义 4 种模式。`ct_pmp_comp_hit` 行 63-69：

```verilog
case(addr_match_mode_x[1:0])
  2'b00:   pmp_mmu_hit_x = 1'b0;                 //OFF   不匹配，区禁用
  2'b01:   pmp_mmu_hit_x = mmu_tor_addr_match;   //TOR   [pmpaddr_{i-1}, pmpaddr_i)
  2'b10:   pmp_mmu_hit_x = mmu_na4_addr_match;   //NA4   固定 4 字节
  2'b11:   pmp_mmu_hit_x = mmu_napot_addr_match; //NAPOT 2 的幂自然对齐区
  default: pmp_mmu_hit_x = 1'b0;
endcase
```

- **OFF（00）**：该区关闭，恒不命中。
- **TOR（01）**：Top Of Range，上界 = 本区 pmpaddr，下界 = 上一区 pmpaddr（见第 5 节）。
- **NA4（10）**：Naturally Aligned 4-byte，固定 4 字节区。**OpenC910 未实现**：

```verilog
//assign mmu_na4_addr_match = (mmu_pmp_pa_y[31:2] == pmpaddr_x_value[29:0]);  // 行 88 注释掉
assign mmu_na4_addr_match = 1'b0;                                            // 行 89 硬连 0
```

  NA4 被硬连为 `1'b0`，即配 NA4 模式的区永不命中。**为什么不实现 NA4？** 因为 C910 的
  PMP 最小粒度是 **4KB**（见第 7 节），4 字节粒度与 4KB 粒度冲突，实现 NA4 既无意义
  又会显著增大地址寄存器（要保存到 4B 级），故直接砍掉。
- **NAPOT（11）**：Naturally Aligned Power-Of-Two，覆盖一段 2 的幂大小、自然对齐的区
  （见第 6 节）。

---

## 5. TOR 模式：用上一区地址做下界

TOR 区命中条件：`pmpaddr_{i-1} <= addr < pmpaddr_i`。`ct_pmp_comp_hit` 行 74-81：

```verilog
//1. TOR mode : pmpaddr_x_value[i-1] <= addr < pmpaddr_x_value[i]
assign mmu_comp_adder[28:0] = {1'b0, mmu_pmp_pa_y[27:0]} - {1'b0, pmpaddr_x_value[28:1]};
assign mmu_addr_ls_top      = mmu_comp_adder[28];          // addr < 本区 pmpaddr（上界）
assign mmu_tor_addr_match   = mmu_addr_ge_bottom_x && mmu_addr_ls_top;
// for next entry
assign mmu_addr_ge_upaddr_x = !mmu_comp_adder[28];         // addr >= 本区 pmpaddr，喂下一区做下界
```

逻辑拆解：

- `mmu_comp_adder = {0,addr} - {0, pmpaddr[28:1]}`：用减法做无符号比较。借位（最高位 bit28）
  为 1 表示 `addr < pmpaddr`（不够减），即地址在本区**上界以下**——这就是 `mmu_addr_ls_top`。
- `mmu_addr_ge_bottom_x`：地址是否 ≥ 本区下界。**下界不是本区自己存的，而是上一区的
  pmpaddr**，所以这个信号由上一区算好传进来（即上一区的 `mmu_addr_ge_upaddr`）。
- 两者与起来 = TOR 命中。
- 同时本区算出 `mmu_addr_ge_upaddr_x = !borrow = (addr >= 本区pmpaddr)`，喂给下一区当下界。

注意比较用的是 `pmpaddr_x_value[28:1]`（取高 28 位对齐 28 位页帧号），最低位 [0] 不参与
TOR 比较（它只在 NAPOT 里有意义）。这条"下界链"在 `ct_pmp_acc` 里把 8 个区串起来
（见第 8 节）。

---

## 6. NAPOT 模式：末尾连续 1 编码基址+大小

### 6.1 核心技巧

NAPOT 要在一个地址寄存器里**同时编码"基址"和"区大小"**，用的技巧是：
**地址值低位末尾连续 1 的个数决定区大小，第一个 0 之上是基址**。

```
pmpaddr 低位形如:   ... b b b 0 1 1 1 1
                            ↑ ↑—————↑
                          基址  4 个连续 1 → 区大小 = 2^(4+1) × 最小粒度
```

- 末尾连续 `k` 个 1，则区大小 = `2^(k+3)` 字节（标准 NA4 起步；本实现起步 4KB）；
- 那串 1 的位置确定低位 mask，mask 之上的高位是基址。

### 6.2 RTL 生成地址 mask（行 96-129）

`ct_pmp_comp_hit` 用一个 `casez` 把"末尾连续 1 的模式"映射成"比较 mask"：

```verilog
casez(pmpaddr_x_value[28:0])
  29'b????_..._????_0 : addr_mask[27:0] = 28'hfffffff; // 末位 0 → 4KB，mask 全 1（整页帧都要比）
  29'b????_..._???0_1 : addr_mask[27:0] = 28'hffffffe; // 末尾 1 个 1 → 8KB，mask 末位放 0
  29'b????_..._??01_1 : addr_mask[27:0] = 28'hffffffc; // 末尾 2 个 1 → 16KB
  29'b????_..._?011_1 : addr_mask[27:0] = 28'hffffff8; // 32KB
  ...
  29'b0111_..._1111_1 : addr_mask[27:0] = 28'h0000000; // 末尾 28 个 1 → 1T，mask 全 0（不比）
  default             : addr_mask[27:0] = 28'b0;
endcase   // 行 98-129
```

规律一目了然：**pmpaddr 末尾的 1 越多，区越大，mask 里低位的 0 越多**（被掩掉、不参与比较
的低位越多）。从 4KB（行 99）一路到 1T（行 127），共 29 档，每档对应 2 的幂大小，正是
"自然对齐 2 的幂"区。

### 6.3 用 mask 做匹配（行 84）

```verilog
//2. NAPOT : addr & addr_mask == pmpaddr_x_value & addr_mask
assign mmu_napot_addr_match = (addr_mask[27:0] & mmu_pmp_pa_y[27:0])
                           == (addr_mask[27:0] & pmpaddr_x_value[28:1]);
```

把待查地址和基址都用 mask 掩掉低位（区内偏移位），比较剩下的高位是否相等——相等即落在
该 NAPOT 区内。**这就是 NAPOT 的精髓：一个寄存器、一次掩码比较，搞定"基址+任意 2 的幂
大小"的区匹配**，无需单独存大小字段，也无需上下界两个寄存器（对比 TOR 要借上一区地址）。

> 为什么用末尾连续 1 而不是单独存 log2(size)？因为 RISC-V 标准就这么定义（向后兼容
> NA4：末位是 0 即 NA4/最小粒度，全 1 即最大），且硬件实现就是一次优先级译码出 mask，
> 极其廉价。代价是 pmpaddr 不能表示任意基址——基址必须按区大小自然对齐，但这正是
> "Naturally Aligned"的要求，软件配置时本就该对齐。

---

## 7. 4KB 粒度

OpenC910 PMP 的最小粒度是 **4KB**，体现在两处：

1. 地址比较只到页帧级：`mmu_pmp_pa_y` 是 28 位 = PA[39:12]，低 12 位（页内偏移）根本不参与
   PMP 比较——意味着 PMP 永远以 4KB 对齐的页为单位授权。
2. NAPOT 最小档就是 4KB（行 99，末位 0 → mask 全 1），没有更小的 NA4（已砍，第 4 节）。

这与 `ct_pmp_regs` 中地址寄存器低 9 位读 0 的设计一致（见 `01_pmp_regs.md` 第 8 节）。
4KB 粒度的好处是：与 MMU 页大小对齐、地址寄存器更窄（28 位而非 PA 全宽）、比较逻辑更短。
代价是无法保护小于 4KB 的细粒度区域——对 PMP 的典型用途（保护整段固件/内存区）足够。

---

## 8. 8 个并行检查器与下界链

`ct_pmp_acc` 例化 8 个 `ct_pmp_comp_hit`（entry0~7，行 140-231），各区的 A 模式从
`pmpcfg0_value` 切片（行 129-136）：

```verilog
assign addr_match_mode0 = pmpcfg0_value[4:3];     // entry0 的 A
assign addr_match_mode1 = pmpcfg0_value[12:11];   // entry1
... 
assign addr_match_mode7 = pmpcfg0_value[60:59];   // entry7
```

8 个区的输入物理地址相同（都是 `mmu_pmp_pa_y`），地址寄存器各取自己的。命中向量
汇聚成 `pmp_hit[7:0]`（行 123-126），高 8 位恒 0（行 251，因 entry8~15 不存在）。

### TOR 下界链（行 113-120）

```verilog
assign {mmu_addr_ge_bottom7, ..., mmu_addr_ge_bottom1, mmu_addr_ge_bottom0} =
       {mmu_addr_ge_upaddr6, ..., mmu_addr_ge_upaddr0,  1'b1};
```

精妙之处：

- entry_i 的"下界比较结果" `mmu_addr_ge_bottom_i` = entry_{i-1} 算出的
  `mmu_addr_ge_upaddr_{i-1}`（即"地址 ≥ 上一区 pmpaddr"）——因为 TOR 区 i 的下界正是
  pmpaddr_{i-1}。
- entry0 没有"上一区"，其下界固定为 0，所以 `mmu_addr_ge_bottom0 = 1'b1`（任何地址都 ≥ 0）。

这把 8 个区的下界用一条移位链连起来，每个区只需算一次减法（在 comp_hit 内），
下界免费来自邻居。**这是 TOR "用上一区地址做下界"在硬件上的优雅落地**。

---

## 9. 优先级编码：低编号区优先

多个区可能同时命中同一地址，RISC-V 规定**最低编号的命中区生效**。`ct_pmp_acc` 用一个
`casez` 优先级编码实现（行 280-299）：

```verilog
casez(pmp_hit[15:0])
  16'b???????????????1 : pmp_mmu_flg_y = {pmpcfg0_value[07], pmpcfg0_value[2:0]};   // entry0 命中(最高优先)
  16'b??????????????10 : pmp_mmu_flg_y = {pmpcfg0_value[15], pmpcfg0_value[10:8]};  // entry1
  16'b?????????????100 : pmp_mmu_flg_y = {pmpcfg0_value[23], pmpcfg0_value[18:16]}; // entry2
  16'b????????????1000 : pmp_mmu_flg_y = {pmpcfg0_value[31], pmpcfg0_value[26:24]}; // entry3
  ...
  16'b????????10000000 : pmp_mmu_flg_y = {pmpcfg0_value[63], pmpcfg0_value[58:56]}; // entry7
  16'b???????100000000 : pmp_mmu_flg_y = {pmpcfg2_value[07], pmpcfg2_value[2:0]};   // entry8 (恒不命中)
  ...
  16'b0000000000000000 : pmp_mmu_flg_y = pmp_default_flg[3:0];                       // 无命中 → 默认
  default              : pmp_mmu_flg_y = {4{1'bx}};
endcase
```

- `casez` 的 `?` 通配 + 从上到下匹配，自然实现"最低 1 位优先"——即低编号区优先。
- 命中区的结果取 `{L, X, W, R}`：例如 entry0 取 `{cfg[7]=L, cfg[2:0]=X/W/R}`。返回的 4 位
  正是 `pmp_mmu_flg_y[3:0] = {L, X, W, R}`，回送 MMU。MMU 据此判断该访问类型（读/写/取指）
  是否被允许，不允许则产生 access fault。
- entry8~15 的分支虽然写了，但 `pmp_hit[15:8]` 恒 0（行 251），永远走不到。

---

## 10. M 态默认全通与锁定规则约束

### 10.1 默认权限（行 256）

```verilog
assign pmp_default_flg[3:0] = cp0_mach_mode ? 4'b0111 : 4'b0;
```

无任何区命中时：

- **M 态**：`4'b0111` = {L=0, X=1, W=1, R=1}，默认 RWX 全通；
- **U/S 态**：`4'b0`，默认全拒（访问即 fault）。

这正是 RISC-V "M 态对未匹配地址默认全权、低特权级默认无权"的规定。

### 10.2 锁定规则约束 M 态

注意优先级编码里：**只要某区命中，就直接用该区的 R/W/X，不再看是不是 M 态**
（行 281-296 各分支都无条件取 cfg 的权限位）。这意味着：

- M 态访问**未命中**区 → 走默认 `4'b0111` 全通；
- M 态访问**命中**区 → 用该区 R/W/X 受限。

结合 `ct_pmp_regs` 的 L 锁位：一个 L=1 的区，配置不可改、且其 R/W/X 对 M 态强制生效，
于是 M 态固件能把自己的代码段锁成"只读不可写不可改配置"，实现固件自保护。

> 严格按 RISC-V 规范，未锁定（L=0）的区对 M 态其实是"不强制"（M 态总有权）的——
> 但本 RTL 简化为"命中即用该区权限"，配置软件应保证只在需要约束 M 态时才让 M 态相关
> 区命中（典型做法是给 M 态要保护的区配 L=1）。L=0 的区在实际使用中主要针对 U/S 态。

`pmp_default_flg` 的 L 位恒 0（默认非锁定），符合"默认情况不锁"。

---

## 11. 有效特权模式与 MPRV

判权用的不是当前模式，而是"有效特权模式"（行 107-109）：

```verilog
assign cp0_priv_mode[1:0] = pmp_mprv_status_y ? cp0_pmp_mpp[1:0]   // MPRV 生效：用 MPP
                                              : cur_priv_mode[1:0]; // 否则用当前模式
assign cp0_mach_mode      = cp0_priv_mode[1:0] == 2'b11;           // 是否 M 态
```

`pmp_mprv_status_y` 由顶层逐通道算好（见 `00_pmp_overview.md` 第 10 节）：MPRV 置 1 且本次
是访存（非取指）时为 1，此时 PMP 按 `mstatus.MPP` 指定的特权级判权——让 M 态固件能"以
U/S 身份"访问内存（例如代表用户态做数据搬运并接受 PMP 约束）。取指通道强制 `pmp_mprv_status=0`，
保证取指永远按真实当前模式判权，符合规范。

`cp0_mach_mode` 进而决定无命中时走 `4'b0111`（M）还是 `4'b0`（非 M），把 MPRV 的影响
一路传到默认权限。

---

## 设计取舍小结

| 决策 | 取舍 | 原因 |
|------|------|------|
| NA4 硬连 0（不实现） | 功能 vs 成本 | 与 4KB 粒度冲突，实现 NA4 需保存 4B 级地址，得不偿失 |
| NAPOT 用末尾连续 1 编码 | 面积 vs 灵活 | 一个寄存器编码基址+大小，一次掩码比较即匹配，极廉价；代价是基址需自然对齐 |
| TOR 下界用上一区地址（移位链） | 面积 | 免去每区单独存下界，8 区串成一条链，每区只算一次减法 |
| 8 区全并行匹配 + 优先级编码 | 时序 vs 面积 | 检查必须当拍出结果，不能逐区串行；casez 天然实现低编号优先 |
| M 态默认 4'b0111、非 M 默认 0 | 符合规范 | RISC-V 规定 M 态对未匹配区全权、低特权无权 |
| 命中即用该区权限（不区分 M 态） | 简化 | 配合 L 锁位实现固件自保护；软件需正确配置 L |
| 有效特权模式按 MPRV 选 MPP/当前 | 符合规范 | 支持 M 态以低特权身份访存，取指通道强制关 MPRV |
| 全组合逻辑、无流水 | 时序 | PMP 检查在访问关键路径上，加流水会延迟所有访存 |

*文档覆盖 ct_pmp_comp_hit.v 全部 136 行与 ct_pmp_acc.v 全部 306 行逻辑。*
