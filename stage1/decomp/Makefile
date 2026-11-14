# Stock stage1 from source, FW4 and FW5-0918 from one source (-DFW=4 / -DFW=5):
# the C compiled by SDCC 2.9.0, linked into the stock disassembly. The ROMs
# are byte for byte stock's; tools/link.py fails if they differ from a local
# kernel.gb.
#
#   make            build/fw4/stage1.gb and build/fw5/stage1.gb
#   make match      which functions match, per firmware (tools/match.py)
#   make clean
#
# SDCC 2.9.0 goes in ../../tools/sdcc-2.9.0: tools/build-sdcc29.sh.

SDCC29 := ../../tools/sdcc-2.9.0/bin/sdcc
SRCS := $(wildcard src/*.c src/*.h)

all: build/fw4/stage1.gb build/fw5/stage1.gb

build/fw4/stage1.gb: $(SRCS) tools/link.py $(SDCC29) ../fw4/kernel.sym ../fw4/disassembly/bank_000.asm ../fw4/disassembly/bank_001.asm
	python3 tools/link.py fw4

build/fw5/stage1.gb: $(SRCS) tools/link.py $(SDCC29) ../fw5-0918/kernel.sym ../fw5-0918/disassembly/bank_000.asm ../fw5-0918/disassembly/bank_001.asm
	python3 tools/link.py fw5-0918

$(SDCC29):
	@echo "no SDCC 2.9.0: run stage1/decomp/tools/build-sdcc29.sh" >&2; exit 1

match:
	python3 tools/match.py fw4
	python3 tools/match.py fw5-0918

clean:
	rm -rf build

.PHONY: all match clean
.DELETE_ON_ERROR:
