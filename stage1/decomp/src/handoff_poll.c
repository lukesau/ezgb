/* Stock stage1 01:4000, the same on FW4 and FW5-0918.
 *
 * Linked to run at $D100 and stored at 01:4000: area _HANDOFF, which the link
 * places at $D100 and tools/link.py moves to $4000 (HandoffPollRom). */
#pragma codeseg HANDOFF

#include "hw.h"
#include "handoff.h"

/* 01:4000: runs from WRAM at $D100 (HandoffRun() copies it), since cart
 * space switches to the kernel under it. Stock was linked for $D100 too: its
 * jumps go to $D1xx.
 *
 * Starts the load, waits for the window to leave 0 (it floats for a moment
 * after $7F36 = 3, ../../stage0/docs/design.md) and then for it to leave 1,
 * then switches to kernel mode and calls the kernel. */
void HandoffPoll(void)
{
    volatile UBYTE *status;

    FPGA_UNLOCK();
    FPGA_LOAD_MAP = 3;
    FPGA_COMMIT();

    while (WINDOW[0] == 0)
        ;
    do {
        status = WINDOW;
    } while (*status == 1);

    FPGA_UNLOCK();
    FPGA_LOAD_MAP = 0;
    FPGA_COMMIT();
    FPGA_UNLOCK();
    FPGA_SRAM_MAP = 0;
    FPGA_COMMIT();
    ROMB0 = 1;
    ROMB1 = 0;
    FPGA_UNLOCK();
    FPGA_7F31 = 0;
    FPGA_MODE = 0x80;
    FPGA_COMMIT();
    ENTRY_0100();
}

