/* FastLaunch scan (root-only): decide at boot whether to skip the browser and
 * launch a ROM straight away, and report its full path in result_path
 * (leading '/', e.g. "/PKMRED.GB"). Two triggers:
 *
 *   1. Config file: /EZGB.CFG, key FLAUNCH = the ROM path (root or nested).
 *      A leading '#' on the value means fast launch is disabled outright.
 *      Parsed by the shared bank-2 module ezcfg.c (docs/ezgb-cfg.md), which
 *      also reads a legacy /FLAUNCH.CFG when EZGB.CFG is missing.
 *   2. Lone ROM: if the SD root holds exactly one real file (ignoring the
 *      kernel ezgb.dat, EZGB.CFG / FLAUNCH.CFG, dot-files, and macOS junk)
 *      and it is a .gb/.gbc, launch it.
 *
 * The config file takes priority. (An earlier "<name>.fastlaunch" marker-file
 * trigger was dropped 2026-09-07; the SET tab + config file replace it.) On
 * any "nothing to do" outcome (no trigger, any FatFs error) result_path[0] is
 * left 0 so the caller falls through to the normal menu.
 *
 * FILINFO layout (classic FatFs _USE_LFN external-buffer form) CONFIRMED live
 * against this exact kernel (see docs/fast-launch-notes.md):
 *   +0..3   fsize
 *   +8      fattrib (bit 4 / $10 = AM_DIR)
 *   +9..21  fname[13]  8.3 short name, NUL-terminated
 *   +22..23 lfname     POINTER to an external long-name buffer (set by us)
 *   +24..25 lfsize     size of that buffer
 * The long name lands in the buffer lfname points at; it is empty (buf[0]==0)
 * for an 8.3-only entry, so entry_name() falls back to fname. End-of-directory
 * is the standard FatFs contract: fname[0] == 0.
 *
 * Big buffers live at fixed WRAM scratch ($D780-$D980: below the $E000 stack,
 * above the kernel's variables which top out ~$D73B, cleared to 0 at boot), so
 * the scan keeps only a few bytes on the stack. Nothing else touches this
 * window during boot/browse. Only one DIR object is needed (no recursion).
 *
 * IMPORTANT for injection: SDCC/sdld link functions in source-declaration
 * order, and inject.py pins the FIRST-declared function, so fastlaunch_scan is
 * defined first, ahead of the static helpers it calls (forward-declared just
 * below).
 */

extern unsigned char FarCallOpendir_B5(unsigned char *dp, const unsigned char *path);
extern unsigned char FarCallReaddir_B5(unsigned char *dp, unsigned char *fno);
extern void FarCallSetPage(unsigned char page);   /* SetFpgaPage: $7FC0 = page */

/* Shared settings module (same bank, plain call; no stack args, op in WRAM). */
extern void ezcfg(void);                          /* 02:4a00 */
#define EZ_OP    (*(volatile unsigned char *)0xDBFC)
#define OP_LOAD  0
#define FL_EN    (*(volatile unsigned char *)0xDA80)
#define FL_PLEN  (*(volatile unsigned char *)0xDA81)
#define FL_PATH  ((unsigned char *)0xDA82)

/* FPGA personality selected via $7FC0. SD sector reads (DiskRead_B2) require
 * $00; the file-record window ($A000, where the browser rests) is $03. */
#define SD_PAGE     0x00
#define PSRAM_PAGE  0x03

/* Fixed WRAM scratch. */
#define FNO   ((unsigned char *)0xD780)  /* FILINFO, 26 used */
#define LFN   ((unsigned char *)0xD7A0)  /* long-name buffer, 256 */
#define NAME  ((unsigned char *)0xD8D0)  /* last real file's name, 48 */
#define DIRO  ((unsigned char *)0xD900)  /* the one DIR object, 128 reserved */

#define FNO_ATTRIB  8
#define FNO_SFN     9
#define FNO_LFNPTR  22
#define FNO_LFNSIZE 24
#define AM_DIR      0x10

#define LFN_SIZE  254
#define NAME_MAX  48

static unsigned char to_upper(unsigned char c);
static unsigned char strlen_u(const unsigned char *s);
static const unsigned char *entry_name(void);
static unsigned char is_end(void);
static void readdir_prep(void);
static unsigned char streq_ci(const unsigned char *a, const unsigned char *b);
static unsigned char is_rom(const unsigned char *name);
static void write_result(unsigned char *result_path, const unsigned char *name);
static void scan_root(void);
static unsigned char scan_config(void);

/* Takes no argument: it is reached by a far-call (FarCallTrampoline), which
 * shifts stack args by 6 bytes, so passing a pointer across it is fragile.
 * Instead it writes straight to the kernel's launch basename buffer $c4a4,
 * which is exactly where the launch step reads the path from. */
#define RESULT ((unsigned char *)0xC4A4)

/* SD reads must run under FPGA personality $7FC0=$00 (DiskRead_B2 does not set
 * it itself; DirList sets it before every f_readdir). The scan is entered with
 * the browser's resting $7FC0=$03 (the PSRAM record window), so it selects the
 * SD page for its reads and restores $03 on the way out. Skipping this reads the
 * wrong window and wedges the SD controller on real hardware, though it is
 * invisible in the emulator, whose stub ignores $7FC0. */
void fastlaunch_scan(void) {
    scan_root();
    FarCallSetPage(PSRAM_PAGE);
}

