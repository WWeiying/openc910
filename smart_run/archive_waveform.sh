#!/usr/bin/env bash
set -euo pipefail

MODE=auto
CASE_NAME=""
LABEL=""
SOURCE_DIR=""
OUTPUT_DIR=""
OUTPUT_ROOT=""
TAG=""
GIT_COMMIT=""
GIT_STATE=""

usage() {
    cat <<'EOF'
Usage: archive_waveform.sh --case CASE --source-dir DIR [options]

Archive one completed smart_run waveform and the files needed by the FSDB
Notebook. The archive is copied through a temporary directory and is never
silently overwritten.

Required:
  --case CASE             benchmark case name
  --source-dir DIR        directory containing novas.fsdb and run files

Destination (choose one):
  --output-dir DIR        exact archive directory
  --output-root DIR       create LABEL_<git>_<state>__<run-id> below DIR

Options:
  --mode auto|on|off      auto archives only when novas.fsdb exists; on treats
                          a missing FSDB as an error; default auto
  --label LABEL           readable label used with --output-root
  --tag TAG               parent benchmark run tag recorded in waveform.info
  --git-commit COMMIT     Git commit recorded in waveform.info
  --git-state STATE       clean/dirty state recorded in waveform.info
  -h, --help              show this help
EOF
}

while (($#)); do
    case "$1" in
        --case) CASE_NAME="${2:?missing value for --case}"; shift 2 ;;
        --source-dir) SOURCE_DIR="${2:?missing value for --source-dir}"; shift 2 ;;
        --output-dir) OUTPUT_DIR="${2:?missing value for --output-dir}"; shift 2 ;;
        --output-root) OUTPUT_ROOT="${2:?missing value for --output-root}"; shift 2 ;;
        --mode) MODE="${2:?missing value for --mode}"; shift 2 ;;
        --label) LABEL="${2:?missing value for --label}"; shift 2 ;;
        --tag) TAG="${2:?missing value for --tag}"; shift 2 ;;
        --git-commit) GIT_COMMIT="${2:?missing value for --git-commit}"; shift 2 ;;
        --git-state) GIT_STATE="${2:?missing value for --git-state}"; shift 2 ;;
        -h|--help) usage; exit 0 ;;
        *) echo "ERROR: unknown option: $1" >&2; usage >&2; exit 2 ;;
    esac
done

case "${MODE}" in
    auto|on|off) ;;
    *) echo "ERROR: --mode must be auto, on, or off" >&2; exit 2 ;;
esac
if [ "${MODE}" = off ]; then
    exit 0
fi
if [ -z "${CASE_NAME}" ] || [ -z "${SOURCE_DIR}" ]; then
    echo "ERROR: --case and --source-dir are required" >&2
    usage >&2
    exit 2
fi
if { [ -n "${OUTPUT_DIR}" ] && [ -n "${OUTPUT_ROOT}" ]; } || \
        { [ -z "${OUTPUT_DIR}" ] && [ -z "${OUTPUT_ROOT}" ]; }; then
    echo "ERROR: specify exactly one of --output-dir and --output-root" >&2
    exit 2
fi

SOURCE_DIR="$(realpath "${SOURCE_DIR}")"
SOURCE_FSDB="${SOURCE_DIR}/novas.fsdb"
if [ ! -s "${SOURCE_FSDB}" ]; then
    if [ "${MODE}" = on ]; then
        echo "ERROR: non-empty source FSDB not found: ${SOURCE_FSDB}" >&2
        exit 1
    fi
    echo "No FSDB produced for ${CASE_NAME}; waveform archive skipped."
    exit 0
fi

if [ -z "${GIT_COMMIT}" ]; then
    GIT_COMMIT="$(git -C "${SOURCE_DIR}" rev-parse HEAD 2>/dev/null || echo unknown)"
fi
if [ -z "${GIT_STATE}" ]; then
    if git -C "${SOURCE_DIR}" rev-parse --is-inside-work-tree >/dev/null 2>&1 &&
            [ -n "$(git -C "${SOURCE_DIR}" status --porcelain 2>/dev/null || true)" ]; then
        GIT_STATE=dirty
    else
        GIT_STATE=clean
    fi
