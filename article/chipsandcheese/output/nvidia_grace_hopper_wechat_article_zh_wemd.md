---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "nvidia_grace_hopper_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*Grace Hopper, Nvidia’s Halfway APU*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2024 年 7 月 31 日
> - 链接：https://chipsandcheese.com/p/grace-hopper-nvidias-halfway-apu

高性能 GPU 市场由 Nvidia 与 AMD 主导，AMD 的额外优势是能把 CPU、GPU 和 Infinity Fabric 一起卖进 Console 与 Supercomputer。Oak Ridge National Laboratory 的 Frontier 就让 MI250X 通过 Infinity Fabric 连接定制 EPYC。

Nvidia 同样拥有 NVLink，也早在 Tegra X1 中把 CPU/GPU 放入移动 SoC。Grace Hopper GH200 则把这条路线推到高性能领域：CPU 侧提供服务器级 Core Count 与 Memory Bandwidth，旁边直接放置顶级 H100 Datacenter GPU。

![图 1：Grace Hopper GH200](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_grace_hopper_wechat_article_zh/6f714a05228841a7_01_gh200_render.jpg)

*图 1：Nvidia 渲染图中，Grace CPU 位于左侧，Hopper GPU 位于右侧。网页正式图注保留了来源。两颗 Die 封装成一个模块，却拥有各自独立 Memory Pool。*

测试对象托管于 Hydra。GH200 有多种版本，这台机器的 CPU 侧配 480 GB LPDDR5X，GPU 侧配 96 GB HBM3。Neoverse V2 Core Architecture 已在 Graviton 4 文章中分析过，因此这里聚焦 Nvidia 的实现、Uncore 和 CPU/GPU 连接。

网页没有完整披露系统软件镜像、Compiler/Flags、功耗模式、NUMA Policy、并发统计和误差。Cloud Instance 还出现驱动错误、测试 Hang 和整机失去响应；因此异常现象必须保留，Benchmark 也只代表这台 GH200 与当时软件栈。

## 系统架构：72 核 Grace 加一颗 H100

Grace CPU 包含 72 颗 Neoverse V2，最高 3.44 GHz，配 114 MB L3。Core 与 L3 Slice 挂在 Nvidia Scalable Coherency Fabric（SCF）Mesh 上；SCF 负责 Cache Coherency 与 Memory Ordering。

![图 2：Grace CPU 的 SCF Mesh](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_grace_hopper_wechat_article_zh/a54a36431f433ad9_02_scf_mesh.jpg)

*图 2：Nvidia 官方图显示 Core、Distributed L3 Slice、Memory Controller 和 I/O 接入 Mesh Stop。网页正式图注给出 Nvidia Grace CPU Superchip Architecture 资料链接。*

![图 3：Grace CPU 的 Core-to-core Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_grace_hopper_wechat_article_zh/42b80c260f4bf28d_03_core_to_core_latency.png)

*图 3：72 核矩阵整体较均匀，说明 SCF 在大 Mesh 上提供了相对一致的一致性路径；量级接近使用 Arm CMN-700 的 Graviton 4。网页正式图注说明这是 Grace CPU 实测。*

CPU 内存为 480-bit LPDDR5X-6400：480 GB Capacity、理论 384 GB/s。Graviton 4 选择 768-bit DDR5-5200，理论 500 GB/s、容量 768 GB。Nvidia 可能看中 LPDDR5X 的能效，因为 DRAM Power 会占 Server Power Budget 的显著部分。

H100 拥有独立 96 GB HBM3，理论 4 TB/s。CPU 重视 Latency 和 Capacity，GPU 更重 Bandwidth、相对不敏感于 Latency；一套内存同时做到三者会极其昂贵，因此 GH200 没有采用传统 Unified-memory iGPU。

![图 4：Kaby Lake-G 的双内存池思路](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_grace_hopper_wechat_article_zh/6c284676d9201bc4_04_kaby_lake_g.png)

*图 4：Intel Hot Chips Slide 展示 Kaby Lake CPU、Radeon RX Vega M 与 4 GB HBM2 封装。普通 DDR4 服务 CPU，HBM2 服务 GPU；GH200 在概念上相似，只是规模大得多。网页正式图注说明来源。*

## NVLink C2C：900 GB/s、硬件一致性与高延迟

