/* Fast launch: a game straight from stage1. Not wired up yet: the kernel's
 * launch contract (FPGA config from the ROM header, save bookkeeping) comes
 * first, so this always defers to the kernel. */
#include "game.h"
#include "video.h"

void game_launch(uint8_t *buf)
{
    (void)buf;
#ifdef FL_DEBUG
    wait_frames(240);                   /* time to read the name */
#endif
}
