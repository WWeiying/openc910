# C910 性能瓶颈与乱序超标量机制分析

本文档只基于 `smart_run/results` 中已经保存的结果进行分析，不引入新的仿真数据。

当前目标不是只给出一个分数结论，而是把这些 benchmark 数据转换成对乱序超标量处理器关键机制的理解：前端取指与分支预测、寄存器重命名与发射、乱序窗口、LSU、Cache、退休与 flush。最后给出可执行的优化路线。

## 1. 当前结论

### 1.1 总体判断

当前性能主瓶颈不是 L1 I/D cache miss，也不是单纯的分支预测预热问题，而是：

1. **后端可发射/可执行效率不足**：`Backend Stall` 在 CoreMark 和 Dhrystone 中都处于 30% 以上。
2. **寄存器读/发射阶段存在较多 replay**：`RF Launch Fail` 在 CoreMark 与 Dhrystone 中都很高，说明 IS 阶段判断可发射后，RF 阶段仍经常发现源操作数、前递、端口或结构条件不满足。
3. **LSU replay / ordering 相关事件明显**：Dhrystone 中 `LSU Cross 4K Stall`、`LSU Other Stall`、`LSU Spec Fail` 数量较大；CoreMark 中也有 `LSU Spec Fail` 与一定的 L1D load miss。
4. **CoreMark 有明显前端压力**：`Frontend Stall=29.88%`，主要来自高分支密度、代码路径分散、取指/预测/重定向气泡，而不是 I-cache miss。
5. **分支预测是次级瓶颈**：CoreMark 条件分支误预测率为 `3.54%`，Dhrystone 为 `0.85%`。这会损失性能，但不是当前最先应动手的主因。专门的 branch microbench 显示分支机制仍有研究空间。

### 1.2 优化优先级

| 优先级 | 方向 | 为什么优先 | 主要观察指标 |
|---:|---|---|---|
| P0 | 建立更细粒度 profiling | 现在的 `Backend Stall` 和 `RF Launch Fail` 太粗，必须拆分来源，否则改 RTL 容易盲目 | pipe 级 launch fail、IQ full、ROB full、LSIQ/AIQ/BIQ 水位、LSU replay 原因 |
| P1 | RF/IS 发射与 replay 机制 | `RF Launch Fail` 高，直接影响 IPC，是乱序核效率核心 | RF Launch Fail 下降，Backend Stall 下降，IPC 上升 |
| P2 | LSU restart/replay 与依赖预测 | Dhrystone 中 LSU stall 事件非常突出，CoreMark 也有 memory mix | LSU Spec Fail、LSU Cross 4K、LSU Other、SQ discard、L1D miss |
| P3 | 前端供给与分支重定向 | CoreMark `Frontend Stall` 接近 30%，branch microbench 暴露 RAS/indirect/随机分支弱点 | FE stall、Cond/Indir misp、IFU target misp、branch MPKI |
| P4 | 编译选项与代码形态 | 已证明 `-O3`/inline 会显著影响 Dhrystone/CoreMark，要固定口径并分离“编译器收益”和“硬件收益” | inst count、branch count、LDST%、score |
| P5 | Cache/PFU | 当前小规模 benchmark miss 率不高，暂时不是主瓶颈；后续扩展 STREAM/NPB/MiBench 后再强化 | L1D MPKI、L1I MPKI、RB/LFB 占用、PFU 命中 |

## 2. 数据来源与口径

### 2.1 有效结果目录

| 目录 | 状态 | 用途 |
|---|---|---|
| `baseline/` | 有 `.perf` | microbench 与旧 CoreMark 基线，适合看不同机制的压力点 |
| `coremark_c910_tuned_10/` | 有 summary，无 perf | CoreMark 10 次迭代成绩参考 |
| `coremark_c910_tuned_30_unknown_clean/` | 运行被终止，无 score/perf | 不用于结论 |
| `dhrystone_100/` | 有 summary + perf | 短迭代 Dhrystone，不作为正式成绩，只看趋势 |
| `dhrystone_c910_tuned_1000/` | 有 summary + perf | Dhrystone 性能口径之一 |
| `dhrystone_perf_o3_1000/` | 有 summary + perf | Dhrystone 当前最好性能口径 |
| `dhrystone_std_1000/` | 有 summary + perf | 禁内联/严格口径参考 |
| `direct_run_unknown_clean/` | 有 CoreMark + Dhrystone summary/perf | 当前主要正式结果 |

### 2.2 成绩汇总

