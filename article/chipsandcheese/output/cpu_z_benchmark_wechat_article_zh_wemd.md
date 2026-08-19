---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "cpu_z_benchmark_wechat_article_zh"
---

> 英文标题：CPU-Z’s Inadequate Benchmark
> 撰文：Chester Lam
> 首发：Chips and Cheese，2023 年 11 月 3 日
> 链接：https://chipsandcheese.com/p/cpu-zs-inadequate-benchmark

CPU-Z 首先是一款硬件信息工具，开发者是 CPUID 公司；这里的公司名称不要与 x86 的 `CPUID` 指令混淆。它附带的免费跑分很方便，因此进入了硬件评测、网络讨论乃至 AMD 的发布幻灯片。但“方便比较”不等于“能代表真实负载”。下面通过 Intel Software Development Emulator（SDE）和性能计数器，看看这个分数究竟在奖励什么。

![图 1：CPU-Z 的处理器信息与内置 Benchmark 界面；识别结果本身也可能出现古怪之处](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_z_benchmark_wechat_article_zh/b2ce0e6eb79e7595_01_figure.png)

测试覆盖 AMD FX-8150、Intel Celeron J4125、Core i7-7700K、Ryzen 9 3950X 与 Ryzen 9 7950X3D。重点放在单线程模式；多线程模式看起来只是把同一小工作集放到每个逻辑核，并没有对共享缓存、内存带宽等系统级资源形成有效压力。

## 指令：标量 FP32 披着 SSE 外衣

CPU-Z 跑的是 SSE FP32 数学，但除少数 128 bit 内存访问外，几乎没有利用 SIMD 并行。主要指令是标量 FP32 加、乘、转换和比较。

![图 2：CPU-Z 动态指令组成，以标量 SSE 浮点操作为主](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_z_benchmark_wechat_article_zh/0f74e11ab424cd4f_02_figure.png)

SSE 编码和大位移内存操作数使平均指令长度达到 4.85 Byte。

![图 3：指令长度分布；较长的 x86 指令占据显著比例](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_z_benchmark_wechat_article_zh/22013d5a3177aac7_03_figure.png)

对 L1I 每周期只能供给 16 Byte 的老 Intel 核而言，理论上可能先碰到取指带宽；但只要代码被 Micro-op Cache（微操作缓存）覆盖，这个限制就不会出现，而且执行端也得先达到足够高的 IPC。

![图 4：CPU-Z 的 Load、Store 与 Branch 比例；分支密度低于游戏、压缩和 Cinebench 2024](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_z_benchmark_wechat_article_zh/1699faae7a420c8b_04_figure.png)

## 总体画像：前端轻松，后端等待计算

除 Bulldozer 外，各核心大致只能达到自身宽度的一半以下，属于中等 IPC 负载。

![图 5：多种微架构运行 CPU-Z 单线程测试时的 IPC](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_z_benchmark_wechat_article_zh/cf54aea6565d4680_05_figure.png)

Zen 4 按 AMD PPR 的 Top-down 方法统计，Kaby Lake 使用 VTune，Goldmont Plus 使用 `ISSUE_SLOTS_NOT_CONSUMED` 和 `UOPS_NOT_DELIVERED`。这里有一个重要边界：AMD 从前端取入、最终未退休的指令开始计算 Bad Speculation，Intel 从后续 Rename Stage 才开始，Zen 4 的比例天然可能显得更高，图中数值不能机械横比。

![图 6：Goldmont Plus、Kaby Lake 与 Zen 4 的流水槽位去向](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_z_benchmark_wechat_article_zh/1677ea9d89228b8c_06_figure.png)

Goldmont Plus 还不能在误预测后快速恢复，和老 Athlon 类似，要等分支退休后才能确定已知正确状态；图中的 Recovery 就是这段等待。即便如此，三者的共同特征仍是前端供给充分，主要损失落在后端。

## 数据几乎不离开 L1D

CPU-Z 和游戏、Cinebench 2024 的“内存约束”含义完全不同：它的数据工作集极小，32 KB L1D 已经容纳。

![图 7：后端受限周期的构成，核心多在等待计算完成](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_z_benchmark_wechat_article_zh/f51fd31a0296732d_07_figure.png)

![图 8：数据缓存命中率；主要访问停留在 L1D](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_z_benchmark_wechat_article_zh/9dd3ed2781758ccc_08_figure.png)

