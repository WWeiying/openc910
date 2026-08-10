# OpenC910 RISC-V 标准验证环境

本目录给 OpenC910 建立一套与 benchmark 分离的 **RTL/参考模型验证环境**。DUT 侧已经打通标准测试程序编译、ELF 检查、RTL 内存装载、PASS/FAIL 判定、批量回归和结果归档；参考侧接入仓库自带的玄铁定制 QEMU，固定使用 `smarth` machine 和 `c910` CPU 执行同一个裸机 ELF，并将终止架构状态与 RTL 归档比较。

## 1. 当前验证边界

当前开放 RTL 的标准基线按 RTL 实际配置定义为：

| 项目 | 当前配置 |
|---|---|
| 标准 ISA | RV64IMAFDC + Zicsr + Zifencei（通常简称 RV64GC） |
| 特权级 | M / S / U |
| 特权规范 | v1.10 |
| 地址转换 | Sv39，40 位物理地址 |
| PMP | RTL 数据通路中 8 个可用 entry |
| 字节序 | little-endian |
| 当前开放 RTL 的 Vector | `misa.V=0`，不纳入标准基线 |
| XTheadC / XIE / XMAE | 单列厂商扩展验证，不混入 RISC-V 标准通过率 |

机器可读配置见 `config/c910_rv64gc.json`。这份配置描述 **当前仓库 RTL**，不照搬产品论文的 RV64GCV 宣传口径。

## 2. 环境分层

1. **Harness smoke**：确认工具链、链接地址、内存镜像、复位入口、代表性 RV64GC 指令和 PASS/FAIL 握手能够闭环。它不是合规认证。
2. **RISC-V ACT4**：后续生成 self-checking ELF，作为标准体系结构认证层。ACT4 配置必须针对 C910 的特权 v1.10 做兼容性审计，不能直接套用现代 RVA23 配置。
3. **定向与随机验证**：`riscv-tests` 用作快速单元测试来源，`riscv-dv` 用作约束随机程序来源。玄铁 QEMU 已接入终止状态比较；逐提交 PC、指令、写回、CSR 和 store 数据比较仍是下一层工作，不能把终止状态比较说成完整 lockstep。
4. **厂商扩展层**：XThead 指令、扩展 CSR、Cache/TLB 操作独立统计，避免把非标准行为误报成 RISC-V ACT 结果。

`deps.lock.json` 固定社区源码 commit；`.deps/` 和运行输出 `out/` 不提交 Git。

## 3. smart_run 适配原理

现有 testbench 不是通用 `tohost` 平台，存在三项硬约束：

| 约束 | 适配方式 |
|---|---|
| 复位从 `0x0` 取指 | 链接脚本将入口和代码放在 `0x00000` 起 |
| `inst.pat` 装载 `0x00000-0x3ffff`，`data.pat` 初始化 `0x40000-0x7ffff` | `stage` 按 section VMA 自动拆分镜像，并拒绝越界、跨边界或超出初始化窗口的 section；更高 RAM 只用于 BSS/heap/stack 等运行时数据 |
| testbench 监听写回 magic | PASS 写 `0x444333222`，FAIL 写 `0x2382348720`；ACT4 宏已在 `config/act4/` 适配 |

`c910_verify.py` 在运行前还会检查 ELF64、RISC-V、little-endian、入口地址、所有初始化 section 的地址范围。每个 case 使用独立目录，因此不同测试不会覆盖彼此。

## 4. 最小使用流程

先检查环境：

```bash
cd /home/wangwy/openproject/openc910/verification
make doctor
```

若验证专用 `simv` 不存在，单独编译无波形版本。该命令会调用 VCS，是本目录唯一直接启动 EDA 编译的 Make target：

```bash
make rtl-compile
```

编译结果位于 `verification/out/rtl-build/work/simv`。构建过程复制一份独立的 `smart_run/logical` 到忽略目录，不清理、不覆盖 `smart_run/work`，因此不会破坏正在运行的 benchmark 仿真。RTL、testbench、filelist 和构建配置都未变化时会直接复用该 `simv`；任一输入更新后自动重编。

构建、转换并运行 harness smoke：

```bash
make smoke-build
make smoke-stage
make smoke-run
```

只在玄铁 QEMU C910 参考模型上运行同一个 smoke ELF，不启动 EDA：

```bash
make qemu-plugin
make smoke-reference
```

依次运行 RTL、QEMU 并比较架构终态：

```bash
make smoke-diff
```

`smoke-diff` 会先重新编译 `simv`，再启动 RTL 仿真，属于 EDA 命令；`smoke-reference` 只运行 QEMU。QEMU 通过 Docker 中的 Ubuntu 20.04 运行，因为仓库内玄铁 QEMU 的动态库 ABI 与 Rocky Linux 9 宿主环境不兼容。

结果在：

```text
verification/out/cases/rv64gc_harness_smoke/
├── stage.json          # ELF 哈希、Git 号、section 和关键符号
├── result.json         # PASS/FAIL、退出码和墙上时间
├── run_case.report     # testbench 最终判定
├── run.vcs.log
├── simv.console.log
├── inst.pat
├── data.pat
└── case.pat
```

QEMU 与差分结果使用以下机器可读文件：

```text
rtl_arch_state.json        # RTL 在 PASS/FAIL 检测点导出的已提交整数寄存器状态
qemu_arch_state.json       # QEMU 在 PASS/FAIL magic 后、翻译块入口读取的寄存器状态
qemu_result.json           # ELF/QEMU/plugin 哈希、状态、退出码和墙上时间
differential.json          # 同 ELF 证明、比较覆盖、忽略项和逐寄存器 mismatch
```

## 5. QEMU 参考模型与差分比较

玄铁 QEMU 的固定配置为：

```text
qemu-system-riscv64 -M smarth -m 3G -cpu c910 -bios none -kernel <same.elf>
```

`-m 3G` 不是性能配置，而是 bare-metal 测试平台兼容配置。smart_run 的
`sim_end()` 会向 `0xA001FF48` 写结束标记；默认 QEMU RAM 未覆盖该地址时会产生
store access fault。3 GiB guest RAM 覆盖该地址，使 QEMU 能继续从 `main` 返回并
通过 `__exit` 设置 PASS magic，同时保持 QEMU 与 RTL 执行的 ELF 字节完全一致。

`arch_state.so` 插件在每条指令的执行边界读取 `gp/x3`。当它观察到 smart_run 的 PASS magic `0x444333222` 或 FAIL magic `0x2382348720` 时，抓取 QEMU 暴露的全部 GPR、FPR 和 CSR，然后终止 QEMU。逐指令检测是必要的：如果只在翻译块入口检测，QEMU 可能在 PASS 出现后又执行数条退出代码，抓到过晚的寄存器状态。RTL testbench 在对应 magic 的写回已进入 PRF 后，通过 RTU 已提交的逻辑寄存器到物理寄存器映射读取 32 个整数寄存器，生成独立的 `rtl_arch_state.json`。

smart_run 的 `crt0.S` 会在 `__exit` 中主动改写 `a0/ra/sp/gp/tp` 来发布 PASS，随后又直接落入 `__fail` 标签。由于 C910 是乱序核，testbench 在 PASS 写回时抓到的这五个寄存器可能混合 `__exit` 与更年轻的 `__fail` 写入，不能作为程序计算终态。比较器会在 `differential.json` 中把它们明确列为 `ignored_termination_protocol_registers`；其余值完全已知的整数寄存器仍逐一严格比较。该排除只针对测试框架主动破坏的终止协议寄存器，不会把普通 ABI caller-saved 寄存器一并忽略。

比较器不会使用 `reg_trace.log` 的最后一组寄存器。该日志是在退休沿采样的调试轨迹；同周期多条指令退休时，最后一组文本可能早于写回和映射更新，不能代表严格的程序终态。含 `x`/`z` 的 RTL 寄存器会被明确列入 ignored，不会把未知态当成 0。

单独运行参考模型：

```bash
python3 c910_verify.py reference /path/to/test.elf \
  --name test_name --out out/reference --force
```

比较已经存在的 RTL 与 QEMU 归档：

```bash
python3 c910_verify.py compare \
  --rtl-case out/cases/test_name \
  --reference-case out/reference/test_name
```

一条命令完成 RTL、QEMU 和比较：

```bash
python3 c910_verify.py run-diff /path/to/test.elf \
  --name test_name --out out/differential --force
```

对一个目录中的 self-checking ELF 串行执行 RTL/QEMU 差分回归：

```bash
python3 c910_verify.py regress-diff \
  --elf-dir /path/to/self_checking_elfs \
  --pattern '*.elf' \
  --out out/differential-regression \
  --force
```

差分回归固定串行运行，避免无意并发占用 VCS license。根目录生成 `summary.json` 和 `junit.xml`，每个 case 目录另有 `differential_case_result.json`。

比较器首先要求 `stage.json` 与 `qemu_result.json` 的 ELF SHA-256 完全一致；`run-diff` 直接把 RTL case 中已经固化的 ELF 副本交给 QEMU。不同 ELF 即使源码或反汇编看似相同也拒绝比较。之后同时要求 RTL 判定和 RTL 快照均为 PASS、QEMU 判定和 QEMU 快照均为 PASS、至少一个非终止协议 GPR 值完全已知，并检查所有这类已知 GPR 一致。任何不一致都会在 `differential.json` 中给出寄存器名、RTL 值和 QEMU 值。

首次使用终态差分前必须执行一次 `make rtl-compile`，使当前 `tb.v` 的 `rtl_arch_state.json` 导出逻辑进入验证专用 `simv`。如果指定旧 `simv`，比较器会明确拒绝缺少权威 RTL 快照的结果，而不会退回到不可靠的 `reg_trace.log`。

当前版本还没有比较 FPR、CSR、内存签名、store 数据、异常/中断副作用和逐提交事件，也不比较周期或任何微结构状态。因此它已经是可复现的 C910 功能参考后端和 GPR 终态差分层，但还不是逐指令 lockstep 黄金模型。QEMU 是功能参考模型，不复现 C910 的流水线、Cache 时序、分支预测或性能计数。

## 6. 运行任意 self-checking ELF

ELF 必须链接到本环境的内存布局，并自行通过 magic 结束。运行单个 ELF：

```bash
python3 c910_verify.py run /path/to/test.elf \
  --name test_name \
  --timeout 1800 \
  --force
```

只生成 RTL 镜像而不启动 EDA 仿真：

```bash
python3 c910_verify.py stage /path/to/test.elf --name test_name --force
```

批量运行一个目录：

```bash
python3 c910_verify.py regress \
  --elf-dir /path/to/self_checking_elfs \
  --pattern '*.elf' \
  --jobs 1 \
  --timeout 1800 \
  --force
```

回归根目录会生成 `summary.json` 和 CI 可读取的 `junit.xml`。默认 `--jobs 1`，避免无意并发占用多个 VCS license；确认机器和 license 允许后才提高并发数。

## 7. 获取标准社区测试源码

仅获取 ACT4 与 `riscv-tests` 的固定版本；该命令不改动已经独立安装的玄铁 QEMU：

```bash
make deps
```

同时获取 `riscv-dv`：

```bash
make deps-all
```

脚本会验证远端 URL、commit 和工作区洁净度，不会覆盖依赖目录中的本地修改。当前 ACT4 适配目录已经提供 linker 和 PASS/FAIL 宏；`test_config.yaml.in` 的 ACT4 原生参考模型字段仍是占位符。本文接入的是 `c910_verify.py` 的 QEMU 后端，不应据此声称 ACT4 原生参考流程已经完成。

创建互相隔离的 ACT4 与 riscv-dv Python 3.11 环境：

```bash
make python-envs
```

它们分别位于 `.venv-act4/` 和 `.venv-riscv-dv/`，不会修改系统 Python、benchmark 工具链或 Jupyter 环境。ACT4 的 Ruby/UDB 运行依赖以及 ACT4 原生 QEMU adapter 留到认证流程启用时再校准；当前 Python 环境主要用于测试生成和框架准备。

锁定的上游项目分别为 [RISC-V ACT4](https://github.com/riscv/riscv-arch-test)、[riscv-tests](https://github.com/riscv-software-src/riscv-tests) 和 [CHIPS Alliance riscv-dv](https://github.com/chipsalliance/riscv-dv)。标准语义最终以 [RISC-V ISA Manual](https://github.com/riscv/riscv-isa-manual) 为准。

## 8. 结果如何解释

- `rv64gc_harness_smoke=PASS` 只说明 DUT 运行入口和验证基础设施可用，并抽样执行了 I/M/A/F/D/C 与 CSR 指令。
- ACT4 全部通过才是对应配置范围内的体系结构认证证据；ACT4 官方也明确说明 ACT 不是完整处理器验证。
- 只有 QEMU PASS、RTL PASS 和 `differential.json=PASS` 同时成立，才能说明当前终态比较覆盖的已知整数寄存器一致；未被比较的状态仍需要签名或逐提交检查。
- C910 使用特权规范 v1.10，而当前 ACT4/Sail 主要面向更新规范。特权测试必须逐项核对规范版本、WARL/WLRL、PMP、异常优先级和平台中断接口后再启用。
