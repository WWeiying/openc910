---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "cpu_energy_efficiency_mobile_avx512_wechat_article_zh"
---

> 英文标题：Caching Energy Efficiency Data – Mobile and AVX-512
> 撰文：Chester Lam
> 首发：Chips and Cheese，2022 年 7 月 15 日
> 链接：https://chipsandcheese.com/p/caching-energy-efficiency-data-mobile-and-avx-512

这是一篇数据搬运功耗测试的短续篇：加入 Mobile Zen 3、Willow Cove 和 Cascade Lake-X，用来观察同一核心在 Desktop/Mobile 的差异，以及 512 bit Load 是否真能以更少访问提高 Energy Efficiency。

## Zen 3：Vermeer 与 Cezanne 是不同系统

Desktop Vermeer 用两个 CPU Chiplet 加旧工艺 I/O Die，以低成本提供 Core、Cache 与 I/O，并追求很高 All-core Clock；跨 Die 搬运和常开 Non-core Power 不利能效。

Mobile Cezanne 用 Monolithic Die，集成大 iGPU，最多八核且每核 L3 只有 Vermeer 一半；Power Target 和持续 Clock 都低得多。

![图 1：5800U Cezanne 与 5950X Vermeer 的数据读取能效](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_energy_efficiency_mobile_avx512_wechat_article_zh/9e00a20fb895e03b_01_figure.png)

5800U 每核 Bandwidth 更低，却以更少 Energy/bit 搬数据；若 AMD Counter 准确，部分区域接近 Tremont。按 L1D Bandwidth 推断，5800U 约 3.1 GHz，四核 5950X 则 4.5～4.6 GHz。L1D 区内 5950X Package 超 90 W，5800U 约 25 W。

![图 2：Instruction Fetch 的 Energy/Instruction](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_energy_efficiency_mobile_avx512_wechat_article_zh/4f185eadeec90df8_02_figure.png)

Instruction Side 同样是 Cezanne 更省。Cache 内 Vermeer 可 Race-to-sleep，以更高功耗更快完成，因此瞬时 Power 会夸大差距；落到 DRAM 后两者都受 Memory Bottleneck，Vermeer 多耗电却快不了多少。

### 体系结构视角：Energy/bit 比 Watt 更接近任务成本

高频能增大瞬时功耗，却可能缩短执行时间；只有对同样 Bytes 和路径积分 Joule，才能看 Race-to-idle 是否划算。DRAM Bottleneck 下时间不再随 Core Clock 缩短，额外 Voltage/Frequency 几乎都变成浪费。

## Tiger Lake-U Willow Cove

Willow Cove 支持 AVX-512，一条 Load 搬 64 B，是 Zen 3 AVX 的两倍。它在 Private L1/L2 同时得到更高 Bandwidth 和更好 Energy Efficiency；超过每核 1280 KB 后，AMD L3 的 Bandwidth/能效又领先，DRAM AMD 略优。

![图 3：Willow Cove、Cezanne 的数据侧能效](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_energy_efficiency_mobile_avx512_wechat_article_zh/0e622c4f28be36cf_03_figure.png)

但 Willow Cove 可能在测试中 Throttle：初始约 2.3 GHz，L1D 区后段低于 2 GHz，恰好接近能效甜点。Golden Cove 的 Private Cache 也很高效，这一趋势可能从 Willow Cove 开始。

Instruction Side 则 Tiger Lake-U 在所有层级都比 Cezanne 每条指令耗能更多。

![图 4：Tiger Lake-U 与 Cezanne 的取指能效](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_energy_efficiency_mobile_avx512_wechat_article_zh/62421246c1308d37_04_figure.png)

结果还受 Clock 漂移污染。Willow Cove 的 Micro-op Cache 理应在每核 4 KB Loop 内维持 5 IPC，四核合计工作集到 16 KB 前不应降；图中却提前下降。按 Bandwidth 估算，约 45 s 负载内从接近 2.7 降到 2.3 GHz。因此不能把全部差异归于架构。

