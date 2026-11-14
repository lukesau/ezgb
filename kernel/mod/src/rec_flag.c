/* The SET tab's pSRAM checkboxes, SGB BOOT (docs/sgb-boot.md) and SORT BY
 * PLAYS (docs/stars.md): records in battery-backed page $11, 'S', a tag,
 * flag, ~flag, on only when all four bytes say so.
 *
 *   $A400  'S', 'G'  SGB BOOT (kernel/mod/asm/sgb_boot.asm reads it)
 *   $A404  'S', 'O'  SORT BY PLAYS (play.c reads it in the sort)
 *
 * Bank 4, injected at 04:7f51, near-called by SetPage (setpage.c), which
 * had no room for a second copy. RecFlag(r, tag, 0) reads the record,
 * RecFlag(r, tag, 1) toggles it; both return the setting. Mapped the way
 * the kernel maps page $11 for its AUTO SAVE flag (04:58d6): page latch,
 * $7FC0 = $03, access, then both back to 0, where the SET screen rests.
 *
 *   python3 tools/inject.py src/rec_flag.c $V 4 7f51 RecFlag \
 *       --pin SetFpgaPage_B4=466e --apply
 */

#include "types.h"

extern void SetFpgaPage_B4(u8 page);                                /* 04:466e: $7FC0 = page */

#define RAM_PAGE (*(volatile u8 *)0x4000)

u8 RecFlag(volatile u8 *r, u8 tag, u8 toggle) {
    u8 on;

    RAM_PAGE = 0x11;
    SetFpgaPage_B4(3);
    on = r[0] == 'S' && r[1] == tag && r[2] == 1 && r[3] == 0xFE;
    if (toggle) {
        on = !on;
        r[0] = 'S';
        r[1] = tag;
        r[2] = on;
        r[3] = ~on;
    }
    RAM_PAGE = 0;
    SetFpgaPage_B4(0);
    return on;
}
