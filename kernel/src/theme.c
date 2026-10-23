/* UI theme palettes (docs/dark-mode.md).
 *
 * Bank 2, injected at 02:43d0 (bank 2 is the same in every stock kernel,
 * and bank 1 has no free space common to all three). One entry, three
 * callers:
 *
 *   boot     CgbInit (00:0259) calls it right before the boot LCD-on, with
 *            bank 2 mapped by hand (interrupts are still off). EZGB.CFG is
 *            not read yet (CFG_LOADED is 0, WRAM was just cleared), so THEME
 *            comes from the pSRAM mark the last run left: page $11 $A414,
 *            'T', 'H', theme, ~theme. A missing or faded mark is theme 0.
 *   runtime  once THEME holds the file's value: ezcfg's boot restore (a
 *            near call) and the SET tab (FarCallTheme_B4, 04:5990). The
 *            mark is rewritten from THEME, and the theme's four colors are
 *            copied after it ($A418-$A41F), so the next boot starts in it:
 *            our stage1 builds its boot screen palettes from that copy and
 *            keeps no theme table of its own.
 *
 * Either way it then sets the palette registers: BGP/OBP0/OBP1 on every
 * console (the CGB ignores them in CGB mode, a DMG has nothing else), and on
 * a CGB in CGB mode the theme's ramp (theme_ramps.c, 02:4960) in all 8 BG
 * and 8 OBJ palettes, so a stray non-zero attribute still draws in the
 * theme (cgb_init.c zeroes them). Theme 0 is the stock look: BGP $E4, OBP0
 * $E4, OBP1 $1B, the ramp cgb_init.c used to write. Every other theme is a
 * dark one, which on a DMG is the inverted palette.
 *
 * Palette RAM is locked while the LCD draws a line (mode 3). At boot the LCD
 * is off; at run time every byte is written by index and read back, both in
 * mode 0 or 1, and written again if it did not take.
 */

#include "types.h"
#include "vars.h"
#include "ezcfg.h"

#define rSTAT (*(volatile u8 *)0xff41)
#define rBGP  (*(volatile u8 *)0xff47)
#define rOBP0 (*(volatile u8 *)0xff48)
#define rOBP1 (*(volatile u8 *)0xff49)
#define rVBK  (*(volatile u8 *)0xff4f)
#define rBCPS ((volatile u8 *)0xff68)   /* +1 = BCPD */
#define rOCPS ((volatile u8 *)0xff6a)   /* +1 = OCPD */

#define RAM_PAGE (*(volatile u8 *)0x4000)  /* pSRAM page latch, under $7FC0 = $03 */
#define MARK     ((volatile u8 *)0xA414)   /* page $11: 'T', 'H', theme, ~theme, then its ramp */

extern const u8 theme_ramps[THEME_COUNT][8];  /* 02:4960, theme_ramps.c */

static void fpga_page(u8 page);
static void write_ramp(volatile u8 *sel, const u8 *ramp);

void theme(void) {
    volatile u8 *m = MARK;
    u8 t, i;

    RAM_PAGE = 0x11;
    fpga_page(3);
    if (!CFG_LOADED) {
        t = m[2];
        THEME = (m[0] == 'T' && m[1] == 'H' && t < THEME_COUNT && m[3] == (u8)~t) ? t : 0;
    } else {
        t = THEME;
        m[0] = 'T';
        m[1] = 'H';
        m[2] = t;
        m[3] = ~t;
        for (i = 0; i < 8; i++) m[4 + i] = theme_ramps[t][i];
    }
    RAM_PAGE = 0;
    fpga_page(0);

    t = THEME;
    rBGP = t ? 0x1b : 0xe4;
    rOBP0 = t ? 0x1b : 0xe4;
    rOBP1 = t ? 0xe4 : 0x1b;

    /* CGB mode only: VBK reads back $ff otherwise (cgb_init.c) */
    rVBK = 0;
    if (rVBK & 1) return;
    write_ramp(rBCPS, theme_ramps[t]);
    write_ramp(rOCPS, theme_ramps[t]);
}

/* SetFpgaPage_B4 inlined, as in ezcfg.c */
static void fpga_page(u8 page) {
    *(volatile u8 *)0x7F00 = 0xE1;
    *(volatile u8 *)0x7F10 = 0xE2;
    *(volatile u8 *)0x7F20 = 0xE3;
    *(volatile u8 *)0x7FC0 = page;
    *(volatile u8 *)0x7FF0 = 0xE4;
}

/* All 8 palettes behind sel (BCPS or OCPS) get the ramp. */
static void write_ramp(volatile u8 *sel, const u8 *ramp) {
    u8 i, c;
    for (i = 0; i < 64; i++) {
        c = ramp[i & 7];
        do {
            sel[0] = i;
            while (rSTAT & 2) {}
            sel[1] = c;
            while (rSTAT & 2) {}
        } while (sel[1] != c);
    }
}
