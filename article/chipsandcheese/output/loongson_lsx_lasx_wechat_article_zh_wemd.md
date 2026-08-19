---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "loongson_lsx_lasx_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*Loongson’s LSX and LASX Vector Extensions*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2023 年 2 月 26 日
> - 链接：https://chipsandcheese.com/p/loongsons-lsx-and-lasx-vector-extensions

龙芯从 MIPS 转向 LoongArch：保留大量语义，却使用不兼容编码，并按国产 CPU 目标继续扩展。LSX 像 SSE，提供 128-bit；LASX 像 AVX2，提供 256-bit。两者当时没有完整公开文档，但 Loongnix Toolchain 能生成并反汇编指令，因此可从实验观察 ISA 和 3A5000 实现。这不是完整指令集文档。

## 寄存器别名与指令覆盖

LSX 有 VR0～VR31，LASX 有 XR0～XR31，分别是同一物理架构状态的低 128/256 bit；64-bit FP F0～F31 也与其别名，例如 F1=XR1低64 bit、VR1=低128 bit。

![图 1：F、VR、XR 的别名关系](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/loongson_lsx_lasx_wechat_article_zh/d224bd7d3d8681d6_01_figure.png)

*图 1：与 x86 XMM/YMM 的部分寄存器别名作概念对照，具体高位语义并不相同。*

两套扩展覆盖 FP32/FP64，8/16/32/64-bit Integer，128/256-bit Load/Store，以及 Add、Multiply、Logic、Permute、Min/Max、Abs、Load-and-broadcast（`XVLDREPL`）等。`XVMAXI` 直接把每个元素与 5-bit Two's-complement Immediate 比较，范围只能约 -16～15。还可把指定 Lane 移到内存或 GPR。覆盖看起来不错，但缺少某些明确操作，例如视频编码常用的 Sum of Absolute Differences。

## 固定 32-bit 编码与四操作数 FMA

LoongArch 把 Register Field 移到低位。LSX/LASX 延续 MIPS 的 Non-destructive 语义，Destination 不覆盖 Source，因此 FMA 类似 x86 FMA4，要编码四个 Register。指令仍固定 32 bit，只能让 Opcode 长度随 Operand 数变化。

![图 2：由 Toolchain/Disassembly 猜测的 LSX/LASX 编码](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/loongson_lsx_lasx_wechat_article_zh/3822a094002cf039_02_figure.png)

*图 2：有些 LSX/LASX Opcode 只差一位，像 Vector-length Bit；另一些还用 Opcode 下方字段指定 Data Type，规律并不统一。图是逆向猜测。*

LoongArch 也有 Indexed Load，但不像 x86/Arm 能在一条指令同时表达 Base+Index+Scale，数组寻址可能需要更多指令。

## Partial Register Access：高位不是“保留”，而是未定义

在 3A5000 上，128-bit `VFADD.S`/`VADD.W` 会对整个 256-bit 状态产生效果，表现得像对应 256-bit 指令，即使 Opcode 不同；x86 的 128-bit 操作则通常保留或清零高位，规则明确。

![图 3：128-bit 运算对 XR 高半部的影响](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/loongson_lsx_lasx_wechat_article_zh/b60ca6aed8ed5bc8_03_figure.png)

*图 3：实测表明 LSX 与 LASX Alias 的高位语义不能按 x86 推断。*

Scalar `FLD.S` 按手册只定义低 32 bit；接下来的 32 bit 常来自内存中相邻值，暗示存储路径原生至少按 64-bit 粒度工作。更高位有时为零、垃圾，甚至偶尔像完整 256-bit Load。

![图 4：部分 Load 后回存完整 XR 的结果](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/loongson_lsx_lasx_wechat_article_zh/725fd9b90d5b3e49_04_figure.png)

*图 4：先填 256 bit，再 Partial Access，最后 Store 全宽。把 `FLD.S` 放在 16 KB Page 尾部后，高位可能为零、Cache Line 开头、下页有效地址等，行为明确不可依赖。*

128-bit `VLD` 也常表现成 `XVLD`，跨页时更随机。

![图 5：VLD 对高 128 bit 的未定义影响](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/loongson_lsx_lasx_wechat_article_zh/95a3ba994686e915_05_figure.png)

*图 5：合理的软件规则是任何窄写后都视更高位为 Undefined，不利用观察到的偶然值。*

