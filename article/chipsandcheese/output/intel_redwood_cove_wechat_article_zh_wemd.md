---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "intel_redwood_cove_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*Intel’s Redwood Cove: Baby Steps are Still Steps*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2024 年 9 月 22 日
> - 链接：https://chipsandcheese.com/p/intels-redwood-cove-baby-steps-are-still-steps

Meteor Lake 从十多年 Monolithic Client 设计转向 Tile/Chiplet，是系统层的大冒险。Intel 在 CPU Core 上则保守得多：Redwood Cove 只是 2022 Raptor Cove 的小改，Raptor Cove 又几乎是 2021 Golden Cove 加 2 MB L2 与更高但稳定性更差的 Peak Clock。测试看不到主要结构容量变化，但 Branch、L1I、IDQ、Fusion、FP Latency、Miss Queue、Prefetch 与 SMT 仍有实质调整。

## 总览：Golden Cove 连用三年

![图 1：Redwood Cove 核心总览](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_redwood_cove_wechat_article_zh/75fb35123bf9f28d_01_figure.png)

*图 1：主要 Backend Capacity 与 Golden Cove 接近；本文关注小改如何提高同一资源的利用率。结构图来自公开资料与微基准，不是 RTL。*

## Frontend：更快 Main BTB、更大 L1I/IDQ

Intel Optimization Guide 写明“Improved Branch Prediction and reduced average branch misprediction recovery latency”。测试显示 Redwood Cove 可识别略长 Pattern；单 Branch Pattern Length 超 16，或多 Branch 超 `16/branch count` 后，Taken Latency 小幅增加。

![图 2：Redwood Cove 长 Pattern 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_redwood_cove_wechat_article_zh/82378c4ece8a8861_02_figure.png)

*图 2：现象支持“小而快 Global Predictor 被更准 Level Override”的假说；Second Level 只多 1 cycle。具体 Predictor Organization 未公开。*

![图 3：Golden Cove 对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_redwood_cove_wechat_article_zh/fef84b429c7ed758_03_figure.png)

*图 3：Golden Cove 类似台阶出现在 Length 8，说明 Redwood Cove Fast Level 可能更有能力。*

Main BTB 似乎仍为 12K Entry，Latency 从 3 降到 2 cycle；奇怪的是单线程只能看到一半容量，两 SMT Thread 才用满。

![图 4：BTB Capacity/Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_redwood_cove_wechat_article_zh/caac21bc2ea5a3e1_04_figure.png)

*图 4：小 Loop 最多 32 Branch 可两 Taken/cycle，可能由 Micro-op Queue Unroll；128-entry L1 BTB 为 1-cycle，但吞吐也只有 1 Target/cycle。双线程 Branch Spam 时每线程约两 Cycle 一条。*

Pentium 4 曾引入 0x2E Not-taken、0x3E Taken Hint，后代大多忽略。Redwood Cove 重新识别 0x3E：Predictor 没信息——首次见 Branch 或 Footprint 太大——Decoder 看到 Hint 后 Redirect Frontend。

L1I 从 32 KB 翻倍到 64 KB。两线程一起比单线程更能达到 32 B/cycle。

![图 5：L1I Instruction Bandwidth](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_redwood_cove_wechat_article_zh/9b847f228a719696_05_figure.png)

*图 5：高速区扩到 64 KB。单/双线程差异可能来自 Partition、Request Queue 或供给路径，不能仅凭曲线锁定原因。*

4096-entry Op Cache 也要两 SMT Thread 才显示全容量，支持 Golden/Redwood Cove 永久按 Thread 分区、单线程不能借走另一半的解释。

![图 6：Op Cache 容量与 PMU](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_redwood_cove_wechat_article_zh/17617956461a4bb5_06_figure.png)

*图 6：PMU 排除了单线程只是被其他无关原因降速，但静态分区仍是行为反推。*

Rename 前 Instruction Decode Queue（IDQ）从 144 增至 192 Entry；双 SMT 时静态各 96，单线程可用 192。Loop Stream Detector（LSD）复用 IDQ 保存小 Loop，可关闭包括 Op Cache 在内的大部分前端。

