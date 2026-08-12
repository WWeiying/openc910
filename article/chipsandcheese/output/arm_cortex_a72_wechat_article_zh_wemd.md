---
theme: custom-1786280678341-jnfpaqasm
themeName: "学术论文 (副本)"
title: "arm_cortex_a72_wechat_article_zh"
---

> **文章来源**
>
> - 文章：*ARM’s Cortex A72: aarch64 for the Masses*
> - 撰文：Chester Lam
> - 首发：Chips and Cheese
> - 发布：2023 年 11 月 10 日
> - 链接：https://chipsandcheese.com/p/arms-cortex-a72-aarch64-for-the-masses

Cortex-A72 是 Arm 在 2016 年推出的三宽、投机、乱序执行核心。它的黄金时代里，Snapdragon 650、Kirin 950、Helio X20 分别进入 Oppo R11 与 Sony Xperia X、Huawei Mate 8、Lenovo K8 Note 与 Chuwi Hi9 Pro 等设备。

后继核心已经更新数代，A72 却没有很快消失。2022 年前后，Raspberry Pi 4 让它成为爱好者最容易获得的乱序 Arm 核心之一；Rock Pi 4 的 RK3399 使用两颗 A72 加四颗 A53，MNT Reform 的 Layerscape LS1028A 模块、AWS 第一代 Graviton 和 Pensando 网络处理器也采用了它。A72 的意义不只是某代手机大核，而是让 64-bit AArch64 乱序核心进入了大量低成本设备。

测试选择 AWS Graviton 1 的 Cortex-A72，因为实例价格低、容易获得；同期对照是 Snapdragon 821 的 Qualcomm Kryo。两者发布时间接近，频率也相近：Kryo 最高 2.34 GHz，Graviton 1 的 A72 为 2.3 GHz。

网页没有披露 AWS 实例的 OS/Kernel、编译器与 Flags、频率控制、预热、重复次数和统计误差；手机微基准还明确出现较大噪声。因此比较适合观察结构趋势，不适合把所有差距外推为 AArch64 与 x86，或 Arm 与 Qualcomm 的普遍性能结论。

## 核心总览：三宽乱序，目标是“小而能干”

从基本吞吐看，A72 与 Pentium III 有表面相似之处：都是三宽、两条 ALU、两条 AGU、64-bit FPU。A72 的重排序容量、分支预测和 Cache 都强得多，实际性能自然不在同一时代。相较四宽 Kryo，A72 的乱序容量接近，但理论执行吞吐更低；核心宽度和单元数量并不会自动转换成应用性能，预测与存储层级往往更重要。

![图 1：Cortex-A72 核心总览](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/08ceb06873d39c3e_01_cortex_a72_overview.png)

*图 1：三宽 Decode/Rename/Dispatch、128 项 ROB、分布式整数与 FP Scheduler、Load/Store 单元、48 KB L1I、32 KB L1D 和共享 L2。图是网页给出的粗略结构整理，L2 等参数由具体实现决定；Raspberry Pi 4 并不具备 Graviton 1 那样的 2 MB 集群 L2。*

### 体系结构视角：宽度只是性能方程中的一项

三宽限制每周期进入后端的峰值，但真实 IPC 还受分支供给、依赖链、Scheduler 可用项、Cache miss 和端口可达性限制。四宽核心若经常等待 L2，也可能输给三宽但局部性更好的设计。

可把 `frontend_bound`、`bad_speculation`、各 Scheduler/ROB/LSQ Full、执行端口利用率与各级 miss 同时观察。只有 Rename 长期打满且后端仍有余量时，“多一宽”才可能直接兑现。

## 分支预测：方向不错，目标速度偏慢

分支预测既影响性能，也影响错误路径能耗。预测器必须在旧分支尚未执行完时提供下一地址，而且还要足够快，不让 Fetch 等待。

### 方向预测

![图 2：Cortex-A72 的重复模式识别](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/9a0c012ae69e2b97_02_a72_branch_pattern.png)

*图 2：同时改变 Pattern Length、Taken 数和静态分支足迹。A72 对较长重复模式的识别在同代低功耗核中尚可，低平台后的台阶混入历史长度、容量和混叠。*

![图 3：Snapdragon 821 Kryo 的重复模式识别](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/c34bce451c2ca0e7_03_kryo_branch_pattern.jpg)

*图 3：同类测试下，Kryo 在较长 Pattern 上更早出现不稳定区域；A72 似乎有略多的历史存储，静态分支很多时也稍晚受混叠影响。*

![图 4：Neoverse N1 的重复模式识别](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/b7aa346b3fab0893_04_n1_branch_pattern.png)

*图 4：N1 能识别更长历史，也能容纳更多分支，显示 Arm 后继服务器核心已显著扩大预测能力。N1 在 Oracle Cloud 可达 3 GHz，按时间计算的误预测惩罚也更低；频率差必须保留。*

### 间接分支

A72 的间接预测器能以较低代价处理最多约 256 个目标，例如 128 个分支、每分支两个目标；单个间接分支至少可跟踪 16 个目标。

![图 5：A72 的间接分支容量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/1569013dc58a9707_05_a72_indirect_targets.jpg)

