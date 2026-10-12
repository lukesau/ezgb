#!/bin/sh
# Keep the patcher page's patch counts past Apache's log rotation.
#
# Runs daily from lukesau's crontab on lukesau.com (installed by
# scripts/patcher-counts.sh --install). Apache keeps 14 daily access logs;
# this merges every pixel hit still in them (GET /ezgb/p.gif?k=...) into
# ~/ezgb-patch-hits.log, which never rotates. Each hit line carries its own
# time and the page's millisecond timestamp, so merging with sort -u is
# idempotent: running it twice, or after missing a few days, loses and
# doubles nothing. Needs group adm to read /var/log/apache2.
store="$HOME/ezgb-patch-hits.log"
tmp="$store.tmp.$$"
{
    cat "$store" 2>/dev/null
    zcat -f /var/log/apache2/*access.log* 2>/dev/null | grep 'GET /ezgb/p.gif?k='
} | sort -u > "$tmp" && mv "$tmp" "$store"
