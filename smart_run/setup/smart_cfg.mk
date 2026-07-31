#/*Copyright 2019-2021 T-Head Semiconductor Co., Ltd.
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.
#*/
CPU_ARCH_FLAG_0 := c910
SPEC_SPEED_INDEPENDENT_CASES := \
      spec_600_perlbench_speed_kernel \
      spec_602_gcc_speed_kernel \
      spec_603_bwaves_speed_kernel \
      spec_607_cactubssn_speed_kernel \
      spec_619_lbm_speed_kernel \
      spec_620_omnetpp_speed_kernel \
      spec_621_wrf_speed_kernel \
      spec_623_xalancbmk_speed_kernel \
      spec_625_x264_speed_kernel \
      spec_627_cam4_speed_kernel \
      spec_631_deepsjeng_speed_kernel \
      spec_638_imagick_speed_kernel \
      spec_641_leela_speed_kernel \
      spec_644_nab_speed_kernel \
      spec_648_exchange2_speed_kernel \
      spec_649_fotonik3d_speed_kernel \
      spec_654_roms_speed_kernel \
      spec_657_xz_speed_kernel
CASE_LIST := \
      ISA_AMO \
      smoke_bus \
      debug_gpr \
      ISA_THEAD \
      cache_op \
      debug_memory \
      ISA_FP \
      ISA_IMAC \
      coremark \
      dhrystone \
      hello_world \
      MMU \
      csr \
      ISA_BARRIER \
      plic_int \
      sleep \
      rvv \
      bench_branch \
      bench_mem \
      bench_ilp \
      bench_frontend \
      bench_fp \
      bench_br_bimodal \
      bench_br_ras \
      bench_br_indirect \
      bench_br_corr \
      bench_cache_stride \
      spec_perlbench_regex_kernel \
      spec_gcc_compile_kernel \
      spec_505_mcf_composite_kernel \
      spec_605_mcf_composite_kernel \
      spec_omnetpp_event_kernel \
      spec_xalancbmk_xml_kernel \
      spec_xz_lzma_kernel \
      spec_x264_pixel_kernel \
      spec_deepsjeng_search_kernel \
      spec_leela_playout_kernel \
      spec_exchange2_search_kernel \
      spec_bwaves_stencil_kernel \
      spec_cactubssn_stencil_kernel \
      spec_namd_pair_kernel \
      spec_lbm_stream_kernel \
      spec_wrf_stencil_kernel \
      spec_510_parest_composite_kernel \
      spec_povray_ray_kernel \
      spec_blender_render_kernel \
      spec_cam4_climate_kernel \
      spec_imagick_filter_kernel \
      spec_nab_md_kernel \
      spec_fotonik3d_stencil_kernel \
      spec_roms_stencil_kernel \
      spec_pop2_ocean_kernel \
      ${SPEC_SPEED_INDEPENDENT_CASES}

