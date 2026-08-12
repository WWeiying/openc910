---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "intel_tremont_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*Intel’s Tremont: Atom Changes Course*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2022 年 1 月 2 日
> - 链接：https://chipsandcheese.com/p/intels-tremont-atom-changes-course

Tremont 是 Gracemont 的直接祖先，也标志着 Intel Atom 战略转向。Intel 宣称它相对 Goldmont Plus 每周期性能提高 30%；更重要的是，后来让 Gracemont 出彩的多项技术——Core 级分支预测、双 Decode Cluster、大乱序窗口和 Non-Scheduling Queue——都已在这里成形。

## 核心总览：更像缩小版 Gracemont

![图 1：Tremont 微架构总览](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/6a5941743868a054_01_tremont_block_diagram.png)

*图 1：双三宽 Decode Cluster 后接四宽 Rename/Retire、208 项 ROB、168 项整数和 175 项 128-bit FP 物理寄存器、64/42 项 Load/Store Queue；四核共享 1.5 MB L2，再接 4 MB L3。图中未公开容量来自微基准反推。*

从结构上看，Tremont 像缩小的 Gracemont；从演进关系看，Gracemont则是把 Tremont 的方向推到底。前端名义六宽，Rename 与退休四宽；后端不再是早期 Atom 那种脆弱小窗口，但 Cache 和部分执行资源仍保留低功耗取舍。

## Core 级分支预测：准确率、容量和延迟分层

![图 2：Intel 对 Tremont 分支预测的介绍](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/fe1e365389b166df_02_intel_branch_predictor_slide.jpg)

*图 2：Intel 2019 年 Linley Fall Processor Conference 幻灯片强调双层 BTB、长度最高 32 的 RAS、间接目标阵列与面向大代码足迹的预测。这里是官方功能描述。*

Tremont 的 Decode Cluster 会比传统单 Decoder 更远地提前工作，因此错误预测不仅浪费后端推测，也会打乱两条取指/译码链，预测器尤为重要。

### 方向模式识别

![图 3：Tremont 可学习的历史长度](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/c160add3738c18d6_03_tremont_history_length.png)

*图 3：模式延长后仍保持低每分支周期，说明可追踪较长历史。*

![图 4：Tremont 的方向预测曲面](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/d3984a34a92e6042_04_tremont_pattern_surface.jpg)

*图 4：同时扫描 Pattern Length 与静态分支数。曲面低区接近 2019 年主流 Skylake 的水平。*

长历史端的延迟缓慢上升，支持存在二级 Override Predictor；但一级预测本身已很强，接近能力边界时每分支时间也只小幅增加，说明二级很少需要纠正。

![图 5：Skylake 的方向预测曲面](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/3be21d88932107c6_05_skylake_history_length.png)

*图 5：Tremont 发布时，桌面旗舰仍大量使用 Skylake；两者属于相近能力层级。*

![图 6：Gracemont 的方向预测曲面](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/59fc7714a4d24d40_06_gracemont_pattern_surface.jpg)

*图 6：Gracemont 的低误预测区域进一步扩大，显示 Intel 为更高性能目标继续增加预测能力。*

### BTB：512 项快路、4096 项总容量

![图 7：Tremont 的两级 BTB](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/908b5c16f8c0857c_07_tremont_btb_hierarchy.jpg)

*图 7：约 512 个目标可背靠背预测，二级把总容量扩到约 4096，但命中会给前端增加两周期。曲线拐点是有效容量，不是 RTL 读数。*

![图 8：Tremont 与 Intel Core 的 BTB 对比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/d6856da73e9bcc7a_08_intel_btb_comparison.jpg)

*图 8：Tremont 总目标容量接近 Core 系列，却在 L2 BTB 前多放一流水级控制功耗；零气泡连续预测能力只明显落后 Gracemont 和 Zen 3。*

### 实际负载与性能影响

![图 9：7-Zip 的分支预测准确率](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/59d12ec69a6098e8_09_7zip_branch_accuracy.jpg)

*图 9：7-Zip 分支密集且较难预测，Tremont 落后 Skylake。*

![图 10：libx264 的分支预测准确率](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/6ab02bca5883e975_10_x264_branch_accuracy.png)

