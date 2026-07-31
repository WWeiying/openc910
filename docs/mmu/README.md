# C910 MMU 学习文档索引

OpenC910 内存管理单元（MMU，Sv39 单阶段翻译）的逐模块教学文档。RTL 源码位于 `C910_RTL_FACTORY/gen_rtl/mmu/rtl/`。

核心心智模型：**两级 TLB 加页表遍历器构成三级翻译层次**——uTLB（快小）
→ JTLB（大慢）→ PTW（最慢兜底）。前两级缓存翻译，PTW 读取内存中的页表；
PTW 本身不是第三级 TLB。

## 目录结构

| 文件 | 内容 | 适合阶段 |
|------|------|----------|
| [00_mmu_overview.md](00_mmu_overview.md) | Sv39 单阶段、两级 TLB + PTW 翻译层次、完整翻译数据流、关键设计决策汇总 | 先读，建立全局观 |
| [01_iutlb.md](01_iutlb.md) | 指令微 TLB：32 项全相联比较、4 fast + 28 slow、轮转交换、tree-PLRU、不存 ASID | 第一个精读 |
| [02_dutlb.md](02_dutlb.md) | 数据微 TLB：16 普通 + 1 个 1GB 项、双端口、2MB 按 4KB 子页专门化、tree-PLRU | 配合 01 |
| [03_jtlb.md](03_jtlb.md) | 联合 TLB：1024=256×4、8-bit 物理 set index、ASID/global、one-hot 轮转替换、4KB/2MB/1GB | TLB 层次核心 |
| [04_ptw.md](04_ptw.md) | 页表遍历器：Sv39 三级遍历、20 态 FSM、借 LSU 访存、无 PTE cache、大页跨区降级 | miss 兜底处理 |
| [05_arb_tlboper.md](05_arb_tlboper.md) | 仲裁（I/D/PFU/sfence/PTW 共享 JTLB）+ TLB 维护操作（sfence.vma 各变种、TLBP/R/WI/WR） | 共享资源与维护 |
| [06_regs_sysmap.md](06_regs_sysmap.md) | satp + MIR/MEL/MEH/MCIR + XMAE 14 位属性（SO/CA/BUF/SEC/SH）+ sysmap 8 区硬连线 PMA | 寄存器与属性 |

## 推荐学习路径

```
第一轮（建立全局观）
  └── 00_mmu_overview.md   ← 两级 TLB + PTW 翻译层次 + 完整数据流 + 关键取舍

第二轮（一级微 TLB：快小）
  └── 01_iutlb → 02_dutlb   ← 全相联、PLRU、不存 ASID、fast entry / huge 项

第三轮（二级大 TLB 与末级遍历）
  └── 03_jtlb → 04_ptw      ← SRAM 组相联、轮转替换、ASID/G / 三级页表遍历

第四轮（共享、维护、配置）
  └── 05_arb_tlboper → 06_regs_sysmap
```

## 三个必须理解的设计取舍

1. **替换更新方式不同**：uTLB tree-PLRU在命中/回填时更新；JTLB
   4-bit one-hot 指针只在替换时旋转。后者控制更简单，但不比 3-bit
   4-way tree-PLRU 更省位。
2. **ASID 分层**：uTLB 翻译项不存 ASID，satp 写时整清；JTLB tag 保存
   16-bit ASID + G，satp 写不直接扫清大表。
3. **duTLB 大页不对称**：唯一专用项只缓存 1GB；2MB JTLB 翻译按当前
   VPN[8:0]展开成普通项中的 4KB 子页。

## 模块文件速查

| RTL 文件 | 行数 | 文档 |
|----------|------|------|
| `ct_mmu_top.v` | 1134 | 00 |
| `ct_mmu_iutlb.v` / `_entry.v` / `_fst_entry.v` / `ct_mmu_iplru.v` | 2340/256/259/1174 | 01 |
| `ct_mmu_dutlb.v` / `_entry.v` / `_huge_entry.v` / `_read.v` / `ct_mmu_dplru.v` | 1542/215/217/781/940 | 02 |
| `ct_mmu_jtlb.v` / `_tag_array.v` / `_data_array.v` / `ct_spsram_256x196.v` / `_256x84.v` | 1456/153/224/97/97 | 03 |
| `ct_mmu_ptw.v` | 806 | 04 |
| `ct_mmu_arb.v` / `ct_mmu_tlboper.v` | 506/1132 | 05 |
| `ct_mmu_regs.v` / `ct_mmu_sysmap.v` / `_hit.v` / `sysmap.h` | 724/210/47/51 | 06 |