![图 7：DSB/MITE/LSD 的 PMU 来源](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_redwood_cove_wechat_article_zh/e2f98137674d21f9_07_figure.png)

*图 7：正式图注说明 Intel 把 Op Cache 称 Decoded Stream Buffer（DSB），Decoder 称 Micro-Instruction Translation Engine（MITE）。*

![图 8：Redwood Cove 的 Loop Coverage](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_redwood_cove_wechat_article_zh/b101d7123905ab75_08_figure.png)

*图 8：LSD 在 xalancbmk、gcc、x264 占明显比例，其他应用一般或很小。*

![图 9：Zen 4 Loop Buffer 对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_redwood_cove_wechat_article_zh/f0dfb093d7b5e80c_09_figure.png)

*图 9：正式图注提醒 AMD 无 Microcoded 独立类别，且 Zen 4 Op Cache 可缓存 Microcoded Instruction，分类不可直接一一对应。*

![图 10：SPEC CPU2017 FP 的 Loop Coverage](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_redwood_cove_wechat_article_zh/d08ac8eb25e402ba_10_figure.png)

*图 10：Redwood Cove 常覆盖显著少数 Instruction，Zen 4 也能但较少；两者 LSD 都不如 Op Cache 稳定。大 IDQ 还能在 Backend 短 Stall 时积累 Micro-op，随后掩盖 Frontend 短 Stall。*

### 体系结构视角：Queue 不只存东西，也切断反压传播

IDQ 变大不会提高稳态 Rename Width，却能把 Frontend/Backend 的短期速率波动解耦。满时才向上游反压；非空时能跨过短 Fetch Bubble。作为 LSD，它又用相同存储换极低功耗循环供给。容量是否有效取决于 Burst Length 和 Loop Footprint，而非平均 IPC。

## Fusion：让六宽 Slot 承载七条指令

Redwood Cove 增加 MOV+OP、LD+OP Macro-fusion。Register MOV+Math 可表达非破坏性三 Operand；Memory Load+依赖 Math 可表达单条 x86 指令无法编码的组合。一个 Fused Micro-op 占一个 ROB/RF Slot，却代表两条 Instruction；六 Micro-op/cycle 的 Core 若平均融合一对，可达七 Instruction/cycle，也能让 Window 跨得更远。

![图 11：SPEC CPU2017 Integer 的 Micro-op/Instruction](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_redwood_cove_wechat_article_zh/8737108504157127_11_figure.png)

*图 11：正式图注“越低越好”。Zen 4 Fusion Case 不同、Multi-uop Instruction 也不同；Integer Suite 多数 Intel 更省，但 AMD 部分甚至低于 1。*

![图 12：SPEC CPU2017 FP 的 Micro-op/Instruction](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_redwood_cove_wechat_article_zh/2fbabc59a4eae8a9_12_figure.png)

*图 12：FP Suite 不再一边倒；526.blender Intel 更高效，503.bwaves、510.parest AMD 更好。*

### 体系结构视角：Fusion 是“逻辑宽度”优化

物理 Rename/ROB Port 不变，Macro-fusion 让一个 Entry 表示更多 ISA Work。拆成更多 Micro-op 会简化 Execution Unit 和 Exception Boundary，却耗更多 Queue/RF；Fusion 则增加 Frontend Pattern Recognition 与退休语义复杂度。应同时看 Instruction/cycle 与 Micro-op/cycle。

## Execution：容量不变，FP Multiply 回到三拍

Backend 结构测试与 Golden Cove 相同。Optimization Guide 唯一明确 Execution 变化是 FP Multiply 3-cycle。它并非首次：Zen 1 起就是三拍，Broadwell 2015 也从 Haswell 五拍降到三拍；Skylake 又统一 FP Add/Mul/FMA 为四拍，可能重用 FMA Unit。Golden Cove 把 Add 降到两拍，Redwood Cove 再把 Multiply 降到三拍，可能用更多专用 Logic 换延迟。

## Memory：64 个 L2 Miss、LLC Page Prefetch 与 AOP

