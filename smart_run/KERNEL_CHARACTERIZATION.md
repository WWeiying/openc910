# Benchmark Kernel 动态特征统计

## 目标与边界

本流程量化 `perf_monitor_start` 退休之后到 `perf_monitor_end` 执行之前的程序动态特征。统计由相同 RISC-V ELF 在玄铁 QEMU 上进行架构态追踪，再离线分析指令流和虚拟地址流；它不依赖 C910 RTL 性能计数器，也不把处理器的 IPC、cache miss、分支预测失败或流水线停顿误认为程序固有特征。

程序特征报告应与 RTL 性能报告联合使用。例如，程序侧显示条件分支密集、两位 bimodal 代理失误率低，而 RTL 侧仍有较高分支恢复开销，才有证据继续检查 C910 预测器；程序侧工作集很小且全相联 miss-ratio 很低，而 RTL D-cache stall 很高，才应优先检查冲突、bank、端口、流水化或实现问题。

## 一次性运行

### 与 RTL 仿真串联

对一个 kernel 先统计程序特征，再执行原有 RTL 仿真并生成联合瓶颈筛查：

```bash
cd /home/wangwy/openproject/openc910/smart_run
make compile DUMP=off PERF_DETAIL=on
BENCH_CASES=spec_505_mcf_composite_kernel ./run_bench.sh --characterize mcf_joint
```

`--characterize` 默认使用 SPEC kernel `quick` profile 和程序特征 `rtl`
profile：特征阶段和 RTL 阶段使用相同 case 参数和编译环境，并分别归档
ELF。联合报告会比较两个 ELF 的 SHA256 和 Kernel 退休指令数。ELF 必须
精确匹配；由于 C910 最多三条指令同周期退休，而 QEMU 在单条 marker
边界截取；RTL 对 start/end 所在的两个三退休槽周期做整周期快照，因此
退休数允许最多 6 条保守边界偏差，超过即失败。特征阶段不再定义
`KERNEL_CHARACTERIZATION`；QEMU 插件在 `perf_monitor_end` 处结束追踪，
无需修改 marker 后的仿真结束代码，因此特征统计与 RTL 必须使用逐字节相同
的 ELF。

需要更长、更稳定，并与 full RTL 使用同一 ELF 的程序特征时：

```bash
BENCH_CASES=spec_505_mcf_composite_kernel ./run_bench.sh \
  --characterize --profile full mcf_full_joint
```

`--profile full` 自动令程序特征采集标签采用 `representative`；它不改变
SPEC 构建参数，kernel 的正式统计区间仍由 `perf_monitor_start/end` 唯一
确定，归档 ELF 必须与随后 full RTL 使用的 ELF 逐字节一致。

环境变量形式等价：

```bash
PROGRAM_FEATURES=on PROGRAM_FEATURE_PROFILE=rtl \
BENCH_CASES=spec_505_mcf_composite_kernel ./run_bench.sh mcf_joint
```

同一结果目录中会增加：

| 文件 | 内容 |
|---|---|
| `program_features/` | QEMU 架构态动态特征、ELF、trace、CSV/JSON 和校验报告 |
| `program_features.log` | 特征阶段完整日志 |
| `<case>.elf` | RTL 仿真实际使用的 ELF |
| `simv` / `simv.daidir/` | 本结果集顺序/并行仿真实际执行的完整 VCS 模拟器 bundle |
| `simv.daidir.sha256` | 生成共享库和运行时数据库的逐文件 SHA256 清单 |
| `comp.vcs.log` | 本结果集实际使用的 VCS 编译日志 |
| `run.info` | `simv`/编译日志 SHA256、`PERF_DETAIL` 状态、Git 与 profile provenance |
| `PROGRAM_RTL_BOTTLENECK.md` | 程序需求与 RTL 响应的联合瓶颈候选排序 |
| `COMPOSITE_MIX_VALIDATION.md` | 从本次 ELF 的动态函数指令数重算 composite 内部份额，并与 SimPoint 目标权重比较 |

如果程序特征阶段失败，流程会在启动 RTL 仿真前退出，避免拿不完整或错误的特征继续关联。`PERF_DETAIL=on` 必须在编译 `simv` 时启用；否则联合报告只能使用 IPC、基础 cache miss、分支失误和 frontend/backend stall。

