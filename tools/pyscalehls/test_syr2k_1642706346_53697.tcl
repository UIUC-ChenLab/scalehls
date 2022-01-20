open_project test_syr2k_1642706346_53697
set_top test_syr2k
add_files generated_files/ML_in.c
open_solution "solution1"
set_part { xc7k70tfbv676-1 }
create_clock -period 10 -name default
source generated_files/ML_directive_1642706346_53697

csynth_design

exit