*图 10：libx264 分支更少也更容易，Tremont 表现不错，但仍略低于 Skylake。*

Tremont 有细到 Pipeline Slot 的 Topdown PMU，暗示 Atom 已面向严肃性能分析。即使预测器不如 Gracemont，Tremont 因窗口更小、流水线略短，误预测丢掉的 Slot 反而更少；Gracemont 推测得更远，一次清空损失更大，Pattern 测试也显示检测误预测约多一周期。

![图 11：Tremont 与 Gracemont 的错误推测损失](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/a41bd905f2b76e06_11_bad_speculation_slots.png)

*图 11：Topdown 把 Bad Speculation 拆成分支误预测与机器清空。更少浪费 Slot 不等于预测更准，还取决于窗口深度和恢复长度。*

### 体系结构视角：预测器的价值是“避免浪费多少未来工作”

同样一个误预测，浅窗口只清掉少量 micro-op，深窗口可能丢掉更多已取指、已译码甚至已执行工作。因此 MPKI、恢复周期与错误路径在途 Slot 要一起看。下一代核心扩大窗口时，预测器若不同比加强，Bad Speculation 占比可能反而上升。

验证可将 `branch-misses` 与 `slots`、`bad_speculation`、前端重定向周期和 ROB 占用对齐；若 MPKI 不变而每次误预测损失上升，问题更接近流水线/窗口，而不是准确率。

## 双 Cluster 前端：用分支把两套三宽 Decoder 粘起来

Tremont 最醒目的创新，是两组三宽 Fetch/Decode Cluster。它常被称为“乱序译码”，但目标并非绝对性能，而是以较低面积、功耗和研发成本提高前端吞吐。

每个 Cluster 延续 Goldmont Plus 的低层特性，例如指令最好不要带超过 4 B 的 Prefix/Escape。文章判断两套 Decoder 很可能基于已验证模块复用：无需把单一 Instruction Queue 改成六路出队，也不必扩宽 micro-op Queue 或重做按需长度译码。

![图 12：Tremont 的 Clustered Fetch/Decode](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/3f486ca4db33b93e_12_clustered_frontend.png)

*图 12：Branch Predictor 把相邻 Taken Target 交替送到两套 16 B Fetch、三宽 Decode Cluster，末端 Multiplexer 再按程序顺序拼回 micro-op 流。Goldmont Plus 式 Cluster 是结构推断。*

真实代码大约每 10～20 条指令有一次 Taken 分支，预测器天然知道边界，正好可用作两个 Cluster 的分工点。若 Taken 分支相隔太远，两套 Decoder 无法自动均衡，就退化成单组三宽。Intel 优化手册甚至建议：遇到瓶颈时，可每隔 16～32 条指令插入跳向下一顺序地址的无条件 JMP。

![图 13：循环长度如何影响双 Cluster 吞吐](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/2f8312710be83f35_13_decode_loop_length.jpg)

*图 13：约 3～64 条指令的循环最容易利用两组 Decoder；连续约 128～160 条指令没有 Taken 分支后，行为逐步退化为三宽。一般程序 5%～20% 指令为分支，其中约半数 Taken，因此极端失衡不常见。*

### 指令侧带宽

![图 14：纯 NOP 流的取指字节带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/9b0d34d294af336c_14_instruction_bytes_bandwidth.jpg)

*图 14：没有 Taken 分支时测试卡在单 Cluster，L1I 仅约 16 B/cycle，L2 也难以满速；加入无条件跳转后，L1I 接近 Gracemont，主要差距变成 32 KB 对 64 KB L1I。*

![图 15：四字节 NOP 下的 Decode IPC](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/b2acf1617ba4ed36_15_instruction_decode_ipc.jpg)

*图 15：简单顺序流约 3 IPC；加入 Taken 分支完成负载均衡后，Tremont 与 Gracemont 都由四宽 Rename 限制。*

两种 Atom 从 L2 都不能像大核那样持续 4 IPC，可能来自更高 L2 延迟和较弱指令预取。因此 Gracemont 扩 L1I 到 64 KB 很合理；另一种办法是降低 L2 延迟、在 L1I miss 后更深预取，但移动更多数据会耗电。

