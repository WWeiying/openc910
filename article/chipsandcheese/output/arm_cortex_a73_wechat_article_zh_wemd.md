---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "arm_cortex_a73_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*Arm’s Cortex A73: Resource Limits, What are Those?*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2024 年 7 月 18 日
> - 链接：https://chipsandcheese.com/p/arms-cortex-a73-resource-limits-what-are-those

2010 年代中期以前，Arm 的 32-bit Cortex 核心进入了 Nvidia Tegra 3/4、Samsung Exynos 等大量芯片，却始终面对 Qualcomm Krait。转向 64 bit 后又不算顺利：Snapdragon 810 中的 Cortex-A57 受发热困扰，持续性能大幅下降；Snapdragon 820 改用 Qualcomm 自研 Kryo，Samsung 也在 Exynos 8890 上选择 Mongoose，而没有采用 Cortex-A72。

要让手机 SoC 厂商重新授权 Cortex，大核不能只在理论 IPC 上有竞争力。手机的功耗和温度预算会让高峰值、难持续的设计失去意义。Cortex-A73 因此抛开 A57 的基础，走向一套很不一样的架构：不再追逐更宽、更深、更快，而是用足够的性能换更好的能效。

测试平台是 Odroid N2+，SoC 为 Amlogic S922X，包含四颗 Cortex-A73 与两颗 A53。对照数据来自 Nintendo Switch 的 A57，以及 AWS Graviton 1 在更高功耗预算下实现的 A72。网页没有披露 OS/Kernel、编译器与 Flags、频率固定、预热、重复次数和误差；不同平台的 Cache、DRAM 和散热也不一致，应用图只能比较给定系统中的趋势。

![图 1：Odroid N2+ 单板机](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a73_wechat_article_zh/b26bb7a89e52169e_01_odroid_n2_plus.jpg)

*图 1：Amlogic S922X 的 A73 实现位于 Odroid N2+。后文 1 MB L2、32-bit DDR4、跨集群延迟属于这颗 SoC 的具体取舍，不是所有 A73 的固定属性。*

## 总览：两宽乱序，却很难测出传统窗口上限

A73 是双宽乱序执行核心，表面上比三宽 A57/A72 退了一步，部分 Scheduler 也更小。但更大的核心如果因热限制长期降频，峰值宽度就无法兑现；Arm 希望 A73 以更低功耗维持稳定频率。

![图 2：Cortex-A73 核心总览](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a73_wechat_article_zh/07d0cac8f4f40d06_02_cortex_a73_overview.png)

*图 2：两宽取指/译码/Rename，双整数 ALU、独立 Branch、双通用 AGU 和双 FP/Vector Pipe，64 KB L1I、32/64 KB 可配 L1D 与集群共享 L2。图中部分容量来自资料整理或测试，不能视为 RTL。*

![图 3：Cortex-A72 结构对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a73_wechat_article_zh/1237e3f2f44f8a7f_03_cortex_a72_overview.png)

*图 3：A72 为三宽，整数与访存调度队列更多，Load/Store AGU 分工固定；对照帮助理解 A73 为什么删掉多周期整数 Pipe、收窄前端，却把两条 AGU 改为通用。*

### 体系结构视角：持续性能取决于功耗密度，而不只取决于 IPC

手机性能近似由“每周期做多少工作 × 能维持多久的频率”共同决定。宽译码、大 Scheduler 和更多端口提高瞬时 IPC，也会增加切换电容、漏电与热点。若 A72 很快降频，而 A73 能维持更高稳态频率，后者即使 IPC 略低也可能更快。

验证时不能只跑几毫秒。应固定线程亲和性，连续记录频率、温度、功耗和吞吐，区分冷启动、Boost 与热稳态；跨手机比较还要控制散热器、系统调度和 SoC 电源策略。

## 前端：预测规模克制，取指容量反而增大

低功耗核心的分支预测器要在三件事间平衡：误预测会浪费性能和能量，目标给晚会饿死前端，而预测表本身也消耗面积与功耗。

![图 4：Cortex-A73 的方向模式识别](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a73_wechat_article_zh/74825f5766ac9c59_04_a73_branch_pattern.png)

*图 4：同时扫描 Pattern Length 和分支数量。A73 无法像高功耗核心那样处理大量分支与超长模式，但低延迟区域不算小；台阶之后同时混入历史不足、容量和混叠。*

