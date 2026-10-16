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

/* HRAM. The macros compile to ldh. hUiMode and hClip12 are linker symbols
 * each block pins to $fffb / $fff9, so they compile to a 3-byte ld. */
#define PAD_HELD  (*(volatile u8 *)0xFFF7)  /* buttons ReadJoypadLatched ignores until released (docs/joypad-latch.md) */
#define HFRAME    (*(volatile u8 *)0xFFFA)  /* +1 per VBlank (VBlankPadLatch, 00:05cf) */
#define UI_MODE   (*(volatile u8 *)0xFFFB)  /* same byte as hUiMode */
extern volatile u8 hUiMode;                 /* $fffb: 0 = 8px (16 rows), 1 = 12px (10 rows), docs/ui-mode.md; cleared at boot */
extern volatile u8 hClip12;                 /* $fff9: right edge of the next 12px draw or layout, 0 = x 160 */
