#!/usr/bin/env bash
# Attach sd/card.img so you can add/remove ROMs in Finder.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
IMG="${SAMEBOY_EZFLASH_JR_IMG:-$ROOT/sd/card.img}"

if [[ ! -f "$IMG" ]]; then
  echo "error: $IMG not found. Run ./scripts/make-sd-image.sh first, or dump your card there." >&2
  exit 1
fi

echo "Attaching $IMG"
hdiutil attach -imagekey diskimage-class=CRawDiskImage "$IMG"
echo "Eject the volume from Finder (or diskutil eject) when finished."
