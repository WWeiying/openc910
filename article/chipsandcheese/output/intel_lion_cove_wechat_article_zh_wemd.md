---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "intel_lion_cove_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*Lion Cove: Intel’s P-Core Roars*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2024 年 9 月 27 日
> - 链接：https://chipsandcheese.com/p/lion-cove-intels-p-core-roars

近几代 Intel 移动处理器的变化，不只是换一颗核心。面对 AMD、Qualcomm，以及相对次要但同样存在的 Apple 压力，Meteor Lake 把计算、GPU、SoC 与 I/O 拆到不同 Tile；Lunar Lake 又把 CPU、GPU 和内存控制器集中到一颗 Compute Tile，让第二颗 Platform Controller Tile 只处理低速 I/O，并把 LPDDR5X 放进封装。系统结构连续重排，承担单线程性能的 P-Core 却一直保持相对稳定：Redwood Cove 基本延续 Golden Cove，只做了有限调整。

Lion Cove 打破了这种稳定。它把前端扩到八宽，扩大微操作 Cache，重新拆分整数与浮点调度，增加执行端口和寄存器资源，还在传统 L1D 与 L2 之间塞入一层 192 KB Cache。Lunar Lake 中的 Core Ultra 7 258V 由此成为观察这颗核心的第一批窗口。

![图 1：Lion Cove 所处的代际位置](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/e2566ad9173bb80c_01_lion_cove_generation_overview.jpg)

*图 1：Lion Cove 接替 Meteor Lake 中的 Redwood Cove，是 Golden Cove 以来幅度最大的一次 P-Core 改造。文章把它与 Redwood Cove、AMD Zen 5 放在移动平台上比较，观察前端、后端与存储层次的共同变化。*

## 测试平台与结论边界

Lion Cove 来自 ASUS Zenbook S 14 UX5406SA，处理器为 Core Ultra 7 258V；Redwood Cove 来自 Core Ultra 7 155H，Zen 5 来自 Ryzen AI 9 HX 370。ASUS 提供了 Lion Cove 与 Zen 5 的测试机，Meteor Lake 机器则由 Chips and Cheese 自购。三台机器的工艺、频率、Cache、内存、固件和功耗策略均不相同，因此图表首先反映“核心加整个平台”的效果，不能直接当作严格同频 IPC 对照。

微基准反推出的调度器、寄存器文件、ROB、BTB 和 RAS 容量都带有方法边界。没有 Lion Cove RTL，也没有每一项内部信号或官方物理实现作为旁证；文中用“约”“可能”“推测”的地方，应按证据强度理解，而不是改写成 Intel 已确认的模块参数。

SPEC CPU2017 在这篇文章中重新以 `-O3 -mtune=native -march=native` 编译，因此不能与 Chips and Cheese 更早文章中的 SPEC 数字直接拼接。测试图标注 GCC 14.2 和 Rate-1 Estimated Score，但没有完整披露输入、运行次数、误差、功耗约束与稳态频率。小幅差距只能谨慎解释，明显的代际提升才是更可靠的观察。

下文沿着文章的测试顺序展开。图 10、17、19 保留网页给出的英文正式图注意思，其余中文图注用于解释图中信息；各节中的“体系结构视角”则把测量结果放回处理器机制中理解，不把通用分析混成 Lion Cove 已确认实现。

## 更短的环形总线，以及减半的 L3

Intel 从 Sandy Bridge 起长期以环形总线连接核心、末级 Cache 与系统代理。Lunar Lake 继续使用 Ring Bus，但环上只剩四颗 Lion Cove 与四个 L3 Slice；Skymont E-Core 集群没有直接挂在这条 L3 环上。每个 Slice 为 3 MB，总容量 12 MB，只有 Meteor Lake 24 MB 的一半。

![图 2：Lunar Lake 的 Ring Bus 与 L3 组织](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/8a317e4167dd0fc9_02_lunar_lake_ring_bus.png)

*图 2：四颗 Lion Cove 与四个 3 MB L3 Slice 构成更短的环。缩短物理距离和减少环上节点有助于降低平均访问延迟，但容量减少会提高大工作集进入 DRAM 的概率。Skymont 的路径不同，不能把这张图当作全部核心共享 12 MB L3。*

更短的环确实让 L3 延迟下降。与 Meteor Lake 相比，Lion Cove 访问共享 L3 的周期和绝对时间都有改善；AMD Zen 5 的本地 L3 仍更快，但差距已经缩小。这里同时包含核心频率、互连距离和 L3 组织的影响，不能把全部收益只归给某一个变量。

![图 3：Lion Cove、Redwood Cove 与 Zen 5 的 Cache/内存延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/326410bb43c31297_03_l3_latency.png)

*图 3：曲线从私有 Cache 平台进入共享 L3，再进入内存区间。Lion Cove 的 L3 明显优于 Redwood Cove，Zen 5 仍维持更低的本地 L3 延迟。台阶位置同时反映容量，纵轴则包含核心周期与平台频率。*

Lunar Lake 把内存控制器放到 Compute Tile，并使用封装内 LPDDR5X。简单随机内存延迟约为 131.4 ns；在带宽负载存在时，图中最低约为 112.4 ns。Strix Point 的简单结果约 128 ns，在中等并发负载下两者接近误差范围。

