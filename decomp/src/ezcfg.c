/* EZGB.CFG: the one on-card settings file (docs/ezgb-cfg.md).
 *
 * Bank 2, injected at 02:4a00 (after FastLaunchScan at 02:4500). Reached by
 * a plain call from bank-2 code (fastlaunch.c) and by FarCallTrampoline from
 * banks 0/1/4 (boot restore, save-dump hook, SET tab). It takes NO stack
 * argument so both entry styles work: the trampoline shifts stack args by 6
 * bytes, so the operation is passed in WRAM instead (EZ_OP, $DBFC).
 *
 *   op 0 LOAD     read /EZGB.CFG into the FL_* / RTC_BK* WRAM state
 *                 (falls back to the legacy /FLAUNCH.CFG line-1 format)
 *   op 1 SAVE     rewrite /EZGB.CFG from that WRAM state
 *   op 2 BACKUP   LOAD, read the RTC; if it is valid, VL clear and later
 *                 than the stored copy, store it; SAVE. Hooked after every
 *                 BACKUPSAVE dump. (Launches do the same, in LASTSAVE.)
 *   op 3 RESTORE  LOAD; if the file holds a time and a settled RTC read
 *                 looks damaged (year 2000, invalid, VL set, or earlier than
 *                 RTC=), ask, and on A write the stored time back to the RTC.
 *                 A normal boot neither waits nor writes.
 *   op 6 TIMESET  as BACKUP, but the new time always replaces RTC=.
 *   op 7 RELAUNCH the RTC backup LASTSAVE does, for the START-overlay
 *                 relaunch and fast launch, which skip LastRomPersist.
 *   op 8 SAVECHK  boot: is the pending-backup stamp's save path plausible?
 *                 A dead cell leaves garbage there, see savestamp_check.
 * RTCSD=0 (SET tab "RTC: NO SD") turns every RTC part off: no boot read or
 * prompt, and BACKUP, TIMESET and RELAUNCH return before touching the card.
 *                 Hooked at boot, right after "Micro SD initial OK!" and
 *                 before the BACKUPSAVE check, so the same boot's dump then
 *                 stamps a sane time rather than the dead clock's.
 *
 * File format: key=value lines, CR/LF or LF, keys case-insensitive, first
 * occurrence of a key wins, unknown keys ignored, trailing spaces trimmed.
 *
 *   FLAUNCH=/Pokemon/Blue.gb      fast-launch target (a leading '#' on the
 *                                 value = fast launch disabled, path kept)
 *   RTC=2026-09-08 14:33:00       last known good clock (digits are all that
 *                                 matter, split on any
 *                                 punctuation into YYYY MM DD HH MM SS)
 *
 * The firmware rewrites the whole file from its known keys as a fixed
 * REC_LEN (one-sector) record padded with spaces (this FatFs has no f_truncate), so hand
 * added lines do not survive a save; comments are not preserved either.
 *
 * RTC access: FPGA page $06 exposes seven BCD bytes at $A008..$A00E in
 * PCF8563 register order (sec, min, hour, day, weekday, month, year), see
 * RtcToDayCount (01:4c5e; 01:4ec9 in 0918). Writing is the SET tab's recipe
 * (DrawTimeAutosaveScreen_confirmBcdWrite, 04:5747): select page 6, store
 * the seven bytes, commit with $7FD0=1, back to page 0. Both the page select
 * and the commit are the unlock/commit sequence of SetFpgaPage_B4 (04:466e),
 * inlined here because they are plain FPGA register stores that work from
 * any bank.
 *
 * SD I/O discipline (hardware-only failure otherwise, invisible in SameBoy):
 * WaitVBlankFlag + $7FC0=$00 before f_open, f_read, f_write AND f_close. The
 * path string passed to FatFs must be in WRAM (f_open runs in bank 6), so
 * file names are bounced through FL_SCR first. Every op leaves $7FC0=$00;
 * callers re-select their own personality afterwards (the boot hook replays
 * the kernel's SetFpgaPage(3), the SET tab rests at 0, the browser sets its
 * own pages on entry).
 *
 * inject.py pins the FIRST-declared function, so ezcfg is defined first.
 */

typedef unsigned char u8;
typedef unsigned int u16;

extern u8 FarCall_06_7309(u8 *fp, const u8 *path, u8 mode);        /* f_open  00:1926 */
extern u8 FarCall_06_779a(u8 *fp, u8 *buf, u16 btr, u16 *br);       /* f_read  00:1941 */
extern u8 FarCall_07_7739(u8 *fp, const u8 *buf, u16 btw, u16 *bw); /* f_write 00:1963 */
extern u8 FarCall_03_768f(u8 *fp);                                  /* f_close 00:19a1 */
extern void WaitVBlankFlag(void);                                   /* 00:0688 */

#define FIL_OBJ   ((u8 *)0xCA0F)     /* kernel FIL, idle whenever we run */
#define CFGBUF    ((u8 *)0xD800)     /* 512: file contents / the one-sector record to write */
#define FL_EN     (*(volatile u8 *)0xDA80)
#define FL_PLEN   (*(volatile u8 *)0xDA81)
#define FL_PATH   ((u8 *)0xDA82)     /* NUL-terminated, <= PATH_MAX */
#define FL_SCR    ((u8 *)0xDB00)     /* file-name bounce, 16 */
#define RTC_BK    ((u8 *)0xDB40)     /* stored time, 7 BCD bytes in register order */
#define RTC_VALID (*(volatile u8 *)0xDB47)
#define RTC_CUR   ((u8 *)0xDB48)     /* current RTC read, 7 bytes */
#define RTC_OFF   (*(volatile u8 *)0xDB3A)  /* RTCSD=0 ("RTC: NO SD" on the SET tab): no RTC
                                               * reads, backups or prompt; stays valid in WRAM
                                               * after any load, so hooks can skip the card */
#define RTC_RAW   ((u8 *)0xDB50)     /* the unmasked register bytes of the last read */
#ifdef EZCFG_RTCLOG
/* Test builds only (EZGB_DEFINES=EZCFG_RTCLOG, see decomp/tools/sdcc_build.py):
 * an RTCLOG= trace of every RTC event, see log_add. */
#define LOG_LEN   (*(volatile u8 *)0xDB4F)  /* RTCLOG= text length, a multiple of LOG_ENT */
#define LOG_BUF   ((u8 *)0xDB60)     /* RTCLOG= text, newest entry first, LOG_MAX bytes */
#define LOG_ENT   14                 /* "YYMMDDhhmmssE " */
#define LOG_MAX   (LOG_ENT * 10)
#define LOG(ev)   log_add(ev)
#else
#define LOG(ev)
#endif
#define EZ_OP     (*(volatile u8 *)0xDBFC)
#define LR_PATH   ((u8 *)0xDA00)     /* LASTROM= path, NUL-terminated, <= PATH_MAX */
#define LR_VALID  (*(volatile u8 *)0xDA7F)
#define EZ_RES    (*(volatile u8 *)0xDBFB)  /* op result for the bank-0/1 stubs */
#define UI_MODE   (*(volatile u8 *)0xFFFB)  /* HRAM: 0 = 8px browser, 1 = 12px (docs/ui-mode.md); cleared at boot */
#define LAUNCH_PATH ((u8 *)0xC2A6)   /* kernel: assembled launch path (LoaderPrepPath) */
#define OVL_PATH    ((u8 *)0xC4A4)   /* kernel: START overlay's copy of the $A300 record */
#define SAVE_PATH   ((u8 *)0xC3A5)   /* kernel: "/SAVER/<name>.sav", boot's copy of the page-$11 stamp */

#define OP_LOAD    0
#define OP_SAVE    1
#define OP_BACKUP  2
#define OP_RESTORE 3
#define OP_LASTSAVE 4              /* launch: record the launch path as LASTROM= */
#define OP_LASTLOAD 5              /* START overlay: validate $A300 copy, else fall back to LASTROM= */
#define OP_TIMESET 6               /* SET-tab TIME SET confirm: the new time replaces RTC= outright */
#define OP_RELAUNCH 7              /* START-overlay relaunch / fast launch: RTC backup only */
#define OP_SAVECHK 8               /* boot: validate the BACKUPSAVE stamp's path before the prompt */

#define FA_READ   0x01
#define FA_CREATE 0x0A               /* FA_WRITE | FA_CREATE_ALWAYS */
#define CFG_MAX   REC_LEN            /* CFGBUF[CFG_MAX] is the parser NUL (= LR_PATH[0], cleared before parsing) */
#define REC_LEN   512                /* one whole sector, see far_write(); content is 286 max */
#define PATH_MAX  120

#define RTC_WIN   ((volatile u8 *)0xA008)
#define R_SEC 0
#define R_MIN 1
#define R_HR  2
#define R_DAY 3
#define R_WD  4
#define R_MON 5
#define R_YR  6

static void copy_name(const u8 *name);
static u8 open_read(const u8 *name, u16 *br);
static void sd_prep(void);
static void fpga_page(u8 page);
static void fpga_commit_7fd0(void);
static void cfg_load(void);
static u8 cfg_save(void);
static void parse_record(u16 br, u8 legacy);
static void parse_flaunch(const u8 *v, u8 len);
static void parse_rtc(const u8 *v, u8 len);
static u8 key_is(const u8 *k, u8 klen, const u8 *lit, u8 litlen);
static u8 lower(u8 c);
static void rtc_read(void);
static void rtc_write(const u8 *src);
static void backup_take(u8 ev, u8 force);
static u8 rtc_suspect(void);
static u8 rtc_valid(const u8 *r);
static u8 bcd_ok(u8 v, u8 max);
static signed char rtc_cmp(const u8 *a, const u8 *b);
static u8 put_bcd(u8 *dst, u8 v);
static void cfg_backup(u8 timeset);
#ifdef EZCFG_RTCLOG
static void log_add(u8 ev);
#endif
static void cfg_restore(void);
static void rtc_read_settled(void);
static u8 restore_prompt(u8 why);
static void put_hex(u8 *dst, u8 v);
static void put_date(u8 *d, const u8 *r);
static void put_time(u8 *t, const u8 *r);
static void parse_lastrom(const u8 *v, u16 len);
static u8 path_valid(const u8 *p);
static void lastrom_save(void);
static void lastrom_load(void);
static void savestamp_check(void);

extern void DrawString(const u8 *s, u8 len, u8 x, u8 y);   /* 00:08b7 */
extern u8 ReadJoypad(void);                                 /* 00:3a4a, E = key byte, B = $20 */
extern void DrawRect(u8 x0, u8 y0, u8 x1, u8 y1, u8 fill);  /* 00:27ba, pixel coords */
extern void StoreDrawParams(u8 color, u8 colorB, u8 op);    /* 00:2791 */
extern void DrawString12(u16 pad_thunk, u16 pad_af, u16 pad_ret, const u8 *s, u8 len, u8 col, u8 row);   /* 02:7500 */
extern void LastRomName(u16 pad_thunk, u16 pad_af, u16 pad_ret, const u8 *s, u8 len, u8 x, u8 y);   /* 02:7260, lastrom_name.c */

void ezcfg(void) {
    u8 op = EZ_OP;
    if (op == OP_LOAD) { cfg_load(); return; }
    if (op == OP_SAVE) { cfg_save(); return; }
    if (op == OP_BACKUP) { cfg_backup(0); return; }
    if (op == OP_TIMESET) { cfg_backup(1); return; }
    if (op == OP_RELAUNCH) {
        if (RTC_OFF) return;             /* NO SD: leave the card alone */
        /* The relaunch jumps past LoaderPrepPath/LastRomPersist (so past
         * LASTSAVE); $c2a6 need not hold the full path yet, so leave LASTROM=
         * alone and only refresh RTC=. */
        cfg_load();
        backup_take('L', 0);
        cfg_save();
        return;
    }
    if (op == OP_LASTSAVE) { lastrom_save(); return; }
    if (op == OP_LASTLOAD) { lastrom_load(); return; }
    if (op == OP_SAVECHK) { savestamp_check(); return; }
    cfg_restore();
}

/* ---- FPGA helpers (SetFpgaPage_B4 / SetFpga7FD0_B4 inlined) ---- */

static void fpga_page(u8 page) {
    *(volatile u8 *)0x7F00 = 0xE1;
    *(volatile u8 *)0x7F10 = 0xE2;
    *(volatile u8 *)0x7F20 = 0xE3;
    *(volatile u8 *)0x7FC0 = page;
    *(volatile u8 *)0x7FF0 = 0xE4;
}

static void fpga_commit_7fd0(void) {
    *(volatile u8 *)0x7F00 = 0xE1;
    *(volatile u8 *)0x7F10 = 0xE2;
    *(volatile u8 *)0x7F20 = 0xE3;
    *(volatile u8 *)0x7FD0 = 0x01;
    *(volatile u8 *)0x7FF0 = 0xE4;
}

static void sd_prep(void) {
    WaitVBlankFlag();
    fpga_page(0);
}

/* ---- RTC ---- */

/* PCF8563 time registers carry flag/unused bits above the BCD digits:
 * seconds bit 7 is VL (voltage low), months bit 7 is the century flag, and
 * the hours/days/weekday registers have unused high bits. The kernel's own
 * readers extract digits nibble by nibble and never see them; a whole-byte
 * BCD check would, so mask them off exactly as the datasheet lays them out. */
static const u8 rtc_mask[7] = {0x7F, 0x7F, 0x3F, 0x3F, 0x07, 0x1F, 0xFF};

static void rtc_read(void) {
    u8 i;
    u8 v;
    fpga_page(6);
    for (i = 0; i < 7; i++) {
        v = RTC_WIN[i];
        RTC_RAW[i] = v;
        RTC_CUR[i] = v & rtc_mask[i];
    }
    fpga_page(0);
}

static void rtc_write(const u8 *src) {
    u8 i;
    fpga_page(6);
    for (i = 0; i < 7; i++) RTC_WIN[i] = src[i];
    fpga_commit_7fd0();
    fpga_page(0);
}

static u8 bcd_ok(u8 v, u8 max) {
    if ((v & 0x0F) > 9) return 0;
    if ((v >> 4) > 9) return 0;
    return v <= max;
}

/* Sanity check on a register-order 7-byte time. Weekday is ignored (the SET
 * tab hardcodes it). A dead cell leaves zeros or garbage here; zeros fail on
 * day/month, garbage fails the BCD digit test. */
static u8 rtc_valid(const u8 *r) {
    if (!bcd_ok(r[R_SEC], 0x59)) return 0;
    if (!bcd_ok(r[R_MIN], 0x59)) return 0;
    if (!bcd_ok(r[R_HR], 0x23)) return 0;
    if (!bcd_ok(r[R_DAY], 0x31) || r[R_DAY] == 0) return 0;
    if (!bcd_ok(r[R_MON], 0x12) || r[R_MON] == 0) return 0;
    if (!bcd_ok(r[R_YR], 0x99)) return 0;
    return 1;
}

/* Lexicographic compare year, month, day, hour, minute, second; BCD bytes
 * order correctly as unsigned within a field. */
static signed char rtc_cmp(const u8 *a, const u8 *b) {
    static const u8 order[6] = {R_YR, R_MON, R_DAY, R_HR, R_MIN, R_SEC};
    u8 i, x, y;
    for (i = 0; i < 6; i++) {
        x = a[order[i]];
        y = b[order[i]];
        if (x < y) return -1;
        if (x > y) return 1;
    }
    return 0;
}

/* Read the clock, log it as event ev, and store it as RTC= when it is a
 * trustworthy time: valid, VL (seconds bit 7, the PCF8563's "supply dipped,
 * time not guaranteed" flag) clear, and later than the stored copy. force
 * (TIME SET) stores any valid time: it is the user's explicit value, so a
 * clock set back from a wrong future date does not leave RTC= stuck there.
 * The caller saves the file. */
static void backup_take(u8 ev, u8 force) {
    u8 i;
    rtc_read();
    LOG(ev);
    if (!rtc_valid(RTC_CUR)) return;
    if (!force && ((RTC_RAW[R_SEC] & 0x80) || (RTC_VALID && rtc_cmp(RTC_CUR, RTC_BK) <= 0))) return;
    for (i = 0; i < 7; i++) RTC_BK[i] = RTC_CUR[i];
    RTC_VALID = 1;
}

/* After every BACKUPSAVE dump (timeset 0) and TIME SET confirm (timeset 1). */
static void cfg_backup(u8 timeset) {
    if (RTC_OFF) return;                 /* NO SD: flag from the boot/SET load */
    cfg_load();
    backup_take(timeset ? 'T' : 'B', timeset);
    cfg_save();
}

