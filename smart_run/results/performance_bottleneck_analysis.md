# C910 RTL 性能瓶颈定位与体系结构升级路线

本文基于当前最新的 43 项 SPEC CPU 2017 representative composite kernel Full RTL 结果、对应程序动态特征，以及 CoreMark、Dhrystone 和机制 microbench 的细粒度计数器，按照最新数据和 RTL 信号定义建立当前 C910 的性能瓶颈结论。

## 1. 数据范围与可信度

### 1.1 主数据集

| 数据集 | 内容 | 用途 |
|---|---|---|
| `smart_run/results/spec_all_43_full_1f451a653e1c_dirty/` | 43 个 Rate/Speed 独立 composite ELF 的 Full RTL 结果 | 主性能样本 |
| `smart_run/kernel_features/spec_all_43_full_final/` | 同一批 43 个 case 的动态指令、分支、访存、依赖、局部性和理想 ILP 特征 | 解释程序需求 |
| `smart_run/results/archive/all_cases_1f451a653e1c_dirty/` | CoreMark、Dhrystone、branch/ILP/frontend/memory/FP microbench | 机制隔离和反证 |
| `smart_run/PERF_DETAIL.md` | 805 个 detail、189 个 profile、54 个 latency 指标的正式定义 | 指标口径 |
| `smart_run/logical/tb/tb.v` | CPI stack 和各计数器的实际信号组合 | 核查归因优先级 |
| `C910_RTL_FACTORY/gen_rtl/idu/rtl/` | IQ entry、ready/select、create 与 `full_updt` 的实际组合逻辑 | 核查队列深度及阻塞语义 |
| `C910_RTL_FACTORY/gen_rtl/pmu/rtl/ct_hpcp_top.v` | `minstret` 对三个退休 slot 的 `inst_num` 累加逻辑 | 核查 IPC 与退休宽度口径 |

三组结果都对应提交 `1f451a653e1c64abc588b0da47cef16424d3843b`，工作区状态为 `dirty`。结果目录保存了 `git.diff` 和 `git.status`，后续比较必须继续保留这两项，不能只记录短 commit。

SPEC 主数据的完整性如下：

- 43/43 个 RTL case 为 `TEST PASS`。
- 每项均具有基础 `.perf`、805 个 detail 事件、189 个 profile 指标和 54 个 latency 分布。
- Full ROI 为约 44 万至 61 万条动态指令，并在 ROI 前执行独立 warmup。
- 23 个 Rate 和 20 个 Speed composite 的机制权重校准全部通过，最大目标份额误差不超过 0.446 个百分点。
- 程序特征侧 43/43 项校验通过。
- 程序特征与 RTL 是分别构建的 ELF，SHA256 不相同，不能声称逐字节同一二进制；但 42/43 项 ROI 动态指令数与 RTL 退休数只差 `-3..+3`，`521.wrf_r` 对应 case 相差 57 条。因此联合分析适合做机制级归因，但不是逐指令时序对齐证明。

### 1.2 结果能说明什么

这些 Full kernel 已经比早期 quick 或单机制 kernel 更可靠：每个 Rate/Speed benchmark 都有独立 ELF，composite 根据 SimPoint cluster 的分析结果把多个代理机制按权重组合，动态机制份额经过校准。这里校准的是代理机制的执行份额，不是把原 SPEC 的多个真实动态区间逐指令拼接到 ELF 中。它们适合回答：

1. 当前 RTL 对不同控制流、整数、浮点、访存和依赖组合的响应是什么。
2. 哪类队列、执行路径、预测器或 LSU 机制最值得做 A/B 实验。
3. 某项微结构修改是否让目标事件下降并带来 IPC 改善。

但它们仍不是 checkpoint/restore 后执行的真实 SPEC 代表区间，也没有完整 ref 输入的多 GB 工作集、OS 行为和长时间相位变化。因此不能把这里的 IPC 换算为官方 SPECspeed/SPECrate 分数，也不能据此宣称已经测得真实 SPEC 的 L2、LLC 或 DRAM 性能。本文定位的是“当前代理 composite 在 C910 RTL 上暴露的机制瓶颈”；只有已经校准的指令类别、分支、访存和依赖维度可以映射回对应 SPEC 行为，不能进一步声称原程序真实区间必然具有完全相同的队列占用或 IPC 排名。

### 1.3 本文采用的归因标准

本文把证据分成三个层次，避免把性能现象直接写成微结构根因：

1. **结果层**：IPC、零退休和 CPI 分类回答“性能损失有多大”，但不能单独回答“为什么损失”。
2. **阻塞层**：某个具体队列 full、entry not-ready、ready-not-issued、RF launch fail、branch flush 或 LSU replay 回答“工作停在哪一层”。这些是最接近 RTL 行为的直接证据。
3. **根因层**：生产者延迟、结果前递覆盖不足、选择仲裁、端口冲突、预测器索引冲突或访存依赖预测失效回答“为什么该层停住”。当前计数器只能把一部分 case 推进到这一层，其余必须通过单变量 RTL 实验确认。

一个结论只有同时满足以下链条才被写成较强判断：程序动态特征提出需求，RTL 中对应队列或执行路径出现压力，压力事件与吞吐损失同向变化，且负对照没有同样现象。若只满足其中一项，本文只把它称为候选原因。例如 `IQ selected/cycle` 与 IPC 高相关主要是结果层一致性；VIQ 长期接近满、绝大多数 entry 未 ready、等待源又明确不是 load producer，才足以把低 FP case 定位到 FP producer/forward/wakeup 路径。

### 1.4 从流水线理解指标之间的因果关系

C910 中一条指令大致沿下面的路径前进：

```text
取指/预测 -> IBUF -> 译码 -> 重命名/dispatch -> AIQ/BIQ/LSIQ/SDIQ/VIQ
                                                -> ready/select -> RF launch
                                                -> 执行/访存 -> writeback/完成
                                                -> ROB 按序退休
```

其中 IBUF 是指令缓冲，AIQ 是整数/算术发射队列，BIQ 是分支发射队列，LSIQ 是 load/store 地址相关发射队列，SDIQ 是 store data 发射队列，VIQ 是向量/浮点发射队列，RF 是寄存器文件阶段，ROB 是保证按序提交和精确异常的重排序缓冲。不同类型指令进入不同队列，所以“总 IQ 压力”必须继续拆到具体队列才有结构意义。

性能分析必须沿这条路径寻找“最早发生的限制”。下游变慢会通过队列满逐级向上游传播。例如 FP producer 长时间不返回，等待它的 VIQ entry 不能 ready；VIQ entry 释放变慢后队列逐渐填满；dispatch 被阻塞后 IBUF 无法继续下送，最终 IBUF full；此时计数器可能同时出现 VIQ not-ready、VIQ full、dispatch stall、IBUF full 和零退休。它们不是五个独立瓶颈，而是一条因果链上的不同观测点。若把最上游的 IBUF full 当成根因，就会错误地去扩大 I-cache；若只看到 VIQ full 就扩容，也可能只是把同一批等待 producer 的指令存得更多。

本文中的 producer（生产者）是生成某个寄存器结果的较老指令，consumer（消费者）是读取该结果的较新指令；wakeup（唤醒）是通知等待 entry“该源即将或已经可用”，forwarding（结果前递）是在正式写回寄存器文件前直接把执行结果送给后续流水级，select（选择）则从已 ready 的 entry 中挑选本周期可以发射的指令。这几个时点的先后关系决定了一条依赖链在 IQ 中停留多久。

几个核心量的含义如下：

- `IPC = 退休指令数 / 周期数`，`CPI = 1 / IPC`。IPC 是最终结果，不指出损失位置。
- `zero-retire` 表示当周期三个退休 slot 都无效。乱序核可以在其他周期一次退休多个 ROB entry，而且 C910 的 `minstret` 还按每个有效 slot 携带的 `inst_num` 累加架构指令数，因此零退休率不能直接换算为 IPC；但它与低 IPC 同时升高时，说明完成流或 ROB 头部经常断流。
- `occupancy` 是队列平均占用，近似满足排队关系 `平均占用 ≈ 到达率 × 平均驻留时间`。占用高既可能是进入得多，也可能是出去得慢。
- `not-ready` 表示 entry 仍在等待源操作数或其他发射条件，问题位于 producer、wakeup、forward 或依赖链。
- `ready-not-issued` 表示 entry 已具备输入但没有被 select，优先检查仲裁、端口映射和执行单元接收能力。
- `issue-select` 表示队列已经选出指令；若随后 `RF launch fail`，问题位于 RF 源检查、晚到 forwarding、端口条件或执行管线入口。
- `full-update/create-blocked` 表示队列容量已经对 dispatch 形成直接反压，但不能单独区分容量太小还是 entry 驻留时间太长。

因此，本文不按“哪个百分比最大”机械排序，而是先找最早出现的异常，再用下游事件验证传播方向。这个方法也是后续微结构优化最重要的教学主线。

## 2. 核心结论

基于最新结果，当前性能问题不能再概括为单一的“IQ not-ready”。更准确的结论是：

1. **跨 workload 最广泛的直接阻塞点是后端队列服务不足并向前形成反压。** 43 项中 `is_iq_full_stall` 中位数为 17.66% 周期，P90 为 41.34%，与 IPC 的 Spearman 相关系数为 -0.600。压力能落到具体队列：整数 workload 主要是 AIQ0/AIQ1，FP workload 主要是 VIQ0/VIQ1，mcf/parest/bwaves 的部分压力来自 LSIQ。这里的“服务不足”包括 producer 未 ready、select/端口吞吐不足和真实容量不足，不能预先等同于队列 entry 太少。
2. **高 `frontend` proxy 不能直接解释成前端供给不足。** CPI stack 的 `frontend` 类包含 `IBUF full`，而不是只包含 IBUF empty 或 I-cache miss。43 项的 L1I miss 中位数只有 0.01%，I-cache refill busy 中位数只有 0.294%，但 IBUF full 中位数达到 38.60%。大量所谓 frontend 周期实际上是后端消费不动后产生的满缓冲反压。
3. **FP/VIQ 是最明显的低 IPC workload 簇。** `526.blender_r`、`544.nab_r`、`644.nab_s`、`511.povray_r`、`508.namd_r` 的 IPC 只有 0.944、0.957、1.087、1.037、1.228；VIQ not-ready、VIQ full-update 和 RF launch 空周期同时偏高。这条线应优先研究 VFPU producer latency、forward/wakeup 和 VIQ 服务率，而不是归因于 I-cache。
4. **mcf 的第一问题是 branch bad speculation，第二问题是 LSIQ/访存。** `505.mcf_r` 和 `605.mcf_s` 的 IPC 为 0.690/0.710，条件分支误预测率为 17.30%/17.38%，退休 BHT 误预测为 43.18/41.83 MPKI，BadSpec 占 20.44%/20.29%，同时 LSIQ full-update 为 6.88%/7.35%。它们是分支预测与 LSU 联合瓶颈，不是普通 AIQ 容量问题。
5. **整数 workload 的主要压力是 AIQ 服务率、ready/select 和依赖链。** xalancbmk、perlbench、deepsjeng_s、exchange2_s 等 case 的 AIQ0 full-update 达 28% 至 37%，部分 case ready 但未 issue 也明显偏高。应先区分慢 producer/wakeup、select 仲裁和执行端口吞吐，再决定是否扩容 AIQ。
6. **Dhrystone 最突出的异常路径在 LSU store-address/SQ speculation，但实际 flush 代价不能由 deep 事件直接代替。** 它的 L1D load miss 为 0，条件分支误预测只有 0.07%；`rf_pipe5_staddr_no_rdy=43.466/KI`、`lsu_sq_cancel_width_avg=0.328/cycle`，writeback 侧 `lsu_spec_fail_deep=100.883/KI`，但最终 `lsu_spec_fail_flush` 只有 4.860/KI，BadSpec 仅占 1.044% 周期。这说明 LSU 内部有大量取消/失败活动，真正成为全核恢复的只是其中一部分。Dhrystone 适合定位 store-address 和 SQ 效率，不能代表 SPEC branch 或 FP 路径，也不能把全部 deep 事件都折算成 flush 损失。
7. **ROB 和物理寄存器总容量不是当前第一优先级。** `is_rob_full_stall` 中位数为 0，最大仅 0.417%；`rob_occ_ge32` 最大仅 0.293%，`rob_occ_ge64` 全部为 0。虽然 `ir_preg_not_vld` 在 mcf 达 13%，但真正的 `preg_alloc*_block` 和 `preg_alloc_block_avg` 在 43 项中全为 0，物理寄存器可用宽度中位数为 3.978/4。不能把 `ir_preg_not_vld` 直接解释成 free-list 耗尽。

