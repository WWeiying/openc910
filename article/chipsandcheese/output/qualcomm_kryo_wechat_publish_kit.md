# Qualcomm Kryo 微信公众号发布资料

## 正式发布信息

- 正式标题：Kryo：Qualcomm 最后一代自研移动 CPU 核心
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2023 年 7 月 13 日
- 英文标题：Kryo: Qualcomm’s Last In-House Mobile Core
- 文章链接：https://chipsandcheese.com/p/kryo-qualcomms-last-in-house-mobile-core
- 阅读原文链接：https://chipsandcheese.com/p/kryo-qualcomms-last-in-house-mobile-core

### 摘要

从 20 张图理解初代 Kryo：四宽前端、强整数调度和复杂 Store Forwarding 识别为何没能战胜单级 TLB、小而慢的 L2、跨簇一致性与持续功耗。

### 封面文案

主标题：Qualcomm Kryo

副标题：没有等到第二代的雄心之作

### 分享文案

2016 年的 Kryo 像一颗低频桌面核：四宽、四 ALU、好 Scheduler，却被不到一 IPC 的 L2 取指、13-cycle Forwarding 和单级 TLB 拖住。

### 备选标题

- 20 张图看懂初代 Qualcomm Kryo
- Kryo：四宽移动大核为何只活了一代
- Qualcomm 初代 Kryo 架构分析

### 文章标签

- Qualcomm Kryo
- Snapdragon 821
- CPU 微架构
- 乱序执行
- 分支预测
- Cache 与 TLB
- 移动处理器

### 所属栏目

CPU 微架构

## 图片资料

- 正文图片：20 张；目录：`qualcomm_kryo_figures/`；顺序：`01` 至 `20`
- 图 1、2、13～15、17、20 有网页正式图注，其余中文图注用于辅助读图
- 图 3、4、7、13、14、19 为密集曲面或矩阵，移动端建议保留点击查看
- WeMD 副本使用腾讯云 COS HTTPS 图片

## 封面与排版

- 推荐封面 900 × 383 px，可使用图 2 Block Diagram 或图 20 面积对照
- 正文 15～16 px、行距 1.7～1.8；图注 12～13 px
- BTB、RAS、Rename、Scheduler、FPU、TLB、L2、Snoop 等术语保留
- “体系结构视角”小节显式保留

## 后台设置

- 标题：Kryo：Qualcomm 最后一代自研移动 CPU 核心
- 作者栏：Chester Lam
- 摘要：使用本文件摘要
- 阅读原文：https://chipsandcheese.com/p/kryo-qualcomms-last-in-house-mobile-core
- 原创声明：关闭
- AI 内容标识：开启
- 图片顺序：01～20

## 来源与表述要求

- 被测平台为 Snapdragon 821/LG G6；Android 噪声大且无法使用 Huge Page，结果保持近似与不确定性。
- Block Diagram 几乎完全来自 Reverse Engineering，不是 Qualcomm 官方或 RTL。
- 8-entry Fast BTB、8 KB L0 I-cache、其余 Branch Address Calculator 均为曲线解释，后两项不能写成确认实现。
- Big/Little L2 约 768 KB（带问号）/512 KB，25/23 cycle；来自测试边界，不是统一 IP 参数。
- Store Forwarding Case 识别很强，成功路径仍约 13 cycle；两项评价必须同时保留。
- 192-entry 单级 TLB 在 4 KB Page 下名义覆盖 768 KB，没有 L2 TLB。
- DRAM 短测超过 18 GB/s、长测约 14 GB/s；持续热降频是结论的重要部分。
- 跨 Cluster 可能经 DRAM 搬运只是推测，不能写成确认机制。
- 图 20 是论坛用户整理的面积估算，带“若准确”条件。
- 后来的 Kryo 280 等是定制 Cortex，不是本文初代自研 Kryo。

## 发布预览要点

- 20 张图和图注连续，本地链接有效，真实 MIME 与扩展名一致。
- `4-wide`、`8-entry fast BTB`、`16-entry RAS`、`192-entry TLB`、`13-cycle forwarding` 等数字正常。
- Core IP、Snapdragon 821 Uncore、Android 测试限制与架构推测保持分层。
- 腾讯云 COS URL 全部返回 HTTP 200，且 `Content-Type` 与图片格式一致。
- 母稿与 WeMD 除 H1、YAML 和图片 URL 外正文一致。