Compute Workload 可能频繁在 CPU/GPU 间交换数据，所以 Nvidia 用 NVLink Chip-to-chip（C2C）连接两颗 Die。总双向带宽 900 GB/s，也就是每方向 450 GB/s，约比 PCIe 5.0 x16 高一个数量级。

![图 5：Grace、Hopper 与 NVLink C2C](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_grace_hopper_wechat_article_zh/bf1ac0c020123284_05_grace_hopper_architecture.png)

*图 5：CPU LPDDR5X 与 GPU HBM3 各自独立，NVLink C2C 在两颗 Die 间提供高速、Cache-coherent 连接。图片来自 Nvidia Grace Hopper Architecture 资料。*

NVLink C2C 支持 Hardware Coherency。CPU 无需先显式复制到 LPDDR5X，就能直接访问 HBM3；硬件还负责 Memory Ordering，不要求软件为每次访问插入特殊 Barrier。Nvidia 甚至把 HBM3 直接暴露为 CPU 可见 NUMA Node。

![图 6：CPU 访问本地 LPDDR 与远端 HBM 的带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_grace_hopper_wechat_article_zh/bd5f7c1b2c18a571_06_cpu_remote_memory_bandwidth.png)

*图 6：远端测试使用标准 Linux Interface 分配 CPU-owned Memory，全部传输由 CPU Core 发起，没有使用 CUDA Copy Engine 等加速。HBM Remote Bandwidth 接近双路 Zen 4 Server，显著高于两颗 Graviton 4 间的结果；本地 LPDDR5X 则接近 DDR5-4800 的 Bergamo。网页正式图注明确了这一口径。*

带宽表现不错，却远低于 450 GB/s 理论单向值；更大的问题是 Latency。即使用 2 MB Page 减少 Translation Penalty，CPU 访问 HBM3 仍接近 800 ns，比直接访问 LPDDR5X 多 592 ns，而本地 LPDDR5X 本身也不算低延迟。

![图 7：Grace CPU 的本地与远端内存延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_grace_hopper_wechat_article_zh/1ddad4254bb36954_07_cpu_memory_latency.png)

*图 7：本地 LPDDR5X 已超过 200 ns，NVLink C2C 后的 HBM3 接近 800 ns。H100 GPU 侧直接测到 HBM3 约 300 ns，说明 HBM 并非全部原因，C2C/一致性/CPU 路径贡献很大。*

这条链路的 Latency 明显高于 AMD Infinity Fabric、Graviton 4 使用的连接以及 Intel QPI。但若换成“离散 GPU Uplink”视角，结果会温和许多。Nemes 的 Vulkan Test 用 `vkMapMemory` 把 VRAM 映射到进程地址空间，再以 Pointer Chasing 测量。

![图 8：不同离散 GPU 的 CPU→VRAM 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_grace_hopper_wechat_article_zh/2e21b195f7ed2397_08_vulkan_uplink_latency.png)

*图 8：NVLink C2C 的位置介于 Radeon RX 5700 XT 与 HD 7950 等离散配置之间，作为 GPU Link 相当合理；但 CPU Code 若把 HBM3 当普通 NUMA Memory，必须显式考虑接近 800 ns 的代价。*

更严重的负面结果是，普通 HBM Latency Test 期间系统失去响应：`vi` 启动要数秒，SSH 不再响应按键，新连接可能完成 TCP Handshake 却始终没有 Shell，最终只能通过 Cloud Provider 重启恢复。这不是一个理想行为，也不能从单次现象确定是 Hardware、Driver、Kernel 还是 Provider 配置。

### 体系结构视角：可寻址、可一致，并不等于可当成本地内存

把 HBM 暴露为 NUMA Node 极大简化编程模型，Memory Access 却仍跨越 CPU Mesh、C2C Coherency、GPU Fabric 与 HBM Controller。带宽可以用大量 Outstanding Request 填满，Pointer Chain 只有一个依赖请求，近 800 ns 会完整暴露。

软件应把 HBM 当高带宽远端 Tier：批量访问、预取、异步搬运，避免 Fine-grained Dependent Load。验证要区分 CPU Load/Store、DMA Copy Engine、CUDA Managed Memory 与 Vulkan Mapping；它们使用的 Engine、Address Translation 和 Coherency Path 并不相同。

## Grace 的 Neoverse V2 实现：高频、大 L3、小 L2

