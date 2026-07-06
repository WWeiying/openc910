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
| `<case>.detail.perf` | 805 个 detail 事件、189 个 profile 平均值、54 个 latency 分布 |
| `<case>.summary.txt` | benchmark 成绩与运行基本信息 |

分析口径：

1. 表格默认使用 `Kernel` phase。`Kernel` 更接近 benchmark 热区，避免初始化、打印、结束代码污染。
2. `Per KInst` 表示每 1000 条退休指令发生次数。
3. `Zero retire%` 是 `retire_width0_cycle` 周期占比，表示该周期没有指令退休。
4. `zero_*_raw` 是 testbench CPI proxy 的 raw 分类，允许同周期多原因重叠，不能简单相加为 100%。
5. `BIU outstanding` 当前有口径风险，只作为参考，不作为主瓶颈证据。
6. 指标含义和准确性边界见 [PERF_DETAIL.md](/home/wangwy/openproject/openc910/smart_run/PERF_DETAIL.md:1)。

### 2.1 C910 流水线中的瓶颈定位坐标

`doc/idu/00_idu_overview.md` 对 C910 前后端关系的描述非常关键：IFU 负责“取什么指令”，IDU 负责“指令怎么调度执行”，RTU 负责按程序顺序退休。性能分析也应该沿着这条路径推进，而不是只看一个总分。

```text
IFU 取指/预测
  -> ID 译码
    -> IR 重命名/分配 ROB 与物理寄存器
      -> IS 发射队列分配、唤醒、选择
        -> RF 读寄存器、前递、launch fail 检查
          -> IU / LSU / VFPU 执行
            -> RTU 按序退休或 flush 恢复
```

这条链路里，每一级都有不同的“性能失败形态”：

前端失败通常表现为取指供给断裂、BTB/BHT/RAS 预测错误、I-cache refill、IBUF 空或重定向恢复慢。它会反映到 `FE%`、`zero_frontend_raw`、`icache_refill_busy`、`l0_btb_*`、`flush_to_fetch` 等指标上。但前端指标要谨慎读，因为如果后端不消费，IBUF 也可能满，前端看起来也会停。

重命名和窗口容量失败通常表现为 ROB 满、物理寄存器不足、rename/dispatch 被阻塞。如果这是主因，应该看到 `rtu_rob_full`、`rob_full_dbg`、`preg_alloc_block_avg`、IQ full 等指标持续升高。当前结果不支持这个方向，所以报告不建议第一步扩大 ROB 或 PREG。

乱序调度失败通常发生在 IS/RF。IS 阶段的核心是 wakeup-select：队列项等 producer，就绪后被 select 发射。RF 阶段进一步检查物理寄存器读取、前递、执行单元选择和 launch 条件。若 IS 认为可以发射，但 RF 发现源不 ready 或端口/前递条件不满足，就会出现 launch fail。当前 `iq_not_ready_width_avg`、`iq_select_width_avg`、`rf_pipe*_src_no_rdy` 的组合，正是把瓶颈指向这一区域的主要证据。

LSU 失败更复杂，因为 load/store 既要参与乱序执行，又必须保持内存顺序语义。LSIQ/SDIQ 发射后，load 在 AG/DC/WB 多级中可能先推测唤醒消费者，之后再由 cache 命中、store forwarding、地址比较、spec fail 决定是否继续有效。若推测过早或相关性判断失败，load replay 会反向污染 IQ/RF ready。这也是 Dhrystone 和 bench_mem 的核心问题。

RTU 退休端是最终观察点。`retire_width_avg` 低和 `retire_width0_cycle` 高不是根因，而是所有上游问题的最终表现。分析要从 RTU 看到的低退休吞吐向前回溯，找到到底是前端供给断、分支 flush、IQ/RF 不能发射，还是 LSU replay 让消费者反复等待。

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

### 3.1 核心指标解释与读法

这一节解释后文反复使用的关键指标。理解这些指标时要先抓住一条主线：处理器性能最终由退休端体现，低 IPC 一定会表现为某些周期没有足够指令退休；然后再从退休端向前追，判断是前端没供给、分支清空、后端未就绪、访存 replay，还是资源容量限制。

