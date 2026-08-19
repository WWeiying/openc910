---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "intel_meteor_lake_dram_latency_update_wechat_article_zh"
---

> 英文标题：Update on Meteor Lake DRAM Latency Measurements<br>
> 撰文：Chester Lam<br>
> 首发：Chips and Cheese，2024 年 5 月 27 日<br>
> 原始链接：https://chipsandcheese.com/p/update-on-meteor-lake-dram-latency-measurements

Meteor Lake memory controller 也能像核心一样降频降压。测试机为 ASUS Zenbook 14 OLED，标称 128-bit LPDDR5X-7467，但空闲可降到 3200 MT/s；controller 还能从高性能 Gear 2（控制器为内存频率一半）切到 Gear 4（四分之一）。

![图 1：Meteor Lake 内存速率、Gear 与低功耗状态](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_meteor_lake_dram_latency_update_wechat_article_zh/07a6fde65aecaa6e_01_figure.png)

单链 pointer chase 刻意只保持一个 outstanding demand access。对 controller 来说流量很低，heuristic 合理地选择省电状态，却使最低延迟测试测到更高数字。这修正了此前把超 200 ns 主要归因于 LPDDR5X 与路径本身的解读。

## 用第二个核心制造带宽需求

Datasheet 称 heuristic 观察 memory bandwidth utilization 与 IA core stall。结果似乎不在意 E-Core stall：延迟测试中 E-Core 几乎全程 memory bound，仍超过 200 ns。但让另一核心持续读取固定 1 GB 工作集后，latency 明显改善；一个 P-Core 或 E-Core 的带宽需求已足以切高性能，又未把 queue 填到严重排队。

![图 2：不同发起核心与附加带宽负载下的 DRAM 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_meteor_lake_dram_latency_update_wechat_article_zh/492b323630b29d7a_02_figure.png)

Controller 可能监控 CPU Tile 与 memory controller 之间队列 occupancy；这是根据行为的推测。只有 LPE-Core 制造流量时不会切高性能：一颗 LPE-Core 尽力读带宽，另一颗 latency 仍超过 200 ns。

退出低功耗后，LPE-Core 为 175.3 ns，Compute Tile E-Core 约 153 ns。P-Core 单独测试已接近“E-Core+另一核带宽负载”结果，附加负载只小幅改善；heuristic 可能直接考虑 P-Core stall reason。

### 体系结构视角：延迟微基准会改变被测对象的工作状态

最小并发可避免 queueing，却也可能被 DVFS 判断为“无需高性能”。因此软件测到的是请求路径、controller P-state 与 queue occupancy 的共同结果。可靠测试应同时报告 memory data rate、Gear/controller clock、附加流量与核心类型，并扫 outstanding request 数；不能把一个 latency 数值当固定硬件常数。

## 对 Crestmont 文章的修正

此前指出 AMD Van Gogh/Phoenix 用 2 MB page 时保持 200 ns 内，Meteor Lake 更差。

![图 3：此前文章中的 APU 内存延迟对比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_meteor_lake_dram_latency_update_wechat_article_zh/600d198a543e8379_03_figure.png)

高性能状态下，Crestmont 也低于 200 ns；153 ns 与 Van Gogh Zen 2 大致同档。实际 controller 可能更低，因为用另一个核心制造几十 GB/s 会有请求排队，抬高测得 latency。

LPE-Core 的问题仍在，只是多了一层原因：没有 L3已经让每个 L2 miss 直达 DRAM，而低功耗策略又不因 LPE 流量提高 controller 状态。让 CPU Tile 醒来并制造流量可改善 memory latency，却违背 LPE-Core “不唤醒 Compute Tile”目标。

扩大 L2 是更直接办法，Atom 长期可支持 4 MB，先把 2 MB 翻倍；更激进是 SoC Tile 加 system-level cache。Firmware 也可能允许 LPE-Core 拉高 controller，但 175 ns 仍很残酷，效果有限。这些都是设计建议，不是 Intel 已宣布计划。

## 结语

Meteor Lake 超 200 ns 并非 memory controller 固有上限，而是单链低流量触发的省电状态。Compute Tile 制造带宽后，E-Core 约 153 ns，LPE-Core 175.3 ns；只有 LPE-Core 的流量不足以改变状态。

Intel 的选择有明确逻辑：LPE-Core 目标是最低整包功耗。代价也同样明确：无 L3与高 DRAM latency 叠加，使较强的 Crestmont 被限制为轻量后台核心。感谢 Andrei F. 指出 pin 到 LPE-Core 时的低 P-state，促成这组组合负载复测。
