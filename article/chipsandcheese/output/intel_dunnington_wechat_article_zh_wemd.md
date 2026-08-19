---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "intel_dunnington_wechat_article_zh"
---

> 英文标题：Intel’s Dunnington: Core 2 Goes Dun Dun Dun<br>
> 撰文：Chester Lam<br>
> 首发：Chips and Cheese，2023 年 2 月 5 日<br>
> 原始链接：https://chipsandcheese.com/p/intels-dunnington-core-2-goes-dun-dun-dun

Conroe 在 2006 年让 Merom/Core 2 核心重夺客户端单线程优势，但服务器更看重多线程和多插槽。AMD 用 HyperTransport 点对点连接扩展 socket；Intel 仍依赖共享 Front-Side Bus（FSB），核心越多，仲裁、内存和一致性流量越难扩展。Merom 又原生按双核设计，45 nm Penryn 只是加大 L2、做小幅改进。

![图 1：四路 Dunnington 服务器的大量 FBDIMM](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/e6e6ae1189fb1d2c_01_figure.jpg)

Dunnington 把 3 个双核 Penryn module 塞进一颗大 die，再用 16 MB L3 和专用 uncore 尽量隔离 FSB 瓶颈。Tulsa 曾用相似 uncore 给两个 NetBurst 核配 16 MB L3；Dunnington 首次把这套思路扩到 6 个更高效核心。本篇也借此完整观察 Merom/Penryn。

## 503 mm² 的六核巨兽

每个双核 module 共享 3 MB L2；die 中央的 Cache Bridge Controller（CBC）连接三组核心、L3 与 FSB。FSB 接口也放在中央以缩短到 CBC 的距离，但 1066 MT/s 仍难喂饱 6 核。

![图 2：Dunnington 裸片，中央 CBC、三组 Penryn 与不规则 16 MB L3](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/ac3115528d72deda_02_figure.jpg)

45 nm Dunnington 面积 503 mm²、19 亿晶体管；65 nm Tulsa 已有 435 mm²、13.28 亿。单颗 6 MB L2 Penryn 仅 107 mm²、4.1 亿。为把 L3 填进 die，垂直与水平 SRAM block 使用不同实现，形成不规则轮廓。

## Penryn 核心：不炫技，但基本功扎实

Penryn 是 Merom 的 45 nm shrink，也是 P6 的大幅扩展：更宽、更深、支持 64 bit，却保留统一 scheduler 与 ROB+RRF 乱序组织。

![图 3：Penryn 核心框图](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/c03fd1d1294cf3a2_03_figure.png)

它很多结构比 NetBurst 小，也没有同样炫目的机制，却拥有大而低延迟的缓存，并把异常路径惩罚控制在合理范围。

### 分支预测

方向预测能力类似 2010 年代中期低功耗核心，不如 NetBurst 激进；但误预测流水线更短，且能立即取消错误路径，不会像 NetBurst 那样让错误依赖链一直执行到退休。

Penryn 主 BTB 约 2048 项，可让最多 4 条 taken branch 无 bubble。相对 NetBurst 小 footprint 的千条级快速能力是回退，但一级路径 miss 后只多 1 周期；真正 BTB miss 随分支距离变化，仍与 NetBurst 慢速主 BTB 相近，而不是 36 周期悬崖。

![图 4：Penryn 的 taken branch footprint 与延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/f481f10cf4461b1a_04_figure.png)

![图 5：Penryn、AMD K8/K10 的连续 taken branch 能力](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/36186024108e0995_05_figure.png)

K8/K10 不能无气泡处理 back-to-back taken branch，Penryn 虽只覆盖 4 条，也降低了 loop unrolling 的必要性。预测准确率不及现代桌面核，但可覆盖绝大多数分支；有限在途容量也让一次误预测损失较小。

### 取指、译码和重命名

Penryn 使用传统 32 KB L1I，decoder 从 Pentium M 的 3-wide 增到 4-wide。Intel 最早曾考虑 4-wide P6，后来为频率选择 3-wide；到 Merom 才真正实现。传统 L1I 能利用 x86 紧凑字节编码，短指令下吞吐高于 NetBurst trace cache；长指令更易受字节带宽限制。

