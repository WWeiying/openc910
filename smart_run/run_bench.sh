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
RTL_WORKERS="${RTL_WORKERS:-1}"
BENCH_SUITE="${BENCH_SUITE:-default}"
ARCHIVE_FSDB="${ARCHIVE_FSDB:-auto}"
REPLACE_RESULTS=off
RESUME_RESULTS=off
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
  --rtl-workers N              isolated concurrent VCS cases, default 1
  --archive-fsdb               require and archive each case's novas.fsdb
  --no-archive-fsdb            do not archive FSDB files
  --tag NAME                   set result tag; positional TAG remains supported
  --list-cases                 print the effective case list and exit
  --resume-results             reuse only strictly valid completed cases from
                               the same commit, profile, case set, and simv
  --replace-results            explicitly replace an existing same-name directory
  -h, --help                  show this help

Environment equivalents:
  BENCH_SUITE=default|full
  PROGRAM_FEATURES=on
  PROGRAM_FEATURE_PROFILE=rtl|representative
  SPEC_KERNEL_PROFILE=quick|full
  SPEC_COMPOSITE_PROFILE=quick|full  (legacy alias)
  RTL_RETIRED_TOLERANCE=N           default 6
  RTL_WORKERS=N                     isolated VCS workers, 1..8
  ARCHIVE_FSDB=auto|on|off          default auto: archive when FSDB exists
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
        --rtl-workers)
            RTL_WORKERS="$2"; shift 2 ;;
        --archive-fsdb)
            ARCHIVE_FSDB=on; shift ;;
        --no-archive-fsdb)
            ARCHIVE_FSDB=off; shift ;;
        --tag)
            if ((TAG_SEEN)); then
                echo "ERROR: tag specified more than once" >&2
                exit 2
            fi
            TAG="$2"; TAG_SEEN=1; shift 2 ;;
        --replace-results)
            REPLACE_RESULTS=on; shift ;;
        --resume-results)
            RESUME_RESULTS=on; shift ;;
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
if ! [[ "${RTL_WORKERS}" =~ ^[1-8]$ ]]; then
    echo "ERROR: RTL_WORKERS/--rtl-workers must be an integer from 1 to 8" >&2
    exit 2
fi
if [ "${ARCHIVE_FSDB}" != auto ] && [ "${ARCHIVE_FSDB}" != on ] && \
        [ "${ARCHIVE_FSDB}" != off ]; then
    echo "ERROR: ARCHIVE_FSDB must be auto, on, or off" >&2
    exit 2
fi
if [ "${RESUME_RESULTS}" = on ] && [ "${REPLACE_RESULTS}" = on ]; then
    echo "ERROR: --resume-results and --replace-results are mutually exclusive" >&2
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
WORK_SIMV_PATH="${SCRIPT_DIR}/work/simv"
WORK_SIMV_DAIDIR="${SCRIPT_DIR}/work/simv.daidir"
SIMV_PATH="${RESULTS_DIR}/simv"
SIMV_DAIDIR="${RESULTS_DIR}/simv.daidir"
SIMV_DAIDIR_MANIFEST="${RESULTS_DIR}/simv.daidir.sha256"
COMPILE_LOG_PATH="${SCRIPT_DIR}/work/comp.vcs.log"

emit_simv_daidir_manifest() {
    (
        cd "${RESULTS_DIR}"
        find simv.daidir -type f -print0 |
            LC_ALL=C sort -z |
            xargs -0 -r sha256sum
    )
}

verify_simv_daidir_manifest() {
    [ -d "${SIMV_DAIDIR}" ] &&
        [ -s "${SIMV_DAIDIR_MANIFEST}" ] &&
        cmp -s "${SIMV_DAIDIR_MANIFEST}" <(emit_simv_daidir_manifest)
}

RESUMING=off
if [ -e "${RESULTS_DIR}" ]; then
    if [ "${RESUME_RESULTS}" = on ]; then
        RESUMING=on
    elif [ "${REPLACE_RESULTS}" != on ]; then
        echo "ERROR: result directory already exists: ${RESULTS_DIR}" >&2
        echo "       choose another tag, --resume-results, or --replace-results" >&2
        exit 2
    else
        rm -rf "${RESULTS_DIR}"
    fi
