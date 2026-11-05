/* SET tab rows flcfg.c has no room for (docs/fastlaunch-set-tab.md "Pages"):
 * page 2 and both pages' page row.
 *
 * Bank 4, injected at 04:6610 (04:7792 until 2026-10-31, when it needed
 * room for AUTO), near-called by flcfg.c (04:6d19). Page 2
 * holds the UI settings:
 *
 *   row 2   THEME: [ PURPLE]     ThemeRow (theme_row.c), cursor row 6
 *   row 4   FONT:     [12px]     cursor row 7 (flcfg.c ROW_UI, docs/ui-mode.md)
 *   row 6   CLEAN UP NAMES:  [ ]   cursor row 8 (docs/browser-tags.md)
 *   row 8   Game Title (USA) (Re.. the example name, scrolling (tagexample.c)
 *   row 10  SORT BY PLAYS:   [ ]   cursor row 9 (docs/stars.md)
 *   row 12  SGB BOOT:        [ ]   cursor row 10 (docs/sgb-boot.md)
 *   row 14  SKIP BOOT ROM:   [ ]   cursor row 11 (docs/skip-boot-rom.md)
 *   row 16  [< PREV]  2/2        cursor row 12
 *
 * and page 1's row 16 is `1/2 [NEXT >]` (cursor row 5), with row 14 left
 * empty. `cur` is the cursor row.
 *
 *   op 0  page 2's labels
 *   op 1  page 2's rows and its page row
 *   op 2  page 1's page row
 *   op 3  A on a page 2 checkbox: CLEAN UP NAMES and SKIP BOOT ROM toggle
 *         and set SET_DIRTY (SetCommit, 04:5fc0, saves), SORT BY PLAYS and SGB BOOT their pSRAM records
 *         (SGB BOOT: nothing when AUTO); each redraws highlighted
 *   op 4  clear the pane (y 13 down, below the tab strip's rule in either
 *         font: 8px y 8..9, 12px y 12, docs/tab-strip12.md)
 *   op 8  TIME's SET button, plain
 *
 *   SGB BOOT:          [ ]     the box at x 130, as AUTO SAVE's
 *   SGB:              AUTO     when our stage1 handles the SGB
 *
 * SGB BOOT and SORT BY PLAYS are pSRAM records (docs/sgb-boot.md,
 * docs/stars.md), read and toggled by RecFlag (rec_flag.c).
 *
 * Buttons and checkboxes are drawn as flcfg.c draws them: the box 5 px left
 * and 4 px right of the 8px text, 3 px above and 5 below; 12px, the text row
 * plus a pixel above and below.
 */

#include "types.h"
#include "draw.h"
#include "vars.h"
#include "ezcfg.h"

extern void SetFpgaPage_B4(u8 page);                                /* 04:466e: $7FC0 = page */
extern void SetText(const u8 *s, u8 len, u8 col, u8 row);           /* 04:6400, settext.c */
extern void ThemeRow(u8 op);                                        /* 04:77a0, theme_row.c */
extern void TagExample(void);                                       /* 04:7e60, tagexample.c */
extern u8 RecFlag(volatile u8 *r, u8 tag, u8 toggle);               /* 04:7f51, rec_flag.c: a pSRAM checkbox */

#define RAM_PAGE (*(volatile u8 *)0x4000)  /* pSRAM page latch, under $7FC0 = $03 */
#define SGB_REC  ((volatile u8 *)0xA400)   /* page $11: 'S', 'G', flag, ~flag */
#define SORT_REC ((volatile u8 *)0xA404)   /* page $11: 'S', 'O', flag, ~flag */

#define ROW_NEXT  5
#define ROW_THEME 6
#define ROW_UI    7
#define ROW_TAGS  8
#define ROW_SORT  9
#define ROW_SGB   10
#define ROW_BOOT  11
#define ROW_PREV  12

static void box(u8 x, u8 y, u8 on, u8 hi);
static void button(u8 hi, u8 x0, u8 y0, u8 x1, u8 y1);
static void page_row(u8 hi);
static void sgb_row(u8 hi);

