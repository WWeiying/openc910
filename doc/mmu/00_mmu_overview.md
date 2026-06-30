# C910 MMU 总览 模块详细教学文档

> RTL 文件：`C910_RTL_FACTORY/gen_rtl/mmu/rtl/` 目录下全部 21 个文件（顶层 `ct_mmu_top.v` 约 1134 行，整套 MMU 约 14000 行）
>
> 本篇是 MMU 学习的总入口，建立"翻译的存储层次"全局观；各子模块细节见 01~06 分篇。

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键寄存器](#3-参数与关键寄存器)
4. [Sv39 单阶段翻译：地址格式与页表](#4-sv39-单阶段翻译地址格式与页表)
5. [三级 TLB 是"翻译的存储层次"](#5-三级-tlb-是翻译的存储层次)
6. [完整翻译数据流](#6-完整翻译数据流)
7. [关键设计决策汇总](#7-关键设计决策汇总)
8. [模块清单与文件映射](#8-模块清单与文件映射)
9. [设计取舍小结](#设计取舍小结)

---

## 1. 模块概述

### 1.1 职责

C910 的 MMU（Memory Management Unit，内存管理单元）负责把 CPU 流水线发出的**虚拟地址（VA）翻译成物理地址（PA）**，并在翻译的同时给出页面的访问权限（R/W/X/U）和内存属性（PMA：Cacheable/Bufferable/Strong-order/Shareable/Security）。它实现的是 RISC-V 特权架构定义的 **Sv39** 翻译模式：

- 39 位虚拟地址 → 最多 40 位物理地址；
- 三级页表（每级 9 bit 索引）；
- 支持 4KB / 2MB / 1GB 三种页大小。

MMU 不是一个单点查表器，而是一套**逐级放大、容量与延迟逐级权衡的存储层次**：

```
取指/访存请求 VA
   │
   ▼
 uTLB (微 TLB，全相联、寄存器、单周期命中)      ← 最快、最小
   │ miss
   ▼
 JTLB (联合 TLB，SRAM、256×4 路、组相联)        ← 容量大、延迟数拍
   │ miss
   ▼
 PTW  (Page Table Walker，硬件页表遍历)          ← 走 LSU 访存读页表，最慢
   │
   ▼  把翻译结果回填 JTLB，再回填 uTLB
 物理地址 PA + 权限 + PMA
```

### 1.2 位置

MMU 处在前端（IFU 取指）和访存（LSU load/store）与物理内存之间。它有三类"客户"：

- **IFU（取指）**：`ifu_mmu_va` 进来，`mmu_ifu_pa`/`mmu_ifu_pavld`/`mmu_ifu_pgflt`/`mmu_ifu_deny` 出去 —— 服务它的是指令侧微 TLB（**iuTLB**）。
- **LSU（访存）**：两条流水各发一个 VA（`lsu_mmu_va0`/`lsu_mmu_va1`），外加一条预取通道（`lsu_mmu_va2`）—— 服务它的是数据侧微 TLB（**duTLB**），双端口。
- **CP0 / 系统**：`satp` 寄存器写入（`cp0_mmu_satp_sel`、`cp0_mmu_wdata`），`sfence.vma` 类操作（`lsu_mmu_tlb_*`、`cp0_mmu_tlb_all_inv`）。

PTW 在 miss 时反过来当"客户"：它通过 `mmu_lsu_data_req`/`mmu_lsu_data_req_addr` 借用 LSU 的访存口去读内存里的页表项（PTE），没有独立的 PTE cache。

翻译完成后，物理地址还要再经过 **PMP**（物理内存保护）和 **sysmap**（硬连线 PMA 区）做最终的权限/属性确认（见第 6 节与 06 篇）。

---

## 2. 端口说明

顶层 `ct_mmu_top.v`（端口声明见该文件 17~129 行）按客户分组，下面只列教学上最关键的接口。

### 2.1 指令侧（IFU 接口）

| 信号 | 方向 | 含义 |
|------|------|------|
| `ifu_mmu_va` / `ifu_mmu_va_vld` | in | IFU 请求翻译的取指 VA |
| `ifu_mmu_abort` | in | IFU 撤销请求 |
| `mmu_ifu_pa` / `mmu_ifu_pavld` | out | 翻译结果物理地址及有效 |
| `mmu_ifu_pgflt` | out | 取指 page fault（缺页/权限） |
| `mmu_ifu_deny` | out | 取指 access fault（PMP/总线拒绝） |
| `mmu_ifu_ca`/`buf`/`sec` | out | 取指页 PMA 属性 |

### 2.2 数据侧（LSU 接口，双端口 + 预取）

| 信号 | 方向 | 含义 |
|------|------|------|
| `lsu_mmu_va0` / `va0_vld` | in | LSU 流水 0 的 VA（端口 0） |
| `lsu_mmu_va1` / `va1_vld` | in | LSU 流水 1 的 VA（端口 1） |
| `lsu_mmu_va2` / `va2_vld` | in | 预取（PFU）通道 VA |
| `mmu_lsu_pa0`/`pa0_vld` … `pa1` | out | 两端口翻译结果 |
| `mmu_lsu_page_fault0/1`、`access_fault0/1` | out | 两端口缺页/访问异常 |
| `mmu_lsu_ca/buf/so/sh/sec 0/1` | out | 两端口 PMA 属性 |

### 2.3 PTW 借用 LSU 访存口

| 信号 | 方向 | 含义 |
|------|------|------|
| `mmu_lsu_data_req` / `_addr` / `_size` | out | PTW 读 PTE 的访存请求 |
| `lsu_mmu_data` / `lsu_mmu_data_vld` | in | LSU 返回的 64-bit PTE |
| `lsu_mmu_bus_error` | in | 读 PTE 时总线出错 → access fault |

### 2.4 CP0 / SFENCE

| 信号 | 方向 | 含义 |
|------|------|------|
| `cp0_mmu_satp_sel` / `cp0_mmu_wdata` | in | 写 satp（含 mode/ASID/PPN） |
| `cp0_yy_priv_mode`、`cp0_mmu_mprv/mpp/sum/mxr/maee` | in | 特权级与翻译控制位 |
| `lsu_mmu_tlb_*_inv`、`cp0_mmu_tlb_all_inv` | in | sfence.vma 各变种 |
| `mmu_xx_mmu_en` / `mmu_lsu_mmu_en` | out | MMU 是否使能（satp.mode==8 且非 M 态） |

---

## 3. 参数与关键寄存器

整套 MMU 的几个宽度参数在每个子模块里反复出现，含义统一（例如 `ct_mmu_ptw.v:250-257`）：

| 参数 | 值 | 含义 |
|------|----|------|
| `VADDR_WIDTH` | 39 | 虚拟地址宽度（Sv39） |
| `PADDR_WIDTH` | 40 | 物理地址宽度 |
| `VPN_WIDTH` | 39-12 = **27** | 虚拟页号宽度 |
| `PPN_WIDTH` | 40-12 = **28** | 物理页号宽度 |
| `FLG_WIDTH` | **14** | 页属性标志位宽（含 PMA 5 位 + 权限 9 位） |
| `PGS_WIDTH` | **3** | 页大小编码（one-hot：4K/2M/1G） |
| `ASID_WIDTH` | **16** | 地址空间标识，**只在 JTLB tag 里存** |
| `PTE_LEVEL` | 3 | 页表级数 |
| `VPN_PERLEL` | 27/3 = **9** | 每级 VPN 索引位数 |

JTLB tag 每路宽度 `TAG_WIDTH = 1+27+16+3+1 = 48` 位（`ct_mmu_ptw.v:263`），data 每路 `DATA_WIDTH = 28+14 = 42` 位（`:264`）。这两个数字解释了 JTLB 的 SRAM 形状（见 03 篇）。

关键软件可见寄存器（实现于 `ct_mmu_regs.v`，详见 06 篇）：

- **satp**（`:630-653`）：`{mode[3:0], asid[15:0], 16'b0, ppn[27:0]}`，mode==`4'b1000` 即开启 Sv39。
- **MIR / MEL / MEH / MCIR**：T-Head 扩展的 TLB 维护寄存器（probe/read/write/invalidate）。

---

## 4. Sv39 单阶段翻译：地址格式与页表

### 4.1 虚拟地址结构

```
 38      30 29      21 20      12 11           0
+----------+----------+----------+-------------+
| VPN[2]   | VPN[1]   | VPN[0]   |  page offset|
|  9 bit   |  9 bit   |  9 bit   |   12 bit    |
+----------+----------+----------+-------------+
```

39 位以上必须是 38 位的符号扩展，否则非法（这就是各模块里的 `va_illegal` 检查，例如 `ct_mmu_dutlb_read.v:472-474`）。三段 VPN 各 9 位，正好对应每级页表 512 项（2^9）的索引。

### 4.2 三级页表遍历

Sv39 是**单阶段**翻译（没有 G-stage/hypervisor 二级翻译）。从 `satp.ppn` 指向的根页表开始：

1. `pte1 = mem[ satp.ppn × 4096 + VPN[2] × 8 ]`
2. `pte0 = mem[ pte1.ppn × 4096 + VPN[1] × 8 ]`
3. `pte  = mem[ pte0.ppn × 4096 + VPN[0] × 8 ]`

PTE 是 8 字节。若中途某级 PTE 的 R/W/X 全 0 表示它是"指向下一级页表的指针"；若 R 或 X 为 1 则它是**叶子 PTE**，翻译在该级结束 —— 在第 1 级结束就是 1GB 大页，第 2 级结束是 2MB 大页，第 3 级结束是 4KB 普通页。这套逻辑在 PTW 的 FSM 里实现（`ct_mmu_ptw.v:641-642` 判断 `ptw_hit_1g`/`ptw_hit_2m`，见 04 篇）。

### 4.3 PTE 的位定义（C910 实现）

PTW 取出 64-bit PTE 后，从中抽取属性（`ct_mmu_ptw.v:639`）：`ptw_flg = {data[9:6], data[4:0]}` 对应 RISC-V 的 `D A G U X W R V`（注意 bit5 的 G 单独取出，`:721`）。高位 `data[63:59]` 是 T-Head 扩展的 PMA 属性（SO/C/B/SH/Sec），仅当 `cp0_mmu_maee`（属性扩展使能）置位时使用（`:709-710`）。

---

## 5. 三级 TLB 是"翻译的存储层次"

把 TLB 类比成 Cache 层次，是理解 C910 MMU 最重要的一把钥匙：

| 层 | 模块 | 容量 | 组织 | 替换 | 延迟 | 类比 |
|----|------|------|------|------|------|------|
| L1（指令） | iuTLB | 32 项 | 全相联、寄存器 | tree-PLRU | 单周期命中 | L0/L1 I-Cache |
| L1（数据） | duTLB | 16 普通 + 1 huge = 17 项 | 全相联、寄存器、双端口 | tree-PLRU | 单周期命中 | L1 D-Cache |
| L2（联合） | JTLB | 1024 项 = 256×4 | 组相联、SRAM | **FIFO** | 多周期（SRAM 读 + 比较 FSM） | L2 Cache |
| 末级 | PTW | — | 走内存页表 | — | 数十~上百周期 | 访问 DRAM |

层次的核心思想：**小而快的表挡住绝大多数请求，大而慢的表兜底，最慢的页表遍历只在真正缺失时触发。**

- **iuTLB / duTLB**（uTLB，微 TLB）：全相联寄存器堆，每项并行比较，命中即在当拍给出 PA。容量小（32/17 项），所以拼**命中速度**。它们**不存 ASID**（注释见 `ct_mmu_iutlb_entry.v:127-128`）：每项总是隐含匹配 satp 里的当前 ASID，进程切换写 satp 时整表清空（`ct_mmu_regs.v:238` `regs_utlb_clr = satp_write_en`）。
- **JTLB**：SRAM 组相联，索引 8 位选组，4 路并行比较。容量大（1024 项），靠它扛住 uTLB 漏下来的请求，省去频繁的页表遍历。它**存 16 位 ASID**和 global 位，进程切换时不必清空（保大表），靠 ASID 区分。
- **PTW**：硬件页表遍历状态机，没有独立 PTE cache，直接借 LSU 访存口读内存里的页表。

为什么 uTLB 用 PLRU 而 JTLB 用 FIFO，为什么 ASID 只存 JTLB —— 见第 7 节与各分篇。

---

## 6. 完整翻译数据流

下面以**数据 load** 为例走一遍全程（取指走 iuTLB，路径同构）：

```
① LSU 发 lsu_mmu_va0 → duTLB (ct_mmu_dutlb.v / _read.v)
   ├─ 命中 17 项之一 → 当拍输出 mmu_lsu_pa0 + 权限 + PMA → 经 PMP/sysmap 确认 → 完成
   └─ miss → duTLB 进入 refill FSM，向 arb 发 dutlb_arb_req
②  arb (ct_mmu_arb.v) 仲裁 I/D/sfence/PTW 对 JTLB+PTW 的共享访问
   → 授权后把 VA、index、bank_sel 发给 JTLB
③ JTLB (ct_mmu_jtlb.v) 用 VPN 低位做 index 读 SRAM，4 路 tag 并行比较 VPN+ASID(或 G)+pagesize
   ├─ 命中 → 经 read FSM (4K→2M→1G) 输出 jtlb_utlb_ref_{ppn,flg,pgs,vpn} → 回填 uTLB → 完成
   └─ miss（4K/2M/1G 都没中）→ jtlb_ptw_req 触发 PTW
④ PTW (ct_mmu_ptw.v) 三级遍历：
   PTW_IDLE → FST_PMP → FST_DATA(读 pte1) → FST_CHK
            → SCD_PMP → SCD_DATA(读 pte0) → SCD_CHK
            → THD_PMP → THD_DATA(读 pte ) → THD_CHK → DATA_VLD
   每级访存都走 mmu_lsu_data_req → lsu_mmu_data 拿回 PTE
   ├─ 命中叶子 PTE → ptw_jtlb_ref_* 把结果经 arb 回填 JTLB（FIFO 选路）→ 再回填 uTLB
   ├─ 权限/有效性不符 → PTW_PGE_FLT → page fault
   └─ PMP/总线拒绝   → PTW_ACC_FLT → access fault
⑤ 回填后请求重新查 uTLB，这次命中，翻译完成
```

要点：

- **arb 是唯一咽喉**：iuTLB、duTLB、sfence(tlboper)、PTW 回填都要经它排队访问 JTLB（`ct_mmu_arb.v:288-319` 的 grant 优先级：PTW > tlboper > duTLB > iuTLB > 预取）。
- **PTW 没有专属内存口**，它把读 PTE 的请求伪装成一次 LSU 访存（`ct_mmu_ptw.v:762-764`），物理地址也要先过 PMP（`mmu_pmp_pa3`）和 sysmap（`mmu_sysmap_pa3`）。
- **回填是双层的**：PTW→JTLB，JTLB→uTLB，两层都会写。

---

## 7. 关键设计决策汇总

### 7.1 为什么 uTLB 用 tree-PLRU、JTLB 用 FIFO？（小表拼命中率 / 大表省存储）

- **uTLB 小（32/16 项），命中率对性能极敏感**：它是流水线关键路径上的单周期表，多一次 miss 就要等数拍 JTLB。所以它愿意花硬件维护一棵 tree-PLRU（iuTLB 31 个状态位、duTLB 15 个状态位，见 01/02 篇），尽量逼近真 LRU，把"最该留的"项留住，挤命中率。
- **JTLB 大（1024 项），状态位代价高**：若给 1024 项做 per-set PLRU，要为 256 组各维护 3 位 tree 状态并和 SRAM 同步读改写，代价不划算；而大表本身命中率已经很高，替换策略的边际收益小。所以 JTLB 用极简的 **FIFO（轮转指针）**：每组 tag 里只多存 4 位 fifo 指针（`ct_mmu_jtlb_tag_array.v:85` 的 `wen[4]` 那 4 位），回填时轮转 `{fifo[2:0],fifo[3]}` 即可（`ct_mmu_ptw.v:791`）。**用一点命中率换大量存储和复杂度。**

### 7.2 为什么 ASID 只存 JTLB？（切换时清小表、保大表）

ASID（地址空间标识）让不同进程的 TLB 项共存而不互相污染，避免每次进程切换全清 TLB。C910 的取舍是：

- **uTLB 不存 ASID**（`ct_mmu_iutlb_entry.v:127-128`、`ct_mmu_dutlb_entry.v:107-109` 注释明确）。每项隐含等于"当前 satp.ASID"。**进程切换写 satp → `regs_utlb_clr` 直接清空 uTLB**（`ct_mmu_regs.v:238`）。因为 uTLB 只有 32/16 项，清空再暖机的代价很小，反而省下每项 16 位 ASID 的存储和比较器。
- **JTLB 存 16 位 ASID + global 位**（tag 含 ASID，`ct_mmu_jtlb.v` 的 `ASID_WIDTH=16`，命中逻辑里 `(ASID 匹配) 或 (global)`）。**进程切换时 JTLB 不清空**，靠 ASID 区分新旧进程的项，保住这张大表暖好的数据 —— 这正是 ASID 机制的价值所在。

一句话：**小表清得起，就别为它付 ASID 的硬件代价；大表清不起，才值得存 ASID 来保命。**

### 7.3 为什么 duTLB 的 huge 项单列一项？

duTLB 有 16 个普通项 + 1 个专用 huge 项（共 17）。普通项比较**全部 27 位 VPN**（`ct_mmu_dutlb_entry.v:195`），只能装 4KB 页；huge 项只比较 **VPN 高 9 位**（`ct_mmu_dutlb_huge_entry.v:195-199`，`VPN[26:18]`），用于 2MB/1GB 大页。

为什么不让普通项也支持大页？因为支持可变页大小的命中比较要在每项里存 pagesize 并做"按页大小掩码后比较"，会让 16 个高频比较器都变复杂、变慢。C910 的取舍是：**把罕见的大页隔离到唯一一项专门处理**，让 16 个普通项保持最简单最快的全宽比较。回填时按 `jtlb_utlb_ref_pgs[2]`（高位=大页）把结果路由到 huge 项，否则用 PLRU 选普通项（见 02 篇）。这是"为常见情况优化、特例单独伺候"的典型工程取舍。

### 7.4 为什么 PTW 没有独立 PTE cache、走 LSU 访存？

页表遍历读的是普通内存，C910 直接复用 LSU 的访存通路（`mmu_lsu_data_req`），让 PTE 自然地命中 L1/L2 D-Cache，**省掉一份专用 PTE cache 的面积**，同时天然获得 cache 的加速。代价是 PTW 要和真正的 load/store 争 LSU 口，并要经 arb 与 PMP 串行确认，但页表遍历本就是低频事件，这个取舍很划算。

---

## 8. 模块清单与文件映射

| 文件 | 行数 | 角色 | 详见 |
|------|------|------|------|
| `ct_mmu_top.v` | 1134 | 顶层例化与端口汇聚 | 本篇 |
| `ct_mmu_iutlb.v` | 2340 | 指令微 TLB（32 项全相联） | [01](01_iutlb.md) |
| `ct_mmu_iutlb_entry.v` | 256 | iuTLB 普通表项 | [01](01_iutlb.md) |
| `ct_mmu_iutlb_fst_entry.v` | 259 | iuTLB fast entry | [01](01_iutlb.md) |
| `ct_mmu_iplru.v` | 1174 | iuTLB 32 叶 tree-PLRU | [01](01_iutlb.md) |
| `ct_mmu_dutlb.v` | 1542 | 数据微 TLB（16+1，双端口） | [02](02_dutlb.md) |
| `ct_mmu_dutlb_entry.v` | 215 | duTLB 普通表项 | [02](02_dutlb.md) |
| `ct_mmu_dutlb_huge_entry.v` | 217 | duTLB huge 表项（2M/1G） | [02](02_dutlb.md) |
| `ct_mmu_dutlb_read.v` | 781 | duTLB 读出/命中 mux/异常 | [02](02_dutlb.md) |
| `ct_mmu_dplru.v` | 940 | duTLB 16 叶 tree-PLRU | [02](02_dutlb.md) |
| `ct_mmu_jtlb.v` | 1456 | 联合 TLB（256×4，FIFO） | [03](03_jtlb.md) |
| `ct_mmu_jtlb_tag_array.v` | 153 | JTLB tag SRAM 封装 | [03](03_jtlb.md) |
| `ct_mmu_jtlb_data_array.v` | 224 | JTLB data SRAM 封装 | [03](03_jtlb.md) |
| `ct_spsram_256x196.v` / `_256x84.v` | 80/80 | tag/data 物理 SRAM | [03](03_jtlb.md) |
| `ct_mmu_ptw.v` | 806 | 页表遍历器（~20 态 FSM） | [04](04_ptw.md) |
| `ct_mmu_arb.v` | 506 | I/D/sfence/PTW 共享仲裁 | [05](05_arb_tlboper.md) |
| `ct_mmu_tlboper.v` | 1132 | sfence.vma / TLB 维护操作 | [05](05_arb_tlboper.md) |
| `ct_mmu_regs.v` | 724 | satp + MIR/MEL/MEH/MCIR | [06](06_regs_sysmap.md) |
| `ct_mmu_sysmap.v` / `_hit.v` | 210/47 | 8 区硬连线 PMA | [06](06_regs_sysmap.md) |
| `sysmap.h` | 52 | 8 区边界/属性宏定义 | [06](06_regs_sysmap.md) |

---

## 设计取舍小结

- **存储层次思想**：uTLB（快小）→ JTLB（大慢）→ PTW（最慢兜底），逐级权衡延迟与容量，与 Cache 层次同构。
- **替换策略分层**：小表（uTLB）用 tree-PLRU 拼命中率，大表（JTLB）用 FIFO 省状态位，按表的规模和敏感度对症下药。
- **ASID 分层**：只在大表 JTLB 存 ASID/global，进程切换清小表保大表，用最小硬件换最大收益。
- **特例隔离**：大页用 duTLB 单独的 huge 项处理，普通项保持最简最快。
- **资源复用**：PTW 不建专用 PTE cache，借 LSU 访存口走 D-Cache；arb 统一咽喉化对 JTLB/PTW 的所有访问，避免多份控制逻辑。

*本篇为总览，不逐行覆盖单一文件；各模块逐行讲解见 01~06 分篇。*
