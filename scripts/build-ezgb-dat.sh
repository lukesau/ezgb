#!/usr/bin/env bash
# Stage the patched kernel as ezgb.dat, the name the Jr's bootstrap loads.
#
# It is a byte-for-byte copy of re/<ver>/kernel.gb — no rewriting. The kernel
# is patched in place by decomp/tools/inject*.py, so kernel.gb is already the
# authoritative artifact and this only gives it the name the cart expects.
#
# Output lands in sd/root/, so scripts/make-sd-image.sh picks it up and the
# emulator card mirrors a real one. The browser never lists it: DirList
# memcmps each entry against "ezgb.dat" and skips the match.
#
# Usage:
#   scripts/build-ezgb-dat.sh              # 1.05e
#   scripts/build-ezgb-dat.sh 1.05e
#   scripts/build-ezgb-dat.sh 1.05e --fix-checksum
#
# --fix-checksum rewrites the global checksum at $014E-$014F. Off by default:
# patching the ROM invalidates it, but neither the Game Boy boot ROM nor the
# Jr's bootstrap verifies it in practice (a patched kernel boots on real
# hardware), and silently altering header bytes would hide that fact.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER="1.05e"
FIX=0
for arg in "$@"; do
  case "$arg" in
    --fix-checksum) FIX=1 ;;
    -*) echo "error: unknown option $arg" >&2; exit 2 ;;
    *)  VER="$arg" ;;
  esac
done

SRC="$ROOT/re/$VER/kernel.gb"
DEST="$ROOT/sd/root/ezgb.dat"

if [[ ! -f "$SRC" ]]; then
  echo "error: missing $SRC" >&2
  echo "       kernel.gb is not tracked (EZ Flash firmware); drop your own dump there." >&2
  exit 1
fi

mkdir -p "$(dirname "$DEST")"
cp "$SRC" "$DEST"
[[ "$FIX" -eq 1 ]] && python3 - "$DEST" <<'PY'
import sys
p = sys.argv[1]
d = bytearray(open(p, 'rb').read())
total = (sum(d) - d[0x14e] - d[0x14f]) & 0xFFFF
d[0x14e], d[0x14f] = total >> 8, total & 0xFF
open(p, 'wb').write(bytes(d))
print("  rewrote global checksum -> $%04X" % total)
PY

python3 - "$SRC" "$DEST" <<'PY'
import sys, hashlib
src, dest = sys.argv[1], sys.argv[2]
a, b = open(src, 'rb').read(), open(dest, 'rb').read()
print("  %d bytes, md5 %s%s" % (len(b), hashlib.md5(b).hexdigest(),
                                "" if a == b else "  (checksum-fixed, differs from kernel.gb)"))
hdr = 0
for x in b[0x134:0x14d]:
    hdr = (hdr - x - 1) & 0xFF
glob = (sum(b) - b[0x14e] - b[0x14f]) & 0xFFFF
stored = (b[0x14e] << 8) | b[0x14f]
print("  header checksum $%02X %s" % (b[0x14d], "ok" if hdr == b[0x14d] else "BAD"))
if stored != glob:
    print("  global checksum $%04X, computed $%04X — stale after patching." % (stored, glob))
    print("  Not verified by the boot ROM or the Jr bootstrap; --fix-checksum to rewrite.")
else:
    print("  global checksum $%04X ok" % stored)
PY

echo "Wrote $DEST"
