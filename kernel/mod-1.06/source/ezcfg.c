/* ============================================================================
   ezcfg.c  -  mod: /EZGB.CFG, the settings file (bank 2)
   ----------------------------------------------------------------------------
   The same file the 0918 mod keeps (docs/ezgb-cfg.md): key=value lines in
   the first sector of /EZGB.CFG, padded with spaces to 512 bytes. This
   kernel knows these keys:

     RTC=2026-11-24 12:35:51   the last good reading of the clock chip
     AUTOSAVE=1                a copy of the SET tab's AUTO SAVE box
     RTCSD=0                   turns the clock backup off
     BOOTROM=1                 every launch resets through the boot ROM
     SGB=1                     SGB BOOT: turns the record in save RAM on (0: off)
                               at the next boot. Written only when the file
                               already has the key
     THEME=1                   the colors: 0 light, 1 dark, 2 red, 3 green,
                               4 purple, 5 blue (docs/themes.md)
     TAGS=1                    full names in the list; 0 or no key cuts them
                               at their tags (CLEAN NAMES)
     UI=12                     the font: 8 (or no key) the 8px console font, 12
                               the proportional 12px one, EZF EZ Flash's
                               6x12 one in the same layout. SLIM, the 0918
                               mod's third, is 12 here and stays SLIM in
                               the file
     FLAUNCH=/Pokemon/Red.gb   the game to start at power-on, off when the
                               value starts with #

   Both live on the coin cell otherwise, and a dead cell loses them. Lines
   with any other key are kept as they are, so a card can go between this
   kernel and the 0918 mod, which has more keys.

   The file is read into SD_buffer and rewritten from it, so nothing here
   may run while SD_buffer holds something else: boot, the SET tab, and a
   launch before the ROM's header is read.
   ========================================================================== */

#include <gb/gb.h>
#include <gb/drawing.h>
#include <string.h>

#include "ezgb_hw.h"
#include "main.h"
#include "ff.h"
#include "Bank_fun.h"
#include "ezcfg.h"
#include "plays.h"

#pragma bank 2

extern UINT8 SD_buffer[0x200];
extern FIL gfil;

#define CFG_SIZE	0x200U

/* what the file had, or has been given since */
UINT8 cfg_dry;				/* main() saw BATTERY DRY on this boot */
static UINT8 cfg_have_rtc;
static UINT8 cfg_have_autosave;
UINT8 cfg_rtcsd;				/* 0: the clock backup is off */
static UINT8 cfg_autosave;
static UINT8 cfg_rtc[6];		/* year (two digits), month, day, hour, minute, second */
UINT8 cfg_bootrom;			/* BOOTROM=1 */
UINT8 cfg_theme;				/* THEME=, as the file has it */
UINT8 cfg_ui;				/* UI=: 0 is 8 or no key, 1 is 12, 2 is SLIM, 3 is EZF */
UINT8 tags_hide;			/* CLEAN NAMES: 0 with TAGS= set to anything but 0 */
UINT8 ui_font;				/* 1: the mod's 12px font (list12.c), 2: EZ Flash's 6x12 in the same layout */
UINT8 ui_font_cfg;			/* what the settings ask for; ui_font is 0 on a screen that is 8px only */
UINT8 list_rows;			/* rows of the file list: 16, or 10 in 12px */
char cfg_flaunch[FLAUNCH_MAX + 1U];	/* FLAUNCH= */
static UINT8 s1_cancel;			/* our stage1 left its "S1" mark: fast launch is not ours to do */

/* SGB BOOT (sgb.s) */
UINT8 sgb_step;
UINT8 sgb_wait;
UINT8 sgb_busy;
UINT8 pad_last;
UINT8 pad_prev;
static UINT8 sgb_on;			/* this boot sends the header packets */
UINT8 cfg_sgb;				/* SGB=: 0 off, 1 on, 2 the file does not say */
void sgb_set1(void);
void sgb_vbl(void);
void sgb_finish(void) __banked;

extern TCHAR currentpath[];
UINT8 browser_lone_rom(void) __banked;	/* browser.c */
extern TCHAR lfname_temp[];

/* for the launch stub (launch.s) */
UINT8 launch_mode;			/* 0 reset, 1 the DMG family jumps, 2 a CGB game jumps */
UINT8 boot_regs[8];			/* F A C B E D L H, what the game gets on a jump */

static char cfg_path[10];
static UINT8 now[6];			/* the chip's reading, same order */
static UINT8 now_flags;			/* NOW_ bits */

#define NOW_BAD		0x01U		/* not a BCD date and time */
#define NOW_LOWV	0x02U		/* the chip's voltage-low flag */

/* ---- the clock chip ---- */

static UINT8 unbcd(UINT8 v)
{
	return (UINT8)((v & 0x0FU) + ((v >> 4) * 10U));
}

