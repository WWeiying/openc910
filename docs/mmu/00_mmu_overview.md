# C910 MMU 总览 模块详细教学文档

> RTL 文件：`C910_RTL_FACTORY/gen_rtl/mmu/rtl/`目录下 21 个 Verilog 文件
> （共 14310 行）和 `sysmap.h`（51 行）；顶层 `ct_mmu_top.v`为 1134 行。
>
> 本篇是 MMU 学习的总入口，建立"翻译的存储层次"全局观；各子模块细节见 01~06 分篇。

---

## 目录

1. [模块概述](#1-模块概述)
2. [端口说明](#2-端口说明)
3. [参数与关键寄存器](#3-参数与关键寄存器)
4. [Sv39 单阶段翻译：地址格式与页表](#4-sv39-单阶段翻译地址格式与页表)
5. [两级 TLB 加 PTW 构成翻译层次](#5-两级-tlb-加-ptw-构成翻译层次)
6. [完整翻译数据流](#6-完整翻译数据流)
7. [关键设计决策汇总](#7-关键设计决策汇总)
8. [模块清单与文件映射](#8-模块清单与文件映射)
9. [本章小结](#本章小结)

---

## 1. 模块概述

### 1.1 职责

C910 的 MMU（Memory Management Unit，内存管理单元）负责把 CPU 流水线发出的**虚拟地址（VA）翻译成物理地址（PA）**，并在翻译的同时给出页面的访问权限（R/W/X/U）和内存属性（PMA：Cacheable/Bufferable/Strong-order/Shareable/Security）。它实现的是 RISC-V 特权架构定义的 **Sv39** 翻译模式：

- 39 位虚拟地址 → 最多 40 位物理地址；
- 三级页表（每级 9 bit 索引）；
- 支持 4KB / 2MB / 1GB 三种页大小。

MMU 不是一个单点查表器，而是一套**逐级放大、容量与延迟逐级权衡的翻译
层次**。其中 uTLB 和 JTLB 是两级翻译缓存，PTW 是未命中后的页表读取引擎：

```
取指/访存请求 VA
   │
   ▼
 uTLB (微 TLB，全相联、寄存器实现)              ← 最快、最小
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

- **IFU（取指）**：`ifu_mmu_va`进来，
  `mmu_ifu_pa`/`mmu_ifu_pavld`/`mmu_ifu_pgflt`/`mmu_ifu_deny`出去——服务
  它的是指令侧微 TLB（**iuTLB**）。取指 PC 的 bit0 恒为 0，IFU-MMU 接口
  因而使用右移一位的地址表示：`ifu_mmu_va[62:0]`对应体系结构
  `VA[63:1]`，不是普通的 `VA[62:0]`。
- **LSU（访存）**：两条需求流水各发一个 VA
  （`lsu_mmu_va0`/`lsu_mmu_va1`），由双端口数据侧微 TLB（**duTLB**）
  服务；第三条预取通道 `lsu_mmu_va2` 不进入 duTLB，而是经 MMU arb 直接进入
  JTLB 的 PFU 检查状态机，并使用独立的 PMP 通道 4。
- **CP0 / 系统**：`satp` 寄存器写入（`cp0_mmu_satp_sel`、`cp0_mmu_wdata`），`sfence.vma` 类操作（`lsu_mmu_tlb_*`、`cp0_mmu_tlb_all_inv`）。

PTW 在 miss 时反过来当"客户"：它通过
`mmu_lsu_data_req`/`mmu_lsu_data_req_addr`请求 LSU 中的 MCIC 桥读取页表项
（PTE），没有独立的 PTE cache。MCIC 先申请 D-cache/load DA 通路；D-cache
miss 后才经 RB/BIU 取数，所以“PTW 发出请求”“D-cache 接受请求”和“PTE
返回”是三个不同事件。

**PMP**和 **sysmap**不能笼统写成翻译后的两个串行权限级。PMP 对物理地址做
访问许可检查；sysmap 是硬连线 PMA 属性表，在 MMU 关闭、`maee=0`或 PTW
检查大页是否跨属性区等路径提供属性。页表项自带 XMAE 属性时，正常翻译结果
不需要再由 sysmap 覆盖。PTW 对每一级页表内存地址还会单独发起 PMP 检查。

---

## 2. 端口说明

顶层 `ct_mmu_top.v`（端口声明见该文件 17~129 行）按客户分组，下面只列教学上最关键的接口。

### 2.1 指令侧（IFU 接口）

| 信号 | 方向 | 含义 |
|------|------|------|
| `ifu_mmu_va[62:0]` / `ifu_mmu_va_vld` | in | IFU 请求翻译的取指 VA；总线 bit `n`对应体系结构地址 bit `n+1` |
| `ifu_mmu_abort` | in | IFU 撤销请求 |
| `mmu_ifu_pa[27:0]` / `mmu_ifu_pavld` | out | 翻译结果物理页号 PPN 及有效；完整 PA 还需结合原取指地址的页内偏移 |
| `mmu_ifu_pgflt` | out | 取指 page fault（缺页/权限） |
| `mmu_ifu_deny` | out | 取指 access fault（PMP/总线拒绝） |
| `mmu_ifu_ca`/`buf`/`sec` | out | 取指页 PMA 属性 |

### 2.2 数据侧（LSU 接口，双端口 + 预取）

| 信号 | 方向 | 含义 |
|------|------|------|
| `lsu_mmu_va0` / `va0_vld` | in | LSU 流水 0 的 VA（端口 0） |
| `lsu_mmu_va1` / `va1_vld` | in | LSU 流水 1 的 VA（端口 1） |
| `lsu_mmu_va2[27:0]` / `va2_vld` | in | PFU 的页号形式请求；MMU 开启时低 27 位作为 VPN，关闭时 28 位作为 PPN |
| `mmu_lsu_pa0`/`pa0_vld` … `pa1` | out | 两端口翻译得到的 28-bit PPN；完整 PA 的 12-bit 页内偏移由 LSU 保留 |
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
| `mmu_xx_mmu_en` / `mmu_lsu_mmu_en` | out | satp.mode==8 时的取指/数据翻译使能；数据侧有效特权级还受 MPRV/MPP 影响 |

---

## 3. 参数与关键寄存器

整套 MMU 的几个宽度参数在每个子模块里反复出现，含义统一（例如 `ct_mmu_ptw.v:250-257`）：

| 参数 | 值 | 含义 |
|------|----|------|
| `VADDR_WIDTH` | 39 | 虚拟地址宽度（Sv39） |
| `PADDR_WIDTH` | 40 | 物理地址宽度 |
| `VPN_WIDTH` | 39-12 = **27** | 虚拟页号宽度 |
| `PPN_WIDTH` | 40-12 = **28** | 物理页号宽度 |
| `FLG_WIDTH` | **14** | JTLB/uTLB data flag：PMA 5 位 + RSW/D/A/U/X/W/R/V 9 位；G 另存于 JTLB tag |
| `PGS_WIDTH` | **3** | 页大小编码（one-hot：4K/2M/1G） |
| `ASID_WIDTH` | **16** | 地址空间标识；翻译缓存项中仅 JTLB tag 保存，satp/维护寄存器也保存或传递 ASID |
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

PTE 是 8 字节。按 Sv39 规则，`V=1`且 R/W/X 全 0 才是指向下一级页表的
合法非叶 PTE；`V=0`或 `R=0,W=1`应为非法项。`V=1`且 R 或 X 为 1是叶子，
在第一级结束为 1GB、第二级为 2MB、第三级为 4KB。当前 PTW 对无效中间级项
的组合门控存在需要定向验证的边界，详见 04 篇，不能把体系结构规则和当前
RTL 实现行为混写成同一结论。

### 4.3 PTE 的位定义（C910 实现）

PTW 取出 64-bit PTE 后，用
`ptw_flg[8:0] = {data[9:6], data[4:0]}`形成
`{RSW[1:0],D,A,U,X,W,R,V}`。PTE bit5 的 **G** 不在这 9 位中，而是单独保存
为 `ptw_ref_g`。最终写入 TLB data 的 14-bit flag 为
`{PMA[4:0],RSW[1:0],D,A,U,X,W,R,V}`；G 位在 JTLB tag 中。高位
`data[63:59]` 是 T-Head 扩展 PMA/XMAE 属性（SO/CA/BUF/SH/SEC），仅在
`cp0_mmu_maee=1`时采用，否则 PMA 来自 sysmap。

---

## 5. 两级 TLB 加 PTW 构成翻译层次

把**翻译缓存**类比成 Cache 层次，是理解 C910 MMU 的重要方法；但要避免把
PTW 误叫成 TLB。C910 有分离的一级 iuTLB/duTLB、统一的二级 JTLB，以及
JTLB miss 后读取内存页表的 PTW：

| 层 | 模块 | 容量 | 组织 | 替换 | 延迟 | 类比 |
|----|------|------|------|------|------|------|
| L1（指令） | iuTLB | 32 项（4 fast + 28 slow） | 全相联比较、寄存器 | tree-PLRU；slow hit 与 fast slot 交换 | fast slot 直接供 PA；slow hit 先提升 | L0/L1 I-TLB |
| L1（数据） | duTLB | 16 普通 + 1 个 1GB 项 = 17 项 | 全相联、寄存器、双端口 | 16 项 tree-PLRU | 组合命中/读出，外部完成仍受 PMP 等级影响 | L1 D-TLB |
| L2（联合） | JTLB | 1024 项 = 256×4 | 组相联、SRAM | 4-bit one-hot 轮转指针 | 多周期 SRAM 读、TA/TC 比较；大页可能多次查组 | L2 TLB |
| 页表遍历 | PTW | — | 经 LSU/MCIC 读页表 | — | 取决于级数、cache/总线命中和仲裁 | 不是 TLB；是未命中处理引擎 |

层次的核心思想：**小而快的表挡住绝大多数请求，大而慢的表兜底，最慢的页表遍历只在真正缺失时触发。**

- **iuTLB**：32 项都并行比较，以判断翻译是否已在表内；但最终快速 PA/PGS/flag
  mux 只读取 entry 0/8/16/24 四个 fast slot。slow entry 命中不是 JTLB miss，
  而是把该项与按 round-robin 选中的 fast slot 在时钟沿交换；IFU 保持/重提
  请求后再从 fast slot 完成。这比“32 项都当拍出 PA”更准确。
- **duTLB**：两个 LSU 端口对 17 项并行比较。16 个普通项保存 4KB 翻译，也
  保存由 2MB JTLB 项按当前 VPN 低 9 位专门化出的 4KB 子页翻译；唯一 huge
  项只保存 1GB 翻译。它们都不存页大小字段，读出逻辑按项类别确定 4KB/1GB。
- **uTLB 的 ASID**：iuTLB/duTLB 表项都不存 ASID。写 satp 时
  `regs_utlb_clr`整清两张小表；这里说“表项不存 ASID”，不包括 satp 和维护
  寄存器本身。
- **JTLB**：SRAM 组相联，物理 SRAM 地址为候选 9-bit VPN 段的低 8 位，
  剩余一位仍在完整 VPN tag 中比较。它保存 16 位 ASID 和 global 位。
- **PTW**：硬件页表遍历状态机，没有独立 PTE cache，经 LSU MCIC 先查
  D-cache，miss 时复用 RB/BIU。

为什么 uTLB 用 PLRU、JTLB 用只在回填时推进的轮转指针，以及为什么 uTLB
表项不存 ASID，见第 7 节与各分篇。

---

## 6. 完整翻译数据流

下面以**数据 load** 为例走一遍全程（取指走 iuTLB，路径同构）：

```
① LSU 发 lsu_mmu_va0 → duTLB (ct_mmu_dutlb.v / _read.v)
   ├─ 命中 17 项之一 → 组合选择 PPN + 权限 + PMA → PPN 缓存/PMP 检查 → 对 LSU 报有效或异常
   └─ miss → duTLB 进入 refill FSM，向 arb 发 dutlb_arb_req
②  arb (ct_mmu_arb.v) 仲裁 I/D/PFU/tlboper/PTW-refill 对 JTLB 的访问
   → 授权后把 VA、index、bank_sel 发给 JTLB
③ JTLB (ct_mmu_jtlb.v) 按候选页大小选择一段 VPN，其低 8 位索引 SRAM，
   4 路并行比较完整掩码 VPN + pagesize + (ASID 匹配或 G)
   ├─ 命中 → 经 read FSM (4K→2M→1G) 输出 jtlb_utlb_ref_{ppn,flg,pgs,vpn} → 回填 uTLB → 完成
   └─ miss（4K/2M/1G 都没中）→ jtlb_ptw_req 触发 PTW
④ PTW (ct_mmu_ptw.v) 三级遍历：
   PTW_IDLE → FST_PMP → FST_DATA(读 pte1) → FST_CHK
            → SCD_PMP → SCD_DATA(读 pte0) → SCD_CHK
            → THD_PMP → THD_DATA(读 pte ) → THD_CHK → DATA_VLD
   每级访存都走 mmu_lsu_data_req → lsu_mmu_data 拿回 PTE
   ├─ 命中叶子 PTE → ptw_jtlb_ref_* 经 arb 按 one-hot 轮转指针回填 JTLB → 再回填 uTLB
   ├─ 权限/有效性不符 → PTW_PGE_FLT → page fault
   └─ PMP/总线拒绝   → PTW_ACC_FLT → access fault
⑤ 回填后请求重新查 uTLB，这次命中；LSU 把返回 PPN 与自己保留的页内偏移组合成完整 PA
```

要点：

- **arb 是 JTLB 入口的统一仲裁点**：iuTLB、duTLB、PFU、tlboper 和 PTW
  回填经它访问 JTLB；JTLB 大页重查和 parity-clear 还是内部附加来源。PTW
  读取页表内存不经过这个 arb，而是走 LSU/MCIC。
- **可见固定请求优先级**是 PTW 回填 > tlboper > duTLB > iuTLB > PFU，
  但 grant 还受 `utlb_mask`、JTLB read FSM 阶段等条件限制。优先级背后的
  “关键性”属于设计动机推断，不是 grant 公式本身。
- **PTW 没有专属内存口**：每级先在 `*_PMP`状态观察该 PTE 物理地址的 PMP
  结果，再在 `*_DATA`状态保持 `mmu_lsu_data_req`，由 MCIC 接入 D-cache/RB。
  sysmap 在此提供 PMA/大页跨区信息，不是另一层访问许可。
- **回填是双层的**：PTW→JTLB，JTLB→uTLB，两层都会写。

### 6.1 性能事件与调试总线不能只按名字理解

顶层导出 `mmu_hpcp_iutlb_miss`、`mmu_hpcp_dutlb_miss`和
`mmu_hpcp_jtlb_miss`，但三者都不是“看到查表 miss 的组合条件就立即拉高”：

- I/D uTLB 事件在 `jtlb_*utlb_ref_pavld`形成有效 refill 时产生，源条件经
  一个置位/自清零寄存器输出；正常单次完成表现为一个周期的事件，但 RTL
  没有另做上升沿计数器；page/access fault 结束的 miss 不计入；
- JTLB 事件在 I/D 请求的 PTW 成功走到 `PTW_DATA_VLD`，且原 uTLB 仍处于
  等待完成状态时产生；PFU miss、PTW fault 和未成功回填的情况不计入。
  该源条件同样经过置位/自清零寄存器。若 `PTW_DATA_VLD`因 JTLB 回填屏蔽而
  连续保持，输出也可连续保持为高，不能无条件解释成“一次 miss 一个脉冲”。

因此这些更接近“成功完成的对应层 miss/refill 事件”，不是所有 miss 尝试数。
`mmu_had_debug_info[33:0]`则把 iuTLB/duTLB refill、各 tlboper FSM、arb、
JTLB read FSM 和 PTW 状态压成一条调试总线。看波形时应优先展开各源状态，
不要把 34 位总线当成一个数值曲线。

---

## 7. 关键设计决策汇总

### 7.1 为什么 uTLB 用 tree-PLRU、JTLB 用轮转指针？

- **uTLB 小且每次命中都可更新状态**：iuTLB 的 32 项 PLRU 使用 31 个树节点
  位，duTLB 的 16 个普通项使用 15 位；命中和回填都会更新相关路径。它们近似
  最近使用关系，但不是严格 LRU。
- **JTLB 使用 4-bit one-hot 轮转指针**：每个物理 set 的指针与 tag 一同
  存在 256×196 SRAM 中，只在 refill/TLBWR 等替换动作时旋转，不在普通 hit
  时维护访问次序。因此它更准确地说是 FIFO-like/round-robin，而不是真 LRU。
- **不能把它解释成“更省状态位”**：4-way tree-PLRU 理论上只需 3 bit/set，
  当前 one-hot 指针用了 4 bit/set。这里直接可见的优势是状态更新简单、普通
  命中无须读改写替换状态，并能随 tag SRAM 同端口读写；性能收益或面积收益
  仍需综合和 workload 数据证明。

### 7.2 为什么 uTLB 表项不存 ASID，而 JTLB 表项存？

ASID（地址空间标识）让不同进程的 TLB 项共存而不互相污染，避免每次进程切换全清 TLB。C910 的取舍是：

- **uTLB 不存 ASID**（`ct_mmu_iutlb_entry.v:127-128`、`ct_mmu_dutlb_entry.v:107-109` 注释明确）。每项隐含等于"当前 satp.ASID"。**进程切换写 satp → `regs_utlb_clr` 直接清空 uTLB**（`ct_mmu_regs.v:238`）。因为 uTLB 只有 32/16 项，清空再暖机的代价很小，反而省下每项 16 位 ASID 的存储和比较器。
- **JTLB 存 16 位 ASID + global 位**（tag 含 ASID，`ct_mmu_jtlb.v` 的 `ASID_WIDTH=16`，命中逻辑里 `(ASID 匹配) 或 (global)`）。**进程切换时 JTLB 不清空**，靠 ASID 区分新旧进程的项，保住这张大表暖好的数据 —— 这正是 ASID 机制的价值所在。

一句话：**小表清得起，就别为它付 ASID 的硬件代价；大表清不起，才值得存 ASID 来保命。**

### 7.3 为什么 duTLB 只有一个 1GB 专用项？

duTLB 有 16 个普通项 + 1 个专用 1GB 项。普通项比较完整 27-bit VPN，专用项
只比较 VPN[26:18]。回填路由严格由 `jtlb_utlb_ref_pgs[2]`控制，所以只有
`pgs=3'b100`的 1GB 页进入 entry16。

2MB 项的处理更精细：它进入 16 个普通项，但回填时把请求 VPN[8:0]补入表项
VPN，并把同一低 9 位补入 PPN，相当于只缓存该 2MB 映射中当前访问的 4KB
子页。这样普通项无需存 pagesize 或做可变掩码比较；代价是访问同一 2MB 页中
另一个 4KB 子页时，duTLB 仍可能 miss 并再次访问 JTLB。这里的“简化比较器”
是 RTL 可见事实；“为了时序”是合理设计动机，但需要时序报告才能证实收益。

### 7.4 为什么 PTW 没有独立 PTE cache、走 LSU 访存？

页表遍历读的是物理内存。C910 通过 `mmu_lsu_data_req`和 MCIC 复用 LSU：
D-cache hit 时从 load DA 借用数据返回，miss 时经 RB/BIU。RTL 中没有独立
PTE cache，这是明确事实；PTE 是否命中 D-cache、系统是否配置 L2，以及与
普通 load/store 竞争造成多少代价，取决于运行环境。因而不能把“自然命中
L1/L2”或“这个取舍必然划算”写成无条件结论。

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
| `ct_mmu_dutlb_huge_entry.v` | 217 | duTLB 1GB 专用表项 | [02](02_dutlb.md) |
| `ct_mmu_dutlb_read.v` | 781 | duTLB 读出/命中 mux/异常 | [02](02_dutlb.md) |
| `ct_mmu_dplru.v` | 940 | duTLB 16 叶 tree-PLRU | [02](02_dutlb.md) |
| `ct_mmu_jtlb.v` | 1456 | 联合 TLB（256×4，one-hot 轮转替换） | [03](03_jtlb.md) |
| `ct_mmu_jtlb_tag_array.v` | 153 | JTLB tag SRAM 封装 | [03](03_jtlb.md) |
| `ct_mmu_jtlb_data_array.v` | 224 | JTLB data SRAM 封装 | [03](03_jtlb.md) |
| `ct_spsram_256x196.v` / `_256x84.v` | 97/97 | tag/data 物理 SRAM | [03](03_jtlb.md) |
| `ct_mmu_ptw.v` | 806 | 页表遍历器（~20 态 FSM） | [04](04_ptw.md) |
| `ct_mmu_arb.v` | 506 | I/D/sfence/PTW 共享仲裁 | [05](05_arb_tlboper.md) |
| `ct_mmu_tlboper.v` | 1132 | sfence.vma / TLB 维护操作 | [05](05_arb_tlboper.md) |
| `ct_mmu_regs.v` | 724 | satp + MIR/MEL/MEH/MCIR | [06](06_regs_sysmap.md) |
| `ct_mmu_sysmap.v` / `_hit.v` | 210/47 | 8 区硬连线 PMA | [06](06_regs_sysmap.md) |
| `sysmap.h` | 51 | 8 区边界/属性宏定义 | [06](06_regs_sysmap.md) |

---

## 本章小结

C910 的地址翻译由 uTLB、JTLB 和 PTW 逐级接力。IFU 的 iuTLB 与 LSU 的 duTLB 先以小容量、并行比较的结构回答高频访问；miss 后进入容量更大的 256 组 4 路 JTLB；JTLB 对 4KB、2MB、1GB 三种页尺寸都未命中时，PTW 才读取真实页表。uTLB 和 JTLB 保存缓存后的翻译，PTW 是页表遍历状态机而不是第三级 TLB。MMU arb 统一仲裁 iuTLB、duTLB、PFU、维护操作和 PTW 回填对 JTLB 端口的使用，PTW 读取 PTE 的内存事务则经 MCIC 进入 LSU/D-cache/RB/BIU，不经过这个 JTLB 仲裁入口。

各层替换与地址空间隔离方式也不同。小表使用命中更新的 tree-PLRU，JTLB 使用仅在回填时推进的每组 one-hot 轮转指针；后者减少命中路径上的状态更新，但不能据此直接推导命中率优劣。ASID 和 global 位只保存在 JTLB，uTLB 项隐含当前 satp 地址空间，因此 satp 切换需要清空小表，而 JTLB 可继续依靠 ASID/G 隔离。duTLB 还把 1GB 页放入独立项，2MB 页则专门化为当前 4KB 子页后进入普通项。由此分析一次翻译时，必须同时标明请求来自哪个端口、在哪一层命中、页尺寸如何表达、PMP/PMA 权限是否通过以及 miss 是否已经进入 PTW；单独看到某级 hit 或 grant 还不等于最终访存已经完成。各模块的逐级逻辑见 01 至 06 分篇。
