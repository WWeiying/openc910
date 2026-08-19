# SPEC CPU2026：新一代 CPU 基准到底在测什么

> 英文标题：Evaluating SPEC CPU2026
> 撰文：Chester Lam
> 首发：Chips and Cheese，2026 年 5 月 23 日
> 链接：https://chipsandcheese.com/p/evaluating-spec-cpu2026

SPEC CPU 从 CPU2000 到 CPU2017 一直是工业界标准工具：Intel 用它展示 Pentium 4，Samsung 用 Trace 调 Mongoose，Intel 也用 CPU2017 估算 Lion Cove。CPU2026 将 Workload 从 43 增至 52 个，单项源代码 KLOC 普遍增加，希望在保持跨平台可移植性的同时现代化。

![图 1：SPEC CPU2026 工作负载与源代码规模](spec_cpu2026_evaluation_figures/01_figure.jpg)

本文关心硬件而非 Compiler 竞赛，所有 Linux 系统使用 GCC 14.2.0、`-O3` 和 Native Architecture/Tuning。GCC 15.2.0 因多项问题未采用。这一统一设置提高可比性，却不是 SPEC 官方提交所允许的全部优化空间。

## Score 与参照系统

SPEC Score 是相对 Reference System 的 Speedup Ratio。CPU2026 把 Ampere eMAG 8180 定为 1.0。

![图 2：CPU2026 与历代 Reference System](spec_cpu2026_evaluation_figures/02_figure.png)

eMAG 比 CPU2017 的 Sun Fire V490 快，却仍远落后现代核心，也并非广泛部署平台。让多数机器得到“大数字”本可把现代参照定为 1000；Geekbench 6 用常见 Core i7-12700 定为 2500，更易建立直觉。

![图 3：Zen 5 与 Lion Cove 的总分](spec_cpu2026_evaluation_figures/03_figure.png)

最新 Desktop 整数接近，Zen 5 浮点领先。Lion Cove 只跑 5.5 GHz，因为两颗可到 5.7 GHz 的 Core 在套件中 Crash；Sample 可能异常，稳定 5.7 GHz 应缩小差距。

![图 4：整数子项与 eMAG/FX-8350 参照](spec_cpu2026_evaluation_figures/04_figure.png)

现代核心尤其在 `706.stockfish` 彻底超过 eMAG，连十多年前 FX-8350 在几乎所有项都更合适作参照。

![图 5：浮点子项 Score](spec_cpu2026_evaluation_figures/05_figure.png)

Zen 5 的部分优势来自 GCC 生成 AVX-512。Intel SDE 只统计每项最后一次 Invocation，以节省时间；若一个 Binary 用多组 Input，多次行为并未全部覆盖。

![图 6：最后一次 Invocation 的 Vector Instruction Mix](spec_cpu2026_evaluation_figures/06_figure.png)

`706.stockfish`、`749.fotonik3d`、`765.roms` 有 AVX-512，其他多项也使用 128/256 bit Vector。

## IPC：CPU2026 更偏 Core Throughput

IPC 低通常意味着 Cache Miss、Mispredict 或特定 Hazard，高 IPC 更关注 Execution Latency/Port/Core Width；Performance 还取决于 Clock 和每条指令工作量。

![图 7：整数 IPC 分布](spec_cpu2026_evaluation_figures/07_figure.png)

CPU2026 Integer 在 Zen 5/Lion Cove 上更高、更集中，接近 Geekbench 6。

![图 8：浮点 IPC 分布](spec_cpu2026_evaluation_figures/08_figure.png)

Zen 5 的新 FP 分布更宽；Lion Cove 在两代都较宽。

![图 9：CPU2017 低 IPC 的 mcf/omnetpp 与 CPU2026](spec_cpu2026_evaluation_figures/09_figure.jpg)

CPU2017 的 `505.mcf`、`520.omnetpp` 因 Cache/Branch 很难；CPU2026 没有等价项，同名 `710.omnetpp` 行为完全不同。最低的 `721.gcc`、`723.llvm` 仍高于约 1.5 IPC，而 PC Game 常约 1 IPC。

