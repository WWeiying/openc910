---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "amd_athlon_64_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*AMD’s Athlon 64: Getting the Basics Right*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2022 年 7 月 28 日
> - 链接：https://chipsandcheese.com/p/amds-athlon-64-getting-the-basics-right

二十年前，AMD K8 与 Intel 最强的 NetBurst 正面对抗。它比今天的“Zen 对某代 Lake”更有意思，因为两款核心走向了几乎相反的性能路线：Intel 堆出长流水线、大窗口、Trace Cache 和强预测，AMD 则在 K7 基础上谨慎加入 64 bit 与系统级改造。

主要数据来自 Athlon 64 FX-62：两个 K8 核心、AMD 90 nm、2.8 GHz，2006 年与 NetBurst 产品竞争，直到同年 Merom 出现。部分结果来自 65 nm Athlon 64 6000+，核心架构相同。两套 AMD 样品与 Pentium Extreme Edition 965 的频率、Cache、Memory 和主板不同；网页也没有完整给出 OS、Compiler/Flags、温控、重复次数与误差，跨平台曲线用于解释架构，不是严格同频 IPC。

## 总览：K7 加 64 bit，而非另起炉灶

K8 大体延续 K7 Athlon，只增加 64-bit Support 和若干调整。它仍把“运算+访存”的复杂 x86 Instruction 作为一条 Macro-op 保留，而不是一开始拆成多条 Micro-op；Integer Side 由三条近似独立 Pipeline 和 Forwarding Network 组成。

![图 1：AMD K8 微架构总览](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/598155c3c8b48240_01_k8_overview.png)

*图 1：三宽 Decode/Dispatch 对应三 Lane Integer Scheduler、ALU 与 AGU；FP/Vector 作为较独立 Coprocessor，另有专用 Rename、Scheduler 和 Register File。*

NetBurst 同样三宽，其他部分却庞大得多，并塞入当时最先进的多项技巧。

![图 2：Intel NetBurst 微架构总览](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/a07209b691d61237_02_netburst_overview.png)

*图 2：Trace Cache、深 Pipeline、大 Reorder/Scheduler、分离 Load/Store Queue 与高频执行构成另一条路线。两图是结构对照，模块口径并不完全等价。*

### 体系结构视角：设计质量不是高级机制数量的总和

更大窗口与更强 Predictor 只有在 Pipeline Recovery、Cache Latency 和 Memory Feed 同样平衡时才会转化为 IPC。某个复杂机制若失败代价极高，平均收益可能被少数慢路吞掉。

K8 的竞争力来自温和惩罚与低延迟：预测不如 NetBurst、窗口也小，却很少让一次异常情况损失几十乃至上百周期。

## 分支预测：规模普通，但误预测伤得较轻

K8 Pipeline 较短，而且分支确认错误后能在退休前取消错误路径指令，因此 Mispredict Cost 小于 NetBurst。预测仍重要，但 AMD 不必像 Intel 那样把它放在最高优先级。

公开 Block Diagram 与 Optimization Manual 显示，K7/K8 都使用 Global-history Two-level Predictor：Branch Address 与此前 Branch Outcome 共同索引 2-bit Counter Table。K8 把 Table 从 4096 增至 16384 项，减少 Aliasing。

文档却留下一个未闭合的位宽问题：Optimization Manual 说使用 Branch Address 的 4 bit 和最近 8 个 Branch Outcome，只得到 12 bit，无法索引 16384 项所需的 14 bit。Hans de Vries 推测“4 bit Branch Address”实际对应 16-byte I-cache Line，另两位用于选择 Line 内 Branch；这是一种解释，不是已确认 RTL。

![图 3：K8 Die 上的分支预测区域](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/d3ca5bc54aa887fe_03_k8_die_branch_predictor.jpg)

*图 3：Die Photo 来自 Cole L，区域标注用于估计 Predictor/Frontend 布局。网页正式图注只确认照片来源，功能边界不能当作精确 Floorplan。*

