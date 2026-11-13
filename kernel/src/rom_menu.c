/* Hold A on a ROM: options menu (docs/rom-menu.md).
 *
 * Bank 4, injected at 04:5a00. MenuDispatchAB_fileOpen (00:145f) began with
 * an inline far call to DrawLoadingBox; it now calls RomMenuHoldStub
 * (00:0597), which far-calls this with a pointer to the browser frame's
 * record-offset slot (the loop's sp+4) and reads E:
 *
 *   0  go on with the stock open: DrawLoadingBox has been drawn here
 *      (FarCallDrawLoadingBox, 00:0483) and the launch path runs as before
 *   1  back to the browser loop (MenuDispatchAB_waitVBlankLoop, 00:16ab);
 *      a closed menu is cleared and sets the loop's redraw code to 1, so
 *      the page is repainted from the sorted records without re-reading the
 *      directory (and the cursor stays where it was)
 *
 * A tap launches when A comes up; holding A for HOLD_FRAMES opens the menu
 * as soon as the hold is reached. A on "Manage saves" runs ManageSaves
 * (save_mgr.c) and redraws the menu when it returns. A on "Star" (or
 * "Unstar") toggles the ROM's star through StarToggleFar (play.c,
 * docs/stars.md), which sorts the folder again and puts the cursor back on
 * the ROM, and closes the menu. A file that is not .gb/.gbc is offered to
 * the text viewer (TextViewFar, textview.c), which shows a .txt, .ini or .md
 * file and comes back to the page; anything else, and everything in pick
 * mode (FL_PICK), takes the stock path straight away. An A that was already down at
 * the browser's previous poll (held on from the press that opened a folder)
 * is ignored until it is let go: RomMenuPadTrack (00:0453) wraps the loop's
 * ReadJoypad and keeps the previous and current reports in HRAM.
 *
 * While the hold is timed nothing reads the pad but the VBlank sampler
 * (VBlankPadLatch), so hPadLive ($fffc) holds the live state once a frame has
 * passed (ReadJoypadLatched also writes it, with the latch folded in).
 *
 * The box is the BACKUPSAVE prompt's (bkprompt.c) made two rows taller,
 * with the ROM's name on the same band, drawn and scrolled by LastRomName
 * (LR_GEO = 1); the menu polls through LastRomTickStub, which runs the
 * marquee. The name is copied to $c4a4 first: the record sits in the pSRAM
 * window, and the open path clears and refills $c4a4 itself afterwards.
 *
 *   8px   box (0,35)-(159,131); title, name, three options, buttons on
 *         tile rows 5, 7, 9, 11, 13, 15; band y 51..67; rule y 115,
 *         vertical x 83
 *   12px  box (0,36)-(159,135); rows at y 40, 56, 72, 88, 104, 120 from
 *         x 12; band y 53..69; rule y 117, vertical x 79
 *
 *   python3 tools/inject.py src/rom_menu.c $V 4 5a00 RomMenu \
 *       --pin FarCallDrawString12=05c0 --pin LastRomNameStub=0368 \
 *       --pin LastRomTickStub=0370 --pin FarCallDrawLoadingBox=0483 \
 *       --pin ManageSaves=6d11 --pin DrawString=08b7 --pin DrawRect=27ba --pin StoreDrawParams=2791 \
 *       --pin StarQueryFar=5998 --pin StarToggleFar=59a0 --pin TextViewFar=59a8 --apply
 */

#include "types.h"
#include "draw.h"
#include "vars.h"

extern void LastRomNameStub(const u8 *s);                           /* 00:0368 -> LastRomName */
extern u8 LastRomTickStub(void);                                    /* 00:0370: marquee tick, then ReadJoypad */
extern void FarCallDrawLoadingBox(void);                            /* 00:0483 -> 08:737f */
extern void ManageSaves(u8 page);                                   /* 04:6d11, save_mgr.c */
extern u8 StarQueryFar(u8 *slot);                                   /* 04:5998 -> StarQuery (play.c, bank 5) */
extern void StarToggleFar(u8 *slot);                                /* 04:59a0 -> StarToggle */
extern u8 TextViewFar(u8 *slot);                                    /* 04:59a8 -> TextView (textview.c, bank 14): 1 = it was a text file */