因此，当前体系结构升级主线应是：**先修正前后端归因口径，再按 AIQ、VIQ、LSIQ 分别做服务率和容量实验，同时独立推进 mcf 类分支预测与 Dhrystone/bench_mem 类 LSU 地址和 speculation 路径。**

## 3. 全局性能现象

### 3.1 43 项统计分布

| 指标 | 中位数 | P90 | 最小值 | 最大值 | 含义 |
|---|---:|---:|---:|---:|---|
| IPC | 1.649 | 1.995 | 0.690 | 2.294 | 总体吞吐 |
| 零退休周期 | 48.34% | 62.68% | 27.40% | 73.43% | 接近一半周期没有退休 |
| RF launch 0 周期 | 11.51% | 24.09% | 4.47% | 33.89% | 执行发射入口断流 |
| RF launch 平均宽度 | 1.935 | 2.288 | 1.029 | 2.442 | 实际送入执行端的平均宽度 |
| IQ selected/cycle | 1.756 | 2.132 | 0.880 | 2.321 | 队列实际选择吞吐 |
| IQ full dispatch stall | 17.66% | 41.34% | 5.07% | 49.84% | 队列反压 dispatch |
| Frontend Stall 原始事件 | 38.26% | 59.87% | 12.63% | 68.62% | 可与后端事件重叠，且含满缓冲 |
| Backend Stall 原始事件 | 39.80% | 56.98% | 15.41% | 67.98% | 可与前端事件重叠 |
| 条件分支误预测率 | 2.68% | 13.71% | 0.42% | 17.38% | 分支方向预测准确率 |
| L1D load miss | 2.79% | 5.07% | 0.28% | 8.93% | 实际 L1D load miss |
| L1I miss | 0.01% | 0.01% | 0 | 0.01% | 当前 ROI 几乎没有 I-cache miss |

43 项 IPC 与关键指标的 Spearman 相关性如下。Spearman rho 比较的是两个量的排序是否单调一致，不要求线性关系；rho 接近 +1 表示指标越大时 IPC 通常越大，接近 -1 表示指标越大时 IPC 通常越低。这里的 43 项混合了整数、FP、Rate 和 Speed，不同程序需求会形成混杂，因此相关性只用于筛选机制，不能证明因果：

| 指标 | 与 IPC 的 Spearman rho | 解释 |
|---|---:|---|
| IQ selected/cycle | +0.957 | 能否持续把工作送进执行端与最终吞吐高度一致 |
| 零退休周期 | -0.857 | 退休断流是低 IPC 的直接表现 |
| Backend Stall | -0.839 | 后端停顿具有广泛性 |
| IQ full dispatch stall | -0.600 | 队列服务率/容量是跨 workload 的重要限制 |
| 程序 2-bit predictor miss proxy | -0.600 | 难预测程序整体更慢，但有 suite/机制混杂 |
| 程序 D$ 32 KiB miss-ratio proxy | -0.559 | 数据局部性差的 case 整体更慢 |
| 程序理想 ILP64 | +0.503 | 程序存在可利用并行性时，当前 RTL 通常也更快 |
| CPI frontend proxy | -0.498 | 有关联，但该类含后端反压造成的 IBUF full |
| L1D load miss | -0.429 | miss 有影响，但不是唯一或全局第一原因 |
| 条件分支误预测率 | -0.361 | 对 mcf/gcc/xz 等重要，跨所有 FP/整数 case 后相关性被稀释 |
| IQ not-ready entry 数 | -0.007 | 原始数量受队列类型和 workload mix 强烈影响，不能单独作为全局瓶颈排名 |
| ROB full stall | +0.022 | 当前数据不支持 ROB 容量是全局限制 |

`iq_select_width_avg` 与 IPC 的强相关部分来自二者都描述实际吞吐，不能把它当作“提高 select 一定线性提高 IPC”的因果证明。它真正的用途是结合 queue full、ready-not-issued、producer 类型和 RF launch 判断工作停在何处。

程序侧 `ideal ILP64` 是在抽象依赖图和有限观察窗口中估计的可并行度，不包含 C910 的端口、IQ/ROB 容量、真实 cache 延迟、分支恢复和精确 forwarding。因此它回答“程序是否存在可挖掘的独立工作”，不能当作目标 IPC。理想 ILP 高而 RTL IPC 低说明可能存在硬件未利用的机会；理想 ILP 本身就低时，即使硬件完全正确，也不应期待靠增加发射宽度获得线性提升。

从结构上看，C910 每周期最多 dispatch 4 个 entry，具有 3 个退休 slot 和 8 条执行 pipe。但本报告的 IPC 来自 `minstret`：`ct_hpcp_top.v` 不是简单地对三个 slot 有效位求和，而是累加每个有效 slot 的 `hpcp_retire_inst*_num`。因此“3 个退休 slot”不等于 `minstret IPC` 的硬上限，不能把 IPC 除以 3 后称为退休带宽利用率。RF launch 平均宽度中位数为 1.935，也不能简单用 `1.935/8` 宣称执行单元利用率只有 24.2%，因为指令类型、端口映射、3-wide decode、分支清空和数据依赖决定了并非每周期都有 8 条可并行执行的指令。判断退休或执行宽度是否受限，必须使用 retire slot 分布、`inst_num` 分布、RF launch 分布和 ROB 阻塞事件，而不是只拿结构宽度做除法。

43 项 IPC 几何平均为 1.510；Rate 23 项和 Speed 20 项分别为 1.445、1.587，整数 20 项和浮点 23 项分别为 1.421、1.592。这些几何平均只用于本批 kernel 的回归基线，不是 SPEC 分数。浮点组整体几何平均不低，但其中存在 blender/nab/povray/namd 这一组严重 VIQ 受限的低吞吐簇，说明“FP 指令多”本身并不充分，真正决定性能的是 FP 操作类型、依赖距离、forward 覆盖和 pipe 服务率。

若只按当前互斥 CPI stack 选择每个 case 最大的非退休类别，43 项中有 22 项落入 frontend、19 项落入 backend-core、2 项落入 BadSpec，没有一项以 memory 为最大类别。表面看 frontend 略多，但第 4 节会表明其中大量周期由 IBUF full 触发；因此这个分布不能解释成“22 项取指受限”。更严谨的含义是：当前损失主要集中在取指到执行之间的供给/反压链和核心后端，只有 mcf r/s 明确由 BadSpec 成为最大类别，而在当前工作集下没有广泛的纯 memory-dominant case。

### 3.2 零退休是高频短气泡，不只是少量超长停顿

零退休周期中位数达到 48.34%，但 `zero_retire_episode` 平均长度中位数只有 1.894 cycles，P90 为 3.082 cycles。这个 episode 直接按 zero-retire 状态的开始和结束统计，是判断气泡长度的主要证据。`rob_head_block_latency` 中位数为 1.708 cycles，但它属于代表性单 active tracker，不是对每个 ROB entry 的完整追踪，只能作为辅助证据。综合来看，当前多数 workload 不是偶尔遇到一个极长事件，而是持续产生大量短气泡；结合分支、队列、producer、RF 和 LSU 事件，主要来源是分支清空、队列周期性填满、源未 ready、RF launch fail 和 replay 反复发生。

这决定了优化策略：只缩短极少数 >64 cycle 长尾不会自动解决主问题。更高价值的是降低事件发生频率、让 wakeup/select 连续工作、减少队列周期性灌满，以及减少每次错误推测造成的窗口破坏。

### 3.3 43 项核心结果

下表中的 BadSpec、FE、Memory 和 Backend 代理都是 CPI stack 对零退休周期的互斥归类，占总周期的百分比；它们与 Retiring、Idle/Unknown 一起构成 100%。`IQ阻塞` 和最强队列 full-update 则是原始事件，可以与 CPI stack 类别在同一周期重叠，不能和前几列直接相加。`FE代理` 不等于真正的取指饥饿，其定义和局限在第 4 节解释；`最强队列full-update` 用来说明具体由哪类 IQ 形成主要容量/服务率压力。

| Benchmark | IPC | 零退休% | BadSpec代理% | FE代理% | Memory代理% | Backend代理% | IQ阻塞% | 最强队列full-update |
|---|---:|---:|---:|---:|---:|---:|---:|---|
| `505.mcf_r` | 0.690 | 58.68 | 20.44 | 13.68 | 4.41 | 19.44 | 8.15 | LSIQ 6.88% |
| `531.deepsjeng_r` | 1.512 | 39.52 | 4.22 | 7.59 | 0.40 | 26.62 | 6.23 | AIQ0 4.17% |
| `548.exchange2_r` | 1.812 | 47.12 | 5.32 | 12.10 | 0.89 | 24.61 | 16.47 | AIQ0 12.17% |
| `502.gcc_r` | 1.425 | 51.21 | 8.29 | 19.18 | 0.28 | 23.12 | 29.52 | AIQ0 23.27% |
| `541.leela_r` | 1.090 | 57.85 | 8.24 | 9.27 | 1.94 | 38.09 | 8.33 | AIQ0 6.40% |
| `520.omnetpp_r` | 2.028 | 27.40 | 1.44 | 4.82 | 4.02 | 17.13 | 5.08 | AIQ0 4.35% |
| `500.perlbench_r` | 1.293 | 60.36 | 7.75 | 28.07 | 1.25 | 23.30 | 38.65 | AIQ0 28.49% |
| `525.x264_r` | 1.948 | 43.75 | 4.81 | 15.29 | 2.33 | 21.00 | 23.23 | AIQ0 19.95% |
| `523.xalancbmk_r` | 1.275 | 51.17 | 5.97 | 26.72 | 1.17 | 17.32 | 41.98 | AIQ0 36.18% |
| `557.xz_r` | 1.829 | 42.05 | 3.20 | 11.52 | 3.08 | 23.85 | 17.43 | AIQ0 13.94% |
| `510.parest_r` | 1.596 | 39.38 | 1.84 | 6.34 | 3.10 | 27.85 | 29.50 | LSIQ 25.15% |
| `526.blender_r` | 0.944 | 73.43 | 1.48 | 51.58 | 0.42 | 19.96 | 35.09 | VIQ0 24.31% |
| `503.bwaves_r` | 1.928 | 34.16 | 2.50 | 9.59 | 1.05 | 21.01 | 18.57 | AIQ0 10.12% |
| `507.cactuBSSN_r` | 1.673 | 48.02 | 3.30 | 24.78 | 1.83 | 17.74 | 19.77 | AIQ0 12.10% |
| `527.cam4_r` | 1.754 | 48.46 | 2.72 | 24.75 | 1.45 | 19.47 | 13.26 | AIQ0 8.02% |
| `549.fotonik3d_r` | 1.695 | 44.23 | 3.10 | 21.13 | 2.02 | 17.00 | 26.34 | AIQ0 24.73% |
| `538.imagick_r` | 1.802 | 45.25 | 3.04 | 19.20 | 1.50 | 21.28 | 8.46 | AIQ0 7.00% |
| `519.lbm_r` | 1.746 | 48.23 | 4.84 | 24.21 | 0.15 | 18.88 | 27.84 | AIQ0 20.98% |
| `544.nab_r` | 0.957 | 73.24 | 0.93 | 52.20 | 0.42 | 19.68 | 36.52 | VIQ0 23.89% |
| `508.namd_r` | 1.228 | 65.70 | 1.41 | 45.25 | 0.96 | 18.02 | 36.62 | VIQ0 15.21% |
| `511.povray_r` | 1.037 | 62.80 | 4.41 | 40.70 | 1.00 | 16.69 | 49.84 | VIQ0 25.17% |
| `554.roms_r` | 1.493 | 55.70 | 2.44 | 33.32 | 0.75 | 19.13 | 20.91 | VIQ0 7.73% |
| `521.wrf_r` | 1.649 | 50.33 | 4.72 | 24.67 | 0.75 | 20.15 | 13.65 | AIQ0 9.94% |
| `600.perlbench_s` | 1.271 | 58.99 | 10.65 | 19.48 | 1.87 | 26.98 | 30.27 | AIQ0 23.83% |
| `602.gcc_s` | 1.509 | 52.87 | 10.96 | 10.98 | 2.69 | 28.18 | 17.34 | AIQ0 14.59% |
| `605.mcf_s` | 0.710 | 57.76 | 20.29 | 13.70 | 4.01 | 18.96 | 8.58 | LSIQ 7.35% |
| `620.omnetpp_s` | 2.007 | 28.12 | 1.79 | 5.59 | 0.70 | 20.04 | 5.07 | AIQ0 4.33% |
| `623.xalancbmk_s` | 1.348 | 49.48 | 4.08 | 29.95 | 1.34 | 14.11 | 43.15 | AIQ0 36.83% |
| `625.x264_s` | 2.294 | 45.38 | 6.41 | 12.61 | 3.03 | 23.02 | 7.49 | AIQ0 6.43% |
| `631.deepsjeng_s` | 1.318 | 62.18 | 5.63 | 32.33 | 0.79 | 23.43 | 45.11 | AIQ0 34.68% |
| `641.leela_s` | 1.472 | 55.53 | 4.56 | 27.65 | 1.11 | 22.20 | 38.79 | AIQ0 29.07% |
| `648.exchange2_s` | 1.397 | 61.23 | 5.72 | 30.86 | 0.85 | 23.79 | 43.26 | AIQ0 33.88% |
| `657.xz_s` | 1.397 | 54.30 | 9.30 | 16.75 | 2.34 | 25.89 | 24.78 | AIQ0 20.87% |
| `603.bwaves_s` | 2.110 | 45.75 | 4.73 | 16.71 | 2.98 | 21.14 | 6.23 | AIQ0 5.37% |
| `607.cactuBSSN_s` | 1.906 | 46.03 | 2.58 | 19.69 | 2.54 | 21.12 | 10.36 | AIQ0 5.89% |
| `619.lbm_s` | 1.770 | 47.23 | 1.60 | 22.87 | 3.03 | 19.18 | 5.53 | AIQ0 4.72% |
| `621.wrf_s` | 1.775 | 47.20 | 1.91 | 21.77 | 2.56 | 20.52 | 7.59 | AIQ0 5.47% |
| `627.cam4_s` | 1.773 | 48.34 | 2.67 | 17.77 | 1.02 | 26.84 | 17.66 | AIQ0 9.11% |
| `638.imagick_s` | 1.839 | 46.24 | 3.91 | 21.66 | 1.27 | 19.41 | 13.90 | AIQ0 11.71% |
| `644.nab_s` | 1.087 | 68.65 | 1.11 | 47.48 | 0.58 | 19.48 | 33.74 | VIQ0 21.17% |
| `649.fotonik3d_s` | 2.099 | 46.22 | 4.71 | 16.23 | 2.51 | 22.57 | 9.60 | AIQ0 6.38% |
| `654.roms_s` | 1.926 | 46.04 | 2.92 | 20.27 | 3.01 | 19.74 | 7.71 | AIQ0 5.77% |
| `628.pop2_s` | 1.777 | 46.54 | 2.72 | 21.18 | 2.10 | 20.53 | 6.07 | AIQ0 4.31% |

## 4. 必须先修正的前端解释

### 4.1 当前 CPI stack 的真实优先级

`tb.v` 中 `cpi_stack_class()` 先把所有“当周期至少退休一项”的周期归为 retiring；只有零退休周期才继续按原因分类。完整优先级为：

1. `retiring`：当周期只要退休至少一条指令，整周期归入 retiring。
2. `bad_spec`：全核/前端 flush、分支 mispredict stall，或 `rtu_lsu_spec_fail_flush`；它不直接包含所有 `lsu_spec_fail_deep` 原始事件。
3. `frontend`：`if_frontend_stall`、IBUF full、PCFIFO full、I-cache refill/reissue 等任一成立。
4. `memory`：LSU cross、D-cache/MMU stall、LQ/SQ/RB/LFB/WMB full、BIU backpressure。
5. `backend_core`：ID/IR stall、ROB/PREG、IQ full、RF source no-ready、乘除法 stall。
6. `idle_unknown`。

因此这不是传统 Top-down 方法中的纯 `Frontend Bound`。尤其是 `IBUF full` 表示前端已有指令但下游接不走，本质是 backpressure，不是 fetch starvation。由于 `frontend` 的优先级高于 memory 和 backend，同周期同时存在 IBUF full 和 IQ full 时，周期会被分到 frontend，造成 frontend 高估、backend/memory 低估。

### 4.2 最新数据表明大部分不是 I-cache 问题

| 指标 | 43 项中位数 | 最大值 |
|---|---:|---:|
| L1I miss | 0.01% | 0.01% |
| I-cache refill busy | 0.294% | 2.312% |
| IBUF full | 38.60% | 69.56% |
| IBUF 平均占用 | 高压力 FP case 为 22.6 至 24.9 entries | 24.9 entries |

真正的前端断供与后端反压应呈现相反的指标签名。前端断供时，IBUF 应经常空或低占用，I-cache/TLB/refill 或 redirect recovery 活跃，下游 IQ 因得不到新指令而占用下降；后端反压时，IBUF 应高占用或 full，同时某个下游 IQ 高占用、not-ready 或 full。当前数据明显更接近第二种模式：IBUF full 比 refill busy 高两个数量级，并且高值集中在 VIQ/AIQ 同时积压的 case。这个“上下游同时积压”的方向性证据比 `frontend stall` 单个百分比更有解释力。

`544.nab_r` 的 CPI frontend proxy 为 52.20%，但 IBUF full 为 69.56%、IBUF 平均占用 24.89，I-cache refill busy 只有 0.164%。`526.blender_r`、`508.namd_r`、`511.povray_r` 呈现同样模式。这些数字说明前端并不缺指令，而是后端 FP/VIQ 路径处理不完，导致 IBUF 长期满。

因此当前不应优先扩大 I-cache 或增加取指带宽。第一步应该把计数器拆成：

- `frontend_starved`：IBUF empty、fetch invalid、I-cache/TLB/refill 阻塞。
- `frontend_backpressured`：IBUF full、PCFIFO full、ID/IR 不接收。
- `redirect_recovery`：mispred/flush 后到 fetch/ID 恢复。
- `backend_queue_blocked`：具体 AIQ/BIQ/LSIQ/SDIQ/VIQ full。

只有 `frontend_starved` 持续较高时，才有数据依据研究 I-cache、BTB 供给和 fetch width。

## 5. 第一主线：队列服务率与定向容量压力

### 5.1 为什么这是跨 workload 的主问题

`is_iq_full_stall` 表示 dispatch 因某个 issue queue 无法接收目标指令而受阻。RTL 中 `ctrl_is_*_full_updt` 不是“队列只要处于 full 就计数”，而是将对应 create 请求与 `full_updt/1_left_updt` 相与：只有本周期确实需要向该队列分配一项或两项、但剩余 entry 不足时才成立。因此它直接反映了容量状态对当前 dispatch 需求造成的接收失败，比单纯 full 状态更接近性能影响。其 43 项中位数为 17.66%，并且与 IPC 呈 -0.600 的秩相关。

RTL 中 AIQ0、AIQ1、VIQ0、VIQ1 各有 8 个 entry，BIQ、LSIQ、SDIQ 各有 12 个 entry；这些是独立队列，不能把容量相加后解释某个具体队列的 full。进一步按队列拆分：

| 队列事件 | RTL 深度 | 中位数 | 最大值 | 最大值 case |
|---|---:|---:|---:|---|
| AIQ0 full-update | 8 | 8.02% | 36.83% | `623.xalancbmk_s` |
| AIQ1 full-update | 8 | 1.69% | 16.90% | `631.deepsjeng_s` |
| BIQ full-update | 12 | 0 | 0.31% | `505.mcf_r` |
| LSIQ full-update | 12 | 0 | 25.15% | `510.parest_r` |
| SDIQ full-update | 12 | 0 | 0.70% | `548.exchange2_r` |
| VIQ0 full-update | 8 | 0.005% | 25.17% | `511.povray_r` |
| VIQ1 full-update | 8 | 0.010% | 17.10% | `511.povray_r` |

这说明压力会随 workload 类型落到不同队列，而不是“所有队列统一偏小”；究竟是局部容量还是服务率，要继续用 not-ready、ready-not-issued 和 occupancy 区分。程序动态特征和 RTL queue 指标之间存在很强的机制一致性：