AMD Hot Chips 声称相对 K7 提升 5%～10% Branch Prediction Accuracy。实测噪声较大，但 K8 的 Pattern Recognition 明显弱于使用 16-bit Global History 的 NetBurst。

![图 4：K8 的随机分支模式识别](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/763d3e3250aef4d0_04_k8_branch_pattern.png)

*图 4：随着 Pattern Length 与活跃 Branch 数增加，K8 的低延迟区域较早破裂。曲面混合 History、Capacity 和 Aliasing，不能仅凭形状确认 Hash。*

![图 5：NetBurst 的随机分支模式识别](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/e1ae04948136dd96_05_netburst_branch_pattern.jpg)

*图 5：NetBurst 能覆盖更长 Pattern，符合 16-bit Global History 与更大 Predictor 投入。两平台的 Mispredict Penalty 不同，平均周期不应只按准确率解读。*

### 目标预测

K8 只有一级、2048-entry BTB。容量在当时尚可，却无法连续处理 Back-to-back Taken Branch：每次 Taken 都要等 Target，前端产生一周期 Stall，因此 Loop Unrolling 对 AMD 很重要。

![图 6：K8 的 BTB 容量与 Branch Spacing](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/15b7f3102e563ff0_06_k8_btb_capacity.png)

*图 6：每条 16-byte L1I Line 放一个 Branch 时达到最大约 2048 Target；网页正式图注说明这一条件。小 Footprint 仍有 Taken Bubble。*

NetBurst 的 Zero-bubble Tracking 在最佳情况下达到 Zen 3 水平，还有 Multi-level BTB，可跟踪约两倍 Target、频率也更高；代价是超出覆盖或恢复失败时惩罚巨大。

![图 7：NetBurst 的 Branch Target 容量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/a98e6f77a5a75b5b_07_netburst_btb_capacity.png)

*图 7：多级台阶和更大覆盖接近现代层级 BTB 的形态，但慢路远不如现代实现温和。*

K8 把 BTB 与 L1I 紧耦合：Branch Selector 附着在 I-cache Line，Fetch 一次同时取得指令与预测信息，简化前端；I-cache Miss 时则没有对应预测元数据，很难继续准确 Prefetch。NetBurst 很可能使用解耦 BTB，只要 Target 仍在表内，Predictor 就能充当远距离代码 Prefetcher。

### 体系结构视角：错误成本决定预测器的经济性

NetBurst 必须用强预测保护深 Pipeline；K8 恢复更快，给 Predictor 增加大量 SRAM 的边际收益较低。评价预测器不能只看 MPKI，还要乘以错误路径占据窗口、Redirect 与重新取指的总成本。

BTB/L1I 紧耦合省控制，却让 Target Lookahead 止于 I-cache Miss。验证需同步观察 Branch Mispredict、BTB Hit、L1I Miss、错误路径 In-flight Entry 与 Recovery Cycle。

## 取指：预解码 L1I 对抗 Trace Cache

K8 L1I 保存 x86 Instruction Byte，但在 Fill 时先做 Preliminary Decode，把 Instruction Boundary、Opcode Position 与 Type Metadata 一起写入 Cache；主 Decoder 因而少做一部分变长指令解析。

![图 8：K8 Die 上的 Frontend](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/4610da3774a4d366_08_k8_die_frontend.jpg)

*图 8：Die Photo 来自 Cole，标注给出 L1I、Predecode 与 Decode 的估计位置。预解码 Metadata 会增加存储，却保留普通 Byte Cache 的容量效率。*

NetBurst Trace Cache 直接存 Decode 后 Micro-op，极端优化 Fetch Bandwidth，却牺牲有效容量。

![图 9：K8 L1I 与 NetBurst Trace Cache 的有效覆盖](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/1f081b807187cd8a_09_instruction_cache_capacity.png)

*图 9：用 4-byte NOP 扫 Footprint 时，K8 的 Byte Cache 覆盖更大；实际 7-Zip 平均执行指令略短于 4 B，还会进一步帮助 AMD。Intel 自称 Trace Cache Hit Rate 类似 8 KB I-cache，同一 Memory Location 还可能在多条 Trace 中重复。*

