# SPEC2017 Representative Kernel Mapping

> **当前 v5 口径（覆盖本文后续历史记录）**：43 个 SPEC Rate/Speed benchmark
> 各自运行一个独立 composite bare-metal ELF，RTL 仿真和程序动态特征都只统计
> 这个完整 ELF，Rate/Speed 不共享结果。3 个专用 composite 保持原实现；其余
> 40 个代理均包含 2 至 3 个机制 phase，并按各 benchmark 自身的 SimPoint
> function profile 完成语义分组和动态指令权重校准。`638.imagick_s` 暂用自身
> train profile，其余 39 个通用 composite 使用 ref profile。cluster 权重只
> 校准同一 ELF 内的动态指令份额，不再分别运行子 kernel 或在 RTL 结果之后加权。
> 机器可读分组证据见
> `spec_flow/spec_cluster_compositions.json`。本文后续关于旧 split-kernel 的
> 命令和结果仅用于历史追溯。

本文档专门记录从 SPEC2017 SimPoint 结果拆出来的 representative RTL kernels。目的不是记录官方 SPEC 分数，而是防止后续忘记：

```text
哪个 RTL kernel 对应哪个 SPEC benchmark / SimPoint cluster / 原始热点函数 / 权重 / 当前 RTL 表现。
```

当前口径：

```text
SPEC2017-guided representative kernel evaluation on C910 RTL
```

中文可写为：

```text
基于 SPEC2017 SimPoint 热点提取的代表性 kernel RTL 性能评估
```

注意：

```text
这些 kernel 不是 SPEC 原始源码；
不是官方 SPEC CPU2017 分数；
不是精确 SPEC Linux checkpoint restore；
它们是由真实 SPEC SimPoint/function profile 指导构造的 bare-metal RTL representative kernels。
```

## 1. 505.mcf_r test 原始 SimPoint 结果

来源目录：

```text
spec_runs/505.mcf_r_test_c910/
```

生成命令：

```bash
docker exec openc910-qemu bash -lc \
  'cd /work && ./spec_flow/run_bbv_simpoint.sh 505.mcf_r test 5 100000000'
```

基础配置：

| item | value |
|---|---|
| SPEC benchmark | `505.mcf_r` |
| input | `test` |
| compiler | Xuantie GCC Linux glibc |
| optimize | `-O2 -march=rv64imafdcxtheadc -mabi=lp64d -mtune=c910` |
| QEMU | `qemu-riscv64 -cpu c910 -L <sysroot>` |
| BBV type | `qemu_tb_instruction_weighted` |
| interval | `100000000` guest instructions |
| BBV intervals | `231` |
| mapped blocks | `3475` |
| selected K | `4` |
| compare | pass |

原始 SimPoint clusters：

| cluster | representative interval | raw weight | approximate instruction range | top original SPEC functions |
|---:|---:|---:|---|---|
| 0 | 17 | `0.787879` | 1.7B - 1.8B | `spec_qsort 38.0145%`, `cost_compare 33.9896%`, `primal_bea_mpp 27.2789%` |
| 1 | 115 | `0.0606061` | 11.5B - 11.6B | `arc_compare 52.2209%`, `spec_qsort 47.7791%` |
| 2 | 207 | `0.0779221` | 20.7B - 20.8B | `price_out_impl 99.5170%` |
| 3 | 106 | `0.0735931` | 10.6B - 10.7B | `price_out_impl 70.9032%`, `primal_bea_mpp 20.7634%` |

权重说明：

```text
raw weight sum = 1.0000003
轻微超过 1 是 SimPoint 输出小数截断/四舍五入导致。
后续加权时可直接使用 raw weight；需要严格归一化时除以 1.0000003。
```

## 2. 拆分后的 representative kernels

### 2.1 总映射表

| SPEC benchmark | cluster group | group raw weight | representative RTL kernel | kernel path | 代表的原始热点 |
|---|---|---:|---|---|---|
| `505.mcf_r/605.mcf_s test+train` | function-mix sort group | `0.65` | `spec_mcf_sort_kernel` | `smart_run/tests/cases/spec_mcf_sort_kernel/` | `spec_qsort`, `cost_compare`, `arc_compare` |
| `505.mcf_r/605.mcf_s test+train` | function-mix price/primal group | `0.35` | `spec_mcf_kernel` | `smart_run/tests/cases/spec_mcf_kernel/` | `price_out_impl`, `primal_bea_mpp`, `replace_weaker_arc` |

为什么这样拆：

```text
早期口径按 cluster 编号粗分为 0.848/0.152，但 train 结果显示主 cluster 内部也混有 `primal_bea_mpp`。
当前冻结口径改为按函数占比粗分：sort/compare 约 0.65，price/primal/replace 约 0.35。
```

因此最终展示时可以给一个：

```text
505.mcf_r-like weighted RTL prototype
```

但内部仍保留两个 kernel 的独立 RTL 结果，方便定位瓶颈。

### 2.2 spec_mcf_sort_kernel

对应原始 SPEC 信息：

| item | value |
|---|---|
| SPEC benchmark | `505.mcf_r test` |
| represented clusters | function-mix sort group |
| raw weight | `0.65` |
| original functions | `spec_qsort`, `cost_compare`, `arc_compare`, partial `primal_bea_mpp` |
| dominant original cluster | cluster 0 / interval 17 / weight `0.787879` |

RTL kernel 信息：

| item | value |
|---|---|
| kernel name | `spec_mcf_sort_kernel` |
| path | `smart_run/tests/cases/spec_mcf_sort_kernel/` |
| source file | `smart_run/tests/cases/spec_mcf_sort_kernel/main.c` |
| result dir | `smart_run/results/spec_mcf_sort_kernel_default/` |
| default config | `SPEC_MCF_SORT_ITEMS=96`, `SPEC_MCF_SORT_PASSES=1` |

模拟行为：

```text
basket/item array 初始化；
pointer-rich comparator；
abs_cost / red_cost / sequence / node mark 多级比较；
quicksort-like partition；
频繁条件分支、交换、load/store、指针字段访问。
```

当前 RTL smoke 结果：

| metric | value |
|---|---:|
| Kernel cycles | `16232` |
| Kernel retired inst | `12324` |
| Kernel CPI | `1.317` |
| Kernel IPC | `0.759` |
| LDST | `103.94%` |
| Cond Branch | `17.88%` |
| Cond Branch Misp | `34.44%` |
| Frontend Stall | `22.47%` |
| Backend Stall | `49.70%` |
| L1D Load Miss | `0.02%` |
| L1D Store Miss | `0.10%` |
| VCS CPU Time | `48.010s` |

主要限制：

```text
还没有完整覆盖 cluster 0 中的 primal_bea_mpp 27.2789%；
数据规模偏小，cache/TLB/BTB 压力还不够接近真实 SPEC；
它是 sort/compare representative，不是 SPEC qsort 源码拷贝。
```

