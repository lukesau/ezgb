/* FastLaunch: at boot, look for a "<name>.fastlaunch" marker file in the SD
 * root; if found, search the whole SD tree for "<name>.gb"/"<name>.gbc" and
 * report its full path. Never launches anything itself — see
 * fastlaunch_launch.c (not yet written) for the boot-hook wiring, once the
 * $c2a0/$c4a4 launch handoff contract is confirmed live. This file only
 * finds the path; callers get an empty result_path on any "nothing to do"
 * outcome (no trigger file, no match, any FatFs error) so the caller can
 * always safely fall through to the normal menu.
 *
 * FILINFO layout below was confirmed live against this exact kernel build
 * (2026-07, SD card root containing /SAVER and /Pokemon/PKMRED.GB), not
 * assumed from tools/omega-de-kernel/source/ff15/ff.h — that reference
 * config may not exactly match this kernel's FF_USE_LFN/FF_MAX_LFN build.
 * See decomp/src/shims.md for how FarCallOpendir_B5/FarCallReaddir_B5 work.
 *
 *   offset 0-3   fsize   (unused here)
 *   offset 4-5   fdate   (unused here)
 *   offset 6-7   ftime   (unused here)
 *   offset 8     fattrib (bit 4 / 0x10 = AM_DIR)
 *   offset 9-21  altname (13 bytes, NUL-terminated 8.3 short name)
 *   offset 22..  fname   (long name if present; this kernel's FatFs build
 *                         leaves it empty rather than copying the short
 *                         name in, unlike the reference ff.c source, so
 *                         code here must fall back to altname explicitly)
 *
 * End-of-directory: ff.c's get_fileinfo() invalidates fname unconditionally
 * on every call (even end-of-directory), but only touches altname when
 * there's a real entry to report (end-of-directory returns before reaching
 * that step). So fname[0]==0 is NOT a reliable end marker on its own (a
 * real short-name-only entry also leaves it empty) — this code clears
 * altname[0] before every readdir call and checks THAT for "no more
 * entries", which is unambiguous.
 *
 * IMPORTANT for injection: SDCC/sdld link functions in source-declaration
 * order, so `fastlaunch_scan` — the function inject.py's caller actually
 * wants to pin an address to — is defined FIRST, ahead of the static
 * helpers it calls (with forward declarations below). Getting this order
 * backwards silently pins the address of whichever helper happens to be
 * declared first instead, which still compiles and links with no error or
 * warning — it just calls the wrong function. Learned this the hard way
 * live-debugging an empty scan result that turned out to be `to_upper()`
 * running instead of the real scan.
 */

extern unsigned char FarCallOpendir_B5(unsigned char *dp, const unsigned char *path);
extern unsigned char FarCallReaddir_B5(unsigned char *dp, unsigned char *fno);

#define DIR_SIZE 48
#define FNO_SIZE 100
#define FNO_ATTRIB 8
#define FNO_ALTNAME 9
#define FNO_FNAME 22
#define AM_DIR 0x10

#define MAX_DEPTH 6
#define PATH_MAX 100
#define BASENAME_MAX 40

typedef struct {
    unsigned char dir[DIR_SIZE];
    unsigned char path_len; /* length of `path` up to and including this dir's trailing '/' */
} Level;

static unsigned char to_upper(unsigned char c);
static unsigned char streq_ci(const unsigned char *a, const unsigned char *b);
static unsigned char strlen_u(const unsigned char *s);
static const unsigned char *entry_name(const unsigned char *fno);
static unsigned char match_fastlaunch_ext(const unsigned char *name, unsigned char *out_base);
static unsigned char match_rom_name(const unsigned char *name, const unsigned char *base);

/* Clears result_path[0] on any "nothing found / nothing to do" outcome
 * (no trigger file, no match anywhere, any FatFs error) so the caller can
 * always safely treat an empty result as "boot normally". On success,
 * result_path holds the full path (leading '/', e.g. "/Pokemon/PKMRED.GB"). */
