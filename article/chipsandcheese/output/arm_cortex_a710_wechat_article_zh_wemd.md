---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "arm_cortex_a710_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*ARM’s Cortex A710: Winning by Default*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2023 年 8 月 11 日
> - 链接：https://chipsandcheese.com/p/arms-cortex-a710-winning-by-default

2010 年代后半，Cortex-A73、A75 和 A76 在维持能效的同时持续提高性能。Qualcomm、Samsung 先后发现，直接授权 Arm 核心比继续自研更容易；Apple 虽然强大，却封闭在自家生态。到 Cortex-A78 时，Android 高性能 CPU 核几乎已没有真正对手。

Cortex-A710 延续这份优势。它沿用 A78 的成功框架，优先提高能效，在部分结构上甚至主动收缩。Arm 宣称：相对只有一半 L3 容量的 A78，A710 可提升 30% 能效，或在固定功耗下提高 10% 性能；同时升级到 Armv9-A 并加入 Scalable Vector Extension（SVE）。这些是 Arm 给定对照条件下的官方目标，不等于任意手机的整机提升。

## 系统层：DSU-110、异构核心与实际频率

测试设备是 Asus Zenfone 9，SoC 为 Qualcomm Snapdragon 8+ Gen 1：一颗 Cortex-X2、三颗 A710、四颗 A510。它们很可能通过 Arm DynamIQ Shared Unit 110（DSU-110）互连。DSU-110 最多连接 12 核，可接内存和外设，也可配置最高 16 MB L3。Qualcomm 选择 6 MB；Arm 的能效/性能估算采用 8 MB，因此实际实现用更小面积换取了少量性能。

![图 1：Snapdragon 8+ Gen 1 的核心与共享 Cache](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a710_wechat_article_zh/0f6b218fcbf85c13_01_snapdragon_8plus_gen1_cluster.png)

*图 1：X2、三颗 A710 和两组双核 A510 连接 DSU-110，后接 6 MB L3 与 LPDDR5。不同核心的私有 L2 容量、频率也不同。*

DSU-110 用 Snoop Filter 维持一致性。过滤器和 L3 都切成多个 Slice，以双环相连，地址跨 Slice 交错映射；结构很像 Sandy Bridge Ring，可随 Slice 数扩展带宽。用核间延迟测试来回转移 Cache line 时，同一核心对也会随地址落入不同 Home Slice 而变化。

![图 2：Snapdragon 8+ Gen 1 的核间延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a710_wechat_article_zh/d8a3b1b0f411a2af_02_core_to_core_latency.png)

*图 2：A710 核心已标出；数字单位为 ns，Offset 相对 4 KB 对齐地址。相同核心对随地址 Offset 改变，说明 Home Slice 会参与关键路径。*

DSU-110 还允许两个核心组成 Cluster，共享部分逻辑以节省面积，但会损失性能。Qualcomm 把 A510 配成双核 Cluster，A710 没有成对聚类，因此 A710 与其他核心转移 Cache line 时通常延迟较好。

![图 3：DSU-110 的 Cluster 与电源域](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a710_wechat_article_zh/f8ef9a16a9c57efc_03_dsu110_cluster_topology.png)

*图 3：Arm TRM 展示双核 Cluster、每核 L2、共享 Snoop Filter/L3 Slice、独立电源与时钟域。它说明 DSU-110 能力，不等同于 Qualcomm 的完整物理布局。*

与 Haswell 类似，DSU-110 把核心和 Ring 放在不同频率域，以少量 L3 延迟换能效；每个核心或 Cluster 也有独立时钟、电源域。A710 可在 633 MHz 到 2.745 GHz 间变化，但最高 Boost 很少持续。受载后约 20 ms 从 633 MHz 跳到 2.22 GHz，随后通常能长期维持。

![图 4：Cortex-A710 的受载频率变化](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a710_wechat_article_zh/e68bfe7b39d43932_04_a710_clock_behavior.png)

*图 4：用寄存器加法延迟估算频率；约 19.21 ms 后从 0.63 GHz 升至约 2.22 GHz，瞬间尖峰和小幅跌落也提醒读者这不是直接读取 PLL。*

