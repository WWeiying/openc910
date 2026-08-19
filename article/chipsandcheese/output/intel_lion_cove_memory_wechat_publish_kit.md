# Lion Cove 内存系统｜微信公众号发布资料

## 正式标题

Arrow Lake 上的 Lion Cove：L1.5 很聪明，内存系统却拖了后腿

## 备选标题

- 192 KB L1.5 能救 Lion Cove 吗
- 同一颗 Lion Cove，Arrow Lake 为什么快了 24%
- 8-wide、5.7 GHz 与慢内存：Lion Cove 的矛盾

## 作者与来源

- 作者栏：Chester Lam
- 首发：Chips and Cheese
- 英文题目：*Analyzing Lion Cove’s Memory Subsystem in Arrow Lake*
- 发布日期：2025 年 1 月 6 日
- 阅读原文：https://chipsandcheese.com/p/analyzing-lion-coves-memory-subsystem

## 摘要

Arrow Lake 用 5.7 GHz、3 MB L2、36 MB L3 释放 Lion Cove，但高 L3/DRAM 延迟仍限制性能。21 张图分析 192 KB L1.5、FP Port 与实际负载。

## 分享卡片文案

Lion Cove 的 192 KB L1.5 可以接住大量 L1 Miss，却也在补偿更慢的 L2。拆解一颗先进核心为何只能与 Zen 5 大致互有胜负。

## 封面与标签

- 主标题：LION COVE MEMORY
- 副标题：聪明的 L1.5，昂贵的长延迟
- 标签：Intel、Lion Cove、Arrow Lake、L1.5、Cache、SPEC CPU2017
- 栏目：处理器体系结构

## 图片与排版

- 正文 21 张图，按 01～21 上传。

## 后台设置

- 作者栏：Chester Lam
- 阅读原文：https://chipsandcheese.com/p/analyzing-lion-coves-memory-subsystem
- 原创声明：关闭；AI 内容标识按平台要求开启。

## 发布前边界

- Intel 与 AMD PMU 的 Cache 数据来源定义不同，比例不能直接横比。
- Zen 5 DDR5-5600 与 Arrow Lake DDR5-8000 并非对称平台。
- L1.5 是本文便于理解的称呼，Intel 文档命名不同。
- Chiplet 导致延迟是结合系统现象的分析，不是单一链路延迟拆分。
