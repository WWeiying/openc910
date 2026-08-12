---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "arm_cortex_a55_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*Arm’s Cortex A55*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2026 年 8 月 2 日
> - 链接：https://chipsandcheese.com/p/arms-cortex-a55

Arm 的 5 系列核心服务于“性能不太重要、功耗和面积极其重要”的任务。这类核心不必频繁换代：2012 年的 Cortex-A53 先后搭档 A57、A72 和 A73；五年后的 Cortex-A55 又陪伴 A75、A76 和 A78 走过多代产品。

![图 1：Cortex-A55 在 DynamIQ 集群中的定位](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/20c0ae83a0980aaa_01_cortex_a55_product_timeline.png)

*图 1：Arm 官方资料展示 A55 与大核组成 DynamIQ Cluster。A55 可选 16/32/64 KB L1I/L1D、0/64/128/256 KB 私有 L2，并与最多八颗核心共享 DSU L3。网页正式图注说明图片来自 Arm 网站。*

主要测试平台是 Radxa NIO 12L 单板机，SoC 为 MediaTek Genio 1200：四颗 2 GHz A55、四颗 A78、每颗 A55 配 128 KB L2，八核共享 2 MB DSU L3；板载 8 GB LPDDR4X-4266。作为实现差异参照，还使用 Pixel 3A 的 Snapdragon 670 和 OnePlus 7 Pro 的 Snapdragon 855，两者也含 A55。Android 噪声较大，主要微基准在 Linux 平台完成。

与 A53 的比较平台是 Amlogic S922X。两颗核心处在不同 SoC、Cache 层级、频率、内存与软件环境，尤其 Genio 1200 的 A55 拥有明显更强的私有 L2、共享 L3 和内存系统。网页没有完整给出编译器与 Flags、Kernel、频率锁定、预热、重复次数和误差；Geekbench 6 与 SPEC CPU2026 的跨平台结果不能当作纯核心 IPC 对照。

## 总览：仍是两宽、顺序、固定长度流水线

A55 保留 A53 的两宽顺序执行框架，整数流水线八级、FP 流水线九级。每类指令都会经过对应管线的全部阶段，从而天然维持顺序，也避免不同延迟指令同时抵达 Writeback 的冲突。相较典型乱序核心，它更接近固定长度流水线。

![图 2：Cortex-A55 流水线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/cf942d91a5701d22_02_cortex_a55_overview.png)

*图 2：IF1/IF2/IF3、Decode/Issue、EX1/EX2/Writeback 组成整数八级路径；两条整数 Pipe 覆盖 ALU、Shift、MAC、DIV 和 Branch，两条 64-bit FP/NEON Pipe 位于九级路径。A55 的主要更新集中在前端和存储系统，而非大幅扩宽后端。*

### 体系结构视角：固定长度管线用灵活性换简单确定性

顺序核不需要 Rename、ROB、复杂 Wakeup/Select 和大量 Recovery Checkpoint。所有指令沿固定阶段前进，控制、面积和功耗都更低；代价是前方一次 Cache Miss 或长延迟依赖便会迅速堵住后续指令。

因此 A55 的优化重点不是堆更多执行单元，而是减少会让管线断粮或停住的事件：更好的方向预测、更快的 Taken Target、小延迟私有 L2、更低 Load-to-use，以及更积极的系统级 Prefetch。

## 分支预测：从 GShare 转向“神经网络”

Arm Slide 把新方向预测器称为 Neural-network-based。较合理的解释是 Perceptron Predictor：它用权重学习不同历史位置对当前 Branch 的影响，在存储增长较小的情况下覆盖比 A53 GShare 更长的 Pattern；但 Arm 没有公开算法与 RTL，不能据名称确认具体形式。

![图 3：Arm 对 A55 分支预测改进的说明](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/1d40000a6cae562b_03_neural_branch_predictor.png)

*图 3：A75 采用 TAGE，A55 则标为“Neural Network”，两者都增加新间接目标预测器和更快的目标重定向。Slide 说明的是设计方向，不包含表大小、历史长度和训练规则。*

随机生成 Taken/Not-taken Pattern 并逐步加长时，A55 比 A53 稳定，但距离同期高性能核心仍很远。

