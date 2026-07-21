#!/bin/bash
# Build and characterize every benchmark Kernel interval without running RTL.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
TOOLCHAIN="${REPO_ROOT}/toolchains/Xuantie-900-gcc-elf-newlib-x86_64-V3.1.0"
NM="${TOOLCHAIN}/bin/riscv64-unknown-elf-nm"
OBJDUMP="${TOOLCHAIN}/bin/riscv64-unknown-elf-objdump"
CONTAINER="${DOCKER_CONTAINER:-openc910-qemu}"
QEMU="/work/toolchains/Xuantie-qemu-x86_64-Ubuntu-20.04-V5.2.8-B20250721-0303/bin/qemu-system-riscv64"
PLUGIN="/work/tools/qemu-plugins/kernel_trace.so"
TAG="kernel_features"
PROFILE="representative"
SPEC_KERNEL_PROFILE="${SPEC_KERNEL_PROFILE:-${SPEC_COMPOSITE_PROFILE:-}}"
RTL_RESULTS=""
RTL_RETIRED_TOLERANCE="${RTL_RETIRED_TOLERANCE:-6}"
MAX_INSTRUCTIONS="${MAX_INSTRUCTIONS:-1000000000}"
KEEP_RAW_TRACE="${KEEP_RAW_TRACE:-0}"
OUTPUT_DIR=""
ASSUME_LOCK_HELD=0
CASES=()

usage() {
    cat <<'EOF'
Usage: ./run_kernel_characterization.sh [options] [case ...]

Options:
  --tag NAME               output tag, default kernel_features
  --rtl-results DIR        validate trace count against DIR/<case>.summary.txt
  --rtl-retired-tolerance N allow N instructions of retire-boundary skew, default 6
  --profile MODE           representative (default) or rtl
  --max-instructions N     fail-safe limit per case, default 1000000000
  --keep-raw-trace         keep uncompressed .ktrace after analysis
  --output-dir DIR         write directly to DIR instead of kernel_features/<tag>_...
  --assume-lock-held       parent workflow already owns .run_bench.lock

With no case arguments, all coremark/dhrystone/bench_*/spec_* cases are used.
EOF
}

while (($#)); do
    case "$1" in
        --tag)
            TAG="$2"; shift 2 ;;
        --rtl-results)
            RTL_RESULTS="$(realpath "$2")"; shift 2 ;;
        --rtl-retired-tolerance)
            RTL_RETIRED_TOLERANCE="$2"; shift 2 ;;
        --profile)
            PROFILE="$2"; shift 2 ;;
        --max-instructions)
            MAX_INSTRUCTIONS="$2"; shift 2 ;;
        --keep-raw-trace)
            KEEP_RAW_TRACE=1; shift ;;
        --output-dir)
            OUTPUT_DIR="$2"; shift 2 ;;
        --assume-lock-held)
            ASSUME_LOCK_HELD=1; shift ;;
        -h|--help)
            usage; exit 0 ;;
        --)
            shift; CASES+=("$@"); break ;;
        -*)
            echo "ERROR: unknown option $1" >&2; usage >&2; exit 2 ;;
        *)
            CASES+=("$1"); shift ;;
    esac
done

if [[ "${PROFILE}" != rtl && "${PROFILE}" != representative ]]; then
    echo "ERROR: --profile must be rtl or representative" >&2
    exit 2
fi
if [[ ! "${RTL_RETIRED_TOLERANCE}" =~ ^[0-9]+$ ]]; then
    echo "ERROR: --rtl-retired-tolerance must be a non-negative integer" >&2
    exit 2
fi
if [[ -z "${SPEC_KERNEL_PROFILE}" ]]; then
    if [[ "${PROFILE}" == representative ]]; then
        SPEC_KERNEL_PROFILE=full
    else
        SPEC_KERNEL_PROFILE=quick
    fi
fi
if [[ "${SPEC_KERNEL_PROFILE}" != quick && \
      "${SPEC_KERNEL_PROFILE}" != full ]]; then
    echo "ERROR: SPEC_KERNEL_PROFILE must be quick or full" >&2
    exit 2
fi
SPEC_COMPOSITE_PROFILE="${SPEC_KERNEL_PROFILE}"
if [[ "${PROFILE}" == representative && -n "${RTL_RESULTS}" ]]; then
    echo "WARN: ignoring --rtl-results for representative profile" >&2
    RTL_RESULTS=""