*图 5：横轴改变目标数，另一维改变分支数。约 256 个总目标以内存在较稳定区域，但“128×2”和“单分支 16 目标”是不同测试切片，不能相乘成物理表容量。*

它还有一个反常现象：分支不超过四个、每分支目标也不超过四个时，反而容易误预测。

![图 6：少量分支和目标下的异常区域](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/2c9278bf8430254f_06_a72_indirect_short_pattern.jpg)

*图 6：小规模组合出现本不该有的高代价，说明“表越空越准”并不总成立；局部目标序列与选择机制可能不匹配。*

若让目标选择与附近直接分支的 Taken/Not Taken 结果相关，问题会缓解，说明 A72 会使用全局方向历史；它又能处理单分支最多 16 个目标，说明也利用了局部目标历史。奇怪之处在于，它对很短的局部目标模式反而用得不好。

![图 7：加入附近直接分支相关性后的间接预测](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/aecfbb84f273d2e5_07_a72_indirect_correlated_history.jpg)

*图 7：目标序列与附近方向历史建立相关后，小规模异常明显收敛。这是对输入特征的行为观察，不足以确定具体间接预测算法。*

### Return 与 RAS

Call/Return 是容易利用栈关系预测的间接分支。Paul Drongowski 曾估计 A72 的返回地址栈（RAS）为 8 项；测试曲线却支持约 31 项，两种说法并不一致，应并列保留。

![图 8：正确 Call/Return 对的基本代价](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/ac8fde3df54abb87_08_call_return_latency.jpg)

*图 8：正确预测的一对 Call + Return 约 4 周期，平均每条分支约 2 周期。*

![图 9：A72 的返回栈深度](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/faa7a743b64a95d9_09_return_stack_depth.png)

*图 9：曲线到调用深度约 31 后才出现明显转折，因此文章倾向于 31 项；Kryo 和 Haswell 的 RAS 都约 16 项。该拐点反推仍不是 RTL 确认。*

### BTB 容量与延迟

分支目标缓冲区（Branch Target Buffer，BTB）让预测器在取到分支指令字节前先给出目标。A72 的测试结果比较怪。Drongowski 的解释是 BTB 可拆分条目：远分支占较大目标字段，最多约 2K 项；近分支压缩目标后最多约 4K 项。

![图 10：Graviton 1 的 A72 BTB 容量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/cd56776e7eca0caf_10_btb_capacity.jpg)

*图 10：曲线改变 Branch Spacing。每 8 B 一条分支时最多接近 4096；分支更远时容量与 L1I 可容纳的代码量高度相关。低分支数处因 AArch64 编码限制，循环尾使用间接分支，异常高值应忽略。*

文章并不完全接受“近/远双容量”解释。4096 个密集近分支很像一张 Near BTB；所谓 Far BTB 的容量却与代码 Cache 完全相关，也可能只是 L1I miss 延迟。无论哪种解释，A72 都无法让预测器驱动指令预取，因此 I-Cache miss 很昂贵。

速度同样不突出。64 项“Micro BTB”仍会在 Taken 分支后留下前端 Bubble，对应约 2 周期；主 BTB 约 3 周期，完全没有 Zero-bubble Branch。循环展开能减少 Taken 频率，却会扩大代码足迹，展开过度又会制造 L1I miss。

![图 11：Snapdragon 821 Kryo 的 BTB 层级](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/d018e404e148910d_11_kryo_btb_latency.png)

*图 11：Kryo 的 8 项 L0 BTB 可无气泡处理；约 8 KB 代码范围内约每 2 周期一条 Taken，32 KB L1I 内再增加约 1～2 周期。它总分支容量略小，却在许多常见足迹下比 A72 更快。*

### 体系结构视角：循环展开同时优化分支密度并伤害 I-Cache

循环展开减少动态分支数，能缓解 A72 的 2～3 周期 Taken Bubble；但指令体变大后，48 KB L1I 和有限 Fill Buffer 会承受更多压力。最优展开因循环体、分支位置和 L1I 冲突而不同，不能只按“越少分支越好”处理。

验证时应同时记录每千条指令分支数、Taken Bubble、L1I/ITLB miss 和代码工作集。若展开后分支停顿下降、L1I miss 上升，性能峰值往往出现在两者交叉点附近。

## Fetch 与 Decode：48 KB L1I 之后迅速失速

A72 先用 48 项全相联 iTLB 翻译取指地址，再查 48 KB、三路组相联 L1I。L1I 通过 128-bit 总线每周期送 16 B，也就是最多四条 AArch64 定长指令；Decoder 只有三宽，因此命中时峰值仍为三条。

![图 12：Cortex-A72 前端](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/3acd221742928faa_12_cortex_a72_frontend.png)

*图 12：图中整理为 64 项 L1 BTB、约 4096 项 L2 BTB、约 256 项间接目标阵列、约 31 项 RAS、48 项全相联 iTLB、48 KB 三路 L1I、3 个 Fill Buffer、1024 项四路 L2 TLB、三宽 Decode/Rename。带问号和测试反推的参数不能视为 Arm 官方框图。*

顺序取指时，A72 会尽量每个 64 B Cache Line 只查一次 Tag；只要后续 16 B Fetch 仍在同一 Line，就只打开之前命中的 Data RAM Way。这样最多四次连续取指共用一次 Tag 比较，降低动态功耗。

