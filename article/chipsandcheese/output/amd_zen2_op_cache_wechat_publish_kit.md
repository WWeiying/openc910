# Zen 2 Op Cache 微信公众号发布资料

## 正式发布信息

- 正式标题：Zen 2 的 Op Cache 到底带来多少性能与能效
- 署名：Chester Lam
- 来源：Chips and Cheese
- 日期：2021 年 7 月 3 日
- 英文标题：How Zen 2’s Op Cache Affects Performance
- 原始链接：https://chipsandcheese.com/p/how-zen-2s-op-cache-affects-performance

### 摘要

在 Ryzen 9 3950X 上用 MSR 关闭 Op Cache，再结合 PMU、得分和功耗模型，观察前端带宽、误预测恢复和后端等待如何决定实际收益。

### 封面与分享文案

- 主标题：Zen 2 Op Cache 的真实价值
- 副标题：超过 10% 性能，也可能提高总功耗
- 分享文案：Hit Rate 高不等于性能收益大；从 3DPM、Cinebench、Y-Cruncher、编译与 CPU-Z 看懂前端和后端的边界。
- 备选标题：关闭 Zen 2 Op Cache 会怎样；微操作缓存为何总能改善能效

### 标签与栏目

- 标签：AMD、Zen 2、Op Cache、CPU 前端、PMU、能效
- 栏目：CPU 微架构

## 图片与移动端排版

- 图片 8 张，目录 `amd_zen2_op_cache_figures/`，按 01～08 上传。
- 封面用 Decoder/Op Cache 双路径；柱图全宽。

## 后台设置与发布前检查

- 功耗来自 MSR，不是外部仪表；0.24 W 是隔离估算，0.375 W/核是上界。
- Intel 把 LSD 计为 Op Cache Hit；AMD/Intel PMU 来源并非完全同构。
- 所有测试除注明外为 3950X、关闭 Boost 固定 3.5 GHz。
- 核对 90%、50～60%、10%、88.5%/13.24 MPKI、96%/5.15 MPKI 与 8 张图。
- 后台作者栏填 Chester Lam，“阅读原文”使用完整链接；原创声明关闭，AI 内容标识按平台要求开启。
