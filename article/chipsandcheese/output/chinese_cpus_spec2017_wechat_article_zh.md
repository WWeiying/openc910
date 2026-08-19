# 用 SPEC CPU2017 比较龙芯与兆芯：IPC、ISA、预测和频率

> **文章来源**
>
> - 文章：*Running SPEC CPU2017 on Chinese CPUs, and More*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2024 年 10 月 19 日
> - 链接：https://chipsandcheese.com/p/running-spec-cpu2017-on-chinese-cpus

SPEC CPU2017 是 OEM 与 CPU 团队常用的源码 Benchmark。这里的结果标为 Estimated：技术上尽量满足同一次 `runcpu` 跑完整套件、单 File System 等要求，主要缺少正式提交要求的文档；统一使用 GCC 14.2.0 和 Bare-metal Linux。若发行版无包，就源码编译 GCC 或在 Debian Chroot 运行。x86-64 Flags 为 `-O3 -march=native -mtune=native -fomit-frame-pointer`，AArch64 为 `-O3 -mcpu=native -fomit-frame-pointer`，其他 ISA 采用相当的 Native Target。

重点为单线程 Rate、一个 Copy；只有 SMT 收益用两个 Copy 固定到同一核心的 Sibling Thread。因此不能与正式 SPEC 公布分数或不同 Compiler Flag 直接比较。

## 龙芯 3A6000：六宽 LA664 的 IPC 不差，绝对性能仍低

3A6000 是四核、2.5 GHz、支持 SMT 的 LoongArch64，LA664 六宽、256-bit Vector、乱序能力合理。龙芯官网在 2024 年 10 月仍将其定位 Notebook/Desktop，因此与客户端 CPU 比较；这类应用对单线程尤其敏感。

![图 1：3A6000 单线程 SPEC CPU2017 总分](chinese_cpus_spec2017_figures/01_figure.png)

*图 1：无法接近近代 AMD/Intel 客户端核心，甚至落后为密度优化的 E-Core。*

![图 2：3A6000 与客户端核心/核心数背景](chinese_cpus_spec2017_figures/02_figure.jpg)

*图 2：Meteor Lake 有八颗 Crestmont E-Core；3A6000 只有四颗较弱核心，产品级多线程也受核心数约束。*

![图 3：3A6000 的 SPEC Integer/FP 子项](chinese_cpus_spec2017_figures/03_figure.jpg)

*图 3：Integer 只有 520.omnetpp 接近 Crestmont；FP 的 538.imagick、521.wrf、549.fotonik3d 可胜 Crestmont，但后者在其他项拉开，总分仍高。*

SMT 让 Pipeline 各级获得更多显式并行度。

![图 4：3A6000 的两线程 SMT 增益](chinese_cpus_spec2017_figures/04_figure.jpg)

*图 4：总增益超过 20%，与 Zen 5 相近；Zen 4 FP 的 SMT 增益较低，可能因单线程已更 Core-bound。*

![图 5：两条 3A6000 SMT 对一条 AMD 大核](chinese_cpus_spec2017_figures/05_figure.jpg)

*图 5：两线程仍不及当代 AMD 单线程。首代 SMT 实现本身表现不错，但不能弥补频率与核心数。*

环境准备也很困难：SPEC Toolset 与 GCC 都需源码编译，使用八个 Hardware Thread 编译 GCC 会崩溃，固定两核才完成且耗时很长。这个失败是软件/平台稳定性观察，不属于一次有效 CPU 性能结果。

## 3A5000：同为 2.5 GHz，四宽 LA464 落在低功耗旧核心区间

![图 6：3A5000 单线程 SPEC 总分](chinese_cpus_spec2017_figures/06_figure.png)

*图 6：位于 Celeron J4125 与 Bulldozer FX-8150 之间；后者 Integer/FP 分别高 19.5%/7.3%，约领先一代。*

![图 7：3A5000 Integer 子项对 Skylake/E-Core](chinese_cpus_spec2017_figures/07_figure.png)

*图 7：两代龙芯都不及 2015 Skylake；“接近初代 Ryzen”的宣传无法由这些数据支持。exchange2、x264 等高 IPC 项差尤其大。*

![图 8：3A5000 FP 子项](chinese_cpus_spec2017_figures/08_figure.png)

*图 8：浮点套件也呈相同整体格局。*

### 体系结构视角：SPEC 是“Compiler+ISA+Microarchitecture+System”的共同结果

