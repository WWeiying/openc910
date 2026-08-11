---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "sifive_p550_wechat_article_zh"
---

> **原文信息**
>
> - 原文：*Inside SiFive’s P550 Microarchitecture*
> - 原作者：Chester Lam
> - 首发平台：Chips and Cheese
> - 原文日期：2025 年 1 月 26 日
> - 原文链接：https://chipsandcheese.com/p/inside-sifives-p550-microarchitecture

RISC-V 是一套相对年轻、开放的指令集。它已经在微控制器、学术研究和各类片上控制器中站稳脚跟：原文举例说，Nvidia 用 RISC-V 替换了 GPU 内部的 Falcon 微控制器，Berkeley BOOM 等大学项目也以 RISC-V 为基础。但从这些场景走向对单线程性能、系统软件和产品成熟度要求更高的市场，难度会陡然增加。SiFive 在这个过程中承担的角色，近似于 Arm 在 Arm 生态中的角色：提供可授权的处理器 IP，由芯片厂商完成 SoC、内存系统和整机实现。

P550 正是 SiFive 向高性能方向迈进的一步。SiFive 曾以“相对可比的 Cortex-A75，在不到一半面积内提供高 30% 的性能”描述其目标；但这类 PPA 宣称离不开工艺、电压、频率、Cache 配置和工作负载。原作者并没有复现这组受控条件，而是从 SiFive Premier P550 Dev Board 出发，逐层探测 P550 的前端、乱序后端和存储系统。

![图 1：SiFive Premier P550 开发板](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p550_wechat_article_zh/0fd616db4839f8f2_01_p550_premier_dev_board.jpg)

*图 1：原图注译文为“数据表中的 P550 开发板渲染图”。本文测试的是板上 Eswin EIC7700X SoC 中的 P550 实现，而不是抽象的 P550 IP；核心之外的 L3、片上网络、DDR 控制器和板级配置都会进入测试结果。*

## 测试平台与结论边界

原作者使用的平台为 SiFive Premier P550 Dev Board：

- SoC：Eswin EIC7700X，台积电 12 nm FFC；
- CPU：4 个 SiFive P550 核心，频率 1.4 GHz；
- 共享 Cache：4 MB L3；
- 内存：16 GB LPDDR5-6400；
- 主要对照：Pixel 3a 中的 Qualcomm Snapdragon 670，包含 2 个 2 GHz Cortex-A75；
- 特殊对照：图 15 的 Cache 延迟使用 Amlogic S922X 中的 Cortex-A73，因为作者无法在 Android 对照机上以相同方式使用大页；图 17 的四核带宽也使用该 A73 平台，但原文没有说明这项选择的原因。

原文首次把 SoC 写成 `EC7700X`，其余正文、图题和资料均写 `EIC7700X`。本文统一采用后者，同时明确保留首处拼写差异，不将其误认为另一款芯片。

原文没有披露操作系统与内核版本、编译器、优化参数、微基准完整源码、预热和重复次数、误差范围、线程绑核方式、频率策略及预取器状态。除图 17 明确为四线程/四核、图 21～22 明确为核间测试外，其他图的线程条件也没有逐项完整标注。因此，这批数据适合用来识别容量台阶和结构趋势，不足以构成统一软件栈、统一功耗条件下的产品性能排名。不同图中的 A73 与 A75 也不能合并成一个“Arm 对照平台”。

全文采用以下证据边界：

- **原文援引公开资料**：原作者从 SiFive 或 Eswin 数据表取得的信息；
- **作者实测**：Chester Lam 在上述具体平台得到的曲线、计数器和延迟；
- **作者推断**：根据容量拐点、吞吐台阶和公开框图反推的内部结构；
- **作者判断**：原作者对产品定位、成熟度和技术演进的评价；
- **未确定项**：测试不能唯一确定，或原文图文口径并不完全一致的内容。

本批材料不含 P550 RTL，因而本文不会把微基准反推写成 RTL 已确认的实现。

原网页 23 张正文图中，只有图 1、15、18 带正式英文图注；这三处在下文明确标出原图注译文。其余斜体中文图注是本文根据图内坐标、数值和相邻正文编写的读图说明，不作为 Chester Lam 的原始 caption 引用。

## 一、核心总览：面向面积与功耗约束的三宽乱序核

【原文援引公开资料】P550 是一颗三宽乱序执行核心，流水线为 13 级。乱序执行允许处理器在老指令等待数据时，从更年轻的指令中寻找可执行工作；在 Cache 和内存延迟远高于单个算术操作的现代系统里，这是通用高性能核心的基础能力。

P550 并非 SiFive 第一颗乱序核。更早的 U87 同样采用三宽乱序结构；P550 在其后多年推出，代表 SiFive 对这条路线的进一步工程化。

![图 2：原作者整理的 SiFive P550 微架构总览](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p550_wechat_article_zh/ce3ec772e22316bc_02_p550_microarchitecture_overview.png)

*图 2：原作者把公开信息与微基准反推汇总为一张框图：三宽译码、约 96 项重排序缓冲区、三条整数路径、独立 Load/Store AGU、两条 FP 路径，以及每核私有 L1/L2 和共享 4 MB L3。图中的问号与近似值必须保留；例如这里把 L2 TLB 标为“约 256 项？”，后文详细测试则给出 512 项，不能把本图当作 SiFive 官方模块图。*

作者整理出的主要容量包括：约 96 项重排序缓冲区（Reorder Buffer，ROB）、约 128 项整数寄存器文件、约 119 项浮点寄存器文件、20 项 Load Queue 和 16 项 Store Queue。前端为 32 KB、4 路组相联 L1 指令 Cache，后端连接 32 KB、4 路组相联 L1 数据 Cache 和 256 KB、8 路组相联私有 L2。

作者选择 Cortex-A75 作为主要参照，是因为两者同为三宽、面向功耗和面积效率的乱序核心。A75 是 Cortex-A73 的后继者；原文援引 AnandTech 的资料称其流水线为 11～13 级，而框图暗示最短分支误预测代价可能更接近 11 个周期。

![图 3：原作者整理的 Cortex-A75 微架构总览](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p550_wechat_article_zh/181c005b14692104_03_cortex_a75_microarchitecture_overview.png)

*图 3：Cortex-A75 对照图同样混合了资料与反推值。它展示三宽译码、约 73 项 ROB、两条通用 AGU、两条 FP/NEON 路径和 64 KB L1。图中将 BTB 画成约 48 项 L0 加 3072 项 L1，但原文后段又称 A75“似乎只有一个小型 BTB 层级”；这两种说法并不一致，本文保留不确定性。*

【作者判断】P550 与 A75 的乱序引擎都远小于当代 Intel、AMD 高性能大核。这样的取舍不是单纯“落后”，而是把面积和功耗预算放在目标市场真正需要的位置；问题在于各个相邻结构是否匹配，以及不常见慢路径是否足够成熟。

### 体系结构视角｜三宽描述的是一条端到端供给链

“三宽”不是应用一定能达到 3 IPC 的承诺。前端必须先预测正确的下一取指地址，从 I-Cache 取回足够字节并切分指令，译码和重命名要接收三条，调度器、寄存器读、执行端口、Load/Store 单元和退休端还要持续消化它们。任何一段长期低于三条，都会成为整条流水线的实际宽度。

缓冲结构只能吸收短时波动。前端空泡会逐渐饿死后端；ROB、物理寄存器、调度器或 Load/Store Queue 满，则会把反压一路传回取指。若按约 96 项 ROB 和三宽粗略换算，完全停止退休时最多只能容纳约 32 个周期的入口流量；这并不等于能隐藏任意 32 周期延迟，因为 20 项 Load Queue、单 Load AGU、未公开的未命中状态保持寄存器（Miss Status Holding Register，MSHR）等资源可能更早耗尽。

要验证真实瓶颈，应同时观察取指字节、译码、重命名、发射和退休吞吐，并区分前端无指令、ROB 满、调度器满、寄存器不足与 LSU 队列满。只看最终 IPC，无法判断流水线是“吃不饱”还是“排不出去”。

## 二、分支预测：方向正确，还要及时交付目标

【原文援引公开资料】原文称 P550 配有 9.1 KiB 分支历史表（Branch History Table，BHT），用历史行为帮助判断条件分支是 Taken 还是 Not Taken。

【作者实测】作者构造了不同静态分支数量、不同随机模式长度的条件分支序列。图中的高度轴是可预测模式与随机模式之间的时间差，作者把曲面的明显转折作为模式识别边界的经验信号。P550 在静态分支较少时能识别相当长的模式，但分支数量增加后，与 A75 的差距缩小。作者认为其模式识别能力符合定位，但仍明显低于当代高性能大核。

![图 4：P550 的分支模式识别曲面](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p550_wechat_article_zh/b0b7cf49a1543e58_04_p550_branch_pattern_recognition.jpg)

*图 4：横轴为随机 Taken/Not-Taken 模式长度，另一轴为参与测试的静态分支数，高度为可预测与随机模式的时间差。少量分支时，P550 到较长模式才出现明显转折；分支增多后的变化可能同时受容量与混叠影响，但本测试不能拆分成因，更不能唯一反推出 gshare、TAGE 或其他具体算法。*

![图 5：Cortex-A75 的分支模式识别曲面](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p550_wechat_article_zh/d1ef47320b6aee1c_05_cortex_a75_branch_pattern_recognition.jpg)

*图 5：同一类测试在 Cortex-A75 上的结果。与 P550 相比，A75 在少量分支下更早遇到长模式边界，但静态分支增多后差距缩小。这里比较的是两块不同 SoC、不同频率和 ISA 下的结构趋势，不是同平台预测准确率排名。*

方向只是第一个问题。即便已经判断分支会跳转，前端还必须及时得到目标地址。作者用始终 Taken 的分支链测试目标供给能力：P550 在大约 32 个分支以内可以保持每周期处理一个 Taken 分支；超过该范围、且代码仍位于 32 KB L1I 内时，吞吐降为约每 3 个周期一个 Taken 分支。

![图 6：P550 的 Taken 分支目标供给延迟](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p550_wechat_article_zh/cedb89d1bc152a1c_06_p550_taken_branch_latency.png)

*图 6：横轴为循环中的分支数，不同曲线改变分支间距。约 32 个分支以内延迟接近 1 cycle/branch，之后多数区间稳定在约 3 cycle/branch；更大代码工作集又出现新的台阶。作者据此提出“约 32 项快速 BTB”假说，但曲线还同时受代码尺寸、布局和 I-Cache 层级影响。*

【作者推断】作者认为 P550 可能只有约 32 项快速分支目标缓冲区（Branch Target Buffer，BTB），没有更大的解耦二级 BTB；miss 后，前端等待识别分支并计算 PC 相对目标。由约 3 周期台阶，他进一步推测 L1I 延迟为 3 周期。这是一套能解释曲线的假说，不是 RTL 确认。

![图 7：P550 与 Cortex-A75 的 Taken 分支延迟对照](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p550_wechat_article_zh/286af384fab92245_07_p550_a75_taken_branch_latency.png)

