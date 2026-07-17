#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/env.sh"

BENCH="${1:?usage: $0 BENCH SIZE [MAX_K] [INTERVAL]}"
SIZE="${2:?usage: $0 BENCH SIZE [MAX_K] [INTERVAL]}"
MAX_K="${3:-5}"
INTERVAL="${4:-100000000}"
OUT_DIR="${SPEC_RUN_ROOT}/${BENCH}_${SIZE}_c910"
STEM="${BENCH}_${SIZE}"
BBV_FILE="${OUT_DIR}/${STEM}.bb"
BBV_MAP="${OUT_DIR}/${STEM}.bb.map"
BBV_CMDMAP="${OUT_DIR}/${STEM}.bb.cmdmap"
BBV_MODULES="${OUT_DIR}/${STEM}.bb.modules"
SIMPOINTS="${OUT_DIR}/${STEM}.simpoints"
WEIGHTS="${OUT_DIR}/${STEM}.weights"
PROFILE="${OUT_DIR}/${STEM}.function_profile.csv"
MANIFEST="${OUT_DIR}/manifest.json"
NM="${NM:-${GCC_GLIBC}/bin/riscv64-unknown-linux-gnu-nm}"

for file in "${BBV_FILE}" "${BBV_MAP}" "${BBV_CMDMAP}" "${BBV_MODULES}"; do
  if [[ ! -s "${file}" ]]; then
    echo "ERROR: missing required BBV artifact: ${file}" >&2
    exit 1
  fi
done

RUN_DIR="$(spec_find_run_dir "${BENCH}" "${SIZE}" "${SPEC_BENCH_SUITE:-}")"
if [[ -z "${RUN_DIR}" || ! -d "${RUN_DIR}" ]]; then
  echo "ERROR: missing SPEC run directory for ${BENCH}/${SIZE}" >&2
  exit 1
fi

cd "${SPEC_ROOT}"
source shrc
cd "${RUN_DIR}"

mapfile -t EXPECTED_COMMANDS < <(
  specinvoke -n speccmds.cmd | awk '!/^#/ && NF && $1 != "specinvoke" {print}'
)
if [[ "${#EXPECTED_COMMANDS[@]}" -eq 0 ]]; then
  echo "ERROR: no commands found in ${RUN_DIR}/speccmds.cmd" >&2
  exit 1
fi
python3 "${SCRIPT_DIR}/check_completed_bbv.py" \
  --bbv "${BBV_FILE}" --map "${BBV_MAP}" --cmdmap "${BBV_CMDMAP}" \
  --modules "${BBV_MODULES}" --expected-commands "${#EXPECTED_COMMANDS[@]}"

ELF="$(awk -F '\t' 'NR == 2 {print $4}' "${BBV_CMDMAP}")"
if [[ ! -f "${ELF}" ]]; then
  echo "ERROR: missing ELF from cmdmap: ${ELF}" >&2
  exit 1
fi

echo "[finalize] compare ${BENCH}/${SIZE}"
{
  echo "[compare] command source=compare.cmd"
  echo "[compare] recovery from completed BBV"
} >"${OUT_DIR}/compare.log"
mapfile -t COMPARE_LINES < <(specinvoke -n compare.cmd | awk '!/^#/ && NF && $1 != "specinvoke" {print}')
COMPARE_RC=0
COMPARE_INDEX=0
for COMPARE_LINE in "${COMPARE_LINES[@]}"; do
  EXE_TOKEN="$(awk '{print $1}' <<<"${COMPARE_LINE}")"
  if [[ "${EXE_TOKEN}" = /* ]]; then
    EXE_PATH="${EXE_TOKEN}"
  else
    EXE_PATH="$(readlink -f "${EXE_TOKEN}")"
  fi
  if [[ -f "${EXE_PATH}" ]] && file "${EXE_PATH}" | grep -qi 'RISC-V'; then
    COMPARE_LINE="\"${QEMU}\" -R \"${QEMU_RESERVED_VA:-0x4000000000}\" -cpu c910 -L \"${SYSROOT}\" ${COMPARE_LINE}"
  fi
  echo "[compare] command[${COMPARE_INDEX}]=${COMPARE_LINE}" >>"${OUT_DIR}/compare.log"
  if ! eval "${COMPARE_LINE}" >>"${OUT_DIR}/compare.log" 2>&1; then
    COMPARE_RC=1
  fi
  COMPARE_INDEX=$((COMPARE_INDEX + 1))
done
echo "[compare] exit: rc=${COMPARE_RC}" >>"${OUT_DIR}/compare.log"

echo "[finalize] SimPoint ${BENCH}/${SIZE}"
"${SIMPOINT}" -maxK "${MAX_K}" -loadFVFile "${BBV_FILE}" \
  -saveSimpoints "${SIMPOINTS}" -saveSimpointWeights "${WEIGHTS}" \
  >"${OUT_DIR}/simpoint.log" 2>&1
if [[ ! -s "${SIMPOINTS}" || ! -s "${WEIGHTS}" ]]; then
  echo "ERROR: SimPoint did not produce output" >&2
  exit 1
fi

PROFILE_CMD=(
  python3 "${SCRIPT_DIR}/analyze_bbv_functions.py"
  --bbv "${BBV_FILE}" --map "${BBV_MAP}" --elf "${ELF}"
  --cmdmap "${BBV_CMDMAP}" --simpoints "${SIMPOINTS}" --weights "${WEIGHTS}"
  --nm "${NM}" --top "${PROFILE_TOP:-20}" --out "${PROFILE}"
)
if [[ -s "${BBV_MODULES}" ]]; then
  PROFILE_CMD+=(--modules "${BBV_MODULES}")
fi
"${PROFILE_CMD[@]}" | tee "${OUT_DIR}/function_profile.log"

python3 "${SCRIPT_DIR}/make_simpoint_manifest.py" \
    --bench "${BENCH}" --size "${SIZE}" --out-dir "${OUT_DIR}" \
    --interval "${INTERVAL}" --max-k "${MAX_K}" \
    --bbv-id-stride "${SPEC_BBV_ID_STRIDE}" \
  --qemu-reserved-va "${QEMU_RESERVED_VA:-0x4000000000}" \
  --qemu-path "${QEMU}" \
  --compiler-path "${GCC_GLIBC}/bin/riscv64-unknown-linux-gnu-gcc" \
  --simpoint-path "${SIMPOINT}" \
  --optimize "${C910_OPT} -march=${C910_MARCH} -mabi=${C910_MABI} -mtune=${C910_MTUNE} -fcommon" \
  --out "${MANIFEST}"

echo "[finalize] done manifest=${MANIFEST} compare_rc=${COMPARE_RC}"
exit "${COMPARE_RC}"
