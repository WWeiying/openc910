---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "tachyum_too_good_to_be_true_wechat_article_zh"
---

> 英文标题：Tachyum: Too Good to be True?
> 撰文：George Cozma、Chester Lam
> 首发：Chips and Cheese，2022 年 6 月 28 日
> 链接：https://chipsandcheese.com/p/tachyum-too-good-to-be-true

这篇文章评估的是 Tachyum 在 2018～2022 年早期披露的 Prodigy。文章发布后，Chips and Cheese 采访了 Tachyum，并明确说明其中几乎全部架构分析已被后续信息取代；新版应以《Tachyum’s Revised Prodigy Architecture》为准。本篇仍值得保留，因为它展示了如何审查一组同时跨越 CPU、HPC 和 AI 的激进产品承诺。

## 从 2017 年创立到多次延期

Tachyum 曾宣称一颗芯片既能超过 AMD 64 核 Milan，又能达到 Ponte Vecchio 级 SIMD，并在 AI 上超过 Nvidia H100。公司 2017 年 2 月成立，2018 年预计 2020 年量产；随后延至 2021 年，2021 年又因转 TSMC N5 延到 2022 年。当时最接近实体的是 FPGA 仿真，计划 2022 年第四季度送样、最快 2023 年中普及。

早期 Prodigy 经常拿 Intel Itanium 作参照。Itanium/IA-64 依赖编译器排 VLIW，通用高性能市场表现不佳；VLIW 在 DSP 等规则、专用场景更常见。下面所有判断都建立在当时公开信息之上。

## 方向预测与目标跟踪

文章假定 2022 早期方案沿用 2018 版“skewed-gshare-like”方向预测和 12 bit 全局历史。Gshare 用 PC 与全局历史（常为 XOR）索引共享饱和计数器，曾用于 Pentium 4、Athlon 64 等；相同存储预算下，现代 TAGE/感知器通常更准。

![图 1：早期 Prodigy 的 Gshare 预测器与现代方案比较](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/tachyum_too_good_to_be_true_wechat_article_zh/9257f10d55c9eb2d_01_figure.png)

其优势是误预测代价仅七周期，低于 Neoverse N1 的约 9～11 级和 Zen 3 常见 13 周期。浅流水也意味着每次错误浪费的在途工作较少。

目标跟踪仅 1024 项，甚至少于 Athlon 64 的 2048 和 NetBurst 的约 4096；只有 16 个分支可在后续无前端气泡。

![图 2：Prodigy 与多代 CPU 的 BTB 容量/速度档位](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/tachyum_too_good_to_be_true_wechat_article_zh/e78cfe049b14ce43_02_figure.jpg)

更关键的是，每条 L1I Cache Line 附带两个目标，BTB 与 L1I 耦合。它省掉独立查询，却意味着 L1I miss 时同时失去目标，无法让解耦预测器跨 miss 持续生成预取。早期 VLIW 编译器可提供分支提示，可能降低先进预测器的重要性；而更大 L1I 也可能扩大 BTB，文章当时无法确认。

## Frontend、Bundle 与所谓乱序

公开规格称四宽乱序，采访又称基于 VLIW。Hot Chips 2018 写“最高 8 个 RISC 风格微操作/cycle”，MPR 则称“四 Bundle、八宽”，通常每拍一个 Bundle。一种解释是每拍取四个 Bundle、每个最多拆两条；更保守的解释是每拍只拆一个、最多四条，材料存在冲突。

取回的 Bundle 进入 12 项 Queue。若每项最多八个微操作，理论上 96 项；但官方称平均每 Bundle 2.6 条，实际大约低于 32 条。相比 Skylake 每线程 25 项 Fetch Buffer 加 64 项 Micro-op Queue，其吸收停顿能力可能偏弱。

![图 3：Hot Chips 2018 的 Prodigy 前端](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/tachyum_too_good_to_be_true_wechat_article_zh/bc54525b671b2dcf_03_figure.png)

