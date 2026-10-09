#!/bin/bash
# Build and run every DAT0-3 ordering of P25 P29 P30 P34 in parallel (12 at a
# time), each doing the GB-side sd_read; prints which orderings match card.img.
# usage: datvariants.sh GB_START_NS RUN_NS   (run from fw4/vl/fast)
START=${1:-31000000}; RUN=${2:-34000000}
PERMS=$(python3 -c "
import itertools
for p in itertools.permutations(['P25','P29','P30','P34']): print('_'.join(p))")
run_one() {
    p=$1; d=dat_$p; mkdir -p $d
    v="{$(echo $p | tr _ '\n' | tac | paste -sd, -)}"   # DAT[3:0] = {DAT3,...,DAT0}
    verilator --binary --timing -j 2 -Wno-fatal -Wno-lint -Wno-style \
        +define+RUN_NS=$RUN +define+GB_START_NS=$START "+define+SD_DAT=$v" \
        '+define+GB_TEST="gb_sdread.vh"' --top-module tb --Mdir $d/obj -o simv \
        ../s3prims.v ../models.v ../pinmon.v ../tb_pcmap.v ../design_di.v ../tb_full.v > $d/build.log 2>&1
    ./$d/obj/simv > $d/run.log 2>&1
    echo "DAT0..3 = ${p//_/ }: $(grep 'gb: sector' $d/run.log | sed 's/.*gb: //' || true) $(grep -c 'sd: read block' $d/run.log) block reads"
}
export -f run_one; export START RUN
echo "$PERMS" | xargs -P 12 -I{} bash -c 'run_one {}'
