# spec_mcf_kernel

`spec_mcf_kernel` is a compact bare-metal kernel for the first SPEC-to-RTL
path.  It is shaped after the pointer-rich arc scan and basket selection behavior
seen in SPEC CPU2017 `505.mcf_r`, but it is not SPEC source code and is not a
SimPoint interval.

Default smoke configuration:

```text
SPEC_MCF_NODES=32
SPEC_MCF_ARCS=96
SPEC_MCF_BASKET=8
SPEC_MCF_PASSES=1
```

Build and run:

```bash
make buildcase CASE=spec_mcf_kernel DUMP=off
make simcase CASE=spec_mcf_kernel DUMP=off
```

Larger RTL stress example:

```bash
make buildcase CASE=spec_mcf_kernel DUMP=off \
  SPEC_MCF_NODES=64 SPEC_MCF_ARCS=256 SPEC_MCF_BASKET=16 SPEC_MCF_PASSES=2
make simcase CASE=spec_mcf_kernel DUMP=off
```

The RTL testbench reads `work/symbols.args` through `+sym_*` plusargs, so changing
this kernel does not require recompiling RTL after the plusargs-aware `simv` has
been built once.
