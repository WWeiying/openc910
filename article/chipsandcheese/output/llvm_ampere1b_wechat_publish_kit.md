# LLVM Ampere1B：发布资料

## 正式标题

从 LLVM 提交看 AmpereOne 1A 与 1B

## 基本信息

- 英文题目：LLVM’s Ampere1B Commit
- 作者：Chester Lam
- 首发：Chips and Cheese
- 日期：2024 年 2 月 20 日
- 阅读原文：https://chipsandcheese.com/p/llvms-ampere1b-commit
- 后台作者栏：Chester Lam

## 摘要

LLVM 调度模型显示，AmpereOne 以四宽、四条整数 ALU 和轻量 FP/Vector 换 192 核密度；1A 增加融合、SM3/SM4 与 MTE，1B 则把重排扩到 192 微操作，并显著降低 FP、Vector 和 L1D 延迟。

## 封面与分享文案

- 封面：一条 LLVM Commit，能看出多少 CPU 架构？
- 分享：三周期 Load、192 微操作窗口、更快 FP/Vector——Ampere 1B 的编译器模型透露了一次不小的中期换代，也暴露了 SVE 和高密度服务器的系统难题。

## 备选标题

- AmpereOne 1B：从编译器调度模型反推设计重点
- 192 核之后，Ampere 为什么开始补 FP 与 Load 延迟

## 标签与栏目

- 标签：AmpereOne、LLVM、Arm Server、编译器、微架构
- 栏目：处理器架构

## 图片与排版

- 共 8 张图，图 1 或图 5 适合作封面。
- LLVM Feature 名用等宽样式；正文 15～16 px。

## 发布前检查

- 全文明确 LLVM Model 不等于硬件确认。
- MTE 产品资料与 LLVM 支持差异保留。
- C3A 的上线状态与价格均按 2024 年文章时点表述。
- 8 张图均可访问。
