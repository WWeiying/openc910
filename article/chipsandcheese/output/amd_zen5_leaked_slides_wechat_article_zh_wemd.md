---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "amd_zen5_leaked_slides_wechat_article_zh"
---

> 英文标题：Zen 5’s Leaked Slides<br>
> 撰文：Chester Lam<br>
> 首发：Chips and Cheese，2023 年 10 月 8 日<br>
> 原始链接：https://chipsandcheese.com/p/zen-5s-leaked-slides

2023 年 10 月，YouTube 频道 Moore’s Law is Dead（MLiD）展示了几张据称来自 AMD 的 Zen 5 幻灯片。泄露材料通常无法核验，也经常与最终产品不符。RDNA 3 在发布前被传得足以压过 Nvidia Ada，就是一个反例：AMD 同时在 CPU、GPU 两条战线上对抗规模更大的竞争者，却总被传闻要求下一代创造奇迹。

![图 1：MLiD 展示的 Zen 5“微架构亮点”页面，真实性在文章发表时无法确认](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_leaked_slides_wechat_article_zh/614ed182d74445d6_01_figure.jpg)

这次材料至少列出较完整的架构方向，比编造几个性能数字更难保持内部一致，因此值得逐条提供背景。但本文不试图“证实”或“证伪”，更不会把后来产品信息倒灌回 2023 年的判断；所有具体 Zen 5 参数仍属于当时泄露内容。

## 分支预测

branch predictor 为流水线选择下一段取指地址。预测太慢会堵住前端，预测错误则让核心在无用路径上花时间和功耗。泄露页列出“zero-bubble conditional branches”“high accuracy”“larger BTB”。

### Zero-bubble 并不是新能力

zero-bubble 表示处理 branch 时不延迟后续 instruction，像液体管道中没有气泡，不损失前端输送率。

![图 2：A64FX 预测/取指流水线，展示快速小型 predictor 与较慢 BTB 路径](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_leaked_slides_wechat_article_zh/f484947ce0ca420e_02_figure.png)

Zen 1 已能让少量 branch 走 zero-bubble path；Zen 3 把这级 BTB 扩到约 1024 target，使快速路径成为常态；Zen 4 再到约 1536。conditional branch 也一直可以 zero-bubble，并非只有 unconditional branch。

![图 3：Zen 4 上 conditional always-taken 与 unconditional branch 的吞吐差异很小](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_leaked_slides_wechat_article_zh/588b80c081943bc1_03_figure.png)

Intel Haswell 更早就能跟踪约 128 条 branch 并以零气泡处理。Zen 3 以后 AMD 的快速容量更大，但 Intel 同样不弱。因此，这行字本身几乎没有新信息；也许 Zen 5 扩容了快速 predictor，但 slide 没说。

### “高准确率”和更大 BTB

AMD 每代都在提高预测准确率，Zen 2/3/4 在不少场景胜过同期 Intel。Zen 5 当然会继续追求准确，但“桌面 CPU 预测很准”就像“客机机舱加压”一样，本应如此；Phenom 时代更简单的 predictor 也能预测绝大多数 branch。

BTB（Branch Target Buffer）缓存 target，让分支尚未进入执行核心时，前端就知道下一次从哪里 fetch，尤其能避免 branch instruction 本身从 L2 或更远处取回后才重定向。AMD 每代调整容量，但当时仍落后 Intel 最强实现。

![图 4：Zen 4、Golden Cove 等核心的 branch target tracking；Golden Cove 最后一级 BTB 容量约高 50%](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_leaked_slides_wechat_article_zh/6119e6505ca580b7_04_figure.png)

Zen 4 在游戏中存在 frontend latency 问题，Intel 同样可能受大代码 footprint 影响，因此两家都会在晶体管预算允许时扩 BTB。

### “2 Basic Block Fetch”有三种解释

basic block 是只有一个入口、一个出口的连续代码段；即使 conditional branch 最终 not taken，它也标志着 block 边界。

![图 5：三个基本块的假想代码布局](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_leaked_slides_wechat_article_zh/f813ce00b524f762_05_figure.png)

最普通、也最可能的解释是：Zen 5 能跨 not-taken branch 继续取指。过去二十年的高性能 AMD/Intel core 本来就能做到。