void fastlaunch_scan(unsigned char *result_path) {
    unsigned char fno[FNO_SIZE];
    unsigned char root_dir[DIR_SIZE];
    unsigned char base[BASENAME_MAX];
    unsigned char found_base;
    unsigned char path[PATH_MAX];
    unsigned char plen;
    Level levels[MAX_DEPTH];
    unsigned char depth;
    unsigned char res, i;

    result_path[0] = 0;
    found_base = 0;

    /* --- Step 1: root scan for *.fastlaunch --- */
    if (FarCallOpendir_B5(root_dir, (const unsigned char *)"/") != 0) return;
    for (;;) {
        fno[FNO_ALTNAME] = 0;
        res = FarCallReaddir_B5(root_dir, fno);
        if (res != 0) return;
        if (fno[FNO_ALTNAME] == 0) break; /* end of root listing, no trigger file */
        if (fno[FNO_ATTRIB] & AM_DIR) continue; /* trigger must be a plain file */
        if (match_fastlaunch_ext(entry_name(fno), base)) {
            found_base = 1;
            break;
        }
    }
    if (!found_base) return;

    /* --- Step 2: DFS the whole tree for base + .gb/.gbc --- */
    path[0] = '/';
    path[1] = 0;
    plen = 1;
    if (FarCallOpendir_B5(levels[0].dir, path) != 0) return;
    levels[0].path_len = plen;
    depth = 0;

    while (1) {
        fno[FNO_ALTNAME] = 0;
        res = FarCallReaddir_B5(levels[depth].dir, fno);
        if (res != 0 || fno[FNO_ALTNAME] == 0) {
            /* error, or end of this directory's listing: back out one level */
            if (depth == 0) return; /* whole tree exhausted */
            depth--;
            continue;
        }

        {
            const unsigned char *name = entry_name(fno);
            if (fno[FNO_ATTRIB] & AM_DIR) {
                unsigned char base_len, nlen;
                if (name[0] == '.') continue; /* skip . and .. */
                if (depth + 1 >= MAX_DEPTH) continue; /* too deep, skip subtree */
                base_len = levels[depth].path_len;
                nlen = strlen_u(name);
                if ((unsigned int)base_len + nlen + 2 >= PATH_MAX) continue; /* path too long, skip */
                for (i = 0; i < nlen; i++) path[base_len + i] = name[i];
                path[base_len + nlen] = '/';
                path[base_len + nlen + 1] = 0;
                if (FarCallOpendir_B5(levels[depth + 1].dir, path) == 0) {
                    levels[depth + 1].path_len = base_len + nlen + 1;
                    depth++;
                }
                /* opendir failure: just skip this subdir, stay at current depth */
                continue;
            }
            if (match_rom_name(name, base)) {
                unsigned char base_len = levels[depth].path_len;
                unsigned char nlen = strlen_u(name);
                for (i = 0; i < base_len; i++) result_path[i] = path[i];
                for (i = 0; i < nlen; i++) result_path[base_len + i] = name[i];
                result_path[base_len + nlen] = 0;
                return;
            }
        }
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

/* Selects fname when non-empty (this build seems to never actually take
 * that path, see file header, but a future FatFs config change shouldn't
 * silently break this), else altname. */
static const unsigned char *entry_name(const unsigned char *fno) {
    if (fno[FNO_FNAME] != 0) return fno + FNO_FNAME;
    return fno + FNO_ALTNAME;
}

/* True if name ends in ".fastlaunch" (case-insensitive); if so and out_base
 * is non-NULL, copies the name without that suffix into it. */
static unsigned char match_fastlaunch_ext(const unsigned char *name, unsigned char *out_base) {
    unsigned char len = strlen_u(name);
    unsigned char suflen = 11; /* strlen(".fastlaunch") */
    unsigned char i;
    if (len <= suflen) return 0;
    if (!streq_ci(name + (len - suflen), (const unsigned char *)".fastlaunch")) return 0;
    if (out_base) {
        for (i = 0; i < len - suflen; i++) out_base[i] = name[i];
        out_base[len - suflen] = 0;
    }
    return 1;
}

/* True if name is base + ".gb" or base + ".gbc" (case-insensitive). */
static unsigned char match_rom_name(const unsigned char *name, const unsigned char *base) {
    unsigned char blen = strlen_u(base);
    unsigned char nlen = strlen_u(name);
    unsigned char i;
    if (nlen <= blen) return 0;
    for (i = 0; i < blen; i++) {
        if (to_upper(name[i]) != to_upper(base[i])) return 0;
    }
    return streq_ci(name + blen, (const unsigned char *)".gb")
        || streq_ci(name + blen, (const unsigned char *)".gbc");
}
