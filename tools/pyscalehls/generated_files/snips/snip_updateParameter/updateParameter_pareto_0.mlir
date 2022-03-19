func @updateParameter(%arg0: memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>, %arg1: memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>, %arg2: f32) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>, llvm.linkage = #llvm.linkage<external>, resource = #hlscpp.r<lut=0, dsp=40, bram=0>, timing = #hlscpp.t<0 -> 143, 143, 143>} {
  affine.for %arg3 = 0 to 128 {
    %0 = affine.load %arg1[%arg3 * 8] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %1 = arith.mulf %arg2, %0 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
    %2 = affine.load %arg0[%arg3 * 8] {partition_indices = [0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %3 = arith.addf %2, %1 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
    affine.store %3, %arg0[%arg3 * 8] {partition_indices = [0], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %4 = affine.load %arg1[%arg3 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %5 = arith.mulf %arg2, %4 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
    %6 = affine.load %arg0[%arg3 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %7 = arith.addf %6, %5 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
    affine.store %7, %arg0[%arg3 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %8 = affine.load %arg1[%arg3 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %9 = arith.mulf %arg2, %8 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
    %10 = affine.load %arg0[%arg3 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %11 = arith.addf %10, %9 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
    affine.store %11, %arg0[%arg3 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %12 = affine.load %arg1[%arg3 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %13 = arith.mulf %arg2, %12 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
    %14 = affine.load %arg0[%arg3 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %15 = arith.addf %14, %13 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
    affine.store %15, %arg0[%arg3 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %16 = affine.load %arg1[%arg3 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %17 = arith.mulf %arg2, %16 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
    %18 = affine.load %arg0[%arg3 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %19 = arith.addf %18, %17 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
    affine.store %19, %arg0[%arg3 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %20 = affine.load %arg1[%arg3 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %21 = arith.mulf %arg2, %20 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
    %22 = affine.load %arg0[%arg3 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %23 = arith.addf %22, %21 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
    affine.store %23, %arg0[%arg3 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %24 = affine.load %arg1[%arg3 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %25 = arith.mulf %arg2, %24 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
    %26 = affine.load %arg0[%arg3 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %27 = arith.addf %26, %25 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
    affine.store %27, %arg0[%arg3 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %28 = affine.load %arg1[%arg3 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %29 = arith.mulf %arg2, %28 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
    %30 = affine.load %arg0[%arg3 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %31 = arith.addf %30, %29 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
    affine.store %31, %arg0[%arg3 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=1, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=128, iterLatency=12, minII=1>, timing = #hlscpp.t<0 -> 141, 141, 141>}
  return {timing = #hlscpp.t<141 -> 141, 0, 0>}
}