![图 6：顺序布局且 branch not taken 时，一个 fetch 可跨越两个 basic block](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_leaked_slides_wechat_article_zh/0a9cca1a587aef93_06_figure.png)

更有意思的解释是跨 taken branch fetch。Rocket Lake 的 loop buffer 能展开短循环，从取指视角把 taken edge 变成顺序；Neoverse N2 与 Cortex-X2 的 64-entry nano-BTB 可持续每周期两条 taken branch。这能帮助高 IPC、branch-dense 代码。既然多家已经实现，Zen 5 支持每周期多于一条 taken branch 并非离谱，但 slide 仍不足以确认。

![图 7：跨 taken branch 取两个 block 需要多目标预测、双取指路径和下游 merge](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_leaked_slides_wechat_article_zh/6e9c518968564c9a_07_figure.png)

最激进的解释是让大多数 basic-block crossing 都双路 fetch，而不依赖小 loop/nano-BTB。这可能要求 dual-ported I-cache 或 uop cache、大 BTB 同周期给两个 target，再把两个 fetch block 合并给后级。面积功耗很高，只帮助少数 frontend-throughput-bound 高 IPC 代码，而 I-cache miss 引起的 latency 往往更重要，所以作者认为不划算。

### 体系结构视角：营销短语必须落到“哪一级、多少容量、每周期几个目标”

zero-bubble 可以只覆盖一个很小的快速 BTB，也可以覆盖常用 working set；“two block”可能只是跨 not-taken 边界，也可能是 two-taken-target。性能差异巨大。真正验证要扫 branch footprint、taken density、target alignment 与 loop size，并结合 BTB miss/resteer、fetch block 和 decoder utilization 计数器。slide 没给这些维度，所以只能列出可行解释。

## Load/Store：更大的 L1D、DTLB 与 Page Walk Cache

### 48 KB、12-way、仍为 4 周期的 L1D

泄露页称 Zen 5 L1D 从 Zen 4 的 32 KB、8-way 增至 48 KB、12-way，latency 仍为 4 周期。Sunny Cove 也把 Intel L1D 增到 48 KB，却从 4 增到 5 周期。

容量提高可减少 capacity miss，associativity 提高可减少“总容量足够、hot address 却冲到同一 set”的 conflict miss。但 12-way 意味着每次 access 要筛选更多 way。Zen 使用 micro-tag，先比较 partial tag 预测命中 way；即便如此，若每周期四条 load，直观上也可能涉及 `12 × 4 = 48` 次 micro-tag compare，时序和能耗都不轻。

### 更大 DTLB 的具体层级未知

virtual memory 由 page table 把进程 virtual address 映射到 physical address。若每次 load/store 都查多级表，一次程序访存会变成数次依赖内存访问，因此 TLB 缓存常用 translation。

![图 8：x86-64 四级页表以及一次 page walk 的依赖访问路径](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_leaked_slides_wechat_article_zh/e3bc4f390c1898e7_08_figure.png)

Zen 4 一级 dTLB 已从 64 项增至 72 项。小型一级 TLB 常为 fully associative，消除 conflict miss，却要把请求与所有 entry 比较。若四条 data access/cycle，对 72 项可达 288 个 tag comparison。Zen 5 若继续扩容又保持 latency，可能改用类似 128-entry、16-way set-associative 的组织；容量更大、每次比较更少，但引入 set conflict。这只是示例推测。

另一种可能是一级不动，只扩 L2 dTLB。Zen 4 已从 Zen 3 的 2048 项增到 3072 项，再扩可帮助 multi-megabyte hot footprint。slide 只写“larger DTLB”，无法判断发生在哪一级。

### 更大 Page Walk Cache

TLB miss 不一定要从 page-table root 完整走到底。Page Walk Cache（PWC）保存上层 page-table entry，让 walker 从较低层开始，减少依赖 memory access。一个 cached Page Directory Pointer Table entry 可覆盖 1 GB，比单个 4 KB TLB entry 覆盖范围大得多。

![图 9：不同 PWC 组织可在“覆盖更大地址范围”与“少走更多层”之间取舍](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_leaked_slides_wechat_article_zh/0a9081506142b10f_09_figure.png)