原网页正文对 LLVM 子项还出现过 `725.llvm` 和 `721.llvm` 两种写法，但相关图表均标为 `723.llvm`；下文按图表口径使用 `723.llvm`，并保留这处来源文字差异。

超过半数 Integer 接近或超过 3 IPC；`750.sealcrypto` 在 Zen 5、Lion Cove、Skymont 都最高。

![图 10：浮点 Workload 的 IPC 与 Memory 压力](spec_cpu2026_evaluation_figures/10_figure.jpg)

FP 多在 2 IPC 以上。`749.fotonik3d`、`765.roms` 仍压 DRAM；旧 `538.imagick` 的极高 IPC 没有直接替代。

### 体系结构视角：Benchmark Coverage 也是一种设计取舍

高 IPC 套件更能区分 Width、Port 和 Vector，低 IPC 套件更能区分 BPU、Cache/TLB 与 Latency Hiding。平均分若偏向一种行为，会奖励相应设计。套件更新不应只追求“更新代码”，还要维持微架构压力分布。

## Top-down：六/八宽 Slot 丢在哪里

Rename/Allocate 通常是所有 Micro-op 必经的最窄级。Slot 分为 Retiring、Backend Bound、Frontend Bound、Bad Speculation。

![图 11：CPU2026 Integer 的 Top-down 分解](spec_cpu2026_evaluation_figures/11_figure.png)

相对 CPU2017，Retiring 普遍上升。`723.llvm`、`721.gcc` 主要 Frontend Latency-bound：Branch 多且偶有 Mispredict；`750.sealcrypto` 几乎无 Branch，前后端都能直线推进。

![图 12：CPU2017 FP Top-down](spec_cpu2026_evaluation_figures/12_figure.png)

![图 13：CPU2026 FP Top-down](spec_cpu2026_evaluation_figures/13_figure.png)

FP 继续以 Core Throughput 为主，Branch 少且可预测。`fotonik3d/roms` 在两核上严重 Backend Memory-bound，多数其他为 Core-bound。

![图 14：709.cactus 在 Zen 5/Lion Cove 的不同瓶颈](spec_cpu2026_evaluation_figures/14_figure.png)

Zen 5 在 `709.cactus` Frontend Bandwidth-bound，八宽 Rename 收不到足够 Uop；Lion Cove Frontend 轻松，却卡 Backend，最终也未领先。

## Branch Prediction：总体比 CPU2017 轻

CPU2017 的 `505.mcf`、`541.leela`、`557.xz` 对 Zen 5 仍有高 MPKI。

![图 15：CPU2017 Integer Branch MPKI](spec_cpu2026_evaluation_figures/15_figure.png)

使用 MPKI 而非 Accuracy，因为 Branch 很少时准确率差也未必影响大量指令。

![图 16：CPU2026 Integer Branch MPKI](spec_cpu2026_evaluation_figures/16_figure.png)

`723.llvm` 仍中等困难，却低于 `557.xz`，更远低于 mcf/leela。预测压力降低是 IPC 上升原因之一。

![图 17：CPU2017 FP Branch MPKI](spec_cpu2026_evaluation_figures/17_figure.png)

旧 FP 普遍容易，`526.blender` 有 Bad Speculation，却不及 Integer 难项。

![图 18：CPU2026 FP Branch MPKI](spec_cpu2026_evaluation_figures/18_figure.png)

`731.astcenc` 成为两套中最大预测挑战，仍不及 CPU2017 mcf，至少保留一项 Unpredictable Control Flow。

## Code Footprint：新套件更有变化

AMD 近代核心偏向把 Hot Code 放在高优化 Op Cache。CPU2026 Integer 多项 Coverage 低于 80%，KLOC 增大在部分项目确实对应更差 Locality；但 Zen 5 多数时间仍走 Op Cache。

![图 19：Zen 5 Integer Op-cache Coverage](spec_cpu2026_evaluation_figures/19_figure.png)

Coverage 低于 90% 的项目大多也有显著 L1I Miss。32 KB L1I 从 Zen 2 沿用至今，对 6K Op Cache 之外扩展有限；1 MB L2 接住大多数，只有 GCC/LLVM 编译明显 Miss L2，可能降低 IPC。

