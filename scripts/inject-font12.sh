#!/usr/bin/env bash
# Pack kernel/font12/font12.txt and (re)place the two 12px font tables in
# re/kernel/<version>/kernel.gb: the glyph bitmaps (Font12, 02:6000) and the
# advances / ink widths / kerning matrix (Font12Metrics, 02:6978). Re-run
# after editing the glyph sheet or the packer's spacing options.
#
#   scripts/inject-font12.sh [version] [font12-pack.py options]
#                                             (default 1.05e-0731)
#
# inject_bytes.py refuses an address that already has a kernel.sym entry, so
# the previous lines are dropped first (same pattern as
# scripts/inject-ezcfg.sh). The bitmaps are a fixed 2424 bytes; the metrics
# table shrinks or grows with the kerning classes (about 17 bytes per right
# class), so the bytes between its end and the next kernel.sym label after
# 02:6978 (FillRect at 02:6f40 since the theme work; Fit12 at 02:7100 before
# it) are blanked to $FF before it is written, leaving nothing stale behind
# it, and a table that would reach that label is refused here:
# inject_bytes.py does not notice a block running into the next label.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
V="${1:-1.05e-0731}"
shift || true
SYM="$ROOT/re/kernel/$V/kernel.sym"
ROM="$ROOT/re/kernel/$V/kernel.gb"
METRICS_END="$(python3 -c 'import sys; print(hex(min(a for a in (int(l[3:7], 16) for l in open(sys.argv[1]) if l.startswith("02:")) if a > 0x6978)))' "$SYM")"

python3 "$ROOT/scripts/font12-pack.py" "$@" | head -2
perl -ni -e 'print unless /^02:(6000|6978) /' "$SYM"
python3 - "$ROM" "$ROOT/kernel/font12/font12-metrics.bin" "$METRICS_END" <<'EOF'
import sys
p, metrics, end = sys.argv[1], sys.argv[2], int(sys.argv[3], 16)
n = len(open(metrics, "rb").read())
if 0x6978 + n > end:
    sys.exit(f"error: Font12Metrics is {n} bytes, 02:6978 + {n} = ${0x6978 + n:04x} reaches the next block at ${end:04x}")
d = bytearray(open(p, "rb").read())
lo, hi = 2 * 0x4000 + (0x6978 - 0x4000), 2 * 0x4000 + (end - 0x4000)
d[lo:hi] = b"\xff" * (hi - lo)
open(p, "wb").write(d)
EOF
cd "$ROOT/kernel"
python3 tools/inject_bytes.py "$V" 2 6000 Font12 "$(xxd -p font12/font12.bin | tr -d '\n')" --apply | tail -1
python3 tools/inject_bytes.py "$V" 2 6978 Font12Metrics "$(xxd -p font12/font12-metrics.bin | tr -d '\n')" --apply | tail -1
