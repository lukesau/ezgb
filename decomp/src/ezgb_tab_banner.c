/* Code-injection smoke test — deliberately trivial, not part of any feature.
 *
 * Purpose: prove the whole inject -> hook -> run chain end to end with a
 * change that is visible on a real screen, so that when a real feature
 * misbehaves we already know the plumbing itself is sound.
 *
 * Hook site: bank 8 $7200, the `jp $7331` that ends the SD-tab variant of
 * the browser's tab-row draw (tab index 0 at sp+$06, the default view).
 * $7331 is a bare `ret`, and this function is stack-neutral and ends in
 * `ret`, so replacing that `jp` with `jp ezgb_tab_banner` preserves the
 * original control flow exactly — nothing has to be replayed.
 *
 * Draws a 5-char marker at row 0, cols 15-19, the empty span to the right
 * of the " SD " / " SET " / " HELP " tabs.
 *
 * DrawString / StoreDrawParams argument order is copied from the stock tab
 * draws immediately above the hook site (see re/1.05e/disassembly/
 * bank_008.asm): DrawString(str, len, col, row), with the same
 * StoreDrawParams(3, 0, 0) an unselected tab uses.
 */
extern void DrawString(const unsigned char *s, unsigned char len,
                       unsigned char col, unsigned char row);
extern void StoreDrawParams(unsigned char a, unsigned char b, unsigned char c);

void ezgb_tab_banner(void) {
    StoreDrawParams(0x03, 0x00, 0x00);
    DrawString((const unsigned char *)"*MOD*", 5, 15, 0);
}
