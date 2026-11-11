/* SET tab page 3, the theme page (docs/fastlaunch-set-tab.md "Pages",
 * docs/dark-mode.md "Color picker").
 *
 * Bank 13, injected at 0D:4000: bank 4 had no room for a third page. flcfg.c
 * (04:6d19) reaches it through FarCallThemePage (04:5990), so the args sit
 * past the trampoline's three words and the stub's return address.
 *
 *   row 2   THEME: [ PURPLE]       cursor row 14
 *   row 4   FONT:     [12px]       cursor row 15 (docs/ui-mode.md)
 *   row 6   COLORS:   R   G   B
 *   row 8   BG:      [ 6][ 2][12]  cursor row 16, color index 0
 *   row 10  TEXT:    [31][31][31]  cursor row 17, color index 3
 *   row 12  ACCENT:  [29][26] [7]  cursor row 18, the accent's index
 *   row 16  [< PREV] 3/3 [NEXT >]  cursor rows 19 and 20 (setpage.c draws it)
 *
 *   op 0  the labels
 *   op 1  the rows, arg = the cursor row
 *   op 3  A on a row (arg): THEME steps (B back, THEME_BACK), FONT steps,
 *         a color row starts setting it. Returns 2 when the tab strip and
 *         the pane have to be laid out again (the glyph set or the accent's
 *         color index changed), which flcfg does, else 0
 *   op 5  once per pass of the SET input loop, arg = the pad flcfg read:
 *         returns the pad for the stock loop
 *
 * The color rows show the colors on screen, read back from palette RAM, five
 * bits a channel as the console has them. A on a row sets it, as A on TIME's
 * SET does the clock: LEFT and RIGHT pick the channel, UP and DOWN change
 * it, A or B ends. While that runs (CP_EDIT) op 5 hands the stock loop no
 * keys. The first change in a built-in theme copies its background and ink
 * to the custom one (CUST_RGB) and switches THEME to it, so the picker
 * starts from what is on screen; from then on a change rebuilds CUST_RAMP
 * the way ThemeColors and ezcfg's colors_accent do from COLORS=, and Theme
 * applies it. The accent (ACC_RGB) is copied with them, replacing one set
 * before (it is DV's highlight too, DV_RAMP, which follows); the accent row
 * in DV sets that highlight and leaves DV on. DV's background and text are
 * not for setting, as its font is not: A on those rows and on FONT, which
 * reads SLIM there, does nothing. SetCommit writes COLORS= with the rest.
 *
 * When that first change moves the accent to another color index (light and
 * dark have none) or leaves DV's glyphs, the screen is laid out again: op 5
 * sets CP_EDIT bit 7 and returns A, the stock loop dispatches it, and op 3
 * returns 2 for it. CP_EDIT stays set, so the row is still being set after.
 *
 *   op 6  arg = the row the cursor is moving to: returns the row it lands
 *         on, the next one that can be set the way it was going (SET_CUR is
 *         where it was)
 *
 * A row that can't be set is drawn in color index 2, DV's blue and a gray
 * elsewhere, with no highlight, and the cursor passes over it: FONT, BG and
 * TEXT in DV. Palette RAM is locked on a DMG and in compatibility mode
 * (PAL_LOCKED): there are no colors to set, and the color rows and their
 * heading are not drawn at all.
 */

#include "types.h"
#include "draw.h"
#include "vars.h"
#include "ezcfg.h"

extern void FarCallTrampoline(void);    /* 00:078d */
extern u8 ReadJoypad(void);             /* 00:3a4a, post-swap byte: RIGHT 1, LEFT 2, UP 4, DOWN 8, A $10, B $20 */

#define ROW_THEME 14
#define ROW_UI    15
#define ROW_BG    16         /* then TEXT and ACCENT */

#define rSTAT (*(volatile u8 *)0xff41)
#define rBCPS (*(volatile u8 *)0xff68)
#define rBCPD (*(volatile u8 *)0xff69)

