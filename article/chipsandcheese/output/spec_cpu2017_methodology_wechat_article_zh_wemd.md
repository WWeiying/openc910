---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "spec_cpu2017_methodology_wechat_article_zh"
---

> 英文标题：Running SPEC CPU2017 at Chips and Cheese?
> 撰文：Chester Lam
> 首发：Chips and Cheese，2024 年 9 月 20 日
> 链接：https://chipsandcheese.com/p/running-spec-cpu2017-at-chips-and-cheese

Standard Performance Evaluation Corporation（SPEC）的测试套件长期被视为行业参照。OEM 常用 SPEC CPU2017 建立整机性能预期，CPU 厂商也会把它作为优化目标。Chips and Cheese 获得了 SPEC 免费新闻许可，这里记录第一版运行方法，以及从子项与性能计数器中看到的微架构特征。

这不是已经定型的测试规范。是否长期运行、编译参数是否调整都仍待观察：SPEC 以源码分发，Compiler 与 Flag 会改变结果；一次完整运行在 Ryzen 9 9950X 上也需数小时，在 Ampere Altra 上超过 11 小时。若还要更换编译器、重复采集 PMU，时间成本会迅速膨胀。

## 初始配置：优先可复现与跨厂商

方法大致参考 AnandTech，但使用 GCC 14.2.0，不采用 AOCC、ICC、armclang 等厂商编译器。厂商工具可能得到更高分，不过逐个调优 Flag 会削弱统一方法的可维护性。Clang 与 GCC 都遇到部分源码编译问题；SPEC 已记录 GCC 的多数 Workaround，剩余问题以 `-Wno-implicit-int`、`-Wno-error=implicit-int` 和 GFortran 的 `-std=legacy` 处理，而 Clang 的错误更难快速定位。

统一优化选项为：

```text
-O3 -fomit-frame-pointer -mcpu=native
```

不用 AnandTech 的 `-Ofast`，因为它让 FP Suite 某子项失败。AArch64 下 `-mcpu=native` 同时选择当前 ISA Feature 与 Tune；x86-64 下只做 Tune，未来仍需检查把 `-march` 与 `-mtune` 拆开后的变化。`-fomit-frame-pointer` 来自 AnandTech 方法，Zen 4 有无该项得分相同，Ampere Altra Integer 只高 1.2%，影响可忽略。

测试只跑一份 Rate，以观察单线程性能。SPEC 也允许多份 Rate 或使用多线程的 Speed Test，但第一版没有覆盖。除 Cloud 无法避免 Virtualization 外，均使用 Bare-metal Linux。未向 SPEC 提交审核，所以所有结果标为 Estimated。

![图 1：第一批 SPEC CPU2017 Estimated 总分；3950X 的 Linux 环境未支持 Boost](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/spec_cpu2017_methodology_wechat_article_zh/a159f2b0a6c2600f_01_figure.png)

![图 2：AnandTech 最后一篇 Ryzen 9 9950X 文章中的 SPEC 结果，作为外部参照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/spec_cpu2017_methodology_wechat_article_zh/9e6809fac19ee657_02_figure.png)

本轮 9950X 的 Integer、FP 分别高 8.6%、11.7%；以 7950X3D 的 Non-VCache CCD 近似 7950X，分别高 6.2%、7.3%。差异可能来自 Memory：9950X 使用 DDR5-6000，AnandTech 为 DDR5-5600；本地 Zen 4 为 DDR5-5600，而 AnandTech 旧文未标明对应配置。GCC 成熟度、Compiler 与 Flag 也会影响，不能把差值直接归因于 CPU。

SPEC 分数是相对一台 2006 年、2.1 GHz UltraSPARC IV+（Oracle Developer Studio 12.5）的速度倍数。现代消费级大核超过 10 倍，面积优化的 Crestmont 也超过 5 倍。

### 体系结构视角：源码基准首先考验方法一致性

Binary Benchmark 固定了编译选择，源码 Benchmark 则把 Compiler 也纳入系统。`native` 在两种 ISA 上语义不同，Memory Speed、Boost、Operating System 和 Virtualization 也会混入结果。要做跨平台比较，必须同时保存源码版本、Compiler/Library、完整 Flag、Input、Copies、频率与内存配置；只保留总分无法复现。

