---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "amd_bulldozer_cache_conclusion_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*Bulldozer, AMD’s Crash Modernization: Caching and Conclusion*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2023 年 1 月 24 日
> - 链接：https://chipsandcheese.com/p/bulldozer-amds-crash-modernization-caching-and-conclusion

上篇分析了 Bulldozer 的前端、PRF、Scheduler、共享 FPU 与 Load/Store。现代 CPU 的性能却不能只看 Core：DRAM 速度落后于 CPU，Cache 必须越来越复杂；Cache 越大又越难同时保持低 Latency。

Bulldozer 像其他现代 CPU 一样采用三级 Cache，却把“容量、共享、延迟、带宽”之间的矛盾集中暴露出来。

## Cache 总览：容量大，延迟也普遍更高

相较 K10，Bulldozer 大幅重做层级：每线程 16 KB L1D、每 Module 2 MB L2、全 Die 8 MB L3。总 On-chip Capacity 很大，Hit Latency 大多回退。

![图 1：Bulldozer Cache Hierarchy](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_bulldozer_cache_conclusion_wechat_article_zh/44143c83945b3b75_01_cache_hierarchy.jpg)

*图 1：两颗 Integer Core 各有私有 L1D，共享 Module L2；四个 Module 再通过 Northbridge 访问全芯片 L3。结构图用于概览，不代表精确物理距离。*

## L1D：16 KB、四周期与先进但徒劳的技巧

AMD 原想保留 K10 的 64 KB L1D，版图却从 Module 两侧“伸出去”，先砍到 32 KB、再到 16 KB；三周期也放弃，改为四周期。

32 nm 上为改善低电压 Margin、Read Timing、Clock 与 Power，L1D 从 K10 45 nm 的 6T Bitcell 改为 8T、0.294 μm²。Transistor 数增加，却以更低存储密度占更大面积，说明“Transistor Density”不能直接代表有效 SRAM Efficiency。Llano 把 K10 缩到 32 nm 时也用 8T，现代一级 Cache 常用 8T，因此这既与工艺初期困难有关，也反映更小 Node 的读稳定性挑战。

容量大降后，相联度增至四路以减少 Conflict Miss；Micro-banking 保持 16 个 Logical Bank，避免总容量缩小后 Bank 数也下降。两 Port 若读取同一 16-byte Sector，可共用一次 L1D Read；同一 Page 的 TLB Access 也可合并。四路 Tag 通过 Way Prediction 避免每次全查。

这些机制很先进，却补不回 16 KB 的 Capacity，部分负载每指令 L1D Miss 甚至超过 K10 两倍。

![图 2：Bulldozer、K10 与 Sandy Bridge 的 L1D Miss](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_bulldozer_cache_conclusion_wechat_article_zh/b235cc6efbf04cc7_02_l1d_miss_rate.png)

*图 2：Bulldozer Hit Rate 大幅下降。Sandy Bridge Counter 在 Retirement 统计 Load，与 AMD 事件不完全可比，只作参考；网页正式图注明确这项限制。*

读取吞吐至少维持 K10：L1D 可每拍两条 128-bit Load。一个 Module 虽有两份独立 L1D，共享 FPU 每拍只能接一对 Load，所以 Module 峰值仍是 `2×128 bit`。

### 体系结构视角：Cache 的基本盘仍是容量、延迟和端口

Way Prediction、Read Coalescing、Micro-bank 都在降低能耗或冲突；若 Working Set 频繁越过 16 KB，所有技巧都只能优化 Hit，无法阻止昂贵的 L2 Access。

设计顺序应先保证 Hit Rate 与 Critical Latency，再用细节优化 Power。验证要同时看 L1D MPKI、Way Prediction Miss、Bank Conflict 和 Port Utilization，不能用“高级机制很多”代替有效容量。

## Write-through L1D 与 4 KB WCC

Write-through L1D 不保留唯一 Modified Copy，可靠性可用便宜 Parity，免去 Eviction Writeback；代价是每次 Store 都向下层产生流量。Intel 在 NetBurst 后放弃这条路线。

AMD 没直接写入慢 L2，而是在中间放 4 KB、四路 Write Coalescing Cache（WCC），作为 Core 与 L2 之间的 Write-back Buffer/Cache。

![图 3：L1D、WCC 与 L2 的写带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_bulldozer_cache_conclusion_wechat_article_zh/82099bf2b798d6ba_03_write_bandwidth.png)

