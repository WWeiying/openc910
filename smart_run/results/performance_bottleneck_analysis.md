# C910 性能瓶颈定位与优化路线报告

本文档基于最新 `PERF_DETAIL` 细粒度性能指标，对当前 C910 RTL 仿真结果做完整瓶颈分析。目标不是只解释某个 benchmark 分数，而是把性能损失从 `IPC/FE/BE` 逐层定位到乱序超标量处理器的关键机制：取指、分支预测、rename、issue queue、wakeup/select、RF launch、执行、LSU replay、flush、retire。

## 1. 结论摘要

当前处理器的主要瓶颈不是单一 cache miss、不是单纯分支预测预热、也不是单纯 ROB/PREG 容量不足。最新细粒度指标显示，性能主要受以下机制共同限制：

| 优先级 | 瓶颈方向 | 关键证据 | 结论 |
|---|---|---|---|
| P0 | IQ ready/wakeup/select 效率 | 多数 case `IQ not-ready` 高、`IQ select` 低；`bench_ilp` `zero_backend_raw=73.70%`、`iq_select=0.78` | 后端窗口里有大量未就绪或不能有效选择的指令，真实发射宽度远低于设计潜力 |
| P1 | LSU replay/spec fail/地址相关 | `dhrystone lsu_spec_fail_deep=100.88/KI`，`bench_mem ld_sq_data_discard_deep=66.75/KI`，`bench_cache_stride ld_ag_cross_req=179.55/KI` | 访存瓶颈主要不是 L1D miss，而是 LSU 内部地址、依赖、forward、replay、spec fail |
| P2 | 分支误预测与 flush 频率 | `spec_mcf global_flush_zero_retire=79.00/KI`，`spec_mcf_sort=62.24/KI`，`spec_deepsjeng=53.91/KI` | irregular SPEC kernel 中，频繁 flush 清空窗口，是低 IPC 的关键因素 |
| P3 | 前端供给和重定向恢复 | `spec_cactubssn FE=53.73%`、`spec_lbm FE=41.19%`、`coremark FE=29.91%` | 前端供给参与瓶颈，但要区分真实取指不足和后端反压导致的前端 stall |
| P4 | FP/VIQ/长延迟执行 | `bench_fp BE=48.36%`，`spec_povray IPC=0.671` 且 VIQ/AIQ 等待明显 | FP/向量路径不能用 Dhrystone/CoreMark 结论覆盖，需要单独研究 |
| P5 | ROB/PREG 容量 | 典型 case `preg_alloc_block_avg=0`，ROB full 很低 | 当前第一轮不应先扩大 ROB/PREG，应先解释 ready/select/replay/flush |

最值得作为下一阶段项目主线的是：

`backend_ready_lsu_branch_bottleneck_decomposition`

也就是把后端未就绪、LSU replay、分支 flush 三条线拆清楚，再做单假设、单改动、可反证的 RTL 优化。

当前可以直接成立的判断：

1. 不应优先扩大 ROB/PREG。
2. 不应把当前低分数主要归咎于 L1 cache miss。
3. Dhrystone 的第一研究入口是 LSU/RF ready/replay。
4. CoreMark 是前端、后端、IQ、LSU、flush 混合瓶颈。
5. SPEC kernel 必须单独看，不能用 Dhrystone/CoreMark 结论概括。

当前还不能直接下结论的判断：

1. 不能说 BIU/外部内存带宽是主瓶颈，outstanding 口径需要先修。
2. 不能说 `rf_pipe5_src_no_rdy` 一定来自 load producer，需要 producer 分类。
3. 不能说 mcf/povray 的问题一定是 BHT，需要 direction/target/indirect/RAS 分类。
4. 不能直接改 wakeup/LSU/predictor 后宣称有效，必须用目标指标和反证指标同时闭环。

## 2. 数据来源与口径

最新结果目录：

`smart_run/results/all_cases_gcc_v3_1_0_perf_detail_68a77af01682_clean/`

使用的文件：

| 文件 | 用途 |
|---|---|
| `<case>.perf` | IPC、CPI、Frontend Stall、Backend Stall、cache miss、branch miss 等粗粒度结果 |
| `<case>.detail.perf` | 700 个 detail 事件、104 个 profile 平均值、54 个 latency 分布 |
| `<case>.summary.txt` | benchmark 成绩与运行基本信息 |

分析口径：

1. 表格默认使用 `Kernel` phase。`Kernel` 更接近 benchmark 热区，避免初始化、打印、结束代码污染。
2. `Per KInst` 表示每 1000 条退休指令发生次数。
3. `Zero retire%` 是 `retire_width0_cycle` 周期占比，表示该周期没有指令退休。
4. `zero_*_raw` 是 testbench CPI proxy 的 raw 分类，允许同周期多原因重叠，不能简单相加为 100%。
5. `BIU outstanding` 当前有口径风险，只作为参考，不作为主瓶颈证据。
6. 指标含义和准确性边界见 [PERF_DETAIL.md](/home/wangwy/openproject/openc910/smart_run/PERF_DETAIL.md:1)。

## 3. 全量结果汇总

