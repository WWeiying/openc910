# SPEC CPU2017 SimPoint 与 RTL 通路状态

本文档记录当前 SPEC CPU2017 / QEMU / SimPoint / RTL 通路的真实状态，以及从现在推进到 L3 所需的验收标准。

拆分出的 representative kernels、对应原始 SPEC 函数、权重和 RTL 结果另见：

```text
spec_flow/SPEC2017_REPRESENTATIVE_KERNELS.md
```

当前结论先写清楚：

```text
L1-rate: SPEC CPU2017 rate -> QEMU BBV -> SimPoint -> function profile 已完成 test 全覆盖，23/23 compare pass。
L1-speed: SPEC CPU2017 speed -> QEMU BBV -> SimPoint -> function profile 已完成 train 全覆盖，20/20 compare pass、SimPoint 完整。
L2-v2（历史）: SPECspeed train -> 单综合代理 kernel 为主 -> smart_run RTL 已跑通，但这不是多 SimPoint 加权的真实 SPEC RTL 性能。
L2-v5（当前）: 43 个 benchmark 各自对应一个独立 composite bare-metal ELF。每个 cluster 整体归入一种内部机制，cluster 权重用于校准该机制在 composite 中的动态退休指令份额；RTL 和程序特征均只统计整个 ELF，不再对子 kernel 分开跑或仿真后加权。43/43 已完成 quick/full 动态特征和机制权重校准；当前完整 43 项 RTL 批次尚未执行。
L3: 已完成寄存器 checkpoint 探针；精确 SPEC Linux SimPoint checkpoint -> RTL 恢复执行尚未完成。

L2+ 全套目标进一步要求 Rate/Speed 的 `test/train/ref` 共 129 个组合全部
`ok`。统一进度使用 `spec_flow/check_l2plus_status.sh`；剩余组合由
`spec_flow/run_l2plus_remaining.sh` 断点续跑。2026-07-10 启动剩余任务时的
基线为 63/129：speed test/train 和 rate test 已完成，speed ref、rate
train/ref 正在补齐。

L2+ 新采样统一使用 `qemu-riscv64 -R 0x4000000000` 固定 guest 动态库
地址，并生成 `<bench>_<size>.bb.modules`。该文件记录每条 SPEC command 的
RISC-V loader、libc、libstdc++、libm 和 libgcc 地址区间；函数画像同时解析
主 ELF 与动态库符号，避免把动态链接器/运行库执行笼统记为
`[external-or-unknown]`。manifest 中的 `qemu_reserved_va`、
`mapped_modules` 和 `module_map_done` 用于审计是否采用增强画像。
```

## 1. 分级定义和当前状态

| Level | 目标 | 当前状态 | 已有产物 | 主要缺口 |
|---|---|---|---|---|
| L1-rate | 在 QEMU 上运行 SPEC rate，生成 BBV、SimPoint、weights，并映射到函数级热点 | 完成 CPU2017 rate `test` 23/23 | `.bb`, `.bb.map`, `.bb.cmdmap`, `.simpoints`, `.weights`, `.function_profile.csv`, `manifest.json` | `train/ref` 入口已具备，但尚未在当前仓库记录完整结果 |
| L1-speed | 在 QEMU 上运行 SPECspeed，生成同格式 BBV、SimPoint、weights、函数热点和 manifest | 完成 CPU2017 speed `train` 20/20 | `.bb`, `.bb.map`, `.bb.cmdmap`, `.simpoints`, `.weights`, `.function_profile.csv`, `manifest.json`, `representative_batch_speed_train_summary.md` | `ref` 尚未全量运行；L2 当前固定采用 train 口径 |
| L2 | 每个 benchmark 构造一个独立 composite bare-metal ELF，用本 benchmark 的 cluster 权重校准内部机制动态指令份额 | v5 quick/full 特征与配比 43/43 通过；旧版 25 项 RTL 结果仅可作历史参考 | `spec2017_*_kernel_map.json`, `spec_kernel_profiles.json`, `spec_all_43_*_final/` | 重跑当前 43 项 RTL；`638.imagick_s` 的 ref profile 完成后替换临时 train 配比 |
| L3 | 在 RTL 中从 SimPoint interval 附近恢复真实 SPEC 执行，获得加权 RTL 指标 | 探针完成，恢复未完成 | `tools/qemu-plugins/simpoint_probe.so`, `505.mcf_r_test.probe.regs` | 已能在 interval 附近导出寄存器；仍缺 Linux 进程内存、OS/syscall 状态、RTL restore |