*图 3：WCC 只有略高于 10 B/cycle，Phenom/Sandy Bridge 可每拍持续一条 16 B Store；超过 4 KB 后，L2 平均略高于 5 B/cycle，Module 双线程也不增加写带宽。*

四周期、16 KB、Write-through 三项让 L1D 成为明显弱点：比 Phenom 更慢、Miss 更多，还会增加 L2 Bandwidth Demand。

### 体系结构视角：WCC 是写流量缓冲，不会变出大 L1

WCC 可把相邻 Store 合并成完整 Line，降低 L2 Transaction，也让 L1 不必持有 Dirty State；4 KB Shared Capacity 很快被双线程流式写穿，之后性能仍受 L2 Path 限制。

应按 Store Footprint、Write Combining Ratio 与线程数观察 WCC Hit/Eviction、L2 Write Traffic。只测小数组会把 WCC 当成正常 Write-back L1，夸大持续带宽。

## 2 MB L2：Bulldozer 存储系统的亮点

每 Module 的 L2 为 2 MB、16 路，使用 0.258 μm² 6T Bitcell，比 Westmere L2 的 0.275 μm² 略密。结构由 128 KB Slice 组成，每 Slice 有八个 16 KB Macro，再排成四 Bank。内部 Pipeline 六级；实测 Load-to-use 20 cycle，比四周期 L1 多 16。Pipeline 之外的十周期很可能用于 Queue/Transit，但只是推测。

![图 4：Bulldozer、K10 与 Sandy Bridge 的 Cache Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_bulldozer_cache_conclusion_wechat_article_zh/ecf3fbee268d78d8_04_cache_latency.png)

*图 4：Bulldozer L2 比 K10 慢、容量更大；Sandy Bridge 256 KB L2 走低延迟路线。对照机器只有 Sandy Bridge-EP，其 L3 Slice 更多且每片 2.5 MB，比 Client 版更大更慢，网页正式图注明确此限制。*

2 MB 高 Hit Rate 能让“更大、更慢”成为合理交换。Bandwidth 也比 K10 好：单线程每周期略增，加上 Clock 后 FX-8150 比 Phenom X6 1100T 高 34%；Sandy Bridge 单线程更高，却只有八分之一容量。

![图 5：单/双线程 L2 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_bulldozer_cache_conclusion_wechat_article_zh/37168fc8a7a7cb82_05_l2_bandwidth.png)

*图 5：同 Module 两线程使 Bulldozer L2 Bandwidth 约翻倍，说明两套 LSU 有独立通路。*

![图 6：L2 到两颗 Core 的独立 Data Path](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_bulldozer_cache_conclusion_wechat_article_zh/009a90e91869e80d_06_l2_datapaths.png)

*图 6：AMD 2011 IEEE 图显示两条各 16 B/cycle 的 L2→Core Path。网页正式图注说明来源。*

![图 7：双线程/多核 L2 带宽扩展](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_bulldozer_cache_conclusion_wechat_article_zh/c754f4afa58b63e6_07_l2_dual_thread_bandwidth.png)

*图 7：两线程 Aggregate 可超过 Sandy Bridge，同时容量大八倍；单线程不能独享 32 B/cycle，是为多线程简单扩展作出的取舍。*

L2 的容量/带宽组合能把流量留在 Module，减少进入糟糕 L3 的请求，是全架构少见的亮点。

### 体系结构视角：Private-to-module L2 是 CMT 的吞吐支点

每线程私有 L1 缩小后，共享 2 MB L2 同时承担 Capacity Backup 和双线程供给。两条 16 B Path 让并发读扩展，却无法让单线程借用另一条全部带宽。

这是一种明确偏多线程的 Provisioning。测量应分单线程、同 Module 双线程与跨 Module，联看 L2 Hit、Bank Conflict 与每条 Path Utilization。

## L3 与 Northbridge：8 MB 容量后面的集中瓶颈

L3 为 8 MB、64 路，全 Die 共享。8 MB 恰等于四份 L2 总和，为扩大有效容量，L3 尽量与 Module-private Cache Exclusive：某 Module 拉入一条 Line 后，若不可能被多 Module 共享，就从 L3 删除。L3 同时是 Victim Cache，只由 L2 Eviction Fill。

