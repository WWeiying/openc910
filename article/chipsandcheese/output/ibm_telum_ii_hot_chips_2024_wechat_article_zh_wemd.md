---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "ibm_telum_ii_hot_chips_2024_wechat_article_zh"
---

> 英文标题：Telum II at Hot Chips 2024: Mainframe with a Unique Caching Strategy<br>
> 撰文：Chester Lam<br>
> 首发：Chips and Cheese，2024 年 9 月 8 日<br>
> 原始链接：https://chipsandcheese.com/p/telum-ii-at-hot-chips-2024-mainframe-with-a-unique-caching-strategy

大型机仍承担金融交易等要求极高的可用性与低延迟的任务。IBM 最新 Telum II 与普通服务器 CPU 很不一样：只有 8 个核心，却运行在 5.5 GHz，并配置 360 MB 片上缓存；另有加速 I/O 的 DPU 与片上 AI accelerator，采用 Samsung 5 nm 工艺。

![图 1：Telum II 裸片中的 8 个 5.5 GHz 核心、10 个 36 MB L2、DPU 与 24 TOPS AI 加速器](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ibm_telum_ii_hot_chips_2024_wechat_article_zh/45c66e306e455263_01_figure.jpg)

Hot Chips 2024 的常规规格已有很多介绍，本文集中看最特别的 cache 策略。DRAM latency 与 bandwidth 限制让缓存对交易负载尤其关键，Telum II 延续上一代 Telum 的 virtual L3 和 virtual L4 思路。

## 十块 36 MB L2，以及一层并不存在的“物理 L3”

Telum II 片上有十块 36 MB L2：八块连接 CPU core，一块连接 DPU，第十块不挂任何计算单元。总容量 360 MB，单块就比 Zen 3 桌面/服务器常见的 32 MB L3 更大。作为另一参照，Snapdragon X Elite 的 Oryon 以 12 MB、约 5.28 ns L2 被 Qualcomm 称为高容量紧耦合缓存，而 Telum II 单块容量更大、延迟约 3.6 ns。

![图 2：Oryon 约 5.28 ns 的 12 MB L2 延迟曲线，用于对照 Telum II 的 36 MB、3.6 ns](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ibm_telum_ii_hot_chips_2024_wechat_article_zh/1ecf7508c81e5e08_02_figure.jpg)

巨型 L2 能降低单核访问延迟，却带来共享缓存难题。现代 CPU 的 shared LLC 可让低线程负载独占更多容量，也减少多线程共享数据的重复副本；但 Telum II 八个 CPU core 的 L2 已占 288 MB SRAM，再增加传统大 L3，即使对专用大型机芯片也很昂贵。

![图 3：传统 Zen 3/4/5 的私有 L2（绿）与按地址固定分片的共享 L3（红）](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ibm_telum_ii_hot_chips_2024_wechat_article_zh/dd76174ebbe0fc86_03_figure.png)

IBM 的办法是减少重复，并把已有 L2 的闲置容量重用成 virtual L3。根据 IBM patent，每块 L2 有一个 Saturation Metric，反映所属 core 为满足 miss 而把新数据带入 L2 的频率。某块 L2 evict cache line 时，victim 会迁移到 Saturation Metric 更低的另一块 L2，让已经承压的核心继续保留自己的空间。没有挂 core 的第十块 L2 始终具有最低 metric，自然成为优先目的地。

若另一块 L2 已有同一 line，Telum II 会把 ownership 交给现有副本，而不是再向 virtual L3 放一个副本，进一步减少 duplication。

![图 4：Telum II virtual L3：被某核 L2 淘汰的 line 保留在其他较空闲的 L2 中](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ibm_telum_ii_hot_chips_2024_wechat_article_zh/75d98840a84c5f4d_04_figure.png)

IBM 还用 replacement position 防止 virtual L3 挤掉 core 自己的 L2。普通 LRU 策略会把新 line 放到 MRU 端，使其最后被淘汰；virtual-L3 line 可插入 LRU 与 MRU 之间，优先保留由本地 core 直接带入的 line。

![图 5：virtual-L3 line 插在中间 LRU 位置，本地 L2 fill 仍进入 MRU](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ibm_telum_ii_hot_chips_2024_wechat_article_zh/c162b6ff81212a37_05_figure.png)

插入位置还能动态限制 virtual L3 占用。例如放在 LRU/MRU 中点，稳定状态下大致只能使用一半 ways；core idle 时，可把 virtual-L3 fill 放到更有利位置，让它吃下整块空闲 L2。

代价是查找更复杂。AMD、Arm、Intel 的常规 L3 通常由地址位唯一映射到某个 slice，requester 可以直接路由；Telum II 的 virtual-L3 line 可能在十块 L2 的任意一块，据 IBM 的交流，访问可能需要检查全部 L2 slice。面对“额外 tag compare 是否太贵”的问题，IBM 回答 L2 miss rate 很低，因此不是主要矛盾。一个 core 最多先享受 36 MB L2，miss 频率本就可能低于 Zen 5 core 在 32 MB L3 中的 miss。

### 体系结构视角：虚拟层级把“容量所有权”变成动态资源调度

传统 inclusive/exclusive cache 层级在物理上预留各级容量；Telum II 则让一块 SRAM 随负载充当 private L2 或 victim-based shared cache。Saturation Metric 决定 victim 去哪里，插入位置决定它能占多少 way，重复副本合并又提高有效容量。

这种设计适合低 L2 miss、高价值单线程的场景：多数访问只付 3.6 ns，少数 miss 才承担广播/多 slice tag 查找。若 miss 很多，全片探测会增加带宽与能耗。验证时应观察每片 L2 occupancy、virtual-L3 hit、victim migration、probe/tag lookup 与 saturation metric；只有专利和公开说明时，不能把具体广播网络细节当作已确认 RTL。

