"""What the kernel is built from: every source, by bank (tools/build.py).

A group is a set of sources that share a bank, compiler flags and RAM.
Sources under base/ are built with SDCC 2.9.0, the rest with a current SDCC;
.s files are assembled. Within a bank the code is laid out in the order
given here.

data: where a group's variables go. EZ Flash's code and the mod both use
fixed RAM addresses all over, so each group's variables stay where the
stock kernel has them.
"""

K = "--opt-code-size -Ibase/gbdk/include -DBYTE_IS_UNSIGNED=1"
FF = "--opt-code-size -DBANK=%d"


def group(name, bank, srcs, cflags="", data=None):
    return dict(name=name, bank=bank, srcs=srcs.split(), cflags=cflags, data=data or {})


GROUPS = [
    # bank 0. crt0 comes first: its vectors and header, and the start of
    # the startup code that fills initialized variables
    group("crt0", 0, "base/gbdk/crt0.s", data={"_BSS": 0xd6c9}),
    group("kernel", 0, "base/src/kernel.c", K, {"_DATA": 0xcc31}),
    group("fatfs0", 0, "base/src/fsglue.c base/src/diskio.c base/src/option/ccsbcs.c",
          "--opt-code-size", {"_DATA": 0xcc33}),
    group("rle", 0, "base/sdcclib/crt0_rle.s"),
    group("libasm", 0, "base/src/libasm.s"),
    group("sdccasm", 0, "base/sdcclib/stubs.s base/sdcclib/div.s base/sdcclib/shift.s"),
    group("strrchr", 0, "base/sdcclib/_strrchr.c"),
    group("strncpy", 0, "base/sdcclib/_strncpy.c"),
    group("strlen", 0, "base/sdcclib/_strlen.c"),
    group("gbdk", 0, """
        base/gbdk/drawing.s base/gbdk/cpy_data.s base/gbdk/ibmfixed.s base/gbdk/pad.s
        base/gbdk/delay.s build/font.s base/gbdk/init_tt.s
        asm/SgbStub.s asm/Bcall.s src/lastrom_tick.c asm/BrowserPoll.s src/cgb_init.c
        src/popup_params.c asm/SgbVblTail.s asm/SgbVblList.s asm/PadWait.s
        asm/VBlankPadLatch.s src/dv_params.c""", data={"_BSS": 0xd723}),

    group("bank1", 1, "base/src/bank1.c src/save_ops.c src/patch_guard.c asm/SgbBootHook.s",
          K, {"_DATA": 0xd3f9}),

    group("bank2", 2, """
        base/src/bank2.c src/theme.c src/fastlaunch.c src/lastrom_box.c src/theme_ramps.c
        src/theme_pick.c src/ezcfg.c asm/FillRect.s src/fit12_shim.c src/marquee.c
        src/draw12_shim.c src/tabstrip12.c src/lastrom_name.c src/browser_icons.c""", K),

    # FatFs R0.11a: one cut of ff.c per bank, sharing its variables
    group("ff3", 3, "base/src/ff.c", FF % 3, {"_DATA": 0xc5a5}),

    # the loader routine that runs from RAM: linked for $D100, stored at 04:4000
    group("bank4ram", 4, "base/src/bank4_wram.c", K),
    group("bank4", 4, """
        base/src/bank4.c src/rom_menu.c src/bkprompt.c src/settext.c src/setpage.c
        asm/SkipBootPrep.s src/flcfg.c src/save_name.c src/setbox.c asm/U32ToAsciiFast.s
        asm/SgbLaunchHook.s src/tagexample.c src/rec_flag.c""", K),

    group("ff5", 5, """
        base/src/dbg.c base/src/ff.c src/browser_hide.c src/tagtrim.c src/theme_colors.c
        src/play.c""", FF % 5, {"_DATA": 0xc5a5}),
    group("ff6", 6, "base/src/dbg.c base/src/ff.c", FF % 6, {"_DATA": 0xc5a5}),
    group("ff7", 7, "base/src/ff.c", FF % 7, {"_DATA": 0xc5a5}),

    group("bank8", 8, """
        base/src/bank8.c src/browser_sort.c src/flpick_banner.c src/help_sd.c src/help12.c
        src/play_mark.c""", K),

    group("ff9", 9, "base/src/dbg.c base/src/ff.c src/fs_unlink.c", FF % 9, {"_DATA": 0xc5a5}),

    # banks stock does not have
    group("bank10", 10, "src/draw12.c src/layout12.c asm/Font12.s"),
    group("bank11", 11, "src/save_mgr.c src/play_file.c src/msgbox.c"),
    group("bank12", 12, "src/browser_nav.c src/auto_backup.c"),
    group("bank13", 13, "src/themepage.c"),
    group("bank14", 14, "src/textview.c src/hide_list.c"),
]

BANKS = 16

# The loader routine above: where it is linked to run, and where in the ROM
# it is stored. The rest of bank 4 starts right after it.
RAM_CODE = dict(group="bank4ram", run=0xd100, bank=4, at=0x4000, size=0xab)

# A name that several groups define, for a group that defines none of its
# own: which group's it means.
PREFER = {"_clust2sect": "ff5", "_get_fat": "ff5"}
