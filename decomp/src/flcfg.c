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
 *               the two new rows (FAST LAUNCH checkbox, ROM + PICK button,
 *               basename) with the cursor highlight.
 *   op 1 ROWS   cursor moved (hiliteDec/hiliteInc tails): redraw the rows.
 *   op 2 A      A pressed with the cursor on row 2 or 3. Row 2 toggles the
 *               flag and rewrites the file (returns 0 = jp redraw). Row 3
 *               arms pick mode (returns 1 = leave the SET screen; the bank-0
 *               FlSetExitHook then re-enters the browser).
 *   op 3 PICK   the browser's A-on-ROM hook (bank 0, via FlPickCommitFar):
 *               compose $c2a6 + '/' + $c4a4, rewrite the file, disarm.
 *   op 4 LOAD   test hook only.
 *
 * `frame` is DrawTimeAutosaveScreen's stack frame (frame[0x3d] = cursor row:
 * 0 TIME SET, 1 AUTO SAVE, 2 FAST LAUNCH, 3 PICK). NULL for op 3/4.
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

#define ROW_CHECK 2
#define ROW_PICK  3

static void cfg_load(void);
static void cfg_save(void);
static void draw_static(void);
static void draw_name(void);
static void draw_rows(u8 cur);
static void pick_commit(void);
static void wait_a_release(void);

u8 flcfg(u8 *frame, u8 op) {
    if (op == 0) {
        FL_PICK = 0;
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
        FL_PICK = 1;
        wait_a_release();
        return 1;
    }
    if (op == 3) {
        pick_commit();
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

/* Labels on rows 9 and 11, basename on rows 13-14. */
static void draw_static(void) {
    static const u8 fl_label[13] = {'F','A','S','T',' ','L','A','U','N','C','H',':',0};
    static const u8 rom_label[5] = {'R','O','M',':',0};
    StoreDrawParams(3, 0, 0);
    DrawString(fl_label, 12, 0, 9);
    DrawString(rom_label, 4, 0, 11);
    draw_name();
}

/* Basename of FL_PATH (or "(AUTO)" when there is no explicit path) drawn as
 * two 20-column rows from a zero-padded buffer: DrawString renders NUL as a
 * space up to len, so stale text is always overwritten. Never len 0 (= 17)
 * and never more than 20 per call (the cursor wraps at column 19). */
static void draw_name(void) {
    static const u8 auto_str[7] = {'(','A','U','T','O',')',0};
    const u8 *src;
    u8 i, base;

    for (i = 0; i < DISP_LEN; i++) FL_DISP[i] = 0;
    if (FL_PLEN == 0) {
        src = auto_str;
    } else {
        base = 0;
        for (i = 0; FL_PATH[i]; i++) if (FL_PATH[i] == '/') base = i + 1;
        src = FL_PATH + base;
    }
    for (i = 0; i < DISP_LEN && src[i]; i++) FL_DISP[i] = src[i];
    StoreDrawParams(3, 0, 0);
    DrawString(FL_DISP, 20, 0, 13);
    DrawString(FL_DISP + 20, 20, 0, 14);
}

/* Checkbox on row 9 (mirrors the AUTO SAVE checkbox sequence, 04:496a) and
 * the PICK button on row 11 (mirrors the SET button, 04:4906). */
static void draw_rows(u8 cur) {
    static const u8 pick_str[5] = {'P','I','C','K',0};

    StoreDrawParams(0, 0, 0);
    DrawRect(0x82, 0x48, 0x8a, 0x50, 1);          /* clear box */
    if (cur == ROW_CHECK) StoreDrawParams(1, 1, 0); else StoreDrawParams(3, 0, 0);
    DrawRect(0x82, 0x48, 0x8a, 0x50, 0);          /* outline */
    if (FL_EN) {
        StoreDrawParams(3, 3, 0);
        DrawRect(0x84, 0x4a, 0x88, 0x4e, 1);      /* check mark */
    }

    if (cur == ROW_PICK) StoreDrawParams(0, 3, 0); else StoreDrawParams(3, 0, 0);
    DrawRect(0x73, 0x55, 0x9b, 0x61, 1);          /* button box */
    DrawString(pick_str, 4, 15, 11);
    StoreDrawParams(3, 0, 0);
}
