# PERF_DETAIL 细粒度性能指标说明与完整字典

本文档是 `PERF_DETAIL` 的唯一正式说明文档，合并了原来的使用说明、准确性边界和指标编号索引。以后查询 `.detail.perf` 指标时只看本文档。

`PERF_DETAIL` 位于 `smart_run/logical/tb/tb.v`，是 testbench 侧性能观测逻辑，不修改 CPU 功能 RTL。它通过层级引用读取现有 RTL 内部信号，输出事件计数、平均占用/宽度和延迟分布，用于分析 C910 乱序超标量流水线瓶颈。

## 使用方式

编译带细粒度探针的仿真模型：

```bash
cd smart_run
make compile DUMP=off PERF_DETAIL=on
```

运行 benchmark 并保存结果：

```bash
BENCH_CASES="dhrystone coremark bench_mem spec_mcf_kernel" ./run_bench.sh perf_detail_v1
```

结果保存目录：

```bash
smart_run/results/<tag>_<git>_<clean|dirty>/
```

关键输出文件：

| 文件 | 内容 |
|---|---|
| `<case>.perf` | 原有 HPCP 粗粒度计数：周期、IPC、cache miss、branch miss、frontend/backend stall、LSU/RF 事件 |
| `<case>.detail.perf` | 本文档说明的细粒度指标：700 个 detail 事件、104 个 profile 平均值、54 个 latency 分布 |
| `<case>.summary.txt` | benchmark 简要结果 |
| `<case>.run.vcs.log` | 完整仿真日志，包含 `.perf` 和 `.detail.perf` 表格 |

## 输出表口径

### Detail 事件计数

| 列 | 含义 |
|---|---|
| `Perf Count` | 选定 phase 内事件计数或状态为 1 的周期数 |
| `Retired Inst` | 选定 phase 内退休指令数 |
| `Per KInst` | 每 1000 条退休指令的事件次数 |
| `Cycles %` | 事件周期数 / phase 周期数。对脉冲事件可理解为相对周期规模，不一定是严格持续时间 |

### Profile 平均宽度/占用

| 列 | 含义 |
|---|---|
| `Sum Value` | phase 内每周期值的累加 |
| `Cycles` | phase 周期数 |
| `Avg / Cycle` | 平均每周期值 |

### Latency 延迟分布

| 列 | 含义 |
|---|---|
| `Samples` | 完成采样的 episode 数 |
| `Avg Cycles` | 平均等待周期 |
| `<=4/<=8/<=16/<=32/<=64/>64` | 延迟桶分布 |

## 指标准确性等级

| 等级 | 含义 | 典型指标 | 使用建议 |
|---|---|---|---|
| 精确事件 | 直接采样 RTL 的 valid/full/stall/handshake 脉冲或状态位 | `biu_ar_hs_deep`、`lfb_addr_pop_entry`、`wmb_entry_pop_deep`、`rob_commit0` | 可以直接作为事件次数或周期占比使用 |
| 精确宽度/占用 | 对 RTL valid 向量做 popcount 或对多路 valid 求和 | `rob_occ_avg`、`iq_ready_width_avg`、`sq_pop_width_avg` | 可以作为平均并发度、资源压力使用 |
| 代表性延迟窗口 | testbench 只跟踪每类事件的一个 active 窗口，不为每个 entry/transaction 建时间戳 | `dispatch_to_commit`、`sq_create_to_pop`、`biu_ar_to_rlast` | 用于判断是否存在长等待，不能当作全量逐事务延迟直方图 |

边界说明：

1. `detail_counter` 采用 `detail_n_delay` 累加，事件采样有一拍延迟。长 benchmark 影响很小，phase 边界附近有一拍级误差。
2. `biu_rd_outstanding_avg` 和 `biu_wr_outstanding_avg` 是 testbench 维护的 AXI-facing outstanding 深度。它适合看趋势，但短 phase、AR/RLAST 不平衡或 phase 边界场景要谨慎，不能单独作为内存带宽瓶颈证据。
3. latency 类指标是代表性 episode，不是逐 entry 或逐 transaction 全量追踪。
4. CPI stack 相关指标是 testbench 近似分类，不是硬件 PMU 的唯一根因归因。

## 静态核查结论

