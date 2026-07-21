# SPEC CPU2017 L2+ Composite Kernel 映射

> 当前文件是最终发布前的过渡状态。严格 L2+ 完成后，
> `generate_l2plus_overviews.py` 会从 ref 映射、quick/full 特征契约和干净
> RTL 证据重新生成逐项 43-case 表格，并由 `finalize_l2plus.sh` 事务化发布。

## 当前口径

- 23 个 Rate 和 20 个 Speed benchmark 各自对应一个独立 bare-metal
  composite ELF，共 43 个 ELF；Rate/Speed 不共享 case。
- 每个 composite 包含 2–3 个机制 phase。SimPoint cluster 被完整且互斥地
  分配给这些 phase，cluster 权重校准为同一 ELF 内的动态指令份额。
- quick 与 full 都运行完整 composite ELF，不再分别运行子 kernel，也不在
  RTL 结果之后对多个代理结果加权。
- 当前 42 项已绑定自身 ref 画像；`638.imagick_s` 仍使用 train 临时画像，
  等精确 ref BBV/SimPoint/函数画像完成后重建并校准。

## 准确含义

这些程序是 SimPoint 指导的 SPEC-like RTL representative kernels，适合：

- 对同一 C910 RTL 的不同微结构版本做相对性能比较；
- 研究分支、前端、发射、依赖、执行流水线和存储层次瓶颈；
- 将程序动态特征与 RTL 细粒度性能计数器对应起来。

它们不是 SPEC 原始源码，不是真实 SPEC Linux checkpoint，不产生官方
SPEC CPU2017 分数。完成真实代表区间 checkpoint/restore、warmup、执行和
SimPoint 加权才属于 L3。

## 当前权威数据

| 内容 | 文件 |
|---|---|
| Rate benchmark 到 composite 映射 | `spec2017_kernel_map.json` |
| Speed benchmark 到 composite 映射 | `spec2017_speed_kernel_map.json` |
| cluster、函数热点与机制分组 | `spec_cluster_compositions.json` |
| 对应中文表格 | `SPEC_CLUSTER_COMPOSITIONS.md` |
| quick/full 指令数与工作集契约 | `spec_kernel_profiles.json` |
| 对应中文表格 | `SPEC_KERNEL_PROFILES.md` |

当前文件不作为最终完成证明。最终证明必须同时满足：

```text
strict SimPoint = 129/129
43 个 case 全部 ref-bound
quick features = 43/43
full features = 43/43
full PERF_DETAIL RTL TEST PASS = 43/43
SPEC2017_L2PLUS_FINAL_VALIDATION.md errors = 0
```
