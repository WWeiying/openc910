---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "intel_golden_cove_cache_wechat_article_zh"
---

> 英文标题：Going Armchair Quarterback on Golden Cove’s Caches<br>
> 撰文：Chester Lam<br>
> 首发：Chips and Cheese，2022 年 2 月 11 日<br>
> 原始链接：https://chipsandcheese.com/p/going-armchair-quarterback-on-golden-coves-caches

处理器频率的进步远快于 DRAM，缓存层级越来越像核心性能的第二套微架构。Golden Cove 选择了高延迟、高带宽路线：48 KB、5 周期 L1D，1.25 MB、约 15 周期 L2，以及容量很大却延迟偏高的共享 L3。还能怎么改？

这里不是流片结果，而是 ChampSim 假设实验：先搭出接近 Golden Cove 的基线，再单独修改缓存容量、延迟和相联度。每条 trace 只运行 10 亿条指令，不等于完整 benchmark；总计 214 条，包括 Qualcomm 为 Value Prediction 竞赛提供、应用身份被混淆的 trace，Jiménez 教授提供的 SPEC2006/2017 trace，以及 Chips and Cheese 自建的 7-Zip、Geekbench 4、libx264、Y-Cruncher、Cinebench R15。结果适合比较机制，不适合变成真实产品分数。

## L1D：多数访问更在意 1 个周期，而不是多 16 KB

### 32 KB、4 周期

![图 1：Golden Cove 48 KB/5 周期 L1D 与 32 KB/4 周期假设配置](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/3a33075acd8c37e8_01_figure.png)

把 L1D 改成类似 Skylake 的 32 KB、4 周期是现实可想象的配置：Skylake 在较旧工艺仍可超过 5 GHz，Zen 3 的 32 KB/4 周期也能高频运行。

![图 2：32 KB/4 周期相对基线的逐 trace IPC 变化](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/3df35510e00c634b_02_figure.png)

214 条中有 204 条由更小、更快的 L1D 获胜。

![图 3：两种 L1D 的命中率对比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/46536548057fd01d_03_figure.png)

绝大多数数据访问本来就命中 32 KB L1D，容量扩大 1.5 倍带来的命中率增益不足以抵消每次访问多 1 周期。模拟支持“若能维持带宽和频率，Golden Cove 应优先降低 L1D 延迟”的意见。

### Phenom 风格：64 KB、3 周期、2-way

![图 4：Phenom 风格 L1D 与 Golden Cove 基线参数](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/153bdcbb78a3ed4d_04_figure.png)

Phenom 曾用更大、更快但低相联、低带宽的 L1D。假设现代工艺能让 64 KB、3 周期、2-way 配置跑到 Golden Cove 频率，可以检验更激进的延迟路线。

![图 5：Phenom 风格 L1D 的 IPC 结果](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/e36b91e8eea63b18_05_figure.png)

它在 207/214 条 trace 获胜，通常比 32 KB/4 周期进一步提升。

![图 6：少数 trace 的严重负收益](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/36a254a857df63fd_06_figure.png)

最大两个失败来自用途未知的 Qualcomm trace；SPEC2006 `410.bwaves` 两条分别下降 9.18% 和 6.86%，命中率仅下降不到 2%，MPKI 却从 2.03 增至 3.03。

![图 7：64 KB 与 48 KB L1D 命中率](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/27ded0a6c5e8a569_07_figure.png)

64 KB 并没有稳定胜过 48 KB，罪魁祸首是 2-way 相联：热点地址更容易映射到同一 set，冲突 miss 抵消容量优势。

![图 8：L1D 配置的容量、相联度、延迟和表现汇总](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/ef7b0d24ab3b574b_08_figure.png)

64 KB 需要多 33% data array，却未稳定减少 L2 流量；但每次只比较 2 个 tag，也可能比 Golden Cove 的 12-way 更省查找能耗。最大未知是 5 GHz 以上能否实现 3 周期，以及 3 load+2 store/cycle 的高带宽是否允许这种组织。

### 体系结构视角：L1D 延迟牵动整条依赖链

L1D load-to-use latency 会直接串入 `load → ALU → address → next load` 依赖链，乱序窗口无法并行化真正的串行指针追踪。因此 1 周期变化会作用于大量命中访问；L1 容量增加只帮助原本会 miss 的少数访问。相联度降低则引入工作集无关的映射冲突，形成少量但很重的长尾。

真实实现还要检查 bank 冲突、AGU 到 data array 的时序、store forwarding 和多端口面积。ChampSim 的容量/延迟替换没有覆盖所有这些物理代价。

## L2：容量比少 3 个周期更值钱

### Zen 风格：512 KB、12 周期

![图 9：Golden Cove 1.25 MB/15 周期与 Zen 风格 512 KB/12 周期](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/82257e28858afbbb_09_figure.png)

