/* FPGA interface survey, run from a ROM launched in the game slot.
 *
 * The goal here is no longer "make chain-boot work" — it is to map which FPGA
 * registers respond at all when the cart is emulating a game, and how. A
 * command that kills the console is a result, not a failure, so long as the
 * screen shows how far we got.
 *
 * ---------------------------------------------------------------------------
 * Established by v1-v7 (see docs/game-slot-access.md):
 *
 *   - $46 readings are open bus, not data: the read compiles to `ld b,(hl)`,
 *     which IS opcode $46, so a floating bus hands back the last byte driven.
 *   - $A000 is live and writable, but only after the MBC cart-RAM enable
 *     ($0A -> $0000-$1FFF). That is emulated save RAM, not the EZ window.
 *   - $7FC0, $4000 and the unlock triple are all INERT from the game slot.
 *   - $7F36 = $03 is the ONE write the FPGA visibly reacts to: issued from
 *     ROM it kills the console instantly, because it opens the ROM-load
 *     command window — i.e. it remaps the cart out from under the PC.
 *   - The kernel never drives these registers from ROM either.
 *     RomLoad_BuildAndRun7FD2Wait_B8 (bank_008.asm:2534) copies its FPGA
 *     routine to $D000 and calls it there, wrapped in DiNest/EiNest.
 *
 * v7 copied to $D000 like the kernel does, and corrupted the display. $D000 is
 * NOT free: wWToUpperKeys spans $CC33-$D00E and wWToUpperVals starts at $D00F,
 * so the copy landed on live FatFs case-folding tables. The kernel gets away
 * with $D000 only because it does that at ROM-launch, when it is about to reset
 * and nothing else matters.
 *
 * v8 uses HRAM instead: $FF80-$FF89 is the OAM DMA stub, $FF8A-$FFFE is
 * untouched by the kernel. 79-byte routine at $FF8A, results at $FFF0-$FFF4,
 * clear of $FFFF (IE).
 * ---------------------------------------------------------------------------
 *
 * The HRAM routine is parameterised, so one build surveys many registers:
 *
 *   in   $FFF0  port low byte (the port is $7F00 | this)
 *        $FFF1  value to write
 *        $FFF4  value to write on the way back out (restore)
 *        $FFF5  page latched into $4000 after the command — the step v10 was
 *               missing. The kernel always does personality THEN page; without
 *               it we sampled whatever page happened to be selected, which is
 *               why every OS-mode read came back $FF.
 *   out  $FFF2  $A000 sampled while the command is active
 *        $FFF3  read-back after writing $5A to $A000
 *
 * It disables interrupts, issues unlock/command/commit, samples, then issues
 * unlock/restore/commit so ROM is mapped again BEFORE it returns. Each line
 * prints immediately, so a fatal command still leaves everything before it on
 * screen.
 *
 * Output: `Pnn A=xx W=yy` — port, $A000 read, $5A write-back.
 *   46      open bus; nothing responded (game slot)
 *   A/B     in OS mode these are real reads of the selected page
 *   11/22   sentinels survived: the routine never reached its stores
 *   W = 5A  that window is live and writable
 */

extern void DrawString(const unsigned char *s, unsigned char len,
                       unsigned char col, unsigned char row);
extern void StoreDrawParams(unsigned char a, unsigned char b, unsigned char c);
/* The 79-byte routine, once copied to $FF8A. Pinned; never called in ROM. */
extern void hram_fpga_probe(void);

static void probe_body(unsigned char tag);

/* One entry point per candidate stopping point, each tagged, so the output
 * says which one the hardware actually reached:
 *   N  $0f8d  FileBrowserEntry — the normal, non-error boot path. This is the
 *             one that fires when the probe IS ezgb.dat and everything works.
 *   B  $18e2  BatteryCheck_waitA back-edge — reached by construction
 *   S  $0e21  SdMenuMain_initErrorHang
 *   F  $0998  SdReadRetryCount_errorHang
 */
void probe_from_boot(void)    { probe_body('N'); }   /* N = normal boot path */
void probe_from_battery(void) { probe_body('B'); }
void probe_from_sderr(void)   { probe_body('S'); }
void probe_from_fserr(void)   { probe_body('F'); }

#define POKE(a, v) (*(volatile unsigned char *)(a) = (unsigned char)(v))
#define PEEK(a)    (*(volatile unsigned char *)(a))

