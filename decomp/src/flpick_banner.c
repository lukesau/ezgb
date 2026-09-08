/* Pick-mode banner for the file browser (docs/fastlaunch-set-tab.md).
 *
 * Bank 8, injected at 08:7b8d and reached by `jp` from the tail of the
 * tab-strip drawer's SD arm (08:7200, stock `jp $7331` = bare ret; stack is
 * balanced there, so this function's own ret ends DrawMenuTabs). That drawer
 * runs on every FileBrowserEntry, so while the SET tab's PICK mode is armed
 * ($DBFE != 0) the tab strip reads " PICK A ROM " instead of SD/SET/HELP.
 * Columns 16-19 (page number) are drawn later by the list code and survive.
 */

typedef unsigned char u8;

extern void DrawString(const u8 *s, u8 len, u8 col, u8 row);  /* 00:08b7 */
extern void StoreDrawParams(u8 color, u8 colorB, u8 op);      /* 00:2791 */

#define FL_PICK (*(volatile u8 *)0xDBFE)

void flpick_banner(void) {
    static const u8 banner[16] =
        {' ','P','I','C','K',' ','A',' ','R','O','M',' ',' ',' ',' ',0};
    if (FL_PICK == 0) return;
    StoreDrawParams(3, 2, 0);
    DrawString(banner, 15, 0, 0);
    StoreDrawParams(3, 0, 0);
}
