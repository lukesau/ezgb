#!/bin/sh
# tools/asm.sh FILE.c [fw4|fw5-0918]: SDCC 2.9.0's assembly for one source, on stdout
here=$(cd "$(dirname "$0")/.." && pwd); repo=$(cd "$here/../.." && pwd)
sdcc=${SDCC29:-$repo/tools/sdcc-2.9.0}; d=$(mktemp -d)
case ${2:-fw4} in fw4) l="Update to ver:4 "; f=4 ;; *) l="Update to ver:5 "; f=5 ;; esac
printf '#define LABEL "%s"\n' "$l" > "$d/label.h"
PATH=$sdcc/bin:$PATH "$sdcc/bin/sdcc" -S -mgbz80 --no-std-crt0 ${UPD_CFLAGS---opt-code-size} -DFW=$f -DBYTE_IS_UNSIGNED=1 \
    -I"$d" -I"$repo/kernel/stock/gbdk/include" -I"$here/src" "$1" -o "$d/o.asm" && cat "$d/o.asm"
rm -rf "$d"
