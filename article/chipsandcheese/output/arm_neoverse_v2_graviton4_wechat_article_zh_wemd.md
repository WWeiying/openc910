---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "arm_neoverse_v2_graviton4_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*Arm’s Neoverse V2, in AWS’s Graviton 4*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2024 年 7 月 22 日
> - 链接：https://chipsandcheese.com/p/arms-neoverse-v2-in-awss-graviton-4

AWS 很早便开始把 Arm 带进服务器。2018 年的第一代 Graviton 只有 16 颗 Cortex-A72；三代之后，Graviton 4 已经装入 96 颗 Neoverse V2。V2 是 Cortex-X3 的服务器衍生核心，也是当时 Arm Neoverse V 系列中最新、最强的一员。

![图 1：AWS Graviton 4 封装](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/bf9105acba237831_01_graviton4_package.jpg)

*图 1：Graviton 4 把 96 颗 Neoverse V2 核心、CMN-700 Mesh、共享 L3 与十二通道 DDR5 组织成一颗高密度服务器处理器。封装图展示的是整颗芯片，后文的核心微基准只描述其中一颗 V2。*

这次测试的意义，正在于把 Hot Chips 演讲里的 V2 设计放进一颗真实产品：核心能提供多宽的前端、多深的乱序窗口和多强的执行资源；AWS 又如何配置 L3、片上互连、双路链路和内存系统。

测试覆盖单路与双路 Graviton 4 实例。双路系统有 192 核、1536 GB DDR5；核心在单路实例最高 2.8 GHz，双路降至 2.7 GHz。对照数据来自 Bergamo、Genoa-X、Sapphire Rapids、Milan-X、Zen 4 桌面平台及更老服务器，平台、频率、NUMA 模式和软件栈并不统一，只适合观察结构趋势。

网页没有完整披露 OS、Kernel、编译器与 Flags、微基准源码、预热、重复次数和误差。Benchmark 只给出 libx264 的 4K、veryslow、CRF 24，以及 7-Zip 压缩 2.67 GB 文件等条件；软件版本、输入文件细节和完整命令行未提供。

## Graviton 4 的系统结构

Graviton 4 使用 Arm CMN-700 Mesh 连接 96 颗核心，却只配置 36 MB 共享 L3。片内 Cache Line 在不同核心之间转移时，延迟大致为 30～60 ns；矩阵没有出现“跨小簇后突然跳高”的清晰边界，但延迟会随核心到负责追踪该地址的 Mesh Stop 距离而变化。

![图 2：单路 Graviton 4 的核间延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/440d318a14680ac9_02_single_socket_core_latency.png)

*图 2：96×96 核间延迟矩阵。多数非对角格落在约 30～60 ns，局部绿色和红色带反映物理位置、Home Node 与路由距离。由于大实例成本较高，测试让 64 对核心并行运行；并发测试本身可能带来额外 Fabric 竞争。*

双路配置把系统扩到 192 核。跨 Socket 的 Cache Line 转移平均约 138.6 ns，与 Sapphire Rapids 接近；Bergamo 要管理更多核心，跨路可超过 200 ns，较低核心数的 Broadwell E5-2660 v4 则约 126 ns。片内延迟与 Graviton 2/3 大致相当，却要服务多 50% 的核心。

![图 3：双路 Graviton 4 的核间延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/960bd504729eeb3c_03_dual_socket_core_latency.png)

*图 3：192×192 矩阵形成四个象限。两个绿色对角象限是各自 Socket 内的访问，两个橙红色非对角象限代表跨 Socket；双路边界非常清楚。*

远端 DRAM 的代价更大。使用 2 MB 页、在 1 GB 数组上做 Pointer Chasing 时，本地 DRAM 为 114.08 ns，远端为 256.61 ns，跨路惩罚 142.53 ns。AMD Infinity Fabric 的同类惩罚约 120 ns，部分老平台甚至更低。Graviton 4 比 Graviton 3 的约 120 ns 本地延迟略有进步，接近 NPS1 Bergamo，却不如 NPS2 Genoa-X。

![图 4：跨 Socket 内存延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/311fb4f32415eab7_04_cross_socket_memory_latency.png)

*图 4：蓝色为本地 DRAM，浅色为远端 DRAM，红色为两者差值。Graviton 4 为 114.08/256.61/142.53 ns；Genoa-X NPS2 为 103.90/222.70/118.80 ns；Bergamo NPS1 为 120.29/211.81/91.52 ns。不同 NUMA 配置和内存代际会共同影响结果。*

每颗 Graviton 4 配置十二通道、768-bit DDR5-5600，容量 768 GB。全核读取时，本地带宽达到 468.81 GB/s，高于所测 DDR5-4800 Bergamo 的 359.53 GB/s，也显著领先八通道 Milan-X。跨路读取只有 77.40 GB/s，而 Zen 4 Infinity Fabric 可超过 120 GB/s；不具 NUMA 感知的程序更容易在这里受限。

![图 5：本地与远端 NUMA 内存带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/dc98f83a1b4ef61e_05_numa_memory_bandwidth.png)

*图 5：Graviton 4 本地/远端为 468.81/77.40 GB/s；Genoa-X NPS2 为 410.36/127.24，Bergamo NPS1 为 359.53/121.72。带星号项目由对应 NUMA Node 的跨路结果相加估算，并非完全相同的单次测试。*

### 体系结构视角：一致性好，不等于 NUMA 访问也好

核间修改态 Cache Line 转移会经过目录查询、Snoop、数据返回和路由；远端 DRAM 还要跨 Socket 到另一侧内存控制器，再把数据送回。两条路径共享部分链路，却不是同一种事务，因此 Graviton 4 可以同时拥有不错的核间一致性延迟和偏弱的远端内存带宽。

验证系统瓶颈时，应把 Local/Remote DRAM、Read/Write、Cache-to-Cache、Home Node 距离和并发核数分开。若跨路流量增长时 Link Credit 或 Fabric Queue 饱和，而本地控制器仍有余量，优化页面放置与线程亲和性通常比改核心代码更有效。

## Neoverse V2 核心总览

V2 的宽度和重排序能力接近 Zen 4，却没有走到 Golden Cove、Oryon 或 Apple Firestorm 那样的超大型核心。更显眼的差异是频率：单路 2.8 GHz、双路 2.7 GHz；Bergamo 的 Zen 4c 在双路 256 核下可到 3.1 GHz，Genoa-X 的 Zen 4 在重负载中可维持约 3.7 GHz。

![图 6：Neoverse V2 微架构总览](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/773f3b86327014ef_06_neoverse_v2_overview.jpg)

*图 6：总览综合 Arm Hot Chips 2023 资料与微基准估计：六宽 Decode/Rename、1536 项 Micro-op Cache、320 项 ROB、约 213 项整数与约 198×128-bit FP/Vector 物理寄存器、约 175 项 LQ、80 项 SQ、三 AGU、64 KB L1I/L1D、2 MB L2 和 36 MB 共享 L3。BTB、Scheduler、Queue 等问号与近似值不是 RTL 确认。图中 Transaction Queue 写 96 项，后文 TRM 口径为 92 项。*

## 分支预测：八表 TAGE 与三级 BTB

宽核心和深窗口必须依靠高质量预测来避免错误路径吞掉吞吐。V2 使用八组件 TAGE（Tagged Geometric History Length）方向预测器，表比 V1 更大：更多历史长度能够覆盖不同相关距离，更大容量则减少互相破坏状态的别名冲突。

重复随机模式测试中，V2 的形态接近 Golden Cove；不过曲面只能说明可学习的模式长度、活跃分支数、容量和别名的综合效果，不能反推出完整哈希和训练策略。

![图 7：Neoverse V2 的方向模式识别](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/893f1206d0837dad_07_v2_branch_pattern.png)

*图 7：横纵轴改变 Pattern Length 与 Branch Count，低延迟区域代表重复模式仍能被稳定预测。拐点之后同时混入历史不足、表容量和冲突。*

Zen 4 能覆盖更长模式和更多活跃分支。测试据此推测 AMD 可能采用两级方向预测：快而较粗的一级先给答案，更准但更深的二级稍后覆盖。V2 低频运行，对预测阵列时序压力较小，可能无需这类 Override；这只是对行为的解释，不是两颗核心的 RTL 结论。

![图 8：Zen 4 的方向模式识别](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/5ec864908accca2a_08_zen4_branch_pattern.png)

*图 8：Zen 4 的稳定区域更大。桌面 Zen 4 还要在 5 GHz 以上运行，在高频下维持这种覆盖能力本身就是很重的前端工程投入。*

目标侧采用三级 BTB。微基准支持这样的层级：约 256 项 Nano BTB 面向小循环，每周期可处理两条 Taken；随后是一张约 8K 项、单周期的主 BTB；更大足迹可能落入约 14K 项、额外 2～3 周期的 L2 BTB。

![图 9：V2 的 Taken Branch 足迹与延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/9c9891fdb5474a1f_09_v2_btb_latency.png)

*图 9：随静态 Taken Branch 数增加出现多个延迟台阶，据此估计 256/8K/14K 三层。容量与层级均来自拐点反推，冲突和代码布局会使台阶偏离真实 Entry 数。*

