---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "amd_mi300a_memory_wechat_article_zh"
---

> 英文标题：Inside the AMD Instinct MI300A's Giant Memory Subsystem<br>
> 撰文：Chester Lam<br>
> 首发：Chips and Cheese，2025 年 1 月 18 日<br>
> 原始链接：https://chipsandcheese.com/p/inside-the-amd-radeon-instinct-mi300as

AMD 在 2006 年收购 ATI，希望把 GPU 专长与 CPU 能力结合成完整平台。“Accelerated Processing Unit”（APU）这个名称从 2011 年 Llano 延续至今，Van Gogh、Phoenix、Strix Point 已让 AMD 在移动游戏市场占据重要位置。

![图 1：MI300 的模块化构造，计算 die 可在 CCD 与 XCD 之间组合](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/90bd9abc04c7519c_01_figure.jpg)

MI300A 把 APU 推到 HPC 与 AI：三个 Core Complex Die（CCD）各含 8 个 Zen 4 核心，共 24 核、最高约 3.7 GHz；六个 Accelerator Complex Die（XCD）各含 38 个 CDNA3 Compute Unit，共 228 CU。它们堆叠在四个 I/O Die（IOD）上，IOD 既是带 cache 的 active interposer，又通过下层 active interposer 互连并访问 HBM3。

可以把 MI300A 理解为用部分 GPU 算力换来 24 个 Zen 4 核的 MI300X。两款 MI300 都拥有 256 MB memory-side Infinity Cache 与 5.3 TB/s HBM3 带宽。CPU、GPU 本体此前已有专文，本文集中分析这张巨大的 Infinity Fabric 网络。

![图 2：四路测试系统的 lstopo 拓扑，每颗 MI300A 作为一个 NUMA node](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/f3be1a7e17dc368a_02_figure.jpg)

测试设备是 GIGABYTE G383-R80-AAP1，包含四颗 MI300A，由 AMD 与 GIGABYTE Launchpad 提供超过两周。设备来源得到厂商支持，但测试方法和判断由 Chips and Cheese 独立完成。

## 巨型 APU 上的 Infinity Fabric

Infinity Fabric 由大量网络化组件组成，为 24 个 CPU 核与 228 个 GPU CU 提供 coherent memory access。CPU/GPU die 首先与 Coherent Master（CM）通信。CM 保存 memory map，把请求封装为 flit，并按物理地址发给负责该地址的 agent；总线、switch 与 off-die interface 再把 flit 送到目标。

![图 3：MI300A 内存系统概览，CCD/XCD 经 CM、IOD 与 HBM3 相连](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/6688ec804315abfc_03_figure.jpg)

大部分 CPU/GPU 请求落到由 DRAM 支撑的物理地址。Coherent Slave（CS）负责提供最新数据，内部有 probe filter，并连接 memory controller。

![图 4：CM、CS、Infinity Cache 与 HBM 的简化数据路径](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/97c8d115b5f57a83_04_figure.jpg)

MI300A 的每个 CS 还与一个 2 MB Infinity Cache block 共置。一个请求可能从三处满足：

1. 命中该 CS 的 2 MB Infinity Cache slice；
2. cache miss 后访问附属 memory controller；
3. 若 probe filter 表明某 CPU/GPU die 持有 modified line，则向对应 CM 发 probe。

计算 die 无需自行区分这些位置，就能获得最新数据；代价是路径很长。

![图 5：单路 MI300A 的依赖读取延迟阶梯，Infinity Cache 命中超过 140 ns，HBM3 约 227 ns](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/122da9b8203e0e0c_05_figure.jpg)

Infinity Cache hit 的 load-to-use latency 超过 140 ns，甚至高于 Ryzen 9 7950X3D 的 DRAM。miss 后访问 HBM3 约 227 ns。“High Bandwidth Memory”首先追求带宽而非低延迟，而 Infinity Cache 本身也很慢，说明相当多时间花在穿越庞大 Fabric。

![图 6：MI300A 中请求在 CM、CS、2 MB slice 与 HBM 间的路径示意](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/020dfa0addb0ba23_06_figure.png)

### 体系结构视角：memory-side cache 与核心侧 LLC 的位置不同

