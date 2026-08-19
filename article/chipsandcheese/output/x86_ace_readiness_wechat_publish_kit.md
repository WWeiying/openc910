# x86 准备好 ACE 了吗：从 AMX 内积走向外积矩阵加速：发布资料

## 正式标题

x86 准备好 ACE 了吗：从 AMX 内积走向外积矩阵加速

## 基本信息

- 英文题目：Is x86 ready to ACE it?
- 作者：Chester Lam、Aurora Nockert
- 首发：Chips and Cheese
- 日期：2026 年 7 月 14 日
- 阅读原文：https://chipsandcheese.com/p/is-x86-ready-to-ace-it
- 后台作者栏：Chester Lam、Aurora Nockert

## 摘要

ACE 把 AMX 框架从内积扩展到外积，以 AVX-512 输入、8 KB Tile Accumulator、灵活 2～7 bit 反量化和 Block Scaling 服务新一代矩阵计算。与 Arm SME2 相比各有取舍，但尚无硬件，真实性能仍取决于实现。

## 封面与分享文案

- 封面：ACE 会成为 x86 的下一代矩阵引擎吗？
- 分享：同一 32K 矩阵乘的理想 Cache Traffic，从 AVX-512 的 3.4 TB 降到 ACE 的 1.5 TB。外积、Tile 与反量化如何一起改变 CPU 矩阵计算？

## 备选标题

- ACE 对 SME2：x86 与 Arm 的外积矩阵路线
- 从 AMX 到 ACE：为什么更大的 Accumulator 能省带宽

## 标签与栏目

- 标签：ACE、AMX、SME2、矩阵计算、AVX10
- 栏目：ISA 与加速器

## 图片与排版

- 共 12 张图，图 3、5 或 12 可作封面。
- 数学公式在微信编辑器中确认渲染；必要时转为普通文本公式。

## 发布前检查

- 截至发布日期没有 ACE Hardware，未来支持未写成事实。
- Traffic Calculation 是理想化模型，不是实测 Benchmark。
- 12 张图按顺序可访问。
