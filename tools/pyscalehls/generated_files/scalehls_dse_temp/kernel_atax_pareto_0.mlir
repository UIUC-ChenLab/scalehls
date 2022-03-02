func @kernel_atax(%arg0: f32, %arg1: f32, %arg2: memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>, %arg3: memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>, %arg4: memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>, %arg5: memref<1900xf32, affine_map<(d0) -> (0, d0)>, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>, llvm.linkage = #llvm.linkage<external>, resource = #hlscpp.r<lut=0, dsp=70, bram=0>, timing = #hlscpp.t<0 -> 2726656, 2726656, 2726656>} {
  %cst = arith.constant {timing = #hlscpp.t<0 -> 0, 0, 0>} 0.000000e+00 : f32
  affine.for %arg6 = 0 to 150 {
    affine.store %cst, %arg4[%arg6 * 14] {partition_indices = [0], timing = #hlscpp.t<0 -> 1, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
    affine.store %cst, %arg4[%arg6 * 14 + 1] {partition_indices = [1], timing = #hlscpp.t<0 -> 1, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
    affine.store %cst, %arg4[%arg6 * 14 + 2] {partition_indices = [2], timing = #hlscpp.t<0 -> 1, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
    affine.store %cst, %arg4[%arg6 * 14 + 3] {partition_indices = [3], timing = #hlscpp.t<0 -> 1, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
    affine.store %cst, %arg4[%arg6 * 14 + 4] {partition_indices = [4], timing = #hlscpp.t<0 -> 1, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
    affine.store %cst, %arg4[%arg6 * 14 + 5] {partition_indices = [5], timing = #hlscpp.t<0 -> 1, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
    affine.store %cst, %arg4[%arg6 * 14 + 6] {partition_indices = [6], timing = #hlscpp.t<0 -> 1, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
    affine.store %cst, %arg4[%arg6 * 14 + 7] {partition_indices = [7], timing = #hlscpp.t<0 -> 1, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
    affine.store %cst, %arg4[%arg6 * 14 + 8] {partition_indices = [8], timing = #hlscpp.t<0 -> 1, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
    affine.store %cst, %arg4[%arg6 * 14 + 9] {partition_indices = [9], timing = #hlscpp.t<0 -> 1, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
    affine.store %cst, %arg4[%arg6 * 14 + 10] {partition_indices = [10], timing = #hlscpp.t<0 -> 1, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
    affine.store %cst, %arg4[%arg6 * 14 + 11] {partition_indices = [11], timing = #hlscpp.t<0 -> 1, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
    affine.store %cst, %arg4[%arg6 * 14 + 12] {partition_indices = [12], timing = #hlscpp.t<0 -> 1, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
    affine.store %cst, %arg4[%arg6 * 14 + 13] {partition_indices = [13], timing = #hlscpp.t<0 -> 1, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=1, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=150, iterLatency=1, minII=1>, timing = #hlscpp.t<0 -> 152, 152, 152>}
  affine.for %arg6 = 0 to 1900 {
    affine.store %cst, %arg5[%arg6] {max_mux_size = 1 : i64, partition_indices = [0], timing = #hlscpp.t<0 -> 1, 1, 1>} : memref<1900xf32, affine_map<(d0) -> (0, d0)>, 1>
    affine.for %arg7 = 0 to 150 {
      %0 = affine.load %arg2[%arg6, %arg7 * 14] {partition_indices = [0, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %1 = affine.load %arg3[%arg7 * 14] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %2 = arith.mulf %0, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
      %3 = affine.load %arg2[%arg6, %arg7 * 14 + 1] {partition_indices = [0, 1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %4 = affine.load %arg3[%arg7 * 14 + 1] {partition_indices = [1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %5 = arith.mulf %3, %4 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
      %6 = arith.addf %2, %5 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
      %7 = affine.load %arg2[%arg6, %arg7 * 14 + 2] {partition_indices = [0, 2], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %8 = affine.load %arg3[%arg7 * 14 + 2] {partition_indices = [2], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %9 = arith.mulf %7, %8 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f32
      %10 = arith.addf %6, %9 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f32
      %11 = affine.load %arg2[%arg6, %arg7 * 14 + 3] {partition_indices = [0, 3], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %12 = affine.load %arg3[%arg7 * 14 + 3] {partition_indices = [3], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %13 = arith.mulf %11, %12 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f32
      %14 = arith.addf %10, %13 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f32
      %15 = affine.load %arg2[%arg6, %arg7 * 14 + 4] {partition_indices = [0, 4], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %16 = affine.load %arg3[%arg7 * 14 + 4] {partition_indices = [4], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %17 = arith.mulf %15, %16 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f32
      %18 = arith.addf %14, %17 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f32
      %19 = affine.load %arg2[%arg6, %arg7 * 14 + 5] {partition_indices = [0, 5], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %20 = affine.load %arg3[%arg7 * 14 + 5] {partition_indices = [5], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %21 = arith.mulf %19, %20 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f32
      %22 = arith.addf %18, %21 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f32
      %23 = affine.load %arg2[%arg6, %arg7 * 14 + 6] {partition_indices = [0, 6], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %24 = affine.load %arg3[%arg7 * 14 + 6] {partition_indices = [6], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %25 = arith.mulf %23, %24 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f32
      %26 = arith.addf %22, %25 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f32
      %27 = affine.load %arg2[%arg6, %arg7 * 14 + 7] {partition_indices = [0, 7], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %28 = affine.load %arg3[%arg7 * 14 + 7] {partition_indices = [7], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %29 = arith.mulf %27, %28 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f32
      %30 = arith.addf %26, %29 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f32
      %31 = affine.load %arg2[%arg6, %arg7 * 14 + 8] {partition_indices = [0, 8], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %32 = affine.load %arg3[%arg7 * 14 + 8] {partition_indices = [8], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %33 = arith.mulf %31, %32 {timing = #hlscpp.t<37 -> 41, 4, 1>} : f32
      %34 = arith.addf %30, %33 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f32
      %35 = affine.load %arg2[%arg6, %arg7 * 14 + 9] {partition_indices = [0, 9], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %36 = affine.load %arg3[%arg7 * 14 + 9] {partition_indices = [9], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %37 = arith.mulf %35, %36 {timing = #hlscpp.t<42 -> 46, 4, 1>} : f32
      %38 = arith.addf %34, %37 {timing = #hlscpp.t<46 -> 51, 5, 1>} : f32
      %39 = affine.load %arg2[%arg6, %arg7 * 14 + 10] {partition_indices = [0, 10], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %40 = affine.load %arg3[%arg7 * 14 + 10] {partition_indices = [10], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %41 = arith.mulf %39, %40 {timing = #hlscpp.t<47 -> 51, 4, 1>} : f32
      %42 = arith.addf %38, %41 {timing = #hlscpp.t<51 -> 56, 5, 1>} : f32
      %43 = affine.load %arg2[%arg6, %arg7 * 14 + 11] {partition_indices = [0, 11], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %44 = affine.load %arg3[%arg7 * 14 + 11] {partition_indices = [11], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %45 = arith.mulf %43, %44 {timing = #hlscpp.t<52 -> 56, 4, 1>} : f32
      %46 = arith.addf %42, %45 {timing = #hlscpp.t<56 -> 61, 5, 1>} : f32
      %47 = affine.load %arg2[%arg6, %arg7 * 14 + 12] {partition_indices = [0, 12], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %48 = affine.load %arg3[%arg7 * 14 + 12] {partition_indices = [12], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %49 = arith.mulf %47, %48 {timing = #hlscpp.t<57 -> 61, 4, 1>} : f32
      %50 = arith.addf %46, %49 {timing = #hlscpp.t<61 -> 66, 5, 1>} : f32
      %51 = affine.load %arg2[%arg6, %arg7 * 14 + 13] {partition_indices = [0, 13], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %52 = affine.load %arg3[%arg7 * 14 + 13] {partition_indices = [13], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %53 = arith.mulf %51, %52 {timing = #hlscpp.t<62 -> 66, 4, 1>} : f32
      %54 = arith.addf %50, %53 {timing = #hlscpp.t<66 -> 71, 5, 1>} : f32
      %55 = affine.load %arg5[%arg6] {max_mux_size = 1 : i64, partition_indices = [0], timing = #hlscpp.t<69 -> 71, 2, 1>} : memref<1900xf32, affine_map<(d0) -> (0, d0)>, 1>
      %56 = arith.addf %55, %54 {timing = #hlscpp.t<71 -> 76, 5, 1>} : f32
      affine.store %56, %arg5[%arg6] {max_mux_size = 1 : i64, partition_indices = [0], timing = #hlscpp.t<76 -> 77, 1, 1>} : memref<1900xf32, affine_map<(d0) -> (0, d0)>, 1>
    } {loop_directive = #hlscpp.ld<pipeline=true, targetII=8, dataflow=false, flatten=false, parallel=false>, loop_info = #hlscpp.l<flattenTripCount=150, iterLatency=77, minII=8>, timing = #hlscpp.t<1 -> 1272, 1271, 1271>}
    affine.for %arg7 = 0 to 150 {
      %0 = affine.load %arg4[%arg7 * 14] {partition_indices = [0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %1 = affine.load %arg2[%arg6, %arg7 * 14] {partition_indices = [0, 0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %2 = affine.load %arg5[%arg6] {max_mux_size = 1 : i64, partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1900xf32, affine_map<(d0) -> (0, d0)>, 1>
      %3 = arith.mulf %1, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
      %4 = arith.addf %0, %3 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
      affine.store %4, %arg4[%arg7 * 14] {partition_indices = [0], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %5 = affine.load %arg4[%arg7 * 14 + 1] {partition_indices = [1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %6 = affine.load %arg2[%arg6, %arg7 * 14 + 1] {partition_indices = [0, 1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %7 = arith.mulf %6, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
      %8 = arith.addf %5, %7 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
      affine.store %8, %arg4[%arg7 * 14 + 1] {partition_indices = [1], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %9 = affine.load %arg4[%arg7 * 14 + 2] {partition_indices = [2], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %10 = affine.load %arg2[%arg6, %arg7 * 14 + 2] {partition_indices = [0, 2], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %11 = arith.mulf %10, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
      %12 = arith.addf %9, %11 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
      affine.store %12, %arg4[%arg7 * 14 + 2] {partition_indices = [2], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %13 = affine.load %arg4[%arg7 * 14 + 3] {partition_indices = [3], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %14 = affine.load %arg2[%arg6, %arg7 * 14 + 3] {partition_indices = [0, 3], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %15 = arith.mulf %14, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
      %16 = arith.addf %13, %15 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
      affine.store %16, %arg4[%arg7 * 14 + 3] {partition_indices = [3], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %17 = affine.load %arg4[%arg7 * 14 + 4] {partition_indices = [4], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %18 = affine.load %arg2[%arg6, %arg7 * 14 + 4] {partition_indices = [0, 4], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %19 = arith.mulf %18, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
      %20 = arith.addf %17, %19 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
      affine.store %20, %arg4[%arg7 * 14 + 4] {partition_indices = [4], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %21 = affine.load %arg4[%arg7 * 14 + 5] {partition_indices = [5], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %22 = affine.load %arg2[%arg6, %arg7 * 14 + 5] {partition_indices = [0, 5], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %23 = arith.mulf %22, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
      %24 = arith.addf %21, %23 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
      affine.store %24, %arg4[%arg7 * 14 + 5] {partition_indices = [5], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %25 = affine.load %arg4[%arg7 * 14 + 6] {partition_indices = [6], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %26 = affine.load %arg2[%arg6, %arg7 * 14 + 6] {partition_indices = [0, 6], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %27 = arith.mulf %26, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
      %28 = arith.addf %25, %27 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
      affine.store %28, %arg4[%arg7 * 14 + 6] {partition_indices = [6], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %29 = affine.load %arg4[%arg7 * 14 + 7] {partition_indices = [7], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %30 = affine.load %arg2[%arg6, %arg7 * 14 + 7] {partition_indices = [0, 7], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %31 = arith.mulf %30, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
      %32 = arith.addf %29, %31 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
      affine.store %32, %arg4[%arg7 * 14 + 7] {partition_indices = [7], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %33 = affine.load %arg4[%arg7 * 14 + 8] {partition_indices = [8], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %34 = affine.load %arg2[%arg6, %arg7 * 14 + 8] {partition_indices = [0, 8], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %35 = arith.mulf %34, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
      %36 = arith.addf %33, %35 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
      affine.store %36, %arg4[%arg7 * 14 + 8] {partition_indices = [8], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %37 = affine.load %arg4[%arg7 * 14 + 9] {partition_indices = [9], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %38 = affine.load %arg2[%arg6, %arg7 * 14 + 9] {partition_indices = [0, 9], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %39 = arith.mulf %38, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
      %40 = arith.addf %37, %39 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
      affine.store %40, %arg4[%arg7 * 14 + 9] {partition_indices = [9], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %41 = affine.load %arg4[%arg7 * 14 + 10] {partition_indices = [10], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %42 = affine.load %arg2[%arg6, %arg7 * 14 + 10] {partition_indices = [0, 10], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %43 = arith.mulf %42, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
      %44 = arith.addf %41, %43 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
      affine.store %44, %arg4[%arg7 * 14 + 10] {partition_indices = [10], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %45 = affine.load %arg4[%arg7 * 14 + 11] {partition_indices = [11], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %46 = affine.load %arg2[%arg6, %arg7 * 14 + 11] {partition_indices = [0, 11], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %47 = arith.mulf %46, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
      %48 = arith.addf %45, %47 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
      affine.store %48, %arg4[%arg7 * 14 + 11] {partition_indices = [11], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %49 = affine.load %arg4[%arg7 * 14 + 12] {partition_indices = [12], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %50 = affine.load %arg2[%arg6, %arg7 * 14 + 12] {partition_indices = [0, 12], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %51 = arith.mulf %50, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
      %52 = arith.addf %49, %51 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
      affine.store %52, %arg4[%arg7 * 14 + 12] {partition_indices = [12], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %53 = affine.load %arg4[%arg7 * 14 + 13] {partition_indices = [13], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
      %54 = affine.load %arg2[%arg6, %arg7 * 14 + 13] {partition_indices = [0, 13], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<1900x2100xf32, affine_map<(d0, d1) -> (0, d1 mod 14, d0, d1 floordiv 14)>, 1>
      %55 = arith.mulf %54, %2 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f32
      %56 = arith.addf %53, %55 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f32
      affine.store %56, %arg4[%arg7 * 14 + 13] {partition_indices = [13], timing = #hlscpp.t<11 -> 12, 1, 1>} : memref<2100xf32, affine_map<(d0) -> (d0 mod 14, d0 floordiv 14)>, 1>
    } {loop_directive = #hlscpp.ld<pipeline=true, targetII=1, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=150, iterLatency=12, minII=1>, timing = #hlscpp.t<1272 -> 1435, 163, 163>}
  } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=false, parallel=false>, loop_info = #hlscpp.l<flattenTripCount=1900, iterLatency=1435, minII=1435>, timing = #hlscpp.t<152 -> 2726654, 2726502, 2726502>}
  return {timing = #hlscpp.t<2726654 -> 2726654, 0, 0>}
}