Tachyum 用 “poison bit” 描述低面积、低功耗乱序。文章推测它可能接近研究方案 iCFP：Cache miss 依赖指令移入 Slice Buffer，数据到达后重放，而不是传统 Scheduler 每周期检查所有候选项。

![图 4：iCFP 研究中与小型乱序核的性能/面积比较](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/tachyum_too_good_to_be_true_wechat_article_zh/d84a0259d8c4d333_04_figure.png)

合理实现只在数据返回时唤醒相应 Slice，不像 NetBurst 那样反复盲目 replay；但仍需大 Buffer 跟踪依赖。iCFP 未有已知量产先例，新机制可能隐藏研究未覆盖的缺陷。

![图 5：1996 年的 Trace Cache 研究提醒](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/tachyum_too_good_to_be_true_wechat_article_zh/b7b869f4cf0db1f6_05_figure.png)

Trace Cache 在论文阶段同样有吸引力，量产后却因容量利用率等问题受挫。更重要的是，当时 Tachyum 除 “poison bit” 外没有披露足以确认 iCFP 的 Buffer/Checkpoint，故这部分只能是候选解释。

![图 6：用 Trace 分析 Load 依赖以估计顺序核停顿](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/tachyum_too_good_to_be_true_wechat_article_zh/fcc39f1a872afaa5_06_figure.png)

图中通过修改 ChampSim Trace，把后续源寄存器与 Load 目的寄存器匹配来识别依赖。若没有 iCFP 类机制，仅靠 Non-blocking Load 的有效重排远不及大乱序核，现有二进制又未按顺序流水约束编译，L1D miss 会尤其致命。

### 体系结构视角：新机制必须说明正常路径与恢复路径

“Poison”只解释标记错误数据，不自动回答状态保存、依赖传播、精确异常、Replay 顺序和 Buffer 满后的反压。判断机制可行性，应逐项寻找公开状态或硅片事件；缺一条关键恢复链，就不能把概念等同完整乱序实现。

## 变宽的向量与重做的缓存

2018 版每拍 2×512 bit Vector FMA；当时所称 2022 版扩为 2×1024 bit，并把矩阵吞吐从 2×1024 扩为 2×2048 bit，单核 FPU 宽度超过当时通用 CPU。

![图 7：2018 Prodigy 与 Skylake-X 向量后端比较](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/tachyum_too_good_to_be_true_wechat_article_zh/4e7708ec479554d7_07_figure.png)

缓存也连续扩容：2018 年每核 L1I/L1D 仅 16 KB、L2 256 KB，64 核共享 32 MB L3；中间版本增至 32 KB、512 KB，核心和 L3 翻倍；2022 早期披露进一步到 64 KB L1、1 MB L2，并用闲置核 L2 形成类似 IBM Telum 的 Virtual L3。

Virtual L3 复用 SRAM，却需要动态决定 L2/L3 配额。Prodigy 每核仅 1 MB 可借用，远小于 Telum 的 32 MB；总缓存约 144 MB，也低于 Milan 的约 292 MB。巨大向量单元可能因此更依赖 DRAM。

## DRAM、I/O 与计算/带宽比

![图 8：早期披露的 DRAM 带宽；2 TB/s 带星号项依赖未说明的带宽放大](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/tachyum_too_good_to_be_true_wechat_article_zh/7aefb2785a3b7a4a_08_figure.png)

文章不把“Bandwidth Amplification Technology”计入结论，因为没有机制资料。即便按约 1 TB/s，Prodigy 的 FP64 计算/内存带宽比也明显偏高。

![图 9：Prodigy 与 CPU/GPU 的 FP64 FLOP/Byte 比较](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/tachyum_too_good_to_be_true_wechat_article_zh/fa29518220d7074a_09_figure.jpg)

程序必须依靠 Cache 高复用来利用向量，但缓存总量不大。2022 方案还去掉 HBM 和 Ethernet，改为统一 PCIe 5.0，并把 DDR 总线翻倍。

![图 10：2018 与 2022 的内存、I/O 配置变化](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/tachyum_too_good_to_be_true_wechat_article_zh/3aa54c7c866cd960_10_figure.jpg)

