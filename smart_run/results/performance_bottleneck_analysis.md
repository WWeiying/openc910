# C910 性能瓶颈定位与优化路线报告

本文档基于新一版 `PERF_DETAIL` 全量结果分析当前 C910 RTL 仿真的性能瓶颈。分析目标不是只解释 Dhrystone 或 CoreMark 分数，而是把低 IPC 从退休端一路追到乱序后端的关键机制：IQ ready/wakeup/select、RF launch、LSU store-load 相关、分支 flush、前端供给和 FP/VIQ 路径。

## 1. 数据来源与结论摘要

本报告使用的新结果目录为：

`smart_run/results/all_cases_gcc_v3_1_0_perf_detail_f6043c027744_clean/`

对应提交：

`f6043c027744f7994b26fd23100d85aff3f87e90`

该目录由 `PERF_DETAIL` 版本生成，包含每个 case 的：

| 文件 | 用途 |
|---|---|
| `<case>.perf` | IPC、CPI、Frontend Stall、Backend Stall、cache miss、branch miss、LSU/RF 粗粒度事件 |
| `<case>.detail.perf` | 805 个 detail 事件、189 个 profile 平均值、54 个 latency 分布 |
| `<case>.summary.txt` | benchmark 成绩与运行摘要 |

所有结论默认使用 `Kernel` phase。`Kernel` phase 更接近 benchmark 热区，能减少初始化、打印、退出代码对数据的污染。

当前最重要的结论如下：

| 优先级 | 瓶颈方向 | 新指标证据 | 结论 |
|---|---|---|---|
| P0 | IQ not-ready 与 non-load dependency | `iq_not_ready_width_avg` 在多个 case 达到 10-16；`bench_ilp nonload_dep=18.693`、`coremark nonload_dep=8.385`、`dhrystone nonload_dep=4.697`，均远高于 load dependency | 当前主线不是简单 load-use，而是更广义的非 load producer、wakeup、依赖链和 select 效率问题 |
| P1 | IQ ready 后选择/发射效率 | `bench_branch ready_not_issued=1.655`、`spec_xz=1.598`、`dhrystone=1.183`；大量 case `iq_select_width_avg` 只有 0.78-2.05 | 一部分工作已经 ready，但没有稳定转化为 issue，说明队列选择、age 规则、端口/pipe 映射或 flush 干扰需要继续拆 |
| P2 | LSU/SQ/store-address 路径 | `dhrystone lsu_spec_fail_deep=100.883/KI`、`rf_pipe5_staddr_no_rdy=43.466/KI`、`sq_cancel=0.328/cyc`；`bench_mem sq_cancel=0.287/cyc`、`rf_pipe5_src0_no_rdy=26.572/KI` | Dhrystone/bench_mem 的访存问题不是 cache miss，而是 store address、SQ cancel/forward、LSU speculation/replay 和 RF ready 耦合 |
| P3 | 分支误预测与 flush | `spec_mcf bht_mis=88.356/KI`、`flush_zero=79.000/KI`；`spec_mcf_sort bht_mis=62.967/KI`；`spec_deepsjeng bht_mis=54.038/KI` | irregular SPEC kernel 中，分支错误和 flush 是低 IPC 的第一类原因之一 |
| P4 | 前端供给与后端反压混合 | `spec_cactubssn FE=53.73%`、`spec_lbm FE=41.19%`、`coremark FE=29.91%`，同时 IQ not-ready 也很高 | 前端参与瓶颈，但不能直接归因于 I-cache；很多前端 stall 可能来自 flush 或后端消费不动 |
| P5 | ROB/PREG 容量 | 关键 case 中 ROB full、PREG alloc block 不构成主证据 | 当前不应优先扩大 ROB/PREG，应该先解决 ready/select/replay/flush |

一句话概括：**当前处理器低 IPC 的主因是后端乱序窗口没有稳定变成有效发射和退休；新指标进一步说明，主要等待不是单纯 load-use，而是 non-load dependency、IQ select/age、RF/LSU store-address 和分支 flush 多条线叠加。**

## 2. 全量结果表

下表集中列出本报告使用的关键指标。

字段说明：

