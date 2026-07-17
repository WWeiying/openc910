#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${SCRIPT_DIR}/env.sh"

LOG_ROOT="${SPEC_RUN_ROOT}/logs/l2plus_remaining"
MAX_ROUNDS="${L2PLUS_MAX_ROUNDS:-2}"
MIN_FREE_KB="${L2PLUS_MIN_FREE_KB:-524288000}"
STAGES="${L2PLUS_STAGES:-speed:test speed:train rate:test rate:train speed:ref rate:ref}"
mkdir -p "${LOG_ROOT}"

exec > >(tee -a "${LOG_ROOT}/scheduler.log") 2>&1
exec 9>"${LOG_ROOT}/run.lock"
if ! flock -n 9; then
  echo "ERROR: another L2+ SimPoint scheduler is already running" >&2
  exit 1
fi

echo "$$" >"${LOG_ROOT}/scheduler.pid"

is_ok() {
  local suite="$1"
  local size="$2"
  local bench="$3"
  "${SCRIPT_DIR}/check_l2plus_case.py" \
    --spec-runs "${SPEC_RUN_ROOT}" "${bench}" "${size}" >/dev/null 2>&1
}

try_recover_completed_bbv() {
  local suite="$1" size="$2" bench="$3" log="$4"
  local out="${SPEC_RUN_ROOT}/${bench}_${size}_c910"
  local stem="${bench}_${size}"

  [[ -s "${out}/${stem}.bb" && -s "${out}/${stem}.bb.map" && \
     -s "${out}/${stem}.bb.cmdmap" && -s "${out}/${stem}.bb.modules" ]] || return 1
  echo "[recovery] validate and finalize completed BBV ${suite}/${size}/${bench}"
  env SPEC_BENCH_SUITE="${suite}" \
    "${SCRIPT_DIR}/finalize_existing_bbv.sh" "${bench}" "${size}" 5 100000000 \
    >"${log}" 2>&1
}

check_disk() {
  local free_kb
  free_kb="$(df -Pk "${REPO_ROOT}" | awk 'NR == 2 {print $4}')"
  if [[ -z "${free_kb}" || "${free_kb}" -lt "${MIN_FREE_KB}" ]]; then
    echo "ERROR: free disk ${free_kb:-unknown} KiB is below limit ${MIN_FREE_KB} KiB"
    return 1
  fi
}

run_stage() {
  local suite="$1"
  local size="$2"
  local round bench stage_dir case_log manifest pending
  local -a run_env
  stage_dir="${LOG_ROOT}/${suite}_${size}"
  mkdir -p "${stage_dir}"

  echo "[stage] begin suite=${suite} size=${size} at $(date -u +%FT%TZ)"
  for round in $(seq 1 "${MAX_ROUNDS}"); do
    pending=0
    echo "[stage] round=${round}/${MAX_ROUNDS} suite=${suite} size=${size}"
    for bench in $(spec_benchmarks_for_suite "${suite}"); do
      if is_ok "${suite}" "${size}" "${bench}"; then
        echo "[skip] ${suite}/${size}/${bench} already ok"
        continue
      fi

      pending=$((pending + 1))
      check_disk || return 1
      case_log="${stage_dir}/${bench}.round${round}.log"
      manifest="${SPEC_RUN_ROOT}/${bench}_${size}_c910/manifest.json"
      if try_recover_completed_bbv "${suite}" "${size}" "${bench}" \
          "${case_log}.recovery" && is_ok "${suite}" "${size}" "${bench}"; then
        echo "[recovered] ${suite}/${size}/${bench} at $(date -u +%FT%TZ)"
        continue
      fi
      run_env=(
        env
        SPEC_BATCH_SUMMARY="${stage_dir}/${bench}.summary.md"
      )
      if [[ -s "${manifest}" ]]; then
        echo "[recollect] ${suite}/${size}/${bench}: strict validation failed"
        run_env+=(FORCE_BBV=1 FORCE_PROFILE=1)
      fi
      echo "[run] ${suite}/${size}/${bench} log=${case_log} at $(date -u +%FT%TZ)"
      if "${run_env[@]}" "${SCRIPT_DIR}/run_representative_batch.sh" \
          --suite "${suite}" "${size}" 5 100000000 "${bench}" \
          9>&- >"${case_log}" 2>&1; then
        if is_ok "${suite}" "${size}" "${bench}"; then
          echo "[pass] ${suite}/${size}/${bench} at $(date -u +%FT%TZ)"
        else
          echo "[fail] ${suite}/${size}/${bench}: command completed but status is not ok"
        fi
      else
        echo "[fail] ${suite}/${size}/${bench}: command failed; continuing"
      fi
    done
    [[ "${pending}" -eq 0 ]] && break
  done

  "${SCRIPT_DIR}/check_simpoint_status.py" --suite "${suite}" --size "${size}" \
    | tee "${stage_dir}/status.md"
  if "${SCRIPT_DIR}/check_simpoint_status.py" --suite "${suite}" --size "${size}" \
      | tail -n 1 | grep -Eq '^summary: ok=[0-9]+$'; then
    echo "[stage] complete suite=${suite} size=${size} at $(date -u +%FT%TZ)"
    return 0
  fi
  echo "[stage] incomplete suite=${suite} size=${size} after ${MAX_ROUNDS} rounds"
  return 1
}

overall_status=0
echo "[scheduler] start pid=$$ stages=${STAGES} at $(date -u +%FT%TZ)"
for stage in ${STAGES}; do
  suite="${stage%%:*}"
  size="${stage#*:}"
  if ! run_stage "${suite}" "${size}"; then
    overall_status=1
  fi
done

echo "[scheduler] final matrix"
for suite in speed rate; do
  for size in test train ref; do
    printf '[status] %s/%s ' "${suite}" "${size}"
    "${SCRIPT_DIR}/check_simpoint_status.py" --suite "${suite}" --size "${size}" \
      | tail -n 1
  done
done
echo "[scheduler] finish status=${overall_status} at $(date -u +%FT%TZ)"
exit "${overall_status}"
