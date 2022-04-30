func @get_delta_matrix_weights2(%arg0: memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>, %arg1: memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>, %arg2: memref<64xf64, affine_map<(d0) -> (d0 mod 2, d0 floordiv 2)>, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>, llvm.linkage = #llvm.linkage<external>, resource = #hlscpp.r<lut=0, dsp=192, bram=0>, timing = #hlscpp.t<0 -> 73, 73, 73>} {
  affine.for %arg3 = 0 to 32 {
    %0 = affine.load %arg2[%arg3 * 2] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 2, d0 floordiv 2)>, 1>
    %1 = affine.load %arg1[0] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %2 = arith.mulf %0, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %2, %arg0[%arg3 * 128] {partition_indices = [0], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %3 = affine.load %arg1[1] {partition_indices = [1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %4 = arith.mulf %0, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %4, %arg0[%arg3 * 128 + 1] {partition_indices = [1], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %5 = affine.load %arg1[2] {partition_indices = [2], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %6 = arith.mulf %0, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %6, %arg0[%arg3 * 128 + 2] {partition_indices = [2], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %7 = affine.load %arg1[3] {partition_indices = [3], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %8 = arith.mulf %0, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %8, %arg0[%arg3 * 128 + 3] {partition_indices = [3], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %9 = affine.load %arg1[4] {partition_indices = [4], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %10 = arith.mulf %0, %9 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %10, %arg0[%arg3 * 128 + 4] {partition_indices = [4], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %11 = affine.load %arg1[5] {partition_indices = [5], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %12 = arith.mulf %0, %11 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %12, %arg0[%arg3 * 128 + 5] {partition_indices = [5], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %13 = affine.load %arg1[6] {partition_indices = [6], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %14 = arith.mulf %0, %13 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %14, %arg0[%arg3 * 128 + 6] {partition_indices = [6], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %15 = affine.load %arg1[7] {partition_indices = [7], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %16 = arith.mulf %0, %15 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %16, %arg0[%arg3 * 128 + 7] {partition_indices = [7], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %17 = affine.load %arg1[8] {partition_indices = [8], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %18 = arith.mulf %0, %17 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %18, %arg0[%arg3 * 128 + 8] {partition_indices = [8], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %19 = affine.load %arg1[9] {partition_indices = [9], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %20 = arith.mulf %0, %19 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %20, %arg0[%arg3 * 128 + 9] {partition_indices = [9], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %21 = affine.load %arg1[10] {partition_indices = [10], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %22 = arith.mulf %0, %21 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %22, %arg0[%arg3 * 128 + 10] {partition_indices = [10], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %23 = affine.load %arg1[11] {partition_indices = [11], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %24 = arith.mulf %0, %23 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %24, %arg0[%arg3 * 128 + 11] {partition_indices = [11], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %25 = affine.load %arg1[12] {partition_indices = [12], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %26 = arith.mulf %0, %25 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %26, %arg0[%arg3 * 128 + 12] {partition_indices = [12], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %27 = affine.load %arg1[13] {partition_indices = [13], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %28 = arith.mulf %0, %27 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %28, %arg0[%arg3 * 128 + 13] {partition_indices = [13], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %29 = affine.load %arg1[14] {partition_indices = [14], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %30 = arith.mulf %0, %29 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %30, %arg0[%arg3 * 128 + 14] {partition_indices = [14], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %31 = affine.load %arg1[15] {partition_indices = [15], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %32 = arith.mulf %0, %31 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %32, %arg0[%arg3 * 128 + 15] {partition_indices = [15], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %33 = affine.load %arg1[16] {partition_indices = [16], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %34 = arith.mulf %0, %33 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %34, %arg0[%arg3 * 128 + 16] {partition_indices = [16], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %35 = affine.load %arg1[17] {partition_indices = [17], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %36 = arith.mulf %0, %35 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %36, %arg0[%arg3 * 128 + 17] {partition_indices = [17], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %37 = affine.load %arg1[18] {partition_indices = [18], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %38 = arith.mulf %0, %37 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %38, %arg0[%arg3 * 128 + 18] {partition_indices = [18], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %39 = affine.load %arg1[19] {partition_indices = [19], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %40 = arith.mulf %0, %39 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %40, %arg0[%arg3 * 128 + 19] {partition_indices = [19], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %41 = affine.load %arg1[20] {partition_indices = [20], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %42 = arith.mulf %0, %41 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %42, %arg0[%arg3 * 128 + 20] {partition_indices = [20], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %43 = affine.load %arg1[21] {partition_indices = [21], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %44 = arith.mulf %0, %43 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %44, %arg0[%arg3 * 128 + 21] {partition_indices = [21], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %45 = affine.load %arg1[22] {partition_indices = [22], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %46 = arith.mulf %0, %45 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %46, %arg0[%arg3 * 128 + 22] {partition_indices = [22], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %47 = affine.load %arg1[23] {partition_indices = [23], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %48 = arith.mulf %0, %47 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %48, %arg0[%arg3 * 128 + 23] {partition_indices = [23], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %49 = affine.load %arg1[24] {partition_indices = [24], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %50 = arith.mulf %0, %49 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %50, %arg0[%arg3 * 128 + 24] {partition_indices = [24], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %51 = affine.load %arg1[25] {partition_indices = [25], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %52 = arith.mulf %0, %51 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %52, %arg0[%arg3 * 128 + 25] {partition_indices = [25], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %53 = affine.load %arg1[26] {partition_indices = [26], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %54 = arith.mulf %0, %53 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %54, %arg0[%arg3 * 128 + 26] {partition_indices = [26], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %55 = affine.load %arg1[27] {partition_indices = [27], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %56 = arith.mulf %0, %55 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %56, %arg0[%arg3 * 128 + 27] {partition_indices = [27], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %57 = affine.load %arg1[28] {partition_indices = [28], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %58 = arith.mulf %0, %57 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %58, %arg0[%arg3 * 128 + 28] {partition_indices = [28], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %59 = affine.load %arg1[29] {partition_indices = [29], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %60 = arith.mulf %0, %59 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %60, %arg0[%arg3 * 128 + 29] {partition_indices = [29], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %61 = affine.load %arg1[30] {partition_indices = [30], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %62 = arith.mulf %0, %61 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %62, %arg0[%arg3 * 128 + 30] {partition_indices = [30], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %63 = affine.load %arg1[31] {partition_indices = [31], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %64 = arith.mulf %0, %63 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %64, %arg0[%arg3 * 128 + 31] {partition_indices = [31], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %65 = affine.load %arg1[32] {partition_indices = [32], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %66 = arith.mulf %0, %65 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %66, %arg0[%arg3 * 128 + 32] {partition_indices = [32], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %67 = affine.load %arg1[33] {partition_indices = [33], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %68 = arith.mulf %0, %67 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %68, %arg0[%arg3 * 128 + 33] {partition_indices = [33], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %69 = affine.load %arg1[34] {partition_indices = [34], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %70 = arith.mulf %0, %69 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %70, %arg0[%arg3 * 128 + 34] {partition_indices = [34], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %71 = affine.load %arg1[35] {partition_indices = [35], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %72 = arith.mulf %0, %71 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %72, %arg0[%arg3 * 128 + 35] {partition_indices = [35], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %73 = affine.load %arg1[36] {partition_indices = [36], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %74 = arith.mulf %0, %73 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %74, %arg0[%arg3 * 128 + 36] {partition_indices = [36], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %75 = affine.load %arg1[37] {partition_indices = [37], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %76 = arith.mulf %0, %75 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %76, %arg0[%arg3 * 128 + 37] {partition_indices = [37], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %77 = affine.load %arg1[38] {partition_indices = [38], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %78 = arith.mulf %0, %77 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %78, %arg0[%arg3 * 128 + 38] {partition_indices = [38], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %79 = affine.load %arg1[39] {partition_indices = [39], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %80 = arith.mulf %0, %79 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %80, %arg0[%arg3 * 128 + 39] {partition_indices = [39], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %81 = affine.load %arg1[40] {partition_indices = [40], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %82 = arith.mulf %0, %81 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %82, %arg0[%arg3 * 128 + 40] {partition_indices = [40], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %83 = affine.load %arg1[41] {partition_indices = [41], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %84 = arith.mulf %0, %83 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %84, %arg0[%arg3 * 128 + 41] {partition_indices = [41], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %85 = affine.load %arg1[42] {partition_indices = [42], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %86 = arith.mulf %0, %85 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %86, %arg0[%arg3 * 128 + 42] {partition_indices = [42], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %87 = affine.load %arg1[43] {partition_indices = [43], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %88 = arith.mulf %0, %87 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %88, %arg0[%arg3 * 128 + 43] {partition_indices = [43], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %89 = affine.load %arg1[44] {partition_indices = [44], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %90 = arith.mulf %0, %89 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %90, %arg0[%arg3 * 128 + 44] {partition_indices = [44], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %91 = affine.load %arg1[45] {partition_indices = [45], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %92 = arith.mulf %0, %91 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %92, %arg0[%arg3 * 128 + 45] {partition_indices = [45], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %93 = affine.load %arg1[46] {partition_indices = [46], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %94 = arith.mulf %0, %93 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %94, %arg0[%arg3 * 128 + 46] {partition_indices = [46], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %95 = affine.load %arg1[47] {partition_indices = [47], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %96 = arith.mulf %0, %95 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %96, %arg0[%arg3 * 128 + 47] {partition_indices = [47], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %97 = affine.load %arg1[48] {partition_indices = [48], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %98 = arith.mulf %0, %97 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %98, %arg0[%arg3 * 128 + 48] {partition_indices = [48], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %99 = affine.load %arg1[49] {partition_indices = [49], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %100 = arith.mulf %0, %99 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %100, %arg0[%arg3 * 128 + 49] {partition_indices = [49], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %101 = affine.load %arg1[50] {partition_indices = [50], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %102 = arith.mulf %0, %101 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %102, %arg0[%arg3 * 128 + 50] {partition_indices = [50], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %103 = affine.load %arg1[51] {partition_indices = [51], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %104 = arith.mulf %0, %103 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %104, %arg0[%arg3 * 128 + 51] {partition_indices = [51], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %105 = affine.load %arg1[52] {partition_indices = [52], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %106 = arith.mulf %0, %105 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %106, %arg0[%arg3 * 128 + 52] {partition_indices = [52], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %107 = affine.load %arg1[53] {partition_indices = [53], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %108 = arith.mulf %0, %107 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %108, %arg0[%arg3 * 128 + 53] {partition_indices = [53], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %109 = affine.load %arg1[54] {partition_indices = [54], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %110 = arith.mulf %0, %109 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %110, %arg0[%arg3 * 128 + 54] {partition_indices = [54], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %111 = affine.load %arg1[55] {partition_indices = [55], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %112 = arith.mulf %0, %111 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %112, %arg0[%arg3 * 128 + 55] {partition_indices = [55], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %113 = affine.load %arg1[56] {partition_indices = [56], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %114 = arith.mulf %0, %113 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %114, %arg0[%arg3 * 128 + 56] {partition_indices = [56], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %115 = affine.load %arg1[57] {partition_indices = [57], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %116 = arith.mulf %0, %115 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %116, %arg0[%arg3 * 128 + 57] {partition_indices = [57], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %117 = affine.load %arg1[58] {partition_indices = [58], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %118 = arith.mulf %0, %117 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %118, %arg0[%arg3 * 128 + 58] {partition_indices = [58], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %119 = affine.load %arg1[59] {partition_indices = [59], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %120 = arith.mulf %0, %119 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %120, %arg0[%arg3 * 128 + 59] {partition_indices = [59], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %121 = affine.load %arg1[60] {partition_indices = [60], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %122 = arith.mulf %0, %121 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %122, %arg0[%arg3 * 128 + 60] {partition_indices = [60], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %123 = affine.load %arg1[61] {partition_indices = [61], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %124 = arith.mulf %0, %123 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %124, %arg0[%arg3 * 128 + 61] {partition_indices = [61], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %125 = affine.load %arg1[62] {partition_indices = [62], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %126 = arith.mulf %0, %125 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %126, %arg0[%arg3 * 128 + 62] {partition_indices = [62], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %127 = affine.load %arg1[63] {partition_indices = [63], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %128 = arith.mulf %0, %127 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %128, %arg0[%arg3 * 128 + 63] {partition_indices = [63], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %129 = affine.load %arg2[%arg3 * 2 + 1] {partition_indices = [1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 2, d0 floordiv 2)>, 1>
    %130 = arith.mulf %129, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %130, %arg0[%arg3 * 128 + 64] {partition_indices = [64], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %131 = arith.mulf %129, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %131, %arg0[%arg3 * 128 + 65] {partition_indices = [65], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %132 = arith.mulf %129, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %132, %arg0[%arg3 * 128 + 66] {partition_indices = [66], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %133 = arith.mulf %129, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %133, %arg0[%arg3 * 128 + 67] {partition_indices = [67], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %134 = arith.mulf %129, %9 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %134, %arg0[%arg3 * 128 + 68] {partition_indices = [68], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %135 = arith.mulf %129, %11 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %135, %arg0[%arg3 * 128 + 69] {partition_indices = [69], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %136 = arith.mulf %129, %13 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %136, %arg0[%arg3 * 128 + 70] {partition_indices = [70], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %137 = arith.mulf %129, %15 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %137, %arg0[%arg3 * 128 + 71] {partition_indices = [71], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %138 = arith.mulf %129, %17 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %138, %arg0[%arg3 * 128 + 72] {partition_indices = [72], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %139 = arith.mulf %129, %19 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %139, %arg0[%arg3 * 128 + 73] {partition_indices = [73], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %140 = arith.mulf %129, %21 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %140, %arg0[%arg3 * 128 + 74] {partition_indices = [74], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %141 = arith.mulf %129, %23 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %141, %arg0[%arg3 * 128 + 75] {partition_indices = [75], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %142 = arith.mulf %129, %25 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %142, %arg0[%arg3 * 128 + 76] {partition_indices = [76], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %143 = arith.mulf %129, %27 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %143, %arg0[%arg3 * 128 + 77] {partition_indices = [77], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %144 = arith.mulf %129, %29 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %144, %arg0[%arg3 * 128 + 78] {partition_indices = [78], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %145 = arith.mulf %129, %31 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %145, %arg0[%arg3 * 128 + 79] {partition_indices = [79], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %146 = arith.mulf %129, %33 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %146, %arg0[%arg3 * 128 + 80] {partition_indices = [80], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %147 = arith.mulf %129, %35 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %147, %arg0[%arg3 * 128 + 81] {partition_indices = [81], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %148 = arith.mulf %129, %37 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %148, %arg0[%arg3 * 128 + 82] {partition_indices = [82], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %149 = arith.mulf %129, %39 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %149, %arg0[%arg3 * 128 + 83] {partition_indices = [83], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %150 = arith.mulf %129, %41 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %150, %arg0[%arg3 * 128 + 84] {partition_indices = [84], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %151 = arith.mulf %129, %43 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %151, %arg0[%arg3 * 128 + 85] {partition_indices = [85], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %152 = arith.mulf %129, %45 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %152, %arg0[%arg3 * 128 + 86] {partition_indices = [86], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %153 = arith.mulf %129, %47 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %153, %arg0[%arg3 * 128 + 87] {partition_indices = [87], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %154 = arith.mulf %129, %49 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %154, %arg0[%arg3 * 128 + 88] {partition_indices = [88], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %155 = arith.mulf %129, %51 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %155, %arg0[%arg3 * 128 + 89] {partition_indices = [89], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %156 = arith.mulf %129, %53 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %156, %arg0[%arg3 * 128 + 90] {partition_indices = [90], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %157 = arith.mulf %129, %55 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %157, %arg0[%arg3 * 128 + 91] {partition_indices = [91], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %158 = arith.mulf %129, %57 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %158, %arg0[%arg3 * 128 + 92] {partition_indices = [92], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %159 = arith.mulf %129, %59 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %159, %arg0[%arg3 * 128 + 93] {partition_indices = [93], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %160 = arith.mulf %129, %61 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %160, %arg0[%arg3 * 128 + 94] {partition_indices = [94], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %161 = arith.mulf %129, %63 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %161, %arg0[%arg3 * 128 + 95] {partition_indices = [95], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %162 = arith.mulf %129, %65 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %162, %arg0[%arg3 * 128 + 96] {partition_indices = [96], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %163 = arith.mulf %129, %67 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %163, %arg0[%arg3 * 128 + 97] {partition_indices = [97], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %164 = arith.mulf %129, %69 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %164, %arg0[%arg3 * 128 + 98] {partition_indices = [98], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %165 = arith.mulf %129, %71 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %165, %arg0[%arg3 * 128 + 99] {partition_indices = [99], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %166 = arith.mulf %129, %73 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %166, %arg0[%arg3 * 128 + 100] {partition_indices = [100], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %167 = arith.mulf %129, %75 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %167, %arg0[%arg3 * 128 + 101] {partition_indices = [101], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %168 = arith.mulf %129, %77 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %168, %arg0[%arg3 * 128 + 102] {partition_indices = [102], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %169 = arith.mulf %129, %79 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %169, %arg0[%arg3 * 128 + 103] {partition_indices = [103], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %170 = arith.mulf %129, %81 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %170, %arg0[%arg3 * 128 + 104] {partition_indices = [104], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %171 = arith.mulf %129, %83 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %171, %arg0[%arg3 * 128 + 105] {partition_indices = [105], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %172 = arith.mulf %129, %85 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %172, %arg0[%arg3 * 128 + 106] {partition_indices = [106], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %173 = arith.mulf %129, %87 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %173, %arg0[%arg3 * 128 + 107] {partition_indices = [107], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %174 = arith.mulf %129, %89 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %174, %arg0[%arg3 * 128 + 108] {partition_indices = [108], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %175 = arith.mulf %129, %91 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %175, %arg0[%arg3 * 128 + 109] {partition_indices = [109], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %176 = arith.mulf %129, %93 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %176, %arg0[%arg3 * 128 + 110] {partition_indices = [110], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %177 = arith.mulf %129, %95 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %177, %arg0[%arg3 * 128 + 111] {partition_indices = [111], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %178 = arith.mulf %129, %97 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %178, %arg0[%arg3 * 128 + 112] {partition_indices = [112], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %179 = arith.mulf %129, %99 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %179, %arg0[%arg3 * 128 + 113] {partition_indices = [113], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %180 = arith.mulf %129, %101 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %180, %arg0[%arg3 * 128 + 114] {partition_indices = [114], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %181 = arith.mulf %129, %103 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %181, %arg0[%arg3 * 128 + 115] {partition_indices = [115], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %182 = arith.mulf %129, %105 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %182, %arg0[%arg3 * 128 + 116] {partition_indices = [116], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %183 = arith.mulf %129, %107 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %183, %arg0[%arg3 * 128 + 117] {partition_indices = [117], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %184 = arith.mulf %129, %109 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %184, %arg0[%arg3 * 128 + 118] {partition_indices = [118], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %185 = arith.mulf %129, %111 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %185, %arg0[%arg3 * 128 + 119] {partition_indices = [119], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %186 = arith.mulf %129, %113 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %186, %arg0[%arg3 * 128 + 120] {partition_indices = [120], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %187 = arith.mulf %129, %115 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %187, %arg0[%arg3 * 128 + 121] {partition_indices = [121], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %188 = arith.mulf %129, %117 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %188, %arg0[%arg3 * 128 + 122] {partition_indices = [122], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %189 = arith.mulf %129, %119 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %189, %arg0[%arg3 * 128 + 123] {partition_indices = [123], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %190 = arith.mulf %129, %121 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %190, %arg0[%arg3 * 128 + 124] {partition_indices = [124], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %191 = arith.mulf %129, %123 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %191, %arg0[%arg3 * 128 + 125] {partition_indices = [125], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %192 = arith.mulf %129, %125 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %192, %arg0[%arg3 * 128 + 126] {partition_indices = [126], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %193 = arith.mulf %129, %127 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %193, %arg0[%arg3 * 128 + 127] {partition_indices = [127], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=2, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=32, iterLatency=7, minII=2>, timing = #hlscpp.t<0 -> 71, 71, 71>}
  return {timing = #hlscpp.t<71 -> 71, 0, 0>}
}
