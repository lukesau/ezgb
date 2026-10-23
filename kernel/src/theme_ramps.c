/* UI theme colors (docs/dark-mode.md): what color index 0..3 of every tile
 * draws as on a color console in CGB mode, per theme number (vars.h).
 * BGR555, little endian. Data only, injected at 02:4960 on its own so a
 * theme is one more row here; theme.c reads it by address.
 *
 * Dark is made for OLED screens: a gray background and a dim tan ink. The
 * colored themes have white ink, and their two middle shades are the
 * background blended 20% and 56% toward white. Green, purple and blue are
 * brighter than red so the three stay apart on an unlit GBC screen. On a
 * DMG every theme past 0 is the inverted palette (theme.c). */

#include "types.h"
#include "vars.h"

const u8 theme_ramps[THEME_COUNT][8] = {
    {0xff, 0x7f, 0xb5, 0x56, 0x4a, 0x29, 0x00, 0x00},   /* LIGHT  $7fff $56b5 $294a $0000, stock */
    {0xc6, 0x18, 0x4b, 0x25, 0x11, 0x36, 0xd8, 0x4a},   /* DARK   $18c6 $254b $3611 $4ad8 */
    {0x00, 0x00, 0xc6, 0x18, 0x31, 0x46, 0xff, 0x7f},   /* BLACK  $0000 $18c6 $4631 $7fff */
    {0x28, 0x04, 0xed, 0x1c, 0x55, 0x4a, 0xff, 0x7f},   /* RED    $0428 $1ced $4a55 $7fff */
    {0x22, 0x0d, 0xa8, 0x25, 0xb2, 0x4e, 0xff, 0x7f},   /* GREEN  $0d22 $25a8 $4eb2 $7fff */
    {0x48, 0x30, 0x0d, 0x41, 0x55, 0x5e, 0xff, 0x7f},   /* PURPLE $3048 $410d $5e55 $7fff */
    {0xa2, 0x30, 0x48, 0x41, 0x92, 0x5e, 0xff, 0x7f},   /* BLUE   $30a2 $4148 $5e92 $7fff */
};