2 MB L2 并非新变化，Raptor Lake Client 与 Sapphire Rapids Server 已采用。Redwood Cove 每一级 Cache 都比 Mobile Zen 4 更大、也更高延迟；L3 超 75 cycle，Zen 4 Mobile 约 50。

![图 13：Cache Latency（2 MB Page）](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_redwood_cove_wechat_article_zh/f18f2bb682b136e7_13_figure.png)

*图 13：正式图注说明用 2 MB Page，减少 TLB/Page Walk 干扰。不同 Mobile Platform Clock/Uncore/DRAM 仍影响结果。*

L2 Miss Queue 从 48 增到 64，增加 Outstanding Miss，帮助隐藏高延迟并提高 Bandwidth。

![图 14：Redwood Cove Cache Bandwidth](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_redwood_cove_wechat_article_zh/4c28c79c30e76dd9_14_figure.png)

*图 14：更多 MLP 被 Meteor Lake 较高 Cache/Memory Latency 与较低 Clock 抵消。Golden Cove 数据来自 Raichu 旧版测试，原帖已不可用，方法版本不同。*

![图 15：Read-modify-write Bandwidth](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_redwood_cove_wechat_article_zh/0f0c21b37a9d78eb_15_figure.jpg)

*图 15：RMW 好一些，但单核仍不及 Zen 4。Bandwidth 是 Outstanding Request×每次返回量/Latency 的综合，不只看 Interface Width。*

LLC Page Prefetcher 在程序接近 4 KB Page 末尾时，进一步抓取后两页共 8 KB。若进 48 KB L1D 会占六分之一，因此只 Fill 24 MB L3；8 KB 占 L3 不到 1%。它也不占 16 个 DCU Fill Buffer 或 64 个 MLC Miss Queue Entry，并 opportunistically 使用 Intra-die Interconnect（IDI）Slot；Ring Traffic 高时自然 Throttle。

![图 16：LLC Page Prefetcher 说明](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_redwood_cove_wechat_article_zh/76f25ce1dce7c085_16_figure.png)

*图 16：正式图注指出摘自 Intel Optimization Guide。机制同时控制 Pollution、Demand Starvation 与 Fabric Bandwidth。*

Array-of-pointers（AOP）Prefetcher 面向 Pointer Array。Apple M1 已有类似机制，也曾被研究者用于 Speculative Side Channel；研究还发现 Raptor Cove 有较保守 AOP，不足以泄露信息。

![图 17：AOP Latency 测试](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_redwood_cove_wechat_article_zh/f69313ceb9794eae_17_figure.png)

*图 17：独立 Pointer Array Access 本身可被普通 OoO 并行，连未声明 AOP 的 Crestmont 也表现很好，因此该 Microbenchmark 无法把收益唯一归因于 AOP，差异也不算巨大。*

### 体系结构视角：Prefetch 的三道闸门

预测“可能用到”只是第一步。放在哪级 Cache 决定 Pollution，借哪组 Miss Entry 决定是否挤压 Demand，何时在 Fabric 空闲发出决定系统干扰。Redwood Cove 把 8 KB 放 LLC、绕开 DCU/MLC Queue、用闲置 IDI Slot，是把 Aggressiveness 与 QoS 一起设计。

## SMT：Watermark 比静态二分更灵活

两线程活跃时，资源可 Duplicated、Static Partition、Watermarked 或 Competitive Shared。Intel 自 Pentium 4 后很少公开细节，下面来自双线程结构测试反推。

![图 18：Redwood Cove SMT Resource Sharing](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_redwood_cove_wechat_article_zh/62f585451854ceda_18_figure.jpg)

*图 18：Intel/AMD 多数结构使用 Watermark，而非 Pentium 4 那样把主要 Scheduler 静态二分。具体容量与阈值不是官方参数。*

![图 19：单线程可占 RF 比例](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_redwood_cove_wechat_article_zh/d428a7921693505c_19_figure.png)

*图 19：Redwood Cove 一线程可占约四分之三 Integer RF，AMD 约 58%。高 Watermark 提高一忙一闲时的利用率，也需防止一个 Thread 让另一个饥饿。*