![图 6：L1I/L2/DRAM 不同代码 footprint 下的 IPC](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/af8190d43250ffb7_06_figure.png)

L1I miss 后，即使是 4-byte 指令也无法超过 1 IPC。K10 类似，但 L1I 更大、较少进入此路径；代码完全溢出 cache 后，Dunnington 比 K10 差，客户端 Penryn 从 DRAM 取指则大致相当。

Renamer 能识别 zero idiom 并打断依赖，但指令仍需进 ALU，不能完全消除；Penryn 和 K10 都没有 move elimination，属于当时典型水平。

### 乱序执行与执行单元

96-entry ROB 在当时很大。ROB+RRF 意味着未退休结果直接存在各自 ROB entry，不会在 ROB 之前先耗尽独立物理寄存器，因此一项 ROB 容量比现代 PRF 核心更“实”。

![图 7：Penryn、NetBurst 与 K10 的在途结构容量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/1bbd13e200573ffb_07_figure.jpg)

NetBurst 有 126-entry ROB 和大 PRF，却要跟踪错误路径、应对极端慢路径；与惩罚正常的 K10 比更有意义。多数类型下 Penryn 能容纳更多在途指令；128-bit SSE 例外，因为 Intel 要用两项保存 128-bit 结果，AMD 不需要。

![图 8：Penryn 与 K10 执行端口和主要操作吞吐/延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/b8621d1757059fce_08_figure.jpg)

Merom/Penryn 多一条 ALU pipe，FP/vector 原生 128-bit。常见操作与 K10 吞吐相近；AMD 在 shift、rotate、LEA 等少见整数操作更强。FP 方面两者吞吐相同，Penryn FP add 延迟更低。128-bit integer add：Penryn 1/cycle、1-cycle latency；K10 2/cycle、2-cycle latency。SSE register move：Penryn 2/cycle、1 cycle；K10 三条 FP pipe 都可做、但 2-cycle latency。

### 体系结构视角：吞吐和依赖延迟回答不同问题

K10 两条 2-cycle integer-vector add 可让独立操作达到 2 IPC，却无法让一条依赖链快于每 2 周期；Penryn 单 pipe 只有 1 IPC，却能每周期推进依赖链。微基准和应用应按 ILP 结构选择指标，不能用一个峰值吞吐判断所有代码。

## Load/Store：较粗粒度检查，较可控惩罚

Penryn 两条 AGU 中一条只做 load、一条只做 store；L1D 每周期可两次访问，却必须是一 load+一 store。程序通常 load 多于 store，load AGU 更易成为瓶颈。K8/K10 有 3 条 load/store 通用 AGU，L1D 才是上限：每周期可两 load，或一 load+一 store。

![图 9：Merom/Penryn 与 K10 的地址生成组织](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/669ae9b3a099f276_09_figure.png)

地址完全相同且 load 不跨 64 B line 时，Penryn store forwarding 约 5 周期；若 store 64-bit 对齐，也能转发其上半部分。

![图 10：Penryn 的 store-to-load forwarding 矩阵](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/d6db5265e7c83b66_10_figure.png)

失败通常约 12 周期。粗粒度初筛会制造假依赖：load/store 落在同一 64-bit 对齐块，即使不重叠也可能受罚。若 load 不跨 64-bit boundary 且 store 地址更高，核心可早发现错误，只多 2—3 周期；load 地址更高则可能完整等 12 周期。重叠且跨 64 B line 时为 22—23 周期。

NetBurst 检查粒度更细，较少假依赖，但 forwarding failure 为 51 周期、双跨 line 超 160；说明“检查精确”并不能抵消恢复代价。

![图 11：Penryn 与 NetBurst 的转发失败对比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/404e17a9acccf218_11_figure.png)

![图 12：K10 转发矩阵](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/0bf7415a758afd2d_12_figure.png)

