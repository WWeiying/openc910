---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "x86_split_locks_wechat_article_zh"
---

> 英文标题：Investigating Split Locks on x86-64
> 撰文：Chester Lam
> 首发：Chips and Cheese，2026 年 4 月 8 日
> 链接：https://chipsandcheese.com/p/investigating-split-locks-on-x86

Split Lock（跨行锁）是操作数跨越 Cache Line Boundary 的原子内存操作。普通 Atomic 可借 Cache Coherence 独占一条 Cache Line，不妨碍其他地址；Intel、AMD 看来都不能同时锁住两条 Line，于是跨行时退回文档所谓的 Bus Lock。它既慢，也可能干扰其他核心，因此新处理器可 Trap Split Lock，Linux 默认还会人为加入延迟。

![图 1：一个 8 Byte 原子值横跨两条 64 Byte Cache Line 的示意](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/b385d324b493da1a_01_figure.jpg)

## 怎么把影响测出来

Core-to-core Latency Test 用 `_InterlockedCompareExchange64`，在 x86-64 编译为 `lock cmpxchg`。正常目标位于 64 Byte 对齐块开头；Split 版本把 8 Byte Value 起始地址放到 Line 尾部之前，让一部分 Byte 落入下一条 Line。

为测 Noisy-neighbor，另一组不参加锁 Ping-pong 的核心同时运行 Memory Latency/Bandwidth Microbenchmark，以及 Geekbench 6 Photo Filter 与 Asset Compression。前者生成大量 Cache Miss Traffic，后者较少。很多 CPU 只有不超过两核活跃时才能最高 Boost，而实验至少占三核，因此部分平台关闭 Boost 或降频，以隔离 Clock Variation。结果仍是刻意高频循环 Split Lock 的极端压力，不代表普通应用的发生率。

## Arrow Lake：L2 命中以内基本隔离

Core Ultra 9 285K 的普通跨核 Ping-pong 如下，Linux 先编号全部 P-Core，再编号 E-Core。

![图 2：Arrow Lake 普通 Cache Line Ping-pong Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/79f360ff67dd0735_02_figure.jpg)

Split Lock 把延迟推到约 7 μs，且不同 Core Type 之间差异不大。

![图 3：Arrow Lake Split Lock 的跨核延迟矩阵](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/2bdbff89c45fb65b_03_figure.png)

![图 4：Arrow Lake 普通与 Split Lock 延迟对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/ebf2e45faff2165d_04_figure.jpg)

干扰只从 L2 Miss 开始，行为接近传统意义上的“锁住所有核心共享层级”：若另一程序持续命中本核 L2 或更快 Cache，可以不受影响。

![图 5：Arrow Lake 在 Split Lock 干扰下的 Memory Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/947900fb8608eb14_05_figure.png)

![图 6：Arrow Lake Memory Bandwidth；越过 L2 后大致减半](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/7cb80b4786f2dd3e_06_figure.png)

同一四 E-Core Cluster 共享的 4 MB L2 很特别，即便 Split Lock 来自本 Cluster 两核，L2 Hit 也没有被拖慢。Geekbench Photo Filter 因 Cache Miss 多而严重下降，Asset Compression 也降但较轻。

![图 7：Arrow Lake 的两项 GB6 干扰结果；P-Core 4.7 GHz、E-Core 3.8 GHz、DDR5-4800 JEDEC](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/31d1bc9ee348ffb3_07_figure.png)

## Zen 5：Split Lock 本身较快，邻居反而更惨

Ryzen 9 9900X 的 Split Lock 约 500 ns，优于 Arrow Lake，仍远慢于普通 Atomic；CCX Boundary 基本不改变延迟。

![图 8：Zen 5 普通跨核延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/1e71a49a39627f9c_08_figure.jpg)

![图 9：Zen 5 Split Lock 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/e420a802cf2014d1_09_figure.jpg)

