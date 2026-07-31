# 玄铁 C910：官方论文、Hot Chips 演讲与独立分析中文译注

## 文档说明

本文分别把下列三份材料的正文、图表、图注、表格、脚注、致谢和参考文献整理为中文：

1. [《Xuantie-910: A Commercial Multi-Core 12-Stage Pipeline Out-of-Order 64-bit High Performance RISC-V Processor with Vector Extension》](<2020_Xuantie-910 - A Commercial Multi-Core 12-Stage Pipeline Out-of-Order 64-bit High Performance RISC-V_Chen, Chen et al_52-64_会议论文.pdf>)，ISCA 2020 工业产品论文，第 52–64 页。
2. [《Xuantie-910: Innovating Cloud and Edge Computing by RISC-V》](<2020_Xuantie-910 - Innovating Cloud and Edge Computing by RISC-V_Chen, Chen et al_1-19_会议论文.pdf>)，Hot Chips 32，2020 年，19 页演示稿。
3. [《Alibaba/T-HEAD's Xuantie C910》](<Alibaba_T-HEAD's Xuantie C910 - by Chester Lam.html>)，Chips and Cheese 的 Chester Lam 于 2025 年 2 月 4 日发表的独立分析。该文结合公开 RTL、微基准和 TH1520 实机测试，对前端、乱序后端、访存和片上互连作了进一步拆解。

翻译约定：

- XT-910、Xuantie-910 与玄铁 910 均指同一处理器；正文依原文多使用 XT-910。
- 前两份 PDF 的图页以 PNG 保存，第三份 HTML 的正文图按原有 JPEG/PNG 格式保存，均已嵌入。图中英文标签之后给出中文解释，可直接对照原始视觉信息。
- 前两份材料中的性能比较、产品计划和市场判断均为官方作者在 2020 年发表时的陈述，不代表本文重新验证后的结论。
- 第三份材料是独立作者的技术分析，不是阿里巴巴或平头哥的官方说明。本文明确区分“官方资料”“公开 RTL 可核对事实”“作者微基准实测”“作者判断”和“本文教学解读”。
- 第三份材料的实测平台是 LicheePi 4A：TH1520、4 个 C910 核、1 MB 共享 L2、1.85 GHz、8 GB LPDDR4X-3733。其延迟和带宽不能直接外推到其他 SoC、Cache 配置或开源 RTL 仿真环境。
- 三份材料按各自原文独立翻译和整理。相同机制出现不同名称、容量或测量结果时，本文保留各自口径并说明证据来源，不为了得到一个“统一规格”而改写其中任何一份材料。
- 原文写作或命名存在不一致时忠实保留并加译注。例如 ISCA 正文写作 “MOSEI”，Hot Chips 演示写作 “MOESI”；通常的一致性协议名称是 MOESI。
- IEEE PDF 页脚中的许可访问提示在此统一记录：原文件由 IEEE Xplore 授权访问，ISCA PDF 显示下载于 2023-02-16，Hot Chips PDF 显示下载于 2023-05-19；原 PDF 的使用限制继续适用。

本文各篇内的普通正文是对应原文的中文转述；标题中带有“教学解读”“体系结构旁白”“核查说明”“综合核查”或“证据边界”的段落是为帮助理解而加入的说明，不属于原文。第三篇不是逐字硬译，而是在不遗漏技术内容、数值、图表和结论的前提下整理语序，使中文表达连贯。跨材料对照只负责呈现异同，不反向修改三篇正文。

## 术语和缩写

### 处理器总体结构

| 英文或缩写 | 中文表述 | 本文中的准确含义 |
|---|---|---|
| ISA | 指令集体系结构 | 软件可见的指令、寄存器、异常和特权规则 |
| RISC-V | 第五代精简指令集体系结构 | XT-910 采用的开放 ISA |
| RV64GCV | 64 位通用指令集加压缩和向量扩展 | G 表示通用基础扩展集合，C 为压缩指令，V 为向量扩展 |
| OoO / Out-of-Order | 乱序执行 | 在不破坏程序语义的前提下，让就绪的年轻指令先执行 |
| superscalar | 超标量 | 一个周期内可以处理或发射多条指令 |
| pipeline | 流水线 | 将指令处理拆成多个可重叠执行的阶段 |
| SMP | 对称多处理 | 多个处理器核共享统一系统软件和一致内存视图 |
| cluster | 处理器簇 | 一组共享 L2 和一致性互连的核心 |
| frontend / backend | 前端 / 后端 | 前端取指、预测、译码和重命名；后端调度、执行、访存和退休 |

### 流水级和执行部件

| 英文或缩写 | 中文表述 | 主要职责 |
|---|---|---|
| IF / Instruction Fetch | 取指 | 生成 PC、访问 I-Cache、进行早期预测 |
| IP / Instruction Pack | 指令打包 | 预处理、边界识别、打包并进行第二级跳转处理 |
| IB / Instruction Buffer | 指令缓冲 | 缓存已取指令并向译码级供给 |
| ID / Instruction Decode | 指令译码 | 识别操作并拆分微操作 |
| IR / Instruction Rename | 指令重命名 | 把架构寄存器映射到物理寄存器 |
| IS / Instruction Issue | 指令发射 | 从队列选择已就绪指令送往执行单元 |
| RF / Register File | 寄存器文件读取 | 读取物理寄存器操作数 |
| EX | 执行 | ALU、分支、乘除法、浮点、向量和访存操作 |
| WB / Write Back | 写回 | 把结果写回物理寄存器或存储队列 |
| RT / Retire | 退休 | 按程序顺序提交结果并释放资源 |
| IFU | 取指单元 | PC、I-Cache、分支预测、打包和指令缓冲 |
| IDU | 指令译码单元 | 译码、重命名、调度和寄存器读取相关逻辑 |
| LSU | 访存单元 | load/store 地址生成、Cache、队列、转发和回放 |
| RTU | 退休单元 | 顺序提交、异常和流水线恢复 |
| ALU | 算术逻辑单元 | 整数加减、逻辑、比较和部分移位 |
| BJU | 分支跳转单元 | 计算分支条件和目标并发现误预测 |
| FPU | 浮点单元 | 标量浮点运算 |
| VEC / VFPU | 向量执行或向量浮点单元 | 向量整数、浮点和相关 load/store |

### 乱序执行资源

| 英文或缩写 | 中文表述 | 作用 |
|---|---|---|
| ROB / Reorder Buffer | 重排序缓冲 | 记录在途指令状态并保证按序退休 |
| IQ / Issue Queue | 发射队列 | 保存等待操作数或执行端口的指令 |
| GPR | 通用整数寄存器 | 软件可见的整数寄存器 |
| FGPR | 浮点寄存器 | 软件可见的浮点寄存器 |
| VGPR | 向量寄存器 | 软件可见的向量寄存器 |
| PRF | 物理寄存器文件 | 重命名后保存推测执行结果 |
| Age Vector | 年龄向量 | 表示队列项先后关系，帮助优先选择较老指令 |
| µOp | 微操作 | 一条 ISA 指令在处理器内部拆成的执行单位 |
| RAW | 写后读真依赖 | 消费者必须等待生产者产生数据 |
| WAR / WAW | 读后写 / 写后写伪依赖 | 可通过寄存器重命名消除 |
| flush | 清空流水线 | 丢弃错误路径或异常之后的推测状态 |
| folded ROB entry | 折叠式 ROB 表项 | 一个物理 ROB 表项可聚合多条满足条件的顺序指令，因此物理表项数不必等于可容纳的 ISA 指令数 |

### 分支预测和取指

| 英文或缩写 | 中文表述 | 作用 |
|---|---|---|
| BTB | 分支目标缓冲 | 由分支 PC 查询预测目标地址 |
| BHT | 分支历史表 | 依据历史预测条件分支方向 |
| GHR | 全局历史寄存器 | 记录近期分支 taken/not-taken 序列 |
| RAS | 返回地址栈 | 为函数 return 预测调用点后的返回地址 |
| indirect predictor | 间接分支预测器 | 预测寄存器间接跳转的目标 |
| bi-mode predictor | 双模预测器 | 分离不同方向偏好的分支以减少别名干扰 |
| IBUF | 指令缓冲 | 在前端供给多于后端消耗时积累指令 |
| LBUF | 循环缓冲 | 保存短循环体，绕过重复取指和回跳气泡 |
| way prediction | Cache 路预测 | 提前猜测组相联 Cache 命中哪一路，降低访问能耗或延迟 |
| predecode | 预译码 | 在 I-Cache 中随指令保存边界、分支等辅助位，减少后续识别工作 |
| MPKI | 每千条指令未命中数 | 将预测器或 Cache 未命中按动态指令数归一化，便于跨程序比较 |

### 存储层次和地址转换

| 英文或缩写 | 中文表述 | 作用 |
|---|---|---|
| I-Cache / D-Cache | 指令 Cache / 数据 Cache | 保存近期指令和数据 |
| L1 / L2 | 一级 / 二级 Cache | L1 更小更快且通常每核私有；L2 更大并可共享 |
| LQ / SQ | load 队列 / store 队列 | 保持内存指令顺序、检测依赖、转发和回放 |
| AG / AGU | 地址生成级 / 地址生成单元 | 计算基址、索引、偏移形成的有效地址 |
| DC / DA | 数据 Cache / 数据对齐级 | 访问 D-Cache，并按访问宽度对齐返回数据 |
| TLB | 地址转换后备缓冲 | 缓存虚拟页到物理页的页表转换 |
| uTLB / jTLB | 微型 TLB / 联合 TLB | 前者小而快，后者更大并统一回填 |
| MMU | 内存管理单元 | 执行地址转换、权限和内存属性检查 |
| VPN | 虚拟页号 | 虚拟地址中用于查询页表或 TLB 的高位 |
| ASID | 地址空间标识符 | 区分不同进程的同名虚拟地址，减少切换时清空 TLB |
| Sv39 | 39 位虚拟地址分页方案 | RISC-V 64 位系统常用的三级页表模式 |
| PMP | 物理内存保护 | 机器态配置的物理地址访问权限区域 |
| ECC / parity | 纠错码 / 奇偶校验 | 检测或纠正 Cache、SRAM 中的位错误 |
| prefetch | 预取 | 在正式 load 之前把可能需要的数据搬入 Cache |
| LFB / line-fill buffer | Cache line 填充缓冲 | 跟踪尚未完成的 Cache miss，并暂存回填地址或数据 |
| store forwarding | store 到 load 转发 | 较老 store 尚未写入 Cache 时，直接把其数据交给依赖 load |
| AXI4 | AMBA AXI 第 4 版总线协议 | C910 簇与外部系统互连使用的高带宽片上接口协议 |

### 多核一致性和系统控制

| 英文或缩写 | 中文表述 | 作用 |
|---|---|---|
| MOESI | 修改、拥有、独占、共享、无效协议 | 维护多个 Cache 副本的一致内存视图 |
| snoop | 侦听 | 观察其他核心的一致性请求 |
| snoop filter | 侦听过滤器 | 记录某条 Cache line 可能在哪些核心，减少无效广播 |
| directory | 目录 | 集中或分布记录共享者和所有者 |
| CLINT | 核心本地中断器 | 提供软件中断和定时器中断等本地功能 |
| PLIC | 平台级中断控制器 | 汇聚、仲裁并分发外部中断 |
| HAD | 硬件辅助调试 | 玄铁处理器的调试逻辑 |
| PIU | 处理器接口单元 | 在核或处理器侧接入 CIU；不同资料对边界模块命名略有差异，应以具体 RTL 层次为准 |
| CIU | 一致性接口单元 | 接收各核请求、执行一致性仲裁并连接共享 L2 与系统总线 |
| SNB | 侦听广播/缓冲单元 | CIU 内按物理地址位分 bank 处理相干事务的单元 |
| SAB | 侦听地址缓冲 | SNB 内跟踪尚未完成的一致性请求；当前 RTL 每个 SNB 有 24 项 |

### 向量、工艺和评测

| 英文或缩写 | 中文表述 | 含义 |
|---|---|---|
| VLEN | 向量寄存器位宽 | 向量架构或实现中的寄存器长度参数 |
| SLEN | 单次内部传输或执行位宽 | Vector 0.7.1 时代使用的实现参数 |
| VL | 当前向量长度 | 本次向量指令实际处理的元素数 |
| VLMAX | 当前配置可容纳的最大元素数 | 由寄存器宽度与元素宽度等共同决定 |
| VSEW | 当前选定的向量元素宽度 | 例如 8、16、32 或 64 位元素，影响同一向量寄存器可容纳的元素数 |
| widening / narrowing | 扩宽 / 收窄运算 | 结果元素宽度变大或变小 |
| permutation | 向量重排 | 跨 lane 或 slice 改变元素位置 |
| MAC / FMA | 乘加 / 融合乘加 | 一次完成乘法与加法；峰值 FLOPS 常把它计为两次浮点运算 |
| LVT / ULVT | 低阈值 / 超低阈值单元 | 速度更高但通常漏电更大的标准单元或 SRAM |
| VDD | 电源电压 | 升高电压通常有利于频率，但增加功耗和可靠性压力 |
| TT | 典型 NMOS、典型 PMOS 工艺角 | 工艺、电压、温度条件中的典型工艺样本 |
| CoreMark/MHz | 每 MHz 的 CoreMark 得分 | 归一化核心吞吐指标，不包含工作频率本身 |
| IPC / CPI | 每周期指令数 / 每指令周期数 | IPC 越高通常越好；单线程条件下 CPI 约为 IPC 的倒数 |

---

# 第一篇：带向量扩展的商用多核、12 级流水、乱序 64 位高性能 RISC-V 处理器

## 第一篇出版信息

- 英文题目：Xuantie-910: A Commercial Multi-Core 12-Stage Pipeline Out-of-Order 64-bit High Performance RISC-V Processor with Vector Extension
- 论文类型：工业产品论文
- 会议：2020 ACM/IEEE 第 47 届国际计算机体系结构年会（ISCA）
- 页码：52–64
- DOI：10.1109/ISCA45697.2020.00016
- 作者：Chen Chen、Xiaoyan Xiang、Chang Liu、Yunhai Shang、Ren Guo、Dongqi Liu、Yimin Lu、Ziyi Hao、Jiahui Luo、Zhijian Chen、Chunqiang Li、Yu Pu、Jianyi Meng、Xiaolang Yan、Yuan Xie、Xiaoning Qi
- 单位：阿里云平头哥事业部
- 通讯作者邮箱：jianyi.mjy@alibaba-inc.com
- 版权：© 2020 IEEE
- IEEE 出版标识：978-1-7281-4661-4/20/$31.00
- 说明：本文属于 ISCA 2020 工业赛道。

## 摘要

开源 RISC-V 指令集体系结构正迅速获得发展动力。本文介绍阿里巴巴平头哥事业部推出的玄铁 910，这是一款业界领先的 64 位高性能嵌入式 RISC-V 处理器。它完整建立在 RV64GCV 指令集之上，并针对算术运算、位操作、访存、TLB 和 Cache 操作提供定制扩展。它还实现了 RISC-V 向量扩展规范的 0.7.1 稳定版本，以实现高效率向量处理。

玄铁 910 支持带 Cache 一致性的多核、多簇 SMP。每个簇包含 1–4 个能够启动 Linux 操作系统的处理器核。每个单核采用先进的 12 级深流水、乱序、多发射超标量体系结构。在 TSMC 12 nm FinFET 工艺的典型工艺、电压和温度条件下，最高频率可达 2.5 GHz。带向量执行单元的单核面积为 0.8 mm²，不包括 L2 Cache。

配套工具链经过大幅增强，可支持向量扩展和定制扩展。通过硬件与工具链协同优化，截至论文发表时，与 RISC-V 家族中的前代处理器相比，玄铁 910 在多项工业控制流与数据计算 benchmark 上取得了最高的 IPC、速度和能效。玄铁 910 的 FPGA 实现已经部署到阿里云数据中心，用于区块链交易等专用加速。面向物联网端点和边缘计算等低成本 SoC 应用的 ASIC 部署也已列入计划，以支撑阿里巴巴端到端、云到边的计算基础设施。

**关键词：** RISC-V、多核、Cache、存储体系结构、乱序执行、向量、扩展。

## 一、引言

云计算与物联网应用推动了新一轮半导体研发浪潮，对低功耗、高性价比 CPU 的需求持续增长。RISC-V 在这一时期具有很强吸引力，原因包括：

1. 相比封闭且成本高昂的指令集，开放、免费的 RISC-V ISA 通过开放标准协作加速处理器创新。
2. RISC-V 具有可伸缩、可扩展和模块化特征，可针对机器学习加速器、网络处理、安全飞地、存储控制器和超级计算等领域专用负载定制处理器，从而提高处理效率并降低设计成本。
3. RISC-V 正逐渐成为 Unix/Linux 操作系统的主流平台，GNU、GCC、GDB 和 LLVM 等工具链日趋成熟，进一步改善软件体验并降低软件开发成本。

但与 x86、ARM、MIPS [16]–[18]、PowerPC、SPARC [11][20][21][23][30]、OpenRISC [14][24][26]，以及主流 GPU 和 DSP 背后的其他 ISA 相比，RISC-V 当时仍处于早期阶段。作者列举了以下进展。

### 学术界工作

- 加州大学伯克利分校发布了顺序执行的 Rocket 核、乱序执行的 BOOM 核以及开源设计生成器 [9][10]。Rocket 与 BOOM 都能够启动 Linux。
- 苏黎世联邦理工学院与博洛尼亚大学在 PULP 平台 [4] 中提供了三种 RISC-V 核：32 位四级流水 RI5CY、32 位两级流水 Zero-riscy，以及 64 位六级流水 Ariane [32]。
- 印度理工学院马德拉斯分校开发了 Shakti 系列 RISC-V 处理器，范围从三级流水顺序核到目标频率 1.5–2.5 GHz 的乱序多线程核 [5][13]。

### 工业界工作

- NVIDIA 多年来一直在 GPU 中使用 RISC-V 作为 Falcon 控制器 [8]。
- SiFive、Microsemi、阿里巴巴平头哥、Andes 与 Codasip 等芯片厂商提供了多种经过硅验证的 32 位和 64 位嵌入式 RISC-V IP。
- Western Digital 当时刚开源 SweRV Core [25]。它是一款工业级 32 位、双发射超标量、九级流水处理器，在 TSMC 28 nm CMOS 工艺下频率超过 1.0 GHz。其内部仿真性能最高达到 5.0 CoreMark/MHz，面积较小，适合存储控制器、工业物联网、监控实时分析和其他智能系统等数据密集型边缘设备。

在当时的 RISC-V 性能谱系中，大多数处理器核仍属于微控制器级 [12][15][19][33]；一些工作把 RISC-V 扩展到领域专用加速器或协处理器 [22][27]–[29]，但 64 位高性能端的选择很少。

阿里巴巴平头哥的玄铁产品系列是基于 RISC-V 的高性能嵌入式计算核。平头哥半导体是阿里巴巴集团面向集成电路设计的业务实体，目标是发展下一代云端一体芯片体系结构、数据中心和嵌入式物联网芯片。“玄铁”这一代号来自中国故事中的“玄铁重剑”。作者强调，这项工作的目的不是与市场上的非 RISC-V 处理器竞争，而是通过开源协作推动高端 64 位 RISC-V 体系结构。

论文发表时，只有 FPGA 版本利用定制扩展和向量扩展部署于阿里云数据中心进行专用加速，初始规模为数百套。Xilinx VU9P FPGA 实现在 Linux 下运行于 200 MHz。以区块链交易加速为例，作者称 FPGA 版本的单核性能仍比 Ubuntu 16.04 下运行于 2.5 GHz 的 x86-64 Intel Xeon Platinum 8163 高 20%。低成本 ASIC 版本已经流片，预计 2020 年 7 月获得芯片；作者预计其运行频率为 2.0–2.5 GHz，相应性能为该 Xeon 对照的 12–15 倍。

除内部使用外，阿里巴巴还推动玄铁核 IP 用于 AI、边缘服务器、工业控制和高级驾驶辅助系统等外部边缘计算应用，并准备开源玄铁。论文预计到 2022 年总出货量达到 1500 万颗，并给出当时的产品组合网站：https://www.t-head.cn/product 。

在此之前，SiFive U74 [6] 被作者视为当时性能最高的 RISC-V 应用处理器，最高达到 5.1 CoreMark/MHz，约与 ARM Cortex-A55 [1] 相当。XT-910 是一款采用 12 nm 工艺的 64 位 RISC-V 处理器，可扩展到 16 核，最高频率 2.5 GHz；支持乱序执行、三发射和 12 级流水；实现 RV64GCV，既支持 RV64G 基础 ISA、16 位压缩指令 C 和标准 32 位指令，也支持向量扩展；另含 50 多条非标准指令以加速不同任务。配套工具链也进行了大幅优化。作者报告 XT-910 达到 7.1 CoreMark/MHz，比 U74 高 40%。

本文后续结构如下：第二节概述 XT-910 架构；第三、四节分别介绍取指单元和执行核；第五节从硬件实现到 Linux 内存管理详细讨论存储子系统；第六节介绍多簇、多核 SMP；第七、八节介绍向量扩展与提高领域专用应用性能的非标准扩展；第九节说明优化编译工具链；第十节给出多项 benchmark 的实验结果；第十一节总结全文。

## 二、XT-910 架构总览

XT-910 完全遵循 RISC-V RV64GCV 指令集规范 [31]，支持标准用户态 U、监管者模式 S 和机器态 M 三种特权模式。RV64GCV 表示处理器实现：

1. 64 位 RISC-V 基础 ISA，即 RV64G；
2. 16 位紧凑压缩指令 C 与常规 32 位指令；
3. 当时仍在制定中的向量操作 V。

此外，XT-910 还提供 50 多条非标准指令以加速不同领域专用任务。

![图 1：U、S、M 特权模式](assets/xuantie910_papers/isca/fig01_privilege_modes.png)

**图 1 中文说明：** 用户态 U 执行用户进程；监管者模式 S 运行 hypervisor 或内核；机器态 M 可访问机器级资源并被视为固有可信的最高特权层。

