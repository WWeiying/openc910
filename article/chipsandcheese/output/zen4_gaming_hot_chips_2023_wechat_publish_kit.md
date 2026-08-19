# Zen 4 Gaming：发布资料

## 正式标题

Zen 4 跑游戏时，流水线时间都花在哪里

## 基本信息

- 英文题目：Hot Chips 2023: Characterizing Gaming Workloads on Zen 4
- 作者：Chester Lam
- 首发：Chips and Cheese
- 日期：2023 年 9 月 6 日
- 阅读原文：https://chipsandcheese.com/p/hot-chips-2023-characterizing-gaming-workloads-on-zen-4
- 后台作者栏：Chester Lam

## 摘要

7950X3D 的 Pipeline-slot PMU 显示，两款多人游戏主要受前端延迟、分支错误和串行 Load 限制：每四五条指令一个 Branch，L1I 17～20 MPKI，误预测浪费 13%～15% Slot，而 MAB 很少超过四项，说明问题是 Latency 而非 Bandwidth。

## 封面与分享文案

- 封面：六宽 Zen 4，为什么游戏 IPC 仍然很低？
- 分享：97% 以上预测准确率仍不够；96 MB V-Cache 也不能消除 Instruction Footprint。用 Pipeline Slot、BTB、TLB、ROB、MAB 一起看，才能知道游戏在等什么。

## 备选标题

- 从前端到 MAB：Zen 4 游戏瓶颈全景
- 游戏为什么吃分支预测，而不是更多执行端口

## 标签与栏目

- 标签：AMD、Zen 4、游戏、性能计数器、分支预测
- 栏目：工作负载分析

## 图片与排版

- 共 24 张图，图 4、13 或 24 适合作封面。
- PMU 百分比保留测试波动说明；正文 15～16 px。

## 发布前检查

- 两款游戏、Affinity、4.2 GHz 与多 Pass 收集条件完整。
- Core/L3 Controller 视角和 Event 统计口径不混用。
- 24 张图按顺序可访问。
