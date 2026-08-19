---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "intel_alder_lake_power_efficiency_wechat_article_zh"
---

> 英文标题：Alder Lake’s Power Efficiency – A Complicated Picture<br>
> 撰文：Chester Lam<br>
> 首发：Chips and Cheese，2022 年 1 月 28 日<br>
> 原始链接：https://chipsandcheese.com/p/alder-lakes-power-efficiency-a-complicated-picture

Alder Lake 在评测中常以很高功耗换取强劲性能：AnandTech 的 POV-Ray 测到 272 W 封装功耗，测试中的 8 个 Golden Cove P-Core 也能单独超过 168 W。但这些数字对应默认设置，而默认设置恰好把两种核心都推离了最佳能效区。

这里考察不同功率点下的 performance、平均功率和完成任务所耗总能量。每次只用 4 核，便于跨平台匹配，也比单线程更接近现代应用。Linux 上通过 `intel_pstate` 调整 `max_perf_pct`，负载前后读取核心电源平面 PP0 计数器得到能量。

计数器本身有边界：Intel 核心功耗值似乎包含 ring stop、L2 等共享组件，单个 Gracemont 的消耗会被共享功耗淹没；用完整四核集群可使测得值更多地反映核心活动，但仍不是纯执行单元功耗。

## 性能—功率曲线：E-Core 只在合适区间占优

![图 1：Intel 给出的 P-Core/E-Core 性能与功率关系](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_alder_lake_power_efficiency_wechat_article_zh/d539ed9657b80dac_01_figure.jpg)

图 1 的官方数据看起来对 E-Core 很不利：任何功率点都未超过 P-Core，似乎只剩面积效率优势。下面用具体负载复测。

![图 2：四核 libx264 向量化编码的性能—功率曲线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_alder_lake_power_efficiency_wechat_article_zh/1b67402ffc57146b_02_figure.jpg)

libx264 中超过 17% 指令是 256-bit 向量指令，而 Gracemont 会把它们拆成两个 128-bit 操作。结果是，只有四核总功率低于约 6 W、接近超轻薄本强节流区时，Gracemont 才超过 Golden Cove。

![图 3：四核 7-Zip 整数压缩的性能—功率曲线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_alder_lake_power_efficiency_wechat_article_zh/6996e4809abcc607_03_figure.jpg)

纯整数负载里局面反转：15 W 以下，Gracemont 以更低功率提供更高性能。若再加约 6 W uncore，这大致落在轻薄本功耗范围。

纵观全范围，Gracemont 超过每核 3—4 W 后扩展性迅速下降；i7-12700K 默认却把它推到这一甜点区之外。Golden Cove 也有边际收益递减，但高功率扩展更好；在 5 GHz 时，libx264 和 7-Zip 分别领先 Gracemont 107% 与 54%，符合 P-Core 追求峰值性能的定位。

## 完成任务的总能量

低功率不是高能效的充分条件。E-Core 的“E”指 efficiency，评价时应计算完成同一任务的焦耳数。

![图 4：libx264 在不同频率下完成任务的总核心能量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_alder_lake_power_efficiency_wechat_article_zh/ee9b55773a7ecc79_04_figure.jpg)

![图 5：7-Zip 在不同频率下完成任务的总核心能量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_alder_lake_power_efficiency_wechat_article_zh/09a52ebffe09e521_05_figure.jpg)

默认频率下 Gracemont 更省能，因为虽然慢，功率也低得多。但 Golden Cove 在 3—4 GHz 也很高效：整数负载用近似总能量更快完成；向量负载则因完成得快，即使瞬时功率更高，总能量仍低于 Gracemont。若主要目标是能效，让 Gracemont 超过 3.2 GHz 已没有意义，3.8 GHz 更像一个更差的 P-Core。

低于 3 GHz 时 Gracemont 尤其擅长整数负载；但两种核心低于 1 GHz 后能效都恶化，因为任务时间太长，静态功耗抵消降频收益。

### 体系结构视角：频率、压降和静态功耗共同塑造 U 形曲线

动态功耗大致随 `C × V² × f` 增长。冲击高频通常还要提高电压，因此曲线右端能耗陡升；过度降频后，固定的漏电、uncore 和时钟维持功耗会被更长执行时间积分，曲线左端也会上升。每种核心和负载都有自己的甜点区，而且向量宽度、IPC 与内存等待会移动这个区间。

所谓 race to sleep 只有在“提高性能带来的执行时间缩短”超过“电压和频率带来的功率增长”时成立。不能把它当作默认最高 boost 必然省能的通则。

## 与 Skylake 比：架构进步被默认频率吃掉

![图 6：libx264 中 Gracemont 与 Skylake 的性能—功率关系](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_alder_lake_power_efficiency_wechat_article_zh/aa27369fefb158e8_06_figure.jpg)

![图 7：7-Zip 中 Gracemont 与 Skylake 的性能—功率关系](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_alder_lake_power_efficiency_wechat_article_zh/0dacb62726c4abf0_07_figure.jpg)

libx264 中，四核总功率超过 20 W 后 Gracemont 与六年多前的 Skylake 接近，后者还可继续向高功率扩展；低功率区 Gracemont 才明显领先。7-Zip 中，Gracemont 在所有功率点都超过 Skylake，说明 E-Core 的整数宽度和效率提升更成功。

![图 8：libx264 中 Golden Cove 与 Skylake 的性能—功率关系](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_alder_lake_power_efficiency_wechat_article_zh/35bb6a4b9b9428ab_08_figure.jpg)

