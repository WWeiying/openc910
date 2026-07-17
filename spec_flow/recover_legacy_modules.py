#!/usr/bin/env python3
import argparse
import collections
import os
import shlex
import subprocess
import tempfile
from pathlib import Path

try:
    from spec_flow.capture_guest_modules import (
        FILE_RE,
        MAP_RE,
        MPROTECT_RE,
        elf_load_span,
        resolve_interpreter,
        resolve_library,
    )
except ModuleNotFoundError:
    from capture_guest_modules import (
        FILE_RE,
        MAP_RE,
        MPROTECT_RE,
        elf_load_span,
        resolve_interpreter,
        resolve_library,
    )


def load_high_pcs(path, start_id=None, end_id=None):
    pcs = []
    with Path(path).open() as stream:
        for line in stream:
            fields = line.split()
            if len(fields) < 2:
                continue
            block_id = int(fields[0])
            if start_id is not None and block_id < start_id:
                continue
            if end_id is not None and block_id > end_id:
                continue
            pc = int(fields[1], 16)
            if pc >= 0x1000000000:
                pcs.append(pc)
    return pcs


def parse_modules(debug, sysroot, elf, cmd_index):
    modules = []
    pending = None
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
            modules.append((cmd_index, base, base + size, path, pending))
        pending = None

    interpreter = resolve_interpreter(sysroot, elf)
    if interpreter is not None:
        span, relro = elf_load_span(interpreter)
        if relro is not None:
            ranges = [(base, end) for _, base, end, _, _ in modules]
            for line in debug.splitlines():
                match = MPROTECT_RE.search(line)
                if not match:
                    continue
                address = int(match.group(1), 16)
                if address < 0x1000000000:
                    continue
                if any(base <= address < end for base, end in ranges):
                    continue
                base = address - relro
                modules.append(
                    (cmd_index, base, base + span, interpreter, interpreter.name)
                )
                break
    return modules


def guest_arguments(command):
    if not command:
        return []
    out = []
    for token in shlex.split(command)[1:]:
        if token in {">", ">>", "<", "<<", "2>", "2>>", "1>", "1>>"}:
            break
        if token.startswith((">", "<", "1>", "2>")):
            break
        out.append(token)
    return out


def run_probe(args):
    with tempfile.TemporaryDirectory(prefix="openc910-module-probe-") as tmp:
        bbv = Path(tmp) / "probe.bb"
        bbv_map = Path(tmp) / "probe.bb.map"
        command = [
            str(Path(args.qemu).resolve()),
            "-strace",
            "-cpu",
            "c910",
            "-L",
            str(Path(args.sysroot).resolve()),
            "-E",
            "LD_DEBUG=files",
            "-plugin",
            (
                f"{Path(args.plugin).resolve()},interval=100000000,"
                f"outfile={bbv},mapfile={bbv_map}"
            ),
            str(Path(args.elf).resolve()),
        ]
        elf_name = Path(args.elf).name
        timeout = args.timeout
        probe_cwd = tmp
        if "deepsjeng" in elf_name:
            probe_input = Path(tmp) / "probe.txt"
            probe_input.write_text(
                "r2qk2r/ppp1b1pp/2n1p3/3pP1n1/3P2b1/2PB1NN1/PP4PP/R1BQK2R w KQkq - 0 1\n1\n"
            )
            command.append(str(probe_input))
            timeout = max(timeout, 30.0)
        elif "perlbench" in elf_name:
            perl_args = guest_arguments(args.command)
            if perl_args:
                command.extend("1" if token.isdigit() else token for token in perl_args)
                probe_cwd = args.cwd
                timeout = max(timeout, 30.0)
            else:
                command.extend(["-e", "exit"])
        elif args.command:
            command.extend(guest_arguments(args.command))
        process = subprocess.Popen(
            command,
            cwd=probe_cwd,
            stdin=subprocess.DEVNULL,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.PIPE,
            text=True,
        )
        try:
            _, debug = process.communicate(timeout=timeout)
        except subprocess.TimeoutExpired:
            process.terminate()
            try:
                _, debug = process.communicate(timeout=2.0)
            except subprocess.TimeoutExpired:
                process.kill()
                _, debug = process.communicate()
        if not bbv_map.is_file() or bbv_map.stat().st_size == 0:
            raise RuntimeError("probe produced no BBV map")
        probe_pcs = load_high_pcs(bbv_map)
        modules = parse_modules(
            debug, Path(args.sysroot).resolve(), Path(args.elf).resolve(), args.cmd_index
        )
        return probe_pcs, modules


