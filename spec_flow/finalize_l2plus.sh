#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
source "${SCRIPT_DIR}/env.sh"
export PYTHONPATH="${REPO_ROOT}${PYTHONPATH:+:${PYTHONPATH}}"

RATE_MAP="${SCRIPT_DIR}/spec2017_kernel_map.json"
SPEED_MAP="${SCRIPT_DIR}/spec2017_speed_kernel_map.json"
COMPOSITIONS="${SCRIPT_DIR}/spec_cluster_compositions.json"
COMPOSITIONS_MD="${SCRIPT_DIR}/SPEC_CLUSTER_COMPOSITIONS.md"
PROFILE_CONTRACTS="${SCRIPT_DIR}/spec_kernel_profiles.json"
PROFILE_CONTRACTS_MD="${SCRIPT_DIR}/SPEC_KERNEL_PROFILES.md"

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
RTL_RESULTS="$(realpath "${RTL_RESULTS}")"

ALLOW_SOURCE_MISMATCH="${L2PLUS_ALLOW_SOURCE_MISMATCH:-0}"
if [[ "${ALLOW_SOURCE_MISMATCH}" != 0 && "${ALLOW_SOURCE_MISMATCH}" != 1 ]]; then
  echo "ERROR: L2PLUS_ALLOW_SOURCE_MISMATCH must be 0 or 1" >&2
  exit 2
fi
RTL_INFO="${RTL_RESULTS}/run.info"
if [[ ! -f "${RTL_INFO}" ]]; then
  echo "ERROR: RTL run.info not found: ${RTL_INFO}" >&2
  exit 1
fi
EVIDENCE_COMMIT="$(sed -n 's/^git_commit=//p' "${RTL_INFO}" | tail -1)"
CURRENT_COMMIT="$(git -C "${REPO_ROOT}" rev-parse HEAD)"
if [[ "${ALLOW_SOURCE_MISMATCH}" != 1 ]]; then
  if [[ ! "${EVIDENCE_COMMIT}" =~ ^[0-9a-fA-F]{40}$ ]]; then
    echo "ERROR: RTL evidence does not contain a full Git commit" >&2
    exit 1
  fi
  if [[ "${CURRENT_COMMIT}" != "${EVIDENCE_COMMIT}" ]]; then
    echo "ERROR: current source commit does not match RTL evidence" >&2
    echo "       current=${CURRENT_COMMIT}" >&2
    echo "       evidence=${EVIDENCE_COMMIT}" >&2
    exit 1
  fi
  if [[ -n "$(git -C "${REPO_ROOT}" status --porcelain)" ]]; then
    echo "ERROR: finalization requires the evidence commit in a clean worktree" >&2
    git -C "${REPO_ROOT}" status --short >&2
    exit 1
  fi
fi

QUICK_FEATURES_DIR="${L2PLUS_QUICK_FEATURES_DIR:-${REPO_ROOT}/smart_run/kernel_features/spec_all_43_quick_final}"
FULL_FEATURES_DIR="${L2PLUS_FULL_FEATURES_DIR:-${REPO_ROOT}/smart_run/kernel_features/spec_all_43_full_final}"
FEATURES_PROFILE="${L2PLUS_FEATURES_PROFILE:-full}"
if [[ "${FEATURES_PROFILE}" != "quick" && "${FEATURES_PROFILE}" != "full" ]]; then
  echo "ERROR: L2PLUS_FEATURES_PROFILE must be quick or full" >&2
  exit 1
fi
if [[ -n "${L2PLUS_FEATURES_DIR:-}" ]]; then
  if [[ "${FEATURES_PROFILE}" == "quick" ]]; then
    QUICK_FEATURES_DIR="${L2PLUS_FEATURES_DIR}"
  else
    FULL_FEATURES_DIR="${L2PLUS_FEATURES_DIR}"
  fi
elif [[ -d "${RTL_RESULTS}/program_features/cases" ]]; then
  sample_feature="$(
    find "${RTL_RESULTS}/program_features/cases" -mindepth 2 -maxdepth 2 \
      -name features.json -print -quit
  )"
  if [[ -n "${sample_feature}" ]]; then
    embedded_profile="$(jq -r '.profile.kernel_profile // empty' "${sample_feature}")"
    if [[ "${embedded_profile}" == "quick" ]]; then
      QUICK_FEATURES_DIR="${RTL_RESULTS}/program_features"
    elif [[ "${embedded_profile}" == "full" ]]; then
      FULL_FEATURES_DIR="${RTL_RESULTS}/program_features"
    fi
  fi
