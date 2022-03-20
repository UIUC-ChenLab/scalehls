func @dotProduct(%arg0: memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>, %arg1: memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>) -> f32 attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>, llvm.linkage = #llvm.linkage<external>, resource = #hlscpp.r<lut=0, dsp=10, bram=0>, timing = #hlscpp.t<0 -> 942, 942, 942>} {
  %cst = arith.constant {timing = #hlscpp.t<0 -> 0, 0, 0>} 0.000000e+00 : f32
  %0 = memref.alloc() {timing = #hlscpp.t<0 -> 0, 0, 0>} : memref<1xf32, affine_map<(d0) -> (0, d0)>, 1>
  affine.store %cst, %0[0] {partition_indices = [0], timing = #hlscpp.t<0 -> 1, 1, 1>} : memref<1xf32, affine_map<(d0) -> (0, d0)>, 1>
  %1 = memref.alloc() {timing = #hlscpp.t<0 -> 0, 0, 0>} : memref<1xf32, affine_map<(d0) -> (0, d0)>, 1>
  affine.store %cst, %1[0] {partition_indices = [0], timing = #hlscpp.t<0 -> 1, 1, 1>} : memref<1xf32, affine_map<(d0) -> (0, d0)>, 1>
  affine.for %arg2 = 0 to 128 {
    %3 = affine.load %arg0[%arg2 * 8] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %4 = affine.load %arg1[%arg2 * 8] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %5 = arith.mulf %3, %4 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
    %6 = affine.load %arg0[%arg2 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %7 = affine.load %arg1[%arg2 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %8 = arith.mulf %6, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
    %9 = arith.addf %5, %8 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
    %10 = affine.load %arg0[%arg2 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %11 = affine.load %arg1[%arg2 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %12 = arith.mulf %10, %11 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
    %13 = arith.addf %9, %12 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
    %14 = affine.load %arg0[%arg2 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %15 = affine.load %arg1[%arg2 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %16 = arith.mulf %14, %15 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
    %17 = arith.addf %13, %16 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
    %18 = affine.load %arg0[%arg2 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %19 = affine.load %arg1[%arg2 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %20 = arith.mulf %18, %19 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f32
    %21 = arith.addf %17, %20 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f32
    %22 = affine.load %arg0[%arg2 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %23 = affine.load %arg1[%arg2 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %24 = arith.mulf %22, %23 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f32
    %25 = arith.addf %21, %24 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f32
    %26 = affine.load %arg0[%arg2 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %27 = affine.load %arg1[%arg2 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %28 = arith.mulf %26, %27 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f32
    %29 = arith.addf %25, %28 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f32
    %30 = affine.load %arg0[%arg2 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %31 = affine.load %arg1[%arg2 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %32 = arith.mulf %30, %31 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f32
    %33 = arith.addf %29, %32 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f32
    %34 = affine.load %0[0] {partition_indices = [0], timing = #hlscpp.t<40 -> 41, 1, 1>} : memref<1xf32, affine_map<(d0) -> (0, d0)>, 1>
    %35 = arith.addf %34, %33 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f32
    affine.store %35, %0[0] {partition_indices = [0], timing = #hlscpp.t<46 -> 47, 1, 1>} : memref<1xf32, affine_map<(d0) -> (0, d0)>, 1>
    affine.store %35, %1[0] {partition_indices = [0], timing = #hlscpp.t<46 -> 47, 1, 1>} : memref<1xf32, affine_map<(d0) -> (0, d0)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=7, dataflow=false, flatten=false, parallel=false>, loop_info = #hlscpp.l<flattenTripCount=128, iterLatency=47, minII=7>, timing = #hlscpp.t<1 -> 939, 938, 938>}
  %2 = affine.load %1[0] {partition_indices = [0], timing = #hlscpp.t<939 -> 940, 1, 1>} : memref<1xf32, affine_map<(d0) -> (0, d0)>, 1>
  return {timing = #hlscpp.t<940 -> 940, 0, 0>} %2 : f32
}