fi
mkdir -p "${RESULTS_DIR}"

# Bind every result set to the exact compiled simulator used for all cases.
if [ "${RESUMING}" = on ]; then
    if [ ! -x "${SIMV_PATH}" ]; then
        echo "ERROR: archived simulator is missing or not executable: ${SIMV_PATH}" >&2
        exit 1
    fi
    if ! verify_simv_daidir_manifest; then
        echo "ERROR: archived simv.daidir bundle is missing or inconsistent" >&2
        exit 1
    fi
    SIMV_SHA256="$(sha256sum "${SIMV_PATH}" | awk '{print $1}')"
    SIMV_DAIDIR_MANIFEST_SHA256="$(
        sha256sum "${SIMV_DAIDIR_MANIFEST}" | awk '{print $1}'
    )"
    RUN_INFO="${RESULTS_DIR}/run.info"
    if [ ! -f "${RUN_INFO}" ]; then
        echo "ERROR: cannot resume without ${RUN_INFO}" >&2
        exit 1
    fi
    read_run_info() {
        sed -n "s/^$1=//p" "${RUN_INFO}" | tail -n 1
    }
    normalize_words() {
        awk '{$1=$1; print}' <<< "$1"
    }
    resume_mismatch=0
    check_resume_field() {
        local key="$1"
        local expected="$2"
        local actual
        actual="$(read_run_info "${key}")"
        if [ "${actual}" != "${expected}" ]; then
            echo "ERROR: resume ${key}=${actual:-missing}, expected=${expected}" >&2
            resume_mismatch=1
        fi
    }
    check_resume_field tag "${TAG}"
    check_resume_field bench_suite "${BENCH_SUITE}"
    if [ "$(normalize_words "$(read_run_info bench_cases)")" != \
         "$(normalize_words "${BENCH_CASES}")" ]; then
        echo "ERROR: resume bench_cases do not match the requested case set" >&2
        resume_mismatch=1
    fi
    check_resume_field git_commit "${GIT_COMMIT_FULL}"
    check_resume_field git_dirty "${GIT_DIRTY}"
    check_resume_field program_features "${PROGRAM_FEATURES}"
    check_resume_field program_feature_profile "${PROGRAM_FEATURE_PROFILE}"
    check_resume_field kernel_profile "${SPEC_KERNEL_PROFILE}"
    check_resume_field composite_profile "${SPEC_COMPOSITE_PROFILE}"
    check_resume_field rtl_retired_tolerance "${RTL_RETIRED_TOLERANCE}"
    check_resume_field archive_fsdb "${ARCHIVE_FSDB}"
    check_resume_field simv_sha256 "${SIMV_SHA256}"
    check_resume_field simv_daidir_manifest_sha256 \
        "${SIMV_DAIDIR_MANIFEST_SHA256}"
    check_resume_field perf_detail_compiled on
    COMPILE_LOG_SHA256="$(read_run_info compile_log_sha256)"
    if ! [[ "${COMPILE_LOG_SHA256}" =~ ^[0-9a-fA-F]{64}$ ]] || \
            [ ! -s "${RESULTS_DIR}/comp.vcs.log" ] || \
            [ "$(sha256sum "${RESULTS_DIR}/comp.vcs.log" | awk '{print $1}')" != \
              "${COMPILE_LOG_SHA256}" ]; then
        echo "ERROR: resume compile log provenance is missing or inconsistent" >&2
        resume_mismatch=1
    fi
    if [ ! -f "${RESULTS_DIR}/git.status" ] || \
            [ -s "${RESULTS_DIR}/git.status" ] || \
            [ ! -f "${RESULTS_DIR}/git.diff" ] || \
            [ -s "${RESULTS_DIR}/git.diff" ]; then
        echo "ERROR: resume Git snapshots are missing or not clean" >&2
        resume_mismatch=1
    fi
    if [ "${resume_mismatch}" -ne 0 ]; then
        exit 1
    fi
    PERF_DETAIL_COMPILED=on