![图 4：Cortex-A55 的随机方向模式识别](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/f163afa3f6333d17_04_a55_branch_pattern.jpg)

*图 4：Pattern Length 与活跃分支数增加后，低延迟平面逐渐破裂。曲面同时混入可学习历史、权重容量和别名，不能单独证明 Perceptron 的表组织。*

![图 5：Cortex-A53 的同类方向模式识别](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/144be70f08e9e3d9_05_a53_branch_pattern.png)

*图 5：A53 更早失去稳定预测，符合 A55 更新方向预测器的预期。两个平台的测量环境不同，比较以形态为主。*

Geekbench 6 的 PMU 对比并不完全同口径：A55 可统计 Retired Branch，A53 只能得到 Executed Branch，后者会包含错误路径。粗略看，A55 在多数负载改善；但 Clang 反而从 A53 的 20.12 增至 21.26 MPKI，Photo Library 也从 3.37 增至 3.88，并非所有程序都受益。Perceptron 本身也会被线性不可分模式难住，而直接以 History Pattern 索引的方案没有同一种限制。

![图 6：Geekbench 6 的 Branch MPKI](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/0ad3c6667a2cbd99_06_geekbench_branch_mpki.png)

*图 6：A55/A53 的蓝橙柱分别使用 Retired/Executed Branch 口径，不能精确等价。File Compression 为 6.23/8.06、Navigation 16.07/20.16；Clang 与 Photo Library 是必须保留的负面结果。*

目标侧新增 48 项 Micro-BTB，命中时 Taken Branch 不产生 Bubble。A53 只有一条 16-byte Branch Target Instruction Cache（BTIC），只能加速单一目标。Micro-BTB 仍很小，但可覆盖更多紧循环，而且容量不受 Branch Spacing 影响。

![图 7：Micro-BTB 容量与 Branch Spacing](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/71e290670291d5bd_07_micro_btb_capacity.png)

*图 7：不同间距曲线都在约 48 个目标后上升，支持 48 项容量。之后由 Decoder 计算未命中目标，Taken Branch 延迟回到约三周期。*

A55 依然没有大核那种数百或数千项 BTB，预测器不能远远跑在 Fetch 之前替大 Footprint 代码做 Target Prefetch。若每条 Branch 跳到不同的 64 B Cache Line，越过 L1I 后延迟飞涨；1536 条 Branch、96 KB Footprint 时，A55 每条约 28～29 周期，A53 反而只有约 15～16。即使 A55 的数据侧私有 L2 更快，其指令侧路径仍发生回退。

![图 8：Taken Branch 足迹与延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/faf86bda894b4eaf_08_taken_branch_latency.png)

*图 8：小足迹约三周期；超过 L1I/L2 覆盖后多条曲线分层上升。A55 在大 Footprint 回归不是漂亮结果，却揭示“更好方向预测”无法替代大 BTB 与强代码供给。*

### 体系结构视角：预测得对，还要尽早知道往哪里取

方向预测回答 Taken/Not-taken，BTB 提供目标地址。A55 的新预测器能减少错误方向，48 项 Micro-BTB 能消除小循环 Bubble；一旦目标不在快表，Decoder 必须先取到并识别 Branch 才能算 Target，无法预取远处代码。

验证应把 Direction MPKI、Micro-BTB Hit、Taken Redirect、L1I Miss 和 DPU Instruction Queue Empty 分开。大 Footprint 中方向正确但 Queue 仍空，问题更可能在目标/代码供给，而不是再扩大方向历史。

## 取指：预解码 L1I 与孱弱的 L2 路径

A55 的 L1I 可选 16/32/64 KB，取消 A53 的 8 KB 选项，并从两路增至四路，减少“总容量够、映射冲突却反复逐出”的 Conflict Miss。MediaTek 与 Qualcomm 都选择 32 KB。

L1I 不是保存原始字节，而是保存 Predecoded Format：4-byte AArch32/AArch64 指令扩成 40 bit，16-bit T32 扩成 20 bit，Tag 还记录 ISA 类型。这位于传统 I-cache 与完全跳过 Decode 的 Micro-op Cache 之间。

