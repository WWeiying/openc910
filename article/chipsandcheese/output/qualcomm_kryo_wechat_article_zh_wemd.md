---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "qualcomm_kryo_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*Kryo: Qualcomm’s Last In-House Mobile Core*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2023 年 7 月 13 日
> - 链接：https://chipsandcheese.com/p/kryo-qualcomms-last-in-house-mobile-core

CPU 设计很难，真正长期投入自研核心的公司并不多。今天的 Android SoC 即使挂着各家品牌，CPU Architecture 也大多来自 Arm Cortex；但在 2016 年以前，Samsung 还有 Mongoose，Qualcomm 也沿着 Scorpion、Krait 做到了第一代 64-bit Kryo。

Kryo 既是 Qualcomm 第一颗、也是当时最后一颗自研 64-bit Arm 移动核心。它还采用一种少见的 Hybrid 方案：Big/Little 两组使用同一套微架构，只改变频率和 Cache 配置，而不是像 Arm big.LITTLE 那样搭配两种核心。

![图 1：Snapdragon 821 的两组 Kryo Cluster](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_kryo_wechat_article_zh/6f6390c008d37f69_01_big_little_clusters.png)

*图 1：`lscpu` 显示两个 Cluster。网页正式图注指出，小核虽然最大频率标为 2.18 GHz，负载下却很少达到该值，通常停留在约 1.58 GHz。*

Kryo 首发于 Snapdragon 820，接替口碑不佳的 Snapdragon 810。本文测试 Snapdragon 821/LG G6；Android 的后台噪声让微基准很难稳定，系统又无法提供 Huge Page 进行内存延迟测试。网页明确要求对结果保持谨慎，也没有完整给出 Android 版本、编译器与 Flags、温控、重复次数和误差。

## 总览：2016 年移动端少见的四宽乱序核

Kryo 是四宽乱序架构，拥有相当可观的重排序容量和丰富执行资源。同期 Arm 是三宽 Cortex-A72 与两宽 Cortex-A73；宽度本身不能决定性能，但 Kryo 在多数结构上确实更激进。

![图 2：Kryo 微架构总览](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_kryo_wechat_article_zh/a9570eed7936013c_02_kryo_block_diagram.png)

*图 2：四宽前端连接较大的 Integer/Flags Register File、以双端口队列为核心的 Integer Scheduler、分布式 FP/Memory Queue，以及四条 ALU、FP/Vector 和 Load/Store 单元。网页正式图注明确：这张图几乎完全来自 Reverse Engineering，不是 Qualcomm 官方框图或 RTL。*

### 体系结构视角：四宽只是“入口”，持续吞吐取决于整条链

要把四条 Instruction/cycle 变成 IPC，预测器必须连续给出正确 PC，L1I 要持续供字节，Rename/Queue 要有空项，执行端口要匹配，Cache 还要及时返回数据。任何一级只有一 IPC，四宽峰值就会失去意义。

Kryo 的故事正是这种不均衡：前端宽、整数后端强，L2/TLB 和持续散热却喂不饱它。分析应把“核心能处理多少”与“系统能供给多少”分开。

## 分支预测：Pattern 能力接近 A72，容量不追桌面核

错误路径既浪费时间也浪费手机电量，但更复杂的 Predictor 同样消耗面积和功率。Kryo 的方向预测属于低功耗核中规中矩的水平。

![图 3：Kryo 的随机分支模式识别](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_kryo_wechat_article_zh/9a0c012ae69e2b97_03_kryo_branch_pattern.png)

*图 3：单个或少量 Branch 的 Pattern 加长后，低延迟区域逐步破裂。曲面反映 History、Capacity 与 Aliasing 的共同影响，不能据此确认具体算法。*

![图 4：Cortex-A72 的同类分支模式测试](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_kryo_wechat_article_zh/c34bce451c2ca0e7_04_a72_branch_pattern.jpg)

*图 4：Kryo 与 A72 对 Pattern Length 的承受能力接近，但活跃 Branch 很多时 Kryo 更容易退化；两者都远不及 Skylake，这符合移动核的面积和功耗定位。*

