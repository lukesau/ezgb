/* The game clock for MBC3 games with a timer, set the way the kernel sets
 * it at launch (1.05e-0918: RtcToDayCount 01:4ec9, RtcWriteTimeFromDayDelta
 * 01:505c, RtcReadDaysClearRegs 01:5346, PreLaunchSaveStamp 01:5824).
 * The cart serves the game base + time since the ROM load, so the base has
 * to be the saved clock moved on by the time the cart was off or in other
 * games. The saved clock is the .sav footer (S/M/H/DL/DH at +0..+16 and the
 * launch stamp at +40) or, when pSRAM already holds this game's save, the
 * kernel's copy on page $11 ($A220-$A224, stamp at $A210). */
#include "rtc.h"
#ifndef RTC_HOST_TEST
#include "hw.h"
#include "fpga.h"
#endif

#ifndef RTC_HOST_TEST
static uint8_t bcd(uint8_t v)
{
    return (v >> 4) * 10 + (v & 15);   /* as the kernel: VL/century bits kept */
}

static uint8_t leap(uint16_t y)
{
    return (y % 4 == 0 && y % 100 != 0) || y % 400 == 0;
}

static const uint8_t mdays[12] = {31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

int32_t rtc_now(void)
{
    uint8_t s, m, h, d, mon, i;
    uint16_t year, y;
    uint32_t days = 0;

    fpga_set(FPGA_SRAM_MAP, 6);
    s = bcd(WINDOW[0x08]);
    m = bcd(WINDOW[0x09]);
    h = bcd(WINDOW[0x0A]);
    d = bcd(WINDOW[0x0B]);
    mon = bcd(WINDOW[0x0D]);
    year = 2000 + bcd(WINDOW[0x0E]);
    fpga_set(FPGA_SRAM_MAP, 0);
    for (y = 1970; y < year; y++)
        days += leap(y) ? 366 : 365;
    for (i = 1; i < mon && i <= 12; i++)
        days += i == 2 && leap(year) ? 29 : mdays[i - 1];
    days += d - 1;
    return (int32_t)(((days * 24 + h) * 60 + m) * 60 + s) - 28800;
}
#endif

void rtc_advance(uint8_t *f, int32_t stamp, int32_t now)
{
    uint8_t s, m, h, dh;
    uint32_t days, diff;

    if (stamp == 0) {
        f[0] = f[1] = f[2] = f[3] = f[4] = 0;
        return;
    }
    diff = now - stamp < 0 ? 0 : (uint32_t)(now - stamp);   /* mod: clamp, not zero */
    s = f[0];
    m = f[1];
    h = f[2];
    days = f[3];                        /* DL only: DH bit 0 isn't folded in */
    dh = f[4];
    if (s > 59 || m > 59 || h > 23) {
        s = m = h = dh = 0;
        days = 0;
    }
    s += diff % 60;
    if (s > 59) { s -= 60; m++; }
    diff /= 60;
    m += diff % 60;
    if (m > 59) { m -= 60; h++; }
    diff /= 60;
    h += diff % 24;
    if (h > 23) { h -= 24; days++; }
    diff /= 24;
    days += diff;
    if (days > 0xFF) {
        dh = (dh & 0xC1) | 0x01;
        if (days > 0x1FF) {
            days &= 0x1FF;
            dh = (dh | 0x80) & 0xC0;
        }
    }
    f[0] = s;
    f[1] = m;
    f[2] = h;
    f[3] = (uint8_t)days;
    f[4] = dh;
}

#ifndef RTC_HOST_TEST
void rtc_apply(const uint8_t *f, int32_t now)
{
    uint8_t i;

    fpga_set(FPGA_SRAM_MAP, 6);
    for (i = 0; i < RTC_FIELDS; i++)
        WINDOW[0x18 + i] = f[i];
    psram_map(PSRAM_META);
    for (i = 0; i < RTC_FIELDS; i++)
        PSRAM[0x220 + i] = f[i];
    PSRAM[0x202] = 0x77;
    PSRAM[0x210] = (uint8_t)now;
    PSRAM[0x211] = (uint8_t)(now >> 8);
    PSRAM[0x212] = (uint8_t)(now >> 16);
    PSRAM[0x213] = (uint8_t)(now >> 24);
    psram_unmap();
}
#endif
