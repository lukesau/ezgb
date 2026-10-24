/* Mod-owned WRAM and HRAM bytes that more than one block uses. A byte with
 * one owner and one user stays in that file; ezcfg's state is in ezcfg.h,
 * the name marquee's in marquee.h. Include after types.h. */

/* LastRomName's band (lastrom_name.c): 0 = the START overlay's (row 14),
 * 1 = the one at row 7 / y 56 (BACKUPSAVE prompt, ROM menu, save manager). */
#define LR_GEO    (*(volatile u8 *)0xDB3F)
/* SET tab PICK ROM armed (flcfg.c): A on a ROM in the browser captures it. */
#define FL_PICK   (*(volatile u8 *)0xDBFE)
/* Set by browser_hide.c when the listing hits its cap, cleared by browser_sort.c. */
#define LIST_CUT  (*(volatile u8 *)0xDBFA)
/* UI theme (docs/dark-mode.md): 0 light, 1 dark, 2.. red, green, purple,
 * blue. THEME= in EZGB.CFG, mirrored to pSRAM page $11 $A414 for the
 * next boot's first frame (theme.c). Every theme past 0 is a dark one: on a
 * DMG it is the inverted palette, on a color console its row of
 * theme_ramps.c. */
#define THEME     (*(volatile u8 *)0xDBF7)
#define THEME_COUNT 6

/* HRAM, mod-owned and at the same address in every kernel. Constant
 * addresses in $FF00-$FFFF compile to ldh. */
#define PAD_HELD  (*(volatile u8 *)0xFFF7)  /* buttons ReadJoypadLatched ignores until released (docs/joypad-latch.md) */
#define hClip12   (*(volatile u8 *)0xFFF9)  /* right edge of the next 12px draw or layout, 0 = x 160 */
#define HFRAME    (*(volatile u8 *)0xFFFA)  /* +1 per VBlank (VBlankPadLatch, 00:05cf) */
#define hUiMode   (*(volatile u8 *)0xFFFB)  /* 0 = 8px (16 rows), 1 = 12px (10 rows), docs/ui-mode.md; cleared at boot */
