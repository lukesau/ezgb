#!/usr/bin/env bash
# Tally the patcher page's successful patches from lukesau.com's Apache logs.
# The page (scripts/patcher/patcher.html, count()) loads
# https://lukesau.com/ezgb/p.gif?k=<patch id>&t=<ms> after each verified patch;
# this counts those hits per patch id, rotated logs included. Reading the logs
# needs root (sudo prompts in this terminal) or membership in group adm.
#
#   scripts/patcher-counts.sh            # all time
#   scripts/patcher-counts.sh 12/Oct/2026   # one day, as Apache writes it
set -euo pipefail
day="${1:-}"
ssh -t lukesau.com "sudo sh -c 'zcat -f /var/log/apache2/*access.log*'" \
  | grep 'GET /ezgb/p.gif?k=' | grep -v 'k=test' | grep -F -- "$day" \
  | sed -E 's/.*[?&]k=([^& ]*).*/\1/' | sort | uniq -c | sort -rn
