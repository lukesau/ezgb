/* Fast-launch configuration from the SET tab (docs/fastlaunch-set-tab.md).
 *
 * Bank 4, injected at 04:6600, same bank as DrawTimeAutosaveScreen (04:46f4)
 * so the hand-assembled hook shims (04:5932..) reach it with a plain call.
 * The SD file /EZGB.CFG is the single source of truth, read and written by
 * the shared bank-2 module ezcfg.c (docs/ezgb-cfg.md) through the bank-4
 * FarCallEzCfg shim (04:5f00); this file only owns the FL_* WRAM state and
 * the SET-tab UI:
 *
 *   FLAUNCH=<path>       -> enabled, launch that ROM
 *   FLAUNCH=#<path>      -> DISABLED (every trigger skipped), path kept
 *   missing / empty      -> enabled, no explicit target (lone-ROM rule, see
 *                           fastlaunch.c)
 *
 * One entry point, op-selected (inject.py pins the first-declared function):
 *
 *   op 0 ENTER  SET prologue: cancel any pending pick, load the file, draw
 *               the page's mod rows with the cursor highlight.
 *   op 1 ROWS   cursor moved (hiliteDec/hiliteInc tails): keep it on the
 *               page, redraw the rows.
 *   op 2 A      A pressed with the cursor on a mod row. The checkboxes, THEME
 *               and UI toggle and rewrite the file (returns 0 = jp redraw); SGB BOOT
 *               toggles its pSRAM record instead (no file); PICK ROM
 *               arms pick mode (returns 1 = leave the SET screen; the bank-0
 *               FlSetExitHook then re-enters the browser); NEXT and PREV
 *               switch the page (returns 2 = enter the SET screen again).
 *   op 3 PICK   the browser's A-on-ROM hook (bank 0, via FlPickCommitFar):
 *               compose $c2a6 + '/' + $c4a4, rewrite the file, disarm.
 *   op 4 LOAD   test hook only.
 *   op 5 TICK   once per pass of the SET input loop (SetLoopTickHook,
 *               04:5f20, on its ReadJoypad call): scroll the ROM name,
 *               then read the pad with a D-pad key repeat and return it.
 *
 * Two pages (8px rows; the stock rows were slid up one, see inject-ezcfg.sh):
 *   page 1: 2 TIME: [SET]   4 date/time   6 RTC: SD [ ] NO SD [ ]
 *           8 AUTO SAVE: [ ]   10 FAST LAUNCH: [ ]
 *           12 <name, 10 cols, scrolling> [PICK ROM]   14 SGB BOOT: [ ]
 *           16 1/2 [NEXT >]
 *   page 2: 2 THEME: [LIGHT]   4 FONT: [8px]   6 SHOW NAME TAGS: [x]
 *           8 Ex: <name, scrolling>   16 [< PREV] 2/2               (setpage.c)
 * `frame` is DrawTimeAutosaveScreen's stack frame (frame[0x3d] = cursor row:
 * 0 TIME SET, 1 RTC, 2 AUTO SAVE, 3 FAST LAUNCH, 4 PICK ROM, 5 SGB BOOT,
 * 6 NEXT; 7 THEME, 8 UI, 9 TAGS, 10 PREV). The stock clamp lets the cursor
 * run 0..10; op ROWS keeps it on the page. Page 2 is drawn over the stock
 * screen, which keeps running: SetText drops its text there (SET_PAGE, vars.h)
 * and op ROWS clears its dirty flag (frame[0x3e]) so it draws no boxes.
 *
 * SGB BOOT is not in EZGB.CFG: the boot stub (scripts/sgb/sgb_boot.asm) runs
 * long before the SD card is up, so it reads a record in battery-backed
 * pSRAM, page $11 at $A400 ('S', 'G', flag, ~flag; docs/psram-page-map.md).
 * Set it on a DMG/GBC/GBA, then move the cart to the Super Game Boy.
 * NULL for op 3/4/5.
 *
 * ezcfg leaves $7FC0=$00 after its SD I/O. The SET screen rests at $7FC0=$00,
 * so nothing to restore there; after a pick the SET prologue re-selects its
 * own pages. ReadJoypad is level triggered, so every A action spins until A
 * is released; otherwise the screen we hand over to sees the same press.
 */

#include "types.h"
#include "draw.h"
#include "vars.h"
#include "ezcfg.h"

