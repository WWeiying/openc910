---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "arm_cortex_a510_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*Arm’s Cortex A510: Two Kids in a Trench Coat*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2023 年 10 月 2 日
> - 链接：https://chipsandcheese.com/p/arms-cortex-a510-two-kids-in-a-trench-coat

Arm 的 5 系列更新得很慢。Cortex-A53 和 A55 都曾跨越数代 7 系列大核，长期保持低频、两宽、顺序执行。后台任务通常不需要追逐最高性能，但指令集继续演进，小核也必须跟上。A510 于是第一次打破延续十余年的两宽公式：前端扩到三宽，执行仍然顺序，还允许两颗核心共享 FPU、L2 TLB、L2 Cache 和对外桥接。

文章测试的是 Snapdragon 8+ Gen 1 中的合并核心配置（Merged Core Configuration），并以 Snapdragon 670 的 A55 作为主要参照。两代核心处在不同 SoC、制程、Cache、频率和内存系统中；网页没有完整披露设备型号、编译器与 Flags、系统版本、锁频、温控、重复次数和误差。因此，曲线适合解释瓶颈与结构取舍，不适合当成严格同平台 IPC 对决。

## 总览：三宽顺序核与“双核合并”

A510 是三宽顺序执行核心。SoC 厂商既可以让每颗核心拥有独立资源，也可以把两颗核心组成一簇，共享部分面积昂贵、平均利用率却不高的结构。Cache 容量和共享 FPU 的宽度也有多种配置。

![图 1：Cortex-A510 双核合并配置](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a510_wechat_article_zh/4658ec9a3f5ce19f_01_merged_core_configuration.png)

*图 1：一组示例配置中，两颗核心各自保留前端、整数执行、L1I/L1D 和内存管理单元，共享 FP/Vector 单元、L2 TLB、L2 Cache 以及 CPU Bridge。网页正式图注强调，Cluster 方式与 Cache 容量可以采用其他组合。*

A510 与 A55 都是八级整数流水线，但阶段重新分配了。A510 为适配三宽 Decoder，把 Decode 拉长到三阶段；分支若在第一执行级确认错误，可以立即重定向。A55 要到 Writeback 才能重定向，所以两者的最短误预测代价仍都是八周期。

![图 2：Cortex-A510 与 A55 的流水阶段](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a510_wechat_article_zh/2e95b04200d27d31_02_a510_a55_pipeline.png)

*图 2：A510 的 Fetch 之后是三段 Decode，再进入 Issue、EX1、EX2、Writeback/Retire；A55 的 Decode 较短，却要更晚完成误预测重定向。图片来自两颗核心各自的 Optimization Guide。*

### 体系结构视角：流水级数相同，不代表前端行为相同

误预测代价取决于“何时拿到正确方向和目标、何时允许 Fetch 改道”，而不是只数方框。A510 用更长 Decode 换取三宽吞吐，又把执行级 Redirect 前移，最终守住八周期最短代价。

这也说明顺序核并非没有恢复设计。分支之前的指令可以继续退休，之后已进入流水线的工作则必须作废；只是不需要像乱序核那样恢复 Rename Map、ROB 和多级 Scheduler 状态。验证时应同时观察 Branch Mispredict、Redirect 到新 PC 的周期差以及前端重新产生有效指令的时间，而不是只报一项 MPKI。

## 分支预测：比 A53 更好，仍是“小核级别”

A510 的方向预测明显优于 A53，但随机 Pattern 测试依然显示，它识别长模式的能力落后于 Qualcomm Kryo、Arm 7 系列和 X 系列。曲面只呈现“给定活跃分支数和 Pattern Length 后的平均周期”，不能唯一反推出算法、历史长度或表组织。

![图 3：Cortex-A510 的随机分支模式识别](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a510_wechat_article_zh/7b82d0e95a667d4f_03_branch_pattern_recognition.png)

*图 3：Pattern 加长、活跃分支增多后，低延迟平面逐渐破裂。容量、历史相关性和 Table Aliasing 共同影响曲面，不能据此确认 A510 使用哪一种具体 Predictor。*