#ifdef EZCFG_RTCLOG
/* Prepend one fixed-width RTCLOG= entry: the raw registers of the last read
 * as YYMMDDhhmmss (hex, so flag bits and garbage show as-is) and an event:
 *   boot, first read suspect (see rtc_suspect): Z year 2000, I invalid,
 *     V VL flag set, E earlier than RTC=; then after the settle wait:
 *     S looked fine after all, or Y/N the prompt answered A/B
 *   L  game launch    B  BACKUPSAVE dump    T  TIME SET confirm
 * A normal boot logs nothing and does not write the file.
 * The oldest entries drop off past LOG_MAX. */
static void log_add(u8 ev) {
    static const u8 order[6] = {R_YR, R_MON, R_DAY, R_HR, R_MIN, R_SEC};
    u8 i, n;
    n = LOG_LEN;
    if (n > LOG_MAX - LOG_ENT) n = LOG_MAX - LOG_ENT;
    for (i = n; i != 0; i--) LOG_BUF[i - 1 + LOG_ENT] = LOG_BUF[i - 1];
    for (i = 0; i < 6; i++) put_hex(LOG_BUF + 2 * i, RTC_RAW[order[i]]);
    LOG_BUF[12] = ev;
    LOG_BUF[13] = ' ';
    LOG_LEN = n + LOG_ENT;
}
#endif

/* The FPGA serves the PCF8563 through a register copy it fills over I2C. On a
 * soft reset that copy stays live, but on a cold power-up this hook runs very
 * early and the copy may not be filled yet. Wait, then read until two reads a
 * frame apart agree. */
#define SETTLE_FRAMES 60             /* ~1 s */
#define SETTLE_TRIES  8

static void rtc_read_settled(void) {
    u8 i, t, same;
    u8 prev[7];
    for (i = 0; i < SETTLE_FRAMES; i++) WaitVBlankFlag();
    rtc_read();
    for (t = 0; t < SETTLE_TRIES; t++) {
        for (i = 0; i < 7; i++) prev[i] = RTC_CUR[i];
        WaitVBlankFlag();
        rtc_read();
        same = 1;
        for (i = 0; i < 7; i++) if (prev[i] != RTC_CUR[i]) same = 0;
        if (same) return;
    }
}

/* Why the last read looks like clock damage, or 0. Checked against a stored
 * RTC= only, so there is always something to restore:
 *   Z  year 2000, what a PCF8563 that lost power comes back as
 *   I  not a valid BCD date/time
 *   V  VL set: the chip's supply dipped too low to guarantee the time
 *   E  earlier than RTC=; the backup is refreshed at every launch and dump,
 *      so the clock stopped or glitched
 * None of these writes the clock on its own: an unsettled cold-boot read that
 * looked "earlier than stored" once rolled the clock back automatically, and
 * the next launch of an RTC game zeroed the game's clock (see the clamp in
 * docs/ezgb-cfg.md). The user decides in restore_prompt. */
static u8 rtc_suspect(void) {
    if (RTC_CUR[R_YR] == 0x00) return 'Z';
    if (!rtc_valid(RTC_CUR)) return 'I';
    if (RTC_RAW[R_SEC] & 0x80) return 'V';
    if (rtc_cmp(RTC_CUR, RTC_BK) < 0) return 'E';
    return 0;
}

/* The from-source stage1 (bitstream-re: stage1/src/main.c) writes "S1" to
 * pSRAM page $11 $A410 when START was held at power-on: the user canceled
 * fast launch there, so the kernel must not fast launch either, even with
 * START released by now. Consumed here, once per boot, by marking
 * fastlaunch_boot's one-shot flag ($DBFF) as already used. Page $11 is
 * free from $A400 (docs/psram-page-map.md); RtcBootHook re-selects page
 * $11 and personality 3 after this op, as before. */
static void stage1_skip_mark(void) {
    volatile u8 *mark = (volatile u8 *)0xA410;
    *(volatile u8 *)0x4000 = 0x11;
    fpga_page(3);
    if (mark[0] == 'S' && mark[1] == '1') {
        mark[0] = 0;
        mark[1] = 0;
        *(volatile u8 *)0xDBFF = 1;
    }
    *(volatile u8 *)0x4000 = 0;
    fpga_page(0);
}

static void cfg_restore(void) {
    u8 why;
    stage1_skip_mark();
    cfg_load();
    if (RTC_OFF || !RTC_VALID) return;   /* NO SD: never read the clock or ask */
    rtc_read();
    why = rtc_suspect();
    if (why == 0) return;                /* normal boots never wait or write */
    LOG(why);
    rtc_read_settled();
    why = rtc_suspect();
    if (why == 0) {
        LOG('S');
    } else if (restore_prompt(why)) {
        LOG('Y');
        rtc_write(RTC_BK);
    } else {
        LOG('N');
        /* Keep the chip's time, but rewrite it so VL clears and the prompt
         * does not return every boot for a time the user accepted. */
        if (why == 'V') rtc_write(RTC_CUR);
    }
#ifdef EZCFG_RTCLOG
    cfg_save();                          /* record the events */
#endif
}

/* Two hex digits (the raw BCD nibbles, so a garbage read shows as such). */
static void put_hex(u8 *dst, u8 v) {
    u8 h = v >> 4, l = v & 0x0F;
    dst[0] = h < 10 ? '0' + h : 'A' - 10 + h;
    dst[1] = l < 10 ? '0' + l : 'A' - 10 + l;
}

