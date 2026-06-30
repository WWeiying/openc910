# C910 MMU 学习文档索引

OpenC910 内存管理单元（MMU，Sv39 单阶段翻译）的逐模块教学文档。RTL 源码位于 `C910_RTL_FACTORY/gen_rtl/mmu/rtl/`。

核心心智模型：**三级 TLB 是"翻译的存储层次"**——uTLB（快小）→ JTLB（大慢）→ PTW（最慢兜底），与 Cache 层次同构。

## 目录结构

| 文件 | 内容 | 适合阶段 |
|------|------|----------|
| [00_mmu_overview.md](00_mmu_overview.md) | Sv39 单阶段、三级 TLB 存储层次、完整翻译数据流、关键设计决策汇总 | 先读，建立全局观 |
| [01_iutlb.md](01_iutlb.md) | 指令微 TLB：32 项全相联、fast entry（MRU 快项）、tree-PLRU、不存 ASID | 第一个精读 |
| [02_dutlb.md](02_dutlb.md) | 数据微 TLB：16 普通 + 1 huge = 17、双端口、huge 项专存 2M/1G、tree-PLRU | 配合 01 |
| [03_jtlb.md](03_jtlb.md) | 联合 TLB：1024=256×4、SRAM 组织、**ASID 16 位只存这里**、global 位、**FIFO 替换**、4K/2M/1G | TLB 层次核心 |
| [04_ptw.md](04_ptw.md) | 页表遍历器：Sv39 三级遍历、20 态 FSM、借 LSU 访存、无 PTE cache、大页跨区降级 | miss 兜底处理 |
| [05_arb_tlboper.md](05_arb_tlboper.md) | 仲裁（I/D/PFU/sfence/PTW 共享 JTLB）+ TLB 维护操作（sfence.vma 各变种、TLBP/R/WI/WR） | 共享资源与维护 |
| [06_regs_sysmap.md](06_regs_sysmap.md) | satp + MIR/MEL/MEH/MCIR + XMAE 14 位属性（SO/CA/BUF/SEC/SH）+ sysmap 8 区硬连线 PMA | 寄存器与属性 |

## 推荐学习路径

```
第一轮（建立全局观）
  └── 00_mmu_overview.md   ← 三级 TLB 存储层次 + 完整数据流 + 关键取舍

第二轮（一级微 TLB：快小）
  └── 01_iutlb → 02_dutlb   ← 全相联、PLRU、不存 ASID、fast entry / huge 项

第三轮（二级大 TLB 与末级遍历）
  └── 03_jtlb → 04_ptw      ← SRAM 组相联、FIFO、ASID 存这里 / 三级页表遍历

第四轮（共享、维护、配置）
  └── 05_arb_tlboper → 06_regs_sysmap
```

## 三个必须理解的设计取舍

1. **uTLB 用 tree-PLRU，JTLB 用 FIFO**：小表命中率敏感、状态位代价小，拼命中率；大表状态位代价高、命中率本就高，用 FIFO 省存储（fifo 指针塞进 tag SRAM）。
2. **ASID 只存 JTLB**：小表（uTLB）不存 ASID，进程切换整表清空（清得起，省硬件）；大表（JTLB）存 16 位 ASID + global，切换时保留（清不起，靠 ASID 区分）—— 切换时清小表、保大表。
3. **duTLB 的 huge 项单列**：16 个普通项比全 27 位 VPN 专吃 4K，保持最简最快；1 个 huge 项只比高 9 位专吃 2M/1G —— 为常见情况优化、特例单独伺候。

## 模块文件速查

| RTL 文件 | 行数 | 文档 |
|----------|------|------|
| `ct_mmu_top.v` | 1134 | 00 |
| `ct_mmu_iutlb.v` / `_entry.v` / `_fst_entry.v` / `ct_mmu_iplru.v` | 2340/256/259/1174 | 01 |
| `ct_mmu_dutlb.v` / `_entry.v` / `_huge_entry.v` / `_read.v` / `ct_mmu_dplru.v` | 1542/215/217/781/940 | 02 |
| `ct_mmu_jtlb.v` / `_tag_array.v` / `_data_array.v` / `ct_spsram_256x196.v` / `_256x84.v` | 1456/153/224/80/80 | 03 |
| `ct_mmu_ptw.v` | 806 | 04 |
| `ct_mmu_arb.v` / `ct_mmu_tlboper.v` | 506/1132 | 05 |
| `ct_mmu_regs.v` / `ct_mmu_sysmap.v` / `_hit.v` / `sysmap.h` | 724/210/47/52 | 06 |