1024 bit DDR5-7200 理论约 921.6 GB/s，是预计 Genoa DDR5-4800 约 460.8 GB/s 的两倍，但仍低于 A64FX 约 1 TB/s HBM，且要喂更多算力。64 条 PCIe 5.0 对需要 18 块 PCIe SSD 的 Netflix 式 I/O 场景也可能不足。

## 950 W、500 mm² 与频率疑问

2018 目标为 N7、64 核、180 W、280 mm²、4 GHz 以上；粗略扩到 128 核即 360 W、560 mm²。2022 披露变为 N5、128 核、最高 5.7 GHz、950 W、约 500 mm²。

![图 11：不同 Prodigy SKU 的核心、频率与 TDP](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/tachyum_too_good_to_be_true_wechat_article_zh/d9a5ba5a385f15d4_11_figure.png)

950 W/500 mm² 平均接近 2 W/mm²，超过 H100 全 Die 约 0.875 W/mm²。SKU 数字还出现同 TDP 下核心数翻倍、同核心数较高频型号 TDP 反而减半等难以解释关系。公司说明这些是受 TDP 人为限制后的 Boost Clock；文章仍怀疑除一两个整数核外能否达到，更质疑双超宽向量全速的功耗与面积。

## 软件生态与旧 ISA 绑定

当时 GCC 优化计划称第四季度上游，LLVM 还没有公开提交。Bundle 与具体执行单元绑定也妨碍代际兼容：若下一代从两条 FMA 改三条，旧 Bundle 无法自然表达；若拆开重新调度，又失去 VLIW 简化优势。

![图 12：早期 Prodigy 的 Bundle/端口绑定](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/tachyum_too_good_to_be_true_wechat_article_zh/1ed2583be936f5c6_12_figure.png)

x86、Arm、RISC-V 二进制实际通过 QEMU 运行。文章引用的 Geekbench 对比显示，模拟平均损失接近 90% 单线程、超过 80% 多线程，SIMD 损失尤其大；它不是 Prodigy 硅片实测，而是说明二进制翻译风险。

## 当时的结论，以及今天应如何阅读

文章认为，在约 500 mm² 内同时覆盖通用 CPU、HPC 和 AI 的承诺难以成立。若定位类似 A64FX 的专用超算部件，双宽向量有潜在市场；“Universal Processor”则要同时解决面积、散热、Cache、带宽、工具链和应用生态。

Prodigy 最高约 45 TFLOP/s FP64、低于 1 TB/s，对应超过 50:1；MI250X 约 47.8 TFLOP/s、相近 SRAM、3.5 倍带宽，约 15:1；A64FX 约 3.4:1。这解释了为何单看峰值 FMA 不足以判断应用吞吐。

![图 13：Tachyum 当时公布的产品路线图](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/tachyum_too_good_to_be_true_wechat_article_zh/d29ba86b2b9e03fc_13_figure.png)

当时公司预计 2022 年第三季度后半流片、12 月送样、2023 年上半年量产，并规划 N3、PCIe 6.0/CXL 的 Prodigy 2 在 2024 年下半年送样。文章认为时间表对首次流片公司非常乐观，还会直接遇到 Grace-Hopper、MI300 及后继产品。

### 体系结构视角：把承诺拆成可证伪的链条

审查激进芯片时，应分别问：工艺和流水能否达到频率；端口和寄存器文件能否达到每拍吞吐；Cache/MLP/DRAM 能否供数；功耗密度能否散热；编译器和库能否生成有效代码。任何一环未成立，峰值乘法都会失去意义。

后续采访已经让这篇文章的具体架构假设过时，尤其 VLIW 和乱序组织不能再用于描述新版 Prodigy。它的历史价值，是保留当时公开证据下的质疑与验证方法，而不是作为当前产品规格。

## 参考资料

- Chips and Cheese：Tachyum: Too Good to be True?
- 后续更新：Tachyum’s Revised Prodigy Architecture
- Tachyum Hot Chips 2018、产品表和当时公开访谈