### 体系结构视角：这不是传统意义的“乱序执行前端”

两个 Cluster 并不是让任意指令跨分支乱序译码，而是借预测到的 Taken 边界并行准备两个基本块，再按顺序汇合。它省掉六宽变长 x86 Decoder 的集中式复杂度，却把性能押在分支密度与预测正确性上。

观察 `idq` 供给、Decode Active、Taken 分支间距和 Cluster 选择信号，可区分取指字节不足、单 Cluster 饥饿与四宽 Rename 上限。

## Rename：四宽是六宽前端的真正出口

![图 16：Tremont 与其他核心的 Rename 能力](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/1ea92568044fb973_16_rename_width_comparison.jpg)

*图 16：双三宽前端最终通过四宽 Rename/Dispatch，退休也不超过四条/cycle；表格还比较 Gracemont、Skylake 等的融合与消除能力。*

Tremont 识别 `xor r,r` 无依赖，但不会消除，仍占 ALU。独立 MOV 可消除，吞吐超过三条/cycle；链式依赖 MOV 偶尔能消除，却不如 Gracemont、Sunny Cove 和 Zen 2/3 稳健。

![图 17：Tremont 的清零与 MOV 优化](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/a57f25ac092330cf_17_rename_optimization.jpg)

*图 17：测试把依赖/独立 MOV、XOR 清零和其他 Idiom 分开，说明“解除依赖”和“不占端口”不是一回事。*

这种取舍仍合理。Haswell/Skylake 的 MOV Elimination 也相似，Haswell 计数器显示大多数 MOV 可成功消除；链式 MOV 并不常见，GCC/Clang/MSVC 又普遍用 XOR 清零。更完整机制可能只有很小收益，不值得更多晶体管。

## 后端：Atom 已有 Haswell 级容量，调度仍偏小

![图 18：Tremont、Skylake 与 Haswell 的后端容量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/062aed7d84181f88_18_backend_capacity.jpg)

*图 18：ROB 208，介于 Haswell 192 与 Skylake 224；整数寄存器 168、FP/Vector 175；Taken/Not-Taken 分支可见容量约 60/102；Load/Store Queue 为 64/42。Tremont 无 SMT，少了第二线程架构状态占用，更多物理寄存器可用于重命名。*

Tremont 不支持 AVX，向量寄存器只有 128 bit；这让它能以较小面积提供接近 HSW/SKL 的寄存器条目数。

### 整数 Scheduler 与端口

Tremont 像早期 Atom、Zen 1/2 一样采用分布式整数 Scheduler。总计约 45 项，但专用分支队列占 14 项，常用整数操作只有 31 项。Zen 2 有更灵活的 64 项，半数可容纳分支；Skylake 总项数虽略少于 Zen 2，统一 Scheduler 却能让每项服务任意端口。

![图 19：Tremont、Zen 2、Skylake 与 Gracemont 的整数调度](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/425ea7775b1d3c1d_19_integer_scheduler_layout.jpg)

*图 19：Tremont 的 12/12/7 项 ALU 队列加 14 项 Branch 队列突出低功耗取舍；Gracemont 大幅增容，结构更像大核。*

三条 ALU 通常足够，因为 Rename 最多四条/cycle，真实整数流还混有分支和访存。弱点集中在少见操作与乘法器。

![图 20：整数乘法吞吐与延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/a1985302311e1a9b_20_integer_multiply.jpg)

*图 20：Tremont 的整数 Multiply 相对 Gracemont/Skylake/Zen 较弱；精确数值随 32/64-bit 和依赖链口径变化。*

![图 21：单端口整数操作](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/e40debcf5113b009_21_integer_operation_throughput.png)

*图 21：LEA、Rotate、Bit Test/Set 等只进一个端口，而 Skylake/Zen 常可由多个端口执行。平均代码不一定受限，集中使用时吞吐会明显下降。*

内存侧用小 Scheduler 加中等 NSQ：约 13 项 Scheduler 前有约 21 项 Non-Scheduling Queue，总计可保留 34 条内存操作，却每周期只检查最前面 13 条是否就绪。效率可能不及真正 34 项 Scheduler，但功耗低得多。执行端每周期两次 128-bit 访存，其中最多一次 Store，接近 Sandy Bridge。