源码由 GCC 针对不同 ISA 生成，Instruction Count 包含 ISA 表达力和 Backend Codegen；IPC 是核心执行这批指令的效率；频率再把周期换成时间。Cache/DRAM、OS 与 Chroot 也会参与。只有把四层拆开，才知道该改指令扩展、Compiler Pattern、预测器还是时钟路径。

## Instruction Count：LoongArch64 平均多约一成

![图 9：SPEC Integer 的 Retired Instruction 差](chinese_cpus_spec2017_figures/09_figure.png)

*图 9：Geomean 中 x86-64 比 AArch64 多约 1.17%；LoongArch64 比 x86-64 多 10.6%。*

![图 10：SPEC FP 的 Retired Instruction 差](chinese_cpus_spec2017_figures/10_figure.png)

*图 10：LoongArch64 比 x86-64 多 11.4%，与 AArch64 的 Geomean 却在 1% 内；549.fotonik3d/554.roms 分别多 77.1%/78%，可能是 ISA 难表达，也可能 GCC Codegen 特别差，不能只怪 ISA。*

![图 11：3A5000/6000 的 SPEC IPC](chinese_cpus_spec2017_figures/11_figure.jpg)

*图 11：两代 IPC 很有竞争力，但要执行更多指令，2.5 GHz 的频率又低，无法变成等比例性能。*

Zen 1 数据来自 Oracle `VM.Standard.E2.4`。该 Cloud Core 似乎被永久静态划分为双线程，即使 Sibling Idle，单线程也只能看到一半 ROB/Register Capacity；其他 Cloud 未见此现象，但它支持 PMU，只能作为有明确限制的最佳可用对照。

![图 12：受 Cloud 2T 分区影响的 Zen 1 IPC](chinese_cpus_spec2017_figures/12_figure.jpg)

*图 12：3A6000 某些项 IPC 很高。538.imagick 即便 IPC 更高，Core i5-6600K 仍快 94%，显示 Instruction Count 与频率的共同影响。*

## Branch Prediction：3A6000 已追到 Skylake 量级

![图 13：SPEC Integer Branch Accuracy](chinese_cpus_spec2017_figures/13_figure.jpg)

*图 13：3A6000 略高于 Skylake，较 3A5000 是明显进步。*

![图 14：SPEC FP Branch Accuracy](chinese_cpus_spec2017_figures/14_figure.png)

*图 14：整体也达到 2015 Intel 架构量级，双 SMT Thread 只小幅下降，支持 Predictor Storage 较充足的判断；具体结构/容量不能由准确率唯一反推。*

## 兆芯 KX-6640MA：小乱序核心的合理位置

KX-6640MA 为四核 2.6 GHz x86-64，“陆家嘴”是两宽、低 Reordering Capacity 的 OoO Core。

![图 15：KX-6640MA SPEC 总分](chinese_cpus_spec2017_figures/15_figure.png)

*图 15：略低于 Goldmont Plus，与 Cortex-A73 相当或略高；两者都明显快于两宽 In-order Cortex-A55，说明小乱序窗口仍很有价值。*

![图 16：兆芯 Integer 子项](chinese_cpus_spec2017_figures/16_figure.png)

*图 16：Goldmont Plus 因更大窗口常胜；A73 虽有更多 Reordering 和独特 OoO Retirement，兆芯凭更高频率可领先。*

![图 17：兆芯 FP 子项](chinese_cpus_spec2017_figures/17_figure.png)

*图 17：Cortex-A73 在 FP 多项反超。KX-6640MA 属于低功耗低性能档，而不是桌面大核。*

## 结语与可比性

SPEC 不包含 libx264 那样按 ISA 手写 Assembly 的库优化，525.x264 也不会调用那些函数；这里又强调单线程，而早期文章用同核心数多线程，因此视角不同，整体结论却一致：LA664 的 IPC 与 Predictor 有实质进步，但频率、Instruction Count 和四核规模让 3A6000 仍落后旧桌面核心；兆芯则处于 Atom/A73 一档。

不能从一套 Estimated SPEC 推断所有桌面体验；也不能用“高 IPC”或“高频率”单项宣称竞争力。后续若要复现，应保留 GCC 14.2.0、Native Flags、Bare-metal/Chroot、一个 Rate Copy 与 CPU Affinity。

## 参考资料

- Chester Lam, *Running SPEC CPU2017 on Chinese CPUs, and More*, Chips and Cheese, 2024-10-19
- SPEC CPU2017 Run and Reporting Rules
- GCC 14.2.0；LoongArch64/x86-64/AArch64 Native Target
