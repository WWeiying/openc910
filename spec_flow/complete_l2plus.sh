#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${SCRIPT_DIR}/env.sh"

WAIT_PID="${L2PLUS_WAIT_PID:-}"
MAX_PASSES="${L2PLUS_COMPLETION_PASSES:-3}"
RTL_RESULTS="${RTL_RESULTS:-${1:-}}"
LOG_ROOT="${SPEC_RUN_ROOT}/logs/l2plus_completion"

if ! [[ "${MAX_PASSES}" =~ ^[1-9][0-9]*$ ]] || [[ "${MAX_PASSES}" -gt 10 ]]; then
  echo "ERROR: L2PLUS_COMPLETION_PASSES must be an integer from 1 to 10" >&2
  exit 2
fi
if [[ -n "${WAIT_PID}" ]] && ! [[ "${WAIT_PID}" =~ ^[1-9][0-9]*$ ]]; then
  echo "ERROR: L2PLUS_WAIT_PID must be a positive integer" >&2
  exit 2
fi

mkdir -p "${LOG_ROOT}"
exec > >(tee -a "${LOG_ROOT}/completion.log") 2>&1
echo "$$" >"${LOG_ROOT}/completion.pid"

strict_count() {
  local status count

  status="$(L2PLUS_STATUS_JOBS="${L2PLUS_STATUS_JOBS:-16}" \
    "${SCRIPT_DIR}/check_l2plus_status.sh")"
  printf '%s\n' "${status}" >"${LOG_ROOT}/status.md"
  count="$(sed -n 's/.*：\([0-9][0-9]*\)\/129.*/\1/p' <<<"${status}" | tail -1)"
  if [[ -z "${count}" ]]; then
    echo "ERROR: unable to parse strict L2+ status" >&2
    return 1
  fi
  printf '%s\n' "${count}"
}

wait_for_scheduler() {
  local state

  [[ -z "${WAIT_PID}" ]] && return 0
  echo "[completion] waiting for scheduler pid=${WAIT_PID}"
  while kill -0 "${WAIT_PID}" 2>/dev/null; do
    state="$(ps -o stat= -p "${WAIT_PID}" 2>/dev/null | tr -d ' ' || true)"
    [[ -z "${state}" || "${state}" == Z* ]] && break
    sleep 60
  done
  echo "[completion] scheduler pid=${WAIT_PID} ended at $(date -u +%FT%TZ)"
}

wait_for_scheduler

previous=-1
for pass in $(seq 1 "${MAX_PASSES}"); do
  current="$(strict_count)"
  echo "[completion] strict=${current}/129 before pass=${pass}"
  if [[ "${current}" -eq 129 ]]; then
    break
  fi
  if [[ "${current}" -eq "${previous}" ]]; then
    echo "[completion] warning: no strict progress since previous pass"
  fi
  previous="${current}"

  L2PLUS_MAX_ROUNDS="${L2PLUS_MAX_ROUNDS:-2}" \
    L2PLUS_WORKERS="${L2PLUS_WORKERS:-8}" \
    "${SCRIPT_DIR}/run_l2plus_parallel.sh" || true
done

current="$(strict_count)"
echo "[completion] strict=${current}/129 after recovery"
if [[ "${current}" -ne 129 ]]; then
  echo "ERROR: L2+ recovery exhausted after ${MAX_PASSES} pass(es)" >&2
  exit 1
fi

if [[ -n "${RTL_RESULTS}" ]]; then
  "${SCRIPT_DIR}/finalize_l2plus.sh" "${RTL_RESULTS}"
else
  "${SCRIPT_DIR}/run_l2plus_final_evidence.sh"
fi
echo "[completion] finalized at $(date -u +%FT%TZ)"
