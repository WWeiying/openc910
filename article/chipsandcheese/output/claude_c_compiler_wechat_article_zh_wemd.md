---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "claude_c_compiler_wechat_article_zh"
---

> 英文标题：Embracing AI with Claude's C Compiler<br>
> 撰文：Chester Lam<br>
> 首发：Chips and Cheese，2026 年 4 月 1 日<br>
> 原始链接：https://chipsandcheese.com/p/embracing-ai-with-claudes-c-compiler

先说明文章语境：这是 4 月 1 日发布的技术讽刺文，基于真实编译与性能测试，用夸张口吻讨论 AI 编译器。4 月 2 日的更新称，考虑到“当前日期已经改变”，Chips and Cheese 已撤回改用 Claude C Compiler（CCC）的决定；下面保留原测试与原有幽默。

在这套叙事里，社会已经把全部希望押在 AI 上。依照一条戏仿的“沉没成本定律”，投资会无限增长，直到 AI 无所不能；银行没钱就由政府接力，政府没钱则轮到外星人和神灵。于是，Chips and Cheese 宣布走在革命前沿，采用 Claude 生成的 CCC。

CCC，即 Claude’s C Compiler，被介绍为一个“从零编写、没有依赖、能够编译 Linux 内核”的优化编译器。Anthropic 使用 Claude 大语言模型（LLM）生成整个编译器，人类主要负责提示、维护 coding agent，并建立足够强的测试套件约束其行为。过去的微基准和 benchmark 使用由人类开发的 GCC；把 GCC 与 CCC 对比，正好观察这种软件开发方式目前能产出什么。

## 先编译一个延迟微基准

缓存与内存延迟通常可用连续依赖的数组访问测量：

![图 1：指针追踪式 C 循环，前一次数组读取结果决定下一次下标](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/claude_c_compiler_wechat_article_zh/7f904471b775e470_01_figure.png)

`current = A[current]` 建立严格的数据依赖，乱序核心也无法让多次读取并行；总时间除以迭代次数，就得到单次访问延迟。CCC 与 GCC 生成的汇编差异很大。

![图 2：同一循环在 x86-64 与 AArch64 上由 CCC、GCC 生成的汇编](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/claude_c_compiler_wechat_article_zh/fb04fa8db280ba77_02_figure.png)

GCC 用 indexed addressing 把移位、相加和 load 表达在一条 x86 指令中。CCC 则把访问拆成更多简单指令，看起来更符合文章戏仿的“纯粹 RISC”路线。

![图 3：x86-64、最高优化级别下，CCC 与 GCC 的依赖数据流](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/claude_c_compiler_wechat_article_zh/5d0734e2d056ebe2_03_figure.png)

CCC 走得更远：一条 `current = A[current]` 被展开成九条指令的依赖链。在 x86-64 上，index 在多个寄存器间搬运，还往返 stack；AArch64 虽把 index 留在寄存器中，却同样从 stack 取数组基址，再额外写回 stack 后使用。

![图 4：AArch64、最高优化级别下的依赖数据流](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/claude_c_compiler_wechat_article_zh/e735d583d3c26197_04_figure.png)

这些代码让测得的“数组访问延迟”掺入编译器开销。Zen 5 和 Lion Cove 多出约 2 周期，可能主要来自 shift 加 add 的依赖链；两者很强的 move elimination 与近零延迟 store forwarding 似乎能折叠九指令链中的大部分搬运，宽乱序后端也能吞下多余指令。近期 Arm 核心的 move elimination 较弱，也不能零延迟转发 store，因此多付出约 6—7 周期。

![图 5：不同核心上 GCC 与 CCC 版本测得的一级缓存依赖访问延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/claude_c_compiler_wechat_article_zh/7b618ced62a88f27_05_figure.png)

窄执行引擎的小核心更难吸收 loop overhead 与 `sum += current` 的附加代码，顺序执行核心的损失最大。

![图 6：CCC 为 AArch64 循环计数与汇总语句生成的冗长数据流，甚至包含寄存器自搬运](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/claude_c_compiler_wechat_article_zh/105cf143c24e1a74_06_figure.png)

### 体系结构视角：微基准首先测到的是“程序—编译器—硬件”组合

指针追踪只有在循环控制、地址生成和结果汇总不进入关键依赖链时，才能接近纯 load-to-use latency。CCC 让 stack spill/reload、shift、add 和 move 混入链条，读数自然不再等于缓存本身。验证时应检查最终汇编，用硬件计数器对照 retired instruction、load 数、store-forward stall 和前后端停顿；最好再用手写汇编建立基准。

move elimination 和 store forwarding 本来只是现代乱序核的优化层，不能替代良好代码生成。普通程序很少连续做无意义寄存器搬运或频繁 stack 往返，所以这些机制常只带来小幅收益；当编译器系统性制造这种模式时，它们才被迫成为性能关键路径。