![图 20：Zen 5 Integer L1I/L2 Code Miss](spec_cpu2026_evaluation_figures/20_figure.png)

Lion Cove 用较小 5.2K Op Cache、64 KB L1I、八宽 Decode、3 MB L2。更大 L1I 普遍少 Miss，并几乎消除 `714.cpython/706.stockfish` 的 L2 Code Fetch；L2 再阻止多数访问 L3。

![图 21：Lion Cove Integer Instruction Hierarchy](spec_cpu2026_evaluation_figures/21_figure.jpg)

小 Loop 用 Loop Stream Detector 锁住 192 项 Micro-op Queue，Integer 中主要是 `750.sealcrypto`。

![图 22：Lion Cove Integer LSD Coverage](spec_cpu2026_evaluation_figures/22_figure.png)

新 FP 也出现更大 Code Footprint。`709.cactus` 在 Zen 5 主要靠 Decoder，解释 Frontend Bandwidth Bound；`749.fotonik3d` 虽溢出 Op Cache，却全被 L1I 接住。

![图 23：Zen 5 FP Frontend Coverage](spec_cpu2026_evaluation_figures/23_figure.png)

Lion Cove FP 多项在 Tiny Loop；`722.palm` 由 192 项 Queue 覆盖 40% 以上，出 Loop 后又很可能同时 Miss Op Cache 与 64 KB L1I。

![图 24：Lion Cove FP LSD 与 Code Miss](spec_cpu2026_evaluation_figures/24_figure.jpg)

没有 FP 项大到常态 Miss L2。

## Data Footprint：LLC 压力反而不足

Integer 多项 Miss 48 KB L1D，也有不少挑战 1 MB L2，但很少 Demand Miss LLC。

![图 25：Zen 5 Integer Data Cache MPKI](spec_cpu2026_evaluation_figures/25_figure.png)

`714.cpython/750.sealcrypto` 连 L1D 都少 Miss，与高 IPC 一致。

Lion Cove 192 KB L1.5D 很有价值：多项 L1D Miss 几乎全被它截住。36 MB LLC 对多数 Integer 足够。

![图 26：Lion Cove Integer L1.5/L2/L3 Behavior](spec_cpu2026_evaluation_figures/26_figure.png)

FP 中 `709.cactus` 刺穿 48 KB L1D，AMD L2/L3 处理良好；只有 `765.roms`、`749.fotonik3d` 有明显 LLC Miss。

![图 27：Zen 5 FP Data Cache MPKI](spec_cpu2026_evaluation_figures/27_figure.png)

Intel L3 MPKI 较低却不完全可比：Counter 只算 Retired Load，忽略被 Flush 的 Load；两家也只把对某 64 B Line 发起首次 Refill 的 Miss 计一次。

![图 28：Lion Cove FP LLC Miss 与 Fill Buffer Hit](spec_cpu2026_evaluation_figures/28_figure.png)

Intel 还能计 Fill Buffer Hit：Load 命中已有 Outstanding Miss，可能来自同 Line Spatial Locality 或 Prefetch 先发。`fotonik3d/roms` Fresh L3 Miss 少、FB Hit 多，可能大量匹配 Prefetch 发起的请求。

## 结语

CPU2026 的 Code Footprint 更丰富，更多项目走出 Op Cache/L1I；Branch Prediction 和 Data-side Footprint 的多样性却下降，现代 Core 可从 L2 顺畅 Streaming Code，整体更偏 Core Throughput。作者尤其遗憾 CPU2017 `520.omnetpp` 这种接近 Game 的低 IPC 行为消失。

因此 CPU2026 更像补充 CPU2017，而不是完美替代。看 Score 时还应记住 GCC 版本、Native Flag、SDE 只 Profiling 最后 Invocation、Lion Cove Sample 5.5 GHz 与 Counter 口径差异。单一 Aggregate Score 无法替代 Workload-level 分析。

## 参考资料

- SPEC CPU2026 / SPEC CPU2017
- Chips and Cheese：Evaluating SPEC CPU2026
- GCC 14.2.0、Intel SDE 与 AMD/Intel PMU