Android 环境无法测试 Huge Page 与 SVE，数据噪声也高于桌面操作系统。后文几处把平台写成“Snapdragon 8 Gen 1”，而开篇和设备信息明确是“8+ Gen 1”；这里保留这一页面内部命名差异，并按实际测试设备理解。

### 体系结构视角：移动核心的性能先经过 SoC 调度

手机中的同一 CPU IP 可以配不同 L1/L2、频率、电源域和 Cluster。线程迁移、DVFS 延迟、温控、DSU 频率与 L3 容量，都会改变最终性能；把 A710 核心成绩直接视为所有 A710 手机的固定属性，会混淆 IP 和 SoC 实现。

较可靠的验证应固定 CPU affinity、记录每核频率与温度，区分冷启动、20 ms Boost 过渡和稳态区间，再把 PMU 的 L2/L3 miss 与 DSU 流量对齐到同一时间窗。

## 核心总览：五宽、十级流水线与可配置 Cache

A710 是五宽、十级流水线的乱序核心。它有中等重排序能力、很大的分布式 Scheduler 和充足执行资源，像几代前的桌面核心，却以更低频率追求能效。许多结构允许 SoC 厂商配置。

![图 5：Snapdragon 8+ Gen 1 中的 Cortex-A710](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a710_wechat_article_zh/e6a561b504beaffc_05_a710_block_diagram.jpg)

*图 5：结构图汇总 1536 项 micro-op Cache、160 项 ROB、约 147 项整数与约 124×128-bit FP/Vector 物理寄存器、111/51 项 Load/Store Queue、512 KB L2 和 6 MB L3。未公开容量由微基准估计，精确性有限。*

Qualcomm 为第一颗 A710 配置 32 KB L1 与 512 KB L2。奇怪的是，第二颗 A710 似乎有 64 KB L1D，L1I 也可能是 64 KB。Arm 允许同一 SoC 中相同核心类型使用不同 Cache 容量，Qualcomm 可能在三颗 A710 内部也设置了性能层级；这是测量推断，不是公开 Floorplan。

## 分支预测：面积克制，目标供给并不保守

分支预测器在旧分支尚未执行时决定下一条取指地址。更准确可减少错误路径能耗，更快则避免 Taken 分支让 Fetch 停顿。A710 的 Pattern Recognition 已接近几代前桌面核。

![图 6：Cortex-A710 的方向模式识别](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a710_wechat_article_zh/9f2724c732a729f1_06_a710_branch_pattern.png)

*图 6：同时扫描 Pattern Length 与静态分支数。低平台代表预测器能稳定学习；台阶之后混入历史不足、容量和混叠。*

![图 7：Skylake 的方向模式识别](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a710_wechat_article_zh/d9950068918fc6cc_07_skylake_branch_pattern.jpg)

*图 7：同一类测试中的 Skylake，用来说明 A710 已达到较早桌面大核的量级；测试不是跨 ISA 的应用性能比较。*

Zen 3/4 的大预测器仍更强。Arm 必须考虑预测表本身的面积和动态功耗，容量越大，边际准确率收益越小。

![图 8：A710 与其他核心的方向预测对比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a710_wechat_article_zh/e7b8c6984f2901ec_08_branch_predictor_comparison.png)

*图 8：曲线/容量对照把移动核放回桌面核背景。预测正确率、覆盖容量和取结果延迟必须分开看。*

Taken 分支通常每 10～20 条指令出现一次，目标供给过慢就会形成前端瓶颈。A710 的一级 BTB 测得可到 2048 项，并可处理背靠背分支；但这个数字来自每 8 B 一条分支的极密布局，现实每两条指令一分支并不常见，有效容量更可能约 512～1024 个分支。

A710 还有约 10K 项二级 BTB。按分支间距不同，主 BTB 供给目标会增加约 1～3 周期。

![图 9：A710 的 BTB 容量与分支间距](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a710_wechat_article_zh/e0c8bc3ad3b541cd_09_a710_btb_capacity.png)

*图 9：多条曲线改变 Branch Spacing。密集布局可提高名义条目利用率，稀疏现实布局更早受到索引、Tag 与前端取指块组织影响。*

多目标间接分支需要在多个 Target 中选择。A710 单分支可处理约 64 个目标而不出现巨大惩罚；每分支八个目标时，总计可追踪约 4K 个。文章因此怀疑间接目标直接使用大主 BTB，而非独立目标阵列。

