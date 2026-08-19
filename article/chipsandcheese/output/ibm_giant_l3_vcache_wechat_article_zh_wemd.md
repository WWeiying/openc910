---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "ibm_giant_l3_vcache_wechat_article_zh"
---

> 英文标题：Do IBM’s Giant L3 and V-Cache Represent the Future?<br>
> 撰文：Chester Lam<br>
> 首发：Chips and Cheese，2021 年 9 月 29 日<br>
> 原始链接：https://chipsandcheese.com/p/do-ibms-giant-l3-and-v-cache-represent-the-future

IBM 在 Hot Chips 2021 展示 Telum 的 256 MB L3，引出了一个很自然的问题：巨大末级缓存会不会成为处理器的共同方向？AMD 也一直强调缓存，Zen 2 把 16 MB CCX 级缓存称为“GameCache”，3D V-Cache 又把 Zen 3 的 LLC 扩到 96 MB。

但消费级处理器为什么没有普遍采用数百 MB 缓存？下面用约 350 条指令轨迹，在接近 Zen 3 的核心模型上模拟 32 MB、96 MB 与 256 MB L3，观察容量收益和延迟代价如何竞争。

## 256 MB 并不免费

IBM 资料给出的 Telum 基础频率为 5 GHz 以上，256 MB L3 平均延迟约 12 ns；按 5 GHz 换算是 60 个周期。AMD Zen 3 优化指南给出的 32 MB L3 平均延迟是 46 周期。

![图 1：约 350 条轨迹中，256 MB/60 周期 L3 相对 32 MB/46 周期 L3 的 IPC 变化](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ibm_giant_l3_vcache_wechat_article_zh/67272f654a18b04d_01_figure.jpg)

部分轨迹在 256 MB 下获得巨大提升，更多轨迹则收益有限，甚至出现回退；最差的一批 IPC 下降约 10%。在近几代 Intel 与 AMD 单线程性能十分接近的背景下，10% 足以改变产品竞争力。

![图 2：IPC 变化与原 32 MB L3 命中率的关系](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ibm_giant_l3_vcache_wechat_article_zh/d14206307ef4525a_02_figure.jpg)

许多负载在 32 MB 时命中率已经很高，容量几乎没有改善空间，60 周期访问反而拖慢依赖链。另一些负载的工作集极大，即使容量扩大 8 倍，命中率提升仍不足以抵消 14 周期延迟差。

![图 3：IPC 变化与 L3 MPKI 改善的关系；只有 miss 明显减少时，大而慢的缓存才值得](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ibm_giant_l3_vcache_wechat_article_zh/b1fdcb9c317da90f_03_figure.png)

换言之，增大 L3 必须显著降低 miss rate，才能覆盖更高访问延迟；否则不仅浪费面积和功耗，还可能损失性能。

## 96 MB V-Cache 的两种延迟假设

测试时 AMD 尚未公布 3D V-Cache 的实际延迟，因此模拟两组边界：一组保持 32 MB L3 的 46 周期，代表 3D 堆叠与更短连线完全抵消容量增大的延迟；另一组设为 52 周期。后者增加 6 周期，与 AMD 从 8 MB 扩到 16 MB 时增加约 4 周期、从 16 MB 扩到 32 MB 时增加约 7 周期相近，是偏悲观的假设。

![图 4：96 MB、46 周期 L3 的理想情形，相对 32 MB 基线的 IPC 变化](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ibm_giant_l3_vcache_wechat_article_zh/985f6fbd1475a9e6_04_figure.jpg)

无额外延迟时，96 MB 带来很大收益，又几乎不让其他轨迹回退。

![图 5：96 MB、52 周期 L3 的结果；容量受益负载仍大幅提升，延迟敏感负载出现小幅回退](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ibm_giant_l3_vcache_wechat_article_zh/6dc9fd17ebec83a5_05_figure.jpg)

增加 6 周期后，情况成为 256 MB 配置的温和版本：有些轨迹接近一代 IPC 提升，能装进 32 MB、又对延迟敏感的轨迹则回退。大部分下降不超过 5%，日常使用可能不明显，但 benchmark 和帧率统计能看到。

### 体系结构视角：缓存容量只减少“去内存的次数”，不会自动缩短命中路径

大缓存的收益可粗略看成“减少的 miss 数 × 被避免的下一级代价”，成本则包括“所有 L3 hit 多付出的周期”、更大的阵列能耗和面积。工作集刚好跨过原容量、且访问有复用时，容量收益最大；工作集本来就小或大到新缓存也装不下时，延迟更重要。

乱序执行和内存级并行能隐藏一部分 miss，但单条依赖链、指针追踪和同步访问更难隐藏。验证时不能只报平均命中率，还应同时观察 L3 MPKI、平均并发 miss、后端 memory-bound 周期、有效内存延迟与 IPC。本文给出的相关图正说明：同一个命中率指标不足以代表所有轨迹。

## 游戏处在什么位置

测试没有采集游戏指令轨迹，而是在 Ryzen 9 3950X 上用 L3 性能计数器测量“每条指令的 L3 miss”，再把游戏位置近似映射到模拟曲线。因此这部分只能用于趋势判断，不是对游戏帧率的直接模拟。