但它会破坏所有 L1D Miss：L2、L3 Latency 与 Bandwidth 约退化 10 倍。

![图 10：Zen 5 Memory Latency，在 L1D 以外出现数量级退化](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/80be66af6359c13a_10_figure.png)

![图 11：Zen 5 Memory Bandwidth](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/1c04d5c5bb4a467c_11_figure.png)

所以连平时不产生太多 L3 Miss 的 Asset Compression 也重挫，因为此时一次 L1D Miss 就已昂贵。

![图 12：Zen 5 两项 GB6 Workload 均严重下降](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/53398577244d3bb9_12_figure.png)

### 体系结构视角：原子操作自身延迟与系统 QoS 是两个指标

Zen 5 的 500 ns 看似胜过 Arrow Lake 的 7 μs，却让邻居从 L2 起承受约 10 倍损失；Alder Lake 后面会展示相反组合。评估 Atomic Corner Case 不能只测发起线程完成时间，还要测其他核心在 L1/L2/L3/DRAM 各层的 Latency、Bandwidth 和真实 Workload Throughput。

## Alder Lake：操作最慢，隔离却最好

Core i7-1265U 有 Golden Cove P-Core 与 Gracemont E-Core。普通 Line 在 P-Core 间转移比 E-Core 快；Arrow Lake 之前，即便同 Cluster 的 E-Core 互传也要走 Ring。

![图 13：Alder Lake 普通跨核 Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/3dfda1667c49eed0_13_figure.png)

Split Lock 颠倒关系：P-Core 极慢，P↔E 略高于 7 μs、接近 Arrow Lake，E-Core 反而最好。

![图 14：Alder Lake Split Lock Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/f841a20a0561bfe9_14_figure.png)

其 Memory Subsystem 却很能隔离干扰，L3 只轻微下降，DRAM Latency 增量也不大。

![图 15：Alder Lake Memory Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/4b67754ee38d732c_15_figure.png)

![图 16：Alder Lake Memory Bandwidth](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/4b67754ee38d732c_16_figure.png)

![图 17：GB6 几乎不受影响；此平台未降频，部分差异来自多核频率变化](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/4dbe3ab1ac0bcc6d_17_figure.png)

## Zen 2：与 Zen 5 一样，从 L1D Miss 起全面受创

Ryzen 9 3950X 的 Split Lock 延迟高于 Zen 5，仍好于新 Intel；CCX Boundary 同样没有明显影响。

![图 18：Zen 2 普通跨核 Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/4e1e04326f433708_18_figure.jpg)

![图 19：Zen 2 Split Lock Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/836f12dda42aae85_19_figure.jpg)

L1D 之外 Latency/Bandwidth 约退化 10 倍。

![图 20：Zen 2 Memory Latency 与 Bandwidth 的 Split Lock 对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/2272aa3c81c07f2e_20_figure.png)

当 Split Lock 与被测负载位于同一 CCX 时，L3 Latency 在 2 MB 后还出现一次额外拐点，Zen 5 同 CCX 没有相同现象。

![图 21：Zen 2 工作集越过 2 MB 后的额外 L3 Latency 变化](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/cd9bc0b31d82694c_21_figure.png)

![图 22：Zen 2 的 GB6 Photo Filter 与 Asset Compression 均严重下降](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/01656e0a845f23d8_22_figure.png)

## Skylake：L2 Hit 安全，越过 L2 才受罚

Core i5-6600K 的 Split Lock 竟优于 Arrow Lake/Alder Lake，略差于 Zen 2，尚未到 μs 级。

![图 23：Skylake 普通与 Split Lock 跨核 Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/940f64c743f2f87c_23_figure.png)

和 Arrow Lake 类似，L1/L2 Hit 不受影响，L2 Miss 后出现惩罚。

![图 24：Skylake Memory Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/c1854891ecdc9100_24_figure.png)

![图 25：Skylake Memory Bandwidth](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/10f9019c5cf2201f_25_figure.png)

