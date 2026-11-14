#!/usr/bin/env bash
# Pack a 12px glyph sheet and (re)place its two tables in
# kernel/<version>/kernel.gb: the glyph bitmaps and the advances / ink
# widths / kerning matrix. Re-run after editing a sheet or the packer's
# spacing options. The glyph sets live in bank 10 beside the 12px engine
# (draw12.c, layout12.c; docs/font12.md):
#
#   set 0  kernel/mod/font12/font12.txt     Font12 0A:4C00, Font12Metrics 0A:5580
#   set 1  kernel/mod/font12/font12_dv.txt  Font12Dv 0A:5D00, Font12DvMetrics 0A:6680
#          (the DV theme's: Tamzen 6x12, fixed width, packed with --mono 6)
#
#   scripts/inject-font12.sh [version] [set] [font12-pack.py options]
#                                             (default 1.05e-0731, set 0)
#
# inject_bytes.py refuses an address that already has a kernel.sym entry, so
# the previous lines are dropped first (same pattern as
# scripts/inject-ezcfg.sh). The bitmaps are a fixed 2424 bytes; the metrics
# table shrinks or grows with the kerning classes (about 17 bytes per right
# class), so the bytes between its end and the next kernel.sym label in the
# bank are blanked to $FF before it is written, leaving nothing stale behind
# it, and a table that would reach that label is refused here:
# inject_bytes.py does not notice a block running into the next label.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
V="${1:-1.05e-0731}"
SET="${2:-0}"
shift 2 2>/dev/null || shift $# || true
SYM="$ROOT/kernel/$V/kernel.sym"
ROM="$ROOT/kernel/$V/kernel.gb"
BANK=0a
case "$SET" in
  0) SHEET=font12.txt; BMP=4c00; MET=5580; NAME=Font12; OPTS=() ;;
  1) SHEET=font12_dv.txt; BMP=5d00; MET=6680; NAME=Font12Dv; OPTS=(--mono 6) ;;
  *) echo "error: no glyph set $SET" >&2; exit 2 ;;
esac
OUT="$ROOT/kernel/mod/font12/${SHEET%.txt}.bin"
OUTM="$ROOT/kernel/mod/font12/${SHEET%.txt}-metrics.bin"
METRICS_END="$(python3 -c 'import sys
b, m = sys.argv[2], int(sys.argv[3], 16)
after = [a for a in (int(l[3:7], 16) for l in open(sys.argv[1]) if l.startswith(b + ":")) if a > m]
print(hex(min(after) if after else 0x8000))' "$SYM" "$BANK" "$MET")"

python3 "$ROOT/scripts/font12-pack.py" -i "$ROOT/kernel/mod/font12/$SHEET" -o "$OUT" -m "$OUTM" ${OPTS[@]+"${OPTS[@]}"} "$@" | head -2
perl -ni -e "print unless /^$BANK:($BMP|$MET) /" "$SYM"
python3 - "$ROM" "$OUTM" "$BANK" "$MET" "$METRICS_END" <<'EOF'
import sys
p, metrics, bank, start, end = sys.argv[1], sys.argv[2], int(sys.argv[3], 16), int(sys.argv[4], 16), int(sys.argv[5], 16)
n = len(open(metrics, "rb").read())
if start + n > end:
    sys.exit(f"error: the metrics are {n} bytes, {bank:02x}:{start:04x} + {n} = ${start + n:04x} reaches the next block at ${end:04x}")
d = bytearray(open(p, "rb").read())
lo, hi = bank * 0x4000 + (start - 0x4000), bank * 0x4000 + (end - 0x4000)
d[lo:hi] = b"\xff" * (hi - lo)
open(p, "wb").write(d)
EOF
cd "$ROOT/kernel/mod"
python3 tools/inject_bytes.py "$V" 10 "$BMP" "$NAME" "$(xxd -p "$OUT" | tr -d '\n')" --apply | tail -1
python3 tools/inject_bytes.py "$V" 10 "$MET" "${NAME}Metrics" "$(xxd -p "$OUTM" | tr -d '\n')" --apply | tail -1
