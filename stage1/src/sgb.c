/* Super Game Boy unlock. The Jr's FPGA drives the cart /RESET line high
 * through 330 ohms, harder than the SGB's 10k can pull it low, so the SNES
 * can't hold the Game Boy CPU in reset while it starts up. The boot ROM sends
 * the six header packets before the SNES listens, and the SGB stays dark.
 * Stage1 sends them again, as nitro2k01's SGB Enabler and the kernel's SGB
 * BOOT option do (scripts/sgb/sgb_boot.asm), but only on an SGB: the boot
 * ROM's last register values tell the models apart, so no other console
 * waits. */
#include "hw.h"
#include "video.h"
#include "sgb.h"

#define HDR_START 0x0104
#define HDR_END   0x0150                /* packet bytes from here on are 0 */

static uint8_t packet[16];

/* SGB and SGB2 boot ROMs leave C = $14, DMG and Pocket $13; a color
 * console (A = $11) can't be one */
uint8_t sgb_detect(void)
{
    return BOOT_C == 0x14 && BOOT_A != 0x11;
}

/* reset pulse, 128 bits LSB first (P15 low = 1, P14 low = 0), stop bit 0,
 * then 4 frames for the SGB */
static void send_packet(void)
{
    uint8_t i, j, b;

    rP1 = 0x00;
    rP1 = 0x30;
    for (i = 0; i < 16; i++) {
        b = packet[i];
        for (j = 0; j < 8; j++) {
            rP1 = b & 1 ? 0x10 : 0x20;
            rP1 = 0x30;
            b >>= 1;
        }
    }
    rP1 = 0x20;
    rP1 = 0x30;
    wait_frames(4);
}

/* the six header packets, $F1 ... $FB: [cmd][sum of the 14 data bytes]
 * [14 bytes of stage1's own header] */
static void send_header(void)
{
    const uint8_t *src = (const uint8_t *)HDR_START;
    uint8_t cmd, i, sum;

    for (cmd = 0xF1; cmd != 0xFD; cmd += 2) {
        packet[0] = cmd;
        for (sum = 0, i = 2; i < 16; i++, src++) {
            packet[i] = (uint16_t)src < HDR_END ? *src : 0;
            sum += packet[i];
        }
        packet[1] = sum;
        send_packet();
    }
}

/* four rounds with the Enabler's gaps, about 6.7 s; needs the LCD on */
void sgb_unlock(void)
{
    send_header();
    wait_frames(192);
    send_header();
    wait_frames(64);
    send_header();
    wait_frames(48);
    send_header();
}
