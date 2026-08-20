---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "cpu_microarchitecture_measurement_methodology_wechat_article_zh"
---

> **资料与案例**
>
> - 方法起点：*Chips and Cheese's Microbenchmark Framework*
> - 资料撰文：George Cozma
> - 首发：Chips and Cheese，2024 年 11 月 13 日
> - 原始链接：https://chipsandcheese.com/p/chips-and-cheeses-microbenchmark
> - 公开代码：https://github.com/ChipsandCheese/CnC-Tools
> - 代表案例：Chips and Cheese 的 P550、Cortex-X925、Zen 4、SPEC CPU2017、核间延迟与频率响应测试
> - 方法整理：wangwy

跑出一个分数不难，难的是回答三个更有价值的问题：这颗处理器为什么快或慢，瓶颈落在哪个子机制，以及下一组实验怎样推翻或加强当前解释。

Chips and Cheese 的处理器文章看似在逐颗核心拆解，背后却反复使用同一种实验语言：构造一个尽可能单纯的指令流，只改变一个变量，观察曲线的台阶、斜率和相互干扰，再用另一种测试或性能监控单元（Performance Monitoring Unit，PMU）交叉验证。最终得到的不是一张“官方框图”，而是一套对外部现象解释力较强、同时允许被后续证据修正的微结构模型。

这篇文章把这种方法整理为一条可以亲手执行的路线。目标不是照抄某个测试程序，而是掌握如何把性能问题拆开、如何测延迟和吞吐、如何反推 BTB、RAS、ROB、物理寄存器、调度器、Load/Store Queue、TLB、Cache 和并发 miss 容量，以及如何知道自己的结论说过头了。

## 一、先说清楚：公开框架不等于全部测试源码

Chips and Cheese 在 2024 年公布 CnC-Tools，希望先统一测试框架和数据格式，长期再让社区补充测试，并用多种方法测同一件事，以便相互校验。这个方向本身很重要：微基准最怕每篇文章换一套计时、绑核和输出方式，最后连同一台机器的结果都难以复现。

截至 2026 年 8 月 20 日核对的仓库提交 `00aca29b5e2fb42e0d8c19319401d9c58f215f09`，公开代码仍明确标为 WIP。框架提供 Linux/Windows 逻辑处理器枚举与线程亲和性、基于 `CLOCK_MONOTONIC` 的纳秒计时包装，以及 `.cnc` 结果存储；CPU 测试中主要可见的是正在迁移的 Core Coherency Latency。P550、X925 等文章里的分支、ROB、调度器和 Store Forwarding 探测并没有全部公开在这个仓库中。

公开的核间测试仍很适合学习实验结构。它把两个线程固定到指定逻辑处理器，默认用原子比较交换让同一共享字在两核间往返，也可选择普通 Load/Store 路径；默认迭代一千万次，再遍历全部逻辑处理器对，形成延迟矩阵。代码还提供地址偏移和并行测试数量参数。

但“公开”不代表可以跳过审查。当前实现用 `gettimeofday` 包住线程创建、执行与回收，并先把总时间截成毫秒，再归一化为纳秒；一千万次往返能够摊薄固定开销，低迭代次数却可能明显受计时粒度和线程生命周期影响。`-nolock` 路径使用 `volatile` 普通访问，它不是 C 语言内存模型中的线程同步原语，严谨实验应改用明确的原子语义或经过核对的汇编。框架给出了良好起点，测量契约仍需要实验者自己完成。

### 体系结构视角：方法的价值高于某一份测试代码

一套成熟方法应该允许两个独立实现得到相近结论，也应该在结果不一致时帮助定位差异来自计时、代码生成、操作系统还是硬件。公开框架最值得继承的不是某个常数，而是统一平台层、计时层、原始数据和测试元数据；真正的微结构判断，还要靠受控刺激、正交验证和证据边界。

## 二、处理器评测要分成四层

评测经常失败，是因为不同层的问题被一个分数混在一起。比较稳妥的顺序是从外向内走，再回到真实负载验证。

| 层次 | 要回答的问题 | 常见输出 | 最容易犯的错误 |
| --- | --- | --- | --- |
| 整体性能 | 完成同一工作要多久、耗多少能量 | 时间、吞吐、分数、焦耳/任务 | 只看 IPC 或最高频率 |
| 瓶颈归因 | 时间主要损失在前端、执行还是存储系统 | Top-down、MPKI、停顿周期、带宽 | 把相关性当因果 |
| 子机制探测 | 某条快路的延迟、吞吐、容量和冲突条件是什么 | cycle/op、B/cycle、容量台阶、偏移矩阵 | 把可见拐点当官方参数 |
| 模型验证 | 当前解释能否预测另一组实验 | 正交微基准、PMU、跨指令对照、RTL | 只寻找支持证据 |

整体性能决定结论有没有现实意义，微基准解释结论为什么发生。两者缺一不可：只有应用分数，很难指导硬件或软件优化；只有微基准，又容易把罕见慢路当成整颗处理器的主要矛盾。

一个实用的粗分解是：

```text
执行时间 ≈ 退休指令数 ÷ 退休 IPC ÷ 平均有效频率
```

这不是严格恒等式，却能提醒评测者同时检查动态工作量、每周期推进能力和时钟。跨 ISA 时，编译器、库与向量化会改变退休指令数；IPC 会受到预测、Cache、TLB 和乱序资源影响；平均频率又受功耗、温度、线程数与电源策略控制。只报其中一个量，解释链条一定不完整。

