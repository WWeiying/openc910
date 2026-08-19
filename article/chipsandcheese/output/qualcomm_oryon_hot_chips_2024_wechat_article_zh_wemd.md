---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "qualcomm_oryon_hot_chips_2024_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*Hot Chips 2024: Qualcomm’s Oryon Core*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2024 年 8 月 27 日
> - 链接：https://chipsandcheese.com/p/hot-chips-2024-qualcomms-oryon-core

Qualcomm 在 Hot Chips 2024 公布了更多 Oryon 细节。它不是单纯把 Decode 做到 8-wide，而是同时投入大容量 TAGE 分支预测、64 B/cycle 取指、分布式调度、超大 TLB、12 MB 共享 L2 与激进预取。宽度只是结果，能否持续找到正确指令和数据才是前提。

![图 1：Hot Chips 2024 的 Snapdragon X Elite 纪念章](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_oryon_hot_chips_2024_wechat_article_zh/86031b41ab1f189a_01_figure.jpg)

## 一、80 KB 条件预测器怎样服务 8-wide Decode

Qualcomm 确认 Oryon 的条件分支预测采用 TAGE（Tagged Geometric History Length，带标签几何历史长度）方法，可按分支选择不同历史长度。条件预测存储预算约 80 KB，接近 96 KB L1D；这个数字虽大，但与论文中 64 KB L-TAGE 以及现代大核的预测阵列规模处于同一量级。间接分支预算更小，也利用全局历史在多个目标间选择。

![图 2：Oryon 分支预测器的容量预算](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_oryon_hot_chips_2024_wechat_article_zh/8ca8c7ff7acf5066_02_figure.jpg)

*图 2：容量来自 Qualcomm 幻灯片；具体 Table 数、History Length 和 Hash 方式未公开。*

误预测恢复约 13 周期。Qualcomm 称它不是行业最低，但与整颗核心平衡；Zen 4 优化指南给出约 11～18 周期、常见约 13 周期。Oryon 每周期从 L1I 取 64 Byte，Gerard Williams 解释宽取指能在误预测后更快重新填满流水线，也能平滑其他短暂气泡。

8-wide 的选择还带有长期规划意味：一座更宽的“桥”未必立即带来同等收益，却给未来优化留下空间。工程团队会用仿真评估每项特性的收益与成本；8-wide 被采用，意味着 Qualcomm 判断其长期收益值得付出。

![图 3：Oryon 前端与 8-wide 管线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_oryon_hot_chips_2024_wechat_article_zh/87543545aecb4938_03_figure.jpg)

### 体系结构视角：宽核心先要解决“预测带宽”

8-wide Decode 若每十几条指令就遇到一个 Taken Branch，实际 Fetch Block 很容易被切碎。大 TAGE、宽目标预测和 64 B/cycle 取指共同减少空槽；13 周期恢复则决定一次错误要浪费多少在飞工作。只比较 Decode Width，会忽略预测准确率与恢复延迟的乘积。

## 二、分布式后端与反常的大 Load/Store Scheduler

Oryon 的标量与向量侧都使用物理寄存器文件，并各有来自 LSU 的四路数据供给。作为参照，Zen 4 整数侧每周期最多三次 Load、向量侧两次。

![图 4：Oryon 标量与向量执行布局](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_oryon_hot_chips_2024_wechat_article_zh/8eb4e53e9b7c5a1d_04_figure.jpg)

Qualcomm 选择分布式 Scheduler。小队列更容易从 Ready 操作中选出较老者，也利于高速时序；代价是操作只能等待指定端口，可能出现某队列拥堵、相邻端口闲置。

![图 5：Load/Store 调度资源](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_oryon_hot_chips_2024_wechat_article_zh/78ac97b35153e190_05_figure.jpg)

LSU 有很大的 64-entry Reservation Station。公开图给出的总调度容量甚至大于 Load/Store Queue，这与许多核心相反。更大队列既缓解瓶颈，也可能容纳 Store Data 等非地址操作。

此前微基准在约 62 个 Outstanding Load 后看到 Rename Stall，曾被理解为 Load 只能使用 64 项 Scheduler；正式幻灯片表明结构并非如此。依赖 Load 可能先撞到别的资源。Store 的行为不同；若一条 Store 拆成 Address 和 Data 两个操作，曲线也可能支持 LSU 总计约 256 项 RS 的解释，但这仍是推断。

![图 6：Load 调度容量微基准](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_oryon_hot_chips_2024_wechat_article_zh/4276a721cb9103dd_06_figure.png)

![图 7：Store 相关容量测试](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_oryon_hot_chips_2024_wechat_article_zh/b4503668b4ef89d4_07_figure.png)

*图 6、7：微基准看到的是“最先耗尽的可见资源”，不能凭 62 直接给 Scheduler 物理项数下结论。*

## 三、96 KB L1D 与异常巨大的地址翻译覆盖

Oryon 的 96 KB L1D 使用 Foundry 标准 Bitcell，并做成多端口。Qualcomm 曾评估更大容量，最终为满足时序与频率选择 96 KB。

