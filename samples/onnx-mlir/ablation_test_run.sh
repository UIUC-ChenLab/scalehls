#!/bin/bash

# Please run: source ablation_test_run.sh -m resnet18 -n 17 -c 0

# cd samples/onnx-mlir-1/ && source ablation_test_run.sh -m lenet -n 17 -c 0
# cd samples/onnx-mlir-1/ && source ablation_test_run.sh -m mobilenetv2 -n 17 -c 0
# cd samples/onnx-mlir-1/ && source ablation_test_run.sh -m resnet18 -n 17 -c 0
# cd samples/onnx-mlir-1/ && source ablation_test_run.sh -m vgg16 -n 17 -c 0

# cd samples/onnx-mlir-2/ && source ablation_test_run.sh -m lenet -n 17 -c 0
# cd samples/onnx-mlir-2/ && source ablation_test_run.sh -m mobilenetv2 -n 17 -c 0
# cd samples/onnx-mlir-2/ && source ablation_test_run.sh -m resnet18 -n 17 -c 0
# cd samples/onnx-mlir-2/ && source ablation_test_run.sh -m vgg16 -n 17 -c 0

# cd samples/onnx-mlir-3/ && source ablation_test_run.sh -m lenet -n 17 -c 0
# cd samples/onnx-mlir-3/ && source ablation_test_run.sh -m mobilenetv2 -n 17 -c 0
# cd samples/onnx-mlir-3/ && source ablation_test_run.sh -m resnet18 -n 17 -c 0
# cd samples/onnx-mlir-3/ && source ablation_test_run.sh -m vgg16 -n 17 -c 0

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

# Legalization from ONNX.
legalize="-allow-unregistered-dialect -legalize-onnx -affine-loop-normalize -canonicalize"

# Different level graph optimization.
graph_O1=-legalize-dataflow="min-gran=8 insert-copy=true"
graph_O2=-legalize-dataflow="min-gran=7 insert-copy=true"
graph_O3=-legalize-dataflow="min-gran=6 insert-copy=true"
graph_O4=-legalize-dataflow="min-gran=5 insert-copy=true"
graph_O5=-legalize-dataflow="min-gran=4 insert-copy=true"
graph_O6=-legalize-dataflow="min-gran=3 insert-copy=true"
# graph_O7=-legalize-dataflow="min-gran=2 insert-copy=true"

# Split and canonicalize function.
split="-split-function -convert-linalg-to-affine-loops -canonicalize"

# Convert to HLSCpp.
hlscpp=-legalize-to-hlscpp="top-func=main_graph"

# Loop perfection.
perfect="-affine-loop-perfection"

# Different level loop optimization (tile + order opt + pipeline).
loop_O1="-affine-loop-order-opt -loop-pipelining"
loop_O2=-partial-affine-loop-tile="tile-size=2 apply-order-opt=true apply-pipeline=true"
loop_O3=-partial-affine-loop-tile="tile-size=4 apply-order-opt=true apply-pipeline=true"
loop_O4=-partial-affine-loop-tile="tile-size=8 apply-order-opt=true apply-pipeline=true"
loop_O5=-partial-affine-loop-tile="tile-size=16 apply-order-opt=true apply-pipeline=true"
loop_O6=-partial-affine-loop-tile="tile-size=32 apply-order-opt=true apply-pipeline=true"
# loop_O7=-partial-affine-loop-tile="tile-size=64 apply-order-opt=true apply-pipeline=true"

# Loop pipelining.
pipeline="-loop-pipelining"

# Directive optimization.
direct="-simplify-affine-if -affine-store-forward -simplify-memref-access -array-partition -cse -canonicalize"

