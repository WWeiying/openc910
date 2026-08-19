---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "geekbench6_evaluation_wechat_article_zh"
---

> 英文标题：Evaluating Geekbench 6
> 撰文：Chester Lam
> 首发：Chips and Cheese，2026 年 5 月 7 日
> 链接：https://chipsandcheese.com/p/evaluating-geekbench-6

应用需求差异巨大，任何总分都不可能代表所有软件。SPEC 以源码和跨平台为中心，Geekbench 自约 2010 年起更面向 Consumer，Binary Distribution、短 Runtime 和简单 Harness 方便普通用户。Primate Labs 创始人 John Poole 提供了 Geekbench 6 License，本文由此检查每个 Workload 真正在压什么。

![图 1：Geekbench 6 的消费级测试套件](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/geekbench6_evaluation_wechat_article_zh/8d7d88af3195dd40_01_figure.jpg)

## Binary 让 ISA 专用优化成为主角

Intel SDE 可用不同 ISA Target 精确统计指令。Granite Rapids Target 下，Background Blur、Object Detection、Structure from Motion 大量使用 AVX-512；Object Detection 与 Photo Library 还有 AMX，虽只占 0.2%和 0.02%动态指令。

![图 2：Granite Rapids Target 的 Instruction Mix](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/geekbench6_evaluation_wechat_article_zh/583982dfd2d656de_02_figure.png)

AMX 比例小、影响却大。改成无 AMX 的 Ice Lake-X Target，为同一工作量需要显著更多 AVX2/AVX-512；其他项目基本不变。

![图 3：Granite Rapids 与 Ice Lake-X 的动态指令数变化](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/geekbench6_evaluation_wechat_article_zh/a0588101354da82c_03_figure.png)

整个 Suite 都很 Vector-heavy。Text Processing、File Compression、Clang、PDF Renderer Vector 较少，其余大量 128/256 bit。

Haswell Target 无 AVX-512，三个重 AVX-512 项改用更多 AVX2，Object Detection 尤其被 256 bit 指令主导。

![图 4：Haswell AVX2 Target 的指令组成](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/geekbench6_evaluation_wechat_article_zh/38d240c15fa04799_04_figure.png)

Ivy Bridge 有 AVX 但 256 bit Math 主要限 FP，故大部分回到 128 bit SSE；256 bit 在多数项低于 1%，只有 Background Blur 大量使用。

![图 5：Ivy Bridge Target](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/geekbench6_evaluation_wechat_article_zh/9cd0387e3e7167d4_05_figure.png)

古老 Prescott x86-64 Base 也以 128 bit SSE 为主，分布竟接近 Ivy Bridge。

![图 6：Prescott Target](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/geekbench6_evaluation_wechat_article_zh/0de294288c7fd790_06_figure.png)

SPEC CPU2017 为 Portability 依赖 Compiler Auto-vectorization。GCC 14.2.0 针对 Zen 5 时，`549.fotonik3d/554.roms` 有大量 AVX-512，其他较少；Integer 只有 `525.x264/548.exchange2` 用一些 128 bit。

![图 7：SPEC CPU2017 的 Vector Instruction Mix](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/geekbench6_evaluation_wechat_article_zh/bbd87be1d7c27da1_07_figure.png)

### 体系结构视角：少量矩阵指令可以替代大量普通指令

Dynamic Instruction Share 不能直接表示时间或加速贡献。AMX 一条 Tile Operation 可完成大量 Multiply-accumulate，0.2%也可能重塑热点；反之，频繁 Scalar 控制指令可能只占少量 Cycle。分析应同时看指令数、Latency/Throughput、数据搬运和禁用扩展后的端到端差值。

## IPC：大多“喂得很饱”

Geekbench 6 多数在中高 IPC。Lion Cove/Zen 5 多项超过 2；Skymont IPC 常接近，却在 Clang、Asset Compression、Photo Library、Structure From Motion 出现 Glass-jaw。

![图 8：x86 核心的 Geekbench 6 IPC](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/geekbench6_evaluation_wechat_article_zh/e9fc1b7ccfbd459d_08_figure.png)

N1/N2 也相似。四宽 N1 多项超 2 已很高，五宽 N2 多项超 3。N1 Object Remover 较低可能来自弱 Vector；只有 Navigation 在所有核心都持续低 IPC。

![图 9：Neoverse N1/N2 IPC](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/geekbench6_evaluation_wechat_article_zh/88ecdc9896530430_09_figure.png)

SPEC CPU2017 分布更宽，Integer `505.mcf/520.omnetpp` 即使大核也很难。

![图 10：Geekbench 6 与 SPEC CPU2017 IPC 分布](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/geekbench6_evaluation_wechat_article_zh/870fd3b241851177_10_figure.png)

Geekbench 更接近 SPEC FP，但仍更集中；`549.fotonik3d` 是单核 DRAM Bandwidth 限制的低 IPC Outlier。

## Branch：Navigation 是真正例外

![图 11：各 Workload Branch MPKI](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/geekbench6_evaluation_wechat_article_zh/e8f73268e629287e_11_figure.png)

Navigation 远高于其他，Mispredict 很可能是低 IPC 首因；先进 Predictor 有帮助却不能解决，新核相对十年前小核 IPC 提升很少。

![图 12：Navigation 在多代 Core 上的 IPC/MPKI](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/geekbench6_evaluation_wechat_article_zh/cd340f5823328375_12_figure.png)

File Compression、Clang 中等困难，新 Predictor 在 Clang 更明显。

