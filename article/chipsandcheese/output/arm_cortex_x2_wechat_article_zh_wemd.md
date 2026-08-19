---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "arm_cortex_x2_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*Cortex X2: Arm Aims High*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2023 年 10 月 27 日
> - 链接：https://chipsandcheese.com/p/cortex-x2-arm-aims-high

Arm 长期占据功耗—性能曲线的低端。当 Intel 尝试向低功耗市场下探时，Arm 也在向更高性能区间上攻，Cortex-X 系列正是这条路线的前锋。Arm 对 Cortex-X Custom CPU Program 的定位是：在扩大的功耗与面积包络内，提供极致峰值性能。

被测实现来自 Asus Zenfone 9 的 Snapdragon 8+ Gen 1：一颗 Cortex-X2、三颗 Cortex-A710 和四颗 A510。X2 常见运行频率为 2.8 GHz，`lscpu` 报告的可选范围是 787.2 MHz～3.187 GHz。加负载后先迅速升到 2.56 GHz，约 55 ms 后到 2.8 GHz；更长测试没有观察到更高频率。

![图 1：Zenfone 9 中 Cortex-X2 的 Boost 过程](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_x2_wechat_article_zh/a157f38cb61f63eb_01_x2_boost_behavior.png)

*图 1：测试设备为 Asus Zenfone 9。频率先从约 0.79 GHz 跳到 2.56 GHz，约 55 ms 后稳定在 2.8 GHz，期间有短暂下探。3.187 GHz 是系统枚举的频点，不是本次持续负载实测。*

网页没有披露 Android/Kernel 版本、编译器与 Flags、温度、功耗、预热、重复次数及误差；Android 又无法使用 Huge Page。后文与 Zen 4、M1、Skylake、N1/N2 的图来自不同 ISA、平台与频率，适合比较微结构趋势，不能当作统一应用排名。

## 核心总览：A710 的大号兄弟

X2 与 A710 同宗，却明显更大：更宽流水线、更多执行单元和更深乱序资源。两者仍是十级流水线，说明 Arm 没有为了扩大宽度而简单拉长核心前端到执行的最短距离。

![图 2：Cortex-X2 核心总览](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_x2_wechat_article_zh/a883b46bc6e39dd3_02_cortex_x2_overview.jpg)

*图 2：五宽 Decode、六宽 Rename、3072 项 Micro-op Cache、288 项 ROB、四整数 Scheduler、四条 FP/Vector Pipe、三 AGU、64 KB L1I/L1D、1 MB L2，并连接 DSU-110 的 6 MB L3。图中部分队列和端口容量由微基准重建，不是 Arm RTL。*

### 体系结构视角：放大一套已有架构，比另起炉灶更容易共享工程成本

X2 不是与 A710 完全不同的核心。相似的 Scheduler 布局、融合与恢复逻辑可以共享设计和验证经验，再分别调宽度、容量与时序。它比 AMD 只改变物理实现的 Zen 4/Zen 4c 分化更大，又比 Intel Golden Cove/Gracemont 两套完全不同微架构更接近。

共享基础能减少前端、ISA 一致性和验证成本，但大核心仍需要重新平衡队列、旁路、布线与功耗。简单把所有容量乘二，通常会在关键路径或端口碎片上付出过高代价。

## 分支预测：比 A710 更强，但仍在手机功耗包络里

X2 获得更大面积和功耗预算，因此能识别比 A710、Neoverse N2 略长的模式，也能容纳更多同时活跃的分支。

![图 3：Cortex-X2 的方向模式识别](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_x2_wechat_article_zh/a68d28e72c69b4f9_03_x2_branch_pattern.png)

*图 3：低延迟平台覆盖较长 Pattern 和较大静态分支数；转折之后同时包含历史不足、容量与混叠，无法据此唯一确定预测算法。*

![图 4：Neoverse N2 的方向模式识别](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_x2_wechat_article_zh/37602dc7de2620e8_04_neoverse_n2_branch_pattern.jpg)

*图 4：服务器 N2 的同类曲面略弱于 X2，说明 X 系列确实把额外预算投入预测器。测试平台和频率不同。*

![图 5：Cortex-A710 的方向模式识别](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_x2_wechat_article_zh/a68d28e72c69b4f9_05_cortex_a710_branch_pattern.png)

