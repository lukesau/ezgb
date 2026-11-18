/* joypad() for a box with a name in it: a step of the name's marquee
 * (LastRomName(0), lastrom_name.c), then the pad. The START overlay, the
 * BACKUPSAVE prompt, the ROM menu and the save manager poll through it. */

#pragma codeseg MOD0A	/* a free run of bank 0's header (tools/build.py places it) */

#include "types.h"

extern void LastRomName(const u8 *s) __banked;
extern u8 ReadJoypad(void);

u8 LastRomTickStub(void) {
    LastRomName(0);
    return ReadJoypad();
}