| 指标 | 所属阶段 | 它在回答什么问题 | 数值高通常意味着什么 | 当前报告中的用法 |
|---|---|---|---|---|
| `IPC` | 全局结果 | 平均每周期退休多少条指令 | 越高越好；低 IPC 只说明结果差，不说明原因 | 用来判断最终性能，但不直接归因 |
| `FE%` | 粗粒度前端 | 前端相关 stall 占比 | 可能是取指、I-cache、BTB、redirect、IBUF，也可能是后端反压造成 | 只作为前端参与瓶颈的入口，不能单独归因 |
| `BE%` | 粗粒度后端 | 后端相关 stall 占比 | 可能是 IQ、RF、LSU、执行单元、ROB head、replay 等 | 用来判断是否需要深入后端 |
| `retire_width_avg` | RTU/退休 | 平均每周期真正提交多少条指令 | 低说明完成并可提交的指令不足 | 判断乱序宽度是否被有效利用 |
| `retire_width0_cycle` / `Zero%` | RTU/退休 | 有多少周期一条也没退休 | 高说明流水线经常无法向软件可见状态推进 | 所有瓶颈最终都要解释它为什么高 |
| `zero_bad_spec_raw` / `Zbad` | CPI proxy | zero-retire 周期中是否有错误推测因素 | 分支误预测、错误路径、flush 影响较大 | 用于判断 branch/flush 是否主导 |
| `zero_frontend_raw` / `Zfe` | CPI proxy | zero-retire 周期中是否有前端供给因素 | fetch/redirect/IBUF/I-cache 或后端反压造成前端气泡 | 用于判断前端是否需要进一步拆分 |
| `zero_memory_raw` / `Zmem` | CPI proxy | zero-retire 周期中是否有 memory 因素 | 可能是 cache miss、LSU 队列、BIU、load/store replay | 当前多数 case 不高，所以外部 memory 不是主线 |
| `zero_backend_raw` / `Zbe` | CPI proxy | zero-retire 周期中是否有后端 core 因素 | IQ 未就绪、RF launch 失败、执行端口、ROB head 等 | 当前最强的粗粒度后端证据 |
| `iq_not_ready_width_avg` | IDU/Issue Queue | 队列里平均有多少 valid 但不能发射的项 | 操作数未 ready、producer 晚、wakeup/forward 保守、长依赖链 | 当前 P0 瓶颈的核心指标 |
| `*_src*_not_ready_avg` | IDU/Issue Queue | 各 IQ not-ready entry 分别在等哪个源操作数 ready | 可区分 src0/src1/src2、srcv0/srcv1/srcv2、srcvm、SDIQ store-address 条件 | 新增源操作数级拆分；可定位等待入口，但仍不是 producer 类型 |
| `*_load_dep_not_ready_avg` | IDU/Issue Queue | not-ready 源操作数中带有 dep-entry `lsu_match` 的数量 | 可区分等待 load/vload producer 与等待非 load/未知 producer | 这是 producer 粗分类 proxy，不是完整 producer 类型 |
| `iq_select_width_avg` | IDU/Issue Select | 平均每周期有多少 IQ 项被选中发射 | 低说明 ready 指令少、select/端口受限或被 flush/replay 打断 | 与 `iq_not_ready` 配合判断调度效率 |
| `*_issue_select_avg` | IDU/Issue Select | 各个 IQ 平均每周期被 `issue_en` 选中的 entry 数 | 可区分 AIQ/BIQ/SDIQ/VIQ 哪个队列 age-select 后发射候选不足；LSIQ 口径等同 ready | 和同队列 ready/not-ready/ready-not-issued 配合使用 |
| `*_ready_not_issued_avg` | IDU/Issue Select | 各个 IQ 已 ready 但没有 `issue_en` 的 entry 数 | ready 工作被队列内 older-ready age-select 压住 | 如果高，说明瓶颈不再是源操作数 ready，而是队列选择排队或执行入口吞吐；LSIQ 通常不贡献该项 |
| `rf_pipe*_src_no_rdy` | IDU/RF | 指令进入 RF 后发现源操作数仍未就绪 | IS 阶段过于乐观、producer 晚、forward/wakeup 时序不准 | Dhrystone 中 `pipe5` 异常高，指向 LSU/RF 耦合 |
| `rf_pipe*_src*_no_rdy` / `rf_pipe*_srcv*_no_rdy` | IDU/RF | RF 阶段逐 pipe、逐源操作数确认哪个 operand 未就绪 | 能把 pipe 级 no-ready 继续拆到 src0/src1/src2/srcv0/srcv1/srcv2/srcvm/staddr | 用来解释 `rf_pipe5_src_no_rdy` 到底是 store 地址、store 数据还是普通源等待 |
| `rf_pipe*_preg/vreg/*_fail` | IDU/RF | RF launch fail 中非普通源未就绪的子原因 | PREG/VREG 读条件、vdiv/mtvr、mfvr、vmul unsplit 等特殊结构限制 | 用来区分“等待 producer”和“RF/寄存器端口/特殊执行路径限制” |
| `rf_pipe*_lch_fail` | IDU/RF | RF launch 总失败次数 | 源未就绪、读端口冲突、forward 不满足、结构条件不满足 | 用来判断 issue 到 RF 之间是否存在打回 |
| `lsiq_not_ready_avg` | LSU IQ | load 侧队列中 valid 但未 ready 的项 | load 依赖、地址生成、cache/DC/DA、replay、forward 等等待 | 判断 load 路径是否参与瓶颈 |
| `sdiq_not_ready_avg` | LSU IQ | store 侧队列中 valid 但未 ready 的项 | store 地址/数据等待、WMB/SQ、store commit 路径压力 | 判断 store 路径是否参与瓶颈 |
| `lsu_spec_fail_deep` | LSU/RTU | LSU 推测失败或相关深层 spec fail 事件 | load/store 顺序、地址未知、forward 失败、replay 等可能较多 | Dhrystone 和 mcf 的核心 LSU 证据 |
| `lsu_replay_*` / `sq_*fwd*` / `sq_cancel_*` | LSU/SQ | replay discard、SQ forward、SQ cancel 的细分事件 | 判断 store-load forwarding 是顺利供数，还是伴随 cancel/discard/replay | 用来把 LSU/RF 耦合拆到 SQ forward 或 replay 子路径 |
| `lsu_*wait_old` / `lsu_*_full_from_idu` | LSU/ordering/resource | 等待更老访存、LQ/SQ/RB 对 IDU 可见 full | 判断 LSU 是否因 memory ordering 或队列资源限制上游 | 若这些高，优化方向不同于单纯 forward/wakeup |
| `producer_*_wakeup` | IDU/IU/LSU/VFPU | ALU、mult/div、load/vload、VFPU producer 活动 | 粗看 producer 结果/前递活动是否足够、是否与消费者等待错位 | 它不是消费者等待 producer 类型的精确分类，只能辅助解释 |
| `ld_ag_cross_req` | LSU AG | load 地址生成阶段触发 cross/boundary 类请求 | 跨边界、split、地址特殊路径或相关 replay 风险 | 判断是否是地址模式触发 LSU 特殊路径 |
| `ld_sq_data_discard_deep` | LSU/SQ | load 从 SQ 取数或相关路径发生 discard | store-load forwarding 数据晚到、地址冲突、SQ 相关性失败 | bench_mem 的核心证据 |
| `ld_replay_pressure` | LSU/replay | load replay 造成的平均压力或等待 | replay 不只是次数多，而且每次代价可能大 | 判断 LSU replay 是否会传导到 RF/IQ |
| `bht_bju_mispred` | IFU/BJU | BHT/BJU 相关条件分支误预测事件 | 条件分支方向预测错误频繁 | mcf、deepsjeng、povray 的核心 branch 证据 |
| `global_flush_zero_retire` | RTU/flush | flush 相关 zero-retire 事件 | 错误路径清空、重定向恢复、窗口重新填充成本高 | 判断误预测或 spec fail 的性能代价 |
| `ifu_ibuf_full` | IFU/IBUF | IBUF 满导致前端停顿或反压 | 可能是后端消费不动，不一定是前端取不到指令 | 区分真实前端不足和后端反压 |
| `icache_refill_busy` | I-cache | I-cache refill 正在忙 | I-cache miss/refill 可能影响取指 | 当前不是 CoreMark/Dhrystone 主证据 |
| `biu_ar_hs_deep` / `biu_rlast_hs_deep` | BIU/AXI | 外部读请求发出和返回完成情况 | 外部读事务活跃；需结合 latency/backpressure | 用于判断外部 memory，而不是单看 outstanding |
| `biu_rd_outstanding_avg` | BIU/AXI | testbench 维护的读 outstanding 平均值 | 可能表示外部读并发，也可能受 phase 口径影响 | 当前只作参考，不作主证据 |

### 3.2 指标组合如何形成瓶颈证据

单个指标通常不能直接证明瓶颈。比较可靠的判断方式是看一组指标是否共同指向同一条流水线机制，并且能排除其他解释。

| 指标组合 | 说明 | 可以支持的结论 | 仍需避免的误判 |
|---|---|---|---|
| `IPC` 低 + `retire_width_avg` 低 + `Zero%` 高 | 性能差最终体现在退休端 | 流水线不能稳定产出可提交指令 | 还不知道原因，需要继续拆 |
| `Zbe` 高 + `iq_not_ready` 高 + `iq_select` 低 | 后端窗口里很多指令不能发射 | ready/wakeup/select 是主嫌疑 | 不等于 IQ 容量不足 |
| `Zbe` 高 + `ROB full` 低 + `preg_alloc_block_avg` 低 | 后端差但不是窗口容量卡住 | 不应优先扩大 ROB/PREG | 后续优化后容量可能变成新瓶颈 |
| `LSU spec/KI` 高 + `LD cross/KI` 高 + L1D miss 低 | 访存问题不来自 cache 容量 miss | LSU 内部地址/依赖/replay 更可疑 | 还要拆 spec fail 具体原因 |
| `rf_pipe*_src_no_rdy` 高 + `lsiq_not_ready` 高 + `ld_replay_pressure` 高 | RF 源未就绪可能由 LSU producer/replay 传导 | LSU/RF/wakeup 存在耦合 | 现在可继续看 `rf_pipe*_src*_no_rdy`、`sq_*fwd*`、`producer_load_fwd_wakeup`，但非 load producer 精确归因仍有限 |
| `BHT mis/KI` 高 + `Flush/KI` 高 + `Zbad` 高 | 错误推测会频繁清空窗口 | branch/flush 是主方向 | 要区分 direction、target、indirect、RAS |
| `FE%` 高 + `icache_refill_busy` 低 + `ifu_ibuf_full` 高 | 前端 stall 不一定是 I-cache miss | 可能是后端反压或 redirect | 不能直接改 I-cache |
| `FE%` 高 + `Flush/KI` 高 + `Zbad` 高 | 前端气泡可能由分支重定向造成 | 先看 predictor/flush recovery | 不要把它归为纯 fetch 带宽不足 |

