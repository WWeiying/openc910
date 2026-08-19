# Intel Xeon 6 内存系统微信公众号发布资料

## 正式标题

Intel Xeon 6 的内存系统：跨 Die Mesh 能否继续维持“逻辑单体”

## 备选标题

- 480 MB L3 与三颗 Compute Die：Xeon 6 内存系统实测
- Xeon 6 对比 AMD Turin：两种 Chiplet 互连哲学
- 跨 Die 仍是一张 Mesh，Intel 付出了什么

## 作者与来源

- 作者栏：Chester Lam
- 首发：Chips and Cheese
- 英文题目：*A Look into Intel Xeon 6’s Memory Subsystem*
- 发布日期：2025 年 9 月 26 日
- 阅读原文：https://chipsandcheese.com/p/a-look-into-intel-xeon-6s-memory

## 摘要

AWS 的 96 核 Xeon 6 6985P-C 用 120 个 CHA、480 MB L3 和跨 Die Mesh 维持逻辑单体。实测显示巨大带宽，也暴露约 33 ns 本地 L3 与远端跳数代价。

## 分享卡片文案

Intel 与 AMD 都用 Chiplet，却选择了完全不同的共享层次。Xeon 6 的 L3 能跨更多核心，为什么单核从 L3 取数反而不及 Zen 5 从 DRAM？

## 封面

- 主标题：Intel Xeon 6
- 副标题：跨 Die Mesh 与 480 MB L3
- 小字：96 Redwood Cove / SNC3 / EMIB / 12-channel DDR5
- 比例：2.35:1，Intel 蓝，三颗 Compute Die 由一条 Mesh 串联

## 推荐标签与栏目

- 标签：Intel、Xeon 6、Redwood Cove、服务器 CPU、Mesh、EMIB、NUMA、Cache、内存带宽
- 栏目：处理器体系结构

## 图片与排版

- 正文图片：14 张，按 01～14 上传
- 图 9～12 是拓扑/矩阵重点，保留原比例
- 公式 `(2×57.63＋33.25)/3=49.5 ns` 不拆行

## 后台设置

- 作者栏：Chester Lam
- 阅读原文：https://chipsandcheese.com/p/a-look-into-intel-xeon-6s-memory
- 原创声明：关闭
- AI 内容标识：开启后台相应标识

## 发布前边界

- 6985P-C 是 AWS 未公开 SKU，测试时间受云实例成本限制。
- AWS 使用普通 DDR5-7200，不是 MCRDIMM；不要恢复网页旧版错误。
- 49.5 ns 是统一模式的算术推算，不是实测。
- 120 CHA、80 MDF 来自实例计数；具体 Mesh 位置仍未知。
