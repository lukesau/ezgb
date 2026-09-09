#!/usr/bin/env bash
# Regenerate the README banner: a stock-vs-mod screenshot comparison.
#
# Fully automated, no manual steps. It (re)builds the emulator SD card from
# sd/root/ (scripts/make-sd-image.sh — this is the same card the emulator uses,
# there is no separate showcase card), boots both the stock and the modded
# 1.05e-0731 kernel in SameBoy (DMG palette), screenshots the SD / SET / HELP
# tabs of each, and stitches a labeled banner.
#
#   ./scripts/make-showcase-banner.sh [output.png]     # default: docs/banner.png
#
# macOS only: uses mtools (via make-sd-image.sh), screencapture (needs Screen
# Recording permission for your terminal), CGWindowList/CGEvent Swift helpers, and
# ImageMagick (`brew install imagemagick`). The mod version in the label comes from
# patches/kernel/VERSION; the card's files/order come from sd/root/ and sd/ORDER.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
OUT="${1:-$ROOT/docs/banner.png}"

KVER="1.05e-0731"                                   # kernel build shown in the banner
MOD_KERNEL="$ROOT/re/$KVER/kernel.gb"
STOCK_KERNEL="$ROOT/tools/ezflashjr/official/2020-07-31_FW5_K1.05RC/ezgb.dat"
SAMEBOY="${SAMEBOY:-$ROOT/tools/SameBoy/build/bin/SDL/sameboy}"
CARD="$ROOT/sd/card.img"
FONT="${SHOWCASE_FONT:-/System/Library/Fonts/Menlo.ttc}"
GREEN='#9bbc0f'                                      # Game Boy pea-green for labels
MOD_VER="$(tr -d '[:space:]' < "$ROOT/patches/kernel/VERSION")"

command -v magick >/dev/null || { echo "error: ImageMagick not found (brew install imagemagick)"; exit 1; }
[ -f "$SAMEBOY" ] || { echo "error: SameBoy not built at $SAMEBOY (see scripts/setup-sameboy.sh)"; exit 1; }
[ -f "$MOD_KERNEL" ] || { echo "error: missing modded kernel $MOD_KERNEL"; exit 1; }
[ -f "$STOCK_KERNEL" ] || { echo "error: missing stock kernel $STOCK_KERNEL"; exit 1; }

TMP="$(mktemp -d /tmp/ezgb-banner.XXXXXX)"
SB_PID=""
cleanup() { [ -n "$SB_PID" ] && kill "$SB_PID" 2>/dev/null || true; rm -rf "$TMP"; }
trap cleanup EXIT

# --- compile the window-id / key-injection helpers -------------------------
swiftc -O "$ROOT/scripts/showcase/winid.swift" -o "$TMP/winid"
swiftc -O "$ROOT/scripts/showcase/keys.swift"  -o "$TMP/keys"

# --- capture one kernel's SD / SET / HELP tabs into a 3-panel montage -------
# Select (SameBoy default = Backspace, macOS keycode 51) cycles the tabs.
capture_row() {
  local kernel="$1" out="$2" wid="" i
  SAMEBOY_EZFLASH_JR_IMG="$CARD" "$SAMEBOY" --model dmg "$kernel" >/dev/null 2>&1 &
  SB_PID=$!
  for i in $(seq 1 40); do sleep 0.5; wid="$("$TMP/winid" | head -1)"; if [ -n "$wid" ]; then break; fi; done
  [ -n "$wid" ] || { echo "error: SameBoy window not found"; return 1; }
  sleep 6                                              # boot + first browser paint
  screencapture -x -o -l "$wid" "$TMP/b.png"
  "$TMP/keys" "$SB_PID" 51 1; sleep 2.5; screencapture -x -o -l "$wid" "$TMP/s.png"  # SET (wait for clock)
  "$TMP/keys" "$SB_PID" 51 1; sleep 1.5; screencapture -x -o -l "$wid" "$TMP/h.png"  # HELP
  kill "$SB_PID" 2>/dev/null || true; wait "$SB_PID" 2>/dev/null || true; SB_PID=""

  # Crop the SDL chrome: the 160x144 screen fills the window width and sits at the
  # bottom, so screen height = W*144/160 and the title bar is whatever's above it.
  local W H GBH Y crop
  W="$(sips -g pixelWidth  "$TMP/b.png" | awk '/pixelWidth/{print $2}')"
  H="$(sips -g pixelHeight "$TMP/b.png" | awk '/pixelHeight/{print $2}')"
  GBH=$(( W * 144 / 160 )); Y=$(( H - GBH )); crop="${W}x${GBH}+0+${Y}"
  local p
  for p in b s h; do magick "$TMP/$p.png" -crop "$crop" +repage "$TMP/c-$p.png"; done
  # Join the three panels with a black gutter (a plain append avoids `montage`'s
  # default filename labels, which need a font and error out under `set -e`).
  magick -size "12x${GBH}" xc:black "$TMP/gut.png"
  magick "$TMP/c-b.png" "$TMP/gut.png" "$TMP/c-s.png" "$TMP/gut.png" "$TMP/c-h.png" \
    +append -bordercolor black -border 0x12 "$out"
}

# --- a black label strip: title on the left, version on the right ----------
label() {
  local out="$1" left="$2" right="$3" w="$4" ps
  ps=$(( w * 28 / 996 ))
  magick -size "${w}x50" xc:black -font "$FONT" -pointsize "$ps" -fill "$GREEN" \
    -gravity West -annotate +22+0 "$left" \
    -gravity East -annotate +22+0 "$right" "$out"
}

echo "building SD card (sd/card.img) from sd/root + sd/ORDER..."
"$ROOT/scripts/make-sd-image.sh" >/dev/null
[ -f "$CARD" ] || { echo "error: $CARD was not built"; exit 1; }

echo "capturing stock $KVER..."
capture_row "$STOCK_KERNEL" "$TMP/row-stock.png"
echo "capturing mod $KVER mod-$MOD_VER..."
capture_row "$MOD_KERNEL" "$TMP/row-mod.png"

RW="$(sips -g pixelWidth "$TMP/row-stock.png" | awk '/pixelWidth/{print $2}')"
label "$TMP/hdr-stock.png" "STOCK" "$KVER"                    "$RW"
label "$TMP/hdr-mod.png"   "MOD"   "$KVER mod-$MOD_VER"       "$RW"
magick -size "${RW}x16" xc:black "$TMP/spacer.png"

mkdir -p "$(dirname "$OUT")"
magick "$TMP/hdr-stock.png" "$TMP/row-stock.png" "$TMP/spacer.png" \
       "$TMP/hdr-mod.png"   "$TMP/row-mod.png" -append \
       -bordercolor black -border 16x16 "$OUT"

echo "wrote $OUT ($(sips -g pixelWidth -g pixelHeight "$OUT" | awk '/pixel/{printf "%s ",$2}')px)"
