# 大型系统核间延迟微信公众号发布资料

## 正式发布信息

- 正式标题：大型系统核间延迟图谱：从 Pentium 双路到 Sapphire Rapids 与 Genoa-X
- 署名：Chester Lam
- 来源：Chips and Cheese
- 日期：2023 年 11 月 7 日
- 英文标题：Core to Core Latency Data on Large Systems
- 原始链接：https://chipsandcheese.com/p/core-to-core-latency-data-on-large-systems

### 摘要

32张Atomic Cacheline Ping-pong矩阵覆盖Intel、AMD、Arm、IBM、Sun、Cavium和Ampere大型系统，展示Home Slice、Cluster、Mesh、NUMA与Cloud Placement。

### 封面与分享文案

- 主标题：大型 CPU 的核间延迟地图
- 副标题：从 46 ns 到微秒，拓扑藏在矩阵里
- 分享文案：Sapphire Rapids、Genoa-X、Graviton、Skylake四路、POWER与Pentium双路同场，如何读出Ring、Mesh、CCX和Home Agent？
- 备选标题：18种大型系统的Cacheline往返；核心越多，为何延迟矩阵越复杂

### 标签与栏目

- 标签：Core-to-core Latency、Cache Coherence、NUMA、Mesh、Ring、Server CPU
- 栏目：多核与互连

## 图片与移动端排版

- 图片32张，目录 `large_system_core_latency_figures/`，按01～32上传。
- 所有矩阵用100%宽度并允许点开；不同图Color Scale不同，不拼图比较颜色。

## 后台设置与发布前检查

- Compare-and-exchange测Contended Ownership Transfer，通常不代表应用主流流量。
- Windows式SMT编号；Linux编号不同。Address/Home Slice变化会改变矩阵。
- POWER Cloud底层Placement未知；数据不可当裸芯片规格。
- 核对SPR 59/81/138 ns、Graviton3 48/<59、G2 50.7、Skylake47/150、ThunderX64/315、Pentium507.9 ns/61周期及32图。
- 后台作者 Chester Lam；阅读原文完整链接；原创关闭，AI标识按要求开启。
