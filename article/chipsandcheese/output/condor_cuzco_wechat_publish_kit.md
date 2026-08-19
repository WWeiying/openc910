# Condor Cuzco：发布资料

## 正式标题

Condor Cuzco：用“时间表”调度的八宽 RISC-V 核心

## 基本信息

- 英文题目：Condor’s Cuzco RISC-V Core at Hot Chips 2025
- 作者：Chester Lam
- 首发：Chips and Cheese
- 日期：2025 年 8 月 29 日
- 阅读原文：https://chipsandcheese.com/p/condors-cuzco-risc-v-core-at-hot
- 后台作者栏：Chester Lam

## 摘要

Cuzco 用 256 周期时间资源矩阵在重命名阶段预订未来资源，再以 poison/replay 处理 Cache miss 等变量延迟，试图保留乱序性能并降低动态调度功耗。本文同时梳理其 TAGE-SC-L 前端、256 项 ROB、执行切片、64 项 Load/Store Queue 和八核缓存集群。

## 封面与分享文案

- 封面：八宽乱序，后端却按“时间表”执行
- 分享：不改 RISC-V ISA，也不依赖编译器，Cuzco 把调度提前到 Rename，并让 Load miss 触发 replay。这种用重执行换调度器复杂度的设计，能否在硅片上成立？

## 备选标题

- Cuzco：一颗把乱序调度搬到 Rename 的 RISC-V 大核
- TRM、Poison 与 Replay：Cuzco 的非常规乱序后端

## 标签与栏目

- 标签：RISC-V、Cuzco、Condor Computing、乱序执行、Hot Chips
- 栏目：处理器架构

## 图片与排版

- 共 12 张图，建议图 1 或图 6 作封面。
- 图 6、图 8、图 9 保持原尺寸；首次出现 TRM、XEQ、PIPT 时保留英文缩写。
- 正文 15～16 px，图注 13 px。

## 发布前检查

- 明确所有数字来自 Hot Chips 披露而非硅片实测。
- 保留每千条 70.07 次 replay、八周期搜索窗和 L3 命中三次执行的边界。
- 检查 12 张图片、原始链接和主题小标题。