extern void FarCallEzCfg(void);                                     /* 04:5f00 -> ezcfg (02:4a00) */
extern void SetFpgaPage_B4(u8 page);                                /* 04:466e: $7FC0 = page */
extern void FarCallMenuTabs(u8 tab);                                /* 04:5f70 -> DrawMenuTabs (08:7169) */
extern void SetText(const u8 *s, u8 len, u8 col, u8 row);           /* 04:6400, settext.c: DrawString, or the 12px pane's fields */
extern u8 ReadJoypad(void);                                         /* 00:3a4a, post-swap byte, A = $10 */
extern void ThemeRow(u8 op);                                        /* 04:7670, theme_row.c: the THEME button */
extern void SetPage(u8 op, u8 cur);                                 /* 04:7792, setpage.c: SGB BOOT, page 2, the page row */

#define FL_DISP  ((u8 *)0xDB10)     /* 40 bytes: marquee text the marquee can read (bank 4 ROM it cannot) */
#define CWD      ((u8 *)0xC2A6)     /* browser: current directory ("/" or "/a/b") */
#define SELNAME  ((u8 *)0xC4A4)     /* browser: selected entry name */

#define DISP_LEN  40

#define ROW_RTC   1          /* RTC: SD / NO SD (RTC backup, restore and prompt on or off);
                              * row 2 is the stock AUTO SAVE, which never reaches flcfg */
#define ROW_CHECK 3
#define ROW_PICK  4
#define ROW_SGB   5          /* SGB BOOT: checkbox, a pSRAM record (setpage.c) */
#define ROW_NEXT  6          /* page 1's last row */
#define ROW_THEME 7          /* page 2: THEME button (theme_row.c, docs/dark-mode.md) */
#define ROW_UI    8          /* FONT: 8px / 12px button (docs/ui-mode.md) */
#define ROW_TAGS  9          /* SHOW NAME TAGS: checkbox: off hides ROM name tags (docs/browser-tags.md) */
#define ROW_PREV  10         /* page 2's last row */
#define PAGE2     (SET_PAGE & 1)
#define NAME_X1  79                         /* the name's field ends left of PICK ROM: ten 8px cells, x 0..79 */

#define HPADLATCH (*(volatile u8 *)0xFFFD)  /* VBlankPadLatch: buttons pressed since the last read */
#define RP_DIR   (*(volatile u8 *)0xDBEC)   /* D-pad bits of the held direction, 0 = none */
#define RP_LEFT  (*(volatile u8 *)0xDBED)   /* frames until it repeats */
#define RP_DELAY 24                         /* first repeat after 0.4 s held */
#define RP_RATE  6                          /* then 10 steps a second */

#include "marquee.h"

static void cfg_load(void);
static void cfg_save(void);
static void draw_static(void);
static void draw_name(void);
static void draw_rows(u8 cur);
static void pick_commit(void);
static void wait_a_release(void);
static void box(u8 x, u8 y, u8 on, u8 hi);
static void button(u8 hi, u8 x0, u8 y0, u8 x1, u8 y1);
static u8 flcfg_op(u8 *frame, u8 op);

/* SET_PAGE bit 7 tells SetText the text is ours, which page 2 draws */
u8 flcfg(u8 *frame, u8 op) {
    u8 r;
    SET_PAGE |= 0x80;
    r = flcfg_op(frame, op);
    SET_PAGE &= 1;
    return r;
}

