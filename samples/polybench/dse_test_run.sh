#!/bin/bash

# Please run: source dse_test_run.sh -c 0

# cd samples/polybench/ && source dse_test_run.sh -m atax -c 0
# cd samples/polybench/ && source dse_test_run.sh -m bicg -c 0
# cd samples/polybench/ && source dse_test_run.sh -m gemm -c 0
# cd samples/polybench/ && source dse_test_run.sh -m gesummv -c 0
# cd samples/polybench/ && source dse_test_run.sh -m syrk -c 0
# cd samples/polybench/ && source dse_test_run.sh -m syr2k -c 0

# Script options.
while getopts 'm:c:' opt
do
  case $opt in
    m) model_name=$OPTARG ;;
    c) rerun_csynth_from=$OPTARG ;;
  esac
done

# Create directories.
if [ ! -d "${model_name}/cpp_src" ]
then
  mkdir ${model_name}/cpp_src
fi

if [ ! -d "${model_name}/mlir_src" ]
then
  mkdir ${model_name}/mlir_src
fi

if [ ! -d "${model_name}/dump_csv" ]
then
  mkdir ${model_name}/dump_csv
fi

if [ ! -d "${model_name}/hls_proj" ]
then
  mkdir ${model_name}/hls_proj
fi

# Run DSE.
config=../../config/target-spec.ini
input=${model_name}/${model_name}.mlir

scalehls-opt $input -legalize-to-hlscpp="top-func=${model_name}" -qor-estimation="target-spec=$config" | scalehls-translate -emit-hlscpp > ${model_name}/cpp_src/${model_name}_naive.cpp
scalehls-opt $input -multiple-level-dse="top-func=${model_name} output-path=${model_name}/mlir_src/ csv-path=${model_name}/dump_csv/ target-spec=$config" -debug-only=scalehls > /dev/null

for file in ${model_name}/mlir_src/*
do
  cpp_name=${file##*mlir_src/}
  cpp_name=${cpp_name%.mlir}

  scalehls-translate -emit-hlscpp $file > ${model_name}/cpp_src/$cpp_name.cpp
done

# Run Vivado HLS and collect results.
echo -e "Name\tBRAM\tDSP\tLUT\tCycles\tInterval" > ${model_name}/${model_name}_result.log
n=0
for file in ${model_name}/cpp_src/*
do
  cpp_name=${file##*cpp_src/}
  cpp_name=${cpp_name%.cpp}

  if [ $n -ge $rerun_csynth_from ]
  then
    # Run HLS synthesis.
    cd ${model_name}/hls_proj
    vivado_hls ../../hls_script.tcl "${model_name}" "../cpp_src/${cpp_name}.cpp" "${cpp_name}"
    cd ../..
  fi

  csynth_xml=${model_name}/hls_proj/${cpp_name}/${model_name}/syn/report/csynth.xml

  bram=$(awk '/<\/*BRAM_18K>/{gsub(/<\/*BRAM_18K>/,"");print $0;exit;}' $csynth_xml)
  dsp=$(awk '/<\/*DSP48E>/{gsub(/<\/*DSP48E>/,"");print $0;exit;}' $csynth_xml)
  lut=$(awk '/<\/*LUT>/{gsub(/<\/*LUT>/,"");print $0;exit;}' $csynth_xml)
  cycles=$(awk '/<\/*Best-caseLatency>/{gsub(/<\/*Best-caseLatency>/,"");print $0}' $csynth_xml)
  interval=$(awk '/<\/*Interval-min>/{gsub(/<\/*Interval-min>/,"");print $0}' $csynth_xml)

  echo -e "${cpp_name}\t$bram\t$dsp\t$lut\t$cycles\t$interval" >> ${model_name}/${model_name}_result.log

  let n++
done