void SetPage(u8 op, u8 cur) {
    StoreDrawParams(3, 0, 0);
    if (op == 0) {
        static const u8 theme_label[7] = {'T','H','E','M','E',':',0};
        static const u8 font_label[6] = {'F','O','N','T',':',0};
        static const u8 tags_label[16] = {'C','L','E','A','N',' ','U','P',' ','N','A','M','E','S',':',0};
        SetText(theme_label, 6, 0, 2);
        SetText(font_label, 5, 0, 4);
        static const u8 sort_label[15] = {'S','O','R','T',' ','B','Y',' ','P','L','A','Y','S',':',0};
        SetText(tags_label, 15, 0, 6);
        SetText(sort_label, 14, 0, 10);
        {
            static const u8 sgb_label[10] = {'S','G','B',' ','B','O','O','T',':',0};
            static const u8 sgb_short[5] = {'S','G','B',':',0};
            static const u8 boot_label[15] = {'S','K','I','P',' ','B','O','O','T',' ','R','O','M',':',0};
            if (S1_SGB) SetText(sgb_short, 4, 0, 12); else SetText(sgb_label, 9, 0, 12);
            SetText(boot_label, 14, 0, 14);
        }
        TagExample();                       /* row 8, scrolling */
    } else if (op == 1) {
        static const u8 ui8_str[5] = {' ','8','p','x',0};
        static const u8 ui12_str[5] = {'1','2','p','x',0};
        /* AUTO: a theme with one font (DV, 12px only) decides it */
        static const u8 auto_str[5] = {'A','U','T','O',0};
        ThemeRow(cur == ROW_THEME);
        button(cur == ROW_UI, 0x73, 0x1d, 0x9b, 0x29);
        SetText(THEME == THEME_DV ? auto_str : hUiMode ? ui12_str : ui8_str, 4, 15, 4);
        box(0x82, 0x30, TAGS_HIDE, cur == ROW_TAGS);
        box(0x82, 0x50, RecFlag(SORT_REC, 'O', 0), cur == ROW_SORT);
        sgb_row(cur == ROW_SGB);
        box(0x82, 0x70, !BOOT_RESET, cur == ROW_BOOT);
        page_row(cur == ROW_PREV);
    } else if (op == 2) {
        page_row(cur == ROW_NEXT);
    } else if (op == 3 && cur == ROW_SORT) {
        u8 on = RecFlag(SORT_REC, 'O', 1);
        SET_DIRTY = 1;                      /* /.ezgbplays keeps it (docs/stars.md) */
        box(0x82, 0x50, on, 1);
    } else if (op == 3 && cur == ROW_SGB) {
        if (S1_SGB) return;             /* AUTO: stage1 does it, nothing to set */
        RecFlag(SGB_REC, 'G', 1);
        sgb_row(1);
    } else if (op == 3 && cur == ROW_BOOT) {
        BOOT_RESET = BOOT_RESET ? 0 : 1;
        SET_DIRTY = 1;
        box(0x82, 0x70, !BOOT_RESET, 1);
    } else if (op == 3) {
        TAGS_HIDE = TAGS_HIDE ? 0 : 1;
        SET_DIRTY = 1;
        box(0x82, 0x30, TAGS_HIDE, 1);
        TagExample();                       /* the other name, from its start */
    } else if (op == 4) {
        StoreDrawParams(0, 0, 0);
        DrawRect(0, 0x0d, 0x9f, 0x8f, 1);   /* under the 12px rule (y 12) too */
    } else if (op == 8) {
        static const u8 set_str[4] = {'S','E','T',0};
        button(0, 0x7b, 0x0d, 0x9b, 0x19);
        SetText(set_str, 3, 16, 2);
    }
    StoreDrawParams(3, 0, 0);
}

/* Row 12: SGB BOOT's box. Our stage1 sends the SGB header itself, only on
 * an SGB, and the kernel never does: the setting has nothing to decide. */
static void sgb_row(u8 hi) {
    if (S1_SGB) {
        static const u8 auto_str[5] = {'A','U','T','O',0};
        if (hi) StoreDrawParams(0, 3, 0); else StoreDrawParams(3, 0, 0);
        SetText(auto_str, 4, 13, 12);
    } else {
        box(0x82, 0x60, RecFlag(SGB_REC, 'G', 0), hi);
    }
}

/* Row 16: PREV (page 2) or NEXT (page 1), then the page number. */
static void page_row(u8 hi) {
    static const u8 next_str[7] = {'N','E','X','T',' ','>',0};
    static const u8 prev_str[7] = {'<',' ','P','R','E','V',0};
    static const u8 nums[8] = {'1','/','2',0,'2','/','2',0};
    if (SET_PAGE & 1) {
        button(hi, 0x03, 0x7d, hUiMode ? 0x41 : 0x3b, 0x89);   /* 12px "< PREV" is wider */
        SetText(prev_str, 6, 1, 16);
    } else {
        button(hi, 0x63, 0x7d, 0x9b, 0x89);
        SetText(next_str, 6, 13, 16);
    }
    StoreDrawParams(3, 0, 0);
    SetText(nums + ((SET_PAGE & 1) << 2), 3, 9, 16);
}

/* Checkbox at pixel x, y (flcfg.c's): clear, outline (highlighted when the
 * cursor is on it), tick. */
static void box(u8 x, u8 y, u8 on, u8 hi) {
    StoreDrawParams(0, 0, 0);
    DrawRect(x, y, x + 8, y + 8, 1);
    if (hi) StoreDrawParams(1, 1, 0); else StoreDrawParams(3, 0, 0);
    DrawRect(x, y, x + 8, y + 8, 0);
    if (on) {
        StoreDrawParams(3, 3, 0);
        DrawRect(x + 2, y + 2, x + 6, y + 6, 1);
    }
}

/* A button's box in 8px coordinates, in the ink its text then uses
 * (flcfg.c's). */
static void button(u8 hi, u8 x0, u8 y0, u8 x1, u8 y1) {
    if (hi) StoreDrawParams(0, 3, 0); else StoreDrawParams(3, 0, 0);
    if (hUiMode) {
        y0 += 2;
        y1 += 3;
    }
    DrawRect(x0, y0, x1, y1, 1);
}
