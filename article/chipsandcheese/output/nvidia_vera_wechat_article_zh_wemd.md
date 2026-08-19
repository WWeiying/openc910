---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "nvidia_vera_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*NVIDIA’s Vera Whitepaper Has a Thread Loose*
> - 撰文：George Cozma、Chester Lam
> - 首发：Chips and Cheese
> - 发布：2026 年 8 月 5 日
> - 链接：https://chipsandcheese.com/p/nvidias-vera-whitepaper-has-a-thread

NVIDIA 的 Vera CPU 很可能是一颗相当出色的服务器处理器。问题恰恰在于：一颗拥有宽前端、大窗口、激进分支预测、值预测和 1.2 TB/s 内存带宽的芯片，本来不需要靠含混的 SMT 示意、选择性归一化和缺少实验细节的图表来证明自己。

George Cozma 对 Vera 白皮书的评价因此分成两层。硬件本身值得期待；白皮书用来支撑优势的若干论证，却经不起同样严格的体系结构审视。下面沿白皮书的图表逐项展开，同时保留哪些是 NVIDIA 公开信息、哪些是白皮书数据、哪些是 Chips and Cheese 的质疑。

## 一、先看硬件：Olympus 是一颗什么样的核心

Vera 是一颗 88 核单片 CPU。每颗 Olympus 核心基于 Armv9.2，前端最多每周期译码 10 条指令、跟踪两条 Taken 分支；后端拥有较大的乱序窗口、内存重命名（Memory Renaming）、六条 128-bit SVE 执行管线、四条 Load 和两条 Store 路径。每核配置 96 KB L1D、2 MB 私有 L2，整片再提供 164 MB 共享末级 Cache。

![图 1：NVIDIA Olympus 核心结构](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_vera_wechat_article_zh/281272f9a0686841_01_figure.png)

*图 1：Olympus 的宽度贯穿预测、取指、译码、重命名、调度和执行。白皮书还给出约 10 cycle 的 2 MB L2，以及约 3.4 TB/s 的片上相干互连能力。它不是单纯靠堆核心数取胜的“小核”设计。*

Vera 最有辨识度的两项机制是值预测（Value Prediction）与 Graph Prefetcher。前者尝试在真正结果产生前猜测数据值，让依赖指令提前执行；后者针对指针追逐和数据相关的访问链，提前发起后续访问。它们都在解决同一个问题：乱序窗口即使很大，也很难跨越数百周期的内存依赖链。

这些方向并非凭空出现。Intel 已在产品中部署 Data-Dependent Prefetcher（DDP）和 Granite Rapids 的 Array of Pointers 预取；AMD 的早期 Zen 也有较有限的浮点值预测迹象。Olympus 的意义在于把它们做得更广、更主动，而不是“第一次发明”。同样，神经分支预测也有 Piledriver、Zen 以及后来 TAGE 系列的长期演进背景。

### 体系结构视角：值预测为什么既诱人又危险

普通乱序执行只能在操作数已知后发射依赖指令。值预测则把“等待数据”改成“先猜再验证”：猜对可以把一条很长的依赖链压缩成并行工作，猜错却必须撤销所有使用了错误值的年轻指令，并恢复寄存器映射、Load/Store 顺序和异常状态。

因此，值预测的价值不能只看命中率。还要同时看覆盖率、错误恢复距离、被预测值的消费者数量、重放流量和节省的关键路径周期。若公开 PMU 能区分 value-prediction attempt、correct、mispredict 和 replay，才有可能把应用加速真正归因到这项机制。

## 二、Spatial Multithreading：名字新，资源分配问题并不新

NVIDIA 把 Vera 的双线程机制称为 Spatial Multithreading。白皮书用左图表示传统 SMT：两个线程似乎按时间轮流占用整条流水线；右图则把每一级资源静态分给两个线程，强调确定性与隔离。

![图 2：NVIDIA 对传统 SMT 与 Spatial Multithreading 的对比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_vera_wechat_article_zh/c061d997974c92ad_02_figure.jpg)

*图 2：右侧的空间划分可以提供资源隔离和更可预测的服务质量；争议在于左侧并不准确代表现代 SMT。执行端口、Load/Store 单元和 Cache 通常能在同一周期服务两个线程，并非整条流水线只能轮流归一个线程。*

问题可以用一个 10-wide 核心简化说明。若把译码固定分成每线程五条，一侧没有足够工作时，另一侧也不能使用空闲槽位；若让前端逐周期选择线程，则可根据双方就绪程度动态填满八个或十个槽位。

