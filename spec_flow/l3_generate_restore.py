#!/usr/bin/env python3
"""Generate and build a machine-mode Sv39 restore image from an L3 package."""

import argparse
import hashlib
import json
import shlex
import subprocess
from pathlib import Path


def sha256(path):
    digest = hashlib.sha256()
    with path.open("rb") as stream:
        for chunk in iter(lambda: stream.read(1024 * 1024), b""):
            digest.update(chunk)
    return digest.hexdigest()


def parse_int(value):
    return int(value, 0) if isinstance(value, str) else int(value)


def register_value(registers, name):
    return parse_int(registers[name]["value"])


def pte_flags(permissions):
    flags = 0
    if "r" in permissions:
        flags |= 1 << 1
    if "w" in permissions:
        flags |= 1 << 2
    if "x" in permissions:
        flags |= 1 << 3
    if flags & (1 << 2) and not flags & (1 << 1):
        raise ValueError(f"RISC-V forbids writable non-readable PTE: {permissions}")
    return flags


def restore_permissions(segment):
    if "restore_permissions" in segment:
        return segment["restore_permissions"]
    host = segment.get("host_permissions", segment.get("permissions", "---"))
    if "r" not in host:
        return "---"
    return "rw-" if "w" in host else "r-x"


def verify_artifact(package, item):
    path = package / item["path"]
    if not path.is_file():
        raise ValueError(f"missing checkpoint artifact: {path}")
    if sha256(path) != item["sha256"]:
        raise ValueError(f"checkpoint artifact digest mismatch: {path}")
    return path


def generate_assembly(checkpoint, package, output, allow_syscalls):
    artifacts = checkpoint["artifacts"]
    registers_path = verify_artifact(package, artifacts["registers"])
    memory_map_path = verify_artifact(package, artifacts["memory_map"])
    memory_image = verify_artifact(package, artifacts["memory_image"])
    syscall_path = verify_artifact(package, artifacts["syscall_trace"])
    registers = json.loads(registers_path.read_text())["registers"]
    memory_map = json.loads(memory_map_path.read_text())
    syscall_trace = json.loads(syscall_path.read_text())
    syscalls = int(syscall_trace.get("restore_syscalls", -1))
    if syscalls and not allow_syscalls:
        raise ValueError(
            f"checkpoint-to-ROI-end window contains {syscalls} "
            "unsupported syscalls"
        )

    required = {"pc", "fcsr"} | {f"x{i}" for i in range(32)} | {
        f"f{i}" for i in range(32)
    }
    missing = sorted(required - set(registers))
    if missing:
        raise ValueError("missing restore registers: " + ",".join(missing))

    captured = [
        item for item in memory_map["segments"] if item.get("captured", True)
    ]
    lines = [
        '    .section .checkpoint_meta,"a",@progbits',
        "    .balign 8",
        "    .globl checkpoint_segment_count",
        "checkpoint_segment_count:",
        f"    .quad {len(captured)}",
        "    .globl checkpoint_segments",
        "checkpoint_segments:",
    ]
    for index, segment in enumerate(captured):
        virtual_address = parse_int(segment["guest_start"])
        length = parse_int(segment["length"])
        image_offset = parse_int(segment["image_offset"])
        if (virtual_address | length | image_offset) & 0xFFF:
            raise ValueError(f"checkpoint segment {index} is not page aligned")
        lines.extend(
            [
                f"    .quad 0x{virtual_address:x}",
                f"    .quad checkpoint_segment_{index}",
                f"    .quad 0x{length:x}",
                f"    .quad 0x{pte_flags(restore_permissions(segment)):x}",
            ]
        )
    lines.extend(
        [
            "    .globl checkpoint_pc",
            "checkpoint_pc:",
            f"    .quad 0x{register_value(registers, 'pc'):016x}",
            "    .globl checkpoint_fcsr",
            "checkpoint_fcsr:",
            f"    .quad 0x{register_value(registers, 'fcsr'):016x}",
            "    .globl checkpoint_gprs",
            "checkpoint_gprs:",
        ]
    )
    lines.extend(
        f"    .quad 0x{register_value(registers, f'x{index}'):016x}"
        for index in range(32)
    )
    lines.extend(["    .globl checkpoint_fprs", "checkpoint_fprs:"])
    lines.extend(
        f"    .quad 0x{register_value(registers, f'f{index}'):016x}"
        for index in range(32)
    )
    lines.extend(['    .section .checkpoint_pages,"aw",@progbits'])
    quoted_image = str(memory_image.resolve()).replace("\\", "\\\\").replace(
        '"', '\\"'
    )
    for index, segment in enumerate(captured):
        length = parse_int(segment["length"])
        image_offset = parse_int(segment["image_offset"])
        lines.extend(
            [
                "    .balign 4096",
                f"    .globl checkpoint_segment_{index}",
                f"checkpoint_segment_{index}:",
                f'    .incbin "{quoted_image}", {image_offset}, {length}',
            ]
        )
    generated = output / "checkpoint_data.S"
    generated.write_text("\n".join(lines) + "\n")
    return generated, syscalls, captured


