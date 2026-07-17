#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/env.sh"

SUITE="${SPEC_BENCH_SUITE:-rate}"

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --suite)
      SUITE="$2"
      shift 2
      ;;
    --suite=*)
      SUITE="${1#--suite=}"
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      break
      ;;
  esac
done

SIZES="${1:-train ref}"
MAX_K="${2:-5}"
INTERVAL="${3:-${BBV_INTERVAL}}"
if [[ "$#" -gt 0 ]]; then shift; fi
if [[ "$#" -gt 0 ]]; then shift; fi
if [[ "$#" -gt 0 ]]; then shift; fi

while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --suite)
      SUITE="$2"
      shift 2
      ;;
    --suite=*)
      SUITE="${1#--suite=}"
      shift
      ;;
    --)
      shift
      break
      ;;
    *)
      break
      ;;
  esac
done

if [[ "$#" -eq 0 ]]; then
  set -- $(spec_benchmarks_for_suite "${SUITE}")
fi

echo "[sizes] sizes=${SIZES}"
echo "[sizes] suite=${SUITE}"
echo "[sizes] maxK=${MAX_K}"
echo "[sizes] interval=${INTERVAL}"
echo "[sizes] benchmarks=$*"

for size in ${SIZES}; do
  echo "[sizes] begin size=${size}"
  "${SCRIPT_DIR}/run_representative_batch.sh" "${size}" "${MAX_K}" "${INTERVAL}" --suite "${SUITE}" "$@"
  echo "[sizes] done size=${size}"
done