L3 的严格定义是：

```text
SPEC binary + input + compiler + run command 固定；
QEMU 或 full-system model 从程序全程执行中定位 SimPoint interval；
在 interval 前保存可恢复状态；
RTL 从该状态恢复并完成 warmup + detailed interval；
多个 SimPoint interval 的 RTL 指标按 weights 加权汇总；
结果与全程序或更高层模型做 sanity validation。
```

当前 `smart_run` 是裸机 case 加载方式，不是 Linux 用户态进程恢复环境。因此不能把现在的 composite kernel 称为“真实 SPEC SimPoint checkpoint”。它们仍是 L2 representative proxy。

## 2. 已完成的 L1 结果

运行命令：

```bash
docker exec openc910-qemu bash -lc \
  'cd /work && ./spec_flow/run_bbv_simpoint.sh 505.mcf_r test 5 100000000'
```

结果目录：

```text
spec_runs/505.mcf_r_test_c910/
```

关键文件：

| 文件 | 说明 |
|---|---|
| `505.mcf_r_test.bb` | QEMU plugin 生成的 SimPoint text frequency vector |
| `505.mcf_r_test.bb.map` | block id 到 QEMU TB 起始 PC 的映射 |
| `505.mcf_r_test.simpoints` | SimPoint 代表 interval |
| `505.mcf_r_test.weights` | 每个 cluster 权重 |
| `505.mcf_r_test.function_profile.csv` | 全程序和各 SimPoint interval 的函数级热点 |
| `manifest.json` | 汇总上述结果、编译选项和校验状态 |
| `compare.log` | SPEC compare 结果 |
| `simpoint.log` | SimPoint 日志 |

当前 L1 校验：

| 项目 | 值 |
|---|---:|
| benchmark | `505.mcf_r` |
| input | `test` |
| compiler | Xuantie GCC Linux glibc |
| key optimize | `-O2 -march=rv64imafdcxtheadc -mabi=lp64d -mtune=c910` |
| QEMU | `qemu-riscv64 -cpu c910 -L <sysroot>` |
| BBV type | `qemu_tb_instruction_weighted` |
| interval | `100000000` guest instructions |
| BBV intervals | `231` |
| mapped blocks | `3475` |
| estimated guest instructions | about `23.1B` |
| SimPoint maxK | `5` |
| selected K | `4` |
| SPEC compare | pass |
| manifest validation | `compare_pass=true`, `simpoint_done=true` |

SimPoint 结果：

| cluster | representative interval | weight | approximate guest instruction range |
|---:|---:|---:|---|
| 0 | 17 | `0.787879` | 1.7B - 1.8B |
| 1 | 115 | `0.0606061` | 11.5B - 11.6B |
| 2 | 207 | `0.0779221` | 20.7B - 20.8B |
| 3 | 106 | `0.0735931` | 10.6B - 10.7B |

全程序函数热点：

| rank | function | percent |
|---:|---|---:|
| 1 | `spec_qsort` | `32.3048%` |
| 2 | `cost_compare` | `26.9321%` |
| 3 | `primal_bea_mpp` | `21.5108%` |
| 4 | `price_out_impl` | `12.7368%` |
| 5 | `arc_compare` | `2.8582%` |
| 6 | `data_start` | `0.9717%` |
| 7 | `replace_weaker_arc` | `0.9520%` |

各 SimPoint interval 的函数热点：

| cluster | interval | weight | top functions |
|---:|---:|---:|---|
| 0 | 17 | `0.787879` | `spec_qsort 38.0145%`, `cost_compare 33.9896%`, `primal_bea_mpp 27.2789%` |
| 1 | 115 | `0.0606061` | `arc_compare 52.2209%`, `spec_qsort 47.7791%` |
| 2 | 207 | `0.0779221` | `price_out_impl 99.5170%` |
| 3 | 106 | `0.0735931` | `price_out_impl 70.9032%`, `primal_bea_mpp 20.7634%`, smaller refresh/flow functions |