以 Dhrystone 为例，`FE%=8.59%`、`bht_bju_mispred=0.10/KI` 排除了前端和分支作为主因；`dcache_read_miss` 很低，排除了 L1D miss 主导；但 `lsu_spec_fail_deep=100.88/KI`、`ld_ag_cross_req=48.35/KI`、`rf_pipe5_src_no_rdy=43.49/KI` 同时高，所以证据链指向 LSU replay、地址路径和 RF source-ready。以 `bench_ilp` 为例，`FE%=1.45%`、`zero_memory_raw=0`，但 `zero_backend_raw=73.70%`、`iq_select_width_avg=0.78`，说明它是更纯粹的后端调度/select 压力。以 `spec_mcf` 为例，`bht_bju_mispred=88.36/KI`、`global_flush_zero_retire=79.00/KI`、`zero_bad_spec_raw=21.93%` 同时高，所以分支/flush 是不可忽略的主瓶颈。

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

### 4.6 当前性能损失的主线归因

从全量结果看，当前性能损失不是单个模块坏掉，而是多个机制沿着流水线形成连锁：

```text
前端供给/分支预测/后端 ready
  -> issue queue 中有效指令不能稳定变成可发射指令
    -> RF launch、LSU replay、branch flush 反复打断执行流
      -> ROB head 可提交指令不足
        -> retire_width 低、zero-retire 周期高、IPC 低
```

把所有 case 放在一起看，当前 C910 RTL 仿真的低性能首先表现为退休端吞吐不稳定，而不是某一个前端、cache 或分支指标单独异常。`retire_width_avg` 普遍低于乱序超标量处理器应有水平，`retire_width0_cycle` 在多个 case 中很高，说明处理器经常处在“这一拍没有任何可提交指令”的状态。退休端是流水线的最终出口，它不直接告诉我们瓶颈在哪里，但它给出了最重要的事实：前面某些阶段没有持续地产生已完成、顺序正确、可提交的指令。后续所有分析都应该围绕这个事实展开，而不是只盯着某个单项计数。

继续向前追，`zero_backend_raw` 在大量 case 中占比很高，说明 zero-retire 周期更常与后端 core 状态相关。这里的“后端”不能简单理解成 ROB 满，也不能简单理解成执行单元不够。当前 ROB/PREG 相关指标并不高，说明指令并不是主要卡在 rename 无法分配资源，也不是窗口容量已经被填满而完全不能继续接收指令。更合理的解释是：指令已经进入乱序窗口，但其中相当一部分不能变成 ready，或者 ready 之后不能稳定被 select，或者发射后在 RF/LSU 阶段被打回。这个判断和 `iq_not_ready_width_avg` 高、`iq_select_width_avg` 偏低、部分 case 中 `rf_pipe*_src_no_rdy` 高是相互吻合的。

因此，当前最重要的体系结构问题不是“窗口够不够大”，而是“窗口里的指令是否能被有效唤醒、选择和执行”。乱序处理器扩大窗口的前提是窗口中能找到足够多的独立 ready 指令。如果 wakeup/forward 保守、producer ready 信号来得晚、select 仲裁低效、RF launch 条件和 IS ready 条件不一致，那么扩大窗口只能堆积更多等待项，未必能增加发射宽度。当前 `bench_ilp` 是这个判断的关键反证：它几乎没有前端和 memory 压力，却仍然表现为极高后端 raw stall 和很低 select 宽度。这说明即便给后端相对干净的输入，调度和发射链路仍然没有稳定输出高吞吐。

访存路径是第二条非常明确的瓶颈线，但它不是传统意义上的“cache miss 主导”。Dhrystone 和 bench_mem 暴露的主要是 LSU 内部的地址、store-load 相关性、forward、spec fail 和 replay。Dhrystone 的 L1D miss 不高，分支误预测也很低，但 `lsu_spec_fail_deep`、`ld_ag_cross_req`、`rf_pipe5_src_no_rdy` 同时突出，这说明访存问题已经传导到 RF 和 IQ ready。换句话说，load/store 不只是自己慢，它还让依赖它们的后续指令无法 ready，进而降低整体 select 和 retire。这个传导关系比单独一个 LSU 事件更重要，因为它解释了为什么一个看似小整数 benchmark 会变成后端 ready/replay 问题。

分支和前端是第三条主线，主要影响 SPEC irregular kernel。`spec_mcf`、`spec_mcf_sort`、`spec_deepsjeng`、`spec_povray` 的 `bht_bju_mispred` 和 `global_flush_zero_retire` 都高，说明这些 case 中错误路径被频繁引入窗口，又被 flush 清掉。分支错误的成本不是只损失重定向的几拍，它还会浪费前端取指带宽、污染后端窗口、取消 IQ/LSU 中已经做的工作，并造成窗口重新填充的空档。前端高 stall 的部分 case 也不能直接归因于 I-cache，因为 flush 和后端反压都可能让前端看起来停顿。因此前端优化必须先拆来源：是真取指供给不足，还是分支重定向频繁，还是后端消费不动导致 IBUF/PCFIFO 反压。

综合起来，当前最可信的瓶颈排序是：先研究后端 ready/wakeup/select 和 RF launch，再研究 LSU replay/spec fail 与 store-load 相关性，然后研究分支预测/flush 对 SPEC kernel 的影响，最后再根据前端归因决定是否改 I-cache、BTB、IBUF 或 redirect。这个排序不是说前端和分支不重要，而是说在当前数据下，直接扩大 cache、扩大 ROB 或盲目调 predictor，都没有先拆后端 producer 和 LSU replay 来得稳。

## 5. 主瓶颈一：IQ ready/wakeup/select 效率

### 5.1 微结构背景：IDU 如何把窗口转化为执行流

在 `doc/idu/00_idu_overview.md` 中，IDU 的核心使命被分成译码、重命名、发射和 RF 读寄存器。对性能最关键的是后两步：IS 阶段把指令放入不同发射队列，等待源操作数 ready；RF 阶段读取物理寄存器或使用前递结果，最后把指令送入执行单元。也就是说，乱序核真正释放 ILP 的地方，不是 ROB 里“存了多少指令”，而是发射队列能不能持续找到 ready 指令，并且 RF 阶段能不能确认这些指令真的可以执行。

```text
IR dispatch
  -> AIQ / BIQ / LSIQ / SDIQ / VIQ entry valid
    -> dep entry 跟踪 src0/src1/srcvm 是否 ready
      -> producer 广播目的物理寄存器或向量寄存器
        -> entry 被 wakeup
          -> select 仲裁选择某个 ready entry
            -> RF 读 PRF 或选择 forward
              -> launch 成功进入 IU/LSU/VFPU
```

这里有一个容易忽略的细节：IS 阶段的 ready 判断和 RF 阶段的真实 launch 条件不是同一件事。IS 阶段可能基于预测前递或即将到来的 producer 结果认为消费者可以发射；RF 阶段才真正检查源操作数、前递路径、读端口、执行单元选择和特殊结构条件。如果 RF 阶段发现条件不满足，指令会发生 launch fail，被打回或冻结，等待重新调度。`doc/idu/18_rf_ctrl.md` 里 RF launch fail 的描述正对应这条路径。

因此，`iq_not_ready_width_avg` 高说明“队列里有很多指令还没满足发射条件”，`iq_select_width_avg` 低说明“每周期真正被选出来的指令少”，`rf_pipe*_src_no_rdy` 高说明“即使进入 RF，源操作数仍可能没有准备好”。这三个指标不是彼此孤立的事件，而是同一条后端调度链路的三个观察点：队列等待、选择不足、RF 打回。

### 5.2 证据

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