static UINT8 bcd(UINT8 v)
{
	return (UINT8)(((v / 10U) << 4) + (v % 10U));
}

static UINT8 is_bcd(UINT8 v)
{
	return (((v & 0x0FU) < 10U) && (v < 0xA0U)) ? 1U : 0U;
}

/* The PCF8563's registers at $A008-$A00E of page 6: seconds, minutes, hours,
   day, weekday, month, year */
static void clock_read(void)
{
	static const UINT8 reg[6] = {0x0EU, 0x0DU, 0x0BU, 0x0AU, 0x09U, 0x08U};
	static const UINT8 mask[6] = {0xFFU, 0x1FU, 0x3FU, 0x3FU, 0x7FU, 0x7FU};
	static const UINT8 top[6] = {99U, 12U, 31U, 23U, 59U, 59U};
	UINT8 i;
	UINT8 v;

	now_flags = 0U;
	hw_set_page(A000Address_RTC);
	if(*((volatile UINT8 *)(Base_RTCbuffer + 8)) & 0x80U) now_flags |= NOW_LOWV;
	for(i = 0U; i < 6U; i++)
	{
		v = *((volatile UINT8 *)(Base_RTCbuffer + reg[i])) & mask[i];
		if(!is_bcd(v)) now_flags |= NOW_BAD;
		v = unbcd(v);
		if(v > top[i]) now_flags |= NOW_BAD;
		now[i] = v;
	}
	if((now[1] == 0U) || (now[2] == 0U)) now_flags |= NOW_BAD;
	hw_set_page(A000Address_TF);
}

/* Weekday as the SET tab writes it: 1 = Sunday */
static UINT8 weekday(UINT8 year2, UINT8 month, UINT8 day)
{
	static const UINT8 t[12] = {0, 3, 2, 5, 0, 3, 5, 1, 4, 6, 2, 4};
	UINT16 y = (UINT16)2000 + year2;
	UINT16 w;

	if(month < 3U) y--;
	w = (UINT16)(y + y / 4U - y / 100U + y / 400U + t[month - 1U] + day);
	return (UINT8)((w % 7U) + 1U);
}

static void clock_write(const UINT8 *t)
{
	hw_set_page(A000Address_RTC);
	*((volatile UINT8 *)(Base_RTCbuffer + 0x8)) = bcd(t[5]);
	*((volatile UINT8 *)(Base_RTCbuffer + 0x9)) = bcd(t[4]);
	*((volatile UINT8 *)(Base_RTCbuffer + 0xA)) = bcd(t[3]);
	*((volatile UINT8 *)(Base_RTCbuffer + 0xB)) = bcd(t[2]);
	*((volatile UINT8 *)(Base_RTCbuffer + 0xC)) = weekday(t[0], t[1], t[2]);
	*((volatile UINT8 *)(Base_RTCbuffer + 0xD)) = bcd(t[1]);
	*((volatile UINT8 *)(Base_RTCbuffer + 0xE)) = bcd(t[0]);
	HW_BEGIN();
	HW_RTC_PAGE = 1;
	HW_END();
	hw_set_page(A000Address_TF);
}

/* 1 when a is later than b */
static UINT8 later(const UINT8 *a, const UINT8 *b)
{
	UINT8 i;

	for(i = 0U; i < 6U; i++)
	{
		if(a[i] != b[i]) return (a[i] > b[i]) ? 1U : 0U;
	}
	return 0U;
}

/* ---- the file ---- */

static UINT8 up(UINT8 c)
{
	if((c >= 'a') && (c <= 'z')) return (UINT8)(c - 0x20U);
	return c;
}

/* 0 when the line at p does not start with key and '=', otherwise the
   length of both. key is upper case. */
static UINT8 key_is(const UINT8 *p, const char *key)
{
	UINT8 n = 0U;

	while(*key)
	{
		if(up(p[n]) != (UINT8)*key) return 0U;
		key++;
		n++;
	}
	if(p[n] != '=') return 0U;
	return (UINT8)(n + 1U);
}

/* 1 when s is t but for case, to the end of both. t is upper case. */
static UINT8 key_tail(const char *s, const char *t)
{
	while(*t)
	{
		if(up((UINT8)*s) != (UINT8)*t) return 0U;
		s++;
		t++;
	}
	return (*s == 0) ? 1U : 0U;
}

/* 0 for a line this kernel does not know, else 1 RTC, 2 AUTOSAVE, 3 RTCSD,
   4 BOOTROM, 5 FLAUNCH, 6 SGB, 7 THEME, 8 UI, 9 TAGS.
   *skip gets the length of the key and '='. */
