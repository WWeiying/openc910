---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "amd_infinity_fabric_limits_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*Pushing AMD’s Infinity Fabric to its Limits*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2024 年 11 月 24 日
> - 链接：https://chipsandcheese.com/p/pushing-amds-infinity-fabric-to-its

内存空载延迟只是起点。更接近真实并发环境的办法，是让一个线程做 Pointer Chasing，同时逐步增加流式带宽线程，画出带宽上升时延迟如何恶化。Ampere 在 Hot Chips 2024 也描述过这种“一个延迟敏感应用+逐渐增加带宽型应用”的 Loaded Latency 方法。

![图 1：AmpereOne 的 Loaded Latency 曲线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/7bd4b304173cbea5_01_figure.jpg)

*图 1：横轴带宽、纵轴延迟。本文改为按线程数同时画带宽和延迟，以揭示拓扑位置。*

AMD Zen 用多级互连扩展核心数：若干核共享 Core Complex（CCX）内 L3，CCX 位于 CCD；CCD 再以 Infinity Fabric On-Package（IFOP）连接 I/O Die。IFOP 每 CCD 在 FCLK 域提供约 32 B/cycle 读、16 B/cycle 写。高核心数下，CCX 的外部接口、IFOP、Fabric 队列和 DRAM 控制器都可能排队。

![图 2：Zen 2 的 IFOP 物理接口](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/87af83dc23c57b4b_02_figure.png)

*图 2：来自 AMD ISSCC 2020。接口尺寸与结构是公开图示。*

![图 3：多级争用点示意](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/a2465020a3a1e197_03_figure.png)

*图 3：Zen 2 一颗 CCD 内还有两个 CCX 共用 IFOP，便于分别观察 CCX 与 CCD 层瓶颈。*

## Zen 4：单 CCD 内延迟可从 83 ns 冲到 400 ns以上

平台为 Ryzen 9 7950X3D、DDR5-5600。Zen 4 每 CCD 一个八核 CCX，单核顺序读 3 GB 就接近 50 GB/s。

![图 4：7950X3D 的双 CCD 拓扑](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/e26a0db37d4e517b_04_figure.jpg)

*图 4：V-Cache/普通 CCD 之外，两颗 CCD 各有独立 IFOP，最后汇聚到同一 I/O Die 与内存控制器。*

空载约 82～83 ns；延迟线程与带宽线程都放在普通 CCD 时，只需少数线程就开始填满共享队列，和五个带宽线程竞争时超过 400 ns。

![图 5：同一 Zen 4 CCD 内的 Loaded Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/169de82ead9b4966_05_figure.jpg)

*图 5：最多七个带宽线程加一个延迟线程，均固定在非 V-Cache CCD。曲线证明排队，不能单独识别是哪一级队列。*

把带宽线程移到 CCD0、延迟线程放 CCD1，隔离明显改善；一个带宽线程时反而有异常延迟尖峰，继续增加线程又下降。一个可能性是活跃核数触发了队列预留或单核节流，但没有官方说明。

![图 6：跨 CCD 隔离后的 Zen 4 曲线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/5651138d78f7bd74_06_figure.jpg)

*图 6：八个带宽线程可接近 64 GB/s，延迟却好于同 CCD 场景，说明双 CCD 在合成负载下可形成某种 QoS 隔离。*

交替向两颗 CCD 加线程可同时使用两条 IFOP；每颗一线程就达到最大带宽附近，但十多个流之后 CCD 与内存控制器排队叠加，延迟线程超过 700 ns，Windows Task Manager 也出现明显卡顿。

![图 7：交替加载两颗 CCD 的带宽与延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/d319e79703cd2981_07_figure.jpg)

*图 7：少量线程时总带宽高、延迟仍受控。*

![图 8：高线程数时的延迟失控](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/d5d7cf442064b511_08_figure.jpg)

*图 8：这是极端合成访问，不代表一般桌面负载。*

### 从 Xi 计数器看 L3 miss 之后

Zen 4 L3 可随机采样 miss 并统计延迟。

![图 9：Zen 4 PPR 的 Xi Sampled Latency 事件](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/51f6070be0fe1649_09_figure.jpg)

*图 9：官方定义事件，但“Xi”的展开并未公开。*

文章推测 Xi 是 L3 Complex 的 External Interface，并以 Queue Entry 占用时长采样。

![图 10：Zen 1 L3 Complex 中的 Xi](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/18d22efd37df0904_10_figure.jpg)

*图 10：来自 AMD ISSCC。Xi=External Interface、DP=Datapath 等展开属于合理推测，不是 RTL 确认。*

软件测的是从 AGU、逐级 Cache Lookup 到 Load-to-use 的总延迟；Xi 事件只从 L3 miss 之后开始，因此应更低。

![图 11：软件延迟与 Xi 延迟的范围差异](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/5535ddf4feffad05_11_figure.jpg)

