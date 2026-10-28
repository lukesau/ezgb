/* SET tab row 16: the SGB BOOT and TAGS checkboxes (docs/sgb-boot.md,
 * docs/browser-tags.md).
 *
 * Bank 4, injected at 04:77a0, near-called by flcfg.c (04:6600), which
 * outgrew its slot when the TAGS box was added, the way ThemeRow
 * (theme_row.c) holds the THEME button. Cursor rows 7 (SGB BOOT) and 8
 * (TAGS, flcfg.c ROW_SGB / ROW_TAGS).
 *
 *   op 0  draw both boxes plain
 *   op 1  the cursor is on SGB BOOT
 *   op 2  the cursor is on TAGS
 *   op 3  A on SGB BOOT: toggle the pSRAM record (nothing when AUTO), redraw
 *   op 4  A on TAGS: toggle TAGS_HIDE, save EZGB.CFG, redraw
 *   op 5  the labels (once, at SET entry)
 *
 *   SGB BOOT: [ ]  TAGS: [x]     8px: "SGB BOOT:" cols 0-8, box x 74
 *                                (68 in 12px); "TAGS:" cols 11-15, box x 130
 *   SGB: AUTO      TAGS: [x]     when our stage1 handles the SGB: "SGB:"
 *                                and AUTO from col 5 (12px x 34..86)
 *
 * SGB BOOT is a pSRAM record, mapped the way the kernel maps page $11 for
 * its AUTO SAVE flag (04:58d6): page latch, $7FC0 = $03, access, then both
 * back to 0, where the SET screen rests. TAGS is an EZGB.CFG key.
 */

#include "types.h"
#include "draw.h"
#include "vars.h"
#include "ezcfg.h"

extern void FarCallEzCfg(void);                                     /* 04:5f00 -> ezcfg (02:4a00) */
extern void SetFpgaPage_B4(u8 page);                                /* 04:466e: $7FC0 = page */
extern void SetText(const u8 *s, u8 len, u8 col, u8 row);           /* 04:6400, settext.c */

#define RAM_PAGE (*(volatile u8 *)0x4000)  /* pSRAM page latch, under $7FC0 = $03 */
#define SGB_REC  ((volatile u8 *)0xA400)   /* page $11: 'S', 'G', flag, ~flag */

static void box(u8 x, u8 y, u8 on, u8 hi);
static u8 sgb_get(void);
static void sgb_set(u8 on);

void SgbTagsRow(u8 op) {
    if (op == 5) {
        static const u8 sgb_label[10] = {'S','G','B',' ','B','O','O','T',':',0};
        static const u8 sgb_short[5] = {'S','G','B',':',0};
        static const u8 tags_label[6] = {'T','A','G','S',':',0};
        StoreDrawParams(3, 0, 0);
        /* "SGB:" when AUTO follows, to leave the TAGS box its room */
        if (S1_SGB) SetText(sgb_short, 4, 0, 16); else SetText(sgb_label, 9, 0, 16);
        SetText(tags_label, 5, 11, 16);
        return;
    }
    if (op == 3) {
        if (S1_SGB) return;             /* AUTO: stage1 does it, nothing to set */
        sgb_set(!sgb_get());
        op = 1;
    } else if (op == 4) {
        TAGS_HIDE = TAGS_HIDE ? 0 : 1;
        EZ_OP = OP_SAVE;
        FarCallEzCfg();
        op = 2;
    }
    if (S1_SGB) {
        /* our stage1 sends the SGB header itself, only on an SGB, and the
         * kernel never does: the setting has nothing to decide */
        static const u8 auto_str[5] = {'A','U','T','O',0};
        if (op == 1) StoreDrawParams(0, 3, 0); else StoreDrawParams(3, 0, 0);
        SetText(auto_str, 4, 5, 16);
    } else {
        /* 2 px after "SGB BOOT:": 8px text ends at x 72, 12px at 65 */
        box(hUiMode ? 0x44 : 0x4a, 0x80, sgb_get(), op == 1);
    }
    box(0x82, 0x80, !TAGS_HIDE, op == 2);
    StoreDrawParams(3, 0, 0);
}

/* Checkbox at pixel x, row y/8 (flcfg.c's): clear, outline (highlighted
 * when the cursor is on it), tick. */
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