| 字段 | 含义 |
|---|---|
| `IPC` | Kernel phase 平均每周期退休指令数 |
| `FE/BE` | `<case>.perf` 中 Frontend Stall / Backend Stall 百分比 |
| `Zero` | `retire_width0_cycle`，无退休周期占比 |
| `IQnot` | `iq_not_ready_width_avg`，平均每周期 valid 但 not-ready 的 IQ 项数量 |
| `IQsel` | `iq_select_width_avg`，平均每周期被 issue/select 的 IQ 项数量 |
| `NLoad` | `iq_nonload_dep_not_ready_avg`，not-ready 源操作数中非 load/未知 producer proxy |
| `Load` | `iq_load_dep_not_ready_avg`，not-ready 源操作数中 load/vload producer proxy |
| `RNI` | `iq_ready_not_issued_avg`，ready 但未 issue 的 IQ 项数量 |
| `RFp5` | `rf_pipe5_src_no_rdy_avg`，pipe5 RF source no-ready 平均强度 |
| `SQcan` | `lsu_sq_cancel_width_avg` |
| `BHTmis` | `bht_bju_mispred` 每千指令次数 |

| Case | IPC | FE% | BE% | Zero% | IQnot | IQsel | NLoad | Load | RNI | RFp5 | SQcan | BHTmis/KI |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `bench_br_bimodal` | 2.089 | 5.75 | 14.12 | 33.38 | 6.05 | 1.98 | 4.13 | 0.00 | 0.20 | 0.00 | 0.00 | 3.53 |
| `bench_br_corr` | 1.860 | 28.34 | 35.58 | 34.19 | 9.68 | 1.87 | 10.74 | 0.00 | 1.23 | 0.00 | 0.00 | 1.00 |
| `bench_br_indirect` | 0.835 | 16.27 | 41.00 | 62.13 | 6.25 | 1.23 | 4.66 | 0.00 | 0.82 | 0.00 | 0.29 | 29.32 |
| `bench_br_ras` | 1.866 | 7.83 | 15.86 | 22.35 | 5.16 | 1.94 | 0.99 | 0.00 | 0.64 | 0.00 | 0.00 | 7.65 |
| `bench_branch` | 1.482 | 33.40 | 36.45 | 41.38 | 8.97 | 1.80 | 8.31 | 0.00 | 1.66 | 0.01 | 0.21 | 9.22 |
| `bench_cache_stride` | 1.232 | 6.46 | 30.81 | 50.50 | 4.83 | 1.53 | 1.75 | 0.22 | 0.32 | 0.05 | 0.00 | 39.38 |
| `bench_fp` | 1.366 | 10.45 | 48.36 | 54.27 | 9.74 | 1.29 | 7.84 | 0.35 | 0.02 | 0.00 | 0.03 | 6.46 |
| `bench_frontend` | 1.325 | 10.80 | 33.33 | 57.06 | 5.19 | 1.47 | 3.96 | 0.00 | 0.56 | 0.00 | 0.00 | 22.03 |
| `bench_ilp` | 0.770 | 1.45 | 66.46 | 77.68 | 11.34 | 0.78 | 18.69 | 0.00 | 0.01 | 0.00 | 0.00 | 2.28 |
| `bench_mem` | 0.982 | 5.19 | 22.70 | 55.07 | 10.25 | 1.79 | 5.47 | 0.10 | 0.04 | 0.03 | 0.29 | 2.59 |
| `coremark` | 1.544 | 29.91 | 34.21 | 36.12 | 11.06 | 1.64 | 8.38 | 0.00 | 0.59 | 0.00 | 0.01 | 7.28 |
| `dhrystone` | 1.887 | 8.59 | 25.13 | 28.81 | 12.13 | 2.58 | 4.70 | 0.24 | 1.18 | 0.08 | 0.33 | 0.10 |
| `spec_cactubssn_stencil_kernel` | 1.494 | 53.73 | 46.77 | 48.24 | 16.20 | 1.60 | 15.71 | 0.34 | 0.33 | 0.00 | 0.03 | 3.73 |
| `spec_deepsjeng_search_kernel` | 0.923 | 16.97 | 35.98 | 57.30 | 2.58 | 1.10 | 0.56 | 0.00 | 0.31 | 0.00 | 0.03 | 54.04 |
| `spec_exchange2_search_kernel` | 1.617 | 20.90 | 30.07 | 51.19 | 8.87 | 1.98 | 5.46 | 0.01 | 1.25 | 0.03 | 0.08 | 13.40 |
| `spec_lbm_stream_kernel` | 1.717 | 41.19 | 40.95 | 51.29 | 15.18 | 1.70 | 15.13 | 0.11 | 0.50 | 0.00 | 0.00 | 2.60 |
| `spec_leela_playout_kernel` | 1.053 | 22.77 | 45.20 | 63.67 | 9.73 | 1.28 | 7.21 | 0.03 | 0.51 | 0.01 | 0.02 | 27.00 |
| `spec_mcf_kernel` | 0.639 | 19.97 | 46.68 | 62.05 | 5.31 | 1.14 | 2.23 | 0.03 | 0.12 | 0.01 | 0.01 | 88.36 |
| `spec_mcf_sort_kernel` | 0.759 | 23.86 | 50.83 | 49.03 | 6.31 | 1.31 | 0.94 | 0.02 | 0.19 | 0.01 | 0.06 | 62.97 |
| `spec_parest_sparse_kernel` | 1.410 | 33.36 | 41.03 | 45.22 | 10.86 | 1.44 | 9.60 | 0.40 | 0.10 | 0.00 | 0.01 | 10.82 |
| `spec_povray_ray_kernel` | 0.671 | 31.98 | 49.17 | 71.99 | 10.15 | 1.03 | 10.80 | 0.22 | 0.14 | 0.00 | 0.00 | 47.38 |
| `spec_x264_pixel_kernel` | 1.833 | 26.46 | 32.79 | 44.71 | 10.62 | 1.96 | 9.83 | 0.07 | 0.75 | 0.00 | 0.00 | 7.68 |
| `spec_xz_lzma_kernel` | 1.712 | 10.48 | 24.85 | 44.34 | 9.62 | 2.05 | 7.49 | 0.08 | 1.60 | 0.01 | 0.03 | 11.09 |