else
    if [ ! -x "${WORK_SIMV_PATH}" ]; then
        echo "ERROR: work/simv not found. Run 'make compile' first." >&2
        exit 1
    fi
    if [ ! -d "${WORK_SIMV_DAIDIR}" ]; then
        echo "ERROR: work/simv.daidir not found. Run 'make compile' first." >&2
        exit 1
    fi
    cp -p --reflink=auto "${WORK_SIMV_PATH}" "${SIMV_PATH}"
    cp -a --reflink=auto "${WORK_SIMV_DAIDIR}" "${SIMV_DAIDIR}"
    emit_simv_daidir_manifest > "${SIMV_DAIDIR_MANIFEST}"
    SIMV_SHA256="$(sha256sum "${SIMV_PATH}" | awk '{print $1}')"
    SIMV_DAIDIR_MANIFEST_SHA256="$(
        sha256sum "${SIMV_DAIDIR_MANIFEST}" | awk '{print $1}'
    )"
    if [ -s "${COMPILE_LOG_PATH}" ]; then
        cp -f "${COMPILE_LOG_PATH}" "${RESULTS_DIR}/comp.vcs.log"
        COMPILE_LOG_SHA256="$(sha256sum "${RESULTS_DIR}/comp.vcs.log" | awk '{print $1}')"
        if grep -q '+define+PERF_DETAIL' "${RESULTS_DIR}/comp.vcs.log"; then
            PERF_DETAIL_COMPILED=on
        else
            PERF_DETAIL_COMPILED=off
        fi
    else
        COMPILE_LOG_SHA256=missing
        PERF_DETAIL_COMPILED=unknown
    fi
fi

exec > >(tee -a "${RESULTS_DIR}/run.console.log") 2>&1

echo "=== run_bench: TAG=${TAG} ==="
echo "Results -> ${RESULTS_DIR}"
echo "Git     -> ${GIT_COMMIT} (${GIT_DIRTY}, ${GIT_BRANCH})"
echo "Resume  -> ${RESUMING}"
echo "Workers -> ${RTL_WORKERS}"
echo "FSDB    -> ${ARCHIVE_FSDB} archive policy"
echo ""

if [ "${RESUMING}" = on ]; then
    printf 'resume_utc=%s pid=%s rtl_workers=%s\n' \
        "$(date -u +%FT%TZ)" "$$" "${RTL_WORKERS}" \
        >> "${RESULTS_DIR}/resume.log"
else
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
        echo "rtl_workers=${RTL_WORKERS}"
        echo "archive_fsdb=${ARCHIVE_FSDB}"
        echo "simv_sha256=${SIMV_SHA256}"
        echo "simv_daidir_manifest_sha256=${SIMV_DAIDIR_MANIFEST_SHA256}"
        echo "compile_log_sha256=${COMPILE_LOG_SHA256}"
        echo "perf_detail_compiled=${PERF_DETAIL_COMPILED}"
    } > "${RESULTS_DIR}/run.info"

    git -C "${REPO_ROOT}" status --short > "${RESULTS_DIR}/git.status" 2>/dev/null || true
    git -C "${REPO_ROOT}" diff > "${RESULTS_DIR}/git.diff" 2>/dev/null || true
fi

PASS=0
FAIL=0