| Case | IPC | FE% | BE% | Retire | Zero% | Zbad | Zfe | Zmem | Zbe | IQ not | IQ sel | LSU spec/KI | LD cross/KI | BHT mis/KI | Flush/KI |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `bench_br_bimodal` | 2.089 | 5.75 | 14.12 | 1.601 | 33.38 | 5.46 | 6.92 | 0.03 | 31.66 | 6.05 | 1.98 | 0.00 | 0.00 | 3.53 | 3.46 |
| `bench_br_corr` | 1.860 | 28.34 | 35.58 | 0.839 | 34.19 | 1.54 | 16.18 | 0.00 | 34.19 | 9.68 | 1.87 | 0.00 | 0.00 | 1.00 | 0.76 |
| `bench_br_indirect` | 0.835 | 16.27 | 41.00 | 0.592 | 62.13 | 14.15 | 13.91 | 0.12 | 59.54 | 6.25 | 1.23 | 17.47 | 1.07 | 29.32 | 29.12 |
| `bench_br_ras` | 1.866 | 7.83 | 15.86 | 1.758 | 22.35 | 2.35 | 5.44 | 0.08 | 19.72 | 5.16 | 1.94 | 0.00 | 0.00 | 7.65 | 7.65 |
| `bench_branch` | 1.482 | 33.40 | 36.45 | 0.727 | 41.38 | 2.71 | 14.73 | 0.02 | 41.28 | 8.97 | 1.80 | 0.00 | 0.00 | 9.22 | 9.12 |
| `bench_cache_stride` | 1.232 | 6.46 | 30.81 | 0.982 | 50.50 | 15.00 | 6.05 | 10.03 | 43.50 | 4.83 | 1.53 | 0.00 | 179.55 | 39.38 | 39.38 |
| `bench_fp` | 1.366 | 10.45 | 48.36 | 1.056 | 54.27 | 6.37 | 8.56 | 0.55 | 54.27 | 9.74 | 1.29 | 0.00 | 9.92 | 6.46 | 6.35 |
| `bench_frontend` | 1.325 | 10.80 | 33.33 | 0.913 | 57.06 | 11.55 | 7.14 | 0.00 | 56.21 | 5.19 | 1.47 | 0.00 | 0.00 | 22.03 | 21.88 |
| `bench_ilp` | 0.770 | 1.45 | 66.46 | 0.332 | 77.68 | 1.56 | 2.39 | 0.00 | 73.70 | 11.34 | 0.78 | 0.00 | 0.00 | 2.28 | 2.00 |
| `bench_mem` | 0.982 | 5.19 | 22.70 | 1.144 | 55.07 | 3.02 | 5.03 | 6.06 | 49.80 | 10.25 | 1.79 | 25.92 | 83.60 | 2.59 | 22.52 |
| `coremark` | 1.544 | 29.91 | 34.21 | 1.194 | 36.12 | 2.68 | 11.72 | 0.62 | 34.95 | 11.06 | 1.64 | 0.92 | 0.00 | 7.28 | 7.57 |
| `dhrystone` | 1.887 | 8.59 | 25.13 | 1.678 | 28.81 | 1.04 | 4.00 | 4.55 | 25.96 | 12.13 | 2.58 | 100.88 | 48.35 | 0.10 | 4.93 |
| `spec_cactubssn_stencil_kernel` | 1.494 | 53.73 | 46.77 | 1.054 | 48.24 | 12.66 | 29.12 | 5.19 | 48.22 | 16.20 | 1.60 | 0.19 | 64.96 | 3.73 | 3.92 |
| `spec_deepsjeng_search_kernel` | 0.923 | 16.97 | 35.98 | 0.681 | 57.30 | 12.16 | 11.61 | 0.61 | 56.60 | 2.58 | 1.10 | 0.00 | 0.84 | 54.04 | 53.91 |
| `spec_exchange2_search_kernel` | 1.617 | 20.90 | 30.07 | 1.041 | 51.19 | 10.07 | 12.36 | 1.32 | 47.49 | 8.87 | 1.98 | 1.59 | 3.21 | 13.40 | 13.34 |
| `spec_lbm_stream_kernel` | 1.717 | 41.19 | 40.95 | 1.082 | 51.29 | 6.94 | 26.47 | 0.23 | 51.15 | 15.18 | 1.70 | 0.00 | 1.54 | 2.60 | 2.60 |
| `spec_leela_playout_kernel` | 1.053 | 22.77 | 45.20 | 0.816 | 63.67 | 13.39 | 19.35 | 2.29 | 59.76 | 9.73 | 1.28 | 0.00 | 24.08 | 27.00 | 24.03 |
| `spec_mcf_kernel` | 0.639 | 19.97 | 46.68 | 0.593 | 62.05 | 21.93 | 15.78 | 2.42 | 60.28 | 5.31 | 1.14 | 37.06 | 41.18 | 88.36 | 79.00 |
| `spec_mcf_sort_kernel` | 0.759 | 23.86 | 50.83 | 0.780 | 49.03 | 24.64 | 13.37 | 1.21 | 47.78 | 6.31 | 1.31 | 0.00 | 21.34 | 62.97 | 62.24 |
| `spec_parest_sparse_kernel` | 1.410 | 33.36 | 41.03 | 1.163 | 45.22 | 16.13 | 21.29 | 3.61 | 45.15 | 10.86 | 1.44 | 0.00 | 53.18 | 10.82 | 10.82 |
| `spec_povray_ray_kernel` | 0.671 | 31.98 | 49.17 | 0.430 | 71.99 | 28.88 | 25.63 | 0.05 | 71.53 | 10.15 | 1.03 | 0.00 | 0.28 | 47.38 | 38.55 |
| `spec_x264_pixel_kernel` | 1.833 | 26.46 | 32.79 | 1.121 | 44.71 | 8.31 | 17.81 | 3.14 | 44.20 | 10.62 | 1.96 | 0.00 | 40.83 | 7.68 | 7.32 |
| `spec_xz_lzma_kernel` | 1.712 | 10.48 | 24.85 | 0.982 | 44.34 | 5.75 | 5.65 | 3.29 | 43.15 | 9.62 | 2.05 | 0.00 | 25.08 | 11.09 | 10.62 |

字段说明：

| 字段 | 含义 |
|---|---|
| `Retire` | `retire_width_avg`，平均每周期退休指令数 |
| `Zero%` | `retire_width0_cycle`，无退休周期占比 |
| `Zbad/Zfe/Zmem/Zbe` | zero-retire raw 分类：bad speculation、frontend、memory、backend core |
| `IQ not` | `iq_not_ready_width_avg`，平均每周期 valid-not-ready IQ 项数量 |
| `IQ sel` | `iq_select_width_avg`，平均每周期被 select/issue 的 IQ 项数量 |
| `LSU spec/KI` | `lsu_spec_fail_deep` 每千指令次数 |
| `LD cross/KI` | `ld_ag_cross_req` 每千指令次数 |
| `BHT mis/KI` | `bht_bju_mispred` 每千指令次数 |
| `Flush/KI` | `global_flush_zero_retire` 每千指令次数 |

## 4. 全局现象

### 4.1 退休宽度远低于峰值

C910 是乱序超标量处理器，但当前 benchmark 的 `retire_width_avg` 普遍远低于理论峰值。典型情况：

| Case | IPC | Retire/cyc | Zero-retire |
|---|---:|---:|---:|
| `coremark` | 1.544 | 1.194 | 36.12% |
| `dhrystone` | 1.887 | 1.678 | 28.81% |
| `bench_ilp` | 0.770 | 0.332 | 77.68% |
| `spec_mcf_kernel` | 0.639 | 0.593 | 62.05% |
| `spec_povray_ray_kernel` | 0.671 | 0.430 | 71.99% |

这说明性能损失最终体现为退休端没有足够完成指令可提交。分析不能停在 IPC，需要继续拆：为什么没有完成指令，是前端没供给、分支清空、LSU replay、IQ 未就绪，还是 ROB head 阻塞。

### 4.2 后端 raw 原因覆盖面最大

`zero_backend_raw` 排名前列：

| Case | `zero_backend_raw` |
|---|---:|
| `bench_ilp` | 73.70% |
| `spec_povray_ray_kernel` | 71.53% |
| `spec_mcf_kernel` | 60.28% |
| `spec_leela_playout_kernel` | 59.76% |
| `bench_br_indirect` | 59.54% |
| `spec_deepsjeng_search_kernel` | 56.60% |

这说明多数低 IPC case 首先是后端没有把窗口中的指令高效转化为执行和退休。由于 `zero_backend_raw` 是粗分类，下一层要看 IQ ready/select、RF src_not_ready、LSU replay、ROB head、执行单元。

### 4.3 ROB/PREG 不是第一瓶颈

若第一瓶颈是窗口容量或物理寄存器不足，应看到 `rtu_rob_full`、`rob_full_dbg`、`preg_alloc_block_avg` 持续升高。但当前数据不支持这个方向：

| Case | `rtu_rob_full` | `preg_alloc_block_avg` | 判断 |
|---|---:|---:|---|
| `coremark` | 约 0.001% | 0 | 不是 ROB/PREG 容量主导 |
| `dhrystone` | 约 0 | 0 | 不是 ROB/PREG 容量主导 |
| `bench_ilp` | 很低 | 0 | 即使后端严重受限，也不是 free-list 阻塞 |

因此，第一轮优化不建议直接扩大 ROB 或物理寄存器。更优先的问题是：窗口里已有指令为什么长期不 ready、不 select、不 retire。

### 4.4 L1 cache miss 不是当前主线

CoreMark 和 Dhrystone 的 L1I/L1D miss 不高，但 FE/BE 和 LSU replay 仍明显。尤其 Dhrystone `lsu_spec_fail_deep=100.88/KI`、`ld_ag_cross_req=48.35/KI`，这不是 cache 容量 miss 能解释的。当前访存瓶颈更像 LSU 内部路径问题：地址生成、store-load 相关性、forward、边界访问、spec fail、replay。

### 4.5 BIU outstanding 暂不能当主证据

`coremark` 中 `biu_ar_hs_deep=17946`、`biu_rlast_hs_deep=6590`，但 `biu_rd_outstanding_avg=125.312`；`dhrystone` 中 AR/RLAST 只有 21/22，但 outstanding 仍显示明显活动。这说明 outstanding 当前可能受 phase 边界、AXI burst 语义、AR/RLAST 维护口径影响。