fi
for features_dir in "${QUICK_FEATURES_DIR}" "${FULL_FEATURES_DIR}"; do
  if [[ ! -d "${features_dir}/cases" ]]; then
    echo "ERROR: program-feature case directory not found: ${features_dir}/cases" >&2
    exit 1
  fi
done
QUICK_FEATURES_DIR="$(realpath "${QUICK_FEATURES_DIR}")"
FULL_FEATURES_DIR="$(realpath "${FULL_FEATURES_DIR}")"

RTL_RETIRED_TOLERANCE="${L2PLUS_RTL_RETIRED_TOLERANCE:-6}"
EXPECTED_DETAIL_ROWS="${L2PLUS_EXPECTED_DETAIL_ROWS:-1048}"
if ! [[ "${RTL_RETIRED_TOLERANCE}" =~ ^[0-9]+$ ]]; then
  echo "ERROR: L2PLUS_RTL_RETIRED_TOLERANCE must be non-negative" >&2
  exit 2
fi
if ! [[ "${EXPECTED_DETAIL_ROWS}" =~ ^[0-9]+$ ]]; then
  echo "ERROR: L2PLUS_EXPECTED_DETAIL_ROWS must be non-negative" >&2
  exit 2
fi

echo "[finalize] rtl_results=${RTL_RESULTS}"
echo "[finalize] quick_features=${QUICK_FEATURES_DIR}"
echo "[finalize] full_features=${FULL_FEATURES_DIR}"

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

STAGE="$(mktemp -d "${SCRIPT_DIR}/.l2plus-finalize.XXXXXX")"
trap 'rm -rf "${STAGE}"' EXIT
STAGE_RATE="${STAGE}/spec2017_kernel_map.json"
STAGE_SPEED="${STAGE}/spec2017_speed_kernel_map.json"
STAGE_COMPOSITIONS="${STAGE}/spec_cluster_compositions.json"
STAGE_COMPOSITIONS_MD="${STAGE}/SPEC_CLUSTER_COMPOSITIONS.md"
STAGE_PROFILES="${STAGE}/spec_kernel_profiles.json"
STAGE_PROFILES_MD="${STAGE}/SPEC_KERNEL_PROFILES.md"

cp "${RATE_MAP}" "${STAGE_RATE}"
cp "${SPEED_MAP}" "${STAGE_SPEED}"
cp "${PROFILE_CONTRACTS}" "${STAGE_PROFILES}"

SPEC_RUN_ARG="${SPEC_RUN_ROOT}"
if [[ "$(realpath "${SPEC_RUN_ROOT}")" == "${REPO_ROOT}/spec_runs" ]]; then
  SPEC_RUN_ARG="spec_runs"
fi
(
  cd "${REPO_ROOT}"
  python3 "${SCRIPT_DIR}/build_cluster_composition_specs.py" \
    --spec-runs "${SPEC_RUN_ARG}" \
    --output "${STAGE_COMPOSITIONS}" \
    --markdown "${STAGE_COMPOSITIONS_MD}"
)
python3 "${SCRIPT_DIR}/apply_cluster_compositions.py" \
  --compositions "${STAGE_COMPOSITIONS}" \
  --map "${STAGE_RATE}" --map "${STAGE_SPEED}" \
  --profiles "${STAGE_PROFILES}"

python3 "${SCRIPT_DIR}/record_composition_measurements.py" \
  --map "${STAGE_RATE}" --map "${STAGE_SPEED}" \
  --quick-features "${QUICK_FEATURES_DIR}" \
  --full-features "${FULL_FEATURES_DIR}" \
  --expected-cases 43

python3 "${SCRIPT_DIR}/update_spec_profile_contracts.py" \
  --kernel-map "${STAGE_RATE}" --kernel-map "${STAGE_SPEED}" \
  --quick-features "${QUICK_FEATURES_DIR}" \
  --full-features "${FULL_FEATURES_DIR}" \
  --output "${STAGE_PROFILES}" \
  --markdown "${STAGE_PROFILES_MD}"

python3 - "${RTL_RESULTS}" "${QUICK_FEATURES_DIR}" "${FULL_FEATURES_DIR}" \
  "${STAGE_RATE}" "${STAGE_SPEED}" <<'PY'
import json
import sys
from pathlib import Path

from spec_flow.validate_l2plus import (
    read_key_value_info,
    validate_feature_results,
    validate_rtl_results,
)

cases = set()
for map_path in sys.argv[4:]:
    for row in json.loads(Path(map_path).read_text())["benchmarks"]:
        cases.update(kernel["case"] for kernel in row["kernels"])
passed, errors = validate_rtl_results(
    Path(sys.argv[1]),
    cases,
    require_clean=True,
    required_profile="full",
)
if errors:
    raise SystemExit("RTL artifact preflight failed: " + "; ".join(errors))
