# Intel Goldmont Plus WeChat Publish Kit

## 正式标题

Goldmont Plus：Intel Atom 走向混合架构前的过渡一代

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：Tracing Intel’s Atom Journey: Goldmont Plus
- 日期：2024-06-10
- 阅读原文：https://chipsandcheese.com/p/tracing-intels-atom-journey-goldmont-plus
- 栏目：Intel Atom / 微架构

## 摘要

Goldmont Plus 已有 3-wide 乱序前端、93 项 ROB、PRF、分布式调度和 4 MB shared L2，却受慢 BTB、24 KB 疑似 write-through L1D、单 load AGU 与高 DRAM 延迟限制。它比早期 Atom 平衡，也清楚暴露了 Intel 走向 Tremont 与混合架构前的过渡状态。

## 封面文案

93 项 ROB、4 MB L2：被遗忘的 Atom 已经走了多远？

## 分享文案

从分支预测、64 KB predecode cache、4-wide rename，到 store forwarding、TLB 与疑似 4 KB write-back buffer，完整拆解 Celeron J4125 的 Goldmont Plus。

## 备选标题

- Goldmont Plus 深度拆解：一颗定位尴尬却很平衡的 Atom
- 从 Silvermont 到 Tremont：Goldmont Plus 补上了什么，还缺什么

## 标签

Intel、Atom、Goldmont Plus、Gemini Lake、乱序执行、缓存

## 图片说明

- 共 24 张图，全部按页面顺序保留。
- 图 3—8 为前端，图 9—16 为乱序与 load/store，图 17—24 为缓存、带宽与核间通信。
- 图 22 支持 write-through L1D/4 KB buffer 推断，但不是 Intel 官方结构图。

## 发布前检查

- [ ] 24 张图全部显示且顺序正确
- [ ] J4125 的 10 W 目标与 13—14 W 全核实测没有混淆
- [ ] BTB 2048 项/3 周期、93 项 ROB、PRF 容量等数据准确
- [ ] store forwarding 快慢路径与 10—11 周期惩罚完整
- [ ] dTLB、L2 TLB、24 KB L1D、4 MB/19 周期 L2 保留
- [ ] write-through 与 false-dependency 原因保持推断口径
