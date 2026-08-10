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
ifeq (${COMPILER}, gcc)
  CC      = ${GCC_PATH}/riscv64-unknown-elf-gcc
  AS      = ${GCC_PATH}/riscv64-unknown-elf-as
  LINK    = ${GCC_PATH}/riscv64-unknown-elf-ld
  OBJDUMP = ${GCC_PATH}/riscv64-unknown-elf-objdump
  OBJCOPY = ${GCC_PATH}/riscv64-unknown-elf-objcopy
  LLVM_OPTION ?= 
else
  CC      = ${LLVM_PATH}/clang
  AS      = ${LLVM_PATH}/llvm-as
  LINK    = ${LLVM_PATH}/lld
  OBJDUMP = ${LLVM_PATH}/llvm-objdump
  OBJCOPY = ${GCC_PATH}/riscv64-unknown-elf-objcopy
  LLVM_OPTION ?= --target=riscv64-unknown-elf
endif

CONVERT	=../tests/bin/Srec2vmem

INCLUDE = -I${GCC_PATH}/riscv64-unknown-elf/include

SSRC = $(wildcard *.S)
sSRC = $(wildcard *.s)
CSRC = $(wildcard *.c)

OBJECTS = $(SSRC:%.S=%.o) $(sSRC:%.s=%.o) $(CSRC:%.c=%.o)

FLAG_MARCH = -mtune=c910
#CPU_ARCH_FLAG_0 => CPU Arch: c910
ifeq (${CPU_ARCH_FLAG_0}, c910)
  #FLAG_MARCH += -march=rv64imafdcv
  FLAG_MARCH += -march=rv64imafdcxtheadc
  FLAG_ABI   = -mabi=lp64d
else
  #FLAG_MARCH += -march=rv64imafdcv
  FLAG_MARCH += -march=rv64imafdcvxtheadc
  FLAG_ABI   = -mabi=lp64d
endif
CFLAGS = ${FLAG_MARCH} ${FLAG_ABI} ${LLVM_OPTION}

COREMARK_ITERATIONS ?= 30
EXTRA_CFLAGS ?=
KERNEL_CHARACTERIZATION ?= 0
SPEC_COMPOSITION_SCALE ?= 1
SPEC_SPEED_INDEPENDENT_CASES := \
  spec_600_perlbench_speed_kernel spec_602_gcc_speed_kernel \
  spec_603_bwaves_speed_kernel spec_607_cactubssn_speed_kernel \
  spec_619_lbm_speed_kernel spec_620_omnetpp_speed_kernel \
  spec_621_wrf_speed_kernel spec_623_xalancbmk_speed_kernel \
  spec_625_x264_speed_kernel spec_627_cam4_speed_kernel \
  spec_631_deepsjeng_speed_kernel spec_638_imagick_speed_kernel \
  spec_641_leela_speed_kernel spec_644_nab_speed_kernel \
  spec_648_exchange2_speed_kernel spec_649_fotonik3d_speed_kernel \
  spec_654_roms_speed_kernel spec_657_xz_speed_kernel
ifeq (${SPEC_COMPOSITE_PROFILE}, full)
ifneq ($(filter ${CASENAME},spec_644_nab_speed_kernel),)
SPEC_COMPOSITION_SCALE := 1
else ifneq ($(filter ${CASENAME},spec_607_cactubssn_speed_kernel spec_620_omnetpp_speed_kernel spec_627_cam4_speed_kernel),)
SPEC_COMPOSITION_SCALE := 2
else ifneq ($(filter ${CASENAME},spec_600_perlbench_speed_kernel spec_619_lbm_speed_kernel spec_621_wrf_speed_kernel spec_649_fotonik3d_speed_kernel spec_657_xz_speed_kernel),)
SPEC_COMPOSITION_SCALE := 3
else ifneq ($(filter ${CASENAME},spec_654_roms_speed_kernel),)
SPEC_COMPOSITION_SCALE := 4
else ifneq ($(filter ${CASENAME},spec_623_xalancbmk_speed_kernel),)
SPEC_COMPOSITION_SCALE := 7
else ifneq ($(filter ${CASENAME},spec_638_imagick_speed_kernel),)
SPEC_COMPOSITION_SCALE := 5
else ifneq ($(filter ${CASENAME},spec_603_bwaves_speed_kernel),)
SPEC_COMPOSITION_SCALE := 8
else ifneq ($(filter ${CASENAME},spec_602_gcc_speed_kernel spec_625_x264_speed_kernel),)
SPEC_COMPOSITION_SCALE := 9
else ifneq ($(filter ${CASENAME},spec_641_leela_speed_kernel),)
SPEC_COMPOSITION_SCALE := 10
else ifneq ($(filter ${CASENAME},spec_648_exchange2_speed_kernel),)
SPEC_COMPOSITION_SCALE := 17
else ifneq ($(filter ${CASENAME},spec_631_deepsjeng_speed_kernel),)
SPEC_COMPOSITION_SCALE := 24
endif
endif
CFLAGS += -DSPEC_COMPOSITION_SCALE=${SPEC_COMPOSITION_SCALE}

