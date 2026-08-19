---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "amd_zen5_avx512_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*Zen 5’s AVX-512 Frequency Behavior*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2025 年 3 月 1 日
> - 链接：https://chipsandcheese.com/p/zen-5s-avx-512-frequency-behavior

Zen 5 是 AMD 第一代配备完整 512-bit 执行数据通路的桌面核心：它能在一个周期内完成 512-bit 向量运算，还能从 L1D 发起两次 512-bit Load。AMD 没有像早期 Intel AVX-512 处理器那样公布固定的“AVX 频率档位”，而是让温度、电流和电压变化率等传感器参与自适应控制。

这套控制确实更细腻，但也带来一个容易误读的现象：重载刚开始时，性能可能已经明显下降，频率计数器却仍接近 5.7 GHz。要理解它，必须把“时钟频率”“前端运行速度”和“后端实际接收指令的速度”分开。

![图 1：Zen 5 执行两条 512-bit FMA 时的性能轨迹](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_avx512_wechat_article_zh/acbfbf8b6349f700_01_figure.jpg)

*图 1：两条寄存器操作数 FP32 FMA 已能占满两条 512-bit FMA 管线，但在被测快速 CCD 上几乎没有触发持续降速。*

![图 2：寄存器 FMA 测试的局部放大](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_avx512_wechat_article_zh/ccb9cc86197c22ca_02_figure.jpg)

*图 2：约 1.3 μs 的采样点一度落到相当于 5.3 GHz 的吞吐，下一点又恢复满速；这不足以证明存在固定 AVX 档位。*

## 一、先看参照：Skylake-X 的固定状态切换

作为对照，Core i9-10900X 在标量代码中约为 4.65 GHz；高强度 AVX-512 开始后，先跌到约 3.7 GHz，短暂回到 3.8 GHz，最后稳定在 4.0 GHz。测试观察到约 55 μs 的转换窗口，而其他测试者曾测到约 12～20 μs，说明微基准构造和采样方式会显著影响“切换耗时”。

![图 3：Skylake-X 的标量与 AVX-512 频率变化](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_avx512_wechat_article_zh/f85268a30b6f05c9_03_figure.jpg)

*图 3：Skylake-X 呈现比较清晰的标量档位、切换阶段和 AVX-512 稳态档位。*

![图 4：Skylake-X 转换窗口放大](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_avx512_wechat_article_zh/2de7955c4ae407a7_04_figure.jpg)

*图 4：转换不是瞬间完成；不同测试方法得到的微秒数不能直接混用。*

### 体系结构视角：为什么 AVX-512 会成为供电问题

512-bit FMA、向量寄存器文件和宽 Load 通路会同时翻转大量晶体管。若硬件不先留下电流余量，电压下陷可能破坏时序。固定档位易于验证，却会让大量并不危险的向量代码也付出降频代价；传感器驱动的控制可以按核心、按负载强度调节，但控制环路本身需要时间观察、限流和恢复。

## 二、Zen 5 的异常阶段出现在“加上内存操作数”以后

仅用寄存器的两条 FMA 没有带来明显问题。把两条 FMA 都改成 512-bit 内存操作数，再混入标量加法后，理论吞吐为每周期三条指令。被测 Ryzen 9 9900X 的快速 CCD 却出现约 12 ms 的低吞吐阶段，随后才逐步回到约 5.5 GHz 对应的水平。

![图 5：快速 CCD 上的双 FMA 内存操作数测试](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_avx512_wechat_article_zh/6039fb3a741aa21f_05_figure.jpg)

*图 5：表面吞吐一度只相当于约 4.7 GHz，且持续时间远长于 Skylake-X 的微秒级切换。*

![图 6：较慢 CCD 没有出现同样的转换](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_avx512_wechat_article_zh/9c79131d7d9cc293_06_figure.jpg)

*图 6：9900X 的 CCD0 最高约 5.7 GHz，CCD1 最高约 5.4 GHz；后者留出的电气余量更大，没有重现相同慢段。*

![图 7：不同核心的转换差异](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_avx512_wechat_article_zh/b31ef9bfbb0575ae_07_figure.jpg)

*图 7：行为随核心而变，支持传感器和每核控制在起作用，而不是所有核心共用一个固定 AVX 偏移。*

关键证据来自性能计数器。真实时钟只是在转换期缓慢回落，IPC 却先下降，再恢复到预期的 3。换言之，早期用相关加法估算出来的“4.7 GHz”并不全是降频，它还混入了后端节流。

![图 8：硬件频率计数与 IPC 的分离](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_avx512_wechat_article_zh/e480011990da886a_08_figure.jpg)

*图 8：频率仍接近峰值时，IPC 已显著低于理论值；软件看到的工作完成速度不能简单等同于时钟。*

![图 9：短采样中的测量误差](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_avx512_wechat_article_zh/5c0de6f1250606ab_09_figure.png)

*图 9：`perf` 调用开销会给很短的迭代带来约 1%～3% 误差，因此单个尖点不宜过度解释。*

![图 10：节流行为的核心间差异](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_avx512_wechat_article_zh/992caf8ed2a58413_10_figure.jpg)

*图 10：不同核心的 IPC 低谷和恢复过程并不完全一致，再次表明控制粒度细于 CCD 统一固定档位。*

## 三、再占用一条向量管线，慢段更长、稳态更低