K8 的 Coupled BTB 在 L1I Miss 后无法准确预测远端 Fetch Address，很可能因此只支持两个 Outstanding I-cache Miss，也就是两个 Miss Address Buffer（MAB）。更多 I-side MLP 若没有可靠 Target 也会浪费。于是 Working Set 落在 L2、超出 L1I 时，AMD 反而落后 NetBurst。

长指令又受 L1I 每拍 16 B 上限。8-byte NOP 要达到三条每拍需 24 B，K8 无法做到；Trace Cache 输出 Micro-op，绕过此限制。

![图 10：8-byte Instruction 下的前端 Byte Bandwidth](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/17868972603e881c_10_long_instruction_fetch.png)

*图 10：K8 在约 16 B/cycle 封顶，NetBurst Micro-op Cache 不按原始字节受限。2000 年代尚无更长 AVX/AVX-512 Prefix，这个问题没有后来严重；Large Immediate/Displacement 在 Trace Cache 也可能占两项。*

### 体系结构视角：Predecode 与 Micro-op Cache 是两种空间换时间

Predecode 只缓存 Boundary/Type，仍要经过主 Decoder，但单位 Byte 覆盖大；Trace Cache 跳过 Decode，输出快，却让同一代码因 Trace Path 重复、有效容量缩小。

真实收益由 Instruction Length、Code Footprint、Taken Path 和 L2 Refill 决定。应分别测 Byte/cycle、Instruction/cycle、MAB Occupancy 与 Decoder Stall，避免把“Cache 更大”直接等价为“前端更快”。

## Rename 与执行窗口：只做必要技巧

2006 年还没有今天丰富的 Rename Trick。K8 能识别常见 Zeroing Idiom、打断旧依赖，但不做 Move Elimination。

![图 11：Zeroing Idiom 的依赖消除](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/38190f990b3d8b91_11_zero_idiom.jpg)

*图 11：测试把 K8 的基础依赖消除与后来的 Golden Cove 并列；网页正式图注也调侃 Golden Cove 出现在这张图。重点是 K8 已做最重要的清零识别，而非达到现代 Rename 水平。*

Integer Side 采用类似 P6 的 ROB+Retirement Register File（RRF）；FP/Vector 则用 Physical Register File（PRF），ROB 保存指向独立 Vector Register 的 Pointer。实践中 120-entry FP Register File 足以覆盖扣除 Architectural State 后的整个 ROB，因此混合差异不形成主要容量瓶颈。

![图 12：K8 Die 上的执行与寄存器区域](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/6d5246b5cc42dca4_12_k8_die_execution.jpg)

*图 12：Die Annotation 是估计，网页正式图注明确不保证精确。它用于理解三 Lane Integer 与独立 FPU 的面积关系。*

K7 FP Register 为 88 项；x86-64 把 Architectural SSE Register 从 8 增到 16，K8 扩到 120，避免 Architectural State 吃掉太多 Rename Capacity。每个 Integer Scheduling Queue 也从 K7 增加两项，总计 24，K7 为 18；除此之外变化不大。

![图 13：K8 与 NetBurst 的重排序资源](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/4535536488a4098b_13_reorder_capacity.png)

*图 13：纸面上 NetBurst 在 ROB、Scheduler、Load/Store Queue 等容量大幅领先。它却不能在退休前取消已确认错误的 Bogus Operation，长延迟错误路径会继续占窗口；部分大容量还可能为 SMT Yield 配置，而非单线程最优。*

### 体系结构视角：可回收的窗口比名义窗口更重要

Mispredict 已确认却仍不能释放错误路径 Entry，会让 ROB 看似很大、可供正确路径使用的容量却缩小。窗口大小应结合 Recovery Policy、SMT Partition 和 Queue Binding 分析。

K8 容量小，却能较早取消错误工作。比较时应测 Correct-path In-flight、Squashed Entry Lifetime 与 Full Stall，而不只列总 Entry。

## Integer Execution：把同一套 Pipeline 复制三次

ROB 组织为 24 Line×3 Micro-op，可视作三 Lane。三条 General-purpose Pipeline 由 Forwarding Network 相连，每条都有小 Scheduler、ALU 与 AGU，并能处理把 Math 与 Memory 组合的 x86 Instruction。

K8 不像早期 P6 把 Load-op、Load-op-store 拆开，而保留为一个 Macro-op；Scheduler 需要时把它依次 Dispatch 到 AGU/ALU。一个复杂指令只占一项 ROB/Scheduler，比拆成两三项更节约窗口。

![图 14：K8 Integer Execution Unit](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/c6405fffcc1fa248_14_integer_execution.png)

*图 14：根据 Agner Instruction Table 重建。三 Lane 大体对称；Multiply 成本较高，只在第一条 Pipeline，Rename 会把 Multiply 分配到该 Lane。网页正式图注说明结构来源。*

对称设计简化 Round-robin Allocation，减少一条 Lane 满、另一条空的问题；模块也可设计一次、复用三份，甚至让指令从 Decode 到 Retirement 保持 Lane。

代价是资源过度复制。三条 AGU 永远无法全用满，因为 Dual-port L1D 限制 Memory Throughput；三条 ALU 都能做 Not-taken Jump、Shift，甚至 CWD、BSWAP、SAHF 都可三条每拍。作为对照，Golden Cove 对这些少见指令也只有一两个 Port。

### 体系结构视角：规则化结构用面积换控制简单

对称 Lane 降低 Steering、Scheduler Crossbar 与验证复杂度，Macro-op 又节约窗口；多复制的 AGU/特殊 ALU 功能则成为面积浪费。这里的“低效”可能换来了更短 Critical Path 和更稳定 Timing。

判断取舍需看 Port Utilization、Steering Stall 与物理面积，而非只数 Unit。很少同时使用的三份单元，可以是性能冗余，也可以是简化控制的代价。

## FP 与 Vector：独立 Coprocessor，专用但不宽

FPU 拥有自己的 Rename、36-entry Unified Scheduler 和 Register，只有 Retirement 仍占主 ROB。K8/NetBurst 都能让约一半 In-flight Instruction 是等待执行的 FP Operation，这一比例高于许多现代 CPU。

![图 15：K8 的 FP Scheduler 与执行资源](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/a9b5ca92520185ef_15_fp_scheduler.png)

*图 15：36-entry Scheduler 驱动三条 Specialized Pipe。Integer ALU 很小可复制，FP/Vector 面积高，AMD 因而没有复制三套通用 FPU。*

x87 Top-of-stack 会制造隐式依赖，独立 FP Renamer 还负责消除这类限制。

![图 16：K8 FPU 结构](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/c5857e3a5888c04a_16_fp_execution.png)

*图 16：来自 AMD Optimization Manual。执行单元为 64-bit，x87 为 80-bit；128-bit SSE 要拆成两条 Micro-op。网页正式图注说明来源。*

即便如此，K8 FP/Vector Throughput 仍优于同为 64-bit Unit、却只有一条相关 Pipe 的 NetBurst。Vector Integer 可用 K8 两条 Pipe；FP Add/Multiply Latency 都是四周期，NetBurst 分别为五、七周期。

### 体系结构视角：独立 FPU 让窗口容量按工作负载重新分配

36 项专用 Scheduler 在 FP-heavy Code 中很慷慨，Integer-heavy 时却无法借用。它降低统一 Scheduler 的端口和比较复杂度，也让不同负载的有效窗口差异更大。

128-bit SSE 拆两拍说明 ISA Vector Width 可以先于物理 Data Path 演进。报告峰值时必须区分 Instruction Throughput、Micro-op 数和每拍实际处理 Bit Width。

## Load/Store：检查简单，失败代价却温和

Load 必须判断 Data 来自 Cache，还是来自更老的 In-flight Store。完整比较昂贵，通常以 Fast Path 覆盖常见情况，困难组合回退到等待 Store 完成后再读 Cache。

