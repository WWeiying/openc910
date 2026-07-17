#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/env.sh"

BENCH="${1:-505.mcf_r}"
SIZE="${2:-test}"
TARGET="${3:-1}"
INTERVAL="${4:-100000}"
OUT_DIR="${SPEC_RUN_ROOT}/${BENCH}_${SIZE}_c910"
PROBE_PLUGIN_LOCAL="${PROBE_PLUGIN_LOCAL:-${REPO_ROOT}/tools/qemu-plugins/simpoint_probe.so}"
OUT_FILE="${OUT_DIR}/${BENCH}_${SIZE}.probe.regs"

mkdir -p "${OUT_DIR}"

"${SCRIPT_DIR}/write_config.sh"

if [[ ! -f "${PROBE_PLUGIN_LOCAL}" ]]; then
  make -C "${REPO_ROOT}/tools/qemu-plugins" QEMU_ROOT="${QEMU_ROOT}" simpoint_probe.so
fi

cd "${SPEC_ROOT}"
source shrc

runcpu \
  --config=c910-gcc-linux \
  --size="${SIZE}" \
  --tune=base \
  --action=runsetup \
  --noreportable \
  "${BENCH}" >"${OUT_DIR}/probe_runsetup.log" 2>&1

RUN_DIR="$(spec_find_run_dir "${BENCH}" "${SIZE}" "${SPEC_BENCH_SUITE:-}")"
if [[ -z "${RUN_DIR}" || ! -d "${RUN_DIR}" ]]; then
  echo "Run directory not found for ${BENCH} ${SIZE}" >&2
  exit 1
fi

cd "${RUN_DIR}"
COMMAND_LINE="$(specinvoke -n speccmds.cmd | awk '!/^#/ && NF && $1 != "specinvoke" {print; exit}')"
if [[ -z "${COMMAND_LINE}" ]]; then
  echo "Unable to extract command from speccmds.cmd" >&2
  exit 1
fi

SUBMIT_PREFIX="${QEMU} -cpu c910 -L ${SYSROOT} "
if [[ "${COMMAND_LINE}" == "${SUBMIT_PREFIX}"* ]]; then
  COMMAND_LINE="${COMMAND_LINE#${SUBMIT_PREFIX}}"
fi

rm -f "${OUT_FILE}"

echo "[probe] run_dir=${RUN_DIR}" | tee "${OUT_DIR}/probe.log"
echo "[probe] command=${COMMAND_LINE}" | tee -a "${OUT_DIR}/probe.log"
echo "[probe] interval=${INTERVAL} target=${TARGET} outfile=${OUT_FILE}" | tee -a "${OUT_DIR}/probe.log"

eval "\"${QEMU}\" -cpu c910 -L \"${SYSROOT}\" -plugin \"${PROBE_PLUGIN_LOCAL}\",interval=${INTERVAL},target=${TARGET},outfile=\"${OUT_FILE}\",exit_after=1 ${COMMAND_LINE}" \
  >>"${OUT_DIR}/probe.log" 2>&1

chmod -R a+rwX "${OUT_DIR}" "${RUN_DIR}" 2>/dev/null || true

echo "[done] probe=${OUT_FILE}"
