---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "cortex_a73_reordering_capacity_wechat_article_zh"
---

> 英文标题：Cortex A73’s Not-So-Infinite Reordering Capacity
> 撰文：Chester Lam
> 首发：Chips and Cheese，2024 年 8 月 4 日
> 链接：https://chipsandcheese.com/p/cortex-a73s-not-so-infinite-reordering-capacity

Cortex-A73 为解决 Arm 早期 64 bit 大核的功耗与散热问题，选择了更紧凑的乱序资源，并似乎实现了很少见的乱序退休（Out-of-Order Retirement）。这种机制也让传统结构容量微基准失效：用 Cache Miss 阻塞最老指令时，后续资源竟还能持续释放。

![图 1：Amlogic S922X 的 DDR4；乱序执行用于隐藏这类内存延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cortex_a73_reordering_capacity_wechat_article_zh/d043345e8ea4802a_01_figure.jpg)

Henry Wong 常用的容量测法大多无法在 A73 上得到拐点，只有 Scheduler 较正常。Discord 用户 muffiny_mcmuffinface 建议用“依赖未完成 Load 的 Branch”阻止退休，才让隐藏容量显现。

## 为什么通常必须顺序退休

前端按程序顺序取指，Rename/Allocate 分配物理寄存器、Load/Store Buffer 等资源，后端可以投机乱序执行；寄存器结果在真正提交前仍是 Speculative，Store 数据也留在 Store Buffer。只有一条指令及其之前的所有指令都确认正确，它才退休并释放内部资源。

![图 2：顺序退休、精确异常与错误路径清除](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cortex_a73_reordering_capacity_wechat_article_zh/ab46a5659b088ec5_02_figure.png)

顺序退休使异常状态精确：若一条指令访问未映射页面，核心丢弃它之后的所有投机工作，操作系统看到的状态恰好停在异常前，处理完后即可恢复。若任由后面的指令提前退休，一旦更老的指令异常，状态就可能无法回滚。

A73 却可能在特定条件下越过未完成 Load 退休。一个合理解释是：地址翻译和页表权限检查完成后，核心已能确信 Load 最终不会产生普通软件异常，剩下只是数据何时返回。灾难性内存故障不在正常恢复模型内。这个解释来自现象推断，并无 RTL 或官方机制说明。

![图 3：未决 Branch 阻塞后测得约 40 个整数结果寄存器](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cortex_a73_reordering_capacity_wechat_article_zh/141b3c908d926e6a_03_figure.png)

Branch 则不能被这样越过：在分支执行前，核心不知道预测是否正确，必须保留之前的重命名状态以恢复。修改后的测试让一个永不 Taken 的 Branch 依赖 Cache Miss，避免方向误预测干扰，同时真正阻塞资源释放。

### 体系结构视角：退休优化解决的是资源周转率

大窗口通常靠增大 ROB、PRF 和队列，但面积、端口和泄漏功耗都会上升。若能证明旧 Load 不会异常，就可提前提交部分年轻指令、释放结果寄存器和队列，让较小物理结构获得更大的“有效窗口”。异常安全条件一旦不完备，代价却是破坏精确状态，因此验证重点应是页 Fault、权限变化、Machine Check 和分支恢复边界，而不仅是性能。

## 鞋带预算下的 Register File

修改后的测试显示，A73 多种资源比 A57/A72 更小。

![图 4：A57、A72、A73 的推测性资源容量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cortex_a73_reordering_capacity_wechat_article_zh/c21c7a8abf95a26a_04_figure.png)

A57 的 Register File Entry 只有 32 bit；64 bit Integer 或 128 bit Vector 要占多个 Entry，这可能是为了兼顾当时大量 32 bit 软件。A72 把 Entry 扩到 64 bit，并提升 FMA，意味着更大存储和更多端口。

A73 改成分离的 Integer 与 FP/Vector Register File：约 41 个 64 bit 整数 Entry、38 个 128 bit FP/Vector Entry 可保存投机结果。分离后各阵列所需端口更少。寄存器文件面积主要由每项宽度和访问端口数量决定，而不是单纯由 Cell 数决定，因此“小粒度统一阵列”并不一定更省面积或功耗。