结论：修正 BIU outstanding 前，不把它作为“内存带宽是主瓶颈”的证据。BIU 相关判断应优先看 AR/RLAST handshake、backpressure、`biu_ar_to_rlast` latency，并结合 LFB/RB/LQ/SQ。

### 4.6 当前性能损失的总体归因模型

从全量结果看，当前性能损失不是单个模块坏掉，而是多个机制形成了连锁：

```text
前端供给/分支预测/后端 ready
  -> issue queue 中有效指令不能稳定变成可发射指令
    -> RF launch、LSU replay、branch flush 反复打断执行流
      -> ROB head 可提交指令不足
        -> retire_width 低、zero-retire 周期高、IPC 低
```

这个模型解释了为什么不能只看 `IPC` 或只看 `Frontend Stall/Backend Stall`。例如 `CoreMark` 的 FE% 和 BE% 都高，但 L1 cache miss 和 LSU spec fail 并不极端；它更像前端供给、IQ not-ready、分支 flush、LSIQ waiting 共同造成的吞吐下降。`Dhrystone` 则相反，FE% 低、branch miss 低，但 `rf_pipe5_src_no_rdy`、`lsu_spec_fail_deep`、`ld_ag_cross_req` 同时高，说明主问题集中在 LSU/RF ready/replay。`bench_ilp` 又进一步排除了前端和 cache，把问题压缩到后端调度、wakeup、select、执行端口或依赖链本身。

因此后续分析必须采用“交叉排除”的方法：

| 判断目标 | 支持证据 | 反证证据 | 当前结论 |
|---|---|---|---|
| 是否 cache miss 主导 | L1/L2 miss、refill busy、memory raw、BIU handshake 同时高 | miss 低但 IQ/LSU/flush 高 | 当前不是主线 |
| 是否 ROB/PREG 容量主导 | ROB full、PREG block、rename 阻塞持续高 | ROB/PREG 低但 zero_backend 高 | 当前不是第一瓶颈 |
| 是否前端主导 | FE%、IBUF empty、I-cache/BTB/redirect 高 | IQ not-ready/LSU/flush 同时高 | 只在部分 SPEC case 明显 |
| 是否后端 ready/select 主导 | IQ not-ready 高、select 宽度低、RF no-ready 高 | ROB full 或 cache miss 更高 | 当前 P0 |
| 是否 LSU replay 主导 | spec fail、cross req、SQ discard、load replay pressure 高 | L1D miss 低、BIU 不重 | Dhrystone/bench_mem 强成立 |
| 是否分支 flush 主导 | BHT/BJU mispred、global flush、bad spec raw 高 | flush 低但 BE 高 | mcf/povray/deepsjeng 强成立 |

这一归因模型也决定了优化顺序：先把“窗口里为什么不能执行”解释清楚，再去改窗口大小、cache 容量或外部内存带宽。否则很容易把面积和复杂度加到非主瓶颈上，分数不涨，时序和验证压力反而上升。

## 5. 主瓶颈一：IQ ready/wakeup/select 效率

### 5.1 证据

`IQ not-ready` 排名前列：

| Case | `iq_not_ready_width_avg` | `iq_select_width_avg` | 现象 |
|---|---:|---:|---|
| `spec_cactubssn_stencil_kernel` | 16.20 | 1.60 | 队列中大量未就绪，select 宽度低 |
| `spec_lbm_stream_kernel` | 15.18 | 1.70 | 前端和后端同时受限 |
| `dhrystone` | 12.13 | 2.58 | IQ 等待高，但 select 相对较好 |
| `bench_ilp` | 11.34 | 0.78 | 纯后端瓶颈，select 极低 |
| `coremark` | 11.06 | 1.64 | 综合型瓶颈，后端 ready/select 是关键 |
| `spec_parest_sparse_kernel` | 10.86 | 1.44 | 前端、LSU、IQ 等待叠加 |

这个组合很关键：`IQ not-ready` 高说明队列里有很多 valid entry，但操作数、依赖或执行条件未满足；`IQ select` 低说明真正进入执行的宽度有限。若只是前端没供给，IQ not-ready 不应长期这么高；若只是 ROB 容量不足，应看到 ROB full。

### 5.2 机制解释

IQ ready/wakeup/select 低效可能来自几类机制：

| 机制 | 可能表现 | 当前证据 |
|---|---|---|
| load-use 依赖等待 | LSU producer 未返回，消费者长期 not-ready | `dhrystone lsiq_not_ready=4.916`、`rf_pipe5_src_no_rdy=43.485/KI` |
| wakeup/forward 时机保守 | 指令已经接近可执行，但 ready 晚置位 | `IQ not-ready` 高，`select` 低，cache miss 不高 |
| 执行端口/FU 忙 | ready 指令不能及时 select | `bench_ilp iq_select=0.78`，`zero_backend_raw=73.70%` |
| RF launch 被打回 | IS 判断可发射，RF 发现源/端口不满足 | Dhrystone `rf_pipe5_src_no_rdy` 异常高，需继续确认 producer 类型 |
| 长延迟执行链 | FP/div/mult/load 链造成 ready 长尾 | `bench_fp`、`spec_povray`、VIQ/AIQ wait 明显 |

这里最关键的不是“队列里有没有指令”，而是“有效指令什么时候变成 ready，以及 ready 后是否能马上被 select”。乱序处理器的吞吐依赖窗口把独立指令提前找出来执行；如果 wakeup 过晚、select 端口利用不好，或者 RF 阶段反复发现源操作数仍不可用，那么即使前端能持续送指令，后端也会表现为低 issue、低 retire。

`bench_ilp` 是判断这一点的核心证据。它的 FE% 只有 1.45%，`zero_memory_raw=0`，但 `zero_backend_raw=73.70%`、`iq_select_width_avg=0.78`。这意味着瓶颈不能推给取指，也不能推给 cache miss，而应集中检查后端调度链路。若后续某个 wakeup/select/RF 改动有效，`bench_ilp` 应该是最敏感的 case；若 CoreMark/Dhrystone 变好但 `bench_ilp` 不动，则说明优化可能只击中了 LSU 或分支副问题，没有提升通用调度能力。

对这一线要特别避免一个误判：`IQ not-ready` 高不等于 IQ 容量不够。容量不够应表现为 IQ full、rename/dispatch 被阻塞；当前更像队列中存在大量等待 producer 的指令。扩大 IQ 可能让等待项更多，但不一定增加 ready 项比例。真正要解决的是 producer ready 时机、consumer wakeup 时机、select 仲裁和 RF launch 一致性。

### 5.3 需要补充的细粒度观测

当前指标已经能证明“ready/select 有问题”，但还不能完全回答“谁是 producer”。下一步应增加：

| 新指标 | 用途 |
|---|---|
| `iq_not_ready_by_src_type` | 区分 load、ALU、mult/div、FP、branch、CSR producer |
| `rf_src_no_rdy_by_pipe_and_producer` | 解释 `rf_pipe5_src_no_rdy` 到底等谁 |
| `load_use_distance_hist` | 判断 load-use 间隔是否过短 |
| `iq_entry_age_hist` | 找长期滞留 IQ 的 entry |
| `select_block_reason` | 区分 not-ready、FU busy、port busy、age priority、flush |

### 5.4 改进方案

| 优先级 | 方案 | 验证指标 | 风险 |
|---|---|---|---|
| P0 | 拆分 IQ not-ready producer 类型 | `iq_not_ready_by_src_type` | 先观测，不改功能，风险低 |
| P0 | 针对 load producer 检查 wakeup/forward 提前量 | `rf_pipe*_src_no_rdy`、`ld_replay_pressure` | 过早 wakeup 可能增加 replay |
| P1 | 调整 select 优先级，优先解除长等待链 | `iq_select_width_avg`、`retire_width_avg` | 可能牺牲公平性或其他 workload |
| P1 | 检查 RF launch ready 判定和 IS ready 判定是否不一致 | `rf_pipe*_lch_fail` | 需要保证不破坏正确性 |
| P2 | 对长延迟 FU 增加更准确的完成/wakeup 信号 | `*_wait_to_ready` | 需要理解执行单元接口 |

