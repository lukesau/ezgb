/* Save manager file work: list, back up, restore, delete (docs/save-manager.md).
 *
 * Bank 1, injected at 01:7670. Far target of SmSaveOp (04:65f0), which the
 * save manager's screens (save_mgr.c, bank 4) call with an op and a list
 * index packed in one word, op in the high byte:
 *
 *   SO_SCAN     list /SAVER: LIVE, COUNT and LIST for the ROM at $c4a4
 *   SO_BACKUP   copy the live save to a new backup named after its time
 *   SO_RESTORE  back the live save up, then copy backup idx over it
 *   SO_DELETE   delete backup idx (FsUnlink, bank 9)
 *   SO_LABEL    backup idx's time as "YY-MM-DD HH:MM (n)" into LABEL
 *   SO_DONE     $7FC0 back to $03 and $4000 to page idx (the browser's)
 *
 * Returns 1 on success. The list is stale after any op that writes (a copy
 * uses its memory too); the caller rescans.
 *
 * <base> is the ROM's file name without .gb/.gbc, as BackupOpenSaverPath
 * names the save (Tetris.gb -> /SAVER/Tetris.sav). A backup is
 *
 *   /SAVER/<base> YYYY-MM-DD HH-MM.sav, then " (2)", " (3)" ... before .sav
 *
 * with the save's last-modified time and the first counter not on the card.
 * This FatFs has no rename, so restore is a copy and the backup stays.
 *
 * Copies move whole 512-byte sectors: this FatFs copies a partial-sector
 * transfer with an 8-bit count (ezcfg.c far_write), so only a tail under
 * 256 bytes is safe. Saves are whole sectors plus at most the 48-byte RTC
 * footer; a file whose tail is 256..511 bytes is left out of the list.
 *
 * SD I/O discipline as in ezcfg.c: WaitVBlankFlag + $7FC0=$00 before every
 * FatFs call, paths in WRAM.
 *
 * WRAM (the fast-launch scan window and ezcfg's CFGBUF, both idle while the
 * browser waits for a key, a few bytes past the kernel's last variable, and
 * the loader's $C0A0 scratch, which only the launch and save paths use):
 *
 *   $D750  LABEL (24)
 *   $D770  LIVE: exists, then the save's time as a list entry (7)
 *   $D777  COUNT, $D778 BLEN
 *   scan:  FNO $D780, LFN $D7A0 (128), LIST $D820 (37 x 6), DIRO $D900
 *   copy:  FIL_B $D780 (a FIL is 544 bytes: this FatFs is not FS_TINY, each
 *          FIL carries its own sector buffer), PATH $D9A0 (96), BUF $C0A0
 *          (512)
 *
 * A list entry is the name's time: year-1980, month, day, hour, minute,
 * counter. The list holds the newest MAX_BK, newest first.
 *
 *   python3 tools/inject.py src/save_ops.c $V 1 7670 SaveOp \
 *       --pin WaitVBlankFlag=0688 --pin FarCall_06_7309=1926 \
 *       --pin FarCall_06_779a=1941 --pin FarCall_07_7739=1963 \
 *       --pin FarCall_03_768f=19a1 --pin SoOpendir=7630 --pin SoReaddir=7646 \
 *       --pin SoUnlink=765c --pin SoMatch=7d50 --apply
 */

#include "types.h"
#include "draw.h"

extern u8 FarCall_06_7309(u8 *fp, const u8 *path, u8 mode);         /* f_open  00:1926 */
extern u8 FarCall_06_779a(u8 *fp, u8 *buf, u16 btr, u16 *br);       /* f_read  00:1941 */
extern u8 FarCall_07_7739(u8 *fp, const u8 *buf, u16 btw, u16 *bw); /* f_write 00:1963 */
extern u8 FarCall_03_768f(u8 *fp);                                  /* f_close 00:19a1 */
extern u8 SoOpendir(u8 *dp, const u8 *path);                        /* 01:7630 -> Opendir_B5 */
extern u8 SoReaddir(u8 *dp, u8 *fno);                               /* 01:7646 -> Readdir_B5 */
extern u8 SoUnlink(const u8 *path);                                 /* 01:765c -> FsUnlink 09:7cc0 */
extern u8 SoMatch(const u8 *name, u8 *e);                           /* 01:7d50 -> SaveNameMatch 04:73a0, save_name.c */

#define NAME_BUF  ((const u8 *)0xC4A4)      /* the ROM's file name */
#define FIL_A     ((u8 *)0xCA0F)            /* kernel FIL, idle in the browser */
#define FIL_B     ((u8 *)0xD780)            /* 544: FIL keeps its own sector buffer */
#define LABEL     ((u8 *)0xD750)
#define LIVE      ((u8 *)0xD770)            /* [0] save exists, [1..6] its time */
#define COUNT     (*(volatile u8 *)0xD777)
#define BLEN      (*(volatile u8 *)0xD778)
#define FNO       ((u8 *)0xD780)            /* FILINFO, 26 */
#define LFN       ((u8 *)0xD7A0)
#define LIST      ((u8 *)0xD820)            /* between LFN and DIRO */
#define DIRO      ((u8 *)0xD900)            /* DIR, 26 */
#define PATH      ((u8 *)0xD9A0)            /* 96 */
#define BUF       ((u8 *)0xC0A0)            /* the loader's 512-byte scratch */

