/* Instrumented copy of fastlaunch_scan for live debugging only - NOT the
 * final feature (see fastlaunch.c for that).
 *
 * This round's finding: opendir succeeded and readdir found the right
 * number/type of entries (attrib bytes were all correct), but every
 * entry's name read back as the same wrong garbage byte. Attrib (offset 8)
 * being right while name (offset 9+) is wrong, identically, every time, is
 * the signature of Readdir_B5 writing PAST the end of a too-small fno[]
 * buffer and corrupting whatever's adjacent - not a stack-depth issue at
 * all (that theory doesn't explain garbage landing at a FIXED offset with
 * a FIXED wrong value). FNO_SIZE has been 45-100 bytes across every test
 * so far; the real FILINFO's `fname` field could plausibly need up to
 * ~256 bytes (tools/omega-de-kernel's ff15 config default,
 * FF_MAX_LFN=255) even if this kernel's actual build uses less - so this
 * round goes generously large (280 bytes) rather than guess again.
 *
 *   $d700: opendir("/") result
 *   for each entry: attrib byte, first char of name
 *   $FE marker, then found_base (0/1), then extracted base name if found
 */

extern unsigned char FarCallOpendir_B5(unsigned char *dp, const unsigned char *path);
extern unsigned char FarCallReaddir_B5(unsigned char *dp, unsigned char *fno);

#define FNO_ATTRIB 8
#define FNO_ALTNAME 9
#define FNO_FNAME 22
#define AM_DIR 0x10
#define DIR_SIZE 48
#define FNO_SIZE 280
#define BASENAME_MAX 24

static unsigned char to_upper(unsigned char c);
static unsigned char streq_ci(const unsigned char *a, const unsigned char *b);
static unsigned char strlen_u(const unsigned char *s);
static const unsigned char *entry_name(const unsigned char *fno);
static unsigned char match_fastlaunch_ext(const unsigned char *name, unsigned char *out_base);

void fastlaunch_scan_debug(unsigned char *result_path) {
    /* fno lives in fixed WRAM, not on the stack - 280 bytes on the stack
     * re-introduces the "did that break something via depth, or via size"
     * ambiguity from the previous round. root_dir/base stay small and on
     * the stack, matching what the original probe already proved safe. */
    unsigned char *fno = (unsigned char *)0xd780;
    unsigned char root_dir[DIR_SIZE];
    unsigned char base[BASENAME_MAX];
    unsigned char found_base;
    unsigned char res;
    unsigned char *dbg = (unsigned char *)0xd700;
    unsigned char guard;

    result_path[0] = 0;
    found_base = 0;

    res = FarCallOpendir_B5(root_dir, (const unsigned char *)"/");
    *dbg++ = res;
    if (res != 0) return;

    guard = 0;
    for (;;) {
        const unsigned char *name;
        if (++guard == 0) break;
        fno[FNO_ALTNAME] = 0;
        res = FarCallReaddir_B5(root_dir, fno);
        if (res != 0) { *dbg++ = 0xEF; *dbg++ = res; return; }
        if (fno[FNO_ALTNAME] == 0) break;
        name = entry_name(fno);
        *dbg++ = fno[FNO_ATTRIB];
        *dbg++ = name[0];
        if (fno[FNO_ATTRIB] & AM_DIR) continue;
        if (match_fastlaunch_ext(name, base)) {
            found_base = 1;
            break;
        }
    }

    *dbg++ = 0xFE;
    *dbg++ = found_base;
    if (found_base) {
        unsigned char blen = strlen_u(base);
        unsigned char i;
        for (i = 0; i < blen; i++) *dbg++ = base[i];
        for (i = 0; i < blen; i++) result_path[i] = base[i];
        result_path[blen] = 0;
    }
}

static unsigned char to_upper(unsigned char c) {
    if (c >= 'a' && c <= 'z') return c - 0x20;
    return c;
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

static unsigned char strlen_u(const unsigned char *s) {
    unsigned char n = 0;
    while (s[n]) n++;
    return n;
}

static const unsigned char *entry_name(const unsigned char *fno) {
    if (fno[FNO_FNAME] != 0) return fno + FNO_FNAME;
    return fno + FNO_ALTNAME;
}

static unsigned char match_fastlaunch_ext(const unsigned char *name, unsigned char *out_base) {
    unsigned char len = strlen_u(name);
    unsigned char suflen = 11;
    unsigned char i;
    if (len <= suflen) return 0;
    if (!streq_ci(name + (len - suflen), (const unsigned char *)".fastlaunch")) return 0;
    if (out_base) {
        for (i = 0; i < len - suflen; i++) out_base[i] = name[i];
        out_base[len - suflen] = 0;
    }
    return 1;
}
