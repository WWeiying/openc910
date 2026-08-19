# 为什么不能只凭 CPUID 相信一颗处理器的身份：发布资料

## 正式标题

为什么不能只凭 CPUID 相信一颗处理器的身份

## 基本信息

- 英文题目：Why you can’t trust CPUID
- 作者：Ryan Mull、Chester Lam
- 首发：Chips and Cheese
- 日期：2022 年 10 月 27 日
- 阅读原文：https://chipsandcheese.com/p/why-you-cant-trust-cpuid
- 后台作者栏：Ryan Mull、Chester Lam

## 摘要

AMD 的 Brand String 来自六个可写 MSR，CPU-Z、Geekbench 等工具读取后可以显示任意型号；虚拟机里 Hypervisor 更能重写全部 CPUID 视图。处理器名称是枚举接口，不是不可伪造的硬件身份证。

## 封面与分享文案

- 封面：CPUID 显示的 CPU 名称，为什么也能是假的？
- 分享：只改六个寄存器，再调频、裁核心，一张“新 SKU”跑分截图就能显得十分合理。CPUID 的真正信任边界，比一行 Brand String 复杂得多。

## 备选标题

- 从假 Ryzen 跑分看 CPUID 的信任边界
- CPU-Z 和 Geekbench 为什么会相信一个假型号

## 标签与栏目

- 标签：CPUID、MSR、Benchmark、虚拟化、处理器识别
- 栏目：x86 机制

## 图片与排版

- 共 7 张图，图 4、5 或 7 可作封面。
- 寄存器改写演示用于解释风险，结论聚焦验证方法。

## 发布前检查

- 原始撰文者为 Ryan Mull、Chester Lam。
- Bare-metal 与 Hypervisor 的信任边界已分开。
- 7 张图按顺序可访问。
