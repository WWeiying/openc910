#!/usr/bin/env bash
set -euo pipefail

SIMV="$(realpath "${1:?usage: run_staged_rtl_case.sh SIMV STAGE_ROOT CASE}")"
STAGE_ROOT="$(realpath "${2:?usage: run_staged_rtl_case.sh SIMV STAGE_ROOT CASE}")"
CASE="${3:?usage: run_staged_rtl_case.sh SIMV STAGE_ROOT CASE}"
CASE_DIR="${STAGE_ROOT}/${CASE}"

if [[ ! -x "${SIMV}" ]]; then
  echo "ERROR: simulator is missing or not executable: ${SIMV}" >&2
  exit 2
fi
for input in case.pat inst.pat data.pat symbols.args "${CASE}.elf"; do
  if [[ ! -s "${CASE_DIR}/${input}" ]]; then
    echo "ERROR: ${CASE}: staged input is missing or empty: ${input}" >&2
    exit 2
  fi
done

mapfile -t SYMBOL_ARGS <"${CASE_DIR}/symbols.args"
if ((${#SYMBOL_ARGS[@]} == 0)); then
  echo "ERROR: ${CASE}: symbols.args contains no arguments" >&2
  exit 2
fi
rm -f \
  "${CASE_DIR}/run.vcs.log" \
  "${CASE_DIR}/run_case.report" \
  "${CASE_DIR}/simv.console.log" \
  "${CASE_DIR}/pc_trace.log" \
  "${CASE_DIR}/reg_trace.log"

cd "${CASE_DIR}"
set +e
nice -n 10 "${SIMV}" -l run.vcs.log "${SYMBOL_ARGS[@]}" \
  >simv.console.log 2>&1
status=$?
set -e
printf 'simv_exit=%s\n' "${status}" >simv.exit
exit "${status}"