同一 Core Architecture 可以因平台而表现不同。Grace 面向 Parallel Compute，选择 72 核、更高 Clock 和 114 MB Shared L3；Boost Policy 也更灵活，让不易并行的代码在 Power/Thermal 允许时获得单线程性能。

Graviton 4 面向多租户 Cloud，选择更多核心和每核更大 L2，减少 Noisy Neighbor；低频降低随 Workload 变化的 Power Throttling，也能在一台 Server 塞入更多小实例。

![图 9：Grace 与 Graviton 4 的 Neoverse V2 实现](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_grace_hopper_wechat_article_zh/dc013198b4adad75_09_neoverse_v2_implementations.jpg)

*图 9：图表并列 Core Count、Clock、L2/L3 与 Memory。两者核心到 L2 的周期行为相同，差异主要从每核 Cache 配置、Mesh、Memory Controller 与产品目标开始。*

### 延迟

L1/L2 以周期计完全相同，因为它们属于 Neoverse V2 核心设计。到 L3 后差距突然扩大：大 Mesh 与大 Cache 都会增加 Hit Latency，Grace 的 L3 Load-to-use 超过 125 周期。面对这么昂贵的 L2 Miss，文章更希望看到 2 MB L2；Graviton 4 与 Sapphire Rapids 都用 2 MB 缓冲高 L3 Latency。Zen 4 虽只有 1 MB L2，其 L3 Miss Cost 小得多。

![图 10：Grace、Graviton 4 的 Cache/Memory 周期](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_grace_hopper_wechat_article_zh/e76ff84f83db41a7_10_cache_latency_cycles.png)

*图 10：两条曲线到 L2 基本重合，Grace 离开 1 MB L2 后进入超过 125-cycle L3；Graviton 4 的 2 MB L2 延后了这一转折。*

高频让 Grace 的 L1/L2 Hit Time 优于 Graviton 4，但 L3 仍超过 38 ns。Sapphire Rapids 同样通过大 Mesh 访问大 L3，也略快一些，约 33 ns。

![图 11：按纳秒比较 Cache/Memory 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_grace_hopper_wechat_article_zh/e473a8c7b219668f_11_cache_latency_time.png)

*图 11：Grace 本地 LPDDR5X 超过 200 ns，Graviton 4 DDR5 为 114.08 ns，更接近其他 Server CPU。高频只能缩短 Core-clock Domain，无法消除 Mesh 与 DRAM 的绝对时间。*

### 体系结构视角：L2 是核心与 Mesh 之间的减压阀

当 L3 超过 125 cycle，1 MB L2 的每一次 Capacity Miss 都把请求送入大 Mesh。扩大 L2 不只降低单线程 Latency，也减少 Fabric Traffic 与多核干扰；成本是每核 SRAM 面积和 Leakage。

应按 Working Set 分离 L2 Hit、L3 Hit 和 DRAM，并联看 L2 MPKI、Mesh Queue 与 `STALL_BACKEND_MEM`。若 L3 Hit 很慢但 MPKI 极低，影响有限；小 L2 让慢路频繁出现时，才会转化为 IPC 损失。

## 带宽：Grace 的强项是全芯片 L3

更高频让单颗 Grace Core 的 Cache Bandwidth 明显高于 Graviton 4；但 AMD Zen 4 对 Vectorized Workload 做了更强优化，即使都从大 L3 取数，单核可用带宽仍更高。

![图 12：单核 Cache/Memory 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_grace_hopper_wechat_article_zh/1bb28af836fae16b_12_single_core_bandwidth.png)

*图 12：Grace 单核 L1/L2/L3 高于 Graviton 4 的对应 V2，Zen 4 在 Cache Bandwidth 上仍占优。测试采用 Prefetch-friendly Linear Pattern，不能代表随机访问。*

Grace 单核从 L3 得到的带宽更高，可能来自激进 L2 Prefetcher，它可在乱序窗口达到极限后继续制造大量 Outstanding Request。Prefetch 仍无法克服 LPDDR5X Latency：Grace 单核 DRAM 约 21 GB/s，Graviton 4 约 28 GB/s。

![图 13：全核 L1/L2 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_grace_hopper_wechat_article_zh/2cf6d711df800378_13_all_core_private_cache_bandwidth.png)

*图 13：Grace 72 核合计约 10.7 TB/s L1、约 5 TB/s L2；Graviton 4 以更多核心弥补低频，合计更高。Genoa-X 同时拥有高每周期带宽、较高频率和 96 核。*

