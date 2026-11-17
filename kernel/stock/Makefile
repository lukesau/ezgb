# The stock kernels from source: 1.05e-0918, 1.04e and 1.05e-0731. 0731 is
# the reference: the source was first matched against it, and K0918 and
# K104 in the C mark where the other two differ from it. The build fails unless each result is
# byte-identical to its stock kernel.
#
# The C needs SDCC 2.9.0, the compiler EZ Flash used: SDCC29=<install prefix>,
# by default ../../tools/sdcc-2.9.0 (stage1/decomp/tools/build-sdcc29.sh).
#
#   make            build all three (build-0918/, build-104/, build-0731/kernel.gb),
#                   each checked against ../../stock.sha1
#   make 0918       only 0918 (make 1.04e, make 0731)
#   make MOD=1      the same kernels with banks 10-15 added (build-<K>-mod/,
#                   no stock check): README.md, Extra banks
#   make clean

K ?= 0918
SDCC29 ?= $(abspath ../../tools/sdcc-2.9.0)
export SDCC29
SDINC := python3 tools/sdinc.py

# 0918 is 0731 with RtcDebugDump added to bank 1, so bank 1 from $4C5E on
# is $262 higher: G1-G4 are where its _GSINIT pieces and _GSINITTAIL start
# 1.04e (FW4) is 1.05e without the RTC code (K104 in the C): bank 0's
# library code from $20BB is $3B9 lower, and the runtime globals from
# $D6A7, where 1.05e's day-count tables are, $27 lower. lib and wram map a
# 1.05e address to this kernel's.
ifeq ($(K),104)
SYM       := disassembly/1.04e/kernel.sym
B         := build-104
KDEFS     := -DK104
LSHIFT    := 3b9
WSHIFT    := 27
B0K := 190d
G1 := 5c87
G2 := 5c91
G3 := 6467
G4 := 6729
D1 := d3f2
else ifeq ($(K),0918)
SYM       := disassembly/1.05e-0918/kernel.sym
B         := build-0918
KDEFS     := -DK0918
G1 := 6b18
G2 := 6b22
G3 := 72f8
G4 := 75f2
B0K := 1926
else ifeq ($(K),0731)
SYM       := disassembly/1.05e-0731/kernel.sym
B         := build-0731
KDEFS     :=
G1 := 68b6
G2 := 68c0
G3 := 7096
G4 := 7390
B0K := 1926
else
$(error K=$(K): want 0918, 104 or 0731)
endif
# MOD=1: 16 banks. Banks 10-15 are $$FF, or $(MODSRC)/bank<N>.c where there
# is one. The ten stock banks are the stock bytes.
ifdef MOD
B := $(B)-mod
MODSRC ?= ../mod/banks
MOD_BANKS := 10 11 12 13 14 15
MOD_INCS := $(MOD_BANKS:%=$(B)/mod_b%.inc)
endif

RTC_ALIASES := $(if $(filter 104,$(K)),,-a _SetFpga7FD4_B1=SetFpga7FD4_B1)
D1 ?= d3f9
LSHIFT ?= 0
WSHIFT ?= 0
lib  = $(shell printf %04x $$((0x$(1) - 0x$(LSHIFT))))
wram = $(shell printf %04x $$((0x$(1) - 0x$(WSHIFT))))

# Symbols crt0.s needs that are not in kernel.sym: GBDK's linker-defined
# addresses, and globals that global.s declares but the kernel never uses.
CRT0_DEFS := -g .STACK=0xe000 -g .refresh_OAM=0xff80 -g .OAM=0xc000 \
             -g .init=0 -g .reset=0 -g _main=0

# FatFs R0.11a (src/ff.c): one copy per bank, cut by BANK. Its calls out of
# the bank, under their kernel.sym names.
FF_BANKS   := 3 5 6 7 9
FF_ALIASES := -a _disk_initialize=DiskInitialize -a _disk_status=DiskStatus \
              -a _disk_read=FarCallDiskRead -a _disk_write=FarCallDiskWrite \
              -a _disk_ioctl=ReturnZero \
              -a _ff_convert=MapCp437 -a _ff_wtoupper=WToUpper \
              -a banked_call=FarCallTrampoline -a __mullong_rrx_s=U32Mul \
              -a __divulong_rrx_s=U32Div -a __divuint_rrx_s=U16Div \
              -a __rlulong_rrx_s=U32Shl -a __rrulong_rrx_s=U32Shr