## 3. 退休端现象：不是单点慢，而是流水线经常断供

低 IPC 最终都体现在退休端。几个代表 case：

| Case | IPC | Zero-retire% | 解释 |
|---|---:|---:|---|
| `bench_ilp` | 0.770 | 77.68% | 前端和访存几乎排除后，仍长期无退休，是后端 ready/select 的纯压力 case |
| `spec_povray_ray_kernel` | 0.671 | 71.99% | 分支、FP/VIQ、后端等待混合，退休端最差 |
| `spec_mcf_kernel` | 0.639 | 62.05% | 分支误预测、flush、后端低 select、LSU spec 叠加 |
| `bench_mem` | 0.982 | 55.07% | memory microbench 的无退休周期主要来自 LSU/SQ 和依赖链 |
| `dhrystone` | 1.887 | 28.81% | 总 IPC 不低，但离官方/高性能目标仍有差距，LSU/SQ/RF store-address 是关键 |

`retire_width0_cycle` 高不是根因，而是症状。后续所有分析都要回答：为什么这些周期没有可提交指令？新结果显示答案主要分成四类：IQ 中大量指令未 ready，部分 ready 指令没有被及时 issue，LSU store/load speculation 造成 replay/cancel，分支错误频繁 flush 窗口。

## 4. 第一主线：IQ not-ready 主要不是 load-use

新增的 `iq_load_dep_not_ready_avg` 和 `iq_nonload_dep_not_ready_avg` 改变了之前容易产生的直觉。很多 case 的 IQ not-ready 很高，但 load dependency proxy 很低，non-load/未知 producer proxy 明显更高。

典型对比：

| Case | IQnot | NLoad | Load | 判断 |
|---|---:|---:|---:|---|
| `bench_ilp` | 11.34 | 18.69 | 0.00 | 纯后端整数依赖/select 压力，基本不是 load-use |
| `spec_cactubssn_stencil_kernel` | 16.20 | 15.71 | 0.34 | 高 FE 之外，后端 non-load 依赖也很强 |
| `spec_lbm_stream_kernel` | 15.18 | 15.13 | 0.11 | 不是传统 cache miss 主导，更多是窗口内 producer/consumer 不顺 |
| `coremark` | 11.06 | 8.39 | 0.00 | CoreMark 的后端等待主要不是 load producer |
| `dhrystone` | 12.13 | 4.70 | 0.25 | 有 LSU 线索，但 IQ 等待大头仍不是 load dep proxy |
| `spec_povray_ray_kernel` | 10.15 | 10.80 | 0.22 | FP/branch 混合场景中 non-load 依赖显著 |

这里要注意一个计数口径：`NLoad` 和 `Load` 是按源操作数 proxy 统计，同一 entry 多个源未 ready 会重叠，所以它们不应与 `IQnot` 简单相加。正确读法是：它们告诉我们 not-ready 的来源倾向。当前倾向非常明确：**大多数 case 不是“load 结果回来太慢”一个解释能覆盖，而是 ALU/MUL/DIV/VFPU/CSR/特殊路径或未知 producer 造成的 non-load 等待占主导。**

