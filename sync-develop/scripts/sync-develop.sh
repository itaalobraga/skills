#!/usr/bin/env bash
set -euo pipefail

if [ $# -ne 1 ]; then
  echo "usage: sync-develop.sh /absolute/path/to/repo" >&2
  exit 2
fi

repo=$1
cd "$repo"

git rev-parse --is-inside-work-tree >/dev/null 2>&1 || {
  echo "not a git repo: $repo" >&2
  exit 1
}

if [ -n "$(git status --porcelain)" ]; then
  echo "dirty working tree: $repo" >&2
  git status -sb
  exit 1
fi

current=$(git branch --show-current)
if [ -z "$current" ]; then
  echo "detached HEAD: $repo" >&2
  exit 1
fi

if git show-ref --verify --quiet refs/heads/develop; then
  base=develop
elif git show-ref --verify --quiet refs/heads/main; then
  base=main
else
  echo "no develop or main branch: $repo" >&2
  exit 1
fi

if [ "$current" = "$base" ]; then
  git pull
  echo "$repo: already on $base ($(git rev-parse --short HEAD)); pulled"
  exit 0
fi

git checkout "$base"
git pull

case "$current" in
  main|master|develop)
    echo "$repo: $base ($(git rev-parse --short HEAD)); left local $current"
    exit 0
    ;;
esac

git branch -d "$current"
echo "$repo: $base ($(git rev-parse --short HEAD)); deleted local $current"