![图 5：Cortex-A57 的方向模式识别](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a73_wechat_article_zh/6375cf9ee3176797_05_a57_branch_pattern.png)

*图 5：A57 的同类曲面与 A73 明显不同，却没有拉开一代级差距。两图用于比较预测行为，不是完整应用成绩。*

### BTB、间接目标与 Return

A73 的一级分支目标缓冲区（L1 BTB）只有 48 项，Taken 分支约每两周期一条。四个以内、且分支排得很密时偶尔更快。主 BTB 约 3 周期，可能有 3072 项；一旦循环代码溢出 L1I，Taken 延迟显著上升，说明主 BTB 可能与指令 Cache 绑定。

![图 6：A73 的 BTB 延迟与容量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a73_wechat_article_zh/ea3662c3b0b3cf42_06_a73_btb_latency_capacity.png)

*图 6：曲线改变 Branch Spacing。约 48 个分支之前是较快层，主层约 3 周期；代码足迹超过 L1I 后出现大台阶。3072 项是行为推测，不能直接写成官方容量。*

![图 7：A57 的 BTB 对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a73_wechat_article_zh/fcd8a127a89ad047_07_a57_btb_latency_capacity.png)

*图 7：A73 与 A57 的总体层级接近，A73 在极小分支足迹和溢出 L1I 后略好；Haswell 等高性能核心的最快 BTB 可跟踪更多目标，并有单周期 Taken。*

间接分支的目标来自寄存器。同一个分支可跳向多个位置，预测器还要选择目标。A73 可用较低代价跟踪约 256 个总目标，例如 128 个分支各交替两个目标；单分支可到 16 个目标后才明显困难。

![图 8：A73 的间接分支预测](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a73_wechat_article_zh/da087580c054619b_08_a73_indirect_targets.png)

*图 8：横轴改变每分支目标数，另一维改变间接分支数量。128×2 与单分支 16 目标是两种不同切片，不能合并成物理阵列参数。*

Return 可利用 Call/Return 栈关系。A73 在调用深度不超过 16 时最快，却要到超过 47 后才出现明显陡升；A57 在深度 32 后逐渐恶化。曲线可能意味着多级或回退机制，而不是一张“47 项 RAS”就能完整解释。

![图 9：A73 与 A57 的返回预测](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a73_wechat_article_zh/c2a4512c16947aa4_09_return_stack_a73_a57.png)

*图 9：A73 在 16 以内延迟最低，47 后明显上升；A57 在约 32 后缓慢变差。图只给出外部可见行为，没有确认 RAS 深度和溢出回退路径。*

### Fetch 与 Decode

A57/A72 会在 L1I 填充前预译码，把每条 32-bit Arm 指令扩成约 36 或 40 bit 中间格式。A72 的 48 KB 有效 L1I 因此实际需要约 54～60 KB 存储。A73 收窄到两宽译码后，很可能不再需要这种方案：直接把 AArch64 指令译成 micro-op 仍可控制功耗，也省下预译码膨胀。

省下的存储预算被用来把 L1I 从 A72 的 48 KB 增至 64 KB，相联度从三路增到四路，降低冲突 miss。虽然两宽把 L1I 命中时的 IPC 上限压低，A73 从 L2 取代码却更快。

![图 10：A73 与 A72 的指令取数带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a73_wechat_article_zh/9b749161dbf66842_10_instruction_fetch_bandwidth.png)

*图 10：L1I 内 A73 约 2 IPC、A72 更高；进入 L2 后 A73 仍接近 1 IPC，A72 约 0.61；大足迹后两者都很低。A73 最多跟踪四个 64 B L1I miss，A72 为三个，增加的指令侧 MLP 可能贡献了改善。*

### 体系结构视角：更大的有效 L1I 可以抵消更窄 Decode

前端宽度决定命中时峰值，L1I 容量和 Fill Buffer 决定大代码足迹下能否持续供给。A73 用更小的两宽 Decode 换来 64 KB、四路有效 L1I，并把 Fill Buffer 从三增至四，属于“降低峰值、抬高更常见下限”。

若 L1I 命中率很高而 Decode 长期满，两宽会直接限制 IPC；若代码经常跨出 48 KB，A73 的容量和 L2 取数可能更有价值。验证需同时看 Fetch Bytes、Decode Utilization、L1I miss、Refill 并发与 Taken Bubble。

