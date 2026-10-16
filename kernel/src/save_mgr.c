/* Manage saves: the screens (docs/save-manager.md).
 *
 * Bank 4, injected at 04:6d11, near-called from RomMenu (rom_menu.c) when A
 * is pressed on "Manage saves", with the browser's record page. The ROM's
 * file name is at $c4a4 (RomMenu copied it there). The file work (listing
 * /SAVER, copies, delete, the list labels) is SaveOp in bank 1 (save_ops.c),
 * reached through SmSaveOp (04:6562) with an op and a list index.
 *
 *   Saves                  "Working...", then "Done" or "Error"
 *   <ROM name>             LastRomName's band (LR_GEO = 1)
 *   Back up save           "No save yet" without one
 *   26-10-11 12:00         backups, newest first
 *   [B]back | [A]ok
 *
 * A on a backup puts its time in the title and offers Restore / Delete, then
 * asks "Restore this save?" or "Delete this save?" ([B]no | [A]yes).
 *
 *   8px   box (0,35)-(159,139); title row 5, name band row 7 (y 51..67),
 *         list rows 9..14, rule y 123, buttons row 16, vertical x 83
 *   12px  box (0,36)-(159,143); title y 40, band y 53..69, list rows at
 *         y 72, 84, 96, 108, rule y 123, buttons y 128, vertical x 79
 *
 *   python3 tools/inject.py src/save_mgr.c $V 4 6d11 ManageSaves \
 *       --pin FarCallDrawString12=05c0 --pin LastRomNameStub=0368 \
 *       --pin LastRomTickStub=0370 --pin DrawString=08b7 --pin DrawRect=27ba \
 *       --pin StoreDrawParams=2791 --pin SmSaveOp=6562 --pin hUiMode=fffb --apply
 */

#include "types.h"
#include "draw.h"
#include "vars.h"

extern void LastRomNameStub(const u8 *s);                           /* 00:0368 -> LastRomName */
extern u8 LastRomTickStub(void);                                    /* 00:0370: marquee tick, then ReadJoypad */
extern u8 SmSaveOp(u16 opidx);                                      /* 04:6562 -> SaveOp 01:7670 */

#define NAME_BUF  ((const u8 *)0xC4A4)      /* the ROM's file name */
#define LABEL     ((const u8 *)0xD750)      /* SO_LABEL's text */
#define LIVE      ((const u8 *)0xD770)      /* [0] the ROM has a save */
#define COUNT     (*(volatile u8 *)0xD777)  /* backups listed */

#define SO_SCAN    0                        /* save_ops.c */
#define SO_BACKUP  1
#define SO_RESTORE 2
#define SO_DELETE  3
#define SO_LABEL   4
#define SO_DONE    5

#define PAD_UP    0x04
#define PAD_DOWN  0x08
#define PAD_A     0x10
#define PAD_B     0x20

static u8 key(u8 *prev);
static u8 wait_ab(void);
static u8 choose(u8 idx);
static void draw_box(void);
static void draw_list(u8 mode, u8 sel, u8 top);
static void title(const u8 *s);
static void buttons(u8 confirm);
static void text(const u8 *s, u8 row8, u8 y12);
static void frame(void);

/* The entry point stays the first function in the file. Near-called. */
void ManageSaves(u8 page) {
    static const u8 saves_str[6]  = {'S','a','v','e','s',0};
    static const u8 rest_str[19]  = {'R','e','s','t','o','r','e',' ','t','h','i','s',' ','s','a','v','e','?',0};
    static const u8 del_str[18]   = {'D','e','l','e','t','e',' ','t','h','i','s',' ','s','a','v','e','?',0};
    static const u8 work_str[11]  = {'W','o','r','k','i','n','g','.','.','.',0};
    static const u8 done_str[5]   = {'D','o','n','e',0};
    static const u8 err_str[6]    = {'E','r','r','o','r',0};
    u8 f, prev, sel, top, rows, ok, act;

    SmSaveOp(SO_SCAN << 8);
    draw_box();
    title(saves_str);
    buttons(0);
    sel = 0;
    top = 0;
    rows = hUiMode ? 4 : 6;
    draw_list(0, sel, top);
    prev = 0xFF;
    for (;;) {
        f = key(&prev);
        if (f & PAD_B) break;
        if (f & (PAD_UP | PAD_DOWN)) {
            if ((f & PAD_UP) && sel) sel--;
            if ((f & PAD_DOWN) && sel < COUNT) sel++;
            if (sel < top) top = sel;
            if (sel >= top + rows) top = sel - rows + 1;
            draw_list(0, sel, top);
            continue;
        }
        if (!(f & PAD_A)) continue;
        if (sel == 0) {
            if (!LIVE[0]) continue;
            act = SO_BACKUP;
        } else {
            act = choose(sel - 1);
            if (act) {
                title(act == SO_RESTORE ? rest_str : del_str);
                buttons(1);
                if (!wait_ab()) act = 0;
                buttons(0);
            }
            if (!act) {
                title(saves_str);
                draw_list(0, sel, top);
                prev = 0xFF;
                continue;
            }
        }
        title(work_str);
        ok = SmSaveOp((act << 8) | (u8)(sel - 1));
        SmSaveOp(SO_SCAN << 8);
        title(ok ? done_str : err_str);
        sel = 0;
        top = 0;
        draw_list(0, sel, top);
        prev = 0xFF;
    }

    StoreDrawParams(0, 0, 0);
    DrawRect(0, 32, 159, 143, 1);
    StoreDrawParams(3, 0, 0);
    SmSaveOp((SO_DONE << 8) | page);
}

/* After the next VBlank: the buttons newly down since *prev (the poll runs
 * the name's marquee). */
