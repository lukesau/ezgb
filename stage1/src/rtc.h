#ifndef RTC_H
#define RTC_H

#include <stdint.h>

/* MBC3 clock fields as the kernel keeps them: S, M, H, DL, DH */
#define RTC_FIELDS 5

/* The kernel's clock seconds from the cart's PCF8563 (RtcToDayCount,
 * 01:4ec9): local date/time as seconds since 1970, minus 8 hours. */
int32_t rtc_now(void);

/* The game clock now: saved fields advanced by now - stamp
 * (RtcWriteTimeFromDayDelta, 01:505c, with the mod's negative clamp).
 * stamp 0 zeroes the clock. f is updated in place. */
void rtc_advance(uint8_t *f, int32_t stamp, int32_t now);

/* Give the game its clock: FPGA clock window ($7FC0=6, $A018-$A01C), the
 * kernel's copy at page $11 $A220-$A224, the clock flag $A202=$77 and the
 * launch stamp $A210-$A213, as the kernel's launch leaves them. */
void rtc_apply(const uint8_t *f, int32_t now);

#endif
