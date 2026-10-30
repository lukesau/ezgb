/* START overlay name line and its marquee (docs/last-rom.md "Overlay layout").
 *
 * Bank 2, injected at 02:5d58 and reached through the 8-byte far stub
 * LastRomNameStub (00:0368, `cd 8d 07 58 5d 02 00 c9`). The stub is
 * `call`ed: three pad parameters. Two callers:
 *
 *   LastRomDrawBasename's `call DrawString` (00:132b) now calls the stub
 *   with the same (s, len, x, y) frame: s != 0 sets the name up and draws
 *   it. ezcfg's "(none)" line near-calls the same entry with dummies for
 *   the pads.
 *
 *   LastRomInputLoop's `call ReadJoypad` (00:1330) now calls
 *   LastRomTickStub (00:0370), which pushes s = 0, calls the stub and
 *   leaves through `jp ReadJoypad`: s == 0 is the marquee tick.
 *
 * The scrolling is the shared marquee's (marquee.c, MQ_A). The field: 8px,
 * tile row 14 from column 1, 18 characters (the caller's x, y are not
 * used); 12px, a 12px row at y 112 from x 12 to x 156, which keeps the ink
 * two pixels short of the box's right side. The name is drawn in paper on
 * ink, on the solid band LastRomBox laid across the box.
 *
 * A second line scrolls the same way: the BACKUPSAVE prompt's "Played"
 * line (bkprompt.c), set up with LR_GEO = 2 and drawn in ink on paper on
 * the box's info row, in MQ_B: set up in MQ_A's place, then swapped
 * back. Every other set-up (LR_GEO 0 or 1) clears MQ_B's text, so it never
 * outlives the prompt. Every other set-up (LR_GEO 0 or 1) clears
 * MQ_B's text, so it never outlives the prompt.
 *
 *   python3 tools/inject.py src/lastrom_name.c $V 2 5d58 LastRomName \
 *       --pin Marquee=7260 --replace --apply
 */

#include "types.h"
#include "draw.h"
#include "vars.h"

#include "marquee.h"

#define A (*MQ_A)
#define B (*MQ_B)

static void swap(void);

/* The entry point stays the first function in the file: the far stub
 * jumps to the block's first byte. */
void LastRomName(u16 far_pad_thunk, u16 far_pad_af, u16 far_pad_ret, const u8 *s) {
    /* tile row by LR_GEO; the 12px row is at 8x that y */
    static const u8 row8[3] = {14, 7, 9};

    (void)far_pad_thunk;
    (void)far_pad_af;
    (void)far_pad_ret;
    if (s == 0) {
        MQ_RUN(Marquee, MQ_A, MQ_STEP);
        if (B.s) MQ_RUN(Marquee, MQ_B, MQ_STEP);
        return;
    }
    /* the second line is set up in MQ_A's place and traded into MQ_B */
    if (LR_GEO == 2) {
        swap();
        A.attr = MQ_POPUP | 3;              /* ink on paper */
    } else {
        B.s = 0;
        A.attr = MQ_POPUP | (3 << 2);       /* paper on ink, the band */
    }
    A.s = s;
    A.x0 = 8;
    A.x1 = 151;
    if (hUiMode) { A.x0 = 12; A.x1 = 156; }
    A.y = (u8)(row8[LR_GEO] << 3);
    MQ_RUN(Marquee, MQ_A, MQ_START);
    if (LR_GEO == 2) swap();
}

/* Trade MQ_A and MQ_B, which follow each other. */
static void swap(void) {
    u8 *a = (u8 *)MQ_A;
    u8 n, t;

    for (n = sizeof(Mq); n; n--, a++) {
        t = *a; *a = a[sizeof(Mq)]; a[sizeof(Mq)] = t;
    }
}
