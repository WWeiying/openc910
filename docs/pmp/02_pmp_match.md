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
10. [无命中默认值与 M 模式 L 位旁路](#10-无命中默认值与-m-模式-l-位旁路)
11. [有效特权模式与 MPRV](#11-有效特权模式与-mprv)
12. [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 职责

这两个模块共同完成“给一个物理页号，匹配哪个 PMP entry，并返回该 entry 的属性”的组合
计算。它们不是完整的访问异常判定器：

- **`ct_pmp_comp_hit`**：对**单个 PMP 区**做地址匹配——给定区的 `pmpaddr` 和匹配模式 A，
  判断输入物理地址 `mmu_pmp_pa_y` 是否落在该区范围内，输出 1 位 `pmp_mmu_hit_x`。
- **`ct_pmp_acc`**：一条访问检查通道。内部例化 **8 个 `ct_pmp_comp_hit`**（entry0~7），
  收集 8 位命中向量，做**优先级编码**选出最低编号的命中区，取其 R/W/X/L 作为权限结果
  `pmp_mmu_flg_y[3:0]`；若无区命中，用有效特权模式相关的默认值。MMU 消费端随后根据
  本次是读、写还是执行，并结合结果有效时刻和 M 模式 `L=0` 旁路，形成最终 deny/fault。

`ct_pmp_top` 例化 5 个 `ct_pmp_acc`（对应 5 个并发物理地址），故全 PMP 内部共
8×5 = 40 个 `ct_pmp_comp_hit` 源码实例。**这两个模块全是组合逻辑**：输入变化后，输出
经过组合延迟变化。模块没有时钟、valid 或握手，因此“当拍出结果”只能理解为“不在 PMP
内部新增寄存级”，不能理解为 PMP 自己确认了一次事务完成。

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
| `pmp_mmu_flg_y` | out | 4 | 48 | 选中项/默认项的属性 `{L,X,W,R}`；不携带有效位 |

---

## 3. 参数与关键信号

`ct_pmp_comp_hit` 参数（行 49）：

```verilog
parameter ADDR_WIDTH = `PA_WIDTH-12;   // = 40-12 = 28
```

`ADDR_WIDTH=28`，即 `PA[39:12]` 的页帧号位数。`pmpaddr_x_value[28:0]` 对应软件可见
CSR `[37:9]`，不是完整物理地址：

- 比较器中的 `[28:1]` 对应 CSR `[37:10]`，与 `PA[39:12]` 对齐；
- `[0]` 对应 CSR `[9]`，参与 NAPOT 大小译码；
- CSR `[8:0]` 已在寄存器堆中被丢弃并读回 0。

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

  NA4 被硬连为 `1'b0`，即配成 NA4 的 entry 在本实现中永不命中。RTL 能证明“没有
  NA4 功能”，但没有写明删去 NA4 的设计动机。它与整条通路只传 `PA[39:12]`、地址寄存器
  不保存 CSR `[8:0]` 的 4KB 粒度选择一致；成本或产品需求方面的原因只能作为推测。
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

### 6.1 先区分标准 CSR 编码和内部 29 位编码

NAPOT 在一个地址寄存器中同时编码基址和范围大小。标准软件视角下，`pmpaddr` 低位连续
1 的数量决定范围大小；但当前 RTL 丢弃 CSR `[8:0]`，所以观察内部
`pmpaddr_x_value[28:0] = CSR[37:9]` 时，编码已经平移了 9 位。

```
内部值低位形如:   ... b b b 0 1 1 1 1
                          ↑  └── k 个连续 1
                          第一个参与基址比较的低位
```

- 内部最低位为 0 时，`k=0`，RTL 选择 4KB；
- 内部有 `k` 个末尾连续 1 时，范围大小为 `4KB × 2^k`；
- mask 将这 `k` 个页号低位清零，只比较范围之外的高位；
- 例如内部尾部 `...01` 表示 8KB，`...011` 表示 16KB。

这与标准 CSR 表述并不矛盾：4KB NAPOT 在完整 `pmpaddr` 中需要的低位编码落在被实现省略的
CSR `[8:0]`；从内部保存的 bit9 开始，只需继续表示 8KB 及以上的扩展倍数。

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

> 这里的“内部末位 0 表示 4KB”不要误读为标准 `pmpaddr` 的最低位为 0。它特指
> `pmpaddr_x_value[0] = CSR[9]`；标准 CSR `[8:0]` 已不在该内部值中。基址仍必须按范围大小
> 自然对齐。

---

## 7. 4KB 粒度

OpenC910 PMP 的最小粒度是 **4KB**，体现在两处：

1. 地址比较只到页帧级：`mmu_pmp_pa_y` 是 28 位 = PA[39:12]，低 12 位（页内偏移）根本不参与
   PMP 比较——意味着 PMP 永远以 4KB 对齐的页为单位授权。
2. NAPOT 最小档就是 4KB（行 99，末位 0 → mask 全 1），没有更小的 NA4（已砍，第 4 节）。

这与 `ct_pmp_regs` 将 CSR `[8:0]` 读回 0 的行为一致。代价是无法表达或检查页内的小范围，
也无法从该 PMP 接口判断一次多字节访问是否在页内跨越更细的保护边界，因为输入既没有
`PA[11:0]` 也没有访问 size。范围若跨 4KB 边界，访问通路如何拆分和分别检查还取决于
LSU/IFU 上游行为，不能由 `ct_pmp_comp_hit` 单独回答。

与 MMU 的 4KB 基本页对齐、减少地址比较位数，都是该结构可能带来的工程收益；是否“足够”
以及时序/面积改善多少属于平台需求和综合结果，不是 RTL 逻辑本身能够证明的结论。

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

这把 8 个区的下界比较结果串接起来。每个 entry 都独立计算“地址是否不低于自己的
`pmpaddr`”，该结果同时可作为下一个 TOR entry 的下界条件。它避免为同一个边界重复做
比较，但 8 个 entry 的减法器仍然并行存在，“复用比较结果”不等于“没有组合成本”。

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
- 命中区的结果取 `{L,X,W,R}`：例如 entry0 取 `{cfg[7],cfg[2:0]}`。这一步只选属性；
  MMU 还要等对应通路的结果有效，并结合访问类型和 M 模式旁路才能形成 access fault。
- entry8~15 的分支虽然写了，但 `pmp_hit[15:8]` 恒 0（行 251），永远走不到。

---

## 10. 无命中默认值与 M 模式 L 位旁路

### 10.1 默认权限（行 256）

```verilog
assign pmp_default_flg[3:0] = cp0_mach_mode ? 4'b0111 : 4'b0;
```

无任何区命中时：

- **M 态**：`4'b0111` = {L=0, X=1, W=1, R=1}，默认 RWX 全通；
- **U/S 态**：`4'b0`，默认全拒（访问即 fault）。

这正是 RISC-V "M 态对未匹配地址默认全权、低特权级默认无权"的规定。

### 10.2 匹配器返回 L，MMU 消费端实施 M 模式旁路

优先编码本身确实不按特权模式改写命中项：只要 entry 命中，就返回该项原始
`{L,X,W,R}`。但这**不表示 M 模式立即受 R/W/X 限制**。I-uTLB、D-uTLB、PTW 和 PFU
消费端都有同类条件：

```text
requested_permission == 0
&& result_valid
&& !(effective_machine_mode && L == 0)
```

以 I-uTLB 为例，它检查 X 位 `pmp_mmu_flg2[2]`；D-uTLB 对 load/store 分别检查 R/W；
PTW 根据引发遍历的原始访问类型检查 X/R/W；PFU 检查 R。于是完整语义是：

| 情形 | `ct_pmp_acc` 输出 | MMU 最终处理 |
|------|-------------------|--------------|
| M 模式、无 entry 命中 | 默认 `{0,1,1,1}` | RWX 允许 |
| M 模式、命中 `L=0` | 返回该项原始 R/W/X | 消费端旁路权限限制 |
| M 模式、命中 `L=1` | 返回该项原始 R/W/X | 不旁路，按相应权限位判断 |
| S/U 模式、无命中 | 默认全 0 | 对应访问被拒绝 |
| S/U 模式、命中 | 返回该项原始 R/W/X | 按相应权限位判断 |

因此当前 RTL 没有“命中即无条件限制 M 模式”的简化；正确结论必须跨
`ct_pmp_acc` 和 MMU 消费端共同得出。`pmp_default_flg` 的 L 位为 0，只表示无命中默认项
携带的 L 属性，不是一个可写锁状态。

---

## 11. 有效特权模式与 MPRV

判权用的不是当前模式，而是"有效特权模式"（行 107-109）：

```verilog
assign cp0_priv_mode[1:0] = pmp_mprv_status_y ? cp0_pmp_mpp[1:0]   // MPRV 生效：用 MPP
                                              : cur_priv_mode[1:0]; // 否则用当前模式
assign cp0_mach_mode      = cp0_priv_mode[1:0] == 2'b11;           // 是否 M 态
```

`pmp_mprv_status_y` 由顶层逐通道算好。通道 0/1/4直接采用 CP0 的 MPRV 状态，取指通道 2
固定为 0；PTW 通道 3 在原始 miss 为 fetch 时关闭 MPRV，在数据访问或预取 miss 时保留它。
当选择信号为 1 时，`ct_pmp_acc` 用 MPP 替代当前模式来生成**无命中默认项**；命中项仍
原样返回 L/R/W/X，最终 M 模式旁路也由各 MMU 消费端使用对应的有效模式判断。

`cp0_mach_mode` 进而决定无命中时走 `4'b0111`（M）还是 `4'b0`（非 M），把 MPRV 的影响
一路传到默认权限。

---

## 本章小结

PMP 匹配器对八个有效 entry 全并行计算 OFF、TOR 和 NAPOT 条件，再由 `casez` 选择最低编号命中项。NA4 路径在当前实现中硬连为不命中，这与只保存高地址字段的页号级接口一致。NAPOT 用地址末尾连续 1 同时编码自然对齐基址和 2 的幂范围；TOR 的上界来自本项地址，下界来自前一项地址，前一比较结果可向后一项传递，但每项仍执行自己的边界判断。最低编号优先是重叠区域的确定语义，不能把所有 hit 位简单 OR 后忽略 entry 顺序。

命中时，模块原样输出该 entry 的 `{L,X,W,R}`；无命中时，M 态默认返回 `4'b0111`，非 M 态默认返回 0。匹配器本身不根据当前访问是 fetch、load 还是 store 选择 X/R/W，也不在 M 态直接完成所有旁路判断，这些工作由 MMU 消费端结合访问类型和 L 位完成。有效特权可在符合条件的数据通道上由 MPRV 选择 MPP，取指通道强制关闭该替换。整条路径是组合逻辑，没有 PMP 内部 valid 或流水级；若后续修改边界，必须同步调整 MMU 的有效信号与异常时序。验证时应把地址模式、重叠优先级、有效特权、访问类型和最终拒绝条件作为一条链检查。
