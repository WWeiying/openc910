---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "arm_cortex_a725_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*Arm’s Cortex A725 ft. Dell’s Pro Max with GB10*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2026 年 1 月 27 日
> - 链接：https://chipsandcheese.com/p/arms-cortex-a725-ft-dells-pro-max

Arm 的 7 系列核心最初代表着公司最高的性能水平。随着面向峰值性能的 X 系列出现，7 系列逐渐转向密度优化：不再追求单个核心包揽所有性能，而是希望在有限面积和功耗内放入更多核心，以更低成本换取较强的多线程吞吐。这与 Intel E-Core 的基本思路相似，也让“高性能大核 + 高密度中核”的异构组合成为一种自然选择。

Cortex-A725 是这条路线上的新一代产品。对 Arm 而言，一颗有竞争力的密度核心不仅关系到手机 SoC，也关系到授权模式能否继续吸引芯片厂商、big.LITTLE 组合能否抗衡 Qualcomm 自研核心，以及 Arm 能否进一步进入长期由 x86-64 主导的笔记本市场。

这次观察对象是 Nvidia GB10 中的 A725。GB10 共有 10 个 A725 和 10 个 Cortex-X925，分成两个簇，每簇各有 5 个 A725 与 5 个 X925。A725 运行在 2.8 GHz，X925 则达到 3.9～4.0 GHz；两个簇分别配有 8 MB 和 16 MB L3。这样的产品给了我们一个观察 A725 微架构的窗口，但核心之外的频率、L3、DSU、内存控制器与整机实现同样会进入测试结果。

## 测试平台与结论边界

Dell 为测试提供了两台 Pro Max with GB10。即使运行 Linpack，两台机器仍相当安静，这至少说明 Dell 的散热设计能够把 GB10 控制在合理状态；网页没有进一步给出温度、风扇转速或功耗数据，因此不能把“安静”换算成定量能效结论。

![图 1：两台 Dell Pro Max with GB10](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a725_wechat_article_zh/68d25d25443b03dc_01_dell_pro_max_gb10.jpg)

*图 1：两台由 Dell 提供的 Pro Max with GB10 叠放在一起。测试对象是 GB10 中的一种 A725 实现，而不是脱离 SoC 的抽象 IP 核。*

主要对照包括 Cortex-A710、与 A710 关系密切的 Neoverse N2，以及 Intel Skymont、Crestmont。N2 数据来自 Azure Cobalt 100，Skymont 来自 Core Ultra 9 285K，Crestmont 来自 Core Ultra 7 155H。不同核心处于不同 ISA、频率、Cache 和内存系统中，因此微基准更适合识别结构台阶，SPEC 数据则只能代表这些具体平台。

SPEC CPU2017 总览图明确标为估算的单副本 `intrate-1` 与 `fprate-1`。网页没有完整披露编译器版本、全部编译参数、输入集、操作系统与内核、功耗限制、锁频方式、预热与重复次数、误差范围；分支准确率图只明确说明 Arm 核心统一使用 `-march=armv8` 以方便比较。跨 AArch64 与 x86-64 比较 IPC 时，执行指令数也可能不同，不能把 IPC 直接当成同一工作量下的性能。

下文沿着网页中的 22 张图展开。公开手册明确给出的配置会直接标明来源；曲线台阶得到的容量用“约”“可能”或“支持某种判断”表述。材料没有 A725 RTL，因此不会把 BTB、队列、端口或恢复逻辑写成 RTL 已确认实现。图 1、8、14、15 保留了英文正式图注的含义，其余中文图注用于帮助读图。

## 一、核心总览：五宽，但不是无条件追求规模

Cortex-A725 是一颗五宽乱序执行核心。它的重排序能力大致达到 Intel Skylake 或 AMD Zen 2 的量级，足以深入利用乱序执行，却仍明显小于当代峰值性能大核。核心通过独立的 256-bit 读、写路径连接 DynamIQ Shared Unit 120（DSU-120）；DSU-120 既是簇级互连，也承载共享 L3。

![图 2：Cortex-A725 微架构总览](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a725_wechat_article_zh/0077418634495e74_02_cortex_a725_overview.png)

*图 2：网页汇总的 A725 总览图。前端包括 32/512/8192 项三级 BTB、16 项返回栈、64 KB 四路 L1I 和五个译码器；后端标出 224 项 ROB、约 199 项整数寄存器、约 211 项 64-bit FP/向量寄存器、约 81 项 flags 状态、约 52 项 SVE predicate 状态、四个 20 项整数调度器、多个 16 项 FP/Load/Store 调度器、23 项非调度队列、164 项 Load Queue，以及 512 KB L2 和 1536 项六路 L2 TLB。图中 ITLB 为 48 项、Store Queue 为 67 项，但后文分别写成 32 项与 78 项；两组口径无法从现有材料中强行统一。*

A725 保留了 Arm IP 核常见的配置弹性。L1I 和 L1D 均可选 32 KB 或 64 KB，都是四路组相联；L1I 可选奇偶校验，L1D 可选 ECC。L2 可选 128、256、512 或 1024 KB，均为八路组相联；前三种延迟为 9 周期，1 MB 版本为 10 周期，并可配置 ECC。L2 TLB 可选 1024 项四路或 1536 项六路，前者用于缩减面积。性能监控计数器可以选择 6 个或 21 个。