桌面 Zen 4 的 L3 紧邻 CCX，命中路径相对短。MI300A 的 Infinity Cache 挂在负责地址归属与一致性的 CS 一侧，任何 CCD/XCD 都可受益，却必须经过片上网络。它减少 HBM 流量、扩大共享容量，但不等于“256 MB 的低延迟 CPU L3”。对 GPU 来说，海量线程能隐藏延迟；对 CPU 指针链来说，140 ns 仍会直接暴露。

验证这类结构要同时测依赖 load latency、并发带宽与 cache hit/miss 边界。只看 256 MB 容量或 5.3 TB/s 峰值，无法推断 CPU 性能。

## 四路 NUMA：本地、近端与远端

Infinity Fabric 的 transport layer 可跨越封装，支持多路 NUMA。四颗 MI300A 各暴露为一个 node。

![图 7：四个 NUMA node 的 2 GB 读取延迟矩阵，本地约 234—247 ns，远端约 480—580 ns](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/20c254b1ec3898bb_07_figure.png)

`numactl --hardware` 报告各 node 距离相同，GIGABYTE 图也暗示四颗芯片彼此直连；实测却有成对差异。

![图 8：G383-R80-AAP1 方框图，四颗 MI300A 之间有封装外 Infinity Fabric 链路](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/b7c0e4c650900de0_08_figure.jpg)

较近 node 的远端 DRAM 延迟约 477 ns，较远 node 约 559 ns。作者推测差异来自 cross-socket link 相对 CPU core 的位置：若链路在另一块 IOD 上，先跨 IOD 就会增加时间。该解释没有内部布线资料确认。

![图 9：本地、近端和远端 node 的缓存/内存延迟曲线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/296fa2614315b8cf_09_figure.jpg)

远端数据若命中其归属 node 的 Infinity Cache，延迟可降至约 369 ns 与 430 ns，仍然很高。原因是本地 MI300A 的 Infinity Cache 不能缓存其他 node 的地址。cache slice 与 CS 绑定，只处理该 CS 的 memory controller 所拥有的地址。

![图 10：访问远端 node Infinity Cache 时，请求必须跨封装到拥有该地址的 CS](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/b451672e3a099d0f_10_figure.png)

这种绑定牺牲一部分 NUMA 性能，却让 256 MB memory-side cache 自然嵌入现有一致性体系，只需在 CS 增加有限逻辑。若另设一层可缓存远端地址的解耦 cache，可能隔离 remote DRAM latency，但其 controller 需要同时承担 CM 与 CS 的职责，也会形成新的 coherence domain 和状态管理。

![图 11：远端 Infinity Cache miss 后继续访问归属 node HBM3 的完整路径](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/a7e2471e789883e6_11_figure.png)

与常规双路服务器相比，MI300A 的本地和远端 DRAM 延迟都很高，Zen 4 CPU 核因此会落后于桌面或 EPYC 实现。

![图 12：MI300A、双路 EPYC 9Y3X 与双路 Xeon 的本地/远端 DRAM 延迟对比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/e00563a4cc744552_12_figure.jpg)

## 一致性 probe 与核间传递

Infinity Cache 和 HBM 是主要数据来源。若 probe filter 显示某地址已在其他 CPU/GPU die 中修改，CS 还要发 probe，确保所有计算单元看到一致数据。这类流量占比很小，却决定共享内存语义。

![图 13：四路 MI300A 的 core-to-core latency 全矩阵缩略图](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/0d9c5249ae4b1d69_13_figure.jpg)

单颗 MI300A 内跨 CCD 传递约 260—450 ns，差异可能取决于测试地址 homed 到哪个 CS。它明显慢于 EPYC，但 MI300A 的 Fabric 网络也大得多。

![图 14：MI300A 与桌面/服务器 Zen 4 的 CM、CS 数量及核间传递规模对比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/62a5ab4904b5d855_14_figure.jpg)

四颗芯片组成的一致性域更加复杂。最坏情况是负责地址的 CS 与两个通信 core 都不在同一 node：传递会涉及三颗 MI300A，一颗持有请求方，一颗持有数据方，第三颗负责 home/orchestration。