常规测试为避免多个核心请求同一 Cache Line 被合并，会给每线程分割 Array；Grace/Graviton 4 的 L2 相对 L3 很大，导致 L3 区间不易显现。改为 Shared Array 虽会高估 DRAM，却有助于估算 L3 Aggregate Bandwidth。

![图 14：共享数组下的全芯片 L3 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_grace_hopper_wechat_article_zh/a87665f59d9fb573_14_shared_array_l3_bandwidth.png)

*图 14：Grace L3 超过 2 TB/s，显著高于 Graviton 4 约 750 GB/s，符合 Bandwidth-hungry Parallel Compute 定位。Genoa-X 仍更强：每八核一份 L3，数据更近、扩展更好；代价是总 LLC 超过 1 GB，而单核只能分配到其中 96 MB。*

### 体系结构视角：统一大 Cache 优化共享，分片近端 Cache 优化局部性

Grace 的 114 MB Unified L3 便于同一进程跨核共享数据，2 TB/s Aggregate Bandwidth 也很可观；每次访问却可能跨多跳 Mesh。Genoa-X 把 L3 绑定八核 Cluster，Latency 和扩展更好，但远端容量不能被单核自然当作一池使用。

选择取决于 Data Placement。Cache Blocking 若让工作块留在 Grace L3，能受益于大共享池；若线程大多访问私有数据，靠近核心的分布式 Cache 更高效。

## 轻量 Benchmark：高频没有换来普适领先

测试只简要覆盖 libx264 与 7-Zip。libx264 使用大量 Vector Instruction、带宽需求高，并锁定相同 Core Count，理论上适合 Grace；结果却没有胜过低频 Graviton 4。

![图 15：Grace 与 Graviton 4 的 libx264](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_grace_hopper_wechat_article_zh/3d5e1ef86277bc97_15_libx264_performance.png)

*图 15：同 Core Count 下，Grace 未凭高 Clock 取得领先。网页没有完整给出 libx264 Version、Command Line、Input 和统计，结果用于后续 PMU 诊断。*

7-Zip 只使用 Scalar Integer，表现同样不好，而且反复运行仍出现一个可疑差异。

![图 16：Grace 与 Graviton 4 的 7-Zip](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_grace_hopper_wechat_article_zh/da32326b9b9f84b3_16_7zip_performance.png)

*图 16：两边使用相同 Command-line Parameter，但 GH200 为完成同一压缩执行 2.58 万亿条指令，Graviton 4 只有 1.86 万亿；libx264 两边都约 19.8 万亿。因此 7-Zip 结果存在软件/路径差异，不能用来归因纯硬件性能。*

Neoverse V2 的 `STALL_BACKEND_MEM` 统计：因 Core-clock Domain 内 Last-level Cache Miss，后端 Stall 导致前端无法向后端 Dispatch 的周期。Core-clock Domain 的 LLC 是 L2，所以它近似表示 L3/DRAM Latency 超出乱序窗口吸收能力、最终在 Rename/Dispatch 处丢失的吞吐。

![图 17：libx264 的 Memory Backend Stall](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_grace_hopper_wechat_article_zh/22f2dfdd8bfa70b4_17_libx264_backend_stalls.png)

*图 17：Grace 的 Memory Stall 大幅增加，1 MB L2、慢 L3 与慢 DRAM 的组合并不理想。总 Rename Lost Throughput 只增加几个百分点，说明 V2 大后端确实吸收了大量额外延迟，却仍不足以保住高频优势。*

![图 18：7-Zip 的 Memory Backend Stall](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_grace_hopper_wechat_article_zh/50e4ec68a3552eae_18_7zip_backend_stalls.png)

*图 18：7-Zip 计数差距没那么大，Grace 仍承受更多 L2 Miss Latency；其主要成绩异常来自同一工作执行了更多 Instruction，而非这些 Stall 单独解释。*

7-Zip/libx264 没受益，不代表 Grace 没有合适负载。114 MB L3 很适合 Cache Blocking，高 Clock 可加速串行区段，激进 Prefetch 也能帮助规则吞吐程序。哪些应用真正受益，需要有针对性的优化和更完整测试，超出这次简测。

### 体系结构视角：Benchmark 先核动态指令，再谈 IPC

同一命令执行 2.58 与 1.86 万亿 Instruction，说明 Binary、Library、Input Path、Runtime Dispatch 或算法行为至少有一项不同。此时 Runtime 差异不能直接映射到 Core IPC。

