---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "intel_arrow_lake_system_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*Examining Intel’s Arrow Lake, at the System Level*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2024 年 12 月 4 日
> - 链接：https://chipsandcheese.com/p/examining-intels-arrow-lake-at-the

Core Ultra 9 285K 把 8 个 Lion Cove P-Core、16 个 Skymont E-Core、GPU、SoC Tile 和 Base Tile 组合成 Intel 第一代桌面多 Die 处理器。它最鲜明的特点是一组看似矛盾的数据：Compute Tile 到 SoC Tile 的带宽非常充裕，任意一组 P-Core 都能接近 DRAM 理论带宽；DRAM Load-to-use 却超过 100 ns，L3 也超过 80 周期。

![图 1：Arrow Lake 桌面处理器](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_arrow_lake_system_wechat_article_zh/acc13430c1c3de90_01_figure.jpg)

对照平台包括 Meteor Lake 笔记本，以及 AMD 提供、直接装入既有主板与 DDR5-5600 环境的 Ryzen 9 9900X。平台不同，因此数据用于理解拓扑与瓶颈，不是统一配置下的产品排名。

## 一、Compute、GPU、SoC 与 Base Tile

Arrow Lake Compute Tile 使用 TSMC N3B，GPU 独立成 Tile，只有四个 Xe Core；SoC Tile 用成本更低的 TSMC N6，负责 DRAM、慢速 I/O 与无需先进工艺的模块，并取消 Meteor Lake SoC 上的两颗低功耗 Crestmont。各 Tile 通过 Base Tile 上的 Foveros Die Interconnect（FDI）通信。

![图 2：Intel 早期多 Die 规划](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_arrow_lake_system_wechat_article_zh/8dc47f777f034506_02_figure.jpg)

AMD 自 Zen 2 也采用 Hub-and-spoke：CCD 通过封装走线连接 IOD，不需要 Base Die，连线距离更自由，适合服务器放置更多 CCD；代价是单 CCD GMI 链路没有跟上 DDR5 带宽。标准 2 GHz FCLK 下，单 CCD 约 64 GB/s 读、32 GB/s 写。

![图 3：Intel 与 AMD Chiplet 拓扑](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_arrow_lake_system_wechat_article_zh/1e9df54c86fc6893_03_figure.png)

![图 4：Zen 5 CCD 的读与 Non-temporal Write 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_arrow_lake_system_wechat_article_zh/815cffb85f14dd72_04_figure.png)

Intel Hot Chips 34 幻灯片称 FDI 约“2K Mainband Width”、2 GHz，Arrow Lake 约 2.1 GHz。若 2K 真指 2048 data bit，理论 256 B/cycle、约 512 GB/s，显然过度充裕；实际还要扣除 Address、Command、ECC 和方向划分，因此不能从一句话精确复算链路数据宽度。

![图 5：Foveros 与 FDI 规格](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_arrow_lake_system_wechat_article_zh/6ced27e6590d24ca_05_figure.jpg)

![图 6：Compute Tile 到 SoC Tile 链路](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_arrow_lake_system_wechat_article_zh/98ed428046a4703d_06_figure.jpg)

实际结果表明跨 Die 带宽不是瓶颈：读接近 DRAM 理论上限，写虽然略低，仍远高于 AMD 单 CCD，且没有写带宽减半。

![图 7：Arrow Lake DRAM 读写带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_arrow_lake_system_wechat_article_zh/465e41873feb0059_07_figure.png)

### 体系结构视角：Chiplet 链路要把带宽和延迟分开设计

宽并行 FDI 可以用很多短距离线降低每 Bit 能耗并提高聚合吞吐，但一次依赖 Load 仍要经历协议、跨 Tile、内存控制器与返回路径的固定流水级。流式负载可用大量并发请求摊薄这些阶段，指针追逐却只能串行等待。因此“接近理论带宽”与“超过 100 ns”完全可以同时成立。

## 二、DRAM：基线延迟高，60 GB/s 以后才显出带宽优势