# 1.04e has no clock: its FatFs stamps a fixed date and never calls this
ifneq ($(K),104)
FF_ALIASES += -a _get_fattime=RtcReadPage
endif

INCS := $(B)/crt0_low.inc $(B)/crt0_home.inc $(B)/b1_gsinittail.inc $(B)/b1_kernel_init.inc $(B)/b1_code.inc $(B)/b1_init.inc $(FF_BANKS:%=$(B)/ff_b%.inc) $(B)/b0_fatfs.inc $(B)/b1_ccsbcs_init.inc $(B)/b0_kernel.inc \
        $(B)/b0_strrchr.inc $(B)/b0_strncpy.inc $(B)/b0_strlen.inc $(B)/b0_sdccasm.inc $(B)/b0_rle.inc \
        $(B)/b0_gbdk_header.inc $(B)/b0_gbdk_code.inc $(B)/b0_gbdk_vbl.inc $(B)/b0_gbdk_font.inc $(B)/b0_gbdk_base.inc \
        $(B)/b2_code.inc $(B)/b4_wram.inc $(B)/b4_code.inc $(B)/b8_code.inc $(B)/b0_lib0.inc $(B)/b0_lib1.inc $(B)/b0_lib2.inc $(B)/b0_lib3.inc $(B)/b0_lib4.inc $(B)/b0_lib5.inc

ifeq ($(origin K),file)
all: 0918 1.04e 0731
else
all: $(B)/kernel.gb
endif

0918 0731:
	$(MAKE) K=$@ $(if $(MOD),MOD=1)
1.04e:
	$(MAKE) K=104 $(if $(MOD),MOD=1)

$(B)/crt0_low.inc $(B)/crt0_home.inc $(B)/b1_gsinittail.inc $(B)/crt0.sym &: gbdk/crt0.s gbdk/global.s tools/sdinc.py $(SYM)
	@mkdir -p $(B)
	$(SDINC) gbdk/crt0.s --sym $(SYM) -b _HOME=0x0600 -b _BSS=0x$(call wram,d6c9) $(CRT0_DEFS) \
		-b _GSINIT=0x$(G1) -b _GSINITTAIL=0x$(G4) \
		--region 0000:01e3:$(B)/crt0_low.inc --region 0600:07bc:$(B)/crt0_home.inc \
		--region $(G4):8000:$(B)/b1_gsinittail.inc --syms-out $(B)/crt0.sym

# the whole bank: code from $4000, $FF fill after it, FatFs globals at $C5A5
# banks 5, 6 and 9 link src/dbg.c first
ff_srcs = $(if $(filter 5 6 9,$(1)),src/dbg.c) src/ff.c

$(B)/ff_b%.inc: src/dbg.c src/ff.c src/ff.h src/ffconf.h src/integer.h src/diskio.h tools/sdinc.py $(SYM)
	@mkdir -p $(B)
	$(SDINC) $(call ff_srcs,$*) --sdcc29 --bank $* --cflags "--opt-code-size -DBANK=$* $(KDEFS)" --sym $(SYM) \
		-b _CODE=0x4000 -b _DATA=0xc5a5 $(FF_ALIASES) --region 4000:8000:$@

# bank 0's FatFs glue: the f_ entry points, the disk layer and the RTC clock,
# and the CP437 conversion. ff_wtoupper's tables are WRAM ($CC33): the
# _GSINIT code that fills them is in bank 1, where EZ Flash linked that area.
B0_FATFS_SRCS := src/fsglue.c src/diskio.c src/option/ccsbcs.c
B0_FATFS_ALIASES := -a _f_open=Open_B6 -a _f_read=Read_B6 -a _f_write=Write_B7 \
              -a _f_lseek=Lseek_B3 -a _f_close=Close_B3 -a _f_mkdir=Mkdir_B9 \
              -a _clust2sect=Clust2Sect_B5 -a _get_fat=GetFat_B5 \
              -a _SdRead=SdRead -a _SdWrite=SdWrite -a banked_call=FarCallTrampoline \
              -a __rlulong_rrx_s=U32Shl -a __rrulong_rrx_s=U32Shr -a __initrleblock=RleUnpack

