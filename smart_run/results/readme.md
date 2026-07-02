# 结果目录汇总

| 目录 | 基准 | 迭代/运行次数 | 核心指标 | 关键编译选项（口径说明） |
|---|---|---:|---|---|
| baseline | coremark + bench_* | coremark=2 | CoreMark 1.0=4.409288 | 标准基础口径（默认优化级别） |
| coremark_c910_tuned_10 | coremark | 10 | CoreMark 1.0=6.589569 | CoreMark 性能口径（高优化） |
| coremark_c910_tuned_30_unknown_clean | coremark | 30 | （无 score/perf） | CoreMark 性能口径（高优化）+ 30 次迭代 |
| dhrystone_100 | dhrystone | 100 | DMIPS/MHz=4.900 | Dhrystone 性能口径（短迭代） |
| dhrystone_c910_tuned_1000 | dhrystone | 1000 | DMIPS/MHz=4.353 | Dhrystone 性能口径（中间迭代） |
| dhrystone_perf_o3_1000 | dhrystone | 1000 | DMIPS/MHz=5.188 | Dhrystone 性能口径（-O3 全开） |
| dhrystone_std_1000 | dhrystone | 1000 | DMIPS/MHz=4.204 | Dhrystone 严格口径（禁止内联） |
| direct_run_unknown_clean | coremark + dhrystone | coremark=30 / dhrystone=1000 | CoreMark 1.0=6.677975；DMIPS/MHz=5.187 | CoreMark 性能口径 + Dhrystone 1000（-O3） |

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