![图 3：静态五加五与逐周期动态选择的简化示意](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_vera_wechat_article_zh/686d4b15e40a578d_03_figure.png)

*图 3：静态分区提高隔离性，却可能留下不可借用的空槽；动态竞争更容易提高平均利用率，却会带来线程间干扰。两者是 QoS、吞吐和公平性的取舍，并非“空间一定比时间更高效”。*

早在 Pentium 4 的 SMT 管线中，执行端就能同时接收两个线程的微操作。取指、译码或分配阶段可以有线程选择策略，但进入调度器后的执行与访存资源通常并不按整周期独占。

![图 4：Pentium 4 的 SMT 流水线示意](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_vera_wechat_article_zh/e25314e54668ed9b_04_figure.jpg)

*图 4：两个线程的微操作可以共同进入队列并竞争执行端口。这张历史示意直接反驳了“传统 SMT 必然整拍轮换整条流水线”的过度简化。*

资源也不只有“全共享”和“完全静态平分”两种状态。AMD 的 Zen 5 文档展示了四类常见策略：竞争共享、固定划分、水位线限制，以及每线程复制。

![图 5：AMD Zen 5 的 SMT 资源共享方式](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_vera_wechat_article_zh/0c0a9b7ffe5884ca_05_figure.jpg)

*图 5：L1、TLB、Op Cache 等资源可以竞争共享；部分队列采用水位线；退休队列等结构可静态分区。现代 SMT 本来就是按结构选择策略的混合体。NVIDIA 尚未披露 Olympus 各队列究竟如何划分。*

Olympus 在兄弟线程结束后，还要等待 10,000 cycle 才回到单线程模式。这说明软件必须理解线程驻留、迁移和空闲状态的代价。Spatial Multithreading 的真正优势更可能是隔离、确定性和 agent QoS，而不是白皮书图中暗示的天然吞吐优势。

### 体系结构视角：SMT 应该怎样比较

公平实验至少要给出单线程、双线程和双独立核心三组结果，并记录每线程 IPC、尾延迟、功耗和各队列占用。若静态分区降低了吞吐却显著改善 P99 延迟，它仍可能适合云服务；若只看平均吞吐，则动态共享往往更容易利用不均衡的线程级并行。评价必须围绕目标，不应由一张卡通图替代。

## 三、一个 NUMA 节点，不等于物理距离消失

白皮书把双路 Vera 表示为每个 Socket 一个 NUMA 节点，并把双路 AMD Turin 画成 32 个 NUMA 节点。

![图 6：Vera 与 x86 NUMA 的白皮书对比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_vera_wechat_article_zh/b5bc8f0bb2810310_06_figure.jpg)

*图 6：32 个节点是 AMD 可选的最高粒度配置，并非 x86 平台的固定属性。EPYC 可运行 NPS4、NPS2、NPS1，甚至更统一的模式；把一种极端配置写成架构固有特征，会放大对比。*

软件只看到一个 NUMA 节点，确实能降低线程绑定和内存放置的复杂度。但 88 核、164 MB Cache、八路内存接口和大规模互连仍存在物理距离。地址的 Home Agent、Cache Slice 和内存控制器位置不会因为 ACPI 只暴露一个节点而消失。

白皮书给出的核间延迟热图显示 Vera 更均匀，并宣称“最高降低 50%”。但图中没有核编号、最小值/中位数/最大值、测试分布和同步方法。

![图 7：Turin 与 Vera 的核间延迟热图](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_vera_wechat_article_zh/59c904955f49d0b3_07_figure.jpg)

*图 7：Turin 呈现明显簇内/簇间层次，Vera 更均匀。均匀并不自动等于平均更低：簇式设计常以很低的簇内延迟换取较高的跨簇延迟，而大 Mesh 可能让所有核心都处在一个中等区间。缺少行列映射和统计分布，无法复算“50%”。*

### 体系结构视角：逻辑单体与物理单体是两件事

NUMA 是软件接口，互连距离是硬件事实。统一地址视图可以降低编程成本，却可能让软件失去主动靠近数据的机会；显式 NUMA 增加部署复杂度，却能让数据库、内存池和 HPC 程序利用局部性。更完整的比较应同时给出本地/远端延迟分布、跨区带宽、受载延迟和 NUMA-aware/oblivious 两套应用结果。

