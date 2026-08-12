# AmpereOne Hot Chips 2024 微信公众号发布资料

## 正式发布信息

- 正式标题：AmpereOne：为密度而生
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2024 年 8 月 29 日
- 英文标题：AmpereOne at Hot Chips 2024: Maximizing Density
- 文章链接：https://chipsandcheese.com/p/ampereone-at-hot-chips-2024-maximizing-density
- 阅读原文链接：https://chipsandcheese.com/p/ampereone-at-hot-chips-2024-maximizing-density

### 摘要

从 34 张图理解 AmpereOne：四宽自研核心、八表 TAGE、208 项 ROB、Write-through L1D、2 MB L2、192 核 Mesh，以及“密度与稳定性能优先”如何贯穿整颗处理器。

### 封面文案

主标题：AmpereOne

副标题：为密度而生

### 分享文案

16 KB L1I、64 KB Write-through L1D、2 MB L2、192 核 8×9 Mesh：AmpereOne 没有追逐桌面大核峰值，而是围绕云端密度与稳定性能重做平衡。

### 备选标题

- 34 张图看懂 AmpereOne 的密度路线
- AmpereOne 架构分析：192 核背后的核心与 Mesh
- AmpereOne：为什么一颗服务器核选择小 L1I 和大 L2

### 文章标签

- AmpereOne
- Ampere Computing
- CPU 微架构
- 服务器处理器
- 分支预测
- 乱序执行
- Memory Tagging
- Chiplet 与 Mesh

### 所属栏目

CPU 微架构

## 图片资料

- 正文图片：34 张；目录：`ampereone_hot_chips_2024_figures/`；顺序：`01` 至 `34`
- 图 2、8、14、27、34 有网页正式图注；其余中文图注用于辅助读图
- 图 6、14、19、20、24、27 为高密度曲线或矩阵，移动端保留点击查看
- 图 22 原始资源为 JPEG，文件已使用 `.jpg`，避免错误 Content-Type
- WeMD 副本使用腾讯云 COS HTTPS 图片

## 封面与排版

- 推荐封面 900 × 383 px，可使用图 1 GDS 或图 26 Compute Chiplet
- 正文 15～16 px、行距 1.7～1.8；图注 12～13 px
- TAGE、BTB、ROB、AGU、TLB、NSQ、SLC、CMN、D2D、ATM 等缩写保留
- “体系结构视角”小节显式保留

## 后台设置

- 标题：AmpereOne：为密度而生
- 作者栏：Chester Lam
- 摘要：使用本文件摘要
- 阅读原文：https://chipsandcheese.com/p/ampereone-at-hot-chips-2024-maximizing-density
- 原创声明：关闭
- AI 内容标识：开启
- 图片顺序：01～34

## 来源与表述要求

- AmpereOne 产品最高 3.7 GHz；Oracle 被测 SKU 最高 3 GHz，两者不得混写。
- 256/8K BTB、10-cycle Recovery、208 ROB、192 Scheduler、64/1536 DTLB、2 MB L2 等来自 Ampere Slide；20/24/32 Scheduler、LQ/SQ、约 112 RAS 等部分容量来自微基准。
- `IDR_STALL_IXU_SCHED` 同时可能指向 Scheduler 或整数寄存器不足，不能只按事件名归因。
- Store Forwarding 包含组合的快路约 6～7 周期，失败约 17；向量转发约 12，L1D 两端口与 128-bit 位宽仍是行为推测。
- 11-cycle/3.68 ns L2 在 3 GHz 下吻合；166 ns DRAM 是端到端结果，不能全归因于 Mesh。
- CXRH 功能未披露，连接 PCIe I/O Die 只是推测。
- Memory Tagging 无容量/带宽开销、ATM Loaded Latency、Perf/W 和 Performance/Rack 均为 Ampere 主张，网页没有独立整机复测。
- Oracle 配额仅 16 核且不支持 Ubuntu/Debian，测试覆盖有限。
- 7-Zip/libx264 的跨 ISA 对照只限制到约 3 GHz，软件、平台和 Cache 配置不完全一致。

## 发布预览要点

- 34 张图和图注编号连续，本地链接有效，真实 MIME 与扩展名一致。
- `16 KB L1I`、`64 KB L1D`、`2 MB L2`、`208 ROB`、`192 Scheduler`、`192 core`、`64 MB SLC` 等数字正常。
- 官方披露、Oracle 实测、行为反推和体系结构补充仍清晰分开。
- 腾讯云 COS URL 全部返回 HTTP 200，且 `Content-Type` 与图片格式一致。
- 母稿与 WeMD 除 H1、YAML 和图片 URL 外正文一致。