Latency 超过 18 ns，显著差于 Sandy Bridge-EP 12.7 ns，也回退于低 Northbridge Clock 的 Phenom X4 945（16.35 ns）。

![图 8：Bulldozer 的 L3 Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_bulldozer_cache_conclusion_wechat_article_zh/b08e320a0dae3557_08_l3_latency.png)

*图 8：Phenom II→Bulldozer 保持 Set 数、把相联从 48 增到 64 路以得到 8 MB。更多 Way 降低 Conflict，却需检查 64 组 Tag/State，可能迫使 Pipeline 加深；这项因果是推测，非 RTL 确认。*

K8 Northbridge 起初只需整合 Memory Controller 和跨 Socket，带宽为十几 GB/s、Latency 本就远高于 Cache。K10 把 L3 接到这个中央 Hub 后，低频集中 Queue 突然要服务所有 Core 的 Cache-class Traffic；Bulldozer 仍沿用。

![图 9：Die 中央的 AMD Northbridge](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_bulldozer_cache_conclusion_wechat_article_zh/ee142a9651a5edcd_09_northbridge_layout.jpg)

*图 9：AMD Hot Chips Slide 显示 Northbridge 位于中央。网页正式图注说明来源。四块物理 L3 仍从集中 NB 后访问。*

Sandy Bridge 把 L3 Slice 放到 Ring Stop，每处有 Cache Controller，形成 Multi-ported Banked LLC，可多请求并行。

![图 10：集中 Northbridge 与 Ring-based L3](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_bulldozer_cache_conclusion_wechat_article_zh/aec085765906d2da_10_l3_interconnect.png)

*图 10：对照展示集中 Crossbar/Queue 与分布式 Slice。拓扑差异同时影响 Latency、Aggregate Bandwidth 和扩展。*

Intel Nehalem/Westmere 也曾把 L3 放在集中 Crossbar。Xeon X5650 L3 超过 15 ns，但 Bandwidth 没 Bulldozer 那么差；Uncore Clock 是变量，尚不足以解释全部差距。

![图 11：Westmere 与 Bulldozer 的 L3 Bandwidth](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_bulldozer_cache_conclusion_wechat_article_zh/aa909cac1d422802_11_westmere_l3_bandwidth.png)

*图 11：X5650 是 Nehalem 的 32 nm Die Shrink、最多六核，Uncore Architecture 相同。网页正式图注说明这一代际口径。*

文章更倾向把 Read Bandwidth 短板归因于 Victim Operation：L2 每次 Evict 都写入 L3，无论 Dirty 与否，L3 常同时处理 Lookup 与 L2 Writeback，流量近乎翻倍。软件读到 35 GB/s 时，PMU 若把 Northbridge Event `0x4E2` 的 L2 Eviction Fill 算入，内部约 70 GB/s；Read-modify-write 才能让这部分 Copyback 对软件有用。

单 Module L3 Read 约 15 GB/s，双线程只略升；Phenom 单核 12～14。DRAM 单线程约 8.8、双线程约 12.3，意味着 L3 只比 DRAM 快不到两倍或仅 25%。全核时每 Module L3 不到 10 GB/s，总 L3 35～39 GB/s；Sandy Bridge 全核负载下单 Core 就可超过 30 GB/s。

Northbridge 超到 2.4 GHz 后 L3 达 42 GB/s、17.2 ns；2.6 GHz 系统锁死，说明 NB 并非为接近 Core Clock 设计。L3 以轻微容量增加换性能回退，又迫使架构使用大而慢 L2，不适合 Bulldozer 增加的多线程需求。

### 体系结构视角：Victim Cache 的容量效率会转化成内部流量

Exclusive/Victim Policy 避免 L2/L3 重复存同一 Line，提高有效容量；Clean L2 Victim 也必须写入 L3，带宽成本可能接近一次 Lookup 加一次 Fill。集中 Northbridge 再把所有流量压到共享 Queue。

PMU 验证必须把 Software Read、L3 Hit、L2 Victim Fill 和 Northbridge Transaction 一起计数。只报 35 GB/s 会误以为阵列只忙到 35；内部 70 GB/s 才解释为何带宽已饱和。

## Core-to-core Coherency：不常发生，但一次超过 200 ns

跨核通信频率通常不高，重要性仍是“频率×代价”。同 Module 两线程的 Contended `cmpxchg` 尚可，跨 Module 超过 200 ns；若 OS 不把频繁通信线程放同 Module，平均 Thread-to-thread 约 220 ns，明显回退于 K10，也差于 Sandy Bridge。

