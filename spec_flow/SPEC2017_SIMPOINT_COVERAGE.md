# SPEC2017 SimPoint 覆盖与 Representative Kernel 对照

本文档完成两个目的：

1. 固化当前 SPEC CPU2017 `test` workload 的 QEMU BBV、SimPoint 和函数热点结果。
2. 对照 `smart_run/tests/cases/spec_*` representative kernel，判断每个 kernel 对真实 SPEC 热点的覆盖程度和下一步校准方向。

当前结果不是 SPEC 官方性能分数，也不是 RTL 上跑完整 SPEC。它的用途是为 RTL 可承受的小 kernel 选择、性能瓶颈归因和后续微结构优化提供 workload 依据。

## 1. SimPoint 结果总表

运行口径：

| 项目 | 当前配置 |
|---|---|
| SPEC suite | SPEC CPU2017 `intrate` + `fprate` |
| workload | `test` |
| 执行方式 | Xuantie QEMU `qemu-riscv64 -cpu c910` |
| BBV interval | 100,000,000 dynamic instructions |
| SimPoint | `maxK=5` |
| 编译器 | Xuantie GCC Linux glibc V3.1.0, GCC 14.1.1 |
| 优化选项 | `-O2 -march=rv64imafdcxtheadc -mabi=lp64d -mtune=c910` |
| 结果目录 | `/work/spec_runs/<benchmark>_test_c910/` |

注意：函数热点来自 QEMU basic block map 到 ELF 符号的归因。`[external-or-unknown]` 表示 PC 不在当前 benchmark ELF 的 text 符号范围内，通常来自动态库、Fortran runtime、libgcc/libm/libc 或当前 BBV map 没有记录的共享对象符号。旧版本 profile 中曾把这类地址误归到 `data_start`；当前 analyzer 已避免把 `data_start` 当函数热点。