![图 5：A72 与 A73 寄存器文件和执行端口关系](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cortex_a73_reordering_capacity_wechat_article_zh/40796da76e3cb567_05_figure.png)

A72 端口多且共享一个 Register File，可能需要复制阵列等办法增加读口，软件无法确认。A73 的 35 个可用 Vector Result Entry 还略多于 A72 的 31 个，而且 Scalar Integer 不再与 Vector 抢同一容量。

不过，混合写 Integer/Vector 时 A73 只能容纳约 66 条在途指令，未能把两边 Entry 全部吃满。可能还有类似 Intel Physical Register Reclaim Table 的统一回收资源先耗尽；这同样只是候选解释。

## Load 很多，Store 与 Branch 很少

A73 可有约 50 个在途 Load，远多于其他结构。要达到该数字，测试序列还需混合写入 Integer 和 Vector Destination，否则会先受某一 PRF 限制。相对 A72 约 32 项 LQ，这是很大的提升，通常不会成为首要瓶颈。

Store 则只能在未决 Branch 后保留约 11 个，比 A72 已偏小的 15 项更少。更奇怪的是，独立 Branch 看起来也共享这 11 项资源；它满后，即使 Scheduler 仍有空间，新 Branch 也进不了后端。

![图 6：Store 与 Branch 共享约 11 项容量的测量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cortex_a73_reordering_capacity_wechat_article_zh/0673c58c91487374_06_figure.png)

一种可能是两者都要在 11 项 Verification Queue 中保留位置：Branch 可能误预测，Store 提交会让数据对其他核可见，均需额外确认。但结构名称和实现未公开。无论如何，这个低容量共享资源很可能频繁成为瓶颈。

A73 也没有 Memory Dependence Prediction。只要先前 Store Address 尚未知，年轻 Load 就不能执行；实际上多数 Load 不与 Store 重叠，Core 2 和 Bulldozer 已通过预测让 Load 越过未知 Store。A73 的保守策略会推迟高延迟 Load，并进一步压迫有限窗口。

## 找不到传统 ROB 上限

传统 ROB 按程序顺序记录在途指令，NOP 不占 PRF 或访存队列，最适合测 ROB。A73 的 NOP 即使越过未决 Branch 也没有出现容量拐点。

![图 7：NOP 测试没有找到有限 ROB 容量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cortex_a73_reordering_capacity_wechat_article_zh/1a0461f72dfbc610_07_figure.png)

再把 Integer/FP 写入与 Store 混合，可同时占满三类资源并达到 76 条在途指令，仍不像撞上独立 ROB。由此只能说软件微基准没有发现“ROB-like”统一上限，不能证明物理上绝对没有顺序跟踪结构。

## 性能与频率的最终平衡

乱序退休与 Skymont 16-wide Retire 的目标相似：更快回收资源，让小结构维持可接受吞吐。

![图 8：测试 Cortex-A73 的单板机](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cortex_a73_reordering_capacity_wechat_article_zh/66677cd1ae308036_08_figure.jpg)

当工作负载真要依赖这些结构时，A73 常比 A72/A57 吃亏。libx264 中，它能以更小资源接近 A57；文件压缩则不是如此。

![图 9：A73 在不同负载中的 IPC 对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cortex_a73_reordering_capacity_wechat_article_zh/df0ca1c27325bda3_09_figure.png)

IPC 不是全部。S922X 的四个 A73 可被动散热持续 2.2 GHz，Tegra X1 的四个 A57 即使主动散热也只有 1.8 GHz。

![图 10：折入频率后的实际性能非常接近](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cortex_a73_reordering_capacity_wechat_article_zh/78168edc540bb15a_10_figure.png)

A73 用更小、更窄的核心换更高持续频率，以更低功耗取得接近性能。这提醒我们：提高 IPC 与提高频率都不是天然正确，关键是工作负载、热设计与资源配置能否形成平衡。

## 参考资料

- Chips and Cheese：Cortex A73’s Not-So-Infinite Reordering Capacity
- Henry Wong 的结构容量微基准方法
- Arm Cortex-A73/A72/A57 公开资料