*图 5：A710 与 X2 同宗，形态接近，但 X2 的稳定区域更大。比较的是受控模式，不是实际程序预测正确率。*

![图 6：Zen 4 的方向模式识别](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_x2_wechat_article_zh/9120affce47088a1_06_zen4_branch_pattern.jpg)

*图 6：Zen 4 在更长模式和更大分支足迹下继续维持较好表现。X2 虽称扩大功耗面积包络，仍要进入被动散热手机，预测器预算远小于桌面核。*

目标侧基本沿用 A710：Micro BTB 最多跟踪约 64 个分支，可每周期处理两条 Taken；随后约 10K 分支由更慢层覆盖，增加约 1～2 周期。Return Address Stack（RAS）约 14 项。

![图 7：Cortex-X2 的 BTB 容量与延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_x2_wechat_article_zh/6c66ef6519a0ddce_07_x2_btb_capacity.png)

*图 7：曲线改变 Branch Spacing。约 64 项快层后进入大约 10K 的主层，代码足迹继续增大后出现 Cache/目标供给台阶。64/10K/14 均来自微基准观察或反推，不是公开 RTL 参数。*

### 体系结构视角：预测器的预算应与错误路径深度共同看

288 项 ROB 让 X2 能在未解析分支后投机更远，误预测可浪费的工作远多于 A53/A73，因此更强预测器的回报也更高。另一方面，预测器自身位于每次 Fetch 的关键路径，表越大越需要分级、并行哈希和稍后覆盖。

验证要把方向 MPKI、BTB miss、RAS miss、恢复周期和错误路径发射数放在一起。只有方向正确却目标给晚时，增加方向表容量不会消除 Taken Bubble。

## 前端：64 KB L1I、3072 项 Micro-op Cache 与五宽 Decode

X2 把 A710 的 1536 项 Micro-op Cache 扩到 3072 项，比 Sunny Cove 还大；L1I 强制为 64 KB，而 A710 可选 32/64 KB。Zen 4 的 Micro-op Cache 更大，但 L1I 只有 32 KB。若代码在 32～64 KB、又有大量难预测分支，Zen 4 更容易落到 L2，X2 的大 L1I 反而有优势。

X2 Micro-op Cache 每周期可给 8 条操作，足够喂六宽 Renamer；五宽 Decoder 也比 A710、Zen 4 的四宽更强。图中 Instruction Queue 连接两条供给路径。

![图 8：X2、A710 与 Zen 4 前端](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_x2_wechat_article_zh/4323d224bfe0f86a_08_frontend_x2_a710_zen4.png)

*图 8：X2 为 48 项全相联 iTLB、2048 项八路 L2 TLB、64 KB 四路 L1I、20 B/cycle、五宽 Decode、3072 项四路 Micro-op Cache、8 micro-op/cycle；A710 为 1024 项 L2 TLB、32/64 KB L1I、四宽 Decode、1536 项；Zen 4 为 64 项 iTLB、512 项 L2 iTLB、32 KB L1I、四宽 Decode、约 6912 项 Micro-op Cache、9 micro-op/cycle。部分 Zen 4 Queue 容量带问号。*

![图 9：Cortex-X2 与 Zen 4 的前端供给](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_x2_wechat_article_zh/6f332ed1a4ca12f9_09_frontend_bandwidth.png)

*图 9：X2 小足迹 MOV 混合约 5.8 IPC，NOP 因融合可超过 10；64 KB 附近约 4.71，512 KB 内约 4，进入 L3 约 1.66。Zen 4 非 V-Cache Die 的小足迹融合结果接近 12，Decoder 路径约 3.97，L3 可约 3.28 IPC。不同指令混合和 ISA 不能当作纯 Decode 宽度对比。*

代码在 L2 时，X2 仍能超过四条指令/cycle；进入 L3 后 Zen 4 凭借低延迟 L3 与更激进预测器超过 3 IPC，X2 仍有 1.66，表现不差但差距明显。

### 体系结构视角：Micro-op Cache 和 L1I 解决的不是同一种 Miss

Micro-op Cache 命中绕过 Decode，节省能量并提高供给；L1I 命中只保证拿到指令字节，仍需译码。难预测分支会降低 Micro-op Cache 连续命中机会，而 64 KB L1I 仍可减少落入更慢 L2 的概率。

