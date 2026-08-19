# Cinebench 2024：这个热门渲染跑分到底在测什么：发布资料

## 正式标题

Cinebench 2024：这个热门渲染跑分到底在测什么

## 基本信息

- 英文题目：Cinebench 2024: Reviewing the Benchmark
- 作者：Chester Lam
- 首发：Chips and Cheese
- 日期：2023 年 10 月 23 日
- 阅读原文：https://chipsandcheese.com/p/cinebench-2024-reviewing-the-benchmark
- 后台作者栏：Chester Lam

## 摘要

Cinebench 2024 大量使用 AVX 编码，却以标量和 128 bit 运算为主。代码溢出 L1I、数据穿过 L3，全核运行带来约 20 GB/s 级流量；它同时考验前端、乱序调度和多核内存系统，却不能代表游戏或宽向量计算。

## 封面与分享文案

- 封面：Cinebench 2024 到底在测 CPU 的哪一部分？
- 分享：分支 MPKI 低于 2，Zen 4 的 Decoder 仍承担约五分之一 Micro-op，16 核平台 L3 Miss 流量约 20 GB/s。一个 Cinebench 分数背后，其实是前端、调度窗口和内存系统的共同结果。

## 备选标题

- 从指令到 DRAM，拆解 Cinebench 2024
- Cinebench 2024 为什么比 R23 更考验内存

## 标签与栏目

- 标签：Cinebench 2024、Benchmark、乱序执行、Cache、DRAM
- 栏目：基准方法

## 图片与排版

- 共 27 张图，图 6、12、24 可作封面。
- 图 23、25 必须保留计数器口径和测量位置说明。

## 发布前检查

- 7950X3D、3950X、7700K 的每线程 IPC 与 SMT 条件已写明。
- Zen 2 Top-down 为估算，Kaby Lake 部分事件未公开。
- 27 张图按顺序可访问。
