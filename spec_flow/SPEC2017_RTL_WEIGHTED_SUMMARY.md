# SPEC2017-Guided RTL Weighted Summary

> Historical L2 v2 output. Most rows use one synthetic proxy kernel and are not
> multi-SimPoint weighted SPEC RTL performance. Use the v3 `*_RTL_PROXY_SUMMARY`
> reports after cluster mechanism grouping and ref calibration.

This is not an official SPEC CPU2017 score and not an exact SimPoint checkpoint result.
It combines SPEC2017 QEMU SimPoint/function profiles with bare-metal RTL representative kernels.

## Inputs

- SPEC size: `test`
- SPEC run root: `spec_runs`
- RTL results: `smart_run/results/archive/all_cases_1f451a653e1c_dirty`
- Kernel map: `spec_flow/spec2017_kernel_map.json`

## Suite Summary

| suite | benchmarks | geomean IPC | arithmetic IPC | arithmetic CPI |
|---|---:|---:|---:|---:|
| `fprate` | 13 | 1.228 | 1.286 | 0.860 |
| `intrate` | 10 | 1.212 | 1.273 | 0.870 |
| `all` | 23 | 1.221 | 1.281 | 0.864 |

## Benchmark Details

| suite | benchmark | manifest | coverage | RTL kernel(s) | weighted Kernel CPI | weighted Kernel IPC | frontend stall % | backend stall % | branch misp % | L1D load miss % |
|---|---|---|---|---|---:|---:|---:|---:|---:|---:|
| `intrate` | `500.perlbench_r` | compare=pass, simpoint=done, intervals=818, clusters=5 | medium | `spec_perlbench_regex_kernel` (1.000, IPC 0.751) | 1.332 | 0.751 | 37.81 | 51.86 | 33.33 | 0.90 |
| `intrate` | `502.gcc_r` | compare=pass, simpoint=done, intervals=1, clusters=1 | medium | `spec_gcc_compile_kernel` (1.000, IPC 1.410) | 0.709 | 1.410 | 32.43 | 38.40 | 18.68 | 0.21 |
| `intrate` | `505.mcf_r` | compare=pass, simpoint=done, intervals=231, clusters=4 | high | `spec_mcf_sort_kernel` (0.650, IPC 0.759)<br>`spec_mcf_kernel` (0.350, IPC 0.639) | 1.404 | 0.712 | 22.50 | 49.38 | 32.92 | 0.13 |
| `intrate` | `520.omnetpp_r` | compare=pass, simpoint=done, intervals=117, clusters=5 | medium | `spec_omnetpp_event_kernel` (1.000, IPC 1.423) | 0.703 | 1.422 | 7.63 | 20.59 | 10.49 | 0.06 |
| `intrate` | `523.xalancbmk_r` | compare=pass, simpoint=done, intervals=4, clusters=1 | medium | `spec_xalancbmk_xml_kernel` (1.000, IPC 1.296) | 0.772 | 1.295 | 63.26 | 55.82 | 5.88 | 0.00 |
| `intrate` | `525.x264_r` | compare=pass, simpoint=done, intervals=4758, clusters=5 | high | `spec_x264_pixel_kernel` (1.000, IPC 1.833) | 0.546 | 1.832 | 26.46 | 32.79 | 8.68 | 0.00 |
| `intrate` | `531.deepsjeng_r` | compare=pass, simpoint=done, intervals=391, clusters=5 | high | `spec_deepsjeng_search_kernel` (1.000, IPC 0.923) | 1.083 | 0.923 | 16.97 | 35.98 | 23.80 | 0.25 |
| `intrate` | `541.leela_r` | compare=pass, simpoint=done, intervals=240, clusters=5 | high | `spec_leela_playout_kernel` (1.000, IPC 1.053) | 0.949 | 1.054 | 22.77 | 45.20 | 12.07 | 0.00 |
| `intrate` | `548.exchange2_r` | compare=pass, simpoint=done, intervals=979, clusters=4 | high | `spec_exchange2_search_kernel` (1.000, IPC 1.617) | 0.618 | 1.618 | 20.90 | 30.07 | 12.83 | 0.19 |
| `intrate` | `557.xz_r` | compare=pass, simpoint=done, intervals=392, clusters=4 | high | `spec_xz_lzma_kernel` (1.000, IPC 1.712) | 0.584 | 1.712 | 10.48 | 24.85 | 14.38 | 0.00 |
| `fprate` | `503.bwaves_r` | compare=pass, simpoint=done, intervals=258, clusters=5 | medium | `spec_bwaves_stencil_kernel` (1.000, IPC 1.702) | 0.588 | 1.701 | 22.96 | 30.99 | 4.20 | 0.01 |
| `fprate` | `507.cactuBSSN_r` | compare=pass, simpoint=done, intervals=283, clusters=5 | high | `spec_cactubssn_stencil_kernel` (1.000, IPC 1.494) | 0.669 | 1.495 | 53.73 | 46.77 | 8.41 | 0.24 |
| `fprate` | `508.namd_r` | compare=pass, simpoint=done, intervals=308, clusters=5 | high | `spec_namd_pair_kernel` (1.000, IPC 0.818) | 1.223 | 0.818 | 73.17 | 71.76 | 5.80 | 0.00 |
| `fprate` | `510.parest_r` | compare=pass, simpoint=done, intervals=277, clusters=5 | low | `spec_parest_sparse_kernel` (1.000, IPC 1.410) | 0.709 | 1.410 | 33.36 | 41.03 | 9.63 | 0.11 |
| `fprate` | `511.povray_r` | compare=pass, simpoint=done, intervals=23, clusters=4 | high | `spec_povray_ray_kernel` (1.000, IPC 0.671) | 1.491 | 0.671 | 31.98 | 49.17 | 35.19 | 0.00 |
| `fprate` | `519.lbm_r` | compare=pass, simpoint=done, intervals=63, clusters=2 | high | `spec_lbm_stream_kernel` (1.000, IPC 1.717) | 0.582 | 1.718 | 41.19 | 40.95 | 3.95 | 0.11 |
| `fprate` | `521.wrf_r` | compare=pass, simpoint=done, intervals=743, clusters=5 | medium | `spec_wrf_stencil_kernel` (1.000, IPC 1.475) | 0.678 | 1.475 | 38.76 | 42.60 | 15.81 | 0.00 |
| `fprate` | `526.blender_r` | compare=pass, simpoint=done, intervals=12, clusters=4 | medium | `spec_blender_render_kernel` (1.000, IPC 0.818) | 1.223 | 0.818 | 73.17 | 71.76 | 5.80 | 0.00 |
| `fprate` | `527.cam4_r` | compare=pass, simpoint=done, intervals=1309, clusters=4 | medium | `spec_cam4_climate_kernel` (1.000, IPC 1.618) | 0.618 | 1.618 | 44.70 | 37.32 | 4.56 | 0.00 |
| `fprate` | `538.imagick_r` | compare=pass, simpoint=done, intervals=1, clusters=1 | medium | `spec_imagick_filter_kernel` (1.000, IPC 1.238) | 0.808 | 1.238 | 45.41 | 45.91 | 26.88 | 0.00 |
| `fprate` | `544.nab_r` | compare=pass, simpoint=done, intervals=60, clusters=3 | high | `spec_nab_md_kernel` (1.000, IPC 0.813) | 1.230 | 0.813 | 73.57 | 71.96 | 5.80 | 0.00 |
| `fprate` | `549.fotonik3d_r` | compare=pass, simpoint=done, intervals=386, clusters=4 | low | `spec_fotonik3d_stencil_kernel` (1.000, IPC 1.475) | 0.678 | 1.475 | 38.76 | 42.60 | 15.81 | 0.00 |
| `fprate` | `554.roms_r` | compare=pass, simpoint=done, intervals=292, clusters=5 | medium | `spec_roms_stencil_kernel` (1.000, IPC 1.475) | 0.678 | 1.475 | 38.76 | 42.60 | 15.81 | 0.00 |

## Interpretation Rules

- `geomean IPC` is only a repository-local summary across representative kernels; it is not a SPEC ratio.
- For one-kernel mappings, weighted CPI equals that kernel's RTL Kernel CPI.
- For split mappings, CPI is combined by normalized component weights.
- Coverage `low/medium/high` describes how directly the bare-metal kernel matches the SPEC function profile.
- Exact SimPoint RTL requires checkpoint/restore, warmup, detailed interval execution, and weighted aggregation over real SPEC state.