这对优化方向很关键。若直接围绕 load-use 做大改，可能只改善 Dhrystone/bench_mem 的一部分，无法解释 `bench_ilp`、CoreMark、cactubssn、lbm、povray 这些更广泛的后端低效。下一步应该把 non-load producer 继续拆成 ALU、MUL、DIV、branch/CSR、VFPU、特殊传送路径，或者建立 per-entry trace，记录 IQ entry 从 create 到 ready、select、RF launch 的生产者类别和等待时间。

## 5. 第二主线：ready 后没有充分 issue

`ready_not_issued` 指标回答的是另一个问题：如果指令已经 ready，是否仍然没有被选中 issue。这个指标高时，瓶颈就不再是“操作数没来”，而是队列内 age-select、端口/pipe 映射、功能单元入口、flush 干扰或局部选择策略限制。

| Case | RNI | IQsel | 现象 |
|---|---:|---:|---|
| `bench_branch` | 1.655 | 1.80 | ready 工作存在，但 branch/flush/选择效率限制发射 |
| `spec_xz_lzma_kernel` | 1.598 | 2.05 | ready 后排队明显，适合查队列 age-select 和 pipe 映射 |
| `spec_exchange2_search_kernel` | 1.253 | 1.98 | ready-not-issued 与中等分支/后端 stall 混合 |
| `bench_br_corr` | 1.225 | 1.87 | branch microbench 中 ready 排队明显 |
| `dhrystone` | 1.183 | 2.58 | Dhrystone 不只是源等待，ready 后选择/发射也有损失 |
| `bench_ilp` | 0.007 | 0.78 | ILP case 的核心不是 ready 后排队，而是 ready 本身不足或 producer/wakeup 链不顺 |

`bench_ilp` 是最重要的反证 case。它 FE 只有 1.45%，SQ/LSU 基本不参与，`Load=0`，`RNI=0.007`，但 `IQnot=11.34`、`IQsel=0.78`、`NLoad=18.69`。这说明它的问题不是 ready 指令很多但 select 不出去，而是窗口里的指令长期没有变 ready，或者 non-load producer/wakeup 链条太保守。若未来优化 IQ wakeup/select，`bench_ilp` 必须明显改善；若只改善 Dhrystone 而 `bench_ilp` 不动，说明改动很可能只是命中了 LSU/store-address，而不是提升了通用后端调度能力。

## 6. 第三主线：Dhrystone 和 bench_mem 的 LSU 问题不同

新指标把原来笼统的 `rf_pipe5_src_no_rdy` 拆开后，Dhrystone 与 bench_mem 的差异非常清楚。

### 6.1 Dhrystone：store-address/SQ cancel/LSU spec fail

Dhrystone 关键数据：

| 指标 | 数值 |
|---|---:|
| IPC | 1.887 |
| FE / BE | 8.59% / 25.13% |
| `lsu_spec_fail_deep` | 100.883/KI |
| `ld_ag_cross_req` | 48.355/KI |
| `rf_pipe5_src_no_rdy_avg` | 0.082/cyc |
| `rf_pipe5_src0_no_rdy` | 0.019/KI |
| `rf_pipe5_staddr_no_rdy` | 43.466/KI |
| `sdiq_staddr_not_ready_avg` | 1.913/cyc |
| `lsu_sq_cancel_width_avg` | 0.328/cyc |
| `lsu_sq_fwd_width_avg` | 0.201/cyc |
| `ld_replay_pressure` latency | 19.746 cycles |

这组数据说明 Dhrystone 不是 L1D miss 主导，也不是普通 load-use 主导。`rf_pipe5_src0_no_rdy` 几乎没有，`rf_pipe5_staddr_no_rdy` 很高，说明 pipe5 的 RF no-ready 主要来自 store-address 条件，而不是普通源寄存器 src0。`sq_cancel` 和 `sq_fwd` 同时高，说明 store-load forwarding/取消访问/推测访问之间存在明显活动。`lsu_spec_fail_deep` 高达 100.883/KI，说明 LSU speculation/replay 的代价对 Dhrystone 分数非常关键。

因此，Dhrystone 的优化入口应该是：

