# OpenC910 SPEC CPU2017 SimPoint 原理、流程与项目实践

> 状态基线：2026-07-21，Git `17068ce4e9a60114796922d792cb85f22e4082bd`。
> 实时进度必须以脚本校验为准；本文中的数字是写作时快照，不替代验收报告。

## 1. 本文要解决什么问题

SPEC CPU2017 的 `ref` 工作负载通常包含数千亿乃至数万亿条动态指令，无法直接放进 RTL 仿真器完整执行。SimPoint 的作用是先在较快的功能模型上观察完整程序，把行为相似的执行区间聚成若干类，再从每一类中选一个真实代表区间。详细模拟器只执行少量代表区间，并按各类在完整执行中的权重恢复 benchmark 级结果。

本项目还面临一个额外约束：OpenC910 当前可稳定运行的是 bare-metal RTL 测试，尚不能低成本、批量地把任意 Linux SPEC 进程状态恢复到 RTL。因此仓库中存在三个层次：

| 层次 | 本项目定义 | 实际运行对象 | 能回答的问题 | 不能声称的结果 |
|---|---|---|---|---|
| L1 | 完整程序 SimPoint 画像 | QEMU 中的原始 SPEC Linux ELF | 程序有哪些阶段、每阶段多大权重、热点函数是什么 | C910 RTL 的真实性能 |
| L2+ | SimPoint 指导的 composite kernel | 每个 SPEC benchmark 独立的 bare-metal 复合 ELF | 微结构修改对相似机制负载的相对影响 | 原始 SPEC 代表区间性能、官方 SPEC 分数 |
| L3 | checkpoint/restore 代表区间 | RTL 中恢复后的原始 SPEC Linux 状态 | 多个真实代表区间的 RTL 指标及加权结果 | 在全部区间验证完成前，不能代表完整 benchmark |

这里的 **L1、L2+、L3 是本项目内部的工程分级，不是 SimPoint 或 SPEC 官方术语**。

写作时的核心结论是：

1. L1 已完成严格校验 `128/129`，唯一缺项是 `638.imagick_s/ref`。
2. L2+ 已有 43 个独立 composite case 和 quick/full 契约，但当前还没有满足最终门禁的 43-case 干净 RTL 全量证据。
3. L3 已证明一条小规模 checkpoint/restore 链路可运行，但正式多 benchmark、多 SimPoint campaign 尚未完成。
4. 当前可以把 L2+ 用于微结构相对比较和瓶颈实验；不能把它写成“真实 SPEC RTL 性能”或“SPEC CPU2017 分数”。

## 2. 必须先掌握的术语

| 术语 | 准确定义 | 在本项目中的对应物 |
|---|---|---|
| 静态指令 | ELF 中的一条指令，只按地址计一次 | 反汇编中的一条 RISC-V 指令 |
| 动态指令 | 程序执行时实际经过的一条指令；循环会重复计数 | QEMU BBV count、RTL retired instruction |
| Basic Block | 单入口、控制流中间不跳出的直线代码段 | 本项目用 QEMU Translation Block 近似 |
| TB | QEMU 翻译和执行的基本块 | `.bb.map` 中由 PC 标识的 block |
| Interval | 按动态指令数切分的连续执行片段 | 默认名义长度 100,000,000 条 guest 指令 |
| BBV | 一个 interval 内各 block 的动态指令计数向量 | `<bench>_<size>.bb` 的每一行 |
| Phase | 长时间执行中行为相近的一类 interval | SimPoint 的一个 cluster；L2+ 中也指复合 ELF 的机制阶段，二者不能混同 |
| Cluster | 聚类后的一组相似 BBV interval | cluster ID 及其成员集合 |
| SimPoint | 一个 cluster 中最接近中心的真实 interval | `.simpoints` 中的 interval 编号 |
| Weight | cluster 占完整画像的比例 | `.weights` 中按 cluster ID 记录的权重 |
| Warmup | 正式测量前恢复 cache、TLB、预测器等历史状态的执行 | L3 的代表区间前导指令；L2+ 也有 kernel 自身 warmup |
| ROI | Region of Interest，真正统计性能的指令区间 | RTL counter 的开始和结束边界 |
| Program feature | 程序本身的动态行为，如指令类型、分支、地址流 | QEMU/plugin 特征统计 |
| Microarchitecture metric | 处理器对程序的反应，如 miss、flush、not-ready、stall | RTL `PERF_DETAIL` 计数器 |

最重要的区分是：**SimPoint 描述程序执行阶段；性能计数器描述某个微结构运行这些阶段时发生了什么。** 前者不能直接推出后者。例如 load 比例高不等于 D-cache miss 一定高，条件分支多也不等于预测错误一定多。

## 3. SPEC CPU2017 在本项目中的含义

### 3.1 Rate 与 Speed

SPEC CPU2017 包含四个正式 suite：

| suite | benchmark 数 | 官方度量目标 | 本项目名称后缀 |
|---|---:|---|---|
| Integer Rate | 10 | 吞吐量，多份工作可并行 | `_r` |
| Floating Point Rate | 13 | 吞吐量，多份工作可并行 | `_r` |
| Integer Speed | 10 | 单份任务完成时间 | `_s` |
| Floating Point Speed | 10 | 单份任务完成时间，可按规则使用 benchmark 线程 | `_s` |

因此本项目有 23 个 Rate benchmark 和 20 个 Speed benchmark，共 43 个 benchmark 身份。Rate 与 Speed 中名字相似的程序仍是不同 benchmark，例如 `505.mcf_r` 与 `605.mcf_s`，不能共用 SimPoint、权重或最终结果。

对单核 C910 延迟研究，Speed 的目标语义更直接；Rate 仍然有研究价值，但“单 copy 跑 `_r`”不能冒充官方 Speed 指标。项目当前同时保留二者，并分别构造 43 个独立 case。

### 3.2 test、train 与 ref

| 输入 | 官方用途 | 适合本项目做什么 | 不适合做什么 |
|---|---|---|---|
| `test` | 快速验证程序能构建、启动并给出正确输出 | 工具冒烟、脚本调试、格式验证 | 性能代表性结论 |
| `train` | 较小的非计分验证/训练输入 | 流程开发、ref 不可得时的临时画像 | 默认替代 ref 的正式性能画像 |
| `ref` | 正式计时参考输入 | 生产级 SimPoint 画像的首选来源 | 在慢 RTL 上从头完整执行 |

官方 reportable run 会先执行不计时的 test/train 并校验输出，再对 ref 计时。本项目收集 `43 x 3 = 129` 个 L1 组合，是为了验证完整工具链、比较输入规模对阶段结构的影响并保留来源证据；这不表示 test/train 会进入官方分数，也不表示先做 test 再做 train 是 SimPoint 算法的必需步骤。

### 3.3 为什么本项目结果不是官方 SPEC 分数

官方结果要求遵循 SPEC run/reporting rules、指定的运行组织、重复次数、正确性校验、编译配置披露和计分方法。本项目的 QEMU BBV 与 bare-metal composite 主要服务于体系结构研究：

- QEMU 时间不是目标 C910 RTL 时间；
- composite ELF 不是 SPEC 原始源码和输入；
- L2+ 没有恢复真实 Linux 进程状态；
- 当前没有执行官方的整套计分与报告流程；
- 当前主要用于同一 RTL 基线与优化版本之间的相对比较。

对外表述应使用：

> SimPoint-guided SPEC-like RTL representative kernel result

不应使用：

> SPEC CPU2017 score，或多 SimPoint 加权的真实 SPEC RTL 性能

## 4. SimPoint 的基本原理

### 4.1 为什么可以抽样

