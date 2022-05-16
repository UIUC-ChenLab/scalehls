open_project kernel_3mm_eval
set_top kernel_3mm
add_files tiled_target.cpp
open_solution "solution1"
set_part { xc7k70tfbv676-1 }
create_clock -period 10 -name default

csynth_design

exit