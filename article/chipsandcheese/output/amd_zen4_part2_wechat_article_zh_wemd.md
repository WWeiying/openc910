---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "amd_zen4_part2_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*AMD’s Zen 4, Part 2: Memory Subsystem and Conclusion*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2022 年 11 月 8 日
> - 链接：https://chipsandcheese.com/p/amds-zen-4-part-2-memory-subsystem-and-conclusion

上篇看到，Zen 4 没有大改 Zen 3 的调度与执行管线，而是通过更好的预测、更大的前端与乱序资源、更高频率，让既有执行能力得到更充分利用。接下来要回答真正决定这些资源能否吃饱的问题：数据从哪里来，Load/Store 如何排序，Cache 和 TLB 能否及时返回，16 颗核心又如何共享 DDR5。

## 测试平台与可比性

主要对象为 Ryzen 9 7950X/Zen 4，通常使用 DDR5-6000；Zen 3 主要来自 Ryzen 9 5950X/DDR4-3600，另有 3950X DDR4-3333 16-18-18-38；Golden Cove 来自 Core i7-12700K，部分结果使用 JEDEC DDR5-4800，AVX-512 数据由 CapFrameX 另测，Tiger Lake 数据由 cha0s 提供。

这些系统没有统一内存时序、频率和固件。Cache 区间的周期与每周期带宽更适合做结构比较；DRAM 端点受 DIMM、控制器和拓扑影响很大。原文章也明确要求不要把未匹配的 DRAM 数字直接排名。

## Load/Store 引擎：三条 AGU，两个 Load 跟踪层级

Zen 4 与 Zen 3 一样使用三条地址生成单元（Address Generation Unit，AGU）计算 Load/Store 地址，再把地址与 Store Data 交给 Load/Store Unit。后者既要让访问在架构上看似按程序顺序完成，又要允许大量操作投机并行。

AMD 从 Zen 1 起就把 Load 跟踪拆成两层。公开的 Load Queue 更像执行队列：Load 得到数据后即可释放；另一个更大结构一直跟踪到退休，文章称之为 Load Validation Queue。前者约 88 项，后者让 Zen 4 最多维持约 136 个 Load 在途。Intel 的 Load Queue 语义不同，不能直接只拿官方条目数比较。

![图 1：Zen 4 Load/Store 子系统的行为复原](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part2_wechat_article_zh/b5b8982ff501700e_01_zen4_load_store_subsystem.png)

*图 1：三条 AGU 后连接约 88 项 Load Execution Queue、约 136 项 Load Validation Queue 与 64 项 Store Queue；DTLB 为 72 项 L1、3072 项 L2，Page Walker 有 6 组，Page Directory Cache 标为不少于约 64 项；L1D 为 32 KB、8-way，Load 侧 3×64-bit 或 2×256-bit，Store 侧 2×64-bit 或 1×256-bit，后接 1 MB、16-way L2 与 Miss Address Buffer。图是公开资料和测试复原，不是 RTL。*

Store 必须留在 64 项 Store Queue，直到退休确认不会产生错误路径写入；512-bit Store 还会拆成两条微操作、占两项，所以 AVX-512 写密集代码承受更大压力。

### 体系结构视角：为什么 Load 可以早释放，Store 却要等退休

Load 只把数据送入可回滚的投机状态，若后续发现内存顺序违反，可以取消并 replay；Store 会改变共享 Cache 与其他核心可见的状态，通常必须等到按序退休后才提交。AMD 用独立 Validation Queue 保存已执行 Load 的顺序检查信息，让昂贵执行队列更快周转。

如果年轻 Load 在老 Store 地址未知时提前执行，预测正确可隐藏延迟，预测错误则重放依赖链。验证这条路径可观察 load replay、memory-order violation、两级 Load 队列 full、Store Queue full 与退休阻塞，而不能把 88 和 136 简单相加成一个“224 项 Load Queue”。

## Store Forwarding：精确匹配很快，跨页异常昂贵

若老 Store 与年轻 Load 地址重叠，数据可直接从 Store Queue 转发。精确地址匹配时，Zen 4 与 Zen 3 的依赖 Load/Store 链可达到 2 IPC，即每个 Load 看到约 1 周期延迟。

条件并不宽松：地址必须完全匹配；Store 跨过 32 B 对齐边界会增加 1 周期；Store 跨 4 KB 页边界时，快路完全失效。

