func @matrix_vector_product_with_bias_input_layer(%arg0: memref<64xf64>, %arg1: memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>, %arg2: memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>, %arg3: memref<13xf64, affine_map<(d0) -> (d0 mod 13, d0 floordiv 13)>, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>, llvm.linkage = #llvm.linkage<external>, resource = #hlscpp.r<lut=0, dsp=175, bram=0>, timing = #hlscpp.t<0 -> 97, 97, 97>} {
  %cst = arith.constant {timing = #hlscpp.t<0 -> 0, 0, 0>} 0.000000e+00 : f64
  affine.for %arg4 = 0 to 8 {
    %0 = affine.load %arg1[%arg4 * 104] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %1 = affine.load %arg3[0] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<13xf64, affine_map<(d0) -> (d0 mod 13, d0 floordiv 13)>, 1>
    %2 = arith.mulf %0, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %3 = arith.addf %2, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %4 = affine.load %arg1[%arg4 * 104 + 13] {partition_indices = [13], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %5 = arith.mulf %4, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %6 = arith.addf %5, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %7 = affine.load %arg1[%arg4 * 104 + 26] {partition_indices = [26], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %8 = arith.mulf %7, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %9 = arith.addf %8, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %10 = affine.load %arg1[%arg4 * 104 + 39] {partition_indices = [39], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %11 = arith.mulf %10, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %12 = arith.addf %11, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %13 = affine.load %arg1[%arg4 * 104 + 52] {partition_indices = [52], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %14 = arith.mulf %13, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %15 = arith.addf %14, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %16 = affine.load %arg1[%arg4 * 104 + 65] {partition_indices = [65], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %17 = arith.mulf %16, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %18 = arith.addf %17, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %19 = affine.load %arg1[%arg4 * 104 + 78] {partition_indices = [78], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %20 = arith.mulf %19, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %21 = arith.addf %20, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %22 = affine.load %arg1[%arg4 * 104 + 91] {partition_indices = [91], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %23 = arith.mulf %22, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %24 = arith.addf %23, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %25 = affine.load %arg1[%arg4 * 104 + 1] {partition_indices = [1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %26 = affine.load %arg3[1] {partition_indices = [1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<13xf64, affine_map<(d0) -> (d0 mod 13, d0 floordiv 13)>, 1>
    %27 = arith.mulf %25, %26 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %28 = arith.addf %3, %27 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %29 = affine.load %arg1[%arg4 * 104 + 14] {partition_indices = [14], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %30 = arith.mulf %29, %26 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %31 = arith.addf %6, %30 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %32 = affine.load %arg1[%arg4 * 104 + 27] {partition_indices = [27], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %33 = arith.mulf %32, %26 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %34 = arith.addf %9, %33 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %35 = affine.load %arg1[%arg4 * 104 + 40] {partition_indices = [40], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %36 = arith.mulf %35, %26 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %37 = arith.addf %12, %36 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %38 = affine.load %arg1[%arg4 * 104 + 53] {partition_indices = [53], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %39 = arith.mulf %38, %26 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %40 = arith.addf %15, %39 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %41 = affine.load %arg1[%arg4 * 104 + 66] {partition_indices = [66], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %42 = arith.mulf %41, %26 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %43 = arith.addf %18, %42 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %44 = affine.load %arg1[%arg4 * 104 + 79] {partition_indices = [79], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %45 = arith.mulf %44, %26 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %46 = arith.addf %21, %45 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %47 = affine.load %arg1[%arg4 * 104 + 92] {partition_indices = [92], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %48 = arith.mulf %47, %26 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %49 = arith.addf %24, %48 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %50 = affine.load %arg1[%arg4 * 104 + 2] {partition_indices = [2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %51 = affine.load %arg3[2] {partition_indices = [2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<13xf64, affine_map<(d0) -> (d0 mod 13, d0 floordiv 13)>, 1>
    %52 = arith.mulf %50, %51 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %53 = arith.addf %28, %52 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %54 = affine.load %arg1[%arg4 * 104 + 15] {partition_indices = [15], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %55 = arith.mulf %54, %51 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %56 = arith.addf %31, %55 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %57 = affine.load %arg1[%arg4 * 104 + 28] {partition_indices = [28], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %58 = arith.mulf %57, %51 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %59 = arith.addf %34, %58 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %60 = affine.load %arg1[%arg4 * 104 + 41] {partition_indices = [41], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %61 = arith.mulf %60, %51 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %62 = arith.addf %37, %61 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %63 = affine.load %arg1[%arg4 * 104 + 54] {partition_indices = [54], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %64 = arith.mulf %63, %51 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %65 = arith.addf %40, %64 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %66 = affine.load %arg1[%arg4 * 104 + 67] {partition_indices = [67], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %67 = arith.mulf %66, %51 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %68 = arith.addf %43, %67 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %69 = affine.load %arg1[%arg4 * 104 + 80] {partition_indices = [80], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %70 = arith.mulf %69, %51 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %71 = arith.addf %46, %70 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %72 = affine.load %arg1[%arg4 * 104 + 93] {partition_indices = [93], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %73 = arith.mulf %72, %51 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %74 = arith.addf %49, %73 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %75 = affine.load %arg1[%arg4 * 104 + 3] {partition_indices = [3], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %76 = affine.load %arg3[3] {partition_indices = [3], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<13xf64, affine_map<(d0) -> (d0 mod 13, d0 floordiv 13)>, 1>
    %77 = arith.mulf %75, %76 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f64
    %78 = arith.addf %53, %77 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f64
    %79 = affine.load %arg1[%arg4 * 104 + 16] {partition_indices = [16], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %80 = arith.mulf %79, %76 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f64
    %81 = arith.addf %56, %80 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f64
    %82 = affine.load %arg1[%arg4 * 104 + 29] {partition_indices = [29], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %83 = arith.mulf %82, %76 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f64
    %84 = arith.addf %59, %83 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f64
    %85 = affine.load %arg1[%arg4 * 104 + 42] {partition_indices = [42], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %86 = arith.mulf %85, %76 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f64
    %87 = arith.addf %62, %86 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f64
    %88 = affine.load %arg1[%arg4 * 104 + 55] {partition_indices = [55], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %89 = arith.mulf %88, %76 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f64
    %90 = arith.addf %65, %89 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f64
    %91 = affine.load %arg1[%arg4 * 104 + 68] {partition_indices = [68], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %92 = arith.mulf %91, %76 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f64
    %93 = arith.addf %68, %92 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f64
    %94 = affine.load %arg1[%arg4 * 104 + 81] {partition_indices = [81], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %95 = arith.mulf %94, %76 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f64
    %96 = arith.addf %71, %95 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f64
    %97 = affine.load %arg1[%arg4 * 104 + 94] {partition_indices = [94], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %98 = arith.mulf %97, %76 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f64
    %99 = arith.addf %74, %98 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f64
    %100 = affine.load %arg1[%arg4 * 104 + 4] {partition_indices = [4], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %101 = affine.load %arg3[4] {partition_indices = [4], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<13xf64, affine_map<(d0) -> (d0 mod 13, d0 floordiv 13)>, 1>
    %102 = arith.mulf %100, %101 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f64
    %103 = arith.addf %78, %102 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f64
    %104 = affine.load %arg1[%arg4 * 104 + 17] {partition_indices = [17], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %105 = arith.mulf %104, %101 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f64
    %106 = arith.addf %81, %105 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f64
    %107 = affine.load %arg1[%arg4 * 104 + 30] {partition_indices = [30], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %108 = arith.mulf %107, %101 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f64
    %109 = arith.addf %84, %108 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f64
    %110 = affine.load %arg1[%arg4 * 104 + 43] {partition_indices = [43], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %111 = arith.mulf %110, %101 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f64
    %112 = arith.addf %87, %111 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f64
    %113 = affine.load %arg1[%arg4 * 104 + 56] {partition_indices = [56], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %114 = arith.mulf %113, %101 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f64
    %115 = arith.addf %90, %114 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f64
    %116 = affine.load %arg1[%arg4 * 104 + 69] {partition_indices = [69], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %117 = arith.mulf %116, %101 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f64
    %118 = arith.addf %93, %117 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f64
    %119 = affine.load %arg1[%arg4 * 104 + 82] {partition_indices = [82], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %120 = arith.mulf %119, %101 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f64
    %121 = arith.addf %96, %120 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f64
    %122 = affine.load %arg1[%arg4 * 104 + 95] {partition_indices = [95], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %123 = arith.mulf %122, %101 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f64
    %124 = arith.addf %99, %123 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f64
    %125 = affine.load %arg1[%arg4 * 104 + 5] {partition_indices = [5], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %126 = affine.load %arg3[5] {partition_indices = [5], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<13xf64, affine_map<(d0) -> (d0 mod 13, d0 floordiv 13)>, 1>
    %127 = arith.mulf %125, %126 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f64
    %128 = arith.addf %103, %127 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f64
    %129 = affine.load %arg1[%arg4 * 104 + 18] {partition_indices = [18], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %130 = arith.mulf %129, %126 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f64
    %131 = arith.addf %106, %130 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f64
    %132 = affine.load %arg1[%arg4 * 104 + 31] {partition_indices = [31], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %133 = arith.mulf %132, %126 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f64
    %134 = arith.addf %109, %133 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f64
    %135 = affine.load %arg1[%arg4 * 104 + 44] {partition_indices = [44], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %136 = arith.mulf %135, %126 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f64
    %137 = arith.addf %112, %136 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f64
    %138 = affine.load %arg1[%arg4 * 104 + 57] {partition_indices = [57], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %139 = arith.mulf %138, %126 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f64
    %140 = arith.addf %115, %139 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f64
    %141 = affine.load %arg1[%arg4 * 104 + 70] {partition_indices = [70], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %142 = arith.mulf %141, %126 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f64
    %143 = arith.addf %118, %142 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f64
    %144 = affine.load %arg1[%arg4 * 104 + 83] {partition_indices = [83], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %145 = arith.mulf %144, %126 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f64
    %146 = arith.addf %121, %145 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f64
    %147 = affine.load %arg1[%arg4 * 104 + 96] {partition_indices = [96], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %148 = arith.mulf %147, %126 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f64
    %149 = arith.addf %124, %148 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f64
    %150 = affine.load %arg1[%arg4 * 104 + 6] {partition_indices = [6], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %151 = affine.load %arg3[6] {partition_indices = [6], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<13xf64, affine_map<(d0) -> (d0 mod 13, d0 floordiv 13)>, 1>
    %152 = arith.mulf %150, %151 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f64
    %153 = arith.addf %128, %152 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f64
    %154 = affine.load %arg1[%arg4 * 104 + 19] {partition_indices = [19], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %155 = arith.mulf %154, %151 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f64
    %156 = arith.addf %131, %155 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f64
    %157 = affine.load %arg1[%arg4 * 104 + 32] {partition_indices = [32], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %158 = arith.mulf %157, %151 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f64
    %159 = arith.addf %134, %158 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f64
    %160 = affine.load %arg1[%arg4 * 104 + 45] {partition_indices = [45], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %161 = arith.mulf %160, %151 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f64
    %162 = arith.addf %137, %161 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f64
    %163 = affine.load %arg1[%arg4 * 104 + 58] {partition_indices = [58], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %164 = arith.mulf %163, %151 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f64
    %165 = arith.addf %140, %164 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f64
    %166 = affine.load %arg1[%arg4 * 104 + 71] {partition_indices = [71], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %167 = arith.mulf %166, %151 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f64
    %168 = arith.addf %143, %167 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f64
    %169 = affine.load %arg1[%arg4 * 104 + 84] {partition_indices = [84], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %170 = arith.mulf %169, %151 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f64
    %171 = arith.addf %146, %170 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f64
    %172 = affine.load %arg1[%arg4 * 104 + 97] {partition_indices = [97], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %173 = arith.mulf %172, %151 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f64
    %174 = arith.addf %149, %173 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f64
    %175 = affine.load %arg1[%arg4 * 104 + 7] {partition_indices = [7], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %176 = affine.load %arg3[7] {partition_indices = [7], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<13xf64, affine_map<(d0) -> (d0 mod 13, d0 floordiv 13)>, 1>
    %177 = arith.mulf %175, %176 {timing = #hlscpp.t<37 -> 41, 4, 1>} : f64
    %178 = arith.addf %153, %177 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f64
    %179 = affine.load %arg1[%arg4 * 104 + 20] {partition_indices = [20], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %180 = arith.mulf %179, %176 {timing = #hlscpp.t<37 -> 41, 4, 1>} : f64
    %181 = arith.addf %156, %180 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f64
    %182 = affine.load %arg1[%arg4 * 104 + 33] {partition_indices = [33], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %183 = arith.mulf %182, %176 {timing = #hlscpp.t<37 -> 41, 4, 1>} : f64
    %184 = arith.addf %159, %183 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f64
    %185 = affine.load %arg1[%arg4 * 104 + 46] {partition_indices = [46], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %186 = arith.mulf %185, %176 {timing = #hlscpp.t<37 -> 41, 4, 1>} : f64
    %187 = arith.addf %162, %186 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f64
    %188 = affine.load %arg1[%arg4 * 104 + 59] {partition_indices = [59], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %189 = arith.mulf %188, %176 {timing = #hlscpp.t<37 -> 41, 4, 1>} : f64
    %190 = arith.addf %165, %189 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f64
    %191 = affine.load %arg1[%arg4 * 104 + 72] {partition_indices = [72], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %192 = arith.mulf %191, %176 {timing = #hlscpp.t<37 -> 41, 4, 1>} : f64
    %193 = arith.addf %168, %192 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f64
    %194 = affine.load %arg1[%arg4 * 104 + 85] {partition_indices = [85], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %195 = arith.mulf %194, %176 {timing = #hlscpp.t<37 -> 41, 4, 1>} : f64
    %196 = arith.addf %171, %195 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f64
    %197 = affine.load %arg1[%arg4 * 104 + 98] {partition_indices = [98], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %198 = arith.mulf %197, %176 {timing = #hlscpp.t<37 -> 41, 4, 1>} : f64
    %199 = arith.addf %174, %198 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f64
    %200 = affine.load %arg1[%arg4 * 104 + 8] {partition_indices = [8], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %201 = affine.load %arg3[8] {partition_indices = [8], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<13xf64, affine_map<(d0) -> (d0 mod 13, d0 floordiv 13)>, 1>
    %202 = arith.mulf %200, %201 {timing = #hlscpp.t<42 -> 46, 4, 1>} : f64
    %203 = arith.addf %178, %202 {timing = #hlscpp.t<46 -> 51, 5, 1>} : f64
    %204 = affine.load %arg1[%arg4 * 104 + 21] {partition_indices = [21], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %205 = arith.mulf %204, %201 {timing = #hlscpp.t<42 -> 46, 4, 1>} : f64
    %206 = arith.addf %181, %205 {timing = #hlscpp.t<46 -> 51, 5, 1>} : f64
    %207 = affine.load %arg1[%arg4 * 104 + 34] {partition_indices = [34], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %208 = arith.mulf %207, %201 {timing = #hlscpp.t<42 -> 46, 4, 1>} : f64
    %209 = arith.addf %184, %208 {timing = #hlscpp.t<46 -> 51, 5, 1>} : f64
    %210 = affine.load %arg1[%arg4 * 104 + 47] {partition_indices = [47], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %211 = arith.mulf %210, %201 {timing = #hlscpp.t<42 -> 46, 4, 1>} : f64
    %212 = arith.addf %187, %211 {timing = #hlscpp.t<46 -> 51, 5, 1>} : f64
    %213 = affine.load %arg1[%arg4 * 104 + 60] {partition_indices = [60], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %214 = arith.mulf %213, %201 {timing = #hlscpp.t<42 -> 46, 4, 1>} : f64
    %215 = arith.addf %190, %214 {timing = #hlscpp.t<46 -> 51, 5, 1>} : f64
    %216 = affine.load %arg1[%arg4 * 104 + 73] {partition_indices = [73], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %217 = arith.mulf %216, %201 {timing = #hlscpp.t<42 -> 46, 4, 1>} : f64
    %218 = arith.addf %193, %217 {timing = #hlscpp.t<46 -> 51, 5, 1>} : f64
    %219 = affine.load %arg1[%arg4 * 104 + 86] {partition_indices = [86], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %220 = arith.mulf %219, %201 {timing = #hlscpp.t<42 -> 46, 4, 1>} : f64
    %221 = arith.addf %196, %220 {timing = #hlscpp.t<46 -> 51, 5, 1>} : f64
    %222 = affine.load %arg1[%arg4 * 104 + 99] {partition_indices = [99], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %223 = arith.mulf %222, %201 {timing = #hlscpp.t<42 -> 46, 4, 1>} : f64
    %224 = arith.addf %199, %223 {timing = #hlscpp.t<46 -> 51, 5, 1>} : f64
    %225 = affine.load %arg1[%arg4 * 104 + 9] {partition_indices = [9], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %226 = affine.load %arg3[9] {partition_indices = [9], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<13xf64, affine_map<(d0) -> (d0 mod 13, d0 floordiv 13)>, 1>
    %227 = arith.mulf %225, %226 {timing = #hlscpp.t<47 -> 51, 4, 1>} : f64
    %228 = arith.addf %203, %227 {timing = #hlscpp.t<51 -> 56, 5, 1>} : f64
    %229 = affine.load %arg1[%arg4 * 104 + 22] {partition_indices = [22], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %230 = arith.mulf %229, %226 {timing = #hlscpp.t<47 -> 51, 4, 1>} : f64
    %231 = arith.addf %206, %230 {timing = #hlscpp.t<51 -> 56, 5, 1>} : f64
    %232 = affine.load %arg1[%arg4 * 104 + 35] {partition_indices = [35], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %233 = arith.mulf %232, %226 {timing = #hlscpp.t<47 -> 51, 4, 1>} : f64
    %234 = arith.addf %209, %233 {timing = #hlscpp.t<51 -> 56, 5, 1>} : f64
    %235 = affine.load %arg1[%arg4 * 104 + 48] {partition_indices = [48], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %236 = arith.mulf %235, %226 {timing = #hlscpp.t<47 -> 51, 4, 1>} : f64
    %237 = arith.addf %212, %236 {timing = #hlscpp.t<51 -> 56, 5, 1>} : f64
    %238 = affine.load %arg1[%arg4 * 104 + 61] {partition_indices = [61], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %239 = arith.mulf %238, %226 {timing = #hlscpp.t<47 -> 51, 4, 1>} : f64
    %240 = arith.addf %215, %239 {timing = #hlscpp.t<51 -> 56, 5, 1>} : f64
    %241 = affine.load %arg1[%arg4 * 104 + 74] {partition_indices = [74], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %242 = arith.mulf %241, %226 {timing = #hlscpp.t<47 -> 51, 4, 1>} : f64
    %243 = arith.addf %218, %242 {timing = #hlscpp.t<51 -> 56, 5, 1>} : f64
    %244 = affine.load %arg1[%arg4 * 104 + 87] {partition_indices = [87], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %245 = arith.mulf %244, %226 {timing = #hlscpp.t<47 -> 51, 4, 1>} : f64
    %246 = arith.addf %221, %245 {timing = #hlscpp.t<51 -> 56, 5, 1>} : f64
    %247 = affine.load %arg1[%arg4 * 104 + 100] {partition_indices = [100], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %248 = arith.mulf %247, %226 {timing = #hlscpp.t<47 -> 51, 4, 1>} : f64
    %249 = arith.addf %224, %248 {timing = #hlscpp.t<51 -> 56, 5, 1>} : f64
    %250 = affine.load %arg1[%arg4 * 104 + 10] {partition_indices = [10], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %251 = affine.load %arg3[10] {partition_indices = [10], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<13xf64, affine_map<(d0) -> (d0 mod 13, d0 floordiv 13)>, 1>
    %252 = arith.mulf %250, %251 {timing = #hlscpp.t<52 -> 56, 4, 1>} : f64
    %253 = arith.addf %228, %252 {timing = #hlscpp.t<56 -> 61, 5, 1>} : f64
    %254 = affine.load %arg1[%arg4 * 104 + 23] {partition_indices = [23], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %255 = arith.mulf %254, %251 {timing = #hlscpp.t<52 -> 56, 4, 1>} : f64
    %256 = arith.addf %231, %255 {timing = #hlscpp.t<56 -> 61, 5, 1>} : f64
    %257 = affine.load %arg1[%arg4 * 104 + 36] {partition_indices = [36], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %258 = arith.mulf %257, %251 {timing = #hlscpp.t<52 -> 56, 4, 1>} : f64
    %259 = arith.addf %234, %258 {timing = #hlscpp.t<56 -> 61, 5, 1>} : f64
    %260 = affine.load %arg1[%arg4 * 104 + 49] {partition_indices = [49], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %261 = arith.mulf %260, %251 {timing = #hlscpp.t<52 -> 56, 4, 1>} : f64
    %262 = arith.addf %237, %261 {timing = #hlscpp.t<56 -> 61, 5, 1>} : f64
    %263 = affine.load %arg1[%arg4 * 104 + 62] {partition_indices = [62], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %264 = arith.mulf %263, %251 {timing = #hlscpp.t<52 -> 56, 4, 1>} : f64
    %265 = arith.addf %240, %264 {timing = #hlscpp.t<56 -> 61, 5, 1>} : f64
    %266 = affine.load %arg1[%arg4 * 104 + 75] {partition_indices = [75], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %267 = arith.mulf %266, %251 {timing = #hlscpp.t<52 -> 56, 4, 1>} : f64
    %268 = arith.addf %243, %267 {timing = #hlscpp.t<56 -> 61, 5, 1>} : f64
    %269 = affine.load %arg1[%arg4 * 104 + 88] {partition_indices = [88], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %270 = arith.mulf %269, %251 {timing = #hlscpp.t<52 -> 56, 4, 1>} : f64
    %271 = arith.addf %246, %270 {timing = #hlscpp.t<56 -> 61, 5, 1>} : f64
    %272 = affine.load %arg1[%arg4 * 104 + 101] {partition_indices = [101], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %273 = arith.mulf %272, %251 {timing = #hlscpp.t<52 -> 56, 4, 1>} : f64
    %274 = arith.addf %249, %273 {timing = #hlscpp.t<56 -> 61, 5, 1>} : f64
    %275 = affine.load %arg1[%arg4 * 104 + 11] {partition_indices = [11], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %276 = affine.load %arg3[11] {partition_indices = [11], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<13xf64, affine_map<(d0) -> (d0 mod 13, d0 floordiv 13)>, 1>
    %277 = arith.mulf %275, %276 {timing = #hlscpp.t<57 -> 61, 4, 1>} : f64
    %278 = arith.addf %253, %277 {timing = #hlscpp.t<61 -> 66, 5, 1>} : f64
    %279 = affine.load %arg1[%arg4 * 104 + 24] {partition_indices = [24], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %280 = arith.mulf %279, %276 {timing = #hlscpp.t<57 -> 61, 4, 1>} : f64
    %281 = arith.addf %256, %280 {timing = #hlscpp.t<61 -> 66, 5, 1>} : f64
    %282 = affine.load %arg1[%arg4 * 104 + 37] {partition_indices = [37], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %283 = arith.mulf %282, %276 {timing = #hlscpp.t<57 -> 61, 4, 1>} : f64
    %284 = arith.addf %259, %283 {timing = #hlscpp.t<61 -> 66, 5, 1>} : f64
    %285 = affine.load %arg1[%arg4 * 104 + 50] {partition_indices = [50], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %286 = arith.mulf %285, %276 {timing = #hlscpp.t<57 -> 61, 4, 1>} : f64
    %287 = arith.addf %262, %286 {timing = #hlscpp.t<61 -> 66, 5, 1>} : f64
    %288 = affine.load %arg1[%arg4 * 104 + 63] {partition_indices = [63], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %289 = arith.mulf %288, %276 {timing = #hlscpp.t<57 -> 61, 4, 1>} : f64
    %290 = arith.addf %265, %289 {timing = #hlscpp.t<61 -> 66, 5, 1>} : f64
    %291 = affine.load %arg1[%arg4 * 104 + 76] {partition_indices = [76], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %292 = arith.mulf %291, %276 {timing = #hlscpp.t<57 -> 61, 4, 1>} : f64
    %293 = arith.addf %268, %292 {timing = #hlscpp.t<61 -> 66, 5, 1>} : f64
    %294 = affine.load %arg1[%arg4 * 104 + 89] {partition_indices = [89], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %295 = arith.mulf %294, %276 {timing = #hlscpp.t<57 -> 61, 4, 1>} : f64
    %296 = arith.addf %271, %295 {timing = #hlscpp.t<61 -> 66, 5, 1>} : f64
    %297 = affine.load %arg1[%arg4 * 104 + 102] {partition_indices = [102], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %298 = arith.mulf %297, %276 {timing = #hlscpp.t<57 -> 61, 4, 1>} : f64
    %299 = arith.addf %274, %298 {timing = #hlscpp.t<61 -> 66, 5, 1>} : f64
    %300 = affine.load %arg1[%arg4 * 104 + 12] {partition_indices = [12], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %301 = affine.load %arg3[12] {partition_indices = [12], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<13xf64, affine_map<(d0) -> (d0 mod 13, d0 floordiv 13)>, 1>
    %302 = arith.mulf %300, %301 {timing = #hlscpp.t<62 -> 66, 4, 1>} : f64
    %303 = arith.addf %278, %302 {timing = #hlscpp.t<66 -> 71, 5, 1>} : f64
    affine.store %303, %arg2[%arg4 * 8] {partition_indices = [0], timing = #hlscpp.t<71 -> 72, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %304 = affine.load %arg1[%arg4 * 104 + 25] {partition_indices = [25], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %305 = arith.mulf %304, %301 {timing = #hlscpp.t<62 -> 66, 4, 1>} : f64
    %306 = arith.addf %281, %305 {timing = #hlscpp.t<66 -> 71, 5, 1>} : f64
    affine.store %306, %arg2[%arg4 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<71 -> 72, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %307 = affine.load %arg1[%arg4 * 104 + 38] {partition_indices = [38], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %308 = arith.mulf %307, %301 {timing = #hlscpp.t<62 -> 66, 4, 1>} : f64
    %309 = arith.addf %284, %308 {timing = #hlscpp.t<66 -> 71, 5, 1>} : f64
    affine.store %309, %arg2[%arg4 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<71 -> 72, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %310 = affine.load %arg1[%arg4 * 104 + 51] {partition_indices = [51], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %311 = arith.mulf %310, %301 {timing = #hlscpp.t<62 -> 66, 4, 1>} : f64
    %312 = arith.addf %287, %311 {timing = #hlscpp.t<66 -> 71, 5, 1>} : f64
    affine.store %312, %arg2[%arg4 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<71 -> 72, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %313 = affine.load %arg1[%arg4 * 104 + 64] {partition_indices = [64], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %314 = arith.mulf %313, %301 {timing = #hlscpp.t<62 -> 66, 4, 1>} : f64
    %315 = arith.addf %290, %314 {timing = #hlscpp.t<66 -> 71, 5, 1>} : f64
    affine.store %315, %arg2[%arg4 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<71 -> 72, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %316 = affine.load %arg1[%arg4 * 104 + 77] {partition_indices = [77], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %317 = arith.mulf %316, %301 {timing = #hlscpp.t<62 -> 66, 4, 1>} : f64
    %318 = arith.addf %293, %317 {timing = #hlscpp.t<66 -> 71, 5, 1>} : f64
    affine.store %318, %arg2[%arg4 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<71 -> 72, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %319 = affine.load %arg1[%arg4 * 104 + 90] {partition_indices = [90], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %320 = arith.mulf %319, %301 {timing = #hlscpp.t<62 -> 66, 4, 1>} : f64
    %321 = arith.addf %296, %320 {timing = #hlscpp.t<66 -> 71, 5, 1>} : f64
    affine.store %321, %arg2[%arg4 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<71 -> 72, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %322 = affine.load %arg1[%arg4 * 104 + 103] {partition_indices = [103], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 104, d0 floordiv 104)>, 1>
    %323 = arith.mulf %322, %301 {timing = #hlscpp.t<62 -> 66, 4, 1>} : f64
    %324 = arith.addf %299, %323 {timing = #hlscpp.t<66 -> 71, 5, 1>} : f64
    affine.store %324, %arg2[%arg4 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<71 -> 72, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=3, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=8, iterLatency=72, minII=3>, timing = #hlscpp.t<0 -> 95, 95, 95>}
  return {timing = #hlscpp.t<95 -> 95, 0, 0>}
}