ifeq (${CASENAME}, coremark)
  #CFLAGS += -c -O3 -mtune=c910 -static -funroll-all-loops -finline-limit=500 -fgcse-sm -fno-schedule-insns --param max-rtl-if-conversion-unpredictable-cost=100 -DITERATIONS=10000
  CFLAGS += -c -O3 -mtune=c910 -static -funroll-all-loops -finline-limit=500 -fgcse-sm -fno-schedule-insns --param max-rtl-if-conversion-unpredictable-cost=100 -msignedness-cmpiv -fno-code-hoisting -mno-thread-jumps1 -mno-iv-adjust-addr-cost -mno-expand-split-imm -DITERATIONS=${COREMARK_ITERATIONS}
  # CFLAGS += -c -v -funroll-all-loops -finline-limit=500 -fgcse-sm -fno-schedule-insns --param max-rtl-if-conversion-unpredictable-cost=100 -fno-code-hoisting -mno-thread-jumps1 -mno-iv-adjust-addr-cost -DITERATIONS=10000 -O3 -static -mbit-translate
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O3 -mtune=c910 -static -funroll-all-loops -finline-limit=500 -fgcse-sm -fno-schedule-insns --param max-rtl-if-conversion-unpredictable-cost=100 -msignedness-cmpiv -fno-code-hoisting -mno-thread-jumps1 -mno-iv-adjust-addr-cost -mno-expand-split-imm -DITERATIONS=${COREMARK_ITERATIONS}
else ifeq (${CASENAME}, dhrystone)
  # Performance-oriented Dhrystone build: allows normal -O3 inlining.
  # Use the archived dhrystone_std_1000 result for strict no-inline ground rules.
  CFLAGS += -c -O3 -std=gnu99 -Wno-implicit-int -Wno-implicit-function-declaration -DSMART_RUN -DDHRYSTONE_RUNS=1000
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O3 -std=gnu99 -Wno-implicit-int -Wno-implicit-function-declaration -DSMART_RUN -DDHRYSTONE_RUNS=1000
else ifeq (${CASENAME}, spec_mcf_kernel)
  ifeq (${SPEC_MCF_REPRESENTATIVE}, 1)
    SPEC_MCF_NODES ?= 96
    SPEC_MCF_ARCS ?= 384
    SPEC_MCF_BASKET ?= 16
    SPEC_MCF_PASSES ?= 3
  else
    SPEC_MCF_NODES ?= 32
    SPEC_MCF_ARCS ?= 96
    SPEC_MCF_BASKET ?= 8
    SPEC_MCF_PASSES ?= 1
  endif
  CFLAGS += -c -O2 \
    -DSPEC_MCF_NODES=${SPEC_MCF_NODES} \
    -DSPEC_MCF_ARCS=${SPEC_MCF_ARCS} \
    -DSPEC_MCF_BASKET=${SPEC_MCF_BASKET} \
    -DSPEC_MCF_PASSES=${SPEC_MCF_PASSES}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_mcf_sort_kernel)
  ifeq (${SPEC_MCF_SORT_REPRESENTATIVE}, 1)
    SPEC_MCF_SORT_ITEMS ?= 256
    SPEC_MCF_SORT_PASSES ?= 3
  else
    SPEC_MCF_SORT_ITEMS ?= 96
    SPEC_MCF_SORT_PASSES ?= 1
  endif
  CFLAGS += -c -O2 \
    -DSPEC_MCF_SORT_ITEMS=${SPEC_MCF_SORT_ITEMS} \
    -DSPEC_MCF_SORT_PASSES=${SPEC_MCF_SORT_PASSES}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_505_mcf_composite_kernel)
  SPEC_COMPOSITE_PROFILE ?= quick
  ifeq (${SPEC_COMPOSITE_PROFILE}, full)
    SPEC_MCF_COMPOSITE_SORT_ITEMS ?= 1400
    SPEC_MCF_COMPOSITE_PRICE_NODES ?= 4096
    SPEC_MCF_COMPOSITE_PRICE_ARCS ?= 13250
    SPEC_MCF_COMPOSITE_PRICE_BASKET ?= 8
    SPEC_MCF_COMPOSITE_SORT_ROUNDS ?= 1
    SPEC_MCF_COMPOSITE_SORT_TAIL_ITEMS ?= 0
    SPEC_MCF_COMPOSITE_PRICE_ROUNDS ?= 1
    SPEC_MCF_COMPOSITE_WARMUP ?= 1
  else ifeq (${SPEC_COMPOSITE_PROFILE}, quick)
    SPEC_MCF_COMPOSITE_SORT_ITEMS ?= 96
    SPEC_MCF_COMPOSITE_PRICE_NODES ?= 32
    SPEC_MCF_COMPOSITE_PRICE_ARCS ?= 96
    SPEC_MCF_COMPOSITE_PRICE_BASKET ?= 8
    SPEC_MCF_COMPOSITE_SORT_ROUNDS ?= 1
    SPEC_MCF_COMPOSITE_SORT_TAIL_ITEMS ?= 8
    SPEC_MCF_COMPOSITE_PRICE_ROUNDS ?= 4
    SPEC_MCF_COMPOSITE_WARMUP ?= 0
  else
    $(error SPEC_COMPOSITE_PROFILE must be quick or full)
  endif
  CFLAGS += -c -O2 \
    -DMCF_SORT_ITEMS=${SPEC_MCF_COMPOSITE_SORT_ITEMS} \
    -DMCF_PRICE_NODES=${SPEC_MCF_COMPOSITE_PRICE_NODES} \
    -DMCF_PRICE_ARCS=${SPEC_MCF_COMPOSITE_PRICE_ARCS} \
    -DMCF_PRICE_BASKET=${SPEC_MCF_COMPOSITE_PRICE_BASKET} \
    -DSPEC_MCF_COMPOSITE_SORT_ROUNDS=${SPEC_MCF_COMPOSITE_SORT_ROUNDS} \
    -DSPEC_MCF_COMPOSITE_SORT_TAIL_ITEMS=${SPEC_MCF_COMPOSITE_SORT_TAIL_ITEMS} \
    -DSPEC_MCF_COMPOSITE_PRICE_ROUNDS=${SPEC_MCF_COMPOSITE_PRICE_ROUNDS} \
    -DSPEC_MCF_COMPOSITE_WARMUP=${SPEC_MCF_COMPOSITE_WARMUP}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_605_mcf_composite_kernel)
  SPEC_COMPOSITE_PROFILE ?= quick
  ifeq (${SPEC_COMPOSITE_PROFILE}, full)
    SPEC_MCF_COMPOSITE_SORT_ITEMS ?= 1400
    SPEC_MCF_COMPOSITE_PRICE_NODES ?= 4096
    SPEC_MCF_COMPOSITE_PRICE_ARCS ?= 10330
    SPEC_MCF_COMPOSITE_PRICE_BASKET ?= 8
    SPEC_MCF_COMPOSITE_SORT_ROUNDS ?= 1
    SPEC_MCF_COMPOSITE_SORT_TAIL_ITEMS ?= 0
    SPEC_MCF_COMPOSITE_PRICE_ROUNDS ?= 1
    SPEC_MCF_COMPOSITE_WARMUP ?= 1
  else ifeq (${SPEC_COMPOSITE_PROFILE}, quick)
    SPEC_MCF_COMPOSITE_SORT_ITEMS ?= 96
    SPEC_MCF_COMPOSITE_PRICE_NODES ?= 32
    SPEC_MCF_COMPOSITE_PRICE_ARCS ?= 96
    SPEC_MCF_COMPOSITE_PRICE_BASKET ?= 8
    SPEC_MCF_COMPOSITE_SORT_ROUNDS ?= 1
    SPEC_MCF_COMPOSITE_SORT_TAIL_ITEMS ?= 44
    SPEC_MCF_COMPOSITE_PRICE_ROUNDS ?= 3
    SPEC_MCF_COMPOSITE_WARMUP ?= 0
  else
    $(error SPEC_COMPOSITE_PROFILE must be quick or full)
  endif
  CFLAGS += -c -O2 \
    -DMCF_SORT_ITEMS=${SPEC_MCF_COMPOSITE_SORT_ITEMS} \
    -DMCF_PRICE_NODES=${SPEC_MCF_COMPOSITE_PRICE_NODES} \
    -DMCF_PRICE_ARCS=${SPEC_MCF_COMPOSITE_PRICE_ARCS} \
    -DMCF_PRICE_BASKET=${SPEC_MCF_COMPOSITE_PRICE_BASKET} \
    -DSPEC_MCF_COMPOSITE_SORT_ROUNDS=${SPEC_MCF_COMPOSITE_SORT_ROUNDS} \
    -DSPEC_MCF_COMPOSITE_SORT_TAIL_ITEMS=${SPEC_MCF_COMPOSITE_SORT_TAIL_ITEMS} \
    -DSPEC_MCF_COMPOSITE_PRICE_ROUNDS=${SPEC_MCF_COMPOSITE_PRICE_ROUNDS} \
    -DSPEC_MCF_COMPOSITE_WARMUP=${SPEC_MCF_COMPOSITE_WARMUP}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_xz_lzma_kernel)
  ifeq (${SPEC_COMPOSITE_PROFILE}, full)
    SPEC_COMPOSITION_SCALE := 3
    SPEC_XZ_BYTES ?= 512
    SPEC_XZ_DICT ?= 1024
    SPEC_XZ_PASSES ?= 1
    SPEC_XZ_PROBES ?= 12
    SPEC_XZ_RANGE_STEPS ?= 4
  else ifeq (${SPEC_XZ_REPRESENTATIVE}, 1)
    SPEC_XZ_BYTES ?= 2048
    SPEC_XZ_DICT ?= 4096
    SPEC_XZ_PASSES ?= 2
    SPEC_XZ_PROBES ?= 32
    SPEC_XZ_RANGE_STEPS ?= 8
  else
    SPEC_XZ_BYTES ?= 512
    SPEC_XZ_DICT ?= 1024
    SPEC_XZ_PASSES ?= 1
    SPEC_XZ_PROBES ?= 12
    SPEC_XZ_RANGE_STEPS ?= 4
  endif
  CFLAGS += -c -O2 \
    -DSPEC_XZ_BYTES=${SPEC_XZ_BYTES} \
    -DSPEC_XZ_DICT=${SPEC_XZ_DICT} \
    -DSPEC_XZ_PASSES=${SPEC_XZ_PASSES} \
    -DSPEC_XZ_PROBES=${SPEC_XZ_PROBES} \
    -DSPEC_XZ_RANGE_STEPS=${SPEC_XZ_RANGE_STEPS}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_x264_pixel_kernel)
  ifeq (${SPEC_COMPOSITE_PROFILE}, full)
    SPEC_COMPOSITION_SCALE := 2
    SPEC_X264_WIDTH ?= 24
    SPEC_X264_HEIGHT ?= 24
    SPEC_X264_BLOCKS ?= 1
    SPEC_X264_PASSES ?= 1
    SPEC_X264_CANDIDATES ?= 1
  else ifeq (${SPEC_X264_REPRESENTATIVE}, 1)
    SPEC_X264_WIDTH ?= 48
    SPEC_X264_HEIGHT ?= 40
    SPEC_X264_BLOCKS ?= 48
    SPEC_X264_PASSES ?= 2
    SPEC_X264_CANDIDATES ?= 8
  else
    SPEC_X264_WIDTH ?= 24
    SPEC_X264_HEIGHT ?= 24
    SPEC_X264_BLOCKS ?= 1
    SPEC_X264_PASSES ?= 1
    SPEC_X264_CANDIDATES ?= 1
  endif
  CFLAGS += -c -O2 \
    -DSPEC_X264_WIDTH=${SPEC_X264_WIDTH} \
    -DSPEC_X264_HEIGHT=${SPEC_X264_HEIGHT} \
    -DSPEC_X264_BLOCKS=${SPEC_X264_BLOCKS} \
    -DSPEC_X264_PASSES=${SPEC_X264_PASSES} \
    -DSPEC_X264_CANDIDATES=${SPEC_X264_CANDIDATES}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_deepsjeng_search_kernel)
  ifeq (${SPEC_COMPOSITE_PROFILE}, full)
    SPEC_COMPOSITION_SCALE := 1
    SPEC_DEEPSJENG_POSITIONS ?= 1
    SPEC_DEEPSJENG_DEPTH ?= 1
    SPEC_DEEPSJENG_MOVES ?= 8
    SPEC_DEEPSJENG_QMOVES ?= 0
  else ifeq (${SPEC_DEEPSJENG_REPRESENTATIVE}, 1)
    SPEC_DEEPSJENG_POSITIONS ?= 4
    SPEC_DEEPSJENG_DEPTH ?= 2
    SPEC_DEEPSJENG_MOVES ?= 16
    SPEC_DEEPSJENG_QMOVES ?= 8
  else
    SPEC_DEEPSJENG_POSITIONS ?= 1
    SPEC_DEEPSJENG_DEPTH ?= 1
    SPEC_DEEPSJENG_MOVES ?= 8
    SPEC_DEEPSJENG_QMOVES ?= 0
  endif
  CFLAGS += -c -O2 \
    -DSPEC_DEEPSJENG_POSITIONS=${SPEC_DEEPSJENG_POSITIONS} \
    -DSPEC_DEEPSJENG_DEPTH=${SPEC_DEEPSJENG_DEPTH} \
    -DSPEC_DEEPSJENG_MOVES=${SPEC_DEEPSJENG_MOVES} \
    -DSPEC_DEEPSJENG_QMOVES=${SPEC_DEEPSJENG_QMOVES}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_leela_playout_kernel)
  ifeq (${SPEC_COMPOSITE_PROFILE}, full)
    SPEC_COMPOSITION_SCALE := 4
    SPEC_LEELA_BOARD ?= 13
    SPEC_LEELA_PLAYOUTS ?= 2
    SPEC_LEELA_MOVES ?= 12
    SPEC_LEELA_CHILDREN ?= 16
  else ifeq (${SPEC_LEELA_REPRESENTATIVE}, 1)
    SPEC_LEELA_BOARD ?= 13
    SPEC_LEELA_PLAYOUTS ?= 8
    SPEC_LEELA_MOVES ?= 32
    SPEC_LEELA_CHILDREN ?= 64
  else
    SPEC_LEELA_BOARD ?= 13
    SPEC_LEELA_PLAYOUTS ?= 2
    SPEC_LEELA_MOVES ?= 12
    SPEC_LEELA_CHILDREN ?= 16
  endif
  CFLAGS += -c -O2 \
    -DSPEC_LEELA_BOARD=${SPEC_LEELA_BOARD} \
    -DSPEC_LEELA_PLAYOUTS=${SPEC_LEELA_PLAYOUTS} \
    -DSPEC_LEELA_MOVES=${SPEC_LEELA_MOVES} \
    -DSPEC_LEELA_CHILDREN=${SPEC_LEELA_CHILDREN}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_exchange2_search_kernel)
  ifeq (${SPEC_COMPOSITE_PROFILE}, full)
    SPEC_COMPOSITION_SCALE := 16
    SPEC_EXCHANGE2_POSITIONS ?= 1
    SPEC_EXCHANGE2_DEPTH ?= 2
    SPEC_EXCHANGE2_MOVES ?= 6
    SPEC_EXCHANGE2_TABLE ?= 64
  else ifeq (${SPEC_EXCHANGE2_REPRESENTATIVE}, 1)
    SPEC_EXCHANGE2_POSITIONS ?= 4
    SPEC_EXCHANGE2_DEPTH ?= 4
    SPEC_EXCHANGE2_MOVES ?= 14
    SPEC_EXCHANGE2_TABLE ?= 256
  else
    SPEC_EXCHANGE2_POSITIONS ?= 1
    SPEC_EXCHANGE2_DEPTH ?= 2
    SPEC_EXCHANGE2_MOVES ?= 6
    SPEC_EXCHANGE2_TABLE ?= 64
  endif
  CFLAGS += -c -O2 \
    -DSPEC_EXCHANGE2_POSITIONS=${SPEC_EXCHANGE2_POSITIONS} \
    -DSPEC_EXCHANGE2_DEPTH=${SPEC_EXCHANGE2_DEPTH} \
    -DSPEC_EXCHANGE2_MOVES=${SPEC_EXCHANGE2_MOVES} \
    -DSPEC_EXCHANGE2_TABLE=${SPEC_EXCHANGE2_TABLE}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_cactubssn_stencil_kernel)
  ifeq (${SPEC_COMPOSITE_PROFILE}, full)
    SPEC_COMPOSITION_SCALE := 1
    SPEC_CACTU_N ?= 6
    SPEC_CACTU_STEPS ?= 1
    SPEC_CACTU_TENSORS ?= 3
  else ifeq (${SPEC_CACTU_REPRESENTATIVE}, 1)
    SPEC_CACTU_N ?= 12
    SPEC_CACTU_STEPS ?= 3
    SPEC_CACTU_TENSORS ?= 6
  else
    SPEC_CACTU_N ?= 6
    SPEC_CACTU_STEPS ?= 1
    SPEC_CACTU_TENSORS ?= 3
  endif
  CFLAGS += -c -O2 \
    -DSPEC_CACTU_N=${SPEC_CACTU_N} \
    -DSPEC_CACTU_STEPS=${SPEC_CACTU_STEPS} \
    -DSPEC_CACTU_TENSORS=${SPEC_CACTU_TENSORS}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_lbm_stream_kernel)
  ifeq (${SPEC_COMPOSITE_PROFILE}, full)
    SPEC_COMPOSITION_SCALE := 3
    SPEC_LBM_CELLS ?= 24
    SPEC_LBM_STEPS ?= 1
    SPEC_LBM_Q ?= 19
  else ifeq (${SPEC_LBM_REPRESENTATIVE}, 1)
    SPEC_LBM_CELLS ?= 384
    SPEC_LBM_STEPS ?= 4
    SPEC_LBM_Q ?= 19
  else
    SPEC_LBM_CELLS ?= 24
    SPEC_LBM_STEPS ?= 1
    SPEC_LBM_Q ?= 19
  endif
  CFLAGS += -c -O2 \
    -DSPEC_LBM_CELLS=${SPEC_LBM_CELLS} \
    -DSPEC_LBM_STEPS=${SPEC_LBM_STEPS} \
    -DSPEC_LBM_Q=${SPEC_LBM_Q}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_parest_sparse_kernel)
  ifeq (${SPEC_PAREST_REPRESENTATIVE}, 1)
    SPEC_PAREST_N ?= 128
    SPEC_PAREST_NNZ_PER_ROW ?= 7
    SPEC_PAREST_ITERS ?= 5
  else
    SPEC_PAREST_N ?= 48
    SPEC_PAREST_NNZ_PER_ROW ?= 5
    SPEC_PAREST_ITERS ?= 3
  endif
  CFLAGS += -c -O2 \
    -DSPEC_PAREST_N=${SPEC_PAREST_N} \
    -DSPEC_PAREST_NNZ_PER_ROW=${SPEC_PAREST_NNZ_PER_ROW} \
    -DSPEC_PAREST_ITERS=${SPEC_PAREST_ITERS}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_parest_dof_kernel)
  ifeq (${SPEC_PAREST_DOF_REPRESENTATIVE}, 1)
    SPEC_PAREST_DOF_N ?= 64
    SPEC_PAREST_DOF_WIDTH ?= 8
    SPEC_PAREST_DOF_CONSTRAINTS ?= 12
    SPEC_PAREST_DOF_PASSES ?= 2
  else
    SPEC_PAREST_DOF_N ?= 24
    SPEC_PAREST_DOF_WIDTH ?= 5
    SPEC_PAREST_DOF_CONSTRAINTS ?= 4
    SPEC_PAREST_DOF_PASSES ?= 1
  endif
  CFLAGS += -c -O2 \
    -DSPEC_PAREST_DOF_N=${SPEC_PAREST_DOF_N} \
    -DSPEC_PAREST_DOF_WIDTH=${SPEC_PAREST_DOF_WIDTH} \
    -DSPEC_PAREST_DOF_CONSTRAINTS=${SPEC_PAREST_DOF_CONSTRAINTS} \
    -DSPEC_PAREST_DOF_PASSES=${SPEC_PAREST_DOF_PASSES}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_510_parest_composite_kernel)
  SPEC_COMPOSITE_PROFILE ?= quick
  ifeq (${SPEC_COMPOSITE_PROFILE}, full)
    SPEC_PAREST_COMPOSITE_DOF_N ?= 42
    SPEC_PAREST_COMPOSITE_DOF_WIDTH ?= 8
    SPEC_PAREST_COMPOSITE_DOF_CONSTRAINTS ?= 4
    SPEC_PAREST_COMPOSITE_SPARSE_N ?= 3800
    SPEC_PAREST_COMPOSITE_SPARSE_NZ ?= 8
    SPEC_PAREST_COMPOSITE_DOF_PASSES ?= 1
    SPEC_PAREST_COMPOSITE_SPARSE_ITERS ?= 1
    SPEC_PAREST_COMPOSITE_SPARSE_TAIL_ROWS ?= 0
    SPEC_PAREST_COMPOSITE_WARMUP ?= 1
  else ifeq (${SPEC_COMPOSITE_PROFILE}, quick)
    SPEC_PAREST_COMPOSITE_DOF_N ?= 24
    SPEC_PAREST_COMPOSITE_DOF_WIDTH ?= 5
    SPEC_PAREST_COMPOSITE_DOF_CONSTRAINTS ?= 4
    SPEC_PAREST_COMPOSITE_SPARSE_N ?= 48
    SPEC_PAREST_COMPOSITE_SPARSE_NZ ?= 5
    SPEC_PAREST_COMPOSITE_DOF_PASSES ?= 1
    SPEC_PAREST_COMPOSITE_SPARSE_ITERS ?= 20
    SPEC_PAREST_COMPOSITE_SPARSE_TAIL_ROWS ?= 13
    SPEC_PAREST_COMPOSITE_WARMUP ?= 0
  else
    $(error SPEC_COMPOSITE_PROFILE must be quick or full)
  endif
  CFLAGS += -c -O2 \
    -DPAREST_DOF_N=${SPEC_PAREST_COMPOSITE_DOF_N} \
    -DPAREST_DOF_WIDTH=${SPEC_PAREST_COMPOSITE_DOF_WIDTH} \
    -DPAREST_DOF_CONSTRAINTS=${SPEC_PAREST_COMPOSITE_DOF_CONSTRAINTS} \
    -DPAREST_SPARSE_N=${SPEC_PAREST_COMPOSITE_SPARSE_N} \
    -DPAREST_SPARSE_NZ=${SPEC_PAREST_COMPOSITE_SPARSE_NZ} \
    -DSPEC_PAREST_COMPOSITE_DOF_PASSES=${SPEC_PAREST_COMPOSITE_DOF_PASSES} \
    -DSPEC_PAREST_COMPOSITE_SPARSE_ITERS=${SPEC_PAREST_COMPOSITE_SPARSE_ITERS} \
    -DSPEC_PAREST_COMPOSITE_SPARSE_TAIL_ROWS=${SPEC_PAREST_COMPOSITE_SPARSE_TAIL_ROWS} \
    -DSPEC_PAREST_COMPOSITE_WARMUP=${SPEC_PAREST_COMPOSITE_WARMUP}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_povray_ray_kernel)
  ifeq (${SPEC_COMPOSITE_PROFILE}, full)
    SPEC_COMPOSITION_SCALE := 8
    SPEC_POVRAY_RAYS ?= 32
    SPEC_POVRAY_OBJECTS ?= 8
    SPEC_POVRAY_BOUNCES ?= 1
  else ifeq (${SPEC_POVRAY_REPRESENTATIVE}, 1)
    SPEC_POVRAY_RAYS ?= 192
    SPEC_POVRAY_OBJECTS ?= 32
    SPEC_POVRAY_BOUNCES ?= 3
  else
    SPEC_POVRAY_RAYS ?= 32
    SPEC_POVRAY_OBJECTS ?= 8
    SPEC_POVRAY_BOUNCES ?= 1
  endif
  CFLAGS += -c -O2 \
    -DSPEC_POVRAY_RAYS=${SPEC_POVRAY_RAYS} \
    -DSPEC_POVRAY_OBJECTS=${SPEC_POVRAY_OBJECTS} \
    -DSPEC_POVRAY_BOUNCES=${SPEC_POVRAY_BOUNCES}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_perlbench_regex_kernel)
  ifeq (${SPEC_COMPOSITE_PROFILE}, full)
    SPEC_COMPOSITION_SCALE := 5
    SPEC_PERLBENCH_ITEMS ?= 64
    SPEC_PERLBENCH_ITERS ?= 1
    SPEC_PERLBENCH_STATES ?= 8
    SPEC_PERLBENCH_DEPTH ?= 3
  else ifeq (${SPEC_PERLBENCH_REPRESENTATIVE}, 1)
    SPEC_PERLBENCH_ITEMS ?= 256
    SPEC_PERLBENCH_ITERS ?= 4
    SPEC_PERLBENCH_STATES ?= 16
    SPEC_PERLBENCH_DEPTH ?= 6
  else
    SPEC_PERLBENCH_ITEMS ?= 64
    SPEC_PERLBENCH_ITERS ?= 1
    SPEC_PERLBENCH_STATES ?= 8
    SPEC_PERLBENCH_DEPTH ?= 3
  endif
  CFLAGS += -c -O2 \
    -DSPEC_PERLBENCH_ITEMS=${SPEC_PERLBENCH_ITEMS} \
    -DSPEC_PERLBENCH_ITERS=${SPEC_PERLBENCH_ITERS} \
    -DSPEC_PERLBENCH_STATES=${SPEC_PERLBENCH_STATES} \
    -DSPEC_PERLBENCH_DEPTH=${SPEC_PERLBENCH_DEPTH}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_gcc_compile_kernel)
  ifeq (${SPEC_COMPOSITE_PROFILE}, full)
    SPEC_COMPOSITION_SCALE := 7
    SPEC_GCC_ITEMS ?= 64
    SPEC_GCC_ITERS ?= 1
    SPEC_GCC_WIDTH ?= 8
    SPEC_GCC_DEPTH ?= 4
  else ifeq (${SPEC_GCC_REPRESENTATIVE}, 1)
    SPEC_GCC_ITEMS ?= 192
    SPEC_GCC_ITERS ?= 4
    SPEC_GCC_WIDTH ?= 16
    SPEC_GCC_DEPTH ?= 8
  else
    SPEC_GCC_ITEMS ?= 64
    SPEC_GCC_ITERS ?= 1
    SPEC_GCC_WIDTH ?= 8
    SPEC_GCC_DEPTH ?= 4
  endif
  CFLAGS += -c -O2 \
    -DSPEC_GCC_ITEMS=${SPEC_GCC_ITEMS} \
    -DSPEC_GCC_ITERS=${SPEC_GCC_ITERS} \
    -DSPEC_GCC_WIDTH=${SPEC_GCC_WIDTH} \
    -DSPEC_GCC_DEPTH=${SPEC_GCC_DEPTH}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_omnetpp_event_kernel)
  ifeq (${SPEC_COMPOSITE_PROFILE}, full)
    SPEC_COMPOSITION_SCALE := 2
    SPEC_OMNETPP_EVENTS ?= 64
    SPEC_OMNETPP_ITERS ?= 1
    SPEC_OMNETPP_WIDTH ?= 6
    SPEC_OMNETPP_DEPTH ?= 3
  else ifeq (${SPEC_OMNETPP_REPRESENTATIVE}, 1)
    SPEC_OMNETPP_EVENTS ?= 192
    SPEC_OMNETPP_ITERS ?= 4
    SPEC_OMNETPP_WIDTH ?= 12
    SPEC_OMNETPP_DEPTH ?= 5
  else
    SPEC_OMNETPP_EVENTS ?= 64
    SPEC_OMNETPP_ITERS ?= 1
    SPEC_OMNETPP_WIDTH ?= 6
    SPEC_OMNETPP_DEPTH ?= 3
  endif
  CFLAGS += -c -O2 \
    -DSPEC_OMNETPP_EVENTS=${SPEC_OMNETPP_EVENTS} \
    -DSPEC_OMNETPP_ITERS=${SPEC_OMNETPP_ITERS} \
    -DSPEC_OMNETPP_WIDTH=${SPEC_OMNETPP_WIDTH} \
    -DSPEC_OMNETPP_DEPTH=${SPEC_OMNETPP_DEPTH}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_xalancbmk_xml_kernel)
  ifeq (${SPEC_COMPOSITE_PROFILE}, full)
    SPEC_COMPOSITION_SCALE := 4
    SPEC_XALAN_NODES ?= 64
    SPEC_XALAN_ITERS ?= 1
    SPEC_XALAN_ROOTS ?= 6
    SPEC_XALAN_DEPTH ?= 4
  else ifeq (${SPEC_XALAN_REPRESENTATIVE}, 1)
    SPEC_XALAN_NODES ?= 256
    SPEC_XALAN_ITERS ?= 4
    SPEC_XALAN_ROOTS ?= 16
    SPEC_XALAN_DEPTH ?= 8
  else
    SPEC_XALAN_NODES ?= 64
    SPEC_XALAN_ITERS ?= 1
    SPEC_XALAN_ROOTS ?= 6
    SPEC_XALAN_DEPTH ?= 4
  endif
  CFLAGS += -c -O2 \
    -DSPEC_XALAN_NODES=${SPEC_XALAN_NODES} \
    -DSPEC_XALAN_ITERS=${SPEC_XALAN_ITERS} \
    -DSPEC_XALAN_ROOTS=${SPEC_XALAN_ROOTS} \
    -DSPEC_XALAN_DEPTH=${SPEC_XALAN_DEPTH}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_bwaves_stencil_kernel)
  ifeq (${SPEC_COMPOSITE_PROFILE}, full)
    SPEC_COMPOSITION_SCALE := 2
    SPEC_BWAVES_CELLS ?= 64
    SPEC_BWAVES_STEPS ?= 1
    SPEC_BWAVES_RADIUS ?= 3
    SPEC_BWAVES_DEPTH ?= 2
  else ifeq (${SPEC_BWAVES_REPRESENTATIVE}, 1)
    SPEC_BWAVES_CELLS ?= 384
    SPEC_BWAVES_STEPS ?= 6
    SPEC_BWAVES_RADIUS ?= 8
    SPEC_BWAVES_DEPTH ?= 4
  else
    SPEC_BWAVES_CELLS ?= 64
    SPEC_BWAVES_STEPS ?= 1
    SPEC_BWAVES_RADIUS ?= 3
    SPEC_BWAVES_DEPTH ?= 2
  endif
  CFLAGS += -c -O2 \
    -DSPEC_BWAVES_CELLS=${SPEC_BWAVES_CELLS} \
    -DSPEC_BWAVES_STEPS=${SPEC_BWAVES_STEPS} \
    -DSPEC_BWAVES_RADIUS=${SPEC_BWAVES_RADIUS} \
    -DSPEC_BWAVES_DEPTH=${SPEC_BWAVES_DEPTH}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_namd_pair_kernel)
  ifeq (${SPEC_COMPOSITE_PROFILE}, full)
    SPEC_COMPOSITION_SCALE := 2
    SPEC_NAMD_ATOMS ?= 64
    SPEC_NAMD_STEPS ?= 1
    SPEC_NAMD_NEIGHBORS ?= 6
    SPEC_NAMD_DEPTH ?= 2
  else ifeq (${SPEC_NAMD_REPRESENTATIVE}, 1)
    SPEC_NAMD_ATOMS ?= 192
    SPEC_NAMD_STEPS ?= 4
    SPEC_NAMD_NEIGHBORS ?= 16
    SPEC_NAMD_DEPTH ?= 4
  else
    SPEC_NAMD_ATOMS ?= 64
    SPEC_NAMD_STEPS ?= 1
    SPEC_NAMD_NEIGHBORS ?= 6
    SPEC_NAMD_DEPTH ?= 2
  endif
  CFLAGS += -c -O2 \
    -DSPEC_NAMD_ATOMS=${SPEC_NAMD_ATOMS} \
    -DSPEC_NAMD_STEPS=${SPEC_NAMD_STEPS} \
    -DSPEC_NAMD_NEIGHBORS=${SPEC_NAMD_NEIGHBORS} \
    -DSPEC_NAMD_DEPTH=${SPEC_NAMD_DEPTH}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_wrf_stencil_kernel)
  ifeq (${SPEC_COMPOSITE_PROFILE}, full)
    SPEC_COMPOSITION_SCALE := 1
    SPEC_WRF_CELLS ?= 80
    SPEC_WRF_STEPS ?= 1
    SPEC_WRF_RADIUS ?= 3
    SPEC_WRF_DEPTH ?= 2
  else ifeq (${SPEC_WRF_REPRESENTATIVE}, 1)
    SPEC_WRF_CELLS ?= 384
    SPEC_WRF_STEPS ?= 6
    SPEC_WRF_RADIUS ?= 8
    SPEC_WRF_DEPTH ?= 4
  else
    SPEC_WRF_CELLS ?= 64
    SPEC_WRF_STEPS ?= 1
    SPEC_WRF_RADIUS ?= 3
    SPEC_WRF_DEPTH ?= 2
  endif
  CFLAGS += -c -O2 \
    -DSPEC_WRF_CELLS=${SPEC_WRF_CELLS} \
    -DSPEC_WRF_STEPS=${SPEC_WRF_STEPS} \
    -DSPEC_WRF_RADIUS=${SPEC_WRF_RADIUS} \
    -DSPEC_WRF_DEPTH=${SPEC_WRF_DEPTH}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_blender_render_kernel)
  ifeq (${SPEC_COMPOSITE_PROFILE}, full)
    SPEC_COMPOSITION_SCALE := 1
    SPEC_BLENDER_RAYS ?= 64
    SPEC_BLENDER_PASSES ?= 1
    SPEC_BLENDER_OBJECTS ?= 6
    SPEC_BLENDER_DEPTH ?= 2
  else ifeq (${SPEC_BLENDER_REPRESENTATIVE}, 1)
    SPEC_BLENDER_RAYS ?= 192
    SPEC_BLENDER_PASSES ?= 4
    SPEC_BLENDER_OBJECTS ?= 16
    SPEC_BLENDER_DEPTH ?= 4
  else
    SPEC_BLENDER_RAYS ?= 64
    SPEC_BLENDER_PASSES ?= 1
    SPEC_BLENDER_OBJECTS ?= 6
    SPEC_BLENDER_DEPTH ?= 2
  endif
  CFLAGS += -c -O2 \
    -DSPEC_BLENDER_RAYS=${SPEC_BLENDER_RAYS} \
    -DSPEC_BLENDER_PASSES=${SPEC_BLENDER_PASSES} \
    -DSPEC_BLENDER_OBJECTS=${SPEC_BLENDER_OBJECTS} \
    -DSPEC_BLENDER_DEPTH=${SPEC_BLENDER_DEPTH}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_cam4_climate_kernel)
  ifeq (${SPEC_COMPOSITE_PROFILE}, full)
    SPEC_COMPOSITION_SCALE := 2
    SPEC_CAM4_LEVELS ?= 60
    SPEC_CAM4_STEPS ?= 1
    SPEC_CAM4_COLUMNS ?= 6
    SPEC_CAM4_DEPTH ?= 2
  else ifeq (${SPEC_CAM4_REPRESENTATIVE}, 1)
    SPEC_CAM4_LEVELS ?= 256
    SPEC_CAM4_STEPS ?= 4
    SPEC_CAM4_COLUMNS ?= 16
    SPEC_CAM4_DEPTH ?= 4
  else
    SPEC_CAM4_LEVELS ?= 64
    SPEC_CAM4_STEPS ?= 1
    SPEC_CAM4_COLUMNS ?= 6
    SPEC_CAM4_DEPTH ?= 2
  endif
  CFLAGS += -c -O2 \
    -DSPEC_CAM4_LEVELS=${SPEC_CAM4_LEVELS} \
    -DSPEC_CAM4_STEPS=${SPEC_CAM4_STEPS} \
    -DSPEC_CAM4_COLUMNS=${SPEC_CAM4_COLUMNS} \
    -DSPEC_CAM4_DEPTH=${SPEC_CAM4_DEPTH}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_imagick_filter_kernel)
  ifeq (${SPEC_COMPOSITE_PROFILE}, full)
    SPEC_COMPOSITION_SCALE := 6
    SPEC_IMAGICK_PIXELS ?= 64
    SPEC_IMAGICK_PASSES ?= 1
    SPEC_IMAGICK_RADIUS ?= 3
    SPEC_IMAGICK_DEPTH ?= 2
  else ifeq (${SPEC_IMAGICK_REPRESENTATIVE}, 1)
    SPEC_IMAGICK_PIXELS ?= 256
    SPEC_IMAGICK_PASSES ?= 4
    SPEC_IMAGICK_RADIUS ?= 8
    SPEC_IMAGICK_DEPTH ?= 4
  else
    SPEC_IMAGICK_PIXELS ?= 64
    SPEC_IMAGICK_PASSES ?= 1
    SPEC_IMAGICK_RADIUS ?= 3
    SPEC_IMAGICK_DEPTH ?= 2
  endif
  CFLAGS += -c -O2 \
    -DSPEC_IMAGICK_PIXELS=${SPEC_IMAGICK_PIXELS} \
    -DSPEC_IMAGICK_PASSES=${SPEC_IMAGICK_PASSES} \
    -DSPEC_IMAGICK_RADIUS=${SPEC_IMAGICK_RADIUS} \
    -DSPEC_IMAGICK_DEPTH=${SPEC_IMAGICK_DEPTH}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_nab_md_kernel)
  ifeq (${SPEC_COMPOSITE_PROFILE}, full)
    SPEC_COMPOSITION_SCALE := 3
    SPEC_NAB_ATOMS ?= 64
    SPEC_NAB_STEPS ?= 1
    SPEC_NAB_NEIGHBORS ?= 6
    SPEC_NAB_DEPTH ?= 2
  else ifeq (${SPEC_NAB_REPRESENTATIVE}, 1)
    SPEC_NAB_ATOMS ?= 192
    SPEC_NAB_STEPS ?= 4
    SPEC_NAB_NEIGHBORS ?= 16
    SPEC_NAB_DEPTH ?= 4
  else
    SPEC_NAB_ATOMS ?= 64
    SPEC_NAB_STEPS ?= 1
    SPEC_NAB_NEIGHBORS ?= 6
    SPEC_NAB_DEPTH ?= 2
  endif
  CFLAGS += -c -O2 \
    -DSPEC_NAB_ATOMS=${SPEC_NAB_ATOMS} \
    -DSPEC_NAB_STEPS=${SPEC_NAB_STEPS} \
    -DSPEC_NAB_NEIGHBORS=${SPEC_NAB_NEIGHBORS} \
    -DSPEC_NAB_DEPTH=${SPEC_NAB_DEPTH}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_fotonik3d_stencil_kernel)
  ifeq (${SPEC_COMPOSITE_PROFILE}, full)
    SPEC_COMPOSITION_SCALE := 8
    SPEC_FOTONIK_CELLS ?= 64
    SPEC_FOTONIK_STEPS ?= 1
    SPEC_FOTONIK_RADIUS ?= 3
    SPEC_FOTONIK_DEPTH ?= 2
  else ifeq (${SPEC_FOTONIK_REPRESENTATIVE}, 1)
    SPEC_FOTONIK_CELLS ?= 384
    SPEC_FOTONIK_STEPS ?= 6
    SPEC_FOTONIK_RADIUS ?= 8
    SPEC_FOTONIK_DEPTH ?= 4
  else
    SPEC_FOTONIK_CELLS ?= 64
    SPEC_FOTONIK_STEPS ?= 1
    SPEC_FOTONIK_RADIUS ?= 3
    SPEC_FOTONIK_DEPTH ?= 2
  endif
  CFLAGS += -c -O2 \
    -DSPEC_FOTONIK_CELLS=${SPEC_FOTONIK_CELLS} \
    -DSPEC_FOTONIK_STEPS=${SPEC_FOTONIK_STEPS} \
    -DSPEC_FOTONIK_RADIUS=${SPEC_FOTONIK_RADIUS} \
    -DSPEC_FOTONIK_DEPTH=${SPEC_FOTONIK_DEPTH}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_roms_stencil_kernel)
  ifeq (${SPEC_COMPOSITE_PROFILE}, full)
    SPEC_COMPOSITION_SCALE := 1
    SPEC_ROMS_CELLS ?= 80
    SPEC_ROMS_STEPS ?= 1
    SPEC_ROMS_RADIUS ?= 3
    SPEC_ROMS_DEPTH ?= 2
  else ifeq (${SPEC_ROMS_REPRESENTATIVE}, 1)
    SPEC_ROMS_CELLS ?= 384
    SPEC_ROMS_STEPS ?= 6
    SPEC_ROMS_RADIUS ?= 8
    SPEC_ROMS_DEPTH ?= 4
  else
    SPEC_ROMS_CELLS ?= 64
    SPEC_ROMS_STEPS ?= 1
    SPEC_ROMS_RADIUS ?= 3
    SPEC_ROMS_DEPTH ?= 2
  endif
  CFLAGS += -c -O2 \
    -DSPEC_ROMS_CELLS=${SPEC_ROMS_CELLS} \
    -DSPEC_ROMS_STEPS=${SPEC_ROMS_STEPS} \
    -DSPEC_ROMS_RADIUS=${SPEC_ROMS_RADIUS} \
    -DSPEC_ROMS_DEPTH=${SPEC_ROMS_DEPTH}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_pop2_ocean_kernel)
  ifeq (${SPEC_COMPOSITE_PROFILE}, full)
    SPEC_COMPOSITION_SCALE := 2
    SPEC_POP2_CELLS ?= 64
    SPEC_POP2_STEPS ?= 1
    SPEC_POP2_SOLVER_ITERS ?= 3
    SPEC_POP2_DEPTH ?= 2
  else ifeq (${SPEC_POP2_REPRESENTATIVE}, 1)
    SPEC_POP2_CELLS ?= 256
    SPEC_POP2_STEPS ?= 4
    SPEC_POP2_SOLVER_ITERS ?= 8
    SPEC_POP2_DEPTH ?= 4
  else
    SPEC_POP2_CELLS ?= 64
    SPEC_POP2_STEPS ?= 1
    SPEC_POP2_SOLVER_ITERS ?= 3
    SPEC_POP2_DEPTH ?= 2
  endif
  CFLAGS += -c -O2 \
    -DSPEC_POP2_CELLS=${SPEC_POP2_CELLS} \
    -DSPEC_POP2_STEPS=${SPEC_POP2_STEPS} \
    -DSPEC_POP2_SOLVER_ITERS=${SPEC_POP2_SOLVER_ITERS} \
    -DSPEC_POP2_DEPTH=${SPEC_POP2_DEPTH}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, spec_638_imagick_speed_kernel)
  SPEC_638_WIDTH ?= 12
  SPEC_638_HEIGHT ?= 8
  SPEC_638_RESAMPLE_ROUNDS ?= 4
  SPEC_638_COLOR_ROUNDS ?= 1
  SPEC_638_FILTER_ROUNDS ?= 1
  SPEC_638_RESAMPLE_EXTRA_ROUNDS ?= 0
  SPEC_638_COLOR_EXTRA_ROUNDS ?= 0
  SPEC_638_FILTER_EXTRA_ROUNDS ?= 0
  CFLAGS += -c -O2 \
    -DSPEC_638_WIDTH=${SPEC_638_WIDTH} \
    -DSPEC_638_HEIGHT=${SPEC_638_HEIGHT} \
    -DSPEC_638_RESAMPLE_ROUNDS=${SPEC_638_RESAMPLE_ROUNDS} \
    -DSPEC_638_COLOR_ROUNDS=${SPEC_638_COLOR_ROUNDS} \
    -DSPEC_638_FILTER_ROUNDS=${SPEC_638_FILTER_ROUNDS} \
    -DSPEC_638_RESAMPLE_EXTRA_ROUNDS=${SPEC_638_RESAMPLE_EXTRA_ROUNDS} \
    -DSPEC_638_COLOR_EXTRA_ROUNDS=${SPEC_638_COLOR_EXTRA_ROUNDS} \
    -DSPEC_638_FILTER_EXTRA_ROUNDS=${SPEC_638_FILTER_EXTRA_ROUNDS}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else ifeq (${CASENAME}, bench_br_pattern)
  BP_BRANCHES ?= 1
  BP_PATTERN_LENGTH ?= 2
  BP_RANDOM_MODE ?= 0
  BP_SEED ?= 910
  BP_WARMUP_ITERATIONS ?= 256
  BP_MEASURE_ITERATIONS ?= 512
  CFLAGS += -c -O2 -fno-unroll-loops \
    -DBP_BRANCHES=${BP_BRANCHES} \
    -DBP_PATTERN_LENGTH=${BP_PATTERN_LENGTH} \
    -DBP_RANDOM_MODE=${BP_RANDOM_MODE} \
    -DBP_SEED=${BP_SEED} \
    -DBP_WARMUP_ITERATIONS=${BP_WARMUP_ITERATIONS} \
    -DBP_MEASURE_ITERATIONS=${BP_MEASURE_ITERATIONS}
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
else
  CFLAGS += -c -O2
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
endif

