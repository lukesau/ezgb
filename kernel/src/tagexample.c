/* The SET tab's tag example (docs/browser-tags.md): page 2, row 8, under
 * SHOW NAME TAGS:, a file name the way the browser will draw it.
 *
 *   ticked     Game Title (USA) (Rev 1) [!].gb
 *   unticked   Game Title.gb
 *
 * The name takes the whole row, in the shared marquee (marquee.c,
 * MQ_A), which scrolls it when it does not fit; flcfg.c's op TICK steps
 * it. The marquee runs in bank 2, so the name is copied to FL_DISP first.
 *
 * Bank 4, injected at 04:7e60, near-called by SetPage (setpage.c, ops 0
 * and 3).
 *
 *   python3 tools/inject.py src/tagexample.c $V 4 7e60 TagExample \
 *       --pin FarCallMarquee=0410 --replace --apply
 */

#include "types.h"
#include "draw.h"
#include "vars.h"
#include "marquee.h"

#define FL_DISP ((u8 *)0xDB10)              /* the SET tab's marquee text (flcfg.c) */

void TagExample(void) {
    static const u8 tagged[32] = {'G','a','m','e',' ','T','i','t','l','e',' ','(','U','S','A',')',' ',
                                  '(','R','e','v',' ','1',')',' ','[','!',']','.','g','b',0};
    static const u8 plain[14] = {'G','a','m','e',' ','T','i','t','l','e','.','g','b',0};
    const u8 *src = TAGS_HIDE ? plain : tagged;
    u8 i;

    for (i = 0; (FL_DISP[i] = src[i]) != 0; i++) {}
    MQ_A->s = FL_DISP;
    MQ_A->x0 = 0;
    MQ_A->x1 = 159;
    MQ_A->y = 8 * 8;
    MQ_A->attr = 3;
    MQ_RUN(FarCallMarquee, MQ_A, MQ_START);
}
