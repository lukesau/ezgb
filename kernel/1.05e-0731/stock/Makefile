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

INCS := build/crt0_low.inc build/crt0_home.inc build/b1_gsinittail.inc build/b1_kernel_init.inc build/b1_code.inc build/b1_init.inc $(FF_BANKS:%=build/ff_b%.inc) build/b0_fatfs.inc build/b1_ccsbcs_init.inc build/b0_kernel.inc \
        build/b0_strrchr.inc build/b0_strncpy.inc build/b0_strlen.inc build/b0_sdccasm.inc build/b0_rle.inc \
        build/b0_gbdk_header.inc build/b0_gbdk_code.inc build/b0_gbdk_vbl.inc build/b0_gbdk_font.inc build/b0_gbdk_base.inc \
        build/b2_code.inc build/b4_wram.inc build/b4_code.inc build/b8_code.inc build/b0_lib0.inc build/b0_lib1.inc build/b0_lib2.inc build/b0_lib3.inc build/b0_lib4.inc build/b0_lib5.inc

all: build/kernel.gb

build/crt0_low.inc build/crt0_home.inc build/b1_gsinittail.inc build/crt0.sym &: gbdk/crt0.s gbdk/global.s tools/sdinc.py $(SYM)
	@mkdir -p build
	$(SDINC) gbdk/crt0.s --sym $(SYM) -b _HOME=0x0600 -b _BSS=0xd6c9 $(CRT0_DEFS) \
		-b _GSINIT=0x68b6 -b _GSINITTAIL=0x7390 \
		--region 0000:01e3:build/crt0_low.inc --region 0600:07bc:build/crt0_home.inc \
		--region 7390:8000:build/b1_gsinittail.inc --syms-out build/crt0.sym

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
              -a __modulong_rrx_s=U32Div -a __divulong_rrx_s=U32Mod -g _wLabelBuf=0xc4a4 \
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
              -g _DrawMenuTabs=08:7169 -g _wFatFs=0xc7a9 -g _wPath=0xc2a6 -g _wTmp=0xc3a5 \
              -g _wD3EB=0xd3eb -g _wD3EC=0xd3ec -g _wD3ED=0xd3ed -g _wD3EF=0xd3ef -g _wD3F0=0xd3f0 \
              -g _wD3F6=0xd3f6

# its one initialized global, wMarqueePos, starts _GSINIT ($68B6, bank 1)
build/b0_kernel.inc build/b1_kernel_init.inc &: $(KERNEL_SRCS) src/ff.h src/ffconf.h src/integer.h tools/sdinc.py $(SYM)
	@mkdir -p build
	$(SDINC) $(KERNEL_SRCS) --sdcc29 --bank 0 --cflags="$(KERNEL_CFLAGS)" --sym $(SYM) \
		-b _CODE=0x07bc -b _DATA=0xcc31 -b _GSINIT=0x68b6 $(KERNEL_ALIASES) \
		--region 07bc:1926:build/b0_kernel.inc --region 68b6:68c0:build/b1_kernel_init.inc

# the kernel's C in bank 1, $4000-$68B6; its initialized data's _GSINIT code
# follows ccsbcs.c's at $7096
BANK1_SRCS := src/bank1.c
BANK1_ALIASES := -a _DrawString=DrawString -a _U32ToAscii_B0=U32ToAscii_B0 -a _color=StoreDrawParams \
              -a banked_call=FarCallTrampoline -a __initrleblock=RleUnpack -a _memset=Memset \
              -a _memcpy=Memcpy -a _strlen=CStrLen -a _set_data=VramCopyStack \
              -a _fs_open=FarCall_06_7309 -a _fs_read=FarCall_06_779a -a _fs_lseek=FarCall_03_76cc \
              -a _fs_close=FarCall_03_768f -a __modslong_rrx_s=S32Div -a __divslong_rrx_s=S32Mod \
              -a __mullong_rrx_s=U32Mul -a __rrulong_rrx_s=U32Shr -a __moduint_rrx_s=U16Mod \
              -g _wEntries=0xc2a0 -g _wEntryCount=0xc2a2 -g _wPath=0xc2a6 -g _wLabelBuf=0xc4a4 \
              -g _wSaveBuf=0xc0a0 -g _wTmp=0xc3a5 -g _wFil=0xca0f -g _wD3EB=0xd3eb -g _wD3ED=0xd3ed \
              -g _wD3F0=0xd3f0 -g _wD3F2=0xd3f2 -g _wD3EC=0xd3ec -g _wD3EE=0xd3ee -g _wD3EF=0xd3ef \
              -g _wD3F1=0xd3f1 -g _wD3F6=0xd3f6 -g _wFatFs=0xc7a9 -g _wRomBanks=0xc2a4 -g _wHdrSum=0xc5a3 \
              -a _fs_write=FarCall_07_7739 -a _fs_clust2sect=FarCall_05_4279 -a _fs_get_fat=FarCall_05_4378 \
              -a _wait_vbl_done=WaitVBlankFlag -a _joypad=ReadJoypad -a _delay=Delay -a _box=DrawRect \
              -a _strcpy=ApplyBasename -a __rlulong_rrx_s=U32Shl