![图 12：Bulldozer 核间一致性延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_bulldozer_cache_conclusion_wechat_article_zh/6089c9fa0696acb5_12_core_to_core_latency.png)

*图 12：矩阵展示同 Module 与跨 Module 的明显分层。测试是 Contended Atomic Lock，不等价于所有 Read Sharing。*

![图 13：Core Transfer 发生频率](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_bulldozer_cache_conclusion_wechat_article_zh/84fe0525783a71aa_13_core_transfer_frequency.png)

*图 13：按 PMU 估计 Core-to-core Transfer，相对 L3 Miss 并不频繁。网页正式图注说明只看 Data Load，遗漏 Instruction Read Miss，因而可能低估 L3 Miss。*

![图 14：L3 Miss 与跨核事件的对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_bulldozer_cache_conclusion_wechat_article_zh/dbcb05619723d34e_14_l3_miss_frequency.png)

*图 14：把事件频率与单次代价结合，文章粗估 Core-to-core Latency 可能影响 Gaming 约 1%，通常不大，个别场景略高于误差。该比例是推算，不是直接消融。*

### 体系结构视角：Scheduler 拓扑应知道共享域边界

同 Module 通信快、跨 Module 极慢，OS 若把 Producer/Consumer 分散，会放大 Lock、False Sharing 与 Cache-line Ownership Transfer。CMT 的 Thread Placement 不只影响执行资源，还影响 Coherency。

应区分 Atomic Ping-pong、Read Sharing 与 False Sharing，并比较固定 Affinity。只有 Contended Lock 慢，不能推断普通并行程序同样损失 220 ns。

## Memory Controller：仍是 AMD 的强项

FX-8150 使用 DDR3-1866 CL10，DRAM Latency 约 65 ns；Phenom X6 1100T 以非官方 DDR3-1600 CL9 得 57.8 ns。Bandwidth 为 23.95 vs 20.55 GB/s。配快 DDR3-1866 时，Bulldozer 也应超过只官方支持 DDR3-1333 的 Sandy Bridge。

![图 15：双通道 DDR3 Memory Bandwidth 参照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_bulldozer_cache_conclusion_wechat_article_zh/356acc4accefad33_15_memory_bandwidth.png)

*图 15：网页正式图注称 Haswell 结果用于提示 DDR3-1333 双通道的可能水平。各平台 Memory Setup 无法匹配，因此不作过度推论；结论只到“Bulldozer Controller 合理”。*

## 4 KB Page：1024 项 L2 TLB 仍救不了慢路径

2 MB Page 展示 Raw Cache Latency，Client 常用 4 KB。Bulldozer L2 TLB 为 1024 项，K10 为 512，纸面覆盖更大；实际在 1 MB Test 已增加 15+ cycle，以每 Page 一个 Element 隔离后，越过 L1 TLB 的差值约 20 cycle。

L2 TLB 位于 LSU 外的 Cache Unit（CU），与 L2 Data Path 一起远离每线程 Core；这样便于双线程共享昂贵大表，却付出二十周期 Hit。Sandy Bridge 约七，K10 只 2～3；Bulldozer L1 TLB 还更小，幸运 Hit 更少。

![图 16：4 KB Page 下的有效访问延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_bulldozer_cache_conclusion_wechat_article_zh/7b0e8abe4249cfd1_16_4k_page_latency.png)

*图 16：512 KB～2 MB 时，Bulldozer 明明还在 L2，延迟却接近已进 L3 的 Sandy Bridge/K10；Translation 抵消了 2 MB L2 容量优势。L3 区间可达约 105 cycle。*

K10 即便 L2 TLB Miss 仍有更低 L3 Latency。文章推测 K10 的 24-entry Page Walk Cache 可保存上一级 Page Directory Entry，理论覆盖 96 MB；Bulldozer 则让 L2 TLB 同时充当 Walk Cache，如何选择 Direct Translation 或 Higher-level Entry 不清楚。两项均无 RTL 证实。

### 体系结构视角：共享 TLB 省面积，却把距离放进每次命中

1024 项容量降低 Page Walk 频率，二十周期 Hit 却作用于每个 L1 Miss。对 16 KB L1D 而言，Working Set 很快进入这条路径，容量优势尚未兑现就先付延迟。