从数值上看，`iq_not_ready_width_avg=11.06` 不是“发生了 11 次事件”，而是平均每个采样周期有约 11 个 IQ entry 处于 valid 但 not-ready 状态。它表示窗口中存在大量等待项。`iq_select_width_avg=1.64` 则表示平均每周期真正被选中发射的项只有约 1.64 个。两者放在一起看，含义是：窗口不是空的，但其中很多指令不能转化为执行流。

这类瓶颈会直接压低乱序核的有效宽度。乱序超标量核的性能依赖三个动作连续发生：dispatch 把指令放入队列，wakeup 把等待 producer 的消费者标成 ready，select 从 ready 集合里挑指令发射。如果第一个动作正常，但第二、第三个动作效率低，就会看到 IQ 中有很多 valid-not-ready 项，同时 select 宽度不高，最后 retire 宽度也低。

当前报告把它列为 P0，是因为它覆盖面最大：

1. `bench_ilp` 几乎排除了前端和 memory，却仍然 `zero_backend_raw=73.70%`、`iq_select=0.78`，说明后端调度链路本身有问题。
2. `CoreMark` 的 `iq_not_ready=11.06`、`iq_select=1.64`，说明常用整数 workload 也受影响。
3. Dhrystone 的 `iq_not_ready=12.13`、`rf_pipe5_src_no_rdy=43.49/KI`，说明 ready/select 问题和 LSU/RF 路径耦合。
4. 多个 SPEC kernel 的 `iq_not_ready` 高，说明这不是单个 benchmark 的偶然形态。

这个瓶颈最可能来自三类细节。第一类是 producer 晚，典型是 load producer、乘除法 producer、FP producer 或某些长延迟执行结果返回晚，导致消费者长期停留在 not-ready 状态。第二类是 wakeup/forward 保守，硬件为了避免错误发射，可能等到结果已经非常确定才唤醒消费者，这会错过本可以提前发射的机会。第三类是 select/port/FU 仲裁限制，即使某些指令已经 ready，也因为端口、执行单元、队列分组或年龄策略没有被选中。当前指标还不能把这三类完全拆开，所以报告强调下一步必须加 producer 分类和 select block reason。

从优化角度看，这条线不能靠一个大改动解决。应该先确认 not-ready 的主要来源，再决定是否改 load wakeup、ALU forward、select policy、RF launch 条件或执行端口仲裁。如果 producer 分类显示 load 占主导，那么应该和 LSU replay 路线合并研究；如果 ALU/mult/div 占主导，则更可能是整数执行链路或 forward 时机问题；如果 ready 项已经不少但 select 宽度仍然低，则要看 select 仲裁和端口映射。这个拆分很重要，因为“提高 issue 宽度”“扩大 IQ”“增加执行单元”在没有 root-cause 的情况下都可能不产生收益。

### 5.3 典型时序场景：为什么窗口里有指令却发不出去

可以用一个 load-use 链条理解当前瓶颈。假设一条 load 指令进入 LSIQ，后面一条 ALU 指令依赖它的结果。为了提高性能，硬件可能在 load 的 AG 或 DC 阶段就推测性唤醒消费者，让消费者尽快进入发射候选。如果 load hit 且数据及时返回，消费者就能顺利经过 RF 并执行；如果 load 后来发现 store-load 冲突、cache 路径延迟、forward 条件不满足或 spec fail，消费者在 RF 阶段就可能发现源不 ready，形成 `rf_pipe*_src_no_rdy` 或 launch fail。

```text
load 发射到 LSU
  -> producer 结果被预测为即将 ready
    -> consumer 在 IQ 中被 wakeup
      -> select 选择 consumer
        -> RF 检查源操作数
          -> producer 实际未 ready 或 replay
            -> source-not-ready / launch fail
              -> consumer 回到等待状态
```

如果这种场景偶尔发生，性能影响有限；如果频繁发生，IQ 中会出现大量 valid-not-ready entry，select 宽度会下降，RF launch 会反复打回，最终 retire 端出现空拍。当前 Dhrystone、CoreMark、bench_ilp 和多个 SPEC kernel 同时表现出 `iq_not_ready` 高、`iq_select` 低或 RF source-not-ready 高，说明这种后端调度效率问题不是局部噪声，而是当前最需要拆解的主线。

### 5.4 机制边界

这一线要避免两个误判。第一，`IQ not-ready` 高不等于 IQ 容量不够；容量瓶颈应表现为 IQ full、rename/dispatch 被阻塞，而当前更像队列里已有很多等待 producer 的指令。第二，`iq_select` 低也不一定只由 select 仲裁造成，它可能是 ready 指令少，也可能是 ready 后被端口、FU、RF launch 或 flush/replay 接住。因此下一步必须把 not-ready producer、ready-but-not-selected 原因和 RF launch fail 原因拆开。

`bench_ilp` 是这条线的关键反证 case。它 FE% 只有 1.45%，`zero_memory_raw=0`，但 `zero_backend_raw=73.70%`、`iq_select_width_avg=0.78`，所以瓶颈不能推给取指或 cache miss。若 wakeup/select/RF 改动有效，`bench_ilp` 应最敏感；若 CoreMark/Dhrystone 提升但 `bench_ilp` 不动，说明改动更可能击中了 LSU 或代码形态，而不是通用后端调度能力。

### 5.5 已补齐的细粒度观测和仍然存在的边界

当前指标已经从“能证明 ready/select 有问题”推进到“能把问题拆到 RF operand、RF launch fail 子原因、LSU replay/forward/cancel/wait-old 和 producer 活动”。`*_src*_not_ready_avg` 回答 IQ 里未 ready 的 entry 在等哪个源操作数；`*_load_dep_not_ready_avg`/`*_nonload_dep_not_ready_avg` 回答这些等待是否带有 dep-entry 的 `lsu_match`；`*_issue_select_avg` 和 `*_ready_not_issued_avg` 回答 ready 后是否被队列内 age-select 压住。新增的 `rf_pipe*_src*_no_rdy` 则把 RF 阶段的打回继续拆到具体 pipe 和具体 operand，比如 Dhrystone 里如果 `rf_pipe5_src_no_rdy` 高，现在可以继续判断是 `src0`、`srcv0` 还是 `staddr`。

LSU 侧新增的 `lsu_replay_data_discard`、`lsu_replay_discard_sq`、`sq_has_fwd_req`、`sq_fwd_req`、`sq_fwd_bypass_req`、`sq_fwd_multi`、`sq_cancel_acc_req`、`sq_cancel_ahead_wb` 可以把“LSU replay/forward 有问题”进一步拆成：是否真的发生 SQ forward、是否 forward 多匹配、是否提前访问被取消、是否 replay 与 SQ discard 相关。`lsu_ld_ag_wait_old`、`lsu_st_ag_wait_old`、`lsu_wait_old`、`lsu_lq/sq/rb_full_from_idu` 则用于判断问题是否来自 memory ordering 或 LSU 队列资源，而不是单纯 load-use timing。

仍然要保留一个准确性边界：现有 dep-entry 只保存 `lsu_match`，没有保存“这个未 ready 源正在等待 ALU、MUL、DIV、VFPU、CSR 中的哪一种 producer”。因此 `producer_alu0_wakeup`、`producer_mult_wakeup`、`producer_load_fwd_wakeup` 等新增项只能表示 producer 活动/唤醒机会，不能直接当作消费者等待对象的精确分类。若未来要做严格 producer attribution，需要在 IQ/dep entry 里额外保存 producer class，或建立逐 entry trace，记录 create、producer tag、ready、select、RF fail、replay 的时间线。

### 5.6 改进方案

