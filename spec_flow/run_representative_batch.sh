#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/env.sh"

SUITE="${SPEC_BENCH_SUITE:-rate}"

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --suite)
      SUITE="$2"
      shift 2
      ;;
    --suite=*)
      SUITE="${1#--suite=}"
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      break
      ;;
  esac
done

SIZE="${1:-test}"
MAX_K="${2:-5}"
INTERVAL="${3:-${BBV_INTERVAL}}"
if [[ "$#" -gt 0 ]]; then shift; fi
if [[ "$#" -gt 0 ]]; then shift; fi
if [[ "$#" -gt 0 ]]; then shift; fi

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --suite)
      SUITE="$2"
      shift 2
      ;;
    --suite=*)
      SUITE="${1#--suite=}"
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      break
      ;;
  esac
done

if [[ "$#" -eq 0 ]]; then
  set -- $(spec_benchmarks_for_suite "${SUITE}")
fi
export SPEC_BENCH_SUITE="${SUITE}"

NM="${NM:-${GCC_GLIBC}/bin/riscv64-unknown-linux-gnu-nm}"
SPEC_RUN_SUFFIX="${SPEC_RUN_SUFFIX:-}"
SUMMARY="${SPEC_BATCH_SUMMARY:-${SPEC_RUN_ROOT}/representative_batch_${SUITE}_${SIZE}${SPEC_RUN_SUFFIX}_summary.md}"
CASE_LOCK_ROOT="${SPEC_RUN_ROOT}/logs/l2plus_case_locks"
mkdir -p "${CASE_LOCK_ROOT}"

find_run_dir() {
  local bench="$1"
  spec_find_run_dir "${bench}" "${SIZE}" "${SUITE}"
}

find_elf() {
  local bench="$1"
  local run_dir="$2"
  local candidate

  candidate="$(find "${run_dir}" -maxdepth 1 -type f -name "*_base.${SPEC_LABEL}" -print | head -1)"
  if [[ -n "${candidate}" ]]; then
    if [[ -f "${candidate}.riscv" ]]; then
      echo "${candidate}.riscv"
      return 0
    fi
    echo "${candidate}"
    return 0
  fi

  candidate="$(find "${SPEC_ROOT}/benchspec/CPU/${bench}/exe" -maxdepth 1 -type f -name "*_base.${SPEC_LABEL}" -print 2>/dev/null | head -1)"
  if [[ -n "${candidate}" ]]; then
    echo "${candidate}"
    return 0
  fi

  candidate="$(find "${run_dir}" -maxdepth 1 -type f -perm -111 -print | head -1)"
  if [[ -n "${candidate}" ]]; then
    echo "${candidate}"
    return 0
  fi

  return 1
}

append_summary_header() {
  cat >"${SUMMARY}" <<EOF
# SPEC2017 Representative Batch Summary

Batch command:

\`\`\`bash
./spec_flow/run_representative_batch.sh --suite ${SUITE} ${SIZE} ${MAX_K} ${INTERVAL} $*
\`\`\`

Configuration:

| item | value |
|---|---|
| SPEC benchmark suite | \`${SUITE}\` |
| input size | \`${SIZE}\` |
| SimPoint maxK | \`${MAX_K}\` |
| BBV interval | \`${INTERVAL}\` guest instructions |
| compiler optimize | \`${C910_OPT} -march=${C910_MARCH} -mabi=${C910_MABI} -mtune=${C910_MTUNE} -fcommon\` |
| BBV type | \`qemu_tb_instruction_weighted\` |

## Results

| benchmark | status | intervals | blocks | selected clusters | top global functions |
|---|---|---:|---:|---:|---|
EOF
}

summarize_one() {
  local bench="$1"
  local out_dir="${SPEC_RUN_ROOT}/${bench}_${SIZE}_c910${SPEC_RUN_SUFFIX}"
  local stem="${bench}_${SIZE}"
  local profile="${out_dir}/${stem}.function_profile.csv"
  local manifest="${out_dir}/manifest.json"

  python3 - "$bench" "$manifest" "$profile" >>"${SUMMARY}" <<'PY'
import csv
import json
import sys
from pathlib import Path

bench = sys.argv[1]
manifest_path = Path(sys.argv[2])
profile_path = Path(sys.argv[3])

if not manifest_path.exists() or not profile_path.exists():
    print(f"| `{bench}` | incomplete |  |  |  |  |")
    raise SystemExit

manifest = json.loads(manifest_path.read_text())
counts = manifest.get("counts", {})
validation = manifest.get("validation", {})
simpoints = manifest.get("simpoints", [])
top = []
with profile_path.open(newline="") as f:
    for row in csv.DictReader(f):
        if row["scope"] == "global":
            top.append(f"{row['function']} {row['percent']}%")
        if len(top) >= 4:
            break
if not validation.get("simpoint_done", False):
    status = "simpoint_missing"
elif not validation.get("compare_pass", False):
    status = "compare_failed"
else:
    status = "ok"
print(
    f"| `{bench}` | {status} | {counts.get('bbv_intervals', '')} | "
    f"{counts.get('mapped_blocks', '')} | {len(simpoints)} | "
    f"{'; '.join(top)} |"
)
PY
}

append_summary_header "$@"

for bench in "$@"; do
  case_lock="${CASE_LOCK_ROOT}/${bench}_${SIZE}.lock"
  exec {case_lock_fd}>"${case_lock}"
  echo "[batch] waiting for case lock ${bench}/${SIZE}"
  flock "${case_lock_fd}"

  out_dir="${SPEC_RUN_ROOT}/${bench}_${SIZE}_c910${SPEC_RUN_SUFFIX}"
  stem="${bench}_${SIZE}"
  bbv="${out_dir}/${stem}.bb"
  bbv_map="${out_dir}/${stem}.bb.map"
  bbv_cmdmap="${out_dir}/${stem}.bb.cmdmap"
  bbv_modules="${out_dir}/${stem}.bb.modules"
  simpoints="${out_dir}/${stem}.simpoints"
  weights="${out_dir}/${stem}.weights"
  profile="${out_dir}/${stem}.function_profile.csv"
  manifest="${out_dir}/manifest.json"

  mkdir -p "${out_dir}"

  echo "[batch] bench=${bench} size=${SIZE}"

  if [[ -z "${SPEC_RUN_SUFFIX}" ]] && \
      "${SCRIPT_DIR}/check_l2plus_case.py" \
        --spec-runs "${SPEC_RUN_ROOT}" "${bench}" "${SIZE}" >/dev/null 2>&1; then
    echo "[batch] strict result already complete for ${bench}/${SIZE}"
    summarize_one "${bench}"
    flock -u "${case_lock_fd}"
    exec {case_lock_fd}>&-
    continue
  fi

  if [[ "${FORCE_BBV:-0}" == "1" || ! -s "${bbv}" || ! -s "${bbv_map}" || ! -s "${simpoints}" || ! -s "${weights}" ]]; then
    "${SCRIPT_DIR}/run_bbv_simpoint.sh" "${bench}" "${SIZE}" "${MAX_K}" "${INTERVAL}"
  else
    echo "[batch] reuse BBV/SimPoint outputs for ${bench}"
  fi

  run_dir="$(find_run_dir "${bench}")"
  if [[ -z "${run_dir}" || ! -d "${run_dir}" ]]; then
    echo "[batch] missing run_dir for ${bench}" >&2
    summarize_one "${bench}"
    continue
  fi

  if ! elf="$(find_elf "${bench}" "${run_dir}")"; then
    echo "[batch] missing ELF for ${bench}" >&2
    summarize_one "${bench}"
    continue
  fi

  if [[ "${FORCE_PROFILE:-0}" == "1" || ! -s "${profile}" ]]; then
    PROFILE_CMD=(
      python3 "${SCRIPT_DIR}/analyze_bbv_functions.py"
      --bbv "${bbv}"
      --map "${bbv_map}"
      --elf "${elf}"
      --simpoints "${simpoints}"
      --weights "${weights}"
      --nm "${NM}"
      --top "${PROFILE_TOP:-20}"
      --out "${profile}"
    )
    if [[ -s "${bbv_cmdmap}" ]]; then
      PROFILE_CMD+=(--cmdmap "${bbv_cmdmap}")
    fi
    if [[ -s "${bbv_modules}" ]]; then
      PROFILE_CMD+=(--modules "${bbv_modules}")
    fi
    "${PROFILE_CMD[@]}" | tee "${out_dir}/function_profile.log"
  else
    echo "[batch] reuse function profile for ${bench}"
  fi

  MANIFEST_CMD=(
    "${SCRIPT_DIR}/make_simpoint_manifest.py"
    --bench "${bench}"
    --size "${SIZE}"
    --out-dir "${out_dir}"
    --interval "${INTERVAL}"
    --max-k "${MAX_K}"
    --bbv-id-stride "${SPEC_BBV_ID_STRIDE}"
    --qemu-reserved-va "${QEMU_RESERVED_VA:-0x4000000000}"
    --qemu-path "${QEMU}"
    --compiler-path "${GCC_GLIBC}/bin/riscv64-unknown-linux-gnu-gcc"
    --simpoint-path "${SIMPOINT}"
    --optimize "${C910_OPT} -march=${C910_MARCH} -mabi=${C910_MABI} -mtune=${C910_MTUNE} -fcommon"
    --skip-intervals "${BBV_SKIP_INTERVALS:-0}"
    --out "${manifest}"
  )
  if grep -q 'aslr_slide_recovered' "${bbv_modules}" 2>/dev/null; then
    MANIFEST_CMD+=(--module-map-method aslr_slide_recovered)
  fi
  if [[ -n "${BBV_MAX_INTERVALS:-}" ]]; then
    MANIFEST_CMD+=(--max-intervals "${BBV_MAX_INTERVALS}")
  fi
  "${MANIFEST_CMD[@]}"

  summarize_one "${bench}"
  flock -u "${case_lock_fd}"
  exec {case_lock_fd}>&-
done

cat >>"${SUMMARY}" <<'EOF'

## Notes

This summary is for SPEC2017-guided representative kernel selection. It is not
an official SPEC CPU2017 reportable result and not an exact RTL checkpoint
restore result.
EOF

chmod a+rwX "${SPEC_RUN_ROOT}" "${SUMMARY}" 2>/dev/null || true

echo "[batch] summary=${SUMMARY}"
