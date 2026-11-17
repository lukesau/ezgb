# RAM the stock C names (kernel/stock/src/mod.h)
MOD_G := -g _hUiMode=0xfffb -g _hPadPrev=0xfff5 -g _hPad=0xfff6 -g _hPadHeld=0xfff7 \
	-g _wEzOp=0xdbfc -g _wEzRes=0xdbfb -g _wBatteryDry=0xdbfd -g _wFlPick=0xdbfe \
	-g _wFlBooted=0xdbff -g _wSetBack=0xdc1c -g _wBrowser=0xdc20 \
	-g _wSetPage=0xdbee -g _wSetRow=0xdc32 -g _wSetDirty=0xdc33

MOD_B0 := asm/SgbStub.s \
	asm/BrowserPoll.s \
	src/cgb_init.c \
	src/popup_params.c \
	asm/SgbVblTail.s \
	asm/LastRomNameStub.s \
	asm/LastRomTickStub.s \
	asm/TabNum12.s \
	asm/BrowserSortAllStub.s \
	asm/FarCallTagLen.s \
	asm/FarCallMarquee.s \
	asm/FarCallDrawLoadingBox.s \
	asm/SgbVblList.s \
	asm/PadWait.s \
	asm/FarCallDrawString12.s \
	asm/VBlankPadLatch.s \
	asm/DrawNameWithIcon.s \
	src/dv_params.c

MOD_B1 := asm/SoOpendir.s \
	asm/SoReaddir.s \
	asm/SoUnlink.s \
	src/save_ops.c \
	asm/SoMatch.s \
	src/patch_guard.c \
	asm/SgbBootHook.s

MOD_B2 := asm/FarCallOpendir_B5.s \
	asm/FarCallReaddir_B5.s \
	asm/FarCallSetPage.s \
	asm/FarCallPatchGuard.s \
	src/theme.c \
	src/fastlaunch.c \
	src/lastrom_box.c \
	src/theme_ramps.c \
	src/theme_pick.c \
	src/ezcfg.c \
	asm/FillRect.s \
	src/fit12_shim.c \
	src/marquee.c \
	src/draw12_shim.c \
	src/tabstrip12.c \
	src/lastrom_name.c \
	asm/FarCallPlayLoad.s \
	src/browser_icons.c

MOD_B4 := asm/FlPickCommitFar.s \
	asm/FarCallThemePage.s \
	asm/StarQueryFar.s \
	asm/StarToggleFar.s \
	asm/TextViewFar.s \
	asm/FarCallMsgBox_B4.s \
	src/rom_menu.c \
	asm/FarCallEzCfg.s \
	asm/FarCallMenuTabs.s \
	asm/SetCommit.s \
	src/bkprompt.c \
	src/settext.c \
	asm/SmSaveOp.s \
	asm/FlCfgJump.s \
	src/setpage.c \
	asm/SkipBootPrep.s \
	asm/ManageSaves.s \
	src/flcfg.c \
	src/save_name.c \
	asm/FarCallPlaySync_B4.s \
	src/setbox.c \
	asm/U32ToAsciiFast.s \
	asm/SgbLaunchHook.s \
	src/tagexample.c \
	src/rec_flag.c

MOD_B5 := src/browser_hide.c \
	src/tagtrim.c \
	src/theme_colors.c \
	src/play.c

MOD_B8 := src/browser_sort.c \
	asm/HideLoadFar.s \
	src/flpick_banner.c \
	src/help_sd.c \
	src/help12.c \
	src/play_mark.c

MOD_B9 := src/fs_unlink.c

MOD_B10 := src/draw12.c \
	src/layout12.c \
	asm/Font12.s \
	asm/Font12Metrics.s \
	asm/Font12Dv.s \
	asm/Font12DvMetrics.s

MOD_B11 := asm/SmSaveOpB11.s \
	src/save_mgr.c \
	src/play_file.c \
	src/msgbox.c

MOD_B12 := src/browser_nav.c \
	src/auto_backup.c

MOD_B13 := src/themepage.c

MOD_B14 := src/textview.c \
	src/hide_list.c

# 1.04e has no date code: the mod's
ifeq ($(K),104)
MOD_B0 += src/fat_date.c
endif