| 优先级 | 方案 | 验证指标 | 风险 |
|---|---|---|---|
| P0 | 拆分 IQ not-ready producer 类型 | `iq_not_ready_by_src_type` | 先观测，不改功能，风险低 |
| P0 | 针对 load producer 检查 wakeup/forward 提前量 | `rf_pipe*_src_no_rdy`、`ld_replay_pressure` | 过早 wakeup 可能增加 replay |
| P1 | 调整 select 优先级，优先解除长等待链 | `iq_select_width_avg`、`retire_width_avg` | 可能牺牲公平性或其他 workload |
| P1 | 检查 RF launch ready 判定和 IS ready 判定是否不一致 | `rf_pipe*_lch_fail` | 需要保证不破坏正确性 |
| P2 | 对长延迟 FU 增加更准确的完成/wakeup 信号 | `*_wait_to_ready` | 需要理解执行单元接口 |

## 6. 主瓶颈二：LSU replay、spec fail 与地址相关路径

### 6.1 微结构背景：LSIQ/SDIQ 与 LSU replay 的根本矛盾

`doc/idu/15_is_lsiq.md` 对访存发射队列的描述可以直接解释当前数据。访存指令和 ALU 指令不同：ALU 指令的操作数 ready 后，执行延迟相对固定；load/store 则要经过地址生成、D-cache、store queue 比较、store-to-load forwarding、MMU/cache 状态、异常和内存顺序检查。为了不让后续指令白等，C910 会让 load 在较早阶段向 IDU 广播目的寄存器，推测性唤醒依赖者；但如果后面发现 load 不能按预测完成，就必须 replay 或触发 spec fail。

```text
LSIQ issue load
  -> LSU AG 地址生成
    -> 可能推测唤醒依赖该 load 的消费者
      -> LSU DC 访问 D-cache / 检查 store forwarding
        -> 命中且顺序正确：WB 写回，消费者继续执行
        -> miss / forwarding 失败 / store-load 冲突 / spec fail：replay 或 flush
```

这就是 LSU 性能的根本矛盾：唤醒越早，消费者越可能提前执行，性能潜力越高；但唤醒越早，一旦 load 后续路径失败，就会制造更多 replay 和 RF source-not-ready。唤醒越保守，spec fail 可能减少，但消费者等待更久，IQ not-ready 会升高。当前 Dhrystone 和 bench_mem 的数据说明，C910 在这条线上存在明显压力：不是简单 cache miss，而是地址路径、store-load 相关性、forward 和 replay 之间的平衡没有被当前 workload 顺利通过。

LSU 还有另一个复杂点：store 被拆成 store address 和 store data 两条相关路径。LSIQ 负责 load 和 store address，SDIQ 负责 store data。store-load forwarding 要求 older store 的地址和数据都足够明确；如果地址未知、数据未到、或者比较/forward 条件不满足，load 的推测执行就可能被否定。`ld_sq_data_discard_deep` 高，正是这类 store queue / forwarding 相关路径需要重点追踪的信号。

### 6.2 证据

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

这些 LSU 指标要分层理解：

| 指标层次 | 代表含义 | 解释方式 |
|---|---|---|
| `ld_ag_cross_req` / `st_ag_cross_req` | AG 地址生成阶段已经发现访问落入 cross/boundary 或特殊路径 | 它不是 cache miss，而是地址形态触发了更复杂的 LSU 处理 |
| `ld_sq_data_discard_deep` | load 和 store queue / forwarding 相关路径发生 discard | 常见原因是 store 数据未到、地址冲突、forward 条件不满足或推测失败 |
| `lsu_spec_fail_deep` | LSU 深层推测失败或相关 replay/flush 事件 | 表示 load/store 推测执行结果被否定，需要回滚、重放或清空相关流水 |
| `ld_replay_pressure` | replay 造成的平均压力 | 用来判断 replay 只是偶发事件，还是每次都会造成较长等待 |

为什么说它不是 L1D miss 主导？因为 cache miss 主导时，通常应同时看到 D-cache miss、LFB/RB/BIU 读请求、memory raw、读返回 latency 等指标显著升高。而当前 Dhrystone 的突出事件集中在 `lsu_spec_fail_deep`、`ld_ag_cross_req`、`rf_pipe5_src_no_rdy`，不是 D-cache miss。也就是说，数据可能在 L1 里，但 LSU 因为地址、顺序、forward 或 replay 机制，仍然不能顺利把 load/store 转化成完成结果。

LSU 瓶颈对乱序核特别危险，因为它会向上游传导。一个 load replay 不是只损失 load 自己的周期，它还会让依赖它的整数指令、store 地址、分支条件都保持 not-ready；这些消费者滞留在 IQ/RF，又会降低 select 宽度和 retire 宽度。因此 Dhrystone 中 `lsu_spec_fail_deep` 与 `rf_pipe5_src_no_rdy` 同时高，是比单独一个 LSU 事件更强的证据。

后续验证必须把“次数”和“代价”分开。`lsu_spec_fail_deep` 高说明事件频繁，但还要看每次 replay 造成多长等待、影响多少消费者、是否导致全局 flush、是否集中在少数 PC。若事件集中在少数 PC 和地址低位，可能是代码布局或数据对齐触发；若分布广泛，则更可能是 LSU 策略本身偏保守。若 `lsu_spec_fail` 降了但 `iq_not_ready` 没降，说明 LSU replay 不是 ready/select 的主要来源；若两者同时下降且 IPC 上升，才能证明 LSU 优化击中了真实瓶颈。

### 6.3 Dhrystone 的 LSU/RF 特征

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

### 6.4 CoreMark 的 LSU 位置

CoreMark 的 LSU 指标不如 Dhrystone 极端：

| 指标 | 数值 |
|---|---:|
| `lsu_spec_fail_deep` | 0.924/KI |
| `ld_ag_cross_req` | 0.003/KI |
| `ld_sq_data_discard_deep` | 0.072/KI |
| `lsiq_not_ready_avg` | 4.060 |
| `ld_replay_pressure` | 0.208 cycles |

CoreMark 的主要问题不是 LSU replay 单点爆炸，而是综合型：前端、IQ not-ready、LSIQ 等待、分支 flush 共同降低退休宽度。

CoreMark 这里的判断要更谨慎。`lsu_spec_fail_deep` 和 `ld_ag_cross_req` 不高，说明它不是 Dhrystone 式 LSU replay 爆炸；但 `lsiq_not_ready_avg=4.060` 仍说明 load-side queue 有等待。也就是说，CoreMark 的 LSU 更像“综合后端等待的一部分”，而不是第一根因。优化 LSU replay 可能会帮助 CoreMark，但不能指望它单独解决 CoreMark 的 FE/BE 混合瓶颈。对 CoreMark 来说，必须同时拆 IQ producer 和前端反压来源。

### 6.5 改进方案

| 优先级 | 方案 | 验证指标 | 预期 |
|---|---|---|---|
| P0 | 拆 `lsu_spec_fail_deep` 原因 | `spec_fail_by_store_load_dep/cross/cache/mmu` | 找出 Dhrystone 100.88/KI 的真实来源 |
| P0 | 记录 `ld_ag_cross_req` 触发 PC 和地址低位 | top PC、地址对齐分布 | 判断是否由数据布局触发 |
| P0 | 做 Dhrystone 数据/栈/全局变量对齐实验 | `ld_ag_cross_req`、`lsu_spec_fail_deep` | 若显著下降，说明 layout 触发 LSU 特殊路径 |
| P1 | 拆 store-load forwarding attempt/success/fail | `ld_sq_data_discard_deep` | 解释 bench_mem 的 66.75/KI |
| P1 | 拆 load replay producer-consumer 链 | `ld_replay_pressure`、`rf_pipe*_src_no_rdy` | 验证 replay 是否导致消费者反复打回 |
| P2 | 优化 store-load speculation 或 replay 策略 | IPC、flush、spec fail | 减少 replay，但必须保证内存一致性 |