build/b1_code.inc build/b1_init.inc &: $(BANK1_SRCS) src/ff.h src/ffconf.h src/integer.h tools/sdinc.py $(SYM)
	@mkdir -p build
	$(SDINC) $(BANK1_SRCS) --sdcc29 --bank 1 --cflags="$(KERNEL_CFLAGS)" --sym $(SYM) \
		-b _CODE=0x4000 -b _DATA=0xd3f9 -b _GSINIT=0x7096 $(BANK1_ALIASES) \
		--region 4000:68b6:build/b1_code.inc --region 7096:7390:build/b1_init.inc


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

# GBDK's gb library: the drawing, font and joypad code and the IBM font.
# _BASE is one run in link order; drawing's _CODE comes first in _CODE,
# font's is linked further on, and drawing.s's .vbl/.lcd sit at $2A5F.
# The mode table jumps in drawing's and font's _HEADER land at $03C9 and
# $05B6: stock's linker appended each module's _HEADER after crt0's
# (ending at $01E3) instead of overlaying them, so $01E6 and $01EA, where
# .set_mode jumps, are $FF.
GBDK_SRCS := gbdk/drawing.s gbdk/cpy_data.s gbdk/ibmfixed.s gbdk/pad.s gbdk/delay.s build/font.s gbdk/init_tt.s
GBDK_INCS := build/b0_gbdk_header.inc build/b0_gbdk_code.inc build/b0_gbdk_vbl.inc build/b0_gbdk_font.inc build/b0_gbdk_base.inc

build/font.s: gbdk/font.ms gbdk/wait_hbl.mh tools/maccer.py
	@mkdir -p build
	python3 tools/maccer.py $< $@

$(GBDK_INCS) &: $(GBDK_SRCS) gbdk/global.s build/crt0.sym tools/sdinc.py $(SYM)
	$(SDINC) $(GBDK_SRCS) -I gbdk --bank 0 --sym $(SYM) --defs build/crt0.sym $(CRT0_DEFS) \
		-b _CODE=0x20f4 -b _BASE=0x2eea -b _VBLLCD=0x2a5f -b _BSS=0xd723 --area-at font.s:_CODE=0x2d56 \
		--area-at drawing.s:_HEADER=0x01e3 --area-at font.s:_HEADER=0x03cc \
		--region 01e3:0600:build/b0_gbdk_header.inc \
		--region 20f4:2826:build/b0_gbdk_code.inc --region 2a5f:2a77:build/b0_gbdk_vbl.inc \
		--region 2d56:2d95:build/b0_gbdk_font.inc --region 2eea:4000:build/b0_gbdk_base.inc

# bank 0's asm runtime that is neither SDCC's nor GBDK's, rebuilt from stock
# (origin unknown, see src/libasm.s), in six pieces between other library code
LIBASM_INCS := build/b0_lib0.inc build/b0_lib1.inc build/b0_lib2.inc build/b0_lib3.inc build/b0_lib4.inc build/b0_lib5.inc

$(LIBASM_INCS) &: src/libasm.s tools/sdinc.py $(SYM)
	@mkdir -p build
	$(SDINC) $< --bank 0 --sym $(SYM) -g _errno=0xd6c7 -b _LIB0=0x20e2 \
		-b _LIB1=0x29e6 -b _LIB2=0x2a77 -b _LIB3=0x2ca5 -b _LIB4=0x2d4c -b _LIB5=0x2dba \
		--region 20e2:20f4:build/b0_lib0.inc \
		--region 29e6:2a5f:build/b0_lib1.inc --region 2a77:2c42:build/b0_lib2.inc \
		--region 2ca5:2cd3:build/b0_lib3.inc --region 2d4c:2d56:build/b0_lib4.inc \
		--region 2dba:2eea:build/b0_lib5.inc

# the kernel's C in bank 2, all of it: the SD sector reads and writes
build/b2_code.inc: src/bank2.c src/diskio.h src/integer.h tools/sdinc.py $(SYM)
	@mkdir -p build
	$(SDINC) $< --sdcc29 --bank 2 --cflags="$(KERNEL_CFLAGS)" --sym $(SYM) \
		-b _CODE=0x4000 -a _set_data=VramCopyStack -a _delay=Delay -a __rrulong_rrx_s=U32Shr \
		--region 4000:8000:$@

