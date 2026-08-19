# AWS Graviton 3：发布资料

## 正式标题

AWS Graviton 3 初探：Arm Server 大核真正进入第一梯队

## 基本信息

- 英文题目：Graviton 3: First Impressions
- 作者：George Cozma
- 首发：Chips and Cheese
- 日期：2022 年 5 月 29 日
- 阅读原文：https://chipsandcheese.com/p/graviton-3-first-impressions
- 后台作者栏：George Cozma

## 摘要

Graviton 3 相比 N1 全面升级：可双 Taken/cycle 的 Micro-BTB、可能 4K+10K 目标层级、3K Micro-op Cache、六宽 Rename、约 512 项 ROB、三条访存管线和 256 bit SVE。低频让纳秒延迟与每核带宽仍落后部分 x86，SVE 软件生态也尚未成熟。

## 封面与分享文案

- 封面：从 N1 到 Graviton 3，Arm Server 核心跨过了什么？
- 分享：512 Branch 下记住长度 16 的模式、Micro-BTB 每拍处理两个 Taken、ROB 可能达到 512 项。Graviton 3 已不像一颗“加大版手机核”，但 2.6 GHz 和 SVE 生态仍决定落地上限。

## 备选标题

- Graviton 3：分支预测、512 项窗口与 SVE
- AWS 的 2.6 GHz 大核，为什么能进入 Server 第一梯队

## 标签与栏目

- 标签：AWS、Graviton 3、Neoverse V1、SVE、Arm Server
- 栏目：处理器架构

## 图片与排版

- 共 28 张图，图 1、9 或 28 可作封面。
- 反推容量统一使用“可能/约/支持判断”；正文 15～16 px。

## 发布前检查

- 不把 V1 来源、BTB/ROB/Scheduler 反推写成官方规格。
- Cache 同时保留 Cycle 与 ns 口径，SVE/NEON 分开。
- 28 张图按顺序可访问。