![图 3：A725 的实现选项与 GB10 配置](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a725_wechat_article_zh/8c9365ac8f119a7d_03_cortex_a725_configuration_options.jpg)

*图 3：GB10 采用 64 KB L1I、64 KB L1D、512 KB L2 和 21 个 PMU 计数器；图中把 L2 TLB 写成“很可能为 1536 项”，说明这一项仍带有判断成分。配置选项体现的是 Arm 授权 IP 的设计空间，不能把 GB10 的选择外推到所有 A725 SoC。*

### 体系结构视角：密度优化首先是资源配比问题

五宽只描述前端和分配链路某个截面的峰值能力。要把它变成退休 IPC，分支预测、I-Cache、TLB、重命名、ROB、调度器、执行端口和 Load/Store 队列必须保持大致匹配；其中任何一处长期不足，都会通过反压限制整条流水线。

A725 的设计重点不是把每一张表都做大，而是把面积留给更常成为瓶颈的结构，再缩减或重组收益较低的部分。判断这种取舍是否成功，应观察前端空周期、重命名停顿原因、ROB/寄存器/队列满周期、ready-but-not-issued 操作和端口利用率，而不能只凭“五宽”或“224 项 ROB”给核心定级。

## 二、分支预测：方向很强，目标供给有所收缩

Cortex-A710 的方向预测能力已经接近较早一代 Intel 高性能核心，A725 延续了这一优势。测试让条件分支按照不断增长的随机 Taken/Not-Taken 模式重复执行，同时改变循环中的静态分支数；纵轴记录随机模式相对可预测模式增加的时间。

网页先把总体判断概括为 A725 与 A715 互有胜负，紧接着的具体数值和两张曲面则使用 A710 对照。单个分支时，A725 在模式长度超过 2048 后开始变慢，而 A710 的对应边界约为 3072。循环中存在 512 个分支时，两颗核心都在模式长度超过 32 后变慢；区别是 A710 的退化更突然，A725 的变化更渐进。因此，这不是一轮所有条件下都同向改善的升级。

![图 4：A725 的随机分支模式识别曲面](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a725_wechat_article_zh/4aa28b2c25b13d79_04_branch_random_pattern_a725.png)

*图 4：横轴为模式长度 2～32768，另一轴为循环中的分支数 1～512，纵轴为随机与可预测模式的纳秒差。曲面抬升说明这一组合已不能维持相同预测效果；它同时受历史长度、预测表容量、索引和混叠影响，不能据此认定某种具体算法。*

![图 5：A710 的相同分支模式测试](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a725_wechat_article_zh/9f2724c732a729f1_05_branch_random_pattern_a710.png)

*图 5：A710 对照曲面。它在部分区域能学习更长的单分支模式，但多分支压力下出现更陡的台阶。两张图适合比较可观察行为，不等同于内部历史寄存器位数。*

### BTB：容量变小，较大层级也更慢

Arm 7 系列过去常用低周期数的分支目标缓冲器（Branch Target Buffer，BTB）弥补较低频率。A725 单独看仍属合理，但相对 A710 出现退步：各级可见容量更小，较大层级的目标交付也更慢。

![图 6：A725 的 BTB 容量与延迟台阶](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a725_wechat_article_zh/24bf96279fbd9d7e_06_btb_capacity_latency_comparison.png)

*图 6：横轴为循环中的 Taken 分支数，纵轴为 cycles/branch，4～64 B 曲线改变相邻分支间距。曲线在约 32、512、8192 个分支附近出现台阶，支持总览图所列的 L0/L1/L2 BTB 容量；代码布局越稀疏，工作集也越早冲击 I-Cache 与目标表，最右侧不能只解释为单一 BTB miss。*

A725 与 Skymont 在 Taken 分支链中互有胜负。很小的循环更有利于 A725，因为 Skymont 不能每周期处理两个 Taken 分支；中等分支数则由 Skymont 获胜，其 1024 项 L1 BTB 可在单周期交付目标，而 A725 的 512 项 L1 BTB 会引入一个流水线空泡。两者到 8192 项 L2 BTB 的周期数相近，但 Skymont 频率更高，因此换成绝对时间后更占优势。

![图 7：A725、A710 与 Skymont 的目标供给对照](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a725_wechat_article_zh/d1ffdb35513ef73c_07_taken_branch_throughput_a725_skymont.png)

*图 7：A725 在不超过 32 个分支时可低于 1 cycle/branch，进入 512 项层级后约为 2 cycle/branch，进入更大层级后约为 3 cycle/branch；A710 在 1024～8192 项区间更快，Skymont 的 1024 项快速层也更有优势。不同频率不会改变 cycles/branch，却会改变真实时间和每秒吞吐。*

Arm 通常用 branch-with-link 指令完成函数调用，函数返回则由 16 项返回地址栈（Return Address Stack，RAS）预测。一次 call+return 对的延迟为 2 周期，因而单个调用或返回很可能各为 1 周期；这里的“很可能”是由组合延迟反推，而不是执行流水线的公开分级。

### SPEC 中的方向预测结果

