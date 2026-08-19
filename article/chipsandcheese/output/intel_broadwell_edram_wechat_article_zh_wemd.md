---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "intel_broadwell_edram_wechat_article_zh"
---

> 英文标题：Broadwell’s eDRAM: VCache before VCache was Cool<br>
> 撰文：Chester Lam<br>
> 首发：Chips and Cheese，2024 年 11 月 1 日<br>
> 原始链接：https://chipsandcheese.com/p/broadwells-edram-vcache-before-vcache

Broadwell 原本要延续 Intel 的 tick-tock：把 Haswell 搬到 14 nm，再靠小幅架构修改提高约 5% IPC。14 nm 的问题却让桌面版无法达到 Haswell 频率，少量 IPC 增益不足以补偿；Broadwell 在移动和服务器的低单核功率场景表现不错，旗舰桌面仍由 Haswell 占据。

![图 1：Broadwell 桌面产品与裸片背景](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/4b30d6220a58539c_01_figure.jpg)

有限的桌面版因此更特别：它搭载 128 MB eDRAM L4，目标首先是让大 iGPU 在双通道 DDR3 上获得足够带宽，同时也服务 CPU。Intel 比 Ryzen 7 5800X3D 的 96 MB 堆叠 L3 早近 7 年，把“大容量封装内缓存”带到桌面。

测试使用 Crispysilicon 提供的 Xeon E3-1285 v4，另有 cha0shacker 提供 Broadwell/Skylake eDRAM 数据。

## Crystal Well：一颗为缓存而设计的 DRAM Die

Broadwell 的 L4 位于独立 77 mm² die，代号 Crystal Well，以较旧 22 nm 制造，通过封装内 OPIO（On-Package IO）连接 CPU die。它在 Haswell 已首次出现，Broadwell 延续这套方案。

![图 2：Intel ISSCC 论文中的 Crystal Well eDRAM 裸片](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/18667d1daa7078cb_02_figure.jpg)

eDRAM（embedded DRAM）每 bit 只需一个晶体管和电容，密度优于用多个晶体管锁存一 bit 的 SRAM。IBM POWER 也曾用 eDRAM 做 L3。

![图 3：22 nm eDRAM 与更新 14 nm SRAM 的 bit density 对比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/97220039fdbcd6c2_03_figure.jpg)

两种 22 nm eDRAM 的密度都很出色，但 DRAM 电容会漏电，需要刷新；读取会破坏电荷，需要恢复。Crystal Well 通过不同于 DIMM 的 bank、接口与时序取舍，把 DRAM 调成低功耗、高性能缓存。

### 128 个 Bank 和 6 个阵列周期的恢复

![图 4：Crystal Well 的阵列与 bank 组织](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/992df022faba72d3_04_figure.jpg)

Crystal Well 有 128 个 bank；同期 DDR3 仅 8 个，DDR5 也常为 32 个。读后恢复在各 bank 独立进行，bank 越多，请求撞上仍在恢复的 bank 的概率越低；单 bank 只需 6 个 array cycle 恢复，主存 DDR 的随机 bank cycle 往往是数十周期。

![图 5：四象限 banking；每象限选一个 bank，两周期各读出 16 B，共组成 64 B cache line](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/58c63a6c6c7a4650_05_figure.jpg)

每个 bank 数据宽度为 64 bit（8 B），图 5 展示一条 64 B cache line 如何由四个象限并行供给。

### 分离读写总线的 OPIO

![图 6：Haswell/Broadwell 相同的 OPIO 双向独立 64-bit 数据总线](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/7239eac98e922f9d_06_figure.jpg)

标准 DDR 用同一组引脚读写，方向切换需要 turnaround，期间总线空闲；OPIO 用独立 64-bit read bus 和 write bus，可以交替周期处理读写，甚至双向并行。地址总线只有一条，但每个请求是一条 512-bit cache line，数据传两周期，单地址通道足以喂满两条数据总线。读写各半时反而最容易最大化总带宽。

刷新也按 64 个 bank group 独立进行，每组两个 bank；未刷新的组仍可服务请求。DDR3 通常整 rank 同时刷新，DDR3L/LPDDR3 虽支持 per-bank refresh，bank 数也少得多。Crystal Well 还可自刷新并关闭 OPIO，标准 DDR 则需要内存控制器发刷新命令。

![图 7：Crystal Well 自刷新与功耗状态](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/678df6adf4c0ed61_07_figure.jpg)

