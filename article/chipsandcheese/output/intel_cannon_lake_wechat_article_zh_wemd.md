---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "intel_cannon_lake_wechat_article_zh"
---

> 英文标题：Cannon Lake: Intel’s Forgotten Generation<br>
> 撰文：Chester Lam<br>
> 首发：Chips and Cheese，2022 年 11 月 15 日<br>
> 原始链接：https://chipsandcheese.com/p/cannon-lake-intels-forgotten-generation

Palm Cove，常被直接称作 Cannon Lake 核心，是 Skylake 的 10 nm 工艺移植版。按 Intel 当年的 Tick-Tock 节奏，它本应是 Skylake 之后风险较低的“Tick”；但 2018 年 Cannon Lake-U 到来时已经迟到，Skylake 甚至完成了 Kaby Lake 高频刷新。

10 nm 困难把产品压缩到唯一 SKU：Core i3-8121U，2 核 4 线程、15 W、最高 3.2 GHz，而且集成 GPU 被禁用。cha0s 在该机上完成微基准；Fritzchens Fritz 则对同型号芯片开盖拍摄。本文把 SoC 代号和核心架构分开使用，避免把 Cannon Lake 产品与 Palm Cove 核心混成一个概念。

![图 1：Cannon Lake/Palm Cove 与 Kaby Lake/Skylake 等名称对应](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/edc87e1ca9133f86_01_figure.jpg)

Palm Cove 大体延续 Skylake，下面集中看工艺、少量核心结构、分支预测、AVX-512、内存系统，以及软件无法触达的 Gen 10 iGPU 和 System Agent。

## 10 nm：密度成功，性能功耗失败

Intel 原计划让 10 nm 相对 14 nm 实现巨大密度跨越，并继续领先其他厂商的“10 nm”节点。

![图 2：Intel 2017 年新闻资料中的制程密度主张](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/6ec09d786a7d56da_02_figure.jpg)

libx264 是 Palm Cove 的有利场景，因为能使用 AVX-512。测试锁定 2 核 4 线程，并分别比较封装功率与核心功率。

![图 3：libx264 在 Cannon Lake、Kaby Lake 与 Goldmont Plus 上的性能—封装功率](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/3e1c18ac63ee2762_03_figure.png)

封装功率下，早期 10 nm 表现很差：重叠功率范围内，14 nm Kaby Lake 更快；对同为 14 nm 的低功耗 Goldmont Plus（Celeron J4125/Gemini Lake），Palm Cove 只在轻薄本功率区较高端领先。极低功率设备反而可能更适合 Atom 核心。

![图 4：同一负载按核心功率比较](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/80a01b7da2c52639_04_figure.png)

核心功率口径下 Palm Cove 以相近性能少约 10% 功率，但一部分很可能来自 AVX-512 用更少指令完成工作，而非工艺本身。Kaby Lake 的 uncore 计数器多数点只有略高于 1 W，明显低于 Skylake 负载常见约 6 W，也低于 Cannon Lake 的 3—4 W 和 Gemini Lake 的 2—3 W，数据可能异常，因此封装比较不能假装精确。

7-Zip 压缩 2.67 GB 文件，几乎是纯整数，不享受 AVX-512。

![图 5：7-Zip 性能—封装功率](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/1626b1b4760a60fd_05_figure.png)

Cannon Lake 在 7 W 以上略胜 Gemini Lake，但远非新节点应有的压倒性优势。

![图 6：7-Zip 性能—核心功率](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/405c109b3351efd9_06_figure.png)

去掉 AVX-512 后，Palm Cove 连核心功率也落后 Kaby Lake，且后者能扩展到更高性能。libx264 的部分优势因此更像指令集收益。

![图 7：Fritzchens Fritz 裸片图中按同尺度裁出的 Palm Cove 与 Kaby Lake 核心](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/58a8697c35dbd4f6_07_figure.png)

10 nm 的密度却真实可见：Palm Cove 面积只有 Kaby Lake 的 43%。高密度给 AVX-512 留出晶体管预算，却没有带来通常随 FinFET 缩节点而来的 performance/W 改善，Intel 只能继续用 14 nm 覆盖产品线。

![图 8：Cannon Lake 裸片功能区推测标注](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/3e405589f35b374d_08_figure.jpg)

图 8 的区域识别是基于裸片观察的推测，不是 Intel 官方 floorplan；CPU 核心、ring stop 与 L3 合计略超 die 的 16%。

### 体系结构视角：工艺密度、频率和能效不是同一个指标

更密的晶体管可缩面积、增加功能，却可能因电阻电容、漏电、设计规则和良率约束无法达到目标电压频率。Palm Cove 的结果说明“面积缩至 43%”不能推出“同功率更快”。验证工艺收益应在相同逻辑、相近电压频率和统一功率口径下比较；本文跨 SoC、计数器异常及 AVX-512 都让纯工艺归因受限。

