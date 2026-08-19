---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "ps5_zen2_fpu_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*The Nerfed FPU in PS5’s Zen 2 Cores*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2024 年 3 月 20 日
> - 链接：https://chipsandcheese.com/p/the-nerfed-fpu-in-ps5s-zen-2-cores

Fritzchens Fritz 的 Die Photo 显示，PlayStation 5 风格 Zen 2 核心的 FPU 从桌面版约 0.91 mm² 缩到 0.59 mm²。测试平台不是零售 PS5，而是采用 Harvested PS5 Chip 的 AMD BC-250：六颗 Zen 2 核心可用、GPU 被大幅精简，原本面向加密挖矿。文中简称“PS5 Zen 2”，这一平台边界必须保留。

## 砍的是执行端口，不是乱序容量

![图 1：桌面 Zen 2 与 PS5 风格核心的 FPU Die Photo](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ps5_zen2_fpu_wechat_article_zh/937283071fe03146_01_figure.jpg)

*图 1：图片来自 Fritzchens Fritz。PS5 FPU 短边同宽，另一轴明显压缩，空白与两侧执行阵列都减少。*

普通 Zen 2 有 FP0～FP3 四个 Port。PS5 删除 FP3；FP2 只保留 FP/Vector Store，数学单元被删或移到 FP0/FP1，因此等效为“双数学端口+可并发 Store”。

![图 2：微基准反推的 FPU 端口能力](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ps5_zen2_fpu_wechat_article_zh/4de529680db45af2_02_figure.png)

*图 2：来自指令吞吐与 PMU，不是 AMD 官方框图。*

![图 3：物理寄存器阵列的版图变化](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ps5_zen2_fpu_wechat_article_zh/1b7b51d49c7a1eb1_03_figure.jpg)

*图 3：Block 数量看似不变，但更紧凑。*

用 Speculative Register Capacity 微基准测试 FP/Vector Physical Register File，仍为完整 160 项；换 256-bit FP Add 填充后相同，说明每项仍 256-bit。

![图 4：PS5 与普通 Zen 2 的 FP Register Capacity](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ps5_zen2_fpu_wechat_article_zh/6b4eea12b76c4afb_04_figure.png)

*图 4：容量来自在途寄存器压力的拐点反推。*

寄存器文件面积更依赖 Read/Write Port 的数量与宽度，而非 Bit Cell 本身。普通 Zen 2 四条 Pipe 最多需要十个输入，但优化手册称 FP3 Source Bus 复用于 FP0/FP1 FMA 的第三操作数，因此文章推断其约八个 Read Port；PS5 版只需约六个。

![图 5：Zen 4 关于寄存器文件端口主导面积的说明](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ps5_zen2_fpu_wechat_article_zh/6362706d1b1feb29_05_figure.jpg)

*图 5：Kai Troester 讨论的是 Zen 4 512-bit Register File，本文把同一物理规律用于解释 PS5，是推断。*

![图 6：Zen 2 Register Read Port 复用示意](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ps5_zen2_fpu_wechat_article_zh/760795f231c33c5e_06_figure.png)

*图 6：普通版约 8 Read Port，PS5 版约 6；并无 RTL 证据。按此估算，3.5 GHz 下 PS5 读/写为 192/128 B/cycle，即 672/448 GB/s；普通版为 256/192 B/cycle，即 896/672 GB/s。*

Scheduler 与 64 项 Non-Scheduling Queue（NSQ）没有裁剪；对 FP Pipe Assignment 事件设 Count Mask=4，显示仍可从 Rename 每周期接收四个微操作。FP Renamer 也保持完整。

![图 7：完整乱序结构配较少执行端的意义](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ps5_zen2_fpu_wechat_article_zh/3b795b2af4f2a0a9_07_figure.png)

*图 7：以 Daniel Lemire AVX-512 Integer-to-string 测试作更宽背景；Zen 4 也用相似思想，以完整窗口隐藏较有限的吞吐。该图不是 PS5 跑分。*

### 体系结构视角：缩吞吐之前，为什么不先缩 Queue