## 三、先把实验地基打牢

微基准通常短、快、重复性高，也因此更容易被编译器、计时器和系统噪声完全支配。正式测试前，至少要固定并记录下面这些条件。

```text
处理器与 SoC：型号、步进、微码/固件、核心类型、SMT 状态
系统：主板、BIOS、电源模式、操作系统、内核、虚拟化状态
频率：基频/Boost、固定或动态、实际采样值、温度与功耗限制
内存：通道、频率、时序、NUMA 节点、页大小、透明大页状态
软件：源码提交、编译器、完整参数、链接库、输入与线程数
实验：绑核、预热、重复次数、样本顺序、原始结果与误差统计
```

第一步是看反汇编。`volatile` 只能约束部分编译器行为，不能保证指令数量、寄存器分配、对齐或融合方式与设想一致。内联汇编或生成式汇编通常更可靠，但也要确认没有意外的循环控制、地址计算和保存恢复代码进入测量区间。

第二步是保证线程不迁移。把测试线程固定到一个逻辑处理器，记录它属于哪颗物理核、SMT sibling 是否空闲，并确认异构系统没有把线程迁到另一类核心。多核测试还要保存逻辑编号到物理核、簇、CCD、NUMA 节点的映射；操作系统编号通常不等于芯片平面图顺序。

第三步是校准计时器。x86 的时间戳计数器、Arm Generic Timer、RISC-V `cycle`/`time` 和操作系统单调时钟的语义并不相同。读取前后要使用适合该 ISA 的序列化方式，单独测量空计时开销，并确认计数器是否随核心频率改变。若最后报告纳秒，要同时保存实际频率；若报告 cycle，也要说明它是核心周期、参考周期还是软件推算值。

第四步是控制存储状态。数据与代码要显式对齐；测试 Cache 容量时要说明预取器是否开启；测试 TLB 时要固定页大小并预先触页；测试 DRAM 时要确认 NUMA 分配和内存控制器位置。随机指针环应先完成构造和预热，再开始计时，避免把缺页、分配器和随机数生成时间算进硬件延迟。

最后，不要只保存平均数。至少保留原始样本、中位数、较低分位和较高分位，并随机化参数扫描顺序。若容量从小到大单向扫描，温升、Boost 下降和预测器训练可能伪装成一条漂亮的容量曲线。

PMU 也需要校准。优先把相关事件放进同一个 event group，检查 `time_enabled/time_running`，避免事件复用比例不同破坏相除关系；同时确认事件发生在投机、执行、退休还是 Cache fill 侧。AMD 的 Demand Refill、Intel 的退休数据源事件和软件观测到的字节数可能描述不同生命周期，名字相似并不代表能够直接横比。中断采样还会有 skid，而极短微基准更适合直接计数并扩大迭代次数。

## 四、五种基本实验结构

绝大多数处理器微基准，都可以看成下面五种结构的组合。

### 1. 依赖链：测单次延迟

让下一次操作必须等待上一次结果，例如随机指针追逐：

```text
p = *p
p = *p
p = *p
...
```

同一时刻只能有一个有效请求，平均每步周期接近 Load-to-use 延迟。整数加法、乘法、FMA、寄存器搬运、Cache 和 TLB 延迟都能用类似方法测试。关键是依赖必须真实存在，循环开销要被展开或单独扣除。

### 2. 多条独立链：测稳态吞吐

把同一种操作分散到多个互不依赖的寄存器或地址流中，让流水线有足够并行工作。依赖链上的 FMA 可能表现为 4 cycle latency；六条独立 FMA 链却可能让硬件每周期接收多条新操作。延迟回答“一个结果多久回来”，吞吐回答“稳定状态每周期能做多少”，两者不能互换。

### 3. 参数扫描：寻找容量台阶

逐步增加静态分支数、调用深度、在途指令数、页面数、工作集或并发 miss 数。曲线在某个范围突然升高，常意味着快路径容量、相联度或下一级层次被触发。先用 1、2、4、8……做粗扫，再在台阶附近逐项细扫，比一开始遍历所有点更高效。

### 4. 混合与干扰：寻找共享资源

单独跑 A、单独跑 B，再把 A/B 按不同比例混合。若两者吞吐互不影响，它们可能使用不同端口；若混合后总吞吐受同一上限约束，它们可能共享执行单元、寄存器端口、Cache bank 或互连链路。这里得到的是“资源竞争关系”，不是物理框图的唯一解。

### 5. 二维或多维矩阵：寻找边界条件与拓扑

改变 Load/Store 的大小和相对偏移，可以得到 Store Forwarding 矩阵；改变发送核和接收核，可以得到核间延迟矩阵；改变工作集和独立链数量，可以同时观察容量与并行性。矩阵比单条曲线更容易暴露周期性、分区和异常慢路，也更需要谨慎解释坐标与单位。

## 五、前端怎么测：方向、目标、返回与取指是四件事

### 分支方向：测的是可学习模式，不是直接读取历史寄存器

方向预测测试可以让一个或多个静态条件分支按预先生成的 Taken/Not-Taken 序列运行，并改变模式周期与静态分支数量。可预测周期序列和随机序列的时间差，能显示预测器何时失去学习能力。

![图 1：P550 的分支模式长度与静态分支数量扫描](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_microarchitecture_measurement_methodology_wechat_article_zh/b0b7cf49a1543e58_01_branch_pattern_sweep.jpg)