## 6. 主瓶颈二：LSU replay、spec fail 与地址相关路径

### 6.1 证据

LSU 相关 top 指标：

| 指标 | Top case | 数值 |
|---|---|---:|
| `lsu_spec_fail_deep` | `dhrystone` | 100.88/KI |
| `lsu_spec_fail_deep` | `spec_mcf_kernel` | 37.06/KI |
| `lsu_spec_fail_deep` | `bench_mem` | 25.92/KI |
| `ld_ag_cross_req` | `bench_cache_stride` | 179.55/KI |
| `ld_ag_cross_req` | `bench_mem` | 83.60/KI |
| `ld_ag_cross_req` | `spec_cactubssn_stencil_kernel` | 64.96/KI |
| `ld_ag_cross_req` | `spec_parest_sparse_kernel` | 53.18/KI |
| `ld_sq_data_discard_deep` | `bench_mem` | 66.75/KI |

这些指标同时指向 LSU 内部，而不是 L1D 容量 miss：

1. Dhrystone 的 `L1D miss` 很低，但 `lsu_spec_fail_deep` 极高。
2. `bench_mem` 不是简单 cache miss，而是 `ld_sq_data_discard_deep` 很高，说明 store/load 相关性或 forwarding/discard 路径明显。
3. `bench_cache_stride` 的 `ld_ag_cross_req` 极高，说明地址模式触发了 LSU 特殊路径。
4. `spec_mcf` 同时有 `lsu_spec_fail_deep`、`ld_ag_cross_req`、branch flush，属于混合坏 case。

### 6.2 Dhrystone 的 LSU/RF 特征

| 指标 | 数值 | 含义 |
|---|---:|---|
| `IPC` | 1.887 | 比 CoreMark 高，但离理想乱序宽度仍远 |
| `FE%` | 8.59% | 前端不是主因 |
| `BE%` | 25.13% | 后端是主要方向 |
| `zero_backend_raw` | 25.96% | zero-retire 主要由后端 raw 解释 |
| `rf_pipe5_src_no_rdy` | 43.485/KI | LSU/store 相关 pipe 源未就绪异常突出，但 producer 类型还需继续拆分 |
| `rf_pipe2_src_no_rdy` | 4.840/KI | 次级源未就绪 |
| `lsiq_not_ready_avg` | 4.916 | load-side IQ 等待突出 |
| `sdiq_not_ready_avg` | 2.780 | store-side IQ 等待突出 |
| `ld_ag_cross_req` | 48.35/KI | load 地址边界/特殊路径高 |
| `st_ag_cross_req` | 28.98/KI | store 地址相关事件高 |
| `lsu_spec_fail_deep` | 100.88/KI | 深度 LSU spec fail/replay 极高 |
| `ld_replay_pressure` | 19.746 cycles | replay 一旦出现，平均压力很大 |

Dhrystone 的结论很明确：不是分支、不是 I-cache，也不是 ROB/PREG。第一嫌疑是 LSU replay 与 RF ready/forward 的耦合。要重点确认 `rf_pipe5_src_no_rdy` 的 producer 是否来自 load/store 路径，还是来自其他执行 pipe 的写回/前递时序。

更进一步看，Dhrystone 的特殊性在于它看起来是“小整数 benchmark”，但当前 RTL 结果呈现出明显的 LSU/RF 路径压力。`dcache_read_miss` 和 `dcache_write_miss` 并不支持 cache miss 主导；`bht_bju_mispred=0.10/KI` 也不支持分支主导；但 `lsu_spec_fail_deep=100.88/KI`、`ld_ag_cross_req=48.35/KI`、`st_ag_cross_req=28.98/KI`、`rf_pipe5_src_no_rdy=43.49/KI` 同时出现，说明 load/store 地址路径、spec fail/replay、RF 源就绪之间存在强耦合。

这里有三种可能根因，需要用后续计数器和 microbench 区分：

| 可能根因 | 机制描述 | 需要看到的证据 | 可能改法 |
|---|---|---|---|
| store-load 相关性保守或失败 | load 早于 older store 地址/数据确定，之后被 replay 或打回 | spec fail reason 集中在 store-load violation、SQ addr/data late | 改 memory disambiguation、SQ forwarding、load issue 条件 |
| 地址边界/特殊访问路径触发 | 结构体、栈或全局变量布局导致 cross req 或 split 访问 | top PC/地址低位集中，数据对齐后事件下降 | 改数据布局，或优化 AG/DC cross handling |
| RF/wakeup 时序不一致 | IS 阶段认为可发射，RF 阶段发现 producer 未就绪 | `rf_pipe5_src_no_rdy` 与 load replay/spec fail 同周期相关 | 改 load wakeup、forward ready、RF launch 判定 |

这也是为什么 Dhrystone 分数不能只通过增加迭代次数或调编译选项解释。迭代次数只能提高统计稳定性；编译选项可能改变代码布局和 load/store 形态，但不会解释硬件机制。要把它变成体系结构研究，需要固定当前编译口径，然后观察上述事件是否随 RTL 或数据布局实验发生可解释变化。

### 6.3 CoreMark 的 LSU 位置

CoreMark 的 LSU 指标不如 Dhrystone 极端：

| 指标 | 数值 |
|---|---:|
| `lsu_spec_fail_deep` | 0.924/KI |
| `ld_ag_cross_req` | 0.003/KI |
| `ld_sq_data_discard_deep` | 0.072/KI |
| `lsiq_not_ready_avg` | 4.060 |
| `ld_replay_pressure` | 0.208 cycles |

CoreMark 的主要问题不是 LSU replay 单点爆炸，而是综合型：前端、IQ not-ready、LSIQ 等待、分支 flush 共同降低退休宽度。

### 6.4 改进方案

| 优先级 | 方案 | 验证指标 | 预期 |
|---|---|---|---|
| P0 | 拆 `lsu_spec_fail_deep` 原因 | `spec_fail_by_store_load_dep/cross/cache/mmu` | 找出 Dhrystone 100.88/KI 的真实来源 |
| P0 | 记录 `ld_ag_cross_req` 触发 PC 和地址低位 | top PC、地址对齐分布 | 判断是否由数据布局触发 |
| P0 | 做 Dhrystone 数据/栈/全局变量对齐实验 | `ld_ag_cross_req`、`lsu_spec_fail_deep` | 若显著下降，说明 layout 触发 LSU 特殊路径 |
| P1 | 拆 store-load forwarding attempt/success/fail | `ld_sq_data_discard_deep` | 解释 bench_mem 的 66.75/KI |
| P1 | 拆 load replay producer-consumer 链 | `ld_replay_pressure`、`rf_pipe*_src_no_rdy` | 验证 replay 是否导致消费者反复打回 |
| P2 | 优化 store-load speculation 或 replay 策略 | IPC、flush、spec fail | 减少 replay，但必须保证内存一致性 |

## 7. 主瓶颈三：分支误预测与 flush

### 7.1 证据

`global_flush_zero_retire` 排名前列：

| Case | `global_flush_zero_retire` | `bht_bju_mispred` | `zero_bad_spec_raw` |
|---|---:|---:|---:|
| `spec_mcf_kernel` | 79.00/KI | 88.36/KI | 21.93% |
| `spec_mcf_sort_kernel` | 62.24/KI | 62.97/KI | 24.64% |
| `spec_deepsjeng_search_kernel` | 53.91/KI | 54.04/KI | 12.16% |
| `bench_cache_stride` | 39.38/KI | 39.38/KI | 15.00% |
| `spec_povray_ray_kernel` | 38.55/KI | 47.38/KI | 28.88% |
| `bench_br_indirect` | 29.12/KI | 29.32/KI | 14.15% |