解释：

```text
505.mcf_r test 的主导 cluster 是 interval 17，权重接近 78.8%。
该 interval 不是单纯 mcf arc scan，而是 spec_qsort + cost_compare + primal_bea_mpp 混合阶段。
历史 `spec_mcf_kernel` 只覆盖 price_out/primal_bea_mpp 风格，因此不能代表整个 505.mcf_r test；当前已由包含 sort 和 pricing 的 `spec_505_mcf_composite_kernel` 取代。
```

## 3. 当前 QEMU BBV 语义

插件：

```text
tools/qemu-plugins/simple_bbv.c
```

输出语义：

```text
每个 QEMU translated block 分配一个 block id；
每次执行 TB 时累加该 TB 的 guest instruction 数；
每满 interval 输出一行 SimPoint text frequency vector；
mapfile 记录 block id -> TB 起始 PC -> TB instruction count。
```

这不是严格 basic block execution count，而是：

```text
QEMU TB instruction-weighted frequency vector
```

用于 SimPoint phase selection 是合理的，但写报告时必须说明该口径。

函数级 profile 命令：

```bash
python3 spec_flow/analyze_bbv_functions.py \
  --bbv spec_runs/505.mcf_r_test_c910/505.mcf_r_test.bb \
  --map spec_runs/505.mcf_r_test_c910/505.mcf_r_test.bb.map \
  --elf spec2017/benchspec/CPU/505.mcf_r/run/run_base_test_c910_gcc_xthead.0000/mcf_r_base.c910_gcc_xthead \
  --simpoints spec_runs/505.mcf_r_test_c910/505.mcf_r_test.simpoints \
  --weights spec_runs/505.mcf_r_test_c910/505.mcf_r_test.weights \
  --nm toolchains/Xuantie-900-gcc-linux-6.6.0-glibc-x86_64-V3.1.0/bin/riscv64-unknown-linux-gnu-nm \
  --top 20 \
  --out spec_runs/505.mcf_r_test_c910/505.mcf_r_test.function_profile.csv
```

manifest 生成命令：

```bash
./spec_flow/make_simpoint_manifest.py \
  --bench 505.mcf_r \
  --size test \
  --out-dir spec_runs/505.mcf_r_test_c910 \
  --interval 100000000 \
  --max-k 5 \
  --out spec_runs/505.mcf_r_test_c910/manifest.json
```

SPECspeed `test` 全量结果也已生成，命令为：

```bash
docker exec openc910-qemu bash -lc \
  'cd /work && ./spec_flow/run_representative_batch.sh --suite speed test 5 100000000'
```

当前 SPECspeed L1 校验：

| 项目 | 值 |
|---|---:|
| benchmark 数量 | `20` |
| input | `test` |
| interval | `100000000` guest instructions |
| SimPoint maxK | `5` |
| SPEC compare | `20/20 pass` |
| manifest validation | `20/20 compare_pass=true, simpoint_done=true` |
| batch summary | `spec_runs/representative_batch_speed_test_summary.md` |
| RTL weighted summary | `spec_flow/SPEC2017_SPEED_RTL_WEIGHTED_SUMMARY.md` |

SPECspeed 支持过程中修正了两个关键问题：

```text
1. SPECspeed 的 speccmds.cmd 会通过 submit 包装命令。BBV flow 现在会剥离 submit wrapper，只对真实 RISC-V ELF 做 QEMU plugin 插桩。
2. SPEC 工具链里既有 RISC-V 目标程序，也有 host 侧工具。spec_submit_wrapper.sh 会用 file -L 判断 ELF 类型，RISC-V ELF 走 qemu-riscv64，host 工具原生执行。
3. 628.pop2_s 需要 C 侧 -DSPEC_CASE_FLAG 以及 Fortran 侧 -fconvert=big-endian、-fallow-argument-mismatch；否则会出现 netcdf 符号或 ocn.log endian sanity failure。
```

## 4. 已有的 L2 RTL representative kernel

当前已有两个 case：