应按同一代码布局分别测 Micro-op Cache 命中、L1I miss、Decoder 活跃周期和 Renamer 供给。NOP 容易被融合，不能用其峰值直接代表一般 AArch64 程序。

## 乱序资源：接近 Zen 4，Load 容量尤其惊人

X2 保留 A710 的融合优化，把 ROB 从 160 增至 288，其他资源相应扩大。

![图 10：X2、A710 与 Zen 4 的乱序资源](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_x2_wechat_article_zh/90bb9d4f24dd5747_10_ooo_resource_comparison.jpg)

*图 10：ROB 为 288/160/320；整数 Rename 约 213/147/224；FP/Vector 为约 156×128-bit、124×128-bit、192×512-bit；Flags 为 70/46，Zen 4 文档 108、实测 238；LQ 为 174/64，Zen 4 文档 88、实测 136；SQ 为 72/36/64；Branch Order 为 68/44/118。测量值是特定阻塞构造下的可见容量。*

X2 多数结构已接近 Zen 4，Load Queue 甚至更深。融合让它可跟踪约 249 条待退休 FP 操作，Zen 4 约 154；但 Zen 4 的 512-bit AVX-512 物理寄存器能在宽向量代码中保存更多显式并行工作。

A710 的 Scheduler 相对 ROB 有些过配；X2 把比例拉回平衡。整数侧是四组 24 项 Queue，与 Zen 4 的四组容量惊人地接近。区别是 Zen 4 还让这些 Queue 与 AGU 共享，X2 的 AGU 有独立调度结构。

### 体系结构视角：同样的 Scheduler 项数，不代表同样的可用窗口

端口绑定、融合后 micro-op 数、物理寄存器宽度和 NSQ 都会改变有效容量。X2 的 174 项 Load Queue 很深，但如果某组 24 项整数 Queue 先满，前端仍会停；Zen 4 总项数相似，却能让不同操作共享更多位置。

验证需用不同指令类型逐一阻塞，并观察各 Queue Full、ROB/LSQ/Register Full 和端口利用率。总容量只能描述上限，端口可达性决定程序实际能用多少。

## 四条 FP/Vector Pipe：128-bit 吞吐很强

A710 只有双 FP/Vector Pipe；X2 用更大面积预算扩到四条，四条都能处理常见运算，并保持 A710 的低 FP 延迟。优化指南认为某些指令可用满四条，但测试没有完全达到理论值，即便如此吞吐仍很高。

![图 11：X2、A710 与 Zen 4 的 FP/Vector 吞吐](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_x2_wechat_article_zh/d4ba004fda9643bc_11_fp_vector_throughput.jpg)

*图 11：X2/A710/Zen 4 的 FP32 Add 为 2.53/2/2 per cycle、延迟 2/2/3；FMA 为 2.53/2/2、延迟均 4；128-bit INT32 Add 为 2.53/2/4、延迟 2/2/1；Multiply 为 1.26/1/2、延迟 4/4/3。网页正式图注说明对应 FP 向量版本的延迟和吞吐相同。*

Zen 4 可做两条 256-bit FMA/cycle，X2 的理论等价是四条 128-bit FMA；按每周期总位数相同。Zen 4 在长向量和整数向量延迟上仍占优。

X2 的 FP Scheduler 看起来是两组各约 23 项。因为找不到只能使用单条 ADDV Pipe 的操作，无法判定是一张 23 项共享队列、11+12 分区，还是更可能的两张双端口 23 项队列。Zen 4 为两组 32，共 64 项；X2 若按 23+23 则为 46。

两者在 Scheduler 前都有 Non-Scheduling Queue（NSQ）。NSQ 不做每周期 Wakeup/Select，可用较低成本容纳更多未完成操作。X2 为 29 项，总计可保留约 75 条未完成 FP；Zen 4 为 64 项，总计约 128。

![图 12：X2 与 Zen 4 的 FP/Vector 调度](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_x2_wechat_article_zh/1ff16bca2983986a_12_fp_vector_scheduler.jpg)

*图 12：X2 为 29 项 NSQ、两组约 23 项 Scheduler、四条 128-bit Pipe；Zen 4 为 64 项 NSQ、两组 32 项 Scheduler、四条主要 256-bit Pipe。X2 的 23+23 组织仍是行为重建。*