L1I 每 16 bit 指令数据配一位奇偶校验，每个 Tag 配两位。它能检测单 bit 翻转，却不能原位纠正；发现错误后丢弃并从 L2 重取。指令数据从不需要保存唯一的已修改副本，因此不一定需要 ECC。

L1I miss 时还预取相邻下一条 Cache Line。这种策略很保守，却符合未解耦 BTB 的能力：两条 64 B Line 已含 32 条 AArch64 指令，后半很可能在某个 Taken 分支后变得无用。Sandy Bridge/Haswell 可让 BTB 在 L1I miss 后继续生成目标，代价是更复杂、更耗电，而且指令侧需要足够 MLP。

A72 只有三个 L1I Fill Buffer，无法吸收 L2 延迟。

![图 13：A72 与 Kryo 的取指带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/e91564f2c387bc08_13_instruction_fetch_bandwidth_bytes.jpg)

*图 13：按 GB/s 表示。L1I 内 A72/Kryo 约 24.39/36.88 GB/s；L2 范围约 5.60/8.61 GB/s；内存范围约 2.45/0.54 GB/s。A72 测试因一次只能执行约 1 NOP/cycle，使用 NOP、ADD、MOV 混合；Kryo 使用 NOP，方法并不完全相同。*

![图 14：同一取指测试换算为 IPC](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/e3a9116b00b4974c_14_instruction_fetch_bandwidth_ipc.jpg)

*图 14：AArch64 每条指令固定 4 B，L1I 内 A72/Kryo 约 2.65/3.94 IPC；进入 L2 后约 0.61/0.91 IPC，内存约 0.27/0.06 IPC。两者从 L2 都无法维持 1 IPC。*

![图 15：Kryo 前端作为对照](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/8c39f076ca3abf6c_15_kryo_frontend.png)

*图 15：Kryo 图中为 8 项 L0、2048 项 L1、8192 项 L2 BTB，约 64 项间接目标、16 项 RAS，32 KB 四路 L1I、四宽 Decode/Rename。容量来自测试整理，并非 Qualcomm RTL。*

总体上，A72 前端多处弱于 Kryo：三宽而非四宽，L2 取指稍慢，Taken 分支延迟更高；优点是 L1I 从 32 KB 增至 48 KB，虽然后者的四路相联会部分抵消容量差。A72 与 A53 一样，在填入 L1I 时预译码，保存中间格式，以缩短主译码并节能。

## Rename 与乱序窗口：128 项 ROB 很深，资源比例不均

A72 的 Renamer 不能消除依赖型寄存器 MOV；它能识别“立即数零写寄存器”并打断依赖链，不过这是基本重命名器应有能力，Kryo 也一样。

![图 16：A72 的乱序资源分配](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/771dfef1632a21b6_16_a72_reordering_resources.jpg)

*图 16：三宽 Rename/Dispatch 为每条指令分配 128 项 ROB，并按需使用 32 项 Load Queue、15 项 Store Queue、39 项 Branch Order Buffer、96 个整数物理寄存器、26 个 Flags、158 个 64-bit FP/Vector、5 个 FPCR。图中总物理数包含非投机架构状态，正文关注可重命名部分。*

128 项 ROB 对低功耗核心很大。A72 使用 ROB 与独立物理寄存器文件，而不是把结果存进 ROB。整数侧约允许 64 次投机 Rename，意味着大约一半在途指令能产生整数结果；比例偏低，但仍略高于 Golden Cove 的对应覆盖比例。

FP/Vector 侧看似可以覆盖整个 ROB，因为物理条目只有 64 bit。一条 128-bit NEON 结果测试中竟消耗约五个 64-bit 条目，所以 A72 必须提供很多 64-bit FP 寄存器。副作用是标量 FP Rename 容量极深，只略低于 Haswell；但 128-bit Vector 只有约 31 组可见容量。

![图 17：不同资源的实测重排序容量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/2cce8e20d57f9fd1_17_measured_reordering_capacity.jpg)

*图 17：A72/Kryo/Haswell/N1 的 ROB 为 128/128/192/128；整数 Rename 64/74/136/88；64-bit FP 为至少 126/35/136/96；128-bit Vector 为 31/同 64-bit/同 64-bit/96；Flags 为 25/57/整数 RF/38；LQ 为 32/17/72/56；SQ 为 15/18/42/44；Branch Order 为 39/56/48/36；FP 控制寄存器 Rename 为 4/32/7/17。括号中的非投机条目不计入微基准可用值。*

访存资源偏轻：LQ 约占 ROB 四分之一，SQ 约占八分之一；Branch Order 与 Flags 比例更充足，可能更偏向分支密集代码。ROB 本身也可能因为 64-bit FP 寄存器已经必须做大而以较低成本顺便加深，所以单看 ROB 会高估所有类型指令的可用窗口。

![图 18：A72 与 Jaguar、Silvermont 的低功耗乱序容量](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/91fec30c7821ce7e_18_low_power_ooo_comparison.jpg)

*图 18：A72/Jaguar/Silvermont 的 ROB 为 128/64/32，整数 Rename 为 64/33～44/32，64-bit FP 为至少 126/44/32；LQ 为 32、Jaguar 共用 16、Silvermont 10，SQ 为 15/20/16。Jaguar 与 Silvermont 数据引自 Real World Tech。*

