# RISC-V P550 与 C910 实测：发布资料

## 正式标题

RISC-V 进展检查：P550 与 C910 实测

## 基本信息

- 英文题目：A RISC-V Progress Check: Benchmarking P550 and C910
- 作者：Chester Lam
- 首发：Chips and Cheese
- 日期：2025 年 1 月 30 日
- 阅读原文：https://chipsandcheese.com/p/a-risc-v-progress-check-benchmarking
- 后台作者栏：Chester Lam

## 摘要

用 SPEC CPU2017、7-Zip、SHA-256 与 x264 对照 P550、C910、Cortex-A73、Goldmont Plus 和 Cortex-A55，解释频率、IPC、动态指令数、存储系统与软件生态如何共同决定 RISC-V 的实际性能。

## 封面文案

P550 与 C910，RISC-V 高性能走到了哪里？

## 分享文案

同样是三宽乱序核心，为什么 P550 能以更低频率追上 C910？为什么 RISC-V 在 x264 中 IPC 最高、性能却最差？答案不只在核心，也在 SoC 和软件生态。

## 备选标题

- P550 对 C910：一场不只看 IPC 的 RISC-V 实测
- RISC-V 高性能进展：核心、平台与软件生态的三重考验

## 标签与栏目

- 标签：RISC-V、SiFive P550、玄铁 C910、SPEC CPU2017、微架构
- 栏目：处理器实测

## 图片说明

- 共 18 张图，按英文页面出现顺序排布。
- 建议封面使用图 1 或图 18；正文性能曲线应保留原图尺寸，点击查看。

## 移动端排版与后台设置

- 正文 15～16 px，图注 13 px；代码编译参数保留等宽字体。
- 原始链接放文首并设置为可复制文本；摘要控制在 120 字内。
- 开启原文链接，关闭赞赏提示之外的无关自动组件。

## 发布前检查

- 确认四个平台、GCC 14.2.0 与编译参数完整保留。
- 确认 7-Zip/SHA-256 的 2.67 GB 输入和四线程条件未删。
- 确认 x264 的高 IPC、高指令数与软件缺少 RISC-V 汇编三个要点同时出现。
- 确认 18 张图片均可访问，无平台测试结果误归因于 ISA。