| Suite | Benchmark | Compare | Intervals | Blocks | SimPoints | Top 函数热点 |
|---|---|---:|---:|---:|---:|---|
| intrate | `500.perlbench_r` | pass | 818 | 6,148,105 | 5 | `[external-or-unknown]` 18.68%, `Perl_yylex` 6.52%, `Perl_pp_multideref` 4.78%, `Perl_sv_setsv_flags` 3.68%, `Perl_keyword` 3.11% |
| intrate | `502.gcc_r` | pass | 1 | 40,367 | 1 | `[external-or-unknown]` 18.80%, `ggc_alloc_stat` 5.20%, `do_multiply` 3.62%, `recog_32` 3.42%, `ira_init` 3.11% |
| intrate | `505.mcf_r` | pass | 231 | 3,474 | 4 | `spec_qsort` 32.30%, `cost_compare` 26.93%, `primal_bea_mpp` 21.51%, `price_out_impl` 12.74% |
| intrate | `520.omnetpp_r` | pass | 117 | 22,479 | 5 | `[external-or-unknown]` 55.50%, `cMessageHeap::shiftup` 6.77%, `_PROCEDURE_LINKAGE_TABLE_` 2.46%, `sendDelayed` 1.15%, `cMessageHeap::insert` 1.10% |
| intrate | `523.xalancbmk_r` | pass | 4 | 30,740 | 1 | `XalanDOMStringCache::release` 25.83%, `[external-or-unknown]` 24.66%, `XStringCachedAllocator::destroy` 4.50%, `VariablesStack::findEntry` 3.36%, `XalanDOMString::equals` 3.24% |
| intrate | `525.x264_r` | pass | 4,758 | 10,139 | 5 | `x264_pixel_satd_8x4` 16.35%, `get_ref` 15.81%, `x264_pixel_sad_x4_16x16` 11.61%, `x264_pixel_sad_16x16` 7.37% |
| intrate | `531.deepsjeng_r` | pass | 391 | 6,083 | 5 | `feval` 14.43%, `qsearch` 9.16%, `FindFirstRemove` 7.90%, `search` 7.30%, `make` 5.80% |
| intrate | `541.leela_r` | pass | 240 | 7,349 | 5 | `FastState::play_random_move` 11.47%, `FastBoard::get_pattern_fast_augment` 9.88%, `FastBoard::self_atari` 9.86%, `FastBoard::update_board_fast` 8.30% |
| intrate | `548.exchange2_r` | pass | 979 | 5,956 | 4 | `digits_2` 87.52%, `[external-or-unknown]` 6.26%, `specific` 2.84%, `new_solver` 1.77%, `hidden_triplets` 0.52% |
| intrate | `557.xz_r` | pass | 392 | 57,158 | 4 | `lzma_lzma_optimum_normal` 20.49%, `sha_compress` 14.66%, `lzma_lzma_encode` 12.88%, `lzma_decode` 12.44%, `bt_skip_func` 12.25% |
| fprate | `503.bwaves_r` | pass | 258 | 9,851 | 5 | `mat_times_vec_` 49.46%, `shell_` 20.61%, `jacobian_` 9.29%, `bi_cgstab_block_` 8.94%, `[external-or-unknown]` 8.22% |
| fprate | `507.cactuBSSN_r` | pass | 283 | 38,142 | 5 | `ML_BSSN_Advect_Body` 37.77%, `ML_BSSN_RHS_Body` 35.63%, `ML_BSSN_constraints_Body` 9.84%, `ML_BSSN_convertToADMBaseDtLapseShift_Body` 6.08%, `[external-or-unknown]` 4.12% |
| fprate | `508.namd_r` | pass | 308 | 6,208 | 5 | `calc_pair_energy` 18.84%, `calc_pair_energy_fullelect` 13.01%, `calc_pair_fullelect` 8.85%, `calc_self_energy` 7.30% |
| fprate | `510.parest_r` | pass | 277 | 31,441 | 5 | `[external-or-unknown]` 94.76%, `SparsityPattern::operator()` 1.41%, `ConstraintMatrix::add_entries_local_to_global` 1.38%, `ConstraintMatrix::condense` 0.93%, `SparsityPattern::matrix_position` 0.36% |
| fprate | `511.povray_r` | pass | 23 | 14,199 | 4 | `All_Plane_Intersections` 13.46%, `All_CSG_Intersect_Intersections` 13.03%, `All_Sphere_Intersections` 12.49%, `Check_And_Enqueue` 8.35% |
| fprate | `519.lbm_r` | pass | 63 | 2,742 | 2 | `LBM_performStreamCollideTRT` 93.18%, `LBM_showGridStatistics` 3.19%, `LBM_handleInOutFlow` 1.30%, `LBM_initializeGrid` 0.94%, `[external-or-unknown]` 0.84% |
| fprate | `521.wrf_r` | pass | 743 | 84,448 | 5 | `[external-or-unknown]` 18.15%, `advect_scalar` 6.79%, `advect_scalar_pd` 5.87%, `advance_uv` 5.53%, `advance_w` 4.33% |
| fprate | `526.blender_r` | pass | 12 | 25,636 | 4 | `[external-or-unknown]` 26.36%, `shade_input_calc_viewco` 5.40%, `ray_shadow_qmc` 4.68%, `RE_rayobject_intersect` 4.57%, `bvh_node_stack_raycast` 4.46% |
| fprate | `527.cam4_r` | pass | 1,309 | 40,244 | 4 | `[external-or-unknown]` 35.88%, `radabs` 15.74%, `trcab` 5.69%, `initp_` 3.52%, `radcswmx` 3.04% |
| fprate | `538.imagick_r` | pass | 1 | 7,481 | 1 | `HorizontalFilter` 58.28%, `[external-or-unknown]` 18.02%, `WriteTGAImage` 9.29%, `WritePixelCachePixels` 3.24%, `ReadPixelCachePixels` 3.24% |
| fprate | `544.nab_r` | pass | 60 | 5,360 | 3 | `mme34` 58.58%, `[external-or-unknown]` 14.05%, `nbond` 9.96%, `nblist` 5.28%, `ephi` 4.76% |
| fprate | `549.fotonik3d_r` | pass | 386 | 8,484 | 4 | `[external-or-unknown]` 91.71%, `mat_updatee` 2.37%, `updateh` 1.74%, `mat_init` 1.45%, `upml_updatee_simple` 0.60% |
| fprate | `554.roms_r` | pass | 292 | 12,427 | 5 | `step2d_tile` 21.40%, `[external-or-unknown]` 9.73%, `pre_step3d` 9.19%, `step3d_t` 7.40%, `t3dmix2` 6.84% |

当前覆盖结论：`intrate` 10/10 和 `fprate` 13/13 均已完成 full compare + BBV + SimPoint + function profile，没有 missing，也没有 sampled-only 残留。

## 2. Representative Kernel 覆盖判断