![图 13：Clang、File/Asset Compression 的 MPKI](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/geekbench6_evaluation_wechat_article_zh/045dbd6d94c0f69a_13_figure.png)

Asset Compression 对多数核不难，Piledriver 2.76、Jaguar 2.96 MPKI，Skymont 却异常 4.33，说明 Predictor 也会遇到特定 Alias/Pattern 退化，不能只按世代排序。

## Code Locality：Clang 几乎是唯一大 Footprint

Lion Cove 只有 Clang 明显溢出 5.2K Op Cache；PDF Renderer、HDR、Photo Filter 大量由 192 项 Loop Buffer 供应。它不提高超过八宽 Rename 的吞吐，却可关掉前端省电。

![图 14：Lion Cove LSD/Op-cache/Decode Coverage](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/geekbench6_evaluation_wechat_article_zh/0e6ed61f54b7f34b_14_figure.png)

Zen 5 有约 6K Op Cache，Clang 仍是唯一显著挑战，且多数时间仍不需 Decoder。这正适合 AMD，因为 Zen 5 Single-thread Decoder 比 Lion Cove 弱。

![图 15：Zen 5 Op-cache Coverage](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/geekbench6_evaluation_wechat_article_zh/0128eb017628aa22_15_figure.png)

## Data Side：Miss 多，但通常可预取、可被大 L2 接住

Lion Cove 多项有重 L1D Miss；3 MB L2 承担主要工作，192 KB L1.5D 偶尔几乎接住全部。只有 Object Remover 有很高 L2 Miss。

![图 16：Lion Cove Data Hierarchy MPKI](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/geekbench6_evaluation_wechat_article_zh/5b412b4c617e8d40_16_figure.png)

L3 Miss 看来很低，但 Counter 只算对 64 B Line 发起 Fresh Miss 的第一条 Retired Load。命中已有请求算 Fill Buffer Hit，未计。文章另在 CPU Tile Die-to-die Arbitration Queue 测流量，作为 L3 Miss/DRAM Bandwidth Proxy。

![图 17：Arrow Lake Tile-to-tile 流量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/geekbench6_evaluation_wechat_article_zh/5414916a50412696_17_figure.png)

许多项每秒跨 Die 数 GB，仍不及 SPEC `fotonik3d`。Photo Filter 虽只有 0.23 L3 MPKI，却流量最高，说明 Prefetcher 可能在 Load 前已发请求，用 Bandwidth 换 Latency。

![图 18：Lion Cove MPKI 与外部流量的反差](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/geekbench6_evaluation_wechat_article_zh/3cadda5b632026ea_18_figure.png)

AMD Event 计 Demand Refill，而非在 Retire 给 Load 标 Data Source；被 Mispredict Flush 的 Load 也可能产生 Refill，数值通常更高，不能直接与 Intel 对表。

![图 19：9800X3D Demand Cache Refill](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/geekbench6_evaluation_wechat_article_zh/c678ba3e1f3dae80_19_figure.png)

96 MB L3 几乎消除 Navigation LLC Miss，也改善 Object Remover。其他项因口径和 Miss 本就低，很难与 Arrow Lake 36 MB 比。Zen 5 的 1 MB L2 比 Lion Cove 3 MB 更常 Miss，但 AMD L3 更快、更大。

![图 20：9800X3D Memory Controller Traffic](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/geekbench6_evaluation_wechat_article_zh/5de87f9be391d29b_20_figure.png)

作者没调通 CCM Write Event，改用 UMC；iGPU 已关闭、I/O 很少，近似足够。9800X3D DRAM Traffic 通常低于 285K，可能来自更大 L3；Photo Filter、HTML5 Browser、Horizon Detection 都是高带宽且 Prefetch-friendly。

### 体系结构视角：低 MPKI 不等于不耗内存带宽

Prefetch 先发、同 Line 合并会让 Demand/Fresh Miss 数很小，外部流量仍很高。要判断“Cache 够不够”，需一起看 Demand MPKI、Fill Buffer Hit、Prefetch Request、Memory Controller Bytes 和 Average Latency。

## Score：2500 的含义

Geekbench 与 SPEC 都按 Reference Speedup。Geekbench 用 Dell Precision 3460/Core i7-12700 定 2500；SPEC CPU2017 用 2.1 GHz UltraSPARC-IV+ Sun Fire V490 定 1。SPEC 数学更直观，参照却太老；Geekbench 参照更现代。

![图 21：各核心相对 Geekbench 2500 Baseline](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/geekbench6_evaluation_wechat_article_zh/697c8ecf3aa79dde_21_figure.png)

i7-12700 P-Core 有强 Vector，而 Suite 又 Vector-heavy，因此 Baseline 很高。Skymont Vector 弱，常低于 2500；N1/N2 也因 Vector 和整体低目标落后。Score 不是纯“日常体感”，而是这组 Workload 权重后的加权结果。

## 结语

Geekbench 6 偏 Vector 与 Core Throughput，多数 Code Footprint 小、Branch 易预测、Data Access 可预取。Navigation 是 Branch-bound 例外，Clang 是 Op-cache Footprint 例外。

SPEC CPU2017 覆盖更广的 IPC/Memory/Branch 压力，但 Portability 让它较少直接使用 ISA-specific Vector。两套服务不同目的，不能互相替代。使用 Geekbench 总分比较时，应同时注明版本、ISA Binary、扩展路径、单/多核模式和平台频率，而不从一项总分外推所有应用。

## 参考资料

- Geekbench 6 / Primate Labs
- SPEC CPU2017
- Intel SDE、AMD/Intel PMU
- Chips and Cheese：Evaluating Geekbench 6
