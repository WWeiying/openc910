#!/usr/bin/env bash
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${SCRIPT_DIR}/env.sh"

WATCH="${L2PLUS_RECOVERY_WATCH:-0}"
INTERVAL="${L2PLUS_RECOVERY_INTERVAL:-60}"
LOG_ROOT="${SPEC_RUN_ROOT}/logs/l2plus_partial_recovery"
LOCK_ROOT="${SPEC_RUN_ROOT}/logs/l2plus_case_locks"

if ! [[ "${INTERVAL}" =~ ^[1-9][0-9]*$ ]]; then
  echo "ERROR: L2PLUS_RECOVERY_INTERVAL must be a positive integer" >&2
  exit 2
fi
mkdir -p "${LOG_ROOT}" "${LOCK_ROOT}"
exec > >(tee -a "${LOG_ROOT}/watcher.log") 2>&1
echo "$$" >"${LOG_ROOT}/watcher.pid"

is_ok() {
  "${SCRIPT_DIR}/check_l2plus_case.py" \
    --spec-runs "${SPEC_RUN_ROOT}" "$1" ref >/dev/null 2>&1
}

case_busy() {
  local bench="$1"
  ps -eo args= | awk -v bench="${bench}" '
    $0 ~ /awk -v bench=/ {next}
    index($0, bench) &&
    ($0 ~ /run_bbv_simpoint[.]sh/ || $0 ~ /run_representative_batch[.]sh/ ||
     $0 ~ /qemu-riscv64/) {
      found=1
    }
    END {exit !found}
  '
}

derive_spec_root() {
  local cmdmap="$1" elf
  elf="$(awk -F '\t' 'NR == 2 {print $4}' "${cmdmap}")"
  case "${elf}" in
    */benchspec/CPU/*) printf '%s\n' "${elf%%/benchspec/CPU/*}" ;;
    *) return 1 ;;
  esac
}

scan_once() {
  local suite bench out stem cmdmap root log lock_file lock_fd

  for suite in speed rate; do
    for bench in $(spec_benchmarks_for_suite "${suite}"); do
      is_ok "${bench}" && continue
      case_busy "${bench}" && continue

      out="${SPEC_RUN_ROOT}/${bench}_ref_c910"
      stem="${bench}_ref"
      cmdmap="${out}/${stem}.bb.cmdmap"
      [[ -s "${out}/${stem}.bb" && -s "${out}/${stem}.bb.map" && \
         -s "${cmdmap}" && -s "${out}/${stem}.bb.modules" ]] || continue
      root="$(derive_spec_root "${cmdmap}")" || continue
      [[ -d "${root}" ]] || continue

      lock_file="${LOCK_ROOT}/${bench}_ref.lock"
      exec {lock_fd}>"${lock_file}"
      if ! flock -n "${lock_fd}"; then
        exec {lock_fd}>&-
        continue
      fi
      if is_ok "${bench}" || case_busy "${bench}"; then
        flock -u "${lock_fd}"
        exec {lock_fd}>&-
        continue
      fi

      log="${LOG_ROOT}/${bench}_ref.log"
      echo "[recovery-watch] attempt ${suite}/ref/${bench} root=${root}"
      if env SPEC_ROOT="${root}" SPEC_BENCH_SUITE="${suite}" \
          "${SCRIPT_DIR}/finalize_existing_bbv.sh" "${bench}" ref 5 100000000 \
          >"${log}" 2>&1 && is_ok "${bench}"; then
        echo "[recovery-watch] pass ${suite}/ref/${bench} at $(date -u +%FT%TZ)"
      else
        echo "[recovery-watch] not recoverable ${suite}/ref/${bench}; see ${log}"
      fi
      flock -u "${lock_fd}"
      exec {lock_fd}>&-
    done
  done
}

echo "[recovery-watch] start pid=$$ watch=${WATCH}"
while :; do
  scan_once
  [[ "${WATCH}" == "1" ]] || break
  if ! pgrep -f 'run_l2plus_parallel[.]sh|run_l2plus_supplement[.]sh' >/dev/null; then
    break
  fi
  sleep "${INTERVAL}"
done
echo "[recovery-watch] finish at $(date -u +%FT%TZ)"
