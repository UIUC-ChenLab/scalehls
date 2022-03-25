func @get_delta_matrix_weights3(%arg0: memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>, %arg1: memref<3xf64, affine_map<(d0) -> (d0 mod 3, d0 floordiv 3)>, 1>, %arg2: memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>, llvm.linkage = #llvm.linkage<external>, resource = #hlscpp.r<lut=0, dsp=72, bram=0>, timing = #hlscpp.t<0 -> 18, 18, 18>} {
  affine.for %arg3 = 0 to 8 {
    %0 = affine.load %arg2[%arg3 * 8] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %1 = affine.load %arg1[0] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<3xf64, affine_map<(d0) -> (d0 mod 3, d0 floordiv 3)>, 1>
    %2 = arith.mulf %0, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %2, %arg0[%arg3 * 24] {partition_indices = [0], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %3 = affine.load %arg1[1] {partition_indices = [1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<3xf64, affine_map<(d0) -> (d0 mod 3, d0 floordiv 3)>, 1>
    %4 = arith.mulf %0, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %4, %arg0[%arg3 * 24 + 1] {partition_indices = [1], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %5 = affine.load %arg1[2] {partition_indices = [2], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<3xf64, affine_map<(d0) -> (d0 mod 3, d0 floordiv 3)>, 1>
    %6 = arith.mulf %0, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %6, %arg0[%arg3 * 24 + 2] {partition_indices = [2], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %7 = affine.load %arg2[%arg3 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %8 = arith.mulf %7, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %8, %arg0[%arg3 * 24 + 3] {partition_indices = [3], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %9 = arith.mulf %7, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %9, %arg0[%arg3 * 24 + 4] {partition_indices = [4], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %10 = arith.mulf %7, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %10, %arg0[%arg3 * 24 + 5] {partition_indices = [5], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %11 = affine.load %arg2[%arg3 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %12 = arith.mulf %11, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %12, %arg0[%arg3 * 24 + 6] {partition_indices = [6], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %13 = arith.mulf %11, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %13, %arg0[%arg3 * 24 + 7] {partition_indices = [7], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %14 = arith.mulf %11, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %14, %arg0[%arg3 * 24 + 8] {partition_indices = [8], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %15 = affine.load %arg2[%arg3 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %16 = arith.mulf %15, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %16, %arg0[%arg3 * 24 + 9] {partition_indices = [9], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %17 = arith.mulf %15, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %17, %arg0[%arg3 * 24 + 10] {partition_indices = [10], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %18 = arith.mulf %15, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %18, %arg0[%arg3 * 24 + 11] {partition_indices = [11], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %19 = affine.load %arg2[%arg3 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %20 = arith.mulf %19, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %20, %arg0[%arg3 * 24 + 12] {partition_indices = [12], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %21 = arith.mulf %19, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %21, %arg0[%arg3 * 24 + 13] {partition_indices = [13], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %22 = arith.mulf %19, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %22, %arg0[%arg3 * 24 + 14] {partition_indices = [14], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %23 = affine.load %arg2[%arg3 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %24 = arith.mulf %23, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %24, %arg0[%arg3 * 24 + 15] {partition_indices = [15], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %25 = arith.mulf %23, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %25, %arg0[%arg3 * 24 + 16] {partition_indices = [16], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %26 = arith.mulf %23, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %26, %arg0[%arg3 * 24 + 17] {partition_indices = [17], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %27 = affine.load %arg2[%arg3 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %28 = arith.mulf %27, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %28, %arg0[%arg3 * 24 + 18] {partition_indices = [18], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %29 = arith.mulf %27, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %29, %arg0[%arg3 * 24 + 19] {partition_indices = [19], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %30 = arith.mulf %27, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %30, %arg0[%arg3 * 24 + 20] {partition_indices = [20], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %31 = affine.load %arg2[%arg3 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %32 = arith.mulf %31, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %32, %arg0[%arg3 * 24 + 21] {partition_indices = [21], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %33 = arith.mulf %31, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %33, %arg0[%arg3 * 24 + 22] {partition_indices = [22], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %34 = arith.mulf %31, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %34, %arg0[%arg3 * 24 + 23] {partition_indices = [23], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=1, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=8, iterLatency=7, minII=1>, timing = #hlscpp.t<0 -> 16, 16, 16>}
  return {timing = #hlscpp.t<16 -> 16, 0, 0>}
}
