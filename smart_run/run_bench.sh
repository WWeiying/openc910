#!/bin/bash
# run_bench.sh - run all benchmark cases and save performance reports
#
# Usage: ./run_bench.sh [options] [TAG]
#   TAG  : label for this run (e.g. "baseline" or "modified"), default "run"
#   --characterize : collect architectural program features before RTL simulation
#
# Prerequisite: RTL must be compiled first.
#   For fast runs (no waveform): make compile DUMP=off
#   For waveform:                make compile DUMP=on
#
# Results are saved to results/<TAG>_<git>_<clean|dirty>/
# Override the case list with, for example:
#   BENCH_CASES=coremark ./run_bench.sh coremark_c910_tuned_30

set -e

TAG="run"
PROGRAM_FEATURES="${PROGRAM_FEATURES:-off}"
PROGRAM_FEATURE_PROFILE="${PROGRAM_FEATURE_PROFILE:-}"
SPEC_KERNEL_PROFILE="${SPEC_KERNEL_PROFILE:-${SPEC_COMPOSITE_PROFILE:-quick}}"
SPEC_COMPOSITE_PROFILE="${SPEC_KERNEL_PROFILE}"
RTL_RETIRED_TOLERANCE="${RTL_RETIRED_TOLERANCE:-6}"
BENCH_SUITE="${BENCH_SUITE:-default}"
REPLACE_RESULTS=off
BASELINE_MODE=off
LIST_CASES=off
TAG_SEEN=0
BENCH_CASES_WAS_SET=0
if [ "${BENCH_CASES+x}" = x ]; then
    BENCH_CASES_WAS_SET=1
fi

usage() {
    cat <<'EOF'
Usage: ./run_bench.sh [options] [TAG]

Options:
  --baseline                  run the canonical 55-case Full baseline suite
                              with tag baseline_full
  --suite NAME                benchmark suite: default or full
  --characterize              collect program features before RTL simulation
  --characterize-profile MODE rtl (default) or representative
  --profile MODE               SPEC kernel workload profile: quick or full
  --tag NAME                   set result tag; positional TAG remains supported
  --list-cases                 print the effective case list and exit
  --replace-results            explicitly replace an existing same-name directory
  -h, --help                  show this help

Environment equivalents:
  BENCH_SUITE=default|full
  PROGRAM_FEATURES=on
  PROGRAM_FEATURE_PROFILE=rtl|representative
  SPEC_KERNEL_PROFILE=quick|full
  SPEC_COMPOSITE_PROFILE=quick|full  (legacy alias)
  RTL_RETIRED_TOLERANCE=N           default 6
  BENCH_CASES="case1 case2 ..."
EOF
}

