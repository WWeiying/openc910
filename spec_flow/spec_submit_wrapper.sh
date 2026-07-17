#!/usr/bin/env bash
set -euo pipefail

if [[ $# -lt 3 ]]; then
  echo "usage: $0 <qemu> <sysroot> <command> [args...]" >&2
  exit 2
fi

QEMU="$1"
SYSROOT="$2"
shift 2

CMD="$1"

if [[ ! -e "${CMD}" ]]; then
  if command -v "${CMD}" >/dev/null 2>&1; then
    CMD="$(command -v "${CMD}")"
    set -- "${CMD}" "${@:2}"
  else
    exec "$@"
  fi
fi

FILE_INFO="$(file -L "${CMD}" 2>/dev/null || true)"
if [[ "${FILE_INFO}" == *"ELF"* && "${FILE_INFO}" == *"RISC-V"* ]]; then
  exec "${QEMU}" -R "${QEMU_RESERVED_VA:-0x4000000000}" -cpu c910 -L "${SYSROOT}" "$@"
fi

exec "$@"