![图 4：带宽压力下的 DRAM 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/6bade9a2ddd020ef_04_loaded_dram_latency.png)

*图 4：横轴逐步增加并发内存负载，纵轴观察随机访问延迟。Lunar Lake 在一段中等负载下保持得不错，但这不是纯核心属性：封装内 LPDDR5X、内存控制器、NoC、预取器和功耗管理都会参与结果。*

![图 5：Lunar Lake 的封装与内存布局](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/3226a0a26a297e89_05_lunar_lake_package.jpg)

*图 5：CPU、GPU、NPU 与内存控制器集中在 Compute Tile，LPDDR5X 封装在处理器旁。缩短外部走线有利于能效和带宽，但不会消除 DRAM 阵列、控制器排队与一致性路径本身的延迟。*

系统中还有 8 MB Memory Side Cache。Lion Cove 访问它大约需要 30 ns，位置更接近内存侧而非核心侧。其主要意义是为 NPU、显示和其他 SoC 客户端缓冲流量，而不是充当 P-Core 的常规末级 Cache。

![图 6：8 MB Memory Side Cache 的访问延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/c0734db1cd6333f4_06_memory_side_cache_latency.png)

*图 6：该缓存形成区别于 P-Core 私有 Cache 和 L3 的另一段延迟平台。约 30 ns 的访问成本说明它不适合取代低延迟 CPU Cache；其价值更接近减少外部 DRAM 流量与提高共享客户端能效。*

LPDDR5X-8533 给出了很高的封装带宽。四颗 Lion Cove 的读取带宽达到 94.87 GB/s，高于 Meteor Lake 全部核心的 83.02 GB/s、其 CPU Tile 的 77.77 GB/s，以及 Strix Point 全部核心的 79.91 GB/s；Snapdragon X Elite 的十二核结果为 116.33 GB/s。四颗 Zen 5 所在集群约 61.74 GB/s。

![图 7：多核 DRAM 读取带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/926d415985df3beb_07_multicore_dram_bandwidth.png)

*图 7：四颗 Lion Cove 已能把平台带宽推到 94.87 GB/s。不同柱状项的核心数、内存制式、控制器和整机功耗都不一致，适合回答各平台能把自身内存系统推到什么程度，不适合作为单核 LSU 吞吐排名。*

### 体系结构视角：系统延迟不是“核心到 DRAM”的一根线

一次 LLC miss 要穿过核心的 miss 队列、L3 Slice、环形互连、系统代理、内存控制器和 DRAM。轻载延迟取决于固定路径，加载带宽后还会叠加队列等待、bank 冲突和调度策略。因而“短环更快”和“封装内存更近”都成立，却不意味着所有工作负载都按同一比例加速。

如果要判断瓶颈落在哪里，应把 L2/L3 miss、占用中的 MSHR、环或 NoC 排队、内存控制器队列深度、DRAM 读写带宽与核心停顿周期串起来看。只有在 LLC miss 增多且内存侧队列同时抬升时，才有充分理由把下降归到内存层次；若前端或执行端已经缺货，再高的 DRAM 带宽也可能闲置。

## 在 L1D 与 L2 之间再放一层 Cache

Lion Cove 最醒目的变化之一，是 Intel 对数据 Cache 层级重新命名。公开资料把最靠近执行端的 48 KB Cache 称为 L0，把新的 192 KB、9-cycle Cache 称为 L1，再往下才是 2.5 MB L2。为了便于与历代核心比较，文章仍把 48 KB 叫作 L1D，并把 192 KB 层称为 L1.5。

第一层数据 Cache 的命中延迟从 Redwood Cove 的 5 周期降到 4 周期。L1.5 在测试中约 8.97 周期、容量 192 KB；其绝对访问时间约 1.88 ns。文章拿它与 Cortex-A72 约 1.75 ns 的 L2 作直观参照，但两者的工艺、频率、端口和设计目标差异很大，不能据此判断孰优孰劣。

![图 8：历代 Intel P-Core 的 L2/L3 容量与延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/bb06434e3b33960d_08_l2_capacity_latency.jpg)

*图 8：Skylake 的 L2 为 256 KB/12 周期，Willow Cove 为 1.25 MB/14 周期，Redwood Cove 为 2 MB/16 周期，Lion Cove 增至 2.5 MB/17 周期；Lion Cove 设计还支持最高 3 MB。容量增加的代价通常是地址译码、bank 与布线更复杂。*

![图 9：Lion Cove 的多级数据 Cache 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/e2b15673f9411940_09_l1_l15_l2_latency.png)

*图 9：Lion Cove 的第一层约 4 周期，192 KB L1.5 约 8.97 周期，2.5 MB L2 约 17 周期；Redwood Cove 的 L1D 约 5.08 周期、L2 约 16.20 周期，Zen 5 L2 约 14.02 周期。Lion Cove 用额外层级换取更低的平均 L1 miss 代价。*

![图 10：Lion Cove 的四级数据层次](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/0c629a3f8fec18e0_10_cache_hierarchy.jpg)