## 核心改动：小幅扩队列

Palm Cove 的 math scheduler 从 Skylake 的 58 项增到 62；可跟踪待退休 load 从 72 增到 80，store queue 从 56 增到 58。

![图 9：Palm Cove 核心结构；除实测差异外按 Skylake 假设](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/8f1a9ae5f9bf926c_09_figure.png)

这些变化很小，性能影响可能难以测量，但比以往纯工艺 Tick 完全不改结构更积极。图中未实测部分不能当作 Palm Cove 官方参数。

## 分支预测：BTB 略大，密集分支稍有改善

![图 10：不同分支数量与间距下的 taken branch 吞吐](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/549988f804cbbf8a_10_figure.png)

Palm Cove BTB 组织接近 Skylake。Skylake 约 4096 项；分支间隔 32 B 时，Palm Cove 能跟踪约 4608 条。只要间隔至少 32 B 且落在约 128 项快速跟踪结构内，taken branch 可零气泡；主 BTB 目标带来 1 周期惩罚。

![图 11：小于 32 B 间距时 Palm Cove 与 Skylake 的 taken branch 代价](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/862282346ce32301_11_figure.png)

Skylake 相比 Haswell 在密集分支下回退，Palm Cove 没彻底解决，却有所改善。超过 BTB 容量后惩罚增长更缓，约 8K branch 出现拐点，可能是非 LRU 替换让命中率逐渐下降；这只是曲线推断。分支远超容量时，两者都约每 9 周期完成一条 taken branch。

### 体系结构视角：BTB 容量曲线不能唯一识别组织

同一拐点可能来自 set 冲突、替换策略、前端快速层或取指块边界。32 B 间距还把指令对齐和 fetch block 影响带入结果。要进一步验证，应扫 PC 映射、taken 密度、目标距离和冷热切换，并观察 frontend redirect/bubble 事件；没有 RTL 不能把 4608 直接写成精确物理 entry 数。

## AVX-512：客户端首次落地，但没有服务器双 FMA

Palm Cove 是首个支持 AVX-512 的 Intel 客户端核心。它沿用服务器 Skylake 已铺好的基础，却省掉额外 FPU 扩展，不具备 `2 × 512-bit` 浮点吞吐，因此理论 FP 吞吐与客户端 Skylake 基本相同；大部分其他 AVX-512 基础仍在。

![图 12：Palm Cove 向量指令延迟与吞吐；512-bit FMA 约 4.85 个实测周期](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/0728745dc59daa5a_12_figure.jpg)

uops.info 报告 FMA 4 周期，本测试接近 5 周期。另一种可能是测试中核心从 3.2 降到 2.65 GHz，软件反推把降频算进延迟；缺少频率轨迹，无法判定。

![图 13：混合 256-bit 与 512-bit FMA 的吞吐](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/d3c8ecd16ac62eb3_13_figure.png)

Palm Cove 会把已有两条 256-bit FMA 数据通路融合成一条 512-bit 操作，理论上混合宽度时有机会超过 1 IPC，类似 Centaur CNS 和 Zen 4；实测却只有 1 IPC。

![图 14：两条 256-bit FMA 与一条融合 512-bit FMA 的模式示意](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/f3fc3112a1c88061_14_figure.png)

发射 512-bit FMA 会阻止 port 1 同时接收另一条 FMA，且执行引擎似乎不能以细粒度在 `2×256` 和 `1×512` 两种模式间交替。这是测试支持的解释，不是官方调度规则。

服务器 Skylake-X/Ice Lake-X 也有相似现象：按 2:1 混合 256/512-bit FMA 时只有 2 IPC，理想调度本可让 port 0/1 各跑一条 256-bit、port 5 跑一条 512-bit，达到 3 IPC。向量整数不受同样限制；Palm Cove port 5 有全宽 512-bit integer unit，与 512-bit FMA 混合可明显超过 1 IPC。

![图 15：推测的 256-bit 向量执行数据流](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/a48529fb72f8dd38_15_figure.jpg)

![图 16：推测的 512-bit FMA 融合数据流](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/1e2fdf90a96f1e79_16_figure.jpg)

图 15—16 是把微基准映射到裸片布局的解释；512-bit 与混合宽度时都可能保持融合模式。

![图 17：Palm Cove（上）与 Coffee Lake/Skylake（下）的向量执行区](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/15b111de735c2f81_17_figure.jpg)

![图 18：两代核心单个 64-bit lane 的对比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/81322134e4ad8125_18_figure.jpg)

