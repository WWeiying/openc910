---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "centaur_cha_die_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*Examining Centaur CHA’s Die and Implementation Goals*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2022 年 4 月 30 日
> - 链接：https://chipsandcheese.com/p/examining-centaur-chas-die-and-implementation-goals

CHA 是 Centaur 最后一颗 SoC，面向 Edge Server Inference：八颗最高2.5 GHz CNS x86 Core、2.5 GHz NCore ML Accelerator、16 MB L3、四通道 DDR4、44 PCIe Lane和双路 Link。本文从 Die Area 看目标如何决定核心：不是“把大核缩小”，而是有意把 CPU 频率和 IPC 控制在适合密度的范围，把面积留给加速器和 I/O。

## 对比 Haswell-E：相似 I/O/核数，Die 只有略多一半

CHA 用 TSMC 16 nm、194 mm²；八核 Haswell-E 用 Intel 22 nm、355 mm²。

![图 1：CHA 与 Haswell-E 等比例 Die Photo](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/centaur_cha_die_wechat_article_zh/118262315f6b7e3e_01_figure.jpg)

*图 1：两者均八核、四通道 DDR4、双路；CHA 44 PCIe 对40，L3 16 MB对20 MB。工艺标称不可直接等比例换算，Die 图提供整体实现证据。*

Haswell Core 约占三分之一，加 L3/Ring 约一半，其余 I/O。

![图 2：Haswell-E Area Breakdown](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/centaur_cha_die_wechat_article_zh/c7134f5bc090bdcd_02_figure.png)

*图 2：另约33.44%主要为 PCIe/QPI Logic 与 Bus。*

CHA I/O 也近半，但八 CNS+L3 只约三分之一，剩余可装面积约等于八 Core 的 NCore。

![图 3：CHA Area Breakdown](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/centaur_cha_die_wechat_article_zh/079624023b5786e9_03_figure.png)

*图 3：未标面积主要是 Bus、I/O Control、Dual-socket Interconnect。NCore 显然是第一优先级。*

Haswell-E 要服务 HEDT，3 GHz以上的 Single-thread 需要大、高频 Circuit；Broadwell 缩14 nm后 Core 仍大。

![图 4：Haswell/Broadwell Core 等比例](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/centaur_cha_die_wechat_article_zh/cebd73155fb2ef0c_04_figure.jpg)

*图 4：高频 Library、长 Pipeline 与更多 Critical-path Logic 都付出面积。*

CNS 只瞄准低功耗 Edge Server，以小 Core 达 Haswell-like IPC，却无法继续抬频。

![图 5：同频附近 7-Zip](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/centaur_cha_die_wechat_article_zh/5494f7d58ed21631_05_figure.png)

*图 5：Haswell Predictor 可追更长 History、Branch-heavy 7-Zip 更快；CNS 无文档 PMU，解释不能直接验证。*

![图 6：libx264 同频/Stock](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/centaur_cha_die_wechat_article_zh/da57eb6531be2264_06_figure.png)

*图 6：约14.67% 指令用 AVX-512 时 CNS 同频接近 Haswell；解除频率限制后 Haswell 明显领先。*

Y-Cruncher 中 23.29% 指令为 AVX-512，`VPMADD52LUQ` 12.76%、`VPADDQ` 9.06%；前者无直接 AVX2 对应。

![图 7：Y-Cruncher 的 CNS/Haswell](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/centaur_cha_die_wechat_article_zh/2e75502c2ba1fe39_07_figure.png)

*图 7：同频 CNS 大胜，Stock Haswell 靠高频追平；Haswell SMT 也补偿部分面积密度。*

### 体系结构视角：Core Area 的“效率”必须绑定目标频率

低频可用 High-density Cell/SRAM、短 Pipeline、更简单 Adder 与更少 Buffer；高频则需 High-performance Library、Pipeline Register、Carry Lookahead 和更多旁路。比较 mm² 时必须同时列频率、IPC、Voltage 与 Workload，否则小核心未必在目标产品上更高效。

