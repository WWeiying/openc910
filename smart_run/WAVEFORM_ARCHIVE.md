# FSDB 波形归档

`smart_run/work/novas.fsdb`、`run.vcs.log` 和 `run_case.report` 是临时文件，
下一次仿真可以覆盖它们。波形归档功能把每个 case 的 FSDB 及配套文件复制到独立目录，
供 Verdi 和 `/home/wangwy/work_dir/C910_FSDB_signal_visualization.ipynb` 后续使用。

## run_bench.sh

`run_bench.sh` 默认使用 `ARCHIVE_FSDB=auto`：仿真生成 `novas.fsdb` 时自动归档；使用
无波形编译时只记录 `not-generated`，不增加 FSDB 空间。

运行前必须使用 `make compile DUMP=on` 编译带波形的模拟器；`run_bench.sh` 复用已有
`work/simv`，不会在运行阶段把无波形模拟器自动变成有波形模拟器。

```bash
cd smart_run

make compile DUMP=on PERF_DETAIL=on

# 有波形就归档，默认行为
BENCH_CASES=coremark ./run_bench.sh coremark_wave

# 明确要求每个 case 必须产生并归档 FSDB，否则报错
BENCH_CASES=coremark ./run_bench.sh --archive-fsdb coremark_wave

# 全量性能回归不保留波形
./run_bench.sh --no-archive-fsdb --baseline
```

每个 case 的目录结构为：

```text
results/<tag>_<git>_<state>/
└── waveforms/
    ├── coremark.status
    └── coremark/
        ├── novas.fsdb
        ├── run.vcs.log
        ├── run_case.report
        ├── coremark.elf
        ├── coremark.asm
        ├── symbols.args
        └── waveform.info
```

`run_bench.sh` 创建新的结果目录时拒绝覆盖同名目录；波形归档器同样拒绝覆盖已存在的
case 目录。使用 `--replace-results` 会按用户明确要求删除整个同名结果集，包括其中的
FSDB，因此不能用它保留旧实验。

## 单 case 波形

`coremark-wave` 默认归档：

```bash
make -C smart_run coremark-wave COREMARK_WAVE_ITERATIONS=1
```

输出位于：

```text
smart_run/results/waveform_runs/
└── coremark_iter-1_<git>_<state>__<run-id>/
```

普通 `simcase` 和 `runcase` 默认同样使用 `ARCHIVE_FSDB=auto`；若本次模拟器产生 FSDB，
就会自动归档：

```bash
make -C smart_run simcase CASE=bench_frontend \
  DUMP=on
```

需要把“未生成 FSDB”视为错误时使用 `ARCHIVE_FSDB=on`；明确不保留波形时使用
`ARCHIVE_FSDB=off`。传统 `make regress` 已显式关闭自动归档，防止整套旧回归意外保存
大量波形；需要全量逐 case 波形时应使用 `run_bench.sh` 并明确规划磁盘容量。

`<run-id>` 根据实际 FSDB 的路径、大小、纳秒时间和文件身份生成，不使用时间戳目录名。
归档先写入临时目录，全部复制成功后再原子重命名；目标目录已存在时直接失败，不会静默
覆盖旧波形。

在 FSDB Notebook 中只需把输入改为归档文件：

```python
FSDB_PATH = Path(
    "/home/wangwy/openproject/openc910/smart_run/results/"
    "waveform_runs/coremark_iter-1_<git>_<state>__<run-id>/novas.fsdb"
)
```

配套日志和报告与 FSDB 位于同一目录，Notebook 会自动识别；其导出 CSV 仍按实际 FSDB
身份存入 `work_dir/fsdb_tools/data/runs/<benchmark>__<run-id>/`，不同仿真不会互相覆盖。
