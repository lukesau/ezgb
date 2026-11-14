/* CGB-mode initialization, run at boot in place of the stock LCD-on.
 *
 * Hooked over `ld a,$c0 / ldh [rLCDC],a` at 00:01ba (KernelEntry), so it runs
 * with the LCD still off, the only safe window for a bulk VRAM write, and
 * performs the LCD-on itself at the end.
 *
 * Why this is needed at all: setting the ROM header's CGB flag ($0143 = $80)
 * makes a Game Boy Color run the kernel in CGB mode, where `BGP`/`OBP` are
 * ignored and color comes from CGB palette RAM instead. The kernel writes
 * BGP exactly once (`ld a,$e4` at 00:01b0, the identity mapping, so color
 * index N is simply shade N) and never touches it again, so replicating the
 * existing look is a direct 4-color translation with no runtime palette
 * effects to preserve.
 *
 * The other half is the BG attribute map. In CGB mode every tilemap byte has a
 * companion attribute byte in VRAM bank 1 selecting palette, tile bank and
 * flips, and KernelEntry clears WRAM, OAM and HRAM but *never VRAM*
 * (bank_000.asm:337-363). Left alone, those attributes are whatever the boot
 * ROM happened to leave, which shows up as random per-tile palettes and
 * mirroring. Zeroing bank 1 gives every tile attribute 0: palette 0, tile
 * bank 0, no flip.
 *
 * Runs on DMG hardware too, so everything CGB-specific is behind a runtime
 * feature test rather than a build-time assumption.
 *
 * When does the kernel actually run in CGB mode? Only when the console's boot
 * ROM saw a CGB flag. On the cart it reads the factory bootstrap's header,
 * not ezgb.dat's (docs/cgb-mode.md), so in practice this is for emulators
 * that run ezgb.dat directly. Everywhere else the feature test fails and
 * this is just the stock LCD-on.
 */

#define rLCDC (*(volatile unsigned char *)0xff40)
#define rVBK  (*(volatile unsigned char *)0xff4f)

#define LCDC_ON 0xc0 /* the value the stock boot wrote (bank_000.asm:401) */

/* 02:43d0, theme.c: the palettes, DMG and CGB, in the theme of the pSRAM
 * mark (docs/dark-mode.md). A literal address, not a pin: the port map
 * would read a bank-0 pin above $4000 as bank-1 code, and injected
 * addresses are the same in every kernel. */
#define THEME_FN ((void (*)(void))0x43d0)
#define rROMB (*(volatile unsigned char *)0x2000)

void cgb_init_and_lcd_on(void) {
    /* Feature-test VBK rather than trusting the saved boot A at $d6c9: on CGB
     * hardware A is $11 even when the console is running in DMG compatibility
     * mode, where the CGB registers are locked out and this whole block must
     * be skipped. A DMG reads $ff4f back as $ff, but a CGB in DMG
     * compatibility mode reads back what was written (docs/cgb-mode.md), so
     * this also clears bank 1 there, which is harmless: compat mode never
     * shows it. Theme (theme.c) does not rely on this test. */
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
    }

    /* BGP/OBP on every console, and on a CGB all 8 BG and 8 OBJ palettes,
     * so a stray non-zero attribute byte still renders in the theme rather
     * than in garbage colors */
    /* KernelEntry has bank 1 mapped (wRomBank). Interrupts are still off
     * (IE is 0), so map bank 2 by hand rather than through
     * FarCallTrampoline, whose EiNest would turn them on early. */
    rROMB = 2;
    THEME_FN();
    rROMB = 1;

    rLCDC = LCDC_ON;
}
