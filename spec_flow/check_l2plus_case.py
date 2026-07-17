#!/usr/bin/env python3
import argparse
from pathlib import Path

try:
    from spec_flow.validate_l2plus import validate_manifest
except ModuleNotFoundError:
    from validate_l2plus import validate_manifest


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("bench")
    parser.add_argument("size", choices=("test", "train", "ref"))
    parser.add_argument("--spec-runs", default="spec_runs")
    parser.add_argument("--weight-tolerance", type=float, default=0.002)
    args = parser.parse_args()

    path = Path(args.spec_runs) / f"{args.bench}_{args.size}_c910" / "manifest.json"
    result = validate_manifest(
        path, args.bench, args.size, args.weight_tolerance
    )
    if result["valid"]:
        print(f"ok: {args.bench}/{args.size}")
        return 0
    print(f"invalid: {args.bench}/{args.size}")
    for issue in result["issues"]:
        print(f"- {issue}")
    return 1


if __name__ == "__main__":
    raise SystemExit(main())