| 核查项 | 结果 |
|---|---|
| RTL 层级宏 | 45 个 |
| RTL 信号引用 | 663 个 `` `MACRO.signal`` 引用 |
| RTL 源码匹配 | 全部能在 `C910_RTL_FACTORY/gen_rtl` 对应模块源码中找到 |
| Detail 编号 | 1-700 连续，无重复、无缺号 |
| Profile 编号 | 1-104 连续，无重复、无缺号 |
| Latency 编号 | 1-54 连续，无重复、无缺号 |

注意：这是静态源码核查，不等同于 EDA elaboration。它能确认信号名和模块来源正确，但不能替代一次真正的 `make compile PERF_DETAIL=on`。

## 关键 RTL 信号来源

| 指标组 | RTL 来源 | 准确性说明 |
|---|---|---|
| Frontend / L0 BTB | `ct_ifu_ibctrl.v` 中 `ibctrl_ibdp_l0_btb_hit/miss/mispred/wait` | 能反映 L0 BTB 命中、miss、误预测和等待状态 |
| Indirect BTB | `ct_ifu_ibctrl.v` 中 `ibctrl_ind_btb_check_vld`、`ibctrl_ind_btb_fifo_stall`、`ibctrl_pcfifo_if_ind_btb_miss` | `ind_btb_miss` 是 miss 侧 proxy，不是完整准确率 |
| RAS | `ct_ifu_ibctrl.v` / `ct_ifu_ras.v` 中 RAS redirect、mistaken、push/pop/full/empty | 能观察 RAS 活动和错误，但不是完整表项级统计 |
| BHT | `ct_ifu_bht.v` 中 `bht_pred_array_rd`、`bht_sel_array_rd`、`wr_buf_hit`、`bju_mispred` | 是 BHT 活动/旁路/误预测侧信号，不是完整预测准确率 |
| Rename / PST | `ct_idu_id_ctrl.v`、`ct_idu_ir_ctrl.v`、`ct_rtu_pst_*` | ID/IR stall 和物理寄存器 alloc valid/block 直接来自 RTL |
| ROB | `rtu_had_debug_info[24:18]`、`ct_rtu_rob_rt.v` | 适合看 ROB 饱和、head 阻塞和 commit，不是逐 entry age |
| IQ ready/select | `ct_idu_is_aiq*`、`biq`、`lsiq`、`sdiq`、`viq*` 中 entry valid/ready/issue_en | entry 向量直接可见，ready/not-ready 个数可信 |
| LSU queue/buffer | LQ/SQ/RB/LFB/WMB entry valid/full/create/pop 信号 | 能反映资源占用、生命周期和结构阻塞 |
| D-cache arbiter | `ct_lsu_dcache_arb.v` 中 request/grant/tag/data/dirty/borrow/serial 信号 | 能看仲裁源和 tag/data 请求，没有完整 bank conflict 统计 |
| Load replay/spec fail | `ct_lsu_ld_da.v`、`ct_lsu_st_da.v` discard/spec_fail 信号 | 能看 replay/discard/spec fail 压力，没有逐 load violation age |
| BIU/AXI | `ct_biu_read_channel.v`、`ct_biu_write_channel.v` 中 AR/R/W/B valid/ready/last | handshake 准确；outstanding 是 testbench AXI-facing 维护口径 |
| MMU/TLB/PTW | `ct_mmu_top.v`、IUTLB/DUTLB/JTLB/PTW 请求和完成信号 | 能观察 TLB miss、refill arbitration 和 page walk 活动 |

## 如何用这些指标定位瓶颈

1. 先看 `<case>.perf` 的 IPC、Backend Stall、Frontend Stall、I-cache/D-cache miss、branch miss。
2. 再看 `.detail.perf` 的 `retire_width_avg` 和 `retire_width0_cycle`。如果 retire width 经常为 0，继续看 CPI proxy。
3. 看 `cpi_stack_*` 和 `zero_*_raw`，判断大方向是 bad speculation、frontend、memory 还是 backend core。
4. 如果是 frontend：看 `icache_refill_*`、`ifu_ibuf_full`、`ifu_pcfifo_full_stall`、`l0_btb_*`、`ind_btb_*`、`bht_*`、`flush_to_fetch`。
5. 如果是 memory：看 `dcache_*_miss`、`ld/st_utlb_miss`、`lq/sq/rb/lfb/wmb_*`、`dca_*`、`biu_*backpressure`、`*_to_pop` latency。
6. 如果是 backend core：看 `rob_occ_avg/ge*`、`rob_head_block_latency`、`iq_ready/not_ready/select`、`rf_pipe*_src_no_rdy`、`preg/ereg_alloc*_block`。
7. 如果是 bad speculation：看 `retire_*mispred`、`iu_*mispred`、`l0_btb_mispred`、`bht_bju_mispred`、`ld/st_spec_fail`、`flush_to_*`。

常见判断：

| 现象 | 优先查看 |
|---|---|
| IPC 低但 miss 不高 | `id/ir/is/rf/retire_width_avg`、`retire_width0_cycle` |
| ROB 满 | `rob_occ_avg`、`rob_occ_ge64/ge96`、`rob_head_block_latency`、`retire_width_avg` |
| IQ 满或 ready 但发不出 | `*_full`、`*_ready_any`、`*_issue_select_any`、`*_ready_to_issue` |
| 源操作数未就绪 | `rf_pipe*_src_no_rdy`、`*_wait_to_ready`、`iq_not_ready_width_avg` |
| free-list 限制 rename | `preg/ereg_alloc*_block`、`preg_alloc_avail0`、`ereg_alloc_avail0` |
| D-cache/LSU 限制 | `dca_*`、`lfb_*`、`rb_*`、`wmb_*`、`sq_*`、`ld_*discard*` |
| 总线/内存系统限制 | `biu_*backpressure`、`biu_ar_to_rlast`、`biu_aw_to_b_full`，outstanding 只作辅助 |
| 分支恢复代价高 | `retire_bht_mispred`、`retire_jmp_mispred`、`flush_to_fetch`、`mispred_to_fetch`、`flush_to_retire` |

## 完整指标字典阅读说明

每个指标都给出模块、含义/用途和注意事项。`pipeN`、`slotN`、`widthN` 这类模式化指标按实际编号逐项列出，但含义遵循同一模式。

## Detail 事件计数完整字典

| ID | 指标 | 模块 | 含义 | 用途 | 注意 |
|---|---|---|---|---|---|
| 1 | `id_ctrl_stall` | IDU/IQ/RF | ID 控制级 stall 周期，表示 ID 控制逻辑无法向后级推进。 | 判断前端送达后是否被 ID/rename/flush/结构条件阻塞。 | 这是综合 stall，不单独说明根因，需要结合 IR、ROB、IQ、flush 指标。 |
| 2 | `id_ir_stall` | IDU/IQ/RF | ID 到 IR/rename 方向的阻塞周期。 | 判断指令进入 rename 前是否受后端反压。 | 不是前端取指 miss，通常和 rename/ROB/IQ/full 共同分析。 |
| 3 | `id_not_pipedown3` | IDU/IQ/RF | ID 未能达到 3 条 pipe-down 的周期。 | 观察 ID 供给宽度不足或后端接收不足。 | 宽度不足可能来自前端，也可能来自后端反压。 |
| 4 | `id_pipedown1` | IDU/IQ/RF | ID 当周期向后级成功送出 1 条指令。 | 评估 ID 实际供给宽度。 | 与 id_width*_cycle、ir_width*_cycle 一起看。 |
| 5 | `id_pipedown2` | IDU/IQ/RF | ID 当周期向后级成功送出 2 条指令。 | 评估 ID 实际供给宽度。 | 与 id_width*_cycle、ir_width*_cycle 一起看。 |
| 6 | `id_pipedown3` | IDU/IQ/RF | ID 当周期向后级成功送出 3 条指令。 | 评估 ID 实际供给宽度。 | 与 id_width*_cycle、ir_width*_cycle 一起看。 |
| 7 | `id_fence_stall` | IDU/IQ/RF | fence/sync 类指令导致 ID 停顿。 | 判断同步指令是否破坏流水并行度。 | 普通 bare-metal benchmark 中通常应很低。 |
| 8 | `id_split_long_stall` | IDU/IQ/RF | 长指令或拆分指令导致 ID 停顿。 | 判断复杂指令拆分是否影响前端到后端吞吐。 | 若高，需要查具体指令形态。 |
| 9 | `rtu_rob_full` | RTU/PST/退休 | RTU 报告 ROB 满导致前端/rename 阻塞。 | 判断是否需要研究 ROB 容量或 commit 释放速度。 | 若低，扩大 ROB 通常不是第一优化方向。 |
| 10 | `ir_preg_not_vld` | IDU/IQ/RF | IR/rename 阶段物理寄存器分配结果无效。 | 判断整数物理寄存器 free-list 或 rename 资源压力。 | 要结合 preg_alloc*_block 和 preg_alloc_avail*。 |
| 11 | `rtu_idu_flush_stall` | RTU/PST/退休 | RTU flush 使 IDU 停顿的周期。 | 判断 flush/recovery 对前端和 rename 的影响。 | 和 rtu_global_flush、flush_to_* latency 联合看。 |
| 12 | `rtu_global_flush` | RTU/PST/退休 | RTU 全局 flush 事件。 | 统计异常、误预测、LSU spec fail 等导致的流水清空。 | 它是 flush 总入口，不区分具体原因。 |
| 13 | `rtu_ifu_flush` | RTU/PST/退休 | RTU 发往 IFU 的 flush 事件。 | 判断前端重定向/清空频率。 | 恢复代价看 flush_to_fetch/flush_to_id。 |
| 14 | `iu_pipe0_flush` | IU/预测校验 | IU pipe0 触发的 flush。 | 观察整数/分支执行侧修正控制流的次数。 | 需结合分支误预测和 BJU 信号。 |
| 15 | `lsu_spec_fail_flush` | LSU/Cache | LSU speculative fail 触发的 flush。 | 定位访存推测失败对性能的影响。 | 更细原因要看 lsu_spec_fail_deep、ld/st discard。 |
| 16 | `rf_pipe0_lch_fail` | IDU/IQ/RF | 整数/分支相关执行 pipe0 RF launch 失败。 | 判断 issue 后进入 RF 时是否被源操作数、前递、端口或结构条件打回。 | 这是 pipe 级失败总量，原因需看 src_no_rdy、preg/vreg_conflict。 |
| 17 | `rf_pipe1_lch_fail` | IDU/IQ/RF | 整数/乘法相关执行 pipe1 RF launch 失败。 | 判断 issue 后进入 RF 时是否被源操作数、前递、端口或结构条件打回。 | 这是 pipe 级失败总量，原因需看 src_no_rdy、preg/vreg_conflict。 |
| 18 | `rf_pipe2_lch_fail` | IDU/IQ/RF | 整数执行 pipe2 RF launch 失败。 | 判断 issue 后进入 RF 时是否被源操作数、前递、端口或结构条件打回。 | 这是 pipe 级失败总量，原因需看 src_no_rdy、preg/vreg_conflict。 |
| 19 | `rf_pipe3_lch_fail` | IDU/IQ/RF | load 地址/访存相关 pipe3 RF launch 失败。 | 判断 issue 后进入 RF 时是否被源操作数、前递、端口或结构条件打回。 | 这是 pipe 级失败总量，原因需看 src_no_rdy、preg/vreg_conflict。 |
| 20 | `rf_pipe4_lch_fail` | IDU/IQ/RF | 向量/浮点相关 pipe4 RF launch 失败。 | 判断 issue 后进入 RF 时是否被源操作数、前递、端口或结构条件打回。 | 这是 pipe 级失败总量，原因需看 src_no_rdy、preg/vreg_conflict。 |
| 21 | `rf_pipe5_lch_fail` | IDU/IQ/RF | store 地址/访存相关 pipe5 RF launch 失败。 | 判断 issue 后进入 RF 时是否被源操作数、前递、端口或结构条件打回。 | 这是 pipe 级失败总量，原因需看 src_no_rdy、preg/vreg_conflict。 |
| 22 | `rf_pipe6_lch_fail` | IDU/IQ/RF | VFPU pipe6 RF launch 失败。 | 判断 issue 后进入 RF 时是否被源操作数、前递、端口或结构条件打回。 | 这是 pipe 级失败总量，原因需看 src_no_rdy、preg/vreg_conflict。 |
| 23 | `rf_pipe7_lch_fail` | IDU/IQ/RF | VFPU pipe7 RF launch 失败。 | 判断 issue 后进入 RF 时是否被源操作数、前递、端口或结构条件打回。 | 这是 pipe 级失败总量，原因需看 src_no_rdy、preg/vreg_conflict。 |
| 24 | `rf_pipe0_src_no_rdy` | IDU/IQ/RF | 整数/分支相关执行 pipe0 RF launch 时源操作数未就绪。 | 定位 wakeup/forward/load-use 相关瓶颈。 | 高时应追 producer 类型和等待链。 |
| 25 | `rf_pipe1_src_no_rdy` | IDU/IQ/RF | 整数/乘法相关执行 pipe1 RF launch 时源操作数未就绪。 | 定位 wakeup/forward/load-use 相关瓶颈。 | 高时应追 producer 类型和等待链。 |
| 26 | `rf_pipe2_src_no_rdy` | IDU/IQ/RF | 整数执行 pipe2 RF launch 时源操作数未就绪。 | 定位 wakeup/forward/load-use 相关瓶颈。 | 高时应追 producer 类型和等待链。 |
| 27 | `rf_pipe3_src_no_rdy` | IDU/IQ/RF | load 地址/访存相关 pipe3 RF launch 时源操作数未就绪。 | 定位 wakeup/forward/load-use 相关瓶颈。 | 高时应追 producer 类型和等待链。 |
| 28 | `rf_pipe4_src_no_rdy` | IDU/IQ/RF | 向量/浮点相关 pipe4 RF launch 时源操作数未就绪。 | 定位 wakeup/forward/load-use 相关瓶颈。 | 高时应追 producer 类型和等待链。 |
| 29 | `rf_pipe5_src_no_rdy` | IDU/IQ/RF | store 地址/访存相关 pipe5 RF launch 时源操作数未就绪。 | 定位 wakeup/forward/load-use 相关瓶颈。 | 高时应追 producer 类型和等待链。 |
| 30 | `rf_pipe6_src_no_rdy` | IDU/IQ/RF | VFPU pipe6 RF launch 时源操作数未就绪。 | 定位 wakeup/forward/load-use 相关瓶颈。 | 高时应追 producer 类型和等待链。 |
| 31 | `rf_pipe7_src_no_rdy` | IDU/IQ/RF | VFPU pipe7 RF launch 时源操作数未就绪。 | 定位 wakeup/forward/load-use 相关瓶颈。 | 高时应追 producer 类型和等待链。 |
| 32 | `rf_pipe3_reg_lch_fail` | IDU/IQ/RF | load 地址/访存相关 pipe3 寄存器读相关 launch 失败。 | 判断 RF 读端口或寄存器访问条件是否限制发射。 | 和 preg/vreg conflict 区分。 |
| 33 | `rf_pipe4_reg_lch_fail` | IDU/IQ/RF | 向量/浮点相关 pipe4 寄存器读相关 launch 失败。 | 判断 RF 读端口或寄存器访问条件是否限制发射。 | 和 preg/vreg conflict 区分。 |
| 34 | `rf_pipe5_reg_lch_fail` | IDU/IQ/RF | store 地址/访存相关 pipe5 寄存器读相关 launch 失败。 | 判断 RF 读端口或寄存器访问条件是否限制发射。 | 和 preg/vreg conflict 区分。 |
| 35 | `rf_pipe3_preg_conflict` | IDU/IQ/RF | load 地址/访存相关 pipe3 整数物理寄存器读端口冲突。 | 判断 PREG 读端口仲裁是否导致发射失败。 | 只覆盖该 pipe 暴露的冲突口径。 |
| 36 | `rf_pipe5_preg_conflict` | IDU/IQ/RF | store 地址/访存相关 pipe5 整数物理寄存器读端口冲突。 | 判断 PREG 读端口仲裁是否导致发射失败。 | 只覆盖该 pipe 暴露的冲突口径。 |
| 37 | `rf_pipe3_vreg_conflict` | IDU/IQ/RF | load 地址/访存相关 pipe3 向量/浮点寄存器读端口冲突。 | 判断 VREG/FREG 读端口是否限制 FP/向量发射。 | 主要用于 FP/VIQ case。 |
| 38 | `rf_pipe4_vreg_conflict` | IDU/IQ/RF | 向量/浮点相关 pipe4 向量/浮点寄存器读端口冲突。 | 判断 VREG/FREG 读端口是否限制 FP/向量发射。 | 主要用于 FP/VIQ case。 |
| 39 | `lsu_ld_cross4k_hpcp` | LSU/Cache | load 跨 4K 或相关边界处理 stall。 | 判断地址跨界特殊路径是否触发 LSU replay。 | 名字沿用 HPCP，需结合 ld_ag_cross_req。 |
| 40 | `lsu_st_cross4k_hpcp` | LSU/Cache | store 跨 4K 或相关边界处理 stall。 | 判断 store 地址跨界特殊路径压力。 | 需结合 st_ag_cross_req。 |
| 41 | `lsu_ld_other_hpcp` | LSU/Cache | load 其他 LSU stall/replay 类事件。 | 定位非 cross4K 的 load LSU 压力。 | 这是粗分类，具体原因看 deep 指标。 |
| 42 | `lsu_st_other_hpcp` | LSU/Cache | store 其他 LSU stall/replay 类事件。 | 定位非 cross4K 的 store LSU 压力。 | 这是粗分类，具体原因看 WMB/SQ/deep 指标。 |
| 43 | `ld_ag_cross_req` | LSU/Cache | load AG 产生 cross/boundary 类请求。 | 判断 load 地址生成阶段是否频繁进入特殊边界路径。 | 高不必然等于 cache miss。 |
| 44 | `ld_ag_dcache_stall_req` | LSU/Cache | load AG 因 D-cache 侧条件请求 stall。 | 判断 load 进入 D-cache 前是否受仲裁或资源限制。 | 需结合 dca_ld_req/grnt 和 lfb/rb。 |
| 45 | `ld_ag_mmu_stall_req` | LSU/Cache | AG 阶段因 MMU/TLB 相关条件停顿。 | 判断地址翻译是否阻塞 LSU。 | 结合 utlb/jtlb/PTW 指标确认。 |
| 46 | `ld_ag_atomic_no_cmit` | LSU/Cache | 原子操作尚不能提交导致的请求。 | 判断 atomic/同步类访存是否限制流水。 | 普通 benchmark 中通常应很低。 |
| 47 | `st_ag_cross_req` | LSU/Cache | store AG 产生 cross/boundary 类请求。 | 判断 store 地址生成阶段是否频繁进入特殊边界路径。 | 高时检查数据布局和地址对齐。 |
| 48 | `st_ag_dcache_stall_req` | LSU/Cache | store AG 因 D-cache 侧条件请求 stall。 | 判断 store 进入 D-cache 前是否受仲裁或资源限制。 | 需结合 dca_st_req/grnt 和 wmb/sq。 |
| 49 | `st_ag_mmu_stall_req` | LSU/Cache | AG 阶段因 MMU/TLB 相关条件停顿。 | 判断地址翻译是否阻塞 LSU。 | 结合 utlb/jtlb/PTW 指标确认。 |
| 50 | `st_ag_atomic_no_cmit` | LSU/Cache | 原子操作尚不能提交导致的请求。 | 判断 atomic/同步类访存是否限制流水。 | 普通 benchmark 中通常应很低。 |
| 51 | `ifu_frontend_stall_raw` | IFU/分支 | 前端 raw stall 周期。 | 判断取指/供给/重定向是否参与瓶颈。 | 可能受后端反压影响，不等于 I-cache miss。 |
| 52 | `ifu_ibuf_full` | IFU/分支 | IFU IBUF 满状态周期。 | 判断前端 buffer 是否被后端反压或消费不足撑满。 | IBUF full 高不一定是前端供给不足。 |
| 53 | `ifu_pcfifo_full_stall` | IFU/分支 | PC FIFO 满导致前端停顿。 | 判断取指控制队列容量/消费是否限制。 | 与分支重定向和后端反压相关。 |
| 54 | `id_width0_cycle` | IDU/IQ/RF | ID 阶段当周期有效宽度为 0 的周期数。 | 看流水前中段实际宽度分布。 | 与 avg 宽度互相校验。 |
| 55 | `id_width1_cycle` | IDU/IQ/RF | ID 阶段当周期有效宽度为 1 的周期数。 | 看流水前中段实际宽度分布。 | 与 avg 宽度互相校验。 |
| 56 | `id_width2_cycle` | IDU/IQ/RF | ID 阶段当周期有效宽度为 2 的周期数。 | 看流水前中段实际宽度分布。 | 与 avg 宽度互相校验。 |
| 57 | `id_width3_cycle` | IDU/IQ/RF | ID 阶段当周期有效宽度为 3 的周期数。 | 看流水前中段实际宽度分布。 | 与 avg 宽度互相校验。 |
| 58 | `ir_width0_cycle` | IDU/IQ/RF | IR 阶段当周期有效宽度为 0 的周期数。 | 看流水前中段实际宽度分布。 | 与 avg 宽度互相校验。 |
| 59 | `ir_width1_cycle` | IDU/IQ/RF | IR 阶段当周期有效宽度为 1 的周期数。 | 看流水前中段实际宽度分布。 | 与 avg 宽度互相校验。 |
| 60 | `ir_width2_cycle` | IDU/IQ/RF | IR 阶段当周期有效宽度为 2 的周期数。 | 看流水前中段实际宽度分布。 | 与 avg 宽度互相校验。 |
| 61 | `ir_width3_cycle` | IDU/IQ/RF | IR 阶段当周期有效宽度为 3 的周期数。 | 看流水前中段实际宽度分布。 | 与 avg 宽度互相校验。 |
| 62 | `ir_width4_cycle` | IDU/IQ/RF | IR 阶段当周期有效宽度为 4 的周期数。 | 看流水前中段实际宽度分布。 | 与 avg 宽度互相校验。 |
| 63 | `is_width0_cycle` | IDU/IQ/RF | IS 阶段当周期有效宽度为 0 的周期数。 | 看流水前中段实际宽度分布。 | 与 avg 宽度互相校验。 |
| 64 | `is_width1_cycle` | IDU/IQ/RF | IS 阶段当周期有效宽度为 1 的周期数。 | 看流水前中段实际宽度分布。 | 与 avg 宽度互相校验。 |
| 65 | `is_width2_cycle` | IDU/IQ/RF | IS 阶段当周期有效宽度为 2 的周期数。 | 看流水前中段实际宽度分布。 | 与 avg 宽度互相校验。 |
| 66 | `is_width3_cycle` | IDU/IQ/RF | IS 阶段当周期有效宽度为 3 的周期数。 | 看流水前中段实际宽度分布。 | 与 avg 宽度互相校验。 |
| 67 | `is_width4_cycle` | IDU/IQ/RF | IS 阶段当周期有效宽度为 4 的周期数。 | 看流水前中段实际宽度分布。 | 与 avg 宽度互相校验。 |
| 68 | `rf_launch_width0_cycle` | IDU/IQ/RF | RF launch 当周期成功发射宽度为 0 的周期数。 | 判断 issue 到 RF 的实际发射吞吐。 | 低宽度多时查 RF fail、IQ not-ready、端口冲突。 |
| 69 | `rf_launch_width1_cycle` | IDU/IQ/RF | RF launch 当周期成功发射宽度为 1 的周期数。 | 判断 issue 到 RF 的实际发射吞吐。 | 低宽度多时查 RF fail、IQ not-ready、端口冲突。 |
| 70 | `rf_launch_width2_cycle` | IDU/IQ/RF | RF launch 当周期成功发射宽度为 2 的周期数。 | 判断 issue 到 RF 的实际发射吞吐。 | 低宽度多时查 RF fail、IQ not-ready、端口冲突。 |
| 71 | `rf_launch_width3_cycle` | IDU/IQ/RF | RF launch 当周期成功发射宽度为 3 的周期数。 | 判断 issue 到 RF 的实际发射吞吐。 | 低宽度多时查 RF fail、IQ not-ready、端口冲突。 |
| 72 | `rf_launch_width4_cycle` | IDU/IQ/RF | RF launch 当周期成功发射宽度为 4 的周期数。 | 判断 issue 到 RF 的实际发射吞吐。 | 低宽度多时查 RF fail、IQ not-ready、端口冲突。 |
| 73 | `rf_launch_width5_cycle` | IDU/IQ/RF | RF launch 当周期成功发射宽度为 5 的周期数。 | 判断 issue 到 RF 的实际发射吞吐。 | 低宽度多时查 RF fail、IQ not-ready、端口冲突。 |
| 74 | `rf_launch_width6_cycle` | IDU/IQ/RF | RF launch 当周期成功发射宽度为 6 的周期数。 | 判断 issue 到 RF 的实际发射吞吐。 | 低宽度多时查 RF fail、IQ not-ready、端口冲突。 |
| 75 | `rf_launch_width7_cycle` | IDU/IQ/RF | RF launch 当周期成功发射宽度为 7 的周期数。 | 判断 issue 到 RF 的实际发射吞吐。 | 低宽度多时查 RF fail、IQ not-ready、端口冲突。 |
| 76 | `rf_launch_width8_cycle` | IDU/IQ/RF | RF launch 当周期成功发射宽度为 8 的周期数。 | 判断 issue 到 RF 的实际发射吞吐。 | 低宽度多时查 RF fail、IQ not-ready、端口冲突。 |
| 77 | `retire_width0_cycle` | RTU/PST/退休 | 退休宽度为 0 的周期数。 | 判断最终提交吞吐；width0 是 zero-retire 周期。 | 性能分析最重要的终端指标之一。 |
| 78 | `retire_width1_cycle` | RTU/PST/退休 | 退休宽度为 1 的周期数。 | 判断最终提交吞吐；width0 是 zero-retire 周期。 | 性能分析最重要的终端指标之一。 |
| 79 | `retire_width2_cycle` | RTU/PST/退休 | 退休宽度为 2 的周期数。 | 判断最终提交吞吐；width0 是 zero-retire 周期。 | 性能分析最重要的终端指标之一。 |
| 80 | `retire_width3_cycle` | RTU/PST/退休 | 退休宽度为 3 的周期数。 | 判断最终提交吞吐；width0 是 zero-retire 周期。 | 性能分析最重要的终端指标之一。 |
| 81 | `rob_empty` | RTU/PST/退休 | ROB 为空的周期。 | 判断后端窗口是否被前端供给不足清空。 | 和 FE stall、flush 一起看。 |
| 82 | `rob_full_dbg` | RTU/PST/退休 | ROB 占用或满状态桶。 | 判断乱序窗口容量压力。 | 若 ROB 满不高，扩大窗口不是第一方向。 |
| 83 | `rob_occ_ge32` | RTU/PST/退休 | ROB 占用或满状态桶。 | 判断乱序窗口容量压力。 | 若 ROB 满不高，扩大窗口不是第一方向。 |
| 84 | `rob_occ_ge64` | RTU/PST/退休 | ROB 占用或满状态桶。 | 判断乱序窗口容量压力。 | 若 ROB 满不高，扩大窗口不是第一方向。 |
| 85 | `rob_occ_ge96` | RTU/PST/退休 | ROB 占用或满状态桶。 | 判断乱序窗口容量压力。 | 若 ROB 满不高，扩大窗口不是第一方向。 |
| 86 | `is_iq_full` | IDU/IQ/RF | IDU issue queue 总体 full 状态。 | 判断 dispatch 是否被 IQ 容量阻塞。 | 需拆到 AIQ/BIQ/LSIQ/SDIQ/VIQ。 |
| 87 | `is_vmb_full` | IDU/IQ/RF | VMB/向量相关 buffer full 状态。 | 判断向量/浮点路径是否阻塞 dispatch。 | 主要用于 FP/Vector case。 |
| 88 | `aiq0_empty` | IDU/IQ/RF | 整数 issue queue AIQ0 为空 的周期。 | 判断具体 issue queue 的占用压力。 | empty 高可能是供给不足，full 高可能是后端消费不足。 |
| 89 | `aiq0_full` | IDU/IQ/RF | 整数 issue queue AIQ0 满 的周期。 | 判断具体 issue queue 的占用压力。 | empty 高可能是供给不足，full 高可能是后端消费不足。 |
| 90 | `aiq1_empty` | IDU/IQ/RF | 整数 issue queue AIQ1 为空 的周期。 | 判断具体 issue queue 的占用压力。 | empty 高可能是供给不足，full 高可能是后端消费不足。 |
| 91 | `aiq1_full` | IDU/IQ/RF | 整数 issue queue AIQ1 满 的周期。 | 判断具体 issue queue 的占用压力。 | empty 高可能是供给不足，full 高可能是后端消费不足。 |
| 92 | `biq_empty` | IDU/IQ/RF | 分支 issue queue BIQ 为空 的周期。 | 判断具体 issue queue 的占用压力。 | empty 高可能是供给不足，full 高可能是后端消费不足。 |
| 93 | `biq_full` | IDU/IQ/RF | 分支 issue queue BIQ 满 的周期。 | 判断具体 issue queue 的占用压力。 | empty 高可能是供给不足，full 高可能是后端消费不足。 |
| 94 | `lsiq_empty` | IDU/IQ/RF | load issue queue LSIQ 为空 的周期。 | 判断具体 issue queue 的占用压力。 | empty 高可能是供给不足，full 高可能是后端消费不足。 |
| 95 | `lsiq_full` | IDU/IQ/RF | load issue queue LSIQ 满 的周期。 | 判断具体 issue queue 的占用压力。 | empty 高可能是供给不足，full 高可能是后端消费不足。 |
| 96 | `sdiq_empty` | IDU/IQ/RF | store issue queue SDIQ 为空 的周期。 | 判断具体 issue queue 的占用压力。 | empty 高可能是供给不足，full 高可能是后端消费不足。 |
| 97 | `sdiq_full` | IDU/IQ/RF | store issue queue SDIQ 满 的周期。 | 判断具体 issue queue 的占用压力。 | empty 高可能是供给不足，full 高可能是后端消费不足。 |
| 98 | `viq0_empty` | IDU/IQ/RF | 向量/浮点 issue queue VIQ0 为空 的周期。 | 判断具体 issue queue 的占用压力。 | empty 高可能是供给不足，full 高可能是后端消费不足。 |
| 99 | `viq0_full` | IDU/IQ/RF | 向量/浮点 issue queue VIQ0 满 的周期。 | 判断具体 issue queue 的占用压力。 | empty 高可能是供给不足，full 高可能是后端消费不足。 |
| 100 | `viq1_empty` | IDU/IQ/RF | 向量/浮点 issue queue VIQ1 为空 的周期。 | 判断具体 issue queue 的占用压力。 | empty 高可能是供给不足，full 高可能是后端消费不足。 |
| 101 | `viq1_full` | IDU/IQ/RF | 向量/浮点 issue queue VIQ1 满 的周期。 | 判断具体 issue queue 的占用压力。 | empty 高可能是供给不足，full 高可能是后端消费不足。 |
| 102 | `retire_condbr_slot0` | RTU/PST/退休 | 退休槽位 0。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 该槽退休 条件分支 指令。 | 统计分支指令在退休流中的分布。 | 用于计算分支密度和 slot 分布。 |
| 103 | `retire_condbr_slot1` | RTU/PST/退休 | 退休槽位 1。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 该槽退休 条件分支 指令。 | 统计分支指令在退休流中的分布。 | 用于计算分支密度和 slot 分布。 |
| 104 | `retire_condbr_slot2` | RTU/PST/退休 | 退休槽位 2。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 该槽退休 条件分支 指令。 | 统计分支指令在退休流中的分布。 | 用于计算分支密度和 slot 分布。 |
| 105 | `retire_jmp_slot0` | RTU/PST/退休 | 退休槽位 0。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 该槽退休 跳转 指令。 | 统计分支指令在退休流中的分布。 | 用于计算分支密度和 slot 分布。 |
| 106 | `retire_jmp_slot1` | RTU/PST/退休 | 退休槽位 1。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 该槽退休 跳转 指令。 | 统计分支指令在退休流中的分布。 | 用于计算分支密度和 slot 分布。 |
| 107 | `retire_jmp_slot2` | RTU/PST/退休 | 退休槽位 2。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 该槽退休 跳转 指令。 | 统计分支指令在退休流中的分布。 | 用于计算分支密度和 slot 分布。 |
| 108 | `retire_bht_mispred` | RTU/PST/退休 | 退休侧确认的 BHT 条件分支误预测。 | 评估方向预测错误。 | 分母应使用条件分支退休数。 |
| 109 | `retire_jmp_mispred` | RTU/PST/退休 | 退休侧确认的 jump/间接跳转误预测。 | 评估目标或间接跳转预测质量。 | 样本少时百分比可能夸大。 |
| 110 | `ifu_retire0_condbr` | IFU/分支 | IFU 侧 retire0 分支相关统计。 | 观察前端记录的首槽分支和误预测事件。 | 与 retire_* 指标交叉校验。 |
| 111 | `ifu_retire0_condbr_taken` | IFU/分支 | IFU 侧 retire0 分支相关统计。 | 观察前端记录的首槽分支和误预测事件。 | 与 retire_* 指标交叉校验。 |
| 112 | `ifu_retire0_mispred` | IFU/分支 | IFU 侧 retire0 分支相关统计。 | 观察前端记录的首槽分支和误预测事件。 | 与 retire_* 指标交叉校验。 |
| 113 | `ifu_retire0_jmp_mispred` | IFU/分支 | IFU 侧 retire0 分支相关统计。 | 观察前端记录的首槽分支和误预测事件。 | 与 retire_* 指标交叉校验。 |
| 114 | `nospec_miss_any` | IU/预测校验 | no-spec 或 value/valid-prediction 相关 miss/mispred 事件。 | 判断特殊预测/非投机机制是否触发。 | 当前 benchmark 中通常较低，若高需查对应机制。 |
| 115 | `nospec_mispred_any` | IU/预测校验 | no-spec 或 value/valid-prediction 相关 miss/mispred 事件。 | 判断特殊预测/非投机机制是否触发。 | 当前 benchmark 中通常较低，若高需查对应机制。 |
| 116 | `vl_miss_inst0` | IU/预测校验 | no-spec 或 value/valid-prediction 相关 miss/mispred 事件。 | 判断特殊预测/非投机机制是否触发。 | 当前 benchmark 中通常较低，若高需查对应机制。 |
| 117 | `vl_mispred_inst0` | IU/预测校验 | no-spec 或 value/valid-prediction 相关 miss/mispred 事件。 | 判断特殊预测/非投机机制是否触发。 | 当前 benchmark 中通常较低，若高需查对应机制。 |
| 118 | `iu_idu_mispred_stall` | IU/预测校验 | IU 误预测导致 IDU stall。 | 衡量分支修正对后端前段的阻塞。 | 和 bht/jmp mispred 共同分析。 |
| 119 | `iu_ifu_mispred_stall` | IU/预测校验 | IU 误预测导致 IFU stall。 | 衡量分支修正对取指恢复的影响。 | 恢复延迟看 mispred_to_fetch。 |
| 120 | `iu_bht_mispred` | IU/预测校验 | IU/BJU 侧 BHT 误预测事件。 | 观察执行侧确认的方向预测错误。 | 和 retire_bht_mispred 口径可能不同。 |
| 121 | `iu_jmp_mispred` | IU/预测校验 | IU/BJU 侧 jump 误预测事件。 | 观察执行侧确认的目标/跳转错误。 | 和 indirect BTB/L0 BTB 一起看。 |
| 122 | `icache_refill_pre` | IFU/分支 | I-cache refill/miss/reissue/busy 相关事件。 | 判断取指 cache miss、refill 和重发是否造成前端停顿。 | miss 低而 FE 高时，前端瓶颈多半不是 I-cache 容量。 |
| 123 | `icache_refill_reissue` | IFU/分支 | I-cache refill/miss/reissue/busy 相关事件。 | 判断取指 cache miss、refill 和重发是否造成前端停顿。 | miss 低而 FE 高时，前端瓶颈多半不是 I-cache 容量。 |
| 124 | `icache_refill_busy` | IFU/分支 | I-cache refill/miss/reissue/busy 相关事件。 | 判断取指 cache miss、refill 和重发是否造成前端停顿。 | miss 低而 FE 高时，前端瓶颈多半不是 I-cache 容量。 |
| 125 | `icache_miss_under_refill` | IFU/分支 | I-cache refill/miss/reissue/busy 相关事件。 | 判断取指 cache miss、refill 和重发是否造成前端停顿。 | miss 低而 FE 高时，前端瓶颈多半不是 I-cache 容量。 |
| 126 | `icache_way_mispred_reissue` | IFU/分支 | I-cache refill/miss/reissue/busy 相关事件。 | 判断取指 cache miss、refill 和重发是否造成前端停顿。 | miss 低而 FE 高时，前端瓶颈多半不是 I-cache 容量。 |
| 127 | `ifu_bry_missigned_stall` | IFU/分支 | IFU buffer、BTB 或多分支取指相关事件。 | 分析前端供给、目标预测、buffer 创建/释放和多分支限制。 | 需区分真实前端不足和后端反压。 |
| 128 | `ifu_multi_branch_stall` | IFU/分支 | IFU buffer、BTB 或多分支取指相关事件。 | 分析前端供给、目标预测、buffer 创建/释放和多分支限制。 | 需区分真实前端不足和后端反压。 |
| 129 | `dcache_read_access` | LSU/Cache | D-cache read access 次数。 | 计算 load/cache 访问强度。 | 和 read miss 组成 miss rate。 |
| 130 | `dcache_read_miss` | LSU/Cache | D-cache read miss 次数。 | 判断 load miss 压力。 | miss 低但 LSU stall 高时，瓶颈在 LSU 内部而非 cache 容量。 |
| 131 | `dcache_write_access` | LSU/Cache | D-cache write access 次数。 | 计算 store/cache 写访问强度。 | 和 write miss 配合看。 |
| 132 | `dcache_write_miss` | LSU/Cache | D-cache write miss 次数。 | 判断 store miss 压力。 | store miss 低不代表 store pipeline 无瓶颈。 |
| 133 | `ld_utlb_miss` | LSU/Cache | TLB miss 侧事件。 | 判断地址翻译是否造成前端或 LSU 停顿。 | bare-metal 恒等映射下需注意信号口径。 |
| 134 | `st_utlb_miss` | LSU/Cache | TLB miss 侧事件。 | 判断地址翻译是否造成前端或 LSU 停顿。 | bare-metal 恒等映射下需注意信号口径。 |
| 135 | `ld_da_dcache_miss_raw` | LSU/Cache | LSU DA 阶段观测到的 D-cache miss raw 事件。 | 定位 DA 侧 miss 压力。 | raw 口径可能与汇总 miss 分母不同。 |
| 136 | `st_da_dcache_miss_raw` | LSU/Cache | LSU DA 阶段观测到的 D-cache miss raw 事件。 | 定位 DA 侧 miss 压力。 | raw 口径可能与汇总 miss 分母不同。 |
| 137 | `lq_full_raw` | LSU/Cache | LSU 队列或 buffer full raw 状态。 | 判断访存子系统结构资源是否堵塞。 | 高时继续查对应 queue 生命周期。 |
| 138 | `sq_full_raw` | LSU/Cache | LSU 队列或 buffer full raw 状态。 | 判断访存子系统结构资源是否堵塞。 | 高时继续查对应 queue 生命周期。 |
| 139 | `rb_full_raw` | LSU/Cache | LSU 队列或 buffer full raw 状态。 | 判断访存子系统结构资源是否堵塞。 | 高时继续查对应 queue 生命周期。 |
| 140 | `lfb_addr_full` | LSU/Cache | LSU 队列或 buffer full raw 状态。 | 判断访存子系统结构资源是否堵塞。 | 高时继续查对应 queue 生命周期。 |
| 141 | `wmb_bytes_full` | LSU/Cache | LSU 队列或 buffer full raw 状态。 | 判断访存子系统结构资源是否堵塞。 | 高时继续查对应 queue 生命周期。 |
| 142 | `pipe0_inst_vld` | 执行单元 | 整数/分支相关执行 pipe0 有有效指令。 | 观察执行 pipe 利用率。 | 需要和发射宽度、stall、完成信号结合。 |
| 143 | `pipe1_inst_vld` | 执行单元 | 整数/乘法相关执行 pipe1 有有效指令。 | 观察执行 pipe 利用率。 | 需要和发射宽度、stall、完成信号结合。 |
| 144 | `pipe2_inst_vld` | 执行单元 | 整数执行 pipe2 有有效指令。 | 观察执行 pipe 利用率。 | 需要和发射宽度、stall、完成信号结合。 |
| 145 | `pipe3_inst_vld` | 执行单元 | load 地址/访存相关 pipe3 有有效指令。 | 观察执行 pipe 利用率。 | 需要和发射宽度、stall、完成信号结合。 |
| 146 | `pipe4_inst_vld` | 执行单元 | 向量/浮点相关 pipe4 有有效指令。 | 观察执行 pipe 利用率。 | 需要和发射宽度、stall、完成信号结合。 |
| 147 | `mult_pipe1_stall` | 执行单元 | 乘法 pipe1 stall。 | 判断乘法执行单元是否阻塞整数路径。 | 结合指令 mix 和 pipe1 valid。 |
| 148 | `div_wb_stall` | 执行单元 | 除法写回 stall。 | 判断除法长延迟或写回冲突。 | 通常只在除法密集 case 显著。 |
| 149 | `pipe5_inst_vld` | 执行单元 | store 地址/访存相关 pipe5 有有效指令。 | 观察执行 pipe 利用率。 | 需要和发射宽度、stall、完成信号结合。 |
| 150 | `pipe6_inst_vld` | 执行单元 | VFPU pipe6 有有效指令。 | 观察执行 pipe 利用率。 | 需要和发射宽度、stall、完成信号结合。 |
| 151 | `pipe7_inst_vld` | 执行单元 | VFPU pipe7 有有效指令。 | 观察执行 pipe 利用率。 | 需要和发射宽度、stall、完成信号结合。 |
| 152 | `ifu_ibuf_create` | IFU/分支 | IFU buffer、BTB 或多分支取指相关事件。 | 分析前端供给、目标预测、buffer 创建/释放和多分支限制。 | 需区分真实前端不足和后端反压。 |
| 153 | `ifu_ibuf_retire` | IFU/分支 | IFU buffer、BTB 或多分支取指相关事件。 | 分析前端供给、目标预测、buffer 创建/释放和多分支限制。 | 需区分真实前端不足和后端反压。 |
| 154 | `ifu_lbuf_create` | IFU/分支 | IFU buffer、BTB 或多分支取指相关事件。 | 分析前端供给、目标预测、buffer 创建/释放和多分支限制。 | 需区分真实前端不足和后端反压。 |
| 155 | `ifu_lbuf_retire` | IFU/分支 | IFU buffer、BTB 或多分支取指相关事件。 | 分析前端供给、目标预测、buffer 创建/释放和多分支限制。 | 需区分真实前端不足和后端反压。 |
| 156 | `ifu_bypass_inst_vld` | IFU/分支 | IFU buffer、BTB 或多分支取指相关事件。 | 分析前端供给、目标预测、buffer 创建/释放和多分支限制。 | 需区分真实前端不足和后端反压。 |
| 157 | `ifu_merge_inst_vld` | IFU/分支 | IFU buffer、BTB 或多分支取指相关事件。 | 分析前端供给、目标预测、buffer 创建/释放和多分支限制。 | 需区分真实前端不足和后端反压。 |
| 158 | `ifu_pcfifo_create` | IFU/分支 | IFU buffer、BTB 或多分支取指相关事件。 | 分析前端供给、目标预测、buffer 创建/释放和多分支限制。 | 需区分真实前端不足和后端反压。 |
| 159 | `ifu_ind_btb_miss` | IFU/分支 | IFU buffer、BTB 或多分支取指相关事件。 | 分析前端供给、目标预测、buffer 创建/释放和多分支限制。 | 需区分真实前端不足和后端反压。 |
| 160 | `ifu_ind_btb_rd_stall` | IFU/分支 | IFU buffer、BTB 或多分支取指相关事件。 | 分析前端供给、目标预测、buffer 创建/释放和多分支限制。 | 需区分真实前端不足和后端反压。 |
| 161 | `ifu_btb_miss` | IFU/分支 | IFU buffer、BTB 或多分支取指相关事件。 | 分析前端供给、目标预测、buffer 创建/释放和多分支限制。 | 需区分真实前端不足和后端反压。 |
| 162 | `ifu_l0_btb_miss` | IFU/分支 | IFU buffer、BTB 或多分支取指相关事件。 | 分析前端供给、目标预测、buffer 创建/释放和多分支限制。 | 需区分真实前端不足和后端反压。 |
| 163 | `ras_push` | IFU/分支 | RAS 返回地址栈活动或状态。 | 判断 call/return 预测、栈空/满和重定向情况。 | 不是完整 RAS 准确率，需要分母。 |
| 164 | `ras_pop` | IFU/分支 | RAS 返回地址栈活动或状态。 | 判断 call/return 预测、栈空/满和重定向情况。 | 不是完整 RAS 准确率，需要分母。 |
| 165 | `ras_empty` | IFU/分支 | RAS 返回地址栈活动或状态。 | 判断 call/return 预测、栈空/满和重定向情况。 | 不是完整 RAS 准确率，需要分母。 |
| 166 | `ras_full` | IFU/分支 | RAS 返回地址栈活动或状态。 | 判断 call/return 预测、栈空/满和重定向情况。 | 不是完整 RAS 准确率，需要分母。 |
| 167 | `bht_wrbuf_create` | IFU/分支 | BHT 预测表或写缓冲活动。 | 分析方向预测读、选择、更新缓冲和 BJU 误预测。 | 不是完整 BHT 准确率。 |
| 168 | `bht_wrbuf_retire` | IFU/分支 | BHT 预测表或写缓冲活动。 | 分析方向预测读、选择、更新缓冲和 BJU 误预测。 | 不是完整 BHT 准确率。 |
| 169 | `bht_wrbuf_create_slot_full` | IFU/分支 | BHT 预测表或写缓冲活动。 | 分析方向预测读、选择、更新缓冲和 BJU 误预测。 | 不是完整 BHT 准确率。 |
| 170 | `bht_wrbuf_not_empty` | IFU/分支 | BHT 预测表或写缓冲活动。 | 分析方向预测读、选择、更新缓冲和 BJU 误预测。 | 不是完整 BHT 准确率。 |
| 171 | `icache_refill_start` | IFU/分支 | I-cache refill/miss/reissue/busy 相关事件。 | 判断取指 cache miss、refill 和重发是否造成前端停顿。 | miss 低而 FE 高时，前端瓶颈多半不是 I-cache 容量。 |
| 172 | `icache_refill_cmplt` | IFU/分支 | I-cache refill/miss/reissue/busy 相关事件。 | 判断取指 cache miss、refill 和重发是否造成前端停顿。 | miss 低而 FE 高时，前端瓶颈多半不是 I-cache 容量。 |
| 173 | `icache_refill_data_vld` | IFU/分支 | I-cache refill/miss/reissue/busy 相关事件。 | 判断取指 cache miss、refill 和重发是否造成前端停顿。 | miss 低而 FE 高时，前端瓶颈多半不是 I-cache 容量。 |
| 174 | `icache_refill_trans_err` | IFU/分支 | I-cache refill/miss/reissue/busy 相关事件。 | 判断取指 cache miss、refill 和重发是否造成前端停顿。 | miss 低而 FE 高时，前端瓶颈多半不是 I-cache 容量。 |
| 175 | `icache_refill_on` | IFU/分支 | I-cache refill/miss/reissue/busy 相关事件。 | 判断取指 cache miss、refill 和重发是否造成前端停顿。 | miss 低而 FE 高时，前端瓶颈多半不是 I-cache 容量。 |
| 176 | `icache_refill_chgflw` | IFU/分支 | I-cache refill/miss/reissue/busy 相关事件。 | 判断取指 cache miss、refill 和重发是否造成前端停顿。 | miss 低而 FE 高时，前端瓶颈多半不是 I-cache 容量。 |
| 177 | `retire_load_any` | RTU/PST/退休 | 退休侧指令属性或事件统计。 | 分析指令 mix、写回类型、特殊预测命中/失败。 | 按退休指令口径，适合作分母。 |
| 178 | `retire_store_any` | RTU/PST/退休 | 退休侧指令属性或事件统计。 | 分析指令 mix、写回类型、特殊预测命中/失败。 | 按退休指令口径，适合作分母。 |
| 179 | `retire_split_any` | RTU/PST/退休 | 退休侧指令属性或事件统计。 | 分析指令 mix、写回类型、特殊预测命中/失败。 | 按退休指令口径，适合作分母。 |
| 180 | `retire_preg_write_any` | RTU/PST/退休 | 退休侧指令属性或事件统计。 | 分析指令 mix、写回类型、特殊预测命中/失败。 | 按退休指令口径，适合作分母。 |
| 181 | `retire_vreg_write_any` | RTU/PST/退休 | 退休侧指令属性或事件统计。 | 分析指令 mix、写回类型、特殊预测命中/失败。 | 按退休指令口径，适合作分母。 |
| 182 | `retire_ereg_write_any` | RTU/PST/退休 | 退休侧指令属性或事件统计。 | 分析指令 mix、写回类型、特殊预测命中/失败。 | 按退休指令口径，适合作分母。 |
| 183 | `retire_nospec_hit_any` | RTU/PST/退休 | 退休侧指令属性或事件统计。 | 分析指令 mix、写回类型、特殊预测命中/失败。 | 按退休指令口径，适合作分母。 |
| 184 | `retire_nospec_miss_any` | RTU/PST/退休 | 退休侧指令属性或事件统计。 | 分析指令 mix、写回类型、特殊预测命中/失败。 | 按退休指令口径，适合作分母。 |
| 185 | `retire_nospec_misp_any` | RTU/PST/退休 | 退休侧指令属性或事件统计。 | 分析指令 mix、写回类型、特殊预测命中/失败。 | 按退休指令口径，适合作分母。 |
| 186 | `retire_vl_pred_any` | RTU/PST/退休 | 退休侧指令属性或事件统计。 | 分析指令 mix、写回类型、特殊预测命中/失败。 | 按退休指令口径，适合作分母。 |
| 187 | `rob_head_valid` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 188 | `rob_head_load` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 189 | `rob_head_store` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 190 | `rob_head_bju` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 191 | `rob_head_condbr` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 192 | `rob_head_jmp` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 193 | `rob_head_expt` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 194 | `rob_head_int` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 195 | `rob_head_spec_fail` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 196 | `lq_create0` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 197 | `lq_create1` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 198 | `sq_wmb_pop_to_ce_req` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 199 | `wmb_ce_create` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 200 | `wmb_ce_pop` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 201 | `wmb_write_biu_req` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 202 | `wmb_write_stall` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 203 | `wmb_merge_data_stall` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 204 | `wmb_ld_dc_discard` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 205 | `rb_biu_ar_req` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 206 | `rb_lfb_create_req` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 207 | `rb_ld_da_full` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 208 | `rb_st_da_full` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 209 | `lfb_data_full` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 210 | `lfb_data_wait_surplus` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 211 | `lfb_addr_empty` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 212 | `lfb_data_empty` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 213 | `biu_arvalid` | BIU/AXI | BIU/AXI 通道 valid/ready/busy 状态。 | 判断总线请求、响应和写通道活动。 | 结合 backpressure、handshake、latency 使用。 |
| 214 | `biu_ar_handshake` | BIU/AXI | BIU/AXI 通道握手事件。 | 统计外部读写请求或响应实际完成。 | AR/RLAST/AW/B 成对分析。 |
| 215 | `biu_ar_backpressure` | BIU/AXI | BIU/AXI 通道 valid 但未握手的反压周期。 | 判断外部总线 ready/response 是否限制访存。 | 需结合 handshake 和 latency；不要只看单项。 |
| 216 | `biu_rvalid` | BIU/AXI | BIU/AXI 通道 valid/ready/busy 状态。 | 判断总线请求、响应和写通道活动。 | 结合 backpressure、handshake、latency 使用。 |
| 217 | `biu_r_backpressure` | BIU/AXI | BIU/AXI 通道 valid 但未握手的反压周期。 | 判断外部总线 ready/response 是否限制访存。 | 需结合 handshake 和 latency；不要只看单项。 |
| 218 | `biu_awvalid` | BIU/AXI | BIU/AXI 通道 valid/ready/busy 状态。 | 判断总线请求、响应和写通道活动。 | 结合 backpressure、handshake、latency 使用。 |
| 219 | `biu_wvalid` | BIU/AXI | BIU/AXI 通道 valid/ready/busy 状态。 | 判断总线请求、响应和写通道活动。 | 结合 backpressure、handshake、latency 使用。 |
| 220 | `biu_bvalid` | BIU/AXI | BIU/AXI 通道 valid/ready/busy 状态。 | 判断总线请求、响应和写通道活动。 | 结合 backpressure、handshake、latency 使用。 |
| 221 | `biu_r_handshake` | BIU/AXI | BIU/AXI 通道握手事件。 | 统计外部读写请求或响应实际完成。 | AR/RLAST/AW/B 成对分析。 |
| 222 | `biu_rready` | BIU/AXI | BIU/AXI 通道 valid/ready/busy 状态。 | 判断总线请求、响应和写通道活动。 | 结合 backpressure、handshake、latency 使用。 |
| 223 | `biu_aw_handshake` | BIU/AXI | BIU/AXI 通道握手事件。 | 统计外部读写请求或响应实际完成。 | AR/RLAST/AW/B 成对分析。 |
| 224 | `biu_aw_backpressure` | BIU/AXI | BIU/AXI 通道 valid 但未握手的反压周期。 | 判断外部总线 ready/response 是否限制访存。 | 需结合 handshake 和 latency；不要只看单项。 |
| 225 | `biu_w_handshake` | BIU/AXI | BIU/AXI 通道握手事件。 | 统计外部读写请求或响应实际完成。 | AR/RLAST/AW/B 成对分析。 |
| 226 | `biu_w_backpressure` | BIU/AXI | BIU/AXI 通道 valid 但未握手的反压周期。 | 判断外部总线 ready/response 是否限制访存。 | 需结合 handshake 和 latency；不要只看单项。 |
| 227 | `biu_bready` | BIU/AXI | BIU/AXI 通道 valid/ready/busy 状态。 | 判断总线请求、响应和写通道活动。 | 结合 backpressure、handshake、latency 使用。 |
| 228 | `biu_b_handshake` | BIU/AXI | BIU/AXI 通道握手事件。 | 统计外部读写请求或响应实际完成。 | AR/RLAST/AW/B 成对分析。 |
| 229 | `biu_b_backpressure` | BIU/AXI | BIU/AXI 通道 valid 但未握手的反压周期。 | 判断外部总线 ready/response 是否限制访存。 | 需结合 handshake 和 latency；不要只看单项。 |
| 230 | `biu_st_awvalid` | BIU/AXI | BIU/AXI 通道 valid/ready/busy 状态。 | 判断总线请求、响应和写通道活动。 | 结合 backpressure、handshake、latency 使用。 |
| 231 | `biu_st_aw_stall` | BIU/AXI | BIU/AXI 通道 valid 但未握手的反压周期。 | 判断外部总线 ready/response 是否限制访存。 | 需结合 handshake 和 latency；不要只看单项。 |
| 232 | `biu_vict_awvalid` | BIU/AXI | BIU/AXI 通道 valid/ready/busy 状态。 | 判断总线请求、响应和写通道活动。 | 结合 backpressure、handshake、latency 使用。 |
| 233 | `biu_vict_aw_stall` | BIU/AXI | BIU/AXI 通道 valid 但未握手的反压周期。 | 判断外部总线 ready/response 是否限制访存。 | 需结合 handshake 和 latency；不要只看单项。 |
| 234 | `biu_st_wvalid` | BIU/AXI | BIU/AXI 通道 valid/ready/busy 状态。 | 判断总线请求、响应和写通道活动。 | 结合 backpressure、handshake、latency 使用。 |
| 235 | `biu_st_w_stall` | BIU/AXI | BIU/AXI 通道 valid 但未握手的反压周期。 | 判断外部总线 ready/response 是否限制访存。 | 需结合 handshake 和 latency；不要只看单项。 |
| 236 | `biu_vict_wvalid` | BIU/AXI | BIU/AXI 通道 valid/ready/busy 状态。 | 判断总线请求、响应和写通道活动。 | 结合 backpressure、handshake、latency 使用。 |
| 237 | `biu_vict_w_stall` | BIU/AXI | BIU/AXI 通道 valid 但未握手的反压周期。 | 判断外部总线 ready/response 是否限制访存。 | 需结合 handshake 和 latency；不要只看单项。 |
| 238 | `biu_write_busy` | BIU/AXI | BIU/AXI 通道 valid/ready/busy 状态。 | 判断总线请求、响应和写通道活动。 | 结合 backpressure、handshake、latency 使用。 |
| 239 | `retire_s0_valid` | RTU/PST/退休 | 退休槽位 0。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `valid`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 240 | `retire_s1_valid` | RTU/PST/退休 | 退休槽位 1。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `valid`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 241 | `retire_s2_valid` | RTU/PST/退休 | 退休槽位 2。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `valid`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 242 | `retire_s0_load` | RTU/PST/退休 | 退休槽位 0。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `load`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 243 | `retire_s1_load` | RTU/PST/退休 | 退休槽位 1。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `load`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 244 | `retire_s2_load` | RTU/PST/退休 | 退休槽位 2。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `load`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 245 | `retire_s0_store` | RTU/PST/退休 | 退休槽位 0。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `store`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 246 | `retire_s1_store` | RTU/PST/退休 | 退休槽位 1。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `store`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 247 | `retire_s2_store` | RTU/PST/退休 | 退休槽位 2。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `store`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 248 | `retire_s0_bju` | RTU/PST/退休 | 退休槽位 0。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `bju`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 249 | `retire_s1_bju` | RTU/PST/退休 | 退休槽位 1。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `bju`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 250 | `retire_s2_bju` | RTU/PST/退休 | 退休槽位 2。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `bju`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 251 | `retire_s0_condbr` | RTU/PST/退休 | 退休槽位 0。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `condbr`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 252 | `retire_s1_condbr` | RTU/PST/退休 | 退休槽位 1。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `condbr`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 253 | `retire_s2_condbr` | RTU/PST/退休 | 退休槽位 2。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `condbr`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 254 | `retire_s0_jmp` | RTU/PST/退休 | 退休槽位 0。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `jmp`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 255 | `retire_s1_jmp` | RTU/PST/退休 | 退休槽位 1。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `jmp`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 256 | `retire_s2_jmp` | RTU/PST/退休 | 退休槽位 2。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `jmp`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 257 | `retire_s0_split` | RTU/PST/退休 | 退休槽位 0。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `split`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 258 | `retire_s1_split` | RTU/PST/退休 | 退休槽位 1。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `split`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 259 | `retire_s2_split` | RTU/PST/退休 | 退休槽位 2。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `split`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 260 | `retire_s0_preg_write` | RTU/PST/退休 | 退休槽位 0。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `preg_write`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 261 | `retire_s1_preg_write` | RTU/PST/退休 | 退休槽位 1。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `preg_write`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 262 | `retire_s2_preg_write` | RTU/PST/退休 | 退休槽位 2。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `preg_write`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 263 | `retire_s0_vreg_write` | RTU/PST/退休 | 退休槽位 0。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `vreg_write`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 264 | `retire_s1_vreg_write` | RTU/PST/退休 | 退休槽位 1。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `vreg_write`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 265 | `retire_s2_vreg_write` | RTU/PST/退休 | 退休槽位 2。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `vreg_write`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 266 | `retire_s0_ereg_write` | RTU/PST/退休 | 退休槽位 0。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `ereg_write`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 267 | `retire_s1_ereg_write` | RTU/PST/退休 | 退休槽位 1。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `ereg_write`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 268 | `retire_s2_ereg_write` | RTU/PST/退休 | 退休槽位 2。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `ereg_write`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 269 | `retire_s0_nospec_hit` | RTU/PST/退休 | 退休槽位 0。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `nospec_hit`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 270 | `retire_s1_nospec_hit` | RTU/PST/退休 | 退休槽位 1。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `nospec_hit`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 271 | `retire_s2_nospec_hit` | RTU/PST/退休 | 退休槽位 2。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `nospec_hit`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 272 | `retire_s0_nospec_miss` | RTU/PST/退休 | 退休槽位 0。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `nospec_miss`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 273 | `retire_s1_nospec_miss` | RTU/PST/退休 | 退休槽位 1。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `nospec_miss`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 274 | `retire_s2_nospec_miss` | RTU/PST/退休 | 退休槽位 2。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `nospec_miss`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 275 | `retire_s0_nospec_misp` | RTU/PST/退休 | 退休槽位 0。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `nospec_misp`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 276 | `retire_s1_nospec_misp` | RTU/PST/退休 | 退休槽位 1。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `nospec_misp`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 277 | `retire_s2_nospec_misp` | RTU/PST/退休 | 退休槽位 2。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `nospec_misp`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 278 | `retire_s0_vl_pred` | RTU/PST/退休 | 退休槽位 0。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `vl_pred`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 279 | `retire_s1_vl_pred` | RTU/PST/退休 | 退休槽位 1。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `vl_pred`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 280 | `retire_s2_vl_pred` | RTU/PST/退休 | 退休槽位 2。C910 每周期最多 3 条退休，slot0/1/2 表示该周期对应退休位置。 退休指令属性 `vl_pred`。 | 统计每个退休槽的指令类别和写回属性。 | 用于指令 mix、slot 利用率和退休宽度分析。 |
| 281 | `cpi_stack_retiring` | RTU/PST/退休 | testbench CPI stack proxy 分类。 | 按 retiring、bad speculation、frontend、memory、backend、unknown 粗分 zero-retire 原因。 | 这是近似归因，不是硬件唯一 root cause。 |
| 282 | `cpi_stack_bad_spec` | RTU/PST/退休 | testbench CPI stack proxy 分类。 | 按 retiring、bad speculation、frontend、memory、backend、unknown 粗分 zero-retire 原因。 | 这是近似归因，不是硬件唯一 root cause。 |
| 283 | `cpi_stack_frontend` | RTU/PST/退休 | testbench CPI stack proxy 分类。 | 按 retiring、bad speculation、frontend、memory、backend、unknown 粗分 zero-retire 原因。 | 这是近似归因，不是硬件唯一 root cause。 |
| 284 | `cpi_stack_memory` | RTU/PST/退休 | testbench CPI stack proxy 分类。 | 按 retiring、bad speculation、frontend、memory、backend、unknown 粗分 zero-retire 原因。 | 这是近似归因，不是硬件唯一 root cause。 |
| 285 | `cpi_stack_backend_core` | RTU/PST/退休 | testbench CPI stack proxy 分类。 | 按 retiring、bad speculation、frontend、memory、backend、unknown 粗分 zero-retire 原因。 | 这是近似归因，不是硬件唯一 root cause。 |
| 286 | `cpi_stack_idle_unknown` | RTU/PST/退休 | testbench CPI stack proxy 分类。 | 按 retiring、bad speculation、frontend、memory、backend、unknown 粗分 zero-retire 原因。 | 这是近似归因，不是硬件唯一 root cause。 |
| 287 | `preg_alloc0_req` | RTU/PST/退休 | preg 分配端口 0 的 req 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 288 | `preg_alloc1_req` | RTU/PST/退休 | preg 分配端口 1 的 req 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 289 | `preg_alloc2_req` | RTU/PST/退休 | preg 分配端口 2 的 req 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 290 | `preg_alloc3_req` | RTU/PST/退休 | preg 分配端口 3 的 req 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 291 | `preg_alloc0_vld` | RTU/PST/退休 | preg 分配端口 0 的 vld 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 292 | `preg_alloc1_vld` | RTU/PST/退休 | preg 分配端口 1 的 vld 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 293 | `preg_alloc2_vld` | RTU/PST/退休 | preg 分配端口 2 的 vld 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 294 | `preg_alloc3_vld` | RTU/PST/退休 | preg 分配端口 3 的 vld 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 295 | `preg_alloc0_block` | RTU/PST/退休 | preg 分配端口 0 的 block 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 296 | `preg_alloc1_block` | RTU/PST/退休 | preg 分配端口 1 的 block 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 297 | `preg_alloc2_block` | RTU/PST/退休 | preg 分配端口 2 的 block 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 298 | `preg_alloc3_block` | RTU/PST/退休 | preg 分配端口 3 的 block 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 299 | `ereg_alloc0_req` | RTU/PST/退休 | ereg 分配端口 0 的 req 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 300 | `ereg_alloc1_req` | RTU/PST/退休 | ereg 分配端口 1 的 req 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 301 | `ereg_alloc2_req` | RTU/PST/退休 | ereg 分配端口 2 的 req 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 302 | `ereg_alloc3_req` | RTU/PST/退休 | ereg 分配端口 3 的 req 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 303 | `ereg_alloc0_vld` | RTU/PST/退休 | ereg 分配端口 0 的 vld 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 304 | `ereg_alloc1_vld` | RTU/PST/退休 | ereg 分配端口 1 的 vld 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 305 | `ereg_alloc2_vld` | RTU/PST/退休 | ereg 分配端口 2 的 vld 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 306 | `ereg_alloc3_vld` | RTU/PST/退休 | ereg 分配端口 3 的 vld 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 307 | `ereg_alloc0_block` | RTU/PST/退休 | ereg 分配端口 0 的 block 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 308 | `ereg_alloc1_block` | RTU/PST/退休 | ereg 分配端口 1 的 block 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 309 | `ereg_alloc2_block` | RTU/PST/退休 | ereg 分配端口 2 的 block 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 310 | `ereg_alloc3_block` | RTU/PST/退休 | ereg 分配端口 3 的 block 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 311 | `freg_vreg_alloc0_req` | RTU/PST/退休 | freg_vreg 分配端口 0 的 req 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 312 | `freg_vreg_alloc1_req` | RTU/PST/退休 | freg_vreg 分配端口 1 的 req 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 313 | `freg_vreg_alloc2_req` | RTU/PST/退休 | freg_vreg 分配端口 2 的 req 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 314 | `freg_vreg_alloc3_req` | RTU/PST/退休 | freg_vreg 分配端口 3 的 req 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 315 | `freg_vreg_alloc0_vld` | RTU/PST/退休 | freg_vreg 分配端口 0 的 vld 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 316 | `freg_vreg_alloc1_vld` | RTU/PST/退休 | freg_vreg 分配端口 1 的 vld 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 317 | `freg_vreg_alloc2_vld` | RTU/PST/退休 | freg_vreg 分配端口 2 的 vld 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 318 | `freg_vreg_alloc3_vld` | RTU/PST/退休 | freg_vreg 分配端口 3 的 vld 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 319 | `freg_vreg_alloc0_block` | RTU/PST/退休 | freg_vreg 分配端口 0 的 block 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 320 | `freg_vreg_alloc1_block` | RTU/PST/退休 | freg_vreg 分配端口 1 的 block 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 321 | `freg_vreg_alloc2_block` | RTU/PST/退休 | freg_vreg 分配端口 2 的 block 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 322 | `freg_vreg_alloc3_block` | RTU/PST/退休 | freg_vreg 分配端口 3 的 block 状态。 | 判断 rename/free-list 申请、可用和阻塞压力。 | block 高才考虑 free-list/物理寄存器容量。 |
| 323 | `preg_pst_empty` | RTU/PST/退休 | PST/free-list 空、恢复或可分配状态。 | 判断物理寄存器资源、flush rollback 和退休回收是否限制 rename。 | 需要和 rename stall 一起看。 |
| 324 | `ereg_pst_empty` | RTU/PST/退休 | PST/free-list 空、恢复或可分配状态。 | 判断物理寄存器资源、flush rollback 和退休回收是否限制 rename。 | 需要和 rename stall 一起看。 |
| 325 | `freg_vreg_pst_empty` | RTU/PST/退休 | PST/free-list 空、恢复或可分配状态。 | 判断物理寄存器资源、flush rollback 和退休回收是否限制 rename。 | 需要和 rename stall 一起看。 |
| 326 | `vfpu_pipe6_issue` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 327 | `vfpu_pipe7_issue` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 328 | `vfpu_pipe6_gateclk_issue` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 329 | `vfpu_pipe7_gateclk_issue` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 330 | `vfpu_vdiv_issue` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 331 | `vfpu_vdiv_gateclk_issue` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 332 | `vfdsu_pipe_busy` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 333 | `vfdsu_ex2_wait` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 334 | `vfdsu_idle` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 335 | `vfpu_ex1_pipe6_data_vld` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 336 | `vfpu_ex1_pipe7_data_vld` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 337 | `vfpu_ex2_pipe6_data_vld` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 338 | `vfpu_ex2_pipe7_data_vld` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 339 | `vfpu_ex3_pipe6_data_vld` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 340 | `vfpu_ex3_pipe7_data_vld` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 341 | `vfpu_ex3_pipe6_fwd_vreg` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 342 | `vfpu_ex3_pipe7_fwd_vreg` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 343 | `vfpu_ex4_pipe6_fwd_vreg` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 344 | `vfpu_ex4_pipe7_fwd_vreg` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 345 | `vfpu_ex5_pipe6_fwd_vreg` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 346 | `vfpu_ex5_pipe7_fwd_vreg` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 347 | `vfpu_pipe6_ereg_wb` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 348 | `vfpu_pipe7_ereg_wb` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 349 | `vfpu_pipe6_vreg_fr_wb` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 350 | `vfpu_pipe7_vreg_fr_wb` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 351 | `vfpu_pipe6_vreg_vr_wb` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 352 | `vfpu_pipe7_vreg_vr_wb` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 353 | `vfpu_pipe6_vmla_no_fwd` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 354 | `vfpu_pipe7_vmla_no_fwd` | VFPU | VFPU/浮点向量执行、前递、写回或除法/开方单元状态。 | 分析 FP/vector case 的执行延迟、busy、forward 和写回压力。 | 整数 benchmark 中通常接近 0。 |
| 355 | `ld_pfu_act` | LSU/Cache | PFU 预取活动、请求、命中或 buffer 状态。 | 判断预取是否产生请求、命中或占用内存系统。 | 预取有效性需和 miss/latency/BIU 一起判断。 |
| 356 | `st_pfu_act` | LSU/Cache | PFU 预取活动、请求、命中或 buffer 状态。 | 判断预取是否产生请求、命中或占用内存系统。 | 预取有效性需和 miss/latency/BIU 一起判断。 |
| 357 | `ld_pfu_pf_inst` | LSU/Cache | PFU 预取活动、请求、命中或 buffer 状态。 | 判断预取是否产生请求、命中或占用内存系统。 | 预取有效性需和 miss/latency/BIU 一起判断。 |
| 358 | `st_pfu_pf_inst` | LSU/Cache | PFU 预取活动、请求、命中或 buffer 状态。 | 判断预取是否产生请求、命中或占用内存系统。 | 预取有效性需和 miss/latency/BIU 一起判断。 |
| 359 | `pfu_biu_ar_req` | LSU/Cache | PFU 预取活动、请求、命中或 buffer 状态。 | 判断预取是否产生请求、命中或占用内存系统。 | 预取有效性需和 miss/latency/BIU 一起判断。 |
| 360 | `pfu_lfb_create_req` | LSU/Cache | PFU 预取活动、请求、命中或 buffer 状态。 | 判断预取是否产生请求、命中或占用内存系统。 | 预取有效性需和 miss/latency/BIU 一起判断。 |
| 361 | `pfu_lfb_create_vld` | LSU/Cache | PFU 预取活动、请求、命中或 buffer 状态。 | 判断预取是否产生请求、命中或占用内存系统。 | 预取有效性需和 miss/latency/BIU 一起判断。 |
| 362 | `pfu_biu_req_unmask` | LSU/Cache | PFU 预取活动、请求、命中或 buffer 状态。 | 判断预取是否产生请求、命中或占用内存系统。 | 预取有效性需和 miss/latency/BIU 一起判断。 |
| 363 | `pfu_biu_req_hit_idx` | LSU/Cache | PFU 预取活动、请求、命中或 buffer 状态。 | 判断预取是否产生请求、命中或占用内存系统。 | 预取有效性需和 miss/latency/BIU 一起判断。 |
| 364 | `pfu_pfb_empty` | LSU/Cache | PFU 预取活动、请求、命中或 buffer 状态。 | 判断预取是否产生请求、命中或占用内存系统。 | 预取有效性需和 miss/latency/BIU 一起判断。 |
| 365 | `pfu_sdb_empty` | LSU/Cache | PFU 预取活动、请求、命中或 buffer 状态。 | 判断预取是否产生请求、命中或占用内存系统。 | 预取有效性需和 miss/latency/BIU 一起判断。 |
| 366 | `pfu_pmb_empty` | LSU/Cache | PFU 预取活动、请求、命中或 buffer 状态。 | 判断预取是否产生请求、命中或占用内存系统。 | 预取有效性需和 miss/latency/BIU 一起判断。 |
| 367 | `pfu_part_empty` | LSU/Cache | PFU 预取活动、请求、命中或 buffer 状态。 | 判断预取是否产生请求、命中或占用内存系统。 | 预取有效性需和 miss/latency/BIU 一起判断。 |
| 368 | `pfu_pop_all` | LSU/Cache | PFU 预取活动、请求、命中或 buffer 状态。 | 判断预取是否产生请求、命中或占用内存系统。 | 预取有效性需和 miss/latency/BIU 一起判断。 |
| 369 | `pfu_biu_pe_grnt` | LSU/Cache | PFU 预取活动、请求、命中或 buffer 状态。 | 判断预取是否产生请求、命中或占用内存系统。 | 预取有效性需和 miss/latency/BIU 一起判断。 |
| 370 | `vb_empty` | LSU/Cache | Victim buffer 创建、满、请求或 D-cache 访问状态。 | 判断替换/回写路径是否产生压力。 | 和 WMB/BIU 写通道一起看。 |
| 371 | `vb_addr_full` | LSU/Cache | Victim buffer 创建、满、请求或 D-cache 访问状态。 | 判断替换/回写路径是否产生压力。 | 和 WMB/BIU 写通道一起看。 |
| 372 | `vb_data_full` | LSU/Cache | Victim buffer 创建、满、请求或 D-cache 访问状态。 | 判断替换/回写路径是否产生压力。 | 和 WMB/BIU 写通道一起看。 |
| 373 | `vb_lfb_create` | LSU/Cache | Victim buffer 创建、满、请求或 D-cache 访问状态。 | 判断替换/回写路径是否产生压力。 | 和 WMB/BIU 写通道一起看。 |
| 374 | `vb_wmb_create` | LSU/Cache | Victim buffer 创建、满、请求或 D-cache 访问状态。 | 判断替换/回写路径是否产生压力。 | 和 WMB/BIU 写通道一起看。 |
| 375 | `vb_icc_create` | LSU/Cache | Victim buffer 创建、满、请求或 D-cache 访问状态。 | 判断替换/回写路径是否产生压力。 | 和 WMB/BIU 写通道一起看。 |
| 376 | `vb_biu_aw_req` | LSU/Cache | Victim buffer 创建、满、请求或 D-cache 访问状态。 | 判断替换/回写路径是否产生压力。 | 和 WMB/BIU 写通道一起看。 |
| 377 | `vb_biu_w_req` | LSU/Cache | Victim buffer 创建、满、请求或 D-cache 访问状态。 | 判断替换/回写路径是否产生压力。 | 和 WMB/BIU 写通道一起看。 |
| 378 | `vb_dcache_ld_req` | LSU/Cache | Victim buffer 创建、满、请求或 D-cache 访问状态。 | 判断替换/回写路径是否产生压力。 | 和 WMB/BIU 写通道一起看。 |
| 379 | `vb_dcache_st_req` | LSU/Cache | Victim buffer 创建、满、请求或 D-cache 访问状态。 | 判断替换/回写路径是否产生压力。 | 和 WMB/BIU 写通道一起看。 |
| 380 | `ld_lfb_discard_grnt` | LSU/Cache | load/store discard 或 speculative fail 事件。 | 定位 store-load 相关性、replay、违例和数据丢弃。 | 是 LSU replay 分析核心指标。 |
| 381 | `ld_lm_discard_grnt` | LSU/Cache | load/store discard 或 speculative fail 事件。 | 定位 store-load 相关性、replay、违例和数据丢弃。 | 是 LSU replay 分析核心指标。 |
| 382 | `ld_rb_discard_grnt` | LSU/Cache | load/store discard 或 speculative fail 事件。 | 定位 store-load 相关性、replay、违例和数据丢弃。 | 是 LSU replay 分析核心指标。 |
| 383 | `ld_sq_data_discard` | LSU/Cache | load/store discard 或 speculative fail 事件。 | 定位 store-load 相关性、replay、违例和数据丢弃。 | 是 LSU replay 分析核心指标。 |
| 384 | `ld_sq_global_discard` | LSU/Cache | load/store discard 或 speculative fail 事件。 | 定位 store-load 相关性、replay、违例和数据丢弃。 | 是 LSU replay 分析核心指标。 |
| 385 | `ld_wmb_discard` | LSU/Cache | load/store discard 或 speculative fail 事件。 | 定位 store-load 相关性、replay、违例和数据丢弃。 | 是 LSU replay 分析核心指标。 |
| 386 | `ld_spec_fail` | LSU/Cache | load/store discard 或 speculative fail 事件。 | 定位 store-load 相关性、replay、违例和数据丢弃。 | 是 LSU replay 分析核心指标。 |
| 387 | `st_spec_fail` | LSU/Cache | load/store discard 或 speculative fail 事件。 | 定位 store-load 相关性、replay、违例和数据丢弃。 | 是 LSU replay 分析核心指标。 |
| 388 | `ld_data_discard_hpcp` | LSU/Cache | load/store discard 或 speculative fail 事件。 | 定位 store-load 相关性、replay、违例和数据丢弃。 | 是 LSU replay 分析核心指标。 |
| 389 | `ld_discard_sq_hpcp` | LSU/Cache | load/store discard 或 speculative fail 事件。 | 定位 store-load 相关性、replay、违例和数据丢弃。 | 是 LSU replay 分析核心指标。 |
| 390 | `ld_pfu_hit_idx` | LSU/Cache | PFU 预取活动、请求、命中或 buffer 状态。 | 判断预取是否产生请求、命中或占用内存系统。 | 预取有效性需和 miss/latency/BIU 一起判断。 |
| 391 | `st_pfu_hit_idx` | LSU/Cache | PFU 预取活动、请求、命中或 buffer 状态。 | 判断预取是否产生请求、命中或占用内存系统。 | 预取有效性需和 miss/latency/BIU 一起判断。 |
| 392 | `is_dispatch_stall` | IDU/IQ/RF | IDU issue/dispatch stall、queue full 更新或 create 事件。 | 判断 dispatch 到各 issue queue 的接收和阻塞情况。 | 和 IQ occupancy、ready/select 一起看。 |
| 393 | `is_rob_full_stall` | IDU/IQ/RF | IDU issue/dispatch stall、queue full 更新或 create 事件。 | 判断 dispatch 到各 issue queue 的接收和阻塞情况。 | 和 IQ occupancy、ready/select 一起看。 |
| 394 | `is_iq_full_stall` | IDU/IQ/RF | IDU issue/dispatch stall、queue full 更新或 create 事件。 | 判断 dispatch 到各 issue queue 的接收和阻塞情况。 | 和 IQ occupancy、ready/select 一起看。 |
| 395 | `is_vmb_full_stall` | IDU/IQ/RF | IDU issue/dispatch stall、queue full 更新或 create 事件。 | 判断 dispatch 到各 issue queue 的接收和阻塞情况。 | 和 IQ occupancy、ready/select 一起看。 |
| 396 | `is_aiq0_full_updt` | IDU/IQ/RF | IDU issue/dispatch stall、queue full 更新或 create 事件。 | 判断 dispatch 到各 issue queue 的接收和阻塞情况。 | 和 IQ occupancy、ready/select 一起看。 |
| 397 | `is_aiq1_full_updt` | IDU/IQ/RF | IDU issue/dispatch stall、queue full 更新或 create 事件。 | 判断 dispatch 到各 issue queue 的接收和阻塞情况。 | 和 IQ occupancy、ready/select 一起看。 |
| 398 | `is_biq_full_updt` | IDU/IQ/RF | IDU issue/dispatch stall、queue full 更新或 create 事件。 | 判断 dispatch 到各 issue queue 的接收和阻塞情况。 | 和 IQ occupancy、ready/select 一起看。 |
| 399 | `is_lsiq_full_updt` | IDU/IQ/RF | IDU issue/dispatch stall、queue full 更新或 create 事件。 | 判断 dispatch 到各 issue queue 的接收和阻塞情况。 | 和 IQ occupancy、ready/select 一起看。 |
| 400 | `is_sdiq_full_updt` | IDU/IQ/RF | IDU issue/dispatch stall、queue full 更新或 create 事件。 | 判断 dispatch 到各 issue queue 的接收和阻塞情况。 | 和 IQ occupancy、ready/select 一起看。 |
| 401 | `is_viq0_full_updt` | IDU/IQ/RF | IDU issue/dispatch stall、queue full 更新或 create 事件。 | 判断 dispatch 到各 issue queue 的接收和阻塞情况。 | 和 IQ occupancy、ready/select 一起看。 |
| 402 | `is_viq1_full_updt` | IDU/IQ/RF | IDU issue/dispatch stall、queue full 更新或 create 事件。 | 判断 dispatch 到各 issue queue 的接收和阻塞情况。 | 和 IQ occupancy、ready/select 一起看。 |
| 403 | `is_aiq0_create0` | IDU/IQ/RF | IDU issue/dispatch stall、queue full 更新或 create 事件。 | 判断 dispatch 到各 issue queue 的接收和阻塞情况。 | 和 IQ occupancy、ready/select 一起看。 |
| 404 | `is_aiq0_create1` | IDU/IQ/RF | IDU issue/dispatch stall、queue full 更新或 create 事件。 | 判断 dispatch 到各 issue queue 的接收和阻塞情况。 | 和 IQ occupancy、ready/select 一起看。 |
| 405 | `is_aiq1_create0` | IDU/IQ/RF | IDU issue/dispatch stall、queue full 更新或 create 事件。 | 判断 dispatch 到各 issue queue 的接收和阻塞情况。 | 和 IQ occupancy、ready/select 一起看。 |
| 406 | `is_aiq1_create1` | IDU/IQ/RF | IDU issue/dispatch stall、queue full 更新或 create 事件。 | 判断 dispatch 到各 issue queue 的接收和阻塞情况。 | 和 IQ occupancy、ready/select 一起看。 |
| 407 | `is_biq_create0` | IDU/IQ/RF | IDU issue/dispatch stall、queue full 更新或 create 事件。 | 判断 dispatch 到各 issue queue 的接收和阻塞情况。 | 和 IQ occupancy、ready/select 一起看。 |
| 408 | `is_biq_create1` | IDU/IQ/RF | IDU issue/dispatch stall、queue full 更新或 create 事件。 | 判断 dispatch 到各 issue queue 的接收和阻塞情况。 | 和 IQ occupancy、ready/select 一起看。 |
| 409 | `is_lsiq_create0` | IDU/IQ/RF | IDU issue/dispatch stall、queue full 更新或 create 事件。 | 判断 dispatch 到各 issue queue 的接收和阻塞情况。 | 和 IQ occupancy、ready/select 一起看。 |
| 410 | `is_lsiq_create1` | IDU/IQ/RF | IDU issue/dispatch stall、queue full 更新或 create 事件。 | 判断 dispatch 到各 issue queue 的接收和阻塞情况。 | 和 IQ occupancy、ready/select 一起看。 |
| 411 | `is_sdiq_create0` | IDU/IQ/RF | IDU issue/dispatch stall、queue full 更新或 create 事件。 | 判断 dispatch 到各 issue queue 的接收和阻塞情况。 | 和 IQ occupancy、ready/select 一起看。 |
| 412 | `is_sdiq_create1` | IDU/IQ/RF | IDU issue/dispatch stall、queue full 更新或 create 事件。 | 判断 dispatch 到各 issue queue 的接收和阻塞情况。 | 和 IQ occupancy、ready/select 一起看。 |
| 413 | `is_viq0_create0` | IDU/IQ/RF | IDU issue/dispatch stall、queue full 更新或 create 事件。 | 判断 dispatch 到各 issue queue 的接收和阻塞情况。 | 和 IQ occupancy、ready/select 一起看。 |
| 414 | `is_viq0_create1` | IDU/IQ/RF | IDU issue/dispatch stall、queue full 更新或 create 事件。 | 判断 dispatch 到各 issue queue 的接收和阻塞情况。 | 和 IQ occupancy、ready/select 一起看。 |
| 415 | `is_viq1_create0` | IDU/IQ/RF | IDU issue/dispatch stall、queue full 更新或 create 事件。 | 判断 dispatch 到各 issue queue 的接收和阻塞情况。 | 和 IQ occupancy、ready/select 一起看。 |
| 416 | `is_viq1_create1` | IDU/IQ/RF | IDU issue/dispatch stall、queue full 更新或 create 事件。 | 判断 dispatch 到各 issue queue 的接收和阻塞情况。 | 和 IQ occupancy、ready/select 一起看。 |
| 417 | `aiq0_rf_pop` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 418 | `aiq1_rf_pop` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 419 | `biq_rf_pop` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 420 | `lsiq_pop` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 421 | `sdiq_pop` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 422 | `viq0_rf_pop` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 423 | `viq1_rf_pop` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 424 | `aiq0_rf_pop_dlb` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 425 | `aiq1_rf_pop_dlb` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 426 | `viq0_rf_pop_dlb` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 427 | `viq1_rf_pop_dlb` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 428 | `dca_lfb_ld_req` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 429 | `dca_vb_ld_req` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 430 | `dca_snq_ld_req` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 431 | `dca_icc_ld_req` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 432 | `dca_wmb_ld_req` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 433 | `dca_mcic_ld_req` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 434 | `dca_ag_ld_req` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 435 | `dca_lfb_ld_grnt` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 436 | `dca_vb_ld_grnt` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 437 | `dca_snq_ld_grnt` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 438 | `dca_icc_ld_grnt` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 439 | `dca_wmb_ld_grnt` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 440 | `dca_mcic_ld_grnt` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 441 | `dca_ag_ld_grnt` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 442 | `dca_lfb_st_req` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 443 | `dca_vb_st_req` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 444 | `dca_snq_st_req` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 445 | `dca_icc_st_req` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 446 | `dca_wmb_st_req` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 447 | `dca_ag_st_req` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 448 | `dca_lfb_st_grnt` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 449 | `dca_vb_st_grnt` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 450 | `dca_snq_st_grnt` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 451 | `dca_icc_st_grnt` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 452 | `dca_wmb_st_grnt` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 453 | `dca_ag_st_grnt` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 454 | `dca_serial_req` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 455 | `dca_serial_vld` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 456 | `dca_ld_borrow_vld` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 457 | `dca_st_borrow_vld` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 458 | `dca_ld_tag_req` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 459 | `dca_ld_data_req` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 460 | `dca_st_tag_req` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 461 | `dca_st_dirty_req` | LSU/Cache | D-cache arbiter 请求、授权、tag/data/dirty 或 serial 事件。 | 判断 LSU 到 D-cache 的仲裁压力和访问类型。 | req 高 grnt 低说明仲裁或端口可能受限。 |
| 462 | `sq_create_success` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 463 | `sq_create_vld` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 464 | `sq_pop_to_ce_req` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 465 | `sq_wmb_merge_stall_req` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 466 | `sq_data_discard_req` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 467 | `sq_other_discard_req` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 468 | `sq_newest_fwd_req` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 469 | `sq_addr1_dep_discard` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 470 | `lfb_empty` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 471 | `lfb_addr_pop_vld` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 472 | `lfb_addr_discard_vld` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 473 | `lfb_addr_dcache_hit` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 474 | `lfb_ld_da_hit_idx` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 475 | `lfb_st_da_hit_idx` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 476 | `lfb_pfu_biu_req_hit_idx` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 477 | `lfb_rb_biu_req_hit_idx` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 478 | `lfb_wmb_read_req_hit_idx` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 479 | `lfb_wmb_write_req_hit_idx` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 480 | `lfb_vb_create_req` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 481 | `lfb_vb_create_vld` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 482 | `lfb_vb_pe_req` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 483 | `lfb_vb_pe_grnt` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 484 | `lfb_data_create_vld` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 485 | `lfb_data_not_full` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 486 | `lfb_lf_sm_vld` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 487 | `lfb_lf_sm_req` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 488 | `lfb_lf_sm_create_vld` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 489 | `lfb_lf_sm_refill_wakeup` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 490 | `lfb_lf_sm_data_grnt` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 491 | `lfb_lf_sm_data_pop_req` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 492 | `lfb_biu_r_id_hit` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 493 | `lfb_ca_rready_grnt` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 494 | `lfb_nc_rready_grnt` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 495 | `lfb_pfu_rready_grnt` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 496 | `lfb_pop_depd_ff` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 497 | `lfb_depd_wakeup` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 498 | `lfb_mcic_wakeup` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 499 | `lfb_snq_bypass_hit` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 500 | `lfb_no_rcl_cnt_updt` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 501 | `lfb_addr_not_resp` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 502 | `wmb_empty` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 503 | `wmb_create_vld` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 504 | `wmb_biu_ar_req` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 505 | `wmb_biu_aw_req` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 506 | `wmb_biu_w_req` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 507 | `wmb_biu_nc_req_grnt` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 508 | `wmb_biu_so_req_grnt` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 509 | `wmb_mem_set_write_grnt` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 510 | `wmb_vb_create_req` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 511 | `wmb_vb_create_vld` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 512 | `wmb_st_wb_cmplt_req` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 513 | `wmb_st_wb_spec_fail` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 514 | `wmb_ld_wb_data_req` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 515 | `wmb_ld_dc_fwd_req` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 516 | `wmb_ld_dc_cancel_acc_req` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 517 | `wmb_pop_depd` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 518 | `wmb_pop_discard_req` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 519 | `wmb_pop_fwd_req` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 520 | `wmb_wakeup_queue_not_empty` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 521 | `wmb_depd_wakeup` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 522 | `wmb_b_nc_id_hit` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 523 | `wmb_b_so_id_hit` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 524 | `wmb_sync_fence_req_success` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 525 | `wmb_has_sync_fence` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 526 | `rb_empty` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 527 | `rb_full` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 528 | `rb_create_ld_success` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 529 | `rb_create_st_success` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 530 | `rb_biu_req_unmask` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 531 | `rb_biu_ar_req_detail` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 532 | `rb_biu_req_hit_idx` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 533 | `rb_biu_nc_req_grnt` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 534 | `rb_biu_so_req_grnt` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 535 | `rb_lfb_create_vld` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 536 | `rb_lfb_boundary_wakeup` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 537 | `rb_lfb_depd` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 538 | `rb_pfu_biu_req_hit_idx` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 539 | `rb_wmb_ce_hit_idx` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 540 | `rb_ld_da_hit_idx` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 541 | `rb_st_da_hit_idx` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 542 | `rb_ld_da_merge_fail` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 543 | `rb_ld_wb_cmplt_req` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 544 | `rb_ld_wb_data_req` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 545 | `rb_entry_read_req_grnt` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 546 | `rb_entry_wb_cmplt_req` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 547 | `rb_entry_wb_data_req` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 548 | `rb_entry_discard_vld` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 549 | `rb_entry_boundary_wakeup` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 550 | `rb_pfu_nc_no_pending` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 551 | `rob_commit0` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 552 | `rob_commit1` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 553 | `rob_commit2` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 554 | `rob_commit_width0_cycle` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 555 | `rob_commit_width1_cycle` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 556 | `rob_commit_width2_cycle` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 557 | `rob_commit_width3_cycle` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 558 | `rob_read0_valid` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 559 | `rob_read0_cmplted` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 560 | `rob_read0_commit` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 561 | `rob_head_not_complete` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 562 | `rob_read0_expt_entry` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 563 | `rob_commit0_mask` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 564 | `rob_commit1_mask` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 565 | `rob_commit2_mask` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 566 | `rob_read0_pipe0_cmplt` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 567 | `rob_read0_pipe1_cmplt` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 568 | `rob_read0_pipe2_cmplt` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 569 | `rob_read0_pipe3_cmplt` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 570 | `rob_read0_pipe4_cmplt` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 571 | `rob_read0_pipe6_cmplt` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 572 | `rob_read0_pipe7_cmplt` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 573 | `rob_read0_nospec_hit` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 574 | `rob_read0_nospec_miss` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 575 | `rob_read0_nospec_misp` | RTU/PST/退休 | ROB oldest/head、commit 或 retire flush 相关事件。 | 判断提交端、精确状态、异常和 flush 对性能的影响。 | head 阻塞高时看完成、异常、load/store、branch 类型。 |
| 576 | `retire_async_expt` | RTU/PST/退休 | 退休侧指令属性或事件统计。 | 分析指令 mix、写回类型、特殊预测命中/失败。 | 按退休指令口径，适合作分母。 |
| 577 | `retire_async_no_commit` | RTU/PST/退休 | 退休侧指令属性或事件统计。 | 分析指令 mix、写回类型、特殊预测命中/失败。 | 按退休指令口径，适合作分母。 |
| 578 | `retire_async_no_retire` | RTU/PST/退休 | 退休侧指令属性或事件统计。 | 分析指令 mix、写回类型、特殊预测命中/失败。 | 按退休指令口径，适合作分母。 |
| 579 | `retire_async_expt_vld` | RTU/PST/退休 | 退休侧指令属性或事件统计。 | 分析指令 mix、写回类型、特殊预测命中/失败。 | 按退休指令口径，适合作分母。 |
| 580 | `retire_lsu_all_commit_data` | RTU/PST/退休 | 退休侧指令属性或事件统计。 | 分析指令 mix、写回类型、特殊预测命中/失败。 | 按退休指令口径，适合作分母。 |
| 581 | `retire_inst0_flush` | RTU/PST/退休 | 退休侧指令属性或事件统计。 | 分析指令 mix、写回类型、特殊预测命中/失败。 | 按退休指令口径，适合作分母。 |
| 582 | `retire_inst0_mispred` | RTU/PST/退休 | 退休侧指令属性或事件统计。 | 分析指令 mix、写回类型、特殊预测命中/失败。 | 按退休指令口径，适合作分母。 |
| 583 | `retire_rob_flush` | RTU/PST/退休 | 退休侧指令属性或事件统计。 | 分析指令 mix、写回类型、特殊预测命中/失败。 | 按退休指令口径，适合作分母。 |
| 584 | `aiq0_ready_any` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 585 | `aiq1_ready_any` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 586 | `biq_ready_any` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 587 | `lsiq_ready_any` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 588 | `sdiq_ready_any` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 589 | `viq0_ready_any` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 590 | `viq1_ready_any` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 591 | `aiq0_valid_not_ready` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 592 | `aiq1_valid_not_ready` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 593 | `biq_valid_not_ready` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 594 | `lsiq_valid_not_ready` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 595 | `sdiq_valid_not_ready` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 596 | `viq0_valid_not_ready` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 597 | `viq1_valid_not_ready` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 598 | `aiq0_issue_select_any` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 599 | `aiq1_issue_select_any` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 600 | `biq_issue_select_any` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 601 | `lsiq_issue_select_any` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 602 | `sdiq_issue_select_any` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 603 | `viq0_issue_select_any` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 604 | `viq1_issue_select_any` | IDU/IQ/RF | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 605 | `iutlb_miss` | MMU/TLB/PTW | TLB miss 侧事件。 | 判断地址翻译是否造成前端或 LSU 停顿。 | bare-metal 恒等映射下需注意信号口径。 |
| 606 | `dutlb_miss` | MMU/TLB/PTW | TLB miss 侧事件。 | 判断地址翻译是否造成前端或 LSU 停顿。 | bare-metal 恒等映射下需注意信号口径。 |
| 607 | `jtlb_miss` | MMU/TLB/PTW | TLB miss 侧事件。 | 判断地址翻译是否造成前端或 LSU 停顿。 | bare-metal 恒等映射下需注意信号口径。 |
| 608 | `ifu_mmu_va_vld` | IFU/分支 | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 609 | `mmu_ifu_pavld` | MMU/TLB/PTW | MMU/TLB/PTW 请求、完成、miss 或页属性事件。 | 判断地址翻译和 page walk 是否阻塞。 | bare-metal 小程序通常应较低。 |
| 610 | `lsu_mmu_va0_vld` | LSU/Cache | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 611 | `lsu_mmu_va1_vld` | LSU/Cache | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 612 | `lsu_mmu_va2_vld` | LSU/Cache | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 613 | `mmu_lsu_pa0_vld` | MMU/TLB/PTW | MMU/TLB/PTW 请求、完成、miss 或页属性事件。 | 判断地址翻译和 page walk 是否阻塞。 | bare-metal 小程序通常应较低。 |
| 614 | `mmu_lsu_pa1_vld` | MMU/TLB/PTW | MMU/TLB/PTW 请求、完成、miss 或页属性事件。 | 判断地址翻译和 page walk 是否阻塞。 | bare-metal 小程序通常应较低。 |
| 615 | `mmu_lsu_pa2_vld` | MMU/TLB/PTW | MMU/TLB/PTW 请求、完成、miss 或页属性事件。 | 判断地址翻译和 page walk 是否阻塞。 | bare-metal 小程序通常应较低。 |
| 616 | `mmu_lsu_stall0` | MMU/TLB/PTW | MMU/TLB/PTW 请求、完成、miss 或页属性事件。 | 判断地址翻译和 page walk 是否阻塞。 | bare-metal 小程序通常应较低。 |
| 617 | `mmu_lsu_stall1` | MMU/TLB/PTW | MMU/TLB/PTW 请求、完成、miss 或页属性事件。 | 判断地址翻译和 page walk 是否阻塞。 | bare-metal 小程序通常应较低。 |
| 618 | `mmu_lsu_tlb_busy` | MMU/TLB/PTW | MMU/TLB/PTW 请求、完成、miss 或页属性事件。 | 判断地址翻译和 page walk 是否阻塞。 | bare-metal 小程序通常应较低。 |
| 619 | `iutlb_arb_req` | MMU/TLB/PTW | MMU/TLB/PTW 请求、完成、miss 或页属性事件。 | 判断地址翻译和 page walk 是否阻塞。 | bare-metal 小程序通常应较低。 |
| 620 | `iutlb_arb_cmplt` | MMU/TLB/PTW | MMU/TLB/PTW 请求、完成、miss 或页属性事件。 | 判断地址翻译和 page walk 是否阻塞。 | bare-metal 小程序通常应较低。 |
| 621 | `dutlb_arb_req` | MMU/TLB/PTW | MMU/TLB/PTW 请求、完成、miss 或页属性事件。 | 判断地址翻译和 page walk 是否阻塞。 | bare-metal 小程序通常应较低。 |
| 622 | `dutlb_arb_cmplt` | MMU/TLB/PTW | MMU/TLB/PTW 请求、完成、miss 或页属性事件。 | 判断地址翻译和 page walk 是否阻塞。 | bare-metal 小程序通常应较低。 |
| 623 | `jtlb_ptw_req` | MMU/TLB/PTW | MMU/TLB/PTW 请求、完成、miss 或页属性事件。 | 判断地址翻译和 page walk 是否阻塞。 | bare-metal 小程序通常应较低。 |
| 624 | `ptw_arb_req` | MMU/TLB/PTW | MMU/TLB/PTW 请求、完成、miss 或页属性事件。 | 判断地址翻译和 page walk 是否阻塞。 | bare-metal 小程序通常应较低。 |
| 625 | `ptw_jtlb_imiss` | MMU/TLB/PTW | MMU/TLB/PTW 请求、完成、miss 或页属性事件。 | 判断地址翻译和 page walk 是否阻塞。 | bare-metal 小程序通常应较低。 |
| 626 | `ptw_jtlb_dmiss` | MMU/TLB/PTW | MMU/TLB/PTW 请求、完成、miss 或页属性事件。 | 判断地址翻译和 page walk 是否阻塞。 | bare-metal 小程序通常应较低。 |
| 627 | `ptw_jtlb_pmiss` | MMU/TLB/PTW | MMU/TLB/PTW 请求、完成、miss 或页属性事件。 | 判断地址翻译和 page walk 是否阻塞。 | bare-metal 小程序通常应较低。 |
| 628 | `ptw_jtlb_ref_cmplt` | MMU/TLB/PTW | MMU/TLB/PTW 请求、完成、miss 或页属性事件。 | 判断地址翻译和 page walk 是否阻塞。 | bare-metal 小程序通常应较低。 |
| 629 | `ptw_jtlb_ref_data_vld` | MMU/TLB/PTW | MMU/TLB/PTW 请求、完成、miss 或页属性事件。 | 判断地址翻译和 page walk 是否阻塞。 | bare-metal 小程序通常应较低。 |
| 630 | `mmu_lsu_data_req` | MMU/TLB/PTW | MMU/TLB/PTW 请求、完成、miss 或页属性事件。 | 判断地址翻译和 page walk 是否阻塞。 | bare-metal 小程序通常应较低。 |
| 631 | `lsu_mmu_data_vld` | LSU/Cache | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 632 | `ptw_top_imiss` | MMU/TLB/PTW | MMU/TLB/PTW 请求、完成、miss 或页属性事件。 | 判断地址翻译和 page walk 是否阻塞。 | bare-metal 小程序通常应较低。 |
| 633 | `jtlb_arb_tc_miss` | MMU/TLB/PTW | MMU/TLB/PTW 请求、完成、miss 或页属性事件。 | 判断地址翻译和 page walk 是否阻塞。 | bare-metal 小程序通常应较低。 |
| 634 | `jtlb_arb_sel_4k` | MMU/TLB/PTW | MMU/TLB/PTW 请求、完成、miss 或页属性事件。 | 判断地址翻译和 page walk 是否阻塞。 | bare-metal 小程序通常应较低。 |
| 635 | `jtlb_arb_sel_2m` | MMU/TLB/PTW | MMU/TLB/PTW 请求、完成、miss 或页属性事件。 | 判断地址翻译和 page walk 是否阻塞。 | bare-metal 小程序通常应较低。 |
| 636 | `jtlb_arb_sel_1g` | MMU/TLB/PTW | MMU/TLB/PTW 请求、完成、miss 或页属性事件。 | 判断地址翻译和 page walk 是否阻塞。 | bare-metal 小程序通常应较低。 |
| 637 | `mmu_lsu_page_fault` | MMU/TLB/PTW | MMU/TLB/PTW 请求、完成、miss 或页属性事件。 | 判断地址翻译和 page walk 是否阻塞。 | bare-metal 小程序通常应较低。 |
| 638 | `rob_occ_lt32` | RTU/PST/退休 | ROB 占用或满状态桶。 | 判断乱序窗口容量压力。 | 若 ROB 满不高，扩大窗口不是第一方向。 |
| 639 | `rob_occ_32_63` | RTU/PST/退休 | ROB 占用或满状态桶。 | 判断乱序窗口容量压力。 | 若 ROB 满不高，扩大窗口不是第一方向。 |
| 640 | `rob_occ_ge64_bucket` | RTU/PST/退休 | ROB 占用或满状态桶。 | 判断乱序窗口容量压力。 | 若 ROB 满不高，扩大窗口不是第一方向。 |
| 641 | `zero_bad_spec_raw` | RTU/PST/退休 | zero-retire 周期的 raw 原因分类。 | 判断没有指令退休时更像 bad-spec、frontend、memory 还是 backend。 | raw 原因可重叠，不能简单相加为 100%。 |
| 642 | `zero_frontend_raw` | RTU/PST/退休 | zero-retire 周期的 raw 原因分类。 | 判断没有指令退休时更像 bad-spec、frontend、memory 还是 backend。 | raw 原因可重叠，不能简单相加为 100%。 |
| 643 | `zero_memory_raw` | RTU/PST/退休 | zero-retire 周期的 raw 原因分类。 | 判断没有指令退休时更像 bad-spec、frontend、memory 还是 backend。 | raw 原因可重叠，不能简单相加为 100%。 |
| 644 | `zero_backend_raw` | RTU/PST/退休 | zero-retire 周期的 raw 原因分类。 | 判断没有指令退休时更像 bad-spec、frontend、memory 还是 backend。 | raw 原因可重叠，不能简单相加为 100%。 |
| 645 | `zero_multi_raw_cause` | RTU/PST/退休 | zero-retire 周期的 raw 原因分类。 | 判断没有指令退休时更像 bad-spec、frontend、memory 还是 backend。 | raw 原因可重叠，不能简单相加为 100%。 |
| 646 | `zero_no_raw_cause` | RTU/PST/退休 | zero-retire 周期的 raw 原因分类。 | 判断没有指令退休时更像 bad-spec、frontend、memory 还是 backend。 | raw 原因可重叠，不能简单相加为 100%。 |
| 647 | `l0_btb_hit` | IFU/分支 | L0 BTB 或 indirect BTB 命中、miss、等待、检查事件。 | 分析目标预测和间接跳转预测。 | 需要分母才能得到准确率。 |
| 648 | `l0_btb_miss_deep` | IFU/分支 | L0 BTB 或 indirect BTB 命中、miss、等待、检查事件。 | 分析目标预测和间接跳转预测。 | 需要分母才能得到准确率。 |
| 649 | `l0_btb_mispred` | IFU/分支 | L0 BTB 或 indirect BTB 命中、miss、等待、检查事件。 | 分析目标预测和间接跳转预测。 | 需要分母才能得到准确率。 |
| 650 | `l0_btb_wait` | IFU/分支 | L0 BTB 或 indirect BTB 命中、miss、等待、检查事件。 | 分析目标预测和间接跳转预测。 | 需要分母才能得到准确率。 |
| 651 | `ind_btb_check` | IFU/分支 | L0 BTB 或 indirect BTB 命中、miss、等待、检查事件。 | 分析目标预测和间接跳转预测。 | 需要分母才能得到准确率。 |
| 652 | `ind_btb_fifo_stall` | IFU/分支 | L0 BTB 或 indirect BTB 命中、miss、等待、检查事件。 | 分析目标预测和间接跳转预测。 | 需要分母才能得到准确率。 |
| 653 | `ind_btb_miss_deep` | IFU/分支 | L0 BTB 或 indirect BTB 命中、miss、等待、检查事件。 | 分析目标预测和间接跳转预测。 | 需要分母才能得到准确率。 |
| 654 | `ras_redirect` | IFU/分支 | RAS 返回地址栈活动或状态。 | 判断 call/return 预测、栈空/满和重定向情况。 | 不是完整 RAS 准确率，需要分母。 |
| 655 | `ras_mistaken` | IFU/分支 | RAS 返回地址栈活动或状态。 | 判断 call/return 预测、栈空/满和重定向情况。 | 不是完整 RAS 准确率，需要分母。 |
| 656 | `lbuf_bju_mispred` | IFU/分支 | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 657 | `bht_pred_array_rd` | IFU/分支 | BHT 预测表或写缓冲活动。 | 分析方向预测读、选择、更新缓冲和 BJU 误预测。 | 不是完整 BHT 准确率。 |
| 658 | `bht_sel_array_rd` | IFU/分支 | BHT 预测表或写缓冲活动。 | 分析方向预测读、选择、更新缓冲和 BJU 误预测。 | 不是完整 BHT 准确率。 |
| 659 | `bht_wr_buf_hit` | IFU/分支 | BHT 预测表或写缓冲活动。 | 分析方向预测读、选择、更新缓冲和 BJU 误预测。 | 不是完整 BHT 准确率。 |
| 660 | `bht_bju_mispred` | IFU/分支 | BHT 预测表或写缓冲活动。 | 分析方向预测读、选择、更新缓冲和 BJU 误预测。 | 不是完整 BHT 准确率。 |
| 661 | `wmb_ld_fwd_req_deep` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 662 | `wmb_ld_cancel_req_deep` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 663 | `sq_newest_fwd_req_deep` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 664 | `sq_data_discard_req_deep` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 665 | `sq_other_discard_req_deep` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 666 | `sq_addr_dep_discard_deep` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 667 | `ld_sq_data_discard_deep` | LSU/Cache | load/store discard 或 speculative fail 事件。 | 定位 store-load 相关性、replay、违例和数据丢弃。 | 是 LSU replay 分析核心指标。 |
| 668 | `ld_sq_global_discard_deep` | LSU/Cache | load/store discard 或 speculative fail 事件。 | 定位 store-load 相关性、replay、违例和数据丢弃。 | 是 LSU replay 分析核心指标。 |
| 669 | `ld_wmb_discard_deep` | LSU/Cache | load/store discard 或 speculative fail 事件。 | 定位 store-load 相关性、replay、违例和数据丢弃。 | 是 LSU replay 分析核心指标。 |
| 670 | `lsu_spec_fail_deep` | LSU/Cache | 直接采样 RTL 同名信号或其组合的事件/状态。 | 用于补充定位对应模块的活动、阻塞或状态变化。 | 如需精确根因，应回到 tb.v 层级引用和 RTL 信号定义核查。 |
| 671 | `lfb_rb_create_entry` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 672 | `lfb_pfu_create_entry` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 673 | `lfb_addr_pop_entry` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 674 | `lfb_data_create_deep` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 675 | `wmb_entry_create_deep` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 676 | `wmb_entry_pop_deep` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 677 | `sq_entry_create_deep` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 678 | `sq_entry_pop_deep` | LSU/Cache | LSU 队列/buffer 生命周期、请求、命中、discard 或 wakeup 事件。 | 定位 load/store queue、write merge buffer、refill buffer、read buffer 的结构瓶颈。 | 事件多为 any-entry 脉冲，宽度需看 profile。 |
| 679 | `biu_rd_outstanding` | BIU/AXI | testbench 维护的 BIU outstanding 状态。 | 粗看外部读写并发压力。 | 当前口径有边界风险，短 phase 或 AR/RLAST 不平衡时需谨慎。 |
| 680 | `biu_rd_outstanding_ge2` | BIU/AXI | testbench 维护的 BIU outstanding 状态。 | 粗看外部读写并发压力。 | 当前口径有边界风险，短 phase 或 AR/RLAST 不平衡时需谨慎。 |
| 681 | `biu_wr_outstanding` | BIU/AXI | testbench 维护的 BIU outstanding 状态。 | 粗看外部读写并发压力。 | 当前口径有边界风险，短 phase 或 AR/RLAST 不平衡时需谨慎。 |
| 682 | `biu_wr_outstanding_ge2` | BIU/AXI | testbench 维护的 BIU outstanding 状态。 | 粗看外部读写并发压力。 | 当前口径有边界风险，短 phase 或 AR/RLAST 不平衡时需谨慎。 |
| 683 | `biu_ar_hs_deep` | BIU/AXI | BIU/AXI 通道握手事件。 | 统计外部读写请求或响应实际完成。 | AR/RLAST/AW/B 成对分析。 |
| 684 | `biu_rlast_hs_deep` | BIU/AXI | BIU/AXI 通道握手事件。 | 统计外部读写请求或响应实际完成。 | AR/RLAST/AW/B 成对分析。 |
| 685 | `biu_aw_hs_deep` | BIU/AXI | BIU/AXI 通道握手事件。 | 统计外部读写请求或响应实际完成。 | AR/RLAST/AW/B 成对分析。 |
| 686 | `biu_b_hs_deep` | BIU/AXI | BIU/AXI 通道握手事件。 | 统计外部读写请求或响应实际完成。 | AR/RLAST/AW/B 成对分析。 |
| 687 | `pst_async_flush` | RTU/PST/退休 | PST/free-list 空、恢复或可分配状态。 | 判断物理寄存器资源、flush rollback 和退休回收是否限制 rename。 | 需要和 rename stall 一起看。 |
| 688 | `pst_preg_recover_vec` | RTU/PST/退休 | PST/free-list 空、恢复或可分配状态。 | 判断物理寄存器资源、flush rollback 和退休回收是否限制 rename。 | 需要和 rename stall 一起看。 |
| 689 | `pst_ereg_recover_vec` | RTU/PST/退休 | PST/free-list 空、恢复或可分配状态。 | 判断物理寄存器资源、flush rollback 和退休回收是否限制 rename。 | 需要和 rename stall 一起看。 |
| 690 | `pst_preg_all_retired_wb` | RTU/PST/退休 | PST/free-list 空、恢复或可分配状态。 | 判断物理寄存器资源、flush rollback 和退休回收是否限制 rename。 | 需要和 rename stall 一起看。 |
| 691 | `pst_preg_empty` | RTU/PST/退休 | PST/free-list 空、恢复或可分配状态。 | 判断物理寄存器资源、flush rollback 和退休回收是否限制 rename。 | 需要和 rename stall 一起看。 |
| 692 | `preg_alloc_avail0` | RTU/PST/退休 | PST/free-list 空、恢复或可分配状态。 | 判断物理寄存器资源、flush rollback 和退休回收是否限制 rename。 | 需要和 rename stall 一起看。 |
| 693 | `preg_alloc_avail4` | RTU/PST/退休 | PST/free-list 空、恢复或可分配状态。 | 判断物理寄存器资源、flush rollback 和退休回收是否限制 rename。 | 需要和 rename stall 一起看。 |
| 694 | `ereg_alloc_avail0` | RTU/PST/退休 | PST/free-list 空、恢复或可分配状态。 | 判断物理寄存器资源、flush rollback 和退休回收是否限制 rename。 | 需要和 rename stall 一起看。 |
| 695 | `ereg_alloc_avail4` | RTU/PST/退休 | PST/free-list 空、恢复或可分配状态。 | 判断物理寄存器资源、flush rollback 和退休回收是否限制 rename。 | 需要和 rename stall 一起看。 |
| 696 | `flush_fetch_invalid_cycle` | 其他 | flush 恢复路径或有效指令状态。 | 判断 flush 后 fetch/ID/retire 是否出现气泡。 | 完整恢复时间看 latency 的 flush_to_*。 |
| 697 | `flush_id_invalid_cycle` | 其他 | flush 恢复路径或有效指令状态。 | 判断 flush 后 fetch/ID/retire 是否出现气泡。 | 完整恢复时间看 latency 的 flush_to_*。 |
| 698 | `ifctrl_ipctrl_vld` | 其他 | flush 恢复路径或有效指令状态。 | 判断 flush 后 fetch/ID/retire 是否出现气泡。 | 完整恢复时间看 latency 的 flush_to_*。 |
| 699 | `id_inst0_valid` | IDU/IQ/RF | flush 恢复路径或有效指令状态。 | 判断 flush 后 fetch/ID/retire 是否出现气泡。 | 完整恢复时间看 latency 的 flush_to_*。 |
| 700 | `global_flush_zero_retire` | 其他 | flush 恢复路径或有效指令状态。 | 判断 flush 后 fetch/ID/retire 是否出现气泡。 | 完整恢复时间看 latency 的 flush_to_*。 |

## Profile 平均宽度/占用完整字典

| ID | 指标 | 模块 | 含义 | 用途 | 注意 |
|---|---|---|---|---|---|
| 1 | `id_width_avg` | IDU/IQ/RF | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 2 | `ir_width_avg` | IDU/IQ/RF | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 3 | `is_width_avg` | IDU/IQ/RF | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 4 | `rf_launch_width_avg` | IDU/IQ/RF | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 5 | `retire_width_avg` | RTU/PST/退休 | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 6 | `rob_occ_avg` | RTU/PST/退休 | 每周期平均占用深度。 | 判断队列或 buffer 是否长期积压。 | 平均低但 latency 长时，可能是少量长尾事件。 |
| 7 | `aiq0_occ_avg` | IDU/IQ/RF | 每周期平均占用深度。 | 判断队列或 buffer 是否长期积压。 | 平均低但 latency 长时，可能是少量长尾事件。 |
| 8 | `aiq1_occ_avg` | IDU/IQ/RF | 每周期平均占用深度。 | 判断队列或 buffer 是否长期积压。 | 平均低但 latency 长时，可能是少量长尾事件。 |
| 9 | `biq_occ_avg` | IDU/IQ/RF | 每周期平均占用深度。 | 判断队列或 buffer 是否长期积压。 | 平均低但 latency 长时，可能是少量长尾事件。 |
| 10 | `lsiq_occ_avg` | IDU/IQ/RF | 每周期平均占用深度。 | 判断队列或 buffer 是否长期积压。 | 平均低但 latency 长时，可能是少量长尾事件。 |
| 11 | `sdiq_occ_avg` | IDU/IQ/RF | 每周期平均占用深度。 | 判断队列或 buffer 是否长期积压。 | 平均低但 latency 长时，可能是少量长尾事件。 |
| 12 | `viq0_occ_avg` | IDU/IQ/RF | 每周期平均占用深度。 | 判断队列或 buffer 是否长期积压。 | 平均低但 latency 长时，可能是少量长尾事件。 |
| 13 | `viq1_occ_avg` | IDU/IQ/RF | 每周期平均占用深度。 | 判断队列或 buffer 是否长期积压。 | 平均低但 latency 长时，可能是少量长尾事件。 |
| 14 | `lq_occ_avg` | LSU/Cache | 每周期平均占用深度。 | 判断队列或 buffer 是否长期积压。 | 平均低但 latency 长时，可能是少量长尾事件。 |
| 15 | `sq_occ_avg` | LSU/Cache | 每周期平均占用深度。 | 判断队列或 buffer 是否长期积压。 | 平均低但 latency 长时，可能是少量长尾事件。 |
| 16 | `rb_occ_avg` | LSU/Cache | 每周期平均占用深度。 | 判断队列或 buffer 是否长期积压。 | 平均低但 latency 长时，可能是少量长尾事件。 |
| 17 | `lfb_addr_occ_avg` | LSU/Cache | 每周期平均占用深度。 | 判断队列或 buffer 是否长期积压。 | 平均低但 latency 长时，可能是少量长尾事件。 |
| 18 | `wmb_occ_avg` | LSU/Cache | 每周期平均占用深度。 | 判断队列或 buffer 是否长期积压。 | 平均低但 latency 长时，可能是少量长尾事件。 |
| 19 | `ibuf_occ_avg` | 其他 | 每周期平均占用深度。 | 判断队列或 buffer 是否长期积压。 | 平均低但 latency 长时，可能是少量长尾事件。 |
| 20 | `bht_wrbuf_occ_avg` | IFU/分支 | 每周期平均占用深度。 | 判断队列或 buffer 是否长期积压。 | 平均低但 latency 长时，可能是少量长尾事件。 |
| 21 | `lfb_data_occ_avg` | LSU/Cache | 每周期平均占用深度。 | 判断队列或 buffer 是否长期积压。 | 平均低但 latency 长时，可能是少量长尾事件。 |
| 22 | `retire_load_inst_avg` | RTU/PST/退休 | 每周期平均退休的某类指令或属性数量。 | 分析指令 mix 和退休端负载。 | 和总退休宽度组成比例分析。 |
| 23 | `retire_store_inst_avg` | RTU/PST/退休 | 每周期平均退休的某类指令或属性数量。 | 分析指令 mix 和退休端负载。 | 和总退休宽度组成比例分析。 |
| 24 | `retire_bju_inst_avg` | RTU/PST/退休 | 每周期平均退休的某类指令或属性数量。 | 分析指令 mix 和退休端负载。 | 和总退休宽度组成比例分析。 |
| 25 | `retire_condbr_inst_avg` | RTU/PST/退休 | 每周期平均退休的某类指令或属性数量。 | 分析指令 mix 和退休端负载。 | 和总退休宽度组成比例分析。 |
| 26 | `retire_jmp_inst_avg` | RTU/PST/退休 | 每周期平均退休的某类指令或属性数量。 | 分析指令 mix 和退休端负载。 | 和总退休宽度组成比例分析。 |
| 27 | `retire_split_inst_avg` | RTU/PST/退休 | 每周期平均退休的某类指令或属性数量。 | 分析指令 mix 和退休端负载。 | 和总退休宽度组成比例分析。 |
| 28 | `retire_preg_inst_avg` | RTU/PST/退休 | 每周期平均退休的某类指令或属性数量。 | 分析指令 mix 和退休端负载。 | 和总退休宽度组成比例分析。 |
| 29 | `retire_vreg_inst_avg` | RTU/PST/退休 | 每周期平均退休的某类指令或属性数量。 | 分析指令 mix 和退休端负载。 | 和总退休宽度组成比例分析。 |
| 30 | `retire_ereg_inst_avg` | RTU/PST/退休 | 每周期平均退休的某类指令或属性数量。 | 分析指令 mix 和退休端负载。 | 和总退休宽度组成比例分析。 |
| 31 | `retire_nospec_hit_avg` | RTU/PST/退休 | 每周期平均退休的某类指令或属性数量。 | 分析指令 mix 和退休端负载。 | 和总退休宽度组成比例分析。 |
| 32 | `retire_nospec_miss_avg` | RTU/PST/退休 | 每周期平均退休的某类指令或属性数量。 | 分析指令 mix 和退休端负载。 | 和总退休宽度组成比例分析。 |
| 33 | `retire_nospec_misp_avg` | RTU/PST/退休 | 每周期平均退休的某类指令或属性数量。 | 分析指令 mix 和退休端负载。 | 和总退休宽度组成比例分析。 |
| 34 | `retire_vl_pred_avg` | RTU/PST/退休 | 每周期平均退休的某类指令或属性数量。 | 分析指令 mix 和退休端负载。 | 和总退休宽度组成比例分析。 |
| 35 | `preg_alloc_req_avg` | RTU/PST/退休 | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 36 | `preg_alloc_vld_avg` | RTU/PST/退休 | 每周期平均分配请求、可用、阻塞或可分配数量。 | 判断 rename/free-list 资源压力。 | block 高才说明资源真限制。 |
| 37 | `preg_alloc_block_avg` | RTU/PST/退休 | 每周期平均分配请求、可用、阻塞或可分配数量。 | 判断 rename/free-list 资源压力。 | block 高才说明资源真限制。 |
| 38 | `ereg_alloc_req_avg` | RTU/PST/退休 | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 39 | `ereg_alloc_vld_avg` | RTU/PST/退休 | 每周期平均分配请求、可用、阻塞或可分配数量。 | 判断 rename/free-list 资源压力。 | block 高才说明资源真限制。 |
| 40 | `ereg_alloc_block_avg` | RTU/PST/退休 | 每周期平均分配请求、可用、阻塞或可分配数量。 | 判断 rename/free-list 资源压力。 | block 高才说明资源真限制。 |
| 41 | `freg_vreg_alloc_req_avg` | RTU/PST/退休 | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 42 | `freg_vreg_alloc_vld_avg` | RTU/PST/退休 | 每周期平均分配请求、可用、阻塞或可分配数量。 | 判断 rename/free-list 资源压力。 | block 高才说明资源真限制。 |
| 43 | `freg_vreg_alloc_block_avg` | RTU/PST/退休 | 每周期平均分配请求、可用、阻塞或可分配数量。 | 判断 rename/free-list 资源压力。 | block 高才说明资源真限制。 |
| 44 | `vfpu_issue_width_avg` | VFPU | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 45 | `vfpu_wb_width_avg` | VFPU | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 46 | `pfu_pfb_occ_avg` | LSU/Cache | 每周期平均占用深度。 | 判断队列或 buffer 是否长期积压。 | 平均低但 latency 长时，可能是少量长尾事件。 |
| 47 | `pfu_pmb_occ_avg` | LSU/Cache | 每周期平均占用深度。 | 判断队列或 buffer 是否长期积压。 | 平均低但 latency 长时，可能是少量长尾事件。 |
| 48 | `pfu_sdb_occ_avg` | LSU/Cache | 每周期平均占用深度。 | 判断队列或 buffer 是否长期积压。 | 平均低但 latency 长时，可能是少量长尾事件。 |
| 49 | `vb_addr_occ_avg` | LSU/Cache | 每周期平均占用深度。 | 判断队列或 buffer 是否长期积压。 | 平均低但 latency 长时，可能是少量长尾事件。 |
| 50 | `vb_data_occ_avg` | LSU/Cache | 每周期平均占用深度。 | 判断队列或 buffer 是否长期积压。 | 平均低但 latency 长时，可能是少量长尾事件。 |
| 51 | `is_create_width_avg` | IDU/IQ/RF | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 52 | `is_aiq_create_avg` | IDU/IQ/RF | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 53 | `is_biq_create_avg` | IDU/IQ/RF | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 54 | `is_lsiq_create_avg` | IDU/IQ/RF | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 55 | `is_sdiq_create_avg` | IDU/IQ/RF | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 56 | `is_viq_create_avg` | IDU/IQ/RF | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 57 | `iq_pop_width_avg` | 其他 | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 58 | `int_iq_pop_avg` | 其他 | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 59 | `lsu_iq_pop_avg` | LSU/Cache | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 60 | `vec_iq_pop_avg` | 其他 | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 61 | `dca_ld_req_width_avg` | LSU/Cache | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 62 | `dca_ld_grnt_width_avg` | LSU/Cache | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 63 | `dca_st_req_width_avg` | LSU/Cache | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 64 | `dca_st_grnt_width_avg` | LSU/Cache | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 65 | `lfb_addr_pop_avg` | LSU/Cache | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 66 | `lfb_dcache_hit_avg` | LSU/Cache | 每周期平均活动量。 | 用于观察对应模块吞吐、占用或状态强度。 | 需结合 detail 和 latency 指标解释。 |
| 67 | `lfb_depd_wakeup_avg` | LSU/Cache | 每周期平均活动量。 | 用于观察对应模块吞吐、占用或状态强度。 | 需结合 detail 和 latency 指标解释。 |
| 68 | `lfb_vb_pe_req_avg` | LSU/Cache | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 69 | `wmb_wakeup_queue_avg` | LSU/Cache | 每周期平均活动量。 | 用于观察对应模块吞吐、占用或状态强度。 | 需结合 detail 和 latency 指标解释。 |
| 70 | `wmb_depd_wakeup_avg` | LSU/Cache | 每周期平均活动量。 | 用于观察对应模块吞吐、占用或状态强度。 | 需结合 detail 和 latency 指标解释。 |
| 71 | `wmb_create_width_avg` | LSU/Cache | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 72 | `rb_create_width_avg` | LSU/Cache | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 73 | `rb_biu_pe_req_avg` | LSU/Cache | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 74 | `rob_commit_width_avg` | RTU/PST/退休 | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 75 | `iq_ready_width_avg` | 其他 | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 76 | `iq_not_ready_width_avg` | 其他 | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 77 | `iq_select_width_avg` | 其他 | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 78 | `int_iq_ready_avg` | 其他 | 每周期平均 ready entry 或 ready 队列数量。 | 判断是否有可发射工作但 select/端口未消化。 | 需和 select/pop 宽度比较。 |
| 79 | `lsu_iq_ready_avg` | LSU/Cache | 每周期平均 ready entry 或 ready 队列数量。 | 判断是否有可发射工作但 select/端口未消化。 | 需和 select/pop 宽度比较。 |
| 80 | `vec_iq_ready_avg` | 其他 | 每周期平均 ready entry 或 ready 队列数量。 | 判断是否有可发射工作但 select/端口未消化。 | 需和 select/pop 宽度比较。 |
| 81 | `int_iq_not_ready_avg` | 其他 | 每周期平均 valid 但未 ready 的 entry 数量。 | 定位 wakeup、forward、依赖链或执行单元等待。 | 这是队列级统计，不能直接给出 producer 类型。 |
| 82 | `lsu_iq_not_ready_avg` | LSU/Cache | 每周期平均 valid 但未 ready 的 entry 数量。 | 定位 wakeup、forward、依赖链或执行单元等待。 | 这是队列级统计，不能直接给出 producer 类型。 |
| 83 | `vec_iq_not_ready_avg` | 其他 | 每周期平均 valid 但未 ready 的 entry 数量。 | 定位 wakeup、forward、依赖链或执行单元等待。 | 这是队列级统计，不能直接给出 producer 类型。 |
| 84 | `mmu_va_req_width_avg` | MMU/TLB/PTW | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 85 | `tlb_refill_req_avg` | 其他 | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 86 | `tlb_refill_cmplt_avg` | 其他 | 每周期平均地址翻译或 page walk 活动。 | 判断 MMU/TLB 是否参与瓶颈。 | 小 bare-metal case 通常应低。 |
| 87 | `ptw_activity_avg` | MMU/TLB/PTW | 每周期平均地址翻译或 page walk 活动。 | 判断 MMU/TLB 是否参与瓶颈。 | 小 bare-metal case 通常应低。 |
| 88 | `mem_wakeup_width_avg` | 其他 | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 89 | `biu_rd_outstanding_avg` | BIU/AXI | testbench 维护的 BIU outstanding 平均深度。 | 粗看外部读写事务并发。 | 当前 outstanding 口径需谨慎，不能单独证明带宽瓶颈。 |
| 90 | `biu_wr_outstanding_avg` | BIU/AXI | testbench 维护的 BIU outstanding 平均深度。 | 粗看外部读写事务并发。 | 当前 outstanding 口径需谨慎，不能单独证明带宽瓶颈。 |
| 91 | `cpi_raw_cause_avg` | 其他 | 每周期平均活动量。 | 用于观察对应模块吞吐、占用或状态强度。 | 需结合 detail 和 latency 指标解释。 |
| 92 | `iq_blocked_queue_avg` | 其他 | 每周期平均活动量。 | 用于观察对应模块吞吐、占用或状态强度。 | 需结合 detail 和 latency 指标解释。 |
| 93 | `iq_ready_queue_avg` | 其他 | 每周期平均 ready entry 或 ready 队列数量。 | 判断是否有可发射工作但 select/端口未消化。 | 需和 select/pop 宽度比较。 |
| 94 | `preg_alloc_avail_avg` | RTU/PST/退休 | 每周期平均分配请求、可用、阻塞或可分配数量。 | 判断 rename/free-list 资源压力。 | block 高才说明资源真限制。 |
| 95 | `ereg_alloc_avail_avg` | RTU/PST/退休 | 每周期平均分配请求、可用、阻塞或可分配数量。 | 判断 rename/free-list 资源压力。 | block 高才说明资源真限制。 |
| 96 | `aiq0_not_ready_avg` | IDU/IQ/RF | 每周期平均 valid 但未 ready 的 entry 数量。 | 定位 wakeup、forward、依赖链或执行单元等待。 | 这是队列级统计，不能直接给出 producer 类型。 |
| 97 | `aiq1_not_ready_avg` | IDU/IQ/RF | 每周期平均 valid 但未 ready 的 entry 数量。 | 定位 wakeup、forward、依赖链或执行单元等待。 | 这是队列级统计，不能直接给出 producer 类型。 |
| 98 | `biq_not_ready_avg` | IDU/IQ/RF | 每周期平均 valid 但未 ready 的 entry 数量。 | 定位 wakeup、forward、依赖链或执行单元等待。 | 这是队列级统计，不能直接给出 producer 类型。 |
| 99 | `lsiq_not_ready_avg` | IDU/IQ/RF | 每周期平均 valid 但未 ready 的 entry 数量。 | 定位 wakeup、forward、依赖链或执行单元等待。 | 这是队列级统计，不能直接给出 producer 类型。 |
| 100 | `sdiq_not_ready_avg` | IDU/IQ/RF | 每周期平均 valid 但未 ready 的 entry 数量。 | 定位 wakeup、forward、依赖链或执行单元等待。 | 这是队列级统计，不能直接给出 producer 类型。 |
| 101 | `viq0_not_ready_avg` | IDU/IQ/RF | 每周期平均 valid 但未 ready 的 entry 数量。 | 定位 wakeup、forward、依赖链或执行单元等待。 | 这是队列级统计，不能直接给出 producer 类型。 |
| 102 | `viq1_not_ready_avg` | IDU/IQ/RF | 每周期平均 valid 但未 ready 的 entry 数量。 | 定位 wakeup、forward、依赖链或执行单元等待。 | 这是队列级统计，不能直接给出 producer 类型。 |
| 103 | `wmb_pop_width_avg` | LSU/Cache | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |
| 104 | `sq_pop_width_avg` | LSU/Cache | 每周期平均宽度或请求/创建/弹出数量。 | 衡量吞吐能力、并发度和端口利用率。 | 平均值低不一定是瓶颈，需要结合 ready、full、stall。 |

## Latency 延迟分布完整字典

| ID | 指标 | 起点 | 终点 | 用途 | 注意 |
|---|---|---|---|---|---|
| 1 | `icache_refill_latency` | IFU/分支 | I-cache refill start | I-cache refill complete | 判断取指 refill 等待 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 2 | `biu_ar_to_r_latency` | BIU/AXI | AXI AR 握手 | 首个 R 握手 | 判断读响应首拍延迟 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 3 | `biu_aw_to_b_latency` | BIU/AXI | AXI AW 握手 | B 响应握手 | 判断写响应延迟 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 4 | `lfb_create_to_refill` | LSU/Cache | LFB 创建 | refill 完成 | 判断 miss refill 长尾 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 5 | `dutlb_arb_latency` | MMU/TLB/PTW | DUTLB refill 仲裁请求 | 仲裁完成 | 判断 DTLB refill 等待 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 6 | `iutlb_arb_latency` | MMU/TLB/PTW | IUTLB refill 仲裁请求 | 仲裁完成 | 判断 ITLB refill 等待 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 7 | `ptw_refill_latency` | MMU/TLB/PTW | JTLB PTW 请求 | PTW refill 完成 | 判断 page walk 等待 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 8 | `zero_retire_episode` | RTU/PST/退休 | 退休宽度变为 0 | 退休宽度恢复非 0 | 判断流水停顿片段长度 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 9 | `bad_spec_episode` | 其他 | bad speculation raw 原因出现 | 该原因消失 | 判断错误推测片段长度 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 10 | `frontend_bound_episode` | 其他 | frontend raw 原因出现 | 该原因消失 | 判断前端受限片段长度 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 11 | `memory_bound_episode` | 其他 | memory raw 原因出现 | 该原因消失 | 判断访存受限片段长度 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 12 | `backend_core_episode` | 其他 | backend core raw 原因出现 | 该原因消失 | 判断后端核心受限片段长度 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 13 | `rob_head_block_latency` | RTU/PST/退休 | ROB head 未完成阻塞 | head 不再阻塞 | 判断提交头阻塞时间 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 14 | `iq_ready_to_select` | 其他 | IQ 有 ready 但未 select | 出现 select | 判断 ready 后等待发射 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 15 | `iq_wait_to_ready` | 其他 | IQ 有 valid-not-ready | 同队列出现 ready | 判断依赖等待时间 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 16 | `ld_replay_pressure` | LSU/Cache | load replay 压力出现 | 压力释放 | 判断 LSU replay 持续时间 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 17 | `rb_create_to_wb_cmplt` | LSU/Cache | RB 创建 | 写回完成 | 判断 read buffer 完成等待 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 18 | `rb_create_to_wb_data` | LSU/Cache | RB 创建 | 写回数据有效 | 判断 read buffer 数据等待 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 19 | `pfu_pe_req_to_grant` | LSU/Cache | PFU prefetch 请求 | 请求获准 | 判断预取请求仲裁等待 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 20 | `pfu_pe_req_to_lfb` | LSU/Cache | PFU prefetch 请求 | LFB 创建 | 判断预取进入 miss/refill 路径等待 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 21 | `frontend_stall_episode` | 其他 | frontend stall 出现 | frontend stall 消失 | 判断前端停顿片段 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 22 | `ibuf_full_episode` | 其他 | IBUF full 出现 | IBUF 不再 full | 判断 IBUF 堵塞片段 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 23 | `ifu_to_id_supply` | IFU/分支 | IFU 有供给 | ID 接收有效 | 判断前端到 ID 供给延迟 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 24 | `mispred_to_retire` | 其他 | 退休侧误预测 | 退休恢复 | 判断误预测到提交恢复 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 25 | `flush_to_retire` | 其他 | retire ROB flush | 退休恢复 | 判断 flush 到提交恢复 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 26 | `mmu_va_to_pa` | MMU/TLB/PTW | VA 请求有效 | PA 返回有效 | 判断地址翻译等待 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 27 | `aiq0_wait_to_ready` | IDU/IQ/RF | 整数 issue queue AIQ0 有 valid-not-ready | 整数 issue queue AIQ0 出现 ready entry | 判断该队列依赖等待或 wakeup 延迟 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 28 | `aiq1_wait_to_ready` | IDU/IQ/RF | 整数 issue queue AIQ1 有 valid-not-ready | 整数 issue queue AIQ1 出现 ready entry | 判断该队列依赖等待或 wakeup 延迟 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 29 | `biq_wait_to_ready` | IDU/IQ/RF | 分支 issue queue BIQ 有 valid-not-ready | 分支 issue queue BIQ 出现 ready entry | 判断该队列依赖等待或 wakeup 延迟 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 30 | `lsiq_wait_to_ready` | IDU/IQ/RF | load issue queue LSIQ 有 valid-not-ready | load issue queue LSIQ 出现 ready entry | 判断该队列依赖等待或 wakeup 延迟 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 31 | `sdiq_wait_to_ready` | IDU/IQ/RF | store issue queue SDIQ 有 valid-not-ready | store issue queue SDIQ 出现 ready entry | 判断该队列依赖等待或 wakeup 延迟 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 32 | `viq0_wait_to_ready` | IDU/IQ/RF | 向量/浮点 issue queue VIQ0 有 valid-not-ready | 向量/浮点 issue queue VIQ0 出现 ready entry | 判断该队列依赖等待或 wakeup 延迟 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 33 | `viq1_wait_to_ready` | IDU/IQ/RF | 向量/浮点 issue queue VIQ1 有 valid-not-ready | 向量/浮点 issue queue VIQ1 出现 ready entry | 判断该队列依赖等待或 wakeup 延迟 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 34 | `aiq0_ready_to_issue` | IDU/IQ/RF | 整数 issue queue AIQ0 有 ready entry | 整数 issue queue AIQ0 issue/select | 判断 ready 后是否被端口/仲裁卡住 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 35 | `aiq1_ready_to_issue` | IDU/IQ/RF | 整数 issue queue AIQ1 有 ready entry | 整数 issue queue AIQ1 issue/select | 判断 ready 后是否被端口/仲裁卡住 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 36 | `biq_ready_to_issue` | IDU/IQ/RF | 分支 issue queue BIQ 有 ready entry | 分支 issue queue BIQ issue/select | 判断 ready 后是否被端口/仲裁卡住 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 37 | `lsiq_ready_to_issue` | IDU/IQ/RF | load issue queue LSIQ 有 ready entry | load issue queue LSIQ issue/select | 判断 ready 后是否被端口/仲裁卡住 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 38 | `sdiq_ready_to_issue` | IDU/IQ/RF | store issue queue SDIQ 有 ready entry | store issue queue SDIQ issue/select | 判断 ready 后是否被端口/仲裁卡住 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 39 | `viq0_ready_to_issue` | IDU/IQ/RF | 向量/浮点 issue queue VIQ0 有 ready entry | 向量/浮点 issue queue VIQ0 issue/select | 判断 ready 后是否被端口/仲裁卡住 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 40 | `viq1_ready_to_issue` | IDU/IQ/RF | 向量/浮点 issue queue VIQ1 有 ready entry | 向量/浮点 issue queue VIQ1 issue/select | 判断 ready 后是否被端口/仲裁卡住 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 41 | `dispatch_to_commit` | 其他 | 任意 dispatch create | 任意 ROB commit | 代表性 dispatch 到 commit 窗口 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 42 | `rob_full_episode` | RTU/PST/退休 | ROB full 出现 | ROB 不再 full | 判断 ROB 满持续时间 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 43 | `sq_create_to_pop` | LSU/Cache | SQ entry 创建 | SQ entry pop | 判断 store queue 生命周期 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 44 | `wmb_create_to_pop` | LSU/Cache | WMB entry 创建 | WMB entry pop | 判断 write merge buffer 生命周期 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 45 | `lfb_addr_create_to_pop` | LSU/Cache | LFB addr entry 创建 | LFB addr entry pop | 判断 LFB 地址 entry 生命周期 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 46 | `lfb_data_to_empty` | LSU/Cache | LFB data 有效 | LFB data empty | 判断 LFB 数据保持时间 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 47 | `biu_ar_to_rlast` | BIU/AXI | AXI AR 握手 | RLAST 握手 | 判断读事务完整返回延迟 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 48 | `biu_aw_to_b_full` | BIU/AXI | AXI AW 握手 | B 响应握手 | 判断完整写响应延迟 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 49 | `flush_to_fetch` | 其他 | retire ROB flush | fetch valid 恢复 | 判断前端恢复速度 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 50 | `flush_to_id` | 其他 | retire ROB flush | ID valid 恢复 | 判断取指到译码恢复速度 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 51 | `mispred_to_fetch` | 其他 | 退休侧误预测 | fetch valid 恢复 | 判断误预测后前端恢复 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 52 | `bht_mispred_episode` | IFU/分支 | BHT mispred 出现 | 该 episode 结束 | 判断方向误预测片段 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 53 | `pst_alloc_block_episode` | RTU/PST/退休 | PST/free-list 分配阻塞 | 分配恢复 | 判断物理寄存器资源阻塞持续时间 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |
| 54 | `pst_flush_recover` | RTU/PST/退休 | PST flush/recover 开始 | 恢复完成 | 判断 flush 后寄存器映射恢复时间 | 代表性单 active 窗口，不是逐 entry/逐 transaction 完整直方图。 |

## 仍然不是精确覆盖的指标

| 缺口 | 当前状态 | 若要精确需要 |
|---|---|---|
| 真正硬件 CPI Stack | 现在是 testbench priority classifier 加 raw overlap | RTL 内部 root-cause 仲裁和每周期唯一/多重归因 |
| 每个 IQ entry age | 现在是队列级 wait/ready episode | 在 IQ entry 内加 create/ready/select/pop 时间戳或 trace |
| 每个 ROB entry age | 现在有 ROB head 和 occupancy | 在 ROB entry 内加 create/complete/commit 时间戳 |
| 全 outstanding transaction latency | 现在有 outstanding depth 和单 active 延迟窗口 | 按 AXI ID 或 miss entry 建多槽计时器 |
| store-to-load forwarding 成功率 | 现在有 forward request、cancel、discard、spec fail | 定义统一 attempt/success/fail/violation 事件，并按 load 追踪 |
| 完整 predictor 表质量 | 现在有 L0/indirect/RAS/BHT 侧信号 | 每个 predictor lookup/hit/miss/correct/update/alias 统计 |
| cache bank/tag/data conflict | 现在有 D-cache arbiter req/grant/tag/data | cache 内部 bank/port/MSHR/LFB allocate fail 计数 |

## 对当前指标正确性的结论

1. 层级引用和信号拼写是正确的：静态检查 663 个引用无缺失。
2. 直接事件和 profile 的准确性较高，适合做性能瓶颈定位。
3. latency 类指标有意保持轻量，属于代表性 episode，不是全量事务追踪。
4. CPI stack 是 testbench 近似分类，不是硬件正式 PMU 归因。
5. 对当前 benchmark 分析来说，这套指标已经足够支撑：判断瓶颈方向、定位到 frontend/memory/backend/rename/ROB/IQ/BIU 等模块、指导下一步机制优化。