| 程序需求与 RTL 响应 | Spearman rho |
|---|---:|
| FP 指令比例 vs VIQ0 not-ready | +0.960 |
| FP 指令比例 vs VIQ1 not-ready | +0.961 |
| 访存指令比例 vs LSIQ not-ready | +0.782 |
| 控制流比例 vs BIQ not-ready | +0.773 |
| 整数比例 vs AIQ1 not-ready | +0.628 |
| 整数比例 vs AIQ0 not-ready | +0.559 |

这组关系说明动态特征统计和 RTL 探针至少在机制方向上相互支持，也说明不能用一个全局 IQ 数字解释所有 workload。

`iq_nonload_dep_not_ready_avg` 与 IPC 的全局 rho 只有 -0.114，并不意味着该指标无用。它按源操作数计数，同一 entry 可以贡献多个源，而且 non-load 同时包含 ALU、MUL/DIV、VFPU、CSR、特殊 producer 和无法匹配的 producer。它适合在同类队列、同类 workload 内判断依赖来源，例如比较 FP 簇的 VIQ，不能把 AIQ、VIQ、LSIQ 的原始数值混在一起做全局瓶颈排名。

### 5.2 full 不自动等于应该扩容

队列满可能由两类原因产生：

1. **容量不足**：consumer 可以正常 ready/issue，但突发并行工作超过 entry 数。
2. **服务率不足**：producer 太晚、wakeup 保守、select/端口冲突或执行单元吞吐低，entry 长时间出不去，最终把队列填满。

直接扩大队列只能缓冲第二类问题，不能消除根因，还可能增加 select 延迟、面积和时序压力。应先比较：

- 每队列 `occ_avg` 和 occupancy histogram。
- `not_ready_avg` 与 producer class。
- `ready_not_issued_avg` 与 `issue_select_avg`。
- oldest ready/not-ready entry age。
- RF launch fail、功能单元 busy 和 forward hit/miss。

当前 43 项中 IQ ready entry 的平均值中位数为 2.170，selected 中位数为 1.756；先对每个 case 计算 `selected/ready` 后再取中位数，结果约为 0.84。这里不能直接用两个中位数相除，因为中位数一般不满足比值运算。case 间差异很大：`502.gcc_r`、`557.xz_r`、`548.exchange2_r` 的 selected/ready 只有 0.590、0.606、0.610，说明它们有明显 ready 后竞争；`bench_ilp` 则 ready-not-issued 只有 0.007/cycle，主要是指令长期未 ready，不属于同一问题。

### 5.3 整数 AIQ 路径

AIQ0/AIQ1 压力不能只看 full。下面把 8-entry 队列的平均占用、未就绪 entry、非 load 源等待和 ready 后未发射同时列出。`非load源等待` 按源操作数累计，一条 entry 可以贡献多个未就绪源，所以数值可以大于队列 entry 数。

| Case | IPC | AIQ0/1占用 | AIQ0/1未就绪 | 非load源等待/cycle | Ready未发射/cycle | AIQ0/1 full-update |
|---|---:|---:|---:|---:|---:|---:|
| `502.gcc_r` | 1.425 | 5.42 / 4.91 | 4.04 / 3.83 | 9.20 | 1.135 | 23.27% / 7.38% |
| `523.xalancbmk_r` | 1.275 | 6.17 / 5.18 | 5.25 / 4.47 | 12.94 | 0.544 | 36.18% / 8.04% |
| `631.deepsjeng_s` | 1.318 | 6.26 / 5.72 | 5.40 / 4.90 | 13.03 | 0.551 | 34.68% / 16.90% |
| `648.exchange2_s` | 1.397 | 6.08 / 5.48 | 5.25 / 4.67 | 12.88 | 0.525 | 33.88% / 15.33% |
| `bench_ilp` | 0.770 | 7.22 / 4.63 | 6.89 / 4.29 | 18.69 | 0.007 | 64.25% / 0.02% |

这组数据可以把整数压力进一步拆成两个子类型。

`bench_ilp` 是最清楚的 not-ready 型证据：它的 ROI 同时包含串行乘加链和 8 路独立累加两段代码，不能称为纯依赖链；但聚合结果明显由前一类压力主导。AIQ0 平均占用 7.22/8，其中 6.89 项未 ready；AIQ0 full-update 达 64.25%，但 ready-not-issued 只有 0.007/cycle，而且没有 load dependency。也就是说，队列几乎被等待 non-load producer 的指令占满，并不是有大量 ready 指令输给 select 后被拒绝。直接扩容会延后 full 的发生，却不会缩短 producer-consumer 链。正式优化实验前应把两段拆成独立 ROI，分别检查整数乘法结果延迟、ALU/MLA wakeup 提前量、forward 条件和独立指令的队列吞吐。

`502.gcc_r` 则是混合型：AIQ 中同样有大量 non-load not-ready entry，但 ready-not-issued 达 1.135/cycle，selected/ready 只有 0.590。它不仅在等 producer，也存在 ready 后的仲裁或执行端口竞争。因此 gcc 更适合验证 select policy、pipe0/pipe1 映射和多类指令端口冲突；如果只改善 wakeup，ready-not-issued 还可能进一步上升。

xalancbmk、deepsjeng_s 和 exchange2_s 位于两者之间：两个 AIQ 都保持约 5 至 6 项平均占用，大部分 entry 未 ready，同时每周期仍有约 0.5 项 ready 后未发射。它们支持“producer/wakeup 为基础压力，select/端口为次级压力”的判断，但还不能区分 producer latency 与 wakeup 实现。值得注意的是，AIQ 的 load-dependency 分量在这些 case 中只有约 0.02 至 0.09/cycle，而 non-load 分量为约 5 至 13/cycle，整数压力不能归因于 D-cache load-use。

由此，整数路径的实验顺序应是：先抓取 non-load producer 的具体类别和 producer-consumer PC，再分别测试 wakeup/forward 与 select/port mapping，最后才做 AIQ entry sweep。只有在 producer 和端口服务率改善后，队列仍高占用、oldest ready age 上升且扩容能独立提升 IPC，才能确认真实容量不足。

## 6. 第二主线：FP/VIQ 与执行流水线

### 6.1 低 IPC FP 簇

| Case | FP 动态指令% | IPC | 零退休% | VIQ0/VIQ1未就绪平均项数 | VIQ0/VIQ1 full-update | RF launch 平均宽度 |
|---|---:|---:|---:|---:|---:|---:|
| `526.blender_r` | 51.53 | 0.944 | 73.43 | 5.386 / 4.937 | 24.31% / 13.22% | 1.029 |
| `544.nab_r` | 51.82 | 0.957 | 73.24 | 5.525 / 5.036 | 23.89% / 12.81% | 1.033 |
| `644.nab_s` | 40.64 | 1.087 | 68.65 | 4.914 / 4.489 | 21.17% / 11.52% | 1.209 |
| `511.povray_r` | 38.08 | 1.037 | 62.80 | 5.152 / 5.065 | 25.17% / 17.10% | 1.238 |
| `508.namd_r` | 37.91 | 1.228 | 65.70 | 4.748 / 4.284 | 15.21% / 8.29% | 1.342 |

理解 VIQ 指标需要先理解 FP 依赖的时序。consumer 进入 VIQ 后，只有所有源都 ready 才能参与 select；producer 的结果可以在执行后经 forwarding 提前唤醒，也可以等到更晚的 writeback 才可见。若 forwarding 覆盖不完整、wakeup 发生过晚或某类 FP 操作本身延迟长，consumer 会长期占着 VIQ entry。这样即使 pipe6/pipe7 某些周期空闲，队列也可能没有 ready 指令可发，最终表现为“执行端看似没跑满，但 VIQ 反而满”。所以应先看 not-ready，再看 ready-not-issued，最后才看 pipe 利用率。

这些 case 同时满足：VIQ not-ready 高、VIQ full 高、RF launch 宽度低、零退休高，而 L1I miss 和 CPI memory 都很低。进一步检查 entry 级平均值后，低吞吐簇的 VIQ0/VIQ1 平均占用约为 5.02 至 5.83、4.53 至 5.31 项，其中约 94% 至 96% 的 entry 未 ready；每个 VIQ 的 ready-not-issued 只有约 0.02 至 0.04/cycle。这排除了“VIQ 中已有大量 ready 指令，但 select 仲裁发不出去”作为第一原因，压力在 select 之前就已经形成。

source 分类给出了更强证据。blender、nab、povray、namd 的 VIQ load-dependency 未就绪分量仅为 0.040 至 0.125/cycle，而 non-load source 未就绪分量达到 5.889 至 7.748/cycle。后者按源操作数统计，可以大于 entry 数，但两者相差两个数量级，说明这些 VIQ entry 主要在等待 FP/VFPU 或其他非 load producer，而不是等待 D-cache load 返回。结合 RF launch 平均宽度只有 1.029 至 1.342，当前最有依据的根因范围是 FP producer-consumer latency、forward/wakeup 覆盖和 pipe6/pipe7 服务率；现有计数器还不足以在这三者中选出唯一根因。

`627.cam4_s`、`607.cactuBSSN_s`、`649.fotonik3d_s` 也有较高 FP 比例，但 IPC 达 1.773、1.906、2.099，VIQ full-update 只有约 1% 至 2.5%，RF launch 平均宽度达到 2.041、2.121、2.292。它们的 VIQ 占用和 non-load source 等待总体低于低吞吐簇，尤其 fotonik3d_s 的 VIQ0/1 占用只有 3.08/2.90，明显不是“只要 FP 比例高就必然填满 VIQ”。程序特征侧也显示，低吞吐 FP 簇的理想 ILP64 约为 5.64 至 7.87，而 cactuBSSN_s、cam4_s、fotonik3d_s 为 10.26 至 11.28；因此一部分差距来自程序依赖结构，一部分来自硬件处理这些依赖的效率。它们可作为负对照，比较为何相似 FP 密度下 VIQ entry 能更快释放。应重点比较：

1. FMA/乘加依赖链长度和 producer-consumer 距离。
2. pipe6/pipe7 分配是否均衡。
3. ex3/ex4/ex5 forward 命中与无 forward 情况。
4. FDSU/divide 长延迟是否阻塞普通 FP 工作。
5. VIQ oldest entry 等待的具体 source bit 和 producer class。

### 6.2 不能只扩大 VIQ

如果 VFPU producer 延迟或 forwarding 是根因，扩大 VIQ 只会容纳更多 not-ready entry。正确的实验顺序是：

1. 先记录 VIQ entry create、source-ready、select、RF launch、writeback/flush 的生命周期。
2. 按 producer 分类为 pipe6、pipe7、FDSU、load/vload 和未知来源。
3. 对 pipe6/pipe7 port mapping、wakeup 提前量和 forward 条件做单变量修改。
4. 最后做 VIQ entry 数参数 sweep，判断容量是否有独立收益。

