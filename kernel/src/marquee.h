/* Scrolling text, for any caller in any bank (marquee.c, docs/marquee.md).
 *
 * A caller owns an Mq in WRAM, fills in the text and the field for the
 * current UI font, and calls Marquee with MQ_START; from then on MQ_STEP
 * once per pass of its loop keeps it moving, and MQ_DRAW repaints it where
 * it is. Text that fits is drawn once and never redrawn. Text that does not
 * fit holds for MQ_HOLD frames, then steps one character every MQ_RATE
 * frames and repeats after MQ_GAP blanks.
 *
 * Marquee runs in bank 2, so everything it reads, the Mq and the text, must
 * be in RAM, bank 0 or bank 2: a caller in another bank copies ROM text to
 * WRAM first. It takes no stack arguments (the instance and the op are in
 * WRAM, MQ_RUN sets them), so the same call works from bank 2 directly and
 * from any other bank through FarCallMarquee. Include after types.h. */

typedef struct {
    const u8 *s;   /* the text, NUL-terminated */
    u8 len;        /* its length (Marquee sets it) */
    u8 pos;        /* first character shown */
    u8 tick;       /* frames since the last step */
    u8 fr;         /* HFRAME at the last MQ_STEP */
    u8 x0, x1;     /* the field: pixels x0..x1, in the current font's layout */
    u8 y;          /* its top: tile row y / 8 in 8px, a 12px row at y */
    u8 attr;       /* ink | paper << 2 | MQ_POPUP; MQ_SCROLLS is Marquee's */
} Mq;

#define MQ_POPUP   0x80   /* PopupDrawParams, else StoreDrawParams */
#define MQ_SCROLLS 0x40   /* set by MQ_START when the text does not fit */

/* The two instances: the SET tab's name (page 1's fast-launch target or
 * page 2's tag example) and the START overlay's first line share MQ_A,
 * never being on screen together; the BACKUPSAVE prompt's "Played" line is
 * MQ_B. In RTCLOG's old tail ($DBC2-$DBE3 with the work copy and the
 * arguments), which test builds now cap at 7 entries. */
#define MQ_A ((Mq *)0xDBD0)
#define MQ_B ((Mq *)0xDBDA)

#define MQ_ARG (*(Mq * volatile *)0xDBC2)  /* the instance to run */
#define MQ_OPS (*(volatile u8 *)0xDBCE)    /* what to do with it */

#define MQ_START 0     /* measure s, reset, draw */
#define MQ_STEP  1     /* advance if due, redraw when it moved */
#define MQ_DRAW  2     /* redraw where it is */

#define MQ_GAP   3     /* blanks between repeats */
#define MQ_RATE  20    /* frames per step (3 chars/s) */
#define MQ_HOLD  60    /* ...at the start of the text (1 s) */

extern void Marquee(void);              /* 02:7260 */
extern void FarCallMarquee(void);       /* 00:0410 -> 02:7260 */

/* Bank 2: MQ_RUN(Marquee, m, op); elsewhere MQ_RUN(FarCallMarquee, m, op). */
#define MQ_RUN(fn, m, op) do { MQ_ARG = (m); MQ_OPS = (op); fn(); } while (0)