Arrow Lake DRAM Load-to-use 超过 100 ns，明显差于单片 Raptor Lake。内存控制器在低流量下会进入省电状态；P-Core 活跃时通常快速退出，只有 E-Core 低负载更容易测到额外延迟。后续图使用 P-Core。

![图 8：Arrow Lake、Raptor Lake 与 Zen 5 的 DRAM 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_arrow_lake_system_wechat_article_zh/97a4b34cf902e322_08_figure.jpg)

用带宽线程制造 Noisy Neighbor，再让另一线程做延迟测试：在约 60 GB/s 以前，Zen 5 的低基线延迟仍更快；超过这一点，AMD 单 CCD-to-IOD 链路开始拥塞，Arrow Lake 的宽 FDI 才体现优势。

![图 9：带宽负载下的 DRAM 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_arrow_lake_system_wechat_article_zh/7885a730c2f276bb_09_figure.png)

*图 9：游戏等低线程延迟敏感负载此前很少接近 60 GB/s；图像处理等高度并行吞吐负载更可能受益。不能把峰值带宽优势直接等同于所有应用更快。*

## 三、Core-to-core：物理同 Die，不代表逻辑路径短

全部 CPU Core 位于 Compute Tile，Cache-to-cache Transfer 无需跨 Die。Skymont 还让同一 L2 Cluster 内直接处理一致性转移，因此测得延迟很好。

![图 10：Arrow Lake 核间延迟矩阵](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_arrow_lake_system_wechat_article_zh/e2f077058af3019b_10_figure.jpg)

Lion Cove P-Core 最坏核间延迟却接近 AMD 跨 CCD。Arrow Lake Ring 可能有约 13 个 Stop：8 个 P-Core、4 个 E-Core Cluster 和一个跨 Tile Stop；但 P-Core 间最差，说明 Ring 距离不是全部原因。

![图 11：BIOS 更新后的 Zen 5 核间延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_arrow_lake_system_wechat_article_zh/095b477d0eac434d_11_figure.jpg)

Lion Cove 有三层 Core-private Data Cache。请求核必然在私有层级 Miss；持有 Modified Line 的核心收到 Probe 后，还要定位数据并失效自身副本。多一层私有 Cache 可能增加检查与转发步骤。Lunar Lake 只有四核、短 Ring，Lion Cove 仍有很高核间延迟，也支持“逻辑一致性流程比 Die 边界更重要”的判断。

![图 12：Lion Cove 私有 Cache 与一致性路径](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_arrow_lake_system_wechat_article_zh/14978a07829cb9a6_12_figure.png)

*图 12：网页没有公开一致性状态机与 Probe Pipeline。三层私有 Cache 是解释之一，不是逐级串行检查的 RTL 证明。*

## 四、L3：36 MB 更大，却不一定更快

Arrow Lake 有 12 个带 Core 的 Ring Stop，每个对应 3 MB L3 Slice，合计 36 MB、12-way；与 Lunar Lake 单 Slice 容量和相联度相同。更长 Ring 与更多 Slice 让 P-Core L3 Load-to-use 超过 80 周期，Lunar Lake 约 52 周期；即使前者频率更高，实际纳秒延迟仍更差。

![图 13：Arrow Lake 36 MB 分片 L3](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_arrow_lake_system_wechat_article_zh/2beb98efb0d88975_13_figure.jpg)

![图 14：P-Core 的 L1/L2/L3 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_arrow_lake_system_wechat_article_zh/64e48d8dfeaf4912_14_figure.png)

Zen 5 每个 CCX 有独立 32 MB L3，服务核心少，延迟很低；但单线程只能使用本 CCX 的 32 MB，即使 9900X 全芯片有 64 MB。Intel 统一 36 MB 更容易共享容量，却付出更长访问路径。

![图 15：Arrow Lake 与 Zen 5 Cache 延迟/容量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_arrow_lake_system_wechat_article_zh/f861fd8c9f1001dd_15_figure.png)