1. 抓触发 `rf_pipe5_staddr_no_rdy` 的 PC，确认是否集中在少数 store 指令。
2. 抓 `sq_cancel_acc_req`、`sq_cancel_ahead_wb` 与 `lsu_spec_fail_deep` 的时间关系，判断是 store address 晚、forward 取消、还是 load ahead 策略过激。
3. 检查 `ld_ag_cross_req` 的地址低位分布，确认是否是数据布局/对齐导致的特殊路径。
4. 若是 store-address 晚导致，优化方向是 store address ready/wakeup、SDIQ ready 逻辑、store address 提前生成或更准确的 store-load dependency 判断。
5. 若是 load ahead/cancel 过多，优化方向是 LSU memory dependence predictor、SQ forwarding/cancel 策略和 replay 恢复成本。

### 6.2 bench_mem：普通地址源 src0 与 SQ cancel

bench_mem 关键数据：

| 指标 | 数值 |
|---|---:|
| IPC | 0.982 |
| FE / BE | 5.19% / 22.70% |
| `ld_ag_cross_req` | 83.603/KI |
| `lsu_spec_fail_deep` | 25.924/KI |
| `rf_pipe5_src_no_rdy_avg` | 0.027/cyc |
| `rf_pipe5_src0_no_rdy` | 26.572/KI |
| `rf_pipe5_staddr_no_rdy` | 0.486/KI |
| `lsu_sq_cancel_width_avg` | 0.287/cyc |
| `lsu_sq_fwd_width_avg` | 0.095/cyc |

bench_mem 与 Dhrystone 不同。它的 RF pipe5 no-ready 主要是 `src0`，不是 `staddr`。这更像 load/store 地址基址依赖或地址生产者晚到。它同样有 SQ cancel 和 cross request，但 store-address 条件不是主要 RF no-ready 来源。

因此，bench_mem 的优化入口应该是：

1. 抓 `rf_pipe5_src0_no_rdy` 的 consumer PC 和 producer PC。
2. 判断 src0 producer 是 ALU 地址计算、load forward、还是其他特殊路径。
3. 检查 address generation 链条是否有过长的 producer-consumer 距离，或者 wakeup 提前/延后不准确。
4. 与 Dhrystone 分开优化：Dhrystone 偏 store-address/SQ cancel，bench_mem 偏地址源 producer 和 SQ cancel。

### 6.3 bench_cache_stride：cross path 很高但不是 SQ cancel

bench_cache_stride 数据：

| 指标 | 数值 |
|---|---:|
| IPC | 1.232 |
| `ld_ag_cross_req` | 179.553/KI |
| `rf_pipe5_staddr_no_rdy` | 42.239/KI |
| `lsu_sq_cancel_width_avg` | 0.000/cyc |
| `lsu_spec_fail_deep` | 0.000/KI |

这个 case 说明 `ld_ag_cross_req` 高不一定等于 replay/cancel 高。它更像地址模式、跨界或特殊地址路径压力。它适合用来验证地址对齐、cross-page/cross-boundary 判断和 AG 特殊路径优化；但不适合直接验证 SQ cancel 策略。

## 7. 第四主线：SPEC irregular 的 branch/flush 是独立大问题

分支和 flush 对 SPEC irregular kernel 的影响非常强。典型数据：

| Case | IPC | BHTmis/KI | Flush/KI | Zero% | 判断 |
|---|---:|---:|---:|---:|---|
| `spec_mcf_kernel` | 0.639 | 88.356 | 79.000 | 62.05% | 分支错误和 flush 是第一主因之一，同时有 LSU spec/cross |
| `spec_mcf_sort_kernel` | 0.759 | 62.967 | 62.240 | 49.03% | sort/search 类控制流不规则，branch/flush 主导明显 |
| `spec_deepsjeng_search_kernel` | 0.923 | 54.038 | 53.910 | 57.30% | 搜索类分支错误高，低 IPC 不能只看 IQ |
| `spec_povray_ray_kernel` | 0.671 | 47.375 | 38.550 | 71.99% | 分支、FP/VIQ、后端等待混合，最差之一 |
| `bench_br_indirect` | 0.835 | 29.315 | 29.120 | 62.13% | microbench 级验证 indirect/target/RAS 方向 |

这些 case 的优化路线不能只用 Dhrystone/CoreMark 来验证。Dhrystone 的分支误预测只有 0.097/KI，几乎不能反映 predictor 问题。若目标是提升 SPEC 类工作负载，必须单独建立 branch 线：