![图 6：三种模拟缓存配置的 IPC 收益与 16 MB L3 命中率；标注点是 3950X 计数器测得的真实负载 L3 MPKI](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ibm_giant_l3_vcache_wechat_article_zh/9f2ecae4cbd9b3e8_06_figure.jpg)

游戏看起来很适合更大缓存，96 MB 配置尤其接近这类 L3 miss 范围的甜点。256 MB IBM 风格缓存往往要等 16 MB L3 超过约 20 MPKI 才显示优势。

但游戏不是全部。图中也标了若干非游戏 benchmark，它们对应的轨迹即使“免费”得到 96 MB、延迟不增加，收益仍接近零。这些程序更需要更快而不是更大的缓存。

![图 7：3950X 上游戏与非游戏负载的 16 MB L3 命中率对比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ibm_giant_l3_vcache_wechat_article_zh/ea945805807eb96f_07_figure.png)

因此 V-Cache 不是对普通 L3 的全面替代，而是承认单一 L3 容量无法覆盖所有场景。面向广泛负载的产品，很可能同时提供带 V-Cache 与不带 V-Cache 的配置，让用户按工作集和延迟敏感度选择。当时泄露的 Genoa PPR 没有提到超过 32 MB 的常规配置，也与这种分化方向一致；泄露材料本身不能视作正式规格。

## 对 V-Cache 延迟的推测

![图 8：AMD 在 Hot Chips 2021 展示的 3D V-Cache 游戏收益，主张平均提升约 15%](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ibm_giant_l3_vcache_wechat_article_zh/2ee513babcad22e3_08_figure.jpg)

AMD 宣称游戏平均提升约 15%，更接近 46 周期的理想模拟，而不是增加 6 周期的悲观结果。Tom’s Hardware 当时也转述 AMD 称延迟影响很小。由此推测，首代 V-Cache 可能只增加约几个周期；这不是直接测量值，消费者最终权衡的也可能更多是价格而非明显性能副作用。

## 为什么 IBM 与消费级 CPU 选择不同

IBM 早已在大缓存上积累多年：2019 年 z15 使用 256 MB、32 路片级缓存，2017 年 z14 已有 128 MB，而且都在 GlobalFoundries 14 nm 上实现。AMD 与 Intel 并非没有能力照搬，而是目标负载不同。

AMD 面对更广的消费与通用计算负载，其中很多工作集不大却对命中延迟敏感。更快、容量适中的 L3 可能在内部模拟中给出更好的总体表现；游戏等另一类负载才为 V-Cache 提供理由。IBM 主机更强调巨大工作集，也可能更能容忍较高 LLC 延迟。理想的低延迟 256 MB L3 当然兼得两者，但以当时的制造和封装代价并不现实，3D V-Cache 是更可行的折中。

## 模拟条件与可比性

模拟使用 ChampSim，轨迹来源包括机器学习预取竞赛、Qualcomm Datacenter Technologies 为 Championship Value Prediction 竞赛提供的轨迹，以及 Texas A&M Daniel Jiménez 教授提供的 ChampSim 轨迹。每条轨迹执行 10 亿条指令，另有 2000 万条 warm-up。

![图 9：缓存模拟参数；L1I/L1D 32 KB、L2 512 KB，比较 16/32/96/256 MB L3 与不同延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ibm_giant_l3_vcache_wechat_article_zh/039beb0a7716afa7_09_figure.jpg)

L3 采用 SRRIP 替换策略。模型用 32 KB、8 路、4 周期的 L1I/L1D，512 KB、8 路、12 周期 L2；L3 容量从 16 MB 到 256 MB，延迟按 39、46、52、60 周期变化。96 MB 还单独跑了 46 周期理想配置。

![图 10：近似 Zen 3 的其他核心参数，包括 6-wide 前端、8-wide 执行/退休、256 项 ROB 与 DDR4-3200](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ibm_giant_l3_vcache_wechat_article_zh/02f60978e521b687_10_figure.jpg)

核心假设 6-wide fetch/decode、8-wide execution/retire、96 项 scheduler、256 项 ROB、114 项 load queue、44 项 store queue，分支预测使用 Hashed Perceptron，内存为双通道 DDR4-3200 15-15-15，核心 4.5 GHz。部分参数来自 Zen 3 测量或近似，不是周期精确的 AMD 官方模型。

最后还要保留样本限制：约 350 条轨迹并不覆盖所有负载；仿真耗时很长，3950X 连续运行多日；Qualcomm 客户端和服务器轨迹子集并非随机抽样，只是从大压缩包中最先解出的部分，之后磁盘空间就耗尽了。游戏又只有计数器定位，没有直接轨迹。因此，结果适合解释容量—延迟规律，不应被外推为所有应用的固定收益。

## 结语

巨大 L3 不是处理器缓存的唯一未来。IBM、V-Cache 与普通低延迟 L3 分别在不同工作集上占优：大工作集需要容量，小而依赖密集的工作集需要延迟，3D 堆叠则尝试在成本允许范围内靠近二者的平衡。

真正值得关注的不是“多少 MB”本身，而是新增容量是否显著减少 miss、访问延迟增加多少，以及目标负载能否隐藏这些周期。缓存设计最终是一项面向工作负载分布的产品决策。
