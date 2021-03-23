#!/bin/bash

# Please run: source ablation_test_run.sh -m resnet18 -n 9 -c 0

# Script options.
while getopts 'm:n:c:' opt
do
  case $opt in
    m) model_name=$OPTARG ;;
    n) ablation_number=$OPTARG ;;
    c) rerun_csynth_from=$OPTARG ;;
  esac
done

# Create directories.
if [ -d "${model_name}/cpp_src" ]
then
  rm -rf ${model_name}/cpp_src
fi

if [ -d "${model_name}/hls_proj" ]
then
  rm -rf ${model_name}/hls_proj
fi

mkdir ${model_name}/cpp_src
mkdir ${model_name}/hls_proj

# ONNX-MLIR output legalization.
pre='-allow-unregistered-dialect -legalize-onnx -affine-loop-normalize -canonicalize'

# Non-optimization pipeline.
post='-split-function -convert-linalg-to-affine-loops -canonicalize'

# Directive optimization pipeline.
post_d='-split-function -convert-linalg-to-affine-loops -loop-pipelining -simplify-affine-if -affine-store-forward -simplify-memref-access -cse -canonicalize'

# Loop and directive optimization pipeline.
post_ld='-split-function -convert-linalg-to-affine-loops -affine-loop-perfection -affine-loop-order-opt -loop-pipelining -simplify-affine-if -affine-store-forward -simplify-memref-access -cse -canonicalize'

# Ablation test.
echo -e "Name\tBRAM\tDSP\tLUT\tCycles\tInterval" > ${model_name}/${model_name}_result.log
n=0
while [ $n -lt $ablation_number ]
do
  file=${model_name}/${model_name}.mlir
  output=${model_name}/cpp_src/${model_name}_case$n.cpp

  case $n in
    0) scalehls-opt $file $pre $post | scalehls-translate -emit-hlscpp -o $output ;;
    1) scalehls-opt $file $pre $post_d | scalehls-translate -emit-hlscpp -o $output ;;
    2) scalehls-opt $file $pre $post_ld | scalehls-translate -emit-hlscpp -o $output ;;

    # Graph and loop and directive optimization pipeline.
    3) scalehls-opt $file $pre -legalize-dataflow="min-gran=6 insert-copy=true" $post_ld | scalehls-translate -emit-hlscpp -o $output ;;
    4) scalehls-opt $file $pre -legalize-dataflow="min-gran=5 insert-copy=true" $post_ld | scalehls-translate -emit-hlscpp -o $output ;;
    5) scalehls-opt $file $pre -legalize-dataflow="min-gran=4 insert-copy=true" $post_ld | scalehls-translate -emit-hlscpp -o $output ;;
    6) scalehls-opt $file $pre -legalize-dataflow="min-gran=3 insert-copy=true" $post_ld | scalehls-translate -emit-hlscpp -o $output ;;
    7) scalehls-opt $file $pre -legalize-dataflow="min-gran=2 insert-copy=true" $post_ld | scalehls-translate -emit-hlscpp -o $output ;;
    8) scalehls-opt $file $pre -legalize-dataflow="min-gran=1 insert-copy=true" $post_ld | scalehls-translate -emit-hlscpp -o $output ;;
  esac

  if [ $n -ge $rerun_csynth_from ]
  then
    # Run HLS synthesis.
    cd ${model_name}/hls_proj
    vivado_hls ../../hls_script.tcl "main_graph" "../cpp_src/${model_name}_case$n.cpp" "${model_name}_case$n"
    cd ../..
  fi

  csynth_xml=${model_name}/hls_proj/${model_name}_case$n/main_graph/syn/report/csynth.xml

  bram=$(awk '/<\/*BRAM_18K>/{gsub(/<\/*BRAM_18K>/,"");print $0;exit;}' $csynth_xml)
  dsp=$(awk '/<\/*DSP48E>/{gsub(/<\/*DSP48E>/,"");print $0;exit;}' $csynth_xml)
  lut=$(awk '/<\/*LUT>/{gsub(/<\/*LUT>/,"");print $0;exit;}' $csynth_xml)
  cycles=$(awk '/<\/*Best-caseLatency>/{gsub(/<\/*Best-caseLatency>/,"");print $0}' $csynth_xml)
  interval=$(awk '/<\/*Interval-min>/{gsub(/<\/*Interval-min>/,"");print $0}' $csynth_xml)

  echo -e "Case_$n\t$bram\t$dsp\t$lut\t$cycles\t$interval" >> ${model_name}/${model_name}_result.log

  let n++
done
