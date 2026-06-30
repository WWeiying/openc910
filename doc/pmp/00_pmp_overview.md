# C910 PMP 顶层（ct_pmp_top）模块详细教学文档

> RTL 文件：`C910_RTL_FACTORY/gen_rtl/pmp/rtl/ct_pmp_top.v`（约 344 行）
>
> 相关文件：`ct_pmp_regs.v`、`ct_pmp_acc.v`、`ct_pmp_comp_hit.v`；配置宏 `cpu/rtl/cpu_cfig.h`（`PA_WIDTH 40`，第 461 行）

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键寄存器](#3-参数与关键寄存器)
4. [PMP 解决什么问题：MMU 管不到的物理层隔离](#4-pmp-解决什么问题mmu-管不到的物理层隔离)
5. [与 MMU 的先后关系：翻译后查物理地址](#5-与-mmu-的先后关系翻译后查物理地址)
6. [8 区结构与 5 条并行通道](#6-8-区结构与-5-条并行通道)
7. [M 态语义与特权模式](#7-m-态语义与特权模式)
8. [CSR 译码与写使能](#8-csr-译码与写使能)
9. [时钟门控](#9-时钟门控)
10. [MPRV 旁路：每通道独立处理](#10-mprv-旁路每通道独立处理)
11. [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

### 1.1 职责

`ct_pmp_top` 是 OpenC910 物理内存保护单元的顶层。它把三件事拼在一起：

1. **CSR 接口**：接收 CP0（C910 中承载所有 CSR 的单元）发来的 PMP 寄存器读写请求，
   译码出要访问哪一个 PMP CSR（pmpcfg0/pmpcfg2 或 pmpaddr0~15），驱动写使能，
   并把读结果 `pmp_cp0_data` 返回。
2. **寄存器堆**：例化唯一一份 `ct_pmp_regs`，存放 8 组配置/地址寄存器。
3. **访问检查**：例化 **5 个** `ct_pmp_acc` 实例，分别检查 MMU 在同一拍内送来的
   最多 5 个物理地址（`mmu_pmp_pa0`~`mmu_pmp_pa4`）的访问权限，输出 5 组 4 位标志
   `pmp_mmu_flg0`~`pmp_mmu_flg4`（R/W/X + L）给 MMU。

一句话：**寄存器堆只有一份，检查器有五套**，因为读寄存器是慢通路（写 CSR），
而权限检查是每拍都要做的快通路（多个访存口并发）。

### 1.2 位置

```
CP0 (CSR 读写) ─────────────► ct_pmp_top ─────► pmp_cp0_data  (读 PMP CSR 回值)
                                  │
MMU (翻译后的物理地址 ×5) ──────►  │  ──────────► pmp_mmu_flg0~4 (各地址的 R/W/X/L 权限)
                                  │
                              ┌───┴────────────────────────┐
                              │ ct_pmp_regs (8×cfg+8×addr)  │
                              └───┬────────────────────────┘
                                  │ 广播 cfg/addr 给 5 个检查器
                  ┌───────┬───────┼───────┬───────┐
              acc0    acc1    acc2    acc3    acc4   (每个内含 8 个 comp_hit)
```

PMP 在 C910 流水线中**位于 MMU 之后、访问真正发往总线/Cache 之前**：MMU 先把虚拟
地址翻译成物理地址（或在 Bare 模式下直接透传物理地址），翻译结果送进 PMP 做权限校验，
PMP 返回的标志位决定该访问是否触发 access fault。详见第 5 节。

---

## 2. 端口说明

### 2.1 CP0 / CSR 接口（寄存器读写通路）

| 端口 | 方向 | 位宽 | 行号 | 含义 |
|------|------|------|------|------|
| `cp0_pmp_reg_num` | in | 5 | 44 | CSR 编号低 5 位，用于定位 pmpaddr0~15 / pmpcfg |
| `cp0_pmp_wdata` | in | 64 | 45 | 写入 PMP CSR 的数据 |
| `cp0_pmp_wreg` | in | 1 | 46 | CSR 写请求有效 |
| `pmp_cp0_data` | out | 64 | 57 | 读出的 PMP CSR 值，回给 CP0 |

### 2.2 特权/状态输入

| 端口 | 方向 | 位宽 | 行号 | 含义 |
|------|------|------|------|------|
| `cp0_yy_priv_mode` | in | 2 | 47 | 当前特权模式（11=M, 01=S, 00=U） |
| `cp0_pmp_mpp` | in | 2 | 42 | `mstatus.MPP`，MPRV 生效时用作"有效特权模式" |
| `cp0_pmp_mprv` | in | 1 | 43 | `mstatus.MPRV`，访存按 MPP 而非当前模式判权 |

### 2.3 MMU 访问检查接口（5 条并行通道）

| 端口 | 方向 | 位宽 | 行号 | 含义 |
|------|------|------|------|------|
| `mmu_pmp_pa0`~`pa4` | in | 28 each | 51-55 | 5 个待检查物理地址，每个是 PA[39:12]（4KB 页帧号） |
| `mmu_pmp_fetch3` | in | 1 | 50 | 通道 3 是否为取指访问（影响该通道 MPRV，见第 10 节） |
| `pmp_mmu_flg0`~`flg4` | out | 4 each | 58-62 | 5 组权限标志，位序 {L, X, W, R}（见 `ct_pmp_acc`） |

### 2.4 时钟与复位

| 端口 | 方向 | 位宽 | 行号 | 含义 |
|------|------|------|------|------|
| `forever_cpuclk` | in | 1 | 49 | 自由运行时钟（送入门控单元） |
| `cpurst_b` | in | 1 | 48 | 低有效复位 |
| `cp0_pmp_icg_en` | in | 1 | 41 | 时钟门控模块级使能 |
| `pad_yy_icg_scan_en` | in | 1 | 56 | DFT 扫描使能（门控旁路） |

---

## 3. 参数与关键寄存器

### 3.1 CSR 地址参数（行 145-162）

顶层把 16 个 pmpaddr 与 2 个 pmpcfg 的 12 位 CSR 地址写成参数：

```verilog
parameter PMPCFG0   = 12'h3A0;   // 行 145
parameter PMPCFG2   = 12'h3A2;   // 行 146（RV64 中奇数号 pmpcfg 不存在，故只有 0 和 2）
parameter PMPADDR0  = 12'h3B0;   // 行 147
...
parameter PMPADDR15 = 12'h3BF;   // 行 162
```

注意：RV64 下每个 pmpcfg CSR 是 64 位、打包 8 个 entry 的配置字节，所以
**只用 pmpcfg0（entry0~7）和 pmpcfg2（entry8~15）两个 CSR**，pmpcfg1/3 在 RV64 不存在。
本实现 entry8~15 全部硬连为 0（见 `01_pmp_regs.md`），所以 pmpcfg2 恒为 0。

### 3.2 拼出完整 CSR 地址（行 164）

```verilog
assign cp0_pmp_addr[11:0] = {7'b0011101, cp0_pmp_reg_num[4:0]};
```

CP0 只送来低 5 位编号 `cp0_pmp_reg_num`，顶层把高 7 位固定补成 `0011101`，
拼出完整 12 位地址（`0x3A0`~`0x3BF` 段）。这是因为所有 PMP CSR 都落在
`0x3A0`~`0x3BF` 这 32 个地址内，高 7 位完全相同。

### 3.3 内部关键 wire

| 信号 | 位宽 | 行号 | 含义 |
|------|------|------|------|
| `pmp_csr_sel` | 18 | 87 | one-hot 选中向量（2 个 cfg + 16 个 addr） |
| `pmp_csr_wen` | 18 | 88 | 写使能（sel & wreg） |
| `wr_pmp_regs` | 1 | 109 | 任一 PMP CSR 被写（门控 local_en） |
| `pmpcfg0_value`/`pmpcfg2_value` | 64 | 107-108 | 寄存器堆输出的两份配置字 |
| `pmpaddr0_value`~`7_value` | 29 each | 99-106 | 8 个地址寄存器值（[28:0]） |
| `cur_priv_mode` | 2 | 77 | 当前特权模式（= `cp0_yy_priv_mode`） |
| `pmp_mprv_status0`~`4` | 1 each | 94-98 | 各通道独立的 MPRV 生效标志（见第 10 节） |

---

## 4. PMP 解决什么问题：MMU 管不到的物理层隔离

### 4.1 MMU 的盲区

MMU（内存管理单元）通过页表把虚拟地址翻译成物理地址，并在页表项里带 R/W/X/U
权限位——但这套机制有两个根本盲区：

1. **页表本身由谁保护？** 页表在内存里，谁能改页表，谁就能给自己授予任意权限。
   M 态固件、安全监控程序必须保证一段物理内存（存放安全代码、页表根、
   secure boot 镜像）**任何更低特权级都碰不到**，而这不能依赖页表本身。
2. **Bare（无翻译）访问**：M 态运行时通常关闭翻译（`satp=Bare`），此时虚拟地址即物理
   地址，MMU 的页表权限完全不起作用。但 M 态固件仍希望对自己的某些区域做只读保护
   （防止固件 bug 改坏自己），或把一段地址标记为不可执行。

PMP 正是为这两个场景而生：它**直接作用在物理地址上**，不依赖页表、不依赖翻译是否开启。

### 4.2 典型用途：TEE / 安全隔离

- **TEE / 可信执行环境**：把安全世界的代码与数据放在某段物理内存，用一个 PMP 区
  标记为"仅 M 态可访问、且 Lock 锁死"，则即使 OS（S 态）被攻破也读不到、改不到这段内存。
- **外设隔离**：把某个外设 MMIO 区域限定只有特定特权级能访问。
- **固件自保护**：M 态把自己的代码段标记为只读不可写（`R=1,W=0,X=1,L=1`），
  即使固件自身有 bug 也无法改写自己的指令。
- **DMA/从设备保护**：C910 还有独立的 L2 PMP（顶层注释 122-138 行残留的 `ct_l2pmp_*`
  例化痕迹，本实现已不在此文件中），用于保护非 CPU 主设备的访问。

---

## 5. 与 MMU 的先后关系：翻译后查物理地址

RISC-V 规范明确：**PMP 检查发生在地址翻译之后**。流程是：

```
虚拟地址 ──[MMU 翻译/或 Bare 透传]──► 物理地址 ──[PMP 权限检查]──► 实际访问
                                            │
                                  匹配命中的 PMP 区给出 R/W/X
                                  不满足则 access fault
```

这就是为什么 `ct_pmp_top` 的输入是 `mmu_pmp_pa0`~`pa4`（已是物理地址，宽度 28 位 =
PA[39:12]），而不是虚拟地址——PMP 只看物理地址。MMU 完成翻译后，把物理页帧号送进
PMP，PMP 在**同一时序窗口内组合逻辑判出**该地址在当前特权级下能不能读/写/执行，
结果 `pmp_mmu_flg` 当拍回给 MMU，由 MMU 决定是否产生 access fault 异常。

**为什么是 MMU 来送地址而不是 LSU/IFU 直接送？** 因为无论翻译开/关，物理地址都从
MMU 这一点流出（Bare 模式 MMU 做透传），由 MMU 统一汇聚成 5 个并发地址送 PMP，
避免在每个访存源各放一份 PMP，节省面积。

---

## 6. 8 区结构与 5 条并行通道

### 6.1 8 个 PMP 区（entry）

RISC-V 允许实现 0/16/64 个 PMP 区。OpenC910 实现 **8 个**（entry 0~7）。
每个区由一对寄存器描述：

- `pmpcfgN`：8 位配置字节，含 R/W/X 权限、A 匹配模式（OFF/TOR/NA4/NAPOT）、L 锁位；
- `pmpaddrN`：编码该区覆盖的物理地址范围（基址或上界，编码方式取决于 A）。

CSR 接口上预留了 entry8~15 的地址（`pmp_csr_sel` 共 18 位），但 entry8~15 的地址值与
配置在 `ct_pmp_regs` 中全部硬连为 0，等于"存在但永不命中"，所以**有效区只有 8 个**。

### 6.2 5 条并行检查通道

`ct_pmp_top` 例化 5 个 `ct_pmp_acc`（行 237、258、279、300、321），每个吃一个物理地址。
为什么是 5 个？因为 C910 一拍内可能同时产生多达 5 个需要做 PMP 检查的物理地址（取指口
+ 多个访存口，由 MMU 汇聚）。**每个通道都要独立、并行地对全部 8 个区做匹配**，所以
8 区 × 5 通道 = 内部共 40 个 `ct_pmp_comp_hit` 实例。寄存器堆只有一份，其 cfg/addr
输出被广播到 5 个 acc（行 243-252 等可见每个 acc 都收到同样的 `pmpaddr*_value`/`pmpcfg*_value`）。

> 设计取舍：寄存器是写少读多，且 5 个通道读的是同一份配置，所以"一份存储 + 多份组合
> 逻辑读端口"是面积/时序最优解——避免把寄存器复制 5 份。

---

## 7. M 态语义与特权模式

### 7.1 M 态默认全通

RISC-V 规定：**M 态（machine mode）对未被任何区匹配的地址默认拥有全部权限**；而
U/S 态对未匹配地址默认**无任何权限**（访问即 fault）。这一默认值在 `ct_pmp_acc` 中实现：

```verilog
assign pmp_default_flg[3:0] = cp0_mach_mode ? 4'b0111 : 4'b0;   // ct_pmp_acc.v 行 256
```

`4'b0111` = {L=0, X=1, W=1, R=1}，即 M 态默认 RWX 全开；非 M 态默认全 0（全拒）。

### 7.2 锁定区对 M 态也生效

但有一个例外：**带 Lock（L=1）的区，其权限对 M 态同样强制执行**。也就是说 M 态固件
可以用 L=1 把某段内存对自己也设为只读/不可执行，从而实现"固件自保护"。这一点由
匹配命中时直接采用该区的 R/W/X（而不是默认全通）保证——只要某区命中，无论是不是 M 态，
都用该区配置（详见 `02_pmp_match.md` 优先级编码）。

### 7.3 有效特权模式

判权用的"有效特权模式"不一定是当前模式。`ct_pmp_acc` 行 107-109：

```verilog
assign cp0_priv_mode = pmp_mprv_status_y ? cp0_pmp_mpp : cur_priv_mode;
assign cp0_mach_mode = (cp0_priv_mode == 2'b11);
```

当 MPRV 生效时，用 `mstatus.MPP` 作为有效特权模式（见第 10 节）；否则用当前模式。

---

## 8. CSR 译码与写使能

### 8.1 one-hot 选择（行 165-182）

```verilog
assign pmp_csr_sel[0]  = cp0_pmp_addr[11:0] == PMPCFG0;   // pmpcfg0
assign pmp_csr_sel[1]  = cp0_pmp_addr[11:0] == PMPCFG2;   // pmpcfg2
assign pmp_csr_sel[2]  = cp0_pmp_addr[11:0] == PMPADDR0;  // pmpaddr0
...
assign pmp_csr_sel[17] = cp0_pmp_addr[11:0] == PMPADDR15; // pmpaddr15
```

18 位 one-hot：bit0=pmpcfg0，bit1=pmpcfg2，bit2~17=pmpaddr0~15。

### 8.2 写使能与"是否写 PMP"（行 184-186）

```verilog
assign pmp_csr_wen[17:0] = pmp_csr_sel[17:0] & {18{cp0_pmp_wreg}};  // 选中且写请求
assign wr_pmp_regs       = |pmp_csr_wen[17:0];                       // 任一被写
```

`wr_pmp_regs` 既驱动寄存器写，也作为时钟门控的"本地使能"——只有真正写 PMP 时才打开时钟。

---

## 9. 时钟门控

行 189-197 例化标准门控单元 `gated_clk_cell`：

```verilog
gated_clk_cell x_pmp_gated_clk (
  .clk_in (forever_cpuclk), .clk_out (cpuclk),
  .external_en(1'b0), .global_en(1'b1),
  .local_en (wr_pmp_regs),        // 仅写 PMP CSR 时打开
  .module_en(cp0_pmp_icg_en),     // 模块级使能
  .pad_yy_icg_scan_en(pad_yy_icg_scan_en)
);
```

只有 `wr_pmp_regs`（有 PMP CSR 写）时才放行时钟。**PMP 寄存器极少改写**（通常只在
boot 阶段配置一次），所以门控收益很大——绝大多数时间 `cpuclk` 关停，寄存器堆不翻转。
注意：**权限检查通路是纯组合逻辑**（见 `ct_pmp_acc`/`ct_pmp_comp_hit` 全是 assign 与
组合 always），不吃这个门控时钟，所以门控关停不影响每拍的权限判定。

---

## 10. MPRV 旁路：每通道独立处理

`mstatus.MPRV`（Modify PRiVilege）置 1 时，M 态发起的 **load/store** 要按 `MPP` 的特权级
判权（让 M 态固件能"以 U 态身份"访问内存），但**取指不受 MPRV 影响**。顶层为 5 个通道
分别算出各自的 MPRV 生效标志（行 229-233）：

```verilog
assign pmp_mprv_status0 = cp0_pmp_mprv;                       // 访存通道
assign pmp_mprv_status1 = cp0_pmp_mprv;                       // 访存通道
assign pmp_mprv_status2 = 1'b0;                               // 该通道恒不受 MPRV（如取指）
assign pmp_mprv_status3 = cp0_pmp_mprv && !mmu_pmp_fetch3;    // 取指时强制关 MPRV
assign pmp_mprv_status4 = cp0_pmp_mprv;                       // 访存通道
```

- 通道 2 直接钉死 `1'b0`：该通道服务的访问类型（取指）本就不应用 MPRV；
- 通道 3 用 `!mmu_pmp_fetch3` 动态判断：同一通道有时取指有时访存，**取指时关 MPRV**，
  符合规范"MPRV 只作用于显式访存，不作用于取指"。

这是 PMP 顶层为数不多的"每通道差异化"逻辑，体现了取指与访存在 MPRV 语义上的根本区别。

---

## 设计取舍小结

| 决策 | 取舍 | 原因 |
|------|------|------|
| 8 个有效区（CSR 接口预留 16） | 面积 vs 灵活度 | 8 区足够覆盖典型 TEE/固件保护场景；预留 16 的 CSR 译码便于将来扩展 |
| 1 份寄存器堆 + 5 套组合检查器 | 面积 vs 并发 | 写少读多，5 通道读同一份配置，复制寄存器不划算，复制组合逻辑便宜 |
| 权限检查纯组合、寄存器走门控时钟 | 时序 vs 功耗 | 检查必须当拍出结果（不能加流水延迟访问），寄存器极少改可深度门控 |
| MPRV 每通道独立计算 | 复杂度 vs 正确性 | 取指/访存对 MPRV 语义不同，必须区分，通道 3 还需动态判 fetch |
| 高 7 位 CSR 地址硬拼 | 面积 | 所有 PMP CSR 高位相同，无需 CP0 传完整地址 |
| pmpcfg 仅 0/2 两个 CSR | 符合 RV64 | RV64 一个 pmpcfg 打包 8 个 entry，奇数号不存在 |

*文档覆盖 ct_pmp_top.v 全部 344 行逻辑。*