FEATURE_DIR=""
if [ "${PROGRAM_FEATURES}" = on ]; then
    FEATURE_DIR="${RESULTS_DIR}/program_features"
    FEATURE_LOG="${RESULTS_DIR}/program_features.log"
    mapfile -t FEATURE_CASES < <(
        tr '[:space:]' '\n' <<< "${BENCH_CASES}" | sed '/^$/d'
    )
    echo "=== Program features: profile=${PROGRAM_FEATURE_PROFILE} ==="
    echo "Program features -> ${FEATURE_DIR}"
    FEATURE_CHECK_ARGS=()
    for feature_case in "${FEATURE_CASES[@]}"; do
        FEATURE_CHECK_ARGS+=(--expected-case "${feature_case}")
    done
    FEATURE_COMPLETE=off
    if [ "${RESUMING}" = on ] && \
            python3 "${REPO_ROOT}/spec_flow/check_feature_evidence.py" \
                --root "${FEATURE_DIR}" \
                --profile "${SPEC_KERNEL_PROFILE}" \
                --commit "${GIT_COMMIT_FULL}" \
                "${FEATURE_CHECK_ARGS[@]}" >/dev/null 2>&1; then
        FEATURE_COMPLETE=on
    fi
    if [ "${FEATURE_COMPLETE}" = on ]; then
        echo "Program characterization RESUME_PASS"
    elif ! SPEC_KERNEL_PROFILE="${SPEC_KERNEL_PROFILE}" \
            "${SCRIPT_DIR}/run_kernel_characterization.sh" \
            --profile "${PROGRAM_FEATURE_PROFILE}" \
            --tag "${TAG}" \
            --output-dir "${FEATURE_DIR}" \
            --assume-lock-held \
            "${FEATURE_CASES[@]}" > "${FEATURE_LOG}" 2>&1; then
        echo "ERROR: program characterization failed; see ${FEATURE_LOG}" >&2
        exit 1
    else
        echo "Program characterization PASS"
    fi
    if ! grep -q '^program_feature_dir=' "${RESULTS_DIR}/run.info"; then
        echo "program_feature_dir=${FEATURE_DIR}" >> "${RESULTS_DIR}/run.info"
    fi
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

write_waveform_status() {
    local case="$1"
    local status="$2"
    local archive_path="${3:-}"
    local status_dir="${RESULTS_DIR}/waveforms"
    local status_path="${status_dir}/${case}.status"
    local temporary

    mkdir -p "${status_dir}"
    temporary="$(mktemp "${status_dir}/.${case}.status.XXXXXX")"
    {
        echo "case=${case}"
        echo "archive_mode=${ARCHIVE_FSDB}"
        echo "status=${status}"
        echo "archive_path=${archive_path}"
    } > "${temporary}"
    mv "${temporary}" "${status_path}"
}

archive_case_waveform() {
    local case="$1"
    local source_dir="${2:-${SCRIPT_DIR}/work}"
    local source_fsdb="${source_dir}/novas.fsdb"
    local archive_dir="${RESULTS_DIR}/waveforms/${case}"

    if [ "${ARCHIVE_FSDB}" = off ]; then
        write_waveform_status "${case}" disabled
        return 0
    fi
    if [ ! -s "${source_fsdb}" ]; then
        if [ "${ARCHIVE_FSDB}" = on ]; then
            write_waveform_status "${case}" missing
            echo "ERROR: ${case}: ARCHIVE_FSDB=on but no non-empty novas.fsdb was produced" >&2
            return 1
        fi
        write_waveform_status "${case}" not-generated
        return 0
    fi

    bash "${SCRIPT_DIR}/archive_waveform.sh" \
        --mode on \
        --case "${case}" \
        --label "${case}" \
        --tag "${TAG}" \
        --git-commit "${GIT_COMMIT_FULL}" \
        --git-state "${GIT_DIRTY}" \
        --source-dir "${source_dir}" \
        --output-dir "${archive_dir}"
    write_waveform_status "${case}" archived "${archive_dir}"
}

archive_case_outputs() {
    local case="$1"
    local source_dir="${2:-${SCRIPT_DIR}/work}"
    local log="${source_dir}/run.vcs.log"
    local compile_log="${source_dir}/${case}_build.case.log"
    local detail_log="${RESULTS_DIR}/${case}.detail.perf"
    local branch_pc_log="${RESULTS_DIR}/${case}.branch_pc.perf"

    cp -f "${log}" "${RESULTS_DIR}/${case}.run.vcs.log" 2>/dev/null || true
    cp -f "${compile_log}" "${RESULTS_DIR}/${case}.compile.log" 2>/dev/null || true
    cp -f "${source_dir}/${case}.asm" "${RESULTS_DIR}/${case}.asm" 2>/dev/null || true
    cp -f "${source_dir}/${case}.elf" "${RESULTS_DIR}/${case}.elf" 2>/dev/null || true
    cp -f "${source_dir}/symbols.args" "${RESULTS_DIR}/${case}.symbols.args" 2>/dev/null || true
    cp -f "${source_dir}/run_case.report" "${RESULTS_DIR}/${case}.run_case.report" 2>/dev/null || true
    cp -f "${source_dir}/simv.console.log" \
        "${RESULTS_DIR}/${case}.simv.console.log" 2>/dev/null || true

    archive_case_waveform "${case}" "${source_dir}"

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
    local source_dir="${1:-${SCRIPT_DIR}/work}"
    local report="${source_dir}/run_case.report"
    local log="${source_dir}/run.vcs.log"

    if grep -q "TEST FAIL" "${report}" "${log}" 2>/dev/null; then
        return 1
    fi
    grep -q "TEST PASS" "${report}" 2>/dev/null || \
        grep -q "Correct operation validated" "${log}" 2>/dev/null
}