| case | 覆盖目标 | 状态 |
|---|---|---|
| `smart_run/tests/cases/spec_mcf_kernel/` | `price_out_impl/primal_bea_mpp` 风格 arc scan、reduced cost、basket update | 已跑 RTL smoke |
| `smart_run/tests/cases/spec_mcf_sort_kernel/` | `spec_qsort/cost_compare` 风格 sort/comparator、指针字段比较、branch-heavy partition | 已跑 RTL smoke |
| `smart_run/tests/cases/spec_parest_dof_kernel/` | deal.II 风格 DoF 插入、稀疏结构构建、约束消元、排序和间接遍历 | 已完成构建验证，待 ref 画像校准和正式 RTL |
| `smart_run/tests/cases/spec_fotonik3d_stencil_kernel/` | E/H 场更新、材料系数、UPML 边界和 power-DFT 累积 | 已由通用 stencil 升级为专用 FDTD 模型，待 ref 画像校准和正式 RTL |

定位：

```text
不是 SPEC 原始源码；
不是真实 SimPoint interval；
是参考 505.mcf_r pointer-heavy arc scan / reduced cost / basket selection 写出的 bare-metal kernel。
```

`spec_mcf_kernel` 默认配置：

```text
SPEC_MCF_NODES=32
SPEC_MCF_ARCS=96
SPEC_MCF_BASKET=8
SPEC_MCF_PASSES=1
```

运行命令：

```bash
cd smart_run
make buildcase CASE=spec_mcf_kernel DUMP=off
make simcase CASE=spec_mcf_kernel DUMP=off
```

已有 RTL smoke 指标：

| metric | value |
|---|---:|
| Kernel cycles | `4366` |
| Kernel retired inst | `2673` |
| Kernel IPC | `0.612` |
| LDST | `93.94%` |
| Cond Branch | `25.93%` |
| Backend Stall | `48.14%` |
| Frontend Stall | `21.35%` |
| Cond Branch Misp | `32.47%` |

`spec_mcf_sort_kernel` 默认配置：

```text
SPEC_MCF_SORT_ITEMS=96
SPEC_MCF_SORT_PASSES=1
```

构建和仿真命令：

```bash
cd smart_run
make buildcase CASE=spec_mcf_sort_kernel DUMP=off
make simcase CASE=spec_mcf_sort_kernel DUMP=off
```

已归档结果：

```text
smart_run/results/spec_mcf_sort_kernel_default/spec_mcf_sort_kernel.run.vcs.log
```

RTL smoke 指标：

| metric | value |
|---|---:|
| Kernel cycles | `16232` |
| Kernel retired inst | `12324` |
| Kernel IPC | `0.759` |
| LDST | `103.94%` |
| Cond Branch | `17.88%` |
| Backend Stall | `49.70%` |
| Frontend Stall | `22.47%` |
| Cond Branch Misp | `34.44%` |
| L1D Load Miss | `0.02%` |
| L1D Store Miss | `0.10%` |
| VCS CPU Time | `48.010s` |

和真实 SimPoint 的对齐关系：

| 真实阶段 | 对齐程度 | 说明 |
|---|---|---|
| cluster 0 / interval 17 | 中 | `spec_mcf_sort_kernel` 覆盖 `spec_qsort/cost_compare`，但还没有把 `primal_bea_mpp` 混进同一 interval |
| cluster 1 / interval 115 | 中 | `spec_mcf_sort_kernel` 覆盖 sort/comparator 行为，但 `arc_compare` 仍是近似 |
| cluster 2 / interval 207 | 中 | 真实热点几乎全是 `price_out_impl`，当前 kernel 有类似 pricing/arc scan 形态 |
| cluster 3 / interval 106 | 中 | 真实热点是 `price_out_impl + primal_bea_mpp`，当前 kernel 接近但不精确 |

当前 L2.5 的加权口径：

| cluster group | representative kernel | combined weight |
|---|---|---:|
| sort/compare function mix | `spec_mcf_sort_kernel` | `0.65` |
| price/primal/replace function mix | `spec_mcf_kernel` | `0.35` |

如果只用这两个 RTL kernel 粗略组合，按 equal-interval SimPoint 权重对 CPI 加权：

```text
weighted CPI ~= 0.65 * 1.317 + 0.35 * 1.565 = 1.404
weighted IPC ~= 0.712
```

