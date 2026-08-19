/* CGB-mode initialisation, run at boot in place of the stock LCD-on.
 *
 * Hooked over `ld a,$c0 / ldh [rLCDC],a` at 00:01ba (KernelEntry), so it runs
 * with the LCD still off — the only safe window for a bulk VRAM write — and
 * performs the LCD-on itself at the end.
 *
 * Why this is needed at all: setting the ROM header's CGB flag ($0143 = $80)
 * makes a Game Boy Color run the kernel in CGB mode, where `BGP`/`OBP` are
 * ignored and colour comes from CGB palette RAM instead. The kernel writes
 * BGP exactly once (`ld a,$e4` at 00:01b0 — the identity mapping, so colour
 * index N is simply shade N) and never touches it again, so replicating the
 * existing look is a direct 4-colour translation with no runtime palette
 * effects to preserve.
 *
 * The other half is the BG attribute map. In CGB mode every tilemap byte has a
 * companion attribute byte in VRAM bank 1 selecting palette, tile bank and
 * flips — and KernelEntry clears WRAM, OAM and HRAM but *never VRAM*
 * (bank_000.asm:337-363). Left alone, those attributes are whatever the boot
 * ROM happened to leave, which shows up as random per-tile palettes and
 * mirroring. Zeroing bank 1 gives every tile attribute 0: palette 0, tile
 * bank 0, no flip.
 *
 * Runs on DMG hardware too, so everything CGB-specific is behind a runtime
 * feature test rather than a build-time assumption.
 */

#define rLCDC (*(volatile unsigned char *)0xff40)
#define rVBK  (*(volatile unsigned char *)0xff4f)
#define rBCPS (*(volatile unsigned char *)0xff68)
#define rBCPD (*(volatile unsigned char *)0xff69)
#define rOCPS (*(volatile unsigned char *)0xff6a)
#define rOCPD (*(volatile unsigned char *)0xff6b)

#define LCDC_ON 0xc0 /* the value the stock boot wrote (bank_000.asm:401) */

/* Defined below, not here: SDCC emits functions in definition order, and
 * inject.py extracts one contiguous run starting at the link origin — so the
 * entry point the hook jumps to has to be the first function in the file. */
static void write_shade_ramp(volatile unsigned char *port);

void cgb_init_and_lcd_on(void) {
    unsigned char i;

    /* MBC cart-RAM enable ($0A to $0000-$1FFF, the standard MBC1/MBC5 gate).
     *
     * Only meaningful when this image was launched *as a game*: the loader
     * reads the launched ROM's $0147/$0149 and has the FPGA emulate that MBC
     * (bank_001.asm:6188+, feeding $7F37), and an emulated MBC keeps
     * $A000-$BFFF disabled until this write. Both the SD data window and the
     * PSRAM meta pages live at $A000, which is why a chain-booted kernel fails
     * SD init *and* the battery check from one cause.
     *
     * Booted normally, the FPGA is not emulating an MBC and this is an
     * ordinary ignored write to ROM space. */
    *(volatile unsigned char *)0x0000 = 0x0a;

    /* Feature-test VBK rather than trusting the saved boot A at $d6c9: on CGB
     * hardware A is $11 even when the console is running in DMG compatibility
     * mode, where the CGB registers are locked out and this whole block must
     * be skipped. A writable VBK is the thing that actually distinguishes
     * "really in CGB mode" — in DMG mode $ff4f reads back $ff, so bit 0 can
     * never be observed as 0. Writes to it there are harmless no-ops. */
    rVBK = 0;
    if ((rVBK & 1) == 0) {
        unsigned char *v;

        /* Zero all of VRAM bank 1: attribute map and bank-1 tile data alike.
         * Safe only because the LCD is still off at this point. */
        rVBK = 1;
        for (v = (unsigned char *)0x8000; v != (unsigned char *)0xa000; v++) {
            *v = 0;
        }
        rVBK = 0;

        /* All 8 BG and 8 OBJ palettes get the same ramp, so a stray non-zero
         * attribute byte still renders correctly rather than in garbage
         * colours. $80 = index 0 with auto-increment. */
        rBCPS = 0x80;
        rOCPS = 0x80;
        for (i = 0; i < 8; i++) {
            write_shade_ramp(&rBCPD);
            write_shade_ramp(&rOCPD);
        }
    }

    rLCDC = LCDC_ON;
}

/* BGR555, matching the DMG shade ramp BGP=$E4 selects: 0 lightest .. 3 black.
 * Written as literal byte pairs rather than a const array on purpose —
 * inject.py cannot place initialised statics (they land in _DATA, which has no
 * crt0 to copy it at boot), so the data has to live in the instruction
 * stream. */
static void write_shade_ramp(volatile unsigned char *port) {
    /* DIAGNOSTIC PALETTE — shade 0 is deliberately bright red, not white.
     *
     * The point of this build is to answer one question on real hardware: does
     * the console's boot ROM ever read ezgb.dat's header, or does the factory
     * bootstrap's header decide the mode? A faithful greyscale ramp cannot
     * answer it — it looks near-identical to the DMG palette the boot ROM
     * applies when the CGB flag is ignored, so both outcomes render the same.
     *
     * Shade 0 is the UI background, so in CGB mode the whole screen goes red;
     * shade 3 stays black, keeping text readable. Unmistakable either way.
     *
     * Restore the real ramp once the question is settled:
     *   0xff,0x7f  $7fff white      0xb5,0x56  $56b5 light grey
     *   0x4a,0x29  $294a dark grey  0x00,0x00  $0000 black          */
    *port = 0x1f; *port = 0x00; /* $001f BRIGHT RED (BGR555: r=31) */
    *port = 0xb5; *port = 0x56; /* $56b5 light grey                */
    *port = 0x4a; *port = 0x29; /* $294a dark grey                 */
    *port = 0x00; *port = 0x00; /* $0000 black                     */
}