A72 在大多数资源上强于早两年的 Jaguar 与 Silvermont，因此更能越过长延迟，但 128-bit Vector 或 Store 密集代码会更早撞墙。

Haswell 单线程整数 Rename 测试约 148，曲线在 136～144 间有可复现尖峰。Intel 文档给出 168 个整数寄存器，因此文章认为 136 个可供投机 Rename，另有 `2×16` 保存两个 SMT 线程的非投机状态。Silvermont 则使用 32 项 Rename Buffer，退休时再复制到独立架构寄存器文件。

![图 19：Haswell 单线程整数 Rename 容量的异常尖峰](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/4a6584c5cc085304_19_haswell_integer_rename_capacity.png)

*图 19：136～144 条附近的尖峰可重复出现，说明用阻塞序列反推容量会受恢复、资源分配或测试边界影响。它是对照平台的细节，不能反推 A72。*

### 体系结构视角：ROB 深度不等于所有代码都能看 128 条远

每条指令都占 ROB，但只有 Load 占 LQ、Store 占 SQ、分支占 Branch Order、写寄存器者占物理条目。任何一种更小资源先满，Rename 都会停止。A72 的 15 项 SQ 和约 31 组 128-bit Vector Rename 会把特定代码的有效窗口压到远低于 128。

因此应按指令类型构造多个独立阻塞序列，并同时检查 ROB/LQ/SQ/Register Full。单一 `ROB=128` 数字只能说明上界，无法代替资源平衡分析。

## 分布式调度与执行端口

A72 为每条执行端口配置独立 Issue Queue。每个队列只搜索一个执行单元，每周期也只需读出一条 micro-op，逻辑简单、布线短、功耗低。Kryo 整数侧更接近半统一结构，FP 与访存侧仍以分布式为主。

### 整数执行

A72 有两条简单 ALU、一条整数 Multiply/Divide 和一条 Branch 管线；前三组队列各 8 项，Branch 为 10 项，总计最多约 34 条等待整数相关单元。

![图 20：A72 与 Kryo 的整数 Scheduler](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/ddb48a9a9bca73c5_20_integer_execution.png)

*图 20：A72 的四组 8/8/8/10 项队列绑定具体端口；Kryo 两组各 16 项半统一队列可覆盖四条 ALU，其中两条兼乘法、一条兼分支。图表示端口可达性，不是物理 Floorplan。*

Kryo 共有 32 项，但常见简单整数操作可用全部 32 项；A72 只能使用两组 ALU 队列的 16 项。未解析分支可用 16 对 10，整数乘法可用 16 对 8。Kryo 还有四条基础 ALU 和两条整数乘法路径，乘法并非完全流水化，平均约 1.25/cycle；A72 为 1/cycle。两者整数乘法延迟都是 5 周期。

Kryo 的吞吐更高，代价是更复杂的分配与调度网络。A72 的小型单端口队列和专用管线明显优先考虑面积与功耗。

### 浮点与向量

A72 有两条 FP/Vector Pipe，每条由 8 项独立队列供给。执行单元基本是 64-bit；多数 128-bit 指令以半速完成。它不像 Zen/Gracemont 那样把超出执行宽度的向量拆成两条 micro-op，更像 Pentium 4：保持一条 micro-op，分两拍送入执行单元。128-bit Packed Integer Add 是例外，两条管线都能全速执行。

![图 21：A72 与 Kryo 的 FP/Vector 端口](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/11bfa49eb7f70896_21_fp_vector_layout.png)

*图 21：A72 两组 8 项队列对应 64-bit FADD/FMUL/FMA、128-bit ALU 等；Kryo 为 16+15 项，普遍使用 128-bit 单元。A72 右侧端口还可做 64-bit Integer Multiply。*

![图 22：FP/Vector 吞吐与延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/85f3fe47ea29bb59_22_fp_vector_execution.jpg)

*图 22：A72/Kryo 的标量 FADD 为 2/1.67 per cycle、延迟 4/3；128-bit Packed FADD 为 1/1.64、4/3；FMUL 为 1/0.94、4/5；FMA 为 1/0.98、7/5；FMA/FADD 混合为 0.97/1.62；Vector Integer Add 为 2/1.85、3/1；Multiply 为 0.5/0.96、4/4。A72 标量 FMUL 与 FMA 均可达 2/cycle 的说明来自对单独标量路径的测试。*

A72 的标量 FP 吞吐很有竞争力，适合 JavaScript 中常见的 64-bit `number`；Kryo 延迟更低，128-bit FP/Integer Vector 吞吐也普遍更强。移动端重计算常由专用 IP 或云端接手，所以 Arm 把预算放在标量基础能力与能效上。以当时低功耗核标准看，A72 向量属于平均，Kryo 高于平均。

### AGU 与 LSU

A72 有独立 Load AGU 和 Store AGU，各由 8 项 Queue 供给，只能每周期一 Load 加一 Store。Kryo 有两条 Load AGU 加一条 Store AGU，可做两 Load 或一 Load 加一 Store，队列为 9+12 项。

![图 23：A72 与 Kryo 的 AGU 布局](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/55af4e63cadab6d8_23_agu_layout.png)

