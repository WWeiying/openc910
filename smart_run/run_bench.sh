#!/bin/bash
# run_bench.sh - run all benchmark cases and save performance reports
#
# Usage: ./run_bench.sh [TAG]
#   TAG  : label for this run (e.g. "baseline" or "modified"), default "run"
#
# Prerequisite: RTL must be compiled first.
#   For fast runs (no waveform): make compile DUMP=off
#   For waveform:                make compile DUMP=on
#
# Results are saved to results/<TAG>_<git>_<clean|dirty>/
# Override the case list with, for example:
#   BENCH_CASES=coremark ./run_bench.sh coremark_c910_tuned_30

set -e

TAG=${1:-"run"}
BENCH_CASES=${BENCH_CASES:-"coremark dhrystone \
    bench_branch bench_mem bench_ilp bench_frontend bench_fp \
    bench_br_bimodal bench_br_ras bench_br_indirect bench_br_corr \
    bench_cache_stride"}

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel 2>/dev/null || cd "${SCRIPT_DIR}/.." && pwd)"
GIT_COMMIT="$(git -C "${REPO_ROOT}" rev-parse --short=12 HEAD 2>/dev/null || echo unknown)"
GIT_COMMIT_FULL="$(git -C "${REPO_ROOT}" rev-parse HEAD 2>/dev/null || echo unknown)"
GIT_BRANCH="$(git -C "${REPO_ROOT}" rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
if [ -n "$(git -C "${REPO_ROOT}" status --porcelain 2>/dev/null || true)" ]; then
    GIT_DIRTY="dirty"
else
    GIT_DIRTY="clean"
fi
RESULTS_DIR="${SCRIPT_DIR}/results/${TAG}_${GIT_COMMIT}_${GIT_DIRTY}"

rm -rf "${RESULTS_DIR}"
mkdir -p "${RESULTS_DIR}"

echo "=== run_bench: TAG=${TAG} ==="
echo "Results -> ${RESULTS_DIR}"
echo "Git     -> ${GIT_COMMIT} (${GIT_DIRTY}, ${GIT_BRANCH})"
echo ""

{
    echo "tag=${TAG}"
    echo "bench_cases=${BENCH_CASES}"
    echo "git_commit=${GIT_COMMIT_FULL}"
    echo "git_commit_short=${GIT_COMMIT}"
    echo "git_branch=${GIT_BRANCH}"
    echo "git_dirty=${GIT_DIRTY}"
    echo "results_dir=${RESULTS_DIR}"
    if [ -n "${COREMARK_ITERATIONS:-}" ]; then
        echo "coremark_iterations=${COREMARK_ITERATIONS}"
    fi
    echo "perf_detail_request=${PERF_DETAIL:-auto}"
} > "${RESULTS_DIR}/run.info"

git -C "${REPO_ROOT}" status --short > "${RESULTS_DIR}/git.status" 2>/dev/null || true
git -C "${REPO_ROOT}" diff > "${RESULTS_DIR}/git.diff" 2>/dev/null || true

# Require simv to exist - RTL must be compiled before running simulations
if [ ! -f "${SCRIPT_DIR}/work/simv" ]; then
    echo "ERROR: work/simv not found. Run 'make compile' first."
    exit 1
fi

PASS=0
FAIL=0

for CASE in ${BENCH_CASES}; do
    printf "  %-16s ... " "${CASE}"

    LOG="${SCRIPT_DIR}/work/run.vcs.log"
    CASE_LOG="${RESULTS_DIR}/${CASE}.build.log"

    # build and simulate; save full output for post-mortem on failure
    if make -s simcase CASE="${CASE}" \
            -C "${SCRIPT_DIR}" > "${CASE_LOG}" 2>&1; then

        cp -f "${LOG}" "${RESULTS_DIR}/${CASE}.run.vcs.log" 2>/dev/null || true
        cp -f "${SCRIPT_DIR}/work/${CASE}.asm" "${RESULTS_DIR}/${CASE}.asm" 2>/dev/null || true
        cp -f "${SCRIPT_DIR}/work/symbols.args" "${RESULTS_DIR}/${CASE}.symbols.args" 2>/dev/null || true
        cp -f "${SCRIPT_DIR}/work/run_case.report" "${RESULTS_DIR}/${CASE}.run_case.report" 2>/dev/null || true

        # extract the performance statistics block
        grep -A 200 "Performance Statistics" "${LOG}" \
            > "${RESULTS_DIR}/${CASE}.perf" 2>/dev/null || true

        DETAIL_LOG="${RESULTS_DIR}/${CASE}.detail.perf"
        if ! grep -A 2400 "Detailed Performance Statistics" "${LOG}" \
                > "${DETAIL_LOG}" 2>/dev/null; then
            rm -f "${DETAIL_LOG}"
        fi

        grep -E "CoreMark has been run|CoreMark 1.0|Dhrystone|Dhrystones per simulated MHz|DMIPS/MHz|Cycles for one run|CoreMark Size|Iterations       :|Correct operation|TEST PASS|TEST FAIL|Total     \\||Main      \\||Kernel    \\||CPU Time" \
            "${LOG}" > "${RESULTS_DIR}/${CASE}.summary.txt" 2>/dev/null || true

        # check pass/fail from report file
        if grep -q "TEST PASS" "${SCRIPT_DIR}/work/run_case.report" 2>/dev/null || \
           grep -q "Correct operation validated" "${LOG}" 2>/dev/null; then
            echo "PASS"
            PASS=$((PASS + 1))
        else
            echo "FAIL (simulation error) -- see ${CASE_LOG}"
            FAIL=$((FAIL + 1))
        fi
    else
        echo "FAIL (build/run error) -- see ${CASE_LOG}"
        FAIL=$((FAIL + 1))
    fi
done

echo ""
echo "=== Summary: ${PASS} passed, ${FAIL} failed ==="
