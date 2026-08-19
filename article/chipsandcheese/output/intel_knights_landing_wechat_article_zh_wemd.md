---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "intel_knights_landing_wechat_article_zh"
---

> 英文标题：Knight’s Landing: Atom with AVX-512<br>
> 撰文：Chester Lam<br>
> 首发：Chips and Cheese，2022 年 12 月 8 日<br>
> 原始链接：https://chipsandcheese.com/p/knights-landing-atom-with-avx-512

Intel 的大核用大型乱序窗口和高频追求单线程；Atom 则选择不同的功耗、性能与面积平衡。Alder Lake 用大量 Gracemont 提高每面积吞吐之前，Xeon Phi 已把小核堆到更极端。

第二代 Xeon Phi，代号 Knights Landing（KNL），在 14 nm 上最多集成 72 核。实测 Xeon Phi 7210 启用 64 核，每核 4-way SMT，共 256 线程；封装内另有 16 GB MCDRAM，可作为独立地址空间或 DDR4 cache。它不是普通客户端/服务器 CPU，而是面向 HPC、试图站在 CPU 可编程性与 GPU 吞吐之间的众核处理器。

## 从 Silvermont 出发，围绕 AVX-512 重做

KNL 以 Silvermont 为基础，但 FP/vector 后端被彻底改造：`2×512-bit FMA`、vector side 全乱序；Silvermont FPU 为节能而顺序执行。重排序资源增至两倍以上，并加入 SMT4。Physical address 从 36 bit 增到 46 bit，L1D/TLB 也扩大，适配更大 HPC 内存。

![图 1：Knights Landing 与 Silvermont 核心结构对比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/1fc80921d64dd423_01_figure.png)

## 前端：小预测器靠 SMT 隐藏延迟

KNL 难以识别长分支模式，低于同期 Cortex-A72。

![图 2：分支模式长度测试](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/5bebf0649805471d_02_figure.png)

![图 3：KNL 与其他低功耗/桌面核心方向预测能力](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/9669bbaa8416a897_03_figure.jpg)

对 HPC 或许合理：分支少、单线程窗口不大，预测器省面积功耗。SMT4 一方面让四条线程争用有限 history/BTB，另一方面误预测只 flush 对应线程，浪费工作较少。

BTB 只能跟踪约 256 条 taken branch、覆盖约 4 KB code；老 P6 都有 512 项。

![图 4：KNL taken branch footprint](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/4955b63ed7be9918_04_figure.png)

单线程不能 back-to-back taken：BTB 最低 2-cycle latency，每次 taken 后 L1I fetch 空 1 周期。BTB 聚合吞吐却为 1 target/cycle；两条以上 SMT thread 可交错，达到全核每周期一 taken。

Cortex-A72 有超过 2048 项的二级 BTB，代价多 1 周期；一级更小，branchy code 很快转二级。两者单线程都不能连续 taken；A72 没 SMT 隐藏。超过 BTB 后，KNL decoder 侧 branch address calculation 约 7 周期，A72 为 9—10，Intel 管线较短。

![图 5：KNL 与 Cortex-A72 的分层 taken branch 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/558fddd2425a1cf1_05_figure.png)

Return stack 16 项，SMT 静态分区：1 thread 得 16，2 thread 各 8，3/4 thread 各 4；三线程时无法均分，部分闲置。

![图 6：不同 SMT 活动数下 RAS 深度](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/37059d45bdcddb7c_06_figure.png)

### 应用中的预测

7-Zip branch rate 高但代码 footprint 小，甚至能放进现代核心 uop cache；KNL 四线程时仍可能表现合理。

![图 7：7-Zip 随 SMT 数变化的 branch MPKI](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/c26de9343204a060_07_figure.png)

单线程下它好于 Phytium，说明有限资源调得不错，但不敌桌面大预测器。

![图 8：单线程预测器跨架构对比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/40fd444b690b68de_08_figure.png)

libx264 branch rate 更低、代码 footprint 更大，增加 SMT thread 后预测准确率却剧跌。

![图 9：libx264 随 SMT 数变化的 branch MPKI](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/32fddb40fc246c9d_09_figure.png)

Intel BAClear 表示预测单元没提供正确目标，decoder 重新算 target 并轻度 flush，可近似观察 BTB miss。

![图 10：7-Zip/libx264 的 BAClear；libx264 随 SMT thread 激增](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/bfc863c1948eae94_10_figure.png)