若优化有效，应同时看到 VIQ non-load source not-ready、VIQ occupancy/full-update 下降，RF launch 0 周期下降，RF launch 平均宽度和 VIQ issue select 上升，最终零退休下降且 IPC 上升。若只增加 VIQ entry，预期首先看到 full-update 下降而 not-ready 总量和 RF launch 基本不变；这种结果说明扩容只是容纳了更多等待项。若修改 forwarding 后 non-load not-ready 和零退休下降但 VIQ full 降幅较小，则说明服务率改善有效，容量不是第一约束。这里给出了可证伪的不同计数器签名，而不是只以 IPC 单点判断。

## 7. 第三主线：分支预测与错误路径恢复

### 7.1 mcf 是最高优先级分支 case

| Case | 控制流% | 条件误预测率 | BHT MPKI | IFU target misp% | BadSpec代理% | IPC |
|---|---:|---:|---:|---:|---:|---:|
| `505.mcf_r` | 25.39 | 17.30% | 43.18 | 9.59% | 20.44% | 0.690 |
| `605.mcf_s` | 24.53 | 17.38% | 41.83 | 8.24% | 20.29% | 0.710 |
| `602.gcc_s` | 8.57 | 16.60% | 12.58 | 0.45% | 10.96% | 1.509 |
| `657.xz_s` | 8.46 | 15.79% | 11.88 | 0.45% | 9.30% | 1.397 |
| `600.perlbench_s` | 10.86 | 12.79% | 12.92 | 0.07% | 10.65% | 1.271 |
| `541.leela_r` | 25.48 | 10.47% | 24.44 | 0.36% | 8.24% | 1.090 |

分支损失通常可粗略写成 `CPI_branch ≈ mispredicts/instruction × exposed penalty`。其中误预测率回答“预测器面对分支时错多少”，MPKI 回答“每执行一千条程序指令实际错多少次”，后者同时包含分支频率，因此更适合估算总性能损失。`exposed penalty` 也不是固定流水级数：错误路径上可能与其他工作重叠，恢复期间还可能被 CPI stack 的其他优先级重新分类。

这里存在一条完整的跨层证据链。程序特征显示 mcf 的控制流比例约 25%，且 2-bit predictor miss proxy 高；RTL 实测条件误预测率约 17.3%，BHT 错误达到约 42 至 43 MPKI；`global_flush_zero_retire` 又达到约 42.6 至 43.9/KI，几乎与 BHT MPKI 一一对应；最终约 20.3% 至 20.4% 周期被 CPI stack 归入 BadSpec，IPC 落到全体最低的 0.69 至 0.71。跨 43 项看，条件误预测率与 CPI BadSpec 的 Spearman rho 为 +0.885，程序侧 2-bit miss proxy、分支熵与 RTL 条件误预测率的 rho 分别为 +0.581、+0.517。这些证据共同支持 mcf 的第一瓶颈是方向预测错误，而不只是“mcf 分支很多”。

以 `505.mcf_r` 为例，IPC 0.690 对应总 CPI 约 1.449；BadSpec 占 20.44% 周期，因此实测可见的 BadSpec 分量约为 `1.449 × 20.44% = 0.296 CPI`，也就是每千指令约 296 个周期。若直接用 43.18 MPKI 乘以代表性 `mispred_to_retire≈8.4 cycles`，会得到约 0.363 CPI，高于实测分类值。这一差异说明 latency tracker 不是所有误预测的精确平均惩罚，且恢复与其他事件存在重叠，教学上不能把“MPKI × 某个单窗口 latency”当作精确 CPI 分解。

可以用 CPI stack 做一个受限的收益上界估算：假设 `505.mcf_r` 的全部 BadSpec 周期都能消失且不被其他瓶颈替代，IPC 上界约为 `0.690/(1-0.2044)=0.867`，相对提升约 25.7%；`605.mcf_s` 对应约 0.891，提升约 25.5%。这是乐观上界而不是预测结果，因为消除错误路径后队列、memory 和 frontend 分类会重新分布，但它说明分支优化具有足够大的收益空间，值得排在 LSIQ 扩容之前。

mcf 的分支频率和每千指令错误次数都高，优化优先级应先放在错误频率而不是单次恢复延迟。当前 `mispred_to_retire` 中位数约 8.8 cycles，mcf 为约 8.4 cycles；但 latency 计数器是代表性单 active 窗口，不是每个分支完整追踪。若只把恢复缩短 1 cycle，而 43 MPKI 的错误频率不变，收益会受到频率上限约束；先降低热点 PC 的重复误判，再评估 flush-to-fetch/ID 恢复，逻辑更稳健。

### 7.2 raw misprediction rate 不能脱离 MPKI

`644.nab_s`、`619.lbm_s` 等 case 的间接分支误预测率可达 16% 至 20%，但间接分支动态数量很少，其 BadSpec 只有约 1%。因此 predictor 评估必须同时看：

- 该类分支占退休指令的比例。
- 每千指令误预测次数。
- 触发的 global flush 次数。
- BadSpec 和零退休损失。

只按“误预测率最高”排序会把低频间接分支错误误判为主要瓶颈。

### 7.3 分支技术路线

分支预测失败需要先按机制分类。BHT/PHT 主要预测条件分支 taken/not-taken 方向；BTB 提供直接跳转或已见分支的目标地址；间接预测器处理目标随运行状态变化的跳转；RAS 用调用栈预测 return 目标。方向正确但 BTB 没有目标仍会重定向，return 错误也不能靠扩大 BHT 修复，因此所有错误不能只汇总成一个 branch-miss rate。

应先把现有误预测拆成 direction、BTB/target、indirect 和 RAS 四类，并记录 top PC。针对 mcf/gcc/xz/perlbench 的可能升级包括：

1. 检查 PHT/BHT alias，即不同静态分支映射到同一预测项造成的互相污染；增加 index/tag 或改进历史折叠。
2. 对高熵热点比较更长全局历史、局部历史和混合预测。
3. 检查 update 延迟，避免同一热点在更新生效前重复误判。
4. 对 mcf 的 target misp 单独检查 BTB 容量、冲突和目标生成。
5. 在预测频率下降后，再研究 flush 到 fetch/ID 的恢复流水线和前端重填。

每次改动必须同时检查 BHT MPKI、target/indirect MPKI、global flush MPKI、BadSpec、零退休和 IPC，避免通过一种预测器改善方向错误却恶化 BTB 或时序。

## 8. 第四主线：LSU、LSIQ 与存储层次

### 8.1 当前不是全局 cache-miss 主导

43 项 L1D load miss 中位数为 2.79%，CPI memory proxy 中位数为 1.45%，没有任何 case 以 memory proxy 作为最大的非退休类别。程序 D$ 32 KiB 全相联 miss-ratio proxy 与 RTL L1D load miss 的 rho 为 +0.837，说明特征统计能正确区分局部性；但 L1D miss 与 CPI memory proxy 的相关性并不稳定，因为：

1. CPI stack 的 frontend 优先级会把与 IBUF full 重叠的 memory 周期提前分类。
2. miss rate 只表示事件频率，不表示 MLP、单次延迟和是否落在关键路径。
3. 当前 composite ROI 的工作集远小于完整 SPEC ref，不能覆盖真实 L2/DRAM 行为。

存储性能不能只看 miss rate。粗略关系是 `memory CPI ≈ misses/instruction × exposed miss penalty`，而 exposed penalty 取决于命中层级、乱序窗口能否找到独立工作、同时在途 miss 数量、load 是否位于关键依赖链，以及预取和 store forwarding。MLP（memory-level parallelism）表示多个未命中能否并行在途；两个程序即使 L1D miss rate 相同，也可能因为 MLP 不同而有完全不同的 CPI。反过来，cache 全部命中也不保证 LSU 无阻塞：地址 producer 未 ready、LSIQ/SDIQ entry 长期占用、store-load 依赖推测失败和 replay 都可以在没有 cache miss 的情况下制造气泡。

因此当前结论不是“内存不重要”，而是“当前 43 个约 0.5M 指令 composite 中，cache miss 不是跨 workload 的第一瓶颈”。

### 8.2 mcf、parest 与 bwaves 的 LSIQ 压力

| Case | IPC | 程序访存% | L1D load miss | CPI Memory代理% | LSIQ full-update | 判断 |
|---|---:|---:|---:|---:|---:|---|
| `505.mcf_r` | 0.690 | 44.72 | 4.97% | 4.41% | 6.88% | branch 主导，同时存在 pointer/LSIQ/miss 压力 |
| `605.mcf_s` | 0.710 | 45.41 | 4.58% | 4.01% | 7.35% | 与 Rate 结果复现 |
| `510.parest_r` | 1.596 | 32.01 | 0.28% | 3.10% | 25.15% | 更像 LSIQ 服务率/地址依赖，不是 cache capacity |
| `503.bwaves_r` | 1.928 | 28.81 | 1.77% | 1.05% | 7.39% | 有 LSIQ 压力但总体吞吐较高，可作对照 |

`510.parest_r` 是区分“cache miss”和“LSIQ service”的关键 case：实际 L1D load miss 只有 0.28%，但 LSIQ full-update 高达 25.15%。应检查 load 地址 producer、LSIQ wakeup/select、AG 端口和 load pipeline 接收能力，而不是扩大 cache。

更细的 LSIQ 数据把范围继续缩小。parest 的 12-entry LSIQ 平均占用为 6.902，其中 6.216 项未 ready；ready-not-issued 为 0，`src1_not_ready` 为 1.173/cycle，load-dependency 分量仅 0.005/cycle，而 non-load dependency 为 1.272/cycle。由此可见，parest 的 ready load 并没有卡在 LSIQ select，L1D miss 也不是原因；队列是被尚未完成地址相关整数源或其他发射条件的 load 占住。下一步应追踪 src1 的 producer PC、整数 wakeup 和地址生成入口，只有这些改善后 full 仍存在，才测试增加 LSIQ entry。

mcf_r 的 LSIQ 平均占用/未就绪为 4.854/4.170，ready-not-issued 同样为 0，src0 等待为 0.504/cycle；bwaves_r 为 4.800/4.221。它们也更像地址 producer/依赖造成的服务率问题，而不是 ready load 的仲裁问题。不过 mcf 有大量错误路径，因此必须先降低 branch flush，再重新测真实路径上的 LSIQ 占用，否则可能把错误路径访存产生的瞬态压力当作 LSU 容量需求。

### 8.3 Dhrystone 和 memory microbench 提供不同 LSU 证据

store 路径需要分别处理地址和待写数据，两者可能由不同 producer 在不同时间 ready。LSIQ/地址执行路径负责形成或调度访存地址，SDIQ 跟踪 store data 及其与地址状态的配合；memory dependence speculation 还会在地址完全解析前猜测 load/store 是否可以越过。因而 `src0_no_rdy`、`staddr_no_rdy`、SQ cancel 和 spec fail 虽然都属于 LSU，却代表因果链上的不同位置，不能合并成一个“访存停顿率”。