![图 26：Photo Filter 性能下降 34.24%，Asset Compression 下降 16.2%](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/17c96740b09db33f_26_figure.png)

## Piledriver：最老的平台反而最从容

FX-8350 平时跨核延迟高，但 Split Lock 只比普通 Atomic 慢 2～3 倍，是全部平台最好结果。

![图 27：Piledriver 普通与 Split Lock Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/f0435d0a3069c8a9_27_figure.png)

Cache Hit 完全不受影响，甚至包括 Shared L3；只有 DRAM Latency 约翻倍、Bandwidth 下降一半以上。

![图 28：Piledriver Memory Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/03d079c340356abd_28_figure.png)

![图 29：Piledriver Memory Bandwidth](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/b6a079220432ef63_29_figure.png)

![图 30：两项 GB6 只有较轻损失](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/a3486c98ab4ed2a1_30_figure.png)

Piledriver 有约 10 MB Cache 不受 Split Lock 干扰，测试平台中无人能提供更多“安全容量”。这也提醒我们：更老不等于每个 Corner Case 都更差。

## Goldmont Plus：L2 同样形成隔离层

Celeron J4125 的 Split Lock 延迟高，却仍优于 Arrow Lake/Alder Lake。

![图 31：Goldmont Plus 跨核 Atomic Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/5d17be13a7bdcd71_31_figure.png)

和 Arrow Lake E-Core 一样，L2 Hit 不受影响；DRAM Bandwidth 显著下降，Latency 只略增，不过它的 Baseline DRAM Latency 本来就很差。

![图 32：Goldmont Plus Memory Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/27e6bd1e767ff59c_32_figure.png)

![图 33：Goldmont Plus Memory Bandwidth；L1D/L2 小差异也混入未降频导致的 Clock 变化](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/1cf797a92692d07c_33_figure.png)

![图 34：Goldmont Plus 两项 GB6 的下降，Asset Compression 很可能主要受低频影响](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/03a05d2ec40ab36d_34_figure.png)

Photo Filter 确实受损，却弱于 Arrow Lake、Zen 2、Zen 5。

## 现代处理器里的“Bus”究竟是什么

早期多处理器共享主板总线，拉住 Bus Pin 就能阻止其他 CPU 访存，保证 Atomic。现代 CPU 使用分布式、Non-blocking Interconnect，不再有同一个经典总线；`LOCK` Prefix 保留的是原子语义，不代表实现仍相同。

![图 35：Intel 文档对 `LOCK` 与历史 Shared Bus 的说明](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/b85973ff49d2260d_35_figure.jpg)

一种推测是 Intel 在 IDI（In-die Interconnect）Protocol 处理这类请求：P/E Core 通过 IDI 进入 Uncore/Ring。Goldmont Plus PMU 还把 Bus Lock 描述为送往 L2 Controller 的特殊请求，但其 L2 Hit 并未受影响。

Zen 2/5 连 Core-private L2 都受干扰，行为超出传统 Bus Lock。一种可能是退到 Infinity Fabric 层；Core-to-core Test 时 Data Fabric Coherent Station Counter 会增加，但增量不随同时测得的 L2 Hit Traffic 成比例，最多支持“控制路径参与”，还不足以确认实现。

![图 36：AMD Data Fabric/Coherent Station 相关观测](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/54a77e62e93b5796_36_figure.jpg)

Piledriver 又不符合这两类表现，甚至可能用 Cache Coherence 完成并让无关 Cache Access 继续。因而“Bus Lock”已不是良好微结构描述，各厂商更应明确它在哪一级串行化、影响哪些请求。

### 体系结构视角：同一 ISA 语义可以落成完全不同的内部协议

x86 只规定 Atomic 的可见结果，不规定 Core、L2 Controller、Ring、Data Fabric 如何协作。这里跨七代平台的差异正是 ISA 与 Microarchitecture 的边界：从软件语义无法推出锁住哪一级，更不能仅凭术语猜测 RTL。