POWER9 名义 SMT8，更适合理解为两个资源丰富的 SMT4 group，四线程下预测没有崩坏。

![图 11：POWER9 与 KNL 四线程 branch prediction](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/05ef8d5e7634a44a_11_figure.png)

KNL 的 SMT4 仍带来性能收益，但计数器揭示小预测器在四 footprint 下的压力。

### 体系结构视角：SMT 能隐藏预测延迟，也会放大容量争用

目标 lookup 两周期时，前端可轮到另一线程取指，改善利用率；但 direction history、BTB、RAS 都被更多 PC/路径污染。最优线程数取决于 footprint 与后端瓶颈。验证必须同时看 aggregate IPC、per-thread MPKI、BAClear、L1I miss 和 thread fairness，不能只看总吞吐。

## Fetch/Decode：2-wide，L2 取代码很慢

32 KB、8-way L1I 通常足够喂 2-wide core；一旦代码落到 L2，像 Bobcat 等低功耗核一样慢。

![图 12：不同代码 footprint 的取指吞吐；KNL flat DDR4，MCDRAM 结果类似](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/79f49c531b621344_12_figure.png)

四线程也不能提高每核 L2 code bandwidth，4-byte 指令仍低于 1 IPC，提示 instruction-side MLP 很低。

![图 13：不同指令长度下的 L2 取指 IPC](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/edc889b9ed592142_13_figure.png)

![图 14：KNL、Bobcat、Cortex-A72 与大核的大 footprint 对比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/4915c10ec241ffb5_14_figure.png)

HPC loop 通常小，问题不大；客户端应用代码大，多线程进一步削弱 locality。

![图 15：SMT 对实际前端供给的改善](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/be48ffc3f30c9a8e_15_figure.png)

SMT 仍能在一线程 BTB/L1I stall 时切到另一线程，提高平均供给，但没有增加底层取指端口本身的带宽。

Renamer 很原始：zero idiom 都不能断依赖，清零用较长编码的 move immediate 反而更好；也没有 move elimination。

## 乱序容量：72-entry ROB 为四线程精确切分

KNL 延续 Silvermont 布局并扩大。ROB 保存 speculative register file（Intel 称 rename buffer）指针，退休时复制到独立 RRF，行为像 P6 ROB+RRF：各寄存器类型的 rename capacity 足以覆盖整个 ROB。

![图 16：KNL 的 ROB、整数/向量/mask rename 等容量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/fe6f891dd2c96598_16_figure.jpg)

Mask 实测约 69 个可用 rename，容量测试本身两条 pointer-chasing load 占 2 个 ROB slot，基本覆盖 72。单线程资源约在 Athlon/Jaguar 水平；即使 AVX-512，也不太会每条指令都写 ZMM，因此单线程略显过量。

SMT 采用静态分区：两线程各半；三或四线程都各四分之一，没有三等分模式。

![图 17：其他 SMT thread 运行 spinloop 时的结构容量；三与四线程相同](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/784f56d0f8f72ca4_17_figure.png)

SMT4 每线程只有约 18 ROB，所有 rename 类型覆盖这 18 项反而必要。Store queue 更紧，每线程仅 4 项。

![图 18：随 SMT 数变化的 load/store queue 可用容量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/daf6d612dfed838e_18_figure.png)

Pentium II/III 40-entry ROB 配 12 store buffer，最多 30% in-flight instruction 可为 store；KNL 四线程仅 4/18≈22%。小窗口中更容易由 store 先形成反压。

### Integer 与 AVX-512 执行

两条 ALU pipe 匹配 2-wide，均支持 add/MOV；shift/rotate 只有一条。64-bit multiply 单 pipe、半速率、5-cycle latency。两组 integer scheduler 各 12 项，比 Silvermont 各 8 项多 50%，并在 queue 中保存 operand。

AVX-512 占核心近 40% 面积。Vector scheduler 不保存 512-bit operand，避免阵列爆炸。

![图 19：裸片上的 AVX-512 执行区，标注为推测](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/cd3cb183a14ec6f5_19_figure.jpg)

每周期 FMA 吞吐可匹敌 Skylake-X，也能两条 512-bit integer add；延迟更长。

![图 20：KNL 与 Skylake-X 向量吞吐/延迟；KNL 对较窄向量也近似](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/1442013a971513e7_20_figure.jpg)

