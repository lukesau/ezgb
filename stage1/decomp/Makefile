# Stock stage1 in C, FW4 and FW5-0918 from one source (-DFW=4 / -DFW=5).
# Not byte-exact: this checks that the C compiles, for both firmwares.
#
#   make            compile every file for fw4 and fw5 into build/
#   make clean

SDCC   := sdcc
CFLAGS := -msm83 --opt-code-size -Isrc
SRCS   := $(wildcard src/*.c)
HDRS   := $(wildcard src/*.h)
FWS    := 4 5

RELS := $(foreach fw,$(FWS),$(patsubst src/%.c,build/fw$(fw)/%.rel,$(SRCS)))

all: $(RELS)

define fw_rule
build/fw$(1)/%.rel: src/%.c $(HDRS)
	@mkdir -p $$(@D)
	$$(SDCC) $$(CFLAGS) -DFW=$(1) -c $$< -o $$@
endef
$(foreach fw,$(FWS),$(eval $(call fw_rule,$(fw))))

clean:
	rm -rf build

.PHONY: all clean