static UINT8 line_key(const UINT8 *p, UINT8 *skip)
{
	if((*skip = key_is(p, "RTC")) != 0U) return 1U;
	if((*skip = key_is(p, "AUTOSAVE")) != 0U) return 2U;
	if((*skip = key_is(p, "RTCSD")) != 0U) return 3U;
	if((*skip = key_is(p, "BOOTROM")) != 0U) return 4U;
	if((*skip = key_is(p, "FLAUNCH")) != 0U) return 5U;
	if((*skip = key_is(p, "SGB")) != 0U) return 6U;
	if((*skip = key_is(p, "THEME")) != 0U) return 7U;
	if((*skip = key_is(p, "UI")) != 0U) return 8U;
	if((*skip = key_is(p, "TAGS")) != 0U) return 9U;
	return 0U;
}

/* Six numbers split on anything that is not a digit, the last two digits of
   each: 2026-11-24 12:35:51 */
static void parse_rtc(const UINT8 *p, const UINT8 *end)
{
	UINT8 t[6];
	UINT8 i = 0U;
	UINT8 v = 0U;
	UINT8 digits = 0U;
	UINT8 c;

	while(i < 6U)
	{
		c = (p < end) ? *p : (UINT8)'\n';
		if((c >= '0') && (c <= '9'))
		{
			v = (UINT8)((v % 10U) * 10U + (c - '0'));
			digits = 1U;
		}
		else
		{
			if(digits) t[i++] = v;
			v = 0U;
			digits = 0U;
			if((c == '\r') || (c == '\n')) break;
		}
		p++;
	}
	if(i != 6U) return;
	if((t[1] < 1U) || (t[1] > 12U) || (t[2] < 1U) || (t[2] > 31U)) return;
	if((t[3] > 23U) || (t[4] > 59U) || (t[5] > 59U)) return;
	memcpy(cfg_rtc, t, 6U);
	cfg_have_rtc = 1U;
}

/* The file's first sector into SD_buffer, spaces after its end. The first
   line with a key wins. With keep 0 the settings are taken from it; with
   keep 1 they are left alone and the lines this kernel manages are cut
   out, ready for the new ones. Returns the length of what is left. */
static UINT16 file_read(UINT8 keep)
{
	UINT16 got = 0U;
	UINT16 rd = 0U;
	UINT16 wr = 0U;
	UINT16 eol;
	UINT8 seen = 0U;
	UINT8 skip;
	UINT8 k;
	UINT8 c;

	memcpy(cfg_path, "/EZGB.CFG", 10U);
	memset(SD_buffer, ' ', CFG_SIZE);
	hw_set_page(A000Address_TF);
	if(f_open_bank(&gfil, cfg_path, FA_READ) == FR_OK)
	{
		if(f_read_bank(&gfil, SD_buffer, CFG_SIZE, &got) != FR_OK) got = 0U;
		f_close_bank(&gfil);
	}
	if(got > CFG_SIZE) got = CFG_SIZE;

	while(rd < got)
	{
		eol = rd;
		while((eol < got) && (SD_buffer[eol] != '\n')) eol++;
		if(eol < got) eol++;			/* the line with its LF */

		k = line_key(SD_buffer + rd, &skip);
		if(k && !keep && !(seen & (UINT8)(1U << k)))
		{
			seen |= (UINT8)(1U << k);
			c = SD_buffer[rd + skip];
			if(k == 1U) parse_rtc(SD_buffer + rd + skip, SD_buffer + eol);
			else if(k == 2U)
			{
				if((c == '0') || (c == '1'))
				{
					cfg_autosave = (UINT8)(c - '0');
					cfg_have_autosave = 1U;
				}
			}
			else if(k == 3U) cfg_rtcsd = (c == '0') ? 0U : 1U;
			else if(k == 4U) cfg_bootrom = (c == '1') ? 1U : 0U;
			else if(k == 6U) cfg_sgb = (c == '1') ? 1U : 0U;
			else if(k == 7U)
			{
				if((c >= '0') && (c <= '9')) cfg_theme = (UINT8)(c - '0');
			}
			else if(k == 8U)
			{
				if(c == '1') cfg_ui = 1U;
				else if((c == 'S') || (c == 's')) cfg_ui = 2U;
				else if((c == 'E') || (c == 'e')) cfg_ui = 3U;
				else cfg_ui = 0U;
			}
			else if(k == 9U) tags_hide = (c == '0') ? 1U : 0U;
			else
			{
				UINT8 n = 0U;
				const UINT8 *v = SD_buffer + rd + skip;

				while((v < SD_buffer + eol) && (*v != '\r') && (*v != '\n') && (n < FLAUNCH_MAX))
					cfg_flaunch[n++] = (char)*v++;
				while(n && (cfg_flaunch[n - 1U] == ' ')) n--;
				cfg_flaunch[n] = 0;
			}
		}
		if(k && keep)
		{
			rd = eol;				/* cut */
			continue;
		}
		while(rd < eol) SD_buffer[wr++] = SD_buffer[rd++];
	}
	/* spaces and line ends at the tail go: the padding of the last write */
	while(wr && ((SD_buffer[wr - 1U] == ' ') || (SD_buffer[wr - 1U] == '\r') ||
	             (SD_buffer[wr - 1U] == '\n') || (SD_buffer[wr - 1U] == 0U))) wr--;
	if(wr)
	{
		SD_buffer[wr++] = '\r';
		SD_buffer[wr++] = '\n';
	}
	return wr;
}