## 四、“Agentic Benchmark”究竟测了什么

白皮书把 CPython、GCC、LLVM 和 Cppcheck 四个 SPEC CPU2026 整数子项称为 agentic benchmarks，并给出每核 1.7～1.8 倍的优势。

![图 8：白皮书选择的四项 SPEC CPU2026 结果](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_vera_wechat_article_zh/9e834e1e50adb77c_08_figure.png)

*图 8：这些程序可以作为 AI Agent 工作流中的 CPU 组件，但本质仍是解释器、编译器和静态分析负载，并不是包含模型推理、工具调用、代码生成和验证的端到端 Agent 测试。*

完整的双路估算结果则是 Vera 925、EPYC 9755 为 898，总吞吐领先约 3.0%。Vera 用 176 个物理核、352 个副本，EPYC 用 256 个物理核、512 个副本；按整套整数测试折算，Vera 的每核优势约 50%，仍然很强，但低于四个精选子项的 70%～80%。

![图 9：Vera 的 SPEC CPU2026 整数 Rate 估算明细](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_vera_wechat_article_zh/a85d9bdea629f3e3_09_figure.jpg)

*图 9：表中列出 13 个子项、352 copies 和总估算 925。完整套件与精选子集回答的是不同问题：前者更接近总体吞吐，后者只说明特定编译/解释类代码很适合 Olympus。*

![图 10：白皮书论证与实际可支持结论的对应](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_vera_wechat_article_zh/3288a693dac0fef9_10_figure.png)

*图 10：四组主张分别存在 SMT 示意失真、NUMA 取极端配置、跨 ISA 计数器不可审计，以及 RL 图缺少实验定义的问题。质疑针对证据链，不是否认 Vera 的硬件能力。*

更令人困惑的是“单线程 IPC”图。白皮书实际让 Vera 跑 352 copies、EPYC 跑 512 copies，都是每个物理核两个副本的满载状态。这样的数据可以反映满载下每个副本的效率，却不能自然称为单线程运行。

![图 11：满载 Socket 下的所谓单线程 IPC](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_vera_wechat_article_zh/d558dd6523de9b78_11_figure.png)

*图 11：Vera 在四个子项上显示约 1.4～1.9 倍 IPC。白皮书没有说明 PMU 事件定义、采样方式、线程聚合、频率和指令口径，尤其跨 Arm/x86 时“每条指令”并非天然可比。*

同样的问题出现在每周期分支预测、Taken 分支、取指操作和后端操作数量上。图中最高分别达到 2.3、3.5、2.4 和 4.3 倍，但没有原始计数和事件定义。

![图 12：Vera 与 Turin 的前后端计数器对比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_vera_wechat_article_zh/da05bc515999d14a_12_figure.png)

*图 12：更高的 ops/cycle 可能来自更宽的核心，也可能来自 ISA 拆分、微操作定义和计数位置不同。若要证明某项机制造成加速，需要给出机制开关、命中/错误次数或至少完整事件公式。*

### 体系结构视角：跨 ISA 的 IPC 为什么容易误导

Arm 和 x86 的架构指令粒度不同，一条 x86 指令还可能拆成多个微操作。即使都叫 backend ops，计数位置也可能分别位于译码、分配、发射或退休。更稳妥的比较是用完成同一工作所需的墙钟时间和能量作主指标，再用各平台内部一致定义的 MPKI、Cache miss、队列占用和分支恢复周期解释原因，而不是直接把两个厂商的“ops”相除。

## 五、1.2 TB/s 内存：真正的优势来自接口规模

Vera 使用八个 SOCAMM2 LPDDR5X 通道，最高 1.5 TB 容量、1.2 TB/s 带宽，NVIDIA 宣称内存功耗约 50 W。白皮书测到约 1.1 TB/s，而对照 Turin 约 400 GB/s。

![图 13：Vera 与 Turin 的带宽—延迟曲线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_vera_wechat_article_zh/a5058a39e06fb6eb_13_figure.jpg)

*图 13：Vera 在约 1.1 TB/s 时仍保持约 200 ns，Turin 在约 400 GB/s 附近急剧拥塞。图形清楚说明 Vera 的带宽储备，但 Turin 数值低于 Chips and Cheese 在 12 通道 DDR5-6400 平台上测得的约 570 GB/s。*