目标预测采用两级 Branch Target Buffer（BTB）。约 64 项的 L1 BTB 可以一周期给出 Taken Target；L2 BTB 的容量从曲线估计约 512 项，命中需要两周期。再未命中时，Branch Address Calculator 可在代码命中 L1I 的前提下以四周期处理分支。

![图 4：A510 的 BTB 容量与目标延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a510_wechat_article_zh/1ec134ba35ce04e4_04_btb_capacity_latency.png)

*图 4：不同 Branch Spacing 的曲线在约 64 项后离开最快平台，并在更大足迹出现第二级变化。512 项带有问号，是微基准解释而非 Arm 公布容量；图中还并列 A55、A53 和 Kryo 作为形态参照。*

相较 A55，A510 的一级目标表大约翻倍；A55 很可能没有 L2 BTB，而是以约三周期的 Branch Address Calculator 兜底。因此，小到中等 Branch Footprint 下 A510 更有优势；分支继续增多后，两者差距会收窄。

![图 5：Taken Branch 足迹扩大后的延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a510_wechat_article_zh/b767ea7c30e17e7a_05_taken_branch_footprint.png)

*图 5：16-byte Branch Spacing 下，A510 与 A55 都会随 Branch 数量增加而出现多级台阶；小足迹的快表优势无法替代大 Footprint 的代码供给。*

Return Address Stack（RAS）只有八项。对中、大核而言很浅，深层函数调用或递归容易溢出；Arm 没有在 A53 基础上增加其深度。

### 体系结构视角：方向、目标和返回地址是三类问题

方向预测器回答 Taken/Not-taken，BTB 回答 Taken 后跳到哪里，RAS 则专门利用 Call/Return 的栈式关系。三者任一失效都会让前端改道，但应分别用 Direction MPKI、BTB Hit/Redirect 与调用深度拐点验证。

A510 的取舍很清楚：用 64 项快表覆盖高频小循环，用一个较慢的二级表扩展常用代码，再把极大足迹交给 Decoder/地址计算器。它没有为后台小核配置大核级目标阵列，因此“大多数时候很快”和“大程序里不够快”可以同时成立。

## 取指与译码：单核三宽，双核共享压力从 L2 开始

A510 的 L1I 可选 32 或 64 KB，四路组相联，采用 Virtually Indexed, Physically Tagged（VIPT）方式。16 项全相联 iTLB 与 Cache Index 并行查询；Pseudo-random Replacement 省掉维护 LRU Metadata 的成本，但可能略微降低命中率。Qualcomm 在 Snapdragon 8+ Gen 1 上选择 32 KB，更偏向面积密度。

![图 6：单核指令供给带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a510_wechat_article_zh/9e0ae2c69e3688fc_06_instruction_fetch_bandwidth.png)

*图 6：A510 在 L1I 范围内接近三 Instruction/cycle，A55 约两条；越过 L1I 后两者都显著下降。A510 平均可从 L1I 消费 24 B/cycle，足以喂满三宽 Decoder。*

来自 L2 的代码供给也比 A55 改善，但代码落到 L3 后仍远弱于大核。合并配置下，两颗 A510 各有 L1I 和 Decoder，所以代码留在各自 L1I 时，一簇理论上可持续六 IPC；一旦两边都越过 L1I，就要竞争共享 L2。

![图 7：同簇与跨簇双核的代码带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a510_wechat_article_zh/29a4e3c84360c051_07_dual_core_code_bandwidth.png)

*图 7：两颗核心位于不同 Complex 时，L2 区间的每核吞吐高于同一 Complex，符合共享 L2 争用；到 L3 及更远层级，两种组合基本重合，可能已受每核可跟踪 I-cache Miss 数限制。*

### 体系结构视角：合并核心首先改变的是资源拥塞位置

每颗核心的三宽前端并没有因为共享而消失，所以 L1I 命中时吞吐近似相加。共享边界从 L2 开始，双线程一旦同时产生 Refill，Arbiter、Bank、Fill Buffer 和 Bridge 都可能成为共同瓶颈。

判断共享结构是否拖慢性能，应比较同簇双核、跨簇双核和单核三种组合，并让 Working Set 依次落在 L1I、L2、L3。只看双核总 IPC，无法区分是共享 L2 冲突，还是每核前端本来就没有足够的 Miss-level Parallelism（MLP）。

