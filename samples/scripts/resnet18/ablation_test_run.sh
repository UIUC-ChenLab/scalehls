#!/bin/bash

# Please run: source ablation_test_run.sh -n 9 -c 0

# Script options.
while getopts 'n:c:' opt
do
  case $opt in
    n) ablation_number=$OPTARG ;;
    c) rerun_csynth_from=$OPTARG ;;
  esac
done

# Create directories.
if [ ! -d "cpp_src" ]
then
  mkdir cpp_src
fi

if [ ! -d "hls_proj" ]
then
  mkdir hls_proj
fi

# Passes pipeline.
pre='-allow-unregistered-dialect -legalize-onnx -affine-loop-normalize -canonicalize'

post='-split-function -convert-linalg-to-affine-loops -canonicalize'
post_p='-split-function -convert-linalg-to-affine-loops -loop-pipelining -simplify-affine-if -affine-store-forward -simplify-memref-access -cse -canonicalize'
post_op='-split-function -convert-linalg-to-affine-loops -affine-loop-perfection -affine-loop-order-opt -loop-pipelining -simplify-affine-if -affine-store-forward -simplify-memref-access -cse -canonicalize'

# Ablation test.
echo -e "Name\tBRAM\tDSP\tLUT\tCycles\tInterval" > test_result.log
n=0
while [ $n -lt $ablation_number ]
do
  file=resnet18.mlir
  output=cpp_src/resnet18_$n.cpp

  case $n in
    # Original.
    0) scalehls-opt $file $pre $post | scalehls-translate -emit-hlscpp -o $output ;;
    1) scalehls-opt $file $pre $post_p | scalehls-translate -emit-hlscpp -o $output ;;
    2) scalehls-opt $file $pre $post_op | scalehls-translate -emit-hlscpp -o $output ;;

    # Progressive dataflow legalization.
    3) scalehls-opt $file $pre -legalize-dataflow="min-gran=6 insert-copy=true" $post_op | scalehls-translate -emit-hlscpp -o $output ;;
    4) scalehls-opt $file $pre -legalize-dataflow="min-gran=5 insert-copy=true" $post_op | scalehls-translate -emit-hlscpp -o $output ;;
    5) scalehls-opt $file $pre -legalize-dataflow="min-gran=4 insert-copy=true" $post_op | scalehls-translate -emit-hlscpp -o $output ;;
    6) scalehls-opt $file $pre -legalize-dataflow="min-gran=3 insert-copy=true" $post_op | scalehls-translate -emit-hlscpp -o $output ;;
    7) scalehls-opt $file $pre -legalize-dataflow="min-gran=2 insert-copy=true" $post_op | scalehls-translate -emit-hlscpp -o $output ;;
    8) scalehls-opt $file $pre -legalize-dataflow="min-gran=1 insert-copy=true" $post_op | scalehls-translate -emit-hlscpp -o $output ;;
  esac

  if [ $n -ge $rerun_csynth_from ]
  then
    # Run HLS synthesis.
    cd hls_proj
    vivado_hls ../hls_script.tcl "main_graph" "../cpp_src/resnet18_$n.cpp" "resnet18_$n"
    cd ..
  fi

  cycles=$(awk '/<\/*Best-caseLatency>/{gsub(/<\/*Best-caseLatency>/,"");print $0}' hls_proj/resnet18_$n/main_graph/syn/report/csynth.xml)
  interval=$(awk '/<\/*Interval-min>/{gsub(/<\/*Interval-min>/,"");print $0}' hls_proj/resnet18_$n/main_graph/syn/report/csynth.xml)
  bram=$(awk '/<\/*BRAM_18K>/{gsub(/<\/*BRAM_18K>/,"");print $0;exit;}' hls_proj/resnet18_$n/main_graph/syn/report/csynth.xml)
  dsp=$(awk '/<\/*DSP48E>/{gsub(/<\/*DSP48E>/,"");print $0;exit;}' hls_proj/resnet18_$n/main_graph/syn/report/csynth.xml)
  lut=$(awk '/<\/*LUT>/{gsub(/<\/*LUT>/,"");print $0;exit;}' hls_proj/resnet18_$n/main_graph/syn/report/csynth.xml)

  echo -e "Case_$n\t$bram\t$dsp\t$lut\t$cycles\t$interval" >> test_result.log

  let n++
done