static void labels(void);
static u8 locked(u8 row);
static u8 skip(u8 cur);
static void rows(u8 cur);
static u8 press(u8 row);
static u8 tick(u8 pad);
static void theme_btn(u8 hi);
static u8 theme_step(void);
static void color_row(u8 ci, u8 hi);
static u8 change(u8 ci, u8 k, u8 up);
static void rebuild(void);
static void pack(u8 *d, const u8 *c);
static u8 scale255(u8 c, u8 m);
static u8 pal_idx(u8 ci);
static void pal_get(u8 idx, u8 *c);
static u8 pal_byte(u8 i);
static void seed(u8 idx, u8 *d);
static u8 widen(u8 v);
static void button(u8 hi, u8 x0, u8 y0, u8 x1, u8 y1);
static void text(const u8 *s, u8 col, u8 row, u8 x12, u8 end12);
static void FarTheme(void);

u8 ThemePage(u16 pad_thunk, u16 pad_af, u16 pad_ret, u8 op, u8 arg) {
    u8 r = 0;
    (void)pad_thunk; (void)pad_af; (void)pad_ret;
    if (op == 0) labels();
    else if (op == 1) rows(arg);
    else if (op == 3) r = press(arg);
    else if (op == 6) return skip(arg);
    else return tick(arg);
    StoreDrawParams(3, 0, 0);
    return r;
}

/* x of a color cell's box, 25 px wide, the last one ending at x 155 as the
 * buttons above do */
#define CELL_X(k) ((u8)(0x43 + ((k) << 5)))

static void labels(void) {
    static const u8 theme_label[7] = {'T','H','E','M','E',':',0};
    static const u8 font_label[6] = {'F','O','N','T',':',0};
    static const u8 colors_label[8] = {'C','O','L','O','R','S',':',0};
    static const u8 rgb[6] = {'R',0,'G',0,'B',0};
    static const u8 names[3][8] = {
        {'B','G',':',0},
        {'T','E','X','T',':',0},
        {'A','C','C','E','N','T',':',0},
    };
    u8 k;

    StoreDrawParams(3, 0, 0);
    text(theme_label, 0, 2, 0, 84);
    text(font_label, 0, 4, 0, 112);
    if (PAL_LOCKED) return;
    text(colors_label, 0, 6, 0, 64);
    for (k = 0; k < 3; k++) {
        text(rgb + (k << 1), 10 + (k << 2), 6, CELL_X(k) + 9, CELL_X(k) + 22);
        text(names[k], 0, 8 + (k << 1), 0, 64);
    }
}

static void rows(u8 cur) {
    static const u8 ui8_str[5] = {' ','8','p','x',0};
    static const u8 ui12_str[5] = {'1','2','p','x',0};
    static const u8 slim_str[5] = {'S','L','I','M',0};
    u8 i;

    theme_btn(cur == ROW_THEME);
    button(locked(ROW_UI) ? 2 : cur == ROW_UI, 0x73, 0x1d, 0x9b, 0x29);
    /* DV has one font, its glyph set, which is SLIM's letters */
    text(GLYPHS_DV ? slim_str : hUiMode ? ui12_str : ui8_str, 15, 4, 120, 155);
    if (PAL_LOCKED) return;
    for (i = 0; i < 3; i++) color_row(i, cur == (u8)(ROW_BG + i));
}

/* A row A does nothing on: DV has one font and is black and white, only its
 * highlight is set; without palette RAM there are no colors at all. */
static u8 locked(u8 row) {
    if (row < ROW_UI || row > ROW_BG + 2) return 0;
    if (row >= ROW_BG && PAL_LOCKED) return 1;
    return THEME == THEME_DV && row != ROW_BG + 2;
}

/* The cursor never rests on such a row: it goes on the way it was going.
 * THEME above and PREV below are never locked. */
static u8 skip(u8 cur) {
    u8 down = cur > SET_CUR;
    while (locked(cur)) {
        if (down) cur++; else cur--;
    }
    return cur;
}

static u8 press(u8 row) {
    if (CP_EDIT & 0x80) {               /* op 5's layout request */
        CP_EDIT &= 0x7f;
        return 2;
    }
    if (row == ROW_THEME) return theme_step();
    if (row == ROW_UI) {
        if (locked(row)) return 0;      /* DV decides the font */
        /* 8px, 12px, SLIM (DV's glyph set, 12px), 8px */
        if (!hUiMode) hUiMode = 1;
        else if (!FONT_SLIM) FONT_SLIM = 1;
        else hUiMode = FONT_SLIM = 0;
        return 2;
    }
    if (locked(row)) return 0;
    CP_EDIT = 1;
    color_row(row - ROW_BG, 1);
    return 0;
}