长程序通常不是从头到尾都执行完全不同的代码，而会反复进入若干稳定行为，例如解析、图遍历、矩阵计算、排序、垃圾回收或输出处理。若两个长区间执行了大致相同的基本块，并且执行比例相近，它们通常具有相似的指令混合、控制流和地址生成行为。SimPoint 利用这一点，把完整执行压缩成少量代表区间。

抽样不是简单地“取最热函数”或“取程序中间 1 亿条指令”。一个热点函数可能包含多个内部阶段；一个时间位置也可能刚好是初始化或阶段切换。SimPoint 以整段代码使用频率向量进行无监督聚类，能够同时表达多个基本块的组合。

### 4.2 从动态执行序列构造 BBV

设完整执行被切为 `N` 个 interval，程序中观察到 `D` 个 block。第 `i` 个 interval 的 BBV 为：

```text
V_i = [c_i,1, c_i,2, ..., c_i,D]
```

其中 `c_i,j` 是 block `j` 在 interval `i` 中贡献的动态指令数。标准化后：

```text
V'_i = V_i / sum(V_i)
```

这样比较的是各 block 的执行比例，而不是最后一个不完整 interval 与普通 interval 的绝对长度差。

本项目 `.bb` 使用 SimPoint 的稀疏文本格式：

```text
T:<block-id>:<instruction-count> :<block-id>:<instruction-count> ...
```

未出现在某行的维度视为 0。默认 interval 是 1 亿条 guest 动态指令。由于 QEMU plugin 在 TB 执行回调中计数，边界具有 TB 粒度；它适合阶段画像，但不是可直接恢复的精确单指令 checkpoint 坐标。

### 4.3 降维与聚类

真实 BBV 可能有数千到数万个维度。SimPoint 先用随机线性投影把 BBV 降到较低维空间，再运行 K-means：

1. 随机选择若干 cluster 中心；
2. 把每个 interval 分配给最近中心；
3. 重新计算中心；
4. 重复直到收敛；
5. 比较不同 `K` 的聚类质量并选取结果。

经典 SimPoint 使用 BIC（Bayesian Information Criterion）在拟合误差与 cluster 数量之间折中：增加 cluster 通常会降低组内距离，但模型复杂度也会受到惩罚，从而避免只靠增加 `K` 获得表面上更好的拟合。本项目生产参数为 `maxK=5`，含义是候选 cluster 数量上限为 5，并不保证每个 benchmark 一定产生 5 个 cluster。当前 Rate 每项有 2–5 个 cluster，Speed 每项有 3–5 个 cluster。

随机投影和 K-means 初始化意味着结果可能受随机 seed 影响。生产研究不能只因一次聚类成功就认为 phase 唯一，应对关键 benchmark 做多 seed 稳定性检查。若不同 seed 得到的代表区间变化很大，但加权性能接近，说明宏观估计可能仍稳定；若权重和性能也明显变化，则需要增大 `maxK`、调整 interval 或扩大样本验证。

### 4.4 选择代表 interval

聚类中心通常不是程序中真正存在的 interval。SimPoint 会在每个 cluster 中选择距离中心最近的实际 interval 作为 representative simulation point：

```text
s_k = arg min(i in cluster k) distance(V'_i, centroid_k)
```

这保证详细仿真使用的是一段真实动态执行，而不是人工拼出的平均向量。

SimPoint interval 编号通常从 0 开始。对单一、连续 command，interval `i` 的名义起点可粗略写成 `i * interval_length`；本项目会把一个 benchmark 的多条 SPEC command 拼接进同一画像，且边界是 TB 粒度，因此不能用这个乘法直接生成 checkpoint。L3 必须结合 `.bb.cmdmap` 和完整计划，把全局 interval 转换为具体 command 内的动态坐标。

### 4.5 cluster 权重

若第 `k` 个 cluster 覆盖的 interval 数为 `n_k`，完整画像有 `N` 个 interval，则典型权重是：

```text
w_k = n_k / N
sum(w_k) = 1
```

最后一个 interval 可能不完整，工具实现也可能提供更精细的长度处理；使用时应以 `.weights` 为准，而不是自行按文件行数重算。本项目严格门禁允许权重和相对 1 的误差不超过 `0.002`。

### 4.6 如何正确加权性能

假设第 `k` 个代表区间测得 `I_k` 条指令、`C_k` 个周期：

```text
CPI_k = C_k / I_k
benchmark_CPI = sum(w_k * CPI_k)
benchmark_IPC = 1 / benchmark_CPI
```

不能直接使用：

```text
wrong_IPC = sum(w_k * IPC_k)
```

事件计数也不能直接相加，因为每个代表区间只代表完整程序的一部分。一般先转换成每指令事件率：

```text
event_per_inst_k = event_k / I_k
benchmark_event_per_inst = sum(w_k * event_per_inst_k)
```

对 cache miss rate 这类“分子/分母”指标，应分别汇总基础事件率再相除：

```text
weighted_misses_per_inst  = sum(w_k * misses_k  / I_k)
weighted_accesses_per_inst = sum(w_k * accesses_k / I_k)
miss_rate = weighted_misses_per_inst / weighted_accesses_per_inst
```

直接平均各区间 miss rate 会在各区间访问密度不同时产生偏差。

### 4.7 SimPoint 没有自动解决 warmup

代表 interval 在原程序中可能位于数千亿条指令之后。若详细模拟从空 cache、空 TLB、空分支预测器直接进入该 interval，测得的是冷启动状态，而不是原执行到达此处时的状态。

常见方案有：

1. 从更早位置建立 checkpoint，再执行一段 warmup；
2. 保存或重建 cache、TLB、预测器状态；
3. 使用足够长的功能预热，再只在 ROI 开启详细计数；
4. 对不同结构采用不同预热长度并做收敛实验。

因此完整 SimPoint 方法必须同时回答三个问题：**从哪里开始、如何恢复架构状态、如何恢复微结构历史。** 只有 `.simpoints` 和 `.weights` 还不足以直接进行可信 RTL 测量。

还要注意，BBV 是 **代码路径画像**，不直接包含 load/store 地址、数据值、cache 状态或分支历史。若两个 interval 执行同一批 block、比例也相近，但访问完全不同的数据区域，BBV 可能把它们归到同一 cluster，而 cache/TLB 行为并不相同。SimPoint 的优点是画像基本不依赖目标微结构；代价是数据阶段必须通过地址流、working set/reuse 特征或真实代表区间结果做补充验证。

### 4.8 interval 与 maxK 如何选择

| 参数变化 | 优点 | 风险 |
|---|---|---|
| 更短 interval | 能识别短暂阶段和快速切换 | 向量数量、聚类和 checkpoint 数增加；边界/warmup 占比更大 |
| 更长 interval | 文件和代表点较少，阶段统计更平滑 | 多个不同阶段可能在一个 interval 内被平均 |
| 更小 maxK | RTL 成本低，结果易管理 | 不同机制被合并，代表误差可能升高 |
| 更大 maxK | 能表达更多行为模式 | 代表区间、checkpoint 和 RTL 成本增加，也可能过拟合小阶段 |

1 亿条指令是经典 SimPoint 研究中常用的大区间量级，也与本项目 ref 全程序画像和严格 validator 一致，但它不是对所有 workload 都天然最优。项目若改变 interval 或 `maxK`，必须生成新的独立 campaign，不能与当前 100M/maxK=5 权重混用。

## 5. 标准的多 SimPoint 研究流程

一套可发表、可复现的代表区间流程通常如下：

