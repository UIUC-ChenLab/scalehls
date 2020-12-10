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

if [ ! -d "test_results" ]
then
  mkdir test_results
fi

# Candidate passes.
hta=-hlskernel-to-affine
cth=-convert-to-hlscpp
can=-canonicalize

alp=-affine-loop-perfection
rvb=-remove-var-loop-bound
par=-array-partition

p0=-insert-pipeline-pragma="insert-level=0"
p1=-insert-pipeline-pragma="insert-level=1"
p2=-insert-pipeline-pragma="insert-level=2"
p3=-insert-pipeline-pragma="insert-level=3"

u1=-affine-loop-unroll="unroll-full unroll-num-reps=1"
u2=-affine-loop-unroll="unroll-full unroll-num-reps=2"
u3=-affine-loop-unroll="unroll-full unroll-num-reps=3"

t1s2=-partial-affine-loop-tile="tile-level=1 tile-size=2"
t1s4=-partial-affine-loop-tile="tile-level=1 tile-size=4"
t1s8=-partial-affine-loop-tile="tile-level=1 tile-size=8"

t2s2=-partial-affine-loop-tile="tile-level=2 tile-size=2"
t2s4=-partial-affine-loop-tile="tile-level=2 tile-size=4"
t2s8=-partial-affine-loop-tile="tile-level=2 tile-size=8"

t3s2=-partial-affine-loop-tile="tile-level=3 tile-size=2"
t3s4=-partial-affine-loop-tile="tile-level=3 tile-size=4"
t3s8=-partial-affine-loop-tile="tile-level=3 tile-size=8"

emit=-emit-hlscpp