#define REC_BASE  (*(volatile u16 *)0xC2A0) /* the open page's records in the $A000 window */
#define NAME_BUF  ((u8 *)0xC4A4)            /* 255 bytes, refilled by the open path */
#define PAD_LIVE  (*(volatile u8 *)0xFFFC)  /* VBlankPadLatch: last frame's pad */
#define PAD_PREV  (*(volatile u8 *)0xFFF5)  /* RomMenuPadTrack: the browser's previous report */
#define PAD_CUR   (*(volatile u8 *)0xFFF6)  /* ...and its latest */

#define PAD_UP    0x04
#define PAD_DOWN  0x08
#define PAD_A     0x10
#define PAD_B     0x20
#define HOLD_FRAMES 30                      /* 0.5 s */
#define REDRAW_OFS 0x0e                     /* the loop's sp+$12, from its sp+4 */

static u8 is_rom(const u8 *s);
static u8 a_held(void);
static void box(void);
static void options(u8 sel, u8 starred);
static void opt(const u8 *s, u8 on, u8 row8, u8 y12);
static void text(const u8 *s, u8 row8, u8 y12);
static void frame(void);

/* The entry point stays the first function in the file. Inline trampoline:
 * two pad parameters. */
u8 RomMenu(u16 far_pad_thunk, u16 far_pad_af, u8 *slot) {
    const u8 *rec;
    u8 i, f, pad, prev, sel, starred;

    (void)far_pad_thunk;
    (void)far_pad_af;
    if (FL_PICK) goto open;
    rec = (const u8 *)(*(u16 *)slot + REC_BASE);
    if (!is_rom(rec)) {
        /* a text file opens in the viewer (textview.c), then the page again */
        if (TextViewFar(slot)) goto closed;
        goto open;
    }
    if (PAD_PREV & PAD_A) {
        while (a_held()) {}
        PAD_CUR = 0;
        return 1;
    }
    f = HFRAME;
    for (;;) {
        if (!a_held()) goto open;
        if ((u8)(HFRAME - f) >= HOLD_FRAMES) break;
    }

    for (i = 0; i < 254 && rec[i]; i++) NAME_BUF[i] = rec[i];
    NAME_BUF[i] = 0;
    starred = StarQueryFar(slot);
    box();
    sel = 0;
    options(sel, starred);
    prev = PAD_A;
    for (;;) {
        f = HFRAME;
        while (HFRAME == f) WaitVBlankFlag();   /* halted, not spinning: docs/browser-nav.md */
        pad = LastRomTickStub();
        f = pad & (u8)~prev;
        prev = pad;
        if (f & (PAD_UP | PAD_DOWN)) {
            sel += (f & PAD_UP) ? 2 : 1;    /* wraps at both ends */
            if (sel > 2) sel -= 3;
            options(sel, starred);
        } else if (f & PAD_B) {
            break;
        } else if (f & PAD_A) {
            if (sel == 0) goto open;
            if (sel == 2) {
                StarToggleFar(slot);
                break;
            }
            /* the record page MenuDispatchAB_bankEntry mapped: entry index
             * (loop sp+$13 word + sp+$15 byte) / 32 + $12 */
            ManageSaves((u8)((u16)(*(u16 *)(slot + 0x0f) + slot[0x11]) >> 5) + 0x12);
            box();
            options(sel, starred);
            prev = 0xFF;
        }
    }
    /* the page repaint only covers rows with entries */
    StoreDrawParams(0, 0, 0);
    DrawRect(0, 32, 159, 135 + (hUiMode << 2), 1);
    StoreDrawParams(3, 0, 0);
closed:
    slot[REDRAW_OFS] = 1;
    PAD_CUR = 0;
    return 1;

open:
    PAD_CUR = 0;
    FarCallDrawLoadingBox();
    return 0;
}