### 体系结构视角：NSQ 用“不能立即选择”换容量

Scheduler 每周期要比较源操作数是否就绪并选择端口，面积和功耗随条目与端口迅速增长。NSQ 只缓存尚不能进入调度窗口的操作，不必承担同等比较网络。它不能替代 Scheduler，却可防止长延迟 FP 很早堵住前端。

如果 NSQ 满而 Scheduler 仍有空位，问题可能是依赖尚未成熟或转移带宽；Scheduler 满且 Pipe 利用率高则是执行吞吐饱和。二者需要不同优化方向。

## 三 AGU 与 Store Forwarding：吞吐现代，依赖处理偏保守

X2 有三条地址生成单元（AGU），每周期最多三次访存，其中可为三次 Load、最多两次 Store。布局与 A710、Neoverse V2 有相似之处，但调度 Queue 略小，前面还有很小的 NSQ。

地址生成后，LSU 必须让 Load/Store 在架构上像按程序顺序发生，并从更老 Store 向依赖 Load 转发数据。X2 的行为延续 N1 之后的 Arm 核心：64-bit Store 可把任一 32-bit 半部快速转给 32-bit Load，其他大多走慢路。快路 5 周期，慢路额外 10～11 周期。

![图 13：Cortex-X2 标量 Store-to-Load Forwarding](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_x2_wechat_article_zh/83dcf1931a9fa685_13_x2_scalar_store_forwarding.png)

*图 13：按 Henry Wong 方法扫描 Offset，快路只覆盖有限的精确半部组合，大片部分重叠进入 10～11 周期慢路。格内单位为周期。*

Zen 4 更健壮：只要 Load 完全包含于旧 Store 就能转发，精确地址匹配甚至零额外延迟。不过其慢回退路径高达 19～20 周期，可能说明从地址生成到 Store 退休之间流水级更多。

![图 14：Zen 4 标量 Store-to-Load Forwarding](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_x2_wechat_article_zh/7ddf58c35b127fe8_14_zen4_scalar_store_forwarding.png)

*图 14：绿色可转发区域远大于 X2，但部分重叠或不支持组合的红色慢路更深。零额外延迟指相对正常 Load Pipeline，不等于数据物理瞬时到达。*

对齐方面 X2 更稳健。Zen 4 Store 跨 32 B 对齐边界时降到每两周期一条；X2 直到跨 64 B Cache Line 才受罚。Henry Wong 用更小 Load/Store 宽度测试也没有看到显著不同。

128-bit Store 的向量情况略有不同：X2 可转发任一 64-bit 半部，还能快速转发低 32 bit，再与 L1D 的另 32 bit 合并，完成部分重叠的 64-bit Load。

![图 15：X2 的向量 Store Forwarding](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_x2_wechat_article_zh/837c58bf1e07b20a_15_x2_vector_store_forwarding.png)

*图 15：测试使用 `str q,[x]` 与 `ldr d,[x]`。除两个 64-bit 半部外，低 32-bit 合并路径形成额外快区；其余部分重叠仍进入慢路。*

![图 16：Zen 4 的向量 Store Forwarding](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_x2_wechat_article_zh/754bc3a560cb2132_16_zen4_vector_store_forwarding.png)

*图 16：使用 `movups` Store 与 `movsd` Load。行为与标量侧相近但多几周期；未对齐 Load 基本免费，Store 更容易撞上 32 B 边界惩罚。*

### 体系结构视角：Forwarding 设计是在快路覆盖率与慢路深度间取舍

X2 只为常见半部匹配做短快路，因此逻辑简单、最坏约 10～11 周期；Zen 4 覆盖范围大、最佳可零额外延迟，却有 19～20 周期回退。真实收益取决于编译器生成的宽度、对齐和重叠分布。

测试要区分完全包含、部分重叠、不同大小、跨 32/64 B、跨页和异常页，并结合 Replay/Recovery 事件。矩阵只能确认输入到延迟的行为，不能单独确定 Store Queue 比较粒度或旁路拓扑。

## 地址转换：2048 项 L2 TLB 补上 A710 的短板

