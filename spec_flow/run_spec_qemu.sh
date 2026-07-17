#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/env.sh"

BENCH="${1:-505.mcf_r}"
SIZE="${2:-test}"
ACTION="${3:-run}"
LOG="${SPEC_RUN_ROOT}/logs/${BENCH}_${SIZE}_${ACTION}.log"

"${SCRIPT_DIR}/write_config.sh"

cd "${SPEC_ROOT}"
source shrc

echo "[run] bench=${BENCH} size=${SIZE} action=${ACTION}"
echo "[run] config=${SPEC_ROOT}/config/c910-gcc-linux.cfg"
echo "[run] submit=${QEMU} -cpu c910 -L ${SYSROOT} <SPEC command>"

runcpu \
  --config=c910-gcc-linux \
  --size="${SIZE}" \
  --tune=base \
  --action="${ACTION}" \
  --noreportable \
  "${BENCH}" 2>&1 | tee "${LOG}"

chmod -R a+rwX "${SPEC_RUN_ROOT}" "${SPEC_ROOT}/result" "${SPEC_ROOT}/benchspec/CPU/${BENCH}/run" 2>/dev/null || true
echo "[run] log=${LOG}"