| 结果目录 | 基准 | 迭代 | 主成绩 | cycles/run | Main IPC | CPU Time |
|---|---|---:|---:|---:|---:|---:|
| `coremark_c910_tuned_10` | CoreMark | 10 | 6.589569 CoreMark/MHz | 151755 | 1.511 | 3837.720s |
| `direct_run_unknown_clean` | CoreMark | 30 | 6.677975 CoreMark/MHz | 149746 | 1.543 | 9937.730s |
| `dhrystone_100` | Dhrystone | 100 | 4.900 DMIPS/MHz | 116.2 | 1.051 | 75.110s |
| `dhrystone_c910_tuned_1000` | Dhrystone | 1000 | 4.353 DMIPS/MHz | 130.7 | 1.449 | 591.960s |
| `dhrystone_perf_o3_1000` | Dhrystone | 1000 | 5.188 DMIPS/MHz | 109.7 | 1.723 | 482.160s |
| `dhrystone_std_1000` | Dhrystone | 1000 | 4.204 DMIPS/MHz | 135.4 | 0.851 | 615.660s |
| `direct_run_unknown_clean` | Dhrystone | 1000 | 5.187 DMIPS/MHz | 109.7 | 1.722 | 318.520s |

### 2.3 主要 perf 计数器汇总

| Case | CPI | IPC | FE Stall | BE Stall | Cond Misp | Indir Misp | L1I Miss | L1D Load Miss | RF Launch Fail | LSU 4K | LSU Other | LSU Spec Fail |
|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `baseline/coremark` | 0.786 | 1.272 | 26.81% | 38.22% | 9.67% | 17.80% | 0.09% | 0.70% | 2460 | 607 | 404 | 169 |
| `direct_run/coremark` | 0.649 | 1.541 | 29.88% | 34.23% | 3.54% | 19.52% | 0.01% | 0.70% | 24526 | 621 | 2611 | 2679 |
| `dhrystone_100` | 0.953 | 1.049 | 37.43% | 52.55% | 6.12% | 16.98% | 0.44% | 0.39% | 1467 | 1779 | 1016 | 100 |
| `dhrystone_c910_tuned_1000` | 0.690 | 1.449 | 11.76% | 34.53% | 1.04% | 15.49% | 0.09% | 0.03% | 5602 | 16380 | 53 | 2002 |
| `dhrystone_perf_o3_1000` | 0.581 | 1.722 | 14.25% | 29.77% | 0.86% | 17.37% | 0.07% | 0.05% | 10468 | 14381 | 10016 | 1000 |
| `dhrystone_std_1000` | 0.512 | 1.955 | 33.50% | 53.39% | 15.61% | 8.48% | 0.51% | 0.13% | 372 | 204 | 22 | 1 |
| `direct_run/dhrystone` | 0.581 | 1.721 | 14.37% | 30.65% | 0.85% | 17.37% | 0.07% | 0.04% | 10479 | 14381 | 10010 | 1000 |

注意：`dhrystone_std_1000` 的 Total IPC 高但 Main IPC 低，这说明 summary/perf 的总区间与主测区间存在口径差异；正式判断应优先看 direct/perf-o3 这类完整主测区间一致的数据。

### 2.4 microbench 机制压力点

| Case | IPC | FE Stall | BE Stall | 关键现象 | 说明 |
|---|---:|---:|---:|---|---|
| `bench_br_bimodal` | 2.382 | 0.96% | 0.85% | 表现很好 | 简单可预测分支对前后端压力很小 |
| `bench_br_corr` | 0.915 | 17.79% | 26.70% | Cond misp 14.59% | 全局历史/相关分支仍有误判 |
| `bench_br_indirect` | 0.690 | 13.97% | 40.67% | Indir misp 75.61% | 间接跳转预测对随机目标很弱 |
| `bench_br_ras` | 0.715 | 53.73% | 79.10% | RAS 深递归压力 | 返回预测失败与短样本放大 stall |
| `bench_branch` | 0.836 | 44.76% | 73.33% | 条件/间接分支都高 | 随机分支是分支预测 worst-case |
| `bench_cache_stride` | 0.513 | 23.57% | 36.03% | CPI 最高 | 小样本 stride 压力，需扩大数据集再判定 cache |
| `bench_fp` | 0.798 | 21.15% | 50.27% | FP 链/矩阵混合 | FP latency 与后端发射/等待明显 |
| `bench_frontend` | 0.791 | 15.97% | 30.28% | 前端压测不只 FE 高 | 即使前端 case，后端仍有资源限制 |
| `bench_ilp` | 0.698 | 68.89% | 61.34% | ILP 压测异常高 stall | 说明发射/窗口/数据依赖/代码形态需要复查 |
| `bench_mem` | 0.887 | 21.63% | 27.67% | LDST 53.35% | 小数据集 cache miss 低，主要看 LSU 管线与依赖 |

## 3. 怎样读这些计数器

### 3.1 IPC/CPI

`IPC = Retired Inst / Cycles`。C910 是乱序超标量核，理论上一拍可以取、译码、派遣、退休多条指令。实际 IPC 不到峰值通常有五类原因：

