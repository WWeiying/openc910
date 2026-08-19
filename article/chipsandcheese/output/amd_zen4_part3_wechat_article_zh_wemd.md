---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "amd_zen4_part3_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*AMD’s Zen 4, Part 3: System Level Stuff, and iGPU*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2023 年 1 月 5 日
> - 链接：https://chipsandcheese.com/p/amds-zen-4-part-3-system-level-stuff-and-igpu

前两篇已经分析 Zen 4 核心与存储层次，这一篇收拢其余值得追究的系统现象：短时间 Boost、CCD 到 I/O Die 的 Infinity Fabric 带宽、线程数为何会反向影响 DRAM 效率，以及 Raphael 上极小的 RDNA 2 核显。很多结果可能与这颗 Ryzen 9 7950X 样品有关，也未必显著改变应用性能；重点是理解曲线暴露的系统约束，而不是再做一轮常规跑分。

## Boost：同一颗 7950X 也有“快 CCD”与“慢 CCD”

AMD 标称 7950X 最高 Boost 为 5.7 GHz，外界曾讨论 5.85 GHz，但这颗样品没有达到后一个数字。测试逐核运行寄存器到寄存器的依赖整数加法，以单周期加法的延迟反推时钟。核心 0、3、4 最高，且都位于第一颗 Core Complex Die（CCD）。

![图 1：逐核心 Boost 频率](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part3_wechat_article_zh/b0e4699294e7edf6_01_figure.png)

*图 1：纵轴没有从零开始，以放大核心间差异。该图是单颗样品的实测，不代表所有 7950X。*

第二颗 CCD 的核心约为 5.51～5.54 GHz，比第一颗低 100～200 MHz。测试过的 5950X 与 3950X 也都由第一颗 CCD 包含最高频核心，因此一种可能是 16 核型号只对其中一颗 CCD 做最高 Boost 档分箱；材料没有厂商确认，不能把它写成固定规则。

![图 2：Zen 2、Zen 3 与 Zen 4 的逐核心频率离散](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part3_wechat_article_zh/87ffdd46614bf0e2_02_figure.jpg)

*图 2：这三颗具体样品中，Zen 3/4 的核心间离散小于 Zen 2。制程成熟度、分箱与样品差异都会影响结果。3950X 上约 7%～8% 的差距更可能让调度位置影响性能，而 5950X/7950X 的 3%～4% 较难感知。*

为了查看亚毫秒到数百毫秒的变化，测试用 `RDTSC` 高频采样并增加每个样本的迭代次数。相同核心的重复结果稳定，但核心之间不同：第一颗 CCD 某些核心短暂超过 5.71 GHz，核心 0、2 曾在不足 50 ms 内到 5.74 GHz；核心 2 又维持约半秒后出现波动。

![图 3：第一颗 CCD 的短时 Boost 轨迹](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part3_wechat_article_zh/589b2f1afd699fd9_03_figure.png)

*图 3：仍以整数加法延迟估算频率，观察窗口约 700 ms。*

![图 4：第二颗 CCD 的短时 Boost 轨迹](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part3_wechat_article_zh/072f1967f101086d_04_figure.png)

*图 4：第二颗 CCD 从接近 5.6 GHz 起步，极短时间后略微下降。短、长时频率通常只差约 50 MHz，在 Zen 4 的频率下不足 1%。*

真正有意义的结论不是“还有隐藏的几十 MHz”，而是 Zen 4 会以很细的时间粒度连续调整频率，软件不应期待一条完全水平的时钟曲线。

### 体系结构视角：频率测量为什么只能说明“有效节拍”

依赖加法延迟把已知的一周期依赖链当作时钟尺，能捕捉短时变化，却仍会受到线程迁移、计时开销与任何执行节流影响。要区分 PLL 时钟、硬件性能状态和实际执行速率，最好同时读取 APERF/MPERF、固定周期计数器并固定亲和性。单颗样品的好核心位置只能形成分箱假说，不能确认调度器或固件政策。

## 一颗 CCD 的 Infinity Fabric 并不“无限”