在容易预测的程序中，A725 大体守住 A710/N2 水平；在部分困难项目中则有明显进步。最突出的是 `541.leela`：A725 的正确率为 93.09%，N2 为 92.59%，换算成每条指令的误预测次数后，A725 降低了 6.61%。N2 是 A710 的近亲，测试平台为 Azure Cobalt 100。

![图 8：SPEC CPU2017 整数套件的分支正确率](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a725_wechat_article_zh/231b7d8e77231870_08_spec2017_integer_branch_prediction.png)

*图 8：准确率定义为 `1 - 退休误预测分支数 / 退休分支数`，Arm 核心统一以 `-march=armv8` 编译以方便比较。A725、N2、Skymont 在多数项目都很接近；`505.mcf`、`541.leela`、`557.xz` 等困难项目更能暴露差异。准确率还要结合分支频度和恢复代价，不能单独换算成性能。*

浮点套件通常分支更少、预测也更容易。A725 与 N2 在各子项互有胜负，没有整数套件中那样清楚的单向提升；但因为这些工作负载更强调核心吞吐，预测器没有整体退步仍可视为正面结果。

![图 9：SPEC CPU2017 浮点套件的分支正确率](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a725_wechat_article_zh/f7064ad5f8c2c3f9_09_spec2017_fp_branch_prediction.png)

*图 9：大部分项目在 95%～100% 区间。图中完整保留每个子项的 A725、N2 与 Skymont 数据；不同 ISA 无法得到完全相同的动态指令流，因此 Skymont 只适合判断量级。*

综合两组图，A725 与 Skymont 大体处于同一档，两者都拥有相当优秀的方向预测能力；由于 ISA 不同，无法让它们执行完全相同的分支流，因而不适合用极小的百分比差异给出绝对排序。

### 体系结构视角：分支预测交付的是“下一段可用指令流”

方向预测回答“跳不跳”，BTB 回答“Taken 后去哪里”，RAS 处理同一返回指令对应多个动态调用者的问题。方向猜对但目标没有及时到达，前端仍会产生空泡；方向猜错，则必须取消年轻指令、恢复正确 PC，并恢复任何被推测更新的历史或 RAS 状态。

预测准确率提高会降低错误路径工作和前端重填次数；更快的 BTB 则直接减少正确 Taken 分支上的气泡。验证时可分别构造固定方向、变化 PC 数量、不同分支间距和不同调用深度的微基准，再结合条件分支 MPKI、BTB miss、返回目标错误、重定向周期和取消 MOP 数定位问题。现有材料没有公开 A725 的历史 checkpoint、错误恢复和更新时机，不能从曲线越过这条证据边界。

## 三、取指与译码：取消 MOP Cache，回到常规五宽路径

预测器决定下一 PC 后，前端取回指令，再把它们译为 Arm 内部的宏操作（Macro-Operation，MOP）；MOP 在后续阶段还可能拆成微操作（micro-operation，uOP）。较早的 Arm 核心可以把 MOP 缓存在 MOP Cache 中，做法类似 AMD 和 Intel 高性能核心的 uOP/Op Cache。A725 取消了 MOP Cache，完全依赖常规取指和译码路径。

这条路径每周期可交付 5 个 MOP；如果一对指令融合成一个 MOP，最多可对应 6 条指令。NOP 流中，A725 持续达到 5 instruction/cycle，直到工作集越过文中所称的 32 项 ITLB 覆盖范围，随后跌到 2 IPC 以下，并一直延续到工作集越过 L3。

![图 10：A725、A710 与 Skymont 的指令供给带宽](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a725_wechat_article_zh/bf7c7daf138872a5_10_frontend_instruction_bandwidth.png)

*图 10：横轴为 2 KB～4 GB 的代码测试规模，纵轴为 4-byte NOPs/cycle。A725 小工作集稳定在 5，A710 可因相邻 NOP 融合接近 10，Skymont 接近 8；越过各自前端 Cache/TLB 层级后出现多级下降。总览图把 A725 ITLB 画成 48 项，而正文根据这组测试写成 32 项，两者存在未解释差异。*

A710 可以让每个 MOP 对应一对融合 NOP，因此在这一特制测试中达到 10 IPC。A725 不再融合相邻 NOP，但仍支持更有实际意义的融合，例如 `CMP + branch`。这使 A710 的 10 IPC 更像角落案例，而不是典型应用持续吞吐。

取消 MOP Cache 并不等于每次都从零开始做完整译码。Arm 很早就把预译码信息随 L1I 内容存储：直到 Cortex-A78/Cortex-X1，一些 L1I 使用 36-bit 或 40-bit 中间格式，在微操作缓存的面积成本与每次完全重译码之间折中。A725 的技术参考手册显示，每条 32-bit AArch64 指令旁还存有 5-bit “sideband”预译码数据，位模式可以指出有效操作码。这些位很可能也用于处理 AArch64 庞大且不连续的未定义编码空间，并为正式译码提供辅助。

### 体系结构视角：删掉 MOP Cache 是用稳定吞吐换取更低固定成本

MOP Cache 能绕过部分译码工作，却需要标签、数据阵列、填充策略、失效一致性和额外取指选择逻辑。低频、五宽核心较容易让常规译码满足时序，预译码又能降低每次译码的能耗；如果真实程序很少在同一周期提供多组可融合指令，那么保留 MOP Cache 的收益可能不足以覆盖面积和静态功耗。

