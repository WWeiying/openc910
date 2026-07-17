# spec_fotonik3d_stencil_kernel

Models the electric/magnetic field updates, material coefficients, UPML
boundary work, and power-DFT accumulation visible in `549.fotonik3d_r` and
`649.fotonik3d_s`. This is a representative RTL kernel, not SPEC source.

```sh
make -C smart_run simcase CASE=spec_fotonik3d_stencil_kernel DUMP=off
make -C smart_run simcase CASE=spec_fotonik3d_stencil_kernel DUMP=off \
  SPEC_FOTONIK_REPRESENTATIVE=1
```