| Case | IPC | L1D miss | CPI Memory代理% | WB deep spec/KI | 实际 LSU flush/KI | SQ cancel/cycle | pipe5 关键等待 |
|---|---:|---:|---:|---:|---:|---:|---|
| `dhrystone` | 1.887 | 0 | 4.54% | 100.883 | 4.860 | 0.328 | staddr 43.466/KI |
| `bench_mem` | 0.982 | 0.12% | 4.23% | 25.924 | 20.415 | 0.287 | src0 26.572/KI |
| `bench_cache_stride` | 1.232 | 0.11% | 5.07% | 0 | 0 | 0 | staddr 42.239/KI |

`WB deep spec/KI` 是原始 spec-fail 信号有效周期数按退休指令归一化，不是去重后的失败 transaction 数；同一次内部状态若持续多个周期会重复累计。`实际 LSU flush/KI` 来自送入恢复路径的 flush 事件，更接近全核可见代价。`SQ cancel/cycle` 又是两个 cancel 条件的宽度和平均值，表示取消活动强度。三者单位和统计对象不同，只能按事件传播顺序联合解释，不能直接比较数值大小。

这些数据还形成了三条不同的 LSU 阻塞链。

Dhrystone 的 LSIQ full-update 为 7.29%，LSIQ 平均占用/未就绪为 5.746/4.916；SDIQ 平均有 1.913 项等待 staddr，`rf_pipe5_staddr_no_rdy` 为 43.466/KI，同时 SQ cancel 达 0.328/cycle。这里必须区分两级信号：`lsu_spec_fail_deep` 是 `ld_da_wb_spec_fail || st_da_wb_spec_fail` 的原始周期事件，达到 100.883/KI；真正送到全核恢复路径的 `lsu_spec_fail_flush` 只有 4.860/KI，CPI BadSpec 也只有 1.044%。因此数据能够确认 store-address/SQ 路径内部活动异常，并支持“地址就绪较晚 → SQ 取消或内部 spec-fail 增加”的候选链，但尚不能证明 100.883/KI 都变成了可见流水线损失。Dhrystone 的 LSU 优化应同时要求 deep 活动、实际 flush、CPI memory/BadSpec 和 IPC 按预期变化。

bench_mem 的症状不同：LSIQ full-update 为 10.01%，LSIQ 未就绪为 4.988 项，SDIQ `src0_not_ready` 为 1.742/cycle，`rf_pipe5_src0_no_rdy` 为 26.572/KI，而 staddr no-ready 只有 0.486/KI。它的 deep spec-fail 为 25.924/KI，实际 LSU flush 却达到 20.415/KI，说明失败事件更大比例进入了恢复路径。它优先暴露地址基址 producer/wakeup 及其后续 speculation，不能和 Dhrystone 的 staddr/SQ 活动简单合并。bench_cache_stride 又是这条 LSU 链的局部负对照：虽然 staddr no-ready 为 42.239/KI，但 LSIQ/SDIQ full、deep spec-fail、LSU flush 和 SQ cancel 都为 0，说明单个 staddr 等待事件不必然造成 speculation failure；必须观察后续事件链是否成立。它并不是全局“健康”对照，因为自身 BHT mispredict 达 39.09 MPKI、BadSpec 达 15.00%，所以这里只用它排除 staddr 到 LSU spec-fail 的必然关系，不能直接拿总 IPC 与 Dhrystone 比较。

因此 LSU 优化必须分开：

- Dhrystone 优先查 store-address ready、SDIQ staddr 条件、SQ forwarding/cancel 和 memory dependence predictor。
- bench_mem 优先查地址 src0 的 producer PC、wakeup 和 AG 输入路径。
- bench_cache_stride 用于验证 cross-boundary/alignment 路径，不应用来验证 SQ speculation。

### 8.4 大工作集研究需要独立路线

BIU AR-to-R 平均延迟在部分 case 中很高，例如 `621.wrf_s=110.7 cycles`、`508.namd_r=101.7 cycles`，但它与 IPC 的全局 rho 只有 -0.100，并且 latency tracker 是代表性单 active 窗口。当前数据只能说明外部读路径存在长延迟样本，不能据此估计真实 ref 输入的内存墙。

为了控制 RTL 时间，建议只为 `mcf`、`parest`、`bwaves`、`wrf` 选择 1 至 5M 指令的大 footprint 版本，或完成 checkpoint/restore 后运行真实代表区间。没有必要让全部 43 项都进入超长内存仿真。当前 0.5M Full kernel 继续负责核心流水线回归，大工作集子集负责 L2/BIU/MLP 研究。

## 9. ROB、物理寄存器与退休端的排除性结论

### 9.1 ROB 容量证据不足

ROB 的作用是保存未退休指令并维持精确异常。更大的 ROB 只有在前端能持续 dispatch、后端能够容纳更多独立指令，而且现有窗口经常因为 full 阻止继续探索未来 ILP 时才会提升性能。如果指令已经在小型 IQ 中等待 producer，或者分支频繁清空窗口，ROB 根本填不起来；此时扩大 ROB 不会让关键 producer 更早完成。

| 指标 | 中位数 | 最大值 |
|---|---:|---:|
| `is_rob_full_stall` | 0 | 0.417% |
| `rtu_rob_full` | 0 | 0.655% |
| `rob_occ_ge32` | 0.001% | 0.293% |
| `rob_occ_ge64` | 0 | 0 |

当前工作负载在 IQ 或执行路径已经受阻，没有把 ROB 长期填满。直接扩大 ROB 很可能增加面积、功耗和时序复杂度，却不改善 producer、select、VIQ 或 branch 问题。只有在这些前置瓶颈改善后 ROB full 明显上升，才应重新评估窗口深度。

### 9.2 `ir_preg_not_vld` 不是 free-list 耗尽证明

物理寄存器用于保存重命名后的版本。真正的容量不足应沿着“free-list 可用项下降 -> rename allocation block -> dispatch stall”出现，而不是只看某个中间 valid 信号。`ir_preg_not_vld` 的名字容易被理解成“没有物理寄存器”，但它还受 IR 有效、控制清空和分配请求本身影响，因此必须用实际 alloc-block 信号确认。

`ir_preg_not_vld` 中位数为 1.362%，mcf 达约 13%，但：

- `preg_alloc0..3_block` 在 43 项中全部为 0。
- `preg_alloc_block_avg` 全部为 0。
- `pst_alloc_block_episode` 全部为 0。
- `preg_alloc_avail_avg` 中位数为 3.978，最大分配宽度为 4。

这说明 `ir_preg_not_vld` 更可能反映 IR 当周期没有有效分配结果或受其他控制条件影响，不能直接归因为物理寄存器数量不足。当前不应优先扩大 PREG/FREG free list。

## 10. CoreMark、Dhrystone 与机制 microbench 的作用

SPEC composite 提供应用相关性，但一个 SPEC case 往往同时包含分支、依赖、访存和执行端口压力，单靠它很难证明因果。机制 microbench 的作用是主动压低无关变量：bench_ilp 几乎去掉 cache 影响，bench_frontend 把控制流压力放大，bench_mem 和 cache_stride 则构造不同 LSU 路径。负对照承担相反角色，它与目标 case 保持某个表面特征相似，但不出现目标性能问题。只有“目标 case 改善、对应直接事件下降、负对照稳定”同时成立，才能把一次 IPC 变化解释成机制优化，而不是代码布局或其他耦合。

### 10.1 CoreMark 与 Dhrystone

当前正式结果为：

| Benchmark | 成绩 | IPC | 零退休% | IQ full% | BHT MPKI | 主要解释 |
|---|---:|---:|---:|---:|---:|---|
| CoreMark 30 次 | 6.677975 CoreMark/MHz | 1.544 | 36.12 | 22.21 | 7.17 | AIQ/整数依赖、ready/select 和 branch 混合 |
| Dhrystone 1000 次 | 5.187 DMIPS/MHz | 1.887 | 28.81 | 8.20 | 0.082 | LSU store-address/SQ 内部活动突出，实际 flush 较少，不是 branch/cache |

CoreMark 程序特征为约 50.5% 整数、27.8% 访存、21.7% 控制流，适合作为综合回归，但不能隔离单一机制。Dhrystone 的理想 ILP64 proxy 达 24.1，而实际 IPC 只有 1.887，说明仍有并行性未被当前流水线利用；但理想 ILP 模型忽略真实资源和精确延迟，只能用于说明存在优化空间。

### 10.2 机制 microbench 的反证价值

| Case | 关键数据 | 能隔离的机制 |
|---|---|---|
| `bench_ilp` | IPC 0.770，Backend proxy 71.60%，IQ full 64.25%，non-load source proxy 18.693，selected 0.782 | 整数 producer/wakeup/AIQ service；几乎无访存，能排除 cache |
| `bench_fp` | IPC 1.366，Backend proxy 42.86%，IQ full 29.95%，RF launch 吞吐低 | FP/VIQ/执行路径 |
| `bench_frontend` | 程序 2-bit miss proxy 65.19%，RTL BHT 21.88 MPKI，BadSpec 11.56%，L1I miss 0.07% | 实际是 branch/frontend redirect stress，不是 I-cache stress |
| `bench_br_indirect` | IPC 0.835，BadSpec 14.15%，global flush 29.12 MPKI | indirect/target/恢复路径 |
| `bench_mem` | IPC 0.982，WB deep spec-fail 25.92/KI、实际 LSU flush 20.42/KI，SQ cancel 0.287/cycle | 地址 producer 和 SQ speculation |
| `bench_cache_stride` | cross/staddr 活动高，但 deep spec-fail、LSU flush 和 SQ cancel 为 0 | cross/alignment 特殊路径负对照 |

`bench_ilp` 的名称容易造成误解。它把串行乘加链和 8 路独立累加放在同一 ROI，程序特征显示聚合后的理想 ILP64 只有约 3.05；更准确的定位是“整数依赖与 AIQ/wakeup 混合 stressor”，不是单一的高 ILP 峰值测试。这个 case 几乎排除了 cache 和复杂分支，使 AIQ 服务率问题很清楚，但要分别量化依赖延迟和独立吞吐，仍需把两个 pattern 拆开。

## 11. 下一步优化试验方案

### 11.1 总体目标和执行顺序

下一阶段不是同时修改所有可疑结构，而是用一组单变量干预把“相关性”推进为“因果性”。优先级由证据置信度、潜在收益、RTL 改动风险和验证成本共同决定：

