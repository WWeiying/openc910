# Intel Crestmont 微信公众号发布资料

## 正式发布信息

- 正式标题：Crestmont：Meteor Lake E-Core 的渐进升级
- 署名：Chester Lam；来源：Chips and Cheese；发布日期：2024 年 5 月 13 日
- 英文标题：Meteor Lake’s E-Cores: Crestmont Makes Incremental Progress
- 原文/阅读原文：https://chipsandcheese.com/p/meteor-lakes-e-cores-crestmont-makes-incremental-progress

### 摘要

从 27 张图理解 Crestmont：六宽 Clustered Frontend、更大 BTB/TLB 与更快 FP 是渐进更新；真正的难题是同一核心同时服务 Ring E-Core 与无 L3 的 SoC Tile LPE-Core。

### 封面/分享

- 主标题：Crestmont；副标题：Meteor Lake E-Core 的渐进升级
- 分享文案：同一 Crestmont，接 Ring 与 Shared L3 时像 Laptop Core，放到 SoC Tile 后更像 Phone Core；Meteor Lake 的系统位置比核心改动更能决定表现。

### 备选标题

- 27 张图看懂 Meteor Lake E-Core
- Crestmont：六宽小核为何只算渐进升级
- E-Core 与 LPE-Core：同核心，不同命运

### 标签/栏目

- Intel Crestmont、Meteor Lake、E-Core、LPE-Core、Branch Prediction、Cache、Hybrid CPU
- 栏目：移动处理器

## 图片、排版与后台

- 27 图，目录 `intel_crestmont_figures/`，01～27；封面建议 1/2/27；COS HTTPS。
- 正文 15～16 px，图注 12～13 px；显式保留“体系结构视角”。
- 后台标题同正式标题；作者 Chester Lam；原创关闭；AI 标识开启；阅读原文同上。

## 关键边界与发布检查

- Structure Size 是微基准估计，小变化可能为误差。
- 6144 L2 BTB 更慢；Gracemont 未测同 64 B Case。
- Predictor 128 B/cycle Scan 来自 Intel Guide，无直接测量。
- E-Core/LPE Core Architecture 相同，系统 Interface/L3/Clock 不同。
- Bandwidth 必须保留 Active Core 触发降频条件。
- 双 Decode Cluster 服务单线程，不写成 SMT。
- 27 图、MIME、Pandoc、禁词、COS 200、母稿/WeMD 一致后发布。
