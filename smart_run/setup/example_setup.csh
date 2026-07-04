#Copyright 2019-2021 T-Head Semiconductor Co., Ltd.
#
#Licensed under the Apache License, Version 2.0 (the "License");
#you may not use this file except in compliance with the License.
#You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
#Unless required by applicable law or agreed to in writing, software
#distributed under the License is distributed on an "AS IS" BASIS,
#WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#See the License for the specific language governing permissions and
#limitations under the License.


#!/bin/csh

setenv TOOLCHAIN_ROOT /home/wangwy/openproject/openc910/toolchains/Xuantie-900-gcc-elf-newlib-x86_64-V3.1.0
setenv LLVM_TOOLCHAIN_ROOT /home/wangwy/openproject/openc910/toolchains/Xuantie-900-llvm-elf-newlib-x86_64-V2.4.0
setenv QEMU_ROOT /home/wangwy/openproject/openc910/toolchains/Xuantie-qemu-x86_64-Ubuntu-20.04-V5.2.8-B20250721-0303
setenv TOOL_EXTENSION ${TOOLCHAIN_ROOT}/bin/
setenv GCC_PATH ${TOOL_EXTENSION}
setenv LLVM_PATH ${LLVM_TOOLCHAIN_ROOT}/bin
setenv QEMU_PATH ${QEMU_ROOT}/bin
echo 'Toolchain path($TOOL_EXTENSION):'
echo "    $TOOL_EXTENSION"
echo 'LLVM path($LLVM_PATH):'
echo "    $LLVM_PATH"
echo 'QEMU path($QEMU_PATH):'
echo "    $QEMU_PATH"