1. 前端无法稳定提供足够指令：取指、I-cache、BTB/BHT/RAS、重定向。
2. 派遣/重命名受限：ROB、物理寄存器、发射队列、flush。
3. 发射失败或源操作数未就绪：IQ 认为可发射，但 RF 阶段失败。
4. 执行/访存延迟：ALU/MUL/DIV/FP/LSU/cache miss。
5. 退休受限：ROB 头部未完成、异常或 flush、store commit 未完成。

### 3.2 Frontend Stall

`Frontend Stall / cycles` 表示前端供给不足或被重定向/暂停影响的占比。常见来源：

| 来源 | 对应机制 | 当前数据判断 |
|---|---|---|
| I-cache miss | L1I Miss | 关键 case 里 L1I miss 很低，不是主因 |
| 分支方向错误 | BHT / Bi-mode predictor | CoreMark 3.54%，Dhrystone 0.85%，不是首因 |
| 分支目标错误 | BTB / L0 BTB / Indirect BTB / RAS | indirect/RAS microbench 暴露明显弱点 |
| 重定向气泡 | IU BJU 发现 mispred 后 flush/reissue | CoreMark 分支密度高，会放大 FE stall |
| IBUF/LBUF 供给不足 | IFU 到 IDU 的缓冲 | 需要增加队列水位计数才能确认 |

### 3.3 Backend Stall

`Backend Stall / cycles` 表示后端不能有效接收/执行/退休的占比。C910 中应重点映射到：

| 可能来源 | 相关模块 | 应观察的内部信号/计数 |
|---|---|---|
| ROB 满或退休头阻塞 | RTU/ROB | `rob_entry_num`、`rtu_idu_rob_full` |
| 物理寄存器不足 | RTU/PST | `rtu_idu_no_alloc_preg` |
| 发射队列满 | IDU/IS | AIQ/BIQ/LSIQ/SDIQ 水位和 full |
| RF 阶段 launch fail | IDU/RF | event20 / `RF Launch Fail`，pipe 级 fail 原因 |
| LSU replay / discard | LSU/LQ/SQ/WMB | LSU Spec Fail、SQ discard、LSI replay |
| 长延迟执行单元 | IU/VFPU | MUL/DIV/FP busy，写回口冲突 |

当前 `Backend Stall` 在正式 CoreMark/Dhrystone 都超过 30%，所以优化应先从后端拆解开始。

### 3.4 RF Launch Fail

`RF Launch Fail` 是当前最关键的细粒度指标之一。根据 `doc/idu/18_rf_ctrl.md`，launch fail 与 stall 不同：

| 概念 | 含义 |
|---|---|
| Stall | IS 级被阻止发射，RF 阶段没有新有效指令进入 |
| Launch Fail | IS 级已经发射，但 RF 阶段发现条件不满足，需要取消并重调度 |

典型原因：

1. 源操作数未真正 ready：IS 阶段乐观预测可以前递，RF 阶段发现前递源还没到。
2. 物理寄存器读端口冲突：不同 pipe 同周期争用有限读端口。
3. MTVR/MFVR、DIV/MULT、VFPU 写回口冲突。
4. LSU 指令进入 RF 后发现地址/依赖/资源条件不满足。

当前数据：

| Case | RF Launch Fail | 判断 |
|---|---:|---|
| `direct_run/coremark` | 24526 | 很高，必须拆分 pipe 与原因 |
| `direct_run/dhrystone` | 10479 | 很高，对 Dhrystone 分数有直接影响 |
| `dhrystone_perf_o3_1000` | 10468 | 与 direct Dhrystone 一致，说明稳定存在 |
| `dhrystone_c910_tuned_1000` | 5602 | 仍高，但低于 perf-o3，说明代码形态影响发射失败 |

这说明当前乱序调度的“乐观发射”策略可能产生较多 replay。优化不一定是增大硬件，也可能是调整唤醒时机、ready 判定、优先级、端口冲突仲裁或编译器代码形态。

### 3.5 LSU 相关事件

| 事件 | 含义 | 当前判断 |
|---|---|---|
| `L1D Load Miss` | load 访问 L1D miss 率 | CoreMark 0.70%，Dhrystone 0.04%，不是主瓶颈 |
| `L1D Store Miss` | store 访问 L1D miss 率 | 正式结果很低 |
| `LSU Cross 4K Stall` | 访存跨 4K 页边界导致第二段翻译/访问等待 | Dhrystone 非常高，需定位是否计数口径或代码地址形态导致 |
| `LSU Other Stall` | LSU 其他 replay/stall 类事件 | Dhrystone perf-o3/direct 很高，需要进一步拆分 |
| `LSU Spec Fail` | load/store 顺序违例或相关 flush | CoreMark 2679、Dhrystone 1000，值得重点看 LQ/SQ/spec_fail_predict |
| `LSU SQ Discard` / `SQ Data Discard` | store-load 前递不能完成导致 replay | 当前数量不高，暂不是主因 |

注意：Dhrystone 的 `LSU Cross 4K Stall=14381` 与 `LSU Other Stall=10010` 远高于 L1D miss，说明访存瓶颈更多来自 LSU 管线、地址边界、依赖/replay，而不是 cache 容量。

