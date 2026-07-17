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

include ./setup/smart_cfg.mk

################################################################################
# Simulation related
################################################################################
SIM = vcs
DUMP = on
PERF_DETAIL ?= off
UPF = off 
THREADS = 4
COREMARK_ITERATIONS ?= 30
export COMPILER = gcc

CODE_BASE_PATH ?= $(abspath ../C910_RTL_FACTORY)
TOOLCHAIN_ROOT ?= $(abspath ../toolchains/Xuantie-900-gcc-elf-newlib-x86_64-V3.1.0)
LLVM_TOOLCHAIN_ROOT ?= $(abspath ../toolchains/Xuantie-900-llvm-elf-newlib-x86_64-V2.4.0)
QEMU_ROOT ?= $(abspath ../toolchains/Xuantie-qemu-x86_64-Ubuntu-20.04-V5.2.8-B20250721-0303)
TOOL_EXTENSION ?= $(TOOLCHAIN_ROOT)/bin/
GCC_PATH ?= $(TOOL_EXTENSION)
LLVM_PATH ?= $(LLVM_TOOLCHAIN_ROOT)/bin
QEMU_PATH ?= $(QEMU_ROOT)/bin
export CODE_BASE_PATH
export TOOLCHAIN_ROOT
export LLVM_TOOLCHAIN_ROOT
export QEMU_ROOT
export TOOL_EXTENSION
export GCC_PATH
export LLVM_PATH
export QEMU_PATH

################################################################################
# Docker environment for Xuantie QEMU / SimPoint tooling
################################################################################
REPO_ROOT := $(abspath ..)
DOCKER ?= docker
DOCKER_IMAGE ?= ubuntu:20.04
DOCKER_CONTAINER ?= openc910-qemu
DOCKER_WORKDIR ?= /work/smart_run
DOCKER_MOUNT ?= $(REPO_ROOT):/work
DOCKER_RUN_FLAGS ?= --network host
DOCKER_QEMU ?= /work/toolchains/Xuantie-qemu-x86_64-Ubuntu-20.04-V5.2.8-B20250721-0303/bin/qemu-system-riscv64
DOCKER_APT_DEPS ?= \
	ca-certificates bash make file less vim-tiny git \
	build-essential python3 python3-pip python3-venv perl \
	qemu-system-misc p7zip-full gzip xz-utils time \
	libcapstone3 pkg-config libglib2.0-dev zstd \
	libsnappy1v5 liblzo2-2 libsdl2-2.0-0 libdaxctl1 libvdeplug2 \
	libgtk-3-0 libcairo2 libgdk-pixbuf2.0-0 libsdl2-image-2.0-0 \
	libpulse0 libfuse3-3 libnfs13

# Generate C++ in executable form
VERILATOR_FLAGS += -cc --exe
# Generate makefile dependencies (not shown as complicates the Makefile)
#VERILATOR_FLAGS += -MMD
# Optimize
VERILATOR_FLAGS += -Os -x-assign 0
# lint-only
VERILATOR_FLAGS += -lint-only
# Warn abount lint issues; may not want this on less solid designs
VERILATOR_FLAGS += -Wno-fatal
# Make waveforms
#VERILATOR_FLAGS += --trace
## Check SystemVerilog assertions
#VERILATOR_FLAGS += --assert
## Generate coverage analysis
#VERILATOR_FLAGS += --coverage
# Run Verilator in debug mode
#VERILATOR_FLAGS += --debug
# Add this trace to get a backtrace in gdb
#VERILATOR_FLAGS += --gdbbt

ifeq (${DUMP}, on)
ifeq (${SIM}, verilator)
SIM_DUMP := --trace
else
SIM_DUMP :=
endif
else
ifeq (${SIM}, iverilog)
SIM_DUMP = -DNO_DUMP
else
SIM_DUMP := +define+NO_DUMP
endif
endif

