#!/usr/bin/env python3
import argparse
import csv
from dataclasses import dataclass
from pathlib import Path
from typing import Iterable


@dataclass(frozen=True)
class LogicalSram:
    logical_name: str
    logical_depth: int
    logical_width: int
    logical_instances: int
    compiler: str
    macro_depth: int
    macro_width: int
    mux: int
    slices: int
    note: str

    @property
    def physical(self) -> "PhysicalSram":
        return PhysicalSram(self.compiler, self.macro_depth, self.macro_width, self.mux)


@dataclass(frozen=True, order=True)
class PhysicalSram:
    compiler: str
    depth: int
    width: int
    mux: int

    @property
    def compiler_config(self) -> str:
        return f"{self.depth}x{self.width}m{self.mux}s"

    @property
    def macro_name(self) -> str:
        if self.compiler == "PUHD":
            return f"ts1n28hpcpuhdsvtb{self.depth}x{self.width}m{self.mux}swbso_170a"
        if self.compiler == "PD127":
            return f"ts1n28hpcpsvtb{self.depth}x{self.width}m{self.mux}swbaso_180a"
        raise ValueError(f"unknown compiler {self.compiler}")

    def base_dir(self, args: argparse.Namespace) -> Path:
        if self.compiler == "PUHD":
            return Path(args.puhd_dir)
        if self.compiler == "PD127":
            return Path(args.pd127_dir)
        raise ValueError(f"unknown compiler {self.compiler}")

    def db_path(self, args: argparse.Namespace) -> Path:
        macro = self.macro_name
        return self.base_dir(args) / macro / "DB" / f"{macro}_{args.corner}.db"

    def verilog_path(self, args: argparse.Namespace) -> Path:
        macro = self.macro_name
        return self.base_dir(args) / macro / "VERILOG" / f"{macro}_{args.corner}.v"

    def nldm_dir(self, args: argparse.Namespace) -> Path:
        return self.base_dir(args) / self.macro_name / "NLDM"

    def db_dir(self, args: argparse.Namespace) -> Path:
        return self.base_dir(args) / self.macro_name / "DB"


def parse_config(path: Path) -> list[LogicalSram]:
    rows: list[LogicalSram] = []
    with path.open(newline="") as fh:
        filtered = (line for line in fh if line.strip() and not line.lstrip().startswith("#"))
        for raw in csv.DictReader(filtered, delimiter="\t"):
            rows.append(
                LogicalSram(
                    logical_name=raw["logical_name"],
                    logical_depth=int(raw["logical_depth"]),
                    logical_width=int(raw["logical_width"]),
                    logical_instances=int(raw["logical_instances"]),
                    compiler=raw["compiler"].upper(),
                    macro_depth=int(raw["macro_depth"]),
                    macro_width=int(raw["macro_width"]),
                    mux=int(raw["mux"]),
                    slices=int(raw["slices"]),
                    note=raw.get("note", ""),
                )
            )
    return rows


def physical_srams(rows: Iterable[LogicalSram]) -> list[PhysicalSram]:
    return sorted({row.physical for row in rows})


def check_puhd(depth: int, width: int, mux: int) -> list[str]:
    errors: list[str] = []
    if mux == 1:
        if not (8 <= depth <= 128 and depth % 4 == 0):
            errors.append("PUHD mux1 depth must be 8..128 step 4")
        if not (16 <= width <= 288 and width % 2 == 0):
            errors.append("PUHD mux1 width must be 16..288 step 2")
    elif mux == 2:
        if not (16 <= depth <= 256 and depth % 8 == 0):
            errors.append("PUHD mux2 depth must be 16..256 step 8")
        if not (8 <= width <= 144):
            errors.append("PUHD mux2 width must be 8..144 step 1")
    elif mux == 4:
        if not (32 <= depth <= 2048 and depth % 16 == 0):
            errors.append("PUHD mux4 depth must be 32..2048 step 16")
        if not (8 <= width <= 144):
            errors.append("PUHD mux4 width must be 8..144 step 1")
    else:
        errors.append("PUHD mux must be one of 1, 2, 4")
    if not (128 <= depth * width <= 288 * 1024):
        errors.append("PUHD macro size must be 128 bits..288 Kbits")
    return errors


