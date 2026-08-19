# A710 N2 FP Scheduler Correction WeChat Publish Kit

## 正式标题

Cortex-A710 / Neoverse N2 浮点调度器：一次微架构测量纠错

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：Correction for A710/Neoverse N2’s FP Scheduler Layout
- 日期：2023-08-20
- 阅读原文：https://chipsandcheese.com/p/correction-for-a710-neoverse-n2s-fp-scheduler-layout
- 栏目：Arm 微架构 / 测试方法

## 摘要

一次 SCVTF 形式选择错误，让 A710 的 M0 队列被误认为 V0 调度器。重新选用 FJCVTZS、ADDV 并分离 NSQ 后，更合理的模型是两套约 19 项 scheduler，共享约 11 项非调度队列。文章同时解释如何从外部测量乱序资源，以及为何一个容量拐点不能直接等同于物理队列深度。

## 封面文案

从“30 项”到“19+11”：微架构测量怎样发现自己错了

## 分享文案

同一个 SCVTF，因为操作数形式不同就会走另一条端口。本文完整还原 A710 浮点调度器测量的错误、纠正与方法论。

## 备选标题

- A710 浮点调度器纠错：端口、微操作与 NSQ 的三重陷阱
- 怎样从微基准测出 scheduler？一次 Arm 核心测量复盘

## 标签

Arm、Cortex-A710、Neoverse N2、Scheduler、乱序执行、微基准

## 图片说明

- 共 10 张图，按页面顺序保留。
- 图 3 的手册表格、图 6 的测试代码与图 7 的拐点是理解纠错的关键。
- 图 10 是作者明确标为仍不完整的 Cortex-X2 初步模型。

## 发布前检查

- [ ] 10 张图全部显示且顺序正确
- [ ] SCVTF、FJCVTZS、ADDV 的形式与端口关系准确
- [ ] 30 项可见容量与 19 项 scheduler、11 项 NSQ 未混为一谈
- [ ] A710 组织写为微基准支持的模型，不写成 Arm 官方 RTL
- [ ] Cortex-X2 图保留“仍未计入 NSQ”的限制
