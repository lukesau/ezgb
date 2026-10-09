/* Debug screen: a scrollable page of hardware readouts (docs/debug-tab.md).
 *
 * Debug builds only (scripts/make-debug-build.py), bank 4, at 04:7400 when
 * free. SELECT on HELP returns to the browser in a release build; in a
 * debug build DbgTabHook (00:0259) clears the pane first (DrawMenuTabs tab 3:
 * the strip stays on HELP) and far-calls this, which returns on SELECT like
 * the other tabs' loops.
 *
 * The page is a list of 20-column lines, built on the fly from a snapshot
 * (stats, refreshed on entry and after A), and drawn 16 at a time on rows
 * 2..17. UP/DOWN scroll a line, holding repeats. A writes the page $10 test
 * pattern (see below), then the snapshot is taken again.
 *
 * pSRAM probe (docs/psram-page-map.md): is page $10 really unused and not
 * an alias of another page? Page sums for $00, $01 (game save RAM), $10 and
 * $11 (kernel meta), page $10's first bytes, how many of the 256 byte values
 * occur in it (random power-on contents give ~250+), and whether the test
 * pattern is intact (OK, NONE, or BAD n). A fills page $10 with the pattern,
 * unless its sum and first 16 bytes match page $00, $01 or $11 (an alias
 * would turn that write into lost saves or settings).
 *
 * Then the SGB BOOT record, page $11 $A400-$A403 (docs/sgb-boot.md), and the
 * A register KernelEntry saved at boot (wBootA).
 *
 * Page access is the kernel's: $4000 = page, $7FC0 = $03, read through
 * $A000-$BFFF, then $4000 = 0, $7FC0 = 0.
 *
 *   scripts/make-debug-build.py <ver> [--install /Volumes/<card>]
 */

typedef unsigned char u8;
typedef unsigned int u16;

extern void SetFpgaPage_B4(u8 page);                                /* 04:466e: $7FC0 = page */
extern void DrawString(const u8 *s, u8 len, u8 col, u8 row);        /* 00:08b7 */
extern void DrawRect(u8 x0, u8 y0, u8 x1, u8 y1, u8 fill);          /* 00:27ba */
extern void StoreDrawParams(u8 color, u8 colorB, u8 op);            /* 00:2791 */
extern u8 ReadJoypad(void);                                         /* 00:3a4a: A $10, SELECT $40, UP 4, DOWN 8 */
extern void WaitVBlankFlag(void);                                   /* 00:0688 */
extern volatile u8 wBootA;                                          /* KernelEntry's copy of the boot A */

#define RAM_PAGE (*(volatile u8 *)0x4000)
#define WIN      ((volatile u8 *)0xA000)
#define PAGE_LEN 0x2000
#define ROWS     16          /* rows 2..17 */
#define FIRST    2
#define WIDTH    20
#define REPEAT   8           /* frames between scroll steps while held */
#define DELAY    24          /* ...after the first */

#define PAD_A      0x10
#define PAD_SELECT 0x40
#define PAD_UP     0x04
#define PAD_DOWN   0x08

typedef struct {
    u16 sum[4];              /* pages $00, $01, $10, $11 */
    u8 head[8];              /* page $10 $A000.. */
    u16 distinct;
    u16 diff;                /* page $10 bytes off the pattern */
    u8 alias;
    u8 rec[4];               /* page $11 $A400.. */
} Stats;

static const u8 pages[4] = {0x00, 0x01, 0x10, 0x11};

static void snapshot(Stats *st);
static u8 line(const Stats *st, u8 n, u8 *out);
static void draw(const Stats *st, u8 top);
static void map(u8 page);
static void unmap(void);
static u8 same_start(u8 a, u8 b);
static u8 pat(u16 i);
static void hex(u8 *out, u8 v);
static void dec(u8 *out, u16 v);
static void text(u8 *out, const u8 *s);