## 对比 Zeppelin 与 Coffee Lake：通用性也占面积

Zeppelin（GF 14 nm）八 Zen 1、两组4核+8 MB L3，比 CHA 大约9%，却只有一半 DDR Channel、32 对44 PCIe。

![图 8：CHA、Zeppelin、Coffee Lake 等比例](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/centaur_cha_die_wechat_article_zh/c5f0e4a5f15e352b_08_figure.jpg)

*图 8：三者节点近似但 Foundry/Library 不同，不作纯工艺归因。*

![图 9：Zeppelin Area Breakdown](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/centaur_cha_die_wechat_article_zh/da3325fc14cee4f8_09_figure.png)

*图 9：L3 面积近似，TSMC 16 nm/GF14 nm High-density SRAM量级接近；Core Area介于 CHA 与 Haswell-E。*

Zeppelin 还要兼任 Desktop/Workstation/Server Building Block：USB3.1、PCIe/SATA Multi-mode、IFOP 都耗面积，却能一 Die 扩到四 Die EPYC（32核、8 DDR Channel、128 PCIe）。Zen 1 需 Desktop 频率，因此用128-bit Execution/Register，把256-bit AVX拆两 Uop来省 Vector Area。

![图 10：CNS 与 Zen 1 Core 面积](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/centaur_cha_die_wechat_article_zh/ee278d52aaeaa921_10_figure.jpg)

*图 10：Zen 1 不含 L2 已约5.24 mm²，仍大于含 L2 的 CNS。*

Zen 1 以适中 IPC/频率和 SMT 平衡密度。

![图 11：Azure Zen 1 Server 测试配置](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/centaur_cha_die_wechat_article_zh/befc93453d09f0c8_11_figure.png)

*图 11：Cloud VM 是平台边界。*

![图 12：7-Zip 的 Zen 1/CNS](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/centaur_cha_die_wechat_article_zh/a5b04fcbe45fba32_12_figure.png)

*图 12：Server Zen 1 Boost 低于 Desktop，却在轻线程和同频 IPC 都领先。*

![图 13：libx264 的 Zen 1/CNS](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/centaur_cha_die_wechat_article_zh/6c43140a715eedb3_13_figure.png)

*图 13：AMD 的大 Vector Non-scheduling Queue 减少 Renamer Stall，价值超过 CNS 较高 Execution Throughput。重 Vector AVX-512 的 Y-Cruncher 则由 CNS 大胜。*

Coffee Lake 把 Core+L3 超过一半面积、约四分之一给 iGPU；其 GPU 无论绝对/比例都比 NCore 大，剩余才是有限 I/O。

![图 14：Coffee Lake Area Breakdown](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/centaur_cha_die_wechat_article_zh/432b22b37f8ad7c6_14_figure.png)

*图 14：窄 Client 目标让它在小 Die 里塞入更多 CPU Performance。*

![图 15：Skylake Core 跨 Kaby/Coffee/Comet Lake](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/centaur_cha_die_wechat_article_zh/34b60c6d39a46079_15_figure.png)

*图 15：同基本核心经 Process Tweak 提频，面积大于 CNS/Zen 1。*

![图 16：Kaby Lake Die](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/centaur_cha_die_wechat_article_zh/cf5ea87558d4680d_16_figure.jpg)

*图 16：Skylake Core 还为 AVX-512 Ready 留面积，让同一设计覆盖 Ultrabook 到 Server；这是设计复用换面积。*

## AVX-512：CNS 追求最低成本，Skylake-X 追求最大收益

![图 17：CNS 与 Skylake-X 的 AVX-512 选择](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/centaur_cha_die_wechat_article_zh/d2c5b70270e3d9d4_17_figure.jpg)

*图 17：CNS 扩展 RAT 处理 Mask Register、Decoder 识别指令，只增加重视的 Specialized Unit；不采用 Intel 那种全面加宽 Register/Execution。*

![图 18：特定内核的 AVX-512 Speedup](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/centaur_cha_die_wechat_article_zh/025b70d9637eddf8_18_figure.png)