1.6 GHz eDRAM 配合双倍 OPIO 速率，等效 DDR-3200；最高可到 2 GHz，理论上读、写各 64 GB/s。电压低于 1.1 V，而标准 DDR3 为 1.5 V。Intel 宣称 OPIO 在 3.2 GHz、双向合计 102 GB/s 时约耗 1 W。

代价同样真实：128 bank 的寻址/恢复逻辑、自刷新逻辑占掉 bitcell 面积；分离读写需要更多封装走线；固定 die 也没有 DIMM 的容量弹性。它不适合当主存，却适合当 128 MB L4。

### 体系结构视角：DRAM 的慢并非只有 bitcell 决定

主存为成本和容量选择少 bank、共享双向总线与较宽松时序；Crystal Well 以更多外围逻辑、更多连线和较低容量换 bank-level parallelism。随机访问延迟、混合读写吞吐和高负载排队因此同时改善。它说明“DRAM 必然慢”并不准确，系统接口和调度组织同样重要。

## Broadwell 如何把 eDRAM 做成 L4

Haswell，以及很可能 Broadwell，都使用 non-inclusive victim cache：L3 被替换的 victim line 进入 eDRAM，L4 无需重复保存仍在上层的 line。Crystal Well die 主要只有 data array 和简单控制；cache tag 放在 CPU die 的 L3 slice 内。

Broadwell L3 从 8 MB 缩到 6 MB，为 L4 tag 腾出面积。tag 每次 lookup 都要按 way 比较，适合放在先进 14 nm SRAM 上，而非独立 eDRAM die。

![图 8：L3 slice 中并行检查 L3 与 eDRAM tag](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/ce63f48331e1ad7e_08_figure.png)

L3 与 L4 tag 并行查，L4 miss 不必先绕 ring 访问 eDRAM 控制器、再回头访问内存。

![图 9：eDRAM 控制器拥有独立 ring stop](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/916ede4a59a434d0_09_figure.png)

该 stop 与四个核心/L3 slice、System Agent、iGPU 一起挂在 ring 上。这些结构来自 Intel 公开论文和框图；“Broadwell 与 Haswell 相同”的部分仍带推定，不能写成已经由 RTL 核实。

## 实测：约 36.6 ns、50 GB/s

![图 10：Broadwell L1/L2/L3/L4/DRAM load-to-use 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/9fdbeccac137a09c_10_figure.jpg)

L4 约 36.6 ns，在 3.8 GHz 接近 140 周期，远不能替代 L3；6 MB L3 仍负责低延迟命中。

![图 11：Broadwell eDRAM 与无 eDRAM Haswell 的延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/c1340dde7efc0d81_11_figure.png)

溢出 L3 后，Broadwell 由 L4 把延迟压在 DRAM 之前。1 GB 工作集下 Broadwell DRAM 为 64.3 ns、Haswell 为 71.2 ns，但主要因为前者使用 DDR3-1866 11-11-11，后者只是 DDR3-1333 CL9，不能归因于核心代际。

![图 12：eDRAM 只读与 read-modify-write 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/a6e32609c61d1943_12_figure.png)

只读约 50 GB/s 封顶；读改写因为双向总线而更高，但未翻倍，可能受高负载 bank conflict 限制。这是根据现象的解释，不是计数器确认。

![图 13：L3 与 eDRAM 带宽随核心数扩展](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/83170b3a49ae9f8b_13_figure.png)

eDRAM 只有一个 OPIO 和一个 ring stop，四核即可饱和；L3 则按核心数分 slice，每 slice 可在更高 uncore 时钟下提供 32 B/cycle，聚合带宽随核心数增长。即使提高 eDRAM 频率，最终也会碰到单 ring stop 上限。

### 高利用率下的延迟

请求接近带宽极限时会排队，平均延迟通常急升。Intel 论文称 Crystal Well 对随机流量的 load sensitivity 很小，高 bank 数、双向独立总线和快速 bank cycle 都有帮助。

![图 14：Intel 对 Haswell 有/无 eDRAM 的带宽利用率—延迟测试](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/1d14d3d975f7d1b0_14_figure.jpg)

复测时启动可变数量的带宽线程，并用 busy-loop 节流；另一个延迟线程固定在独立核心，使用 2 MB 大页降低地址翻译开销。

![图 15：Broadwell 复测；32+64 MB 命中 eDRAM，1+1 GB 进入 DRAM](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/6686c4392e9f03a1_15_figure.png)

eDRAM 到 99% 带宽效率时延迟约翻倍，但上升仍平缓；主存超过 85% 利用率后延迟已超过 101 ns。Intel 可能用 4 KB 页，因此原论文数字还混入更多 TLB/page walk 开销，二者只能比较趋势。

