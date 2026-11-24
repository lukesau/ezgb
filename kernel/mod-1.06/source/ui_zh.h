/* ============================================================================
   ui_zh.h  -  12px text renderer for the Chinese build (LANG=zh)
   ----------------------------------------------------------------------------
   Why APA instead of a hand-built tile pool: a BG map entry is an 8-bit tile
   index, so at most 256 distinct tiles can be referenced on screen and the GBDK
   console font owns tiles 0-95. GBDK's drawing library maps the 144 pixel rows
   onto two tile sets via y_table and switches them at scanline 72 with the LCD
   interrupt, trading time for space - a full 160px width still fits 9 rows of
   12px text. The cost is slower per-pixel drawing and the LCD interrupt.

   Geometry: list area y = ZH_TOP + row*ZH_PITCH, full width 0..159.
   Everything is drawn straight into VRAM, so there is no shadow buffer to
   flush; the selected row is marked with a 1px frame (zh_frame).
   ========================================================================== */
#ifndef UI_ZH_H
#define UI_ZH_H

#include <gb/gb.h>

/* ---- list geometry (pixels) ----
   The zh build uses GBDK's APA per-pixel drawing (drawing.h), like 1.05c:
   the library maps the upper/lower half onto different tiles via y_table and
   switches them at scanline 72, so 160px of width still fits (no 256-tile limit).
   The cost is slower drawing and the LCD/VBlank interrupt. */
#define ZH_TOP        17          /* y of the first text row: 12px tabs plus the double line at y13/14 */
#define ZH_PITCH      14          /* row pitch: 12px glyphs + 2px gap (frame lines fall in the gap) */
#define ZH_ROWS       9           /* visible rows: 9*14=126px, y17..142 */
#define ZH_COLS       20          /* 20 cells of 8 pixels across = 160 pixels */
#define ZH_X_END      160         /* usable pixel width of one row */
#define ZH_MARK_W     6           /* width of the selection cursor in pixels */
#define ZH_TEXT_X     8           /* text start x: 8 pixels on the left are left for the cursor */
#define ZH_MAP_COLS   20U         /* kept for old references, meaningless under APA */

#define ZH_ASC_W      6           /* ASCII advance */
#define ZH_HZ_W       16          /* CJK advance */

/* ---- API ---- */
/* The only function in bank 0: switch to the font bank and copy 24 bytes to RAM.
   Plain call, no __banked: after the switch only bank 0 code is still mapped. */
void zh_fetch(UINT8 page, UINT16 off, UINT8 *dst);

/* Build the list tilemap (once per screen entry), mapping tiles to rows x cols */
void zh_screen_init(void) __banked;

/* Draw one text row at the list geometry (row 0 = ZH_TOP); the ASCII variant
   uses the 6x12 glyphs only, with no CJK lookup */
UINT8 zh_row_text(UINT8 row, UINT8 x, const UINT8 *s, UINT8 x_limit) __banked;
UINT8 zh_row_ascii(UINT8 row, UINT8 x, const UINT8 *s, UINT8 x_limit) __banked;

/* Fill a band at any y / left cursor (the recent list has its own pitch) */
void zh_clear_band(UINT8 y, UINT8 h) __banked;

/* Double black line under the tabs (rows y and y+1) */
void zh_rule(UINT8 y) __banked;

/* 1px frame / solid block / white on black (plot_point or palette control) */
void zh_frame(UINT8 x0, UINT8 y0, UINT8 x1, UINT8 y1) __banked;
void zh_fill_black(UINT8 x0, UINT8 y0, UINT8 x1, UINT8 y1) __banked;
void zh_fill_grey(UINT8 x0, UINT8 y0, UINT8 x1, UINT8 y1) __banked;
void zh_fill_white(UINT8 x0, UINT8 y0, UINT8 x1, UINT8 y1) __banked;
void zh_fill_flat(UINT8 x0, UINT8 y0, UINT8 x1, UINT8 y1) __banked;

/* Three tab cells plus the thick line at y14. active=0/1/2 = SD/SET/HELP.
   Layout follows the old UI.c: the active page is white, the others dark grey. */
void zh_tabbar(UINT8 active) __banked;
void zh_frame_erase(UINT8 x0, UINT8 y0, UINT8 x1, UINT8 y1) __banked;
UINT8 zh_ascii_inv(UINT8 y, UINT8 x, const UINT8 *s, UINT8 x_limit) __banked;
void zh_field_inv(UINT8 x, UINT8 y, const UINT8 *s, UINT8 chars) __banked;

/* Flush the whole list area into VRAM */
void zh_flush_all(void) __banked;

/* Drawing at an arbitrary y (the recent list does not start at ZH_TOP) */
/* ASCII stand-in for a GBK punctuation mark (0 = draw nothing). Marks in GB2312
   rows 1-15 are never taken from the font: that data is misaligned in the blob. */
UINT8 zh_punct(UINT8 c1, UINT8 c2) __banked;
UINT8 zh_text_at(UINT8 y, UINT8 x, const UINT8 *s, UINT8 x_limit) __banked;
UINT8 zh_ascii_at(UINT8 y, UINT8 x, const UINT8 *s, UINT8 x_limit) __banked;

/* ---- Draw_Text's zh implementation (single entry point) --------------------
   main.c's Draw_Text always dispatches here in the zh build: console call
   semantics (tile x/y, len as coverage width, len==0 = 17 cells, the
   color(BLACK,DKGREY) background trick) become 12px APA. The console path is not
   compiled in the zh build: on the graphics canvas wrtchr writes glyphs into the
   wrong tile for rows >= 9, which corrupted dialogs and the boot "save?" box.
   mode(M_TEXT_OUT)+cls is gone too: the zh build stays in graphics mode from
   boot. str must point into WRAM: main.c copies it onto the stack first. */
void zh_text_row(UINT8 y, UINT8 x, const UINT8 *str, UINT8 len) __banked;

/* Fill full-width rows with white (also clears the grey-background record).
   Replaces box(...,M_FILL) for screen/list clears: 23,000 plot calls before. */
void zh_fill_white_rows(UINT8 y0, UINT8 y1) __banked;

/* Recently played list (APA, renders Chinese names) */
void list_zh_recent(UINT8 count, UINT8 sel) __banked;
/* Redraw the window: entries top..top+ZH_RECENT_ROWS-1 into rows 0..8 */
void list_zh_recent_window(UINT8 count, UINT8 top, UINT8 sel) __banked;
/* Redraw only the two rows touched by a cursor move (per-pixel drawing is slow) */
void list_zh_recent_refresh(UINT8 top, UINT8 old_sel, UINT8 new_sel) __banked;

/* Visible rows in the recent list: up to RECENT_MAX (14) records; beyond 9
   main.c scrolls the window (list_zh_recent_window). */
#define ZH_RECENT_ROWS 9

/* ---- list (called from Bank_fun.c / main.c zh branches; see list_zh.c) ---- */
void list_zh_show(UINT16 show_offset, UINT16 file_select) __banked;
void list_zh_refresh(UINT16 show_offset, UINT16 file_select, UINT8 updown) __banked;
void list_zh_loop(UINT32 shift, UINT16 show_offset, UINT16 file_select) __banked;

#endif /* UI_ZH_H */
