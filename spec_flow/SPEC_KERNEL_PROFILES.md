# SPEC RTL Kernel Profile 总表

Rate/Speed 的 43 个 benchmark 分别映射到 43 个独立 bare-metal RTL case；
Rate 和 Speed 不共享 case、ELF、权重或实测结果。每个 case 只有一个完整 ELF，
程序特征统计和 RTL 仿真使用相同的 quick/full 参数。

`simpoint-composition` 是专用多机制 composite；
`simpoint-cluster-composition` 将该 benchmark 自身的 SimPoint cluster
按语义分组后，在一个 ELF 内执行并校准动态指令权重。所有 43 个 case
均包含至少两个可独立计数的机制阶段。full 另含 128 KiB footprint 脚手架，
计入 ROI/工作集，
但不计入机制权重，且动态指令占比不得超过 10%。

| case | 对应 SPEC benchmark | 校准级别 | quick ROI | quick warmup | full ROI | full warmup | full 工作集 | footprint 占比 |
|---|---|---|---:|---:|---:|---:|---:|---:|
| `spec_505_mcf_composite_kernel` | 505.mcf_r | 多机制 SimPoint 校准 | 19,707 | 0 | 501,991 | 235,820 | 594,944 B | N/A |
| `spec_510_parest_composite_kernel` | 510.parest_r | 多机制 SimPoint 校准 | 108,350 | 0 | 497,534 | 277,686 | 244,480 B | N/A |
| `spec_600_perlbench_speed_kernel` | 600.perlbench_s | 多 cluster 机制校准 | 144,084 | 2,334 | 460,754 | 22,823 | 131,968 B | 6.227% |
| `spec_602_gcc_speed_kernel` | 602.gcc_s | 多 cluster 机制校准 | 51,947 | 2,334 | 495,409 | 22,823 | 133,120 B | 5.791% |
| `spec_603_bwaves_speed_kernel` | 603.bwaves_s | 多 cluster 机制校准 | 59,578 | 2,334 | 505,212 | 22,823 | 132,608 B | 5.679% |
| `spec_605_mcf_composite_kernel` | 605.mcf_s | 多机制 SimPoint 校准 | 19,188 | 0 | 462,143 | 189,100 | 501,504 B | N/A |
| `spec_607_cactubssn_speed_kernel` | 607.cactuBSSN_s | 多 cluster 机制校准 | 290,141 | 2,335 | 608,892 | 22,824 | 132,800 B | 4.712% |
| `spec_619_lbm_speed_kernel` | 619.lbm_s | 多 cluster 机制校准 | 144,356 | 2,334 | 461,700 | 22,823 | 132,416 B | 6.214% |
| `spec_620_omnetpp_speed_kernel` | 620.omnetpp_s | 多 cluster 机制校准 | 270,572 | 2,334 | 571,552 | 22,823 | 132,160 B | 5.019% |
| `spec_621_wrf_speed_kernel` | 621.wrf_s | 多 cluster 机制校准 | 163,571 | 2,335 | 519,246 | 22,824 | 132,672 B | 5.525% |
| `spec_623_xalancbmk_speed_kernel` | 623.xalancbmk_s | 多 cluster 机制校准 | 69,018 | 2,334 | 511,628 | 22,823 | 131,968 B | 5.607% |
| `spec_625_x264_speed_kernel` | 625.x264_s | 多 cluster 机制校准 | 50,394 | 2,334 | 482,118 | 22,823 | 132,544 B | 5.951% |
| `spec_627_cam4_speed_kernel` | 627.cam4_s | 多 cluster 机制校准 | 211,874 | 2,334 | 452,416 | 22,823 | 132,160 B | 6.341% |
| `spec_631_deepsjeng_speed_kernel` | 631.deepsjeng_s | 多 cluster 机制校准 | 18,823 | 2,334 | 480,084 | 22,823 | 131,776 B | 5.976% |
| `spec_638_imagick_speed_kernel` | 638.imagick_s | 多 cluster 机制校准 | 64,268 | 2,334 | 478,480 | 22,823 | 132,544 B | 5.996% |
| `spec_641_leela_speed_kernel` | 641.leela_s | 多 cluster 机制校准 | 45,577 | 2,334 | 485,046 | 22,823 | 131,904 B | 5.915% |
| `spec_644_nab_speed_kernel` | 644.nab_s | 多 cluster 机制校准 | 462,212 | 2,335 | 490,899 | 22,824 | 133,248 B | 5.844% |
| `spec_648_exchange2_speed_kernel` | 648.exchange2_s | 多 cluster 机制校准 | 27,253 | 2,334 | 491,745 | 22,823 | 132,736 B | 5.834% |
| `spec_649_fotonik3d_speed_kernel` | 649.fotonik3d_s | 多 cluster 机制校准 | 166,355 | 2,335 | 527,598 | 22,824 | 132,800 B | 5.438% |
| `spec_654_roms_speed_kernel` | 654.roms_s | 多 cluster 机制校准 | 108,661 | 2,335 | 463,100 | 22,824 | 132,800 B | 6.195% |
| `spec_657_xz_speed_kernel` | 657.xz_s | 多 cluster 机制校准 | 157,754 | 2,335 | 501,819 | 22,824 | 133,120 B | 5.717% |
| `spec_blender_render_kernel` | 526.blender_r | 多 cluster 机制校准 | 515,710 | 2,335 | 544,397 | 22,824 | 133,120 B | 5.270% |
| `spec_bwaves_stencil_kernel` | 503.bwaves_r | 多 cluster 机制校准 | 227,894 | 8,111 | 484,422 | 28,600 | 136,064 B | 5.922% |
| `spec_cactubssn_stencil_kernel` | 507.cactuBSSN_r | 多 cluster 机制校准 | 548,331 | 5,864 | 577,018 | 26,353 | 141,760 B | 4.972% |
| `spec_cam4_climate_kernel` | 527.cam4_r | 多 cluster 机制校准 | 304,744 | 2,335 | 591,493 | 22,728 | 132,544 B | 4.850% |
| `spec_deepsjeng_search_kernel` | 531.deepsjeng_r | 多 cluster 机制校准 | 411,822 | 25,572 | 440,494 | 46,061 | 134,336 B | 6.513% |
| `spec_exchange2_search_kernel` | 548.exchange2_r | 多 cluster 机制校准 | 32,244 | 26,330 | 544,501 | 46,818 | 137,152 B | 5.269% |
| `spec_fotonik3d_stencil_kernel` | 549.fotonik3d_r | 多 cluster 机制校准 | 61,276 | 1,370 | 518,638 | 21,857 | 132,736 B | 5.532% |
| `spec_gcc_compile_kernel` | 502.gcc_r | 多 cluster 机制校准 | 68,193 | 14,259 | 523,393 | 34,751 | 140,544 B | 5.481% |
| `spec_imagick_filter_kernel` | 538.imagick_r | 多 cluster 机制校准 | 81,816 | 2,334 | 519,444 | 22,823 | 132,544 B | 5.523% |
| `spec_lbm_stream_kernel` | 519.lbm_r | 多 cluster 机制校准 | 148,451 | 3,924 | 473,987 | 24,413 | 134,912 B | 6.053% |
| `spec_leela_playout_kernel` | 541.leela_r | 多 cluster 机制校准 | 142,962 | 1,038 | 553,219 | 21,526 | 132,096 B | 5.186% |
| `spec_nab_md_kernel` | 544.nab_r | 多 cluster 机制校准 | 167,533 | 2,334 | 531,270 | 22,823 | 132,672 B | 5.400% |
| `spec_namd_pair_kernel` | 508.namd_r | 多 cluster 机制校准 | 211,293 | 2,335 | 451,196 | 22,824 | 132,992 B | 6.358% |
| `spec_omnetpp_event_kernel` | 520.omnetpp_r | 多 cluster 机制校准 | 273,006 | 2,334 | 575,366 | 22,823 | 132,160 B | 4.986% |
| `spec_perlbench_regex_kernel` | 500.perlbench_r | 多 cluster 机制校准 | 105,267 | 2,334 | 554,891 | 22,823 | 131,968 B | 5.170% |
| `spec_pop2_ocean_kernel` | 628.pop2_s | 多 cluster 机制校准 | 290,205 | 1,759 | 609,048 | 22,248 | 133,120 B | 4.710% |
| `spec_povray_ray_kernel` | 511.povray_r | 多 cluster 机制校准 | 68,358 | 721 | 575,207 | 21,208 | 132,288 B | 4.988% |
| `spec_roms_stencil_kernel` | 554.roms_r | 多 cluster 机制校准 | 327,272 | 2,335 | 440,850 | 23,208 | 132,480 B | 6.508% |
| `spec_wrf_stencil_kernel` | 521.wrf_r | 多 cluster 机制校准 | 349,386 | 2,335 | 468,602 | 23,208 | 132,928 B | 6.123% |
| `spec_x264_pixel_kernel` | 525.x264_r | 多 cluster 机制校准 | 228,663 | 12,780 | 485,986 | 33,269 | 132,800 B | 5.903% |
| `spec_xalancbmk_xml_kernel` | 523.xalancbmk_r | 多 cluster 机制校准 | 113,468 | 2,334 | 482,688 | 22,823 | 131,968 B | 5.944% |
| `spec_xz_lzma_kernel` | 557.xz_r | 多 cluster 机制校准 | 92,578 | 16,930 | 502,102 | 38,442 | 135,424 B | 5.714% |

## 约束与入口

- full ROI 契约范围为 400,000 至 620,000 条动态指令。
- full 工作集下限为 128 KiB；三个专用 composite 使用各自更高的实测下限。
- warmup 位于 `perf_warmup_start/end`，不计入 ROI。
- 所有实测值的漂移容差为 0；源码、编译器或参数变化后必须重新统计并显式更新契约。
- RTL/QEMU retired 比较另允许 6 条整周期退休边界偏差，不属于 workload 契约漂移。
- 机器可读契约：`spec_flow/spec_kernel_profiles.json`。
- quick/full 统一入口：`spec_flow/run_spec_kernel_profiles.sh`。
- 完整特征结果：`smart_run/kernel_features/spec_all_43_quick_final/` 和
  `smart_run/kernel_features/spec_all_43_full_final/`。

这些 kernel 用于微结构机制研究和版本间相对比较，不是 SPEC CPU2017 原程序
代表区间，也不能生成或替代正式 SPEC 分数。
