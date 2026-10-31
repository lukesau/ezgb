/* The SET tab THEME button's names (theme_row.c, docs/dark-mode.md), by
 * theme number, six wide so a shorter name covers a longer one. Data only,
 * injected on its own (ThemeRow had no room for a seventh), at 04:7eeb since
 * DV made eight (04:7f20 until then, RecFlag follows it). */

#include "types.h"
#include "vars.h"

const u8 theme_names[THEME_COUNT][7] = {
    {' ','L','I','G','H','T',0},
    {' ',' ','D','A','R','K',0},
    {' ',' ',' ','R','E','D',0},
    {' ','G','R','E','E','N',0},
    {'P','U','R','P','L','E',0},
    {' ',' ','B','L','U','E',0},
    {'C','U','S','T','O','M',0},
    {' ',' ',' ',' ','D','V',0},     /* THEME_DV, after custom (vars.h) */
};
