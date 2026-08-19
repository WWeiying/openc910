---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "amd_epyc_9355p_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*AMD’s EPYC 9355P: Inside a 32 Core Zen 5 Server Chip*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2025 年 9 月 30 日
> - 链接：https://chipsandcheese.com/p/amds-epyc-9355p-inside-a-32-core

服务器 CPU 不只有“核心越多越好”这一条路线。应用可能无法扩展到上百核，内存带宽也可能先于计算资源饱和。AMD EPYC 9355P 只有 32 核，却用八颗 CCD、每 CCD 完整 32 MB L3、最高 4.4 GHz 以及 GMI-Wide 双链路，让每颗启用核心得到更多 Cache 和片外带宽。

测试平台是 Dell 提供的 PowerEdge R6715，由 ZeroOne Technology 免费托管，配置 EPYC 9355P 与 768 GB DDR5-5200。12 个内存控制器构成 768-bit 总线，理论带宽略低于 500 GB/s。网页未完整披露操作系统、编译器、锁频和重复误差，因此细小差距不宜脱离这一平台解释。

![图 1：AMD EPYC 9005 系列的 CCD 组织](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_epyc_9355p_wechat_article_zh/4fa7bf0049082ffe_01_figure.jpg)

*图 1：高核心数 Turin 可用 16 个 CCD；EPYC 9355P 使用八个 CCD，每颗只启用四个 Zen 5 核，却保留整颗 CCD 的 32 MB L3。它以较低硅利用率换取每核 Cache 容量。*

## 一、GMI-Wide：核心少了，链路并没有减半

Zen 5 服务器 I/O Die 提供 16 条 GMI（Global Memory Interconnect）链路。高核心数型号可连接 16 颗 CCD；9355P 只有八颗 CCD，于是每颗 CCD 使用两条链路，即 GMI-Wide。读、写方向各可达到 64 B/FCLK cycle。

![图 2：普通 GMI 与 GMI-Wide](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_epyc_9355p_wechat_article_zh/8ce52d05f70f154a_02_figure.jpg)

*图 2：左侧 12-CCD 配置通常每颗 CCD 一条 GMI；右侧 8-CCD 配置每颗占用两个 GMI Port。双链路不是附带效果，而是这颗低核心数 SKU 的主要性能杠杆。*

![图 3：被测 Dell PowerEdge R6715](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_epyc_9355p_wechat_article_zh/25d28c1f7bf49ca2_03_figure.jpg)

*图 3：服务器实机由 Dell 提供、ZeroOne 托管。设备来源、内存频率和远程测试条件是理解后续数据的必要部分。*

### 体系结构视角：低核心数 SKU 也可以重新分配片上预算

关闭核心通常只降低计算吞吐；若 Cache Slice 和互连同时被裁掉，每核可用资源不会明显改善。9355P 的做法不同：保留八颗完整 CCD 和全部 IOD GMI Port，使每四核共享 32 MB L3、每颗 CCD 获得双链路。它牺牲有效核心/硅面积比，换取更高的单核频率、每核容量和簇外带宽。

## 二、NPS1、NPS2、NPS4 与 L3-as-NUMA

NPS1 把访问条带化到全部 12 个内存控制器，为软件呈现每 Socket 一个节点。测得 DRAM 延迟约 125.54 ns，略优于 Intel Xeon 6 的 SNC3，但明显高于桌面 Ryzen 9 9900X。原因不难理解：IOD 内的 Infinity Fabric 要连接最多 16 个 CCD、12 个控制器和大量 I/O。

![图 4：9355P、桌面 Zen 5 与 Xeon 6 的 Cache/DRAM 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_epyc_9355p_wechat_article_zh/3d554cbe6e7abbd9_04_figure.png)

*图 4：AMD 桌面与服务器复用 CCD，因此 L1/L2/L3 以 cycle 计接近；服务器频率更低、DRAM 路径更复杂。Intel 则从 L3 起采用不同的服务器组织。*

![图 5：三种 NPS 模式的本地与远端延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_epyc_9355p_wechat_article_zh/70144945a8e70ff2_05_figure.jpg)

*图 5：NPS1 本地约 125.54 ns；NPS2 约 117.7 ns、远端约 128.54 ns；NPS4 本地约 115.42 ns、远端约 122～140 ns。细分节点只带来十纳秒量级改善。*

NPS2 把芯片分成两个半区，每区 16 核、六个控制器；NPS4 划成四个象限，每节点两颗 CCD、三个控制器。还可把每颗 CCD 暴露成一个 NUMA 节点，方便把共享 L3 的线程放在一起。但“L3-as-NUMA”与内存交织模式是两项独立设置，地址仍按 NPS1/2/4 分配给控制器。

![图 6：NPS4 的核—内存延迟矩阵](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_epyc_9355p_wechat_article_zh/b97eaf1630ed6e70_06_figure.jpg)

*图 6：对角线是本地象限，非对角线是跨 IOD 请求。最坏空载值仍低于约 140 ns，说明大 IOD 内的跨区代价相对温和。*

