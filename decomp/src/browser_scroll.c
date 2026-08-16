/* Continuous scrolling for the file browser's DOWN/UP keys.
 *
 * Stock behaviour: DOWN stops dead at the bottom row (sel == $0f,
 * bank_000.asm:4038) and UP stops at the top. Moving past a screenful is only
 * possible via LEFT/RIGHT, which page by 16 and are undiscoverable. This makes
 * DOWN/UP scroll the window one line at a time instead.
 *
 * Called from the two asm stubs in browser_scroll_shims.md, which pass a
 * pointer to the live FileBrowserEntry stack frame. Those slots are
 * contiguous, so they map to a struct:
 *
 *   sp+$12  dirty   redraw code: 0 none, 1 full page, 2 row-down, 3 row-up
 *   sp+$13  base    first visible entry index (u16, spans sp+$13..$14)
 *   sp+$15  sel     selected row within the window, 0..15
 *
 * Entries live in cart FRAM (page $12 + (idx >> 5), record at
 * $A000 + 255 * (idx & $1f)), not WRAM, and are never evicted — so scrolling
 * UP never touches the SD card. Only scrolling DOWN past what has been
 * enumerated so far needs another DirList batch.
 *
 * Nothing downstream requires `base` to be a multiple of 16:
 * DrawBrowserEntries clamps its row count to min(count - base, 16) and indexes
 * entries as base + i, and DrawBrowserDetail / MenuDispatchAB_bankEntry use
 * base + sel. Scrolling therefore just moves `base` off its old 16-alignment.
 */

/* Streams the next batch of up to 16 entries into cart FRAM and advances the
 * count. Resumes from the persistent DIR object at $c9f5 — never rewinds. */
extern void DirList(void);

#define ROWS 16 /* visible list rows; matches the sel cap at bank_000.asm:4038 */

/* Total entries enumerated so far. NOT the directory's true size: it only
 * grows as DirList streams more in. */
#define ENTRY_COUNT (*(volatile unsigned int *)0xc2a2)

/* Sticky "readdir returned no more entries" latch, set in DirList_failEmpty
 * (bank_000.asm:2588) and cleared once per browser entry. Without honouring
 * it, every DOWN press at a true end-of-list would re-run a doomed readdir. */
#define END_OF_DIR (*(volatile unsigned char *)0xc5a4)

struct BrowserScrollState {
    unsigned char dirty;
    unsigned int base;
    unsigned char sel;
};

void browser_scroll_down(struct BrowserScrollState *st) {
    unsigned int base = st->base;
    unsigned char sel = st->sel;

    if (sel + 1 < ROWS) {
        /* Still room on screen. Stock checked sel+1 against the count without
         * adding base, which only held while base stayed 16-aligned; now that
         * scrolling makes base arbitrary, the absolute index is required. */
        if (base + sel + 1 < ENTRY_COUNT) {
            st->sel = sel + 1;
            st->dirty = 2;
        }
        return;
    }

    /* On the bottom row: scroll the window down by one, streaming another
     * batch first if we have not enumerated that far yet. */
    if (base + ROWS >= ENTRY_COUNT) {
        if (END_OF_DIR) {
            return;
        }
        DirList();
        if (base + ROWS >= ENTRY_COUNT) {
            return;
        }
    }
    st->base = base + 1;
    st->dirty = 1;
}

void browser_scroll_up(struct BrowserScrollState *st) {
    unsigned char sel = st->sel;

    if (sel != 0) {
        st->sel = sel - 1;
        st->dirty = 3;
        return;
    }
    if (st->base != 0) {
        st->base = st->base - 1;
        st->dirty = 1;
    }
}