## 执行引擎：三发射，但仍无法越过远处依赖

解码后的指令可经三个 Dispatch Position 送往多组执行单元。只要彼此独立、操作数就绪、又没有争抢同一执行 Pipe，常见指令便可 Co-issue。

A510 也不是“遇到 Cache Miss 立即完全冻结”的最严格顺序核。它有少量队列，可跟踪 Miss 之后取到的年轻指令；但容量远不能与乱序 Scheduler 相比，很快仍会遇到必须 Stall 的依赖或资源边界。两次 Cache Miss 之间最多可容纳的工作包括：

- 总共约 12 条指令，A53 为 8 条；
- 约 6 条 FP 指令，A53 为 4 条；A510 可包含 128-bit Vector，A53 遇到 Vector 会立即 Stall；
- 3 条 Branch，与 A53 相同；
- 5 条 Load，而 A53 在 Miss 后遇到任何后续访存都会停住。

这些数字描述特定微基准下可见的缓冲距离，不是 ROB 或完整乱序窗口。

### 整数执行

Integer Add、Logic、Compare 和 Register Move 等常见操作大多可三发射。Optimization Guide 画出了许多 Pipe，但不能把每个方框都当成完全独立的端口。例如 Not-taken Jump 与 Multiply 虽分别标在 Branch、MAC Pipe 上，却不能 Dual Issue；它们同时出现在一个三指令组里的概率不高，影响有限。A510 还增加 Pointer Authentication 执行支持，以适配 Armv9。

![图 8：Cortex-A510 执行流水线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a510_wechat_article_zh/f830944a0cf48266_08_execution_pipeline.png)

*图 8：Optimization Guide 展示三条 Issue 位置与 ALU、Shift、Branch、MAC、Divider、Load/Store、FP/Vector 等路径。可达某个单元不等于拥有一份完全独立的发射带宽，真实组合仍受端口与 Co-issue 规则约束。*

### 体系结构视角：三宽顺序核最怕“错过这一次发射”

乱序核可以把暂时发不出去的指令留在 Scheduler，稍后用空闲端口补回吞吐；顺序核若当前三条中有依赖或端口冲突，空掉的槽位通常永远损失。它因而需要更多重复执行能力来增加当拍组合，却又更难用高利用率摊销面积。

应把理论 Pipe 吞吐、可共同发射的指令组合和真实 IPC 分开测量。若独立 Add 能到三 IPC，混合代码却长期不到一 IPC，限制更可能来自依赖、Cache Miss 或前端断流，而不是 ALU 数量。

## 共享 FPU：用峰值换利用率与面积

FPU 是合并配置最醒目的部分。浮点加法需要对齐指数、相加尾数再规格化，硬件远比简单 Integer ALU 昂贵；而 A53/A55 的双发射 FPU 在多数应用中利用率很低。即使 FP-heavy 程序也需要 Scalar Integer 指令完成控制流和地址生成，顺序核又不擅长隐藏 Cache 与执行延迟，很难持续喂满每核一套强 FPU。

![图 9：双核合并配置中的共享功耗域](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a510_wechat_article_zh/c444bc7466d78168_09_shared_fpu_configuration.png)

*图 9：TRM 图中两颗核心共享 FP/Vector Processing Unit 和 L2 TLB。FPU 拥有独立 Power Domain，可以在两核都不使用时关闭；整个 Cluster 仍共用 Clock/Voltage Domain，调频粒度没有同样灵活。*

Arm 允许放弃合并配置，也允许选择更强的 2×128-bit FPU。Qualcomm 为 Snapdragon 8+ Gen 1 选择 2×64-bit 共享 FPU，优先追求面积效率。单核可做每周期两条 Scalar FP，或一条 128-bit Vector；AES 等 Crypto 也占用同一组 2×64/128-bit 路径，因此整个双核簇每周期最多只有 128 bit 的 FP/Vector 总吞吐。

![图 10：单核与双核负载下的 FP/Vector 吞吐](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a510_wechat_article_zh/dd74e1158db39a89_10_fp_vector_throughput.jpg)

