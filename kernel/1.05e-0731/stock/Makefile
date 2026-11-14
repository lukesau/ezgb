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

INCS := build/crt0_low.inc build/crt0_home.inc $(FF_BANKS:%=build/ff_b%.inc) build/b0_fatfs.inc build/b1_ccsbcs_init.inc build/b0_kernel.inc \
        build/b0_strrchr.inc build/b0_strncpy.inc build/b0_strlen.inc

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

# bank 0's FatFs glue: the f_ entry points, the disk layer and the RTC clock,
# and the CP437 conversion. ff_wtoupper's tables are WRAM ($CC33): the
# _GSINIT code that fills them is in bank 1, where EZ Flash linked that area.
B0_FATFS_SRCS := src/fsglue.c src/diskio.c src/option/ccsbcs.c
B0_FATFS_ALIASES := -a _f_open=Open_B6 -a _f_read=Read_B6 -a _f_write=Write_B7 \
              -a _f_lseek=Lseek_B3 -a _f_close=Close_B3 -a _f_mkdir=Open_B9 \
              -a _clust2sect=Clust2Sect_B5 -a _get_fat=GetFat_B5 \
              -a _SdRead=DiskRead_B2 -a _SdWrite=DiskWrite_B2 -a banked_call=FarCallTrampoline \
              -a __rlulong_rrx_s=U32Shl -a __rrulong_rrx_s=U32Shr -a __initrleblock=RleUnpack

build/b0_fatfs.inc build/b1_ccsbcs_init.inc &: $(B0_FATFS_SRCS) src/ff.h src/ffconf.h src/integer.h src/diskio.h tools/sdinc.py $(SYM)
	@mkdir -p build
	$(SDINC) $(B0_FATFS_SRCS) --sdcc29 --bank 0 --cflags=--opt-code-size --sym $(SYM) \
		-b _CODE=0x1926 -b _DATA=0xcc33 -b _GSINIT=0x68c0 $(B0_FATFS_ALIASES) \
		--region 1926:20bb:build/b0_fatfs.inc --region 68c0:7096:build/b1_ccsbcs_init.inc

# the kernel's own C in bank 0, $07BC-$1926, against GBDK 2.96a's headers
KERNEL_CFLAGS := --opt-code-size -I$(CURDIR)/gbdk/include -DBYTE_IS_UNSIGNED=1
KERNEL_SRCS := src/kernel.c
KERNEL_ALIASES := -a _joypad=ReadJoypad -a _delay=Delay -a _plot_point=PlotPixelXY \
              -a _gotogxy=SetTextCursor -a _wrtchr=DrawGlyphAdvance -a _color=StoreDrawParams \
              -a _strlen=CStrLen -a _strcpy=ApplyBasename -a _f_readdir=Readdir_B5 \
              -a _U32ToAscii_B0=U32ToAscii_B0 -a _wDebugTextRow=wDebugTextRow \
              -a _wDebugTextCol=wDebugTextCol -a banked_call=FarCallTrampoline \
              -g _wEntries=0xc2a0 -g _wEntryCount=0xc2a2 -g _wDirEnd=0xc5a4 \
              -g _wFno=0xc9db -g _wDir=0xc9f5 -a _SetFpgaPageAlt_B4=SetFpgaPageAlt_B4 \
              -a _strncpy=Strncpy -a _CStrCat_B1=CStrCat_B1 -a __rrulong_rrx_s=U32Shr \
              -a __modulong_rrx_s=U32Div -a __divulong_rrx_s=U32Mod -g _wLabelBuf=0xc4a4 -g _wMarqueePos=0xcc31 \
              -a _box=DrawRect -a _memset=Memset -a _memcpy=Memcpy -a _strrchr=Strrchr \
              -a _wait_vbl_done=WaitVBlankFlag -a _display_off=LcdOff -a _disable_interrupts=DiNest \
              -a _f_mount=Mount_B5 -a _f_chdir=Chdir_B5 -a _f_opendir=Opendir_B5 -a _fs_mkdir=FarCall_09_77ff \
              -a _CStrCmp=CStrCmp -a _DrawReadingBox=DrawReadingBox -a _DrawLoadingBox=DrawLoadingBox \
              -a _DrawErrorFileBox=DrawErrorFileBox -a _DrawLastRomButtons=DrawLastRomButtons \
              -a _DrawTimeAutosaveScreen=DrawTimeAutosaveScreen -a _DrawFwVersionScreen=DrawFwVersionScreen \
              -a _DrawBrowserEntries=DrawBrowserEntries -a _DrawBrowserDetail=DrawBrowserDetail \
              -a _BackupSavePrompt=BackupSavePrompt -a _LoaderPrepPath=LoaderPrepPath \
              -a _RomLoaderMain=RomLoaderMain -a _BackupOpenSaverPath=BackupOpenSaverPath \
              -a _LaunchSetup=LaunchSetup -a _SetFpga7F37_B4=SetFpga7F37_B4 -a _SetFpga7FD4_B1=SetFpga7FD4_B1 \
              -a _SetFpga7FC4_B4=SetFpga7FC4_B4 -a _SetFpgaRomSize_B4=SetFpgaRomSize_B4 \
              -a _SetFpga7FC3_B4=SetFpga7FC3_B4 -a _RomLoad_CopyCmdWindowPoll_B4=RomLoad_CopyCmdWindowPoll_B4 \
              -g _Bank8_7169=08:7169 -g _wFatFs=0xc7a9 -g _wPath=0xc2a6 -g _wTmp=0xc3a5 \
              -g _wD3EB=0xd3eb -g _wD3EC=0xd3ec -g _wD3ED=0xd3ed -g _wD3EF=0xd3ef -g _wD3F0=0xd3f0 \
              -g _wD3F6=0xd3f6

build/b0_kernel.inc: $(KERNEL_SRCS) src/ff.h src/ffconf.h src/integer.h tools/sdinc.py $(SYM)
	@mkdir -p build
	$(SDINC) $(KERNEL_SRCS) --sdcc29 --bank 0 --cflags="$(KERNEL_CFLAGS)" --sym $(SYM) \
		-b _CODE=0x07bc $(KERNEL_ALIASES) --region 07bc:1926:$@


# SDCC 2.9.0's library C among bank 0's library modules, built as SDCC
# builds its device lib: no options
SDCCLIB_INCS := build/b0_strrchr.inc build/b0_strncpy.inc build/b0_strlen.inc

build/b0_strrchr.inc: sdcclib/_strrchr.c tools/sdinc.py $(SYM)
	@mkdir -p build
	$(SDINC) $< --sdcc29 --bank 0 --sym $(SYM) -b _CODE=0x2c42 --region 2c42:2ca5:$@

build/b0_strncpy.inc: sdcclib/_strncpy.c tools/sdinc.py $(SYM)
	@mkdir -p build
	$(SDINC) $< --sdcc29 --bank 0 --sym $(SYM) -b _CODE=0x2cd3 --region 2cd3:2d4c:$@

build/b0_strlen.inc: sdcclib/_strlen.c tools/sdinc.py $(SYM)
	@mkdir -p build
	$(SDINC) $< --sdcc29 --bank 0 --sym $(SYM) -b _CODE=0x2d95 --region 2d95:2dba:$@

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