*图 7：在 16 B 分支间距下，P550 和 A75 都先经历约 32 项附近的延迟台阶；更大工作集中的曲线又受取指层级影响。原文据此称两者缺少现代高性能大核常见的大容量、解耦目标供给结构；但 A75 总览图又画出 3072 项 L1 BTB，精确层级仍属未确定项。*

函数返回是第三种目标问题。同一个 `ret` 指令会因调用者不同而回到不同地址，因此处理器通常用返回地址栈（Return Address Stack，RAS）追踪动态调用嵌套。

【作者实测与推断】P550 在调用深度超过 16 后出现陡峭延迟上升，支持 16 项 RAS 的判断。A75 的拐点约在 42 项，而且溢出后的增长更平缓。作者推测 A75 可能只错掉被挤出的返回项，而 P550 的溢出处理或恢复不够平滑，少量超深嵌套也可能引发连续 return 误预测。

![图 8：P550 与 Cortex-A75 的返回地址栈深度](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p550_wechat_article_zh/edcb3fa0e7c079a6_08_return_stack_depth.png)

*图 8：横轴为调用深度，纵轴为每组 call/return 的纳秒时间。P550 在深度从 16 增至 17 时从约 2.3 ns 跃升到接近 10 ns；A75 到约 42 项后才缓慢上升。A75 的 2 GHz 频率也进入纳秒结果；常见命中区两者绝对时间接近。P550 曲线约在深度 30 处停止，原文没有说明原因；曲线可能同时受容量与溢出恢复策略影响。*

### 体系结构视角｜预测器交付的是连续、正确的下一段指令流

方向预测回答“跳不跳”，BTB 回答“Taken 后去哪里”，RAS 专门处理“这次函数返回到哪里”。其中任何一项失败，都会让前端停止供给或沿错误路径工作。方向错判通常需要清空年轻指令、重定向取指，并恢复推测更新的全局历史、路径历史和 RAS 状态；若恢复不完整，一次错误还可能诱发后续级联误预测。

性能分析因此要把方向 MPKI、BTB miss、返回目标错误和每次重定向丢失周期拆开。13 级流水线也不等于固定 13 周期误预测代价：实际代价取决于分支在哪一级解析、正确目标由谁提供、I-Cache 是否命中以及前后端重新填充速度。没有专用 PMU 事件时，可以用固定方向、变化 PC 数量、间距和嵌套深度的正交微基准分别隔离这些因素。

## 三、取指与译码：12 B/cycle 只代表 L1I 命中快路

【原文援引公开资料】P550 的 32 KB、4 路组相联 L1 指令 Cache 带奇偶校验保护，可以向下游三宽译码器提供 12 B/cycle。代码位于 L1I 时，作者的指令取数微基准接近这一上限。

【作者实测】工作集超过 L1I 后，P550 的取指字节带宽降到约 8 B/cycle，原文将其解释为从 L2 仍可维持约 2 IPC；工作集进入 L3 后，约 4 B/cycle 对应约 1 IPC。再向下进入内存，供给接近 1 B/cycle。

![图 9：P550 与 Cortex-A75 的指令取指带宽](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p550_wechat_article_zh/d909948c0f414631_09_instruction_fetch_bandwidth.png)

*图 9：横轴为代码测试规模，纵轴为取指字节/周期。P550 在 32 KB 内约为 12 B/cycle，随后经历约 8 B/cycle 和约 4 B/cycle 台阶；A75 的 64 KB L1I 覆盖更大，但离开私有 Cache 后下降更陡。原文没有公开代码布局和控制流；曲线只表示该指令取数微基准的字节供给，不等于应用 IPC。*

Cortex-A75 的 L1I 为 64 KB，更大的容量提高了指令访问在一级命中的概率；但 Snapdragon 670 把 1 MB System Level Cache 放在更靠近内存控制器的位置，它并不以单个 CPU 核的低延迟、高带宽为首要目标。EIC7700X 的 4 MB L3 则与 P550 簇更紧密，因此 P550 在 L1I miss 后的曲线反而更平缓。这一差异主要说明 SoC Cache 拓扑，而不能简单归结为核心前端优劣。

取回的指令经译码形成内部微操作，再通过重命名进入乱序后端。原文没有给出重命名宽度、前端队列深度、分支 checkpoint 数量或恢复算法。

### 体系结构视角｜字节供给、指令供给和微操作供给不是同一个量

RISC-V 程序可能混合 16 位压缩指令和 32 位普通指令。12 B/cycle 足以容纳三条 32 位指令，但压缩指令比例更高时，译码宽度会先于字节带宽成为上限；反过来，跨 Cache line、跨页取指、Taken 分支截断、I-TLB miss 和指令对齐都会让可用字节低于物理接口宽度。

L1I miss 时，请求要进入 L2/L3 refill；I-TLB miss 要查询下一级 TLB，仍 miss 才进行页表遍历。重定向或异常发生后，前端还必须用 epoch 或同类机制丢弃旧路径迟到的取指和翻译结果。验证时应分别统计 fetch bytes、有效指令、压缩指令比例、I-Cache/TLB 各级 miss、decode 利用率和前端空周期，而不能把图 9 的峰值直接写成应用吞吐。

## 四、乱序执行：ROB 是视野，最小资源决定可用窗口

【作者实测】作者通过阻塞退休探测可见容量；其中 A75 明确使用一条未完成分支与一条未完成 Load 的组合，P550 的具体阻塞序列原文没有交代。测试给出的 P550 ROB 约为 96 项，高于 A75 的约 73 项；但 A75 继承了 A73 的特殊乱序退休行为，某些阻塞构造下可以让缓冲资源利用得更充分。因此，微基准测到的是特定条件下的可见容量，不是所有工作负载中的等效窗口。