def check_pd127(depth: int, width: int, mux: int) -> list[str]:
    errors: list[str] = []
    if mux == 4:
        if not (32 <= depth <= 8192 and depth % 16 == 0):
            errors.append("PD127 mux4 depth must be 32..8192 step 16")
        if not (8 <= width <= 144):
            errors.append("PD127 mux4 width must be 8..144 step 1")
    elif mux == 8:
        if not (64 <= depth <= 16384 and depth % 32 == 0):
            errors.append("PD127 mux8 depth must be 64..16384 step 32")
        if not (4 <= width <= 72):
            errors.append("PD127 mux8 width must be 4..72 step 1")
    elif mux == 16:
        if not (4096 <= depth <= 32768 and depth % 64 == 0):
            errors.append("PD127 mux16 depth must be 4096..32768 step 64")
        if not (2 <= width <= 39):
            errors.append("PD127 mux16 width must be 2..39 step 1")
    else:
        errors.append("PD127 mux must be one of 4, 8, 16")
    if mux and depth // mux in {260, 772, 1284, 1796} and depth % mux == 0:
        errors.append("PD127 NWORD/NMUX ratio is explicitly unsupported")
    if not (256 <= depth * width <= 1024 * 1024):
        errors.append("PD127 macro size must be 256 bits..1 Mbit")
    return errors


def validate(rows: list[LogicalSram]) -> None:
    errors: list[str] = []
    for row in rows:
        if row.compiler not in {"PUHD", "PD127"}:
            errors.append(f"{row.logical_name}: compiler must be PUHD or PD127")
            continue
        if row.logical_depth != row.macro_depth:
            errors.append(f"{row.logical_name}: macro_depth must match logical_depth for this flow")
        if row.macro_width * row.slices < row.logical_width:
            errors.append(f"{row.logical_name}: macro_width * slices is narrower than logical_width")
        if row.compiler == "PUHD":
            errors.extend(f"{row.logical_name}: {msg}" for msg in check_puhd(row.macro_depth, row.macro_width, row.mux))
        if row.compiler == "PD127":
            errors.extend(f"{row.logical_name}: {msg}" for msg in check_pd127(row.macro_depth, row.macro_width, row.mux))
    if errors:
        raise SystemExit("\n".join(errors))


def write_compiler_configs(args: argparse.Namespace, physical: list[PhysicalSram]) -> None:
    by_compiler = {"PUHD": [], "PD127": []}
    for phy in physical:
        by_compiler[phy.compiler].append(phy.compiler_config)
    for compiler, configs in by_compiler.items():
        base = Path(args.puhd_dir if compiler == "PUHD" else args.pd127_dir)
        base.mkdir(parents=True, exist_ok=True)
        with (base / "config.txt").open("w") as fh:
            for config in configs:
                fh.write(config + "\n")
        print(f"wrote {base / 'config.txt'} ({len(configs)} macros)")


def write_convert_tcl(args: argparse.Namespace, physical: list[PhysicalSram], out: Path) -> None:
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open("w") as fh:
        for phy in physical:
            nldm = phy.nldm_dir(args)
            db_dir = phy.db_dir(args)
            db_dir.mkdir(parents=True, exist_ok=True)
            libs = sorted(nldm.glob("*.lib"))
            if not libs:
                raise SystemExit(f"missing NLDM libs for {phy.macro_name}: {nldm}")
            for lib in libs:
                base = lib.stem
                tech_name = "_".join(base.split("_")[0:3:2])
                fh.write(f"read_lib {lib}\n")
                fh.write(f"write_lib {tech_name} -output {db_dir / (base + '.db')}\n")
        fh.write("exit\n")
    print(f"wrote {out}")