*图 11：二者不能直接当作同一指标。*

![图 12：全系统测试中的两 CCD Xi 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/803a5d0d45df379f_12_figure.jpg)

*图 12：开始阶段软件见 190 ns，延迟线程所在 CCD 的 Xi 约 166 ns；带宽线程所在 CCD 的 L3 miss 流量约 59 GB/s，且自身请求似乎优先。更多线程后 Xi 平均约 200 ns，软件却超过 700 ns，因为延迟线程只占极少流量，平均值掩盖了尾部饿死。横轴为测试时间。*

## Zen 5+DDR5-8000：相同 I/O Die，Loaded Latency 好得多

Ryzen 9 9950X 使用很快的 DDR5-8000，并略提高 FCLK；AMD 推荐甜点仍是 6000 MT/s，因此它不是典型配置。

![图 13：Zen 5 测试平台](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/489722880184c75d_13_figure.jpg)

*图 13：高速内存使单 CCD IFOP 只覆盖 DRAM 理论带宽约 55%，而 Zen 4 测试平台约 71.4%。*

![图 14：Zen 5 同 CCD Loaded Latency](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/e544df6374289bfb_14_figure.jpg)

*图 14：CCX 内争用仍增大延迟，但比 Zen 4 温和，基础延迟也因高速 DRAM 更低。*

Hot Chips 2024 图示 Zen 5 每 CCX 有两个 Xi，并暗示更多 Queue Entry。

![图 15：Zen 5 的双 Xi 组织](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/d80a3fa704eb001f_15_figure.jpg)

*图 15：更多入口可降低一个带宽线程独占队列的概率；具体分配仍未由 RTL 确认。*

跨 CCD 时，Zen 4 的单线程尖峰消失。因为两代使用同一 I/O Die，除了 CCD 结构，AMD 也可能调整了 Fabric 公平性政策。

![图 16：Zen 5 跨 CCD 隔离](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/41cebf47ba1f633a_16_figure.jpg)

*图 16：更快 FCLK/DRAM 与可能的调度变化共同作用，不能只归因于一个因素。*

![图 17：Zen 5 双 CCD 超过 100 GB/s 时的延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/09011f0cebd90bdb_17_figure.jpg)

*图 17：即便总流量超过 100 GB/s，未出现 Zen 4 的约 700 ns 尾部。DDR5-8000 48 GB 套装当时约 250 美元，成本边界也需保留。*

## Zen 2：两 CCX 让争用层级更容易分离

3950X 让 FCLK 与 DDR 实钟匹配，单 CCD 的 IFOP 理论带宽等于 DRAM。单 CCX 达到理论 DRAM 的约 84.4%，比例高于 Zen 4 的 71.4% 与 Zen 5 的 55%，绝对带宽则更低。

![图 18：Zen 2 的双 CCX/CCD 拓扑](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/4c12e0e971ccbd13_18_figure.jpg)

*图 18：每个四核 CCX 先经自身 Xi，再由两 CCX 共用 IFOP。*

同 CCX 中，延迟从 71.7 ns 升至三个带宽线程下的 142.77 ns；把流量移到同 CCD 另一 CCX，隔离良好，说明 Xi 可能比下游 IFOP 更早成为争用点。

![图 19：Zen 2 的 CCX 内与跨 CCX 对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/6231015796714a3d_19_figure.jpg)

*图 19：两 CCX 都制造流量时，Xi 与 IFOP 争用叠加，约 285 ns；仍好于 Zen 4 同 CCD 的 400 ns，Zen 5 对应约 151 ns。*

Zen 2 单核只能维持约 24～25 GB/s，较难独占下游队列；更弱的单核内存级并行反而给延迟线程留下入口。

![图 20：三代 Zen 单核 DRAM 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/e185c1ea7f113bc1_20_figure.jpg)

*图 20：后代单核更强，也使公平调度更重要。*

![图 21：Zen 2 的跨 CCD 隔离](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/7327c2d6d1d3dc1a_21_figure.jpg)

*图 21：单带宽线程没有 Zen 4 异常尖峰，可能只是它不足以占满队列，而非高级 QoS。*

![图 22：3950X 与 7950X3D 跨 CCD 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/6188bdbfa3efbea4_22_figure.jpg)

*图 22：旧 DDR4 控制器即使更接近带宽极限，仍能较好控制延迟。*

![图 23：两条 IFOP 同时工作时的 Zen 2](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/4e6f30c9de90de09_23_figure.jpg)

*图 23：两 CCD 同时读比把全部流量塞过一条 IFOP 延迟更好，因为只剩 DRAM 一处主要饱和。*

Zen 2 PPR 还有更直接的 Xi Queue Occupancy 与请求计数：延迟=占用累计/请求数，本质是 Little’s Law。

