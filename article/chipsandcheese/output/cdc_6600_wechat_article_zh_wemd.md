---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "cdc_6600_wechat_article_zh"
---

> 英文标题：Inside Control Data Corporation’s CDC 6600<br>
> 撰文：Chester Lam<br>
> 首发：Chips and Cheese，2024 年 4 月 1 日<br>
> 原始链接：https://chipsandcheese.com/p/inside-control-data-corporations-cdc-6600

这篇文章发表于 4 月 1 日，故意站在 CDC 6600 所属年代，用“当代新品评测”的语气介绍它，并穿插今天看来明显荒诞的判断。玩笑之外，60-bit 数据通路、scoreboard、十个功能单元、磁芯存储与独立 I/O 处理器等结构参数，来自 CDC 手册与历史资料。

当银行、航空公司和大型企业面对越来越多的数据，Control Data Corporation（CDC）用 CDC 6600 追求比 IBM、DEC 更强的计算能力。它没有现代乱序核的寄存器重命名与推测执行，却已经使用并行、非阻塞功能单元，高性能 Central Memory，以及独立 I/O processor 来减少中央处理器负担。

## 整体结构

CDC 6600 的 Central Processor 是 60-bit scalar、in-order 架构，拥有非阻塞执行单元与 18-bit 地址。它可直接访问最多 960 KB Central Memory；可选的 Extended Core Storage（ECS）为超大存储需求提供超过 14 MB 容量。

![图 1：CDC 6600 中央处理器、寄存器、功能单元、Central Memory 与 ECS 的高层结构](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cdc_6600_wechat_article_zh/dd7429eb5dce3d1f_01_figure.png)

Central Processor 与 Central Memory 都运行在当时很高的 10 MHz。CPU 与内存同频，使系统无需多级 cache，整个 Central Memory 地址空间都能提供相对一致的访问时间。

## 前端：没有分支预测

CDC 6600 不做 branch prediction。

指令从 Central Memory 取到一个可容纳 8 个 60-bit word 的 instruction queue，这个队列也能充当 loop buffer。为节约内存带宽，只有分支跳出队列范围，或队列即将耗尽时，才启动下一次取指。Central Memory 取指延迟为 8 周期；若分支目标已在队列中，分支约 9 周期，必须重新从内存取目标则约 15 周期。

![图 2：CDC 参考手册中的 RNI（Read Next Instruction）时序](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cdc_6600_wechat_article_zh/6bd6faa434009b46_02_figure.png)

指令与数据共享无 cache 的 Central Memory，因此 self-modifying code 不需要失效和重填 cache，只需保证修改位置至少领先当前执行指令 8 个 60-bit word。

指令集不到 100 条，所有指令由硬件直接执行。原文把这描述为“不需要 decoder”；更准确地说，它无需现代复杂指令集那种庞大的变长解码和微码翻译，但仍需要控制逻辑识别 opcode 并驱动功能单元。

### 体系结构视角：loop buffer 是早期前端的局部性优化

8-word instruction queue 同时减少取指流量和短循环的内存等待，作用与现代 loop cache、uop cache 的一部分目标相似。差别在于它不预测未来控制流：遇到不在队列中的 target，只能付出 15 周期重取。现代前端用 BTB、方向预测和投机队列把这段时间藏在正确预测之后，但一旦错预测就要清空错误路径；CDC 6600 直接等待，结构简单、代价确定。

## 顺序发射与 scoreboard

指令进入队列后，reservation control section 按程序顺序处理，并确认所需资源。其中的 scoreboard 记录哪个功能单元忙、哪个寄存器正等待在途指令写回。依赖满足后，指令才可进入执行；寄存器按架构编号直接寻址，没有 register renaming。

![图 3：scoreboard 检查功能单元占用与寄存器 RAW 依赖](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cdc_6600_wechat_article_zh/bf514a870d77860d_03_figure.png)

没有重命名意味着还必须处理 WAR（write-after-read）hazard：每次写回都要检查是否有较早指令尚未读取同一个寄存器。

发射后的指令从 register file 读取操作数。为减少布线，一些功能单元共享输入与结果总线。体系共有 24 个寄存器：

- `X0`—`X7` 是八个 60-bit operand register，用于高精度计算，并非完全通用；Central Memory load 只能写入 `X0`—`X5`，store 只能从 `X6` 或 `X7` 取数据；
- `A0`—`A7` 是八个 18-bit address register；
- `B0`—`B7` 是八个 18-bit increment register。

地址与增量寄存器只做成 18 bit，以节约昂贵的逻辑资源。

![图 4：register file 与十个功能单元间的数据连接](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cdc_6600_wechat_article_zh/4097f520130de7ac_04_figure.png)

十个独立 functional unit 理论上可以同时工作，但它们没有流水化，且多为多周期。程序需要混合不同类型指令，避免集中占用某个单元。

![图 5：CDC 6400/6600/6800 各类指令在不同功能单元上的周期数](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cdc_6600_wechat_article_zh/aef4a0015c023b5f_05_figure.png)

increment unit 与 floating-point multiply unit 各有两套，因此前一条乘法未完成时，下一条仍可在另一单元启动。理想地混合浮点乘加时，CDC 6600 可达 4.5 MFLOPS；不过浮点乘法延迟高达 10 周期，软件很难持续制造完美组合。

![图 6：培训手册中的指令时序与冲突图；“third order conflict”指 WAR hazard](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cdc_6600_wechat_article_zh/2eaa200246ee67e8_06_figure.png)

### 体系结构视角：scoreboarding 已经在利用指令级并行

