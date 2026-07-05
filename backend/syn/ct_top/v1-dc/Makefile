SHELL := /usr/bin/env bash

ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))
REPO_ROOT := $(abspath $(ROOT_DIR)/../../../..)

RUN_DIR := $(ROOT_DIR)/run
DC_TCL := $(ROOT_DIR)/global_scripts/dc.tcl
SETUP_FILE := $(RUN_DIR)/.synopsys_dc.setup
DC_FILELIST := $(REPO_ROOT)/backend/flist/ct_top_dc.f
SRAM_DIR := $(REPO_ROOT)/backend/sram
SRAM_DB_SETUP := $(SRAM_DIR)/generated/c910_sram_db.tcl

CODE_BASE_PATH ?= $(REPO_ROOT)/C910_RTL_FACTORY
DC_SHELL ?= dc_shell-t
DC_ARGS ?= -64bit

.PHONY: help check dc

help:
	@echo "C910 ct_top DC synthesis flow"
	@echo ""
	@echo "Targets:"
	@echo "  make -C backend/syn/ct_top/v1-dc check"
	@echo "  make -C backend/syn/ct_top/v1-dc dc"
	@echo ""
	@echo "Variables:"
	@echo "  CODE_BASE_PATH=$(CODE_BASE_PATH)"
	@echo "  DC_SHELL=$(DC_SHELL)"
	@echo "  DC_ARGS=$(DC_ARGS)"

check:
	@test -f "$(DC_TCL)" || { echo "missing $(DC_TCL)"; exit 1; }
	@test -f "$(SETUP_FILE)" || { echo "missing $(SETUP_FILE)"; exit 1; }
	@test -f "$(DC_FILELIST)" || { echo "missing $(DC_FILELIST)"; exit 1; }
	@test -f "$(SRAM_DB_SETUP)" || { echo "missing $(SRAM_DB_SETUP)"; exit 1; }
	@$(MAKE) -C "$(SRAM_DIR)" verify-generated
	@echo "OK: ct_top DC inputs are present"

dc: check
	@echo "Running DC for ct_top"
	@cd "$(RUN_DIR)" && \
	  CODE_BASE_PATH="$(CODE_BASE_PATH)" \
	  DC_SHELL="$(DC_SHELL)" \
	  DC_ARGS="$(DC_ARGS)" \
	  ./run.cmd