![图 24：Zen 2 PPR 的 Xi 延迟事件](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/7badedd27cf65392_24_figure.jpg)

*图 24：事件按周期累加 Queue Occupancy。*

![图 25：Zen 2 平均 Xi Queue Occupancy](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/b246b9a98604c39d_25_figure.jpg)

*图 25：平均约 59～61，接近 64，可能意味着每 CCX 64 项、每 CCD 128 项；计数器不支持 Count Mask，故不能把近似反推写成确定容量。*

![图 26：Zen 3 的 192 个 Pending Miss](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/527057d866e306a0_26_figure.jpg)

*图 26：AMD Hot Chips 33 明确给出的八核 CCX 数字。*

![图 27：Zen 5 可能的 320 项 Xi 容量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/1d1e6ed92f1ed294_27_figure.png)

*图 27：文章据双 Xi 推测总计约 320、每块约 160；Zen 4 容量没有找到公开数字。AMD 仅公开称 Zen 4 的 L2/L3 Miss Queue 都扩大。*

### 体系结构视角：平均延迟会掩盖尾延迟与不公平

当吞吐线程占绝大多数请求时，Xi 的全局平均可保持 200 ns，而少量 Pointer Chasing 请求等到 700 ns。评估 QoS 应看分位数、每 Source/CCD 延迟和 Queue Full 时间；平均值只能说明总体服务时间。多级队列的等待还是相加的：先等 Xi Entry，再错过 IFOP 时隙，之后才进入内存控制器。

## 应用会不会遇到这些极限

Cyberpunk 2077 在普通 CCD 上有 10～15 GB/s L3 miss 流量，1 s 采样可能平滑掉纳秒级尖峰；Xi 延迟常高于 90 ns。

![图 28：Cyberpunk 在两 CCD 上的 L3 miss 流量与延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/3ac0f1ae1f609421_28_figure.jpg)

*图 28：V-Cache 降低 miss 流量和排队延迟，帧率从 122.34 到 153.98 FPS，提升 25.8%；两种情况都未逼近 IFOP/DRAM 峰值，基础延迟与命中率更重要。*

![图 29：GHPC 的 L3 miss 与延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/acdf670ad5c59fe8_29_figure.jpg)

*图 29：趋势相同但流量更低，V-Cache 的次级收益是减轻 L3 之后所有层级的排队。*

![图 30：Baldur’s Gate 3 的带宽与 Xi 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/29cc340eacd4d44e_30_figure.jpg)

*图 30：秒级带宽波动很大，延迟仍远低于提示饱和的约 200 ns；V-Cache 把 L3 命中率从 31.65% 提至 79.46%，但普通 CCD 也有大量余量。*

RawTherapee 转换多张 Nikon D850 45.7 MP RAW、同时做曝光和降噪，线程多且数据难缓存，两 CCD 同时记录。

![图 31：RawTherapee 的突发带宽与延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/80406310bc3bb4eb_31_figure.jpg)

*图 31：流量尖峰未必持续满 1 s，但采样延迟超过 200 ns，表明队列在短时间内被推满。*

![图 32：玩 Baldur’s Gate 3 同时后台转码](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/9bcfb9cec4743582_32_figure.jpg)

*图 32：L3 miss 流量不低但延迟受控，游戏多数时间保持 60 FPS。*

![图 33：加入 L3 Hit 后的总片上带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/6b9baf9061979403_33_figure.jpg)

*图 33：部分采样超过 85 GB/s；大 L3 把大量流量留在片上。假想 16 核、每核 1 MB L2、无 L3 的 Zen 4 会严重冲击 Fabric/DDR，但现实中并无这一配置。*

![图 34：多级互连的“吵闹邻居”](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/495600b5dec363bb_34_figure.jpg)

*图 34：一个层级的多个 Source 汇聚到下一层 Choke Point，队列满会让延迟敏感任务受牵连。*

![图 35：三代 Zen Loaded Latency 总览](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_infinity_fabric_limits_wechat_article_zh/9da409cada748f80_35_figure.jpg)

*图 35：CCX 内争用通常最严重；Zen 4 因单核可制造更多并发 miss，叠加延迟最突出，Zen 5 显示 AMD 已改善。*

典型游戏与不少生产力程序不会持续推满 Fabric；RawTherapee 这类难缓存又高度并行的负载则不适合与延迟敏感任务并跑。作为对照，文章初测 Comet Lake 全核加载约 233.8 ns：无 CCX/CCD 层，但仍会在 Ring/DRAM 排队。跨平台数字不是同配置排名。

## 参考资料

- Chester Lam, *Pushing AMD’s Infinity Fabric to its Limits*, Chips and Cheese, 2024-11-24
- AMD Zen 1/2/3/4/5 PPR、ISSCC 与 Hot Chips 公开资料
- AmpereOne Hot Chips 2024 Loaded Latency 方法说明