![图 17：K8 Die 上的 Load/Store 区域](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/dffdd8bd39f26f9e_17_k8_die_lsu.jpg)

*图 17：Die Photo 来自 Cole，标注估计 LSU、L1D 与 Queue 位置。实际比较器与 Bank 边界无法由照片确认。*

K8 的 Memory Ordering Check 极其基础：只有 Exact Address Match 且 8-byte Aligned 才能 Forward。NetBurst 对同地址更灵活，除非访问跨 64 B Cache Line。

![图 18：Athlon 64 的 Store-to-load Forwarding](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/055294e666b19523_18_k8_store_forwarding.png)

*图 18：成功约五周期；Failed Forwarding 多为十周期，跨 8 B Boundary 时约十五周期。非重叠访问跨 8 B 也会降吞吐。网页正式图注强调：检查基础，但回退代价适中。*

![图 19：NetBurst 的 Store Forwarding](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/404e17a9acccf218_19_netburst_store_forwarding.png)

*图 19：NetBurst 成功同样约五周期，覆盖 Case 更广；失败却要约 51 周期。Misaligned Load/Store 可能多 23～100 周期，K8 通常只多一两周期。*

K8 的 Queue 组织也很独特，不分传统 LQ/SQ，而是两级 Unified Queue：第一层 12 项，保存等待 Probe L1D 的 Memory Operation；完成 Probe 后进入第二层 32 项，等待 Retirement。

![图 20：K8 两级 Unified Memory Queue](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/89990d56c9b2fc7a_20_memory_queue.png)

*图 20：最多追踪 32 个 In-flight Memory Instruction，没有单独 Load/Store 上限，因而能以较少总 Entry 动态适配读写比例。NetBurst 的 Load、Store Queue 各自都超过 32 项，纸面容量仍占优。*

### 体系结构视角：Fast Path 覆盖率与 Recovery Cost 必须一起看

NetBurst 识别更多 Forward Case，失败一次却损失 51 cycle；K8 只认最简单对齐匹配，回退为 10～15 cycle。真实性能取决于各 Case 频率乘惩罚，而不是“支持情况”越多就一定越好。

Unified Queue 也在平均利用率与并行流程之间取舍：读多写少时容量更灵活，所有 Memory Operation 共用管理逻辑可能增加 Port/Arbitration。验证应报告 Hit Case 分布、Replay/Wait Cycle、两级 Queue Full 与 Load/Store Mix。

## Cache、TLB 与集成内存控制器

每颗 K8 有 64 KB L1D 和 1 MB L2。L2 是 Victim Cache，与 L1D Exclusive；两级都是 Write-back，Data 受 ECC 保护。

### 延迟

L1D 只有三周期，使 2.8 GHz FX-62 即便频率低于 Pentium EE 965，实际 L1D 时间仍相当。

![图 21：K8 与 NetBurst 的 Cache/Memory 绝对延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/d1e6a149ed1ac5fa_21_cache_latency_time.png)

*图 21：上半按纳秒展示，K8 的 L1/L2/DRAM 路径都很短；具体平台与 Memory Timing 不同。*

![图 22：相同结果按周期表示](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/965129fa1a65b26b_22_cache_latency_cycles.png)

*图 22：下半按 Core Cycle 展示，NetBurst 高频使周期数与纳秒的观感不同。读图必须同时看两种单位。*

K8 L2 容量更小，延迟也低得多。Hot Chips Slide 暗示 11 cycle，实测 1 MB 配置约 12.5 cycle；11 可能只适用于更小 L2 Variant，但材料无法确认。

![图 23：AMD Hot Chips 14 的 K8 Cache 资料](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/b91e188224043924_23_k8_hot_chips_cache.png)

*图 23：2002 年 Slide，红字为后加 Annotation。官方参考值与 FX-62 实测不完全一致，应同时保留。*

Cache Miss 后，Integrated Memory Controller 让 Athlon 以约 60 ns 访问 DRAM，今天看仍很不错。NetBurst 要穿过 Motherboard Chipset，超过 94 ns；Intel 可能因此用更大 L2 降低昂贵 DRAM Access 频率。