*图 1：P550 测试同时扫描随机模式长度和参与测试的静态分支数量，高度表示可预测模式与随机模式的时间差。少量分支时可以学习较长模式，分支增多后边界缩短。曲面同时受到有效历史、表容量、索引混叠和训练策略影响，不能据此宣布预测器就是 gshare、TAGE 或某个确定历史长度。*

要提高解释力，可以保持总动态分支数不变，只改变静态 PC 数；保持静态 PC 不变，只改变模式周期；再分别测试全局相关、局部重复和 path-dependent 模式。如果几组结果都指向同一边界，才能逐步区分历史能力与表项混叠。

### BTB：用始终 Taken 的分支链测目标供给

分支目标缓冲区（Branch Target Buffer，BTB）关注的不是“跳不跳”，而是 Taken 后能否及时给出目标。最常见的测试是生成一串方向固定、目标固定的直接跳转，扫描分支数和分支间距，记录每个 Taken branch 的周期。

![图 2：P550 的 Taken 分支目标供给台阶](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_microarchitecture_measurement_methodology_wechat_article_zh/cedb89d1bc152a1c_02_btb_capacity_latency.png)

*图 2：P550 在约 32 个分支以内接近 1 cycle/branch，随后多数区间落到约 3 cycle/branch，更大代码工作集又出现新台阶。约 32 项快速 BTB 是与曲线相符的解释，但代码尺寸、分支间距、I-Cache 和索引别名也参与结果，因此它仍是微基准反推。*

好的 BTB 测试必须同时扫描分支间距。固定分支数而增大间距，会让代码工作集越过 L1I；固定代码大小而增大分支数，则会改变目标密度。两条轴可以帮助区分 BTB miss 和取指 Cache miss。对间接分支还要改变同一 PC 的目标数量，直接 BTB 的单目标测试不能代表 `switch`、虚函数和 JIT 跳转。

### RAS：递归深度给出返回快路的可见容量

返回地址栈（Return Address Stack，RAS）可以用逐层嵌套的真实 `call/ret` 测试。必须禁止内联和尾调用优化，并从反汇编确认编译器确实生成了调用与返回。随着嵌套深度增加，延迟台阶通常对应 RAS 溢出。

![图 3：P550 与 Cortex-A75 的返回地址栈深度测试](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_microarchitecture_measurement_methodology_wechat_article_zh/edcb3fa0e7c079a6_03_ras_depth.png)

*图 3：P550 在深度从 16 增至 17 时由约 2.3 ns 跳到接近 10 ns，支持约 16 项 RAS 的判断；A75 到约 42 层后才缓慢上升。曲线形状还包含溢出后的恢复策略，A75 的 2 GHz 频率也进入纳秒结果，因此这不是只比较容量的同平台实验。*

RAS 的容量和溢出行为要分开报告。两颗核心即使都有 16 项，也可能分别采取环形覆盖、回退 BTB、从退休调用栈重建或其他策略，超出一项后的惩罚会完全不同。异常、上下文切换、`longjmp` 和不配对 call/ret 还可以专门测试恢复健壮性。

### 取指与译码：先分清字节、指令和微操作

直线代码或低开销循环可以扫描代码工作集、指令长度、对齐和跨 Cache line 情况。x86 还要区分解码器和微操作缓存（Micro-op Cache），RISC-V 要考虑 16/32 位混合指令，Arm 则要注意固定长度指令与取指块边界。

![图 4：P550 与 Cortex-A75 的指令取数带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_microarchitecture_measurement_methodology_wechat_article_zh/d909948c0f414631_04_fetch_bandwidth.png)

*图 4：P550 在 32 KB L1I 范围内约为 12 B/cycle，越过后出现约 8 B/cycle、4 B/cycle 和更低台阶。这个结果测的是特定代码布局下的字节供给，不等于应用 IPC；跨 SoC 对照还混入 L2/L3 拓扑与频率。*

误预测代价也不应直接拿流水线级数代替。更可靠的方法是先训练分支，再以可控频率翻转结果，比较正确预测和错误预测的差值，并分别控制目标是否在 BTB、正确路径代码是否在 L1I。测得的是“解析、重定向和重新填充”的合成代价，而不是一条固定常数。

### 体系结构视角：前端的产物是连续的正确指令流

方向预测、BTB、RAS、I-TLB、I-Cache、对齐和译码是串联关系。方向猜对而目标来晚，前端照样产生空泡；取到足够字节却遇到译码边界，也不能达到指令峰值。分析时应同时看方向 MPKI、目标 miss、返回错误、取指层次和重定向周期，而不是把所有前端损失都归给“分支预测不准”。

## 六、后端怎么测：一个容量台阶往往同时撞到多个资源

### 先把延迟、吞吐和端口可达性分开

每类整数、浮点和向量指令先做依赖链，再做足够多的独立链。若 A 与 B 单独都能每周期一条，混合后仍只有每周期一条，它们很可能竞争某个资源；若混合后接近每周期两条，则更可能存在独立管线。再加入不同源/目的寄存器、不同操作数位置和不同数据宽度，可以寻找寄存器读端口、回写端口和特殊执行路径。

这种测试只能建立“兼容端口集合”。相同延迟不证明复用同一物理单元，互相干扰也可能来自调度器、寄存器文件或回写网络。需要多组指令交叉构成约束，再选择最简单、能解释全部现象的模型。

