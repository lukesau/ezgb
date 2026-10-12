#!/usr/bin/env bash
# Tally the patcher page's successful patches from lukesau.com.
# The page (scripts/patcher/patcher.html, count()) loads
# https://lukesau.com/ezgb/p.gif?k=<patch id>&t=<ms> after each verified
# patch. Apache keeps only 14 daily logs, so a daily cron job
# (scripts/patcher/archive-hits.sh) copies the hits into
# ~/ezgb-patch-hits.log; this counts that archive plus whatever the live logs
# hold, per patch id. Ids starting with "test" are skipped.
#
# Reading /var/log/apache2 needs group adm (lukesau has it since 2026-10-12).
# The ssh skips the persistent ControlMaster connection: a master opened
# before a group change keeps the old groups for as long as it lives.
#
#   scripts/patcher-counts.sh                 # all time
#   scripts/patcher-counts.sh 12/Oct/2026     # one day, as Apache writes it
#   scripts/patcher-counts.sh --install       # (re)install the archive cron job and
#                                             # ~/ezgb-patch-counts for use on the server
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SSH=(ssh -o ControlMaster=no -o ControlPath=none lukesau.com)
CRON='17 1 * * * $HOME/bin/ezgb-patch-hits'

if [ "${1:-}" = "--install" ]; then
  "${SSH[@]}" 'mkdir -p ~/bin && cat > ~/bin/ezgb-patch-hits && chmod 755 ~/bin/ezgb-patch-hits' \
    < "$ROOT/scripts/patcher/archive-hits.sh"
  "${SSH[@]}" 'cat > ~/ezgb-patch-counts && chmod 755 ~/ezgb-patch-counts' \
    < "$ROOT/scripts/patcher/count-hits.sh"
  "${SSH[@]}" "( crontab -l 2>/dev/null | grep -v 'bin/ezgb-patch-hits'; echo '$CRON' ) | crontab - && ~/bin/ezgb-patch-hits && crontab -l && wc -l ~/ezgb-patch-hits.log"
  exit 0
fi

day="${1:-}"
hits="$("${SSH[@]}" \
    "{ cat ~/ezgb-patch-hits.log 2>/dev/null; zcat -f /var/log/apache2/*access.log* | grep 'GET /ezgb/p.gif?k='; } | sort -u" \
  | { grep -v 'k=test' || true; } | { grep -F -- "$day" || true; })"
if [ -z "$hits" ]; then
  echo "no patches counted${day:+ on $day}"
  exit 0
fi
printf '%s\n' "$hits" | sed -E 's/.*[?&]k=([^& ]*).*/\1/' | sort | uniq -c | sort -rn