对带 `composition` 元数据的 SPEC case，`run_bench.sh --characterize`
还会在 RTL 前执行 `spec_flow/validate_composite_features.py`。内部机制
实测动态指令份额与 ref cluster 目标默认不得相差超过
`0.5` 个百分点，以防止源码或编译选项变化后沿用过期配比。

### SPEC quick/full 统一 profile

Rate/Speed 共 43 个 benchmark 分别映射为 43 个独立 RTL case。每个 benchmark
只运行一个完整 ELF；同一 benchmark 的程序动态特征统计和 RTL 仿真使用同一
case，而 Rate/Speed 之间不共享 case、ELF、配比或实测结果。43 个 case 均具有：

- `quick`：短 ROI，用于分支、发射、依赖和执行流水线快速回归；
- `full`：44.0 万至 60.9 万条 ROI 指令，工作集 131,776 至 594,944 B，
  用于更稳定的程序特征及 L1 之外的存储层次压力；
- 独立 `perf_warmup_start/end` 和 `perf_monitor_start/end`，warmup 不计入 ROI；
- 机器可读的实测指令数、warmup、工作集和 footprint 占比契约。

证据强度分为两类，不能与真实 checkpoint 混用。`spec_505_mcf_composite_kernel`、
`spec_605_mcf_composite_kernel` 和 `spec_510_parest_composite_kernel` 是
`simpoint-composition`：内部包含多个机制，并已把动态机制份额校准到
SimPoint cluster 权重。其余 40 个是 `simpoint-cluster-composition`：将每个
benchmark 自身的多个 cluster 按热点函数和机制语义合并为 2 至 3 个 phase，
并在一个 ELF 内校准。39 项使用各自 ref profile；`638.imagick_s` 的 ref
全程序画像仍在生成，当前仅该项临时使用自身 train profile。43 项 quick/full
实测权重误差均不超过 0.5 个百分点。

40 个统一 phase-marker full ELF 含 128 KiB footprint 脚手架，用于产生存储层次压力。
它位于 monitor ROI 内但在所有 composition phase 之外，因此计入总动态
指令和工作集，不污染 SimPoint 机制权重；实测占总 ROI 的约 4.7% 至 6.5%，
契约上限为 10%。

43 个 case 的逐项 ROI、warmup、工作集、SPEC 映射和校准级别见
`spec_flow/SPEC_KERNEL_PROFILES.md`，机器可读源为
`spec_flow/spec_kernel_profiles.json`。完整程序特征分别位于
`smart_run/kernel_features/spec_all_43_quick_final/` 和
`smart_run/kernel_features/spec_all_43_full_final/`，两个目录的 43 项 profile
契约校验均通过。

43 是 benchmark-local case/ELF 数量，不等于正式 SPEC 代表区间数量。完整
quick/full 特征签名不存在等价组，但它们仍是 SimPoint 指导的 bare-metal
代理，不是从 SPEC checkpoint 恢复的原程序区间。

三个 composition case 当前 quick RTL 校准结果为：

| case | QEMU/RTL 指令 | RTL cycles | IPC | 本机单项流程时间 |
|---|---:|---:|---:|---:|
| `spec_505_mcf_composite_kernel` | 19,707 / 19,708 | 25,949 | 0.759 | 约 120 s |
| `spec_605_mcf_composite_kernel` | 19,188 / 19,188 | 25,113 | 0.764 | 约 134 s |
| `spec_510_parest_composite_kernel` | 108,350 / 108,347 | 68,206 | 1.589 | 约 306 s |

三项 QEMU/RTL 差值分别为 -1、0 和 +3，均处于同周期退休边界的 6 条
容差内。上述时间包含该 case 的构建、VCS 和报告归档，仅用于当前主机
量级估计；三个 quick 顺序回归总计约 560 s。

两版本使用相同的 GCC 基线选项
`-O2 -mtune=c910 -march=rv64imafdcxtheadc -mabi=lp64d`，只通过编译期
规模、轮数和 warmup 宏改变 workload，避免把编译优化差异混入对比。

所有 profile 都是 bare-metal 代理，不是 SPEC CPU2017 原程序的真实代表
区间或 checkpoint/restore。它们可用于微结构机制研究和同版本相对比较，
不能作为正式 SPEC 分数。

只收集 full 程序特征，不启动 EDA：

```bash
cd /home/wangwy/openproject/openc910
./spec_flow/run_spec_kernel_profiles.sh --profile full --features-only \
  --tag spec_all_full_features
```

执行全部 43 个 quick 的程序特征加 RTL 联合回归：

