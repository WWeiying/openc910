# Intel Sapphire Rapids 微信公众号发布资料

## 正式发布信息

- 正式标题：Sapphire Rapids：Golden Cove 进入服务器之后
- 署名：Chester Lam；来源：Chips and Cheese；发布日期：2023 年 3 月 12 日
- 英文标题：Sapphire Rapids: Golden Cove Hits Servers
- 原文/阅读原文：https://chipsandcheese.com/p/a-peek-at-sapphire-rapids

### 摘要

从 22 张图理解 Sapphire Rapids：2×512-bit FMA、AMX 与 2 MB L2 很强，四 Tile 统一 56-slice L3 却付出 33 ns 延迟和有限带宽；它既是服务器产品，也是跨 Die Mesh 的工程试验场。

### 封面/分享

- 主标题：Sapphire Rapids；副标题：Golden Cove 进入服务器
- 分享文案：当 56 核、56 片 L3、Memory Controller、Accelerator 与 I/O 跨四 Tile 连成一个统一系统，容量与灵活性很强，Latency 与 Bandwidth 也开始收取代价。

### 备选标题

- 22 张图看懂 Sapphire Rapids
- Sapphire Rapids：强向量与慢 L3 的交换
- Intel 如何用 EMIB 拼出统一 56 核 Xeon

### 标签/栏目

- Intel Sapphire Rapids、Xeon、Golden Cove、AVX-512、AMX、Mesh、EMIB、Server CPU
- 栏目：服务器处理器

## 图片、排版与后台

- 22 图，目录 `intel_sapphire_rapids_figures/`，01～22；封面建议 6/22；COS HTTPS。
- 正文 15～16 px，图注 12～13 px；显式保留“体系结构视角”。
- 后台标题同正式标题；作者 Chester Lam；原创关闭；AI 标识开启；阅读原文同上。

## 关键边界与发布检查

- DevCloud Boost 异常、GCP 3 GHz Lock、Cloud DRAM 未知必须保留。
- Mask/Vector RF 为测试反推；AVX-512 无固定 Offset 不等于任何负载不降频。
- 32 Core 后 L3/DRAM 为 Projection，不写成实测全核。
- GCP Cluster 125→88 cycle 不能全归因于 Cluster Mode。
- Minecraft Arm 4 vCPU、其他 8 vCPU；Clock/MPKI 口径差异保留。
- 22 图、MIME、Pandoc、禁词、COS 200、母稿/WeMD 一致后发布。
