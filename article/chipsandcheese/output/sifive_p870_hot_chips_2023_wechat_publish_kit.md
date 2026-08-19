# SiFive P870：发布资料

## 正式标题

SiFive P870：RISC-V 大核再向前一步

## 基本信息

- 英文题目：Hot Chips 2023: SiFive’s P870 Takes RISC-V Further
- 作者：Chester Lam
- 首发：Chips and Cheese
- 日期：2023 年 9 月 3 日
- 阅读原文：https://chipsandcheese.com/p/hot-chips-2023-sifives-p870-takes-risc-v-further
- 后台作者栏：Chester Lam

## 摘要

六宽乱序、八表 TAGE、分级目标预测、较短误预测恢复、分布式调度和 2×128 bit RVV：P870 已具备当代大核的基本轮廓，也暴露出访存队列、向量吞吐与软件生态上的现实边界。

## 封面与分享文案

- 封面：P870，RISC-V 大核走到哪一步了？
- 分享：P870 没有微操作缓存，却把误预测恢复压到约 7～8 周期；LMUL 指令又被推迟到后端拆分。一起看 SiFive 如何在前端、调度与 RVV 之间取舍。

## 备选标题

- Hot Chips 2023：拆解 SiFive P870 的前端与向量后端
- 从 TAGE 到 LMUL Sequencer：P870 的 RISC-V 大核路线

## 标签与栏目

- 标签：RISC-V、SiFive、P870、分支预测、向量处理
- 栏目：处理器架构

## 图片与排版

- 共 19 张图，建议图 2 或图 5 作封面。
- 图 3、5、12、13 为带标注的流水图，保持原尺寸。
- 正文 15～16 px，图注 13 px。

## 发布前检查

- 频率、流水级和误预测代价均保留“披露/推算”边界。
- 36 B/cycle、64 项 RAS、2.5K 间接预测器、2×128 bit 向量等参数完整。
- 19 张图片顺序、链接及标题检查无误。
