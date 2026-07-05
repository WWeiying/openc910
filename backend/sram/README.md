# C910 SRAM Preparation

This directory mirrors the SRAM preparation flow used by `ara_hdv`, but the
configuration is rebuilt around the SRAM ranges supported by the local TSMC
28 nm memory compilers.

The flow is table driven:

- `config/ct_top_sram.tsv`: logical C910 `ct_top` SRAM wrappers and the
  physical TSMC macro configuration used for each wrapper.
- `scripts/sram_cfg.py`: validates the table, deduplicates physical macros,
  emits compiler `config.txt`, generates DC `.db` setup, and writes the
  Library Compiler conversion TCL.
- `Makefile`: thin command wrapper around `sram_cfg.py`.

## Supported Compiler Ranges

These ranges were taken from the local compiler databooks:

- `tsn28hpcpuhdspsram_20120200_170a`
  - PUHD single-port SRAM, macro size 128 bits..288 Kbits.
  - mux1: depth 8..128 step 4, width 16..288 step 2.
  - mux2: depth 16..256 step 8, width 8..144 step 1.
  - mux4: depth 32..2048 step 16, width 8..144 step 1.

- `tsn28hpcpd127spsram_20120200_180a`
  - PD127 single-port SRAM, macro size 256 bits..1 Mbit.
  - mux4: depth 32..8192 step 16, width 8..144 step 1.
  - mux8: depth 64..16384 step 32, width 4..72 step 1.
  - mux16: depth 4096..32768 step 64, width 2..39 step 1.
  - `depth / mux` values 260, 772, 1284, and 1796 are unsupported.

## Commands

Read-only checks:

```sh
make -C backend/sram check-config
make -C backend/sram print-config
make -C backend/sram list-db
make -C backend/sram list-verilog
make -C backend/sram status
```

Generate the DC SRAM DB setup file:

```sh
make -C backend/sram dc-db-setup
```

Run the SRAM generation flow:

```sh
make -C backend/sram sram
```

`make sram` writes compiler `config.txt` files, runs the TSMC memory compilers,
then converts generated `NLDM/*.lib` files to `.db` using `lc_shell`, and finally
runs `make verify-generated` to ensure macro directories plus the selected
corner `.db` and `.v` files exist.  Do not run it inside a sandboxed
environment.

## Current C910 Notes

Most `ct_top` SRAMs map to PUHD macros.  Irregular logical widths are rounded
up to a nearby regular macro width instead of generating exact odd-width macros:

- `512x22` -> `512x24`
- `512x44` -> `512x48`
- `256x23` -> `256x24`
- `512x59` -> `512x64`
- `512x52` and `512x54` -> `512x56`
- `512x7` -> `512x8`
- `256x84` -> `256x88`
- `256x196` -> two `256x104` macros

The C910 `ct_top` SRAM wrappers now select the SRAM implementation with
`C910_USE_TSMC_SRAM`:

- without `C910_USE_TSMC_SRAM`: original `ct_f_spsram_*` / `fpga_ram`
  behavioural path.
- with `C910_USE_TSMC_SRAM`: `ct_spsram_*` instantiates
  `ct_tsmc_spsram`, which maps the C910 active-low `CEN/GWEN/WEN` interface to
  generated TSMC PUHD macros.

Extra write-data bits are tied low, extra write-mask bits are kept inactive,
and extra read-data bits are ignored.

The migrated `ct_top` DC filelist enables `C910_USE_TSMC_SRAM`, and the DC
setup uses `GUI_IP_LIBRARY "c910sram"` so the generated SRAM `.db` files are in
the link library.

The rounded-up C910 SRAM macros are not currently present in the local
`Memory` tree before generation.  Use `make status` to inspect this and
`make verify-generated` after generation to fail if any expected output is
missing.