print(f"[finalize] RTL artifact preflight passed={passed}/{len(cases)}")
rtl_commit = read_key_value_info(Path(sys.argv[1]) / "run.info").get("git_commit")
for profile, root in (("quick", Path(sys.argv[2])), ("full", Path(sys.argv[3]))):
    passed, errors = validate_feature_results(
        root,
        cases,
        profile,
        require_clean=True,
        required_commit=rtl_commit,
    )
    if errors:
        raise SystemExit(
            f"{profile} feature preflight failed: " + "; ".join(errors)
        )
    print(f"[finalize] {profile} feature preflight passed={passed}/{len(cases)}")
PY

{
  echo "# SPEC Composite 动态指令配比校验"
  echo
  echo "## quick"
  echo
  python3 "${SCRIPT_DIR}/validate_composite_features.py" \
    --kernel-map "${STAGE_RATE}" --kernel-map "${STAGE_SPEED}" \
    --features-dir "${QUICK_FEATURES_DIR}" --profile quick
  echo
  echo "## full"
  echo
  python3 "${SCRIPT_DIR}/validate_composite_features.py" \
    --kernel-map "${STAGE_RATE}" --kernel-map "${STAGE_SPEED}" \
    --features-dir "${FULL_FEATURES_DIR}" --profile full
} >"${STAGE}/SPEC2017_COMPOSITE_MIX_VALIDATION.md"

{
  echo "# SPEC Kernel Profile 契约校验"
  echo
  echo "## quick"
  echo
  python3 "${SCRIPT_DIR}/validate_spec_profiles.py" \
    --contracts "${STAGE_PROFILES}" \
    --features-dir "${QUICK_FEATURES_DIR}" --profile quick
  echo
  echo "## full"
  echo
  python3 "${SCRIPT_DIR}/validate_spec_profiles.py" \
    --contracts "${STAGE_PROFILES}" \
    --features-dir "${FULL_FEATURES_DIR}" --profile full
} >"${STAGE}/SPEC2017_PROFILE_VALIDATION.md"

python3 "${SCRIPT_DIR}/validate_spec_rtl_profiles.py" \
  --contracts "${STAGE_PROFILES}" \
  --results-dir "${RTL_RESULTS}" \
  --features-dir "${FULL_FEATURES_DIR}" \
  --profile full \
  --retired-tolerance "${RTL_RETIRED_TOLERANCE}" \
  --expected-detail-rows "${EXPECTED_DETAIL_ROWS}" \
  --require-detail \
  >"${STAGE}/SPEC2017_RTL_PROFILE_VALIDATION.md"

STAGE_RATE_CAL="${STAGE}/spec2017_kernel_map.calibrated.json"
STAGE_SPEED_CAL="${STAGE}/spec2017_speed_kernel_map.calibrated.json"
python3 "${SCRIPT_DIR}/calibrate_kernel_map.py" \
  --kernel-map "${STAGE_RATE}" --spec-runs "${SPEC_RUN_ROOT}" \
  --require-cluster-mapping --out "${STAGE_RATE_CAL}"
python3 "${SCRIPT_DIR}/calibrate_kernel_map.py" \
  --kernel-map "${STAGE_SPEED}" --spec-runs "${SPEC_RUN_ROOT}" \
  --require-cluster-mapping --out "${STAGE_SPEED_CAL}"

python3 "${SCRIPT_DIR}/report_kernel_alignment.py" \
  --kernel-map "${STAGE_RATE_CAL}" \
  --kernel-map-label "spec_flow/spec2017_kernel_map.json" \
  --size ref --spec-runs "${SPEC_RUN_ROOT}" \
  --out "${STAGE}/SPEC2017_RATE_REF_ALIGNMENT.md"
python3 "${SCRIPT_DIR}/report_kernel_alignment.py" \
  --kernel-map "${STAGE_SPEED_CAL}" \
  --kernel-map-label "spec_flow/spec2017_speed_kernel_map.json" \
  --size ref --spec-runs "${SPEC_RUN_ROOT}" \
  --out "${STAGE}/SPEC2017_SPEED_REF_ALIGNMENT.md"

python3 "${SCRIPT_DIR}/aggregate_rtl_by_simpoint.py" \
  --size ref --spec-runs "${SPEC_RUN_ROOT}" --rtl-results "${RTL_RESULTS}" \
  --kernel-map "${STAGE_RATE_CAL}" \
  --kernel-map-label "spec_flow/spec2017_kernel_map.json" \
  --require-pass \
  --out-md "${STAGE}/SPEC2017_RATE_REF_RTL_PROXY_SUMMARY.md" \
  --out-json "${STAGE}/SPEC2017_RATE_REF_RTL_PROXY_SUMMARY.json"
