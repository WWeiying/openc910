# SPEC CPU2017 Speed Train 指导的 RTL 加权汇总

> 历史 L2 v2 输出。大多数行只使用一个合成代理 kernel，不是多 SimPoint
> 加权的真实 SPEC RTL 性能。完成 cluster 机制分组和 ref 校准后，使用 v3
> `*_RTL_PROXY_SUMMARY` 报告。

本报告不是官方 SPEC CPU2017 分数，也不是精确的 SimPoint checkpoint RTL 结果。
它将 SPECspeed train 的 QEMU SimPoint/函数画像与 bare-metal RTL representative kernel 结果组合，用于仓库内的体系结构研究。

## 输入

- SPEC 输入规模：`train`
- SPEC 结果根目录：`spec_runs`
- RTL 结果：`smart_run/results/archive/specspeed_train_l2_1f451a653e1c_dirty`
- Kernel 映射：`spec_flow/spec2017_speed_kernel_map.json`

## 套件汇总

| 套件 | benchmark 数 | IPC 几何平均 | IPC 算术平均 | CPI 算术平均 |
|---|---:|---:|---:|---:|
| `fpspeed` | 10 | 1.454 | 1.479 | 0.703 |
| `intspeed` | 10 | 1.215 | 1.276 | 0.869 |
| `all` | 20 | 1.329 | 1.377 | 0.786 |

## Benchmark 明细