![图 10：V2、Golden Cove 与 Zen 4 的目标缓存覆盖](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/046197d3a6b28a2a_10_btb_comparison.png)

*图 10：Golden Cove 的末级 BTB 约 12K，Zen 4 的 L2 BTB 约 8K。V2 在很大的 Branch Footprint 下仍能少 Bubble 供给目标，适合复杂、分支密集的服务器代码。*

间接分支的目标来自寄存器，同一个 PC 可能跳往多个地址，比普通直接分支多一个预测维度。V2 在不同目标数量下的曲线展示了这种 Target Correlation 的容量边界。

![图 11：Neoverse V2 的间接目标预测](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/b889863a14048f7c_11_v2_indirect_targets.png)

*图 11：测试改变同一间接分支可见的目标集合。目标增加后，延迟或错误率上升；这类结果不能单独说明 V2 使用 ITTAGE、Path History 还是其他目标表。*

Return Address Stack（RAS）约 31 项，接近 AMD Zen 系列。一般调用层次很少超出该范围，尾递归没有消除的函数式代码则更容易溢出。

![图 12：调用深度与返回预测](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/42e6bac956f8a7a3_12_return_stack.png)

*图 12：调用深度跨过约 31 后，返回路径开始退化，支持 31 项 RAS 的估计。V2 在容量溢出后的行为也优于对照。*

V2 处理 Call+Return Pair 只需两周期，很可能相当于每个 Taken Branch 一周期。这里的文字又称其“与桌面 Zen 4 相当”，紧接着却写 Zen 4 每对需要四周期；“两周期”与“四周期相当”在数值上并不一致，现有材料无法判断是比较口径还是文字有误。

### 体系结构视角：方向、目标和返回预测是三条不同的前端链

TAGE 回答 Taken/Not Taken，BTB 提供 Taken 后的目标，RAS 专门跟踪 Call/Return。任一链条晚到都可能形成 Fetch Bubble：方向很准，却在大目标表多等两拍；或者 Return 溢出后转向通用间接预测器，都可能拉低有效取指带宽。

硬件验证应分别观察方向错误、目标错误、BTB 各级命中、RAS Overflow/Underflow 与 Redirect 周期，并确认错误恢复时全局历史、RAS 指针和 Fetch Queue 是否一起回滚。只给一个总体 Branch MPKI，很难定位是哪条链在失分。

## 取指、译码与重命名：八宽宣称，六宽实测

预测地址先进入 32 项 Fetch Queue。V2 配备 64 KB L1I 和 48 项全相联 iTLB；1536 项 Micro-op Cache 可每周期输出八条 Micro-op，普通六宽 Decoder 则每周期六条，相邻指令融合还可能让测试看到更高的架构指令吞吐。

Micro-op Cache 采用虚拟索引、虚拟地址标识，命中不需要先查 TLB；Arm 通过一致性机制让软件观察到的行为仍像物理地址 Cache。上一代 Cortex-X/Neoverse-V 有 3072 项，V2 缩到 1536 项。考虑后端 Renamer 限制、低频和 Arm 已有的 Predecode，继续维持超大 Micro-op Cache 的收益可能有限；Golden Cove 在更高频率下也能实现六宽 Decode。

![图 13：V2 与 Zen 4 的指令供给带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/2345348a6a8e8b86_13_instruction_fetch_bandwidth.png)

*图 13：V2 与 Zen 4 会把相邻 NOP 融合成一个 Micro-op，因此小足迹峰值不能直接当作 Decode 宽度。V2 的 16 项 Fill Buffer 使 L2 代码仍可接近 4 instruction/cycle；进入 L3 后仍超过 2。AMD/Intel 的 L3 取指更强，很可能与更低的 L3 延迟有关。*

Arm 资料称 Renamer 可处理八条 Micro-op/cycle，测试却只能持续达到六条，因此这颗 Graviton 4 中的 V2 整体更像六宽核心。两种口径必须并列：八宽是 Arm 演讲给出的能力，六宽是这套实现与测试序列观察到的上限。

重命名阶段还可做 Move Elimination 和零值依赖消除。V2 的寄存器间 MOV 并非总能消除：独立 `MOV r,r` 约 3.8 IPC，依赖版本约 1.35；Zen 4 分别为 5.73/5.71。`MOV r,0` 在 V2 可达 5.71，Zen 4 为 3.77；`XOR r,r` 则是 V2 1.00、Zen 4 5.73。不同 ISA 的清零习惯不同，这张表更适合看各自识别了哪些 Idiom。

![图 14：Move Elimination 与清零 Idiom](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/9cb549b43fc10f81_14_rename_behavior.png)