```text
固定 benchmark、输入、二进制和运行环境
  -> 在完整执行上收集 BBV
  -> 校验程序输出正确、画像覆盖完整
  -> SimPoint 聚类并选代表 interval/weight
  -> 为每个代表 interval 建立 checkpoint
  -> 恢复架构状态和内存
  -> warmup cache/TLB/预测器
  -> 测量固定长度 ROI
  -> 校验每个 ROI 正确完成且无未知态
  -> 按 cluster weight 汇总 CPI 和事件率
  -> 与完整仿真或更长抽样做误差验证
```

这条路线在本文中对应 L3。L2+ 的“一个 composite ELF 内嵌多个机制”是为了适应当前 RTL 环境而设计的工程近似，不是标准 SimPoint checkpoint 方法。

## 6. 本项目 L1：完整 SPEC 画像如何生成

### 6.1 固定的执行环境

流程设计为在 Ubuntu 20.04 Docker 容器中运行，仓库挂载为 `/work`。当前关键配置为：

```text
编译器：Xuantie GCC Linux glibc toolchain
优化：  -O2 -march=rv64imafdcxtheadc -mabi=lp64d -mtune=c910 -fcommon
执行器：qemu-riscv64 -cpu c910 -L <Xuantie sysroot>
固定 VA：-R 0x4000000000
BBV：    QEMU user-mode plugin tools/qemu-plugins/simple_bbv.so
interval：100000000 guest instructions
maxK：   5
```

固定 guest VA 的目的不是提高性能，而是让主 ELF、动态链接器和共享库的 PC 地址可重复，从而把 TB 地址稳定映射到模块与函数。旧画像如果使用 ASLR，会通过同进程探针恢复地址 slide，并在 manifest 中标记 `aslr_slide_recovered`。

### 6.2 单 benchmark 调用链

命令：

```bash
./spec_flow/run_bbv_simpoint.sh 505.mcf_r ref 5 100000000
```

脚本按以下步骤执行：

1. 调用 `write_config.sh` 生成当前 C910 SPEC config。
2. 构建 `simple_bbv.so`，如果插件尚不存在。
3. 用 `runcpu --action=runsetup --tune=base` 生成对应输入的 SPEC run directory。
4. 从 `speccmds.cmd` 提取该 benchmark 的全部执行命令。
5. 对每条命令记录 ELF、loader 和共享库地址范围。
6. 用 QEMU 执行每条命令，并把 TB 动态指令计数追加到同一完整画像。
7. 给不同命令分配互不重叠的 block ID 区间，写入 `.bb.cmdmap`。
8. 执行 SPEC `compare.cmd`，确认输出正确。
9. 对完整 `.bb` 调用 SimPoint，生成 representative interval 和 weight。
10. 结合 ELF/module symbol，把代表区间中的 TB 归因到函数。
11. 生成 `manifest.json`，冻结参数、版本、文件、计数和验证状态。

### 6.3 本项目的 BBV 到底统计什么

`simple_bbv.c` 在 QEMU 翻译 TB 时记录：

```text
block ID
TB entry PC
TB 静态指令数
```

每次 TB 执行时执行：

```text
block_dynamic_count += tb_instruction_count
interval_instruction_count += tb_instruction_count
```

所以 `.bb` 的 value 是 **TB 对该 interval 贡献的动态 guest 指令数**，不是 TB 执行次数，也不是 host x86 指令数。

需要理解以下准确性边界：

- QEMU TB 是动态二进制翻译单元，与编译器定义的 basic block 很接近但不保证完全相同；
- interval 边界位于 TB 回调粒度，名义长度为 1 亿条，不是精确逐指令切割；
- L1 适合阶段发现和函数热点分析，不应把 interval 编号直接当作可恢复 PC；
- 动态库中的代码必须结合 `.bb.modules` 才能正确归因；
- `[module:xxx:unresolved]` 表示模块已知但符号不可解析，不等于地址来源完全未知；
- `[external-or-unknown]` 才表示无法确定所属 ELF/module，最终门禁会检查其加权比例。

### 6.4 多 command benchmark

一个 SPEC benchmark 可能在一次 workload 中执行多条命令。若每个 QEMU 进程都从 block ID 1 开始，后续命令会与前一命令的 BBV 维度冲突，聚类结果将失真。

本项目使用 `.bb.cmdmap` 记录：

```text
cmd_index  start_id  end_id  elf  command
```

每条 command 的 ID 范围必须连续且互不重叠。严格 validator 还检查 `.bb.map` 的 ID 唯一性、最大 ID 与 command 末端一致，以及每条 command 的 PC 是否与模块地址范围相交。

### 6.5 Perlbench 的 fork 处理

`500.perlbench_r` 和 `600.perlbench_s` 会递归执行并 fork。fork 后的 QEMU 子进程会继承插件内存，若继续使用父进程计数器，会产生重复计数和 ID 冲突。

项目对这两项启用 PID namespace：

```text
raw block ID = host PID << 32 | process-local ID
```

子进程检测到 PID 变化后会重置继承计数。随后 `compact_bbv_ids.py` 把稀疏的 64 位 ID 压缩成连续 ID，并合并固定 VA 下真正相同的 TB。`make -C tools/qemu-plugins check-fork` 用专门测试验证该路径。

### 6.6 输出文件如何阅读

以 `spec_runs/505.mcf_r_ref_c910/` 为例：

| 文件 | 内容 | 用途 |
|---|---|---|
| `505.mcf_r_ref.bb` | 每个 interval 的稀疏 BBV | SimPoint 聚类的核心输入 |
| `505.mcf_r_ref.bb.map` | block ID、PC、TB 指令数 | 地址和函数归因 |
| `505.mcf_r_ref.bb.cmdmap` | command 与 ID 范围 | 防止多 command 冲突，定位区间来源 |
| `505.mcf_r_ref.bb.modules` | 每条 command 的模块地址范围 | 归因 loader/libc/libm 等动态代码 |
| `505.mcf_r_ref.simpoints` | representative interval 与 cluster ID | 指定每类选哪个真实 interval |
| `505.mcf_r_ref.weights` | weight 与 cluster ID | 恢复完整程序统计 |
| `505.mcf_r_ref.function_profile.csv` | 全局和逐 cluster 热点函数 | 解释阶段、构造 L2+ 机制 |
| `qemu_bbv.log` | QEMU 收集过程 | 运行错误、时间和 command 证据 |
| `compare.log` | SPEC 输出比较 | 正确性门禁 |
| `simpoint.log` | 聚类过程 | K、输出和错误检查 |
| `manifest.json` | 参数、版本、SHA/路径、计数和验证结果 | 单 case 的权威机器可读索引 |

`.simpoints` 的两列是：

```text
<representative-interval> <cluster-id>
```

`.weights` 的两列是：

```text
<weight> <cluster-id>
```

两者应当 **按 cluster ID 连接**，不能假设文件行顺序永远一一对应。

### 6.7 manifest 为什么重要

只看到 `.bb`、`.simpoints` 或输出目录存在，不能证明结果可用。`manifest.json` 记录并绑定：

- benchmark、input size、interval、maxK；
- 是否从程序开头到结尾完整收集；
- 编译选项、QEMU CPU 与固定 VA；
- QEMU、GCC、SimPoint 路径和版本；
- Git commit 和 dirty 状态；
- BBV interval、block、module 数量；
- SPEC compare、SimPoint、module map 是否通过；
- 全局热点和每个 cluster 的 interval、weight、热点函数；
- 所有关键产物的路径。

最终研究记录应引用 manifest 内容或 SHA，而不是仅写“使用了某个目录”。

## 7. `505.mcf_r/ref` 实例：从真实 SimPoint 到 L2+

### 7.1 L1 真实画像

当前 manifest 记录：

