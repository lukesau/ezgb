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
 *   op 2 BACKUP   LOAD, read the RTC; if it is valid and later than the
 *                 stored copy, store it and SAVE. Hooked after every
 *                 BACKUPSAVE dump and after a SET-tab TIME SET confirm.
 *   op 3 RESTORE  LOAD; if the file holds a time and the RTC is unreadable,
 *                 earlier than it, or the BATTERY DRY prompt fired this boot
 *                 (DRY flag $DBFD), write the stored time back to the RTC.
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
 * RtcToDayCount (01:4c5e). Writing is the SET tab's recipe
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
#define RTC_RAW   ((u8 *)0xDB50)     /* EZCFG_RTCRAW builds: the unmasked register bytes */
#define DBG_VALID (*(volatile u8 *)0xDB57)  /* EZCFG_RTCRAW: validity bits of the last BACKUP */
#define DBG_CMP   (*(volatile u8 *)0xDB58)  /* EZCFG_RTCRAW: compare result of the last BACKUP */
#define EZ_OP     (*(volatile u8 *)0xDBFC)
#define DRY_FLAG  (*(volatile u8 *)0xDBFD)  /* set by BatteryDryHook (00:0530) */
#define LR_PATH   ((u8 *)0xDA00)     /* LASTROM= path, NUL-terminated, <= PATH_MAX */
#define LR_VALID  (*(volatile u8 *)0xDA7F)
#define EZ_RES    (*(volatile u8 *)0xDBFB)  /* op result for the bank-0/1 stubs */
#define LAUNCH_PATH ((u8 *)0xC2A6)   /* kernel: assembled launch path (LoaderPrepPath) */
#define OVL_PATH    ((u8 *)0xC4A4)   /* kernel: START overlay's copy of the $A300 record */

#define OP_LOAD    0
#define OP_SAVE    1
#define OP_BACKUP  2
#define OP_RESTORE 3
#define OP_LASTSAVE 4              /* launch: record the launch path as LASTROM= */
#define OP_LASTLOAD 5              /* START overlay: validate $A300 copy, else fall back to LASTROM= */

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
static void rtc_write(void);
static u8 rtc_valid(const u8 *r);
static u8 bcd_ok(u8 v, u8 max);
static signed char rtc_cmp(const u8 *a, const u8 *b);
static u8 put_bcd(u8 *dst, u8 v);
static void cfg_backup(void);
static void cfg_restore(void);
static void parse_lastrom(const u8 *v, u16 len);
static u8 path_valid(const u8 *p);
static void lastrom_save(void);
static void lastrom_load(void);

extern void DrawString(const u8 *s, u8 len, u8 x, u8 y);   /* 00:08b7 */
extern u8 ReadJoypad(void);                                 /* 00:3a4a, E = key byte, B = $20 */

void ezcfg(void) {
    u8 op = EZ_OP;
    if (op == OP_LOAD) { cfg_load(); return; }
    if (op == OP_SAVE) { cfg_save(); return; }
    if (op == OP_BACKUP) { cfg_backup(); return; }
    if (op == OP_LASTSAVE) { lastrom_save(); return; }
    if (op == OP_LASTLOAD) { lastrom_load(); return; }
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
    fpga_page(6);
#ifdef EZCFG_RTCRAW
    for (i = 0; i < 7; i++) RTC_RAW[i] = RTC_WIN[i];
#endif
    for (i = 0; i < 7; i++) RTC_CUR[i] = RTC_WIN[i] & rtc_mask[i];
    fpga_page(0);
}

static void rtc_write(void) {
    u8 i;
    fpga_page(6);
    for (i = 0; i < 7; i++) RTC_WIN[i] = RTC_BK[i];
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

static void cfg_backup(void) {
    cfg_load();
    rtc_read();
#ifdef EZCFG_RTCRAW
    DBG_VALID = (RTC_VALID ? 1 : 0) | (rtc_valid(RTC_CUR) ? 2 : 0);
    DBG_CMP = RTC_VALID ? (u8)(rtc_cmp(RTC_CUR, RTC_BK) + 1) : 9;
    if (!rtc_valid(RTC_CUR) || (RTC_VALID && rtc_cmp(RTC_CUR, RTC_BK) <= 0)) {
        cfg_save();  /* diagnostic: record what the registers held anyway */
        return;
    }
#else
    if (!rtc_valid(RTC_CUR)) return;
    if (RTC_VALID && rtc_cmp(RTC_CUR, RTC_BK) <= 0) return;
#endif
    {
        u8 i;
        for (i = 0; i < 7; i++) RTC_BK[i] = RTC_CUR[i];
    }
    RTC_VALID = 1;
    cfg_save();
}

static void cfg_restore(void) {
    cfg_load();
    if (!RTC_VALID) return;
    rtc_read();
    if (DRY_FLAG || !rtc_valid(RTC_CUR) || rtc_cmp(RTC_CUR, RTC_BK) < 0) {
        rtc_write();
    }
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
    u8 seen_fl, seen_rtc, seen_lr;

    if (br > CFG_MAX) br = CFG_MAX;
    CFGBUF[br] = 0;
    seen_fl = 0;
    seen_rtc = 0;
    seen_lr = 0;
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
#ifdef EZCFG_RTCRAW
    {
        /* RTCRAW=<7 raw regs> <7 masked regs> <7 stored regs> V<valid> C<cmp>
         * valid: RTC_VALID before this op | rtc_valid(masked)<<1; cmp: 0/1/2
         * for RTC earlier/equal/later than stored (9 when nothing stored).
         * Diagnostic builds only; ignored by the parser. */
        static const u8 k_raw[7] = {'R','T','C','R','A','W','='};
        u8 d, j;
        const u8 *src;
        for (i = 0; i < 7; i++) CFGBUF[n++] = k_raw[i];
        for (j = 0; j < 3; j++) {
            src = j == 0 ? RTC_RAW : j == 1 ? RTC_CUR : RTC_BK;
            for (i = 0; i < 7; i++) {
                d = src[i] >> 4;   CFGBUF[n++] = d < 10 ? '0' + d : 'A' + d - 10;
                d = src[i] & 0x0F; CFGBUF[n++] = d < 10 ? '0' + d : 'A' + d - 10;
            }
            CFGBUF[n++] = ' ';
        }
        CFGBUF[n++] = 'V'; CFGBUF[n++] = '0' + DBG_VALID;
        CFGBUF[n++] = 'C'; CFGBUF[n++] = '0' + DBG_CMP;
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
    DrawString(none_str, 0x14, 0, 0x0f);  /* the overlay's basename line */
    for (;;) {
        WaitVBlankFlag();
        if (ReadJoypad() & 0x20) break;   /* B */
    }
    EZ_RES = 0;
}
