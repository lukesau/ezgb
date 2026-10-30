/* Scrolling text in either UI font (marquee.h, docs/marquee.md).
 *
 * One routine for every name line that may not fit its field: the SET tab's
 * fast-launch name and tag example (flcfg.c, tagexample.c, through
 * FarCallMarquee) and the START overlay's and BACKUPSAVE prompt's lines
 * (lastrom_name.c, directly).
 *
 * The field is pixels x0..x1 at y. 8px: (x1 + 1 - x0) / 8 cells from tile
 * column x0 / 8 on tile row y / 8, DrawString drawing NUL as a blank, so the
 * window always overwrites the whole field. 12px: hClip12 = x1 + 1, which
 * DrawString12 and Fit12 both stop at, so as many whole glyphs as fit are
 * drawn and the field is repainted to its end. Whether the text fits is
 * measured the same way, in glyphs for 12px rather than a character count.
 *
 * MQ_STEP stamps fr even when the text fits: flcfg reads HFRAME - fr before
 * the step for its D-pad repeat.
 *
 * Bank 2, injected at 02:7260; the far stub FarCallMarquee (00:0410,
 * `cd 8d 07 60 72 02 00 c9`). No stack arguments: MQ_ARG and MQ_OPS.
 *
 *   python3 tools/inject.py src/marquee.c $V 2 7260 Marquee \
 *       --pin DrawString12=7500 --pin Fit12=7100 --pin DrawString=08b7 \
 *       --pin StoreDrawParams=2791 --pin PopupDrawParams=0290 --replace --apply
 */

#include "types.h"
#include "draw.h"
#include "vars.h"
#include "marquee.h"

#define BUF 40                              /* MAX_GLYPHS, and the 12px window */

/* The instance being run, copied in and back out: fixed addresses compile
 * to plain loads and stores where a pointer's fields do not. */
#define C (*(Mq *)0xDBC4)

static void draw(void);
static void params(u8 ink, u8 paper);
static void copy(u8 *dst, const u8 *src);

/* The entry point stays the first function in the file: the far stub
 * jumps to the block's first byte. */
void Marquee(void) {
    u8 len, f, d, op = MQ_OPS;
    u8 xs[BUF];

    copy((u8 *)&C, (const u8 *)MQ_ARG);
    if (op == MQ_START) {
        for (len = 0; len < 252 && C.s[len]; len++) {}   /* len + MQ_GAP stays a byte */
        C.len = len;
        C.pos = 0;
        C.tick = 0;
        C.fr = HFRAME;
        C.attr |= MQ_SCROLLS;
        if (hUiMode) {
            hClip12 = (u8)(C.x1 + 1);
            if (Fit12(0, 0, C.s, 0, C.x0, xs) >= len) C.attr &= ~MQ_SCROLLS;
            hClip12 = 0;
        } else if (len <= (u8)((u8)(C.x1 + 1 - C.x0) >> 3)) {
            C.attr &= ~MQ_SCROLLS;
        }
        draw();
    } else if (op == MQ_STEP) {
        f = HFRAME;
        d = f - C.fr;
        C.fr = f;
        if (C.attr & MQ_SCROLLS) {
            if (d > 100) d = 100;           /* tick stays below 256 */
            C.tick += d;
            if (C.tick >= (C.pos == 0 ? MQ_HOLD : MQ_RATE)) {
                C.tick = 0;
                if (++C.pos >= (u8)(C.len + MQ_GAP)) C.pos = 0;
                draw();
            }
        }
    } else {
        draw();
    }
    copy((u8 *)MQ_ARG, (const u8 *)&C);
}

/* The window from pos, blanks after the text; a scrolling text starts
 * again after MQ_GAP of them (k never wraps when wrap is 0). */
static void draw(void) {
    u8 buf[BUF];
    u8 *p = buf;
    const u8 *s = C.s;
    u8 n, k = C.pos, len = C.len, wrap = 0;

    if (C.attr & MQ_SCROLLS) wrap = len + MQ_GAP;
    for (n = BUF - 1; n; n--) {
        *p++ = k < len ? s[k] : ' ';
        if (++k == wrap) k = 0;
    }
    *p = 0;
    params(C.attr & 3, (C.attr >> 2) & 3);
    if (hUiMode) {
        hClip12 = (u8)(C.x1 + 1);
        DrawString12(0, 0, 0, buf, 0, C.x0, C.y);
        hClip12 = 0;
    } else {
        DrawString(buf, (u8)((u8)(C.x1 + 1 - C.x0) >> 3), C.x0 >> 3, C.y >> 3);
    }
    params(3, 0);
}

static void copy(u8 *dst, const u8 *src) {
    u8 n;
    for (n = sizeof(Mq); n; n--) *dst++ = *src++;
}

/* The field's ink and paper, or back to the plain (3, 0) after it, in the
 * caller's kind of draw parameters. */
static void params(u8 ink, u8 paper) {
    if (C.attr & MQ_POPUP) PopupDrawParams(ink, paper);
    else StoreDrawParams(ink, paper, 0);
}
