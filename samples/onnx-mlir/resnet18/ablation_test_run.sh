#!/bin/bash

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
pred='-legalize-onnx -affine-loop-normalize -canonicalize'

succ='-split-function -convert-linalg-to-affine-loops -canonicalize'
succ_pipeline='-split-function -convert-linalg-to-affine-loops -loop-pipelining -canonicalize'

succ_fusion='-split-function -convert-linalg-to-affine-loops -affine-loop-fusion -canonicalize'
succ_fusion_pipeline='-split-function -convert-linalg-to-affine-loops -affine-loop-fusion -loop-pipelining -canonicalize'

# Ablation test.
echo -e "Name\tBRAM\tDSP\tLUT\tCycles\tInterval" > test_result.log
n=0
while [ $n -lt $ablation_number ]
do
  file=../../../tmp/resnet18.mlir
  output=cpp_src/resnet18_$n.cpp

  case $n in
    # Original.
    0) scalehls-opt $file $pred $succ | scalehls-translate -emit-hlscpp -o $output ;;
    1) scalehls-opt $file $pred $succ_pipeline | scalehls-translate -emit-hlscpp -o $output ;;

    # Conservative dataflow legalization.
    2) scalehls-opt $file $pred -legalize-dataflow="min-gran=1 insert-copy=false" $succ_pipeline | scalehls-translate -emit-hlscpp -o $output ;;

    # Progressive dataflow legalization.
    3) scalehls-opt $file $pred -legalize-dataflow="min-gran=1 insert-copy=true" $succ_pipeline | scalehls-translate -emit-hlscpp -o $output ;;
    4) scalehls-opt $file $pred -legalize-dataflow="min-gran=2 insert-copy=true" $succ_pipeline | scalehls-translate -emit-hlscpp -o $output ;;
    5) scalehls-opt $file $pred -legalize-dataflow="min-gran=3 insert-copy=true" $succ_pipeline | scalehls-translate -emit-hlscpp -o $output ;;
    6) scalehls-opt $file $pred -legalize-dataflow="min-gran=4 insert-copy=true" $succ_pipeline | scalehls-translate -emit-hlscpp -o $output ;;
    7) scalehls-opt $file $pred -legalize-dataflow="min-gran=5 insert-copy=true" $succ_pipeline | scalehls-translate -emit-hlscpp -o $output ;;

    # Original with fusion.
    8) scalehls-opt $file $pred $succ_fusion | scalehls-translate -emit-hlscpp -o $output ;;
    9) scalehls-opt $file $pred $succ_fusion_pipeline | scalehls-translate -emit-hlscpp -o $output ;;

    # Conservative dataflow legalization with fusion.
    10) scalehls-opt $file $pred -legalize-dataflow="min-gran=1 insert-copy=false" $succ_fusion_pipeline | scalehls-translate -emit-hlscpp -o $output ;;

    # Progressive dataflow legalization with fusion.
    11) scalehls-opt $file $pred -legalize-dataflow="min-gran=1 insert-copy=true" $succ_fusion_pipeline | scalehls-translate -emit-hlscpp -o $output ;;
    12) scalehls-opt $file $pred -legalize-dataflow="min-gran=2 insert-copy=true" $succ_fusion_pipeline | scalehls-translate -emit-hlscpp -o $output ;;
    13) scalehls-opt $file $pred -legalize-dataflow="min-gran=3 insert-copy=true" $succ_fusion_pipeline | scalehls-translate -emit-hlscpp -o $output ;;
    14) scalehls-opt $file $pred -legalize-dataflow="min-gran=4 insert-copy=true" $succ_fusion_pipeline | scalehls-translate -emit-hlscpp -o $output ;;
    15) scalehls-opt $file $pred -legalize-dataflow="min-gran=5 insert-copy=true" $succ_fusion_pipeline | scalehls-translate -emit-hlscpp -o $output ;;
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
