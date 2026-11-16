# The firmware updaters' program from source, FW4's and FW5-0918's from one
# source (-DFW=4 / -DFW=5): the kernel's crt0 and libraries, the C compiled
# by SDCC 2.9.0. Identical to stock's: tools/link.py fails if the result
# differs.
#
#   make            build/fw4/updater-code.gb and build/fw5-0918/updater-code.gb
#   make match      which functions match, per firmware (tools/match.py; needs
#                   the official updaters)
#   make clean
#
# SDCC 2.9.0 goes in ../../tools/sdcc-2.9.0: stage1/decomp/tools/build-sdcc29.sh.
# A whole updater is the program and a slot B image: tools/link.py --payload.

SDCC29 := ../../tools/sdcc-2.9.0/bin/sdcc
SRCS := $(wildcard src/*.c src/*.s) tools/link.py

all: build/fw4/updater-code.gb build/fw5-0918/updater-code.gb

build/fw4/updater-code.gb: $(SRCS) $(SDCC29)
	python3 tools/link.py fw4

build/fw5-0918/updater-code.gb: $(SRCS) $(SDCC29)
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