## AVX-512 在 14 nm 上也省吗

理论上，512 bit 相比 256/128 bit 搬同样数据只需一半/四分之一 Access，减少 AGU、Tag Check、Instruction 和 Retirement；但具体 CPU 的工艺、频率、Cache/Uncore 也进入结果。

![图 5：Cascade Lake-X 与 Skylake Client 的能效/带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_energy_efficiency_mobile_avx512_wechat_article_zh/fdd867488c0bb77a_05_figure.png)

10980XE Cascade Lake-X 的 L1D 反而略低效，尽管用 AVX-512 64 B Load；HEDT Platform 本就不以能效为目标。但其 Bandwidth 高 80% 以上，若应用需要吞吐，轻微能效损失可能合理。

L2 在更大容量下仍算合理；Mesh L3 很差，刚越过 L2 即约 80 pJ/bit，四线程 8 MB 只有 138.72 GB/s。四核 5950X 同工作集 L3 约 438 GB/s，Energy/bit 不到一半。

## Rocket Lake：更接近干净的 AVX-512 例子

Cypress Cove 是 Sunny Cove Backport 到 14 nm、面向高频；Kaby Lake 同样高频，工艺接近。

![图 6：Rocket Lake 与 Kaby Lake 的层级能效](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_energy_efficiency_mobile_avx512_wechat_article_zh/b421ae5bd4b6e584_06_figure.png)

Private Cache 差异很小：Kaby L1 每 bit 多约 9.8%能量，L2 少约 2.2%。但 Rocket Lake 在近似能效下提供超过两倍 L1/L2 Bandwidth，说明 AVX-512 有实际潜力。到 L3，AVX 已能饱和，AVX-512 不再带来 Race-to-sleep；更长 Ring、更大 L3 还增加能耗。

## Mobile 与 Desktop 的结论

Desktop 常被推过最佳效率点追性能。

![图 7：Chiplet、高频的 Vermeer](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_energy_efficiency_mobile_avx512_wechat_article_zh/8acb2cf645244195_07_figure.jpg)

Mobile 则受 Battery/Thermal 约束，AMD 改成 Monolithic，Intel/AMD Firmware 都限制 Package。Intel Sample 在持续四核负载逐步降频，AMD Sample 较稳定。

![图 8：Monolithic、集成 iGPU 的 Cezanne](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_energy_efficiency_mobile_avx512_wechat_article_zh/24cebe515ea28539_08_figure.jpg)

Laptop 很难用来反推纯 Core：OEM Cooling、PL1/PL2、Firmware 与 Ambient 可能和架构同样重要。

![图 9：测试过程中的 Package Power 随时间变化](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cpu_energy_efficiency_mobile_avx512_wechat_article_zh/f1b069089481a54b_09_figure.png)

Desktop 测试约 35～40 W 稳定，只在超 Cache 后因等待数据下降；Mobile 初高后降，i7-1165G7 持续四核希望低于 20 W。i7-11800H 是反例，55 W PL2 让它保持 4 GHz 以上。

## AVX-512 的结论

Intel 从 NetBurst 128 bit SSE、Sandy Bridge 256 bit AVX 到 512 bit AVX-512，长期领先 L1D Native Vector Width；同期 Athlon/Bulldozer 会拆成更窄微操作。宽 Access 确实能减少同样数据量的动态工作。

但没有完美 A/B：Tiger Lake 与 Mobile Zen 3 架构不同；Cascade Lake 平台功耗目标不同；Rocket Lake/Kaby 最接近，却仍跨代。因而能确认的是 AVX-512“有能效潜力”，不是所有 AVX-512 CPU 都更省电。软件还必须真正使用它；当时 Adoption 范围仍小。

## 参考资料

- Chips and Cheese：Caching Energy Efficiency Data – Mobile and AVX-512
- AMD RAPL/Power Counter 与各平台数据搬运微基准
