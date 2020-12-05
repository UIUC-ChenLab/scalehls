#!/bin/bash

# Generate HLS C++ files.
if [ ! -d "cpp_src" ]
then
  mkdir cpp_src
fi
for file in ../test/Conversion/HLSKernelToAffine/*
do
  scalehls-opt -hlskernel-to-affine -affine-loop-perfection $file | scalehls-translate -emit-hlscpp -o "cpp_src/${file##*Affine/}.cpp"
done

if [ $1 == "rerun" ]
then
  # Run HLS synthesis.
  if [ ! -d "hls_proj" ]
  then
    mkdir hls_proj
  fi
  cd hls_proj
  vivado_hls ../hls_script.tcl
  cd ..
fi

# Generate latency report.
echo -e "testcase\tlatency" > test_result.log
echo "--------------------------------" >> test_result.log
for file in cpp_src/*
do
  name=${file##*cpp_src/}
  name=${name%.mlir*}
  latency=$(cat hls_proj/$name/$name/syn/report/csynth.xml | grep Worst-caseLatency)
  latency=${latency##<Worst-caseLatency>}
  latency=${latency%</Worst-caseLatency>}
  
  echo -e $name"\t"$latency >> test_result.log
done
