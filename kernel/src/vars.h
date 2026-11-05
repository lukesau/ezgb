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
 * blue, 6 custom, 7 DV; the SET button steps light, dark, DV, then red ..
 * custom. THEME= in EZGB.CFG, mirrored to pSRAM page $11 $A414 for the next
 * boot's first frame (theme.c). On a color console in CGB mode a theme is
 * its row of theme_ramps.c, custom the colors of COLORS= (theme_colors.c),
 * DV dv_ramp (theme_pick.c); on a DMG, or a CGB in compatibility mode (stock
 * stage1), DV is BGP $27 and every other theme past 0 the inverted palette. */
#define THEME     (*(volatile u8 *)0xDBF7)
#define THEME_COUNT 8
#define THEME_CUSTOM 6             /* theme_ramps.c has no row for it */
/* DV, after custom so the earlier numbers stay as they are in EZGB.CFG: the
 * homage to davidesqalv's ezgb-dv fork, its 12px glyph set
 * (glyph set 1, docs/font12.md), black, lime, blue and white, the selection
 * bar and accents in lime (StoreDrawParams' DV remap, dv_params.c). */
#define THEME_DV  7
/* COLORS=RRGGBB,RRGGBB (theme_colors.c): the background and ink as read,
 * 1 once a valid line was read, and the four colors the custom theme draws
 * in (BGR555, as a theme_ramps.c row). CUST_RAMP is also loaded from the
 * pSRAM mark at boot, before the file is read. */
#define CUST_RGB  ((u8 *)0xDBE4)   /* 6: R, G, B of the background, then of the ink */
#define CUST_OK   (*(volatile u8 *)0xDBEA)
#define CUST_RAMP ((u8 *)0xDB58)   /* 8 */
/* What the jump to a game hands over (scripts/skipboot/skip_boot.asm), popped
 * as F A C B E D L H: our stage1's record of this console's boot registers,
 * else the DMG or the CGB values by PAL_LOCKED (ezcfg.c stage1_skip_mark).
 * NO_DMG: 1 when a DMG-family console must reset, an SGB or a stage1 that
 * didn't pass its registers. */
#define BOOT_REGS ((u8 *)0xDC00)   /* 8 */
#define NO_DMG    (*(volatile u8 *)0xDC08)
/* BOOTROM=1 in EZGB.CFG (theme_colors.c): every launch resets through the
 * boot ROM, never the jump to $0100 (scripts/skipboot/skip_boot.asm). */
#define BOOT_RESET (*(volatile u8 *)0xDBEB)
/* Browser names without their tags (docs/browser-tags.md): the SET tab's
 * CLEAN UP NAMES, on unless EZGB.CFG says TAGS=1 (the default since
 * 2026-10-31; TAGS=0 still reads as on). tagtrim.c, browser_icons.c. */
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
/* SET tab settings changed in RAM since the last write: SetCommit (04:5fc0)
 * writes them on NEXT, on PREV and when the screen is left
 * (docs/fastlaunch-set-tab.md). */
#define SET_DIRTY (*(volatile u8 *)0xDAFD)
/* The SET tab's cursor row as last drawn (flcfg.c), for op TICK, which has no
 * frame, and 1 when op TICK turned B on THEME into A: step back (theme_row.c). */
#define SET_CUR   (*(volatile u8 *)0xDAFC)
#define THEME_BACK (*(volatile u8 *)0xDAFB)

/* HRAM, mod-owned and at the same address in every kernel. Constant
 * addresses in $FF00-$FFFF compile to ldh. */
/* 1 once Theme (theme.c) found palette RAM locked: a DMG, or a CGB in
 * compatibility mode. Past dark only DV looks different there, so the THEME
 * button (theme_row.c) offers light, dark and DV. */
#define PAL_LOCKED (*(volatile u8 *)0xFFF8)
#define PAD_HELD  (*(volatile u8 *)0xFFF7)  /* buttons ReadJoypadLatched ignores until released (docs/joypad-latch.md) */
#define hClip12   (*(volatile u8 *)0xFFF9)  /* right edge of the next 12px draw or layout, 0 = x 160 */
#define HFRAME    (*(volatile u8 *)0xFFFA)  /* +1 per VBlank (VBlankPadLatch, 00:05cf) */
#define hUiMode   (*(volatile u8 *)0xFFFB)  /* 0 = 8px (16 rows), 1 = 12px (10 rows), docs/ui-mode.md; cleared at boot */