验证应分别测 L1/L2 TLB Hit 与 Walk，报告 4 KB/2 MB Page 和 Working Set。不能用图 16 的 105 cycle 直接称“L3 本体延迟”，其中混入 Translation。

## 为什么 Bulldozer 落后 Sandy Bridge

没有单一罪魁。AMD 的困难与 Intel 在 Sandy Bridge 上的成功同时叠加。

### 32 nm 与高频目标

AMD 原计划维持 Phenom IPC、靠 Clock 提升 Single-thread；若每线程 Integer/LSU 保持 K10 规模，共享 Frontend/FPU 又更强，确有可能。但一次工程同时加入大量新机制、迁移新 Node、为结构加 Multithreading，最终不得不削减。

ISSCC 解释：45 nm 6T→32 nm 8T 是为改善 Low-voltage Margin/Read Timing、降功耗，并消除 D-cache Read-modify-write Critical Path。8T 又不够，Bitline Loading 从每线 16 Cell 降到 8；前 AMD Engineer 提供的信息称 L1D 从 64→32→16 KB。Write-through/Parity 也可能与省面积有关，但这是推断。

Integer RF 为移除 Critical Wire Delay 而复制，占用本可用于执行单元或窗口的面积。AMD 文献明确 Physical RF Array 与 AGEN Incrementor 都做 Replication。

不应只怪 Aggressive Clock。Llano 把 K10 最小改动迁到同一 32 nm，也比 Phenom 低频。AMD ISSCC 2010 记录 HKMG 的 PMOS/NMOS Drive Imbalance、Dynamic Node Keeper 修改、Unexpected Delay，以及 Electromigration Current Limit 低于几何缩放预期，需要并联 Strap/降 Capacitance。材料足以确认 Node 困难，但不进一步猜电气根因。

### 还没追够、每线程也不够大

Predictor 比 K10 强，仍不及 Sandy Bridge 速度/准确率；Store Forwarding 覆盖改善，Intel 覆盖更多且 Penalty 更低；AMD 只 Fusion CMP/TEST+Branch，Intel 从 Core 2 迭代到多数 ALU+Branch Fusion。FX-8150 Boost 4.2 GHz，Llano 同 Node 顶级只有 3 GHz，但 Sandy Bridge 同样高频，优势不大。

Northbridge/L3 没现代化，Ring 是 Sandy Bridge 巨大跃升。糟糕 L3 强迫 AMD 配大 L2，大 L2 又慢，尤其惩罚小 Write-through L1D。

无论把 FX-8150 称八核还是四 Module，它更像八颗小 Core，而非四颗大 Core+SMT。单线程可独享 Frontend/FPU，却只有 Module 一半 Integer Reordering；除 FPU Scheduler/RF 外，关键 OoO Buffer 都小于 Sandy Bridge。

这并非必然失败。Zen 4 Window 小于 Golden Cove，却有更低 Cache Latency。Bulldozer 恰好 Window 更小、Cache 更慢。双线程合计则很可观：`2×128 ROB`，Sandy Bridge SMT 把 192 分成 `2×96`；大 Cache 也帮助线程数增加后的 Footprint，所以部分 Well-threaded 应用很有竞争力。Client 的问题是四颗强 Core 比八颗弱 Core 更容易用满，低线程性能不能牺牲。

### 新架构的功耗学习曲线

Bulldozer 到处加入 Power Optimization：PRF、低功耗 Scheduler、L1D Way Prediction、Clock Gating、短 Wire 与 RF Replication；也像 Sandy Bridge 一样根据事件模型估算 Power，在 TDP 内 Opportunistic Boost，并非直接测电功率。

![图 17：AMD 对 Bulldozer 功耗组成的分析](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_bulldozer_cache_conclusion_wechat_article_zh/a6817efb97c83b0a_17_power_breakdown.png)

*图 17：来自 AMD ISSCC 2011。设计早期以 RTL Clock/Flip-flop Activity 作为 Switching Power Proxy；随实现收敛才更接近真实功耗，而此时大改越来越困难。网页正式图注说明来源。*

AMD 论文坦言：彻底新设计缺少“完成实现→找最大浪费→下一版优化”的反馈循环，Power、Timing 与 Functionality 只能同时收敛。高 Clock 与 32 nm 又增加 Leakage/Delay Tradeoff 难度。