#define SO_SCAN    0
#define SO_BACKUP  1
#define SO_RESTORE 2
#define SO_DELETE  3
#define SO_LABEL   4
#define SO_DONE    5

#define ENT       6
#define MAX_BK    37
#define LFN_SIZE  128
#define BASE_MAX  60                        /* "/SAVER/" + base + " YYYY-MM-DD HH-MM (nnn).sav" < 96 */
#define FNO_DATE  4
#define FNO_TIME  6
#define FNO_ATTR  8
#define FNO_SFN   9
#define FNO_LFNP  22
#define FNO_LFNS  24
#define AM_DIR    0x10
#define FA_READ   0x01
#define FA_CREATE 0x0A                      /* FA_WRITE | FA_CREATE_ALWAYS */

static void fpga_page(u8 page);
static void sd_prep(void);
static void scan(void);
static void insert(const u8 *e);
static u8 *put_dec(u8 *d, u16 v, u8 w);
static u8 *fmt(u8 *d, const u8 *e, u8 name);
static void make_path(const u8 *e);
static u8 free_slot(u8 *e);
static u8 copy(const u8 *src, const u8 *dst);
static u8 back_up(void);
static u8 restore(const u8 *b);

/* The entry point stays the first function in the file. Far target: two
 * pad parameters. */
u8 SaveOp(u16 far_pad_af, u16 far_pad_ret, u16 opidx) {
    u8 b[ENT];
    u8 op = opidx >> 8, idx = (u8)opidx, i;

    (void)far_pad_af;
    (void)far_pad_ret;
    if (op == SO_DONE) {
        fpga_page(3);
        *(volatile u8 *)0x4000 = idx;
        return 1;
    }
    if (op == SO_SCAN) {
        for (i = 0; NAME_BUF[i]; i++) {}
        while (i && NAME_BUF[i - 1] != '.') i--;
        BLEN = i ? i - 1 : 0;
        COUNT = 0;
        LIVE[0] = 0;
        if (BLEN && BLEN <= BASE_MAX) scan();
        return 1;
    }
    if (op == SO_BACKUP) return LIVE[0] && back_up();
    for (i = 0; i < ENT; i++) b[i] = LIST[idx * ENT + i];
    if (op == SO_LABEL) {
        fmt(LABEL, b, 0);
        return 1;
    }
    if (op == SO_RESTORE) return restore(b);
    make_path(b);
    sd_prep();
    return SoUnlink(PATH) == 0;
}

/* ---- SD ---- */

static void fpga_page(u8 page) {
    *(volatile u8 *)0x7F00 = 0xE1;
    *(volatile u8 *)0x7F10 = 0xE2;
    *(volatile u8 *)0x7F20 = 0xE3;
    *(volatile u8 *)0x7FC0 = page;
    *(volatile u8 *)0x7FF0 = 0xE4;
}

static void sd_prep(void) {
    WaitVBlankFlag();
    fpga_page(0);
}

/* List /SAVER: the live save's time into LIVE, backups into LIST. */
static void scan(void) {
    static const u8 dir_str[7] = {'/','S','A','V','E','R',0};
    u8 e[ENT];
    const u8 *name;
    u8 i, k;

    COUNT = 0;
    LIVE[0] = 0;
    for (i = 0; i < 7; i++) PATH[i] = dir_str[i];
    sd_prep();
    if (SoOpendir(DIRO, PATH)) return;
    FNO[FNO_LFNP] = (u8)((u16)LFN & 0xFF);
    FNO[FNO_LFNP + 1] = (u8)((u16)LFN >> 8);
    FNO[FNO_LFNS] = LFN_SIZE;
    FNO[FNO_LFNS + 1] = 0;
    for (;;) {
        LFN[0] = 0;
        sd_prep();
        if (SoReaddir(DIRO, FNO) || FNO[FNO_SFN] == 0) break;
        if (FNO[FNO_ATTR] & AM_DIR) continue;
        if (FNO[1] & 1) continue;             /* tail of 256..511 bytes: not copyable */
        name = LFN[0] ? LFN : FNO + FNO_SFN;
        k = SoMatch(name, e);
        if (k == 1) {
            i = FNO[FNO_DATE];
            k = FNO[FNO_DATE + 1];
            LIVE[1] = k >> 1;                                 /* year - 1980 */
            LIVE[2] = (u8)(((k & 1) << 3) | (i >> 5));        /* month */
            LIVE[3] = i & 0x1F;                               /* day */
            i = FNO[FNO_TIME];
            k = FNO[FNO_TIME + 1];
            LIVE[4] = k >> 3;                                 /* hour */
            LIVE[5] = (u8)(((k & 7) << 3) | (i >> 5));        /* minute */
            LIVE[6] = 1;
            LIVE[0] = 1;
        } else if (k == 2) {
            insert(e);
        }
    }
}

