/* Name marquee state and timing, shared by the SET tab's ROM name (flcfg.c)
 * and the START overlay's name line (lastrom_name.c). The two never show at
 * once, so they share the WRAM bytes; each resets them when it takes over.
 * A name that does not fit holds for MQ_HOLD frames, then steps one
 * character every MQ_RATE frames and repeats after MQ_GAP blanks. The tick
 * reads HFRAME from vars.h. */

#define MQ_POS   (*(volatile u8 *)0xDB38)   /* first shown char */
#define MQ_TICK  (*(volatile u8 *)0xDB39)   /* frames since the last step */
#define MQ_FR    (*(volatile u8 *)0xDB3B)   /* hFrame at the previous tick */

#define MQ_GAP   3                          /* blanks between repeats */
#define MQ_RATE  20                         /* frames per step (3 chars/s) */
#define MQ_HOLD  60                         /* ...at the start of the name (1 s) */
