#!/usr/bin/env bash
# Build sd/card.img as a FAT16 volume and optionally copy sd/root/ into it.
#
# On modern macOS, newfs_msdos cannot format a plain file ("Cannot get partition
# offset"). We attach it as a raw disk image first and format the /dev/disk* node.
#
# While the image is mounted, macOS injects .fseventsd / Spotlight junk — strip
# that before detaching. Prefer 8.3 names in sd/root/ (e.g. TETRIS.GB, PKMRED.GB);
# VFAT long names often render as garbage in the Jr file browser.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SD="$ROOT/sd"
IMG="$SD/card.img"
ROOTFS="$SD/root"
# Default 64MiB — plenty for a handful of ROMs; override with SD_IMAGE_MB=128 etc.
MB="${SD_IMAGE_MB:-64}"

mkdir -p "$SD"

echo "Creating ${MB}MiB FAT16 image at $IMG"
rm -f "$IMG"
dd if=/dev/zero of="$IMG" bs=1m count="$MB" status=none

DEV="$(hdiutil attach -imagekey diskimage-class=CRawDiskImage -nomount "$IMG" | awk 'NR==1 { print $1 }')"
if [[ -z "$DEV" || ! -e "$DEV" ]]; then
  echo "error: failed to attach $IMG for formatting" >&2
  exit 1
fi
echo "Formatting $DEV as FAT16 (EZJR)"
# Superfloppy (no partition table) — FatFs mounts this; Jr cards are often similar.
newfs_msdos -F 16 -v EZJR "$DEV" >/dev/null
hdiutil detach "$DEV" >/dev/null

scrub_macos_junk() {
  local mnt="$1"
  rm -rf "$mnt/.fseventsd" "$mnt/.Spotlight-V100" "$mnt/.Trashes" \
         "$mnt/.TemporaryItems" "$mnt/.DocumentRevisions-V100" \
         "$mnt/.DS_Store" "$mnt/.metadata_never_index" 2>/dev/null || true
  find "$mnt" \( -name '.DS_Store' -o -name '._*' -o -name '.fseventsd' \
              -o -name '.metadata_never_index' \) -exec rm -rf {} + 2>/dev/null || true
}

if [[ -d "$ROOTFS" ]] && [[ -n "$(ls -A "$ROOTFS" 2>/dev/null || true)" ]]; then
  MNT="$(mktemp -d /tmp/ezjr-sd.XXXXXX)"
  cleanup() {
    hdiutil detach "$MNT" -quiet 2>/dev/null || true
    rmdir "$MNT" 2>/dev/null || true
  }
  trap cleanup EXIT
  echo "Copying $ROOTFS -> image"
  export COPYFILE_DISABLE=1
  hdiutil attach -imagekey diskimage-class=CRawDiskImage -mountpoint "$MNT" "$IMG" >/dev/null
  scrub_macos_junk "$MNT"
  rsync -a --exclude '.DS_Store' --exclude '._*' --exclude '.Spotlight-V100' \
        --exclude '.fseventsd' --exclude '.Trashes' --exclude '.metadata_never_index' \
        "$ROOTFS"/ "$MNT"/
  scrub_macos_junk "$MNT"
  # Warn about non-8.3 names (spaces / long names → VFAT LFN → often broken in Jr UI)
  while IFS= read -r -d '' f; do
    base="$(basename "$f")"
    [[ "$base" == .* ]] && continue
    if [[ "$base" == *' '* || ${#base} -gt 12 ]]; then
      echo "warning: non-8.3 name '$base' — Jr browser may show garbage; rename e.g. PKMRED.GB" >&2
    fi
  done < <(find "$MNT" -mindepth 1 -maxdepth 2 \( -type f -o -type d \) -print0)
  sync
  scrub_macos_junk "$MNT"
  # Last chance: macOS often recreates .fseventsd on detach; remount read-write scrub is hard,
  # so clear whatever is there now and sync hard before eject.
  sync
  hdiutil detach "$MNT" >/dev/null
  trap - EXIT
  rmdir "$MNT" 2>/dev/null || true
  echo "Done. Image has contents of sd/root/."
else
  echo "No sd/root/ contents found; left an empty FAT volume."
  echo "Mount with ./scripts/mount-sd-image.sh and add ROMs, or populate sd/root/ and re-run."
fi

ls -lh "$IMG"
file "$IMG"