$(B)/b0_fatfs.inc $(B)/b1_ccsbcs_init.inc &: $(B0_FATFS_SRCS) src/ff.h src/ffconf.h src/integer.h src/diskio.h tools/sdinc.py $(SYM)
	@mkdir -p $(B)
	$(SDINC) $(B0_FATFS_SRCS) --sdcc29 --bank 0 --cflags="--opt-code-size $(KDEFS)" --sym $(SYM) \
		-b _CODE=0x$(B0K) -b _DATA=0xcc33 -b _GSINIT=0x$(G2) $(B0_FATFS_ALIASES) \
		--region $(B0K):$(call lib,20bb):$(B)/b0_fatfs.inc --region $(G2):$(G3):$(B)/b1_ccsbcs_init.inc

# the kernel's own C in bank 0, $07BC-$1926, against GBDK 2.96a's headers
KERNEL_CFLAGS := --opt-code-size -I$(CURDIR)/gbdk/include -DBYTE_IS_UNSIGNED=1 $(KDEFS)
KERNEL_SRCS := src/kernel.c
KERNEL_ALIASES := -a _joypad=ReadJoypad -a _delay=Delay -a _plot_point=PlotPixelXY \
              -a _gotogxy=SetTextCursor -a _wrtchr=DrawGlyphAdvance -a _color=StoreDrawParams \
              -a _strlen=CStrLen -a _strcpy=ApplyBasename -a _f_readdir=Readdir_B5 \
              -a _U32ToAscii_B0=U32ToAscii_B0 -a _wDebugTextRow=wDebugTextRow \
              -a _wDebugTextCol=wDebugTextCol -a banked_call=FarCallTrampoline \
              -g _wEntries=0xc2a0 -g _wEntryCount=0xc2a2 -g _wDirEnd=0xc5a4 \
              -g _wFno=0xc9db -g _wDir=0xc9f5 -a _SetFpgaPageAlt_B4=SetFpgaPageAlt_B4 \
              -a _strncpy=Strncpy -a _CStrCat_B1=CStrCat_B1 -a __rrulong_rrx_s=U32Shr \
              -a __modulong_rrx_s=U32Mod -a __divulong_rrx_s=U32Div -g _wLabelBuf=0xc4a4 \
              -a _box=DrawRect -a _memset=Memset -a _memcpy=Memcpy -a _strrchr=Strrchr \
              -a _wait_vbl_done=WaitVBlankFlag -a _display_off=LcdOff -a _disable_interrupts=DiNest \
              -a _f_mount=Mount_B5 -a _f_chdir=Chdir_B5 -a _f_opendir=Opendir_B5 -a _fs_mkdir=FarCall_09_77ff \
              -a _CStrCmp=CStrCmp -a _DrawReadingBox=DrawReadingBox -a _DrawLoadingBox=DrawLoadingBox \
              -a _DrawErrorFileBox=DrawErrorFileBox -a _DrawLastRomButtons=DrawLastRomButtons \
              -a _DrawTimeAutosaveScreen=DrawTimeAutosaveScreen -a _DrawFwVersionScreen=DrawFwVersionScreen \
              -a _DrawBrowserEntries=DrawBrowserEntries -a _DrawBrowserDetail=DrawBrowserDetail \
              -a _BackupSavePrompt=BackupSavePrompt -a _LoaderPrepPath=LoaderPrepPath \
              -a _RomLoaderMain=RomLoaderMain -a _BackupOpenSaverPath=BackupOpenSaverPath \
              -a _LaunchSetup=LaunchSetup -a _SetFpga7F37_B4=SetFpga7F37_B4 $(RTC_ALIASES) \
              -a _SetFpga7FC4_B4=SetFpga7FC4_B4 -a _SetFpgaRomSize_B4=SetFpgaRomSize_B4 \
              -a _SetFpga7FC3_B4=SetFpga7FC3_B4 -a _RomLoad_CopyCmdWindowPoll_B4=RomLoad_CopyCmdWindowPoll_B4 \
              -g _DrawMenuTabs=08:7169 -g _wFatFs=0xc7a9 -g _wPath=0xc2a6 -g _wTmp=0xc3a5 \
              -g _wD3EB=0xd3eb -g _wD3EC=0xd3ec -g _wD3ED=0xd3ed -g _wD3EF=0xd3ef -g _wD3F0=0xd3f0 \
              -g _wD3F6=0xd3f6