XT-910 采用同构多簇架构。每个簇最多由 4 个核组成；每核支持 32/64 KB L1 指令 Cache 与 32/64 KB L1 数据 Cache。每簇共享一个包含式、8/16 路组相联 L2 Cache，容量最高 8 MB，并支持 ECC 和奇偶校验。处理器还支持独占内存访问指令、8 或 16 个 PMP 物理内存保护区域以及符合 RISC-V Linux 规范的 Sv39 MMU。LSU 支持非对齐数据访问。系统还包含标准 CLINT 和 PLIC 多核中断控制器、定时器、调试器、性能监控器和 I/O 从接口。

![图 2：四核配置的 XT-910 多核簇](assets/xuantie910_papers/isca/fig02_cluster.png)

**图 2 中文说明：** 每个核包括硬件辅助调试 HAD、分支预测、取指、译码、重命名、分派、发射队列、物理寄存器文件、写回、ALU、向量单元、FPU、分支跳转单元 BJU、LSU、MMU/TLB，以及私有 L1 I/D Cache。多个核经一致性总线连接并共享 L2。

### 表 I：XT-910 核配置

![表 I 原图](assets/xuantie910_papers/isca/table01_configurations.png)

| 特性 | 可配置项 |
|---|---|
| 每簇核心数 | 1、2、4 |
| L1 数据 Cache | 32 KB、64 KB |
| L1 指令 Cache | 32 KB、64 KB |
| L2 Cache | 256 KB–8 MB |
| 向量扩展 | 有或无 |

为了提高性能，XT-910 提供 RISC-V 向量扩展以及算术、位操作、load/store、TLB 和 Cache 操作等非标准定制扩展；还扩展 MMU，以支持基于页的内存属性管理，并扩展中断控制器以支持权限控制。所有扩展均由配套编译工具链支持。通过硬件配置可以禁用非标准扩展，使 XT-910 以完全兼容标准 RISC-V 的模式运行。

![图 3：单核与双核版图](assets/xuantie910_papers/isca/fig03_floorplans.png)

**图 3 中文说明：** 上图为带向量执行单元与 512 KB L2 的单核版图，下图为双核版图。

版图后仿真结果汇总于表 II。在 TSMC 12 nm FinFET 工艺下，不计 L2，带向量单元和不带向量单元的单核面积分别为 0.8 mm² 与 0.6 mm²。在 0.8 V VDD 下，使用 LVT 标准单元库和 ULVT SRAM，核心频率超过 2.0 GHz；若使用 ULVT 标准单元并把 VDD 提升至 1.0 V，即升压模式，可达到 2.5 GHz。另一次 7 nm FinFET 实验中，单核频率达到 2.8 GHz。

### 表 II：12 nm FinFET 下的 XT-910 核结果

![表 II 原图](assets/xuantie910_papers/isca/table02_12nm_results.png)

| 指标 | 结果 |
|---|---|
| 工作频率 | 2.0 GHzᵃ–2.5 GHzᵇ，TT、85 ℃ |
| 每核硅面积 | 不带 VEC 0.6 mm²；带 VEC 0.8 mm² |
| 动态功耗 | 约 100 μW/MHz/核ᶜ，TT、85 ℃ |

脚注：

- a：LVT 6T-turbo 标准单元、ULVT SRAM、0.8 V VDD。
- b：30% ULVT 标准单元、ULVT SRAM、1.0 V VDD。
- c：配置为 32/64 KB L1、256/512 KB L2，不含 VEC。

![图 4：XT-910 核的 12 级流水线](assets/xuantie910_papers/isca/fig04_pipeline.png)

XT-910 流水线的前端包含 IF 到 RF 共 7 级。IFU 使用混合预测器，预测分支方向、分支地址、函数返回地址和间接跳转地址。IDU 每周期可同时译码 3 条指令，并借助物理寄存器最多重命名 4 条指令。乱序发射引擎最多可发射 8 条指令。

后端包含多个执行单元：两个单周期 ALU、一个单周期分支跳转单元、一个双发射乱序 load/store 单元、两个标量浮点单元和两个向量执行单元。多周期 ALU 与除法单元共享一条执行管线；整数乘法单元与两个单周期 ALU 共用一条管线。LSU 支持非对齐访问和多模式、多流预取，以提高数据访问带宽。

### 教学解读：流水级、宽度和乱序窗口应当怎样理解

“12 级流水”“每周期译码 3 条”“最多重命名 4 条”“最多发射 8 条”描述的是不同维度，不能把这些数字当成同一种吞吐宽度，也不能据此断言处理器每周期能完成 8 条程序指令。

首先，流水级数描述一条指令从取指到退休所经过的时序阶段。流水更深，组合逻辑可被切得更短，通常有利于提高频率；代价是旁路、控制和恢复更复杂，分支误预测或异常清空可能损失更多周期。图 4 把 IF、IP、IB、ID、IR、IS、RF、不同执行路径、WB 和 RT 画在同一张时序图中。各类指令的执行延迟并不相同，因此“12 级”是对主流水组织的概括，不能把图上所有方框机械相加，得出每一类指令都具有完全相同的 12 周期延迟。

其次，各宽度位于不同流水位置：

- 128 位取指是每周期从 I-Cache 读取的比特数。若全部是 16 位压缩指令，理论上最多容纳 8 条；若全部是常规 32 位指令，则最多容纳 4 条。跨取指边界、控制流改变、I-Cache miss 和有效指令不足都会进一步降低实际条数。
- 每周期打包 8 条表示 IP 级具备识别和整理最多 8 条短指令的能力，不等于下游能同时执行 8 条。
- 每周期译码 3 条是稳定进入后端的主要前端宽度，通常更接近标量程序的长期吞吐上限之一。
- 最多重命名 4 条可能来自译码后内部表示、缓冲或特定拆分/融合路径。论文没有公开足够细节，不能仅根据 3 译码和 4 重命名推断具体实现。
- 最多发射 8 条指的是多个发射队列可在同一周期向不同执行端口选择多个已就绪的内部操作。ISA 指令可能拆成多个微操作，而且 8 个执行端口并非对任意操作都通用，因此这不是“任意 8 条指令”的承诺。
- 退休宽度在两份官方材料中没有明确给出。即使前面能够宽发射，最终持续 IPC 仍会受到退休带宽、ROB 头部阻塞和精确异常规则约束。

论文引言还把 XT-910 称为“triple-issue”，后面的架构章节和演示稿则写“最多发射 8 条”。原文没有给出足以统一两种口径的内部接口定义。较稳妥的理解是：三路描述前端稳定送入后端的宏观宽度，八路描述多个执行管线合计的峰值选择/发射能力；但这属于结合框图作出的解释，不能当成论文明确公布的接口规范。

本篇官方论文把 ROB 描述为最多容纳 192 条指令，本文在第一篇中保留这一官方口径，不用后来公开 RTL 的物理表项组织替换它。该容量用于扩大可观察的乱序窗口：当一条较老 load 等待较长访存延迟时，处理器可以继续观察后续指令，从中寻找与该 load 无关的工作。窗口越大，隐藏长延迟的机会通常越多，但也会增加面积、功耗、查找与恢复复杂度。若后续指令都依赖这条 load，或者发射队列、物理寄存器、LQ/SQ 先耗尽，再大的 ROB 也无法继续推进。公开 RTL 所见的 64 个物理表项及其与 192 条指令容量的关系，放在第三篇的独立核查说明中讨论。

因此，可把单线程性能粗略理解为下面这条受限链：

> 有效取指供给 → 译码与重命名 → 依赖唤醒和发射 → 执行端口 → Cache/TLB/内存 → 按序退休

长期 IPC 由链上最紧的环节以及错误推测造成的无效工作共同决定。判断瓶颈时，必须同时观察有效取指条数、分支误预测、队列占用、操作数未就绪、端口冲突、Cache/TLB miss、回放、ROB 头部等待和退休情况，而不能只看某一个峰值宽度。

## 三、取指单元

IFU 分为三个流水级：

1. **Instruction Fetch（IF，取指）：** 访问 L1 指令 Cache 获取指令，把虚拟地址转换为物理地址，并处理第一级分支跳转。单周期最多从 L1 Cache 取出 128 位指令行。
2. **Instruction Pack（IP，指令打包）：** 对指令打包和预处理，处理第二级分支跳转，并在 Cache miss 时回填 Cache line。每周期最多打包 8 条指令。后续 IDU 最多只译码 3 条，因此作者认为 IP 吞吐量不会成为性能瓶颈。
3. **Instruction Buffer（IB，指令缓冲）：** 缓存打包后的指令，每周期向 ID 级发送最多 3 条，并处理第三级跳转。

![图 5：XT-910 IFU 流水线](assets/xuantie910_papers/isca/fig05_ifu_pipeline.png)

**图 5 中文说明：** IF 级包含 PC 生成、IF 级控制流改变和 I-Cache；IP 级包含 IP 控制流改变和指令打包；IB 级包含 IB 控制流改变和指令缓冲。PC 分配与各级纠错形成反馈路径。

XT-910 使用混合多模式分支预测，覆盖绝对跳转、条件分支、间接分支和函数调用返回，同时预测方向和目标地址，使程序跳转尽可能早地发起，降低控制流改变导致的流水气泡。通过预测预取的指令全部缓存在 IBUF 中；预测正确时 IBUF 可以积累指令，因此即使发生 Cache miss，IFU 仍可能向后续 IDU 提供足够指令。

### A. 分支方向预测

为提高取指效率，IFU 尽量在最早流水级预测条件分支方向。IF 级捕获少数分支并立即处理跳转，使这些分支的延迟惩罚降为零；大部分条件分支在 IP 级捕获。预测依据分支历史，预测结果存放于多个存储体中，由动态监控算法选择最终结果。为保存大量预测值，这些存储体由高密度 SRAM 实现。

IF 级一次处理 128 位、最多 8 条指令，因此每周期取出的指令中很可能含条件分支，而且当前分支方向可能受前一分支影响。SRAM 存储体访问延迟较大，读出预测值后必须先进入寄存器才能使用。若把当前分支的预测方向作为后一分支的历史信息，就会增加一个周期延迟，导致相邻周期的条件分支无法连续处理。

XT-910 使用多级缓冲预取预测值。系统以模糊匹配方式提前从条件分支预测存储体读出可能的预测结果，缓存在 BUF1 和 BUF2。检测到分支时使用 BUF1 的值进行预测，并把 BUF2 中相关值上移到 BUF1，供下一周期分支使用。

![图 6：带两级缓冲的分支预测器](assets/xuantie910_papers/isca/fig06_branch_buffers.png)

这一机制还能在单周期预测多条分支。如果 128 位取指内容中含多条分支，第一条的结果来自 BUF1；根据该结果，可从 BUF2 获得第二条分支结果。更高级预取缓冲可以并行支持更多分支。若误预测，只有当分支到达分支跳转执行单元时才纠正；与在 IP 级执行跳转相比，至少造成 7 个周期的性能惩罚。

### B. 分支目标预测

只预测是否跳转还不够，目标地址同样重要。即便在 IP 级正确发起跳转，流水中仍会出现一个气泡；跳转过于频繁时，IFU 带宽无法满足后端需求。

为消除气泡，IFU 使用级联 BTB。L1 BTB 是主 BTB，拥有 1K 以上条目，采用组相联结构；L0 BTB 为 16 条目的全相联结构。若 IF 级命中 L0 BTB，就立即使用表中预测地址发起跳转，从而消除流水气泡。

L0 BTB 的方向和目标预测在 IP 级确认：方向由分支预测器检查，目标由 L1 BTB 检查。若 L0 BTB 误预测，IP 级立即纠正目标。传统设计通常在流水后段纠正 L1 BTB，XT-910 则在 IB 级检查 L1 BTB 目标并立即纠错。

多数情况下，IP 级跳转的损失可被 IBUF 中的预取指令隐藏。L0 BTB 主要捕获无法被隐藏的连续跳转程序：这类程序频繁在 IP 级跳转，IBUF 指令逐渐减少，最终无法遮蔽气泡。把这些分支缓存到 L0 BTB 后，可在 IF 级发起跳转。IFU 还包含间接分支预测器；子程序调用使用返回地址栈预测返回地址。

### C. 循环缓冲

为加速小循环取指，IFU 还提供 LBUF。小循环中频繁发生回跳；若在 IP 级执行跳转会插入气泡，而且当前迭代最后一条指令不能与下一迭代第一条指令同时发射。

LBUF 将完整循环体缓存起来，使当前迭代末指令与下一迭代首指令可以同时送入后续流水，从而尽量保持 IDU 每周期 3 条指令的供给。循环体允许前向分支，因此含 if-else 的小循环也可被加速。执行循环时无需访问 L1 指令 Cache，也可以降低功耗。XT-910 的 LBUF 有 16 个条目；发生上下文切换时清空。

![图 7：LBUF 对小循环的加速](assets/xuantie910_papers/isca/fig07_loop_buffer.png)

**图 7 中文说明：** 从 I-Cache 取指时，回跳会在相邻迭代间形成 bubble；从 LBUF 连续输出时，上一迭代尾部与下一迭代头部可连续打包，减少空槽。

### 教学解读：分支预测为什么决定前端有效带宽

取指前必须知道下一条 PC。顺序代码的下一地址容易计算，分支却同时提出两个问题：是否跳转，以及跳到哪里。条件分支方向预测器回答 taken/not-taken；BTB、间接跳转预测器和 RAS 分别帮助预测直接跳转目标、间接目标和函数返回地址。任何一个环节出错，都可能把错误路径指令送入后端。

L0 BTB 小而快，重点解决最早一级的低延迟目标供给；L1 BTB 容量更大，用来覆盖更多分支 PC。二者级联体现的是典型的容量与访问延迟权衡。方向预测表采用高密度 SRAM，可以保存更多历史，但读延迟不容易直接塞入最早预测级，所以设计又增加 BUF1/BUF2，把可能即将用到的预测值提前读出。这里的缓冲不是扩大指令 Cache，而是在时序压力下把预测信息提前送到关键路径。

IBUF 则解耦前端和后端的瞬时速度。前端供给充足时先积累指令；短暂 I-Cache miss 或一次较晚的跳转修正发生时，后端仍可能从 IBUF 取到已有指令。不过，缓冲只能吸收短期波动，不能弥补长期平均供给不足。若错误路径填满缓冲，或连续跳转反复打断取指，缓冲中的内容也可能失效。

LBUF 针对短循环采用另一种办法：把循环体留在专用缓冲中，避免每轮重新访问 I-Cache，并让上一轮末尾与下一轮开头连续供给。它主要改善“小而热、反复执行”的循环；对于超过 16 项容量、控制流复杂或频繁退出的循环，收益会下降。

评价这套前端不能只看总分支准确率。至少应区分条件分支、直接跳转、间接跳转和 return，并同时统计：每千条指令误预测数、误预测恢复周期、BTB miss、RAS 错误、I-Cache/TLB miss、IBUF 空周期、每周期有效取指/译码条数，以及错误路径上被清除的指令数。总准确率可能很高，但一个低频、惩罚很大的间接分支仍可能主导性能。

## 四、执行核

执行核包括 ID、IR、IS、RF、EX1–EX4 与 RT1–RT2。IDU 覆盖 ID 到 RF：

- ID 级分解和译码指令，根据指令类型、操作数数量和写回数量等属性拆成微指令，并支持标量与向量指令的零延迟解耦。
- IR 级用物理寄存器重命名 GPR、FGPR 和 VGPR 操作数，对标量整数、浮点和向量寄存器都进行重命名。重命名既处理数据依赖，也消除高成本 move 指令。XT-910 推测性分配物理寄存器；指令写回完成并退休后释放物理寄存器。
- IS 级执行乱序调度。处理器有 8 个由全部已发射指令共享的指令槽。多个独立乱序发射队列依据执行单元资源和负载装入指令；发射队列使用基于年龄向量的调度算法，并通过监控流水负载实时调整优先级，实现动态负载平衡。

EX 级包含 8 条执行管线，可并行处理 2 条算术指令、1 条分支、1 条 load、2 条 store（原文称“伪双 store”，第五节详述），以及 2 条标量浮点或向量指令。

RT 级负责写回与退休。RTU 按程序顺序退休指令并释放物理寄存器。虽然执行是乱序的，为保证正确性仍必须顺序退休，这由最多容纳 192 条指令的 ROB 实现。若一条指令发生异常，它必须到达退休点，且后续推测执行指令会从流水中清除。

![图 8：指令执行异常后的推测失败恢复](assets/xuantie910_papers/isca/fig08_recovery.png)

**图 8 中文说明：** 左侧表示退休级事件或跳转误预测触发前端与后端清空；右侧表示 BHT 误预测被取消，并依次清空前端、发射级和后端。两者都展示了异常或错误推测后恢复按序状态的控制过程。

### 教学解读：乱序执行真正解决的是“等待期间还能做什么”

乱序执行不会改变程序可见的结果。它把“执行顺序”和“提交顺序”分开：只要操作数和执行端口已经就绪，年轻指令可以先执行；但所有指令仍通过 ROB 按程序顺序退休。这样既能利用不同指令之间的并行性，又能在异常、分支误预测或访存次序推测失败时恢复精确状态。

寄存器重命名把同一个架构寄存器的不同逻辑版本映射到不同物理寄存器，从而消除 WAR 和 WAW 伪依赖。例如两条互不相关的指令都写 a0 时，重命名后可以写入不同物理寄存器。RAW 真依赖不能被重命名消除：消费者仍必须等待生产者的结果。发射队列中的 not-ready 指令，本质上可能在等待整数、乘除法、浮点、向量或 load 的结果；只有进一步按生产者类型和等待时长分类，才能判断问题来自长依赖链、Cache miss，还是唤醒/旁路时序。

年龄向量帮助调度器在多个就绪候选中优先选择较老指令，减少 ROB 头部长期得不到执行的风险。但调度还必须服从端口约束。例如两条指令都只能进入同一乘法管线，即使它们都已就绪，也不能凭借“8 发射”在一个周期同时执行。由此要区分三类等待：操作数未就绪、目标执行端口忙、后端结构资源已满。

恢复机制是乱序核正确性的核心。分支执行后发现方向或目标错误，必须撤销更年轻的错误路径状态，并从正确 PC 重新取指；异常通常等到相关指令到达 ROB 头部再精确处理。图 8 展示的是恢复控制路径，不表示所有异常都具有完全相同的固定惩罚。实际代价取决于错误被哪一级发现、错误路径已经深入多少、前端重新供给需要多久，以及 Cache/TLB 状态是否可复用。

## 五、存储子系统

### A. 双发射乱序 LSU

作者称 XT-910 是当时唯一支持双发射乱序 LSU 的 RISC-V 处理器。LSU 可并行处理一条 load 与一条 store，因此设置独立 load 管线和 store 管线。每条管线都含地址生成 AG、数据 Cache DC、数据对齐 DA 和写回 WB 四级：

- AG：生成 load/store 地址，访问 uTLB，把虚拟地址转换为物理地址。
- DC：访问数据 Cache。
- DA：完成数据对齐。
- WB：把数据写回物理寄存器文件。

![图 9：LSU 流水级](assets/xuantie910_papers/isca/fig09_lsu_pipeline.png)

数据 Cache 系统包含 load 管线使用的 DATA RAM 和 LD TAG RAM，并为 store 管线增加独立 ST TAG RAM；load 与 store 分别访问各自 RAM。为了正确乱序执行，LQ 和 SQ 维护内存指令顺序并检查地址依赖。

执行 load 时，检查 SQ 中所有更早 store；地址相同的 store 数据会转发给 load。执行 store 时检查 LQ；若发现同地址、更年轻的 load 已提前执行，则内存推测失败并产生全局 flush。为减少推测失败损失，XT-910 预测并标记可能冲突的 load/store，在执行单元中阻塞相应 load，保证它不会越过相关 store。

### B. 伪双 store 指令

为了加速 store，指令进入队列前拆成两个微操作：

- st.addr：保存 store 的地址部分，用于地址生成和 Cache 查询；从共享 load/store 发射队列进入 store 地址管线。
- st.data：保存 store 的数据部分，用于读取操作数；从专用 store-data 发射队列进入 store-data 管线，访问物理寄存器文件并接收执行单元转发。

两者经过各自管线后，在 SQ 的写缓冲中合并，再写入数据 Cache 或片外存储。地址与数据分离后，地址生成和 Cache 访问可以更早开始。

![图 10：LSU 中独立的地址流和数据流](assets/xuantie910_papers/isca/fig10_lsu_addr_data.png)

### 教学解读：内存乱序、转发与地址/数据拆分

存储指令的困难在于，寄存器依赖在重命名时就能看见，而两次访存是否指向同一地址，往往要等地址生成后才知道。处理器希望让年轻 load 越过尚未完成的旧 store，以便尽早获得数据；但若二者后来被证明访问同一地址，就必须保证 load 读到正确的 store 数据。

SQ 保存较老 store 的地址和数据。load 地址产生后，会查询更老的 SQ 项：若地址匹配且 store 数据已经就绪，可直接进行 store-to-load forwarding；若地址尚未知或数据未就绪，处理器需要等待、预测无冲突后继续，或者在稍后发现冲突时回放/清空。论文所说的“推测失败预测”就是试图提前识别高风险 load/store 对，减少先执行后撤销的代价。

把 store 拆为 st.addr 和 st.data，是因为地址依赖链与数据依赖链常常不同。地址可能很早就由基址加偏移得到，而待写数据仍在等待前序计算；也可能相反。拆开后，地址侧可以先完成 TLB、Cache tag 和冲突检查，数据侧独立等待真实数据，最终在 SQ 中合并。这会增加内部微操作和队列管理复杂度，却能提高调度自由度。因此，“伪双 store”不是每周期向 Cache 独立提交两个完整 store，而是地址微操作与数据微操作可占用两条不同路径。

Hot Chips 所称 3 周期 load-to-use，是在命中和旁路条件满足时，从 load 发起到消费者可使用结果的核心延迟；它不包含 D-Cache miss、TLB miss、Bank 冲突或回放。“store 执行为 1 周期”同样主要描述地址/数据处理路径的局部能力，不代表数据在 1 周期后已经对其他核心或外部内存全局可见。

