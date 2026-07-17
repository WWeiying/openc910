# spec_605_mcf_composite_kernel

`605.mcf_s` 的单 ELF bare-metal L2+ 代理。在一个 `perf_monitor` 区间内
执行 sort/comparator 与 pointer-rich pricing/tree 两种机制，目标动态指令
占比分别为 68.8677% 和 31.1323%。

| profile | 关键参数 | ROI 指令 | 预热指令 | 工作集 | sort 实测占比 |
|---|---|---:|---:|---:|---:|
| quick | `items=96, nodes=32, arcs=96, basket=8, sort=1+tail44, price=3` | 19,188 | 0 | 10,944 B | 68.9208% |
| full | `items=1400, nodes=4096, arcs=10330, basket=8, sort=1, price=1` | 462,143 | 189,100 | 501,504 B | 68.9027% |

使用 `SPEC_COMPOSITE_PROFILE=quick|full` 选择版本。full 的预热在
`perf_warmup_start/end` 内，位于性能统计区间之前。本程序不是 SPEC 源码，
也不是真实 SimPoint checkpoint；它只能作为 SimPoint 指导的机制代理。