代价是峰值和大代码工作集更依赖 L1I、ITLB 与译码器。异常、分支重定向或取指 miss 发生时，前端还必须丢弃错误路径结果，防止迟到的 Cache/TLB 响应进入新路径。区分字节供给、指令供给与 MOP 供给，需要同时观察 fetch/decode 有效宽度、I-Cache/TLB miss、融合成功数和前端空周期；只有 NOP IPC 并不足以判断应用前端效率。

## 四、重命名与分配：有优化，但吞吐并非全宽

MOP 进入五宽重命名/分配阶段。经典寄存器重命名把架构寄存器映射到物理寄存器，消除 WAR/WAW 假依赖；A725 还会识别把立即数 0 写入寄存器的清零惯用法，无需为结果分配物理寄存器。

普通寄存器 MOV 也支持消除，但紧密排列的 MOV 不能跨全部重命名槽持续消除。独立 MOV 测试中，A725 仍为每条指令分配物理寄存器。一个可能解释是同周期 MOV 太多时消除能力达到上限，类似 Intel Haswell 的情况；A725 没有用于统计 MOV 消除效果的 PMU 事件，因而无法进一步确认。

![图 11：MOV 消除与清零惯用法吞吐](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a725_wechat_article_zh/2ecf9489be97bd19_11_move_elimination_test.jpg)

*图 11：独立 MOV 吞吐为 A725 3.77 IPC、A710 3.85、Skymont 7.29；依赖 MOV 分别为 1.14、1.37、7.29，后者体现 Skymont 更强的消除能力。清零操作为 A725 `MOV r,0` 4.54 IPC、A710 5.76、Skymont `XOR r,r` 7.17。A710 因融合可超过自身五宽，跨 ISA 指令也并不完全等价。*

内存重命名是另一种“零周期搬运”：如果 Store 和后续 Load 使用相同地址寄存器，处理器可以在重命名阶段建立值关系，而不必等待普通 Store-to-Load forwarding。Intel Ice Lake、AMD Zen 2 和 Skymont 支持这种优化；测试没有在 A725 上观察到相同行为。

### 体系结构视角：优化失败时必须无缝回到正常路径

MOV 消除和清零惯用法的价值不只是节省一条 ALU 操作，它们还减少物理寄存器、调度项和写回端口压力。但别名关系必须正确维护生命周期；分支错判或异常恢复时，重命名映射也必须回到精确状态。消除带宽不足时，指令应退回普通分配和执行，而不能阻塞整条五宽路径。

内存重命名的条件更苛刻，因为地址相同不自动保证大小、对齐、字节掩码和异常语义兼容。未观察到它并不意味着 A725 的普通 Store forwarding 很弱，只说明这组零周期特例没有出现。

## 五、乱序窗口：把 ROB 增长集中到真正有用的结构

Arm 过去对 7 系列的乱序容量扩张较保守。A725 把重排序缓冲区（Reorder Buffer，ROB）从 A710/N2 的 160 项大幅增加到 224 项，让核心可以越过更长的停顿寻找独立指令；但窗口最终由最先耗尽的资源决定，所以物理寄存器和内存次序队列也需要同步调整。

![图 12：A725、A710/N2 与 Skymont 的乱序资源](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a725_wechat_article_zh/0d37c9f9fdd64aff_12_out_of_order_structure_sizes.jpg)

*图 12：A725 为 224 项 ROB、约 199 项整数寄存器（167 投机 + 32 架构）、约 211 项 FP/向量寄存器（179 + 32）、约 81 项 flags、约 52 项 predicate、164 项 Load Queue 和 78 项 Store Queue；A710/N2 相应为 160、约 147、约 124、约 46、约 56、111、44。Skymont 图中列出 416 项 ROB、约 272 项整数和约 282 项 FP 寄存器。使用 128-bit FP add 时，A725 可见的投机 FP 结果只有 107 项，支持单项可能为 64-bit 的判断。总览图的 Store Queue 是 67 项，与本表 78 项冲突。*

A725 增加了整数物理寄存器和 Load/Store Queue，但没有让所有资源同幅度增长。FP/向量寄存器总项数更多，能容纳的 128-bit 结果反而更少，因而单项很可能从 A710 的 128-bit 改为 64-bit；SVE predicate 状态也略有缩减。向量执行面积大、只惠及部分程序，这些变化显示 Arm 正在降低向量路径的资源优先级，以换取更好的核心密度。

## 六、调度与执行：四条整数路径，FP 调度改用两级缓冲

A725 的执行端口布局与 A710 相近。四条路径处理整数操作，每条由 20 项调度队列供给；另有两条分支端口。混合分支与整数加法时，没有测到额外调度容量，因此分支端口很可能与 ALU 共享调度项。A710 的一条整数路径只能处理 `madd` 等多周期操作，A725 则让四条都能执行简单单周期操作。

整数乘法仍是 7 系列的强项：A725 每周期可完成两次整数乘法，延迟只有 2 周期。

FP/向量侧有两条大体对称的路径。Arm 从 Cortex-A57 时代起就长期采用双 FP/向量路径；A725 虽已是完全不同的一代核心，这种组织仍是密度设计中兼顾吞吐与成本的合理平衡。每条路径配 16 项调度队列，两者还共享约 23 项非调度队列；单条路径在自身调度器填满后，最多还能占用共享队列中的约 18 项。与 A710 相比，A725 缩小 FP 调度器，却增加更便宜的非调度缓冲。