*图 23：A72 的固定 Load/Store 绑定简化 Rename 分配；Kryo 需要决定 Load 绑定哪条端口，却换来更高 Load 吞吐与更灵活调度。*

![图 24：更大 AGU Scheduler 在 Zen 2 工作负载中的意义](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/dac8d2934518792d_24_agu_scheduler_comparison.png)

*图 24：Cinebench R15 的 Zen 2/3950X 计数器示例中，Renamer 停顿周期里 ROB Full 约 4.56%、AGU Scheduler Full 约 2.22%、ALU Token 不足约 2.21%、SQ Full 约 1.56%。它只用于说明 AGU 调度容量可能成为现实瓶颈，不是 A72 测试。*

Load 执行前，LSU 必须检查是否与更老 Store 重叠。A72 Store-to-Load Forwarding 基本延迟约 7 周期，即便只是部分重叠也能维持；若 Load 与 Store 都跨 16 B 边界且只部分重叠，会再加 1～2 周期；两者都跨 64 B Cache Line 时再加约 2～3 周期。32-bit Load 从 64-bit Store 上半部取值甚至没有额外转发代价。

![图 25：A72 的 Store-to-Load Forwarding 矩阵](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/7554602e434bb3d2_25_a72_store_forwarding.jpg)

*图 25：测试复现 Henry Wong 的方法并加入 AArch64 版本，格内单位为周期。大部分完全或部分覆盖保持约 7，跨 16 B 与 64 B 的组合形成较慢斜带。*

这种稳健性可能来自 A72 不做内存依赖投机：Load 要等所有更老 Store 地址明确后才执行，因此检查时能确定是否需要转发。代价是未知 Store 地址会阻塞本可独立的 Load。

独立访存中，Store 跨 8 B 边界会降到半速；Load 跨 64 B Cache Line 也会半速。

![图 26：Kryo 的 Store Forwarding](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/c4716e7d79f0800a_26_kryo_store_forwarding.jpg)

*图 26：Kryo 能识别所有 Load 被 Store 包含的组合，却要约 15～16 周期，部分重叠再多 1 周期，远高于 A72。*

![图 27：放大低延迟差异后的 Kryo 矩阵](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/616dfa8dd3199904_27_kryo_store_forwarding_detail.jpg)

*图 27：手机微基准噪声很大。Load/Store 即使独立，只要落在同一 4 B 对齐区，Kryo 也多约 1 周期，像是先按高位做粗粒度匹配，再在可能重叠时精查。*

Kryo 的 Store 跨 8 B 没有额外代价，只有跨 64 B Cache Line 才受罚。它的内存依赖处理与 Sandy Bridge 到 Skylake 有相似之处，但 Forwarding 延迟高得多。

![图 28：A72 与 Kryo 的 Load/Store 路径汇总](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/95d3df5a757e9780_28_load_store_paths.png)

*图 28：A72 为 32 项 LQ、15 项 SQ、32 项全相联 L1 DTLB、1024 项四路 L2 TLB、32 KB 两路 L1D、2 MB 16 路共享 L2、6 项 MSHR；Kryo 为 32/15 项队列、192 项 TLB、24 KB 三路 L1D、512 KB 八路私有 L2。部分容量来自微基准整理，不能视为 RTL。*

### 体系结构视角：不做内存依赖投机也是一种性能选择

激进核心允许 Load 猜测越过地址未知的旧 Store，猜对可隐藏延迟，猜错则要检测、清除并 Replay。A72 更保守，可能牺牲独立 Load 的提前量，却让转发与恢复路径简单、延迟稳定。

验证需要同时构造地址很晚才就绪的非别名 Store、真实别名和部分重叠，再记录 Load Replay、Machine Clear 或等效恢复事件。没有公开事件时，只能从延迟分布与错误恢复台阶判断，不能把“没有观察到 Replay”直接升级为某个 RTL 算法。

## Cache 与 TLB：核心够用，层级却拖后腿

Jim Keller 曾把现代性能的两大限制概括为指令/分支可预测性与数据局部性。前端之后，A72 的关键问题正是 Cache 和 DRAM。

A72 有 32 KB、两路 L1D，命中延迟 4 周期。用 4 KB 页随机指针追逐时，工作集超过 16 KB 便出现异常增延迟；换 2 MB Huge Page 后，完整 32 KB 都保持 4 周期。TRM 明确写有 32 项全相联 L1 DTLB，并原生支持 4 KB、64 KB、1 MB 页，按理说 4 KB 页要到 128 KB 才溢出，因此 16 KB 台阶无法解释。

![图 29：Graviton 1 的 A72 Cache/内存延迟，ns](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/79a3003f53e316b3_29_a72_cache_memory_latency_ns.jpg)

*图 29：蓝色 4 KB 页、橙色 2 MB 大页。大页下 L1 约 1.75 ns、L2 约 9.18 ns、DRAM 约 92.07 ns；4 KB 页在 16 KB 后升到约 5.53 ns，最终 DRAM 达 162.08 ns。大页显示原始 Cache/Memory 延迟，4 KB 页更接近普通应用。*

![图 30：同一延迟按 2.3 GHz 换算为周期](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/770ad40fb7653a82_30_a72_cache_memory_latency_cycles.jpg)

