# Centaur CHA 的双路实现：协议能跑，带宽却像没做完

> **文章来源**
>
> - 文章：*Centaur CHA’s Probably Unfinished Dual Socket Implementation*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2022 年 4 月 23 日
> - 链接：https://chipsandcheese.com/p/centaur-chas-probably-unfinished-dual-socket-implementation

Centaur CHA 面向服务器，却只有八核；双 Socket 能把系统扩到16核，因此很关键。集成 Memory Controller 让每个 Socket 拥有自己的 Memory Pool，远端访问必须跨 Socket Link，形成 NUMA。优秀实现不能消除远端惩罚，只能把额外延迟降到合理水平，并让足够多 Outstanding Request 填满长链路。

![图 1：CHA 双 Socket/NUMA 拓扑](centaur_cha_dual_socket_figures/01_figure.jpg)

*图 1：每个 Socket 各有 CPU、DDR 与跨 Socket Coherence Link。*

## 远端延迟：额外约92 ns

测试把1 GB Array 分配到不同 Node，再由不同 Node Core 做 Pointer Chasing；1 GB 可越过 Cache，使用2 MB Page避免 TLB miss。多数 Client 用4 KB Page，因此数字用于隔离 NUMA，不是应用平均 Memory Latency。

![图 2：CHA 本地/远端 DRAM 延迟](centaur_cha_dual_socket_figures/02_figure.png)

*图 2：跨 Socket 多约92 ns，远端接近本地两倍。*

![图 3：Broadwell 双路 Early Snoop](centaur_cha_dual_socket_figures/03_figure.png)

*图 3：Xeon E5-2660 v4、DDR4-2400 CL17；远端仅多42 ns、慢41.7%。更老 Westmere 本地70.3、远端121.1 ns，差约51 ns，也优于 CHA。*

Broadwell Cluster-on-die（CoD）把每 Socket 分两 NUMA Node，每个覆盖一条 Ring+双通道 DDR。Local 略快，但四 Pool 让路由复杂；同 Die 跨 Node 竟多近70 ns，比跨 Socket 链路本身影响更大。

![图 4：Broadwell CoD 四 Node Memory Latency](centaur_cha_dual_socket_figures/04_figure.png)

*图 4：CHA 只有两 Node 时显得平庸；Intel 同时选择三个 Remote Node 时也接近。*

![图 5：Milan-X NPS2 延迟](centaur_cha_dual_socket_figures/05_figure.png)

*图 5：AMD 每 Socket 两 Node，同 Socket 跨半区只多14.33 ns，跨 Socket 约70～80 ns，说明快速 Directory 可显著降低 Home Routing 成本。Azure Cloud 结果含虚拟化边界。*

### 体系结构视角：NUMA 延迟包含“找 Home”与“走链路”

一次远端 Load 先需根据 Physical Address 找到 Home Agent/Memory Controller，再经过 Link、Remote DRAM，最后返回。Broadwell CoD 显示 Directory/Route Lookup 有时比物理跨 Socket 更贵。验证应做 Source Core×Memory Node Matrix，并改变 Home Address，而不是只报一个 Remote Number。

## 远端带宽：只有约1.3 GB/s

Bandwidth 使用3 GB Array越过 Cache，只测 Read；CHA 为四通道 DDR4-3200。

![图 6：CHA 本地与远端读取带宽](centaur_cha_dual_socket_figures/06_figure.png)

*图 6：远端略高于1.3 GB/s，甚至低于优秀 NVMe 顺序读，明显不正常。*

![图 7：Broadwell 双路带宽](centaur_cha_dual_socket_figures/07_figure.png)

*图 7：每 Socket 单 Node 时本地近60 GB/s，远端21.3 GB/s；Westmere 三通道 DDR3 本地20.4、远端11.2 GB/s，也远高于 CHA。*

![图 8：Broadwell CoD 带宽](centaur_cha_dual_socket_figures/08_figure.png)