![图 2：Zen 4 Store-to-Load Forwarding 矩阵](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part2_wechat_article_zh/f12e46d3dab37285_02_store_forwarding_matrix.png)

*图 2：网页正式图注说明使用 Henry Wong 的方法。矩阵按 Load/Store 偏移与大小显示精确匹配、完全包含、部分重叠、跨 32 B 和跨页路径；绿色快路与红色慢路说明“有重叠”远不足以保证转发。*

Load 完全包含在 Store 中时，Zen 4 为 6～7 周期，略好于 Zen 3 的 7～8。若两者部分重叠、但单靠 Store 数据无法完成 Load，Zen 4 为 19 周期；Zen 3 在 Store 4 B 对齐时为 18，否则为 25。更合理的解释是等待 Store 退休后从 L1D 重新取数，但延迟本身无法唯一确认内部协议。

![图 3：各代核心的 Store Forwarding 情形汇总](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part2_wechat_article_zh/1fe689cd4eadff0c_03_store_forwarding_summary.jpg)

*图 3：精确匹配为 Zen 4/Zen 3 各 1 周期，Golden Cove 每拍两 Load 加两 Store、等效 0.5 周期；Contained 为 6～7/7～8/5～6；失败重叠为 19、18 或 25、19～20。跨 4 KB 页时 Zen 4 达 43～44，Zen 3 约 34～44，Golden Cove 按 Load/Store 跨页组合约 27～41，Bulldozer 约 50～54 周期。*

Zen 4 保留大多数 Zen 3 行为，并改善常见情况，却在罕见跨页转发上略有倒退。Golden Cove 多数情形延迟更低，精确匹配还有吞吐优势；只有 Load 与 Store 同时跨 64 B Cache line 等组合会暴露 Intel 慢路。

## 未对齐访问：32 B、64 B 与 4 KB 是三条边界

Cache 并非按单字节任意读取，而是按对齐块访问。Zen 4 从 Zen 2 起以 32 B 块处理写入；Golden Cove 以 64 B Cache line 块处理。访问跨边界时需要两次标签/数据阵列操作，吞吐就会下降。

![图 4：未对齐 Store、Load 与跨页访问所需的内部工作](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part2_wechat_article_zh/a5487a2be87880ec_04_misaligned_access_paths.png)

*图 4：Zen 2/3/4 的跨 32 B Store 需要两次 L1D 写标签/状态与两个 32 B Sector；跨 64 B Load 需要两次标签检查并读取两条 Cache line；跨 4 KB 还需要两个虚拟到物理翻译。图解释工作量，不确认具体 bank 布线。*

Zen 4 的普通 misaligned Load 为约 1 周期，misaligned Store 为 2 周期。Zen 3 Store 只有 4 B 对齐时为 2 周期，否则 5～6；Zen 4 消除了这条常见慢路。Golden Cove 普通 Load/Store 约 1/2 周期，Ice Lake 同样约 1/2。

跨 4 KB 的 Load 在各代 Zen 上仍约 1 周期，说明 TLB 可在一拍服务多个查询；Golden Cove 为 3～4，Ice Lake 约 4。跨页 Store 则全部昂贵：Zen 4 约 33～34 周期，Zen 3 约 25 或 27，Golden Cove 24，Ice Lake 25。文章猜测 AMD 认为这种访问足够少，愿意以更高最坏代价换取频率。

![图 5：未对齐访问的倒数吞吐](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part2_wechat_article_zh/ff3631a5e62f5df9_05_misaligned_access_throughput.jpg)

*图 5：网页正式图注给出 Reciprocal Throughput。Zen 4 普通 Load/Store 为 1/2 周期，跨页为 1/33～34；Zen 3 为 1～2、2 或 5～6、1、25 或 27；Golden Cove 为 1、2、3～4、24；Ice Lake 为 1、2、4、25。*

### 体系结构视角：慢路设计看的是频率乘发生概率

把所有罕见组合都做成单周期，会让 L1D、TLB 与合并网络更大、更慢、更耗能。若编译器和分配器通常保证对齐，硬件可以让常见路径更快，把跨页 Store 交给复杂慢路。

但“罕见”取决于软件。网络包、序列化格式、压缩数据和手写 SIMD 都可能触发。微基准应覆盖地址偏移、访问宽度、Cache line 与页边界，并把普通未对齐和 Store Forwarding 重叠分开；异常或 replay 时还要验证不会留下不允许的部分架构可见写入。

