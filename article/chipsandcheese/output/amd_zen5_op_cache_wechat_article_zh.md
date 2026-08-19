# 关掉 Zen 5 的 Op Cache：双译码集群到底能做什么

> **文章来源**
>
> - 文章：*Disabling Zen 5’s Op Cache and Exploring its Clustered Decoder*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2025 年 1 月 23 日
> - 链接：https://chipsandcheese.com/p/disabling-zen-5s-op-cache-and-exploring

Zen 5 有两组取指与译码集群，每组最多译码四条 x86 指令。它们分别服务一个 SMT 线程，因此只有双线程同时运行时，核心才能合计达到 8-wide Decode。正常情况下，前端的主角却是约 6K 项 Op Cache（微操作缓存），译码器更像缺失填充与补充路径。

通过设置 MSR `0xC0011021` 的 bit 5，可以关闭 Op Cache，单独观察译码路径。这个设置只用于结构探测，不代表正常软件的优化方式。被测 Ryzen 9 9900X 为 12 核、两个 6 核 CCD，内存为 DDR5-5600；与此前使用 9950X、DDR5-6000 的数据不能直接混作同平台对比。

![图 1：Zen 5 双取指/译码集群](amd_zen5_op_cache_figures/01_figure.png)

*图 1：每个线程对应一套 4-wide 路径，两线程合计八条；单线程不会借用另一套译码器。*

## 一、关掉 Op Cache 后，前端到底有多宽

NOP 微基准先验证基本带宽。8-byte NOP 的单线程取指约为 16 B/cycle，并没有达到幻灯片容易让人联想到的 32 B/cycle；换成 4-byte NOP，单线程可达 4 IPC，双线程合计 8 IPC。

![图 2：8-byte NOP 的单线程指令带宽](amd_zen5_op_cache_figures/02_figure.jpg)

![图 3：4-byte NOP 的单、双线程译码吞吐](amd_zen5_op_cache_figures/03_figure.jpg)

*图 2、3：译码宽度和字节供给宽度是两项限制。每条指令越长，越容易先撞到取指字节带宽。*

![图 4：双线程下的聚合译码能力](amd_zen5_op_cache_figures/04_figure.png)

*图 4：两个线程各自使用一套集群，才能把总吞吐推到 8 条指令/周期。*

Zen 5 还复制了取指侧的未命中处理能力。代码超出 L1I 后，双线程能并行产生更多填充请求，体现出比单纯“多一组译码器”更强的指令级内存并行性。

![图 5：代码工作集增大后的取指带宽](amd_zen5_op_cache_figures/05_figure.png)

![图 6：单线程 L1I/L2 供给](amd_zen5_op_cache_figures/06_figure.png)

![图 7：双线程下的指令侧未命中带宽](amd_zen5_op_cache_figures/07_figure.png)

*图 5～7：第二套前端路径不仅增加译码槽位，也让两个线程更好地重叠 L1I Miss。具体 Miss Queue 数量没有公开，曲线只能证明并行能力提高。*

### 体系结构视角：宽译码器并不等于持续宽供给

x86 指令可变长，前端要先确定边界、处理跨行、分支和微码指令，再把微操作顺序送入重命名。单线程很难让两套独立流在保持程序顺序的同时无代价合并，因此 Zen 5 把双集群用于 SMT。Op Cache 则绕过高成本译码，让常见代码直接以微操作形式供给后端；两者解决的是不同场景。

## 二、与 Excavator 对照：复制取指路径的重要性

Excavator 也有双译码集群，但两个线程共享一条 L1I 取指路径。代码位于 Cache 内时，它和 Zen 5 都能获得不错的合计译码吞吐；工作集溢出后，Excavator 的带宽下降更明显。

![图 8：Excavator 的双模块前端](amd_zen5_op_cache_figures/08_figure.jpg)

![图 9：Excavator 与 Zen 5 的 Cache 内吞吐](amd_zen5_op_cache_figures/09_figure.jpg)

![图 10：大代码工作集下的单线程对照](amd_zen5_op_cache_figures/10_figure.png)

![图 11：大代码工作集下的双线程对照](amd_zen5_op_cache_figures/11_figure.png)

*图 8～11：Excavator 的 64 KB L1I 有容量优势，8-byte NOP 时也有较强字节带宽；但两个线程共享填充路径，L2 代码带宽远低于 Zen 5 的双路径结果。Excavator 数据由 cha0shacker 协助采集。*

