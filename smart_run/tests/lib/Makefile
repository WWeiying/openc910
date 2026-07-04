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
else ifeq (${CASENAME}, spec_xz_lzma_kernel)
  ifeq (${SPEC_XZ_REPRESENTATIVE}, 1)
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
  ifeq (${SPEC_X264_REPRESENTATIVE}, 1)
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
  ifeq (${SPEC_DEEPSJENG_REPRESENTATIVE}, 1)
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
  ifeq (${SPEC_LEELA_REPRESENTATIVE}, 1)
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
  ifeq (${SPEC_EXCHANGE2_REPRESENTATIVE}, 1)
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
  ifeq (${SPEC_CACTU_REPRESENTATIVE}, 1)
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
  ifeq (${SPEC_LBM_REPRESENTATIVE}, 1)
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
else ifeq (${CASENAME}, spec_povray_ray_kernel)
  ifeq (${SPEC_POVRAY_REPRESENTATIVE}, 1)
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
else
  CFLAGS += -c -O2
  SFLAGS = -march=rv64imafdcvxtheadc -mabi=lp64d -c -O2
endif

CFLAGS += --specs=nano.specs

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