![图 10：A710 的间接分支目标能力](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a710_wechat_article_zh/65067fde353a17ca_10_a710_indirect_targets.png)

*图 10：两轴分别改变分支数和每分支目标数。64 个单分支目标与约 4K 总目标来自不同切片，不能相乘成一个更大物理表。*

Return 是间接分支的特例。A710 约有 14 项 Return Address Stack（RAS），深层嵌套溢出后仍保持不错性能，可能像 Skylake 一样回退到间接预测器。

### 体系结构视角：方向、目标与返回是三条相关但不同的链

方向预测回答 Taken/Not Taken，BTB 回答 Taken 后去哪，RAS 用 Call/Return 栈关系给返回地址。一级 BTB 可抢先提供快目标，二级 BTB 或复杂历史稍后覆盖；RAS 溢出时又可能借间接预测兜底。

验证时应分别改变静态分支数、分支间距、单分支目标数和调用深度，并加入无关直接分支观察共享污染。一个测试同时改变这些维度，很难区分表容量、组冲突与恢复延迟。

## Fetch、Decode 与 micro-op Cache

A710 配置 32 KB、四路组相联 L1I，采用 Virtually Indexed, Physically Tagged（VIPT，虚拟索引、物理标签）。前端可并行用虚拟地址索引 L1I，并查询 48 项全相联 iTLB；L1I hit 后，每周期最多向四宽 Decoder 送 16 B 指令。

![图 11：Cortex-A710 前端](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a710_wechat_article_zh/e144dd0e7dc31af5_11_a710_frontend.png)

*图 11：四宽 Decode 填入 micro-op Queue，也把 micro-op 写入 1536 项、四路组相联 micro-op Cache；后者每周期最多提供五条 micro-op。*

融合发生在填入 micro-op Cache 前，因此两条指令若融合成一条 micro-op，按指令数统计的有效供给可超过五。NOP 测试尤其明显，因为 A710 能把成对 NOP 融合。

A77/A78 的 micro-op Cache 可每周期提供六条，A710 主动缩到五条。继续加宽对性能的边际收益很小，而 A710 要在同工艺下提高能效，没有空间保留贡献有限的“展示性宽度”。

Arm 的 A77/A78/A710 与 Intel 的 Sandy Bridge/Haswell/Skylake 都连续三代使用 1536 项 micro-op Cache。Arm 和 Intel 分别曾宣称 A77、Sandy Bridge hitrate 为 85%/80%，文章对此持强烈怀疑。AMD 的 Op Cache 物理标记、虚拟 micro-tag，可在两个 SMT 线程间竞争共享；Arm/Intel 则虚拟寻址，Intel 会被 TLB Maintenance 刷新，文章推测 Arm 也可能如此。

![图 12：A710 的指令提取带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a710_wechat_article_zh/c1964a3880de2453_12_instruction_bandwidth.png)

*图 12：小足迹命中 micro-op Cache，融合可抬高按指令计算的 IPC；随后四宽 Decoder 维持供给。代码从 L2 执行几乎没有明显惩罚，接近 Skylake/Zen 1，直到溢出 L2 后才显著下降。*

相对 N1，A710 从 L2 取指是一大进步。进入 L3 后仍能维持可用 IPC，但通常落后 Skylake；分支预测同样会限制这种纯 NOP 带宽在真实控制流中的兑现。

## Rename：减宽，却没有放弃关键优化

Rename 把 ISA 寄存器映射到物理寄存器，使后端只为真正的 Read-after-Write 依赖等待；它还为每条指令分配 ROB 项，为 Load/Store 分配 LSU 队列。

A710 能消除寄存器间 MOV，但面对链式依赖 MOV 有时失败；近期 AMD/Intel 更稳健。它也不识别 XOR/SUB 自清零习惯，不过 AArch64 固定 32-bit 指令长度下，直接写立即数零并不比 XOR 编码更长，因此影响较小。

![图 13：A710 的重命名优化](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a710_wechat_article_zh/193e9eda1827c810_13_rename_optimizations.jpg)