KNL 1.3 GHz 下 FMA 6 cycle，Skylake-X 4；vector integer 2 cycle，Skylake-X 1。低功耗核常用更长流水线，A72 FMA 7、vector integer add 3。裸片 SRAM 不均匀，可能分为约 72-entry、4.6 KB speculative vector file 和能保存四线程非投机状态的 8 KB architectural file；这是布局推测。

### 体系结构视角：KNL 像“小乱序核心包着大向量机”

峰值 FLOPS 来自两条 512-bit FMA，而 dependency latency、2-wide decode 与每线程 18 ROB 决定单线程能否喂满。编译器需展开循环、准备多条独立 accumulator，并用多线程隐藏 6-cycle FMA 与内存延迟。若算法依赖链长或分支多，向量单元面积再大也会空闲。

## LSU：两 AGU、高带宽，但依赖检查粗糙

Memory scheduler 12 项，Silvermont 仅 6；两 AGU 支持每周期两 memory op，可为两 load，最多一 store。

精确地址 store forwarding 为 6—7 周期。依赖比较以 4 B 粒度；同一 4 B aligned region 即使不重叠也走 16-cycle 慢路径。Sandy Bridge—Skylake 同样先按 4 B 检查，却会后续澄清，避免如此重罚。

![图 21：Henry Wong 方法测得的 KNL store-to-load forwarding](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/f1c6a3fa65a0eabf_21_figure.png)

Load 跨 64 B line 时快速 forwarding 失败，约 20 周期；普通跨 line load 2 周期、store 4；跨 4 KB page 无论 load/store 都多 14—15。Vector forwarding 成功也要 9—10 周期。

## 片上 Cache、TLB 与两种 DRAM

L1D 32 KB、4 周期，大于 Silvermont 24 KB；每 tile 两核共享 1 MB L2、17 周期。A72/Graviton 四核共享更大 L2，约 21 周期。

![图 22：KNL L1D/L2 延迟与容量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/6e9906a3d9b07426_22_figure.png)

没有片上 L3，每核平均只有 512 KB on-die cache。L2 miss 经 mesh 到负责该 cacheline 的 tile，地址 hash 类似 Skylake-X；该 tile 只有 directory，决定去其他 tile 取数据还是访问 DRAM。

![图 23：开盖 KNL 封装内的 MCDRAM die](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/acbbdfea184998f5_23_figure.jpg)

MCDRAM 类似 HBM，利用短走线和高 wire density 提供高带宽，但不需 interposer。Flat mode 映射为独立高地址内存；cache mode 则做 64 B line、direct-mapped（1-way）DDR4 cache。

![图 24：IEEE 论文中的 MCDRAM cache 实现](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/05f226874d398393_24_figure.jpg)

DRAM tag 本身慢，复杂高相联查找不划算，direct mapping 简化 controller。Flat MCDRAM 约 176 ns，DDR4 147 ns；quadrant+SNC4 让目录与 controller 本地化后 MCDRAM 约 170 ns。Core 1.3 GHz、mesh 1.6 GHz，mesh 不是主要延迟来源。

![图 25：Flat、Cache 与 DDR4 的 load-to-use latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/848ee242f79186a0_25_figure.png)

Cache mode 比 flat MCDRAM 多 3—4 ns，相当于 mesh 约 6 cycle 的 tag/status 检查；cache miss 后去 DDR4 超过 270 ns。

TLB 进一步增加长尾：L2 TLB 对 2 MB page 仅 128 项，随机 footprint 超 256 MB 就 miss；一级 uTLB 64 项且只支持 4 KB，即便使用 2 MB page，也会在一级按 4 KB chunk 处理，超过 256 KB 后延迟上升。uTLB miss、L2 TLB hit 多 6 cycle，L2 TLB miss 多 20 以上。

![图 26：页面大小与 TLB reach 造成的延迟台阶](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/90a223a2edd502c8_26_figure.png)

客户端常用 4 KB 会更受伤；HPC 更重吞吐且可显式使用大页。

### 体系结构视角：大页不能自动绕过所有 TLB 层级

不同 TLB level 支持的 page size 可能不同。KNL 的 2 MB page 扩大 L2 TLB reach，却仍受只认 4 KB 的 uTLB 容量影响。验证应分 4 KB/2 MB、随机/顺序、冷热 page walk，报告 reach 而不仅是 entry 数；`128 × 2 MB=256 MB` 只描述对应层级覆盖。