## “挑战类型系统”

文章随后用一段故意违反 C 类型规则的程序测试编译器：把整数赋给结构体，再把结构体当整数相加并传给 `%d`。

![图 7：故意包含多处不兼容类型操作的 C 程序](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/claude_c_compiler_wechat_article_zh/1c8732610cd14999_07_figure.png)

GCC 报告 incompatible types 等错误，拒绝生成二进制；CCC 则在显式补充 include path 后产生可执行文件。原文把这种缺少诊断戏称为“打破旧类型秩序”，实际工程含义恰恰相反：能产出文件不代表保持了语言语义，编译器正确性必须优先于优化质量。

![图 8：GCC 的类型错误信息与 CCC 仍然产出可执行文件的命令行结果](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/claude_c_compiler_wechat_article_zh/64ee9b5d5470c659_08_figure.png)

## SPEC CPU2017：测试平台与结果

CCC 只支持 C，因此测试 SPEC CPU2017 中八个纯 C workload。平台为：

- Nvidia GB10 中的 Arm Cortex-X925；
- Ryzen 7 9800X3D 中的 AMD Zen 5，关闭 boost；
- Core Ultra 9 285K 中的 Intel Lion Cove。

9800X3D 关闭 boost，是因为 CCC 版本运行很久；原文继续用讽刺口吻称应把节省的电力留给 AI。比较对象均为同一 workload 的 GCC 编译版本。

![图 9：八个 C workload 在三种核心上的估算 SPEC CPU2017 分数](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/claude_c_compiler_wechat_article_zh/ccfb58c3bcdff049_09_figure.png)

CCC 编译的 `502.gcc` 在 Cortex-X925 上持续 segmentation fault，虽然 x86-64 偶尔可以跑完。跑完时，它在 Lion Cove 与 Zen 5 上只达到 GCC 版本的 23.6% 和 27.1%。相对最好的是 `505.mcf`，回退仍略低于 35%；八个 workload 平均性能下降超过 70%。

![图 10：CCC 相对 GCC 的性能回退比例](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/claude_c_compiler_wechat_article_zh/07132ed2171c19f8_10_figure.png)

Cortex-X925 受影响最大。GCC 版本下它可与 Zen 5、Lion Cove 竞争；换成 CCC 后，除 `500.perlbench` 因 Zen 5 自身大幅下滑而短暂领先外，几乎全面落后，而且该项仍不及 Lion Cove。

SPEC CPU2017 的 score 是相对参考机的速度比，参考机是 2.1 GHz UltraSPARC IV+ 的 Sun Fire V490。Lion Cove 在 `500.perlbench` 中三者最好，却只有 0.76，仍低于参考机。原文由此故意反推“4-wide 顺序执行的 UltraSPARC IV+ 比 8-wide 巨型乱序核更先进”，用来讽刺把编译器问题归咎于硬件。

![图 11：CCC 与 GCC 版本的平均 IPC](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/claude_c_compiler_wechat_article_zh/4659dabd900e2e7e_11_figure.png)

如果只看 IPC，CCC 甚至显得“很好”：Arrow Lake 运行 CCC 版 `525.x264` 平均达到 6.09 IPC，是图中所有运行的最高值；GCC 最好约 5.5 IPC。这个优势并不普遍，`538.imagick` 仍是 GCC IPC 更高。

![图 12：八个 workload 的退休指令总数；CCC 在部分负载上执行超过十倍指令](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/claude_c_compiler_wechat_article_zh/1bea8c355d91ca26_12_figure.png)

高 IPC 没有转化为高性能，因为 CCC 让每项工作需要执行的指令暴增，有些超过十倍。AArch64 `502.gcc` 没跑完，其指令数还可能被低估。

### 体系结构视角：IPC 不是工作完成速度

性能近似由“完成工作所需指令数 × 每条指令平均周期”共同决定。CCC 可以把简单操作展开成大量彼此较独立的 move、load、store，让宽核每周期退休更多指令；但如果动态指令数增长十倍，即使 IPC 上升，执行时间仍会恶化。比较编译器必须以相同输入的 elapsed time 或 SPEC score 为主，同时报告指令数与正确性，不能把 IPC 当作独立成绩。

## Top-Down：糟糕代码怎样改变瓶颈

硬件性能计数器显示，CCC 没有让 branch count 随总指令数同比增长，因此分支预测的相对重要性下降。三个纯 C 浮点 workload 变得非常 core-bound；在 Zen 5 上，这表示退休常被“不读取内存的指令”阻挡，瓶颈转向核心执行吞吐。五个整数 workload 的 frontend-bound 比例降低，backend 压力增大。更高 IPC 所谓的“核心利用率提升”，本质上是处理更多无用工作。