ifeq (${SIM}, vcs)
TIMESCALE := -timescale=1ns/100fs
ifeq (${DUMP}, on)
SIMULATOR_OPT := -full64 -sverilog -Mupdate -j64 -lca -kdb -debug_access +nospecify +notimingchecks +lint=TFIPC-L
else
SIMULATOR_OPT := -full64 -sverilog -Mupdate -j64 -lca +nospecify +notimingchecks +lint=TFIPC-L
endif
SIMULATOR_DEF := +define+no_warning +define+TSMC_NO_WARNING
SIMULATOR_LOG := -l comp.vcs.log
ifeq (${UPF}, on)
SIMULATOR_POWER_OPT := -upf ../impl/upf/example_cpu_power_spec.upf +define+UPF_INCLUDED
SIMV_POWER_OPT      := +fsdb+power +fsdb+all 
else
SIMULATOR_POWER_OPT := 
SIMV_POWER_OPT      := 
endif
else 
    ifeq (${SIM}, nc) 
    TIMESCALE := -timescale 1ns/100fs
    SIMULATOR_OPT := +v2k -sysv +sv +access+wrc +notimingcheck -default_ext verilog -elaborate +tcl+../setup/nc.tcl
    SIMULATOR_DEF := +define+no_warning +define+TSMC_NO_WARNING +define+VMC +define+NC_SIM 
    SIMULATOR_LOG := -l comp.nc.log
    else
        ifeq (${SIM}, iverilog)
          TIMESCALE := 
          SIMULATOR_OPT := -o xuantie_core.vvp -Diverilog=1 -g2012 
          SIMULATOR_DEF := -DIVERILOG_SIM
          SIMULATOR_LOG := 
        else
            ifeq (${SIM}, verilator)
              SIMULATOR_OPT := -Os -x-assign 0 -Wno-fatal --threads ${THREADS}
              SIMULATOR_DEF := -cc --exe --top-module top 
              SIMULATOR_LOG := 
            else
            endif
        endif
    endif
endif

ifeq (${PERF_DETAIL}, on)
ifeq (${SIM}, iverilog)
SIMULATOR_DEF += -DPERF_DETAIL
else
    ifeq (${SIM}, verilator)
SIMULATOR_DEF += -DPERF_DETAIL
    else
SIMULATOR_DEF += +define+PERF_DETAIL
    endif
endif
endif

ifeq (${SIM}, iverilog)
    SIM_FILELIST := ${SIM_FILELIST} -f ${CODE_BASE_PATH}/gen_rtl/filelists/C910_asic_rtl.fl -c ../logical/filelists/smart.fl -c ../logical/filelists/tb.fl
else
    ifeq (${SIM}, verilator)
    SIM_FILELIST := ${SIM_FILELIST} -f ../logical/filelists/sim_verilator.fl
    else
    SIM_FILELIST := ${SIM_FILELIST} -f ../logical/filelists/sim.fl
    endif
endif

compile:
	@echo "  [THead-smart] Compiling smart now ... "
	@echo "  [THead-smart] SIM = ${SIM}"
	@echo "  [THead-smart] PERF_DETAIL = ${PERF_DETAIL}"
	@echo "  [THead-smart] CODE_BASE_PATH = ${CODE_BASE_PATH}"
ifeq (${SIM}, vcs)
	@make -s cleansim
	@mkdir -p ./work
	@cd ./work && vcs ${SIMULATOR_OPT} ${TIMESCALE} ${SIMULATOR_DEF} ${SIM_FILELIST} ${SIM_DUMP} ${SIMULATOR_LOG} ${SIMULATOR_POWER_OPT} 
else 
    ifeq (${SIM}, nc) 
	@cd ./work && irun ${SIMULATOR_OPT} ${TIMESCALE} ${SIMULATOR_DEF} ${SIM_FILELIST} ${SIM_DUMP} ${SIMULATOR_LOG} 
    else
        ifeq (${SIM}, iverilog)
	  @cd ./work && iverilog ${TIMESCALE} ${SIMULATOR_OPT} ${SIMULATOR_DEF} ${SIM_FILELIST} ${SIM_DUMP} ${SIMULATOR_LOG}
        else
            ifeq (${SIM}, verilator)
	      @cd ./work && verilator ${SIMULATOR_OPT} ${SIMULATOR_DEF} ${SIMULATOR_LOG} ${SIM_FILELIST} ${SIM_DUMP}
            else
	      @echo "  [THead-smart] Please specify SIM = vcs to use VCS, or SIM = nc ,or SIM = verilator to use irun ..."
            endif
        endif
    endif 
