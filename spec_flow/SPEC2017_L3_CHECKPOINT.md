# SPEC CPU2017 L3 Checkpoint/Restore

## 1. 目标与结果口径

L3 的目标是运行原始 SPEC Linux ELF 的真实代表区间，不再用手写 composite kernel 代替 SPEC 行为。每个 SimPoint cluster 独立捕获 checkpoint，在 C910 RTL 中恢复、预热、测量固定长度 ROI，最后按 SimPoint 指令权重汇总。

```text
完整程序 BBV + SimPoint
        -> 冻结代表区间及来源
        -> 捕获寄存器、虚拟内存和 syscall 窗口
        -> system QEMU restore/replay 一致性验证
        -> C910 RTL restore + warmup + ROI
        -> SimPoint 加权结果
```

加权规则如下：

- benchmark CPI 为各 cluster CPI 的 SimPoint 权重算术平均。
- benchmark IPC 为 `1 / weighted_CPI`，不能直接平均各 cluster IPC。
- 事件先换算为 event/instruction 再按权重汇总。
- miss rate 等比例指标由加权后的分子事件率除以加权后的分母事件率。

只有全部必需 cluster 都有通过校验的 `rtl_result.json` 时，结果才能称为“多 SimPoint 加权的真实 SPEC RTL 代表区间结果”。

## 2. 已实现的完整链路

### 2.1 冻结代表区间

`l3_checkpoint_plan.py` 读取完整 BBV、command map、SimPoint 和权重，将全局 SimPoint interval 转换为具体 SPEC command 内的动态指令坐标。计划同时冻结 manifest、ELF SHA-256、命令、输入目录、QEMU seed 和保留虚拟地址范围，防止后续捕获使用了不同二进制或不同输入。

### 2.2 QEMU 用户态捕获

`simpoint_probe.so` 在一次 command 运行中处理多个 checkpoint 和 ROI 终点，捕获：

- PC、32 个整数寄存器、32 个浮点寄存器和 FCSR；
- guest 的低地址虚拟内存映射及 resident page 内容；
- 堆、栈、TLS、动态链接器和共享库已映射页面；
- checkpoint 与 ROI 终点的动态指令坐标；
- warmup、ROI 以及 checkpoint 到 ROI 终点的 syscall 计数；
- TB 边界误差、ELF、命令和捕获来源。

QEMU plugin 的 TB callback 位于 TB 执行前，因此 checkpoint 状态坐标是 `current_insns - tb_insns`，PC 以 TB entry PC 为准。计划捕获点与实际状态通常相差一个 TB，严格校验上限为 64 条指令。

### 2.3 Checkpoint 打包与校验

`l3_parse_probe.py` 将原始 probe 输出归一化为固定寄存器编号和独立内存镜像；`l3_build_checkpoint_package.py` 生成 `checkpoint.json`，记录所有产物的大小和 SHA-256。校验器会拒绝以下状态：

- ELF、SPEC manifest、command 或计划坐标不一致；
- 寄存器、memory map、memory image、syscall trace 或 ROI reference 缺失；
- TB 边界误差超过 64 条指令；
- resident memory 超过 RTL 的 32 MiB SRAM；
- checkpoint 到 ROI 终点包含 bare-metal restore 尚不支持的 syscall；
- QEMU restore/replay 未通过。

### 2.4 QEMU 精确重放

恢复器将 checkpoint 页嵌入 ELF，构造 Sv39 页表，从 M-mode 切换到 U-mode，并恢复 PC、全部整数/浮点寄存器和 FCSR。`restore_replay.so` 从 checkpoint PC 开始按动态指令数精确执行到参考终点，比较 PC、32 GPR、32 FPR 和 FCSR，共 66 项状态。

QEMU 校验使用不包含 RTL cache-control 初始化的可移植恢复镜像。公开 Xuantie QEMU 的 C910 system model不能可靠执行 `mcor` 全 cache/预测器失效序列，因此该序列由 RTL 运行单独验证。

### 2.5 C910 RTL 恢复与测量

`l3_generate_restore.py --rtl` 会：

- 将 captured pages 紧凑放入 32 MiB 物理 SRAM；
- 离线构造 Sv39 三级页表，不在 RTL 中逐页建表；
- 为叶子 PTE 写入 C910 `PTE[63:59]=0xf` 的普通可缓存内存属性；
- 开启 `MXSTATUS.MAEE`，并采用现有 `smart_run/tests/lib/crt0.S` 同口径的 `mcor/mhcr/mhint/mccr2` 初始化；
- 生成 16 个 SRAM byte-lane 文件；
- 恢复 U-mode 状态并跳转到真实 checkpoint PC。

`tb.v` 在退休端检测 checkpoint PC。它先按退休指令数执行 warmup，再对 ROI 记录 cycles、retired instructions、42 个基础事件、805 个 detail、189 个 profile 和 54 组 latency 分布。恢复器启动、页表和 CSR 初始化均发生在 ROI 之前，不计入结果。