*图 30：大页下 L1 为 4.02 周期、L2 为 21.10、DRAM 为 212.10；4 KB 页的中间台阶约 12.71/28.03，最大工作集达 372.78 周期。周期换算依赖 Graviton 1 的 2.3 GHz。*

L2 命中约 9 ns、21 周期，接近 Haswell/Zen 2 的 L3，但共享式低功耗 L2 常见较高周期数；Tremont L2 也约 19 周期，只是频率更高、实际 ns 更低。

超过 128 KB 后，32 项 L1 DTLB 开始 miss；1024 项、四路 L2 TLB 命中再加 7 周期、约 3 ns。Graviton 1 大页 DRAM 稍高于 92 ns，4 KB 页却达 162 ns，说明 Page Walk 很慢；核心并非唯一责任，因为页表项也可能来自高延迟 L2 或 DRAM。

Kryo 使用 24 KB、三路、3 周期 L1D，以及单级 192 项 TLB。每颗大核有 512 KB、八路私有 L2，小核为 256 KB；大/小核 L2 延迟分别 25/23 周期，之后的 DRAM 更慢。文章对 Snapdragon 821 存储层级评价很低，认为会严重压制不能留在 L1 的负载。

![图 31：A72 与 Kryo 的 4 KB 页实际延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/e86b10d41715754e_31_a72_kryo_latency_ns.jpg)

*图 31：A72/Kryo L1 约 5.53/1.29 ns，L2 约 9.16/10.94 ns，最大工作集约 162.08/306.08 ns。频率不同，所以 ns 更适合比较墙钟延迟。*

![图 32：A72 与 Kryo 的 4 KB 页延迟周期](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/05f061f1ba9fc7f7_32_a72_kryo_latency_cycles.jpg)

*图 32：A72/Kryo L1 约 4.01/3.01 周期，L2 约 21.31/25.64，最大工作集约 372.78/716.23。跨 SoC 差异包含内存控制器与 DRAM。*

Arm 允许实现者把 A72 L2 配在 512 KB～4 MB。Graviton 1 为四核集群选择 2 MB，避免了 Kryo 那样的小私有 L2，但共享带宽成为新问题。

### 单核带宽

A72 每周期可做一次 128-bit Load；相对同期桌面核不高，而且 Read 在 16 KB 后就下降，与前面的异常延迟台阶一致。L2 读略高于 8 B/cycle，推测 L1—L2 物理路径可能是 16 B/cycle，却利用不足。Kryo 的 L2 更小、私有，结果仍更差。

![图 33：A72 与 Kryo 单核 Read 带宽，GB/s](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/64b0349862a7467c_33_single_core_read_bandwidth_gbps.jpg)

*图 33：A72/Kryo 的 L1 峰值约 36.65/40.15 GB/s；A72 在 16 KB 后先跌至约 23，再回到约 26，L2 范围约 19.52；Kryo L2 约 17.78。进入内存后两者约 10 GB/s。*

![图 34：单核 Read 带宽换算为 B/cycle](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/a530c3cb83fedead_34_single_core_read_bandwidth_per_cycle.jpg)

*图 34：A72/Kryo L1 约 15.93/17.46 B/cycle，L2 约 8.47/7.73，内存约 4.94/4.39。理论接口宽度与实测有效带宽不能混写。*

Graviton 1 单线程 Write 低于 Read，这符合 Load 更常见的资源取舍。Kryo 反而拥有更高写带宽，可能因为 Store 数据交给更低层队列后，核心不必像 Load 那样持续跟踪返回值。Kryo 连续地址写可能有专门优化：反复写同一位置只能一条 128-bit Store/cycle，线性流却更高。

![图 35：单核 Write 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/ada80faafef23a07_35_single_core_write_bandwidth.jpg)

*图 35：Kryo L1 线性写约 53.45 GB/s，512 KB 附近仍约 50.27，内存约 18.47；A72 L1 约 18.39，L2 范围约 15.26，内存约 13.99。网页据同址写测试认为 Kryo 可能有线性写优化。*

### 体系结构视角：页表遍历会放大本来就慢的下级 Cache

TLB miss 的代价不是一项固定常数。Page Walker 要串行或部分并行读取多级页表，每一级又可能命中 L2 或 DRAM。A72 的共享 L2 已有 21 周期，4 KB 页最终比大页多约 70 ns，说明翻译路径与数据路径叠加后非常昂贵。

诊断时应分别用 4 KB/2 MB 页、相同物理数据布局和相同随机序列；同时测 DTLB refill、Walk Cache、L2 miss 与 DRAM。16 KB 的异常台阶无法由公开 32 项 TLB 解释，应作为未确定项保留，而不是强行给某个隐藏表命名。

## Graviton 1 系统结构：四核一组，L2 与集群出口先饱和

Graviton 1 每四颗 A72 组成一个 Cluster，共享 2 MB L2。`a1.metal` 有四个 Cluster，共 16 核。

### 集群内带宽

L2 Read 从两核开始几乎不再增长。页面一处写成“Graviton 2 的 L2”，上下文、图题和全文平台都明确为 Graviton 1，这里保留为原页面的一次型号笔误。四核合计仍略低于 16 B/cycle；Tremont 四核共享 L2 可到 32 B/cycle。A72 平均每核只有 4 B/cycle，L1 容不下的工作集可能受限。