这个值只能称为 `505.mcf_r-like weighted RTL prototype`，不能称为 SPEC CPU2017 分数。

`605.mcf_s train` pilot 已完成，用来校准上述 mcf 权重：

| 项目 | 值 |
|---|---:|
| result dir | `spec_runs/605.mcf_s_train_c910/` |
| SPEC compare | pass |
| BBV intervals | `1168` |
| mapped blocks | `3473` |
| selected clusters | `5` |
| global top 1 | `spec_qsort 33.0166%` |
| global top 2 | `cost_compare 28.0735%` |
| global top 3 | `price_out_impl 14.5387%` |
| global top 4 | `primal_bea_mpp 14.5342%` |
| global top 5 | `replace_weaker_arc 5.6892%` |

这个 train 结果说明 mcf 的主要压力仍是 sort/comparator + pointer-heavy arc scan 混合相位。按函数占比估算，sort/compare group 约 0.65，price/primal/replace group 约 0.35，比旧的 0.848/0.152 cluster 粗分更稳。

`619.lbm_s train` 已做过一次前台尝试，但未形成可用结果：

| 项目 | 值 |
|---|---:|
| result dir | `spec_runs/619.lbm_s_train_c910/` |
| 当前状态 | partial |
| 已产生 BBV intervals | `4482` |
| compare | 未执行 |
| SimPoint | 未执行 |
| manifest | 不存在 |
| 处理结论 | 不作为完成结果使用；后续应改用后台长任务重新跑 |

这次尝试说明 `train` 输入在 QEMU BBV 插桩下不适合交互前台等待。后续 train/ref 应使用后台 `nohup` 或任务管理器运行，并用 `spec_flow/check_simpoint_status.py` 汇总状态。

## 5. L3 为什么还不能直接完成

当前工具链里有 `qemu-system-riscv64`，但当前 L1 使用的是：

```text
qemu-riscv64 user-mode
```

当前 RTL smart_run 使用的是：

```text
bare-metal ELF -> inst.pat/data.pat -> simple memory model -> M-mode case
```

两者之间缺少以下桥接：

| 缺口 | 影响 |
|---|---|
| 用户态 QEMU 不能直接导出完整 Linux 进程 checkpoint | 只能看到 guest 用户态执行，不能自然得到可由 RTL 恢复的 OS/进程全状态 |
| smart_run 不是 Linux 进程恢复环境 | 没有用户态 ELF loader、syscall ABI、文件描述符、动态链接器、页表恢复路径 |
| SPEC binary 是 Linux/glibc 动态链接程序 | checkpoint 包含 loader/libc/heap/stack/mmap/file state，不只是 PC 和 GPR |
| RTL memory model 目前按裸机 case 加载 | 不能直接加载任意 Linux 虚拟地址空间和 page table |
| SimPoint interval 需要 warmup | 只从 interval 起点恢复会丢 cache/TLB/BPU/微结构状态，需要 fast-forward 或 warmup slice |

因此，标准 L3 不能靠“把 interval 号传给 RTL”完成。必须选择下面两条路线之一。

## 6. L3 可执行路线

### 6.0 当前已完成的 L3 探针

新增 QEMU plugin：

```text
tools/qemu-plugins/simpoint_probe.c
tools/qemu-plugins/simpoint_probe.so
spec_flow/run_simpoint_probe.sh
```

作用：

```text
按 guest instruction interval 计数；
到达 target interval 附近时读取当前 vCPU registers；
输出 GPR/FPR/PC/priv 等寄存器；
可选 exit_after=1，用于快速验证而不跑完整 benchmark。
```

编译命令：

```bash
make -C tools/qemu-plugins \
  QEMU_ROOT=/home/wangwy/openproject/openc910/toolchains/Xuantie-qemu-x86_64-Ubuntu-20.04-V5.2.8-B20250721-0303 \
  simpoint_probe.so
```

已验证短探针：

```bash
docker exec openc910-qemu bash -lc \
  'cd /work && ./spec_flow/run_simpoint_probe.sh 505.mcf_r test 1 100000'
```

输出文件：

```text
spec_runs/505.mcf_r_test_c910/505.mcf_r_test.probe.regs
```

验证结果：