*图 10：网页正式图注意思是“这可真有不少 Cache 层级”。从 48 KB L1D、192 KB L1.5、2.5 MB L2 到共享 L3，Lion Cove 在核心附近建立了更细的延迟梯度。层级越多，命中路径、替换、预取与一致性管理也越复杂。*

L1.5 的读带宽没有超过约 32 B/cycle；读改写模式可以更高，但仍远低于 48 KB L1D。L2 则在只读和读改写测试中都维持约 32 B/cycle。也就是说，新增层级的主要目标是降低 L1 miss 的平均延迟，而不是复制 L1D 的极高端口带宽。

![图 11：Lion Cove 私有 Cache 的带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/e7a3f45c3e0e93c2_11_private_cache_bandwidth.png)

*图 11：最靠近执行端的 L1D 具有最高字节吞吐；L1.5 只读约在 32～40 B/cycle 范围，读改写峰值约 54.64 B/cycle；L2 约 32 B/cycle。不同曲线混合了 Load、Store、回写和预取行为，不能只用单一峰值推导 SRAM 端口数。*

单核访问共享 L3 时，Lion Cove 只读略高于 10 B/cycle，低于 Redwood Cove 约 16 B/cycle；读改写约 17～18 B/cycle。Lion Cove 的 L2 miss 跟踪容量从 64 增至约 80 项，有助于用更多并发请求弥补单请求带宽或延迟。Zen 5 的 L2 到 L3 可在两个方向各达到约 32 B/cycle，读改写总流量接近 64 B/cycle；不过图中 Zen 5 约 5.15 GHz，Lion Cove 约 4.8 GHz，按 GB/s 看还叠加了频率差。

![图 12：L3 与 DRAM 区间的带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/360ef6ef67f354c0_12_l3_bandwidth.png)

*图 12：Lion Cove 在 L3 区间的只读约 50.01 GB/s、读改写约 82.50 GB/s；Zen 5 对应区间明显更高，图中读取约 163.62 GB/s、读改写约 308.16 GB/s。进入 DRAM 后，平台内存系统而非单个 L3 端口成为主导。*

### 体系结构视角：L1.5 是延迟保险，不是免费的带宽层

增加 L1.5 的核心问题是：能否用一小块、较快的存储接住足够多的 L1 miss，从而避免支付完整 L2 延迟。收益取决于 48～192 KB 工作集的局部性、L1.5 的命中率和访问是否能与前端执行重叠；若工作集直接越过 192 KB，额外标签查询反而可能增加控制复杂度。

异常或阻塞时，Load 会占住队列等待对应 Cache 层级返回，依赖它的微操作保持未就绪；Store 则还涉及地址、数据、顺序和退休。若 miss 很多却只有少量并发槽位，宽后端仍会因 Load Queue 或 miss 队列耗尽而停住。验证这一设计应把各层命中率、平均 Load 延迟、L2 miss queue full、并发 miss 数和内存停顿周期放在一起，而不是只比较 4/9/17 这三个延迟数字。

## 后端重组：整数与浮点分开排队

Pentium Pro 以来，Intel 长期使用统一调度器。Skylake 把地址操作分离，Sunny Cove 又进一步拆出内存调度，Golden Cove 调整了整体组织。Lion Cove 继续向分区化发展：整数与 FP/向量调度器彼此分开，对应的寄存器重命名资源也更独立，整体布局更接近 AMD Zen 的思路。

![图 13：Lion Cove 调度器重组](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/c0c3e493a3eb3b85_13_scheduler_reorganization.png)

*图 13：整数、FP/向量与内存操作进入不同调度域。拆分可缩短唤醒选择与旁路网络，但每个分区只能使用自己的容量和端口；工作负载偏斜时，另一边的空闲条目不能自动借来。*

Lion Cove 的整数调度容量约 97 项，FP/向量约 114 项，内存约 62 项；Redwood Cove 的对应资源更小。作为对照，Zen 5 约为整数 88、FP 76、内存 58。仅整数与 FP 两类相加，Lion Cove 已能容纳超过 200 个等待执行的数学操作。

![图 14：调度器容量比较](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/f9384a721074126f_14_scheduler_capacity.jpg)

*图 14：Lion Cove 的三个主要调度域分别约为 97、114、62 项，均大于图中的 Zen 5 对照。容量并不等于每周期吞吐：微操作还必须已经取得源操作数，并且存在可用的匹配端口。*

调度器只接纳已经进入执行候选集合的操作，前面还有不参与唤醒选择的队列。指令可以在这些队列中等待资源，但不能直接争抢执行端口。因此，大量“总条目”只有在分配、重命名和调度入口都顺畅时才能转化为可用窗口。

Lion Cove 把执行端口从 Redwood Cove 的 12 个增加到 18 个。标量整数侧多了一条 ALU 路径；内存侧增加第三条 Store 地址生成路径，但持续 Store 吞吐仍约为每周期两条。FP/向量侧从三条主路径增至四条，其中两条可做 FMA/乘法，另两条偏向加法；四条都能处理向量整数加法。