1. 把 `bht_bju_mispred` 拆成 direction、target、indirect、RAS、BTB miss/alias。
2. 统计每次 mispred 到 fetch、ID、retire 的恢复时间和窗口损失。
3. 对 mcf/deepsjeng/povray 抓 top mispred PC，判断是否是少数热点分支。
4. 若热点是 direction 错，研究 BHT/PHT 历史长度、全局历史折叠、alias。
5. 若热点是 target/indirect 错，研究 BTB/indirect predictor/RAS，而不是改 BHT。

## 8. 第五主线：前端高 stall 不能直接等于 I-cache 差

前端 stall 高的 case：

| Case | FE% | IQnot | NLoad | BHTmis/KI | 判断 |
|---|---:|---:|---:|---:|---|
| `spec_cactubssn_stencil_kernel` | 53.73 | 16.20 | 15.71 | 3.73 | FE 很高，但后端 non-load 等待也极强 |
| `spec_lbm_stream_kernel` | 41.19 | 15.18 | 15.13 | 2.60 | 更像前后端互相影响，不是纯 I-cache |
| `coremark` | 29.91 | 11.06 | 8.39 | 7.28 | FE、后端、branch、IQ 混合 |
| `spec_povray_ray_kernel` | 31.98 | 10.15 | 10.80 | 47.38 | FE 高受分支和后端共同影响 |

如果一个 case 同时 FE 高、IQnot 高、NLoad 高，那么不能直接说“前端取不到指令”。后端消费不动会让前端缓冲变满，分支 flush 会让前端反复重定向，I-cache refill 只解释其中一部分。前端优化应先做 PC 级别供给分析：

1. 统计 IBUF empty、IBUF full、PCFIFO full、I-cache refill busy、BTB miss、flush_to_fetch 的重叠关系。
2. 对 FE 高 case 抓取前端断供 PC，判断是 cache line/refill、branch redirect，还是后端 backpressure。
3. 若 `icache_refill_busy` 低但 FE 高，优先查 flush 和后端反压。
4. 若 `icache_refill_busy`、`biu_ar_to_rlast` 高，才考虑 I-cache/BIU latency。

## 9. FP/VIQ 与 spec_povray 需要单独研究

`spec_povray_ray_kernel` IPC 只有 0.671，Zero-retire 71.99%，BE 49.17%，BHTmis 47.375/KI，IQnot 10.15，NLoad 10.80。它不是单纯分支问题，也不是 LSU 问题，RF pipe5 和 SQ cancel 几乎不参与。它更可能是 FP/VIQ/长延迟执行、分支和前端混合。

当前新增指标已经覆盖 VFPU/VIQ 基本活动，但 non-load producer 仍未精确拆分到 VFPU producer。因此 FP 线下一步应该增加或使用：

1. VIQ not-ready by producer class。
2. VFPU pipe6/pipe7 busy、issue、wb、forward、vreg conflict 的 PC 关联。
3. FDSU/长延迟指令 active episode 与消费者等待时间。
4. povray/bench_fp 的 top waiting PC 和 producer-consumer trace。

不能用 Dhrystone 或 CoreMark 判断 FP 路径优化是否有效。FP 路径必须用 `bench_fp`、`spec_povray_ray_kernel` 和其他 FP/vector case 单独闭环。

## 10. 排除性结论和准确性边界

本报告把 ROB/PREG 容量排在低优先级，不是因为窗口容量永远不重要，而是因为当前结果没有显示它是第一瓶颈。代表 case 的容量相关数据如下：

| Case | ROB occ avg | ROB >=64 | ROB full | PREG block | PREG avail |
|---|---:|---:|---:|---:|---:|
| `bench_ilp` | 0.013 | 0.00% | 0.00% | 0.000 | 3.989 |
| `dhrystone` | 0.248 | 0.00% | 0.00% | 0.000 | 3.935 |
| `coremark` | 0.154 | 0.00% | 0.00% | 0.000 | 3.931 |
| `spec_mcf_kernel` | 0.611 | 0.00% | 0.00% | 0.000 | 3.745 |
| `spec_povray_ray_kernel` | 0.480 | 0.00% | 0.00% | 0.000 | 3.870 |

这组数据支持一个有限但重要的判断：当前第一轮优化不应从扩大 ROB 或物理寄存器数量开始。若后续 wakeup/select、LSU replay、分支 flush 被改善，窗口压力可能会上升，到那时需要重新检查 ROB/PREG 是否变成新瓶颈。

还需要保留几个准确性边界：

