#!/usr/bin/env bash
# Interior-label naming loop — phase after notes.json CF is complete.
#
# Names auto Jump_/jr_ inside already-named functions via kernel.sym + regen.
# Does not touch notes-only CF work (see docs/MAP-SESSION.md).
#
# Usage:
#   ./scripts/map-interior.sh
#   ./scripts/map-interior.sh --top 10
#   ./scripts/map-interior.sh --include-lib --top 5
#   ./scripts/map-interior.sh --banks 04 --top 5
#   ./scripts/map-interior.sh --apply names.txt   # apply sym + regen + packet
#   ./scripts/map-interior.sh --skip-complete     # skip D rows with 0 asm autos
#
# Exit codes:
#   0  work remains (or apply succeeded)
#   2  no interior targets left (--skip-complete and all asm autos cleared)
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER="1.05e"
TOP=5
MAX_LABELS=40
INCLUDE_LIB=0
BANKS=""
SKIP_BANKS=""
SKIP_COMPLETE=0
APPLY=""
REGEN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --top)
      TOP="$2"
      shift 2
      ;;
    --max-labels)
      MAX_LABELS="$2"
      shift 2
      ;;
    --include-lib)
      INCLUDE_LIB=1
      shift
      ;;
    --banks)
      BANKS="$2"
      shift 2
      ;;
    --skip-banks)
      SKIP_BANKS="$2"
      shift 2
      ;;
    --skip-complete)
      SKIP_COMPLETE=1
      shift
      ;;
    --apply)
      APPLY="$2"
      REGEN=1
      shift 2
      ;;
    --regen)
      REGEN=1
      shift
      ;;
    -h|--help)
      sed -n '2,22p' "$0"
      exit 0
      ;;
    -*)
      echo "unknown flag: $1" >&2
      exit 1
      ;;
    *)
      VER="$1"
      shift
      ;;
  esac
done

cd "$ROOT"

INT_FLAGS=(--app --top "$TOP" --max-labels "$MAX_LABELS")
[[ "$INCLUDE_LIB" -eq 1 ]] && INT_FLAGS+=(--include-lib)
[[ -n "$BANKS" ]] && INT_FLAGS+=(--banks "$BANKS")
[[ -n "$SKIP_BANKS" ]] && INT_FLAGS+=(--skip-banks "$SKIP_BANKS")
[[ "$SKIP_COMPLETE" -eq 1 ]] && INT_FLAGS+=(--skip-complete)

SCOPE="app"
[[ "$INCLUDE_LIB" -eq 1 ]] && SCOPE="app+lib"
[[ -n "$BANKS" ]] && SCOPE="banks=$BANKS"

if [[ -n "$APPLY" ]]; then
  echo "=== apply ==="
  python3 "$ROOT/scripts/interior-packet.py" "$VER" --apply "$APPLY"
  REGEN=1
fi

if [[ "$REGEN" -eq 1 ]]; then
  echo
  echo "=== regen ==="
  "$ROOT/scripts/regen-disasm.sh" "$VER"
fi

echo "=== progress ==="
"$ROOT/scripts/naming-progress.sh" "$VER" || true

echo
echo "=== interior worklist ($SCOPE --top $TOP) ==="
PACKET_OUT="$(mktemp)"
python3 "$ROOT/scripts/interior-packet.py" "$VER" "${INT_FLAGS[@]}" | tee "$PACKET_OUT"

echo
echo "=== next ==="
echo "  1. Read TARGET + NOTES CF + UNNAMED INTERIOR LABELS (do not re-grep)."
echo "  2. Name labels in re/$VER/kernel.sym: ParentFn_role (qualified, not top-level API)."
echo "     Or batch: write names.txt then ./scripts/map-interior.sh $VER --apply names.txt"
echo "  3. ./scripts/regen-disasm.sh $VER  (required after sym edits)"
echo "  4. One parent function per tick; huge fns (--max-labels) may take several ticks."
echo "  doc: docs/INTERIOR-NAMING.md"
echo "  scope: $SCOPE; lib banks skipped unless --include-lib or --banks"

if grep -q '^interior_complete: 1' "$PACKET_OUT"; then
  rm -f "$PACKET_OUT"
  exit 2
fi
rm -f "$PACKET_OUT"
exit 0