## 带宽：350 GB/s 才是 KNL 的主场

L1D 每周期两 memory op，可两 load、最多一 store。读测试没完全达到，指令吞吐测试却确认 `2×512-bit load/cycle`；1:1 read/write、数组每项加常量可超过 64 B/cycle。

![图 27：单 tile L1/L2/DRAM 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/f968d3f334010d03_27_figure.png)

L2 理论 64 B/cycle；单核略低，双核接近。单核加载全部 SMT thread，DRAM 约 13 GB/s；同 tile 第二核提升不大。

![图 28：全芯片 DDR4、MCDRAM flat/cache 的带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/ad90b6aedb3ab4df_28_figure.png)

Cache-mode 这次关闭 SMT 却启动 256 软件线程，OS time slice 粒度远粗于 SMT，使 cache spill 点错位；带宽上限仍几乎不受 cache mode 影响。

Dmidecode 报 8 个 6400 MT/s、每个 2 GB、64-bit（含 ECC 72-bit）MCDRAM，理论 409.6 GB/s；读测试约 350 GB/s，即 85.6% 效率。它高于同期 GTX 980 Ti 384-bit GDDR5 理论带宽，同时容量 16 GB。另有 96 GB DDR4、超过 78 GB/s；GPU 若访问同等 host memory 通常受 PCIe 限制，连 PCIe 4.0 x16 都达不到。

### Hybrid、Quadrant 与 SNC4

Hybrid 一半 MCDRAM flat、一半 cache；测试再启 quadrant+SNC4，分成四个 locality domain。NUMA node 0—3 是各 quadrant CPU+DDR4，并各有 2 GB MCDRAM cache；node 4—7 是各自 2 GB flat MCDRAM（其余 2 GB 做 cache）。

![图 29：Hybrid+SNC4 各 NUMA node 的容量/带宽曲线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/31842e9d495eed81_29_figure.png)

Cache 容量分片后更早跌落。单 node 的 MCDRAM cache 反而略高于 flat；512 MB 时 `88.98×4=355.92 GB/s`，只略高于 flat 全通道 350，说明 mesh 已能承载巨大带宽，quadrant 分区收益不大。

![图 30：本地与远端 MCDRAM 的延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/3e9d891dd8c62fb4_30_figure.png)

Local controller 从约 179 降至 170 ns，仍比 DDR4 慢，证明 MCDRAM 优先带宽而非延迟。

![图 31：SNC4 中本地/远端 DDR4 与 MCDRAM；结果不同于典型 NUMA](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/7c3dcb1020e1ed7e_31_figure.png)

Flat+quadrant+SNC4 的本地 DDR4 最低约 143 ns。Remote node 带宽几乎接近 local，延迟罚也轻；单片 die 的密集 mesh 让 NUMA 特征温和。

![图 32：随启用核心数增加的 DDR4/MCDRAM 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/5cf4fb7954856a75_32_figure.png)

多数 CPU 几核就吃满 DRAM；KNL 核弱而内存极宽，几乎要全核才饱和 MCDRAM，DDR4 约 10 核即可饱和。

## Mesh 与核间延迟

每 tile 两核、一个 mesh stop，分布式 directory 维护一致性。Contested lock 测试中，同核 SMT 约 23 ns，同 tile 两核约 41 ns；跨 tile 80—100 ns，取决于距离和 cacheline home tile。

![图 33：全芯片 core-to-core latency 矩阵；Linux 编号转换为 Windows 习惯](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/cda4b84f3ffc284b_33_figure.png)

![图 34：quadrant+SNC4 的核间矩阵](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/3d7fdc055c9710ea_34_figure.png)

SNC4 把 directory lookup 局部化，但核间延迟变化小。跨 NUMA MCDRAM 约 86 vs local 90 GB/s；DDR4 19.1 vs 20.8，NUMA-aware 程序略有收益，普通程序也不会遭受严重 remote penalty。

## SMT4：能隐藏延迟，也能让 Cache 更糟

KNL 72-entry ROB、各类 rename 全覆盖、branch 无额外独立限制，所以容量比数字更耐用；SMT4 每线程 18 项仍可用。高 FP latency、taken branch 气泡、17-cycle L2、无 L3，都为交错线程留下空间。

![图 35：7-Zip/libx264 等应用随 SMT thread 数的绝对性能](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/cca64f6867dac162_35_figure.png)

