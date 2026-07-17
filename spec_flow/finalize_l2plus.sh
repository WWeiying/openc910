#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${SCRIPT_DIR}/env.sh"
export PYTHONPATH="${REPO_ROOT}${PYTHONPATH:+:${PYTHONPATH}}"

RATE_MAP="${SCRIPT_DIR}/spec2017_kernel_map.json"
SPEED_MAP="${SCRIPT_DIR}/spec2017_speed_kernel_map.json"
RATE_TMP="${RATE_MAP}.tmp.$$"
SPEED_TMP="${SPEED_MAP}.tmp.$$"
trap 'rm -f "${RATE_TMP}" "${SPEED_TMP}"' EXIT

RTL_RESULTS="${RTL_RESULTS:-${1:-}}"
if [[ -z "${RTL_RESULTS}" ]]; then
  RTL_RESULTS="$(find "${REPO_ROOT}/smart_run/results" -maxdepth 1 -type d \
    -name 'spec2017_l2plus_rtl_full_*' -printf '%T@ %p\n' 2>/dev/null \
    | sort -n | tail -1 | cut -d' ' -f2-)"
fi
if [[ -z "${RTL_RESULTS}" || ! -d "${RTL_RESULTS}" ]]; then
  echo "ERROR: completed RTL result directory not found" >&2
  exit 1
fi

failures=0
for suite in speed rate; do
  for size in test train ref; do
    for bench in $(spec_benchmarks_for_suite "${suite}"); do
      if ! "${SCRIPT_DIR}/check_l2plus_case.py" \
          --spec-runs "${SPEC_RUN_ROOT}" "${bench}" "${size}" >/dev/null; then
        echo "ERROR: strict manifest preflight failed: ${suite}/${size}/${bench}" >&2
        failures=$((failures + 1))
      fi
    done
  done
done
if [[ "${failures}" -ne 0 ]]; then
  echo "ERROR: ${failures} manifest(s) failed L2+ preflight" >&2
  exit 1
fi

python3 - "${RTL_RESULTS}" "${RATE_MAP}" "${SPEED_MAP}" <<'PY'
import json
import sys
from pathlib import Path

from spec_flow.validate_l2plus import validate_rtl_results

cases = set()
for map_path in sys.argv[2:]:
    for row in json.loads(Path(map_path).read_text())["benchmarks"]:
        cases.update(kernel["case"] for kernel in row["kernels"])
passed, errors = validate_rtl_results(Path(sys.argv[1]), cases)
if errors:
    raise SystemExit("RTL preflight failed: " + "; ".join(errors))
print(f"[finalize] RTL preflight passed={passed}/{len(cases)}")
PY

python3 "${SCRIPT_DIR}/calibrate_kernel_map.py" \
  --kernel-map "${RATE_MAP}" --spec-runs "${SPEC_RUN_ROOT}" \
  --require-cluster-mapping --out "${RATE_TMP}"
python3 "${SCRIPT_DIR}/calibrate_kernel_map.py" \
  --kernel-map "${SPEED_MAP}" --spec-runs "${SPEC_RUN_ROOT}" \
  --require-cluster-mapping --out "${SPEED_TMP}"
mv "${RATE_TMP}" "${RATE_MAP}"
mv "${SPEED_TMP}" "${SPEED_MAP}"

python3 "${SCRIPT_DIR}/report_kernel_alignment.py" \
  --kernel-map "${RATE_MAP}" --size ref --spec-runs "${SPEC_RUN_ROOT}" \
  --out "${SCRIPT_DIR}/SPEC2017_RATE_REF_ALIGNMENT.md"
python3 "${SCRIPT_DIR}/report_kernel_alignment.py" \
  --kernel-map "${SPEED_MAP}" --size ref --spec-runs "${SPEC_RUN_ROOT}" \
  --out "${SCRIPT_DIR}/SPEC2017_SPEED_REF_ALIGNMENT.md"

python3 "${SCRIPT_DIR}/validate_composite_features.py" \
  --kernel-map "${RATE_MAP}" --kernel-map "${SPEED_MAP}" \
  --features-dir "${RTL_RESULTS}/program_features" \
  >"${SCRIPT_DIR}/SPEC2017_COMPOSITE_MIX_VALIDATION.md"

python3 "${SCRIPT_DIR}/aggregate_rtl_by_simpoint.py" \
  --size ref --spec-runs "${SPEC_RUN_ROOT}" --rtl-results "${RTL_RESULTS}" \
  --kernel-map "${RATE_MAP}" --require-pass \
  --out-md "${SCRIPT_DIR}/SPEC2017_RATE_REF_RTL_PROXY_SUMMARY.md" \
  --out-json "${SCRIPT_DIR}/SPEC2017_RATE_REF_RTL_PROXY_SUMMARY.json"
python3 "${SCRIPT_DIR}/aggregate_rtl_by_simpoint.py" \
  --size ref --spec-runs "${SPEC_RUN_ROOT}" --rtl-results "${RTL_RESULTS}" \
  --kernel-map "${SPEED_MAP}" --require-pass \
  --out-md "${SCRIPT_DIR}/SPEC2017_SPEED_REF_RTL_PROXY_SUMMARY.md" \
  --out-json "${SCRIPT_DIR}/SPEC2017_SPEED_REF_RTL_PROXY_SUMMARY.json"

"${SCRIPT_DIR}/check_l2plus_status.sh" \
  >"${SCRIPT_DIR}/SPEC2017_L2PLUS_STATUS.md"
python3 "${SCRIPT_DIR}/validate_l2plus.py" \
  --spec-runs "${SPEC_RUN_ROOT}" --rtl-results "${RTL_RESULTS}" \
  >"${SCRIPT_DIR}/SPEC2017_L2PLUS_FINAL_VALIDATION.md"

echo "[finalize] L2+ complete"
echo "[finalize] validation=${SCRIPT_DIR}/SPEC2017_L2PLUS_FINAL_VALIDATION.md"