K10 成功 4—5 周期，失败多为 10—12；只支持精确地址，misaligned 不转发。K10 L1D 访问粒度更小，misaligned 更常见，但失败惩罚约 12—13，约为 Penryn 特定跨界场景一半。

Penryn 跨 64 B store 为 10—11 周期，load 为 12—13；NetBurst 分别约 106 和 22—23。K10 的 L1D 是 16 B sector，跨界更频繁，却只多 2—3 周期。

跨 4 KB page 更糟：Penryn load 163 周期，store 218；K10 除上述 misalignment 外没有额外罚时。Penryn 初步 memory disambiguation 只看 4 KB page offset，因此相隔 4096 B、落在相同 64-bit block 的访问也可能假冲突；K10 同样有 4K alias，却只多 3—4 周期，misaligned 5—6。

一种解释是 Intel 很晚才做完整 physical-address 检查；权限检查晚于 L1D 数据读取也正是 Meltdown 条件之一。这个关联是推测，并非测试直接证明。

### 体系结构视角：虚拟地址早判断与物理地址晚确认

AGU 先产生 virtual address，TLB 后才给 physical address。为了早发射 load，LSU 常用 page offset 与 store queue 做保守比较，再在后级校验；4K alias 是这种投机的可见副作用。正常时提高吞吐，冲突时 replay。验证应扫 4 KB 倍数、访问大小、跨页与真实映射别名，并区分 TLB miss 与 alias replay。

## Penryn 的两级缓存

![图 13：Dunnington 测试系统缓存拓扑，来自 lstopo](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/da93bc869398ec5a_13_figure.png)

### 32 KB L1D

32 KB、8-way、3 周期，8 bank 支持每周期一 load+一 store；128-bit load/store 各只需一次 L1D access。

![图 14：Penryn L1D 延迟、容量与带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/0cf46b2d48f5dde2_14_figure.png)

K8/K10 为 64 KB、2-way、类似延迟；K8 FPU 每周期只能一次 L1D access，128-bit 又拆成两次 64-bit，Penryn 向量占优；K10 可每周期两次 128-bit load，或 load+store，Penryn 落后。相对 NetBurst 的 16 KB、4 周期、write-through，Penryn 则是巨大进步。

### 6 MB 共享 L2

每双核共享 6 MB、12-way，也可裁为 3 MB。物理上由 1 MB、4-way slice 组成，可按 1 MB flush/power-down。L1D 已吸收高频访问，因此 L2 用约 0.38 µm² ULV cell 追求密度和低功耗：活动低于 0.7 V，standby 低于 0.5 V。

![图 15：Intel 论文中的 Penryn L2 组织](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/38e9d20276a0de7d_15_figure.png)

内部从 L2 bus interface 起为 7-stage，实测 load-to-use 约 15 周期；作为客户端 LLC，它的容量近似现代 L3，却有很低延迟。

![图 16：Merom/Penryn 与 K10 缓存延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/4951c52133b10372_16_figure.png)

Penryn 容量选项比 Merom 大 50%，延迟可能多 1 周期。45 nm K10 若计 L3可给单核相近总容量，但 L3 约 50 周期；65 nm K10 只有 2 MB L3，同样约 50 周期。

Intel 称 L2 随 core clock、256-bit bus、每两周期一请求，理论 32 B/cycle；实测未达到。

![图 17：单核和双核共享 Penryn L2 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/f9d45028c995260c_17_figure.png)

单核约 8 B/cycle，双核接近 16 B/cycle，离 32 很远；仍足够匹配当时 modest vector throughput，也明显高于 K10 从 L3 不到 4 B/cycle 的供给。

## Dunnington 16 MB L3 与 CBC

三组 Penryn 通过 Simple Direct Interface（SDI）接入中央 CBC，而不是各自 FSB。

![图 18：Tulsa Hot Chips 框图；Dunnington 复用类似 uncore 概念](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/1c380b2da7791f64_18_figure.png)

![图 19：Intel Technology Journal 的 Dunnington 高层架构](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/242f923a06e57a32_19_figure.png)