*图 14：V2 对零立即数表现很好，却没有普遍消除寄存器 MOV；接近四条的独立 MOV 也说明它们仍可能占用 ALU。整数 Add 约四条/cycle，支持 Graviton 4 实现只有四条通用 ALU 的判断。*

### 体系结构视角：前端标称宽度只有穿过最窄点才有意义

八条 Micro-op 从 Cache 出来，如果 Rename/Allocate 只能持续接收六条，峰值仍由六宽决定；再往后，某个 Scheduler、物理寄存器或 LSQ 先满，还会通过 Backpressure 让前端停住。融合又会使“架构指令/cycle”高于实际分配的 Micro-op/cycle。

区分瓶颈时，应同时观察 Decode/Micro-op Cache 供给、Rename 接收、ROB 分配与各种 Full 周期。若前端送出八条而 Rename 只收六条，是宽度限制；若 Rename 本可六宽却频繁被 ROB/Queue Full 阻断，则问题在乱序资源，而不是译码。

## 乱序执行与整数集群

V2 的 ROB 图示为 320 项，整数寄存器约 213 项、FP/Vector 寄存器约 198×128-bit、Flags 约 86 项、Load Queue 约 175、Store Queue 80。它们多为微基准下的可见容量，融合、阻塞序列和恢复保留项都会改变测值。

Arm 资料称 V2 有六条 ALU，比 V1 的四条更多，但 Graviton 4 无法做到六条 Add/cycle。Add 与 Branch 混合可以超过 4 IPC，说明 Branch Unit 仍位于独立端口；未知的是 AWS 删除了 Branch Scheduler 附属 ALU，还是演讲中新增的两条 ALU。

![图 15：V2、Zen 4 与 Oryon 的整数集群](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/abec95714af97ec8_15_integer_cluster_comparison.png)

*图 15：行为重建的 V2 有四组 22 项 Scheduler，其中两组连 Branch+ALU，两组连 ALU/整数乘加；Zen 4 为四组 24 项，并让三组同时服务 AGU；Oryon 为六组 20 项。V2 图示是对 Graviton 4 的推测，不代表所有 V2 授权实现。*

用 40 条相互依赖的 Branch，后接依赖 Add 探测调度容量时，Graviton 4 没有表现出超过 60 项的可用窗口。因此更符合现象的解释，是额外两条 ALU 及对应 Queue 没有出现在这颗实现中。若判断成立，V2 整数调度容量与 Zen 4 相近；Zen 4 条目略多，却还要让三组与 AGU 共享。Oryon 的六组大 Scheduler 相比之下十分激进。

## FP/Vector：四条 128-bit Pipe

FP/Vector 侧有四条 128-bit Pipe，四条都能处理大部分基础 FP 与向量整数操作。虽然管线比 Zen 4 的 256-bit 窄，但四条都能执行 FMA，因此按 FP FMA 操作数仍能匹配 Zen 4。AMD 在 256-bit Packed Add 与 FMA 并行时占优，V2 则更适合没有充分利用宽向量的代码。

![图 16：V2、Zen 4 与 Oryon 的 FP/Vector 调度](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/a310c47be073fb7f_16_fp_vector_cluster_comparison.png)

*图 16：V2 为约 36 项 NSQ、两组各 28 项 Scheduler、四条 128-bit Pipe；Zen 4 为 64 项 NSQ、两组各 36 项 Scheduler 及更专门化的 256-bit Pipe；Oryon 直接使用四组各 48 项 Scheduler。V2 比 Cortex-X2 多了少量条目，但未完成 FP/Vector 操作容量仍低于 Zen 4，更远低于 Oryon。*

Non-Scheduling Queue（NSQ）可先接纳暂时进不了 Scheduler 的操作，延后前端停顿，又不必承担完整 Wakeup/Select 网络。它增加的是等待容量，不是可立即发射的端口数。

V2 的 FP Add/Multiply/FMA 延迟为 2/3/4 周期，Zen 4 为 3/3/4；128-bit Vector Integer Add/Multiply 则是 2/4，Zen 4 为 1/3。V2 的两周期 FP Add 很漂亮，但低频并没有让 L1D 和整数向量也获得周期数优势。测试说明标量 FP32 与 4×FP32 的 128-bit 向量延迟相同。

![图 17：FP 与向量执行延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/511e73461b3579b2_17_fp_vector_latency.jpg)

*图 17：FP Add 是 V2 的强项；简单 Vector Integer Add 仍需两周期，文中提出一种可能性：向量寄存器文件读取也许分成两级，而 AMD/Intel 多数核心可在一级完成。该解释没有 RTL 佐证。*

