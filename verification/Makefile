PYTHON ?= python3
PYTHON311 ?= python3.11
VERIFY := $(PYTHON) ./c910_verify.py
OUT ?= $(CURDIR)/out
SMOKE_ELF := $(OUT)/build/rv64gc_harness_smoke.elf
ACT4_ROOT := $(CURDIR)/.deps/riscv-arch-test
ACT4_VENV := $(CURDIR)/.venv-act4
RISCV_DV_ROOT := $(CURDIR)/.deps/riscv-dv
RISCV_DV_VENV := $(CURDIR)/.venv-riscv-dv
QEMU_ROOT ?= $(abspath ../toolchains/Xuantie-qemu-x86_64-Ubuntu-20.04-V5.2.8-B20250721-0303)
QEMU_PLUGIN := $(abspath ../tools/qemu-plugins/arch_state.so)
QEMU_CONTAINER ?= openc910-qemu
QEMU_ARGS := --qemu-root $(QEMU_ROOT) --qemu-plugin $(QEMU_PLUGIN) --qemu-container $(QEMU_CONTAINER)
RTL_BUILD := $(OUT)/rtl-build
RTL_SIMV := $(RTL_BUILD)/work/simv
VCS ?= vcs
VCS_JOBS ?= 4
CODE_BASE_PATH := $(abspath ../C910_RTL_FACTORY)
RTL_SOURCES := $(shell find ../smart_run/logical ../C910_RTL_FACTORY/gen_rtl \
  -type f \( -name '*.v' -o -name '*.sv' -o -name '*.V' -o -name '*.h' -o -name '*.fl' \))

.PHONY: help doctor deps deps-all act4-python riscv-dv-python python-envs \
  smoke-build smoke-stage smoke-run qemu-plugin smoke-reference smoke-diff \
  rtl-compile static-check

help:
	@printf '%s\n' \
	  'OpenC910 RISC-V DUT verification' \
	  '' \
	  '  make doctor       Check compiler, ELF tools, converter and simv' \
	  '  make deps         Clone pinned ACT4 and riscv-tests sources' \
	  '  make deps-all     Also clone riscv-dv' \
	  '  make python-envs  Create isolated ACT4 and riscv-dv Python environments' \
	  '  make smoke-build  Build the standard RV64GC harness smoke ELF' \
	  '  make smoke-stage  Convert the smoke ELF to smart_run images' \
	  '  make smoke-run    Run the smoke ELF on the verification C910 simv' \
	  '  make qemu-plugin  Build the XuanTie QEMU architectural-state plugin' \
	  '  make smoke-reference  Run the smoke ELF on XuanTie QEMU c910' \
	  '  make smoke-diff   Run the same smoke ELF on RTL/QEMU and compare GPRs' \
	  '  make rtl-compile  Compile an isolated no-wave VCS simv under out/' \
	  '  make static-check Check Python syntax and CLI parsing'

doctor:
	$(VERIFY) doctor --simv $(RTL_SIMV)

deps:
	$(PYTHON) ./setup_deps.py

deps-all:
	$(PYTHON) ./setup_deps.py --all

act4-python: deps
	$(PYTHON311) -m venv $(ACT4_VENV)
	$(ACT4_VENV)/bin/python -m pip install --disable-pip-version-check \
	  -e $(ACT4_ROOT)/framework \
	  -e $(ACT4_ROOT)/generators/testgen \
	  -e $(ACT4_ROOT)/generators/coverage

riscv-dv-python: deps-all
	$(PYTHON311) -m venv $(RISCV_DV_VENV)
	$(RISCV_DV_VENV)/bin/python -m pip install --disable-pip-version-check \
	  -r $(RISCV_DV_ROOT)/requirements.txt \
	  -e $(RISCV_DV_ROOT)

python-envs: act4-python riscv-dv-python

smoke-build:
	$(VERIFY) build-smoke --output $(SMOKE_ELF)

smoke-stage: smoke-build
	$(VERIFY) stage $(SMOKE_ELF) --name rv64gc_harness_smoke --out $(OUT)/cases --force

smoke-run: smoke-build
	$(VERIFY) run $(SMOKE_ELF) --name rv64gc_harness_smoke --out $(OUT)/cases \
	  --simv $(RTL_SIMV) --force

qemu-plugin:
	$(MAKE) -C ../tools/qemu-plugins arch_state.so QEMU_ROOT=$(QEMU_ROOT)

smoke-reference: smoke-build qemu-plugin
	$(VERIFY) reference $(SMOKE_ELF) --name rv64gc_harness_smoke \
	  --out $(OUT)/reference $(QEMU_ARGS) --force

# This target invokes the existing EDA simulator, then runs QEMU and compares
# the terminal architectural GPR state. It is intentionally not a dependency
# of smoke-reference or static-check.
smoke-diff: smoke-build qemu-plugin rtl-compile
	$(VERIFY) run-diff $(SMOKE_ELF) --name rv64gc_harness_smoke \
	  --out $(OUT)/differential --simv $(RTL_SIMV) $(QEMU_ARGS) --force

# This is the only target that invokes an EDA compiler. It is a dependency of
# smoke-diff because the terminal-state exporter is compiled into the testbench.
# It is never a dependency of doctor, deps, smoke-build, smoke-stage, or the
# QEMU-only smoke-reference target.
rtl-compile: $(RTL_SIMV)

$(RTL_SIMV): $(RTL_SOURCES) ./config/symbols.svh Makefile
	rm -rf $(RTL_BUILD)
	mkdir -p $(RTL_BUILD)/work
	cp -a ../smart_run/logical $(RTL_BUILD)/logical
	cp ./config/symbols.svh $(RTL_BUILD)/work/symbols.svh
	cd $(RTL_BUILD)/work && CODE_BASE_PATH=$(CODE_BASE_PATH) nice -n 15 $(VCS) \
	  -full64 -sverilog -Mupdate -j$(VCS_JOBS) -lca +nospecify \
	  +notimingchecks +lint=TFIPC-L -timescale=1ns/100fs \
	  +define+no_warning +define+TSMC_NO_WARNING \
	  -f ../logical/filelists/sim.fl +define+NO_DUMP -l comp.vcs.log

static-check:
	$(PYTHON) -m py_compile c910_verify.py qemu_reference.py setup_deps.py
	PYTHONPATH=. $(PYTHON) -m unittest -v test_qemu_reference.py
	$(VERIFY) --help >/dev/null
