/* Bank 10: the mod's C, built by kernel/stock (make MOD=1). */

#include <gb/gb.h>
#include <gb/drawing.h>

void DrawString (char *s, UINT8 len, UINT8 x, UINT8 y);

/* the mod's line on the firmware version screen, under stock's three */
void ModVersion (void) __banked
{
	color(3, 0, 0);
	DrawString("ezgb mod", 8, 0, 7);
}
