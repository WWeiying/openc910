#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(realpath "${SCRIPT_DIR}/..")"
ITERATIONS="${COREMARK_ITERATIONS:-1}"
SIGNAL_CONFIG="${SIGNAL_CONFIG:-/home/wangwy/work_dir/fsdb_tools/configs/c910_core_rob.json}"
EXPORT_TOOL="${EXPORT_TOOL:-/home/wangwy/work_dir/fsdb_tools/export_fsdb.py}"
ANALYZER="${ANALYZER:-${SCRIPT_DIR}/analyze_coremark_branch_precision.py}"
PYTHON="${PYTHON:-/home/wangwy/software/anaconda3/envs/pytorch/bin/python}"
REUSE_BUILD=off
BACKGROUND=off

usage() {
  cat <<'EOF'
Usage: run_coremark_branch_precision.sh [--reuse-build] [--background]

Build and run CoreMark with a full FSDB and the detailed branch-analysis signal
schema. The run is staged under smart_run/results and never reuses an existing
result directory.

Environment:
  COREMARK_ITERATIONS   CoreMark iteration count (default: 1)
  SIGNAL_CONFIG         fsdb_tools JSON configuration
  EXPORT_TOOL           fsdb_tools/export_fsdb.py path
  ANALYZER              post-export branch analysis script
  PYTHON                Python interpreter used for FSDB export
EOF
}

while (($#)); do
  case "$1" in
    --reuse-build) REUSE_BUILD=on ;;
    --background)  BACKGROUND=on ;;
    -h|--help) usage; exit 0 ;;
    *) echo "ERROR: unknown option: $1" >&2; usage >&2; exit 2 ;;
  esac
  shift
done

for path in "${SIGNAL_CONFIG}" "${EXPORT_TOOL}" "${ANALYZER}"; do
  [[ -s "${path}" ]] || { echo "ERROR: missing required file: ${path}" >&2; exit 2; }
done
[[ -x "${PYTHON}" ]] || { echo "ERROR: Python is not executable: ${PYTHON}" >&2; exit 2; }

cd "${SCRIPT_DIR}"
if [[ "${REUSE_BUILD}" != on ]]; then
  flock .branch_precision_build.lock \
    make -s buildcase CASE=coremark COREMARK_ITERATIONS="${ITERATIONS}"
  flock .branch_precision_build.lock \
    make -s compile DUMP=on PERF_DETAIL=on
fi

SIMV="${SCRIPT_DIR}/work/simv"
[[ -x "${SIMV}" ]] || { echo "ERROR: simulator is missing: ${SIMV}" >&2; exit 2; }
grep -q '+define+PERF_DETAIL' work/comp.vcs.log || {
  echo "ERROR: simulator was not compiled with PERF_DETAIL=on" >&2
  exit 2
}
if grep -q '+define+NO_DUMP' work/comp.vcs.log; then
  echo "ERROR: simulator was compiled with DUMP=off" >&2
  exit 2
fi

for input in case.pat inst.pat data.pat symbols.args coremark.elf coremark.asm; do
  [[ -s "work/${input}" ]] || { echo "ERROR: missing staged input: work/${input}" >&2; exit 2; }
done

GIT_COMMIT="$(git -C "${REPO_ROOT}" rev-parse HEAD)"
GIT_SHORT="${GIT_COMMIT:0:12}"
if [[ -n "$(git -C "${REPO_ROOT}" status --porcelain --untracked-files=no)" ]]; then
  GIT_STATE=dirty
else
  GIT_STATE=clean
fi
LABEL="coremark_branch_precision_v2_iter${ITERATIONS}_${GIT_SHORT}_${GIT_STATE}"
RESULT_DIR="${SCRIPT_DIR}/results/${LABEL}"
[[ ! -e "${RESULT_DIR}" ]] || {
  echo "ERROR: result directory already exists; refusing to overwrite: ${RESULT_DIR}" >&2
  exit 2
}
mkdir -p "${RESULT_DIR}"

for input in case.pat inst.pat data.pat symbols.args coremark.elf coremark.asm; do
  cp -p --reflink=auto "work/${input}" "${RESULT_DIR}/${input}"