| item | value |
|---|---:|
| target interval | `1` |
| interval size | `100000` guest instructions |
| observed instructions | `100005` |
| TB PC | `0x7fa865af95fc` |
| dumped registers | `zero..t6`, `pc`, `ft0..ft11`, `priv`, `fflags/frm/fcsr`, Xuantie extension regs |

这个探针证明：

```text
QEMU user-mode 可以在 SimPoint-like interval 附近导出 architectural registers。
```

但它还不能作为 L3 checkpoint：

```text
没有 dump 用户态虚拟内存；
没有 dump mmap/heap/stack 全量内容；
没有 syscall/file descriptor/dynamic linker 状态；
没有把该状态导入 smart_run RTL 的 restore path。
```

### 6.1 精确 L3：full-system checkpoint 路线

这是最严格、最接近学术/工业详细模拟的路线。

流程：

```text
qemu-system-riscv64 boot Linux
  -> 在 Linux 中运行 SPEC CPU2017 binary
  -> QEMU/full-system 采集 BBV 或同步 SimPoint event
  -> 在 SimPoint 前 warmup point 保存 machine checkpoint
  -> checkpoint 包含 memory + GPR/FPR/CSR + page table + device/interrupt state
  -> RTL SoC 加载 checkpoint
  -> 先跑 warmup，再统计 detailed interval
  -> 按 SimPoint weights 加权
```

需要新增能力：

| 模块 | 需要做什么 |
|---|---|
| full-system boot | 准备 C910/通用 RISC-V Linux 镜像、rootfs、SPEC 运行环境 |
| checkpoint dump | dump guest physical memory、hart regs、CSR、privilege、page table/device 状态 |
| RTL restore | smart_run 支持从 checkpoint 初始化内存和 architectural state |
| warmup/detailed 控制 | interval 前 N 条 warmup，随后 M 条 detailed perf 统计 |
| validation | 同一 interval 在 QEMU 和 RTL 的 retired PC/inst count 做 sanity check |

这条路线当前未完成，属于后续较大工程。

### 6.2 实用 L3 原型：user-level replay / derived kernel 路线

这是当前仓库更现实的路线。

流程：

```text
L1 function profile
  -> 选择每个 cluster 的 top functions
  -> 构造 SPEC-derived 或 SPEC-like bare-metal replay kernel
  -> 每个 cluster 一个 RTL kernel
  -> RTL 跑每个 kernel 得到 IPC/stall/miss/mispredict
  -> 用 SimPoint weights 加权成 SPEC-like RTL 指标
```

这不是精确 SPEC checkpoint，但适合研究处理器机制：

| 优点 | 限制 |
|---|---|
| 可在当前 smart_run 上跑 | 不能宣称为 SPEC CPU2017 官方/精确 RTL 分数 |
| 能针对 memory/branch/front-end/backend 做机制分析 | 行为取决于 kernel 抽取和数据构造质量 |
| 开发成本比 full-system checkpoint 小很多 | 需要用 QEMU function profile 持续校准 representative 程度 |

当前 L3 原型已经具备的数据基础：

```text
cluster 0 weight=0.787879: spec_qsort/cost_compare/primal_bea_mpp
cluster 1 weight=0.0606061: arc_compare/spec_qsort
cluster 2 weight=0.0779221: price_out_impl
cluster 3 weight=0.0735931: price_out_impl/primal_bea_mpp
```

因此，下一步实际编码优先级是：

| priority | action | reason |
|---:|---|---|
| P0 | 扩大 `spec_mcf_sort_kernel`/`spec_mcf_kernel` 数据规模并固定正式配置 | 当前 smoke 规模偏小，cache/TLB/BTB 压力不足 |
| P1 | 为两个 kernel 建立统一 result manifest | 记录配置、RTL perf、对应 cluster weight，形成可重复的 SPEC-like RTL profile |
| P2 | 把 `primal_bea_mpp` 行为混入 sort kernel 或新增 hybrid kernel | cluster 0 中 `primal_bea_mpp` 仍有 27.2789% |
| P3 | 如果许可允许，在本地从 SPEC 源码生成 derived kernel，不直接提交 SPEC 源码 | 提高与真实函数的对齐程度 |

## 7. 当前建议

