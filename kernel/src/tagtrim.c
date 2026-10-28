/* Clean ROM names in the browser (docs/browser-tags.md).
 *
 * ROM sets name their files "Title (Region) (Rev 1) [!].gb"; with TAGS=0
 * in EZGB.CFG (the SET tab's TAGS checkbox off) the browser shows "Title":
 * a file's name is cut at the first " (" or " [", else at its last '.',
 * the extension. Folders are left alone, and so is everything else that
 * shows a name (the hold-A menu, the START overlay, the save manager): the
 * cut is display-only, the record keeps the full name.
 *
 * Bank 5, injected at 05:7a00 (after the hide filter). Two entries:
 *
 *   TagCat   far target of the marquee's gap strcat in DrawDirEntryLabel
 *            (00:0d69, was 01:4000 CStrCat_B1): the marquee buffer holds
 *            name[offset..]; it is cut first, then the gap is appended as
 *            before. Inline far call, so the arguments sit at sp+6: two pads.
 *   TagLen   what the marquee's `call CStrLen` on the name (00:0c55) now
 *            calls, through the 8-byte stub FarCallTagLen (00:0408): the
 *            name's length as drawn. Called stub: three pads. DrawNameWithIcon
 *            (browser_icons.c, bank 2) calls the same stub for the row draw.
 *
 * TagLen leaves TAG_CUT = 1 when it cut this name, so that TagCat, which
 * only sees the buffer, cuts the same entry (the marquee's offset stays
 * below the cut, so the cut point is always still in the buffer).
 *
 *   python3 tools/inject.py src/tagtrim.c $V 5 7a00 TagCat --replace --apply
 */

#include "types.h"
#include "vars.h"

#define ATTR_OFS 254       /* a browser record: 254 name bytes, then the attribute */
#define ATTR_DIR 0x10

static u8 cut_at(const u8 *s);

void TagCat(u16 far_pad_thunk, u16 far_pad_af, u8 *buf, const u8 *gap) {
    u8 i, n;

    (void)far_pad_thunk;
    (void)far_pad_af;
    if (TAG_CUT) {
        n = cut_at(buf);
        if (n != 0xFF) buf[n] = 0;
    }
    for (i = 0; buf[i]; i++) {}
    while ((buf[i++] = *gap++) != 0) {}
}

u16 TagLen(u16 far_pad_thunk, u16 far_pad_af, u16 far_pad_ret, const u8 *s) {
    u8 n;

    (void)far_pad_thunk;
    (void)far_pad_af;
    (void)far_pad_ret;
    TAG_CUT = 0;
    if (TAGS_HIDE && s[ATTR_OFS] != ATTR_DIR) {
        n = cut_at(s);
        if (n != 0xFF) {
            TAG_CUT = 1;
            return n;
        }
    }
    for (n = 0; n < ATTR_OFS && s[n]; n++) {}
    return n;
}

/* Where the name stops: the first " (" or " [", else the last '.', with
 * blanks before it dropped. 0xFF when there is nothing to cut. Never 0, so
 * a name can't vanish: a leading tag or dot is left alone. */
static u8 cut_at(const u8 *s) {
    u8 i, cut = 0xFF;

    for (i = 0; i < ATTR_OFS && s[i]; i++) {
        if (i >= 2 && s[i - 1] == ' ' && (s[i] == '(' || s[i] == '[')) {
            cut = i - 1;
            break;
        }
        if (i >= 1 && s[i] == '.') cut = i;
    }
    while (cut != 0xFF && cut > 1 && s[cut - 1] == ' ') cut--;
    return cut;
}
