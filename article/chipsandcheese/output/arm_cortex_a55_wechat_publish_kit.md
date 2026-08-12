# Arm Cortex-A55 微信公众号发布资料

## 正式发布信息

- 正式标题：Arm Cortex-A55：顺序小核的第二次打磨
- 署名：Chester Lam
- 来源：Chips and Cheese
- 发布日期：2026 年 8 月 2 日
- 英文标题：Arm’s Cortex A55
- 文章链接：https://chipsandcheese.com/p/arms-cortex-a55
- 阅读原文链接：https://chipsandcheese.com/p/arms-cortex-a55

### 摘要

从 36 张图理解 Cortex-A55：两宽顺序执行没有变，神经网络方向预测、48 项 Micro-BTB、两周期 Load、私有 L2、DynamIQ L3 和 L3 Prefetch 却重塑了它的实际性能。

### 封面文案

主标题：Cortex-A55

副标题：顺序小核的第二次打磨

### 分享文案

A55 没有改掉 A53 的两宽顺序框架，却用预测、旁路、私有 L2 和 DSU L3 把 SPEC CPU2026 整数/浮点几何平均提高 35.35%/50.45%。

### 备选标题

- 36 张图看懂 Cortex-A55
- Cortex-A55：两宽顺序小核如何再活一代
- Cortex-A55 架构分析：真正的升级发生在存储系统

### 文章标签

- Arm Cortex-A55
- CPU 微架构
- 顺序执行
- 分支预测
- DynamIQ
- Cache 与 TLB
- SPEC CPU2026

### 所属栏目

CPU 微架构

## 图片资料

- 正文图片：36 张；目录：`arm_cortex_a55_figures/`；顺序：`01` 至 `36`
- 图 1、11、13、18～20、25 有网页正式图注；其余中文图注用于辅助读图
- 图 4、5、18、20、27、28 为密集曲面或矩阵，移动端保留点击查看
- WeMD 副本使用腾讯云 COS HTTPS 图片

## 封面与排版

- 推荐封面 900 × 383 px，可选择图 1 Arm 定位图或图 2 流水线
- 正文 15～16 px、行距 1.7～1.8；图注 12～13 px
- BTB、BTIC、DPU、TLB、IPA、DSU、VIPT、PIPT、ECC 等缩写保留
- “体系结构视角”小节显式保留

## 后台设置

- 标题：Arm Cortex-A55：顺序小核的第二次打磨
- 作者栏：Chester Lam
- 摘要：使用本文件摘要
- 阅读原文：https://chipsandcheese.com/p/arms-cortex-a55
- 原创声明：关闭
- AI 内容标识：开启
- 图片顺序：01～36

## 来源与表述要求

- 主要 A55 平台为 Genio 1200/Radxa NIO 12L，A53 为 Amlogic S922X，SoC、Cache、内存和软件环境不同。
- “Neural-network-based”很可能指 Perceptron，但 Arm 未公开算法或 RTL。
- A55 Retired Branch 与 A53 Executed Branch PMU 口径不同，Branch MPKI 只可粗比。
- Clang、Photo Library 预测没有改善，Structure from Motion 与整数负载 Interlock 改善有限，负面结果不得删除。
- 48 Micro-BTB、两周期 Load、三 Outstanding Refill 等有文档与微基准支撑；A53 Guide 的两周期 Pointer Latency未能复现。
- Cache Miss 后可见约八条年轻指令来自 Pipeline Stage，不是 Pseudo-ROB。
- Genio 1200 的 9/35-cycle L2/L3、Prefetch 与带宽属于具体 SoC 实现，不能全归给 A55 IP。
- SPEC CPU2026 图为 Estimated Scores；网页没有完整编译器、Flags 与重复统计，也未收集 PMU。

## 发布预览要点

- 36 张图和图注编号连续，本地链接有效，真实 MIME 与扩展名一致。
- `2-wide`、`8/9-stage`、`48 micro-BTB`、`16/1024 TLB`、`128 KB L2`、`2 MB L3` 等数字正常。
- 官方资料、微基准、实现差异和体系结构补充仍清晰分开。
- 腾讯云 COS URL 全部返回 HTTP 200，且 `Content-Type` 与图片格式一致。
- 母稿与 WeMD 除 H1、YAML 和图片 URL 外正文一致。
