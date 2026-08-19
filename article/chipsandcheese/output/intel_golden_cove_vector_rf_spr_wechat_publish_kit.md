# Golden Cove Vector RF Official Check WeChat Publish Kit

## 正式标题

用 Sapphire Rapids 官方数据复核 Golden Cove：向量寄存器文件到底有多大

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：Golden Cove’s Vector Register File: Checking with Official (SPR) Data
- 日期：2023-01-15
- 阅读原文：https://chipsandcheese.com/p/golden-coves-vector-register-file-checking-with-official-spr-data
- 栏目：处理器微架构 / 乱序后端

## 摘要

Sapphire Rapids 官方数据支持 Golden Cove 只有部分物理向量寄存器具备 512-bit 宽度，但也修正了简单“speculative 容量 + 32 个架构寄存器”的算法。文章进一步解释结构容量微基准的误差，以及 240-entry Load Queue 为何只测到 192 个在途 load。

## 封面文案

官方数字来了：软件反推到底准了多少？

## 分享文案

一次难得的反向验证：把 Golden Cove 微基准与 Sapphire Rapids 官方结构容量对上，拆解物理寄存器、精确状态和 Load Queue 定义之间的差别。

## 备选标题

- 从 210/295 到官方数据：Golden Cove 向量寄存器复核
- 为什么 240 项 Load Queue，软件只能测到 192 项

## 标签

Intel、Golden Cove、Sapphire Rapids、AVX-512、物理寄存器、Load Queue、ROB

## 图片说明

- 共 7 张图，图 1—4 为容量核对，图 6 展示测量方法。
- 官方 slide 与测试推算应在图注中明确区分。

## 移动端排版与后台设置

- 摘要填后台，开启原文链接。
- 所有绝对 entry 数保留测量/官方/推算属性。
- 图片保持原比例。

## 发布前检查

- [ ] 7 张图全部可显示
- [ ] Golden Cove 与 SPR 相似性的假设保留
- [ ] zero tracking 只写为猜想
- [ ] 240 与 192 的定义差异解释完整
- [ ] 没有把微基准误差写成硬件缺陷