| 项目 | 值 |
|---|---:|
| BBV interval | 8121 |
| 名义 interval 长度 | 100,000,000 指令 |
| 映射 TB | 3490 |
| 映射模块 | 3 |
| SimPoint cluster | 5 |
| SPEC compare | 通过 |
| 完整程序画像 | 是 |

因此画像覆盖约 `8121 x 100M = 8121 亿` 条名义 guest 指令；最后一个 interval 和 TB 边界会带来小量差异，应把该值理解为规模估算，不是精确 retired instruction 总数。

五个代表点为：

| cluster | representative interval | weight | 主要热点 |
|---:|---:|---:|---|
| 0 | 1164 | 0.2207860 | `replace_weaker_arc`、`price_out_impl` |
| 1 | 789 | 0.0887822 | `arc_compare`、`spec_qsort` |
| 2 | 5290 | 0.5454990 | `spec_qsort`、`cost_compare`、`primal_bea_mpp` |
| 3 | 4601 | 0.0481468 | `price_out_impl`、`replace_weaker_arc` |
| 4 | 4578 | 0.0967861 | `primal_bea_mpp`、`spec_qsort`、`cost_compare` |

这说明 `505.mcf_r` 不是“一个 mcf 小循环”。它至少包含排序/比较和 pricing/tree 两大行为，且不同 interval 中函数比例明显不同。

### 7.2 L2+ 如何把五个 cluster 放入一个 ELF

项目把行为接近的 cluster 分成两个互斥且完备的机制组：

| composite phase | cluster | 目标权重 | quick 实测份额 | full 实测份额 |
|---|---|---:|---:|---:|
| `sort_compare` | 1、2 | 0.6342811 | 0.6344992 | 0.6343317 |
| `pricing_tree` | 0、3、4 | 0.3657189 | 0.3655008 | 0.3656683 |

目标权重来自源 cluster 权重之和：

```text
sort_compare = w_1 + w_2
pricing_tree = w_0 + w_3 + w_4
```

然后调节 bare-metal phase 的循环次数，使同一个 composite ELF 内各 phase 的 **动态退休指令份额** 接近目标。quick/full 都执行完整 composite，RTL 之后不再把两个 phase 的 CPI 做第二次加权。

这一步保留的是“机制组成和大致动态份额”，并没有保留原程序的完整指令、数据结构、地址轨迹、OS 状态和跨阶段历史。因此它比单一手写 kernel 更有代表性，但仍低于真实 checkpoint。

## 8. 本项目 L2+ 的构建方法

### 8.1 为什么使用 composite

直接对每个 cluster 分别手写一个 kernel 再在 RTL 后加权，会产生三个问题：

1. 43 个 benchmark、最多 5 个 cluster 会扩张成近 200 次 RTL case，管理和仿真成本很高；
2. 很多 cluster 只是相同机制的不同时间实例，逐个手写会重复；
3. 每个极短子 kernel 都从冷状态启动，会放大初始化和 warmup 偏差。

因此当前 L2+ 对每个 benchmark 只保留一个 composite ELF，在 ELF 内顺序执行 2–3 个机制 phase，并把源 cluster 的权重转成 phase 的目标动态指令份额。

### 8.2 cluster 到机制 phase 的规则

对 benchmark `b` 的 cluster 集合 `C_b`，定义若干机制组 `G_b,1 ... G_b,m`。必须满足：

```text
G_b,p intersection G_b,q = empty, p != q
union(G_b,p) = C_b
```

即每个 cluster 恰好进入一个 phase，不能遗漏，也不能重复。phase 目标权重为：

```text
target_weight_b,p = sum(weight_b,k), k in G_b,p
```

分组依据包括：

- 逐 cluster 热点函数及其动态比例；
- 算法语义，如 tree search、stencil、sort、hash、compression；
- 主要控制流形态；
- 整数/浮点/向量式计算特征；
- 指针追逐、规则流式访存或大工作集；
- cluster 间是否只是同一机制的不同时间实例。

当前 40 个通用 case 的分组由 `spec_cluster_compositions.json` 记录；`505.mcf_r`、`510.parest_r`、`605.mcf_s` 是专门 composite。所有 43 个 case 都有至少两个机制 phase。

### 8.3 当前映射规模

| 集合 | benchmark/case | 源 cluster | 每项 cluster | 2-phase case | 3-phase case |
|---|---:|---:|---:|---:|---:|
| Rate | 23 | 102 | 2–5 | 14 | 9 |
| Speed | 20 | 93 | 3–5 | 13 | 7 |
| 合计 | 43 | 195 | 2–5 | 27 | 16 |

43 个 benchmark 对应 43 个独立 case；Rate/Speed 不共享 ELF、权重或结果。多个 case 可以复用通用机制函数库，但每个 benchmark 的入口、phase 组合、循环次数、权重校准和最终 ELF 身份仍独立。

### 8.4 动态份额校准

设 composite 中 phase `p` 实测退休指令为 `R_p`，所有机制 phase 总退休指令为 `R`：

```text
measured_share_p = R_p / R
error_p = abs(measured_share_p - target_weight_p)
```

生产门禁要求每个 phase 的误差不超过 0.5 个百分点。full 模式中的 footprint 脚手架位于 phase 之外，不参加机制权重分母，但会进入整个 ROI 和工作集；其动态指令占比另受上限约束。

这里校准的是 **动态指令份额**，不是 cycles、cache misses 或 IPC 份额。不能因为动态份额匹配，就断言微结构事件也与原 SPEC 完全匹配。

### 8.5 quick 与 full

| 模式 | 目标 | 当前实测范围 | 主要用途 |
|---|---|---:|---|
| quick | 低成本回归，尽快暴露分支、发射、依赖和执行流水问题 | 18,823–548,331 条 ROI 指令 | 每次 RTL 修改后的轻量筛选 |
| full | 放大稳定阶段并加入较大工作集 | 440,494–609,048 条 ROI 指令 | cache、访存层次、完整机制组合与最终比较 |

full 的 64 B cache-line 工作集实测为 131,776–594,944 B。各 case 的 warmup、ROI、工作集和容差由 `spec_kernel_profiles.json` 冻结，中文表见 `SPEC_KERNEL_PROFILES.md`。

quick 和 full 是同一 benchmark composite 的两个 profile，通常会生成 profile 对应的 ELF。严格同一性要求是：**某个 profile 的程序特征统计与该 profile 的 RTL 仿真必须使用完全相同的 ELF**；不能把 quick 的特征与 full 的 RTL 结果混合。

### 8.6 L2+ 能保留与不能保留的内容

| 维度 | L2+ 保留程度 | 说明 |
|---|---|---|
| 主要机制类型 | 中到高 | phase 根据真实 cluster 热点和算法语义构造 |
| cluster 总权重 | 高 | 转成 phase 动态指令目标并校准 |
| 指令总规模 | 人工约束 | quick/full 固定到可承受范围，不是原 interval 的 1 亿条 |
| 指令级控制流 | 低到中 | 代理实现，不是原 ELF 的路径 |
| 指令 mix | 中 | 可通过特征工具继续校验，但不保证逐项等价 |
| 地址流与 reuse distance | 低到中 | full 放大工作集，但不是原 SPEC 地址轨迹 |
| 跨阶段 cache/预测器历史 | 低 | composite 的顺序是人工安排 |
| OS、syscall、动态链接行为 | 基本不保留 | bare-metal 环境 |
| 原程序数据依赖 | 低到中 | 只保留机制代理，不是原数据结构状态 |

因此 L2+ 最适合回答：

> 同一个 C910 RTL 上，某项微结构修改是否普遍改善这些已知机制负载，改善来自哪些 stall/miss/flush 指标？

它不适合独立回答：

> 真实 `505.mcf_r` 的 CPI 是多少，或者 C910 的 SPEC CPU2017 分数是多少？