重命名和退休宽度也可用长串、随时就绪的简单操作探测，但必须先证明前端和执行端不会更早限流，并同时观察指令数与微操作数。宏融合、微融合、Move Elimination 和零惯用法会让“每周期退休几条指令”与“每周期处理几个微操作”不同；短时 burst 还可能借助队列超过稳态平均值。因而更准确的结论通常是某类指令组合的持续分配或退休吞吐，而不是脱离操作类型的单一宽度。

### ROB 与物理寄存器：用最老阻塞项冻结退休

反推重排序缓冲区（Reorder Buffer，ROB）的经典思路，是让程序最老处存在一个长时间未完成、又不能退休的操作，在它后面放入 `N` 个年轻填充操作，再观察后续标记操作何时不能继续进入窗口。扫过 `N`，延迟或停顿在资源满处出现台阶。

![图 5：P550 与 Cortex-A75 的可见乱序资源](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_microarchitecture_measurement_methodology_wechat_article_zh/3a6c809295d8a392_05_reorder_capacity.jpg)

*图 5：P550 微基准反推出约 96 项可见 ROB、95+32 个整数物理寄存器、87+32 个 FP 寄存器、20 项 Load Queue 和 16 项 Store Queue；A75 的对应可见值约为 73、69+32、57+32、68 和 14。A75 总览图曾把 Load Buffer 写成 69，这张表写 68，差异应保留。所有数字都依赖特定阻塞构造，不是官方阵列披露。*

填充操作决定先撞到什么资源。无目的寄存器的操作更接近 ROB 或前端上限；整数写入还消耗整数物理寄存器；FP/向量写入消耗另一套寄存器；Load 和 Store 又消耗 LQ/SQ、地址生成与存储系统槽位。比较多种填充序列，才能把一个总台阶拆成资源向量。

阻塞项本身也必须验证。Cortex-A73 的测试就是反例：常规未完成 Load 没有暴露传统 ROB 上限，加入尚未解析的分支后才出现新的容量边界。外部现象支持某种特殊退休处理，但没有 RTL 时不能直接命名其内部算法。一个在处理器 A 上有效的“ROB 探针”，换到处理器 B 上可能只是在测 Load Queue 或异常跟踪。

### 调度器：既要看总容量，也要看分区碎片

要让一批操作长期留在调度器中，可以让它们依赖同一个迟到结果；再用独立操作探测其他队列或端口是否仍能接收。改变两类操作的排列顺序和比例，可以判断分配器是否固定轮转、是否根据空闲度选择，以及一个分区满后能否溢出到其他兼容分区。

![图 6：Cortex-X925 的整数分区调度器容量测试](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_microarchitecture_measurement_methodology_wechat_article_zh/cab2e3b34a6a7ab2_06_scheduler_partitioning.png)

*图 6：X925 的四个整数调度器各约 28 项。只放依赖加法时，拐点接近四队列总量；依赖与独立加法交错后，大约一半依赖操作就可能使被指定队列先满。结果支持固定或轮转分配的解释，但不能独自证明 RTL 的选择逻辑。*

现代核心的“窗口大小”从来不是一个数字。ROB 决定程序顺序视野，物理寄存器保存投机结果，调度器保存等待执行的操作，LQ/SQ 维护内存顺序，分支 checkpoint 决定可恢复的推测点。应用会先撞到与自身指令组合最相关的那一项。

### 体系结构视角：拐点测到的是可见边界，不是芯片铭牌

容量台阶可能低于物理项数，因为硬件预留了条目、SMT 做了分区、宏指令展开成多个微操作，或哈希冲突提前出现；也可能因为融合、Move Elimination、零惯用法和特殊退休行为而看起来更大。报告时应写“在这组构造下可见约 N 项”，并保留测试操作类型。

如果 PMU 提供 ROB full、rename stall、scheduler full、LQ/SQ full 或 ready-but-not-issued 等事件，应让台阶与相应事件同时出现。若有 RTL，则沿 valid/ready、分配、释放、flush 与恢复信号确认条目生命周期；不能只凭模块名或信号名把外部曲线硬套进实现。

## 七、Load/Store 怎么测：地址生成、依赖检查与转发要逐层拆开

Load/Store 单元（LSU）至少包含地址生成、地址翻译、Cache 访问、内存依赖检查、Store 数据合并和退休可见性。一个“Load 延迟”数字往往只覆盖其中某条快路。

地址生成单元（Address Generation Unit，AGU）的吞吐可以用命中 L1D、地址彼此独立的 Load-only、Store-only 和混合序列测试。若两类单独都快，混合却没有增加总请求率，可能共享 AGU 或其他前端资源；若混合更快，则可能存在专用或组合端口。地址计算复杂度也要变化，x86 的简单基址、基址加索引和 Store Data 可能走不同端口。

LQ/SQ 容量可以沿用“冻结退休 + 扫描操作数”的办法，但 Store Queue、Store Buffer 和写合并结构的名字在不同厂商资料中并不等价。Load 还可能因 TLB miss、Cache miss 或内存依赖预测而重放。只有让地址命中层级、依赖关系和退休状态受控，才知道台阶属于哪一层。

### Store Forwarding：用大小与偏移矩阵找快路

先执行较老 Store，再让较年轻 Load 读取相同或部分重叠地址，扫描两者大小、相对偏移、是否跨自然边界、Cache line 和页面。没有重叠的组合给出基线，完全覆盖通常走快速转发，部分覆盖、未知地址或跨边界可能等待 Store 提交、重放或进入软件慢路。

