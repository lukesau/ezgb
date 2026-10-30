/* SD speed line on the HELP pane (docs/sd-error-recovery.md).
 *
 * Bank 8, injected at 08:7c00. Once the bank-1 PicoBlaze patch has dropped
 * the SD clock to half speed after an SD error, its RTC refresh reports
 * weekday 7 in the RTC window ($7FC0=6, $A00C, kernel mode), a value the
 * PCF8563 never holds (0-6; the FPGA keeps only those three bits). The
 * line is drawn only then; at full speed, and on stock firmware, the pane
 * is unchanged.
 *
 * Called from both HELP panes: Help12 (12px) calls it with big = 1; the 8px
 * DrawHelpModVersion's closing `jp $7141` (08:7af1) goes through
 * HelpSdHook (08:7cc0, after this block), which calls it with big = 0.
 *
 *   python3 tools/inject.py src/help_sd.c $V 8 7c00 HelpSd \
 *       --pin FarCallDrawString12=05c0 --pin DrawString=08b7 --apply
 */

#include "types.h"
#include "draw.h"

#define RTC_WDAY (*(volatile u8 *)0xA00C)

static void fpga_page(u8 page);

/* The entry point stays the first function in the file. */
void HelpSd(u8 big) {
    static const u8 half[14] = {'S','D',' ','S','P','E','E','D',':',' ','H','A','L','F'};
    u8 buf[15];
    u8 t, i;

    fpga_page(6);
    t = RTC_WDAY & 0x07;
    fpga_page(0);                   /* where the stock HELP screen rests */
    if (t != 7) return;
    if (big) {
        /* the 12px renderer runs in bank 2: copy the text to the stack */
        for (i = 0; i < 14; i++) buf[i] = half[i];
        buf[14] = 0;
        FarCallDrawString12(buf, 0, 4, 116);
    } else {
        DrawString(half, 14, 0, 12);
    }
}

/* SetFpgaPage_B4's unlock/commit, inlined (ezcfg.c does the same) */
static void fpga_page(u8 page) {
    *(volatile u8 *)0x7F00 = 0xE1;
    *(volatile u8 *)0x7F10 = 0xE2;
    *(volatile u8 *)0x7F20 = 0xE3;
    *(volatile u8 *)0x7FC0 = page;
    *(volatile u8 *)0x7FF0 = 0xE4;
}
