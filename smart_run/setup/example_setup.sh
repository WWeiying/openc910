#!/bin/bash

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "${SCRIPT_DIR}/../.." && pwd)"

export TOOLCHAIN_ROOT="${TOOLCHAIN_ROOT:-${REPO_ROOT}/toolchains/Xuantie-900-gcc-elf-newlib-x86_64-V3.1.0}"
export LLVM_TOOLCHAIN_ROOT="${LLVM_TOOLCHAIN_ROOT:-${REPO_ROOT}/toolchains/Xuantie-900-llvm-elf-newlib-x86_64-V2.4.0}"
export QEMU_ROOT="${QEMU_ROOT:-${REPO_ROOT}/toolchains/Xuantie-qemu-x86_64-Ubuntu-20.04-V5.2.8-B20250721-0303}"
export TOOL_EXTENSION="${TOOL_EXTENSION:-${TOOLCHAIN_ROOT}/bin/}"
export GCC_PATH="${GCC_PATH:-${TOOL_EXTENSION}}"
export LLVM_PATH="${LLVM_PATH:-${LLVM_TOOLCHAIN_ROOT}/bin}"
export QEMU_PATH="${QEMU_PATH:-${QEMU_ROOT}/bin}"
echo 'Toolchain path($TOOL_EXTENSION):'
echo "    $TOOL_EXTENSION"
echo 'LLVM path($LLVM_PATH):'
echo "    $LLVM_PATH"
echo 'QEMU path($QEMU_PATH):'
echo "    $QEMU_PATH"
