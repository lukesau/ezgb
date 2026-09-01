/*
 * NorProbeDraw - rom-area read-back probe (NOR-reuse investigation).
 *
 * Drawn once when the START overlay opens (hook over `call ReadJoypad` at
 * 00:1330, one-shot via $DBFD, cleared on FileBrowserEntry). The kernel runs
 * *from* the rom area as a banked ROM: MBC latch $2000 selects which 16KB
 * bank appears at $4000. The kernel image occupies banks 0-9, so banks 10+
 * are whatever sits in the rom area past the kernel - i.e. the tail of the
 * previously launched game, if the store retains it across power-off.
 *
 * Draws four lines "BB:XXXXXXXX" (bank, first 4 bytes at $4000 in hex) at
 * rows $0b-$0e:
 *   bank 09 - control: must equal kernel.gb offset $24000 (proves the probe)
 *   bank 10 - rom area $28000 (just past the kernel: stage1-clobber boundary)
 *   bank 16 - rom area $40000 (past v2's 256KB copy window)
 *   bank 32 - rom area $80000 (deep tail; also catches a 16-bank mask wrap:
 *             if masked, this reads as bank 0 = kernel $0000 bytes)
 *
 * IMPORTANT (learned the hard way): this must be ONE function with no static
 * helpers or const arrays - SDCC emits statics/data ahead of the entry point,
 * but inject.py's label (and the hook's `call`) point at the block start.
 *
 * Interrupts are disabled around the bank flip: the VBlank path may far-call
 * through the trampoline, and the latch shadow at $D6CF must stay coherent
 * with the actual latch while we borrow it.
 */

extern void DrawString(unsigned char *s, unsigned char len, unsigned int pos);

#define LATCH (*(volatile unsigned char *)0x2000)
#define LATCH_SHADOW (*(volatile unsigned char *)0xd6cf)
#define WINDOW ((volatile unsigned char *)0x4000)

void NorProbeDraw(void)
{
    unsigned char buf[12];
    unsigned char raw[4];
    unsigned char line, i, k, bank, v;
    unsigned int pos;

    pos = 0x0b00; /* (row << 8) | col, rows $0b-$0e, col 0 */
    for (line = 0; line < 4; line++) {
        if (line == 0)      bank = 9;
        else if (line == 1) bank = 10;
        else if (line == 2) bank = 16;
        else                bank = 32;

        __critical {
            LATCH = bank;
            for (i = 0; i < 4; i++) {
                raw[i] = WINDOW[i];
            }
            LATCH = LATCH_SHADOW;
        }

        /* "BB:XXXXXXXX" - nibble stream: bank, then the 4 bytes */
        k = 0;
        for (i = 0; i < 10; i++) {
            if (i < 2)  v = bank;
            else        v = raw[(i - 2) >> 1];
            if (!(i & 1)) v >>= 4;
            v &= 0x0f;
            buf[k] = (v < 10) ? ('0' + v) : ('A' + (v - 10));
            k++;
            if (i == 1) {
                buf[k] = ':';
                k++;
            }
        }
        DrawString(buf, 11, pos);
        pos += 0x0100;
    }
}
