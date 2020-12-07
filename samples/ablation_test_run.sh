#!/bin/bash

# Script options.
while getopts 'n:c:r:' opt
do
  case $opt in
    n) ablation_number=$OPTARG ;;
    c) rerun_csynth=$OPTARG ;;
    r) rerun_report=$OPTARG ;;
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

if [ ! -d "test_results" ]
then
  mkdir test_results
fi

# Candidate passes.
hta=-hlskernel-to-affine
pft=-affine-loop-perfection
rvb=-remove-var-loop-bound
can=-canonicalize

p0=-insert-pipeline-pragma="insert-level=0"
p1=-insert-pipeline-pragma="insert-level=1"
p2=-insert-pipeline-pragma="insert-level=2"
p3=-insert-pipeline-pragma="insert-level=3"

u1=-affine-loop-unroll="unroll-full unroll-num-reps=1"
u2=-affine-loop-unroll="unroll-full unroll-num-reps=2"
u3=-affine-loop-unroll="unroll-full unroll-num-reps=3"

t1s2=-partial-affine-loop-tile="tile-level=1 tile-size=2"
t1s4=-partial-affine-loop-tile="tile-level=1 tile-size=4"
t2s2=-partial-affine-loop-tile="tile-level=2 tile-size=2"
t2s4=-partial-affine-loop-tile="tile-level=2 tile-size=4"
t3s2=-partial-affine-loop-tile="tile-level=3 tile-size=2"
t3s4=-partial-affine-loop-tile="tile-level=3 tile-size=4"

emit=-emit-hlscpp

# Ablation test.
n=0
while [ $n -lt $ablation_number ]
do
  # Generate HLS C++ files.
  for file in ../test/Conversion/HLSKernelToAffine/*
  do
    output="cpp_src/${file##*Affine/}.cpp"
    case $n in
      0) scalehls-opt $hta $can $file | scalehls-translate $emit -o $output ;;

      # Apply pipeline.
      1) scalehls-opt $hta "$p0" $can $file | scalehls-translate $emit -o $output ;;
      2) scalehls-opt $hta "$p1" $can $file | scalehls-translate $emit -o $output ;;
      3) scalehls-opt $hta "$p2" $can $file | scalehls-translate $emit -o $output ;;
      4) scalehls-opt $hta "$p3" $can $file | scalehls-translate $emit -o $output ;;

      # Apply loop perfection + pipeline.
      5) scalehls-opt $hta $pft "$p0" $can $file | scalehls-translate $emit -o $output ;;
      6) scalehls-opt $hta $pft "$p1" $can $file | scalehls-translate $emit -o $output ;;
      7) scalehls-opt $hta $pft "$p2" $can $file | scalehls-translate $emit -o $output ;;
      8) scalehls-opt $hta $pft "$p3" $can $file | scalehls-translate $emit -o $output ;;

      # Apply loop perfection + remove variable bound + pipeline.
      9) scalehls-opt $hta $pft $rvb "$p0" $can $file | scalehls-translate $emit -o $output ;;
      10) scalehls-opt $hta $pft $rvb "$p1" $can $file | scalehls-translate $emit -o $output ;;
      11) scalehls-opt $hta $pft $rvb "$p2" $can $file | scalehls-translate $emit -o $output ;;
      12) scalehls-opt $hta $pft $rvb "$p3" $can $file | scalehls-translate $emit -o $output ;;

      # Apply loop perfection + remove variable bound + loop tiling + pipeline.
      13) scalehls-opt $hta $pft $rvb "$t1s4" "$p1" "$u1" $can $file | scalehls-translate $emit -o $output ;;
      14) scalehls-opt $hta $pft $rvb "$t2s4" "$p2" "$u2" $can $file | scalehls-translate $emit -o $output ;;
      15) scalehls-opt $hta $pft $rvb "$t3s4" "$p3" "$u3" $can $file | scalehls-translate $emit -o $output ;;
    esac
  done

  if [ $rerun_csynth == "true" ]
  then
    # Run HLS synthesis.
    cd hls_proj
    vivado_hls ../hls_script.tcl
    cd ..
  fi

  if [ $rerun_report == "true" ]
  then
    # Generate latency report.
    echo -e "benchmark\tdsp\tlut\tcycles" > test_results/test_result$n.log
    # echo "----------------------------------------" >> test_results/test_result$n.log
    for file in cpp_src/*
    do
      name=${file##*cpp_src/}
      name=${name%.mlir*}
      cycles=$(awk '/<\/*Worst-caseLatency>/{gsub(/<\/*Worst-caseLatency>/,"");print $0}' hls_proj/$name/$name/syn/report/csynth.xml)
      dsp=$(awk '/<\/*DSP48E>/{gsub(/<\/*DSP48E>/,"");print $0;exit;}' hls_proj/$name/$name/syn/report/csynth.xml)
      lut=$(awk '/<\/*LUT>/{gsub(/<\/*LUT>/,"");print $0;exit;}' hls_proj/$name/$name/syn/report/csynth.xml)

      echo -e "$name\t$dsp\t$lut\t$cycles" >> test_results/test_result$n.log
    done
  fi

  let n++
done

# Generate report summary.
echo -e "test summary" > test_summary.log
echo -e "benchmark\tdsp\tlut\tcycles" >> test_summary.log

n=2
for file in cpp_src/*
do
  name=${file##*cpp_src/}
  name=${name%.mlir*}

  idx=0
  for result in test_results/*
  do
    case $idx in
      0) echo -e "$name\t\c" >> test_summary.log ;;

      # Apply pipeline.
      1) echo -e "p0\t\c" >> test_summary.log ;;
      2) echo -e "p1\t\c" >> test_summary.log ;;
      3) echo -e "p2\t\c" >> test_summary.log ;;
      4) echo -e "p3\t\c" >> test_summary.log ;;

      # Apply loop perfection + pipeline.
      5) echo -e "pft+p0\t\c" >> test_summary.log ;;
      6) echo -e "pft+p1\t\c" >> test_summary.log ;;
      7) echo -e "pft+p2\t\c" >> test_summary.log ;;
      8) echo -e "pft+p3\t\c" >> test_summary.log ;;

      # Apply loop perfection + remove variable bound + pipeline.
      9) echo -e "pft+rvb+p0\t\c" >> test_summary.log ;;
      10) echo -e "pft+rvb+p1\t\c" >> test_summary.log ;;
      11) echo -e "pft+rvb+p2\t\c" >> test_summary.log ;;
      12) echo -e "pft+rvb+p3\t\c" >> test_summary.log ;;

      # Apply loop perfection + remove variable bound + loop tiling + pipeline.
      13) echo -e "pft+rvb+t1+p1\t\c" >> test_summary.log ;;
      14) echo -e "pft+rvb+t2+p2\t\c" >> test_summary.log ;;
      15) echo -e "pft+rvb+t3+p3\t\c" >> test_summary.log ;;
    esac

    cat $result | awk "NR==$n{OFS=\"\t\";print \$2,\$3,\$4}" >> test_summary.log
    let idx++
  done

  let n++
done
