# Arm Cortex-A72 微信公众号发布资料

## 正式发布信息

- 正式标题：Arm Cortex-A72：让 AArch64 走向大众
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2023 年 11 月 10 日
- 英文标题：ARM’s Cortex A72: aarch64 for the Masses
- 文章链接：https://chipsandcheese.com/p/arms-cortex-a72-aarch64-for-the-masses
- 阅读原文链接：https://chipsandcheese.com/p/arms-cortex-a72-aarch64-for-the-masses

### 摘要

从 45 张图理解 Cortex-A72：三宽前端、128 项 ROB、分布式 Scheduler、稳健 Store Forwarding，以及 Graviton 1 共享 L2 和集群互连如何限制服务器表现。

### 封面文案

主标题：Cortex-A72

副标题：让 AArch64 走向大众

### 分享文案

三宽、128 项 ROB、48 KB L1I、21 周期共享 L2；单核够强，四核 Read 却很快饱和。45 张图看清 Cortex-A72 与 Graviton 1 的得失。

### 备选标题

- Cortex-A72：一颗让 AArch64 普及的低功耗乱序核
- 45 张图看懂 Cortex-A72 与第一代 Graviton
- Cortex-A72 架构分析：核心够用，存储层级拖后腿

### 文章标签

- Arm Cortex-A72
- AWS Graviton 1
- AArch64
- CPU 微架构
- 分支预测
- 乱序执行
- Cache 与互连

### 所属栏目

CPU 微架构

## 图片资料

- 正文图片：45 张；目录：`arm_cortex_a72_figures/`；顺序：`01` 至 `45`
- 所有图片保留网页顺序；JPEG/PNG 扩展名已按真实编码修正
- 图 2～7、25～27 为高密度曲面或矩阵，移动端保留点击查看
- 图 17、18、22 为数据密集表格，建议原宽显示
- WeMD 副本使用腾讯云 COS HTTPS 图片

## 封面与排版

- 推荐封面 900 × 383 px，可使用 A72 核心总览或 Graviton 四集群示意
- 正文 15～16 px、行距 1.7～1.8；图注 12～13 px
- BTB、RAS、ROB、AGU、LQ、SQ、TLB、MSHR 等缩写保留
- “体系结构视角”小节显式保留

## 后台设置

- 标题：Arm Cortex-A72：让 AArch64 走向大众
- 作者栏：Chester Lam
- 摘要：使用本文件摘要
- 阅读原文：https://chipsandcheese.com/p/arms-cortex-a72-aarch64-for-the-masses
- 原创声明：关闭
- AI 内容标识：开启
- 图片顺序：01～45

## 来源与表述要求

- 核心微结构测试来自 AWS Graviton 1 的 2.3 GHz A72；对照 Kryo 来自 Snapdragon 821，最高 2.34 GHz。
- 网页未披露 OS/Kernel、编译器、固定频率、预热、重复次数和统计误差；手机测试噪声明确较高。
- Paul Drongowski 估计 RAS 为 8 项，测试支持约 31 项，两种口径都要保留。
- BTB 的 2K/4K 近远分支解释未被完全接受；Far BTB 台阶也可能来自 L1I miss。
- A72 前端图中的 4096 BTB、256 间接目标、31 RAS 等含测试反推，不是官方 RTL。
- A72 取指微基准使用 NOP/ADD/MOV 混合，Kryo 使用 NOP，不能把曲线当成完全同构测试。
- 128-bit NEON 结果约消耗五个 64-bit FP/Vector 条目是微基准观察，不能直接推导物理写端口。
- 图 24 是 Zen 2/Cinebench R15 例子，只说明 AGU Scheduler 可能成为瓶颈，不是 A72 数据。
- A72 不做内存依赖投机是根据 Forwarding 行为提出的机制解释，没有 RTL 确认。
- 16 KB 后的 A72 L1D 延迟台阶无法由公开 32 项 L1 DTLB 解释，必须保留为未确定项。
- 页面一处把 Graviton 1 的 L2 写成 Graviton 2，正文已说明上下文矛盾。
- Graviton 1 的 L2、Cluster 出口与 DRAM 结果不能泛化到 Raspberry Pi 4 或所有 A72 SoC。
- Graviton 内存通道类型只是 fast DDR3/slow DDR4 推测，不是确认配置。
- 核间延迟测试未披露同步协议与 Cache line 状态，不能据矩阵量化一般应用损失。

## 发布预览要点

- 45 张图片和图注编号连续，本地链接有效，真实 MIME 与扩展名一致。
- `48 KB/3-way L1I`、`128 ROB`、`64/126/31 rename`、`32/15 LSQ`、`21-cycle L2`、`13.5/36.31 GB/s` 等数字正常。
- 8/31 RAS、16 KB L1D 台阶、Graviton 1/2 笔误等内部不确定项仍在。
- 腾讯云 COS URL 全部返回 HTTP 200，且 `Content-Type` 与图片格式一致。
- 母稿与 WeMD 除 H1、YAML 和图片 URL 外正文一致。