![图 7：EPYC NPS4 与 Xeon 6 SNC3 的路径对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_epyc_9355p_wechat_article_zh/a07257bba73f2b05_07_figure.jpg)

*图 7：AMD 控制器集中在 IOD，跨节点主要穿过同一 IOD；Intel 控制器位于 Compute Die，最远请求要跨两个 Die 边界，延迟可超过 180 ns。图中路径是理解拓扑的示意，不是 AMD IOD 内部网格的公开 RTL。*

每种模式都能接近理论带宽，前提是线程访问本地节点。NPS2/NPS4 略高，但要求软件理解 NUMA。

![图 8：不同 NPS 模式的本地与跨节点总带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_epyc_9355p_wechat_article_zh/0cc86862dfb0d085_08_figure.jpg)

*图 8：NPS1 同节点约 478.98 GB/s；NPS2 同节点合计约 483.32 GB/s，交换访问约 468.54 GB/s；NPS4 本地约 488.13 GB/s，不同跨节点排列约 435～447 GB/s。跨区拥塞存在，却没有灾难性下降。*

单个 NPS4 节点的本地内存池约 117.33 GB/s，访问其他节点略高于 107 GB/s。更大的风险是三个内存控制器供不满两颗 GMI-Wide CCD：若一个工作负载只占一个象限，它可能受节点内带宽限制；手工把内存分散到其他节点会增加部署复杂度。

总体上，这颗 9355P 的 NUMA 特征很温和。对大多数程序，NPS1 很可能已经足够，NPS 优化的收益未必抵得上软件成本。

### 体系结构视角：NUMA 模式是在交换“平均距离”和“局部资源”

NPS1 让每个地址可使用 12 个控制器，带宽池大、管理简单，但平均路径更长；NPS4 缩短本地路径，却把每节点带宽和容量切成四份。选择时应先问线程工作集能否稳定留在节点内，再看本地延迟，而不是默认节点越多越快。

## 三、一颗 CCD 能从 GMI-Wide 得到多少

GMI-Wide 让单 CCD 纯读达到约 99.8 GB/s，明显高于桌面 Ryzen 9 9900X 的 GMI-Narrow 约 62.5 GB/s。

![图 9：单 CCD 纯读受载延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_epyc_9355p_wechat_article_zh/dcd65466655be5ff_09_figure.png)

*图 9：9355P 在约 100 GB/s 处仍能控制延迟。9900X 上单个带宽线程可占满窄链路，使同 CCD 的延迟线程接近 500 ns；增加更多线程后 QoS 机制似乎才开始限流。*

早期对 Ryzen 9 9950X 的远程测试没有看到这个角落，可能因为 DDR5-8000 与 2.2 GHz FCLK 让一颗核心不足以垄断 CCD 链路。GMI-Wide 通过更大的链路余量达到类似效果。

![图 10：单 CCD 1:1 读写的受载延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_epyc_9355p_wechat_article_zh/2c2877a89972d82c_10_figure.png)

*图 10：读改写可同时利用读写方向，9355P 峰值约 134 GB/s；桌面链路也因单线程不再独占纯读路径而避免极端延迟。*

桌面 GMI-Narrow 在 2 GHz FCLK 下理论上可提供 32 B/cycle 读、16 B/cycle 写，按 2:1 读写约 48 B/cycle；但控制器到 Infinity Fabric 的 32 B/cycle 通路可能先限制结果。

![图 11：Zen 4 桌面 IOD 与 Infinity Fabric 链路](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_epyc_9355p_wechat_article_zh/0f50ac4c7a1bf9f6_11_figure.jpg)

*图 11：这张 AMD 幻灯片针对 Zen 4 桌面；Zen 5 桌面复用同一 IOD，因此链路组织仍可作为参照。它不能直接代表 Turin 的 GMI-Wide。*

读写混合还会在 DRAM 总线上产生 turnaround：读、写共用双向引脚，方向切换会浪费周期。桌面系统中，窄 GMI 留给控制器足够余量，带宽未必下降，但延迟线程可能要等控制器排空写队列。

NPS1 下，一颗 GMI-Wide CCD 的请求可分散到 12 个控制器，读写混合几乎没有额外惩罚；NPS4 下，双链路能力反而超过三个控制器，读改写从 NPS1 的约 134 GB/s 降到 96.6 GB/s，延迟升到 248 ns。

![图 12：NPS4 单 CCD 的纯读与读写混合](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_epyc_9355p_wechat_article_zh/32e1c2e4819651b1_12_figure.png)

*图 12：纯读在更短路径下可超过 100 GB/s，混合流量却暴露三控制器的方向切换与排队。NPS4 对小核数、高带宽任务尤其需要谨慎。*

### 体系结构视角：链路变宽以后，瓶颈会向下一层迁移

双 GMI 解除了 CCD 边界的限制，却不会增加 NPS4 节点内的 DRAM 引脚。于是瓶颈从“CCD 到 IOD”移动到“控制器队列与 DRAM 总线”。定位此类问题应同时测读、写、固定比例读写和延迟线程，并记录 GMI、控制器和 DRAM 利用率；只看一个峰值无法判断堵在哪一层。