static u8 tick(u8 pad) {
    u8 e = CP_EDIT, ci, k, r;

    if (!e) {
        /* B on THEME steps back: the loop sees A, and theme_step the flag */
        if ((pad & 0x20) && SET_CUR == ROW_THEME) {
            THEME_BACK = 1;
            pad ^= 0x30;
        }
        return pad;
    }
    ci = SET_CUR - ROW_BG;
    k = e - 1;
    if (pad & 0x30) {
        CP_EDIT = 0;
        color_row(ci, 1);
        while (ReadJoypad() & 0x30) {}
    } else if (pad & 0x03) {
        if (pad & 1) k = k == 2 ? 0 : k + 1;
        else k = k ? k - 1 : 2;
        CP_EDIT = k + 1;
        color_row(ci, 1);
    } else if (pad & 0x0c) {
        r = change(ci, k, pad & 0x04);
        if (r == 3) {
            CP_EDIT |= 0x80;
            return 0x10;
        }
        if (r == 2) rows(SET_CUR);      /* the THEME button reads CUSTOM now */
        else if (r) color_row(ci, 1);
    } else {
        return 0;
    }
    StoreDrawParams(3, 0, 0);
    return 0;
}

/* The THEME button (theme_row.c until the page moved here). The order is
 * light, dark, DV, red .. blue, then custom when there are custom colors.
 * With palette RAM locked the colored themes and custom are the dark
 * palette, so it is only light, dark, DV, and one of the others set in the
 * file shows as DARK; THEME keeps its value until the button is pressed.
 * 12px: wider to the left, PURPLE is about 60 px. */
static const u8 theme_names[THEME_COUNT][7] = {
    {' ','L','I','G','H','T',0},
    {' ',' ','D','A','R','K',0},
    {' ',' ',' ','R','E','D',0},
    {' ','G','R','E','E','N',0},
    {'P','U','R','P','L','E',0},
    {' ',' ','B','L','U','E',0},
    {'C','U','S','T','O','M',0},
    {' ',' ',' ',' ','D','V',0},     /* THEME_DV, after custom (vars.h) */
};

static u8 shown(void) {
    u8 t = THEME;
    if (PAL_LOCKED && t > 1 && t != THEME_DV) t = 1;
    return t;
}

static void theme_btn(u8 hi) {
    button(hi, hUiMode ? 0x56 : 0x63, 0x0d, 0x9b, 0x19);
    text(theme_names[shown()], 13, 2, 0x5b, 0x9a);
}

static u8 theme_step(void) {
    /* DV keeps its number, 7, after custom (vars.h) */
    static const u8 order[8] = {0, 1, THEME_DV, 2, 3, 4, 5, THEME_CUSTOM};
    u8 was_g = GLYPHS_DV, was_a = ACC_IDX;
    u8 i, t = shown(), n = PAL_LOCKED ? 3 : CUST_OK ? 8 : 7;

    for (i = 0; order[i] != t; i++) {}
    if (THEME_BACK) i = i ? i - 1 : n - 1;
    else i = (u8)(i + 1) == n ? 0 : i + 1;
    THEME_BACK = 0;
    THEME = order[i];
    SET_DIRTY = 1;
    FarTheme();
    /* onto or off DV, whose glyph set is its own (12px only), or onto
     * or off an accent (the bars were drawn in another color index,
     * dv_params.c): the tab strip and the pane are drawn again */
    if (GLYPHS_DV != was_g || ACC_IDX != was_a) {
        if (THEME == THEME_DV) hUiMode = 1;
        return 2;
    }
    rows(ROW_THEME);                    /* the color rows follow the theme */
    return 0;
}

/* One color's three cells: all three highlighted with the cursor on the
 * row, only the channel being set while one is. */