![图 10：小而快 L2 的逐 trace IPC](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/6b308e9e1acd5b46_10_figure.png)

结果是否定的：115/214 条 trace 变慢。容量扩大约 2.5 倍带来的命中率收益足以覆盖 3 周期惩罚。

![图 11：两种 L2 的命中率](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/d65de07c4dbd1a83_11_figure.png)

![图 12：两种 L2 的 miss per instruction](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/b9c8b9b07157a701_12_figure.png)

程序访问 L1D 的频率远高于 L2，L2 延迟只作用于 L1 miss；而 Golden Cove L2 miss 又要进入高延迟 L3，比 Zen 上的代价更大，因此避免 miss 更重要。

![图 13：小 L2 结果分布，少数未知 Qualcomm trace 形成极端负值](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/3216fa729032a052_13_figure.jpg)

其中几条 trace 的 L2 命中率从 90% 以上跌至约 50%，显著拉低平均数，且应用身份未知。

![图 14：去掉极端值后的结果分布](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/86c3b18a7d9c02ce_14_figure.jpg)

其余 trace 中确有不少受益于 12 周期，但收益更小、数量也更少。Golden Cove 的大 L2 能把核心隔离在高延迟 L3 之外，是缓存层级中的亮点。

### Willow Cove 风格：20-way、14 周期

![图 15：Willow Cove 与 Golden Cove L2 参数](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/d750e41a82e105be_15_figure.png)

![图 16：20-way、14 周期 L2 的 IPC 增益](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/7cc82d6abcaabc02_16_figure.png)

它几乎全面小幅领先，但幅度很小。

![图 17：提高相联度后的 L2 命中率](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/240970b28edb7559_17_figure.png)

![图 18：提高相联度后的 L2 MPKI](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/9fc6b911016d6666_18_figure.png)

命中率和 MPKI 都只略变。20-way 意味着每次访问最多比较 20 个 tag；L2 虽不如 L1 热，却仍频繁访问。若这套组织让 boost 从 Golden Cove 的 5.2—5.5 GHz 回退到 Willow Cove 的约 5 GHz，微小 IPC 增益不值。更合理的理解是 Golden Cove 用少量命中率和 1 周期换取频率、功耗与可实现性。

## L3：低延迟比无限加容量更普适

### 借用 Zen 3 风格 L3

![图 19：Golden Cove 基线与 Zen 3 风格 L3](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/1009b3edb0dc61ec_19_figure.png)

Zen 自第一代起使用与核心频率紧密耦合的低延迟 L3；Intel 从 Haswell 起让 ring/L3 使用独立 uncore 频率，以免 iGPU 需要缓存带宽时迫使核心也高频运行。

![图 20：更大、更快、更高相联 L3 的 IPC 变化](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/ac4b8a93cca83d6d_20_figure.png)

这一配置全面获胜。SPEC2006 `libquantum` 因小幅容量增加得到异常大的命中率收益；Geekbench 4 HTML5 DOM 完全放得下两种 L3，仍提升 5.51%，可归因于延迟。多数 trace 则同时受益于略高命中率和更低延迟。

![图 21：Zen 3 风格 L3 的结果分布](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/61821f7a60b5e48a_21_figure.jpg)

模拟意见是降低 L3 延迟，甚至考虑回到 Sandy Bridge 那样让 ring/L3 贴近核心时钟；代价可能是 iGPU 轻负载功耗，或需要把 GPU 缓存与 CPU L3 分开。这是设计建议，不是对 Golden Cove RTL 的确认。

### 90 MB 堆叠 SRAM

![图 22：Intel 早期 128 MB eDRAM 与 AMD 3D V-Cache 的背景](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/896c089608c62105_22_figure.jpg)

![图 23：假设 90 MB、略高延迟 L3 的平均 IPC](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/4e41512b0b4d621f_23_figure.png)

平均值上升，但分布极端：许多 trace 无收益或略退化，少数 trace 因容量命中而“被修好”。SPEC2006 `leslie3d`、`libquantum` 分别提升 45% 和 93%，SPEC2017 `lbm` 提升 70%，`omnetpp`、`cactuBSSN` 约 20%。

![图 24：90 MB L3 的 hitrate/IPC 关系](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/7dbb9872d3f200e2_24_figure.png)

![图 25：90 MB L3 的逐 trace 分布](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/ba2d8ccfc115c494_25_figure.jpg)

111/214 条 trace 反而因更高 L3 延迟损失 IPC。2022 年时 3D 堆叠成本高、产品覆盖有限，因此这是一种面向特定大工作集的专用方案，不适合作为通用 Golden Cove 的无条件替代。

### 体系结构视角：Cache 容量收益具有门槛性，延迟成本却普遍存在

