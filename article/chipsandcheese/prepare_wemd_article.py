#!/usr/bin/env python3
"""Create a WeMD publishing copy without modifying the source article.

The default output adds the configured WeMD theme metadata, removes the first
H1 (the WeChat backend has a separate title field), validates local images,
and writes ``<source-stem>_wemd.md`` next to the source.

Images can be handled in either of two non-interactive modes:

1. ``--image-base-url`` rewrites local image paths after the same relative
   paths have already been uploaded to a public image host.
2. ``--upload-cos`` uploads referenced images to Tencent COS with the official
   Python SDK, then writes the public URLs into the publishing copy.

COS credentials are read only from environment variables so they never need
to appear in the repository or shell history.
"""

from __future__ import annotations

import argparse
import hashlib
import json
import mimetypes
import os
import re
import sys
from dataclasses import dataclass
from pathlib import Path
from typing import Callable
from urllib.parse import quote, unquote, urlsplit


DEFAULT_THEME_ID = "custom-1786280678341-jnfpaqasm"
DEFAULT_THEME_NAME = "学术论文 (副本)"
DEFAULT_COS_PREFIX = "wechat/articles"
DEFAULT_MANIFEST_NAME = ".wemd-cos-manifest.json"
DEFAULT_COS_STORAGE_CLASS = "STANDARD"
SUPPORTED_COS_STORAGE_CLASSES = {
    "STANDARD",
    "STANDARD_IA",
    "MAZ_STANDARD",
    "MAZ_STANDARD_IA",
}

FRONTMATTER_RE = re.compile(
    r"\A(?:\ufeff)?---\r?\n(?P<meta>[\s\S]*?)\r?\n---(?:\r?\n|\Z)"
)
FRONTMATTER_FIELD_RE = re.compile(r"^\s*(theme|themeName|title)\s*:")
FIRST_H1_RE = re.compile(r"^#\s+\S")
FENCE_RE = re.compile(r"^\s*(`{3,}|~{3,})")
IMAGE_RE = re.compile(
    r"!\[(?P<alt>(?:\\.|[^\]])*)\]\("
    r"(?P<target><[^>\n]+>|[^)\s]+)"
    r"(?P<title>\s+(?:\"[^\"\n]*\"|'[^'\n]*'|\([^\)\n]*\)))?"
    r"\)"
)


class PreparationError(RuntimeError):
    """Raised for an invalid article or publishing configuration."""


@dataclass(frozen=True)
class ImageReference:
    source_path: Path
    relative_path: Path


@dataclass
class RewriteStats:
    total_images: int = 0
    local_images: int = 0
    remote_images: int = 0
    rewritten_images: int = 0
    uploaded_images: int = 0
    reused_uploads: int = 0


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="生成带 WeMD 主题信息的公众号发布副本，母稿保持不变。"
    )
    parser.add_argument("source", type=Path, help="公众号 Markdown 母稿")
    parser.add_argument(
        "-o",
        "--output",
        type=Path,
        help="输出路径；默认在母稿旁生成 <stem>_wemd.md",
    )
    parser.add_argument("--theme", default=DEFAULT_THEME_ID, help="WeMD 主题 ID")
    parser.add_argument(
        "--theme-name", default=DEFAULT_THEME_NAME, help="WeMD 主题显示名称"
    )
    parser.add_argument(
        "--title",
        help="WeMD 文件标题；默认使用母稿文件名（不含 .md）",
    )
    parser.add_argument(
        "--keep-first-heading",
        action="store_true",
        help="保留正文开头的一级标题；默认删除以避免与公众号标题重复",
    )
    parser.add_argument(
        "--asset-root",
        type=Path,
        help="本地图片相对路径的根目录；默认是母稿所在目录",
    )

    image_group = parser.add_mutually_exclusive_group()
    image_group.add_argument(
        "--image-base-url",
        help=(
            "把本地图片路径改写到该公开 HTTPS 根地址；"
            "要求图床保留相对于 --asset-root 的目录结构"
        ),
    )
    image_group.add_argument(
        "--upload-cos",
        action="store_true",
        help="使用腾讯云 COS Python SDK 上传引用的本地图片并改写链接",
    )

    parser.add_argument(
        "--cos-bucket",
        default=os.environ.get("WEMD_COS_BUCKET"),
        help="COS Bucket（含 appid）；默认读取 WEMD_COS_BUCKET",
    )
    parser.add_argument(
        "--cos-region",
        default=os.environ.get("WEMD_COS_REGION"),
        help="COS Region；默认读取 WEMD_COS_REGION",
    )
    parser.add_argument(
        "--cos-prefix",
        default=os.environ.get("WEMD_COS_PREFIX", DEFAULT_COS_PREFIX),
        help=f"COS 对象前缀；默认 {DEFAULT_COS_PREFIX}",
    )
    parser.add_argument(
        "--cos-public-base-url",
        default=os.environ.get("WEMD_COS_PUBLIC_BASE_URL"),
        help="公开 COS/CDN 根地址；默认由 Bucket 和 Region 推导",
    )
    parser.add_argument(
        "--cos-storage-class",
        default=os.environ.get(
            "WEMD_COS_STORAGE_CLASS", DEFAULT_COS_STORAGE_CLASS
        ),
        choices=sorted(SUPPORTED_COS_STORAGE_CLASSES),
        help=(
            "COS 对象存储类型；多 AZ 标准存储使用 MAZ_STANDARD，"
            f"默认 {DEFAULT_COS_STORAGE_CLASS}"
        ),
    )
    parser.add_argument(
        "--cos-manifest",
        type=Path,
        help=f"上传缓存清单；默认写在输出目录的 {DEFAULT_MANIFEST_NAME}",
    )
    return parser.parse_args(argv)


