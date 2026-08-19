---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "amd_turin_uma_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*Evaluating Uniform Memory Access Mode on AMD’s Turin ft. Verda (formerly DataCrunch.io)*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2025 年 11 月 26 日
> - 链接：https://chipsandcheese.com/p/evaluating-uniform-memory-access

NUMA（Non-Uniform Memory Access，非统一内存访问）把核心与内存控制器的距离暴露给软件。它能让程序主动靠近数据，却要求开发者处理线程绑定、内存放置、节点容量和跨节点访问。AMD 的 NPS0 反其道而行：把双路服务器呈现为一个统一节点，让访问均匀分布到 24 个内存控制器。

这次机会来自 Verda（原 DataCrunch）提供的云实例，配置两颗 AMD EPYC 9575F 和八张 NVIDIA B200，并开放约三周。系统看起来运行在 NPS0；网页没有给出 BIOS 截图、内核 NUMA 枚举细节、编译器和完整重复统计，因此模式判断与小幅差异仍需保留这一边界。

![图 1：AMD EPYC 的 NPS0、NPS1、NPS2 与 NPS4](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_turin_uma_wechat_article_zh/82e85360ef7cc609_01_figure.jpg)

*图 1：NPS0 把全部 Socket 与通道交织成一个域；NPS1 每 Socket 一个节点；NPS2/NPS4 再细分。L3 是否单独暴露为 NUMA 域又是另一项设置。*

## 一、NPS0 解决的是软件复杂度

传统双路 NPS1 中，每颗 Socket 是一个节点，线程访问本地内存较快，跨 Socket 较慢。程序若想得到最佳性能，需要在分配内存时指定节点，避免跨区访问，还要面对每个节点只拥有部分核心、带宽和容量的问题。

![图 2：双路 Turin 在 NPS1 下的拓扑](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_turin_uma_wechat_article_zh/34d2eeaddb717b0e_02_figure.jpg)

*图 2：AMD 资料中的双路系统，每颗 Socket 自成 NUMA 节点。NPS0 会把这里的两个域合并，并把物理地址条带化到全部 24 个控制器。*

NPS0 的吸引力是让软件像使用桌面平台一样工作：不必决定页应该落在哪颗 Socket，也不会因线程迁移而突然访问“错误”节点。代价则是每次访问的平均物理距离上升。

### 体系结构视角：统一视图没有消除远端访问

NPS0 只隐藏亲和关系。请求仍可能经过本地 CCD、IOD、Socket 间 xGMI、另一颗 IOD 和远端控制器。条带化让每个线程都能使用全部带宽，却也意味着相当比例请求天然走远路。它优化的是可编程性和总体资源池，而不是单次访问的最短路径。

## 二、超过 220 ns 的 DRAM 延迟

简单指针追逐立即显示代价：NPS0 下 DRAM 延迟超过 220 ns，比 EPYC 9355P 单路 NPS1 高近 90 ns。

![图 3：NPS0 下的 Cache 与 DRAM 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_turin_uma_wechat_article_zh/14c06bf8c269a995_03_figure.png)

*图 3：CPU Cache 台阶仍由 Zen 5 CCD 决定，越过 L3 后则进入约 220 ns 的双路统一路径。高频 9575F 无法缩短以纳秒计的互连与 DRAM 时间。*

作为历史对照，双路 Broadwell 在每 Socket 一个节点时约 75.8 ns，统一访问约 104.6 ns；Turin NPS0 的绝对惩罚明显更大。现代平台拥有更多核心、控制器与互连端点，统一化成本也随规模上升。

![图 4：NPS0 与单路 NPS1 的受载延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_turin_uma_wechat_article_zh/debd73f76e303a3c_04_figure.png)

*图 4：NPS0 基线约 220 ns，直到总带宽接近 400 GB/s 后，24 个控制器的带宽储备才开始抵消延迟劣势。单路 9355P 基线约 130 ns，在接近其带宽极限时快速抬升。*

NPS0 确实让两颗 Socket 的控制器同时工作。问题是 NUMA-unaware 程序未必能高效产生足够均匀的并行请求。测试工具的普通带宽模式还遇到线程结束时间不一致，导致 9575F 数值偏低；受载延迟测试通过共享停止标志让线程近似同时结束，避免了这一误差。9355P 在 NPS1 的单纯线性读曾测得 479 GB/s。