Tag 与 Data 都有 Parity：每 32-bit Tag Entry 一位；每 20 bit 原始数据一位。单个 T32 指令可检测一位翻转；4 B 指令的两个 20-bit Half 若各翻一位也可检测，但同一 Half 内两位同时翻转不保证发现。

![图 9：Predecode L1I 的吞吐边界](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/28caaf1dd6a9b0b4_09_l1i_predecode_ecc.png)

*图 9：NOP Loop 在 32 KB 内保持两 Instruction/cycle，越过 L1I 后跌到不足 1 IPC。所有 A55 实现都能喂满两宽核心，真正短板是 L1I Miss 后的持续供给。*

TRM 写有从 L2 Memory System 到 L1I 的 128-bit Read Interface，但简单流式代码无法持续用满。A55 从 L2 的代码吞吐甚至低于 A53；越过 L2 后，A55 因拥有 L3 才重新领先。

![图 10：A55、A53 的代码供给与前端空转](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/31230ded1bbd3608_10_instruction_fetch_throughput.png)

*图 10：左侧按 Footprint 比较指令吞吐，右侧 Geekbench 6 将 DPU Instruction Queue 为空定义为 Frontend Bound，并继续拆为 Pending I-cache Miss 等原因。Clang 等大代码负载最容易让 Queue 长时间空置。*

### 体系结构视角：接口位宽不是可持续代码吞吐

128-bit 接口只描述一次传输能力。Tag Lookup、Fill Buffer、Bank、L2 仲裁、Branch Target 发现和 Queue 深度都可能让连续供给低于 16 B/cycle。顺序核一旦 DPU Queue 见底，后端没有乱序窗口可用来隐藏空洞。

用相同代码布局改变 Footprint、Taken Density 与并发 Miss 数，再观察 I-cache Refill、DPU IQ Empty 和接口利用率，才能区分“阵列够宽但请求不连续”与“L2 路径本身带宽不足”。

## 后端：双发射仍灵活，但没有“伪 ROB”

A55 大体继承 A53 后端。多数常见指令可从两个 Issue Position 任意一个发射，并有两份常用执行单元；Interlock 处理依赖，Forwarding 则让固定长度管线仍能得到较低延迟。

![图 11：A55 后端 Forwarding Path](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/c7a348355bd2d7ff_11_backend_forwarding_paths.png)

*图 11：根据 Arm Optimization Guide 粗略重绘。EX1/EX2/WR 之间的 ALU、Shift 与 MAC 旁路降低相邻依赖等待；这是文档描述的路径示意，不是 RTL 网表。*

早先用乱序核心方法探测 A53/A55 时，Cache Miss 后似乎还能让少量独立指令前进。结合 Optimization Guide，更合理的解释并非存在某种 Pseudo-ROB，而是年轻指令占据 Load 后面的若干 Pipeline Stage，直到 Miss 无法退休或出现首个 Hazard 才阻止 Issue。可见“重排序距离”只是管线中能暂存多少工作。

A55 把 FP FMA 延迟从 A53 的八周期降到四周期，与 FP Add/Multiply 相同。A53 的八周期 FMA 没有依赖链优势，A55 修正了这一点；同时加入 Armv8.2、Armv8.3 LDAPR 和 Armv8.4 Dot Product 支持。

![图 12：Geekbench 6 中 A55 的后端 Interlock](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/ee1844d5ae8eabb7_12_fp_vector_latency.png)

*图 12：蓝/橙/灰分别为其他、Address Generation 与 FP/ASIMD Interlock。HDR 的 FP/ASIMD 等待仍约占四成多，但 A55 已显著低于 A53；Asset Compression、Photo Filter、Ray Tracer 也受益。*

![图 13：HDR 热点中的 `fmadd`](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/538c29eca64f7081_13_hdr_fmadd_code.png)

*图 13：网页正式图注指出，Geekbench 6 HDR 最热函数包含 `fmadd`，A55 改善的四周期 FMA 很可能直接帮助该负载。它是关联证据，不是单指令贡献的严格消融。*

