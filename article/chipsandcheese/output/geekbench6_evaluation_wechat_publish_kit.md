# Geekbench 6：发布资料

## 正式标题

Geekbench 6：一套偏向向量吞吐的消费级基准

## 基本信息

- 英文题目：Evaluating Geekbench 6
- 作者：Chester Lam
- 首发：Chips and Cheese
- 日期：2026 年 5 月 7 日
- 阅读原文：https://chipsandcheese.com/p/evaluating-geekbench-6
- 后台作者栏：Chester Lam

## 摘要

SDE 与 PMU 显示，Geekbench 6 大量使用 AVX2/AVX-512，少量 AMX 还能显著减少动态指令；多数项目 Code Footprint 小、Branch 易预测、Prefetch 友好，因而集中在中高 IPC。Navigation 与 Clang 是少数控制流和代码容量例外。

## 封面与分享文案

- 封面：Geekbench 6 的总分，究竟奖励什么？
- 分享：0.2% AMX 指令也能大幅改变工作量；0.23 L3 MPKI 也可能对应最高 DRAM 流量。拆开 Instruction Mix、IPC、BPU 和 Cache 后，Geekbench 的偏好很清楚。

## 备选标题

- Geekbench 6 深度画像：Vector、Loop 与 Prefetch
- 为什么 Geekbench 6 不能替代 SPEC CPU2017

## 标签与栏目

- 标签：Geekbench 6、Benchmark、AVX-512、AMX、性能计数器
- 栏目：基准方法

## 图片与排版

- 共 21 张图，图 2、10 或 21 可作封面。
- Instruction Share 与性能贡献不得等同；正文 15～16 px。

## 发布前检查

- Granite Rapids/Ice Lake-X/Haswell/Ivy/Prescott 均是 SDE ISA Target。
- Intel/AMD PMU Event 口径区别保留。
- 21 张图按顺序可访问。
