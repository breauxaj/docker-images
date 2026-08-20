#!/usr/bin/env python3
"""Print image names whose files changed compared to a git base ref.

If shared repo files changed, print every image. With --json, print a JSON array.
"""

from __future__ import annotations

import argparse
import json
import subprocess
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SHARED_PREFIXES = (
    "docker-bake.hcl",
    "Makefile",
    "scripts/",
    ".github/workflows/",
    ".hadolint.yaml",
)


def git(*args: str) -> str:
    return subprocess.check_output(["git", *args], cwd=REPO_ROOT, text=True).strip()


def git_ok(*args: str) -> bool:
    return (
        subprocess.call(
            ["git", *args],
            cwd=REPO_ROOT,
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
        )
        == 0
    )


def all_images() -> list[str]:
    images_dir = REPO_ROOT / "images"
    if not images_dir.is_dir():
        return []
    return [path.parent.name for path in sorted(images_dir.glob("*/Dockerfile"))]


def resolve_base_ref(explicit: str | None) -> str | None:
    if explicit:
        if explicit.startswith("0" * 8) or not git_ok("rev-parse", "--verify", "--quiet", explicit):
            return None
        return explicit
    for candidate in ("origin/develop", "origin/main", "HEAD^1"):
        if git_ok("rev-parse", "--verify", "--quiet", candidate):
            return candidate
    return None


def emit(images: list[str], as_json: bool) -> None:
    if as_json:
        json.dump(images, sys.stdout, separators=(",", ":"))
        sys.stdout.write("\n")
        return
    for name in images:
        print(name)


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--json", action="store_true", help="print a JSON array")
    parser.add_argument("base_ref", nargs="?", help="git ref to compare against")
    args = parser.parse_args()

    images = all_images()
    base_ref = resolve_base_ref(args.base_ref)
    if not images or base_ref is None:
        emit(images, args.json)
        return 0

    merge_base = subprocess.run(
        ["git", "merge-base", base_ref, "HEAD"],
        cwd=REPO_ROOT,
        text=True,
        capture_output=True,
        check=False,
    )
    if merge_base.returncode != 0 or not merge_base.stdout.strip():
        emit(images, args.json)
        return 0

    changed = git("diff", "--name-only", merge_base.stdout.strip(), "HEAD").splitlines()
    if not changed:
        emit(images, args.json)
        return 0

    if any(
        path == prefix or path.startswith(prefix)
        for path in changed
        for prefix in SHARED_PREFIXES
    ):
        emit(images, args.json)
        return 0

    selected = set()
    for path in changed:
        parts = Path(path).parts
        if len(parts) >= 2 and parts[0] == "images":
            selected.add(parts[1])

    emit([name for name in images if name in selected], args.json)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
