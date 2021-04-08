#!/bin/bash

# Please run: source dse_scale_test.sh -m gemm -c 0

# cd samples/polybench-1/ && source dse_scale_test.sh -m bicg -c 0
# cd samples/polybench-1/ && source dse_scale_test.sh -m gemm -c 0
# cd samples/polybench-1/ && source dse_scale_test.sh -m gesummv -c 0
# cd samples/polybench-1/ && source dse_scale_test.sh -m syrk -c 0
# cd samples/polybench-1/ && source dse_scale_test.sh -m syr2k -c 0
# cd samples/polybench-1/ && source dse_scale_test.sh -m trmm -c 0

# cd samples/polybench-2/ && source dse_scale_test.sh -m bicg -c 0
# cd samples/polybench-2/ && source dse_scale_test.sh -m gemm -c 0
# cd samples/polybench-2/ && source dse_scale_test.sh -m gesummv -c 0
# cd samples/polybench-2/ && source dse_scale_test.sh -m syrk -c 0
# cd samples/polybench-2/ && source dse_scale_test.sh -m syr2k -c 0
# cd samples/polybench-2/ && source dse_scale_test.sh -m trmm -c 0

# cd samples/polybench-3/ && source dse_scale_test.sh -m bicg -c 0
# cd samples/polybench-3/ && source dse_scale_test.sh -m gemm -c 0
# cd samples/polybench-3/ && source dse_scale_test.sh -m gesummv -c 0
# cd samples/polybench-3/ && source dse_scale_test.sh -m syrk -c 0
# cd samples/polybench-3/ && source dse_scale_test.sh -m syr2k -c 0
# cd samples/polybench-3/ && source dse_scale_test.sh -m trmm -c 0

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

config=target-spec.ini

echo -e "Name\tBRAM\tDSP\tLUT\tCycles\tEstiDSP\tEstiCycles" > ${model_name}/${model_name}_result.log
for n in 32 64 128 256 512 1024 2048 4096
do
  func_name=${model_name}_$n
  input=${model_name}/${func_name}.mlir

  mlir_path=${model_name}/mlir_src
  csv_path=${model_name}/dump_csv
  cpp_path=${model_name}/cpp_src
  proj_path=${model_name}/hls_proj

  mlir_file=${func_name}_pareto_0.mlir
  cpp_file=${func_name}_pareto_0.cpp

  # Run DSE.
  scalehls-opt $input -multiple-level-dse="top-func=${func_name} output-path=${mlir_path}/ csv-path=${csv_path}/ target-spec=$config" -debug-only=scalehls > /dev/null

  # Emit to HLS C++.
  scalehls-translate -emit-hlscpp ${mlir_path}/${mlir_file} > ${cpp_path}/${cpp_file}

  # Run Vivado HLS and collect results.
  if [ $n -ge $rerun_csynth_from ]
  then
    # Run HLS synthesis.
    cd ${proj_path}
    vivado_hls ../../hls_script.tcl "${func_name}" "../cpp_src/${cpp_file}" "${func_name}"
    cd ../..
  fi

  csynth_xml=${proj_path}/${func_name}/${func_name}/syn/report/csynth.xml

  bram=$(awk '/<\/*BRAM_18K>/{gsub(/<\/*BRAM_18K>/,"");print $0;exit;}' $csynth_xml)
  dsp=$(awk '/<\/*DSP48E>/{gsub(/<\/*DSP48E>/,"");print $0;exit;}' $csynth_xml)
  lut=$(awk '/<\/*LUT>/{gsub(/<\/*LUT>/,"");print $0;exit;}' $csynth_xml)
  cycles=$(awk '/<\/*Worst-caseLatency>/{gsub(/<\/*Worst-caseLatency>/,"");print $0;exit;}' $csynth_xml)
  # interval=$(awk '/<\/*Interval-min>/{gsub(/<\/*Interval-min>/,"");print $0;exit;}' $csynth_xml)

  esti_dsp=$(awk -F ',' 'NR==2{print $(NF-1)}' ${csv_path}/${func_name}_space.csv)
  esti_cycles=$(awk -F ',' 'NR==2{print $(NF-2)}' ${csv_path}/${func_name}_space.csv)

  echo -e "${func_name}\t$bram\t$dsp\t$lut\t$cycles\t${esti_dsp}\t${esti_cycles}" >> ${model_name}/${model_name}_result.log
done
