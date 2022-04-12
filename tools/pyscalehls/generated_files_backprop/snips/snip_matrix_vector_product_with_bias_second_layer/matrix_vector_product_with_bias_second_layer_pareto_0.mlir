func @matrix_vector_product_with_bias_second_layer(%arg0: memref<64xf64>, %arg1: memref<4096xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>, %arg2: memref<64xf64, affine_map<(d0) -> (0, d0)>, 1>, %arg3: memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>, %arg4: memref<1xf64, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>, llvm.linkage = #llvm.linkage<external>, resource = #hlscpp.r<lut=0, dsp=40, bram=0>, timing = #hlscpp.t<0 -> 563, 563, 563>} {
  %cst = arith.constant {timing = #hlscpp.t<560 -> 560, 0, 0>} 42.424242419999999 : f64
  %cst_0 = arith.constant {timing = #hlscpp.t<0 -> 0, 0, 0>} 0.000000e+00 : f64
  affine.for %arg5 = 0 to 8 {
    affine.for %arg6 = 0 to 64 {
      %0 = affine.load %arg1[%arg6 * 64 + %arg5 * 8] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
      %1 = affine.load %arg3[%arg5 * 8] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
      %2 = arith.mulf %0, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
      %3 = affine.load %arg2[%arg6] {max_mux_size = 1 : i64, partition_indices = [0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<64xf64, affine_map<(d0) -> (0, d0)>, 1>
      %4 = affine.if affine_set<(d0) : (d0 * 8 == 0)>(%arg5) -> f64 {
        affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %cst_0 : f64
      } else {
        affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %3 : f64
      } {timing = #hlscpp.t<6 -> 6, 0, 0>}
      %5 = arith.addf %4, %2 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
      %6 = affine.load %arg1[%arg6 * 64 + %arg5 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
      %7 = affine.load %arg3[%arg5 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
      %8 = arith.mulf %6, %7 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
      %9 = arith.addf %5, %8 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
      %10 = affine.load %arg1[%arg6 * 64 + %arg5 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
      %11 = affine.load %arg3[%arg5 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
      %12 = arith.mulf %10, %11 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
      %13 = arith.addf %9, %12 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
      %14 = affine.load %arg1[%arg6 * 64 + %arg5 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
      %15 = affine.load %arg3[%arg5 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
      %16 = arith.mulf %14, %15 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f64
      %17 = arith.addf %13, %16 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f64
      %18 = affine.load %arg1[%arg6 * 64 + %arg5 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
      %19 = affine.load %arg3[%arg5 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
      %20 = arith.mulf %18, %19 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f64
      %21 = arith.addf %17, %20 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f64
      %22 = affine.load %arg1[%arg6 * 64 + %arg5 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
      %23 = affine.load %arg3[%arg5 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
      %24 = arith.mulf %22, %23 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f64
      %25 = arith.addf %21, %24 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f64
      %26 = affine.load %arg1[%arg6 * 64 + %arg5 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
      %27 = affine.load %arg3[%arg5 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
      %28 = arith.mulf %26, %27 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f64
      %29 = arith.addf %25, %28 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f64
      %30 = affine.load %arg1[%arg6 * 64 + %arg5 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
      %31 = affine.load %arg3[%arg5 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
      %32 = arith.mulf %30, %31 {timing = #hlscpp.t<37 -> 41, 4, 1>} : f64
      %33 = arith.addf %29, %32 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f64
      affine.store %33, %arg2[%arg6] {max_mux_size = 1 : i64, partition_indices = [0], timing = #hlscpp.t<46 -> 47, 1, 1>} : memref<64xf64, affine_map<(d0) -> (0, d0)>, 1>
    } {loop_directive = #hlscpp.ld<pipeline=true, targetII=1, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=64, iterLatency=47, minII=1>, timing = #hlscpp.t<1 -> 113, 112, 112>}
  } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true, parallel=false>, loop_info = #hlscpp.l<flattenTripCount=512, iterLatency=47, minII=1>, timing = #hlscpp.t<0 -> 560, 560, 560>}
  affine.store %cst, %arg4[0] {partition_indices = [0], timing = #hlscpp.t<560 -> 561, 1, 1>} : memref<1xf64, 1>
  return {timing = #hlscpp.t<561 -> 561, 0, 0>}
}
