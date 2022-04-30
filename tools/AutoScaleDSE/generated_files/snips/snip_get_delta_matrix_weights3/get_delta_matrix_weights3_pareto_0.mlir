func @get_delta_matrix_weights3(%arg0: memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>, %arg1: memref<3xf64, affine_map<(d0) -> (d0 mod 3, d0 floordiv 3)>, 1>, %arg2: memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>, llvm.linkage = #llvm.linkage<external>, resource = #hlscpp.r<lut=0, dsp=288, bram=0>, timing = #hlscpp.t<0 -> 12, 12, 12>} {
  affine.for %arg3 = 0 to 2 {
    %0 = affine.load %arg2[%arg3 * 32] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %1 = affine.load %arg1[0] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<3xf64, affine_map<(d0) -> (d0 mod 3, d0 floordiv 3)>, 1>
    %2 = arith.mulf %0, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %2, %arg0[%arg3 * 96] {partition_indices = [0], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %3 = affine.load %arg1[1] {partition_indices = [1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<3xf64, affine_map<(d0) -> (d0 mod 3, d0 floordiv 3)>, 1>
    %4 = arith.mulf %0, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %4, %arg0[%arg3 * 96 + 1] {partition_indices = [1], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %5 = affine.load %arg1[2] {partition_indices = [2], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<3xf64, affine_map<(d0) -> (d0 mod 3, d0 floordiv 3)>, 1>
    %6 = arith.mulf %0, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %6, %arg0[%arg3 * 96 + 2] {partition_indices = [2], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %7 = affine.load %arg2[%arg3 * 32 + 1] {partition_indices = [1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %8 = arith.mulf %7, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %8, %arg0[%arg3 * 96 + 3] {partition_indices = [3], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %9 = arith.mulf %7, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %9, %arg0[%arg3 * 96 + 4] {partition_indices = [4], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %10 = arith.mulf %7, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %10, %arg0[%arg3 * 96 + 5] {partition_indices = [5], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %11 = affine.load %arg2[%arg3 * 32 + 2] {partition_indices = [2], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %12 = arith.mulf %11, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %12, %arg0[%arg3 * 96 + 6] {partition_indices = [6], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %13 = arith.mulf %11, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %13, %arg0[%arg3 * 96 + 7] {partition_indices = [7], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %14 = arith.mulf %11, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %14, %arg0[%arg3 * 96 + 8] {partition_indices = [8], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %15 = affine.load %arg2[%arg3 * 32 + 3] {partition_indices = [3], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %16 = arith.mulf %15, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %16, %arg0[%arg3 * 96 + 9] {partition_indices = [9], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %17 = arith.mulf %15, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %17, %arg0[%arg3 * 96 + 10] {partition_indices = [10], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %18 = arith.mulf %15, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %18, %arg0[%arg3 * 96 + 11] {partition_indices = [11], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %19 = affine.load %arg2[%arg3 * 32 + 4] {partition_indices = [4], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %20 = arith.mulf %19, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %20, %arg0[%arg3 * 96 + 12] {partition_indices = [12], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %21 = arith.mulf %19, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %21, %arg0[%arg3 * 96 + 13] {partition_indices = [13], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %22 = arith.mulf %19, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %22, %arg0[%arg3 * 96 + 14] {partition_indices = [14], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %23 = affine.load %arg2[%arg3 * 32 + 5] {partition_indices = [5], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %24 = arith.mulf %23, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %24, %arg0[%arg3 * 96 + 15] {partition_indices = [15], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %25 = arith.mulf %23, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %25, %arg0[%arg3 * 96 + 16] {partition_indices = [16], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %26 = arith.mulf %23, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %26, %arg0[%arg3 * 96 + 17] {partition_indices = [17], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %27 = affine.load %arg2[%arg3 * 32 + 6] {partition_indices = [6], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %28 = arith.mulf %27, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %28, %arg0[%arg3 * 96 + 18] {partition_indices = [18], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %29 = arith.mulf %27, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %29, %arg0[%arg3 * 96 + 19] {partition_indices = [19], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %30 = arith.mulf %27, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %30, %arg0[%arg3 * 96 + 20] {partition_indices = [20], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %31 = affine.load %arg2[%arg3 * 32 + 7] {partition_indices = [7], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %32 = arith.mulf %31, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %32, %arg0[%arg3 * 96 + 21] {partition_indices = [21], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %33 = arith.mulf %31, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %33, %arg0[%arg3 * 96 + 22] {partition_indices = [22], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %34 = arith.mulf %31, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %34, %arg0[%arg3 * 96 + 23] {partition_indices = [23], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %35 = affine.load %arg2[%arg3 * 32 + 8] {partition_indices = [8], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %36 = arith.mulf %35, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %36, %arg0[%arg3 * 96 + 24] {partition_indices = [24], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %37 = arith.mulf %35, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %37, %arg0[%arg3 * 96 + 25] {partition_indices = [25], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %38 = arith.mulf %35, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %38, %arg0[%arg3 * 96 + 26] {partition_indices = [26], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %39 = affine.load %arg2[%arg3 * 32 + 9] {partition_indices = [9], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %40 = arith.mulf %39, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %40, %arg0[%arg3 * 96 + 27] {partition_indices = [27], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %41 = arith.mulf %39, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %41, %arg0[%arg3 * 96 + 28] {partition_indices = [28], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %42 = arith.mulf %39, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %42, %arg0[%arg3 * 96 + 29] {partition_indices = [29], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %43 = affine.load %arg2[%arg3 * 32 + 10] {partition_indices = [10], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %44 = arith.mulf %43, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %44, %arg0[%arg3 * 96 + 30] {partition_indices = [30], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %45 = arith.mulf %43, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %45, %arg0[%arg3 * 96 + 31] {partition_indices = [31], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %46 = arith.mulf %43, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %46, %arg0[%arg3 * 96 + 32] {partition_indices = [32], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %47 = affine.load %arg2[%arg3 * 32 + 11] {partition_indices = [11], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %48 = arith.mulf %47, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %48, %arg0[%arg3 * 96 + 33] {partition_indices = [33], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %49 = arith.mulf %47, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %49, %arg0[%arg3 * 96 + 34] {partition_indices = [34], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %50 = arith.mulf %47, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %50, %arg0[%arg3 * 96 + 35] {partition_indices = [35], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %51 = affine.load %arg2[%arg3 * 32 + 12] {partition_indices = [12], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %52 = arith.mulf %51, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %52, %arg0[%arg3 * 96 + 36] {partition_indices = [36], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %53 = arith.mulf %51, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %53, %arg0[%arg3 * 96 + 37] {partition_indices = [37], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %54 = arith.mulf %51, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %54, %arg0[%arg3 * 96 + 38] {partition_indices = [38], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %55 = affine.load %arg2[%arg3 * 32 + 13] {partition_indices = [13], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %56 = arith.mulf %55, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %56, %arg0[%arg3 * 96 + 39] {partition_indices = [39], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %57 = arith.mulf %55, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %57, %arg0[%arg3 * 96 + 40] {partition_indices = [40], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %58 = arith.mulf %55, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %58, %arg0[%arg3 * 96 + 41] {partition_indices = [41], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %59 = affine.load %arg2[%arg3 * 32 + 14] {partition_indices = [14], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %60 = arith.mulf %59, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %60, %arg0[%arg3 * 96 + 42] {partition_indices = [42], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %61 = arith.mulf %59, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %61, %arg0[%arg3 * 96 + 43] {partition_indices = [43], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %62 = arith.mulf %59, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %62, %arg0[%arg3 * 96 + 44] {partition_indices = [44], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %63 = affine.load %arg2[%arg3 * 32 + 15] {partition_indices = [15], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %64 = arith.mulf %63, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %64, %arg0[%arg3 * 96 + 45] {partition_indices = [45], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %65 = arith.mulf %63, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %65, %arg0[%arg3 * 96 + 46] {partition_indices = [46], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %66 = arith.mulf %63, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %66, %arg0[%arg3 * 96 + 47] {partition_indices = [47], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %67 = affine.load %arg2[%arg3 * 32 + 16] {partition_indices = [16], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %68 = arith.mulf %67, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %68, %arg0[%arg3 * 96 + 48] {partition_indices = [48], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %69 = arith.mulf %67, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %69, %arg0[%arg3 * 96 + 49] {partition_indices = [49], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %70 = arith.mulf %67, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %70, %arg0[%arg3 * 96 + 50] {partition_indices = [50], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %71 = affine.load %arg2[%arg3 * 32 + 17] {partition_indices = [17], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %72 = arith.mulf %71, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %72, %arg0[%arg3 * 96 + 51] {partition_indices = [51], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %73 = arith.mulf %71, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %73, %arg0[%arg3 * 96 + 52] {partition_indices = [52], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %74 = arith.mulf %71, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %74, %arg0[%arg3 * 96 + 53] {partition_indices = [53], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %75 = affine.load %arg2[%arg3 * 32 + 18] {partition_indices = [18], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %76 = arith.mulf %75, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %76, %arg0[%arg3 * 96 + 54] {partition_indices = [54], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %77 = arith.mulf %75, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %77, %arg0[%arg3 * 96 + 55] {partition_indices = [55], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %78 = arith.mulf %75, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %78, %arg0[%arg3 * 96 + 56] {partition_indices = [56], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %79 = affine.load %arg2[%arg3 * 32 + 19] {partition_indices = [19], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %80 = arith.mulf %79, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %80, %arg0[%arg3 * 96 + 57] {partition_indices = [57], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %81 = arith.mulf %79, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %81, %arg0[%arg3 * 96 + 58] {partition_indices = [58], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %82 = arith.mulf %79, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %82, %arg0[%arg3 * 96 + 59] {partition_indices = [59], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %83 = affine.load %arg2[%arg3 * 32 + 20] {partition_indices = [20], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %84 = arith.mulf %83, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %84, %arg0[%arg3 * 96 + 60] {partition_indices = [60], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %85 = arith.mulf %83, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %85, %arg0[%arg3 * 96 + 61] {partition_indices = [61], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %86 = arith.mulf %83, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %86, %arg0[%arg3 * 96 + 62] {partition_indices = [62], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %87 = affine.load %arg2[%arg3 * 32 + 21] {partition_indices = [21], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %88 = arith.mulf %87, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %88, %arg0[%arg3 * 96 + 63] {partition_indices = [63], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %89 = arith.mulf %87, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %89, %arg0[%arg3 * 96 + 64] {partition_indices = [64], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %90 = arith.mulf %87, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %90, %arg0[%arg3 * 96 + 65] {partition_indices = [65], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %91 = affine.load %arg2[%arg3 * 32 + 22] {partition_indices = [22], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %92 = arith.mulf %91, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %92, %arg0[%arg3 * 96 + 66] {partition_indices = [66], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %93 = arith.mulf %91, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %93, %arg0[%arg3 * 96 + 67] {partition_indices = [67], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %94 = arith.mulf %91, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %94, %arg0[%arg3 * 96 + 68] {partition_indices = [68], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %95 = affine.load %arg2[%arg3 * 32 + 23] {partition_indices = [23], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %96 = arith.mulf %95, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %96, %arg0[%arg3 * 96 + 69] {partition_indices = [69], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %97 = arith.mulf %95, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %97, %arg0[%arg3 * 96 + 70] {partition_indices = [70], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %98 = arith.mulf %95, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %98, %arg0[%arg3 * 96 + 71] {partition_indices = [71], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %99 = affine.load %arg2[%arg3 * 32 + 24] {partition_indices = [24], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %100 = arith.mulf %99, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %100, %arg0[%arg3 * 96 + 72] {partition_indices = [72], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %101 = arith.mulf %99, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %101, %arg0[%arg3 * 96 + 73] {partition_indices = [73], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %102 = arith.mulf %99, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %102, %arg0[%arg3 * 96 + 74] {partition_indices = [74], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %103 = affine.load %arg2[%arg3 * 32 + 25] {partition_indices = [25], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %104 = arith.mulf %103, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %104, %arg0[%arg3 * 96 + 75] {partition_indices = [75], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %105 = arith.mulf %103, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %105, %arg0[%arg3 * 96 + 76] {partition_indices = [76], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %106 = arith.mulf %103, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %106, %arg0[%arg3 * 96 + 77] {partition_indices = [77], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %107 = affine.load %arg2[%arg3 * 32 + 26] {partition_indices = [26], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %108 = arith.mulf %107, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %108, %arg0[%arg3 * 96 + 78] {partition_indices = [78], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %109 = arith.mulf %107, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %109, %arg0[%arg3 * 96 + 79] {partition_indices = [79], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %110 = arith.mulf %107, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %110, %arg0[%arg3 * 96 + 80] {partition_indices = [80], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %111 = affine.load %arg2[%arg3 * 32 + 27] {partition_indices = [27], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %112 = arith.mulf %111, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %112, %arg0[%arg3 * 96 + 81] {partition_indices = [81], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %113 = arith.mulf %111, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %113, %arg0[%arg3 * 96 + 82] {partition_indices = [82], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %114 = arith.mulf %111, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %114, %arg0[%arg3 * 96 + 83] {partition_indices = [83], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %115 = affine.load %arg2[%arg3 * 32 + 28] {partition_indices = [28], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %116 = arith.mulf %115, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %116, %arg0[%arg3 * 96 + 84] {partition_indices = [84], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %117 = arith.mulf %115, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %117, %arg0[%arg3 * 96 + 85] {partition_indices = [85], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %118 = arith.mulf %115, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %118, %arg0[%arg3 * 96 + 86] {partition_indices = [86], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %119 = affine.load %arg2[%arg3 * 32 + 29] {partition_indices = [29], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %120 = arith.mulf %119, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %120, %arg0[%arg3 * 96 + 87] {partition_indices = [87], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %121 = arith.mulf %119, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %121, %arg0[%arg3 * 96 + 88] {partition_indices = [88], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %122 = arith.mulf %119, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %122, %arg0[%arg3 * 96 + 89] {partition_indices = [89], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %123 = affine.load %arg2[%arg3 * 32 + 30] {partition_indices = [30], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %124 = arith.mulf %123, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %124, %arg0[%arg3 * 96 + 90] {partition_indices = [90], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %125 = arith.mulf %123, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %125, %arg0[%arg3 * 96 + 91] {partition_indices = [91], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %126 = arith.mulf %123, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %126, %arg0[%arg3 * 96 + 92] {partition_indices = [92], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %127 = affine.load %arg2[%arg3 * 32 + 31] {partition_indices = [31], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 32, d0 floordiv 32)>, 1>
    %128 = arith.mulf %127, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %128, %arg0[%arg3 * 96 + 93] {partition_indices = [93], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %129 = arith.mulf %127, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %129, %arg0[%arg3 * 96 + 94] {partition_indices = [94], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
    %130 = arith.mulf %127, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %130, %arg0[%arg3 * 96 + 95] {partition_indices = [95], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 96, d0 floordiv 96)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=1, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=2, iterLatency=7, minII=1>, timing = #hlscpp.t<0 -> 10, 10, 10>}
  return {timing = #hlscpp.t<10 -> 10, 0, 0>}
}