### 3.6 分支误预测

当前正式结果：

| Case | Cond Misp | Indir Misp | 判断 |
|---|---:|---:|---|
| `direct_run/coremark` | 3.54% | 19.52% | 条件分支尚可；间接分支比例很小，百分比高但绝对数低 |
| `direct_run/dhrystone` | 0.85% | 17.37% | 条件分支很好；间接分支总数 213，绝对影响有限 |
| `baseline/coremark` | 9.67% | 17.80% | 旧基线分支明显差，调优后 CoreMark 条件分支已有改善 |

专门 microbench：

| Case | 现象 | 研究价值 |
|---|---|---|
| `bench_br_bimodal` | 预测效果很好 | 简单偏置分支不是问题 |
| `bench_br_corr` | Cond misp 14.59% | 可研究全局历史/相关分支 |
| `bench_br_indirect` | Indir misp 75.61% | 可研究 Indirect BTB 容量、索引、路径历史 |
| `bench_br_ras` | FE/BE 都很高 | 可研究 RAS 深度、push/pop、flush 恢复 |
| `bench_branch` | 随机分支 worst-case | 适合验证分支优化是否真的有效 |

结论：分支机制值得学习和局部优化，但若目标是先提升 CoreMark/Dhrystone，优先级低于 RF/LSU。

## 4. benchmark 逐项归因

### 4.1 CoreMark

`direct_run_unknown_clean/coremark`：

| 指标 | 数值 |
|---|---:|
| CoreMark/MHz | 6.677975 |
| cycles/run | 149746 |
| CPI / IPC | 0.649 / 1.541 |
| ALU% | 55.90% |
| LDST% | 31.58% |
| Cond Branch% | 20.39% |
| L1I Miss | 0.01% |
| L1D Load Miss | 0.70% |
| Cond Misp | 3.54% |
| FE Stall | 29.88% |
| BE Stall | 34.23% |

CoreMark 的指令混合比较像真实整数应用：ALU、load/store、branch 都有一定比例。它比 Dhrystone 更适合观察综合瓶颈。

瓶颈解释：

1. `L1I Miss=0.01%`，说明前端 stall 不是由 I-cache miss 主导。
2. `Cond Branch=20.39%`，分支密度高，少量 mispredict 也会导致显著重定向气泡。
3. `LDST=31.58%`，访存比例高，但 L1D miss 只有 0.70%，说明访存开销主要在 LSU 管线/依赖/端口，而非 cache 容量。
4. `FE=29.88%` 与 `BE=34.23%` 同时高，说明 CoreMark 不是单点瓶颈，而是前后端耦合：分支重定向会清空后端窗口，后端 replay/flush 又会反压前端。
5. `RF Launch Fail=24526` 是最应拆分的指标，它可能解释 BE stall 的大部分来源。

CoreMark 优化应优先做：

1. 拆分 `RF Launch Fail` 原因。
2. 统计每类 IQ 水位与发射成功率。
3. 分函数/PC 区间统计 FE/BE 和 branch misp，定位热点函数。
4. 再根据热点决定是否优化分支预测或 LSU。

### 4.2 Dhrystone

`direct_run_unknown_clean/dhrystone`：

| 指标 | 数值 |
|---|---:|
| DMIPS/MHz | 5.187 |
| cycles/run | 109.7 |
| CPI / IPC | 0.581 / 1.721 |
| ALU% | 55.42% |
| LDST% | 43.48% |
| Store% | 17.64% |
| Cond Branch% | 11.28% |
| L1D Load Miss | 0.04% |
| Cond Misp | 0.85% |
| FE Stall | 14.37% |
| BE Stall | 30.65% |
| RF Launch Fail | 10479 |
| LSU Cross 4K Stall | 14381 |
| LSU Other Stall | 10010 |
| LSU Spec Fail | 1000 |

Dhrystone 的条件分支预测已经很好，I/D cache miss 也很低，所以 Dhrystone 的优化重点不是前端 cache，也不是分支预热。

瓶颈解释：

1. `LDST=43.48%`，访存比例高，且 store 占比 17.64%，这会显著触发 LSU 的 LQ/SQ/WMB 机制。
2. `L1D Load Miss=0.04%`，说明数据基本命中 L1D。
3. `LSU Cross 4K Stall=14381` 与 `LSU Other Stall=10010` 很高，说明 LSU 内部 stall/replay 是 Dhrystone 的关键疑点。
4. `RF Launch Fail=10479` 也高，说明即便 Dhrystone 这种小程序，后端发射仍有大量失败重调度。
5. `Cond Misp=0.85%`，分支预测不是主要瓶颈。

Dhrystone 优化应优先做：

