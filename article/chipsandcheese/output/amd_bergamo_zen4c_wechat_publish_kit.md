# AMD Bergamo/Zen 4c 微信公众号发布资料

## 正式发布信息

- 正式标题：Bergamo：AMD 如何用 Zen 4c 把服务器堆到 128 核
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2024 年 6 月 22 日
- 英文标题：Testing AMD’s Bergamo: Zen 4c Spam
- 文章链接：https://chipsandcheese.com/p/testing-amds-bergamo-zen-4c-spam
- 阅读原文链接：https://chipsandcheese.com/p/testing-amds-bergamo-zen-4c-spam

### 摘要

从 18 张图理解 Bergamo：Zen 4c 不改核心架构，以低频物理实现、16 MB L3 与双 CCX/CCD 换 128 核密度，并把带宽、NUMA 和一致性变成主要问题。

### 封面文案

主标题：AMD Bergamo

副标题：Zen 4c 如何堆到 128 核

### 分享文案

Zen 4c 单核更慢，整颗 Compute Die 却能领先 34.7%～69.4%；Density Server 的正确分母不是 IPC，而是每 Die、每瓦和每台机器的吞吐。

### 备选标题

- 18 张图看懂 AMD Bergamo
- Zen 4c 架构没变，为什么能塞两倍核心
- Bergamo：128 核服务器的密度账

### 文章标签

- AMD Bergamo
- Zen 4c
- Server CPU
- Chiplet
- NUMA
- Cache Coherency
- Memory Bandwidth

### 所属栏目

服务器处理器

## 图片资料

- 正文图片：18 张；目录：`amd_bergamo_zen4c_figures/`；顺序：`01` 至 `18`
- 图 8～10 的 NPS1/NPS2、图 11 并行 Pair 测试、图 13～16 跨平台限制须保留
- Core-to-core 大矩阵移动端建议保留点击查看
- WeMD 副本使用腾讯云 COS HTTPS 图片

## 封面与排版

- 推荐封面 900 × 383 px，可使用图 2 Package 或图 3 CCD
- 正文 15～16 px、行距 1.7～1.8；图注 12～13 px
- CCD/CCX、NPS、NUMA、Infinity Fabric、L3、Probe Filter 等术语保留
- “体系结构视角”小节显式保留

## 后台设置

- 标题：Bergamo：AMD 如何用 Zen 4c 把服务器堆到 128 核
- 作者栏：Chester Lam
- 摘要：使用本文件摘要
- 阅读原文：https://chipsandcheese.com/p/testing-amds-bergamo-zen-4c-spam
- 原创声明：关闭
- AI 内容标识：开启
- 图片顺序：01～18

## 来源与表述要求

- Zen 4c Core Architecture 不变，差异主要是 Physical Implementation、Clock、Area 与 L3 配比。
- 每 CCD 两 CCX 共用一条 I/O Die Interface；线程 Placement 影响 Bandwidth 阶梯。
- 全核 Read 近 360 GB/s，RMW Aggregate 378 GB/s；理论 460 GB/s。
- Bergamo NPS1，Milan-X/Genoa-X 对照 NPS2，Cross-socket 小差异不作结论。
- Core-to-core 测试并行多个不重叠 Pair，可能略高于单 Pair；同/跨 CCX/Socket 约 30～40/100～120/200 ns。
- 7950X3D 限 3.1 GHz 仍拥有更高 CCD Link 与更低 Client DRAM Latency，不是同平台。
- libx264/7-Zip 同时报告单 CCX 与整 CCD，不能只保留有利结果。
- 12 CCD/192 Core 与 7-bit ID 上限是潜力/假说，不是产品确认。

## 发布预览要点

- 18 张图和图注连续，本地链接有效，真实 MIME 与扩展名一致。
- `128 cores`、`16 cores/CCD`、`16 MB/CCX`、`360/378 GB/s`、`120 GB/s remote` 等数字正常。
- AMD 官方定位、Hot Aisle 系统测试、跨平台对照与教学分析保持分层。
- 腾讯云 COS URL 全部返回 HTTP 200，且 `Content-Type` 与图片格式一致。
- 母稿与 WeMD 除 H1、YAML 和图片 URL 外正文一致。
