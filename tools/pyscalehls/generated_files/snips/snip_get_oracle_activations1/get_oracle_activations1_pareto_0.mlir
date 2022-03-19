func @get_oracle_activations1(%arg0: memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>, %arg1: memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>, %arg2: memref<64xf64, affine_map<(d0) -> (0, d0)>, 1>, %arg3: memref<64xf64, affine_map<(d0) -> (0, d0)>, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>, llvm.linkage = #llvm.linkage<external>, resource = #hlscpp.r<lut=0, dsp=43, bram=0>, timing = #hlscpp.t<0 -> 605, 605, 605>} {
  %cst = arith.constant {timing = #hlscpp.t<0 -> 0, 0, 0>} 0.000000e+00 : f64
  affine.for %arg4 = 0 to 4 {
    affine.for %arg5 = 0 to 64 {
      %0 = affine.load %arg1[%arg4 * 16] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %1 = affine.load %arg0[%arg5 * 64 + %arg4 * 16] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %2 = arith.mulf %0, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
      %3 = affine.load %arg2[%arg5] {max_mux_size = 1 : i64, partition_indices = [0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<64xf64, affine_map<(d0) -> (0, d0)>, 1>
      %4 = affine.if affine_set<(d0) : (d0 * 16 == 0)>(%arg4) -> f64 {
        affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %cst : f64
      } else {
        affine.yield {timing = #hlscpp.t<6 -> 6, 0, 0>} %3 : f64
      } {timing = #hlscpp.t<6 -> 6, 0, 0>}
      %5 = arith.addf %4, %2 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
      %6 = affine.load %arg3[%arg5] {max_mux_size = 1 : i64, partition_indices = [0], timing = #hlscpp.t<84 -> 86, 2, 1>} : memref<64xf64, affine_map<(d0) -> (0, d0)>, 1>
      %7 = affine.load %arg1[%arg4 * 16 + 1] {partition_indices = [1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %8 = affine.load %arg0[%arg5 * 64 + %arg4 * 16 + 1] {partition_indices = [1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %9 = arith.mulf %7, %8 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
      %10 = arith.addf %5, %9 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
      %11 = affine.load %arg1[%arg4 * 16 + 2] {partition_indices = [2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %12 = affine.load %arg0[%arg5 * 64 + %arg4 * 16 + 2] {partition_indices = [2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %13 = arith.mulf %11, %12 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
      %14 = arith.addf %10, %13 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
      %15 = affine.load %arg1[%arg4 * 16 + 3] {partition_indices = [3], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %16 = affine.load %arg0[%arg5 * 64 + %arg4 * 16 + 3] {partition_indices = [3], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %17 = arith.mulf %15, %16 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f64
      %18 = arith.addf %14, %17 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f64
      %19 = affine.load %arg1[%arg4 * 16 + 4] {partition_indices = [4], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %20 = affine.load %arg0[%arg5 * 64 + %arg4 * 16 + 4] {partition_indices = [4], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %21 = arith.mulf %19, %20 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f64
      %22 = arith.addf %18, %21 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f64
      %23 = affine.load %arg1[%arg4 * 16 + 5] {partition_indices = [5], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %24 = affine.load %arg0[%arg5 * 64 + %arg4 * 16 + 5] {partition_indices = [5], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %25 = arith.mulf %23, %24 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f64
      %26 = arith.addf %22, %25 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f64
      %27 = affine.load %arg1[%arg4 * 16 + 6] {partition_indices = [6], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %28 = affine.load %arg0[%arg5 * 64 + %arg4 * 16 + 6] {partition_indices = [6], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %29 = arith.mulf %27, %28 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f64
      %30 = arith.addf %26, %29 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f64
      %31 = affine.load %arg1[%arg4 * 16 + 7] {partition_indices = [7], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %32 = affine.load %arg0[%arg5 * 64 + %arg4 * 16 + 7] {partition_indices = [7], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %33 = arith.mulf %31, %32 {timing = #hlscpp.t<37 -> 41, 4, 1>} : f64
      %34 = arith.addf %30, %33 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f64
      %35 = affine.load %arg1[%arg4 * 16 + 8] {partition_indices = [8], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %36 = affine.load %arg0[%arg5 * 64 + %arg4 * 16 + 8] {partition_indices = [8], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %37 = arith.mulf %35, %36 {timing = #hlscpp.t<42 -> 46, 4, 1>} : f64
      %38 = arith.addf %34, %37 {timing = #hlscpp.t<46 -> 51, 5, 1>} : f64
      %39 = affine.load %arg1[%arg4 * 16 + 9] {partition_indices = [9], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %40 = affine.load %arg0[%arg5 * 64 + %arg4 * 16 + 9] {partition_indices = [9], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %41 = arith.mulf %39, %40 {timing = #hlscpp.t<47 -> 51, 4, 1>} : f64
      %42 = arith.addf %38, %41 {timing = #hlscpp.t<51 -> 56, 5, 1>} : f64
      %43 = affine.load %arg1[%arg4 * 16 + 10] {partition_indices = [10], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %44 = affine.load %arg0[%arg5 * 64 + %arg4 * 16 + 10] {partition_indices = [10], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %45 = arith.mulf %43, %44 {timing = #hlscpp.t<52 -> 56, 4, 1>} : f64
      %46 = arith.addf %42, %45 {timing = #hlscpp.t<56 -> 61, 5, 1>} : f64
      %47 = affine.load %arg1[%arg4 * 16 + 11] {partition_indices = [11], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %48 = affine.load %arg0[%arg5 * 64 + %arg4 * 16 + 11] {partition_indices = [11], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %49 = arith.mulf %47, %48 {timing = #hlscpp.t<57 -> 61, 4, 1>} : f64
      %50 = arith.addf %46, %49 {timing = #hlscpp.t<61 -> 66, 5, 1>} : f64
      %51 = affine.load %arg1[%arg4 * 16 + 12] {partition_indices = [12], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %52 = affine.load %arg0[%arg5 * 64 + %arg4 * 16 + 12] {partition_indices = [12], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %53 = arith.mulf %51, %52 {timing = #hlscpp.t<62 -> 66, 4, 1>} : f64
      %54 = arith.addf %50, %53 {timing = #hlscpp.t<66 -> 71, 5, 1>} : f64
      %55 = affine.load %arg1[%arg4 * 16 + 13] {partition_indices = [13], timing = #hlscpp.t<65 -> 67, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %56 = affine.load %arg0[%arg5 * 64 + %arg4 * 16 + 13] {partition_indices = [13], timing = #hlscpp.t<65 -> 67, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %57 = arith.mulf %55, %56 {timing = #hlscpp.t<67 -> 71, 4, 1>} : f64
      %58 = arith.addf %54, %57 {timing = #hlscpp.t<71 -> 76, 5, 1>} : f64
      %59 = affine.load %arg1[%arg4 * 16 + 14] {partition_indices = [14], timing = #hlscpp.t<70 -> 72, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %60 = affine.load %arg0[%arg5 * 64 + %arg4 * 16 + 14] {partition_indices = [14], timing = #hlscpp.t<70 -> 72, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %61 = arith.mulf %59, %60 {timing = #hlscpp.t<72 -> 76, 4, 1>} : f64
      %62 = arith.addf %58, %61 {timing = #hlscpp.t<76 -> 81, 5, 1>} : f64
      %63 = affine.load %arg1[%arg4 * 16 + 15] {partition_indices = [15], timing = #hlscpp.t<75 -> 77, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %64 = affine.load %arg0[%arg5 * 64 + %arg4 * 16 + 15] {partition_indices = [15], timing = #hlscpp.t<75 -> 77, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %65 = arith.mulf %63, %64 {timing = #hlscpp.t<77 -> 81, 4, 1>} : f64
      %66 = arith.addf %62, %65 {timing = #hlscpp.t<81 -> 86, 5, 1>} : f64
      affine.store %66, %arg2[%arg5] {max_mux_size = 1 : i64, partition_indices = [0], timing = #hlscpp.t<89 -> 90, 1, 1>} : memref<64xf64, affine_map<(d0) -> (0, d0)>, 1>
      %67 = arith.mulf %66, %6 {timing = #hlscpp.t<86 -> 90, 4, 1>} : f64
      affine.if affine_set<(d0) : (-(d0 * 16 + 15) + 63 == 0)>(%arg4) {
        affine.store %67, %arg2[%arg5] {max_mux_size = 1 : i64, partition_indices = [0], timing = #hlscpp.t<90 -> 91, 1, 1>} : memref<64xf64, affine_map<(d0) -> (0, d0)>, 1>
      } {timing = #hlscpp.t<90 -> 91, 1, 0>}
    } {loop_directive = #hlscpp.ld<pipeline=true, targetII=2, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=64, iterLatency=91, minII=2>, timing = #hlscpp.t<0 -> 219, 219, 219>}
  } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true, parallel=false>, loop_info = #hlscpp.l<flattenTripCount=256, iterLatency=91, minII=2>, timing = #hlscpp.t<0 -> 603, 603, 603>}
  return {timing = #hlscpp.t<603 -> 603, 0, 0>}
}
