# Stock stage1 in C, FW4 and FW5-0918 from one source (-DFW=4 / -DFW=5),
# linked against the stock disassembly into a runnable stage1.gb. Not
# byte-exact: the C is compiled by SDCC 4, not EZ Flash's compiler.
#
#   make            build/fw4/stage1.gb and build/fw5/stage1.gb
#   make clean

SRCS := $(wildcard src/*.c src/*.s src/*.h)

all: build/fw4/stage1.gb build/fw5/stage1.gb

build/fw4/stage1.gb: $(SRCS) tools/link.py ../fw4/kernel.sym ../fw4/disassembly/bank_000.asm ../fw4/disassembly/bank_001.asm
	python3 tools/link.py fw4

build/fw5/stage1.gb: $(SRCS) tools/link.py ../fw5-0918/kernel.sym ../fw5-0918/disassembly/bank_000.asm ../fw5-0918/disassembly/bank_001.asm
	python3 tools/link.py fw5-0918

clean:
	rm -rf build

.PHONY: all clean
.DELETE_ON_ERROR:
