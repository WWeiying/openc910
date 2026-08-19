# CPU-Z 的内置跑分，为什么代表不了现代应用：发布资料

## 正式标题

CPU-Z 的内置跑分，为什么代表不了现代应用

## 基本信息

- 英文题目：CPU-Z’s Inadequate Benchmark
- 作者：Chester Lam
- 首发：Chips and Cheese
- 日期：2023 年 11 月 3 日
- 阅读原文：https://chipsandcheese.com/p/cpu-zs-inadequate-benchmark
- 后台作者栏：Chester Lam

## 摘要

CPU-Z 的工作集几乎完全留在 L1D 与 Micro-op Cache，分支也少而易测。它真正奖励的是标量 FP 延迟、长依赖链下的 Scheduler、ROB 和物理寄存器容量，很难代表游戏、编译与生产力软件。

## 封面与分享文案

- 封面：CPU-Z 跑分到底在测什么？
- 分享：16 KB L1D 也有 99.9%命中，现代 Op Cache 覆盖超过 90%，BTB 更毫无压力。拆开流水线后，CPU-Z 的高分为何不等于真实应用更快便很清楚。

## 备选标题

- CPU-Z 跑分的微架构真相：它主要测 FP 依赖链
- 为什么 Zen 4 在 CPU-Z 里只比 Zen 3 快一点

## 标签与栏目

- 标签：CPU-Z、Benchmark、浮点执行、乱序执行、性能计数器
- 栏目：基准方法

## 图片与排版

- 共 23 张图，图 5、17 或 22 可作封面。
- 图 6 的 Intel/AMD Top-down 口径差异必须随图保留。

## 发布前检查

- 单线程为主，多线程只是复制小工作集。
- Kaby Lake 多项后端事件未公开，文中已标不确定性。
- 23 张图按顺序可访问。