### 2.3 spec_mcf_kernel

对应原始 SPEC 信息：

| item | value |
|---|---|
| SPEC benchmark | `505.mcf_r test` |
| represented clusters | function-mix price/primal group |
| raw weight | `0.35` |
| original functions | `price_out_impl`, `primal_bea_mpp`, refresh/flow helper functions |
| dominant original clusters | cluster 2 / interval 207, cluster 3 / interval 106 |

RTL kernel 信息：

| item | value |
|---|---|
| kernel name | `spec_mcf_kernel` |
| path | `smart_run/tests/cases/spec_mcf_kernel/` |
| source file | `smart_run/tests/cases/spec_mcf_kernel/main.c` |
| default config | `SPEC_MCF_NODES=32`, `SPEC_MCF_ARCS=96`, `SPEC_MCF_BASKET=8`, `SPEC_MCF_PASSES=1` |

模拟行为：

```text
node array；
arc array；
arc->tail / arc->head 指针访问；
red_cost = cost - tail->potential + head->potential；
dual infeasible branch filter；
basket_insert；
potential update。
```

当前 RTL smoke 结果：

| metric | value |
|---|---:|
| Kernel cycles | `4366` |
| Kernel retired inst | `2673` |
| Kernel CPI | `1.633` |
| Kernel IPC | `0.612` |
| LDST | `93.94%` |
| Cond Branch | `25.93%` |
| Cond Branch Misp | `32.47%` |
| Frontend Stall | `21.35%` |
| Backend Stall | `48.14%` |

主要限制：

```text
它更接近 price_out/primal arc scan；
不能代表 cluster 0/1 的 qsort/cost_compare 行为；
规模仍是 smoke 级别。
```

## 3. 单个 mcf-like 总结果如何合成

SimPoint 标准思路是：

```text
多个代表点分别 detailed simulation；
每个代表点有一个 weight；
最终 benchmark 结果按 weight 加权。
```

当前两个 representative kernels 的粗略分组：

| representative kernel | cluster group | raw weight | Kernel CPI | Kernel IPC |
|---|---|---:|---:|---:|
| `spec_mcf_sort_kernel` | sort/compare function mix | `0.65` | `1.317` | `0.759` |
| `spec_mcf_kernel` | price/primal/replace function mix | `0.35` | `1.565` | `0.639` |

粗略加权：

```text
weighted CPI ~= 0.65 * 1.317 + 0.35 * 1.565
             ~= 1.404

weighted IPC ~= 1 / weighted CPI
             ~= 0.712
```

推荐对外展示名：

```text
505.mcf_r-like weighted RTL prototype
```

不要写成：

```text
505.mcf_r official SPEC score
SPEC CPU2017 reportable result
exact SimPoint checkpoint RTL result
```

## 4. 后续最容易忘的点

| question | answer |
|---|---|
| 为什么不是一个 kernel？ | 因为 `505.mcf_r test` 的 SimPoint 显示至少有 sort/compare 和 price/primal 两类主要 phase。 |
| 为什么最终又能给一个 mcf-like 结果？ | SimPoint 本来就是多个代表点按权重加权，最终得到一个 benchmark-level estimate。 |

## 5. 批量扩展后的 SPEC-like kernels

本节记录 2026-07-03 至 2026-07-04 批量完成并继续增强的另外四个
representative kernels。它们和 `spec_mcf_*` 一样，都不是 SPEC 源码拷贝，
而是依据真实 SPEC2017 SimPoint/function profile 写出的 bare-metal 行为模型。

2026-07-04 的增强目标是把 kernel 从“能跑的热点外形”推进到“更接近真实热点机制”：

```text
557.xz_r:        match finder + probability/range update + checksum/mix
525.x264_r:      SAD/SATD + motion candidate search + subpel refine + CABAC-like context update
531.deepsjeng_r: bitboard attack + move ordering + qsearch + history + TT
541.leela_r:     playout selection + pattern + liberty/capture-like update + UCT child scan
```

来源汇总：

```text
spec_runs/representative_batch_test_summary.md
```

生成口径：

```text
input=test
SimPoint maxK=5
BBV interval=100000000 guest instructions
compiler=-O2 -march=rv64imafdcxtheadc -mabi=lp64d -mtune=c910 -fcommon
```

### 5.1 SPEC2017 intrate/fprate representative 覆盖总表

当前 `smart_run` 已经把 SPEC2017 rate 套件的 benchmark 名义覆盖补齐。这里的
“覆盖”指可在 C910 RTL bare-metal 环境运行的 representative kernel 覆盖，不是
SPEC 官方源码运行，也不是 SPEC SimPoint checkpoint 恢复。