1. 先确认 `LSU Cross 4K Stall` 计数语义是否是“周期数”还是“事件数”，并用波形看触发 PC。
2. 用 PC 范围统计 `Proc_1`/`Proc_2`/`Func_1` 等热点函数的 LSU 事件。
3. 对比 `dhrystone_c910_tuned_1000` 与 `dhrystone_perf_o3_1000` 的 asm，找出为什么 `-O3` cycles/run 从 130.7 降到 109.7。
4. 拆分 RF launch fail 是否主要来自 LSU pipe3/4/5，还是整数 pipe0/1。

### 4.3 Dhrystone 不同口径对比

| 结果 | DMIPS/MHz | cycles/run | Main IPC | FE | BE | 解释 |
|---|---:|---:|---:|---:|---:|---|
| `std_1000` | 4.204 | 135.4 | 0.851 | 33.50% | 53.39% | 禁内联导致调用/分支/代码路径开销大 |
| `c910_tuned_1000` | 4.353 | 130.7 | 1.449 | 11.76% | 34.53% | 有调优但 cycles 仍偏高 |
| `perf_o3_1000` | 5.188 | 109.7 | 1.723 | 14.25% | 29.77% | 当前最好口径 |
| `direct_run` | 5.187 | 109.7 | 1.722 | 14.37% | 30.65% | 与 perf-o3 基本一致 |

这说明 Dhrystone 对编译器形态极度敏感。硬件优化必须固定编译口径，否则无法区分“硬件变快”还是“编译器把代码变短”。

### 4.4 microbench 的教学价值

这些 microbench 不一定适合作为正式性能排名，但非常适合学习乱序超标量关键机制：

| microbench | 学习对象 | 应看模块 |
|---|---|---|
| `bench_br_bimodal` | BHT 2-bit 饱和计数、偏置分支 | IFU BHT |
| `bench_br_corr` | 全局历史、相关分支 | IFU BHT/GHR |
| `bench_br_indirect` | 间接跳转目标预测 | IFU Indirect BTB |
| `bench_br_ras` | 返回地址栈深度、调用返回匹配 | IFU RAS + IU BJU |
| `bench_frontend` | 取指/译码/IBUF 供给 | IFU IBUF/LBUF + IDU |
| `bench_ilp` | 乱序窗口、发射队列、执行端口、依赖链 | IDU/IS + IU + RTU |
| `bench_mem` | LQ/SQ/WMB、store-load 前递、replay | LSU |
| `bench_cache_stride` | D-cache 访问模式与 miss/replay | LSU DCache/PFU |
| `bench_fp` | FP latency、VIQ、写回口冲突 | VFPU + IDU |

## 5. 当前最值得掌握的乱序超标量机制

### 5.1 前端：PCGEN、BTB/BHT/RAS、IBUF

乱序核后端再强，也需要前端持续提供足够指令。C910 IFU 的核心链路是：

```text
PCGEN -> ICache/BTB/BHT/RAS -> predecode -> IBUF/LBUF -> IDU
```

需要掌握的问题：

1. 下一拍 PC 从哪里来：顺序 PC、L0 BTB、BTB、BHT taken、RAS、IU mispred redirect、RTU exception。
2. 预测错一次损失多少周期：IFU 到 BJU resolve 再 redirect 的总 bubble。
3. IBUF 能不能吸收前端/后端速率波动。
4. branch density 高时，BTB/BHT/RAS 的目标/方向错误怎样转换成 `Frontend Stall`。

当前行动：

1. 用 `bench_br_bimodal` 作为 sanity check，确保简单方向预测不能退化。
2. 用 `bench_br_indirect` 研究 Indirect BTB，目标是降低 75.61% 的 indirect misp。
3. 用 `bench_br_ras` 研究 RAS 深度、flush 恢复、调用返回匹配。
4. 在 CoreMark 中做 PC 区间统计，确认 FE stall 是否集中在 list/state 等函数。

### 5.2 IDU/IS/RF：乱序发射与 replay

C910 的乱序核心不是“只要 IQ 有 ready 指令就执行”。真实路径更复杂：

```text
rename/dispatch -> issue queue -> select/wakeup -> RF read/final check -> execute
```

`RF Launch Fail` 正是这里的关键现象：发射队列以为这条指令可以发，但 RF 阶段最终检查失败。

你需要重点掌握：

1. wakeup/select 的 ready 判定是不是保守还是乐观。
2. 前递网络什么时候能承诺数据可用。
3. PRF 读端口如何分配，哪些 pipe 会冲突。
4. pipe0/1/2/3/4/5/6/7 的发射失败分别来自什么。
5. launch fail 后指令如何回 IQ，是否导致队列抖动。

当前行动：

1. 给 perf 增加 pipe 级 launch fail 细分：
   - pipe0/1 ALU
   - pipe2 BJU
   - pipe3 load
   - pipe4 store address
   - pipe5 store data
   - pipe6/7 VFPU
2. 给 launch fail 增加原因细分：
   - src not ready
   - preg port conflict
   - vreg port conflict
   - div/mult/vfpu writeback conflict
   - LSU resource/restart