### 体系结构视角：可持续带宽决定排队延迟

基础 load-to-use latency 只描述空载路径。真实多核场景中，bank、总线和 ring stop 都是排队服务台；利用率接近 100% 时，少量新流量就会让队列等待非线性增长。MSHR、Load Queue 和乱序窗口只能维持更多未决请求，不能消除服务率上限。验证应同时扫线程数、读写比例和节流强度，而非只测单核延迟。

## 没有 L4 PMU 事件，怎样估算命中率

Broadwell 没公开 eDRAM 性能事件。测试尝试组合 CBo（Cache Box，即 L3 slice）lookup state 与 System Agent 的 ARB 仲裁队列计数。CBo lookup 为 I（invalid）表示 L3 miss；若没有 L4，该 miss 通常经 ARB 访问 DRAM，而 L4 hit 可由 CBo/eDRAM 路径满足。

![图 16：CBo、ring、eDRAM 与 System Agent ARB 的关系](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/024de31984f5fa26_16_figure.png)

![图 17：不同工作集下 CBo L3 miss 与 ARB 请求的关系](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/19092bf9662534f0_17_figure.png)

微基准中两类事件可提示容量边界，但完整 SPEC 很难解释。一条 L3 miss 可能触发多个 ARB 请求：从 DRAM 取新 line；被替换 L3 line 进入 L4；它又替换 dirty L4 line，后者回写 DRAM。不过这一解释仍不充分，因为无 eDRAM 的 i5-6600K 上 ARB 请求也略多于 L3 miss，说明还有未知流量。

![图 18：SPEC CPU2017 中按 CBo/ARB 推算的 L4 命中行为](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/6a4a62a1ea2b822c_18_figure.png)

因此后面的“L4 hitrate”只是估算，不是精确硬件事件。

![图 19：SPEC CPU2017 单项结果与估算 L4 命中率](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/ac8cb34658586d9e_19_figure.png)

`520.omnetpp` 的 L3 miss 很多，估算 L4 hitrate 超过 84%，足以让 Broadwell 超过频率更高、架构更新的 Skylake。

![图 20：Broadwell 与 Skylake 的 SPEC CPU2017 汇总](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/643bbb6b94583dc5_20_figure.png)

其他项目 Broadwell 都未取胜。i5-6600K 频率为 3.9 GHz、Broadwell 为 3.8 GHz，Skylake 架构和频率总体占优：SPEC CPU2017 integer 领先 5%，floating point 领先 18.3%。页面没有在此完整披露编译器、flags 和 input，不能把这些数字当成跨平台标准排名。

### libx264

SPEC 同时测试编译器与硬件，不含大量手写汇编；libx264 则为常见 ISA 提供汇编优化。测试把一个线程固定到每个物理核心。

![图 21：Broadwell 与 Skylake 的 libx264 性能](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/7586de8e171c2d3c_21_figure.png)

向量密集编码中 Skylake 领先 4.8%。

![图 22：libx264 的 System Agent 流量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/5f9dd7ff8441c350_22_figure.png)

计数器显示 eDRAM 把 System Agent 流量减少一半以上，可推测 DRAM 流量也大致减半。但双通道 DDR4-2133 的 i5-6600K 并不常受内存带宽限制，因此流量下降没有转化为胜利；若平台只有早期 DDR3，作用会更大。

### 体系结构视角：减少 DRAM 流量不保证提高核心性能

缓存收益取决于被消除的是带宽瓶颈还是延迟瓶颈。libx264 计算与向量执行占比较高，主存未饱和时，L4 命中只是减少外部流量；140 周期 L4 延迟也不够低，无法抵消 Skylake 的核心 IPC 与频率优势。对 `omnetpp` 这类高 L3 MPKI 工作负载，84% 估算命中率才会改变关键路径。

## Skylake eDRAM：更通用，却更不利于 CPU 延迟

Intel 在部分 Skylake SKU 延续 Crystal Well，但把 eDRAM tag 和相关逻辑移到 System Agent，控制器也不再有独立 ring stop。

![图 23：Broadwell 与 Skylake eDRAM 系统组织对比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/6f13782d030eeed2_23_figure.png)

所有主存访问都可受益，display engine 尤其合适：阅读网页或编辑文档时 CPU 很闲，屏幕刷新却持续占用 DRAM 带宽。

![图 24：Skylake eDRAM 与主存带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/791dd7887a2ba151_24_figure.png)

带宽略有改善，可能小幅提高了 eDRAM/OPIO 频率。但 tag 不再与 L3 并行查；L3 miss 到 System Agent 后才知道是否命中 L4。主存又必须等 L4 tag 判 miss 才能启动，否则会失去缓存意义。