X2 的一级数据 TLB 为 48 项全相联，比 A710 的 32 项大，仍小于 Zen 4 的 72 项。L1 miss 可由 2048 项、八路 L2 TLB 接住，代价多 5 周期；A710 只有 1024 项四路，N2 为 1280 项。X2 已追平 Zen 2，但仍低于 Zen 4 的 3072 项、24 路。

![图 17：X2、A710 与 Zen 4 的地址转换](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_x2_wechat_article_zh/c2e9bfb3a7c0eab5_17_address_translation.png)

*图 17：X2/A710 使用 48-bit VA、40-bit PA，L1 DTLB 为 48/32 项，L2 为 2048×8-way/1024×4-way，命中均多 5 周期；Zen 4 为 72 项 L1、3072×24-way L2，L1 miss 后约多 7～8 周期，VA/PA 为 48 bit。*

### 体系结构视角：扩大 TLB 不只减少 Page Walk，也改变 L3 可见延迟

L1 DTLB 覆盖不住 6 MB L3 使用 4 KB 页时的全部工作集，因此程序测到的 L3 曲线还包含 L2 TLB 命中代价。X2 扩到 2048 项后，TLB Reach 为 8 MB，恰能覆盖整个 6 MB L3，这使大 Cache 的真实延迟更容易暴露。

验证应对 4 KB 与大页使用相同物理访问序列，分别记录 L1/L2 TLB hit、Page Walk 与 Cache hit。Android 无大页时，只能承认 TLB 与 Cache 延迟难以完全拆开。

## Cache 与内存：核心很强，SoC 喂得不够好

Snapdragon 8+ Gen 1 为 X2 提供三级 Cache。强制 64 KB L1D，命中 4 周期；对低于 3 GHz 的核心不算惊艳，老 Athlon/Phenom 早已做到 3 周期。补偿是带索引寻址不会像近期 AMD/Intel 那样再多一周期。

X2 L2 可选 512 KB 或 1 MB、均八路，容量通过 Set 数改变。L2 Inclusive 于 L1D，因此 Arm 不提供更小选项是合理的。Qualcomm 选择 1 MB；命中 11 周期、略低于 4 ns。L1D/L2 始终有 ECC，不再把可靠性做成可选项。

![图 18：Snapdragon 8+ Gen 1 的 X2 延迟层级](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_x2_wechat_article_zh/fb6c287bcc4137cb_18_x2_cache_latency.png)

*图 18：短依赖链与长 Pattern 两种曲线。L1 约 1.44 ns，L2 接近 3.98 ns，4 MB 工作集约 18.18 ns，1 GB 达 202.18 ns；Zen 4 非 V-Cache Die 对照为 L1 0.96、L2 3.36、L3 约 16.22、DRAM 106.89 ns。Android 无大页，TLB miss 与 Page Walk 混入大工作集。*

L2 通过 256-bit 总线连接 DSU-110。DSU 最多配置 16 MB L3；容量为二次幂时 16 路，可被 3 整除时为 12 路。Qualcomm 选 6 MB，因此是 12 路。

![图 19：DSU-110 的 Slice 与双环](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_x2_wechat_article_zh/4957c4e2badd950c_19_dsu110_structure.png)

*图 19：来自 Arm DSU-110 TRM。多个核心、每核/Cluster 私有 Cache 接入由 L3 Slice、Snoop Filter 和双向环组成的 DSU，再通过 CHI 等总线连接系统。它说明 IP 能力，不等于 Snapdragon 的完整物理布局。*

L3 按 Slice 组织，由私有 Cache Victim 填充。X2 在 4 MB 工作集处约 18.18 ns，接近 Core i9-12900K E-core 的 17.41 ns。6 MB 既小又不快；按 X2 约 2.8 GHz 计仍是约 51 Core Cycle。

![图 20：DSU-110 的可配置 L3 数据流水线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_x2_wechat_article_zh/5d05e371e0b02748_20_dsu110_l3_pipeline.png)

*图 20：来自 Arm DSU-110 TRM。L3 Data RAM、ECC、输出等部分可配 5～7 周期；程序可见延迟还包括 Tag、互连、上级 Cache/TLB 和仲裁，不能把 18.18 ns 只归给 SRAM。*

