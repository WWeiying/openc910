# spec_parest_dof_kernel

Representative bare-metal model for the DoF, sparsity-pattern construction,
constraint condensation, sorting, and indirect traversal phases visible in
`510.parest_r`. It is not SPEC CPU2017 source code.

The default smoke configuration uses `N=24`, `width=5`, `constraints=4`, and
`passes=1`. `SPEC_PAREST_DOF_REPRESENTATIVE=1` uses the validated larger
`N=64`, `width=8`, `constraints=12`, and `passes=2` configuration.

```sh
make -C smart_run simcase CASE=spec_parest_dof_kernel DUMP=off
make -C smart_run simcase CASE=spec_parest_dof_kernel DUMP=off \
  SPEC_PAREST_DOF_REPRESENTATIVE=1
```
