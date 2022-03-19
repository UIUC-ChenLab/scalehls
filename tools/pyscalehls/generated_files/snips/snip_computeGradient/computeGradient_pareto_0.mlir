func @computeGradient(%arg0: memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>, %arg1: memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>, %arg2: f32) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>, llvm.linkage = #llvm.linkage<external>, resource = #hlscpp.r<lut=0, dsp=24, bram=0>, timing = #hlscpp.t<0 -> 138, 138, 138>} {
  affine.for %arg3 = 0 to 128 {
    %0 = affine.load %arg1[%arg3 * 8] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %1 = arith.mulf %arg2, %0 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
    affine.store %1, %arg0[%arg3 * 8] {partition_indices = [0], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %2 = affine.load %arg1[%arg3 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %3 = arith.mulf %arg2, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
    affine.store %3, %arg0[%arg3 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %4 = affine.load %arg1[%arg3 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %5 = arith.mulf %arg2, %4 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
    affine.store %5, %arg0[%arg3 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %6 = affine.load %arg1[%arg3 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %7 = arith.mulf %arg2, %6 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
    affine.store %7, %arg0[%arg3 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %8 = affine.load %arg1[%arg3 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %9 = arith.mulf %arg2, %8 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
    affine.store %9, %arg0[%arg3 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %10 = affine.load %arg1[%arg3 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %11 = arith.mulf %arg2, %10 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
    affine.store %11, %arg0[%arg3 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %12 = affine.load %arg1[%arg3 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %13 = arith.mulf %arg2, %12 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
    affine.store %13, %arg0[%arg3 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %14 = affine.load %arg1[%arg3 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %15 = arith.mulf %arg2, %14 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
    affine.store %15, %arg0[%arg3 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=1, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=128, iterLatency=7, minII=1>, timing = #hlscpp.t<0 -> 136, 136, 136>}
  return {timing = #hlscpp.t<136 -> 136, 0, 0>}
}