Zen 4 每颗 CCD 从 Fabric 读取的链路为 32 B/cycle，写入为 16 B/cycle，工作在 Infinity Fabric Clock（FCLK）域。内存带宽微基准使用 3 GB 数据，并依次填满物理核心；3950X 上先填一颗 CCD 内的两个 CCX。

![图 5：线程扩展下的 DRAM 读取带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part3_wechat_article_zh/128dedbb0a685dca_05_figure.png)

*图 5：7950X 使用 DDR5-6000，3950X 使用 DDR4-3333，内存配置并不相同。7950X 单 CCD 很快碰到 32 B/cycle 链路边界，第二颗 CCD 加入后才可继续提高总带宽。*

Zen 2/3 常让 FCLK 与 DDR 实钟匹配，因此一条 32 B/cycle 链路的理论吞吐恰与 128-bit DDR 通道相当，问题不突出。Zen 4 的 DDR5 更快，一条 IFOP 链路可能先饱和。泄露的 Genoa PPR 暗示 CCD 可配两条 Fabric 链路，但桌面单 CCD 产品是否、怎样配置必须另行确认。

非临时写（Non-Temporal Store）也显示单 CCD 的 16 B/cycle 写链路约束；两颗 CCD 合用则接近平台写入上限。

![图 6：非临时写随核心数扩展](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part3_wechat_article_zh/3862845903b6a839_06_figure.png)

*图 6：两代 CPU 都出现“用满所有核心反而不如较少线程”的峰值回落，因此链路宽度不是唯一因素。*

每线程使用独立数组，总数据量固定，避免控制器把不同线程访问轻易合并。7950X 的最佳结果出现在四线程、每颗 CCD 两核；3950X 也有类似现象。CCX→Fabric 请求、内存带宽和 L3 命中计数器没有显示写合并或 Cache 假象。

![图 7：7950X 在 2 GHz FCLK 下的线程数—带宽关系](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part3_wechat_article_zh/76f5f7defccd1ff4_07_figure.png)

*图 7：四线程取得最高值，继续增加独立流会让地址分布更散。*

![图 8：3950X 的对应扩展曲线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part3_wechat_article_zh/32f747509c33d95b_08_figure.png)

*图 8：在匹配频率下，32 B/cycle Fabric 理论带宽约等于可用 DDR4 带宽。*

更合理的解释是，32 个流给 DRAM 控制器带来的并行度虽高，却降低行缓冲命中与调度自由度；控制器还要避免某一请求饿死，队列可能反压。理论峰值永远还会被 Page miss、读写切换和 Refresh 吃掉。

![图 9：Zen 4 对理论 DRAM 带宽的利用率](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part3_wechat_article_zh/3b315a53f4c53e53_09_figure.png)

*图 9：每颗 CCD 两线程时约达到理论值 81%，是本测试的高效区。*

![图 10：Zen 2 的 DDR4 利用率](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part3_wechat_article_zh/d7ef280be1c391b4_10_figure.png)

*图 10：旧 DDR4 控制器在纯峰值利用率上更高；但 Zen 4 已能让 `REP STOSB` 避免 Read for Ownership，并更好处理 Read-Modify-Write 和全线程普通 AVX 写，绝对带宽也高得多。*

把 FCLK 从 2.0 降到 1.6 GHz后，写带宽的下降几乎正好对应两颗 CCD 各 16 B/cycle 链路少掉的容量。

![图 11：2.0 与 1.6 GHz FCLK 下的带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part3_wechat_article_zh/3d147a8153ab463e_11_figure.png)

*图 11：深红为 2.0 GHz，浅红为 1.6 GHz。写带宽清楚受 Fabric 限制；读取仍高于按 32 B/cycle×FCLK 得到的单链路值，且 FCLK 降 20% 只让最大读带宽降 5.8%，不能说读取由同一瓶颈线性控制。*

### 体系结构视角：带宽峰值为何可能随线程数下降

未完成请求越多，不一定越快。请求若分散到更多 DRAM Row/Bank，控制器既损失 Page hit，又要承担公平性、Refresh 和读写方向切换；队列满后，延迟会先陡升，再通过反压降低有效吞吐。验证瓶颈要同时扫线程数、FCLK、UCLK、内存频率与访问模式，并观察 Fabric/DRAM 事务，而不能只凭一条峰值曲线定位内部队列。

