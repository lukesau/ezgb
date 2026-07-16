#!/usr/bin/env bash
# Symbol-annotated byte diff between two Game Boy ROMs.
# Thin wrapper around tools/gb-asm-tools/tools/gbdiff.sh (pret).
#
# gbdiff annotates each differing region with the nearest preceding symbol read
# from a "<rom-basename>.sym" file sitting beside each ROM. We ship
# re/1.05e/kernel.sym, so the newer side gets named; drop a re/1.04e/kernel.sym
# beside the older dump (e.g. a built disassembly/game.sym) to name both sides.
#
# Usage:
#   scripts/gbdiff.sh                # diff the 1.04e vs 1.05e kernel dumps
#   scripts/gbdiff.sh old.gb new.gb  # diff any two ROMs
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
GBDIFF="${GBASM_TOOLS:-$ROOT/tools/gb-asm-tools}/tools/gbdiff.sh"

A="${1:-$ROOT/re/1.04e/kernel.gb}"
B="${2:-$ROOT/re/1.05e/kernel.gb}"

if [[ ! -f "$GBDIFF" ]]; then
  echo "error: missing $GBDIFF" >&2
  echo "       git clone https://github.com/pret/gb-asm-tools \"$ROOT/tools/gb-asm-tools\"" >&2
  exit 1
fi

for f in "$A" "$B"; do
  if [[ ! -f "$f" ]]; then
    echo "error: ROM not found: $f" >&2
    exit 1
  fi
done

exec bash "$GBDIFF" "$A" "$B"