大块 FMA 自 Haswell 已存在，服务器 Skylake 将其复制，客户端 Palm Cove 没这样做，符合面积取舍。靠近 FP 单元和寄存器文件的新增逻辑可能对应扩到 512-bit 的 port 5 integer/vector logic；这些功能与实测吻合，但具体块识别仍是猜测。最左侧向量寄存器文件扩到 512-bit，而客户端 Skylake 的对应空间未使用。

![图 19：Palm Cove 相对 Skylake 的主要裸片差异，L2 区域用途未知](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/a6816658e7d757af_19_figure.jpg)

Load/store 与整数数据通路之间某结构也变宽，可能是 pending store data buffer；下面用带宽检验，不据此直接命名。

## L1/L2 与内存带宽

![图 20：单核 L1D 读带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/d2e0f3179ec07e31_20_figure.png)

AVX-512 让一次地址生成和一次 L1D 访问搬 512 bit，显著提高带宽；每周期也可做一条 512-bit store。Palm Cove 面对 512-bit 内存操作似乎几乎不节流，因此即使最高 3.2 GHz，比 4.5 GHz i7-7700K 低 40% 以上，仍保有实际带宽优势。

![图 21：单核缓存层级带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/03079bc96b3d670f_21_figure.png)

L2 持续带宽略超 32 B/cycle。客户端 Skylake 虽也有 64 B/cycle L2 datapath，AVX 可见带宽受 L1D 与 L2 prefetcher 干扰限制。

![图 22：全线程内存带宽；7700K 为 DDR4-2400，8121U 为 LPDDR4-2400，均 128-bit 接口](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/b416c6b4dabd8e68_22_figure.png)

四核 Kaby Lake 高频运行，但两核 Cannon Lake 也足以接近内存上限。4 GB 工作集下分别为 30.19 与 30.73 GB/s；相对理论值约 78.6% 与 80%，差异很小，两套控制器带宽效率都不错。

## 缓存与 DRAM 延迟

![图 23：按核心周期计的缓存/内存延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/38dddbd155de63d3_23_figure.png)

Palm Cove 周期数与 Kaby Lake 接近。双核只有 4 MB L3，四核 7700K 为 8 MB，因为 Intel 按核心数配 L3 slice。更短 ring、更小 L3、3.1 GHz ring 接近 3.2 GHz core，本应让 Palm Cove 明显占优，实际 L3 只少约 1 周期；可能是开发中放宽了 L3 timing，但这无法确认。

![图 24：换算为纳秒的缓存/内存延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/c08893566c04d9bb_24_figure.png)

低核心频率让 Cannon Lake 各级实际时间都落后。LPDDR4 DRAM 延迟更比 Kaby Lake DDR4 高 46% 以上；后者为 DDR4-2400 17-17-17-39，Cannon Lake LPDDR4 timing 更高。高延迟会削弱 30 GB/s 带宽的可利用性，尤其是 L2 prefetcher 难预测的访问。

## 不能启动的 Gen 10 iGPU

Cannon Lake iGPU 占 die 约 45%，唯一出货 SKU 却将其禁用。有关实验室中能运行但寿命不足的说法没有公开证据，不能当事实；软件无法测试，只能从裸片与旧代码观察。

![图 25：Cannon Lake Gen 10 iGPU 区域](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/1b6b684951d4c4f0_25_figure.jpg)

可见 5 个 subslice，每个 8 个 EU；Skylake/Kaby Lake GT2 同样每 subslice 8 EU，却只有 3 个 subslice。

![图 26：Kaby Lake GT2 对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/94720c889fe836ef_26_figure.jpg)

![图 27：Intel 客户端 iGPU 规模演进](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/416bf455c9f31a01_27_figure.jpg)

Ice Lake 后来以四核产品带来更大 GT2，Cannon Lake 显示扩张从 Gen 10 已开始。

![图 28：Cannon Lake 与 Kaby Lake 的 iGPU L3 位置；红框为 L3，绿框为 subslice](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/cbcf2ff5dc40a3b1_28_figure.jpg)

Gen 10 把 iGPU 自己的末级 L3 放在 subslice 中央，缩短访问；GPU L3 miss 后仍查 CPU 共享 L3。旧 Intel Compute Runtime 有 `CNL_2x5x8` 配置，与裸片相符，若对应正确，L3 约 1536 KB、6 bank；Gen 9 为 768 KB、4 bank。

![图 29：Coffee Lake 与 Cannon Lake subslice 近旁 SRAM 对比，未按同尺度](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/6569b50b7fec4b00_29_figure.jpg)