| 顺序 | 实验 | 要回答的问题 | 首轮 RTL 变量 | 主要目标 case | 进入全量回归的条件 |
|---:|---|---|---|---|---|
| E0 | 冻结基线与诊断补强 | 两版结果是否真正可比，热点来自哪些 PC/producer | 只增加监测，不改功能 | 所有后续小集合 | ELF、退休数和基线结果一致 |
| E1 | BHT 同容量索引实验 | mcf 的高方向误判是否主要来自历史/PC 别名 | 只改变 BHT index hash | mcf r/s、gcc_s、xz_s、perlbench_s、leela_r | 方向 MPKI、flush 和 BadSpec 同时下降 |
| E2 | 整数 AIQ 服务实验 | AIQ 压力来自分配失衡、producer/wakeup 还是 select/端口 | 每次只改 steering、forward 或 select 一项 | `bench_ilp`、gcc r/s、xalancbmk r/s、deepsjeng_s、exchange2_s | 对应直接事件先变化，目标组 IPC 提升 |
| E3 | FP/VIQ 服务实验 | 低吞吐 FP 簇在等待哪类 producer，forward 是否过晚 | 每次只改一个 producer class 或 pipe6/7 路径 | `bench_fp`、blender、nab r/s、povray、namd | VIQ non-load wait 与零退休同步下降 |
| E4 | LSU 地址与推测实验 | 地址源等待和 memory-dependence failure 各占多少 | 早地址、依赖预测、replay 恢复分别测试 | Dhrystone、`bench_mem`、parest、bwaves | 地址等待或实际 flush 按实验目标下降 |
| E5 | 容量与大工作集 | 服务率改善后是否仍受 entry/L2/BIU 限制 | AIQ/VIQ/LSIQ 容量或大 footprint | 前四阶段仍 full 的 case、mcf/parest/bwaves/wrf | 扩容或层次结构直接带来独立 IPC 收益 |

建议先实施 E1。mcf r/s 已经形成“约 42 至 43 BHT MPKI -> 约 43 global flush/KI -> 约 20% BadSpec -> IPC 0.69 至 0.71”的完整链条，乐观收益池约 25%；而 BHT 同容量索引实验不需要先扩大 SRAM，也不会像修改 wakeup 时序那样立即触碰数据正确性。E2 和 E3 同样重要，但在修改 forwarding 前必须先知道 consumer 等待的 producer class，否则容易用一个大改动掩盖真实原因。

### 11.2 E0：冻结可复现基线

当前 `spec_all_43_full_1f451a653e1c_dirty` 可以作为分析基线，但后续 RTL 优化不应直接依赖一个无法重新构造的历史 dirty 状态。第一项工作是在任何功能改动前保存一版新的 `e0_opt_base`：固定当前 RTL、TB、工具版本、编译参数、Full profile、warmup 和复位过程，并保存 `git.diff`、`git.status`、编译日志与 ELF。`run_bench.sh` 会重新执行 case build，因此不能只假设源代码未改就代表二进制相同；A/B 结果进入比较前必须核对同名 ELF 的 SHA256 和 Kernel 退休指令数。

诊断补强只加入下列观测，不改变核心状态：

1. **已完成：**退休条件分支和 jump 的 top PC、动态执行次数、误预测次数及错误份额；jump 误预测再按 call、return、other 指令类别拆分。该层能定位反复制造错误的静态 PC，但还不能把 jump 根因精确拆成 BTB、indirect predictor 和 RAS 内部状态。
2. **仍需补充：**AIQ/VIQ/LSIQ 的 oldest not-ready entry，包括 consumer PC、source 编号、producer class、等待年龄和最终释放原因。
3. **仍需补充：**每队列 full episode、oldest-ready age、oldest-not-ready age、create/pop/service rate。
4. **仍需补充：**frontend-starved 与 IBUF-full/backpressure 分离，以及 branch、frontend、memory、backend 的 pairwise raw overlap。
5. **已完成：**`compare_bench.py` 已把摘要 IPC、前后端停顿和几何平均统一到 Kernel ROI，并加入同名 ELF SHA256 与 Kernel 退休指令数门禁。mcf_r 的 Main/Kernel IPC 分别为 0.837/0.690，这一修正确保顶部 GEOMEAN 与本文分析窗口一致；后续比较只有门禁为 `PASS` 时才能作为晋级依据。

这些计数器用于选择优化位置，不以自身数值下降作为性能成功。若监测逻辑改变了 DUT 驱动、门控、复位或组合路径，必须视为功能 RTL 改动，不能再称为零扰动基线。

退休分支 PC 监测已经过单 case 动态闭环核查。`bench_br_bimodal` 的 Kernel ROI 中，逐 PC 条件分支执行数为 2500，与原有三个退休 slot 的 `1778+245+477` 完全一致；逐 PC 误预测数为 72，与 `retire_bht_mispred=72` 一致。`analyze_branch_hotspots.py --strict` 把 5 个热点 PC 全部反汇编为实际 `bne`，修正 monitor 信号对齐前后 Kernel 结果均为 7393 cycles、15028 inst、IPC 2.033。由此可以确认当前 monitor 使用的是与退休 PC 同周期的 RTU 私有退休信号，且没有改变 DUT 的架构执行。正式 E0 目标集合尚未运行，因此本次 smoke 只验证监测正确性，不代表已经获得 mcf/gcc/xz 的热点结论。

### 11.3 E1：先做 BHT 同容量索引实验

当前 `ct_ifu_bht.v` 的 prediction array 使用 10-bit 折叠 GHR 索引，GHR 为 22 bit；selection array 使用 7-bit PC 行索引。第一轮不扩大表项，而是比较三版完全相同容量的索引：

| 版本 | 唯一变量 | 目的 |
|---|---|---|
| B0 | 原始 GHR fold | 新基线 |
| B1 | 在 10-bit GHR fold 中混入对齐后的 PC 位 | 降低不同静态分支共享同一历史行的冲突 |
| B2 | 另一组历史折叠位与 PC 混合，容量和 counter 更新规则不变 | 区分“需要 PC”与“只是某一组 hash 偶然较好” |

实现时必须把索引函数写成 read/update 共用的逻辑概念，并逐一核对正常顺序取指、BJU mispredict、RTU flush 和 update 四条路径。read 侧可获得 `pcgen_bht_pcindex`，update 侧可获得 `cur_cur_pc`；二者代表的 PC 位必须严格对齐。若只改正常 read index 而遗漏恢复 read 或 update index，MPKI 可能因训练读写错位而恶化，这不是有效的 predictor 对比。

首轮目标集合为 mcf r/s、gcc_s、xz_s、perlbench_s、leela_r，加 `bench_br_bimodal`、`bench_br_corr` 和 `bench_frontend` 做机制压力测试；Dhrystone、omnetpp_r 和 fotonik3d_s 作为低方向误判负对照。判定顺序为：

1. 功能 PASS、ELF SHA 和退休指令数不变。
2. mcf 的 BHT MPKI 相对下降至少 15%，即从 43.18/41.83 降到约 36.7/35.6 以下；`rtu_global_flush` 应同向下降。
3. mcf BadSpec 从约 20.4% 明显下降，IPC 至少提升 5%；若 MPKI 下降而 BadSpec、零退休和 IPC 不动，说明错误不在关键路径或分类存在问题。
4. target/indirect/RAS 错误不能抵消 direction 收益，三个负对照 IPC 退化不超过 1%。
5. B1/B2 中只有满足上述链条的版本进入 43 项 Full 回归；两版都失败时停止扩大 BHT，先用 top PC 判断是不可预测模式、更新延迟还是 target 问题。

恢复路径优化必须放在预测准确率实验之后单独进行。它的正确签名是 BHT/target MPKI 基本不变，而 `mispred_to_fetch`、`mispred_to_retire`、BadSpec 和零退休下降；不能与 B1/B2 合在同一版，否则无法知道收益来自少犯错还是恢复更快。

### 11.4 E2：整数 AIQ 服务实验

AIQ0/AIQ1 各有 8 个 entry，但不同 case 的阻塞形态不同。`bench_ilp` 的 AIQ0 占用/未就绪为 7.22/6.89，ready-not-issued 仅 0.007/cycle；gcc_r 则同时存在 non-load not-ready 和约 1.135/cycle ready-not-issued。首轮应把 `bench_ilp` 的串行乘加链和 8 路独立累加拆成两个独立 case：前者测 producer latency/wakeup，后者测 steering、select 和执行吞吐。随后按以下顺序实验：

1. **A1，dual-eligible 指令动态 steering。** 只对两个 AIQ/执行 pipe 都合法的简单整数操作，根据队列可用 entry 或占用选择 AIQ0/AIQ1；特殊、乘除和只支持单 pipe 的操作保持原路由。该实验回答固定 create 优先和队列不均衡是否浪费了另一队列容量。
2. **A2，producer/wakeup/forward。** 根据 oldest not-ready 的 producer class，只补一个已经具有正确数据与 valid 条件、但当前没有及时唤醒 consumer 的路径；不能通过强制 source-ready 制造“理想 forwarding”，因为 ready 而数据未到会破坏功能。
3. **A3，select/port mapping。** 仅在 gcc 等 ready-not-issued 明显的 case 上改变仲裁公平性或 dual-eligible 执行端口映射；不和 A1/A2 合并。
4. **A4，容量 sweep。** 只有 A1-A3 后仍出现高 full、oldest-ready/not-ready age 且 service rate 已改善时，才测试 AIQ entry。当前生成 RTL 将 8 个 entry、age vector、create/select 和 forward 比较显式展开，扩容不是改一个 parameter，必须同步修改并完整验证这些路径。

不同实验的直接签名不能混用：A1 应降低 AIQ0/AIQ1 占用差和 create-blocked；A2 应先降低 non-load not-ready 与 wait-to-ready age；A3 应先降低 ready-not-issued；A4 则可能只降低 full，甚至提高总 occupancy。首轮目标组使用两个拆分 microbench、gcc r/s、xalancbmk r/s、deepsjeng_s 和 exchange2_s，omnetpp r/s 与 x264_s 为负对照。目标组 IPC 几何平均至少提升 3%，且直接事件符合对应签名，才进入全量回归。

### 11.5 E3：FP/VIQ 服务实验

`bench_fp` 同样把依赖 FMA 链和矩阵乘法放在一个 ROI，应先拆成 `fp_dep_chain` 与 `fp_independent`，避免把延迟和吞吐混在一起。随后在 blender、nab r/s、povray 和 namd 上用 oldest entry 追踪把 VIQ non-load 等待分为 pipe6 producer、pipe7 producer、FDSU/divide、跨 pipe 结果、load/vload 和未知来源。

第一版功能改动只能针对占比最高且 RTL 数据已可用的一个 producer class，检查 ex3/ex4/ex5 forward valid、目标 vreg tag 比较、wakeup 时点和 consumer RF launch 条件是否一致。若两个 pipe 的 producer/consumer 分配明显失衡，再单独做 pipe6/pipe7 steering；若 FDSU 长延迟是主因，则研究长延迟操作与普通 FP 的队列或仲裁隔离。VIQ 扩容仍放在最后。

有效 forwarding 实验应使目标 producer class 的等待、VIQ non-load not-ready、VIQ occupancy/full 和 RF launch 0 周期依次下降，同时 RF launch width、VIQ issue 和 IPC 上升。建议以目标组 IPC 几何平均提升 5%、VIQ non-load wait 相对下降 15%、负对照 fotonik3d_s/cactuBSSN_s/cam4_s 退化不超过 1%作为首轮门槛。若 full 降低但 non-load wait、RF launch 和 IPC 不变，不能认定 VIQ 性能得到改善。

### 11.6 E4：LSU 地址与推测实验

LSU 必须拆成三条互斥假设分别试验：

