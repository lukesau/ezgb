#!/usr/bin/env bash
# Tally the patcher page's successful patches from lukesau.com's Apache logs.
# The page (scripts/patcher/patcher.html, count()) loads
# https://lukesau.com/ezgb/p.gif?k=<patch id>&t=<ms> after each verified
# patch; this counts those hits per patch id, rotated logs included. Ids
# starting with "test" are skipped.
#
# Reading /var/log/apache2 needs group adm (lukesau has it since 2026-10-12).
# The ssh skips the persistent ControlMaster connection: a master opened
# before a group change keeps the old groups for as long as it lives.
#
#   scripts/patcher-counts.sh                 # all time
#   scripts/patcher-counts.sh 12/Oct/2026     # one day, as Apache writes it
set -euo pipefail
day="${1:-}"
hits="$(ssh -o ControlMaster=no -o ControlPath=none lukesau.com \
    "zcat -f /var/log/apache2/*access.log*" \
  | { grep 'GET /ezgb/p.gif?k=' || true; } | { grep -v 'k=test' || true; } | { grep -F -- "$day" || true; })"
if [ -z "$hits" ]; then
  echo "no patches counted${day:+ on $day}"
  exit 0
fi
printf '%s\n' "$hits" | sed -E 's/.*[?&]k=([^& ]*).*/\1/' | sort | uniq -c | sort -rn