可靠对照应固定 Binary/ISA Target、Library、Thread Count、Input 与 NUMA Placement，并同时报告 Instruction、Cycle、Frequency、L2 MPKI 和 Stall。只有动态工作量相近，才能继续讨论微架构效率。

## H100 On-package GPU：更强的版本，也有不成熟之处

GH200 GPU 类似 H100 SXM：Die 上 144 个 Streaming Multiprocessor（SM），启用 132 个；96 GB VRAM 高于单独 H100 的 80 GB，说明 12 组 HBM Controller 全开。每组 512-bit，总 Bus Width 为 6144 bit。软件仍把它暴露为普通 PCIe Device，即使物理连接是更快的 NVLink C2C。

`nvidia-smi` 显示 GH200 整体 Power Limit 为 900 W。H100 SXM 为 700 W，H100 PCIe 为 350～400 W；CPU/GPU 共享 900 W，但 CPU 轻载时 GPU 可能比独立版本有更大功耗空间。

![图 19：GH200 H100 的 Cache/VRAM 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_grace_hopper_wechat_article_zh/73e4403804135d6b_19_h100_memory_latency.png)

*图 19：相较 H100 PCIe，GH200 GPU Clock 更高，片上 Cache Latency 更低；VRAM 从约 330 ns 降到 300 ns 以下。无法分离较高 Clock 降低 NoC 时间与 HBM3 本身改进各自贡献。*

H100 的 L1 很大、L2 中等，不像 RDNA 2、CDNA 3 或 Ada Lovelace 那样配巨大 LLC，也不至于像旧 Ampere 那样很小。

![图 20：GH200 H100 的 GPU Memory Bandwidth](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_grace_hopper_wechat_article_zh/a90bc7c69eb48824_20_h100_memory_bandwidth.png)

*图 20：更多启用 SM 与更高 Clock 带来更高带宽，但测试在 384 MB 后无法继续，因而不能可靠确定完整 VRAM Bandwidth。网页只作“若测试正常，可能高于独立 H100”的推测。*

原计划还用 `vkCmdCopyBuffer` 测 GPU Copy Engine 的 CPU→GPU Bandwidth。DMA Engine 能独立排队、比 CPU Pointer Chain 更耐 Latency，但该测试 Hang 且永不结束。

![图 21：GH200 测试触发的 Kernel/Graphics 错误](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_grace_hopper_wechat_article_zh/61209545703f7ddc_21_kernel_errors.png)

*图 21：`dmesg` 报告 PCIe Error 与 Graphics Exception。对应消息可能来自 Closed-source Nvidia Kernel Module，Linux Source 中无法定位；它记录了测试失败，不能据此诊断硬件根因。*

OpenCL 也不可用：`clinfo` 能发现 GPU，`clpeak` 等程序却无法创建 Context。相比之下，H100 PCIe Cloud Instance 的 Vulkan/OpenCL 表现正常。定制平台的 Interconnect、Driver 和 Runtime 协同验证显然十分困难。

### 体系结构视角：平台验证是异构架构的一部分

硬件一致性让 CPU 能“看见”HBM，Driver/Runtime 还要正确管理 Page Mapping、Fault、DMA、Reset 与错误恢复。任何一层死锁或异常处理不完整，都可能把一项性能测试扩大成整机 Hang。

发布级 Benchmark 应记录 Firmware、Kernel、Driver、CUDA/Vulkan/OpenCL Version 与 Error Log，并区分“不支持”“测试工具不兼容”和“平台故障”。图 21 只能证明当前组合失败，不能外推所有 GH200。

## 最后的评价：强大，却只完成了 APU 的一半

Grace 是很有个性的 Neoverse V2 实现：比 Graviton 4 核心少、Power Budget 高、Clock 更高，却不追求普适 Per-core Performance，而为特定 Parallel Application 优化。消费级通用负载即使 Vectorized，也未必合适。

这也揭示 Arm Licensing 模式的难题。AMD/Intel 的 Core Team 能围绕较窄的一组 Platform Characteristic 联合设计；Arm 必须让 IP 吸引尽可能多的 Implementer，难以预知最终会遇到 1 MB L2、125-cycle L3 还是 200 ns LPDDR。

