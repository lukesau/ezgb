/* Fast-launch configuration from the SET tab (docs/fastlaunch-set-tab.md).
 *
 * Bank 4, injected at 04:5990, same bank as DrawTimeAutosaveScreen (04:46f4)
 * so the hand-assembled hook shims (04:5932..) reach it with a plain call.
 * The SD file /EZGB.CFG is the single source of truth, read and written by
 * the shared bank-2 module ezcfg.c (docs/ezgb-cfg.md) through the bank-4
 * FarCallEzCfg shim (04:5f00); this file only owns the FL_* WRAM state and
 * the SET-tab UI:
 *
 *   FLAUNCH=<path>       -> enabled, launch that ROM
 *   FLAUNCH=#<path>      -> DISABLED (every trigger skipped), path kept
 *   missing / empty      -> enabled, no explicit target (lone-ROM rule, see
 *                           fastlaunch.c)
 *
 * One entry point, op-selected (inject.py pins the first-declared function):
 *
 *   op 0 ENTER  SET prologue: cancel any pending pick, load the file, draw
 *               the mod rows (RTC SD / NO SD, the FAST LAUNCH checkbox, the ROM
 *               name + PICK ROM button, UI) with the cursor highlight.
 *   op 1 ROWS   cursor moved (hiliteDec/hiliteInc tails): redraw the rows.
 *   op 2 A      A pressed with the cursor on a mod row. The checkboxes and UI
 *               toggle and rewrite the file (returns 0 = jp redraw); PICK ROM
 *               arms pick mode (returns 1 = leave the SET screen; the bank-0
 *               FlSetExitHook then re-enters the browser).
 *   op 3 PICK   the browser's A-on-ROM hook (bank 0, via FlPickCommitFar):
 *               compose $c2a6 + '/' + $c4a4, rewrite the file, disarm.
 *   op 4 LOAD   test hook only.
 *   op 5 TICK   once per pass of the SET input loop (SetLoopTickHook,
 *               04:5f20, on its ReadJoypad call): scroll the ROM name.
 *
 * Layout (8px rows; the stock rows were slid up one, see inject-ezcfg.sh):
 *   2 TIME: [SET]   4 date/time   6 RTC: SD [ ] NO SD [ ]   8 AUTO SAVE: [ ]
 *   10 FAST LAUNCH: [ ]   12 <name, 10 cols, scrolling> [PICK ROM]   14 UI: [8px]
 * `frame` is DrawTimeAutosaveScreen's stack frame (frame[0x3d] = cursor row:
 * 0 TIME SET, 1 RTC, 2 AUTO SAVE, 3 FAST LAUNCH, 4 PICK ROM, 5 UI).
 * NULL for op 3/4/5.
 *
 * ezcfg leaves $7FC0=$00 after its SD I/O. The SET screen rests at $7FC0=$00,
 * so nothing to restore there; after a pick the SET prologue re-selects its
 * own pages. ReadJoypad is level triggered, so every A action spins until A
 * is released; otherwise the screen we hand over to sees the same press.
 */

typedef unsigned char u8;
typedef unsigned int u16;

extern void FarCallEzCfg(void);                                     /* 04:5f00 -> ezcfg (02:4a00) */
extern void SetFpgaPage_B4(u8 page);                                /* 04:466e: $7FC0 = page */
extern void DrawString(const u8 *s, u8 len, u8 col, u8 row);        /* 00:08b7 */
extern void DrawRect(u8 x0, u8 y0, u8 x1, u8 y1, u8 fill);          /* 00:27ba */
extern void StoreDrawParams(u8 color, u8 colorB, u8 op);            /* 00:2791 */
extern u8 ReadJoypad(void);                                         /* 00:3a4a, post-swap byte, A = $10 */

#define FL_EN    (*(volatile u8 *)0xDA80)
#define FL_PLEN  (*(volatile u8 *)0xDA81)
#define FL_PATH  ((u8 *)0xDA82)     /* stored path, NUL-terminated, <= PATH_MAX */
#define FL_DISP  ((u8 *)0xDB10)     /* 40-byte zero-padded display buffer */
#define EZ_OP    (*(volatile u8 *)0xDBFC)
#define FL_PICK  (*(volatile u8 *)0xDBFE)
#define CWD      ((u8 *)0xC2A6)     /* browser: current directory ("/" or "/a/b") */
#define SELNAME  ((u8 *)0xC4A4)     /* browser: selected entry name */

#define OP_LOAD  0
#define OP_SAVE  1

#define PATH_MAX  120
#define DISP_LEN  40

