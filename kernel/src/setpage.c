/* SET tab rows flcfg.c has no room for (docs/fastlaunch-set-tab.md "Pages"):
 * page 2 and every page's page row.
 *
 * Bank 4, injected at 04:6610 (04:7792 until 2026-10-31, when it needed
 * room for AUTO), near-called by flcfg.c (04:6d19). Page 2
 * holds the browser and launch settings (THEME and FONT were its first two
 * rows until page 3, themepage.c, took them):
 *
 *   row 2   CLEAN UP NAMES:  [ ]   cursor row 7 (docs/browser-tags.md)
 *   row 4   Game Title (USA) (Re.. the example name, scrolling (tagexample.c)
 *   row 6   SORT BY PLAYS:   [ ]   cursor row 8 (docs/stars.md)
 *   row 8   SGB BOOT:        [ ]   cursor row 9 (docs/sgb-boot.md)
 *   row 10  SKIP BOOT ROM:   [ ]   cursor row 10 (docs/skip-boot-rom.md)
 *   row 16  [< PREV] 2/3 [NEXT >]  cursor rows 11 and 12
 *
 * Page 1's row 16 is `1/3 [NEXT >]` (cursor row 6); its row 14 is DAILY
 * BACKUP, cursor row 5. Page 3's is `[< PREV] 3/3` (cursor row 18). `cur` is
 * the cursor row.
 *
 *   op 0  page 2's labels
 *   op 1  page 2's rows and its page row
 *   op 2  page 1's DAILY BACKUP row and its page row
 *   op 3  A on a page 2 row: CLEAN UP NAMES and SKIP BOOT ROM toggle
 *         and set SET_DIRTY (SetCommit, 04:5fc0, saves), SORT BY PLAYS and SGB BOOT their pSRAM records
 *         (SGB BOOT: nothing when AUTO); each redraws highlighted
 *   op 4  clear the pane (y 13 down, below the tab strip's rule in either
 *         font: 8px y 8..9, 12px y 12, docs/tab-strip12.md)
 *   op 5  page 3's page row
 *   op 6  A on NEXT or PREV (cur): write what changed (SetCommit), step
 *         SET_PAGE, clear the pane, and leave the cursor row for the
 *         re-entry in SET_RE: the button that goes on the same way, or the
 *         page's only one (page 3 has only PREV, page 1 only NEXT)
 *   op 8  TIME's SET button, plain
 *
 *   SGB BOOT:          [ ]     the box at x 130, as AUTO SAVE's
 *   SGB:              AUTO     when our stage1 handles the SGB
 *
 * SGB BOOT and SORT BY PLAYS are pSRAM records (docs/sgb-boot.md,
 * docs/stars.md), read and toggled by RecFlag (rec_flag.c).
 *
 *   SKIP BOOT ROM:     [x]   jump when this console and game allow it
 *   SKIP BOOT ROM:     [ ]   BOOTROM=1, or this console can't jump (A does nothing)
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
extern void SetCommit(void);                                        /* 04:5fc0: SET_DIRTY -> EZGB.CFG and /.ezgbplays */
extern void TagExample(void);                                       /* 04:7e60, tagexample.c */
extern u8 RecFlag(volatile u8 *r, u8 tag, u8 toggle);               /* 04:7f51, rec_flag.c: a pSRAM checkbox */

#define RAM_PAGE (*(volatile u8 *)0x4000)  /* pSRAM page latch, under $7FC0 = $03 */
#define SGB_REC  ((volatile u8 *)0xA400)   /* page $11: 'S', 'G', flag, ~flag */
#define SORT_REC ((volatile u8 *)0xA404)   /* page $11: 'S', 'O', flag, ~flag */

#define ROW_BK    5
#define ROW_NEXT  6
#define ROW_TAGS  7
#define ROW_SORT  8
#define ROW_SGB   9
#define ROW_BOOT  10
#define ROW_PREV  11
#define ROW_NEXT2 12
#define ROW_PREV3 18

#define Y_TAGS 0x10          /* the checkboxes: 8 x the row */
#define Y_SORT 0x30
#define Y_SGB  0x40
#define Y_BOOT 0x50

static void box(u8 x, u8 y, u8 on, u8 hi);
static void button(u8 hi, u8 x0, u8 y0, u8 x1, u8 y1);
static void page_row(u8 cur);
static void sgb_row(u8 hi);
static void boot_row(u8 hi);
static u8 can_jump(void);