![图 15：Lion Cove 的 18 个执行端口](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/c7375e90ce159741_15_execution_ports.png)

*图 15：端口数增长覆盖整数、分支、FP/向量和地址生成。端口图表达的是“哪些操作可以去哪里”，不代表每条路径都有完全相同的位宽与能力；共享乘法器、回写端口或寄存器读口仍可能形成二级瓶颈。*

Lion Cove 的全宽向量整数加法可以单周期完成，与较短向量相同。FP 非规格值仍是一个明显慢路：规格化输入产生非规格化输出时，测试到约 132 周期，Redwood Cove 约 124 周期；Skymont 和 Zen 在同类测试中没有这样的长惩罚。

### 体系结构视角：分区调度是在时序、面积与利用率之间下注

统一调度器让任意空闲条目和端口更容易共享，但条目越多，比较源操作数、广播结果和选择最老就绪操作的网络就越难在高频下收敛。拆分可以缩短关键路径、降低广播能耗，也能按整数和向量的需求分别扩容；代价是资源碎片化。

判断分区是否失衡，可以看各调度域 full 周期、ready-but-not-issued 操作数、端口利用率和分配停顿原因。如果 FP 队列已满而整数队列空闲，增加总条目没有意义；如果队列并不满却持续等待，则更可能是依赖链、端口能力或回写带宽限制。

## 更大的在途窗口，但资源增长并不整齐

微基准看到 Lion Cove 约 576 项 ROB，高于 Redwood Cove 的 512 和 Zen 5 的 448。它的整数物理寄存器约 290 项、FP/向量寄存器约 406 项、Mask/MMX/x87 类资源约 166 项；Redwood Cove 约为 280、332、158，Zen 5 约为 240、384、146。

Load Queue 约 189 项，Redwood Cove 约 192 项，Zen 5 的同类测试约 202 项但无法精确确定；Store Queue 则约 120、114、104 项。分支跟踪容量增长更明显：Lion Cove 约 180，Redwood Cove 约 128，Zen 5 约 96。

![图 16：ROB、寄存器与 Load/Store 队列容量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/e5cc2565bc443276_16_backend_resource_capacity.jpg)

*图 16：Lion Cove 把 ROB 扩至约 576 项，FP 寄存器和分支资源增长尤其明显；整数寄存器与 Load Queue 的变化较小。条目来自阻塞退休类微基准，只代表特定构造下可见容量，不是 Intel 公布的晶体管级结构。*

ROB 只增长 12.5%，不及 Golden Cove 当年的约 45%，也不及 Zen 5 相对前代约 40% 的扩张。分支资源增长超过 40%，FP 寄存器也明显扩容；整数寄存器只多不到十几项，Store Queue 仅略增，Load Queue 甚至没有明显增加。这种不均衡说明 Lion Cove 并非机械地把所有结构按同一比例放大，而是在预期负载与面积成本之间重新配比。

客户端 Lion Cove 不提供 AVX-512，因而图中 Mask 相关资源无法通过 AVX-512 掩码直接探测。MMX/x87 可能与这套物理资源别名，测试由此只能看到近似容量；扩大 FP 与 Mask 资源或许也为更完整的向量实现留下空间，但现有结果不能证明客户端核心内部保留了可用 AVX-512 数据通路。

## Store Forwarding：快路很快，重叠失配仍然昂贵

x86 要维持内存顺序。年轻 Load 在执行时必须检查更老的 Store：若地址与大小匹配，可直接从 Store Queue 转发数据；若关系不清或部分重叠，就需要等待、重放或走更慢的合并路径。

![图 17：Lion Cove 的 Store-to-Load Forwarding 矩阵](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/a88b3f2ec9d0daa2_17_store_forwarding_matrix.png)

*图 17：网页正式图注说明测试方法来自 Henry Wong 的 x86 Memory Disambiguation 微基准。矩阵按 Store/Load 偏移展示延迟：完全覆盖、被包含和部分重叠会落入不同路径。方法参考：https://blog.stuffedcow.net/2014/01/x86-memory-disambiguation/*

地址和大小完全匹配时，Lion Cove 可以每周期处理两次转发，依赖链几乎不增加额外延迟。Load 完全包含在更大的 Store 内时，Lion Cove 约需 8～9 周期，慢于 Golden Cove 的 5～6 周期，也慢于 Zen 5 的约 7 周期。部分重叠时，Lion Cove 约 19 周期，Golden Cove 约 19～20，Zen 5 约 14。

![图 18：不同 Store Forwarding 情形的延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/2c5b4d59340c624d_18_store_forwarding_latency.jpg)

*图 18：精确匹配是零额外延迟快路；Contained 模式为 Lion Cove 8～9、Golden Cove 5～6、Zen 5 约 7 周期；部分重叠分别约 19、19～20、14 周期。慢路可能涉及等待 Store 可安全退休或重新读取，但仅凭延迟不能唯一确认内部协议。*

独立未对齐 Load 在 Lion Cove 和 Golden Cove 上可以每周期一条，Zen 5 同类测试为三个周期完成四条；未对齐 Store 在 Lion Cove 与 Golden Cove 约每两周期一条，Zen 5 可做到每周期一条。跨越 64 B Cache line 会让 Lion Cove Store 再增加约一个周期；Load 处理更好，但 AMD 在这些组合中仍占优势。