## Rename：基础不复杂，但加入 Move Elimination

Rename 用物理寄存器消除写后写、读后写等假依赖，也适合识别不必进入后端的操作。A73 不像 x86 那样识别 `XOR reg,reg` 清零；AArch64 指令都为 4 B，用自异或清零并不节省编码，因此影响不大。

A72 无法消除依赖型寄存器 MOV，A73 则具备某种 Move Elimination。

![图 11：A73 与 A72 的重命名行为](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a73_wechat_article_zh/652c029cd3a6ccb2_11_rename_move_elimination.png)

*图 11：`EOR r,r` 两者均约 1 IPC；立即数零 MOV 与独立寄存器 MOV，A73/A72 为 1.82/1.91；依赖 MOV 时 A73 仍为 1.82，而 A72 降到 1.00。结果说明 A73 能打断 MOV 依赖，但没有揭示映射表内部实现。*

## “无限”重排序：Slot-based 执行的反常测量结果

A73 最独特之处在于乱序窗口。Arm 说架构有八个 “Slot”，但公开描述不足以解释 Slot 具体保存什么。用 Henry Wong 的方法，在两次 Cache miss 之间不断增加 filler 指令，通常能测出 ROB、寄存器文件或 LSQ 容量；A73 却一直到 filler 多得让两宽 Decoder 在第一个 DRAM miss 返回前都发不完，两个 miss 才不再重叠。

从这个外部测试定义看，已完成但尚待退休的指令没有撞上可见资源上限，因此表现为“理论无限”的重排序容量。一个可能解释是：核心识别某段指令不可能引发异常后，把中间结果折叠进 Slot。但公开材料与微基准都不足以确认这一恢复机制。

“无限”并不等于能无限向前执行。等待执行单元的指令仍占 Scheduler；A73 的 Scheduler 很小。性能计数器也表明 Load/Store Slot 会限制性能，但这些 Slot 的精确定义仍不清楚。

![图 12：A73 的后端资源停顿](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a73_wechat_article_zh/e09dba8105d624d6_12_backend_resource_stalls.png)

*图 12：libx264 Transcode/7-Zip 的 Data Processing IQ Full 为 1.19/1.86%，Data Engine IQ Full 为 11.83/0%，Load/Store IQ Full 为 6.02/2.93%，All Load-Store Slots Busy 为 9.84/4.61%。计数器证明实际资源仍会满，却不能把 Slot 直接等同于传统 ROB/LQ/SQ。*

### 体系结构视角：为什么“测不到 ROB”不等于没有精确状态

处理器仍必须支持精确异常、分支恢复和内存顺序。区别可能在于已完成、无异常风险的指令不再逐条占传统退休状态，而未完成或可能出错者保留在少量 Slot 中。这样能减少大 ROB 的面积与比较开销，却把可压缩性变成程序相关变量。

验证应加入可能异常的除法、页故障 Load、分支和 Store，分别改变它们与两次 miss 的距离；同时观察精确陷阱状态和恢复。只有看到哪些指令阻止折叠，才能逐步逼近 Slot 的语义。没有 RTL 时，不应为八个 Slot 虚构字段和状态机。

## 调度与执行：删端口、减队列，再重新分配

### 整数与分支

A73 仍是分布式 Scheduler，却删除 A72 的独立多周期整数 Pipe。乘除等复杂操作并入一条主 ALU，因此省下一组 8 项 Queue 和两条寄存器读端口。

![图 13：A73 与 A72 的整数和访存调度](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a73_wechat_article_zh/d62285b9edbbc095_13_scheduler_a73_a72.png)

*图 13：A73 两组 ALU Queue 各 6 项，一条兼 INT MUL；Branch 为 14 项；两条通用 AGU 共享/使用约 14 项调度容量。A72 为三组 8 项整数队列、10 项 Branch，以及 8+8 项专用 Load/Store AGU 队列。图是行为重建，不是 RTL Floorplan。*

A72 与 A73 都保留独立 Branch Port。这对只有两条 ALU 的核心很有意义：一般应用每 5～20 条指令就有一条分支，独立端口减少 ALU 争用，并天然优先让分支早点执行。误预测代价不只是 Fetch 到 Execute 的最短流水线长度；如果分支在 Scheduler 中等不到端口，恢复还会更晚。Branch 不写普通寄存器，专用端口也比通用 ALU 少一条 Register Write Port，成本更低。