1 GB 工作集 DRAM 延迟约 202 ns。L2 TLB miss 与 Page Walk 可能很重，却因 Android 无 Huge Page 难以拆出。手机 SoC 中不算离谱，但远落后桌面/笔记本，也差于 Apple M1。Apple 12 MB 共享 L2 承担 Snapdragon 6 MB L3 的类似系统角色，却同时更大、更快。

![图 21：X2 与 Apple M1 的 Cache/Memory 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_x2_wechat_article_zh/c7aa11ba0262065e_21_cache_memory_latency_comparison.png)

*图 21：X2 长 Pattern 的 L1/L3/DRAM 约 1.44/18.18/202.18 ns；M1 约 0.94/6.19/105.92 ns。两者 Cache 层级命名和平台不同，图说明供给差距，不是核心 IPC 比较。*

### Read 带宽

三 AGU 与三端口 L1D 可每周期服务三次 128-bit 访问。X2 与 A710、M1 的每周期 L1D 峰值接近，M1 依靠更高频率取得更高绝对 GB/s；近期 x86 还有更宽向量，因此绝对带宽也更高。

![图 22：X2、M1 与 N1/Ampere Altra 的向量 Read 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_x2_wechat_article_zh/cb1b1feabe8c735f_22_vector_read_bandwidth.png)

*图 22：L1 峰值 X2/M1/Altra 约 134.25/153.56/91.60 GB/s；L2 约 79.17/86.33/57.94；约 4 MB 时 X2/M1/Altra 约 54.45/86.33/39.49；大工作集约 32.55/57.15/14.93。平台与频率不同。*

X2 L2 约 28 B/cycle，接近 M1。Zen 4/Skylake 因高频拥有明显绝对优势。L2 miss 进入可配置 72～96 项 Transaction Queue，深队列帮助覆盖高 L3 延迟，使 X2 L3 带宽可接近 Skylake。单颗 X2 的 DRAM Read 约 32.5 GB/s；DSU-110 的 CHI 每个 Master Port 最多跟踪 128 个 Read，若 Qualcomm 用它接内存控制器，可以解释高延迟下仍有不错带宽，但连接方式未确认。

![图 23：X2、Skylake 与 Zen 4 的 Read 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_x2_wechat_article_zh/161fcbb2cccc6b9a_23_cache_memory_read_bandwidth.png)

*图 23：L1 X2/Skylake/Zen 4 约 134.05/225.13/261.29 GB/s；L2 约 79/104.12/133.89；L3 区域 X2 约 56.79、Zen 4 约 114.42；DRAM 约 32.55/21.35/41.63。Zen 4 固定 4.2 GHz，跨 ISA/频率只看层级形态。*

### Write Streaming

Write 通常先做 Read-for-ownership（RFO），把 Line 填入 Cache，再修改并写回，因而会消耗 Read 带宽。X2 能检测连续完整覆盖 Cache Line、且旧数据从未被读的模式，随后切换到 Write Streaming：miss 不再 Fill，直接把新数据向下写，避免 RFO 与 Writeback 争带宽。

L1D Write 较低，因为只有两条 AGU 能做 Store；更低层却全部受益。L2 可到约 30 B/cycle，L3 约 67 GB/s，DRAM 约 41.2 GB/s。页面认为这更接近 64-bit LPDDR5-6400 控制器可提供的带宽，但内存配置与流模式仍影响结果。

![图 24：X2 的 Read 与 Streaming Write 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_x2_wechat_article_zh/e5c2a4103374e839_24_cache_memory_write_bandwidth.png)

*图 24：L1 Read/Write 约 134.05/89.77 GB/s；L2 附近约 79/83.91；L3 约 54.28/66.98；DRAM Read/Write 约 32.55/41.20。Write 曲线在最大工作集末端下降，不能把单点峰值当作所有写法。*

### 体系结构视角：高延迟并不必然意味着低带宽

延迟是单条依赖链等待多久，带宽是足够多独立请求能否填满通路。X2 的 202 ns DRAM 很慢，却借 174 项 LQ、72～96 项 Transaction Queue 和可能的 128 Read CHI Credit 维持约 32.5 GB/s。没有足够独立请求的程序仍会直接承受高延迟。

验证需改变并行 Stream 数、依赖/独立 Load、读写比例和 Cache Line 覆盖率，并记录 LQ/TQ Occupancy、Outstanding Read、RFO 与 Writeback。Streaming Write 只有在连续完整覆盖达到阈值后才出现，不应外推到普通小 Store。

