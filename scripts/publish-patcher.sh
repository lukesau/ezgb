#!/usr/bin/env bash
# Publish the patcher page to GitHub Pages: https://lukesau.github.io/ezgb/patcher/
#
# Builds dist/patcher/index.html (scripts/make-patcher-page.py, any arguments
# such as --hold fw4 are passed through) and commits it as patcher/index.html
# on the gh-pages branch, which holds nothing but the page, a redirect from the
# site root and .nojekyll. Then pushes gh-pages; Pages serves that branch.
#
#   scripts/publish-patcher.sh [--hold fw4] [--no-push]
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
push=1
args=()
for a in "$@"; do
  if [ "$a" = "--no-push" ]; then push=0; else args+=("$a"); fi
done

python3 "$ROOT/scripts/make-patcher-page.py" "${args[@]+"${args[@]}"}"
WT="$(mktemp -d /tmp/ezgb-gh-pages.XXXXXX)"
trap 'git -C "$ROOT" worktree remove --force "$WT" 2>/dev/null || true; rm -rf "$WT"' EXIT

git -C "$ROOT" fetch -q origin gh-pages 2>/dev/null || true
if git -C "$ROOT" rev-parse -q --verify gh-pages >/dev/null; then
  git -C "$ROOT" worktree add -q "$WT" gh-pages
elif git -C "$ROOT" rev-parse -q --verify origin/gh-pages >/dev/null; then
  git -C "$ROOT" worktree add -q -b gh-pages "$WT" origin/gh-pages
else
  git -C "$ROOT" worktree add -q --detach "$WT"
  git -C "$WT" checkout -q --orphan gh-pages
  git -C "$WT" rm -rq --cached . && git -C "$WT" clean -fdxq
fi

mkdir -p "$WT/patcher"
cp "$ROOT/dist/patcher/index.html" "$WT/patcher/index.html"
touch "$WT/.nojekyll"
cat > "$WT/index.html" <<'HTML'
<!doctype html>
<meta charset="utf-8">
<title>EZ Flash Jr Patcher</title>
<meta http-equiv="refresh" content="0; url=patcher/">
<a href="patcher/">EZ Flash Jr Patcher</a>
HTML

git -C "$WT" add -A
if git -C "$WT" diff --cached --quiet; then
  echo "gh-pages already up to date"
else
  rev="$(git -C "$ROOT" rev-parse --short HEAD)"
  git -C "$WT" -c user.name="Luke Esau" -c user.email=lukesau@gmail.com commit -q -m "patcher page from $rev"
  echo "committed gh-pages: $(git -C "$WT" log --oneline -1)"
fi
if [ "$push" = 1 ]; then
  git -C "$WT" push -q origin gh-pages
  echo "pushed gh-pages: https://lukesau.github.io/ezgb/patcher/"
fi
