# Stage1 into slot B, then the updater, in one step. Each step is
# stage0/tools/build-stage1-updater.sh; the build host runs s3patch
# (stage0/docs/setup.md). Outputs go in fpga/stage1/ (ignored).
#
#   make updaters BUILD_HOST=<host>     Update-fw4.gb and Update-fw5-0918.gb
#   make check-slotb BUILD_HOST=<host>  the stock stage1, built from source, in
#                                       stock slot B: must give stock's bitstream
#   make stage0 BUILD_HOST=<host>       slot B built from the readable Verilog
#                                       with ISE, proved equivalent to stock,
#                                       with stage1 in it: Update-fw4-ise.gb and
#                                       Update-fw5-0918-ise.gb (stage0/ise/README.md;
#                                       FW5 needs stage0/tools/fw5-prove.sh run first)
#   make stage0-stock BUILD_HOST=<host> the stock firmware from source: both
#                                       slot B images with the stock stage1 and
#                                       PicoBlaze programs, proved equivalent to
#                                       stock (fpga/ise/<fw>-stock-nopatch/proj/top.raw).
#                                       PROVE=0 skips the proof and needs no
#                                       file of EZ Flash's
#
# STAGE1=stock builds the updaters with the stock stage1 from source instead of
# ours; PATCHES=0 leaves the PicoBlaze programs stock.

MOD := $(shell sed -n 2p stage1/VERSION)
OUT := fpga/stage1
export STAGE1 PATCHES PROVE UPDATER BUILD_HOST

updaters: $(OUT)/Update-fw4.gb $(OUT)/Update-fw5-0918.gb

$(OUT)/Update-fw4.gb: FORCE
	stage0/tools/build-stage1-updater.sh fw4 "To FW4-MOD $(MOD)" $@

$(OUT)/Update-fw5-0918.gb: FORCE
	stage0/tools/build-stage1-updater.sh fw5-0918 "To FW5-MOD $(MOD)" $@

stage0: $(OUT)/Update-fw4-ise.gb $(OUT)/Update-fw5-0918-ise.gb

$(OUT)/Update-fw4-ise.gb: FORCE
	stage0/tools/build-stage0.sh fw4 "FW4 ISE MOD $(MOD)" $@

$(OUT)/Update-fw5-0918-ise.gb: FORCE
	stage0/tools/build-stage0.sh fw5-0918 "FW5 ISE MOD $(MOD)" $@

stage0-stock:
	STAGE1=stock PATCHES=0 stage0/tools/build-stage0.sh fw4
	STAGE1=stock PATCHES=0 stage0/tools/build-stage0.sh fw5-0918

check-slotb:
	STAGE1=stock PATCHES=0 stage0/tools/build-stage1-updater.sh fw4
	STAGE1=stock PATCHES=0 stage0/tools/build-stage1-updater.sh fw5-0918

FORCE:
.PHONY: updaters check-slotb stage0 stage0-stock FORCE