![图 10：P550 与 Cortex-A75 的可见乱序资源容量](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p550_wechat_article_zh/3a6c809295d8a392_10_reordering_capacity_comparison.jpg)

*图 10：P550 的可见容量约为 96 项 ROB、95 个投机整数目的寄存器加 32 个假定已退休寄存器、87+32 个 FP 寄存器、20 项 Load Queue 和 16 项 Store Queue；A75 相应为约 73、69+32、57+32、68 和 14。A75 总览图把 Load Buffer 写成 69，本表写 68，都是作者反推值。物理寄存器很多，并不意味着内存窗口同样宽。*

两颗核心相对各自 ROB 都有较充足的物理寄存器，但内存次序队列偏薄；总体窗口远小于当代 Intel、AMD 大核和更晚的 Cortex-A710，更接近 Core 2 或 Goldmont Plus。即使如此，它们仍比顺序执行更有能力越过短时停顿。

重命名通过把架构寄存器映射到物理寄存器，消除 WAR/WAW 假依赖；ROB 则保持程序顺序、完成状态和异常信息，使乱序完成的指令最终形成精确架构状态。ROB 满、物理寄存器耗尽、调度器或 Load/Store Queue 满，都会停止重命名。分支错判和异常还要求撤销年轻指令占用的资源，并恢复正确的寄存器映射。

原文只证明 P550 存在重命名与乱序执行，没有证据区分它使用逐分支映射 checkpoint、历史缓冲回滚还是混合恢复方案。

### 整数、FP 与调度资源

【作者实测与推断】P550 有三条整数执行路径：第一条可执行 ALU 和分支，第二条为普通 ALU，第三条可执行 ALU 与整数乘法。作者估计相应调度容量约为 16、约 8 和 16 项。Load 与 Store 各自有约 18 项调度容量，较深的等待队列可以吸收短时读写比例不均，但不能改变每周期只有一条 Load AGU 的峰值。

![图 11：P550 与 Cortex-A75 的执行单元和调度容量](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p550_wechat_article_zh/b109399e7676a174_11_execution_units_comparison.png)

*图 11：P550 用三条较灵活的整数路径和独立 Load/Store AGU，A75 则用两条 ALU、独立分支端口和两条可同时处理 Load/Store 的 AGU。方框中的容量来自作者微基准；P550 第二整数调度器的 8 项带问号，FP 的 28 项也无法区分统一双端口队列与两个 14 项队列。*

原作者认为，P550 的整数端口可达性更灵活、调度容量更多；A75 的独立分支端口则不需要整数寄存器写回路径，可能以更低成本获得接近的标量整数性能。这是设计取舍判断，而非面积测量。

P550 的两条 FP 路径都能处理加法、乘法与融合乘加（Fused Multiply-Add，FMA），这三类操作的实测延迟均为 4 周期。作者据此猜测它们可能复用 FMA 单元：加法可视为乘数为 1 的 FMA，乘法可视为加数为 0 的 FMA。但相同延迟不能唯一证明物理实现。

A75 的 FP 加法与乘法为 3 周期，FMA 为 5 周期，可能使用分离单元，也可能只是在共享单元中设计了更短旁路。A75 还支持 128 位 NEON 向量执行，而 P550 没有向量能力。作者测得 A75 约有 31 项 FP 调度容量，与 AnandTech 给出的两个 8 项调度器并不一致；P550 则约为 28 项。

### 体系结构视角｜窗口大小必须和指令可达端口一起看

ROB 决定核心能“看到”多远，调度器决定哪些已看到的指令能够等待并竞争端口，物理寄存器保存投机结果，Load/Store Queue 则维持内存次序。只扩 ROB 而不扩更早耗尽的队列，并不能得到同等比例的延迟容忍度。

端口数量也不等于吞吐。指令只能进入兼容的调度器和执行路径；操作数未就绪、端口忙、寄存器读或回写冲突都会延后发射。4 周期 FMA 是依赖链延迟，不代表吞吐一定是每 4 周期一条；只有把依赖链测试与多条独立链分开，才能判断管线是否可以逐周期接收新操作。

在有计数器或 RTL 的环境中，应查看 ROB、空闲物理寄存器表（free-list）、各调度器和 LSQ 的占用率（occupancy）、高水位与满（full）周期，并检查已就绪但尚未发射（ready-but-not-issued）的指令为何停留。分支恢复时还要确认错误路径的物理寄存器和队列项只释放一次，迟到写回不会污染新映射。

## 五、Load/Store、TLB 与未对齐慢路径

P550 配有两个地址生成单元（Address Generation Unit，AGU），其中一个只处理 Load，另一个只处理 Store；两者后面都有约 18 项调度容量。A75 的两条 AGU 都能处理 Load 或 Store，对以 Load 为主的常见工作负载更灵活。

原文引用 David B. Papworth 的 *Tuning the Pentium Pro Microarchitecture* 作历史类比：Intel 当时观察到两条 Load/Store 端口的平均利用率都只有约 20%，改成一条专用 Load 和一条专用 Store 后，性能损失不到 1%。这说明专用端口可能以很小的平均性能代价节省面积和复杂度，但不能证明 SiFive 采用了完全相同的分析过程。

### 两级 TLB

