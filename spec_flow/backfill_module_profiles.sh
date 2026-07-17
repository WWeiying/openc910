#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/env.sh"
export PYTHONPATH="${REPO_ROOT}${PYTHONPATH:+:${PYTHONPATH}}"

process_one() {
  local suite="$1"
  local size="$2"
  local bench="$3"
  local out_dir stem cmdmap modules modules_tmp profile profile_tmp manifest manifest_tmp
  local elf optimize first cmd_index start_id end_id command module_method recovery_log

  out_dir="${SPEC_RUN_ROOT}/${bench}_${size}_c910"
  stem="${bench}_${size}"
  cmdmap="${out_dir}/${stem}.bb.cmdmap"
  modules="${out_dir}/${stem}.bb.modules"
  profile="${out_dir}/${stem}.function_profile.csv"
  manifest="${out_dir}/manifest.json"
  modules_tmp="${modules}.tmp.$$"
  profile_tmp="${profile}.tmp.$$"
  manifest_tmp="${manifest}.tmp.$$"
  recovery_log="${out_dir}/module_recovery.log"
  trap 'rm -f "${modules_tmp}" "${profile_tmp}" "${manifest_tmp}"' RETURN

  for path in \
    "${out_dir}/${stem}.bb" "${out_dir}/${stem}.bb.map" "${cmdmap}" \
    "${out_dir}/${stem}.simpoints" "${out_dir}/${stem}.weights" \
    "${out_dir}/compare.log" "${out_dir}/simpoint.log"; do
    if [[ ! -s "${path}" ]]; then
      echo "[backfill] skip ${suite}/${size}/${bench}: missing ${path}" >&2
      return 1
    fi
  done

  first=1
  elf=""
  module_method="$(python3 - "${out_dir}/${stem}.bb.map" <<'PY'
import sys
legacy = False
with open(sys.argv[1]) as stream:
    for line in stream:
        fields = line.split()
        if len(fields) >= 2 and int(fields[1], 16) >= 0x700000000000:
            legacy = True
            break
print("aslr_slide_recovered" if legacy else "fixed_va")
PY
)"
  : >"${recovery_log}"
  while IFS=$'\t' read -r cmd_index start_id end_id command_elf command; do
    if [[ "${cmd_index}" == "cmd_index" ]]; then
      continue
    fi
    if [[ ! -f "${command_elf}" ]]; then
      echo "[backfill] ${suite}/${size}/${bench}: missing ELF ${command_elf}" >&2
      return 1
    fi
    if [[ "${first}" -eq 1 ]]; then
      elf="${command_elf}"
      first=0
    fi
    if [[ "${module_method}" == "aslr_slide_recovered" ]]; then
      if ! python3 "${SCRIPT_DIR}/recover_legacy_modules.py" \
          --qemu "${QEMU}" --sysroot "${SYSROOT}" \
          --plugin "${BBV_PLUGIN_LOCAL:-${REPO_ROOT}/tools/qemu-plugins/simple_bbv.so}" \
          --elf "${command_elf}" --cwd "$(dirname "${command_elf}")" \
          --command "${command}" \
          --cmd-index "${cmd_index}" \
          --old-map "${out_dir}/${stem}.bb.map" \
          --start-id "${start_id}" --end-id "${end_id}" \
          --out "${modules_tmp}" --append 2>&1 | tee -a "${recovery_log}"; then
        if [[ -s "${modules_tmp}" ]]; then
          echo "[modules-recover] warning: cmd=${cmd_index} could not be aligned; preserving prior recovered ranges" \
            | tee -a "${recovery_log}"
          continue
        fi
        return 1
      fi
    else
      python3 "${SCRIPT_DIR}/capture_guest_modules.py" \
        --qemu "${QEMU}" --sysroot "${SYSROOT}" \
        --reserved-va "${QEMU_RESERVED_VA:-0x4000000000}" \
        --elf "${command_elf}" --cwd "$(dirname "${command_elf}")" \
        --cmd-index "${cmd_index}" --out "${modules_tmp}" --append \
        | tee -a "${recovery_log}"
    fi
  done <"${cmdmap}"
  if [[ -z "${elf}" || ! -s "${modules_tmp}" ]]; then
    echo "[backfill] ${suite}/${size}/${bench}: module capture produced no file" >&2
    return 1
  fi
  mv "${modules_tmp}" "${modules}"

  python3 "${SCRIPT_DIR}/analyze_bbv_functions.py" \
    --bbv "${out_dir}/${stem}.bb" --map "${out_dir}/${stem}.bb.map" \
    --elf "${elf}" --cmdmap "${cmdmap}" --modules "${modules}" \
    --simpoints "${out_dir}/${stem}.simpoints" \
    --weights "${out_dir}/${stem}.weights" \
    --nm "${GCC_GLIBC}/bin/riscv64-unknown-linux-gnu-nm" \
    --top "${PROFILE_TOP:-20}" --out "${profile_tmp}"
  mv "${profile_tmp}" "${profile}"

  optimize="$(python3 - "${manifest}" <<'PY'