static UINT8 *put2(UINT8 *p, UINT8 v, UINT8 sep)
{
	*p++ = (UINT8)('0' + v / 10U);
	*p++ = (UINT8)('0' + v % 10U);
	if(sep) *p++ = sep;
	return p;
}

/* Rewrites the file: what it has of other keys, then this kernel's lines */
static void file_write(void)
{
	UINT8 line[FLAUNCH_MAX + 12U];
	UINT8 *p;
	UINT16 at;
	UINT16 n;
	UINT8 k;

	at = file_read(1U);
	for(k = 1U; k <= 9U; k++)
	{
		p = line;
		if(k == 1U)
		{
			if(!cfg_have_rtc) continue;
			memcpy(p, "RTC=20", 6U);
			p += 6;
			p = put2(p, cfg_rtc[0], '-');
			p = put2(p, cfg_rtc[1], '-');
			p = put2(p, cfg_rtc[2], ' ');
			p = put2(p, cfg_rtc[3], ':');
			p = put2(p, cfg_rtc[4], ':');
			p = put2(p, cfg_rtc[5], 0U);
		}
		else if(k == 2U)
		{
			if(!cfg_have_autosave) continue;
			memcpy(p, "AUTOSAVE=", 9U);
			p += 9;
			*p++ = (UINT8)('0' + cfg_autosave);
		}
		else if(k == 3U)
		{
			if(cfg_rtcsd) continue;
			memcpy(p, "RTCSD=0", 7U);
			p += 7;
		}
		else if(k == 4U)
		{
			if(!cfg_bootrom) continue;
			memcpy(p, "BOOTROM=1", 9U);
			p += 9;
		}
		else if(k == 5U)
		{
			if(!cfg_flaunch[0]) continue;
			memcpy(p, "FLAUNCH=", 8U);
			p += 8;
			n = (UINT16)strlen(cfg_flaunch);
			memcpy(p, cfg_flaunch, n);
			p += n;
		}
		else if(k == 6U)
		{
			if(cfg_sgb > 1U) continue;		/* the file never had the key */
			memcpy(p, "SGB=", 4U);
			p += 4;
			*p++ = (UINT8)('0' + cfg_sgb);
		}
		else if(k == 7U)
		{
			if(!cfg_theme) continue;
			memcpy(p, "THEME=", 6U);
			p += 6;
			*p++ = (UINT8)('0' + cfg_theme);
		}
		else if(k == 8U)
		{
			if(!cfg_ui) continue;
			if(cfg_ui == 1U) memcpy(p, "UI=12", 5U);
			else if(cfg_ui == 2U) memcpy(p, "UI=SLIM", 7U);
			else memcpy(p, "UI=EZF", 6U);
			p += (cfg_ui == 1U) ? 5 : ((cfg_ui == 2U) ? 7 : 6);
		}
		else
		{
			if(tags_hide) continue;
			memcpy(p, "TAGS=1", 6U);
			p += 6;
		}
		*p++ = '\r';
		*p++ = '\n';
		n = (UINT16)(p - line);
		if((UINT16)(at + n) > CFG_SIZE) continue;	/* no room: the line is left out */
		memcpy(SD_buffer + at, line, n);
		at += n;
	}
	memset(SD_buffer + at, ' ', CFG_SIZE - at);

	hw_set_page(A000Address_TF);
	if(f_open_bank(&gfil, cfg_path, FA_WRITE | FA_OPEN_ALWAYS) == FR_OK)
	{
		f_write_bank(&gfil, SD_buffer, CFG_SIZE, &n);
		f_close_bank(&gfil);
	}
	hw_set_page(A000Address_TF);
}

/* ---- the save info page ---- */

static UINT8 info_get(UINT16 at)
{
	UINT8 v;

	HW_BANK = SAVE_info_sram_bank;
	hw_set_page(A000Address_SRAM);
	v = *((volatile UINT8 *)(FlashBase_SRAM + at));
	HW_BANK = 0;
	hw_set_page(A000Address_TF);
	return v;
}

static void info_put(UINT16 at, UINT8 v)
{
	HW_BANK = SAVE_info_sram_bank;
	hw_set_page(A000Address_SRAM);
	*((volatile UINT8 *)(FlashBase_SRAM + at)) = v;
	HW_BANK = 0;
	hw_set_page(A000Address_TF);
}

/* ---- the clock prompt ---- */

/* "YY-MM-DD HH:MM" at text column 6 of a row */
static void draw_time(const UINT8 *t, UINT8 row)
{
	UINT8 s[15];
	UINT8 *p = s;

	p = put2(p, t[0], '-');
	p = put2(p, t[1], '-');
	p = put2(p, t[2], ' ');
	p = put2(p, t[3], ':');
	p = put2(p, t[4], 0U);
	*p = 0U;
	Draw_Text(s, 14U, 6U, row);
}

/* Shows the chip's time and the stored one. 1 when A (restore) was chosen. */
static UINT8 clock_prompt(UINT8 why)
{
	UINT8 s[12];
	UINT8 keys;

	color(BLACK, DKGREY, SOLID);
	box(2, 37, 157, 108, M_FILL);
	if(why == 0U) memcpy(s, "RTC RESET?", 11U);
	else if(why == 1U) memcpy(s, "RTC BAD?", 9U);
	else if(why == 2U) memcpy(s, "RTC LOW V?", 11U);
	else memcpy(s, "RTC BEHIND?", 12U);
	Draw_Text(s, (UINT8)strlen((char *)s), 1U, 5U);

	memcpy(s, "NOW", 4U);
	Draw_Text(s, 4U, 1U, 7U);
	if(why != 1U) draw_time(now, 7U);
	memcpy(s, "SD ", 4U);
	Draw_Text(s, 4U, 1U, 9U);
	draw_time(cfg_rtc, 9U);

	memcpy(s, "[A]RESTORE", 11U);
	Draw_Text(s, 10U, 1U, 11U);
	memcpy(s, "[B]KEEP", 8U);
	Draw_Text(s, 7U, 12U, 11U);

	while(joypad() & (J_A | J_B)) wait_vbl_done();
	while(1)
	{
		wait_vbl_done();
		keys = joypad();
		if(keys & (J_A | J_B)) break;
	}
	while(joypad() & (J_A | J_B)) wait_vbl_done();
	color(BLACK, WHITE, SOLID);
	return (keys & J_A) ? 1U : 0U;
}

static void clock_check(void)
{
	UINT8 why;
	UINT8 first[6];
	UINT8 tries;

	clock_read();
	if(now_flags & NOW_BAD) why = 1U;
	else if(now[0] == 0U) why = 0U;
	else if(now_flags & NOW_LOWV) why = 2U;
	else if(later(cfg_rtc, now)) why = 3U;
	else return;

	/* A suspect reading may be the FPGA's copy of the registers not filled
	   yet early in a cold boot: wait, then read until two readings a frame
	   apart agree, and judge that one. */
	delay(1000);
	for(tries = 0U; tries < 60U; tries++)
	{
		clock_read();
		memcpy(first, now, 6U);
		wait_vbl_done();
		clock_read();
		if(!memcmp(first, now, 5U)) break;
	}
	if(now_flags & NOW_BAD) why = 1U;
	else if(now[0] == 0U) why = 0U;
	else if(now_flags & NOW_LOWV) why = 2U;
	else if(later(cfg_rtc, now)) why = 3U;
	else return;

	if(clock_prompt(why)) clock_write(cfg_rtc);
	else if((why == 2U) && !(now_flags & NOW_BAD)) clock_write(now);	/* clears the flag */
}

/* ---- the console, for the jump past the boot ROM ---- */

/* Fills boot_regs and launch_mode (docs/skip-boot-rom.md). Our stage1
   leaves the boot ROM's registers in save RAM bank 17 at $A428, behind the
   mark "SB" or "SN" at $A412. Stock stage1 leaves nothing, and then the
   mode decides. */
UINT8 cgb_mode;				/* console_init: the kernel runs in CGB mode */

/* ---- the font ---- */

static void font_set(void)
{
#ifdef LANG_ZH
	ui_font = 0U;			/* the Chinese build has its own 12px text, ui_zh.c */
#else
	ui_font = (cfg_ui == 3U) ? 2U : (cfg_ui ? 1U : 0U);
#endif
	ui_font_cfg = ui_font;
	list_rows = ui_font ? 10U : 16U;
}

/* ---- themes ---- */


/* The theme in use. The 0918 mod has two more, custom (6) and DV (7): here
   they show as dark, and the file keeps its number until the row is used. */
UINT8 theme_now(void) __banked
{
	return (cfg_theme < THEMES) ? cfg_theme : 1U;
}

/* What color index 0 to 3 draws as (docs/themes.md), BGR555 low byte
   first: the background, a shade of it, the highlight, the ink. This
   kernel draws a highlight as the ink on index 2, where the 0918 mod draws
   the background color on its accent, so the color themes have a deeper
   accent here, one white text reads on.

   In CGB mode the colors go to every BG and OBJ palette. A DMG, and a
   color console in DMG compatibility mode, have only BGP: light is the
   stock $E4 and every other theme is the inverted $1B. */