![图 22：Arm 评估 Neoverse V2 的仿真平台](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_grace_hopper_wechat_article_zh/c220da6941fb4375_22_arm_v2_evaluation_platform.png)

*图 22：Arm Hot Chips 2023 Slide 展示的 Emulation Environment 与 Grace、Graviton 4 的实际平台差别很大。网页正式图注以此说明 IP 设计方无法完全预见最终 Uncore。*

Neoverse V2 的 Reordering Capacity 接近 Zen 4；换成 125-cycle L3、200 ns DRAM，Zen 4 同样会很难受。所有 Zen 4 实现都配低延迟 L3并非偶然。Golden Cove 在 i7-12700K 的 L3 约 11.8 ns，在 Xeon 8480+ 则约 33.3 ns；Server 版凭更大的乱序窗口和 2 MB L2缓解慢 Mesh。

GPU 侧可能是市场上最强 H100 Variant：完整 Memory Bus、更高 Power Limit，NVLink C2C 的 CPU/GPU Bandwidth 也高于 PCIe。但理论 450 GB/s 单向带宽很难被高 Latency 利用，Link Error 与 System Hang 令人担忧。把 VRAM 透明呈现为 NUMA Node 是很好的目标，以当前技术和软件成熟度看，却可能仍跨得太远。

![图 23：NVLink 用于跨节点的高速互连](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/nvidia_grace_hopper_wechat_article_zh/54b9e543814e8c93_23_nvlink_cluster.png)

*图 23：Nvidia 官方资料展示 NVLink 不只连接单模块 CPU/GPU，也服务 Cluster Scale-up。它扩大统一通信域，同时把拓扑、路由、可靠性和软件栈问题带到更大范围。*

Grace Hopper 虽不是共享同一 Memory Pool 的 iGPU，却是 Nvidia 对抗 AMD CPU/GPU Integration 的强力方案，已经进入 Amazon 和英国 Isambard-AI。AMD MI300A 采用真正 Integrated GPU，CPU/GPU 通信更快，但总 Memory Capacity 只有 128 GB；GH200 双池设计不需要接受这个容量妥协。两条路线的竞争，本质上是“统一低通信成本”与“针对各自需求配置大内存池”的权衡。

### 体系结构视角：从 GH200 可以归纳出的七点认识

第一，封装在一起不等于共享一池内存。GH200 用 LPDDR5X 满足 CPU Capacity/Latency，用 HBM3 满足 GPU Bandwidth，再以 C2C Coherency 架桥。

第二，Bandwidth 与 Latency 可以同时一强一弱。远端 HBM 有服务器级吞吐，Pointer Chain 仍近 800 ns；批量并行传输与细粒度依赖访问必须采用不同策略。

第三，同一 Neoverse V2 的性能主要从 L2 之后分叉。Grace 的 1 MB L2、高延迟大 L3和 LPDDR，与 Graviton 4 的 2 MB L2、低频多核形成不同产品。

第四，Prefetcher 能扩展 MLP，不能消除 Dependency Latency。Grace 单核线性 L3 Bandwidth 很强，单核 DRAM 却只有 21 GB/s，说明 200 ns 已超出它能持续掩盖的范围。

第五，统一大 LLC 与分簇 LLC 优化目标不同。Grace 方便大规模共享和 Cache Blocking；Genoa-X 把 Cache 靠近八核 Cluster，换来更低 Latency 和更好 Aggregate Scaling。

第六，端到端 Benchmark 必须先核动态工作量。7-Zip 的 2.58/1.86 万亿 Instruction 差异足以让性能比较失去纯硬件含义，负面结果应保留而非硬解释。

第七，异构集成的最后一公里是系统软件与恢复。NUMA Exposure、DMA、Vulkan/OpenCL 和 Kernel Error Handling 都是产品架构的一部分；一条 900 GB/s 链路若会 Hang，就还不能只按峰值评价。

## 参考资料

- Chips and Cheese：[*Grace Hopper, Nvidia’s Halfway APU*](https://chipsandcheese.com/p/grace-hopper-nvidias-halfway-apu)
- Nvidia：[*NVIDIA Grace CPU Superchip Architecture In-Depth*](https://developer.nvidia.com/blog/nvidia-grace-cpu-superchip-architecture-in-depth/)
- Nvidia：[*NVIDIA Grace Hopper Superchip Architecture In-Depth*](https://developer.nvidia.com/blog/nvidia-grace-hopper-superchip-architecture-in-depth/)