原文用投石机解释：遛狗要走四个街区，投石机先把人和狗抛过两个街区，就能从中途开始；目的地方向不同，就造 64 台朝不同方向的投石机。抛得更远能少走更多路，抛得较近却能覆盖更多终点，而数量、威力都消耗面积和“木材”——这正是 PWC entry 覆盖层级与容量的权衡。

从 Zen 1 起，AMD 有 64-entry Page Directory Cache（PDC），保存 Page Directory Pointer Table 与 PML4 entry；L2 TLB entry 也能缓存 Page Directory entry。Zen 5 可能扩 PDC，也可能让 LSU 更倾向在 L2 TLB 中保留 directory entry，而不是 direct translation。仍没有足够信息判断。

## 更高吞吐：8-wide dispatch/rename 与 fusion

Zen 代际的持续吞吐提升较温和，因为 core width 很少是主瓶颈。Zen 1/2 可持续约 5 instruction/cycle，Zen 3/4 约 6；每代两位数 IPC 更多来自 instruction/data memory access 改进。

![图 10：AMD Zen 3 Hot Chips 图，IPC 增长主要来自 cache、frontend、branch predictor 与 load/store](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_leaked_slides_wechat_article_zh/970030f9c3269f09_10_figure.png)

少数高 IPC 程序仍可能受 core width 限制。各代 Zen 前端和 retire 至少 8-wide，但 dispatch/rename 只有 6 uop/cycle。若 Zen 5 扩到 8-wide，就能持续分配 8 uop/cycle。

![图 11：Samsung Exynos 论文中的 IPC 分布，只有少数 workload 接近宽度上限](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_leaked_slides_wechat_article_zh/ab93e30000205b48_11_figure.png)

高 IPC 程序可受益，游戏等低 IPC、cache/memory-latency-bound workload 则很少因为宽度本身变快。

op fusion 把相邻 instruction 合成一个内部 uop，提高吞吐并节省 queue。最常见是设置 flags 的 ALU 指令加 conditional branch。Intel/AMD 已做多代，近期 Arm 也融合等价 AArch64 sequence。Zen 3 从 CMP/TEST 扩展到 ADD/AND/XOR + branch，并能写回运算结果；Zen 4 增加 NOP fusion 和 `XOR+DIV`/`CDQ+IDIV` 等常见除法准备序列。

泄露页只写 fusion，没有列新组合，可能只是重复 Zen 4 已有能力。branch 已覆盖最大收益，NOP 很少真正执行，compiler 又会避免昂贵 division；继续扩展很可能是边际收益。

## 更大、更统一的 Scheduler

scheduler 每周期监视 result broadcast，唤醒等输入的 uop，再从 ready set 选出可进入 execution unit 的操作。若 wakeup/select 无法在一个周期完成，额外 pipeline stage 据引用研究会造成约 10% IPC 损失，因此“大而快”很难。

distributed scheduler 为不同 port 配私有 queue，每个只选一条，设计简单且容量可按预计流量配置；但一个 queue 填满就会阻塞 rename，即使其他 queue 还有空位。

![图 12：Henry Wong 博士论文中的 distributed scheduler 设计空间](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_leaked_slides_wechat_article_zh/282d6d3ad4157f17_12_figure.png)

unified scheduler 让多个 port 共享 entry，更能吸收某类操作突增，却必须每周期完成多路选择。近期 AMD、Intel、Arm 都采用混合方案。

![图 13：Zen 1、Zen 2 与 Zen 3/4 的分布式/部分统一 scheduler 演进](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_leaked_slides_wechat_article_zh/d4cea3154ef2db58_13_figure.png)

泄露页称 Zen 5 scheduler 更大、更 unified，意味着 entry 增加，也能更灵活使用。对两个游戏的观察显示 integer scheduler 0 略比其他队列常满。

![图 14：两个游戏中触发 rename/dispatch stall 的资源分布](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_leaked_slides_wechat_article_zh/d2187505928cfc22_14_figure.png)

Cinebench 2024 整数侧也相似。scheduler 0 服务一条 AGU 和一条 ALU/branch pipe，AMD 可扩它、与另一队列合并，或两者兼用。

