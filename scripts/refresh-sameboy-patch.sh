#!/usr/bin/env bash
# Regenerate patches/sameboy/0001-ezflash-jr-stub.patch from tools/SameBoy.
# Expects the clone to be checked out at BASE_COMMIT with the stub as
# uncommitted local changes (the state left by setup-sameboy.sh).
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PATCH_DIR="$ROOT/patches/sameboy"
DEST="${SAMEBOY_DIR:-$ROOT/tools/SameBoy}"
OUT="$PATCH_DIR/0001-ezflash-jr-stub.patch"
BASE_COMMIT="$(tr -d '[:space:]' < "$PATCH_DIR/BASE_COMMIT")"

if [[ ! -d "$DEST/.git" ]]; then
  echo "error: $DEST is not a git clone; run scripts/setup-sameboy.sh first" >&2
  exit 1
fi

actual="$(git -C "$DEST" rev-parse HEAD)"
if [[ "$actual" != "$BASE_COMMIT" ]]; then
  echo "error: $DEST is at $actual, expected BASE_COMMIT $BASE_COMMIT" >&2
  echo "       run: git -C \"$DEST\" checkout --force $BASE_COMMIT" >&2
  echo "       then re-apply your stub edits (or scripts/setup-sameboy.sh)" >&2
  exit 1
fi

git -C "$DEST" add \
  Core/ezflash_jr.c \
  Core/ezflash_jr.h \
  Core/gb.c \
  Core/gb.h \
  Core/mbc.c \
  Core/memory.c \
  Makefile

git -C "$DEST" diff --cached > "$OUT"
git -C "$DEST" reset HEAD >/dev/null

lines="$(wc -l < "$OUT" | tr -d ' ')"
if [[ "$lines" -eq 0 ]]; then
  echo "error: empty patch (no stub changes staged vs HEAD)" >&2
  exit 1
fi

echo "Wrote $OUT ($lines lines) against $BASE_COMMIT"
