#!/usr/bin/env python3
"""Pack EZ Flash's 6x12 ASCII font (source/asc12x6.c, the Chinese build's)
as a glyph set for the mod's 12px renderer (source/font12.c): the font the
SET tab calls EZF.

  ezf-pack.py <asc12x6.c> <font12.bin> <font12-metrics.bin> <out.bin> <out-metrics.bin>

The output has the shape kernel/tools/font12-pack.py gives the mod's font
(docs/font12.md): 101 glyphs of 12 rows, each a big-endian 16-bit word with
the leftmost pixel in bit 15, for codes 0x20 to 0x7F and then the five
icons; and the metrics, an advance, an ink width and a left kerning class
for each glyph and the offsets of the right class rows.

The letters are EZ Flash's as they are, each in its fixed 6 pixel cell and
not trimmed, with no kerning (every class is 0, which the renderer takes
as "never kerns"). The star and the icons are the mod font's, since EZ
Flash's font has none.
"""
import re
import sys

GLYPHS = 101
ICON_FIRST = 95          # the star (0x7F), then the icons 0xC0 to 0xC4
CELL = 6

src, mod_bin, mod_met, out_bin, out_met = sys.argv[1:6]
text = open(src, encoding='latin-1').read()
body = text[text.index('ASC_DATA'):]
data = bytes(int(h, 16) for h in re.findall(r'0x([0-9A-Fa-f]{2})', body))
assert len(data) == 1536, len(data)
font = open(mod_bin, 'rb').read()
met = open(mod_met, 'rb').read()
assert len(font) == GLYPHS * 24

glyphs = bytearray()
adv = bytearray()
width = bytearray()
for g in range(GLYPHS):
    if g >= ICON_FIRST:
        glyphs += font[g * 24:(g + 1) * 24]
        adv.append(met[g])
        width.append(met[GLYPHS + g])
        continue
    code = 0x20 + g
    for row in data[code * 12:(code + 1) * 12]:
        glyphs += bytes([row, 0])
    adv.append(CELL)
    width.append(0 if code == 0x20 else CELL)

open(out_bin, 'wb').write(glyphs)
# no kerning: the left classes are all 0, so the row offsets are never read
open(out_met, 'wb').write(bytes(adv) + bytes(width) + bytes(GLYPHS) + bytes(2 * GLYPHS))
print('wrote %s: %d glyphs, %d bytes; %s: %d bytes' % (out_bin, GLYPHS, len(glyphs), out_met, 5 * GLYPHS))