## 子项不是同一种负载

Integer 与 FP Suite 都是多个 Workload 的集合。相对 UltraSPARC 的加速幅度差异很大，Integer 的 `548.exchange2` 是突出高值；FP Outlier 更强，连单线程表现不佳的 FX-8150 也在 `503.bwaves` 中远超参照机。

![图 3：Integer Suite 各子项相对参考系统的速度比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/spec_cpu2017_methodology_wechat_article_zh/a83dd6d3ce5af41d_03_figure.png)

![图 4：Floating-point Suite 子项速度比，Outlier 更明显](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/spec_cpu2017_methodology_wechat_article_zh/175277382f55fb25_04_figure.png)

PMU 深挖集中于可用的最新 AMD Zen 5 与 Intel Redwood Cove，既代表现代设计，也可缩短一次耗时数小时的运行。

![图 5：Zen 5 与 Redwood Cove 的 Integer 子项 IPC](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/spec_cpu2017_methodology_wechat_article_zh/bf8a93715ac74086_05_figure.png)

Integer 中 `548.exchange2`、`525.x264`、`500.perlbench` IPC 很高；`505.mcf`、`520.omnetpp` 很低，两核的相对模式大致一致。

![图 6：FP 子项 IPC；538.imagick 很高，549.fotonik3d 很低](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/spec_cpu2017_methodology_wechat_article_zh/76655b73024df34b_06_figure.png)

## 低 IPC：omnetpp 与 mcf 并不是同一种慢

Top-down 在流水线最窄、后续 Burst 无法补回吞吐的位置归因 Lost Slot。Zen 5 的 `520.omnetpp` 主要被 Backend Memory Latency 限制；`505.mcf` 更复杂，Frontend Latency 最大，其他类别也都有贡献。

![图 7：Zen 5 的 505.mcf 与 520.omnetpp Top-down 分解](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/spec_cpu2017_methodology_wechat_article_zh/8dbe050d1cea2c7d_07_figure.png)

![图 8：Redwood Cove 的对应分解](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/spec_cpu2017_methodology_wechat_article_zh/7846054f1d83f12f_08_figure.png)

Meteor Lake 的 Cache/Memory Hierarchy Latency 较高，Redwood Cove 跑 `omnetpp` 的 Backend Memory 问题更重；`mcf` 也更 Memory-bound，同时因 Bad Speculation 损失更多。

`541.leela` 的 Predictor Accuracy 技术上更低，但 Branch 只占 16.47%；`505.mcf` 有 22.5%指令是 Branch，将 Mispredict 按全部指令归一化后尤其严峻。

![图 9：SPEC Integer 的 Branch Prediction Accuracy/MPKI](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/spec_cpu2017_methodology_wechat_article_zh/7187c762f0b35299_09_figure.png)

![图 10：Branch Density；xalancbmk 分支更多但准确率高，最终 IPC 尚可](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/spec_cpu2017_methodology_wechat_article_zh/8cb0061bbcbd119b_10_figure.png)

误预测还会造成 Frontend Latency：队列清空后，正确 Target 需要重新从相应 Cache Level 取回。好消息是 `mcf` Code Footprint 很温和，在 Zen 5 与 Redwood Cove 都基本装进 Micro-op Cache。

![图 11：Integer Suite 的 Micro-op Cache Coverage；Zen 5 在 leela、deepsjeng 仍超过 90%](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/spec_cpu2017_methodology_wechat_article_zh/14aa09dd76680033_11_figure.png)

### 深挖 505.mcf

Redwood Cove 的现象容易解释：高 Op-cache Hit 控制了前端 Latency/Bandwidth，但 Mispredict 把大量错误工作送入后端。Zen 5 即使从最快的 Op Cache 取指，Frontend Latency 仍很高，需要看更细事件。

![图 12：505.mcf 的 Instruction Cache Miss；L1I Miss 并非主要原因](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/spec_cpu2017_methodology_wechat_article_zh/72125106506fb5f5_12_figure.jpg)

