# AMD MI300A Memory WeChat Publish Kit

## 正式标题

AMD Instinct MI300A：拆解一颗巨型 APU 的内存系统

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：Inside the AMD Instinct MI300A's Giant Memory Subsystem
- 日期：2025-01-18
- 阅读原文：https://chipsandcheese.com/p/inside-the-amd-radeon-instinct-mi300as
- 栏目：HPC / 异构计算 / 内存系统

## 摘要

24 个 Zen 4 核、228 个 CDNA3 CU、256 MB Infinity Cache 与 5.3 TB/s HBM3，被一张可跨四路封装的一致性网络连接起来。完整拆解 MI300A 的 CM/CS、NUMA 延迟、CPU 带宽、远端瓶颈，以及 SVM、零拷贝和 CPU/GPU atomic 通信。

## 封面文案

5.3 TB/s 带宽背后：MI300A 的巨大一致性网络

## 分享文案

Infinity Cache 命中为何仍超过 140 ns？CPU 为什么只能读到 212 GB/s？四路 MI300A 又怎样让 CPU/GPU 原子通信保持在数百纳秒？

## 备选标题

- MI300A 内存系统：高带宽 GPU 与高延迟 CPU 的交换
- 从 CM/CS 到 HBM3：MI300A 如何连接 24 核 CPU 与 228 CU GPU

## 标签

AMD、Instinct MI300A、Infinity Fabric、HBM3、NUMA、SVM、异构计算

## 图片说明

- 共 38 张图，全部按页面顺序保留。
- 图 3—17 讲一致性与延迟，图 18—28 讲 CPU/跨 node 带宽，图 29—33 讲 CPU/GPU 共享，图 34—38 讲封装与模块化。
- 图 13 是受 CMS 限制的原页面缩略图；本稿保持原始下载版本。

## 移动端排版与后台设置

- 文章较长，建议保留“一致性路径、NUMA、带宽、SVM、封装”五级导航。
- 延迟热图不要裁边；移动端允许点开原图。
- CM、CS、XCD、CCD、IOD 首次出现的全称不要删。

## 发布前检查

- [ ] 38 张图全部显示且顺序正确
- [ ] GIGABYTE/AMD 借测与独立测试边界保留
- [ ] 24 核、228 CU、256 MB、5.3 TB/s 等规格准确
- [ ] 140/227/477/559 ns 等不同路径没有混淆
- [ ] CPU 212 GB/s、RMW 314 GB/s、远端读 25—26 GB/s 条件准确
- [ ] remote bottleneck 与链路位置写为未知/推测
- [ ] SVM 不等于 zero copy、atomics 未正式宣告支持等限制保留
- [ ] core-to-core 测试只用于解释拓扑，没有外推应用性能
