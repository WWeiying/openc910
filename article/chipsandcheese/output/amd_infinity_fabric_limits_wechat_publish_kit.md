# Infinity Fabric Loaded Latency 微信公众号发布资料

## 正式发布信息

- 正式标题：把 AMD Infinity Fabric 推到极限：带宽、排队与“吵闹邻居”
- 署名：Chester Lam
- 来源：Chips and Cheese
- 日期：2024 年 11 月 24 日
- 英文标题：Pushing AMD’s Infinity Fabric to its Limits
- 原始链接：https://chipsandcheese.com/p/pushing-amds-infinity-fabric-to-its

### 摘要

用一条延迟线程对抗逐渐增加的带宽线程，比较 Zen 2、Zen 4 与 Zen 5 在 CCX、CCD、IFOP 和 DRAM 多级排队下的 Loaded Latency。

### 封面与分享文案

- 主标题：Infinity Fabric 极限测试
- 副标题：为什么 83 ns 会变成 700 ns
- 分享文案：平均 Xi 延迟约 200 ns，软件却看到 700 ns；35 张图解释多级队列、公平性、V-Cache 与 CCD 隔离。
- 备选标题：AMD 的“吵闹邻居”问题；从 Zen 2 到 Zen 5 的 Loaded Latency

### 标签与栏目

- 标签：AMD、Infinity Fabric、Zen 2、Zen 4、Zen 5、Loaded Latency、QoS
- 栏目：多核与互连

## 图片与移动端排版

- 图片 35 张，目录 `amd_infinity_fabric_limits_figures/`，按 01～35 上传。
- 封面画 CCX→Xi→IFOP→IOD→DDR 队列；所有曲线保留原宽。

## 后台设置与发布前检查

- 软件 Load-to-use 与 Xi 的 L3-miss 后延迟口径不同；平均会掩盖尾延迟。
- Zen 2 64 项、Zen 5 320 项是反推/推测；Zen 3 192 Pending Miss 为 AMD 图示。
- DDR5-8000 不是 AMD 推荐典型配置；三代平台不能作产品总排名。
- 游戏未逼近带宽极限，RawTherapee 才明显超过 200 ns。
- 核对 32/16 B/cycle、82～83/400/700 ns、59 GB/s、100 GB/s、71.7/142.77/285 ns 和 35 张图。
- 后台作者栏填 Chester Lam，“阅读原文”使用完整链接；原创声明关闭，AI 内容标识按平台要求开启。