*图 10：ST 为单线程，2c 为同一 Complex 的两核同时运行，表中给出每核 IPC，乘二才是整簇 IPC。例如 128-bit FP32 FMA 从单核约 1/cycle 降到双核各约 0.51/cycle，整簇吞吐仍约一条；基本 FP/Vector 吞吐与 A55 相近，部分延迟略有回退。*

即使是延迟受限、没有饱和总吞吐的 FP 测试，两核同时运行也会看到更高执行延迟，可能来自共享仲裁中的不利排队。A510 另有不共享的 PALU Pipe 处理 Scalable Vector Extension（SVE）Predicate，避免 Predicate Dependency 进一步堵住共享 Vector Pipe；但 Snapdragon 8+ Gen 1 不支持 SVE，文章无法实测这一点。

### 体系结构视角：共享单元的成本不只是一条吞吐除以二

共享 FPU 节省面积，也提高低占用资源的平均利用率；代价包括峰值吞吐、仲裁延迟、两线程公平性和更复杂的 Power-state Coordination。即使总请求率低于一条 Pipe 的容量，随机抵达时刻也可能让延迟链发生排队。

验证要同时做单核、同簇双核与跨簇双核，对比 Throughput-bound 和 Dependency-chain 两类测试；还应检查每线程 Grant、Starvation、Queue Occupancy 与 FPU Power State。只看整簇峰值，会漏掉单线程尾延迟和仲裁抖动。

## Load/Store：双 AGU、原生 128 bit 与简单 Forwarding

两条 Address Generation Unit（AGU）都能处理 Load，其中一条还能处理 Store。简单寻址的 L1D Load Latency 为三周期，Indexed Addressing 多一周期。生成的 Virtual Address 由 16 项全相联 dTLB 翻译；A510 支持 40-bit Physical Address，即最多 64 GB Physical Memory。

双核配置的相关 TRM 文字写到：`0x000–0x0FF` Set 访问 Main TLB，`0x100–0x147` 访问 IPA/Walk Entry。L1 dTLB Miss 进入双核共享、八路组相联 L2 TLB。Arm 没直接写总 Entry 数；按 Main TLB 使用八位 Set Index 推算为 256 Set × 8 Way，也就是最多 2048 项。这个推导应保留为推算，而非明示规格。

A55 的 L2 TLB 是 1024 项、四路，因此共享 A510 在单线程时最多获得两倍容量；双线程平均各约 1024 项，前提是 QoS 没有让一方被挤出。4 KB Page 下，2048 项最多覆盖 8 MB。微基准测到 L2 TLB Hit 比 dTLB Hit 多五周期，而 TRM 暗示只多三周期，两种口径存在差异，材料无法确认来自测量路径还是文档定义。

共享 L2 TLB 比共享 FPU 更棘手：顺序核尤其无法隐藏 Page Walk。它确实能让大而昂贵的 SRAM 更充分利用，但多线程翻译争用可能直接延长关键路径。

### Cache Alignment 与 Store Forwarding

A510 没有高性能 Arm 核常见的 Failed Store Forwarding 深坑。即使 Load/Store 部分重叠，也能约四周期完成；未对齐访问会增至约 7～8 周期。较合理的解释是短流水线让 Dependent Load 等待更早的 Store Commit，从而避免复杂的 Memory Disambiguation/Forwarding Recovery，但没有 RTL 证据确认这一实现。

![图 11：Store-to-load Forwarding 延迟矩阵](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a510_wechat_article_zh/c6f5718952ca9fa7_11_store_forwarding_latency.png)

*图 11：绿色区域约四周期，Partial Overlap 没有形成大核上常见的极高失败代价；跨对齐边界的区域升到约 7～8 周期。矩阵展示结果，不足以证明内部一定采用“等 Store Commit”的结构。*

Load 以 32 B 对齐边界、Store 以 16 B 对齐边界工作；跨界时内部需要拆成两次访问。A55 的 Load 对齐粒度只有 8 B、Store 同为 16 B，所以更容易让普通未对齐 Load 受罚。

![图 12：Load/Store 对齐对吞吐的影响](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a510_wechat_article_zh/21a4d2066867a8b1_12_load_store_alignment.png)