| 套件 | SPEC benchmark | representative RTL kernel | 默认规模宏 | representative 规模宏 | 覆盖机制 | profile 状态 |
|---|---|---|---|---|---|---|
| intrate | `500.perlbench_r` | `spec_perlbench_regex_kernel` | `ITEMS=64`, `ITERS=1`, `STATES=8`, `DEPTH=3` | `ITEMS=256`, `ITERS=4`, `STATES=16`, `DEPTH=6` | parser/regex/hash/interpreter 分支 | 机制补齐，待真实 SimPoint 校准 |
| intrate | `502.gcc_r` | `spec_gcc_compile_kernel` | `ITEMS=64`, `ITERS=1`, `WIDTH=8`, `DEPTH=4` | `ITEMS=192`, `ITERS=4`, `WIDTH=16`, `DEPTH=8` | IR 图遍历、dataflow、bitset、分支 | 机制补齐，待真实 SimPoint 校准 |
| intrate | `505.mcf_r` | `spec_mcf_sort_kernel` + `spec_mcf_kernel` | `ITEMS=96/PASSES=1`; `NODES=32/ARCS=96/BASKET=8/PASSES=1` | `ITEMS=256/PASSES=3`; `NODES=96/ARCS=384/BASKET=16/PASSES=3` | sort/compare、arc scan、price/primal | 已有 `505.mcf_r test` SimPoint/function profile |
| intrate | `520.omnetpp_r` | `spec_omnetpp_event_kernel` | `EVENTS=64`, `ITERS=1`, `WIDTH=6`, `DEPTH=3` | `EVENTS=192`, `ITERS=4`, `WIDTH=12`, `DEPTH=5` | priority queue、event dispatch、pointer-like indexing | 机制补齐，待真实 SimPoint 校准 |
| intrate | `523.xalancbmk_r` | `spec_xalancbmk_xml_kernel` | `NODES=64`, `ITERS=1`, `ROOTS=6`, `DEPTH=4` | `NODES=256`, `ITERS=4`, `ROOTS=16`, `DEPTH=8` | XML/DOM traversal、string hash、attribute lookup | 机制补齐，待真实 SimPoint 校准 |
| intrate | `525.x264_r` | `spec_x264_pixel_kernel` | `WIDTH=24`, `HEIGHT=24`, `BLOCKS=1`, `PASSES=1`, `CANDIDATES=1` | `WIDTH=48`, `HEIGHT=40`, `BLOCKS=48`, `PASSES=2`, `CANDIDATES=8` | SAD/SATD、motion search、pixel reference load | 已有 `525.x264_r test` SimPoint/function profile |
| intrate | `531.deepsjeng_r` | `spec_deepsjeng_search_kernel` | `POSITIONS=1`, `DEPTH=1`, `MOVES=8`, `QMOVES=0` | `POSITIONS=4`, `DEPTH=2`, `MOVES=16`, `QMOVES=8` | alpha-beta/qsearch、bitboard、TT、move ordering | 已有 `531.deepsjeng_r test` SimPoint/function profile |
| intrate | `541.leela_r` | `spec_leela_playout_kernel` | `BOARD=13`, `PLAYOUTS=2`, `MOVES=12`, `CHILDREN=16` | `BOARD=13`, `PLAYOUTS=8`, `MOVES=32`, `CHILDREN=64` | Go playout、pattern lookup、UCT selection | 已有 `541.leela_r test` SimPoint/function profile |
| intrate | `548.exchange2_r` | `spec_exchange2_search_kernel` | `POSITIONS=1`, `DEPTH=2`, `MOVES=6`, `TABLE=64` | `POSITIONS=4`, `DEPTH=4`, `MOVES=14`, `TABLE=256` | branch-heavy recursive search / solver shape | 已有 `548.exchange2_r test` SimPoint/function profile，映射仍偏粗 |
| intrate | `557.xz_r` | `spec_xz_lzma_kernel` | `BYTES=512`, `DICT=1024`, `PASSES=1`, `PROBES=12`, `RANGE_STEPS=4` | `BYTES=2048`, `DICT=4096`, `PASSES=2`, `PROBES=32`, `RANGE_STEPS=8` | LZMA match finder、probability/range-like update | 已有 `557.xz_r test` SimPoint/function profile |
| fprate | `503.bwaves_r` | `spec_bwaves_stencil_kernel` | `CELLS=64`, `STEPS=1`, `RADIUS=3`, `DEPTH=2` | `CELLS=384`, `STEPS=6`, `RADIUS=8`, `DEPTH=4` | wave/stencil FP update | 机制补齐，待真实 SimPoint 校准 |
| fprate | `507.cactuBSSN_r` | `spec_cactubssn_stencil_kernel` | `N=6`, `STEPS=1`, `TENSORS=3` | `N=12`, `STEPS=3`, `TENSORS=6` | tensor stencil、regular FP load/compute/store | 已有 `507.cactuBSSN_r test` SimPoint/function profile |
| fprate | `508.namd_r` | `spec_namd_pair_kernel` | `ATOMS=64`, `STEPS=1`, `NEIGHBORS=6`, `DEPTH=2` | `ATOMS=192`, `STEPS=4`, `NEIGHBORS=16`, `DEPTH=4` | molecular dynamics pair force | 机制补齐，待真实 SimPoint 校准 |
| fprate | `510.parest_r` | `spec_parest_sparse_kernel` | `N=48`, `NNZ_PER_ROW=5`, `ITERS=3` | `N=128`, `NNZ_PER_ROW=7`, `ITERS=5` | sparse matrix/vector、indirect load、iterative solver | 已有 `510.parest_r test` SimPoint/function profile |
| fprate | `511.povray_r` | `spec_povray_ray_kernel` | `RAYS=32`, `OBJECTS=8`, `BOUNCES=1` | `RAYS=192`, `OBJECTS=32`, `BOUNCES=3` | ray/object intersection、geometry FP branches | 已有 `511.povray_r test` SimPoint/function profile |
| fprate | `519.lbm_r` | `spec_lbm_stream_kernel` | `CELLS=24`, `STEPS=1`, `Q=19` | `CELLS=384`, `STEPS=4`, `Q=19` | LBM stream/collide、regular memory bandwidth | 已有 `519.lbm_r test` SimPoint/function profile，但 test 输入初始化占比偏高 |
| fprate | `521.wrf_r` | `spec_wrf_stencil_kernel` | `CELLS=64`, `STEPS=1`, `RADIUS=3`, `DEPTH=2` | `CELLS=384`, `STEPS=6`, `RADIUS=8`, `DEPTH=4` | weather stencil / finite-difference update | 机制补齐，待真实 SimPoint 校准 |
| fprate | `526.blender_r` | `spec_blender_render_kernel` | `RAYS=64`, `PASSES=1`, `OBJECTS=6`, `DEPTH=2` | `RAYS=192`, `PASSES=4`, `OBJECTS=16`, `DEPTH=4` | render/ray-like FP object interaction | 机制补齐，待真实 SimPoint 校准 |
| fprate | `527.cam4_r` | `spec_cam4_climate_kernel` | `LEVELS=64`, `STEPS=1`, `COLUMNS=6`, `DEPTH=2` | `LEVELS=256`, `STEPS=4`, `COLUMNS=16`, `DEPTH=4` | climate column physics、vertical recurrence | 机制补齐，待真实 SimPoint 校准 |
| fprate | `538.imagick_r` | `spec_imagick_filter_kernel` | `PIXELS=64`, `PASSES=1`, `RADIUS=3`, `DEPTH=2` | `PIXELS=256`, `PASSES=4`, `RADIUS=8`, `DEPTH=4` | image convolution/color transform/conditional pipeline | 机制补齐，待真实 SimPoint 校准 |
| fprate | `544.nab_r` | `spec_nab_md_kernel` | `ATOMS=64`, `STEPS=1`, `NEIGHBORS=6`, `DEPTH=2` | `ATOMS=192`, `STEPS=4`, `NEIGHBORS=16`, `DEPTH=4` | molecular mechanics pair-list FP update | 机制补齐，待真实 SimPoint 校准 |
| fprate | `549.fotonik3d_r` | `spec_fotonik3d_stencil_kernel` | `CELLS=64`, `STEPS=1`, `RADIUS=3`, `DEPTH=2` | `CELLS=384`, `STEPS=6`, `RADIUS=8`, `DEPTH=4` | 3D FDTD/stencil FP update | 机制补齐，待真实 SimPoint 校准 |
| fprate | `554.roms_r` | `spec_roms_stencil_kernel` | `CELLS=64`, `STEPS=1`, `RADIUS=3`, `DEPTH=2` | `CELLS=384`, `STEPS=6`, `RADIUS=8`, `DEPTH=4` | ocean-model stencil / FP recurrence | 机制补齐，待真实 SimPoint 校准 |

配置说明：

```text
default smoke 配置目标是可在 RTL 中快速跑完并验证接入。
representative 配置目标是更接近真实 SPEC 热点机制，RTL 全量运行时间会明显更长。
已有 SimPoint/function profile 的 case 可以做较强 SPEC-guided 分析。
机制补齐 case 先用于补完整 suite 压力源，下一步应跑 QEMU BBV + SimPoint 后再校准。
```

