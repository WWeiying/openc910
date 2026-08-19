# 给主板芯片组做微基准：多绕一颗芯片，PCIe 延迟增加多少：发布资料

## 正式标题

给主板芯片组做微基准：多绕一颗芯片，PCIe 延迟增加多少

## 基本信息

- 英文题目：Microbenchmarking Chipsets for Giggles
- 作者：Chester Lam
- 首发：Chips and Cheese
- 日期：2026 年 3 月 22 日
- 阅读原文：https://chipsandcheese.com/p/microbenchmarking-chipsets-for-giggles
- 后台作者栏：Chester Lam

## 摘要

用同一张 Nvidia T1000 从 GPU 访问 Host Memory，B650 单颗 PROM21 多约 570 ns，X670E 双 PROM21 多约 921 ns，Z890 PCH 多约 550 ns，老 Z170 反而只多 338 ns。现代芯片组不追求低延迟，是用途变化后的合理取舍。

## 封面与分享文案

- 封面：PCIe 插在芯片组上，会多出多少延迟？
- 分享：一颗 PROM21 或 Z890 PCH 都会增加约 550 ns，双芯片 X670E 接近 1 μs。这个数字很大，但对 SSD、NIC 往往又不重要。

## 备选标题

- 从 AM3+ 到 AM5，四代主板芯片组延迟实测
- CPU 直连与 PCH Slot：PCIe 路径差在哪

## 标签与栏目

- 标签：Chipset、PCIe、PCH、PROM21、Vulkan
- 栏目：平台与互连

## 图片与排版

- 共 18 张图，图 6、9 或 17 可作封面。
- Cache-hit Bandwidth 涉及未确认 Probe 机制，不宜用确定性措辞。

## 发布前检查

- OS、Driver、T1000 Gen3 x16 限制已写明。
- GPU→Host 为主，CPU→VRAM 仅作旁证。
- 18 张图按顺序可访问。