![图 7：P550 的 Store-to-Load 偏移矩阵](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_microarchitecture_measurement_methodology_wechat_article_zh/1115a05077d996f4_07_store_forwarding_matrix.jpg)

*图 7：列为 32-bit Load Offset 0～63，行为 64-bit Store Offset 0～63。P550 只有同址且自然对齐时接近快路，单侧未对齐出现约 741/1062 周期，两侧未对齐约 1800 周期。测试文字对 Load/Store 的 1062/741 归属与按图轴读取的方向相反，无法判断是轴标还是文字有误；共同结论只能收窄为两种单侧慢路和一条叠加慢路。*

上千周期和每次约 505 条额外执行指令强烈支持异常后由软件模拟的解释，却仍不是 RTL 证明。验证时应同时记录 `cycle`、`instret`、trap 次数、异常原因和 `tval`，再检查内核处理路径。跨页 Store 还涉及执行环境承诺的非原子或全有/全无语义，不能只测时间而忽略架构可见副作用。

内存依赖预测则需要另一类实验：让较老 Store 的地址晚就绪，让较年轻 Load 的地址早就绪；分别构造真正别名、明确不别名和训练后突然翻转的序列。若核心允许 Load 越过未知 Store，预测错误时会 replay；若过于保守，则无别名序列也会等待。把重放次数、延迟和吞吐一起看，才能判断问题在预测、比较器容量还是转发路径。

## 八、Cache 与 TLB 怎么测：台阶、相联度、并行性缺一不可

### Cache 与 TLB 延迟：随机访问把层次逐级展开

构造一个覆盖指定工作集的随机置换，每个节点只保存下一个节点地址，依赖链一次走一项。扫描工作集后，L1、L2、L3 和 DRAM 会形成延迟台阶。随机化访问顺序是为了减少流式和步长预取，但节点大小、页布局、Cache set 分布和大页仍会改变结果。

![图 8：P550 与 Cortex-A75 的 TLB 容量和层次](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_microarchitecture_measurement_methodology_wechat_article_zh/0ae98195bd6481d5_08_tlb_capacity.png)

*图 8：P550 测试呈现约 32 项 DTLB、32 项 ITLB 和 512 项/4 路统一 L2 TLB，L2 TLB 命中比 L1 多约 9 周期。总览图中的“约 256 项？”与详细测试的 512 项不一致，因此只能保留冲突。A75 的页面组容量和层次又不同，跨 ISA 比较必须同时说明页大小。*

TLB 测试通常每页只访问一个 Cache line，并随机化页面顺序，再扫描页面数量。以 4 KB 页为例，32 项只能覆盖约 128 KB，512 项约覆盖 2 MB；使用 2 MB 大页后 reach 会放大 512 倍。为区分 Cache 与翻译，应做普通页/大页对照、控制物理数据工作集，并观察 DTLB miss、二级 TLB hit 和 page walk。若只看总延迟，Cache 台阶很容易冒充 TLB 台阶。

![图 9：P550 的 Cache 与内存延迟台阶](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_microarchitecture_measurement_methodology_wechat_article_zh/5d3471e25c37bd6e_09_cache_latency_stairs.png)

*图 9：使用 2 MB 页时，P550 的随机访问台阶约为 L1D 3.01 cycle、L2 13.06 cycle、L3 38.11 cycle；对照 A73 的 1 MB L2 约 24.94 cycle。大页减少了 TLB 干扰，但两套 SoC、频率和末级 Cache 拓扑不同，不能把曲线差异全部归因于 CPU 核。*

相联度不能只靠总工作集测。更有针对性的办法是选取映射到同一 set 的地址，逐渐增加竞争 line 数量；第 `ways+1` 个地址若引发稳定 miss，才支持某种相联度判断。物理索引 Cache 需要知道物理地址或使用大页控制低位，否则虚拟地址看似同 set，实际可能没有冲突。Slice hash、skewed indexing 和替换策略也会让简单模型失效。

### 带宽与并发 miss：用独立流和 Little’s Law 联立

Cache/内存带宽要用多条独立地址流，逐步增加未完成请求数，直到吞吐不再增长。Load、Store、Read-Modify-Write、Non-temporal Store 和复制必须分别测，因为 Write Allocate 会产生 Read for Ownership（RFO），读写切换还有总线 turnaround。报告“有效字节”还是“总线事务字节”必须明确。

并发 miss 容量可用 Little’s Law 做外部估算：

```text
平均在途请求数 ≈ 带宽 × 平均延迟 ÷ 每个请求字节数
```

![图 10：用 Little’s Law 估算 Zen 4 的 L2 miss 跟踪深度](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_microarchitecture_measurement_methodology_wechat_article_zh/5c2d685c656704d6_10_l2_miss_queue_littles_law.jpg)

*图 10：按 64 B/请求计算，Zen 4 由 57.29 GB/s 与 78.72 ns 得到约 70.45 项，Zen 3 约 49.72，Zen 2 约 36.46。4 KB 页测试还可能混入 Page Walk 和预取请求，所以这些数字只能说明“可维持的并发活动更深”，不能直接写成物理 L2 miss 队列项数。*

