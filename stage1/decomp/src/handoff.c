/* Stock stage1 bank 1: handing the load command to the FPGA and entering
 * the kernel. 01:4000-01:4133, the same on FW4 and FW5-0918. */
#pragma bank 1

#include "hw.h"
#include "handoff.h"

/* 01:4000: runs from WRAM at $D100 (HandoffRun() copies it), since cart
 * space switches to the kernel under it. Stock was linked for $D100: its
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

/* 01:40AE: byte copy, n at most 255. Unused. */
void RomLoad_Build(UBYTE *dst, const UBYTE *src, UBYTE n)
{
    while (n--)
        *dst++ = *src++;
}

/* 01:40EA */
void HandoffRun(void)
{
    set_data((void *)HANDOFF_WRAM, (void *)HandoffPoll, HANDOFF_SIZE);
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
