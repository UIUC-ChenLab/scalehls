#!/bin/bash

# This test is deprecated!

# Script options.
while getopts 'm:c:' opt
do
  case $opt in
    m) model_name=$OPTARG ;;
    c) rerun_csynth_from=$OPTARG ;;
  esac
done

# Create directories.
if [ -d "${model_name}/cpp_src" ]
then
  rm -rf ${model_name}/cpp_src
fi

if [ -d "${model_name}/mlir_src" ]
then
  rm -rf ${model_name}/mlir_src
fi

if [ -d "${model_name}/dump_csv" ]
then
  rm -rf ${model_name}/dump_csv
fi

if [ -d "${model_name}/hls_proj" ]
then
  rm -rf ${model_name}/hls_proj
fi

mkdir ${model_name}/cpp_src
mkdir ${model_name}/mlir_src
mkdir ${model_name}/dump_csv
mkdir ${model_name}/hls_proj

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
echo -e "Name\tBRAM\tDSP\tLUT\tCycles\tEstiDSP\tEstiCycles" > ${model_name}/${model_name}_result.log
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
  cycles=$(awk '/<\/*Worst-caseLatency>/{gsub(/<\/*Worst-caseLatency>/,"");print $0;exit;}' $csynth_xml)
  # interval=$(awk '/<\/*Interval-min>/{gsub(/<\/*Interval-min>/,"");print $0;exit;}' $csynth_xml)

  if [ $n -eq 0 ]
  then
    esti_dsp=$(awk '/\/* DSP=/{gsub(/\/* DSP=/,"");print $0}' ${model_name}/cpp_src/${cpp_name}.cpp)
    esti_cycles=$(awk '/\/* Latency=/{gsub(/\/* Latency=/,"");print $0}' ${model_name}/cpp_src/${cpp_name}.cpp)
  else
    index=${cpp_name##*pareto_}
    index=`expr $index + 2`

    esti_dsp=$(awk -F ',' 'NR=="'$index'"{print $(NF-1)}' ${model_name}/dump_csv/func_${model_name}_space.csv)
    esti_cycles=$(awk -F ',' 'NR=="'$index'"{print $(NF-2)}' ${model_name}/dump_csv/func_${model_name}_space.csv)
  fi

  echo -e "${cpp_name}\t$bram\t$dsp\t$lut\t$cycles\t${esti_dsp}\t${esti_cycles}" >> ${model_name}/${model_name}_result.log

  let n++
done