/* The RTC restore prompt, in the look of the START overlay and the
 * BACKUPSAVE prompt (docs/modal-prompts.md): one box, rules under the title
 * and above the options, a vertical rule between the options, in the font
 * of the UI mode. Shows why, the chip's settled reading (raw hex, so garbage
 * and the VL bit show as-is) and the RTC= backup, and asks which to keep:
 *
 *   RTC RESET?          Z  (RTC BAD? I, RTC LOW V? V, RTC BEHIND? E)
 *   CHIP 00-01-01
 *        00:00:05
 *   SD   26-09-29
 *        12:38:24
 *   [B]keep | [A]use SD
 *
 *   8px   box (0,27)-(159,99); rows 4, 6..9, 11; rules y 43 and 83
 *   12px  box (0,20)-(159,115); rows at y 24, 44..80, 100; rules y 38 and 95
 *
 * Returns 1 for A (restore RTC=). Waits out the joypad latch and any held
 * button first (docs/joypad-latch.md: a tap from before the box existed would
 * answer it unseen), then for the release so the press cannot carry into the
 * BACKUPSAVE [A]OK prompt that follows, and clears the box. "Micro SD initial
 * OK!" sits on row 0, outside the box. */
static void put_date(u8 *d, const u8 *r) {
    put_hex(d, r[R_YR]);      d[2] = '-';
    put_hex(d + 3, r[R_MON]); d[5] = '-';
    put_hex(d + 6, r[R_DAY]);
}

static void put_time(u8 *t, const u8 *r) {
    put_hex(t, r[R_HR]);      t[2] = ':';
    put_hex(t + 3, r[R_MIN]); t[5] = ':';
    put_hex(t + 6, r[R_SEC]);
}

/* One piece of prompt text: n characters at (col, row) of the 8x8 grid, or
 * the 12px row at y12 from x12 (1 = the text margin, x 12; else a pixel x). */
static void prow(const u8 *s, u8 n, u8 col, u8 row, u8 x12, u8 y12) {
    if (UI_MODE) DrawString12(0, 0, 0, s, n, x12, y12);
    else DrawString(s, n, col, row);
}

static u8 restore_prompt(u8 why) {
    static const u8 pad[2]    = {' ', 0};
    static const u8 t_z[11]   = {'R','T','C',' ','R','E','S','E','T','?',0};
    static const u8 t_i[9]    = {'R','T','C',' ','B','A','D','?',0};
    static const u8 t_v[11]   = {'R','T','C',' ','L','O','W',' ','V','?',0};
    static const u8 t_e[12]   = {'R','T','C',' ','B','E','H','I','N','D','?',0};
    static const u8 chip_s[5] = {'C','H','I','P',0};
    static const u8 sd_s[3]   = {'S','D',0};
    /* "[B]keep" at 0, "[A]use SD" at 10 */
    static const u8 btn[20]   = {'[','B',']','k','e','e','p',' ',' ',' ',
                                 '[','A',']','u','s','e',' ','S','D',0};
    u8 l[9];
    u8 k, yes, m;
    const u8 *title;

    title = why == 'Z' ? t_z : why == 'I' ? t_i : why == 'V' ? t_v : t_e;
    for (k = 0; title[k]; k++) {}
    m = UI_MODE;
    l[8] = 0;

    DrawString(pad, 1, 5, 8);
    StoreDrawParams(0, 0, 0);
    DrawRect(0, 16, 159, 127, 1);
    StoreDrawParams(3, 0, 0);
    if (m) DrawRect(0, 20, 159, 115, 1); else DrawRect(0, 27, 159, 99, 1);
    prow(title, k, 1, 4, 1, 24);
    prow(chip_s, 4, 1, 6, 1, 44);
    put_date(l, RTC_RAW); prow(l, 8, 6, 6, 60, 44);
    put_time(l, RTC_RAW); prow(l, 8, 6, 7, 60, 56);
    prow(sd_s, 2, 1, 8, 1, 68);
    put_date(l, RTC_BK);  prow(l, 8, 6, 8, 60, 68);
    put_time(l, RTC_BK);  prow(l, 8, 6, 9, 60, 80);
    if (m) {
        DrawString12(0, 0, 0, btn, 7, 1, 100);
        DrawString12(0, 0, 0, btn + 10, 0, 88, 100);   /* right of the rule at x 79 */
        /* a 12px row runs to x 159, over the box's right side */
        DrawRect(0, 20, 159, 115, 0);
        StoreDrawParams(3, 3, 0);
        DrawRect(0, 38, 159, 38, 1);
        DrawRect(0, 95, 159, 95, 1);
        DrawRect(79, 95, 79, 115, 1);
    } else {
        DrawString(btn, 7, 1, 11);
        DrawString(btn + 10, 9, 10, 11);
        StoreDrawParams(3, 3, 0);
        DrawRect(0, 43, 159, 43, 1);
        DrawRect(0, 83, 159, 83, 1);
        DrawRect(75, 83, 75, 99, 1);
    }
    StoreDrawParams(3, 0, 0);

    for (k = 0; k < 8; ) {
        WaitVBlankFlag();
        if (ReadJoypad() & 0x30) k = 0; else k++;
    }
    for (;;) {
        WaitVBlankFlag();
        k = ReadJoypad();
        if (k & 0x10) { yes = 1; break; }   /* A */
        if (k & 0x20) { yes = 0; break; }   /* B */
    }
    while (ReadJoypad() & 0x30) WaitVBlankFlag();

    StoreDrawParams(0, 0, 0);
    DrawRect(0, 16, 159, 127, 1);
    return yes;
}

/* ---- file I/O ---- */

static void copy_name(const u8 *name) {
    u8 i;
    for (i = 0; ; i++) { FL_SCR[i] = name[i]; if (name[i] == 0) break; }
}

/* Open name read-only and read up to REC_LEN bytes into CFGBUF. Returns 1 if
 * the file opened (br may be 0), 0 if it does not exist. */