## 9. 程序动态特征与 RTL 性能指标如何结合

### 9.1 两类数据分别回答什么

程序特征先描述 workload：

- 整数、浮点、load、store、branch 等动态指令比例；
- 条件/无条件/间接/call/return 分支构成；
- taken 比例、方向、目标距离和分支规律；
- load/store 宽度、地址分布、工作集、reuse 和 stride；
- 基本块大小、热点集中度、函数和 phase 构成；
- ILP、数据依赖距离和可能的执行端口需求。

RTL 指标再描述处理器响应：

- IPC、零退休周期、每周期退休宽度分布；
- 前端供给不足、I-cache/ITLB、取指气泡；
- 分支预测错误、redirect/flush 及恢复周期；
- rename/ROB/IQ/LSQ 等结构满导致的反压；
- IQ not-ready 的源操作数类型和等待生产者；
- 执行单元占用、端口冲突、长延迟操作；
- D-cache/DTLB miss、load replay、store-load 冲突；
- 各类 latency histogram 和关键路径等待时间。

### 9.2 正确的归因逻辑

一个可靠结论至少要形成以下证据链：

```text
程序特征提出机制假设
  -> RTL 指标证明瓶颈事件确实频繁
  -> 周期级分解证明该事件造成可见停顿
  -> 单变量微结构实验改变该机制
  -> IPC/周期改善且对应事件同步下降
  -> 多 benchmark 检查收益、回归和面积/时序代价
```

例如“branch 比例高”只说明预测器值得观察。只有同时看到 mispredict/ki 明显、redirect 后零退休周期多、改进预测器后 mispredict 与总周期一起下降，才可以把它归因为分支预测瓶颈。

### 9.3 不要把相关性当因果

- Frontend stall 与 backend stall 可能同周期重叠，不能直接相加得到总空闲比例。
- D-cache miss 增加可能由工作集变大导致，也可能因错误路径、prefetch 或 replay 放大。
- IQ not-ready 可能等 load、乘除法、浮点、CSR 或前序指令；只看一个总数不能定位生产者。
- 分支 mispredict 会同时降低前端有效供给、清空在途指令并改变 cache 流量。
- IPC 改善可能来自编译后 ELF 变化，因此必须先校验 ELF SHA 和 retired boundary。

## 10. 本项目 L3：真实代表区间 checkpoint/restore

### 10.1 L3 的目标

L3 不再用手写 composite。它对每个真实 SimPoint cluster：

```text
把全局 interval 转成具体 SPEC command 内的动态坐标
  -> 在 QEMU user-mode 捕获寄存器和 resident memory
  -> 打包 checkpoint 并记录 SHA
  -> 用 QEMU restore/replay 校验终点状态
  -> 在 C910 RTL 建立 Sv39 页表并恢复 U-mode
  -> warmup
  -> 测量固定 ROI
  -> 按真实 cluster weight 汇总
```

这才是“多 SimPoint 加权的真实 SPEC RTL 代表区间”应采用的方向。

### 10.2 已实现能力

当前代码可以捕获和验证：

- PC、32 个 GPR、32 个 FPR、FCSR；
- 低地址 guest virtual memory map 和 resident pages；
- 堆、栈、TLS、loader 和共享库已映射页；
- checkpoint、warmup、ROI 的动态指令坐标；
- checkpoint 到 ROI 结束间的 syscall；
- ELF、command、manifest 和捕获来源；
- QEMU restore 后 66 项架构状态终点比较；
- RTL Sv39 页表、C910 内存属性、U-mode 恢复和 ROI 计数。

### 10.3 当前 L3 状态

冻结 plan 当前包含 41 个 benchmark、186 个 region，其中 39 个 benchmark、178 个 region 可进入默认捕获。主要未解决项包括：

- `500.perlbench_r`、`600.perlbench_s` 的 fork/多地址空间 checkpoint；
- plan 中尚未纳入 `621.wrf_s`、`638.imagick_s`；
- 32 MiB RTL SRAM 对 resident memory 的限制；
- warmup/ROI 内 syscall 必须为 0；
- 大量 ref SimPoint 位于数千亿指令之后，捕获时间很长。

已完成一次 `505.mcf_r` 的小区间端到端 smoke：QEMU 重放 1001 条、66 项状态无差异，RTL warmup 105 条并测量 900 条 ROI。它只证明恢复链路闭环，900 条指令 CPI 不能代表 `505.mcf_r`。

### 10.4 L3 仍需完成什么

要把 L3 结果用于正式体系结构结论，至少还需要：

1. 解决全部目标 benchmark 的捕获可达性；
2. 对每个必需 cluster 生成 checkpoint package；
3. 证明 resident memory、syscall 和 TB 边界全部过门禁；
4. 用足够长 warmup 并做 cache/TLB/预测器收敛实验；
5. 对每个代表区间执行有统计意义的 RTL ROI；
6. 验证无 trap、无未知态、retired 边界正确；
7. 缺任一必需 cluster 时拒绝发布 benchmark 加权值；
8. 与完整 QEMU/更长采样或可行的小输入全量 RTL 做误差交叉验证。

详细命令和恢复格式见 `spec_flow/SPEC2017_L3_CHECKPOINT.md`。

## 11. 当前状态：什么已完成，什么未完成

### 11.1 L1 严格矩阵

写作时运行 `./spec_flow/check_l2plus_status.sh` 的结果为：

| suite | input | 通过 | 总数 | 状态 |
|---|---|---:|---:|---|
| Speed | test | 20 | 20 | 完成 |
| Speed | train | 20 | 20 | 完成 |
| Speed | ref | 19 | 20 | 缺 `638.imagick_s/ref` |
| Rate | test | 23 | 23 | 完成 |
| Rate | train | 23 | 23 | 完成 |
| Rate | ref | 23 | 23 | 完成 |
| 合计 | test/train/ref | 128 | 129 | 99.2% |

这里的“通过”不是只检查文件存在，而是严格验证 benchmark/size 身份、完整程序标志、1 亿 interval、maxK、SPEC compare、SimPoint、权重和、产物、模块地址交集、编译选项、provenance、ID 唯一性和 command 范围等。

### 11.2 L2+ 资产状态

| 项目 | 当前状态 | 说明 |
|---|---|---|
| 43 个 benchmark 独立映射 | 已有 | 23 Rate + 20 Speed，不共享 case |
| 2–3 phase 机制组合 | 已有 | 共承接 195 个源 cluster |
| quick/full profile 契约 | 43/43 已有 | 记录指令、warmup、工作集与容差 |
| ref 绑定 | 42/43 | `638.imagick_s` 暂时使用 train |
| 历史 quick/full feature 目录 | 存在 | 目录存在不等于最终干净证据通过 |
| 最终 43-case full RTL evidence | 未发现符合命名与门禁的结果目录 | 尚不能宣布 L2+ 最终完成 |
| `SPEC2017_L2PLUS_FINAL_VALIDATION.md` | 当前不存在 | 尚无 `errors=0` 最终验收证明 |

### 11.3 何时才算 L2+ 完成

必须同时满足：

```text
strict SimPoint matrix = 129/129
43 个 benchmark 全部绑定自身 ref manifest SHA-256
quick feature evidence = 43/43
full feature evidence = 43/43
full PERF_DETAIL RTL TEST PASS = 43/43
feature ELF 与 RTL ELF 逐 case 完全一致
retired instruction boundary 通过
详细计数器无缺项、无伪造为 0 的 X/Z
Git commit、dirty 状态、simv 与 compile log provenance 通过
SPEC2017_L2PLUS_FINAL_VALIDATION.md errors = 0
```

静态 Markdown 状态、旧 summary、目录数量或后台进程结束都不能替代以上门禁。