![图 5：EPYC 9575F NPS0 与 9355P NPS1 的访问模式带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_turin_uma_wechat_article_zh/fb240068ad491380_05_figure.jpg)

*图 5：9575F 的普通 Read/Add/Modify-write/NT-write 约为 83/125.4/71.04 GB/s；9355P 为 99.6/131.8/88.4 GB/s。这里更能说明测试线程同步问题和单 CCD 路径，而不是 24 控制器的整机峰值。*

两款芯片都使用 GMI-Wide：每颗 CCD 在 FCLK 下拥有读、写各 64 B/cycle。NPS0 不会改变 CCD 入口宽度，因此单 CCD 带宽与 NPS1 差别很小。

### 体系结构视角：带宽资源增加，不等于单线程更快

24 个控制器只有在足够多的独立请求均匀分布时才有价值。单线程受限于指令级并行、Load Queue、未完成 miss 数、预取器和一颗 CCD 的 GMI；提高控制器数量通常不改变这些上游限制。NPS0 的优势更偏向整机吞吐，而其延迟惩罚会立即作用于每次 DRAM miss。

## 三、SPEC CPU2017：总分掩盖了相反的子项

EPYC 9575F 最高可达 5 GHz。尽管 DRAM 延迟超过 220 ns，它在单线程 SPEC CPU2017 总分中仍表现很好，因为频率、核心 IPC、Cache 命中率都会影响最终时间。

![图 6：SPEC CPU2017 单线程估算总分](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_turin_uma_wechat_article_zh/146d38bae996aefc_06_figure.png)

*图 6：9575F 的整数/浮点估算约为 11.59/19.63，整体领先 4.4 GHz 的 9355P。NPS 模式不是唯一变量，不能把总分解释成 NPS0 优于 NPS1。*

整数子项呈现两类行为。`548.exchange2` 很少离开 Cache，高频核心优势充分体现；`502.gcc`、`505.mcf` 与 `520.omnetpp` 更依赖 DRAM，5 GHz 无法抵消 NPS0 的长延迟，反而落后 4.4 GHz、延迟更低的平台。

![图 7：SPEC CPU2017 整数子项](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_turin_uma_wechat_article_zh/0600ffcda65dd8b0_07_figure.png)

*图 7：右侧差值同时有正有负。它说明“频率更高”和“内存更慢”会在不同局部性工作负载中分别占上风，单一总分不应替代子项分析。*

浮点套件同样分化。`549.fotonik3d`、`554.roms` 对内存敏感，NPS0 供数不足；`538.imagick` Cache 命中率高，能把 9575F 的计算吞吐转成成绩。

![图 8：SPEC CPU2017 浮点子项](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_turin_uma_wechat_article_zh/d61ee0c41ddb6b5a_08_figure.png)

*图 8：高频优势与长延迟惩罚在同一套 Benchmark 中并存。测试为单 Copy 的 Rate 估算，并不代表双路、全核吞吐。*

## 四、NPS0 值不值得使用

这组单线程 SPEC 结果比直觉更好，说明 Zen 5 的 Cache 与 5 GHz 频率能遮住一部分 220 ns DRAM 延迟。但这并没有改变 NPS0 的根本取舍：延迟成本从第一个 DRAM miss 就开始支付，额外带宽却要到总需求接近 400 GB/s 才显现。

可以归纳出四点：

1. NPS0 是软件易用性模式，不是低延迟模式；它把 NUMA 优化成本从应用转移到硬件平均路径。
2. Cache 命中率决定高频能否兑现。局部性良好的程序可以忽略很慢的 DRAM，内存密集程序则完全相反。
3. 双路统一带宽需要足够线程、良好交织和正确的测试同步；单线程或单 CCD 无法代表 24 通道能力。
4. 随核心、控制器和 Socket 规模继续增加，隐藏物理亲和关系的代价大概率会继续上升。

Chester Lam 的结论很明确：在现代双路系统中，NPS0 并不划算。对于必须跨 Socket 扩展的负载，NUMA-aware 的线程与内存放置仍是一项令人无奈却难以回避的工作。

## 参考资料

- Chester Lam，*Evaluating Uniform Memory Access Mode on AMD’s Turin*：https://chipsandcheese.com/p/evaluating-uniform-memory-access
- AMD，*EPYC 9005 Series Architecture Overview*