![图 15：四路系统逐核延迟热图，跨 node 特别是第三方 home node 路径最慢](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/0cd9814661c2563f_15_figure.png)

这也解释 AMD 为什么更愿意在单 socket 内提高 EPYC 核数，而不是继续扩到四路。只看单颗 MI300A，拓扑会清晰很多。

![图 16：单个 MI300A node 内的逐核延迟，每次只测一个核心](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/b9790af95dd26390_16_figure.jpg)

![图 17：AWS 上 12 核 Zen 4 实例的核间延迟对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/97f9d6641e6488d8_17_figure.jpg)

作者强调，core-to-core transfer 在真实应用里很少，这组测试几乎不应直接用于预测应用性能；它的价值主要是揭示 topology 和 home-agent 路径。

### 体系结构视角：一致性的“home”位置会决定最坏路径

cache line 的最新副本、请求 core 与负责该物理地址的 CS 可能位于三个不同位置。即使两线程彼此很近，home agent 很远也会让所有权转移绕路。NUMA 优化不只是把线程绑到相邻核心，还要让内存 first-touch/allocate 到合适 node，并减少跨 node 写共享。

若平台提供计数器，可通过 remote read/write、probe、cache-to-cache transfer、link flit 和 home-node 分布验证；本文主要用延迟矩阵反推，所以具体链路位置仍属推测。

## 带宽：CPU 面前是大海，出口却是有限的

每个 8 核 Zen 4 CCD 使用 GMI-wide 配置，与系统之间双向各有两条 32 B/cycle link。更宽链路允许庞大 Fabric 以较低频率运行，也让 CPU 核获得高于桌面 Zen 4 的带宽。

![图 18：MI300A CCD、桌面 Ryzen 7950X 与 EPYC CCD 到 I/O die 的链路宽度对比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/88718f64d13379d7_18_figure.jpg)

MI300A 仍有与桌面 Zen 4 类似的 CCD pinch point：同 CCD 上的带宽线程可让延迟敏感线程成为 noisy neighbor。实测约 71 GB/s，高于桌面 Zen 4 在 2 GHz Fabric 下约 64 GB/s 的读上限；超过这个界线，延迟开始上升。其他 CCD 的流量则相互隔离。

![图 19：同 CCD 与其他 CCD 加载内存时的延迟；同 CCD 流量超过约 71 GB/s 后延迟激增](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/3ba2608492faa195_19_figure.png)

即便另外两块 CCD 合计读取超过 140 GB/s，第一块 CCD 的延迟也不变。三块 CCD 无法接近 HBM3 极限。

![图 20：24 个 CPU 核和 6 个 GPU XCD 在 MI300A 内的连接关系](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/33981f7e4d373d70_20_figure.jpg)

5.3 TB/s HBM3 主要服务 GPU。Apple M1 Max 也不能让 CPU 核吃满整片 LPDDR5，说明集成系统常在 CPU cluster 到 system fabric 之间设置实际瓶颈。

MI300A 的 24 个 Zen 4 核可读约 212 GB/s；若使用 read-modify-write 同时利用 CPU die Fabric 的两个方向，可达约 314 GB/s。人均带宽很高，却仍不足以让 HBM controller 紧张。CPU 负载更依赖延迟，因此同频 MI300A Zen 4 在 Y-Cruncher 这类带宽密集程序中仍落后于服务器 Zen 4。

![图 21：Y-Cruncher 总计算时间，MI300A 慢于 EPYC 9R14，快于 7950X](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/5f81faadc9949db2_21_figure.png)

![图 22：SPEC CPU2017 估算分数；MI300A 单线程整数大致处于 Ryzen 9 3950X 的 Zen 2 水平](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/ef651e1c1ac67e73_22_figure.png)

这并不意味着 Zen 4 core 本身退化，而是 3.7 GHz 与高延迟内存系统共同决定了可见性能。3950X 曾是顶级桌面 CPU，绝对单线程能力至今仍可用；对主要负责支持 GPU 的 24 个核心来说，这个位置并不差。

## 跨 node 带宽：链路能力没有完全变成 CPU 读取带宽