这些数据说明，SPEC irregular kernel 中频繁 flush 是低 IPC 的重要原因；对应的分支/stride microbench 也能触发类似现象，用于做机制放大验证。和 Dhrystone 不同，这类 workload 更接近真实应用中的复杂控制流，必须作为研究重点。

### 7.2 机制解释

分支/flush 造成性能损失的路径：

1. 预测错误导致错误路径指令进入窗口。
2. BJU/retire 发现错误后触发 flush。
3. ROB、IQ、LSU 中错误路径工作被清空或取消。
4. IFU 重定向，fetch/ID 恢复需要若干周期。
5. 后端窗口重新填充，期间退休宽度降低。

当前很多 case 的问题更像“flush 频率高”，不一定是单次恢复延迟特别长。因此第一优先级是降低误预测/错误目标次数，而不是先优化恢复流水线。

分支方向还要区分“预测错了什么”。同样是 `global_flush_zero_retire` 高，可能来自 BHT 方向错、BTB 目标错、间接跳转目标错、RAS 错、更新延迟，也可能来自少数热点 PC 的 alias。不同原因对应完全不同的 RTL 改法：

| 错误类型 | 典型现象 | RTL 研究重点 |
|---|---|---|
| 条件分支方向错 | `bht_bju_mispred` 高，热点 PC 多为条件分支 | BHT 表大小、历史长度、索引 hash、更新时机 |
| 目标地址错 | BTB/L0 BTB miss 或 target incorrect 高 | BTB 容量、tag、目标旁路、fetch redirect |
| 间接跳转错 | indirect BTB miss/correct 差 | 间接预测器结构、目标历史、调用模式 |
| return 错 | RAS empty/full/mistaken 与 flush 相关 | RAS 深度、push/pop 时机、异常/flush 恢复 |
| 更新滞后或覆盖 | wrbuf full、wrbuf hit/alias 高 | predictor update buffer、commit/update 策略 |

当前 `mcf`、`mcf_sort`、`deepsjeng`、`povray` 是最适合做这条线的真实 workload。`bench_br_*` 可以用来放大单一机制，但不能替代 SPEC kernel，因为人工 microbench 往往控制流更规则，未必暴露真实程序中的 alias、间接跳转和代码布局问题。

### 7.3 改进方案

| 优先级 | 方案 | 验证指标 | 说明 |
|---|---|---|---|
| P0 | 记录 mispred PC top-N | 每个 PC 的 mispred 次数、类型 | 找 mcf/povray/deepsjeng 的热点分支 |
| P0 | 区分 direction/target/indirect/RAS miss | `bht_bju_mispred`、`l0_btb_mispred`、`ind_btb_miss`、`ras_mistaken` | 决定优化 BHT、BTB、间接预测还是 RAS |
| P1 | 观察 BHT update buffer alias/覆盖 | `bht_wr_buf_hit`、`bht_wrbuf_create_slot_full` | 判断小表或更新时机是否限制 |
| P1 | 加 target predictor hit/correct 分母 | BTB hit/miss/correct rate | 避免只有 miss 事件没有准确率 |
| P2 | 改 predictor 结构或参数 | `global_flush_zero_retire`、IPC | 必须用 mcf/povray/deepsjeng 验证 |

## 8. 主瓶颈四：前端供给

### 8.1 证据

`zero_frontend_raw` 和 FE% 最高的 case：

| Case | FE% | `zero_frontend_raw` | 判断 |
|---|---:|---:|---|
| `spec_cactubssn_stencil_kernel` | 53.73% | 29.12% | 前端和后端同时严重受限 |
| `spec_lbm_stream_kernel` | 41.19% | 26.47% | 前端供给与后端等待叠加 |
| `spec_povray_ray_kernel` | 31.98% | 25.63% | 分支/FP/前端混合 |
| `spec_parest_sparse_kernel` | 33.36% | 21.29% | 前端、LSU、IQ 混合 |
| `coremark` | 29.91% | 11.72% | 综合型前后端耦合 |

前端问题不能简单等同于 I-cache miss。很多 case 的 FE 高，但 I-cache miss/refill 并不是主证据。可能原因包括：

1. 分支重定向频繁导致 fetch 气泡。
2. IBUF/PCFIFO 被后端反压撑满。
3. 多分支 fetch、BTB/L0 BTB 等目标预测路径造成供给不连续。
4. 后端 flush/replay 使前端反复丢弃工作。

前端分析最容易出错，因为 `FE%` 是结果，不是原因。前端可能真的供不上，也可能是后端不消费导致 IBUF/PCFIFO 反压，还可能是分支 flush 导致前端反复重定向。当前 `coremark` 的 `ifu_ibuf_full` 明显高于 I-cache miss 相关事件，说明至少在 CoreMark 上，前端 stall 中有很大部分不能直接归咎于 I-cache 容量或 refill 延迟。对 `spec_cactubssn`、`spec_lbm`、`spec_parest` 这类 FE 高的 case，也必须同时看 IQ not-ready 和 flush，否则会把后端问题误判成取指问题。

因此前端技术路线应分成两步：第一步只做归因，不急于改取指结构；第二步才根据归因选择 BTB、IBUF、redirect、I-cache 或后端解耦。若发现 FE stall 与 `global_flush_zero_retire` 同周期强相关，优先改 predictor/redirect；若与 `id_ir_stall`、`ifu_ibuf_full`、IQ full 或后端 waiting 强相关，优先改后端消费；只有当 IBUF empty、I-cache refill busy、BTB miss 和 fetch invalid 同时成立时，才把取指带宽或 I-cache 作为主改动方向。

### 8.2 改进方案

| 优先级 | 方案 | 验证指标 |
|---|---|---|
| P0 | 区分 frontend stall 是 I-cache miss、BTB/redirect、IBUF full 还是后端反压 | `icache_refill_*`、`l0_btb_*`、`ifu_ibuf_full`、`flush_to_fetch` |
| P0 | 统计 IBUF empty/full 与 backend stall 同周期相关性 | 判断是真前端不足还是后端消费不足 |
| P1 | 记录 flush 后 fetch/id 恢复延迟分布 | `flush_to_fetch`、`flush_to_id` |
| P1 | 对 SPEC 前端高 case 记录取指 PC 断点 | 找供给不连续位置 |
| P2 | 优化 BTB/L0 BTB 或 fetch redirect 旁路 | FE%、`zero_frontend_raw`、IPC |

## 9. 主瓶颈五：FP/VIQ 和长延迟执行

### 9.1 证据

| Case | IPC | BE% | `viq0_not_ready_avg` | 相关现象 |
|---|---:|---:|---:|---|
| `bench_fp` | 1.366 | 48.36% | 3.793 | FP benchmark 后端受限明显 |
| `spec_povray_ray_kernel` | 0.671 | 49.17% | 3.156 | FP/分支/前端混合坏 case |
| `spec_lbm_stream_kernel` | 1.717 | 40.95% | 2.913 | streaming/FP/前端混合 |
| `spec_cactubssn_stencil_kernel` | 1.494 | 46.77% | 2.489 | stencil 前端和后端同时高 |

FP/VIQ case 的瓶颈不能用 Dhrystone 的 LSU/RF 结论概括。这里需要看 VFPU issue、forward、writeback、VIQ ready/select、长延迟 FU busy。

### 9.2 改进方案

