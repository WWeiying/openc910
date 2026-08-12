# Intel Redwood Cove 微信公众号发布资料

## 正式发布信息

- 正式标题：Redwood Cove：小步前进，也仍然是前进
- 署名：Chester Lam；来源：Chips and Cheese；发布日期：2024 年 9 月 22 日
- 英文标题：Intel’s Redwood Cove: Baby Steps are Still Steps
- 原文/阅读原文：https://chipsandcheese.com/p/intels-redwood-cove-baby-steps-are-still-steps

### 摘要

Redwood Cove 没扩大 Golden Cove Backend，却用更快 BTB、64 KB L1I、192 项 IDQ、新 Fusion、64 项 L2 Miss Queue、LLC/AOP Prefetch 与 SMT 调优做了一次务实小改。

### 封面/分享

- 主标题：Redwood Cove；副标题：小步前进，也是前进
- 分享文案：容量不变如何进步？Redwood Cove 用 Fusion、Queue、Prefetch 和 Watermark 提高既有资源利用率，也展示 Meteor Lake 如何把系统大改与核心风险错峰。

### 备选标题

- 22 张图看懂 Redwood Cove
- Meteor Lake P-Core：Golden Cove 的第三年
- 不扩大 ROB，Intel 如何让 Redwood Cove 更高效

### 标签/栏目

- Intel Redwood Cove、Meteor Lake、SMT、Branch Prediction、Prefetch、SPEC CPU2017
- 栏目：移动处理器

## 图片、排版与后台

- 22 图，目录 `intel_redwood_cove_figures/`，01～22；封面建议 1/22；COS HTTPS。
- 正文 15～16 px，图注 12～13 px；显式保留“体系结构视角”。
- 后台标题同正式标题；作者 Chester Lam；原创关闭；AI 标识开启；阅读原文同上。

## 关键边界与发布检查

- Fast/Slow Predictor、永久 BTB/Op-cache Partition 均为测试解释，不写成确认实现。
- L1 BTB/Main BTB Latency/Throughput 分开；两 Taken/cycle 只限小 Loop。
- SPEC：GCC 14.2、native Flags、同 Core 两 Copy；Integer/FP 分别 17.6%/4.2%。
- AOP Test 被普通 OoO MLP 混入，不能宣称完全测出 Prefetcher。
- SMT Resource Sharing 为反推；Watermark 数值保留约数。
- 22 图、MIME、Pandoc、禁词、COS 200、母稿/WeMD 一致后发布。
