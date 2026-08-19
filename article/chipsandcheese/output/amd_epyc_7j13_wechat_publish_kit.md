# AMD EPYC 7J13 WeChat Publish Kit

## 正式标题

AMD EPYC 7J13：为 GPU 云实例定制的 Zen 3

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：AMD’s EPYC 7J13: Zen 3 Customized
- 日期：2023-06-28
- 阅读原文：https://chipsandcheese.com/p/amds-epyc-7j13-zen-3-customized
- 栏目：服务器处理器 / AMD Zen

## 摘要

EPYC 7J13 是出现在 Lambda Cloud A100 实例中的非公开 Zen 3 SKU。它保留常规 Zen 3 的执行吞吐与 L2 带宽，却把 L2 命中延迟从约 12 周期放宽到 20 周期，体现了 GPU 服务器里 CPU 角色与功耗目标的定制取舍。

## 封面文案

一颗没有公开规格的 Zen 3，为什么把 L2 做慢了？

## 分享文案

从 CPUID、缓存延迟与 30 线程带宽，观察 AMD EPYC 7J13 如何为 GPU 云实例调整 Zen 3。

## 备选标题

- EPYC 7J13：藏在 A100 云实例里的定制 Zen 3
- L2 延迟 20 周期：AMD 如何为 GPU 服务器调整 Zen 3

## 标签

AMD、EPYC、Zen 3、云计算、缓存、GPU 服务器

## 图片说明

- 共 3 张图，依次覆盖缓存延迟、单线程带宽与多线程带宽。
- 图 1 中 EPYC 7763 是常规 Zen 3 的对照。

## 发布前检查

- [ ] 3 张图全部显示且顺序正确
- [ ] 云虚拟机、30 线程/15 核测试条件保留
- [ ] 2.45 GHz 与约 3.24 GHz 的含义没有混淆
- [ ] 节能动机明确为解释，没有写成 AMD 官方结论
