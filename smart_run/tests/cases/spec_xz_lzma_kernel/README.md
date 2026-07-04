# spec_xz_lzma_kernel

`spec_xz_lzma_kernel` models the dominant `557.xz_r test` behavior seen in
the SimPoint/function profile: LZMA match finding, hash-chain traversal,
price-table updates, and byte checksum/transform work.

It is not SPEC source code and is not an exact SimPoint checkpoint.

Default configuration:

```text
SPEC_XZ_BYTES=512
SPEC_XZ_DICT=1024
SPEC_XZ_PASSES=1
SPEC_XZ_PROBES=12
SPEC_XZ_RANGE_STEPS=4
```

Build and run:

```bash
make buildcase CASE=spec_xz_lzma_kernel DUMP=off
make simcase CASE=spec_xz_lzma_kernel DUMP=off
```

Representative build:

```bash
make buildcase CASE=spec_xz_lzma_kernel DUMP=off SPEC_XZ_REPRESENTATIVE=1
```