## 7. 主瓶颈三：分支误预测与 flush

### 7.1 微结构背景：预测方向、预测目标和 flush 代价不是一回事

`doc/ifu/04_bht.md` 里把 BHT 的职责说得很清楚：BHT 判断条件分支“跳不跳”，BTB/L0 BTB/indirect BTB/RAS 负责“跳到哪里”。性能报告里看到 `bht_bju_mispred` 高，只能说明条件分支方向或 BJU 确认路径出现大量不一致；看到 `global_flush_zero_retire` 高，则说明这些错误已经造成退休空档。二者相关，但不是同一个问题。

```text
IFU 预测 PC
  -> BHT 预测方向 taken / not-taken
  -> BTB / L0 BTB / RAS / indirect predictor 给目标
  -> 预测路径指令进入 IDU/ROB/IQ/LSU
  -> BJU 或 RTU 确认真实方向/目标
    -> 预测正确：窗口继续推进
    -> 预测错误：RTU flush，恢复正确 PC 和重命名状态
```

分支错误的成本不只发生在 IFU。错误路径上的指令可能已经译码、重命名、进入 IQ，甚至发射到 LSU 或执行单元。flush 发生时，这些工作全部作废；随后 IFU 重新取正确路径，IDU 重新填窗口，RTU 重新等到正确路径指令完成。因此，分支瓶颈常常会同时抬高 `zero_bad_spec_raw`、`zero_frontend_raw` 和 `zero_backend_raw`。如果只看 FE 或 BE，很容易低估分支的真实影响。

对当前报告来说，mcf、mcf_sort、deepsjeng、povray 这类 case 的关键不是“是否有分支”，而是“错误频率是否高到足以反复清空窗口”。`bht_bju_mispred` 给出错误频率，`global_flush_zero_retire` 给出这些错误在退休端造成的可见损失。后续要进一步把错误拆成 direction、target、indirect、RAS 和 update/alias，才能决定具体改 BHT 还是 BTB/RAS。

### 7.2 证据

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

这里要区分两个概念：误预测次数和误预测代价。`bht_bju_mispred` 更接近“错了多少次”，`global_flush_zero_retire` 和 `zero_bad_spec_raw` 更接近“这些错误造成了多少无法退休的周期”。如果 mispred 高但 flush 代价低，可能只是轻微错误；如果 mispred 和 flush 都高，就说明错误路径已经严重影响窗口有效工作。`spec_mcf_kernel` 同时有 `bht_bju_mispred=88.36/KI`、`global_flush_zero_retire=79.00/KI`、`zero_bad_spec_raw=21.93%`，所以它不是“偶尔预测错”，而是错误推测持续清空和污染窗口。

分支瓶颈还会间接表现为前端和后端都差。一次 flush 会丢掉前端已经取到的错误路径指令，也会清掉后端窗口里的错误路径工作；恢复后前端要重新取正确路径，后端要重新填窗口。在统计上，这可能同时抬高 FE、Zbad、Zbe，不能只因为 BE 高就忽略分支。

对 mcf、deepsjeng、povray 这类 irregular workload，分支瓶颈通常不是均匀分布在所有分支上，而是少数热点分支贡献大部分错误。如果能找到 top PC，优化可以非常具体：例如某几个循环退出分支方向历史不够，就研究 BHT/history；某些间接跳转目标分散，就研究 indirect BTB；某些函数返回错，就检查 RAS push/pop 和 flush 恢复。没有 PC 维度时，直接换 predictor 结构风险很高，因为你不知道当前错误来自容量、alias、目标、返回还是更新策略。

分支优化还要用两个目标指标闭环。第一是错误次数下降，例如 `bht_bju_mispred`、BTB miss、indirect miss、RAS mistaken 下降；第二是错误代价下降，例如 `flush_to_fetch`、`flush_to_id`、`global_flush_zero_retire` 下降。有时 predictor 难以大幅降低错误次数，但可以缩短恢复路径，减少每次错误的空拍。当前数据更支持先降低错误次数，因为 mcf 类 case 的 mispred/KI 本身很高；等错误次数下降后，再看 flush recovery 是否成为主导。

### 7.3 改进方案

| 优先级 | 方案 | 验证指标 | 说明 |
|---|---|---|---|
| P0 | 记录 mispred PC top-N | 每个 PC 的 mispred 次数、类型 | 找 mcf/povray/deepsjeng 的热点分支 |
| P0 | 区分 direction/target/indirect/RAS miss | `bht_bju_mispred`、`l0_btb_mispred`、`ind_btb_miss`、`ras_mistaken` | 决定优化 BHT、BTB、间接预测还是 RAS |
| P1 | 观察 BHT update buffer alias/覆盖 | `bht_wr_buf_hit`、`bht_wrbuf_create_slot_full` | 判断小表或更新时机是否限制 |
| P1 | 加 target predictor hit/correct 分母 | BTB hit/miss/correct rate | 避免只有 miss 事件没有准确率 |
| P2 | 改 predictor 结构或参数 | `global_flush_zero_retire`、IPC | 必须用 mcf/povray/deepsjeng 验证 |

## 8. 主瓶颈四：前端供给

### 8.1 微结构背景：前端 stall 可能来自取不到，也可能来自送不下去

IFU 文档把前端拆成 PC 生成、预测、I-cache/refill、predecode、IBUF/LBUF 等多级结构。性能分析里常见的误区是把 `FE%` 直接理解成“I-cache 不够好”。实际上，前端 stall 只是说前端到后端的供给链路没有持续推进，它既可能来自 IFU 自身，也可能来自 IDU/后端不接收。

```text
PCGen / BHT / BTB / RAS
  -> I-cache / refill
    -> predecode / align / pack
      -> IBUF / LBUF
        -> IDU ID stage
```

如果 I-cache miss 或 BTB 目标错误，前端确实会供给不足；如果分支频繁 flush，前端会反复丢弃错误路径并重新取指；如果后端的 ID/IR/IS/RF 因 IQ、LSU 或 ROB 条件无法推进，IBUF 可能被顶满，此时前端也会表现为 stall。三种情况的 FE% 都可能高，但 RTL 改法完全不同。

因此，前端分析必须同时看 “empty” 和 “full”。IBUF empty 更像前端没有指令可交付；IBUF full 更像后端不消费；I-cache refill busy 更像取指 miss；flush_to_fetch 高更像重定向恢复慢。当前 CoreMark 和若干 SPEC case 的 FE 高，但并没有形成“纯 I-cache miss 主导”的证据，所以报告把前端列为参与瓶颈，而不是第一根因。

### 8.2 证据

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

当前报告对前端的态度是“参与瓶颈，但先不把它当单一主因”。原因是 FE% 高的 case 往往同时有其他强证据。例如 `spec_cactubssn` 的 FE% 高达 53.73%，但它的 `iq_not_ready=16.20`、`zero_backend_raw=48.22%` 也很高，说明前端和后端互相影响；`coremark` 的 FE%=29.91%，但 `icache_refill_busy` 不足以解释全部前端 stall，且 `ifu_ibuf_full` 表示前端缓冲可能被后端不消费顶住。真正要优化前端，必须先判断是 I-cache/BTB 供给不足，还是 flush/后端反压造成前端看起来停顿。

