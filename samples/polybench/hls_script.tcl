set name [lindex $argv 0]
set file [lindex $argv 1]
set proj [lindex $argv 2]

open_project $proj
set_top $name
add_files $file
open_solution $name
set_part {xc7z020-clg400-1} -tool vivado
create_clock -period 10 -name default
#csim_design
csynth_design
#cosim_design
close_project