浮点侧约 24 项 Scheduler 加 33 项 NSQ，可在 Rename 被堵前保留约 57 条 FP 指令，与 Skylake 的 FP 可用调度容量相近。

![图 22：Tremont 的 FP 与访存 Scheduler/NSQ](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/1e39fe2d7e8fdc9a_22_fp_scheduler_layout.png)

*图 22：图中与 Gracemont、Skylake 比较。57 条“等待执行”中并非全部可参与每周期 Wakeup/Select，NSQ 深处即使已就绪也要先进入 Scheduler。*

Skylake 的统一队列也并非总占优，FP/Vector 程序仍包含很多整数操作，会与 FP 争用同一 97 项 Scheduler。

### 128-bit 向量：缺 AVX 与 FMA

Tremont 完全没有 AVX，渲染、图像和编码只能用 128-bit SSE；也没有 FMA。两条 Vector ALU 并不保证所有操作双发：2×64-bit 整数 Add 只有 1/cycle，4×32-bit Add 才是 2/cycle，64-bit Element 延迟也更差。

![图 23：常见 FP/Vector 操作延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/4f3bbbc467c1cc74_23_fp_vector_latency.jpg)

*图 23：Tremont FP Add/Multiply 为 3/4 周期；Vector INT Add 对 64/32-bit Element 为 2/1 周期；Vector INT Multiply 为 5 周期。表中对照 Gracemont、Skylake、Zen 2 与 N1。*

面向纯低功耗核心，取消 AVX 合理；放进 Hybrid CPU 却会拖累大核。如果程序在大核探测到 AVX 后被 OS 迁到小核，执行同一指令会崩溃，所以整机通常不能向应用暴露大核 AVX。Gracemont 修正了这个短板。

### 后端阻塞在真实负载中的样子

![图 24：Tremont、Gracemont、Skylake 的 Backend Bound](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/ac27979d5efadd03_24_backend_bound_slots.png)

*图 24：Tremont 因后端满丢失的 Slot 明显更多。大窗口本用于覆盖长延迟，而 Jasper Lake Cache/内存并不强。*

![图 25：7-Zip 的后端资源阻塞](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/e4a16e33736bec12_25_7zip_backend_stalls.png)

*图 25：纯整数 7-Zip 中 Tremont 主要受小整数 Scheduler 限制；Skylake 把瓶颈推到整数寄存器，Gracemont 的更大队列与寄存器明显改善。三者 ROB 都未充分利用。*

![图 26：libx264 的后端资源阻塞](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/13b45a6c3cb515ef_26_x264_backend_stalls.png)

*图 26：向量化 x264 让 Tremont 的分布式 Scheduler、Memory Scheduler 与寄存器都出现压力，另约 10% Backend Bound Slot 来自 ROB 满。Skylake 向量寄存器相关阻塞中约 85% 是 Vector RF 满。*

ROB 满一方面表示其他资源没有更早耗尽，另一方面说明在途延迟已经超过窗口能力。Gracemont 靠更大后端和 Alder Lake 存储系统改善；Skylake 的统一 Scheduler、低延迟高带宽 Cache 让它即使频率略低，也在该测试略胜 Gracemont。

### 体系结构视角：NSQ 是低功耗窗口的“候车区”

NSQ 不做完整 Wakeup/Select，只让更多未完成操作留在后端，避免 Rename 因小 Scheduler 立刻停住。它适合短暂突发和大多数依赖尚未就绪的负载，却无法让队尾就绪操作立刻抢占端口。

区分 Scheduler 与 NSQ，需要混合依赖和独立 filler，观察独立操作腾出 Scheduler 后延迟台阶是否移动。只用“在两次 Cache miss 之间塞 N 条操作”的经典容量测试，会测到两者总和。

## Cache 与 TLB：低频友好，带宽却很弱

