# ======================================================================
#  ezgb (new_kernel_en)  -  build with GBDK-2020 / SDCC 4.5.1
#  --------------------------------------------------------------------
#  Toolchain : tools/gbdk-2020-4.5.0          (override: make GBDK=...)
#  Sources   : source/  (.c/.h)
#  Attic     : attic/   (unused copies, not built)
#  Build dir : build/    intermediates (LANG=en)
#              build/zh  intermediates (LANG=zh) - kept apart so the two
#                        languages can never link each other's objects
#  Release   : release/  ezgb.dat                    (LANG=en)
#                        ezgb_zh.dat                 (LANG=zh)
#              only .dat is produced - that is the name the flasher expects
#
#  Language  : LANG=en  (default)  the 1.06e image, byte for byte
#              LANG=zh            same image + Chinese file names
#
#              en: 10 ROM banks, fatfs code page 437, 8x8 tile list
#              zh: 26 ROM banks, fatfs code page 936, 12px pixel list
#                  (banks 10-21 GB2312 font, 22-25 code page tables)
#
#  Targets   : all (default, follows LANG) | both | clean | distclean
#  Note      : run with GNU make inside an sh-capable shell (MSYS2/Git Bash)
# ======================================================================

GBDK  ?= ../../tools/gbdk-2020-4.5.0/gbdk
LCC   := $(GBDK)/bin/lcc
REL   := release

# ---- language switch -------------------------------------------------
#  LANG=en must compile/link exactly like 1.06e: no -D, unchanged source list.
#  Check: make (default en) writes release/en/ezgb.dat with the expected md5.
LANG  ?= en

ifeq ($(LANG),zh)
  BUILD    := build/zh
  PROG     := ezgb_zh
  RELDIR   := $(REL)/zh
  ROMBANKS := -Wm-yo30
  LANGDEF  := -DLANG_ZH
  # extra objects for the zh build: pixel font engine + GB2312 font + cp936 tables
  # ui_zh_fast.s: bank 2 assembly glyph writer (zh only)
  LANG_SRCS := ui_zh_home ui_zh ui_zh_fast asc12x6 list_zh
  LANG_SRCS += hzk12_0 hzk12_1 hzk12_2 hzk12_3 hzk12_4 hzk12_5 \
               hzk12_6 hzk12_7 hzk12_8 hzk12_9 hzk12_10 hzk12_11
  LANG_SRCS += cp936_0 cp936_1 cp936_2 cp936_3 cp936_4 cp936_5 cp936_6 cp936_7
else
  BUILD    := build
  PROG     := ezgb
  RELDIR   := $(REL)/en
  ROMBANKS := -Wm-yo10
  LANGDEF  :=
  # en only: fast rectangle fill (bank 1) replacing per-pixel box(M_FILL)
  LANG_SRCS := fill_fast
endif

# modules - order is link order, do not reorder
SRCS := main ezgb_hw diskio ff ff_1 ff_2 ff_3 ff_4 ffunicode \
        SD_operate GBcard_OP RTC Help UI Bank_fun
SRCS += $(LANG_SRCS)

OBJS   := $(addprefix $(BUILD)/,$(addsuffix .o,$(SRCS)))
TARGET := $(BUILD)/$(PROG).dat
#  Deliverables go straight to release/en/ or release/zh/, both named ezgb.dat
RELDAT := $(RELDIR)/ezgb.dat

#  EXTRA_DEFS: extra macros for debug builds that never reach the release, e.g.
#
#  Compile flags:
#  -Wf--include=port_types.h  force BYTE back to unsigned (GBDK-2020 defines
#                             it as signed char, which breaks FatFs' DDEM
#                             (0xE5) directory-entry checks)
CFLAGS := -Isource -Wf--include=port_types.h $(LANGDEF) $(EXTRA_DEFS)

#  Link flags:
#  $(ROMBANKS)      en: 10 banks => 163840 bytes
#                   zh: 26 banks => 425984 bytes
#  -Wm-yt0x01      MBC1 cartridge
#  -Wm-yn"EZGB"    cartridge title
#  -Wl-b_CODE=0x600  keep 0x0200-0x05FF reserved, same as the original ROM
LDFLAGS := $(ROMBANKS) -Wm-yt0x01 -Wm-yn"EZGB" -Wl-b_CODE=0x600

all: checktext $(RELDAT)

#  Build both languages one after the other (each in its own obj dir).
both:
	$(MAKE) LANG=en all
	$(MAKE) LANG=zh all

#  UI text width check: strings in ui_text.h must fit the dialog / screen.
#  Skipped (with a warning) when python is not on PATH.
checktext:
	@if command -v python3 >/dev/null 2>&1; then \
		python3 tools/check_ui_text.py || exit 1; \
	else echo "[WARN] python not found - ui_text width check skipped"; fi

$(BUILD):
	-mkdir -p $(BUILD)

$(REL):
	-mkdir -p $(REL)

#  lcc returns 0 even when the compiler subprocess fails, so a failed compile
#  must not be masked by a stale .o. Two guards:
#    1) delete the old .o first - prefixed with '-' because on some MSYS2
#       setups rm cannot delete files written by the Windows lcc.exe
#       (the build still works, so the failure is not fatal);
#    2) after compiling, require the .o to exist AND to be newer than the .c,
#       which catches the "rm failed, compile failed, stale .o left" case.
#  Every .o depends on every .h. Crude but necessary: ZH_ROWS / ZH_COLS / ZH_PITCH
#  in ui_zh.h decide the generated coordinates, so editing a header without
#  recompiling leaves a ROM with stale values that looks like a rendering bug.
#  (Seen: changing the row count only relinked, md5 stayed the same.)
HEADERS := $(wildcard source/*.h)

$(BUILD)/%.o : source/%.c $(HEADERS) | $(BUILD)
	-@rm -f $@
	$(LCC) -c -o $@ $< $(CFLAGS)
	@test -f $@ -a $@ -nt $< || { echo "[ERROR] compile failed: $<"; exit 1; }

#  Font / code-page blobs: a .s that does nothing but .incbin the .bin and
#  puts it in its own _CODE_<n> bank.  Nothing else may live in that file,
#  otherwise the bank does not start at the window base and every glyph
#  address would be off.
$(BUILD)/%.o : source/%.s | $(BUILD)
	-@rm -f $@
	$(LCC) -c -o $@ $<
	@test -f $@ -a $@ -nt $< || { echo "[ERROR] assemble failed: $<"; exit 1; }

$(TARGET): $(OBJS) | $(BUILD)
	$(LCC) -o $@ $(OBJS) $(LDFLAGS)

# publish: .dat only (the name the flasher expects)
$(RELDAT): $(TARGET) | $(REL)
	-mkdir -p $(RELDIR)
	cp -f $< $@

clean:
	-rm -f $(BUILD)/*.o $(BUILD)/*.dat $(BUILD)/*.gbc $(BUILD)/*.map \
	       $(BUILD)/*.ihx $(BUILD)/*.sym $(BUILD)/*.asm $(BUILD)/*.lst \
	       $(BUILD)/*.noi $(BUILD)/*.cdb

distclean: clean
	-rm -f $(REL)/en/ezgb.dat $(REL)/zh/ezgb.dat
	-rm -f $(REL)/ezgb.dat $(REL)/ezgb_zh.dat	# leftovers of the old layout
	-rm -f $(REL)/ezgb.gbc $(REL)/ezgb_zh.gbc

.PHONY: all both checktext clean distclean
