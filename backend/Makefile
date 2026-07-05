SHELL := /usr/bin/env bash

.PHONY: help dc dc-ct_top sram-check

help:
	@echo "C910 backend flow"
	@echo ""
	@echo "Targets:"
	@echo "  make -C backend dc"
	@echo "  make -C backend dc-ct_top"
	@echo "  make -C backend sram-check"

dc: dc-ct_top

dc-ct_top:
	@$(MAKE) -C syn/ct_top/v1-dc dc

sram-check:
	@$(MAKE) -C sram verify-generated