【作者实测与推断】P550 的一级数据 TLB（DTLB）和指令 TLB（ITLB）各有 32 项、全相联；统一二级 TLB 为 512 项、4 路组相联。数据访问在 L2 TLB 命中时，相对 L1 TLB 命中多约 9 周期。A75 的 DTLB 为 48 项、ITLB 为 32 项；其 Main TLB 对 4/16/64 KB 页为 1024 项、4 路，对 1/2/16/32/512 MB 与 1 GB 页为 256 项、2 路。作者测得 A75 下一级 TLB 命中的附加代价约 5～6 周期。

![图 12：P550 与 Cortex-A75 的地址翻译缓存](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p550_wechat_article_zh/0ae98195bd6481d5_12_tlb_comparison.png)

*图 12：P550 的两个 32 项一级 TLB 共享 512 项、4 路 L2 TLB。A75 Main TLB 按页面组分成 1024 项/4 路与 256 项/2 路两种容量。P550 总览图中的“约 256 项？”与本图的 512 项冲突；本文采用后文详细测试口径，同时保留其原作者反推和未确定属性。*

以 4 KB 页粗略计算，32 项一级 TLB 的覆盖范围只有约 128 KB，512 项 L2 TLB 约覆盖 2 MB；大页可以显著增加 TLB reach。实际命中率还受页大小、ASID、替换、统一 L2 中指令与数据竞争以及页表遍历并发度影响。

### Store forwarding 与非对齐访问

在访问 Cache 之前，年轻 Load 必须与更老的 Store 做地址依赖检查。P550 只有在 Load 与 Store 地址完全相同、而且两次访问都自然对齐时，才能走快速 Store forwarding。部分重叠、跨自然边界等情况会显著增加复杂度。

![图 13：P550 的 Store-to-Load 偏移矩阵](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p550_wechat_article_zh/1115a05077d996f4_13_p550_store_forwarding_matrix.jpg)

*图 13：列扫描 32-bit Load Offset 0～63，行扫描 64-bit Store Offset 0～63，单元格给出周期数。图中可见约 1～7、约 741、约 1062 和约 1803～1804 的周期性区域；各区域的具体成因仍应结合正文测试解释。原图数字密集，发布时应保留原尺寸。*

【作者实测】单个未对齐 Load 约需 1062 周期，未对齐 Store 约需 741 周期，两者组合超过 1800 周期，而且几乎不能重叠。硬件计数器还显示，每执行一条未对齐 Load，会产生约 505 条执行指令。

【未确定项】按图 13 的轴标签读取，Store 保持自然对齐而只改变 Load Offset 的区域更接近约 741 周期；Load 对齐而只改变 Store Offset 的区域更接近约 1062 周期，与正文对 Load/Store 的 1062/741 归属相反。原文没有解释是轴标、测试定义还是文字归属造成差异，本文不强行统一；两种口径共同确认的只有“单侧未对齐分别进入约 741 与 1062 周期慢路、两侧未对齐合计约 1800 周期”。

【作者推断】作者据此认为 P550 很可能没有硬件未对齐访问支持，而是触发异常，由操作系统处理程序在软件中模拟。这个解释与上千周期代价和额外指令数相符，但仍可能受内核实现、固件路径和计数器口径影响，因此不能写成 RTL 已证实的事实。

![图 14：Cortex-A75 的 Store-to-Load 偏移矩阵](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p550_wechat_article_zh/bebffdf9f88380fc_14_cortex_a75_store_forwarding_matrix.jpg)

*图 14：Snapdragon 670/Cortex-A75 上的同类测试，同样以列表示 32-bit Load Offset、行表示 64-bit Store Offset，并扫描 0～63。多数快区约为 1～3 周期，较慢条带约为 5～15 周期；正文归纳相依且两侧均未对齐的最差情况约 15 周期。*

### 体系结构视角｜慢路径同样是处理器设计的一部分

未对齐访问可以在 LSU 内拆成两个对齐拍（beat）再合并，也可以产生地址未对齐异常（address-misaligned exception），由执行环境保存上下文、读取或写入若干字节、更新目标寄存器和 PC，再返回原程序。后一种方案节省硬件，却把一次普通内存操作变成异常入口、软件模拟和异常返回的串行链。

这类取舍对平均负载可能影响很小，但 packed 数据结构、网络协议解析、JIT 代码或 ABI 使用不当会遭遇数量级退化。跨页 Store 还需要明确测试部分写入与非原子语义：RISC-V 允许执行环境决定未对齐访问的支持方式与异常行为，即使访问成功也未必具有原子性；只有执行环境或软件模拟明确承诺全有或全无（all-or-nothing）时，处理程序才必须在写入前完成两页验证。因此，慢路径不仅是性能问题，也牵涉精确异常与执行环境契约。

验证时应扫访问宽度、偏移、同页/跨页和依赖距离，同时统计 `cycle`、`instret`、陷入（trap）次数和异常原因。若能观察 RTL，则要检查对齐检测、异常 `cause/tval`、ROB 精确陷入，并确认陷入前不产生架构不允许且不可回滚的 Store 副作用；Cache 内部请求、所有权获取或分配本身不等于架构可见写入。RISC-V 的硬件性能监控事件编码通常由实现定义，不应杜撰 P550 专用事件名。

## 六、核心私有 Cache：小窗口更依赖命中延迟

P550 没有向量能力，乱序窗口也不大，其目标负载和单核结构通常不会要求与宽向量大核相同的峰值存储吞吐；但它更难用大量独立工作隐藏 miss，Cache 命中延迟反而格外重要。原文称数据侧各级 Cache 都有 ECC 保护。

