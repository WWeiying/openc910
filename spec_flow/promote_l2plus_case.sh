#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/env.sh"

BENCH="${1:?usage: promote_l2plus_case.sh BENCH SIZE SOURCE_DIR}"
SIZE="${2:?usage: promote_l2plus_case.sh BENCH SIZE SOURCE_DIR}"
SOURCE_DIR="${3:?usage: promote_l2plus_case.sh BENCH SIZE SOURCE_DIR}"
SOURCE_DIR="$(realpath "${SOURCE_DIR}")"
TARGET_DIR="${SPEC_RUN_ROOT}/${BENCH}_${SIZE}_c910"
ARCHIVE_ROOT="${SPEC_RUN_ROOT}/archive"
BACKUP_DIR="${ARCHIVE_ROOT}/${BENCH}_${SIZE}_c910_pre_l2plus_partial"
SOURCE_NAME="$(basename "${SOURCE_DIR}")"
TARGET_NAME="$(basename "${TARGET_DIR}")"

if [[ "${SOURCE_DIR}" == "$(realpath -m "${TARGET_DIR}")" ]]; then
  echo "ERROR: source is already the canonical directory: ${SOURCE_DIR}" >&2
  exit 2
fi
if [[ ! -f "${SOURCE_DIR}/manifest.json" ]]; then
  echo "ERROR: staged manifest not found: ${SOURCE_DIR}/manifest.json" >&2
  exit 1
fi
if [[ -e "${BACKUP_DIR}" ]]; then
  echo "ERROR: fixed backup path already exists: ${BACKUP_DIR}" >&2
  exit 1
fi

"${SCRIPT_DIR}/check_l2plus_case.py" \
  --spec-runs "${SPEC_RUN_ROOT}" \
  --manifest "${SOURCE_DIR}/manifest.json" \
  "${BENCH}" "${SIZE}"

mkdir -p "${ARCHIVE_ROOT}"
moved_old=0
manifest_rebased=0
if [[ -e "${TARGET_DIR}" ]]; then
  mv "${TARGET_DIR}" "${BACKUP_DIR}"
  moved_old=1
fi

rollback() {
  local status=$?

  if [[ -e "${TARGET_DIR}" && ! -e "${SOURCE_DIR}" ]]; then
    mv "${TARGET_DIR}" "${SOURCE_DIR}" || true
  fi
  if [[ "${manifest_rebased}" == 1 && -f "${SOURCE_DIR}/manifest.json" ]]; then
    "${SCRIPT_DIR}/rebase_manifest_files.py" \
      "${SOURCE_DIR}/manifest.json" "${TARGET_NAME}" "${SOURCE_NAME}" || true
  fi
  if [[ "${moved_old}" == 1 && -e "${BACKUP_DIR}" && ! -e "${TARGET_DIR}" ]]; then
    mv "${BACKUP_DIR}" "${TARGET_DIR}" || true
  fi
  exit "${status}"
}
trap rollback ERR

mv "${SOURCE_DIR}" "${TARGET_DIR}"
"${SCRIPT_DIR}/rebase_manifest_files.py" \
  "${TARGET_DIR}/manifest.json" "${SOURCE_NAME}" "${TARGET_NAME}"
manifest_rebased=1
"${SCRIPT_DIR}/check_l2plus_case.py" \
  --spec-runs "${SPEC_RUN_ROOT}" "${BENCH}" "${SIZE}"
trap - ERR

echo "[promote] canonical=${TARGET_DIR}"
if [[ "${moved_old}" == 1 ]]; then
  echo "[promote] previous_partial=${BACKUP_DIR}"
fi