static void theme_apply(void)
{
	static const UINT8 ramps[THEMES][8] = {
		{0xFFU, 0x7FU, 0xB5U, 0x56U, 0x4AU, 0x29U, 0x00U, 0x00U},	/* light, stock */
		{0x00U, 0x00U, 0xC6U, 0x18U, 0x31U, 0x46U, 0xFFU, 0x7FU},	/* dark */
		{0x28U, 0x04U, 0xEDU, 0x1CU, 0xA3U, 0x69U, 0xFFU, 0x7FU},	/* red, sky #1A6FD0 */
		{0x22U, 0x0DU, 0xA8U, 0x25U, 0x18U, 0x3DU, 0xFFU, 0x7FU},	/* green, rose #C2407F */
		{0x48U, 0x30U, 0x0DU, 0x41U, 0xF3U, 0x01U, 0xFFU, 0x7FU},	/* purple, gold #9A7A00 */
		{0xA2U, 0x30U, 0x48U, 0x41U, 0x79U, 0x0DU, 0xFFU, 0x7FU},	/* blue, apricot #C85A1A */
	};
	const UINT8 *r = ramps[theme_now()];
	UINT8 pal;
	UINT8 i;

	if(!cgb_mode)
	{
		BGP_REG = theme_now() ? 0x1BU : 0xE4U;
		return;
	}
	/* palette RAM does not take a write in mode 3: one palette of each
	   kind a frame, at the start of VBlank */
	for(pal = 0U; pal < 8U; pal++)
	{
		wait_vbl_done();
		BCPS_REG = (UINT8)(0x80U | (pal << 3));
		OCPS_REG = (UINT8)(0x80U | (pal << 3));
		for(i = 0U; i < 8U; i++)
		{
			BCPD_REG = r[i];
			OCPD_REG = r[i];
		}
	}
}

/* ---- SGB BOOT ---- */

/* The setting is a record in save RAM, bank 17 at $A400: 'S' 'G' $01 $FE.
   It cannot be in the file, since the packets go out before the card is
   up. Our stage1 sends them itself and says so with "SB" or "SN" at $A412. */
UINT8 sgb_record(void) __banked
{
	return ((info_get(0x400U) == 'S') && (info_get(0x401U) == 'G') &&
	        (info_get(0x402U) == 0x01U) && (info_get(0x403U) == 0xFEU)) ? 1U : 0U;
}

static void sgb_start(void)
{
	UINT8 m;

	sgb_on = 0U;
	m = info_get(0x413U);
	if((info_get(0x412U) == 'S') && ((m == 'B') || (m == 'N'))) return;
	if(!sgb_record()) return;
	sgb_on = 1U;
	sgb_set1();			/* the first set, 0.4 s */
	sgb_wait = 192U;		/* the rest from VBlank */
	sgb_step = 1U;
	add_VBL(sgb_vbl);
}

/* SGB= in the file sets the record for the next boot */
static void sgb_apply(void)
{
	if(cfg_sgb == 1U)
	{
		if(sgb_record()) return;
		info_put(0x400U, 'S');
		info_put(0x401U, 'G');
		info_put(0x402U, 0x01U);
		info_put(0x403U, 0xFEU);
	}
	else if(cfg_sgb == 0U)
	{
		if(sgb_record()) info_put(0x400U, 0U);
	}
}

static UINT8 con_dmg;			/* the DMG family */
static UINT8 con_nodmg;			/* an SGB under our stage1 */

static void launch_mode_set(void)
{
	if(cfg_bootrom) launch_mode = 0U;
	else if(con_dmg) launch_mode = (con_nodmg || sgb_on) ? 0U : 1U;	/* SGB BOOT on: it may be an SGB, which needs the reset */
	else launch_mode = cgb_mode ? 2U : 0U;
}

static void console_detect(void)
{
	static const UINT8 dmg_regs[8] = {0xB0U, 0x01U, 0x13U, 0x00U, 0xD8U, 0x00U, 0x4DU, 0x01U};
	static const UINT8 cgb_regs[8] = {0x80U, 0x11U, 0x00U, 0x00U, 0x56U, 0xFFU, 0x0DU, 0x00U};
	UINT8 rec[8];
	UINT8 dmg_fam;
	UINT8 no_dmg = 0U;
	UINT8 i;
	UINT8 m;

	/* VBK reads $FF on the DMG family and the written bit on a color console */
	VBK_REG = 0U;
	dmg_fam = VBK_REG & 1U;
	memcpy(boot_regs, cgb_mode ? cgb_regs : dmg_regs, 8U);

	m = info_get(0x413U);
	if((info_get(0x412U) == 'S') && ((m == 'B') || (m == 'N')))
	{
		no_dmg = 1U;			/* a stage1 from before the registers could be on an SGB */
		for(i = 0U; i < 8U; i++) rec[i] = info_get((UINT16)(0x428U + i));
		if((rec[1] == 0x01U) || (rec[1] == 0x11U) || (rec[1] == 0xFFU))
		{
			memcpy(boot_regs, rec, 8U);
			no_dmg = (rec[2] == 0x14U) ? 1U : 0U;	/* C = $14 is an SGB */
			dmg_fam = (rec[1] != 0x11U) ? 1U : 0U;
		}
	}
	/* "S1" at $A410: our stage1 saw the fast launch canceled (START held)
	   or could not do it, and the kernel must not launch the game itself */
	s1_cancel = 0U;
	if((info_get(0x410U) == 'S') && (info_get(0x411U) == '1'))
	{
		s1_cancel = 1U;
		info_put(0x410U, 0U);
		info_put(0x411U, 0U);
	}
	/* the record is for this boot only: it must not outlive a change of stage1 */
	info_put(0x412U, 0U);
	info_put(0x413U, 0U);
	info_put(0x429U, 0U);

	con_dmg = dmg_fam;
	con_nodmg = no_dmg;
	launch_mode_set();
}

