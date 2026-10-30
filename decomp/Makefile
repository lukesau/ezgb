# Stock 1.05e-0731 kernel from source: rgbds disassembly (asm/) with routines
# replaced by real sources (gbdk/, later src/) as they are matched. The build
# fails unless the result is byte-identical to the stock kernel.
#
#   make            build build/kernel.gb and check its md5
#   make clean

STOCK_MD5 := 91eb7fc67332ef20b5691029181ff748
SYM       := ../re/kernel/1.05e-0731/kernel.sym
SDINC     := python3 tools/sdinc.py

# Symbols crt0.s needs that are not in kernel.sym: GBDK's linker-defined
# addresses, and globals that global.s declares but the kernel never uses.
CRT0_DEFS := -g .STACK=0xe000 -g .refresh_OAM=0xff80 -g .OAM=0xc000 \
             -g .init=0 -g .reset=0 -g _main=0

INCS := build/crt0_low.inc build/crt0_home.inc

all: build/kernel.gb

build/crt0_low.inc build/crt0_home.inc &: gbdk/crt0.s gbdk/global.s tools/sdinc.py $(SYM)
	@mkdir -p build
	$(SDINC) gbdk/crt0.s --sym $(SYM) -b _HOME=0x0600 -b _BSS=0xd6c9 $(CRT0_DEFS) \
		--region 0000:01e3:build/crt0_low.inc --region 0600:07bc:build/crt0_home.inc

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