static u8 open_read(const u8 *name, u16 *br) {
    u8 r;
    copy_name(name);
    sd_prep();
    if (FarCall_06_7309(FIL_OBJ, FL_SCR, FA_READ) != 0) return 0;
    sd_prep();
    /* One whole-sector read: for our own REC_LEN files this is FatFs's direct
     * path (see far_write). A shorter file takes the partial path, whose copy
     * is 8-bit: up to 255 bytes it is complete; 256..511 bytes land only
     * (size & 0xFF), so trust just that prefix (a 320-byte record from mod
     * 3.6-4.2 keeps its FLAUNCH line and is rewritten whole at the next save). */
    r = FarCall_06_779a(FIL_OBJ, CFGBUF, REC_LEN, br);
    sd_prep();
    FarCall_03_768f(FIL_OBJ);
    if (r != 0) *br = 0;
    else if (*br > 0xFF && *br < REC_LEN) *br &= 0xFF;
    return 1;
}

/* This kernel's FatFs copies a partial-sector transfer through the FIL
 * buffer with an 8-bit byte count (the kernel itself only ever writes whole
 * sectors or 48-byte records), so a single 320-byte write used to land only
 * 320 & 0xFF = 64 bytes while the file pointer still advanced by 320: the
 * rest of the record kept whatever the sector held before. Found on hardware
 * 2026-09-09 (a 60-byte FLAUNCH line pushed the RTC value past byte 64, so it
 * never reached the card). Splitting the write into two partial calls did
 * not work either (the second call restarted the sector). So the record is
 * exactly one sector, REC_LEN = 512, written in one call at offset 0: that is
 * FatFs's direct whole-sector path, the same one the kernel's own save dumps
 * take, and it never touches the 8-bit copy. Reads use the same whole-sector
 * call (see open_read). */
static u8 far_write(const u8 *buf, u16 len) {
    u16 bw;
    u8 r;
    sd_prep();
    r = FarCall_07_7739(FIL_OBJ, buf, len, &bw);
    if (r != 0) return r;
    return bw == len ? 0 : 0xFF;
}

static void cfg_load(void) {
    static const u8 cfg_name[10] = {'/','E','Z','G','B','.','C','F','G',0};
    static const u8 old_name[13] = {'/','F','L','A','U','N','C','H','.','C','F','G',0};
    u16 br;

    FL_EN = 1;
    FL_PLEN = 0;
    FL_PATH[0] = 0;
    RTC_VALID = 0;
    LR_VALID = 0;
    LR_PATH[0] = 0;
    RTC_OFF = 0;
#ifdef EZCFG_RTCLOG
    LOG_LEN = 0;
#endif

    if (open_read(cfg_name, &br)) {
        parse_record(br, 0);
        return;
    }
    /* Legacy: /FLAUNCH.CFG, line 1 = "[#]path". Migrated on the next SAVE. */
    if (open_read(old_name, &br)) parse_record(br, 1);
}

/* Walk CFGBUF[0..br) line by line. legacy=1: the first line is the FLAUNCH
 * value itself (no key). Only the first occurrence of each key counts, so a
 * stale tail left behind by a shorter rewrite cannot override the record. */
static void parse_record(u16 br, u8 legacy) {
    u16 p, s, e, eq;
    u8 seen_fl, seen_rtc, seen_lr, seen_ui, seen_rs;
#ifdef EZCFG_RTCLOG
    u8 seen_log = 0;
#endif

    if (br > CFG_MAX) br = CFG_MAX;
    CFGBUF[br] = 0;
    seen_fl = 0;
    seen_rtc = 0;
    seen_lr = 0;
    seen_ui = 0;
    seen_rs = 0;
    p = 0;
    for (;;) {
        if (p >= br) break;
        s = p;
        while (s < br && CFGBUF[s] == ' ') s++;
        e = s;
        while (e < br && CFGBUF[e] != 0x0d && CFGBUF[e] != 0x0a && CFGBUF[e] != 0) e++;
        p = e;
        while (p < br && (CFGBUF[p] == 0x0d || CFGBUF[p] == 0x0a)) p++;
        if (CFGBUF[e] == 0 && e < br) p = br;         /* NUL: stop after this line */
        while (e > s && CFGBUF[e - 1] == ' ') e--;
        if (e == s) continue;
        if (legacy) {
            parse_flaunch(CFGBUF + s, (u8)(e - s));
            return;
        }
        eq = s;
        while (eq < e && CFGBUF[eq] != '=') eq++;
        if (eq >= e) continue;
        {
            u8 klen = (u8)(eq - s);
            u16 vs = eq + 1;
            while (klen != 0 && CFGBUF[s + klen - 1] == ' ') klen--;
            while (vs < e && CFGBUF[vs] == ' ') vs++;
            if (!seen_fl && key_is(CFGBUF + s, klen, (const u8 *)"flaunch", 7)) {
                seen_fl = 1;
                parse_flaunch(CFGBUF + vs, (u8)(e - vs));
            } else if (!seen_rtc && key_is(CFGBUF + s, klen, (const u8 *)"rtc", 3)) {
                seen_rtc = 1;
                parse_rtc(CFGBUF + vs, (u8)(e - vs));
            } else if (!seen_lr && key_is(CFGBUF + s, klen, (const u8 *)"lastrom", 7)) {
                seen_lr = 1;
                parse_lastrom(CFGBUF + vs, e - vs);
            } else if (!seen_ui && key_is(CFGBUF + s, klen, (const u8 *)"ui", 2)) {
                seen_ui = 1;
                UI_MODE = (e - vs >= 2 && CFGBUF[vs] == '1' && CFGBUF[vs + 1] == '2') ? 1 : 0;
            } else if (!seen_rs && key_is(CFGBUF + s, klen, (const u8 *)"rtcsd", 5)) {
                seen_rs = 1;
                RTC_OFF = (e > vs && CFGBUF[vs] == '0') ? 1 : 0;
#ifdef EZCFG_RTCLOG
            } else if (!seen_log && key_is(CFGBUF + s, klen, (const u8 *)"rtclog", 6)) {
                u16 j, len = e - vs + 1;    /* the trimmed last entry's space */
                u8 whole = 0;
                seen_log = 1;
                if (len > LOG_MAX) len = LOG_MAX;
                while (whole + LOG_ENT <= len) whole += LOG_ENT;
                len = whole;
                for (j = 0; j < len; j++) LOG_BUF[j] = CFGBUF[vs + j];
                if (len != 0) LOG_BUF[len - 1] = ' ';
                LOG_LEN = (u8)len;
#endif
            }
        }
    }
}

