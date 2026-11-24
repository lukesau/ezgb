#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""Check the length of the UI strings in ui_text.h.

Two rules, both learned the hard way:
  1. Dialog strings (the DIALOG list) must not exceed 10 characters:
     box(35,37,125,108) spans 40px..125px = 80px, 8px per character.
  2. Full-width rows (starting at x=0) must not exceed 20 characters: 160/8.

Why not a compile-time assertion: SDCC emits sizeof("literal") strings into
every module that includes the header (~290 bytes in each of 3 banks).

Exit code: 0 = pass, 1 = some string is too long.
"""
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
HEADER = os.path.join(HERE, '..', 'source', 'ui_text.h')

DIALOG_LIMIT = 10    # inside a dialog
LINE_LIMIT = 20      # full row starting at x=0

# strings only used inside dialogs
DIALOG = {
    'UI_SAVE_TITLE', 'UI_SAVE_BUSY', 'UI_SAVE_OK', 'UI_SAVE_FAIL',
    'UI_SAVE_FAIL_SD', 'UI_SAVE_PRESS_B', 'UI_BTN_NO', 'UI_BTN_OK',
    'UI_LOAD_TITLE', 'UI_LOAD_BUSY', 'UI_LOAD_OK', 'UI_LOAD_NONE',
    'UI_LOAD_NEW', 'UI_READING', 'UI_ERROR_FILE',
}

def main():
    with open(HEADER, 'rb') as fh:
        raw = fh.read()
    # The project is UTF-8 now; the GBK fallback stays for older branches
    for enc in ('utf-8', 'gbk'):
        try:
            text = raw.decode(enc)
            break
        except UnicodeDecodeError:
            continue
    else:
        print('[UI] cannot decode ui_test.h (neither UTF-8 nor GBK)')
        return 1

    bad = []
    count = 0
    for name, value in re.findall(r'#define\s+(UI_\w+)\s+"([^"]*)"', text):
        count += 1
        limit = DIALOG_LIMIT if name in DIALOG else LINE_LIMIT
        if len(value) > limit:
            bad.append((name, value, len(value), limit))

    for name, value, length, limit in bad:
        print('[UI] %-18s %2d > %2d chars  "%s"' % (name, length, limit, value))

    if bad:
        print('\n[UI] %d string(s) too long, fix ui_text.h' % len(bad))
        return 1

    print('[UI] %d strings checked, all fit' % count)
    return 0

if __name__ == '__main__':
    sys.exit(main())
