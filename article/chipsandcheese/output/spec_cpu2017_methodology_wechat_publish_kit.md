# 在 Chips and Cheese 跑 SPEC CPU2017：方法、代价与第一批观察：发布资料

## 正式标题

在 Chips and Cheese 跑 SPEC CPU2017：方法、代价与第一批观察

## 基本信息

- 英文题目：Running SPEC CPU2017 at Chips and Cheese?
- 作者：Chester Lam
- 首发：Chips and Cheese
- 日期：2024 年 9 月 20 日
- 阅读原文：https://chipsandcheese.com/p/running-spec-cpu2017-at-chips-and-cheese
- 后台作者栏：Chester Lam

## 摘要

用 GCC 14.2.0、单份 Rate 与统一 Flag 运行 SPEC CPU2017，既揭示了 mcf 的分支噩梦、fotonik3d 的带宽墙和 V-Cache 的适用边界，也说明源码基准为何必须严谨记录 Compiler、内存、频率与计数器口径。

## 封面与分享文案

- 封面：SPEC CPU2017 为什么这么难跑明白？
- 分享：mcf 有 22.5%分支，fotonik3d 单核读写近 28 GB/s，96 MB V-Cache 在 omnetpp 提升 52% IPC。总分之下，每个子项考的其实完全不同。

## 备选标题

- 从 mcf 到 fotonik3d：SPEC CPU2017 的微架构画像
- SPEC CPU2017 初测：编译器、缓存与内存如何改变结论

## 标签与栏目

- 标签：SPEC CPU2017、Benchmark、GCC、分支预测、V-Cache
- 栏目：基准方法

## 图片与排版

- 共 25 张图，图 7、18 或 25 可作封面。
- 文首保留“初始方法、Estimated、尚未定型”的边界。

## 发布前检查

- GCC 版本、完整 Flag、单份 Rate 与 Bare-metal/Cloud 条件已写明。
- Intel/AMD PMU 口径不可横比，推断均已标明。
- 25 张图按顺序可访问。