off-socket Infinity Fabric 每方向提供 128 GB/s。读取工作集能装进远端 Infinity Cache 时，实测可以接近链路极限。

![图 23：跨 node 读取带宽随工作集变化；命中远端 Infinity Cache 时接近链路能力](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/2618c94c57abd12a_23_figure.png)

工作集扩大到远端 HBM 后，CPU 读取带宽却很低。作者尝试让所有线程按 flag 同时结束，避免固定工作量带来的尾部误差，也尝试 2 MB huge page 减少地址翻译开销。

![图 24：读取远端 node Infinity Cache 的路径与约 112—115 GB/s 结果](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/d9fe670fb1774c69_24_figure.png)

这些改动都无明显作用，remote DRAM read 仍只有 25—26 GB/s。

![图 25：Infinity Cache miss 后读取远端 HBM3 的路径，CPU 实测约 25 GB/s](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/f8e7a6721686caa6_25_figure.png)

换用 non-temporal write 可提高带宽。普通 write 通常先做 read-for-ownership（RFO），否则可能 torn write，读延迟会限制吞吐；non-temporal write 则明确避开这条路径。部分服务器 CPU 如 Ice Lake 能在特定条件避免 RFO，但这里选择 NT store 以固定语义。

![图 26：跨 node non-temporal write 绕过 Infinity Cache，实测约 45.43 GB/s](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/ff77428a47e05239_26_figure.png)

45.43 GB/s 好于 25 GB/s，却仍远低于链路已证明可达的 112 GB/s。改变线程数也没有解决。

![图 27：remote bandwidth 随线程数扩展；超过两个 core 后不再上升](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/e7ec73c1748a1aba_27_figure.png)

两核后就饱和，说明单核可制造的 memory-level parallelism 不是主要限制。write 更快、远端 cache hit 又能到 112 GB/s，仍提示某处受延迟或控制路径限制；具体瓶颈无法从现有测试定位，文章明确保留未知。

## CPU 与 GPU 通信：显式复制

MI300A 让 CPU/GPU 共用主存。最基础、最可移植的 GPU 模式仍是显式复制；测试用 OpenCL `clEnqueueWriteBuffer` 与 `clEnqueueReadBuffer` 在 CPU、GPU memory space 间搬数据。

![图 28：OpenCL buffer copy 带宽，本地与跨 MI300A GPU 的大块复制可达约 55.9 GB/s](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/c70bef240119a694_28_figure.png)

这些 API 往往调用 GPU DMA engine，较不敏感于 CPU load latency。即使跨到另一颗 MI300A，也可达 55.9 GB/s，高于 CPU remote request，再次支持 CPU 测试受延迟限制。小块 copy 仍会受延迟影响，跨芯片更明显，DMA startup 也是原因之一。

## Shared Virtual Memory：同一指针不一定等于零拷贝

OpenCL Shared Virtual Memory（SVM）允许 CPU 与 GPU 使用相同 pointer，但规范本身不保证 zero copy。支持等级决定显式同步程度：

- coarse-grained buffer：CPU 写入后要 `clEnqueueSVMUnmap` 才对 GPU 可见；GPU 结果要 `clEnqueueSVMMap` 后 CPU 才能看见；
- fine-grained buffer：GPU kernel 结束后结果自动可见，kernel 启动前的 CPU 写入也自动可见；
- atomics：CPU/GPU 可在程序运行时直接交换数据，通信体验接近额外 CPU thread。

![图 29：AMD 对 MI300A coherent shared memory 的说明](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/c4dfa82d77c2b2fd_29_figure.png)

驱动仍可能在 SVM 背后复制整块 buffer。为识别 zero copy，测试分配 256 MB，却只改一个 32-bit value：真正共享只需传播一个 cache line；若驱动复制整块，延迟会进入毫秒级。

![图 30：256 MB SVM buffer 只修改 32 bit 时的 CPU↔GPU 同步延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/8c950db2b8d6643b_30_figure.png)