![图 36：相对每核单线程的 SMT scaling](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/c6f840e7668a4f67_36_figure.png)

只要不受带宽限制，SMT4 增益可观。

![图 37：随 SMT 增加的每指令 offcore response](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/0a484de36b268be1_37_figure.png)

更多 thread 也会挤 L1/L2，使 DDR4/MCDRAM 请求每指令增加。Bandwidth bound 时 SMT 可负 scaling。

![图 38：旧版 Y-Cruncher 在 DDR4/MCDRAM 和不同线程数下的性能](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/810ff8ca59ee2c60_38_figure.png)

使用旧版是因为新版不支持 KNL AVX-512。DDR4 下超过物理核数后因 cache thrash 和带宽瓶颈变慢；MCDRAM 则让 256 线程 KNL 大幅超过 Zen 2 Ryzen 3950X。3950X 已完全受内存限制，开 boost 只让 IPC 同比下降，性能不增。MCDRAM 对 libx264/7-Zip 无帮助，7-Zip 甚至因更高延迟略慢。

### 体系结构视角：SMT 只填执行空洞，不创造 Cache 或内存带宽

线程交错能覆盖依赖链、BTB 和 cache latency；一旦 MSHR、L2 或 DRAM 已饱和，更多线程只增加 working set 与争用。可用 per-thread IPC、offcore response/instruction、cache MPKI 与带宽利用率识别转折点，而不是机械地总开 SMT4。

## 物理实现与升频

656 mm² 大 die 上，大量面积用于 cache、mesh interface 和全芯片总线。每 tile 的 mesh stop+共享 L2 约 3.58 mm²。

![图 39：Fritzchens Fritz 的 KNL 裸片](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/49fa4edea84010ef_39_figure.jpg)

每核心约 2.93 mm²，显著小于同 14 nm Skylake；vector execution 约 1.14 mm²、占 39%；L1D 为吞吐牺牲密度，占核心略超 10%。

![图 40：KNL tile/core 推测标注](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/2bf9baa3e8bc4554_40_figure.jpg)

![图 41：C2000 Silvermont 裸片](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/a166e81d9bb05804_41_figure.jpg)

两者 floorplan 完全不同，却有微架构继承；反过来 Sandy Bridge 与 Nehalem floorplan 相似，核心结构却重做。因此裸片外形不能当架构亲缘证据。Silvermont module 的 L2/offcore logic 更小，用 Nehalem 式 crossbar，只支撑 25.6 GB/s memory traffic；KNL mesh 超过 300 GB/s，需要深队列和更大接口。

Xeon Phi 7210 idle 约 1 GHz，实测常用 1.3 GHz。Intel slide 称单 tile 可 1.5、全 tile 1.4，但测试没超过 1.3，主板 firmware 可能禁用 turbo。

![图 42：从 idle 到 1.3 GHz 的升频轨迹](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_knights_landing_wechat_article_zh/9408b11d8833240d_42_figure.png)

约 80 ms 后才以 100 MHz step 上升，近 90 ms 到 1.3 GHz，比 OS P-state 桌面 CPU 稍慢；但 idle 已接近工作频率，HPC 不重视瞬时响应。

## 结语

Xeon Phi 源自 Larrabee：早期用 P54C 2-wide in-order Pentium 核加 512-bit vector 与 SMT4，Knight’s Ferry 32 核、ring、GDDR3，仍有 display/texture；22 nm Knight’s Corner 62 核并转 HPC；2016 KNL 最多 72（完整 die 文中后段亦提 76 个物理核心，实测 SKU 64 启用）、去掉 texture、改 mesh，并换成现代乱序 Silvermont 基础。材料对最大核心数存在 72/76 两种表述，应并列保留，可能对应产品/物理 die 口径。

它不像 GPU 那样依靠大量顺序线程完全隐藏延迟：每核仍有分支预测、小乱序与较低访问延迟，编程更自然；96 GB DDR4 加 16 GB MCDRAM 也避免所有数据都经 PCIe。代价是单线程极弱、前端和 TLB 小、MCDRAM 延迟高。

Stampede2 等超级计算机证明其 HPC 价值。Y-Cruncher 展示高核心数、SMT4、AVX-512 与 350 GB/s MCDRAM 可以击败新很多的桌面 CPU；libx264、7-Zip 又展示 256 弱线程若无法扩展就毫无意义。KNL 是 CPU 与 GPU 中间路线一次极具辨识度的实现。