static u8 lower(u8 c) {
    return (c >= 'A' && c <= 'Z') ? (u8)(c + 32) : c;
}

static u8 key_is(const u8 *k, u8 klen, const u8 *lit, u8 litlen) {
    u8 i;
    if (klen != litlen) return 0;
    for (i = 0; i < klen; i++) if (lower(k[i]) != lit[i]) return 0;
    return 1;
}

/* "[#][/]path": '#' = disabled. A path gets a leading '/' if missing. */
static void parse_flaunch(const u8 *v, u8 len) {
    u8 i, n;
    i = 0;
    if (len != 0 && v[0] == '#') {
        FL_EN = 0;
        i = 1;
        while (i < len && v[i] == ' ') i++;
    }
    if (i >= len) return;
    n = 0;
    if (v[i] != '/') FL_PATH[n++] = '/';
    for (; i < len && n < PATH_MAX; i++) FL_PATH[n++] = v[i];
    FL_PATH[n] = 0;
    FL_PLEN = n;
}

/* Split the value into six numeric fields on any non-digit (YYYY-MM-DD
 * HH:MM:SS), keeping the LAST two digits of each as a BCD byte. This tolerates
 * a 2-, 3- or 4-digit year (a stale file with "026" or "26" still restores;
 * the century is implicitly dropped) and is rewritten cleanly on the next
 * save. Needs exactly six fields, else the line is ignored. */
static void parse_rtc(const u8 *v, u8 len) {
    u8 f[6];
    u8 fi, d0, d1, ndig, i, c;

    for (i = 0; i < 6; i++) f[i] = 0;
    fi = 0; d0 = 0; d1 = 0; ndig = 0;
    for (i = 0; i <= len; i++) {
        c = (i < len) ? v[i] : 0;
        if (c >= '0' && c <= '9') {
            d0 = d1;
            d1 = (u8)(c - '0');
            ndig++;
        } else {
            if (ndig != 0 && fi < 6) f[fi++] = (u8)((d0 << 4) | d1);
            d0 = 0; d1 = 0; ndig = 0;
            if (c == 0) break;
        }
    }
    if (fi < 6) return;
    RTC_BK[R_YR]  = f[0];
    RTC_BK[R_MON] = f[1];
    RTC_BK[R_DAY] = f[2];
    RTC_BK[R_WD]  = 0x03;                 /* what the SET tab writes */
    RTC_BK[R_HR]  = f[3];
    RTC_BK[R_MIN] = f[4];
    RTC_BK[R_SEC] = f[5];
    RTC_VALID = rtc_valid(RTC_BK);
}

/* Two ASCII digits from a BCD byte; returns bytes written (2). */
static u8 put_bcd(u8 *dst, u8 v) {
    dst[0] = '0' + (v >> 4);
    dst[1] = '0' + (v & 0x0F);
    return 2;
}

/* Rewrite /EZGB.CFG as a fixed REC_LEN record (space padded past the last
 * line) so a shorter record fully covers a longer old one without
 * f_truncate. Returns FRESULT (0 = ok). */
static u8 cfg_save(void) {
    static const u8 cfg_name[10] = {'/','E','Z','G','B','.','C','F','G',0};
    static const u8 k_fl[8]  = {'F','L','A','U','N','C','H','='};
    static const u8 k_rtc[6] = {'R','T','C','=','2','0'};
    static const u8 k_lr[8]  = {'L','A','S','T','R','O','M','='};
    static const u8 k_ui[3]  = {'U','I','='};
    u16 n;
    u8 i, r;

    n = 0;
    for (i = 0; i < 8; i++) CFGBUF[n++] = k_fl[i];
    if (!FL_EN) CFGBUF[n++] = '#';
    for (i = 0; i < FL_PLEN; i++) CFGBUF[n++] = FL_PATH[i];
    CFGBUF[n++] = 0x0d;
    CFGBUF[n++] = 0x0a;
    if (RTC_VALID) {
        for (i = 0; i < 6; i++) CFGBUF[n++] = k_rtc[i];
        n += put_bcd(CFGBUF + n, RTC_BK[R_YR]);
        CFGBUF[n++] = '-';
        n += put_bcd(CFGBUF + n, RTC_BK[R_MON]);
        CFGBUF[n++] = '-';
        n += put_bcd(CFGBUF + n, RTC_BK[R_DAY]);
        CFGBUF[n++] = ' ';
        n += put_bcd(CFGBUF + n, RTC_BK[R_HR]);
        CFGBUF[n++] = ':';
        n += put_bcd(CFGBUF + n, RTC_BK[R_MIN]);
        CFGBUF[n++] = ':';
        n += put_bcd(CFGBUF + n, RTC_BK[R_SEC]);
        CFGBUF[n++] = 0x0d;
        CFGBUF[n++] = 0x0a;
    }
    if (LR_VALID) {
        for (i = 0; i < 8; i++) CFGBUF[n++] = k_lr[i];
        for (i = 0; LR_PATH[i]; i++) CFGBUF[n++] = LR_PATH[i];
        CFGBUF[n++] = 0x0d;
        CFGBUF[n++] = 0x0a;
    }
    for (i = 0; i < 3; i++) CFGBUF[n++] = k_ui[i];
    if (UI_MODE) CFGBUF[n++] = '1';
    CFGBUF[n++] = UI_MODE ? '2' : '8';
    CFGBUF[n++] = 0x0d;
    CFGBUF[n++] = 0x0a;
    if (RTC_OFF) {
        static const u8 k_rs[7] = {'R','T','C','S','D','=','0'};
        for (i = 0; i < 7; i++) CFGBUF[n++] = k_rs[i];
        CFGBUF[n++] = 0x0d;
        CFGBUF[n++] = 0x0a;
    }
#ifdef EZCFG_RTCLOG
    if (LOG_LEN != 0) {
        static const u8 k_log[7] = {'R','T','C','L','O','G','='};
        for (i = 0; i < 7; i++) CFGBUF[n++] = k_log[i];
        for (i = 0; i < LOG_LEN - 1; i++) CFGBUF[n++] = LOG_BUF[i];
        CFGBUF[n++] = 0x0d;
        CFGBUF[n++] = 0x0a;
    }
#endif
    while (n < REC_LEN) CFGBUF[n++] = ' ';

    copy_name(cfg_name);
    sd_prep();
    r = FarCall_06_7309(FIL_OBJ, FL_SCR, FA_CREATE);
    if (r != 0) return r;
    r = far_write(CFGBUF, REC_LEN);
    sd_prep();
    FarCall_03_768f(FIL_OBJ);
    return r;
}