## 四、SPEC CPU2017：单线程与四核 CCD 的两种结论

单线程测试中，9355P 落后高频 Ryzen 9 9900X；关闭 9900X Boost、拉近频率后，两者明显接近。服务器更高的 DRAM 延迟仍有影响，但相同 CCD 让核心与 Cache 部分保持一致。

![图 13：SPEC CPU2017 单线程估算](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_epyc_9355p_wechat_article_zh/ac10283b677a06ed_13_figure.png)

*图 13：图中为 Rate 套件单 Copy 的估算分数。NPS1/2/4 差别极小；NPS4 技术上领先，却不足以支撑实际排名。9355P 对密度优化的 Graviton 4 和 Xeon 6 6975P-C 有明显单线程优势。*

为了观察 CCD 带宽瓶颈，测试在四颗核心上运行八个 SPEC Rate Copy；Ryzen 9 9900X 也只用四颗核心，其他两核留空，并把每个平台绑定到单一 NUMA 节点。

![图 14：四核、八 Copy 的 SPEC CPU2017 吞吐](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_epyc_9355p_wechat_article_zh/d36328554da4d33f_14_figure.png)

*图 14：整数套件对带宽不太敏感；浮点套件中，GMI-Wide 与服务器内存系统拉开差距。不同平台的频率、内存和 NUMA 并不完全一致，重点是识别瓶颈转移。*

`549.fotonik3d` 是最明显的带宽负载。单核在 Meteor Lake 上曾达到 28.23 GB/s，八 Copy 会迅速放大需求。此时 9900X 的低空载延迟失去意义，甚至落后 Xeon 6 Redwood Cove；9355P 则凭 GMI-Wide 取得很高成绩。

![图 15：549.fotonik3d 八 Copy 结果](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_epyc_9355p_wechat_article_zh/5b2a642381dd4195_15_figure.png)

*图 15：9355P NPS1/NPS2/NPS4 约为 98/92.8/70.9，Xeon 6 约 53.1，9900X 约 40.5。NPS4 因每节点只有三个控制器而显著落后，再次说明最低空载延迟不等于最高吞吐。*

Intel 的逻辑单体互连没有 CCD 边界，但单核从 DRAM 得到的 1:1 读写带宽约 33 GB/s；9355P 的双 GMI 足以匹配。若换成每 CCD 八核且使用窄 GMI 的高密度 EPYC，这一结论可能改变。

## 五、32 核服务器的设计意义

低核心数服务器过去常只换来更高频率；9355P 还把闲置的 IOD Port 和完整 L3 容量分给每颗启用核心。

![图 16：AMD Zen 2 时代对统一 IOD 的延迟说明](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_epyc_9355p_wechat_article_zh/a370f8aeb883aedd_16_figure.jpg)

*图 16：AMD 自 Zen 2 起把控制器集中到 IOD，以略高本地延迟换取更一致的 Socket 内访问。Turin 拓扑更复杂、DDR5 本身延迟更高，但设计主线延续。*

![图 17：EPYC 9005 的中央 IOD 与 CCD 封装](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_epyc_9355p_wechat_article_zh/f822e9c98e66c398_17_figure.jpg)

*图 17：不同核心数产品可在同一 IOD 周围配置不同数量 CCD。模块化带来 SKU 扩展能力，也使 GMI 数量、CCD 数量和每节点控制器数之间形成新的配比问题。*

从体系结构角度，9355P 给出四点认识：

1. 服务器单线程性能不仅由频率决定，每核 L3 容量和 CCD 外带宽同样可以随 SKU 调整。
2. NUMA 的“本地更快”必须与“本地资源更少”一起看；NPS4 在 fotonik3d 上就是反例。
3. AMD 的 Hub-and-Spoke IOD 让 DRAM 行为比 Intel Xeon 6 更均匀，代价是本地路径不追求极致低延迟。
4. GMI-Wide 对 32 核 SKU 很有效，但结论不能直接外推到 128/192 核、每 CCD 八核且链路更窄的型号。

![图 18：机架中的 Dell PowerEdge R6715](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_epyc_9355p_wechat_article_zh/8cbc92437503a774_18_figure.jpg)

*图 18：实机照片由 ZeroOne Technology 提供。本文所有结果都应理解为这台 32 核、DDR5-5200、768 GB 配置下的观察。*

Chester Lam 的总体判断是：AMD 从 Zen 2 时代找到了一套有效的服务器公式，并在 Turin 上继续加强；Intel 则努力用跨 Die Mesh 维持单层逻辑单体，Arm 服务器通常也偏向单层互连。9355P 并不证明一种拓扑普遍胜出，却清楚展示了低核心数服务器不必只是高核心数型号的“削减版”。

## 参考资料

- Chester Lam，*AMD’s EPYC 9355P: Inside a 32 Core Zen 5 Server Chip*：https://chipsandcheese.com/p/amds-epyc-9355p-inside-a-32-core
- AMD，*EPYC 9005 Processor Architecture Overview*
- Dell PowerEdge R6715 产品资料