#define ROW_RTC   1          /* RTC: SD / NO SD (RTC backup, restore and prompt on or off);
                              * row 2 is the stock AUTO SAVE, which never reaches flcfg */
#define ROW_CHECK 3
#define ROW_PICK  4
#define ROW_UI    5          /* UI: 8px / 12px button (docs/ui-mode.md) */
#define RTC_OFF  (*(volatile u8 *)0xDB3A)   /* RTCSD=0, owned by ezcfg */
#define MQ_POS   (*(volatile u8 *)0xDB38)   /* name marquee: first shown char */
#define MQ_TICK  (*(volatile u8 *)0xDB39)   /* ...frames since the last step */
#define MQ_FR    (*(volatile u8 *)0xDB3B)   /* hFrame at the previous tick */
#define HFRAME   (*(volatile u8 *)0xFFFA)   /* +1 per VBlank (VBlankPadLatch, 00:05cf) */
#define NAME_W   10                         /* name columns left of PICK ROM */
#define MQ_GAP   3                          /* blanks between repeats */
#define MQ_RATE  20                         /* frames per step (3 chars/s) */
#define MQ_HOLD  60                         /* ...at the start of the name (1 s) */
#define UI_MODE  (*(volatile u8 *)0xFFFB)   /* HRAM, read/written by ezcfg too */

static void cfg_load(void);
static void cfg_save(void);
static void draw_static(void);
static void draw_name(void);
static void draw_rows(u8 cur);
static void pick_commit(void);
static void wait_a_release(void);
static void box(u8 x, u8 y, u8 on, u8 hi);

u8 flcfg(u8 *frame, u8 op) {
    if (op == 0) {
        FL_PICK = 0;
        MQ_POS = 0;
        MQ_TICK = 0;
        MQ_FR = HFRAME;
        cfg_load();
        draw_static();
        draw_rows(frame[0x3d]);
        SetFpgaPage_B4(0);
        return 0;
    }
    if (op == 1) {
        draw_rows(frame[0x3d]);
        return 0;
    }
    if (op == 2) {
        if (frame[0x3d] == ROW_CHECK) {
            FL_EN = FL_EN ? 0 : 1;
            cfg_save();
            draw_rows(ROW_CHECK);
            wait_a_release();
            SetFpgaPage_B4(0);
            return 0;
        }
        if (frame[0x3d] == ROW_RTC) {
            RTC_OFF = RTC_OFF ? 0 : 1;
            cfg_save();
            draw_rows(ROW_RTC);
            wait_a_release();
            SetFpgaPage_B4(0);
            return 0;
        }
        if (frame[0x3d] == ROW_UI) {
            UI_MODE = UI_MODE ? 0 : 1;
            cfg_save();
            draw_rows(ROW_UI);
            wait_a_release();
            SetFpgaPage_B4(0);
            return 0;
        }
        FL_PICK = 1;
        wait_a_release();
        return 1;
    }
    if (op == 3) {
        pick_commit();
        return 0;
    }
    if (op == 5) {
        /* Paced in frames, not loop passes: a pass takes anything from a
         * fraction of a frame (1.05e) to exactly one (1.04e waits for VBlank
         * each pass), so count the VBlank interrupt's frame counter. */
        u8 f = HFRAME, d = f - MQ_FR;
        MQ_FR = f;
        if (d > 100) d = 100;             /* MQ_TICK stays below 256 */
        MQ_TICK += d;
        if (MQ_TICK >= (MQ_POS == 0 ? MQ_HOLD : MQ_RATE)) {
            MQ_TICK = 0;
            MQ_POS++;
            draw_name();          /* wraps MQ_POS, redraws only when it scrolls */
        }
        return 0;
    }
    cfg_load();
    return 0;
}

/* /EZGB.CFG -> FL_EN / FL_PLEN / FL_PATH (and the RTC copy, unused here). */
static void cfg_load(void) {
    EZ_OP = OP_LOAD;
    FarCallEzCfg();
}

/* FL_* (+ the RTC copy loaded alongside) -> /EZGB.CFG. */
static void cfg_save(void) {
    EZ_OP = OP_SAVE;
    FarCallEzCfg();
}

/* Browser A-on-ROM in pick mode: CWD + '/' + SELNAME becomes the new path.
 * The enable flag is preserved (a pick does not switch fast launch on). Too
 * long a path (> PATH_MAX) leaves the file untouched. */