# its one initialized global, wMarqueePos, starts _GSINIT ($68B6, bank 1)
$(B)/b0_kernel.inc $(B)/b1_kernel_init.inc &: $(KERNEL_SRCS) src/ff.h src/ffconf.h src/integer.h tools/sdinc.py $(SYM)
	@mkdir -p $(B)
	$(SDINC) $(KERNEL_SRCS) --sdcc29 --bank 0 --cflags="$(KERNEL_CFLAGS)" --sym $(SYM) \
		-b _CODE=0x07bc -b _DATA=0xcc31 -b _GSINIT=0x$(G1) $(KERNEL_ALIASES) \
		--region 07bc:$(B0K):$(B)/b0_kernel.inc --region $(G1):$(G2):$(B)/b1_kernel_init.inc

# the kernel's C in bank 1, $4000-$68B6 ($6B18 in 0918); its initialized
# data's _GSINIT code follows ccsbcs.c's at $7096 ($72F8)
BANK1_SRCS := src/bank1.c
BANK1_ALIASES := -a _DrawString=DrawString -a _U32ToAscii_B0=U32ToAscii_B0 -a _color=StoreDrawParams \
              -a banked_call=FarCallTrampoline -a __initrleblock=RleUnpack -a _memset=Memset \
              -a _memcpy=Memcpy -a _strlen=CStrLen -a _set_data=VramCopyStack \
              -a _fs_open=FarCall_06_7309 -a _fs_read=FarCall_06_779a -a _fs_lseek=FarCall_03_76cc \
              -a _fs_close=FarCall_03_768f -a __modslong_rrx_s=S32Mod -a __divslong_rrx_s=S32Div \
              -a __mullong_rrx_s=U32Mul -a __rrulong_rrx_s=U32Shr -a __moduint_rrx_s=U16Mod \
              -g _wEntries=0xc2a0 -g _wEntryCount=0xc2a2 -g _wPath=0xc2a6 -g _wLabelBuf=0xc4a4 \
              -g _wSaveBuf=0xc0a0 -g _wTmp=0xc3a5 -g _wFil=0xca0f -g _wD3EB=0xd3eb -g _wD3ED=0xd3ed \
              -g _wD3F0=0xd3f0 -g _wD3F2=0xd3f2 -g _wD3EC=0xd3ec -g _wD3EE=0xd3ee -g _wD3EF=0xd3ef \
              -g _wD3F1=0xd3f1 -g _wD3F6=0xd3f6 -g _wFatFs=0xc7a9 -g _wRomBanks=0xc2a4 -g _wHdrSum=0xc5a3 \
              -a _fs_write=FarCall_07_7739 -a _fs_clust2sect=FarCall_05_4279 -a _fs_get_fat=FarCall_05_4378 \
              -a _wait_vbl_done=WaitVBlankFlag -a _joypad=ReadJoypad -a _delay=Delay -a _box=DrawRect \
              -a _strcpy=ApplyBasename -a __rlulong_rrx_s=U32Shl \
              -a _DrawU32Decimal=DrawU32Decimal -a _WaitJoypadSelect=WaitJoypadSelect

$(B)/b1_code.inc $(B)/b1_init.inc &: $(BANK1_SRCS) src/ff.h src/ffconf.h src/integer.h tools/sdinc.py $(SYM)
	@mkdir -p $(B)
	$(SDINC) $(BANK1_SRCS) --sdcc29 --bank 1 --cflags="$(KERNEL_CFLAGS)" --sym $(SYM) \
		-b _CODE=0x4000 -b _DATA=0x$(D1) -b _GSINIT=0x$(G3) $(BANK1_ALIASES) \
		--region 4000:$(G1):$(B)/b1_code.inc --region $(G3):$(G4):$(B)/b1_init.inc


