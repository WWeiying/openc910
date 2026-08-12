# AMD Bulldozer（上）微信公众号发布资料

## 正式发布信息

- 正式标题：Bulldozer：AMD 的激进现代化（上）——前端与执行引擎
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2023 年 1 月 22 日
- 英文标题：Bulldozer, AMD’s Crash Modernization: Frontend and Execution Engine
- 文章链接：https://chipsandcheese.com/p/bulldozer-amds-crash-modernization-frontend-and-execution-engine
- 阅读原文链接：https://chipsandcheese.com/p/bulldozer-amds-crash-modernization-frontend-and-execution-engine

### 摘要

从 31 张图理解 Bulldozer 的现代化：CMT 共享、PRF、RAT Checkpoint、统一 Scheduler 与竞争式 FPU 为何仍被慢 BTB、两 ALU 和 35～43-cycle LSU 慢路拖住。

### 封面文案

主标题：AMD Bulldozer（上）

副标题：前端与执行引擎

### 分享文案

Bulldozer 并不落后于时代：PRF、Checkpoint 和共享 FPU 都很现代；问题是新机制的延迟与单线程资源没有形成平衡。

### 备选标题

- 31 张图看懂 AMD Bulldozer 前后端
- Bulldozer 为什么先进却不快
- AMD Bulldozer 架构分析：现代化的代价

### 文章标签

- AMD Bulldozer
- CPU 微架构
- CMT
- 分支预测
- 乱序执行
- FPU
- Load/Store

### 所属栏目

CPU 微架构史

## 图片资料

- 正文图片：31 张；目录：`amd_bulldozer_frontend_execution_figures/`；顺序：`01` 至 `31`
- 图 3 的 FP Scheduler 64/60 项冲突、图 27～31 的慢路和 4K Alias 均须保留
- 密集结构图、曲面与矩阵移动端建议保留点击查看
- WeMD 副本使用腾讯云 COS HTTPS 图片

## 封面与排版

- 推荐封面 900 × 383 px，可使用图 1 芯片或图 3 Module
- 正文 15～16 px、行距 1.7～1.8；图注 12～13 px
- CMT、BTB、PRF/RRF、RAT、Scheduler、FMA4、LQ/SQ 等术语保留
- “体系结构视角”小节显式保留

## 后台设置

- 标题：Bulldozer：AMD 的激进现代化（上）——前端与执行引擎
- 作者栏：Chester Lam
- 摘要：使用本文件摘要
- 阅读原文：https://chipsandcheese.com/p/bulldozer-amds-crash-modernization-frontend-and-execution-engine
- 原创声明：关闭
- AI 内容标识：开启
- 图片顺序：01～31

## 来源与表述要求

- Module 为 Frontend/FPU/L2 共享，Integer/LSU 每线程私有；不笼统称“两个完整核心”。
- FP Scheduler Optimization Manual 写 64，ISSCC/测试约 60；两者并列。
- L2 BTB Hit 五周期、每三周期一 Target；Sandy Bridge L1 BTB 对照来自微基准。
- ROB 比 K10 增 77%，Mapper Checkpoint 消除等待 Branch Retire 的恢复 Stall。
- Integer RF 双副本等效 8 Read/4 Write，但 Write 写入两份。
- 256-bit AVX 拆两条 128-bit Micro-op；FMA4 的峰值受算法融合和软件支持限制。
- Bulldozer Forward 成功 8、失败 35～43 cycle；K10 覆盖少但最坏 12～13，不能只写覆盖提升。
- 跨页 TLB 双读与 Write-through 影响均为推测，不写成确认实现。

## 发布预览要点

- 31 张图和图注连续，本地链接有效，真实 MIME 与扩展名一致。
- `512 L1 BTB`、`24 RAS`、`40 scheduler`、`60/64 FP scheduler`、`160 FP RF`、`40/24 LQ/SQ` 等数字正常。
- 官方资料、微基准、内部冲突和体系结构分析保持分层。
- 腾讯云 COS URL 全部返回 HTTP 200，且 `Content-Type` 与图片格式一致。
- 母稿与 WeMD 除 H1、YAML 和图片 URL 外正文一致。