SPEC_PROFILE_FOOTPRINT_CASES := \
  spec_perlbench_regex_kernel spec_gcc_compile_kernel \
  spec_omnetpp_event_kernel spec_xalancbmk_xml_kernel \
  spec_x264_pixel_kernel spec_deepsjeng_search_kernel \
  spec_leela_playout_kernel spec_exchange2_search_kernel \
  spec_xz_lzma_kernel spec_bwaves_stencil_kernel \
  spec_cactubssn_stencil_kernel spec_namd_pair_kernel \
  spec_povray_ray_kernel spec_lbm_stream_kernel \
  spec_wrf_stencil_kernel spec_blender_render_kernel \
  spec_cam4_climate_kernel spec_imagick_filter_kernel \
  spec_nab_md_kernel spec_fotonik3d_stencil_kernel \
  spec_roms_stencil_kernel spec_pop2_ocean_kernel \
  ${SPEC_SPEED_INDEPENDENT_CASES}
ifeq (${SPEC_COMPOSITE_PROFILE}, full)
ifneq ($(filter ${CASENAME},${SPEC_PROFILE_FOOTPRINT_CASES}),)
CFLAGS += -DSPEC_PROFILE_FOOTPRINT_BYTES=131072
SFLAGS += -DSPEC_PROFILE_FOOTPRINT_BYTES=131072
endif
endif

