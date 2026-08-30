/* RIGHT on the last page jumps the cursor to the bottom of the list.
 *
 * Stock behaviour is asymmetric: LEFT on the first page moves the cursor to
 * the top (FileBrowserEntry_pageDecGate: base == 0, sel != 0 -> sel = 0,
 * dirty = 1), but RIGHT when the window already shows the tail of the list
 * (base + 16 >= count) just falls out to the wait loop and does nothing.
 * This is that missing mirror: same trigger, cursor to the last visible
 * row, same full-page dirty as the LEFT gate.
 *
 * Hooked at the `jp nc, MenuDispatchAB_waitVBlankLoop` that ends the
 * FileBrowserEntry_pageInc bounds check (00:1195): its operand is repointed
 * to a frame-preserving stub (00:03f4, browser_scroll_shims.md pattern)
 * that passes &frame.dirty here and then jumps to the wait loop itself.
 * The nc branch is taken exactly when base + 16 >= count, so `count - base`
 * is the visible row count (at most 16) whenever count is nonzero.
 */

typedef unsigned char u8;
typedef unsigned int u16;

#define ENTRY_COUNT (*(volatile u16 *)0xc2a2)

struct BrowserScrollState {
    u8 dirty;
    u16 base;
    u8 sel;
};

void browser_page_end(struct BrowserScrollState *st) {
    u16 rows = ENTRY_COUNT;
    u8 last;

    if (rows == 0) {
        return;
    }
    rows -= st->base;
    if (rows > 16) {
        rows = 16; /* unreachable at this hook; guards a stray caller */
    }
    last = (u8)rows - 1;
    if (st->sel != last) {
        st->sel = last;
        st->dirty = 1;
    }
}
