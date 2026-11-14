# Stock 1.05e-0731 kernel from source: rgbds disassembly (asm/) with routines
# replaced by real sources (gbdk/, src/) as they are matched. The build
# fails unless the result is byte-identical to the stock kernel.
#
# The C needs SDCC 2.9.0, the compiler EZ Flash used: SDCC29=<install prefix>.
#
#   make            build build/kernel.gb and check its md5
#   make clean

STOCK_MD5 := 91eb7fc67332ef20b5691029181ff748
SYM       := ../kernel.sym
SDINC     := python3 tools/sdinc.py

# Symbols crt0.s needs that are not in kernel.sym: GBDK's linker-defined
# addresses, and globals that global.s declares but the kernel never uses.
CRT0_DEFS := -g .STACK=0xe000 -g .refresh_OAM=0xff80 -g .OAM=0xc000 \
             -g .init=0 -g .reset=0 -g _main=0

# FatFs R0.11a (src/ff.c): one copy per bank, cut by BANK. Its calls out of
# the bank, under their kernel.sym names.
FF_BANKS   := 3 5 6 7 9
FF_ALIASES := -a _disk_initialize=DiskInitialize -a _disk_status=DiskStatus \
              -a _disk_read=FarCallDiskRead -a _disk_write=FarCallDiskWrite \
              -a _disk_ioctl=ReturnZero -a _get_fattime=RtcReadPage \
              -a _ff_convert=MapCp437 -a _ff_wtoupper=WToUpper \
              -a banked_call=FarCallTrampoline -a __mullong_rrx_s=U32Mul \
              -a __divulong_rrx_s=U32Mod -a __divuint_rrx_s=U16Div \
              -a __rlulong_rrx_s=U32Shl -a __rrulong_rrx_s=U32Shr

INCS := build/crt0_low.inc build/crt0_home.inc $(FF_BANKS:%=build/ff_b%.inc)

all: build/kernel.gb

build/crt0_low.inc build/crt0_home.inc &: gbdk/crt0.s gbdk/global.s tools/sdinc.py $(SYM)
	@mkdir -p build
	$(SDINC) gbdk/crt0.s --sym $(SYM) -b _HOME=0x0600 -b _BSS=0xd6c9 $(CRT0_DEFS) \
		--region 0000:01e3:build/crt0_low.inc --region 0600:07bc:build/crt0_home.inc

# the whole bank: code from $4000, $FF fill after it, FatFs globals at $C5A5
# banks 5, 6 and 9 link src/dbg.c first
ff_srcs = $(if $(filter 5 6 9,$(1)),src/dbg.c) src/ff.c

build/ff_b%.inc: src/dbg.c src/ff.c src/ff.h src/ffconf.h src/integer.h src/diskio.h tools/sdinc.py $(SYM)
	@mkdir -p build
	$(SDINC) $(call ff_srcs,$*) --sdcc29 --bank $* --cflags "--opt-code-size -DBANK=$*" --sym $(SYM) \
		-b _CODE=0x4000 -b _DATA=0xc5a5 $(FF_ALIASES) --region 4000:8000:$@

build/kernel.gb: asm/game.asm asm/bank_*.asm asm/*.inc $(INCS)
	rgbasm -I asm/ -I build/ -o build/game.o asm/game.asm
	rgblink -n build/kernel.sym -m build/kernel.map -o $@ build/game.o
	@md5=$$(md5 -q $@ 2>/dev/null || md5sum $@ | cut -d' ' -f1); \
	if [ "$$md5" = "$(STOCK_MD5)" ]; then echo "$@: matches stock ($$md5)"; \
	else echo "$@: MISMATCH ($$md5, want $(STOCK_MD5))"; exit 1; fi

clean:
	rm -rf build

.PHONY: all clean

# a kernel that fails the md5 check must not count as up to date
.DELETE_ON_ERROR:
