func @get_delta_matrix_weights1(%arg0: memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>, %arg1: memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>, %arg2: memref<13xf64, affine_map<(d0) -> (0, d0)>, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>, llvm.linkage = #llvm.linkage<external>, resource = #hlscpp.r<lut=0, dsp=48, bram=0>, timing = #hlscpp.t<0 -> 62, 62, 62>} {
  affine.for %arg3 = 0 to 13 {
    affine.for %arg4 = 0 to 4 {
      %0 = affine.load %arg2[%arg3] {max_mux_size = 1 : i64, partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<13xf64, affine_map<(d0) -> (0, d0)>, 1>
      %1 = affine.load %arg1[%arg4 * 16] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %2 = arith.mulf %0, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
      affine.store %2, %arg0[%arg3 * 64 + %arg4 * 16] {partition_indices = [0], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %3 = affine.load %arg1[%arg4 * 16 + 1] {partition_indices = [1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %4 = arith.mulf %0, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
      affine.store %4, %arg0[%arg3 * 64 + %arg4 * 16 + 1] {partition_indices = [1], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %5 = affine.load %arg1[%arg4 * 16 + 2] {partition_indices = [2], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %6 = arith.mulf %0, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
      affine.store %6, %arg0[%arg3 * 64 + %arg4 * 16 + 2] {partition_indices = [2], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %7 = affine.load %arg1[%arg4 * 16 + 3] {partition_indices = [3], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %8 = arith.mulf %0, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
      affine.store %8, %arg0[%arg3 * 64 + %arg4 * 16 + 3] {partition_indices = [3], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %9 = affine.load %arg1[%arg4 * 16 + 4] {partition_indices = [4], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %10 = arith.mulf %0, %9 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
      affine.store %10, %arg0[%arg3 * 64 + %arg4 * 16 + 4] {partition_indices = [4], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %11 = affine.load %arg1[%arg4 * 16 + 5] {partition_indices = [5], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %12 = arith.mulf %0, %11 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
      affine.store %12, %arg0[%arg3 * 64 + %arg4 * 16 + 5] {partition_indices = [5], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %13 = affine.load %arg1[%arg4 * 16 + 6] {partition_indices = [6], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %14 = arith.mulf %0, %13 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
      affine.store %14, %arg0[%arg3 * 64 + %arg4 * 16 + 6] {partition_indices = [6], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %15 = affine.load %arg1[%arg4 * 16 + 7] {partition_indices = [7], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %16 = arith.mulf %0, %15 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
      affine.store %16, %arg0[%arg3 * 64 + %arg4 * 16 + 7] {partition_indices = [7], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %17 = affine.load %arg1[%arg4 * 16 + 8] {partition_indices = [8], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %18 = arith.mulf %0, %17 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
      affine.store %18, %arg0[%arg3 * 64 + %arg4 * 16 + 8] {partition_indices = [8], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %19 = affine.load %arg1[%arg4 * 16 + 9] {partition_indices = [9], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %20 = arith.mulf %0, %19 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
      affine.store %20, %arg0[%arg3 * 64 + %arg4 * 16 + 9] {partition_indices = [9], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %21 = affine.load %arg1[%arg4 * 16 + 10] {partition_indices = [10], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %22 = arith.mulf %0, %21 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
      affine.store %22, %arg0[%arg3 * 64 + %arg4 * 16 + 10] {partition_indices = [10], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %23 = affine.load %arg1[%arg4 * 16 + 11] {partition_indices = [11], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %24 = arith.mulf %0, %23 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
      affine.store %24, %arg0[%arg3 * 64 + %arg4 * 16 + 11] {partition_indices = [11], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %25 = affine.load %arg1[%arg4 * 16 + 12] {partition_indices = [12], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %26 = arith.mulf %0, %25 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
      affine.store %26, %arg0[%arg3 * 64 + %arg4 * 16 + 12] {partition_indices = [12], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %27 = affine.load %arg1[%arg4 * 16 + 13] {partition_indices = [13], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %28 = arith.mulf %0, %27 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
      affine.store %28, %arg0[%arg3 * 64 + %arg4 * 16 + 13] {partition_indices = [13], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %29 = affine.load %arg1[%arg4 * 16 + 14] {partition_indices = [14], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %30 = arith.mulf %0, %29 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
      affine.store %30, %arg0[%arg3 * 64 + %arg4 * 16 + 14] {partition_indices = [14], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %31 = affine.load %arg1[%arg4 * 16 + 15] {partition_indices = [15], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %32 = arith.mulf %0, %31 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
      affine.store %32, %arg0[%arg3 * 64 + %arg4 * 16 + 15] {partition_indices = [15], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
    } {loop_directive = #hlscpp.ld<pipeline=true, targetII=1, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=4, iterLatency=7, minII=1>, timing = #hlscpp.t<0 -> 12, 12, 12>}
  } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=52, iterLatency=7, minII=1>, timing = #hlscpp.t<0 -> 60, 60, 60>}
  return {timing = #hlscpp.t<60 -> 60, 0, 0>}
}
