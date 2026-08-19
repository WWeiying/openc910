---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "intel_rocket_lake_power_wechat_article_zh"
---

> 英文标题：Was Rocket Lake Power Efficient?<br>
> 撰文：Chester Lam<br>
> 首发：Chips and Cheese，2022 年 12 月 17 日<br>
> 原始链接：https://chipsandcheese.com/p/was-rocket-lake-power-efficient

与 Golden Cove 比，Rocket Lake 当然不省电：新架构加新工艺理应全面领先。

![图 1：Golden Cove 与 Rocket Lake 的性能—功率曲线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_rocket_lake_power_wechat_article_zh/78dd3def20428c79_01_figure.png)

图 1 说明 Golden Cove 在所有可测功率点都更快，但这不是最有解释力的比较。Rocket Lake、Skylake、Kaby Lake 都是 Intel 14 nm 的不同演进，放在同一工艺家族中更能看出 Cypress Cove 回移设计的价值。

测试每次启用 4 个线程；对核心数更多的 CPU 用亲和性固定到 4 核。与此前 Alder Lake 文章不同，这里主要展示封装功率，因为 L3、ring 和内存控制器等重要组件不在 Intel core power plane 中。后面的假想混合架构部分改用 core power，并明确说明原因。

## libx264：中等功率有效率，默认状态却冲到 147 W

libx264 进行 4K 视频转码，包含大量 AVX/AVX2，Rocket Lake 还可使用 AVX-512。

![图 2：Rocket Lake、Skylake、Kaby Lake 与 Golden Cove 的 libx264 性能—封装功率](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_rocket_lake_power_wechat_article_zh/b5f73a30d4ed1a95_02_figure.png)

30 W 以上，Rocket Lake 的 Cypress Cove 能以相同功率超过 Skylake；它也能继续加功率提高性能，直到 4 核封装功率高达 147 W，代价是极差效率。

![图 3：libx264 完成任务的总能量随频率变化](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_rocket_lake_power_wechat_article_zh/6576511913da809e_03_figure.png)

默认频率下，Rocket Lake 比 Skylake 快 71.5%，完成任务却接近两倍能量。3 GHz 中段的能效可追平 Skylake，最佳区约 2.5—3 GHz，与 Kaby Lake 3.5 GHz、Skylake 3 GHz 或 Golden Cove 4.2—4.5 GHz 相近。弱点是低于 30 W 后性能陡降，2.5 GHz 以下也不再改善能效。

图中 i5-6600K 在 3.6 GHz 后呈平线，是因为横轴绘制的最高 boost 来自单线程加法延迟；libx264 用满四线程时全核 boost 仍是 3.6 GHz，不是测试失效。

## 7-Zip：三代核心差距意外地小

7-Zip 几乎不使用向量单元，也不像 libx264 那样能稳定把 4 核全部压满。测试压缩一个 2.67 GB ETL 文件。

![图 4：7-Zip 压缩性能—封装功率](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_rocket_lake_power_wechat_article_zh/549296d79f43e253_04_figure.png)

Kaby Lake、Rocket Lake、Golden Cove 的差距不大；i5-6600K 的异常曲线原因未知，必须保留为未解释结果。Rocket Lake 仍在 35 W 以上超过 Kaby Lake，低功率缩放依旧很差。

![图 5：7-Zip 完成任务的总能量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_rocket_lake_power_wechat_article_zh/549457785ed4d922_05_figure.png)

Rocket Lake 最佳点仍约 2.5 GHz，能效接近第一代 Skylake。

### 体系结构视角：大核心降频，可能比小核心冲高频更省能

Cypress Cove 的高 IPC 允许在较低频率完成同样工作；降频伴随降压后，动态功耗可大幅下降。问题是回移到 14 nm 的物理实现存在电压下限和较高静态/uncore 占比，低于约 30 W 后不能继续有效缩放。因此“架构高 IPC 有利能效”与“Rocket Lake 默认很耗电”可以同时成立。

## 假想混合架构：Goldmont Plus 能补上低功率空白吗

Rocket Lake 时代的 14 nm Atom 不支持 AVX2，真实产品无法与 Cypress Cove 保持 ISA 对称。先忽略这一点，观察功率曲线是否互补。

![图 6：整数负载中 Gracemont 与 Rocket Lake 的可互补区间](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_rocket_lake_power_wechat_article_zh/7ac97f5a1d94eb59_06_figure.png)

图 6 用更新的 Gracemont 示意：整数工作负载确实存在小核以同功率提供更高吞吐的区间。

假设 Goldmont Plus 能用微码支持 AVX-512，再以 core power 比较。之所以切换口径，是 Celeron J4125 的 uncore 功耗很低，直接比较 package power 会把 SoC 差异当成核心差异。

![图 7：libx264 中 Rocket Lake、Skylake 与 Goldmont Plus 的核心功率曲线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_rocket_lake_power_wechat_article_zh/8d841717e20eb46d_07_figure.png)

Rocket Lake 无法进入极低功率，Goldmont Plus 又无法向高功率扩展，两者之间留下明显功率和性能空档，Skylake 恰好落在中间。

![图 8：7-Zip 中三种核心的核心功率曲线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_rocket_lake_power_wechat_article_zh/76acc6f87f5a58cb_08_figure.png)

7-Zip 重复相同格局，但 Goldmont Plus 在四核总 core power 低于 5 W 时略好于 Skylake。曲线说明它可作为 Rocket Lake 的 little core，甚至形成 Cypress Cove“prime”、Skylake“mid”、Goldmont Plus“little”的三级组合。

现实障碍是 ISA 不一致。Lakefield 的 Tremont 不支持 AVX，迫使软件放弃 Sunny Cove 的 AVX；Alder Lake 的 Gracemont 不支持 AVX-512，又使 Golden Cove 的该能力无法对普通软件开放。假想 Rocket Lake 混合组合也会遇到同样问题，所以这里是机制思想实验，不是可直接实现的产品方案。

### 体系结构视角：异构核心首先要共享可迁移的软件状态

操作系统可能在任意调度点迁移线程。若大核执行过小核不支持的指令，迁移就会破坏透明性；要么隐藏大核 ISA 能力，要么做复杂的线程约束和状态管理。混合架构不仅要匹配性能/功率曲线，还要统一 ISA、异常模型、性能计数器和可保存状态。

## 结语

Rocket Lake 与 Alder Lake 一样，在默认状态下都因追求峰值性能而低效；作为高 IPC 核心回移到旧 14 nm 的产品，Rocket Lake 更严重，也缺少 Alder Lake 那样的低功率缩放能力。

但在四线程、30 W 以上的中等桌面功率区间，它是效率最高的 Intel 14 nm 设计之一。它说明即使没有新工艺，更大、更高 IPC 的核心在合理降频后仍可提升能效。遗憾的是，这个优势只存在于狭窄功率窗口；低于 30 W 的空白原本适合小核，真实硬件却受 ISA 不对称阻挡。