### 体系结构视角：转发失败为什么会牵动整个窗口

Store 数据可能已算出，但地址尚未确定；Load 若贸然越过，之后发现别名就必须重放依赖链。预测过于保守会让无关 Load 白等，过于激进又会增加 replay。Contained 与部分重叠尤其麻烦，因为需要移位、拼接、掩码或等到 Cache 中的旧字节可用。

异常发生时，架构要求退休点保持精确；微结构可以提前做可回滚的查询、分配或取数，却不能在错误路径上留下不允许的架构可见结果。可用 forwarding success/failure、memory-order violation、replay、Store Queue full 和 blocked-load 周期判断慢路来源；Lion Cove 未公开相关专用 PMU 事件编码，因此至少还可以用 cycle、retired instructions 与精心设计的依赖链分离吞吐和延迟。

## TLB：两套一级数据结构与分区式二级容量

Lion Cove 的数据侧一级 TLB 分成 Load 和 Store 两套。Load DTLB 包含 128 项、8 路的 4 KB 页组，以及 32 项、8 路的 2 MB 页组；Store DTLB 约 16 项全相联，可覆盖多种页大小。指令侧一级 TLB 为 256 项、8 路的 4 KB 页组，加 32 项、8 路的 2 MB 页组。

二级 TLB 合计约 2048 项、8 路，但由两个 1024 项分区构成：一组覆盖 4 KB/2 MB/4 MB，另一组覆盖 4 KB/1 GB。Redwood Cove 的组织大体相似，只是 4 KB Load DTLB 为 96 项、6 路。Lion Cove、Redwood Cove 与 Zen 5 的二级 TLB 命中都大约增加 7 周期。

![图 19：Lion Cove、Redwood Cove 与 Zen 5 的 TLB 组织](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/49af1a769fb45cd1_19_tlb_capacity.jpg)

*图 19：网页正式图注意思是“反正谁会用 1 GB 大页呢”。Zen 5 的 L1 DTLB 约 96 项全相联，二级数据 TLB 含 4096 项、16 路的 4 KB/2 MB 组和 1024 项、4 路的 1 GB 组；其 ITLB 约 64 项全相联，二级指令 TLB 为 2048 项、8 路。*

TLB 命中只能避免页表遍历，并不直接等于数据命中。若一级 TLB miss、二级命中，Load 会在正常 Cache 延迟上再付约 7 周期；若二级也 miss，就要发起 Page Walk，而页表项本身还可能逐级命中或错过 Cache。大页减少的是地址翻译覆盖压力，不会改变应用数据本身的局部性。

## 八宽重命名：入口变宽，依赖消除能力却各有边界

重命名通常是乱序核心最难扩宽的阶段之一。它必须按程序顺序处理源/目的寄存器映射、分配 ROB 和队列资源、建立恢复状态，并在一个周期内解决同组指令之间的新依赖。Lion Cove 从 Redwood Cove 的六宽扩至八宽，与 Zen 5 相同。

![图 20：重命名阶段可消除或加速的操作](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/375b2f017dbe02b3_20_rename_optimization_throughput.jpg)

*图 20：Lion Cove/Redwood Cove/Zen 5 的 IPC 依次为：`XOR r,r` 7.31/5.70/5.01，`XOR xmm,xmm` 7.31/5.71/4.99；依赖 MOV 7.02/5.56/6.65，独立 MOV 7.25/5.71/5.01；依赖 increment 5.60/5.53/1.00，依赖 add-immediate 4.36/5.47/1.00。*

零惯用法和寄存器移动接近入口带宽，说明它们可以在重命名附近消除或低成本处理。Golden Cove 引入的“每周期处理多条依赖小立即数加法”能力仍然存在，但没有随八宽入口同比增强：图中 Lion Cove 的依赖 increment 约 5.60 IPC，依赖 add-immediate 约 4.36 IPC，后者反而低于 Redwood Cove 的 5.47。

### 体系结构视角：重命名宽度决定峰值，也制造恢复压力

八宽重命名意味着每拍最多要生成八组新映射，并正确处理同拍的读后写、写后写与分支边界。宽度提高可以让充足的前端供给更快进入后端，却也增加映射表端口、checkpoint 容量和旁路复杂度。分支预测错误时，核心还要把 speculative mapping 恢复到正确路径。

从公开测试无法确认 Lion Cove 使用逐分支完整 checkpoint、增量历史记录还是混合恢复。可以确认的是：零惯用法与 MOV 的吞吐接近八宽，而依赖立即数加法存在更窄的专用路径。若 IPC 低而 rename stall 很高，应继续看究竟是 ROB、寄存器、分支资源还是某个分区队列先耗尽，不能把所有入口停顿都归给重命名逻辑本身。

## 八宽译码、12-wide 微操作 Cache 与三级 BTB

Lion Cove 仍采用 Intel P-Core 熟悉的前端：指令从 I-Cache 进入主译码器，热点代码可以由微操作 Cache 绕过重复译码。主译码从 Redwood Cove 的六条指令扩至八条；微操作 Cache 从约 4096 项增至 5250 项，读取带宽从每周期 8 个微操作提高到 12 个。

