# Cortex-A73 Reordering Capacity：发布资料

## 正式标题

Cortex-A73 的“非无限”重排能力

## 基本信息

- 英文题目：Cortex A73’s Not-So-Infinite Reordering Capacity
- 作者：Chester Lam
- 首发：Chips and Cheese
- 日期：2024 年 8 月 4 日
- 阅读原文：https://chipsandcheese.com/p/cortex-a73s-not-so-infinite-reordering-capacity
- 后台作者栏：Chester Lam

## 摘要

A73 似乎能越过已经确认不会异常、但数据尚未返回的 Load 退休后续指令，以更快回收小型 PRF 和队列。用未决 Branch 阻塞后，测试测得约 41/38 项整数与 FP/Vector 结果、50 个 Load、11 项 Store/Branch 共享瓶颈，却仍找不到传统 ROB 上限。

## 封面与分享文案

- 封面：没有明显 ROB 上限，A73 怎么退休？
- 分享：为什么 Cache Miss 挡不住 A73 释放资源，而一条永不跳转的 Branch 可以？这颗小核心用一种少见策略，把面积预算换成资源周转率。

## 备选标题

- Cortex-A73：用乱序退休放大小型后端
- 11 项 Store/Branch、50 个 Load：A73 的真实重排边界

## 标签与栏目

- 标签：Arm、Cortex-A73、乱序执行、退休、微基准
- 栏目：处理器架构

## 图片与排版

- 共 10 张图，建议图 2 或图 4 作封面。
- 结构容量均使用“测得/约/可能”，正文 15～16 px。

## 发布前检查

- 不把乱序退休候选机制写成 RTL 确认。
- 保留 Branch 测试方法、50 Load、11 Store/Branch 和 76 指令边界。
- 10 张图均可访问。