*图 18：灰条相对 Table Lookup；Skylake-X 不支持 AVX-512 Integer FMA而未测。CNS 面积成本低但仍能在匹配指令上明显加速，不代表所有 AVX-512 负载。*

## 设计逻辑：低频、最低限度 AVX-512、适中 ROB

Centaur 需要低成本 Edge SoC，又要 NCore、PCIe 和 Memory I/O，只能让 CPU 追密度。高性能 SRAM Bitcell 的示例为 Samsung 7 nm 0.032 µm²，高密度为0.026 µm²；高频还要更深 Pipeline 与复杂 Circuit。

CNS 只追 Haswell-like IPC，而非当时最新 Skylake。ChampSim 对7-Zip Trace 的 ROB Occupancy 显示多数周期要么低于200项，要么直接接近填满。

![图 19：模拟 ROB Occupancy 分布](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/centaur_cha_die_wechat_article_zh/3ee4308104ad1537_19_figure.png)

*图 19：GLC Baseline 来自站内旧 Cache Study，属于模拟而非 CHA PMU。*

![图 20：ROB 容量的累计覆盖](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/centaur_cha_die_wechat_article_zh/3267f8f857456eb3_20_figure.png)

*图 20：超过约200项开始收益递减；扩大 ROB 还必须扩大 RF/Scheduler/LSQ，否则别处先满，面积增长不成比例。*

CNS 在2.2 GHz Heavy AVX 约65 W，2.5 GHz 暴增到140 W，显示已过 Efficiency Knee、不适合消费者。CHA 每 Socket 又只有八核，未使用 NCore 的程序也缺多线程竞争力。

![图 21：Core Width、Window、Vector 与 Clock 的表层对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/centaur_cha_die_wechat_article_zh/80d583ff40767387_21_figure.jpg)

*图 21：关键结论是强 Vector Unit 可以放进小核，只要频率/IPC目标按密度设定。Centaur 团队约100人、使用上一代节点，说明这类路线对有限资源可行。*

## 如果当年走另一条路

这是明确的 Speculation。若把八核 CPU Complex+Cache 复制四倍，约246 mm²；加 I/O 后，32核 CNS 仍可能比28核 Skylake-X 677.98 mm² 小得多。

![图 22：假想32核 CNS Die](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/centaur_cha_die_wechat_article_zh/e99e540beecb760f_22_figure.jpg)

*图 22：MS Paint 可视化约372 mm²，不是可布线 Floorplan。2019 前可用低价/AVX-512 与32核 Zen1 EPYC 竞争，后者 Vector 较弱。*

Zen 2+TSMC7 nm 后，AMD 有更大 OoO、更快/大 Cache与256-bit Unit，CNS Core-to-core 已无机会。

![图 23：CNS 与 Zen 2 综合性能](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/centaur_cha_die_wechat_article_zh/6de40eb01d498b96_23_figure.png)

*图 23：即使 CNS 2.5 GHz 也明显落后。*

![图 24：八核 File Compression](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/centaur_cha_die_wechat_article_zh/f8c37844025f76cb_24_figure.png)

*图 24：CNS 从四到八核缩放异常差。*

![图 25：Y-Cruncher 最佳场景](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/centaur_cha_die_wechat_article_zh/6aca09e4553083e2_25_figure.png)

*图 25：Zen 2 仍靠高频+SMT 领先；7 nm 又让单 Socket 可64核。*

文章设想若 CNS 缩到7 nm，可能成为带 AVX-512 的最小 CPU Core、类似 Altra 但 Vector 更强；被 Intel 收购后，其 Vector 技术也可能补 E-Core 的 AVX-512，解决 Alder Lake ISA 不一致。均为当时设想，没有后续实现事实。

## 参考资料

- Chester Lam, *Examining Centaur CHA’s Die and Implementation Goals*, Chips and Cheese, 2022-04-30
- Centaur Linley Presentation；Intel/AMD Die Photo 与公开规格
- ChampSim 修改版 ROB Occupancy 模拟
