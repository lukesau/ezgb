# -*- coding: utf-8 -*-
"""Host-side replica of the /SAVER/Recently play.txt I/O (byte for byte).
   Purpose: reproduce the "second record lost its first two characters" bug.
"""

MAXFN = 254
RECENT_MAX = 10
CHUNK = 32

sram = bytearray(8192)          # the SRAM page of the A000 window
tf = bytearray(8192)            # the TF page of the A000 window
WIN = {'cur': tf}


def hw_set_page(page):
    WIN['cur'] = sram if page == 3 else tf


class Rec:
    def __init__(self):
        self.filename = bytearray(MAXFN)
        self.fattrib = 0


class PBuf:
    """pFilename_buffer = (FM_FILE_FS*)0xa000"""
    def __getitem__(self, i):
        return RecProxy(i)


class RecProxy:
    def __init__(self, i):
        self.base = i * 255
        self.filename = FilenameView(self.base)


class FilenameView:
    def __init__(self, base):
        self.base = base

    def __setitem__(self, k, v):
        WIN['cur'][self.base + k] = v

    def __getitem__(self, k):
        return WIN['cur'][self.base + k]

    def __str__(self):
        out = []
        k = 0
        while k < MAXFN:
            c = WIN['cur'][self.base + k]
            if c == 0:
                break
            out.append(chr(c))
            k += 1
        return ''.join(out)

    def __len__(self):
        return len(str(self))


pFilename_buffer = PBuf()


class Card:
    def __init__(self):
        self.data = bytearray()
        self.pos = 0
        self.size = 0


card = Card()


def f_open(mode_create):
    if mode_create:
        card.data = bytearray()
        card.size = 0
    elif card.size == 0:
        return 4          # FR_NO_FILE
    card.pos = 0
    return 0


def f_read(btr):
    n = 0
    out = bytearray()
    while n < btr and card.pos < card.size:
        out.append(card.data[card.pos])
        card.pos += 1
        n += 1
    return out


def f_write(buf):
    for b in buf:
        if card.pos < len(card.data):
            card.data[card.pos] = b
        else:
            card.data.append(b)
        card.pos += 1
    if card.pos > card.size:
        card.size = card.pos
    return len(buf)


def recently_load():
    hw_set_page(0)
    if f_open(False) != 0:
        return 0
    n = 0
    ln = 0
    while n < RECENT_MAX:
        hw_set_page(0)
        chunk = f_read(CHUNK)
        if not chunk:
            break
        hw_set_page(3)
        for c in chunk:
            if c == 0x0D:
                continue
            if c == 0x0A:
                if ln:
                    pFilename_buffer[n].filename[ln] = 0
                    n += 1
                    ln = 0
                    if n >= RECENT_MAX:
                        break
                continue
            if ln < MAXFN - 1:
                pFilename_buffer[n].filename[ln] = c
                ln += 1
    if ln and n < RECENT_MAX:
        hw_set_page(3)
        pFilename_buffer[n].filename[ln] = 0
        n += 1
    hw_set_page(0)
    return n


def recent_write_line(src):
    hw_set_page(3)
    ln = len(src)
    off = 0
    while off < ln:
        chunk = ln - off
        if chunk > CHUNK:
            chunk = CHUNK
        buf = bytes(WIN['cur'][src.base + off + k] for k in range(chunk))
        hw_set_page(0)
        f_write(buf)
        hw_set_page(3)
        off += CHUNK
    hw_set_page(0)
    f_write(b'\r\n')


def recently_add(fullpath):
    hw_set_page(0)
    n = recently_load()
    if n > 0:
        hw_set_page(3)
        if str(pFilename_buffer[0].filename) == fullpath:
            hw_set_page(0)
            print('  [dedupe] %s' % fullpath)
            return
    hw_set_page(0)
    f_open(True)
    f_write(fullpath.encode('ascii'))
    f_write(b'\r\n')
    for i in range(min(n, RECENT_MAX - 1)):
        hw_set_page(3)
        if str(pFilename_buffer[i].filename) == fullpath:
            continue
        recent_write_line(pFilename_buffer[i].filename)
    hw_set_page(0)


def dump(tag):
    s = card.data[:card.size]
    txt = s.replace(b'\r', b'\\r').replace(b'\n', b'\\n')
    print('%-22s [%d] %s' % (tag, card.size, txt.decode('latin1')))


for step, path in enumerate(['/GAMES/GAME_A.GB',
                             '/GAMES/GAME_B.GB',
                             '/GAMES/SUPER MARIO LAND.ZELDA.GB',
                             '/GAMES/GAME_A.GB',
                             '/A.GB',
                             '/GAMES/GAME_B.GB']):
    recently_add(path)
    dump('%d add %s' % (step + 1, path.rsplit('/', 1)[-1]))