![图 25：Skylake eDRAM 和 DRAM 的 load-to-use 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/9b5a732a633376b4_25_figure.png)

L4 远离 CPU、靠近内存控制器，CPU 这种延迟敏感客户端吃亏；Skylake eDRAM 延迟已接近快速 DDR3，DRAM 延迟也因串行 tag 检查而回退。

![图 26：eDRAM、DDR4 与 DDR5 的带宽/延迟演进](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/32128bf66bddb9d6_26_figure.png)

后期 DDR4 接近 50 GB/s；DDR5 能超过 eDRAM，并在越过 50 GB/s 时维持较好延迟，OPIO 已显陈旧。消费级封装走线本身进步有限；AMD Zen 2 以后 IFOP 只承载 DRAM/I/O，带宽也不足以直接服务类似大缓存。

## eDRAM 的历史位置

![图 27：Crystal Well 与主存 DRAM 设计取舍](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/5fcafd569c6c257a_27_figure.png)

Crystal Well 证明，主存 DRAM 的少 bank、双向共享总线和较长 bank cycle 是成本取舍，不是 DRAM 技术不可改变的天条。

![图 28：IBM POWER8 片上 eDRAM L3](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/cbdc1e3a5345a579_28_figure.jpg)

POWER8 在 monolithic die 内访问 eDRAM，L3 load-to-use 仅 6.86 ns，说明合适互连下 DRAM 可达到很强的缓存性能。Broadwell 仍选择廉价封装走线、旧 22 nm eDRAM 和 chiplet L4，在成本与性能间妥协。

![图 29：Broadwell eDRAM 与 AMD 3D V-Cache 的延迟/容量定位](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_broadwell_edram_wechat_article_zh/32b25d2df12bc4c3_29_figure.png)

AMD V-Cache 是精神上的继承者：同样加一颗 cache die，却用先进垂直互连和更快 SRAM，专门优化 CPU 性能，特征远胜 Crystal Well。SRAM 密度和主存带宽也持续进步：Meteor Lake iGPU 已有 4 MB L2，CPU 有 24 MB L3；LPDDR5-7467 理论带宽超过 100 GB/s，单靠 CPU 核心都难以饱和。大 L4 的必要性因而下降。

## 结语

Broadwell eDRAM 不是“更慢的大 L3”，而是一套完整系统：128-bank、快速恢复、独立读写 OPIO、L3/L4 tag 并行检查和 non-inclusive victim 策略，共同把 128 MB 密度优势变成约 36.6 ns、50 GB/s 的 L4。

它减少 DRAM 流量，却无法稳定战胜一年后到来的 Skylake；77 mm² cache die 增加成本，单 OPIO/ring stop 又限制多核带宽。Skylake 把缓存移近内存控制器后覆盖面更广，CPU 延迟却进一步恶化。随着 DDR4/DDR5 和片上 SRAM 进步，Crystal Well 退出有充分理由。

但它仍展示了高容量缓存的长期价值。未来若 Intel 用先进封装重新引入大容量 SRAM，思路会更接近 V-Cache，而不是复刻 OPIO eDRAM。是否值得，仍取决于目标工作集、额外延迟、带宽扩展、封装成本和功耗，而不是容量数字本身。

## 参考资料

- Fatih Hamzaoglu 等，*A 1 Gb 2 GHz Embedded DRAM in 22nm Tri-Gate CMOS Technology*，ISSCC 2014。
- Per Hammarlund 等，*Haswell: The Fourth-Generation Intel Core Processor*，IEEE，2014。
- Eric J. Fluhr 等，*POWER8: A 12-Core Server-Class Processor in 22nm SOI with 7.6Tb/s Off-Chip Bandwidth*。
- Teja Singh 等，*Zen: An Energy-Efficient High-Performance x86 Core*，IEEE JSSC，2018。
- Jonathan Chang 等，*A 7nm 256Mb SRAM in High-K Metal-Gate FinFET Technology...*，ISSCC 2017。
- Jason Ross、Ken Lueh、Subramaniam Maiyuran，*Intel Processor Graphics: Architecture and Programming*。
- Rani Borkar 等，*14nm and Broadwell Micro-architecture*，2014。
- DDR3L per-bank refresh 资料：https://onlinedocs.microchip.com/oxy/GUID-BCEA4067-D69A-4529-81CC-133D9195C03C-en-US-4/GUID-8408C1C6-0BAA-41C0-85B5-02E34F257E76.html
