#!/usr/bin/env python3
"""Merge FSDB signal configurations without silently replacing aliases."""

from __future__ import annotations

import argparse
import json
from itertools import product
from pathlib import Path


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("output", type=Path)
    parser.add_argument("inputs", nargs="+", type=Path)
    return parser.parse_args()


def signal_identity(signal: dict) -> tuple[str, str, str]:
    return signal["alias"], signal["path"], signal.get("radix", "h")


def variable_values(name: str, specification: object) -> list[str | int]:
    if isinstance(specification, list):
        values = specification
    elif isinstance(specification, dict):
        unknown = set(specification) - {"start", "stop", "step"}
        if unknown:
            raise ValueError(
                f"template variable {name!r} has unknown keys: "
                + ", ".join(sorted(unknown))
            )
        if "stop" not in specification:
            raise ValueError(f"template variable {name!r} requires stop")
        start = specification.get("start", 0)
        stop = specification["stop"]
        step = specification.get("step", 1)
        if not all(isinstance(value, int) for value in (start, stop, step)):
            raise ValueError(f"template variable {name!r} range must be integral")
        if step == 0:
            raise ValueError(f"template variable {name!r} step cannot be zero")
        values = list(range(start, stop, step))
    else:
        raise ValueError(f"template variable {name!r} must be a list or range")
    if not values or not all(isinstance(value, (str, int)) for value in values):
        raise ValueError(f"template variable {name!r} has invalid values")
    return values


def expanded_signals(config: dict) -> list[dict]:
    result = [config["cycle_signal"], *config.get("signals", [])]
    for group_index, group in enumerate(config.get("signal_template_groups", [])):
        variables = group.get("variables", {})
        templates = group.get("signals", [])
        if not variables or not templates:
            raise ValueError(f"signal template group {group_index} is incomplete")
        names = list(variables)
        value_sets = [variable_values(name, variables[name]) for name in names]
        for values in product(*value_sets):
            substitutions = dict(zip(names, values))
            for template in templates:
                result.append(
                    {
                        key: value.format_map(substitutions)
                        if isinstance(value, str)
                        else value
                        for key, value in template.items()
                    }
                )
    return result


def validate_unique_signals(config: dict) -> int:
    aliases: dict[str, str] = {}
    paths: dict[str, str] = {}
    signals = expanded_signals(config)
    for signal in signals:
        alias, path, _ = signal_identity(signal)
        if alias in aliases:
            raise ValueError(
                f"duplicate signal alias {alias!r}: {aliases[alias]} and {path}"
            )
        if path in paths:
            raise ValueError(
                f"signal path {path} is listed as both {paths[path]!r} and {alias!r}"
            )
        aliases[alias] = path
        paths[path] = alias
    return len(signals)


def main() -> None:
    args = parse_args()
    configs = [json.loads(path.read_text()) for path in args.inputs]
    if not configs:
        raise ValueError("at least one input configuration is required")

    merged = {
        "sample": configs[0]["sample"],
        "cycle_signal": configs[0]["cycle_signal"],
        "signals": [],
        "signal_template_groups": [],
    }
    seen: dict[str, dict] = {merged["cycle_signal"]["alias"]: merged["cycle_signal"]}
    for path, config in zip(args.inputs, configs):
        if config.get("sample") != merged["sample"]:
            raise ValueError(f"sample configuration differs in {path}")
        if signal_identity(config["cycle_signal"]) != signal_identity(
            merged["cycle_signal"]
        ):
            raise ValueError(f"cycle signal differs in {path}")
        for signal in config.get("signals", []):
            alias = signal["alias"]
            previous = seen.get(alias)
            if previous is not None:
                if signal_identity(previous) != signal_identity(signal):
                    raise ValueError(
                        f"alias {alias!r} has conflicting definitions in {path}"
                    )
                continue
            seen[alias] = signal
            merged["signals"].append(signal)
        merged["signal_template_groups"].extend(
            config.get("signal_template_groups", [])
        )

    expanded_count = validate_unique_signals(merged)
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(merged, indent=2, ensure_ascii=False) + "\n")
    print(
        f"merged {len(merged['signals'])} direct signals; "
        f"validated {expanded_count} expanded signals in {args.output}"
    )


if __name__ == "__main__":
    main()