| 优先级 | 方案 | 验证指标 |
|---|---|---|
| P0 | 拆 VIQ not-ready producer 类型 | `viq*_not_ready_avg`、`viq*_wait_to_ready` |
| P0 | 记录 VFPU issue/wb/forward 冲突 | `vfpu_*issue`、`vfpu_*wb`、`vfpu_*fwd` |
| P1 | 拆 FP 长延迟单元 busy 与等待 | `vfdsu_pipe_busy`、`vfdsu_ex2_wait` |
| P1 | 检查 FP writeback 端口冲突 | VFPU WB width、vreg conflict |

## 10. 重点 benchmark 逐项分析

### 10.1 CoreMark

CoreMark 是当前最重要的综合型整数 benchmark。

| 指标 | 数值 | 判断 |
|---|---:|---|
| IPC | 1.544 | 中等偏低，未充分发挥乱序宽度 |
| FE% | 29.91% | 前端参与瓶颈 |
| BE% | 34.21% | 后端也明显受限 |
| retire_width_avg | 1.194 | 最终退休宽度低 |
| zero-retire | 36.12% | 超过三分之一周期无退休 |
| zero_backend_raw | 34.95% | 后端 raw 是第一大类 |
| zero_frontend_raw | 11.72% | 前端 raw 有影响 |
| zero_bad_spec_raw | 2.68% | 分支错误不是第一主因 |
| zero_memory_raw | 0.62% | memory-bound raw 很低 |
| iq_not_ready_width_avg | 11.06 | 大量 IQ 项未就绪 |
| iq_select_width_avg | 1.64 | 实际 select 宽度不高 |
| lsiq_not_ready_avg | 4.06 | LSU 队列等待明显 |
| lsu_spec_fail_deep | 0.92/KI | LSU spec fail 不高 |
| global_flush_zero_retire | 7.57/KI | flush 中等 |

CoreMark 不是单点瓶颈。它的优化方向应是综合拆解：

1. 先拆 `IQ not-ready` producer。
2. 同时看前端 stall 是 redirect/IBUF/后端反压还是 I-cache。
3. LSU replay 不是 CoreMark 第一嫌疑，但 LSIQ waiting 仍需关注。
4. 不建议只为了 CoreMark 分数去调编译器或只扩大 cache。

### 10.2 Dhrystone

Dhrystone 是小整数/控制流 benchmark，但当前数据强烈指向 LSU/RF ready。

| 指标 | 数值 | 判断 |
|---|---:|---|
| IPC | 1.887 | 高于 CoreMark，但仍受后端限制 |
| FE% | 8.59% | 前端不是主因 |
| BE% | 25.13% | 后端是主因 |
| retire_width_avg | 1.678 | 退休宽度仍未满 |
| zero_backend_raw | 25.96% | 后端 raw 明确 |
| rf_pipe5_src_no_rdy | 43.49/KI | 最突出的 RF 事件 |
| lsu_spec_fail_deep | 100.88/KI | 最突出的 LSU 事件 |
| ld_ag_cross_req | 48.35/KI | 地址相关路径明显 |
| st_ag_cross_req | 28.98/KI | store 地址相关路径明显 |
| ld_replay_pressure | 19.746 cycles | replay 代价大 |
| bht_bju_mispred | 0.10/KI | 分支不是主因 |

Dhrystone 的未来实验应该围绕：

1. `rf_pipe5_src_no_rdy` 的 producer 类型。
2. `lsu_spec_fail_deep` 的原因拆分。
3. Dhrystone 数据布局/栈/全局变量对齐。
4. load-use 依赖距离和 forward 时机。

### 10.3 bench_ilp

`bench_ilp` 是最纯粹的后端压力 case：

| 指标 | 数值 |
|---|---:|
| IPC | 0.770 |
| FE% | 1.45% |
| BE% | 66.46% |
| zero-retire | 77.68% |
| zero_backend_raw | 73.70% |
| iq_not_ready_width_avg | 11.34 |
| iq_select_width_avg | 0.78 |

这个 case 基本排除前端和 memory，适合专门研究整数后端 ready/select、依赖链、执行端口、wakeup。若优化 IQ/wakeup/select 有效，`bench_ilp` 应该最敏感。

### 10.4 bench_mem

| 指标 | 数值 |
|---|---:|
| IPC | 0.982 |
| zero_backend_raw | 49.80% |
| zero_memory_raw | 6.06% |
| lsu_spec_fail_deep | 25.92/KI |
| ld_ag_cross_req | 83.60/KI |
| ld_sq_data_discard_deep | 66.75/KI |
| lsiq_not_ready_avg | 4.99 |
| sdiq_not_ready_avg | 2.22 |

`bench_mem` 是 LSU store-load 相关性、SQ forwarding/discard、地址路径的核心验证 case。任何 LSU replay 优化都应该在这个 case 上看到明显指标下降。

### 10.5 SPEC kernel

| 类别 | Case | 主证据 | 研究重点 |
|---|---|---|---|
| 分支/flush 主导 | `spec_mcf_kernel`, `spec_mcf_sort_kernel`, `spec_deepsjeng_search_kernel`, `spec_povray_ray_kernel` | flush 和 BHT/BJU mispred 高 | predictor、BTB、BJU resolve、flush recovery |
| 前端供给明显 | `spec_cactubssn_stencil_kernel`, `spec_lbm_stream_kernel`, `spec_parest_sparse_kernel` | FE%、zero_frontend 高 | fetch、IBUF、redirect、后端反压 |
| LSU/地址相关明显 | `spec_mcf_kernel`, `spec_parest_sparse_kernel`, `spec_x264_pixel_kernel`, `spec_xz_lzma_kernel`, `spec_cactubssn_stencil_kernel` | `ld_ag_cross_req` 高 | AG/DC/DA、cross boundary、store-load |
| FP/VIQ 明显 | `spec_povray_ray_kernel`, `spec_lbm_stream_kernel`, `spec_cactubssn_stencil_kernel` | VIQ/AIQ 等待、BE 高 | VFPU、VIQ、长延迟、writeback |

SPEC kernel 的价值在于覆盖真实应用中的复杂混合瓶颈。后续优化不能只看 Dhrystone/CoreMark，必须用这些 kernel 做回归，防止优化只对小 benchmark 有效。

从研究角度看，benchmark 需要承担不同角色：

| 角色 | Benchmark | 用途 |
|---|---|---|
| 稳定回归 | CoreMark、Dhrystone | 检查常用整数路径是否退化，便于和历史结果比较 |
| 单机制放大 | `bench_ilp`、`bench_mem`、`bench_br_*`、`bench_fp` | 把后端调度、LSU、分支、FP 分开看 |
| 真实混合验证 | SPEC kernel | 验证优化是否能覆盖真实程序中的混合瓶颈 |

后续每个 RTL 优化都应该同时在这三类 benchmark 上验证。只在单机制 microbench 上变好，说明机制可能有效但泛化不足；只在 Dhrystone/CoreMark 上变好，可能是代码布局或编译形态命中；只有目标 microbench、目标真实 kernel、稳定回归 case 同时符合预期，才能认为优化方向可靠。

## 11. 体系结构技术路线与下一步计划

### 11.1 当前瓶颈定位的可信度

当前结论可以分成三类：高可信、较高可信、仍需验证。