![图 15：Cinebench 2024 的 scheduler-related dispatch stall，integer scheduler 0 占比最高](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_leaked_slides_wechat_article_zh/aed4eb82c43a7c87_15_figure.png)

不过整数 scheduler 相关 stall 仍只是 single-digit percentage，说明 Zen 4 分布式组织已经调得不错，改造空间有限。

### 6 个 ALU、4 load、2 store

泄露页称 Zen 5 有 6 ALU，且每周期 4 load/2 store。此前各代 Zen 都是 4 ALU，峰值 scalar integer throughput 因而可提高 50%。

实际收益可能很小。scheduler 会因 port 不足而 full，也会因长 dependency latency 而 full，因此 scheduler-bound stall 只是“execution-unit-bound 时间”的上限，而图中这个上限并不高。4 load/2 store 可能帮助 memcpy 等特殊场景，普遍收益未知。

ALU/AGU 本体很小，喂数据才昂贵：每个新 port 都要增加 register-file read/write port、scheduler select 与 bypass network，面积功耗会快速上涨。

![图 16：一种低增量成本的 6 ALU、4 AGU 假想布局，AGU 与 branch port 兼做简单 ALU](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_leaked_slides_wechat_article_zh/f4376e255b1b3515_16_figure.png)

作者设想最省成本的方法是让 AGU port 兼做 ALU——AGU 本来就要对 register input 做简单加法；branch port 也可升级为 ALU，复用既有 register-file port。该图是个人方案，不是泄露的 Zen 5 实现。若用很低代价取得小收益，仍然值得。

### 体系结构视角：端口数量不是吞吐承诺

峰值需要前端持续提供 uop、rename 不停顿、scheduler 找到足够独立 ready 操作、PRF/旁路网提供输入，最后 load/store 还要 cache bank 和 TLB 同时接住。增加 ALU 很容易，增加可持续 feed bandwidth 很难。验证“6 ALU/4 load”要构造无依赖、严格端口映射的微基准，并同时观察 dispatch、issue、load/store pipe 与 cache bank conflict；真实应用则要先确认这些端口原来是否经常饱和。

## 更大的乱序结构

乱序 core 用 ROB、PRF、load/store queue 等保存 speculative state，直到结果按序成为 architectural state。结构几乎每代都扩，泄露页也写 Zen 5 更大，却没有数值。

![图 17：Cinebench 2024 中 Zen 4 的 dispatch stall，ROB full 是主要来源之一](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_leaked_slides_wechat_article_zh/50636def5238c466_17_figure.png)

ROB 跟踪后端全部 instruction，限制核心能越过 stalled instruction 看多远。ROB fill 并非设计失败，它也说明更专用的 queue 足够大，没有更早成为瓶颈。

![图 18：AMD 各代 ROB 容量，从 Phenom 72、Piledriver 128 到 Zen 4 320 项](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_leaked_slides_wechat_article_zh/ed63f57cae1c75c4_18_figure.png)

AMD 每代增加 ROB，Zen 5 很可能继续，但幅度未知。ROB 扩大后，其他结构也要扩，避免先行 full。Zen 4 store queue 已可能是候选；但它要保存 pending store data，每项最多 32 byte，扩容的 SRAM/端口成本不低。

slide 的“64 Byte Fills/Victim”令人困惑。近代 CPU 本就以 64-byte cache line 管理 fill 和 victim，淘汰/带入都是 64 byte，这一行若没有额外上下文几乎没有信息量。

## Data Prefetching

更大 cache 降低实际命中 latency，更大窗口允许越过 stalled load，prefetcher 则尝试在 demand instruction 到达前把数据取来。

![图 19：Zen 3/4 的 L1 与 L2 data prefetcher，包括 stream、stride、region 与 up/down 模式](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_leaked_slides_wechat_article_zh/3d7de1f90e92c284_19_figure.png)

slide 没给 Zen 5 细节。它可能沿用 Zen 4 方法，却利用更成熟 DDR5 的带宽看得更远；也可能在多核高带宽压力下更强地保证 demand request 优先。二者都只是可能方向。

## 更强 AVX-512

