---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "intel_crestmont_comparison_wechat_article_zh"
---

> 英文标题：Comparing Crestmonts: No L3 Hurts<br>
> 撰文：Chester Lam<br>
> 首发：Chips and Cheese，2024 年 5 月 21 日<br>
> 原始链接：https://chipsandcheese.com/p/comparing-crestmonts-no-l3-hurts

Meteor Lake Compute Tile 上的标准 E-Core 与 P-Core 共享 24 MB L3；SoC Tile 上的低功耗 E-Core（LPE-Core）只有私有集群 2 MB L2。两者逻辑上都是 Crestmont，因而提供一个难得对照：同一核心坐得离 DRAM 太近，会发生什么？

![图 1：Intel Tech Tour 展示标准 E-Core 与 SoC Tile LPE-Core](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_crestmont_comparison_wechat_article_zh/3e655c0026f3a1e6_01_figure.jpg)

分析使用 Top-Down 方法，以 rename/allocate 这个现代核心通常最窄的 stage 计算 pipeline slot。Frontend 没填满是 frontend bound；后端资源无空项导致 renamer 不能下发是 backend bound；已过 rename 但最终不退休的是 bad speculation。乱序执行可在后段“追赶”，却补不回最窄处已经丢失的 slot。

## libx264：0.1% 的 DRAM load，制造 26% 的停顿

![图 2：libx264 的 Top-Down slot 分类](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_crestmont_comparison_wechat_article_zh/588091227902b509_02_figure.png)

两种 Crestmont 都以 backend bound 为主。

![图 3：后端结构满导致的 stall 细分](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_crestmont_comparison_wechat_article_zh/ee48cf978a90d64a_03_figure.png)

Load buffer 最热，说明大量 load 等待更老操作；ROB 也频繁填满，核心在努力隐藏长延迟；依赖这些慢指令的 uop 继续占 scheduler。更大 buffer/scheduler 会有帮助，但先要看延迟来源。

![图 4：L1D miss 后分别等待 L2/L3/DRAM 的周期占比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_crestmont_comparison_wechat_article_zh/cfa61022b3e6e52b_04_figure.png)

L2 虽不算快，现代乱序核仍可隐藏二十多周期，两种核心只在 2%—4% 周期等待 L2。标准 Crestmont 面对较高 L3 延迟也只有 6.31%。DRAM 则是数百周期，LPE-Core 无法隐藏；Redwood Cove 大核也只是减轻。

![图 5：每指令 DRAM access 与 DRAM-bound cycle](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_crestmont_comparison_wechat_article_zh/b3fb8a2d7bfea29d_05_figure.png)

标准 Crestmont 仅 0.1% 指令从 DRAM load，却让核心超过 26% cycle stall；LPE-Core 每指令 DRAM access 为前者 2.6 倍，44% cycle 等 DRAM。少数超长延迟指令足以支配吞吐。

LPE-Core 平均 1.17 IPC，标准 E-Core 1.55，后者高 30% 以上。Meteor Lake L3 不算快，却远胜完全没有。

### 体系结构视角：为什么几十分之一的 miss 能拖住整个窗口

一条 DRAM load 可占用 Load Queue、ROB 和 destination physical register 数百周期；依赖链又占 scheduler。只要 outstanding miss 数接近并发上限，rename 就因任一资源耗尽反压。验证应联合看 LLC MPKI、average miss latency、LQ/ROB full、memory-level parallelism 和 dependent stall；单看 0.1% load 比例会低估影响。

## Linux tinyconfig：数据和指令都可能饿死核心

使用并行构建编译 Linux kernel 的最小 `tinyconfig`。整体仍 backend bound，但 frontend 与 bad speculation 更显眼。

![图 6：Kernel compile Top-Down 分类](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_crestmont_comparison_wechat_article_zh/f2998ddd74833f50_06_figure.png)

![图 7：Frontend latency 与 bandwidth 损失](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_crestmont_comparison_wechat_article_zh/106ce6e9a05020dd_07_figure.png)

Intel 把 I-cache miss、branch detect、branch resteer 归 latency，其余归 bandwidth。Crestmont 两个 decode cluster 需要均衡；偏向一侧会从 6-wide 近似退成 3-wide。通常在 taken branch 切换 cluster，predictor 也能在大 basic block 插 toggle point。编译负载 branch 占 21.5%，libx264 仅 6.1%；频繁 taken 既造成 cluster 不均，也浪费 branch 后的 decode slot。

![图 8：Crestmont 双 decode cluster 与 toggle 机制示意](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_crestmont_comparison_wechat_article_zh/62e5dd67ea0ec9ba_08_figure.jpg)

大量 branch 还会访问更大、更慢 BTB level，decoder 有时发现 predictor 未跟踪的 taken branch，Crestmont 可能受益于更大 BTB。

![图 9：指令 cache miss 造成的前端 stall](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_crestmont_comparison_wechat_article_zh/f96128160c50c52a_09_figure.png)