### 体系结构视角：容量、吞吐和依赖链延迟是三件事

大 Scheduler/NSQ 允许核心绕过更多长延迟操作；Pipe 数决定独立操作的稳态吞吐；单条依赖链则受执行延迟限制。四条 128-bit FMA 很强，并不意味着一条串行 FMA 链每周期完成一次；反过来，两周期 FP Add 也不能补偿工作集没有足够并行度。

可用独立指令流测吞吐、单链测延迟、逐步增加未完成操作数测 Queue 深度。若 Scheduler Full 而 Pipe 利用率低，通常是端口可达性或依赖结构问题；NSQ Full 则说明长延迟工作已超出廉价缓冲能力。

## Load/Store：三 AGU、TLB 与 Store Forwarding

V2 有三条地址生成单元（AGU）：两条可处理 Load/Store，一条只处理 Load。Zen 4 同样有三 AGU，但通过让 AGU 与 ALU 共享 Scheduler 节省条目。

地址转换采用两级 TLB。一级 DTLB 为 48 项全相联，二级为 2048 项、八路，L2 TLB 命中额外增加 5 周期；容量与 Cortex-X2 相同。Zen 4 从 Zen 3 的 64/2048 项增至 72/3072 项，二级命中多 7 周期。桌面 Zen 4 高频下换算为时间仍可能更快；在低频 Zen 4c 服务器中，这项优势会反转。

内存排序还要检查年轻 Load 是否与更老 Store 重叠。V2 的快路覆盖较窄：64-bit Store 之后，只能把任意一个 32-bit 半部快速转发给 32-bit Load。这与较早的 Neoverse N1 很相似；AMD 和 Intel 已能对“Load 完全包含于旧 Store”的更多组合做快路处理。

![图 18：Neoverse V2 的 Store-to-Load Forwarding](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/c63344b61b254a2e_18_v2_store_forwarding.png)

*图 18：沿用 Henry Wong 的方法并改写为 AArch64，横纵轴扫描 Store 与 Load Offset。快路匹配时为 5 周期；不支持的重叠组合多为 10～11 周期。该矩阵描述外部行为，不足以确定 Store Queue 比较器或旁路网络。*

![图 19：Zen 4 的 Store-to-Load Forwarding](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/7ddf58c35b127fe8_19_zen4_store_forwarding.png)

*图 19：Zen 4 对完全包含组合覆盖更广，最简单的地址匹配可做到零额外延迟，普通快路为 6～7 周期；失败路径却深达约 19～20 周期。网页正式图注说明这是同一测试在 Zen 4 上的结果。*

无依赖时，访存进入 64 KB L1D。V2 的 Load/Store 都以 64 B 为对齐边界；Zen 4 的 Load 为 64 B、Store 为 32 B，因此 Store 更容易跨内部边界。V2 最低 L1D 延迟为四周期，与 Zen 4 相同；考虑 V2 频率很低，这个周期数并不占优。

跨 4 KB Page 需要两次地址转换。材料先称 V2 的 Split-page Store 惩罚为 11～12 周期，Zen 4 为 33，Golden Cove 为 24；紧接着又称“V2 与 Zen 2 的 Split-page Store 没有惩罚”。两个句子对 V2 自相矛盾，无法据此选定一个数值，更可能是其中一个测试类型写错。

向量带宽为三条 128-bit Load，而 Zen 4 可做两条 256-bit Load。Arm 还称 V2 每周期可服务四条 64-bit Scalar Load，但核心只有三 AGU，因此这很可能是 `LDP` Pair Load 的特殊计数口径。

64 KB L1D 容量优于 Zen 4 的 32 KB 和 Golden Cove 的 48 KB。替换策略从 Pseudo-LRU 改为 RRIP（Re-Reference Interval Prediction），用重用距离估计减少有用数据被过早逐出。

### 体系结构视角：Forwarding 和未对齐慢路必须连同 Replay 看

Store Forwarding 快路解决“数据仍在 Store Queue、尚未写入 Cache”时的真实依赖；地址或宽度不匹配后，核心可能等待 Store 退休、重放 Load 或合并两个 Cache Line。快路覆盖越广，比较和旁路逻辑越复杂；回退越深，编译器偶尔产生的部分重叠就越昂贵。

验证应扫描 Load/Store 宽度、Offset、完全包含、部分重叠、跨 64 B 和跨 4 KB，并同时记录周期、Replay、TLB Miss、Page Walk 与异常。资料没有公开 V2 专用 PMU 编码，也没有 RTL，矩阵不能证明某套内部实现。

## L2、L3 与带宽