所有支持 fine-grained sharing 的受测 GPU 都表现为 zero copy，部分仅 coarse-grained 的 GPU 也能做到。Meteor Lake Core Ultra 7 155H iGPU 只报告 coarse-grained，却明显没有复制整块，而且是该测试最快。Nvidia Pascal discrete GPU 进入毫秒级，说明缺少强硬件 cache coherence，驱动很可能复制完整 256 MB；两款 Arm Mali iGPU 也不像 zero copy。MediaTek Genio 1200 避免 PCIe 传输仍有收益，但延迟比真正 zero copy 高几个数量级。

![图 31：改用 4 KB allocation 后的同步延迟，显示微秒级主要来自同步固定开销](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/fd6d58d946ddc427_31_figure.png)

buffer 只有 4 KB 时，两款 Nvidia discrete GPU 与其他平台差距缩小。排除大复制后，MI300A 的 zero-copy 确认成立，同步开销仅高于 Meteor Lake；CPU 与另一颗 MI300A 的 GPU 同步也只略慢。

## Atomics：绕开驱动级同步

atomic 可在 kernel 不结束、驱动不做整套维护时让写入跨 CPU/GPU 可见。MI300A 没有宣告支持 SVM atomics，但实测足以把 core-to-core ping-pong 改造成一条 GPU thread 与一条 CPU thread：GPU 用 OpenCL `atomic_cmpxchg`，CPU 在 Windows/MSVC 用 `_InterlockedCompareExchange`，Linux/GCC 用 `__sync_bool_compare_and_swap`。

![图 32：CPU↔GPU atomic ping-pong；MI300A 本地约 222.15 ns，远端仍控制在数百 ns](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/0dc87e6fcf661d08_32_figure.png)

去掉驱动程序与高层同步后，延迟回到纳秒级。本地 MI300A 的 222.15 ns 比明确支持 atomics 的 Core i5-6600K 稍慢，但对如此大的一致性系统已很优秀，且接近 CCD 间延迟；跨 MI300A 的 GPU 也没有失控。

![图 33：四颗 MI300A 上不同 CCX 到不同 GPU 的 atomic 延迟矩阵](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/e157ef43c16eb734_33_figure.png)

GPU 的写入与 atomic 组织可能解释它为何优于最差 core-to-core 路径。CPU 用 write-back L1，atomic 需要获取 cache line 所有权；GPU 的 L1 常是 write-through 或 read-only，写入下沉到 L2，atomic 由 L2 专用单元处理，无需 probe CU-private cache。AMD 也可能重点优化 GPU atomic，因为 GPU 才是 MI300A 主角。这两点是基于结构的解释，不是内部实现确认。

### 体系结构视角：统一地址、共享物理内存和硬件一致性是三件事

SVM 只保证可使用相同 pointer；驱动可以迁移或复制数据。zero copy 表示不搬整块数据；fine-grained coherence 与 atomic 又进一步决定修改何时可见。程序设计必须按平台声明和实测选择同步方式，不能看到“统一内存”四个字就假设所有访问都像 CPU cache hit。

MI300A 的价值是把 CPU/GPU 交接从 PCIe 外设事务降到 coherent fabric 内部事务。长 GPU kernel 之间若需要 CPU 小规模处理，222 ns 级 atomic 或微秒级 SVM 同步可显著减少数据周转，但它并不会消除 kernel launch、同步和 NUMA placement 的成本。

## 封装、模块化与工程分工

MI300A 把 AMD CPU/GPU 能力组合到非常大的封装。IOD 可连接 XCD 或 CCD，使 MI300X 与 MI300A 重用大量 die，简化制造与产品组合。

![图 34：同一 Zen 4 CCD 在 EPYC、MI300A 中复用，以及 IOD/XCD 的模块化接口](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/054c9184c2109b9c_34_figure.jpg)

多种先进封装共同支撑它：die 堆在 die 上，再堆到另一层 die；垂直堆叠由 TSV 提供高带宽，相邻 IOD 也用超短距离链路连接。

![图 35：MI300 的 3D hybrid bonding、2.5D interposer 与多层封装](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/3e348a07f059667f_35_figure.jpg)

AMD 的封装论文称，每颗 IOD 几乎用完整 die edge 铺设接口；相邻 IOD 距离极短，因此复用了 Radeon GPU 开发的 ultra-short-reach（USR）SerDes PHY。

