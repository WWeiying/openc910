SHELL := /usr/bin/env bash

ROOT_DIR := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

SRAM_CONFIG ?= $(ROOT_DIR)/config/ct_top_sram.tsv

PD127_SPSRAM_COMPILER_DIR ?= /home/wangwy/technical_library/tsmc28nm/Memory/tsn28hpcpd127spsram_20120200_180a/AN61001_20180416/tsn28hpcpd127spsram_20120200_180a/TSMCHOME/sram/Compiler/tsn28hpcpd127spsram_20120200_180a/tsn28hpcpd127spsram_20120200_180a
PUHD_SPSRAM_COMPILER_DIR  ?= /home/wangwy/technical_library/tsmc28nm/Memory/tsn28hpcpuhdspsram_20120200_170a/AN61001_20180125/tsn28hpcpuhdspsram_20120200_170a/TSMCHOME/sram/Compiler/tsn28hpcpuhdspsram_20120200_170a/tsn28hpcpuhdspsram_20120200_170a

LC_SHELL ?= lc_shell
SRAM_DB_CORNER ?= tt0p9v25c
DC_SRAM_SETUP ?= $(ROOT_DIR)/generated/c910_sram_db.tcl
CONVERT_TCL ?= $(ROOT_DIR)/generated/convert_script.tcl

SRAM_CFG := $(ROOT_DIR)/scripts/sram_cfg.py \
  --config $(SRAM_CONFIG) \
  --puhd-dir $(PUHD_SPSRAM_COMPILER_DIR) \
  --pd127-dir $(PD127_SPSRAM_COMPILER_DIR) \
  --corner $(SRAM_DB_CORNER)

.PHONY: help check-config print-config list-db list-verilog status verify-generated write-configs dc-db-setup sram

help:
	@echo "C910 SRAM preparation flow"
	@echo ""
	@echo "Read-only targets:"
	@echo "  make -C backend/sram check-config"
	@echo "  make -C backend/sram print-config"
	@echo "  make -C backend/sram list-db"
	@echo "  make -C backend/sram list-verilog"
	@echo "  make -C backend/sram status"
	@echo "  make -C backend/sram verify-generated"
	@echo ""
	@echo "Generated setup target:"
	@echo "  make -C backend/sram dc-db-setup"
	@echo ""
	@echo "EDA target:"
	@echo "  make -C backend/sram sram"

check-config:
	@$(SRAM_CFG) check

print-config:
	@$(SRAM_CFG) print

list-db:
	@$(SRAM_CFG) list-db

list-verilog:
	@$(SRAM_CFG) list-verilog

status:
	@$(SRAM_CFG) status

verify-generated:
	@$(SRAM_CFG) verify-generated

write-configs: check-config
	@$(SRAM_CFG) write-configs

dc-db-setup: check-config
	@$(SRAM_CFG) dc-db-setup --out $(DC_SRAM_SETUP)

sram: check-config
	@$(SRAM_CFG) write-configs
	@if [ -s "$(PD127_SPSRAM_COMPILER_DIR)/config.txt" ]; then \
	  echo "Running PD127 SPSRAM compiler"; \
	  cd "$(PD127_SPSRAM_COMPILER_DIR)" && ./run.sh; \
	else \
	  echo "Skipping PD127 SPSRAM compiler: empty config"; \
	fi
	@if [ -s "$(PUHD_SPSRAM_COMPILER_DIR)/config.txt" ]; then \
	  echo "Running PUHD SPSRAM compiler"; \
	  cd "$(PUHD_SPSRAM_COMPILER_DIR)" && ./run.sh; \
	else \
	  echo "Skipping PUHD SPSRAM compiler: empty config"; \
	fi
	@$(SRAM_CFG) write-convert-tcl --out $(CONVERT_TCL)
	@echo "Running $(LC_SHELL)"
	@cd "$(ROOT_DIR)" && $(LC_SHELL) -f $(CONVERT_TCL)
	@$(SRAM_CFG) verify-generated
