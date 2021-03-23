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
if [ ! -d "${model_name}/cpp_src" ]
then
  mkdir ${model_name}/cpp_src
fi

if [ ! -d "${model_name}/hls_proj" ]
then
  mkdir ${model_name}/hls_proj
fi

# Legalization stage 1.
legal_1='-allow-unregistered-dialect -legalize-onnx -affine-loop-normalize -canonicalize'

# Legalization stage 2.
legal_2='-split-function -convert-linalg-to-affine-loops -canonicalize'

# Directive optimization.
direct='-loop-pipelining -simplify-affine-if -affine-store-forward -simplify-memref-access -array-partition -cse -canonicalize'

# Loop and directive optimization stage 1.
loop_direct_1='-affine-loop-perfection -affine-loop-order-opt -remove-variable-bound'

# Loop and directive optimization stage 2.
loop_direct_2='-simplify-affine-if -affine-store-forward -simplify-memref-access -array-partition -cse -canonicalize'

# Ablation test.
echo -e "Name\tBRAM\tDSP\tLUT\tCycles\tInterval" > ${model_name}/${model_name}_result.log
n=0
while [ $n -lt $ablation_number ]
do
  file=${model_name}/${model_name}.mlir
  output=${model_name}/cpp_src/${model_name}_case$n.cpp

  case $n in
    # Non-opt.
    0) scalehls-opt $file $legal_1 $legal_2 | scalehls-translate -emit-hlscpp -o $output ;;

    # Directive opt.
    1) scalehls-opt $file $legal_1 $legal_2 $direct | scalehls-translate -emit-hlscpp -o $output ;;

    # Loop (level 0) + directive opt.
    2) scalehls-opt $file $legal_1 $legal_2 $loop_direct_1 $direct | scalehls-translate -emit-hlscpp -o $output ;;

    # Loop (from level 1 to 4) + directive opt.
    3) scalehls-opt $file $legal_1 $legal_2 $loop_direct_1 -partial-affine-loop-tile="tile-size=2 apply-pipeline=true" $loop_direct_2 | scalehls-translate -emit-hlscpp -o $output ;;
    4) scalehls-opt $file $legal_1 $legal_2 $loop_direct_1 -partial-affine-loop-tile="tile-size=4 apply-pipeline=true" $loop_direct_2 | scalehls-translate -emit-hlscpp -o $output ;;
    5) scalehls-opt $file $legal_1 $legal_2 $loop_direct_1 -partial-affine-loop-tile="tile-size=8 apply-pipeline=true" $loop_direct_2 | scalehls-translate -emit-hlscpp -o $output ;;
    6) scalehls-opt $file $legal_1 $legal_2 $loop_direct_1 -partial-affine-loop-tile="tile-size=16 apply-pipeline=true" $loop_direct_2 | scalehls-translate -emit-hlscpp -o $output ;;
    # 7) scalehls-opt $file $legal_1 $legal_2 $loop_direct_1 -partial-affine-loop-tile="tile-size=32 apply-pipeline=true" $loop_direct_2 | scalehls-translate -emit-hlscpp -o $output ;;
    # 8) scalehls-opt $file $legal_1 $legal_2 $loop_direct_1 -partial-affine-loop-tile="tile-size=64 apply-pipeline=true" $loop_direct_2 | scalehls-translate -emit-hlscpp -o $output ;;

    # Graph (from level 1 to 6) + loop (level 0) + directive opt.
    # 3) scalehls-opt $file $legal_1 -legalize-dataflow="min-gran=6 insert-copy=true" $legal_2 $loop_direct_1 $direct | scalehls-translate -emit-hlscpp -o $output ;;
    # 4) scalehls-opt $file $legal_1 -legalize-dataflow="min-gran=5 insert-copy=true" $legal_2 $loop_direct_1 $direct | scalehls-translate -emit-hlscpp -o $output ;;
    # 5) scalehls-opt $file $legal_1 -legalize-dataflow="min-gran=4 insert-copy=true" $legal_2 $loop_direct_1 $direct | scalehls-translate -emit-hlscpp -o $output ;;
    # 6) scalehls-opt $file $legal_1 -legalize-dataflow="min-gran=3 insert-copy=true" $legal_2 $loop_direct_1 $direct | scalehls-translate -emit-hlscpp -o $output ;;
    # 7) scalehls-opt $file $legal_1 -legalize-dataflow="min-gran=2 insert-copy=true" $legal_2 $loop_direct_1 $direct | scalehls-translate -emit-hlscpp -o $output ;;
    # 8) scalehls-opt $file $legal_1 -legalize-dataflow="min-gran=1 insert-copy=true" $legal_2 $loop_direct_1 $direct | scalehls-translate -emit-hlscpp -o $output ;;
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