# Ablation test.
echo -e "Name\tBRAM\tDSP\tLUT\tCycles\tInterval" > ${model_name}/${model_name}_result.log
n=0
while [ $n -lt $ablation_number ]
do
  file=${model_name}/${model_name}.mlir
  output=${model_name}/cpp_src/${model_name}_case$n.cpp

  case $n in
    # Non-opt.
    0)  scalehls-opt $file $legalize $split $hlscpp | scalehls-translate -emit-hlscpp -o $output ;;
    # Only directive opt.
    1)  scalehls-opt $file $legalize $split $hlscpp $pipeline $direct | scalehls-translate -emit-hlscpp -o $output ;;

    # Loop (level 6) + directive opt.
    2)  scalehls-opt $file $legalize $split $hlscpp $perfect "$loop_O6" $direct | scalehls-translate -emit-hlscpp -o $output ;;
    # Graph (level 6) + directive opt.
    3)  scalehls-opt $file $legalize "$graph_O6" $split $hlscpp $pipeline $direct | scalehls-translate -emit-hlscpp -o $output ;;
    # Graph (level 6) + loop (level 6) + directive opt.
    4)  scalehls-opt $file $legalize "$graph_O6" $split $hlscpp $perfect "$loop_O6" $direct | scalehls-translate -emit-hlscpp -o $output ;;

    ## Ablation study of loop opt.
    # Graph (level 6) + loop (level 1 to 6) + directive opt.
    5)  scalehls-opt $file $legalize "$graph_O6" $split $hlscpp $perfect  $loop_O1  $direct | scalehls-translate -emit-hlscpp -o $output ;;
    6)  scalehls-opt $file $legalize "$graph_O6" $split $hlscpp $perfect "$loop_O2" $direct | scalehls-translate -emit-hlscpp -o $output ;;
    7)  scalehls-opt $file $legalize "$graph_O6" $split $hlscpp $perfect "$loop_O3" $direct | scalehls-translate -emit-hlscpp -o $output ;;
    8)  scalehls-opt $file $legalize "$graph_O6" $split $hlscpp $perfect "$loop_O4" $direct | scalehls-translate -emit-hlscpp -o $output ;;
    9)  scalehls-opt $file $legalize "$graph_O6" $split $hlscpp $perfect "$loop_O5" $direct | scalehls-translate -emit-hlscpp -o $output ;;
    10) scalehls-opt $file $legalize "$graph_O6" $split $hlscpp $perfect "$loop_O6" $direct | scalehls-translate -emit-hlscpp -o $output ;;

    ## Ablation study of graph opt.
    # Graph (from level 1 to 6) + loop (level 6) + directive opt.
    11) scalehls-opt $file $legalize "$graph_O1" $split $hlscpp $perfect "$loop_O6" $direct | scalehls-translate -emit-hlscpp -o $output ;;
    12) scalehls-opt $file $legalize "$graph_O2" $split $hlscpp $perfect "$loop_O6" $direct | scalehls-translate -emit-hlscpp -o $output ;;
    13) scalehls-opt $file $legalize "$graph_O3" $split $hlscpp $perfect "$loop_O6" $direct | scalehls-translate -emit-hlscpp -o $output ;;
    14) scalehls-opt $file $legalize "$graph_O4" $split $hlscpp $perfect "$loop_O6" $direct | scalehls-translate -emit-hlscpp -o $output ;;
    15) scalehls-opt $file $legalize "$graph_O5" $split $hlscpp $perfect "$loop_O6" $direct | scalehls-translate -emit-hlscpp -o $output ;;
    16) scalehls-opt $file $legalize "$graph_O6" $split $hlscpp $perfect "$loop_O6" $direct | scalehls-translate -emit-hlscpp -o $output ;;

    # 17) scalehls-opt $file $legalize "$graph_O6" $split $hlscpp $perfect "$loop_O7" $direct | scalehls-translate -emit-hlscpp -o $output ;;
    # 18) scalehls-opt $file $legalize "$graph_O7" $split $hlscpp $perfect "$loop_O6" $direct | scalehls-translate -emit-hlscpp -o $output ;;
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