CFLAGS += --specs=nano.specs
ifeq (${KERNEL_CHARACTERIZATION}, 1)
CFLAGS += -DKERNEL_CHARACTERIZATION
SFLAGS += -DKERNEL_CHARACTERIZATION
endif
CFLAGS += ${EXTRA_CFLAGS}
SFLAGS += ${EXTRA_CFLAGS}

LINKFLAGS = -Tlinker.lcf -nostartfiles #${FLAG_MARCH} ${FLAG_ABI}

# LINKLIBS  = -L${TOOL_PATH}/lib/gcc/riscv64-unknown-elf/8.1.0/rv32imac
# LINKLIBS += -L${TOOL_PATH}/riscv64-unknown-elf/lib/rv32imac
# LINKLIBS += -L${TOOL_PATH}/riscv32-unknown-elf/lib

LINKLIBS = -lc -lgcc

OBJDUMPFLAGS = -S -Mnumeric

HEXFLAGS	= -O srec

%.o : %.c
	${CC} -c ${CFLAGS} -o $@ $<

%.o : %.s
	${CC} -c ${CFLAGS} -o $@ $<

%.o : %.S
	${CC} -c ${SFLAGS} -o $@ $<

.PHONY: print-compiler-config
print-compiler-config:
	@printf 'CC=%s\nCFLAGS=%s\nSFLAGS=%s\nLINKFLAGS=%s\nLINKLIBS=%s\n' \
	  '${CC}' '${CFLAGS}' '${SFLAGS}' '${LINKFLAGS}' '${LINKLIBS}'