V2 可配置 1 MB 或 2 MB 私有 L2，AWS 选择 2 MB。命中延迟为 11 周期，低于 Zen 4 的 14 周期；换算成时间后略差于高频 Genoa-X，却优于 3.1 GHz Bergamo。容量还是 Zen 4 私有 L2 的两倍。

![图 20：以周期表示的 Cache 与内存延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/4454ef91e9697208_20_cache_memory_latency_ns.png)

*图 20：标题写“2 MB Pages”，纵轴实际为 Cycles。Graviton 4 的 L1 约 4、L2 标注 11.26，16 MB 测试点的 L3 为 67.94，主存约 300 多周期。图内 Sapphire Rapids 约 5.04/16.13/125.19，Bergamo L2 约 14.31、L3 55.88。*

![图 21：以纳秒表示的 Cache 与内存延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/07025bc21946268a_21_cache_memory_latency_cycles.png)

*图 21：文件名保留下载时语义，但纵轴为 ns。V2 L2 约 4 ns，16 MB L3 测试点约 25 ns；Bergamo L3 约 18.02 ns，Genoa-X 约 18.38，Sapphire Rapids 约 32.98。周期和时间必须结合频率一起看。*

V2 需要大 L2 隔离高延迟 Mesh：L3 命中约 68 周期、25 ns，比 Sapphire Rapids 好，接近 Ice Lake Server，却差于 Bergamo 的约 18 ns，Genoa-X 更强。

单核带宽不算差，但 AMD/Intel 为宽向量投入更多。Sapphire Rapids 可每周期做三条 256-bit Load。Arm Hot Chips 资料声称 V2 的四 Bank L2 可达 128 B/cycle——每个 Bank 每两周期处理一条 64 B Line；实际简单线性只读却不到 32 B/cycle，Read-Modify-Write 或 Write-only 也没有显著改变。

![图 22：单线程 Cache 与内存带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/905276df7896fba5_22_single_thread_cache_bandwidth.png)

*图 22：Graviton 4 在 L1 区约 126.61 GB/s，L2 区约 67.64，单核 L3 只有约 30.53；Sapphire Rapids L1 约 459.95、L2 约 189.83，Genoa-X L1/L2/L3 约 214.66/118.07/89.96。频率、向量宽度和访问代码均参与差值。*

单核 L3 只有略高于 30 GB/s，高延迟很可能限制并发命中数。Transaction Queue 在 Hot Chips 图中为 96 项，Technical Reference Manual 则为 92 项；两种公开口径不一致。无论 92 还是 96，都不足以完全隐藏 68 周期 L3。

![图 23：单颗处理器的全核 Cache 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/0398b466e5bb2a8e_23_full_chip_cache_bandwidth.png)

*图 23：96 核 Graviton 4 的 L1 峰值约 12.25 TB/s，低于 Genoa-X 的约 18.78 TB/s，却较 Graviton 3 和 Milan-X 大幅提升；L2 仍在数 TB/s。所有私有 L2 合计 192 MB，远大于 36 MB L3，因此很难用容量扫描干净隔离全芯片 L3 带宽。*

### 体系结构视角：大私有 L2 是对 Mesh 延迟的结构性补偿

共享 L3 小而远时，扩大每核 L2 能提高命中率、减少 Mesh 流量，并让 96 核更少争抢目录和数据链路。但它也使总私有 Cache 容量超过 L3，传统“逐级跨过容量台阶”的全芯片测试失去清晰边界。

要区分 L2 Bank、Miss 并发和 Mesh 反压，应改变独立 Stream 数、核心数与地址 Home Node，并观察 L2 Miss、Transaction Queue 占用、Fabric Credit 和内存带宽。128 B/cycle 是结构峰值；不到 32 B/cycle 的简单测试是端到端结果，两者并不必然互相否定。

## 两项轻量 Benchmark

测试用 libx264 以 veryslow/CRF 24 编码 4K 视频，并用 7-Zip 压缩 2.67 GB 文件。前者强调向量和带宽，后者主要是标量整数并对分支预测更敏感。

比较段落把被测对象写成“八核 Graviton 3 实例”，图中却明确标为 “Graviton 4 @ 2.8 GHz, 8c”，结合全文更像一处代际笔误；中文稿保留这项不一致。AMD 对照包括 3.1 GHz Bergamo 的 8c/16t CCX，以及把 Ryzen 7950X3D 降到 3.42 GHz 模拟 EPYC 9V33X 名义全核频率。真实 9V33X 重负载可维持约 3.7 GHz，因此这只能给出模糊的 Genoa 参照。

![图 24：八核 Benchmark 性能](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/aed54683e5e7362e_24_benchmark_performance.png)

