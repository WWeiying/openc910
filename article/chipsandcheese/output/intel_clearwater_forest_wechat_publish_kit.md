# Intel Clearwater Forest 微信公众号发布资料

## 正式发布信息

- 正式标题：Clearwater Forest：288 个 E-Core 如何拼成一颗服务器 CPU
- 署名：Chester Lam；来源：Chips and Cheese；发布日期：2025 年 8 月 25 日
- 英文标题：Intel’s Clearwater Forest E-Core Server Chip at Hot Chips 2025
- 原文/阅读原文：https://chipsandcheese.com/p/intels-clearwater-forest-e-core-server

### 摘要

9 张 Hot Chips 图看 Clearwater Forest：288 个 Skymont、18A Compute Die、Intel 3 Base/L3 Mesh、576 MB LLC、1.3 TB/s DRAM 与 3D Stack，展示 Intel 的 Density Server 路线。

### 封面/分享

- 主标题：Clearwater Forest；副标题：288 个 E-Core 如何拼起来
- 分享文案：18A 做核心、Intel 3 做 Mesh/L3、Intel 7 复用 I/O，再把 288 个 Skymont 堆成一颗服务器 CPU；真正的胜负手可能是 4 MB L2 能否挡住慢 Mesh。

### 备选标题

- 9 张图看 Clearwater Forest
- 288 核 Xeon：Intel 的 3D E-Core 服务器
- 从 Atom 到 288 核：E-Core 的服务器跃迁

### 标签/栏目

- Intel Clearwater Forest、Skymont、E-Core、Intel 18A、3D Stacking、Server CPU、CXL
- 栏目：服务器处理器

## 图片、排版与后台

- 9 图，目录 `intel_clearwater_forest_figures/`，01～09；封面建议 1/4/5；COS HTTPS。
- 正文 15～16 px，图注 12～13 px；显式保留“体系结构视角”。
- 后台标题同正式标题；作者 Chester Lam；原创关闭；AI 标识开启；阅读原文同上。

## 关键边界与发布检查

- 基于 Hot Chips 资料，尚无独立 Silicon Test。
- Compute Die 24 Core 与 9 μm Pitch 保留“似乎/若听取无误”。
- Address Range→Nearest Controller 是读图推断。
- 35 GB/s 可能为 Latency-limited 测量，不写成接口位宽。
- 20:70 为 Intel SPEC CPU2017 Integer Rate 主张，测试配置未全给。
- 9 图、MIME、Pandoc、禁词、COS 200、母稿/WeMD 一致后发布。
