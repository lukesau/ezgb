/* Call_000_069f @ 1.05e $069f.
 * If LCD is on (LCDC bit 7), wait until LY is in a safe window then clear
 * that bit. Early-out when LCD already off via the add-a / ret-nc idiom. */

#define rLCDC (*(volatile unsigned char *)0xff40)
#define rLY   (*(volatile unsigned char *)0xff44)

void lcd_off(void) {
    if ((signed char)rLCDC >= 0) {
        return;
    }
    while (rLY >= 0x92)
        ;
    while (rLY < 0x91)
        ;
    rLCDC &= 0x7f;
}