`l3_run_rtl.py` 完成严格校验、镜像生成、VCS 调用、日志解析和结果归档。未知态指标保存为 `null` 并列入 `unknown_metrics`，不会伪装成 0。

## 3. 当前状态

当前冻结的 `spec_checkpoints/l3_plan.json` 包含 41 个 benchmark、186 个 SimPoint region：

| 项目 | 当前状态 |
|---|---:|
| plan 中 benchmark | 41 |
| plan 中 region | 186 |
| 可进入捕获的 benchmark | 39 |
| 默认批量实际选择的可捕获 region | 178 |
| fork 身份尚不支持 | `500.perlbench_r`、`600.perlbench_s` |
| 尚未进入该版 plan | `621.wrf_s`、`638.imagick_s` |

已完成一次 `505.mcf_r` 小区间端到端功能验证。它用于证明 checkpoint/restore 机制，不是正式 SPEC 性能数据：

| 检查项 | 结果 |
|---|---:|
| checkpoint 目标/实际动态指令 | 100000 / 99995 |
| resident memory | 10559488 B |
| checkpoint 到 ROI 终点 syscall | 0 |
| QEMU replay 指令 | 1001 |
| QEMU 状态比较 | 66 项，0 差异 |
| RTL 到达 checkpoint PC | 通过 |
| RTL warmup / ROI | 105 / 900 条退休指令 |
| RTL ROI cycles / instructions | 4183 / 900 |
| RTL retirement overshoot | 0 |
| 基础/detail/profile/latency | 42 / 805 / 189 / 54 |
| 当前 unknown detail/profile/latency | 0 / 0 / 0 |

这证明了“捕获、打包、QEMU 重放、C910 页表/cache 配置、RTL 恢复、计数器解析、加权输入格式”的闭环。正式 186-region campaign 尚未完成，不能用上述 900 指令 CPI 代表 `505.mcf_r` 或 SPEC CPU2017 成绩。

## 4. 操作命令

### 4.1 构建 QEMU plugins

```bash
make -C tools/qemu-plugins
```

### 4.2 生成冻结计划

```bash
python3 spec_flow/l3_checkpoint_plan.py \
  --suite all --size ref \
  --warmup-instructions 10000000 \
  --out spec_checkpoints/l3_plan.json \
  --report spec_checkpoints/L3_CHECKPOINT_PLAN.md
```

### 4.3 捕获 checkpoint

不加 `--execute` 只打印命令：

```bash
python3 spec_flow/l3_run_probes.py \
  --plan spec_checkpoints/l3_plan.json \
  --bench 505.mcf_r
```

真正执行：

```bash
python3 spec_flow/l3_run_probes.py \
  --plan spec_checkpoints/l3_plan.json \
  --bench 505.mcf_r \
  --output-root spec_checkpoints/probes \
  --execute
```

同一 SPEC command 的多个 cluster 会在一次 QEMU 运行中捕获。脚本复制独立 workspace，不修改原 SPEC run directory。

### 4.4 解析并打包

每个 command probe 完成后解析其 `probe_map.json`：

```bash
python3 spec_flow/l3_parse_probe.py \
  --probe-map spec_checkpoints/probes/505.mcf_r.command_0/probe_map.json \
  --out-root spec_checkpoints/packages
```

随后生成 checkpoint manifest 并先做 capture-stage 校验：

```bash
python3 spec_flow/l3_build_checkpoint_package.py \
  --plan spec_checkpoints/l3_plan.json \
  --checkpoint-root spec_checkpoints/packages \
  --bench 505.mcf_r

python3 spec_flow/validate_l3_checkpoint.py \
  --plan spec_checkpoints/l3_plan.json \
  --checkpoint-root spec_checkpoints/packages \
  --stage capture --allow-missing
```

### 4.5 QEMU restore/replay

对每个 package 生成 system QEMU 恢复 ELF，并做 66 项终点状态比较：

```bash
python3 spec_flow/l3_generate_restore.py \
  --package spec_checkpoints/packages/<checkpoint_id> \
  --output spec_checkpoints/qemu_restore/<checkpoint_id> \
  --physical-base 0x80000000

python3 spec_flow/l3_validate_restore_replay.py \
  --package spec_checkpoints/packages/<checkpoint_id> \
  --restore-elf spec_checkpoints/qemu_restore/<checkpoint_id>/restore.elf
```

完成后执行 restore-stage 严格校验：

```bash
python3 spec_flow/validate_l3_checkpoint.py \
  --plan spec_checkpoints/l3_plan.json \
  --checkpoint-root spec_checkpoints/packages \
  --stage restore --allow-missing
```

### 4.6 RTL 编译与运行

EDA 命令必须在已授权的非沙箱环境执行：

```bash
make -C smart_run compile DUMP=off PERF_DETAIL=on
```

先检查某个 region 将执行的命令：