即使 Bulldozer 只有 16 KB L1D，命中率仍为 99.9%，每千条指令不到一次 Miss。Kaby Lake 从单线程切换到多线程，L1D 命中率也只从 99.97% 降到 99.78%。因此 L2、L3、DRAM 的差异基本没有进入比赛；所谓 Memory-bound Slot 多半只是 Load 等待 L1D 延迟，而乱序窗口通常能遮住它。

### 体系结构视角：工作集过小，会把“系统性能”压缩成单一局部能力

真实桌面软件经常同时面对不可预测分支、代码容量、共享缓存竞争和 DRAM 延迟。这里几乎删除了这些维度，得分便主要映射到标量浮点依赖链、乱序窗口和局部前端。拿这个结果外推游戏、编译或生产力软件，相当于用一个局部微基准代替整机负载。

## 乱序窗口与浮点依赖链

常见 L3 命中约 40～50 Cycle，DRAM 可达数百 Cycle；CPU-Z 却主要面对 3～5 Cycle 的 FP 运算延迟。核心需要越过尚未完成的浮点指令，找到依赖链之间的独立工作。

Bulldozer 的共享 FPU 有 60 项 FP Scheduler，兄弟线程空闲时容量看似充裕，仍偶尔因填满而停顿，说明依赖链很长。已完成的独立指令虽可离开 Scheduler，仍要留在 Reorder Buffer（ROB）直到按序退休。

![图 9：Bulldozer 后端结构占满情况；每线程 128 项 ROB 频繁成为边界](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_z_benchmark_wechat_article_zh/a637bb4d307dfaba_09_figure.png)

![图 10：Bulldozer FP Port 利用率不高，表现更像延迟受限而非吞吐端口受限](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_z_benchmark_wechat_article_zh/2ad86dcf117b54e0_10_figure.png)

Kaby Lake 代表 Skylake 衍生的多代 Intel 核。58 项统一 Scheduler 同时服务标量整数和 FP，容量竞争比 AMD 的分布式结构更明显；除 Store Buffer 外，图中结构计数器/Unit Mask 并未公开，结论需保留这一不确定性。

![图 11：Kaby Lake 后端结构压力；多数项目来自未公开计数器](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_z_benchmark_wechat_article_zh/68bdf4e001fb50cb_11_figure.png)

它的 224 项 ROB 能保留更多独立工作，基本 FP 延迟通常为 4 Cycle，也比 Bulldozer 的 5 Cycle 更快穿过依赖链。

![图 12：Kaby Lake 执行端口利用率；两条 FP Pipe 较忙但没有饱和](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_z_benchmark_wechat_article_zh/fd8d89a404dbcab0_12_figure.png)

Zen 2 的 FP 加乘延迟进一步降到 3 Cycle。36 项 FP Scheduler 前还有 64 项非调度队列，可追踪约 100 个未完成 FP Operation，因而压力转移到同为 224 项的 ROB。

![图 13：Zen 2 的 FP 队列与 ROB 占满情况](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_z_benchmark_wechat_article_zh/2864d83633dc6725_13_figure.png)

![图 14：Zen 2 FP Pipe 利用率；FP2 还承载 FP Store，负载略高](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_z_benchmark_wechat_article_zh/8e0f70f51175bf85_14_figure.png)

Zen 4 使用 2×32 项 FP Scheduler，加前级 64 项非调度队列，可跟踪接近 128 个未完成 FP Operation。Scheduler Stall Counter 只有前级队列也填满才增长，而测试中仍能看到停顿，再次印证依赖链很长。

![图 15：Zen 4 FP 调度容量压力](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_z_benchmark_wechat_article_zh/e4a53e8b25f1e4cb_15_figure.png)

和 Zen 2、Bulldozer 的 ROB 先满不同，Zen 4 更早耗尽 192 项 FP Register File；Zen 2/3 为 160 项。这说明绕过依赖链找到的独立指令本身也多是 FP，需要长期占用物理寄存器。

![图 16：Zen 4 后端受限来源，FP Register File 成为突出瓶颈](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_z_benchmark_wechat_article_zh/829aae8870c6f827_16_figure.png)

Zen 4 的专用 FStore Pipe 卸下了加法 Pipe 上的 Store 压力，因此端口利用率反而比 Zen 2 低。综合来看，CPU-Z 先奖励更低 FP Latency，再奖励足够大的 Scheduler、ROB 与 Physical Register File，而不是更多 FP Port。

## 前端：整段热点几乎住在 Micro-op Cache