1. `NLoad` 和 `Load` 是源操作数级 proxy，不是逐指令互斥分类；同一 IQ entry 多个源未 ready 时会重复计数。
2. `NLoad` 只说明“不是 dep-entry 的 load match”，还不能区分 ALU、MUL、DIV、VFPU、CSR 或特殊路径。
3. `producer_*_avg` 是 producer 活动强度，不等于 consumer 正在等待该 producer 的精确归因。
4. `FE%` 高不能直接等于 I-cache 差，因为后端反压和 branch flush 都可能让前端看起来停顿。
5. 本报告使用 Kernel phase，适合分析 benchmark 热区；若研究启动、初始化或 OS/异常路径，需要单独看 Main/Total。

## 11. 当前不应优先做的事情

以下方向不是完全没价值，但不应作为第一批优化：

| 方向 | 原因 |
|---|---|
| 直接扩大 ROB | 当前低 IPC case 的证据更集中在 ready/select/replay/flush，代表 case 中 ROB full 近似为 0 |
| 直接扩大 PREG/FREG free list | `preg_alloc_block_avg` 为 0，PREG 可用宽度没有显示为主瓶颈 |
| 只优化 L1D miss | Dhrystone/CoreMark/bench_mem 的核心不是 L1D miss 率 |
| 只优化 I-cache | FE 高 case 同时有后端和 branch 证据，I-cache 不是唯一解释 |
| 只用 Dhrystone 验证优化 | Dhrystone 主要暴露 LSU/store-address/SQ cancel，不能代表 branch、FP、通用后端 |
| 只看平均 IPC | 必须同时看目标机制指标是否下降，否则可能只是代码布局或仿真噪声 |

## 12. 后续优化路线

### 12.1 第一阶段：把 non-load producer 精确拆开

当前 P0 最大不确定性是 `iq_nonload_dep_not_ready_avg`。它告诉我们“不是 load producer”，但还不能告诉我们到底是 ALU、MUL、DIV、branch/CSR、VFPU 还是特殊路径。

建议新增或临时 trace：

| 工作 | 目标 |
|---|---|
| 在 IQ/dep-entry 或 testbench trace 中记录 producer class | 把 non-load 等待拆成 ALU/MUL/DIV/VFPU/CSR/branch |
| 记录 entry create、source ready、issue、RF fail、retire/flush 时间 | 形成每条指令的生命周期 |
| 记录 consumer PC 与 producer PC | 找 top 等待链条 |
| 对 `bench_ilp`、CoreMark、cactubssn、povray 优先分析 | 覆盖通用后端、真实混合 workload 和 FP-heavy workload |

成功标准：

1. 能解释 `bench_ilp NLoad=18.693` 的主要 producer 类型。
2. 能解释 CoreMark `NLoad=8.385` 是否来自 ALU 链、branch/CSR、还是特殊路径。
3. 能解释 povray `NLoad=10.803` 是否主要来自 VFPU。

### 12.2 第二阶段：优化 IQ wakeup/select

若 producer trace 证明等待来自 wakeup 晚、ready 保守或 select 入口不足，可以研究：

| 方向 | 适用证据 | 验证指标 |
|---|---|---|
| 改善 wakeup 提前量或 forward ready 条件 | not-ready 高、producer 活动足够但 consumer 晚 ready | `iq_not_ready_width_avg`、`iq_wait_to_ready` 下降 |
| 优化 per-queue select/age | `ready_not_issued` 高 | `iq_ready_not_issued_avg` 下降，`iq_select_width_avg` 上升 |
| 调整 pipe 映射或端口竞争 | 某队列 ready 高但 issue 低 | `*_issue_select_avg` 上升 |
| 减少 flush 对 select 的打断 | branch/flush case | `global_flush_zero_retire`、`ready_not_issued` 下降 |

优先验证 case：

| 目标机制 | case |
|---|---|
| 纯后端 wakeup/select | `bench_ilp` |
| 混合整数实际 workload | `coremark` |
| ready-not-issued | `bench_branch`、`spec_xz_lzma_kernel`、`dhrystone` |
| 高 non-load dependency | `spec_cactubssn_stencil_kernel`、`spec_lbm_stream_kernel` |

### 12.3 第三阶段：优化 LSU store-address/SQ cancel

Dhrystone、bench_mem、bench_cache_stride 应分开看：