### Branch Target Cache

程序平均约每十条指令就有一个 Branch，Taken Redirect 的速度十分重要。Skylake 用很大、很快的目标表解决问题；Kryo 面向低频移动 SoC，更偏向保守设计。

![图 5：Kryo 的 Taken Branch 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_kryo_wechat_article_zh/1a2f017818604302_05_branch_target_latency.png)

*图 5：极小 Loop 中约八项快速 BTB 可让 Back-to-back Taken Branch 零 Bubble；之后并没有清晰的大 BTB 台阶。8-entry 容量与其余结构均来自曲线解释。*

一种可能的结构是：8-entry BTB 配合快速 Branch Address Calculator，再加 L0+L1 Instruction Cache。Qualcomm 的 Krait 曾使用 L0 I-cache，因此有设计先例；若假说成立，L0 约 8 KB、两周期。超过 8 KB 后分支代价虽变化，通常仍在 Last-level BTB Hit 常见的五周期左右。但这只是微基准推测，不能当作确认实现。

更明显的缺点是 Predictor 无法有效驱动跨 Cache 的 Instruction Prefetch。测试越过 L1I 后 Taken Latency 大升；再越过 L2 更糟。Branch 每 32 B、32768 个 Branch 对应 1 MB Code Footprint，平均接近 100 cycle/branch，网页为保持图表可读性甚至没有画出这个点。

![图 6：Kryo 与 A72 的 Branch Footprint 对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_kryo_wechat_article_zh/9a04fb7eac4103e8_06_kryo_a72_branch_targets.png)

*图 6：小 Footprint 下 Kryo 表现很好，A72 连 Back-to-back Taken Branch 都无法处理；Kryo 从 L0 取指并现场算目标时，也比 A72 Main BTB 更快。超过约 8 KB 后差距逐渐缩小。*

### Indirect 与 Return Prediction

Vtable、Switch-case 等会让同一 PC 跳往多个 Target。Kryo 对单一 Indirect Branch 可应付约 16 个 Target；若每个 Branch 只在两个 Target 间轮换，总计约 64 Target。

![图 7：Kryo 的 Indirect Target 容量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_kryo_wechat_article_zh/6e0697e288b72f30_07_indirect_target_prediction.png)

*图 7：低延迟区域支持“单 Branch 16 Target、两 Target 模式总计约 64”的观察。A72 对单一难 Branch 接近，但多 Branch 时可维持到约 128 个 Branch×2 Target。*

Return 可通过 Call 时 Push、Return 时 Pop 的 Return Address Stack（RAS）预测。Kryo 在调用深度超过 16 后出现清晰台阶，因此支持 16-entry RAS；从 Core 2 开始的多代 Intel 核心也采用过相同深度。A72 的 RAS 明显更深，体现不同优化优先级。

![图 8：Kryo 与 A72 的 Return Stack 深度](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_kryo_wechat_article_zh/a28e9e5b51221213_08_return_stack.png)

*图 8：Kryo 曲线在 16 层后抬升，A72 要到更深调用才明显退化。这里的“16 项”由微基准拐点支持，不是 Qualcomm 公布参数。*

### 体系结构视角：零 Bubble 的小表无法替代远距离目标供给

八项 Fast BTB 极有效地覆盖紧 Loop，但大型程序需要的不只是正确 Target，还要提前把目标 Line 拉进 L1I。Kryo 在 1 MB Code Footprint 接近 100 cycle/branch，说明前端没有足够远的 Target Lookahead。

验证应同时扫 Branch Count、Spacing 与 Code Footprint，并观察 L1I/L2 Miss。若方向正确而越过 Cache 后延迟仍爆炸，扩大方向历史不会解决代码供给问题。

## 取指、译码与重命名

Kryo 使用 32 KB L1I，每周期最多 Fetch/Decode 四条指令。同期 A72 是三宽、48 KB L1I；下一代 Snapdragon 使用的 A73 只有两宽，因此 Kryo 在移动端相当宽。

![图 9：Kryo、A72 与桌面核的代码供给](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_kryo_wechat_article_zh/00319aa8af68f137_09_instruction_fetch_bandwidth.png)

