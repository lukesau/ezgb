/* Name filter for the file browser: returns 1 if the entry should be hidden.
 *
 * Hidden:
 *  - anything whose name starts with '.' (dotfiles, .DS_Store, AppleDouble
 *    "._*" sidecars, .fseventsd/, .Spotlight-V100/ — the old
 *    DirListSkipDotLongName behaviour, docs/browser-hide-filter.md)
 *  - *.gba — GBA ROMs on a shared card; the Jr can't launch them
 *  - *.fastlaunch — fast-launch marker files (docs/fast-launch-notes.md)
 *  - FLAUNCH.CFG — the fast-launch config file
 *
 * All extension/name tests are case-insensitive; FAT 8.3 short names come
 * back uppercase while long names keep the host's casing.
 *
 * Called per directory entry from DirListHideNameStub (00:04ae), which
 * replaces the old LFN-only dot stub. Unlike that stub this sees BOTH name
 * paths: the resolved long name and the 8.3 short name used when no LFN
 * exists. That matters here — "FLAUNCH.CFG" and upper-case "*.GBA" are valid
 * 8.3 names, so those entries never had a long name to test.
 *
 * The check runs before DirList's directory/file split, so a directory named
 * e.g. "Foo.gba" is hidden too — same deliberate behaviour as the dot filter.
 *
 * String literals live in this bank's _CODE and are only read from here, so
 * no WRAM bounce is needed (contrast fastlaunch.c's cfg_name, which crosses
 * banks).
 */

typedef unsigned char u8;

/* Entry point is defined first so it lands exactly at the injection address
 * (same layout rule as browser_sort.c). */
static u8 lower(u8 c);
static u8 ends_ci(const u8 *name, u8 len, const u8 *suf, u8 suf_len);

/* Reached only via FarCallTrampoline, which pushes three words (restore
 * thunk $07ae, saved bank AF, real return) between the caller's pushed args
 * and the jump — so a far callee finds its first real arg at sp+6, not sp+2
 * (the kernel's own far targets read theirs there too, e.g. Opendir_B5).
 * The two pad params soak up those trampoline words; never read them. */
u8 browser_hide_name(unsigned int far_pad_af, unsigned int far_pad_ret,
                     const u8 *name) {
    u8 len;

    if (name[0] == '.') {
        return 1;
    }
    for (len = 0; name[len] && len < 253; len++) {
    }
    if (ends_ci(name, len, (const u8 *)".gba", 4)) {
        return 1;
    }
    if (ends_ci(name, len, (const u8 *)".fastlaunch", 11)) {
        return 1;
    }
    if (len == 11 && ends_ci(name, len, (const u8 *)"flaunch.cfg", 11)) {
        return 1;
    }
    return 0;
}

static u8 lower(u8 c) {
    return (c >= 'A' && c <= 'Z') ? (u8)(c + 32) : c;
}

/* Does name (of length len) caselessly end with suf (given lowercase)? */
static u8 ends_ci(const u8 *name, u8 len, const u8 *suf, u8 suf_len) {
    u8 i;

    if (len < suf_len) {
        return 0;
    }
    name += len - suf_len;
    for (i = 0; i < suf_len; i++) {
        if (lower(name[i]) != suf[i]) {
            return 0;
        }
    }
    return 1;
}
