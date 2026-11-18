# The mod kernel, built from source: README.md.
#
#   make          build/kernel.gb (16 banks) and build/kernel.sym, then check
#                 every call between banks
#   make clean
#
# manifest.py lists the sources by bank and tools/build.py compiles and
# links them. base/ needs SDCC 2.9.0, the compiler EZ Flash used
# (SDCC29=<install prefix>, by default ../../tools/sdcc-2.9.0); src/ and the
# assembler and linker are a current SDCC's. The version on the HELP tab is
# ../../patches/kernel/VERSION.

SDCC29 ?= $(abspath ../../tools/sdcc-2.9.0)
export SDCC29

all:
	python3 tools/build.py -o build
	python3 tools/faraudit.py build

clean:
	rm -rf build

.PHONY: all clean