![图 8：Oryon L1D 设计](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_oryon_hot_chips_2024_wechat_article_zh/edcd23c57f78cd54_08_figure.jpg)

一级 DTLB 有 224 项；L2 TLB 的覆盖尤其大，目标是即使数据足迹很大，也尽量避免 Page Walk。预取器会提前拉入 Translation，容量越大越不容易被激进预取自身冲刷。L2 TLB Miss 后可并行进行约 10～20 个 Page Walk，Zen 4 对照约为 6 个。

![图 9：Oryon TLB 与地址翻译延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_oryon_hot_chips_2024_wechat_article_zh/2c5a1d77dc1d0bdd_09_figure.png)

测试在 128 MB 工作集出现拐点，对应 32,768 个 4 KB Page。Gerard Williams 暗示这来自 TLB 而非 Page-walk Cache。可能是 32K 项，也可能是 8K 项、每项覆盖四个相邻 Page，或 16K 项、每项覆盖两个；AMD 自 Zen 起就使用过相邻页合并。Page Table Walker 内还存在更高级页表项 Cache，容量未披露。

### 体系结构视角：TLB 容量要换算成“覆盖范围”

同样 8K 个 Tag，若每项能合并四个连续 4 KB Page，就能覆盖 128 MB；若使用 2 MB Huge Page，覆盖又会扩大几个数量级。微基准台阶只能给出特定 Page Size 下的有效覆盖，必须结合 Associativity、Page Coalescing 和 Walk Cache 才能反推物理结构。

## 四、12 MB 共享 L2 是 Oryon 内存系统的核心

四核共享 12 MB L2，命中延迟随 Slice 位置约 15～20 周期，说明它可能由多个 Bank/Slice 组成。Qualcomm 认为每核典型占用 2～3 MB，但单核可使用全部 12 MB；与芯片其余部分的接口为 32 B/cycle。

![图 10：Hot Chips 展示的 Snapdragon X Elite](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_oryon_hot_chips_2024_wechat_article_zh/779c2b63992b59c6_10_figure.jpg)

相比 Intel E-Core Cluster 常见 2～4 MB L2，12 MB 容量很大。Meteor Lake Crestmont 的 L2 也约 20 周期，却只有其一小部分容量且频率更低。若四核各占 3 MB，Oryon 的 L2 可以充当 CPU 侧最后一级主 Cache，不再需要专门的大 L3。

![图 11：Oryon Cache/内存延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_oryon_hot_chips_2024_wechat_article_zh/7722a3821c9cd91d_11_figure.png)

激进预取让单线程 DRAM 带宽接近 100 GB/s，其他测试核心约 30 GB/s。独立内存带宽结果也显示，Oryon 单核明显高于 Meteor Lake Redwood Cove，不过 Intel 的 L1/L2 峰值更高。

![图 12：单线程 Cache 与 DRAM 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_oryon_hot_chips_2024_wechat_article_zh/13d06d050d17e5b0_12_figure.png)

L2 之后还有 6 MB System Level Cache（SLC），容量可在 SoC Block 间动态分配。相对 12 MB CPU L2，它对 CPU 的作用较小，更适合 GPU、Display 和其他缺乏大私有 Cache 的模块。

![图 13：Snapdragon X Elite 的 6 MB SLC](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_oryon_hot_chips_2024_wechat_article_zh/b9275caa266d3f6a_13_figure.png)

Oryon 配置多种标准和自研 Prefetcher。简单线性访问中，预取能够跑得足够远，几乎隐藏 L2 延迟；更复杂模式的收益取决于能否识别。

![图 14：不同访问模式下的可见 Load 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/qualcomm_oryon_hot_chips_2024_wechat_article_zh/79c4b991c9d6379c_14_figure.jpg)

*图 14：低延迟不一定代表真实命中层级更近，也可能是预取提前把数据放到了更近位置。随机指针追逐与可预测步长必须分开测试。*

## 五、三组四核与产品级功耗取舍

Snapdragon X Elite 有 12 核，分为三个四核 Cluster。开发早期的 L2 Interconnect 尚不支持更大 Cluster，后续虽增加能力，但没有赶上这一代产品。12 核让同一芯片能在散热更好的设备上扩展多线程性能；实际轻薄本则可能先受功耗和温度限制。它与 Intel/AMD 用不同核心数覆盖功耗档位的策略不同。

Oryon 给出的设计主线很一致：用大预测器保证控制流，用大 TLB 和预取降低地址与数据延迟，再用 12 MB L2 把大部分工作集留在 Cluster 内。8-wide 并不是孤立卖点，而是这套“提前知道下一步、提前拿到数据”的系统结果。

## 参考资料

- Chester Lam，*Hot Chips 2024: Qualcomm’s Oryon Core*：https://chipsandcheese.com/p/hot-chips-2024-qualcomms-oryon-core
- Qualcomm，Hot Chips 2024 Oryon Core Presentation
- André Seznec，*The L-TAGE Branch Predictor*