![图 14：A53 的后端 Interlock 对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/0f73ebefb887477e_14_geekbench_interlock_stalls.png)

*图 14：A53 在 HDR、Photo Filter、Ray Tracer 等 FP/SIMD 负载有更长灰色区。Structure from Motion 没有明显受益，可能是 A55 更好的存储系统把瓶颈推向执行端；整数 File Compression 与 Navigation 的 Interlock 也变化不大。*

两颗核心的 FP/Vector 仍弱：虽有两条 Pipe，每条只有 64-bit Vector Width，FP/Vector 延迟又高于整数。乱序核可以用独立工作隐藏四周期，顺序核更容易直接停顿。

### 体系结构视角：执行单元越多，不代表顺序核越能利用

顺序 Issue 遇到一个未就绪操作时，后面的独立指令也很难绕过。增加第三条 ALU 的收益可能远低于把 FMA 从八周期降到四、或让 Load 早一周期返回；减少 Interlock 才是有效吞吐的关键。

应分别测单依赖链延迟、独立指令双发射和真实负载 Interlock。若 Pipe 理论吞吐高而 Active Cycle IPC 仍低，通常是数据依赖、前端空洞或 Cache Miss，不是缺少执行单元。

## Load/Store：同周期一 Load 加一 Store

A55 存储系统升级更显著。它每周期可同时处理一 Load 与一 Store，而 A53 只能做一次内存操作；单独峰值仍是 Load 8 B/cycle、Store 16 B/cycle。Memcpy 中相邻 Load/Store 可直接受益。

![图 15：A55 的 Load/Store Datapath 改进](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/a04ae64944569907_15_load_store_throughput.png)

*图 15：Arm Slide 强调 Load/Store Dual Issue、Load Writeback 到 AGU/ALU 的新旁路，以及 Pointer Chasing 从三周期缩短到两周期。*

Load 管线调整后，Writeback 开始处可以把结果旁路回 AGU Base Operand，也可送给 ALU，于是 Back-to-back Dependent Load 和 Load-to-ALU 都可两周期完成。

![图 16：两条 Load Forwarding Path](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/c8516eeeca6a1866_16_load_forwarding_paths.png)

*图 16：上方路径把 Data Cache Output 回送到下一条 Load 的 AGU，下方路径送往 EX2 ALU。路径共享或仲裁细节没有公开。*

一个反常现象是两条快路似乎不能同时使用：在两条依赖 Load 之间插入一条依赖于前一 Load 的 ALU，Pointer Chain 变为三周期；插入独立 ALU 则不增加延迟。

![图 17：依赖 Load 之间插入 ALU 的测试](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/2d611865b0c9993e_17_dependent_load_alu_latency.png)

*图 17：三段 AArch64 Sequence 对比 Back-to-back Load、插入独立 ALU、插入消费 Load Result 的 ALU。只有最后一种增加一周期，支持快旁路存在共享约束。*

Indexed Addressing 的 Load 为三周期，仍比 A53 快一周期。A53 Guide 也写过两周期 Pointer Latency，但实测即使展开依赖 Load 也未达到；从其 AGU 到 Writeback 的级数看，文档值如何实现仍不清楚。

![图 18：Cortex-A55 的 Store-to-Load Forwarding](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/f3a9b4c0b60d46ed_18_a55_store_forwarding.jpg)

*图 18：沿 Store/Load Offset 扫描延迟，框线标出 Exact Address Match。网页正式图注说明采用 Henry Wong 方法。绿色快路较短，部分重叠没有乱序大核那种极深回退。*

Store Forwarding 相比 A53 反而变慢。表中 A55/A53：Load 与 Store 对齐时约 4.1/3.1 周期；Load 16B Boundary 为 4.1/5；Store 跨 16B Boundary 为 7.41/4.19（一般是 4.41）；Forwarded Data 跨 16B Boundary 为 5.1/7。

![图 19：A55 与 A53 的典型 Forwarding 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/a44de44ea300ec54_19_store_forwarding_summary.png)

*图 19：非整数平均值说明某些迭代偶尔多一周期，例如最佳情形 A55 更常为四周期、A53 更常为三周期。双发射支持可能增加 LSU 复杂度，但并无 RTL 证据。*