$(addsuffix _build,${SPEC_SPEED_INDEPENDENT_CASES}):
	@case_name="$(@:_build=)"; \
	cp -f ./tests/cases/$$case_name/* ./work; \
	find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;; \
	cp -f ./tests/lib/clib/* ./work; \
	cp -f ./tests/lib/newlib_wrap/* ./work; \
	cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 \
	  COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=$$case_name \
	  FILE=${CASE} >& $${case_name}_build.case.log

ISA_AMO_build:
	@cp -f ./tests/cases/ISA/ISA_AMO/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \; 
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=ISA_AMO FILE=${CASE} >& ISA_AMO_build.case.log 


smoke_bus_build:
	@cp -f ./tests/cases/smoke/bus_smoke/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \; 
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=smoke_bus FILE=${CASE} >& smoke_bus_build.case.log 


debug_gpr_build:
	@cp -f ./tests/cases/debug/debug_gpr/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \; 
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=debug_gpr FILE=${CASE} >& debug_gpr_build.case.log 


ISA_THEAD_build:
	@cp -f ./tests/cases/ISA/ISA_THEAD/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \; 
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=ISA_THEAD FILE=${CASE} >& ISA_THEAD_build.case.log 


cache_op_build:
	@cp -f ./tests/cases/cache/idcache_oper/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \; 
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=cache_op FILE=${CASE} >& cache_op_build.case.log 


debug_memory_build:
	@cp -f ./tests/cases/debug/debug_memory/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \; 
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=debug_memory FILE=${CASE} >& debug_memory_build.case.log 


ISA_FP_build:
	@cp -f ./tests/cases/ISA/ISA_FP/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \; 
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=ISA_FP FILE=${CASE} >& ISA_FP_build.case.log 


ISA_IMAC_build:
	@cp -f ./tests/cases/ISA/ISA_IMAC/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \; 
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=ISA_IMAC FILE=${CASE} >& ISA_IMAC_build.case.log 


coremark_build:
	@cp -f ./tests/cases/coremark/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \; 
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=coremark FILE=${CASE} COREMARK_ITERATIONS=${COREMARK_ITERATIONS} >& coremark_build.case.log


dhrystone_build:
	@cp -f ./tests/cases/dhrystone/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \; 
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=dhrystone FILE=${CASE} >& dhrystone_build.case.log 


hello_world_build:
	@cp -f ./tests/cases/hello_world/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \; 
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=hello_world FILE=${CASE} >& hello_world_build.case.log 


rvv_build:
	@cp -f ./tests/cases/rvv/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \; 
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=rvv FILE=${CASE} >& rvv.case.log 


MMU_build:
	@cp -f ./tests/cases/MMU/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \; 
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=MMU FILE=${CASE} >& MMU_build.case.log 


ISA_VECTOR_build:
	@cp -f ./tests/cases/ISA/ISA_VECTOR/VECTOR_SMOKE/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \; 
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=ISA_VECTOR FILE=${CASE} >& ISA_VECTOR_build.case.log 


csr_build:
	@cp -f ./tests/cases/csr/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \; 
	echo $(GCC_PATH)
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=csr FILE=${CASE} >& csr_build.case.log 


ISA_BARRIER_build:
	@cp -f ./tests/cases/ISA/ISA_BARRIER/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \; 
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=ISA_BARRIER FILE=${CASE} >& ISA_BARRIER_build.case.log 


plic_int_build:
	@cp -f ./tests/cases/interrupt/int_smoke/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \; 
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=plic_int FILE=${CASE} >& plic_int_build.case.log 


sleep_build:
	@cp -f ./tests/cases/sleep/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \; 
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=sleep FILE=${CASE} >& sleep_build.case.log 


bench_br_bimodal_build:
	@cp -f ./tests/cases/bench_br_bimodal/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=bench_br_bimodal FILE=${CASE} >& bench_br_bimodal_build.case.log


bench_br_ras_build:
	@cp -f ./tests/cases/bench_br_ras/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=bench_br_ras FILE=${CASE} >& bench_br_ras_build.case.log


bench_br_indirect_build:
	@cp -f ./tests/cases/bench_br_indirect/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=bench_br_indirect FILE=${CASE} >& bench_br_indirect_build.case.log


bench_br_corr_build:
	@cp -f ./tests/cases/bench_br_corr/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=bench_br_corr FILE=${CASE} >& bench_br_corr_build.case.log


bench_cache_cap_build:
	@cp -f ./tests/cases/bench_cache_cap/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=bench_cache_cap FILE=${CASE} >& bench_cache_cap_build.case.log


bench_cache_stride_build:
	@cp -f ./tests/cases/bench_cache_stride/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=bench_cache_stride FILE=${CASE} >& bench_cache_stride_build.case.log


bench_branch_build:
	@cp -f ./tests/cases/bench_branch/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=bench_branch FILE=${CASE} >& bench_branch_build.case.log


bench_mem_build:
	@cp -f ./tests/cases/bench_mem/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=bench_mem FILE=${CASE} >& bench_mem_build.case.log

spec_perlbench_regex_kernel_build:
	@cp -f ./tests/cases/spec_perlbench_regex_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_perlbench_regex_kernel FILE=${CASE} >& spec_perlbench_regex_kernel_build.case.log

spec_gcc_compile_kernel_build:
	@cp -f ./tests/cases/spec_gcc_compile_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_gcc_compile_kernel FILE=${CASE} >& spec_gcc_compile_kernel_build.case.log

spec_mcf_kernel_build:
	@cp -f ./tests/cases/spec_mcf_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_mcf_kernel FILE=${CASE} >& spec_mcf_kernel_build.case.log

spec_mcf_sort_kernel_build:
	@cp -f ./tests/cases/spec_mcf_sort_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_mcf_sort_kernel FILE=${CASE} >& spec_mcf_sort_kernel_build.case.log

spec_505_mcf_composite_kernel_build:
	@cp -f ./tests/cases/spec_505_mcf_composite_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_505_mcf_composite_kernel FILE=${CASE} >& spec_505_mcf_composite_kernel_build.case.log

spec_605_mcf_composite_kernel_build:
	@cp -f ./tests/cases/spec_605_mcf_composite_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_605_mcf_composite_kernel FILE=${CASE} >& spec_605_mcf_composite_kernel_build.case.log

spec_omnetpp_event_kernel_build:
	@cp -f ./tests/cases/spec_omnetpp_event_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_omnetpp_event_kernel FILE=${CASE} >& spec_omnetpp_event_kernel_build.case.log

spec_xalancbmk_xml_kernel_build:
	@cp -f ./tests/cases/spec_xalancbmk_xml_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_xalancbmk_xml_kernel FILE=${CASE} >& spec_xalancbmk_xml_kernel_build.case.log

spec_xz_lzma_kernel_build:
	@cp -f ./tests/cases/spec_xz_lzma_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_xz_lzma_kernel FILE=${CASE} >& spec_xz_lzma_kernel_build.case.log

spec_x264_pixel_kernel_build:
	@cp -f ./tests/cases/spec_x264_pixel_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_x264_pixel_kernel FILE=${CASE} >& spec_x264_pixel_kernel_build.case.log

spec_deepsjeng_search_kernel_build:
	@cp -f ./tests/cases/spec_deepsjeng_search_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_deepsjeng_search_kernel FILE=${CASE} >& spec_deepsjeng_search_kernel_build.case.log

spec_leela_playout_kernel_build:
	@cp -f ./tests/cases/spec_leela_playout_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_leela_playout_kernel FILE=${CASE} >& spec_leela_playout_kernel_build.case.log

spec_exchange2_search_kernel_build:
	@cp -f ./tests/cases/spec_exchange2_search_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_exchange2_search_kernel FILE=${CASE} >& spec_exchange2_search_kernel_build.case.log

spec_bwaves_stencil_kernel_build:
	@cp -f ./tests/cases/spec_bwaves_stencil_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_bwaves_stencil_kernel FILE=${CASE} >& spec_bwaves_stencil_kernel_build.case.log

spec_cactubssn_stencil_kernel_build:
	@cp -f ./tests/cases/spec_cactubssn_stencil_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_cactubssn_stencil_kernel FILE=${CASE} >& spec_cactubssn_stencil_kernel_build.case.log

spec_lbm_stream_kernel_build:
	@cp -f ./tests/cases/spec_lbm_stream_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_lbm_stream_kernel FILE=${CASE} >& spec_lbm_stream_kernel_build.case.log

spec_namd_pair_kernel_build:
	@cp -f ./tests/cases/spec_namd_pair_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_namd_pair_kernel FILE=${CASE} >& spec_namd_pair_kernel_build.case.log

spec_wrf_stencil_kernel_build:
	@cp -f ./tests/cases/spec_wrf_stencil_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_wrf_stencil_kernel FILE=${CASE} >& spec_wrf_stencil_kernel_build.case.log

spec_parest_sparse_kernel_build:
	@cp -f ./tests/cases/spec_parest_sparse_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_parest_sparse_kernel FILE=${CASE} >& spec_parest_sparse_kernel_build.case.log

spec_parest_dof_kernel_build:
	@cp -f ./tests/cases/spec_parest_dof_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_parest_dof_kernel FILE=${CASE} >& spec_parest_dof_kernel_build.case.log

spec_510_parest_composite_kernel_build:
	@cp -f ./tests/cases/spec_510_parest_composite_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_510_parest_composite_kernel FILE=${CASE} >& spec_510_parest_composite_kernel_build.case.log

spec_povray_ray_kernel_build:
	@cp -f ./tests/cases/spec_povray_ray_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_povray_ray_kernel FILE=${CASE} >& spec_povray_ray_kernel_build.case.log

spec_blender_render_kernel_build:
	@cp -f ./tests/cases/spec_blender_render_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_blender_render_kernel FILE=${CASE} >& spec_blender_render_kernel_build.case.log

spec_cam4_climate_kernel_build:
	@cp -f ./tests/cases/spec_cam4_climate_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_cam4_climate_kernel FILE=${CASE} >& spec_cam4_climate_kernel_build.case.log

spec_imagick_filter_kernel_build:
	@cp -f ./tests/cases/spec_imagick_filter_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_imagick_filter_kernel FILE=${CASE} >& spec_imagick_filter_kernel_build.case.log

spec_nab_md_kernel_build:
	@cp -f ./tests/cases/spec_nab_md_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_nab_md_kernel FILE=${CASE} >& spec_nab_md_kernel_build.case.log

spec_fotonik3d_stencil_kernel_build:
	@cp -f ./tests/cases/spec_fotonik3d_stencil_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_fotonik3d_stencil_kernel FILE=${CASE} >& spec_fotonik3d_stencil_kernel_build.case.log

spec_roms_stencil_kernel_build:
	@cp -f ./tests/cases/spec_roms_stencil_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_roms_stencil_kernel FILE=${CASE} >& spec_roms_stencil_kernel_build.case.log

spec_pop2_ocean_kernel_build:
	@cp -f ./tests/cases/spec_pop2_ocean_kernel/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=spec_pop2_ocean_kernel FILE=${CASE} >& spec_pop2_ocean_kernel_build.case.log


bench_ilp_build:
	@cp -f ./tests/cases/bench_ilp/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=bench_ilp FILE=${CASE} >& bench_ilp_build.case.log


bench_frontend_build:
	@cp -f ./tests/cases/bench_frontend/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=bench_frontend FILE=${CASE} >& bench_frontend_build.case.log


bench_fp_build:
	@cp -f ./tests/cases/bench_fp/* ./work
	@find ./tests/lib/ -maxdepth 1 -type f -exec cp {} ./work/ \;
	@cp -f ./tests/lib/clib/* ./work
	@cp -f ./tests/lib/newlib_wrap/* ./work
	@cd ./work && make -s clean && make -s all CPU_ARCH_FLAG_0=c910 COMPILER=${COMPILER} ENDIAN_MODE=little-endian CASENAME=bench_fp FILE=${CASE} >& bench_fp_build.case.log


# Adjust verilog filelist for *.v case...
ifeq ($(CASE), debug_gpr)
SIM_FILELIST := ../tests/cases/debug/debug_gpr/had_drv.vh ../tests/cases/debug/debug_gpr/debug_read_write_gpr.v
endif
ifeq ($(CASE), debug_memory)
SIM_FILELIST := ../tests/cases/debug/debug_memory/had_drv.vh ../tests/cases/debug/debug_memory/debug_read_write_memory.v
endif
ifeq ($(CASE), plic_int)
SIM_FILELIST := ../tests/cases/interrupt/int_smoke/ct_plic_int_smoke_hw.v
endif
ifeq ($(CASE), sleep)
SIM_FILELIST := ../tests/cases/sleep/sleep_test.vh
endif


define newline


endef