| 套件 | benchmark | manifest | 覆盖度 | 权重来源 | RTL kernel | 加权 Kernel CPI | 加权 Kernel IPC | 前端停顿 % | 后端停顿 % | 条件分支误预测 % | L1D Load Miss % |
|---|---|---|---|---|---|---:|---:|---:|---:|---:|---:|
| `intspeed` | `600.perlbench_s` | compare=pass, simpoint=done, intervals=1457, clusters=4 | 中 | 单 kernel 映射 | `spec_perlbench_regex_kernel` (1.000, IPC 0.743) | 1.345 | 0.743 | 38.32 | 52.47 | 34.73 | 0.91 |
| `intspeed` | `602.gcc_s` | compare=pass, simpoint=done, intervals=1937, clusters=5 | 中 | 单 kernel 映射 | `spec_gcc_compile_kernel` (1.000, IPC 1.404) | 0.712 | 1.404 | 32.30 | 38.30 | 19.86 | 0.24 |
| `intspeed` | `605.mcf_s` | compare=pass, simpoint=done, intervals=1168, clusters=5 | 中 | SimPoint 函数混合（匹配 99.85%） | `spec_mcf_sort_kernel` (0.659, IPC 0.759)<br>`spec_mcf_kernel` (0.341, IPC 0.612) | 1.425 | 0.702 | 22.09 | 49.17 | 33.77 | 0.17 |
| `intspeed` | `620.omnetpp_s` | compare=pass, simpoint=done, intervals=1260, clusters=3 | 中 | 单 kernel 映射 | `spec_omnetpp_event_kernel` (1.000, IPC 1.471) | 0.680 | 1.471 | 7.61 | 19.24 | 10.11 | 0.09 |
| `intspeed` | `623.xalancbmk_s` | compare=pass, simpoint=done, intervals=2501, clusters=4 | 中 | 单 kernel 映射 | `spec_xalancbmk_xml_kernel` (1.000, IPC 1.308) | 0.765 | 1.307 | 63.54 | 55.57 | 5.88 | 0.00 |
| `intspeed` | `625.x264_s` | compare=pass, simpoint=done, intervals=3884, clusters=5 | 高 | 单 kernel 映射 | `spec_x264_pixel_kernel` (1.000, IPC 1.772) | 0.564 | 1.773 | 25.78 | 31.94 | 11.18 | 0.00 |
| `intspeed` | `631.deepsjeng_s` | compare=pass, simpoint=done, intervals=3658, clusters=2 | 高 | 单 kernel 映射 | `spec_deepsjeng_search_kernel` (1.000, IPC 0.926) | 1.080 | 0.926 | 15.47 | 36.13 | 23.58 | 0.19 |
| `intspeed` | `641.leela_s` | compare=pass, simpoint=done, intervals=3884, clusters=5 | 高 | 单 kernel 映射 | `spec_leela_playout_kernel` (1.000, IPC 1.070) | 0.934 | 1.071 | 21.62 | 44.27 | 11.86 | 0.00 |
| `intspeed` | `648.exchange2_s` | compare=pass, simpoint=done, intervals=2905, clusters=4 | 高 | 单 kernel 映射 | `spec_exchange2_search_kernel` (1.000, IPC 1.645) | 0.608 | 1.645 | 22.01 | 29.93 | 11.73 | 0.19 |
| `intspeed` | `657.xz_s` | compare=pass, simpoint=done, intervals=1246, clusters=5 | 高 | 单 kernel 映射 | `spec_xz_lzma_kernel` (1.000, IPC 1.717) | 0.582 | 1.718 | 10.90 | 25.03 | 14.24 | 0.00 |
| `fpspeed` | `603.bwaves_s` | compare=pass, simpoint=done, intervals=1354, clusters=5 | 高 | 单 kernel 映射 | `spec_bwaves_stencil_kernel` (1.000, IPC 1.712) | 0.584 | 1.712 | 22.68 | 30.60 | 4.28 | 0.01 |
| `fpspeed` | `607.cactuBSSN_s` | compare=pass, simpoint=done, intervals=2216, clusters=5 | 高 | 单 kernel 映射 | `spec_cactubssn_stencil_kernel` (1.000, IPC 1.503) | 0.665 | 1.504 | 53.36 | 46.54 | 7.98 | 0.24 |
| `fpspeed` | `619.lbm_s` | compare=pass, simpoint=done, intervals=5831, clusters=3 | 高 | 单 kernel 映射 | `spec_lbm_stream_kernel` (1.000, IPC 1.619) | 0.618 | 1.618 | 43.37 | 42.91 | 6.94 | 0.10 |
| `fpspeed` | `621.wrf_s` | compare=pass, simpoint=done, intervals=4564, clusters=5 | 中 | 单 kernel 映射 | `spec_wrf_stencil_kernel` (1.000, IPC 1.489) | 0.672 | 1.488 | 35.08 | 41.52 | 14.52 | 0.00 |
| `fpspeed` | `627.cam4_s` | compare=pass, simpoint=done, intervals=6678, clusters=5 | 中 | 单 kernel 映射 | `spec_cam4_climate_kernel` (1.000, IPC 1.634) | 0.612 | 1.634 | 43.83 | 36.54 | 4.80 | 0.00 |
| `fpspeed` | `628.pop2_s` | compare=pass, simpoint=done, intervals=5670, clusters=3 | 中 | 单 kernel 映射 | `spec_pop2_ocean_kernel` (1.000, IPC 1.631) | 0.613 | 1.631 | 37.09 | 39.82 | 5.97 | 0.02 |
| `fpspeed` | `638.imagick_s` | compare=pass, simpoint=done, intervals=2470, clusters=4 | 高 | 单 kernel 映射 | `spec_imagick_filter_kernel` (1.000, IPC 1.401) | 0.714 | 1.401 | 42.64 | 42.69 | 15.05 | 0.00 |
| `fpspeed` | `644.nab_s` | compare=pass, simpoint=done, intervals=3619, clusters=5 | 高 | 单 kernel 映射 | `spec_nab_md_kernel` (1.000, IPC 0.824) | 1.213 | 0.824 | 73.27 | 71.67 | 5.36 | 0.00 |
| `fpspeed` | `649.fotonik3d_s` | compare=pass, simpoint=done, intervals=1777, clusters=5 | 中 | 单 kernel 映射 | `spec_fotonik3d_stencil_kernel` (1.000, IPC 1.489) | 0.672 | 1.488 | 35.08 | 41.52 | 14.52 | 0.00 |
| `fpspeed` | `654.roms_s` | compare=pass, simpoint=done, intervals=10572, clusters=5 | 中 | 单 kernel 映射 | `spec_roms_stencil_kernel` (1.000, IPC 1.489) | 0.672 | 1.488 | 35.08 | 41.52 | 14.52 | 0.00 |

## 解释规则

- IPC 几何平均只是仓库内 representative kernel 的汇总指标，不是 SPEC ratio 或可发布的 SPEC 分数。
- 单 kernel 映射的加权 CPI 等于该 kernel 的 RTL Kernel CPI；多 kernel 映射先按组件权重组合 CPI，再取倒数得到 IPC。
- `SimPoint 函数混合`权重由代表区间内函数占比乘以对应 cluster 权重得到；表中的匹配率表示声明的函数组覆盖了多少加权画像。
- 覆盖度 `low/medium/high` 表示 bare-metal kernel 与 SPEC train 函数画像及主要机制的贴合程度。
- 前端停顿和后端停顿来自可重叠的 RTL 事件，不应相加解释为总停顿比例。
- 精确 SimPoint RTL 仍需要真实 SPEC 状态的 checkpoint/restore、warmup、详细区间执行和按权重汇总，这属于 L3。