static void scan_root(void) {
    unsigned char *result_path = RESULT;
    unsigned char root[2];
    unsigned char realcount;
    unsigned char last_is_rom;
    const unsigned char *name;
    unsigned char i, n;

    result_path[0] = 0;

    /* Highest priority: FLAUNCH= in /EZGB.CFG. 1 = explicit path staged in
     * RESULT; 2 = fast launch DISABLED ('#' on the value): skip the lone-ROM
     * rule too, so the card always boots to the browser. */
    if (scan_config()) return;

    /* FILINFO.lfname = LFN buffer, FILINFO.lfsize = 254 (set once; reused). */
    FNO[FNO_LFNPTR]     = (unsigned char)((unsigned int)LFN & 0xFF);
    FNO[FNO_LFNPTR + 1] = (unsigned char)((unsigned int)LFN >> 8);
    FNO[FNO_LFNSIZE]     = (unsigned char)LFN_SIZE;
    FNO[FNO_LFNSIZE + 1] = 0;

    root[0] = '/';
    root[1] = 0;

    /* --- Classify the root --- */
    realcount = 0;
    last_is_rom = 0;

    FarCallSetPage(SD_PAGE);
    if (FarCallOpendir_B5(DIRO, root) != 0) return;
    for (;;) {
        readdir_prep();
        if (FarCallReaddir_B5(DIRO, FNO) != 0) return;
        if (is_end()) break;
        if (FNO[FNO_ATTRIB] & AM_DIR) continue;
        name = entry_name();
        if (name[0] == '.') continue;                 /* dot-files / macOS junk */
        if (streq_ci(name, (const unsigned char *)"ezgb.dat")) continue;
        if (streq_ci(name, (const unsigned char *)"ezgb.cfg")) continue;
        if (streq_ci(name, (const unsigned char *)"flaunch.cfg")) continue;

        /* A real file: count it and remember it (for the lone-ROM rule). */
        realcount++;
        n = strlen_u(name);
        if (n >= NAME_MAX) n = NAME_MAX - 1;
        for (i = 0; i < n; i++) NAME[i] = name[i];
        NAME[n] = 0;
        last_is_rom = is_rom(NAME);
    }

    /* --- Decide --- */
    if (realcount == 1 && last_is_rom) {
        write_result(result_path, NAME);
    }
}

static void write_result(unsigned char *result_path, const unsigned char *name) {
    unsigned char i;
    result_path[0] = '/';
    for (i = 0; name[i]; i++) result_path[1 + i] = name[i];
    result_path[1 + i] = 0;
}

/* Load /EZGB.CFG through ezcfg and stage the FLAUNCH path in RESULT ($c4a4)
 * with a leading '/'. Returns 1 when a path is staged, 2 when fast launch is
 * disabled ('#' on the value, from the SET tab; the path is kept in the file
 * for re-enabling, see docs/fastlaunch-set-tab.md), 0 otherwise. ezcfg does
 * the VBlank-wait + $7FC0=$00 discipline around its own SD I/O. The path may
 * be nested (e.g. /Pokemon/Blue.gb); the launch glue handles it. */
static unsigned char scan_config(void) {
    unsigned char *r = RESULT;
    unsigned char i;

    EZ_OP = OP_LOAD;
    ezcfg();
    if (!FL_EN) return 2;             /* disabled: no trigger at all */
    if (FL_PLEN == 0) return 0;
    for (i = 0; i < FL_PLEN; i++) r[i] = FL_PATH[i];
    r[i] = 0;
    return 1;
}

static unsigned char to_upper(unsigned char c) {
    if (c >= 'a' && c <= 'z') return c - 0x20;
    return c;
}

static unsigned char strlen_u(const unsigned char *s) {
    unsigned char n = 0;
    while (s[n]) n++;
    return n;
}

static unsigned char streq_ci(const unsigned char *a, const unsigned char *b) {
    unsigned char i = 0;
    for (;;) {
        unsigned char ca = to_upper(a[i]);
        unsigned char cb = to_upper(b[i]);
        if (ca != cb) return 0;
        if (ca == 0) return 1;
        i++;
    }
}

/* Long name if the readdir produced one, else the 8.3 short name. */
static const unsigned char *entry_name(void) {
    if (LFN[0] != 0) return LFN;
    return FNO + FNO_SFN;
}

static unsigned char is_end(void) {
    return FNO[FNO_SFN] == 0;
}

static void readdir_prep(void) {
    FarCallSetPage(SD_PAGE);   /* re-assert SD personality before every read (as DirList does) */
    FNO[FNO_SFN] = 0;
    LFN[0] = 0;
}

/* True if name ends in ".gb" or ".gbc" (case-insensitive). */
static unsigned char is_rom(const unsigned char *name) {
    unsigned char len = strlen_u(name);
    const unsigned char *ext;
    if (len < 3) return 0;
    /* find the last '.' */
    {
        unsigned char i, dot = 0, has = 0;
        for (i = 0; i < len; i++) if (name[i] == '.') { dot = i; has = 1; }
        if (!has) return 0;
        ext = name + dot;
    }
    if (to_upper(ext[1]) == 'G' && to_upper(ext[2]) == 'B') {
        if (ext[3] == 0) return 1;
        if (to_upper(ext[3]) == 'C' && ext[4] == 0) return 1;
    }
    return 0;
}