def file_status(args: argparse.Namespace, physical: list[PhysicalSram], require: bool = False) -> None:
    missing: list[str] = []
    for phy in physical:
        macro_dir = phy.base_dir(args) / phy.macro_name
        db = phy.db_path(args)
        verilog = phy.verilog_path(args)
        states = [
            ("DIR", macro_dir),
            ("DB", db),
            ("VERILOG", verilog),
        ]
        summary = []
        for label, path in states:
            ok = path.exists()
            summary.append(f"{label}={'OK' if ok else 'MISSING'}")
            if require and not ok:
                missing.append(str(path))
        print(f"{phy.macro_name:<48} {' '.join(summary)}")
    if missing:
        raise SystemExit("missing generated SRAM files:\n" + "\n".join(missing))


def write_dc_db_setup(args: argparse.Namespace, physical: list[PhysicalSram], out: Path) -> None:
    out.parent.mkdir(parents=True, exist_ok=True)
    with out.open("w") as fh:
        fh.write("# Generated by backend/sram/scripts/sram_cfg.py. Do not edit by hand.\n")
        fh.write('set IP_LIBRARY_LIST(c910sram,tc) "')
        if physical:
            fh.write("\n")
        for phy in physical:
            db = phy.db_path(args)
            if not db.exists():
                print(f"WARNING: missing {db}")
            fh.write(f"  {db}\n")
        fh.write('"\n')
    print(f"wrote {out}")


def print_rows(rows: list[LogicalSram], physical: list[PhysicalSram], args: argparse.Namespace) -> None:
    print("Logical SRAM mapping:")
    for row in rows:
        split = f"x{row.slices}" if row.slices != 1 else ""
        spare = row.macro_width * row.slices - row.logical_width
        spare_text = f", spare={spare}" if spare else ""
        print(
            f"  {row.logical_name:<28} {row.logical_depth:>5}x{row.logical_width:<3} "
            f"count={row.logical_instances:<2} -> {row.compiler:<5} "
            f"{row.macro_depth}x{row.macro_width}m{row.mux}s{split}{spare_text}"
        )
    print("\nUnique physical macros:")
    for phy in physical:
        print(f"  {phy.compiler:<5} {phy.compiler_config:<14} {phy.macro_name}")


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "command",
        choices=[
            "check",
            "print",
            "list-db",
            "list-verilog",
            "status",
            "verify-generated",
            "write-configs",
            "write-convert-tcl",
            "dc-db-setup",
        ],
    )
    parser.add_argument("--config", required=True)
    parser.add_argument("--puhd-dir", required=True)
    parser.add_argument("--pd127-dir", required=True)
    parser.add_argument("--corner", default="tt0p9v25c")
    parser.add_argument("--out")
    args = parser.parse_args()

    rows = parse_config(Path(args.config))
    validate(rows)
    physical = physical_srams(rows)

    if args.command == "check":
        print(f"OK: {len(rows)} logical SRAM wrappers, {len(physical)} unique physical macros")
    elif args.command == "print":
        print_rows(rows, physical, args)
    elif args.command == "list-db":
        for phy in physical:
            print(phy.db_path(args))
    elif args.command == "list-verilog":
        for phy in physical:
            print(phy.verilog_path(args))
    elif args.command == "status":
        file_status(args, physical, require=False)
    elif args.command == "verify-generated":
        file_status(args, physical, require=True)
    elif args.command == "write-configs":
        write_compiler_configs(args, physical)
    elif args.command == "write-convert-tcl":
        if not args.out:
            raise SystemExit("--out is required")
        write_convert_tcl(args, physical, Path(args.out))
    elif args.command == "dc-db-setup":
        if not args.out:
            raise SystemExit("--out is required")
        write_dc_db_setup(args, physical, Path(args.out))


if __name__ == "__main__":
    main()