SPEC CPU2017 Rate 在同一 Core Pin 两份，GCC 14.2，`-mtune=native -march=native`，可用本机全部 ISA。

![图 20：SPEC CPU2017 Integer SMT Scaling](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_redwood_cove_wechat_article_zh/361bb026ea24ef24_20_figure.png)

*图 20：Redwood Cove Integer Throughput +17.6%。SPEC Version、Compiler 与 Flags 明确，但平台功耗、Run-to-run Error 等仍需随网页条件理解。*

![图 21：SPEC CPU2017 FP SMT Scaling](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_redwood_cove_wechat_article_zh/b605b9cfaaccb62a_21_figure.png)

*图 21：FP 只 +4.2%；Zen 4 两套都超过 20%。SMT 收益取决于两个 Copy 是否竞争 FP、Cache、Bandwidth 等共享资源，不能等同为核心多 17.6%。*

### 体系结构视角：SMT 的价值是填空洞，不是复制核心

一线程因 Dependency、Cache Miss 或 Branch Bubble 暂停时，另一线程使用空闲 Port/Slot。Watermark 允许单线程多占资源，又保留配额让第二线程前进。若两线程争同一 FP Unit 或 Memory Bandwidth，收益小甚至倒退；验证应报告 Per-thread IPC、Fairness、RF/ROB/Scheduler Quota 与共享 Cache Miss。

## 其他 Server-only 变化与最后评价

Granite Rapids 还增加 Code Software Prefetch Extension 与 AMX FP16，但 Meteor Lake Client 没有。前者可能允许软件提示未来 Code 地址；AMX 用 Tile Register 与 Matrix Unit 加速 AI/ML。

![图 22：Meteor Lake System/Tick 背景](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_redwood_cove_wechat_article_zh/846aa2e290c60260_22_figure.jpg)

*图 22：2023 Redwood Cove 更像传统“Tick”：系统与 Process Node 大变，Core 小改，用保守微架构控制总体风险。*

相比 Ivy Bridge/Broadwell 等 Tick，Redwood Cove 改动并不算少；但 2021～2023 AMD 从 Zen 3 到 Zen 4，一代同时从 TSMC 7 nm 转 5 nm、扩大主要结构并加 AVX-512，Intel 进度显得温和。Intel Client 又因 E-Core 不支持而关闭 AVX-512。

Redwood Cove 本身是合格 Core，Meteor Lake 日常性能没有明显问题。它的历史任务不是做大跃进，而是让 Tile 化系统安全落地，把大改留给 Lion Cove。

### 体系结构视角：从 Redwood Cove 可以归纳出的六点认识

第一，系统架构风险与核心风险需要错峰。Meteor Lake 改 Tile/Node/Packaging 时，复用 Golden Cove Backend 是工程策略。

第二，容量不变也能提高有效 Window。Fusion、LSD 与更大 IDQ 让同样 ROB/RF 表示更多有用 Work，并隔离短 Stall。

第三，BTB 容量与共享策略同等重要。12K 只有双线程可见全量，说明 SMT Partition 会改变单线程 Frontend Footprint。

第四，MLP 扩容不能自动克服 Latency。64 Miss Entry 若遇低 Clock 和高 L3/DRAM Delay，Absolute Bandwidth 仍可能一般。

第五，Prefetch 是系统流量管理器。准确率之外，还需控制 Fill Level、Tracking Resource 与 Fabric Priority。

第六，SMT 提升高度依赖工作负载。Integer +17.6%、FP +4.2% 清楚说明“第二线程”不是固定增益。

## 参考资料

- Chips and Cheese：[*Intel’s Redwood Cove: Baby Steps are Still Steps*](https://chipsandcheese.com/p/intels-redwood-cove-baby-steps-are-still-steps)
- Intel：Intel 64 and IA-32 Architectures Optimization Reference Manual, Vol. 1
- SPEC CPU2017、GCC 14.2；Raichu Golden Cove 数据；相关 AOP Prefetcher 安全研究（正文援引）

网页末尾提供 Patreon、PayPal 与 Discord 支持入口。
