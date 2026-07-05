# PERF_DETAIL 细粒度性能指标说明

本文档说明 `smart_run/logical/tb/tb.v` 中 `PERF_DETAIL` 统计层的用途、输出文件、指标含义和信号准确性边界。

`PERF_DETAIL` 是 testbench 侧性能观测逻辑，不修改 CPU 功能 RTL。它通过层级引用读取现有 RTL 内部信号，输出更细的事件计数、平均占用/宽度和延迟分布，用于分析 C910 乱序超标量流水线瓶颈。

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
| `<case>.detail.perf` | 新增细粒度指标：700 个事件计数、104 个平均占用/宽度 profile、54 个延迟分布 |
| `<case>.summary.txt` | benchmark 简要结果 |
| `<case>.run.vcs.log` | 完整仿真日志，包含 `.perf` 和 `.detail.perf` 表格 |

完整编号索引见 `PERF_DETAIL_INDEX.md`。该索引从 `tb.v` 的 `print_detail_row`、`print_profile_row`、`print_latency_row` 自动抽取，覆盖 `.detail.perf` 中全部 detail/profile/latency 指标编号和输出名。

## 静态核查结论

已对 `tb.v` 中的层级引用做静态核查：

| 核查项 | 结果 |
|---|---|
| 检查宏数量 | 45 个 RTL 层级宏 |
| 检查信号引用 | 663 个 `` `MACRO.signal`` 引用 |
| RTL 源码匹配 | 全部能在 `C910_RTL_FACTORY/gen_rtl` 对应模块源码中找到 |
| detail 编号 | 1-700 连续，无重复、无缺号 |
| profile 编号 | 1-104 连续，无重复、无缺号 |
| latency 编号 | 1-54 连续，无重复、无缺号 |
| 脚本检查 | `compare_bench.py` 语法通过，`run_bench.sh` 语法通过，diff 空白检查通过 |

注意：这是静态源码核查，不等同于 EDA elaboration。它能确认信号名和模块来源正确，但不能替代一次真正的 `make compile PERF_DETAIL=on`。

## 指标准确性等级

当前指标分成三类，分析时要区分使用。

| 等级 | 含义 | 典型指标 | 使用建议 |
|---|---|---|---|
| 精确事件 | 直接采样 RTL 的 valid/full/stall/handshake 脉冲或状态位 | `biu_ar_hs_deep`、`lfb_addr_pop_entry`、`wmb_entry_pop_deep`、`rob_commit0` | 可以直接作为事件次数或周期占比使用 |
| 精确宽度/占用 | 对 RTL valid 向量做 popcount 或对多路 valid 求和 | `rob_occ_avg`、`iq_ready_width_avg`、`sq_pop_width_avg` | 可以作为平均并发度、资源压力使用 |
| 代表性延迟窗口 | testbench 只跟踪每类事件的一个 active 窗口，不为每个 entry/transaction 建时间戳 | `dispatch_to_commit`、`sq_create_to_pop`、`biu_ar_to_rlast` | 用于判断“是否存在长等待”，不能当作全量逐事务延迟直方图 |

还有一个边界：`detail_counter` 采用 `detail_n_delay` 累加，即事件采样有一拍延迟。这与原有 event 统计风格一致，对长时间 benchmark 影响很小，但 phase 边界附近会有一拍级误差。

`biu_rd_outstanding_avg` 和 `biu_wr_outstanding_avg` 采样的是 testbench 寄存器中的上一拍 outstanding 深度，因为 outstanding 深度在同一个时钟块里用非阻塞赋值更新。它适合看平均并发趋势；如果只分析极短 phase，边界处同样存在一拍级误差。

## 二次深度核查结论

| 核查点 | 结论 |
|---|---|
| 层级和信号名 | 45 个宏、663 个信号引用均能在对应生成 RTL 文件中找到 |
| IQ ready/not-ready/select | `entry_vld`、`entry_ready`、`entry_issue_en` 在 AIQ/BIQ/LSIQ/SDIQ/VIQ RTL 中直接存在；宽度和队列压力统计可信 |
| L0 BTB / indirect BTB / RAS | 信号来自 `ct_ifu_ibctrl.v` 的接口赋值；事件语义与命名一致 |
| BHT | `bht_pred_array_rd`、`bht_sel_array_rd`、`wr_buf_hit`、`bju_mispred` 均来自 `ct_ifu_bht.v` 内部逻辑；是 BHT 活动/旁路/误预测侧信号，不是完整预测准确率 |
| SQ/WMB/LFB 生命周期 | create/pop 信号来自 per-entry 向量；detail 中 `*_entry_*` 是 any-entry 事件，profile 中 `sq_pop_width_avg`、`wmb_pop_width_avg` 才是 pop 宽度 |
| BIU outstanding/latency | 当前采用 AXI-facing 握手口径；对总线压力判断正确，但不是按 ID 匹配的全事务延迟直方图 |
| flush 指标 | detail 的 `flush_*_invalid_cycle` 是 flush 当拍状态；latency 的 `flush_to_*` 才表示恢复窗口 |

## 关键 RTL 信号来源

### Frontend / 分支预测

| 指标组 | RTL 来源 | 准确性说明 |
|---|---|---|
| L0 BTB | `ct_ifu_ibctrl.v` 中 `ibctrl_ibdp_l0_btb_hit/miss/mispred/wait` | 这些信号由 `ipctrl_ibctrl_l0_btb_*` 转接到 IBCTRL，能反映 L0 BTB 命中、miss、误预测和等待状态 |
| indirect BTB | `ct_ifu_ibctrl.v` 中 `ibctrl_ind_btb_check_vld`、`ibctrl_ind_btb_fifo_stall`、`ibctrl_pcfifo_if_ind_btb_miss` | `ind_btb_check` 是间接跳转检查有效；`ind_btb_miss` 来自 `~ind_btb_rd_vld`，是 miss 侧 proxy |
| RAS | `ct_ifu_ibctrl.v` / `ct_ifu_ras.v` 中 RAS redirect、mistaken、push/pop/full/empty | 能观察 RAS 活动和错误，但不是完整 RAS 表项级统计 |
| BHT | `ct_ifu_bht.v` 中 `bht_pred_array_rd`、`bht_sel_array_rd`、`wr_buf_hit`、`bju_mispred` | `bht_pred_array_rd` 包含条件分支读、flush/mispred 相关读；`wr_buf_hit` 是 BHT 更新缓冲命中；不是“BHT 预测准确率”的完整分母/分子 |
| frontend recovery | `ifctrl_ipctrl_vld`、`ctrl_top_id_inst0_vld` | `flush_to_fetch` 和 `flush_to_id` 分别用取指有效、ID 有效作为恢复终点，是恢复窗口 proxy |

### Rename / ROB / IQ

| 指标组 | RTL 来源 | 准确性说明 |
|---|---|---|
| rename stall | `ct_idu_id_ctrl.v`、`ct_idu_ir_ctrl.v`、`ct_rtu_pst_*` | ID/IR stall 和物理寄存器 alloc valid/block 直接来自 RTL，适合判断 rename/free-list 压力 |
| ROB occupancy | `rtu_had_debug_info[24:18]` | 来自 RTU debug bus，适合看 ROB 饱和程度；不是逐 ROB entry age |
| ROB commit/head | `ct_rtu_rob_rt.v` 中 `rob_commit*`、`rob_read0_*`、`rtu_had_inst_exe_dead` | oldest ROB 状态和 commit slot 是直接信号，适合判断 head 阻塞 |
| IQ ready/not-ready/select | `ct_idu_is_aiq*`、`biq`、`lsiq`、`sdiq`、`viq*` 中 entry valid/ready/issue_en | entry 向量直接可见，ready/not-ready 个数准确；`*_wait_to_ready` 是队列级 episode，不是逐 entry age |
| dispatch create | `ct_idu_is_ctrl.v` 中 `ctrl_*_create*_en` | 直接表示 dispatch 接受进入各 issue queue 的 create enable |

### LSU / Memory

| 指标组 | RTL 来源 | 准确性说明 |
|---|---|---|
| LQ/SQ/RB/LFB/WMB occupancy/full | 各 LSU queue/buffer 的 entry valid/full 信号 | 直接反映资源占用和结构阻塞 |
| SQ lifecycle | `ct_lsu_sq.v` 中 `sq_create_vld`、`sq_entry_pop_to_ce_grnt` | create/pop 是 per-entry 向量，事件计数准确；`sq_create_to_pop` 是代表性窗口 |
| WMB lifecycle/forward | `ct_lsu_wmb.v` 中 `wmb_entry_create_vld`、`wmb_entry_pop_vld`、`wmb_ld_dc_fwd_req`、`wmb_ld_dc_cancel_acc_req` | forward/cancel/discard 是真实路径信号；没有统一 store-to-load success/fail 完整定义 |
| LFB lifecycle | `ct_lsu_lfb.v` 中 `lfb_addr_entry_rb_create_vld`、`lfb_addr_entry_pfu_create_vld`、`lfb_addr_entry_pop_vld`、`lfb_data_create_vld` | create/pop/data_create 都是直接信号；latency 是单 active 窗口 |
| D-cache arbiter | `ct_lsu_dcache_arb.v` 中 request/grant/tag/data/dirty/borrow/serial 信号 | 能看仲裁源和 tag/data 请求，但没有 bank conflict、MSHR 精确统计 |
| load replay/spec fail | `ct_lsu_ld_da.v`、`ct_lsu_st_da.v` discard/spec_fail 信号 | 能看 replay/discard/spec fail 压力，但没有逐 load 的 violation age |
| BIU/AXI | `ct_biu_read_channel.v`、`ct_biu_write_channel.v` 中 AR/R/W/B valid/ready/last | handshake 事件准确；outstanding depth 采用 AXI-facing 口径，由 testbench 用 AR-RLAST、AW-B 外部握手维护；它不是 core 已消费响应的口径 |

### MMU / TLB / PTW

| 指标组 | RTL 来源 | 准确性说明 |
|---|---|---|
| IUTLB/DUTLB/JTLB miss | `ct_mmu_top.v` 的 hpcp/miss 信号 | 直接反映 TLB miss 侧事件 |
| TLB refill arbitration | `iutlb_arb_req/cmplt`、`dutlb_arb_req/cmplt` | 请求/完成窗口可用于判断 refill 等待 |
| PTW | `jtlb_ptw_req`、`ptw_arb_req`、`ptw_jtlb_ref_cmplt`、`ptw_jtlb_ref_data_vld` | 能观察 page walk 活动和完成 |
| VA-to-PA | IFU/LSU VA valid 到 PA valid | 代表性窗口，多个并发请求不会全部独立计入 |

## 输出表 1：事件计数 Detail

`Detail` 表每行输出：

| 列 | 含义 |
|---|---|
| `Perf Count` | 选定 phase 内事件计数或状态为 1 的周期数 |
| `Retired Inst` | 选定 phase 内退休指令数 |
| `Per KInst` | 每 1000 条退休指令的事件次数 |
| `Cycles %` | 事件周期数 / phase 周期数 |

主要事件组如下。

| 组 | 代表指标 | 用途 |
|---|---|---|
| ID/backend stall | `id_ctrl_stall`、`id_ir_stall`、`id_split_long_stall`、`rtu_rob_full`、`ir_preg_not_vld` | 判断前端已经送到 ID 后，是否被 rename/ROB/free-list/长指令阻塞 |
| flush/recovery | `rtu_global_flush`、`rtu_ifu_flush`、`iu_pipe0_flush`、`lsu_spec_fail_flush` | 判断控制流或内存推测失败导致的清流水 |
| RF launch fail | `rf_pipe*_lch_fail`、`rf_pipe*_src_no_rdy`、`rf_pipe*_preg/vreg_conflict` | 判断 issue 后进入 RF 时是否因源操作数或读端口冲突失败 |
| 宽度分布 | `id_widthN_cycle`、`ir_widthN_cycle`、`is_widthN_cycle`、`rf_launch_widthN_cycle`、`retire_widthN_cycle` | 判断流水各级实际宽度是否低于设计宽度 |
| ROB/IQ 压力 | `rob_occ_ge*`、`rob_head_*`、`*_ready_any`、`*_valid_not_ready`、`*_issue_select_any` | 判断 ROB 或 issue queue 是否满、是否 ready 但选不出去 |
| 分支预测 | `retire_bht_mispred`、`retire_jmp_mispred`、`l0_btb_*`、`ind_btb_*`、`ras_*`、`bht_*` | 判断分支预测、BTB/RAS/BHT 是否造成气泡 |
| I-cache/frontend | `icache_refill_*`、`ifu_ibuf_full`、`ifu_pcfifo_full_stall`、`ifu_bypass_inst_vld`、`ifu_merge_inst_vld` | 判断取指供给和前端缓存/队列压力 |
| flush 当拍状态 | `flush_fetch_invalid_cycle`、`flush_id_invalid_cycle` | 只表示 retire ROB flush 当拍 fetch 或 ID 是否无有效指令；完整恢复时间看 latency 的 `flush_to_fetch`、`flush_to_id`、`flush_to_retire` |
| D-cache/LSU | `dcache_*_miss`、`ld/st_utlb_miss`、`lq/sq/rb/lfb/wmb_*`、`dca_*` | 判断访存 miss、队列满、D-cache 仲裁压力 |
| SQ/WMB/LFB lifecycle | `sq_entry_create_deep`、`sq_entry_pop_deep`、`wmb_entry_create_deep`、`wmb_entry_pop_deep`、`lfb_*_entry` | 判断内存子系统每类 buffer 创建/释放是否顺畅 |
| BIU/AXI | `biu_*valid`、`biu_*handshake`、`biu_*backpressure`、`biu_*outstanding*` | 判断总线请求是否被外部 ready/response 限制 |
| PST/free-list | `preg/ereg_alloc*_block`、`preg_alloc_avail0/4`、`ereg_alloc_avail0/4`、`pst_*recover*` | 判断物理寄存器分配和 flush rollback 压力 |
| CPI stack proxy | `cpi_stack_*`、`zero_*_raw`、`zero_multi_raw_cause` | 粗分 zero-retire 周期原因，辅助定位大方向 |

## 输出表 2：平均宽度/占用 Profile

`Profile` 表每行输出：

| 列 | 含义 |
|---|---|
| `Sum Value` | phase 内每周期值的累加 |
| `Cycles` | phase 周期数 |
| `Avg / Cycle` | 平均每周期值 |

关键 profile：

| 指标 | 含义 |
|---|---|
| `id/ir/is_width_avg` | ID、IR/rename、IS/dispatch 可见平均宽度 |
| `rf_launch_width_avg`、`retire_width_avg` | RF launch 和 retire 平均宽度 |
| `rob_occ_avg` | ROB 平均占用 |
| `aiq0/1_occ_avg`、`biq_occ_avg`、`lsiq_occ_avg`、`sdiq_occ_avg`、`viq0/1_occ_avg` | 各 issue queue 平均占用 |
| `lq/sq/rb/lfb/wmb_occ_avg` | LSU 各队列/buffer 平均占用 |
| `iq_ready_width_avg`、`iq_not_ready_width_avg`、`iq_select_width_avg` | 全部 IQ ready、valid-not-ready、select entry 平均数量 |
| `int/lsu/vec_iq_ready_avg`、`int/lsu/vec_iq_not_ready_avg` | 按整数/LSU/向量后端拆分的 ready/not-ready 压力 |
| `aiq0/1_not_ready_avg`、`biq_not_ready_avg`、`lsiq_not_ready_avg`、`sdiq_not_ready_avg`、`viq0/1_not_ready_avg` | 单个 issue queue 的 valid-not-ready 深度 |
| `preg/ereg/freg_vreg_alloc_req/vld/block_avg` | 物理寄存器申请、可分配、阻塞宽度 |
| `preg_alloc_avail_avg`、`ereg_alloc_avail_avg` | 每周期可供 rename 使用的 PREG/EREG 分配结果数量 |
| `dca_ld/st_req_width_avg`、`dca_ld/st_grnt_width_avg` | D-cache arbiter 请求和授权宽度 |
| `lfb/wmb/rb_*_avg` | LFB/WMB/RB create、pop、wakeup、BIU request 等平均活动 |
| `biu_rd_outstanding_avg`、`biu_wr_outstanding_avg` | testbench 维护的 BIU read/write outstanding 平均深度 |
| `cpi_raw_cause_avg` | 每周期同时出现的 raw CPI cause 数，越大说明 stall 归因重叠越严重 |

## 输出表 3：延迟分布 Latency

`Latency` 表每行输出：

| 列 | 含义 |
|---|---|
| `Samples` | 完成采样的 episode 数 |
| `Avg Cycles` | 平均等待周期 |
| `<=4/<=8/<=16/<=32/<=64/>64` | 延迟桶分布 |

关键 latency：

| 指标 | 起点 | 终点 | 准确性 |
|---|---|---|---|
| `icache_refill_latency` | `l1_refill_ifctrl_start` | `l1_refill_ifctrl_trans_cmplt` | 单活动窗口，代表 I-cache refill 等待 |
| `biu_ar_to_r_latency` | AR handshake | 第一个外部 R handshake | AXI-facing 首拍读响应代表窗口，不按 ID 匹配 |
| `biu_ar_to_rlast` | AR handshake | 外部 RLAST handshake | AXI-facing 完整读事务代表窗口，不等同于 core 消费完成 |
| `biu_aw_to_b_latency` / `biu_aw_to_b_full` | AW handshake | 外部 B handshake | AXI-facing 写响应代表窗口 |
| `dutlb_arb_latency`、`iutlb_arb_latency` | TLB refill arb req | arb cmplt | 代表 TLB refill 仲裁等待 |
| `ptw_refill_latency` | JTLB PTW req | PTW refill complete | 代表 page walk 等待 |
| `zero_retire_episode` | retire width 为 0 | retire width 非 0 | 代表流水停顿片段 |
| `bad/frontend/memory/backend_*_episode` | CPI proxy 分类进入该状态 | 离开该状态 | 代表该类瓶颈持续时间 |
| `rob_head_block_latency` | oldest ROB entry 未完成 | oldest ROB 不再阻塞 | 代表 ROB head 阻塞持续时间 |
| `*_wait_to_ready` | 某 IQ 有 valid-not-ready | 同队列出现 ready entry | 队列级 proxy，不是逐 entry |
| `*_ready_to_issue` | 某 IQ ready 但未 issue | 同队列 issue_en | 队列级 proxy，不是逐 entry |
| `dispatch_to_commit` | 任意 dispatch create | 任意 ROB commit | 代表性窗口，不是同一条指令 |
| `sq_create_to_pop`、`wmb_create_to_pop`、`lfb_addr_create_to_pop` | 对应 buffer create | 对应 buffer pop | 单 active 窗口，不是全 entry age |
| `flush_to_fetch`、`flush_to_id`、`flush_to_retire` | retire ROB flush | fetch valid / ID valid / retire 恢复 | 恢复路径 proxy |
| `mispred_to_fetch`、`mispred_to_retire` | retire-side mispredict | fetch valid / retire 恢复 | 分支恢复 proxy |
| `pst_alloc_block_episode`、`pst_flush_recover` | free-list block / PST flush | alloc 恢复 | 物理寄存器恢复 proxy |

延迟采样的关键限制：同一类 latency 只维护一个 active 计时器。如果多个 miss、多个 SQ entry、多个 WMB entry 同时存在，后来的同类事件不会独立建样本。因此它适合看“是否有长尾等待”，不适合做逐 entry/逐 transaction 全量 latency histogram。

## 如何用这些指标定位瓶颈

建议按以下顺序看：

1. 先看 `<case>.perf` 的 IPC、Backend Stall、Frontend Stall、I-cache/D-cache miss、branch miss。
2. 再看 `.detail.perf` 的 `retire_width_avg` 和 `retire_width0_cycle`。如果 retire width 经常为 0，继续看 CPI proxy。
3. 看 `cpi_stack_*` 和 `zero_*_raw`，判断大方向是 bad speculation、frontend、memory 还是 backend core。
4. 如果是 frontend：看 `icache_refill_*`、`ifu_ibuf_full`、`ifu_pcfifo_full_stall`、`l0_btb_*`、`ind_btb_*`、`bht_*`、`flush_to_fetch`。
5. 如果是 memory：看 `dcache_*_miss`、`ld/st_utlb_miss`、`lq/sq/rb/lfb/wmb_*`、`dca_*`、`biu_*backpressure`、`biu_*outstanding*`、`*_to_pop` latency。
6. 如果是 backend core：看 `rob_occ_avg/ge*`、`rob_head_block_latency`、`iq_ready/not_ready/select`、`rf_pipe*_src_no_rdy`、`preg/ereg_alloc*_block`。
7. 如果是 bad speculation：看 `retire_*mispred`、`iu_*mispred`、`l0_btb_mispred`、`bht_bju_mispred`、`ld/st_spec_fail`、`flush_to_*`。

常见判断：

| 现象 | 优先查看 |
|---|---|
| IPC 低但 miss 不高 | width/profile：`id/ir/is/rf/retire_width_avg`、`retire_width0_cycle` |
| ROB 满 | `rob_occ_avg`、`rob_occ_ge64/ge96`、`rob_head_block_latency`、`retire_width_avg` |
| IQ 满或 ready 但发不出 | `*_full`、`*_ready_any`、`*_issue_select_any`、`*_ready_to_issue` |
| 源操作数未就绪 | `rf_pipe*_src_no_rdy`、`*_wait_to_ready`、`iq_not_ready_width_avg` |
| free-list 限制 rename | `preg/ereg_alloc*_block`、`preg_alloc_avail0`、`ereg_alloc_avail0` |
| D-cache/LSU 限制 | `dca_*`、`lfb_*`、`rb_*`、`wmb_*`、`sq_*`、`ld_*discard*` |
| 总线/内存系统限制 | `biu_*backpressure`、`biu_rd/wr_outstanding_avg`、`biu_ar_to_rlast`、`biu_aw_to_b_full` |
| 分支恢复代价高 | `retire_bht_mispred`、`retire_jmp_mispred`、`flush_to_fetch`、`mispred_to_fetch`、`flush_to_retire` |

## 仍然不是精确覆盖的指标

当前已经足够做瓶颈定位和机制探索，但以下内容还不是发表级“精确归因”：

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
3. latency 类指标有意保持轻量，属于“代表性 episode”而不是全量事务追踪。
4. CPI stack 是 testbench 近似分类，不是硬件正式 PMU 归因。
5. 对当前 benchmark 分析来说，这套指标已经足够支撑：判断瓶颈方向、定位到 frontend/memory/backend/rename/ROB/IQ/BIU 等模块、指导下一步机制优化。
