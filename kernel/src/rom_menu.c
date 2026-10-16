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
 * (save_mgr.c) and redraws the menu when it returns. Pick mode (FL_PICK)
 * and files that are not .gb/.gbc take the stock path straight away. An A that was already down at
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
 *   8px   box (0,35)-(159,115); title, name, two options, buttons on tile
 *         rows 5, 7, 9, 11, 13; band y 51..67; rule y 99, vertical x 83
 *   12px  box (0,36)-(159,119); rows at y 40, 56, 72, 88, 104 from x 12;
 *         band y 53..69; rule y 101, vertical x 79
 *
 *   python3 tools/inject.py src/rom_menu.c $V 4 5a00 RomMenu \
 *       --pin FarCallDrawString12=05c0 --pin LastRomNameStub=0368 \
 *       --pin LastRomTickStub=0370 --pin FarCallDrawLoadingBox=0483 \
 *       --pin ManageSaves=6d11 --pin DrawString=08b7 --pin DrawRect=27ba --pin StoreDrawParams=2791 \
 *       --pin hUiMode=fffb --apply
 */

#include "types.h"
#include "draw.h"

extern void LastRomNameStub(const u8 *s);                           /* 00:0368 -> LastRomName */
extern u8 LastRomTickStub(void);                                    /* 00:0370: marquee tick, then ReadJoypad */
extern void FarCallDrawLoadingBox(void);                            /* 00:0483 -> 08:737f */
extern void ManageSaves(u8 page);                                   /* 04:6d11, save_mgr.c */
extern volatile u8 hUiMode;                                         /* $fffb: 0 = 8px, 1 = 12px */

#define FL_PICK   (*(volatile u8 *)0xDBFE)  /* SET tab pick mode: A captures the ROM */
#define LR_GEO    (*(volatile u8 *)0xDB3F)  /* LastRomName: 1 = the BACKUPSAVE band */
#define REC_BASE  (*(volatile u16 *)0xC2A0) /* the open page's records in the $A000 window */
#define NAME_BUF  ((u8 *)0xC4A4)            /* 255 bytes, refilled by the open path */
#define HFRAME    (*(volatile u8 *)0xFFFA)  /* +1 per VBlank */
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
static void options(u8 sel);
static void text(const u8 *s, u8 row8, u8 y12);
static void frame(void);

/* The entry point stays the first function in the file. Inline trampoline:
 * two pad parameters. */
u8 RomMenu(u16 far_pad_thunk, u16 far_pad_af, u8 *slot) {
    const u8 *rec;
    u8 i, f, pad, prev, sel;

    (void)far_pad_thunk;
    (void)far_pad_af;
    if (FL_PICK) goto open;
    rec = (const u8 *)(*(u16 *)slot + REC_BASE);
    if (!is_rom(rec)) goto open;
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
    box();
    sel = 0;
    options(sel);
    prev = PAD_A;
    for (;;) {
        f = HFRAME;
        while (HFRAME == f) {}
        pad = LastRomTickStub();
        f = pad & (u8)~prev;
        prev = pad;
        if (f & (PAD_UP | PAD_DOWN)) {
            sel ^= 1;
            options(sel);
        } else if (f & PAD_B) {
            break;
        } else if (f & PAD_A) {
            if (sel == 0) goto open;
            /* the record page MenuDispatchAB_bankEntry mapped: entry index
             * (loop sp+$13 word + sp+$15 byte) / 32 + $12 */
            ManageSaves((u8)((u16)(*(u16 *)(slot + 0x0f) + slot[0x11]) >> 5) + 0x12);
            box();
            options(sel);
            prev = 0xFF;
        }
    }
    /* the page repaint only covers rows with entries */
    StoreDrawParams(0, 0, 0);
    if (hUiMode) DrawRect(0, 32, 159, 123, 1); else DrawRect(0, 32, 159, 119, 1);
    StoreDrawParams(3, 0, 0);
    slot[REDRAW_OFS] = 1;
    PAD_CUR = 0;
    return 1;

open:
    PAD_CUR = 0;
    FarCallDrawLoadingBox();
    return 0;
}

/* Does the name end in .gb or .gbc, any case? (the open path's own test) */
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

    while (HFRAME == f) {}
    return PAD_LIVE & PAD_A;
}

static void box(void) {
    static const u8 title_str[8] = {'O','p','t','i','o','n','s',0};
    static const u8 back_str[8]  = {'[','B',']','b','a','c','k',0};
    static const u8 ok_str[6]    = {'[','A',']','o','k',0};
    u8 buf[6];
    u8 i;

    StoreDrawParams(0, 0, 0);
    if (hUiMode) DrawRect(0, 32, 159, 123, 1); else DrawRect(0, 32, 159, 119, 1);
    StoreDrawParams(3, 0, 0);
    if (hUiMode) DrawRect(0, 36, 159, 119, 1); else DrawRect(0, 35, 159, 115, 1);
    text(title_str, 5, 40);
    if (hUiMode) {
        text(back_str, 13, 104);
        for (i = 0; i < 6; i++) buf[i] = ok_str[i];
        FarCallDrawString12(buf, 0, 86, 104);
    } else {
        DrawString(back_str, 7, 1, 13);
        DrawString(ok_str, 5, 11, 13);
    }
    frame();
    StoreDrawParams(3, 3, 0);
    if (hUiMode) DrawRect(0, 53, 159, 69, 1); else DrawRect(0, 51, 159, 67, 1);
    LR_GEO = 1;
    LastRomNameStub(NAME_BUF);
}

/* The two option rows, a '>' on the selected one. */
static void options(u8 sel) {
    static const u8 start_str[8]  = {' ',' ','S','t','a','r','t',0};
    static const u8 saves_str[15] = {' ',' ','M','a','n','a','g','e',' ','s','a','v','e','s',0};
    u8 buf[15];
    u8 i;

    StoreDrawParams(3, 0, 0);
    for (i = 0; i < 8; i++) buf[i] = start_str[i];
    if (sel == 0) buf[0] = '>';
    text(buf, 9, 72);
    for (i = 0; i < 15; i++) buf[i] = saves_str[i];
    if (sel == 1) buf[0] = '>';
    text(buf, 11, 88);
    frame();
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
    StoreDrawParams(3, 0, 0);
    if (hUiMode) DrawRect(0, 36, 159, 119, 0); else DrawRect(0, 35, 159, 115, 0);
    StoreDrawParams(3, 3, 0);
    if (hUiMode) {
        DrawRect(0, 101, 159, 101, 1);
        DrawRect(79, 101, 79, 119, 1);
    } else {
        DrawRect(0, 99, 159, 99, 1);
        DrawRect(83, 99, 83, 115, 1);
    }
    StoreDrawParams(3, 0, 0);
}
