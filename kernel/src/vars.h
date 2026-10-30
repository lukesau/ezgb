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
/* Browser names without their tags (docs/browser-tags.md): TAGS=0 in
 * EZGB.CFG, the SET tab's TAGS checkbox off. tagtrim.c, browser_icons.c. */
#define TAGS_HIDE (*(volatile u8 *)0xDBF6)
/* Set by TagLen when it cut the name it measured, for TagCat (tagtrim.c).
 * Past FL_PATH's end ($DAFA); $DBF0-$DBF5 are FillRect's scratch. */
#define TAG_CUT   (*(volatile u8 *)0xDAFF)
/* SET tab page (flcfg.c, setpage.c): bit 0 = page 2, bit 7 = flcfg is
 * drawing. SetText draws nothing while it is exactly 1, which keeps the
 * stock rows (TIME, the date, AUTO SAVE) off page 2. Cleared when the SET
 * screen exits (SetExitHook, 04:5fb0). */
#define SET_PAGE  (*(volatile u8 *)0xDBEE)
/* SET tab re-entry (flcfg.c): the cursor row + 1 to put the cursor on when
 * the screen is entered again after a page or UI mode switch, 0 = none. */
#define SET_RE    (*(volatile u8 *)0xDBEF)

/* HRAM, mod-owned and at the same address in every kernel. Constant
 * addresses in $FF00-$FFFF compile to ldh. */
#define PAD_HELD  (*(volatile u8 *)0xFFF7)  /* buttons ReadJoypadLatched ignores until released (docs/joypad-latch.md) */
#define hClip12   (*(volatile u8 *)0xFFF9)  /* right edge of the next 12px draw or layout, 0 = x 160 */
#define HFRAME    (*(volatile u8 *)0xFFFA)  /* +1 per VBlank (VBlankPadLatch, 00:05cf) */
#define hUiMode   (*(volatile u8 *)0xFFFB)  /* 0 = 8px (16 rows), 1 = 12px (10 rows), docs/ui-mode.md; cleared at boot */