def split_frontmatter(content: str) -> tuple[list[str], str]:
    match = FRONTMATTER_RE.match(content)
    if not match:
        return [], content.lstrip("\ufeff")
    metadata_lines = match.group("meta").splitlines()
    body = content[match.end() :].lstrip("\r\n")
    return metadata_lines, body


def build_frontmatter(
    existing_lines: list[str], theme: str, theme_name: str, title: str
) -> str:
    preserved = [
        line for line in existing_lines if not FRONTMATTER_FIELD_RE.match(line)
    ]
    while preserved and not preserved[-1].strip():
        preserved.pop()
    metadata = preserved + [
        f"theme: {theme}",
        f"themeName: {json.dumps(theme_name, ensure_ascii=False)}",
        f"title: {json.dumps(title, ensure_ascii=False)}",
    ]
    return "---\n" + "\n".join(metadata) + "\n---\n\n"


def remove_initial_h1(body: str) -> str:
    lines = body.splitlines(keepends=True)
    for index, line in enumerate(lines):
        if not line.strip():
            continue
        if not FIRST_H1_RE.match(line):
            return body
        del lines[index]
        if index < len(lines) and not lines[index].strip():
            del lines[index]
        return "".join(lines)
    return body


def is_remote_target(target: str) -> bool:
    parsed = urlsplit(target)
    return bool(parsed.scheme) or target.startswith("//") or target.startswith("#")


def unwrap_target(target: str) -> str:
    if target.startswith("<") and target.endswith(">"):
        return target[1:-1]
    return target


def quoted_relative_url(path: Path) -> str:
    return "/".join(quote(part) for part in path.as_posix().split("/"))


def join_public_url(base_url: str, relative: str) -> str:
    return base_url.rstrip("/") + "/" + relative.lstrip("/")


def validate_https_base_url(name: str, value: str) -> str:
    parsed = urlsplit(value)
    if parsed.scheme != "https" or not parsed.netloc:
        raise PreparationError(f"{name} 必须是可公开访问的 HTTPS 根地址: {value}")
    return value.rstrip("/")


def resolve_local_image(
    target: str, source_dir: Path, asset_root: Path
) -> ImageReference:
    decoded = unquote(target)
    local_path = (source_dir / decoded).resolve()
    try:
        relative_path = local_path.relative_to(asset_root)
    except ValueError as error:
        raise PreparationError(
            f"图片超出资源根目录 {asset_root}: {target}"
        ) from error
    if not local_path.is_file():
        raise PreparationError(f"图片不存在: {target} -> {local_path}")
    return ImageReference(local_path, relative_path)


