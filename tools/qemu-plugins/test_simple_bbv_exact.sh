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
        bash -lc "cd /work/tools/qemu-plugins && ./test_simple_bbv_exact.sh"
fi

CC="${GCC_GLIBC}/bin/riscv64-unknown-linux-gnu-gcc"
PLUGIN="${SCRIPT_DIR}/simple_bbv.so"
TMP="$(mktemp -d)"
trap 'rm -rf "${TMP}"' EXIT

"${CC}" -O2 -static -no-pie \
  "${SCRIPT_DIR}/testdata/bbv_exact_guest.c" -o "${TMP}/bbv_exact_guest"

"${QEMU}" -R 0x4000000000 -cpu c910 -L "${SYSROOT}" \
  -plugin "${PLUGIN},interval=10000,outfile=${TMP}/locked.bb,mapfile=${TMP}/locked.map" \
  "${TMP}/bbv_exact_guest" >"${TMP}/locked.out"

"${QEMU}" -R 0x4000000000 -cpu c910 -L "${SYSROOT}" \
  -plugin "${PLUGIN},interval=10000,outfile=${TMP}/single.bb,mapfile=${TMP}/single.map,single_thread=1,map_interval=1" \
  "${TMP}/bbv_exact_guest" >"${TMP}/single.out"

cmp "${TMP}/locked.out" "${TMP}/single.out"
cmp "${TMP}/locked.bb" "${TMP}/single.bb"
cmp "${TMP}/locked.map" "${TMP}/single.map"

printf '[exact-test] intervals=%s blocks=%s locked=single_thread=yes\n' \
  "$(grep -c '^T' "${TMP}/single.bb")" \
  "$(wc -l <"${TMP}/single.map")"
