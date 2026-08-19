# Knights Landing WeChat Publish Kit

## 正式标题

Knights Landing：把 Atom 改造成 72 核 AVX-512 吞吐怪兽

## 基本信息

- 原作者：Chester Lam
- 后台作者栏：Chester Lam
- 首发平台：Chips and Cheese
- 英文题目：Knight’s Landing: Atom with AVX-512
- 日期：2022-12-08
- 阅读原文：https://chipsandcheese.com/p/knights-landing-atom-with-avx-512
- 栏目：处理器微架构 / Many-Core 与 HPC

## 摘要

Knights Landing 用 64 个启用小核、256 线程、每核双 512-bit FMA、mesh 与 16 GB MCDRAM，在 CPU 可编程性和 GPU 吞吐间取中间路线。单线程预测、取指和延迟都弱，但 SMT4 与约 350 GB/s 带宽能在合适 HPC 负载中发挥惊人性能。

## 封面文案

64 核、256 线程、350 GB/s：Atom 怎样变成 Xeon Phi

## 分享文案

从分支预测、72-entry ROB、AVX-512、TLB 到 MCDRAM/mesh/SMT4，完整拆解 Knights Landing 为吞吐牺牲了什么，又怎样在 Y-Cruncher 中击败新很多的桌面 CPU。

## 备选标题

- Xeon Phi Knights Landing：一颗更像 GPU 的 x86 CPU
- 2-wide 小核包着双 512-bit FMA：KNL 的独特取舍

## 标签

Intel、Xeon Phi、Knights Landing、AVX-512、SMT4、MCDRAM、Mesh、HPC

## 图片说明

- 共 42 张图，全部按英文页面顺序保留。
- 图 2—15 为前端，图 16—21 为后端，图 22—34 为存储/互连，图 35—38 为 SMT。
- 裸片标注为推测；图 28 的线程/SMT 配置异常必须保留。

## 移动端排版与后台设置

- 后台作者填写 Chester Lam。
- 摘要填后台，开启阅读原文和查看原图。
- 文章很长，保留前端、后端、MCDRAM、SMT、物理实现五个导航。

## 发布前检查

- [ ] 42 张图完整且顺序正确
- [ ] 64 启用核/256 线程与 72/76 最大口径未混写
- [ ] 409.6 理论、350 实测、85.6% 效率数据准确
- [ ] Flat/Cache/Hybrid/Quadrant/SNC4 区分清楚
- [ ] MCDRAM 高带宽但高于 DDR4 延迟的结论保留
