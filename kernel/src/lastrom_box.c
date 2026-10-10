/* START overlay chrome (docs/last-rom.md "Overlay layout").
 *
 * Bank 2, injected at 02:4800. LastRomOverlay's inline far call at 00:129e
 * (`call FarCallTrampoline` + 4 bytes) used to reach the stock
 * DrawLastRomButtons (08:73f5); its target bytes now point here. Inline
 * trampoline, no arguments: two pad parameters.
 *
 * The stock function drew an outer box, two button frames and the labels on
 * tile row 17, where the 8x8 text cells repainted the frames' bottom edges
 * and the box's bottom line. Here there is one box with three text rows
 * inside it: a title, the name (LastRomName) and the button labels. The
 * name's row is a solid ink band across the box, on which LastRomName draws
 * the name in paper on ink, and a vertical rule separates the two labels:
 *
 *   8px   box (0,91)-(159,139); title, name, labels on tile rows 12, 14,
 *         16; band y 107..123, the vertical rule at x 83; the list is
 *         cleared from y 88 to the bottom of the screen
 *   12px  box (0,92)-(159,143), flush under list row 5 (the list starts at
 *         y 20); title, name, labels at y 96, 112, 128
 *         (DrawString12's pixel-y rows), from x 12; band y 109..125, the
 *         vertical rule at x 79
 *
 * The band and the rule go on after the text: an 8x8 cell or a 12px row repaints
 * everything it covers. DrawString12 paints its row out to x 159, over the
 * box's right side, so the 12px branch also redraws the outline (LastRomName
 * does the same after the name).
 *
 *   python3 tools/inject.py src/lastrom_box.c $V 2 4800 LastRomBox \
 *       --pin DrawString12=7500 --pin DrawString=08b7 --pin DrawRect=27ba \
 *       --pin StoreDrawParams=2791 --pin hUiMode=fffb --replace --apply
 */

typedef unsigned char u8;
typedef unsigned int u16;

extern void DrawString12(u16 pad_thunk, u16 pad_af, u16 pad_ret, const u8 *s, u8 len, u8 col, u8 row); /* 02:7500 */
extern void DrawString(const u8 *s, u8 len, u8 x, u8 y);           /* 00:08b7 */
extern void DrawRect(u8 x0, u8 y0, u8 x1, u8 y1, u8 fill);          /* 00:27ba */
extern void StoreDrawParams(u8 color, u8 colorB, u8 op);            /* 00:2791 */
#define LR_GEO (*(volatile u8 *)0xDB3F)     /* LastRomName's row: 0 = this overlay */
extern volatile u8 hUiMode;                                         /* $fffb: 0 = 8px, 1 = 12px */

void LastRomBox(u16 far_pad_thunk, u16 far_pad_af) {
    static const u8 title_str[17] = {'L','a','u','n','c','h',' ','L','a','s','t',' ','R','O','M','?',0};
    /* "[B]return" at 0 and "[A]start" at 12: one string for the 12px row,
     * two draws (columns 1 and 11) in 8px */
    static const u8 btn_str[21] = {'[','B',']','r','e','t','u','r','n',' ',' ',' ',
                                   '[','A',']','s','t','a','r','t',0};

    (void)far_pad_thunk;
    (void)far_pad_af;
    LR_GEO = 0;
    StoreDrawParams(0, 0, 0);
    if (!hUiMode) {
        DrawRect(0, 88, 159, 143, 1);
        StoreDrawParams(3, 0, 0);
        DrawRect(0, 91, 159, 139, 1);
        DrawString(title_str, 16, 1, 12);
        DrawString(btn_str, 9, 1, 16);
        DrawString(btn_str + 12, 8, 11, 16);
        StoreDrawParams(3, 3, 0);
        DrawRect(0, 107, 159, 123, 1);
        DrawRect(83, 123, 83, 139, 1);
        return;
    }
    StoreDrawParams(3, 0, 0);
    DrawRect(0, 92, 159, 143, 1);
    DrawString12(0, 0, 0, title_str, 0, 1, 96);
    DrawString12(0, 0, 0, btn_str, 0, 1, 128);
    DrawRect(0, 92, 159, 143, 0);
    StoreDrawParams(3, 3, 0);
    DrawRect(0, 109, 159, 125, 1);
    DrawRect(79, 125, 79, 143, 1);
}