*图 12：标量和 Vector Access 在跨内部边界后出现带状低吞吐区。Vector 更容易跨界；Store 必须 16 B 完全对齐，才能达到最高写带宽。*

### 体系结构视角：地址生成吞吐、访问拆分与 Forwarding 是三层约束

两条 AGU 决定每拍可开始多少地址计算；128-bit Data Path 决定一次能搬多少数据；Alignment 与 Forwarding 决定一次架构访问是否要拆分、或是否依赖旧 Store。三者不能用一个“每周期两次访存”概括。

可用 Offset Sweep 同时改变地址模式、访问宽度和 Load/Store 重叠关系，再配合 LSU Stall、Replay、TLB Refill 与 Cache Refill 计数。若跨界耗时稳定翻倍而没有 Replay，通常更像分两拍服务；出现长尾或重放，才需要继续追查依赖预测和恢复路径。

## Cache 与内存：私有 L1，合并配置从 L2 开始共享

L1D 可选 32 或 64 KB，四路组相联、VIPT、Pseudo-random Replacement。因为它可能持有最新且唯一的数据副本，所以具备 Error-correcting Code（ECC）保护。

![图 13：A510 与 A55 的 L1D 读取带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a510_wechat_article_zh/759e62e905202059_13_l1d_bandwidth.png)

*图 13：A510 依靠原生 128-bit Access，在 L1D 区间明显领先 A55；同一 Cluster 的两核同时运行时带宽近似线性增加，说明每核拥有从 LSU 到 Vector Register File 的私有 128-bit Data Path。*

越过 L1D 后，A510 在 L2、L3 和 DRAM 的带宽也高于对照 A55，有利于简单 Memcpy/Memset；但这些层级强烈依赖 Snapdragon 的实现，不能全部归因于 Core IP。

![图 14：单线程 Cache 与内存读取带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a510_wechat_article_zh/c150d54f66ba842b_14_cache_memory_bandwidth.png)

*图 14：曲线从 L1D 峰值跨过 L2、L3 后逐级下降。A510 的优势同时包含核心接口、共享结构与两台 SoC 内存子系统差异。*

A510 的 L2 可选，容量 128～512 KB、八路组相联；L2 ECC 也是可选项。Snapdragon 8+ Gen 1 看起来采用每个双核 Cluster 共享 128 KB L2，并共享 Off-cluster CPU Bridge。

![图 15：双核同时读取时的共享层级带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a510_wechat_article_zh/2d48fe47fde31676_15_dual_core_bandwidth.png)

*图 15：同簇两核同时冲击 L2 时，带宽扩展较差；越过 L2 后，双核从 L3 获取的数据也没有明显超过单核。DRAM 区间反而出现双核高于单核的结果，说明不同层级的限制并非同一个。图中曲线相交与标值应按趋势解读。*

这种表现与 AMD Bulldozer 相反：Bulldozer Module 的共享 L2 在双线程下能提供更多带宽，A510 的 L2/Bridge 则优先省面积。顺序核本就频繁因延迟停顿，Arm 没有为很少能长期吃满的带宽过度加宽共享路径。

### 延迟

后面的 Cache 延迟测试又把简单寻址 L1 访问记为四周期、复杂寻址为五周期，与前述 LSU 段的三/四周期口径并不一致；L2 约 9～13 周期。因为 L1 dTLB 只有 16 项，使用 4 KB Page 时很快就叠加 L2 TLB 代价。

![图 16：A510 与 A55 的 Cache/Memory 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a510_wechat_article_zh/fd5e44b7310d444d_16_cache_memory_latency.png)

*图 16：A510 在约 32 KB 后离开 L1，约 128 KB 后离开 L2；Snapdragon 8+ Gen 1 配 6 MB L3，Snapdragon 670 则是更小但更快的 1 MB L3。曲线越过 L2 后描述的是两套 SoC，而不是两颗核心的孤立延迟。*

Android 无法使用 Huge Page 进行这组测试，所以图中采用 4 KB Page。即使考虑 Page Walk，Snapdragon 8+ Gen 1 超过 300 ns 的 DRAM Latency 仍非常糟糕，甚至高于一些 GPU 从 VRAM 取数的时间。