非调度队列不检查操作数是否 ready，只按顺序把 MOP 送入有空位的调度器。A725 因此不能同时检查与 A710 一样多的 FP/向量 MOP，却仍能越过相近数量的前序 FP/向量操作寻找后面的独立工作。这种重配很可能是功耗和面积优化。

### 体系结构视角：窗口深度、可见范围与选择能力并不相同

ROB 决定核心能看多远，调度器决定每周期能从多少 ready 候选中挑选，非调度队列则只负责暂存。把部分项从全相联 wakeup/select 队列移到简单 FIFO，可以显著减少比较器、广播和时钟功耗，但遇到头部操作长期未就绪时，也可能让后方 ready 操作更晚进入真正的选择窗口。

224 项 ROB 只有在寄存器、Load/Store Queue、调度器和 miss tracking 资源都没有更早耗尽时才完整可用。诊断时应把 ROB full、LQ/SQ full、scheduler full、ready-but-not-issued 和各端口忙周期放在一起，才能区分“看不够远”“候选选不出来”和“物理端口不够”三类瓶颈。

## 七、Load/Store：三条 AGU 与明显的对齐快慢路

A725 有三条地址生成单元（Address Generation Unit，AGU）路径，每条看起来都由 16 项调度队列供给。三条都可处理 Load，其中两条还能处理 Store；带索引寻址没有额外延迟。

地址进入 Load/Store Unit（LSU）后，还要执行地址转换、维护内存顺序并处理 Store forwarding。与此前 Arm 核心一样，如果 32-bit Load 正好读取前一条 64-bit Store 的低半或高半，依赖 Store+Load 对的转发延迟为 5 周期；其他重叠和对齐组合多为 11 周期，很可能要等 Store 更接近退休后再让 Load 前进。

![图 13：64-bit Store 到 32-bit Load 的对齐矩阵](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a725_wechat_article_zh/bc30c293a62eb483_13_store_to_load_forwarding_alignment.png)

*图 13：结合本节测试，列为 32-bit Load offset，行对应 64-bit Store offset，单元格是依赖链每对操作的周期数；原图左侧标签却可读成“64-bit Load Offset”，很可能是图内标注错误。黄色 5.00 是 32-bit Load 恰好取 Store 某一半的快路，红色约 11.02 是其他重叠组合，绿色约 0.72～1.16 是无真实依赖组合；跨 64 B 边界附近还出现约 2 cycle 区域。矩阵证明存在明显快慢路，但不能单独确认慢路是否一定“阻塞到退休”。*

A725 对 Store 对齐也比 A710 更敏感，看起来以 32 B 块处理 Store：跨越 32 B 边界时吞吐下降，同时跨越 64 B 边界还会再次受罚。A710 在 64 B 边界承受相同代价，却没有 32 B 边界这一档惩罚。

### 体系结构视角：转发逻辑必须同时解决数据、掩码和顺序

Store-to-Load forwarding 不是简单旁路一份数值。LSU 必须比较地址、大小与字节掩码，判断新 Load 是否完全由更老 Store 覆盖；若地址尚未解析，还需要内存依赖预测决定能否先发射。预测错误时，Load 及其依赖链必须重放，Store 也不能在精确异常之前留下不允许的架构可见副作用。

快路可以显著降低指针、栈变量和小字段更新的依赖延迟；慢路则会同时伤害延迟和吞吐。可用地址/大小矩阵、L1D replay、memory-order violation、Load blocked by Store、AGU 利用率和 LQ/SQ 满周期交叉验证。没有专用事件时，至少应比较 cycle、retired instruction 与不同对齐组合的稳定台阶。

## 八、地址转换：从增加 TLB 项数转向扩大每项覆盖

A725 把 L1 DTLB 从 A710 的 32 项增加到 48 项，并保持全相联；按 4 KB 页面计算，基础覆盖从 128 KB 增至 192 KB。指令侧却反向缩减：正文称 A710 的 48 项 ITLB 在 A725 上变为 32 项。数据工作集通常大于代码工作集，把有限项数向数据侧倾斜可能更有收益。不过，Skymont 选择了 48 项 DTLB 与 128 项 ITLB 的相反配比。

标准 L2 TLB 为 1536 项、六路组相联；面积缩减版为 1024 项、四路组相联。前者相对 A710 的 1024 项四路结构有所升级，后者至少没有退步。L2 TLB hit 相对 L1 DTLB hit 增加 5 周期。

![图 14：顺序遍历数组时的数据侧 L2 TLB refill](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a725_wechat_article_zh/24cff621d15ad035_14_l2_dtlb_refill.png)

*图 14：横轴为测试规模 2 KB～1 GB，纵轴为每秒数百万次 `L2D_TLB_REFILL`。4 KB 页面曲线到约 8 MB 仍接近零，随后在 16 MB 左右快速上升；2 MB 大页在图示范围保持接近零。正式英文图注说明测试为线性遍历数组并监控该 PMU 事件。单凭曲线不能把所有覆盖都归给裸 TLB 项数，因为 MMU coalescing 也可能参与。*

