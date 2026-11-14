/* Wrong-patch guard: stop at boot when this kernel's patch was made for
 * another stock build.
 *
 * Bank 1, injected at 01:7d70. Far target of FarCallPatchGuard (02:43c0),
 * which ezcfg's boot op (cfg_restore) calls first, before the BACKUPSAVE
 * check, the RTC prompt and fast launch: before anything that writes the
 * card or pSRAM.
 *
 * An IPS patcher writes the patch's bytes over whatever file it is given.
 * 1.05e-0731 and 1.05e-0918 differ only in bank 1, where 0918 sits $262
 * bytes later from 01:4c5e on, so one of them patched with the other's patch
 * boots to a normal browser while its bank-1 hooks land inside the stock
 * BackupSaveDump write loop: the first save backup would corrupt the .sav.
 * (A 1.05e patch on 1.04e, or the reverse, halts on an illegal opcode before
 * reaching here, also without writing anything.)
 *
 * The check: BuildSaverBackupPath opens with the same 8 bytes in all three
 * stock builds, at a different bank-1 address in each, and the mod changes
 * none of them. port-mod.py pins GuardSig to that label per build (and its
 * verify_target proves the bytes are there), so a correctly patched kernel
 * always finds them. A cross-patched one carries the other build's address
 * and finds other code there.
 */

#include "types.h"
#include "draw.h"

extern const u8 GuardSig[];                                 /* BuildSaverBackupPath, 01:5736 in 0731 */

void patch_guard(void) {
    static const u8 sig[8] = {0xe8, 0xf2, 0x3e, 0x01, 0xf8, 0x14, 0x96, 0x3e};
    static const char *const msg[] = {
        "WRONG PATCH",
        "",
        "This ezgb.dat was",
        "patched with the",
        "patch for another",
        "kernel build.",
        "",
        "Copy the stock",
        "ezgb.dat back and",
        "use its own patch.",
    };
    u8 i, n;

    for (i = 0; i < 8; i++)
        if (GuardSig[i] != sig[i]) break;
    if (i == 8) return;

    StoreDrawParams(0, 0, 0);
    DrawRect(0, 16, 159, 127, 1);
    StoreDrawParams(3, 0, 0);
    for (i = 0; i < sizeof msg / sizeof msg[0]; i++) {
        for (n = 0; msg[i][n]; n++) {}
        if (n) DrawString((const u8 *)msg[i], n, 1, (u8)(3 + i));
    }
    for (;;) WaitVBlankFlag();          /* nothing else runs: no save prompt, no dump */
}
