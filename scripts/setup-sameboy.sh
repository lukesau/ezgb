#!/usr/bin/env bash
# Clone upstream SameBoy at the pinned commit and apply ezgb's local patches.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PATCH_DIR="$ROOT/patches/sameboy"
DEST="${SAMEBOY_DIR:-$ROOT/tools/SameBoy}"
REMOTE="${SAMEBOY_REMOTE:-https://github.com/LIJI32/SameBoy.git}"
BASE_COMMIT="$(tr -d '[:space:]' < "$PATCH_DIR/BASE_COMMIT")"

if [[ ! -f "$PATCH_DIR/BASE_COMMIT" ]]; then
  echo "error: missing $PATCH_DIR/BASE_COMMIT" >&2
  exit 1
fi

if [[ -d "$DEST/.git" ]]; then
  echo "Updating existing clone at $DEST"
  git -C "$DEST" fetch origin
  git -C "$DEST" checkout --force "$BASE_COMMIT"
  git -C "$DEST" reset --hard "$BASE_COMMIT"
  git -C "$DEST" clean -fd
else
  echo "Cloning SameBoy into $DEST"
  mkdir -p "$(dirname "$DEST")"
  git clone "$REMOTE" "$DEST"
  git -C "$DEST" checkout --force "$BASE_COMMIT"
fi

shopt -s nullglob
patches=("$PATCH_DIR"/*.patch)
if ((${#patches[@]} == 0)); then
  echo "warning: no patches in $PATCH_DIR" >&2
else
  echo "Applying ${#patches[@]} patch(es)"
  for patch in "${patches[@]}"; do
    echo "  $(basename "$patch")"
    git -C "$DEST" apply --index --whitespace=nowarn "$patch"
  done
  # Leave working tree matching index; don't commit (tools/ is not part of ezgb history)
  git -C "$DEST" reset HEAD >/dev/null
fi

echo "SameBoy ready at $DEST (base $BASE_COMMIT)"
echo "Build: cd \"$DEST\" && make CONF=debug sdl"
echo "Run:   \"$DEST/build/bin/SDL/sameboy\" \"$ROOT/re/1.05e/kernel.gb\""