*图 8：每个7核 Node 的远端带宽仍高于 CHA；同 Die 跨 Node 却约减半，显示内部 Ring/Home 约束。*

![图 9：Milan-X NPS2 带宽](centaur_cha_dual_socket_figures/09_figure.png)

*图 9：八通道使本地很高，同 Socket 另一半保持良好，跨 Socket 每 NPS2 Node 仍超40 GB/s，接近 CHA 本地。*

长延迟链路要高带宽，必须用 `Bandwidth≈Outstanding Requests×Line Size/Latency` 提供很多在途 Miss。CHA 协议能到远端，却似乎只有很浅 Queue 或有限 Credit。

## Cacheline Ping-pong：反而是 CHA 表现最好的一项

用 Locked Compare-and-exchange 在两核间反复修改同一 Line，测 Coherence Ownership Transfer。CHA 跨 Socket 约90～130 ns。

![图 10：CHA Atomic Core-to-core Matrix](centaur_cha_dual_socket_figures/10_figure.png)

*图 10：若 Line Home 在远端，甚至同 Chip 两核也可能跨 Link Round-trip，形态类似 Ampere Altra；CHA 核少、拓扑简单，绝对值更低。*

Westmere 跨 Socket 更好，并可在同 Die 完成 Coherence，即使 Line Home 在远端 Socket。

![图 11：Westmere Core-to-core Latency](centaur_cha_dual_socket_figures/11_figure.png)

*图 11：Central Global Queue 简单，利于 Coherence；代价是普通 L3 延迟/带宽不如后来 Distributed Ring。*

![图 12：Broadwell CoD Core-to-core](centaur_cha_dual_socket_figures/12_figure.png)

*图 12：同 Cluster Inclusive L3+Core Valid Bit 快；L3 miss 后 Directory 慢，同 Die跨 Node 已超100 ns，跨 Die只再多10～20 ns。*

![图 13：Broadwell Early Snoop Core-to-core](centaur_cha_dual_socket_figures/13_figure.png)

*图 13：同 Die含跨 Ring在50 ns内，但跨 Socket约140 ns，略差于 CHA。*

Milan-X Cloud Pinning 不干净，结果大致与 AnandTech EPYC 7763 相符：同 CCX 很低、NPS2 内跨 CCX约90 ns、跨 NPS2约110 ns、跨 Socket约190 ns。CHA 在这项优于 EPYC，说明协议/Directory 基本可用；但目前没找到实际应用明显受益于低 Ping-pong Latency，Contended Atomic 并不常见。

## 为什么判断“没做完”

CHA 支持每 Socket 数百 GB Memory、四通道 DDR4、44 PCIe Lane，八核却偏少，双路本可补足。1.3 GB/s 会让 NUMA-unaware Workload 严重受损，也使跨 Socket Interleave 获取总带宽的模式不可行。

![图 14：单 NUMA Node 到远端的最大带宽](centaur_cha_dual_socket_figures/14_figure.png)

*图 14：用该 Node 全部 Thread，仍未把 Link 跑起来。*

文章猜测 Link 前有 Queue，但 Centaur 小团队忙于 Server 新技术，未完成验证/调优。

![图 15：最小跨 Socket Latency](centaur_cha_dual_socket_figures/15_figure.png)

*图 15：Latency 尚合理，恰与“协议正确、并发深度不足”相符；仍不是内部 Queue 的直接证据。*

Centaur 已不存在，CHA 的双路潜力不会再完成。结论应保持边界：“Probably Unfinished”是由极低带宽、合理延迟与团队背景形成的判断，而非项目内部确认。

## 参考资料

- Chester Lam, *Centaur CHA’s Probably Unfinished Dual Socket Implementation*, Chips and Cheese, 2022-04-23
- Intel Broadwell/Westmere NUMA；AMD Milan-X NPS2 对照
- 测试平台由 Brutus 配置