![图 36：Graviton 1 四核 Cluster 的 Read 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/5c7f1df4723d64fc_36_cluster_read_scaling.jpg)

*图 36：L1 范围四核约 147.07 GB/s；L2 范围两核已约 36 GB/s，四核仍约 36.75；进入 DRAM 后一至四核从约 11.49 增到 13.49 GB/s，扩展很弱。*

集群内 DRAM Read 的四核上限约 13.5 GB/s。TRM 给出 L2 Fill/Eviction Queue 可为 20、24 或 28 项，可能不足以覆盖内存延迟；具体 Graviton 配置未公开，所以只能作为候选解释。

Write 的单线程峰值较低，却随核心数扩展得更好：L2 可接近 32 B/cycle。混合 Read/Write 也不再继续增加，因此一种可能是共享一条 32 B/cycle 路径，而 Read 利用不足；另一种可能是 16 B/cycle Read 加 32 B/cycle Write。现有曲线不能二选一。DRAM Store 同样比 Load 更容易扩展，支持“读请求跟踪深度不足”的判断。

![图 37：Graviton 1 四核 Cluster 的 Write 带宽](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/caefb429bb858e17_37_cluster_write_scaling.jpg)

*图 37：L1 范围四核约 73.55 GB/s，L2 范围约 64.57 GB/s；大工作集一至四核由约 13.99 增至 17.94 GB/s。*

### 与 Haswell 共享末级 Cache 对照

Haswell 用紧耦合 Ring 为四核提供统一 L3。它的共享末级 Read 起点更高，也能近线性扩展；Graviton 1 同 Cluster 的 L2 在两核后几乎停住。

![图 38：共享末级 Cache Read 扩展](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/9f961b8b366adad5_38_l2_read_haswell_comparison.jpg)

*图 38：Haswell 一到四核为 42.94/85.95/128.23/170.26 GB/s；Graviton 同 Cluster 为 19.35/36.37/36.74/36.75；若每个 Graviton Cluster 只用一核，则为 19.35/39.08/58.88/78.13。*

![图 39：按频率归一后的共享 Cache Read](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/276d5ad249429d40_39_l2_read_clock_normalized.jpg)

*图 39：Haswell 每核每周期从 12.63 扩到总计 50.08 B/cycle；Graviton 同 Cluster 从 8.41 到 15.98 后饱和；每 Cluster 一核则扩到 33.97。即使归一频率，同 Cluster 互连仍明显落后。*

Write 扩展好得多，绝对数受 2.3 GHz 限制；归一到 B/cycle 后，Graviton 甚至很接近 Haswell。

![图 40：共享末级 Cache Write 扩展](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/86b7c2035a4afb72_40_l2_write_haswell_comparison.jpg)

*图 40：Haswell 一到四核为 25.14/50.17/74.73/98.54 GB/s；Graviton 为 15.26/32.32/48.42/64.57。图中没有测试 Graviton“每 Cluster 一核”的 Write，因为运行时间过长。*

![图 41：按频率归一后的共享 Cache Write](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/c746974d01b28b00_41_l2_write_clock_normalized.jpg)

*图 41：一到四核 Graviton 为 6.64/14.05/21.05/28.07 B/cycle，Haswell 为 7.40/14.76/21.98/28.98，几乎同斜率。Load 比 Store 更常见，不能让良好的 Write 扩展掩盖 Read 瓶颈。*

7-Zip 与 libx264 的 Load:Store 比分别约 3.4:1、2.3:1；L2 还要承接全为 Read 的 L1I Refill，因此实际 L2 请求会更偏 Read。Write 曲线漂亮，并不足以消除 A72 的 L2 带宽问题。

### 跨 Cluster DRAM 带宽

同一 Cluster 四核只到约 13.5 GB/s；四个 Cluster 各用一核则超过 36 GB/s，说明瓶颈更可能在 Cluster 到芯片互连的出口，而非全芯片内存控制器。继续增加到 16 核，Read 不再显著上升；16 核 Write 略高于 27 GB/s。

![图 42：Graviton 1 的 DRAM Read 扩展](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/60cedf5dd22bdef9_42_dram_bandwidth_scaling.jpg)

*图 42：3 GB 工作集下，Graviton 同 Cluster 一到四核约 11.49/12.53/12.64/13.49 GB/s；每 Cluster 一核为 11.49/22.13/31.18/36.31；Haswell 双通道 DDR3 对照为 14.77/18.91/19.44/19.41。页面据此推测 Graviton 可能是四通道快速 DDR3 或较慢 DDR4，内存型号未公开，不能当作确认配置。*

### 两级一致性路径

Cluster 内，L2 控制器维护 Snoop Tag，复制每颗核心的 L1D Tag；命中后从对应 L1 取数据。集群内转移延迟中等，不如紧耦合 Ring，却可以接受。

![图 43：Graviton 1 核间延迟矩阵](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/eaa80e5a9e9ac430_43_graviton_core_latency.png)

*图 43：单位 ns。四核 Cluster 内约 55 ns，跨 Cluster 约 217～220 ns，边界非常清晰。网页没有披露锁/共享线状态与同步协议，因此矩阵主要用于识别拓扑。*

![图 44：Haswell 核间延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/8d969b9d30af98fc_44_haswell_core_latency.png)