Bulldozer 的单线程差距由长清单累积：资源少、Penalty 高且容易触发、Cache/TLB 慢、Power 高。任一项不致命，组合后让 L1 Miss 周围更难提取 Parallelism。与此同时，Sandy Bridge 成功整合了 Intel 在 NetBurst 等架构试验的多项技巧，也应得到充分肯定。

## 最后的评价：痛苦但必要的一代

Bulldozer 一次引入复杂 Predictor、共享 Frontend/FPU、全新 OoO、AVX/FMA，再迁移困难 32 nm。AMD 没能同时把功耗和性能都做好，与 NetBurst 有相似之处；它也像 NetBurst 一样成为新技术试验场，为后来的 Zen 留下 PRF、Checkpoint、共享/调度经验等基础。

![图 18：Bulldozer 到 Zen 的技术延续](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_bulldozer_cache_conclusion_wechat_article_zh/792d79ccfb46c6ef_18_bulldozer_to_zen.jpg)

*图 18：Zen 继续使用不少在 Bulldozer 首发的技术，经过多代 Family 15h 学习后，以更平衡方式实现能效、单线程和多线程。图为演进总结，不表示 Zen 直接复用相同模块。*

Bulldozer 又不完全等于 NetBurst：Penalty 虽高于 Sandy Bridge，却远没有 NetBurst 那样极端或普遍；跨 4 KB Load 等 Corner Case 甚至优于 Intel。其性能大致符合窗口与 Cache 配置，NetBurst 则拥有巨量资源仍输给 K8 IPC。

Athlon 像 P6 一样服役十余年，确实老到难以继续；Llano 在 32 nm 的 Clock Struggle 已说明仅迁移旧 Core 也无法轻松过关。AMD 又知道单线程追上 Intel 很难，转而押注 Multithread。Bulldozer 目标过高、整体失败，但一代完成如此多基础改造，工程成就不应被最终成绩完全抹去。

### 体系结构视角：从 Bulldozer 存储系统可以归纳出的七点认识

第一，L1 是整个层级的放大器。16 KB、四周期、Write-through 让 Miss 和下写都增加，迫使 2 MB L2 同时承担容量与流量压力。

第二，中间缓冲不能替代正确基本政策。4 KB WCC 缓和 Write-through，却很快溢出；它是“小降落伞”，不是 Write-back L1D。

第三，大 L2 可以为多线程构建局部带宽域。两条 16 B Path 让同 Module 双线程扩展，也是避免进入糟糕 Northbridge/L3 的关键。

第四，Exclusive/Victim Cache 以带宽换有效容量。35 GB/s 软件读取背后可能有 70 GB/s 内部 Traffic，Cache Policy 必须按真实 Transaction 计账。

第五，Interconnect 需要随流量等级演化。K8 Northbridge 服务 DRAM 很合适，把 Cache-class L3 Traffic 继续塞进集中低频 Queue 就不再适合。

第六，TLB Hit 也可能成为长延迟事件。1024-entry 表听起来强，离 Core 太远导致约 20 cycle；容量与物理位置必须共同设计。

第七，失败来自多项小劣势相乘。小 Per-thread Window×慢 L1/L2/TLB×差 L3×高 Power，比任何一个单独“共享 FPU”更能解释 Bulldozer。

## 测试配置与参考资料

![图 19：Bulldozer 系列测试平台](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_bulldozer_cache_conclusion_wechat_article_zh/8ce425c5432cab74_19_test_setup.jpg)

*图 19：网页脚注中的 Test Setup，列出 FX-8150、Phenom X6 1100T、Sandy Bridge-EP/其他对照的 CPU、Memory 与相关配置。所有跨架构结果均应回到此图检查平台差异。*

- Chips and Cheese：[*Bulldozer, AMD’s Crash Modernization: Caching and Conclusion*](https://chipsandcheese.com/p/bulldozer-amds-crash-modernization-caching-and-conclusion)
- AMD：*Design of the Two-Core x86-64 AMD “Bulldozer” Module in 32 nm SOI CMOS*，IEEE JSSC，2012
- AMD：*Design Solutions for the Bulldozer 32nm SOI 2-Core Processor Module in an 8-Core CPU*，ISSCC 2011
- AMD：*An x86-64 Core Implemented in 32nm SOI CMOS*，ISSCC 2010
- Intel：*Westmere: A Family of 32nm IA Processors*，ISSCC 2010
