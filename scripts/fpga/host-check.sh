#!/bin/sh
# Check a shared build host before running anything on it. ubuntu-compute is
# shared: model benchmarks and a friend's GPU/CPU jobs can be running unannounced.
# Prints the load, other users' busiest processes and GPU jobs, then exits 1
# only if the CPU is maxed out: fewer than MIN_IDLE_CORES (default 2) cores
# idle over a one-second sample. GPU jobs don't block; the stage1 tools are
# CPU only. HOST_CHECK_FORCE=1 runs anyway.
#
#   scripts/fpga/host-check.sh <host>
set -e
host=${1:?usage: host-check.sh <host>}
min=${MIN_IDLE_CORES:-2}
ssh "$host" "min=$min; me=\$(id -un)"'
n=$(nproc)
a=$(head -1 /proc/stat); sleep 1; b=$(head -1 /proc/stat)
idle=$(echo "$a
$b" | awk -v n="$n" "{t = 0; for (i = 2; i <= NF; i++) t += \$i; T[NR] = t; I[NR] = \$5 + \$6}
    END {printf \"%.1f\", n * (I[2] - I[1]) / (T[2] - T[1])}")
echo "$(hostname): load $(cut -d" " -f1-3 /proc/loadavg), $idle of $n cores idle, $(free -g | awk "/^Mem/ {print \$7}") GiB available"
ps -eo user,pcpu,etime,comm --sort=-pcpu | awk -v me="$me" "NR > 1 && \$1 != me && \$1 != \"root\" && \$2 >= 5 {print \"  \" \$0}" | head -5
gpu=$(nvidia-smi --query-compute-apps=pid,process_name,used_memory --format=csv,noheader 2>/dev/null | sort -u -t, -k1,1)
[ -n "$gpu" ] && printf "GPU jobs (not blocking):\n%s\n" "$gpu" | sed "2,\$s/^/  /"
awk -v i="$idle" -v m="$min" "BEGIN {exit !(i >= m)}"
' && exit 0
if [ "${HOST_CHECK_FORCE:-}" = 1 ]; then
    echo "$host CPU is maxed out; running anyway (HOST_CHECK_FORCE=1)" >&2
    exit 0
fi
echo "$host CPU is maxed out; not running there (HOST_CHECK_FORCE=1 to override)" >&2
exit 1