def build_image(
    repo_root, generated, output, physical_base, toolchain, rtl=False,
    c910_init=True
):
    source = repo_root / "spec_flow/l3_restore"
    gcc = toolchain / "bin/riscv64-unknown-elf-gcc"
    objcopy = toolchain / "bin/riscv64-unknown-elf-objcopy"
    objdump = toolchain / "bin/riscv64-unknown-elf-objdump"
    common = [
        "-march=rv64gc",
        "-mabi=lp64d",
        "-mcmodel=medany",
        "-ffreestanding",
        "-fno-pic",
        "-fno-stack-protector",
    ]
    if rtl:
        common.extend(
            ("-DL3_RTL", "-DL3_PREBUILT_PAGE_TABLES", "-DL3_C910_MAEE")
        )
        if c910_init:
            common.append("-DL3_C910_INIT")
    objects = []
    for input_path in (source / "start.S", source / "restore.c", generated):
        object_path = output / (input_path.stem + ".o")
        command = [str(gcc), *common, "-O2", "-c", str(input_path), "-o", str(object_path)]
        subprocess.run(command, check=True)
        objects.append(object_path)
    elf = output / "restore.elf"
    link = [
        str(gcc),
        *common,
        "-nostdlib",
        "-nostartfiles",
        f"-Wl,--defsym=PHYS_BASE={physical_base}",
        f"-Wl,--defsym=IMAGE_LIMIT={32 << 20 if rtl else 128 << 20}",
        f"-Wl,-T,{source / 'linker.ld'}",
        "-Wl,--build-id=none",
        *map(str, objects),
        "-o",
        str(elf),
    ]
    subprocess.run(link, check=True)
    subprocess.run([str(objcopy), "-O", "binary", str(elf), str(output / "restore.bin")], check=True)
    with (output / "restore.asm").open("w") as stream:
        subprocess.run([str(objdump), "-d", "-S", str(elf)], check=True, stdout=stream)
    (output / "build_command.txt").write_text(
        " ".join(shlex.quote(item) for item in link) + "\n"
    )
    return elf


def elf_symbols(nm, elf):
    listing = subprocess.check_output([str(nm), "-n", str(elf)], text=True)
    result = {}
    for line in listing.splitlines():
        fields = line.split()
        if len(fields) >= 3:
            result[fields[2]] = int(fields[0], 16)
    return result


def patch_rtl_page_tables(binary_path, elf, physical_base, captured, nm):
    """Build Sv39 tables offline so RTL does not spend cycles mapping every page."""
    symbols = elf_symbols(nm, elf)
    page_table_base = symbols["page_tables"]
    tables = [[0] * 512]

    def allocate_table():
        if len(tables) >= 128:
            raise ValueError("checkpoint exhausts the 128-page Sv39 table pool")
        tables.append([0] * 512)
        return len(tables) - 1

    def table_pte(index):
        return ((page_table_base + index * 4096) >> 2) | 1

    for segment_index, segment in enumerate(captured):
        virtual = parse_int(segment["guest_start"])
        length = parse_int(segment["length"])
        physical = symbols[f"checkpoint_segment_{segment_index}"]
        # C910 MXSTATUS.MAEE uses PTE[63:59] as SO/C/B/SH/SEC. 0xf is the
        # normal cacheable-memory setting used by smart_run's MMU tests.
        flags = pte_flags(restore_permissions(segment)) | 0xD1 | (0xF << 59)
        for offset in range(0, length, 4096):
            address = virtual + offset
            vpn2 = (address >> 30) & 0x1FF
            vpn1 = (address >> 21) & 0x1FF
            vpn0 = (address >> 12) & 0x1FF
            if tables[0][vpn2] == 0:
                child = allocate_table()
                tables[0][vpn2] = table_pte(child)
            else:
                child = ((tables[0][vpn2] >> 10) << 12) - page_table_base
                child //= 4096
            if tables[child][vpn1] == 0:
                leaf = allocate_table()
                tables[child][vpn1] = table_pte(leaf)
            else:
                leaf = ((tables[child][vpn1] >> 10) << 12) - page_table_base
                leaf //= 4096
            pte = ((physical + offset) >> 2) | flags
            if tables[leaf][vpn0] not in (0, pte):
                raise ValueError(f"duplicate virtual page at 0x{address:x}")
            tables[leaf][vpn0] = pte

    data = bytearray(binary_path.read_bytes())
    patch_offset = page_table_base - physical_base
    patch_bytes = len(tables) * 4096
    if len(data) < patch_offset + patch_bytes:
        data.extend(b"\0" * (patch_offset + patch_bytes - len(data)))
    for table_index, table in enumerate(tables):
        cursor = patch_offset + table_index * 4096
        for entry in table:
            data[cursor : cursor + 8] = entry.to_bytes(8, "little")
            cursor += 8
    binary_path.write_bytes(data)
    return len(tables)