*图 13：依赖 MOV 约 1.37 IPC，独立 MOV 约 3.85；立即数零 MOV 可达约 5.76，而 `eor r,r`、`sub r,r` 仍约 1 IPC。数值区分了依赖消除、端口占用与清零识别。*

A710 把 A77/A78 的六宽 Rename 缩成五宽。Rename 往往是核心最窄处并非偶然：同一周期多条指令可读写同一架构寄存器，六宽 A77 的 Register Alias Table 至少要承受 12 读、6 写，还要把本组较早指令刚分配的物理寄存器正确旁路给后续依赖者。这是高端口、紧时序结构，减宽能以很小性能代价节省面积与功耗。

### 体系结构视角：Rename 宽度的成本不只是“多一个槽位”

Rename 每增加一路，读写端口、同周期依赖旁路、空闲表分配、ROB/LSQ 多路写入和恢复 Checkpoint 都可能一起扩张。成本常近似超线性，而真实 IPC 未必能让第六路长期工作。

若 `rename_width` 经常打满且后端不阻塞，减宽可能损失吞吐；若 ROB/Scheduler/LSQ full 周期更高，第六路只是更快撞上后端。前后两类计数器必须结合，不能从峰值宽度直接判断能效优劣。

## 乱序执行：160 项 ROB 背后的大 Scheduler

乱序核心让就绪指令越过阻塞者执行，再按程序顺序退休。更深 Buffer 可以越过更长 Cache/Memory 延迟。早期低功耗核心常只有不超过 64 项 ROB，或受 Scheduler/物理寄存器限制；A76 的 128 项 ROB 是移动大核走向桌面级窗口的重要转折。

![图 14：A710、N1 与 Skylake 的乱序容量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a710_wechat_article_zh/9c8eecb8e8a22d66_14_ooo_capacity_comparison.jpg)

*图 14：A710/N1/Skylake 的 ROB 为 160/128/192，整数寄存器约 147/120/180，FP/Vector 寄存器为 124/128/168 组 128-bit，Flags 寄存器为 46/39/180，Load Queue 为 111/64/72，Store Queue 为 51/36/56，Branch Order Buffer 为 44/36/64。*

A710 大多数结构都比 A76/N1 大。FP 寄存器没有明显增长，但两条标量 FP 指令可融合，只占一个向量物理寄存器；现实程序即便使用向量，也常混入标量 FP，因此有效容量会高于裸条目数给人的印象。

### Scheduler 与执行端口

A710 采用以分布式为主的 Scheduler。任一队列满都可能阻塞 Rename，即使其他队列还有空位，因此容量配置需要仔细平衡。Arm 给多数队列配得很大，整数侧总调度容量甚至超过同样偏分布式的 Zen 2。

![图 15：A710 与 Skylake 的非访存调度结构](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a710_wechat_article_zh/77184d7b5606303d_15_scheduler_comparison.png)

*图 15：A710 多组 18～22 项整数/分支队列以及两组约 19 项 FP 队列，前面另有共享 NSQ；Skylake 使用 58 项统一 Scheduler。A710 总容量约高 50%，但不能像统一队列那样自由借位。*

浮点 Scheduler 布局在文章发布后修订：最初选错 `SCVTF` 指令形式，把多周期整数端口误当作向量端口；后续用 `FJCVTZS`、单 micro-op 的 16-bit `ADDV`，再以依赖/独立 filler 区分 Scheduler 和 Non-Scheduling Queue（NSQ）。图 5、图 15 使用修订结构，但队列深度仍是微基准重建。

Skylake 的统一 Scheduler 更不容易因单队列满而停住；A710 则以约多 50% 的总容量弥补灵活性，甚至相对自己的 ROB/寄存器规模显得“过配”。

文档示意 A710 有四条整数管线，四条都能处理常见操作、其中三条能处理 Flags；实测却无论是否写 Flags，都无法持续四次 Add 或逻辑操作/cycle。混入 MADD 后可超过三条/cycle，说明第四路更像多周期专用管线。理论上可用乘数为 1 的 MADD 补充整数加法吞吐，但多数代码三 ALU 已不易成为瓶颈。

![图 16：A710 整数寄存器到端口的数据通路假说](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a710_wechat_article_zh/3d4fb5a8ba76df4f_16_integer_port_hypothesis.png)