*图 24：libx264 中 Graviton 4 为 3.84 FPS；无 SMT 的 3.42 GHz Zen 4 为 4.54～4.67，开启 SMT 为 6.18～6.84，领先超过 60%。7-Zip 中 Graviton 4 为 71.92 MB/s，高于无 SMT Zen 4 的 69.49，也高于 Bergamo CCX 的 54.46；Zen 4 加 SMT 后为 79.87～90.65。*

V2 在两项工作负载中的 IPC 都更高，却不足以抵消 Zen 4 的频率与 SMT。IPC 还受 ISA 指令数影响：libx264 中 V2 比 Zen 4 多执行 17.6% 指令，部分与向量长度有关；7-Zip 则反过来，Zen 4 为完成同一任务多执行 9.6%。

![图 25：libx264 与 7-Zip 的每线程 IPC](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/967a8713f6012904_25_benchmark_ipc.png)

*图 25：Graviton 4 的 libx264/7-Zip 为 2.47/2.20 IPC；Zen 4 单线程约 2.08～2.14/1.94～2.13，双 SMT 负载下每线程降到约 1.53～1.58/1.64～1.81。性能计数器无法在两个 SMT Thread 都有负载时提供逐核 IPC。*

方向微基准里 Zen 4 明显更强，真实程序差距较小。libx264 预测正确率为 V2 97.42%、Zen 4 97.36%～97.54%；7-Zip 为 V2 95.07%、Zen 4 95.75%～95.92%。Zen 4 的预测器可能为 SMT 下两个 Thread 的状态竞争留出额外余量。

![图 26：两项工作负载的分支预测正确率](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/cda1c213a2911c53_26_branch_prediction_accuracy.png)

*图 26：不到 1 个百分点的差异并不等于影响很小，因为还要乘以 Branch Frequency 和 Mispredict Penalty。libx264 分支占比低，7-Zip 中 x86-64 与 AArch64 都约有 18% 指令是分支。*

V2 没有可跟踪 Renamed Micro-op 的性能计数器，因此难以精确量化一次错误预测浪费了多少后端工作。以每千条指令的错误预测数（MPKI）归一后，libx264 中 V2 为 1.57，略优于 Zen 4 的 1.66～1.80；7-Zip 中 V2 为 8.93，Zen 4 为 7.30～7.61。7-Zip 不到 1% 的准确率差异，最终让 Zen 4 的每指令错误预测少 17.9%。

![图 27：libx264 与 7-Zip 的 Branch MPKI](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/1bdc38d3745d79ef_27_branch_mpki.png)

*图 27：MPKI 把预测错误按总指令数归一，更能反映分支密度差异。它仍不能单独给出损失周期，因为 Redirect 深度、错误路径发射与前后端重叠都不同。*

受 Graviton 4 实例费用限制，测试没有逐层展开更多 PMU 事件，只用 Frontend Bound 与 Backend Bound 给出概览。libx264 主要受后端限制；7-Zip 同时受前后端限制，高分支率增加取指难度。V2 的超大、低周期 BTB 可能帮助 7-Zip，64 KB L1I 则可能帮助分支足迹较小的 libx264。

![图 28：前端与后端受限比例](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/f9e7104a3a48bc2e_28_frontend_backend_bound.png)

*图 28：libx264 中 Graviton 4 为 31.30% Backend Bound、3.93% Frontend Bound；7-Zip 为 35.61%/10.51%。Zen 4 不同 SMT/V-Cache 配置的比例变化很大，指标定义和平台实现也会影响可比性。*

### 体系结构视角：IPC、指令数和吞吐必须同时看

高 IPC 可能来自较低频率、不同 ISA 指令粒度或更少的 SMT 竞争，并不自动变成更高任务吞吐。libx264 中 V2 的 IPC 更高，却执行更多指令且频率更低；7-Zip 中，V2 凭较高 IPC 在八核无 SMT 对照中取得更好结果，Zen 4 开启 SMT 后则反超。

严谨比较还需要相同软件版本、编译器、Flags、输入、核心数、线程数、频率与功耗，并报告总指令、IPC、MPKI、Cache Miss 和 Wall Time。本页条件不足以形成通用云实例性价比或每瓦排名。

## 最后的评价：好核心，但不是桌面式性能怪兽

Arm 已经掌握现代乱序核心的复杂设计。V2 在既有 Cortex-X/Neoverse-V 基础上改善预测、窗口、执行和 Cache，并因只服务服务器与手机而不必像 Golden Cove、Zen 4 那样覆盖从低功耗到 5 GHz 桌面的宽广区间。深流水线在高频有利，低频时未必占优。

