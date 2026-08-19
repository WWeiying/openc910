#!/usr/bin/env python3
"""Extract a downloaded Chips and Cheese/Substack article for local editing."""

from __future__ import annotations

import argparse
import html
import json
import re
import shutil
from pathlib import Path
from urllib.parse import unquote

from bs4 import BeautifulSoup


def meta_content(soup: BeautifulSoup, key: str, attribute: str) -> str:
    node = soup.select_one(f'meta[{attribute}="{key}"]')
    return html.unescape(node.get("content", "")) if node else ""


def resolve_local_image(html_path: Path, source: str) -> Path:
    raw = source.split("?", 1)[0].split("#", 1)[0]
    candidates = []
    current = raw
    for _ in range(3):
        candidates.append(html_path.parent / current.removeprefix("./"))
        decoded = unquote(current)
        if decoded == current:
            break
        current = decoded
    for candidate in candidates:
        if candidate.is_file():
            return candidate
    raise FileNotFoundError(f"cannot resolve image: {source}")


def image_extension(path: Path) -> str:
    header = path.read_bytes()[:16]
    if header.startswith(b"\x89PNG\r\n\x1a\n"):
        return ".png"
    if header.startswith(b"\xff\xd8\xff"):
        return ".jpg"
    if header.startswith((b"GIF87a", b"GIF89a")):
        return ".gif"
    if header.startswith(b"RIFF") and header[8:12] == b"WEBP":
        return ".webp"
    raise ValueError(f"unsupported image encoding: {path}")


def clean_text(node) -> str:
    return re.sub(r"\s+", " ", node.get_text(" ", strip=True)).strip()


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("html", type=Path)
    parser.add_argument("--copy-images", type=Path)
    parser.add_argument("--json", action="store_true")
    args = parser.parse_args()

    source = args.html.read_text(encoding="utf-8", errors="replace")
    soup = BeautifulSoup(source, "html.parser")
    body = soup.select_one(".body.markup") or soup.find("article")
    if body is None:
        raise RuntimeError("article body not found")

    date_match = re.search(r'"datePublished"\s*:\s*"([^"]+)', source)
    metadata = {
        "title": meta_content(soup, "og:title", "property"),
        "author": meta_content(soup, "author", "name"),
        "url": meta_content(soup, "og:url", "property"),
        "date": date_match.group(1)[:10] if date_match else "",
    }

    if args.copy_images:
        args.copy_images.mkdir(parents=True, exist_ok=True)

    records = []
    figure_number = 0
    for child in body.children:
        if not getattr(child, "name", None):
            continue
        if child.name in {"h1", "h2", "h3", "h4"}:
            text = clean_text(child)
            if text:
                records.append({"type": child.name.upper(), "text": text})
            continue
        if child.name == "p":
            text = clean_text(child)
            if text:
                records.append({"type": "P", "text": text})
            continue
        if child.name in {"ul", "ol"}:
            items = [clean_text(item) for item in child.find_all("li", recursive=False)]
            records.append({"type": child.name.upper(), "items": [x for x in items if x]})
            continue
        if child.name == "blockquote":
            text = clean_text(child)
            if text:
                records.append({"type": "QUOTE", "text": text})
            continue

        figure = child if child.name == "figure" else child.find("figure")
        if figure is None:
            continue
        image = figure.find("img")
        if image is None:
            continue
        figure_number += 1
        image_source = image.get("src", "")
        local_source = resolve_local_image(args.html, image_source)
        extension = image_extension(local_source)
        output_name = f"{figure_number:02d}_figure{extension}"
        if args.copy_images:
            shutil.copy2(local_source, args.copy_images / output_name)
        caption_node = figure.find("figcaption") or child.select_one(".image-caption")
        records.append(
            {
                "type": "FIG",
                "number": figure_number,
                "file": output_name,
                "source": str(local_source),
                "alt": image.get("alt", ""),
                "caption": clean_text(caption_node) if caption_node else "",
            }
        )

    result = {"metadata": metadata, "records": records}
    if args.json:
        print(json.dumps(result, ensure_ascii=False, indent=2))
        return

    print("META " + json.dumps(metadata, ensure_ascii=False))
    for index, record in enumerate(records, 1):
        kind = record["type"]
        if kind == "FIG":
            print(
                f"[{index:03d}] FIG {record['number']:02d} {record['file']}"
                f" | CAP {record['caption']} | ALT {record['alt']}"
            )
        elif kind in {"UL", "OL"}:
            print(f"[{index:03d}] {kind} " + " | ".join(record["items"]))
        else:
            print(f"[{index:03d}] {kind} {record['text']}")


if __name__ == "__main__":
    main()