Gen 10 还可能把工作组本地 scratchpad（Intel SLM，AMD LDS，NVIDIA shared memory）从 iGPU L3 移进每个 subslice。近 EU 的大 SRAM 在 Gen 9.5 不存在；Gen 11 确实采用该做法，因此 Gen 10 很可能是试验场。局部 SLM 避免与 global memory 共用 subslice data port，可降低延迟、提高带宽，但裸片不能确认用途。

iGPU 还出现两块大型重复媒体逻辑，可能是编解码单元，暗示更高视频吞吐。整体上 Gen 10 更接近 Ice Lake Gen 11，是 Intel 从纯 CPU 性能转向多种片上能力的一次大步。

![图 30：Cannon Lake NUC 里与 CPU 封装并列的独立 GPU](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/acd5ae982e55516d_30_figure.jpg)

iGPU 不可用迫使系统用独显驱动画面，独立显存和 PCIe 链路无法像混合显卡笔记本那样在轻载关闭，严重破坏名义上的低功耗定位。Gen 10 没正式启用，却为 Ice Lake 后续图形功能打了基础。

## System Agent：显示、IPU 与 GNA

从 Sandy Bridge 起，客户端 SoC 大致分核心+缓存、iGPU、System Agent。后者承担旧 northbridge 的 I/O、内存和显示接口职责；显示控制器靠近内存控制器与物理接口，可在仅刷新屏幕时不唤醒 ring。

![图 31：Cannon Lake System Agent 与显示控制器区域](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/26fac0f6a2cdb800_31_figure.jpg)

Cannon Lake 显示控制器有更多逻辑和 SRAM。Intel 说明 SRAM 可缓存屏幕较大区域，以 burst 访问内存，让控制器在两次 burst 间进入低功耗。

![图 32：同尺度 Cannon Lake（左）与 Kaby Lake（右）显示控制器](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/39c6e094f4ac8d0f_32_figure.jpg)

更宽 pixel pipe 也能用更低频工作，以面积换能效；Gen 11 白皮书确认过这种取舍。

![图 33：各代显示引擎能力演进](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/2980d80a6745b962_33_figure.jpg)

Cannon Lake 应位于 Skylake 与 Ice Lake 之间，较接近后者；大量 SRAM 暗示目标高于 4K，但是否支持 Ice Lake 式 8K 无法验证。

System Agent 还有大型 Image Processing Unit（IPU）。常见 Bayer 传感器每像素只测一种颜色，需要结合邻域重建 RGB；IPU 可高效完成去马赛克等相机处理，尤其适合电池视频通话。它靠近内存控制器，因为输出帧写入内存。

![图 34：Intel Ice Lake 裸片中的 IPU，与 Cannon Lake 形态相近](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/intel_cannon_lake_wechat_article_zh/1ce254ae02d95cf6_34_figure.jpg)

Cannon Lake IPU 与 Kaby/Skylake 明显不同、接近 Ice Lake。它还首次加入 Gaussian and Neural Accelerator（GNA），面向机器学习降噪和语音处理。公开 slide 暗示本地 scratchpad 与宽 SIMD；估计吞吐不高，重点是节能。Intel 称可省下约一个 1.1 GHz Atom 核 50% 的工作，支持“宽而低频、近 SRAM 少搬数据”的解释，但具体裸片位置和内部结构仍是推测。

### 体系结构视角：固定功能单元是 SoC 能效的另一条扩展轴

当通用 CPU IPC 的边际收益变小，摄像头、语音、显示和编解码可以交给专用流水线。它们牺牲可编程性，以更少取指、重命名、调度和数据移动完成固定任务。验证收益不能只看 accelerator 峰值，还要计入数据往返内存、驱动唤醒和利用率；Cannon Lake 因 iGPU 被禁用，很多系统级设想无法在出货产品上验证。

## 结语

Cannon Lake 体现了 Intel 在 Zen 回归前设定的未来：CPU 市场优势巨大，继续堆通用核心意义有限，于是把 die 投向更强 iGPU、显示、IPU 和 GNA，让移动芯片更像手机 SoC。Palm Cove 本身只有队列小扩容与首个客户端 AVX-512，主要基础早在 Skylake/服务器版本已具备。

设想没有变成产品现实。10 nm 只兑现密度，没有兑现频率与能效；iGPU 无法出货，独显又破坏低功耗；3.2 GHz Palm Cove 甚至难胜旧 14 nm。Ice Lake 后来让部分功能正式落地，但 AMD Zen 已迫使 Intel 把更多面积重新投入多线程 CPU 性能。

这代产品的意义因此不在销量，而在两条技术遗产：Palm Cove 展示了客户端 AVX-512 和早期 10 nm 的真实取舍；未启用的 Gen 10、IPU、GNA 与显示引擎，则成为后续 Intel 异构 SoC 的试验场。