# Ablation test.
n=0
while [ $n -lt $ablation_number ]
do
  # Generate HLS C++ files.
  for file in ../test/Conversion/HLSKernelToAffine/*
  do
    name=${file##*Affine/}
    name=top-function=${name%.mlir*}
    output="cpp_src/${file##*Affine/}.cpp"

    case $n in
      0) scalehls-opt $hta $cth="$name" $can $file | scalehls-translate $emit -o $output ;;

      # Apply pipeline.
      1) scalehls-opt $hta $cth="$name" "$p0" $can $file | scalehls-translate $emit -o $output ;;
      2) scalehls-opt $hta $cth="$name" "$p1" $can $file | scalehls-translate $emit -o $output ;;
      3) scalehls-opt $hta $cth="$name" "$p2" $can $file | scalehls-translate $emit -o $output ;;
      4) scalehls-opt $hta $cth="$name" "$p3" $can $file | scalehls-translate $emit -o $output ;;

      # Apply pipeline + array partition.
      5) scalehls-opt $hta $cth="$name" "$p0" $par $can $file | scalehls-translate $emit -o $output ;;
      6) scalehls-opt $hta $cth="$name" "$p1" $par $can $file | scalehls-translate $emit -o $output ;;
      7) scalehls-opt $hta $cth="$name" "$p2" $par $can $file | scalehls-translate $emit -o $output ;;
      8) scalehls-opt $hta $cth="$name" "$p3" $par $can $file | scalehls-translate $emit -o $output ;;

      # Apply loop perfection + remove variable bound + pipeline.
      9) scalehls-opt $hta $alp $rvb $cth="$name" "$p0" $can $file | scalehls-translate $emit -o $output ;;
      10) scalehls-opt $hta $alp $rvb $cth="$name" "$p1" $can $file | scalehls-translate $emit -o $output ;;
      11) scalehls-opt $hta $alp $rvb $cth="$name" "$p2" $can $file | scalehls-translate $emit -o $output ;;
      12) scalehls-opt $hta $alp $rvb $cth="$name" "$p3" $can $file | scalehls-translate $emit -o $output ;;

      # Apply loop perfection + remove variable bound + pipeline + array partition.
      13) scalehls-opt $hta $alp $rvb $cth="$name" "$p0" $par $can $file | scalehls-translate $emit -o $output ;;
      14) scalehls-opt $hta $alp $rvb $cth="$name" "$p1" $par $can $file | scalehls-translate $emit -o $output ;;
      15) scalehls-opt $hta $alp $rvb $cth="$name" "$p2" $par $can $file | scalehls-translate $emit -o $output ;;
      16) scalehls-opt $hta $alp $rvb $cth="$name" "$p3" $par $can $file | scalehls-translate $emit -o $output ;;

      # Apply ... + 1st-level loop tiling + pipeline.
      17) scalehls-opt $hta $alp $rvb "$t1s2" $cth="$name" "$p1" "$u1" $can $file | scalehls-translate $emit -o $output ;;
      18) scalehls-opt $hta $alp $rvb "$t1s4" $cth="$name" "$p1" "$u1" $can $file | scalehls-translate $emit -o $output ;;
      19) scalehls-opt $hta $alp $rvb "$t1s8" $cth="$name" "$p1" "$u1" $can $file | scalehls-translate $emit -o $output ;;

      # Apply ... + 1st-level loop tiling + pipeline + array partition.
      20) scalehls-opt $hta $alp $rvb "$t1s2" $cth="$name" "$p1" "$u1" $par $can $file | scalehls-translate $emit -o $output ;;
      21) scalehls-opt $hta $alp $rvb "$t1s4" $cth="$name" "$p1" "$u1" $par $can $file | scalehls-translate $emit -o $output ;;
      22) scalehls-opt $hta $alp $rvb "$t1s8" $cth="$name" "$p1" "$u1" $par $can $file | scalehls-translate $emit -o $output ;;

      # Apply ... + 2nd-level loop tiling + pipeline.
      23) scalehls-opt $hta $alp $rvb "$t2s2" $cth="$name" "$p2" "$u2" $can $file | scalehls-translate $emit -o $output ;;
      24) scalehls-opt $hta $alp $rvb "$t2s4" $cth="$name" "$p2" "$u2" $can $file | scalehls-translate $emit -o $output ;;
      25) scalehls-opt $hta $alp $rvb "$t2s8" $cth="$name" "$p2" "$u2" $can $file | scalehls-translate $emit -o $output ;;

      # Apply ... + 2nd-level loop tiling + pipeline + array partition.
      26) scalehls-opt $hta $alp $rvb "$t2s2" $cth="$name" "$p2" "$u2" $par $can $file | scalehls-translate $emit -o $output ;;
      27) scalehls-opt $hta $alp $rvb "$t2s4" $cth="$name" "$p2" "$u2" $par $can $file | scalehls-translate $emit -o $output ;;
      28) scalehls-opt $hta $alp $rvb "$t2s8" $cth="$name" "$p2" "$u2" $par $can $file | scalehls-translate $emit -o $output ;;

      # Apply ... + 3rd-level loop tiling + pipeline.
      29) scalehls-opt $hta $alp $rvb "$t3s2" $cth="$name" "$p3" "$u3" $can $file | scalehls-translate $emit -o $output ;;
      30) scalehls-opt $hta $alp $rvb "$t3s4" $cth="$name" "$p3" "$u3" $can $file | scalehls-translate $emit -o $output ;;

      # Apply ... + 3rd-level loop tiling + pipeline + array partition.
      31) scalehls-opt $hta $alp $rvb "$t3s2" $cth="$name" "$p3" "$u3" $par $can $file | scalehls-translate $emit -o $output ;;
      32) scalehls-opt $hta $alp $rvb "$t3s4" $cth="$name" "$p3" "$u3" $par $can $file | scalehls-translate $emit -o $output ;;
    esac
  done

  if [ $n -ge $rerun_csynth_from ]
  then
    # Run HLS synthesis.
    cd hls_proj
    vivado_hls ../hls_script.tcl
    cd ..
  fi

  if [ $n -ge $rerun_csynth_from ]
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

idx=2
for file in cpp_src/*
do
  name=${file##*cpp_src/}
  name=${name%.mlir*}

  n=0
  while [ $n -lt $ablation_number ]
  do
    result=test_results/test_result$n.log

    case $n in
      0) echo -e "$name\t\c" >> test_summary.log ;;

      # Apply pipeline.
      1) echo -e "p0\t\c" >> test_summary.log ;;
      2) echo -e "p1\t\c" >> test_summary.log ;;
      3) echo -e "p2\t\c" >> test_summary.log ;;
      4) echo -e "p3\t\c" >> test_summary.log ;;

      # Apply pipeline + array partition.
      5) echo -e "p0+par\t\c" >> test_summary.log ;;
      6) echo -e "p1+par\t\c" >> test_summary.log ;;
      7) echo -e "p2+par\t\c" >> test_summary.log ;;
      8) echo -e "p3+par\t\c" >> test_summary.log ;;

      # Apply loop perfection + remove variable bound + pipeline.
      9) echo -e "ar+p0\t\c" >> test_summary.log ;;
      10) echo -e "ar+p1\t\c" >> test_summary.log ;;
      11) echo -e "ar+p2\t\c" >> test_summary.log ;;
      12) echo -e "ar+p3\t\c" >> test_summary.log ;;

      # Apply loop perfection + remove variable bound + pipeline + array partition.
      13) echo -e "ar+p0+par\t\c" >> test_summary.log ;;
      14) echo -e "ar+p1+par\t\c" >> test_summary.log ;;
      15) echo -e "ar+p2+par\t\c" >> test_summary.log ;;
      16) echo -e "ar+p3+par\t\c" >> test_summary.log ;;

      # Apply ... + 1st-level loop tiling + pipeline.
      17) echo -e "ar+t1s2+p1\t\c" >> test_summary.log ;;
      18) echo -e "ar+t1s4+p1\t\c" >> test_summary.log ;;
      19) echo -e "ar+t1s8+p1\t\c" >> test_summary.log ;;

      # Apply ... + 1st-level loop tiling + pipeline + array partition.
      20) echo -e "ar+t1s2+p1+par\t\c" >> test_summary.log ;;
      21) echo -e "ar+t1s4+p1+par\t\c" >> test_summary.log ;;
      22) echo -e "ar+t1s8+p1+par\t\c" >> test_summary.log ;;

      # Apply ... + 2nd-level loop tiling + pipeline.
      23) echo -e "ar+t2s2+p2\t\c" >> test_summary.log ;;
      24) echo -e "ar+t2s4+p2\t\c" >> test_summary.log ;;
      25) echo -e "ar+t2s8+p2\t\c" >> test_summary.log ;;

      # Apply ... + 2nd-level loop tiling + pipeline + array partition.
      26) echo -e "ar+t2s2+p2+par\t\c" >> test_summary.log ;;
      27) echo -e "ar+t2s4+p2+par\t\c" >> test_summary.log ;;
      28) echo -e "ar+t2s8+p2+par\t\c" >> test_summary.log ;;

      # Apply ... + 3rd-level loop tiling + pipeline.
      29) echo -e "ar+t3s2+p3\t\c" >> test_summary.log ;;
      30) echo -e "ar+t3s4+p3\t\c" >> test_summary.log ;;

      # Apply ... + 3rd-level loop tiling + pipeline + array partition.
      31) echo -e "ar+t3s2+p3+par\t\c" >> test_summary.log ;;
      32) echo -e "ar+t3s4+p3+par\t\c" >> test_summary.log ;;
    esac

    cat $result | awk "NR==$idx{OFS=\"\t\";print \$2,\$3,\$4}" >> test_summary.log
    let n++
  done

  let idx++
done
