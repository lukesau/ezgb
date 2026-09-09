#!/usr/bin/env bash
# Build sd/card.img: a deterministic FAT16 card from sd/root/, using mtools.
#
# mtools writes the FAT directly (no hdiutil mount, so macOS never injects
# .fseventsd / ._* / the ._. root sidecar whose 8.3 alias showed up as a stray
# "~1"). It also lets us choose the on-card directory-entry ORDER exactly: the
# stock Jr browser lists entries in raw FAT order, while the mod sorts them, so a
# deliberate order makes the stock-vs-mod difference obvious (see the showcase
# banner, scripts/make-showcase-banner.sh, and docs/browser-sort.md).
#
# Order comes from sd/ORDER (one top-level name per line, '#' comments); any
# entries in sd/root/ not listed there are appended in sorted order. The kernel
# from re/<EZGB_KERNEL_VERSION>/kernel.gb is written last as ezgb.dat (both
# browsers hide it). Override the size with SD_IMAGE_MB=128 etc.
set -euo pipefail
export MTOOLS_SKIP_CHECK=1

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SD="$ROOT/sd"
IMG="$SD/card.img"
ROOTFS="$SD/root"
ORDER="$SD/ORDER"
MB="${SD_IMAGE_MB:-64}"
KVER="${EZGB_KERNEL_VERSION:-1.05e-0731}"
KERNEL="$ROOT/re/$KVER/kernel.gb"

command -v mformat >/dev/null || { echo "error: mtools not found (brew install mtools)" >&2; exit 1; }
[ -d "$ROOTFS" ] || { echo "error: no $ROOTFS (create it or dump your card there)" >&2; exit 1; }

echo "Creating ${MB}MiB FAT16 image at $IMG"
rm -f "$IMG"
dd if=/dev/zero of="$IMG" bs=1m count="$MB" status=none
mformat -i "$IMG" -F -v EZJR ::

DONE=$'\n'
copy_entry() {
  local name="$1" src="$ROOTFS/$1"
  case "$DONE" in *$'\n'"$name"$'\n'*) return 0;; esac   # already copied
  DONE="${DONE}${name}"$'\n'
  if [ ! -e "$src" ]; then echo "  skip (missing): $name"; return 0; fi
  if [ -d "$src" ]; then mcopy -s -i "$IMG" "$src" ::/ ; else mcopy -i "$IMG" "$src" ::/ ; fi
  echo "  + $name"
}

# 1) entries named in sd/ORDER, in that order
if [ -f "$ORDER" ]; then
  while IFS= read -r line; do
    line="${line%%#*}"; line="${line%"${line##*[![:space:]]}"}"   # strip comment + trailing ws
    [ -z "$line" ] && continue
    copy_entry "$line"
  done < "$ORDER"
fi
# 2) anything else in sd/root/, sorted (dotfiles included)
while IFS= read -r name; do
  [ -z "$name" ] && continue
  copy_entry "$name"
done < <(cd "$ROOTFS" && ls -1A | LC_ALL=C sort)

# 3) the kernel, written last (hidden by both browsers, present for real hardware)
if [ -f "$KERNEL" ]; then
  mcopy -i "$IMG" "$KERNEL" ::/ezgb.dat && echo "  + ezgb.dat ($KVER)"
else
  echo "warning: no $KERNEL; card has no kernel" >&2
fi

echo "Done. Root entry order:"
mdir -i "$IMG" ::/ | sed 's/^/  /'
