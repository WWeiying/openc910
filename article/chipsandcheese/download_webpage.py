#!/usr/bin/env python3
"""Download one web page and its required assets as a portable local archive.

The output follows the layout used by the Chips and Cheese source material:

    <name>.html
    <name>_files/

The script uses wget for fetching and link conversion, then moves the main HTML
file next to a flat asset directory and updates local references accordingly.
"""

from __future__ import annotations

import argparse
import html as html_module
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import unicodedata
from urllib.parse import quote, unquote, urlsplit


DEFAULT_USER_AGENT = (
    "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 "
    "(KHTML, like Gecko) Chrome/124.0 Safari/537.36"
)
NAME_PATTERN = re.compile(r"[a-z0-9][a-z0-9_-]*\Z")
HTML_ATTRIBUTE_PATTERN = re.compile(
    r"(?P<prefix>\b(?:src|href|poster|data-src|data-srcset|srcset)\s*=\s*)"
    r"(?P<quote>['\"])(?P<value>.*?)(?P=quote)",
    flags=re.IGNORECASE | re.DOTALL,
)
CSS_URL_PATTERN = re.compile(
    r"url\(\s*(?P<quote>['\"]?)(?P<value>[^)'\"]+)(?P=quote)\s*\)",
    flags=re.IGNORECASE,
)


class DownloadError(RuntimeError):
    """Raised when a page archive cannot be created safely."""


def parse_arguments() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description=(
            "Download a web page, its images, stylesheets, and scripts into "
            "an HTML file plus a matching _files directory."
        )
    )
    parser.add_argument("url", help="Web page URL to archive")
    parser.add_argument(
        "--name",
        help=(
            "English output basename using lowercase letters, numbers, '_' or '-'. "
            "Defaults to the last component of the URL."
        ),
    )
    parser.add_argument(
        "--output-dir",
        type=Path,
        default=Path(__file__).resolve().parent / "input",
        help="Destination directory (default: %(default)s)",
    )
    parser.add_argument(
        "--timeout",
        type=int,
        default=30,
        help="Network timeout in seconds for each wget operation (default: %(default)s)",
    )
    parser.add_argument(
        "--tries",
        type=int,
        default=3,
        help="Maximum wget attempts per resource (default: %(default)s)",
    )
    parser.add_argument(
        "--user-agent",
        default=DEFAULT_USER_AGENT,
        help="HTTP User-Agent sent by wget",
    )
    parser.add_argument(
        "--allow-partial",
        action="store_true",
        help="Keep the archive when optional resources fail but the main HTML exists",
    )
    return parser.parse_args()


def derive_name(url: str) -> str:
    path_parts = [part for part in urlsplit(url).path.split("/") if part]
    raw_name = path_parts[-1] if path_parts else urlsplit(url).hostname or "webpage"
    normalized = unicodedata.normalize("NFKD", unquote(raw_name))
    ascii_name = normalized.encode("ascii", "ignore").decode("ascii").lower()
    name = re.sub(r"[^a-z0-9]+", "_", ascii_name).strip("_")
    return name or "webpage"


def validate_arguments(args: argparse.Namespace) -> tuple[str, Path]:
    parsed_url = urlsplit(args.url)
    if parsed_url.scheme not in {"http", "https"} or not parsed_url.netloc:
        raise DownloadError("URL must start with http:// or https://")
    if args.timeout <= 0 or args.tries <= 0:
        raise DownloadError("--timeout and --tries must be positive integers")

    name = args.name or derive_name(args.url)
    if not NAME_PATTERN.fullmatch(name):
        raise DownloadError(
            "--name must use lowercase English letters, numbers, '_' or '-', "
            "and must start with a letter or number"
        )

    output_dir = args.output_dir.expanduser().resolve()
    output_dir.mkdir(parents=True, exist_ok=True)
    html_path = output_dir / f"{name}.html"
    asset_dir = output_dir / f"{name}_files"
    if html_path.exists() or asset_dir.exists():
        raise DownloadError(
            f"refusing to overwrite existing archive: {html_path} or {asset_dir}"
        )
    return name, output_dir


def run_wget(args: argparse.Namespace, work_dir: Path) -> int:
    wget = shutil.which("wget")
    if wget is None:
        raise DownloadError("wget is required but was not found in PATH")

    command = [
        wget,
        "--page-requisites",
        "--convert-links",
        "--adjust-extension",
        "--span-hosts",
        "--no-directories",
        "--restrict-file-names=windows",
        "--trust-server-names",
        "--execute=robots=off",
        "--max-redirect=20",
        f"--timeout={args.timeout}",
        f"--tries={args.tries}",
        f"--user-agent={args.user_agent}",
        f"--directory-prefix={work_dir}",
        "--no-verbose",
        "--",
        args.url,
    ]
    print(f"Downloading {args.url}", file=sys.stderr)
    return subprocess.run(command, check=False).returncode


def looks_like_html(path: Path) -> bool:
    if not path.is_file():
        return False
    try:
        prefix = path.read_bytes()[:8192].lower()
    except OSError:
        return False
    return b"<html" in prefix or b"<!doctype html" in prefix


def select_main_html(work_dir: Path) -> Path:
    candidates = [path for path in work_dir.iterdir() if looks_like_html(path)]
    if not candidates:
        raise DownloadError("wget did not produce a readable HTML page")
    return max(candidates, key=lambda path: path.stat().st_size)


