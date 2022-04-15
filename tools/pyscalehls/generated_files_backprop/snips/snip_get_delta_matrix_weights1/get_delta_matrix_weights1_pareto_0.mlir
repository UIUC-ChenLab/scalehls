func @get_delta_matrix_weights1(%arg0: memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>, %arg1: memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>, %arg2: memref<13xf64, affine_map<(d0) -> (0, d0)>, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>, llvm.linkage = #llvm.linkage<external>, resource = #hlscpp.r<lut=0, dsp=192, bram=0>, timing = #hlscpp.t<0 -> 23, 23, 23>} {
  affine.for %arg3 = 0 to 13 {
    %0 = affine.load %arg2[%arg3] {max_mux_size = 1 : i64, partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<13xf64, affine_map<(d0) -> (0, d0)>, 1>
    %1 = affine.load %arg1[0] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %2 = arith.mulf %0, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %2, %arg0[%arg3 * 64] {partition_indices = [0], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %3 = affine.load %arg1[1] {partition_indices = [1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %4 = arith.mulf %0, %3 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %4, %arg0[%arg3 * 64 + 1] {partition_indices = [1], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %5 = affine.load %arg1[2] {partition_indices = [2], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %6 = arith.mulf %0, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %6, %arg0[%arg3 * 64 + 2] {partition_indices = [2], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %7 = affine.load %arg1[3] {partition_indices = [3], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %8 = arith.mulf %0, %7 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %8, %arg0[%arg3 * 64 + 3] {partition_indices = [3], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %9 = affine.load %arg1[4] {partition_indices = [4], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %10 = arith.mulf %0, %9 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %10, %arg0[%arg3 * 64 + 4] {partition_indices = [4], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %11 = affine.load %arg1[5] {partition_indices = [5], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %12 = arith.mulf %0, %11 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %12, %arg0[%arg3 * 64 + 5] {partition_indices = [5], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %13 = affine.load %arg1[6] {partition_indices = [6], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %14 = arith.mulf %0, %13 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %14, %arg0[%arg3 * 64 + 6] {partition_indices = [6], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %15 = affine.load %arg1[7] {partition_indices = [7], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %16 = arith.mulf %0, %15 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %16, %arg0[%arg3 * 64 + 7] {partition_indices = [7], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %17 = affine.load %arg1[8] {partition_indices = [8], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %18 = arith.mulf %0, %17 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %18, %arg0[%arg3 * 64 + 8] {partition_indices = [8], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %19 = affine.load %arg1[9] {partition_indices = [9], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %20 = arith.mulf %0, %19 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %20, %arg0[%arg3 * 64 + 9] {partition_indices = [9], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %21 = affine.load %arg1[10] {partition_indices = [10], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %22 = arith.mulf %0, %21 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %22, %arg0[%arg3 * 64 + 10] {partition_indices = [10], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %23 = affine.load %arg1[11] {partition_indices = [11], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %24 = arith.mulf %0, %23 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %24, %arg0[%arg3 * 64 + 11] {partition_indices = [11], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %25 = affine.load %arg1[12] {partition_indices = [12], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %26 = arith.mulf %0, %25 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %26, %arg0[%arg3 * 64 + 12] {partition_indices = [12], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %27 = affine.load %arg1[13] {partition_indices = [13], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %28 = arith.mulf %0, %27 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %28, %arg0[%arg3 * 64 + 13] {partition_indices = [13], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %29 = affine.load %arg1[14] {partition_indices = [14], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %30 = arith.mulf %0, %29 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %30, %arg0[%arg3 * 64 + 14] {partition_indices = [14], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %31 = affine.load %arg1[15] {partition_indices = [15], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %32 = arith.mulf %0, %31 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %32, %arg0[%arg3 * 64 + 15] {partition_indices = [15], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %33 = affine.load %arg1[16] {partition_indices = [16], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %34 = arith.mulf %0, %33 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %34, %arg0[%arg3 * 64 + 16] {partition_indices = [16], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %35 = affine.load %arg1[17] {partition_indices = [17], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %36 = arith.mulf %0, %35 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %36, %arg0[%arg3 * 64 + 17] {partition_indices = [17], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %37 = affine.load %arg1[18] {partition_indices = [18], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %38 = arith.mulf %0, %37 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %38, %arg0[%arg3 * 64 + 18] {partition_indices = [18], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %39 = affine.load %arg1[19] {partition_indices = [19], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %40 = arith.mulf %0, %39 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %40, %arg0[%arg3 * 64 + 19] {partition_indices = [19], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %41 = affine.load %arg1[20] {partition_indices = [20], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %42 = arith.mulf %0, %41 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %42, %arg0[%arg3 * 64 + 20] {partition_indices = [20], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %43 = affine.load %arg1[21] {partition_indices = [21], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %44 = arith.mulf %0, %43 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %44, %arg0[%arg3 * 64 + 21] {partition_indices = [21], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %45 = affine.load %arg1[22] {partition_indices = [22], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %46 = arith.mulf %0, %45 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %46, %arg0[%arg3 * 64 + 22] {partition_indices = [22], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %47 = affine.load %arg1[23] {partition_indices = [23], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %48 = arith.mulf %0, %47 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %48, %arg0[%arg3 * 64 + 23] {partition_indices = [23], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %49 = affine.load %arg1[24] {partition_indices = [24], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %50 = arith.mulf %0, %49 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %50, %arg0[%arg3 * 64 + 24] {partition_indices = [24], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %51 = affine.load %arg1[25] {partition_indices = [25], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %52 = arith.mulf %0, %51 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %52, %arg0[%arg3 * 64 + 25] {partition_indices = [25], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %53 = affine.load %arg1[26] {partition_indices = [26], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %54 = arith.mulf %0, %53 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %54, %arg0[%arg3 * 64 + 26] {partition_indices = [26], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %55 = affine.load %arg1[27] {partition_indices = [27], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %56 = arith.mulf %0, %55 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %56, %arg0[%arg3 * 64 + 27] {partition_indices = [27], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %57 = affine.load %arg1[28] {partition_indices = [28], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %58 = arith.mulf %0, %57 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %58, %arg0[%arg3 * 64 + 28] {partition_indices = [28], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %59 = affine.load %arg1[29] {partition_indices = [29], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %60 = arith.mulf %0, %59 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %60, %arg0[%arg3 * 64 + 29] {partition_indices = [29], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %61 = affine.load %arg1[30] {partition_indices = [30], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %62 = arith.mulf %0, %61 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %62, %arg0[%arg3 * 64 + 30] {partition_indices = [30], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %63 = affine.load %arg1[31] {partition_indices = [31], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %64 = arith.mulf %0, %63 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %64, %arg0[%arg3 * 64 + 31] {partition_indices = [31], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %65 = affine.load %arg1[32] {partition_indices = [32], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %66 = arith.mulf %0, %65 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %66, %arg0[%arg3 * 64 + 32] {partition_indices = [32], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %67 = affine.load %arg1[33] {partition_indices = [33], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %68 = arith.mulf %0, %67 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %68, %arg0[%arg3 * 64 + 33] {partition_indices = [33], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %69 = affine.load %arg1[34] {partition_indices = [34], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %70 = arith.mulf %0, %69 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %70, %arg0[%arg3 * 64 + 34] {partition_indices = [34], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %71 = affine.load %arg1[35] {partition_indices = [35], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %72 = arith.mulf %0, %71 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %72, %arg0[%arg3 * 64 + 35] {partition_indices = [35], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %73 = affine.load %arg1[36] {partition_indices = [36], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %74 = arith.mulf %0, %73 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %74, %arg0[%arg3 * 64 + 36] {partition_indices = [36], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %75 = affine.load %arg1[37] {partition_indices = [37], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %76 = arith.mulf %0, %75 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %76, %arg0[%arg3 * 64 + 37] {partition_indices = [37], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %77 = affine.load %arg1[38] {partition_indices = [38], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %78 = arith.mulf %0, %77 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %78, %arg0[%arg3 * 64 + 38] {partition_indices = [38], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %79 = affine.load %arg1[39] {partition_indices = [39], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %80 = arith.mulf %0, %79 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %80, %arg0[%arg3 * 64 + 39] {partition_indices = [39], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %81 = affine.load %arg1[40] {partition_indices = [40], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %82 = arith.mulf %0, %81 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %82, %arg0[%arg3 * 64 + 40] {partition_indices = [40], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %83 = affine.load %arg1[41] {partition_indices = [41], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %84 = arith.mulf %0, %83 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %84, %arg0[%arg3 * 64 + 41] {partition_indices = [41], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %85 = affine.load %arg1[42] {partition_indices = [42], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %86 = arith.mulf %0, %85 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %86, %arg0[%arg3 * 64 + 42] {partition_indices = [42], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %87 = affine.load %arg1[43] {partition_indices = [43], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %88 = arith.mulf %0, %87 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %88, %arg0[%arg3 * 64 + 43] {partition_indices = [43], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %89 = affine.load %arg1[44] {partition_indices = [44], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %90 = arith.mulf %0, %89 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %90, %arg0[%arg3 * 64 + 44] {partition_indices = [44], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %91 = affine.load %arg1[45] {partition_indices = [45], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %92 = arith.mulf %0, %91 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %92, %arg0[%arg3 * 64 + 45] {partition_indices = [45], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %93 = affine.load %arg1[46] {partition_indices = [46], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %94 = arith.mulf %0, %93 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %94, %arg0[%arg3 * 64 + 46] {partition_indices = [46], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %95 = affine.load %arg1[47] {partition_indices = [47], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %96 = arith.mulf %0, %95 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %96, %arg0[%arg3 * 64 + 47] {partition_indices = [47], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %97 = affine.load %arg1[48] {partition_indices = [48], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %98 = arith.mulf %0, %97 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %98, %arg0[%arg3 * 64 + 48] {partition_indices = [48], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %99 = affine.load %arg1[49] {partition_indices = [49], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %100 = arith.mulf %0, %99 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %100, %arg0[%arg3 * 64 + 49] {partition_indices = [49], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %101 = affine.load %arg1[50] {partition_indices = [50], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %102 = arith.mulf %0, %101 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %102, %arg0[%arg3 * 64 + 50] {partition_indices = [50], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %103 = affine.load %arg1[51] {partition_indices = [51], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %104 = arith.mulf %0, %103 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %104, %arg0[%arg3 * 64 + 51] {partition_indices = [51], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %105 = affine.load %arg1[52] {partition_indices = [52], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %106 = arith.mulf %0, %105 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %106, %arg0[%arg3 * 64 + 52] {partition_indices = [52], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %107 = affine.load %arg1[53] {partition_indices = [53], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %108 = arith.mulf %0, %107 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %108, %arg0[%arg3 * 64 + 53] {partition_indices = [53], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %109 = affine.load %arg1[54] {partition_indices = [54], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %110 = arith.mulf %0, %109 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %110, %arg0[%arg3 * 64 + 54] {partition_indices = [54], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %111 = affine.load %arg1[55] {partition_indices = [55], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %112 = arith.mulf %0, %111 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %112, %arg0[%arg3 * 64 + 55] {partition_indices = [55], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %113 = affine.load %arg1[56] {partition_indices = [56], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %114 = arith.mulf %0, %113 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %114, %arg0[%arg3 * 64 + 56] {partition_indices = [56], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %115 = affine.load %arg1[57] {partition_indices = [57], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %116 = arith.mulf %0, %115 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %116, %arg0[%arg3 * 64 + 57] {partition_indices = [57], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %117 = affine.load %arg1[58] {partition_indices = [58], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %118 = arith.mulf %0, %117 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %118, %arg0[%arg3 * 64 + 58] {partition_indices = [58], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %119 = affine.load %arg1[59] {partition_indices = [59], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %120 = arith.mulf %0, %119 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %120, %arg0[%arg3 * 64 + 59] {partition_indices = [59], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %121 = affine.load %arg1[60] {partition_indices = [60], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %122 = arith.mulf %0, %121 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %122, %arg0[%arg3 * 64 + 60] {partition_indices = [60], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %123 = affine.load %arg1[61] {partition_indices = [61], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %124 = arith.mulf %0, %123 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %124, %arg0[%arg3 * 64 + 61] {partition_indices = [61], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %125 = affine.load %arg1[62] {partition_indices = [62], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %126 = arith.mulf %0, %125 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %126, %arg0[%arg3 * 64 + 62] {partition_indices = [62], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %127 = affine.load %arg1[63] {partition_indices = [63], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %128 = arith.mulf %0, %127 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    affine.store %128, %arg0[%arg3 * 64 + 63] {partition_indices = [63], timing = #hlscpp.t<6 -> 7, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=1, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=13, iterLatency=7, minII=1>, timing = #hlscpp.t<0 -> 21, 21, 21>}
  return {timing = #hlscpp.t<21 -> 21, 0, 0>}
}
