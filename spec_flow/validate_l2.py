#!/usr/bin/env python3
import argparse
import json
import sys
from pathlib import Path


def load_json(path):
    return json.loads(path.read_text())


def main():
    parser = argparse.ArgumentParser(
        description="Validate the SPECspeed train -> representative RTL L2 inputs and results"
    )
    parser.add_argument("--spec-runs", default="spec_runs")
    parser.add_argument(
        "--kernel-map", default="spec_flow/spec2017_speed_kernel_map.json"
    )
    parser.add_argument("--case-root", default="smart_run/tests/cases")
    parser.add_argument("--rtl-results")
    parser.add_argument("--size", default="train")
    args = parser.parse_args()

    kernel_map = load_json(Path(args.kernel_map))
    rows = []
    errors = []
    mapped_cases = set()

    for benchmark in kernel_map.get("benchmarks", []):
        bench = benchmark["bench"]
        manifest_path = (
            Path(args.spec_runs) / f"{bench}_{args.size}_c910" / "manifest.json"
        )
        manifest_ok = False
        weight_sum = 0.0
        clusters = 0
        if not manifest_path.exists():
            errors.append(f"{bench}: missing {manifest_path}")
        else:
            manifest = load_json(manifest_path)
            validation = manifest.get("validation", {})
            simpoints = manifest.get("simpoints", [])
            weight_sum = sum(float(item.get("weight", 0.0)) for item in simpoints)
            clusters = len(simpoints)
            manifest_ok = bool(
                validation.get("compare_pass")
                and validation.get("simpoint_done")
                and simpoints
                and abs(weight_sum - 1.0) <= 0.002
            )
            if not manifest_ok:
                errors.append(
                    f"{bench}: invalid manifest validation or weight sum ({weight_sum:.7f})"
                )

        case_states = []
        for kernel in benchmark.get("kernels", []):
            case = kernel["case"]
            mapped_cases.add(case)
            case_dir = Path(args.case_root) / case
            source_ok = case_dir.is_dir() and any(case_dir.glob("*.c"))
            if not source_ok:
                errors.append(f"{bench}: missing source for {case}")

            rtl_state = "not-checked"
            if args.rtl_results:
                result_dir = Path(args.rtl_results)
                report = result_dir / f"{case}.run_case.report"
                summary = result_dir / f"{case}.summary.txt"
                perf = result_dir / f"{case}.perf"
                detail_perf = result_dir / f"{case}.detail.perf"
                passed = report.exists() and "TEST PASS" in report.read_text(errors="replace")
                rtl_state = (
                    "pass"
                    if passed and summary.exists() and perf.exists() and detail_perf.exists()
                    else "missing"
                )
                if rtl_state != "pass":
                    errors.append(f"{bench}: incomplete RTL result for {case}")
            case_states.append(f"{case}:{rtl_state}")

        rows.append((bench, manifest_ok, clusters, weight_sum, ", ".join(case_states)))

    print("# SPECspeed Train L2 闭环验收")
    print()
    print("本表核验 20 项 train manifest、SimPoint 权重、映射 kernel 源码以及正式 RTL 结果。")
    print()
    print("| benchmark | manifest | clusters | weight sum | mapped RTL case(s) |")
    print("|---|---|---:|---:|---|")
    for bench, manifest_ok, clusters, weight_sum, cases in rows:
        print(
            f"| `{bench}` | {'ok' if manifest_ok else 'invalid'} | {clusters} | "
            f"{weight_sum:.7f} | {cases} |"
        )
    print()
    print(f"验收结果：benchmark={len(rows)}，映射 RTL case={len(mapped_cases)}，错误={len(errors)}。")
    for error in errors:
        print(f"ERROR: {error}", file=sys.stderr)
    return 1 if errors else 0


if __name__ == "__main__":
    raise SystemExit(main())