若用 570 GB/s 重新计算，Vera 的总带宽约为 1.9 倍；按核心数折算仍约 2.8 倍。与 64 核 EPYC 9575F 的每核约 9 GB/s 相比，Vera 的 12.7 GB/s/core 约高 40%。优势仍然成立，但没有图中“最新 x86 三倍”那么普遍。

更重要的是，两边都接近各自理论带宽的 92%～93%。这说明主要差异来自内存接口数量和速率，而不是“单片设计天然比 Chiplet 更有效”。AMD 在白皮书发布两天后公布的第六代 EPYC 更将单 Socket 扩展到 16 通道 DDR5-8000/MRDIMM-12800，理论带宽可达 1.024/1.638 TB/s。

![图 14：AMD 第六代 EPYC 的内存接口升级](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_vera_wechat_article_zh/4fa2df3c4c80b62a_14_figure.jpg)

*图 14：Turin 为 12 通道 DDR5、约 614 GB/s，Venice 提升到 16 通道并可使用更高数据率。带宽主张必须绑定具体 SKU、DIMM 类型和发布日期。*

## 六、PageRank、ClickHouse 与 RL 图还缺什么

PageRank 图显示 Vera 相对 EPYC 最高约 2.6 倍，并从 1 核扩展到 32 核时接近线性；EPYC 的 32 核结果约为 10 倍。

![图 15：PageRank 核数扩展](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_vera_wechat_article_zh/25644b4b1f14afbf_15_figure.png)

*图 15：趋势有吸引力，但 GAP 输入图、规模、编译参数、线程绑定和重复统计均未给出，而且测试止于 32 核，尚不能代表 88/176 核扩展。*

ClickHouse 约 1.2 倍的结果来自较可识别的 1 亿行测试，却仍属于精选负载，也没有把高频 EPYC 9575F 放入同一张对照。强化学习图则只有方块数量：基线完成 45%，Vera 完成 85%，标成 1.8 倍。

![图 16：白皮书的强化学习训练信号图](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_vera_wechat_article_zh/c14089fe348041fb_16_figure.png)

*图 16：缺少模型、环境、CPU/GPU 分工、框架版本、Batch、功耗、重复次数和误差范围，因此它更像概念图，不能作为可复现 Benchmark。*

## 七、怎样看待 Vera

Vera 最值得关注的不是白皮书里的绿色柱子，而是 Olympus 试图同时推进的几件难事：把服务器核心做得很宽，用值预测跨越数据依赖，用 Graph Prefetcher 追踪不规则访问，以大私有 L2 和高带宽内存降低等待，再通过线程隔离为多 Agent 服务提供更稳定的 QoS。

这也导向几条更一般的认识：

1. 一项硬件机制是否新颖，不如它是否覆盖足够多的真实瓶颈、是否能在功耗和恢复代价内稳定获益重要。
2. SMT、NUMA 和 Cache 都不是二元标签。共享、分区、拓扑暴露与软件策略需要逐结构、逐工作负载讨论。
3. 归一化图表必须保留完整基线。精选子项能说明“哪里强”，不能代替完整套件说明“总体强多少”。
4. 内存系统的胜负往往先由接口预算决定，再由拓扑和调度决定。把接口数优势解释为单片/Chiplet 的本质差异，会混淆因果。
5. PMU 是解释性能的工具，不是跨 ISA 的统一尺度；没有事件定义、原始计数和实验配置，倍率只能作为线索。

George Cozma 的结论并不悲观：Olympus 看起来确实很强，Phoronix 在 NVIDIA 允许的早期测试中也看到 Vera 的几何平均成绩领先 5 GHz EPYC 9575F 约 10%，领先 Xeon 6980P 约 55%，领先 Grace 约 63%。但这些结果来自预生产平台、厂商许可的工作负载和很短的测试窗口，频率与整机功耗也没有完整记录。

真正有说服力的下一步，是等量产系统接受不受限制的独立测试：锁定软件版本，记录频率、封装与墙上功耗，给出 SMT 开关、全套应用、延迟分布和可复算的 PMU 原始数据。强大的 CPU 经得起这种检验，也值得比一张过度简化的白皮书得到更好的介绍。

## 参考资料

- George Cozma，*NVIDIA’s Vera Whitepaper Has a Thread Loose*：https://chipsandcheese.com/p/nvidias-vera-whitepaper-has-a-thread
- NVIDIA，Vera CPU Whitepaper（本文讨论对象）
- AMD，Zen 5 Software Optimization Guide（SMT 资源共享表）
- Phoronix，NVIDIA Vera 获准公开的早期性能测试