3. 每次优化先看 `RF Launch Fail / Retired Inst` 是否下降，再看 IPC。

### 5.3 RTU/ROB/PST：乱序执行如何按序退休

RTU 负责把乱序执行重新变成精确的顺序状态。相关瓶颈通常体现为 `Backend Stall`。

需要掌握：

1. ROB 水位是否经常接近满。
2. ROB 头部是否被长延迟 load/div/fp 阻塞。
3. PST 是否因为物理寄存器不足反压 IDU。
4. flush 是否频繁清空窗口。
5. 退休宽度是否被 store commit 或异常路径限制。

当前行动：

1. 给结果增加 `rob_entry_num` 的平均/最大值。
2. 记录 `rtu_idu_rob_full` 周期数。
3. 记录 `rtu_idu_no_alloc_preg` 周期数。
4. 记录 flush 次数与原因：branch mispred、LSU spec fail、exception。

### 5.4 LSU：LQ/SQ/WMB、store-load 前递、spec fail

LSU 是当前最值得深入的模块之一。Dhrystone 的数据已经说明：cache miss 很低，但 LSU stall/replay 很高。

核心路径：

```text
load:  AG -> DC(LQ/SQ/WMB compare) -> DA(cache/forward/miss) -> WB
store: AG/DC/DA -> SQ -> retire commit -> WMB -> DCache/BIU
```

你需要掌握：

1. load 是否越过 older store 执行。
2. store-load 前递什么时候成功，什么时候 discard/replay。
3. LQ 如何检测 RAW/RAR 顺序违例。
4. spec_fail_predict 如何让曾经违例的 load 下次保守执行。
5. WMB 如何影响已提交 store 的可见性。
6. Cross 4K stall 与非对齐拆分如何产生。

当前行动：

1. 先追 `LSU Cross 4K Stall`，因为 Dhrystone 中数值异常高。
2. 再追 `LSU Other Stall`，需要拆成具体子类。
3. 对 `LSU Spec Fail` 做 PC 直方图，确认是不是少数 load 反复触发。
4. 用 `bench_mem` 扩大 ARRAY_SIZE，让它真正超过 L1D，以区分 replay 和 cache miss。

### 5.5 执行单元与写回端口

CoreMark/Dhrystone 整数 ALU 占比高，FP 很少；当前正式成绩不是 FP 受限。但 `bench_fp` 显示 FP case `BE=50.27%`，说明后续研究 FP 时要看：

1. VIQ 发射效率。
2. FP latency chain 与 independent FP ILP 的差异。
3. pipe6/7 写回口冲突。
4. MTVR/MFVR 与整数 PRF/VRF 端口共享冲突。

当前行动：

1. 暂时不要把 FP 作为 CoreMark/Dhrystone 的首要优化方向。
2. 后续要扩展 Whetstone/NPB EP/CG 时，再系统看 VFPU。

## 6. 可执行优化路线

### 6.1 第一阶段：把粗计数拆细

目标：不要直接改复杂 RTL。先把“为什么 BE stall 高”拆成可验证的子项。

新增或导出以下计数：

| 类别 | 指标 | 目的 |
|---|---|---|
| IDU/RF | pipe0~7 launch fail | 判断哪个执行簇导致 replay |
| IDU/RF | src_no_rdy fail | 判断 wakeup/forward 预测是否过于乐观 |
| IDU/RF | preg/vreg port conflict fail | 判断是否读端口冲突 |
| IDU/IS | AIQ/BIQ/LSIQ/SDIQ full cycles | 判断 issue queue 是否堵塞 |
| RTU | ROB full cycles | 判断乱序窗口是否不足 |
| RTU | no free preg cycles | 判断物理寄存器是否不足 |
| RTU | flush count by reason | 判断分支/LSU 哪种 flush 更伤 |
| LSU | LQ/SQ/WMB/RB/LFB full cycles | 判断 LSU 队列瓶颈 |
| LSU | replay reason split | 拆分 LSU Other Stall |
| IFU | IBUF empty/full cycles | 判断前端供给还是后端反压 |

验收标准：

1. 重新跑 CoreMark 30、Dhrystone 1000。
2. 文档里能回答：BE stall 的前三个来源分别占多少。
3. 每个来源能映射到具体 RTL 模块和信号。

### 6.2 第二阶段：优化 RF Launch Fail

候选方向：

| 方向 | 可能改动 | 风险 | 验证 |
|---|---|---|---|
| 更保守的 ready 判定 | IS 阶段减少过早发射 | 可能降低并行度 | launch fail 降，IPC 不降 |
| 改进前递可用性判断 | 更准确判断 EX/WB 结果何时可用 | 时序复杂 | src_no_rdy fail 降 |
| 调整 pipe 优先级 | 减少高频 pipe 的端口冲突 | 可能伤其他 workload | preg port conflict 降 |
| 增加/复制读端口 | 硬件收益直接 | 面积/时序代价大 | conflict fail 大幅降 |
| 调整 IQ replay 策略 | 避免同一指令连续失败 | 控制复杂 | replay burst 减少 |