static void pick_commit(void) {
    u8 lc, ln, need, n, i;

    cfg_load();                       /* refresh FL_EN (and the RTC line) from the file */

    for (lc = 0; CWD[lc]; lc++) {}
    for (ln = 0; SELNAME[ln]; ln++) {}
    need = lc + ln;
    if (lc == 0 || CWD[lc - 1] != '/') need++;
    if (need <= PATH_MAX) {
        n = 0;
        for (i = 0; i < lc; i++) FL_PATH[n++] = CWD[i];
        if (n == 0 || FL_PATH[n - 1] != '/') FL_PATH[n++] = '/';
        for (i = 0; i < ln; i++) FL_PATH[n++] = SELNAME[i];
        FL_PATH[n] = 0;
        FL_PLEN = n;
        cfg_save();
    }
    FL_PICK = 0;
    wait_a_release();
}

static void wait_a_release(void) {
    while (ReadJoypad() & 0x10) {}
}

/* Labels; the name is drawn by draw_name. */
static void draw_static(void) {
    static const u8 rtc_label[5] = {'R','T','C',':',0};
    static const u8 sd_label[3] = {'S','D',0};
    static const u8 nosd_label[6] = {'N','O',' ','S','D',0};
    static const u8 fl_label[13] = {'F','A','S','T',' ','L','A','U','N','C','H',':',0};
    static const u8 ui_label[4] = {'U','I',':',0};
    StoreDrawParams(3, 0, 0);
    DrawString(rtc_label, 4, 0, 6);
    DrawString(sd_label, 2, 6, 6);
    DrawString(nosd_label, 5, 11, 6);
    DrawString(fl_label, 12, 0, 10);
    DrawString(ui_label, 3, 0, 14);
    draw_name();
}

/* Basename of FL_PATH (or "(AUTO)" when there is no explicit path) in the
 * NAME_W columns left of the PICK ROM button on row 12. A longer name scrolls
 * continuously, cursor or not: MQ_POS is the first character shown, the text
 * repeats after MQ_GAP blanks, and op TICK advances it. DrawString renders
 * NUL as a space up to len, so the window always overwrites what was there. */
static void draw_name(void) {
    static const u8 auto_str[7] = {'(','A','U','T','O',')',0};
    const u8 *src;
    u8 i, k, len, base;

    if (FL_PLEN == 0) {
        src = auto_str;
    } else {
        base = 0;
        for (i = 0; FL_PATH[i]; i++) if (FL_PATH[i] == '/') base = i + 1;
        src = FL_PATH + base;
    }
    for (len = 0; src[len]; len++) {}
    if (len <= NAME_W) {
        MQ_POS = 0;
        for (i = 0; i < NAME_W; i++) FL_DISP[i] = i < len ? src[i] : 0;
    } else {
        if (MQ_POS >= len + MQ_GAP) MQ_POS = 0;
        k = MQ_POS;
        for (i = 0; i < NAME_W; i++) {
            FL_DISP[i] = k < len ? src[k] : ' ';
            if (++k >= len + MQ_GAP) k = 0;
        }
    }
    StoreDrawParams(3, 0, 0);
    DrawString(FL_DISP, NAME_W, 0, 12);
}

/* Checkbox at pixel x, row y/8 (the stock AUTO SAVE sequence, 04:496a, at
 * x $82; one row up is y $30): clear, outline (highlighted when the cursor is
 * on it), tick. */
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

/* RTC (row 6: "SD [ ]  NO SD [ ]", one of the two ticked; A switches) and
 * the FAST LAUNCH checkbox (row 10), the PICK ROM button
 * on row 12 and the UI button on row 14, both shaped like the stock SET
 * button (box 5 px left and 4 px right of the text, 3 px above and 5 below). */
static void draw_rows(u8 cur) {
    static const u8 pick_str[9] = {'P','I','C','K',' ','R','O','M',0};
    static const u8 ui8_str[5] = {' ','8','p','x',0};
    static const u8 ui12_str[5] = {'1','2','p','x',0};

    box(0x42, 0x30, !RTC_OFF, cur == ROW_RTC);   /* after "SD" (cols 6-7) */
    box(0x82, 0x30, RTC_OFF, cur == ROW_RTC);    /* after "NO SD" (cols 11-15) */
    box(0x82, 0x50, FL_EN, cur == ROW_CHECK);

    if (cur == ROW_PICK) StoreDrawParams(0, 3, 0); else StoreDrawParams(3, 0, 0);
    DrawRect(0x53, 0x5d, 0x9b, 0x69, 1);
    DrawString(pick_str, 8, 11, 12);
    if (cur == ROW_UI) StoreDrawParams(0, 3, 0); else StoreDrawParams(3, 0, 0);
    DrawRect(0x73, 0x6d, 0x9b, 0x79, 1);
    DrawString(UI_MODE ? ui12_str : ui8_str, 4, 15, 14);
    StoreDrawParams(3, 0, 0);
}
