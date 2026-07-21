# SPEC CPU2017 SimPoint 与 RTL L2+ 状态

> 当前文件是最终发布前的过渡状态。完成全部严格门禁后，
> `generate_l2plus_overviews.py` 会从实际证据重新生成本文件，
> `finalize_l2plus.sh` 会将它与映射、契约和验收报告一起事务化发布。

## 当前结论

最近一次严格核查为 **128/129**。Rate 的 test/train/ref 为 69/69；
Speed 的 test/train 为 40/40，Speed ref 为 19/20。唯一缺项是
`638.imagick_s/ref` 的精确全程序 BBV、SimPoint 和函数画像。

该数字是进度快照，不是静态完成证明。实时权威检查命令为：

```bash
./spec_flow/check_l2plus_status.sh
```

## 分级状态

| 层级 | 定义 | 当前状态 |
|---|---|---|
| L1 | SPEC 全程序经 QEMU 收集 100M 指令区间 BBV，生成 SimPoint、weights、函数画像和严格 manifest | 128/129 |
| L2+ | 每个 benchmark 一个 2–3 phase composite ELF，以自身 ref cluster 权重校准动态指令份额；同一 full ELF 做程序特征和 RTL 仿真 | 638 ref 重建及最终干净证据待完成 |
| L3 | 恢复真实 SPEC Linux 进程 checkpoint，warmup 后执行代表区间并按 SimPoint 权重汇总 | 不在当前目标内，尚未完成 |

## L2+ 最终流水线

```text
129/129 严格 SimPoint
  -> 生成 43 项 ref cluster 机制分组
  -> 校准 43 个 quick/full composite ELF
  -> 干净提交生成 quick 程序特征 43/43
  -> 同一提交生成 full 程序特征和 PERF_DETAIL RTL 结果 43/43
  -> 校验 ELF、退休指令、详细指标、工具归档和 Git provenance
  -> 事务化发布映射、契约、RTL 汇总及最终验收文档
```

完成状态只由以下两个结果共同证明：

```text
SPEC2017_L2PLUS_STATUS.md: strict 129/129
SPEC2017_L2PLUS_FINAL_VALIDATION.md: errors=0
```