### C. 多模式、多流数据预取

高性能应用中，存储带宽和延迟与处理器速度之间存在巨大差距。多级 Cache 虽能减轻 memory wall，但数据复用次数很少或 Cache 容量不足时仍会受限。

XT-910 使用多模式、多流数据预取。它对数据流做模式匹配，把数据提前填入 L1 或 L2，降低长存储延迟导致处理器停顿的概率。支持两种模式：

1. **全局预取模式：** 适合简单、连续的数据流，支持任意 stride，最大预取深度 64 条 Cache line。
2. **多流预取模式：** 适合复杂场景，最多支持 8 条不同 stride 的数据流，最大预取深度 32 条 Cache line。

![图 11：多模式、多流数据预取](assets/xuantie910_papers/isca/fig11_prefetch.png)

预取分三步：

1. **计算 stride：** 从 load 地址中发现正确访问模式。
2. **预取控制：** 决定策略并评估置信度。策略设置预取深度并动态启停，避免过度预取污染 Cache，也避免预取过慢。置信度判断当前策略是否准确，以及是否需要修改或放弃。
3. **实际执行：** 发起多流数据预取，并支持虚拟地址跨页预取。到达页边界时自动请求下一虚拟页转换，获得物理页地址后继续预取。

### 教学解读：预取器应从四个维度评价

预取不是“开得越深越好”。一个预取器至少需要同时评价四个维度：

1. **覆盖率：** 原本会发生的 demand miss 中，有多少被预取消除。覆盖率低说明仍有大量真实 miss 未被识别。
2. **准确率：** 发出的预取中，有多少数据后来确实被程序使用。准确率低会浪费带宽和 MSHR，并污染 Cache。
3. **及时性：** 有用数据是否在 demand load 到来前已经进入合适层级。预取正确但到得太晚，仍然无法隐藏延迟；到得过早，又可能在使用前被替换。
4. **污染与带宽代价：** 预取是否挤掉更有用的 Cache line，是否阻塞真正的 demand 请求，是否增加片上互连和 DDR 流量。

全局模式适合一条或少数规则 stride；多流模式允许同时跟踪多个访问序列，更适合交错数组或多个循环流。所谓预取深度是向当前需求地址前方探索的 Cache line 数量，不等于同时一定存在相同数量的未完成请求。最佳距离取决于处理器频率、内存延迟、循环每次迭代的计算量和可用带宽。

### D. 多页大小、多级 TLB

XT-910 在各级 TLB 中都支持 4 KB、2 MB 和 1 GB 页。uTLB 与 jTLB 的每个条目都包含页大小属性。访问全相联 uTLB 时，请求虚拟地址与所有条目的 VPN 比较；uTLB miss 后把虚拟地址送到 jTLB。

jTLB 为四路组相联，同一时刻只能使用一种页大小对应的索引。它依次尝试 4 KB、2 MB、1 GB 索引；命中后把对应条目回填 uTLB，三种页大小均 miss 时触发页表遍历。

![图 12：多页大小、多级 TLB](assets/xuantie910_papers/isca/fig12_tlbs.png)

### E. Linux 操作系统中的内存管理

为满足 Linux 内存管理要求，XT-910 增加了多条指令来提高 MMU 与 Cache 一致性：

1. 可指定 ASID、页表基址或虚拟地址，并通过互连总线广播 TLB 维护信息。CPU 核和总线上的其他外设 IP 可解析这些信息并维护各自 MMU。相比 IPI 方案，维护由硬件完成，无需软件干预。
2. 支持 Linux 降低 TLB miss 所需的 huge page [3]。MMU 提供三级页表，每一级都可作为叶子条目，同时覆盖 4 KB、2 MB、1 GB 页。
3. ASID 扩展到 16 位。ASID 溢出时才需要清空 TLB；测试显示，16 位 ASID 显著延长溢出时间，使上下文切换引起的 TLB flush 次数降低近 10 倍。

### 教学解读：TLB 为什么是 Cache 之外的第二条访存关键路径

L1 D-Cache 通常使用虚拟地址的页内偏移进行快速索引，但权限检查、tag 比较或继续访问更低层级仍需要物理地址。TLB miss 即使最终数据命中 Cache，也可能因页表遍历而产生很长延迟。因此分析访存瓶颈时，D-Cache miss 和 TLB miss 必须分开统计。

uTLB 小而全相联，目标是用低延迟覆盖最常用的转换；jTLB 更大、四路组相联，承担容量后备。4 KB、2 MB 和 1 GB 页的页内偏移位数不同，所以 jTLB 对三种页大小使用不同索引并依次尝试。大页可用一个 TLB 项覆盖更多地址，减少大工作集的 TLB miss，但会增加内存分配粒度、碎片和系统管理约束。

ASID 让不同进程的地址转换可以同时保留在 TLB 中。16 位 ASID 降低了标识符重复使用的频率，进而减少全量 TLB flush。论文中“降低近 10 倍”描述的是作者测试环境下的 flush 次数，不等于所有程序的执行时间都会提高 10 倍；实际收益取决于上下文切换频率、工作集、TLB 容量与页表遍历代价。

## 六、多核体系结构

XT-910 采用 SMP 多核架构。最多 4 个核组成一个 CPU 簇，最多 4 个 CPU 簇通过 Ncore 互连。簇内核心通过带一致性协议的内部总线连接，共享最大可配置到 8 MB 的包含式 L2 Cache。

原文称 L2 支持 “MOSEI” 一致性协议；这很可能是 MOESI 的字母顺序笔误，Hot Chips 演示稿明确写作 MOESI。系统还包含 snoop filter，监控各核对共享 L2 的访问，以减少核间通信。

![图 13：多核实现框图](assets/xuantie910_papers/isca/fig13_multicore.png)

**图 13 中文说明：** 图中给出最多四簇的连接方式。簇内四核连接一致性代理和共享 L2 slice；多个 CPU 簇通过 Ncore 与外部 NPU、DDR 等模块互连。

### 教学解读：共享包含式 L2 与目录一致性的权衡

包含式 L2 意味着私有 L1 中存在的 Cache line，通常也必须在共享 L2 中保留对应记录。这样做便于把 L2 tag 当作侦听过滤信息：若 L2 表明某地址不在任何上层 Cache，就可避免向所有核心广播无效查询。代价是 L2 的有效容量不仅服务数据复用，还要容纳 L1 内容；当 L2 驱逐某条 line 时，可能需要同步使上层副本失效。

MOESI 状态用于描述一个 Cache line 在多个核心中的所有权和共享关系。目录记录哪些核心可能持有副本，snoop filter 据此缩小侦听范围。二者的目标不是消除一致性通信，而是减少不必要的广播和能耗。随着核心与簇数量增加，一致性目录容量、跨簇延迟、共享数据乒乓、L2 bank 冲突和内存带宽都会成为扩展瓶颈。

因此，多核性能不能用单核 IPC 乘以核心数直接估算。应分别观察单线程延迟、私有 Cache miss、共享 L2 命中、目录/侦听流量、互连拥塞、内存带宽、锁竞争和跨簇访问距离。论文主要给出结构能力，没有提供完整的多核扩展曲线。

## 七、向量指令扩展

XT-910 是最早采用 RISC-V Vector Extension 提案的商用处理器之一。向量引擎显著提高向量处理性能，尤其面向 AI 和机器学习应用。

与 ARM NEON、Intel SSE/AVX 等定长 SIMD 相比，ARM SVE 和 RISC-V Vector Extension 等变长向量指令集既允许硬件灵活选择参数，也提高上层软件跨不同硬件平台的可移植性。基于 RISC-V Vector 0.7.1 稳定版本，XT-910 支持双发射乱序向量指令执行。

XT-910 使用 64 位标量流水线。按规范，向量流水线支持 8–64 位整数元素，以及 FP16、FP32、FP64 向量浮点运算。向量流水由多个相同 slice 组成，每个 slice 具有完整 64 位数据通路，包括多端口 64 位向量物理寄存器文件和两条乱序向量浮点/整数执行管线。每条管线可执行：

- 一路 64 位整数或双精度浮点运算；
- 两路 32 位整数或单精度浮点运算。

每个 slice 拥有独立寄存器、旁路和执行数据通路，只有 widening、narrowing、permutation 等少数操作需要跨 slice 交换数据。

![图 14：流水化向量运算体系结构](assets/xuantie910_papers/isca/fig14_vector_pipeline.png)

以 slice 为基础的架构可降低位宽增大造成的布局布线代价。XT-910 可支持 64–1024 位运算宽度，但深流水、乱序、多核处理器的最大 load/store 位宽会受到总线和 Cache 架构限制；更大位宽也会增加访存成本并加剧 Cache 一致性问题。

为了平衡算术逻辑位宽与 load/store 位宽，论文建议配置两个 VLEN=128、SLEN=128 的向量 slice。此配置下，XT-910 每周期产生共 256 位运算结果，并完成 128 位向量 load/store。

向量运算指令本身不指定元素格式和运算位宽，而由 vsetvl/vsetvli 配置。配置指令只需指定待处理元素数，硬件结合 VLMAX 决定实际运算宽度和元素数，使软件无需了解底层硬件参数，也能运行于不同计算位宽的平台。

这一机制对深流水不够友好：每条向量运算必须与前面的参数配置指令建立关联，拖慢执行。XT-910 因此预测向量参数并推测执行向量运算；只有 vl 变化时才产生推测失败。

多数向量操作在 3–4 周期完成；单精度与双精度向量乘法为 5 周期；整数除法和浮点除法为 6–25 周期。

### 教学解读：256 位计算宽度不等于每周期搬运 256 位数据

两个 128 位 slice 合起来可形成每周期 256 位的计算吞吐，但论文同时给出每周期 128 位向量 load/store。这里要区分计算带宽和访存带宽：若数据已在向量寄存器中并能被反复使用，两个 slice 可以持续并行计算；若每次计算都必须装入新数据，128 位访存路径可能先成为限制。实际性能还受到元素宽度、指令组合、数据重用、Cache 命中率、跨 slice 重排和依赖链影响。

以 Hot Chips 给出的每簇 FP16 峰值为例，每核每周期 32 FLOP、2.5 GHz、4 核相乘得到 320 GFLOPS，因而写作“超过 300 GFLOPS”。这里把一次 FMA 计为一次乘法加一次加法，即 2 FLOP；它是理论峰值，不包含 load/store、分支、配置指令和利用率损失。

变长向量 ISA 的核心价值是同一程序不把硬件向量寄存器长度写死。软件通过 vsetvl/vsetvli 表达剩余元素数和元素类型，硬件返回本轮实际处理长度，循环继续处理余数。XT-910 实现的是 Vector 0.7.1，而今天常见的软件工具链主要面向后来定稿的 Vector 1.0；二者在指令编码和部分语义上存在差异，不能把现代 V 扩展二进制直接当成该实现可执行程序。

## 八、非标准指令集扩展

为面向不同工业应用，XT-910 在标准 RISC-V 之外提供一组定制非标准指令，可按目的分为访存增强和基础算术增强。

### A. 访存增强

访存指令通常占动态指令的较高比例，增强它们可直接改善整体性能。作者分析主流 RISC-V 应用后认为，基础 RISC-V 访存相关指令仍有较大改进空间：

1. 支持“寄存器 + 寄存器”寻址，以及 indexed load/store，减少地址计算使用的寄存器和指令数量，从而加速循环体数据访问。
2. 支持地址生成时的无符号扩展。基础指令集不能直接把 32 位数据零扩展到 64 位，会产生较多移位指令。

### B. 算术运算增强

安全加密、音视频编解码等领域负载具有不同算术需求。例如加密算法频繁对数据中的特定字节或字段执行 shift、and、or 等操作。XT-910 因此扩展了一系列位操作、乘法和乘加指令。

### 教学解读：定制指令的收益必须拆成三部分

一条定制指令可能从三个方向带来收益：减少动态指令数，缩短关键依赖链，或把原本需要多个通用执行步骤的操作映射到专用硬件。收益是否能实现，还取决于编译器能否识别模式、寄存器和立即数字段是否合适、执行端口是否足够，以及新指令是否增加关键路径。

定制扩展也有成本。软件需要特定编译器和运行库，二进制可移植性下降；硬件要增加译码、验证、异常、调试和性能监控支持。公平评价时应至少给出“标准 ISA + 标准编译器”“标准 ISA + 优化编译器”“扩展 ISA + 优化编译器”三组结果，才能把编译优化收益和新硬件指令收益分开。论文图 20 把指令扩展与优化编译器合并比较，因此约 20% 不能全部归因于某一条或某一类定制指令。

## 九、优化工具链

平头哥发布面向 XT-910 的综合集成开发环境 CDS，提供 RISC-V 图形化 trace、profiling、指令精确模拟器和 JTAG 在线调试，并完整支持 GNU 官方编译工具集。

![图 15：编译工具链](assets/xuantie910_papers/isca/fig15_toolchain.png)

**图 15 中文说明：** 输入可为 C/C++、汇编以及库、目标或数据文件。GCC 前端包含预处理器、运行时库、指令映射、优化 pass、调用约定和流水调度；Binutils 包含汇编器、链接器和 CPU BFD；输出为 ELF/HEX、库/目标文件与 map/symbol 文件。

![图 16：XT-910 性能分析工具](assets/xuantie910_papers/isca/fig16_profiling_tool.png)

**图 16 中文说明：** 工具界面同时展示函数占比、IPC/Cache/分支预测仪表、指令计数、时间线和逐条执行信息，用于定位热点和微结构事件。

编译器与硬件协同优化包括：

1. RISC-V 在 32 位到 64 位转换时使用符号扩展。当时的现有编译器不支持 induction variable 优化，循环展开后仍包含索引自增和分支，显著降低效率。XT-910 编译器提取循环变量，把自增变量和控制代码移出循环，减少总动态指令数。
2. RISC-V 规定 global pointer 指向固定内存地址，一些变量可通过“全局指针 + 偏移”直接 load/store。编译器一般把较小变量放在 GP 可达区域，但若连续访问一个小变量和一个大变量，两者地址可能相距很远，破坏数据局部性。XT-910 编译器采用 anchor 方案，把同一函数的变量连续分配，将区域起始地址保存在寄存器中，再以偏移访问。
3. 原文称当时已有 RISC-V 编译器不支持 Dead Store Elimination，XT-910 编译器则支持 DSE。

### 教学解读：编译器也是微结构供给链的一部分

硬件峰值只有在编译器生成合适指令序列时才能转化为应用性能。循环变量提取和 DSE 主要减少动态指令；anchor 布局改善地址生成和局部性；指令选择利用定制操作；调度则尽量把相互独立的操作拉开，隐藏执行与 load-to-use 延迟。这些优化会同时改变前端压力、寄存器需求、分支频率、Cache 行为和后端依赖。

因此比较两个处理器时，只写 -O2 并不足以证明软件条件完全相同。编译器版本、目标架构参数、调优参数、链接库、是否使用 PGO/LTO、ISA 扩展、代码模型和 benchmark 规则都会影响结果。论文中的 A73 使用 GCC 6.3，XT-910 使用 GCC 8.1；作者对齐了 Cache 容量和 -O2，但编译器代际与 ISA 后端仍不同，这是阅读横向比较时必须保留的变量。

## 十、实验结果

作者使用一系列面向嵌入式 CPU 的工业 benchmark 评估性能。

### A. CoreMark

CoreMark 包含链表处理（查找与排序）、矩阵操作、状态机（判断输入流是否包含有效数字）和 CRC。作者认为它基本全部命中 Cache，几乎不受 DDR 延迟影响，主要评估核心本身。

![图 17：CoreMark 分数](assets/xuantie910_papers/isca/fig17_coremark.png)

XT-910 达到 7.1 CoreMark/MHz，比作者当时认为市场上性能最高的 RISC-V 处理器 SiFive U74 高 40%。作者提到即将发布的 SiFive U84，但投稿时没有官方产品数据，无法在不知道评测条件、硬件配置和编译细节的情况下比较。

论文以 ARM Cortex-A73 [2] 为参考，因为当时缺少同类高性能 RISC-V 的公开 benchmark。作者认为 Cortex-A73 与 XT-910 在流水级数、发射宽度等方面有许多相似性，便于从 ISA 层面分析 ARM 与 RISC-V 的差异。

实验中的 Cortex-A73 来自华为 Kirin 970，使用 Linaro GCC 6.3-2017.02，配置 64 KB L1 I-Cache、64 KB L1 D-Cache和指令/数据共享 2 MB L2。为公平比较，XT-910 使用相同 L1/L2 容量，编译器为 GCC 8.1，优化选项为 -O2。

作者特别声明，这些 benchmark 结果并不意味着 XT-910 已经达到旗舰 Cortex-A73 的完善程度；XT-910 当时刚推出，仍需要多年开放协作来覆盖大量边界情况。

### B. EEMBC

论文将 EEMBC 描述为面向自动驾驶、物联网、移动设备等硬件与软件的 benchmark，并把结果归一化到 ARM Cortex-A73。

![图 18：EEMBC 性能，归一化到 Cortex-A73](assets/xuantie910_papers/isca/fig18_eembc.png)

图中四类为 automotive、consumer、networking 和 telecom。XT-910 在四组中均高于或接近 A73，其中 telecom 的相对提升最明显。

### C. NBench

原文称 NBench 是面向 .NET 应用的性能测试框架。图 19 给出 Assignment、Bitfield、Fourier、FP Emulation、Huffman、IDEA、LU Decomposition、Neural Net、Numeric Sort 和 String Sort 十个子项，并归一化到 Cortex-A73。作者结论是 XT-910 整体与 Cortex-A73 相当。

![图 19：NBench 性能，归一化到 Cortex-A73](assets/xuantie910_papers/isca/fig19_nbench.png)

### D. SPECInt2006

作者运行了 SPECInt2006。该套件使用大型程序，频繁产生 L2 miss，综合反映核心性能、Cache 容量、Cache miss 和 DDR 延迟。XT-910 为 6.11 SPECInt/GHz，比 Cortex-A73 的 6.75 SPECInt/GHz 低 10%。

### E. 指令扩展与编译器优化收益

与原生 RISC-V ISA 和标准编译器相比，开启指令扩展与优化编译器后，XT-910 性能约提高 20%。

![图 20：指令扩展与优化编译器带来的性能提升](assets/xuantie910_papers/isca/fig20_extensions.png)

**图 20 中文说明：** EEMBC、NBench 和 OpenSSL 都以原生 RISC-V ISA 与标准编译器的 100% 为基线，扩展指令和优化编译器约达到 120%。

论文未给出 AI 实例加速数据，但指出 XT-910 支持 RISC-V Vector 0.7.1，而 Cortex-A73 使用 NEON。以 16 位乘加为例，作者称 Cortex-A73 支持 8 路 16 位 MAC，XT-910 支持 16 路 16 位 MAC，理论算力提高 1 倍；XT-910 还支持 A73 不支持的半精度运算，因此作者预计 AI 场景差距更大。

### F. 预取对存储子系统的影响

作者用 stream 测试内存访问与预取性能，以所有预取关闭的场景 a 为 1：

- a：L1、L2、TLB 预取全部关闭。
- b：只开 L1 预取，关闭 L2/TLB，配置较短预取距离；性能提高到 3.8 倍。
- c：打开 L1、L2、TLB，仍使用较短距离；提高到 4.9 倍。
- d：L1、L2、TLB 全开，预取距离从短调到长；最高达到 5.4 倍。
- e：保持 d 的其他配置，只关闭 TLB 预取；性能下降约 2.4%。

![图 21：预取对存储子系统性能的影响](assets/xuantie910_papers/isca/fig21_prefetch_results.png)

实验来自 HAPS80-S26 FPGA。由于内存访问延迟直接影响结果，作者通过总线与 DDR 延迟把一次内存访问调到约 200 个 CPU 周期，即 CPU 发出读请求后约 200 周期从总线获得数据。FPGA 测试中的 CPU 频率为 60 MHz。

### 教学解读：如何正确阅读论文中的性能图

这些结果回答的问题不同，不能混成一个“处理器快多少”的结论：

- CoreMark/MHz 主要观察小工作集下的核心与编译代码效率。按 MHz 归一化消除了频率，却没有消除编译器、ISA 扩展、Cache 配置和内存系统差异。
- EEMBC 和 NBench 展示的是相对 A73 的归一化柱状图。归一化适合看各子项相对趋势，但没有原始执行时间和误差时，无法从图中恢复绝对性能，也不能把多个柱简单做算术平均。
- SPECInt2006 更接近大程序综合性能，论文只报告 6.11 与 6.75 SPECInt/GHz，没有在正文完整披露每个子项、base/peak、迭代、编译 flags、内存时序和合法运行记录。因此它可以说明作者报告的总体差距，不能替代可复现实验档案。
- Stream 预取实验有意把存储访问设置为约 200 个 CPU 周期，形成强存储延迟压力。5.4 倍说明预取在这个特定条件下能隐藏大量延迟，不代表普通应用、ASIC 频率或不同 DDR 系统都会获得同样倍数。
- 0.6/0.8 mm²、2.0–2.5 GHz 和约 100 μW/MHz 来自指定 12 nm 工艺、标准单元/SRAM 阈值、电压、温度与配置。PPA 比较必须同时控制工艺节点、宏单元、Cache 是否计入、目标频率和活动率。

从体系结构实验方法看，最可靠的做法是先固定软件与平台，取得全套基线，再进行单变量对照。例如关闭/开启某一级预取器，同时记录 IPC、L1/L2 miss、TLB miss、预取准确率、带宽和污染；或者固定二进制，只改变分支预测配置，同时记录 MPKI、恢复周期和错误路径指令。这样才能建立“机制变化 → 微结构事件变化 → 周期变化 → 总性能变化”的因果链。

## 十一、结论

论文介绍了 XT-910：一款深流水、乱序、高性能、64 位、嵌入式、多簇多核 RISC-V 处理器。它基于 RV64GCV，并通过定制扩展增强向量与算术运算、位操作、load/store、TLB 和 Cache。每簇包含 1–4 个可启动 Linux 的核，并支持带 Cache 一致性的多核多簇系统。