![图 21：Lion Cove 的取指、译码与微操作 Cache](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/66ad6ed6199009d8_21_frontend_fetch_decode.png)

*图 21：八宽主译码器服务一条线程，不像 Zen 5 那样以双集群组织；微操作 Cache 可提供最高 12 uops/cycle，再由前端队列吸收短期波动。峰值供给仍要通过八宽重命名，因此多出的带宽主要用于填补空泡。*

在 64 KB I-Cache 范围内，Lion Cove 可以维持约 8 instructions/cycle。进入 L2 供给后，字节吞吐约为 16 B/cycle；从 L3 取代码时，Lion Cove 与数据侧表现相近，分支预测器还可以跑在取指前面，提前发起 I-Cache miss。Zen 5 在 L3 代码供给测试中反而更低。

使用 8-byte NOP 时，微操作 Cache 内可达到约 8 IPC，但吞吐在接近 5250 项名义容量前就开始下降；16 KB 代码只含 2048 条这种 NOP，理应仍在容量内，Redwood Cove 也有相似现象。这个拐点说明有效容量可能受组相联、地址映射或测试布局影响，不能用单一曲线断言物理条目失效。

![图 22：不同代码规模下的指令供给](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/5235b866b99e71ed_22_instruction_fetch_bandwidth.png)

*图 22：L1I/微操作 Cache 区域可接近八条指令或约 64 B/cycle，离开热点区后下降；L1I 本身略高于 32 B/cycle，L2 约 16 B/cycle。图展示整条取指路径的有效吞吐，不等于某个 SRAM 阵列的裸带宽。*

方向预测方面，单个静态分支可以学习约 12K 长度的随机重复模式，Lion Cove 与 Redwood Cove 差异不大。SPEC CPU2017 的架构 PMU 结果也显示两代几何平均准确率相差不到 0.1 个百分点；Zen 5 整体略好，在 541.leela 和 557.xz 中，相对 Intel 分别减少约 11.4% 和 3.84% 的 mispredict/instruction。网页正文把后一项写作 `541.xz`，这里按 SPEC CPU2017 的正式项目名写作 `557.xz`。Lion Cove 对 526.blender 仍较吃力。

![图 23：Lion Cove 的随机方向模式预测](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/4ac71c4d556b98ff_23_lion_cove_direction_pattern.png)

*图 23：横轴增加重复随机模式长度。单分支可维持到约 12K 的规模，随后成功率下降；这反映历史与预测表共同形成的有效能力，不能直接读成 12K 位全局历史。*

![图 24：Redwood Cove 的对应方向模式](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/82378c4ece8a8861_24_redwood_cove_direction_pattern.png)

*图 24：Redwood Cove 的整体形态与 Lion Cove 接近，说明这一代重点不在大幅扩展方向历史。两张图的细微差异还可能来自散列、表冲突和训练状态。*

![图 25：SPEC CPU2017 整数子项的分支预测准确率](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/7de4d0a9e63863fd_25_spec_integer_branch_accuracy.png)

*图 25：多数项目已经非常接近 100%，因此看似微小的准确率差异可能对应可观的 MPKI 相对变化。Zen 5 在 541.leela、557.xz 等困难子项更有优势，Lion Cove 与 Redwood Cove 的几何平均变化则很小。*

![图 26：SPEC CPU2017 浮点子项的分支预测准确率](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/721ec42724da5268_26_spec_fp_branch_accuracy.png)

*图 26：浮点套件同样呈现“多数容易、少数困难”的分布。526.blender 是 Lion Cove 较弱的一项；图中结果来自架构 PMU，不能区分是具体哪一级方向表或更新策略造成。*

目标预测仍为三级 BTB。Lion Cove 与 Redwood Cove 都能每周期处理两个 Taken 分支，这项能力可能在约 192 项微操作队列内结合循环展开实现；Lion Cove 在该范围内似乎能跟踪的分支更少，机制没有被公开确认。

![图 27：连续 Taken 分支的吞吐](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/220689038ea8eff7_27_taken_branch_throughput.png)

*图 27：两代核心都能在特定近距离代码布局下达到每周期两个 Taken 分支。该结果可能同时使用快速 BTB、微操作队列或循环前端，不能直接等同于任意地址模式下的全局 BTB 吞吐。*

第一级 BTB 命中没有额外空泡。Lion Cove 能在约 2 KB 代码跨度内维持这一快路，几乎不随分支数量变化；Redwood Cove 则能覆盖约 128 个分支，与空间跨度关系更小。第二级约 6K 项，两代命中均产生约 2 周期空泡；末级约 12K 项，Lion Cove 约 3～4 周期，Redwood Cove 的形态更难精确界定。

![图 28：三级 BTB 的容量与命中延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/6dc5e0e6d9d68751_28_btb_capacity_latency.png)

*图 28：延迟平台依次对应零空泡快速层、约 6K 的中间层和约 12K 的末级。Lion Cove 的 L1 BTB 更像按约 2 KB 空间窗口发挥作用，Redwood Cove 则约为 128 个目标；这是微基准观察，不足以唯一确定组相联和标签位宽。*

