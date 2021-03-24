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

# Legalization passes.
legal="-allow-unregistered-dialect -legalize-onnx -affine-loop-normalize -canonicalize"

# Dataflow passes.
dataflow_O1=-legalize-dataflow="min-gran=6 insert-copy=true"
dataflow_O2=-legalize-dataflow="min-gran=5 insert-copy=true"
dataflow_O3=-legalize-dataflow="min-gran=4 insert-copy=true"
dataflow_O4=-legalize-dataflow="min-gran=3 insert-copy=true"
dataflow_O5=-legalize-dataflow="min-gran=2 insert-copy=true"
dataflow_O6=-legalize-dataflow="min-gran=1 insert-copy=true"

# Split function passes.
split="-split-function -convert-linalg-to-affine-loops -canonicalize"

# Convert to HLSCpp.
hlscpp=-legalize-to-hlscpp="top-func=main_graph"

# Loop opt passes.
loop="-affine-loop-perfection -affine-loop-order-opt -remove-variable-bound"

# Loop tile passes.
tile_O1=-partial-affine-loop-tile="tile-size=2 apply-pipeline=true"
tile_O2=-partial-affine-loop-tile="tile-size=4 apply-pipeline=true"
tile_O3=-partial-affine-loop-tile="tile-size=8 apply-pipeline=true"
tile_O4=-partial-affine-loop-tile="tile-size=16 apply-pipeline=true"
tile_O5=-partial-affine-loop-tile="tile-size=32 apply-pipeline=true"
tile_O6=-partial-affine-loop-tile="tile-size=64 apply-pipeline=true"

# Directive opt passes without pipeline.
direct="-simplify-affine-if -affine-store-forward -simplify-memref-access -array-partition -cse -canonicalize"

# Directive opt passes with pipeline.
direct_wpip="-loop-pipelining -simplify-affine-if -affine-store-forward -simplify-memref-access -array-partition -cse -canonicalize"

# Ablation test.
echo -e "Name\tBRAM\tDSP\tLUT\tCycles\tInterval" > ${model_name}/${model_name}_result.log
n=0
while [ $n -lt $ablation_number ]
do
  file=${model_name}/${model_name}.mlir
  output=${model_name}/cpp_src/${model_name}_case$n.cpp

  case $n in
    # Non-opt.
    0) scalehls-opt $file $legal $split $hlscpp | scalehls-translate -emit-hlscpp -o $output ;;

    # Directive opt.
    1) scalehls-opt $file $legal $split $hlscpp $direct_wpip | scalehls-translate -emit-hlscpp -o $output ;;

    # Loop (level 0) + directive opt.
    2) scalehls-opt $file $legal $split $hlscpp $loop $direct_wpip | scalehls-translate -emit-hlscpp -o $output ;;

    # Loop (from level 1 to 6) + directive opt.
    3) scalehls-opt $file $legal $split $hlscpp $loop "$tile_O1" $direct | scalehls-translate -emit-hlscpp -o $output ;;
    4) scalehls-opt $file $legal $split $hlscpp $loop "$tile_O2" $direct | scalehls-translate -emit-hlscpp -o $output ;;
    5) scalehls-opt $file $legal $split $hlscpp $loop "$tile_O3" $direct | scalehls-translate -emit-hlscpp -o $output ;;
    6) scalehls-opt $file $legal $split $hlscpp $loop "$tile_O4" $direct | scalehls-translate -emit-hlscpp -o $output ;;
    7) scalehls-opt $file $legal $split $hlscpp $loop "$tile_O5" $direct | scalehls-translate -emit-hlscpp -o $output ;;
    8) scalehls-opt $file $legal $split $hlscpp $loop "$tile_O6" $direct | scalehls-translate -emit-hlscpp -o $output ;;

    # Graph (from level 1 to 6) + loop (level 0) + directive opt.
    # 3) scalehls-opt $file $legal $dataflow_O1 $split $hlscpp $loop $direct_wpip | scalehls-translate -emit-hlscpp -o $output ;;
    # 4) scalehls-opt $file $legal $dataflow_O2 $split $hlscpp $loop $direct_wpip | scalehls-translate -emit-hlscpp -o $output ;;
    # 5) scalehls-opt $file $legal $dataflow_O3 $split $hlscpp $loop $direct_wpip | scalehls-translate -emit-hlscpp -o $output ;;
    # 6) scalehls-opt $file $legal $dataflow_O4 $split $hlscpp $loop $direct_wpip | scalehls-translate -emit-hlscpp -o $output ;;
    # 7) scalehls-opt $file $legal $dataflow_O5 $split $hlscpp $loop $direct_wpip | scalehls-translate -emit-hlscpp -o $output ;;
    # 8) scalehls-opt $file $legal $dataflow_O6 $split $hlscpp $loop $direct_wpip | scalehls-translate -emit-hlscpp -o $output ;;
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
