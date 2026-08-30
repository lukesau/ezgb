/* FastLaunch scan (root-only): decide at boot whether to skip the browser and
 * launch a ROM straight away, and report its full path in result_path
 * (leading '/', e.g. "/PKMRED.GB"). Two triggers, both looking only at the SD
 * root:
 *
 *   1. Marker file: a "<name>.fastlaunch" in root launches "<name>.gb" or
 *      "<name>.gbc" from root.
 *   2. Lone ROM: if the root holds exactly one real file (ignoring the kernel
 *      ezgb.dat, dot-files, and macOS junk) and it is a .gb/.gbc, launch it.
 *
 * The marker takes priority. On any "nothing to do" outcome (no trigger, no
 * matching ROM, any FatFs error) result_path[0] is left 0 so the caller falls
 * through to the normal menu.
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

/* Fixed WRAM scratch. */
#define FNO   ((unsigned char *)0xD780)  /* FILINFO, 26 used */
#define LFN   ((unsigned char *)0xD7A0)  /* long-name buffer, 256 */
#define BASE  ((unsigned char *)0xD8A0)  /* marker stem / target base, 48 */
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
static unsigned char match_fastlaunch_ext(const unsigned char *name);
static unsigned char match_rom_name(const unsigned char *name);
static void write_result(unsigned char *result_path, const unsigned char *name);

/* Takes no argument: it is reached by a far-call (FarCallTrampoline), which
 * shifts stack args by 6 bytes, so passing a pointer across it is fragile.
 * Instead it writes straight to the kernel's launch basename buffer $c4a4 —
 * which is exactly where the launch step reads the path from. */
#define RESULT ((unsigned char *)0xC4A4)

void fastlaunch_scan(void) {
    unsigned char *result_path = RESULT;
    unsigned char root[2];
    unsigned char have_marker;
    unsigned char realcount;
    unsigned char last_is_rom;
    const unsigned char *name;
    unsigned char i, n;

    result_path[0] = 0;

    /* FILINFO.lfname = LFN buffer, FILINFO.lfsize = 254 (set once; reused). */
    FNO[FNO_LFNPTR]     = (unsigned char)((unsigned int)LFN & 0xFF);
    FNO[FNO_LFNPTR + 1] = (unsigned char)((unsigned int)LFN >> 8);
    FNO[FNO_LFNSIZE]     = (unsigned char)LFN_SIZE;
    FNO[FNO_LFNSIZE + 1] = 0;

    root[0] = '/';
    root[1] = 0;

    /* --- Pass 1: classify the root --- */
    have_marker = 0;
    realcount = 0;
    last_is_rom = 0;

    if (FarCallOpendir_B5(DIRO, root) != 0) return;
    for (;;) {
        readdir_prep();
        if (FarCallReaddir_B5(DIRO, FNO) != 0) return;
        if (is_end()) break;
        if (FNO[FNO_ATTRIB] & AM_DIR) continue;
        name = entry_name();
        if (name[0] == '.') continue;                 /* dot-files / macOS junk */
        if (streq_ci(name, (const unsigned char *)"ezgb.dat")) continue;

        if (match_fastlaunch_ext(name)) {             /* fills BASE with the stem */
            have_marker = 1;
            continue;                                 /* marker is not a "real file" */
        }

        /* A real file: count it and remember it (for the lone-ROM rule). */
        realcount++;
        n = strlen_u(name);
        if (n >= NAME_MAX) n = NAME_MAX - 1;
        for (i = 0; i < n; i++) NAME[i] = name[i];
        NAME[n] = 0;
        last_is_rom = is_rom(NAME);
    }

    /* --- Decide --- */
    if (have_marker) {
        /* Pass 2: find BASE + .gb/.gbc in root. */
        if (FarCallOpendir_B5(DIRO, root) != 0) return;
        for (;;) {
            readdir_prep();
            if (FarCallReaddir_B5(DIRO, FNO) != 0) return;
            if (is_end()) return;
            if (FNO[FNO_ATTRIB] & AM_DIR) continue;
            name = entry_name();
            if (match_rom_name(name)) {
                write_result(result_path, name);
                return;
            }
        }
    }

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

/* If name ends in ".fastlaunch" (case-insensitive), copy the stem into BASE
 * and return 1. */
static unsigned char match_fastlaunch_ext(const unsigned char *name) {
    static const unsigned char suf[12] = {'.','f','a','s','t','l','a','u','n','c','h',0};
    unsigned char len = strlen_u(name);
    unsigned char suflen = 11;
    unsigned char i, stem;
    if (len <= suflen) return 0;
    stem = len - suflen;
    for (i = 0; i < suflen; i++) {
        if (to_upper(name[stem + i]) != to_upper(suf[i])) return 0;
    }
    if (stem >= NAME_MAX) return 0;
    for (i = 0; i < stem; i++) BASE[i] = name[i];
    BASE[stem] = 0;
    return 1;
}

/* True if name is BASE + ".gb" or BASE + ".gbc" (case-insensitive). */
static unsigned char match_rom_name(const unsigned char *name) {
    unsigned char blen = strlen_u(BASE);
    unsigned char nlen = strlen_u(name);
    unsigned char i;
    const unsigned char *ext;
    if (nlen <= blen) return 0;
    for (i = 0; i < blen; i++) {
        if (to_upper(name[i]) != to_upper(BASE[i])) return 0;
    }
    ext = name + blen;
    if (ext[0] == '.' && to_upper(ext[1]) == 'G' && to_upper(ext[2]) == 'B') {
        if (ext[3] == 0) return 1;
        if (to_upper(ext[3]) == 'C' && ext[4] == 0) return 1;
    }
    return 0;
}
