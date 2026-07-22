#!/usr/bin/env bash
# Report disassembly labeling progress.
#
# Base heuristic matches pret unnamed.py (auto-name ends with its address).
# Jump_/jr_ symbols also count as named when documented in notes.json
# (cited as Jump_BBB_AAAA / jr_BBB_AAAA, or a notes block at that addr).
#
# Usage:
#   scripts/naming-progress.sh            # summary line for 1.05e
#   scripts/naming-progress.sh 1.04e      # summary line for another version
#   scripts/naming-progress.sh 1.05e all  # also list every remaining unnamed symbol
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER="${1:-1.05e}"
MODE="${2:-summary}"

exec python3 "$ROOT/scripts/naming-progress.py" "$VER" "$MODE"
