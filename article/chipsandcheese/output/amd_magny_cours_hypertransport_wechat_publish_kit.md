# AMD Magny-Cours 微信公众号发布资料

## 正式发布信息

- 正式标题：AMD Magny-Cours 与 HyperTransport：2010 年如何把 12 核塞进一个封装
- 署名：Chester Lam
- 来源：Chips and Cheese
- 日期：2025 年 7 月 11 日
- 英文标题：AMD’s Magny Cours and HyperTransport Interconnect: A High Core Count Blast from the Past
- 原始链接：https://chipsandcheese.com/p/amds-magny-cours-and-hypertransport

### 摘要

两颗六核 Die、四 Node NUMA、宽边窄对角的 HT Mesh，再加 L3 Probe Filter：复盘 AMD 在 2010 年扩核心数的成本、带宽与软件代价。

### 封面与分享文案

- 主标题：12 核是怎样拼出来的
- 副标题：Magny-Cours 与 HyperTransport
- 分享文案：为什么同 Die 核心传数据也可能绕到另一个 Die？14 张图看懂 Home Node、HT Assist、四 Node NUMA 和 Loaded Latency。
- 备选标题：AMD Chiplet 路线的早期影子；2010 年的双 Die Opteron

### 标签与栏目

- 标签：AMD、Opteron、Magny-Cours、HyperTransport、NUMA、Cache Coherence
- 栏目：处理器历史与互连

## 图片与移动端排版

- 图片 14 张，目录 `amd_magny_cours_hypertransport_figures/`，按 01～14 上传。
- 封面用四 Node 方形 Mesh；延迟矩阵和拓扑图全宽。

## 后台设置与发布前检查

- 8-bit 封装内 Sublink 未启用；理论 19.2 GB/s 不等于实测。
- 延迟由 Source/Destination/Home 三者决定；不能简化为同/跨 Socket。
- MCT 接口宽度和 Queue 不足是候选解释，不是确认根因。
- SPEC 单线程不代表 12 核服务器目标；与现代系统只比机制趋势。
- 核对 6.4 GT/s、12.8/19.2 GB/s、120～130/180/300 ns、4.4～5/17/19.3/48 GB/s、32/56 项与 14 张图。
- 后台作者栏填 Chester Lam，“阅读原文”使用完整链接；原创声明关闭，AI 内容标识按平台要求开启。
