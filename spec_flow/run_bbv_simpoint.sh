#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/env.sh"

BENCH="${1:-505.mcf_r}"
SIZE="${2:-test}"
MAX_K="${3:-10}"
INTERVAL="${4:-${BBV_INTERVAL}}"
SPEC_RUN_SUFFIX="${SPEC_RUN_SUFFIX:-}"
OUT_DIR="${SPEC_RUN_ROOT}/${BENCH}_${SIZE}_c910${SPEC_RUN_SUFFIX}"
BBV_PLUGIN_LOCAL="${BBV_PLUGIN_LOCAL:-${REPO_ROOT}/tools/qemu-plugins/simple_bbv.so}"
NM="${NM:-${GCC_GLIBC}/bin/riscv64-unknown-linux-gnu-nm}"
BBV_ID_STRIDE="${SPEC_BBV_ID_STRIDE}"

# pid_namespace=1 encodes the host PID in bits 63:32.  Keep the compactor's
# range width tied to that file-format contract even in a long-lived worker
# that inherited an older SPEC_BBV_ID_STRIDE value.
if [[ "${BENCH}" == "500.perlbench_r" || "${BENCH}" == "600.perlbench_s" ]]; then
  BBV_ID_STRIDE=4294967296
fi

mkdir -p "${OUT_DIR}" "${SPEC_RUN_ROOT}/logs"

"${SCRIPT_DIR}/write_config.sh"

if [[ ! -f "${BBV_PLUGIN_LOCAL}" ]]; then
  make -C "${REPO_ROOT}/tools/qemu-plugins" QEMU_ROOT="${QEMU_ROOT}"
fi

cd "${SPEC_ROOT}"
source shrc

echo "[bbv] build/runsetup ${BENCH} ${SIZE}"
runcpu \
  --config=c910-gcc-linux \
  --size="${SIZE}" \
  --tune=base \
  --action=runsetup \
  --noreportable \
  "${BENCH}" 2>&1 | tee "${OUT_DIR}/runsetup.log"

RUN_DIR="$(spec_find_run_dir "${BENCH}" "${SIZE}" "${SPEC_BENCH_SUITE:-}")"
if [[ -z "${RUN_DIR}" || ! -d "${RUN_DIR}" ]]; then
  echo "Run directory not found for ${BENCH} ${SIZE}" >&2
  exit 1
fi

BBV_FILE="${OUT_DIR}/${BENCH}_${SIZE}.bb"
BBV_MAP="${OUT_DIR}/${BENCH}_${SIZE}.bb.map"
BBV_CMDMAP="${OUT_DIR}/${BENCH}_${SIZE}.bb.cmdmap"
BBV_MODULES="${OUT_DIR}/${BENCH}_${SIZE}.bb.modules"
BBV_COUNTER="${OUT_DIR}/${BENCH}_${SIZE}.bb.counter"
SIMPOINTS="${OUT_DIR}/${BENCH}_${SIZE}.simpoints"
WEIGHTS="${OUT_DIR}/${BENCH}_${SIZE}.weights"
PLUGIN_EXTRA=""
if [[ -n "${BBV_SKIP_INTERVALS:-}" ]]; then
  PLUGIN_EXTRA="${PLUGIN_EXTRA},skip_intervals=${BBV_SKIP_INTERVALS}"
fi
if [[ -n "${BBV_MAX_INTERVALS:-}" ]]; then
  PLUGIN_EXTRA="${PLUGIN_EXTRA},max_intervals=${BBV_MAX_INTERVALS}"
fi

prepare_perlbench_wrapper() {
  local exe real

  exe="$(find "${RUN_DIR}" -maxdepth 1 -type f -name "perlbench_*_base.${SPEC_LABEL}" -print | head -1)"
  if [[ -z "${exe}" ]]; then
    return 0
  fi

  real="${exe}.riscv"
  if [[ ! -f "${real}" ]]; then
    if file "${exe}" | grep -qi 'RISC-V'; then
      mv "${exe}" "${real}"
    else
      return 0
    fi
  fi

  cat >"${exe}" <<'EOF'
#!/usr/bin/env bash
set -euo pipefail

wrapper="$(readlink -f "$0")"
real="${wrapper}.riscv"
argv0="$0"

qemu="${QEMU:?QEMU is not set}"
sysroot="${SYSROOT:?SYSROOT is not set}"
plugin="${SPEC_BBV_PLUGIN_LOCAL:-}"
bbv="${SPEC_BBV_FILE:-}"
map="${SPEC_BBV_MAP:-}"
interval="${SPEC_BBV_INTERVAL:-100000000}"
extra="${SPEC_BBV_PLUGIN_EXTRA:-}"
reserved_va="${SPEC_QEMU_RESERVED_VA:-0x4000000000}"
id_offset="${SPEC_BBV_ID_OFFSET:-0}"

if [[ -n "${plugin}" && -n "${bbv}" && -n "${map}" ]]; then
  exec "${qemu}" -R "${reserved_va}" -cpu c910 -L "${sysroot}" \
    -plugin "${plugin}",interval="${interval}",outfile="${bbv}",mapfile="${map}",id_offset="${id_offset}",append=1,pid_namespace=1"${extra}" \
    -0 "${argv0}" "${real}" "$@"
fi

exec "${qemu}" -R "${reserved_va}" -cpu c910 -L "${sysroot}" -0 "${argv0}" "${real}" "$@"
EOF
  chmod +x "${exe}"
}