执行单元长期低利用时，删重复 Pipe 可直接省面积和 Register Port；保留 Register、Scheduler 与 NSQ，则能吸收短时突发、长依赖和 Cache miss，避免 Pipeline 因偶发压力立刻反压 Rename。验证应同时看 Pipe Assignment、Scheduler/NSQ Full、Physical Register Full 与执行延迟；平均 Port 利用率低不代表峰值从不重要。

## 对照平台与可比性

没有同一 SoC 的完整/精简 FPU 对照。Steam Deck APU 最接近：两者最高 3.5 GHz，每 Cluster 4 MB L3，LPDDR5 与 GDDR6 都高延迟，但 LPDDR5 略差。

页面说明两边使用 Ubuntu Linux，但没有完整披露发行版版本、编译器、各应用版本和所有命令参数；除 Y-Cruncher 的 2.5 亿位输入、libx264 的 4K 片段等已给条件外，其余比较只按文中场景理解。

![图 8：BC-250 与 Steam Deck 平台差异](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ps5_zen2_fpu_wechat_article_zh/0c564d398d64f026_08_figure.png)

*图 8：跨 SoC 对比不能把全部差值归因于 FPU。*

带宽差异很大：Steam Deck CPU 受片上 Fabric 限制，BC-250 用 1 GB Read-Modify-Write 接近 100 GB/s；若每 Cluster 有 32 B/cycle 双向 Fabric，反推 FCLK 约 1.2 GHz，仍只是推测。

![图 9：两平台 DRAM 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ps5_zen2_fpu_wechat_article_zh/360427c1bd435e14_09_figure.png)

*图 9：每线程独立数组，避免控制器合并；后续只用同 CCX 三核，尽量让 Steam Deck 仍有足够带宽。两边均为 Ubuntu Linux。*

## 基线与中等向量负载

7-Zip 主要是 Scalar Integer、几乎不用 FPU，且工作集越过 Cache。

![图 10：三核 7-Zip 基线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ps5_zen2_fpu_wechat_article_zh/22da53dceb8a12f1_10_figure.png)

*图 10：BC-250 快 4%，更低内存延迟可能是原因；后续差异若在 4% 内视为基本持平。*

libx264 用一个 4K Overwatch 游戏片段转码，Steam Deck 快 14.9%。

![图 11：libx264 三核性能](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ps5_zen2_fpu_wechat_article_zh/b7d9e3b2e64778df_11_figure.png)

*图 11：结果同时含平台差异，但已明显超过 4% 基线。*

![图 12：libx264 的 FP Pipe Assignment](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ps5_zen2_fpu_wechat_article_zh/9e79b9ae7bcf9fd1_12_figure.png)

*图 12：普通 Zen 2 四 Pipe 分配均匀；PS5 工作移到 FP0/1，但平均利用还不像持续饱和。事件在 Zen 2 未正式文档化，Linux perf 仍支持，且用微基准验证过。*

只有 Scheduler+NSQ 合计约 100 项都满，才会出现文中简称的“FP Scheduler Full”。FP Register Full 则说明长延迟写 Register 指令阻塞退休，不一定是执行吞吐不足。

![图 13：Zen 2 PPR 的 FP 资源 Stall 事件](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ps5_zen2_fpu_wechat_article_zh/f3ee910d02a6c23d_13_figure.png)

*图 13：后续用这两类事件区分吞吐与在途寿命。*

![图 14：libx264 的 FP Register/Scheduler Stall](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ps5_zen2_fpu_wechat_article_zh/0061c35ffe3cc2e7_14_figure.png)

*图 14：两版 Scheduler 很少满，Register File 都会满。可能是长延迟完成后，普通四 Pipe 能更快清空 NSQ→Scheduler 积压，让 36 项可见窗口更充分抽取 ILP；尚无直接证据。若连 160 项 Register 也裁掉，后果很可能更严重。*

SSIM 是视频质量指标，Steam Deck 只快 0.45%，视为持平。

![图 15：SSIM 性能](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ps5_zen2_fpu_wechat_article_zh/39ab56c384df8937_15_figure.png)

*图 15：中等 FP 负载可被精简 FPU 吸收。*

![图 16：SSIM 的 Pipe 分配](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ps5_zen2_fpu_wechat_article_zh/ec1bbcf21ffc23df_16_figure.png)

*图 16：FP2 因 Vector Store 得到较多工作，正好利用 PS5 保留的 Store Pipe。*