| case | 主要 LSU 现象 | 优化入口 |
|---|---|---|
| `dhrystone` | `rf_pipe5_staddr_no_rdy=43.466/KI`、`sq_cancel=0.328/cyc`、`lsu_spec=100.883/KI` | store address ready、SDIQ staddr、SQ cancel/forward、memory dependence prediction |
| `bench_mem` | `rf_pipe5_src0_no_rdy=26.572/KI`、`sq_cancel=0.287/cyc`、`ld_cross=83.603/KI` | 地址 src0 producer、AG 输入 ready、load/store dependency |
| `bench_cache_stride` | `ld_cross=179.553/KI`，但 SQ cancel/spec fail 低 | 地址模式、cross-boundary、alignment 特殊路径 |

成功标准：

1. Dhrystone 中 `rf_pipe5_staddr_no_rdy`、`sdiq_staddr_not_ready_avg`、`sq_cancel`、`lsu_spec_fail_deep` 下降。
2. bench_mem 中 `rf_pipe5_src0_no_rdy`、`sq_cancel`、`ld_ag_cross_req` 下降。
3. bench_cache_stride 中 `ld_ag_cross_req` 或相关 AG 特殊路径代价下降。
4. 改动不能让 `bench_ilp`、branch case、FP case 明显倒退。

### 12.4 第四阶段：分支预测和 flush 恢复

SPEC irregular 需要独立路线：

| case | 主要问题 |
|---|---|
| `spec_mcf_kernel` | BHT mis/KI 最高，同时 flush 与 LSU spec 叠加 |
| `spec_mcf_sort_kernel` | branch/flush 主导明显 |
| `spec_deepsjeng_search_kernel` | 搜索类控制流，BHT mis 高 |
| `spec_povray_ray_kernel` | branch + FP/后端混合 |
| `bench_br_indirect` | indirect/target 类 microbench 验证 |

建议先增加预测错误分类，而不是直接改 predictor：

1. direction mispredict。
2. target/BTB miss。
3. indirect target miss。
4. RAS mistaken。
5. alias/update late。

成功标准：

1. `bht_bju_mispred`、`global_flush_zero_retire` 下降。
2. `flush_to_fetch`、`flush_to_id`、`flush_to_retire` 不变差或下降。
3. mcf/deepsjeng/povray 提升，同时 Dhrystone/CoreMark 不倒退。

## 13. 推荐研究顺序

建议按下面顺序推进，不要一次改多个机制：

1. **补 producer class trace**
   目标是解释 `NLoad`。这是当前最大信息缺口，也是后续优化是否准确的前提。

2. **用 `bench_ilp` 做纯后端验证**
   它排除了前端和 LSU，最适合验证 wakeup/select/producer-ready 改动。

3. **用 Dhrystone/bench_mem 拆 LSU**
   Dhrystone 查 store-address 和 SQ cancel；bench_mem 查 src0 地址 producer 和 SQ cancel。

4. **用 mcf/deepsjeng/povray 拆 branch/flush**
   先分类错误，再改 predictor 或恢复路径。

5. **用 CoreMark 做综合回归**
   CoreMark 混合了前端、后端、分支和整数依赖，适合作为最终综合指标，不适合作为单机制定位的唯一依据。

6. **每次 RTL 改动都同时看机制指标和 IPC**
   例如优化 LSU 不能只看 Dhrystone IPC，还要确认 `rf_pipe5_staddr_no_rdy`、`sq_cancel`、`lsu_spec_fail_deep` 是否下降；优化 IQ 不能只看 CoreMark IPC，还要确认 `iq_not_ready_width_avg`、`NLoad`、`iq_select_width_avg` 是否朝预期变化。

## 14. 最终判断

基于新一版细粒度结果，当前最可靠的瓶颈定位是：

1. **全局第一瓶颈是后端 IQ ready/select 效率，不是 cache miss，也不是 ROB/PREG 容量。**
2. **IQ 等待的主因在多数 case 中不是 load dependency，而是 non-load/未知 producer dependency。**
3. **Dhrystone 的特殊瓶颈是 LSU store-address、SQ cancel/forward、LSU spec fail 与 RF pipe5 staddr no-ready。**
4. **bench_mem 与 Dhrystone 不同，它更偏 pipe5 src0 地址源等待和 SQ cancel。**
5. **SPEC irregular 的分支误预测和 flush 是独立大问题，必须单独优化。**
6. **前端 stall 高的 case 不能直接归因为 I-cache，需要与后端反压和分支 flush 一起拆。**
7. **下一步最有价值的工作不是继续盲加计数器，而是把 non-load producer 精确分类，并围绕 bench_ilp、Dhrystone、mcf 三类代表 case 做单机制优化闭环。**