P550 的 32 KB L1D 为 4 路组相联，命中延迟约 3 周期。在没有对齐问题时，它每周期可以服务一条 64 位 Load 和一条 64 位 Store，读写各 8 B/cycle，均衡读写的合计峰值为 16 B/cycle。

私有 L2 为 256 KB、8 路组相联、双 bank，命中延迟约 13 周期，读写带宽都约 8 B/cycle。这个容量与延迟不算激进，但能在相当一部分 L1 miss 到达共享 L3 之前将其截住。

![图 15：P550 与 Cortex-A73 的 Cache/内存延迟](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p550_wechat_article_zh/5d3471e25c37bd6e_15_cache_memory_latency.png)

*图 15：原图注译文为“使用 A73 对比，因为我无法在 Android 上使用大页”。测试使用 2 MB 页；P550 的台阶约为 L1D 3.01 cycle、L2 13.06 cycle、L3 38.11 cycle；Amlogic S922X 中 Cortex-A73 的 L1 约 3 cycle、1 MB L2 约 24.94 cycle。*

图 15 还展示一种不同的层次取舍：A73 用 1 MB L2 同时承担 L1 后的低层 Cache 和末级 Cache，容量小于 EIC7700X 的 4 MB L3，但约 25 周期延迟更低；P550 则有 256 KB 私有 L2 加容量更大的共享 L3。

![图 16：读—改—写模式下的 Cache 带宽](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p550_wechat_article_zh/f02ccc0677f74ca0_16_read_modify_write_bandwidth.png)

*图 16：纵轴为 GB/s，横轴为工作集。P550 在 L1 区间约 19.49 GB/s，A75 约 31.48 GB/s；A75 的下一层仍可见约 17.46 GB/s，而 P550 进入 L2 后约为 11 GB/s，随后向 L3 带宽收敛。P550 图例明确使用 2 MB 页，A75 图例未标页大小；绝对 GB/s 还同时包含 1.4 与 2.0 GHz 的频率差。*

【作者结论】A75 在每周期带宽和频率上都更高，因此各级 Cache 的绝对带宽领先 P550。不过，对单 Load AGU、无向量的低频 P550，8 B/cycle L2 仍可能满足目标负载。

### 体系结构视角｜延迟、带宽与并发 miss 必须一起看

Cache 延迟描述一条依赖链多久拿到数据；带宽描述稳定流量能通过多少；并发 miss 数则决定处理器能否用内存级并行（Memory-Level Parallelism，MLP）把长延迟转化为吞吐。小 ROB、20 项 Load Queue 和单 Load AGU 会限制 P550 能制造的并发，因此低延迟 L1/L2 对它尤其重要。

资源满时，MSHR、回写队列、bank 或 refill 端口都可能反压 LSU；最老 Load 未完成又会阻塞退休，最终填满 ROB。完整验证要记录各级 hit/miss、延迟分布、MSHR occupancy/full、bank conflict、回写和 ECC 事件。只看峰值 GB/s，看不到依赖负载的停顿和饱和后的排队。

## 七、共享 L3、互连与 DRAM：从核心 IP 走向 SoC 实现

P550 最多以四核组成一个 cluster；多个 cluster 可以接入 Coherent System Fabric。原作者根据 EIC7700X 数据表推测，这一 fabric 很可能是 crossbar，单个 cluster 可能共享一个外部接口。这些属于结构反推。

【原文援引公开资料】SiFive 提供 1、2、4 和 8 MB 的 L3 配置。最大的 8 MB 版本有 8 个 bank，用于多 cluster 方案；EIC7700X 采用 4 MB、4 bank，bank 数与四个核心一致。

![图 17：跨越 Cache 层次与 DRAM 的多线程带宽](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p550_wechat_article_zh/73e52174aa62342f_17_multithreaded_cache_memory_bandwidth.png)

*图 17：该图跨越私有 L1/L2、共享 L3 与 DRAM。四线程 P550 的 Add 曲线在共享 L3 区间标出约 43.88 GB/s，远端 P550 曲线标出 16.74 GB/s；Amlogic S922X 的 A73 read 远端标注约 8.02 GB/s。原文未定义 Add 带宽是否同时计入读写流量，不能把不同 pattern 的线直接换算成端口宽度。*

![图 18：原作者反推的 P550 存储层次与 Coherent Fabric](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p550_wechat_article_zh/f7940039240dab96_18_p550_memory_hierarchy.png)

*图 18：原图注译文为“很可能每个 cluster 只有一个 32 B/cycle（256-bit）接口连接 crossbar”。作者还画出 48-bit 虚拟地址、41-bit 物理地址、20/16 项 Load/Store Queue、512 项 L2 TLB、32 KB L1D、256 KB L2、四个 1 MB/16 路 L3 bank 及各类外部端口；128 位 Memory Port 同样带问号。这些位宽与容量来自原作者整理/反推图，不是 RTL 确认。*

【作者实测】单核可从 L3 获得约 8 B/cycle；四核合计约 43.88 GB/s。以 1.4 GHz 粗算，`4 × 8 B/cycle × 1.4 GHz = 44.8 GB/s`，按原作者采用的带宽口径，两者在算术上接近；但 Add 的读写流量计数没有定义，不能单凭该等式确认物理接口已经饱和。L3 延迟约为 38 周期，在其可配置、可共享的目标下并不差。

L3 miss 进入 Memory Port。公开资料允许一到两个 128 或 256 位 Memory Port，每个最多跟踪 128 个未完成请求；非 Cache 或 I/O 请求可以进入两个 64 位 System Port 或一个 64 位 Peripheral Port；一到两个 Front Port 则允许其他代理以一致方式接入该复合体。

