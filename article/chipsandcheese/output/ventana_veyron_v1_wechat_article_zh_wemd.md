---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "ventana_veyron_v1_wechat_article_zh"
---

> 英文标题：Hot Chips 2023: Ventana’s Unconventional Veyron V1
> 撰文：Chester Lam
> 首发：Chips and Cheese，2023 年 9 月 1 日
> 链接：https://chipsandcheese.com/p/hot-chips-2023-ventanas-unconventional-veyron-v1

Ventana 的 Veyron V1 面向高核心数服务器，采用八宽乱序执行，却在 BTB、指令缓存、TLB、L1D 和执行端口上连续做出非常规选择。目标频率为 3.6 GHz；降到 2.4 GHz 时，单核功耗低于 0.9 W。

![图 1：根据公开资料整理的 Veyron V1 方框图](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ventana_veyron_v1_wechat_article_zh/7fafc10d0ad32b15_01_figure.png)

## 流水线与恢复

V1 的误预测流水线约 15 周期，比 Zen 4 的最低约 11 周期、Neoverse N2 的约 10 周期更长。

![图 2：Ventana 展示的 V1 流水线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ventana_veyron_v1_wechat_article_zh/086c7c517c335810_02_figure.png)

后续 V2 宣称降低了代价。V1 在 IX1 发现误预测后从 RPS 重启；若真实方向/目标能直接反馈到 PNI（Predict Next IP）后继续，理论上可再缩短两拍至 13 周期。这是依据级名和路径的推演。

![图 3：误预测检测和可能的重启位置](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ventana_veyron_v1_wechat_article_zh/2c58085f9260bfc0_03_figure.png)

## 单级 12K BTB

现代前端通常用小而快的 L1 BTB 保证连续 taken，再用更大的慢速后级覆盖大 footprint。V1 却采用单级 12K 项 BTB，并宣称“single cycle next lookup”，意味着它可能同时得到大容量和连续 taken 分支吞吐。

![图 4：12K 项单级 BTB 与前端参数](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ventana_veyron_v1_wechat_article_zh/5ae0fa9d5d4ecced_04_figure.png)

作为参照，Golden Cove 的 12K 项末级 BTB 约三周期。V1 若 BTB 未给出正确目标，可在约三周期后重定向，可能由接近首个译码级的分支地址计算器完成。由于 12K 容量很大，这类覆盖应较少，但仍需硅片测量确认。

### 体系结构视角：删除层级并没有删除物理约束

单级结构减少覆盖和状态迁移，却必须让同一个阵列同时满足容量、时延、带宽和功耗。判断它是否成功，不能只看项数：需要构造不同分支 footprint、taken 密度和地址冲突模式，测连续目标吞吐、容量拐点和重定向延迟。

## 512 KB L1/L2 指令缓存

V1 同样把常见的 L1I+L2I 合为 512 KB 指令缓存，前面只有一个主要用于紧凑循环省电的小型 Loop Buffer。代码 footprint 超出常见 32/64 KB L1I 时，它省去了先查小缓存、再从 L2 搬运的能量和延迟。

![图 5：V1 Die 图中的两半 L2](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ventana_veyron_v1_wechat_article_zh/e48f23726bc822ce_05_figure.jpg)

代价是 L2 指令/数据被固定切成 512+512 KB，无法像统一 1 MB L2 那样动态把容量让给代码或数据。若做成统一阵列，取指的高带宽又可能与数据访问争用。

![图 6：即使低性能核心也需要很高取指带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ventana_veyron_v1_wechat_article_zh/c1ffc5054ea83a81_06_figure.png)

因此 512+512 KB 相比 Zen 1～3 的统一 512 KB 更有总容量优势，但面对 Zen 4 和多款 Arm 核心的统一 1 MB L2，灵活性较差。

V1 支持每周期最高 64 B 的全流水非对齐取指。分支跳到取指块中间后，仍能从跨边界的两个块拼出完整带宽。

![图 7：非对齐取指如何减少跳转后的带宽损失](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ventana_veyron_v1_wechat_article_zh/dc47d394b650f2c9_07_figure.png)

常规做法需要两个阵列访问再合并；对 512 KB 指令缓存每周期完成这一点并不容易。公开资料没有说明 bank、读口或拼接机制，因此不能进一步确认实现。

## 单级 3K TLB 与 VIVT L1D

iTLB 和 DTLB 都只有一个层级，各 3K 项，容量接近其他核心的最大 L2 TLB。指令侧每次访问 512 KB 缓存时查询大 iTLB，但顺序代码一次翻译可服务多条指令。

数据侧则直接删除 L1 DTLB，让 64 KB L1D 使用虚拟索引、虚拟标签（VIVT）；主 TLB 放在去 L2 的路径上，远离 L1 命中关键路径。

![图 8：VIVT L1D 与常见 VIPT 方案比较](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ventana_veyron_v1_wechat_article_zh/974434a150a6271e_08_figure.png)