| 结论 | 可信度 | 原因 | 还缺什么 |
|---|---|---|---|
| ROB/PREG 不是第一瓶颈 | 高 | `rtu_rob_full`、`rob_full_dbg`、`preg_alloc_block_avg` 在关键 case 中很低或为 0 | 后续优化后若窗口压力上升，需要重新检查 |
| L1 cache miss 不是当前主线 | 高 | CoreMark/Dhrystone miss 率低，但 IQ/LSU/FE/BE 仍明显 | 更大数据集、L2/外存场景需要单独验证 |
| Dhrystone 主要指向 LSU/RF ready/replay | 高 | `lsu_spec_fail_deep=100.88/KI`、`rf_pipe5_src_no_rdy=43.49/KI`、`ld_replay_pressure=19.746 cycles` 同时成立 | `rf_pipe5_src_no_rdy` producer 类型、`lsu_spec_fail` 具体原因 |
| CoreMark 是综合瓶颈 | 高 | FE、BE、IQ not-ready、LSIQ waiting、flush 都有贡献，没有单一极端事件 | 需要拆 FE stall 来源和 IQ producer |
| mcf/povray/deepsjeng 受 branch/flush 明显影响 | 较高 | `global_flush_zero_retire`、`bht_bju_mispred`、`zero_bad_spec_raw` 高 | mispred PC top-N、direction/target/indirect/RAS 分类 |
| cactu/lbm/parest 前端供给问题明显 | 较高 | FE% 和 `zero_frontend_raw` 高，同时 IQ not-ready 也高 | 区分真实前端不足与后端反压 |
| BIU/内存带宽不是主瓶颈 | 中等 | 当前 L1 miss 和 BIU handshake 不支持带宽主导 | outstanding 指标口径需修正，STREAM/大数据集需重测 |

因此，当前报告的瓶颈定位是准确的，但不是“最终归因”。它已经把问题从大类定位到微结构方向；下一步还需要把方向拆成可修改 RTL 的根因。

### 11.2 体系结构研究的主线

从乱序超标量处理器角度，后续研究应按以下依赖顺序推进：

```text
观测可信度
  -> root-cause 归因
    -> microbench 反证
      -> 小 RTL 改动
        -> 全量 benchmark 回归
          -> 性能/面积/时序/正确性权衡
```

不要直接从“IPC 低”跳到“扩大队列/增大 predictor/改 LSU”。每个改动前必须先形成一个可反证假设：

| 合格假设 | 不合格假设 |
|---|---|
| Dhrystone 的 `rf_pipe5_src_no_rdy` 主要由 load producer 晚 wakeup 导致 | Dhrystone 后端差，改 RF |
| `bench_mem ld_sq_data_discard_deep` 来自 SQ forwarding 数据晚到 | bench_mem 访存差，改 cache |
| `spec_mcf` 的 flush 主要来自少数 BHT direction miss PC | mcf 分支差，换 predictor |
| `coremark FE` 高主要是后端反压导致 IBUF full | CoreMark 前端差，改 I-cache |

后续应同时从四个角度验证同一个假设，避免单指标误导：

| 角度 | 方法 | 判断标准 |
|---|---|---|
| 计数器角度 | 看目标事件是否按预期下降，反证事件是否不恶化 | 例如 `lsu_spec_fail` 降低时，`global_flush`、`FE%`、功能结果不能变坏 |
| 波形角度 | 对 top case 抓取 producer-consumer、flush、replay、RF launch 片段 | 能在周期级看到“为什么等待”和“何时恢复” |
| microbench 角度 | 构造单变量对照，如 load-use、ready-heavy、branch-hot、FP-dep | 改动只影响对应机制，不应无差别改变所有 case |
| 全量回归角度 | 固定编译选项和结果目录，对所有 benchmark 重跑 | 目标 case 上升，非目标 case 不显著倒退 |

这四个角度共同构成可靠技术路线。计数器给全局统计，波形给因果链，microbench 给可反证实验，全量回归给泛化能力。只满足其中一个角度，都不足以支撑“瓶颈已经被解决”的结论。

### 11.3 技术路线一：后端调度、wakeup、select、RF launch

这是最高优先级，因为它同时影响 `bench_ilp`、CoreMark、Dhrystone 和多个 SPEC kernel。

| 阶段 | 工作 | 具体观测 | 可尝试改动 | 成功标准 |
|---|---|---|---|---|
| 1 | 拆 IQ not-ready producer | load/ALU/mult/div/FP/branch/CSR producer 分类 | 不改 RTL，只加计数 | 能解释 top case 的 not-ready 来源 |
| 2 | 拆 RF src_no_rdy producer | pipe x producer x age | 不改 RTL，只加计数 | 能解释 Dhrystone pipe5 |
| 3 | 检查 wakeup 提前/滞后 | producer ready 到 consumer ready 的间隔 | 调整 load/ALU/FP wakeup 提前量 | `iq_not_ready`、`rf_src_no_rdy` 下降 |
| 4 | 检查 select 仲裁 | ready 但未 select 的原因 | 调整 age/port/FU 优先级 | `iq_select_width_avg`、retire width 上升 |
| 5 | 检查 RF launch 条件一致性 | IS ready 但 RF fail 的具体原因 | 统一 IS/RF ready 判定或减少乐观发射 | `rf_lch_fail` 下降且 replay 不上升 |

核心架构问题：

1. 乱序窗口中是否积压大量“几乎 ready”的指令。
2. wakeup 是否过晚，导致可执行机会错过。
3. select 是否被端口、FU、年龄策略或队列划分限制。
4. RF launch 是否在重复做 IS 阶段没有判断准的事情。

这一线的收益判断不能只看 IPC，还要看：

| 目标指标下降 | 反证指标不能恶化 |
|---|---|
| `iq_not_ready_width_avg` | `global_flush_zero_retire` |
| `rf_pipe*_src_no_rdy` | `lsu_spec_fail_deep` |
| `rf_pipe*_lch_fail` | `FE%` |
| `*_wait_to_ready` | 功能正确性和 replay 次数 |

### 11.4 技术路线二：LSU replay、memory disambiguation、store-load forwarding

这是 Dhrystone、bench_mem、mcf、parest、x264、xz 的关键方向。

| 阶段 | 工作 | 具体观测 | 可尝试改动 | 成功标准 |
|---|---|---|---|---|
| 1 | 拆 `lsu_spec_fail_deep` | store-load violation、地址未知、cross boundary、cache/MMU replay | 不改 RTL，只加计数 | Dhrystone 100.88/KI 能分解到 1-2 个主因 |
| 2 | 拆 SQ forwarding | attempt/success/data late/addr conflict/global discard | 不改 RTL，只加计数 | bench_mem 66.75/KI 有明确来源 |
| 3 | 地址模式定位 | 触发 PC、地址低位、跨 cacheline/4K 分类 | 数据对齐 microbench | 判断硬件瓶颈还是 layout 触发 |
| 4 | 优化 replay 策略 | replay age、replay 次数、consumer 打回次数 | 调整 load/store speculation 或 replay throttling | `ld_replay_pressure` 和 RF src_no_rdy 同降 |
| 5 | 优化 forwarding/依赖预测 | SQ 命中、WMB forward、cancel | 改 forwarding 时机或依赖判定 | `ld_sq_data_discard` 下降，IPC 上升 |

关键架构问题：

1. load 是否过早执行，导致 store 地址/数据未确定后 replay。
2. store-load forwarding 是否因为数据晚到、地址未定或端口仲裁失败。
3. cross boundary 事件是否真实导致多周期 replay，还是计数器对某类普通访问过敏。
4. replay 是否反过来污染 wakeup/RF launch，造成后端连锁损失。

对 LSU 的优化风险更高，必须同时验证：

| 必须保持 | 原因 |
|---|---|
| 内存一致性 | store-load speculation 不能破坏程序语义 |
| 异常精确性 | replay/flush 必须保持精确状态 |
| forward 正确性 | 不能把错误 store 数据转发给 load |
| 性能不倒退 | 减少 spec fail 不能靠过度保守执行换来 |

### 11.5 技术路线三：分支预测、BTB/RAS、flush recovery

这是 mcf、povray、deepsjeng、branch microbench 的关键方向。

