func @get_delta_matrix_weights2(%arg0: memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>, %arg1: memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>, %arg2: memref<64xf64, affine_map<(d0) -> (d0 mod 4, d0 floordiv 4)>, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>, llvm.linkage = #llvm.linkage<external>, resource = #hlscpp.r<lut=0, dsp=258, bram=0>, timing = #hlscpp.t<0 -> 56, 56, 56>} {
  affine.for %arg3 = 0 to 16 {
    %0 = affine.load %arg2[%arg3 * 4] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 4, d0 floordiv 4)>, 1>
    %1 = affine.load %arg1[0] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %2 = arith.mulf %0, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %2, %arg0[%arg3 * 256] {partition_indices = [0], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %3 = affine.load %arg1[1] {partition_indices = [1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %4 = arith.mulf %0, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %4, %arg0[%arg3 * 256 + 1] {partition_indices = [1], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %5 = affine.load %arg1[2] {partition_indices = [2], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %6 = arith.mulf %0, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %6, %arg0[%arg3 * 256 + 2] {partition_indices = [2], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %7 = affine.load %arg1[3] {partition_indices = [3], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %8 = arith.mulf %0, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %8, %arg0[%arg3 * 256 + 3] {partition_indices = [3], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %9 = affine.load %arg1[4] {partition_indices = [4], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %10 = arith.mulf %0, %9 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %10, %arg0[%arg3 * 256 + 4] {partition_indices = [4], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %11 = affine.load %arg1[5] {partition_indices = [5], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %12 = arith.mulf %0, %11 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %12, %arg0[%arg3 * 256 + 5] {partition_indices = [5], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %13 = affine.load %arg1[6] {partition_indices = [6], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %14 = arith.mulf %0, %13 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %14, %arg0[%arg3 * 256 + 6] {partition_indices = [6], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %15 = affine.load %arg1[7] {partition_indices = [7], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %16 = arith.mulf %0, %15 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %16, %arg0[%arg3 * 256 + 7] {partition_indices = [7], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %17 = affine.load %arg1[8] {partition_indices = [8], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %18 = arith.mulf %0, %17 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %18, %arg0[%arg3 * 256 + 8] {partition_indices = [8], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %19 = affine.load %arg1[9] {partition_indices = [9], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %20 = arith.mulf %0, %19 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %20, %arg0[%arg3 * 256 + 9] {partition_indices = [9], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %21 = affine.load %arg1[10] {partition_indices = [10], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %22 = arith.mulf %0, %21 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %22, %arg0[%arg3 * 256 + 10] {partition_indices = [10], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %23 = affine.load %arg1[11] {partition_indices = [11], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %24 = arith.mulf %0, %23 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %24, %arg0[%arg3 * 256 + 11] {partition_indices = [11], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %25 = affine.load %arg1[12] {partition_indices = [12], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %26 = arith.mulf %0, %25 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %26, %arg0[%arg3 * 256 + 12] {partition_indices = [12], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %27 = affine.load %arg1[13] {partition_indices = [13], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %28 = arith.mulf %0, %27 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %28, %arg0[%arg3 * 256 + 13] {partition_indices = [13], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %29 = affine.load %arg1[14] {partition_indices = [14], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %30 = arith.mulf %0, %29 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %30, %arg0[%arg3 * 256 + 14] {partition_indices = [14], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %31 = affine.load %arg1[15] {partition_indices = [15], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %32 = arith.mulf %0, %31 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %32, %arg0[%arg3 * 256 + 15] {partition_indices = [15], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %33 = affine.load %arg1[16] {partition_indices = [16], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %34 = arith.mulf %0, %33 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %34, %arg0[%arg3 * 256 + 16] {partition_indices = [16], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %35 = affine.load %arg1[17] {partition_indices = [17], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %36 = arith.mulf %0, %35 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %36, %arg0[%arg3 * 256 + 17] {partition_indices = [17], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %37 = affine.load %arg1[18] {partition_indices = [18], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %38 = arith.mulf %0, %37 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %38, %arg0[%arg3 * 256 + 18] {partition_indices = [18], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %39 = affine.load %arg1[19] {partition_indices = [19], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %40 = arith.mulf %0, %39 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %40, %arg0[%arg3 * 256 + 19] {partition_indices = [19], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %41 = affine.load %arg1[20] {partition_indices = [20], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %42 = arith.mulf %0, %41 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %42, %arg0[%arg3 * 256 + 20] {partition_indices = [20], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %43 = affine.load %arg1[21] {partition_indices = [21], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %44 = arith.mulf %0, %43 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %44, %arg0[%arg3 * 256 + 21] {partition_indices = [21], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %45 = affine.load %arg1[22] {partition_indices = [22], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %46 = arith.mulf %0, %45 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %46, %arg0[%arg3 * 256 + 22] {partition_indices = [22], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %47 = affine.load %arg1[23] {partition_indices = [23], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %48 = arith.mulf %0, %47 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %48, %arg0[%arg3 * 256 + 23] {partition_indices = [23], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %49 = affine.load %arg1[24] {partition_indices = [24], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %50 = arith.mulf %0, %49 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %50, %arg0[%arg3 * 256 + 24] {partition_indices = [24], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %51 = affine.load %arg1[25] {partition_indices = [25], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %52 = arith.mulf %0, %51 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %52, %arg0[%arg3 * 256 + 25] {partition_indices = [25], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %53 = affine.load %arg1[26] {partition_indices = [26], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %54 = arith.mulf %0, %53 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %54, %arg0[%arg3 * 256 + 26] {partition_indices = [26], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %55 = affine.load %arg1[27] {partition_indices = [27], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %56 = arith.mulf %0, %55 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %56, %arg0[%arg3 * 256 + 27] {partition_indices = [27], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %57 = affine.load %arg1[28] {partition_indices = [28], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %58 = arith.mulf %0, %57 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %58, %arg0[%arg3 * 256 + 28] {partition_indices = [28], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %59 = affine.load %arg1[29] {partition_indices = [29], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %60 = arith.mulf %0, %59 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %60, %arg0[%arg3 * 256 + 29] {partition_indices = [29], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %61 = affine.load %arg1[30] {partition_indices = [30], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %62 = arith.mulf %0, %61 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %62, %arg0[%arg3 * 256 + 30] {partition_indices = [30], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %63 = affine.load %arg1[31] {partition_indices = [31], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %64 = arith.mulf %0, %63 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %64, %arg0[%arg3 * 256 + 31] {partition_indices = [31], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %65 = affine.load %arg1[32] {partition_indices = [32], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %66 = arith.mulf %0, %65 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %66, %arg0[%arg3 * 256 + 32] {partition_indices = [32], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %67 = affine.load %arg1[33] {partition_indices = [33], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %68 = arith.mulf %0, %67 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %68, %arg0[%arg3 * 256 + 33] {partition_indices = [33], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %69 = affine.load %arg1[34] {partition_indices = [34], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %70 = arith.mulf %0, %69 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %70, %arg0[%arg3 * 256 + 34] {partition_indices = [34], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %71 = affine.load %arg1[35] {partition_indices = [35], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %72 = arith.mulf %0, %71 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %72, %arg0[%arg3 * 256 + 35] {partition_indices = [35], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %73 = affine.load %arg1[36] {partition_indices = [36], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %74 = arith.mulf %0, %73 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %74, %arg0[%arg3 * 256 + 36] {partition_indices = [36], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %75 = affine.load %arg1[37] {partition_indices = [37], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %76 = arith.mulf %0, %75 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %76, %arg0[%arg3 * 256 + 37] {partition_indices = [37], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %77 = affine.load %arg1[38] {partition_indices = [38], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %78 = arith.mulf %0, %77 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %78, %arg0[%arg3 * 256 + 38] {partition_indices = [38], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %79 = affine.load %arg1[39] {partition_indices = [39], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %80 = arith.mulf %0, %79 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %80, %arg0[%arg3 * 256 + 39] {partition_indices = [39], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %81 = affine.load %arg1[40] {partition_indices = [40], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %82 = arith.mulf %0, %81 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %82, %arg0[%arg3 * 256 + 40] {partition_indices = [40], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %83 = affine.load %arg1[41] {partition_indices = [41], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %84 = arith.mulf %0, %83 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %84, %arg0[%arg3 * 256 + 41] {partition_indices = [41], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %85 = affine.load %arg1[42] {partition_indices = [42], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %86 = arith.mulf %0, %85 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %86, %arg0[%arg3 * 256 + 42] {partition_indices = [42], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %87 = affine.load %arg1[43] {partition_indices = [43], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %88 = arith.mulf %0, %87 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %88, %arg0[%arg3 * 256 + 43] {partition_indices = [43], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %89 = affine.load %arg1[44] {partition_indices = [44], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %90 = arith.mulf %0, %89 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %90, %arg0[%arg3 * 256 + 44] {partition_indices = [44], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %91 = affine.load %arg1[45] {partition_indices = [45], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %92 = arith.mulf %0, %91 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %92, %arg0[%arg3 * 256 + 45] {partition_indices = [45], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %93 = affine.load %arg1[46] {partition_indices = [46], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %94 = arith.mulf %0, %93 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %94, %arg0[%arg3 * 256 + 46] {partition_indices = [46], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %95 = affine.load %arg1[47] {partition_indices = [47], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %96 = arith.mulf %0, %95 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %96, %arg0[%arg3 * 256 + 47] {partition_indices = [47], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %97 = affine.load %arg1[48] {partition_indices = [48], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %98 = arith.mulf %0, %97 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %98, %arg0[%arg3 * 256 + 48] {partition_indices = [48], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %99 = affine.load %arg1[49] {partition_indices = [49], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %100 = arith.mulf %0, %99 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %100, %arg0[%arg3 * 256 + 49] {partition_indices = [49], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %101 = affine.load %arg1[50] {partition_indices = [50], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %102 = arith.mulf %0, %101 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %102, %arg0[%arg3 * 256 + 50] {partition_indices = [50], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %103 = affine.load %arg1[51] {partition_indices = [51], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %104 = arith.mulf %0, %103 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %104, %arg0[%arg3 * 256 + 51] {partition_indices = [51], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %105 = affine.load %arg1[52] {partition_indices = [52], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %106 = arith.mulf %0, %105 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %106, %arg0[%arg3 * 256 + 52] {partition_indices = [52], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %107 = affine.load %arg1[53] {partition_indices = [53], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %108 = arith.mulf %0, %107 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %108, %arg0[%arg3 * 256 + 53] {partition_indices = [53], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %109 = affine.load %arg1[54] {partition_indices = [54], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %110 = arith.mulf %0, %109 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %110, %arg0[%arg3 * 256 + 54] {partition_indices = [54], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %111 = affine.load %arg1[55] {partition_indices = [55], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %112 = arith.mulf %0, %111 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %112, %arg0[%arg3 * 256 + 55] {partition_indices = [55], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %113 = affine.load %arg1[56] {partition_indices = [56], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %114 = arith.mulf %0, %113 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %114, %arg0[%arg3 * 256 + 56] {partition_indices = [56], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %115 = affine.load %arg1[57] {partition_indices = [57], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %116 = arith.mulf %0, %115 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %116, %arg0[%arg3 * 256 + 57] {partition_indices = [57], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %117 = affine.load %arg1[58] {partition_indices = [58], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %118 = arith.mulf %0, %117 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %118, %arg0[%arg3 * 256 + 58] {partition_indices = [58], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %119 = affine.load %arg1[59] {partition_indices = [59], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %120 = arith.mulf %0, %119 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %120, %arg0[%arg3 * 256 + 59] {partition_indices = [59], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %121 = affine.load %arg1[60] {partition_indices = [60], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %122 = arith.mulf %0, %121 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %122, %arg0[%arg3 * 256 + 60] {partition_indices = [60], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %123 = affine.load %arg1[61] {partition_indices = [61], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %124 = arith.mulf %0, %123 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %124, %arg0[%arg3 * 256 + 61] {partition_indices = [61], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %125 = affine.load %arg1[62] {partition_indices = [62], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %126 = arith.mulf %0, %125 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %126, %arg0[%arg3 * 256 + 62] {partition_indices = [62], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %127 = affine.load %arg1[63] {partition_indices = [63], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %128 = arith.mulf %0, %127 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %128, %arg0[%arg3 * 256 + 63] {partition_indices = [63], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %129 = affine.load %arg2[%arg3 * 4 + 1] {partition_indices = [1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 4, d0 floordiv 4)>, 1>
    %130 = arith.mulf %129, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %130, %arg0[%arg3 * 256 + 64] {partition_indices = [64], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %131 = arith.mulf %129, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %131, %arg0[%arg3 * 256 + 65] {partition_indices = [65], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %132 = arith.mulf %129, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %132, %arg0[%arg3 * 256 + 66] {partition_indices = [66], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %133 = arith.mulf %129, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %133, %arg0[%arg3 * 256 + 67] {partition_indices = [67], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %134 = arith.mulf %129, %9 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %134, %arg0[%arg3 * 256 + 68] {partition_indices = [68], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %135 = arith.mulf %129, %11 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %135, %arg0[%arg3 * 256 + 69] {partition_indices = [69], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %136 = arith.mulf %129, %13 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %136, %arg0[%arg3 * 256 + 70] {partition_indices = [70], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %137 = arith.mulf %129, %15 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %137, %arg0[%arg3 * 256 + 71] {partition_indices = [71], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %138 = arith.mulf %129, %17 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %138, %arg0[%arg3 * 256 + 72] {partition_indices = [72], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %139 = arith.mulf %129, %19 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %139, %arg0[%arg3 * 256 + 73] {partition_indices = [73], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %140 = arith.mulf %129, %21 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %140, %arg0[%arg3 * 256 + 74] {partition_indices = [74], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %141 = arith.mulf %129, %23 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %141, %arg0[%arg3 * 256 + 75] {partition_indices = [75], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %142 = arith.mulf %129, %25 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %142, %arg0[%arg3 * 256 + 76] {partition_indices = [76], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %143 = arith.mulf %129, %27 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %143, %arg0[%arg3 * 256 + 77] {partition_indices = [77], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %144 = arith.mulf %129, %29 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %144, %arg0[%arg3 * 256 + 78] {partition_indices = [78], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %145 = arith.mulf %129, %31 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %145, %arg0[%arg3 * 256 + 79] {partition_indices = [79], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %146 = arith.mulf %129, %33 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %146, %arg0[%arg3 * 256 + 80] {partition_indices = [80], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %147 = arith.mulf %129, %35 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %147, %arg0[%arg3 * 256 + 81] {partition_indices = [81], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %148 = arith.mulf %129, %37 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %148, %arg0[%arg3 * 256 + 82] {partition_indices = [82], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %149 = arith.mulf %129, %39 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %149, %arg0[%arg3 * 256 + 83] {partition_indices = [83], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %150 = arith.mulf %129, %41 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %150, %arg0[%arg3 * 256 + 84] {partition_indices = [84], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %151 = arith.mulf %129, %43 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %151, %arg0[%arg3 * 256 + 85] {partition_indices = [85], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %152 = arith.mulf %129, %45 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %152, %arg0[%arg3 * 256 + 86] {partition_indices = [86], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %153 = arith.mulf %129, %47 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %153, %arg0[%arg3 * 256 + 87] {partition_indices = [87], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %154 = arith.mulf %129, %49 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %154, %arg0[%arg3 * 256 + 88] {partition_indices = [88], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %155 = arith.mulf %129, %51 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %155, %arg0[%arg3 * 256 + 89] {partition_indices = [89], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %156 = arith.mulf %129, %53 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %156, %arg0[%arg3 * 256 + 90] {partition_indices = [90], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %157 = arith.mulf %129, %55 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %157, %arg0[%arg3 * 256 + 91] {partition_indices = [91], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %158 = arith.mulf %129, %57 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %158, %arg0[%arg3 * 256 + 92] {partition_indices = [92], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %159 = arith.mulf %129, %59 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %159, %arg0[%arg3 * 256 + 93] {partition_indices = [93], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %160 = arith.mulf %129, %61 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %160, %arg0[%arg3 * 256 + 94] {partition_indices = [94], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %161 = arith.mulf %129, %63 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %161, %arg0[%arg3 * 256 + 95] {partition_indices = [95], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %162 = arith.mulf %129, %65 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %162, %arg0[%arg3 * 256 + 96] {partition_indices = [96], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %163 = arith.mulf %129, %67 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %163, %arg0[%arg3 * 256 + 97] {partition_indices = [97], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %164 = arith.mulf %129, %69 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %164, %arg0[%arg3 * 256 + 98] {partition_indices = [98], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %165 = arith.mulf %129, %71 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %165, %arg0[%arg3 * 256 + 99] {partition_indices = [99], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %166 = arith.mulf %129, %73 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %166, %arg0[%arg3 * 256 + 100] {partition_indices = [100], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %167 = arith.mulf %129, %75 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %167, %arg0[%arg3 * 256 + 101] {partition_indices = [101], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %168 = arith.mulf %129, %77 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %168, %arg0[%arg3 * 256 + 102] {partition_indices = [102], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %169 = arith.mulf %129, %79 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %169, %arg0[%arg3 * 256 + 103] {partition_indices = [103], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %170 = arith.mulf %129, %81 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %170, %arg0[%arg3 * 256 + 104] {partition_indices = [104], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %171 = arith.mulf %129, %83 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %171, %arg0[%arg3 * 256 + 105] {partition_indices = [105], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %172 = arith.mulf %129, %85 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %172, %arg0[%arg3 * 256 + 106] {partition_indices = [106], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %173 = arith.mulf %129, %87 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %173, %arg0[%arg3 * 256 + 107] {partition_indices = [107], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %174 = arith.mulf %129, %89 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %174, %arg0[%arg3 * 256 + 108] {partition_indices = [108], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %175 = arith.mulf %129, %91 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %175, %arg0[%arg3 * 256 + 109] {partition_indices = [109], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %176 = arith.mulf %129, %93 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %176, %arg0[%arg3 * 256 + 110] {partition_indices = [110], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %177 = arith.mulf %129, %95 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %177, %arg0[%arg3 * 256 + 111] {partition_indices = [111], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %178 = arith.mulf %129, %97 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %178, %arg0[%arg3 * 256 + 112] {partition_indices = [112], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %179 = arith.mulf %129, %99 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %179, %arg0[%arg3 * 256 + 113] {partition_indices = [113], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %180 = arith.mulf %129, %101 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %180, %arg0[%arg3 * 256 + 114] {partition_indices = [114], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %181 = arith.mulf %129, %103 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %181, %arg0[%arg3 * 256 + 115] {partition_indices = [115], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %182 = arith.mulf %129, %105 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %182, %arg0[%arg3 * 256 + 116] {partition_indices = [116], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %183 = arith.mulf %129, %107 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %183, %arg0[%arg3 * 256 + 117] {partition_indices = [117], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %184 = arith.mulf %129, %109 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %184, %arg0[%arg3 * 256 + 118] {partition_indices = [118], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %185 = arith.mulf %129, %111 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %185, %arg0[%arg3 * 256 + 119] {partition_indices = [119], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %186 = arith.mulf %129, %113 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %186, %arg0[%arg3 * 256 + 120] {partition_indices = [120], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %187 = arith.mulf %129, %115 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %187, %arg0[%arg3 * 256 + 121] {partition_indices = [121], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %188 = arith.mulf %129, %117 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %188, %arg0[%arg3 * 256 + 122] {partition_indices = [122], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %189 = arith.mulf %129, %119 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %189, %arg0[%arg3 * 256 + 123] {partition_indices = [123], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %190 = arith.mulf %129, %121 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %190, %arg0[%arg3 * 256 + 124] {partition_indices = [124], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %191 = arith.mulf %129, %123 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %191, %arg0[%arg3 * 256 + 125] {partition_indices = [125], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %192 = arith.mulf %129, %125 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %192, %arg0[%arg3 * 256 + 126] {partition_indices = [126], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %193 = arith.mulf %129, %127 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %193, %arg0[%arg3 * 256 + 127] {partition_indices = [127], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %194 = affine.load %arg2[%arg3 * 4 + 2] {partition_indices = [2], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 4, d0 floordiv 4)>, 1>
    %195 = arith.mulf %194, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %195, %arg0[%arg3 * 256 + 128] {partition_indices = [128], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %196 = arith.mulf %194, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %196, %arg0[%arg3 * 256 + 129] {partition_indices = [129], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %197 = arith.mulf %194, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %197, %arg0[%arg3 * 256 + 130] {partition_indices = [130], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %198 = arith.mulf %194, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %198, %arg0[%arg3 * 256 + 131] {partition_indices = [131], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %199 = arith.mulf %194, %9 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %199, %arg0[%arg3 * 256 + 132] {partition_indices = [132], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %200 = arith.mulf %194, %11 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %200, %arg0[%arg3 * 256 + 133] {partition_indices = [133], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %201 = arith.mulf %194, %13 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %201, %arg0[%arg3 * 256 + 134] {partition_indices = [134], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %202 = arith.mulf %194, %15 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %202, %arg0[%arg3 * 256 + 135] {partition_indices = [135], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %203 = arith.mulf %194, %17 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %203, %arg0[%arg3 * 256 + 136] {partition_indices = [136], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %204 = arith.mulf %194, %19 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %204, %arg0[%arg3 * 256 + 137] {partition_indices = [137], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %205 = arith.mulf %194, %21 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %205, %arg0[%arg3 * 256 + 138] {partition_indices = [138], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %206 = arith.mulf %194, %23 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %206, %arg0[%arg3 * 256 + 139] {partition_indices = [139], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %207 = arith.mulf %194, %25 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %207, %arg0[%arg3 * 256 + 140] {partition_indices = [140], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %208 = arith.mulf %194, %27 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %208, %arg0[%arg3 * 256 + 141] {partition_indices = [141], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %209 = arith.mulf %194, %29 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %209, %arg0[%arg3 * 256 + 142] {partition_indices = [142], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %210 = arith.mulf %194, %31 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %210, %arg0[%arg3 * 256 + 143] {partition_indices = [143], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %211 = arith.mulf %194, %33 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %211, %arg0[%arg3 * 256 + 144] {partition_indices = [144], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %212 = arith.mulf %194, %35 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %212, %arg0[%arg3 * 256 + 145] {partition_indices = [145], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %213 = arith.mulf %194, %37 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %213, %arg0[%arg3 * 256 + 146] {partition_indices = [146], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %214 = arith.mulf %194, %39 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %214, %arg0[%arg3 * 256 + 147] {partition_indices = [147], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %215 = arith.mulf %194, %41 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %215, %arg0[%arg3 * 256 + 148] {partition_indices = [148], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %216 = arith.mulf %194, %43 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %216, %arg0[%arg3 * 256 + 149] {partition_indices = [149], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %217 = arith.mulf %194, %45 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %217, %arg0[%arg3 * 256 + 150] {partition_indices = [150], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %218 = arith.mulf %194, %47 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %218, %arg0[%arg3 * 256 + 151] {partition_indices = [151], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %219 = arith.mulf %194, %49 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %219, %arg0[%arg3 * 256 + 152] {partition_indices = [152], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %220 = arith.mulf %194, %51 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %220, %arg0[%arg3 * 256 + 153] {partition_indices = [153], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %221 = arith.mulf %194, %53 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %221, %arg0[%arg3 * 256 + 154] {partition_indices = [154], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %222 = arith.mulf %194, %55 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %222, %arg0[%arg3 * 256 + 155] {partition_indices = [155], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %223 = arith.mulf %194, %57 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %223, %arg0[%arg3 * 256 + 156] {partition_indices = [156], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %224 = arith.mulf %194, %59 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %224, %arg0[%arg3 * 256 + 157] {partition_indices = [157], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %225 = arith.mulf %194, %61 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %225, %arg0[%arg3 * 256 + 158] {partition_indices = [158], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %226 = arith.mulf %194, %63 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %226, %arg0[%arg3 * 256 + 159] {partition_indices = [159], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %227 = arith.mulf %194, %65 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %227, %arg0[%arg3 * 256 + 160] {partition_indices = [160], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %228 = arith.mulf %194, %67 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %228, %arg0[%arg3 * 256 + 161] {partition_indices = [161], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %229 = arith.mulf %194, %69 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %229, %arg0[%arg3 * 256 + 162] {partition_indices = [162], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %230 = arith.mulf %194, %71 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %230, %arg0[%arg3 * 256 + 163] {partition_indices = [163], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %231 = arith.mulf %194, %73 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %231, %arg0[%arg3 * 256 + 164] {partition_indices = [164], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %232 = arith.mulf %194, %75 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %232, %arg0[%arg3 * 256 + 165] {partition_indices = [165], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %233 = arith.mulf %194, %77 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %233, %arg0[%arg3 * 256 + 166] {partition_indices = [166], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %234 = arith.mulf %194, %79 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %234, %arg0[%arg3 * 256 + 167] {partition_indices = [167], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %235 = arith.mulf %194, %81 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %235, %arg0[%arg3 * 256 + 168] {partition_indices = [168], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %236 = arith.mulf %194, %83 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %236, %arg0[%arg3 * 256 + 169] {partition_indices = [169], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %237 = arith.mulf %194, %85 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %237, %arg0[%arg3 * 256 + 170] {partition_indices = [170], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %238 = arith.mulf %194, %87 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %238, %arg0[%arg3 * 256 + 171] {partition_indices = [171], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %239 = arith.mulf %194, %89 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %239, %arg0[%arg3 * 256 + 172] {partition_indices = [172], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %240 = arith.mulf %194, %91 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %240, %arg0[%arg3 * 256 + 173] {partition_indices = [173], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %241 = arith.mulf %194, %93 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %241, %arg0[%arg3 * 256 + 174] {partition_indices = [174], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %242 = arith.mulf %194, %95 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %242, %arg0[%arg3 * 256 + 175] {partition_indices = [175], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %243 = arith.mulf %194, %97 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %243, %arg0[%arg3 * 256 + 176] {partition_indices = [176], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %244 = arith.mulf %194, %99 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %244, %arg0[%arg3 * 256 + 177] {partition_indices = [177], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %245 = arith.mulf %194, %101 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %245, %arg0[%arg3 * 256 + 178] {partition_indices = [178], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %246 = arith.mulf %194, %103 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %246, %arg0[%arg3 * 256 + 179] {partition_indices = [179], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %247 = arith.mulf %194, %105 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %247, %arg0[%arg3 * 256 + 180] {partition_indices = [180], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %248 = arith.mulf %194, %107 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %248, %arg0[%arg3 * 256 + 181] {partition_indices = [181], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %249 = arith.mulf %194, %109 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %249, %arg0[%arg3 * 256 + 182] {partition_indices = [182], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %250 = arith.mulf %194, %111 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %250, %arg0[%arg3 * 256 + 183] {partition_indices = [183], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %251 = arith.mulf %194, %113 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %251, %arg0[%arg3 * 256 + 184] {partition_indices = [184], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %252 = arith.mulf %194, %115 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %252, %arg0[%arg3 * 256 + 185] {partition_indices = [185], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %253 = arith.mulf %194, %117 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %253, %arg0[%arg3 * 256 + 186] {partition_indices = [186], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %254 = arith.mulf %194, %119 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %254, %arg0[%arg3 * 256 + 187] {partition_indices = [187], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %255 = arith.mulf %194, %121 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %255, %arg0[%arg3 * 256 + 188] {partition_indices = [188], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %256 = arith.mulf %194, %123 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %256, %arg0[%arg3 * 256 + 189] {partition_indices = [189], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %257 = arith.mulf %194, %125 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %257, %arg0[%arg3 * 256 + 190] {partition_indices = [190], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %258 = arith.mulf %194, %127 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %258, %arg0[%arg3 * 256 + 191] {partition_indices = [191], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %259 = affine.load %arg2[%arg3 * 4 + 3] {partition_indices = [3], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 4, d0 floordiv 4)>, 1>
    %260 = arith.mulf %259, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %260, %arg0[%arg3 * 256 + 192] {partition_indices = [192], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %261 = arith.mulf %259, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %261, %arg0[%arg3 * 256 + 193] {partition_indices = [193], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %262 = arith.mulf %259, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %262, %arg0[%arg3 * 256 + 194] {partition_indices = [194], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %263 = arith.mulf %259, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %263, %arg0[%arg3 * 256 + 195] {partition_indices = [195], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %264 = arith.mulf %259, %9 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %264, %arg0[%arg3 * 256 + 196] {partition_indices = [196], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %265 = arith.mulf %259, %11 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %265, %arg0[%arg3 * 256 + 197] {partition_indices = [197], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %266 = arith.mulf %259, %13 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %266, %arg0[%arg3 * 256 + 198] {partition_indices = [198], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %267 = arith.mulf %259, %15 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %267, %arg0[%arg3 * 256 + 199] {partition_indices = [199], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %268 = arith.mulf %259, %17 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %268, %arg0[%arg3 * 256 + 200] {partition_indices = [200], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %269 = arith.mulf %259, %19 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %269, %arg0[%arg3 * 256 + 201] {partition_indices = [201], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %270 = arith.mulf %259, %21 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %270, %arg0[%arg3 * 256 + 202] {partition_indices = [202], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %271 = arith.mulf %259, %23 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %271, %arg0[%arg3 * 256 + 203] {partition_indices = [203], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %272 = arith.mulf %259, %25 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %272, %arg0[%arg3 * 256 + 204] {partition_indices = [204], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %273 = arith.mulf %259, %27 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %273, %arg0[%arg3 * 256 + 205] {partition_indices = [205], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %274 = arith.mulf %259, %29 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %274, %arg0[%arg3 * 256 + 206] {partition_indices = [206], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %275 = arith.mulf %259, %31 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %275, %arg0[%arg3 * 256 + 207] {partition_indices = [207], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %276 = arith.mulf %259, %33 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %276, %arg0[%arg3 * 256 + 208] {partition_indices = [208], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %277 = arith.mulf %259, %35 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %277, %arg0[%arg3 * 256 + 209] {partition_indices = [209], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %278 = arith.mulf %259, %37 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %278, %arg0[%arg3 * 256 + 210] {partition_indices = [210], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %279 = arith.mulf %259, %39 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %279, %arg0[%arg3 * 256 + 211] {partition_indices = [211], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %280 = arith.mulf %259, %41 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %280, %arg0[%arg3 * 256 + 212] {partition_indices = [212], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %281 = arith.mulf %259, %43 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %281, %arg0[%arg3 * 256 + 213] {partition_indices = [213], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %282 = arith.mulf %259, %45 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %282, %arg0[%arg3 * 256 + 214] {partition_indices = [214], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %283 = arith.mulf %259, %47 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %283, %arg0[%arg3 * 256 + 215] {partition_indices = [215], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %284 = arith.mulf %259, %49 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %284, %arg0[%arg3 * 256 + 216] {partition_indices = [216], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %285 = arith.mulf %259, %51 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %285, %arg0[%arg3 * 256 + 217] {partition_indices = [217], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %286 = arith.mulf %259, %53 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %286, %arg0[%arg3 * 256 + 218] {partition_indices = [218], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %287 = arith.mulf %259, %55 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %287, %arg0[%arg3 * 256 + 219] {partition_indices = [219], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %288 = arith.mulf %259, %57 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %288, %arg0[%arg3 * 256 + 220] {partition_indices = [220], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %289 = arith.mulf %259, %59 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %289, %arg0[%arg3 * 256 + 221] {partition_indices = [221], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %290 = arith.mulf %259, %61 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %290, %arg0[%arg3 * 256 + 222] {partition_indices = [222], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %291 = arith.mulf %259, %63 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %291, %arg0[%arg3 * 256 + 223] {partition_indices = [223], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %292 = arith.mulf %259, %65 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %292, %arg0[%arg3 * 256 + 224] {partition_indices = [224], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %293 = arith.mulf %259, %67 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %293, %arg0[%arg3 * 256 + 225] {partition_indices = [225], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %294 = arith.mulf %259, %69 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %294, %arg0[%arg3 * 256 + 226] {partition_indices = [226], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %295 = arith.mulf %259, %71 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %295, %arg0[%arg3 * 256 + 227] {partition_indices = [227], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %296 = arith.mulf %259, %73 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %296, %arg0[%arg3 * 256 + 228] {partition_indices = [228], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %297 = arith.mulf %259, %75 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %297, %arg0[%arg3 * 256 + 229] {partition_indices = [229], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %298 = arith.mulf %259, %77 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %298, %arg0[%arg3 * 256 + 230] {partition_indices = [230], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %299 = arith.mulf %259, %79 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %299, %arg0[%arg3 * 256 + 231] {partition_indices = [231], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %300 = arith.mulf %259, %81 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %300, %arg0[%arg3 * 256 + 232] {partition_indices = [232], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %301 = arith.mulf %259, %83 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %301, %arg0[%arg3 * 256 + 233] {partition_indices = [233], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %302 = arith.mulf %259, %85 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %302, %arg0[%arg3 * 256 + 234] {partition_indices = [234], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %303 = arith.mulf %259, %87 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %303, %arg0[%arg3 * 256 + 235] {partition_indices = [235], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %304 = arith.mulf %259, %89 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %304, %arg0[%arg3 * 256 + 236] {partition_indices = [236], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %305 = arith.mulf %259, %91 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %305, %arg0[%arg3 * 256 + 237] {partition_indices = [237], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %306 = arith.mulf %259, %93 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %306, %arg0[%arg3 * 256 + 238] {partition_indices = [238], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %307 = arith.mulf %259, %95 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %307, %arg0[%arg3 * 256 + 239] {partition_indices = [239], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %308 = arith.mulf %259, %97 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %308, %arg0[%arg3 * 256 + 240] {partition_indices = [240], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %309 = arith.mulf %259, %99 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %309, %arg0[%arg3 * 256 + 241] {partition_indices = [241], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %310 = arith.mulf %259, %101 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %310, %arg0[%arg3 * 256 + 242] {partition_indices = [242], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %311 = arith.mulf %259, %103 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %311, %arg0[%arg3 * 256 + 243] {partition_indices = [243], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %312 = arith.mulf %259, %105 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %312, %arg0[%arg3 * 256 + 244] {partition_indices = [244], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %313 = arith.mulf %259, %107 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %313, %arg0[%arg3 * 256 + 245] {partition_indices = [245], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %314 = arith.mulf %259, %109 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %314, %arg0[%arg3 * 256 + 246] {partition_indices = [246], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %315 = arith.mulf %259, %111 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %315, %arg0[%arg3 * 256 + 247] {partition_indices = [247], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %316 = arith.mulf %259, %113 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %316, %arg0[%arg3 * 256 + 248] {partition_indices = [248], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %317 = arith.mulf %259, %115 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %317, %arg0[%arg3 * 256 + 249] {partition_indices = [249], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %318 = arith.mulf %259, %117 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %318, %arg0[%arg3 * 256 + 250] {partition_indices = [250], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %319 = arith.mulf %259, %119 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %319, %arg0[%arg3 * 256 + 251] {partition_indices = [251], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %320 = arith.mulf %259, %121 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %320, %arg0[%arg3 * 256 + 252] {partition_indices = [252], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %321 = arith.mulf %259, %123 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %321, %arg0[%arg3 * 256 + 253] {partition_indices = [253], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %322 = arith.mulf %259, %125 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %322, %arg0[%arg3 * 256 + 254] {partition_indices = [254], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %323 = arith.mulf %259, %127 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %323, %arg0[%arg3 * 256 + 255] {partition_indices = [255], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=3, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=16, iterLatency=7, minII=3>, timing = #hlscpp.t<0 -> 54, 54, 54>}
  return {timing = #hlscpp.t<54 -> 54, 0, 0>}
}
