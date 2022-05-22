func @update_weights(%arg0: memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>, %arg1: memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>, %arg2: memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>, %arg3: memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>, %arg4: memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>, %arg5: memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>, %arg6: memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>, %arg7: memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>, %arg8: memref<3xf64, affine_map<(d0) -> (0, d0)>>, %arg9: memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>, %arg10: memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>, %arg11: memref<3xf64, affine_map<(d0) -> (0, d0)>>, %arg12: f64) attributes {llvm.linkage = #llvm.linkage<external>, resource = #hls.r<lut=0, dsp=120, bram=0>, timing = #hls.t<0 -> 870, 870, 870>, top_func} {
  %cst = arith.constant {timing = #hls.t<0 -> 0, 0, 0>} 1.000000e-02 : f64
  affine.for %arg13 = 0 to 13 {
    affine.for %arg14 = 0 to 4 {
      %0 = affine.load %arg3[%arg13 * 64 + %arg14 * 16] {partition_indices = [0], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %1 = arith.mulf %0, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %2 = affine.load %arg0[%arg13 * 64 + %arg14 * 16] {partition_indices = [0], timing = #hls.t<4 -> 6, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %3 = arith.subf %2, %1 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %3, %arg0[%arg13 * 64 + %arg14 * 16] {partition_indices = [0], timing = #hls.t<11 -> 12, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %4 = affine.load %arg3[%arg13 * 64 + %arg14 * 16 + 1] {partition_indices = [1], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %5 = arith.mulf %4, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %6 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 1] {partition_indices = [1], timing = #hls.t<4 -> 6, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %7 = arith.subf %6, %5 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %7, %arg0[%arg13 * 64 + %arg14 * 16 + 1] {partition_indices = [1], timing = #hls.t<11 -> 12, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %8 = affine.load %arg3[%arg13 * 64 + %arg14 * 16 + 2] {partition_indices = [2], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %9 = arith.mulf %8, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %10 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 2] {partition_indices = [2], timing = #hls.t<4 -> 6, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %11 = arith.subf %10, %9 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %11, %arg0[%arg13 * 64 + %arg14 * 16 + 2] {partition_indices = [2], timing = #hls.t<11 -> 12, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %12 = affine.load %arg3[%arg13 * 64 + %arg14 * 16 + 3] {partition_indices = [3], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %13 = arith.mulf %12, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %14 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 3] {partition_indices = [3], timing = #hls.t<4 -> 6, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %15 = arith.subf %14, %13 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %15, %arg0[%arg13 * 64 + %arg14 * 16 + 3] {partition_indices = [3], timing = #hls.t<11 -> 12, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %16 = affine.load %arg3[%arg13 * 64 + %arg14 * 16 + 4] {partition_indices = [4], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %17 = arith.mulf %16, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %18 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 4] {partition_indices = [4], timing = #hls.t<4 -> 6, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %19 = arith.subf %18, %17 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %19, %arg0[%arg13 * 64 + %arg14 * 16 + 4] {partition_indices = [4], timing = #hls.t<11 -> 12, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %20 = affine.load %arg3[%arg13 * 64 + %arg14 * 16 + 5] {partition_indices = [5], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %21 = arith.mulf %20, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %22 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 5] {partition_indices = [5], timing = #hls.t<4 -> 6, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %23 = arith.subf %22, %21 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %23, %arg0[%arg13 * 64 + %arg14 * 16 + 5] {partition_indices = [5], timing = #hls.t<11 -> 12, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %24 = affine.load %arg3[%arg13 * 64 + %arg14 * 16 + 6] {partition_indices = [6], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %25 = arith.mulf %24, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %26 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 6] {partition_indices = [6], timing = #hls.t<4 -> 6, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %27 = arith.subf %26, %25 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %27, %arg0[%arg13 * 64 + %arg14 * 16 + 6] {partition_indices = [6], timing = #hls.t<11 -> 12, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %28 = affine.load %arg3[%arg13 * 64 + %arg14 * 16 + 7] {partition_indices = [7], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %29 = arith.mulf %28, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %30 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 7] {partition_indices = [7], timing = #hls.t<4 -> 6, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %31 = arith.subf %30, %29 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %31, %arg0[%arg13 * 64 + %arg14 * 16 + 7] {partition_indices = [7], timing = #hls.t<11 -> 12, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %32 = affine.load %arg3[%arg13 * 64 + %arg14 * 16 + 8] {partition_indices = [8], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %33 = arith.mulf %32, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %34 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 8] {partition_indices = [8], timing = #hls.t<4 -> 6, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %35 = arith.subf %34, %33 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %35, %arg0[%arg13 * 64 + %arg14 * 16 + 8] {partition_indices = [8], timing = #hls.t<11 -> 12, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %36 = affine.load %arg3[%arg13 * 64 + %arg14 * 16 + 9] {partition_indices = [9], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %37 = arith.mulf %36, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %38 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 9] {partition_indices = [9], timing = #hls.t<4 -> 6, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %39 = arith.subf %38, %37 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %39, %arg0[%arg13 * 64 + %arg14 * 16 + 9] {partition_indices = [9], timing = #hls.t<11 -> 12, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %40 = affine.load %arg3[%arg13 * 64 + %arg14 * 16 + 10] {partition_indices = [10], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %41 = arith.mulf %40, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %42 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 10] {partition_indices = [10], timing = #hls.t<4 -> 6, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %43 = arith.subf %42, %41 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %43, %arg0[%arg13 * 64 + %arg14 * 16 + 10] {partition_indices = [10], timing = #hls.t<11 -> 12, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %44 = affine.load %arg3[%arg13 * 64 + %arg14 * 16 + 11] {partition_indices = [11], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %45 = arith.mulf %44, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %46 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 11] {partition_indices = [11], timing = #hls.t<4 -> 6, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %47 = arith.subf %46, %45 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %47, %arg0[%arg13 * 64 + %arg14 * 16 + 11] {partition_indices = [11], timing = #hls.t<11 -> 12, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %48 = affine.load %arg3[%arg13 * 64 + %arg14 * 16 + 12] {partition_indices = [12], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %49 = arith.mulf %48, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %50 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 12] {partition_indices = [12], timing = #hls.t<4 -> 6, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %51 = arith.subf %50, %49 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %51, %arg0[%arg13 * 64 + %arg14 * 16 + 12] {partition_indices = [12], timing = #hls.t<11 -> 12, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %52 = affine.load %arg3[%arg13 * 64 + %arg14 * 16 + 13] {partition_indices = [13], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %53 = arith.mulf %52, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %54 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 13] {partition_indices = [13], timing = #hls.t<4 -> 6, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %55 = arith.subf %54, %53 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %55, %arg0[%arg13 * 64 + %arg14 * 16 + 13] {partition_indices = [13], timing = #hls.t<11 -> 12, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %56 = affine.load %arg3[%arg13 * 64 + %arg14 * 16 + 14] {partition_indices = [14], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %57 = arith.mulf %56, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %58 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 14] {partition_indices = [14], timing = #hls.t<4 -> 6, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %59 = arith.subf %58, %57 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %59, %arg0[%arg13 * 64 + %arg14 * 16 + 14] {partition_indices = [14], timing = #hls.t<11 -> 12, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %60 = affine.load %arg3[%arg13 * 64 + %arg14 * 16 + 15] {partition_indices = [15], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %61 = arith.mulf %60, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %62 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 15] {partition_indices = [15], timing = #hls.t<4 -> 6, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %63 = arith.subf %62, %61 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %63, %arg0[%arg13 * 64 + %arg14 * 16 + 15] {partition_indices = [15], timing = #hls.t<11 -> 12, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
    } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, loop_info = #hls.l<flattenTripCount=4, iterLatency=12, minII=1>, parallel, timing = #hls.t<803 -> 820, 17, 17>}
  } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, loop_info = #hls.l<flattenTripCount=52, iterLatency=12, minII=1>, parallel, timing = #hls.t<0 -> 65, 65, 65>}
  affine.for %arg13 = 0 to 8 {
    %0 = affine.load %arg9[%arg13 * 8] {partition_indices = [0], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %1 = arith.mulf %0, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %2 = affine.load %arg6[%arg13 * 8] {partition_indices = [0], timing = #hls.t<4 -> 6, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %3 = arith.subf %2, %1 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %3, %arg6[%arg13 * 8] {partition_indices = [0], timing = #hls.t<11 -> 12, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %4 = affine.load %arg9[%arg13 * 8 + 1] {partition_indices = [1], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %5 = arith.mulf %4, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %6 = affine.load %arg6[%arg13 * 8 + 1] {partition_indices = [1], timing = #hls.t<4 -> 6, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %7 = arith.subf %6, %5 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %7, %arg6[%arg13 * 8 + 1] {partition_indices = [1], timing = #hls.t<11 -> 12, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %8 = affine.load %arg9[%arg13 * 8 + 2] {partition_indices = [2], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %9 = arith.mulf %8, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %10 = affine.load %arg6[%arg13 * 8 + 2] {partition_indices = [2], timing = #hls.t<4 -> 6, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %11 = arith.subf %10, %9 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %11, %arg6[%arg13 * 8 + 2] {partition_indices = [2], timing = #hls.t<11 -> 12, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %12 = affine.load %arg9[%arg13 * 8 + 3] {partition_indices = [3], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %13 = arith.mulf %12, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %14 = affine.load %arg6[%arg13 * 8 + 3] {partition_indices = [3], timing = #hls.t<4 -> 6, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %15 = arith.subf %14, %13 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %15, %arg6[%arg13 * 8 + 3] {partition_indices = [3], timing = #hls.t<11 -> 12, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %16 = affine.load %arg9[%arg13 * 8 + 4] {partition_indices = [4], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %17 = arith.mulf %16, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %18 = affine.load %arg6[%arg13 * 8 + 4] {partition_indices = [4], timing = #hls.t<4 -> 6, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %19 = arith.subf %18, %17 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %19, %arg6[%arg13 * 8 + 4] {partition_indices = [4], timing = #hls.t<11 -> 12, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %20 = affine.load %arg9[%arg13 * 8 + 5] {partition_indices = [5], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %21 = arith.mulf %20, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %22 = affine.load %arg6[%arg13 * 8 + 5] {partition_indices = [5], timing = #hls.t<4 -> 6, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %23 = arith.subf %22, %21 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %23, %arg6[%arg13 * 8 + 5] {partition_indices = [5], timing = #hls.t<11 -> 12, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %24 = affine.load %arg9[%arg13 * 8 + 6] {partition_indices = [6], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %25 = arith.mulf %24, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %26 = affine.load %arg6[%arg13 * 8 + 6] {partition_indices = [6], timing = #hls.t<4 -> 6, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %27 = arith.subf %26, %25 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %27, %arg6[%arg13 * 8 + 6] {partition_indices = [6], timing = #hls.t<11 -> 12, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %28 = affine.load %arg9[%arg13 * 8 + 7] {partition_indices = [7], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %29 = arith.mulf %28, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %30 = affine.load %arg6[%arg13 * 8 + 7] {partition_indices = [7], timing = #hls.t<4 -> 6, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %31 = arith.subf %30, %29 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %31, %arg6[%arg13 * 8 + 7] {partition_indices = [7], timing = #hls.t<11 -> 12, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
  } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, loop_info = #hls.l<flattenTripCount=8, iterLatency=12, minII=1>, parallel, timing = #hls.t<65 -> 86, 21, 21>}
  affine.for %arg13 = 0 to 13 {
    affine.for %arg14 = 0 to 4 {
      %0 = affine.load %arg0[%arg13 * 64 + %arg14 * 16] {partition_indices = [0], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %1 = arith.divf %0, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %1, %arg0[%arg13 * 64 + %arg14 * 16] {partition_indices = [0], timing = #hls.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %2 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 1] {partition_indices = [1], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %3 = arith.divf %2, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %3, %arg0[%arg13 * 64 + %arg14 * 16 + 1] {partition_indices = [1], timing = #hls.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %4 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 2] {partition_indices = [2], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %5 = arith.divf %4, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %5, %arg0[%arg13 * 64 + %arg14 * 16 + 2] {partition_indices = [2], timing = #hls.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %6 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 3] {partition_indices = [3], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %7 = arith.divf %6, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %7, %arg0[%arg13 * 64 + %arg14 * 16 + 3] {partition_indices = [3], timing = #hls.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %8 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 4] {partition_indices = [4], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %9 = arith.divf %8, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %9, %arg0[%arg13 * 64 + %arg14 * 16 + 4] {partition_indices = [4], timing = #hls.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %10 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 5] {partition_indices = [5], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %11 = arith.divf %10, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %11, %arg0[%arg13 * 64 + %arg14 * 16 + 5] {partition_indices = [5], timing = #hls.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %12 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 6] {partition_indices = [6], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %13 = arith.divf %12, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %13, %arg0[%arg13 * 64 + %arg14 * 16 + 6] {partition_indices = [6], timing = #hls.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %14 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 7] {partition_indices = [7], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %15 = arith.divf %14, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %15, %arg0[%arg13 * 64 + %arg14 * 16 + 7] {partition_indices = [7], timing = #hls.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %16 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 8] {partition_indices = [8], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %17 = arith.divf %16, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %17, %arg0[%arg13 * 64 + %arg14 * 16 + 8] {partition_indices = [8], timing = #hls.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %18 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 9] {partition_indices = [9], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %19 = arith.divf %18, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %19, %arg0[%arg13 * 64 + %arg14 * 16 + 9] {partition_indices = [9], timing = #hls.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %20 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 10] {partition_indices = [10], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %21 = arith.divf %20, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %21, %arg0[%arg13 * 64 + %arg14 * 16 + 10] {partition_indices = [10], timing = #hls.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %22 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 11] {partition_indices = [11], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %23 = arith.divf %22, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %23, %arg0[%arg13 * 64 + %arg14 * 16 + 11] {partition_indices = [11], timing = #hls.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %24 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 12] {partition_indices = [12], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %25 = arith.divf %24, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %25, %arg0[%arg13 * 64 + %arg14 * 16 + 12] {partition_indices = [12], timing = #hls.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %26 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 13] {partition_indices = [13], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %27 = arith.divf %26, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %27, %arg0[%arg13 * 64 + %arg14 * 16 + 13] {partition_indices = [13], timing = #hls.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %28 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 14] {partition_indices = [14], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %29 = arith.divf %28, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %29, %arg0[%arg13 * 64 + %arg14 * 16 + 14] {partition_indices = [14], timing = #hls.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %30 = affine.load %arg0[%arg13 * 64 + %arg14 * 16 + 15] {partition_indices = [15], timing = #hls.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %31 = arith.divf %30, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %31, %arg0[%arg13 * 64 + %arg14 * 16 + 15] {partition_indices = [15], timing = #hls.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
    } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, loop_info = #hls.l<flattenTripCount=4, iterLatency=19, minII=1>, parallel, timing = #hls.t<710 -> 734, 24, 24>}
  } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, loop_info = #hls.l<flattenTripCount=52, iterLatency=19, minII=1>, parallel, timing = #hls.t<86 -> 158, 72, 72>}
  affine.for %arg13 = 0 to 8 {
    %0 = affine.load %arg6[%arg13 * 8] {partition_indices = [0], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %1 = arith.divf %0, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %1, %arg6[%arg13 * 8] {partition_indices = [0], timing = #hls.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %2 = affine.load %arg6[%arg13 * 8 + 1] {partition_indices = [1], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %3 = arith.divf %2, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %3, %arg6[%arg13 * 8 + 1] {partition_indices = [1], timing = #hls.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %4 = affine.load %arg6[%arg13 * 8 + 2] {partition_indices = [2], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %5 = arith.divf %4, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %5, %arg6[%arg13 * 8 + 2] {partition_indices = [2], timing = #hls.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %6 = affine.load %arg6[%arg13 * 8 + 3] {partition_indices = [3], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %7 = arith.divf %6, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %7, %arg6[%arg13 * 8 + 3] {partition_indices = [3], timing = #hls.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %8 = affine.load %arg6[%arg13 * 8 + 4] {partition_indices = [4], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %9 = arith.divf %8, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %9, %arg6[%arg13 * 8 + 4] {partition_indices = [4], timing = #hls.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %10 = affine.load %arg6[%arg13 * 8 + 5] {partition_indices = [5], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %11 = arith.divf %10, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %11, %arg6[%arg13 * 8 + 5] {partition_indices = [5], timing = #hls.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %12 = affine.load %arg6[%arg13 * 8 + 6] {partition_indices = [6], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %13 = arith.divf %12, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %13, %arg6[%arg13 * 8 + 6] {partition_indices = [6], timing = #hls.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %14 = affine.load %arg6[%arg13 * 8 + 7] {partition_indices = [7], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %15 = arith.divf %14, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %15, %arg6[%arg13 * 8 + 7] {partition_indices = [7], timing = #hls.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
  } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, loop_info = #hls.l<flattenTripCount=8, iterLatency=19, minII=1>, parallel, timing = #hls.t<158 -> 186, 28, 28>}
  affine.for %arg13 = 0 to 64 {
    affine.for %arg14 = 0 to 4 {
      %0 = affine.load %arg4[%arg13 * 64 + %arg14 * 16] {partition_indices = [0], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %1 = arith.mulf %0, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %2 = affine.load %arg1[%arg13 * 64 + %arg14 * 16] {partition_indices = [0], timing = #hls.t<4 -> 6, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %3 = arith.subf %2, %1 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %3, %arg1[%arg13 * 64 + %arg14 * 16] {partition_indices = [0], timing = #hls.t<11 -> 12, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %4 = affine.load %arg4[%arg13 * 64 + %arg14 * 16 + 1] {partition_indices = [1], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %5 = arith.mulf %4, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %6 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 1] {partition_indices = [1], timing = #hls.t<4 -> 6, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %7 = arith.subf %6, %5 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %7, %arg1[%arg13 * 64 + %arg14 * 16 + 1] {partition_indices = [1], timing = #hls.t<11 -> 12, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %8 = affine.load %arg4[%arg13 * 64 + %arg14 * 16 + 2] {partition_indices = [2], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %9 = arith.mulf %8, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %10 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 2] {partition_indices = [2], timing = #hls.t<4 -> 6, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %11 = arith.subf %10, %9 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %11, %arg1[%arg13 * 64 + %arg14 * 16 + 2] {partition_indices = [2], timing = #hls.t<11 -> 12, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %12 = affine.load %arg4[%arg13 * 64 + %arg14 * 16 + 3] {partition_indices = [3], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %13 = arith.mulf %12, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %14 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 3] {partition_indices = [3], timing = #hls.t<4 -> 6, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %15 = arith.subf %14, %13 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %15, %arg1[%arg13 * 64 + %arg14 * 16 + 3] {partition_indices = [3], timing = #hls.t<11 -> 12, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %16 = affine.load %arg4[%arg13 * 64 + %arg14 * 16 + 4] {partition_indices = [4], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %17 = arith.mulf %16, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %18 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 4] {partition_indices = [4], timing = #hls.t<4 -> 6, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %19 = arith.subf %18, %17 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %19, %arg1[%arg13 * 64 + %arg14 * 16 + 4] {partition_indices = [4], timing = #hls.t<11 -> 12, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %20 = affine.load %arg4[%arg13 * 64 + %arg14 * 16 + 5] {partition_indices = [5], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %21 = arith.mulf %20, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %22 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 5] {partition_indices = [5], timing = #hls.t<4 -> 6, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %23 = arith.subf %22, %21 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %23, %arg1[%arg13 * 64 + %arg14 * 16 + 5] {partition_indices = [5], timing = #hls.t<11 -> 12, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %24 = affine.load %arg4[%arg13 * 64 + %arg14 * 16 + 6] {partition_indices = [6], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %25 = arith.mulf %24, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %26 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 6] {partition_indices = [6], timing = #hls.t<4 -> 6, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %27 = arith.subf %26, %25 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %27, %arg1[%arg13 * 64 + %arg14 * 16 + 6] {partition_indices = [6], timing = #hls.t<11 -> 12, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %28 = affine.load %arg4[%arg13 * 64 + %arg14 * 16 + 7] {partition_indices = [7], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %29 = arith.mulf %28, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %30 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 7] {partition_indices = [7], timing = #hls.t<4 -> 6, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %31 = arith.subf %30, %29 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %31, %arg1[%arg13 * 64 + %arg14 * 16 + 7] {partition_indices = [7], timing = #hls.t<11 -> 12, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %32 = affine.load %arg4[%arg13 * 64 + %arg14 * 16 + 8] {partition_indices = [8], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %33 = arith.mulf %32, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %34 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 8] {partition_indices = [8], timing = #hls.t<4 -> 6, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %35 = arith.subf %34, %33 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %35, %arg1[%arg13 * 64 + %arg14 * 16 + 8] {partition_indices = [8], timing = #hls.t<11 -> 12, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %36 = affine.load %arg4[%arg13 * 64 + %arg14 * 16 + 9] {partition_indices = [9], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %37 = arith.mulf %36, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %38 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 9] {partition_indices = [9], timing = #hls.t<4 -> 6, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %39 = arith.subf %38, %37 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %39, %arg1[%arg13 * 64 + %arg14 * 16 + 9] {partition_indices = [9], timing = #hls.t<11 -> 12, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %40 = affine.load %arg4[%arg13 * 64 + %arg14 * 16 + 10] {partition_indices = [10], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %41 = arith.mulf %40, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %42 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 10] {partition_indices = [10], timing = #hls.t<4 -> 6, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %43 = arith.subf %42, %41 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %43, %arg1[%arg13 * 64 + %arg14 * 16 + 10] {partition_indices = [10], timing = #hls.t<11 -> 12, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %44 = affine.load %arg4[%arg13 * 64 + %arg14 * 16 + 11] {partition_indices = [11], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %45 = arith.mulf %44, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %46 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 11] {partition_indices = [11], timing = #hls.t<4 -> 6, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %47 = arith.subf %46, %45 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %47, %arg1[%arg13 * 64 + %arg14 * 16 + 11] {partition_indices = [11], timing = #hls.t<11 -> 12, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %48 = affine.load %arg4[%arg13 * 64 + %arg14 * 16 + 12] {partition_indices = [12], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %49 = arith.mulf %48, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %50 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 12] {partition_indices = [12], timing = #hls.t<4 -> 6, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %51 = arith.subf %50, %49 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %51, %arg1[%arg13 * 64 + %arg14 * 16 + 12] {partition_indices = [12], timing = #hls.t<11 -> 12, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %52 = affine.load %arg4[%arg13 * 64 + %arg14 * 16 + 13] {partition_indices = [13], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %53 = arith.mulf %52, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %54 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 13] {partition_indices = [13], timing = #hls.t<4 -> 6, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %55 = arith.subf %54, %53 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %55, %arg1[%arg13 * 64 + %arg14 * 16 + 13] {partition_indices = [13], timing = #hls.t<11 -> 12, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %56 = affine.load %arg4[%arg13 * 64 + %arg14 * 16 + 14] {partition_indices = [14], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %57 = arith.mulf %56, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %58 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 14] {partition_indices = [14], timing = #hls.t<4 -> 6, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %59 = arith.subf %58, %57 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %59, %arg1[%arg13 * 64 + %arg14 * 16 + 14] {partition_indices = [14], timing = #hls.t<11 -> 12, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %60 = affine.load %arg4[%arg13 * 64 + %arg14 * 16 + 15] {partition_indices = [15], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %61 = arith.mulf %60, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
      %62 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 15] {partition_indices = [15], timing = #hls.t<4 -> 6, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %63 = arith.subf %62, %61 {timing = #hls.t<6 -> 11, 5, 1>} : f64
      affine.store %63, %arg1[%arg13 * 64 + %arg14 * 16 + 15] {partition_indices = [15], timing = #hls.t<11 -> 12, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
    } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, loop_info = #hls.l<flattenTripCount=4, iterLatency=12, minII=1>, parallel, timing = #hls.t<413 -> 430, 17, 17>}
  } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, loop_info = #hls.l<flattenTripCount=256, iterLatency=12, minII=1>, parallel, timing = #hls.t<186 -> 455, 269, 269>}
  affine.for %arg13 = 0 to 8 {
    %0 = affine.load %arg10[%arg13 * 8] {partition_indices = [0], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %1 = arith.mulf %0, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %2 = affine.load %arg7[%arg13 * 8] {partition_indices = [0], timing = #hls.t<4 -> 6, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %3 = arith.subf %2, %1 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %3, %arg7[%arg13 * 8] {partition_indices = [0], timing = #hls.t<11 -> 12, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %4 = affine.load %arg10[%arg13 * 8 + 1] {partition_indices = [1], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %5 = arith.mulf %4, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %6 = affine.load %arg7[%arg13 * 8 + 1] {partition_indices = [1], timing = #hls.t<4 -> 6, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %7 = arith.subf %6, %5 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %7, %arg7[%arg13 * 8 + 1] {partition_indices = [1], timing = #hls.t<11 -> 12, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %8 = affine.load %arg10[%arg13 * 8 + 2] {partition_indices = [2], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %9 = arith.mulf %8, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %10 = affine.load %arg7[%arg13 * 8 + 2] {partition_indices = [2], timing = #hls.t<4 -> 6, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %11 = arith.subf %10, %9 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %11, %arg7[%arg13 * 8 + 2] {partition_indices = [2], timing = #hls.t<11 -> 12, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %12 = affine.load %arg10[%arg13 * 8 + 3] {partition_indices = [3], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %13 = arith.mulf %12, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %14 = affine.load %arg7[%arg13 * 8 + 3] {partition_indices = [3], timing = #hls.t<4 -> 6, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %15 = arith.subf %14, %13 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %15, %arg7[%arg13 * 8 + 3] {partition_indices = [3], timing = #hls.t<11 -> 12, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %16 = affine.load %arg10[%arg13 * 8 + 4] {partition_indices = [4], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %17 = arith.mulf %16, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %18 = affine.load %arg7[%arg13 * 8 + 4] {partition_indices = [4], timing = #hls.t<4 -> 6, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %19 = arith.subf %18, %17 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %19, %arg7[%arg13 * 8 + 4] {partition_indices = [4], timing = #hls.t<11 -> 12, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %20 = affine.load %arg10[%arg13 * 8 + 5] {partition_indices = [5], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %21 = arith.mulf %20, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %22 = affine.load %arg7[%arg13 * 8 + 5] {partition_indices = [5], timing = #hls.t<4 -> 6, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %23 = arith.subf %22, %21 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %23, %arg7[%arg13 * 8 + 5] {partition_indices = [5], timing = #hls.t<11 -> 12, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %24 = affine.load %arg10[%arg13 * 8 + 6] {partition_indices = [6], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %25 = arith.mulf %24, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %26 = affine.load %arg7[%arg13 * 8 + 6] {partition_indices = [6], timing = #hls.t<4 -> 6, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %27 = arith.subf %26, %25 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %27, %arg7[%arg13 * 8 + 6] {partition_indices = [6], timing = #hls.t<11 -> 12, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %28 = affine.load %arg10[%arg13 * 8 + 7] {partition_indices = [7], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %29 = arith.mulf %28, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %30 = affine.load %arg7[%arg13 * 8 + 7] {partition_indices = [7], timing = #hls.t<4 -> 6, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %31 = arith.subf %30, %29 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %31, %arg7[%arg13 * 8 + 7] {partition_indices = [7], timing = #hls.t<11 -> 12, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
  } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, loop_info = #hls.l<flattenTripCount=8, iterLatency=12, minII=1>, parallel, timing = #hls.t<455 -> 476, 21, 21>}
  affine.for %arg13 = 0 to 64 {
    affine.for %arg14 = 0 to 4 {
      %0 = affine.load %arg1[%arg13 * 64 + %arg14 * 16] {partition_indices = [0], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %1 = arith.divf %0, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %1, %arg1[%arg13 * 64 + %arg14 * 16] {partition_indices = [0], timing = #hls.t<18 -> 19, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %2 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 1] {partition_indices = [1], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %3 = arith.divf %2, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %3, %arg1[%arg13 * 64 + %arg14 * 16 + 1] {partition_indices = [1], timing = #hls.t<18 -> 19, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %4 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 2] {partition_indices = [2], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %5 = arith.divf %4, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %5, %arg1[%arg13 * 64 + %arg14 * 16 + 2] {partition_indices = [2], timing = #hls.t<18 -> 19, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %6 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 3] {partition_indices = [3], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %7 = arith.divf %6, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %7, %arg1[%arg13 * 64 + %arg14 * 16 + 3] {partition_indices = [3], timing = #hls.t<18 -> 19, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %8 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 4] {partition_indices = [4], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %9 = arith.divf %8, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %9, %arg1[%arg13 * 64 + %arg14 * 16 + 4] {partition_indices = [4], timing = #hls.t<18 -> 19, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %10 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 5] {partition_indices = [5], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %11 = arith.divf %10, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %11, %arg1[%arg13 * 64 + %arg14 * 16 + 5] {partition_indices = [5], timing = #hls.t<18 -> 19, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %12 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 6] {partition_indices = [6], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %13 = arith.divf %12, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %13, %arg1[%arg13 * 64 + %arg14 * 16 + 6] {partition_indices = [6], timing = #hls.t<18 -> 19, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %14 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 7] {partition_indices = [7], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %15 = arith.divf %14, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %15, %arg1[%arg13 * 64 + %arg14 * 16 + 7] {partition_indices = [7], timing = #hls.t<18 -> 19, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %16 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 8] {partition_indices = [8], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %17 = arith.divf %16, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %17, %arg1[%arg13 * 64 + %arg14 * 16 + 8] {partition_indices = [8], timing = #hls.t<18 -> 19, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %18 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 9] {partition_indices = [9], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %19 = arith.divf %18, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %19, %arg1[%arg13 * 64 + %arg14 * 16 + 9] {partition_indices = [9], timing = #hls.t<18 -> 19, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %20 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 10] {partition_indices = [10], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %21 = arith.divf %20, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %21, %arg1[%arg13 * 64 + %arg14 * 16 + 10] {partition_indices = [10], timing = #hls.t<18 -> 19, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %22 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 11] {partition_indices = [11], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %23 = arith.divf %22, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %23, %arg1[%arg13 * 64 + %arg14 * 16 + 11] {partition_indices = [11], timing = #hls.t<18 -> 19, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %24 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 12] {partition_indices = [12], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %25 = arith.divf %24, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %25, %arg1[%arg13 * 64 + %arg14 * 16 + 12] {partition_indices = [12], timing = #hls.t<18 -> 19, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %26 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 13] {partition_indices = [13], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %27 = arith.divf %26, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %27, %arg1[%arg13 * 64 + %arg14 * 16 + 13] {partition_indices = [13], timing = #hls.t<18 -> 19, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %28 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 14] {partition_indices = [14], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %29 = arith.divf %28, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %29, %arg1[%arg13 * 64 + %arg14 * 16 + 14] {partition_indices = [14], timing = #hls.t<18 -> 19, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %30 = affine.load %arg1[%arg13 * 64 + %arg14 * 16 + 15] {partition_indices = [15], timing = #hls.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
      %31 = arith.divf %30, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
      affine.store %31, %arg1[%arg13 * 64 + %arg14 * 16 + 15] {partition_indices = [15], timing = #hls.t<18 -> 19, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>>
    } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, loop_info = #hls.l<flattenTripCount=4, iterLatency=19, minII=1>, parallel, timing = #hls.t<116 -> 140, 24, 24>}
  } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, loop_info = #hls.l<flattenTripCount=256, iterLatency=19, minII=1>, parallel, timing = #hls.t<476 -> 752, 276, 276>}
  affine.for %arg13 = 0 to 8 {
    %0 = affine.load %arg7[%arg13 * 8] {partition_indices = [0], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %1 = arith.divf %0, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %1, %arg7[%arg13 * 8] {partition_indices = [0], timing = #hls.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %2 = affine.load %arg7[%arg13 * 8 + 1] {partition_indices = [1], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %3 = arith.divf %2, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %3, %arg7[%arg13 * 8 + 1] {partition_indices = [1], timing = #hls.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %4 = affine.load %arg7[%arg13 * 8 + 2] {partition_indices = [2], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %5 = arith.divf %4, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %5, %arg7[%arg13 * 8 + 2] {partition_indices = [2], timing = #hls.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %6 = affine.load %arg7[%arg13 * 8 + 3] {partition_indices = [3], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %7 = arith.divf %6, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %7, %arg7[%arg13 * 8 + 3] {partition_indices = [3], timing = #hls.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %8 = affine.load %arg7[%arg13 * 8 + 4] {partition_indices = [4], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %9 = arith.divf %8, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %9, %arg7[%arg13 * 8 + 4] {partition_indices = [4], timing = #hls.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %10 = affine.load %arg7[%arg13 * 8 + 5] {partition_indices = [5], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %11 = arith.divf %10, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %11, %arg7[%arg13 * 8 + 5] {partition_indices = [5], timing = #hls.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %12 = affine.load %arg7[%arg13 * 8 + 6] {partition_indices = [6], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %13 = arith.divf %12, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %13, %arg7[%arg13 * 8 + 6] {partition_indices = [6], timing = #hls.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %14 = affine.load %arg7[%arg13 * 8 + 7] {partition_indices = [7], timing = #hls.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
    %15 = arith.divf %14, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %15, %arg7[%arg13 * 8 + 7] {partition_indices = [7], timing = #hls.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>>
  } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, loop_info = #hls.l<flattenTripCount=8, iterLatency=19, minII=1>, parallel, timing = #hls.t<752 -> 780, 28, 28>}
  affine.for %arg13 = 0 to 8 {
    %0 = affine.load %arg5[%arg13 * 24] {partition_indices = [0], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %1 = arith.mulf %0, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %2 = affine.load %arg2[%arg13 * 24] {partition_indices = [0], timing = #hls.t<4 -> 6, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %3 = arith.subf %2, %1 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %3, %arg2[%arg13 * 24] {partition_indices = [0], timing = #hls.t<11 -> 12, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %4 = affine.load %arg5[%arg13 * 24 + 1] {partition_indices = [1], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %5 = arith.mulf %4, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %6 = affine.load %arg2[%arg13 * 24 + 1] {partition_indices = [1], timing = #hls.t<4 -> 6, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %7 = arith.subf %6, %5 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %7, %arg2[%arg13 * 24 + 1] {partition_indices = [1], timing = #hls.t<11 -> 12, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %8 = affine.load %arg5[%arg13 * 24 + 2] {partition_indices = [2], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %9 = arith.mulf %8, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %10 = affine.load %arg2[%arg13 * 24 + 2] {partition_indices = [2], timing = #hls.t<4 -> 6, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %11 = arith.subf %10, %9 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %11, %arg2[%arg13 * 24 + 2] {partition_indices = [2], timing = #hls.t<11 -> 12, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %12 = affine.load %arg5[%arg13 * 24 + 3] {partition_indices = [3], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %13 = arith.mulf %12, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %14 = affine.load %arg2[%arg13 * 24 + 3] {partition_indices = [3], timing = #hls.t<4 -> 6, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %15 = arith.subf %14, %13 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %15, %arg2[%arg13 * 24 + 3] {partition_indices = [3], timing = #hls.t<11 -> 12, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %16 = affine.load %arg5[%arg13 * 24 + 4] {partition_indices = [4], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %17 = arith.mulf %16, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %18 = affine.load %arg2[%arg13 * 24 + 4] {partition_indices = [4], timing = #hls.t<4 -> 6, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %19 = arith.subf %18, %17 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %19, %arg2[%arg13 * 24 + 4] {partition_indices = [4], timing = #hls.t<11 -> 12, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %20 = affine.load %arg5[%arg13 * 24 + 5] {partition_indices = [5], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %21 = arith.mulf %20, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %22 = affine.load %arg2[%arg13 * 24 + 5] {partition_indices = [5], timing = #hls.t<4 -> 6, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %23 = arith.subf %22, %21 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %23, %arg2[%arg13 * 24 + 5] {partition_indices = [5], timing = #hls.t<11 -> 12, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %24 = affine.load %arg5[%arg13 * 24 + 6] {partition_indices = [6], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %25 = arith.mulf %24, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %26 = affine.load %arg2[%arg13 * 24 + 6] {partition_indices = [6], timing = #hls.t<4 -> 6, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %27 = arith.subf %26, %25 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %27, %arg2[%arg13 * 24 + 6] {partition_indices = [6], timing = #hls.t<11 -> 12, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %28 = affine.load %arg5[%arg13 * 24 + 7] {partition_indices = [7], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %29 = arith.mulf %28, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %30 = affine.load %arg2[%arg13 * 24 + 7] {partition_indices = [7], timing = #hls.t<4 -> 6, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %31 = arith.subf %30, %29 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %31, %arg2[%arg13 * 24 + 7] {partition_indices = [7], timing = #hls.t<11 -> 12, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %32 = affine.load %arg5[%arg13 * 24 + 8] {partition_indices = [8], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %33 = arith.mulf %32, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %34 = affine.load %arg2[%arg13 * 24 + 8] {partition_indices = [8], timing = #hls.t<4 -> 6, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %35 = arith.subf %34, %33 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %35, %arg2[%arg13 * 24 + 8] {partition_indices = [8], timing = #hls.t<11 -> 12, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %36 = affine.load %arg5[%arg13 * 24 + 9] {partition_indices = [9], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %37 = arith.mulf %36, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %38 = affine.load %arg2[%arg13 * 24 + 9] {partition_indices = [9], timing = #hls.t<4 -> 6, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %39 = arith.subf %38, %37 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %39, %arg2[%arg13 * 24 + 9] {partition_indices = [9], timing = #hls.t<11 -> 12, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %40 = affine.load %arg5[%arg13 * 24 + 10] {partition_indices = [10], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %41 = arith.mulf %40, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %42 = affine.load %arg2[%arg13 * 24 + 10] {partition_indices = [10], timing = #hls.t<4 -> 6, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %43 = arith.subf %42, %41 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %43, %arg2[%arg13 * 24 + 10] {partition_indices = [10], timing = #hls.t<11 -> 12, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %44 = affine.load %arg5[%arg13 * 24 + 11] {partition_indices = [11], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %45 = arith.mulf %44, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %46 = affine.load %arg2[%arg13 * 24 + 11] {partition_indices = [11], timing = #hls.t<4 -> 6, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %47 = arith.subf %46, %45 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %47, %arg2[%arg13 * 24 + 11] {partition_indices = [11], timing = #hls.t<11 -> 12, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %48 = affine.load %arg5[%arg13 * 24 + 12] {partition_indices = [12], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %49 = arith.mulf %48, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %50 = affine.load %arg2[%arg13 * 24 + 12] {partition_indices = [12], timing = #hls.t<4 -> 6, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %51 = arith.subf %50, %49 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %51, %arg2[%arg13 * 24 + 12] {partition_indices = [12], timing = #hls.t<11 -> 12, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %52 = affine.load %arg5[%arg13 * 24 + 13] {partition_indices = [13], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %53 = arith.mulf %52, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %54 = affine.load %arg2[%arg13 * 24 + 13] {partition_indices = [13], timing = #hls.t<4 -> 6, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %55 = arith.subf %54, %53 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %55, %arg2[%arg13 * 24 + 13] {partition_indices = [13], timing = #hls.t<11 -> 12, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %56 = affine.load %arg5[%arg13 * 24 + 14] {partition_indices = [14], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %57 = arith.mulf %56, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %58 = affine.load %arg2[%arg13 * 24 + 14] {partition_indices = [14], timing = #hls.t<4 -> 6, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %59 = arith.subf %58, %57 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %59, %arg2[%arg13 * 24 + 14] {partition_indices = [14], timing = #hls.t<11 -> 12, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %60 = affine.load %arg5[%arg13 * 24 + 15] {partition_indices = [15], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %61 = arith.mulf %60, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %62 = affine.load %arg2[%arg13 * 24 + 15] {partition_indices = [15], timing = #hls.t<4 -> 6, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %63 = arith.subf %62, %61 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %63, %arg2[%arg13 * 24 + 15] {partition_indices = [15], timing = #hls.t<11 -> 12, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %64 = affine.load %arg5[%arg13 * 24 + 16] {partition_indices = [16], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %65 = arith.mulf %64, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %66 = affine.load %arg2[%arg13 * 24 + 16] {partition_indices = [16], timing = #hls.t<4 -> 6, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %67 = arith.subf %66, %65 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %67, %arg2[%arg13 * 24 + 16] {partition_indices = [16], timing = #hls.t<11 -> 12, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %68 = affine.load %arg5[%arg13 * 24 + 17] {partition_indices = [17], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %69 = arith.mulf %68, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %70 = affine.load %arg2[%arg13 * 24 + 17] {partition_indices = [17], timing = #hls.t<4 -> 6, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %71 = arith.subf %70, %69 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %71, %arg2[%arg13 * 24 + 17] {partition_indices = [17], timing = #hls.t<11 -> 12, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %72 = affine.load %arg5[%arg13 * 24 + 18] {partition_indices = [18], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %73 = arith.mulf %72, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %74 = affine.load %arg2[%arg13 * 24 + 18] {partition_indices = [18], timing = #hls.t<4 -> 6, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %75 = arith.subf %74, %73 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %75, %arg2[%arg13 * 24 + 18] {partition_indices = [18], timing = #hls.t<11 -> 12, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %76 = affine.load %arg5[%arg13 * 24 + 19] {partition_indices = [19], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %77 = arith.mulf %76, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %78 = affine.load %arg2[%arg13 * 24 + 19] {partition_indices = [19], timing = #hls.t<4 -> 6, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %79 = arith.subf %78, %77 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %79, %arg2[%arg13 * 24 + 19] {partition_indices = [19], timing = #hls.t<11 -> 12, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %80 = affine.load %arg5[%arg13 * 24 + 20] {partition_indices = [20], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %81 = arith.mulf %80, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %82 = affine.load %arg2[%arg13 * 24 + 20] {partition_indices = [20], timing = #hls.t<4 -> 6, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %83 = arith.subf %82, %81 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %83, %arg2[%arg13 * 24 + 20] {partition_indices = [20], timing = #hls.t<11 -> 12, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %84 = affine.load %arg5[%arg13 * 24 + 21] {partition_indices = [21], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %85 = arith.mulf %84, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %86 = affine.load %arg2[%arg13 * 24 + 21] {partition_indices = [21], timing = #hls.t<4 -> 6, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %87 = arith.subf %86, %85 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %87, %arg2[%arg13 * 24 + 21] {partition_indices = [21], timing = #hls.t<11 -> 12, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %88 = affine.load %arg5[%arg13 * 24 + 22] {partition_indices = [22], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %89 = arith.mulf %88, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %90 = affine.load %arg2[%arg13 * 24 + 22] {partition_indices = [22], timing = #hls.t<4 -> 6, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %91 = arith.subf %90, %89 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %91, %arg2[%arg13 * 24 + 22] {partition_indices = [22], timing = #hls.t<11 -> 12, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %92 = affine.load %arg5[%arg13 * 24 + 23] {partition_indices = [23], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %93 = arith.mulf %92, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %94 = affine.load %arg2[%arg13 * 24 + 23] {partition_indices = [23], timing = #hls.t<4 -> 6, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %95 = arith.subf %94, %93 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %95, %arg2[%arg13 * 24 + 23] {partition_indices = [23], timing = #hls.t<11 -> 12, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
  } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, loop_info = #hls.l<flattenTripCount=8, iterLatency=12, minII=1>, parallel, timing = #hls.t<780 -> 801, 21, 21>}
  affine.for %arg13 = 0 to 3 {
    %0 = affine.load %arg11[%arg13] {partition_indices = [0], timing = #hls.t<0 -> 2, 2, 1>} : memref<3xf64, affine_map<(d0) -> (0, d0)>>
    %1 = arith.mulf %0, %cst {timing = #hls.t<2 -> 6, 4, 1>} : f64
    %2 = affine.load %arg8[%arg13] {partition_indices = [0], timing = #hls.t<4 -> 6, 2, 1>} : memref<3xf64, affine_map<(d0) -> (0, d0)>>
    %3 = arith.subf %2, %1 {timing = #hls.t<6 -> 11, 5, 1>} : f64
    affine.store %3, %arg8[%arg13] {partition_indices = [0], timing = #hls.t<11 -> 12, 1, 1>} : memref<3xf64, affine_map<(d0) -> (0, d0)>>
  } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, loop_info = #hls.l<flattenTripCount=3, iterLatency=12, minII=1>, parallel, timing = #hls.t<801 -> 817, 16, 16>}
  affine.for %arg13 = 0 to 8 {
    %0 = affine.load %arg2[%arg13 * 24] {partition_indices = [0], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %1 = arith.divf %0, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %1, %arg2[%arg13 * 24] {partition_indices = [0], timing = #hls.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %2 = affine.load %arg2[%arg13 * 24 + 1] {partition_indices = [1], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %3 = arith.divf %2, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %3, %arg2[%arg13 * 24 + 1] {partition_indices = [1], timing = #hls.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %4 = affine.load %arg2[%arg13 * 24 + 2] {partition_indices = [2], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %5 = arith.divf %4, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %5, %arg2[%arg13 * 24 + 2] {partition_indices = [2], timing = #hls.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %6 = affine.load %arg2[%arg13 * 24 + 3] {partition_indices = [3], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %7 = arith.divf %6, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %7, %arg2[%arg13 * 24 + 3] {partition_indices = [3], timing = #hls.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %8 = affine.load %arg2[%arg13 * 24 + 4] {partition_indices = [4], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %9 = arith.divf %8, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %9, %arg2[%arg13 * 24 + 4] {partition_indices = [4], timing = #hls.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %10 = affine.load %arg2[%arg13 * 24 + 5] {partition_indices = [5], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %11 = arith.divf %10, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %11, %arg2[%arg13 * 24 + 5] {partition_indices = [5], timing = #hls.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %12 = affine.load %arg2[%arg13 * 24 + 6] {partition_indices = [6], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %13 = arith.divf %12, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %13, %arg2[%arg13 * 24 + 6] {partition_indices = [6], timing = #hls.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %14 = affine.load %arg2[%arg13 * 24 + 7] {partition_indices = [7], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %15 = arith.divf %14, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %15, %arg2[%arg13 * 24 + 7] {partition_indices = [7], timing = #hls.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %16 = affine.load %arg2[%arg13 * 24 + 8] {partition_indices = [8], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %17 = arith.divf %16, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %17, %arg2[%arg13 * 24 + 8] {partition_indices = [8], timing = #hls.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %18 = affine.load %arg2[%arg13 * 24 + 9] {partition_indices = [9], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %19 = arith.divf %18, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %19, %arg2[%arg13 * 24 + 9] {partition_indices = [9], timing = #hls.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %20 = affine.load %arg2[%arg13 * 24 + 10] {partition_indices = [10], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %21 = arith.divf %20, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %21, %arg2[%arg13 * 24 + 10] {partition_indices = [10], timing = #hls.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %22 = affine.load %arg2[%arg13 * 24 + 11] {partition_indices = [11], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %23 = arith.divf %22, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %23, %arg2[%arg13 * 24 + 11] {partition_indices = [11], timing = #hls.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %24 = affine.load %arg2[%arg13 * 24 + 12] {partition_indices = [12], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %25 = arith.divf %24, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %25, %arg2[%arg13 * 24 + 12] {partition_indices = [12], timing = #hls.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %26 = affine.load %arg2[%arg13 * 24 + 13] {partition_indices = [13], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %27 = arith.divf %26, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %27, %arg2[%arg13 * 24 + 13] {partition_indices = [13], timing = #hls.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %28 = affine.load %arg2[%arg13 * 24 + 14] {partition_indices = [14], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %29 = arith.divf %28, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %29, %arg2[%arg13 * 24 + 14] {partition_indices = [14], timing = #hls.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %30 = affine.load %arg2[%arg13 * 24 + 15] {partition_indices = [15], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %31 = arith.divf %30, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %31, %arg2[%arg13 * 24 + 15] {partition_indices = [15], timing = #hls.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %32 = affine.load %arg2[%arg13 * 24 + 16] {partition_indices = [16], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %33 = arith.divf %32, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %33, %arg2[%arg13 * 24 + 16] {partition_indices = [16], timing = #hls.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %34 = affine.load %arg2[%arg13 * 24 + 17] {partition_indices = [17], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %35 = arith.divf %34, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %35, %arg2[%arg13 * 24 + 17] {partition_indices = [17], timing = #hls.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %36 = affine.load %arg2[%arg13 * 24 + 18] {partition_indices = [18], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %37 = arith.divf %36, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %37, %arg2[%arg13 * 24 + 18] {partition_indices = [18], timing = #hls.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %38 = affine.load %arg2[%arg13 * 24 + 19] {partition_indices = [19], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %39 = arith.divf %38, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %39, %arg2[%arg13 * 24 + 19] {partition_indices = [19], timing = #hls.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %40 = affine.load %arg2[%arg13 * 24 + 20] {partition_indices = [20], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %41 = arith.divf %40, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %41, %arg2[%arg13 * 24 + 20] {partition_indices = [20], timing = #hls.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %42 = affine.load %arg2[%arg13 * 24 + 21] {partition_indices = [21], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %43 = arith.divf %42, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %43, %arg2[%arg13 * 24 + 21] {partition_indices = [21], timing = #hls.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %44 = affine.load %arg2[%arg13 * 24 + 22] {partition_indices = [22], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %45 = arith.divf %44, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %45, %arg2[%arg13 * 24 + 22] {partition_indices = [22], timing = #hls.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %46 = affine.load %arg2[%arg13 * 24 + 23] {partition_indices = [23], timing = #hls.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
    %47 = arith.divf %46, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %47, %arg2[%arg13 * 24 + 23] {partition_indices = [23], timing = #hls.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>>
  } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, loop_info = #hls.l<flattenTripCount=8, iterLatency=19, minII=1>, parallel, timing = #hls.t<817 -> 845, 28, 28>}
  affine.for %arg13 = 0 to 3 {
    %0 = affine.load %arg8[%arg13] {partition_indices = [0], timing = #hls.t<0 -> 2, 2, 1>} : memref<3xf64, affine_map<(d0) -> (0, d0)>>
    %1 = arith.divf %0, %arg12 {timing = #hls.t<2 -> 18, 16, 1>} : f64
    affine.store %1, %arg8[%arg13] {partition_indices = [0], timing = #hls.t<18 -> 19, 1, 1>} : memref<3xf64, affine_map<(d0) -> (0, d0)>>
  } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, loop_info = #hls.l<flattenTripCount=3, iterLatency=19, minII=1>, parallel, timing = #hls.t<845 -> 868, 23, 23>}
  return {timing = #hls.t<868 -> 868, 0, 0>}
}