done
[[ ! -s work/coremark_build.case.log ]] || \
  cp -p --reflink=auto work/coremark_build.case.log "${RESULT_DIR}/build.case.log"
cp -p "${SIGNAL_CONFIG}" "${RESULT_DIR}/c910_branch_precision_signals.json"
cp -p "${ANALYZER}" "${RESULT_DIR}/analyze_coremark_branch_precision.py"

{
  echo "schema=c910-coremark-branch-precision-v2"
  echo "case=coremark"
  echo "iterations=${ITERATIONS}"
  echo "git_commit=${GIT_COMMIT}"
  echo "git_state=${GIT_STATE}"
  echo "simulator=${SIMV}"
  echo "signal_config=c910_branch_precision_signals.json"
  echo "expanded_signal_count=$(${PYTHON} -c 'import itertools,json,sys; c=json.load(open(sys.argv[1])); n=1+len(c.get("signals",[])); n+=sum(len(g.get("signals",[]))*__import__("functools").reduce(lambda a,v:a*(len(range(v["start"],v["stop"])) if isinstance(v,dict) else len(v)),g.get("variables",{}).values(),1) for g in c.get("signal_template_groups",[])); print(n)' "${SIGNAL_CONFIG}")"
  echo "sample_period=10ns"
  sha256sum \
    "${RESULT_DIR}/coremark.elf" \
    "${RESULT_DIR}/coremark.asm" \
    "${RESULT_DIR}/c910_branch_precision_signals.json" \
    "${RESULT_DIR}/analyze_coremark_branch_precision.py"
} >"${RESULT_DIR}/run.info"

cat >"${RESULT_DIR}/run_driver.sh" <<EOF
#!/usr/bin/env bash
set -uo pipefail
cd "${RESULT_DIR}"
echo \$\$ > driver.pid
echo RUNNING > run.status
mapfile -t SYMBOL_ARGS < symbols.args
nice -n 10 "${SIMV}" -l run.vcs.log "\${SYMBOL_ARGS[@]}" >simv.console.log 2>&1
sim_status=\$?
printf 'simv_exit=%s\n' "\${sim_status}" >simv.exit
if ((sim_status != 0)); then
  echo SIM_FAILED > run.status
  exit "\${sim_status}"
fi
if ! grep -q 'TEST PASS' run_case.report 2>/dev/null; then
  echo VALIDATION_FAILED > run.status
  exit 3
fi
echo EXPORTING > run.status
"${PYTHON}" "${EXPORT_TOOL}" \
  --fsdb novas.fsdb \
  --config c910_branch_precision_signals.json \
  --output branch_precision_signals.csv \
  --allow-missing-signals >fsdb_export.log 2>&1
export_status=\$?
printf 'export_exit=%s\n' "\${export_status}" >export.exit
if ((export_status != 0)); then
  echo EXPORT_FAILED > run.status
  exit "\${export_status}"
fi
echo ANALYZING > run.status
"${PYTHON}" ./analyze_coremark_branch_precision.py . \
  --signals branch_precision_signals.csv >branch_precision_analysis.log 2>&1
analysis_status=\$?
printf 'analysis_exit=%s\n' "\${analysis_status}" >analysis.exit
if ((analysis_status != 0)); then
  echo ANALYSIS_FAILED > run.status
  exit "\${analysis_status}"
fi
echo COMPLETE > run.status
EOF
chmod +x "${RESULT_DIR}/run_driver.sh"

if [[ "${BACKGROUND}" == on ]]; then
  (
    cd "${RESULT_DIR}"
    setsid -f ./run_driver.sh </dev/null >driver.log 2>&1
  )
  for _ in {1..20}; do
    [[ -s "${RESULT_DIR}/driver.pid" ]] && break
    sleep 0.1
  done
  echo "Background run started"
  echo "Result directory: ${RESULT_DIR}"
  echo "PID: $(cat "${RESULT_DIR}/driver.pid")"
else
  "${RESULT_DIR}/run_driver.sh" |& tee "${RESULT_DIR}/driver.log"
  echo "Result directory: ${RESULT_DIR}"
fi