【作者推断】EIC7700X 选择了一个 Memory Port，可能为 128 位，并使用两个 System Port。第一个 System Port 覆盖 256 MB PCIe BAR、PCIe 配置空间和 4 MB ROM；第二个可访问 DSP SRAM 等资源。

![图 19：EIC7700X SoC 模块图](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p550_wechat_article_zh/8cb878b0ec1537cf_19_eic7700x_soc_block_diagram.png)

*图 19：手册页眉处于 EIC7700X 语境，图底小字却写作“EIC700X block diagram”。图内展示四核 RV64GC cluster、4 MB L3、crossbar、AXI4 互连，以及 GPU、NPU、DSP、PCIe 和多媒体模块，并标出 CPU 最高可到 1.8 GHz；本文实测配置仍是 1.4 GHz。*

这些端口继续连接采用 AXI 协议的片上网络。走到这里，性能已经强烈取决于 SoC 实现者，而不再只由 SiFive 核心 IP 决定。Eswin 配置了两个 DDR 控制器，每个带两个 16 位子通道；开发板连接 16 GB LPDDR5-6400。内存控制器运行在 SDRAM 时钟的四分之一，即约 800 MHz。

![图 20：EIC7700X 的 LPDDR 子系统](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p550_wechat_article_zh/bfdf8bcd63b0a6a7_20_eic7700x_lpddr_subsystem.png)

*图 20：EIC7700X 手册显示两个 DDR Controller/PHY，各连接两个 x16 子通道，并通过 NoC 接入。总线拓扑提供了 64 位原始数据宽度，但 inline ECC、控制器调度、NoC 排队和其他主设备竞争都会降低可用带宽。*

【作者实测】开发板的 DRAM load-to-use 延迟约为 194 ns，约比 L3 延迟多 165 ns。原文无法区分其中多少来自片上网络，多少来自内存控制器。作者评价它明显慢于 Meteor Lake 和 AMD Van Gogh（Steam Deck SoC）等 LPDDR5 平台；这些并非统一方法、统一配置的严格比较。实测 DRAM 带宽为 16.74 GB/s，明显低于 64 位 LPDDR5-6400 的理论值；inline ECC 会占用一部分位宽，但仍不足以解释全部差距。作者同时认为，对四个 1.4 GHz、无向量的低功耗核心，这一带宽在很多场景仍可能够用。

### 体系结构视角｜可授权核心必须与 SoC 边界一起评价

一次 LLC miss 会穿过 cluster 出口、共享 fabric、Memory Port、NoC、DDR 控制器、PHY 和 DRAM。194 ns 在 1.4 GHz 下约为 272 周期，远超约 96 项 ROB 可以直接覆盖的范围；只有多个独立 miss、预取和足够的未完成请求槽位，才能把单次高延迟转化为较高吞吐。

因此，“P550 的内存延迟”并不是严谨表述。分支预测、ROB 和执行端口更接近核心属性；L3、DRAM 与核间传输则是 P550 IP、EIC7700X fabric、内存控制器、板级布局和软件状态的共同结果。验证 SoC 瓶颈需要扫 outstanding 请求数，并观察 AXI 的 `valid/ready`、ID、队列 occupancy、DDR row hit、读写切换、refresh 和各主设备带宽。

## 八、核间传输：目录能扩展，不代表单次转移一定快

【原文援引公开资料】EIC7700X 数据表称其存储系统包含“基于目录的一致性管理器”。目录记录 Cache line 的共享者或所有者，使请求只向相关核心发送 probe；相对广播，它能在核心数增加时控制探测流量。

作者用自编 core-to-core latency 测试测量一个核心多久能观察到另一个核心的写入。其方法与 AnandTech 等站点并不完全相同，原文只认为结果“大体可比”。

![图 21：EIC7700X 的核间传输延迟](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p550_wechat_article_zh/83eb1a179e3ffab6_21_eic7700x_core_to_core_latency.png)

*图 21：四个 P550 核之间的方向性矩阵集中在约 378～380.5，各组合没有明显的近邻/远端层级。原图没有打印单位；结合上下文与对照量级，通常可按 ns 理解，但不能把推定单位写成图内明示条件。矩阵也不能外推到所有 P550 cluster。*

![图 22：Snapdragon 670 的核间传输延迟](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p550_wechat_article_zh/0266f30b0ac5c01d_22_snapdragon_670_core_to_core_latency.png)

*图 22：Pixel 3a/Snapdragon 670 的八核矩阵约为 35.45～37.85，原图同样没有打印单位，也没有给出 CPU 编号与 A75/A55 的对应关系。作者称 A75 与 A55 之间的传输也更快；由于方法、频率、Cache 和一致性实现不同，数量级差距不能精确定位到某一级。*

【作者判断】原作者认为很高的核间延迟不太可能明显影响一般应用，但它增加了 P550 平台“不够精致”的观感。

### 体系结构视角｜核间延迟的影响取决于共享粒度

对相互独立的线程，核间所有权转移（ownership transfer）很少发生，图中约 380 的高延迟可能并不进入关键路径；但锁、无锁队列、任务唤醒、原子操作和伪共享（false sharing）会反复转移同一 Cache line 的所有权。此时目录查询、一致性探测（probe）、失效、脏数据回传和权限迁移会串行化，核间延迟可能直接限制多线程扩展性。

更完整的测试应区分同 cluster/跨 cluster、只读共享/写入 ping-pong、同一行/不同一行、原子操作与线程唤醒，并观察 probe、invalidation、remote modified hit、目录 retry 和 fabric 排队。平均应用影响不能只由这张核间延迟矩阵决定。

