/* Fast-launch configuration from the SET tab (docs/fastlaunch-set-tab.md).
 *
 * Bank 4, injected at 04:5990, same bank as DrawTimeAutosaveScreen (04:46f4)
 * so the hand-assembled hook shims (04:5932..) reach it with a plain call.
 * The SD file /FLAUNCH.CFG is the single source of truth:
 *
 *   line 1 = ROM path            -> enabled, launch that ROM
 *   line 1 = '#' + ROM path      -> DISABLED (every trigger skipped), path kept
 *   missing / empty              -> enabled, no explicit target (lone-ROM
 *                                   rule, see fastlaunch.c)
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
 * SD I/O discipline (hardware-only failure otherwise, invisible in SameBoy):
 * WaitVBlankFlag + $7FC0=$00 before f_open, f_read, f_write AND f_close.
 * The SET screen rests at $7FC0=$00, so nothing to restore there; after a
 * pick the SET prologue re-selects its own pages. ReadJoypad is level
 * triggered, so every A action spins until A is released; otherwise the
 * screen we hand over to sees the same press.
 *
 * Path strings passed to FatFs must be in WRAM (f_open runs in bank 6), so
 * the file name is bounced through FL_SCR first, as fastlaunch.c does.
 */

typedef unsigned char u8;
typedef unsigned int u16;

extern u8 FarCall_06_7309(u8 *fp, const u8 *path, u8 mode);        /* f_open  00:1926 */
extern u8 FarCall_06_779a(u8 *fp, u8 *buf, u16 btr, u16 *br);       /* f_read  00:1941 */
extern u8 FarCall_07_7739(u8 *fp, const u8 *buf, u16 btw, u16 *bw); /* f_write 00:1963 */
extern u8 FarCall_03_768f(u8 *fp);                                  /* f_close 00:19a1 */
extern void WaitVBlankFlag(void);                                   /* 00:0688 */
extern void SetFpgaPage_B4(u8 page);                                /* 04:466e: $7FC0 = page */
extern void DrawString(const u8 *s, u8 len, u8 col, u8 row);        /* 00:08b7 */
extern void DrawRect(u8 x0, u8 y0, u8 x1, u8 y1, u8 fill);          /* 00:27ba */
extern void StoreDrawParams(u8 color, u8 colorB, u8 op);            /* 00:2791 */
extern u8 ReadJoypad(void);                                         /* 00:3a4a, post-swap byte, A = $10 */

#define FIL_OBJ  ((u8 *)0xCA0F)     /* kernel FIL, idle in the menu */
#define CFGBUF   ((u8 *)0xDA00)     /* file contents / line to write (shared with fastlaunch.c) */
#define FL_EN    (*(volatile u8 *)0xDA80)
#define FL_PLEN  (*(volatile u8 *)0xDA81)
#define FL_PATH  ((u8 *)0xDA82)     /* stored path, NUL-terminated, <= PATH_MAX */
#define FL_SCR   ((u8 *)0xDB00)     /* "/FLAUNCH.CFG" bounce, 16 */
#define FL_DISP  ((u8 *)0xDB10)     /* 40-byte zero-padded display buffer */
#define FL_PICK  (*(volatile u8 *)0xDBFE)
#define CWD      ((u8 *)0xC2A6)     /* browser: current directory ("/" or "/a/b") */
#define SELNAME  ((u8 *)0xC4A4)     /* browser: selected entry name */

#define FA_READ   0x01
#define FA_CREATE 0x0A              /* FA_WRITE | FA_CREATE_ALWAYS (truncate) */
#define REC_LEN   124               /* fixed record: every save writes exactly this, so a
                                       * shorter path fully overwrites the old one without any
                                       * f_truncate (which this kernel lacks). */
#define CFG_MAX   127
#define PATH_MAX  120
#define DISP_LEN  40

#define ROW_CHECK 2
#define ROW_PICK  3

static void cfg_load(void);
static u8 cfg_save(void);
static void copy_name(void);
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

static void copy_name(void) {
    static const u8 cfg_name[16] =
        {'/','F','L','A','U','N','C','H','.','C','F','G',0};
    u8 i;
    for (i = 0; ; i++) { FL_SCR[i] = cfg_name[i]; if (cfg_name[i] == 0) break; }
}

/* Parse line 1 of /FLAUNCH.CFG into FL_EN / FL_PLEN / FL_PATH. Missing file
 * or empty line = enabled, no path. Mirrors scan_config() in fastlaunch.c. */