### 体系结构视角：共享资源最怕的是延迟，而非峰值不够漂亮

顺序核缺少大窗口去寻找独立工作，因此 L2 TLB 多几拍、共享 L2 多一次排队，都更容易直接落在 Critical Path。单线程较大的共享容量可能降低 Miss，双线程争用却可能放大 Tail Latency；平均带宽不能回答这项取舍是否成功。

完整分析应把 L1/L2 TLB Hit、Page Walk、L1/L2/L3 Hit、Bridge Queue 和 DRAM Controller 分开，并用同簇/跨簇线程组合观察干扰。只有共享层 Queue Occupancy 与延迟同步上升，才有理由把退化进一步归因于合并结构。

## 频率行为：标称 2.016 GHz，实际最高约 1.8 GHz

`lscpu` 显示 Snapdragon 8+ Gen 1 的 A510 频率范围为 307～2016 MHz，但和同芯片的 A710、X2 一样，测试中无法到达 Qualcomm 设置的最高值。

![图 17：系统报告的 A510 频率范围](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a510_wechat_article_zh/f21025c55c80cbd1_17_clock_limits.png)

*图 17：系统列出四颗 Cortex-A510，最小 307.2 MHz、最大 2016 MHz；这只是操作系统可见上限，不等于负载下实际驻留频率。*

短负载与持续负载都在约 1.8 GHz 封顶，与 Snapdragon 670 中约 1.7 GHz 的 A55 相近。A510 空闲约 0.56 GHz，从空闲提升到 1.8 GHz 用时略低于 16 ms。

![图 18：A510 从空闲到最高实测频率的过程](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a510_wechat_article_zh/c2bbd4107b2df172_18_clock_ramp.png)

*图 18：约 16 ms 后进入 1.8 GHz 附近，之后频率有短暂下探。A510 是 Snapdragon 8+ Gen 1 中 Boost 最快的核心，很大程度上因为它的最高频率最低、达到该点所需功耗增量最小。*

## 最后的评价：共享资源很成功，三宽顺序仍有疑问

A510 让 5 系列第一次越过两宽：方向预测、Cache 带宽以及 Cache Miss 后有限的 Nonblocking 能力都有增量提升。更大胆的变化是资源共享——移动 SoC 喜欢布置许多小核，合并低利用率结构可以直接提高面积效率。

### 共享资源的得与失

A53/A55 的 Dual-issue FPU 在很多高性能核心能跑到中高 IPC 的代码中，平均 IPC 仍低于 1；即使 FP-heavy 程序也包含大量整数控制和地址生成。为每核复制完整 FPU 往往让大块硅面积闲置，A510 的共享方式因此很合理。

L2 TLB 的判断更复杂。若另一方案是两份 A55 式 1024-entry L2 TLB，那么一份共享 2048-entry 表至少让单线程获得更大覆盖；双线程若有良好 QoS，平均容量也不低于 A55。但 Translation Latency 对顺序核尤其昂贵，共享争用比 FPU 争用更值得警惕。

![图 19：A510 单核与双核 Cluster 的功耗域](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a510_wechat_article_zh/4c90a0890bfddb99_19_single_dual_core_configuration.png)

*图 19：TRM 对照单核和双核配置。共享不仅改变数据通路，也改变 Power Domain 与控制关系；一颗核心请求关闭共享 FPU 时，必须先确认另一颗核心不再使用。网页正式图注说明两图来自 TRM。*

共享 L2 与 CPU Bridge 并不是 Arm 第一次尝试，Cortex-A72 已有共享 L2；多核全负载时带宽扩展同样不理想。对经常因内存延迟停顿的小核而言，继续加宽这些路径未必是最划算的面积投资。

共享结构也增加验证难度：Arbitration 必须避免一颗核心在重负载下饿死，Power Management 必须覆盖单核活跃、双核活跃与切换过程。

![图 20：共享单元带来的验证风险](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a510_wechat_article_zh/fd11e78ed84b5010_20_shared_resource_validation.png)