# SDCC 2.9.0's library C among bank 0's library modules, built as SDCC
# builds its device lib: no options
SDCCLIB_INCS := $(B)/b0_strrchr.inc $(B)/b0_strncpy.inc $(B)/b0_strlen.inc

$(B)/b0_strrchr.inc: sdcclib/_strrchr.c tools/sdinc.py $(SYM)
	@mkdir -p $(B)
	$(SDINC) $< --sdcc29 --bank 0 --sym $(SYM) -b _CODE=0x$(call lib,2c42) --region $(call lib,2c42):$(call lib,2ca5):$@

$(B)/b0_strncpy.inc: sdcclib/_strncpy.c tools/sdinc.py $(SYM)
	@mkdir -p $(B)
	$(SDINC) $< --sdcc29 --bank 0 --sym $(SYM) -b _CODE=0x$(call lib,2cd3) --region $(call lib,2cd3):$(call lib,2d4c):$@

$(B)/b0_strlen.inc: sdcclib/_strlen.c tools/sdinc.py $(SYM)
	@mkdir -p $(B)
	$(SDINC) $< --sdcc29 --bank 0 --sym $(SYM) -b _CODE=0x$(call lib,2d95) --region $(call lib,2d95):$(call lib,2dba):$@

# GBDK's gb library: the drawing, font and joypad code and the IBM font.
# _BASE is one run in link order; drawing's _CODE comes first in _CODE,
# font's is linked further on, and drawing.s's .vbl/.lcd sit at $2A5F.
# The mode table jumps in drawing's and font's _HEADER land at $03C9 and
# $05B6: stock's linker appended each module's _HEADER after crt0's
# (ending at $01E3) instead of overlaying them, so $01E6 and $01EA, where
# .set_mode jumps, are $FF.
GBDK_SRCS := gbdk/drawing.s gbdk/cpy_data.s gbdk/ibmfixed.s gbdk/pad.s gbdk/delay.s $(B)/font.s gbdk/init_tt.s
GBDK_INCS := $(B)/b0_gbdk_header.inc $(B)/b0_gbdk_code.inc $(B)/b0_gbdk_vbl.inc $(B)/b0_gbdk_font.inc $(B)/b0_gbdk_base.inc

$(B)/font.s: gbdk/font.ms gbdk/wait_hbl.mh tools/maccer.py
	@mkdir -p $(B)
	python3 tools/maccer.py $< $@

$(GBDK_INCS) &: $(GBDK_SRCS) gbdk/global.s $(B)/crt0.sym tools/sdinc.py $(SYM)
	$(SDINC) $(GBDK_SRCS) -I gbdk --bank 0 --sym $(SYM) --defs $(B)/crt0.sym $(CRT0_DEFS) \
		-b _CODE=0x$(call lib,20f4) -b _BASE=0x$(call lib,2eea) -b _VBLLCD=0x$(call lib,2a5f) -b _BSS=0x$(call wram,d723) --area-at font.s:_CODE=0x$(call lib,2d56) \
		--area-at drawing.s:_HEADER=0x01e3 --area-at font.s:_HEADER=0x03cc \
		--region 01e3:0600:$(B)/b0_gbdk_header.inc \
		--region $(call lib,20f4):$(call lib,2826):$(B)/b0_gbdk_code.inc --region $(call lib,2a5f):$(call lib,2a77):$(B)/b0_gbdk_vbl.inc \
		--region $(call lib,2d56):$(call lib,2d95):$(B)/b0_gbdk_font.inc --region $(call lib,2eea):4000:$(B)/b0_gbdk_base.inc

# bank 0's asm runtime that is neither SDCC's nor GBDK's, rebuilt from stock
# (origin unknown, see src/libasm.s), in six pieces between other library code
LIBASM_INCS := $(B)/b0_lib0.inc $(B)/b0_lib1.inc $(B)/b0_lib2.inc $(B)/b0_lib3.inc $(B)/b0_lib4.inc $(B)/b0_lib5.inc