### 5.2 对应 SimPoint 权重和热点

| SPEC benchmark | selected clusters | representative intervals / weights | global top functions |
|---|---:|---|---|
| `557.xz_r test` | `4` | `243:0.1275510`, `175:0.7066330`, `68:0.0765306`, `133:0.0892857` | `lzma_lzma_optimum_normal 20.4940%`, `sha_compress 14.6621%`, `lzma_lzma_encode 12.8794%`, `lzma_decode 12.4434%` |
| `525.x264_r test` | `5` | `1195:0.0653636`, `45:0.0334174`, `2176:0.0248003`, `3431:0.4567040`, `799:0.4197140` | `x264_pixel_satd_8x4 16.3459%`, `get_ref 15.8116%`, `x264_pixel_sad_x4_16x16 11.6059%`, `x264_pixel_sad_16x16 7.3742%` |
| `531.deepsjeng_r test` | `5` | `152:0.4015350`, `344:0.3529410`, `44:0.2378520`, `1:0.0051151`, `2:0.0025575` | `feval 14.4298%`, `qsearch 9.1634%`, `FindFirstRemove 7.8981%`, `search.part.0 7.2957%` |
| `541.leela_r test` | `5` | `50:0.0458333`, `237:0.2416670`, `8:0.0041667`, `79:0.6750000`, `4:0.0333333` | `play_random_move 11.4653%`, `get_pattern_fast_augment 9.8774%`, `self_atari 9.8604%`, `update_board_fast 8.3020%` |

### 5.3 RTL smoke 结果

结果目录：

```text
smart_run/results/spec_xz_lzma_kernel_default/
smart_run/results/spec_x264_pixel_kernel_default/
smart_run/results/spec_deepsjeng_search_kernel_default/
smart_run/results/spec_leela_playout_kernel_default/
```

| kernel | status | Kernel cycles | Kernel retired inst | Kernel CPI | Kernel IPC | Cond branch misp | Frontend stall | Backend stall | VCS CPU time |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|
| `spec_xz_lzma_kernel` | pass | `40082` | `68831` | `0.582` | `1.717` | `14.24%` | `10.90%` | `25.03%` | `138.790s` |
| `spec_x264_pixel_kernel` | pass | `10945` | `19397` | `0.564` | `1.772` | `11.18%` | `25.78%` | `31.94%` | `49.890s` |
| `spec_deepsjeng_search_kernel` | pass | `24365` | `22555` | `1.080` | `0.926` | `23.58%` | `15.47%` | `36.13%` | `103.180s` |
| `spec_leela_playout_kernel` | pass | `17925` | `19183` | `0.934` | `1.070` | `11.86%` | `21.62%` | `44.27%` | `46.950s` |

这些 smoke 结果对应 5.1 表中的 default smoke config。和第一版相比，部分 case
的默认规模被有意压小，因为新增的真实机制会显著增加 RTL 墙上时间。需要研究真实性时应使用
representative 配置；需要快速验证接入时使用 default smoke 配置。

### 5.4 运行命令

快速 smoke：

```bash
make -C smart_run simcase CASE=spec_xz_lzma_kernel DUMP=off
make -C smart_run simcase CASE=spec_x264_pixel_kernel DUMP=off
make -C smart_run simcase CASE=spec_deepsjeng_search_kernel DUMP=off
make -C smart_run simcase CASE=spec_leela_playout_kernel DUMP=off
```

只编译不跑 RTL：

```bash
make -C smart_run buildcase CASE=spec_xz_lzma_kernel DUMP=off
make -C smart_run buildcase CASE=spec_x264_pixel_kernel DUMP=off
make -C smart_run buildcase CASE=spec_deepsjeng_search_kernel DUMP=off
make -C smart_run buildcase CASE=spec_leela_playout_kernel DUMP=off
```

更接近真实热点机制的 representative build：

```bash
make -C smart_run buildcase CASE=spec_mcf_kernel DUMP=off SPEC_MCF_REPRESENTATIVE=1
make -C smart_run buildcase CASE=spec_mcf_sort_kernel DUMP=off SPEC_MCF_SORT_REPRESENTATIVE=1
make -C smart_run buildcase CASE=spec_xz_lzma_kernel DUMP=off SPEC_XZ_REPRESENTATIVE=1
make -C smart_run buildcase CASE=spec_x264_pixel_kernel DUMP=off SPEC_X264_REPRESENTATIVE=1
make -C smart_run buildcase CASE=spec_deepsjeng_search_kernel DUMP=off SPEC_DEEPSJENG_REPRESENTATIVE=1
make -C smart_run buildcase CASE=spec_leela_playout_kernel DUMP=off SPEC_LEELA_REPRESENTATIVE=1
```

如果要在 RTL 中正式跑 representative 配置，把上面的 `buildcase` 换成 `simcase`。
这类运行建议单独保存 results 目录，并记录对应 git 号、编译选项和宏配置。

### 5.5 当前覆盖边界

| kernel | 已覆盖 | 仍未覆盖 |
|---|---|---|
| `spec_xz_lzma_kernel` | LZMA match finder、hash chain、literal/match probability update、range-like update、price update、SHA-like mix、byte transform/checksum | 完整 range coder、完整 LZMA state machine、SPEC 多输入文件切换、真实压缩文件 IO |
| `spec_x264_pixel_kernel` | SAD/SATD、reference load、multi-candidate motion search、subpel refine、interpolation-like average、4x4 transform/quant、CABAC-like context update | 完整 CABAC bitstream、完整 motion-estimation control、frame-level scheduling、真实视频帧输入 |
| `spec_deepsjeng_search_kernel` | bitboard attack、first-bit move extraction、SEE-like scoring、move ordering、eval、qsearch、alpha-beta search、history update、TT probe/store | 大规模递归树、完整 chess legal move/state model、完整 opening/endgame/eval tables |
| `spec_leela_playout_kernel` | random playout、pattern lookup、self-atari/no-eye-fill、liberty update、capture-like removal、board update、UCT child selection | 完整 SGF/GTP、完整 MCTS tree expansion/backup、完整 Go group/liberty model、神经网络/策略网络路径 |

结论：

```text
到这里，SPEC2017 test 输入上的 mcf/xz/x264/deepsjeng/leela 五类 representative
kernel 都已经有 smart_run bare-metal 移植版本，并且新增四个 kernel 已通过增强后 RTL smoke。
representative 配置也已完成 build 验证。
它们可以作为后续研究 C910 乱序/前端/分支/访存/执行资源瓶颈的第一批 SPEC-like RTL workloads。
```

### 5.6 当前可用性判断