class CosImageUploader:
    def __init__(
        self,
        *,
        bucket: str,
        region: str,
        prefix: str,
        public_base_url: str | None,
        storage_class: str,
        manifest_path: Path,
        article_slug: str,
    ) -> None:
        secret_id = os.environ.get("WEMD_COS_SECRET_ID")
        secret_key = os.environ.get("WEMD_COS_SECRET_KEY")
        token = os.environ.get("WEMD_COS_TOKEN")
        if not secret_id or not secret_key:
            raise PreparationError(
                "--upload-cos 需要环境变量 WEMD_COS_SECRET_ID 和 "
                "WEMD_COS_SECRET_KEY"
            )
        if not bucket or not region:
            raise PreparationError(
                "--upload-cos 需要 --cos-bucket/--cos-region，或对应的 "
                "WEMD_COS_BUCKET/WEMD_COS_REGION 环境变量"
            )
        try:
            from qcloud_cos import CosConfig, CosS3Client  # type: ignore
        except ImportError as error:
            raise PreparationError(
                "缺少腾讯云官方 SDK；请先执行："
                "python3 -m pip install --user -U cos-python-sdk-v5"
            ) from error

        config_arguments = {
            "Region": region,
            "SecretId": secret_id,
            "SecretKey": secret_key,
            "Scheme": "https",
        }
        if token:
            config_arguments["Token"] = token
        config = CosConfig(**config_arguments)
        self.client = CosS3Client(config)
        self.bucket = bucket
        self.region = region
        self.prefix = prefix.strip("/")
        self.storage_class = storage_class
        resolved_public_base_url = (
            public_base_url
            if public_base_url
            else f"https://{bucket}.cos.{region}.myqcloud.com"
        )
        self.public_base_url = validate_https_base_url(
            "COS 公开地址", resolved_public_base_url
        )
        self.manifest_path = manifest_path
        self.article_slug = article_slug
        self.manifest = self._load_manifest()
        self.uploaded = 0
        self.reused = 0

    def _load_manifest(self) -> dict[str, dict[str, object]]:
        if not self.manifest_path.exists():
            return {}
        try:
            parsed = json.loads(self.manifest_path.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError) as error:
            raise PreparationError(
                f"无法读取 COS 上传缓存 {self.manifest_path}: {error}"
            ) from error
        if not isinstance(parsed, dict):
            raise PreparationError(f"COS 上传缓存格式错误: {self.manifest_path}")
        return parsed

    def _save_manifest(self) -> None:
        self.manifest_path.parent.mkdir(parents=True, exist_ok=True)
        temporary = self.manifest_path.with_suffix(
            self.manifest_path.suffix + ".tmp"
        )
        temporary.write_text(
            json.dumps(self.manifest, ensure_ascii=False, indent=2) + "\n",
            encoding="utf-8",
        )
        temporary.replace(self.manifest_path)

    def upload(self, reference: ImageReference) -> str:
        digest = hashlib.sha256(reference.source_path.read_bytes()).hexdigest()
        cache_key = "|".join(
            [
                self.bucket,
                self.region,
                self.public_base_url,
                self.prefix,
                self.storage_class,
                digest,
                reference.source_path.name,
            ]
        )
        cached = self.manifest.get(cache_key)
        if isinstance(cached, dict) and isinstance(cached.get("url"), str):
            self.reused += 1
            return str(cached["url"])

        safe_name = re.sub(r"[^A-Za-z0-9._-]+", "-", reference.source_path.name)
        object_parts = [part for part in [self.prefix, self.article_slug] if part]
        object_parts.append(f"{digest[:16]}_{safe_name}")
        object_key = "/".join(object_parts)
        content_type = mimetypes.guess_type(reference.source_path.name)[0]
        request: dict[str, object] = {
            "Bucket": self.bucket,
            "Key": object_key,
            "Body": reference.source_path.read_bytes(),
            "StorageClass": self.storage_class,
        }
        if content_type:
            request["ContentType"] = content_type
        self.client.put_object(**request)

        url = join_public_url(self.public_base_url, quoted_relative_url(Path(object_key)))
        self.manifest[cache_key] = {
            "url": url,
            "objectKey": object_key,
            "sha256": digest,
            "size": reference.source_path.stat().st_size,
            "storageClass": self.storage_class,
        }
        self._save_manifest()
        self.uploaded += 1
        return url