如果目标是体系结构机制研究，先走 `6.2`：

```text
固定 cluster 0/1 的 sort/compare kernel；
固定 cluster 2/3 的 price/primal kernel；
按 SimPoint weights 做加权；
用 RTL counter 分析 branch/LSU/frontend/backend 瓶颈。
```

如果目标是论文中声称“SPEC CPU2017 SimPoint RTL checkpoint”，必须走 `6.1`，并且需要投入 full-system checkpoint/restore 工程。当前文档不能把 L2 representative kernel 包装成 L3 精确 checkpoint。

## 8. 历史 v2 闭环与当前 v5 状态

下述内容记录的是历史 L2-v2 跑通结果，不能解释为多 SimPoint
加权的真实 SPEC RTL 性能。当前 v5 已形成 43 个 benchmark-local ELF：3 个
专用 `simpoint-composition` 和 40 个多阶段
`simpoint-cluster-composition`；quick/full 的动态机制份额均通过 0.5 个百分点
门限。当前 43 项 RTL 尚未重跑，以下旧加权数字仍只是历史参考值。历史
SPECspeed 单核研究口径如下：

```text
SPECspeed 2017 train workload (20/20)
  -> QEMU BBV
  -> SimPoint / weights
  -> function profile
  -> train-calibrated benchmark-to-kernel map (20 benchmark / 21 component)
  -> smart_run RTL representative kernels (21/21 PASS)
  -> strict L2 validation
  -> train-weighted RTL summary
```

新增/固定的关键文件：

| 文件 | 功能 |
|---|---|
| `spec_flow/spec2017_kernel_map.json` | 记录 SPEC benchmark 到 RTL representative kernel 的映射、权重和覆盖等级 |
| `spec_flow/spec2017_speed_kernel_map.json` | 记录 SPECspeed 到 RTL 代理 kernel 的映射；`mcf_s` 已迁移为完整 cluster 分组权重 |
| `spec_flow/aggregate_rtl_by_simpoint.py` | 生成 RTL proxy summary；只对显式 cluster 分组项目进行多 kernel 加权 |
| `spec_flow/validate_l2.py` | 严格核验 manifest、权重和、kernel 源码、RTL PASS、summary/perf/detail.perf |
| `spec_flow/run_spec2017_simpoint_sizes.sh` | 对 `train/ref` 等多个输入规模批量生成 BBV/SimPoint/function profile |
| `spec_flow/SPEC2017_RTL_WEIGHTED_SUMMARY.md` | 历史 v2 代理结果，已加误读警告，不作为 v3 加权结论 |
| `spec_flow/SPEC2017_SPEED_TRAIN_L2_VALIDATION.md` | 本轮 speed/train L2 闭环验收结果 |
| `spec_flow/SPEC2017_SPEED_TRAIN_RTL_WEIGHTED_SUMMARY.md/json` | 本轮 speed/train RTL 加权结果 |

当前生成命令：

```bash
python3 spec_flow/aggregate_rtl_by_simpoint.py \
  --size train \
  --rtl-results smart_run/results/archive/specspeed_train_l2_1f451a653e1c_dirty \
  --kernel-map spec_flow/spec2017_speed_kernel_map.json \
  --require-pass \
  --out-md spec_flow/SPEC2017_SPEED_TRAIN_RTL_WEIGHTED_SUMMARY.md \
  --out-json spec_flow/SPEC2017_SPEED_TRAIN_RTL_WEIGHTED_SUMMARY.json
```

当前验收结果：

| 项目 | 结果 |
|---|---:|
| SPECspeed `train` manifest/SimPoint 覆盖 | 20/20 |
| speed/train 映射 | 20 benchmark / 21 RTL component |
| speed/train 正式 RTL 批次 | 21/21 PASS |
| L2 严格验收 | 0 error |
| intspeed representative Kernel IPC 几何平均 | 1.215 |
| fpspeed representative Kernel IPC 几何平均 | 1.454 |
| speed 全部 representative Kernel IPC 几何平均 | 1.329 |

解释边界：

```text
这些 geomean IPC 不是 SPEC ratio，也不是官方 SPEC 分数；
它们只是对当前 RTL representative kernels 的本地几何平均汇总。
```