| question | answer |
|---|---|
| 当前最重要的权重是多少？ | 对 `505.mcf_r/605.mcf_s`，当前冻结口径是 sort/compare group `0.65`，price/primal/replace group `0.35`；该口径由 test 与 `605.mcf_s train` 函数占比共同校准。 |
| 当前最该优化/完善哪个 kernel？ | `spec_mcf_sort_kernel` 和 `spec_deepsjeng_search_kernel`。前者 mcf 权重大，后者分支错预测和低 IPC 更适合研究乱序/分支/前端交互。 |
| 当前结果能不能和商业宣传 SPEC 分数直接比？ | 不能。它是 SPEC-guided representative RTL kernel，不是官方 SPEC CPU2017 分数。 |
| 当前能不能用于处理器机制研究？ | 可以。它已经覆盖 branch、LSU、frontend/backend stall、指针访问、递归/搜索、像素密集循环和压缩概率更新等典型压力源。 |
| 当前是否接近真实 SPEC？ | 比第一版更接近真实热点机制，但仍是 L2 representative kernel，不是 L3 Linux checkpoint RTL restore。 |

## 6. 第二批扩展 SPEC-like kernels

本节记录 2026-07-04 新增并完成 sampled profile、权重校准和 RTL
representative-lite 运行的 5 个 SPEC-like kernels：

```text
548.exchange2_r -> spec_exchange2_search_kernel
507.cactuBSSN_r -> spec_cactubssn_stencil_kernel
519.lbm_r       -> spec_lbm_stream_kernel
510.parest_r    -> spec_parest_sparse_kernel
511.povray_r    -> spec_povray_ray_kernel
```

当前结论：

```text
已完成 smart_run bare-metal 移植；
已完成 SPEC 原程序 sampled-prefix BBV + SimPoint + function profile；
已完成 default smoke RTL；
已完成 representative-lite RTL，5/5 pass；
full representative 配置对 RTL 批量运行过重，暂不作为默认批量跑法。
```

### 6.1 Profile 口径

本轮 profile 使用 sampled-prefix，而不是完整 SPEC run：

| item | value |
|---|---|
| input | `test` |
| SimPoint maxK | `5` |
| BBV interval | `1000000` guest instructions |
| BBV max intervals | `50` |
| sampled instruction window | first `50M` guest instructions |
| compare | skipped, `SKIP_COMPARE=1` |
| profile type | `sampled-prefix` |
| compiler | `-O2 -march=rv64imafdcxtheadc -mabi=lp64d -mtune=c910 -fcommon` |
| extra for `510.parest_r` | `CXX_EXTRA_FLAGS="-std=gnu++03 -fpermissive"` |

生成命令：

```bash
docker exec openc910-qemu bash -lc \
  'cd /work && FORCE_BBV=1 FORCE_PROFILE=1 BBV_MAX_INTERVALS=50 SKIP_COMPARE=1 \
   ./spec_flow/run_representative_batch.sh test 5 1000000 \
   548.exchange2_r 507.cactuBSSN_r 519.lbm_r 511.povray_r'

docker exec openc910-qemu bash -lc \
  'cd /work && FORCE_BBV=1 FORCE_PROFILE=1 BBV_MAX_INTERVALS=50 SKIP_COMPARE=1 \
   CXX_EXTRA_FLAGS="-std=gnu++03 -fpermissive" \
   ./spec_flow/run_representative_batch.sh test 5 1000000 510.parest_r'
```

重要限制：

```text
这些权重是前 50 个 1M interval 的 sampled-prefix 权重；
它们不能等同于完整 SPEC CPU2017 run 的 SimPoint 权重；
对初始化很重的 benchmark，prefix profile 会偏向 init/parser/setup phase。
```

本轮为支持这种口径，`simple_bbv` 增加了 `max_intervals`，`run_bbv_simpoint.sh`
增加了 `BBV_MAX_INTERVALS` 和 `SKIP_COMPARE`，`write_config.sh` 增加了
`CXX_EXTRA_FLAGS`。

### 6.2 新增 kernel 总表

| SPEC benchmark | representative RTL kernel | kernel path | default smoke config | full representative config | representative-lite config used in RTL | 代表行为 |
|---|---|---|---|---|---|---|
| `548.exchange2_r` | `spec_exchange2_search_kernel` | `smart_run/tests/cases/spec_exchange2_search_kernel/` | `POSITIONS=1`, `DEPTH=2`, `MOVES=6`, `TABLE=64` | `POSITIONS=4`, `DEPTH=4`, `MOVES=14`, `TABLE=256` | `POSITIONS=1`, `DEPTH=2`, `MOVES=8`, `TABLE=128` | recursive search, move ordering, alpha-beta pruning, history, TT |
| `507.cactuBSSN_r` | `spec_cactubssn_stencil_kernel` | `smart_run/tests/cases/spec_cactubssn_stencil_kernel/` | `N=6`, `STEPS=1`, `TENSORS=3` | `N=12`, `STEPS=3`, `TENSORS=6` | `N=7`, `STEPS=1`, `TENSORS=4` | 3D stencil, tensor coupling, FP update, structured memory |
| `519.lbm_r` | `spec_lbm_stream_kernel` | `smart_run/tests/cases/spec_lbm_stream_kernel/` | `CELLS=24`, `STEPS=1`, `Q=19` | `CELLS=384`, `STEPS=4`, `Q=19` | `CELLS=48`, `STEPS=1`, `Q=19` | D3Q19-like collide/stream, regular loads/stores, FP update |
| `510.parest_r` | `spec_parest_sparse_kernel` | `smart_run/tests/cases/spec_parest_sparse_kernel/` | `N=48`, `NNZ_PER_ROW=5`, `ITERS=3` | `N=128`, `NNZ_PER_ROW=7`, `ITERS=5` | `N=64`, `NNZ_PER_ROW=6`, `ITERS=4` | sparse SpMV, indirect loads, reductions, iterative solver |
| `511.povray_r` | `spec_povray_ray_kernel` | `smart_run/tests/cases/spec_povray_ray_kernel/` | `RAYS=32`, `OBJECTS=8`, `BOUNCES=1` | `RAYS=192`, `OBJECTS=32`, `BOUNCES=3` | `RAYS=48`, `OBJECTS=10`, `BOUNCES=2` | ray-object intersection, FP geometry, shading branch |

### 6.3 SimPoint 权重和热点

