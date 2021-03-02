#!/bin/bash

# Please run: source dse_test_run.sh -c 0

# Script options.
while getopts 'n:c:' opt
do
  case $opt in
    c) rerun_csynth_from=$OPTARG ;;
  esac
done

# Create directories.
if [ ! -d "cpp_src" ]
then
  mkdir cpp_src
fi

if [ ! -d "dump_csv" ]
then
  mkdir dump_csv
fi

if [ ! -d "hls_proj" ]
then
  mkdir hls_proj
fi

config=../../../config/target-spec.ini

for file in ../../polybench/*
do
  name=${file##*polybench/}
  name=${name%.mlir*}

  output="cpp_src/${name}.cpp"
  dse_output="cpp_src/${name}_dse.cpp"
  dse_dump="dump_csv/${name}_dse.csv"

  echo -e "########## TESTING BENCHMARK $name ##########\n"
  scalehls-opt $file -legalize-to-hlscpp="top-func=$name" -qor-estimation="target-spec=$config" | scalehls-translate -emit-hlscpp > $output
  scalehls-opt $file -multiple-level-dse="top-func=$name dump-file=$dse_dump target-spec=$config" -debug-only=scalehls | scalehls-translate -emit-hlscpp > $dse_output
done