import json
import sys
print(json.load(open(sys.argv[1])).get(
    "optimize",
    "-O2 -march=rv64imafdcxtheadc -mabi=lp64d -mtune=c910 -fcommon",
))
PY
)"
  python3 "${SCRIPT_DIR}/make_simpoint_manifest.py" \
    --bench "${bench}" --size "${size}" --out-dir "${out_dir}" \
    --interval 100000000 --max-k 5 \
    --bbv-id-stride "${SPEC_BBV_ID_STRIDE}" \
    --qemu-reserved-va "${QEMU_RESERVED_VA:-0x4000000000}" \
    --module-map-method "${module_method}" \
    --repo-root "${REPO_ROOT}" --qemu-path "${QEMU}" \
    --compiler-path "${GCC_GLIBC}/bin/riscv64-unknown-linux-gnu-gcc" \
    --simpoint-path "${SIMPOINT}" --optimize "${optimize}" \
    --out "${manifest_tmp}"
  mv "${manifest_tmp}" "${manifest}"
  chmod a+rw "${modules}" "${profile}" "${manifest}" 2>/dev/null || true
  echo "[backfill] pass ${suite}/${size}/${bench}"
}

base_artifacts_ready() {
  local bench="$1"
  local size="$2"
  local out_dir="${SPEC_RUN_ROOT}/${bench}_${size}_c910"
  local stem="${bench}_${size}"
  local path

  for path in \
    "${out_dir}/${stem}.bb" "${out_dir}/${stem}.bb.map" \
    "${out_dir}/${stem}.bb.cmdmap" "${out_dir}/${stem}.simpoints" \
    "${out_dir}/${stem}.weights" "${out_dir}/compare.log" \
    "${out_dir}/simpoint.log"; do
    [[ -s "${path}" ]] || return 1
  done
}

if [[ "${1:-}" == "--one" ]]; then
  process_one "${2:?suite required}" "${3:?size required}" "${4:?benchmark required}"
  exit
fi

workers="${BACKFILL_WORKERS:-4}"
if ! [[ "${workers}" =~ ^[1-9][0-9]*$ ]]; then
  echo "ERROR: BACKFILL_WORKERS must be a positive integer" >&2
  exit 2
fi

task_file="$(mktemp)"
trap 'rm -f "${task_file}"' EXIT
for suite in speed rate; do
  for size in test train ref; do
    for bench in $(spec_benchmarks_for_suite "${suite}"); do
      manifest="${SPEC_RUN_ROOT}/${bench}_${size}_c910/manifest.json"
      if [[ ! -s "${manifest}" ]]; then
        continue
      fi
      if ! base_artifacts_ready "${bench}" "${size}"; then
        continue
      fi
      if python3 - "${manifest}" <<'PY'
import json
import os
import sys
from pathlib import Path

from spec_flow.validate_l2plus import validate_manifest

path = Path(sys.argv[1])
data = json.load(path.open())
validation = data.get("validation", {})
eligible = validation.get("compare_pass") and validation.get("simpoint_done")
all_existing = os.environ.get("BACKFILL_ALL_EXISTING", "0") == "1"
strict = False
if not all_existing:
    strict = validate_manifest(
        path, data.get("bench", ""), data.get("size", ""), 0.002
    )["valid"]
raise SystemExit(0 if eligible and (all_existing or not strict) else 1)
PY
      then
        printf '%s\t%s\t%s\n' "${suite}" "${size}" "${bench}" >>"${task_file}"
      fi
    done
  done
done

task_count="$(wc -l <"${task_file}")"
echo "[backfill] tasks=${task_count} workers=${workers}"
if [[ "${task_count}" -eq 0 ]]; then
  exit 0
fi

xargs -r -P "${workers}" -n 3 \
  "${SCRIPT_DIR}/backfill_module_profiles.sh" --one <"${task_file}"
echo "[backfill] complete tasks=${task_count}"
