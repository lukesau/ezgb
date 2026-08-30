/* Bottom-up repaint for the down-scroll.
 *
 * The stock dirty=1 full repaint (DrawBrowserEntries) sweeps rows top to
 * bottom, so on a down-scroll the newly revealed entry — the one the user
 * pressed DOWN to see — is painted last, a visible beat after the press.
 * This wrapper sits between the BrowserScrollDownHook stub (00:02e0) and
 * browser_scroll_down: when the scroll shifts the window (dirty = 1) it
 * takes the repaint over entirely and paints in reverse:
 *
 *   1. DrawBrowserDetail(base, 15, mode 2) via the FarCallDrawDetailBottom
 *      shim — the same two-row primitive the in-screen cursor moves use.
 *      It draws row 14 un-highlighted and the new bottom entry highlighted,
 *      and its epilogue draws the selection-number field as base+row+1 =
 *      base+16, which is exactly right for sel=15. (That number is also why
 *      the helper can't simply be iterated over all eight row pairs: every
 *      call prints base+row+1, so the field would flash wrong values and
 *      finish on base+1.)
 *   2. Rows 13 down to 0 one at a time with the stock drawing primitives,
 *      replicating DrawBrowserEntries' per-row body byte for byte:
 *      dir rows DrawString(name, len 0, col 0) + StoreDrawParams(0, 3) +
 *      "DIR" at col $11; file rows DrawString(name, len $14, col 0).
 *      No ink handling is needed: DrawBrowserDetail's epilogue leaves ink
 *      normal (StoreDrawParams(3, 0) before the number), and rows 0..13 are
 *      never the selection during a window shift (sel is pinned at 15).
 *
 * dirty is then cleared so FileBrowserEntry's own redraw does nothing; the
 * one side effect of its dirty!=0 path — zeroing the 32-bit marquee tick at
 * frame sp+$0a..$0d — is replicated here (the hook's state pointer is
 * frame sp+$12, so the tick sits at st-8; see browser_scroll_shims.md for
 * the frame map).
 *
 * The "DIR" tag string is duplicated here because BrowserDirStr lives in
 * bank 1 and this code runs with bank 0 + the record's PSRAM bank mapped.
 *
 * Scroll UP is untouched: its new entry appears at the top, which the stock
 * top-down sweep already paints first. In-screen moves (dirty = 2) and the
 * end-of-list no-op keep stock behaviour too.
 *
 * Wired by retargeting the call in the 00:02e0 stub from browser_scroll_down
 * to this function. Lives in the 00:3d8c cave.
 */

typedef unsigned char u8;
typedef unsigned int u16;

struct BrowserScrollState {
    u8 dirty;
    u16 base;
    u8 sel;
};

extern void browser_scroll_down(struct BrowserScrollState *st); /* 00:01e3 */
extern void FarCallDrawDetailBottom(u16 base);                  /* 00:03dc */
extern void DrawString(volatile const u8 *s, u8 len, u8 col, u8 row); /* 00:08b7 */
extern void StoreDrawParams(u8 idx, u16 val);                   /* 00:2791 */

#define RAM_BANK (*(volatile u8 *)0x4000)
#define WIN ((volatile u8 *)0xa000)
#define REC_BANK_BASE 0x12
#define ATTR_OFS 254
#define ATTR_DIR 0x10

static void draw_row(u16 base, u8 n);
static void fpga_sram_page(void);

static const u8 dir_tag[] = "DIR";

void browser_scroll_down_repaint(struct BrowserScrollState *st) {
    u8 n;
    volatile u8 *tick;

    browser_scroll_down(st);
    if (st->dirty != 1) {
        return;
    }

    st->dirty = 0;
    tick = (volatile u8 *)st - 8;
    tick[0] = 0;
    tick[1] = 0;
    tick[2] = 0;
    tick[3] = 0;

    fpga_sram_page();
    FarCallDrawDetailBottom(st->base);
    for (n = 14; n--;) {
        draw_row(st->base, n);
    }
}

static void draw_row(u16 base, u8 n) {
    u16 idx = base + n;
    u16 slot = idx & 31;
    volatile u8 *rec;
    u8 row = n + 2;

    RAM_BANK = (u8)(REC_BANK_BASE + (u8)(idx >> 5));
    rec = WIN + ((slot << 8) - slot); /* slot * 255 */
    if (rec[ATTR_OFS] == ATTR_DIR) {
        DrawString(rec, 0, 0, row);
        StoreDrawParams(0, 0x0003);
        DrawString(dir_tag, 3, 0x11, row);
    } else {
        DrawString(rec, 0x14, 0, row);
    }
}

/* SetFpgaPageAlt_B4 (04:41e7) inlined: DrawBrowserDetail and the record
 * reads need the PSRAM window on page $03, and the stock dirty>=2 path
 * farcalls this before the helper. */
static void fpga_sram_page(void) {
    *(volatile u8 *)0x7f00 = 0xe1;
    *(volatile u8 *)0x7f10 = 0xe2;
    *(volatile u8 *)0x7f20 = 0xe3;
    *(volatile u8 *)0x7fc0 = 0x03;
    *(volatile u8 *)0x7ff0 = 0xe4;
}