单 P-Core L3 读约 54.2 GB/s，甚至没有超过九年前 Skylake i5-6600K 的约 59.5 GB/s。多核带宽测试又受总 L2 容量影响：285K 有 40 MB L2、36 MB L3，线程各读私有数组时，不存在“超出 L2 又主要落在 L3”的理想工作集。

![图 16：私有数组与共享数组的多核带宽方法](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_arrow_lake_system_wechat_article_zh/17ac1a9150bc26b5_16_figure.png)

为了降低 L2 命中干扰，测试让线程读取共享数据，可能在下游合并请求。Zen 5 的 L3 PMU 显示真实 L3 Hit 带宽与软件值接近，说明合并更可能发生在 L3 之后；Arrow Lake 当时尚无公开 PMU，无法同样验证。

![图 17：共享数组带宽的验证](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_arrow_lake_system_wechat_article_zh/e9b1f407cd8f18e0_17_figure.png)

多 Slice 可并行服务请求，因此 Arrow Lake 多核 L3 超过 1 TB/s，是 Meteor Lake 两倍以上；仍落后较老 Ryzen 9 3950X，更明显落后 9900X。Intel 用每 P-Core 3 MB L2、每 E-Core Cluster 4 MB L2 减少 L3 流量；AMD 只有 1 MB L2，因为 L3 更快。

![图 18：多核 L3 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_arrow_lake_system_wechat_article_zh/fea368d03a493963_18_figure.png)

![图 19：Arrow Lake P/E-Core 与 Ring L3](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_arrow_lake_system_wechat_article_zh/1950119b7991a4f0_19_figure.jpg)

*图 19：Lunar Lake Skymont 没有 L3；Arrow Lake 即使 L3 慢，也远好于直接面对高延迟 SLC/LPDDR5X。*

### 体系结构视角：Cache 层级是“容量—延迟—可共享性”的三角

AMD 分簇 L3 延迟低，却限制单线程可用容量；Intel Ring L3 全局共享、Slice 多核带宽高，却随 Stop 数增加延迟。更大 L2 能降低进入 L3 的频率，但又增加 L2 Hit Latency。没有一种结构能同时把三项做到极致。

## 五、频率与系统级结论

Arrow Lake 两颗优选 Lion Cove 可达 5.7 GHz，其余 5.5 GHz；全部 Skymont 可达 4.6 GHz。9900X 的 CCD0 全核约 5.6 GHz，CCD1 约 5.35 GHz。低线程调度时，操作系统需要识别 Core 性能等级，而不是只区分 P/E-Core。

![图 20：Arrow Lake 与 Zen 5 的核心频率分布](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_arrow_lake_system_wechat_article_zh/2fa69632ba20ec62_20_figure.png)

![图 21：Arrow Lake 多 Tile 封装](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_arrow_lake_system_wechat_article_zh/0eaf81fdb4da918d_21_figure.jpg)

Intel 正在从早期大单片桌面 CPU 转向可复用 Chiplet。Arrow Lake 力图保持“像单片一样”的均匀带宽，也成功避免 AMD 单 CCD 链路瓶颈；代价是 DRAM、L3 与部分一致性路径仍长。第一代桌面实现没有立即赢下所有指标，并不代表方向没有价值，但它也不能用“为未来铺路”掩盖当代负载的真实延迟。

最值得带走的结论是：Chiplet 的质量不能只数 Die，也不能只测一个内存峰值。依赖延迟、负载下排队、核间一致性、Cache 容量和各核心可见带宽必须共同评估。Arrow Lake 已有很强的吞吐基础，后续能否缩短固定路径，将决定 Lion Cove 这类大窗口核心能否真正发挥。

## 参考资料

- Chester Lam，*Examining Intel’s Arrow Lake, at the System Level*：https://chipsandcheese.com/p/examining-intels-arrow-lake-at-the
- Intel，Hot Chips 34 Multi-die/Foveros presentation
