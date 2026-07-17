#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/env.sh"

MODE="${L2PLUS_STATUS_MODE:-strict}"
STATUS_JOBS="${L2PLUS_STATUS_JOBS:-8}"
if [[ "${MODE}" != "strict" && "${MODE}" != "basic" ]]; then
  echo "ERROR: L2PLUS_STATUS_MODE must be strict or basic" >&2
  exit 2
fi
if ! [[ "${STATUS_JOBS}" =~ ^[1-9][0-9]*$ ]] || [[ "${STATUS_JOBS}" -gt 32 ]]; then
  echo "ERROR: L2PLUS_STATUS_JOBS must be an integer from 1 to 32" >&2
  exit 2
fi

total_ok=0
total_expected=0

echo "| suite | input | ok | total | completion | raw status |"
echo "|---|---|---:|---:|---:|---|"
for suite in speed rate; do
  if [[ "${suite}" == "speed" ]]; then
    expected=20
  else
    expected=23
  fi
  for size in test train ref; do
    if [[ "${MODE}" == "basic" ]]; then
      summary="$("${SCRIPT_DIR}/check_simpoint_status.py" \
        --suite "${suite}" --size "${size}" | tail -n 1)"
      ok="$(sed -n 's/.*\bok=\([0-9][0-9]*\).*/\1/p' <<<"${summary}")"
      ok="${ok:-0}"
    else
      results="$(
        spec_benchmarks_for_suite "${suite}" | tr ' ' '\n' | \
          xargs -r -P "${STATUS_JOBS}" -n 1 bash -c '
            checker="$1"
            run_root="$2"
            size="$3"
            bench="$4"
            if "$checker" --spec-runs "$run_root" "$bench" "$size" >/dev/null 2>&1; then
              printf "ok\n"
            elif [[ -s "$run_root/${bench}_${size}_c910/manifest.json" ]]; then
              printf "invalid\n"
            else
              printf "missing\n"
            fi
          ' _ "${SCRIPT_DIR}/check_l2plus_case.py" "${SPEC_RUN_ROOT}" "${size}"
      )"
      ok="$(grep -c '^ok$' <<<"${results}" || true)"
      invalid="$(grep -c '^invalid$' <<<"${results}" || true)"
      missing="$(grep -c '^missing$' <<<"${results}" || true)"
      summary="strict: ok=${ok}, invalid=${invalid}, missing=${missing}"
    fi
    percent="$(awk -v ok="${ok}" -v total="${expected}" \
      'BEGIN {printf "%.1f%%", 100.0 * ok / total}')"
    printf '| `%s` | `%s` | %d | %d | %s | `%s` |\n' \
      "${suite}" "${size}" "${ok}" "${expected}" "${percent}" "${summary}"
    total_ok=$((total_ok + ok))
    total_expected=$((total_expected + expected))
  done
done

overall="$(awk -v ok="${total_ok}" -v total="${total_expected}" \
  'BEGIN {printf "%.1f%%", 100.0 * ok / total}')"
echo
echo "L2+ SimPoint ${MODE} 总进度：${total_ok}/${total_expected}（${overall}）。"