while (($#)); do
    case "$1" in
        --baseline)
            if ((TAG_SEEN)); then
                echo "ERROR: --baseline cannot be combined with another tag" >&2
                exit 2
            fi
            TAG="baseline_full"
            TAG_SEEN=1
            BENCH_SUITE=full
            SPEC_KERNEL_PROFILE=full
            SPEC_COMPOSITE_PROFILE=full
            BASELINE_MODE=on
            shift ;;
        --suite)
            BENCH_SUITE="$2"; shift 2 ;;
        --characterize|--program-features)
            PROGRAM_FEATURES=on; shift ;;
        --characterize-profile)
            PROGRAM_FEATURE_PROFILE="$2"; shift 2 ;;
        --profile|--composite-profile)
            SPEC_KERNEL_PROFILE="$2"; SPEC_COMPOSITE_PROFILE="$2"; shift 2 ;;
        --tag)
            if ((TAG_SEEN)); then
                echo "ERROR: tag specified more than once" >&2
                exit 2
            fi
            TAG="$2"; TAG_SEEN=1; shift 2 ;;
        --replace-results)
            REPLACE_RESULTS=on; shift ;;
        --list-cases)
            LIST_CASES=on; shift ;;
        -h|--help)
            usage; exit 0 ;;
        --)
            shift
            if (($#)); then
                if ((TAG_SEEN)); then
                    echo "ERROR: tag specified more than once" >&2; exit 2
                fi
                TAG="$1"; TAG_SEEN=1; shift
            fi
            if (($#)); then
                echo "ERROR: unexpected arguments: $*" >&2; exit 2
            fi ;;
        -*)
            echo "ERROR: unknown option $1" >&2; usage >&2; exit 2 ;;
        *)
            if ((TAG_SEEN)); then
                echo "ERROR: tag specified more than once" >&2; exit 2
            fi
            TAG="$1"; TAG_SEEN=1; shift ;;
    esac
done

if [ "${PROGRAM_FEATURES}" != on ] && [ "${PROGRAM_FEATURES}" != off ]; then
    echo "ERROR: PROGRAM_FEATURES must be on or off" >&2
    exit 2
fi
if [ "${BENCH_SUITE}" != default ] && [ "${BENCH_SUITE}" != full ]; then
    echo "ERROR: --suite must be default or full" >&2
    exit 2
fi
if [ "${BASELINE_MODE}" = on ] && \
        { [ "${BENCH_SUITE}" != full ] || [ "${SPEC_KERNEL_PROFILE}" != full ]; }; then
    echo "ERROR: --baseline requires --suite full and --profile full" >&2
    exit 2
fi
if [ "${SPEC_KERNEL_PROFILE}" != quick ] && \
        [ "${SPEC_KERNEL_PROFILE}" != full ]; then
    echo "ERROR: --profile must be quick or full" >&2
    exit 2
fi
if [ -z "${PROGRAM_FEATURE_PROFILE}" ]; then
    if [ "${SPEC_KERNEL_PROFILE}" = full ]; then
        PROGRAM_FEATURE_PROFILE=representative
    else
        PROGRAM_FEATURE_PROFILE=rtl
    fi
fi
if [ "${PROGRAM_FEATURE_PROFILE}" != rtl ] && \
        [ "${PROGRAM_FEATURE_PROFILE}" != representative ]; then
    echo "ERROR: --characterize-profile must be rtl or representative" >&2
    exit 2
fi
DEFAULT_BENCH_CASES="coremark dhrystone \
    bench_branch bench_mem bench_ilp bench_frontend bench_fp \
    bench_br_bimodal bench_br_ras bench_br_indirect bench_br_corr \
    bench_cache_stride \
    spec_perlbench_regex_kernel spec_gcc_compile_kernel \
    spec_505_mcf_composite_kernel spec_605_mcf_composite_kernel \
    spec_omnetpp_event_kernel \
    spec_xalancbmk_xml_kernel spec_x264_pixel_kernel \
    spec_deepsjeng_search_kernel spec_leela_playout_kernel \
    spec_exchange2_search_kernel spec_xz_lzma_kernel \
    spec_bwaves_stencil_kernel spec_cactubssn_stencil_kernel \
    spec_namd_pair_kernel spec_510_parest_composite_kernel \
    spec_povray_ray_kernel spec_lbm_stream_kernel \
    spec_wrf_stencil_kernel spec_blender_render_kernel \
    spec_cam4_climate_kernel spec_imagick_filter_kernel \
    spec_nab_md_kernel spec_fotonik3d_stencil_kernel \
    spec_roms_stencil_kernel spec_pop2_ocean_kernel"

if [ "${BENCH_SUITE}" = full ]; then
    if ((BENCH_CASES_WAS_SET)); then
        echo "ERROR: BENCH_CASES cannot be combined with --suite full or --baseline" >&2
        exit 2
    fi
    FULL_SUITE_FILE="$(cd "$(dirname "$0")" && pwd)/full_regression_cases.txt"
    if [ ! -f "${FULL_SUITE_FILE}" ]; then
        echo "ERROR: full suite manifest not found: ${FULL_SUITE_FILE}" >&2
        exit 2
    fi
    BENCH_CASES="$(
        sed '/^[[:space:]]*#/d; /^[[:space:]]*$/d' "${FULL_SUITE_FILE}" |
            tr '\n' ' '
    )"
else
    BENCH_CASES=${BENCH_CASES:-"${DEFAULT_BENCH_CASES}"}
fi

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
if [ "${LIST_CASES}" = on ]; then
    tr '[:space:]' '\n' <<< "${BENCH_CASES}" | sed '/^$/d'
    exit 0
fi

LOCK_FILE="${SCRIPT_DIR}/.run_bench.lock"
exec 9>"${LOCK_FILE}"
if ! flock -n 9; then
    echo "ERROR: another run_bench.sh is already running for ${SCRIPT_DIR}."
    echo "       smart_run/work is shared, so concurrent benchmark runs corrupt results."
    exit 1
fi
printf "%s\n" "$$" 1>&9

if REPO_ROOT="$(git -C "${SCRIPT_DIR}" rev-parse --show-toplevel 2>/dev/null)"; then
    :
else
    REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
fi
GIT_COMMIT="$(git -C "${REPO_ROOT}" rev-parse --short=12 HEAD 2>/dev/null || echo unknown)"
GIT_COMMIT_FULL="$(git -C "${REPO_ROOT}" rev-parse HEAD 2>/dev/null || echo unknown)"
GIT_BRANCH="$(git -C "${REPO_ROOT}" rev-parse --abbrev-ref HEAD 2>/dev/null || echo unknown)"
if [ -n "$(git -C "${REPO_ROOT}" status --porcelain 2>/dev/null || true)" ]; then
    GIT_DIRTY="dirty"
else
    GIT_DIRTY="clean"
fi
RESULTS_DIR="${SCRIPT_DIR}/results/${TAG}_${GIT_COMMIT}_${GIT_DIRTY}"

if [ -e "${RESULTS_DIR}" ]; then
    if [ "${REPLACE_RESULTS}" != on ]; then
        echo "ERROR: result directory already exists: ${RESULTS_DIR}" >&2
        echo "       choose another tag or pass --replace-results explicitly" >&2
        exit 2
    fi
    rm -rf "${RESULTS_DIR}"
fi
mkdir -p "${RESULTS_DIR}"

exec > >(tee -a "${RESULTS_DIR}/run.console.log") 2>&1

echo "=== run_bench: TAG=${TAG} ==="
echo "Results -> ${RESULTS_DIR}"
echo "Git     -> ${GIT_COMMIT} (${GIT_DIRTY}, ${GIT_BRANCH})"
echo ""

{
    echo "tag=${TAG}"
    echo "bench_suite=${BENCH_SUITE}"
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
    echo "program_features=${PROGRAM_FEATURES}"
    echo "program_feature_profile=${PROGRAM_FEATURE_PROFILE}"
    echo "kernel_profile=${SPEC_KERNEL_PROFILE}"
    echo "composite_profile=${SPEC_COMPOSITE_PROFILE}"
    echo "rtl_retired_tolerance=${RTL_RETIRED_TOLERANCE}"
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

if [ "${PROGRAM_FEATURES}" = on ]; then
    FEATURE_DIR="${RESULTS_DIR}/program_features"
    FEATURE_LOG="${RESULTS_DIR}/program_features.log"
    mapfile -t FEATURE_CASES < <(
        tr '[:space:]' '\n' <<< "${BENCH_CASES}" | sed '/^$/d'
    )
    echo "=== Program features: profile=${PROGRAM_FEATURE_PROFILE} ==="
    echo "Program features -> ${FEATURE_DIR}"
    if ! SPEC_KERNEL_PROFILE="${SPEC_KERNEL_PROFILE}" \
            "${SCRIPT_DIR}/run_kernel_characterization.sh" \
            --profile "${PROGRAM_FEATURE_PROFILE}" \
            --tag "${TAG}" \
            --output-dir "${FEATURE_DIR}" \
            --assume-lock-held \
            "${FEATURE_CASES[@]}" > "${FEATURE_LOG}" 2>&1; then
        echo "ERROR: program characterization failed; see ${FEATURE_LOG}" >&2
        exit 1
    fi
    echo "Program characterization PASS"
    echo "program_feature_dir=${FEATURE_DIR}" >> "${RESULTS_DIR}/run.info"
    python3 "${REPO_ROOT}/spec_flow/validate_composite_features.py" \
        --kernel-map "${REPO_ROOT}/spec_flow/spec2017_kernel_map.json" \
        --kernel-map "${REPO_ROOT}/spec_flow/spec2017_speed_kernel_map.json" \
        --features-dir "${FEATURE_DIR}" \
        --profile "${SPEC_KERNEL_PROFILE}" --allow-missing \
        > "${RESULTS_DIR}/COMPOSITE_MIX_VALIDATION.md"
    if [ -f "${REPO_ROOT}/spec_flow/spec_kernel_profiles.json" ]; then
        python3 "${REPO_ROOT}/spec_flow/validate_spec_profiles.py" \
            --contracts "${REPO_ROOT}/spec_flow/spec_kernel_profiles.json" \
            --features-dir "${FEATURE_DIR}" \
            --profile "${SPEC_KERNEL_PROFILE}" --allow-missing \
            > "${RESULTS_DIR}/SPEC_PROFILE_VALIDATION.md"
    fi
    echo ""
fi

archive_case_outputs() {
    local case="$1"
    local log="${SCRIPT_DIR}/work/run.vcs.log"
    local compile_log="${SCRIPT_DIR}/work/${case}_build.case.log"
    local detail_log="${RESULTS_DIR}/${case}.detail.perf"
    local branch_pc_log="${RESULTS_DIR}/${case}.branch_pc.perf"

    cp -f "${log}" "${RESULTS_DIR}/${case}.run.vcs.log" 2>/dev/null || true
    cp -f "${compile_log}" "${RESULTS_DIR}/${case}.compile.log" 2>/dev/null || true
    cp -f "${SCRIPT_DIR}/work/${case}.asm" "${RESULTS_DIR}/${case}.asm" 2>/dev/null || true
    cp -f "${SCRIPT_DIR}/work/${case}.elf" "${RESULTS_DIR}/${case}.elf" 2>/dev/null || true
    cp -f "${SCRIPT_DIR}/work/symbols.args" "${RESULTS_DIR}/${case}.symbols.args" 2>/dev/null || true
    cp -f "${SCRIPT_DIR}/work/run_case.report" "${RESULTS_DIR}/${case}.run_case.report" 2>/dev/null || true

    if [ -f "${log}" ]; then
        grep -A 200 "Performance Statistics" "${log}" \
            > "${RESULTS_DIR}/${case}.perf" 2>/dev/null || true

        if ! grep -A 2400 "Detailed Performance Statistics" "${log}" \
                > "${detail_log}" 2>/dev/null; then
            rm -f "${detail_log}"
        fi

        if ! grep '^BRANCH_PC' "${log}" > "${branch_pc_log}" 2>/dev/null; then
            rm -f "${branch_pc_log}"
        fi

        grep -E "CoreMark has been run|CoreMark 1.0|Dhrystone|Dhrystones per simulated MHz|DMIPS/MHz|Cycles for one run|CoreMark Size|Iterations       :|Correct operation|TEST PASS|TEST FAIL|Total     \\||Main      \\||Kernel    \\||CPU Time|WARN:" \
            "${log}" > "${RESULTS_DIR}/${case}.summary.txt" 2>/dev/null || true
    fi
}

case_passed() {
    local report="${SCRIPT_DIR}/work/run_case.report"
    local log="${SCRIPT_DIR}/work/run.vcs.log"

    if grep -q "TEST FAIL" "${report}" "${log}" 2>/dev/null; then
        return 1
    fi
    grep -q "TEST PASS" "${report}" 2>/dev/null || \
        grep -q "Correct operation validated" "${log}" 2>/dev/null
}

for CASE in ${BENCH_CASES}; do
    printf "  %-16s ... " "${CASE}"

    LOG="${SCRIPT_DIR}/work/run.vcs.log"
    CASE_LOG="${RESULTS_DIR}/${CASE}.build.log"
    rm -f "${LOG}" \
          "${SCRIPT_DIR}/work/run_case.report" \
          "${SCRIPT_DIR}/work/${CASE}.asm" \
          "${SCRIPT_DIR}/work/${CASE}_build.case.log"

    # build and simulate; save full output for post-mortem on failure
    if make -s simcase CASE="${CASE}" \
            SPEC_COMPOSITE_PROFILE="${SPEC_COMPOSITE_PROFILE}" \
            -C "${SCRIPT_DIR}" > "${CASE_LOG}" 2>&1; then

        archive_case_outputs "${CASE}"

        # check pass/fail from report file
        if case_passed; then
            echo "PASS"
            PASS=$((PASS + 1))
        else
            echo "FAIL (simulation error) -- see ${CASE_LOG}"
            FAIL=$((FAIL + 1))
        fi
    else
        archive_case_outputs "${CASE}"
        if case_passed; then
            echo "PASS (post-run warning) -- see ${CASE_LOG}"
            PASS=$((PASS + 1))
        else
            echo "FAIL (build/run error) -- see ${CASE_LOG}"
            FAIL=$((FAIL + 1))
        fi
    fi
done

if [ -f "${REPO_ROOT}/spec_flow/spec_kernel_profiles.json" ]; then
    RTL_VALIDATION_ARGS=()
    if [ "${PROGRAM_FEATURES}" = on ]; then
        RTL_VALIDATION_ARGS+=(--features-dir "${RESULTS_DIR}/program_features")
    fi
    if grep -q '+define+PERF_DETAIL' "${SCRIPT_DIR}/work/comp.vcs.log" 2>/dev/null; then
        RTL_VALIDATION_ARGS+=(--require-detail)
    fi
    if ! python3 "${REPO_ROOT}/spec_flow/validate_spec_rtl_profiles.py" \
            --contracts "${REPO_ROOT}/spec_flow/spec_kernel_profiles.json" \
            --results-dir "${RESULTS_DIR}" \
            --profile "${SPEC_KERNEL_PROFILE}" \
            --retired-tolerance "${RTL_RETIRED_TOLERANCE}" \
            --allow-missing "${RTL_VALIDATION_ARGS[@]}" \
            > "${RESULTS_DIR}/SPEC_RTL_PROFILE_VALIDATION.md"; then
        echo "WARN: SPEC RTL profile validation failed" >&2
        FAIL=$((FAIL + 1))
    fi
fi

if [ "${PROGRAM_FEATURES}" = on ]; then
    python3 "${SCRIPT_DIR}/analyze_joint_bottleneck.py" \
        --results-dir "${RESULTS_DIR}" \
        --features-dir "${RESULTS_DIR}/program_features" \
        --out-md "${RESULTS_DIR}/PROGRAM_RTL_BOTTLENECK.md" || true
fi

echo ""
echo "=== Summary: ${PASS} passed, ${FAIL} failed ==="
if [ "${FAIL}" -ne 0 ]; then
    exit 1
fi