static u8 key(u8 *prev) {
    u8 f = HFRAME, pad;

    while (HFRAME == f) {}
    pad = LastRomTickStub();
    f = pad & (u8)~*prev;
    *prev = pad;
    return f;
}

/* The yes/no question: 1 on A, 0 on B. */
static u8 wait_ab(void) {
    u8 f, prev = 0xFF;

    for (;;) {
        f = key(&prev);
        if (f & PAD_A) return 1;
        if (f & PAD_B) return 0;
    }
}

/* What to do with backup idx, its time in the title: SO_RESTORE, SO_DELETE,
 * or 0 on B. */
static u8 choose(u8 idx) {
    u8 f, prev = 0xFF, sel = 0;

    SmSaveOp((SO_LABEL << 8) | idx);
    title(LABEL);
    draw_list(1, sel, 0);
    for (;;) {
        f = key(&prev);
        if (f & PAD_B) return 0;
        if (f & PAD_A) return sel ? SO_DELETE : SO_RESTORE;
        if (f & (PAD_UP | PAD_DOWN)) {
            sel ^= 1;
            draw_list(1, sel, 0);
        }
    }
}

/* ---- drawing ---- */

static void draw_box(void) {
    StoreDrawParams(0, 0, 0);
    DrawRect(0, 32, 159, 143, 1);
    StoreDrawParams(3, 0, 0);
    if (hUiMode) DrawRect(0, 36, 159, 143, 1); else DrawRect(0, 35, 159, 139, 1);
    frame();
    StoreDrawParams(3, 3, 0);
    if (hUiMode) DrawRect(0, 53, 159, 69, 1); else DrawRect(0, 51, 159, 67, 1);
    LR_GEO = 1;
    LastRomNameStub(NAME_BUF);
}

/* The list rows from top, sel on an ink band. Mode 0: row 0 backs the save
 * up, rows 1.. are the backups ("YY-MM-DD HH:MM (n)", from SO_LABEL);
 * mode 1: what to do with a backup. */
static void draw_list(u8 mode, u8 sel, u8 top) {
    static const u8 bk_str[13]   = {'B','a','c','k',' ','u','p',' ','s','a','v','e',0};
    static const u8 none_str[12] = {'N','o',' ','s','a','v','e',' ','y','e','t',0};
    static const u8 rest_str[8]  = {'R','e','s','t','o','r','e',0};
    static const u8 del_str[7]   = {'D','e','l','e','t','e',0};
    static const u8 blank_str[1] = {0};
    u8 r, i, y, h, rows;
    const u8 *e;

    rows = hUiMode ? 4 : 6;
    h = hUiMode ? 12 : 8;
    for (r = 0; r < rows; r++) {
        i = top + r;
        e = blank_str;
        if (mode) {
            if (i < 2) e = i ? del_str : rest_str;
        } else if (i == 0) {
            e = LIVE[0] ? bk_str : none_str;
        } else if (i <= COUNT) {
            SmSaveOp((SO_LABEL << 8) | (u8)(i - 1));
            e = LABEL;
        }
        y = hUiMode ? 72 + r * 12 : 72 + r * 8;
        if (i == sel) StoreDrawParams(3, 3, 0); else StoreDrawParams(0, 0, 0);
        DrawRect(1, y, 158, y + h - 1, 1);
        if (i == sel) StoreDrawParams(0, 3, 0); else StoreDrawParams(3, 0, 0);
        text(e, 9 + r, y);
    }
    frame();
}

static void title(const u8 *s) {
    StoreDrawParams(3, 0, 0);
    text(s, 5, 40);
    frame();
}

/* [B]back [A]ok, or [B]no [A]yes for the restore question. */
static void buttons(u8 confirm) {
    static const u8 back_str[8] = {'[','B',']','b','a','c','k',0};
    static const u8 ok_str[6]   = {'[','A',']','o','k',0};
    static const u8 no_str[6]   = {'[','B',']','n','o',0};
    static const u8 yes_str[7]  = {'[','A',']','y','e','s',0};
    u8 buf[8];
    const u8 *a = confirm ? yes_str : ok_str;
    u8 i;

    StoreDrawParams(0, 0, 0);
    if (hUiMode) DrawRect(1, 124, 158, 142, 1); else DrawRect(1, 124, 158, 138, 1);
    StoreDrawParams(3, 0, 0);
    text(confirm ? no_str : back_str, 16, 128);
    if (hUiMode) {
        for (i = 0; i < 8 && a[i]; i++) buf[i] = a[i];
        buf[i] = 0;
        FarCallDrawString12(buf, 0, 86, 128);
    } else {
        DrawString(a, confirm ? 6 : 5, 11, 16);
    }
    frame();
}

/* One text row: tile row row8 from column 1, or the 12px row at y12 from
 * x 12, in the colors already stored. */
static void text(const u8 *s, u8 row8, u8 y12) {
    u8 buf[24];
    u8 i;

    if (!hUiMode) {
        DrawString(s, 18, 1, row8);       /* padded with blanks to the box's inner width */
        return;
    }
    for (i = 0; i < 23 && s[i]; i++) buf[i] = s[i];
    buf[i] = 0;
    FarCallDrawString12(buf, 0, 1, y12);
}

/* The outline (a 12px row runs to x 159), the rule above the buttons and
 * the one between them. Leaves ink 3 on paper. */
static void frame(void) {
    StoreDrawParams(3, 0, 0);
    if (hUiMode) DrawRect(0, 36, 159, 143, 0); else DrawRect(0, 35, 159, 139, 0);
    StoreDrawParams(3, 3, 0);
    DrawRect(0, 123, 159, 123, 1);
    if (hUiMode) DrawRect(79, 123, 79, 143, 1); else DrawRect(83, 123, 83, 139, 1);
    StoreDrawParams(3, 0, 0);
}