*图 44：同物理核的 SMT 线程约 6.4～6.7 ns，跨核通常约 18～22 ns。高频 Ring 与 L3 紧耦合，让它远低于 Graviton。*

![图 45：Snapdragon 821 Kryo 核间延迟](https://gongzhonghao1-1402552401.cos.ap-shanghai.myqcloud.com/wechat/articles/arm_cortex_a72_wechat_article_zh/a041f36834cd612d_45_kryo_core_latency.png)

*图 45：同 Cluster 约 59.8～85.9 ns，跨大小核 Cluster 约 245～335 ns，比 Graviton 1 更慢。矩阵支持 Snapdragon 821 将大、小核分成独立 Cluster 的判断。*

Graviton 跨 Cluster 超过 200 ns，已经接近服务器跨 Socket 量级。页面认为手机核心的一致性并未针对服务器优化，这个弱点随 A72 进入服务器。与此同时，它也判断一般负载中的 Core-to-core Transfer 不够频繁，未必显著影响总体性能，因此不应只凭一张矩阵夸大后果。

### 体系结构视角：集群化把扩展问题分成两层

四核共享 L2 可以减少面积，也让 Cluster 内一致性由本地 Snoop Tag 处理；但所有 Read miss、I-Cache Refill 和跨 Cluster 流量会争用出口。图 38/42 恰好把两级瓶颈分开：同 Cluster 饱和很早，每 Cluster 一核则继续扩展。

只有当同 Cluster L2 Read 带宽不再增长、Cluster 出口队列持续满，而其他 Cluster 仍有余量，才有理由把瓶颈指向本地链路。跨 Cluster 高延迟还应与 Probe/Retry、Fabric 排队和共享数据比例一起看，不能把所有 218 ns 都归给单个一致性步骤。

## 结语：A72 的核心能力强于它的存储系统

Cortex-A72 是一颗小而称职的低功耗乱序核心。128 项 ROB、较深重排序能力和 48 KB L1I 是突出优点；在手机、单板机和网络设备中处理管理任务完全足够。

最大弱点是 Cache。Graviton 1 四核共享 2 MB L2，容量不大、命中 21 周期，Read 总带宽像只有一条 16 B/cycle 接口供四核共享。L2 还要承接全部 L1D/L1I miss。再往后，同 Cluster DRAM Read 约 13.5 GB/s，显示 Cluster 与 SoC Fabric 间链路偏窄。

其他局限更像低功耗目标下的合理牺牲。64-bit 执行单元和物理寄存器让 128-bit NEON 吞吐与有效重排序深度下降；小型分布式 Scheduler 也更容易填满，却节省面积、功耗和关键路径复杂度。若核心本就不负责重数值计算，这些取舍可以接受。

因此，A72 适合手机、爱好者单板机、网络设备与控制任务；进入服务器后，Graviton 1 的 Cache、集群互连和内存层级更容易限制它。

### 体系结构视角：从 A72 可以看到的七个设计认识

第一，A72 的历史价值在于把“足够深的乱序 AArch64”带到低成本平台。它不是同期最宽核心，却用 128 项 ROB 把延迟容忍能力推进到 Jaguar、Silvermont 之上。

第二，资源比例比 ROB 标称深度更重要。15 项 Store Queue、31 组 128-bit Vector Rename 和小型分布式 Scheduler 会先于 128 项 ROB 限制特定代码。

第三，前端容量与速度必须分开。48 KB L1I 很大，方向预测也不差，但 2～3 周期 Taken Branch 和不足 1 IPC 的 L2 取指仍会让大代码足迹失速。

第四，保守内存依赖策略可以换来稳定 Forwarding。A72 可能让 Load 等待更老 Store 地址，却避免了 Kryo 15～16 周期的常见转发代价；这是投机收益与恢复复杂度的交换。

第五，Page Walk 会放大存储层级弱点。大页 DRAM 约 92 ns，4 KB 页却约 162 ns，说明 TLB 覆盖之外还要考虑页表项来自哪一级。

第六，集群化系统必须分别审视核内、Cluster 内和芯片级扩展。Graviton 同 Cluster Read 很快饱和，而每 Cluster 一核能把 DRAM Read 推到 36 GB/s；全芯片控制器并不是第一个瓶颈。

第七，CPU IP 与具体产品实现不能混为一谈。A72 允许 512 KB～4 MB L2，Raspberry Pi、手机和 Graviton 的 Cache、互连、频率与内存都不同；本文最严厉的存储批评首先针对 Graviton 1 的实现。

## 参考资料

- Chester Lam，*ARM’s Cortex A72: aarch64 for the Masses*，Chips and Cheese，2023-11-10：https://chipsandcheese.com/p/arms-cortex-a72-aarch64-for-the-masses
- Arm，*Cortex-A72 MPCore Processor Technical Reference Manual*
- Paul Drongowski，*ARM Cortex-A72 fetch and branch processing*（网页引用）
- Real World Tech 的 Jaguar、Silvermont 乱序资源数据（网页引用）
- Henry Wong 的 Store-to-Load Forwarding 测试方法（网页引用）

如果这类分析对你有帮助，可以通过原页面列出的 Patreon 或 PayPal 支持 Chips and Cheese，也可以加入其 Discord 社区交流。