$(LIBASM_INCS) &: src/libasm.s tools/sdinc.py $(SYM)
	@mkdir -p $(B)
	$(SDINC) $< --bank 0 --sym $(SYM) -g _errno=0x$(call wram,d6c7) -b _LIB0=0x$(call lib,20e2) \
		-b _LIB1=0x$(call lib,29e6) -b _LIB2=0x$(call lib,2a77) -b _LIB3=0x$(call lib,2ca5) -b _LIB4=0x$(call lib,2d4c) -b _LIB5=0x$(call lib,2dba) \
		--region $(call lib,20e2):$(call lib,20f4):$(B)/b0_lib0.inc \
		--region $(call lib,29e6):$(call lib,2a5f):$(B)/b0_lib1.inc --region $(call lib,2a77):$(call lib,2c42):$(B)/b0_lib2.inc \
		--region $(call lib,2ca5):$(call lib,2cd3):$(B)/b0_lib3.inc --region $(call lib,2d4c):$(call lib,2d56):$(B)/b0_lib4.inc \
		--region $(call lib,2dba):$(call lib,2eea):$(B)/b0_lib5.inc

# the kernel's C in bank 2, all of it: the SD sector reads and writes
$(B)/b2_code.inc: src/bank2.c src/diskio.h src/integer.h tools/sdinc.py $(SYM)
	@mkdir -p $(B)
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
              -a __modulong_rrx_s=U32Mod -a __divulong_rrx_s=U32Div \
              -a __moduchar_rrx_s=U8Mod -a __divuchar_rrx_s=U8Div -a __modschar_rrx_s=S8Mod \
              -a __divschar_rrx_s=S8Div -a banked_call=FarCallTrampoline \
              -a __moduschar_rrx_s=U8Mod -a __divuschar_rrx_s=U8Div \
              -a _wait_vbl_done=WaitVBlankFlag \
              -a _RomLoad_InitiatePoll=RomLoad_InitiatePoll -g _wRomBanks=0xc2a4 -g _wHdrSum=0xc5a3 -g _wD3EB=0xd3eb

$(B)/b4_wram.inc: src/bank4_wram.c tools/sdinc.py $(SYM)
	@mkdir -p $(B)
	$(SDINC) $< --sdcc29 --bank 4 --cflags="$(KERNEL_CFLAGS)" --sym $(SYM) \
		-b _CODE=0xd100 --region d100:d1ab:$@

$(B)/b4_code.inc: $(BANK4_SRCS) src/ff.h src/ffconf.h src/integer.h tools/sdinc.py $(SYM)
	@mkdir -p $(B)
	$(SDINC) $(BANK4_SRCS) --sdcc29 --bank 4 --cflags="$(KERNEL_CFLAGS)" --sym $(SYM) \
		-b _CODE=0x40ab $(BANK4_ALIASES) --region 40ab:8000:$@

# the kernel's C in bank 8, all of it
BANK8_SRCS := src/bank8.c
BANK8_ALIASES := -a _DrawString=DrawString -a _color=StoreDrawParams -a _box=DrawRect \
              -a _line=DrawLineXY -a _plot_point=PlotPixelXY -a _set_data=VramCopyStack \
              -a _disable_interrupts=DiNest -a _enable_interrupts=EiNest -a _wait_vbl_done=WaitVBlankFlag \
              -a _joypad=ReadJoypad -a _U32ToAscii_B0=U32ToAscii_B0 -a banked_call=FarCallTrampoline \
              -g _wSaveBuf=0xc0a0

$(B)/b8_code.inc: $(BANK8_SRCS) tools/sdinc.py $(SYM)
	@mkdir -p $(B)
	$(SDINC) $(BANK8_SRCS) --sdcc29 --bank 8 --cflags="$(KERNEL_CFLAGS)" --sym $(SYM) \
		-b _CODE=0x4000 $(BANK8_ALIASES) --region 4000:8000:$@

# SDCC 2.9.0's gbz80 asm library: stubs.s, div.s and shift.s, linked in
# that order. stubs.s jumps to the math in src/libasm.s; div.s has edits
# no SDCC release has.
SDCCASM_SRCS := sdcclib/stubs.s sdcclib/div.s sdcclib/shift.s
SDCCASM_DEFS := -g __mullong=0x$(call lib,2dc1) -g __modslong=0x$(call lib,29e6) -g __modulong=0x$(call lib,2a77) \
              -g __divslong=0x$(call lib,2b28) -g __divulong=0x$(call lib,2bfc) -g __mulschar_rrx_s=0x$(call lib,2ba2) \
              -g __muluchar_rrx_s=0x$(call lib,2bb1) -g __mulint_rrx_s=0x$(call lib,2bcf)