单核采用 12 级流水、乱序、多发射超标量架构，在 TSMC 12 nm FinFET 的典型工艺与温度条件下最高达到 2.5 GHz。不含 L2，带/不带向量单元的单核面积分别为 0.8/0.6 mm²。工具链经过大幅优化以支持定制扩展。作者认为通过软硬件协同设计，XT-910 在当时多项工业控制流与数据计算 benchmark 上取得了 RISC-V 家族前代中最高的 IPC、速度和能效。

自 2019 年 7 月正式发布后，XT-910 FPGA 已部署到阿里云数据中心，通过把服务器任务卸载到 FPGA 并利用定制和向量扩展实现专用加速。ASIC 已经流片，计划在芯片 bring-up 后部署；IP 也被数十家外部客户用于边缘和物联网端点。团队当时正增强多核扩展、并行计算和功能安全。

作者认为，相比 ARM，RISC-V ISA 在体系结构上更简洁，可降低译码、执行和工具链复杂度；其模块化允许通过不同子集组合，在不同应用中灵活权衡功耗、面积和性能。但 RISC-V 中的位操作、trace、虚拟化等提案当时尚未完全定型，而 ARM 已有成熟功能。

XT-910 的研发使作者形成以下判断：

1. RISC-V 不仅适合低功耗、低成本嵌入式 MCU，也适合高性能计算；基于 RV64GC 的 XT-910 在多种通用应用上已达到主流架构商用核心的性能。
2. RISC-V 向量扩展适合 AI 和机器学习。
3. RISC-V 的潜力不限于边缘计算；其灵活性和可定制性也适合数据中心，尤其适合后摩尔时代可伸缩的领域专用加速器。

作者引用一句归于达尔文的话：“生存下来的不是最强壮、也不是最聪明的物种，而是最能适应变化的物种。”作者认为这一理念同样适用于计算体系结构。不过，演进中的 RISC-V 在技术和生态方面仍不成熟。团队积极参加 RISC-V 基金会标准化，并与技术组讨论 XT-910 的有效定制扩展；Cache 操作等扩展已受到关注，并被考虑纳入未来标准 ISA。

为了与其他主流高性能架构竞争，RISC-V 社区需要保持 ISA 一致性，并通过软硬件协同设计共同创新。

## 致谢

作者感谢阿里巴巴平头哥事业部 CPU 硬件和软件工程团队付出的巨大努力，也感谢阿里云基础设施与服务事业部的大力支持。

## 参考文献

以下保留原论文的编号、作者、出处和链接，并将题目译为中文。参考文献 [1]、[2] 的 Arm URL 已去掉原 PDF 中 `utm_*`、`gclid` 等广告追踪查询参数，目标产品页面不变；这属于链接清理，不删除文献内容。

1. ARM，《Cortex-A55 CPU》，https://www.arm.com/products/silicon-ip-cpu/cortex-a/cortex-a55 。
2. ARM，《Cortex-A73 CPU》，https://www.arm.com/products/silicon-ip-cpu/cortex-a/cortex-a73 。
3. Red Hat，《Red Hat Enterprise Linux 性能调优指南》，https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/performance_tuning_guide/ch-intro#idm140449023557936 。
4. 《PULP 平台》，https://pulp-platform.org/ 。
5. 《Shakti 处理器计划》，https://shakti.org.in/ 。
6. SiFive，《U74 标准核》，https://www.sifive.com/cores/u74 。
7. Intel Corporation，《Intel 64 与 IA-32 架构优化参考手册》，技术报告，2011 年 6 月，http://www.cs.princeton.edu/courses/archive/spr15/cos217/reading/ia32opt.pdf 。
8. 《NVIDIA 中的 RISC-V》，第六届 RISC-V Workshop，上海，2017。
9. K. Asanović、R. Avizienis、J. Bachrach、S. Beamer、D. Biancolin、C. Celio、H. Cook、D. Dabbelt、J. Hauser、A. Izraelevitz、S. Karandikar、B. Keller、D. Kim、J. Koenig、Y. Lee、E. Love、M. Maas、A. Magyar、H. Mao、M. Moreto、A. Ou、D. A. Patterson、B. Richards、C. Schmidt、S. Twigg、H. Vo、A. Waterman，《Rocket Chip 生成器》，加州大学伯克利分校 EECS 系技术报告 UCB/EECS-2016-17，2016 年 4 月，http://www2.eecs.berkeley.edu/Pubs/TechRpts/2016/EECS-2016-17.html 。
10. C. Celio、D. A. Patterson、K. Asanović，《Berkeley 乱序机器 BOOM：具有产业竞争力、可综合、可参数化的 RISC-V 处理器》，加州大学伯克利分校 EECS 系技术报告 UCB/EECS-2015-167，2015 年 6 月，http://www2.eecs.berkeley.edu/Pubs/TechRpts/2015/EECS-2015-167.html 。
11. J. Feehrer、S. Jairath、P. Loewenstein、R. Sivaramakrishnan、D. Smentek、S. Turullols、A. Vahidsafa，《Oracle SPARC T5 16 核处理器扩展到八路插槽》，IEEE Micro，33(2)，48–57，2013 年 3 月，http://ieeexplore.ieee.org/document/6493301/ 。
12. E. Flamand、D. Rossi、F. Conti、I. Loi、A. Pullini、F. Rotenberg、L. Benini，《GAP-8：面向 IoT 边缘 AI 的 RISC-V SoC》，第 29 届 IEEE 专用系统、体系结构与处理器国际会议（ASAP 2018），意大利米兰，2018 年 7 月 10–12 日，1–4，https://doi.org/10.1109/ASAP.2018.8445101 。
13. N. Gala、A. Menon、R. Bodduna、G. S. Madhusudan、V. Kamakoti，《SHAKTI 处理器：一项开源硬件计划》，第 29 届 VLSI Design 国际会议暨第 15 届 Embedded Systems 国际会议（VLSID 2016），印度加尔各答，2016 年 1 月 4–8 日，7–8，https://doi.org/10.1109/VLSID.2016.130 。
14. M. Gautschi、M. Muehlberghuber、A. Traber、S. Stucki、M. Baer、R. Andri、L. Benini、B. Muheim、H. Kaeslin，《SIR10us：紧耦合 OpenRISC 椭圆曲线密码协处理器》，第 25 届 IEEE 专用系统、体系结构与处理器国际会议，瑞士苏黎世，2014 年 6 月，25–29，http://ieeexplore.ieee.org/document/6868626/ 。
15. M. Gautschi、P. Schiavone、A. Traber、I. Loi、A. Pullini、D. Rossi、E. Flamand、F. K. Gurkaynak、L. Benini，《带 DSP 扩展、面向可伸缩 IoT 端点设备的近阈值 RISC-V 核》，IEEE Transactions on Very Large Scale Integration (VLSI) Systems，卷 PP，2016 年 8 月。
16. T. R. Gross、N. P. Jouppi、J. L. Hennessy、S. Przybylski、C. Rowen，《回顾“MIPS：一种微处理器体系结构”》，2016。
17. J. Hennessy、N. Jouppi、F. Baskett、J. Gill，《MIPS：一种 VLSI 处理器体系结构》，VLSI Systems and Computations，337–346，Springer，1981。
18. J. Hennessy、N. Jouppi、S. Przybylski、C. Rowen、T. Gross、F. Baskett、J. Gill，《MIPS：一种微处理器体系结构》，ACM SIGMICRO Newsletter，13(4)，17–22，1982。
19. B. Keller、M. Cochet、B. Zimmer、J. Kwak、A. Puggelli、Y. Lee、M. Blagojevic、S. Bailey、P. Chiu、P. Dabbelt、C. Schmidt、E. Alon、K. Asanović、B. Nikolić，《采用 28 nm FD-SOI、集成亚微秒级电源管理的 RISC-V 处理器 SoC》，IEEE JSSC，52(7)，1863–1875，2017，https://doi.org/10.1109/JSSC.2017.2690859 。
20. P. Kongetira、K. Aingaran、K. Olukotun，《Niagara：32 路多线程 SPARC 处理器》，IEEE Micro，25(2)，21–29，2005 年 3 月，http://ieeexplore.ieee.org/document/1453485/ 。
21. G. Konstadinidis、M. Tremblay、S. Chaudhry、M. Rashid、P. Lai、Y. Otaguro、Y. Orginos、S. Parampalli、M. Steigerwald、S. Gundala、R. Pyapali、L. Rarick、I. Elkin、Y. Ge、I. Parulkar，《第三代 65 nm、16 核、32 线程芯片多线程 SPARC 处理器的体系结构与物理实现》，IEEE Journal of Solid-State Circuits，44(1)，7–17，2009 年 1 月，http://ieeexplore.ieee.org/document/4735553/ 。
22. Y. Lee、A. Waterman、R. Avizienis、H. Cook、C. Sun、V. Stojanović、K. Asanović，《带向量加速器的 45 nm、1.3 GHz、16.7 双精度 GFLOPS/W RISC-V 处理器》，第 40 届欧洲固态电路会议（ESSCIRC 2014），意大利 Venice Lido，2014 年 9 月 22–26 日，199–202，https://doi.org/10.1109/ESSCIRC.2014.6942056 。
23. A. S. Leon、K. W. Tam、J. L. Shin、D. Weisner、F. Schumacher，《高能效、高吞吐 32 线程 SPARC 处理器》，IEEE Journal of Solid-State Circuits，42(1)，7–16，2007 年 1 月，http://ieeexplore.ieee.org/document/4039591/ 。
24. A. Lopez-Parrado、J.-C. Valderrama-Cuervo，《用于数字信号处理的 OpenRISC SoC》，第 19 届图像、信号处理与人工视觉研讨会，哥伦比亚 Armenia，2014 年 9 月，1–5，http://ieeexplore.ieee.org/document/7010123/ 。
25. T. Marena，《RISC-V：高性能嵌入式 SweRV Core 微体系结构、性能与 CHIPS Alliance》，Western Digital 技术报告，2019 年 4 月，https://content.riscv.org/wp-content/uploads/2019/04/RISC-V_SweRV_Roadshow-.pdf 。
26. N. Mehdizadeh、M. Shokrolah-Shirazi、S. G. Miremadi，《分析 32 位 OpenRISC 1200 微处理器中的故障效应》，第三届可用性、可靠性与安全国际会议（ARES 2008），2008 年 3 月，648–652，http://ieeexplore.ieee.org/document/4529404/ 。
27. A. Menon、S. Murugan、C. Rebeiro、N. Gala、K. Veezhinathan，《Shakti-T：带轻量级安全扩展的 RISC-V 处理器》，Hardware and Architectural Support for Security and Privacy 会议论文集（HASP@ISCA 2017），加拿大 Toronto，2017 年 6 月 25 日，2:1–2:8，https://doi.org/10.1145/3092627.3092629 。
28. V. Patil、A. Raveendran、P. M. Sobha、A. D. Selvakumar、D. Vivian，《面向 RISC-V ISA 的乱序浮点协处理器》，第 19 届 VLSI Design and Test 国际研讨会（VDAT 2015），印度 Ahmedabad，2015 年 6 月 26–29 日，1–7，https://doi.org/10.1109/ISVDAT.2015.7208116 。
29. G. Tagliavini、S. Mach、D. Rossi、A. Marongiu、L. Benini，《面向 RISC-V ISA 的 SmallFloat SIMD 扩展设计与评估》，Design, Automation & Test in Europe（DATE 2019），意大利 Florence，2019 年 3 月 25–29 日，654–657，https://doi.org/10.23919/DATE.2019.8714897 。
30. M. Tremblay、S. Chaudhry，《第三代 65 nm、16 核、32 线程加 32 个 Scout Thread 的 CMT SPARC 处理器》，IEEE 国际固态电路会议（ISSCC 2008），美国 San Francisco，2008 年 2 月，82–83，http://ieeexplore.ieee.org/document/4523067/ 。
31. A. Waterman、K. Asanović，《RISC-V 指令集手册》，RISC-V Foundation 技术报告，2017 年 5 月，https://content.riscv.org/wp-content/uploads/2017/05/riscv-spec-v2.2.pdf 。
32. F. Zaruba、L. Benini，《应用级处理的代价：22 nm FDSOI 中可运行 Linux 的 1.7 GHz 64 位 RISC-V 核能效与性能分析》，2019 年 4 月。
33. B. Zimmer、Y. Lee、A. Puggelli、J. Kwak、R. Jevtić、B. Keller、S. Bailey、M. Blagojevic、P. Chiu、H. Le、P. Chen、N. Sutardja、R. Avizienis、A. Waterman、B. C. Richards、P. Flatresse、E. Alon、K. Asanović、B. Nikolić，《集成 28 nm FDSOI 同步开关电容 DC-DC 转换器的 RISC-V 向量处理器》，IEEE JSSC，51(4)，930–942，2016，https://doi.org/10.1109/JSSC.2016.2519386 。

---

# 第二篇：玄铁 910——以 RISC-V 创新云计算与边缘计算

## 第二篇出版信息

- 英文题目：Xuantie-910: Innovating Cloud and Edge Computing by RISC-V
- 会议：IEEE Hot Chips 32 Symposium，2020
- 形式：19 页演示稿
- 演讲人：Yu Pu
- 联合作者：Chen Chen、Xiaoyan Xiang、Chang Liu、Yunhai Shang、Ren Guo、Dongqi Liu、Yimin Lu、Ziyi Hao、Jiahui Luo、Zhijian Chen、Chunqiang Li、Yu Pu、Jianyi Meng、Xiaolang Yan、Yuan Xie、Xiaoning Qi
- 单位/品牌：T-HEAD，平头哥

这份演示稿与前述 ISCA 论文介绍同一处理器，但表达更偏产品架构、实现数据和平台生态。以下按原 19 页顺序逐页翻译，并嵌入每一页原图。

## 第 1 页：标题

**玄铁 910：以 RISC-V 创新云计算与边缘计算**

演讲人：Yu Pu；品牌：T-HEAD。

![Hot Chips 第 1 页](assets/xuantie910_papers/hotchips/slide-01.png)

## 第 2 页：平头哥与作者

**T-HEAD：开源，共建新 AIoT 时代的芯片生态。**

作者：

Chen Chen、Xiaoyan Xiang、Chang Liu、Yunhai Shang、Ren Guo、Dongqi Liu、Yimin Lu、Ziyi Hao、Jiahui Luo、Zhijian Chen、Chunqiang Li、Yu Pu、Jianyi Meng、Xiaolang Yan、Yuan Xie、Xiaoning Qi。

![Hot Chips 第 2 页](assets/xuantie910_papers/hotchips/slide-02.png)

## 第 3 页：构建 AIoT 时代的芯片基础设施

平头哥将自身定位为 **AIoT 时代的基础设施提供者**。图中体系由下到上为：

1. 底层基础计算：RISC-V 兼容处理器与领域专用体系结构。
2. 领域专用 SoC 平台：整合合作伙伴 IP。
3. 操作系统：AliOS。
4. 上层应用与控制领域：MCU、安全、智能计算、工业控制、存储控制及其他方向。
5. 云端位于顶层，为 AIoT 设备和应用提供连接与计算支撑。

![Hot Chips 第 3 页](assets/xuantie910_papers/hotchips/slide-03.png)

## 第 4 页：持续演进的玄铁处理器架构

演示稿展示玄铁产品从 902，经正在开发的 9xx 系列，演进到 910：

- 902：首款带硬件可信执行环境 TEE 的 RISC-V 处理器。
- 9xx：演进中的中间产品系列。
- 910：带 AI 加速引擎的超高性能处理器。

![Hot Chips 第 4 页](assets/xuantie910_papers/hotchips/slide-04.png)

## 第 5 页：玄铁 910 超高性能架构

主要特性：

- RISC-V RV64GCV。
- 基于 cluster 的多核架构。
- 每簇可配置 1、2 或 4 核。
- 每核 32/64 KB L1 D-Cache 与 32/64 KB L1 I-Cache。
- 64 位、12 级流水、乱序执行。
- 每周期译码 3 条，最多发射 8 条。
- 双发射乱序访存。
- 高性能混合分支处理。
- 多模式动态数据预取。
- 面向 AI 加速的向量引擎。
- 目标应用包括 AI、边缘服务器、工业控制与 ADAS。

框图中的 910 Core 配有 I-Cache、D-Cache、FPU 和向量计算单元，经一致性互连总线连接 L2 Cache；外围包括 PLIC、Timer、Debug Unit、Trace Unit 和 Master Interface。

![Hot Chips 第 5 页](assets/xuantie910_papers/hotchips/slide-05.png)

## 第 6 页：显著的 CoreMark 性能

图中按 CoreMark/MHz 比较多个 RISC-V 处理器：

| 处理器 | CoreMark/MHz |
|---|---:|
| Rocket | 2.32 |
| NXF | 3.22 |
| BOOM-2w | 3.91 |
| BOOM-4w | 4.7 |
| SweRV | 4.9 |
| SCR7 | 5.0 |
| U74 | 5.1 |
| 玄铁 910 | 7.1 |

演示稿突出玄铁 910 相对 U74 约提高 40%。图中给出的数据来源为：

- http://www2.eecs.berkeley.edu/Pubs/TechRpts/2018/EECS-2018-151.pdf
- https://content.riscv.org/wp-content/uploads/2019/04/RISC-V_SweRV_Roadshow-.pdf
- https://content.riscv.org/wp-content/uploads/2019/06/17.00-syntacore_zurich_ws.pdf
- https://www.sifive.com/cores/u74-mc

![Hot Chips 第 6 页](assets/xuantie910_papers/hotchips/slide-06.png)

## 第 7 页：兼容 RISC-V 规范

| 类别 | 支持内容 |
|---|---|
| ISA | RV64GCV |
| 向量 | RISC-V Vector 0.7.1；FP16/32/64，INT8/16/32/64 |
| 特权模式 | Machine、Supervisor、User |
| 内存管理 | Sv39 MMU；8/16 个 PMP 区域 |
| 中断控制 | CLINT + PLIC |

![Hot Chips 第 7 页](assets/xuantie910_papers/hotchips/slide-07.png)

## 第 8 页：RISC-V Turbo 扩展增强

RISC-V Turbo 包含：

- 计算增强；
- 位操作；
- 内存访问；
- 多核同步；
- 内存管理；
- Cache 与 TLB 操作。

右侧柱状图以 Native RV 为基线，对 EEMBC、NBench 和 OpenSSL 展示 XT-910 扩展后的归一化性能。纵轴刻度为 0、0.2、0.4、0.6、0.8、1.0、1.2、1.4。三组中 XT-910 柱均高于原生 RISC-V，提升约在 20% 左右，与 ISCA 论文图 20 的表述一致。原图未在柱顶标出精确数值，因此不从像素高度伪造额外小数。

![Hot Chips 第 8 页](assets/xuantie910_papers/hotchips/slide-08.png)

## 第 9 页：深度超标量乱序流水线

前端能力：

- 每周期取 8 条指令；
- 每周期译码 3 条指令；
- 每周期最多发射 8 条指令。

后端能力：

- 乱序内存访问；
- 专用分支处理；
- 乱序向量计算。

流水图从 IF、IP、IB 进入 ID、IR、IS、RF，后端包括：

- Load/Store 管线：AG、DC、DA；
- Branch 管线：BR；
- ALU/DIV 管线：ALU；
- ALU/MUL 管线：ALU、MUL2、MUL3；
- 两组 Vector 管线：VEC1–VEC4；
- 最终 WB 写回。

![Hot Chips 第 9 页](assets/xuantie910_papers/hotchips/slide-09.png)

## 第 10 页：采用混合预测的取指单元

混合多模式分支预测覆盖：

- 分支方向预测；
- 分支目标预测；
- 返回地址预测；
- 间接分支预测。

高带宽并行取指包括：

- 128 位取指；
- 每周期最多并行打包 8 条指令；
- I-Cache way prediction；
- 循环加速。

框图由多个方向预测器、GHR、双模预测器、BTB、返回地址栈 RAS、间接分支预测器和分支地址总线组成。

![Hot Chips 第 10 页](assets/xuantie910_papers/hotchips/slide-10.png)

## 第 11 页：双发射乱序 Load/Store 单元

乱序双发射能力：

- load/store 地址管线；
- 独立 store data 管线；
- 推测失败预测。

快速完成能力：

- load-to-use 为 3 周期；
- store 执行为 1 周期。

预取能力：

- 多模式、多流；
- 同时支持虚拟地址与物理地址预取；
- 预取容量可配置。

框图显示发射队列分别向 LD、ST、ST_DATA 路径发射。LD 经 AGU 访问 D-Cache；ST 经 AGU 进入 write buffer；独立 ST_DATA 路径向写缓冲提供数据。

![Hot Chips 第 11 页](assets/xuantie910_papers/hotchips/slide-11.png)

## 第 12 页：高效率多核互连

主要特性：

- 解耦的处理器接口单元 PIUx；
- MOESI 一致性协议；
- 基于目录的一致性架构；
- 支持 snoop filter；
- 可配置 L2 Cache，最大 8 MB；
- 支持 ECC。

框图中多个 PIUx 接入 snoop filter 与 snoop control，共享 L2，并通过 Master Interface 与 Slave Interface 连接外部系统。

![Hot Chips 第 12 页](assets/xuantie910_papers/hotchips/slide-12.png)

## 第 13 页：面向 AI 优化的向量计算引擎

主要特性：

- 兼容 RISC-V Vector 0.7.1；
- 支持 FP16/32/64 与 INT8/16/32/64；
- 256 位运算宽度，由 VL=128 的两条管线组成；
- 每周期执行两个 128 位向量 ALU 操作；
- 每周期执行一个 128 位向量 load 和一个 128 位向量 store；
- 向量 load/store 直接访问 L1 Cache；
- 双发射乱序向量执行流水线；
- 每簇 FP16 算力超过 300 GFLOPS，计算式为 32 FLOPS/核/周期 × 2.5 GHz × 4 核；
- 扩宽到 FP32 时算力为 FP16 的一半。