/* Does the name end in .gb or .gbc, any case? (the open path's test) */
static u8 is_rom(const u8 *s) {
    const u8 *dot = 0;
    u8 i;

    for (i = 0; i < 254 && s[i]; i++) if (s[i] == '.') dot = s + i;
    if (!dot || (dot[1] | 0x20) != 'g' || (dot[2] | 0x20) != 'b') return 0;
    return dot[3] == 0 || ((dot[3] | 0x20) == 'c' && dot[4] == 0);
}

/* After the next VBlank: is A down? */
static u8 a_held(void) {
    u8 f = HFRAME;

    while (HFRAME == f) WaitVBlankFlag();   /* halted, not spinning: docs/browser-nav.md */
    return PAD_LIVE & PAD_A;
}

static void box(void) {
    static const u8 title_str[8] = {'O','p','t','i','o','n','s',0};
    static const u8 back_str[8]  = {'[','B',']','b','a','c','k',0};
    static const u8 ok_str[6]    = {'[','A',']','o','k',0};
    u8 buf[6];
    u8 i, t = hUiMode;                  /* 12px: the box runs a few pixels lower */

    StoreDrawParams(0, 0, 0);
    DrawRect(0, 32, 159, 135 + (t << 2), 1);
    PopupDrawParams(3, 0);
    DrawRect(0, 35 + t, 159, 131 + (t << 2), 1);
    text(title_str, 5, 40);
    if (hUiMode) {
        text(back_str, 15, 120);
        for (i = 0; i < 6; i++) buf[i] = ok_str[i];
        FarCallDrawString12(buf, 0, 86, 120);
    } else {
        DrawString(back_str, 7, 1, 15);
        DrawString(ok_str, 5, 11, 15);
    }
    frame();
    PopupDrawParams(3, 3);
    DrawRect(0, 51 + (t << 1), 159, 67 + (t << 1), 1);
    LR_GEO = 1;
    LastRomNameStub(NAME_BUF);
}

/* The three option rows, a '>' on the selected one; the third says Star,
 * or Unstar for a starred ROM. */
static void options(u8 sel, u8 starred) {
    static const u8 start_str[] = "Start";
    static const u8 saves_str[] = "Manage saves";
    static const u8 star_str[] = "Star";
    static const u8 unstar_str[] = "Unstar";

    PopupDrawParams(3, 0);
    opt(start_str, sel == 0, 9, 72);
    opt(saves_str, sel == 1, 11, 88);
    opt(starred ? unstar_str : star_str, sel == 2, 13, 104);
    frame();
}

/* One option row: "> " or two blanks, then the option. */
static void opt(const u8 *s, u8 on, u8 row8, u8 y12) {
    u8 buf[16];
    u8 i;

    buf[0] = on ? '>' : ' ';
    buf[1] = ' ';
    for (i = 0; (buf[2 + i] = s[i]) != 0; i++) {}
    text(buf, row8, y12);
}

/* One text row: tile row row8 from column 1, or the 12px row at y12 from x 12. */
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

/* What a text row repaints: the box outline (a 12px row runs to x 159), the
 * rule above the buttons and the one between them. Leaves ink 3 on paper. */
static void frame(void) {
    u8 t = hUiMode;

    PopupDrawParams(3, 0);
    DrawRect(0, 35 + t, 159, 131 + (t << 2), 0);
    PopupDrawParams(3, 3);
    DrawRect(0, 115 + (t << 1), 159, 115 + (t << 1), 1);
    DrawRect(83 - (t << 2), 115 + (t << 1), 83 - (t << 2), 131 + (t << 2), 1);
    PopupDrawParams(3, 0);
}
