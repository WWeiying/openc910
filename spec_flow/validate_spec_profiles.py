#!/usr/bin/env python3
import argparse
import json
from pathlib import Path


METRIC_PATHS = {
    "dynamic_instructions": ("execution", "dynamic_instructions"),
    "working_set_bytes_64B_lines": ("memory", "working_set_bytes_64B_lines"),
    "warmup_instructions": ("profile", "warmup_instructions"),
}


def nested_value(data, path):
    value = data
    for key in path:
        if not isinstance(value, dict) or key not in value:
            return None
        value = value[key]
    return value


def footprint_share(features):
    phases = features.get("composition_phases")
    if phases:
        total = nested_value(features, METRIC_PATHS["dynamic_instructions"])
        return phases.get("unattributed_instructions", 0) / total if total else 0.0
    total = nested_value(features, METRIC_PATHS["dynamic_instructions"])
    if not total:
        return 0.0
    count = sum(
        int(item["count"])
        for item in features.get("hotspots", {}).get("functions", [])
        if item.get("name", "").startswith("spec_profile_footprint_run")
    )
    return count / total


def validate_case(contract, features, profile):
    profile_contract = contract.get("profiles", {}).get(profile)
    if profile_contract is None:
        return [f"profile {profile} is not defined"]

    errors = []
    kernel_profile = nested_value(features, ("profile", "kernel_profile"))
    if kernel_profile != profile:
        errors.append(
            f"profile metadata is {kernel_profile!r}, expected {profile!r}"
        )
    for metric, bounds in profile_contract.get("metrics", {}).items():
        path = METRIC_PATHS.get(metric)
        if path is None:
            errors.append(f"unknown metric {metric}")
            continue
        value = nested_value(features, path)
        if value is None:
            errors.append(f"metric {metric} is missing")
            continue
        if "min" in bounds and value < bounds["min"]:
            errors.append(f"{metric} {value} is below {bounds['min']}")
        if "max" in bounds and value > bounds["max"]:
            errors.append(f"{metric} {value} exceeds {bounds['max']}")
        if "measured" in bounds:
            tolerance = bounds.get("tolerance", 0)
            if abs(value - bounds["measured"]) > tolerance:
                errors.append(
                    f"{metric} stored measurement is stale: "
                    f"stored={bounds['measured']} actual={value} "
                    f"tolerance={tolerance}"
                )

    share = footprint_share(features)
    max_share = profile_contract.get("max_footprint_instruction_share")
    if max_share is not None and share > max_share:
        errors.append(
            f"footprint instruction share {share:.6f} exceeds {max_share:.6f}"
        )
    return errors


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--contracts", required=True)
    parser.add_argument("--features-dir", required=True)
    parser.add_argument("--profile", choices=("quick", "full"), required=True)
    parser.add_argument("--allow-missing", action="store_true")
    args = parser.parse_args()

    contracts = json.loads(Path(args.contracts).read_text())
    root = Path(args.features_dir) / "cases"
    errors = []
    validated = 0
    print("| case | profile | warmup | instructions | working set | footprint share | status |")
    print("|---|---|---:|---:|---:|---:|---|")
    for case, contract in contracts.get("cases", {}).items():
        path = root / case / "features.json"
        if not path.is_file():
            if args.allow_missing:
                continue
            errors.append(f"{case}: missing {path}")
            print(f"| `{case}` |  |  |  |  |  | missing |")
            continue
        features = json.loads(path.read_text())
        case_errors = validate_case(contract, features, args.profile)
        instructions = nested_value(features, METRIC_PATHS["dynamic_instructions"])
        working_set = nested_value(
            features, METRIC_PATHS["working_set_bytes_64B_lines"]
        )
        kernel_profile = nested_value(features, ("profile", "kernel_profile"))
        warmup = nested_value(features, METRIC_PATHS["warmup_instructions"])
        share = footprint_share(features)
        status = "ok" if not case_errors else "invalid"
        print(
            f"| `{case}` | {kernel_profile} | {warmup} | {instructions} | {working_set} | "
            f"{share * 100.0:.3f}% | {status} |"
        )
        errors.extend(f"{case}: {error}" for error in case_errors)
        validated += 1

    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        raise SystemExit(1)
    print(f"validated SPEC profiles: {validated}")


if __name__ == "__main__":
    main()