![图 9：7-Zip 中 Golden Cove 与 Skylake 的性能—功率关系](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_alder_lake_power_efficiency_wechat_article_zh/864f43ec8c2486a9_09_figure.jpg)

Golden Cove 在极低功率、每核约 1 W 左右时与 Skylake 很接近，可能为高功率性能牺牲了低压缩放；功率上升后则拉开差距。在近似功率下，两个测试分别领先 Skylake 42% 与 52%。

按相似频率比较，新架构几乎全面更高效；按默认频率比较，Skylake 反而可能更省能，因为 Golden Cove 为进入 4 GHz 后半段付出了过高电压。具体例子是：Skylake 3 GHz 以 5.71 FPS 完成编码，耗 6368 J；Gracemont 3.7 GHz 为 5.72 FPS，却耗 6711 J。半宽向量单元确实省面积和瞬时功率，但更大的向量单元若降频降压，可能以更少周期完成任务，最终同样高效。

## 与 Zen 2 比：先说明计数器限制

研究显示 AMD Zen 2 的 RAPL 能量数据可能是建模而非硬件直接测量；这不代表读数必然错误，却不适合像 Intel Haswell 以后那样用于精确优化整机功率。测试设备无法外接测量 CPU 功率，因此仍按原值展示：在每个物理核第一线程上，负载前后读取 `0xC001029A`（Core Energy Status）。

![图 10：桌面 Zen 2 与 Alder Lake 在 libx264 中的性能—核心功率](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_alder_lake_power_efficiency_wechat_article_zh/b63b3cdded1115b9_10_figure.jpg)

![图 11：桌面 Zen 2 与 Alder Lake 在 7-Zip 中的性能—核心功率](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_alder_lake_power_efficiency_wechat_article_zh/d56555f28a86b289_11_figure.jpg)

高功率区的桌面 Zen 2 像扩展性更好的 Gracemont，并且向量能力更强；但 Golden Cove 是更强的向量核心，Zen 2 只在 10—15 W、低到中 3 GHz 的窄区间能以同功率胜出。7-Zip 中 Zen 2 在整个可测范围都胜过两种 Alder Lake 核心，不过桌面 Zen 2 较早触及电压下限，无法继续缩到极低功率。

![图 12：移动 Renoir Zen 2 的 libx264 性能—功率曲线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_alder_lake_power_efficiency_wechat_article_zh/a6fb3c6cb583fc51_12_figure.jpg)

![图 13：移动 Renoir Zen 2 的 7-Zip 性能—功率曲线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_alder_lake_power_efficiency_wechat_article_zh/0f114ccfaccd28dd_13_figure.png)

移动 Renoir 与桌面 Zen 2 表现得像两个不同定位的核心：15 W 以下胜过两种 Alder Lake 核心，并在所有可比点胜过 Gracemont；但高功率扩展比桌面 Zen 2 更弱，更不及 Golden Cove。

![图 14：libx264 在相近频率下的总能量对比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_alder_lake_power_efficiency_wechat_article_zh/e3662f7b079cc6a1_14_figure.jpg)

![图 15：7-Zip 在相近频率下的总能量对比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_alder_lake_power_efficiency_wechat_article_zh/c4491424e03af612_15_figure.jpg)

按相近频率看，Zen 2 能效很强：Golden Cove 和 Gracemont 都要降至 2 GHz 以下，才可用与桌面 Zen 2 相近的能量完成编码。桌面 Zen 2 关闭 boost 时已到能效峰值，再降频反而增加总能量；Renoir 的低功率缩放则好得多。

这支持一种当时的产品判断：AMD 可以用同一 Zen 2 核心，通过调整 L3、物理实现和功率目标覆盖 P/E 两端，不必立即维护两套 ISA 兼容但微架构不同的核心。它是基于这些功率曲线的推论，不是永恒的产品规律。

### 体系结构视角：同一个 ISA 核心也能有截然不同的功率曲线

核心 RTL 只决定一部分结果。标准单元选择、阈值电压、布线目标、缓存大小、允许的最高频率和电源管理策略都会改变曲线。Renoir 与桌面 Zen 2 的差异说明，“是否采用异构核心”不是唯一的能效杠杆；同一微架构也可通过物理设计和 SoC 约束覆盖不同区间。

跨平台比较还要避免把 core power、package power 和墙上功率混用。本文主测试使用 PP0 核心平面，约 6 W uncore 只作为估计加入某些讨论；因此数字不等同于整机电池续航。

## 结语

i7-12700K 的默认策略优先绝对性能。Golden Cove 在 4 GHz 以下、尤其向量负载中非常高效；Gracemont 在低 3 GHz 的整数负载中很强，256-bit 负载则要降到 3 GHz 以下才显出优势。两种核心都能缩到低功率，但默认频率没有展示这种能力。

按 stock 评价，四个 Golden Cove 完成相同任务会比 Zen 2、甚至 Skylake 消耗更多能量；Gracemont 也被推过 3.5 GHz，越过自己的甜点区。这解释了 Alder Lake 为何同时得到“架构能效进步”和“整机功耗过高”两种看似冲突的评价：两者描述的是不同工作点。

最终结论不是小核无用，也不是大核天然低效，而是性能/功率曲线必须连同任务类型、频率、核心与 uncore 计量口径一起看。默认设置是用户最常见状态，却不是微架构能力的全部。
