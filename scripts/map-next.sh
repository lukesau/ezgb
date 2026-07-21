#!/usr/bin/env bash
# Human lean mapping surface — same context agents get each tick.
#
# 1. naming-progress summary
# 2. propose-labels (dry-run by default; --apply to stamp)
# 3. worklist (doc-symbol-coverage --app --top N; --frontier-only if F rows)
# 4. label-packet for row 1 (body / callers / WRAM / needs_judgment)
# 5. short next-steps footer
#
# Exit codes:
#   0  no judgment needed (or no target)
#   2  packet needs_judgment: 1
#   1  script failure
#
# Usage:
#   ./scripts/map-next.sh
#   ./scripts/map-next.sh 1.05e
#   ./scripts/map-next.sh --top 10
#   ./scripts/map-next.sh 1.05e --apply
#   ./scripts/map-next.sh --include-lib --top 5          # FatFs + app
#   ./scripts/map-next.sh --banks 09 --top 5             # canonical FatFs bank only
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER="1.05e"
TOP=5
APPLY=0
INCLUDE_LIB=0
BANKS=""
SKIP_BANKS=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --top)
      TOP="$2"
      shift 2
      ;;
    --apply)
      APPLY=1
      shift
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
    -h|--help)
      sed -n '2,24p' "$0"
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

# Shared flag vectors for coverage + packet
COV_FLAGS=(--app --top "$TOP")
PKT_FLAGS=(--app --top "$TOP")
if [[ "$INCLUDE_LIB" -eq 1 ]]; then
  COV_FLAGS+=(--include-lib)
  PKT_FLAGS+=(--include-lib)
fi
if [[ -n "$BANKS" ]]; then
  COV_FLAGS+=(--banks "$BANKS")
  PKT_FLAGS+=(--banks "$BANKS")
fi
if [[ -n "$SKIP_BANKS" ]]; then
  COV_FLAGS+=(--skip-banks "$SKIP_BANKS")
  PKT_FLAGS+=(--skip-banks "$SKIP_BANKS")
fi

SCOPE="app"
[[ "$INCLUDE_LIB" -eq 1 ]] && SCOPE="app+lib"
[[ -n "$BANKS" ]] && SCOPE="banks=$BANKS"

echo "=== progress ==="
"$ROOT/scripts/naming-progress.sh" "$VER" || true

echo
echo "=== proposals ==="
if [[ "$APPLY" -eq 1 ]]; then
  python3 "$ROOT/scripts/propose-labels.py" "$VER" --apply
else
  python3 "$ROOT/scripts/propose-labels.py" "$VER" --dry-run
fi

echo
echo "=== worklist ($SCOPE --top $TOP) ==="
# Prefer frontier when any F rows exist (same preference as label-packet).
COV_OUT="$(mktemp)"
python3 "$ROOT/scripts/doc-symbol-coverage.py" "$VER" "${COV_FLAGS[@]}" --frontier-only | tee "$COV_OUT"
if grep -qE ': 0 candidates|; show 0$' "$COV_OUT"; then
  APP_OUT="$(mktemp)"
  python3 "$ROOT/scripts/doc-symbol-coverage.py" "$VER" "${COV_FLAGS[@]}" >"$APP_OUT"
  if ! grep -qE ': 0 candidates|; show 0$' "$APP_OUT"; then
    echo "(no frontier rows — falling back without --frontier-only)"
    cat "$APP_OUT"
  else
    # both empty — still show the empty frontier table already teed
    :
  fi
  rm -f "$APP_OUT"
fi
rm -f "$COV_OUT"

echo
echo "=== packet (row 1) ==="
PACKET_OUT="$(mktemp)"
python3 "$ROOT/scripts/label-packet.py" "$VER" "${PKT_FLAGS[@]}" --frontier-only | tee "$PACKET_OUT"

echo
echo "=== next ==="
echo "  1. Read TARGET + BODY + ABS TOUCHES + CALLERS (do not re-grep)."
echo "  2. Name clear targets in re/$VER/kernel.sym; notes in re/$VER/notes.json"
echo "     (surgical edits only — no broad replaces)."
echo "  3. Prefer bank 09 for FatFs; stamp clones cover 03/05/06/07 when bodies match."
echo "  4. ./scripts/regen-disasm.sh $VER"
echo "  glossary: frontier/F = unnamed callee of a named fn;"
echo "            O = unlabeled function after ret (add sp, -\$ prologue);"
echo "            J = Jump_ that looks like a real entry (after ret);"
echo "            D = interior debt (named fn still has auto Jump_/jr_);"
echo "            needs_judgment=1 = deep-read before naming;"
if [[ "$INCLUDE_LIB" -eq 1 || -n "$BANKS" ]]; then
  echo "            lib banks included (scope=$SCOPE)."
else
  echo "            lib banks 03/05/06/07/09 skipped (pass --include-lib or --banks 09);"
fi
echo "            rank dump only (no body): ./scripts/doc-symbol-coverage.py --top 25"

if grep -q '^needs_judgment: 1' "$PACKET_OUT"; then
  rm -f "$PACKET_OUT"
  exit 2
fi
rm -f "$PACKET_OUT"
exit 0
