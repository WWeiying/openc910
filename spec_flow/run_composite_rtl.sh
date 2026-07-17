#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
SUITE=all
MODE=joint
TAG=spec2017_profile
PROFILE=quick
CALIBRATED_ONLY=0
PROFILED_ONLY=0
PROFILE_CONTRACTS="${SCRIPT_DIR}/spec_kernel_profiles.json"

usage() {
  cat <<'EOF'
Usage: ./spec_flow/run_spec_kernel_profiles.sh [options]

Options:
  --suite rate|speed|all  select benchmark map, default all
  --tag NAME              result tag, default spec2017_profile
  --profile quick|full    short regression or large-workset profile
  --calibrated-only       select only kernels with calibrated composition
  --profiled-only         select only kernels with a quick/full contract
  --features-only         collect whole-composite dynamic features only
  --rtl-only              run whole-composite RTL only
  --list                  print selected SPEC profile cases without running
  -h, --help              show this help

The default mode characterizes each complete SPEC kernel ELF and then runs the
same case in RTL. Every benchmark map row must reference exactly one kernel.
The full profile implies --profiled-only. All current cases are calibrated
multi-mechanism composites, so --calibrated-only is retained for compatibility
and currently selects the same 43 cases.
EOF
}

while (($#)); do
  case "$1" in
    --suite)
      SUITE="$2"; shift 2 ;;
    --suite=*)
      SUITE="${1#--suite=}"; shift ;;
    --tag)
      TAG="$2"; shift 2 ;;
    --profile)
      PROFILE="$2"; shift 2 ;;
    --calibrated-only)
      CALIBRATED_ONLY=1; shift ;;
    --profiled-only)
      PROFILED_ONLY=1; shift ;;
    --features-only)
      MODE=features; shift ;;
    --rtl-only)
      MODE=rtl; shift ;;
    --list)
      MODE=list; shift ;;
    -h|--help)
      usage; exit 0 ;;
    *)
      echo "ERROR: unknown argument $1" >&2
      usage >&2
      exit 2 ;;
  esac
done

case "${SUITE}" in
  rate)
    MAPS=("${SCRIPT_DIR}/spec2017_kernel_map.json") ;;
  speed)
    MAPS=("${SCRIPT_DIR}/spec2017_speed_kernel_map.json") ;;
  all)
    MAPS=(
      "${SCRIPT_DIR}/spec2017_kernel_map.json"
      "${SCRIPT_DIR}/spec2017_speed_kernel_map.json"
    ) ;;
  *)
    echo "ERROR: --suite must be rate, speed, or all" >&2
    exit 2 ;;
esac

if [[ "${PROFILE}" != quick && "${PROFILE}" != full ]]; then
  echo "ERROR: --profile must be quick or full" >&2
  exit 2
fi
if [[ "${PROFILE}" == full ]]; then
  PROFILED_ONLY=1
fi
if [[ "${PROFILED_ONLY}" == 1 && ! -f "${PROFILE_CONTRACTS}" ]]; then
  echo "ERROR: missing profile contracts: ${PROFILE_CONTRACTS}" >&2
  exit 1
fi

mapfile -t CASES < <(python3 - "${CALIBRATED_ONLY}" "${PROFILED_ONLY}" \
  "${PROFILE_CONTRACTS}" "${MAPS[@]}" <<'PY'
import json
import sys

calibrated_only = sys.argv[1] == "1"
profiled_only = sys.argv[2] == "1"
contracts_path = sys.argv[3]
profiled_cases = set()
if profiled_only:
    profiled_cases = set(json.load(open(contracts_path)).get("cases", {}))
seen = set()
for path in sys.argv[4:]:
    data = json.load(open(path))
    for row in data.get("benchmarks", []):
        kernels = row.get("kernels", [])
        if len(kernels) != 1:
            raise SystemExit(
                f"{row.get('bench')}: expected exactly one profile kernel, "
                f"found {len(kernels)}"
            )
        if calibrated_only:
            calibration = kernels[0].get("calibration")
            legacy_composite = calibration is None and kernels[0].get("composition")
            if not legacy_composite and calibration not in {
                "simpoint-composition", "simpoint-cluster-composition"
            }:
                continue
        case = kernels[0]["case"]
        if profiled_only and case not in profiled_cases:
            continue
        if case not in seen:
            seen.add(case)
            print(case)
PY
)

if ((${#CASES[@]} == 0)); then
  echo "ERROR: no SPEC profile cases found" >&2
  exit 1
fi

printf '[spec-profile] suite=%s mode=%s profile=%s calibrated_only=%s profiled_only=%s cases=%d tag=%s\n' \
  "${SUITE}" "${MODE}" "${PROFILE}" "${CALIBRATED_ONLY}" \
  "${PROFILED_ONLY}" "${#CASES[@]}" "${TAG}"

case "${MODE}" in
  list)
    printf '%s\n' "${CASES[@]}"
    ;;
  features)
    if [[ "${PROFILE}" == full ]]; then feature_profile=representative; else feature_profile=rtl; fi
    SPEC_KERNEL_PROFILE="${PROFILE}" \
      "${REPO_ROOT}/smart_run/run_kernel_characterization.sh" \
      --profile "${feature_profile}" --tag "${TAG}" "${CASES[@]}"
    ;;
  rtl)
    BENCH_CASES="${CASES[*]}" SPEC_KERNEL_PROFILE="${PROFILE}" \
      "${REPO_ROOT}/smart_run/run_bench.sh" --profile "${PROFILE}" --tag "${TAG}"
    ;;
  joint)
    BENCH_CASES="${CASES[*]}" SPEC_KERNEL_PROFILE="${PROFILE}" \
      "${REPO_ROOT}/smart_run/run_bench.sh" --characterize \
      --profile "${PROFILE}" --tag "${TAG}"
    ;;
esac