因此前端路线要先做相关性分析，而不是先改结构。应统计前端 stall 周期中 IBUF 是 empty 还是 full，是否同周期存在 global flush，是否同周期 ID/IR 因后端阻塞无法推进，是否存在 I-cache refill 或 BTB miss。只有把前端 stall 切成这些来源，才能决定改 fetch bandwidth、I-cache refill、BTB/L0 BTB、redirect bypass，还是先解决后端 ready/select。当前报告把前端列为 P3，就是因为它重要但归因尚未拆开，贸然改前端结构容易优化错方向。

### 8.3 改进方案

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

FP/VIQ 与整数 IQ 共享“ready/select”这个抽象问题，但 producer、执行延迟和写回路径不同。`viq0_not_ready_avg` 高表示向量/浮点队列中有 valid 但不能发射的项；原因可能是 FP producer 未写回、VFPU 长延迟单元忙、vreg 读写冲突、load-to-FP 数据未到，或者 FP writeback/forward 端口冲突。`bench_fp`、`povray`、`lbm`、`cactubssn` 中这些指标明显，说明 FP/VIQ 需要单独建模，不能用 Dhrystone/CoreMark 的整数结论覆盖。

这条线当前不是第一优先级，但如果目标是全面提升 C910，而不是只提升整数小 benchmark，就必须补 VIQ producer 分类、VIQ wait-to-ready、VFPU issue/wb、vreg conflict、长延迟 FU busy 等指标。优化成功也应使用 FP-heavy case 验证，不能用 Dhrystone 证明 FP 路径变好。

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

CoreMark 的证据链可以这样读：

```text
IPC=1.544、retire_width_avg=1.194、zero-retire=36.12%
  -> 最终提交吞吐不足
FE=29.91%、BE=34.21%
  -> 前端和后端都参与，不是单一方向
zero_backend_raw=34.95%、iq_not_ready=11.06、iq_select=1.64
  -> 后端 ready/select 效率不足是重要部分
zero_memory_raw=0.62%、lsu_spec_fail=0.92/KI、ld_ag_cross=0.00/KI
  -> LSU replay 不是 CoreMark 的第一主因
global_flush=7.57/KI、BHT mis=7.28/KI
  -> 分支有影响，但不是 mcf 那种极端 flush 主导
```

所以 CoreMark 更像“综合压力测试”：它不会像 Dhrystone 那样把 LSU spec fail 放大到极端，也不会像 mcf 那样把分支误预测放大到极端，但它会同时暴露前端供给、后端 ready/select、LSIQ waiting 和一定 flush。优化 CoreMark 的正确方法不是寻找一个万能开关，而是把 FE 和 BE 分开拆：如果 `IQ not-ready by producer` 发现主要等待 load producer，就走 LSU/wakeup 路线；如果发现主要等待 ALU/mult/div producer，就走整数执行和 forward 路线；如果 `ifu_ibuf_full` 与后端 stall 强相关，就先改后端消费，而不是先改 I-cache。

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

Dhrystone 的证据链更集中：

```text
FE=8.59%、BHT mis=0.10/KI
  -> 前端和分支都不是主方向
dcache miss 低，但 LSU spec=100.88/KI、LD cross=48.35/KI、ST cross=28.98/KI
  -> 问题不是 L1D 容量 miss，而是 LSU 内部特殊路径/replay/spec fail
rf_pipe5_src_no_rdy=43.49/KI、lsiq_not_ready=4.916、sdiq_not_ready=2.780
  -> LSU/RF/队列 ready 之间有传导关系
ld_replay_pressure=19.746 cycles
  -> replay 不只是次数多，每次还会造成明显等待压力
```

这里最需要警惕的是：Dhrystone 是小程序，常被当成整数/控制流指标，但当前结果并不是“分支预测差”或“整数 ALU 慢”。它实际暴露的是 load/store 相关和 RF ready。对这个 case，最有价值的下一步不是改 predictor，也不是扩大 ROB，而是抓 `lsu_spec_fail_deep` 的 reason、`rf_pipe5_src_no_rdy` 的 producer，以及触发 `ld_ag_cross_req` 的 PC 和地址低位。如果对齐数据或改变栈/全局变量布局后 `ld_ag_cross_req` 和 `lsu_spec_fail_deep` 明显下降，就说明当前分数对地址布局敏感；如果布局变化不影响这些指标，就更可能是 LSU speculation/forward/replay 机制本身偏保守或时序不准。

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

`bench_ilp` 是判断“通用后端调度能力”的关键 case。它的价值在于排除了很多干扰项：FE% 很低，说明不是取指供给主导；`zero_memory_raw=0`，说明不是访存主导；branch/flush 也不极端。剩下仍然 `zero_backend_raw=73.70%`、`retire_width_avg=0.332`、`iq_select_width_avg=0.78`，就把问题压到了整数后端的 ready/select/执行端口/依赖链。

因此它应该作为所有 wakeup/select/RF 优化的第一反证 case：

| 实验结果 | 解释 |
|---|---|
| CoreMark/Dhrystone 提升，`bench_ilp` 不提升 | 优化可能击中了 LSU、代码布局或特定 workload，不是通用后端改善 |
| `bench_ilp iq_select` 上升，`retire_width` 上升 | select/ready 改动可能真的提高了后端吞吐 |
| `bench_ilp iq_not_ready` 下降但 IPC 不变 | 下游执行端口、RF、retire 或依赖链可能成为新瓶颈 |
| `bench_ilp` 提升但 SPEC 不提升 | 单机制有效，但真实混合 workload 被 branch/LSU/frontend 接住 |

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

`bench_mem` 的核心不是“cache miss benchmark”，而是 LSU 机制 benchmark。它的 `zero_memory_raw=6.06%` 不算极端，但 `ld_ag_cross_req=83.60/KI`、`ld_sq_data_discard_deep=66.75/KI`、`lsu_spec_fail_deep=25.92/KI` 同时高，说明 load/store 的地址路径、SQ forwarding/discard、spec fail/replay 都在发生。它非常适合用来验证 LSU 优化是否真的有效。

对 `bench_mem` 应重点做三类对照：

| 对照实验 | 看什么指标 | 能回答什么 |
|---|---|---|
| 改 load/store 间距 | `ld_sq_data_discard_deep`、`lsu_spec_fail_deep` | 是否由 store-load 距离过短或数据晚到触发 |
| 改地址对齐和 stride | `ld_ag_cross_req`、`st_ag_cross_req` | 是否由跨边界或地址模式触发 |
| 改独立 load/store 比例 | `lsiq_not_ready_avg`、`sdiq_not_ready_avg`、`ld_replay_pressure` | LSU 队列等待来自 load 侧还是 store 侧 |

如果 LSU 改动正确，`bench_mem` 中最应先下降的是 `ld_sq_data_discard_deep`、`lsu_spec_fail_deep` 或 `ld_replay_pressure`；如果这些不降但 IPC 上升，要小心是不是统计噪声、代码布局变化或其他路径偶然改善。

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

这里的“准确”指的是方向准确，而不是已经找到了某一行 RTL 的最终问题。当前数据已经足以排除一些低优先级方向：例如 ROB/PREG 不是第一瓶颈，L1 cache miss 不是 CoreMark/Dhrystone 的主线，BIU outstanding 不能单独作为外部带宽瓶颈证据。与此同时，数据也足以确认几个高优先级方向：后端 ready/select 覆盖面最大，Dhrystone 和 bench_mem 强烈指向 LSU/RF/replay，mcf/deepsjeng/povray 强烈指向 branch/flush。下一步研究的任务不是重新证明“性能低”，而是把这些方向拆成具体 producer、具体 PC、具体 replay reason 和具体 select block reason。