archived_case_complete() {
    local case="$1"
    local args=(
        --case "${case}"
        --results-dir "${RESULTS_DIR}"
        --contracts "${REPO_ROOT}/spec_flow/spec_kernel_profiles.json"
        --profile "${SPEC_KERNEL_PROFILE}"
        --retired-tolerance "${RTL_RETIRED_TOLERANCE}"
        --expected-detail-rows "${L2PLUS_EXPECTED_DETAIL_ROWS:-1048}"
    )
    if [ -n "${FEATURE_DIR}" ]; then
        args+=(--features-dir "${FEATURE_DIR}")
    fi
    if ! python3 "${REPO_ROOT}/spec_flow/check_rtl_evidence_case.py" \
            "${args[@]}" >/dev/null 2>&1; then
        return 1
    fi

    local status_file="${RESULTS_DIR}/waveforms/${case}.status"
    local expected_status
    [ -s "${status_file}" ] || return 1
    expected_status="$(sed -n 's/^status=//p' "${status_file}" | tail -n 1)"
    case "${expected_status}" in
        archived)
            [ -s "${RESULTS_DIR}/waveforms/${case}/novas.fsdb" ] &&
                [ -s "${RESULTS_DIR}/waveforms/${case}/waveform.info" ] ;;
        not-generated)
            [ "${ARCHIVE_FSDB}" = auto ] ;;
        disabled)
            [ "${ARCHIVE_FSDB}" = off ] ;;
        *) return 1 ;;
    esac
}

clear_archived_case() {
    local case="$1"
    local suffix
    for suffix in \
        .run_case.report .summary.txt .perf .detail.perf .run.vcs.log \
        .asm .elf .symbols.args .build.log .compile.log .branch_pc.perf \
        .simv.console.log; do
        rm -f "${RESULTS_DIR}/${case}${suffix}"
    done
    rm -rf "${RESULTS_DIR}/waveforms/${case}"
    rm -f "${RESULTS_DIR}/waveforms/${case}.status"
}

run_sequential_cases() {
  local CASE LOG CASE_LOG

  for CASE in ${BENCH_CASES}; do
      printf "  %-16s ... " "${CASE}"

      if [ "${RESUMING}" = on ] && archived_case_complete "${CASE}"; then
          echo "RESUME_PASS"
          PASS=$((PASS + 1))
          continue
      fi
      if [ "${RESUMING}" = on ]; then
          clear_archived_case "${CASE}"
      fi

      LOG="${SCRIPT_DIR}/work/run.vcs.log"
      CASE_LOG="${RESULTS_DIR}/${CASE}.build.log"
      rm -f "${LOG}" \
            "${SCRIPT_DIR}/work/run_case.report" \
            "${SCRIPT_DIR}/work/novas.fsdb" \
            "${SCRIPT_DIR}/work/${CASE}.asm" \
            "${SCRIPT_DIR}/work/${CASE}_build.case.log"

      # Build and simulate; save full output for post-mortem on failure.
      if make -s simcase CASE="${CASE}" \
              SPEC_COMPOSITE_PROFILE="${SPEC_COMPOSITE_PROFILE}" \
              ARCHIVE_FSDB=off \
              SIMV_BINARY="${SIMV_PATH}" \
              -C "${SCRIPT_DIR}" > "${CASE_LOG}" 2>&1; then

          archive_case_outputs "${CASE}"

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
}

