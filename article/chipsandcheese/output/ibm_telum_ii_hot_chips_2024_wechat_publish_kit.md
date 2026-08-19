# IBM Telum II Hot Chips 2024 WeChat Publish Kit

## 正式标题

IBM Telum II：用 360 MB L2 构造虚拟 L3 与 L4

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：Telum II at Hot Chips 2024: Mainframe with a Unique Caching Strategy
- 日期：2024-09-08
- 阅读原文：https://chipsandcheese.com/p/telum-ii-at-hot-chips-2024-mainframe-with-a-unique-caching-strategy
- 栏目：IBM 大型机 / 缓存体系

## 摘要

Telum II 把十块 36 MB L2 动态重用为 virtual L3，并把跨芯片闲置容量组成 2.8 GB virtual L4。Saturation Metric、victim 迁移和中间 LRU 插入位置，让一块 SRAM 在私有低延迟与共享大容量之间切换。

## 封面文案

没有物理 L3，IBM 怎样做出 2.8 GB L4？

## 分享文案

8 核、5.5 GHz、360 MB 片上缓存：Telum II 用大型机独有的高速互连，把其他核心乃至其他芯片的 L2 变成单线程可用容量。

## 备选标题

- Telum II 缓存体系：十块 L2 如何变成共享 L3
- 从 3.6 ns L2 到 2.8 GB L4：IBM 的虚拟缓存策略

## 标签

IBM、Telum II、大型机、Virtual L3、Virtual L4、缓存、Hot Chips

## 图片说明

- 共 12 张图，按页面顺序保留。
- 图 4—5 解释 Telum II virtual L3，图 6—10 用 Z16/z15 说明 drawer 级组织，图 12 展示互连能力。

## 发布前检查

- [ ] 12 张图全部显示且顺序正确
- [ ] 十块 L2 的归属、360 MB 总容量和 3.6 ns 延迟准确
- [ ] virtual L4 的 drawer 范围明确为依据前代的推断
- [ ] 48.5 ns 是 IBM 宣称值，不是本地实测
- [ ] 客户端 virtual cache 方案明确为设想