static void color_row(u8 ci, u8 hi) {
    u8 c[3], s[3];
    u8 k, v, x0, e = CP_EDIT & 3, row = 8 + (ci << 1), y = row << 3;
    u8 w = GLYPHS_DV ? 6 : 9;           /* a 12px digit */

    u8 off = locked(ROW_BG + ci);

    pal_get(pal_idx(ci), c);
    s[2] = 0;
    for (k = 0; k < 3; k++) {
        x0 = CELL_X(k);
        button(off ? 2 : hi && (!e || e == (u8)(k + 1)), x0, y - 3, x0 + 24, y + 9);
        x0 += 13 - w;                   /* two digits, centered */
        v = c[k];
        s[0] = ' ';
        if (v >= 10) {
            s[0] = '0';
            do { v -= 10; s[0]++; } while (v >= 10);
        } else {
            x0 += w;                    /* 12px: one digit, right-aligned */
        }
        s[1] = '0' + v;
        text(s, 9 + (k << 2), row, x0, CELL_X(k) + 23);
    }
}

/* UP or DOWN on channel k of color ci: 0 nothing changed (the channel is at
 * its end), 1 the color did, 2 and THEME became custom, 3 and the screen
 * needs laying out again. */
static u8 change(u8 ci, u8 k, u8 up) {
    u8 c[3];
    u8 v, acc = pal_idx(2), was_g = GLYPHS_DV, was_a = ACC_IDX, was_t = THEME;
    u8 keep_dv = was_t == THEME_DV && ci == 2;

    pal_get(pal_idx(ci), c);
    v = c[k];
    if (up) {
        if (v == 31) return 0;
        v++;
    } else {
        if (!v) return 0;
        v--;
    }
    if (was_t != THEME_CUSTOM) {
        /* a built-in theme: its background and ink are the custom theme's
         * from here */
        if (!keep_dv || !CUST_OK) {
            seed(0, CUST_RGB);
            seed(3, CUST_RGB + 3);
            CUST_OK = 1;
        }
        /* ...and so is its accent, whichever row changed and whatever
         * accent was set before (since 2026-11-11; until then BG and TEXT
         * left the accent alone and the ACCENT row jumped to an older
         * one). DV's highlight is the same value, so it follows. */
        if (!keep_dv) {
            seed(acc, ACC_RGB);
            ACC_OK = 1;
            THEME = THEME_CUSTOM;
        }
    }
    /* In custom, and in DV on the accent row (its highlight), the accent
     * starts from the one on screen the first time it is set. */
    if (ci == 2) {
        if (!ACC_OK) seed(acc, ACC_RGB);
        ACC_OK = 1;
    }
    (ci == 2 ? ACC_RGB : CUST_RGB + (ci ? 3 : 0))[k] = widen(v);
    rebuild();
    SET_DIRTY = 1;
    FarTheme();
    if (GLYPHS_DV != was_g || ACC_IDX != was_a) return 3;
    return THEME != was_t ? 2 : 1;
}

/* CUST_RAMP from CUST_RGB and ACC_RGB, as COLORS= builds it: the background,
 * the background 3/16 of the way to the ink (ThemeColors' four halving
 * steps), the accent (the third color, else the background's complement at
 * full brightness, or the ink for a gray background, which has none:
 * ezcfg's colors_accent), the ink. And DV with the accent for its lime. */
static void rebuild(void) {
    static const u8 dv[8] = {0x00, 0x00, 0, 0, 0x80, 0x61, 0xff, 0x7f};
    u8 c[3];
    u8 i, h, mx, mn;
    u16 t;

    pack(CUST_RAMP, CUST_RGB);
    pack(CUST_RAMP + 6, CUST_RGB + 3);
    for (i = 0; i < 3; i++) {
        t = CUST_RGB[i];
        t = (t + CUST_RGB[i + 3]) >> 1;
        t = (t + CUST_RGB[i + 3]) >> 1;
        t = (t + CUST_RGB[i]) >> 1;
        t = (t + CUST_RGB[i]) >> 1;
        c[i] = (u8)t;
    }
    pack(CUST_RAMP + 2, c);
    if (ACC_OK) {
        for (i = 0; i < 3; i++) c[i] = ACC_RGB[i];
    } else {
        mx = mn = CUST_RGB[0];
        for (i = 1; i < 3; i++) {
            if (CUST_RGB[i] > mx) mx = CUST_RGB[i];
            if (CUST_RGB[i] < mn) mn = CUST_RGB[i];
        }
        h = 0;
        for (i = 0; i < 3; i++) {
            c[i] = mx == mn ? CUST_RGB[i + 3] : (u8)(mx + mn - CUST_RGB[i]);
            if (c[i] > h) h = c[i];
        }
        if (h && mx != mn) for (i = 0; i < 3; i++) c[i] = scale255(c[i], h);
    }
    pack(CUST_RAMP + 4, c);
    if (ACC_OK) {
        for (i = 0; i < 8; i++) DV_RAMP[i] = dv[i];
        DV_RAMP[2] = CUST_RAMP[4];
        DV_RAMP[3] = CUST_RAMP[5];
    }
}

