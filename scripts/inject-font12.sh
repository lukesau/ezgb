#!/usr/bin/env bash
# Pack decomp/font12/font12.txt and (re)place the Font12 glyph table at
# 02:6000 in re/<version>/kernel.gb. Re-run after editing the glyph sheet.
#
#   scripts/inject-font12.sh [version]        (default 1.05e-0731)
#
# inject_bytes.py refuses an address that already has a kernel.sym entry, so
# the previous Font12 lines are dropped first (same pattern as
# scripts/inject-ezcfg.sh). The table is a fixed 2424 bytes, so nothing is
# left stale behind it.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
V="${1:-1.05e-0731}"
SYM="$ROOT/re/$V/kernel.sym"

python3 "$ROOT/scripts/font12-pack.py" | head -1
perl -ni -e 'print unless /^02:6000 /' "$SYM"
cd "$ROOT/decomp"
python3 tools/inject_bytes.py "$V" 2 6000 Font12 "$(xxd -p font12/font12.bin | tr -d '\n')" --apply | tail -1