## Cache 延迟：周期略增，纳秒反而下降

使用 2 MB 大页可减轻 TLB 压力，较纯粹地观察 Cache 层次。Zen 4 的最大变化是 L2 从 512 KB 翻倍到 1 MB，Load-to-use 增加 2 周期；L3 路径也相应多 2 周期。

![图 6：2 MB 页下的 Cache/内存周期延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part2_wechat_article_zh/6ac297aea301de6b_06_cache_latency_cycles_2mb_pages.png)

*图 6：Zen 4 L1D/L2 约 4/14 周期，Golden Cove 为 5/15；共享 L3 上 Intel 因非核心频率 Ring、两个 E-Core 集群和 iGPU 节点，接近比 Zen 多 20 周期。Golden Cove 用更大 L2 与更深窗口补偿。*

频率改变了真实时间。Zen 4 最高约 5.7 GHz，4-cycle L1D 只有约 0.7 ns；多数访问 L1 hitrate 超过 80%～90%，这条快路影响很大。1 MB L2 虽多两个周期，7950X 测得约 2.44 ns，只比 5950X 的 2.40 ns 略慢。

![图 7：2 MB 页下的真实纳秒延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part2_wechat_article_zh/becbb99761b3c9f1_07_cache_latency_ns_2mb_pages.png)

*图 7：把周期换成时间后，Zen 4 的 L1/L2/L3 都受益于高频。L3 回到约 8～9 ns，与 Zen 2 同级，却保持 Zen 3 统一八核 L3 的两倍单核可见容量。*

Zen 3 把八核、八 Slice 的 L3 统一后提高容量，却增加延迟；Zen 4 以高频把绝对延迟降回 Zen 2。它也低于 Zen 3 V-Cache 延迟，但 V-Cache 容量仍有约 3 倍优势。

![图 8：Zen 4 与 Zen 3 V-Cache 的容量—延迟取舍](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part2_wechat_article_zh/9ed177bb9452e11f_08_zen4_vcache_latency.png)

*图 8：Zen 4 以更低延迟覆盖常规 32 MB CCD L3，V-Cache 则用堆叠容量减少更多 DRAM 访问。哪条路线更快取决于工作集能否被额外 Cache 接住。*

1 GB 测试规模下，7950X/DDR5-6000 为 73.35 ns；12700K 使用 JEDEC DDR5-4800，3950X/DDR4-3333 16-18-18-38 为 72.76 ns。差距没有异常，但内存配置不一致，不作核心架构结论。

## 4 KB 页与 TLB：72 项一级，3072 项二级

应用通常使用 4 KB 页以减少碎片。一个不到 2 KB 的网络包或小文件若用 2 MB 映射，会浪费大量内存；代价是地址翻译条目压力增加。

Zen 4 把 L1 DTLB 从 64 增至 72 项，L2 TLB 从 2048 增至 3072。4 KB 页下，一级可无额外延迟覆盖 288 KB，二级可覆盖 12 MB，L2 TLB hit 增加约 7～8 周期。

![图 9：4 KB 页下的 Cache、TLB 与 Page Walk 延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part2_wechat_article_zh/382de82d4c1406d4_09_cache_latency_4kb_pages.png)

*图 9：未超出二级 TLB 时，Zen 4/Zen 3/Golden Cove 的 L3 约为 9.47/10.44/13.72 ns。到 12 MB 后，Zen 3 与 Golden Cove 的 2048 项 L2 TLB 开始溢出，延迟升至 12 ns 和 15 ns 以上；Zen 4 的 3072 项仍略低于 10 ns。*

L2 TLB miss 会触发最多四层页表访问。三种核心的 Page Walker 都有 Page Directory Cache，刚越过容量时未必真的产生四次下层访问；即便如此，任何 Page Walk 都比直接 L2 TLB hit 更慢。扩大 TLB 因而改善的是真实应用平均访存延迟，而不仅是一个容量数字。

### 体系结构视角：TLB miss 是“访问数据之前，先访问描述数据的数据”

页表本身存放在内存层次里。一次 Page Walk 可能命中 L1/L2/L3，也可能继续 miss，因此它既消耗延迟，也占用 Cache 和 miss 队列带宽。Page Directory Cache 保存高层页表节点，减少重复遍历。

