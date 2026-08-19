# Strix Halo 内存系统微信公众号发布资料

## 正式标题

Strix Halo 的内存系统：一颗大 iGPU 如何兼顾 CPU、GPU 与移动功耗

## 备选标题

- Strix Halo 深度实测：统一内存并不等于没有争用
- 256-bit LPDDR5X、Infinity Cache 与两颗 Zen 5 CCD
- 一颗“集成了 CPU 的 GPU”？Strix Halo 的系统取舍

## 作者与来源

- 作者栏：Chester Lam
- 首发：Chips and Cheese
- 英文题目：*Strix Halo’s Memory Subsystem: Tackling iGPU Challenges*
- 发布日期：2025 年 10 月 31 日
- 阅读原文：https://chipsandcheese.com/p/strix-halos-memory-subsystem-tackling

## 摘要

Strix Halo 把 16 核 Zen 5、大型 RDNA 3.5 GPU、32 MB Infinity Cache 与 256-bit LPDDR5X 放进移动设备。31 张图揭示共享内存的收益、延迟和 QoS 代价。

## 分享卡片文案

GPU 需要吞吐，CPU 害怕延迟。Strix Halo 的 Infinity Cache 会随驱动改变策略，CPU/GPU 同时争用时延迟又会超过 300 ns：统一内存的难题都藏在这里。

## 封面

- 主标题：Strix Halo
- 副标题：大 iGPU 的内存系统取舍
- 小字：Zen 5 / RDNA 3.5 / Infinity Cache / LPDDR5X
- 比例：2.35:1，AMD 橙红＋深灰，CPU/GPU 分居共享内存两侧

## 推荐标签与栏目

- 标签：AMD、Strix Halo、Ryzen AI MAX、Zen 5、RDNA 3.5、Infinity Cache、统一内存、移动处理器
- 栏目：处理器体系结构

## 文章结构

1. GPU 私有 Cache 与 Infinity Cache
2. 软件可变的 Cache Policy
3. Zero-copy 与 Copy Engine
4. CPU CCD 接口和 InFO_oS
5. 跨 CCX 一致性
6. CPU/GPU 带宽争用
7. 大 iGPU 的产品平衡

## 图片与排版

- 正文图片：31 张，按 01～31 上传
- 图 20～22 为矩阵，图 23～29 数据密集，务必检查压缩后可读性
- 图 5 是 2025-09-01 旧驱动历史行为，图注不能删

## 后台设置

- 作者栏：Chester Lam
- 阅读原文：https://chipsandcheese.com/p/strix-halos-memory-subsystem-tackling
- 原创声明：关闭
- AI 内容标识：开启后台相应标识

## 发布前边界

- 测试设备由 ASUS 提供；RX 7600 数据来自 Azralee。
- 网页 11 月 2 日补回 Cyberpunk 数据，当前稿基于修订版。
- GPU Endpoint 位宽、CS 位置影响和 Cache Policy 原因包含反推，不写成 AMD 官方实现。
- CPU/GPU PMU 与软件延迟口径不同；InFO_oS 只优化路径一段。