SDI/CBC 源自 Tulsa；Dunnington 变为三条 SDI 接双核 module。L3 与 uncore 均为 core clock 一半。

物理 L3 分成 4 MB block，但同步访问、各块延迟相同。完整 16 MB 为 16-way，也可减为 12/8-way；实测 Xeon E7450 为 12 MB、12-way。L3 data bitcell 0.3816 µm²，tag 0.54 µm²，data cell 并不比 L2 更密。

![图 20：Dunnington L3 容量/相联度与延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/145713443968b8fe_20_figure.png)

L3 约 37 ns，比 AMD 高；Tulsa 官方约 35 ns，与继承关系一致。大容量可解释一部分延迟，现代 Ampere Altra 也约 35 ns，但这仍属于服务器中的偏高水平。

![图 21：Dunnington L3 单核、module 与全 socket 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/d2c782ff50465d11_21_figure.png)

8 MB 工作集下单核 8.2 GB/s，module 双核 9.49 GB/s。每线程独立数组会叠加三个私有 3 MB L2；L3 又 inclusive，若三组 L2 各缓存不同数据，16 MB 中只有约 3 MB 可装额外 line，容量曲线几乎消失。

让所有线程读共享数组可能因 request combining 高估带宽，但实测 38.35 GB/s；相同方法下 Phenom X4 9950 为 35.86，Phenom II X4 945 为 41.42，后者 PMU 大体支持。Tulsa 官方仅 18.1 GB/s，Dunnington 明显改善，不过 38.35 GB/s 要喂 6 核，仍依赖大 L2 降低压力。

L3 inclusion 还充当第一层 snoop filter：core-valid bit 记录哪个 module 缓存该 line。L3 miss 就表示 die 内没有副本，uncore 才向 FSB/芯片组请求。

### 体系结构视角：Inclusive L3 用有效容量换一致性目录

Inclusive L3 的 tag 可当目录，快速判断是否需要 snoop core；代价是上层私有 cache 内容必须在 L3 有副本，大量核心各自工作集会吃掉共享容量。单线程看是 16 MB，六核独立数组看可用新增容量只剩约 3 MB。评价这类 LLC 必须区分 nominal、inclusive overhead 和共享/私有工作集。

## 7300 芯片组：四 FSB、四通道 DDR2 与百万项 Snoop Filter

7300 MCH 为四个 socket 各给一条 FSB，并集成四通道 DDR2 与跨 socket snoop 管理。

![图 22：7300 MCH 与旧 E8500 ball-out；FSB、FBD、IMI、XDP 标注](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/fa0db44004c24e89_22_figure.png)

封装 12 层、2013 ball、49.5 mm见方；MCH 仅 266 MHz 仍需大散热器。

![图 23：7300 芯片组公开规格](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/ed0bfbfc928a8b36_23_figure.png)

![图 24：Intel 参考 MCH 散热器，使用 PCM45F thermal pad](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/bbb94f8b3c6ca36d_24_figure.jpg)

其职责类似现代 AMD I/O die；在旧工艺下负载功耗并非完全不可理解。I/O 为 28 条 PCIe 1.0，另 4 条连 southbridge。

### 两级 Snoop Filter 与核间延迟

同 die module 间 atomic cacheline bounce 通常略低于 70 ns；奇怪的是同一 Penryn module 两核间反而更高。

![图 25：同核、同 module、跨 module 的 cacheline bounce 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/0af0663d6b3b0edc_25_figure.png)

L3 miss 后进入 MCH。为避免四条 FSB 广播 snoop，MCH 有 1M-entry、128-way filter，由两个 interleave、每个 8 affinity 组织。Tag 单独占 4.5 MB，支持 40-bit physical address（1 TB 地址空间，实际系统难装满）。

![图 26：用 40-bit physical address 查 Snoop Filter](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/2ceed63eefded667_26_figure.png)

每项覆盖 64 B，总计跟踪 64 MB，正好覆盖四颗完整 Dunnington L3。每项 5-bit data 指定该 snoop 哪些 socket。