fi

if ((${#CASES[@]} == 0)); then
    mapfile -t CASES < <(
        make -s -C "${SCRIPT_DIR}" showcase |
            awk '{print $1}' |
            grep -E '^(coremark|dhrystone|bench_|spec_)'
    )
fi

GIT_SHORT="$(git -C "${REPO_ROOT}" rev-parse --short=12 HEAD 2>/dev/null || echo unknown)"
GIT_FULL="$(git -C "${REPO_ROOT}" rev-parse HEAD 2>/dev/null || echo unknown)"
if [[ -n "$(git -C "${REPO_ROOT}" status --porcelain 2>/dev/null || true)" ]]; then
    GIT_STATE=dirty
else
    GIT_STATE=clean
fi
if [[ -n "${OUTPUT_DIR}" ]]; then
    mkdir -p "${OUTPUT_DIR}"
    OUT_ROOT="$(realpath "${OUTPUT_DIR}")"
else
    OUT_ROOT="${SCRIPT_DIR}/kernel_features/${TAG}_${PROFILE}_${GIT_SHORT}_${GIT_STATE}"
fi
case "${OUT_ROOT}" in
    "${REPO_ROOT}"/*) ;;
    *)
        echo "ERROR: output directory must be under ${REPO_ROOT} so Docker can access traces" >&2
        exit 2 ;;
esac
CASE_ROOT="${OUT_ROOT}/cases"
mkdir -p "${CASE_ROOT}"

if [[ "${ASSUME_LOCK_HELD}" != 1 ]]; then
    exec 9>"${SCRIPT_DIR}/.run_bench.lock"
    if ! flock -n 9; then
        echo "ERROR: run_bench/buildcase is active; smart_run/work is shared." >&2
        exit 1
    fi
    printf '%s\n' "$$" 1>&9
fi

docker exec "${CONTAINER}" bash -lc \
    'cd /work/tools/qemu-plugins && make -s kernel_trace.so'

qemu_version="$(docker exec "${CONTAINER}" bash -lc "${QEMU} --version | head -n 1")"
compiler_version="$(${TOOLCHAIN}/bin/riscv64-unknown-elf-gcc --version | head -n 1)"
{
    printf 'schema_version=1\n'
    printf 'git_commit=%s\n' "${GIT_FULL}"
    printf 'git_state=%s\n' "${GIT_STATE}"
    printf 'qemu=%s\n' "${qemu_version}"
    printf 'compiler=%s\n' "${compiler_version}"
    printf 'max_instructions=%s\n' "${MAX_INSTRUCTIONS}"
    printf 'profile=%s\n' "${PROFILE}"
    printf 'kernel_profile=%s\n' "${SPEC_KERNEL_PROFILE}"
    printf 'composite_profile=%s\n' "${SPEC_COMPOSITE_PROFILE}"
    printf 'parent_lock=%s\n' "${ASSUME_LOCK_HELD}"
    printf 'rtl_results=%s\n' "${RTL_RESULTS:-none}"
    printf 'rtl_retired_tolerance=%s\n' "${RTL_RETIRED_TOLERANCE}"
    printf 'cases=%s\n' "${CASES[*]}"
} > "${OUT_ROOT}/run.info"
git -C "${REPO_ROOT}" status --short > "${OUT_ROOT}/git.status" || true
git -C "${REPO_ROOT}" diff > "${OUT_ROOT}/git.diff" || true

PASS=0
FAIL=0
for case_name in "${CASES[@]}"; do
    CASE_BUILD_ARGS=(
        SPEC_COMPOSITE_PROFILE="${SPEC_COMPOSITE_PROFILE}"
    )
    if [[ "${PROFILE}" == representative && "${case_name}" == coremark ]]; then
        CASE_BUILD_ARGS+=(COREMARK_ITERATIONS=3)
    fi
    case_dir="${CASE_ROOT}/${case_name}"
    mkdir -p "${case_dir}"
    printf '  %-38s ' "${case_name}"
    if ! nice -n 10 make --no-print-directory -C "${SCRIPT_DIR}" \
            buildcase CASE="${case_name}" \
            "${CASE_BUILD_ARGS[@]}" \
            > "${case_dir}/build.log" 2>&1; then
        echo "BUILD_FAIL"
        FAIL=$((FAIL + 1))
        continue
    fi

    elf="${SCRIPT_DIR}/work/${case_name}.elf"
    if [[ ! -f "${elf}" ]]; then
        echo "NO_ELF"
        FAIL=$((FAIL + 1))
        continue
    fi
    start_hex="$(${NM} -n "${elf}" | awk '$3 == "perf_monitor_start" {print $1; exit}')"
    end_hex="$(${NM} -n "${elf}" | awk '$3 == "perf_monitor_end" {print $1; exit}')"
    warmup_start_hex="$(${NM} -n "${elf}" | awk '$3 == "perf_warmup_start" {print $1; exit}')"
    warmup_end_hex="$(${NM} -n "${elf}" | awk '$3 == "perf_warmup_end" {print $1; exit}')"
    if [[ -z "${start_hex}" || -z "${end_hex}" ]]; then
        echo "NO_KERNEL_MARKERS"
        FAIL=$((FAIL + 1))
        continue
    fi

    cp -f "${elf}" "${case_dir}/${case_name}.elf"
    cp -f "${SCRIPT_DIR}/work/${case_name}.asm" "${case_dir}/" 2>/dev/null || true
    cp -f "${SCRIPT_DIR}/work/${case_name}_build.case.log" "${case_dir}/compile.log" 2>/dev/null || true
    cp -f "${SCRIPT_DIR}/work/linker.lcf" "${case_dir}/" 2>/dev/null || true
    cp -f "${SCRIPT_DIR}/work/symbols.args" "${case_dir}/" 2>/dev/null || true
    cp -f "${SCRIPT_DIR}/work/main.c" "${case_dir}/source.c" 2>/dev/null || true
    make -s --no-print-directory -C "${SCRIPT_DIR}/work" \
        print-compiler-config CASENAME="${case_name}" COMPILER=gcc \
        CPU_ARCH_FLAG_0=c910 GCC_PATH="${TOOLCHAIN}/bin" \
        "${CASE_BUILD_ARGS[@]}" > "${case_dir}/compiler.flags"
    {
        printf 'profile=%s\n' "${PROFILE}"
        printf 'kernel_profile=%s\n' "${SPEC_KERNEL_PROFILE}"
        printf 'composite_profile=%s\n' "${SPEC_COMPOSITE_PROFILE}"
        printf 'build_args=%s\n' "${CASE_BUILD_ARGS[*]:-none}"
        printf 'qemu_harness_adjustment=none\n'
    } > "${case_dir}/profile.info"
    ${OBJDUMP} -d -S -M no-aliases "${elf}" > "${case_dir}/${case_name}.objdump"

    trace="${case_dir}/${case_name}.ktrace"
    container_elf="/work/${elf#${REPO_ROOT}/}"
    container_trace="/work/${trace#${REPO_ROOT}/}"
    if ! docker exec "${CONTAINER}" bash -lc \
        "nice -n 10 ${QEMU} -M smarth -cpu c910 -nographic -monitor none -serial none -bios none \
         -kernel '${container_elf}' \
         -plugin '${PLUGIN},outfile=${container_trace},start=0x${start_hex},end=0x${end_hex},max_instructions=${MAX_INSTRUCTIONS}'" \
         > "${case_dir}/qemu.stdout" 2> "${case_dir}/qemu.stderr"; then
        echo "TRACE_FAIL"
        FAIL=$((FAIL + 1))
        continue
    fi

    warmup_instructions=""
    if [[ -n "${warmup_start_hex}" && "${warmup_start_hex}" == "${warmup_end_hex}" ]]; then
        warmup_instructions=0
    elif [[ -n "${warmup_start_hex}" && -n "${warmup_end_hex}" ]]; then
        warmup_trace="${case_dir}/${case_name}.warmup.ktrace"
        container_warmup_trace="/work/${warmup_trace#${REPO_ROOT}/}"
        if docker exec "${CONTAINER}" bash -lc \
            "nice -n 10 ${QEMU} -M smarth -cpu c910 -nographic -monitor none -serial none -bios none \
             -kernel '${container_elf}' \
             -plugin '${PLUGIN},outfile=${container_warmup_trace},start=0x${warmup_start_hex},end=0x${warmup_end_hex},max_instructions=${MAX_INSTRUCTIONS}'" \
             > "${case_dir}/qemu.warmup.stdout" \
             2> "${case_dir}/qemu.warmup.stderr"; then
            warmup_instructions="$(sed -n \
                's/.*instructions=\([0-9][0-9]*\).*/\1/p' \
                "${case_dir}/qemu.warmup.stderr" | tail -n 1)"
            rm -f "${warmup_trace}"
        fi
    fi
    printf 'warmup_instructions=%s\n' "${warmup_instructions:-unavailable}" \
        >> "${case_dir}/profile.info"

    rtl_args=()
    rtl_retired=""
    if [[ -n "${RTL_RESULTS}" && -f "${RTL_RESULTS}/${case_name}.summary.txt" ]]; then
        rtl_retired="$(sed -n \
            's/^|[[:space:]]*Kernel[[:space:]]*|[[:space:]]*[0-9][0-9]*[[:space:]]*|[[:space:]]*\([0-9][0-9]*\).*/\1/p' \
            "${RTL_RESULTS}/${case_name}.summary.txt" | head -n 1)"
        if [[ -n "${rtl_retired}" ]]; then
            rtl_args=(
                --rtl-retired "${rtl_retired}"
                --rtl-retired-tolerance "${RTL_RETIRED_TOLERANCE}"
            )
        fi
    fi

    profile_args=(--kernel-profile "${SPEC_KERNEL_PROFILE}")
    if [[ -n "${warmup_instructions}" ]]; then
        profile_args+=(--warmup-instructions "${warmup_instructions}")
    fi
    if python3 "${SCRIPT_DIR}/kernel_characterize.py" \
            --case "${case_name}" --elf "${elf}" --trace "${trace}" \
            --objdump "${OBJDUMP}" "${rtl_args[@]}" \
            "${profile_args[@]}" \
            --out-json "${case_dir}/features.json" \
            --out-md "${case_dir}/README.md" \
            > "${case_dir}/analyze.log" 2>&1; then
        echo "PASS"
        PASS=$((PASS + 1))
    else
        echo "ANALYZE_FAIL"
        FAIL=$((FAIL + 1))
        continue
    fi

    if [[ "${KEEP_RAW_TRACE}" != 1 ]] && command -v zstd >/dev/null 2>&1; then
        zstd -q -f --rm "${trace}" -o "${trace}.zst"
    fi
done

python3 "${SCRIPT_DIR}/aggregate_kernel_features.py" \
    --cases-dir "${CASE_ROOT}" \
    --out-csv "${OUT_ROOT}/kernel_features.csv" \
    --out-json "${OUT_ROOT}/kernel_features.json" \
    --out-md "${OUT_ROOT}/README.md"

validation_args=()
for case_name in "${CASES[@]}"; do
    validation_args+=(--expected-case "${case_name}")
done
if ! python3 "${SCRIPT_DIR}/validate_kernel_features.py" \
        --cases-dir "${CASE_ROOT}" "${validation_args[@]}" \
        --out-md "${OUT_ROOT}/VALIDATION.md"; then
    FAIL=$((FAIL + 1))
fi

if ! python3 "${REPO_ROOT}/spec_flow/validate_composite_features.py" \
        --kernel-map "${REPO_ROOT}/spec_flow/spec2017_kernel_map.json" \
        --kernel-map "${REPO_ROOT}/spec_flow/spec2017_speed_kernel_map.json" \
        --features-dir "${OUT_ROOT}" --profile "${SPEC_KERNEL_PROFILE}" \
        --allow-missing \
        > "${OUT_ROOT}/COMPOSITE_MIX_VALIDATION.md"; then
    FAIL=$((FAIL + 1))
fi

PROFILE_CONTRACTS="${REPO_ROOT}/spec_flow/spec_kernel_profiles.json"
if [[ -f "${PROFILE_CONTRACTS}" ]]; then
    if ! python3 "${REPO_ROOT}/spec_flow/validate_spec_profiles.py" \
            --contracts "${PROFILE_CONTRACTS}" \
            --features-dir "${OUT_ROOT}" --profile "${SPEC_KERNEL_PROFILE}" \
            --allow-missing > "${OUT_ROOT}/SPEC_PROFILE_VALIDATION.md"; then
        FAIL=$((FAIL + 1))
    fi
fi

printf '\nSummary: %d passed, %d failed\n' "${PASS}" "${FAIL}"
printf 'Results: %s\n' "${OUT_ROOT}"
((FAIL == 0))