*图 16：三条常用 ALU 中一条兼做整数乘法，第四条 INT MADD 单独存在；连线是依据吞吐的结构印象，不是 Arm RTL。*

浮点/向量侧只有两条管线。标量 FP 可在跟踪时融合，但到执行阶段会拆开，吞吐仍最多两条/cycle。两条都能做常用 FP，延迟较低；128-bit Packed 操作与标量操作通常具有相同吞吐和延迟。

![图 17：A710、N1 与 Skylake 的 FP/Vector 吞吐](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a710_wechat_article_zh/49f841fdd9fae0bc_17_fp_vector_execution.jpg)

*图 17：FP Add 三者均 2/cycle；A710/N1 延迟约 2 周期，Skylake 约 4。FP FMA 均为 2/cycle、4 周期；128-bit INT32 Add 的 A710/N1/Skylake 吞吐为 2/2/3、延迟为 2/2/1 周期，Multiply 均为 1/cycle、延迟为 4/5/10 周期。Skylake 还可处理更宽 256-bit 向量。*

桌面/服务器核能为 256/512-bit 向量投入更多面积，移动 A710 无法承受；面对偶发向量片段，两条 128-bit 管线仍足够实用。

### 体系结构视角：分布式 Scheduler 用面积换“局部确定性”

分布式队列靠近端口，选择逻辑与连线更短、更省电；代价是资源碎片，某类操作爆发时不能借用空闲队列。统一 Scheduler 利用率更高，却需要更复杂的全局 Wakeup/Select 与更长旁路。

诊断时不仅看总项数，还要看各 Queue Occupancy、Full Stall 和对应端口利用率。某一队列满、其他队列空且前端停住，才是分布式碎片；所有队列和执行端口一起饱和，则只是负载真正用满核心。

## 地址转换：三路访存让小 DTLB 更省电

AGU 产生虚拟地址后，TLB 将其翻译为物理地址。A710 使用较小的 32 项 L1 DTLB，可能是能效选择：三次访存每周期最多需要 `3×32=96` 次 Tag 比较。A73 有 48 项 micro-TLB，却最多两次访存，同样是 `48×2=96`。比较并不能证明电路完全等价，但解释了吞吐增加为何没有伴随 L1 DTLB 扩容。

![图 18：A710 与 A73 的地址转换结构](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a710_wechat_article_zh/24e96c4785888082_18_tlb_comparison.png)

*图 18：A710 为 32 项全相联 L1 DTLB、1024 项四路 L2 TLB，A73 为 48 项 micro-TLB 与同容量 L2；L2 hit 约增加 5 周期。Skylake/Zen 4 的 L1 DTLB 分别为 64/72 项。*

A710 L2 TLB 的容量接近 Haswell，却落后 Skylake 的 1536 和 Zen 4 的 3072。多年工艺进步后，它仍与旧 A73 一样是 1024 项、四路组相联，显示 Arm 没把更多晶体管优先投入翻译覆盖。

A710 也用较窄地址节能。40-bit 物理地址只能覆盖 1 TB；手机足够，数 TB DRAM 加大量外设空间的服务器则需要 48/52 bit。这里是移动与服务器目标的明确分界。

## Store Forwarding：常见对齐快路很窄

乱序访存必须让后续 Load 看见较早 Store 的新值。若数据尚未写入 Cache，Load 要从 Store Queue Forward；简单重叠走快路，复杂情况要回退，常见做法是等 Store 退休后再从 Cache 读取。

A710 快路只能把 Store 的上半或下半精确转给依赖 Load。其他 Overlap 即使 Load 完全包含在 Store 内，也会增加 10 周期以上。

![图 19：A710 的 Store-to-Load Forwarding 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a710_wechat_article_zh/4f6e150d49a2e042_19_store_forwarding.png)

*图 19：横纵轴改变 Load/Store Offset；黄色/绿色带是少数快速覆盖关系，大片红色区域代表慢路。颜色图揭示字节对齐规则，不说明回退是在 Store Queue 内重放还是等退休。*

AMD/Intel 的快路更复杂，只要 Store 完整包含 Load 通常都能 Forward；部分重叠时周期更多，因为它们的流水线为高频设计得更深。

### 体系结构视角：Forwarding 是正确性路径，也是性能路径

