# spec_lbm_stream_kernel

`spec_lbm_stream_kernel` models `519.lbm_r` style lattice-Boltzmann
collide/stream work: D3Q19-like per-cell updates, regular streaming stores, and
high load/store pressure.

It is not SPEC source code and is not an exact SimPoint checkpoint.

Default configuration:

```text
SPEC_LBM_CELLS=24
SPEC_LBM_STEPS=1
SPEC_LBM_Q=19
```

Build and run:

```bash
make buildcase CASE=spec_lbm_stream_kernel DUMP=off
make simcase CASE=spec_lbm_stream_kernel DUMP=off
```

Representative build:

```bash
make buildcase CASE=spec_lbm_stream_kernel DUMP=off SPEC_LBM_REPRESENTATIVE=1
```
