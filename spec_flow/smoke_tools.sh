#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/env.sh"

echo "[smoke] repo: ${REPO_ROOT}"
echo "[smoke] gcc:"
riscv64-unknown-linux-gnu-gcc --version | head -1
echo "[smoke] g++:"
riscv64-unknown-linux-gnu-g++ --version | head -1
echo "[smoke] gfortran:"
riscv64-unknown-linux-gnu-gfortran --version | head -1
echo "[smoke] qemu:"
"${QEMU}" --version | head -1
echo "[smoke] qemu cpu c910:"
"${QEMU}" -cpu help | grep -E '(^| )c910' | head -10 || true
echo "[smoke] simpoint:"
"${SIMPOINT}" \
  -maxK 2 \
  -loadFVFile "${REPO_ROOT}/tools/SimPoint.3.2/input/sample.bb" \
  -saveSimpoints /tmp/openc910-smoke.simpoints \
  -saveSimpointWeights /tmp/openc910-smoke.weights >/tmp/openc910-smoke.simpoint.log
cat /tmp/openc910-smoke.simpoints
cat /tmp/openc910-smoke.weights
echo "[smoke] ok"
