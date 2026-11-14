/* UI theme colors (docs/dark-mode.md): what color index 0..3 of every tile
 * draws as on a color console in CGB mode, per theme number (vars.h).
 * BGR555, little endian. Data only, injected at 02:4960 on its own;
 * theme_pick.c's theme_ramp reads it by address.
 *
 * Dark is a black background, so an OLED screen leaves those pixels off,
 * with white ink. Every theme past 0 has white ink, and shade 1 is the
 * background blended 20% toward white, the popups' background. Light and
 * dark have shade 2 at 56%, a gray; the color themes have their accent
 * there (dv_params.c draws the selection bar and the rules in it), picked
 * from the background's complement and split complements, then made more
 * saturated until they kept their color through a GBC screen's washout
 * (SameBoy's color correction); the background, the bar's text, reads on
 * each at 5:1 or better (docs/dark-mode.md "Accents"). Custom (6) has no row:
 * its colors come from COLORS= (theme_colors.c). DV (7) has its own, in
 * theme_pick.c. */

#include "types.h"
#include "vars.h"

const u8 theme_ramps[THEME_CUSTOM][8] = {
    {0xff, 0x7f, 0xb5, 0x56, 0x4a, 0x29, 0x00, 0x00},   /* LIGHT  $7fff $56b5 $294a $0000, stock */
    {0x00, 0x00, 0xc6, 0x18, 0x31, 0x46, 0xff, 0x7f},   /* DARK   $0000 $18c6 $4631 $7fff */
    {0x28, 0x04, 0xed, 0x1c, 0x88, 0x7e, 0xff, 0x7f},   /* RED    $0428 $1ced $7e88 $7fff, accent #42A5FF sky */
    {0x22, 0x0d, 0xa8, 0x25, 0x5f, 0x62, 0xff, 0x7f},   /* GREEN  $0d22 $25a8 $625f $7fff, accent #FF94C5 rose */
    {0x48, 0x30, 0x0d, 0x41, 0x5d, 0x1f, 0xff, 0x7f},   /* PURPLE $3048 $410d $1f5d $7fff, accent #EFD63A gold */
    {0xa2, 0x30, 0x48, 0x41, 0x9f, 0x36, 0xff, 0x7f},   /* BLUE   $30a2 $4148 $369f $7fff, accent #FFA56B apricot */
};