`smart_run/run_bench.sh` 默认列表已经包含 23 个 SPEC representative kernel，名义上覆盖 SPEC2017 `intrate` 和 `fprate` 的全部 benchmark。它们不是 SPEC 源码，也不是 SimPoint checkpoint；它们是可以在 RTL 中快速跑的机制级 workload。因此这里评价的是“是否覆盖主要微结构压力源”，不是“是否等价于官方 SPEC benchmark”。

覆盖等级定义：

| 等级 | 含义 |
|---|---|
| 高 | kernel 的核心循环和 SPEC top 函数语义直接对应，适合优先用于 RTL 瓶颈定位。 |
| 中 | kernel 覆盖了主要方向，但缺少关键子阶段、对象模型、运行时行为，或 test profile 符号归因噪声较大。 |
| 待增强 | 当前 kernel 只能作为粗粒度占位压力源，若要支撑结论，需要改 kernel、增加子 kernel，或换更大 workload 校准。 |

| Benchmark | 当前 kernel | 覆盖等级 | 覆盖到的主要机制 | 主要缺口与下一步 |
|---|---|---|---|---|
| `500.perlbench_r` | `spec_perlbench_regex_kernel` | 中 | lexer/parser、regex/state machine、hash/table lookup、分支密集控制流 | SPEC 热点是 Perl 解释器内部的 `yylex`、多级解引用、标量赋值和 keyword 识别。当前 kernel 方向正确，但还缺 Perl SV/AV/HV 对象布局、引用计数、opcode dispatch 和解释器栈行为。 |
| `502.gcc_r` | `spec_gcc_compile_kernel` | 中 | allocator churn、RTL recognizer table walk、multiply/constant-fold 风格整数计算、IRA-like interference graph | 已从泛化图遍历扩展到覆盖 `ggc_alloc_stat`、`do_multiply`、`recog_32`、`ira_init` 方向。边界是 SPEC test 只有 1 个 interval，不能过度代表完整 GCC 编译流程。 |
| `505.mcf_r` | `spec_mcf_sort_kernel` + `spec_mcf_kernel` | 高 | sort/compare、arc scan、price/primal、间接访存和分支 | 与 top 函数高度吻合。后续可把两个 kernel 按 SimPoint/function profile 权重组合，用于 mcf-like 综合 RTL 结果。 |
| `520.omnetpp_r` | `spec_omnetpp_event_kernel` | 中 | priority queue、event insert/shiftup、event dispatch、指针式事件访问 | SPEC top 中 `[external-or-unknown]` 很高，说明当前函数归因还缺共享对象/PLT 级信息；语义热点仍能看到 message heap 和 delayed send。当前 kernel 覆盖 heap/event 方向，但缺 C++ 虚函数、对象分配和模块/gate 关系。 |
| `523.xalancbmk_r` | `spec_xalancbmk_xml_kernel` | 中 | XML/DOM traversal、string/cache、vector insert、attribute/name lookup | SPEC test 只有 4 个 interval、1 个 SimPoint，稳定性较弱。当前 kernel 覆盖 XML-like traversal，但要更贴近 `XalanDOMStringCache`、allocator destroy/release 和 vector insert，需要加强字符串生命周期和内存管理压力。 |
| `525.x264_r` | `spec_x264_pixel_kernel` | 高 | SATD/SAD、reference load、multi-candidate motion search、pixel block 计算 | 与 top 函数直接对应，是当前最适合做“高 IPC/规则 SIMD-like integer”对照的 kernel 之一。 |
| `531.deepsjeng_r` | `spec_deepsjeng_search_kernel` | 高 | alpha-beta/qsearch、move generation、bitboard/eval、分支密集搜索 | 与 `feval/qsearch/search/make` 等热点方向一致。后续重点看分支预测、ROB flush、IQ not-ready 和前端恢复。 |
| `541.leela_r` | `spec_leela_playout_kernel` | 高 | Go playout、pattern lookup、board update、随机选择、UCT-like selection | 与 top 函数中的 random move、pattern、自吃判断、board update 对应较好。适合作为 branch + table lookup + irregular update case。 |
| `548.exchange2_r` | `spec_exchange2_search_kernel` | 高 | branch-heavy recursive/search solver、深度搜索、表访问 | `digits_2` 占比极高，说明 workload 很集中。当前 search kernel 能覆盖控制流压力，但若要更准，应把数字/组合枚举和剪枝条件做得更像 Fortran solver。 |
| `557.xz_r` | `spec_xz_lzma_kernel` | 高 | LZMA optimum、hash-chain/match finder、range-like update、SHA-like mix、decode path | 与 top 函数直接对应。适合作为整数、访存、分支混合且较稳定的代表 case。 |
| `503.bwaves_r` | `spec_bwaves_stencil_kernel` | 中 | FP banded matvec、Jacobian-like 系数更新、shell/residual loop、BiCGStab-like 向量递推 | 已从纯 stencil 扩展到覆盖 `mat_times_vec_`、`shell_`、`jacobian_`、`bi_cgstab_block_` 方向。仍需 RTL 性能计数器结果确认其瓶颈是否接近 bwaves 类 matvec/solver。 |
| `507.cactuBSSN_r` | `spec_cactubssn_stencil_kernel` | 高 | tensor stencil、regular FP load/compute/store、多张量 RHS/Advect/constraints | 与 BSSN top 函数高度一致。适合研究 FP pipe、load/store 带宽、DCache、issue queue FP not-ready。 |
| `508.namd_r` | `spec_namd_pair_kernel` | 高 | pair force、neighbor list、FP distance/energy、电荷/范德华计算 | 与 NAMD pair-energy top 函数方向一致。后续可增强 full electrostatics/merge path，但当前已可作为 pairwise FP/访存 case。 |
| `510.parest_r` | `spec_parest_sparse_kernel` | 待增强 | sparse matrix-vector、ILU/SSOR-like precondition、GMRES-like iterative solver、间接访存 | 当前修正后的 SPEC test profile 被 `[external-or-unknown]` 94.76% 主导，benchmark ELF 内可见热点主要是 `SparsityPattern` 和 `ConstraintMatrix` setup/condense，不再能直接证明 solver 主循环占主导。`spec_parest_sparse_kernel` 仍然是研究 sparse/GMRES 机制的有用 kernel，但需要补共享对象符号归因、静态链接或更大 workload 后再确认它对 `510.parest_r` 的代表性。 |
| `511.povray_r` | `spec_povray_ray_kernel` | 高 | ray/object intersection、bbox priority queue、plane/sphere/CSG intersection、几何 FP 分支 | 与 top 函数直接对应。适合研究 branch + FP compare + irregular object traversal。 |
| `519.lbm_r` | `spec_lbm_stream_kernel` | 高 | LBM stream/collide、规则内存带宽、固定 Q=19 访问模式 | `LBM_performStreamCollideTRT` 占 93.18%，当前 kernel 语义非常集中。适合做访存带宽和 store/load pipeline case。 |
| `521.wrf_r` | `spec_wrf_stencil_kernel` | 中 | weather stencil、advect scalar、velocity advance、规则 FP update | 方向正确，但 WRF 真实代码包含多物理过程、边界条件、数组 layout 和大量 Fortran 调用边界。当前 kernel 可先用作 stencil 类代表，但不能单独代表完整 WRF。 |
| `526.blender_r` | `spec_blender_render_kernel` | 中 | render/ray-like object interaction、BVH/raycast、shadow ray、shader view coordinate | 与热点方向一致，但 test 只有 12 个 interval，且 `[external-or-unknown]` 较高。当前 kernel 和 `povray` 类似，后续可加入 BVH stack、shader material 分支和 ray_shadow_qmc 行为以拉开差异。 |
| `527.cam4_r` | `spec_cam4_climate_kernel` | 中 | climate column physics、radiation/vertical recurrence、FP array update | 方向覆盖 climate column，但真实热点偏 radiation (`radabs/trcab/radcswmx`) 和初始化/路由。当前 kernel 需要增加 radiation absorption/transmission 递推和 column loop 才能更准。 |
| `538.imagick_r` | `spec_imagick_filter_kernel` | 高 | horizontal filter、image convolution/color transform、pixel cache 读写 | `HorizontalFilter` 占 58.28%，当前 filter kernel 方向明确；但只有 1 个 interval，后续最好用更大输入确认稳定性。 |
| `544.nab_r` | `spec_nab_md_kernel` | 高 | molecular mechanics、pair-list、nonbonded/electrostatic FP update | `mme34`、`nbond`、`nblist`、`ephi` 与当前 MD kernel 对应较好。适合作为小型分子力场 FP + neighbor case。 |
| `549.fotonik3d_r` | `spec_fotonik3d_stencil_kernel` | 待增强 | 3D FDTD/stencil FP update | top profile 被 `[external-or-unknown]` 91.71% 主导；修正后确认这不是 `data_start` 算法热点，而是共享库/运行时地址未归属。benchmark ELF 内可见热点仍是 `mat_updatee/updateh/upml_update*`，方向支持 FDTD kernel，但需要补共享库符号归因或换更大 workload 后再声称高覆盖。 |
| `554.roms_r` | `spec_roms_stencil_kernel` | 高 | ocean-model step2d/step3d、mixing、FP recurrence、stencil-like update | 与 `step2d_tile`、`pre_step3d`、`step3d_t`、`t3dmix2` 对应较好。适合研究 FP + regular memory + branch 边界条件。 |