![图 13：Ryzen 9800X3D 上 CCC 与 GCC 代码的 Top-Down 构成](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/claude_c_compiler_wechat_article_zh/d3d06d98cf4737d2_13_figure.jpg)

`500.perlbench` 是 Zen 5 的特殊坏例：CCC 代码令 op cache hit rate 大跌。Zen 5 主要依赖 6K 项、16 路 op cache 喂满 8-wide rename/allocate；更大代码 footprint 落到每线程 4-wide decoder。一般代码局部性差时还会有其他瓶颈，decoder 限制不一定显眼；但这个 workload 的潜在 IPC 较高，于是 4-wide decode 明显把 Zen 5 拉到 X925 之后，更远落后 Lion Cove。这是作者在微基准之外首次看到 Zen 5 解码组织产生如此明显的影响，其他 workload 的 op cache coverage 仍很高。

![图 14：Zen 5 上 CCC/GCC 版本的 op cache coverage，500.perlbench 差异最大](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/claude_c_compiler_wechat_article_zh/72ef2e208acbb6f9_14_figure.png)

![图 15：Lion Cove 上 CCC 与 GCC 版本的 Top-Down 构成](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/claude_c_compiler_wechat_article_zh/328342c1707dbc74_15_figure.jpg)

Lion Cove 也遭遇类似压力，但整体比 Zen 5 更 backend-bound。可能原因是 Lion Cove 的 uncore 延迟更高，也可能只是 Intel 与 AMD 的计数归类不同，例如 Intel 可能把“任一指令被 load 延迟”的周期更多计入 memory bound。它的 8-wide decoder 在 `500.perlbench` 中表现很好，前端限制远小于 Zen 5。

![图 16：Cortex-X925 上 CCC 与 GCC 版本的 Top-Down 构成](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/claude_c_compiler_wechat_article_zh/739bd13c863831a0_16_figure.jpg)

X925 运行 CCC 代码时高度 core-bound，而且不只发生在三个浮点 workload。这里用 `STALL_BACKEND_MEMBOUND` 占 backend stall 周期的比例区分 core bound 与 memory bound；该事件表示后端停顿且通向内存的接口忙或被阻塞。

一个原因是 X925 没有 Lion Cove、Zen 5 那样强的 move elimination 与零延迟 store forwarding。普通软件里长 MOV 链和频繁 stack 往返很少见，例如 Ice Lake 禁用 move elimination 通常只损失 1%—3%，它原本只是锦上添花；CCC 却把这种能力变成决定性因素。

![图 17：CCC 版 519.lbm 的热点汇编，反复把 x0 写入 stack，数条指令后又加载回来](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/claude_c_compiler_wechat_article_zh/6983d211ed37db78_17_figure.jpg)

`519.lbm` 的 backend memory-bound 明显上升，与 store forwarding latency 有关。热点路径重复 spill `x0` 再 reload，把转发延迟放进长依赖链；X925 无法像 Zen 5 与 Lion Cove 那样以近零延迟完成。

## 收尾：一份用性能数据写成的讽刺文

编译器让高级语言可用，正确性与生成代码性能都至关重要。CCC 让八个纯 C SPEC CPU2017 workload 平均慢 70% 以上。原文继续反讽称消费者会接受这种下降，因为现代 Lion Cove 即使跑 CCC 代码仍“足够快”；并拿约 15 年前的 AMD Bulldozer 作对比。

![图 18：CCC 版 Lion Cove 与 GCC 版 AMD FX-8150 的估算 SPEC 分数对比](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/claude_c_compiler_wechat_article_zh/f19cda99c65d52ce_18_figure.png)

按图中汇总，GCC 编译代码下的 Bulldozer 比 CCC 代码下最快的 Lion Cove 高 36.8%。文章戏称把 Lion Cove 超频到 8 GHz 就能弥补大部分差距，并调侃有人只能达到 7.5 GHz 是“不够拥抱 AI”。

最后的逻辑故意荒诞：既然不能批评 AI 软件，就只能让硬件承担差距；用 20—30 GHz 和数代架构改进，或许能让 CCC 程序追上今天 GCC 程序，至于功耗则交给“无限能源”。脚注中的“沉没成本证明”同样是笑话——类似“99% 的赌徒都在中奖前放弃”。

玩笑背后的技术结论很直接：硬件和软件确实共同决定性能，但宽执行、乱序窗口、move elimination 和 store forwarding 不应被当成糟糕代码生成的无限缓冲。好的编译器减少动态工作量，并在不同核心上稳定运行；好的硬件则在合理软件分布下提供性能。两者之间的契约被破坏时，再强的核心也只能更快地做无用功。