def rewrite_images(
    body: str,
    *,
    source_dir: Path,
    asset_root: Path,
    image_base_url: str | None,
    upload_image: Callable[[ImageReference], str] | None,
) -> tuple[str, RewriteStats]:
    stats = RewriteStats()
    output_lines: list[str] = []
    active_fence: str | None = None

    for line in body.splitlines(keepends=True):
        fence_match = FENCE_RE.match(line)
        if fence_match:
            marker = fence_match.group(1)[0]
            if active_fence is None:
                active_fence = marker
            elif active_fence == marker:
                active_fence = None
            output_lines.append(line)
            continue
        if active_fence is not None:
            output_lines.append(line)
            continue

        def replace(match: re.Match[str]) -> str:
            stats.total_images += 1
            raw_target = match.group("target")
            target = unwrap_target(raw_target)
            if is_remote_target(target):
                stats.remote_images += 1
                return match.group(0)

            stats.local_images += 1
            reference = resolve_local_image(target, source_dir, asset_root)
            new_target: str | None = None
            if upload_image is not None:
                new_target = upload_image(reference)
            elif image_base_url:
                new_target = join_public_url(
                    image_base_url, quoted_relative_url(reference.relative_path)
                )
            if new_target is None:
                return match.group(0)

            stats.rewritten_images += 1
            title = match.group("title") or ""
            return f"![{match.group('alt')}]({new_target}{title})"

        output_lines.append(IMAGE_RE.sub(replace, line))

    return "".join(output_lines), stats


def prepare_article(args: argparse.Namespace) -> tuple[Path, RewriteStats]:
    source = args.source.expanduser().resolve()
    if not source.is_file():
        raise PreparationError(f"母稿不存在: {source}")
    if source.suffix.lower() != ".md":
        raise PreparationError(f"母稿必须是 Markdown 文件: {source}")

    output = (
        args.output.expanduser().resolve()
        if args.output
        else source.with_name(f"{source.stem}_wemd.md")
    )
    if output == source:
        raise PreparationError("输出路径不能与母稿相同；本脚本不会原地覆盖母稿")

    asset_root = (
        args.asset_root.expanduser().resolve()
        if args.asset_root
        else source.parent.resolve()
    )
    if not asset_root.is_dir():
        raise PreparationError(f"资源根目录不存在: {asset_root}")
    if args.image_base_url:
        args.image_base_url = validate_https_base_url(
            "--image-base-url", args.image_base_url
        )

    content = source.read_text(encoding="utf-8")
    existing_metadata, body = split_frontmatter(content)
    if not args.keep_first_heading:
        body = remove_initial_h1(body)

    uploader: CosImageUploader | None = None
    if args.upload_cos:
        manifest_path = (
            args.cos_manifest.expanduser().resolve()
            if args.cos_manifest
            else output.parent / DEFAULT_MANIFEST_NAME
        )
        uploader = CosImageUploader(
            bucket=args.cos_bucket,
            region=args.cos_region,
            prefix=args.cos_prefix,
            public_base_url=args.cos_public_base_url,
            storage_class=args.cos_storage_class,
            manifest_path=manifest_path,
            article_slug=source.stem,
        )

    body, stats = rewrite_images(
        body,
        source_dir=source.parent,
        asset_root=asset_root,
        image_base_url=args.image_base_url,
        upload_image=uploader.upload if uploader else None,
    )
    if uploader:
        stats.uploaded_images = uploader.uploaded
        stats.reused_uploads = uploader.reused

    title = args.title or source.stem
    frontmatter = build_frontmatter(
        existing_metadata, args.theme, args.theme_name, title
    )
    final_content = frontmatter + body.rstrip() + "\n"
    output.parent.mkdir(parents=True, exist_ok=True)
    temporary = output.with_suffix(output.suffix + ".tmp")
    temporary.write_text(final_content, encoding="utf-8")
    temporary.replace(output)
    return output, stats


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    try:
        output, stats = prepare_article(args)
    except (OSError, PreparationError) as error:
        print(f"错误：{error}", file=sys.stderr)
        return 1

    print(f"已生成 WeMD 发布副本：{output}")
    print(
        "图片："
        f"共 {stats.total_images}，本地 {stats.local_images}，"
        f"原远程 {stats.remote_images}，已改写 {stats.rewritten_images}"
    )
    if args.upload_cos:
        print(
            f"COS：新上传 {stats.uploaded_images}，"
            f"复用缓存 {stats.reused_uploads}"
        )
    elif stats.local_images and not args.image_base_url:
        print(
            "提示：本次保留了本地图片路径；正式粘贴公众号前，请使用 "
            "--upload-cos 或 --image-base-url 重新生成。"
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