返回地址栈方面，Lion Cove 的拐点约在 24 层，Redwood Cove 约 20 层；调用深度不超过约 12 时，Lion Cove 的延迟也更低，因而可能存在两级返回预测。Zen 5 在 SMT 下为两个线程各提供约 52 项。Lion Cove 与 Redwood Cove 可以每周期处理一对 Call/Return，Zen 5 需要约四周期完成一对、即平均每个分支约两周期；但 AMD 的 1024 项零空泡直接分支层更强。两者是在不同分支类型上取舍。

![图 29：返回地址栈深度与调用吞吐](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/567cb5b7e2df109d_29_return_stack_depth.png)

*图 29：Lion Cove 在约 24 层前维持较低返回代价，Redwood Cove 约 20 层；深度增加后的台阶支持 RAS 容量判断。不同调用布局、是否命中微操作 Cache 与返回目标别名都会影响曲线。*

### 体系结构视角：前端必须同时预测方向、目标和时间

方向正确不代表下一拍就有指令。目标 BTB miss、I-Cache miss、跨 Cache line 取指、译码带宽不足和微操作 Cache 冲突，都可能让后端断粮。三级 BTB 的本质是用小而快的结构覆盖热目标，再用更大、更慢的层级补容量；12-wide 微操作 Cache 则用峰值冗余填补分支和 Cache 带来的空洞。预测更准也直接减少错误路径取指、译码和执行，对移动处理器的能效同样重要。

发生误预测时，错误路径上的微操作要被取消，重命名映射和历史状态要恢复，取指再从正确目标启动。最有解释力的指标不是单独的 prediction accuracy，而是 branch MPKI、BTB miss 分层、redirect latency、I-Cache/uop-cache miss、frontend starvation，以及错误路径执行量。它们可以回答“是猜错了，还是猜对却没及时拿到目标和代码”。

## 把 Lion Cove 与 Redwood Cove 放回整颗核心

Lion Cove 的整体框图体现了前述变化：八宽前端、5250 项微操作 Cache、分区化调度、18 个端口、约 576 项 ROB，以及 48 KB L1D、192 KB L1.5 和 2.5 MB L2。它仍是一颗追求高频和高单线程性能的宽乱序核心，只是把资源组织方式从传统统一后端进一步推向分区化。

![图 30：Lion Cove 微架构总览](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/a8b2708b83ae48fa_30_lion_cove_microarchitecture.png)

*图 30：核心入口和后端明显扩宽，Cache 层级也更细。框图中的容量与端口大多来自公开资料和微基准复原，不是 RTL 连接图；最值得关注的是资源之间能否形成端到端平衡。*

![图 31：Redwood Cove 微架构总览](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/75fb35123bf9f28d_31_redwood_cove_microarchitecture.png)

*图 31：Redwood Cove 仍保留 Golden Cove 的六宽前端、较小微操作 Cache、12 端口和约 512 项 ROB。两图并列能看到 Lion Cove 不是单点升级，而是前端、调度、执行与 Cache 的协同重构。*

## SPEC CPU2017：代际提升明确，横向排名仍需克制

重新编译的 SPEC CPU2017 Rate-1 估算结果中，Lion Cove 相对 Redwood Cove 的整数总分提高 23.2%，浮点提高 15.8%。这是足够大的代际变化。Strix Point 的 Zen 5 与 Lion Cove 基本处于误差范围；桌面 Ryzen 9 7950X3D 则分别领先约 12% 和 10.8%。

![图 32：SPEC CPU2017 整数与浮点总分](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/8008613c788a94cf_32_spec_cpu2017_total.png)

*图 32：GCC 14.2 下，Ryzen 9 7950X3D 的整数/浮点约为 10.5/15.6，Lion Cove 为 9.37/13.9，移动 Zen 5 为 9.22/14.0，Redwood Cove 为 7.6/12.0。它们不是同功耗、同频率、同内存的平台。*

Intel 给出的官方性能页同样强调 Lion Cove 的 IPC 与效率提升，但供应商数据有自己的频率、功耗和工作负载口径。这里应把官方演示看作产品主张，把 Chips and Cheese 的微基准与 SPEC 看作独立观察，两者可以相互参照，却不能互相替代。

![图 33：Intel 对 Lion Cove 性能提升的公开表述](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/84f135a1100cd66b_33_intel_lion_cove_performance_slide.jpg)

*图 33：Intel 演示材料用于说明设计目标和官方口径；测试条件与本文独立测量不同。架构分析应先区分数据来源，再讨论是否指向一致趋势。*

整数和浮点子项并不整齐。部分程序受益于更宽前端、更大窗口和更低平均 Cache 延迟，另一些程序更受内存、分支或特殊执行慢路影响。总分可以展示整体代际位置，却会掩盖工作负载结构差异。

![图 34：SPEC CPU2017 整数子项](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/63b5385ea1d3b466_34_spec_integer_subscores.png)