| SPEC benchmark | profile dir | intervals | mapped blocks | selected intervals / weights | global top functions |
|---|---|---:|---:|---|---|
| `548.exchange2_r test` | `spec_runs/548.exchange2_r_test_c910/` | `50` | `5236` | `39:0.26`, `6:0.42`, `8:0.32` | `data_start 37.3797%`, `digits_2 23.7034%`, `specific.4 16.9654%`, `new_solver 11.6289%` |
| `507.cactuBSSN_r test` | `spec_runs/507.cactuBSSN_r_test_c910/` | `50` | `8028` | `12:0.26`, `1:0.04`, `42:0.70` | `data_start 56.6563%`, `piraha::Bracket::addRange 7.5659%`, `piraha::Lookup::match 6.7245%`, `Util_StrCmpi 5.0138%` |
| `519.lbm_r test` | `spec_runs/519.lbm_r_test_c910/` | `50` | `2023` | `1:0.98`, `0:0.02` | `LBM_initializeGrid 99.7771%`, `data_start 0.2222%` |
| `510.parest_r test` | `spec_runs/510.parest_r_test_c910/` | `50` | `16360` | `46:0.10`, `39:0.10`, `36:0.04`, `32:0.28`, `11:0.48` | `data_start 15.6690%`, `DoFCellAccessor::update_cell_dof_indices_cache 9.4094%`, `__introsort_loop 6.8961%`, `execute_refinement 5.8896%` |
| `511.povray_r test` | `spec_runs/511.povray_r_test_c910/` | `50` | `12399` | `29:0.48`, `10:0.24`, `38:0.20`, `3:0.04`, `1:0.04` | `data_start 36.4649%`, `pov::Get_Token.part 21.5912%`, `ITextStream::getchar 14.4431%`, `All_Plane_Intersections 1.2881%` |

校准判断：

| kernel | sampled profile 与当前 kernel 的匹配度 | 说明 |
|---|---|---|
| `spec_exchange2_search_kernel` | 高 | prefix 已进入 sudoku/search/solver 热点，当前 recursive search + pruning + table 行为可代表主要机制。 |
| `spec_cactubssn_stencil_kernel` | 中低 | prefix 主要是 Cactus/piraha 参数解析和 framework setup；当前 kernel 更像 steady-state stencil，不代表 prefix init/parser。 |
| `spec_lbm_stream_kernel` | 中低 | prefix 几乎全是 `LBM_initializeGrid`；当前 kernel 是 steady-state collide/stream，应在后续用 warmup-skip profile 重校准。 |
| `spec_parest_sparse_kernel` | 中 | prefix 进入 deal.II mesh/refinement/DoF setup，当前 sparse kernel 覆盖间接访存和迭代求解，但不覆盖 mesh/refinement 初始化。 |
| `spec_povray_ray_kernel` | 中 | prefix 以 scene parser/tokenizer 为主，已有少量 intersection；当前 ray kernel 覆盖 render/intersection，不覆盖 parser。 |

### 6.4 RTL 结果

default smoke 保存目录：

```text
smart_run/results/spec_extra5_default_4d3a75a53ea7_dirty/
```

representative-lite 保存目录：

```text
smart_run/results/spec_extra5_representative_lite_4d3a75a53ea7_dirty/
```

本轮也尝试过 full representative 批量运行：

```text
smart_run/results/spec_extra5_representative_unknown_clean/
```

但 `spec_exchange2_search_kernel` full 配置运行 12 分钟仍未结束，trace 已推进到约
32 万行，判断 full 配置不适合当前 RTL 批量回归，已停止该批处理；该目录不作为有效结果。

default smoke 结果：

| kernel | status | Kernel cycles | Kernel retired inst | Kernel CPI | Kernel IPC | FP inst | LDST | Cond branch misp | Frontend stall | Backend stall | VCS CPU time |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `spec_exchange2_search_kernel` | pass | `18727` | `30809` | `0.608` | `1.645` | `0.00%` | `23.62%` | `11.73%` | `22.01%` | `29.93%` | `98.330s` |
| `spec_cactubssn_stencil_kernel` | pass | `13925` | `20936` | `0.665` | `1.503` | `26.81%` | `25.99%` | `7.98%` | `53.36%` | `46.54%` | `52.810s` |
| `spec_lbm_stream_kernel` | pass | `17584` | `28474` | `0.618` | `1.619` | `29.99%` | `10.16%` | `6.94%` | `43.37%` | `42.91%` | `56.410s` |
| `spec_parest_sparse_kernel` | pass | `7776` | `12843` | `0.605` | `1.652` | `22.67%` | `32.95%` | `4.85%` | `30.13%` | `34.19%` | `37.800s` |
| `spec_povray_ray_kernel` | pass | `10314` | `7029` | `1.467` | `0.682` | `107.77%` | `36.83%` | `35.45%` | `32.36%` | `49.78%` | `28.420s` |

representative-lite 结果：

| kernel | status | Kernel cycles | Kernel retired inst | Kernel CPI | Kernel IPC | FP inst | LDST | Cond branch misp | Frontend stall | Backend stall | VCS CPU time |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `spec_exchange2_search_kernel` | pass | `22425` | `34639` | `0.647` | `1.545` | `0.00%` | `27.04%` | `14.08%` | `21.36%` | `30.28%` | `111.230s` |
| `spec_cactubssn_stencil_kernel` | pass | `27776` | `49677` | `0.559` | `1.788` | `26.21%` | `25.35%` | `2.71%` | `53.29%` | `39.39%` | `98.570s` |
| `spec_lbm_stream_kernel` | pass | `34034` | `57708` | `0.590` | `1.696` | `29.58%` | `10.03%` | `5.93%` | `43.37%` | `40.42%` | `109.690s` |
| `spec_parest_sparse_kernel` | pass | `13646` | `24577` | `0.555` | `1.801` | `21.38%` | `32.89%` | `2.20%` | `25.51%` | `29.28%` | `59.250s` |
| `spec_povray_ray_kernel` | pass | `33568` | `25573` | `1.313` | `0.762` | `102.00%` | `33.12%` | `28.91%` | `30.13%` | `47.86%` | `80.350s` |

说明：

```text
FP inst 和 LDST 百分比直接来自 RTL perf counter 输出。
部分 counter 以事件数/retired inst 为分母，FP inst 可超过 100%，不能简单理解为指令 mix 百分比。
```

### 6.5 运行命令

快速 smoke：

```bash
make -C smart_run simcase CASE=spec_exchange2_search_kernel DUMP=off
make -C smart_run simcase CASE=spec_cactubssn_stencil_kernel DUMP=off
make -C smart_run simcase CASE=spec_lbm_stream_kernel DUMP=off
make -C smart_run simcase CASE=spec_parest_sparse_kernel DUMP=off
make -C smart_run simcase CASE=spec_povray_ray_kernel DUMP=off
```

批量保存 representative-lite：

```bash
cd smart_run
BENCH_CASES='spec_exchange2_search_kernel spec_cactubssn_stencil_kernel spec_lbm_stream_kernel spec_parest_sparse_kernel spec_povray_ray_kernel' \
SPEC_EXCHANGE2_REPRESENTATIVE=1 SPEC_EXCHANGE2_POSITIONS=1 SPEC_EXCHANGE2_DEPTH=2 SPEC_EXCHANGE2_MOVES=8 SPEC_EXCHANGE2_TABLE=128 \
SPEC_CACTU_REPRESENTATIVE=1 SPEC_CACTU_N=7 SPEC_CACTU_STEPS=1 SPEC_CACTU_TENSORS=4 \
SPEC_LBM_REPRESENTATIVE=1 SPEC_LBM_CELLS=48 SPEC_LBM_STEPS=1 SPEC_LBM_Q=19 \
SPEC_PAREST_REPRESENTATIVE=1 SPEC_PAREST_N=64 SPEC_PAREST_NNZ_PER_ROW=6 SPEC_PAREST_ITERS=4 \
SPEC_POVRAY_REPRESENTATIVE=1 SPEC_POVRAY_RAYS=48 SPEC_POVRAY_OBJECTS=10 SPEC_POVRAY_BOUNCES=2 \
DUMP=off ./run_bench.sh spec_extra5_representative_lite
```