![图 17：SSIM 的 FP Resource Stall](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ps5_zen2_fpu_wechat_article_zh/7b73c853a13f5069_17_figure.png)

*图 17：精简版略高，但两边都不像主要瓶颈。*

## Y-Cruncher：吞吐重负载终于把差距拉开

计算 2.5 亿位 Pi，Y-Cruncher 多线程且充分利用 SIMD，也可能受 DRAM 带宽限制。Steam Deck 快 16.4%。

![图 18：Y-Cruncher 性能](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ps5_zen2_fpu_wechat_article_zh/d511ccdf44ff9819_18_figure.png)

*图 18：三核设置用于降低平台带宽失配，但无法完全消除。*

![图 19：Y-Cruncher 的 Pipe 利用率](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ps5_zen2_fpu_wechat_article_zh/ba055cfb28527c42_19_figure.png)

*图 19：普通四 Pipe 都很忙；PS5 的 FP0/1 更重，FP0 接近 70%。*

![图 20：Y-Cruncher 的 FP Scheduler Full](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ps5_zen2_fpu_wechat_article_zh/f590deeea6cce869_20_figure.png)

*图 20：普通 Zen 2 因 Scheduler+NSQ 满而阻塞 Rename 6.48% 周期，PS5 达 17.32%，明确指向吞吐不足；两边执行延迟实测相同，可排除“指令变慢”作为主因。*

## 游戏：平均 FP Pipe 利用率低于 1%

现代游戏把渲染交给 GPU，CPU 不再需要用 FPU 画图。测试游戏中 FP0/1/3 平均忙碌不足 1%，FP2 因 Store 稍高但仍低。

![图 21：游戏中的 FP Pipe 利用率](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ps5_zen2_fpu_wechat_article_zh/ccdd9b6537fd60e0_21_figure.png)

*图 21：这是所测游戏的平均值，不能保证所有游戏和瞬时阶段都相同。双数学 Pipe 对 PS5 的目标负载很合理。*

## 从定制 FPU 到 Zen 4c：两种面积策略

![图 22：Cortex-A510 可选 VPU Pipe](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ps5_zen2_fpu_wechat_article_zh/667ad3ed4b5d1824_22_figure.png)

*图 22：Arm 明确提供可配置 128-bit Pipe；PS5 表明 AMD 也有很强的客户定制能力，只是未公开通用选项。*

![图 23：PS5 游戏的 FP 操作与乱序缓冲](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ps5_zen2_fpu_wechat_article_zh/334f77ea51a8895c_23_figure.png)

*图 23：即使游戏每秒执行数十亿 FP Operation，完整 Queue 仍能吸收短时峰值，精简执行端足够。*

![图 24：FPU 面积的像素测量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ps5_zen2_fpu_wechat_article_zh/b320935750bc1bfc_24_figure.jpg)

*图 24：缩小约 35%，但四核 Cluster 只缩约 5.8%；比例来自 Die Photo 缩放、标注和像素计数，并非 AMD Floorplan 数字。*

![图 25：Zen 4c 的整核密度路线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ps5_zen2_fpu_wechat_article_zh/23ae52be345fe0ee_25_figure.jpg)

*图 25：Zen 4c 不改架构、保留完整 512-bit Register File/FPU，通过约 3.6 GHz 频率目标、6T SRAM、较小 Clock Mesh 等让整核缩 35%，再把 L3 减半；因此 16 核 Die 只略大于标准八核 Zen 4 CCD。*

PS5 的方案对特定游戏产品非常合适：删掉低利用的执行单元，保留延迟隐藏能力。它对 SSIM 几乎无损，libx264/Y-Cruncher 则慢约 15%～16%。但只缩 FPU 不足以开启新的通用市场，AMD 后来选择 Zen 4c 这种整核密度优化。BC-250 结果说明的是定制取舍，不等于零售 PS5 整机或所有桌面应用表现。

## 参考资料

- Chester Lam, *The Nerfed FPU in PS5’s Zen 2 Cores*, Chips and Cheese, 2024-03-20
- Fritzchens Fritz 的 Zen 2/PS5 Die Photo
- AMD Zen 2 PPR/Optimization Guide；Arm Cortex-A510 Optimization Guide