$(B)/b0_sdccasm.inc: $(SDCCASM_SRCS) tools/sdinc.py $(SYM)
	@mkdir -p $(B)
	$(SDINC) $(SDCCASM_SRCS) --bank 0 --sym $(SYM) -b _CODE=0x$(call lib,2826) $(SDCCASM_DEFS) --region $(call lib,2826):$(call lib,29e6):$@

# SDCC 2.9.0's crt0_rle.s: __initrleblock, which the C files' _GSINIT code calls
$(B)/b0_rle.inc: sdcclib/crt0_rle.s tools/sdinc.py $(SYM)
	@mkdir -p $(B)
	$(SDINC) $< --bank 0 --sym $(SYM) -b _CODE=0x$(call lib,20bb) --region $(call lib,20bb):$(call lib,20e2):$@

# a bank of the mod's C, built like the kernel's. It links against stock
# under kernel.sym's names (-a where the C name differs) and against the
# banks below it. $$FF with no source: rgblink fills the section.
MOD_ALIASES := -a banked_call=FarCallTrampoline -a _color=StoreDrawParams -a _box=DrawRect \
              -a _line=DrawLineXY -a _plot_point=PlotPixelXY -a _set_data=VramCopyStack \
              -a _joypad=ReadJoypad -a _delay=Delay -a _wait_vbl_done=WaitVBlankFlag \
              -a _disable_interrupts=DiNest -a _enable_interrupts=EiNest \
              -a _strlen=CStrLen -a _strcpy=ApplyBasename

define mod_bank
$(B)/mod_b$(1).inc: $(wildcard $(MODSRC)/bank$(1).c) $(2:%=$(B)/mod_b%.inc) tools/sdinc.py $(SYM)
	@mkdir -p $(B)
ifneq ($(wildcard $(MODSRC)/bank$(1).c),)
	$(SDINC) $(MODSRC)/bank$(1).c --sdcc29 --bank $(1) --cflags="$(KERNEL_CFLAGS)" --sym $(SYM) \
		--auto-alias $(MOD_ALIASES) $(2:%=--defs $(B)/mod_b%.sym) -b _CODE=0x4000 \
		--region 4000:8000:$$@ --syms-out $(B)/mod_b$(1).sym
else
	: > $(B)/mod_b$(1).sym
	echo '; bank $(1): no source' > $$@
endif
endef
MOD_PREV :=
$(foreach n,$(MOD_BANKS),$(eval $(call mod_bank,$(n),$(MOD_PREV)))$(eval MOD_PREV += $(n)))

$(B)/kernel.gb: asm/game.asm asm/mod.asm asm/bank_*.asm asm/*.inc $(INCS) $(MOD_INCS)
	rgbasm $(if $(MOD),-D MOD) -I asm/ -I $(B)/ -o $(B)/game.o asm/game.asm
	rgblink $(if $(MOD),-p 0xff) -n $(B)/kernel.sym -m $(B)/kernel.map -o $@ $(B)/game.o
	rgbfix -Wno-overwrite -f g $@
ifdef MOD
	@echo "$@: $$(($$(wc -c < $@) / 16384)) banks"
else
	@want=$$(awk '$$2 == "*kernel/stock/$@" { print $$1 }' ../../stock.sha1); \
	got=$$( (shasum $@ 2>/dev/null || sha1sum $@) | cut -d' ' -f1); \
	if [ -n "$$want" ] && [ "$$got" = "$$want" ]; then echo "$@: matches stock ($$got)"; \
	else echo "$@: MISMATCH ($$got, want $$want)"; exit 1; fi
endif

clean:
	rm -rf build-0918 build-104 build-0731 build-0918-mod build-104-mod build-0731-mod

.PHONY: all clean 0918 1.04e 0731

# a kernel that fails the hash check must not count as up to date
.DELETE_ON_ERROR:
