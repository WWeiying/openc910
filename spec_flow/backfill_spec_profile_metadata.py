#!/usr/bin/env python3
"""Measure warmup intervals in saved SPEC kernel ELFs and refresh metadata."""

from __future__ import annotations

import argparse
import json
import re
import subprocess
from pathlib import Path


QEMU = (
    "/work/toolchains/Xuantie-qemu-x86_64-Ubuntu-20.04-V5.2.8-"
    "B20250721-0303/bin/qemu-system-riscv64"
)
PLUGIN = "/work/tools/qemu-plugins/kernel_trace.so"
INSTRUCTION_RE = re.compile(r"instructions=([0-9]+)")


def symbol_address(nm: Path, elf: Path, symbol: str) -> str | None:
    output = subprocess.check_output([str(nm), "-n", str(elf)], text=True)
    for line in output.splitlines():
        fields = line.split()
        if len(fields) >= 3 and fields[2] == symbol:
            return fields[0]
    return None


def update_key_value(path: Path, key: str, value: str) -> None:
    lines = path.read_text().splitlines() if path.is_file() else []
    replacement = f"{key}={value}"
    for index, line in enumerate(lines):
        if line.startswith(f"{key}="):
            lines[index] = replacement
            break
    else:
        lines.append(replacement)
    path.write_text("\n".join(lines) + "\n")


def update_readme(path: Path, profile: str, warmup: int) -> None:
    if not path.is_file():
        return
    text = path.read_text()
    text = re.sub(r"\n- Kernel profile：`[^`]*`", "", text)
    text = re.sub(r"\n- warmup 指令数：`[^`]*`", "", text)
    marker = "\n- 校验："
    metadata = (
        f"\n- Kernel profile：`{profile}`"
        f"\n- warmup 指令数：`{warmup}`"
    )
    if marker in text:
        text = text.replace(marker, metadata + marker, 1)
    else:
        text += f"\n\n## Profile 元数据\n{metadata}\n"
    path.write_text(text)


def measure_warmup(
    case_dir: Path,
    repo_root: Path,
    nm: Path,
    container: str,
    max_instructions: int,
) -> int:
    case = case_dir.name
    elf = case_dir / f"{case}.elf"
    if not elf.is_file():
        raise FileNotFoundError(elf)
    start = symbol_address(nm, elf, "perf_warmup_start")
    end = symbol_address(nm, elf, "perf_warmup_end")
    if start is None or end is None:
        raise RuntimeError(f"{case}: warmup markers are missing")
    if start == end:
        return 0
    trace = case_dir / f"{case}.warmup.ktrace"
    container_elf = "/work/" + str(elf.resolve().relative_to(repo_root))
    container_trace = "/work/" + str(trace.resolve().relative_to(repo_root))
    command = [
        "docker", "exec", container, QEMU,
        "-M", "smarth", "-cpu", "c910", "-nographic",
        "-monitor", "none", "-serial", "none", "-bios", "none",
        "-kernel", container_elf,
        "-plugin",
        (f"{PLUGIN},outfile={container_trace},start=0x{start},end=0x{end},"
         f"max_instructions={max_instructions}"),
    ]
    completed = subprocess.run(command, text=True, capture_output=True)
    trace.unlink(missing_ok=True)
    if completed.returncode:
        raise RuntimeError(
            f"{case}: QEMU warmup trace failed: {completed.stderr.strip()}"
        )
    matches = INSTRUCTION_RE.findall(completed.stderr)
    if not matches:
        raise RuntimeError(
            f"{case}: plugin did not report an instruction count: "
            f"{completed.stderr.strip()}"
        )
    return int(matches[-1])


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--features-dir", type=Path, required=True)
    parser.add_argument("--profile", choices=("quick", "full"), required=True)
    parser.add_argument("--container", default="openc910-qemu")
    parser.add_argument("--max-instructions", type=int, default=1_000_000_000)
    args = parser.parse_args()

    repo_root = Path(__file__).resolve().parents[1]
    toolchain = repo_root / (
        "toolchains/Xuantie-900-gcc-elf-newlib-x86_64-V3.1.0/bin/"
        "riscv64-unknown-elf-nm"
    )
    root = args.features_dir.resolve()
    cases = sorted((root / "cases").glob("*/features.json"))
    if not cases:
        raise SystemExit(f"no features.json under {root / 'cases'}")

    failures = []
    for feature_path in cases:
        case_dir = feature_path.parent
        try:
            warmup = measure_warmup(
                case_dir, repo_root, toolchain, args.container,
                args.max_instructions,
            )
            data = json.loads(feature_path.read_text())
            data["profile"] = {
                "kernel_profile": args.profile,
                "warmup_instructions": warmup,
            }
            feature_path.write_text(
                json.dumps(data, indent=2, ensure_ascii=False) + "\n"
            )
            update_key_value(case_dir / "profile.info", "kernel_profile", args.profile)
            update_key_value(case_dir / "profile.info", "warmup_instructions", str(warmup))
            update_readme(case_dir / "README.md", args.profile, warmup)
            print(f"{case_dir.name}: warmup={warmup}")
        except (FileNotFoundError, RuntimeError, subprocess.SubprocessError) as error:
            failures.append(str(error))
            print(f"ERROR: {error}")

    if failures:
        raise SystemExit(f"warmup metadata failures: {len(failures)}")
    print(f"updated {len(cases)} cases in {root}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
