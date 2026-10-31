/* UI theme colors (docs/dark-mode.md): what color index 0..3 of every tile
 * draws as on a color console in CGB mode, by row: light, dark, DV
 * (theme_pick.c's theme_ramp maps the theme number to its row). BGR555,
 * little endian. Data only, injected at 02:4960 on its own; theme.c reads
 * it by address.
 *
 * Dark is a black background, so an OLED screen leaves those pixels off,
 * with white ink; its two middle shades are black blended 20% and 56%
 * toward white. DV is davidesqalv's ezgb-dv colors: black, lime (the
 * selection bar and accents, StoreDrawParams' DV remap), blue, white, the
 * colors a GBC's boot ROM gives an unknown DMG game, which DV's BGP $27
 * picks on stock firmware (theme.c). Red, green, purple, blue and custom
 * were rows 2..6 until 2026-10-31. */

#include "types.h"
#include "vars.h"

const u8 theme_ramps[3][8] = {
    {0xff, 0x7f, 0xb5, 0x56, 0x4a, 0x29, 0x00, 0x00},   /* LIGHT  $7fff $56b5 $294a $0000, stock */
    {0x00, 0x00, 0xc6, 0x18, 0x31, 0x46, 0xff, 0x7f},   /* DARK   $0000 $18c6 $4631 $7fff */
    {0x00, 0x00, 0xef, 0x1b, 0x80, 0x61, 0xff, 0x7f},   /* DV     $0000 $1bef $6180 $7fff: #000000 #7BFF31 #0063C5 #FFFFFF */
};