${FILE}.elf : ${OBJECTS} linker.lcf
	${CC} ${LINKFLAGS} ${LINKLIBS} ${OBJECTS} -o $@ -lm 

${FILE}.obj : ${FILE}.elf
	${OBJDUMP} ${OBJDUMPFLAGS} $< > $@

INST_HEX = ${FILE}_inst.hex
DATA_HEX = ${FILE}_data.hex
FILE_HEX = ${FILE}.hex

${FILE}.hex : ${FILE}.elf
	${OBJCOPY} ${HEXFLAGS} $< ${INST_HEX} -j .text*  -j .rodata* -j .eh_frame*
	${OBJCOPY} ${HEXFLAGS} $< ${DATA_HEX} -j .data*  -j .bss -j .COMMON
	${OBJCOPY} ${HEXFLAGS} $< $@ 

${FILE}.asm : ${FILE}.elf
	${OBJDUMP} -d $< > $@	

INST_PAT = inst.pat
DATA_PAT = data.pat
FILE_PAT = case.pat

%.pat	: %.hex
	rm -f *.pat
	${CONVERT} ${INST_HEX} ${INST_PAT}
	${CONVERT} ${DATA_HEX} ${DATA_PAT}
	${CONVERT} ${FILE_HEX} ${FILE_PAT}

symbols.svh : ${FILE}.elf
	PATH=${GCC_PATH}:$$PATH ./gen_symbols.py $<

#--------------------------------------------------------------------
# target setting
.PHONY :all
all : ${FILE}.pat ${FILE}.hex ${FILE}.elf ${FILE}.obj ${FILE}.asm symbols.svh

#---------------------------------------------------------------------
# clean some medium c symbolsode and .pat
.PHONY :clean 
clean:
	rm -rf *.o *.pat *.elf *.obj *.hex