def decode_repeatedly(value: str, limit: int = 3) -> list[str]:
    values = [value]
    for _ in range(limit):
        decoded = unquote(values[-1])
        if decoded == values[-1]:
            break
        values.append(decoded)
    return values


def find_local_asset(value: str, asset_names: set[str]) -> tuple[str, str, str] | None:
    unescaped = html_module.unescape(value.strip())
    if not unescaped or unescaped.startswith(("#", "//")):
        return None

    parsed = urlsplit(unescaped)
    if parsed.scheme or parsed.netloc or parsed.path.startswith("/"):
        return None

    path_variants = decode_repeatedly(parsed.path)
    candidates: list[str] = []
    for path_variant in path_variants:
        candidates.append(Path(path_variant).name)
        if parsed.query:
            candidates.extend(
                [
                    Path(f"{path_variant}?{parsed.query}").name,
                    Path(f"{path_variant}@{parsed.query}").name,
                    Path(f"{path_variant}%3F{parsed.query}").name,
                ]
            )

    for candidate in candidates:
        if candidate in asset_names:
            return candidate, parsed.query, parsed.fragment
    return None


def portable_reference(asset_dir_name: str, asset_name: str) -> str:
    # Percent signs in wget's Windows-safe filenames are literal characters.
    # Encode them as %25 so a browser does not turn (for example) "%3A" into
    # a colon while resolving the local file URL.
    encoded_name = quote(asset_name, safe="._-~@+")
    return f"./{asset_dir_name}/{encoded_name}"


def rewrite_single_url(value: str, asset_names: set[str], asset_dir_name: str) -> str:
    match = find_local_asset(value, asset_names)
    if match is None:
        return value
    asset_name, _query, fragment = match
    rewritten = portable_reference(asset_dir_name, asset_name)
    if fragment:
        rewritten += f"#{fragment}"
    return rewritten


def rewrite_srcset(value: str, asset_names: set[str], asset_dir_name: str) -> str:
    if value.lstrip().lower().startswith("data:"):
        return value
    rewritten_items = []
    for item in value.split(","):
        fields = item.strip().split(None, 1)
        if not fields:
            continue
        url = rewrite_single_url(fields[0], asset_names, asset_dir_name)
        rewritten_items.append(url if len(fields) == 1 else f"{url} {fields[1]}")
    return ", ".join(rewritten_items)


def rewrite_html(main_html: Path, asset_dir_name: str) -> tuple[str, int]:
    raw_html = main_html.read_text(encoding="utf-8", errors="surrogateescape")
    asset_names = {
        path.name for path in main_html.parent.iterdir() if path.is_file() and path != main_html
    }
    rewrite_count = 0

    def replace_attribute(match: re.Match[str]) -> str:
        nonlocal rewrite_count
        prefix = match.group("prefix")
        quote_character = match.group("quote")
        value = match.group("value")
        attribute_name = prefix.split("=", 1)[0].strip().lower()
        if attribute_name in {"srcset", "data-srcset"}:
            rewritten = rewrite_srcset(value, asset_names, asset_dir_name)
        else:
            rewritten = rewrite_single_url(value, asset_names, asset_dir_name)
        if rewritten != value:
            rewrite_count += 1
        return f"{prefix}{quote_character}{rewritten}{quote_character}"

    rewritten_html = HTML_ATTRIBUTE_PATTERN.sub(replace_attribute, raw_html)

    def replace_css_url(match: re.Match[str]) -> str:
        nonlocal rewrite_count
        quote_character = match.group("quote")
        value = match.group("value")
        rewritten = rewrite_single_url(value, asset_names, asset_dir_name)
        if rewritten != value:
            rewrite_count += 1
        return f"url({quote_character}{rewritten}{quote_character})"

    rewritten_html = CSS_URL_PATTERN.sub(replace_css_url, rewritten_html)
    return rewritten_html, rewrite_count


def create_archive(args: argparse.Namespace, name: str, output_dir: Path) -> tuple[Path, Path]:
    work_dir = Path(tempfile.mkdtemp(prefix=f".{name}_download_", dir=output_dir))
    temporary_html = output_dir / f".{name}.html.tmp-{os.getpid()}"
    final_html = output_dir / f"{name}.html"
    final_assets = output_dir / f"{name}_files"

    try:
        return_code = run_wget(args, work_dir)
        main_html = select_main_html(work_dir)
        if return_code != 0 and not args.allow_partial:
            raise DownloadError(
                f"wget exited with status {return_code}; rerun with --allow-partial "
                "only if missing optional resources are acceptable"
            )
        if return_code != 0:
            print(
                f"Warning: wget exited with status {return_code}; keeping partial archive",
                file=sys.stderr,
            )

        rewritten_html, rewrite_count = rewrite_html(main_html, final_assets.name)
        temporary_html.write_text(
            rewritten_html,
            encoding="utf-8",
            errors="surrogateescape",
        )
        main_html.unlink()

        work_dir.replace(final_assets)
        temporary_html.replace(final_html)
        asset_count = sum(1 for path in final_assets.iterdir() if path.is_file())
        print(
            f"Saved {final_html} with {asset_count} assets; "
            f"rewrote {rewrite_count} HTML references",
            file=sys.stderr,
        )
        return final_html, final_assets
    except Exception:
        if temporary_html.exists():
            temporary_html.unlink()
        if work_dir.exists():
            shutil.rmtree(work_dir)
        raise


def main() -> int:
    args = parse_arguments()
    try:
        name, output_dir = validate_arguments(args)
        create_archive(args, name, output_dir)
    except (DownloadError, OSError) as error:
        print(f"Error: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