![图 20：Cortex-A53 的 Store-to-Load Forwarding](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/ed71d792523f7069_20_a53_store_forwarding.png)

*图 20：同一矩阵在 A53 上的结果。两颗核心都偏好 Load 8 B、Store 16 B 对齐；部分重叠没有灾难性惩罚。顺序核在途 Store 很少，因此 A55 的回归对真实程序影响可能有限。*

A53/A55 都不支持 Hit-under-miss：一次 L1D Miss 会拖住后续访存，即使后者本可命中 L1。它们仍可让紧随 Miss 的 Load 访问 L1D 并产生最多三个 Outstanding Refill，但三条 Load 必须位于四个 Pipeline Stage 内。

### 体系结构视角：Memory-level Parallelism 不是 Nonblocking Cache 的同义词

A55 能产生三个 Fill，说明它有有限 Miss 并发；不能 Hit-under-miss，说明已有 Miss 时后续 Hit 仍无法独立完成。对顺序核而言，这三项 Fill 更像在管线尚未完全堵住前抢先发出，而非持续调度任意年轻 Load。

验证应把“Miss 后的 Hit”“Miss 后的独立 Miss”“三条 Load 的指令距离”分开。只有后续 Hit 可以完成，才叫 Hit-under-miss；多个 Refill 同时存在只证明有限 MLP。

## 地址转换：小 L1 TLB，大一倍的 L2 TLB

A55 L1 TLB 从 A53 的 10 项增至 16 项，依然远小于旧乱序核——Athlon 64 很早就有 32 项。L2 TLB 从 512 项、四路增至 1024 项、四路，达到 Haswell 级别容量。

![图 21：A55 与 A53 的 TLB 结构](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/880f988b6ac13784_21_tlb_capacity_latency.png)

*图 21：A55/A53 的 L1 TLB 为 16/10，L2 为 1024/512；IPA Cache 与 Walk Cache 均为 64 项、四路。A55 的 L2 TLB Hit 多三周期，A53 为两周期。*

更大一级 TLB 降低访问二级的频率，二级多一周期是合理交换；三周期仍优于不少低频乱序核心，A78 二级命中例如多五周期。Page Walk 更难隐藏，因此 A55 还保留 64 项 IPA Cache 和 64 项 Walk Cache：前者缓存 Guest Physical→Host Physical，后者保存倒数第二级 Page Table Entry，让 Walk 从最后一步开始。4 KB 页下，一个 Table 覆盖 512 页，64 项 Walk Cache 理论上可加速约 128 MB 地址空间。

L2 TLB 有 Parity；检测错误时失效对应 Entry，再重新 Page Walk。

### 体系结构视角：顺序核更怕 Page Walk 的长尾

乱序核心可在一次 Walk 后继续执行其他独立工作，A55 只能容纳约几个周期的年轻指令。扩大 TLB、缓存中间页表项，比再减少普通 ALU 一周期更可能改善大工作集。

用 4 KB/2 MB 页逐步增加 Working Set，可分离 L1/L2 TLB Hit 与 Walk。虚拟化场景还要区分 IPA Cache 命中；否则一次多级翻译的长尾会被误认成普通 DRAM 延迟。

## Cache：私有 L2 与 DynamIQ L3

A55 的 L1D 同样可选 16/32/64 KB、四路。Data 与 Tag 有 ECC：单 Bit Error 通过 Evict、纠错写出并从 L2 重载处理。相联度比 A53 更高，通常可略微改善命中率。

寻址从 A53 的 Physically Indexed, Physically Tagged（PIPT）改为 Virtually Indexed, Physically Tagged（VIPT），32/64 KB 选项也仍是 VIPT。VIPT 并不要求所有 Index Bit 都落在 4 KB Page Offset 内；只要实现处理可能的 Synonym 与物理 Tag 校验即可。

![图 22：VIPT Cache 的索引与物理标签](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/4542d02e2b7043f9_22_vipt_cache_indexing.png)

*图 22：Virtual Address 可在 TLB 翻译同时启动 Set 访问，Physical Tag 稍后确认命中，从关键路径中重叠两项工作。图示用于解释机制，不代表 A55 的具体 Bank/Way 电路。*

