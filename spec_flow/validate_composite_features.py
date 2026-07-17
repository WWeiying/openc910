#!/usr/bin/env python3
import argparse
import json
import re
from pathlib import Path


def group_matches(function, group):
    if function in set(group.get("functions", [])):
        return True
    return any(
        re.search(pattern, function)
        for pattern in group.get("function_patterns", [])
    )


def measured_share_for_profile(group, profile):
    by_profile = group.get("measured_instruction_share_by_profile", {})
    if profile in by_profile:
        return float(by_profile[profile])
    if profile == "quick" and "measured_instruction_share" in group:
        return float(group["measured_instruction_share"])
    return None


def validate_profile_constraints(kernel, features, profile):
    constraints = kernel.get("profile_constraints", {}).get(profile, {})
    values = {
        "dynamic_instructions": features.get("execution", {}).get(
            "dynamic_instructions"
        ),
        "working_set_bytes_64B_lines": features.get("memory", {}).get(
            "working_set_bytes_64B_lines"
        ),
    }
    errors = []
    for metric, bounds in constraints.items():
        value = values.get(metric)
        if value is None:
            errors.append(f"profile constraint metric {metric} is missing")
            continue
        if "min" in bounds and value < bounds["min"]:
            errors.append(
                f"{profile} {metric} {value} is below {bounds['min']}"
            )
        if "max" in bounds and value > bounds["max"]:
            errors.append(
                f"{profile} {metric} {value} exceeds {bounds['max']}"
            )
    return errors


def measure_composition(row, features, profile="quick"):
    kernel = row["kernels"][0]
    groups = kernel.get("composition", [])
    phase_measurement = features.get("composition_phases")
    if phase_measurement:
        phases = phase_measurement.get("phases", [])
        if len(phases) != len(groups):
            raise ValueError(
                f"{row['bench']}: measured {len(phases)} phases for {len(groups)} groups"
            )
        measured = {phase["name"]: phase for phase in phases}
        expected = {f"phase{index}" for index in range(len(groups))}
        if set(measured) != expected:
            raise ValueError(
                f"{row['bench']}: phase names {sorted(measured)} do not match "
                f"{sorted(expected)}"
            )
        matched = int(phase_measurement["attributed_instructions"])
        total = int(features["execution"]["dynamic_instructions"])
        unmatched = total - matched
        return {
            "case": kernel["case"],
            "total": total,
            "matched": matched,
            "unmatched": unmatched,
            "groups": [
                {
                    "name": group["name"],
                    "count": int(measured[f"phase{index}"]["count"]),
                    "share": float(measured[f"phase{index}"]["share"]),
                    "target": float(group["target_weight"]),
                    "stored_measured": measured_share_for_profile(group, profile),
                }
                for index, group in enumerate(groups)
            ],
        }
    counts = {group["name"]: 0 for group in groups}
    unmatched = 0
    duplicate_matches = []

    for item in features.get("hotspots", {}).get("functions", []):
        function = item["name"]
        count = int(item["count"])
        matches = [group for group in groups if group_matches(function, group)]
        if len(matches) > 1:
            duplicate_matches.append(function)
        elif len(matches) == 1:
            counts[matches[0]["name"]] += count
        else:
            unmatched += count

    matched = sum(counts.values())
    if duplicate_matches:
        raise ValueError(
            f"{row['bench']}: functions match multiple composition groups: "
            + ",".join(duplicate_matches)
        )
    if matched <= 0:
        raise ValueError(f"{row['bench']}: composition selectors matched no instructions")
    total = int(features["execution"]["dynamic_instructions"])
    return {
        "case": kernel["case"],
        "total": total,
        "matched": matched,
        "unmatched": unmatched,
        "groups": [
            {
                "name": group["name"],
                "count": counts[group["name"]],
                "share": counts[group["name"]] / matched,
                "target": float(group["target_weight"]),
                "stored_measured": measured_share_for_profile(group, profile),
            }
            for group in groups
        ],
    }


def validate_measurement(
    row,
    features,
    target_tolerance=0.005,
    stored_tolerance=0.00001,
    unmatched_tolerance=0.001,
    profile="quick",
):
    result = measure_composition(row, features, profile)
    kernel = row["kernels"][0]
    errors = validate_profile_constraints(kernel, features, profile)
    effective_unmatched_tolerance = max(
        unmatched_tolerance,
        float(kernel.get("max_unattributed_instruction_share", 0.0)),
    )
    if result["unmatched"] / result["total"] > effective_unmatched_tolerance:
        errors.append(
            f"unmatched instruction share {result['unmatched'] / result['total']:.7f} "
            f"exceeds {effective_unmatched_tolerance:.7f}"
        )
    for group in result["groups"]:
        if abs(group["share"] - group["target"]) > target_tolerance:
            errors.append(
                f"{group['name']} share {group['share']:.7f} differs from "
                f"target {group['target']:.7f}"
            )
        if (group["stored_measured"] is not None and
                abs(group["share"] - group["stored_measured"]) > stored_tolerance):
            errors.append(
                f"{group['name']} stored measured share is stale: "
                f"stored={group['stored_measured']:.7f} actual={group['share']:.7f}"
            )
    return result, errors


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--kernel-map", action="append", required=True)
    parser.add_argument("--features-dir", required=True)
    parser.add_argument("--target-tolerance", type=float, default=0.005)
    parser.add_argument("--stored-tolerance", type=float, default=0.00001)
    parser.add_argument("--unmatched-tolerance", type=float, default=0.001)
    parser.add_argument("--profile", choices=("quick", "full"), default="quick")
    parser.add_argument(
        "--allow-missing",
        action="store_true",
        help="validate only composite cases present in a partial feature run",
    )
    args = parser.parse_args()

    features_dir = Path(args.features_dir)
    rows = []
    seen = set()
    for map_name in args.kernel_map:
        data = json.loads(Path(map_name).read_text())
        for row in data.get("benchmarks", []):
            kernel = row.get("kernels", [{}])[0]
            if not kernel.get("composition") or kernel["case"] in seen:
                continue
            seen.add(kernel["case"])
            rows.append(row)

    errors = []
    validated = 0
    print("| benchmark | composite case | matched/total instructions | max target error (pp) | status |")
    print("|---|---|---:|---:|---|")
    for row in rows:
        case = row["kernels"][0]["case"]
        path = features_dir / "cases" / case / "features.json"
        if not path.is_file():
            if args.allow_missing:
                continue
            errors.append(f"{row['bench']}: missing {path}")
            print(f"| `{row['bench']}` | `{case}` |  |  | missing |")
            continue
        features = json.loads(path.read_text())
        validated += 1
        result, row_errors = validate_measurement(
            row,
            features,
            args.target_tolerance,
            args.stored_tolerance,
            args.unmatched_tolerance,
            args.profile,
        )
        max_error = max(
            abs(group["share"] - group["target"])
            for group in result["groups"]
        ) * 100.0
        status = "ok" if not row_errors else "invalid"
        print(
            f"| `{row['bench']}` | `{case}` | "
            f"{result['matched']}/{result['total']} | {max_error:.4f} | {status} |"
        )
        errors.extend(f"{row['bench']}: {error}" for error in row_errors)

    if errors:
        for error in errors:
            print(f"ERROR: {error}")
        raise SystemExit(1)
    print(f"validated composite mixes: {validated}")


if __name__ == "__main__":
    main()
