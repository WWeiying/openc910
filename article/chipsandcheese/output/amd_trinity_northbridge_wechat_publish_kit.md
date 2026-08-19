# AMD Trinity Northbridge 微信公众号发布资料

## 正式发布信息

- 正式标题：Infinity Fabric 之前：AMD Trinity 的 Northbridge、“Garlic”与“Onion”
- 署名：Chester Lam
- 来源：Chips and Cheese
- 日期：2025 年 6 月 14 日
- 英文标题：AMD’s Pre-Zen Interconnect: Testing Trinity’s Northbridge
- 原始链接：https://chipsandcheese.com/p/amds-pre-zen-interconnect-testing

### 摘要

Trinity 用 Garlic 高带宽非一致路径和 Onion 低带宽一致路径，把 GPU 接进为 CPU 设计的 SRI+XBAR Northbridge，展示统一互连出现前的工程折中。

### 封面与分享文案

- 主标题：Infinity Fabric 之前
- 副标题：Garlic、Onion 与 Trinity APU
- 分享文案：同一 DDR3 背后，为何 GPU 走 24 GB/s，CPU/GPU Zero-copy 却掉到 10 GB/s以下甚至只有一个 Pending Read？
- 备选标题：AMD APU 早期互连的两条路；Trinity 如何把 GPU 接进 Northbridge

### 标签与栏目

- 标签：AMD、Trinity、APU、Northbridge、Cache Coherence、OpenCL
- 栏目：多核与互连

## 图片与移动端排版

- 图片 19 张，目录 `amd_trinity_northbridge_figures/`，按 01～19 上传。
- 封面突出 Garlic/Onion 双路径；拓扑和流量图用 100% 宽度。

## 后台设置与发布前检查

- 平台为 A8-5600K、DDR3-1866 10-10-9-26；不是完整 Trinity SKU。
- Garlic Queue 16 项、Buffer 越界改走 Onion 均为证据支持的推断。
- Onion Probe 数量、驱动页大小与映射内部实现未知。
- Ryzen 8840HS 仅作现代路径对照，绝对延迟受平台影响。
- 核对 1.8 GHz、40=22+10+8、24/10 GB/s、45M Probe/s、320/93.11 ns 与 19 张图。
- 后台作者栏填 Chester Lam，“阅读原文”使用完整链接；原创声明关闭，AI 内容标识按平台要求开启。
