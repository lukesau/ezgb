#!/bin/sh
# Tally the patcher page's successful patches, run on lukesau.com itself
# (installed as ~/ezgb-patch-counts by scripts/patcher-counts.sh --install;
# from a checkout, scripts/patcher-counts.sh does the same over ssh). Counts
# ~/ezgb-patch-hits.log, the archive the daily cron job keeps
# (archive-hits.sh), plus whatever the live Apache logs hold, per patch id.
# Ids starting with "test" are skipped. Needs group adm.
#
#   ~/ezgb-patch-counts                # all time
#   ~/ezgb-patch-counts 12/Oct/2026    # one day, as Apache writes it
day="$1"
hits="$({ cat "$HOME/ezgb-patch-hits.log" 2>/dev/null
          zcat -f /var/log/apache2/*access.log* 2>/dev/null | grep 'GET /ezgb/p.gif?k='
        } | sort -u | grep -v 'k=test' | grep -F -- "$day")"
if [ -z "$hits" ]; then
    echo "no patches counted${day:+ on $day}"
    exit 0
fi
printf '%s\n' "$hits" | sed -E 's/.*[?&]k=([^& ]*).*/\1/' | sort | uniq -c | sort -rn
