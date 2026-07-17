#!/usr/bin/env python3
import argparse
import os
import re
import subprocess
from pathlib import Path


FILE_RE = re.compile(r"file=([^ ]+) \[.*generating link map")
MAP_RE = re.compile(r"base: (0x[0-9a-fA-F]+)\s+size: (0x[0-9a-fA-F]+)")
MPROTECT_RE = re.compile(r"mprotect\((0x[0-9a-fA-F]+),[^)]*PROT_READ\)")
INTERP_RE = re.compile(r"Requesting program interpreter: ([^]]+)")


def resolve_library(sysroot, name):
    preferred = [
        sysroot / "lib64" / "lp64d" / name,
        sysroot / "lib64xthead" / "lp64d" / name,
        sysroot / "lib" / name,
    ]
    for path in preferred:
        if path.exists():
            return path.resolve()
    matches = sorted(sysroot.rglob(name))
    return matches[0].resolve() if matches else None


def elf_load_span(path):
    output = subprocess.check_output(["readelf", "-lW", str(path)], text=True)
    end = 0
    relro = None
    for line in output.splitlines():
        parts = line.split()
        if not parts:
            continue
        if parts[0] == "LOAD" and len(parts) >= 6:
            end = max(end, int(parts[2], 16) + int(parts[5], 16))
        elif parts[0] == "GNU_RELRO" and len(parts) >= 3:
            relro = int(parts[2], 16)
    return (end + 0xFFF) & ~0xFFF, None if relro is None else relro & ~0xFFF


def resolve_interpreter(sysroot, elf):
    output = subprocess.check_output(["readelf", "-lW", str(elf)], text=True)
    match = INTERP_RE.search(output)
    if not match:
        return None
    path = sysroot / match.group(1).lstrip("/")
    return path.resolve() if path.exists() else None


def capture(args):
    qemu = str(Path(args.qemu).resolve())
    sysroot_path = Path(args.sysroot).resolve()
    elf = str(Path(args.elf).resolve())
    command = [
        qemu,
        "-R",
        args.reserved_va,
        "-strace",
        "-cpu",
        "c910",
        "-L",
        str(sysroot_path),
        "-E",
        "LD_DEBUG=files",
        elf,
    ]
    try:
        result = subprocess.run(
            command,
            cwd=args.cwd,
            stdin=subprocess.DEVNULL,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.PIPE,
            text=True,
            timeout=args.timeout,
            check=False,
        )
        debug = result.stderr
    except subprocess.TimeoutExpired as exc:
        debug = exc.stderr or ""
        if isinstance(debug, bytes):
            debug = debug.decode(errors="replace")

    modules = []
    pending = None
    sysroot = sysroot_path
    for line in debug.splitlines():
        file_match = FILE_RE.search(line)
        if file_match:
            pending = file_match.group(1)
            continue
        map_match = MAP_RE.search(line)
        if not map_match or pending is None:
            continue
        base = int(map_match.group(1), 16)
        size = int(map_match.group(2), 16)
        path = resolve_library(sysroot, os.path.basename(pending))
        if path is not None:
            modules.append((args.cmd_index, base, base + size, path, pending))
        pending = None
    interpreter = resolve_interpreter(sysroot, Path(elf))
    if interpreter is not None:
        span, relro = elf_load_span(interpreter)
        if relro is not None:
            module_ranges = [(base, end) for _, base, end, _, _ in modules]
            for line in debug.splitlines():
                match = MPROTECT_RE.search(line)
                if not match:
                    continue
                address = int(match.group(1), 16)
                if address < 0x1000000000:
                    continue
                if any(base <= address < end for base, end in module_ranges):
                    continue
                base = address - relro
                modules.append(
                    (args.cmd_index, base, base + span, interpreter, interpreter.name)
                )
                break
    return modules


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--qemu", required=True)
    parser.add_argument("--sysroot", required=True)
    parser.add_argument("--reserved-va", default="0x4000000000")
    parser.add_argument("--elf", required=True)
    parser.add_argument("--cwd", default=".")
    parser.add_argument("--cmd-index", type=int, required=True)
    parser.add_argument("--out", required=True)
    parser.add_argument("--append", action="store_true")
    parser.add_argument("--timeout", type=float, default=2.0)
    args = parser.parse_args()

    modules = capture(args)
    out = Path(args.out)
    mode = "a" if args.append and out.exists() else "w"
    with out.open(mode) as stream:
        if mode == "w":
            stream.write("cmd_index\tbase\tend\telf\tmodule\n")
        for cmd_index, base, end, path, module in modules:
            stream.write(f"{cmd_index}\t0x{base:x}\t0x{end:x}\t{path}\t{module}\n")
    print(f"[modules] cmd={args.cmd_index} captured={len(modules)} out={out}")


if __name__ == "__main__":
    main()
