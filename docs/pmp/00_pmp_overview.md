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
11. [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 职责

`ct_pmp_top` 是 OpenC910 物理内存保护单元的顶层。它把三件事拼在一起：

1. **CSR 接口**：接收 CP0（C910 中承载所有 CSR 的单元）发来的 PMP 寄存器读写请求，
   译码出要访问哪一个 PMP CSR（pmpcfg0/pmpcfg2 或 pmpaddr0~15），驱动写使能，
   并把读结果 `pmp_cp0_data` 返回。
2. **寄存器堆**：例化唯一一份 `ct_pmp_regs`，存放 8 组配置/地址寄存器。
3. **访问检查**：例化 **5 个** `ct_pmp_acc` 实例，分别对 MMU 的 5 条物理页号通路
   `mmu_pmp_pa0`~`mmu_pmp_pa4` 做地址匹配，输出 5 组
   `pmp_mmu_flg0`~`pmp_mmu_flg4`。每组 4 位的位序是 `{L,X,W,R}`。

这里的“5 条通路”表示 RTL 中有 5 套始终并行存在的组合比较逻辑，并不等价于“每周期一定
发生 5 次有效访问”。`ct_pmp_top` 本身没有为这 5 个地址配套 `valid` 输入；地址何时有效、
何时采纳权限结果，由 MMU 内各来源通路自己的状态和有效信号控制。PMP 只对当前线网上的
页号持续产生组合结果。

一句话：**寄存器堆只有一份，检查器有五套**。CSR 配置是带时序状态的控制通路；地址
匹配是无状态组合通路。五套比较器允许五个 MMU 来源各自得到结果，但实际事务是否有效
仍由来源通路判断。

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

对普通取指、load/store 和预取而言，PMP 检查使用 MMU 翻译后的物理页号；MMU 关闭时则
使用直通得到的物理页号。PTW 通道是必须单独说明的例外视角：它检查的是页表遍历过程中
即将读取的 **PTE 所在物理地址**，而不是“最终被翻译目标”的物理地址。因此，更准确的
表述是：**PMP 位于各类物理访问形成之后、访问被相应通路接纳之前**。PMP 返回权限元数据，
MMU 再结合访问类型、结果有效时刻以及 M 模式的 `L` 位旁路规则形成 access fault。

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
| `pmp_mmu_flg0`~`flg4` | out | 4 each | 58-62 | 5 组匹配结果元数据，位序 `{L,X,W,R}`；不是独立的“结果有效”或“访问完成”信号 |

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
| `pmpaddr0_value`~`7_value` | 29 each | 99-106 | 8 个地址寄存器的实现值；对应 CSR `[37:9]`，不是完整字节地址 |
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
- **系统级主设备保护**：DMA 等非 CPU 主设备通常需要系统级防火墙、IOMMU 或其他物理
  保护机制。`ct_pmp_top.v` 中确有一段被注释掉的 `ct_l2pmp_*` 生成痕迹，但注释不是有效
  例化，不能据此断言当前 OpenC910 RTL 已集成一套可工作的 L2 PMP；该能力必须到实际 SoC
  集成层和有效 RTL 中另行核查。

---

## 5. 与 MMU 的先后关系：翻译后查物理地址

对一条普通虚拟地址访问，可以用下面的顺序建立直觉：

```
虚拟地址 ──[MMU 翻译/或 Bare 透传]──► 物理地址 ──[PMP 权限检查]──► 实际访问
                                            │
                                  匹配命中的 PMP 区给出 R/W/X
                                  不满足则 access fault
```

这就是为什么 `ct_pmp_top` 的输入是 `mmu_pmp_pa0`~`pa4`（物理地址的
`PA[39:12]`），而不是虚拟地址。`ct_pmp_acc` 和 `ct_pmp_comp_hit` 不含流水寄存器，
所以地址、配置和有效特权模式变化后，`pmp_mmu_flg` 经过组合传播随之变化；这里没有
request/accept/complete 握手，也不能把“组合结果已经变化”称为“一次检查已经完成”。

权限结果的消费还多一步。例如 I-uTLB 在自己的 `pmp_flg_vld` 有效时检查 X 位；若有效
模式是 M 且命中项 `L=0`，则旁路该项的 X 限制。D-uTLB 分别按 load/store 检查 R/W。
因此 `pmp_mmu_flg` 是**匹配项属性**，access fault 才是结合访问语义后的最终判断。

PTW 也复用这套检查器，但送入的是 PTE 读取地址。该地址本来就是物理地址，不应把 PTW
路径误画成“先完成本次目标地址翻译，再检查目标地址”。

**为什么是 MMU 来送地址而不是 LSU/IFU 直接送？** 因为无论翻译开/关，物理地址都从
MMU 这一点流出（Bare 模式 MMU 做透传），由 MMU 统一汇聚成 5 个并发地址送 PMP，
避免在每个访存源各放一份 PMP，节省面积。

---

## 6. 8 区结构与 5 条并行通道

### 6.1 8 个 PMP 区（entry）

当前 OpenC910 RTL 实际实现 **8 个**可配置、可参与匹配的 entry（entry 0~7）。
每个区由一对寄存器描述：

- `pmpcfgN`：8 位配置字节，含 R/W/X 权限、A 匹配模式（OFF/TOR/NA4/NAPOT）、L 锁位；
- `pmpaddrN`：编码该区覆盖的物理地址范围（基址或上界，编码方式取决于 A）。

顶层仍译码 `pmpcfg2` 和 `pmpaddr8`~`pmpaddr15`，但 `ct_pmp_regs` 将相应读值硬连为 0，
也没有这些条目的状态更新逻辑；`ct_pmp_acc` 又把 `pmp_hit[15:8]` 硬连为 0。因此应称其为
“CSR 地址被译码但条目未实现”，而不是“条目存在但永不命中”。

### 6.2 5 条并行检查通道

`ct_pmp_top` 例化 5 个 `ct_pmp_acc`（行 237、258、279、300、321），每个吃一个物理地址。
5 条通道的来源可从 MMU 连线逐一确认：

| 通道 | 地址来源 | 主要用途 |
|------|----------|----------|
| 0 | D-uTLB 端口 0 | load/原子等数据侧地址 |
| 1 | D-uTLB 端口 1 | store 等数据侧地址 |
| 2 | I-uTLB | 取指地址 |
| 3 | PTW 的 `ptw_req_addr` | 页表遍历中的 PTE 物理地址；原始 miss 类型决定检查 X/R/W |
| 4 | JTLB 的 PFU 通路 | 数据预取地址，消费端检查 R |

每个通道都并行匹配全部 8 个已实现条目，所以源码层面共有
8 区 × 5 通道 = 40 个 `ct_pmp_comp_hit` 实例。寄存器堆只有一份，其 cfg/addr 输出广播给
5 个 acc。表中的“用途”描述地址的来源与消费方式，并不表示 PMP 顶层自己保存了访问类型；
除通道 3 的 `mmu_pmp_fetch3` 外，具体读、写、执行选择由 MMU 消费端完成。

> 从结构上看，“一份配置状态 + 多套组合比较器”避免了复制软件可见状态，同时保留 5 条
> 独立结果通路。它通常有利于状态一致性，并以更多比较逻辑换并行性；没有综合结果时，
> 不应进一步断言它是特定工艺下的面积或时序最优解。

---

## 7. M 态语义与特权模式

### 7.1 M 态默认全通

RISC-V 规定：**M 态（machine mode）对未被任何区匹配的地址默认拥有全部权限**；而
U/S 态对未匹配地址默认**无任何权限**（访问即 fault）。这一默认值在 `ct_pmp_acc` 中实现：

```verilog
assign pmp_default_flg[3:0] = cp0_mach_mode ? 4'b0111 : 4'b0;   // ct_pmp_acc.v 行 256
```

`4'b0111` = {L=0, X=1, W=1, R=1}，即 M 态默认 RWX 全开；非 M 态默认全 0（全拒）。

### 7.2 L 位决定 M 模式能否旁路命中项权限

匹配项的 `{L,X,W,R}` 会原样送回 MMU，但“是否约束 M 态”不是在 `ct_pmp_acc` 内单独
完成的。MMU 消费端采用下面的判断：

```text
权限位不允许
且结果已到达该通路的有效时刻
且不是（有效模式为 M 且 L=0）
    -> access fault / deny
```

因此：

- 命中 `L=0` 项时，S/U 按 R/W/X 受限，M 模式旁路该限制；
- 命中 `L=1` 项时，M 模式也按 R/W/X 受限；
- 无命中时，`ct_pmp_acc` 给有效 M 模式 `{L,X,W,R}=4'b0111`，给非 M 模式全 0。

这条跨模块链路很重要：只看 `ct_pmp_acc` 的优先编码，会误以为“M 模式命中任何条目都受
R/W/X 限制”；只看默认值，又会误以为“M 模式永远不受 PMP 限制”。

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

真正进入各寄存器更新条件的是 `pmp_csr_wen`；`wr_pmp_regs` 是其归约或，只作为 PMP
门控时钟的 `local_en`。因此“译码出写请求”与“某个状态确实可更新”也要区分：锁位可能让
对应 `pmp_updt_*` 为 0，未实现的 entry8~15 也没有状态可写，但顶层门控时钟仍会因
`wr_pmp_regs=1` 被请求打开。

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

在正常功能模式下，`wr_pmp_regs` 是局部门控条件；门控单元还同时受
`cp0_pmp_icg_en`、`global_en` 和扫描使能控制。软件通常只在初始化或安全状态切换时改写
PMP，因此这种结构减少无写入期间的寄存器时钟翻转。具体功耗收益仍需门级功耗分析，
不能仅由 RTL 断言“很大”。
注意：**地址匹配和权限选择通路是纯组合逻辑**，不使用 `cpuclk`。关闭寄存器门控时钟会
保持配置状态不变，但不会冻结组合输出；输入页号或有效特权模式变化时，输出仍会传播变化。

---

## 10. MPRV 旁路：每通道独立处理

`mstatus.MPRV` 改变显式内存访问所使用的有效特权模式，而不改变取指特权。顶层不重新
判断 CSR 写入是否合法，而是消费 CP0 已给出的 `cp0_pmp_mprv`/`cp0_pmp_mpp`，为 5 个通道
分别形成 MPRV 选择条件：

```verilog
assign pmp_mprv_status0 = cp0_pmp_mprv;                       // 访存通道
assign pmp_mprv_status1 = cp0_pmp_mprv;                       // 访存通道
assign pmp_mprv_status2 = 1'b0;                               // 该通道恒不受 MPRV（如取指）
assign pmp_mprv_status3 = cp0_pmp_mprv && !mmu_pmp_fetch3;    // 取指时强制关 MPRV
assign pmp_mprv_status4 = cp0_pmp_mprv;                       // 访存通道
```

- 通道 2 直接钉死 `1'b0`：该通道服务的访问类型（取指）本就不应用 MPRV；
- 通道 3 是 PTW 对 PTE 地址的检查。`mmu_pmp_fetch3=ptw_fetch_type` 表示这次页表遍历源于
  取指 miss；此时关闭 MPRV。源于 load/store/prefetch miss 时允许按 CP0 的 MPRV/MPP 选择
  有效模式。这里的 `fetch` 描述**引发遍历的原始访问类型**，PTE 本身仍通过 LSU 被读取。
- 通道 4 服务数据预取，保留 MPRV 选择。

这是 PMP 顶层为数不多的"每通道差异化"逻辑，体现了取指与访存在 MPRV 语义上的根本区别。

---

## 本章小结

当前 PMP 只有 entry0 至 entry7 具备配置状态和地址比较器，entry8 至 entry15 虽落在部分 CSR 地址译码范围内，但读回为 0 且不参与匹配。八个 entry 共用一份寄存器状态，并并行送往五套组合检查器，为 IFU、LSU、PTW 等不同 MMU 访问通道独立生成 `{L,X,W,R}` 属性。PMP 内部没有请求握手或额外流水寄存器，输入地址和有效特权组合传播到属性输出，结果在哪一拍被消费由各 MMU 通路的 valid 决定。该结构的具体面积和关键路径只能由综合报告确认。

每个通道都根据访问类型独立处理 MPRV：取指不采用数据访问的 MPRV 语义，动态兼作 fetch 的通道还必须先判定当前请求类别。CSR 接口只传变化的低位并在 PMP 内硬拼公共高位；RV64 的 pmpcfg0 打包 entry0 至 entry7，奇数编号 pmpcfg CSR 不存在，pmpcfg2 和更高 entry 在当前实现中无有效状态。分析权限失败时，应沿“CSR 配置与 lock、地址模式匹配、最低编号命中、有效特权、MMU 消费端访问类型判断”逐层定位，不能只看最终 page/access fault。被注释的生成痕迹不构成现行功能。
