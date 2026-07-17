# spec_pop2_ocean_kernel

Bare-metal representative kernel for the dominant `628.pop2_s train` ocean
model phases. It models horizontal mixing, state updates, tracer advection,
baroclinic recurrence, and a small iterative barotropic operator. It is not
SPEC CPU2017 source code and does not produce an official SPEC score.

Default smoke configuration:

```sh
make -C smart_run simcase CASE=spec_pop2_ocean_kernel DUMP=off
```

Larger representative configuration:

```sh
make -C smart_run simcase CASE=spec_pop2_ocean_kernel DUMP=off \
  SPEC_POP2_REPRESENTATIVE=1
```