Direct Branch 占绝大多数，Return 与 Indirect Branch 只是少数。

![图 13：505.mcf 的动态 Branch Type 组成](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/spec_cpu2017_methodology_wechat_article_zh/086be1250707ec1d_13_figure.png)

Zen 5 对 Return 与 Changing-target Indirect Branch 不能 Zero-bubble，但其 Indirect Predictor 使用次数竟超过 Retired Indirect Branch 两倍。

![图 14：Zen 5 的 BTB/Indirect Predictor Delay 事件](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/spec_cpu2017_methodology_wechat_article_zh/60b2d11beba7dc9c_14_figure.jpg)

Speculative Event 本就会高于 Retired Event：前面分支错误时，同一个 Indirect 可能再次预测。但超过 2 倍仍异常。连同 Return 与 L1 BTB Miss 的 Direct Branch，约有 72.8 次 Predictor Delay/千指令。一个合理推断是，这些延迟解释 Zen 5 较重的 Frontend Latency；同时它也可能让核心无法在错误分支前跑得太远，从而少向后端灌入 Wrong-path Work。这个因果尚未由 RTL 或定向实验确认。

Redwood Cove 的 Data Side 也更吃力，L1D 与 L1 DTLB Miss 都多。Intel 事件在 Retirement 计数，不含 Prefetch 或最终被 Flush 的错误路径访问。

![图 15：Redwood Cove 运行 505.mcf 时的数据 Cache 与 DTLB Miss](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/spec_cpu2017_methodology_wechat_article_zh/f8c0e2718fe0e9d6_15_figure.png)

多数 Miss 被 L2/L3 接住，但 1.97 L3 MPKI 仍因 DRAM 极高延迟贡献大部分 Memory-bound Delay。

![图 16：存在 Pending Cache Miss 时全部执行单元空闲的周期](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/spec_cpu2017_methodology_wechat_article_zh/4a8f63146da55984_16_figure.png)

Execution Stall 不一定等于性能损失：数据回来后，宽执行端可以 Burst 补回。只有 Queue 填满并在 Rename/Dispatch 形成不可追回的空 Slot，才与最终吞吐直接对应。

## 带宽：Integer 通常不高，fotonik3d 是例外

单核通常不逼近整机带宽。Integer 中最高的 `505.mcf` 也只有 8.77 GB/s，且写流量通常只是少数。

![图 17：Redwood Cove 单核运行 SPEC Integer 的读写 DRAM Bandwidth](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/spec_cpu2017_methodology_wechat_article_zh/c095b70326dadf9e_17_figure.png)

FP 大体相似，但 `549.fotonik3d` 与 `503.bwaves` 明显突出。

![图 18：SPEC FP 的读写 DRAM Bandwidth](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/spec_cpu2017_methodology_wechat_article_zh/f7d4bb1456306592_18_figure.png)

`bwaves` IPC 高，Backend Memory Stall 少，并没有被带宽卡住；`fotonik3d` 则读 21 GB/s、写 7.23 GB/s。作为参照，单个 Redwood Cove 以纯读 Pattern 测得 23.95 GB/s，以 Read-modify-write 测得 38.92 GB/s。`fotonik3d` 的“延迟受限”因此包含排队接近单核带宽上限的结果。

![图 19：Redwood Cove 的 FP Top-down 分解，fotonik3d 明显 Backend Memory-bound](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/spec_cpu2017_methodology_wechat_article_zh/5b2ed0594f50f8f5_19_figure.png)

FP Suite 整体比 Integer 更 Core-bound，更多 Slot 退休有用工作，更强调 Execution Latency/Throughput；Zen 5 模式类似，仍有少量 Frontend Latency。

![图 20：Zen 5 的 FP Top-down 分解](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/spec_cpu2017_methodology_wechat_article_zh/353ccaaf51613d38_20_figure.png)

`507.cactuBSSN` 是全套中唯一让 Zen 5 Op-cache Hit 低于 90%的项目，Redwood Cove 仅 58.98%。