static const u8 f_sep[5] = {' ', '-', '-', ' ', '-'};   /* save_name.c's separators */

/* Into LIST, newest first; the oldest drops off a full list. */
static void insert(const u8 *e) {
    u8 i, j, k;
    u8 *q;

    for (i = 0; i < COUNT; i++) {
        q = LIST + i * ENT;
        for (k = 0; k < ENT && e[k] == q[k]; k++) {}
        if (k < ENT && e[k] > q[k]) break;
    }
    if (i >= MAX_BK) return;
    j = COUNT < MAX_BK ? COUNT : MAX_BK - 1;
    for (; j > i; j--) {
        q = LIST + j * ENT;
        for (k = 0; k < ENT; k++) q[k] = q[k - ENT];
    }
    q = LIST + i * ENT;
    for (k = 0; k < ENT; k++) q[k] = e[k];
    if (COUNT < MAX_BK) COUNT++;
}

/* v in decimal, at least w digits. */
static u8 *put_dec(u8 *d, u16 v, u8 w) {
    static const u16 pw[4] = {1000, 100, 10, 1};
    u8 i, c, any = 0;

    for (i = 0; i < 4; i++) {
        for (c = 0; v >= pw[i]; c++) v -= pw[i];
        if (c || any || 4 - i <= w) {
            *d++ = (u8)('0' + c);
            any = 1;
        }
    }
    return d;
}

/* e's time at d: " YYYY-MM-DD HH-MM" for a file name (name = 1) or
 * "YY-MM-DD HH:MM" for the list, then " (n)" when the counter is above 1. */
static u8 *fmt(u8 *d, const u8 *e, u8 name) {
    u16 v;
    u8 i;

    for (i = 0; i < 5; i++) {
        if (i || name) *d++ = (!name && i == 4) ? ':' : f_sep[i];
        v = e[i];
        if (i == 0) {
            v += 1980;
            if (!name) while (v >= 100) v -= 100;
        }
        d = put_dec(d, v, (i == 0 && name) ? 4 : 2);
    }
    if (e[5] > 1) {
        *d++ = ' ';
        *d++ = '(';
        d = put_dec(d, e[5], 1);
        *d++ = ')';
    }
    *d = 0;
    return d;
}

/* PATH := "/SAVER/<base>.sav" (e == 0) or the backup name for e. */
static void make_path(const u8 *e) {
    static const u8 dir_str[7] = {'/','S','A','V','E','R','/'};
    static const u8 ext_str[5] = {'.','s','a','v',0};
    u8 *d = PATH;
    u8 i;

    for (i = 0; i < 7; i++) *d++ = dir_str[i];
    for (i = 0; i < BLEN; i++) *d++ = NAME_BUF[i];
    if (e) d = fmt(d, e, 1);
    for (i = 0; i < 5; i++) *d++ = ext_str[i];
}

/* The first counter whose name is not on the card, into e[5]. */
static u8 free_slot(u8 *e) {
    for (e[5] = 1; e[5] <= 250; e[5]++) {
        make_path(e);
        sd_prep();
        if (FarCall_06_7309(FIL_A, PATH, FA_READ)) return 1;
        sd_prep();
        FarCall_03_768f(FIL_A);
    }
    return 0;
}

/* Copy one save file to another (0 = the live save). */
static u8 copy(const u8 *src, const u8 *dst) {
    u16 br, bw;
    u8 r, ok = 0;

    make_path(src);
    sd_prep();
    if (FarCall_06_7309(FIL_A, PATH, FA_READ)) return 0;
    make_path(dst);
    sd_prep();
    if (FarCall_06_7309(FIL_B, PATH, FA_CREATE) == 0) {
        for (;;) {
            sd_prep();
            r = FarCall_06_779a(FIL_A, BUF, 512, &br);
            if (r) break;
            if (br == 0) { ok = 1; break; }
            if (br < 512 && br > 255) break;
            sd_prep();
            r = FarCall_07_7739(FIL_B, BUF, br, &bw);
            if (r || bw != br) break;
            if (br < 512) { ok = 1; break; }
        }
        sd_prep();
        if (FarCall_03_768f(FIL_B)) ok = 0;
    }
    sd_prep();
    FarCall_03_768f(FIL_A);
    return ok;
}

/* The live save to a new backup named after its time. */
static u8 back_up(void) {
    u8 e[ENT];
    u8 i;

    for (i = 0; i < ENT; i++) e[i] = LIVE[1 + i];
    if (!free_slot(e)) return 0;
    return copy(0, e);
}

/* Back the live save up (if any), then copy backup b over it. */
static u8 restore(const u8 *b) {
    if (LIVE[0] && !back_up()) return 0;
    return copy(b, 0);
}