Tremont 与 Gracemont 的 L1D/L2 周期数相同，后者频率更高；Tremont L2 为 1.5 MB，Gracemont 为 2 MB。到 L3，Tremont 周期数较少，实际纳秒反而因低频更高；Alder Lake 的 30 MB 共享 L3 又远大于 Jasper Lake 的 4 MB。

![图 27：Cache/内存延迟（周期）](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/e1de25d2c04df15c_27_cache_latency_cycles.jpg)

*图 27：Tremont 以 3-cycle L1D 和较短误预测路径适配低频；下级 Cache 的周期台阶仍明显。*

![图 28：Cache/内存延迟（纳秒）](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/0e6bc380ad152f3d_28_cache_latency_ns.jpg)

*图 28：换成实际时间后，低时钟放大 Tremont 的 L3/DRAM 劣势。周期与纳秒回答的是不同问题。*

### 地址转换

两代 Atom 都用 48 项全相联 L1 DTLB；L2 TLB 四路、命中额外 9 周期。Tremont L2 TLB 只有 1024 项，接近 Haswell；Gracemont 增至 2048，等于 Core 从 Haswell 到 Sunny Cove 的覆盖扩张。

![图 29：Tremont 与大核的 TLB](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/dc0ca3c5264a09f9_29_tlb_comparison.jpg)

*图 29：Tremont/Gracemont L2 TLB 为 1024/2048 项四路；Skylake 1536 项六路、Haswell 1024 项八路、Golden Cove 2048 项十六路，Zen 2 数据侧 2048 项八路。Atom 用更高延迟、更低相联减少每级工作与 Tag 比较。*

### 读取带宽

![图 30：单核读取带宽（GB/s）](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/e03b7ba80130eab0_30_single_core_read_bandwidth.jpg)

*图 30：低频与窄数据路让 Tremont 从 L1 到 L3 都落后；Gracemont 的 L3 本已不强，Tremont 更低。*

![图 31：单核读取带宽（B/cycle）](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/08d1d5a1c44767a5_31_single_core_bytes_per_cycle.jpg)

*图 31：除去频率后，Tremont L2 仍只有 16 B/cycle；L3 每周期带宽也很低，甚至仅优于部分移动 SoC。Snapdragon 670 的 A75 在 SLC 区约 5.22 B/cycle。*

![图 32：128-bit 数据通路核心的带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/65f85fda4a623740_32_128bit_core_bandwidth.jpg)

*图 32：多数核心 L1D 都能两次 128-bit Load/cycle，进入 L2 后差异扩大；Tremont 类似 Piledriver，L3 更弱。*

![图 33：四核读取带宽扩展](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/5ba9332aa4748daf_33_four_core_read_bandwidth.jpg)

*图 33：四线程只让 Tremont L3 增加约 55%；单通道 DDR4 使内存扩展更差。*

![图 34：四核读取带宽（B/cycle）](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/42a3847ec7511b60_34_four_core_bytes_per_cycle.jpg)

*图 34：归一化后可见共享 L2 上限，核心增加并未线性扩大每周期数据供给。*

![图 35：Tremont、Gracemont 与 Zen 的 L2 路径](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/55634e550fae4a9f_35_l2_path_width.jpg)

*图 35：Tremont 单核到 L2 16 B/cycle、整个 Cluster 32 B/cycle；Gracemont 分别 32/64，实测到 L3 的路径约 16；Zen 四核各自私有 L2，每核可 32 B/cycle、合计 128。*

Gracemont 翻倍 Cache 路径，是为了让新增 AVX 能有可用数据；从 Tremont 回看，这一升级比单纯与桌面大核横比更有意义。

### 体系结构视角：共享 L2 宽度会把四个核心绑成一个流量域

单核路径 16 B/cycle、Cluster 总路径 32 B/cycle，意味着四核全开时无法各自维持单核带宽。共享 Cache 省面积和一致性成本，却引入带宽仲裁；向量化多线程尤其容易撞上总口。

应把每核 L1D miss、L2 hit、Cluster L2 流量和内存控制器带宽一起归一到周期。若核心数增加后 L2 hit 不变、总 L2 B/cycle 封顶，瓶颈就在 Cluster 接口而非 DRAM。

## Atom 的新目标：云、5G、边缘与 Hybrid