标准核心可用 branch predictor 跑在 fetch 前方，制造 instruction-side MLP，L2/L3 基本遮住延迟，DRAM fetch 极少。LPE-Core 没 L3，只能从 LPDDR5 拉指令；frontend 完全空闲 12.46% cycle，标准核心仅 1.07%。

Backend 仍损失 21%—23% potential throughput。ROB 是主要限制而非 scheduler，说明编译拥有较多可用 ILP；如果依赖很多，scheduler 应先满。

![图 10：Kernel compile 后端结构压力](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_crestmont_comparison_wechat_article_zh/4602e082eaa562d7_10_figure.png)

![图 11：数据侧 L2/L3/DRAM stall](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_crestmont_comparison_wechat_article_zh/70e3d8d25afbe7c5_11_figure.png)

LPE-Core 仍更多访问 DRAM；标准核心也付 L2/L3 延迟，因此数据侧总差距不像 instruction side 那么极端。最终标准 Crestmont IPC 高 28.5%。

### 体系结构视角：Frontend 也会遭遇“内存墙”

取指 cacheline 同样需要 TLB、L2/L3、MSHR 与 DRAM。Branch predictor 可提前生成多个目标，增加 instruction MLP，但无法跨越数百周期且并发资源有限。验证代码大 footprint 时，应看 L1I MPKI、ITLB、BAClear/resteer、instruction fetch miss latency，而不是把低 IPC 全部归给 decoder width。

## 反例：7-Zip 的问题主要在核心本身

测试压缩 2.67 GB ETL。7-Zip backend bound，并有大量 bad speculation；代码 footprint 小、可放 L1I，前端总体供给良好。

![图 12：7-Zip Top-Down 分类](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_crestmont_comparison_wechat_article_zh/b70524c1ac04389c_12_figure.png)

![图 13：Bad speculation 几乎全部来自 branch mispredict](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_crestmont_comparison_wechat_article_zh/8a234929f9dceb36_13_figure.png)

Memory ordering violation 或错误 load independence 也可浪费执行，但此处贡献很小。

![图 14：三种负载的 branch prediction accuracy](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_crestmont_comparison_wechat_article_zh/3400bbcd9ae51ab0_14_figure.png)

7-Zip 准确率 95.42%，比早期 Atom 好很多，只略低于另两项。

![图 15：按每指令 mispredict 统计，7-Zip 负担显著](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_crestmont_comparison_wechat_article_zh/d8c249e63aefa4c0_15_figure.png)

问题是 branch 占指令流超过 17%；即使 95.42%，每千指令仍会错很多，恢复丢失大量工作。

![图 16：7-Zip 后端结构压力](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_crestmont_comparison_wechat_article_zh/9ca79da84eae0429_16_figure.png)

Scheduler 经常满。7-Zip 几乎没有 FP/vector，因此分布式 integer scheduler 是主要瓶颈；大量指令互相依赖，ILP 难找，与 kernel compile 的 ROB-first 不同。

![图 17：两种 Crestmont 的 cache miss stall](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_crestmont_comparison_wechat_article_zh/855445f252809d92_17_figure.png)

两者 cache 痛感接近：L1D hitrate 高，大多数 miss 又被 2 MB L2 捕获。

![图 18：标准 Crestmont 24 MB L3 在 7-Zip 中仅约 35% hitrate](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_crestmont_comparison_wechat_article_zh/93d1328bf4be72d7_18_figure.png)

L2 再 miss 的访问局部性很差，L3 也难救。标准 E-Core IPC 只高 10.2%。实际性能差大于 10%，因为 LPE-Core 频率更低；若无 L3 却提高频率，DRAM 延迟换算成更多 core cycle，scaling 也会变差。

## 结语：LPE-Core 的架构潜力被系统层级限制

LPDDR5 以低功耗提供高带宽，但 latency 一直高于桌面 DDR，少量 DRAM access 就能制造不成比例的 stall。

![图 19：Crestmont/Gracemont 核心图；来源分别为 Bilibili 页面与 Fritzchens Fritz](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_crestmont_comparison_wechat_article_zh/794fb4f97c92d7db_19_figure.jpg)

![图 20：Intel Tech Tour 展示 E-Core 处理轻量任务](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_crestmont_comparison_wechat_article_zh/fcdedd9bb89f4f4b_20_figure.jpg)

LPE-Core 的目标是处理轻量/后台工作，避免唤醒 Compute Tile。Crestmont 本身有可观乱序能力，本可处理浏览、消息等；实测把浏览器或 Discord 固定到它们后，YouTube 可能掉帧/音频滞后，Discord 近乎不可用，只能承担不关键后台任务。这是特定 Meteor Lake 笔记本与软件环境观察，不是所有配置的定量结论。

更大 L2 或 SoC Tile system-level cache 可能让它们处理更多工作而不唤醒 Compute Tile；Intel Atom 早已支持 4 MB L2，因此扩到 4 MB 是合理设想。具体面积、功耗与互连代价没有公开实现数据，属于方案评论。