### 两条通用 AGU

A72 一条 AGU 只做 Load，另一条只做 Store；A73 两条都能处理 Load 或 Store。现实中 Load 多于 Store，通用化既提高 Load 吞吐，也允许约 14 项调度容量按实际比例使用。固定专用端口则必须各自配足队列，以免一串 Load 或 Store 单独填满。

### FP/Vector

A73 延续双 Pipe FPU，却增加调度项，因为 FP 延迟通常比整数高，更深 Queue 有助于寻找独立操作。FMA 延迟从 A72 的 8 周期降到 7，仍高于 Zen 的 5 周期，而且 Zen 可运行在更高频率。

![图 14：A73 与 A72 的 FPU Scheduler](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a73_wechat_article_zh/8232c17e69f2f4ab_14_fpu_scheduler_a73_a72.png)

*图 14：A73 两条 64-bit FMA/128-bit ALU 路径，Queue 为 13+9 项；A72 为 8+8。增加项数弥补较长依赖延迟，但端口能力仍保持低功耗取向。*

### 体系结构视角：分布式 Scheduler 的总项数会骗人

A73 删除一组整数队列，却把 Branch、AGU 与 FP 队列按常见负载重新平衡。总容量下降，不代表每类代码都更早停；两条通用 AGU 就能让 Load 借用原本可能闲置的 Store 资源。

应观察每个 Queue 的 Occupancy/Full、Ready-but-not-issued 和端口利用率。某组 6 项 ALU Queue 满而另一端口空，是分布式碎片；两条 ALU 都满载则是吞吐上限。只报“总 Scheduler 条目”会掩盖端口可达性。

## 地址转换：低频让五周期主 TLB 仍只有 2.27 ns

A73 数据侧有 48 项全相联 Micro TLB，命中无额外惩罚；1024 项、四路 Main TLB 覆盖更大工作集，命中增加 5 周期。

![图 15：A73 与 Zen 2 的地址转换层级](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a73_wechat_article_zh/47c85e1653cd71c3_15_address_translation_a73_zen2.png)

*图 15：A73 支持 48-bit VA、40-bit PA，48 项 L1 DTLB、1024 项四路 4 KB L2 TLB、128 项 Large Page/Walk Cache；Zen 2 为 64 项 L1、2048 项 16 路 L2/PDE 和 64 项 Page Directory Cache，VA/PA 都为 48 bit。*

Zen 2 的二级 TLB 更大，却要多 7 周期。在 Ryzen 3950X 3.5 GHz Base Clock 下是约 2 ns；A73 的 5 周期在 2.2 GHz 下约 2.27 ns。面向低频设计能用较少流水级到达主 TLB；把高频核心简单降频，并不会自动缩短周期数。

A73 Main TLB 只处理 4 KB、16 KB、64 KB 小页；另一个 128 项结构处理大页，也缓存上层页表项以加速 Page Walk。

![图 16：A73 与 Zen 2 二级 TLB 的映射存储成本](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a73_wechat_article_zh/d4d99d60d939d6ed_16_tlb_storage_cost.jpg)

*图 16：只算 4 KB 页映射的 VA Tag 和 PA 输出，A73 为 `1024×(28+28)/8=7168 B`；Zen 2 为 `2048×(29+36)/8=16640 B`。ASID、VMID、权限、有效位与替换元数据还会继续增加，表中不是完整阵列面积。*

Zen 2 覆盖更大工作集，更适合桌面和服务器。A73 则用更小容量节省存储与比较功耗，40-bit PA 也减少每项位数。

## 内存消歧、转发与对齐

在途 Load 地址必须与更老 Store 比较；若二者重叠，LSU 要把尚未进入 Cache 的 Store Data 转给 Load。A73 最快约 4～5 周期，只比 L1D Hit 多一两周期。

最快路径要求 Load 按 32 bit 对齐，但只要 Load 完全包含在 Store 范围内，很多组合都能处理。未按 32 bit 对齐后变慢；任一访问跨 64-bit 边界还会增加惩罚。最坏约 9 周期，出现在 Load 和 Store 都跨 64-bit 边界时。跨 4 KB 页边界却没有后来部分 Arm 核心和许多 x86 核心的额外惩罚。

![图 17：A73 的 Store-to-Load Forwarding](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a73_wechat_article_zh/1aea4e3fac857e16_17_a73_store_forwarding.png)

