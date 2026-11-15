#!/usr/bin/env bash
# Build SDCC 2.9.0, the compiler EZ Flash used for stage1 and the kernel,
# into tools/sdcc-2.9.0 (ignored). Only the compiler is built, and its C
# library headers copied: the preprocessor, assembler and linker come from
# a current SDCC on PATH (sdcpp, sdasgb, sdldgb), which handle 2.9.0's
# output the same.
#
#   stage1/decomp/tools/build-sdcc29.sh [sdcc-src-2.9.0.tar.bz2]
#
# Without an argument the source release is fetched from SourceForge.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../../.." && pwd)"
OUT="$ROOT/tools/sdcc-2.9.0"
URL="https://sourceforge.net/projects/sdcc/files/sdcc/2.9.0/sdcc-src-2.9.0.tar.bz2/download"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

TAR="${1:-$WORK/sdcc-src-2.9.0.tar.bz2}"
[[ -f "$TAR" ]] || curl -fsSL -o "$TAR" "$URL"
tar xjf "$TAR" -C "$WORK"
cd "$WORK/sdcc"

# 2009 C: a current gcc or clang needs these to get through it
export CFLAGS="-O1 -fcommon -std=gnu89 -Wno-error -Wno-implicit-function-declaration \
  -Wno-int-conversion -Wno-incompatible-pointer-types -Wno-implicit-int -Wno-return-type"
export CXXFLAGS="-O1 -Wno-error"
./configure --disable-mcs51-port --disable-ds390-port --disable-ds400-port \
  --disable-hc08-port --disable-pic-port --disable-pic16-port --disable-xa51-port \
  --disable-avr-port --disable-ucsim --disable-device-lib --disable-packihx \
  --disable-sdcpp --disable-sdcdb >/dev/null
# the old linker no longer builds (getline clash); the compiler is all we need
make -C support/Util >/dev/null 2>&1 || true
make -C src -j4 >/dev/null

mkdir -p "$OUT/bin"
cp bin/sdcc "$OUT/bin/sdcc"
# the C library headers (string.h, stdarg.h), where the compiler looks
mkdir -p "$OUT/share/sdcc"
rm -rf "$OUT/share/sdcc/include"
cp -R device/include "$OUT/share/sdcc/include"
# 2.9.0 passes -obj-ext=.o to sdcpp, which a current sdcpp reads as -o
cat > "$OUT/bin/sdcpp" <<'EOF'
#!/bin/sh
for a; do shift; case "$a" in -obj-ext=*) ;; *) set -- "$@" "$a";; esac; done
exec "$(PATH="$(printf %s "$PATH" | tr : '\n' | grep -vx "$(dirname "$0")" | paste -sd: -)" command -v sdcpp)" "$@"
EOF
chmod +x "$OUT/bin/sdcpp"
ln -sf "$(command -v sdasgb)" "$OUT/bin/sdasgb"
"$OUT/bin/sdcc" -v | head -1