# the kernel's C in bank 4: RomLoad_InitiatePoll ($4000), linked for $D100
# where RomLoad_BuildAndRunPoll copies it, then the rest from $40AB. SDCC
# 2.9.0 calls __moduschar/__divuschar for a char by a constant, which its
# gbz80 library does not have; stock calls the unsigned ones there.
BANK4_SRCS := src/bank4.c
BANK4_ALIASES := -a _DrawString=DrawString -a _color=StoreDrawParams -a _box=DrawRect \
              -a _joypad=ReadJoypad -a _memset=Memset -a _memcpy=Memcpy -a _set_data=VramCopyStack \
              -a __modulong_rrx_s=U32Div -a __divulong_rrx_s=U32Mod \
              -a __moduchar_rrx_s=U8Mod -a __divuchar_rrx_s=U8Div -a __modschar_rrx_s=S8Mod \
              -a __divschar_rrx_s=S8Div -a banked_call=FarCallTrampoline \
              -a __moduschar_rrx_s=U8Mod -a __divuschar_rrx_s=U8Div \
              -a _RomLoad_InitiatePoll=RomLoad_InitiatePoll -g _wRomBanks=0xc2a4 -g _wHdrSum=0xc5a3 -g _wD3EB=0xd3eb

build/b4_wram.inc: src/bank4_wram.c tools/sdinc.py $(SYM)
	@mkdir -p build
	$(SDINC) $< --sdcc29 --bank 4 --cflags="$(KERNEL_CFLAGS)" --sym $(SYM) \
		-b _CODE=0xd100 --region d100:d1ab:$@

build/b4_code.inc: $(BANK4_SRCS) src/ff.h src/ffconf.h src/integer.h tools/sdinc.py $(SYM)
	@mkdir -p build
	$(SDINC) $(BANK4_SRCS) --sdcc29 --bank 4 --cflags="$(KERNEL_CFLAGS)" --sym $(SYM) \
		-b _CODE=0x40ab $(BANK4_ALIASES) --region 40ab:8000:$@

# the kernel's C in bank 8, all of it
BANK8_SRCS := src/bank8.c
BANK8_ALIASES := -a _DrawString=DrawString -a _color=StoreDrawParams -a _box=DrawRect \
              -a _line=DrawLineXY -a _plot_point=PlotPixelXY -a _set_data=VramCopyStack \
              -a _disable_interrupts=DiNest -a _enable_interrupts=EiNest -a _wait_vbl_done=WaitVBlankFlag \
              -a _joypad=ReadJoypad -a _U32ToAscii_B0=U32ToAscii_B0 -a banked_call=FarCallTrampoline \
              -g _wSaveBuf=0xc0a0

build/b8_code.inc: $(BANK8_SRCS) tools/sdinc.py $(SYM)
	@mkdir -p build
	$(SDINC) $(BANK8_SRCS) --sdcc29 --bank 8 --cflags="$(KERNEL_CFLAGS)" --sym $(SYM) \
		-b _CODE=0x4000 $(BANK8_ALIASES) --region 4000:8000:$@

# SDCC 2.9.0's gbz80 asm library: stubs.s, div.s and shift.s, linked in
# that order. stubs.s jumps to the math in src/libasm.s; div.s has edits
# no SDCC release has.
SDCCASM_SRCS := sdcclib/stubs.s sdcclib/div.s sdcclib/shift.s
SDCCASM_DEFS := -g __mullong=0x2dc1 -g __modslong=0x29e6 -g __modulong=0x2a77 \
              -g __divslong=0x2b28 -g __divulong=0x2bfc -g __mulschar_rrx_s=0x2ba2 \
              -g __muluchar_rrx_s=0x2bb1 -g __mulint_rrx_s=0x2bcf

build/b0_sdccasm.inc: $(SDCCASM_SRCS) tools/sdinc.py $(SYM)
	@mkdir -p build
	$(SDINC) $(SDCCASM_SRCS) --bank 0 --sym $(SYM) -b _CODE=0x2826 $(SDCCASM_DEFS) --region 2826:29e6:$@

# SDCC 2.9.0's crt0_rle.s: __initrleblock, which the C files' _GSINIT code calls
build/b0_rle.inc: sdcclib/crt0_rle.s tools/sdinc.py $(SYM)
	@mkdir -p build
	$(SDINC) $< --bank 0 --sym $(SYM) -b _CODE=0x20bb --region 20bb:20e2:$@

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
