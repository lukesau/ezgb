/* BACKUPSAVE prompt (docs/modal-prompts.md).
 *
 * Bank 4, injected at 04:6000. The stock BackupSavePrompt (01:6747) keeps its
 * control flow (auto-save or ask, A dumps, B skips) but its four draw
 * sequences are replaced by inline far calls to this function, with an op:
 *
 *   0  box, title, the save's file name and when the game was last played
 *      (replaces the stock box + "BACKUPSAVE"; `size` is not used)
 *   1  the [B] / [A] options (replaces the two button frames + labels, whose
 *      frames the 8x8 label cells broke)
 *   2  "Saving..." in place of the options: the two stock "Saving..."
 *      draws call BkSavingStub (00:039d) instead of DrawString (a stub,
 *      because those sites load a bank-1 string address that differs per
 *      build, which the port tool will not carry inside a replaced site)
 *   3  the dump's progress dots:  *      BkSpinStub (00:0390) instead of DrawString
 *
 * Inline trampoline: two pad parameters. The prompt's joypad poll goes
 * through LastRomTickStub (00:0370), which runs the name's marquee.
 *
 * The look is the START overlay's (lastrom_box.c): one box, the name in
 * paper on a solid ink band, a rule above the options and one between them.
 * The name is the basename of the SAVER path the boot code copied to $c3a5;
 * LastRomName (lastrom_name.c) draws and scrolls it, with LR_GEO = 1
 * selecting this box's row. The "Played" line is LastRomName's second line
 * (LR_GEO = 2): "Played Oct 23 14:05" is one character over the 8px row, so
 * it scrolls there. Its text sits in FL_DISP, the SET tab's draw buffer,
 * since the marquee reads it again at every step.
 *
 *   8px   box (0,35)-(159,99); title, name, info, options on tile rows 5,
 *         7, 9, 11; band y 51..67; rule y 83, vertical at x 83
 *   12px  box (0,36)-(159,103); rows at y 40, 56, 72, 88 from x 12; band
 *         y 53..69; rule y 85, vertical at x 79
 *
 * The 12px renderer runs in bank 2 and cannot read this bank's strings, so
 * they are copied to the stack first.
 *
 *   python3 tools/inject.py src/bkprompt.c $V 4 6000 BkPrompt \
 *       --pin FarCallDrawString12=05c0 --pin LastRomNameStub=0368 --pin DrawString=08b7 \
 *       --pin DrawRect=27ba --pin StoreDrawParams=2791 --replace --apply
 */

#include "types.h"
#include "draw.h"
#include "vars.h"
#include "ezcfg.h"

extern void LastRomNameStub(const u8 *s);                           /* 00:0368 -> LastRomName */

#define SAVE_PATH ((const u8 *)0xC3A5)      /* kernel: "/SAVER/<name>.sav", from the page-$11 stamp */
#define PLAYED    ((u8 *)0xDB10)            /* the "Played" line: FL_DISP, idle off the SET tab */
#define R_DAY 3
#define R_MON 5
#define SPIN      (*(volatile u8 *)0xDB3E)  /* op 3's call counter (LastRomName's length byte, idle during the dump) */

static void text(const u8 *s, u8 row8, u8 y12);
static void frame(void);