Cache Miss 是顺序核最常见的长延迟事件。A53/A55 在 Miss 后只能让约八条年轻指令、也就是四周期吞吐留在管线；任何 L1D Miss 都远长于四周期，因此降低下一级延迟至关重要。

![图 23：顺序管线无法覆盖 Cache Miss](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/0a527daae26eacfb_23_memory_stall_window.png)

*图 23：Arm Slide 把 A55 的性能提升重点放在 L1 Hit 两周期、私有 L2 与 DSU L3。所谓“约八条在途”来自微基准可见距离，不是 ROB。*

A55 为适配 DynamIQ 引入可选的 Core-private L2，主要表现得像 Victim Cache；Software Prefetch 也可直接把数据带入 L2。容量为 64/128/256 KB、四路、64 B Line；对核心为 128-bit Write、64-bit Read，正好匹配 16/8 B 每周期 Store/Load。极端面积配置可以没有 L2，但性能很可能灾难性下降；128 KB 是常见选择，也是 Genio 1200 配置。

![图 24：A55 私有 L2 带来的延迟台阶](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/47b9c88a8640c925_24_private_l2_design.png)

*图 24：2 MB 页下，A55 L1/L2/L3 约 2.04/9.05/35.17 周期；A53 L1/共享 L2 约 3.00/16.92，之后直达约 240 周期 DRAM。A55 的 9 周期私有 L2 约为 A53 17 周期共享 L2 的一半，但平台不同。*

四颗 128 KB 私有 L2 合计 512 KB，是一张 256 KB 共享 L2 的两倍存储；换来的却是每核低延迟与更少争用。DSU L3 接替大容量共享末级角色：第一代 DSU 最高 4 MB；大于 1 MB 使用两个 Slice。2 MB 是 16-way，1.5/3 MB 可通过关闭 Way 得到 12-way。

![图 25：DSU L3 的可配置流水级](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/a400e8f427bc843a_25_dsu_l3_latency_options.png)

*图 25：Arm DSU TRM 展示 L3 RAM 前后可插入配置级，以适配 SRAM 与时序。网页正式图注注明来源；额外 Register Slice 会提高频率余量，也增加 Hit Latency。*

Arm 示例 L3 Hit 为 21 周期，Genio 1200 实测约 35 周期。它高于 S922X A53 Cluster 的 256 KB L2 很合理：DSU 要服务八核而非两核。A53 也支持最高 2 MB L2，只是这种配置可能并不常见。

![图 26：A55 与 A53 的 Cache/Memory 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/b847f5bb86e8c946_26_cache_memory_latency.png)

*图 26：蓝色 A55 通过 32 KB L1、128 KB L2、2 MB L3 形成 2/9/35 周期阶梯；橙色 A53 为 3/17 后直达内存。2 MB Huge Page 减少 TLB 干扰，但 SoC、频率和 DRAM 不同。*

### 体系结构视角：私有 L2 是 A55 最关键的系统级变化

方向预测和 FMA 改善减少部分 Stall，私有 L2 则把最常见的长延迟事件从共享 Cluster 路径拉回每核附近。顺序核几乎无法隐藏 Miss，一次从 17 降到 9 周期的收益可直接落到 IPC。

代价是总 SRAM 增加、私有副本和一致性流量变多。应按核心数测 L2 Hit、DSU Snoop、L3 Hit、Interconnect Boundary 与尾延迟，区分核心本身与 Genio 1200 的具体 DSU 配置。

## Prefetch 与带宽：A55 的真正跃升

密度核通常不追求带宽，但 A55 在大 Working Set 上进步明显。A53 一出 Cache 带宽便坠落；三个 A55 实现的下降都温和，Genio 1200 在很大 Footprint 下单线程几乎不再显著下降。

![图 27：不同 A55 实现与 A53 的读取带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/4371e3ffa0b18ab1_27_read_bandwidth.png)

*图 27：曲线跨过各自 L1/L2/L3 后的形态不同，说明 SoC Prefetch、DSU 与 DRAM 对“小核带宽”影响很大。不能把 Genio 1200 的全部优势归给 A55 Core IP。*