## Raphael 核显：一组 WGP 的最小 RDNA 2

Raphael 是 AMD 近年第一款带核显的高性能桌面平台。I/O Die 从 GlobalFoundries 12 nm 转到 TSMC 6 nm，控制逻辑和 SRAM 缩小，为一颗主要用于亮机的最小 RDNA 2 GPU 腾出面积：只有一个 Work Group Processor（WGP）。

![图 12：Raphael 核显的 DRAM 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part3_wechat_article_zh/58636157f9c61b31_12_figure.png)

*图 12：只用一个 Workgroup，因为硬件也只有一个 WGP；更多 Workgroup 反而因争用和更不线性的访问降低带宽。大工作集略高于 60 GB/s，既可能接近单 WGP 能力，也接近假设 32 B/cycle、2 GHz Fabric 的 64 GB/s，因而无法用此图识别 Fabric 上限。*

缓存配置非常小：64 KB L1、256 KB L2，没有独立显卡 RDNA 2 的 Infinity Cache，L2 miss 直接去内存。此前 RDNA(2) 常见 128 KB L1，Renoir 核显则用 1 MB L2 抵消 DDR4 带宽不足。

测试还发现一个方法学陷阱：若编译器认定整个 Wavefront 读取相同值，会生成 `s_load_dword`，走独立的标量 Cache。阻止这种 Uniform 推断后才会生成 `global_load_dword`，走向量路径并测到更高延迟；近代 Nvidia/Intel 因共享 Cache，未出现同样差别。

![图 13：AMD GPU 标量侧 Cache 与内存延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part3_wechat_article_zh/e4b4a49dc0c249c5_13_figure.png)

*图 13：容量拐点确认 Raphael 为 64 KB L1、256 KB L2。它的 L1 因频率较低而比桌面 RDNA 2 慢，L2 却更低延迟；1 GB 主存端约 191 ns，优于 RX 6900 XT 的 250 ns 以上，也远好于 Renoir GPU 侧。Renoir 在越过 L2 后的阶梯还混入 TLB 层级，128 MB 后可能是真正 TLB miss。*

![图 14：GCN 与 RDNA 2 的标量/向量读取差异](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part3_wechat_article_zh/df6bc3987ab7b7ed_14_figure.png)

*图 14：AMD 的向量路径偏吞吐，延迟惩罚在 GCN 尤其明显；RDNA 2 已大幅改善。本次没有完成 Raphael 的向量 Cache 延迟测试，这张图只作架构背景。*

核显与 CPU 共享物理内存时，可以把同一页面映射到两边而不复制。若确实需要拷贝，Intel 因 CPU/GPU 共享 L3，小尺寸非常快；AMD 没有这条共享 L3 路径，但共享 DDR 仍比离散 GPU 走 PCIe 快，大尺寸时 Raphael 的 DDR5 让它略胜 Tiger Lake。

![图 15：Host 与 GPU 之间的复制带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part3_wechat_article_zh/19598d0dec880f8d_15_figure.png)

*图 15：小尺寸体现共享 L3 的优势，大尺寸则转为 DDR/互连问题。该结果包含整颗 SoC 的 Cache、内存控制器和驱动路径，不能只归因于 RDNA 2 核心。*

## 结语

这颗 7950X 的 Boost 呈现每 CCD 分箱与毫秒级细调；单 CCD 的 32/16 B/cycle IFOP 链路会在合成负载中出现边界，但 DRAM 调度又使“更多线程”不必然带来更高带宽。Raphael 核显则展示 RDNA 2 可以缩到 64 KB L1、256 KB L2和单 WGP，仍保留低延迟 Cache 特征。三组观察的共同点是：核心频率、片上链路、DRAM 和 GPU Cache 必须作为系统共同分析，任何单一峰值都不足以确认实现。

## 参考资料

- Chester Lam, *AMD’s Zen 4, Part 3: System Level Stuff, and iGPU*, Chips and Cheese, 2023-01-05
- AMD Zen 4、Genoa PPR 与 RDNA 2 公开资料（文章所引）
- Hardware Unboxed、Gamers Nexus 的 7950X 持续全核频率测试（背景对照）
