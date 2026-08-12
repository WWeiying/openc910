# AMD Ryzen 9 9950X / Zen 5 微信公众号发布资料

## 正式发布信息

- 正式标题：Ryzen 9 9950X：Zen 5 来到桌面端之后，究竟强在哪里
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2024 年 8 月 14 日
- 英文标题：AMD’s Ryzen 9950X: Zen 5 on Desktop
- 文章链接：https://chipsandcheese.com/p/amds-ryzen-9950x-zen-5-on-desktop
- 阅读原文链接：https://chipsandcheese.com/p/amds-ryzen-9950x-zen-5-on-desktop

### 摘要

从 42 张图理解桌面 Zen 5：完整 512-bit AVX-512、48 KB L1D、巨大 BTB 和更大乱序资源带来提升，但跨 CCD 延迟、整数寄存器容量与前后端延迟仍限制更宽流水线。

### 封面文案

主标题：Ryzen 9 9950X

副标题：Zen 5 来到桌面端之后

### 分享文案

Zen 5 不只是“更宽”：桌面版重做 512-bit 向量资源、扩大 L1D/BTB/LSQ，并用 NSQ 后 Vector Rename 缓解寄存器压力；但近 200 ns 跨 CCD 延迟和前端 Bubble 说明宽度仍要向延迟讨债。

### 备选标题

- 42 张图看懂桌面 Zen 5
- Ryzen 9 9950X：更宽的核心，为什么仍受延迟限制
- 桌面 Zen 5：完整 AVX-512 与两组四宽译码器

### 文章标签

- AMD Zen 5
- Ryzen 9 9950X
- Granite Ridge
- AVX-512
- Branch Prediction
- Cache
- Chiplet

### 所属栏目

桌面处理器

## 图片资料

- 正文图片：42 张；目录：`amd_ryzen_9950x_zen5_figures/`；顺序：`01` 至 `42`
- 核间延迟矩阵、Slot Breakdown 和 Cache Bandwidth 图建议保留原尺寸
- 图 14、29、42 保留网页正式英文图注的含义，其余图注是中文辅助读图
- WeMD 副本使用腾讯云 COS HTTPS 图片

## 封面与排版

- 推荐封面 900 × 383 px，可用图 1 或图 40
- 正文 15～16 px、行距 1.7～1.8；图注 12～13 px
- CCD、I/O Die、Infinity Fabric、NSQ、ROB、BTB、Op Cache 等术语保持一致
- 所有“体系结构视角”小节显式保留

## 后台设置

- 标题：Ryzen 9 9950X：Zen 5 来到桌面端之后，究竟强在哪里
- 作者栏：Chester Lam
- 摘要：使用本文件摘要
- 阅读原文：https://chipsandcheese.com/p/amds-ryzen-9950x-zen-5-on-desktop
- 原创声明：关闭
- AI 内容标识：开启
- 图片顺序：01～42

## 来源与表述要求

- 样片由 AMD 提供；X670E Aorus Master、DDR5-6000、XMP/EXPO 开启。
- Zen 4 对照为 DDR5-5600，平台由不同地点持有，绝对差异不作纯核心结论。
- CCD Link 为读 32、写 16 B/cycle，2 GHz，对应每 CCD 64/32 GB/s。
- 跨 CCD 近 200 ns 是整个平台端到端结果，内部原因未确认。
- 两组四宽 Decoder 不能在单线程合并是行为观察；简化 SMT 切换等是解释假说。
- 2×512-bit Load、NSQ 后 Vector Rename、104-entry Store Queue 等不要与移动 Zen 5 混写。
- libx264 与 tinyconfig 均为单 CCD、每核一个 SMT Thread、Stock Boost；软件细节披露不完整。
- Top-down 百分比需与 Absolute Slot 一起读；ROB Full 不应直接写成设计失败。
- Branch Predictor 略准但 Bad-speculation Slot 更多，解释为更深投机时保留“可能”。

## 发布预览要点

- 42 张图、图号与图注连续；本地链接存在，MIME 与扩展名一致。
- `5.72/5.49 GHz`、`70 ns`、`1.4 TB/s`、`10 TB/s`、`27.6%`、`22.2%`、`16K BTB` 等关键数字正常。
- 厂商资料、微基准、反推与教学机制保持分层。
- COS URL 应全部返回 HTTP 200，`Content-Type` 与图片格式一致。
- 母稿与 WeMD 除 H1、YAML 和图片 URL 外正文一致。