![图 21：FP Suite 的 Micro-op Source](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/spec_cpu2017_methodology_wechat_article_zh/450e7f2626554f04_21_figure.png)

但两核在该项目几乎没有 Frontend Latency/Bandwidth 损失：Branch 只占 2.22%，准确率超过 99.9%，Predictor 能跑在 Fetch 前面并隐藏 Cache Miss。它与 `mcf` 的对照说明，大 Code Footprint 不必然比 Branchy Code 更糟。

### 体系结构视角：延迟、带宽与并行性必须一起解释

“Memory-bound”可能是一次无法并行的 DRAM Miss，也可能是大量请求把控制器推近带宽墙；两者的优化方向不同。应同时观察 MPKI、Outstanding Miss、平均延迟、字节/秒与 Rename Stall。类似地，Op-cache Hit 低也未必慢：只要控制流可预测，前端可提前取指并掩盖较低层延迟。

## 96 MB V-Cache 何时有用

Zen 4 的 7950X3D 可以在同一处理器上比较 32 MB 与 96 MB L3。AMD Demand Refill 包含由指令发起、但可能后来因误预测被 Flush 的访问；Intel Data-source Event 在 Retirement 计数，所以这里不能与上面的 Redwood Cove 图直接比较。

![图 22：Zen 4 Integer Suite 的 Demand Cache Refill](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/spec_cpu2017_methodology_wechat_article_zh/86ff3b4d4206fb63_22_figure.png)

很多 Integer 项 L1D Miss 已很低。`548.exchange2` 数据完全留在 L1D，Op-cache Hit 98.89%，因此达到 4.1 IPC。`502.gcc`、`505.mcf`、`520.omnetpp` 才更挑战 Cache Hierarchy。

![图 23：Zen 4 FP Suite 的 Demand Refill；fotonik3d、roms 的 L3 Miss 是极端例外](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/spec_cpu2017_methodology_wechat_article_zh/2222ea4b2d0b6c7c_23_figure.png)

FP 项常呈两极：32 MB L3 已覆盖，或连 96 MB 也难彻底覆盖。前者不能受益，后者 Hit 增幅又可能不足以抵消 V-Cache CCD 的降频。

![图 24：7950X3D 两个 CCD 的 SPEC FP IPC 与分数差异](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/spec_cpu2017_methodology_wechat_article_zh/962e4e8a34a6df08_24_figure.png)

`fotonik3d`、`roms` 因更高 L3 Hit 得到 17% IPC 提升，理论上应抵消频率差；实测分数仍低，暗示 V-Cache Core 在运行中没有维持最高频率，但这只是基于结果的推断。

Integer 对 V-Cache 更友好。`520.omnetpp` 的工作集几乎被 96 MB L3 容纳，IPC 提升 52%，足以压过频率劣势。

![图 25：7950X3D 两个 CCD 的 SPEC Integer 差异](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/spec_cpu2017_methodology_wechat_article_zh/04495b6c01363a4f_25_figure.png)

许多其他项目本已位于 L3 内，反而只承受低频；最终 Integer 总分两 CCD 近乎持平，对制造成本更高的 V-Cache Die 不是强表现。

## 结语

SPEC CPU2017 的优势是子项多样，Integer 更偏 Latency，FP 更偏 Throughput；分析 Subscore 能揭示核心强弱。局限也清楚：不少代码几乎完全装进现代 Micro-op Cache，很多数据装进 1 MB L2 或 32 MB L3；FP 又常在“极易缓存”和“强 DRAM 压力”之间两极化。

更现实的约束是时间。一项因 `-Ofast` 数小时后 Segfault 就会让整轮作废，完整 PMU 分析可占数天。因此，这批数字首先是可行性探索；只有同一方法能稳定覆盖广泛系统，才适合复用到后续对比。任何引用都应保留 Estimated 状态、单份 Rate、GCC 14.2.0、统一 Flag、Bare-metal/Cloud 边界与内存配置。

## 参考资料

- SPEC CPU2017
- GCC 14.2.0
- AnandTech SPEC CPU 测试方法
- Chips and Cheese：Running SPEC CPU2017 at Chips and Cheese?
