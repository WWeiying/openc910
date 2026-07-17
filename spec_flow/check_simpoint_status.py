#!/usr/bin/env python3
import argparse
import json
from pathlib import Path


RATE = "500.perlbench_r 502.gcc_r 503.bwaves_r 505.mcf_r 507.cactuBSSN_r 508.namd_r 510.parest_r 511.povray_r 519.lbm_r 520.omnetpp_r 521.wrf_r 523.xalancbmk_r 525.x264_r 526.blender_r 527.cam4_r 531.deepsjeng_r 538.imagick_r 541.leela_r 544.nab_r 548.exchange2_r 549.fotonik3d_r 554.roms_r 557.xz_r".split()
SPEED = "600.perlbench_s 602.gcc_s 603.bwaves_s 605.mcf_s 607.cactuBSSN_s 619.lbm_s 620.omnetpp_s 621.wrf_s 623.xalancbmk_s 625.x264_s 627.cam4_s 628.pop2_s 631.deepsjeng_s 638.imagick_s 641.leela_s 644.nab_s 648.exchange2_s 649.fotonik3d_s 654.roms_s 657.xz_s".split()


def benchmarks_for_suite(suite):
    if suite == "rate":
        return RATE
    if suite == "speed":
        return SPEED
    if suite == "all":
        return RATE + SPEED
    if suite == "intrate":
        return [b for b in RATE if b.endswith("_r") and b[:3] in {"500", "502", "505", "520", "523", "525", "531", "541", "548", "557"}]
    if suite == "fprate":
        return [b for b in RATE if b not in benchmarks_for_suite("intrate")]
    if suite == "intspeed":
        return [b for b in SPEED if b[:3] in {"600", "602", "605", "620", "623", "625", "631", "641", "648", "657"}]
    if suite == "fpspeed":
        return [b for b in SPEED if b not in benchmarks_for_suite("intspeed")]
    raise SystemExit(f"unknown suite: {suite}")


def load_manifest(path):
    try:
        return json.loads(path.read_text())
    except Exception as exc:
        return {"_error": str(exc)}


def row_for(root, bench, size):
    out_dir = root / f"{bench}_{size}_c910"
    stem = f"{bench}_{size}"
    manifest = out_dir / "manifest.json"
    bbv = out_dir / f"{stem}.bb"
    simpoints = out_dir / f"{stem}.simpoints"
    weights = out_dir / f"{stem}.weights"
    compare = out_dir / "compare.log"

    if manifest.exists():
        data = load_manifest(manifest)
        if "_error" in data:
            return [bench, "bad_manifest", "", "", "", data["_error"]]
        validation = data.get("validation", {})
        counts = data.get("counts", {})
        clusters = len(data.get("simpoints", []))
        if validation.get("compare_pass") and validation.get("simpoint_done"):
            status = "ok"
        elif validation.get("simpoint_done"):
            status = "compare_failed"
        else:
            status = "incomplete"
        return [
            bench,
            status,
            str(counts.get("bbv_intervals", "")),
            str(counts.get("mapped_blocks", "")),
            str(clusters),
            str(out_dir),
        ]

    if bbv.exists():
        intervals = sum(1 for _ in bbv.open(errors="replace"))
        artifacts = []
        if simpoints.exists():
            artifacts.append("simpoints")
        if weights.exists():
            artifacts.append("weights")
        if compare.exists():
            artifacts.append("compare")
        detail = ",".join(artifacts) if artifacts else "bbv_only"
        return [bench, "partial", str(intervals), "", "", detail]

    return [bench, "missing", "", "", "", str(out_dir)]


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--suite", default="speed", choices=["rate", "speed", "all", "intrate", "fprate", "intspeed", "fpspeed"])
    parser.add_argument("--size", default="test")
    parser.add_argument("--spec-runs", default="spec_runs")
    parser.add_argument("benchmarks", nargs="*")
    args = parser.parse_args()

    root = Path(args.spec_runs)
    benches = args.benchmarks or benchmarks_for_suite(args.suite)
    rows = [row_for(root, bench, args.size) for bench in benches]

    print("| benchmark | status | intervals | blocks | clusters | detail |")
    print("|---|---|---:|---:|---:|---|")
    for row in rows:
        print("| " + " | ".join(f"`{x}`" if i in {0, 1} else x for i, x in enumerate(row)) + " |")

    counts = {}
    for _, status, *_ in rows:
        counts[status] = counts.get(status, 0) + 1
    print()
    print("summary: " + ", ".join(f"{k}={v}" for k, v in sorted(counts.items())))


if __name__ == "__main__":
    main()