Store Queue 要比较地址、判断覆盖字节、选择最年轻的匹配 Store，再拼接数据。未对齐、部分覆盖或跨 Cache line 会扩大比较与合并电路，移动核把罕见组合送入慢路能节省功耗。

验证应扫描 Load/Store 宽度和 Offset，区分完全包含、部分重叠、跨行与跨页，再观察 Replay、Store Queue Stall 和异常。只有二维延迟矩阵不足以确定内部回退状态机。

## Cache 与内存：更宽 L1D，仍受移动延迟限制

Arm 允许实现方配置 Cache。Snapdragon 8+ Gen 1 为 A710 选择较大的 512 KB L2，却保守使用 32 KB L1 和 6 MB L3；这个组合对多数 App 尚可。

![图 20：A710 的 Cache 选项与 Qualcomm 配置](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a710_wechat_article_zh/b3aded28c8a37a63_20_cache_configuration.jpg)

*图 20：L1I/L1D 可选 32/64 KB，L2 可选 256/512 KB，DSU L3 可到 16 MB；测试设备第一颗 A710 为 32 KB L1、512 KB L2、共享 6 MB L3。*

旧 Cortex-A75 的 L1D 只要 3 周期；A710 为 4 周期，接近高频桌面核，却没有对应高频。A75 频率略低，一定程度抵消了代际差距。

![图 21：A710、A75 与桌面核的 Cache/内存延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a710_wechat_article_zh/b4cb6d2fb387cbf3_21_cache_memory_latency.png)

*图 21：A710 预取器能记住 Pointer Chasing Pattern，测试不得不把周期拉长 8 倍，因此 Cache 层级边界不如普通随机链清晰。*

L1 miss 后进入 512 KB L2。它对 L1D Inclusive，Load-to-use 约 13～14 周期；A75 为 12 周期，但 A710 更高时钟让实际时间占优。L2 miss 经 CPU Bridge 到 DSU-110，可命中 L3 或进入 DRAM。

DSU-110 L3 类似 AMD Zen：对共享数据作为 Inclusive Victim Cache，对核心私有数据呈 Exclusive。Snapdragon 的 6 MB L3 约 20～21 ns、略高于 50 个核心周期。延迟与 Snapdragon 670 相近，但容量差异巨大：1 MB Last-Level Cache 明显不足，6 MB 虽不宽裕，至少接近 i5-6600K 等旧中端桌面平台，能在多类 App 中提供可用 hitrate。

LPDDR 让移动内存延迟普遍很高。A710 比 A75 好，较大 Cache 保存页表结构可能减少地址翻译代价；但同样约 6 MB L3 的 Skylake 即使发生 Page Walk，延迟仍低得多。

### 带宽

三端口 L1D 让 A710 每周期可读取三次 128-bit，即 48 B/cycle，明显高于旧移动核，却不敌为 256-bit 向量设计的桌面核。

![图 22：A710、A75、N1 与 Skylake 的 Cache/内存带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a710_wechat_article_zh/da2ebe569c2c1002_22_cache_memory_bandwidth.png)

*图 22：A710 的曲线标注约 95.98 GB/s（L1）、45.84 GB/s（L2）、32.58 GB/s（L3）和 21.64 GB/s（DRAM）；换算后 L1D 理论供给为 48 B/cycle，L2 持续约 20 B/cycle，L3 略低于 16 B/cycle。Skylake 更宽且频率更高；进入内存后，平台 LPDDR/DDR 与并发 miss 能力共同主导。*

L2 约 20 B/cycle，相对旧 Arm 是大进步，仍低于桌面常见 32 B/cycle。L2 miss 进入 Transaction Queue（TQ）；实现方可配 48、56 或 62 项，读、写和 Snoop 共享容量，并用 Watermark 防止某类请求饿死。

大 TQ 让单核 L3 接近 16 B/cycle，按周期与 Skylake 相似；Skylake 频率更高，实际 GB/s 仍领先。即使 LPDDR 延迟高，A710 单核内存带宽也不错，说明足够多并发请求可以覆盖延迟。

### 体系结构视角：容量、延迟、带宽和 MLP 要一起读

4 周期 L1D、13～14 周期 L2、20 ns 级 L3 描述单次依赖链；48/20/16 B/cycle 描述稳定流量；TQ/Load Queue 描述能挂起多少请求。低延迟不保证高带宽，高带宽也无法让指针追逐变快。

