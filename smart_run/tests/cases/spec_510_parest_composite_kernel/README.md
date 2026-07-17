# spec_510_parest_composite_kernel

`510.parest_r` 的单 ELF bare-metal L2+ 代理。在一个 `perf_monitor` 区间内
执行 finite-element/DoF setup 与 sparse solver 两种机制，目标动态指令占比
分别为 19.3611% 和 80.6389%。

| profile | 关键参数 | ROI 指令 | 预热指令 | 工作集 | DoF 实测占比 |
|---|---|---:|---:|---:|---:|
| quick | `dof=24x5, constraints=4, sparse=48x5, passes=1, iters=20, tail=13` | 108,350 | 0 | 2,880 B | 19.3670% |
| full | `dof=42x8, constraints=4, sparse=3800x8, passes=1, iters=1` | 497,534 | 277,686 | 244,480 B | 19.3135% |

使用 `SPEC_COMPOSITE_PROFILE=quick|full` 选择版本。full 的预热在
`perf_warmup_start/end` 内，位于性能统计区间之前。本程序不是 SPEC 源码，
也不是真实 SimPoint checkpoint；它只能作为 SimPoint 指导的机制代理。