![图 36：Tremont 的 Cache/内存 QoS](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/d2846c864015251d_36_cache_qos_slide.jpg)

*图 36：Intel 2019 幻灯片列出 Last-Level Cache QoS、内存带宽分配、优先级与监控；这些功能对单用户客户端意义有限，却适合云租户隔离。*

Tremont 还面向 5G、IoT，Snow Ridge 用于边缘；Lakefield 则与 Sunny Cove 一起帮助 Intel摸索异构调度。Total Memory Encryption 防御 Cold Boot，Accelerator Interfacing Instructions 方便 GPU 等卸载设备；Core 级预测、窗口和宽度，也让 Atom 能在桌面贡献性能。

但它仍像过渡架构：Cache 弱，执行资源偏薄，整数 Scheduler 甚至小于同期 N1，IPC 与频率都没真正接近桌面大核。

![图 37：x264 的性能、功耗与能效](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/1b7c32b01e07f392_37_x264_power_efficiency.jpg)

*图 37：Jasper Lake Celeron N5095 单核负载几乎不承担大量共享 Uncore 功耗；四核编码时每核略高于 2 W，Package 只比 Core Power 高 2～3 W，而 Skylake/Alder Lake Uncore 超过 6 W。*

四核 Tremont、Skylake、Gracemont 编码分别为 0.98、2.01、1.97 FPS。Tremont 约半速、约四分之一功耗，能效更好；等待时间翻倍却是真实体验代价。

## 结论：性能不耀眼，战略意义很大

Tremont 的长处是四宽核心/六宽前端、深分支与乱序容量、NSQ、快速且准确率尚可的预测器、低功耗，以及适配低频的 3-cycle L1D 和短误预测惩罚。弱点是双 Cluster 会被巨大展开循环绊住，整数 Scheduler 太小，缺 AVX 不利 Hybrid，存储系统高延迟低带宽。

早期 Atom 为 Netbook、平板甚至手机优化常见整数操作，在其他地方大量牺牲，性能脆弱，限制了应用范围。Tremont 2019 年公布，开发大约始于 Zen 在 2017 年出现之际。AMD 与 Arm 的小而高效核心可以在吞吐负载中用数量抵消 Intel 单线程优势；手机尝试又已失利，Intel 需要 Atom 守住低功耗日常负载，让大核更放心追求峰值性能。

结尾提供 Patreon、PayPal 与 Discord 支持渠道。

## 附录：计数器、写带宽与 Store Forwarding

### Bad Speculation 的构成

![图 38：错误推测的来源](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/e087c53857499c1d_38_bad_speculation_causes.jpg)

*图 38：把分支误预测与 Machine Clear 等来源分开，补充图 11 的 Topdown 归因。不同核心事件定义可能不同，比例只在本测试口径内比较。*

### 退休宽度

文章没有直接微基准退休宽度，也找不到 Intel 明示。于是给 `instructions retired`（Event `0xC0`、Umask `0`）设置不同 Count Mask；大于 4 时始终为零，说明测试中 Tremont 从未一周期退休超过四条。这支持四宽上限，但计数器零值不是形式化 RTL 证明。

### Skylake 未公开资源计数器

![图 39：Sandy Bridge 的资源阻塞事件](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/0dfaecefa36e2ff4_39_snb_resource_stall_events.jpg)

*图 39：Skylake 未公开寄存器文件耗尽事件，测试从 Sandy Bridge 文档中的 `RESOURCE_STALLS2`/`ALL_FL_EMPTY` 等线索出发。*

用容量微基准反推 Umask：`0xC` 即二进制 `1100` 同时置两位；第四位在 FP Register File 压力下计数高，第三位对应整数 RF，第一位在两种 RF 同受压时变高。随后在 Skylake 重复验证这些未公开事件。

![图 40：对 Skylake 资源事件的推定解释](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/21b6dbb4aa632f5d_40_skylake_counter_interpretation.jpg)

*图 40：文章把 Bits 1、3、4 相加，粗估因无物理寄存器可供 Rename 而无法向后端发送 micro-op 的周期。未公开计数器无准确性保证。*