static u8 flcfg_op(u8 *frame, u8 op) {
    if (op == 0) {
        FL_PICK = 0;
        /* entered again after a page or UI switch: the cursor goes back on
         * the row that did it (NEXT lands on PREV and back), so A switches
         * straight back */
        if (SET_RE) {
            frame[0x3d] = SET_RE - 1;
            SET_RE = 0;
            /* the stock entry code has drawn its boxes, TIME's SET
             * highlighted for the cursor on row 0: page 2 clears them,
             * page 1 draws SET plain */
            SetPage(PAGE2 ? 4 : 8, 0);
        }
        cfg_load();
        draw_static();
        draw_rows(frame[0x3d]);
        SetFpgaPage_B4(0);
        return 0;
    }
    if (op == 1) {
        u8 cur = frame[0x3d];
        if (PAGE2) {
            if (cur < ROW_THEME) cur = ROW_THEME;
            frame[0x3e] = 0;            /* no stock redraw: its boxes are page 1's */
        } else if (cur > ROW_NEXT) {
            cur = ROW_NEXT;
        }
        frame[0x3d] = cur;
        draw_rows(cur);
        return 0;
    }
    if (op == 2) {
        u8 row = frame[0x3d];
        if (row == ROW_NEXT || row == ROW_PREV) {
            /* enter the screen again on the other page, over a clear pane */
            SET_PAGE ^= 1;
            SET_RE = (row == ROW_NEXT ? ROW_PREV : ROW_NEXT) + 1;
            SetPage(4, 0);
            wait_a_release();
            return 2;
        }
        if (row == ROW_CHECK || row == ROW_RTC || row == ROW_THEME) {
            if (row == ROW_THEME) {
                ThemeRow(2);            /* saves, sets the palettes, redraws itself */
            } else {
                if (row == ROW_CHECK) FL_EN = FL_EN ? 0 : 1; else RTC_OFF = RTC_OFF ? 0 : 1;
                cfg_save();
                draw_rows(row);
            }
            wait_a_release();
            SetFpgaPage_B4(0);
            return 0;
        }
        if (row == ROW_SGB || row == ROW_TAGS) {
            SetPage(row == ROW_SGB ? 7 : 3, 0);   /* toggles, saves, redraws */
            wait_a_release();
            SetFpgaPage_B4(0);
            return 0;
        }
        if (frame[0x3d] == ROW_UI) {
            /* The whole pane (and the tab strip) is laid out per mode:
             * redraw the strip, which also clears the pane, and return 2 so
             * FlSetADispatch re-enters the SET screen from the top. */
            hUiMode = hUiMode ? 0 : 1;
            cfg_save();
            FarCallMenuTabs(1);
            wait_a_release();
            SetFpgaPage_B4(0);
            SET_RE = ROW_UI + 1;          /* op 0 of the re-entry: put the cursor back here */
            return 2;
        }
        FL_PICK = 1;
        wait_a_release();
        return 1;
    }
    if (op == 3) {
        pick_commit();
        return 0;
    }
    if (op == 5) {
        /* Paced in frames, not loop passes: a pass takes anything from a
         * fraction of a frame (1.05e) to exactly one (1.04e waits for VBlank
         * each pass), so count the VBlank interrupt's frame counter. */
        u8 d = HFRAME - MQ_A->fr, fresh, pad, dir;
        if (d > 100) d = 100;
        /* the name on screen: page 1's, or page 2's tag example */
        MQ_RUN(FarCallMarquee, MQ_A, MQ_STEP);
        /* The loop's pad read, with a key repeat on the D-pad. ReadJoypad
         * reports a held direction on every pass, and a pass is a fraction
         * of a frame, so a tap moved the cursor or a time field two or three
         * steps. A direction now acts once, then again after RP_DELAY frames
         * held, then every RP_RATE. A new edge in the latch (released and
         * pressed again between two reads) counts as a new press. */
        fresh = HPADLATCH;
        pad = ReadJoypad();
        dir = pad & 0x0F;
        if (dir == 0) {
            RP_DIR = 0;
        } else if (dir != RP_DIR || (fresh & dir)) {
            RP_DIR = dir;
            RP_LEFT = RP_DELAY;
        } else if (RP_LEFT > d) {
            RP_LEFT -= d;
            pad &= 0xF0;
        } else {
            RP_LEFT = RP_RATE;
        }
        return pad;
    }
    cfg_load();
    return 0;
}

/* /EZGB.CFG -> FL_EN / FL_PLEN / FL_PATH (and the RTC copy, unused here). */
static void cfg_load(void) {
    EZ_OP = OP_LOAD;
    FarCallEzCfg();
}

/* FL_* (+ the RTC copy loaded alongside) -> /EZGB.CFG. */
static void cfg_save(void) {
    EZ_OP = OP_SAVE;
    FarCallEzCfg();
}

/* Browser A-on-ROM in pick mode: CWD + '/' + SELNAME becomes the new path.
 * The enable flag is preserved (a pick does not switch fast launch on). Too
 * long a path (> PATH_MAX) leaves the file untouched. */
static void pick_commit(void) {
    u8 lc, ln, need, n, i;

    cfg_load();                       /* refresh FL_EN (and the RTC line) from the file */

    for (lc = 0; CWD[lc]; lc++) {}
    for (ln = 0; SELNAME[ln]; ln++) {}
    need = lc + ln;
    if (lc == 0 || CWD[lc - 1] != '/') need++;
    if (need <= PATH_MAX) {
        n = 0;
        for (i = 0; i < lc; i++) FL_PATH[n++] = CWD[i];
        if (n == 0 || FL_PATH[n - 1] != '/') FL_PATH[n++] = '/';
        for (i = 0; i < ln; i++) FL_PATH[n++] = SELNAME[i];
        FL_PATH[n] = 0;
        FL_PLEN = n;
        cfg_save();
    }
    FL_PICK = 0;
    wait_a_release();
}

