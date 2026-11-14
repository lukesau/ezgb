/* EZ Flash Jr cart registers as stock stage1 writes them. */
#ifndef HW_H
#define HW_H

#include "gb.h"

#define REG(a) (*(volatile UBYTE *)(a))

#define rNR52 REG(0xFF26)

/* MBC-style ROM bank select */
#define ROMB0 REG(0x2000)
#define ROMB1 REG(0x3000)

/* Every FPGA register write is inside unlock and commit: $7F00=$E1,
 * $7F10=$E2, $7F20=$E3, the register, then $7FF0=$E4
 * (../../stage0/docs/design.md#unlock-and-commit). Stock writes the whole
 * envelope inline each time. */
#define FPGA_UNLOCK() do { REG(0x7F00) = 0xE1; REG(0x7F10) = 0xE2; REG(0x7F20) = 0xE3; } while (0)
#define FPGA_COMMIT() (REG(0x7FF0) = 0xE4)

#define FPGA_SD_MAP   REG(0x7F30)  /* 0 off, 1 sector data at $A000, 3 request + status */
#define FPGA_7F31     REG(0x7F31)  /* written 0 with every mode change */
#define FPGA_MODE     REG(0x7F32)  /* bit 7 set, bit 3 clear ($80): kernel mode (../../stage0/docs/design.md#modes) */
#define FPGA_LOAD_MAP REG(0x7F36)  /* 0 off, 1 load command window, 3 load + status */
#define FPGA_SD_LBA   0x7FB0       /* $7FB0-$7FB3 sector, little end first, $7FB4 count */
#define FPGA_SD_COUNT REG(0x7FB4)
#define FPGA_SRAM_MAP REG(0x7FC0)  /* what $A000 shows: 0 or 2 here */
#define FPGA_BOOT_CPU REG(0x7FD3)  /* FW5: half of the fast-load key (../../stage0/docs/firmware-diff.md) */

#define WINDOW ((volatile UBYTE *)0xA000)

/* main() builds the load command here, LoadKernel() copies it to $A000 */
#define LOADCMD ((UBYTE *)0xC0A0)
#define LOADCMD_SIZE 0x200

/* where HandoffRun() runs HandoffPoll() from */
#define HANDOFF_WRAM 0xD100
#define HANDOFF_SIZE 0x150

/* the kernel's (and any cart's) entry */
#define ENTRY_0100() (((void (*)(void))0x0100)())

#endif