加入一条 `vaddps`，让三条 FP/向量管线与两条 512-bit Load 通路同时繁忙后，转换阶段从约 22 ms 延长到约 32 ms，最终频率又低约 150 MHz。负载强度不仅取决于 Load/Store Unit（LSU），还取决于整个向量后端的活动量。

![图 11：加入第三条向量运算后的轨迹](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_avx512_wechat_article_zh/30897bcab8d17967_11_figure.jpg)

![图 12：更重负载下的第二组记录](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_avx512_wechat_article_zh/d9116fc8dfb187a3_12_figure.jpg)

*图 11、12：更高开关活动延长了控制环路的限制阶段，也压低了最终稳态频率。*

![图 13：三管线压力测试的局部放大](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_avx512_wechat_article_zh/1ee3e7c3e910c98d_13_figure.jpg)

*图 13：转换期平均约 2.75 IPC，只达到理论 4 IPC 的 68.75%；双 FMA 测试的 2.5/3 IPC 尚有 83.3%。节流强度会随负载变化。*

### 体系结构视角：这里更像“发射门控”，不是前端整体降速

若核心只是降低 PLL 频率，指令、周期和执行进度应大体按同一比例变化。现在却是 PMU 频率仍高、IPC 先掉，而且前端与重命名看起来仍在运行。更合理的机制是调度器或执行入口暂时限制高功耗操作的发射，给供电控制留出调整时间。AMD 没有公开足够细的调度/执行 PMU 事件，因此这是由现象支持的定位，而不是 RTL 确认。

## 四、恢复很慢，是为了避免在边界上来回抖动

把标量段和重 AVX-512 段快速交替，首次触发后不会每次都重现完整惩罚。原因是核心没有立即回到最高频率，而是先维持一个更保守的状态。延长标量间隔后，转换逐渐重新出现；恢复到峰值需要超过 100 ms，前 50 ms 大约恢复 200 MHz，最后约 100 MHz 又花了 50 ms 以上。

![图 14：快速交替时没有反复触发完整惩罚](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_avx512_wechat_article_zh/69b0dc5289aace9b_14_figure.jpg)

![图 15：频率恢复过程](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_avx512_wechat_article_zh/5174679af471d1e6_15_figure.jpg)

![图 16：延长标量间隔后的软转换](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_avx512_wechat_article_zh/9ce43f5a3c7c64e5_16_figure.jpg)

![图 17：更长间隔重新触发完整阶段](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_avx512_wechat_article_zh/c029bf416c98a274_17_figure.jpg)

![图 18：完全回到峰值需要超过 100 ms](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_avx512_wechat_article_zh/1b39797a9f33afc5_18_figure.jpg)

*图 14～18：恢复路径带有明显迟滞。它牺牲短时间峰值，换取负载反复切换时不必持续经历严重节流。*

![图 19：转换轨迹与电压下陷控制的相似性](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_avx512_wechat_article_zh/a9468bfc0953fe7b_19_figure.jpg)

*图 19：轨迹像供电控制系统逐步收紧再放松余量，但网页没有电压遥测，不能把形状本身当作电压下陷的直接测量。*

## 五、计数器把问题进一步指向后端

FP Non-Scheduling Queue 满的周期在转换期接近实际周期的 10%。前端仍能取指、译码和重命名，但向量操作不能按预期速度进入执行端，队列便积压。由于 Zen 5 未公开能直接观察调度器与各执行端口节流的完整计数器集合，具体门控点仍未确定。

![图 20：FP 非调度队列满周期](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_avx512_wechat_article_zh/4181373252081bb6_20_figure.jpg)

*图 20：队列满与 IPC 低谷同时出现，是“后端入口受限”的旁证；它不能单独区分调度选择、供电门控或执行端口限制。*

![图 21：被测 Ryzen 处理器](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_avx512_wechat_article_zh/bd85ad5fe20f1012_21_figure.jpg)

![图 22：处理器背面触点](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_avx512_wechat_article_zh/5deb1348b5e17d5e_22_figure.jpg)

*图 21、22：结果来自具体 Ryzen 9 9900X 样品，尤其快、慢 CCD 的差异不应直接外推到所有 Zen 5 SKU。*

## 六、应怎样理解 Zen 5 的 AVX-512 行为

Zen 5 的方案比 Skylake-X 的固定 AVX 偏移精细得多。纯寄存器 512-bit FMA 在 5.7 GHz 下可以稳定运行；只有同时压满宽向量和宽 Load 等高活动资源时，快速 CCD 才进入显著节流。即使触发，限制也会按负载与核心条件变化，而非机械地切到一个固定比例。

这组测试留下三点认识：

1. “报告频率”不等于“有效执行速度”。观察 AVX 负载必须同时记录 APERF/MPERF、实际周期、IPC、队列满和完成吞吐。
2. 降频控制是跨层机制。传感器、供电余量、调度器发射和频率恢复共同决定软件表现。
3. 最坏现象来自刻意压满多条 512-bit 管线的合成负载。它证明机制存在，却不能代表一般 AVX-512 应用的平均代价。

总体判断仍然积极：AMD 在完整 512-bit 数据通路上避免了早期 Intel 那种粗粒度、固定档位式惩罚。不过“时钟仍高、有效吞吐先掉”的阶段也提醒我们，现代处理器的频率管理已经不能只用一个 GHz 数字描述。

## 参考资料

- Chester Lam，*Zen 5’s AVX-512 Frequency Behavior*：https://chipsandcheese.com/p/zen-5s-avx-512-frequency-behavior
- AMD，*Software Optimization Guide for AMD Family 1Ah Processors*
