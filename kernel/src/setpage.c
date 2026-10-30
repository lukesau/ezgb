/* SET tab rows flcfg.c has no room for (docs/fastlaunch-set-tab.md "Pages"):
 * page 1's SGB BOOT row, page 2, and both pages' page row.
 *
 * Bank 4, injected at 04:7792, near-called by flcfg.c (04:6600). Page 2
 * holds the UI settings:
 *
 *   row 2   THEME: [ PURPLE]     ThemeRow (theme_row.c), cursor row 7
 *   row 4   FONT:     [12px]     cursor row 8 (flcfg.c ROW_UI, docs/ui-mode.md)
 *   row 6   SHOW NAME TAGS:  [x]   cursor row 9 (docs/browser-tags.md)
 *   row 8   Ex: Game Title (USA)..  the example name, scrolling (tagexample.c)
 *   row 16  [< PREV]  2/2        cursor row 10
 *
 * and page 1 ends in SGB BOOT on row 14 (cursor row 5) and `1/2 [NEXT >]`
 * on row 16 (cursor row 6). `cur` is the cursor row.
 *
 *   op 0  page 2's labels
 *   op 1  page 2's rows and its page row
 *   op 2  page 1's page row
 *   op 3  A on TAGS: toggle TAGS_HIDE, save EZGB.CFG, redraw it highlighted
 *   op 4  clear the pane (y 13 down, below the tab strip's rule in either
 *         font: 8px y 8..9, 12px y 12, docs/tab-strip12.md)
 *   op 5  SGB BOOT's label
 *   op 6  SGB BOOT's box
 *   op 7  A on SGB BOOT: toggle the pSRAM record (nothing when AUTO), redraw
 *   op 8  TIME's SET button, plain
 *
 *   SGB BOOT:          [ ]     the box at x 130, as AUTO SAVE's
 *   SGB:              AUTO     when our stage1 handles the SGB
 *
 * SGB BOOT is a pSRAM record (docs/sgb-boot.md), mapped the way the kernel
 * maps page $11 for its AUTO SAVE flag (04:58d6): page latch, $7FC0 = $03,
 * access, then both back to 0, where the SET screen rests.
 *
 * Buttons and checkboxes are drawn as flcfg.c draws them: the box 5 px left
 * and 4 px right of the 8px text, 3 px above and 5 below; 12px, the text row
 * plus a pixel above and below.
 */

#include "types.h"
#include "draw.h"
#include "vars.h"
#include "ezcfg.h"

extern void FarCallEzCfg(void);                                     /* 04:5f00 -> ezcfg (02:4a00) */
extern void SetFpgaPage_B4(u8 page);                                /* 04:466e: $7FC0 = page */
extern void SetText(const u8 *s, u8 len, u8 col, u8 row);           /* 04:6400, settext.c */
extern void ThemeRow(u8 op);                                        /* 04:7670, theme_row.c */
extern void TagExample(void);                                       /* 04:7e60, tagexample.c */

#define RAM_PAGE (*(volatile u8 *)0x4000)  /* pSRAM page latch, under $7FC0 = $03 */
#define SGB_REC  ((volatile u8 *)0xA400)   /* page $11: 'S', 'G', flag, ~flag */

#define ROW_SGB   5
#define ROW_NEXT  6
#define ROW_THEME 7
#define ROW_UI    8
#define ROW_TAGS  9
#define ROW_PREV  10

static void box(u8 x, u8 y, u8 on, u8 hi);
static void button(u8 hi, u8 x0, u8 y0, u8 x1, u8 y1);
static void page_row(u8 hi);
static u8 sgb_get(void);
static void sgb_set(u8 on);

void SetPage(u8 op, u8 cur) {
    StoreDrawParams(3, 0, 0);
    if (op == 0) {
        static const u8 theme_label[7] = {'T','H','E','M','E',':',0};
        static const u8 font_label[6] = {'F','O','N','T',':',0};
        static const u8 tags_label[16] = {'S','H','O','W',' ','N','A','M','E',' ','T','A','G','S',':',0};
        SetText(theme_label, 6, 0, 2);
        SetText(font_label, 5, 0, 4);
        SetText(tags_label, 15, 0, 6);
        TagExample();                       /* row 8, scrolling */
    } else if (op == 1) {
        static const u8 ui8_str[5] = {' ','8','p','x',0};
        static const u8 ui12_str[5] = {'1','2','p','x',0};
        ThemeRow(cur == ROW_THEME);
        button(cur == ROW_UI, 0x73, 0x1d, 0x9b, 0x29);
        SetText(hUiMode ? ui12_str : ui8_str, 4, 15, 4);
        box(0x82, 0x30, !TAGS_HIDE, cur == ROW_TAGS);
        page_row(cur == ROW_PREV);
    } else if (op == 2) {
        page_row(cur == ROW_NEXT);
    } else if (op == 3) {
        TAGS_HIDE = TAGS_HIDE ? 0 : 1;
        EZ_OP = OP_SAVE;
        FarCallEzCfg();
        box(0x82, 0x30, !TAGS_HIDE, 1);
        TagExample();                       /* the other name, from its start */
    } else if (op == 4) {
        StoreDrawParams(0, 0, 0);
        DrawRect(0, 0x0d, 0x9f, 0x8f, 1);   /* under the 12px rule (y 12) too */
    } else if (op == 5) {
        static const u8 sgb_label[10] = {'S','G','B',' ','B','O','O','T',':',0};
        static const u8 sgb_short[5] = {'S','G','B',':',0};
        if (S1_SGB) SetText(sgb_short, 4, 0, 14); else SetText(sgb_label, 9, 0, 14);
    } else if (op == 8) {
        static const u8 set_str[4] = {'S','E','T',0};
        button(0, 0x7b, 0x0d, 0x9b, 0x19);
        SetText(set_str, 3, 16, 2);
    } else {
        if (op == 7) {
            if (S1_SGB) return;         /* AUTO: stage1 does it, nothing to set */
            sgb_set(!sgb_get());
            cur = ROW_SGB;
        }
        if (S1_SGB) {
            /* our stage1 sends the SGB header itself, only on an SGB, and
             * the kernel never does: the setting has nothing to decide */
            static const u8 auto_str[5] = {'A','U','T','O',0};
            if (cur == ROW_SGB) StoreDrawParams(0, 3, 0);
            SetText(auto_str, 4, 13, 14);
        } else {
            box(0x82, 0x70, sgb_get(), cur == ROW_SGB);
        }
    }
    StoreDrawParams(3, 0, 0);
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

static u8 sgb_get(void) {
    u8 on;
    RAM_PAGE = 0x11;
    SetFpgaPage_B4(3);
    on = SGB_REC[0] == 'S' && SGB_REC[1] == 'G' && SGB_REC[2] == 1 && SGB_REC[3] == 0xFE;
    RAM_PAGE = 0;
    SetFpgaPage_B4(0);
    return on;
}

static void sgb_set(u8 on) {
    RAM_PAGE = 0x11;
    SetFpgaPage_B4(3);
    SGB_REC[0] = 'S';
    SGB_REC[1] = 'G';
    SGB_REC[2] = on;
    SGB_REC[3] = ~on;
    RAM_PAGE = 0;
    SetFpgaPage_B4(0);
}