*图 17：按 Henry Wong 方法编写 AArch64 测试，列/行扫描 Load 与 Store Offset，格内单位为周期。主对角附近为 4～5 周期，未对齐和跨 8 B 重叠形成更慢色块，最坏约 9。*

A72 的 Forwarding 更可预测，却固定为约 7 周期。

![图 18：A72 的 Store-to-Load Forwarding](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a73_wechat_article_zh/c92043f3fa637041_18_a72_store_forwarding.png)

*图 18：A72 对大多数包含和部分重叠组合维持约 7 周期。两张矩阵显示 A73 优化常见对齐路径、接受边界慢路，而 A72 延迟更均匀。*

Cache 只在表面上按字节寻址，内部按更大的对齐块访问。A73 的 Load/Store 都以 8 B 边界工作；A72 则是 16 B Store、64 B Load 对齐边界，所以 A72 更不容易因未对齐而掉吞吐，却可能每次打开更宽数据块。A73 改用更小块，可能在节能与常见标量访问上更有利。

### 体系结构视角：优化 Common Case 会让延迟分布不再平坦

A73 把 32-bit 对齐、完全包含的常见转发压到 4～5 周期，代价是跨 8 B 的组合升到 9；A72 则更接近固定 7。平均性能取决于真实程序的访问宽度和对齐，而不是单看最优或最差值。

验证应扫描宽度、Offset、完全/部分重叠、Cache Line 和 4 KB 边界，并把独立未对齐 Load/Store 与依赖转发分开。跨页测试还要加入第二页无映射，确认精确异常，而不能只测两个正常页。

## L1 Cache：更低延迟，更高相联，替换策略更简单

A73 与 A72 都是私有 L1、集群共享 L2。A73 L1D 可配置更大、延迟也更低，却在未对齐和替换策略上让步。

A72 使用 LRU，A73 改用伪随机，省掉维护最近使用次序的元数据，可能降低命中率。A73 同时把相联度从 A72 的两路增至八路，用更多候选 Way 减少冲突 miss，部分补偿较笨的替换策略。

A73 还把 L1D 从物理索引物理 Tag（PIPT）改为虚拟索引物理 Tag（VIPT）。VIPT 可让 Set Index 与 TLB 翻译并行，从而把命中从 A72 的 4 周期降至 3 周期；这是结合组织和延迟的合理解释，不是对所有实现时序的 RTL 确认。

![图 19：A73 与 A72 的 Cache/Memory 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a73_wechat_article_zh/60cd895b56cb9a29_19_cache_memory_latency.png)

*图 19：2 MB 大页下，A73/A72 L1 为 2.99/4.01 周期；A73 1 MB L2 约 24.92，A72 2 MB L2 约 21.13；进入 DRAM 后 A73 又更高。容量和 SoC 不同，不能把全部差距归于核心代际。*

两者都能每周期做一次 128-bit Load，但 A73 不再像 A72 那样在 8～16 KB 后明显掉带宽，两条通用 AGU 对窄 Load 也更灵活。

![图 20：单线程 Cache 与内存带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a73_wechat_article_zh/2f46ef93cfdea51f_20_single_thread_cache_bandwidth.png)

*图 20：A73/A72 L1 峰值约 29.83/36.65 GB/s；L2 区间约 12.17/19.52；进入 DRAM 后约 8～11。A73 的 L1 曲线更平，但 L2 明显更慢。*

## L2：理论接口很宽，实测兑现很少

A73 可排队 8 个 L1D Fill Request；原页面同时称 A72“只能有 8 个 L1D miss”，这两个数字本身相同，因此“增加 MLP”的表述与该句并不一致。可能是 Fill 与总体 miss 的口径不同，也可能是页面表述问题；没有更多资料，不能强行统一。

TRM 给出 L1D 从 L2 的 128-bit Read Interface，简单线性访问却远低于 16 B/cycle。四核一起读 L2 时带宽会增加，但合计仍略低于 16 B/cycle；L2 的 512-bit Fetch Path 也没有转成 64 B/cycle 的应用带宽。

![图 21：四核 Cache 与内存带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a73_wechat_article_zh/c71bbb131c77eccf_21_multithread_cache_bandwidth.png)