![图 27：Snoop Filter 如何减少跨 FSB 广播](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/6ab64805667cff18_27_figure.png)

Read-modify-write 很常见，filter 以 533 MHz hot-clock，是 MCH 两倍；lookup 4 cycle、约 2.1 ns。实测跨 socket bounce 约 178—190 ns。

AMD 把高带宽 northbridge 和内存控制器放在各 CPU die，芯片组只管 I/O；可从每 socket L3 划 1 MB 做 256K-entry、4-way snoop filter，覆盖 16 MB，并按该 socket DRAM base offset 索引。

![图 28：同期 Opteron 的同 socket/跨 socket cacheline bounce](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/ffe47b834e704c34_28_figure.png)

Opteron 同 socket 约快 20 ns，跨 socket 约 100 ns，明显低于 Dunnington 170—190；即使不划 L3 做 filter，最差结果仍较合理。

### DRAM：测试很差，但硬件损坏限制结论

四通道 DDR2-667、FBDIMM，最高 512 GB、每通道 8 DIMM。理论上应有充足带宽，实测单 socket 2.3 GB/s、四 socket 8.64 GB/s，比单 socket K10 还低。

![图 29：Dunnington 与 K10 DRAM 聚合带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/a1a5ff2edacd5e00_29_figure.png)

共享数组时 Dunnington 更高，可能发生跨 socket request combining；更重要的是测试机坏了 3 条 FBDIMM，若集中在一通道或造成容量不均，interleave 会严重受损。因此不能把 8.64 GB/s 当作健康 7300 平台上限。

## 从 FSB 到现代 Uncore 的过渡

传统共享 FSB 上，一颗 CPU 先仲裁请求；其他 CPU 监听地址并查 cache；若有 modified copy，就经 FSB 回写；否则内存控制器返回。双 die/双 module 尚能运作。

![图 30：Paxville 两颗 NetBurst die 直接共享一条 FSB 的封装布线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/6bacc2de0d252947_30_figure.jpg)

Paxville 已在部分负载遇到高 FSB utilization，Tulsa 先加 uncore，Dunnington 再换成 Penryn module。

![图 31：Dunnington 封装布线，FSB 接口位于 die 中央](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/3b66a0f1c0f75004_31_figure.jpg)

实际扩展仍差。

![图 32：四路系统随 Penryn module 增加的 libx264 scaling](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/bf4f482581d398e9_32_figure.png)

同 socket 从一组到两组双核只提升 53%，远低于理想 100%；再加到 6 核几乎不增，指向 L3/FSB 瓶颈。上第二 socket 接近翻倍，继续加则进入内存带宽瓶颈。

![图 33：加载更多 module 时每核 IPC 下滑](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/57ccc5c6d9cb67dd_33_figure.png)

PMU 证明不是单纯频率问题，而是共享 L3/内存让每核退休效率下降。

![图 34：4K、veryslow、CRF 24 的 libx264 FPS；Intel 单 socket 多 50% 核心仍落后 AMD](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_dunnington_wechat_article_zh/2ca7c31e5dbffadb_34_figure.png)

甚至需要 2 socket、12 核才超过一颗 AMD 四核，Dunnington 未解决多线程 scaling。

## 结语

Merom/Penryn 是 P6 的成功复位：不如 NetBurst 炫目，却把分支恢复、misalignment、cache latency 和基本执行做好；96-entry ROB 与大而快 L2 让两级缓存就能达到 K10 三级缓存的容量，同时少承受一次高延迟。Nehalem/Sandy Bridge 后来再把 NetBurst 的有用机制逐步合回这条稳健基础。

Dunnington 则是 uncore 的过渡实验。SDI 后来换为 IDI，CBC 在 Nehalem 变 global queue、Sandy Bridge 再变 ring；inclusive L3 + core-valid directory 一直影响 Intel 到 2020 年。它本身延迟高、带宽和 scaling 差，却让 Intel 明白多核绝不是复制核心：共享缓存、互连、目录和内存带宽必须一起扩展。