find_benchmark_elf() {
  local candidate

  candidate="$(find "${RUN_DIR}" -maxdepth 1 -type f -name "*_base.${SPEC_LABEL}" -print | head -1)"
  if [[ -n "${candidate}" ]]; then
    if [[ -f "${candidate}.riscv" ]]; then
      echo "${candidate}.riscv"
      return 0
    fi
    echo "${candidate}"
    return 0
  fi

  candidate="$(find "${SPEC_ROOT}/benchspec/CPU/${BENCH}/exe" -maxdepth 1 -type f -name "*_base.${SPEC_LABEL}" -print 2>/dev/null | head -1)"
  if [[ -n "${candidate}" ]]; then
    echo "${candidate}"
    return 0
  fi

  candidate="$(find "${RUN_DIR}" -maxdepth 1 -type f -perm -111 -print | head -1)"
  if [[ -n "${candidate}" ]]; then
    echo "${candidate}"
    return 0
  fi

  return 1
}

if [[ "${BENCH}" == "500.perlbench_r" || "${BENCH}" == "600.perlbench_s" ]]; then
  prepare_perlbench_wrapper
fi

echo "[bbv] run_dir=${RUN_DIR}"
echo "[bbv] bbv=${BBV_FILE}"

cd "${RUN_DIR}"
rm -f "${BBV_FILE}" "${BBV_MAP}" "${BBV_CMDMAP}" "${BBV_MODULES}" \
  "${BBV_COUNTER}" "${BBV_COUNTER}.lock" "${SIMPOINTS}" "${WEIGHTS}"

if [[ ! -f speccmds.cmd ]]; then
  echo "SPEC command file not found after runsetup: ${RUN_DIR}/speccmds.cmd" >&2
  echo "Check ${OUT_DIR}/runsetup.log for setup or input generation errors." >&2
  exit 1
fi

mapfile -t COMMAND_LINES < <(specinvoke -n speccmds.cmd | awk '!/^#/ && NF && $1 != "specinvoke" {print}')
if [[ "${#COMMAND_LINES[@]}" -eq 0 ]]; then
  echo "Unable to extract command from speccmds.cmd" >&2
  exit 1
fi
SUBMIT_PREFIX="${QEMU} -cpu c910 -L ${SYSROOT} "
SUBMIT_WRAPPER_PREFIX="${SCRIPT_DIR}/spec_submit_wrapper.sh ${QEMU} ${SYSROOT} "

{
  echo "[bbv] commands=${#COMMAND_LINES[@]}"
  printf "cmd_index\tstart_id\tend_id\telf\tcommand\n" >"${BBV_CMDMAP}"
} | tee "${OUT_DIR}/qemu_bbv.log"