框图由向量寄存器文件和多组向量执行单元组成。

**译注：** 本页原文写作“VL = 128 and 2 pipelines”，而 ISCA 论文在同一配置处明确写两个 VLEN=128、SLEN=128 的 slice。VL 通常表示运行时当前向量长度，VLEN 才表示实现的向量寄存器长度参数；因此演示稿这里很可能是在用非严格缩写描述 128 位管线。本文保留原页写法，并以论文术语为准解释硬件配置。

![Hot Chips 第 13 页](assets/xuantie910_papers/hotchips/slide-13.png)

## 第 14 页：高效率性能分析引擎

本页用多张工具截图展示性能分析环境，包括：

- 函数耗时或指令占比；
- IPC、I-Cache、D-Cache、分支预测等仪表；
- 指令计数柱状图；
- 带函数调用、事件和时间区间的 trace 时间线；
- 执行指令、地址和反汇编信息；
- 表格化热点与定位信息。

页面没有额外正文，核心信息是 XT-910 提供集成式、图形化的 profiling 能力。截图中可辨认的英文界面文字对应如下：

| 英文界面项 | 中文含义 |
|---|---|
| Running / Overview / Finish Profiling | 正在运行 / 总览 / 结束性能采集 |
| CPU Type / Elapsed Insns / Elapsed Cycles | CPU 类型 / 已执行指令数 / 已运行周期数 |
| Memory Accesses / Write / Read | 内存访问 / 写 / 读 |
| IRQ & FRQ | 中断请求与频率 |
| Function Rank - Accumulated Elapsed Cycles | 函数累计耗时周期排名 |
| Total Function Cycles Rank | 函数总周期占比排名 |
| Insn Cache / Data Cache / Branch Predict | 指令 Cache / 数据 Cache / 分支预测 |
| refs / miss / miss rate | 访问次数 / 未命中次数 / 未命中率 |
| Instructions / Instruction Summary | 指令 / 指令分类汇总 |
| alu / load / store / branch / jump / rts / rte | 算术逻辑 / 载入 / 存储 / 条件分支 / 跳转 / 子程序返回 / 异常返回 |
| Instruction Count Rank | 指令数量排名 |
| Timeline / Function / Call Paths | 时间线 / 函数 / 调用路径 |
| name / cycle% / insn / cycle | 名称 / 周期占比 / 指令数 / 周期数 |
| total_insn / total_cycle / calls / address | 累计指令数 / 累计周期数 / 调用次数 / 地址 |
| Export CSV | 导出 CSV |

截图中的主要可辨认数值如下。这些数字是演示稿用于展示工具界面的示例采集结果，不是 C910 的通用 benchmark 分数：

| 截图区域 | 原图数值 |
|---|---|
| CPU Type | XT910 |
| Elapsed Insns | 1,624,104,894 |
| Elapsed Cycles | 1,624,112,229 |
| Function Rank - Accumulated Elapsed Cycles | 前六项约为 53.00%、20.61%、18.23%、7.92%、0.20%、0.01% |
| Total Function Cycles Rank | `CK_Uart_GetChar` 52.96%、`CK_CircleBuffer_Read` 20.65%、`CK_CircleBuffer_IsE...` 18.26%、`CK_WaitForReply` 7.94%、`delay` 0.15%、其他 0.04% |
| I-Cache | refs 0、miss 0、miss rate 0% |
| D-Cache | refs 0、miss 0、miss rate 0% |
| Branch Predict | refs 2787、miss 2772、miss rate 99.46% |
| 指令计数 | ALU 1,292,768,929；load 366,323,290；store 197,756,743；branch 100,156,249；jump 65,842,817；rts 49,382,640；rte 874 |
| Instruction Count Rank | ALU 62.38%、load 17.67%、store 9.54%、branch 4.83%、jump 3.17%、rts 2.38%、rte 0.01% |

这里的 I/D Cache 全零和分支 miss rate 99.46% 很可能与演示数据源、事件配置或界面示例状态有关，不能据此推断 C910 的真实 Cache 或分支预测表现。该页要表达的是工具能显示哪些事件，而不是这些示例数值代表正常工作负载。

![Hot Chips 第 14 页](assets/xuantie910_papers/hotchips/slide-14.png)

## 第 15 页：实验结果

左图为 EEMBC，右图为 NBench，均以 Cortex-A73 为 1.0 左右的归一化对照，图例为 A73 与 XT910；两幅图的纵轴刻度均为 0、0.2、0.4、0.6、0.8、1.0、1.2、1.4。

EEMBC 类别：

- automotive（汽车电子）；
- consumer（消费电子）；
- networking（网络处理）；
- telecom（电信处理）。

NBench 子项：

- Assignment（赋值运算）；
- Bitfield（位域操作）；
- Fourier（傅里叶计算）；
- FP Emulation（浮点模拟）；
- Huffman（霍夫曼编码）；
- IDEA（IDEA 加密算法）；
- LU Decomposition（LU 分解）；
- Neural Net（神经网络）；
- Numeric Sort（数值排序）；
- String Sort（字符串排序）。

从柱状图可见，XT-910 在不同子项上有赢有输；EEMBC 四组整体不低于 A73，NBench 整体与 A73 接近。原页没有给柱顶精确数值，应结合第一篇论文图 18、图 19 和正文结论阅读。

![Hot Chips 第 15 页](assets/xuantie910_papers/hotchips/slide-15.png)

## 第 16 页：FPGA 演示

页面由现场实物与屏幕截图组成，标题为 “FPGA DEMO”。图中展示：

- FPGA 开发硬件和连接线缆；
- 终端/调试窗口；
- 图像或视频演示画面；
- 实物场景中的猫。

原页没有进一步文字参数，因此不对演示负载、帧率或 FPGA 型号作超出图片的推断。

![Hot Chips 第 16 页](assets/xuantie910_papers/hotchips/slide-16.png)

## 第 17 页：ASIC 实现

| 指标 | 数据 |
|---|---|
| 工艺 | TSMC 12 nm FinFET |
| 工作频率 | 2.0 GHzᵃ–2.5 GHzᵇ |
| 每核面积，不含 L2 | 不带 VEC 0.6 mm²；带 VEC 0.8 mm² |

脚注：

- a：LVT 6T-turbo 标准单元，0.8 V VDD，TT、85 ℃。
- b：30% ULVT 标准单元，1.0 V VDD，TT、85 ℃。

左侧为单核版图，与 ISCA 论文图 3 相同。

![Hot Chips 第 17 页](assets/xuantie910_papers/hotchips/slide-17.png)

## 第 18 页：搭载玄铁的无剑 SoC 平台

页面主题为 **推动芯片差异化竞争**。演示稿宣称无剑 SoC 平台可以：

- 将芯片设计时间缩短 50%；
- 将设计成本最多节省 50%。

这些数字是演示稿中的平台宣传口径，原页未提供测量方法、样本或误差范围。

![Hot Chips 第 18 页](assets/xuantie910_papers/hotchips/slide-18.png)

## 第 19 页：总结

玄铁 910 被总结为：

- 超高性能超标量处理器；
- RISC-V 兼容，并采用 RISC-V Turbo 技术；
- 双发射乱序存储子系统；
- AI 向量加速引擎。

![Hot Chips 第 19 页](assets/xuantie910_papers/hotchips/slide-19.png)

---

# 第三篇：Alibaba/T-HEAD 的玄铁 C910 独立微结构分析

## 出版信息与证据性质

