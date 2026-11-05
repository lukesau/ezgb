#!/usr/bin/env bash
# Publish the floorplan viewer to GitHub Pages: https://lukesau.github.io/ezgb/floorplan/
#
# Commits fpga/floorplan/floorplan.html (scripts/fpga/floorplan.py builds it) as
# floorplan/index.html on the gh-pages branch and pushes it. The patcher page
# and the site root redirect stay as they are.
#
#   scripts/publish-floorplan.sh [--no-push]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PAGE="$ROOT/fpga/floorplan/floorplan.html"
push=1
[ "${1:-}" = "--no-push" ] && push=0
[ -f "$PAGE" ] || { echo "no $PAGE, run scripts/fpga/floorplan.py" >&2; exit 1; }

WT="$(mktemp -d /tmp/ezgb-gh-pages.XXXXXX)"
trap 'git -C "$ROOT" worktree remove --force "$WT" 2>/dev/null || true; rm -rf "$WT"' EXIT

git -C "$ROOT" fetch -q origin gh-pages
git -C "$ROOT" worktree add -q "$WT" gh-pages
git -C "$WT" merge -q --ff-only origin/gh-pages

mkdir -p "$WT/floorplan"
cp "$PAGE" "$WT/floorplan/index.html"
git -C "$WT" add -A
if git -C "$WT" diff --cached --quiet; then
  echo "gh-pages already up to date"
else
  rev="$(git -C "$ROOT" rev-parse --short HEAD)"
  git -C "$WT" -c user.name="Luke Esau" -c user.email=lukesau@gmail.com commit -q -m "floorplan page from $rev"
  echo "committed gh-pages: $(git -C "$WT" log --oneline -1)"
fi
if [ "$push" = 1 ]; then
  git -C "$WT" push -q origin gh-pages
  echo "pushed gh-pages: https://lukesau.github.io/ezgb/floorplan/"
fi
