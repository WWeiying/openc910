# spec_deepsjeng_search_kernel

`spec_deepsjeng_search_kernel` models the dominant `531.deepsjeng_r test`
profile: recursive search/qsearch-like control flow, bitboard attack
generation, move ordering, make/unmake style state updates, evaluation, and
transposition-table accesses.

It is not SPEC source code and is not an exact SimPoint checkpoint.

Default configuration:

```text
SPEC_DEEPSJENG_POSITIONS=1
SPEC_DEEPSJENG_DEPTH=1
SPEC_DEEPSJENG_MOVES=8
SPEC_DEEPSJENG_QMOVES=0
```

Build and run:

```bash
make buildcase CASE=spec_deepsjeng_search_kernel DUMP=off
make simcase CASE=spec_deepsjeng_search_kernel DUMP=off
```

Representative build:

```bash
make buildcase CASE=spec_deepsjeng_search_kernel DUMP=off SPEC_DEEPSJENG_REPRESENTATIVE=1
```