PMU 事件通常测量极具体的条件，不同架构上名字相似也可能语义不同。因此图 25/26 的 Skylake 细分只用于理解大致瓶颈。

### 写带宽

![图 41：单核写带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/a4e1cb52f9ec86ef_41_single_core_write_bandwidth.jpg)

*图 41：Tremont 每周期只能一次 128-bit Store；Gracemont L1D Load/Store 带宽对称，可匹配 Skylake。*

![图 42：单核写带宽（B/cycle）](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/e82991ddf977c8a9_42_single_core_write_bytes_per_cycle.jpg)

*图 42：进入下级 Cache 后 Skylake 明显领先；DRAM 区写入不用等待数据返回，对 DDR5 高读延迟较不敏感，Gracemont因而反超。Jasper Lake Tremont 各层都弱。*

![图 43：四核写带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/b169c87c5e04cecb_43_four_core_write_bandwidth.jpg)

*图 43：四核时 Gracemont 维持 3.8 GHz，Skylake i5 降到 3.6 GHz，L1D 略占先；Tremont L2 写有一定扩展，L3 几乎不扩展。*

### Store-to-Load Forwarding

![图 44：Tremont 的 Store Forwarding](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/62994dba86a1609b_44_tremont_store_forwarding.jpg)

*图 44：独立实现 Henry Wong 测试；Load 地址必须按 Load Size 与 Store 对齐，例如 64-bit Store 的上下半可转给 32-bit Load。成功约 5 周期，失败 11～12 周期；任一访问跨 64 B Cache line 都失败并再加约一周期。*

![图 45：Skylake 的 Store Forwarding](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/7fb4b7a9f8a8066d_45_skylake_store_forwarding.jpg)

*图 45：只要 Store 完全包含 Load，Skylake 通常成功；Load 跨 Cache line 增加约两周期，仍好于 Tremont 失败后的 12～13 周期。*

![图 46：Neoverse N1 的 Store Forwarding](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_tremont_wechat_article_zh/980d4822ca7ddad8_46_n1_store_forwarding.jpg)

*图 46：Oracle Free Tier Ampere Altra 上的 AArch64 版本。N1 同样只支持 64-bit Store 的上/下半转给 32-bit Load，延迟略长，但跨 64 B Line 仍能工作。*

N1 与 Tremont 在 LSU 做出相似低功耗取舍。它们不显眼，却能解释为什么方框图看似相近的核心，在未对齐与字节重叠代码里表现不同。

## 体系结构视角：从 Tremont 得到的七点认识

第一，**Atom 的转折不只是变宽，而是减少性能脆弱点**。预测器、ROB、物理寄存器和分支窗口都先达到大核量级。

第二，**双 Cluster 是模块复用驱动的创新**。它用真实代码中的 Taken Branch 做分工，避免打造集中六宽 x86 Decoder，但无法处理超长无分支基本块。

第三，**窗口深不等于调度强**。208 项 ROB 已接近 Skylake，常见整数 Scheduler 却只有 31 项，真实程序仍会早早反压。

第四，**NSQ 用更低能耗扩大在途容量**。它适合等待长延迟，却不能替代 Scheduler 对所有就绪操作的即时选择。

第五，**Hybrid ISA 必须取交集**。小核没有 AVX，就会限制大核对应用暴露 AVX；小核的 ISA 能力成为整机迁移安全边界。

第六，**Cache 通路必须跟执行宽度同步升级**。Tremont 单核/Cluster L2 只有 16/32 B/cycle；Gracemont 翻倍后，新增向量能力才不至于完全饿死。

第七，**能效与响应时间可以同时为真**。四分之一功耗、二分之一速度给出更高 FPS/W，也让任务耗时翻倍；产品应按持续吞吐与交互延迟分别评价。

## 参考资料

- Chester Lam, *Intel’s Tremont: Atom Changes Course*, Chips and Cheese, 2022-01-02：https://chipsandcheese.com/p/intels-tremont-atom-changes-course
- Intel, *Tremont Microarchitecture*，Linley Fall Processor Conference, 2019
- Intel, *Intel 64 and IA-32 Architectures Optimization Reference Manual*
- Henry Wong, Store-to-Load Forwarding 与 ROB 容量测试资料