/* BGR555, little endian: r | g << 5 | b << 10, each channel's top 5 bits */
static void pack(u8 *d, const u8 *c) {
    d[0] = (u8)((c[0] >> 3) | ((c[1] & 0x38) << 2));
    d[1] = (u8)((c[1] >> 6) | ((c[2] >> 1) & 0x7C));
}

/* c * 255 / m for c <= m, by shift and subtract (ezcfg.c's) */
static u8 scale255(u8 c, u8 m) {
    u16 num = ((u16)c << 8) - c;
    u16 d = (u16)m << 7;
    u8 bit = 0x80, q = 0;

    while (bit) {
        if (num >= d) {
            num -= d;
            q |= bit;
        }
        d >>= 1;
        bit >>= 1;
    }
    return q;
}

/* The color index a row shows: the background, the ink, the accent (shade
 * 2 where a theme has none, light and dark) */
static u8 pal_idx(u8 ci) {
    if (ci == 0) return 0;
    if (ci == 1) return 3;
    return ACC_IDX ? ACC_IDX : 2;
}

/* Color idx of BG palette 0 (all eight hold the theme) as R, G, B, 0..31 */
static void pal_get(u8 idx, u8 *c) {
    u8 lo = pal_byte(idx << 1), hi = pal_byte((u8)(idx << 1) | 1);
    c[0] = lo & 0x1f;
    c[1] = ((lo >> 5) | (u8)(hi << 3)) & 0x1f;
    c[2] = (hi >> 2) & 0x1f;
}

/* Palette RAM reads $FF while the LCD draws a line (mode 3): read in mode 0
 * or 1, and again if a line started under the read. */
static u8 pal_byte(u8 i) {
    u8 v;
    do {
        rBCPS = i;
        while (rSTAT & 2) {}
        v = rBCPD;
    } while (rSTAT & 2);
    return v;
}

/* Color idx on screen as the R, G, B bytes COLORS= holds */
static void seed(u8 idx, u8 *d) {
    u8 c[3];
    u8 i;
    pal_get(idx, c);
    for (i = 0; i < 3; i++) d[i] = widen(c[i]);
}

/* 5 bits to 8, 31 to 255 */
static u8 widen(u8 v) {
    return (u8)((u8)(v << 3) | (v >> 2));
}

/* A button's box in 8px coordinates, in the ink its text then uses
 * (flcfg.c's): 12px, the text row plus a pixel above and below. hi 1 is
 * the cursor's highlight, 2 a button that can't be pressed, in index 2. */
static void button(u8 hi, u8 x0, u8 y0, u8 x1, u8 y1) {
    if (hi == 1) StoreDrawParams(0, 3, 0);
    else StoreDrawParams(hi ? 2 : 3, 0, 0);
    if (hUiMode) {
        y0 += 2;
        y1 += 3;
    }
    DrawRect(x0, y0, x1, y1, 1);
}

/* Text in the UI mode's font: 8px at (col, row); 12px on the same row from
 * x12, without its leading blanks, repainting up to end12. The 12px
 * renderer runs in another bank, so it gets a copy on the stack. */
static void text(const u8 *s, u8 col, u8 row, u8 x12, u8 end12) {
    u8 buf[10];
    u8 n;

    if (!hUiMode) {
        for (n = 0; s[n]; n++) {}
        DrawString(s, n, col, row);
        return;
    }
    while (*s == ' ') s++;
    for (n = 0; (buf[n] = s[n]) != 0; n++) {}
    hClip12 = end12;
    FarCallDrawString12(buf, 0, x12, (u8)((u8)(row << 3) + 2));
    hClip12 = 0;
}

/* Theme (02:43d0, theme.c): the palettes and the pSRAM mark from THEME */
static void FarTheme(void) __naked {
    __asm
	call	_FarCallTrampoline
	.dw	0x43d0
	.db	2, 0
	ret
    __endasm;
}