诊断时应区分 L1 DTLB miss/L2 hit、真正 Page Walk、walk cache hit 与大页比例。若 12 MB 工作集在 4 KB 页下突然变慢、2 MB 页下不变，优先怀疑 TLB 覆盖，而不是 L3 容量。

## 单核带宽：私有 Cache 保守，L3 与 DRAM 并行性增强

Zen 4 增加 AVX-512，却没有扩宽私有 Cache：每周期 Load 带宽与 Zen 2/3 接近。1 MB L2 可降低对共享 L3 的需求，L1/L2 的 GB/s 提升主要来自时钟更高。

单核 L3 从 Zen 3 平均 24 B/cycle 提高到 Zen 4 的 27 B/cycle，接近 Core-to-L3 接口理论上限。文章推测 L2 与 L3 间队列更深，几乎能吸收整个 L3 延迟。

![图 10：单核 Cache 与 DRAM 读取带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part2_wechat_article_zh/6f1403232a7bb01a_10_single_core_cache_bandwidth.png)

*图 10：网页正式图注提醒各平台内存不同，不比较 DRAM；Tiger Lake 数据来自 cha0s，Golden Cove AVX-512 来自 CapFrameX。Golden Cove 在 L1/L2 显著更强，Zen 4 在 L3 反超，单核进入 DRAM 后仍维持很高请求率。*

Golden Cove L1D 可每周期三次 256-bit Load，或在 AVX-512 可用时两次 512-bit；L1D 到 L2 为 64 B/cycle。L2 工作集下，Golden Cove 使用 AVX-512 比 Zen 4 高约 40%；即使用 AVX，Intel 也可领先，因为 AMD L1D 无法同时处理 L2 fill 和向核心满带宽供数。

到 L3 则反转：Zen 4 几乎保持 L2 级带宽，Golden Cove 无其他核心竞争时也只有约 20 B/cycle。

AMD 的 L3 是 Victim Cache，只接收从 L2 驱逐的行，不在 L3 预取；L2 是最后能根据 L1 miss 流观察模式、向 L3/DRAM 发预取的层级。Zen 4 单核 DRAM 带宽很高，说明它能跟踪许多 pending L2 miss。

![图 11：用 Little’s Law 估算 L2 miss 跟踪深度](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part2_wechat_article_zh/5c2d685c656704d6_11_l2_miss_queue_estimate.jpg)

*图 11：按 64 B/请求计算，Zen 4 为 `(57.29 GB/s ÷ 64 B) × 78.72 ns ≈ 70.45` 项；Zen 3 约 49.72，Zen 2 约 36.46。4 KB 页测试还混入 Page Walk 请求，因此只能说明 Zen 4 可能有更积极 L2 预取、更深队列，或两者兼具。*

## 多核带宽：频率把同宽总线推到更高 GB/s

满线程时，7950X 的 L1D 带宽表明全核仍在 4.8 GHz 以上。Zen 的 Cache 层次运行在核心频率，或至少按同一集群最快核心速度运行，所以即便各层接口位宽没变，更高频率仍直接抬高 L2/L3 的 GB/s。

![图 12：多线程 Cache 与内存带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part2_wechat_article_zh/1dcffd58e7629b36_12_multicore_cache_bandwidth.png)

*图 12：Zen 4 的 16 颗核心在 L1/L2/L3 都取得很高总带宽。Alder Lake 依靠更宽 L1D/L2 曾能挑战旧 AMD 16 核；Zen 4 的高全核频率改变了局面，Alder Lake 只有启用非正式 AVX-512 才能匹配 L1D，L2 则仍追不上。*

AMD 把 L3 分成 CCD 集群，牺牲跨集群容量效率，换取更容易实现的低延迟与高带宽。Zen 4 继续扩大了相对 Intel 的 L3 优势。

## DDR5：72.85 GB/s 很高，却只有理论值的 76%

5950X/DDR4-3600 在 3 GB 读取测试略高于 50 GB/s，为理论值约 88%；7950X/DDR5-6000 达 72.85 GB/s，绝对带宽提高 43%，但 128-bit DDR5-6000 理论值为 96 GB/s，效率只有约 76%。

![图 13：双 CCD 与 I/O Die 的链路拓扑](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part2_wechat_article_zh/f6675ec963cefa51_13_zen4_ccd_iod_topology.jpg)

*图 13：AMD 图示每个 CCD 到 IOD 的写方向为 16 B/cycle，并标出 IOD、内存控制器与 Infinity Fabric。框图位宽需要结合 FCLK/UCLK 所在时钟域理解，不能直接相乘后把任何差额都归为同一链路。*

一种猜测是内存控制器到 Fabric 的 32 B/cycle 链路限制带宽。但 FCLK 为 2000 MHz 时只对应 64 GB/s，低于实测 72.85；若该链路按 UCLK 3000 MHz 工作，则恰好能覆盖 96 GB/s。数据不能排除 IOD 内部其他限制，却说明公开图的 32 B/cycle 不能简单按 FCLK 解读。

把读写按 1:1 混合也没有明显翻倍。DRAM 总线需要在读、写模式间切换，turnaround 会制造空闲周期。Read-Modify-Write 只比纯读高约 1%。普通 Write 本身还隐含 Read for Ownership（RFO）：核心先取整条 Cache line 取得所有权，再合并局部写。36.86 GB/s 写流量按读写各一份计为 73.72 GB/s，与纯读接近。

![图 14：不同访问模式的 DRAM 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part2_wechat_article_zh/f3d7ccc92037a83e_14_dram_access_patterns.png)

*图 14：网页正式图注说明使用 128-bit DDR5-6000，Add 与 Copy 都是 1:1 读写。图中 Add 约 73.65、Read 72.85、REP STOSB 63.76、Non-Temporal Write 63.20、REP MOVSB 50.94、普通 Write 36.86 GB/s。*

`REP MOVSB` 是微码字符串复制，提前知道长度并可避免 RFO，却仍因读写切换下降。`REP STOSB` 在确定覆盖整条 Cache line 时避免 RFO；`MOVNTPS` 使用 Write-Combining、绕过 Cache。两者都接近但未超过 64 GB/s：双 CCD 每个 16 B/cycle、FCLK 2000 MHz 的理论写上限。多数应用读远多于写，这不太可能成为常见主瓶颈。

文章最终更倾向于：Zen 4 DDR5 控制器提取理论带宽的效率不如旧 DDR4，可能在请求调度或次级时序上损失更多。但绝对带宽仍大幅增长，16 核向量负载也确实可能把 DDR5 吃满，因此有效 Cache 依然不可替代。

### 体系结构视角：带宽数字必须先定义“线上传了什么”

应用写入 36.86 GB/s，不代表 DRAM 只传了 36.86 GB/s。Write Allocate 会触发 RFO，复制还有源读取，读写切换又浪费总线周期。测带宽应区分应用有效字节、Cache line 事务、读/写方向与协议开销。

想定位链路瓶颈，需要同时改变 FCLK、UCLK、DRAM 速率、读写比例和指令类型；若结果随某个时钟线性缩放，才有较强因果证据。单一配置恰好接近 64 GB/s，只能形成假说。

## 总结：Zen 4 用制程与频率，把既有机器推得更满

Zen 4 像 Zen 2 一样，把架构更新与新制程合并，同时避免最激进的布局改造。密度提升特别适合扩大 BTB、微操作 Cache、寄存器、TLB 与 L2。

![图 15：Zen 4 与 Zen 2 的代际升级路径](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part2_wechat_article_zh/df18b79c0712e975_15_zen_generation_summary.jpg)

*图 15：Zen 4 相对 Zen 3 的要点包括：L1 BTB 约增 50%、L2 BTB 适度扩容、微操作 Cache 约增 68%、向量寄存器扩至 512 bit、调度与执行布局不变、L1D 仍 2×256-bit Load/1×256-bit Store、L2 TLB 从 2K 到 3K、L2 从 512 KB 到 1 MB并增加 2 周期。右栏把许多容量增长与制程密度联系起来。*

原始执行宽度从 Zen 2 到 Zen 4 变化不大，L1D 峰值也没增加；Zen 4 沿用 Zen 3 调度。AMD 宣称约 13% performance per clock 增长，看起来不如前两代醒目，却与 Ivy Bridge 到 Haswell 的 11.2% 同量级。更重要的是，频率大幅提高：只要 Cache 不让 DRAM 成为主瓶颈，性能通常近似随频率增长。文章认为 AMD 可能放弃调度器和 Store Queue 扩容，以换取高频；Raptor Lake 也用相似路线把 Thermal Velocity Boost 推到 5.8 GHz、普通 Turbo Boost 3.0 推到 5.7 GHz。

