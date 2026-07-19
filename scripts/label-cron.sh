#!/usr/bin/env bash
# Deterministic labeling pass — no LLM required.
#
# 1. stamp-bank-clones.py --apply (cross-bank body matches)
# 2. propose-labels.py --apply   (wrappers / farcalls / FPGA shapes)
# 3. regen-disasm.sh             (mgbdis → annotate → make → progress)
# 4. label-packet.py             (row-1 context + needs_judgment)
#
# Exit codes:
#   0  mechanical work done; packet does not need judgment (or no target)
#   2  packet needs judgment — wake the agent
#   1  regen / script failure
#
# Usage:
#   scripts/label-cron.sh
#   scripts/label-cron.sh 1.05e
#   scripts/label-cron.sh 1.05e --dry-run   # propose/stamp dry-run; still prints packet
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
VER="1.05e"
DRY=0
for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    -*) ;;
    *) VER="$a" ;;
  esac
done

cd "$ROOT"

echo "=== stamp-bank-clones ==="
if [[ "$DRY" -eq 1 ]]; then
  python3 "$ROOT/scripts/stamp-bank-clones.py" "$VER" --dry-run
else
  python3 "$ROOT/scripts/stamp-bank-clones.py" "$VER"
fi

echo "=== propose-labels ==="
if [[ "$DRY" -eq 1 ]]; then
  python3 "$ROOT/scripts/propose-labels.py" "$VER" --dry-run
else
  python3 "$ROOT/scripts/propose-labels.py" "$VER" --apply
fi

echo "=== regen ==="
"$ROOT/scripts/regen-disasm.sh" "$VER"

echo "=== packet ==="
PACKET_OUT="$(mktemp)"
python3 "$ROOT/scripts/label-packet.py" "$VER" --app --frontier-only --top 5 | tee "$PACKET_OUT"

if grep -q '^needs_judgment: 1' "$PACKET_OUT"; then
  rm -f "$PACKET_OUT"
  echo "WAKE: packet needs judgment"
  exit 2
fi
rm -f "$PACKET_OUT"
echo "OK: no judgment needed"
exit 0
