#!/usr/bin/env python3
"""Validate one exact, clean quick/full program-feature evidence set."""

import argparse
from pathlib import Path

try:
    from spec_flow.validate_l2plus import validate_feature_results
except ModuleNotFoundError:
    from validate_l2plus import validate_feature_results


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--root", type=Path, required=True)
    parser.add_argument("--profile", choices=("quick", "full"), required=True)
    parser.add_argument("--commit", required=True)
    parser.add_argument("--expected-case", action="append", default=[])
    args = parser.parse_args()
    expected = set(args.expected_case)
    if not expected:
        parser.error("at least one --expected-case is required")

    passed, errors = validate_feature_results(
        args.root,
        expected,
        args.profile,
        require_clean=True,
        required_commit=args.commit,
    )
    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        return 1
    print(f"validated feature evidence: {passed}/{len(expected)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