```bash
python3 spec_flow/l3_run_rtl.py \
  --plan spec_checkpoints/l3_plan.json \
  --checkpoint-root spec_checkpoints/packages \
  --rtl-results spec_checkpoints/rtl_results \
  --build-root spec_checkpoints/rtl_build \
  --checkpoint 505.mcf_r.ref.cluster_0 \
  --dry-run
```

去掉 `--dry-run` 即执行。省略所有 `--checkpoint` 时默认运行计划中 178 个 capture-ready region，benchmark 级已标记 unsupported 的 region 会被排除并在加权报告中列明。中断后若 RTL 日志已经完整，只重新解析而不重跑：

```bash
python3 spec_flow/l3_run_rtl.py \
  --plan spec_checkpoints/l3_plan.json \
  --checkpoint-root spec_checkpoints/packages \
  --rtl-results spec_checkpoints/rtl_results \
  --build-root spec_checkpoints/rtl_build \
  --checkpoint 505.mcf_r.ref.cluster_0 \
  --skip-generate --parse-existing
```

### 4.7 SimPoint 加权

```bash
python3 spec_flow/aggregate_l3_results.py \
  --plan spec_checkpoints/l3_plan.json \
  --rtl-results spec_checkpoints/rtl_results \
  --out-json spec_checkpoints/L3_WEIGHTED_RESULTS.json \
  --out-md spec_checkpoints/L3_WEIGHTED_RESULTS.md
```

默认缺少任一 region 就失败；`--allow-partial` 只能用于进度检查，不能作为正式 benchmark 结果。

## 5. 输出目录

```text
spec_checkpoints/
  l3_plan.json
  probes/<bench>.command_<n>/
  packages/<checkpoint_id>/
    checkpoint.json
    probe/registers.json
    probe/memory.bin
    probe/memory_map.json
    probe/syscall_trace.json
    reference/roi_end_registers.json
    replay/replay_validation.json
  rtl_build/<checkpoint_id>/
    restore.elf
    restore.asm
    rtl_lanes/checkpoint.ram{0..15}.hex
  rtl_results/<checkpoint_id>/
    rtl.log
    rtl_result.json
    rtl_command.json
    pc_trace.log
```

## 6. 准确性边界与剩余工作

1. **Syscall**：当前要求 checkpoint 到 ROI 终点的整个 restore 窗口 syscall 为 0。文件 I/O、`mmap/brk`、线程同步或退出落在 warmup 或 ROI 内都会被严格拒绝。
2. **多进程**：perlbench 的 fork 后进程身份和多地址空间 checkpoint 尚未实现。
3. **内存容量**：testbench SRAM 为 32 MiB；resident checkpoint 超限时必须扩展 RTL memory model 或缩小可证明等价的工作集，不能静默丢页。
4. **权限来源**：QEMU user `/proc/self/maps` 不能区分 guest 的精确 ELF execute 属性。当前只读映射恢复为 RX、可写映射恢复为 RW；后续应结合 ELF `PT_LOAD` 和动态加载模块精确恢复权限。
5. **QEMU 与 C910 属性**：66 项精确重放校验覆盖可移植 Sv39 恢复版本；C910 的 `MAEE`、PTE 扩展属性和 cache-control 序列由 RTL 到达 checkpoint、无 trap 执行及 I/D-cache 事件共同验证。公开 QEMU system model不能作为这些实现相关 CSR 的等价参考。
6. **TB 边界**：捕获起点是目标之前最近的 TB entry。实际 warmup 会按 `roi_start - observed_checkpoint` 修正；ROI 长度仍使用计划中的固定指令数。严格 syscall 门槛使用两个实际捕获边界的累计计数差，warmup/ROI 分项统计只具有 TB 粒度。
7. **短 warmup**：冒烟测试只有约 100 条 warmup，cache 和预测器明显未稳态，不能用于性能结论。正式计划使用 1000 万条 warmup。
8. **未知态**：冒烟验证中 detail、profile 和 latency 的 `unknown_metrics` 均为空。后续正式运行仍保留 `X/Z -> null` 的防伪逻辑，任何新的未知态都不会被记为 0。
9. **运行成本**：ref SimPoint 可能位于数千亿动态指令处。QEMU capture 与 1 亿指令 RTL ROI 都是长任务，应分批调度、保存 package，并逐级校验后再进入 RTL。
10. **与 L2 后台任务的关系**：L3 使用独立 `spec_checkpoints/` workspace，不会修改 L2 composite kernel 结果；但两者会竞争 CPU、内存和磁盘。只能基于已完成且 manifest 校验通过的 BBV 生成冻结计划，不能一边改写同一 BBV/manifest 一边捕获。

当前最重要的后续工作是：补齐 `621.wrf_s`、`638.imagick_s` 的冻结输入，解决 perlbench fork，批量捕获 39 个当前可支持 benchmark，统计 32 MiB/syscall 合格率，再按合格 region 分批运行 RTL。