*图 34：Lion Cove 相对 Redwood Cove 的提升分布不均，说明 23.2% 不是每个程序共享的固定 IPC 增幅。分支密度、指令工作集、Load 延迟和整数端口压力会改变各子项受益程度。*

![图 35：SPEC CPU2017 浮点子项](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/41cb59d94790147f_35_spec_fp_subscores.png)

*图 35：浮点总分提升 15.8%，子项仍有明显离散。FP/向量调度容量、Cache 带宽和内存延迟都会参与结果；没有锁频和统一平台，不能把单项差距直接还原成某个执行单元的 IPC。*

## 最后的判断：Intel 又做出了一颗有分量的 P-Core

P-Core 一直是 Intel 的核心竞争力，但进步并非始终迅速。Redwood Cove 只是 Golden Cove 的轻微调整；Skylake 架构延续了五代；更早的 P6 也从 Pentium Pro 用到 Pentium II、Pentium III，只在其间逐步修订并提高频率。

Lion Cove 则是一次真正的大改。前端和重命名扩宽，后端调度重新分区，执行端口与 FP 资源扩充，私有 Cache 引入新的中间层，环与内存系统也随 Lunar Lake 一起变化。测试显示 Intel 在遭遇近年挫折后仍保有很强的微架构设计能力。

![图 36：Lunar Lake 同时推进核心、工艺与系统结构变化](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_lion_cove_wechat_article_zh/2e5be251a7430f73_36_lunar_lake_innovation_slide.jpg)

*图 36：传统 Tick-Tock 会把工艺迁移与架构大改分开，以降低风险；Lunar Lake 同时引入新核心、新工艺和系统级重组。文章把这种组合视为 Intel 仍能适应竞争压力的信号。*

文章发布时，Arrow Lake 尚未正式展示桌面端最终表现。更大的 Cache、更高功耗预算和更低延迟 DDR5 理论上能让 Lion Cove 进一步发挥；这是一项基于当时信息的期待，不应倒写成已经由桌面产品验证的结论。在 Raptor Lake 稳定性问题影响市场信心的背景下，作者希望新一代高性能产品重新建立稳固基础。

ASUS 为测试提供 Zenbook S 14；Chips and Cheese 也在文末列出了 Patreon、PayPal 与 Discord，供读者支持或参与讨论。

## 体系结构视角：从 Lion Cove 得到的六点认识

结合这组测试与前面的机制分析，还可以归纳出六点更一般的处理器设计认识；它们用于帮助读图，不是 Intel 官方结论，也不是对测试文章结尾的逐句改写。

第一，**宽度只有端到端匹配才有意义**。八宽译码和重命名、12-wide 微操作 Cache、超过 200 项数学调度容量与 18 个端口共同组成供给链；其中任一处被分支、Cache miss、寄存器或队列限制，峰值宽度就无法兑现。

第二，**层级化是高频设计的核心方法**。三级 BTB、微操作 Cache、L1D/L1.5/L2/L3 和分区调度，本质上都用“小而快的前层处理常见情况，大而慢的后层补容量”。性能取决于常见路径命中率与后层惩罚，而不是层级数量本身。

第三，**大窗口不等于长延迟一定被隐藏**。约 576 项可见 ROB 提供了更远的搜索范围，但 Load Queue、Store Queue、物理寄存器、分支资源和 miss 跟踪能力会决定实际窗口。没有独立工作或没有足够内存级并行时，ROB 只会更长时间等待同一条临界依赖链。

第四，**分区能帮助时序，也会制造资源碎片**。整数与 FP/向量分开调度让唤醒选择网络更容易扩张到高频，却要求设计者正确估计负载比例。观察队列满与 ready-but-not-issued，比只看总条目更能解释性能。

第五，**Cache 的目标不只有容量和峰值带宽**。192 KB L1.5 的价值在于缩短一部分 L1 miss，而不是复制 L1D 带宽；12 MB L3 则用容量换来更短的环。平均访问时间、命中率、并发 miss 和平台功耗必须一起评估。

第六，**微基准最有价值的地方是建立因果假说，而不是冒充 RTL**。容量台阶、依赖链延迟和端口冲突可以缩小实现空间，却往往无法唯一确定 bank、标签、checkpoint 或转发协议。把实测现象、结构推断与通用机制分开，反而能得到更可靠的体系结构理解。

Lion Cove 的意义，不只是某张性能图领先多少。它展示了 Intel 如何在移动功耗范围内，重新平衡前端宽度、乱序容量、执行资源与复杂 Cache 层次。最终产品能否持续受益，还要取决于频率、功耗、内存、编译器和具体工作负载；但就微架构本身而言，这颗 P-Core 的确重新发出了足够响亮的咆哮。

## 参考资料

- Chester Lam, *Lion Cove: Intel’s P-Core Roars*, Chips and Cheese, 2024-09-27：https://chipsandcheese.com/p/lion-cove-intels-p-core-roars
- Intel, Lunar Lake / Lion Cove 公开演示材料（原文章中所引图表）
- Henry Wong, *Memory Disambiguation and Store-to-Load Forwarding*：https://blog.stuffedcow.net/2014/01/x86-memory-disambiguation/
- SPEC CPU2017：https://www.spec.org/cpu2017/