void SetPage(u8 op, u8 cur) {
    StoreDrawParams(3, 0, 0);
    if (op == 0) {
        static const u8 tags_label[16] = {'C','L','E','A','N',' ','U','P',' ','N','A','M','E','S',':',0};
        static const u8 sort_label[15] = {'S','O','R','T',' ','B','Y',' ','P','L','A','Y','S',':',0};
        SetText(tags_label, 15, 0, 2);
        SetText(sort_label, 14, 0, 6);
        {
            static const u8 sgb_label[10] = {'S','G','B',' ','B','O','O','T',':',0};
            static const u8 sgb_short[5] = {'S','G','B',':',0};
            static const u8 boot_label[15] = {'S','K','I','P',' ','B','O','O','T',' ','R','O','M',':',0};
            if (S1_SGB) SetText(sgb_short, 4, 0, 8); else SetText(sgb_label, 9, 0, 8);
            SetText(boot_label, 14, 0, 10);
        }
        TagExample();                       /* row 4, scrolling */
    } else if (op == 1) {
        box(0x82, Y_TAGS, TAGS_HIDE, cur == ROW_TAGS);
        box(0x82, Y_SORT, RecFlag(SORT_REC, 'O', 0), cur == ROW_SORT);
        sgb_row(cur == ROW_SGB);
        boot_row(cur == ROW_BOOT);
        page_row(cur);
    } else if (op == 2) {
        {
            static const u8 bk_label[14] = {'D','A','I','L','Y',' ','B','A','C','K','U','P',':',0};
            SetText(bk_label, 13, 0, 14);
            box(0x82, 0x70, BK_DAILY, cur == ROW_BK);
        }
        page_row(cur);
    } else if (op == 5) {
        page_row(cur);
    } else if (op == 6) {
        SetCommit();
        if (cur == ROW_NEXT || cur == ROW_NEXT2) {
            SET_PAGE++;
            SET_RE = (cur == ROW_NEXT ? ROW_NEXT2 : ROW_PREV3) + 1;
        } else {
            SET_PAGE--;
            SET_RE = (cur == ROW_PREV ? ROW_NEXT : ROW_PREV) + 1;
        }
        StoreDrawParams(0, 0, 0);
        DrawRect(0, 0x0d, 0x9f, 0x8f, 1);
    } else if (op == 3 && cur == ROW_SORT) {
        u8 on = RecFlag(SORT_REC, 'O', 1);
        SET_DIRTY = 1;                      /* /.ezgbplays keeps it (docs/stars.md) */
        box(0x82, Y_SORT, on, 1);
    } else if (op == 3 && cur == ROW_SGB) {
        if (S1_SGB) return;             /* AUTO: stage1 does it, nothing to set */
        RecFlag(SGB_REC, 'G', 1);
        sgb_row(1);
        boot_row(0);                    /* under stock stage1 it decides the DMG family */
    } else if (op == 3 && cur == ROW_BOOT) {
        if (!can_jump()) return;
        BOOT_RESET = BOOT_RESET ? 0 : 1;
        SET_DIRTY = 1;
        boot_row(1);
    } else if (op == 3) {
        TAGS_HIDE = TAGS_HIDE ? 0 : 1;
        SET_DIRTY = 1;
        box(0x82, Y_TAGS, TAGS_HIDE, 1);
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

/* Row 8: SGB BOOT's box. Our stage1 sends the SGB header itself, only on
 * an SGB, and the kernel never does: the setting has nothing to decide. */
static void sgb_row(u8 hi) {
    if (S1_SGB) {
        static const u8 auto_str[5] = {'A','U','T','O',0};
        if (hi) StoreDrawParams(0, 3, 0); else StoreDrawParams(3, 0, 0);
        SetText(auto_str, 4, 13, 8);
    } else {
        box(0x82, Y_SGB, RecFlag(SGB_REC, 'G', 0), hi);
    }
}

/* What SkipBoot (scripts/skipboot/skip_boot.asm) will decide for this console,
 * whatever the game: a CGB mode can jump, a compatibility mode can't, and the
 * DMG family can unless it may be an SGB. */
static u8 can_jump(void) {
    if (!PAL_LOCKED) return 1;
    if (!DMG_FAM) return 0;             /* a color console */
    if (NO_DMG) return 0;
    return S1_SGB || !RecFlag(SGB_REC, 'G', 0);
}

/* Row 10: ticked when launches may jump. BOOT_RESET keeps its value while this
 * console can't jump, so a card moved to one that can still has it. */
static void boot_row(u8 hi) {
    box(0x82, Y_BOOT, can_jump() && !BOOT_RESET, hi);
}

/* Row 16: PREV on pages 2 and 3, NEXT on pages 1 and 2, the page number
 * between them. `cur` highlights the one the cursor is on. */
static void page_row(u8 cur) {
    static const u8 next_str[7] = {'N','E','X','T',' ','>',0};
    static const u8 prev_str[7] = {'<',' ','P','R','E','V',0};
    u8 num[4];
    u8 p = SET_PAGE & 3;
    if (p) {
        button(cur == ROW_PREV || cur == ROW_PREV3, 0x03, 0x7d, hUiMode ? 0x41 : 0x3b, 0x89);   /* 12px "< PREV" is wider */
        SetText(prev_str, 6, 1, 16);
    }
    if (p != 2) {
        button(cur == ROW_NEXT || cur == ROW_NEXT2, 0x63, 0x7d, 0x9b, 0x89);
        SetText(next_str, 6, 13, 16);
    }
    StoreDrawParams(3, 0, 0);
    num[0] = '1' + p;
    num[1] = '/';
    num[2] = '3';
    num[3] = 0;
    SetText(num, 3, 9, 16);
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
