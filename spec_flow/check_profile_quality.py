#!/usr/bin/env python3
import argparse
import json
from pathlib import Path

try:
    from spec_flow.check_simpoint_status import benchmarks_for_suite
except ModuleNotFoundError:
    from check_simpoint_status import benchmarks_for_suite


UNKNOWN = {"[external-or-unknown]", "[unknown]", "[no-symbols]"}


def unknown_percent(items):
    return sum(float(item.get("percent", 0.0)) for item in items if item.get("function") in UNKNOWN)


def module_unresolved_percent(items):
    return sum(
        float(item.get("percent", 0.0))
        for item in items
        if item.get("function", "").startswith("[module:")
        and item.get("function", "").endswith(":unresolved]")
    )


def weighted_percent(manifest, measure):
    value = 0.0
    total_weight = 0.0
    for simpoint in manifest.get("simpoints", []):
        weight = float(simpoint.get("weight", 0.0))
        value += weight * measure(simpoint.get("top_functions", []))
        total_weight += weight
    return value / total_weight if total_weight > 0 else 0.0


def quality_for(manifest):
    global_unknown = unknown_percent(manifest.get("global_top_functions", []))
    weighted_unknown = weighted_percent(manifest, unknown_percent)

    module_map = bool(manifest.get("validation", {}).get("module_map_done"))
    if not module_map:
        quality = "legacy"
    elif weighted_unknown <= 5.0:
        quality = "high"
    elif weighted_unknown <= 20.0:
        quality = "medium"
    else:
        quality = "low"
    return module_map, global_unknown, weighted_unknown, quality


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--suite", default="all")
    parser.add_argument("--size", default="ref")
    parser.add_argument("--spec-runs", default="spec_runs")
    parser.add_argument("benchmarks", nargs="*")
    args = parser.parse_args()

    benches = args.benchmarks or benchmarks_for_suite(args.suite)
    root = Path(args.spec_runs)
    counts = {}

    print("| benchmark | profile | modules | global external unknown % | weighted external unknown % | weighted module-symbol unresolved % |")
    print("|---|---|---:|---:|---:|---:|")
    for bench in benches:
        path = root / f"{bench}_{args.size}_c910" / "manifest.json"
        if not path.exists():
            quality = "missing"
            module_count = 0
            global_unknown = 0.0
            weighted_unknown = 0.0
            weighted_module_unresolved = 0.0
        else:
            manifest = json.loads(path.read_text())
            _, global_unknown, weighted_unknown, quality = quality_for(manifest)
            weighted_module_unresolved = weighted_percent(
                manifest, module_unresolved_percent
            )
            module_count = int(manifest.get("counts", {}).get("mapped_modules", 0))
        counts[quality] = counts.get(quality, 0) + 1
        print(
            f"| `{bench}` | `{quality}` | {module_count} | "
            f"{global_unknown:.2f} | {weighted_unknown:.2f} | "
            f"{weighted_module_unresolved:.2f} |"
        )

    print()
    print("summary: " + ", ".join(f"{key}={counts[key]}" for key in sorted(counts)))


if __name__ == "__main__":
    main()