## 12. 实际操作手册

### 12.1 进入容器并检查工具

在 host：

```bash
cd smart_run
make docker-create
make docker-start
make docker-deps
make docker-shell
```

在容器 `/work`：

```bash
./spec_flow/smoke_tools.sh
make -C tools/qemu-plugins
make -C tools/qemu-plugins check-fork
```

### 12.2 安装 SPEC

ISO 预期位置：

```text
/work/CPU 2017 1.0.5.iso
```

安装：

```bash
./spec_flow/install_spec2017.sh
```

主要目录：

```text
spec2017_iso/  ISO 展开目录
spec2017/      SPEC 安装树
spec_runs/     QEMU、BBV、SimPoint 和 manifest 产物
```

### 12.3 先验证普通 QEMU 执行

```bash
./spec_flow/run_spec_qemu.sh 505.mcf_r test run
```

这一步用于排除编译、动态链接、输入和 SPEC compare 问题，不生成 SimPoint。

### 12.4 收集单个 L1 画像

```bash
./spec_flow/run_bbv_simpoint.sh 505.mcf_r ref 5 100000000
```

参数依次为：

```text
benchmark  input-size  maxK  interval-instructions
```

调试可以先用 test，但研究画像应优先 ref。不要把 `BBV_MAX_INTERVALS` 的截断运行误当成 full-program 画像；严格门禁会拒绝它。

### 12.5 批量运行

Rate 单一输入：

```bash
./spec_flow/run_representative_batch.sh test 5 100000000
```

Speed 单一输入：

```bash
./spec_flow/run_representative_batch.sh --suite speed test 5 100000000
```

多输入：

```bash
./spec_flow/run_spec2017_simpoint_sizes.sh --suite all "train ref" 5 100000000
```

恢复全矩阵并行任务：

```bash
L2PLUS_WORKERS=8 ./spec_flow/run_l2plus_parallel.sh
```

顺序后备：

```bash
./spec_flow/run_l2plus_remaining.sh
```

这些命令只涉及 QEMU/SPEC/SimPoint。RTL/VCS/DC 等 EDA 命令仍应在已授权的非沙箱环境单独运行。

### 12.6 检查实时状态

完整矩阵：

```bash
./spec_flow/check_l2plus_status.sh
```

单 case 严格检查：

```bash
./spec_flow/check_l2plus_case.py 505.mcf_r ref
```

画像质量：

```bash
python3 spec_flow/check_profile_quality.py --suite rate --size ref
python3 spec_flow/check_profile_quality.py --suite speed --size ref
```

最终门禁：

```bash
python3 spec_flow/validate_l2plus.py \
  > spec_flow/SPEC2017_L2PLUS_FINAL_VALIDATION.md
```

当前该命令应当失败，直到 L1 为 129/129、映射全部 ref-bound 且最终 RTL evidence 完整。失败是门禁正常工作，不应通过放宽参数把它包装成完成。

### 12.7 查看一个 benchmark 的 SimPoint

```bash
BENCH=505.mcf_r
SIZE=ref
DIR=spec_runs/${BENCH}_${SIZE}_c910

cat "$DIR/${BENCH}_${SIZE}.simpoints"
cat "$DIR/${BENCH}_${SIZE}.weights"
jq '{bench,size,interval,max_k,collection,counts,validation,simpoints}' \
  "$DIR/manifest.json"
```

检查权重和：

```bash
awk '{sum += $1} END {printf "weight_sum=%.9f\n", sum}' \
  "$DIR/${BENCH}_${SIZE}.weights"
```

查看逐 cluster 热点：

```bash
column -s, -t < "$DIR/${BENCH}_${SIZE}.function_profile.csv" | less -S
```

### 12.8 运行 composite 程序特征或 RTL

列出 43 个 case：

```bash
./spec_flow/run_composite_rtl.sh --suite all --list
```

只统计程序动态特征：

```bash
./spec_flow/run_composite_rtl.sh \
  --suite all --profile quick --features-only \
  --tag spec2017_composite_quick_features
./spec_flow/run_composite_rtl.sh \
  --suite all --profile full --features-only \
  --tag spec2017_composite_full_features
```

只执行 RTL：

```bash
./spec_flow/run_composite_rtl.sh \
  --suite all --profile quick --rtl-only \
  --tag spec2017_composite_quick_rtl
./spec_flow/run_composite_rtl.sh \
  --suite all --profile full --rtl-only \
  --tag spec2017_composite_full_rtl
```

`--profile` 省略时默认是 quick。features 与 RTL 分开执行时，必须保持 suite、profile、case 列表和源码提交一致；最终发布更推荐使用联合模式或最终证据入口，让脚本自动校验 ELF SHA。

完整 L2+ 最终证据入口：

```bash
./spec_flow/run_l2plus_final_evidence.sh
```

最后一个命令会要求干净 Git、严格 129/129，并生成同提交的 quick/full features 和 full `PERF_DETAIL` RTL 证据。它包含 EDA 仿真，必须在符合项目授权要求的非沙箱环境执行。

### 12.9 中断恢复

若 BBV 全部收集完成，但 shell 在 compare/SimPoint/manifest 阶段中断：

```bash
./spec_flow/finalize_existing_bbv.sh 505.mcf_r ref 5 100000000
```

自动观察并恢复可安全后处理的 partial：

```bash
L2PLUS_RECOVERY_WATCH=1 ./spec_flow/recover_l2plus_partials.sh
```

恢复器会避开仍有活跃 QEMU/collector 的 case，并复用同一 case lock，避免把半个多 command 画像误判为完整。

## 13. 如何判断一个 SimPoint 结果可信

### 13.1 单 case 最低检查表

- benchmark 和 input size 与目录名一致；
- SPEC compare 通过；
- `collection.full_program=true`；
- interval 为 100,000,000，maxK 为 5；
- `.bb` 非空且 interval 数合理；
- `.simpoints` 与 `.weights` 非空；
- cluster ID 唯一且两文件集合一致；
- weight sum 接近 1；
- `.bb.map` ID 唯一；
- `.bb.cmdmap` 范围连续且覆盖最大 ID；
- 每条 command 的 PC 与至少一个 module 范围相交；
- weighted external unknown 比例在门槛内；
- 编译器、QEMU、SimPoint 和 Git provenance 可追溯。

### 13.2 benchmark 代表性检查

严格格式通过仍不等于抽样误差足够小。研究中还应检查：

1. `maxK=5` 是否足以覆盖该 benchmark 的阶段多样性；
2. 改变 random seed 或 K 后，代表阶段与权重是否稳定；
3. interval 从 100M 改为 10M/50M/200M 时，阶段是否发生根本变化；
4. 代表区间热点是否能解释全局热点；
5. 对可完整模拟的小输入，SimPoint 加权结果与全量结果误差多大；
6. warmup 从 1M、5M、10M、20M 增长时，CPI/miss/mispredict 是否收敛；
7. 不同代表区间的关键指标方差和置信区间是否可接受。

当前项目的 L1 validator 主要保证 **数据完整性和来源一致性**；它不自动给出统计误差上界。

### 13.3 L2+ 额外检查

- 每个源 cluster 恰好进入一个 phase；
- phase target weight 等于所含 cluster 权重和；
- quick/full 各 phase 动态份额误差不超过 0.5 个百分点；
- footprint 不参与机制权重且占比不过大；
- feature 和 RTL 使用同一 profile、同一 ELF SHA；
- RTL retired 指令与 profile 契约一致；
- 所有 case `TEST PASS`，detail rows 数量符合构建版本；
- X/Z 被记录为 unknown/null，不能转成 0；
- 优化前后使用同一 workload ELF、相同 ROI 和相同仿真器配置。