传统 VIVT Cache 会因 context switch 或页表映射改变而失效，还会遇到多个虚拟地址映射同一物理地址的 synonym 问题。V1 在 Tag 中跟踪 ASID，从而避免切换进程就清空 L1D，并宣称能处理 VA→PA 别名；一种可能做法是在 L2 TLB 记录别名并在 snoop 到来时一并失效，但这只是推断。

L1D 仍为四周期，没有因虚拟寻址降低 Load-to-use 延迟；收益主要是省去一级 DTLB 面积与功耗。即使 miss 稍高，L2 约 11～12 周期的延迟也可缓和损失。

### 体系结构视角：VIVT 的难点在一致性，而不只是命中延迟

正常访问可直接用 VA 查 L1D；映射撤销、页迁移、同义地址和外部 snoop 才是真正压力。验证时需覆盖 ASID 切换、共享页别名、TLB shootdown、DMA 一致性与跨核写入。没有这些边界测试，四周期命中数字不足以证明方案稳健。

## 少而灵活的执行端口

虽然前端八宽，V1 只有四条同时覆盖整数和访存的执行端口。现代程序通常受依赖和内存延迟限制，很少持续占满所有端口；Ventana 希望用四条高利用率管线替代更多低利用率管线。

![图 9：V1 的四条组合执行端口](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ventana_veyron_v1_wechat_article_zh/6df5b73762ce161e_09_figure.png)

![图 10：减少端口带来的面积与功耗收益](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ventana_veyron_v1_wechat_article_zh/ee454b8508fd7648_10_figure.png)

这并非完全没有先例：Intel 长期让浮点与整数单元共享端口，A64FX 也有 AGU/ALU 组合端口。端口更少意味着调度器和寄存器文件端口更少，而寄存器文件面积主要受位宽及读写端口数影响。但吞吐密集代码仍可能暴露执行资源不足。

## 面积、缓存与集群

V1 核心面积小于 Zen 4c 和 Neoverse V2，但它也牺牲了功能：没有向量单元，只有一条标量 FP 管线；L2 容量也少于 V2。因此面积优势不能被解读为在相同性能/功能下全面领先。

![图 11：V1 与 Hot Chips 2023 其他核心的面积比较](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ventana_veyron_v1_wechat_article_zh/c9da0cbe274742e8_11_figure.jpg)

Neoverse N2 宽度更小、BTB/TLB 也更小；V1 在大代码 footprint 的整数负载可能更强，N2 则至少有 2×128-bit 向量能力。

Ventana 用 16 核 compute chiplet 连接中央 I/O Die，类似 Bergamo 的 hub-and-spoke。

![图 12：Veyron V1 与 Bergamo 的 Chiplet 组织](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ventana_veyron_v1_wechat_article_zh/60a7b177e2b6676a_12_figure.png)

![图 13：TSMC 5 nm 上 16 核集群面积比较](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ventana_veyron_v1_wechat_article_zh/361d4aefb602f4fd_13_figure.jpg)

初看 V1 略省面积，但 Ventana 图中未包含 Die-to-Die 接口；补入这部分后，chiplet 大小可能与 Bergamo 接近。

![图 14：把核心、L3 Slice 和 Fabric Slice 放回集群布局](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ventana_veyron_v1_wechat_article_zh/726d665aafaf0f63_14_figure.jpg)

V1 每核 3 MB L3，16 核共享 48 MB；Zen 4c 每核 2 MB，但拥有统一 L2 和强得多的 FP/Vector。跨实现面积比较还受 SRAM 密度、PHY 是否计入和版图留白影响，只能看趋势。

## 环形互连仍有未知项

Ventana 称使用双环，但 2.5 GHz 下 160 GB/s 二分带宽相当于 64 B/cycle。若单方向数据通路为 32 B/cycle，也可能是一条环的两个方向；若确为双环，则每条可能只有 16 B/cycle。

![图 15：集群环形互连与带宽披露](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ventana_veyron_v1_wechat_article_zh/6bf616fc82556138_15_figure.png)

公开数字不足以确定拓扑和位宽。分开的 512+512 KB L2 可能让 L3 流量更高，因此实际 L3 延迟、热点 slice 冲突与多核带宽尤其重要。

## 结语

![图 16：Veyron V1 的关键非常规选择](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/ventana_veyron_v1_wechat_article_zh/1de92085a0236596_16_figure.png)

V1 用 ASID 和 synonym 处理缓和 VIVT 风险，以足够大的两半 L2 支撑分离层级，又把大 BTB/TLB 放在宣称可接受的时延位置。它很可能是一颗有竞争力的标量整数核心，而不是无代价的“架构捷径”。

吞吐型应用会更困难：V1 没有向量能力，RISC-V 向量软件生态本身也尚未成熟。最终评价必须等待硅片，尤其要验证单级大阵列的时序、VIVT 一致性、四端口热点和环形互连。其价值在于展示了另一种平衡容量、层级、面积与功耗的方法。

## 参考资料

- Ventana Hot Chips 2023 Veyron V1 演讲
- Chips and Cheese：Hot Chips 2023: Ventana’s Unconventional Veyron V1