*图 9：L1I 内 Kryo 接近四 IPC；从 L2 取代码后骤降到略低于一 IPC。这在低功耗核和较老桌面核中并不罕见，但相对发布前数年的高性能桌面/服务器架构已明显落后。*

Rename 除了常规消除 Write-after-write（WAW）假依赖，没有 Zeroing Idiom Recognition，也不做 Move Elimination。对固定 4-byte 编码的 Arm ISA，`xor reg,reg` 并不像 x86 那样能以更短指令实现清零，因此前者影响不大；Move Elimination 当时 Arm 自己也尚未实现，不能苛责 Qualcomm。

### 体系结构视角：Rename 技巧的价值与 ISA 编码有关

x86 的 Zeroing Idiom 既能打断旧依赖，也可能节约指令字节；AArch64 固定四字节，后一项收益不存在。相同微结构技巧在不同 ISA 上的收益函数并不一样。

Kryo 更大的问题是 L2 Fetch 只有一 IPC。即使 Rename 能消掉 Move，持续断粮时也没有足够 Micro-op 进入后端；优化应先看最常见 Stall 来源。

## 乱序执行：分支密集整数代码是强项

Samsung 14 nm FinFET 让手机功耗内实现中等规模乱序引擎成为可能。Kryo 与 A72 的最大重排序容量接近，内部资源分配却很不一样：Qualcomm 更重视 Branch-heavy Integer，A72 更偏 Scalar FP。

![图 10：Kryo 与 A72 的乱序资源容量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_kryo_wechat_article_zh/ff1bf5fb4f878701_10_ooo_capacity.jpg)

*图 10：Kryo 即使让约一半在途指令都是 Branch，也能接近最大窗口；较大的 Flags Register File 能容纳与 Conditional Branch 配套的 Flag-setting 指令，Integer Register File 容量也更充裕。表中数字来自 Reverse Engineering，不是官方规格。*

A72 对 Scalar FP 的 Rename Capacity 更好，但换成 128-bit Vector 后优势消失，因为 Kryo 使用全宽 Vector Register。两者 Memory Ordering Queue 都小：A72 的 Load Queue 大得多，Kryo 的 Store Queue略大；Store Queue 往往是很热的结构，差距未必简单由 Load 项数决定。

Scheduler 每拍都要比较依赖并选择 Ready Instruction，是高功耗、难定时结构。Kryo 总容量通常优于 A72。

![图 11：Kryo 与 A72 的 Scheduler 组织](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_kryo_wechat_article_zh/dc744a4276356bb6_11_scheduler_capacity.png)

*图 11：A72 使用小型、单端口分布式 Queue；Kryo 的 Integer Scheduler 由两组 Dual-port Queue 组成，总容量接近 A72 四组 Queue，却能更灵活共享 Entry。FP 与 Memory 仍是分布式，但单队列更大。代价是面积和功耗更高。*

### Integer、FP 与 Vector Execution

四条 ALU 让 Kryo 的基本整数峰值达到桌面核级别。Skylake 在至少一条 Not-taken 时可每拍处理两 Branch，Branch Throughput 更强；Kryo 则有更高 Integer Multiply Throughput，但五周期延迟不如 Skylake 的三周期。与移动核比较就很出色：A72 同为五周期 Multiply，却只有一个 Multiply Port、也只有两条 ALU。

Kryo 和 A72 的 Scalar FP 都不错。Kryo 有两条三周期 FP Adder，A72 为四周期。Vector FP 都不算强，但 Kryo 的 128-bit FMA 只占一条 FP Pipe，可与一条 128-bit Packed Add Dual Issue，理论上每拍 12 个 FP Operation；FMA Latency 为五周期，A72 是七周期。

![图 12：Kryo 与 A72 的执行单元能力](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_kryo_wechat_article_zh/41d13e79c73fb124_12_execution_units.jpg)

*图 12：图表汇总 Integer、Scalar FP、Vector FP/Integer 与 Load/Store 的吞吐、延迟和端口。Kryo 的 Vector INT32 Add 单周期完成；原网页在文字中写“A72 三周期”，图表用于对应 A72 对照。Vector INT32 Multiply 两者均四周期流水，Kryo 吞吐约两倍。*

Vector 也用于 Memory Access。Kryo 可发出每拍两条 128-bit Vector Load，虽然并不总能维持；A72 最高一条。Kryo 每拍可完成一条 128-bit Store，A72 每两拍一条。

### 体系结构视角：Scheduler 灵活性比总 Entry 数更接近有效容量

四个各八项单端口 Queue 与两个各十六项双端口 Queue，即使总数相同，也会因指令绑定、端口冲突和空闲项无法借用而表现不同。Kryo 的 Integer Queue 更集中，Branch-heavy Code 更不易因某一小队列提前 Full。

应按 Instruction Class 分别制造压力，再混合 ALU/Branch/Multiply。总窗口未满但某类操作停止 Rename，说明局部 Scheduler 或 Register File 才是瓶颈。

## Load/Store：识别逻辑先进，数据返回却太慢

Kryo 的 AGU 支持 Indexed/Scaled Addressing，L1D Load Latency 仍为三周期。虚拟地址生成后，LSU 还要翻译地址，并保证 Memory Operation 的架构顺序。

Store Forwarding 识别非常成熟：像 Skylake 一样，只要年轻 Load 完全包含在旧 Store 范围内就能 Forward；还似乎在 4-byte Boundary 做快速早期依赖检查。跨 64-byte Cache Line 时会失败，但以移动 CPU 标准已经很强。

![图 13：Kryo 的 Store-to-load Forwarding](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_kryo_wechat_article_zh/531ed98da767e11d_13_kryo_store_forwarding.png)

*图 13：Big/Little Kryo 行为相同，小核有时因噪声较少而曲面更干净。网页正式图注说明配色为便于阅读而调整。Fast Match、Partial Overlap 与 Cache-line Crossing 形成不同区域。*

遗憾的是，成功 Forward 仍需约 13 周期，几乎与失败的 14～15 周期一样慢；按周期已经接近 Bulldozer，Kryo 频率又低，实际时间更不利。FP/Vector 稍好：128-bit Store 到对齐 64-bit FP Load 约十周期，Partial Overlap 约 11；Misaligned Vector Load 再多一周期。

![图 14：Cortex-A72 的 Store Forwarding 对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_kryo_wechat_article_zh/7554602e434bb3d2_14_a72_store_forwarding.jpg)

*图 14：A72 一般约七周期，最昂贵的跨 Cache-line 情形仍快于 Kryo 的正常成功路径。网页正式图注说明它是 Henry Wong 测试的 AArch64 实现。*

### 地址转换

多数 CPU 采用多级 TLB，Kryo 却选择“全有或全无”：L1 TLB 大而快，共 192 项，后面没有二级 TLB。小 Footprint 因此占优；4 KB Page 下名义 Coverage 为 768 KB，跨入多 MB Working Set 后就直接承受 Page Walk。

### 体系结构视角：命中判断与数据可用是两条关键路径

图 13 说明 Kryo 很擅长判断“能不能 Forward”，13 周期却说明真正的数据选择、对齐、合并或写回路径太深。先进的 Dependency Logic 如果不能提早交付 Data，性能价值会被抵消。

验证要把 Detection Result、Forwarded Data Valid 和 Consumer Wakeup 三个时点拆开。TLB 也同理：192-entry L1 降低小集 Hit Latency，却把 Miss 直接暴露给 Walk；平均很快、尾部很慢是同一设计的两面。

## Cache 与内存：像 2000 年代的两级层次

Kryo 采用简单两级 Cache。L1D 只有 24 KB，但 Hit Latency 为三周期。

![图 15：Big/Little Kryo 的 Cache/Memory 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_kryo_wechat_article_zh/aecce70f1e742043_15_cache_memory_latency.png)

*图 15：Android 很可能无法使用 2 MB Page，地址转换长尾混入曲线。Big Cluster 的 L2 从测试估计约 768 KB（带问号）、25 周期；Little Cluster 约 512 KB、23 周期。容量与边界均为反推。网页正式图注保留了 Huge Page 限制。*

这样的 L2 容量不大，延迟却很高。Skylake 256 KB L2 只需 12 周期；Big Kryo 的 25 cycle 按频率约 10.9 ns，已经接近 Intel 更大 LLC 的时间。Graviton 1 的 A72 访问四核共享 1 MB L2 约 21 周期，单核可见容量更大且稍快。

![图 16：Kryo 与 A72 的 L1/L2 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_kryo_wechat_article_zh/8434e4fdc391f3be_16_l1_l2_bandwidth.png)

*图 16：Kryo L1D 有时可接近两条 128-bit Load/cycle，A72 不能超过一条；两者单核 L2 都只略高于 8 B/cycle。Kryo 的峰值并非持续保证。*

Kryo 每个 Cluster 只有两颗核心共享一份 L2，A72 则四核共享，因而前者的分布式 L2 更容易随核心数扩展。

![图 17：多核 L2 读取带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_kryo_wechat_article_zh/b9f575e492312a8e_17_multicore_l2_bandwidth.png)

*图 17：Kryo 在 L2 内拥有明显多线程带宽优势，A72 加到两核后便基本停止扩展。网页正式图注也提醒 Snapdragon 821 的结果很怪：先绑定 Big Core 后，一核到两核增长并不明显。*

这项优势并不大。每簇约 512/768 KB 很快就会越界，更像 Mid-level Cache 而非 Last-level Cache；长负载下核心又会为控温降频，L2 Bandwidth 随之下降。

![图 18：Snapdragon 821 与 Graviton 1 的 DRAM 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_kryo_wechat_article_zh/2a0777152ae3b19b_18_dram_bandwidth.png)

*图 18：越过 L2 后直达 DRAM。Snapdragon 821 四核在 1 GB Region 上短时超过 18 GB/s，接近 2016 桌面水平；长时间运行只能约 14 GB/s。Graviton 1/A72 在该对照中较低。*

### 体系结构视角：分布式 Cache 提升带宽，却可能牺牲容量效率

每两核一份 L2 降低 Arbitration Fan-in，也允许两簇并行服务更多 Request；代价是数据复制、每线程可用容量偏小，以及跨簇共享必须走更远路径。四核共享大 Cache 恰好相反：容量池化更好，Bank/Port 可能更早饱和。

评估需要同时报告单核带宽、每簇并发、有效容量、持续频率和 Miss 后 DRAM 流量。只看图 17 的短时 L2 峰值，会遗漏热降频和 768 KB 外的 Page Walk/DRAM 代价。

## Cache Coherency：同簇尚可，跨簇代价惊人

多份 Private Cache 必须让所有核心看到一致的最新数据。Snapdragon 821 看起来分两级处理：同簇 Cache-to-cache Transfer 较快，L2 Complex 可能兼作一级 Snoop Filter；Cache Line 在 Big/Little Cluster 之间来回转移时，延迟则急剧上升。

![图 19：Big/Little Kryo 的核间延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_kryo_wechat_article_zh/9500f044bc111257_19_core_to_core_latency.png)

*图 19：同 Cluster 矩阵明显较低，跨 Cluster 进入极高区域。高到让文章怀疑 Qualcomm 可能经 DRAM 搬运跨簇数据，但没有 Interconnect/RTL 证据确认；A72 跨 Cluster 也并不出色。*

### 体系结构视角：相同微架构不等于统一的共享域

Big/Little 两簇使用同一 Kryo Core，却有各自 L2 和频率域。跨簇共享仍要经过 Snoop/Interconnect，拓扑距离远比“指令集和核心相同”更重要。

应分别测 Read Sharing、Write Ping-pong、Atomic RMW 和迁核，并监控 Snoop/Retry 与 DRAM Traffic。只有跨簇时 DRAM Transaction 同步增加，才足以支持“经 DRAM 搬运”的猜想。

## 最后的评价：一颗没有等到第二代的雄心之作

Krait 曾让 Snapdragon S4/800 很成功。Kryo 进一步展示 Qualcomm 想主导移动 CPU 的野心：四宽 Pipeline、优秀 Scheduler、三周期 L1D 和充足 Integer Unit 让高 IPC 代码跑得很快，有时像一颗低频桌面核。零 Bubble Taken Branch、Branch-heavy 大窗口也胜过 A72；Store Forwarding 识别甚至能处理后来的 Cortex-X2/A710 都不擅长的组合。

在 Android 生态中，直到数代以后才重新出现同等级的 Width、Execution Resource 与 Reordering Capacity。问题是芯片其他部分喂不饱它：L2 小而慢，LPDDR Latency 高，跨簇一致性昂贵。Kryo 自身也有 13-cycle Store Forwarding、没有 L2 TLB、持续负载降到略高于 1 GHz 等弱点。4 KB Page 下 Footprint 超过约 768 KB 后，Page Walk 代价超过 28 周期。

系统层面的 Big/Little 思路同样超前：同一微架构通过 Cache/Clock 做两种 Density，某种意义上早于后来的 Zen 4c 路线。可惜“大号小核”仍太占面积，Snapdragon 821 总共只有四核；竞争方案能堆到八颗 A53，在高度并行负载中抵消 Kryo 的单核资源优势。

![图 20：同期移动核心面积对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_kryo_wechat_article_zh/8bf341627899cb10_20_mobile_core_area.png)

*图 20：图片由 AnandTech 论坛用户 Lodix 整理。若估算准确，除 Apple Hurricane 外，Kryo 比同期其他移动核心都大。它是第三方 Die 面积推定，不是 Qualcomm 官方数字。网页正式图注保留了这一条件。*

如果继续迭代，更大更快的 L2、加入 L3、二级 TLB、缩短 Forwarding，再迁移到新制程降低热量，都可能把 Kryo 变成扎实基础；缩小核心后也能增加 Core Count。但 Snapdragon 835 转向 A73/A55。Qualcomm 仍沿用“Kryo”品牌，后来的 Kryo 280 等其实是定制 Cortex，不再是这套自研架构。

2021 年 Qualcomm 收购 Nuvia，重新获得自研核心团队。回看初代 Kryo，它不是一次毫无价值的失败，而是一颗核心能力超前、系统供给和功耗尚未跟上的孤代架构。

### 体系结构视角：从 Kryo 可以归纳出的七点认识

第一，宽核心必须配宽供给。四宽 Decode、四 ALU 和好 Scheduler 在 L1 内很强，L2 代码供给不到一 IPC 时却只剩纸面峰值。

第二，复杂机制只有落到关键时点才有价值。Kryo 能识别困难的 Store Forwarding Case，却要 13 周期交付数据，判断能力没有转化成低依赖延迟。

第三，单级大 TLB 是典型的平均值/长尾交换。192 项让小集快速，超过 768 KB 后却没有二级缓冲，直接把 Page Walk 暴露给低频核心。

第四，Scheduler 组织比“总项数”重要。可灵活共享的 Dual-port Integer Queue 让 Branch-heavy Code 更少局部堵塞，也付出更高面积和每拍比较能耗。

第五，同构 Big/Little 需要真正的 Density Variant。只降频、减 Cache 而不缩窄核心，软件适配简单，却难以像 A53 那样用核心数换多线程吞吐。

第六，短时成绩和持续性能必须并列。DRAM 可短时超过 18 GB/s、长时约 14 GB/s，核心频率也会滑到略高于 1 GHz；手机 SoC 的 Thermal Envelope 本就是架构可用性能的一部分。

第七，Core IP 与 Uncore 必须共同设计。Kryo 的强整数后端、薄弱 L2、跨簇路径和 LPDDR 系统一起决定最终体验，任何一张核心框图都无法单独解释成败。

## 参考资料

- Chips and Cheese：[*Kryo: Qualcomm’s Last In-House Mobile Core*](https://chipsandcheese.com/p/kryo-qualcomms-last-in-house-mobile-core)
- Henry Wong：[*Store-to-Load Forwarding and Memory Disambiguation in x86 Processors*](https://blog.stuffedcow.net/2014/01/x86-memory-disambiguation/)