```bash
./spec_flow/run_spec_kernel_profiles.sh --profile quick \
  --tag spec_all_quick_joint
```

中断后可使用完全相同的命令并增加 `--resume`。只有提交、profile、case
集合、`simv` 和编译日志完全一致，且单项 ELF、退休数、详细计数器及 PASS
状态全部通过校验的 case 才会跳过：

```bash
./spec_flow/run_spec_kernel_profiles.sh --profile full \
  --tag spec_all_full_joint --resume
```

多个 VCS case 可以隔离并行；case 构建仍串行使用共享 `work`，完成后才将
pattern、符号和 ELF 放入各自目录。所有 worker 使用同一个只读 `simv`：

```bash
./spec_flow/run_spec_kernel_profiles.sh --profile full \
  --tag spec_all_full_joint --rtl-workers 2 --resume
```

当前 43 项全部是多机制 calibrated case，因此 `--calibrated-only` 只为兼容
旧命令保留，当前不会缩小集合。full RTL 批量运行需要显著更长时间，建议先按
case 选择执行：

```bash
cd smart_run
BENCH_CASES=spec_505_mcf_composite_kernel \
  ./run_bench.sh --characterize --profile full --tag mcf505_full
```

默认自动发现 CoreMark、Dhrystone、全部 `bench_*` 和全部 `spec_*` case，并采用适合动态特征分析的运行规模：

```bash
cd /home/wangwy/openproject/openc910
./smart_run/run_kernel_characterization.sh --tag all_kernel_features
```

只运行指定 case：

```bash
./smart_run/run_kernel_characterization.sh --tag focused \
  coremark bench_branch spec_505_mcf_composite_kernel
```

按 RTL 默认 workload 参数进行校准，并在存在 summary 时比较退休指令数：

```bash
./smart_run/run_kernel_characterization.sh \
  --profile rtl \
  --tag rtl_calibration \
  --rtl-results smart_run/results/<result-directory> \
  spec_pop2_ocean_kernel
```

默认允许最多 6 条同周期退休边界偏差；可用
`--rtl-retired-tolerance 0` 要求数值完全相等。

`representative` 是默认 profile。SPEC kernel 的规模只由统一的
`SPEC_COMPOSITE_PROFILE=full` 参数控制，不再传入旧的逐 case
`SPEC_*_REPRESENTATIVE` 参数；CoreMark 执行 3 次完整算法迭代。特征构建
不再通过宏删除计时、打印或 testbench 结束写操作，QEMU 插件只按 marker
截取 ROI，因此 SPEC 特征统计与 RTL 可使用逐字节相同的 ELF。`rtl` profile
使用 quick 参数，适合逐 case 与同一 ELF 的 RTL 结果校准，不建议把很短的
quick kernel 当作唯一的程序特征样本。

该命令只执行软件构建、QEMU 功能运行和离线分析，不启动 VCS、Verilator、Icarus 或其他 EDA/RTL 仿真。

SPEC quick/full 的统一入口为：

```bash
./spec_flow/run_spec_kernel_profiles.sh --suite all --profile quick --list
```

入口对每个 benchmark 只选择一个 ELF，先统计该完整 ELF 的程序特征，再
运行整体 RTL。`--features-only` 和 `--rtl-only` 可分开执行两个阶段，
`--list` 显示映射得到的 43 个独立 case。full profile 自动启用
`--profiled-only`，保证每个 case 都存在 quick/full 契约。

## 输出结构

结果目录为：

```text
smart_run/kernel_features/<tag>_<profile>_<git>_<clean|dirty>/
```

主要文件如下：

| 文件 | 内容 |
|---|---|
| `README.md` | 全部 kernel 的紧凑汇总与自动特征结论 |
| `kernel_features.csv` | 适合 pandas、表格和聚类分析的宽表 |
| `kernel_features.json` | 全部 kernel 的机器可读扁平结果 |
| `VALIDATION.md` | case 完整性和跨字段数学不变量校验 |
| `run.info` | Git、profile、QEMU、编译器和 case 列表 |
| `git.diff` / `git.status` | dirty 版本的可复现状态 |
| `cases/<case>/features.json` | 该 case 的完整结构化指标 |
| `cases/<case>/README.md` | 该 case 的详细中文报告 |
| `cases/<case>/compiler.flags` | 最终生效的编译、汇编和链接选项 |
| `cases/<case>/<case>.elf` | 实际追踪 ELF |
| `cases/<case>/<case>.objdump` | 与 ELF 对应的无别名反汇编 |
| `cases/<case>/<case>.ktrace.zst` | 可重复离线分析的压缩原始 trace |