/* ---- what the kernel calls ---- */

/* First thing in main(). In CGB mode BGP and OBP are ignored and color
   comes from palette RAM, which nothing in the kernel as received sets: the
   kernel runs in CGB mode when the header the boot ROM saw has the CGB
   flag, which is our stage1's, and then the screen is whatever stage1 left.
   Here every BG and OBJ palette gets the four grays BGP = $E4 gives, and
   VRAM bank 1 (the tile attributes) is cleared. On a DMG, and on a color
   console in DMG compatibility mode, nothing is done. */
void console_init(void) __banked
{
	static const UINT8 grays[8] = {0xFFU, 0x7FU, 0xB5U, 0x56U, 0x4AU, 0x29U, 0x00U, 0x00U};
	UINT8 *v;
	UINT8 i;

	/* nothing here counts on WRAM being cleared at startup */
	cfg_dry = 0U;
	ui_font = 0U;
	ui_font_cfg = 0U;
	tags_hide = 1U;
	list_rows = 16U;
	sgb_step = 0U;
	sgb_wait = 0U;
	sgb_busy = 0U;
	pad_last = 0U;
	pad_prev = 0U;
	sgb_start();
	cgb_mode = 0U;
	VBK_REG = 0U;
	if(VBK_REG & 1U) return;		/* the DMG family */

	display_off();				/* palette RAM and VRAM take writes at any time */
	BCPS_REG = 0U;
	BCPD_REG = 0x5AU;
	if(BCPD_REG == 0x5AU)
	{
		BCPD_REG = 0xA5U;
		if(BCPD_REG == 0xA5U) cgb_mode = 1U;
	}
	if(cgb_mode)
	{
		VBK_REG = 1U;
		for(v = (UINT8 *)0x8000U; v != (UINT8 *)0xA000U; v++) *v = 0U;
		VBK_REG = 0U;
		BCPS_REG = 0x80U;
		OCPS_REG = 0x80U;
		for(i = 0U; i < 64U; i++)
		{
			BCPD_REG = grays[i & 7U];
			OCPD_REG = grays[i & 7U];
		}
	}
	LCDC_REG |= 0x80U;
}

/* Boot, once the card is mounted and before the pending save is backed up */
void cfg_boot(void) __banked
{
	cfg_have_rtc = 0U;
	cfg_have_autosave = 0U;
	cfg_rtcsd = 1U;
	cfg_bootrom = 0U;
	cfg_flaunch[0] = 0;
	cfg_sgb = 2U;
	cfg_theme = 0U;
	cfg_ui = 0U;
	tags_hide = 1U;
	file_read(0U);
	theme_apply();
	font_set();
	plays_load();		/* stars and play counts, from /.ezgbplays (plays.c) */
	sgb_apply();
	console_detect();

	if(cfg_dry)
	{
		/* The save waiting in save RAM faded with everything else: it must
		   not reach the card. Then AUTO SAVE comes back from the file. */
		info_put(0x000U, 0U);
		if(cfg_have_autosave) info_put(0x200U, cfg_autosave);
	}
	if(cfg_rtcsd && cfg_have_rtc) clock_check();
	hw_set_page(A000Address_TF);
}

/* Fast launch (docs/fast-launch.md): at boot, before the first listing.
   1 when FLAUNCH= names a .gb or .gbc that opens and START is not held:
   currentpath is then its folder and lfname_temp its name, as the recent
   list leaves them for a launch. */