平均 IPC 还会掩盖 AVX-512：更强指令用更少指令完成同一工作，retired IPC 可能下降，performance per clock 却上升。512-bit 数据使每个调度项承载更多工作，新指令也能减少指令数。

Zen 4 的核心策略是提高利用率：更大窗口吸收执行需求突发，更准预测减少浪费，DDR5 提供更高带宽，更深 L2 miss 跟踪提高内存级并行，1 MB L2 与 3K L2 TLB 则降低平均延迟。单核 DRAM 超过 57 GB/s，是深层 pending miss 缓冲的行为证据。Raptor Lake 也把 P-Core L2 从 1.25 MB 增到 2 MB，只付出约 1 周期。

![图 16：libx264 中的 Zen 2 FP/向量端口利用率](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part2_wechat_article_zh/904caf7f455ff046_16_fp_pipe_utilization.png)

*图 16：FP0～FP3 平均利用约 27.06%、20.21%、27.81%、15.52%。正式图注指出执行单元即便在尖峰也不是瓶颈，FP 调度器很少因满而停；真正出现后端停顿的是 ROB 与整数寄存器。*

![图 17：一个周期窗口中的前端宽度利用率](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen4_part2_wechat_article_zh/b2bd40fa131910b8_17_frontend_width_utilization.png)

*图 17：正式图注追问“究竟该怎样衡量宽度利用率”。瞬时供给在周期间波动，平均 IPC 会混入分支、Cache 与后端反压；更大的 L1 BTB 让 Taken 分支后少空转，正是在不加宽六宽重命名的前提下提高有效利用率。*

有些 Zen 4 资源相比 Intel 显得轻：向量 Load/Store 带宽只有 Golden Cove 开启 AVX-512 时的一半，即使都用 256-bit AVX，Intel 每周期仍更高。但 Intel 不能把 16 颗 Golden Cove 全部塞进同一桌面芯片并长期高频运行。历史上 Conroe 到 Skylake 都是四宽，IPC 仍大幅增长；核心宽度不是架构进步的唯一维度。

文章以 Patreon、PayPal 与 Discord 结束，期待 AMD 与 Intel 后续如何继续挖掘相同宽度和执行资源。

## 体系结构视角：从 Zen 4 下篇得到的七点认识

第一，**Load Queue 的名字不等于同一种结构**。AMD 把执行与退休验证拆开，88 与 136 描述不同生命周期；跨厂商比较必须先统一语义。

第二，**Store Forwarding 是对齐、大小与地址关系共同定义的多条路径**。精确匹配 1 周期，部分重叠 19 周期，跨页 43～44 周期，平均性能取决于软件触发比例。

第三，**高频可以让“周期变多、时间变短”同时成立**。L2 增加 2 周期，却只从约 2.40 ns 变为 2.44 ns；L3 甚至回到 8～9 ns。

第四，**TLB 是 Cache 层次不可分割的一部分**。3K L2 TLB 让 4 KB 页覆盖 12 MB，推迟 Page Walk，使真实 L3 延迟优势大于单看 Cache 周期。

第五，**Victim L3 把预取责任压到 L2**。单核 57.29 GB/s 和约 70 项 Little’s Law 估算，说明 L2 必须制造足够多并行 miss 才能利用 DRAM。

第六，**协议流量决定带宽含义**。普通写包含 RFO，读写混合有 turnaround，Non-Temporal Store 又绕过 Cache；不先区分事务，就无法解释 36.86、63.2 与 72.85 GB/s。

第七，**核心优化可以是“让六宽更常有效”，而不是“把六宽改成八宽”**。预测、窗口、TLB、L2、MLP 与频率共同抬升实际吞吐，正是 Zen 4 的主要工程风格。

## 参考资料

- Chester Lam, *AMD’s Zen 4, Part 2: Memory Subsystem and Conclusion*, Chips and Cheese, 2022-11-08：https://chipsandcheese.com/p/amds-zen-4-part-2-memory-subsystem-and-conclusion
- Henry Wong, Store-to-Load Forwarding 微基准方法
- AMD Zen 4 IOD/CCD 与存储系统公开资料（原文章所引）
- Little’s Law（用于 L2 miss 跟踪深度的近似估算）