## 三、SPEC CPU2017：单线程很依赖 Op Cache，双线程却没那么依赖

关闭 Op Cache 后，SPEC CPU2017 单线程整数分数下降 20.3%，浮点下降 16.8%。同类实验中，Zen 4 只下降 11.4% 和 6.6%。这说明 4-wide 译码器不足以持续喂满 Zen 5 更宽的后端。

![图 12：SPEC CPU2017 单线程总体变化](amd_zen5_op_cache_figures/12_figure.jpg)

![图 13：整数子项变化](amd_zen5_op_cache_figures/13_figure.png)

![图 14：浮点子项变化](amd_zen5_op_cache_figures/14_figure.png)

*图 12～14：`548.exchange2` 等高 IPC 负载对单线程译码宽度极敏感；Zen 5 关闭 Op Cache 后的损失明显大于 Zen 4。*

双线程、每核两份 SPEC Copy 时，结果反过来：Zen 5 的整数和浮点只下降约 4.9% 与 0.82%，而 Zen 4 下降约 16% 与 10.3%。两套独立译码集群终于同时工作，足以覆盖大多数双线程负载。

![图 15：SPEC 双线程总体变化](amd_zen5_op_cache_figures/15_figure.png)

![图 16：双线程整数子项](amd_zen5_op_cache_figures/16_figure.png)

![图 17：双线程浮点子项](amd_zen5_op_cache_figures/17_figure.jpg)

*图 15～17：双集群主要改善 SMT 时的最坏供给情形。它不是把每个单线程都变成 8-wide，而是避免两个线程争用同一译码器。*

`525.x264` 的 IPC 在关闭 Op Cache 后甚至略有上升，但最终分数没有同步提高，可能混入 Boost 频率变化。`507.cactuBSSN` 则出现少数真实的 Decoder-only 得分优势。

![图 18：部分工作负载的 IPC 与得分并不同步](amd_zen5_op_cache_figures/18_figure.jpg)

![图 19：cactuBSSN 的特殊结果](amd_zen5_op_cache_figures/19_figure.jpg)

*图 18、19：不能只用 IPC 代替完成时间；频率和执行指令数都可能变化。*

cactuBSSN 的 Op Cache 覆盖率从单线程约 75.94% 降到双线程约 61.79%。AMD 的优化指南指出，Op Cache 与 Decoder 模式频繁切换本身存在代价；当工作负载 IPC 不高、覆盖率又不稳定时，一直走译码路径反而可能减少切换。

![图 20：cactuBSSN 的 Op Cache 覆盖率](amd_zen5_op_cache_figures/20_figure.jpg)

![图 21：前端模式切换示意](amd_zen5_op_cache_figures/21_figure.jpg)

![图 22：双线程下的前端来源比例](amd_zen5_op_cache_figures/22_figure.jpg)

*图 20～22：这是一项局部例外，不意味着关闭 Op Cache 是普遍优化。多数高 IPC 负载仍明显受益于缓存微操作。*

## 四、PMU 显示单译码器为什么会吃力

测试使用 Zen 5 的 `0xAA` 类前端来源事件，并以 `cmask=1` 观察各路径活跃周期。关闭 Op Cache 后，即使某些浮点负载平均 IPC 低于 3，单译码器仍可能在 90% 以上周期工作；双线程的两套译码器则有更多余量，只有 exchange2、imagick 等高 IPC 负载接近压力边界。

![图 23：单线程 Op Cache 与 Decoder 活跃周期](amd_zen5_op_cache_figures/23_figure.jpg)

![图 24：关闭 Op Cache 后的 Decoder 活跃率](amd_zen5_op_cache_figures/24_figure.jpg)

![图 25：SPEC 整数前端来源](amd_zen5_op_cache_figures/25_figure.png)

![图 26：SPEC 浮点前端来源](amd_zen5_op_cache_figures/26_figure.png)

![图 27：双线程前端活跃率](amd_zen5_op_cache_figures/27_figure.png)

![图 28：双线程下的高 IPC 子项](amd_zen5_op_cache_figures/28_figure.png)

*图 23～28：单线程 4-wide Decoder 很容易长期忙碌；双线程总计 8-wide 的供给能力更充裕。PMU 活跃周期并不等于每周期都交付满宽微操作。*