/* ---- LASTROM: the START overlay's fallback when the $A300 record died ---- */

/* "[/]path" -> LR_PATH, capped at PATH_MAX. Empty value = no entry. */
static void parse_lastrom(const u8 *v, u16 len) {
    u8 n;
    u16 i;
    if (len == 0) return;
    n = 0;
    if (v[0] != '/') LR_PATH[n++] = '/';
    for (i = 0; i < len && n < PATH_MAX; i++) LR_PATH[n++] = v[i];
    LR_PATH[n] = 0;
    LR_VALID = 1;
}

/* A plausible launch path: starts with '/', NUL within 254 bytes, no control
 * bytes or $FF, and a non-empty basename containing a '.'. Random NVRAM
 * fails the first byte alone with probability 255/256. */
static u8 path_valid(const u8 *p) {
    u8 i, c, dot, base;
    if (p[0] != '/') return 0;
    dot = 0;
    base = 1;
    for (i = 1; ; i++) {
        if (i == 255) return 0;
        c = p[i];
        if (c == 0) break;
        if (c < 0x20 || c == 0xFF) return 0;
        if (c == '/') { base = (u8)(i + 1); dot = 0; }
        if (c == '.') dot = 1;
    }
    return (i > base && dot) ? 1 : 0;
}

/* Launch (LastRomPersist, 01:4856): record the launch path as LASTROM=.
 * Runs before the kernel selects its NVRAM page, so no FPGA state to restore. */
static void lastrom_save(void) {
    u8 n;
    cfg_load();
    for (n = 0; n <= PATH_MAX && LAUNCH_PATH[n]; n++) {}
    if (n != 0 && n <= PATH_MAX) {
        u8 i;
        for (i = 0; i < n; i++) LR_PATH[i] = LAUNCH_PATH[i];
        LR_PATH[n] = 0;
        LR_VALID = 1;
    }
    if (!RTC_OFF) backup_take('L', 0);   /* the file is rewritten anyway: keep RTC= current */
    cfg_save();
}

/* START overlay (after LastRomLoadRecord copied $A300 into OVL_PATH):
 * EZ_RES = 1 with a usable path in OVL_PATH, else "(none)" is shown until B
 * and EZ_RES = 0. The NVRAM copy wins when it is valid (no SD access at all);
 * otherwise the file's LASTROM= takes its place. */
static void lastrom_load(void) {
    static const u8 none_str[7] = {'(','n','o','n','e',')',0};
    u8 i;
    if (path_valid(OVL_PATH)) { EZ_RES = 1; return; }
    cfg_load();
    if (LR_VALID && path_valid(LR_PATH)) {
        for (i = 0; ; i++) { OVL_PATH[i] = LR_PATH[i]; if (LR_PATH[i] == 0) break; }
        fpga_page(3);                     /* what LastRomOverlay had selected */
        EZ_RES = 1;
        return;
    }
    LastRomName(0, 0, 0, none_str, 0x12, 1, 0x0f);  /* the overlay's name line, in the UI mode's font */
    for (;;) {
        WaitVBlankFlag();
        if (ReadJoypad() & 0x20) break;   /* B */
    }
    EZ_RES = 0;
}

/* Boot (SaveStampHook, 00:03aa): the page-$11 stamp said a backup is pending
 * ($A000 = $AA) and BackupBranchEntry copied its save path to SAVE_PATH.
 * The stamp is battery-backed like the $A300 record, and without a cell the
 * flag can survive while the path is garbage, which the prompt then showed
 * as the save's name (and A would have dumped under it). EZ_RES = 1 only for
 * what PreLaunchSaveStamp writes: "/SAVER/" + a plausible file name. Touches
 * no hardware, so the FPGA page is the caller's. */
static void savestamp_check(void) {
    static const u8 dir[7] = {'/','S','A','V','E','R','/'};
    u8 i;
    EZ_RES = 0;
    for (i = 0; i < 7; i++) if (SAVE_PATH[i] != dir[i]) return;
    EZ_RES = path_valid(SAVE_PATH);
}
