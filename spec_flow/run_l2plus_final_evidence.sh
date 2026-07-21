#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"

QUICK_TAG="${L2PLUS_QUICK_TAG:-spec2017_l2plus_quick_features}"
RTL_TAG="${L2PLUS_RTL_TAG:-spec2017_l2plus_rtl_full}"
SKIP_COMPILE="${L2PLUS_SKIP_COMPILE:-0}"
RESUME="${L2PLUS_RESUME:-1}"
RTL_WORKERS="${L2PLUS_RTL_WORKERS:-2}"

if [[ "${SKIP_COMPILE}" != 0 && "${SKIP_COMPILE}" != 1 ]]; then
  echo "ERROR: L2PLUS_SKIP_COMPILE must be 0 or 1" >&2
  exit 2
fi
if [[ "${RESUME}" != 0 && "${RESUME}" != 1 ]]; then
  echo "ERROR: L2PLUS_RESUME must be 0 or 1" >&2
  exit 2
fi
if ! [[ "${RTL_WORKERS}" =~ ^[1-8]$ ]]; then
  echo "ERROR: L2PLUS_RTL_WORKERS must be an integer from 1 to 8" >&2
  exit 2
fi

status="$(
  L2PLUS_STATUS_MODE=strict L2PLUS_STATUS_JOBS="${L2PLUS_STATUS_JOBS:-16}" \
    "${SCRIPT_DIR}/check_l2plus_status.sh"
)"
strict_count="$(
  sed -n 's/.*：\([0-9][0-9]*\)\/129.*/\1/p' <<<"${status}" | tail -1
)"
if [[ "${strict_count}" != 129 ]]; then
  printf '%s\n' "${status}" >&2
  echo "ERROR: final evidence requires strict SimPoint status 129/129" >&2
  exit 1
fi

if [[ -n "$(git -C "${REPO_ROOT}" status --porcelain)" ]]; then
  echo "ERROR: final evidence must start from a clean Git worktree" >&2
  git -C "${REPO_ROOT}" status --short >&2
  exit 1
fi

git_short="$(git -C "${REPO_ROOT}" rev-parse --short=12 HEAD)"
git_full="$(git -C "${REPO_ROOT}" rev-parse HEAD)"
quick_dir="${REPO_ROOT}/smart_run/kernel_features/${QUICK_TAG}_rtl_${git_short}_clean"
rtl_dir="${REPO_ROOT}/smart_run/results/${RTL_TAG}_${git_short}_clean"

mapfile -t cases < <(
  "${SCRIPT_DIR}/run_spec_kernel_profiles.sh" \
    --suite all --profile full --list |
    sed -n '/^spec_/p'
)
unique_count="$(printf '%s\n' "${cases[@]}" | sort -u | wc -l)"
if [[ "${#cases[@]}" -ne 43 || "${unique_count}" -ne 43 ]]; then
  echo "ERROR: expected 43 distinct SPEC cases, got ${#cases[@]}/${unique_count}" >&2
  exit 1
fi
if [[ -e "${quick_dir}" && "${RESUME}" != 1 ]]; then
  echo "ERROR: quick feature target already exists: ${quick_dir}" >&2
  exit 1
fi
if [[ -e "${rtl_dir}" && "${RESUME}" != 1 ]]; then
  echo "ERROR: RTL result target already exists: ${rtl_dir}" >&2
  exit 1
fi

echo "[final-evidence] commit=${git_full}"
echo "[final-evidence] cases=43"
echo "[final-evidence] quick_features=${quick_dir}"
echo "[final-evidence] rtl_results=${rtl_dir}"
echo "[final-evidence] resume=${RESUME}"
echo "[final-evidence] rtl_workers=${RTL_WORKERS}"

if [[ "${SKIP_COMPILE}" != 1 && ! -e "${rtl_dir}" ]]; then
  make --no-print-directory -C "${REPO_ROOT}/smart_run" \
    compile DUMP=off PERF_DETAIL=on
elif [[ -e "${rtl_dir}" ]]; then
  echo "[final-evidence] preserving compiled simv for partial-result resume"
fi
if [[ ! -e "${rtl_dir}" ]] && \
    ! grep -q '+define+PERF_DETAIL' \
      "${REPO_ROOT}/smart_run/work/comp.vcs.log" 2>/dev/null; then
  echo "ERROR: final evidence requires a PERF_DETAIL-enabled simulator" >&2
  echo "       run: make -C smart_run compile DUMP=off PERF_DETAIL=on" >&2
  exit 1
fi

FEATURE_CHECK_ARGS=()
for case_name in "${cases[@]}"; do
  FEATURE_CHECK_ARGS+=(--expected-case "${case_name}")
done
quick_complete=0
if [[ -e "${quick_dir}" ]] && \
    python3 "${SCRIPT_DIR}/check_feature_evidence.py" \
      --root "${quick_dir}" --profile quick --commit "${git_full}" \
      "${FEATURE_CHECK_ARGS[@]}" >/dev/null 2>&1; then
  quick_complete=1
fi
if [[ "${quick_complete}" == 1 ]]; then
  echo "[final-evidence] quick characterization RESUME_PASS"
else
  "${SCRIPT_DIR}/run_spec_kernel_profiles.sh" \
    --suite all --profile quick --features-only --tag "${QUICK_TAG}"
fi

if [[ -n "$(git -C "${REPO_ROOT}" status --porcelain)" ]]; then
  echo "ERROR: quick characterization changed tracked repository state" >&2
  git -C "${REPO_ROOT}" status --short >&2
  exit 1
fi

RTL_RUN_ARGS=(--rtl-workers "${RTL_WORKERS}")
if [[ "${RESUME}" == 1 ]]; then RTL_RUN_ARGS+=(--resume); fi
"${SCRIPT_DIR}/run_spec_kernel_profiles.sh" \
  --suite all --profile full --tag "${RTL_TAG}" "${RTL_RUN_ARGS[@]}"

if [[ "$(git -C "${REPO_ROOT}" rev-parse HEAD)" != "${git_full}" ]]; then
  echo "ERROR: source commit changed while final evidence was running" >&2
  exit 1
fi
if [[ -n "$(git -C "${REPO_ROOT}" status --porcelain)" ]]; then
  echo "ERROR: source worktree changed while final evidence was running" >&2
  git -C "${REPO_ROOT}" status --short >&2
  exit 1
fi

L2PLUS_QUICK_FEATURES_DIR="${quick_dir}" \
L2PLUS_FULL_FEATURES_DIR="${rtl_dir}/program_features" \
  "${SCRIPT_DIR}/finalize_l2plus.sh" "${rtl_dir}"

echo "[final-evidence] complete"
echo "[final-evidence] validation=${SCRIPT_DIR}/SPEC2017_L2PLUS_FINAL_VALIDATION.md"