## 结语：核心向上走了，系统也必须跟上

X2 据称面积约 2.1 mm²，只略小于 Zen 4c。Arm 向高性能上攻的同时，AMD/Intel 正向低功耗和小面积下探，三家的覆盖区间开始重叠。

![图 25：Arm 给出的 Cortex-X2 面积与性能定位](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_x2_wechat_article_zh/ad5439efcc29e5bf_25_cortex_x2_area_slide.jpg)

*图 25：Arm 官方演示页展示 X2 的实现区域和性能/功耗曲线，红色组件标签为网页后加。2.1 mm² 依赖工艺、库和配置，不能脱离实现条件直接与其他裸片面积比较。*

Arm 的做法是把 A710 的关键滑块推高：更深乱序结构、更大 L1/L2/Micro-op Cache、四 Pipe FPU，以及从 1024 增到 2048 的 L2 TLB。额外面积主要补上 A710 最弱的向量吞吐、TLB Reach 和窗口容量。

![图 26：X2 到 X4 继续扩大的 TLB 与 L2](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_x2_wechat_article_zh/4df46f90585d41bd_26_x2_x4_tlb_l2_comparison.jpg)

*图 26：依据 Cortex-X4 TRM 整理，X2 为 48 项 iTLB、48 项 dTLB、512 KB/1 MB L2；X4 增至 128/96 项，并增加 2 MB L2 选项。它显示 X 系列后续仍沿着修补供给短板的方向发展。*

X2 展示了 Arm 乱序架构在放宽功耗和面积后能达到什么程度，也确实开始给 AMD、Intel 施压。但强核心装进慢 L3 和 202 ns DRAM 的 SoC 后，宽度和队列仍无法完全发挥。页面最强烈的期待不是再把核心做宽一点，而是未来产品能用更好的系统实现展示 Cortex-X 的潜力。

### 体系结构视角：从 Cortex-X2 可以看到的七个设计认识

第一，X2 不是简单的“手机超大核”，而是 A710 设计空间的上沿。共享架构降低工程成本，额外预算则投向预测、窗口、FPU、TLB 和 Cache。

第二，前端峰值已经不是明显短板。8 micro-op/cycle、五宽 Decode 与 64 KB L1I 足以喂六宽 Rename；进入 L3 后的 1.66 IPC 更多暴露下级供给与预测延迟。

第三，深窗口必须配合资源平衡。288 项 ROB、174 项 LQ 很强，但 FP Scheduler/NSQ 仍小于 Zen 4，Store Queue 与 Branch Order 也可能更早限制特定代码。

第四，四条 128-bit Pipe 能在常见标量与短向量上接近两条 256-bit Pipe 的位吞吐；长向量寄存器容量、指令数和调度项仍让 Zen 4 占优。

第五，Store Forwarding 显示两种不同哲学。X2 快路覆盖窄、慢路较浅；Zen 4 覆盖广、最佳更快，但最坏回退更深。不能只拿一格延迟判断 LSU 优劣。

第六，高内存延迟可用 MLP 挽救吞吐，却无法挽救串行依赖。32.5 GB/s Read 与 202 ns 可以同时成立，这正是 Queue 深度与程序并行性的重要性。

第七，核心 IP 与 SoC 供给必须共同设计。6 MB/18.18 ns L3 和 202 ns DRAM 让 X2 无法持续展示核心宽度；Apple M1 的共享 Cache 对照说明“把核心喂饱”本身就是架构竞争力。

## 参考资料

- Chester Lam，*Cortex X2: Arm Aims High*，Chips and Cheese，2023-10-27：https://chipsandcheese.com/p/cortex-x2-arm-aims-high
- Arm，*Cortex-X Custom CPU Program*
- Arm，*DSU-110 Technical Reference Manual*（图 19、20 来源）
- Arm，*Cortex-X4 Technical Reference Manual*（图 26 整理来源）
- Henry Wong 的 Store-to-Load Forwarding 测试方法（网页引用）

如果这类分析对你有帮助，可以通过原页面列出的 Patreon 或 PayPal 支持 Chips and Cheese，也可以加入其 Discord 社区交流。
