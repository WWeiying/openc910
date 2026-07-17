#!/usr/bin/env python3
import argparse
import collections
import os
from array import array
from pathlib import Path


DEFAULT_ID_STRIDE = 1 << 40
MAX_DENSE_RANGE_IDS = 100_000_000


class RawIdMapping:
    def __init__(self, start_id, id_stride):
        self.start_id = start_id
        self.command_base = start_id - 1
        self.id_stride = id_stride
        self.ranges = {}
        self.raw_count = start_id - 1

    def _position(self, raw_id):
        delta = raw_id - self.command_base - 1
        if delta < 0:
            raise KeyError(raw_id)
        return divmod(delta, self.id_stride)

    def add(self, raw_id, compact_id):
        range_index, local_index = self._position(raw_id)
        if local_index >= MAX_DENSE_RANGE_IDS:
            raise ValueError(
                f"raw block ID {raw_id} resolves to implausible local index "
                f"{local_index} with id_stride={self.id_stride}; "
                "the producer and compactor ID strides do not match"
            )
        values = self.ranges.setdefault(range_index, array("Q"))
        if local_index >= len(values):
            values.extend(array("Q", [0]) * (local_index + 1 - len(values)))
        previous = values[local_index]
        if previous == 0:
            values[local_index] = compact_id
            self.raw_count += 1
        return previous

    def __getitem__(self, raw_id):
        if 1 <= raw_id < self.start_id:
            return raw_id
        range_index, local_index = self._position(raw_id)
        try:
            compact_id = self.ranges[range_index][local_index]
        except (KeyError, IndexError) as exc:
            raise KeyError(raw_id) from exc
        if compact_id == 0:
            raise KeyError(raw_id)
        return compact_id

    def __len__(self):
        return self.raw_count


def load_and_compact_map(path, start_id, id_stride=DEFAULT_ID_STRIDE):
    old_entries = []
    new_entries = []
    raw_to_compact = RawIdMapping(start_id, id_stride)
    old_ids = set()
    key_to_compact = {}
    compact_to_key = {}
    next_id = start_id

    with path.open() as stream:
        for line in stream:
            fields = line.split()
            if len(fields) < 3:
                continue
            raw_id = int(fields[0])
            pc = int(fields[1], 16)
            insns = int(fields[2])
            if raw_id < start_id:
                if raw_id in old_ids:
                    raise ValueError(f"duplicate pre-existing block ID {raw_id}")
                old_ids.add(raw_id)
                old_entries.append((raw_id, pc, insns))
                continue

            key = (pc, insns)
            compact_id = key_to_compact.get(key)
            if compact_id is None:
                compact_id = next_id
            previous = raw_to_compact.add(raw_id, compact_id)
            if previous:
                if compact_to_key[previous] != key:
                    raise ValueError(f"raw block ID {raw_id} maps to different TBs")
                continue

            if key not in key_to_compact:
                compact_id = next_id
                next_id += 1
                key_to_compact[key] = compact_id
                compact_to_key[compact_id] = key
                new_entries.append((compact_id, pc, insns))

    expected_old = set(range(1, start_id))
    if old_ids != expected_old:
        missing = sorted(expected_old - old_ids)[:8]
        extra = sorted(old_ids - expected_old)[:8]
        raise ValueError(
            f"pre-existing map is not contiguous before {start_id}: "
            f"missing={missing} extra={extra}"
        )
    return old_entries + new_entries, raw_to_compact


def iter_compact_bbv(path, raw_to_compact):
    with path.open() as stream:
        for line_no, line in enumerate(stream, 1):
            if not line.strip():
                continue
            stripped = line.strip()
            if not stripped.startswith("T"):
                raise ValueError(f"invalid BBV line {line_no}")
            counts = collections.Counter()
            for token in stripped[1:].split():
                if not token.startswith(":"):
                    continue
                parts = token[1:].split(":")
                if len(parts) != 2:
                    raise ValueError(f"invalid BBV token on line {line_no}: {token}")
                raw_id = int(parts[0])
                try:
                    compact_id = raw_to_compact[raw_id]
                except KeyError as exc:
                    raise ValueError(
                        f"BBV line {line_no} references unmapped block ID {raw_id}"
                    ) from exc
                counts[compact_id] += int(parts[1])
            tokens = " ".join(
                f":{block_id}:{counts[block_id]}" for block_id in sorted(counts)
            )
            yield f"T {tokens}\n" if tokens else "T\n"


def compact_bbv(path, raw_to_compact):
    return list(iter_compact_bbv(path, raw_to_compact))


def atomic_write(path, lines):
    tmp = path.with_name(f"{path.name}.tmp.{os.getpid()}")
    line_count = 0
    try:
        with tmp.open("w") as stream:
            for line in lines:
                stream.write(line)
                line_count += 1
        os.replace(tmp, path)
    finally:
        tmp.unlink(missing_ok=True)
    return line_count


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--bbv", required=True)
    parser.add_argument("--map", required=True)
    parser.add_argument("--start-id", type=int, required=True)
    parser.add_argument("--id-stride", type=int, default=DEFAULT_ID_STRIDE)
    args = parser.parse_args()

    if args.start_id < 1:
        parser.error("--start-id must be positive")
    if args.id_stride < 1:
        parser.error("--id-stride must be positive")
    bbv_path = Path(args.bbv)
    map_path = Path(args.map)
    entries, raw_to_compact = load_and_compact_map(
        map_path, args.start_id, args.id_stride
    )
    atomic_write(
        map_path,
        (f"{block_id} 0x{pc:x} {insns}\n" for block_id, pc, insns in entries),
    )
    interval_count = atomic_write(
        bbv_path, iter_compact_bbv(bbv_path, raw_to_compact)
    )
    print(
        f"[compact-bbv] start_id={args.start_id} raw_ids={len(raw_to_compact)} "
        f"compact_blocks={len(entries)} intervals={interval_count}"
    )


if __name__ == "__main__":
    main()
