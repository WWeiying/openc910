# Ryzen Z1：发布资料

## 正式标题

Ryzen Z1：AMD 的温和混合核心策略

## 基本信息

- 英文题目：AMD’s Mild Hybrid Strategy: Ryzen Z1 in ASUS’s ROG Ally
- 作者：Chester Lam
- 首发：Chips and Cheese
- 日期：2024 年 2 月 12 日
- 阅读原文：https://chipsandcheese.com/p/amds-mild-hybrid-strategy-ryzen-z1-in-asuss-rog-ally
- 后台作者栏：Chester Lam
- 样机说明：ASUS 提供 ROG Ally Review Sample

## 摘要

Ryzen Z1 用两个 5 GHz Zen 4 与四个 3.55 GHz Zen 4c 组成同一 L3 Cluster。两类核 ISA 和 Cycle Latency 相同，实际 ns、频率、带宽却不同；按能力分配线程后，六核 L1 可达 1.329 TB/s，FP32 超 1 TFLOP/s。

## 封面与分享文案

- 封面：Zen 4 加 Zen 4c，AMD 为什么这样做 Hybrid？
- 分享：不同核心架构会带来软件和 ISA 麻烦，AMD 选择只改 Physical Design。Z1 的实测展示了这种温和 Hybrid 的收益，也暴露同 Cluster 异频和长尾调度问题。

## 备选标题

- Ryzen Z1：同一种 Zen 4，两种物理实现
- ROG Ally 里的 Zen 4/Zen 4c 如何共享 L3

## 标签与栏目

- 标签：AMD、Ryzen Z1、Zen 4c、ROG Ally、混合架构
- 栏目：处理器实测

## 图片与排版

- 共 16 张图，图 2 或图 16 适合作封面。
- 频率推断与厂商规格分开；正文 15～16 px。

## 发布前检查

- 样机来源放在文首。
- 线程工作量配比、热降频和 LPDDR5 条件完整。
- 16 张图按顺序可访问。