/* The entry point stays the first function in the file. */
void BkPrompt(u16 far_pad_thunk, u16 far_pad_af, u8 op, u8 size) {
    static const u8 title_str[14] = {'B','a','c','k',' ','u','p',' ','s','a','v','e','?',0};
    static const u8 played_str[20] = {'P','l','a','y','e','d',' ','M','m','m',' ',
                                      'd','d',' ','h','h',':','m','m',0};
    static const u8 month_str[36] = {'J','a','n','F','e','b','M','a','r','A','p','r',
                                     'M','a','y','J','u','n','J','u','l','A','u','g',
                                     'S','e','p','O','c','t','N','o','v','D','e','c'};
    static const u8 opt_str[20]   = {'[','B',']','s','k','i','p',' ',' ',' ',' ',' ',
                                     '[','A',']','s','a','v','e',0};
    static const u8 saving_str[10] = {'S','a','v','i','n','g','.','.','.',0};
    u8 buf[20];
    const u8 *p, *name;
    u8 i;

    (void)far_pad_thunk;
    (void)far_pad_af;
    if (op == 0) {
        StoreDrawParams(0, 0, 0);
        DrawRect(0, 32, 159, 107, 1);
        PopupDrawParams(3, 0);
        if (hUiMode) DrawRect(0, 36, 159, 103, 1); else DrawRect(0, 35, 159, 99, 1);
        text(title_str, 5, 40);
        frame();
        PopupDrawParams(3, 3);
        if (hUiMode) DrawRect(0, 53, 159, 69, 1); else DrawRect(0, 51, 159, 67, 1);
        name = SAVE_PATH;
        for (p = SAVE_PATH; *p; p++) if (*p == '/') name = p + 1;
        LR_GEO = 1;
        LastRomNameStub(name);
        /* "Played Oct 23 14:05": the RTC= backup (ezcfg.c), refreshed at
         * every launch, so at this prompt it is when the game was started.
         * Left out when there is no backup. */
        if (RTC_VALID) {
            for (i = 0; i < 20; i++) PLAYED[i] = played_str[i];
            i = RTC_BK[R_MON];
            if (i & 0x10) i -= 6;             /* BCD 10-12 */
            p = month_str + (u8)(i * 3 - 3);
            PLAYED[7] = p[0]; PLAYED[8] = p[1]; PLAYED[9] = p[2];
            /* day, hour, minute: registers 3, 2, 1 at 11, 14, 17 */
            for (p = RTC_BK + R_DAY, i = 11; i < 20; p--, i += 3) {
                PLAYED[i] = (u8)('0' + (*p >> 4));
                PLAYED[i + 1] = (u8)('0' + (*p & 0x0F));
            }
            LR_GEO = 2;
            LastRomNameStub(PLAYED);
        }
        return;
    }
    if (op == 3) {
        /* BackupSaveDump's spinner, once per sector: every 8th call the
         * dots after "Saving" step 1, 2, 3 */
        i = ++SPIN;
        if (i & 7) return;
        i = (u8)((i >> 3) & 3);
        if (i == 0) { SPIN += 8; i = 1; }
        for (op = 0; op < 6; op++) buf[op] = saving_str[op];
        while (i--) buf[op++] = '.';
        buf[op] = 0;
        PopupDrawParams(3, 0);
        text(buf, 11, 88);
        if (hUiMode) DrawRect(0, 36, 159, 103, 0);
        return;
    }
    /* the options row: clear it (op 2 replaces op 1's text and rule) */
    PopupDrawParams(0, 0);
    if (hUiMode) DrawRect(1, 86, 158, 102, 1); else DrawRect(1, 84, 158, 98, 1);
    PopupDrawParams(3, 0);
    if (op == 2) {
        SPIN = 0;
        text(saving_str, 11, 88);
        frame();
        PopupDrawParams(3, 0);
        return;
    }
    if (hUiMode) {
        text(opt_str, 11, 88);
    } else {
        DrawString(opt_str, 7, 1, 11);
        DrawString(opt_str + 12, 7, 11, 11);
    }
    frame();
    if (hUiMode) DrawRect(79, 85, 79, 103, 1); else DrawRect(83, 83, 83, 99, 1);
    PopupDrawParams(3, 0);
}

/* One text row: tile row row8 from column 1, or the 12px row at y12 from x 12. */
static void text(const u8 *s, u8 row8, u8 y12) {
    u8 buf[24];
    u8 i;

    if (!hUiMode) {
        DrawString(s, 18, 1, row8);       /* padded with blanks to the box's inner width */
        return;
    }
    for (i = 0; i < 23 && s[i]; i++) buf[i] = s[i];
    buf[i] = 0;
    FarCallDrawString12(buf, 0, 1, y12);
}

/* What a text row repaints: the box outline (a 12px row runs to x 159) and
 * the rule above the options. Leaves ink 3 on ink 3 selected. */
static void frame(void) {
    PopupDrawParams(3, 0);
    if (hUiMode) DrawRect(0, 36, 159, 103, 0); else DrawRect(0, 35, 159, 99, 0);
    PopupDrawParams(3, 3);
    if (hUiMode) DrawRect(0, 85, 159, 85, 1); else DrawRect(0, 83, 159, 83, 1);
}