更完整的测试要同时扫描独立链数和工作集。单链只测依赖延迟，多链从线性增长进入饱和的拐点反映内存级并行（Memory-Level Parallelism，MLP）上限；此时限制可能是 LQ、MSHR、fill buffer、页表遍历槽位、互连 credit 或 DRAM bank，而不一定是一个叫“miss queue”的阵列。

### 体系结构视角：Cache、TLB 与 MLP 是同一条等待链

Cache 容量降低 miss 频率，命中延迟决定单条依赖链，带宽决定稳态数据流，并发槽位决定核心能否把长延迟重叠起来。TLB miss 又可能在真正访问 Cache 前插入多级查找和 Page Walk。只说“内存慢”没有诊断价值；至少要把 MPKI、平均延迟、Outstanding Miss、B/cycle、页大小和队列满周期放在一起。

## 九、多核怎么测：核间矩阵测的是一致性路径，不是几何距离

让两个固定核心轮流修改同一 Cache line，可以强制所有权在两核之间转移。遍历所有核心对，矩阵中的块状、条纹和远端区域往往对应 SMT sibling、共享 L2/L3 簇、CCD/Tile、Socket 和 NUMA 层次。改变被测地址在页内的偏移，还可能改变 Home Slice 或 Directory 归属。

![图 11：Sapphire Rapids 的核间一致性延迟矩阵](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_microarchitecture_measurement_methodology_wechat_article_zh/8a4cd2caaaaa4b84_11_core_to_core_latency_matrix.png)

*图 11：原测试用 Atomic Compare-and-exchange 反复争夺同一 Cache line。Sapphire Rapids 的矩阵可见 Tile、Mesh 距离和地址 Home 共同影响；颜色不是裸导线传播时间。线程编号、Cache line 归属、原子操作延迟、Snoop/Directory、队列与同步循环都进入结果。*

公开 CnC Core Coherency 测试正是这种结构。默认路径使用原子比较交换，两个线程每轮完成两次交接，因此最终数值应按程序的归一化定义理解，不能未经确认就称作“单程核到核延迟”。计时还包含线程创建与回收，虽然一千万次迭代会显著摊薄固定成本，原始迭代数仍应随结果保存。

核间测试最好分成三组：同一物理核的 SMT sibling、同簇不同核、跨簇或跨 Socket；再分别改变共享行位置、是否使用原子读改写、是否并行跑其他流量。只有延迟随 probe/retry、互连排队或远端 NUMA 事件共同上升，才有理由把瓶颈进一步指向一致性路径。

真实应用还需要测试扩展性。单线程、每簇一线程、每核一线程、SMT 全开分别测吞吐；线程和内存采用 first-touch 或显式 NUMA 绑定；再加入 false sharing、锁争用和无共享基线。Atomic Ping-pong 很适合暴露最坏同步路径，却不能直接预测渲染、编译、数据库或 HPC 的总性能。

## 十、怎样从真实 Benchmark 回到微结构根因

微基准建立局部模型，Benchmark 检查这些局部机制在真实指令混合中是否重要。先看完成时间或吞吐，再看退休指令数、IPC 和平均频率；然后用 Top-down、分支、Cache/TLB 和带宽计数器缩小范围，最后回到定向微基准验证。

作为具体样例，Chips and Cheese 的第一版 SPEC CPU2017 方法统一使用 GCC 14.2.0、`-O3 -fomit-frame-pointer -mcpu=native`，只跑一份 Rate；除无法避免虚拟化的云平台外，其余使用 Bare-metal Linux。结果没有提交 SPEC 审核，因此明确标为 Estimated。即使做了这些统一，`-mcpu=native` 在 AArch64 与 x86-64 上的含义、内存频率和 Boost 状态仍可能不同。这正说明“相同命令行”只是可比性的起点，不是终点。

![图 12：SPEC CPU2017 中两个低 IPC 子项的 Top-down 分解](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_microarchitecture_measurement_methodology_wechat_article_zh/8dbe050d1cea2c7d_12_spec_topdown.png)

*图 12：Zen 5 上，`520.omnetpp` 主要受 Backend Memory Latency 限制；`505.mcf` 则以前端延迟最突出，同时混有其他损失。两者 IPC 都低，根因却不同。Top-down 给出调查入口，不自动给出最终因果。*

`505.mcf` 是一个很好的完整案例。它的分支密度约为 22.5%，方向错误按全部指令归一化后代价很高；代码本身大体能放进微操作缓存，所以前端损失不能简单归为 L1I 容量。进一步的预测器延迟、BTB、Return、间接分支与错误路径事件，才把调查方向收窄到控制流交付。

`520.omnetpp` 的低 IPC 则更像数据侧等待。`549.fotonik3d` 又展示了“Memory-bound”内部的差异：单核读约 21 GB/s、写约 7.23 GB/s，已经接近该平台单核可达到的流量范围，延迟损失中包含排队靠近带宽墙的效果。一次无法并行的 DRAM miss 和许多请求拥塞控制器都叫 Backend Memory，优化方向却完全不同。

跨 ISA 对照还要回到动态工作量。Cortex-X925 在 `549.fotonik3d` 中退休 IPC 约为 Zen 5 的 1.7 倍，却执行约 1.67 倍指令，并承受频率差，最终成绩仍落后。高 IPC 只说明每周期退休得多，不说明完成同一工作用了更少周期。

SPEC、Geekbench、Cinebench、7-Zip 或游戏都必须记录版本、输入、编译器、完整参数、线程/副本数、频率、内存和运行环境。Estimated SPEC、不同编译器、跨操作系统或云实例上的结果，可以用于结构趋势分析，不能包装成严格产品排名。