### 体系结构视角：为什么平均 IPC 不高，前端仍可能满载

平均 IPC 会被分支恢复、Cache Miss 和后端阻塞拉低；真正需要指令带宽时，需求往往以突发形式出现。前端必须在后端重新获得空间后迅速补满队列。Op Cache 的意义不仅是把长期平均供给从 4 提到更高，也是在短窗口内降低变长译码和模式切换的成本。

## 五、游戏与渲染：低 IPC 游戏不敏感，单线程渲染很敏感

游戏测试关闭 Boost，把 CPU 固定在 4.4 GHz，并把 Radeon RX 6900 XT 固定在 2 GHz，使用 1080p 中画质。Cyberpunk 2077 关闭 Op Cache 只损失约 0.17%，GTA V 大部分 Pass 也近乎无差，只有第 4 段约 1.3%。两款游戏 CPU IPC 均低于 1，前端有足够时间通过译码器供给。

![图 29：Cyberpunk 2077 性能](amd_zen5_op_cache_figures/29_figure.png)

![图 30：Cyberpunk 的前端来源](amd_zen5_op_cache_figures/30_figure.jpg)

![图 31：GTA V 各测试段](amd_zen5_op_cache_figures/31_figure.png)

![图 32：GTA V 前端活跃率](amd_zen5_op_cache_figures/32_figure.jpg)

*图 29～32：Cyberpunk 的 Op Cache 供给率约 83.5%，但平均仅约 16.3% 周期活跃；Decoder-only 约 27.4%。GTA V 对应约 77% 覆盖，活跃率约 16.4%/7.9%，关闭后译码器约 29.5%。这些比例说明“命中很多”不等于“性能一定敏感”。*

Cinebench 2024 单线程不同：Op Cache 带来约 13.5% 提升。开启时平均约 2.45 IPC，微操作缓存与译码器分别在约 35.4% 和 11.5% 周期活跃；关闭后约 2.15 IPC，译码器活跃率超过 69%。约 42.8% 的微操作送往 FP 侧，部分瓦片区间 IPC 可达 3.63，单个 4-wide Decoder 的余量很快耗尽。

![图 33：Cinebench 2024 单线程性能](amd_zen5_op_cache_figures/33_figure.png)

![图 34：单线程 IPC 与前端活跃率](amd_zen5_op_cache_figures/34_figure.png)

![图 35：渲染不同阶段的 IPC 波动](amd_zen5_op_cache_figures/35_figure.png)

*图 33～35：高 IPC 的突发渲染阶段把单译码器推到极限，因此平均性能出现两位数差距。Windows 监控以一秒采样，短时峰值只能作趋势观察。*

多线程 Cinebench 中，Op Cache 只提升约 2.2%。覆盖率约 78.1%，部分时间低于 70%，但双集群通常能补上缺口。事件数按 4.4 GHz 与 12 核归一化；由于事件按线程计活跃周期，口径不能直接与单线程图混用。

![图 36：Cinebench 2024 多线程](amd_zen5_op_cache_figures/36_figure.jpg)

![图 37：多线程前端来源与活跃率](amd_zen5_op_cache_figures/37_figure.jpg)

*图 36、37：双译码集群在 SMT 和全核渲染中承担保险路径，Op Cache 的边际收益因此显著缩小。*

## 六、双集群的准确定位

Zen 5 的双译码器不是单线程峰值性能的主通道。6K 项 Op Cache 仍负责大多数热点代码，单线程只用一套 4-wide Decoder；第二套集群的价值主要有三点：

1. 两个 SMT 线程不必共享一个译码瓶颈。
2. 指令工作集溢出时，两条取指路径提高 L1I Miss 并行性。
3. Op Cache 覆盖率下降或模式频繁切换时，Decoder 提供可用的后备供给。

这也解释了看似矛盾的结果：单线程 SPEC 和 Cinebench 很依赖 Op Cache，双线程 SPEC、全核 Cinebench 和低 IPC 游戏却没有同等幅度的损失。前端设计不能只看“几宽”，还要看宽度属于哪个线程、哪条路径，以及队列能否把突发供给平滑到后端。

## 参考资料

- Chester Lam，*Disabling Zen 5’s Op Cache and Exploring its Clustered Decoder*：https://chipsandcheese.com/p/disabling-zen-5s-op-cache-and-exploring
- AMD，*Software Optimization Guide for AMD Family 1Ah Processors*
