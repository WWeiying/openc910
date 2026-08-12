# AMD Strix Point / Zen 5 微信公众号发布资料

## 正式发布信息

- 正式标题：Strix Point：Zen 5 首次从移动端登场
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2024 年 8 月 10 日
- 英文标题：AMD’s Strix Point: Zen 5 Hits Mobile
- 文章链接：https://chipsandcheese.com/p/amds-strix-point-zen-5-hits-mobile
- 阅读原文链接：https://chipsandcheese.com/p/amds-strix-point-zen-5-hits-mobile

### 摘要

从 40 张图理解 Strix Point：Zen 5 以 16K L1 BTB、Clustered Frontend、八宽 Rename、统一 Integer Scheduler、四 AGU 和 48 KB L1D 重做流水线，同时用 Zen 5c 与 SMT 走出不同于 Intel 的移动 Hybrid 路线。

### 封面文案

主标题：Strix Point

副标题：Zen 5 首次从移动端登场

### 分享文案

同一 Architecture 如何做 Hybrid？Strix Point 用 4 个 Zen 5、8 个 Zen 5c、两组 Decode Cluster 和强 SMT 回答；代价与收益则藏在 BTB、Scheduler、Vector RF、Cache 和跨 Cluster 延迟里。

### 备选标题

- 40 张图看懂移动 Zen 5
- Strix Point：AMD 为什么把 Zen 5 做成“温和混合”
- Zen 5 移动核心：巨型 BTB、统一调度与 SMT 前端

### 文章标签

- AMD Zen 5
- Strix Point
- Ryzen AI 9 HX 370
- Zen 5c
- SMT
- Branch Prediction
- AVX-512

### 所属栏目

移动处理器

## 图片资料

- 正文图片：40 张；目录：`amd_strix_point_zen5_figures/`；顺序：`01` 至 `40`
- 核间矩阵、Forwarding Matrix、Backend/Cache Diagram 保留原尺寸
- 图 2、4、21、26、27、35 含网页正式图注含义
- WeMD 副本使用腾讯云 COS HTTPS 图片

## 封面与排版

- 推荐封面 900 × 383 px，可用图 1、3 或 40
- 正文 15～16 px、行距 1.7～1.8；图注 12～13 px
- Zen 5/Zen 5c、BTB、Op Cache、NSQ、RF、AGU 与 TLB 术语统一
- “体系结构视角”小节显式保留

## 后台设置

- 标题：Strix Point：Zen 5 首次从移动端登场
- 作者栏：Chester Lam
- 摘要：使用本文件摘要
- 阅读原文：https://chipsandcheese.com/p/amds-strix-point-zen-5-hits-mobile
- 原创声明：关闭
- AI 内容标识：开启
- 图片顺序：01～40

## 来源与表述要求

- ASUS 提供 Laptop；软件、Firmware 与误差细节披露不完整。
- Zen 5c 是同 Architecture 的 Density Implementation，不写成不同 ISA 小核。
- Clock 由 Dependent Add 估算；跨 Cluster Latency 属于 APU System Result。
- 24K+ BTB Coverage、52-entry RAS、234 ZMM Write 等为测试/资料反推，不写成 RTL 确认。
- AMD Slide 的 64 B/cycle L1I 与实测 32 B/cycle 差异必须保留。
- 移动 Zen 5 为 256/512-bit 混合 Vector RF、256-bit FP Unit；不要套用桌面 Zen 5。
- Misaligned Store 双 Write Port 只是候选解释。
- Benchmark 四核 Affinity、7950X3D 非 V-Cache/5.15 GHz Cap 等条件保留。
- Branch Accuracy 差异在误差范围，只适用于该 Workload。

## 发布预览要点

- 40 张图和图注连续；本地链接、真实 MIME 和扩展名一致。
- `4+8 cores`、`16/8 MB L3`、`5.15/3.3 GHz`、`16K BTB`、`88/58 entries`、`128 ns` 等数字正常。
- 公开资料、微基准、反推与教学机制没有混写。
- COS URL 全部应为 HTTP 200，`Content-Type` 正确。
- 母稿与 WeMD 除 H1、YAML、图片 URL 外正文一致。