## 核心指标覆盖

### 指令与热点

指令类别采用互斥口径，整数、浮点、向量、访存、控制流、系统和其他类别之和必须等于动态指令总数。报告同时给出细分整数/浮点操作、压缩指令比例、动态 mnemonic 熵、静态执行 PC、代码字节、热点函数、热点指令和热点基本块。

这些指标回答 kernel 主要在执行什么，以及性能优化应优先关注整数端口、乘除法、浮点流水线、load/store、前端还是控制流。热点比例还用于判断整体平均值能否代表主要执行时间。

### 控制流

报告统计条件分支、直接跳转、间接跳转、call、return、前向/后向方向、taken 比例、目标距离、基本块长度、循环 trip count、调用深度和间接目标熵。每个静态条件分支分别计算结果熵和 taken/not-taken 翻转率，再按动态次数加权。

最佳静态 per-PC、1-bit 和 2-bit bimodal 失误率均是程序可预测性代理。它们不等于 C910 实际预测失败率，但可以区分“结果本身接近随机”“简单局部状态即可预测”和“可能依赖更长历史或相关性”的分支。

### 代码局部性

报告给出唯一 32B/64B I-line、动态 PC 熵、I-line reuse distance、时间窗口活跃 I-line，以及 4 KiB 到 256 KiB 的全相联 LRU I-cache 容量曲线。曲线只描述容量下界，不包含真实组相联冲突、取指宽度、跨行气泡和 BTB 容量影响。

### 数据访存与地址行为

报告区分 load/store 指令和实际访问事件，统计访问宽度、读写字节、非对齐、跨 cache line、跨页、读写 line/page 工作集、唯一触及字节、地址跨度、line 字节利用率和地址区域。

64B line reuse distance 和 4 KiB 至 1 MiB 全相联 LRU 曲线量化数据容量局部性；页 reuse 和 16 至 512 项全相联 TLB 曲线量化页级压力。每个静态访存 PC 按顺序、固定步长、多步长、不规则分类，并给出顺序或固定步长访问比例作为可预取性代理。该分类是基于动态地址序列的启发式模型，不等同于某个具体预取器的命中率。

### 依赖、并行性与算术强度

报告统计显式寄存器 producer-consumer 距离、第一次 load-use 距离、branch 条件生产距离、load 地址对先前 load 的依赖、同地址 store-to-load、动态反向活跃寄存器，以及 16/32/64/128 指令窗口的理想 ILP。还给出每 32 条指令的 load 数和地址寄存器相互独立的 load 数，用作 MLP 机会代理。

这些指标由反汇编显式操作数和抽象指令延迟推断，不建模隐式寄存器、真实 cache 延迟、执行端口、发射宽度、ROB/IQ/LSQ 容量或物理寄存器重命名。因此它们用于比较 kernel 的依赖结构，不能直接当作 C910 IPC 上限。

算术强度使用请求访存字节计算 FLOP/byte 和 integer-op/byte。它不是 LLC/DRAM 实际流量口径，但适合判断程序更偏计算还是数据搬运。

### 阶段稳定性

执行区间被划分为约 16 个连续窗口，报告访存、控制流和浮点占比的均值、标准差和变异系数。变异系数高说明单一全程平均值可能掩盖 phase，后续应按窗口或 SimPoint 分段分析。

## 数据可信度分层

| 层级 | 指标 |
|---|---|
| 直接观测 | 动态 PC、原始指令、next-PC、访存地址、访问宽度、load/store |
| 精确派生 | 指令构成、taken、基本块、分支熵、工作集、reuse distance、热点 |
| 模型代理 | stride/可预取性、寄存器依赖、load-use、活跃寄存器、理想 ILP、cache/TLB 容量曲线 |
| 不在本流程测量 | IPC、真实 cache/TLB miss、分支预测失败、流水线停顿、能耗、墙上运行性能 |

`VALIDATION.md` 会检查请求的 case 是否全部生成，并验证指令类别守恒、load/store 事件守恒、分支类型与方向守恒、地址模式和地址区域覆盖、百分比范围，以及 cache/TLB 曲线的单调性。原始指令位与 ELF 反汇编不一致、缺失动态 PC 元数据或指定的 RTL 退休指令数不一致时，该 case 直接失败。