stage_parallel_case() {
    local case="$1"
    local stage="$2"
    local case_log="${RESULTS_DIR}/${case}.build.log"
    local feature_elf

    clear_archived_case "${case}"
    rm -rf "${stage}"
    mkdir -p "${stage}"
    if ! make -s buildcase CASE="${case}" \
            SPEC_COMPOSITE_PROFILE="${SPEC_COMPOSITE_PROFILE}" \
            -C "${SCRIPT_DIR}" > "${case_log}" 2>&1; then
        return 1
    fi
    cp -f "${SCRIPT_DIR}/work/"*.pat "${stage}/"
    cp -f "${SCRIPT_DIR}/work/symbols.args" "${stage}/"
    cp -f "${SCRIPT_DIR}/work/${case}.asm" "${stage}/"
    cp -f "${SCRIPT_DIR}/work/${case}.elf" "${stage}/"
    cp -f "${SCRIPT_DIR}/work/${case}_build.case.log" "${stage}/"

    if [ -n "${FEATURE_DIR}" ]; then
        feature_elf="${FEATURE_DIR}/cases/${case}/${case}.elf"
        if [ ! -s "${feature_elf}" ] || \
                [ "$(sha256sum "${feature_elf}" | awk '{print $1}')" != \
                  "$(sha256sum "${stage}/${case}.elf" | awk '{print $1}')" ]; then
            echo "ERROR: ${case}: staged RTL ELF does not match feature ELF" \
                >> "${case_log}"
            return 1
        fi
    fi
}

run_parallel_cases() {
    local stage_root="${RESULTS_DIR}/.rtl_stage"
    local CASE stage
    local -a prepared=()

    rm -rf "${stage_root}"
    mkdir -p "${stage_root}"
    for CASE in ${BENCH_CASES}; do
        printf "  %-38s ... " "${CASE}"
        if [ "${RESUMING}" = on ] && archived_case_complete "${CASE}"; then
            echo "RESUME_PASS"
            PASS=$((PASS + 1))
            continue
        fi
        stage="${stage_root}/${CASE}"
        if stage_parallel_case "${CASE}" "${stage}"; then
            prepared+=("${CASE}")
            echo "STAGED"
        else
            echo "BUILD_FAIL -- see ${RESULTS_DIR}/${CASE}.build.log"
            FAIL=$((FAIL + 1))
        fi
    done

    if ((${#prepared[@]})); then
        printf '%s\0' "${prepared[@]}" |
            xargs -0 -r -P "${RTL_WORKERS}" -n 1 \
                bash "${SCRIPT_DIR}/run_staged_rtl_case.sh" \
                "${SIMV_PATH}" "${stage_root}" || true
    fi

    echo ""
    echo "=== Parallel RTL results ==="
    for CASE in "${prepared[@]}"; do
        stage="${stage_root}/${CASE}"
        printf "  %-38s ... " "${CASE}"
        archive_case_outputs "${CASE}" "${stage}"
        if case_passed "${stage}"; then
            echo "PASS"
            PASS=$((PASS + 1))
            rm -rf "${stage}"
        else
            echo "FAIL -- see ${RESULTS_DIR}/${CASE}.simv.console.log"
            FAIL=$((FAIL + 1))
        fi
    done
    if [ "${FAIL}" -eq 0 ]; then
        rmdir "${stage_root}" 2>/dev/null || true
    fi
}

if [ "${RTL_WORKERS}" -eq 1 ]; then
    run_sequential_cases
else
    run_parallel_cases
fi

if [ -f "${REPO_ROOT}/spec_flow/spec_kernel_profiles.json" ]; then
    RTL_VALIDATION_ARGS=()
    if [ "${PROGRAM_FEATURES}" = on ]; then
        RTL_VALIDATION_ARGS+=(--features-dir "${RESULTS_DIR}/program_features")
    fi
    if [ "${PERF_DETAIL_COMPILED}" = on ]; then
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