## 为什么停在 L3：跨芯片的 2.8 GB virtual L4

大型机处理器不会孤立部署，最多 32 颗 Telum II 可组成共享内存系统。IBM 把同一思路扩到系统级：L3 victim 可以送到仍有 cache 空间的其他 Telum II，构成 2.8 GB virtual L4。

![图 6：上一代 Z16/Telum 的 CPC（Central Processor Complex）drawer](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ibm_telum_ii_hot_chips_2024_wechat_article_zh/235f68adb0de7639_06_figure.png)

IBM 未在演讲中完整说明 Telum II virtual L4 组织，上一代给出线索。CPC drawer 类似 rack server 的紧凑组件，把 CPU 与 DRAM 放在近距离，但自身没有非易失存储或 PSU，不能独立运行。Z16 每 drawer 有八颗 Telum；若 Telum II 仍为八颗，2.8 GB 恰好对应八颗芯片全部片上 cache，virtual L4 很可能在 drawer 内保存 L3 victim。这是依据容量和历史组织的推断。

![图 7：更早的 z15 通过 System Controller 在一个 drawer 内提供 960 MB L4](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ibm_telum_ii_hot_chips_2024_wechat_article_zh/f7d1117af7aa7b93_07_figure.jpg)

IBM 给 virtual L4 的延迟是 48.5 ns。若跨 drawer 达到这个数会非常困难，因此作者认为范围更可能局限在 drawer。即便如此，跨 die 做到 48.5 ns 仍很强；作为参照，monolithic Nvidia Grace 的 L3 已超过 42 ns。IBM 的押注仍是 L3 miss 足够少，L4 延迟不会主导大多数访问。

## 回看第一代 Telum/Z16

virtual L3/L4 在 Telum/Z16 已经出现。每个 32 MB L2 slice 分成两个 16 MB segment；core 不需要全部 L2 时，其中一段可贡献给 virtual L3/L4，core idle 时全部 32 MB 都可贡献。

![图 8：第一代 Telum 的 L2 分段与 core-nest 设计变化](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ibm_telum_ii_hot_chips_2024_wechat_article_zh/709d205ef237fa88_08_figure.jpg)

IBM 技术概览确认，Z16 virtual L4 在 drawer 内实现。一个 drawer 有八颗 Telum，每颗共 256 MB L2。只有一个 thread 活跃时，它有本核 32 MB L2；同 die 其他 L2 组成 224 MB virtual L3；drawer 中其他芯片的闲置 L2 合计为 1.75 GB virtual L4。

![图 9：Z16 单线程可见的 32 MB private L2、224 MB shared virtual L3 与 1.75 GB virtual L4](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ibm_telum_ii_hot_chips_2024_wechat_article_zh/a115a3fa5b1b3575_09_figure.png)

Telum II 在三个层级上继续扩容。IBM 交流时还使用“congruence class”描述 virtual L3，查找后可知它基本对应其他厂商常说的 cache set。

![图 10：IBM 传统术语与行业常见术语对照，congruence class 即 set](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ibm_telum_ii_hot_chips_2024_wechat_article_zh/ac91e7afe2e10daf_10_figure.jpg)

当被问到为何术语不同，IBM 的回答是它更早提出这些叫法，后来行业才选了另一套词汇。轻松的对话也提醒我们，IBM 本就是高性能 CPU 发展的早期先驱。

## 单线程优先的大型机

服务器 CPU 通常追求多线程吞吐，client CPU 更偏单线程。Telum II 服务金融交易等服务器任务，却显著优先单线程：IBM 从 z15 每 die 12 核降到 Telum/Telum II 的 8 核，并用高频与巨大低延迟缓存服务每个 thread。单线程能获得接近客户端的 L2/L3 延迟，却有高一个数量级的容量。

![图 11：IBM 官方 Telum II 芯片渲染图](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ibm_telum_ii_hot_chips_2024_wechat_article_zh/c1e6514cb8fd45ca_11_figure.jpg)

把这种 virtual cache 引入客户端很有吸引力。Ryzen 9 9950X 两块 CCD 合计有 64 MB L3 与 16 MB L2，共 80 MB；若单线程能使用全部，已接近一块 V-Cache CCD 的 96 MB。双 CCD 都堆 V-Cache 的假想产品甚至可提供超过 200 MB virtual L3。

真正障碍是互连。Zen 5 CCD 的 Infinity Fabric 读/写只有约 64/32 GB/s；上一代 Telum 的 dual-chip module 之间已有约两倍带宽，同 module 芯片间更高。

![图 12：Z16 dual-chip module 的高速链路，同模块与跨模块带宽均显著高于客户端 CCD](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ibm_telum_ii_hot_chips_2024_wechat_article_zh/1d6721585086cbfd_12_figure.jpg)

客户端是否愿为 advanced packaging 付费也是问题。若高端游戏 CPU 能承受类似顶级 GPU 的价格，CoWoS-R RDL interposer 或类似封装、再配 virtual L3，或许还能从 cache-sensitive 游戏中挖出性能；这只是延伸设想，不是 IBM 或 AMD 的产品计划。

## 结语

Telum II 的核心思想不是简单“堆 360 MB SRAM”，而是让容量随线程活跃度移动：核心忙时 36 MB L2 保持私有，核心闲时容量转为 virtual L3；跨芯片的空闲 L2 再组成 virtual L4。它用低 miss rate 抵消复杂查找，用高速封装互连把单线程可用容量扩大到 GB 级。

这是一套为大型机交易延迟、单线程性能和昂贵封装共同定制的方案。把它移植到消费 CPU，必须同时解决链路带宽、探测能耗、封装成本与一致性复杂度，不能只看缓存总容量。
