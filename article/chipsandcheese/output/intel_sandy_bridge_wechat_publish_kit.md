# Intel Sandy Bridge 微信公众号发布资料

## 正式发布信息

- 正式标题：Sandy Bridge：Intel 现代高性能核心的地基
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2023 年 8 月 5 日
- 英文标题：Sandy Bridge: Setting Intel’s Modern Foundation
- 文章链接：https://chipsandcheese.com/p/sandy-bridge-setting-intels-modern-foundation
- 阅读原文链接：https://chipsandcheese.com/p/sandy-bridge-setting-intels-modern-foundation

### 摘要

从 22 张图理解 Sandy Bridge：四宽核心并不新鲜，真正奠定十多年 Intel Core 路线的是更强预测、1536 项 Op Cache、PRF 乱序后端、灵活 AGU 与分布式 L3 Ring。

### 封面文案

主标题：Sandy Bridge

副标题：Intel 现代核心的地基

### 分享文案

同样四宽、同样三个 ALU 和两个 AGU，Sandy Bridge 为什么远胜前代？答案在如何持续喂饱流水线：预测、Op Cache、PRF、转发、分布式 L3 和 Ring Bus。

### 备选标题

- 22 张图回看 Sandy Bridge
- Sandy Bridge 为什么影响了此后十多年的 CPU
- 四宽核心如何成为 Intel 的现代地基

### 文章标签

- Intel Sandy Bridge
- CPU Microarchitecture
- Micro-op Cache
- Branch Prediction
- Physical Register File
- Ring Bus
- Cache

### 所属栏目

经典处理器

## 图片资料

- 正文图片：22 张；目录：`intel_sandy_bridge_figures/`；顺序：`01` 至 `22`
- Forwarding Matrix、Frontend 曲线和 L3 延迟图保留原尺寸
- 图 6～8、10～11、15～16、22 含正式图注含义
- WeMD 副本使用腾讯云 COS HTTPS 图片

## 封面与排版

- 推荐封面 900 × 383 px，可用图 1 或图 19
- 正文 15～16 px、行距 1.7～1.8；图注 12～13 px
- BTB、Op Cache、PRF、PRRT、AGU、GQ 与 Ring Bus 术语统一
- “体系结构视角”小节显式保留

## 后台设置

- 标题：Sandy Bridge：Intel 现代高性能核心的地基
- 作者栏：Chester Lam
- 摘要：使用本文件摘要
- 阅读原文：https://chipsandcheese.com/p/sandy-bridge-setting-intels-modern-foundation
- 原创声明：关闭
- AI 内容标识：开启
- 图片顺序：01～22

## 来源与表述要求

- 1-bit Counter+共享 Confidence、BTB Offset 等来自 MPR，需保留来源口径。
- MPR 的 Nehalem 64-bit BTB Entry 被质疑，不应改成 64-bit Target。
- 4096 BTB 由文献/Matt Godbolt Ivy Bridge 测试支持；本次 Sandy Bridge 未直接跑满。
- 最多八 Branch 1-cycle 可能来自 L0 BTB，是候选解释。
- PRRT、RF 与 ROB 容量来自 Henry Wong 方法，不能写成 RTL 确认。
- Store Forwarding 与跨页惩罚数字完整保留。
- L3 对照为六核/12 MB E5-1650 与 X5650；不外推成所有 SKU。
- Ring Bus 评价基于带宽、延迟和核间测试，协议细节未公开。

## 发布预览要点

- 22 张图、图注和顺序连续；本地链接/MIME 正常。
- `1536-entry`、`4096 BTB`、`16 RAS`、`64/1024 DTLB`、`10.3 ns L3` 等数字正常。
- 历史资料、测试反推与体系结构教学边界清楚。
- COS URL 应全部 HTTP 200 且类型正确。
- 母稿与 WeMD 除 H1、YAML、图片 URL 外正文一致。
