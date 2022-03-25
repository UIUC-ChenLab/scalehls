func @get_oracle_activations2(%arg0: memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>, %arg1: memref<3xf64, affine_map<(d0) -> (d0 mod 3, d0 floordiv 3)>, 1>, %arg2: memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>, %arg3: memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>, llvm.linkage = #llvm.linkage<external>, resource = #hlscpp.r<lut=0, dsp=144, bram=0>, timing = #hlscpp.t<0 -> 37, 37, 37>} {
  %cst = arith.constant {timing = #hlscpp.t<0 -> 0, 0, 0>} 0.000000e+00 : f64
  affine.for %arg4 = 0 to 8 {
    %0 = affine.load %arg1[0] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<3xf64, affine_map<(d0) -> (d0 mod 3, d0 floordiv 3)>, 1>
    %1 = affine.load %arg0[%arg4 * 24] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %2 = arith.mulf %0, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %3 = arith.addf %2, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %4 = affine.load %arg3[%arg4 * 8] {partition_indices = [0], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %5 = affine.load %arg0[%arg4 * 24 + 3] {partition_indices = [3], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %6 = arith.mulf %0, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %7 = arith.addf %6, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %8 = affine.load %arg3[%arg4 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %9 = affine.load %arg0[%arg4 * 24 + 6] {partition_indices = [6], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %10 = arith.mulf %0, %9 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %11 = arith.addf %10, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %12 = affine.load %arg3[%arg4 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %13 = affine.load %arg0[%arg4 * 24 + 9] {partition_indices = [9], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %14 = arith.mulf %0, %13 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %15 = arith.addf %14, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %16 = affine.load %arg3[%arg4 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %17 = affine.load %arg0[%arg4 * 24 + 12] {partition_indices = [12], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %18 = arith.mulf %0, %17 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %19 = arith.addf %18, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %20 = affine.load %arg3[%arg4 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %21 = affine.load %arg0[%arg4 * 24 + 15] {partition_indices = [15], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %22 = arith.mulf %0, %21 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %23 = arith.addf %22, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %24 = affine.load %arg3[%arg4 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %25 = affine.load %arg0[%arg4 * 24 + 18] {partition_indices = [18], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %26 = arith.mulf %0, %25 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %27 = arith.addf %26, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %28 = affine.load %arg3[%arg4 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %29 = affine.load %arg0[%arg4 * 24 + 21] {partition_indices = [21], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %30 = arith.mulf %0, %29 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %31 = arith.addf %30, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %32 = affine.load %arg3[%arg4 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %33 = affine.load %arg1[1] {partition_indices = [1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<3xf64, affine_map<(d0) -> (d0 mod 3, d0 floordiv 3)>, 1>
    %34 = affine.load %arg0[%arg4 * 24 + 1] {partition_indices = [1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %35 = arith.mulf %33, %34 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %36 = arith.addf %3, %35 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %37 = affine.load %arg0[%arg4 * 24 + 4] {partition_indices = [4], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %38 = arith.mulf %33, %37 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %39 = arith.addf %7, %38 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %40 = affine.load %arg0[%arg4 * 24 + 7] {partition_indices = [7], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %41 = arith.mulf %33, %40 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %42 = arith.addf %11, %41 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %43 = affine.load %arg0[%arg4 * 24 + 10] {partition_indices = [10], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %44 = arith.mulf %33, %43 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %45 = arith.addf %15, %44 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %46 = affine.load %arg0[%arg4 * 24 + 13] {partition_indices = [13], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %47 = arith.mulf %33, %46 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %48 = arith.addf %19, %47 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %49 = affine.load %arg0[%arg4 * 24 + 16] {partition_indices = [16], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %50 = arith.mulf %33, %49 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %51 = arith.addf %23, %50 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %52 = affine.load %arg0[%arg4 * 24 + 19] {partition_indices = [19], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %53 = arith.mulf %33, %52 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %54 = arith.addf %27, %53 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %55 = affine.load %arg0[%arg4 * 24 + 22] {partition_indices = [22], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %56 = arith.mulf %33, %55 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %57 = arith.addf %31, %56 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %58 = affine.load %arg1[2] {partition_indices = [2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<3xf64, affine_map<(d0) -> (d0 mod 3, d0 floordiv 3)>, 1>
    %59 = affine.load %arg0[%arg4 * 24 + 2] {partition_indices = [2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %60 = arith.mulf %58, %59 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %61 = arith.addf %36, %60 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %62 = arith.mulf %61, %4 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %62, %arg2[%arg4 * 8] {partition_indices = [0], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %63 = affine.load %arg0[%arg4 * 24 + 5] {partition_indices = [5], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %64 = arith.mulf %58, %63 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %65 = arith.addf %39, %64 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %66 = arith.mulf %65, %8 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %66, %arg2[%arg4 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %67 = affine.load %arg0[%arg4 * 24 + 8] {partition_indices = [8], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %68 = arith.mulf %58, %67 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %69 = arith.addf %42, %68 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %70 = arith.mulf %69, %12 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %70, %arg2[%arg4 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %71 = affine.load %arg0[%arg4 * 24 + 11] {partition_indices = [11], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %72 = arith.mulf %58, %71 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %73 = arith.addf %45, %72 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %74 = arith.mulf %73, %16 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %74, %arg2[%arg4 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %75 = affine.load %arg0[%arg4 * 24 + 14] {partition_indices = [14], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %76 = arith.mulf %58, %75 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %77 = arith.addf %48, %76 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %78 = arith.mulf %77, %20 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %78, %arg2[%arg4 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %79 = affine.load %arg0[%arg4 * 24 + 17] {partition_indices = [17], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %80 = arith.mulf %58, %79 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %81 = arith.addf %51, %80 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %82 = arith.mulf %81, %24 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %82, %arg2[%arg4 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %83 = affine.load %arg0[%arg4 * 24 + 20] {partition_indices = [20], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %84 = arith.mulf %58, %83 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %85 = arith.addf %54, %84 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %86 = arith.mulf %85, %28 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %86, %arg2[%arg4 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %87 = affine.load %arg0[%arg4 * 24 + 23] {partition_indices = [23], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %88 = arith.mulf %58, %87 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %89 = arith.addf %57, %88 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %90 = arith.mulf %89, %32 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    affine.store %90, %arg2[%arg4 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=1, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=8, iterLatency=26, minII=1>, timing = #hlscpp.t<0 -> 35, 35, 35>}
  return {timing = #hlscpp.t<35 -> 35, 0, 0>}
}
