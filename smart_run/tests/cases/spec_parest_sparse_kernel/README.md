# spec_parest_sparse_kernel

`spec_parest_sparse_kernel` models `510.parest_r` style finite-element sparse
solver behavior: CSR-like sparse matrix-vector multiply, indirect loads,
dot-product reductions, and iterative update branches.

It is not SPEC source code and is not an exact SimPoint checkpoint.

Default configuration:

```text
SPEC_PAREST_N=48
SPEC_PAREST_NNZ_PER_ROW=5
SPEC_PAREST_ITERS=3
```

Build and run:

```bash
make buildcase CASE=spec_parest_sparse_kernel DUMP=off
make simcase CASE=spec_parest_sparse_kernel DUMP=off
```

Representative build:

```bash
make buildcase CASE=spec_parest_sparse_kernel DUMP=off SPEC_PAREST_REPRESENTATIVE=1
```