UINT8 cfg_fastlaunch(void) __banked
{
	UINT8 n;
	UINT8 slash;
	UINT8 i;
	const char *e;

	if(s1_cancel) return 0U;
	if(cfg_flaunch[0] == '#') return 0U;		/* off */
	if(cfg_flaunch[0] != '/')
	{
		/* no game set: a card whose root has one game and no other file
		   starts it (browser.c). currentpath is the root already. */
		if(joypad() & J_START) return 0U;
		return browser_lone_rom();
	}
	if(joypad() & J_START)
	{
		/* START is also the browser's key for the recent list: say what
		   happened and wait for it to be let go */
		UINT8 msg[21];

		memcpy(msg, "FAST LAUNCH CANCELED", 21U);
		Draw_Text(msg, 20U, 0U, 2U);
		while(joypad() & J_START) wait_vbl_done();
		return 0U;
	}

	n = (UINT8)strlen(cfg_flaunch);
	if(n < 5U) return 0U;
	e = cfg_flaunch + n - 3U;
	if(!key_tail(e, ".GB") && !key_tail(e - 1, ".GBC")) return 0U;

	/* a path that does not open boots to the browser */
	hw_set_page(A000Address_TF);
	if(f_open_bank(&gfil, cfg_flaunch, FA_READ) != FR_OK) return 0U;
	f_close_bank(&gfil);

	slash = 0U;
	for(i = 0U; i < n; i++) if(cfg_flaunch[i] == '/') slash = i;
	memset(currentpath, 0, MAX_path_len);
	if(slash) memcpy(currentpath, cfg_flaunch, slash);
	else currentpath[0] = '/';
	strcpy(lfname_temp, cfg_flaunch + slash + 1U);
	hw_set_page(A000Address_TF);
	f_chdir(currentpath);
	return 1U;
}

/* A launch, before the ROM is read: the clock and AUTO SAVE go to the file */
void cfg_launch(void) __banked
{
	UINT8 v;
	UINT8 dirty = 0U;

	sgb_finish();			/* what is left of the SGB packets goes before the game */
	plays_bump((const UINT8 *)lfname_temp);		/* one more launch of this game (plays.c) */
	v = info_get(0x200U);
	if((v <= 1U) && (!cfg_have_autosave || (v != cfg_autosave)))
	{
		cfg_autosave = v;
		cfg_have_autosave = 1U;
		dirty = 1U;
	}
	if(cfg_rtcsd)
	{
		clock_read();
		if(!now_flags && now[0] && (!cfg_have_rtc || later(now, cfg_rtc)))
		{
			memcpy(cfg_rtc, now, 6U);
			cfg_have_rtc = 1U;
			dirty = 1U;
		}
	}
	if(dirty) file_write();
	hw_set_page(A000Address_TF);
}

/* TIME SET confirmed. t is the SET tab's edited time, indexed by RTC.h's
   _SEC to _YEAR. */
void cfg_timeset(const UINT8 *t) __banked
{
	if(!cfg_rtcsd) return;
	cfg_rtc[0] = t[6];
	cfg_rtc[1] = t[5];
	cfg_rtc[2] = t[3];
	cfg_rtc[3] = t[2];
	cfg_rtc[4] = t[1];
	cfg_rtc[5] = t[0];
	cfg_have_rtc = 1U;
	file_write();
}

/* The AUTO SAVE box changed */
void cfg_autosave_set(UINT8 v) __banked
{
	cfg_autosave = v ? 1U : 0U;
	cfg_have_autosave = 1U;
	file_write();
}

/* ---- for the SET tab's pages (setpage.c) ---- */

/* A setting changed: put it to work and write the file. what is CFG_*. */
void cfg_changed(UINT8 what) __banked
{
	if(what == CFG_BOOTROM) launch_mode_set();
	else if(what == CFG_THEME) theme_apply();
	else if(what == CFG_FONT) font_set();
	else if(what == CFG_SGB)
	{
		/* the record in save RAM, for the boots after this one */
		if(sgb_record()) info_put(0x400U, 0U);
		else
		{
			info_put(0x400U, 'S');
			info_put(0x401U, 'G');
			info_put(0x402U, 0x01U);
			info_put(0x403U, 0xFEU);
		}
		if(cfg_sgb > 1U) return;		/* nothing of it in the file */
		cfg_sgb = sgb_record();
	}
	file_write();
}

/* The last game launched, from the save info page ($A300 of bank 17), into
   cfg_flaunch. 0 when it is not a path that fits. */
UINT8 cfg_flaunch_last(void) __banked
{
	UINT8 i;
	UINT8 c;

	if(info_get(0x300U) != '/') return 0U;
	for(i = 0U; i <= FLAUNCH_MAX; i++)
	{
		c = info_get((UINT16)(0x300U + i));
		if(c == 0U) break;
		if(c < 0x20U) return 0U;
	}
	if((i < 2U) || (i > FLAUNCH_MAX)) return 0U;
	for(c = 0U; c < i; c++) cfg_flaunch[c] = (char)info_get((UINT16)(0x300U + c));
	cfg_flaunch[i] = 0;
	return 1U;
}

/* After a save backup at boot: the clock goes to the file, as at a launch */
void cfg_backup(void) __banked
{
	if(!cfg_rtcsd) return;
	clock_read();
	if(now_flags || !now[0]) return;
	if(cfg_have_rtc && !later(now, cfg_rtc)) return;
	memcpy(cfg_rtc, now, 6U);
	cfg_have_rtc = 1U;
	file_write();
}
