#!/usr/bin/env bash
# Report disassembly labeling progress: how many symbols are still auto-named
# by mgbdis (e.g. Call_000_1a77, jr_007_4175, Jump_006_642f) versus given a
# human name. Wraps tools/gb-asm-tools/tools/unnamed.py (pret) against a built
# game.sym (rgblink -n output).
#
# Usage:
#   scripts/naming-progress.sh            # summary line for 1.05e
#   scripts/naming-progress.sh 1.04e      # summary line for another version
#   scripts/naming-progress.sh 1.05e all  # also list every unnamed symbol
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER="${1:-1.05e}"
MODE="${2:-summary}"
UNNAMED="${GBASM_TOOLS:-$ROOT/tools/gb-asm-tools}/tools/unnamed.py"
SYM="$ROOT/re/$VER/disassembly/game.sym"

if [[ ! -f "$UNNAMED" ]]; then
  echo "error: missing $UNNAMED" >&2
  echo "       git clone https://github.com/pret/gb-asm-tools \"$ROOT/tools/gb-asm-tools\"" >&2
  exit 1
fi

if [[ ! -f "$SYM" ]]; then
  echo "error: $SYM not found; build the disassembly first:" >&2
  echo "       (cd \"$ROOT/re/$VER/disassembly\" && make)" >&2
  exit 1
fi

if [[ "$MODE" == "all" ]]; then
  exec python3 "$UNNAMED" "$SYM"
else
  python3 "$UNNAMED" "$SYM" | head -n 1
fi
