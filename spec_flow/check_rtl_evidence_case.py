#!/usr/bin/env python3
"""Validate one archived RTL case before reusing it in a resumed run."""

import argparse
import json
from pathlib import Path

try:
    from spec_flow.validate_l2plus import REQUIRED_RTL_SUFFIXES
    from spec_flow.validate_spec_rtl_profiles import validate_case
except ModuleNotFoundError:
    from validate_l2plus import REQUIRED_RTL_SUFFIXES
    from validate_spec_rtl_profiles import validate_case


def validate_archived_case(
    case,
    results,
    contracts_path,
    profile,
    tolerance,
    expected_detail_rows,
    features_dir=None,
):
    errors = []
    for suffix in REQUIRED_RTL_SUFFIXES:
        artifact = results / f"{case}{suffix}"
        if not artifact.is_file() or artifact.stat().st_size == 0:
            errors.append(f"missing/empty {artifact.name}")
    if errors:
        return errors

    contracts = json.loads(contracts_path.read_text()).get("cases", {})
    contract = contracts.get(case)
    if contract is None:
        return [f"profile contract is missing for {case}"]
    _, profile_errors = validate_case(
        case,
        contract,
        results,
        profile,
        tolerance,
        expected_detail_rows,
        features_dir,
        True,
    )
    errors.extend(profile_errors)
    perf = (results / f"{case}.perf").read_text(errors="replace")
    if "|     Kernel" not in perf:
        errors.append("perf report does not contain the Kernel phase")
    run_log = (results / f"{case}.run.vcs.log").read_text(errors="replace")
    if "TEST FAIL" in run_log:
        errors.append("run.vcs.log contains TEST FAIL")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--case", required=True)
    parser.add_argument("--results-dir", type=Path, required=True)
    parser.add_argument("--contracts", type=Path, required=True)
    parser.add_argument("--profile", choices=("quick", "full"), required=True)
    parser.add_argument("--retired-tolerance", type=int, default=6)
    parser.add_argument("--expected-detail-rows", type=int, default=1048)
    parser.add_argument("--features-dir", type=Path)
    args = parser.parse_args()
    if args.retired_tolerance < 0 or args.expected_detail_rows < 0:
        parser.error("tolerance and expected detail rows must be non-negative")

    errors = validate_archived_case(
        args.case,
        args.results_dir,
        args.contracts,
        args.profile,
        args.retired_tolerance,
        args.expected_detail_rows,
        args.features_dir,
    )
    if errors:
        for error in errors:
            print(f"ERROR: {args.case}: {error}")
        return 1
    print(f"validated RTL evidence case: {args.case}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
