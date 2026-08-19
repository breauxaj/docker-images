#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <image-name>" >&2
  exit 2
fi

name="$1"
if [[ ! "$name" =~ ^[a-z0-9]+([._-][a-z0-9]+)*$ ]]; then
  echo "image name must be lowercase alphanumeric, with optional . _ - separators: got '$name'" >&2
  exit 1
fi

repo_root="$(cd "$(dirname "$0")/.." && pwd)"
src="$repo_root/templates/image"
dest="$repo_root/images/$name"

if [[ ! -d "$src" ]]; then
  echo "template is missing: $src" >&2
  exit 1
fi

if [[ -e "$dest" ]]; then
  echo "image already exists: $dest" >&2
  exit 1
fi

mkdir -p "$dest"
# Copy files, including dotfiles, without copying the directory itself.
cp -R "$src"/. "$dest"

find "$dest" -type f | while IFS= read -r file; do
  tmp="${file}.tmp"
  sed "s/__IMAGE__/${name}/g" "$file" > "$tmp"
  mv "$tmp" "$file"
done

cat <<EOF
Created images/${name}

Next:
  1. Edit images/${name}/Dockerfile and README.md
  2. Add a docker Dependabot entry for /images/${name} in .github/dependabot.yml
  3. Build with: make build IMAGE=${name}
EOF