建议顺序：

1. 先观测，不直接增加端口。
2. 如果主要是 `src_no_rdy`，研究 wakeup/forward。
3. 如果主要是 `preg port conflict`，先调优仲裁优先级，再考虑端口。
4. 如果主要是 LSU pipe，转入 LSU 阶段。

### 6.3 第三阶段：优化 LSU

候选方向：

| 方向 | 可能改动 | 目标指标 |
|---|---|---|
| Cross 4K 计数定位 | 找触发 PC 与访问类型 | 确认是否真实瓶颈 |
| spec_fail_predict 优化 | 减少同一 load 反复违例 | LSU Spec Fail 下降 |
| store-load 前递优化 | 降低 SQ Data Discard | SQ discard 下降 |
| LSIQ replay 策略优化 | 减少无效重发 | LSU Other Stall 下降 |
| WMB/SQ 提交节奏优化 | 减少 store 反压 | BE stall 下降 |
| RB/LFB/PFU 优化 | 扩展到大数据集后处理 miss | L1D MPKI 与 miss penalty 下降 |

建议先做两件非常具体的事：

1. 追踪 Dhrystone 中 `LSU Cross 4K Stall=14381` 的触发 PC。如果集中在计时/库函数或特殊地址访问，可能不是核心算法瓶颈；如果集中在 Dhrystone 主循环，则要看地址对齐和栈/全局变量布局。
2. 追踪 `LSU Spec Fail=1000` 是否每 iteration 近似一次。如果是，说明有固定 load/store 序列导致每轮 replay，一旦优化会稳定提升。

### 6.4 第四阶段：优化前端与分支

候选方向：

| 方向 | 适用 case | 目标 |
|---|---|---|
| BHT/GHR 调整 | `bench_br_corr` | 降低相关分支 misp |
| Indirect BTB 索引/容量 | `bench_br_indirect` | 降低间接目标 misp |
| RAS 深度/恢复 | `bench_br_ras` | 降低深调用返回错误 |
| IBUF/LBUF 策略 | CoreMark / frontend | 降低 FE stall |
| 分支 resolve 提前 | CoreMark | 降低 mispred penalty |

注意：branch microbench 的提升不一定能转化到 CoreMark。每个分支优化必须同时跑：

1. `bench_br_*`
2. `bench_branch`
3. CoreMark 30
4. Dhrystone 1000

只有 CoreMark/Dhrystone 不退化，microbench 改进才值得保留。

### 6.5 第五阶段：扩展 benchmark

当前 benchmark 数据偏小，Cache/PFU/内存系统没有充分展开。后续建议：

| benchmark | 目的 | 注意 |
|---|---|---|
| MiBench `qsort/bitcount/crc32/sha/dijkstra` | 应用型整数负载 | 适合 RTL 仿真裁剪输入 |
| Embench | 嵌入式小型综合负载 | 比 Dhrystone 更现代 |
| STREAM 裁剪版 | 访存带宽/访存流 | 数据规模要适合 RTL |
| Whetstone/small FP | 浮点路径 | 用于 VFPU |
| NPB EP/IS/CG 小规模 | memory/branch/FP | 移植成本更高 |

## 7. 每轮实验的标准模板

每轮只改一个主要机制，按以下顺序记录。

### 7.1 实验记录表

| 字段 | 内容 |
|---|---|
| 实验 ID | 例如 `rf_lchfail_src_ready_v1` |
| Git commit | 修改前/修改后 commit |
| 修改点 | 具体 RTL 文件、信号、参数 |
| 假设 | 例如“src_no_rdy 过高导致 RF replay” |
| 预期变化 | RF Launch Fail 下降，BE Stall 下降，IPC 上升 |
| benchmark | CoreMark 30、Dhrystone 1000、相关 microbench |
| 正确性 | TEST PASS、CRC/DMIPS/CoreMark 校验 |
| 主结果 | score、cycles/run、IPC |
| 反证指标 | 是否引入 FE stall、misp、miss 或其他退化 |
| 是否保留 | 保留/回退/继续细化 |

### 7.2 判定规则

| 结果 | 判定 |
|---|---|
| IPC 上升且目标 counter 下降 | 有效优化 |
| IPC 上升但目标 counter 不变 | 可能不是该假设导致，需要重新归因 |
| 目标 counter 下降但 IPC 不升 | 优化方向局部有效，但不是主瓶颈 |
| CoreMark 升、Dhrystone 降 | 需要判断目标 workload，不能直接合入 |
| microbench 升、正式 benchmark 不变 | 作为机制研究有效，但不是性能主线 |
| 分数提升但 inst count 大幅变化 | 多半是编译器/代码形态变化，不能直接归因到硬件 |

## 8. 建议从哪里开始读代码

