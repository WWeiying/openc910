#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"
source "${REPO_ROOT}/spec_flow/env.sh"

if ! "${QEMU}" --version >/dev/null 2>&1; then
    if [[ "${QEMU_PLUGIN_TEST_CONTAINER:-0}" == 1 ]]; then
        echo "ERROR: Xuantie QEMU is not runnable inside the test container" >&2
        exit 1
    fi
    CONTAINER="${DOCKER_CONTAINER:-openc910-qemu}"
    if ! docker inspect -f '{{.State.Running}}' "${CONTAINER}" 2>/dev/null |
            grep -qx true; then
        echo "ERROR: Xuantie QEMU is not runnable and ${CONTAINER} is not running" >&2
        exit 1
    fi
    exec docker exec -e QEMU_PLUGIN_TEST_CONTAINER=1 "${CONTAINER}" \
        bash -lc "cd /work/tools/qemu-plugins && ./test_simple_bbv_fork.sh"
fi

CC="${GCC_GLIBC}/bin/riscv64-unknown-linux-gnu-gcc"
PLUGIN="${SCRIPT_DIR}/simple_bbv.so"
TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT

"${CC}" -O2 "${SCRIPT_DIR}/testdata/fork_guest.c" -o "${TMP}/fork_guest"
"${QEMU}" -R 0x4000000000 -cpu c910 -L "${SYSROOT}" \
  -plugin "${PLUGIN},interval=10000,outfile=${TMP}/fork.bb,mapfile=${TMP}/fork.map,append=1,pid_namespace=1" \
  "${TMP}/fork_guest" | grep -qx 'fork-ok'

python3 - "${TMP}/fork.map" <<'PY'
import sys
from pathlib import Path

keys = {}
namespaces = set()
for line_no, line in enumerate(Path(sys.argv[1]).open(), 1):
    fields = line.split()
    if len(fields) < 3:
        continue
    raw_id = int(fields[0])
    key = (int(fields[1], 16), int(fields[2]))
    previous = keys.setdefault(raw_id, key)
    if previous != key:
        raise SystemExit(f"raw ID conflict at line {line_no}: {raw_id}")
    namespaces.add((raw_id - 1) >> 32)
if len(namespaces) < 2:
    raise SystemExit(f"expected at least two PID namespaces, got {namespaces}")
print(f"[fork-test] raw_ids={len(keys)} pid_namespaces={len(namespaces)}")
PY

python3 "${REPO_ROOT}/spec_flow/compact_bbv_ids.py" \
  --bbv "${TMP}/fork.bb" --map "${TMP}/fork.map" \
  --start-id 1 --id-stride 4294967296

python3 - "${TMP}/fork.map" <<'PY'
import sys
from pathlib import Path

ids = [int(line.split()[0]) for line in Path(sys.argv[1]).open() if line.split()]
if ids != list(range(1, len(ids) + 1)):
    raise SystemExit("compacted BBV map IDs are not contiguous")
print(f"[fork-test] compact_ids=1..{len(ids)} contiguous=yes")
PY