4 KB Page 节省 Memory Fragmentation，却降低 TLB Coverage。NetBurst 64-entry dTLB 在 256 KB 以下略占优；K8 L1 dTLB 只有 32 项，超过 128 KB 后 Translation Penalty 抬高有效 L2 Latency。更大 Working Set 时，K8 还有 512-entry L2 TLB，NetBurst 没有，只能承担 20+ cycle Page Walk；Page Table 自身掉出 Cache 后更糟。1 GB Array 中 K8 Latency 近乎只有 NetBurst 一半。

![图 24：4 KB Page 下的 TLB/Memory 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/22659ed1cd3551bb_24_tlb_memory_latency.png)

*图 24：Intel 在小区间受 64-entry L1 TLB 帮助，AMD 从二级 TLB 覆盖的大 Working Set 开始反超。它展示 TLB 层级比单级 Entry 数更重要。*

### 带宽

Cache Bandwidth 不是 K8 强项。NetBurst Data Path 更宽、频率更高，SSE Read 在各 Cache Level 都领先。K8 的 128-bit `MOVDQA/MOVDQU` 拆成两条 64-bit Micro-op，且只能走 FSTORE Pipe，每两周期一条；64-bit Scalar Load 却可每拍执行，并由 Dual-port L1D 限制。这造成 Bandwidth-hungry Vector Code 反而得到比 Scalar 更低的 Cache Bandwidth。

![图 25：K8 与 NetBurst 的 Cache 读取带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/96f38496b98ee2dd_25_cache_read_bandwidth.png)

*图 25：NetBurst 在 L1/L2 的宽度和频率优势明显；K8 的优势不在峰值 Cache Bandwidth。*

到 DRAM 并加载两颗核心后，Integrated Memory Controller 与更快 Memory 配置让 K8 Bandwidth 继续扩展；Pentium EE 965 的所有线程反而因 Shared Front-side Bus 争用而下降。

![图 26：双核/多线程 DRAM 读取带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/ffa77834aba5215c_26_multicore_dram_bandwidth.png)

*图 26：FX-62 为 DDR2-800 4-4-4-12，Pentium EE 965 为 DDR2-533 3-3-3-9。网页正式图注明确内存不同，因此结果体现 Platform，而非 Core-only。*

K8 L1D 是 Write-back，写入先留在 L1，逐出时才下写；NetBurst L1D 是 Write-through，每次写同时进入 L2，Write Bandwidth 被 L2 限制。

![图 27：K8 与 NetBurst 的写带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/0bc50814e973ca8f_27_write_bandwidth.png)

*图 27：L1 范围内 AMD 大幅领先，Intel 在 L2 略胜，DRAM 又落后。Write Policy 直接改变“L1 写峰值”的含义。*

### 一致性延迟

![图 28：K8 双核与 NetBurst 的核间延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/1b03e2901ce87257_28_core_to_core_latency.png)

*图 28：需要跨核搬移数据的 Contended Lock 在 NetBurst 更贵，因为 Off-core Communication 要经过外部 Northbridge；K8 由集成 Northbridge 处理，路径更短。*

### 体系结构视角：集成内存控制器改变的不只是 DRAM 延迟

把 Controller/Northbridge 收进 CPU，既缩短 Memory Access，也改善跨核和未来跨 Socket 的路由控制；HyperTransport 又提供高带宽 Socket Link。它是 System Architecture 变化，而非简单给 Core 加一个 Unit。

Exclusive Victim L2 提高总有效容量，Write-back L1 保住写带宽，二级 TLB 避免大 Working Set 直接 Walk。K8 的多项“基础选择”在端到端上相互加强。

## K8 与 NetBurst：两种设计哲学的对照

![图 29：K8 与 NetBurst 的主要优劣](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/01305483a66e2663_29_k8_netburst_summary.jpg)