这也是为什么报告不建议直接做“大结构升级”。扩大 ROB、增加 IQ entry、加大 predictor、扩大 cache 都属于高成本改动，它们只有在瓶颈已经明确落在容量或结构规模上时才合理。当前更像机制效率问题：现有窗口没有被充分利用，现有 LSU speculation/replay 可能过于保守或时序不准，现有分支预测需要知道到底错在方向、目标还是返回。先加观测、再做反证实验，最后做小 RTL 改动，是更可靠的路线。

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

实际推进时，可以把每个瓶颈都写成一个可反证假设，而不是写成模糊判断。例如不要写“Dhrystone LSU 差”，而要写“Dhrystone 的 `lsu_spec_fail_deep` 主要来自 store-load 地址/数据未定导致的 replay，并且这些 replay 通过 pipe5 source-not-ready 传导到 RF launch”。这个假设有清楚的验证方式：拆 spec fail reason、记录触发 PC、观察 replay 前后的 RF no-ready、做 load/store 距离或数据对齐 microbench。如果这些证据不成立，就要放弃或修正假设，而不是继续沿着 LSU 方向盲改。

同样，对分支也不要写“mcf 分支差”，而要写“mcf 的低 IPC 主要由少数热点条件分支方向误预测造成，flush 频率而非单次恢复延迟是第一损失来源”。这个假设需要 mispred PC top-N、分支类型分类、flush_to_fetch/flush_to_retire 延迟来验证。若最终发现是 indirect target 或 BTB target 错，而不是 BHT direction 错，技术路线就应转向目标预测，而不是继续调 BHT。

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

这条技术路线的核心是把“后端发射不出来”拆成可修改的链路。第一步只做观测，不改功能：如果不知道 not-ready 的 producer 类型，任何 wakeup 改动都可能打错对象。第二步看 producer ready 到 consumer ready 的间隔，确认是否存在 wakeup 晚置位或 forward 信号保守。第三步看 ready 但未 select 的原因，判断 select 是否被端口、FU、年龄策略或队列分组限制。第四步看 RF launch fail，确认 IS 阶段的 ready 判断和 RF 阶段的真实可读/可前递条件是否一致。

如果这条路线成功，预期不是某一个指标孤立变化，而是一组指标同步改善：`iq_not_ready_width_avg` 下降，`iq_select_width_avg` 上升，`rf_pipe*_src_no_rdy` 或 `rf_pipe*_lch_fail` 下降，最终 `retire_width_avg` 和 IPC 上升。若只看到 `iq_not_ready` 下降但 `iq_select` 不升，说明 select/port 可能接住了瓶颈；若 `iq_select` 上升但 retire 不升，说明 ROB head、LSU replay 或 flush 成了下游瓶颈。每一步都要按这种方式判断瓶颈是否转移。

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

LSU 技术路线的难点在于性能和正确性强耦合。store-load speculation 越激进，越可能提前执行 load、提升并行性，但也越可能在 older store 地址或数据后来确定后发现冲突，从而 replay 或 flush。策略越保守，spec fail 可能下降，但 load 被延后，IQ not-ready 和后端等待可能上升。所以 LSU 优化不能只追求 `lsu_spec_fail_deep` 下降，还要看 IPC、`iq_not_ready`、`rf_src_no_rdy` 和 load replay pressure 是否同步改善。

可靠的 LSU 改进应先定位原因，再选择策略。如果主要原因是 SQ forwarding 数据晚到，就研究 forwarding 时机、SQ data valid、load issue 条件；如果主要原因是地址 cross/boundary，则研究 AG/DC/DA 对 split 或跨界访问的处理；如果主要原因是 memory disambiguation 过于乐观，就研究 store-set、load wait policy 或 replay throttle；如果主要原因是 wakeup 过早导致消费者反复打回，则研究 load result ready 和 consumer wakeup 的一致性。不同原因的 RTL 改动完全不同，不能统一称为“优化 LSU”。

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

分支预测路线应先做分类，再做结构实验。当前 `bht_bju_mispred` 和 `global_flush_zero_retire` 高，只能说明 branch/flush 是瓶颈，不能说明应该增大 BHT、改历史长度、改 BTB，还是修 RAS。mispred PC top-N 是这条路线的入口，因为它能告诉我们错误是否集中在少数分支上。如果错误高度集中，优先针对热点类型优化；如果错误分散，才考虑容量、alias 或更通用的 predictor 结构。

优化时还要分清“降低错误次数”和“降低错误代价”。降低错误次数靠 predictor 本身，降低错误代价靠 redirect 和恢复路径。前者影响 `bht_bju_mispred`、BTB miss、indirect miss、RAS mistaken，后者影响 `flush_to_fetch`、`flush_to_id`、`flush_to_retire` 和 `global_flush_zero_retire`。如果 mcf 的 mispred/KI 很高，先改 predictor 更直接；如果 mispred/KI 不高但每次 flush 后恢复很慢，才优先改 recovery。

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

前端路线的关键不是先提高取指带宽，而是先判断前端气泡来自哪里。前端和后端之间有缓冲，当前端看到 stall 时，可能是前端没有指令，也可能是后端阻塞导致前端缓冲满。若后端不消费，前端再强也只会更快把缓冲填满。反过来，如果后端 ready 但前端不能供给，那么后端队列会逐渐变空，retire 也会下降。两种情况在 FE% 上都可能高，但 RTL 改法完全不同。

因此建议把前端 stall 按同周期条件分类：flush 相关、I-cache refill 相关、BTB/redirect 相关、IBUF empty 相关、IBUF full/后端反压相关。只有当 IBUF empty 和 I-cache/BTB 事件强相关时，才优先改 I-cache、BTB 或 fetch；当 IBUF full 和后端 waiting 强相关时，应先改后端 ready/select 或 LSU replay；当前端 stall 和 flush 强相关时，应先改分支预测或恢复路径。

### 11.7 技术路线五：FP/VIQ 和长延迟执行

FP/VIQ 目前不是 Dhrystone/CoreMark 主线，但对 `bench_fp`、`povray`、`lbm`、`cactu` 重要。

| 阶段 | 工作 | 具体观测 | 可尝试改动 |
|---|---|---|---|
| 1 | 拆 VIQ not-ready producer | FP producer、load producer、vreg conflict、FU busy | 不改 RTL，只加分类 |
| 2 | 拆 VFPU issue/wb | issue valid、gateclk issue、wb port、fwd vreg | 优化 issue/wb 仲裁 |
| 3 | 拆长延迟 FU | VFDSU busy、div/sqrt wait、consumer wait | 调整 wakeup 或调度 |
| 4 | FP microbench | 独立 FP、依赖 FP、FP+load 混合 | 分离吞吐瓶颈和依赖瓶颈 |

FP 线的验证必须使用 FP-heavy case，不能用 Dhrystone/CoreMark 判断。

FP/VIQ 技术路线应当放在整数后端和 LSU/branch 初步清楚之后推进，但不能长期忽略。原因是 FP-heavy workload 的瓶颈形态不同：长延迟 FP producer 会形成更长的 wait-to-ready 链，vreg 读写和 VFPU writeback 可能有独立端口冲突，FP load-use 也可能经过不同的 forward 路径。若未来目标包含 SPEC FP kernel、图形/渲染、科学计算或向量扩展，这条线会变成主线。

这条线的正确推进方式和整数 IQ 类似：先拆 producer，再看 issue/wb，再看长延迟 FU。`viq_not_ready` 高本身只说明等待多，不说明等的是 FP producer、load producer、vreg conflict 还是 FU busy。只有 producer 分类清楚后，才知道应该优化 VFPU wakeup、vreg forward、writeback 仲裁，还是长延迟单元调度。

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