def find_slide(old_pcs, probe_pcs):
    old_unique = list(dict.fromkeys(old_pcs))
    probe_unique = list(dict.fromkeys(probe_pcs))
    if not old_unique or not probe_unique:
        raise ValueError("old or probe map has no high guest PCs")

    sample_old = old_unique[:256]
    sample_probe = probe_unique[:256]
    candidates = collections.Counter(
        old_pc - probe_pc for old_pc in sample_old for probe_pc in sample_probe
    )
    old_set = set(old_unique)
    best_slide = None
    best_score = -1
    for slide, _ in candidates.most_common(256):
        score = sum(probe_pc + slide in old_set for probe_pc in probe_unique)
        if score > best_score:
            best_slide = slide
            best_score = score

    minimum = min(
        len(probe_unique), max(20, (len(probe_unique) + 9) // 10)
    )
    if best_slide is None or best_score < minimum:
        raise ValueError(
            f"unable to establish ASLR slide: best_score={best_score}, required={minimum}"
        )
    return best_slide, best_score, len(probe_unique), len(old_unique)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--qemu", required=True)
    parser.add_argument("--sysroot", required=True)
    parser.add_argument("--plugin", required=True)
    parser.add_argument("--elf", required=True)
    parser.add_argument("--cwd", default=".")
    parser.add_argument("--command", default="")
    parser.add_argument("--cmd-index", type=int, required=True)
    parser.add_argument("--old-map", required=True)
    parser.add_argument("--start-id", type=int, required=True)
    parser.add_argument("--end-id", type=int, required=True)
    parser.add_argument("--out", required=True)
    parser.add_argument("--append", action="store_true")
    parser.add_argument("--timeout", type=float, default=5.0)
    args = parser.parse_args()

    if args.end_id < args.start_id:
        print(
            f"[modules-recover] cmd={args.cmd_index} has no mapped block IDs; skipped"
        )
        return

    old_pcs = load_high_pcs(args.old_map, args.start_id, args.end_id)
    last_error = None
    for _ in range(3):
        try:
            probe_pcs, modules = run_probe(args)
            break
        except RuntimeError as exc:
            last_error = exc
    else:
        raise RuntimeError(f"module probe failed after 3 attempts: {last_error}")
    slide, score, probe_count, old_count = find_slide(old_pcs, probe_pcs)
    shifted = [
        (cmd, base + slide, end + slide, path, module)
        for cmd, base, end, path, module in modules
    ]
    hits = sum(
        any(base <= pc < end for _, base, end, _, _ in shifted) for pc in old_pcs
    )
    if not shifted or hits == 0:
        raise RuntimeError("recovered module ranges do not overlap the old BBV map")

    out = Path(args.out)
    mode = "a" if args.append and out.exists() else "w"
    with out.open(mode) as stream:
        if mode == "w":
            stream.write(
                "cmd_index\tbase\tend\telf\tmodule\tmethod\tslide\tprobe_matches\n"
            )
        for cmd, base, end, path, module in shifted:
            stream.write(
                f"{cmd}\t0x{base:x}\t0x{end:x}\t{path}\t{module}\t"
                f"aslr_slide_recovered\t{slide:+#x}\t{score}/{probe_count}\n"
            )
    print(
        f"[modules-recover] cmd={args.cmd_index} slide={slide:+#x} "
        f"probe_matches={score}/{probe_count} old_pcs={old_count} "
        f"module_hits={hits} modules={len(shifted)} out={out}"
    )


if __name__ == "__main__":
    main()
