func @SgdLR_sw(%arg0: memref<4608000xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>, %arg1: memref<4500xi32, affine_map<(d0) -> (0, d0)>, 1>, %arg2: memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>, llvm.linkage = #llvm.linkage<external>, resource = #hlscpp.r<lut=0, dsp=47, bram=8>, timing = #hlscpp.t<0 -> 28170014, 28170014, 28170014>} {
  %cst = arith.constant {timing = #hlscpp.t<0 -> 0, 0, 0>} -6.000000e+04 : f32
  %cst_0 = arith.constant {timing = #hlscpp.t<0 -> 0, 0, 0>} 0.000000e+00 : f32
  %cst_1 = arith.constant {timing = #hlscpp.t<0 -> 0, 0, 0>} 1.000000e+00 : f32
  %0 = memref.alloca() {timing = #hlscpp.t<0 -> 0, 0, 0>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
  affine.for %arg3 = 0 to 5 {
    affine.for %arg4 = 0 to 4500 {
      %1 = memref.alloc() {timing = #hlscpp.t<0 -> 0, 0, 0>} : memref<1xf32, affine_map<(d0) -> (0, d0)>, 1>
      affine.store %cst_0, %1[0] {partition_indices = [0], timing = #hlscpp.t<0 -> 1, 1, 1>} : memref<1xf32, affine_map<(d0) -> (0, d0)>, 1>
      %2 = memref.alloc() {timing = #hlscpp.t<0 -> 0, 0, 0>} : memref<1xf32, affine_map<(d0) -> (0, d0)>, 1>
      affine.store %cst_0, %2[0] {partition_indices = [0], timing = #hlscpp.t<0 -> 1, 1, 1>} : memref<1xf32, affine_map<(d0) -> (0, d0)>, 1>
      affine.for %arg5 = 0 to 128 {
        %8 = affine.load %arg2[%arg5 * 8] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %9 = affine.load %arg0[%arg4 * 1024 + %arg5 * 8] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<4608000xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %10 = arith.mulf %8, %9 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %11 = affine.load %arg2[%arg5 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %12 = affine.load %arg0[%arg4 * 1024 + %arg5 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<4608000xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %13 = arith.mulf %11, %12 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %14 = arith.addf %10, %13 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        %15 = affine.load %arg2[%arg5 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %16 = affine.load %arg0[%arg4 * 1024 + %arg5 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<4608000xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %17 = arith.mulf %15, %16 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        %18 = arith.addf %14, %17 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
        %19 = affine.load %arg2[%arg5 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %20 = affine.load %arg0[%arg4 * 1024 + %arg5 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<4608000xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %21 = arith.mulf %19, %20 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
        %22 = arith.addf %18, %21 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
        %23 = affine.load %arg2[%arg5 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %24 = affine.load %arg0[%arg4 * 1024 + %arg5 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<4608000xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %25 = arith.mulf %23, %24 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f32
        %26 = arith.addf %22, %25 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f32
        %27 = affine.load %arg2[%arg5 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %28 = affine.load %arg0[%arg4 * 1024 + %arg5 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<4608000xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %29 = arith.mulf %27, %28 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f32
        %30 = arith.addf %26, %29 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f32
        %31 = affine.load %arg2[%arg5 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %32 = affine.load %arg0[%arg4 * 1024 + %arg5 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<4608000xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %33 = arith.mulf %31, %32 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f32
        %34 = arith.addf %30, %33 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f32
        %35 = affine.load %arg2[%arg5 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %36 = affine.load %arg0[%arg4 * 1024 + %arg5 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<4608000xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %37 = arith.mulf %35, %36 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f32
        %38 = arith.addf %34, %37 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f32
        %39 = affine.load %1[0] {partition_indices = [0], timing = #hlscpp.t<40 -> 41, 1, 1>} : memref<1xf32, affine_map<(d0) -> (0, d0)>, 1>
        %40 = arith.addf %39, %38 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f32
        affine.store %40, %1[0] {partition_indices = [0], timing = #hlscpp.t<46 -> 47, 1, 1>} : memref<1xf32, affine_map<(d0) -> (0, d0)>, 1>
        affine.store %40, %2[0] {partition_indices = [0], timing = #hlscpp.t<46 -> 47, 1, 1>} : memref<1xf32, affine_map<(d0) -> (0, d0)>, 1>
      } {loop_directive = #hlscpp.ld<pipeline=true, targetII=7, dataflow=false, flatten=false, parallel=false>, loop_info = #hlscpp.l<flattenTripCount=128, iterLatency=47, minII=7>, timing = #hlscpp.t<1 -> 939, 938, 938>}
      %3 = affine.load %2[0] {partition_indices = [0], timing = #hlscpp.t<939 -> 940, 1, 1>} : memref<1xf32, affine_map<(d0) -> (0, d0)>, 1>
      %4 = arith.negf %3 {timing = #hlscpp.t<940 -> 940, 0, 0>} : f32
      %5 = math.exp %4 {timing = #hlscpp.t<940 -> 949, 9, 1>} : f32
      %6 = arith.addf %cst_1, %5 {timing = #hlscpp.t<949 -> 954, 5, 1>} : f32
      %7 = arith.divf %cst_1, %6 {timing = #hlscpp.t<954 -> 970, 16, 1>} : f32
      affine.for %arg5 = 0 to 128 {
        %8 = affine.load %arg1[%arg4] {max_mux_size = 1 : i64, partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<4500xi32, affine_map<(d0) -> (0, d0)>, 1>
        %9 = arith.sitofp %8 {timing = #hlscpp.t<2 -> 2, 0, 0>} : i32 to f32
        %10 = arith.subf %7, %9 {timing = #hlscpp.t<2 -> 7, 5, 1>} : f32
        %11 = affine.load %arg0[%arg4 * 1024 + %arg5 * 8] {partition_indices = [0], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<4608000xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %12 = arith.mulf %10, %11 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        affine.store %12, %0[%arg5 * 8] {partition_indices = [0], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %13 = affine.load %arg0[%arg4 * 1024 + %arg5 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<4608000xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %14 = arith.mulf %10, %13 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        affine.store %14, %0[%arg5 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %15 = affine.load %arg0[%arg4 * 1024 + %arg5 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<4608000xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %16 = arith.mulf %10, %15 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        affine.store %16, %0[%arg5 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %17 = affine.load %arg0[%arg4 * 1024 + %arg5 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<4608000xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %18 = arith.mulf %10, %17 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        affine.store %18, %0[%arg5 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %19 = affine.load %arg0[%arg4 * 1024 + %arg5 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<4608000xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %20 = arith.mulf %10, %19 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        affine.store %20, %0[%arg5 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %21 = affine.load %arg0[%arg4 * 1024 + %arg5 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<4608000xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %22 = arith.mulf %10, %21 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        affine.store %22, %0[%arg5 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %23 = affine.load %arg0[%arg4 * 1024 + %arg5 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<4608000xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %24 = arith.mulf %10, %23 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        affine.store %24, %0[%arg5 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %25 = affine.load %arg0[%arg4 * 1024 + %arg5 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<4608000xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %26 = arith.mulf %10, %25 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
        affine.store %26, %0[%arg5 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
      } {loop_directive = #hlscpp.ld<pipeline=true, targetII=1, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=128, iterLatency=12, minII=1>, timing = #hlscpp.t<970 -> 1111, 141, 141>}
      affine.for %arg5 = 0 to 128 {
        %8 = affine.load %0[%arg5 * 8] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %9 = arith.mulf %cst, %8 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %10 = affine.load %arg2[%arg5 * 8] {partition_indices = [0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %11 = arith.addf %10, %9 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %11, %arg2[%arg5 * 8] {partition_indices = [0], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %12 = affine.load %0[%arg5 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %13 = arith.mulf %cst, %12 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %14 = affine.load %arg2[%arg5 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %15 = arith.addf %14, %13 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %15, %arg2[%arg5 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %16 = affine.load %0[%arg5 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %17 = arith.mulf %cst, %16 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %18 = affine.load %arg2[%arg5 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %19 = arith.addf %18, %17 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %19, %arg2[%arg5 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %20 = affine.load %0[%arg5 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %21 = arith.mulf %cst, %20 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %22 = affine.load %arg2[%arg5 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %23 = arith.addf %22, %21 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %23, %arg2[%arg5 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %24 = affine.load %0[%arg5 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %25 = arith.mulf %cst, %24 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %26 = affine.load %arg2[%arg5 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %27 = arith.addf %26, %25 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %27, %arg2[%arg5 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %28 = affine.load %0[%arg5 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %29 = arith.mulf %cst, %28 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %30 = affine.load %arg2[%arg5 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %31 = arith.addf %30, %29 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %31, %arg2[%arg5 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %32 = affine.load %0[%arg5 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %33 = arith.mulf %cst, %32 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %34 = affine.load %arg2[%arg5 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %35 = arith.addf %34, %33 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %35, %arg2[%arg5 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %36 = affine.load %0[%arg5 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %37 = arith.mulf %cst, %36 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
        %38 = affine.load %arg2[%arg5 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
        %39 = arith.addf %38, %37 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
        affine.store %39, %arg2[%arg5 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<1024xf32, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
      } {loop_directive = #hlscpp.ld<pipeline=true, targetII=1, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=128, iterLatency=12, minII=1>, timing = #hlscpp.t<1111 -> 1252, 141, 141>}
    } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=false, parallel=false>, loop_info = #hlscpp.l<flattenTripCount=4500, iterLatency=1252, minII=1252>, timing = #hlscpp.t<0 -> 5634002, 5634002, 5634002>}
  } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=false, parallel=false>, loop_info = #hlscpp.l<flattenTripCount=5, iterLatency=5634002, minII=5634002>, timing = #hlscpp.t<0 -> 28170012, 28170012, 28170012>}
  return {timing = #hlscpp.t<28170012 -> 28170012, 0, 0>}
}