### 13.4 L3 额外检查

- checkpoint 的 ELF、command、input、manifest SHA 完全一致；
- checkpoint 坐标与目标 SimPoint 的 TB 误差受限；
- 内存页和权限完整，resident size 未超限；
- restore 窗口不存在不支持 syscall；
- QEMU replay 的 PC/GPR/FPR/FCSR 终点一致；
- warmup 足够且已做收敛实验；
- 每个必需 cluster 都有有效 RTL 结果；
- 聚合没有使用 `--allow-partial` 的残缺结果。

## 14. 常见失败与排查顺序

### 14.1 `compare_failed`

依次检查：

1. `runsetup.log` 是否构建和生成输入成功；
2. `qemu_bbv.log` 中每条 command 的退出码；
3. 动态 linker/sysroot 是否匹配；
4. `compare.log` 中是哪一个输出文件失败；
5. 是否错误使用了截断 BBV，却仍尝试正式 compare；
6. benchmark 是否包含 wrapper/fork 特殊路径。

程序输出不正确时，任何 BBV 和 SimPoint 都不能用于性能研究。

### 14.2 有 `.bb` 但没有 manifest

这通常表示收集完成后，compare、SimPoint 或函数归因阶段被中断。先确认没有活跃进程，再使用 `finalize_existing_bbv.sh`，不要立即重跑数小时的 BBV。

### 14.3 SimPoint 输出为空

- 只有一个 interval 时，脚本会写 interval 0、weight 1 的显式 fallback；
- 多个 interval 仍无输出时应检查 `simpoint.log`、BBV 格式、磁盘和工具版本；
- 不要手写伪造 `.simpoints` 让 validator 通过。

### 14.4 unknown 函数比例高

检查 `.bb.modules` 是否存在、固定 VA 是否启用、模块范围是否与 `.bb.map` PC 重叠。旧 ASLR 画像应通过 module recovery 流程重建函数归因。已知 stripped module 的 unresolved 符号和完全未知地址要分开处理。

### 14.5 多 command ID 冲突

检查 `.bb.cmdmap` 的下一条 `start_id` 是否等于上一条 `end_id + 1`，以及 `.bb.map` 是否有重复 ID。此错误会把不同程序地址折叠到同一 BBV 维度，不能靠重新跑 SimPoint 修复，必须重新收集或正确 compact。

### 14.6 长时间运行看似卡死

BBV 插件会在每个 TB 执行时更新计数，ref 画像可能耗时很长。判断是否正常应看：

- QEMU 进程 CPU 使用率是否持续非零；
- `.bb` 是否随 interval 完成而增长；
- `qemu_bbv.log` 当前 command；
- 可用磁盘是否高于调度器 500 GiB guard；
- 是否存在多个调度器争抢同一 case lock。

CPU 长时间接近 0 且日志不增长，才更像阻塞；不要高频轮询大型文件。

### 14.7 为什么 `638.imagick_s/ref` 特别重要

当前 `638.imagick_s` composite 暂时基于 train：4 个 cluster 中 morphology 权重约 99.838%，frame transform 约 0.162%。在 ref 完整画像完成前，不能假设 ref 有相同阶段和权重。它是 L1 129/129、43/43 ref-bound 和最终 L2+ 发布的唯一剩余画像阻塞项。

## 15. 研究中应该怎样使用这套数据

### 15.1 日常微结构优化

建议采用以下层级：

```text
少量针对性 microbenchmark
  -> 43-case quick 中与机制相关的子集
  -> quick 全量检查回归
  -> full 中相关 case
  -> full 43-case 全量
  -> 面积、时序、功耗代价
  -> 有条件时用 L3 真实区间复核
```

每次实验只改变一个主要机制或清楚记录多个改动。结果至少保存：Git commit、编译参数、仿真器 SHA、workload ELF SHA、cycles、retired instructions、IPC、关键事件率、面积和时序。

### 15.2 如何选择 case

不要只按 benchmark 名称选择，应从 `SPEC_CLUSTER_COMPOSITIONS.md` 查看机制：

- 分支预测：tree search、regex、opcode dispatch、combinatorial search；
- load-use/指针追逐：mcf pricing tree、compiler graph、event queue、DOM/object；
- D-cache/工作集：lbm、stencil、image、compression dictionary；
- 浮点吞吐和延迟：bwaves、cactuBSSN、fotonik3d、roms、nab；
- 整数执行和比较：x264、xz、exchange2、gcc bitmap；
- 间接跳转和前端：perl opcode、C++ virtual dispatch、large instruction footprint。

选择后必须再看实际程序特征，确认代理 ELF 确实呈现预期指令 mix、branch 和 memory 行为。

### 15.3 结果如何对外表达

L2+ 报告建议包含：

```text
OpenC910 RTL version / Git SHA
composite profile = quick or full
43-case or selected-case list
program feature source and ELF SHA
RTL simulator/configuration
baseline vs optimization normalized cycles/IPC
关键计数器变化
面积、频率和功耗代价
明确声明：SimPoint-guided SPEC-like bare-metal proxy, not official SPEC
```

L3 报告还应增加：interval、cluster、weight、checkpoint SHA、warmup、ROI、状态重放验证和加权公式。

## 16. 文件与脚本索引

### 16.1 权威配置和数据

| 文件 | 角色 |
|---|---|
| `spec_flow/spec2017_kernel_map.json` | 23 个 Rate benchmark 到独立 composite 的映射 |
| `spec_flow/spec2017_speed_kernel_map.json` | 20 个 Speed benchmark 到独立 composite 的映射 |
| `spec_flow/spec_cluster_compositions.json` | 通用 case 的 cluster、热点与机制分组 |
| `spec_flow/spec_kernel_profiles.json` | 43 个 quick/full 指令、warmup、工作集契约 |
| `spec_runs/*/manifest.json` | 每个 L1 benchmark/input 的来源和严格状态 |
| `spec_checkpoints/l3_plan.json` | L3 checkpoint region 冻结计划 |

JSON 是机器可读权威输入；Markdown 表格便于阅读，但最终状态仍必须由 validator 重算。

### 16.2 主要生成与校验脚本

| 脚本 | 作用 |
|---|---|
| `run_bbv_simpoint.sh` | 单 benchmark 完整 BBV、SimPoint、函数画像和 manifest |
| `run_representative_batch.sh` | 单 suite/input 批量画像 |
| `run_l2plus_parallel.sh` | 129 矩阵并行补齐 |
| `analyze_bbv_functions.py` | TB/模块/符号到函数热点归因 |
| `make_simpoint_manifest.py` | 生成单 case provenance manifest |
| `check_l2plus_case.py` | 单 case 严格校验 |
| `check_l2plus_status.sh` | 129 矩阵实时状态 |
| `check_profile_quality.py` | 函数归因和 unknown coverage 质量 |
| `calibrate_kernel_map.py` | 将 ref cluster 权重绑定到 composite 实测份额 |
| `run_spec_kernel_profiles.sh` | 构建和测量 quick/full profile |
| `run_composite_rtl.sh` | 43 个 composite 的 features/RTL 入口 |
| `run_l2plus_final_evidence.sh` | 干净提交上的最终证据流水线 |
| `finalize_l2plus.sh` | 校准、聚合、验证和事务化发布 |
| `validate_l2plus.py` | L1、映射、features、RTL 的最终总门禁 |
| `l3_checkpoint_plan.py` | 把全局 SimPoint 转换为 command 内坐标 |
| `l3_run_probes.py` | QEMU 捕获 checkpoint/ROI 状态 |
| `l3_generate_restore.py` | 生成 QEMU/RTL restore ELF 和页表 |
| `l3_run_rtl.py` | L3 单 region RTL 执行与解析 |
| `aggregate_l3_results.py` | 按真实 SimPoint 权重汇总 L3 |