endif 

buildVerilator:
	@cp ./logical/tb/Makefile_obj ./work/Makefile_obj
	@cd ./work && make -j -C obj_dir -f ../Makefile_obj
cleansim:
	@cd ./work && rm -rf *.vcs.log novas_dump.log dyn_inst_trace.log pc_trace.log *.fsdb
cleanVerilator:
	@cd ./work && rm -rf obj_dir/

verdi:
	@cd ./work && verdi -sv ${SIM_FILELIST} -ssy -ssv -top tb -ssf novas.fsdb &

################################################################################
# Cases related
################################################################################
showcase:
	@echo "  Case lists:" \ 
	@for case in ${CASE_LIST} ; do \
          echo "    $$case"; \
        done

buildcase: 
ifeq (${CASE},)
	$(error Please specify CASE=xxx on the command line, like: \
        $(newline)   > make buildcase CASE=xxx... \
        $(newline)   The list of valid cases can be obtained by executing: \
        $(newline)   > make showcase ...)
endif
ifeq ($(findstring ${CASE}, ${CASE_LIST}), ${CASE})
	@make -s cleancase
	@make -s ${CASE}_build
else
	$(error Argument CASE=xxx is not valid: \
        $(newline)   The list of valid cases can be obtained by executing: \
        $(newline)   > make showcase ...)
endif


simcase:
ifeq (${CASE},)
	$(error Please specify CASE=xxx on the command line)
endif
ifeq ($(findstring ${CASE}, ${CASE_LIST}), ${CASE})
	@make -s buildcase CASE=${CASE}
ifeq (${SIM}, vcs)
	@cd ./work && ./simv -l run.vcs.log ${SIMV_POWER_OPT} $$(cat symbols.args) && \
	  if [ -f ${CASE}.asm ]; then \
	    ./gen_dyn_inst_trace.py pc_trace.log ${CASE}.asm || echo "WARN: dynamic instruction trace generation failed for ${CASE}"; \
	  else \
	    echo "WARN: ${CASE}.asm not found; skip dynamic instruction trace generation"; \
	  fi
else
        ifeq (${SIM}, nc)
		cd ./work && irun -R -l run.irun.log
        else
            ifeq (${SIM}, verilator)
		make buildVerilator
		cd ./work && obj_dir/Vtop
            else
	        cd ./work && vvp xuantie_core.vvp
            endif
        endif
endif
else
	$(error Argument CASE=xxx is not valid)
endif

cleancase:
	@cd ./work && rm -rf *.s *.S *.c *.o *.pat *.h *.lcf *.hex *.obj *.vh *.v *.report *.elf *.asm symbols.svh symbols.args Makefile *.case.log

################################################################################
# Combined flows
################################################################################
# Execute one case
runVerilator:
	@cd ./work && obj_dir/Vtop

runcase:
ifeq (${CASE},)
	$(error Please specify CASE=xxx on the command line, like: \
        $(newline)   > make buildcase CASE=xxx... \
        $(newline)   The list of valid cases can be obtained by executing: \
        $(newline)   > make showcase ...)
endif
ifeq ($(findstring ${CASE}, ${CASE_LIST}), ${CASE})
	@make -s buildcase CASE=${CASE}
ifeq (${SIM}, vcs)
	@make -s compile
	@cd ./work && ./simv -l run.vcs.log ${SIMV_POWER_OPT} $$(cat symbols.args) && \
	  if [ -f ${CASE}.asm ]; then \
	    ./gen_dyn_inst_trace.py pc_trace.log ${CASE}.asm || echo "WARN: dynamic instruction trace generation failed for ${CASE}"; \
	  else \
	    echo "WARN: ${CASE}.asm not found; skip dynamic instruction trace generation"; \
	  fi
