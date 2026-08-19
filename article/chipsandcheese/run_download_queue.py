#!/usr/bin/env python3
"""Run a resumable queue of webpage downloads.

The queue contains one URL per line. Existing archives are matched by their
canonical or Open Graph URL, so files created with an older custom basename are
skipped instead of downloaded again.
"""

from __future__ import annotations

import argparse
from concurrent.futures import ThreadPoolExecutor, as_completed
import json
from pathlib import Path
import re
import subprocess
import sys
import time
from urllib.parse import urlsplit


CANONICAL_PATTERNS = (
    re.compile(r'<meta[^>]+property=["\']og:url["\'][^>]+content=["\']([^"\']+)'),
    re.compile(r'<meta[^>]+content=["\']([^"\']+)["\'][^>]+property=["\']og:url["\']'),
)


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description="Download a resumable URL queue")
    base = Path(__file__).resolve().parent
    parser.add_argument(
        "--queue",
        type=Path,
        default=base / "input" / "chester_lam_cpu_article_urls.txt",
    )
    parser.add_argument("--output-dir", type=Path, default=base / "input")
    parser.add_argument("--workers", type=int, default=3)
    parser.add_argument("--retries", type=int, default=1)
    return parser.parse_args()


def normalize_url(url: str) -> str:
    return url.strip().rstrip("/")


def read_canonical(path: Path) -> str | None:
    try:
        text = path.read_text(encoding="utf-8", errors="ignore")
    except OSError:
        return None
    for pattern in CANONICAL_PATTERNS:
        match = pattern.search(text)
        if match:
            return normalize_url(match.group(1))
    return None


def derive_name(url: str) -> str:
    slug = Path(urlsplit(url).path).name
    return re.sub(r"[^a-z0-9]+", "_", slug.lower()).strip("_") or "webpage"


def existing_archives(output_dir: Path) -> dict[str, Path]:
    result: dict[str, Path] = {}
    for path in output_dir.glob("*.html"):
        canonical = read_canonical(path)
        if canonical:
            result[canonical] = path
    return result


def download_one(
    index: int,
    total: int,
    url: str,
    downloader: Path,
    output_dir: Path,
    log_dir: Path,
    retries: int,
) -> dict[str, object]:
    name = derive_name(url)
    log_path = log_dir / f"{name}.log"
    for attempt in range(1, retries + 2):
        print(f"[{index:03d}/{total}] START attempt={attempt} {url}", flush=True)
        with log_path.open("a", encoding="utf-8") as log:
            log.write(f"\n=== attempt {attempt} {url} ===\n")
            result = subprocess.run(
                [
                    sys.executable,
                    str(downloader),
                    url,
                    "--name",
                    name,
                    "--output-dir",
                    str(output_dir),
                    "--allow-partial",
                ],
                stdout=log,
                stderr=subprocess.STDOUT,
                check=False,
            )
        html_path = output_dir / f"{name}.html"
        canonical = read_canonical(html_path) if html_path.exists() else None
        if result.returncode == 0 and canonical == url:
            print(f"[{index:03d}/{total}] DONE {name}", flush=True)
            return {
                "index": index,
                "url": url,
                "status": "downloaded",
                "html": str(html_path),
                "log": str(log_path),
            }
        if html_path.exists() and canonical == url:
            print(f"[{index:03d}/{total}] DONE_PARTIAL {name}", flush=True)
            return {
                "index": index,
                "url": url,
                "status": "downloaded_partial",
                "html": str(html_path),
                "log": str(log_path),
            }
        print(
            f"[{index:03d}/{total}] RETRY_OR_FAIL attempt={attempt} exit={result.returncode} {name}",
            flush=True,
        )
        time.sleep(2 * attempt)
    return {
        "index": index,
        "url": url,
        "status": "failed",
        "log": str(log_path),
    }


def main() -> int:
    args = parse_args()
    if args.workers < 1 or args.retries < 0:
        raise SystemExit("--workers must be positive and --retries must be non-negative")

    base = Path(__file__).resolve().parent
    downloader = base / "download_webpage.py"
    output_dir = args.output_dir.resolve()
    queue_path = args.queue.resolve()
    log_dir = output_dir / ".chester_lam_download_logs"
    log_dir.mkdir(parents=True, exist_ok=True)

    urls = [normalize_url(line) for line in queue_path.read_text().splitlines() if line.strip()]
    if len(urls) != len(set(urls)):
        raise SystemExit("queue contains duplicate URLs")

    existing = existing_archives(output_dir)
    pending = [(index, url) for index, url in enumerate(urls, 1) if url not in existing]
    records: list[dict[str, object]] = [
        {
            "index": index,
            "url": url,
            "status": "skipped_existing",
            "html": str(existing[url]),
        }
        for index, url in enumerate(urls, 1)
        if url in existing
    ]

    print(
        f"QUEUE_START total={len(urls)} existing={len(records)} "
        f"pending={len(pending)} workers={args.workers}",
        flush=True,
    )
    with ThreadPoolExecutor(max_workers=args.workers) as executor:
        futures = [
            executor.submit(
                download_one,
                index,
                len(urls),
                url,
                downloader,
                output_dir,
                log_dir,
                args.retries,
            )
            for index, url in pending
        ]
        for future in as_completed(futures):
            records.append(future.result())

    records.sort(key=lambda item: int(item["index"]))
    summary_path = output_dir / "chester_lam_cpu_download_summary.json"
    summary_path.write_text(
        json.dumps(records, indent=2, ensure_ascii=False) + "\n",
        encoding="utf-8",
    )
    counts: dict[str, int] = {}
    for record in records:
        status = str(record["status"])
        counts[status] = counts.get(status, 0) + 1
    print(f"QUEUE_FINISHED counts={json.dumps(counts, sort_keys=True)}", flush=True)
    print(f"SUMMARY {summary_path}", flush=True)
    return 1 if counts.get("failed", 0) else 0


if __name__ == "__main__":
    raise SystemExit(main())