Skymont 的 4096 项 L2 TLB 更大，但 A725 可以让一个 TLB 项追踪多个 4 KB 页面。技术参考手册给出可由控制寄存器选择的 MMU coalescing 模式：`8x32`、`4x2048`、保留值，以及关闭合并。文档没有解释命名细节。

一种最可能的解释类似 AMD 的 page smashing：只要虚拟地址、物理地址连续且属性相同，就把若干小页作为更大的翻译单元缓存。按这一解释，`8x32` 很可能表示把 8 个连续 4 KB 页面合成 32 KB 覆盖；Zen 5 可把 4 个连续 4 KB 页面合成 16 KB。`4x2048` 的精确含义在网页和截图中都没有得到进一步说明，不应自行展开。

![图 15：A725 控制寄存器中的 MMU coalescing 模式](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a725_wechat_article_zh/afff978ebf92dda1_15_mmu_coalescing_register.jpg)

*图 15：Arm A725 技术参考手册中 `IMP_CPUECTLR_EL1[63:62]` 的 `sw_mmu_coalescing_mode` 字段。`0b00` 为 `8x32`，`0b01` 为 `4x2048`，`0b10` 保留，`0b11` 关闭合并并让每个 TLB 项只保存一组 VA→PA 翻译。*

### 体系结构视角：TLB 容量和有效覆盖不是同一个量

裸项数乘以页面大小只给出理想基础覆盖；组相联冲突、地址空间标识、页属性以及合并成功率都会改变实际结果。合并连续小页可以在不要求软件显式建立大页的情况下提升覆盖，但只要物理不连续或属性不同，就必须退回普通 4 KB 项。

TLB miss 也不等于立刻访问 DRAM：先查下一级 TLB，再由 page walker 访问多级页表；页表项本身可能命中 Cache。验证 coalescing 需要控制虚拟/物理连续性和页属性，并分别记录 L1/L2 TLB refill、walk 次数与 walk latency。切换地址空间、修改页表、TLBI 或异常发生时，合并项还必须遵守正常失效与权限语义。

## 九、私有 Cache 与簇内互连：核内很快，跨核代价高

A725 的 L1D 为 64 KB、四路组相联，划分成 16 个 bank，Load-to-use 延迟为 4 周期，采用 pseudo-LRU 替换，并使用虚拟索引、物理标记（Virtually Indexed, Physically Tagged，VIPT）。它每周期可处理 3 个 Load，每个都可以是 128-bit 向量 Load；Store 吞吐为每周期 2 条。

技术参考手册又写有四条 64-bit 写路径，但只有两条 Store AGU，不可能持续接收每周期 4 条独立 Store。更合理的理解是“内部写数据路径宽度”与“Store 指令接收吞吐”不是同一个量，现有材料不足以确认四条路径如何映射到 bank、端口或一次 128-bit Store。

![图 16：GB10 16 MB L3 簇上的 A725 单线程带宽](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a725_wechat_article_zh/6ec751536a6f0aca_16_l1d_bandwidth.png)

*图 16：横轴为 2 KB～4 GB，纵轴为 GB/s。L1 范围读带宽约 133.34 GB/s，对应 2.8 GHz 下每周期 3×16 B；Add 与 Write 约 89.61 GB/s，对应 32 B/cycle。越过 L1 后，Read 明显低于 Add/Write；在 L3 工作集内，后两者仍接近 32 B/cycle。超过 16 MB 共享 L3 后，三条曲线进一步下降。*

私有 L2 为八路组相联、两个 bank。Nvidia 选择 512 KB，这是仍保持 9 周期延迟的最大配置；1 MB 版本增加到 10 周期。L2 miss 的代价更高，因此 Arm 使用比 pseudo-LRU 更复杂的 dynamic biased 替换策略。实测 L2 峰值可达 32 B/cycle，但纯 Read 达不到这一数值；读改写 Add 或纯 Write 可以把约 32 B/cycle 维持到 L3 工作集。

Arm 优化指南还给出了一组 Cache 延迟模型。L1 hit 为 4 core cycles；128/256/512 KB L2 hit 为 9 core cycles，1 MB L2 为 10；L3 hit 为 `19.5 core cycles + 14.5 DSU cycles`。同簇另一 A725 的 L1 hit 为 `38 core cycles + 22.5 DSU cycles`，另一核 L2 hit 反而只需 `32` 或 `33 core cycles + 22.5 DSU cycles`。L3 miss 到内存控制器则是 `19.5 core + 15.5 DSU + 2 SYS cycles + system latency`。

![图 17：Arm 优化指南给出的 A725 Cache 延迟模型](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a725_wechat_article_zh/9a4586ec66207c7d_17_cache_latency_optimization_guide.png)

*图 17：这不是 GB10 的实测表。模型假设核心与 DSU 之间有双向两级异步同步器、L3 data RAM 为 1-cycle in/2-cycles out、核心 3 GHz 而 DSU 2 GHz，且簇内只有 1～4 个核心；GB10 每簇实际有 5 个 A725 和 5 个 X925，L3/DSU 配置也不同。因此表中跨核和 L3 数值只能解释机制，不能直接套到 GB10。*

表中的反常点是：命中另一核 L2 比命中另一核 L1 更快。A725 的 L2 严格包含 L1D 内容，因此 L2 tag 可以充当 L1D 的 snoop filter。Arm 给出的时序暗示 snoop 先检查 L2，只有 L2 tag 命中才继续探测 L1D；真正落在对端 L1 的数据还多走一步，所以延迟更高。

