foreach file [glob -directory "../cpp_src" -- "*.cpp"] {
  set begin [string first "test_" $file]
  set end [expr [string first ".mlir" $file] - 1]
  set name [string range $file $begin $end]

  open_project $name
  set_top $name
  add_files $file
  open_solution $name
  set_part {xc7z020-clg400-1} -tool vivado
  create_clock -period 10 -name default
  #csim_design
  csynth_design
  #cosim_design
  close_project
}