如果流式带宽高而 Pointer Chasing 慢，核心拥有 Memory-Level Parallelism（MLP）却无法缩短串行依赖；若两者都差，则要看 TQ/MSHR 是否满、预取是否迟到以及 DSU/内存控制器是否排队。

## 结语：所谓“Winning by Default”

Samsung、Qualcomm、MediaTek 自研 SoC，却都采用 Arm CPU 核。A710 在 Android 市场的处境像 2015 年前后的 Intel：主要对手是自家上一代。只要不犯错，就能继续赢。

因此 A710 比 Skylake 还保守。Arm 很少公开完整结构，已知容量相对 A77 常常不变、甚至回退；这符合“能效第一、性能第二”。竞争对手不来参赛时，最好的棋局策略不是通宵研究不存在的对手、第二天反而睡过头。

复用 A77/A78 经验让功耗与性能更容易预测，改动少也减少风险。这很无聊，却是谨慎的商业决策。

A710 本身并不差。相对 A75，它有更高核心吞吐、更强 L2 取指、更低指令延迟；融合扩大有效宽度和重排序容量，大 Scheduler 也充分利用 ROB/寄存器。可用晶体管继续增长后，文章仍希望看到更大 TLB、更强 Memory Disambiguation、更先进 Rename 优化和更低 Cache 延迟。它足以让客户在 A77/A78 与 A710 之间选择后者，这正是 Arm 当时所需。

最后的疑问是：如果 Qualcomm、Samsung 仍是有力 CPU IP 对手，A710 会不会更激进？K8 曾推动 Intel 做出 Conroe、Nehalem、Sandy Bridge；Arm 自己也曾从 A75 到 A76/N1 大幅重构而成功。2023 年时，Qualcomm 自研核心和 Ampere Siryn 都仍在传闻/研发中，文章以夸张的漫长时间笑话表达等待，也期待竞争迫使 Arm 加快脚步。结尾提供 Patreon、PayPal 与 Discord 支持渠道。

## 体系结构视角：从 A710 得到的七点认识

第一，**成熟市场会奖励可预测的改进**。没有同级 IP 竞争时，收窄 Rename、复用 1536 项 micro-op Cache，比冒险重构更符合产品目标。

第二，**能效优化常表现为删掉峰值宽度**。A77/A78 的六 micro-op 供给降到五，不代表所有性能都退步；若后端长期接不住第六条，减少端口反而更划算。

第三，**小 ROB 可以配大 Scheduler**。160 项 ROB 不算桌面顶级，但充裕的分布式队列避免单一资源过早阻塞，把有限窗口利用得更充分。

第四，**移动 SoC 的 Cache 是授权方和实现方共同决定的**。32/64 KB L1、256/512 KB L2、最多 16 MB L3 都可选，因此“同为 A710”不保证相同访存表现。

第五，**预测器不是越大越好**。A710 不及 Zen 3/4 的方向容量，却提供快速 BTB、约 10K 主 BTB 和强间接目标能力，体现对常见移动控制流的资源分配。

第六，**访存并发可救带宽，救不了串行延迟**。大 TQ 让 A710 从 L3/LPDDR 拉出不错带宽，但 20 ns L3 和 Page Walk 仍会拖慢依赖链。

第七，**测试结构比给结构命名更难**。指令形式、micro-op 拆分、端口绑定和 NSQ 都会污染容量探测；修订 FP Scheduler 的过程本身，就是微架构反推最有价值的教学案例。

## 参考资料

- Chester Lam, *ARM’s Cortex A710: Winning by Default*, Chips and Cheese, 2023-08-11：https://chipsandcheese.com/p/arms-cortex-a710-winning-by-default
- Chester Lam, *Correction for A710/Neoverse N2’s FP Scheduler Layout*, Chips and Cheese, 2023-08-20：https://chipsandcheese.com/p/correction-for-a710-neoverse-n2s-fp-scheduler-layout
- Arm, *Cortex-A710 Software Optimization Guide* 与 *DSU-110 Technical Reference Manual*
- Henry Wong, *A Superscalar Out-of-Order x86 Soft Processor for FPGA*