void DebugTab(void) {
    Stats st;
    u8 top = 0, j, held = 0, wait = 0, count;

    while (ReadJoypad() & PAD_SELECT) {}   /* the press that left HELP */
    snapshot(&st);
    draw(&st, top);
    for (count = 0; line(&st, count, 0); count++) {}
    for (;;) {
        WaitVBlankFlag();
        j = ReadJoypad();
        if (j & PAD_SELECT) return;
        if (j & PAD_A) {
            if (!st.alias) {
                u16 i;
                map(0x10);
                for (i = 0; i < PAGE_LEN; i++) WIN[i] = pat(i);
                unmap();
            }
            while (ReadJoypad() & PAD_A) {}
            snapshot(&st);
            draw(&st, top);
            continue;
        }
        if (!(j & (PAD_UP | PAD_DOWN))) {
            held = 0;
            continue;
        }
        if (held && --wait) continue;
        wait = held ? REPEAT : DELAY;
        held = 1;
        if ((j & PAD_DOWN) && top + ROWS < count) top++;
        else if ((j & PAD_UP) && top) top--;
        else continue;
        draw(&st, top);
    }
}

/* Line n of the page into out (WIDTH chars, blank-padded); 0 past the end. */
static u8 line(const Stats *st, u8 n, u8 *out) {
    static const u8 t_head[16] = {'P','S','R','A','M',' ','P','A','G','E',' ','S','U','M','S',0};
    static const u8 t_head8[18] = {'P','1','0',' ','F','I','R','S','T',' ','8',' ','B','Y','T','E','S',0};
    static const u8 t_values[12] = {'P','1','0',' ','V','A','L','U','E','S',':',0};
    static const u8 t_pattern[13] = {'P','1','0',' ','P','A','T','T','E','R','N',':',0};
    static const u8 t_ok[3] = {'O','K',0};
    static const u8 t_none[5] = {'N','O','N','E',0};
    static const u8 t_bad[4] = {'B','A','D',0};
    static const u8 t_write[20] = {'A',':','W','R','I','T','E',' ','P','1','0',' ','P','A','T','T','E','R','N',0};
    static const u8 t_alias[19] = {'P','1','0',' ','A','L','I','A','S',':','N','O',' ','W','R','I','T','E',0};
    static const u8 t_sgb[18] = {'S','G','B',' ','B','O','O','T',' ','P','1','1',':','A','4','0','0',0};
    static const u8 t_on[3] = {'O','N',0};
    static const u8 t_off[4] = {'O','F','F',0};
    static const u8 t_boot[17] = {'B','O','O','T',' ','A',' ','R','E','G','I','S','T','E','R',':',0};
    u8 i;

    if (n > 14) return 0;
    if (!out) return 1;
    for (i = 0; i < WIDTH; i++) out[i] = ' ';
    switch (n) {
    case 0: text(out, t_head); break;
    case 1:                               /* P00:xxxx P01:xxxx (game save RAM) */
    case 2:                               /* P10:xxxx P11:xxxx (probe, kernel meta) */
        for (i = 0; i < 2; i++) {
            u8 k = (u8)((n - 1) * 2 + i), *o = out + i * 9;
            o[0] = 'P';
            hex(o + 1, pages[k]);
            o[3] = ':';
            hex(o + 4, st->sum[k] >> 8);
            hex(o + 6, (u8)st->sum[k]);
        }
        break;
    case 4: text(out, t_head8); break;
    case 5:
        for (i = 0; i < 8; i++) hex(out + 1 + 2 * i, st->head[i]);
        break;
    case 6:
        text(out, t_values);
        dec(out + 11, st->distinct);      /* of 256; random contents ~250+ */
        break;
    case 7:
        text(out, t_pattern);
        if (st->diff == 0) text(out + 12, t_ok);
        else if (st->diff > 0x1F00) text(out + 12, t_none);
        else { text(out + 12, t_bad); dec(out + 16, st->diff); }
        break;
    case 8: text(out, st->alias ? t_alias : t_write); break;
    case 10: text(out, t_sgb); break;
    case 11:
        for (i = 0; i < 4; i++) hex(out + 1 + 2 * i, st->rec[i]);
        text(out + 10, (st->rec[0] == 'S' && st->rec[1] == 'G' && st->rec[2] == 1 && st->rec[3] == 0xFE) ? t_on : t_off);
        break;
    case 13: text(out, t_boot); break;
    case 14:
        hex(out + 1, wBootA);
        break;
    }
    return 1;
}