Zen 4 是 AMD 首次支持 AVX-512。它不像早期 SSE/AVX 那样把宽向量先拆成两个 uop，而是使用完整 512-bit vector register，让一条 AVX-512 math instruction 以一个 uop 留在后端，最终在 256-bit datapath 上分两拍执行。

![图 20：AMD ISSCC 对 Zen 4“power-efficient AVX-512”的说明，512-bit 操作由 256-bit datapath 执行](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_leaked_slides_wechat_article_zh/9aabc9f7f5c01f69_20_figure.png)

这样保持与 Zen 2/3 相近的 FP execution throughput，却得到 AVX-512 更高表达密度、较少 backend resource 占用等关键收益，避免大幅增加面积功耗。

泄露页写“FP Pipes/Units at 512b”。最乐观解释是 `2 × 512-bit` FP vector execution，但即使 TSMC 4 nm，面对消费应用很少使用 512-bit vector，这仍可能太昂贵。AMD 也可能像 Intel 一样，为不同 Zen 5 variant 配不同 FP 宽度，client 节省面积功耗。

Zen 4 的 store queue 每项只保存 256-bit pending data，512-bit store 处理较低效；AMD 在 Hot Chips 2023 说，缓冲 512-bit store data 的面积开销不可接受。泄露页又写“Load/Store Queues (512 bit)”，可能表示立场改变。若这些说法都准确，重度 AVX-512 应用会受益；具体 pipe 数与 queue 组织仍未确认。

## 把每一项放回 Zen 演进

Zen 2 相对 Zen 1 大幅改善 branch prediction、vector throughput 与 cache capacity；Zen 3 用更强 BTB 缓解 Zen 2 前端延迟，并重组 scheduler 避免 AGU queue 常满；Zen 4 扩 uop cache、L2 与乱序窗口，引入 AVX-512。若泄露方向成立，Zen 5 主要是在低垂果实减少后，提高 core throughput，并补强 AVX-512。

![图 21：AMD 官方 Zen 4 desktop IPC 构成，约 13% 增长来自多个前后端小改进](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_leaked_slides_wechat_article_zh/6b445a4deb7d2a04_21_figure.png)

但不能把当前 leak 看得太深。细节稀少给了解释很大空间，核心行为还可由 microcode 调整，架构本身也可能配置化；Zen 2 就有不同 FPU 配置。

![图 22：MLiD 展示的另一张 x86 roadmap，暗示不同 FP-512 variant；仍属未核验材料](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_leaked_slides_wechat_article_zh/37590ab89c04e947_22_figure.jpg)

性能数字更应先当猜测。即使消息源是工程师，一个特定 trace 在 simulation 中提升 30% IPC，也不代表其他应用得到同样幅度。

![图 23：AMD 官方历代 desktop IPC 图，Zen 2/3/4 的典型代际增幅约 10%—20%](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_leaked_slides_wechat_article_zh/b0e8e0574c3ddd37_23_figure.jpg)

中间信息经转述后，很容易丢掉“仅对一条 trace”的测试条件。

![图 24：Red Gaming Tech 视频中的 Zen 5 传闻汇总，声称 20%—30% IPC 等多项提升](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_leaked_slides_wechat_article_zh/d5bc4719c7cf3af6_24_figure.jpg)

20%—30% 并非物理上不可能，却显著高于 Zen 2/3/4 通常的 10%—20%，而 RDNA 3 传闻已有失准先例，因此应保持怀疑。

## 结语

泄露页最有价值的用途不是提前宣布 Zen 5 规格，而是列出值得验证的问题：快速 BTB 是否扩容、two-block 是否跨 taken branch、48 KB L1D 如何维持 4 周期、DTLB/PWC 扩在哪级、scheduler 如何统一、执行端口能否持续供给，以及 512-bit datapath 到底覆盖哪部分。

真正评价产品，应等待 AMD 工程团队公开设计，再用明确版本、频率、内存、compiler 与 workload 复测。若最终产品提供正常的 10%—20% 代际提升，却因虚构或误读的早期数字而被视为失败，既不尊重工程工作，也没有比较意义。AMD 的表现应放在同期 Intel、Arm 等对手的进展中判断，而不是拿传闻当基线。