A53/A55 只有三个 L1D Demand Miss 并发，因此高度依赖 Prefetch。A55 的 L1D Prefetcher 最多七个 Outstanding、默认五；A53 甚至可配置到八。A55 新增 L3 Prefetcher，可最多预取前方 32 Line、默认八。L3 容量较大，激进 Prefetch 与热数据争抢的风险更低，这很可能解释大 Footprint 带宽。

![图 28：Demand Refill 与 Prefetch 并发](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/551e595bf22f0b86_28_demand_prefetch_parallelism.png)

*图 28：不同 Implementation 的大 Working Set 带宽反映 Demand Miss、L1/L3 Prefetch 和内存控制器共同作用。文档并发上限不是实际始终占满的请求数。*

A53/A55 都用 Streaming Mode 提升 Store Bandwidth，每级 Cache 在连续“流式”Line 达到阈值后切换策略。MediaTek A55 的大 Footprint Store 仍非常高，其他 A55 更接近 A53。

![图 29：Geekbench 6 的读取与写入带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/9ffe3fe627d2dd46_29_write_bandwidth.png)

*图 29：上半为 Read、下半为 Write；不同 Workload 与核心显示 Genio 1200 A55 的系统供给明显更强。条形值是端到端带宽，不是 L1/L2 端口的孤立峰值。*

PMU 也显示内存相关 Stall 大幅下降。A53 在 Object Remover、Background Blur、Navigation 等负载受害严重，A55 多数接近减半。

![图 30：Geekbench 6 的 Memory Stall](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/311adc1b8c7269d7_30_geekbench_memory_stalls.png)

*图 30：左图为 A55、右图 A53，按 Load/Store、L1D Refill、L2 Access、TLB Walk 等原因分解。两台 SoC 的 Cache/DRAM 差异很大，柱差描述整个平台升级。*

### 体系结构视角：Prefetch 是顺序核的“外置乱序”

核心自己不能从年轻 Load 中挑出独立 Miss，Prefetcher 却可以在地址流中提前生成请求，相当于在 Cache 层创造 Memory-level Parallelism。它不执行程序，也不保证正确使用，因此不会替代 ROB；但对顺序核而言，它是隐藏 DRAM 延迟最现实的方法。

验证要同时报告 Demand Miss、Useful/Useless Prefetch、Cache Pollution、DRAM Bandwidth 和功耗。带宽升高若伴随大量无用 Line 与多核干扰，单线程收益可能变成整机代价。

## 性能：提升很大，但基线也很低

Genio 1200 的 A55 在 Geekbench 6 多项上远超 Arm 当年的参考增幅。Background Blur 相对 S922X A53 提升约 210%，Object Detection、Photo Filter 也很大，来自更少 Memory Stall 与 FP/SIMD Interlock。

![图 31：Arm 2017 年的 A55/A75 参考增幅](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/cb644498424d2e10_31_geekbench6_performance.jpg)

*图 31：同工艺同频率对比中，Arm 给 A55 相对 A53 的 Geekbench v4/Octane/Memcpy/SPECFP2006/SPECINT2006 为 1.22×/1.14×/1.97×/1.42×/1.21×。它是厂商参考，不是本页 Geekbench 6 平台实测。*

更强的 Genio 1200 Cache/Memory 使真实跨平台增幅偏大，不过新 DSU 本就是 A55 时代常见系统条件的一部分。

![图 32：SPEC CPU2026 整数套件估算分数](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/46dbba6debdef32f_32_spec_cpu2026_integer.png)

*图 32：14 项整数工作负载全部由 A55 领先，几何平均相对 A53 提升 35.35%。图题明确为 Estimated Scores；测试版本虽为 SPEC CPU2026，网页未完整给出编译参数和运行统计。*

![图 33：SPEC CPU2026 浮点套件估算分数](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/a1c835cfb0a7e55d_33_spec_cpu2026_fp.png)

*图 33：12 项 FP 工作负载的几何平均提升 50.45%，`cactus`、`fotonik3d`、`roms_r` 等接近翻倍。因单次运行极慢，没有收集 SPEC PMU；将增幅归因于较少 I-cache Miss 或更强内存系统仍是解释。*