现代核心仍保留强 Decoder，是因为 Micro-op 比 x86 指令占空间，Micro-op Cache 追求低延迟而不是大容量；真实代码经常溢出。CPU-Z 恰恰没有这种压力。

![图 17：Kaby Lake、Zen 2、Zen 4 的 Micro-op 来源；纵轴从 75%起](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_z_benchmark_wechat_article_zh/4f9f9c27d8aea689_17_figure.png)

三者超过 90% 的 Micro-op 来自缓存。Kaby Lake 若走 Decoder，16 Byte/Cycle 配合 4.85 Byte 平均指令长度只能支撑约 3.3 IPC；但热点命中绕开了限制。Zen 2 的 4096 项已经能装下全部测试，Zen 4 更大的缓存没有发挥空间。

![图 18：Sandy Bridge 发布时 Intel 给出的典型 Micro-op Cache 命中率约为 80%](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_z_benchmark_wechat_article_zh/da1687d0374c61d4_18_figure.png)

多线程模式下 Intel 静态分割 Micro-op Cache，每线程只剩 768 项，覆盖率仍有 84.16%，高于当年“典型应用”预期。AMD 以物理地址访问 Op Cache，同代码可被线程共享，因此 Zen 2/4 几乎不掉命中率。无 Op Cache 的核心也有约 99.9% L1I 命中。

![图 19：各核心 L1I 命中情况；代码容量几乎不构成挑战](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_z_benchmark_wechat_article_zh/b7e4eeffce19f3ef_19_figure.png)

## 分支：少、容易预测，BTB 也装得下

CPU-Z 的分支更少、更规律。Bulldozer 相对困难，但误预测仍是次要问题；现代 Intel、AMD 准确率接近，AMD 投入更大面积的 Predictor 在此得不到相称回报。

![图 20：单/多线程分支误预测率；注意各子图量程不同](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_z_benchmark_wechat_article_zh/7fedfc268a307346_20_figure.png)

剩余少数错误可能需要很长 History，或分支不够热、来不及训练。两线程共享 Predictor 只造成轻微下降，仍远弱于 Cinebench 2024 和游戏的控制流压力。

BTB（Branch Target Buffer）保存 Taken Branch Target，让前端不必等指令被取回、译码后再计算目标。这里 Unique Branch Footprint 很小，连 BTB 最小的 Goldmont Plus 都能跟上，Zen 4 的 1.5K 项 L1 BTB 已绰绰有余。

![图 21：CPU-Z 的 BTB 层级命中/重定向情况](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_z_benchmark_wechat_article_zh/64454fcf1573fc61_21_figure.png)

### 体系结构视角：更强的 Predictor 只有在控制流足够难时才能兑现

Branch Predictor、Micro-op Cache 和大 L2 都以面积、功耗换取真实应用的前端连续供给。若基准的 Branch Footprint 小、Pattern 简单、代码完全命中 Op Cache，那么这些代际投资在分数里几乎不可见。这不是新架构“没有进步”，而是测量没有激发相应机制。

## 为什么这个分数不足以指导选购

真实的编译、图像编辑、视频编码和游戏很难同时满足“数据在 L1、代码在 Op Cache、分支又容易预测”。CPU-Z 反而正是这个例外。AMD 的公开幻灯片里，Zen 4 相对 Zen 3 在 CPU-Z 只有约 1% IPC 提升，不能由此否定更大 Op Cache、更好 Branch Prediction 和翻倍 L2；这些改动服务的恰是 CPU-Z 没有覆盖的负载。

![图 22：AMD 幻灯片中的 Zen 4 对 Zen 3 IPC 增幅，CPU-Z 仅约 1%](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_z_benchmark_wechat_article_zh/89ddd2d6f04d40ce_22_figure.png)

![图 23：CPU-Z 跑分界面与参考结果](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_z_benchmark_wechat_article_zh/bf58d7a8cf27705b_23_figure.png)

因此，CPU-Z Benchmark 更适合被理解为一个小型、标量 FP、长依赖链的局部测试。它能观察 FP Latency 与乱序资源，却不能代表现代应用最常见的 Branch Predictability 和 Data Locality 挑战。若未来版本要提升代表性，应先从真实桌面应用采样性能计数器，再按常见代码、分支与内存 Footprint 设计工作负载。

## 参考资料

- CPU-Z / CPUID
- Intel Software Development Emulator、VTune
- AMD Processor Programming Reference
- Chips and Cheese：CPU-Z’s Inadequate Benchmark