| 实验 | 首要 case | 唯一变量 | 必须先变化的直接指标 |
|---|---|---|---|
| L1 早地址/地址 producer | `bench_mem`、parest | 一个地址 producer 的 wakeup/forward 或 AG 接收时点 | `src0/src1/staddr_no_rdy`、LSIQ not-ready、wait-to-ready |
| L2 memory-dependence speculation | Dhrystone、`bench_mem` | predictor 条件或同一项预测状态 | SQ cancel/replay、deep spec-fail、最终 `lsu_spec_fail_flush` |
| L3 AG/LSIQ service | parest、bwaves | AG 端口仲裁或 ready load 接收能力 | ready-not-issued、LSIQ pop/service、full-update |

Dhrystone 的 deep spec-fail 很高但实际 flush 低，不能只以内部活动下降判成功；L2 必须进一步降低实际 flush、BadSpec/Memory proxy 或零退休并带来 IPC。parest 当前 ready-not-issued 为 0，因此在没有新证据前不适合直接增加 AG 选择带宽；它应先沿 non-load 地址 producer 查找。mcf 只有在 E1 最佳分支版本上重测后才进入 LSU 实验，以免把错误路径压力优化成更大的真实路径硬件。

### 11.7 容量、大工作集与组合版本

容量 sweep 的用途是验证剩余瓶颈，不是默认升级方向。改善 service 后，若 full/create-blocked 仍高、oldest entry 年龄合理、队列后方还有可执行工作，才分别测试 AIQ/VIQ 增加 2 至 4 项或 LSIQ 增加 2 至 4 项。若扩容只使 full 下降、occupancy/not-ready 上升而 issue、RF launch、零退休和 IPC 不变，应立即停止该方向。

L2/BIU/MLP 使用 mcf、parest、bwaves、wrf 的 1 至 5M 指令大 footprint 或真实 checkpoint 区间单独研究，不与 0.5M Full 核心流水线回归混合。前四组实验各自通过后才能建立组合版，并按 BHT -> AIQ -> VIQ -> LSU 的顺序逐项叠加；每增加一项都与上一版比较，不能假设单项收益可以相加。

### 11.8 执行命令与晋级门槛

以下 EDA 编译和 RTL 仿真命令应在宿主 EDA 环境执行。首轮只跑机制目标集合，Full 结果通过后再跑 43 项：

```bash
cd /home/wangwy/openproject/openc910/smart_run

BR_CASES="bench_br_bimodal bench_br_corr bench_frontend dhrystone \
spec_505_mcf_composite_kernel spec_605_mcf_composite_kernel \
spec_602_gcc_speed_kernel spec_657_xz_speed_kernel \
spec_600_perlbench_speed_kernel spec_leela_playout_kernel \
spec_omnetpp_event_kernel spec_649_fotonik3d_speed_kernel"

# 在未修改功能 RTL 的 E0 状态编译并保存目标集合基线
make compile DUMP=off PERF_DETAIL=on
BENCH_CASES="$BR_CASES" ./run_bench.sh --profile full --tag e0_bht_base

# 反汇编核验并列出 Kernel ROI 中误预测贡献最高的条件分支
python3 analyze_branch_hotspots.py \
  results/e0_bht_base_<git>_<clean-or-dirty> \
  --phase Kernel --kind cond --top 20 --strict

# 应用且只应用 B1 索引改动后，重新编译并运行同一集合
make compile DUMP=off PERF_DETAIL=on
BENCH_CASES="$BR_CASES" ./run_bench.sh --profile full --tag e1_bht_pcxor
```

先用两个实际生成的目标集合目录运行 `compare_bench.py`。当候选版通过后，再从正式基线的 `run.info` 复用完全相同的 43 项列表。全量比较优先使用新冻结的 `e0_opt_base_full`；只有证明当前 E0 的 RTL、TB、ELF 和历史目录完全一致时，才可复用历史 Full 结果：

```bash
ALL43="$(sed -n 's/^bench_cases=//p' \
  results/spec_all_43_full_1f451a653e1c_dirty/run.info)"

# 该命令在 E0 状态执行一次，形成后续所有优化共用的全量基线
BENCH_CASES="$ALL43" ./run_bench.sh --profile full --tag e0_opt_base_full

# 恢复候选 RTL 并重新 compile 后执行
BENCH_CASES="$ALL43" ./run_bench.sh --profile full --tag e1_bht_pcxor_full

# 参数必须是 results/ 下实际生成的两个目录名；先确认摘要已使用 Kernel_IPC
python3 compare_bench.py \
  e0_opt_base_full_<git>_<clean-or-dirty> \
  e1_bht_pcxor_full_<git>_<clean-or-dirty>
```

`--characterize` 不需要在纯 RTL A/B 中重复执行，因为 kernel 和动态程序特征没有改变；若修改了 C/汇编、链接布局或编译选项，则旧特征与旧基线全部失效，必须重新 characterize。候选版晋级需要同时满足四层条件：功能 PASS 且退休数一致；目标直接指标按假设变化；目标组 IPC 几何平均达到实验门槛；43 项几何平均不退化且任何单项超过 1% 的退化都能解释。进入最终实现前还必须比较综合频率、面积和功耗，至少保证 `IPC geomean x Fmax` 为正收益。

当前推荐在正式 E0 目录生成后先运行热点脚本，再决定 B1/B2 的具体 PC 混合位。不能根据 `bench_br_bimodal` 的 smoke 热点直接设计 mcf 的 hash，因为 microbench 的规则循环只验证 monitor，不代表 SPEC 的 alias 模式。若 E0 中 mcf 的错误集中在少数高频 PC，下一步应比较这些 PC 的现有 prediction/selection index 冲突；若错误分散且单 PC 熵高，则同容量换 hash 的成功概率较低，应转向历史长度、局部历史或混合预测实验。

### 11.9 暂不优先的方向

| 方向 | 暂不优先原因 | 何时重新评估 |
|---|---|---|
| 扩大 ROB | full/高占用几乎为 0 | IQ/branch/LSU 改善后 ROB full 明显上升 |
| 扩大 PREG/FREG | 实际 alloc block 为 0 | `preg_alloc_block` 和 block episode 出现 |
| 扩大 I-cache | L1I miss 和 refill busy 很低 | `frontend_starved` 证明真实断供 |
| 全面增加 fetch width | 当前主要是 IBUF full 而非 empty | 后端反压解除后出现持续取指不足 |
| 全面增加发射宽度 | 主要低 IPC case 缺 ready 指令，不是所有端口都繁忙 | ready-not-issued 和执行 busy 普遍成为主导 |
| 只优化 cache miss | parest/Dhrystone 等关键问题不是 miss | 大工作集真实区间显示 memory-bound 主导 |

## 12. 实验闭环与报告要求

体系结构优化本质上是干预实验。观测数据只能提出假设，真正的因果证据来自“只改变机制 A 后，A 的直接事件首先按预期变化”。因此每次 RTL 修改只改变一个机制，并固定 ELF、编译选项、Full profile、warmup、复位过程和仿真参数。若流程仍会重新 build kernel，必须用 SHA256 证明 A/B 的 ELF 完全相同；二进制不同会让代码布局和动态指令流成为混杂变量。确定性 RTL 仿真通常不需要用大量重复运行估计随机误差，但必须保证统计窗口、二进制和初始状态完全一致。

一次完整实验应按以下顺序解释：先确认功能与退休指令数一致；再看被修改机制的直接计数器；然后检查压力是否只是转移到相邻队列；最后才看 IPC、全套回归和 PPA（性能、功耗和面积）。报告至少包含：

1. 43 项 IPC、CPI 和几何平均变化。
2. 目标 case 的零退休、RF launch 宽度和 IQ selected。
3. 目标队列 occupancy、full-update、not-ready、ready-not-issued 和 service rate。
4. 若改 branch，报告 MPKI、flush 和恢复延迟。
5. 若改 LSU，报告 miss、LSIQ/SQ/LFB、replay/cancel 和 BIU latency。
6. 负对照 case 的指标是否保持稳定。
7. 频率、综合面积和关键路径影响；只在 RTL 仿真中提高 IPC 但显著降低频率，不是最终性能提升。

判断因果的基本形式应是：

> 修改机制 A 后，直接事件 A 下降，相关队列/延迟按预期变化，零退休下降，IPC 上升，并且负对照基本不变。

如果只看到 IPC 变化而机制计数器不变，应优先怀疑代码布局、编译差异、统计窗口或其他耦合，而不是直接宣布优化成功。

## 13. 最终判断

当前 C910 RTL 的主要问题不是“cache 太差”或“ROB 太小”，也不能再笼统写成“IQ not-ready”。最新证据给出了更具体的体系结构图景：

1. 整数压力主要从 non-load producer 依赖开始：bench_ilp 的聚合结果是 not-ready 主导型，gcc 是 not-ready 与 ready-select 混合型，xalancbmk/deepsjeng/exchange2 位于两者之间；bench_ilp 的串行链和独立累加仍需拆开验证。
2. blender、nab、povray、namd 的 VIQ entry 有约 94% 至 96% 未 ready，且等待源几乎不是 load；FP producer latency、forward/wakeup 和 pipe6/7 服务率共同构成当前可定位的根因范围。
3. mcf 的 branch bad speculation 最严重，并叠加 LSIQ/访存压力。
4. parest 的 LSIQ 压力来自地址相关源未 ready；Dhrystone 暴露高 staddr/SQ 内部活动但实际 flush 较少，bench_mem 则暴露 src0 producer 等待且更大比例进入 LSU flush，两者不能合并归因。
5. 大量 frontend proxy 由 IBUF full 触发，结合低 I-cache miss/refill 和下游队列积压，证据不支持优先扩大 I-cache。
6. ROB 和物理寄存器容量当前没有形成第一层限制。

上述结论的置信度并不相同。mcf 的方向预测链、低吞吐 FP 簇的 VIQ non-load producer 等待、parest 的 LSIQ 地址源等待，以及 I-cache/ROB/PREG 的排除结论，都有多层计数器或负对照支撑，置信度较高。Dhrystone 的 staddr/SQ 内部活动异常是高置信度观测，但这些活动中有多少形成实际性能损失只有中等置信度，因为 deep spec-fail 与最终 flush 相差很大。具体是哪一级 FP forward、哪一个整数 producer PC、哪一种 select 端口冲突，目前也只定位到了候选范围。扩大某个 IQ、采用哪一种新分支预测器、完整 SPEC ref 是否转为 L2/DRAM 主导，则尚未由当前数据证明，必须留给后续实验。

最可靠的执行顺序是：**先冻结 E0 并补足 top PC/producer 追踪；第一项功能实验做 mcf 的 BHT 同容量索引对照；随后按 not-ready、ready-select、capacity 三种签名分别推进 AIQ 和 VIQ；再独立处理 LSU 地址与推测路径；最后才做容量 sweep、组合版本和 43 项/PPA 回归。** 这条路线不预设某个结构一定有效，而是要求每次改动都能从直接事件一直解释到 IPC，形成可重复的体系结构研究闭环。