def elf_symbol(nm, elf, name):
    listing = subprocess.check_output([str(nm), "-n", str(elf)], text=True)
    for line in listing.splitlines():
        fields = line.split()
        if len(fields) >= 3 and fields[2] == name:
            return int(fields[0], 16)
    raise ValueError(f"ELF symbol is missing: {name}")


def write_rtl_lanes(binary_path, output, image_bytes):
    data = binary_path.read_bytes()
    if len(data) < image_bytes:
        data += b"\0" * (image_bytes - len(data))
    if len(data) > 32 << 20:
        raise ValueError(f"RTL restore binary exceeds 32 MiB: {len(data)}")
    lane_dir = output / "rtl_lanes"
    lane_dir.mkdir(parents=True, exist_ok=True)
    padded = data + b"\0" * ((-len(data)) % 16)
    for lane in range(16):
        values = padded[lane::16]
        (lane_dir / f"checkpoint.ram{lane}.hex").write_text(
            values.hex("\n") + "\n"
        )
    (lane_dir / "inst.pat").write_text("00000000\n")
    (lane_dir / "data.pat").write_text("00000000\n")
    return lane_dir


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--package", required=True)
    parser.add_argument("--output", required=True)
    parser.add_argument("--physical-base")
    parser.add_argument("--toolchain")
    parser.add_argument("--allow-syscalls", action="store_true")
    parser.add_argument("--generate-only", action="store_true")
    parser.add_argument("--rtl", action="store_true")
    parser.add_argument("--no-c910-init", action="store_true")
    args = parser.parse_args()

    repo_root = Path(__file__).resolve().parent.parent
    package = Path(args.package).resolve()
    output = Path(args.output).resolve()
    output.mkdir(parents=True, exist_ok=True)
    checkpoint = json.loads((package / "checkpoint.json").read_text())
    generated, syscalls, captured = generate_assembly(
        checkpoint, package, output, args.allow_syscalls
    )
    print(f"generated={generated} restore_syscalls={syscalls}")
    if not args.generate_only:
        toolchain = Path(args.toolchain) if args.toolchain else (
            repo_root / "toolchains/Xuantie-900-gcc-elf-newlib-x86_64-V3.1.0"
        )
        physical_base = parse_int(
            args.physical_base if args.physical_base is not None
            else ("0x0" if args.rtl else "0x80000000")
        )
        elf = build_image(
            repo_root,
            generated,
            output,
            physical_base,
            toolchain,
            rtl=args.rtl,
            c910_init=not args.no_c910_init,
        )
        print(f"elf={elf} bytes={elf.stat().st_size}")
        if args.rtl:
            nm = toolchain / "bin/riscv64-unknown-elf-nm"
            table_count = patch_rtl_page_tables(
                output / "restore.bin", elf, physical_base, captured, nm
            )
            image_bytes = elf_symbol(nm, elf, "_image_end") - physical_base
            lane_dir = write_rtl_lanes(
                output / "restore.bin", output, image_bytes
            )
            print(f"rtl_lanes={lane_dir} prebuilt_page_tables={table_count}")


if __name__ == "__main__":
    main()