ID_OFFSET=0
CMD_INDEX=0
for COMMAND_LINE in "${COMMAND_LINES[@]}"; do
  if [[ "${COMMAND_LINE}" == "${SUBMIT_PREFIX}"* ]]; then
    COMMAND_LINE="${COMMAND_LINE#${SUBMIT_PREFIX}}"
  fi
  if [[ "${COMMAND_LINE}" == "${SUBMIT_WRAPPER_PREFIX}"* ]]; then
    COMMAND_LINE="${COMMAND_LINE#${SUBMIT_WRAPPER_PREFIX}}"
  fi

  EXE_TOKEN="$(awk '{print $1}' <<<"${COMMAND_LINE}")"
  if [[ "${EXE_TOKEN}" = /* ]]; then
    ELF_PATH="${EXE_TOKEN}"
  else
    ELF_PATH="$(cd "${RUN_DIR}" && readlink -f "${EXE_TOKEN}")"
  fi
  if [[ -f "${ELF_PATH}.riscv" ]]; then
    ELF_PATH="${ELF_PATH}.riscv"
  fi

  START_ID=$((ID_OFFSET + 1))
  APPEND_OPT=""
  if [[ "${CMD_INDEX}" -gt 0 ]]; then
    APPEND_OPT=",append=1"
  fi

  echo "[bbv] command[$CMD_INDEX]=${COMMAND_LINE}" | tee -a "${OUT_DIR}/qemu_bbv.log"
  python3 "${SCRIPT_DIR}/capture_guest_modules.py" \
    --qemu "${QEMU}" --sysroot "${SYSROOT}" \
    --reserved-va "${QEMU_RESERVED_VA:-0x4000000000}" \
    --elf "${ELF_PATH}" --cwd "${RUN_DIR}" --cmd-index "${CMD_INDEX}" \
    --out "${BBV_MODULES}" --append \
    | tee -a "${OUT_DIR}/qemu_bbv.log"
  if [[ "${BENCH}" == "500.perlbench_r" || "${BENCH}" == "600.perlbench_s" ]]; then
    printf '%s\n' "${ID_OFFSET}" >"${BBV_COUNTER}"
    eval "SPEC_BBV_FILE=\"${BBV_FILE}\" SPEC_BBV_MAP=\"${BBV_MAP}\" SPEC_BBV_COUNTER=\"${BBV_COUNTER}\" SPEC_BBV_ID_OFFSET=\"${ID_OFFSET}\" SPEC_BBV_ID_STRIDE=\"${BBV_ID_STRIDE}\" SPEC_BBV_INTERVAL=\"${INTERVAL}\" SPEC_BBV_PLUGIN_LOCAL=\"${BBV_PLUGIN_LOCAL}\" SPEC_BBV_PLUGIN_EXTRA=\"${PLUGIN_EXTRA}\" SPEC_QEMU_RESERVED_VA=\"${QEMU_RESERVED_VA:-0x4000000000}\" /usr/bin/time -p ${COMMAND_LINE}" 2>&1 | tee -a "${OUT_DIR}/qemu_bbv.log"
    python3 "${SCRIPT_DIR}/compact_bbv_ids.py" \
      --bbv "${BBV_FILE}" --map "${BBV_MAP}" --start-id "${START_ID}" \
      --id-stride "${BBV_ID_STRIDE}" \
      | tee -a "${OUT_DIR}/qemu_bbv.log"
  else
    eval "/usr/bin/time -p \"${QEMU}\" -R \"${QEMU_RESERVED_VA:-0x4000000000}\" -cpu c910 -L \"${SYSROOT}\" -plugin \"${BBV_PLUGIN_LOCAL}\",interval=${INTERVAL},outfile=\"${BBV_FILE}\",mapfile=\"${BBV_MAP}\",id_offset=${ID_OFFSET}${APPEND_OPT}${PLUGIN_EXTRA} ${COMMAND_LINE}" 2>&1 | tee -a "${OUT_DIR}/qemu_bbv.log"
  fi

  END_ID="$(awk 'max < $1 {max = $1} END {print max + 0}' "${BBV_MAP}")"
  printf "%s\t%s\t%s\t%s\t%s\n" "${CMD_INDEX}" "${START_ID}" "${END_ID}" "${ELF_PATH}" "${COMMAND_LINE}" >>"${BBV_CMDMAP}"
  ID_OFFSET="${END_ID}"
  CMD_INDEX=$((CMD_INDEX + 1))
done

if [[ "${SKIP_COMPARE:-0}" == "1" ]]; then
  {
    echo "[compare] skipped: SKIP_COMPARE=1"
    if [[ -n "${BBV_SKIP_INTERVALS:-}" || -n "${BBV_MAX_INTERVALS:-}" ]]; then
      echo "[compare] skipped because BBV_SKIP_INTERVALS=${BBV_SKIP_INTERVALS:-0} and BBV_MAX_INTERVALS=${BBV_MAX_INTERVALS:-full} produce a sampled run"
    fi
  } | tee "${OUT_DIR}/compare.log"
else
  {
    echo "[compare] command source=compare.cmd"
    echo "[compare] RISC-V ELF commands are wrapped with QEMU"
  } | tee "${OUT_DIR}/compare.log"

  mapfile -t COMPARE_LINES < <(specinvoke -n compare.cmd | awk '!/^#/ && NF && $1 != "specinvoke" {print}')
  COMPARE_RC=0
  COMPARE_INDEX=0
  for COMPARE_LINE in "${COMPARE_LINES[@]}"; do
    EXE_TOKEN="$(awk '{print $1}' <<<"${COMPARE_LINE}")"
    if [[ "${EXE_TOKEN}" = /* ]]; then
      EXE_PATH="${EXE_TOKEN}"
    else
      EXE_PATH="$(cd "${RUN_DIR}" && readlink -f "${EXE_TOKEN}")"
    fi

    if [[ -f "${EXE_PATH}" ]] && file "${EXE_PATH}" | grep -qi 'RISC-V'; then
      COMPARE_LINE="\"${QEMU}\" -R \"${QEMU_RESERVED_VA:-0x4000000000}\" -cpu c910 -L \"${SYSROOT}\" ${COMPARE_LINE}"
    fi

    echo "[compare] command[${COMPARE_INDEX}]=${COMPARE_LINE}" | tee -a "${OUT_DIR}/compare.log"
    if ! eval "${COMPARE_LINE}" 2>&1 | tee -a "${OUT_DIR}/compare.log"; then
      COMPARE_RC=1
    fi
    COMPARE_INDEX=$((COMPARE_INDEX + 1))
  done

  if [[ "${COMPARE_RC}" -eq 0 ]]; then
    echo "[compare] exit: rc=0" | tee -a "${OUT_DIR}/compare.log"
  else
    echo "[compare] exit: rc=${COMPARE_RC}" | tee -a "${OUT_DIR}/compare.log"
  fi
fi

echo "[simpoint] maxK=${MAX_K}"
"${SIMPOINT}" \
  -maxK "${MAX_K}" \
  -loadFVFile "${BBV_FILE}" \
  -saveSimpoints "${SIMPOINTS}" \
  -saveSimpointWeights "${WEIGHTS}" 2>&1 | tee "${OUT_DIR}/simpoint.log"

if [[ ! -s "${SIMPOINTS}" || ! -s "${WEIGHTS}" ]]; then
  BBV_INTERVALS="$(grep -c '^T' "${BBV_FILE}" || true)"
  if [[ "${BBV_INTERVALS}" -eq 1 ]]; then
    echo "[simpoint] single interval fallback: interval=0 weight=1.0" | tee -a "${OUT_DIR}/simpoint.log"
    printf "0 0\n" >"${SIMPOINTS}"
    printf "1.0 0\n" >"${WEIGHTS}"
  else
    echo "[simpoint] missing output: simpoints=${SIMPOINTS} weights=${WEIGHTS}" >&2
    exit 1
  fi
fi

PROFILE="${OUT_DIR}/${BENCH}_${SIZE}.function_profile.csv"
MANIFEST="${OUT_DIR}/manifest.json"
if ELF="$(find_benchmark_elf)"; then
  PROFILE_CMD=(
    python3 "${SCRIPT_DIR}/analyze_bbv_functions.py"
    --bbv "${BBV_FILE}"
    --map "${BBV_MAP}"
    --elf "${ELF}"
    --simpoints "${SIMPOINTS}"
    --weights "${WEIGHTS}"
    --nm "${NM}"
    --top "${PROFILE_TOP:-20}"
    --out "${PROFILE}"
  )
  if [[ -s "${BBV_CMDMAP}" ]]; then
    PROFILE_CMD+=(--cmdmap "${BBV_CMDMAP}")
  fi
  if [[ -s "${BBV_MODULES}" ]]; then
    PROFILE_CMD+=(--modules "${BBV_MODULES}")
  fi
  "${PROFILE_CMD[@]}" | tee "${OUT_DIR}/function_profile.log"

  MANIFEST_CMD=(
    "${SCRIPT_DIR}/make_simpoint_manifest.py"
    --bench "${BENCH}"
    --size "${SIZE}"
    --out-dir "${OUT_DIR}"
    --interval "${INTERVAL}"
    --max-k "${MAX_K}"
    --bbv-id-stride "${BBV_ID_STRIDE}"
    --qemu-reserved-va "${QEMU_RESERVED_VA:-0x4000000000}"
    --qemu-path "${QEMU}"
    --compiler-path "${GCC_GLIBC}/bin/riscv64-unknown-linux-gnu-gcc"
    --simpoint-path "${SIMPOINT}"
    --optimize "${C910_OPT} -march=${C910_MARCH} -mabi=${C910_MABI} -mtune=${C910_MTUNE} -fcommon"
    --skip-intervals "${BBV_SKIP_INTERVALS:-0}"
    --out "${MANIFEST}"
  )
  if [[ -n "${BBV_MAX_INTERVALS:-}" ]]; then
    MANIFEST_CMD+=(--max-intervals "${BBV_MAX_INTERVALS}")
  fi
  "${MANIFEST_CMD[@]}"
else
  echo "[profile] missing ELF for ${BENCH}; manifest not refreshed" | tee "${OUT_DIR}/function_profile.log"
fi

chmod -R a+rwX "${OUT_DIR}" "${SPEC_RUN_ROOT}/logs" "${RUN_DIR}" 2>/dev/null || true

echo "[done] out_dir=${OUT_DIR}"
echo "[done] bbv=${BBV_FILE}"
echo "[done] bbv_map=${BBV_MAP}"
echo "[done] bbv_cmdmap=${BBV_CMDMAP}"
echo "[done] bbv_modules=${BBV_MODULES}"
echo "[done] simpoints=${SIMPOINTS}"
echo "[done] weights=${WEIGHTS}"
echo "[done] function_profile=${PROFILE}"
echo "[done] manifest=${MANIFEST}"
