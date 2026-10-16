/* Draw routines shared by the injected blocks: the stock kernel's 8px
 * painters in bank 0 and the mod's 12px renderer in bank 2. Each block pins
 * the ones it calls (scripts/port-mod.py REGISTRY). Include after types.h.
 *
 * browser_scroll_repaint.c declares DrawString and StoreDrawParams itself,
 * with packed arguments, so it does not include this. */

/* 8px text at tile column col, row row; len 0 = up to 17 characters. NUL is
 * drawn as a space up to len. */
extern void DrawString(const u8 *s, u8 len, u8 col, u8 row);        /* 00:08b7 */
/* Ink, paper and op for the next draw (wDrawColor/wDrawColorB/wDrawOp). */
extern void StoreDrawParams(u8 color, u8 colorB, u8 op);            /* 00:2791 */
/* Filled rectangle, pixel coords. */
extern void DrawRect(u8 x0, u8 y0, u8 x1, u8 y1, u8 fill);          /* 00:27ba */
/* Halt until the next VBlank; returns at once with the LCD off. */
extern void WaitVBlankFlag(void);                                   /* 00:0688 */

/* 12px text (draw12.c). The far entry takes three pad words; callers in
 * other banks use FarCallDrawString12, which takes the plain arguments. */
extern void DrawString12(u16 pad_thunk, u16 pad_af, u16 pad_ret, const u8 *s, u8 len, u8 col, u8 row); /* 02:7500 */
extern void FarCallDrawString12(const u8 *s, u8 len, u8 col, u8 row);   /* 00:05c0 -> 02:7500 */
/* Glyphs of s that fit the row from col, pen x of each in xs (layout12.c). */
extern u8 Fit12(u16 pad_thunk, u16 pad_af, const u8 *s, u8 len, u8 col, u8 *xs);   /* 02:7100 */