else
        ifeq (${SIM}, nc)	
		cd ./work && irun -R -l run.irun.log
        else
            ifeq (${SIM}, verilator)
		make buildVerilator
		cd ./work && obj_dir/Vtop	
            else
	        cd ./work && vvp xuantie_core.vvp 
            endif
        endif
endif
else
	$(error Argument CASE=xxx is not valid: \
        $(newline)   The list of valid cases can be obtained by executing: \
        $(newline)   > make showcase ...)
endif

# Execute all cases
regress:
	rm -rf ./tests/regress/regress_result/*
	@(for case in ${CASE_LIST} ; do \
	 rm -rf ./work/* ; \
	 make -s runcase CASE=$$case; \
	 cp ./work/run_case.report ./tests/regress/regress_result/$$case.report; \
	 done)
	cd ./tests/regress && perl report_gen.pl
	cat ./tests/regress/regress_report

################################################################################
# Misc
################################################################################
.DEFAULT_GOAL := help

.PHONY: compile buildVerilator cleansim cleanVerilator verdi showcase buildcase \
	simcase cleancase runVerilator runcase regress memlist docker-create \
	docker-start docker-shell docker-root docker-deps docker-qemu-test \
	docker-stop docker-rm clean help

memlist:
	@make -s compile
	${VERDI_HOME}/share/VIA/Apps/Bin/findInstDefWild.pl -dbdir ./work/simv.daidir -pattern "ct_spsram*" -scope "tb.x_soc.x_cpu_sub_system_axi.x_rv_integration_platform.x_cpu_top" -dump_def_name -outlog ./work/memlist.verdi.log
	perl impl/memlist/memlist.pl 

docker-create:
	@if $(DOCKER) ps -a --format '{{.Names}}' | grep -qx '$(DOCKER_CONTAINER)'; then \
	  echo "  [Docker] Container $(DOCKER_CONTAINER) already exists"; \
	else \
	  echo "  [Docker] Creating $(DOCKER_CONTAINER) from $(DOCKER_IMAGE)"; \
	  $(DOCKER) create -it \
	    --name $(DOCKER_CONTAINER) \
	    $(DOCKER_RUN_FLAGS) \
	    -v $(DOCKER_MOUNT) \
	    -w $(DOCKER_WORKDIR) \
	    $(DOCKER_IMAGE) \
	    bash >/dev/null; \
	fi

docker-start: docker-create
	@if $(DOCKER) ps --format '{{.Names}}' | grep -qx '$(DOCKER_CONTAINER)'; then \
	  echo "  [Docker] Container $(DOCKER_CONTAINER) is already running"; \
	else \
	  echo "  [Docker] Starting $(DOCKER_CONTAINER)"; \
	  $(DOCKER) start $(DOCKER_CONTAINER) >/dev/null; \
	fi

docker-shell: docker-start
	@$(DOCKER) exec -it $(DOCKER_CONTAINER) bash

docker-root: docker-shell

docker-deps: docker-start
	@$(DOCKER) exec -it $(DOCKER_CONTAINER) bash -lc \
	  'export DEBIAN_FRONTEND=noninteractive; \
	   apt-get update && \
	   apt-get install -y --no-install-recommends $(DOCKER_APT_DEPS)'

docker-qemu-test: docker-start
	@$(DOCKER) exec -it $(DOCKER_CONTAINER) bash -lc \
	  '$(DOCKER_QEMU) --version && ldd $(DOCKER_QEMU) | grep "not found" || true'

docker-stop:
	@if $(DOCKER) ps --format '{{.Names}}' | grep -qx '$(DOCKER_CONTAINER)'; then \
	  echo "  [Docker] Stopping $(DOCKER_CONTAINER)"; \
	  $(DOCKER) stop $(DOCKER_CONTAINER) >/dev/null; \
	else \
	  echo "  [Docker] Container $(DOCKER_CONTAINER) is not running"; \
	fi

docker-rm:
	@if $(DOCKER) ps -a --format '{{.Names}}' | grep -qx '$(DOCKER_CONTAINER)'; then \
	  echo "  [Docker] Removing $(DOCKER_CONTAINER)"; \
	  $(DOCKER) rm -f $(DOCKER_CONTAINER) >/dev/null; \
	else \
	  echo "  [Docker] Container $(DOCKER_CONTAINER) does not exist"; \
	fi

clean:
	@cd ./work && rm -rf * 

help:
	@echo "  ########## Smart Help Info ##########"
	@echo "  This Makefile is the entrance of T-Head Smart simulation environment"
	@echo "  Usage: make [target] [arguments]";
	@echo "  Available targets:";
	@echo "    compile                         : compile the RTL and Smart tbench (using vcs or ius)";
	@echo "    showcase                        : list all valid cases under current configuration";
	@echo "    buildcase CASE=[casename]       : clean and compile the .c/.s case [casename]";
	@echo "    [casename]_build                : compile the .c/.s case [casename]";
	@echo "    runcase CASE=[casename]         : run the case [casename] (full flow: build+compile+sim)";
	@echo "    simcase CASE=[casename]         : run case without RTL recompile (requires prior compile)";
	@echo "    regress                         : run all cases and summarize the regress result";
	@echo "    memlist                         : generate sram list with the help of VCS/Verdi";
	@echo "    docker-create                   : create Ubuntu container for Xuantie QEMU/SimPoint";
	@echo "    docker-start                    : start the Docker container";
	@echo "    docker-shell                    : enter the Docker container";
	@echo "    docker-deps                     : install runtime deps for bundled Xuantie QEMU";
	@echo "    docker-qemu-test                : test bundled Xuantie QEMU in the container";
	@echo "    docker-stop                     : stop the Docker container";
	@echo "    docker-rm                       : remove the Docker container";
	@echo "    cleansim                        : clean files generated by simulator in ./work ";
	@echo "    cleancase                       : clean files generated by GNU in ./work ";
	@echo "    clean                           : clean ./work ";
	@echo "  Optional arguments:";
	@echo "    SIM=                            : options: vcs / nc / verilator(use version 4.215 or newer)"; 
	@echo "    CASE=                           : options: the list print by 'make showcase'"; 
	@echo "    DUMP=                           : options: on / off";
	@echo "    PERF_DETAIL=                    : options: on / off, enable detailed microarchitecture perf counters";
	@echo "    DOCKER_IMAGE=                   : default: $(DOCKER_IMAGE)";
	@echo "    DOCKER_CONTAINER=               : default: $(DOCKER_CONTAINER)";
	@echo "  Examples:";
	@echo "    make runcase CASE=dhry          : run case 'dhry' (by iverilog withtout dump) "; 
	@echo "    make runcase CASE=dhry SIM=nc   : run case 'dhry' (by nc withtout dump) "; 
	@echo "    make runcase CASE=dhry DUMP=on  : run case 'dhry' with dump "; 
	@echo "    make runcase CASE=coremark SIM=verilator THREADS=8 	: run case 'coremark' without dump(by verilator) with 8 threads";
	@echo "    make cleanVerilator		   			: clean the verilator generated file before Verilator operations";
	@echo "    make compile SIM=verilator DUMP=on THREADS=8  	: run compile with dump (by Verilator with dump) with 8 threads";
	@echo "    make buildVerilator             			: run build executable file with Verilator";
	@echo "    make runVerilator	           			: run simulation file with Verilator";
	@echo "    make docker-create              			: create container $(DOCKER_CONTAINER)";
	@echo "    make docker-deps                			: install bundled QEMU runtime dependencies";
	@echo "    make docker-shell               			: enter container shell at $(DOCKER_WORKDIR)";
	@echo "    make docker-qemu-test           			: verify Xuantie QEMU dynamic libraries";
