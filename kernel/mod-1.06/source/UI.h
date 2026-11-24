// font layout: 12 rows x 8 bits, 12 high, 6 wide, 6 bits used
#include <gb/gb.h>
#include <gb/drawing.h>



extern void DrawGB(UINT8 page)__banked;

extern void Show_reading(void)__banked;
extern void Show_loading(void)__banked;
extern void Show_Error_file(void)__banked;
extern void Show_gamelist_BG(void)__banked;