### 16.3 阅读顺序

要完整理解项目，建议按以下顺序阅读：

1. 本文：建立总体方法和准确性边界；
2. `spec_flow/README.md`：查看最新运行命令；
3. `SPEC_CLUSTER_COMPOSITIONS.md`：理解 43 项的机制来源；
4. `SPEC_KERNEL_PROFILES.md`：理解 quick/full 规模；
5. 单项 `spec_runs/.../manifest.json`：确认真实画像证据；
6. `SPEC2017_L3_CHECKPOINT.md`：理解真实 checkpoint/restore 实现；
7. `validate_l2plus.py` 与最终 validation report：理解何时可以宣布完成。

## 17. 容易混淆的问题

### 17.1 “一个 benchmark 一个 kernel”是否等于只采了一个 SimPoint？

不是。当前 43 个 composite 每项接收该 benchmark 的全部 2–5 个源 cluster，再把相近 cluster 合并成 2–3 个机制 phase。一个 ELF 是部署形式，不代表只有一个 SimPoint。

### 17.2 一个 composite 内已经有多个 phase，为何 RTL 后不再加权？

因为权重已经通过循环次数嵌入该 ELF 的动态指令组成。RTL 运行的是整个 composite，得到一个整体 cycles/retired/事件集合。若再按 phase 权重对整体结果加权，会重复加权。

### 17.3 这是不是 SimPoint 的通行标准做法？

不是。标准做法是分别运行原程序的真实代表 interval，再按 weight 汇总。L2+ 是本项目在 checkpoint/restore 成本过高时采用的代理方法。它比“每个 benchmark 随便选一个小 kernel”严谨，但仍是 approximation。

### 17.4 为什么既要 test/train，又要 ref？

test/train 用于功能和流程验证，也可以揭示输入变化导致的阶段变化；正式性能代表性应以 ref 为主。它们不是先后训练同一个 SimPoint 模型的三个步骤，各自都会产生独立完整画像。

### 17.5 SimPoint 权重是时间权重还是指令权重？

本项目按固定动态 guest 指令 interval 画像，cluster weight 主要反映完整执行中的指令区间占比，不是墙上时间占比。不同微结构每条指令耗时不同，所以最终通过加权 CPI 转成性能，而不是把 QEMU host 时间作为权重。

### 17.6 QEMU 收到的 BBV 能预测 C910 IPC 吗？

不能直接预测。BBV 主要反映代码使用比例，且对 ISA 与二进制敏感、对目标微结构相对独立。必须把代表 workload 放到 RTL 或可靠的 C910 性能模型上，才能得到 IPC、miss 和 stall。

### 17.7 热点函数等于瓶颈函数吗？

不等于。热点表示动态指令多；瓶颈还取决于每条指令的延迟、cache miss、依赖链、分支错误和并行度。一个只占 5% 指令的函数可能制造大量长延迟 miss，也可能决定总周期。

### 17.8 full 只有约 50 万条，为何还能研究 cache？

full 通过放大机制循环和至少 128 KiB 的显式工作集，让 RTL 在可承受时间内观察稳定 cache/访存行为。它足以做许多相对机制实验，但仍远小于标准 1 亿条 SimPoint ROI，也不能完整再现 SPEC 的长程 reuse、页行为和 OS 交互。

### 17.9 128/129 是否表示整个项目已完成 99.2%？

只表示 L1 的 benchmark/input 严格画像矩阵完成 99.2%。它不代表 L2+ 最终 RTL evidence 或 L3 checkpoint campaign 完成 99.2%。不同层次必须分别报告。

## 18. 下一步最合理的技术路线

### 18.1 近期：完成并冻结 L2+

1. 完成 `638.imagick_s/ref` 全程序 BBV、SimPoint、函数画像和严格 manifest；
2. 用 ref 重建该 case 的 cluster 分组和动态份额；
3. 重新校准 43 个 map，绑定 exact ref manifest SHA；
4. 在干净提交上生成 43/43 quick features；
5. 生成同提交、同 ELF 的 43/43 full features 与 PERF_DETAIL RTL；
6. 运行最终 validator，直到 `errors=0`；
7. 冻结该版本为后续微结构优化的唯一 baseline。

### 18.2 中期：量化 L2+ 的代理误差

选择若干覆盖不同机制的 benchmark：

- branch/control：perlbench、deepsjeng、exchange2；
- pointer/memory：mcf、omnetpp、xalancbmk；
- streaming/stencil：lbm、bwaves、cactuBSSN；
- FP/transcendental：cam4、fotonik3d、roms；
- compression/integer：xz、x264、gcc。

对这些 benchmark 完成少量真实 L3 region，比较 L2+ 与 L3 的：指令 mix、branch MPKI、cache MPKI、stall 构成、CPI 排序和微结构优化收益方向。L2+ 不需要绝对值完全一致，但至少应证明它不会频繁给出相反的优化结论。

### 18.3 长期：把 L3 提升为正式代表区间平台

优先解决：

1. fork 和多地址空间恢复；
2. 动态内存容量扩展或可验证的外部内存模型；
3. syscall 重放/代理，而不是只允许零 syscall；
4. cache/TLB/预测器状态 warmup 收敛；
5. 批量 checkpoint 捕获、去重和调度；
6. 代表区间的统计误差与多 seed 稳定性；
7. RTL 结果、面积、时序与 Git provenance 的自动发布。

## 19. 最终掌握标准

当能够独立回答以下问题时，才算真正掌握这套流程：

1. 为什么 BBV 使用动态指令比例，而不是函数运行时间？
2. interval、cluster、SimPoint 和 weight 分别是什么？
3. 为什么代表点必须是 cluster 中的真实 interval？
4. 为什么不能直接加权 IPC 或直接平均 miss rate？
5. 为什么 SimPoint 仍需要 checkpoint 和 warmup？
6. 本项目 QEMU TB BBV 与标准 basic-block BBV 有何边界？
7. 多 command、动态库和 fork 为什么会破坏朴素 BBV 收集？
8. test/train/ref 与 Rate/Speed 分别代表什么？
9. L2+ 如何把全部 cluster 互斥、完备地映射到 2–3 个 phase？
10. 为什么一个 composite ELF 不需要 RTL 后二次加权？
11. L2+ 保留了哪些特征，丢失了哪些真实程序行为？
12. 如何用程序特征和 RTL counter 构造因果瓶颈证据链？
13. 为什么 128/129 不等于 L2+ 或 L3 已完成？
14. 哪些 validator 和 provenance 证据是发布结果的必要条件？
15. 如何用少量 L3 真实区间量化 L2+ 的代理误差？

## 20. 参考资料

- SimPoint 官方 phase analysis：<https://cseweb.ucsd.edu/~calder/simpoint/phase_analysis.htm>
- SimPoint 2.0 工具说明：<https://cseweb.ucsd.edu/~calder/simpoint/simpoint-2-0.htm>
- SimPoint 方法综述：<https://cseweb.ucsd.edu/~calder/papers/SimPointChapter.pdf>
- SPEC CPU2017 Run and Reporting Rules：<https://www.spec.org/cpu2017/Docs/runrules.html>
- SPEC CPU2017 `runcpu` 文档：<https://www.spec.org/cpu2017/Docs/runcpu.html>
- SPEC 对脱离 `runcpu` 研究用法及 ref 抽样的说明：<https://www.spec.org/cpu2017/Docs/runcpu-avoidance.html>

外部资料定义标准方法和官方口径；本项目的实际参数、状态与证据始终以当前仓库脚本、manifest 和 validator 为准。