这种设计可能省掉 Preserve/Merge 逻辑，避免 Sandy Bridge 在 SSE/AVX Saved State 间切换约 70 周期的代价；代价则是软件必须严格遵守高位未定义。

![图 6：3A5000 的初步乱序资源测量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/loongson_lsx_lasx_wechat_article_zh/ca7a044306672849_06_figure.png)

*图 6：混合 Scalar FP 与 Vector 时，Rename Capacity 约少 32 项。尽管 F/VR/XR 是架构别名，核心似乎需要分别保存状态。Sandy Bridge 更严重，Skylake 已消除此类容量损失。*

### 体系结构视角：Partial Register 规则会进入 Rename 设计

若窄写必须保留高位，Rename/Execution 要追踪旧 Mapping 并做 Merge，产生隐式依赖；若高位 Undefined，可分配新 Physical Register、只保证低位，但混用宽度时又可能需要额外状态或转换。验证不能只测结果，还要扫 Scalar/128/256-bit 混合下的 Rename Capacity、Latency、Dependency Breaking 与跨页异常，确保未定义位不会被异常恢复错误地架构化。

## 3A5000 的 256-bit FPU

3A5000 是当时唯一可测 LSX/LASX CPU。它有双 Port、原生 256-bit Execution Unit 与 Register；L1D 每周期两次 256-bit Access，可两 Load，或其中一 Store。不同于 Zen 1，256-bit 指令不拆成两个 128-bit Uop。

![图 7：3A5000 Vector/FP 执行布局](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/loongson_lsx_lasx_wechat_article_zh/5d51ecb42fa7efc2_07_figure.png)

*图 7：来自微基准复原，不是公开 RTL。*

Integer/Logic 可走两 Pipe，简单 Add/Bitwise 一周期；Permute/Integer Multiply 约三四周期。FP 较弱：Add 与 Multiply 各有专用 Pipe，两边共享一个 FMA Unit。FMA 可与 Add 或 Multiply Dual-issue，但 Add+Multiply+FMA 均匀混合仍不到 2 IPC，可能是 Pipe Assignment 或 Shared FMA Contention。

FP 吞吐在程序充分使用 256-bit 时大致匹配 Zen 1，却落后可每周期两条 256-bit FMA 的 Skylake。基础 FP Add/Multiply 延迟为五周期；Zen 1 Add/Multiply 三周期、FMA 五周期。2.5 GHz 又让绝对时间更差。

![图 8：3A5000 与 Zen 1/Skylake Vector 性能](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/loongson_lsx_lasx_wechat_article_zh/881c29b784e4b217_08_figure.jpg)

*图 8：3A5000 的 Integer Vector 一侧相对更好，FP 延迟/吞吐与在途能力弱。*

FPU 使用 Unified 32-entry Scheduler，可 Rename 96 个 Vector Register；加 32 个非投机架构 Register，推测总共 128×256-bit，即 4 KB RF。Zen 1 有 36-entry FP Scheduler，前面还有 64-entry Non-scheduling Queue，可跟踪更多待执行 Uop；其 160 个 Physical Register 只有 128-bit。龙芯只有当程序大量保持 256-bit Live Value 时，RF 位容量优势才明显。

libx264 中 3A5000 没有凭 256-bit 超过只有 128-bit Unit 的 Ampere Altra，更落后 Zen 1；它明显胜过无 AVX/FMA、面向更低功耗的 Goldmont Plus J4125，但这不是同级目标。

## 结语

保留 MIPS 语义、改编码，让龙芯可复用大量 Toolchain 工作，同时摆脱 ISA License 约束。LASX 也说明其目标高于只需 128-bit 的低功耗市场。然而 3A5000 的具体实现并未达到同期 AVX2 桌面 CPU：执行端较窄、FP 延迟高、Scheduler/NSQ 能力弱，2.5 GHz 又放大最终差距。

应把 ISA 与 Microarchitecture 分开：LASX 指令覆盖是否足够，和 3A5000 是否能高吞吐执行，是两件事。本文只通过 Toolchain 与一颗 CPU 抽样，未穷举全部编码和语义。

## 参考资料

- Chester Lam, *Loongson’s LSX and LASX Vector Extensions*, Chips and Cheese, 2023-02-26
- LoongArch Reference Manual；Loongnix LSX/LASX Toolchain
- AMD Zen 1、Intel Sandy Bridge/Skylake 对照资料