CDC 6600 的指令按序进入功能单元控制，却允许不同的长延迟功能单元重叠工作。scoreboard 集中跟踪 RAW、WAR 与结构冲突，是动态调度的重要祖先。没有重命名时，假依赖会延迟写回；没有 ROB 时，也无法像现代核心一样保存大量投机结果并精确提交。

非流水化执行单元的 latency 也等于再次接收同类操作的间隔，复制 FP multiply unit 是以面积换吞吐。现代核心通常把 latency 与 reciprocal throughput 分开：流水化乘法器可以每周期接收新操作，再由 scheduler、rename 和 ROB 保持大量在途指令。

## 内存保护：基址与长度

程序把值写入 address register，再执行相应 Increment 指令启动内存访问。为了支持多任务，CDC 6600 必须阻止不同程序破坏彼此数据。

![图 7：RA 与 FL 定义的程序内存区间](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cdc_6600_wechat_article_zh/30bc4eee56332fc3_07_figure.png)

系统不用 paging 或 virtual memory，而采用简洁的 segmentation。每个程序有 Reference Address（RA）作为段基址，Field Length（FL）以 60-bit word 表示可用长度。访问越过 `RA` 到 `RA+FL` 的范围会 halt。系统也不提供现代操作系统可恢复的 precise exception；原文把这种限制戏称为程序员应如实申请存储并“提高水平”。

## Central Memory：用多 bank 换带宽

Central Memory 最多 960 KB，即 131,072 个 60-bit word。它按 4096 word 一 bank 划分，由地址低位选择；满配共有 32 bank。程序使用八个 18-bit address register 访问，但容量实际只需 17 位，最高一位没有使用。

![图 8：Central Memory 的理论读取带宽：10 MHz 下每周期一个 60-bit word，即 75 MB/s](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cdc_6600_wechat_article_zh/a9907b1a123c8ebb_08_figure.png)

每个 bank 独立工作，理想情况下中央处理器每周期读一个 60-bit word。达到 75 MB/s 要求软件避开 bank conflict，因为单 bank 服务一次请求需要多个周期，Central Memory 的仲裁逻辑“hopper”必须处理冲突。

![图 9：最佳情况下磁芯内存约 300 ns，与现代 GDDR6 实测延迟的数量级对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cdc_6600_wechat_article_zh/d5cfac60f9af0893_09_figure.png)

hopper 没有花逻辑把新地址与所有在途请求逐项比较，而是直接发出地址；若目标 bank 在 175 ns 内不接收，就认为发生冲突，访问进入 300 ns replay loop，直到成功。无冲突 load 也要 300 ns，即 3 个 10 MHz 周期。

![图 10：CDC 6600 Central Memory 子系统与 bank/hopper 连接](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cdc_6600_wechat_article_zh/d5be95d935958557_10_figure.png)

这种设计把复杂度从关联比较转成重试与软件布局。顺序跨 bank 的访问可获得高吞吐，集中打到同一 bank 的模式则会反复 replay。现代内存控制器会用请求队列、bank 状态和调度策略主动重排，代价是更多状态与更难预测的访问延迟。

## Extended Core Storage：14 MB 的大容量层

ECS 最多容纳 200 万个 60-bit word，超过 14 MB，同样使用 magnetic core storage，也能达到每 10 MHz 周期一个 60-bit word 的峰值吞吐。但容量要求它采用不同组织。

![图 11：ECS 参考手册中的机柜与系统说明](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cdc_6600_wechat_article_zh/0edfb074a85c5e79_11_figure.jpg)

Central Memory 可按 word 寻址，ECS 则以 488-bit（61-byte）line 存储。ECS 自身时钟只有 312.5 kHz，靠多 bank 并行取得带宽。每 bank 有 125,952 个 60-bit word，约 944.6 KB；至少四个 bank 才能维持 10 MHz 每周期一个 word。18-bit address register 无法直接覆盖 ECS，相关指令用 60-bit `X0` 给出相对该程序 ECS segment base 的地址。

一个 3200 ns ECS 周期内可以同时完成一次读和一次写：读占 800 ns，随后写占 1600 ns。可靠性方面，ECS 另有 5K word（38.4 KB）reserve memory；局部失效后，用户可通过交换两根线，以 1K word 为单位启用备用区。存储还带 parity 保护。

## 物理实现

CDC 6600 极力节省逻辑和磁芯资源，整台机器最终只占一个房间——这是原文刻意使用的“个人电脑式”玩笑。

![图 12：CDC 6600 的十字形机柜平面布局，每个机翼末端有制冷单元](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cdc_6600_wechat_article_zh/ac7eef6b107b135b_12_figure.png)

四个机翼末端各有 refrigeration unit 处理冷却。

## 结语

CDC 6600 用与硬件紧密对应的简单指令、scoreboard、多个独立功能单元、分 bank 磁芯内存和取指队列，尽可能榨取当时有限的逻辑资源。它不做控制流猜测与恢复，原文便戏称它“完全免疫推测执行漏洞”；这只是幽默表达，并不等于系统没有其他安全或可靠性问题。

![图 13：CDC 当年的宣传广告](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/cdc_6600_wechat_article_zh/7f864502b8b893d4_13_figure.jpg)

文章最后继续站在历史视角断言：如此强大的机器，世界可能同时只需要不到十台；也永远不会需要 5 GHz 以上、巨型乱序执行的处理器——然后以“现在是哪一年？”收尾。

真正经得起时间的部分，是它对资源的精准分配。现代 CPU 的 BTB、rename、ROB、cache 与投机恢复把性能推得更高，却都以状态、验证成本和功耗为代价。CDC 6600 展示了另一端：在器件极其昂贵的时代，用可见的软件约束和 bank/功能单元并行，换取当时惊人的吞吐。