高 die-to-die 带宽让 MI300X 对程序员呈现为一个巨大 GPU。上一代 MI250X 与 Intel Ponte Vecchio 的两半间带宽不足，需要按两个 GPU 管理；MI300A 再加入 CPU，低成本 CPU/GPU 通信进一步简化编程。

硬件连接只是问题的一半。大项目容易出现“太多厨师”的协作成本，而清晰接口可以划分责任。无法从外部确认 AMD 内部组织，但 MI300A 显示出组件之间非常明确的边界：CCX 或 GPU block 只要遵守 CM 接口，就能获得 coherent memory access，无需知道后面接 DDR5、LPDDR5 还是 HBM3，也无需关心系统连接的是 Ryzen 中的另 1 个 CPU Cluster、EPYC 中的另 11 个，还是 2 个 CPU Cluster 加 6 个 GPU Block。

![图 36：Llano 的 GPU 大部分访问走 non-coherent link，coherent 请求则通过较窄的特殊路径接入 Northbridge](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/14063c1806c56e96_36_figure.jpg)

这与 Llano 形成鲜明对比。其 Terascale 2 iGPU 根据是否要求 coherence 选择不同链路，带来复杂度和某些内存类型的奇怪带宽限制；GPU Graphics Memory Controller 还必须了解 CPU Northbridge 细节。任何一侧修改都可能破坏另一侧假设。Infinity Fabric 的抽象接口降低了这种跨团队耦合，是 AMD 能做 MI300X/MI300A 的组织基础之一。

## 为 GPU 倾斜的妥协

CPU 与 GPU 偏好的 memory subsystem 不同。MI300A 明确偏向 GPU：Infinity Cache + HBM3 是高延迟、高带宽，适合用海量并行隐藏延迟的 GPU，却不利于延迟敏感 CPU。Zen 4 核无法追上主流客户端/服务器版本；一致性域扩展到多封装后，remote memory 和 coherence traffic 又比常规双路服务器更昂贵。

PC 用户通常不会接受为巨大 iGPU 付出如此明显的 CPU 妥协，这也是大 iGPU 很少占据桌面高端的原因。但 MI300A 的 CPU 本来就是为巨型 GPU 服务，而非承担高响应的通用桌面任务。24 个核心每个大致仍有 Ryzen 9 3950X 最高频核心的性能，整体算力并不弱。

![图 37：MI300A 的 24 个 Zen 4 核、三个 CCD 与共享 HBM/Infinity Cache](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/aa671e237d50764a_37_figure.jpg)

更重要的是，CPU 可以快速与 GPU 共享数据。若长时间 GPU kernel 之间需要少量 CPU 处理，24 核可能正好喂饱接近 MI300X 规模的 GPU，无需独立 host CPU。

![图 38：El Capitan 使用四路 MI300A node，并在 2024 年 11 月 TOP500 位居第一](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_mi300a_memory_wechat_article_zh/3035204110bdb0ae_38_figure.jpg)

MI300A 已赢得多个超级计算项目，最大案例是 LLNL El Capitan 的四路 MI300A node。它在 2024 年 11 月 TOP500 排名第一。AMD 从 Llano 的早期愿景走了十多年，才把统一 CPU/GPU 设计推进到 exascale。

## 结语

MI300A 不是“带大显卡的普通 Zen 4 服务器”，而是一台以 GPU 为中心的 coherent system。256 MB Infinity Cache、5.3 TB/s HBM3 和巨大 Fabric 提供 GPU 所需吞吐，也带来 140 ns 以上 cache hit、227 ns HBM、本地与远端 NUMA 的高延迟。CPU 端的 212 GB/s 读带宽很高，却仍受 CCD link 与访问延迟约束。

它真正独特的优势在 CPU/GPU 共享：显式 DMA copy 可达约 55.9 GB/s，SVM 展示 zero copy，atomic ping-pong 本地约 222 ns。先进封装让物理带宽成立，CM/CS 接口让众多 die 和工程团队能够组合。理解 MI300A，关键不是把每个峰值相加，而是看每种请求经过哪些一致性节点、在哪一级被限速，以及产品为 GPU 吞吐主动牺牲了什么。
