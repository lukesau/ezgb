#!/usr/bin/env bash
# Regenerate a stage1 disassembly from stage1/<fw>/kernel.sym + notes.json
# and check that it rebuilds byte for byte. kernel.gb there is stage1 as
# written by stage1-from-bram.py (ignored, like every firmware binary).
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
VER="${1:-fw4}"                    # fw4 or fw5-0918
DIR="stage1/$VER"
cd "$ROOT/$DIR"
python3 -u "$ROOT/tools/mgbdis/mgbdis.py" kernel.gb --overwrite >/dev/null
# stock stage1 carries a stale global checksum: fix only the header one
perl -pi -e 's/rgbfix -v -p 255/rgbfix -f h -p 255/' disassembly/Makefile
python3 "$ROOT/scripts/annotate-disasm.py" "$DIR" >/dev/null || [[ $? -eq 1 ]]
make -s -C disassembly >/dev/null
cmp disassembly/game.gb kernel.gb && echo "rebuild matches kernel.gb"
