# 结果目录汇总

| 类型 | 顶层目录 | 测试集合 | Profile | 用途 |
|---|---|---:|---|---|
| 临时基线 | `spec_all_43_full_1f451a653e1c_dirty/` | 43 个独立 SPEC Rate/Speed case | `full` | 新 55 项基线完成前用于现有瓶颈分析 |
| 正式基线 | `baseline_full_<git>_<clean-or-dirty>/` | `full_regression_cases.txt` 固定的 55 项 | `full` | 微结构修改前只运行一次，作为所有候选版本的唯一 A/B 基线 |
| 候选版本 | `<change>_full_<git>_<clean-or-dirty>/` | 与正式基线完全相同的 55 项 | `full` | 微结构修改后全面测试并与正式基线比较 |
| 历史归档 | `archive/` | smoke、quick、旧 kernel 和阶段结果 | 混合 | 仅供追溯，不参与新的 A/B 性能结论 |

# 编译选项说明

`-march=rv64imafdcxtheadc`  
选择目标指令集（RISCV64IMAFDC + xTheadC 扩展），决定可发射指令集合与码流特征。

`-mabi=lp64d`  
定义 ABI：long/int 为64位，双精度浮点参与寄存器约定与调用约定。

`-mtune=c910`  
按 C910 微架构调度/寄存器使用倾向，优化对该核的时序特性。

`-O2`  
默认优化级别；开启常规优化，兼顾吞吐与代码体积。

`-O3`  
更激进优化级别；允许更多展开、内联和重排，提升峰值性能。

`-static`  
静态链接，减少运行时库依赖，提升复现实验可比性。

`-funroll-all-loops`  
强制循环展开，减少分支与循环控制开销，可能增加代码体积。

`-finline-limit=500`  
提高可内联函数大小阈值，扩大内联窗口。

`-fgcse-sm`  
打开 GCN/SM 风格全局公共子表达式优化，减少重复计算。

`-fno-schedule-insns`  
关闭部分指令调度，减少编译器重排导致的口径漂移。

`--param max-rtl-if-conversion-unpredictable-cost=100`  
提高分支转换/谓词化的代价阈值，控制 if-conversion 决策。

`-msignedness-cmpiv`  
启用有符号比较相关优化行为约束，用于稳定比较/分支生成策略。

`-fno-code-hoisting`  
禁用代码前移优化，减少越界语义敏感重排。

`-mno-thread-jumps1`  
关闭特定跳转线程化路径，降低跳转转换的编译器干预。

`-mno-iv-adjust-addr-cost`  
关闭/抑制某类地址计算成本修正，限制地址相关优化干预。

`-mno-expand-split-imm`  
抑制立即数拆分扩展优化，降低指令序列波动。

`-DITERATIONS=<N>`  
注入 CoreMark 运行迭代次数常量。

`-DDHRYSTONE_RUNS=<N>`  
注入 Dhrystone 运行回合数常量。

`-std=gnu99`  
采用 GNU99 C 标准语义与兼容扩展。

`-Wno-implicit-int`  
关闭隐式 int 警告，不改变生成码但放宽编译告警。

`-Wno-implicit-function-declaration`  
关闭隐式函数声明警告，不改变生成码但放宽编译告警。

`-DSMART_RUN`  
开启 smart_run 专用条件编译支路，启用 benchmark 测试入口。

`-fno-inline`  
全局禁止内联，贴近严格口径约束。

`-fno-inline-functions`  
禁止一般函数内联，配合 no-inline 形成完整禁内联集。

`-fno-inline-small-functions`  
禁止小函数内联，避免短函数被编译器自动压缩展开。

`-DSPEC_MCF_COMPOSITE_SORT_ROUNDS=<N>`
设置 mcf composite 中完整 sort/compare 机制的执行轮数。

`-DSPEC_MCF_COMPOSITE_SORT_TAIL_ITEMS=<N>`
设置 mcf composite 中用于细调动态指令份额的 comparator tail 数量。

`-DSPEC_MCF_COMPOSITE_PRICE_ROUNDS=<N>`
设置 mcf composite 中 pricing/tree/pointer-scan 机制的执行轮数。

`-DSPEC_PAREST_COMPOSITE_DOF_PASSES=<N>`
设置 parest composite 中 DoF/稀疏结构构建与约束消元的执行轮数。

`-DSPEC_PAREST_COMPOSITE_SPARSE_ITERS=<N>`
设置 parest composite 中完整 SpMV/Krylov 稀疏求解迭代数。

`-DSPEC_PAREST_COMPOSITE_SPARSE_TAIL_ROWS=<N>`
设置 parest composite 中部分 sparse iteration 的行数，用于细调 sparse 动态指令份额。

`SPEC_KERNEL_PROFILE=quick|full`
选择 SPEC bare-metal kernel 的统一 workload profile。`quick` 保持短 ROI，面向 RTL 快速回归；`full` 使用逐 case 校准参数，将 ROI 扩展到 40 万至 62 万条指令契约范围，并启用独立 warmup。

`-DSPEC_PROFILE_FOOTPRINT_BYTES=131072`
用于 40 个统一 phase-marker SimPoint composite 的 full profile，在 warmup 初始化并在 ROI 触碰 128 KiB 数据 footprint。该脚手架不属于 SPEC 原算法，位于所有机制 phase 之外但计入总 ROI，动态指令占比由 profile 契约限制为不超过 10%；quick profile 中该值为 0。

`-DSPEC_<CASE>_REPRESENTATIVE=1`
为对应 SPEC composite 启用 representative 参数分支。与 `SPEC_KERNEL_PROFILE=full` 联合使用时选择该 case 的 full 执行规模；具体宏值记录在 `compiler.flags` 和 `spec_flow/spec_kernel_profiles.json` 对应实测契约中。