- 英文题目：Alibaba/T-HEAD's Xuantie C910
- 作者：Chester Lam
- 发布平台：Chips and Cheese
- 发表日期：2025 年 2 月 4 日
- 本地归档：[HTML 原文](<Alibaba_T-HEAD's Xuantie C910 - by Chester Lam.html>)
- 原始网页：https://chipsandcheese.com/p/alibabat-heads-xuantie-c910
- 分析方法：公开资料阅读、开源 C910 RTL 阅读、定向微基准和 TH1520 实机测量
- 实测平台：LicheePi 4A，TSMC 12 nm FinFET 工艺的 TH1520，4 个 C910 核，1 MB 共享 L2，核心频率 1.85 GHz，8 GB LPDDR4X-3733

原文正文引用的技术链接：

- OpenC910 开源仓库：https://github.com/XUANTIE-RV/openc910
- IFU 早期译码 RTL `ct_ifu_ipdecode.v`：https://github.com/XUANTIE-RV/openc910/blob/main/C910_RTL_FACTORY/gen_rtl/ifu/rtl/ct_ifu_ipdecode.v
- ROB RTL `ct_rtu_rob.v`：https://github.com/XUANTIE-RV/openc910/blob/main/C910_RTL_FACTORY/gen_rtl/rtu/rtl/ct_rtu_rob.v
- 原文用于解释 bi-mode predictor 的论文链接：https://people.eecs.berkeley.edu/~kubitron/courses/cs152-S04/handouts/papers/p4-lee.pdf

HTML 还包含 30 幅图片的 CDN 链接以及 Patreon、PayPal、Discord 等非技术链接。图片已保存为本地资产；非技术推广链接不影响文章技术内容，本文只在结尾说明其存在，不重复展开。

这篇文章与前两篇官方材料的作用不同。官方论文给出设计目标和高层机制，Hot Chips 演示稿给出产品化表达；Chester Lam 的文章试图用微基准观察软件可见行为，再回到公开 RTL 寻找可能的结构原因。它能补充官方材料没有给出的预测器容量、调度队列规模、转发边界和实机存储延迟等细节，但测量结果会受到具体 SoC、固件、操作系统、频率和测试方法影响。

作者也明确声明自己是软件工程师而非硬件工程师，而且部分 RTL 很可能由未公开的更高层源代码自动生成，阅读十分困难，文中可能存在错误。因此，下面使用四种标记理解证据：

| 标记 | 含义 | 可以支持的结论 |
|---|---|---|
| **官方资料** | ISCA 论文、Hot Chips 演示等公开规格 | 设计方公布的目标、容量和实现数据 |
| **RTL 观察** | 从开源 Verilog 的数组、端口和控制逻辑得到 | 当前公开 RTL 中确实存在的结构；仍需注意配置宏和版本差异 |
| **实机测量** | 作者在 TH1520/LicheePi 4A 上运行微基准所得 | 该平台的软件可见行为，不自动等价于其他 C910 实现 |
| **作者判断** | 作者根据结构与数据作出的归因或评价 | 有证据支持的假说，但不是官方事实，也不替代单变量实验 |

## 背景与定位

平头哥是阿里巴巴全资拥有的处理器 IP 公司，并建立了覆盖多个性能层级的 RISC-V 处理器产品线。原文认为，采用 RISC-V 一方面有利于为物联网端点、边缘计算等目标领域构建成本可控的定制芯片，另一方面也有减少对外部处理器 ISA 和 IP 依赖的战略价值。作者特别以 x86-64 和 Arm 背后的美国、英国企业为对照，强调 RISC-V 是不由这些企业控制的开放 ISA，并把平头哥的路线放到中国发展本土芯片能力的背景下理解。后一层属于作者对产业动机的判断，不是微结构事实。

玄铁 C910 位于产品线的“高性能”层级。它既是较早实现为真实芯片的乱序 RISC-V 核之一，也是 RISC-V Vector 0.7.1 的早期采用者，支持掩码和可变向量长度。文章称后继 C920 将向量规范升级到 1.0，而其余部分基本延续 C910；这一产品关系属于文章发表时的概括，分析具体芯片时仍应核对型号和实现配置。

![第三篇图 1：平头哥处理器产品线与 C910 架构概览](assets/xuantie910_papers/chipsandcheese/01_architecture-slide.jpg)

C910 面向 AI、边缘服务器、工业控制和高级驾驶辅助系统等场景。它是平头哥第一代乱序核，可以组成最多四核的簇，并在簇内共享 L2。官方资料给出的 12 nm 目标为 2–2.5 GHz、单核约 0.8 mm²；2 GHz 时电压约 0.8 V，2.5 GHz 时约 1.0 V；7 nm 实现达到 2.8 GHz。官方还报告动态功耗约 `100 µW/MHz`，按 2 GHz 线性换算约为 0.2 W，但这个数字不包括静态功耗和核外逻辑。作者据此把 C910 定位为低功耗、小面积设计。

下图是作者在官方版图上增加红色注释后的单核图。图中 PIU 与 PLIC 出现在后面的双核版图中。

![第三篇图 2：作者标注后的 C910 单核版图](assets/xuantie910_papers/chipsandcheese/02_annotated-single-core-floorplan.jpg)

![第三篇图 3：C910 双核版图](assets/xuantie910_papers/chipsandcheese/03_dual-core-floorplan.jpg)

本文第三篇的所有实测均来自上述 TH1520 平台。不能把“TH1520 上的 C910”与“论文中可配置到不同 L2 容量的 C910 IP”完全等同，也不能把实机 Linux 测量值直接当成当前仓库 RTL 仿真的固定参数。

## 核心总览

C910 是三指令宽、乱序执行、12 级流水的处理器。官方流水级从取指、指令打包、缓冲、译码和重命名，延伸到分布式发射、寄存器读取、执行、写回与退休。不同执行管线经过的级数并不完全相同，“12 级”描述的是总体组织，不表示每一类指令都固定经历十二个同名寄存级。

![第三篇图 4：官方给出的 C910 12 级流水线](assets/xuantie910_papers/chipsandcheese/04_official-pipeline.jpg)

作者指出，C910 与 Arm Cortex-A73 类似，可以在指令最终退休之前较早释放部分乱序资源。为了通过微基准探测容量，作者使用相关分支和未完成 load 阻塞退休，从而避免被测指令很快流出窗口。这个方法的核心是让某种结构先达到稳定占用，再从吞吐或延迟曲线的拐点反推容量；它测到的是软件可观察的有效容量，仍需与 RTL 物理表项数互证。

![第三篇图 5：作者整理的 C910 核心高层数据通路](assets/xuantie910_papers/chipsandcheese/05_core-overview.jpg)

### 教学解读：宽度、级数与窗口是三个不同维度

三发射宽度限制理想情况下每周期可接收多少条 ISA 指令；四微操作译码/重命名宽度限制复杂指令拆分后每周期可送入后端多少个内部操作；12 级流水线影响各机制的基本延迟和误预测恢复代价；ROB、物理寄存器和调度器容量决定处理器能在等待长延迟事件时观察多远。任何一个维度不足都可能压低 IPC，因此不能只凭“3-wide”判断处理器快慢。

## 前端：取指与分支预测

### 指令 Cache 与预译码

C910 要同时处理 16 位压缩指令、32 位普通指令和向量指令。其 L1 I-Cache 为 64 KB、2 路组相联、FIFO 替换。除了指令字节，每个可能的 16 位指令起点还保存 4 位预译码信息：其中两位用于初步标识该位置是否为指令起点，另外两位携带分支信息。把数据、tag 和这些预译码位合计，文章估算指令 Cache 使用约 83.7 KB 原始位存储。

![第三篇图 6：64 KB、2 路 L1 I-Cache 的存储组成](assets/xuantie910_papers/chipsandcheese/06_l1i-storage.jpg)

一次 L1 I-Cache 访问会同时读取两路的指令字节、预译码数据和 tag。因此 IF 级的临时寄存器一度接收两路共 256 位指令数据和 64 位预译码数据，再由两路 tag 比较确定真正命中的一路。与此同时，IF 级查询一个 16 项全相联 L0 BTB，使少量重复 taken 分支可获得接近单周期的早期目标供给。

两路数据随后进入 IP（Instruction Pack，指令打包）级。RTL 中有两个各 8 路的早期译码块，每个槽对应一个 16 位边界，两路合计检查 16 个候选起点。早期译码只做分类和边界等初步工作；对向量指令还会形成与向量长度配置、所选元素宽度和最大元素数有关的信息。原文把这里概括成“算出 VLEN、VSEW、VLMAX”，其中 VLEN 在 RISC-V 向量术语中通常是实现固定的向量寄存器位宽，并非每条指令动态算出的值；动态状态应重点区分 VL、VSEW、LMUL 与由它们约束的 VLMAX。

这里必须澄清一个容易误读的数字：物理 SRAM 同时读出两路，所以内部暂时出现 `2 × 128 = 256` 位；但组相联 Cache 每次只会有一路命中，错误一路的 8 个候选槽全部丢弃，送往后续级的有效取指窗口仍是命中一路的 128 位。它不是“每周期向后端提供 256 位指令”，更不是“8 字节等于 128 位”。在压缩指令全为 16 位时，一个 128 位窗口最多包含 8 条；若全为 32 位，最多包含 4 条，最终供给还受分支边界和三指令译码宽度限制。

![第三篇图 7：作者绘制的简化前端数据流](assets/xuantie910_papers/chipsandcheese/07_frontend-sketch.jpg)

### 主分支预测器

C910 的主要预测机制位于 IP 级。条件分支使用 bi-mode 预测器，文章从 RTL 识别出：

- 1024 项选择表；
- 两张各 16384 项、每项 2 位饱和计数器的历史表，分别偏向 taken 和 not-taken；
- 22 位全局历史寄存器；
- 12 项返回地址栈；
- 256 项间接目标数组。

选择表索引由分支地址低位与全局历史哈希形成，历史表还会使用全局历史的更高位进行哈希，选择表输出决定使用 taken 表还是 not-taken 表。文章估算全部主要预测存储约 17.3 KB，并把它视为符合低面积、低功耗目标的小型预测器。原文拿 Qualcomm Oryon 的约 80 KB 条件方向预测存储和约 40 KB 间接预测存储作数量级对照；跨时代、跨目标产品的容量比较只能说明设计预算差异，不能单独证明准确率高低。

![第三篇图 8：作者从 RTL 整理的分支预测资源](assets/xuantie910_papers/chipsandcheese/08_branch-predictor-resources.jpg)

作者用不同长度的随机分支模式测试历史识别能力。C910 能处理一定长度的模式，表现与作者测过的其他低功耗核大致相当；当同时存在很多分支时，C910 和 Cortex-A73 都会明显变差，而分支数量较少且所需历史不过长时仍能保持较好准确率。

![第三篇图 9：C910 的随机分支模式识别结果](assets/xuantie910_papers/chipsandcheese/09_branch-pattern-c910.jpg)

![第三篇图 10：Cortex-A73 的随机分支模式识别结果](assets/xuantie910_papers/chipsandcheese/10_branch-pattern-a73.jpg)

主 BTB 为 1024 项、4 路组相联。由 IP 级重定向会制造一个显式流水空泡，软件观察到的 taken 分支延迟约为 2 周期；当分支集合超出主 BTB 容量但代码仍命中 I-Cache 时，作者测得约 4 周期。这里的“taken 延迟”是特定依赖微基准下的有效代价，不应直接替代完整程序中的误预测恢复周期。

![第三篇图 11：taken 分支延迟随分支工作集变化](assets/xuantie910_papers/chipsandcheese/11_taken-branch-latency.jpg)

### 指令缓冲与循环缓冲

IP 级最多向 IB（Instruction Buffer）级交付 8 个 16 位槽及其早期译码信息。IB 使用 32 项指令队列和独立的 16 项循环缓冲来吸收前端供给波动；两者均以 16 位为一项，所以一条 32 位指令占两个槽。原文把循环缓冲的目标类比为 Pentium 4 trace cache 的一部分作用：在短循环 taken 回跳后补足原本会丢失的前端槽位。两者的组织和规模并不相同，C910 的 16 槽 LBUF 只覆盖很小的循环，也不会增大峰值译码宽度。

向正式译码级供给时，IB 可以从循环缓冲、指令队列或旁路路径选择。每条指令连同早期译码元数据被打包成 73 位格式。旁路用于在无需排队时减少额外延迟，队列用于解耦取指波动与译码消耗。

### 教学解读：怎样判断前端是否真的构成瓶颈

“I-Cache 128 位读取”“最多 8 个 16 位候选槽”和“每周期 3 条 ISA 指令”是不同层级的上限。真实有效供给还要依次乘上 I-Cache 命中、正确路选择、分支预测正确、指令边界可用、IB 非空和译码接收等条件。分析完整程序时应联合观察：

1. I-Cache 与 ITLB MPKI；
2. BTB、方向、RAS 和间接分支的分类 MPKI；
3. 每次重定向或误预测造成的恢复周期；
4. IB 空、LBUF 命中、译码零输入和每周期有效译码条数；
5. 代码工作集扩大后 IPC 是否从接近 3 急剧下降。

只有“分支 MPKI 高且恢复周期占比高”才能把主要责任归到预测器；若预测准确而 IB 经常空，应继续检查 I-Cache、ITLB、BTB 目标供给和取指跨行行为。

## 前端：译码与重命名

ID（Instruction Decode）级接收三路 73 位输入，由主译码器提取寄存器信息，并在必要时把一条 ISA 指令拆为多个微操作。三个槽都能为简单指令产生 1–2 个微操作，但每周期总输出不超过 4 个微操作；只有第一个译码槽可以处理会展开为 4 个或更多微操作的复杂指令。此类复杂指令会阻止同周期的并行译码。

译码后的微操作为 178 位，直接进入 IR（Instruction Rename）级。C910 在译码和重命名之间没有许多现代核所设的独立微操作队列，因此两级宽度需要直接匹配：重命名为 4 微操作宽，译码总输出也限制为每周期 4 微操作。

![第三篇图 12：译码到重命名的数据流](assets/xuantie910_papers/chipsandcheese/12_decode-rename-flow.png)

重命名级检查架构寄存器匹配，建立指令间真依赖，并从整数或浮点物理寄存器池分配空闲寄存器；刚从退休级释放的寄存器也可直接再次分配。该级还继续补充多周期 ALU 类型、可用执行端口等控制信息。经过重命名后，一个微操作的打包宽度达到 271 位。这个位宽包括大量控制和依赖元数据，不表示每条指令都搬运 271 位有效数据。

![第三篇图 13：作者对各阶段微操作格式的 RTL 笔记](assets/xuantie910_papers/chipsandcheese/13_micro-op-format-notes.jpg)

图 13 的图内字段可按下面三组理解。位号和信号名保留原图，中文解释说明其职责；原图在 `vl`、`vl_pred` 等名称后带有问号，表示作者当时仍在推测，本文不把问号消去。

| 内部格式 | 原图字段 | 中文职责 |
|---|---|---|
| 73 位译码输入 | `opcode[31:0]` | 32 位原始指令数据 |
| 73 位译码输入 | `expt_vld`、`expt_vec`、`high_hw_expt` | 异常有效、异常向量和高半字异常信息 |
| 73 位译码输入 | `split_long`、`split_short` | 分别提示译码为较多微操作或两个微操作 |
| 73 位译码输入 | `fence`、`bkpta_inst`、`bkptb_inst`、`no_spec` | 屏障、两类断点和禁止推测属性 |
| 73 位译码输入 | `vlmul`、`vsew`、`pc`、`vl`、`vl_pred` | 向量寄存器分组、元素宽度、程序计数器，以及作者标作可能的向量长度/预测信息 |
| 178 位译码输出 | `src0/1/2_vld`、`src0/1/2_reg`、`dst_vld`、`dst_reg` | 最多三个源和一个目的架构寄存器的有效位与编号 |
| 178 位译码输出 | `srcv0/1/2_vld`、`srcv0/1/2_reg`、`dstv_vld`、`dstv_reg` | 向量源/目的寄存器信息 |
| 178 位译码输出 | `inst_type`、`split`、`intmask`、`length` | 指令类型、拆分、整数掩码和指令长度等控制 |
| 178 位译码输出 | `mov`、`fmov`、`iid_plus`、`illegal`、`dst_x0`、`mla` 等 | move/FPU move、指令标识增量、非法指令、写 x0、乘加等译码属性 |
| 178 位译码输出 | `vmla`、`split_last`、`vlmul`、`vsew`、`pc`、`vmb`、`vl`、`vl_pred` | 向量乘加/拆分尾项和从取指侧继续传递的向量、PC 信息；原图蓝色表示沿取指级透传 |
| 271 位重命名输出 | `preg`、`vreg`、`rel_preg` | 重命名后的标量/向量物理寄存器及待释放物理寄存器 |
| 271 位重命名输出 | `bp_rdy`、`lsu_match`、`data`、`wb` | 旁路就绪、LSU 匹配、内联数据和写回控制 |
| 271 位重命名输出 | `srcv*_vld`、`dstv_vreg`、`dst_rel_vreg`、`dst_ereg` | 向量源、向量目的、待释放向量寄存器和扩展目的寄存器 |
| 271 位重命名输出 | `alu`、`load`、`store`、`staddr`、`bar`、`bar_type` | ALU、load、store、store 地址和屏障类别 |
| 271 位重命名输出 | `lsu_pc`、`bju`、`pcall`、`pcfifo`、`mult`、`div`、`special`、`rts`、`expt` | LSU PC、分支跳转、调用、PC FIFO、乘除法、特殊操作、返回和异常属性 |
| 271 位重命名输出 | `pipe6/7`、`vdiv`、`vmla`、`mtvr`、`mfvr`、`unit_stride` 等 | 执行管线选择和向量除法、乘加、标量/向量搬运、单位步长访存等属性 |

从教学角度看，位宽从 73 增至 178，再增至 271，并不是操作数数据越来越宽，而是指令越接近后端，必须携带的控制、依赖、物理寄存器和端口选择信息越来越多。图中部分字段的精确定义仍应以对应 RTL 信号赋值为准。

作者的软件微基准显示，只要代码完全位于 64 KB L1 I-Cache，C910 前端可持续达到每周期 3 条指令；当代码供给落到 L2，前端吞吐低于 1 IPC。对照的 SiFive P550 在更大代码工作集下更稳定，甚至从 L3 取代码时仍能维持约 1 IPC。该图反映的是特定代码布局与测试平台的取指吞吐，不代表通用 benchmark 的总 IPC。

![第三篇图 14：不同代码工作集下的取指吞吐](assets/xuantie910_papers/chipsandcheese/14_instruction-fetch-bandwidth.jpg)

## 乱序执行引擎

### ROB：64 个物理表项与约 192 条指令容量

C910 使用物理寄存器文件式乱序执行：尚未退休的推测结果和已经提交的架构结果都存放在 ROB 之外的物理寄存器文件，ROB 主要负责顺序、完成和异常状态。`ct_rtu_rob.v` 确实例化 64 个 ROB 表项，而官方论文称最多可容纳 192 条指令，作者的容量微基准也大体支持后一个数字。

![第三篇图 15：微基准观察到的 ROB 有效容量](assets/xuantie910_papers/chipsandcheese/15_rob-capacity.jpg)

以上是第三篇原文保留的三项观察：RTL 文件中有 64 个表项，官方论文写最多 192 条指令，作者微基准大体接近 192。原文没有进一步解释 64 与 192 如何对应，也没有在此处使用“折叠 ROB”这一术语。

#### 核查说明：当前仓库 RTL 如何解释 64 与 192

本文另行核查当前仓库 RTL 后发现，一个物理 ROB 表项可以聚合最多三条满足条件的顺序指令，并以完成计数等字段跟踪组内状态。因此，物理索引空间是 64 项，而理想情况下最多可代表约 `64 × 3 = 192` 条 ISA 指令。真实程序能否接近 192 取决于指令类型、聚合条件、异常与控制信息，以及其他资源是否先满。

这一段是本文基于当前仓库 RTL 作出的解释，不是 Chester Lam 原文的结论，也不应反向改写官方论文的“最多 192 条指令”口径。把它简单写成“192 个物理 ROB 表项”会误解实现，把它简单写成“最多 64 条在途指令”也不准确。

文章认为这一理论指令窗口与 2013 年 Intel Haswell 的 192 项 ROB 容量相当，并大于 P550 或 Goldmont Plus，但 C910 的物理寄存器和调度器没有按同等比例扩大。这个比较的重点不是说两者具有相同乱序能力，而是说明 ROB 指令容量只有在其他结构同步匹配时才有价值。

C910 有 96 项整数物理寄存器和 64 项浮点/向量物理寄存器。RISC-V 各有 32 个架构整数和浮点寄存器；按作者的简化估计，保留已提交状态后，留给在途结果的大约是 64 个整数和 32 个浮点寄存器。精确可分配数量还受零寄存器、重命名规则和实现保留项影响，但“物理寄存器可能早于文章所称的 ROB 指令容量耗尽”符合原文的判断方向。

![第三篇图 16：C910、P550 与 Haswell 的关键乱序结构容量对照](assets/xuantie910_papers/chipsandcheese/16_structure-capacity-comparison.jpg)

图中的全部容量转录如下。`entry`、问号和约数均按原图保留；特别是原图把 C910 写成 `192 entry`，这与上文从 RTL 看到的 64 个物理表项不是同一种表述，本文不替作者重写该表。

| 结构 | 何时需要分配 | C910 | P550 | Haswell |
|---|---|---:|---:|---:|
| ROB | 所有进入乱序窗口的指令 | 192 entry（原图原词） | 96 entry | 192 entry |
| 整数物理寄存器 | 写整数寄存器 | 96 项 | 128 项 | 168 项 |
| 浮点/向量物理寄存器 | 写浮点寄存器 | 64 项 | 约 119 项 | 168 项 |
| Load Queue | 从内存读取 | 约 12 项，原图带问号 | 12 项 | 72 项 |
| Store Queue | 向内存写入 | 24 项 | 16 项 | 42 项 |

### 执行端口与整数调度

文章按后端功能统计出 8 个执行端口。标量整数侧有两个端口处理常见 ALU 运算，另一个端口专用于分支。整数物理寄存器文件有 10 个读端口，为包含三条存储相关管线在内的五条执行管线供数。C910 使用分布式调度器；每个调度项除操作码和寄存器匹配信息外，还包含 7 位年龄向量，用于让仲裁优先选择较老的就绪操作。

常用 ALU 调度容量只有 16 项。原文对照 P550 的 3 个 ALU 端口共享约 40 项调度容量，以及 Goldmont Plus 的约 30 项。不同处理器的“scheduler entry”分组方式和可接受操作类型并不完全一致，因此这些数值适合做结构预算对比，不适合直接换算性能。

![第三篇图 17：整数调度器与执行端口](assets/xuantie910_papers/chipsandcheese/17_integer-scheduler-ports.png)

### 浮点与向量执行

FPU 采用两条执行管线，两条都能处理常见加法、乘法、融合乘加和 128 位向量操作。一个 FMA 需要读取三个源操作数，带掩码的向量操作还可能需要第四个源。与 AVX-512 和 SVE 的独立掩码寄存器不同，RVV 的掩码占用向量寄存器，因此这些输入都来自浮点/向量物理寄存器文件。虽然浮点/向量端口数量少于整数侧，寄存器文件仍需提供接近整数侧数量的读端口。

![第三篇图 18：浮点/向量调度器与执行端口](assets/xuantie910_papers/chipsandcheese/18_fp-vector-scheduler-ports.jpg)

作者测得常见浮点运算延迟约为 3–5 周期：加法 3 周期、乘法 4 周期、FMA 5 周期；图中 P550 为 4/4/4，Cortex-A73 为 3/3/5。原文指出 Cortex-X2、Golden Cove、Zen 5 等更新的大核可达到 2 周期浮点加法，但认为不应对低功耗 C910 提出同样目标。

![第三篇图 19：常见浮点操作延迟对照](assets/xuantie910_papers/chipsandcheese/19_fp-latency-comparison.jpg)

### 教学解读：为何“大 ROB、小调度器”会失衡

ROB 决定处理器最多能保留多远的程序顺序，但只有进入调度器且源操作数就绪的微操作才可能利用执行端口。如果常用 ALU 调度器先满，重命名端即使还有 ROB 空间也会被反压；如果物理寄存器先耗尽，新的写寄存器指令不能重命名；如果 LQ、SQ 或 miss 缓冲先满，访存链也无法继续向前。因此必须同时看 ROB、各类 IQ、PRF 空闲表、LQ/SQ 和 LFB 的占用与满阻塞周期。

“结构容量不平衡”在这里是一个待验证的归因。要证明它是某个 benchmark 的主瓶颈，需要看到：ROB 尚有空闲时，某个小结构频繁满；扩容该结构后阻塞周期下降；IPC 或总周期随之改善；时序、面积和功耗代价仍可接受。只看容量表不能完成因果闭环。

## 存储子系统

### 地址生成、TLB 与存储队列

C910 有两个地址生成单元：一个处理 load，一个处理 store。LSU 大体分为 load 和 store 两条管线，目标是每周期最多完成一次 load 地址和一次 store 地址处理。与许多乱序核一样，一条 store 会拆成地址微操作和数据微操作，使地址可以在 store 数据尚未就绪时提前解析。

![第三篇图 20：官方 LSU 流水线](assets/xuantie910_papers/chipsandcheese/20_official-lsu-pipeline.jpg)

数据访问使用 39 位虚拟地址并形成 40 位物理地址。数据侧一级 uTLB 为 17 项全相联，其中公开 RTL 可进一步解释为 16 个普通页项加 1 个大页项。L1 TLB 未命中后访问统一 JTLB；JTLB 为 1024 项、4 路组相联，即 256 组×4 路，文章称相对一级命中增加约 4 周期。

JTLB 数据阵列由两个 `256×84` SRAM 组成，tag 阵列为一个 `256×196` SRAM；一次 tag 访问包含四路 tag 和 4 位 FIFO 替换状态。每个 tag 除 VPN 和有效位外，还包含 16 位 ASID 与 global 位，以便地址空间切换时保留不必失效的转换。文章估算 tag 与数据合计约 8.96 KB 原始位存储。

![第三篇图 21：JTLB tag 字段与存储组织](assets/xuantie910_papers/chipsandcheese/21_l2-tlb-tag-format.png)

地址转换完成后，物理地址进入 load 或 store 队列。文章对 LQ 大小持保留态度：RTL 迹象指向 12 项，但微基准结果并不清晰。RTL 中每个 LQ 项保存 36 位 load 物理地址、16 位字节有效信息和 7 位指令标识；SQ 项则保存 40 位物理地址、待写数据、16 位字节有效位、7 位指令标识以及其他控制字段。相关辅助结构还包括 12 项 wakeup queue、4 位 store-data 标识，以及各 12 项的年龄关系向量。它们共同承担依赖唤醒、顺序判断和转发控制。

![第三篇图 22：作者的 load 队列容量微基准](assets/xuantie910_papers/chipsandcheese/22_load-queue-microbenchmark.jpg)

### Store-to-load 转发与非对齐访问

RTL 的内存依赖比较会使用地址位 `[11:4]`。作者的软件测试显示，只要 load 的所有字节完全包含在较老 store 覆盖范围内，C910 可以不受 store 内部对齐位置影响地转发；但 load 跨越 16 字节对齐边界，或 store 跨越 8 字节对齐边界时，转发会失败，并出现 20 周期以上的代价。

![第三篇图 23：不同 load/store 对齐组合下的转发结果](assets/xuantie910_papers/chipsandcheese/23_store-forwarding-map.jpg)

文章认为 C910 对普通非对齐访问处理良好：load 不跨 16 字节边界、store 不跨 8 字节边界时基本没有额外代价；跨越边界时通常只需在内部增加一次 L1 D-Cache 访问。作者把它评价为略低于当时最新 Intel/AMD 核，但大体达到 AMD Piledriver 的能力层级，也明显好于其测试中的 P550。跨处理器比较仍依赖指令宽度、Cache 命中和测试方法，图中的具体边界才是最可复现的结论。

### 教学解读：转发失败为何会放大为二十多个周期

store 数据已经存在于 SQ 并不意味着任意覆盖关系都能低成本拼接。转发网络需要同时完成地址匹配、年龄判断、字节掩码选择、可能的多项合并和对齐；跨内部边界会增加比较器、选择器和关键路径。实现通常只支持最常见的单项、单边界情况，复杂情况则让 load 回放，等待 store 提交或重新访问 Cache。最终代价包含错误唤醒、流水回放和重新执行，不只是一次多路选择器延迟。

在完整程序中应同时统计 store-forward 尝试、成功、失败原因、load replay 和由回放造成的零退休周期。只有非对齐或别名模式出现足够频繁时，转发边界才会成为主要性能瓶颈。

## 数据 Cache

L1 D-Cache 为 64 KB、2 路组相联、3 周期命中延迟，并划分为 4 字节宽的 bank。它可以每周期处理最多一个 load 和一个 store，但 128 位 store 需要两个周期。load 与 store 使用分离的 tag 阵列，使两类请求能够并行检查地址。

![第三篇图 24：64 KB、2 路 L1 D-Cache 的存储组成](assets/xuantie910_papers/chipsandcheese/24_l1d-storage.jpg)

Cache miss 由 8 个 line-fill buffer 项跟踪，每项保存 miss 地址；回填数据暂存在两个 512 位宽寄存器中。D-Cache 与 I-Cache 一样使用 FIFO 替换。LFB 数量决定同一时刻能追踪多少个尚未完成的 line miss，但有效内存级并行度还受 LQ、TLB、总线信用和依赖链限制。

### 教学解读：3 周期 L1 命中仍可能拖慢核心

load-to-use 延迟只有在消费者依赖 load 结果时才直接进入关键路径。若存在足够多独立工作，乱序窗口可用其他指令覆盖这 3 周期；若程序是链式指针追踪，每次 load 的地址依赖上一次结果，则几乎没有可重叠空间。另一方面，bank 冲突、地址生成端口冲突、TLB miss 和 store-forward 回放会让“标称 3 周期”变成更长的有效延迟。分析时应把 L1 命中 load、L1 miss、TLB miss、回放和端口等待分开。

## L2 Cache 与互连

### 从核心到 CIU

原文把每个 C910 核与外部连接的接口称为 PIU（Processor Interface Unit），簇的另一端由 CIU（Consistency Interface Unit）接收最多四个核心的请求并维持一致性。公开 RTL 的模块边界中，BIU、PIU 和 CIU 的命名层次比文章的简图更细，因此“每核经 PIU 接入”应理解为功能性概括，而不是唯一模块层次定义。

CIU 包含两个 SNB 实例，按物理地址位 `[6]` 将相邻 64 B Cache line 分到两个 bank。当前 RTL 显示每个 SNB 内有 24 项 SAB，其中 16 项用于读类事务、8 项用于写类事务；SNB 按年龄仲裁，并通过 512 位接口访问 L2。这比原文笼统的“24 项请求队列”更准确：24 是每个 SNB 的在途一致性事务跟踪容量，不是整个双 bank CIU 合计只有 24 项。

### L2 组织

在 TH1520 中，L2 容量为 1 MB、16 路组相联、FIFO 替换，并兼任 L1 miss 的下一级和四核簇共享末级 Cache。L2 以物理地址位 `[6]` 选择两个 bank，能够让相邻 Cache line 进入不同 bank；它对上层 Cache 保持包含关系，并用 ECC 保护数据完整性。

![第三篇图 25：1 MB、16 路共享 L2 的存储组成](assets/xuantie910_papers/chipsandcheese/25_l2-storage.png)

作者在 TH1520 上测得 L2 访问约 60 周期，并认为对于没有中间级 Cache、可利用乱序资源受限的 C910 来说过高。原文对照 P550 的 4 MB L3 以及 Goldmont Plus 约 28 周期的共享 L2 延迟。由于各测试的频率、TLB 路径、预取、测量链和 Cache 定义不同，这种对照应看数量级，不能当成严格同条件排名。

![第三篇图 26：TH1520 的 Cache 与内存访问延迟](assets/xuantie910_papers/chipsandcheese/26_cache-memory-latency.jpg)

### L2 与 DRAM 带宽

单个 C910 核从 L2 读取略高于 10 GB/s，按 1.85 GHz 换算约 5.5 B/cycle。四核合计读取约 12.6 GB/s，即平均每核约 1.7 B/cycle；四核合计写带宽约 23.81 GB/s，仍低于整个簇每周期 16 字节，而且一般程序的读流量往往比写流量更常见。原文认为这些结果不仅落后于对照的 P550 L3 和 Goldmont Plus L2，也意味着多线程程序容易触及共享 L2 读带宽限制。

![第三篇图 27：三种四核平台的读取带宽随工作集变化](assets/xuantie910_papers/chipsandcheese/27_quad-core-bandwidth.png)

离开处理器簇的请求通过 128 位 AXI4 接口。LicheePi 4A 的 64 位 LPDDR4X-3733 理论峰值略低于 30 GB/s，但作者测得多线程持续读取约 4.2 GB/s。四核共享的末级 Cache 只有 1 MB 时，大工作集很快落到 DRAM，因此可实现带宽会直接限制多核和向量吞吐。

使用 2 MB 大页和 1 GB 数组时，作者测得 DRAM 延迟约 133.9 ns。原文对照表如下；它比较的是整个平台而非单纯 CPU 核，内存控制器、DRAM 配置、页大小和软件环境都在结果中。

| 平台 | 处理器配置 | 作者测得读带宽 | 作者测得 DRAM 延迟 |
|---|---|---:|---:|
| LicheePi 4A / TH1520 | 4×C910 | 4.17 GB/s | 133.86 ns |
| Eswin EIC7700X | 4×P550 | 17.91 GB/s | 193.92 ns |
| Intel Celeron J4125 | 4×Goldmont Plus | 12.70 GB/s | 186.63 ns |
| Amlogic S922X | 4×Cortex-A73 | 7.96 GB/s | 139.79 ns |

![第三篇图 28：四种低功耗平台的 DRAM 带宽与延迟](assets/xuantie910_papers/chipsandcheese/28_dram-comparison.jpg)

### 核间传输延迟

一致性协议有时必须把脏数据或所有权从一个核心转移到另一个核心。作者编写了与 AnandTech 同类的核间延迟微基准，并认为结果可作大致对照。TH1520 四核矩阵中的核间值约为 61–64 ns；作者评价 CIU 的核间传递速度合理，并明显好于其测得簇内超过 300 ns 的 P550 平台。图中非对角线数值完整转录如下，单位为 ns：

| 发起核＼目标核 | 核 1 | 核 2 | 核 3 | 核 4 |
|---:|---:|---:|---:|---:|
| 核 1 | — | 62.75 | 63.10 | 63.05 |
| 核 2 | 64.05 | — | 62.65 | 63.60 |
| 核 3 | 63.15 | 62.45 | — | 61.75 |
| 核 4 | 62.50 | 61.90 | 61.75 | — |

![第三篇图 29：TH1520 四核之间的传输延迟矩阵](assets/xuantie910_papers/chipsandcheese/29_core-to-core-latency.png)

### 教学解读：为什么 L2 延迟与带宽必须同时看

延迟回答“一个孤立 miss 多久返回”，带宽回答“很多请求并行时每周期能完成多少数据”。指针追踪往往受延迟限制；流式数组、多个核和向量代码更容易受带宽限制。C910 若要隐藏约 60 周期 L2 延迟，需要在此期间持续发现独立工作并维持多个 miss；但调度器、物理寄存器、LQ 和 8 个 LFB 都可能先限制并发。于是“高 L2 延迟”和“有限乱序支撑资源”会互相放大。

对当前 RTL 的瓶颈研究，不能只复现一个平均延迟。至少应分别测：

1. L1、JTLB、L2 和外部内存的无依赖吞吐与依赖链延迟；
2. outstanding miss 数从 1 增加到结构上限时的带宽曲线；
3. 单核与多核、奇偶 Cache line bank 分布、读写混合比例；
4. ROB/IQ/LQ/LFB 占用、满阻塞周期和 load 在 ROB 头部等待周期；
5. 预取带来的覆盖、及时性、污染与额外总线流量。

## 总结与作者结论

作者认为，作为平头哥第一代乱序核，C910 已有不少成熟之处：核间传递延迟、非对齐访问和向量支持优于其测试过的 P550 平台；L2 可配置到 8 MB，多簇配置也提供了扩展核心数的可能性。原文引用官方论文中的产品目标：面向 AI、边缘服务器、工业控制和 ADAS，并预计到 2022 年相关玄铁 910 产品总量达到 1500 万颗。该数字是 2020 年材料中的预期，不是本文核验的实际出货量。

![第三篇图 30：Hot Chips 2024 展示的 TH1520 芯片，并非作者测试的那一颗](assets/xuantie910_papers/chipsandcheese/30_th1520-chip.jpg)

作者的批评更集中在“结构平衡”与“存储供给”：

- 文章所称的 ROB 指令容量较大，但常用调度器和可用于推测状态的物理寄存器较少，可能无法充分利用远距离窗口；
- TH1520 上的共享 L2 既小又慢，且核心与共享 L2 之间没有中间级 Cache；
- 实测 L2 读带宽扩展性和 DRAM 持续读带宽偏低；
- 核心因 L2 延迟和带宽不足而需要更多在途工作，但支撑结构又可能先满，形成互相强化的限制；
- 向量指令提高单位指令的数据需求，若存储层次不能持续供数，向量执行能力也难以充分利用。

原文最后希望平头哥利用 C910 的经验继续改进后续核心，并认为阿里巴巴的支持应能提供充足研发资源；作者也希望看到更多开源乱序设计。作者特别肯定公开 RTL 的研究价值：研究者能直接看到微操作格式如何随流水阶段变化，也能理解“译码”实际上分散在早期边界识别、主译码、重命名控制补充等多个阶段，而不是只存在于名为 Decode 的一级。

原文最后还有支持 Chips and Cheese 的 Patreon、PayPal 和 Discord 邀请；与处理器技术无关，在此完整记录其存在而不展开宣传链接。

## 综合核查：第三篇最有价值的结论与限制

第三篇最有价值之处不是一句“C910 存储系统弱”，而是提供了可以继续验证的机制链：

```text
TH1520 上 L2 约 60 周期、四核 L2 读带宽扩展有限、DRAM 读带宽低
                         ↓
核心需要更多独立指令和并发 miss 来隐藏等待
                         ↓
常用 ALU 调度器、物理寄存器、LQ/LFB 等资源可能先于文章所称的 ROB 容量耗尽
                         ↓
后端反压、not-ready 等待和 ROB 头部 load 阻塞上升
                         ↓
零退休周期增加，实际 IPC 下降
```

这条链中的结构容量多数可从 RTL 核对，平台延迟与带宽可由微基准观测，但“哪一项是某个实际 benchmark 的第一瓶颈”仍需性能计数器和单变量 RTL 实验回答。合理的研究顺序是先按 case 建立证据，再决定扩调度器、增 PRF、提高 miss 并行度，还是优化 L2/互连。直接同时修改多项结构会失去归因，也无法判断收益来自哪里。

同样，文章的前端结论应拆成两部分：L1 I-Cache 内可维持 3 IPC，说明小代码工作集下峰值供给与三宽译码匹配；代码落入 L2 后低于 1 IPC，说明大代码工作集可能暴露取指下层延迟或带宽。要确认当前 RTL 是否同样受限，需要扫描代码 footprint，并同步采集 I-Cache/ITLB miss、IB 空、BTB miss 和取指请求延迟，而不是直接套用 TH1520 数值。

---

# 图表完整性与图内英文对照

本节用于核对图表是否遗漏，并集中解释原图中因保持原始视觉内容而仍然显示为英文的标签。第一篇论文共 21 幅编号图和 2 张编号表，已全部嵌入；第二篇演示稿共 19 页，已逐页完整嵌入；第三篇 HTML 正文中的 30 幅技术图也已按原顺序全部保存并嵌入。图中的模块缩写保留原样，是为了能够与论文、演示稿、第三方分析和 RTL 模块名对应。

## ISCA 论文的 21 幅图

| 图号 | 原图主题 | 图内英文标签的中文对应 |
|---|---|---|
| 图 1 | U、S、M 特权模式 | User-mode / User processes：用户态 / 用户进程；Supervisor-mode / Hypervisor and kernel：监管者模式 / hypervisor 与内核；Machine-mode / Low-level access to machine; Inherently trusted：机器态 / 机器级底层访问、固有可信 |
| 图 2 | 四核簇 | Branch Prediction：分支预测；Instruction Fetch：取指；I-Cache / D-Cache：指令 / 数据 Cache；Decoder：译码器；Rename：重命名；Dispatch：分派；Issue Queue：发射队列；Physical Register File：物理寄存器文件；Write Back：写回；Coherence Bus：一致性总线；ALU/VEC/FPU/BJU/LSU/MMU TLB/HAD 分别为算术逻辑、向量、浮点、分支跳转、访存、内存管理与地址转换、硬件辅助调试单元 |
| 图 3 | 单核与双核版图 | Layout of a single-core, with vector execution unit and 512KB L2 cache：带向量执行单元和 512 KB L2 的单核版图；ciu/lsu/rtu/idu/vfpu/ifu/iu/mmu：一致性互联、访存、退休、译码、向量浮点、取指、整数执行和内存管理模块；L2 cache：二级 Cache |
| 图 4 | 12 级流水线 | instruction fetch：取指；instruction decode & issue：指令译码与发射；Load/Store pipe：访存管线；Branch pipe：分支管线；ALU/DIV pipe：ALU/除法管线；ALU/MUL pipe：ALU/乘法管线；Vector (VFPU) pipe：向量/向量浮点管线；AG/DC/DA：地址生成/数据 Cache/数据对齐；BR：分支执行；WB：写回 |
| 图 5 | IFU 三级流水 | PC Gen：PC 生成；allocate：分配；Chgflw IF/IP/IB：IF、IP、IB 级控制流改变；I-Cache：指令 Cache；Inst Pack：指令打包；Inst Buffer：指令缓冲 |
| 图 6 | 两级预测缓冲 | BUF1/BUF2：一级/二级预测值缓冲；Branch prediction result：分支预测结果；上方重复小格表示多个预测 SRAM 存储体 |
| 图 7 | 循环缓冲 | cycle0–cycle4：第 0–4 周期；inst0 等：第 0 条等指令；Bubble：流水空泡；inst from I-Cache / inst from LBUF：来自 I-Cache / LBUF 的指令 |
| 图 8 | 推测失败恢复 | Flush FE/IR/IS/BE：清空前端/重命名级/发射级/后端；Stall IR：阻塞重命名级；Retire Flush / Jmp Mispred Flush：退休级发起清空 / 跳转误预测清空；BHT Mispred Cancel and Flush：取消分支历史表误预测并清空流水 |
| 图 9 | LSU 流水 | LD PIPE / ST PIPE：load / store 管线；Addr gen：地址生成；TLB：地址转换缓冲；D-Cache：数据 Cache；LQ/SQ：load/store 队列；ST TAG：store tag 阵列；Align：数据对齐；Early forward：提前转发；Writeback/WB：写回；Linefill/Victim：Cache line 填充/被替换行；BUS/DS：总线/DS 接口，原文未展开 DS 缩写 |
| 图 10 | store 地址与数据分离 | Load/Store Issue Queue：load/store 发射队列；Store Issue Queue：store-data 发射队列；ld/st.addr/st.data：load、store 地址、store 数据微操作；AGU：地址生成单元；DATA Cache：数据 Cache；Store Queue：store 队列 |
| 图 11 | 多模式预取 | ld/st inst. flow：load/store 指令流；seq_dect：访问序列检测；Global mode：全局模式；multi_stream mode：多流模式；data prefetch：数据预取 |
| 图 12 | 多页 TLB | uTLB full-associated：全相联 uTLB；jTLB Tag Array Way-associated：组相联 jTLB tag 阵列；Valid：有效位；VPN A/B/C/D/X：示例虚拟页号；4K/2M/1G：条目页大小；G：全局映射位；Index_4K/2M/1G：按 4 KB/2 MB/1 GB 页索引；refill when hit：命中后回填；miss va[38:0]：未命中的虚拟地址 |
| 图 13 | 多核框图 | Core0–Core3：一个簇内的四个处理器核；L2 SLICE0/1：两个 L2 分片；Snoop Filter：侦听过滤器；CPU0–CPU3：连接到 Ncore 的四个 CPU 簇节点，其中 CPU0 在左侧展开；Ncore：多簇互连；NPU0/1：NPU 节点；DDR0/1：外部内存通道；CAI/NCB/CMI 为 Ncore 接口模块缩写，原文未展开全称 |
| 图 14 | 向量流水 | VIQ0/VIQ1：向量发射队列 0/1；Flag Physical Register File：标志物理寄存器文件；Vector Physical Register File：向量物理寄存器文件；VFPU：向量浮点/整数执行单元；VDSP：向量 DSP 执行单元；EX1–EX5：执行第 1–5 级 |
| 图 15 | 编译工具链 | C/C++ Code / Assembly Code / Lib/object/data Files：C/C++ 代码 / 汇编代码 / 库、目标和数据文件；Preprocessor / Runtime Library：预处理器 / 运行库；Instruction Mapping / Call Conversion / Optimize Passes / Pipeline Scheduler：指令映射 / 调用转换 / 优化过程 / 流水调度器；Assembler / Linker / CPU BFD：汇编器 / 链接器 / CPU 二进制文件描述后端；Executable File / Library or object File / Map-Symbol File：可执行文件 / 库或目标文件 / 映射与符号文件 |
| 图 16 | 性能分析工具 | Total Function Cycles Rank：函数总周期排名；Insn Cache / Data Cache / Branch Predict：指令 Cache / 数据 Cache / 分支预测；refs/miss/miss rate：访问/未命中/未命中率；Instruction Count Rank：指令数量排名；Timeline / Function / Call Paths：时间线 / 函数 / 调用路径；Executed Instructions / Locations：已执行指令 / 代码位置。更完整的界面对照见 Hot Chips 第 14 页 |
| 图 17 | CoreMark | CoreMark/MHz：每 MHz 的 CoreMark；In-order processor / Out-of-order processor：顺序执行 / 乱序执行处理器；各柱名称为被比较的处理器型号 |
| 图 18 | EEMBC | Cortex-A73 / XT-910：两种处理器；automotive / consumer / networking / telecom：汽车电子 / 消费电子 / 网络处理 / 电信处理；纵轴百分比表示以 A73 为 100% 的归一化性能 |
| 图 19 | NBench | Assignment / Bitfield / Fourier / FP Emulation / Huffman / IDEA / LU Decomposition / Neural Net / Numeric Sort / String Sort：赋值 / 位域 / 傅里叶 / 浮点模拟 / 霍夫曼编码 / IDEA 加密 / LU 分解 / 神经网络 / 数值排序 / 字符串排序；纵轴为归一化性能 |
| 图 20 | 扩展与编译优化 | Native RISC-V ISA + standard compiler：原生 RISC-V ISA 与标准编译器；XT-910 with instruction extension + optimized compiler：XT-910 指令扩展与优化编译器；EEMBC/NBench/OpenSSL 为三个测试组；纵轴为相对性能百分比 |
| 图 21 | 预取结果 | prefetch performance：预取性能；average：平均值；stream-triad/add/scale/copy：Stream 三元组/加法/缩放/复制；a–e 对应正文列出的五种 L1、L2、TLB 预取配置；横轴为相对关闭预取基线的性能倍数 |

## ISCA 论文的 2 张表

| 表号 | 完整性 | 中文对应位置 |
|---|---|---|
| 表 I，XT-910 Core Configurations | 原表图已嵌入，5 个配置项全部转录 | “表 I：XT-910 核配置”，包括每簇核心数、L1 D/I Cache、L2 Cache 和向量扩展 |
| 表 II，Results of XT-910 Core in 12 nm FinFET | 原表图已嵌入，3 个指标和 a/b/c 三条脚注全部转录 | “表 II：12 nm FinFET 下的 XT-910 核结果”，包括频率、面积、动态功耗及工艺、电压、温度条件 |

## Hot Chips 演示稿的 19 页

| 页码 | 原页标题的中文对应 | 页面内容覆盖情况 |
|---:|---|---|
| 1 | 玄铁 910：以 RISC-V 创新云计算与边缘计算 | 标题、演讲人和品牌已译，整页原图已嵌入 |
| 2 | 开源，共建新 AIoT 时代的芯片生态 | 标语和全部作者姓名已保留，整页原图已嵌入 |
| 3 | 构建 AIoT 时代的芯片基础设施 | 云、应用领域、AliOS、领域专用 SoC、RISC-V 处理器和领域专用架构各层已译 |
| 4 | 持续演进的玄铁处理器架构 | 902、在研 9xx 和 910 的三段说明已译 |
| 5 | 玄铁 910 超高性能架构 | 12 条主要能力、框图模块和目标场景已译 |
| 6 | 显著的性能 | 8 个处理器的 CoreMark/MHz 数值、40% 对比和 4 条数据来源已保留 |
| 7 | 兼容 RISC-V 规范 | ISA、向量、特权模式、内存管理和中断控制已逐项译成表格 |
| 8 | 扩展增强：RISC-V Turbo | 6 类扩展和 3 组归一化 benchmark 已译，并说明图中没有柱顶精确值 |
| 9 | 深度超标量乱序流水线 | 前后端要点以及 IF 到 WB 的各条执行管线已译 |
| 10 | 采用混合预测的取指单元 | 4 类预测、4 项高带宽取指能力及预测器框图已译 |
| 11 | 双发射乱序 Load/Store 单元 | 乱序发射、快速完成、预取能力和 LD/ST/ST_DATA 路径已译 |
| 12 | 高效率多核互连 | PIUx、MOESI、目录、snoop filter、L2、ECC 及接口模块已译 |
| 13 | 面向 AI 优化的向量计算引擎 | 数据类型、256 位计算、128 位访存、乱序执行和峰值公式已译 |
| 14 | 高效率性能分析引擎 | 截图内可辨认的仪表、图、表、菜单、字段和指令分类已逐项对照 |
| 15 | 实验结果 | EEMBC 与 NBench 的图例和所有子项均已给出中英文对应 |
| 16 | FPGA 演示 | 原页所有视觉内容已保存；原页无负载、帧率或型号说明，因此未作推测 |
| 17 | ASIC 实现 | 工艺、频率、面积和 a/b 工艺条件已完整转录 |
| 18 | 搭载玄铁的无剑 SoC 平台 | “设计时间降低 50%”与“设计成本最多降低 50%”已译并注明宣传数据边界 |
| 19 | 总结 | 超标量、RISC-V Turbo、乱序存储子系统和向量引擎四项结论已译 |

## Chips and Cheese 独立分析的 30 幅图

| 图号 | 图的作用 | 阅读重点与英文标签对应 |
|---:|---|---|
| 1 | 平头哥产品线与 C910 架构概览 | High Performance / Efficient Computing / Embedded / MCU：高性能 / 高效计算 / 嵌入式 / 微控制器；C910 位于高性能层级 |
| 2 | 作者标注的单核版图 | 红字为 Chester Lam 添加的模块说明，不是原始论文标注；PIU/PLIC 在双核图出现 |
| 3 | 双核版图 | 观察两个核心、共享或接口逻辑的物理布局关系 |
| 4 | 官方 12 级流水 | IF/IP/IB/ID/IR/IS/RF/EX/WB/RT 分别对应取指、打包、缓冲、译码、重命名、发射、寄存器读取、执行、写回和退休 |
| 5 | 核心高层框图 | 作者把前端、乱序后端、执行端口、LSU、Cache 和 TLB 串成一张结构图 |
| 6 | L1 I-Cache 存储组成 | Data/Predecode/Tag：指令数据 / 预译码 / 标签；总原始位存储约 83.7 KB，不等于软件可用容量 |
| 7 | 简化前端草图 | 两路各读 128 位并各过 8 路早期译码，最终仅保留命中一路 |
| 8 | 分支预测资源 | BHT/BTB/GHR/RAS/Indirect Target Array：方向表 / 目标缓冲 / 全局历史 / 返回栈 / 间接目标数组 |
| 9 | C910 分支模式测试 | Array (Pattern) Length：模式数组长度；Branches in Loop：循环中的分支数；Difference Between Random/Predictable：随机与可预测模式的耗时差，单位 ns；曲面不是直接的“准确率百分比” |
| 10 | Cortex-A73 分支模式测试 | 与图 9 使用相同三轴定义，提供低功耗乱序核参照 |
| 11 | taken 分支延迟 | 横轴 Branches in Loop：循环分支数；纵轴 Cycles Per Branch：每分支周期；四条线表示每 4/8/16/32 B 放置一个分支；BTB 容量内约 2 周期，溢出主 BTB 但仍命中 I-Cache 时约 4 周期 |
| 12 | 译码与重命名流 | 每周期 3 条 ISA 指令入口、最多 4 个微操作输出；译码后直接进入重命名 |
| 13 | 微操作格式笔记 | 73/178/271 位是不同阶段的内部打包宽度，包括控制元数据，不是数据通路计算位宽 |
| 14 | 代码工作集与前端吞吐 | 横轴 Test Size (KB)：测试代码大小；纵轴 Instructions/Cycle：每周期指令数；蓝线为使用 2 MB 大页的 C910，红线为 P550；C910 在 64 KB I-Cache 内接近 3 IPC，进入下级后明显下降 |
| 15 | ROB 有效容量测试 | 横轴为两次指针追踪 load 之间的 NOP 数；纵轴为两次 Cache miss 的延迟；约 181 个 NOP 处出现 288.8 ns 标注和台阶，作者据此认为软件可见容量接近 192；原文另行指出 RTL 文件定义了 64 个 ROB 表项，但未解释二者关系 |
| 16 | 后端容量对照 | ROB、整数/浮点物理寄存器、LQ/SQ 等容量；跨架构定义可能不同，只比较量级 |
| 17 | 整数调度与端口 | 两个常用 ALU 端口、一个分支端口及存储相关端口；常用 ALU 调度容量约 16 项 |
| 18 | 浮点/向量调度与端口 | 两条常见浮点/128 位向量管线；FMA 与掩码操作需要较多寄存器读端口 |
| 19 | 浮点延迟对照 | C910 加/乘/FMA 为 3/4/5 周期；图中同时给出 P550、A73 |
| 20 | 官方 LSU 流水 | LD PIPE/ST PIPE：load/store 管线；地址、TLB、Cache、队列、对齐和写回路径 |
| 21 | JTLB tag 格式 | 256 组×4 路、16 位 ASID、global 与 FIFO 状态；统一承接指令和数据 uTLB miss |
| 22 | LQ 容量微基准 | 横轴为两次 Cache miss 之间插入的 load 数，纵轴为两次 miss 的延迟；红线 Just loads：仅 load，蓝线 Dependent Branch Blocking Retire：用相关分支阻塞退休；曲线并无唯一清晰拐点，RTL 指向约 12 项 |
| 23 | Store-to-load 转发图 | 列为 32 位 load 偏移，行为 64 位 store 偏移；每格给出相应组合的测量值，绿色约 1、黄色约 2、红色常为 10–32；红色对角带显示不能直接转发的重叠/跨边界组合 |
| 24 | L1 D-Cache 存储组成 | 64 KB、2 路、分 bank；load/store tag 阵列分离 |
| 25 | L2 存储组成 | TH1520 为 1 MB、16 路、双 bank、FIFO、ECC；软件可见容量与原始 SRAM 位数不同 |
| 26 | Cache/内存延迟 | 标题中的 2 MB Pages 表示使用 2 MB 页；横轴为测试大小 KB，纵轴为延迟周期；蓝线 C910 的 L1 约 3 周期、L2 标注 59.57 周期，红线 P550 的下级平台标注 13.06 与 38.11 周期 |
| 27 | 四核读取带宽 | 横轴为测试大小 KB，纵轴为 GB/s；蓝/红/绿分别为 TH1520 四核 C910、EIC7700X 四核 P550、Celeron J4125 四核 Goldmont Plus；图上标出 C910 L2 约 12.64 GB/s、DRAM 约 4.17 GB/s |
| 28 | DRAM 平台对照 | All-Core DRAM Read Bandwidth / Latency：全核 DRAM 读带宽 / 延迟；四个平台的全部精确值已在第三篇正文表格转录；比较的是完整 SoC 平台 |
| 29 | 核间延迟矩阵 | 行列为核编号，单位 ns；对角线不是跨核传输；12 个非对角线数值已在正文完整转录，范围 61.75–64.05 ns |
| 30 | TH1520 芯片照片 | 摄于 Hot Chips 2024；原文明确说明并非作者实际测试的那一颗芯片 |

此完整性清单中的“全部”指两份 PDF 的技术正文、标题、项目符号、图、图注、表、表注、致谢和参考文献，以及第三篇 HTML 的正文、标题、引文、图和图注。网页导航、评论、点赞数、登录控件和订阅界面不属于文章正文，未并入技术文档；原文结尾的赞助与社区邀请已在第三篇结尾说明。IEEE 授权下载页脚不在每页重复翻译，已在“文档说明”统一记录；品牌、处理器型号、人名、URL、代码缩写和标准专名保留原文，以免失去唯一对应关系。

---

# 三份材料的信息对应关系

下表只并列三份材料各自采用的口径，不把它们强行归并成一组唯一参数。某一列没有给出的细节，不代表该结构不存在；第三篇的平台实测也不覆盖官方 IP 的所有可配置实现。

| 主题 | ISCA 官方论文 | Hot Chips 官方演示 | Chips and Cheese 独立分析 |
|---|---|---|---|
| 定位 | 完整工业论文，解释设计动机与实现 | 产品化架构与生态展示 | RTL 阅读与 TH1520 实机微基准互证 |
| 核心参数 | 12 级流水、3 指令译码、最多 8 条发射、ROB 最多容纳 192 条指令（按论文原文） | 12 级流水、3 指令译码、8 发射 | RTL 文件定义 64 个 ROB 表项；官方称最多 192 条指令；作者微基准大体接近 192；96/64 项整数/浮点物理寄存器 |
| IFU | 三级 IF/IP/IB、混合预测、L0/L1 BTB、16 项 LBUF | 混合多模式预测、128 位取指、最多打包 8 条（按演示稿原文） | 两路各读 128 位但只保留命中一路；给出 BHT、GHR、RAS、间接表容量及模式测试 |
| 译码与重命名 | 3 指令译码、寄存器重命名 | 深流水超标量后端 | 每周期最多 4 微操作；73/178/271 位阶段格式；无独立微操作队列 |
| 调度与执行 | 分布式发射、整数/浮点/向量/访存执行 | 8 发射与多执行管线 | 常用 ALU 调度约 16 项；执行端口和 FP 3/4/5 周期延迟实测 |
| LSU | load/store 双发射、LQ/SQ、地址/数据拆分、推测失败预测 | 3 周期 load-to-use、1 周期 store、独立 ST_DATA | 17 项数据 uTLB、1024 项 JTLB；转发与非对齐边界；LQ 容量结论保留不确定性 |
| 存储层次 | 32/64 KB L1、最高 8 MB 包含式 L2、多尺寸 TLB | 32/64 KB L1、最高 8 MB L2、ECC | TH1520 的 64 KB L1、1 MB L2；实测 L2 约 60 周期及多核带宽 |
| 一致性 | 原文写 MOSEI，含 snoop filter | 明确写 MOESI、目录式架构、snoop filter | 结合 RTL 说明双 SNB、每个 24 项 SAB、512 位 L2 接口；测量核间延迟 |
| 向量 | Vector 0.7.1、双发射乱序、64 位 slice、建议 2×128 位 | 256 位运算、2×128 位管线、每簇 FP16 超过 300 GFLOPS | 两条 128 位向量执行管线，并指出共享 L2/DRAM 供给可能限制有效吞吐 |
| 工艺与平台 | TSMC 12 nm；0.6/0.8 mm²；2.0–2.5 GHz | 同一组 ASIC 数据 | LicheePi 4A/TH1520：12 nm、1.85 GHz、1 MB L2、LPDDR4X-3733 |
| 性能证据 | CoreMark、EEMBC、NBench、SPECInt2006、Stream | CoreMark、EEMBC、NBench | 定向延迟、容量、转发、带宽和核间传输微基准，不是标准整机性能认证 |
| 主要局限 | 官方配置和测试细节并非全部公开 | 宣传表达简短，缺少测量方法 | 单一 SoC 平台；微基准与 RTL 归因仍可能有误，作者已主动声明 |

# 从体系结构角度串联全文

本节是本文作者为了教学而作的跨材料分析，不属于三份原文，也不用于消除三份材料之间的差异。涉及具体容量或实测值时，仍应回到对应篇章确认其来源、平台和表述口径。

## 总论：处理器不是参数清单，而是一条动态供给链

观察一个乱序处理器时，最容易犯的错误是把某个大数字直接等同于性能：取指 128 位、8 发射、192 条指令窗口、256 位向量、8 MB L2，看起来都很强，但它们只是各局部机制在特定条件下的上限。程序的持续吞吐更接近下面这组能力中的最小值：

> 有效取指供给、译码与重命名接收、各类调度与发射、操作数就绪速度、执行端口吞吐、load 数据返回、按序退休

这是一条动态供给链，而不是一条静态参数链。分支误预测会让前端供给变成无效工作；长依赖链会让调度器里有指令却没有就绪指令；Cache miss 会占住 ROB、物理寄存器和 LQ；退休端的老指令等待又会阻止所有年轻指令释放资源。于是，同一个结构既可能是某个程序的性能上限，也可能在另一个程序中几乎没有被使用。

从排队系统角度看，IFU、IBUF、译码、ROB、IQ、LQ/SQ、LFB 和总线队列都是生产者与消费者之间的缓冲。缓冲太小，短暂波动就向上游传播为停顿；缓冲很大但消费者长期供给不足，只会积累更多等待者。优秀微结构的目标不是把每个队列都做大，而是用合理面积和能耗吸收最常见的延迟波动，同时避免某个小结构过早截断全局窗口。

### 体系结构旁白：宽度是承诺，有效吞吐才是兑现

标称宽度描述理想周期能通过多少工作，有效吞吐还要乘上“有工作、工作正确、资源可接收、操作数就绪、目标端口可用”等条件。可以把某一级的有效利用率抽象成：

> 有效吞吐 = 峰值宽度 × 有效槽比例 × 下游接受比例

这个公式不是精确性能模型，却能提醒研究者：扩大宽度只有在空槽和反压都不是主要问题时才有收益。若三路译码经常只有一路有效，应先处理供给；若译码已有三路有效而重命名频繁阻塞，应处理后端资源；若发射宽度很大但多数 IQ 项 not-ready，应找依赖生产者，而不是继续增加端口。

### 体系结构旁白：预测、乱序和存储层次是三种“提前”

高性能处理器隐藏延迟主要依赖三类提前行为：

1. **分支预测提前选择控制流。** 在真实分支执行前猜测下一段指令，从而避免前端停下来等待。猜错的代价是错误路径工作和流水恢复。
2. **乱序执行提前寻找独立工作。** 当老指令等待数据时，从更年轻的指令中挑选已就绪者执行。代价是 ROB、重命名、调度、回滚和精确异常的复杂度。
3. **Cache 与预取提前准备数据。** Cache 利用时间和空间局部性保存未来可能重用的数据，预取器进一步在正式 load 之前发起请求。猜错会造成污染、带宽和功耗开销。

三者解决的是同一个根本问题：现代存储和控制依赖的延迟远大于一个流水级，核心必须在结果真正需要之前开始行动。它们也遵守同一个原则：提前得越激进，潜在收益越大，错误工作的代价也越高。因此，评估机制不能只看命中率或覆盖率，还要看错误代价、资源占用和是否真正缩短退休关键路径。

## 一、先区分 ISA、微结构与实现

ISA 规定软件可以看见什么，例如 RV64GCV 指令、寄存器、特权模式、异常和地址转换规则。微结构规定处理器如何实现这些语义，例如采用几级流水、多少项 ROB、怎样预测分支、如何调度 load/store。物理实现则回答微结构在特定工艺上能跑多快、多大、多耗电，例如 12 nm、0.8 V/1.0 V、LVT/ULVT、面积和频率。

同一 ISA 可以有完全不同的微结构；同一微结构移到不同工艺、标准单元和 Cache 宏后，也会得到不同频率与功耗。因此，“RISC-V 性能”和“12 nm 下 XT-910 的性能”不是同一层结论。论文中的定制指令属于 ISA 扩展，乱序执行和混合预测属于微结构，2.5 GHz 与 0.8 mm² 属于物理实现结果。

## 二、性能由指令数、CPI 和频率共同决定

单线程执行时间可以写成：

> 执行时间 = 动态指令数 × CPI ÷ 时钟频率

这个式子给出了三条优化路径：编译器或定制指令减少动态指令数；微结构提高 IPC、降低 CPI；电路与流水划分提高频率。三者会相互影响。更深的流水可能提高频率，却增加误预测恢复代价；复杂定制指令可能减少指令数，却增加译码或执行关键路径；更激进的预取可能降低等待 CPI，却提高带宽和功耗。

为理解 CPI，可将额外周期按原因分类为前端供给不足、后端依赖/端口/容量阻塞、存储层次等待和错误推测恢复。但这些事件可能在同一周期重叠，不能把所有 stall 百分比直接相加。更可靠的分析要从退休端出发：先找出没有达到退休宽度的周期，再判断当时 ROB 头部在等什么，以及更前面的队列为什么没有准备好可退休工作。

分支误预测对 CPI 的粗略贡献可用“每条指令的误预测次数 × 平均恢复代价”估计；Cache miss 的贡献还要考虑多个 miss 是否并行、乱序窗口是否有独立工作以及预取是否及时。若多个 miss 可以重叠，简单使用“miss 数 × 单次内存延迟”会严重高估停顿。

## 三、前端要评价的是有效供给，不是标称取指宽度

128 位取指、最多 8 条打包和 3 条译码构成由宽到窄的前端。压缩指令比例、跨边界取指、I-Cache 与 ITLB miss、BTB 命中、方向预测和 IBUF 水位共同决定每周期真正送入后端的有效指令数。错误路径上的取指和译码虽然消耗带宽，却不会形成退休指令。

若前端是瓶颈，常见证据链是：译码入口长期缺少有效指令，同时 IBUF 经常为空；再向前追踪，可看到 I-Cache/ITLB miss、BTB miss、分支误预测或重定向占用较高。若 IBUF 中一直有指令但译码后端不接收，则问题通常不是取指本身，而是重命名资源、ROB、发射队列或 load/store 队列反压。

## 四、乱序窗口要评价的是可利用的指令级并行性

ROB 提供“向前看”的范围，发射队列负责从范围内选择已就绪操作，物理寄存器保存不同推测版本。它们共同把程序中潜在的指令级并行性转化为执行端口利用率。窗口大并不自动带来高 IPC：

1. 长 RAW 依赖链会使大量年轻指令等待同一个生产者。
2. 某类端口过少会使已就绪指令排队，例如乘除法、分支或 AGU 冲突。
3. ROB、IQ、物理寄存器、LQ 或 SQ 任一资源先满，前端都会被迫停止。
4. ROB 头部若等待长延迟 load 或异常处理，后续已完成指令也不能越过它退休。
5. 分支或内存次序误推测会清除已经完成的错误工作，降低有效 IPC。

因此应把“未发射”继续拆成操作数未就绪、端口不可用和结构资源阻塞；把操作数未就绪继续按生产者分成整数、乘除法、分支、浮点、向量和 load 返回。这样才能回答“not-ready 指令到底在等谁”。

### 体系结构旁白：用 Little 定律估算“需要多少在途工作”

排队论中的 Little 定律给出一个非常有用的量级关系：

> 平均在途数量 = 平均吞吐率 × 平均停留时间

假设某级存储延迟为 `L` 周期，希望持续获得 `B` B/cycle，而每个 Cache line 为 64 B，则仅从量级上看，需要的并发 line 请求约为：

> 并发请求数 ≈ `B × L ÷ 64`

例如，用第三篇 TH1520 实测的约 60 周期 L2 延迟作教学假设，若希望获得 8 B/cycle，理论上就需要约 `8 × 60 ÷ 64 = 7.5` 个并发 Cache line 请求。这已经接近文中提到的 8 个 LFB。这个计算不能证明 LFB 是实际瓶颈，因为请求还可能命中不同层级，且 LQ、依赖关系、bank、总线和预取都会改变结果；但它能说明为什么“8 项听起来不少”在 60 周期延迟面前可能几乎没有余量。

对指令窗口也可做类似量级思考。若核心希望在 60 周期等待期间维持 3 instructions/cycle，就需要看到约 180 条独立或可继续推进的指令。这个数字与官方材料所称最多 192 条指令在数量级上接近，但绝不能据此反推“192 就是为 60 周期 L2 设计的”：真实代码包含分支、依赖、store、无结果指令和不能完全聚合的指令，且调度器、物理寄存器与访存队列会更早限制可用窗口。Little 定律用于判断数量级是否匹配，不用于替代 RTL 和实验。

### 体系结构旁白：ROB 提供视野，IQ 和 PRF 决定视野能否使用

可以把 ROB 看成处理器观察未来指令的“视野范围”，把 IQ 看成等待执行的工作台，把 PRF 看成保存推测版本的状态空间。只扩大 ROB，处理器也许能看见更远，却未必能把那些指令留在正确的工作台上，也未必有物理寄存器保存结果。只扩大 IQ，若前端供给不足或 ROB 很快满，也无法填满新增项。只扩大 PRF，则可能只是让空闲寄存器变多，而没有增加可发射工作。

因此，结构平衡不是要求所有队列项数相等，而是要求它们对目标程序的有效容量相匹配。判断依据应是“谁经常第一个满、谁长期占用、扩谁能让退休前进”，而不是哪一个绝对数字最小。优秀的容量实验还要观察瓶颈是否迁移：扩 IQ 后若 PRF full 上升，说明优化有效但下一限制已经出现；若扩 IQ 后目标 stall 不变，则原归因可能错误。

## 五、LSU 是乱序正确性与大工作集性能的交汇点

load/store 同时涉及地址转换、Cache、内存次序和外部带宽。小工作集命中 L1 时，3 周期 load-to-use、AGU 数量、store-to-load forwarding 和 Bank 冲突更重要；大工作集下，L2/内存延迟、TLB、未完成 miss 容量、预取与带宽开始主导。

分析存储瓶颈可以按以下因果顺序进行：

1. 先看 load/store 动态占比和每千条指令的各级 Cache/TLB miss。
2. 再看 miss 的平均与尾部延迟、并行未完成请求数，以及 ROB 头部因 load 等待的周期。
3. 检查 LQ/SQ 满、AGU/Cache 端口冲突、store-forward 失败和内存次序回放。
4. 对预取分别测覆盖率、准确率、及时性、污染和额外带宽。
5. 用关闭/开启单个机制的对照实验确认周期变化，而不是仅凭相关性下结论。

论文的 Stream 实验属于规则流、高延迟环境，适合证明多级预取的潜在上限；SPECInt2006 更能暴露不规则访问、大工作集和完整内存系统的综合限制。两者用途互补，不能互相替代。

## 六、多核与向量性能都受数据供给约束

多核增加并行线程，向量增加单条指令处理的数据元素数，但两者最终都要从 Cache 和内存取得数据。多核还增加一致性与共享资源竞争；向量则可能产生更高的瞬时 load/store 带宽需求。理论峰值只有在数据布局、局部性、并行度和软件向量化都合适时才能接近。

对多核，应报告 1/2/4/更多核心的加速比、每核 IPC、共享 L2 miss、互连流量和内存带宽；对向量，应报告向量化比例、平均 VL、执行单元利用率、向量 load/store 带宽、重排开销和标量剩余部分。只报告核心数、位宽或 GFLOPS 峰值，无法说明真实应用效率。

### 体系结构旁白：计算能力越强，数据供给问题越容易暴露

向量化和增加核心数都在扩大单位时间的数据需求。若一个标量循环原本由 ALU 吞吐限制，向量化可以显著加速；当计算时间缩短到低于取数时间后，瓶颈会迁移到 L1 端口、L2、互连或 DRAM。此时“向量单元利用率低”不一定表示向量执行器设计差，可能表示执行器一直在等数据。

这也是 roofline 思想的核心：程序性能上限由计算峰值和“内存带宽 × 运算强度”二者较小者决定。提高向量宽度抬高计算屋顶，提高 Cache/内存带宽抬高带宽斜线；若程序运算强度不变且已经位于带宽区，继续增加计算单元几乎不会提高性能。多核扩展同理：单核尚未吃满内存时可以近似线性扩展，一旦共享 L2 或 DRAM 饱和，更多核心只是在争抢同一资源。

对 C910 的研究价值在于，它把这个权衡展示得很清楚：官方材料强调向量吞吐和多核扩展能力，第三篇则在特定 TH1520 平台上观察到共享 L2 与 DRAM 供给压力。二者不是互相否定，而是在回答不同问题：前者说明核心具备什么计算机制，后者说明某个实际 SoC 能否持续为这些机制供数。

## 七、把论文机制转化为可验证的实验

| 论文机制 | 主要目标 | 最直接的观测量 | 建议的对照实验 |
|---|---|---|---|
| L0/L1 BTB、方向预测、RAS | 减少错误路径和重定向气泡 | 各类分支 MPKI、BTB miss、恢复周期、错误路径指令 | 固定二进制，对比预测器组件或容量 |
| IBUF、LBUF | 平滑前端供给、加速短循环 | 缓冲空/满周期、译码有效条数、LBUF 命中与覆盖 | 启停 LBUF；按循环体大小分组 |
| 64 个物理 ROB 表项、最多约 192 条折叠指令容量与多队列发射 | 隐藏长延迟、利用指令级并行 | 物理表项和折叠指令占用、IQ 占用、not-ready 来源、端口冲突、零退休周期 | 分别改变表项/折叠或队列容量；按依赖链 benchmark 对比 |
| 双发射 LSU 与 store 拆分 | 增加访存并行、提前解析地址 | LD/ST 发射率、AGU 冲突、SQ/LQ 满、转发和回放 | load-only、store-only、混合读写及别名压力测试 |
| 多级 TLB 与大页 | 降低地址转换等待 | 各级 TLB MPKI、页表遍历、TLB stall | 4 KB 与大页；不同地址空间工作集 |
| 多模式预取 | 隐藏 Cache/内存延迟 | 覆盖率、准确率、及时性、污染、带宽 | 分别启停 L1/L2/TLB 预取并扫描距离 |
| 定制指令和编译优化 | 减少指令数与关键链 | 动态指令数、代码大小、IPC、端口利用率 | 三组 ISA/编译器配置分离软硬件收益 |
| 向量双发射 | 提高数据并行吞吐 | 向量化比例、VL、VFPU 利用率、访存带宽 | 计算密集与带宽密集 kernel 分开测试 |
| 共享 L2、MOESI、目录 | 扩展多核并保持一致性 | L2 命中、snoop、目录命中、共享 line 迁移、带宽 | 私有数据、只读共享、写共享三种模式 |

一项可信的优化结论应至少闭合四层证据：程序动态特征说明为什么会触发该机制；微结构计数器证明原瓶颈确实存在；单变量实验证明修改改变了目标事件；最终的 IPC、执行周期、频率、面积和功耗说明收益是否值得。若只看到总周期变快，却没有事件归因和 PPA 代价，就还不能说明改进来自预期机制。

## 八、从“读懂一个处理器”走向“能够做体系结构研究”

读懂框图只是第一层。真正的体系结构能力，是能把程序行为、微结构状态和最终性能连成可被反驳的因果链。一个完整研究问题通常按下面的顺序收敛：

1. **程序提出需求。** 动态指令组成、依赖距离、分支可预测性、代码与数据工作集、访存局部性说明程序会向硬件施加什么压力。
2. **微结构暴露限制。** 计数器和波形说明压力落在哪个队列、端口、预测器、Cache/TLB 或互连上，以及阻塞如何传播到退休端。
3. **机制修改改变中间事件。** 单变量 RTL 实验应先改变目标事件，例如降低某类 full 周期、减少 replay 或提高并发 miss，而不是只看最终 IPC。
4. **最终收益闭合。** 周期和 IPC 的改善必须能由中间事件变化解释，并同时检查频率、面积、功耗和验证复杂度。
5. **跨程序检验边界。** 在受益 case、无关 case 和可能退化 case 上验证，明确机制适合什么程序，而不是宣称普遍加速。

### 体系结构旁白：最大的 stall 不一定是最值得优化的机制

事件占比大只说明它与大量低利用周期同时出现，不自动说明它是根因。例如 frontend stall 可能由后端 flush 或反压间接造成；IQ not-ready 可能只是因为一个 load miss 尚未返回；ROB full 可能是退休头阻塞的结果。更可靠的问题不是“哪个计数器最大”，而是：

> 如果只改变这个机制，关键路径上的退休进度是否会改变？

这要求使用干预实验。临时增大队列、理想化预测器、固定 Cache 命中、缩短某级延迟或关闭某类回放，都是定位上界的实验手段。理想化实验若几乎不加速，就可以快速排除该机制；若理想化上界很大，再做可实现的小步修改。先测上界再投入 RTL 设计，通常比根据单个百分比直接改硬件更高效。

### 体系结构旁白：优化的终点是更好的约束内平衡，而不是最高 IPC

商用处理器优化的是约束条件下的整体目标。扩大预测器、队列和端口会提高面积与动态功耗，增加时钟负载、旁路复杂度和验证状态空间，还可能降低最高频率。若 IPC 提升 3%，却让频率下降 4%，实际性能反而退化；若面积上升 20% 只改善一个冷门 case，也未必是合理产品选择。

因此每项方案至少应报告：

- 性能：总周期、IPC、关键 stall 和受益程序范围；
- 时序：关键路径、最高频率和新增扇出；
- 面积：寄存器、SRAM、比较器、选择器和旁路网络；
- 功耗：翻转活动、额外读写端口和错误推测工作；
- 复杂度：恢复、异常、一致性和验证状态是否显著增加。

高水平的体系结构结论通常不是“某结构越大越好”，而是“在给定程序集合、工艺和功耗预算下，这个结构增加到某个规模后边际收益迅速下降，瓶颈迁移到另一机制”。这种结论才可以指导下一代设计，也更容易形成可靠的论文论证。

# 阅读这些数据时必须保留的边界

1. **CoreMark/MHz 不等于综合 CPU 性能。** 论文自己也指出 CoreMark 基本命中 Cache，不能代表大工作集、DDR 和完整存储层次。
2. **SPECInt2006 的 6.11/GHz 是系统配置相关数据。** 它受编译器、Cache、内存和运行规则影响，不能脱离论文配置直接与当前 RTL 仿真相除。
3. **EEMBC/NBench 图是归一化结果。** 原图没有完整公开每个绝对分数，不能从柱高推导过度精确的小数。
4. **向量版本是 0.7.1。** 它早于后来定稿的 RISC-V V 1.0，软件和编码不能直接按现代 V 1.0 假定。
5. **性能主张属于 2020 年时间点。** “当时最高性能”“未来产品计划”和市场预测应按原始发表语境理解。
6. **C910 开源 RTL 与论文商用配置不必完全等价。** Cache 容量、向量单元、核数、工艺库、编译器和 SoC 环境都可能不同，使用论文参数分析当前仓库时必须逐项回到 RTL 与配置核实。
7. **第三篇不是官方材料。** 它的 RTL 观察和微基准提供了很有价值的可验证假说，但作者本人已经声明可能存在阅读或归因错误。
8. **第三篇的延迟与带宽只代表 TH1520/LicheePi 4A 测试平台。** `60` 周期 L2、约 `4.2 GB/s` 多线程 DRAM 读取和 `61–64 ns` 核间延迟都受到 1.85 GHz、1 MB L2、内存控制器、LPDDR4X、操作系统和测试方法影响。
9. **结构容量不能直接换算 IPC。** 64 个物理 ROB 表项可折叠表示最多约 192 条指令，但实际折叠率、物理寄存器、调度器、LQ/SQ、LFB、依赖链和分支清空共同决定可利用窗口。
10. **跨处理器微基准不是标准 benchmark 排名。** P550、A73、Goldmont Plus 和 Haswell 的对照用于解释量级与设计平衡；若平台、频率、编译器、页大小和测试代码不同，不能把图中差值当成同条件产品性能结论。
