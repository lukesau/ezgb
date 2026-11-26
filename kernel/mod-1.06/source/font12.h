/* mod: the 12px proportional font (font12.c) */
#ifndef FONT12_H
#define FONT12_H

#define FONT12_MAX	40U		/* glyphs in one string, at most */

/* ink * 4 + paper */
#define F12_NORMAL	0x0CU		/* ink 3 on paper 0 */
#define F12_INVERSE	f12_inverse	/* the selected row: ink 0 on paper 3, or on the theme's accent (ezcfg.c) */
extern UINT8 f12_inverse;

/* the icons, as characters */
#define F12_STAR	0x7FU
#define F12_FOLDER	0xC0U
#define F12_GB		0xC1U
#define F12_GBC		0xC2U
#define F12_FILE	0xC3U
#define F12_SAV		0xC4U

void font12_field(const UINT8 *s, UINT8 x0, UINT8 y, UINT8 colors, UINT8 xe) __banked;
UINT8 font12_end(const UINT8 *s, UINT8 x) __banked;
void font12_draw(const UINT8 *s, UINT8 x0, UINT8 y, UINT8 colors) __banked;
UINT8 font12_fit(const UINT8 *s, UINT8 x) __banked;

#endif