static void wait_a_release(void) {
    while (ReadJoypad() & 0x10) {}
}

/* Labels; the name is drawn by draw_name. */
static void draw_static(void) {
    static const u8 rtc_label[5] = {'R','T','C',':',0};
    static const u8 sd_label[3] = {'S','D',0};
    static const u8 nosd_label[6] = {'N','O',' ','S','D',0};
    static const u8 fl_label[13] = {'F','A','S','T',' ','L','A','U','N','C','H',':',0};
    if (PAGE2) {
        SetPage(0, 0);
        return;
    }
    StoreDrawParams(3, 0, 0);
    SetText(rtc_label, 4, 0, 6);
    SetText(sd_label, 2, 6, 6);
    SetText(nosd_label, 5, 11, 6);
    SetText(fl_label, 12, 0, 10);
    SetPage(5, 0);                    /* the SGB BOOT label */
    draw_name();
}

/* Basename of FL_PATH (or "(AUTO)" when there is no explicit path) left of
 * the PICK ROM button on row 12, in the shared marquee (marquee.c): a name
 * that does not fit scrolls, cursor or not, and op TICK steps it. The
 * marquee runs in bank 2, so "(AUTO)" is copied to FL_DISP first. */
static void draw_name(void) {
    static const u8 auto_str[7] = {'(','A','U','T','O',')',0};
    const u8 *src = FL_DISP;
    u8 i, base;

    if (FL_PLEN == 0) {
        for (i = 0; i < 7; i++) FL_DISP[i] = auto_str[i];
    } else {
        base = 0;
        for (i = 0; FL_PATH[i]; i++) if (FL_PATH[i] == '/') base = i + 1;
        src = FL_PATH + base;
    }
    MQ_A->s = src;
    MQ_A->x0 = 0;
    MQ_A->x1 = NAME_X1;
    MQ_A->y = 12 * 8;
    MQ_A->attr = 3;
    MQ_RUN(FarCallMarquee, MQ_A, MQ_START);
}

/* Checkbox at pixel x, row y/8 (the stock AUTO SAVE sequence, 04:496a, at
 * x $82; one row up is y $30): clear, outline (highlighted when the cursor is
 * on it), tick. */
static void box(u8 x, u8 y, u8 on, u8 hi) {
    StoreDrawParams(0, 0, 0);
    DrawRect(x, y, x + 8, y + 8, 1);
    if (hi) StoreDrawParams(1, 1, 0); else StoreDrawParams(3, 0, 0);
    DrawRect(x, y, x + 8, y + 8, 0);
    if (on) {
        StoreDrawParams(3, 3, 0);
        DrawRect(x + 2, y + 2, x + 6, y + 6, 1);
    }
}

/* A button's box, given in 8px coordinates, in the ink its text then uses:
 * highlighted when the cursor is on it. 12px: the box is the text row plus
 * a pixel above and below, 2 px lower at the top and 3 at the bottom. */
static void button(u8 hi, u8 x0, u8 y0, u8 x1, u8 y1) {
    if (hi) StoreDrawParams(0, 3, 0); else StoreDrawParams(3, 0, 0);
    if (hUiMode) {
        y0 += 2;
        y1 += 3;
    }
    DrawRect(x0, y0, x1, y1, 1);
}

/* Page 1: the RTC (row 6: "SD [ ]  NO SD [ ]", one of the two ticked; A
 * switches) and FAST LAUNCH (row 10) checkboxes, the PICK ROM button on row
 * 12, shaped like the stock SET button (box 5 px left and 4 px right of the
 * text, 3 px above and 5 below). SGB BOOT on row 14, page 2 and both pages'
 * row 16 are setpage.c's. */
static void draw_rows(u8 cur) {
    static const u8 pick_str[9] = {'P','I','C','K',' ','R','O','M',0};

    if (PAGE2) {
        SetPage(1, cur);
        return;
    }
    box(0x42, 0x30, !RTC_OFF, cur == ROW_RTC);   /* after "SD" (cols 6-7) */
    box(0x82, 0x30, RTC_OFF, cur == ROW_RTC);    /* after "NO SD" (cols 11-15) */
    box(0x82, 0x50, FL_EN, cur == ROW_CHECK);
    SetPage(6, cur);

    button(cur == ROW_PICK, 0x53, 0x5d, 0x9b, 0x69);
    SetText(pick_str, 8, 11, 12);
    SetPage(2, cur);
}