static void cfg_load(void) {
    u16 br;
    u8 len, start, i, n, r;

    FL_EN = 1;
    FL_PLEN = 0;
    FL_PATH[0] = 0;

    copy_name();
    WaitVBlankFlag();
    SetFpgaPage_B4(0);
    if (FarCall_06_7309(FIL_OBJ, FL_SCR, FA_READ) != 0) return;
    WaitVBlankFlag();
    SetFpgaPage_B4(0);
    r = FarCall_06_779a(FIL_OBJ, CFGBUF, CFG_MAX, &br);
    WaitVBlankFlag();
    SetFpgaPage_B4(0);
    FarCall_03_768f(FIL_OBJ);
    if (r != 0 || br == 0) return;

    len = 0;
    for (;;) {
        if (len >= CFG_MAX) break;
        if ((u16)len >= br) break;
        if (CFGBUF[len] == 0x0d || CFGBUF[len] == 0x0a || CFGBUF[len] == 0) break;
        len++;
    }
    while (len != 0 && CFGBUF[len - 1] == ' ') len--;

    start = 0;
    if (len != 0 && CFGBUF[0] == '#') {
        FL_EN = 0;
        start = 1;
        while (start < len && CFGBUF[start] == ' ') start++;
    }
    if (start >= len) return;

    n = 0;
    if (CFGBUF[start] != '/') FL_PATH[n++] = '/';
    for (i = start; i < len && n < PATH_MAX; i++) FL_PATH[n++] = CFGBUF[i];
    FL_PATH[n] = 0;
    FL_PLEN = n;
}

/* Rewrite /FLAUNCH.CFG. The first line is "[#]<path>", then CR/LF; the record
 * is padded with spaces to a fixed REC_LEN so every save writes exactly the
 * same number of bytes, so a shorter path fully overwrites a longer old one
 * with no need for f_truncate (which this kernel lacks). Opens
 * FA_CREATE_ALWAYS ($0a); f_write then f_close, each preceded by WaitVBlankFlag
 * + SetFpgaPage(0) as the kernel's own BackupSaveDump does. The parser reads
 * only line 1 and trims trailing spaces, so the padding is invisible. Returns
 * FRESULT (0 = ok). */
static u8 cfg_save(void) {
    u16 bw;
    u8 n, i, r;

    n = 0;
    if (!FL_EN) CFGBUF[n++] = '#';
    for (i = 0; i < FL_PLEN; i++) CFGBUF[n++] = FL_PATH[i];
    CFGBUF[n++] = 0x0d;
    CFGBUF[n++] = 0x0a;
    while (n < REC_LEN) CFGBUF[n++] = ' ';

    copy_name();
    WaitVBlankFlag();
    SetFpgaPage_B4(0);
    r = FarCall_06_7309(FIL_OBJ, FL_SCR, FA_CREATE);
    if (r != 0) return r;
    WaitVBlankFlag();
    SetFpgaPage_B4(0);
    r = FarCall_07_7739(FIL_OBJ, CFGBUF, REC_LEN, &bw);
    WaitVBlankFlag();
    SetFpgaPage_B4(0);
    FarCall_03_768f(FIL_OBJ);
    return r;
}

/* Browser A-on-ROM in pick mode: CWD + '/' + SELNAME becomes the new path.
 * The enable flag is preserved (a pick does not switch fast launch on). Too
 * long a path (> PATH_MAX) leaves the file untouched. */
static void pick_commit(void) {
    u8 lc, ln, need, n, i;

    cfg_load();                       /* refresh FL_EN from the file */

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
    if (cur == ROW_CHECK) StoreDrawParams(2, 2, 0); else StoreDrawParams(3, 0, 0);
    DrawRect(0x82, 0x48, 0x8a, 0x50, 0);          /* outline */
    if (FL_EN) {
        StoreDrawParams(2, 2, 0);
        DrawRect(0x84, 0x4a, 0x88, 0x4e, 1);      /* check mark */
    }

    if (cur == ROW_PICK) StoreDrawParams(3, 2, 0); else StoreDrawParams(3, 0, 0);
    DrawRect(0x73, 0x55, 0x9b, 0x61, 1);          /* button box */
    DrawString(pick_str, 4, 15, 11);
    StoreDrawParams(3, 0, 0);
}