/* v in decimal, left-aligned, by subtraction (no divide in this build). */
static void dec(u8 *out, u16 v) {
    static const u16 pow10[4] = {1000, 100, 10, 1};
    u8 i, d, lead = 1;
    for (i = 0; i < 4; i++) {
        for (d = 0; v >= pow10[i]; d++) v -= pow10[i];
        if (d || !lead || i == 3) {
            *out++ = (u8)('0' + d);
            lead = 0;
        }
    }
}

static void draw(const Stats *st, u8 top) {
    u8 buf[WIDTH], r, i;
    StoreDrawParams(3, 0, 0);
    for (r = 0; r < ROWS; r++) {
        if (!line(st, (u8)(top + r), buf))
            for (i = 0; i < WIDTH; i++) buf[i] = ' ';
        DrawString(buf, WIDTH, 0, (u8)(FIRST + r));
    }
}

/* About 4 s on hardware speed: 40 KB of pSRAM through the $A000 window. */
static void snapshot(Stats *st) {
    static const u8 t_reading[17] = {'R','E','A','D','I','N','G',' ','P','S','R','A','M','.','.','.',0};
    u8 seen[32];
    u8 k, i;
    u16 n, s;

    StoreDrawParams(3, 0, 0);
    DrawString(t_reading, 16, 0, FIRST);

    for (k = 0; k < 4; k++) {
        s = 0;
        map(pages[k]);
        for (n = 0; n < PAGE_LEN; n++) s = (s << 1 | s >> 15) + WIN[n];
        st->sum[k] = s;
    }
    map(0x10);
    for (i = 0; i < 8; i++) st->head[i] = WIN[i];
    for (i = 0; i < 32; i++) seen[i] = 0;
    st->diff = 0;
    for (n = 0; n < PAGE_LEN; n++) {
        u8 v = WIN[n];
        seen[v >> 3] |= (u8)(1 << (v & 7));
        if (v != pat(n)) st->diff++;
    }
    st->distinct = 0;
    for (i = 0; i < 32; i++) {
        u8 b = seen[i];
        while (b) { st->distinct += b & 1; b >>= 1; }
    }
    map(0x11);
    for (i = 0; i < 4; i++) st->rec[i] = WIN[0x400 + i];
    unmap();
    st->alias = (st->sum[2] == st->sum[0] && same_start(0x10, 0x00)) ||
                (st->sum[2] == st->sum[1] && same_start(0x10, 0x01)) ||
                (st->sum[2] == st->sum[3] && same_start(0x10, 0x11));
}

static void map(u8 page) {
    RAM_PAGE = page;
    SetFpgaPage_B4(3);
}

static void unmap(void) {
    RAM_PAGE = 0;
    SetFpgaPage_B4(0);
}

/* First 16 bytes of two pages equal (copied through WRAM, one page mapped at
 * a time). */
static u8 same_start(u8 a, u8 b) {
    u8 buf[16], i, same = 1;
    map(a);
    for (i = 0; i < 16; i++) buf[i] = WIN[i];
    map(b);
    for (i = 0; i < 16; i++) if (WIN[i] != buf[i]) same = 0;
    unmap();
    return same;
}

static u8 pat(u16 i) {
    return (u8)((u8)i * 13 + (u8)(i >> 8) * 7 + 0x5A);
}

static void hex(u8 *out, u8 v) {
    static const u8 digits[16] = {'0','1','2','3','4','5','6','7','8','9','A','B','C','D','E','F'};
    out[0] = digits[v >> 4];
    out[1] = digits[v & 15];
}

static void text(u8 *out, const u8 *s) {
    while (*s) *out++ = *s++;
}
