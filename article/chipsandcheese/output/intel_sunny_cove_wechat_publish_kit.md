# Intel Sunny Cove 微信公众号发布资料

## 正式发布信息

- 正式标题：Sunny Cove：被制程耽误的 Intel 大改一代
- 署名：Chester Lam；来源：Chips and Cheese；发布日期：2022 年 6 月 7 日
- 英文标题：Sunny Cove: Intel’s Lost Generation
- 原文/阅读原文：https://chipsandcheese.com/p/sunny-cove-intels-lost-generation

### 摘要

从 31 张图理解 Sunny Cove：Intel 十多年后首次加宽核心，全面扩充预测、乱序、AGU、Cache/TLB 与 AVX-512，却因 10 nm 延误和 14 nm Backport 没能完整接班 Skylake。

### 封面文案

主标题：Sunny Cove

副标题：被制程耽误的大改一代

### 分享文案

五宽 Rename、50% 以上乱序扩容、四 AGU、48 KB L1D、Client AVX-512——Sunny Cove 并不保守；真正失败的是面向 10 nm 调优的核心，没能在正确制程上准时铺开。

### 备选标题

- 31 张图看懂 Intel Sunny Cove
- Sunny Cove：架构很激进，产品为何失败
- 从 Ice Lake 到 Rocket Lake：制程如何拖垮一代核心

### 标签/栏目

- 标签：Intel Sunny Cove、Ice Lake、Tiger Lake、Rocket Lake、AVX-512、Cache、CPU Microarchitecture
- 栏目：经典处理器

## 图片、排版与后台

- 31 图，目录 `intel_sunny_cove_figures/`，01～31；Matrix/Curve 保留原尺寸；COS HTTPS。
- 封面建议图 1、2、30；正文 15～16 px，图注 12～13 px；保留“体系结构视角”。
- 后台标题同正式标题；作者 Chester Lam；原创关闭；AI 标识开启；阅读原文同上。

## 关键边界与发布检查

- Sunny/Ice/Tiger/Cypress Cove Core 相同但 Cache/Node/Clock 不同，不能混写。
- 测试来自多人/多时段，撰文者不持有 Sunny Cove CPU。
- 单层 Predictor、复杂 Store Compare 等是行为解释，不是 RTL 确认。
- Tiger Lake L2 正确值 1280 KB，保留网页 Revision。
- 18% IPC 为 Intel Claim；反事实 5+ GHz 全线产品保持推演语气。
- 31 图链接/MIME、Pandoc、禁词、COS 200、母稿/WeMD 归一化一致后发布。