## 九、总结：基础链路已经建立，边角仍显粗糙

【作者判断】P550 的目标是在严格功耗和面积约束下取得尽可能高的性能，而不是正面对抗 Zen 5、Lion Cove 或 Oryon。其乱序引擎规模更接近早期 Core 2，频率又显著更低，因此作者把它定位为一颗低功耗、性能适中的核心，适合处理顺序核略显吃力的轻量管理任务。这是基于整篇微基准形成的总体评价，并非统一应用 Benchmark 得出的用途认证。

![图 23：SiFive Premier P550 开发板系统框图](https://gongzhonghao-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/sifive_p550_wechat_article_zh/812d627da94f1cdb_23_p550_board_block_diagram.jpg)

*图 23：开发板数据表中的系统框图列出 16/32 GB LPDDR5 与 64-bit inline ECC；本文被测板配置为 16 GB。PCIe、网络、USB、SATA、音频和扩展接口说明 P550 最终以完整平台交付，但这些系统资源不是 P550 核心内部参数。*

原作者更看重 P550 的演进意义。SiFive 不久前还主要聚焦微控制器所需的小型顺序核，而 P550 已建立一套相对均衡的乱序引擎和 Cache 层次。高性能通用处理器很难绕开乱序执行：Intel 与 IBM 都曾因复杂度尝试在 Itanium、POWER6 上走向不同路线，最终仍说明从动态执行中提取指令级并行极其重要。

【作者判断】P550 仍只是中间一步。与 Cortex-A75 相比，它更像 Arm 较早期的 Cortex-A57：时钟较低、未对齐访问代价异常高、缺少向量支持，很多边角路径尚未打磨。A75 推出时，Arm 已积累多年乱序核心经验，因此整体更完整。原作者同时收窄了结论：许多程序不会触发 P550 最差的未对齐与恢复路径，不能用最坏微基准否定全部常见工作负载。

作者还把 P550 类比为 Intel 的 Pentium Pro。Pentium Pro 在 16 位代码等场景中表现不佳，却让 Intel 建立了继续设计更复杂乱序核心的信心。SiFive 后续已经公布 P870 等更复杂方案；从这个角度看，P550 已经建立较均衡的乱序引擎和称职的 Cache 层次，为后续更复杂核心积累了基础。

## 十、体系结构层面的六条认识

第一，**开放指令集不会自动产生高性能，实现经验仍是决定性变量**。RISC-V 定义软件与硬件的接口；分支目标能否及时交付、错误路径能否可靠恢复、依赖 Load 能否尽早唤醒、Cache 与互连能否持续供数，才决定 P550 的有效 IPC。P550 的进步在于这些基础链路已经形成系统，而不是 ISA 本身天然带来性能。

第二，**均衡不是每个数字都大，而是资源围绕同一目标吞吐配套**。三宽译码、约 96 项 ROB、单 Load/单 Store AGU、8 B/cycle L2 和无向量能力大体位于同一面积与功耗档位。对低频标量负载，这可能比孤立堆大 ROB 或宽 Cache 更合理；判断设计是否均衡，应看最常遇到的瓶颈是否落在预期位置。

第三，**真正的乱序窗口由最先耗尽的资源决定**。96 项 ROB 最显眼，但内存密集代码可能先耗尽 20 项 Load Queue、单 Load AGU、TLB walk 槽位或 MSHR。ROB 是可观察距离，不是保证可行动的容量；体系结构分析必须寻找最小约束。

第四，**前端瓶颈可能从“方向猜错”转移到“目标来不及”**。P550 的方向模式识别并不弱，但约 32 项快速目标容量让更大 Taken 分支工作集出现约三周期供给台阶。方向、BTB、RAS、取指块和恢复链必须共同设计；只报一个分支准确率，会漏掉目标气泡和级联恢复代价。

第五，**快路径漂亮并不能掩盖慢路径不成熟**。对齐 L1D 可以每周期一读一写，私有 L2 也与小窗口较匹配；未对齐访问却可能落入上千周期的软件模拟。处理器成熟度往往体现在 RAS overflow、部分重叠转发、跨页访问和异常恢复这些低频路径上，因为它们会把单个角落事件放大为系统级停顿。

第六，**核心质量与 SoC 集成质量是两个相互耦合、又必须分开的评价对象**。P550 的私有前后端不能直接解释 EIC7700X 的 194 ns DRAM 或核间矩阵约 380 的高值；后两者还包含 fabric、NoC、控制器、板级和软件影响。对可授权 CPU IP，好的核心接口要允许实现者扩展容量和端口，好的 SoC 则要把这些能力转化为可预测的延迟、带宽和一致性行为。

## 参考资料

1. Chester Lam，*Inside SiFive’s P550 Microarchitecture*：https://chipsandcheese.com/p/inside-sifives-p550-microarchitecture
2. SiFive，*Performance P550 Data Sheet*：https://vyvoj.hw.cz/files/p550-8mc-data-sheet-2022.pdf
3. SiFive / Eswin，*EIC7700X Datasheet*：https://www.sifive.com/document-file/eic7700x-datasheet
4. AnandTech，Cortex-A75/A55 架构分析：https://www.anandtech.com/show/11441/dynamiq-and-arms-new-cpus-cortex-a75-a55/3
5. Berkeley Out-of-Order Machine（BOOM）：https://boom-core.org/
6. RISC-V International，*RISC-V Unprivileged ISA Specification*，Load and Store Instructions：https://docs.riscv.org/reference/isa/v20260120/unpriv/rv32.html#_load_and_store_instructions
