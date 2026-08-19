# Neoverse N1 vs Zen 2：发布资料

## 正式标题

Neoverse N1 对 Zen 2：现实中的 Arm 与 x86

## 基本信息

- 英文题目：Neoverse N1 vs Zen 2: ARM in Practice
- 作者：Chester Lam
- 首发：Chips and Cheese
- 日期：2021 年 8 月 5 日
- 阅读原文：https://chipsandcheese.com/p/neoverse-n1-vs-zen-2-arm-in-practice
- 后台作者栏：Chester Lam

## 摘要

用四核 Altra N1 与四核 Zen 2 比较 RSA、7-Zip、gem5、x264/x265、AV1 和 Blender，并进一步测 Branch Predictor、BTB 与 Register File。N1 在编译和普通整数负载中可进入同一性能区间，却在 RSA、AVX2 与缺少 Arm 汇编的新 Codec 中暴露硬件和生态短板。

## 封面与分享文案

- 封面：Arm 和 x86 的现实差距，究竟来自哪里？
- 分享：同频编译 gem5，N1 甚至领先；换成 x265，Zen 2 却快 5～9 倍。把 IPC、指令数、分支预测和软件路径放在一起，才能理解真实平台差距。

## 备选标题

- N1 对 Zen 2：同频差距、AVX2 与软件生态
- 从 RSA 到 x265：Neoverse N1 的强项与短板

## 标签与栏目

- 标签：Neoverse N1、Zen 2、Arm Server、Benchmark、分支预测
- 栏目：处理器实测

## 图片与排版

- 共 25 张图，图 1 或图 23 可作封面。
- x265 的版本/NEON 路径与输出条件不能省略；正文 15～16 px。

## 发布前检查

- 同频、Boost、云 VM 与本地平台区分清楚。
- 功耗结论明确依赖 Arm 估计而非 N1 实测。
- 25 张图按顺序可访问。