full representative 只建议单独逐个跑：

```bash
make -C smart_run simcase CASE=spec_exchange2_search_kernel DUMP=off SPEC_EXCHANGE2_REPRESENTATIVE=1
make -C smart_run simcase CASE=spec_cactubssn_stencil_kernel DUMP=off SPEC_CACTU_REPRESENTATIVE=1
make -C smart_run simcase CASE=spec_lbm_stream_kernel DUMP=off SPEC_LBM_REPRESENTATIVE=1
make -C smart_run simcase CASE=spec_parest_sparse_kernel DUMP=off SPEC_PAREST_REPRESENTATIVE=1
make -C smart_run simcase CASE=spec_povray_ray_kernel DUMP=off SPEC_POVRAY_REPRESENTATIVE=1
```

### 6.6 当前覆盖边界

| kernel | 已覆盖 | 仍未覆盖 |
|---|---|---|
| `spec_exchange2_search_kernel` | recursive search、move ordering、alpha-beta pruning、history update、TT probe/store | 真实 Fortran 程序控制结构、完整输入、full-run SimPoint 权重 |
| `spec_cactubssn_stencil_kernel` | 3D grid、tensor coupling、laplacian/gradient-like FP update、structured memory traversal | Cactus/piraha parser/setup、完整 BSSN 方程组、大规模边界/ghost zone |
| `spec_lbm_stream_kernel` | D3Q19-like collide/stream、obstacle branch、regular streaming store、FP update | `LBM_initializeGrid` init phase、真实 SPEC lbm 数据布局、长时间 streaming memory 压力 |
| `spec_parest_sparse_kernel` | CSR-like SpMV、indirect load、dot-product reduction、CG-like update branch | deal.II mesh/refinement/DoF setup、多层 FEM solver/preconditioner |
| `spec_povray_ray_kernel` | ray/sphere intersection、object scan、hit/miss branch、FP shading/bounce | scene parser/tokenizer、BVH/object hierarchy、texture/material system |

### 6.7 已完成的 L3 profile 增强

本轮已经把 BBV 采样从 sampled-prefix 扩展为可跳过 warmup 的 sampled-window：

| file | change |
|---|---|
| `tools/qemu-plugins/simple_bbv.c` | 增加 `skip_intervals`，可先执行若干 BBV interval 但不输出，再输出后续 representative window；`max_intervals` 仍按输出 interval 计数。 |
| `spec_flow/run_bbv_simpoint.sh` | 增加 `BBV_SKIP_INTERVALS`、`BBV_MAX_INTERVALS`、`SPEC_RUN_SUFFIX`，支持把不同 profile window 保存到不同目录。 |
| `spec_flow/run_representative_batch.sh` | 增加 `SPEC_RUN_SUFFIX`，batch summary 和每个 benchmark 输出目录保持同一后缀。 |
| `spec_flow/write_config.sh` | 增加 `CXX_EXTRA_FLAGS`，用于 `510.parest_r` 在当前 GCC 14 工具链下追加 `-std=gnu++03 -fpermissive`。 |

验证命令：

```bash
bash -n spec_flow/run_bbv_simpoint.sh spec_flow/run_representative_batch.sh spec_flow/write_config.sh
docker exec openc910-qemu bash -lc 'cd /work && source spec_flow/env.sh && make -C tools/qemu-plugins QEMU_ROOT=$QEMU_ROOT'
```

实际 L3 sampled-window profile 命令：

```bash
docker exec openc910-qemu bash -lc \
  'cd /work && FORCE_BBV=1 FORCE_PROFILE=1 BBV_SKIP_INTERVALS=50 BBV_MAX_INTERVALS=50 \
   SKIP_COMPARE=1 SPEC_RUN_SUFFIX=_skip50_n50 \
   ./spec_flow/run_representative_batch.sh test 5 1000000 \
   507.cactuBSSN_r 519.lbm_r 511.povray_r'

docker exec openc910-qemu bash -lc \
  'cd /work && FORCE_BBV=1 FORCE_PROFILE=1 BBV_SKIP_INTERVALS=50 BBV_MAX_INTERVALS=50 \
   SKIP_COMPARE=1 SPEC_RUN_SUFFIX=_skip50_n50 \
   CXX_EXTRA_FLAGS="-std=gnu++03 -fpermissive" \
   ./spec_flow/run_representative_batch.sh test 5 1000000 510.parest_r'
```

### 6.8 L3 sampled-window profile 结果

采样口径：

| item | value |
|---|---|
| input | `test` |
| interval | `1000000` guest instructions |
| skipped interval | `50` |
| profiled interval | `50` |
| effective sampled window | guest instruction `[50M, 100M)` |
| SimPoint maxK | `5` |
| compare | skipped, because QEMU exits early after sampled window |

| SPEC benchmark | profile dir | BBV intervals | mapped blocks | selected intervals / weights | global top functions |
|---|---|---:|---:|---|---|
| `507.cactuBSSN_r` | `spec_runs/507.cactuBSSN_r_test_c910_skip50_n50/` | `50` | `19651` | `15:0.06`, `18:0.66`, `10:0.18`, `3:0.10` | `GaugeWave_initial_Body 62.2%`, `data_start 16.8%`, `CartGrid3D_SetCoordinates 5.2%`, `Util_StrCmpi 4.7%` |
| `519.lbm_r` | `spec_runs/519.lbm_r_test_c910_skip50_n50/` | `50` | `2262` | `42:0.28`, `0:0.18`, `32:0.54` | `data_start 56.5%`, `LBM_initializeGrid 18.1%`, `LBM_loadObstacleFile 16.8%` |
| `510.parest_r` | `spec_runs/510.parest_r_test_c910_skip50_n50/` | `50` | `17346` | `32:0.46`, `2:0.10`, `22:0.02`, `8:0.36`, `25:0.06` | `data_start 29.9%`, `DoFTools::extract_dofs 22.9%`, `ConstraintMatrix::add_entries_local_to_global 13.3%`, `DoFCellAccessor::update_cell_dof_indices_cache 9.4%` |
| `511.povray_r` | `spec_runs/511.povray_r_test_c910_skip50_n50/` | `50` | `12507` | `29:0.26`, `14:0.18`, `36:0.50`, `42:0.06` | `All_Plane_Intersections 17.2%`, `All_CSG_Intersect_Intersections 15.7%`, `All_Sphere_Intersections 14.8%`, `Inside_Object 7.4%` |

