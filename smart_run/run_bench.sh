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
# Results are saved to results/<TAG>/<case>.perf
# Build/run logs saved to  results/<TAG>/<case>.build.log

set -e

TAG=${1:-"run"}
BENCH_CASES="coremark \
    bench_branch bench_mem bench_ilp bench_frontend bench_fp \
    bench_br_bimodal bench_br_ras bench_br_indirect bench_br_corr \
    bench_cache_stride"

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
RESULTS_DIR="${SCRIPT_DIR}/results/${TAG}"

mkdir -p "${RESULTS_DIR}"

echo "=== run_bench: TAG=${TAG} ==="
echo "Results -> ${RESULTS_DIR}"
echo ""

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

        # extract the performance statistics block
        grep -A 200 "Performance Statistics" "${LOG}" \
            > "${RESULTS_DIR}/${CASE}.perf" 2>/dev/null || true

        # check pass/fail from report file
        if grep -q "TEST PASS" "${SCRIPT_DIR}/work/run_case.report" 2>/dev/null; then
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
