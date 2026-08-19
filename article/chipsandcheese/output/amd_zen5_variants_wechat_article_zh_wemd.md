---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "amd_zen5_variants_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*Zen 5 Variants and More, Clock for Clock*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2024 年 8 月 20 日
> - 链接：https://chipsandcheese.com/p/zen-5-variants-and-more-clock-for-clock

Zen 5 上市时已经出现桌面、移动、Zen 5c、不同 Cache 和不同 AVX-512 宽度的多个版本。为了尽量拿掉频率差异，这组测试把一批跨越多代的 AMD、Intel 核心统一限制在 3 GHz，再观察视频编码、文件压缩和 Linux 内核编译。

这不是现实产品排名：各架构本来就围绕不同目标频率设计，而且 `cpupower frequency-set --max 3000mhz` 也不能保证每颗 CPU 精确运行在 3 GHz。它更像一个受控实验，用来观察当“每纳秒内的 DRAM 延迟”被换算成更少周期后，前端、分支预测和乱序窗口还会被什么限制。

![图 1：参与测试的处理器之一](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_variants_wechat_article_zh/8eb6526301935b4e_01_figure.jpg)

![图 2：把上限继续降到 3.5、1 GHz 对 Redwood Cove IPC 的影响](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_variants_wechat_article_zh/11592fb7db68b4cd_02_figure.png)

*图 2：Meteor Lake 的 Redwood Cove 由高延迟 LPDDR5 供给，最大频率从 4 GHz 降到 1 GHz 时 IPC 增加 25.8%；不是核心变强，而是同一内存延迟折算成更少周期。4 GHz 点还可能受温度限制。*

## 一、测试口径：频率锁定并不完美

测试固定四个逻辑核；支持 SMT 或 CMT 的处理器只用每个物理核心的一条线程。Bulldozer 的相邻 P-State 为 2.7 和 3.3 GHz，系统实际选到 2.7 GHz；Zen 2 也出现偏离。后续 IPC 图中，Zen 2 的周期与耗时反推频率约为 2.8 GHz。

![图 3：各平台与实际频率配置](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_variants_wechat_article_zh/46b88a6c1d0bde4b_03_figure.jpg)

*图 3：结论应读作“尽量消除频率后的趋势”，而非严格相同 3.000 GHz 的实验室对比。*

测试包括 libx264、7-Zip 24.08 压缩 2.67 GB 文件，以及 Linux `5189dafa4cf950e675f02ee04b577dfbbad0d9b1`、`tinyconfig`、16 并行任务的编译。编译结果对环境很敏感：另一套 Debian chroot 在方法近似时只执行 0.69 万亿条指令，而本机约 0.75～0.77 万亿，因此文章不把编译完成时间列入正式性能图，只分析 IPC 与计数器。

## 二、3 GHz 下的完成时间：不同负载讲不同故事

libx264 中，桌面 Zen 5 比同类 Zen 4 快 20.8%；给 Zen 4 加 96 MB V-Cache 后，差距仍有 16.6%。移动 Zen 5 因较弱 AVX-512、更小 Cache 与更高内存延迟，只能大致追平桌面 Zen 4。Crestmont E-Core 未进入 Zen 2 或 Skylake 档位；Bulldozer 较大的 FP/向量单元则压过更老的 Husky。

![图 4：3 GHz 上限下的 libx264 性能](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_variants_wechat_article_zh/f0ed88bc0b37fc6b_04_figure.png)

7-Zip 手工设为 16 线程。频率拉齐后，桌面 Zen 5 落在普通 Zen 4 与 V-Cache Zen 4 之间；移动 Zen 5 明显落后，显示该负载对 Cache 容量和内存延迟敏感。Redwood Cove 与 Zen 5c 接近，Skylake 与 Zen 2 接近，老 Husky 甚至略过 Bulldozer。

![图 5：3 GHz 上限下的 7-Zip 压缩](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_variants_wechat_article_zh/70be55d2d193931f_05_figure.png)

### 体系结构视角：性能/周期不等于 IPC

IPC 是退休指令数除以周期数。若两个平台为了完成同一任务执行的指令数不同，高 IPC 反而可能对应更慢的完成时间。ISA 扩展、编译器代码路径和融合规则都会改变指令数；只有工作量与指令数足够接近时，IPC 才能近似“每周期性能”。

## 三、libx264：AVX-512 让指令数先变少

libx264 在 Zen 5 上平均超过 2 IPC。Redwood Cove 的 IPC 与移动 Zen 5、Zen 4 相近，但执行指令数并不相同。Zen 4/5 走 AVX-512 路径，Skylake、Zen 2、Meteor Lake 走 AVX2，Bulldozer 使用 AVX/XOP/FMA4，Husky 主要使用 SSE，形成数个明显的指令数档位。

![图 6：libx264 IPC](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_variants_wechat_article_zh/7123049bf52847b7_06_figure.png)

![图 7：AMD 各代 ISA 扩展支持](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_variants_wechat_article_zh/3cd089fcd86f3ffe_07_figure.png)

![图 8：libx264 退休指令数](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_variants_wechat_article_zh/13f22eda03dcd6b5_08_figure.png)

*图 6～8：桌面 Zen 5 同时有更高 IPC 和更少指令；Redwood Cove 的高 IPC 则不能脱离 AVX2 路径的额外指令解释。*

7-Zip 各平台都执行约 1.69 万亿条指令，此时 IPC 与每周期性能更接近。它本身 IPC 较低，Redwood Cove 相对 Skylake 的优势很小，说明更宽、更深的乱序核心没有得到有利的指令级并行性。

![图 9：7-Zip IPC](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_variants_wechat_article_zh/b4cfbf98d5521c23_09_figure.png)