#define HRAM_CODE 0xff8a
#define BLOB_SRC  0x3d8c
#define BLOB_LEN  84

static unsigned char hexd(unsigned char n) {
    n &= 0x0f;
    return (n < 10) ? (unsigned char)(n + '0') : (unsigned char)(n - 10 + 'A');
}

/* "pp:gg A=xx B=yy" — port low byte, page, $A000, $A201. */
static void show2(unsigned char port, unsigned char page, unsigned char a,
                  unsigned char b, unsigned char row) {
    unsigned char line[16];
    line[0]  = hexd((unsigned char)(port >> 4));
    line[1]  = hexd(port);
    line[2]  = ':';
    line[3]  = hexd((unsigned char)(page >> 4));
    line[4]  = hexd(page);
    line[5]  = ' ';
    line[6]  = 'A';
    line[7]  = '=';
    line[8]  = hexd((unsigned char)(a >> 4));
    line[9]  = hexd(a);
    line[10] = ' ';
    line[11] = 'B';
    line[12] = '=';
    line[13] = hexd((unsigned char)(b >> 4));
    line[14] = hexd(b);
    line[15] = 0;
    StoreDrawParams(0x03, 0x00, 0x00);
    DrawString(line, 15, 0, row);
}

static void survey(unsigned char port, unsigned char val, unsigned char page,
                   unsigned char restore, unsigned char row) {
    POKE(0xfff0, port);
    POKE(0xfff1, val);
    POKE(0xfff4, restore);
    POKE(0xfff5, page);
    POKE(0xfff2, 0x11);
    POKE(0xfff3, 0x22);
    /* Read-only: the routine samples $A000 and $A201 and writes nothing to the
     * cart window. As ezgb.dat that window is LIVE and page $11 holds the
     * BACKUPSAVE stamp and last-ROM path, so a blind write could corrupt
     * saves. Reads cannot. */
    hram_fpga_probe();
    show2(port, page, PEEK(0xfff2), PEEK(0xfff3), row);
}

static void probe_body(unsigned char tag) {
    unsigned char line[6];
    unsigned char n;

    line[0] = tag; line[1] = '8'; line[2] = ' ';
    line[3] = 'G'; line[4] = 'O'; line[5] = 0;
    StoreDrawParams(0x03, 0x00, 0x00);
    DrawString(line, 5, 0, 10);

    for (n = 0; n < BLOB_LEN; n++) {
        ((unsigned char *)HRAM_CODE)[n] = ((const unsigned char *)BLOB_SRC)[n];
    }

    /* ORDER MATTERS, and v9 got it wrong: $7F36 went first and poisoned every
     * line after it. $7F36 = $03 opens the ROM-load command window, and
     * writing $00 back does NOT undo its side effects — after it, glyph
     * rendering is garbage even in OS mode, from HRAM, with interrupts off.
     * The kernel only ever uses it inside the ROM-load path, which ends in a
     * console reset, so it may never need a clean restore and one may not
     * exist. It therefore goes LAST, after everything readable is on screen.
     *
     * $7FC0 personalities: $03 = cart SRAM (FRAM / file list), $00 = the one
     * the kernel sets around FatFs calls. */
    /* Cart-SRAM personality with a real page latched. Page $11 is the meta
     * page: BatteryCheck expects $A201 == $88 there (docs/fram-save-map.md),
     * so this row is the method's own validation — if it does not read $88 in
     * OS mode, the sequence is still wrong. */
    survey(0xc0, 0x03, 0x11, 0x00, 11);
    survey(0xc0, 0x03, 0x12, 0x00, 12);   /* file-list scratch page */
    survey(0xc0, 0x00, 0x00, 0x00, 13);   /* FatFs/SD personality */
    survey(0xd2, 0x01, 0x11, 0x00, 14);   /* updater's trigger */

    /* $7F36 last: it corrupted rendering in v9 and was harmless in v10, cause
     * unknown, so keep it behind everything readable. Its own row is 17, clear
     * of the DONE marker which collided with it last time. */
    StoreDrawParams(0x03, 0x00, 0x00);
    DrawString((const unsigned char *)"--LAST--", 8, 0, 15);
    DrawString((const unsigned char *)"DONE", 4, 0, 16);
    survey(0x36, 0x03, 0x11, 0x00, 17);

    for (;;) {
    }
}
