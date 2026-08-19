# x86-64 Split Lock：一次跨 Cache Line 的原子操作，能拖慢多少邻居：发布资料

## 正式标题

x86-64 Split Lock：一次跨 Cache Line 的原子操作，能拖慢多少邻居

## 基本信息

- 英文题目：Investigating Split Locks on x86-64
- 作者：Chester Lam
- 首发：Chips and Cheese
- 日期：2026 年 4 月 8 日
- 阅读原文：https://chipsandcheese.com/p/investigating-split-locks-on-x86
- 后台作者栏：Chester Lam

## 摘要

七代 Intel/AMD 平台展现了完全不同的 Split Lock 实现：Arrow Lake 约 7 μs 但保护 L2，Zen 5 约 500 ns 却让所有 L1D Miss 受重罚，Piledriver 反而兼顾低延迟与良好隔离。现代“Bus Lock”并不是统一微结构。

## 封面与分享文案

- 封面：一个跨 Cache Line 的原子操作，能让邻核慢 10 倍
- 分享：Split Lock 本身更快，不等于系统影响更小。跨七代平台实测 Cache、带宽与真实负载，结果甚至出现老 Piledriver 全面领先的反直觉组合。

## 备选标题

- 从 Piledriver 到 Zen 5：Split Lock 的七代变迁
- “Bus Lock”早已没有同一种硬件含义

## 标签与栏目

- 标签：x86、Split Lock、原子操作、Cache Coherence、Linux
- 栏目：x86 机制

## 图片与排版

- 共 44 张图，图 39、40 或 1 可作封面。
- 平台章节可折叠，但图序不能调整。

## 发布前检查

- 极端 Lock Rate、降频与未降频平台差异均已说明。
- Infinity Fabric/IDI 只作为推测，没有写成实现事实。
- 44 张图按顺序可访问。
