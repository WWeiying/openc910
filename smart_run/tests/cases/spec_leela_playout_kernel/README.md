# spec_leela_playout_kernel

`spec_leela_playout_kernel` models the dominant `541.leela_r test` profile:
random playout move selection, board-neighbor checks, pattern lookup,
self-atari/no-eye-fill filtering, board updates, and UCT child selection.

It is not SPEC source code and is not an exact SimPoint checkpoint.

Default configuration:

```text
SPEC_LEELA_BOARD=13
SPEC_LEELA_PLAYOUTS=2
SPEC_LEELA_MOVES=12
SPEC_LEELA_CHILDREN=16
```

Build and run:

```bash
make buildcase CASE=spec_leela_playout_kernel DUMP=off
make simcase CASE=spec_leela_playout_kernel DUMP=off
```

Representative build:

```bash
make buildcase CASE=spec_leela_playout_kernel DUMP=off SPEC_LEELA_REPRESENTATIVE=1
```
