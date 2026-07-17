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
- Kernel map: `spec_flow/spec2017_speed_kernel_map.json`

## Suite Summary

| suite | benchmarks | geomean IPC | arithmetic IPC | arithmetic CPI |
|---|---:|---:|---:|---:|
| `fpspeed` | 10 | 1.421 | 1.448 | 0.721 |
| `intspeed` | 10 | 1.212 | 1.273 | 0.870 |
| `all` | 20 | 1.313 | 1.361 | 0.795 |

## Benchmark Details

| suite | benchmark | manifest | coverage | RTL kernel(s) | weighted Kernel CPI | weighted Kernel IPC | frontend stall % | backend stall % | branch misp % | L1D load miss % |
|---|---|---|---|---|---:|---:|---:|---:|---:|---:|
| `intspeed` | `600.perlbench_s` | compare=pass, simpoint=done, intervals=818, clusters=4 | medium | `spec_perlbench_regex_kernel` (1.000, IPC 0.751) | 1.332 | 0.751 | 37.81 | 51.86 | 33.33 | 0.90 |
| `intspeed` | `602.gcc_s` | compare=pass, simpoint=done, intervals=1, clusters=1 | medium | `spec_gcc_compile_kernel` (1.000, IPC 1.410) | 0.709 | 1.410 | 32.43 | 38.40 | 18.68 | 0.21 |
| `intspeed` | `605.mcf_s` | compare=pass, simpoint=done, intervals=231, clusters=4 | medium | `spec_mcf_sort_kernel` (0.650, IPC 0.759)<br>`spec_mcf_kernel` (0.350, IPC 0.639) | 1.404 | 0.712 | 22.50 | 49.38 | 32.92 | 0.13 |
| `intspeed` | `620.omnetpp_s` | compare=pass, simpoint=done, intervals=117, clusters=5 | medium | `spec_omnetpp_event_kernel` (1.000, IPC 1.423) | 0.703 | 1.422 | 7.63 | 20.59 | 10.49 | 0.06 |
| `intspeed` | `623.xalancbmk_s` | compare=pass, simpoint=done, intervals=4, clusters=1 | medium | `spec_xalancbmk_xml_kernel` (1.000, IPC 1.296) | 0.772 | 1.295 | 63.26 | 55.82 | 5.88 | 0.00 |
| `intspeed` | `625.x264_s` | compare=pass, simpoint=done, intervals=4758, clusters=5 | high | `spec_x264_pixel_kernel` (1.000, IPC 1.833) | 0.546 | 1.832 | 26.46 | 32.79 | 8.68 | 0.00 |
| `intspeed` | `631.deepsjeng_s` | compare=pass, simpoint=done, intervals=411, clusters=2 | high | `spec_deepsjeng_search_kernel` (1.000, IPC 0.923) | 1.083 | 0.923 | 16.97 | 35.98 | 23.80 | 0.25 |
| `intspeed` | `641.leela_s` | compare=pass, simpoint=done, intervals=240, clusters=3 | high | `spec_leela_playout_kernel` (1.000, IPC 1.053) | 0.949 | 1.054 | 22.77 | 45.20 | 12.07 | 0.00 |
| `intspeed` | `648.exchange2_s` | compare=pass, simpoint=done, intervals=979, clusters=5 | high | `spec_exchange2_search_kernel` (1.000, IPC 1.617) | 0.618 | 1.618 | 20.90 | 30.07 | 12.83 | 0.19 |
| `intspeed` | `657.xz_s` | compare=pass, simpoint=done, intervals=392, clusters=5 | high | `spec_xz_lzma_kernel` (1.000, IPC 1.712) | 0.584 | 1.712 | 10.48 | 24.85 | 14.38 | 0.00 |
| `fpspeed` | `603.bwaves_s` | compare=pass, simpoint=done, intervals=258, clusters=5 | medium | `spec_bwaves_stencil_kernel` (1.000, IPC 1.702) | 0.588 | 1.701 | 22.96 | 30.99 | 4.20 | 0.01 |
| `fpspeed` | `607.cactuBSSN_s` | compare=pass, simpoint=done, intervals=283, clusters=5 | high | `spec_cactubssn_stencil_kernel` (1.000, IPC 1.494) | 0.669 | 1.495 | 53.73 | 46.77 | 8.41 | 0.24 |
| `fpspeed` | `619.lbm_s` | compare=pass, simpoint=done, intervals=412, clusters=5 | high | `spec_lbm_stream_kernel` (1.000, IPC 1.717) | 0.582 | 1.718 | 41.19 | 40.95 | 3.95 | 0.11 |
| `fpspeed` | `621.wrf_s` | compare=pass, simpoint=done, intervals=743, clusters=5 | medium | `spec_wrf_stencil_kernel` (1.000, IPC 1.475) | 0.678 | 1.475 | 38.76 | 42.60 | 15.81 | 0.00 |
| `fpspeed` | `627.cam4_s` | compare=pass, simpoint=done, intervals=3866, clusters=5 | medium | `spec_cam4_climate_kernel` (1.000, IPC 1.618) | 0.618 | 1.618 | 44.70 | 37.32 | 4.56 | 0.00 |
| `fpspeed` | `628.pop2_s` | compare=pass, simpoint=done, intervals=113, clusters=5 | low | `spec_roms_stencil_kernel` (1.000, IPC 1.475) | 0.678 | 1.475 | 38.76 | 42.60 | 15.81 | 0.00 |
| `fpspeed` | `638.imagick_s` | compare=pass, simpoint=done, intervals=1, clusters=1 | medium | `spec_imagick_filter_kernel` (1.000, IPC 1.238) | 0.808 | 1.238 | 45.41 | 45.91 | 26.88 | 0.00 |
| `fpspeed` | `644.nab_s` | compare=pass, simpoint=done, intervals=60, clusters=3 | high | `spec_nab_md_kernel` (1.000, IPC 0.813) | 1.230 | 0.813 | 73.57 | 71.96 | 5.80 | 0.00 |
| `fpspeed` | `649.fotonik3d_s` | compare=pass, simpoint=done, intervals=386, clusters=4 | low | `spec_fotonik3d_stencil_kernel` (1.000, IPC 1.475) | 0.678 | 1.475 | 38.76 | 42.60 | 15.81 | 0.00 |
| `fpspeed` | `654.roms_s` | compare=pass, simpoint=done, intervals=290, clusters=5 | high | `spec_roms_stencil_kernel` (1.000, IPC 1.475) | 0.678 | 1.475 | 38.76 | 42.60 | 15.81 | 0.00 |

## Interpretation Rules

- `geomean IPC` is only a repository-local summary across representative kernels; it is not a SPEC ratio.
- For one-kernel mappings, weighted CPI equals that kernel's RTL Kernel CPI.
- For split mappings, CPI is combined by normalized component weights.
- Coverage `low/medium/high` describes how directly the bare-metal kernel matches the SPEC function profile.
- Exact SimPoint RTL requires checkpoint/restore, warmup, detailed interval execution, and weighted aggregation over real SPEC state.