## 3. 当前优先级

优先用于 RTL 瓶颈定位的代表集：

| 类别 | 建议 case |
|---|---|
| 规则高 IPC / 对照 | `spec_x264_pixel_kernel`, `spec_xz_lzma_kernel` |
| 分支和搜索 | `spec_deepsjeng_search_kernel`, `spec_leela_playout_kernel`, `spec_exchange2_search_kernel`, `spec_povray_ray_kernel` |
| 不规则访存 / sparse | `spec_mcf_kernel`, `spec_mcf_sort_kernel` |
| FP stencil / regular memory | `spec_cactubssn_stencil_kernel`, `spec_lbm_stream_kernel`, `spec_roms_stencil_kernel` |
| MD / pair force | `spec_namd_pair_kernel`, `spec_nab_md_kernel` |

需要优先增强或重新校准的 case：

| Benchmark | 当前问题 | 建议动作 |
|---|---|---|
| `502.gcc_r` | 已补入 allocator/recognizer/IRA-like 行为，但 SPEC test 只有 1 个 interval | 跑 `spec_gcc_compile_kernel`，检查分支错预测、前端恢复、整数 ALU、ROB/IQ 压力是否比旧泛化版本更接近编译器后端。 |
| `503.bwaves_r` | 已补入 matvec/solver/Jacobian 行为，但尚未用 RTL 数据确认瓶颈形态 | 跑 `spec_bwaves_stencil_kernel`，检查 FP issue、load/store、DCache、IQ not-ready 是否符合 matvec/solver 类 workload。 |
| `510.parest_r` | `[external-or-unknown]` 占比 94.76%，当前可见热点更像 sparse setup，而不是 solver 主循环 | 先不要用当前 SPEC test profile 强行证明 `spec_parest_sparse_kernel` 代表 parest；应补共享对象/module map、尝试静态链接，或切到更能进入求解阶段的 workload 再校准。 |
| `549.fotonik3d_r` | `[external-or-unknown]` 占比 91.71%，主要动态指令不在 benchmark ELF text 符号范围内 | 下一步应让 BBV map 记录共享对象模块，或用静态链接/更大 workload 重新采样；当前 kernel 暂作 FDTD 占位，不做强结论。 |
| `520.omnetpp_r` | C++ 对象/事件系统被简化 | 增加对象池、虚调用形态、message/gate pointer graph。 |
| `523.xalancbmk_r` | string cache/allocator 生命周期未充分覆盖 | 增强 DOMString cache、vector insert、allocator release/destroy。 |
| `527.cam4_r` | radiation 子过程不够具体 | 增加 radabs/trcab/radcswmx-like column radiation phase。 |

## 4. 建议的下一步运行

如果要用当前最稳的一组 SPEC representative kernel 继续做 RTL 瓶颈分析，建议先跑：

```bash
cd smart_run
BENCH_CASES="spec_x264_pixel_kernel spec_xz_lzma_kernel spec_deepsjeng_search_kernel spec_leela_playout_kernel spec_exchange2_search_kernel spec_povray_ray_kernel spec_mcf_kernel spec_mcf_sort_kernel spec_cactubssn_stencil_kernel spec_lbm_stream_kernel spec_roms_stencil_kernel spec_namd_pair_kernel spec_nab_md_kernel" ./run_bench.sh spec_representative_core
```

`spec_parest_sparse_kernel` 暂时建议作为 sparse/GMRES 机制探索的可选项单独跑，不放入最稳核心集：

```bash
cd smart_run
BENCH_CASES="spec_parest_sparse_kernel" ./run_bench.sh spec_parest_sparse_probe
```

如果目标是全量名义覆盖，则直接跑默认列表即可：

```bash
cd smart_run
./run_bench.sh spec2017_representative_all
```

注意：上述命令会跑 RTL 仿真，所有 EDA/RTL 相关命令应在非沙箱环境中由用户手动执行。