这种取舍让 V2 在 Call/Return、L2 周期延迟、Store Forwarding 失败恢复等位置表现很好；材料也把 Split-page Store 列为优点，但前文数字自相矛盾。另一方面，AMD/Intel 更复杂的 Forwarding 快路会抵消 V2 的简单低频优势，L1D 和向量整数延迟在周期数上也不优于 Zen 4。

![图 29：Neoverse V2 与 Zen 4c 的核心面积](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/0a1c850b2fe76238_29_v2_zen4c_area.jpg)

*图 29：图中 V2 面积与 Zen 4c 出人意料地接近。跨工艺、物理库、Cache 配置和面积测量方法的图片比较只能说明密度潜力，不能当作精确晶体管效率排名。*

V2 的定位不是 Zen 4、Golden Cove 或 Oryon 那样追求极高单线程，而是在功耗受限手机或高密度服务器中提供足够好的单线程性能。从核心面积看，它应能匹配 Bergamo 的核心数量，尤其在像 Graviton 4 这样压缩 L3 时；但 AWS 最终仍选择 96 核，与主流 Genoa 相同，而非 Bergamo 的 128 核。

![图 30：AWS 发布 Graviton 4 时的产品定位](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_neoverse_v2_graviton4_wechat_article_zh/400c560a59cb7f56_30_graviton4_launch.jpg)

*图 30：发布图强调更高核心数、内存容量和带宽。产品级收益来自 V2、CMN-700、DDR5、实例配置和云软件共同作用，不能全部归到核心 IPC。*

与 Bergamo 相比，V2 有胜有负；面对 Genoa/Genoa-X 则频率劣势过大。3.42 GHz 的八核 Zen 4 已经给 Graviton 4 很大压力，而至少有一家云厂商提供 3.7 GHz Genoa 实例。

孤立看，Neoverse V2 是一颗好核心；放到 2024 年时间点，它又要面对即将到来的 Zen 5。Cortex-X4 已进一步扩大流水线资源，但真正关键的是能否在不把频率压得过低的前提下兑现这些宽度。只盯 IPC 或只盯频率，都会漏掉性能—功耗—面积的整体平衡。

### 体系结构视角：从 V2 与 Graviton 4 可以看到的几件事

第一，高密度服务器核不需要复制桌面核的全部野心。六宽、320 项 ROB、四条 128-bit FP Pipe 已足以提供强 IPC；更重要的是在目标频率和功耗下把每一级做得均衡。

第二，大私有 L2 与小共享 L3 是明确的系统取舍。它把常见工作集留在核心附近，降低 96 核 Mesh 压力，却使跨核共享数据和大工作集更依赖高延迟 L3、目录与内存系统。

第三，低周期不等于低时间，高 IPC 也不等于高吞吐。V2 的 11-cycle L2 很漂亮，2.8 GHz 下的纳秒值却未必优于高频 Zen 4；Benchmark 还要再乘以指令数、频率、SMT 与并行效率。

第四，微基准最有价值的地方不是猜出一个确定框图，而是找出资源之间的约束关系。六宽实测与八宽宣称、四 Add/cycle 与六 ALU 宣称、92/96 项 Transaction Queue 都应作为边界保留，而不是为了图表整齐强行统一。

第五，服务器扩展首先是数据放置问题。Graviton 4 片内一致性延迟不错，远端 DRAM 带宽和延迟却弱；线程亲和性、NUMA 分配和共享数据结构会决定 96/192 核能否转化成应用吞吐。

第六，核心 IP 与 SoC 产品必须分层评价。TAGE、BTB、ROB、AGU 和 L1/L2 属于 V2 核心；36 MB L3、CMN-700 配置、十二通道 DDR5、跨 Socket Link 和实例频率属于 AWS 实现。把后一层的优缺点全部归因于 Arm 核心，会得到错误的架构结论。

如希望支持 Chips and Cheese 的独立测试，可通过其 [Patreon](https://www.patreon.com/ChipsandCheese) 或 [PayPal](https://www.paypal.com/donate/?hosted_button_id=4EMPH66SBGVSQ)；技术讨论可加入其 [Discord](https://discord.gg/TwVnRhxgY2)。

## 参考资料

- Chips and Cheese：[*Arm’s Neoverse V2, in AWS’s Graviton 4*](https://chipsandcheese.com/p/arms-neoverse-v2-in-awss-graviton-4)
- Henry Wong：[*Store-to-Load Forwarding and Memory Disambiguation in x86 Processors*](https://blog.stuffedcow.net/2014/01/x86-memory-disambiguation/)
- Microsoft Azure：[Dalsv6 / Daldsv6 系列实例](https://learn.microsoft.com/en-us/azure/virtual-machines/dalsv6-daldsv6-series)