## Linux 默认缓解：服务器合理，桌面可能过重

Linux 可 Trap Split Lock，并插入毫秒级 Delay，让违规行为变得“烦人”，同时保护其他任务 QoS。默认 Sysctl 下，单次延迟接近机械硬盘 Seek，对 CPU 是永恒；由于测试线程绝大多数时间被暂停，前述 Noisy-neighbor 也会消失。

![图 37：Linux 默认 Mitigation 下的 Split Lock Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/49cbfb60d3d40db5_37_figure.png)

Multi-user/Server 重视一致性，默认策略合理，可与 Fixed Lower Clock、Cache Partition、Memory Bandwidth Throttle 等 QoS 手段配合。

![图 38：Linux 检测/缓解 Split Lock 时的系统输出](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/c2ef93f5f8757c2b_38_figure.jpg)

Consumer 端争议更大：这个 Ping-pong 测试产生的 Lock Rate 远超正常应用，Split 版本更加极端。部分游戏长期存在 Split Lock，却未在 Windows 上造成可见系统崩塌；若同一游戏 Linux 仅 10 FPS、Windows 200 FPS，Mitigation 本身就成了用户问题。这里表达的是策略取舍，并非否认 Split Lock 的程序缺陷。

## 汇总：它不冻结核心，只在某个 Cache Level 后收费

Split Lock 不是 Global Interpreter Lock，不会让其他核心停止执行，也不会阻断所有内存访问。它从哪个层级开始影响、影响多重，都由平台实现决定。

![图 39：各平台 Split Lock 自身 Latency 汇总](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/55fde878675f6403_39_figure.png)

![图 40：各平台 Noisy-neighbor 性能影响汇总](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/2e84ba13342b455b_40_figure.png)

Piledriver 与 Alder Lake 最能保护邻居；Piledriver 还同时提供最低 Split Lock Latency。Zen 2/5 在这个人为 Corner Case 中最脆弱。程序应避免让 Atomic Operand 跨 Cache Line，硬件也仍有优化自身延迟与隔离影响的空间；OS 缓解则应由真实发生率和目标场景驱动。

## 补充平台与事件

Ryzen AI MAX+ 395（Strix Halo）的 Zen 5 Split Lock 比桌面 Zen 5 更慢。Coherent Station Counter 连 Intra-line、同 CCX Atomic 也会增加，可能只是收到 Line State Change Notification，不能据此确认它负责全部数据路径。

![图 41：Strix Halo Split Lock Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/21022000f045b42b_41_figure.jpg)

高性能移动版双 CCD Zen 4 的结果接近 Zen 2；数据由 Owen Hilyard 提供。

![图 42：移动 Zen 4 Split Lock Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/e63b621db90905d3_42_figure.jpg)

Arrow Lake E-Core 的 PMU 显示，参与 Split Lock 的 E-Core 几乎全周期 Block，其他 E-Core 约一半周期被 Block，可解释 L3/DRAM 约 50%退化，但仍解释不了 L2 为何安然无恙。

![图 43：在 E-Core 4、5 循环 Split Lock 时的 Bus-lock Blocking Counter](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/5d24ffa02f5a144a_43_figure.png)

为选择 GB6 两个代表项目，Arrow Lake Die-to-die Traffic 以 1 秒采样、挑选 Spike 粗略记录；它不是准确的平均 L3 Miss Traffic。

![图 44：Arrow Lake 多项 GB6 的粗略跨 Die Traffic，用于选取 Photo Filter 与 Asset Compression](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/x86_split_locks_wechat_article_zh/217d10e4b9626218_44_figure.png)

## 参考资料

- Intel/AMD Split Lock 与 Performance Monitoring 文档
- Linux Split Lock Detection/Mitigation
- Geekbench 6
- Chips and Cheese：Investigating Split Locks on x86-64