容量只有在工作集从 miss 变成 hit 时才产生跳变收益；若工作集本来就放得下，更多 SRAM 不做贡献。更高命中延迟却会施加到每次命中，因此出现“少数应用巨幅提升、更多应用略退化”的双峰分布。评估大缓存应看逐 workload 分布、MPKI 和 tail latency，不能只看算术平均。

## 整套替换：Zen 3 与 M1 Max

### Golden Cove 核心配 Zen 3 缓存

![图 26：两套完整缓存层级参数](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/e8a461cc07b5c01e_26_figure.jpg)

![图 27：Zen 3 全套缓存带来的 IPC 变化](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/718a160da032cb7a_27_figure.png)

多数情况下，低延迟 L1D/L3 的收益超过 L2 从 1.25 MB 缩到 512 KB 的损失，但结果不统一。

![图 28：IPC 变化与 L2 miss 增量呈负相关](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/befa22e5d36f15a6_28_figure.png)

Geekbench 4 HTML5 DOM 喜欢大 L2：L2 MPKI 从 0.79 增至 2.33，IPC 下降 4.04%。SPEC2006 `mcf` 更敏感于 L3 延迟；SPEC2017 `lbm` 的 L2 miss 几乎不变，超过 40% 的增益主要来自 L3。若必须二选一，模拟更支持低延迟、足够大的 L3，而不是只扩大中间层 L2；这仍取决于目标负载。

### Golden Cove 核心配 M1 Max 缓存

![图 29：Golden Cove 与 Apple M1 Max 缓存参数](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/29c985a3a46dafbc_29_figure.jpg)

这完全不现实：M1 的频率目标和使用场景不同。但它能显示缓存本身的性能上限。

![图 30：M1 Max 缓存配置的逐 trace IPC](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/110c80d85ad41375_30_figure.png)

205/214 条 trace 提升，约一半提升超过 10%，仅缓存层级就接近一次代际 IPC 增长。

![图 31：M1 大 L1 带来的命中率优势](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/93ad5f417a6d14d5_31_figure.png)

M1 的 192 KB L1I + 128 KB L1D 合计 320 KB，甚至超过 Nehalem 到 Skylake 的 256 KB L2；L1D 仍为 3 周期，像一个命中率更好的 Phenom L1D。

![图 32：M1 Max 与 Golden Cove L2 的 miss per instruction](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/114f4a6dcb8b3322_32_figure.png)

M1 的 L2 容量接近某些桌面 L3、延迟接近 Gracemont L2，更像 CPU cluster 的末级缓存；128 KB L1D 和大而快 L2 让它不需要 Golden Cove 式中间层。48 MB System Level Cache 靠近内存控制器，延迟较高，更像为大 iGPU 降低带宽需求，而非 CPU 低延迟缓存。

Apple 可在先进工艺上围绕较窄目标优化；Golden Cove 则要兼顾 5 GHz 以上桌面单线程、高核数互连和低功耗笔记本。15 周期 L2 在 5.2 GHz 是 2.94 ns，在 3.2 GHz 仍要 4.68 ns，因为流水线级数不会随降频减少；为高频设计的核心在低频下未必仍是最佳纳秒延迟。

AnandTech SPECint2017 中 Golden Cove 单核仍比 M1 Max 高 8.6%。如果 Intel 用 M1 Max 式低频设计而落后 Ryzen 9 5950X，就不符合桌面市场目标。M1 风格缓存或许更值得 Gracemont 这类低频核心借鉴。

## 结论与模拟边界

![图 33：Alder Lake 与 Sandy Bridge-E/客户端的 L3 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/4617866d8973f53d_33_figure.png)

最现实的改进是降低 L3 延迟。Sandy Bridge 客户端曾做到约 29—30 周期，连更多 ring stop、频率更低的 Sandy Bridge-E 都低于 Alder Lake。代价是 iGPU 访问时的能效，但桌面 CPU 性能可能更重视这几个百分点。

其次是考虑回到 32 KB/4 周期 L1D，但 Golden Cove 每周期 3 load+2 store 的高带宽可能正是 5 周期的根因。扩大到 48 KB 和 12-way，或许是在延迟已确定后利用这 5 周期换更多容量。

![图 34：ChampSim 基线的核心、缓存与内存参数](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_golden_cove_cache_wechat_article_zh/a12a9c2dd8c1ffa0_34_figure.png)

图 34 给出模拟配置。它尽量对齐 Golden Cove，但 trace 只运行 10 亿指令，大量 Qualcomm trace 不知道应用来源，SPEC 又受编译参数影响；自建 trace 数量也有限。因此“204/214”“205/214”等是该 trace 集上的模拟结果，不是任何 CPU 产品的普适胜率。

总体上，Golden Cove 的大 L2是正确取舍；高延迟 L3最值得改进；巨大堆叠缓存只对特定大工作集产生跳跃式收益；M1 缓存展示了低频、窄目标设计的另一种上限。缓存优化没有单一答案，物理频率、端口、能耗和目标软件必须一起决定。
