#!/usr/bin/env bash
set -euo pipefail

ENV_SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export REPO_ROOT="${REPO_ROOT:-$(cd "${ENV_SCRIPT_DIR}/.." && pwd)}"
export SPEC_ISO="${SPEC_ISO:-${REPO_ROOT}/CPU 2017 1.0.5.iso}"
export SPEC_ISO_DIR="${SPEC_ISO_DIR:-${REPO_ROOT}/spec2017_iso}"
export SPEC_ROOT="${SPEC_ROOT:-${REPO_ROOT}/spec2017}"
export SPEC_RUN_ROOT="${SPEC_RUN_ROOT:-${REPO_ROOT}/spec_runs}"

export GCC_GLIBC="${GCC_GLIBC:-${REPO_ROOT}/toolchains/Xuantie-900-gcc-linux-6.6.0-glibc-x86_64-V3.1.0}"
export GCC_ELF="${GCC_ELF:-${REPO_ROOT}/toolchains/Xuantie-900-gcc-elf-newlib-x86_64-V3.1.0}"
export QEMU_ROOT="${QEMU_ROOT:-${REPO_ROOT}/toolchains/Xuantie-qemu-x86_64-Ubuntu-20.04-V5.2.8-B20250721-0303}"

export PATH="${GCC_GLIBC}/bin:${REPO_ROOT}/tools/bin:${PATH}"
export SYSROOT="${SYSROOT:-${GCC_GLIBC}/sysroot}"
export QEMU="${QEMU:-${QEMU_ROOT}/bin/qemu-riscv64}"
export BBV_PLUGIN="${BBV_PLUGIN:-${QEMU_ROOT}/bin/libbbv.so}"
export SIMPOINT="${SIMPOINT:-${REPO_ROOT}/tools/bin/simpoint}"

export C910_MARCH="${C910_MARCH:-rv64imafdcxtheadc}"
export C910_MABI="${C910_MABI:-lp64d}"
export C910_MTUNE="${C910_MTUNE:-c910}"
export C910_OPT="${C910_OPT:--O2}"
export BBV_INTERVAL="${BBV_INTERVAL:-100000000}"
export SPEC_LABEL="${SPEC_LABEL:-c910_gcc_xthead}"
# Perlbench QEMU processes, including fork children, use host PID namespaces.
# The low 32 bits remain available for each process's translated-block IDs.
export SPEC_BBV_ID_STRIDE="${SPEC_BBV_ID_STRIDE:-4294967296}"

export SPEC_INTRATE_BRINGUP="${SPEC_INTRATE_BRINGUP:-500.perlbench_r 502.gcc_r 505.mcf_r 520.omnetpp_r 523.xalancbmk_r 525.x264_r 531.deepsjeng_r 541.leela_r 548.exchange2_r 557.xz_r}"
export SPEC_FPRATE_BRINGUP="${SPEC_FPRATE_BRINGUP:-503.bwaves_r 507.cactuBSSN_r 508.namd_r 510.parest_r 511.povray_r 519.lbm_r 521.wrf_r 526.blender_r 527.cam4_r 538.imagick_r 544.nab_r 549.fotonik3d_r 554.roms_r}"
export SPEC_RATE_BRINGUP="${SPEC_RATE_BRINGUP:-${SPEC_INTRATE_BRINGUP} ${SPEC_FPRATE_BRINGUP}}"
export SPEC_INTSPEED_BRINGUP="${SPEC_INTSPEED_BRINGUP:-600.perlbench_s 602.gcc_s 605.mcf_s 620.omnetpp_s 623.xalancbmk_s 625.x264_s 631.deepsjeng_s 641.leela_s 648.exchange2_s 657.xz_s}"
export SPEC_FPSPEED_BRINGUP="${SPEC_FPSPEED_BRINGUP:-603.bwaves_s 607.cactuBSSN_s 619.lbm_s 621.wrf_s 627.cam4_s 628.pop2_s 638.imagick_s 644.nab_s 649.fotonik3d_s 654.roms_s}"
export SPEC_SPEED_BRINGUP="${SPEC_SPEED_BRINGUP:-${SPEC_INTSPEED_BRINGUP} ${SPEC_FPSPEED_BRINGUP}}"
export SPEC_ALL_BRINGUP="${SPEC_ALL_BRINGUP:-${SPEC_RATE_BRINGUP} ${SPEC_SPEED_BRINGUP}}"
export SPEC_BENCH_SUITE="${SPEC_BENCH_SUITE:-rate}"

spec_benchmarks_for_suite() {
  case "${1:-rate}" in
    rate)
      printf '%s\n' "${SPEC_RATE_BRINGUP}"
      ;;
    speed)
      printf '%s\n' "${SPEC_SPEED_BRINGUP}"
      ;;
    all)
      printf '%s\n' "${SPEC_ALL_BRINGUP}"
      ;;
    intrate)
      printf '%s\n' "${SPEC_INTRATE_BRINGUP}"
      ;;
    fprate)
      printf '%s\n' "${SPEC_FPRATE_BRINGUP}"
      ;;
    intspeed)
      printf '%s\n' "${SPEC_INTSPEED_BRINGUP}"
      ;;
    fpspeed)
      printf '%s\n' "${SPEC_FPSPEED_BRINGUP}"
      ;;
    *)
      echo "Unknown SPEC_BENCH_SUITE '${1}'. Expected rate, speed, all, intrate, fprate, intspeed, or fpspeed." >&2
      return 1
      ;;
  esac
}

spec_run_size_tag() {
  local size="${1:?missing SPEC size}"
  local suite="${2:-}"
  local bench="${3:-}"

  if [[ "${size}" != "ref" ]]; then
    printf '%s\n' "${size}"
    return 0
  fi

  # SPEC names ref run directories by workload mode, not by the CLI size.
  case "${bench}" in
    *_s) printf '%s\n' "refspeed"; return 0 ;;
    *_r) printf '%s\n' "refrate"; return 0 ;;
  esac

  case "${suite}" in
    speed|intspeed|fpspeed) printf '%s\n' "refspeed" ;;
    rate|intrate|fprate) printf '%s\n' "refrate" ;;
    *)
      echo "Cannot resolve SPEC ref run-directory tag for suite='${suite}' bench='${bench}'" >&2
      return 1
      ;;
  esac
}

spec_find_run_dir() {
  local bench="${1:?missing SPEC benchmark}"
  local size="${2:?missing SPEC size}"
  local suite="${3:-}"
  local size_tag

  size_tag="$(spec_run_size_tag "${size}" "${suite}" "${bench}")"
  find "${SPEC_ROOT}/benchspec/CPU/${bench}/run" \
    -maxdepth 1 \
    -type d \
    -name "run_base_${size_tag}_${SPEC_LABEL}.*" \
    -printf '%T@ %p\n' 2>/dev/null | sort -n | tail -1 | cut -d' ' -f2-
}

mkdir -p "${SPEC_RUN_ROOT}"
