# SPEC CPU2026：发布资料

## 正式标题

SPEC CPU2026：新一代 CPU 基准到底在测什么

## 基本信息

- 英文题目：Evaluating SPEC CPU2026
- 作者：Chester Lam
- 首发：Chips and Cheese
- 日期：2026 年 5 月 23 日
- 阅读原文：https://chipsandcheese.com/p/evaluating-spec-cpu2026
- 后台作者栏：Chester Lam

## 摘要

CPU2026 从 43 增至 52 个 Workload，Code Footprint 更丰富，却减少了 CPU2017 中 mcf/omnetpp 一类低 IPC、重 Branch/LLC 压力项目。Zen 5 与 Lion Cove 数据显示新套件更偏 Core/Vector Throughput，更适合作为 CPU2017 的补充而非完全替代。

## 封面与分享文案

- 封面：SPEC CPU2026 更新了什么，又丢了什么？
- 分享：更多源码、更大指令工作集，却更少低 IPC 与 LLC 压力。新 SPEC 为什么让现代大核更容易跑到 3 IPC？

## 备选标题

- 从 CPU2017 到 CPU2026：Benchmark 压力发生了什么变化
- SPEC CPU2026：高 IPC、Code Footprint 与参考系统之争

## 标签与栏目

- 标签：SPEC CPU2026、Benchmark、Zen 5、Lion Cove、性能计数器
- 栏目：基准方法

## 图片与排版

- 共 28 张图，图 1、11 或 25 可作封面。
- 大图保持原宽，MPKI/IPC/Score 不混用；正文 15～16 px。

## 发布前检查

- GCC 14.2.0、`-O3`、Native、Linux 与 5.5 GHz 条件完整。
- SDE 仅取最后 Invocation 和 PMU 口径差异保留。
- 28 张图按顺序可访问。