*图 21：四颗 A73 与 Graviton 1 四颗 A72 对照。L1 区域约 120/147 GB/s；L2 约 31.90/36.65；大工作集最终约 7.96/12.39。不同 SoC 的频率、L2 和内存都不同，只能看量级。*

A73 的 L2 命中约 25 周期，比 A72 的 21 更慢。S922X 又只配 1 MB，虽然 A73 支持 256 KB～8 MB。页面认为这一配置在共享 L2 中容量小、性能低，Arm 的节能取舍和 Amlogic 的容量选择都可能贡献结果。

![图 22：共享 L2 配置与实测对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a73_wechat_article_zh/d2110bd106f1e37e_22_l2_cache_comparison.jpg)

*图 22：A73 2.2 GHz 为 1 MB 16 路、14.5 B/cycle、25 周期；A72 2.3 GHz 为 2 MB 16 路、15.9 B/cycle、21 周期；Goldmont Plus/J4125 为 4 MB、29.14 B/cycle、19 周期；Jaguar/Athlon 5350 为 2 MB、26.18 B/cycle、26 周期。A73/A72 是集群共享，产品目标也不同。*

### 体系结构视角：512-bit Fetch Path 为什么不等于 64 B/cycle

Fetch Path 可能描述阵列一次填充或内部传输宽度；有效 Load 带宽还要经过 Tag、Bank、仲裁、Refill、L1 接口和每核未决请求数。任何一环串行或冲突，都能让最终带宽远低于物理数据线宽度。

可用多核、不同地址交错和独立 Stream 测试 Bank/端口扩展，再结合 Fill Queue、L2 lookup、Refill 与 Cluster 出口占用。单一线性流达不到理论值，只能证明端到端未饱和，不能直接定位是哪一级限速。

## 一致性与跨集群延迟

共享 L2 配有 Snoop Control Unit（SCU），决定请求命中 L2，还是从另一颗核心的 L1D 取数据。

![图 23：S922X 的核间延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a73_wechat_article_zh/a3b06f92a7412112_23_core_to_core_latency.png)

*图 23：1、2 号为 A53，3～6 号为 A73，单位 ns。A53 集群内约 23，A73 集群内约 28～29，跨集群约 267。测试通过核心对之间转移 Cache Line，但同步协议、Line 状态与重复统计未披露。*

A73 在同 Cluster 内延迟很低；跨 A53/A73 Cluster 代价很高，甚至比 Ryzen 3950X 或 7950X3D 跨 Die 更差。这里只能说明 S922X 拓扑，不应把 267 ns 当作 A73 核心内部延迟。

### 体系结构视角：跨集群一致性是一条系统路径

一次共享线转移可能经过请求队列、Snoop Filter/Tag、目标核 Probe、数据返回和 Fabric 仲裁，其中若干阶段落在关键路径。CPU IP、Cluster SCU 与 SoC 互连共同决定结果。

只有共享写入延迟与 Probe/Retry、Fabric Queue 同时上升，才有理由继续定位一致性瓶颈；普通私有数据的 DRAM miss 不应与核间转移混为一谈。

## DRAM：1 MB 末级 Cache 后面是一条 32-bit 总线

S922X 的内存控制器可跟踪最多 32 条 Read 和 32 条 Write Command。作为历史参照，Nehalem-EX/Westmere-EX 的早期 DDR3 控制器每实例可跟踪 32/48 个请求。

![图 24：S922X DDR 接口](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a73_wechat_article_zh/233f4946b44bd4b2_24_s922x_ddr_interface.png)

*图 24：来自 Amlogic S922X 公开数据表，图中列出 DDR PHY、读写 Buffer 和 32-bit 接口。它是 SoC 官方框图，不是 A73 RTL。*

Odroid N2+ 配 4 GB DDR4-2640、32-bit，总理论带宽 10.56 GB/s。四颗 A73 读取 1 GB 数组达到 8.06 GB/s，与更早的单通道 DDR3 Athlon 5350 接近；Graviton 1 的四颗 A72 更高，主要因为服务器内存子系统功耗预算更大。

![图 25：1 GB 工作集的多线程 Read 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a73_wechat_article_zh/d84c6ffc20de00e2_25_memory_bandwidth_comparison.png)

*图 25：Haswell 双通道 DDR3-1333 为 19.22 GB/s，Graviton 1 四颗 A72 为 13.04，Phenom X4 945 双通道 DDR2-800 为 10.41，Athlon 5350 单通道 DDR3-800 为 8.54，S922X 四颗 A73 为 8.02，Core 2 Extreme DDR2-667 为 6.91。平台、年代与控制器完全不同。*

