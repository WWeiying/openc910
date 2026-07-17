#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${SCRIPT_DIR}/env.sh"

BASE_SPEC_ROOT="${SPEC_ROOT}"
WORKER_ROOT="${L2PLUS_WORKER_ROOT:-${REPO_ROOT}/spec2017_workers}"
LOG_ROOT="${SPEC_RUN_ROOT}/logs/l2plus_parallel"
WORKERS="${L2PLUS_WORKERS:-8}"
MAX_ROUNDS="${L2PLUS_MAX_ROUNDS:-2}"
MIN_FREE_KB="${L2PLUS_MIN_FREE_KB:-524288000}"
STAGES="${L2PLUS_STAGES:-speed:test speed:train rate:test rate:train speed:ref rate:ref}"

if ! [[ "${WORKERS}" =~ ^[1-9][0-9]*$ ]] || [[ "${WORKERS}" -gt 32 ]]; then
  echo "ERROR: L2PLUS_WORKERS must be an integer from 1 to 32" >&2
  exit 2
fi

mkdir -p "${LOG_ROOT}" "${WORKER_ROOT}"
exec > >(tee -a "${LOG_ROOT}/scheduler.log") 2>&1
exec 9>"${SPEC_RUN_ROOT}/logs/l2plus_remaining/run.lock"
if ! flock -n 9; then
  echo "ERROR: another L2+ scheduler is running" >&2
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
  local root="$1" suite="$2" size="$3" bench="$4" log="$5"
  local out="${SPEC_RUN_ROOT}/${bench}_${size}_c910"
  local stem="${bench}_${size}"

  [[ -s "${out}/${stem}.bb" && -s "${out}/${stem}.bb.map" && \
     -s "${out}/${stem}.bb.cmdmap" && -s "${out}/${stem}.bb.modules" ]] || return 1
  echo "[recovery] validate and finalize completed BBV ${suite}/${size}/${bench}"
  env SPEC_ROOT="${root}" SPEC_BENCH_SUITE="${suite}" \
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

prepare_worker_root() {
  local worker_id="$1"
  local root="${WORKER_ROOT}/worker-${worker_id}"
  local marker="${root}/.openc910_l2plus_worker"
  local tmp="${WORKER_ROOT}/.worker-${worker_id}.tmp.$$"

  if [[ -f "${marker}" ]]; then
    printf '%s\n' "${root}"
    return 0
  fi
  if [[ -e "${root}" ]]; then
    echo "ERROR: worker root exists without marker: ${root}" >&2
    return 1
  fi

  mkdir -p "${tmp}"
  if ! cp -a --reflink=always "${BASE_SPEC_ROOT}/." "${tmp}/"; then
    rm -rf -- "${tmp}"
    echo "ERROR: failed to create reflink worker root ${root}" >&2
    return 1
  fi
  printf 'source=%s\ncreated_utc=%s\n' \
    "${BASE_SPEC_ROOT}" "$(date -u +%FT%TZ)" >"${tmp}/.openc910_l2plus_worker"
  mv "${tmp}" "${root}"
  printf '%s\n' "${root}"
}

run_worker() {
  # The scheduler alone owns the singleton lock; jobs must not prolong it.
  exec 9>&-
  local worker_id="$1"
  local root stage suite size round bench bench_index case_log stage_dir manifest
  local -a run_env
  local failures=0

  root="$(prepare_worker_root "${worker_id}")" || return 1
  echo "[worker ${worker_id}] root=${root}"

  for stage in ${STAGES}; do
    suite="${stage%%:*}"
    size="${stage#*:}"
    stage_dir="${LOG_ROOT}/${suite}_${size}"
    mkdir -p "${stage_dir}"

    for round in $(seq 1 "${MAX_ROUNDS}"); do
      bench_index=0
      for bench in $(spec_benchmarks_for_suite "${suite}"); do
        if [[ $((bench_index % WORKERS)) -ne "${worker_id}" ]]; then
          bench_index=$((bench_index + 1))
          continue
        fi
        bench_index=$((bench_index + 1))

        if is_ok "${suite}" "${size}" "${bench}"; then
          echo "[worker ${worker_id}] skip ${suite}/${size}/${bench} already ok"
          continue
        fi
        check_disk || return 1

        case_log="${stage_dir}/${bench}.worker${worker_id}.round${round}.log"
        manifest="${SPEC_RUN_ROOT}/${bench}_${size}_c910/manifest.json"
        if try_recover_completed_bbv "${root}" "${suite}" "${size}" "${bench}" \
            "${case_log}.recovery" && is_ok "${suite}" "${size}" "${bench}"; then
          echo "[worker ${worker_id}] recovered ${suite}/${size}/${bench} at $(date -u +%FT%TZ)"
          continue
        fi
        run_env=(
          env
          SPEC_ROOT="${root}"
          SPEC_BATCH_SUMMARY="${stage_dir}/${bench}.summary.md"
        )
        if [[ -s "${manifest}" ]]; then
          echo "[worker ${worker_id}] recollect ${suite}/${size}/${bench}: strict validation failed"
          run_env+=(FORCE_BBV=1 FORCE_PROFILE=1)
        fi
        echo "[worker ${worker_id}] run ${suite}/${size}/${bench} round=${round} at $(date -u +%FT%TZ)"
        if "${run_env[@]}" "${SCRIPT_DIR}/run_representative_batch.sh" \
            --suite "${suite}" "${size}" 5 100000000 "${bench}" \
            >"${case_log}" 2>&1; then
          if is_ok "${suite}" "${size}" "${bench}"; then
            echo "[worker ${worker_id}] pass ${suite}/${size}/${bench} at $(date -u +%FT%TZ)"
          else
            echo "[worker ${worker_id}] fail ${suite}/${size}/${bench}: status not ok"
          fi
        else
          echo "[worker ${worker_id}] fail ${suite}/${size}/${bench}: command failed"
        fi
      done
    done
  done

  bench_index=0
  for stage in ${STAGES}; do
    suite="${stage%%:*}"
    size="${stage#*:}"
    bench_index=0
    for bench in $(spec_benchmarks_for_suite "${suite}"); do
      if [[ $((bench_index % WORKERS)) -eq "${worker_id}" ]] && \
          ! is_ok "${suite}" "${size}" "${bench}"; then
        echo "[worker ${worker_id}] incomplete ${suite}/${size}/${bench}"
        failures=$((failures + 1))
      fi
      bench_index=$((bench_index + 1))
    done
  done
  echo "[worker ${worker_id}] finish failures=${failures} at $(date -u +%FT%TZ)"
  [[ "${failures}" -eq 0 ]]
}

echo "[scheduler] parallel start pid=$$ workers=${WORKERS} stages=${STAGES} at $(date -u +%FT%TZ)"
worker_pids=()
for worker_id in $(seq 0 $((WORKERS - 1))); do
  run_worker "${worker_id}" &
  worker_pids+=("$!")
done

overall_status=0
for worker_pid in "${worker_pids[@]}"; do
  if ! wait "${worker_pid}"; then
    overall_status=1
  fi
done

echo "[scheduler] final matrix"
"${SCRIPT_DIR}/check_l2plus_status.sh"
echo "[scheduler] finish status=${overall_status} at $(date -u +%FT%TZ)"
exit "${overall_status}"