### 8.1 第一条主线：RF Launch Fail

阅读顺序：

1. `doc/idu/18_rf_ctrl.md`
2. `doc/idu/19_rf_dp.md`
3. `doc/idu/20_rf_fwd.md`
4. `doc/idu/13_is_aiq.md`
5. `doc/idu/15_is_lsiq.md`
6. `C910_RTL_FACTORY/gen_rtl/idu/rtl/ct_idu_rf_ctrl.v`
7. `C910_RTL_FACTORY/gen_rtl/idu/rtl/ct_idu_is_ctrl.v`

目标：回答每一次 `RF Launch Fail` 是哪条 pipe、哪种原因、之后如何重发。

### 8.2 第二条主线：LSU replay

阅读顺序：

1. `doc/lsu/00_lsu_overview.md`
2. `doc/lsu/01_ld_pipeline.md`
3. `doc/lsu/03_lq.md`
4. `doc/lsu/04_sq.md`
5. `doc/lsu/05_wmb.md`
6. `doc/lsu/10_misc.md`
7. `C910_RTL_FACTORY/gen_rtl/lsu/rtl/ct_lsu_lq.v`
8. `C910_RTL_FACTORY/gen_rtl/lsu/rtl/ct_lsu_sq.v`
9. `C910_RTL_FACTORY/gen_rtl/lsu/rtl/ct_lsu_spec_fail_predict.v`

目标：解释 Dhrystone 的 `LSU Cross 4K`、`LSU Other`、`LSU Spec Fail`。

### 8.3 第三条主线：分支与前端

阅读顺序：

1. `doc/ifu/00_ifu_overview.md`
2. `doc/ifu/04_bht.md`
3. `doc/ifu/03_btb.md`
4. `doc/ifu/05_ras.md`
5. `doc/ifu/13_ibuf.md`
6. `doc/iu/02_bju.md`

目标：解释 CoreMark 的 `Frontend Stall=29.88%`，并判断它来自预测错误、目标错误、IBUF 供给还是后端反压。

### 8.4 第四条主线：ROB/PST/退休

阅读顺序：

1. `doc/rtu/00_rtu_overview.md`
2. `doc/rtu/01_rob.md`
3. `doc/rtu/04_retire.md`
4. `doc/rtu/05_pst_preg.md`
5. `doc/rtu/03_rob_expt.md`

目标：判断 `Backend Stall` 是否与 ROB/PREG/retire/flush 相关。

## 9. 当前最具体的行动清单

### 9.1 立即做

1. 增加结果分析脚本：从 `.perf` 自动生成统一表格，避免手工抄数。
2. 增加 RF Launch Fail 细分计数：pipe + reason。
3. 增加 LSU stall 细分计数：cross4k、specfail、sq discard、rb/lfb/wmb full、其他 replay。
4. 增加 ROB/IQ 水位统计：平均、最大、full cycles。
5. 保持当前 CoreMark 30 / Dhrystone 1000 作为固定 baseline。

### 9.2 第一轮 RTL 研究实验

建议第一轮不要改功能，只加观测点。

实验名：`profile_backend_breakdown_v1`

目标：

1. 解释 `direct_run/coremark` 的 `BE=34.23%`。
2. 解释 `direct_run/dhrystone` 的 `BE=30.65%`。
3. 将 `RF Launch Fail` 拆成可行动的前三个原因。

产出：

1. `results/backend_breakdown_v1/`
2. `coremark.summary.txt`
3. `dhrystone.summary.txt`
4. `backend_breakdown.md`

### 9.3 第二轮优化实验

根据第一轮结果选择：

| 如果第一大原因是 | 第二轮动作 |
|---|---|
| `src_no_rdy` | 调整 wakeup/forward ready 判定 |
| `preg port conflict` | 先调优 pipe 优先级，再考虑读端口 |
| `LSU pipe launch fail` | 转向 LSIQ/LSU replay |
| `ROB full` | 看长延迟 head-of-ROB 与窗口大小 |
| `no free preg` | 看物理寄存器回收与分配策略 |
| `branch flush` | 转向 BHT/BTB/RAS/BJU |

## 10. 最终目标

通过这个项目掌握乱序超标量处理器，不应只追一个 benchmark 分数。建议把学习目标拆成以下可验收能力：

1. 能从 `IPC/FE/BE/miss/misp/replay` 判断瓶颈大类。
2. 能把每个 perf counter 映射到 RTL 模块和信号。
3. 能设计 microbench 验证某个机制。
4. 能提出一个“单假设、单改动、可反证”的实验。
5. 能解释优化为什么有效，或为什么无效。
6. 能区分硬件优化、编译器优化、benchmark 口径变化。

当前项目最好的切入点是 **RF Launch Fail + LSU replay**。这两条线既能解释当前正式成绩，也覆盖乱序超标量最核心的机制：发射、前递、端口、乱序访存、replay、flush 与精确状态。