### 体系结构视角：Benchmark 是终点，也是下一轮微基准的起点

好的分析不是把 Top-down 饼图复述一遍，而是提出可证伪问题。例如：如果 `mcf` 真被目标供给拖慢，那么增大静态分支工作集时 BTB 事件是否同步增加？如果 `omnetpp` 真被串行 DRAM miss 限制，那么提高并发 Load 数是否无效，而降低内存延迟是否有效？真实负载负责暴露重要问题，微基准负责把问题拆到可以验证的机制。

## 十一、频率、功耗和温度：不控制它们，微结构数字也会漂移

现代 CPU 的工作频率不是规格表中的固定常数。短任务可能在升到最高 Boost 前已经结束，长任务又可能因温度、封装功耗或电流限制降频。测试延迟用 cycle 表示，可以减少频率差对数值的直接影响；测试用户体验和吞吐仍必须看纳秒与实际频率。

![图 13：多款 CPU 从空闲到最高 Boost 的时间](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_microarchitecture_measurement_methodology_wechat_article_zh/8f22081acb5e5b12_13_frequency_ramp.png)

*图 13：不同处理器到最高频率的时间跨度很大，但“最早到顶”不等于交互响应最好。有些核心先快速到达足够高的中间频率，再缓慢冲顶；短任务只会经历前半段。Skylake Speed Shift 测得约 5.62 ms 到顶，部分 Zen 2 平台约十几毫秒，移动 SoC 在电池策略下可能更慢。*

测频率响应可以在短时间窗口内反复执行已知 latency 的依赖操作，再用参考计时器估算有效核心周期；但线程迁移、流水线停顿、操作 latency 假设和计时粒度都会带来误差。需要把接电状态、电源计划、温度、空闲起始时间和采样窗口一同保存。

能效也要先定义测量边界。核心功耗、封装功耗、内存功耗和墙上功耗不是同一个量；不同厂商 PMU/RAPL 事件也未必同口径。对固定任务，`能量 = 平均功率 × 完成时间` 往往比“峰值瓦数”更有意义。低频降低动态功耗，却延长固定静态功耗的持续时间；最高性能点通常也不是最佳性能功耗比点。

## 十二、把容量反推做成一套可复用流程

如果只记住一段操作方法，可以按下面的闭环执行。

1. **定义唯一问题。** 例如“整数物理寄存器的可见分配上限”，不要写成笼统的“测后端大小”。
2. **设计快、慢两条路径。** 小 `N` 时应稳定命中快路，大 `N` 时应有明确的资源满机制；若预期现象本身不清楚，先不要扫参数。
3. **建立空基线。** 测计时、循环、分支和阻塞项本身的成本，确认结果随迭代数线性缩放。
4. **粗扫再细扫。** 先按指数增加 `N` 找到变化区间，再在台阶前后逐项扫描；参数顺序随机化并重复多轮。
5. **更换填充操作。** NOP、整数写、FP 写、Load、Store 和 Branch 消耗的资源不同。只有多组曲线才能分离 ROB、PRF、调度器、LQ/SQ 与 checkpoint。
6. **改变排列而不改变数量。** 交错、先 A 后 B、先 B 后 A 可以暴露固定分区、轮转分配和资源碎片。
7. **用 PMU 或第二种微基准交叉验证。** 台阶应与对应 full/stall/replay 事件或另一种构造同时出现。
8. **主动寻找反例。** 改变对齐、页大小、代码布局、SMT、频率和预取器；若结论随无关变量消失，原模型就不充分。
9. **只报告证据能支持的强度。** 写“约 N 项可见容量”“支持两级结构的解释”，而不是“硬件就是 N 项”。

不同填充操作通常形成下面的资源叠加关系：

| 填充操作 | 可能额外消耗的关键资源 | 典型混淆 |
| --- | --- | --- |
| NOP/简单无目的操作 | ROB、前端槽位 | 可能被消除、融合或特殊处理 |
| 整数寄存器写 | 整数 PRF、整数调度器、ROB | Move Elimination、零惯用法 |
| FP/向量寄存器写 | FP/向量 PRF、调度器、ROB | 向量宽度与寄存器切片 |
| Load | LQ、AGU、TLB、Cache miss 槽位、ROB | 预取、重放、特殊退休 |
| Store | SQ/Store Buffer、AGU、写合并、ROB | Store drain 与所有权获取 |
| 未解析 Branch | checkpoint、分支队列、ROB | 预测器训练与恢复路径 |

容量曲线可能有多个台阶。第一个台阶未必是目标资源，最后一个台阶也未必是总容量。最稳妥的解释，是为每个候选模型写出它还应预测哪些现象，再设计最便宜的一组实验区分它们。

## 十三、怎样搭建自己的处理器测试工具箱

可以沿 CnC-Tools 的思路，把工具拆成六层，而不是写一个越来越难维护的巨大程序。

```text
platform/   核心枚举、绑核、NUMA、页分配、权限检查
timing/     架构计数器、单调时钟、序列化、开销校准
kernels/    依赖链、独立链、分支生成器、容量填充、矩阵测试
pmu/        事件配置、原始计数、复用比例、厂商口径说明
collect/    元数据、原始 CSV/JSON、日志、反汇编与环境快照
analysis/   统计、变点检测、拟合、绘图和跨测试一致性检查
```