*图 29：NetBurst 强在预测、目标缓存、窗口与 Cache 峰值；K8 强在低 Latency、温和慢路、Write-back L1、二级 TLB、集成内存控制器与一致性路径。图表是全文总结，不代表每项可独立决定性能。*

K8 只是 K7 的小步演进：Integer Queue 每条多两项、TLB 翻倍、FP Register 增加以适配更多 SSE Architectural Register；Width、ROB、Execution Layout 基本没变。按 Intel Tick-tock 语言，它介于一次 Tick 与 Tock 之间。

纸面上，K8 窗口小、几乎没有炫目技巧，Store Forwarding 甚至要 64-bit Alignment；面对 NetBurst 怪兽似乎毫无胜算。但规格容易误导，复杂机制不能替代基础。K8 的 Architecture 更“宽容”：多数异常 Case Penalty 温和，L1/L2/DRAM Latency 低；沿成熟设计谨慎迭代，反而获得更高 IPC 并保持竞争力。

![图 30：Athlon 64 K8 Die](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_athlon_64_wechat_article_zh/6c93126f06030782_30_k8_die_final.jpg)

*图 30：Cole L 的 Die Photo。K8 没把最大面积押在新奇前端，而把工程资源投入 x86-64 与 Integrated Memory Controller 等系统变化。网页正式图注说明照片来源。*

x86-64 相对等价 x86-32 实现只增加约 2%～3% Die Area，并尽量保持 32/64-bit Encoding 相近，兼容现有代码。文章将其与 Arm 从 32 到 64 bit 大改 Encoding 的路线对比：后者增加译码复杂度，也最终难以无限期保留 32-bit Compatibility。这是架构路线判断，不是仅由 Die 图证明的结论。

K8 Integrated Memory Controller 降低 Latency、提高 Bandwidth，HyperTransport 又服务 Multi-socket。AMD 把有限工程资源投向 ISA 与 System Level，得以在 2000 年代中期对抗更大的 Intel。

不过原始 Athlon Core 诞生于 1999 年，到 2006 年已显老。当 Merom 在年末出现，K8 不再能靠小修小补维持竞争力。

### 体系结构视角：从 K8 可以归纳出的七点认识

第一，平均性能来自“收益×命中率－失败×惩罚”。K8 Forward Case 少，失败 10～15 cycle；NetBurst 覆盖广，失败 51 cycle。机制先进程度不能脱离慢路成本。

第二，短 Pipeline 降低了对极端预测器的依赖。K8 Pattern/BTB 都弱，恢复快却让 MPKI 的每次代价较小；NetBurst 必须用更强预测保护更深 Speculation。

第三，窗口的可回收性和绑定方式比总项数重要。错误路径长期占据 NetBurst 大窗口，K8 小窗口能较早释放；Unified Memory Queue 又按 Load/Store Mix 动态分配。

第四，规则化三 Lane 是 Control Complexity 与面积的交换。重复 AGU/ALU 看似浪费，却简化 Steering、Timing 和模块复用；Macro-op 还节省 ROB/Scheduler Entry。

第五，TLB 层级决定大 Working Set 的尾延迟。K8 32-entry L1 在小工作集上落后，512-entry L2 让它避免 NetBurst 20+ cycle Walk，1 GB Array 最终近乎快一倍。

第六，Memory Controller 是核心性能的一部分。60 ns DRAM、可扩展双核带宽和更低 Coherency Latency 共同证明，Uncore 设计能抵消 Core 前端的纸面落后。

第七，有限研发资源要投向不可替代的差异。AMD 没有复制 NetBurst 的所有技巧，而完成 x86-64、Integrated Memory Controller 与 HyperTransport；这些改造比多几项 Scheduler 更长久。

## 参考资料

- Chips and Cheese：[*AMD’s Athlon 64: Getting the Basics Right*](https://chipsandcheese.com/p/amds-athlon-64-getting-the-basics-right)
- AMD：K8 Optimization Manual 与 Hot Chips 14 Slides（正文图中援引）
- Agner Fog：Instruction Tables（正文执行端口分析援引）