校准判断：

| SPEC benchmark | 当前 profile 质量 | 对应 RTL kernel 的真实性判断 | 后续动作 |
|---|---|---|---|
| `548.exchange2_r` | 高，prefix 已进入 sudoku solver/search | `spec_exchange2_search_kernel` 可以作为当前有效 representative kernel | 保持当前 kernel，后续只需增大规模做敏感性分析。 |
| `507.cactuBSSN_r` | 中，skip 后从 parser 进入 grid/initial-data，但还不是长时间 BSSN evolution | `spec_cactubssn_stencil_kernel` 代表 steady-state stencil 机制，但不是这次 test window 的精确函数替身 | 若要更真实，需要更晚窗口或 train/ref 输入，目标热点应出现 BSSN RHS/evolution 类函数。 |
| `519.lbm_r` | 低，skip 后仍偏 `initializeGrid/loadObstacleFile` | `spec_lbm_stream_kernel` 是合理的 LBM steady-state 机制 kernel，但当前 SPEC test profile 还没有校准到 collide/stream 主循环 | 继续增大 skip 或换 train/ref 输入；目标热点应出现 `LBM_performStreamCollide` 类函数。 |
| `510.parest_r` | 中高，skip 后进入 DoF/sparsity setup，仍不是纯 solver | `spec_parest_sparse_kernel` 覆盖稀疏访存/迭代求解，但缺少 deal.II DoF/sparsity setup 行为 | 可新增 `spec_parest_dof_kernel` 或把当前 sparse kernel 扩展出 setup phase。 |
| `511.povray_r` | 高，skip 后已经进入 ray/object intersection | `spec_povray_ray_kernel` 与当前 sampled-window 热点匹配度明显提高 | 当前 kernel 可作为 ray/intersection representative；parser kernel 变为可选补充。 |

### 6.9 统一 11 个 default smoke RTL 结果

结果目录：

```text
smart_run/results/spec11_default_unknown_clean/
```

`run.info` 已补正为：

| item | value |
|---|---|
| tag | `spec11_default` |
| git commit | `4d3a75a53ea7beefb6606009b731db7064013784` |
| branch | `main` |
| dirty | `dirty` |
| status | `11 passed, 0 failed` |

运行命令：

```bash
cd smart_run
BENCH_CASES='spec_mcf_kernel spec_mcf_sort_kernel spec_xz_lzma_kernel spec_x264_pixel_kernel spec_deepsjeng_search_kernel spec_leela_playout_kernel spec_exchange2_search_kernel spec_cactubssn_stencil_kernel spec_lbm_stream_kernel spec_parest_sparse_kernel spec_povray_ray_kernel' \
DUMP=off ./run_bench.sh spec11_default
```

统一 default smoke 结果：

| kernel | status | Kernel cycles | Kernel inst | CPI | IPC | FP inst | LDST | Cond branch misp | Frontend stall | Backend stall | VCS CPU time |
|---|---|---:|---:|---:|---:|---:|---:|---:|---:|---:|---:|
| `spec_mcf_kernel` | pass | `4366` | `2673` | `1.633` | `0.612` | `0.00%` | `93.94%` | `32.47%` | `21.35%` | `48.14%` | `20.500s` |
| `spec_mcf_sort_kernel` | pass | `16232` | `12324` | `1.317` | `0.759` | `0.00%` | `103.94%` | `34.44%` | `22.47%` | `49.70%` | `51.000s` |
| `spec_xz_lzma_kernel` | pass | `40082` | `68831` | `0.582` | `1.717` | `0.00%` | `15.35%` | `14.24%` | `10.90%` | `25.03%` | `143.320s` |
| `spec_x264_pixel_kernel` | pass | `10945` | `19397` | `0.564` | `1.772` | `0.00%` | `18.63%` | `11.18%` | `25.78%` | `31.94%` | `50.060s` |
| `spec_deepsjeng_search_kernel` | pass | `24365` | `22555` | `1.080` | `0.926` | `0.00%` | `14.81%` | `23.58%` | `15.47%` | `36.13%` | `94.430s` |
| `spec_leela_playout_kernel` | pass | `17925` | `19183` | `0.934` | `1.070` | `0.00%` | `23.94%` | `11.86%` | `21.62%` | `44.27%` | `45.380s` |
| `spec_exchange2_search_kernel` | pass | `18727` | `30809` | `0.608` | `1.645` | `0.00%` | `23.62%` | `11.73%` | `22.01%` | `29.93%` | `92.160s` |
| `spec_cactubssn_stencil_kernel` | pass | `13925` | `20936` | `0.665` | `1.503` | `26.81%` | `25.99%` | `7.98%` | `53.36%` | `46.54%` | `49.460s` |
| `spec_lbm_stream_kernel` | pass | `17584` | `28474` | `0.618` | `1.619` | `29.99%` | `10.16%` | `6.94%` | `43.37%` | `42.91%` | `55.630s` |
| `spec_parest_sparse_kernel` | pass | `7776` | `12843` | `0.605` | `1.652` | `22.67%` | `32.95%` | `4.85%` | `30.13%` | `34.19%` | `37.250s` |
| `spec_povray_ray_kernel` | pass | `10314` | `7029` | `1.467` | `0.682` | `107.77%` | `36.83%` | `35.45%` | `32.36%` | `49.78%` | `27.680s` |

### 6.10 当前结论

| question | answer |
|---|---|
| 现在是否有 11 个 SPEC-guided RTL kernels？ | 有。11 个 default smoke 已统一跑通，结果目录完整保存 `.perf`、log、asm、git metadata。 |
| 是否能作为官方 SPEC CPU2017 分数？ | 不能。它们是 SPEC-guided bare-metal representative kernels，不是 SPEC 原程序完整运行，也不是 reportable SPEC score。 |
| 是否足够用于 C910 RTL 架构机制研究？ | 足够作为 L2/L3 之间的 representative workload suite。它覆盖 pointer chasing、sort/compare、LZMA、pixel/ME、搜索、Go playout、sudoku/search、stencil、LBM-like stream、sparse/DoF、ray intersection。 |
| 当前最可信的 kernel | `mcf` 两个、`xz`、`x264`、`deepsjeng`、`leela`、`exchange2`、`povray`。这些已有较清晰的 SPEC function profile 对应关系。 |
| 当前需要继续校准的 kernel | `cactuBSSN`、`lbm`、`parest`。其中 `lbm` 的 SPEC test profile 仍最偏初始化，不能用当前权重声称代表 steady-state stream。 |
| 当前最适合研究的性能瓶颈 | `mcf_sort`/`mcf`/`povray` 的低 IPC、分支错预测和 backend stall；`cactuBSSN`/`lbm` 的 FP + frontend/backend stall；`parest` 的 LDST/间接访存；`xz`/`x264` 的高 IPC 稳态循环可作为对照组。 |