整数套件提升较小的一种可能性，是它的大 Instruction Footprint 更惩罚 A55；FP 套件 I-cache Miss 较少，优势重新回到更强的数据存储系统。

![图 34：A55 在 SPEC CPU2026 中的 IPC](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/d8af80feb2ce01f6_34_geekbench_ipc.png)

*图 34：多数项目只有约 0.35～0.9 IPC，少数刚过 1，远低于两宽理论上限。这是顺序核很难持续喂满的直接证据。*

![图 35：Geekbench 6 的 A55、A53 与 A73](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/540c332653c07687_35_a55_a73_performance.png)

*图 35：A55 相对 A53 几乎逐项提升，但两宽乱序 A73 多数仍明显更快。大 Cache 与更好预测可以减少停顿，却无法复制乱序调度跨过依赖/Miss 的能力。*

![图 36：Geekbench 6 总分与小核面积路线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a55_wechat_article_zh/fed2eeffa66fc0ef_36_a55_a510_area.png)

*图 36：A73/A55/A53 总分为 385/283/183。A73 使用旧式 Pre-DSU、S922X 中仅 1 MB L2，仍领先 A55；说明即使低于 1 W，乱序执行也有巨大价值。原图资源只展示成绩，关于 A510 共享结构的延伸来自正文结论。*

## 最后的评价：不激进，却很合理

A55 的核心框架并不新奇，大部分 A53 后端保持不变。这反而是合理选择：顺序核对任何超过几周期的事件都束手无策，更好的预测与 Cache 直接减少这些事件，收益比盲目增宽执行端更可靠。

但 A55 的 IPC 仍展示两宽顺序执行的困难。继续增大 Cache 和预测器会占面积、功耗，并很快遇到边际收益；小型两宽乱序 A73 即使没有明显更好的内存系统，也能轻松领先。

Arm 最终判断顺序执行仍有生命力。后继 A510 扩到三宽，并让两颗核心共享部分组件省面积。三宽顺序核显然更难喂饱，但在亚瓦级目标下，乱序逻辑的复杂度、验证和功耗也许仍太昂贵。

### 体系结构视角：从 A55 可以看到的几件事

第一，小核代际升级不必重造执行引擎。A55 的最大收益来自减少 Branch、I-cache、Data Cache 与 FP Dependency Stall，而不是增加理论峰值。

第二，顺序执行把系统设计放大成核心性能。128 KB 私有 L2、2 MB DSU L3 和 LPDDR4X 让 Genio 1200 A55 远好于 S922X A53；评价 Core IP 时必须把 SoC 贡献剥离。

第三，48 项 Micro-BTB 展示了“极小结构解决高频 Common Case”的价值。它让紧循环零 Bubble，却不掩盖大代码 Target Path 的 28～29 周期问题。

第四，Prefetcher 是顺序核获得 MLP 的主要手段。三个 Demand Refill 的窗口很浅，L3 Prefetch 却能提前拉回多条 Line；性能与能耗都取决于准确率和多核干扰。

第五，固定流水线也可以有丰富旁路。两周期 Dependent Load、四周期 FMA 和有限双发射说明“顺序”不等于没有技巧，只是无法动态重排远处工作。

第六，Benchmark 增幅要同时看基线和测试系统。35.35%/50.45% 的 SPEC CPU2026 提升很大，A53 基线却极低；Geekbench 的 210% 个别提升又混入更强 DSU 和 DRAM。

第七，小核的终极边界不是宽度，而是长延迟容忍。只要几周期之外的事件仍会封死 Issue，再增加第三条 Pipe 的收益就可能输给一个小型乱序窗口——这也是理解 A510 后续路线的最佳问题意识。

## 参考资料

- Chips and Cheese：[*Arm’s Cortex A55*](https://chipsandcheese.com/p/arms-cortex-a55)
- Henry Wong：[*Store-to-Load Forwarding and Memory Disambiguation in x86 Processors*](https://blog.stuffedcow.net/2014/01/x86-memory-disambiguation/)
