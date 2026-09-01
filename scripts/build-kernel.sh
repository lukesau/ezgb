#!/usr/bin/env bash
# Build the modded kernel from the committed disassembly - no firmware
# download needed, since re/<ver>/disassembly reassembles the full ROM.
#
# Two fixups make the rgbds output byte-identical to the canonical patched
# kernel (the one inject.py produces from a real dump):
#   - rgbfix pads the 160KB (10-bank) ROM to 256KB; truncate it back.
#   - rgbfix "corrects" 4 header bytes the real firmware leaves alone:
#     $0148 (ROM size), $014D (header checksum over the changed $0148), and
#     $014E-$014F (global checksum, stale in the shipped firmware). Restore
#     them from kernel.gb.orig when present, else from the built-in table.
#
# Writes re/<ver>/disassembly/game_trunc.gb and verifies its md5 against
# patches/kernel/manifest.json. --install copies it to re/<ver>/kernel.gb
# (the path build-ezgb-dat.sh and the SameBoy scripts read).
#
# Usage:
#   scripts/build-kernel.sh                # 1.05e-0731
#   scripts/build-kernel.sh 1.05e-0918 --install
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER="1.05e-0731"
INSTALL=0
for arg in "$@"; do
  case "$arg" in
    --install) INSTALL=1 ;;
    -*) echo "error: unknown option $arg" >&2; exit 2 ;;
    *)  VER="$arg" ;;
  esac
done

RE="$ROOT/re/$VER"
if [[ ! -d "$RE/disassembly" ]]; then
  echo "error: no disassembly at $RE/disassembly" >&2
  exit 1
fi

make -C "$RE/disassembly" >/dev/null
python3 - "$VER" "$RE" "$ROOT" <<'PY'
import hashlib, json, os, sys
ver, re_dir, root = sys.argv[1], sys.argv[2], sys.argv[3]

SIZE = 163840
# version -> shipped values of the 4 bytes rgbfix rewrites
HEADER = {
    "1.05e-0731": {0x148: 0x00, 0x14D: 0xBD, 0x14E: 0x7B, 0x14F: 0x57},
    "1.05e-0918": {0x148: 0x00, 0x14D: 0xBD, 0x14E: 0xF8, 0x14F: 0xB5},
}

rom = bytearray(open(os.path.join(re_dir, "disassembly", "game.gb"), "rb").read()[:SIZE])
orig_path = os.path.join(re_dir, "kernel.gb.orig")
if os.path.isfile(orig_path):
    orig = open(orig_path, "rb").read()
    for i in (0x148, 0x14D, 0x14E, 0x14F):
        rom[i] = orig[i]
elif ver in HEADER:
    for i, b in HEADER[ver].items():
        rom[i] = b
else:
    print(f"warning: no kernel.gb.orig and no header table for {ver}; "
          "leaving rgbfix header bytes (cosmetic only)", file=sys.stderr)

out = os.path.join(re_dir, "disassembly", "game_trunc.gb")
open(out, "wb").write(rom)
got = hashlib.md5(rom).hexdigest()
print(f"built {os.path.relpath(out, root)}")
print(f"  {len(rom)} bytes, md5 {got}")

manifest_path = os.path.join(root, "patches", "kernel", "manifest.json")
if os.path.isfile(manifest_path):
    entry = json.load(open(manifest_path)).get(ver)
    if entry:
        if got == entry["patched_md5"]:
            print("  matches manifest patched_md5 - canonical build")
        else:
            print(f"  differs from manifest patched_md5 {entry['patched_md5']} - "
                  "either the disassembly has newer changes than the patch, or "
                  "the build is broken; if intended, rerun kernel-patch.py make",
                  file=sys.stderr)
PY

if [[ "$INSTALL" -eq 1 ]]; then
  SRC="$RE/disassembly/game_trunc.gb"
  DEST="$RE/kernel.gb"
  if [[ -f "$DEST" ]]; then
    echo "replacing existing $DEST (md5 $(md5 -q "$DEST" 2>/dev/null || md5sum "$DEST" | cut -d' ' -f1))"
  fi
  cp "$SRC" "$DEST"
  echo "installed -> $DEST"
fi
