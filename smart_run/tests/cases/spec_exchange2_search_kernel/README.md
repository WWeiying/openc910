# spec_exchange2_search_kernel

`spec_exchange2_search_kernel` models the branch-heavy recursive search shape
of `548.exchange2_r`: move generation, move ordering, alpha-beta pruning,
history updates, and transposition-table probing.

It is not SPEC source code and is not an exact SimPoint checkpoint.

Default configuration:

```text
SPEC_EXCHANGE2_POSITIONS=1
SPEC_EXCHANGE2_DEPTH=2
SPEC_EXCHANGE2_MOVES=6
SPEC_EXCHANGE2_TABLE=64
```

Build and run:

```bash
make buildcase CASE=spec_exchange2_search_kernel DUMP=off
make simcase CASE=spec_exchange2_search_kernel DUMP=off
```

Representative build:

```bash
make buildcase CASE=spec_exchange2_search_kernel DUMP=off SPEC_EXCHANGE2_REPRESENTATIVE=1
```