内核编译的指令数也较接近，约 0.75～0.77 万亿，因此更能看出新核心的每周期优势：Zen 5 超过 Zen 4，Redwood Cove 超过 Skylake，Crestmont 大致达到 Skylake；Bulldozer 仍落后 Husky。

![图 10：Linux 内核编译 IPC](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_variants_wechat_article_zh/4d3dfa6fdfb84c19_10_figure.png)

## 四、分支预测决定乱序窗口能不能发挥

libx264 的分支不算特别多，新核心准确率接近；FX-8150 与 Athlon II X4 651 明显落后。按每千条指令误预测数（MPKI）归一后，Zen 2 与 Redwood Cove 还因执行更多计算指令而显得更低。

![图 11：libx264 分支预测表现](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_variants_wechat_article_zh/617799efa1493ed6_11_figure.png)

7-Zip 更苛刻：新 AMD/Intel 核心准确率仍超过 95%，Zen 5 约 96%，但超过 22% 的指令都是分支。于是 Zen 5 仍有 8.9 MPKI，Zen 4 为 9.3 MPKI。频繁清空流水线会浪费更大的乱序窗口，Zen 5 难以充分利用新增重排序资源，V-Cache Zen 4 反而凭内存系统取胜。

![图 12：7-Zip 分支准确率与 MPKI](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_variants_wechat_article_zh/3fc37e2d4cc48b74_12_figure.png)

Redwood Cove 相比 Skylake 将每指令误预测降低约 17.6%，但误预测的绝对频率仍足以限制其大后端。内核编译约 21.7% 指令是分支，不过模式更容易预测：Zen 5 相比 Bulldozer 将每指令误预测降低 60.2%，而在 7-Zip 中只降低 33.38%。

![图 13：内核编译的分支预测](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_variants_wechat_article_zh/98d732d0e4e0c9b2_13_figure.png)

更准确的预测器还能沿预测路径提前取指，隐藏 L1I、L2 甚至 L3 延迟。内核编译的指令工作集很大；Bulldozer 的 64 KB L1I 相比 Zen 4 的 32 KB 将 L1I MPKI 降低 16.3%，但仍有 27.82 MPKI，单靠容量远远不够。

![图 14：内核编译的指令 Cache 未命中](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_variants_wechat_article_zh/f1b6da17e5aca662_14_figure.png)

### 体系结构视角：预测器还是一台“指令预取器”

现代解耦前端会让分支预测先于真实取指推进。方向与目标正确时，它相当于给 L1I/L2 发出长距离预取；预测错时，不仅错误路径微操作要清空，预取带宽和 MSHR 也被浪费。因此大代码工作集下，预测准确率、BTB 覆盖和指令 Cache 容量不能分开评价。

## 五、流水线槽位去了哪里

不同架构的 Top-down/停顿事件定义并不完全可比，以下只看趋势。libx264 主要后端受限；Zen 2 的 5-wide 管线、低延迟 DDR4 与快速 L3 使“可损失槽位”较少。Zen 5 更宽，因此绝对丢失槽位更多，但依靠更大乱序窗口和更好前端仍是性能第一。

![图 15：各架构计数器口径示意](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_variants_wechat_article_zh/7ae23b45fcd2c73b_15_figure.jpg)

![图 16：libx264 的前端/后端限制](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_variants_wechat_article_zh/74bb5d603f6998da_16_figure.png)

V-Cache 主要减少数据侧等待；移动 Zen 5 则受较弱 FP/向量单元和 LPDDR5 影响。7-Zip 同时受前后端限制。它几乎完全装进微操作缓存：Skylake 1.5K 项 Op Cache 仍供给 93.5%，Zen 4 的 6.75K 项供给 99.5%，但分支过密会让每个 Fetch Group 在早期 Taken 后留下空槽，缓存命中也救不了有效带宽。

![图 17：7-Zip 的流水线限制](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_variants_wechat_article_zh/260d49dfed57d066_17_figure.png)

内核编译则明显前端受限。降低频率能减少后端以周期计的内存等待，却不能消除分支与指令 Cache 问题。Zen 5 仍然是图中最快的核心，只是 8-wide 后端让“未被喂满的潜在槽位”看起来更多。

![图 18：内核编译的流水线限制](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_variants_wechat_article_zh/a45a47ffe96dc94b_18_figure.png)

## 六、真正跨越十代的限制没有改变

![图 19：另一颗参与测试的处理器](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_variants_wechat_article_zh/8296be54bacf672b_19_figure.jpg)

当代码分支密集，前端预测与取指限制性能；分支较少时，数据局部性和内存延迟又会接管。Athlon II X4 651 用 2 MB 大页随机访问 1 GB 数组约为 76 ns，Ryzen AI 9 HX 370 却超过 128 ns。现代核心拥有更大 Cache 和更深乱序窗口，片外纳秒延迟却没有同步改善。

![图 20：DDR3 内存条](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/amd_zen5_variants_wechat_article_zh/258526f0235074ed_20_figure.jpg)

*图 20：从 DDR3 到 LPDDR5，带宽进步巨大，随机访问延迟并没有按核心吞吐的速度缩短。*

这组 3 GHz 实验不回答“哪颗 CPU 最值得买”，却清楚展示三条设计规律：

1. 降频会减少内存延迟对应的周期数，却不会消灭延迟本身。
2. 宽核心只有在预测正确、工作集靠近核心并存在足够并行性时才能兑现宽度。
3. Cache、分支预测和乱序资源必须一起扩展；任何一项落后，都可能让新增执行端口闲置。

## 参考资料

- Chester Lam，*Zen 5 Variants and More, Clock for Clock*：https://chipsandcheese.com/p/zen-5-variants-and-more-clock-for-clock
- Jim Keller 与 Ian Cutress 的 AnandTech 访谈
