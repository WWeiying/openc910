# spec_mcf_sort_kernel

`spec_mcf_sort_kernel` is a compact bare-metal kernel for the dominant
`505.mcf_r test` SimPoint phase.  The L1 function profile shows cluster 0 is
mostly `spec_qsort`, `cost_compare`, and `primal_bea_mpp`; this case models the
sort/comparator-heavy part without copying SPEC source code.

Default configuration:

```text
SPEC_MCF_SORT_ITEMS=96
SPEC_MCF_SORT_PASSES=1
```

Build and run:

```bash
make buildcase CASE=spec_mcf_sort_kernel DUMP=off
make simcase CASE=spec_mcf_sort_kernel DUMP=off
```

Larger stress example:

```bash
make buildcase CASE=spec_mcf_sort_kernel DUMP=off \
  SPEC_MCF_SORT_ITEMS=192 SPEC_MCF_SORT_PASSES=2
make simcase CASE=spec_mcf_sort_kernel DUMP=off
```

