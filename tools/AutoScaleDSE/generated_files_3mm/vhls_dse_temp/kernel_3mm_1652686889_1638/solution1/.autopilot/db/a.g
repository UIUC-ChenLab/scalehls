#!/bin/sh
lli=${LLVMINTERP-lli}
exec $lli \
    /home/gregcsl/Desktop/scalehls/tools/AutoScaleDSE/generated_files_3mm/vhls_dse_temp/kernel_3mm_1652686889_1638/solution1/.autopilot/db/a.g.bc ${1+"$@"}
