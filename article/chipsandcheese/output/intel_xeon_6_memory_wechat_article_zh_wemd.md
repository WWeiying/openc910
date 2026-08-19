---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "intel_xeon_6_memory_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*A Look into Intel Xeon 6’s Memory Subsystem*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2025 年 9 月 26 日
> - 链接：https://chipsandcheese.com/p/a-look-into-intel-xeon-6s-memory

Xeon 6 用更彻底的 Chiplet 组织应对 AMD 与 Arm 的高核心数竞争：Compute Die 并排放置，两侧连接 I/O Die，最多三颗 Compute Die、128 核。与 AMD 的两层 CCX＋Infinity Fabric 不同，Intel 仍希望让 Mesh 跨越 Die 边界，使整颗处理器在 Cache 和一致性上保持“逻辑单体”。

测试来自 AWS r8i 云实例中的 Xeon 6 6985P-C。租用大型实例成本很高，因此这是一轮短测。实例每 Socket 配 1.5 TB Micron DDR5-7200，并运行 Intel 默认的 SNC3；云环境、未公开 SKU、频率管理和测试时长都限制了结论外推。

![图 1：历代 Xeon Scalable 的 Die 组织](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_xeon_6_memory_wechat_article_zh/758df6a592680812_01_figure.png)

*图 1：Xeon 从单片、Quadrant、双 Die 并排发展到 Xeon 6 的三 Compute Die＋两 I/O Die。核心规模扩大，跨 Die 互连也必须承担越来越多 L3、一致性和内存流量。*

## 一、96 颗 Redwood Cove 与 480 MB L3

6985P-C 没有出现在 Intel 公开 SKU 列表中。实例显示它拥有 96 颗最高 3.9 GHz 的 Redwood Cove，每核 2 MB L2。服务器版本保留 64 KB L1I，支持两条 512-bit FMA、每周期 2×512-bit Load＋1×512-bit Store，以及 AMX 矩阵指令。

![图 2：Xeon 6 Compute Die](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_xeon_6_memory_wechat_article_zh/4813234841df70a8_02_figure.jpg)

*图 2：Compute Die 用 Intel 3 工艺，只放核心、CHA/L3 Mesh 与内存控制器；低速 I/O 和加速器移到独立 I/O Die。每核 2 MB L2，单 Die 拥有四个内存控制器。*

每个 Mesh Stop 把核心与 CHA（Caching/Home Agent）连接在一起；CHA 包含 L3 Slice 和 Snoop Filter。6985P-C 有 120 个 2.2 GHz CHA，却只有 96 个启用核心，总 L3 达 480 MB。这可能意味着 Intel 可关闭核心而保留关联 Slice，但未公开布局不足以确认具体 Harvest 规则。

![图 3：Xeon 6 模块化 SoC 与 Mesh](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_xeon_6_memory_wechat_article_zh/e3917a285c841eb3_03_figure.jpg)

*图 3：三颗 Compute Die 通过 EMIB 物理连接，两侧再接 I/O Die。Die 边缘的 MDF（Modular Data Fabric）负责 Mesh 协议层，功能类似 AMD IFOP 的协议封装。*

实例还显示 80 个 2.5 GHz MDF Stop。Intel 没有公开完整 Mesh 平面图；文章提出一种可能：每条 Die 边界的每侧分布十个 MDF Stop。这只是根据计数做的拓扑猜测。

12 个内存控制器分布在三颗 Compute Die 的短边。SNC3 把物理地址空间分成三个节点，各自使用本 Die 的 L3 Slice 与四个控制器，使核心、Cache 和 DRAM 保持亲和。Xeon 6 也支持统一模式，但 AWS 选择了默认 SNC3。

### 体系结构视角：跨 Die Mesh 的目标比“能连通”更高

AMD CCD 先在簇内完成高带宽 L3 访问，再把 DRAM/I/O 请求交给较慢的 Infinity Fabric；Intel 则让一张 Mesh 同时承载 L3 查找、Snoop 和内存路径。这样可获得更大、跨更多核心共享的 Cache，却要求 Die 间链路具备接近片内网络的延迟、带宽与流控能力。

## 二、Cache 和 DRAM 延迟：容量换来了什么

Redwood Cove 的 L1D、L2 仍是 5、16 cycle，与 Meteor Lake 相同；频率较低使实际纳秒数更高。SNC3 下每颗核心可看到本 Die 的 160 MB L3，命中约 33 ns、约 130 cycle。

![图 4：Xeon 6 与 Meteor Lake 的 Cache 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_xeon_6_memory_wechat_article_zh/c933b480180be115_04_figure.png)

*图 4：核心私有层次基本延续 Redwood Cove，服务器从 L3 起明显不同。160 MB 本地池容量巨大，代价是约 33 ns 的命中。*

![图 5：Xeon 6、Emerald Rapids 与 Sapphire Rapids](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_xeon_6_memory_wechat_article_zh/3cb2e04a8b29f33f_05_figure.png)

*图 5：Xeon 6 相比 Sapphire Rapids 是容量升级且延迟接近；相较 Emerald Rapids，L3 和 DDR5-7200 DRAM 延迟却略退步。AWS 的 Emerald Rapids 未开 SNC，仍能以更低延迟访问逻辑统一的 320 MB L3。*

网页最初提到 MCRDIMM，随后依据 DIMM 料号更正：AWS 使用的不是 MCRDIMM，因此不能用该技术解释结果。

AMD Turin 呈现相反取舍：每颗 CCD 只有八核共享 32 MB L3，容量利用率会受跨 CCD 数据复制影响，低线程程序也只能分配本地 32 MB；但命中更快、带宽更高。即使用 3D V-Cache 扩展到 96 MB，单簇仍小于 Xeon 6 SNC3 的 160 MB。

![图 6：Xeon 6 与 AMD Zen 5 Server 的延迟对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_xeon_6_memory_wechat_article_zh/ab787c968802bd4e_06_figure.png)

*图 6：AMD NPS1 的 DRAM 延迟约 125.6 ns，优于 Xeon 6，即便 AMD 并未使用最强调本地性的 NPS4。Intel 将控制器放在 Compute Die 的理论本地优势没有在这台实例上体现。*

### 体系结构视角：末级 Cache 的“有效容量”取决于共享范围

32 MB 低延迟 L3 与 160 MB 高延迟 L3 不能只按容量或纳秒单独排名。前者适合工作集留在一个 CCD、追求快速命中；后者允许更多核心共享一份数据，减少复制和 DRAM 流量。应用需要观察的是 MPKI、共享程度和命中节省的平均周期，而不是参数表上的一列。

## 三、单核与整片带宽

AVX-512 让私有 Cache 带宽很高。单核从 L3 读取约 30 GB/s，略低于 Emerald Rapids；读改写几乎翻倍。Zen 的类似现象来自 Victim Cache：一次 L3 请求可同时带上 L2 Victim，从而一读一写。Intel 也可能采用类似数据通路，或分别设置查找与写回队列，短测无法区分。

![图 7：单核 Cache/DRAM 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_xeon_6_memory_wechat_article_zh/dd4ba2cd1b0a8cbf_07_figure.png)

*图 7：Xeon 6 私有层次吞吐很高，L3 纯读约 30 GB/s；Zen 5 的 L3 更快。不同颜色包含 Read、Add/读改写和 NT Write，不能把总读写字节当作纯读性能。*

单核 DRAM 纯读略低于 20 GB/s，低于 Zen 5；巨大 L3 能降低这个弱点的出现频率。读改写也显著提高可见总带宽。

![图 8：整片 Cache 与 DRAM 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_xeon_6_memory_wechat_article_zh/a0a5aea54497e056_08_figure.png)

*图 8：96 核和快速私有 Cache 使总 L1/L2 带宽远高于 Emerald Rapids 与低核心数 EPYC。L3 总带宽随核心数增长，却仍落后 AMD；本地 NUMA 放置下 DRAM 读取达到 691.62 GB/s。*

691.62 GB/s 明显高于 Emerald Rapids 的 323.45 GB/s，也高于 DDR5-5200 的 EPYC 9355P NPS1 约 478.98 GB/s。这里同时改变了控制器数量、内存频率、核心数和平台，不能只归因于 Mesh。

## 四、跨 Die：每跨一层多约 25 ns

Intel 用一致哈希把物理地址路由到 CHA。SNC3 看起来只在地址所属 Compute Die 的 L3 Slice 中分布，而不是让每个 Die Cache 全部 DRAM 地址；因此访问远端节点时，数据由远端 L3 缓存。

![图 9：本地、相邻与最远 L3 命中](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_xeon_6_memory_wechat_article_zh/53dc7676ec934df2_09_figure.png)

*图 9：本地约 33.25 ns，跨一颗 Die 约 57.63 ns，跨两颗接近 80 ns。每条边界增加约 24～25 ns。*

![图 10：远端 DRAM 与受载延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_xeon_6_memory_wechat_article_zh/7e2e5dc68f440b6d_10_figure.png)

*图 10：本地 DRAM 约 131 ns，相邻节点 157.44 ns，跨两边界 181.54 ns。受载后本地延迟逐渐升到约 300 ns，临近带宽上限才更陡地增加。*

跨 Die L3 带宽很高。用 96 MB 制造带宽负载、16 MB 运行延迟线程时，纯读接近 500 GB/s。若按“Con­ga Line”方向让节点 0 访问节点 1、节点 1 访问节点 2，并采用读改写，总量可超过 800 GB/s。

![图 11：跨 Die L3 带宽路径示意](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_xeon_6_memory_wechat_article_zh/a7bb0a8c7fa5b9b7_11_figure.png)

*图 11：蓝色表示核心位置，橙色表示数据所在 L3。超过 800 GB/s 是刻意顺应线性拓扑的合成测试，证明链路能力，却不是常规应用模式。*

单颗 Xeon 6 Compute Die 的片外带宽高于 AMD GMI-Wide CCD；但 AMD 每个 L3 都覆盖全 Socket 地址、Intel SNC3 的远端地址只缓存在远端 Die，两种流量语义并不完全可比。

### 体系结构视角：线性扩展最怕平均跨越数增长

三 Die 排成一线时，大部分路径只跨零到两条边界；继续增加 Compute Die 会提高平均跳数，让延迟和中间链路负载同时增长。可扩展办法包括增加 Die 内核心密度、改成二维拓扑或进一步分区，但每种选择都会影响小 SKU 复用、Cache 共享范围和功耗。

## 五、核间一致性延迟

核间测试让两个核心反复交换同一 Cache Line。Compute Die 内约 50～80 ns，跨 Die 只略增加。

![图 12：Xeon 6 的核间延迟矩阵](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_xeon_6_memory_wechat_article_zh/3f22a7dbcb030118_12_figure.jpg)

*图 12：测试内存分配在 NUMA 节点 0，因此节点 2 的核心即使彼此通信，也可能由节点 0 的 CHA 组织传输。最坏约 100～120 ns，仍优于 AMD 服务器跨 CCX 常见的 150～180 ns。*

Intel 的逻辑单体 Mesh 与 EMIB 在一致性路径上表现出优势；但矩阵同时取决于 Home Agent 位置，不能简化为纯粹的“核到核物理距离”。

## 六、单核性能与最终取舍

单 Copy SPEC CPU2017 Rate 估算显示，这颗 96 核 SKU 的单线程落后更强调每核性能的低核心数芯片；整数与 96 核 Graviton 4 接近，浮点领先约 8.4%。

![图 13：Xeon 6 6985P-C 的 SPEC CPU2017 单线程估算](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_xeon_6_memory_wechat_article_zh/0d420c99b347058e_13_figure.png)

*图 13：整数约 7.19、浮点约 10.54；Graviton 4 约 7.38/9.72。云平台、编译器和 ISA 不同，结果用于平台级观察，不是 Redwood Cove 与 Arm 核心的纯 IPC 对照。*

![图 14：Intel 对逻辑统一架构的说明](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_xeon_6_memory_wechat_article_zh/d3c7eed8bc6ed3df_14_figure.jpg)

*图 14：幻灯片原本展示 Emerald Rapids，但目标同样适用于 Xeon 6：Mesh 跨越 Die 边界，让所有核心访问共享 L3 与内存控制器。*

Xeon 6 的优势包括更大、更统一的 L3，更低的核间延迟，以及没有 CCD 边界上的窄链路。代价也很清楚：L3 本地就要约 33 ns，单核 L3 带宽甚至低于 Zen 5 单核 DRAM；在这台实例上，控制器位于 Compute Die 的 DRAM 延迟优势也没有兑现。

若关闭 SNC3、让三分之二 L3 请求跨 Die，文章按 `(2×57.63＋33.25)/3` 粗略估计平均约 49.5 ns。这只是基于当前三点延迟的推算，没有统一模式实机可验证，更不能当作测量值。

从这套设计可以看到五条主线：

1. Intel 与 AMD 都采用 Chiplet，却把高带宽共享层放在不同位置；封装形式相似，不代表系统结构相似。
2. Xeon 6 用跨 Die Mesh 购买共享容量和一致性优势，支付 L3 本地延迟与互连复杂度。
3. SNC3 既是优化，也是对大 Mesh 延迟的缓解；分区越强，“逻辑单体”的收益就越少。
4. 受载带宽证明 EMIB/MDF 很强，但日常应用价值仍取决于地址 Home、线程放置和共享模式。
5. 这颗 Redwood Cove 高核心数 SKU 的目标是整机吞吐；下一代 Lion Cove 服务器核心还会改变每核与系统级的平衡。

Chester Lam 没有给出“Intel 路线必然不值得”的结论。相反，Xeon 6 的工程实现相当令人印象深刻；真正的问题是，随着 Mesh 继续变大，维持一个单层逻辑单体所付出的延迟、功耗和验证成本，是否仍小于它带来的软件与共享 Cache 收益。

## 参考资料

- Chester Lam，*A Look into Intel Xeon 6’s Memory Subsystem*：https://chipsandcheese.com/p/a-look-into-intel-xeon-6s-memory
- Intel，Xeon 6 Compute Die / Modular SoC Architecture 公开资料
- AWS，EC2 R8i 实例资料
