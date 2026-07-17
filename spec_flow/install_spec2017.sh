#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/env.sh"

if [[ ! -f "${SPEC_ISO}" ]]; then
  echo "SPEC ISO not found: ${SPEC_ISO}" >&2
  exit 1
fi

mkdir -p "${SPEC_ISO_DIR}" "${SPEC_ROOT}" "${SPEC_RUN_ROOT}/logs"
export TERM="${TERM:-xterm}"

if [[ -x "${SPEC_ROOT}/bin/runcpu" || -x "${SPEC_ROOT}/runcpu" ]]; then
  echo "[install] SPEC already appears installed at ${SPEC_ROOT}"
  exit 0
fi

if [[ ! -f "${SPEC_ISO_DIR}/install.sh" ]]; then
  echo "[install] extracting ISO to ${SPEC_ISO_DIR}"
  7z x -y "${SPEC_ISO}" "-o${SPEC_ISO_DIR}" | tee "${SPEC_RUN_ROOT}/logs/iso_extract.log"
fi

chmod -R a+rwX "${SPEC_ISO_DIR}" "${SPEC_ROOT}" "${SPEC_RUN_ROOT}"
chmod u+x "${SPEC_ISO_DIR}/install.sh" "${SPEC_ISO_DIR}/uninstall.sh" 2>/dev/null || true
find "${SPEC_ISO_DIR}/bin" "${SPEC_ISO_DIR}/tools" -type f -exec chmod u+x {} + 2>/dev/null || true

echo "[install] installing SPEC CPU2017 to ${SPEC_ROOT}"
cd "${SPEC_ISO_DIR}"
./install.sh -f -d "${SPEC_ROOT}" | tee "${SPEC_RUN_ROOT}/logs/spec_install.log"

chmod -R a+rwX "${SPEC_ROOT}" "${SPEC_RUN_ROOT}"

echo "[install] done"