python3 "${SCRIPT_DIR}/aggregate_rtl_by_simpoint.py" \
  --size ref --spec-runs "${SPEC_RUN_ROOT}" --rtl-results "${RTL_RESULTS}" \
  --kernel-map "${STAGE_SPEED_CAL}" \
  --kernel-map-label "spec_flow/spec2017_speed_kernel_map.json" \
  --require-pass \
  --out-md "${STAGE}/SPEC2017_SPEED_REF_RTL_PROXY_SUMMARY.md" \
  --out-json "${STAGE}/SPEC2017_SPEED_REF_RTL_PROXY_SUMMARY.json"

"${SCRIPT_DIR}/check_l2plus_status.sh" \
  >"${STAGE}/SPEC2017_L2PLUS_STATUS.md"
python3 "${SCRIPT_DIR}/validate_l2plus.py" \
  --spec-runs "${SPEC_RUN_ROOT}" \
  --rate-map "${STAGE_RATE_CAL}" --speed-map "${STAGE_SPEED_CAL}" \
  --rtl-results "${RTL_RESULTS}" \
  --contracts "${STAGE_PROFILES}" \
  --contracts-label "spec_flow/spec_kernel_profiles.json" \
  --features-dir "${FULL_FEATURES_DIR}" \
  --quick-features-dir "${QUICK_FEATURES_DIR}" \
  --profile full \
  --rtl-retired-tolerance "${RTL_RETIRED_TOLERANCE}" \
  --expected-detail-rows "${EXPECTED_DETAIL_ROWS}" \
  >"${STAGE}/SPEC2017_L2PLUS_FINAL_VALIDATION.md"

python3 "${SCRIPT_DIR}/generate_l2plus_overviews.py" \
  --rate-map "${STAGE_RATE_CAL}" \
  --speed-map "${STAGE_SPEED_CAL}" \
  --profiles "${STAGE_PROFILES}" \
  --rtl-results "${RTL_RESULTS}" \
  --quick-features "${QUICK_FEATURES_DIR}" \
  --full-features "${FULL_FEATURES_DIR}" \
  --simpoint-status "${STAGE}/SPEC2017_L2PLUS_STATUS.md" \
  --final-validation "${STAGE}/SPEC2017_L2PLUS_FINAL_VALIDATION.md" \
  --representative-out "${STAGE}/SPEC2017_REPRESENTATIVE_KERNELS.md" \
  --status-out "${STAGE}/SPEC2017_SIMPOINT_RTL_STATUS.md" \
  --repo-root "${REPO_ROOT}"

PUBLISH_ARGS=(
  --pair "${STAGE_RATE_CAL}" "${RATE_MAP}"
  --pair "${STAGE_SPEED_CAL}" "${SPEED_MAP}"
  --pair "${STAGE_COMPOSITIONS}" "${COMPOSITIONS}"
  --pair "${STAGE_COMPOSITIONS_MD}" "${COMPOSITIONS_MD}"
  --pair "${STAGE_PROFILES}" "${PROFILE_CONTRACTS}"
  --pair "${STAGE_PROFILES_MD}" "${PROFILE_CONTRACTS_MD}"
)
for name in \
  SPEC2017_COMPOSITE_MIX_VALIDATION.md \
  SPEC2017_PROFILE_VALIDATION.md \
  SPEC2017_RTL_PROFILE_VALIDATION.md \
  SPEC2017_RATE_REF_ALIGNMENT.md \
  SPEC2017_SPEED_REF_ALIGNMENT.md \
  SPEC2017_RATE_REF_RTL_PROXY_SUMMARY.md \
  SPEC2017_RATE_REF_RTL_PROXY_SUMMARY.json \
  SPEC2017_SPEED_REF_RTL_PROXY_SUMMARY.md \
  SPEC2017_SPEED_REF_RTL_PROXY_SUMMARY.json \
  SPEC2017_L2PLUS_STATUS.md \
  SPEC2017_L2PLUS_FINAL_VALIDATION.md \
  SPEC2017_REPRESENTATIVE_KERNELS.md \
  SPEC2017_SIMPOINT_RTL_STATUS.md; do
  PUBLISH_ARGS+=(--pair "${STAGE}/${name}" "${SCRIPT_DIR}/${name}")
done
python3 "${SCRIPT_DIR}/publish_l2plus_outputs.py" "${PUBLISH_ARGS[@]}"

echo "[finalize] L2+ complete"
echo "[finalize] validation=${SCRIPT_DIR}/SPEC2017_L2PLUS_FINAL_VALIDATION.md"