即使用 2 MB 页减少地址翻译影响，S922X 仍有约 139.79 ns DRAM 延迟。32-bit 总线节能，却不提供高带宽；控制器也显然没有为低延迟优化，连内存控制器仍在芯片外的 Core 2 Extreme 都更快。

![图 26：2 MB 页、1 GB 工作集的内存延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a73_wechat_article_zh/40c3df4279b3fde5_26_memory_latency_comparison.png)

*图 26：Haswell 68.36 ns、Core 2 Extreme 71.24、Phenom 74.33、Graviton A72 92.32、Athlon 5350 110.20、S922X A73 139.79。数字包含整个平台，不能按核心名称排名。*

## 结语：向能效转身，并成功让客户回来

A73 的 Slot-based 执行让传统 ROB/LQ 容量探测失效，是很少见的乱序路线。Arm 通过两宽 Decode、减少执行端口和小 Scheduler 控制功耗；同时又重新平衡整数 Queue、使用通用 AGU、增加 FP 调度容量、提高 L1 miss 并发，并用“理论无限”的已完成指令折叠缓解小窗口问题。

最终核心功耗很低，应用性能却没有低于更老的三宽 A57。在桌面上，IPC 原地踏步不吸引人；在手机里，热限制常决定实际性能，能持续运行才是胜利。

![图 27：A57 与 A73 的实际负载](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a73_wechat_article_zh/78168edc540bb15a_27_a57_a73_application_performance.png)

*图 27：四颗 A57/Tegra X1 与四颗 A73/S922X 的 libx264 720p Transcode 为 2.90/3.02 FPS，7-Zip 为 8.11/7.78 MB/s。Switch 的 A57 有主动散热，平台也不同；结果只支持“没有明显倒退”，不是同条件能效证明。*

A73 取得了商业成功。Qualcomm 在 Snapdragon 835 选择 A73，自研大核因此暂停多代；A73 也进入部分 Samsung 产品，虽然 Samsung 还过了几代才放弃 Mongoose。

页面仍认为 Arm 收缩得有些过头：两组 6 项 ALU Queue 在 2010 年代后期太小，两宽也处在过窄边缘。后继 Cortex 重新增加宽度和乱序资源，把性能与能效拉回更均衡位置。

### 体系结构视角：从 A73 可以看到的六个设计认识

第一，A73 的创新不在于“无限 ROB”这个宣传式说法，而在于尝试压缩已完成、无异常风险的状态。它把传统逐指令退休资源转成更依赖程序性质的 Slot 使用。

第二，能效优化不是全面缩小。A73 收窄 Decode、删除整数 Pipe，却扩大有效 L1I、增加指令 miss 并发、通用化 AGU 并加深 FP Queue；预算被从低利用率处移向更常见瓶颈。

第三，专用 Branch Port 对窄核尤其划算。它不需要普通 Register Writeback，却能减少两条 ALU 的争用，让误预测更早暴露。

第四，低频目标可以缩短按周期计的结构延迟。A73 Main TLB 是 5 周期、2.27 ns；高频 Zen 2 为 7 周期、约 2 ns。周期数与墙钟时间必须同时看。

第五，Common Case 优化会让边界慢路更突出。A73 Forwarding 最快 4～5 周期，但双跨 8 B 达 9；A72 固定约 7。平均性能取决于访问分布。

第六，S922X 暴露的最大问题在 SoC 存储系统：1 MB L2、四核不足 16 B/cycle、32-bit DDR4 和 139.79 ns DRAM。评价 A73 IP 时必须把这些实现选择剥离出来。

## 参考资料

- Chester Lam，*Arm’s Cortex A73: Resource Limits, What are Those?*，Chips and Cheese，2024-07-18：https://chipsandcheese.com/p/arms-cortex-a73-resource-limits-what-are-those
- Arm，*Cortex-A73 Technical Reference Manual*
- Amlogic，*S922X Public Datasheet*（图 24 来源）
- Henry Wong 的乱序容量与 Store-to-Load Forwarding 测试方法（网页引用）

如果这类分析对你有帮助，可以通过原页面列出的 Patreon 或 PayPal 支持 Chips and Cheese，也可以加入其 Discord 社区交流。