第一版不必覆盖所有 CPU。推荐按这个顺序扩展：

1. 计时器、绑核、频率读取和空循环校准；
2. 整数/FP 的 latency 与 throughput；
3. 随机指针追逐、Cache 工作集和单/多流带宽；
4. 页大小、TLB reach 和 Page Walk；
5. 条件分支、BTB、RAS 与取指工作集；
6. ROB/PRF/LQ/SQ 的多填充容量扫描；
7. 执行端口混合与分区调度器；
8. Store Forwarding、内存依赖与未对齐矩阵；
9. 核间一致性、NUMA、带宽扩展和 loaded latency；
10. SPEC、编译、压缩、媒体或真实业务与 PMU 联合分析。

每次运行都应生成不可变结果目录，包含 Git 提交、命令行、环境信息、反汇编、原始样本和图表输入。图不是原始数据，最终报告也不能替代原始日志。失败测试同样要保存：它可能证明计时器不适用、阻塞项没有冻结退休，或某种指令没有占用预期端口。

## 十四、最常见的十种误判

1. 用一次运行的平均值代表稳定性能；
2. 把纳秒差异全部归因于微架构，忽略频率；
3. 把 cycle 当核心周期，却实际读取固定参考计数器；
4. 从一个容量台阶直接宣布 BTB、ROB 或 Scheduler 的物理深度；
5. 只看依赖链，把 latency 当 throughput；
6. 只看峰值带宽，忽略并发请求、协议流量和 loaded latency；
7. 把 SoC 的 L3、NoC、内存控制器和 DRAM 表现全部归给 CPU IP；
8. 跨 ISA 比分数时不保存编译器、参数、指令数和库；
9. 忽略“没有测到”的负面结果，以及图轴、正文和不同测试之间的冲突；
10. 先决定答案，再不断调整参数寻找支持曲线。

真正可靠的顺序始终是：先固定现场，再提出可证伪假设；先做静态检查和短定向测试，再投入大规模运行；结果出来后同时核对功能、时间、计数器和机制链条。若实验失败，下一步是解释失败发生在哪一层，而不是立刻重跑。

## 十五、体系结构视角：最终要掌握的是建模能力

第一，**性能不是一个数字，而是一条因果链**。工作量、频率、前端供给、乱序窗口、执行端口、存储层次和多核互连共同决定时间。总分只告诉你发生了什么，拆分指标才开始回答为什么。

第二，**容量是一组相互约束的向量**。ROB 很大，不代表物理寄存器、Scheduler、LQ、MSHR 和 checkpoint 同样大；最先耗尽的资源决定真实窗口。把所有缓冲深度简单相加，没有微结构意义。

第三，**延迟、吞吐和并行性必须联立**。三周期 L1 很快，但只有一条 Load 端口时流量仍有限；两百纳秒 DRAM 很慢，但几十个并发 miss 可以维持可观带宽。任何一个维度都无法独立预测应用性能。

第四，**曲线是证据，不是结构图**。台阶、斜率、条纹和矩阵块状可以排除一批模型，却通常不能唯一确定索引、仲裁、恢复或物理阵列。最专业的表述不是假装确定，而是给出当前最简单解释和仍未区分的候选方案。

第五，**慢路和恢复路径同样属于架构质量**。RAS 溢出、部分重叠转发、跨页访问、分支 flush、TLB miss、异常与一致性冲突不常触发，却可能造成数量级代价或正确性风险。平均吞吐不能替代边界测试。

第六，**好模型必须能预测下一张图**。如果一个解释只能复述已经看到的曲线，它还不是完整模型；如果它能预言更换指令、页大小、地址偏移、核心位置或并发度后结果怎样变化，就值得继续验证。处理器评测的最高价值，不是给一颗 CPU 排名，而是建立这种可以不断被证据修正的理解方式。

## 参考资料

1. George Cozma，*Chips and Cheese's Microbenchmark Framework*：https://chipsandcheese.com/p/chips-and-cheeses-microbenchmark
2. Chips and Cheese，CnC-Tools：https://github.com/ChipsandCheese/CnC-Tools
3. Chester Lam，*Inside SiFive's P550 Microarchitecture*：https://chipsandcheese.com/p/inside-sifives-p550-microarchitecture
4. Chester Lam，*Arm's Cortex X925: Reaching Desktop Performance*：https://chipsandcheese.com/p/arms-cortex-x925-reaching-desktop
5. Chester Lam，*AMD's Zen 4, Part 2: Memory Subsystem and Conclusion*：https://chipsandcheese.com/p/amds-zen-4-part-2-memory-subsystem-and-conclusion
6. Chester Lam，*Core to Core Latency Data on Large Systems*：https://chipsandcheese.com/p/core-to-core-latency-data-on-large-systems
7. Chester Lam，*Running SPEC CPU2017 at Chips and Cheese?*：https://chipsandcheese.com/p/running-spec-cpu2017-at-chips-and-cheese
8. Chester Lam，*How Quickly do CPUs Change Clock Speeds?*：https://chipsandcheese.com/p/how-quickly-do-cpus-change-clock-speeds
9. Chester Lam，*Cortex A73's Not-So-Infinite Reordering Capacity*：https://chipsandcheese.com/p/cortex-a73s-not-so-infinite-reordering-capacity
10. Henry Wong，*Store-to-Load Forwarding and Memory Disambiguation in x86 Processors*：https://blog.stuffedcow.net/2014/01/x86-memory-disambiguation/