fi

SOURCE_IDENTITY="$(
    stat -Lc '%n|%s|%y|%z|%d|%i' "${SOURCE_FSDB}" |
        sha256sum | cut -c1-12
)"
GIT_SHORT="${GIT_COMMIT:0:12}"
[ -n "${LABEL}" ] || LABEL="${CASE_NAME}"
SAFE_LABEL="$(sed 's/[^A-Za-z0-9._+-]/-/g' <<< "${LABEL}")"

if [ -n "${OUTPUT_ROOT}" ]; then
    OUTPUT_ROOT="$(realpath -m "${OUTPUT_ROOT}")"
    OUTPUT_DIR="${OUTPUT_ROOT}/${SAFE_LABEL}_${GIT_SHORT}_${GIT_STATE}__${SOURCE_IDENTITY}"
else
    OUTPUT_DIR="$(realpath -m "${OUTPUT_DIR}")"
fi

if [ -e "${OUTPUT_DIR}" ]; then
    echo "ERROR: waveform archive already exists; refusing to overwrite: ${OUTPUT_DIR}" >&2
    exit 1
fi

OUTPUT_PARENT="$(dirname "${OUTPUT_DIR}")"
mkdir -p "${OUTPUT_PARENT}"
TEMP_DIR="$(mktemp -d "${OUTPUT_PARENT}/.$(basename "${OUTPUT_DIR}").tmp.XXXXXX")"
cleanup() {
    rm -rf "${TEMP_DIR}"
}
trap cleanup EXIT

copy_if_present() {
    local source="$1"
    local destination="$2"
    if [ -f "${source}" ]; then
        cp -p --reflink=auto --sparse=always \
            "${source}" "${TEMP_DIR}/${destination}"
    fi
}

copy_if_present "${SOURCE_FSDB}" novas.fsdb
copy_if_present "${SOURCE_DIR}/run.vcs.log" run.vcs.log
copy_if_present "${SOURCE_DIR}/run_case.report" run_case.report
copy_if_present "${SOURCE_DIR}/simv.console.log" simv.console.log
copy_if_present "${SOURCE_DIR}/symbols.args" symbols.args
copy_if_present "${SOURCE_DIR}/${CASE_NAME}.elf" "${CASE_NAME}.elf"
copy_if_present "${SOURCE_DIR}/${CASE_NAME}.asm" "${CASE_NAME}.asm"
copy_if_present "${SOURCE_DIR}/${CASE_NAME}_build.case.log" build.case.log

if [ ! -s "${TEMP_DIR}/novas.fsdb" ]; then
    echo "ERROR: archived FSDB is missing or empty" >&2
    exit 1
fi
if [ -s "${TEMP_DIR}/run_case.report" ] && \
        grep -q 'TEST PASS' "${TEMP_DIR}/run_case.report"; then
    VALIDATION_STATUS=PASS
elif [ -s "${TEMP_DIR}/run_case.report" ] && \
        grep -q 'TEST FAIL' "${TEMP_DIR}/run_case.report"; then
    VALIDATION_STATUS=FAIL
else
    VALIDATION_STATUS=unknown
fi

ARCHIVE_SIZE="$(stat -Lc '%s' "${TEMP_DIR}/novas.fsdb")"
{
    echo "schema=c910-waveform-archive-v1"
    echo "case=${CASE_NAME}"
    echo "label=${LABEL}"
    echo "tag=${TAG}"
    echo "git_commit=${GIT_COMMIT}"
    echo "git_state=${GIT_STATE}"
    echo "validation_status=${VALIDATION_STATUS}"
    echo "source_directory=${SOURCE_DIR}"
    echo "source_fsdb=${SOURCE_FSDB}"
    echo "source_identity=${SOURCE_IDENTITY}"
    echo "fsdb_size_bytes=${ARCHIVE_SIZE}"
    echo "fsdb_file=novas.fsdb"
    echo "run_log_file=run.vcs.log"
    echo "run_report_file=run_case.report"
} > "${TEMP_DIR}/waveform.info"

mv "${TEMP_DIR}" "${OUTPUT_DIR}"
trap - EXIT
echo "Waveform archive -> ${OUTPUT_DIR}"
