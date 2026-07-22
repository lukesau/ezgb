#!/usr/bin/env bash
# Regen disassembly from kernel.sym + notes.json, then print naming progress
# and the app worklist. Quiet by default; pass -v for full mgbdis/make output.
#
# Usage:
#   scripts/regen-disasm.sh              # 1.05e
#   scripts/regen-disasm.sh 1.05e
#   scripts/regen-disasm.sh 1.05e -v
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER="${1:-1.05e}"
VERBOSE=0
if [[ "${2:-}" == "-v" ]] || [[ "${1:-}" == "-v" ]]; then
  VERBOSE=1
  [[ "${1:-}" == "-v" ]] && VER="1.05e"
fi

RE="$ROOT/re/$VER"
if [[ ! -f "$RE/kernel.gb" ]]; then
  echo "error: missing $RE/kernel.gb" >&2
  exit 1
fi

run() {
  if [[ "$VERBOSE" -eq 1 ]]; then
    "$@"
  else
    "$@" >/tmp/ezgb-regen-$$.log 2>&1 || {
      echo "error: command failed: $*" >&2
      tail -n 40 /tmp/ezgb-regen-$$.log >&2
      rm -f /tmp/ezgb-regen-$$.log
      exit 1
    }
    rm -f /tmp/ezgb-regen-$$.log
  fi
}

cd "$RE"
run python3 "$ROOT/tools/mgbdis/mgbdis.py" kernel.gb --overwrite
run python3 "$ROOT/scripts/annotate-disasm.py" "$VER" || {
  ann_ec=$?
  if [[ "$ann_ec" -eq 1 ]]; then
    echo "warn: annotate-disasm.py exit $ann_ec (orphan note blocks — continuing)" >&2
  else
    exit "$ann_ec"
  fi
}
run make -C disassembly

echo "=== naming-progress ==="
"$ROOT/scripts/naming-progress.sh" "$VER"
echo "=== app worklist ==="
WL="$(mktemp)"
python3 "$ROOT/scripts/doc-symbol-coverage.py" "$VER" --app --frontier-only --top 5 >"$WL" || true
if grep -qE '^[0-9a-fA-F]{2}:' "$WL"; then
  cat "$WL"
else
  python3 "$ROOT/scripts/doc-symbol-coverage.py" "$VER" --app --top 5
fi
rm -f "$WL"
