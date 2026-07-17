# SPECspeed Train L2 闭环验收

本表核验 20 项 train manifest、SimPoint 权重、映射 kernel 源码以及正式 RTL 结果。

| benchmark | manifest | clusters | weight sum | mapped RTL case(s) |
|---|---|---:|---:|---|
| `600.perlbench_s` | ok | 4 | 1.0000002 | spec_perlbench_regex_kernel:pass |
| `602.gcc_s` | ok | 5 | 1.0000002 | spec_gcc_compile_kernel:pass |
| `605.mcf_s` | ok | 5 | 0.9999996 | spec_mcf_sort_kernel:pass, spec_mcf_kernel:pass |
| `620.omnetpp_s` | ok | 3 | 0.9999996 | spec_omnetpp_event_kernel:pass |
| `623.xalancbmk_s` | ok | 4 | 1.0000003 | spec_xalancbmk_xml_kernel:pass |
| `625.x264_s` | ok | 5 | 1.0000005 | spec_x264_pixel_kernel:pass |
| `631.deepsjeng_s` | ok | 2 | 1.0000001 | spec_deepsjeng_search_kernel:pass |
| `641.leela_s` | ok | 5 | 1.0000007 | spec_leela_playout_kernel:pass |
| `648.exchange2_s` | ok | 4 | 0.9999995 | spec_exchange2_search_kernel:pass |
| `657.xz_s` | ok | 5 | 1.0000009 | spec_xz_lzma_kernel:pass |
| `603.bwaves_s` | ok | 5 | 0.9999995 | spec_bwaves_stencil_kernel:pass |
| `607.cactuBSSN_s` | ok | 5 | 1.0000001 | spec_cactubssn_stencil_kernel:pass |
| `619.lbm_s` | ok | 3 | 0.9999993 | spec_lbm_stream_kernel:pass |
| `621.wrf_s` | ok | 5 | 1.0000010 | spec_wrf_stencil_kernel:pass |
| `627.cam4_s` | ok | 5 | 1.0000005 | spec_cam4_climate_kernel:pass |
| `628.pop2_s` | ok | 3 | 0.9999994 | spec_pop2_ocean_kernel:pass |
| `638.imagick_s` | ok | 4 | 1.0000005 | spec_imagick_filter_kernel:pass |
| `644.nab_s` | ok | 5 | 0.9999996 | spec_nab_md_kernel:pass |
| `649.fotonik3d_s` | ok | 5 | 1.0000000 | spec_fotonik3d_stencil_kernel:pass |
| `654.roms_s` | ok | 5 | 0.9999991 | spec_roms_stencil_kernel:pass |

验收结果：benchmark=20，映射 RTL case=21，错误=0。