| 阶段 | 工作 | 具体观测 | 可尝试改动 | 成功标准 |
|---|---|---|---|---|
| 1 | mispred PC top-N | PC、类型、taken、目标、循环/间接/return 分类 | 不改 RTL，只加日志 | 找到贡献最大的少数热点 |
| 2 | 拆方向/目标/间接/RAS | BHT direction、BTB target、indirect target、RAS | 不改 RTL，只加分类 | 明确该改哪个 predictor |
| 3 | 检查 predictor update | update 延迟、wrbuf hit/full、alias | 调整 update 时机或缓冲 | mispred 和 flush 下降 |
| 4 | 检查 redirect latency | mispred/flush 到 fetch/id/retire | 优化 redirect bypass 或恢复路径 | `flush_to_fetch` 下降 |
| 5 | 改 predictor 结构 | 表大小、索引、历史、BTB/RAS/indirect 策略 | 小步参数实验 | mcf/povray/deepsjeng IPC 上升 |

这里要区分两个目标：

| 目标 | 对应指标 |
|---|---|
| 降低错误次数 | `bht_bju_mispred`、`l0_btb_mispred`、`ind_btb_miss`、`ras_mistaken` |
| 降低每次错误代价 | `flush_to_fetch`、`flush_to_id`、`flush_to_retire`、`zero_bad_spec_raw` |

当前数据更支持先降低错误次数，再看恢复延迟。

### 11.6 技术路线四：前端供给和后端反压解耦

前端高 stall 的 case 不能直接说“取指差”。需要先解耦：

| 情况 | 现象 | 应对 |
|---|---|---|
| 真前端不足 | IBUF empty、fetch invalid、I-cache/BTB/redirect 相关事件高 | 优化取指、BTB、I-cache/refill、redirect |
| 后端反压 | IBUF full、ID/IR stall、IQ/LSU/ROB 阻塞同周期高 | 先改后端，否则前端优化无效 |
| flush 导致前端丢弃 | flush 后 fetch/id 恢复片段多 | 先改分支/flush |
| 代码布局问题 | 少数 PC 导致取指断裂或 BTB miss | 调整布局或 predictor |

建议增加一个相关性矩阵：

| 横轴 | 纵轴 | 目的 |
|---|---|---|
| `ifu_ibuf_full` | `id_ir_stall` | 判断 IBUF full 是否由后端不消费导致 |
| `zero_frontend_raw` | `global_flush_zero_retire` | 判断前端气泡是否来自 flush |
| `icache_refill_busy` | `frontend_stall_episode` | 判断 I-cache refill 是否真主导 FE |
| `l0_btb_mispred` | `flush_to_fetch` | 判断目标错误和恢复延迟关系 |

### 11.7 技术路线五：FP/VIQ 和长延迟执行

FP/VIQ 目前不是 Dhrystone/CoreMark 主线，但对 `bench_fp`、`povray`、`lbm`、`cactu` 重要。

| 阶段 | 工作 | 具体观测 | 可尝试改动 |
|---|---|---|---|
| 1 | 拆 VIQ not-ready producer | FP producer、load producer、vreg conflict、FU busy | 不改 RTL，只加分类 |
| 2 | 拆 VFPU issue/wb | issue valid、gateclk issue、wb port、fwd vreg | 优化 issue/wb 仲裁 |
| 3 | 拆长延迟 FU | VFDSU busy、div/sqrt wait、consumer wait | 调整 wakeup 或调度 |
| 4 | FP microbench | 独立 FP、依赖 FP、FP+load 混合 | 分离吞吐瓶颈和依赖瓶颈 |

FP 线的验证必须使用 FP-heavy case，不能用 Dhrystone/CoreMark 判断。

### 11.8 技术路线六：实验方法和收敛标准

每一轮性能研究都应固定 baseline、固定编译选项、固定 benchmark 集合，然后只改变一个因素。建议把实验分成三类：

| 实验类型 | 改什么 | 不改什么 | 目的 |
|---|---|---|---|
| 观测增强实验 | 只加计数器和日志 | 不改功能 RTL、不改 benchmark | 把粗瓶颈拆成具体原因 |
| microbench 反证实验 | 改输入代码形态或数据布局 | 不改核心 RTL | 判断瓶颈是否由某类程序形态触发 |
| RTL 优化实验 | 只改一个微结构机制 | 固定编译器、benchmark、计数口径 | 验证机制改动是否真实提升性能 |

每个优化实验都应给出四类结果：

1. **性能结果**：IPC、CPI、retire width、benchmark score 是否提升。
2. **目标指标**：被优化机制的事件是否下降，例如 `iq_not_ready`、`lsu_spec_fail`、`global_flush`。
3. **反证指标**：其他机制是否恶化，例如 LSU 改动后分支 flush 或 FE stall 是否上升。
4. **正确性和工程代价**：程序结果是否正确，RTL 是否引入明显时序、面积、验证复杂度风险。

一项优化如果只提升 IPC，但目标指标没有按预期变化，不能认为根因判断正确；可能只是改变了代码布局、执行时序或统计噪声。一项优化如果目标指标下降但 IPC 不升，也不是失败，而是说明该机制不是当前主导，或者被下一级瓶颈接住了。真正可靠的收敛标准是：目标指标下降、IPC 上升、非目标指标不明显恶化，并且能在波形中看到因果链缩短。

### 11.9 推荐的阶段性里程碑

| 里程碑 | 目标 | 交付物 | 是否改功能 |
|---|---|---|---|
| M0 | 固化 baseline 和指标口径 | 当前 results、PERF_DETAIL 文档、分析报告 | 否 |
| M1 | 修正/确认计数器可信度 | BIU outstanding 修正，producer 分类计数 | 否 |
| M2 | 完成后端 root-cause 分解 | IQ/RF/LSU/branch 四张 root-cause 表 | 否 |
| M3 | 完成 microbench 反证 | load-use、ready-heavy、branch-hot、FP-dep microbench | 否 |
| M4 | 做第一组低风险 RTL 优化 | wakeup/ready/select 小改动 | 是 |
| M5 | 做 LSU 或 predictor 专项优化 | LSU replay 或 branch predictor 参数/逻辑实验 | 是 |
| M6 | 全量回归和论文式归因 | IPC、CPI stack、目标指标、反证指标、波形证据 | 是 |

### 11.10 当前最建议先做的三件事

1. **先拆 producer，不先改 RTL。**

   直接改 wakeup/LSU/predictor 现在还太早，因为当前证据定位到机制方向，但没有定位到具体 producer 和 PC。

2. **用 Dhrystone + bench_mem + bench_ilp 建立后端闭环。**

   Dhrystone 看 LSU/RF ready，bench_mem 看 SQ/forward/replay，bench_ilp 看纯调度/select。三者能把后端问题拆清楚。

3. **用 mcf + povray + deepsjeng 建立分支闭环。**

   这三个 case 的 flush/mispred 足够高，适合验证 predictor 和 flush recovery。不要只用 branch microbench，因为 microbench 可能过于人工。

### 11.11 风险和约束

1. 不要用单个 benchmark 代表处理器性能。Dhrystone、CoreMark、SPEC kernel 展示的是不同机制。
2. 不要把 `Frontend Stall` 直接等同于 I-cache miss。它可能来自 redirect、IBUF full、后端反压。
3. 不要把 `Backend Stall` 直接等同于 ROB 满。当前数据明确不支持 ROB/PREG 是第一瓶颈。
4. 不要把 `BIU outstanding` 直接当内存带宽证据。当前口径需要先修。
5. 不要只追编译选项带来的分数变化。硬件研究必须固定编译口径，比较同一 workload 下同一指标的变化。
6. 每次 RTL 改动都要同时看目标指标和反证指标。比如降低 `lsu_spec_fail` 后，如果 `global_flush` 或 `FE%` 上升，说明优化可能引入副作用。

最终判断：当前瓶颈分析已经足够准确，可以指导下一阶段研究；但当前还没有到“直接大改微结构”的阶段。正确路线是先把 producer、PC、原因分类补齐，然后做小步 RTL 实验，用指标闭环证明每一步改动确实击中了瓶颈。
