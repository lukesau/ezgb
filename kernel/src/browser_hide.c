/* Name filter for the file browser: returns 1 if the entry should be hidden.
 *
 * Hidden:
 *  - anything whose name starts with '.' (dotfiles, .DS_Store, AppleDouble
 *    "._*" sidecars, .fseventsd/, .Spotlight-V100/), matching the old
 *    DirListSkipDotLongName behavior (docs/browser-hide-filter.md)
 *  - *.gba (GBA ROMs on a shared card; the Jr can't launch them)
 *  - EZGB.CFG, the settings file (docs/ezgb-cfg.md), and FLAUNCH.CFG, its
 *    pre-2.9 predecessor (a leftover would otherwise clutter the root)
 *
 * All extension/name tests are case-insensitive; FAT 8.3 short names come
 * back uppercase while long names keep the host's casing.
 *
 * Called per directory entry from DirListHideNameStub (00:04ae), which
 * replaces the old LFN-only dot stub. Unlike that stub this sees BOTH name
 * paths: the resolved long name and the 8.3 short name used when no LFN
 * exists. That matters here: "EZGB.CFG" and upper-case "*.GBA" are valid
 * 8.3 names, so those entries never had a long name to test.
 *
 * The check runs before DirList's directory/file split, so a directory named
 * e.g. "Foo.gba" is hidden too, the same deliberate behavior as the dot
 * filter.
 *
 * String literals live in this bank's _CODE and are only read from here, so
 * no WRAM bounce is needed (contrast fastlaunch.c's cfg_name, which crosses
 * banks). The 12px notice text is the exception: that renderer runs in bank
 * 2, so it gets a stack copy.
 *
 * It is also where a directory is cut short (docs/browser-sort.md "Record
 * cap"). DirList stores entry i at pSRAM page $12 + (i >> 5), unmasked, and
 * the cart keeps only 5 bits of the page, so past page $1E records would
 * land on the sort keys ($1F) and then wrap onto game saves ($00) and the
 * kernel meta ($11). This hook sees every entry DirList is about to store,
 * whoever called DirList, so once MAX_RECORDS are listed the next shown
 * entry ends the directory instead: the DIR's current sector is zeroed,
 * which is how FatFs itself marks the end, so the next f_readdir comes back
 * empty and DirList sets its end-of-directory latch as on a real end.
 * LIST_CUT tells browser_sort.c to leave the partial listing unsorted, and
 * a notice box stays up for about two seconds before the list is drawn.
 *
 * Bank 5, injected at 05:7700 (free space after FatFs; it was 08:7c00 until
 * the cap outgrew that slot):
 *
 *   python3 tools/inject.py src/browser_hide.c $V 5 7700 BrowserHideName \
 *       --pin DrawString=08b7 --pin FarCallDrawString12=05c0 --pin DrawRect=27ba \
 *       --pin StoreDrawParams=2791 --pin Delay=3a93 --pin hUiMode=fffb --apply
 */

typedef unsigned char u8;

extern void DrawString(const u8 *s, u8 len, u8 x, u8 y);           /* 00:08b7 */
extern void FarCallDrawString12(const u8 *s, u8 len, u8 col, u8 row);   /* 00:05c0 -> 02:7500 */
extern void DrawRect(u8 x0, u8 y0, u8 x1, u8 y1, u8 fill);          /* 00:27ba */
extern void StoreDrawParams(u8 color, u8 colorB, u8 op);            /* 00:2791 */
extern void Delay(unsigned int ms);                                 /* 00:3a93, about 1 ms per count */
extern volatile u8 hUiMode;                                         /* $fffb: 0 = 8px, 1 = 12px */

#define ENTRY_COUNT (*(volatile unsigned int *)0xc2a2)
#define DIR_SECT (*(volatile unsigned long *)0xca03)   /* DirList's DIR is $c9f5, sect at +$0e */
#define LIST_CUT (*(volatile u8 *)0xdbfa)              /* browser_sort.c clears it */
#define MAX_RECORDS 416                                /* pages $12-$1E, 32 each */

/* Entry point is defined first so it lands exactly at the injection address
 * (same layout rule as browser_sort.c). */
static u8 lower(u8 c);
static u8 ends_ci(const u8 *name, u8 len, const u8 *suf, u8 suf_len);
static void cut_notice(void);
static void notice_line(const u8 *s, u8 row8, u8 y12);

/* Reached only via FarCallTrampoline, which pushes three words (restore
 * thunk $07ae, saved bank AF, real return) between the caller's pushed args
 * and the jump, so a far callee finds its first real arg at sp+6, not sp+2
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
    if (len == 8 && ends_ci(name, len, (const u8 *)"ezgb.cfg", 8)) {
        return 1;
    }
    if (len == 11 && ends_ci(name, len, (const u8 *)"flaunch.cfg", 11)) {
        return 1;
    }
    if (ENTRY_COUNT >= MAX_RECORDS) {
        DIR_SECT = 0;
        LIST_CUT = 1;
        cut_notice();
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

/* Erases the Reading... box (35,37)-(125,108), then a closed box in the look
 * of the boot prompts (docs/modal-prompts.md): ink 3 outline on paper 0,
 * two lines.
 *   8px   box (0,51)-(159,84), text on tile rows 7 and 9 from column 1
 *   12px  box (0,52)-(159,87), text at y 56 and 72 from x 12
 * The browser repaints the whole list area afterwards. */
static void cut_notice(void) {
    StoreDrawParams(0, 0, 0);
    DrawRect(35, 37, 125, 108, 1);
    StoreDrawParams(3, 0, 0);
    if (hUiMode) DrawRect(0, 52, 159, 87, 1); else DrawRect(0, 51, 159, 84, 1);
    notice_line((const u8 *)"Too many files.", 7, 56);
    notice_line((const u8 *)"Showing first 416", 9, 72);
    if (hUiMode) DrawRect(0, 52, 159, 87, 0);   /* 12px rows paint over the right edge */
    Delay(2000);
}

static void notice_line(const u8 *s, u8 row8, u8 y12) {
    u8 buf[20];
    u8 i;

    if (!hUiMode) {
        DrawString(s, 18, 1, row8);
        return;
    }
    for (i = 0; i < 19 && s[i]; i++) buf[i] = s[i];
    buf[i] = 0;
    FarCallDrawString12(buf, 0, 1, y12);
}
