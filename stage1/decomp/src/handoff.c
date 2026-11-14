/* Stock stage1 bank 1: handing the load command to the FPGA and entering
 * the kernel. 01:40AE-01:4133, the same on FW4 and FW5-0918; HandoffPoll at
 * 01:4000 is in handoff_poll.c. */
#pragma bank 1

#include "hw.h"
#include "handoff.h"

/* 01:40AE: byte copy, n at most 255. Unused. */
void RomLoad_Build(UBYTE *dst, const UBYTE *src, UBYTE n)
{
    while (n--)
        *dst++ = *src++;
}

/* 01:40EA */
void HandoffRun(void)
{
    set_data((void *)HANDOFF_WRAM, HandoffPollRom, HANDOFF_SIZE);
    ((void (*)(void))HANDOFF_WRAM)();
}

/* 01:40FF: main() calls this through banked_call */
void LoadKernel(UBYTE *cmd) BANKED
{
    FPGA_UNLOCK();
    FPGA_LOAD_MAP = 1;
    FPGA_COMMIT();
    set_data((void *)WINDOW, cmd, LOADCMD_SIZE);
    HandoffRun();
}
