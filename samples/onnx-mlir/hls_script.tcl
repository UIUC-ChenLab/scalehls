set name [lindex $argv 0]
set file [lindex $argv 1]
set proj [lindex $argv 2]

open_project $proj
set_top $name
add_files $file
open_solution $name
set_part {xcvu9p-flga2104-2L-e} -tool vivado
create_clock -period 5 -name default
#csim_design
csynth_design
#cosim_design
close_project