### 体系结构视角：Cache 层次还承担一致性过滤

私有 L2 的价值不只在容量和延迟。若它严格包含 L1D，L2 tag 就能告诉互连“这个核心是否可能持有该 Cache line”，减少无效 L1 probe；代价是 L2 eviction 可能需要同步处理 L1 副本。跨核访问的关键路径还可能包含 home/目录查询、snoop、对端响应、数据返回与时钟域跨越，并非所有阶段都一定串行。

带宽图则提醒我们区分请求生成、阵列端口和下层传输。三条 Load AGU 能产生 48 B/cycle 的 128-bit Load 请求，但离开 L1 后，L2 refill、MSHR、bank 冲突和 DSU 路径会逐级收紧。只有把 L1/L2 miss、MSHR full、bank conflict、snoop/probe、DSU 排队与实际字节数串起来，才能判断瓶颈在核心还是 SoC。

## 十、SPEC CPU2017：核心架构进步，被 2.8 GHz 实现限制

整体上，GB10 中 A725 的 SPEC CPU2017 估算成绩夹在 Intel Meteor Lake 的 Crestmont 附近，Azure Cobalt 100 的 Neoverse N2 略高。核心性能高度依赖具体实现；GB10 把 A725 设在 2.8 GHz，使它难以在最终用时上越过一些更老、但频率更高的密度核心。

![图 18：SPEC CPU2017 单副本估算总分](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a725_wechat_article_zh/c2d0e46fd3d30a18_18_spec2017_overall_performance.png)

*图 18：`intrate-1 / fprate-1` 估算分依次为：Skymont（Core Ultra 9 285K）8.95/13.00，N2（Azure Cobalt 100）6.01/8.81，A725 16 MB L3 簇 5.95/8.03，Crestmont（Core Ultra 7 155H）5.88/6.86，A725 8 MB L3 簇 5.77/7.95。16 MB 与 8 MB 两组也说明共享 L3 容量会进入所谓“核心成绩”。*

![图 19：SPEC CPU2017 整数套件分项](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a725_wechat_article_zh/5531bae7b07870cf_19_spec2017_integer_performance.png)

*图 19：完整列出两个 A725 簇、N2、Skymont 与 Crestmont 的整数分项。Skymont 在多个核心受限项目中显著领先；A725 在 `520.omnetpp` 等内存敏感项目保持竞争力。跨平台分项同时混合频率、ISA 指令数、Cache 与 DRAM，不宜由单项推出核心全面优劣。*

![图 20：SPEC CPU2017 浮点套件分项](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a725_wechat_article_zh/b62875082e564efa_20_spec2017_fp_performance.png)

*图 20：浮点分项的跨度更大，Skymont 在 `503.bwaves` 等项目明显领先，A725 在部分内存受限项目接近或超过较老密度核心。A725 的 SVE/向量资源取舍会影响部分程序，但网页没有给出每个二进制的自动向量化、SVE 使用率或编译诊断，不能把所有差异直接归因于向量硬件。*

### 核心受限：IPC 进步抵不过频率

`548.exchange2` 的私有 Cache 命中率很高，IPC 基本不随频率变化，是观察核心吞吐的好例子。A725 比 N2 高 10.9% IPC，说明核心架构确有进步；但 N2 运行在 3.4 GHz，最终仍比 2.8 GHz A725 快 17%。

x86-64 与 AArch64 的动态指令数又不同：`548.exchange2` 在 x86-64 核心执行 1.93 万亿条，在 AArch64 核心执行 2.12 万亿条。A725 的按周期工作效率仍更高，但 3.8 GHz Crestmont 最终快 14.5%。其他高 IPC 项目也大体遵循这一趋势，只有 Crestmont 在 `538.imagick` 上出现明显异常低 IPC。

![图 21：高 IPC、核心受限的 SPEC 子项](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a725_wechat_article_zh/c30ac2aabf5b5139_21_spec2017_core_bound.png)

*图 21：纵轴为 retired instructions / core active cycles。`548.exchange2` 中 A725 4.37、N2 3.94、Skymont 4.21、Crestmont 3.38；`525.x264` 为 3.57、3.32、4.30、3.23；`500.perlbench` 为 2.99、2.19、3.55、2.32；`538.imagick` 为 3.47、3.37、5.42、1.91。IPC 是每周期效率，不含频率，也不保证跨 ISA 完成相同数量指令。*

### 内存受限：低频反而没有那么吃亏

大量 LLC miss 的工作负载不同。DRAM 延迟不会随核心频率同比缩短，频率越高，等待同一次内存访问所消耗的周期数反而越多，因此 IPC 会下降。A725 虽然频率较低，在这些项目中仍很有竞争力：`520.omnetpp` 与 N2 大致相当，并领先 Crestmont 约 20%；`549.fotonik3d` 甚至接近 Skymont 的最终性能水平。

![图 22：内存受限的 SPEC 子项](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a725_wechat_article_zh/69f7554f7e5069bd_22_spec2017_memory_bound.png)

*图 22：IPC 分别为：`520.omnetpp` 1.04/0.77/1.00/0.51，`523.xalancbmk` 1.78/1.48/1.48/1.19，`554.roms` 2.20/2.00/1.01/0.60，`549.fotonik3d` 2.55/1.87/0.86/0.51；顺序均为 A725、N2、Skymont、Crestmont。高 IPC 不自动等于更短运行时间，但它显示 A725 在等待内存时损失的周期比例较低。*

### 体系结构视角：性能是核心、频率与内存系统的乘积

核心受限程序中，性能可近似理解为 IPC × 频率；内存受限程序还要加入有效 Cache 容量、并发未命中数、互连和 DRAM 延迟。频率提高会增加每秒可执行周期，却也把固定纳秒内存延迟换算成更多周期。A725 在图 21 中展现架构效率，在图 22 中受益于较低频率和 GB10 的内存层次，但这些作用无法仅靠一张总分图拆开。

更严谨的比较需要统一编译器、ISA 目标、输入、线程数、页面大小和功耗限制，并报告运行时间、IPC、指令数、MPKI、内存带宽与频率驻留。现有图表没有提供这样的完整控制条件，因此适合解释“为什么某些项目这样表现”，不适合建立跨产品的绝对排名。

## 十一、怎样理解 A725 的设计位置

A725 相比 A710，只在最关键的乱序结构上明显增加项数；其他位置更多是重新配比，甚至主动收缩。224 项 ROB、164 项 Load Queue 和更大的整数寄存器文件提高了越过停顿的能力；取消 MOP Cache、缩小 BTB、重排 FP 调度资源、减少 128-bit 向量结果容量，则把成本从低收益或高功耗结构中移走。

这样的“减脂”很难得，因为 A710 本来就不是一颗臃肿的大核。综合方向预测、前端、乱序窗口和 SPEC 结果，A725 的微架构整体优于 A710 与 Neoverse N2。若频率和内存系统相同，它很可能在总体上领先；但在 GB10 中，2.8 GHz 使其最终性能无法全面超过更老的实现。

Arm/Nvidia 的选择也与 Intel、AMD 的密度路线形成对照。Skymont 已经接近一颗 P-Core，只在向量等面积和功耗最昂贵的部分明显让步；AMD 更像把高性能架构降频使用，并接受由此得到的密度收益；Arm 则从一开始围绕密度优化核心，再把它带入 GB10 这类更高性能设备。三条路线的最终胜负，不会只由单核 IPC 决定，还取决于核心数、频率、向量需求、共享 Cache、互连、功耗和软件负载。

### 体系结构视角：从 A725 可以归纳出的六点认识

第一，密度核心不是简单缩小大核。A725 增大 ROB、整数寄存器与内存窗口，同时削减 MOP Cache、BTB 和部分向量资源，说明真正的优化对象是每平方毫米、每瓦能得到多少有效工作。

第二，前端容量和前端能效必须一起看。取消 MOP Cache 损失了 NOP 角落案例的 10 IPC，却可能减少一套长期供电的复杂阵列；BTB 缩小同样节省面积，但 Taken 分支密集代码会更早遇到目标供给空泡。

第三，乱序窗口的意义取决于最小相邻资源。224 项 ROB 如果被调度器、物理寄存器、LQ/SQ 或 MSHR 提前卡住，就不会完整转化为延迟隐藏能力。资源配比通常比单个最大数字更重要。

第四，向量能力是密度设计中最昂贵的选择之一。A725 仍保留双 FP/向量路径和三路 128-bit Load，但缩小能同时驻留的 128-bit 结果与 FP ready 选择窗口。这不是“不要向量”，而是把向量吞吐、调度能耗和核心数量重新平衡。

第五，TLB coalescing 和 inclusive L2 都体现了“用元数据减少昂贵访问”的思路。前者用连续性扩大翻译覆盖，后者用 L2 tag 过滤无效 snoop；它们节省的是下一级查询、page walk 或跨核探测，而不仅是阵列容量。

第六，IP 核与产品实现必须分层评价。A725 的 IPC 进步属于核心架构，2.8 GHz、8/16 MB L3、DSU 和 DRAM 属于 GB10 选择。把前者的优点或后者的限制全部归到“Cortex-A725”名下，都会模糊真正的设计责任。

## 参考资料与支持

- Chips and Cheese 原始文章：https://chipsandcheese.com/p/arms-cortex-a725-ft-dells-pro-max
- Arm 关于早期预译码中间格式的说明：https://developer.arm.com/documentation/ka001493/latest/
- Cortex-A725 技术参考手册相关寄存器页：https://developer.arm.com/documentation/107652/0002/AArch64-registers/AArch64-Generic-System-Control-registers-summary/IMP-ISIDE-DATA1-EL3--RAMINDEX-Instruction-Data-register-1?lang=en
- Dell Pro Max with GB10：https://www.dell.com/en-us/shop/desktop-computers/dell-pro-max-with-gb10/spd/dell-pro-max-fcm1253-micro

Chips and Cheese 依靠读者支持持续制作此类微架构测试。可通过 [Patreon](https://www.patreon.com/ChipsandCheese) 或 [PayPal](https://www.paypal.com/donate/?hosted_button_id=4EMPH66SBGVSQ) 支持，也可以加入其 [Discord](https://discord.gg/TwVnRhxgY2) 社区继续讨论。