*图 20：网页以一条 A510 Erratum 为例——两核在特定精确时序下执行链式 Multiply-accumulate，可能产生错误结果；受影响的是共享 2×64-bit VPU Data Path 的配置。网页正式图注提醒，即使不跨核共享，处理器同样会有勘误。*

这些工程问题并不轻松，却能为后续更复杂的小核积累仲裁、验证和电源管理经验。

### 为什么不该把 A510 简单类比为 Bulldozer

两者都在核心对之间共享大量结构，但 Bulldozer 的主要问题并不是“共享”本身。它在多线程程序中反而更有竞争力；真正短板是每线程重排序容量小于 Sandy Bridge、Cache Latency 又更高，而当时市场极其看重单线程性能。

A510 不面向高性能市场。若性能成为首要目标，最先限制它的是顺序执行，而不是共享 FPU。它追求的是低功耗和小面积，共享低利用率资源正好服务这个目标。

### 后续方向：共享会留下，顺序执行未必

Arm 在 Embedded Cortex-M、Performance Cortex-X 之间同时维护多条产品线，仍愿意为 5 系列投入复杂的共享设计。Qualcomm 在 Snapdragon 8+ Gen 1 中采用合并配置，也证明这一方向具有商业吸引力。

![图 21：可选的 A510 Cluster 与 FPU 组合](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a510_wechat_article_zh/1683c717675f2891_21_fpu_configuration_choice.jpg)

*图 21：Arm 允许单核、双核以及 2×64/2×128-bit FPU 等组合。若共享导致性能问题，SoC 厂商可以选更强配置；图中的产品路线显示主流实现仍优先选择了更省面积的组合。网页正式图注以略带讽刺的口吻指出，厂商显然没有选择更强 FPU。*

未来还可能继续共享低利用率的 Integer Multiplier/Divider，甚至形成更大的小核 Cluster。不过，三宽顺序执行本身更值得怀疑。A53 除最简单任务外平均 IPC 远低于 1；A510 虽扩大 Miss 后的缓冲距离，最终仍受“Cache Miss 到第一条消费指令之间有多少独立工作”限制。Buffer 继续变大后，小型乱序核心可能反而同时获得更好的性能与面积效率。

A510 很可能像 A53/A55 一样跨越数代大核。真正值得追踪的问题，不是下一代能否再多一条 Pipe，而是 Arm 会在何时判断：继续维持顺序所节省的控制成本，已经抵不过一次长延迟造成的整条流水线停顿。

### 体系结构视角：从 A510 可以归纳出的六点认识

第一，合并核心不是“半颗核心”。每颗 A510 仍有独立前端、整数执行与 L1 Cache；共享边界落在高面积、低平均利用率或更远的层级，因此单线程 Common Case 可以保持完整。

第二，共享资源应按利用率和延迟敏感度分别选择。FPU 平均闲置，适合共享；L2 TLB 虽也占面积，却处在 Page Walk 的关键路径，争用代价比吞吐表面值更危险。

第三，三宽顺序执行扩大了峰值，也放大了空槽浪费。没有 Scheduler 回收错过的发射机会，Dependency、Port Conflict 与 Cache Miss 都会让理论三 IPC 快速蒸发。

第四，小核性能越来越像一个 Cluster 问题。L1 内单核可以三 IPC，同簇双核到 L2 便开始争用；评价 A510 不能只测单线程，也不能把 Snapdragon 的 L3/DRAM 行为全归给 Arm Core IP。

第五，有限 Nonblocking 能力不等于乱序。12 条指令、6 条 FP、5 条 Load 描述的是 Miss 后还能容纳多远；一旦遇到首个真正依赖，顺序约束依然会封住流水线。

第六，面积效率需要付出验证成本。共享 FPU、Clock/Power Domain 和 Arbiter 引入了跨线程状态组合，图 20 的勘误正是提醒：省下的 SRAM 与执行单元面积，会部分转化为设计、验证和 QoS 工作。

## 参考资料

- Chips and Cheese：[*Arm’s Cortex A510: Two Kids in a Trench Coat*](https://chipsandcheese.com/p/arms-cortex-a510-two-kids-in-a-trench-coat)
- Arm：Cortex-A510 Technical Reference Manual 与 Software Optimization Guide（正文图中援引）
