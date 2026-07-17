#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${SCRIPT_DIR}/env.sh"

SUITE="${1:-speed}"
SIZE="${2:-ref}"
shift $(( $# >= 2 ? 2 : $# ))
if [[ "$#" -eq 0 ]]; then
  echo "ERROR: provide an explicit non-overlapping benchmark list" >&2
  exit 2
fi

BASE_SPEC_ROOT="${SPEC_ROOT}"
WORKER_ROOT="${L2PLUS_SUPPLEMENT_ROOT:-${REPO_ROOT}/spec2017_supplement_workers}"
LOG_ROOT="${L2PLUS_SUPPLEMENT_LOG_ROOT:-${SPEC_RUN_ROOT}/logs/l2plus_supplement}"
WORKERS="${L2PLUS_SUPPLEMENT_WORKERS:-8}"
MIN_FREE_KB="${L2PLUS_MIN_FREE_KB:-524288000}"
BENCHMARKS=("$@")

if ! [[ "${WORKERS}" =~ ^[1-9][0-9]*$ ]] || [[ "${WORKERS}" -gt 16 ]]; then
  echo "ERROR: L2PLUS_SUPPLEMENT_WORKERS must be an integer from 1 to 16" >&2
  exit 2
fi
if [[ "${SIZE}" != "test" && "${SIZE}" != "train" && "${SIZE}" != "ref" ]]; then
  echo "ERROR: size must be test, train, or ref" >&2
  exit 2
fi

mkdir -p "${WORKER_ROOT}" "${LOG_ROOT}"
exec > >(tee -a "${LOG_ROOT}/scheduler.log") 2>&1
echo "$$" >"${LOG_ROOT}/scheduler.pid"

is_ok() {
  "${SCRIPT_DIR}/check_l2plus_case.py" \
    --spec-runs "${SPEC_RUN_ROOT}" "$1" "${SIZE}" >/dev/null 2>&1
}

check_disk() {
  local free_kb
  free_kb="$(df -Pk "${REPO_ROOT}" | awk 'NR == 2 {print $4}')"
  [[ -n "${free_kb}" && "${free_kb}" -ge "${MIN_FREE_KB}" ]] || {
    echo "ERROR: free disk ${free_kb:-unknown} KiB is below ${MIN_FREE_KB} KiB" >&2
    return 1
  }
}

prepare_root() {
  local id="$1"
  local root="${WORKER_ROOT}/worker-${id}"
  local marker="${root}/.openc910_l2plus_supplement"
  local tmp="${WORKER_ROOT}/.worker-${id}.tmp.$$"

  if [[ -f "${marker}" ]]; then
    printf '%s\n' "${root}"
    return 0
  fi
  if [[ -e "${root}" ]]; then
    echo "ERROR: supplemental root exists without marker: ${root}" >&2
    return 1
  fi
  mkdir -p "${tmp}"
  if ! cp -a --reflink=always "${BASE_SPEC_ROOT}/." "${tmp}/"; then
    rm -rf -- "${tmp}"
    return 1
  fi
  printf 'source=%s\ncreated_utc=%s\n' \
    "${BASE_SPEC_ROOT}" "$(date -u +%FT%TZ)" >"${tmp}/.openc910_l2plus_supplement"
  mv "${tmp}" "${root}"
  printf '%s\n' "${root}"
}

run_worker() {
  local id="$1"
  local root index bench log failures=0

  root="$(prepare_root "${id}")" || return 1
  echo "[supplement ${id}] root=${root}"
  for index in "${!BENCHMARKS[@]}"; do
    [[ $((index % WORKERS)) -eq "${id}" ]] || continue
    bench="${BENCHMARKS[index]}"
    if is_ok "${bench}"; then
      echo "[supplement ${id}] skip ${bench}/${SIZE} already strict"
      continue
    fi
    check_disk || return 1
    log="${LOG_ROOT}/${bench}_${SIZE}.worker${id}.log"
    echo "[supplement ${id}] run ${bench}/${SIZE} at $(date -u +%FT%TZ)"
    if env SPEC_ROOT="${root}" \
        SPEC_BATCH_SUMMARY="${LOG_ROOT}/${bench}_${SIZE}.summary.md" \
        "${SCRIPT_DIR}/run_representative_batch.sh" \
          --suite "${SUITE}" "${SIZE}" 5 100000000 "${bench}" \
          >"${log}" 2>&1 && is_ok "${bench}"; then
      echo "[supplement ${id}] pass ${bench}/${SIZE} at $(date -u +%FT%TZ)"
    else
      echo "[supplement ${id}] fail ${bench}/${SIZE}"
      failures=$((failures + 1))
    fi
  done
  echo "[supplement ${id}] finish failures=${failures}"
  [[ "${failures}" -eq 0 ]]
}

echo "[supplement] start suite=${SUITE} size=${SIZE} workers=${WORKERS} cases=${#BENCHMARKS[@]}"
pids=()
for id in $(seq 0 $((WORKERS - 1))); do
  run_worker "${id}" &
  pids+=("$!")
done

status=0
for pid in "${pids[@]}"; do
  wait "${pid}" || status=1
done
echo "[supplement] finish status=${status} at $(date -u +%FT%TZ)"
exit "${status}"
