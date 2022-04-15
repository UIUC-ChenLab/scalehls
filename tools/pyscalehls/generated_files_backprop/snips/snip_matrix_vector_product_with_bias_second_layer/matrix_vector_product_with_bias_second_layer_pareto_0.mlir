func @matrix_vector_product_with_bias_second_layer(%arg0: memref<64xf64>, %arg1: memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>, %arg2: memref<64xf64, affine_map<(d0) -> (d0 mod 4, d0 floordiv 4)>, 1>, %arg3: memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>, %arg4: memref<1xf64, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>, llvm.linkage = #llvm.linkage<external>, resource = #hlscpp.r<lut=0, dsp=320, bram=0>, timing = #hlscpp.t<0 -> 392, 392, 392>} {
  %cst = arith.constant {timing = #hlscpp.t<389 -> 389, 0, 0>} 42.424242419999999 : f64
  %cst_0 = arith.constant {timing = #hlscpp.t<0 -> 0, 0, 0>} 0.000000e+00 : f64
  affine.for %arg5 = 0 to 16 {
    %0 = affine.load %arg1[%arg5 * 256] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %1 = affine.load %arg3[0] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %2 = arith.mulf %0, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %3 = arith.addf %2, %cst_0 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %4 = affine.load %arg1[%arg5 * 256 + 64] {partition_indices = [64], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %5 = arith.mulf %4, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %6 = arith.addf %5, %cst_0 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %7 = affine.load %arg1[%arg5 * 256 + 128] {partition_indices = [128], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %8 = arith.mulf %7, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %9 = arith.addf %8, %cst_0 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %10 = affine.load %arg1[%arg5 * 256 + 192] {partition_indices = [192], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %11 = arith.mulf %10, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %12 = arith.addf %11, %cst_0 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %13 = affine.load %arg1[%arg5 * 256 + 1] {partition_indices = [1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %14 = affine.load %arg3[1] {partition_indices = [1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %15 = arith.mulf %13, %14 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %16 = arith.addf %3, %15 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %17 = affine.load %arg1[%arg5 * 256 + 65] {partition_indices = [65], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %18 = arith.mulf %17, %14 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %19 = arith.addf %6, %18 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %20 = affine.load %arg1[%arg5 * 256 + 129] {partition_indices = [129], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %21 = arith.mulf %20, %14 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %22 = arith.addf %9, %21 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %23 = affine.load %arg1[%arg5 * 256 + 193] {partition_indices = [193], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %24 = arith.mulf %23, %14 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %25 = arith.addf %12, %24 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %26 = affine.load %arg1[%arg5 * 256 + 2] {partition_indices = [2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %27 = affine.load %arg3[2] {partition_indices = [2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %28 = arith.mulf %26, %27 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %29 = arith.addf %16, %28 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %30 = affine.load %arg1[%arg5 * 256 + 66] {partition_indices = [66], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %31 = arith.mulf %30, %27 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %32 = arith.addf %19, %31 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %33 = affine.load %arg1[%arg5 * 256 + 130] {partition_indices = [130], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %34 = arith.mulf %33, %27 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %35 = arith.addf %22, %34 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %36 = affine.load %arg1[%arg5 * 256 + 194] {partition_indices = [194], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %37 = arith.mulf %36, %27 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %38 = arith.addf %25, %37 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %39 = affine.load %arg1[%arg5 * 256 + 3] {partition_indices = [3], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %40 = affine.load %arg3[3] {partition_indices = [3], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %41 = arith.mulf %39, %40 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f64
    %42 = arith.addf %29, %41 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f64
    %43 = affine.load %arg1[%arg5 * 256 + 67] {partition_indices = [67], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %44 = arith.mulf %43, %40 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f64
    %45 = arith.addf %32, %44 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f64
    %46 = affine.load %arg1[%arg5 * 256 + 131] {partition_indices = [131], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %47 = arith.mulf %46, %40 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f64
    %48 = arith.addf %35, %47 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f64
    %49 = affine.load %arg1[%arg5 * 256 + 195] {partition_indices = [195], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %50 = arith.mulf %49, %40 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f64
    %51 = arith.addf %38, %50 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f64
    %52 = affine.load %arg1[%arg5 * 256 + 4] {partition_indices = [4], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %53 = affine.load %arg3[4] {partition_indices = [4], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %54 = arith.mulf %52, %53 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f64
    %55 = arith.addf %42, %54 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f64
    %56 = affine.load %arg1[%arg5 * 256 + 68] {partition_indices = [68], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %57 = arith.mulf %56, %53 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f64
    %58 = arith.addf %45, %57 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f64
    %59 = affine.load %arg1[%arg5 * 256 + 132] {partition_indices = [132], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %60 = arith.mulf %59, %53 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f64
    %61 = arith.addf %48, %60 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f64
    %62 = affine.load %arg1[%arg5 * 256 + 196] {partition_indices = [196], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %63 = arith.mulf %62, %53 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f64
    %64 = arith.addf %51, %63 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f64
    %65 = affine.load %arg1[%arg5 * 256 + 5] {partition_indices = [5], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %66 = affine.load %arg3[5] {partition_indices = [5], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %67 = arith.mulf %65, %66 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f64
    %68 = arith.addf %55, %67 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f64
    %69 = affine.load %arg1[%arg5 * 256 + 69] {partition_indices = [69], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %70 = arith.mulf %69, %66 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f64
    %71 = arith.addf %58, %70 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f64
    %72 = affine.load %arg1[%arg5 * 256 + 133] {partition_indices = [133], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %73 = arith.mulf %72, %66 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f64
    %74 = arith.addf %61, %73 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f64
    %75 = affine.load %arg1[%arg5 * 256 + 197] {partition_indices = [197], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %76 = arith.mulf %75, %66 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f64
    %77 = arith.addf %64, %76 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f64
    %78 = affine.load %arg1[%arg5 * 256 + 6] {partition_indices = [6], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %79 = affine.load %arg3[6] {partition_indices = [6], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %80 = arith.mulf %78, %79 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f64
    %81 = arith.addf %68, %80 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f64
    %82 = affine.load %arg1[%arg5 * 256 + 70] {partition_indices = [70], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %83 = arith.mulf %82, %79 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f64
    %84 = arith.addf %71, %83 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f64
    %85 = affine.load %arg1[%arg5 * 256 + 134] {partition_indices = [134], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %86 = arith.mulf %85, %79 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f64
    %87 = arith.addf %74, %86 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f64
    %88 = affine.load %arg1[%arg5 * 256 + 198] {partition_indices = [198], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %89 = arith.mulf %88, %79 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f64
    %90 = arith.addf %77, %89 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f64
    %91 = affine.load %arg1[%arg5 * 256 + 7] {partition_indices = [7], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %92 = affine.load %arg3[7] {partition_indices = [7], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %93 = arith.mulf %91, %92 {timing = #hlscpp.t<37 -> 41, 4, 1>} : f64
    %94 = arith.addf %81, %93 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f64
    %95 = affine.load %arg1[%arg5 * 256 + 71] {partition_indices = [71], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %96 = arith.mulf %95, %92 {timing = #hlscpp.t<37 -> 41, 4, 1>} : f64
    %97 = arith.addf %84, %96 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f64
    %98 = affine.load %arg1[%arg5 * 256 + 135] {partition_indices = [135], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %99 = arith.mulf %98, %92 {timing = #hlscpp.t<37 -> 41, 4, 1>} : f64
    %100 = arith.addf %87, %99 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f64
    %101 = affine.load %arg1[%arg5 * 256 + 199] {partition_indices = [199], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %102 = arith.mulf %101, %92 {timing = #hlscpp.t<37 -> 41, 4, 1>} : f64
    %103 = arith.addf %90, %102 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f64
    %104 = affine.load %arg1[%arg5 * 256 + 8] {partition_indices = [8], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %105 = affine.load %arg3[8] {partition_indices = [8], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %106 = arith.mulf %104, %105 {timing = #hlscpp.t<42 -> 46, 4, 1>} : f64
    %107 = arith.addf %94, %106 {timing = #hlscpp.t<46 -> 51, 5, 1>} : f64
    %108 = affine.load %arg1[%arg5 * 256 + 72] {partition_indices = [72], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %109 = arith.mulf %108, %105 {timing = #hlscpp.t<42 -> 46, 4, 1>} : f64
    %110 = arith.addf %97, %109 {timing = #hlscpp.t<46 -> 51, 5, 1>} : f64
    %111 = affine.load %arg1[%arg5 * 256 + 136] {partition_indices = [136], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %112 = arith.mulf %111, %105 {timing = #hlscpp.t<42 -> 46, 4, 1>} : f64
    %113 = arith.addf %100, %112 {timing = #hlscpp.t<46 -> 51, 5, 1>} : f64
    %114 = affine.load %arg1[%arg5 * 256 + 200] {partition_indices = [200], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %115 = arith.mulf %114, %105 {timing = #hlscpp.t<42 -> 46, 4, 1>} : f64
    %116 = arith.addf %103, %115 {timing = #hlscpp.t<46 -> 51, 5, 1>} : f64
    %117 = affine.load %arg1[%arg5 * 256 + 9] {partition_indices = [9], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %118 = affine.load %arg3[9] {partition_indices = [9], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %119 = arith.mulf %117, %118 {timing = #hlscpp.t<47 -> 51, 4, 1>} : f64
    %120 = arith.addf %107, %119 {timing = #hlscpp.t<51 -> 56, 5, 1>} : f64
    %121 = affine.load %arg1[%arg5 * 256 + 73] {partition_indices = [73], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %122 = arith.mulf %121, %118 {timing = #hlscpp.t<47 -> 51, 4, 1>} : f64
    %123 = arith.addf %110, %122 {timing = #hlscpp.t<51 -> 56, 5, 1>} : f64
    %124 = affine.load %arg1[%arg5 * 256 + 137] {partition_indices = [137], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %125 = arith.mulf %124, %118 {timing = #hlscpp.t<47 -> 51, 4, 1>} : f64
    %126 = arith.addf %113, %125 {timing = #hlscpp.t<51 -> 56, 5, 1>} : f64
    %127 = affine.load %arg1[%arg5 * 256 + 201] {partition_indices = [201], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %128 = arith.mulf %127, %118 {timing = #hlscpp.t<47 -> 51, 4, 1>} : f64
    %129 = arith.addf %116, %128 {timing = #hlscpp.t<51 -> 56, 5, 1>} : f64
    %130 = affine.load %arg1[%arg5 * 256 + 10] {partition_indices = [10], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %131 = affine.load %arg3[10] {partition_indices = [10], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %132 = arith.mulf %130, %131 {timing = #hlscpp.t<52 -> 56, 4, 1>} : f64
    %133 = arith.addf %120, %132 {timing = #hlscpp.t<56 -> 61, 5, 1>} : f64
    %134 = affine.load %arg1[%arg5 * 256 + 74] {partition_indices = [74], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %135 = arith.mulf %134, %131 {timing = #hlscpp.t<52 -> 56, 4, 1>} : f64
    %136 = arith.addf %123, %135 {timing = #hlscpp.t<56 -> 61, 5, 1>} : f64
    %137 = affine.load %arg1[%arg5 * 256 + 138] {partition_indices = [138], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %138 = arith.mulf %137, %131 {timing = #hlscpp.t<52 -> 56, 4, 1>} : f64
    %139 = arith.addf %126, %138 {timing = #hlscpp.t<56 -> 61, 5, 1>} : f64
    %140 = affine.load %arg1[%arg5 * 256 + 202] {partition_indices = [202], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %141 = arith.mulf %140, %131 {timing = #hlscpp.t<52 -> 56, 4, 1>} : f64
    %142 = arith.addf %129, %141 {timing = #hlscpp.t<56 -> 61, 5, 1>} : f64
    %143 = affine.load %arg1[%arg5 * 256 + 11] {partition_indices = [11], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %144 = affine.load %arg3[11] {partition_indices = [11], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %145 = arith.mulf %143, %144 {timing = #hlscpp.t<57 -> 61, 4, 1>} : f64
    %146 = arith.addf %133, %145 {timing = #hlscpp.t<61 -> 66, 5, 1>} : f64
    %147 = affine.load %arg1[%arg5 * 256 + 75] {partition_indices = [75], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %148 = arith.mulf %147, %144 {timing = #hlscpp.t<57 -> 61, 4, 1>} : f64
    %149 = arith.addf %136, %148 {timing = #hlscpp.t<61 -> 66, 5, 1>} : f64
    %150 = affine.load %arg1[%arg5 * 256 + 139] {partition_indices = [139], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %151 = arith.mulf %150, %144 {timing = #hlscpp.t<57 -> 61, 4, 1>} : f64
    %152 = arith.addf %139, %151 {timing = #hlscpp.t<61 -> 66, 5, 1>} : f64
    %153 = affine.load %arg1[%arg5 * 256 + 203] {partition_indices = [203], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %154 = arith.mulf %153, %144 {timing = #hlscpp.t<57 -> 61, 4, 1>} : f64
    %155 = arith.addf %142, %154 {timing = #hlscpp.t<61 -> 66, 5, 1>} : f64
    %156 = affine.load %arg1[%arg5 * 256 + 12] {partition_indices = [12], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %157 = affine.load %arg3[12] {partition_indices = [12], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %158 = arith.mulf %156, %157 {timing = #hlscpp.t<62 -> 66, 4, 1>} : f64
    %159 = arith.addf %146, %158 {timing = #hlscpp.t<66 -> 71, 5, 1>} : f64
    %160 = affine.load %arg1[%arg5 * 256 + 76] {partition_indices = [76], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %161 = arith.mulf %160, %157 {timing = #hlscpp.t<62 -> 66, 4, 1>} : f64
    %162 = arith.addf %149, %161 {timing = #hlscpp.t<66 -> 71, 5, 1>} : f64
    %163 = affine.load %arg1[%arg5 * 256 + 140] {partition_indices = [140], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %164 = arith.mulf %163, %157 {timing = #hlscpp.t<62 -> 66, 4, 1>} : f64
    %165 = arith.addf %152, %164 {timing = #hlscpp.t<66 -> 71, 5, 1>} : f64
    %166 = affine.load %arg1[%arg5 * 256 + 204] {partition_indices = [204], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %167 = arith.mulf %166, %157 {timing = #hlscpp.t<62 -> 66, 4, 1>} : f64
    %168 = arith.addf %155, %167 {timing = #hlscpp.t<66 -> 71, 5, 1>} : f64
    %169 = affine.load %arg1[%arg5 * 256 + 13] {partition_indices = [13], timing = #hlscpp.t<65 -> 67, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %170 = affine.load %arg3[13] {partition_indices = [13], timing = #hlscpp.t<65 -> 67, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %171 = arith.mulf %169, %170 {timing = #hlscpp.t<67 -> 71, 4, 1>} : f64
    %172 = arith.addf %159, %171 {timing = #hlscpp.t<71 -> 76, 5, 1>} : f64
    %173 = affine.load %arg1[%arg5 * 256 + 77] {partition_indices = [77], timing = #hlscpp.t<65 -> 67, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %174 = arith.mulf %173, %170 {timing = #hlscpp.t<67 -> 71, 4, 1>} : f64
    %175 = arith.addf %162, %174 {timing = #hlscpp.t<71 -> 76, 5, 1>} : f64
    %176 = affine.load %arg1[%arg5 * 256 + 141] {partition_indices = [141], timing = #hlscpp.t<65 -> 67, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %177 = arith.mulf %176, %170 {timing = #hlscpp.t<67 -> 71, 4, 1>} : f64
    %178 = arith.addf %165, %177 {timing = #hlscpp.t<71 -> 76, 5, 1>} : f64
    %179 = affine.load %arg1[%arg5 * 256 + 205] {partition_indices = [205], timing = #hlscpp.t<65 -> 67, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %180 = arith.mulf %179, %170 {timing = #hlscpp.t<67 -> 71, 4, 1>} : f64
    %181 = arith.addf %168, %180 {timing = #hlscpp.t<71 -> 76, 5, 1>} : f64
    %182 = affine.load %arg1[%arg5 * 256 + 14] {partition_indices = [14], timing = #hlscpp.t<70 -> 72, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %183 = affine.load %arg3[14] {partition_indices = [14], timing = #hlscpp.t<70 -> 72, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %184 = arith.mulf %182, %183 {timing = #hlscpp.t<72 -> 76, 4, 1>} : f64
    %185 = arith.addf %172, %184 {timing = #hlscpp.t<76 -> 81, 5, 1>} : f64
    %186 = affine.load %arg1[%arg5 * 256 + 78] {partition_indices = [78], timing = #hlscpp.t<70 -> 72, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %187 = arith.mulf %186, %183 {timing = #hlscpp.t<72 -> 76, 4, 1>} : f64
    %188 = arith.addf %175, %187 {timing = #hlscpp.t<76 -> 81, 5, 1>} : f64
    %189 = affine.load %arg1[%arg5 * 256 + 142] {partition_indices = [142], timing = #hlscpp.t<70 -> 72, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %190 = arith.mulf %189, %183 {timing = #hlscpp.t<72 -> 76, 4, 1>} : f64
    %191 = arith.addf %178, %190 {timing = #hlscpp.t<76 -> 81, 5, 1>} : f64
    %192 = affine.load %arg1[%arg5 * 256 + 206] {partition_indices = [206], timing = #hlscpp.t<70 -> 72, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %193 = arith.mulf %192, %183 {timing = #hlscpp.t<72 -> 76, 4, 1>} : f64
    %194 = arith.addf %181, %193 {timing = #hlscpp.t<76 -> 81, 5, 1>} : f64
    %195 = affine.load %arg1[%arg5 * 256 + 15] {partition_indices = [15], timing = #hlscpp.t<75 -> 77, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %196 = affine.load %arg3[15] {partition_indices = [15], timing = #hlscpp.t<75 -> 77, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %197 = arith.mulf %195, %196 {timing = #hlscpp.t<77 -> 81, 4, 1>} : f64
    %198 = arith.addf %185, %197 {timing = #hlscpp.t<81 -> 86, 5, 1>} : f64
    %199 = affine.load %arg1[%arg5 * 256 + 79] {partition_indices = [79], timing = #hlscpp.t<75 -> 77, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %200 = arith.mulf %199, %196 {timing = #hlscpp.t<77 -> 81, 4, 1>} : f64
    %201 = arith.addf %188, %200 {timing = #hlscpp.t<81 -> 86, 5, 1>} : f64
    %202 = affine.load %arg1[%arg5 * 256 + 143] {partition_indices = [143], timing = #hlscpp.t<75 -> 77, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %203 = arith.mulf %202, %196 {timing = #hlscpp.t<77 -> 81, 4, 1>} : f64
    %204 = arith.addf %191, %203 {timing = #hlscpp.t<81 -> 86, 5, 1>} : f64
    %205 = affine.load %arg1[%arg5 * 256 + 207] {partition_indices = [207], timing = #hlscpp.t<75 -> 77, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %206 = arith.mulf %205, %196 {timing = #hlscpp.t<77 -> 81, 4, 1>} : f64
    %207 = arith.addf %194, %206 {timing = #hlscpp.t<81 -> 86, 5, 1>} : f64
    %208 = affine.load %arg1[%arg5 * 256 + 16] {partition_indices = [16], timing = #hlscpp.t<80 -> 82, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %209 = affine.load %arg3[16] {partition_indices = [16], timing = #hlscpp.t<80 -> 82, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %210 = arith.mulf %208, %209 {timing = #hlscpp.t<82 -> 86, 4, 1>} : f64
    %211 = arith.addf %198, %210 {timing = #hlscpp.t<86 -> 91, 5, 1>} : f64
    %212 = affine.load %arg1[%arg5 * 256 + 80] {partition_indices = [80], timing = #hlscpp.t<80 -> 82, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %213 = arith.mulf %212, %209 {timing = #hlscpp.t<82 -> 86, 4, 1>} : f64
    %214 = arith.addf %201, %213 {timing = #hlscpp.t<86 -> 91, 5, 1>} : f64
    %215 = affine.load %arg1[%arg5 * 256 + 144] {partition_indices = [144], timing = #hlscpp.t<80 -> 82, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %216 = arith.mulf %215, %209 {timing = #hlscpp.t<82 -> 86, 4, 1>} : f64
    %217 = arith.addf %204, %216 {timing = #hlscpp.t<86 -> 91, 5, 1>} : f64
    %218 = affine.load %arg1[%arg5 * 256 + 208] {partition_indices = [208], timing = #hlscpp.t<80 -> 82, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %219 = arith.mulf %218, %209 {timing = #hlscpp.t<82 -> 86, 4, 1>} : f64
    %220 = arith.addf %207, %219 {timing = #hlscpp.t<86 -> 91, 5, 1>} : f64
    %221 = affine.load %arg1[%arg5 * 256 + 17] {partition_indices = [17], timing = #hlscpp.t<85 -> 87, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %222 = affine.load %arg3[17] {partition_indices = [17], timing = #hlscpp.t<85 -> 87, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %223 = arith.mulf %221, %222 {timing = #hlscpp.t<87 -> 91, 4, 1>} : f64
    %224 = arith.addf %211, %223 {timing = #hlscpp.t<91 -> 96, 5, 1>} : f64
    %225 = affine.load %arg1[%arg5 * 256 + 81] {partition_indices = [81], timing = #hlscpp.t<85 -> 87, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %226 = arith.mulf %225, %222 {timing = #hlscpp.t<87 -> 91, 4, 1>} : f64
    %227 = arith.addf %214, %226 {timing = #hlscpp.t<91 -> 96, 5, 1>} : f64
    %228 = affine.load %arg1[%arg5 * 256 + 145] {partition_indices = [145], timing = #hlscpp.t<85 -> 87, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %229 = arith.mulf %228, %222 {timing = #hlscpp.t<87 -> 91, 4, 1>} : f64
    %230 = arith.addf %217, %229 {timing = #hlscpp.t<91 -> 96, 5, 1>} : f64
    %231 = affine.load %arg1[%arg5 * 256 + 209] {partition_indices = [209], timing = #hlscpp.t<85 -> 87, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %232 = arith.mulf %231, %222 {timing = #hlscpp.t<87 -> 91, 4, 1>} : f64
    %233 = arith.addf %220, %232 {timing = #hlscpp.t<91 -> 96, 5, 1>} : f64
    %234 = affine.load %arg1[%arg5 * 256 + 18] {partition_indices = [18], timing = #hlscpp.t<90 -> 92, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %235 = affine.load %arg3[18] {partition_indices = [18], timing = #hlscpp.t<90 -> 92, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %236 = arith.mulf %234, %235 {timing = #hlscpp.t<92 -> 96, 4, 1>} : f64
    %237 = arith.addf %224, %236 {timing = #hlscpp.t<96 -> 101, 5, 1>} : f64
    %238 = affine.load %arg1[%arg5 * 256 + 82] {partition_indices = [82], timing = #hlscpp.t<90 -> 92, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %239 = arith.mulf %238, %235 {timing = #hlscpp.t<92 -> 96, 4, 1>} : f64
    %240 = arith.addf %227, %239 {timing = #hlscpp.t<96 -> 101, 5, 1>} : f64
    %241 = affine.load %arg1[%arg5 * 256 + 146] {partition_indices = [146], timing = #hlscpp.t<90 -> 92, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %242 = arith.mulf %241, %235 {timing = #hlscpp.t<92 -> 96, 4, 1>} : f64
    %243 = arith.addf %230, %242 {timing = #hlscpp.t<96 -> 101, 5, 1>} : f64
    %244 = affine.load %arg1[%arg5 * 256 + 210] {partition_indices = [210], timing = #hlscpp.t<90 -> 92, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %245 = arith.mulf %244, %235 {timing = #hlscpp.t<92 -> 96, 4, 1>} : f64
    %246 = arith.addf %233, %245 {timing = #hlscpp.t<96 -> 101, 5, 1>} : f64
    %247 = affine.load %arg1[%arg5 * 256 + 19] {partition_indices = [19], timing = #hlscpp.t<95 -> 97, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %248 = affine.load %arg3[19] {partition_indices = [19], timing = #hlscpp.t<95 -> 97, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %249 = arith.mulf %247, %248 {timing = #hlscpp.t<97 -> 101, 4, 1>} : f64
    %250 = arith.addf %237, %249 {timing = #hlscpp.t<101 -> 106, 5, 1>} : f64
    %251 = affine.load %arg1[%arg5 * 256 + 83] {partition_indices = [83], timing = #hlscpp.t<95 -> 97, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %252 = arith.mulf %251, %248 {timing = #hlscpp.t<97 -> 101, 4, 1>} : f64
    %253 = arith.addf %240, %252 {timing = #hlscpp.t<101 -> 106, 5, 1>} : f64
    %254 = affine.load %arg1[%arg5 * 256 + 147] {partition_indices = [147], timing = #hlscpp.t<95 -> 97, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %255 = arith.mulf %254, %248 {timing = #hlscpp.t<97 -> 101, 4, 1>} : f64
    %256 = arith.addf %243, %255 {timing = #hlscpp.t<101 -> 106, 5, 1>} : f64
    %257 = affine.load %arg1[%arg5 * 256 + 211] {partition_indices = [211], timing = #hlscpp.t<95 -> 97, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %258 = arith.mulf %257, %248 {timing = #hlscpp.t<97 -> 101, 4, 1>} : f64
    %259 = arith.addf %246, %258 {timing = #hlscpp.t<101 -> 106, 5, 1>} : f64
    %260 = affine.load %arg1[%arg5 * 256 + 20] {partition_indices = [20], timing = #hlscpp.t<100 -> 102, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %261 = affine.load %arg3[20] {partition_indices = [20], timing = #hlscpp.t<100 -> 102, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %262 = arith.mulf %260, %261 {timing = #hlscpp.t<102 -> 106, 4, 1>} : f64
    %263 = arith.addf %250, %262 {timing = #hlscpp.t<106 -> 111, 5, 1>} : f64
    %264 = affine.load %arg1[%arg5 * 256 + 84] {partition_indices = [84], timing = #hlscpp.t<100 -> 102, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %265 = arith.mulf %264, %261 {timing = #hlscpp.t<102 -> 106, 4, 1>} : f64
    %266 = arith.addf %253, %265 {timing = #hlscpp.t<106 -> 111, 5, 1>} : f64
    %267 = affine.load %arg1[%arg5 * 256 + 148] {partition_indices = [148], timing = #hlscpp.t<100 -> 102, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %268 = arith.mulf %267, %261 {timing = #hlscpp.t<102 -> 106, 4, 1>} : f64
    %269 = arith.addf %256, %268 {timing = #hlscpp.t<106 -> 111, 5, 1>} : f64
    %270 = affine.load %arg1[%arg5 * 256 + 212] {partition_indices = [212], timing = #hlscpp.t<100 -> 102, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %271 = arith.mulf %270, %261 {timing = #hlscpp.t<102 -> 106, 4, 1>} : f64
    %272 = arith.addf %259, %271 {timing = #hlscpp.t<106 -> 111, 5, 1>} : f64
    %273 = affine.load %arg1[%arg5 * 256 + 21] {partition_indices = [21], timing = #hlscpp.t<105 -> 107, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %274 = affine.load %arg3[21] {partition_indices = [21], timing = #hlscpp.t<105 -> 107, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %275 = arith.mulf %273, %274 {timing = #hlscpp.t<107 -> 111, 4, 1>} : f64
    %276 = arith.addf %263, %275 {timing = #hlscpp.t<111 -> 116, 5, 1>} : f64
    %277 = affine.load %arg1[%arg5 * 256 + 85] {partition_indices = [85], timing = #hlscpp.t<105 -> 107, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %278 = arith.mulf %277, %274 {timing = #hlscpp.t<107 -> 111, 4, 1>} : f64
    %279 = arith.addf %266, %278 {timing = #hlscpp.t<111 -> 116, 5, 1>} : f64
    %280 = affine.load %arg1[%arg5 * 256 + 149] {partition_indices = [149], timing = #hlscpp.t<105 -> 107, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %281 = arith.mulf %280, %274 {timing = #hlscpp.t<107 -> 111, 4, 1>} : f64
    %282 = arith.addf %269, %281 {timing = #hlscpp.t<111 -> 116, 5, 1>} : f64
    %283 = affine.load %arg1[%arg5 * 256 + 213] {partition_indices = [213], timing = #hlscpp.t<105 -> 107, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %284 = arith.mulf %283, %274 {timing = #hlscpp.t<107 -> 111, 4, 1>} : f64
    %285 = arith.addf %272, %284 {timing = #hlscpp.t<111 -> 116, 5, 1>} : f64
    %286 = affine.load %arg1[%arg5 * 256 + 22] {partition_indices = [22], timing = #hlscpp.t<110 -> 112, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %287 = affine.load %arg3[22] {partition_indices = [22], timing = #hlscpp.t<110 -> 112, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %288 = arith.mulf %286, %287 {timing = #hlscpp.t<112 -> 116, 4, 1>} : f64
    %289 = arith.addf %276, %288 {timing = #hlscpp.t<116 -> 121, 5, 1>} : f64
    %290 = affine.load %arg1[%arg5 * 256 + 86] {partition_indices = [86], timing = #hlscpp.t<110 -> 112, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %291 = arith.mulf %290, %287 {timing = #hlscpp.t<112 -> 116, 4, 1>} : f64
    %292 = arith.addf %279, %291 {timing = #hlscpp.t<116 -> 121, 5, 1>} : f64
    %293 = affine.load %arg1[%arg5 * 256 + 150] {partition_indices = [150], timing = #hlscpp.t<110 -> 112, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %294 = arith.mulf %293, %287 {timing = #hlscpp.t<112 -> 116, 4, 1>} : f64
    %295 = arith.addf %282, %294 {timing = #hlscpp.t<116 -> 121, 5, 1>} : f64
    %296 = affine.load %arg1[%arg5 * 256 + 214] {partition_indices = [214], timing = #hlscpp.t<110 -> 112, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %297 = arith.mulf %296, %287 {timing = #hlscpp.t<112 -> 116, 4, 1>} : f64
    %298 = arith.addf %285, %297 {timing = #hlscpp.t<116 -> 121, 5, 1>} : f64
    %299 = affine.load %arg1[%arg5 * 256 + 23] {partition_indices = [23], timing = #hlscpp.t<115 -> 117, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %300 = affine.load %arg3[23] {partition_indices = [23], timing = #hlscpp.t<115 -> 117, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %301 = arith.mulf %299, %300 {timing = #hlscpp.t<117 -> 121, 4, 1>} : f64
    %302 = arith.addf %289, %301 {timing = #hlscpp.t<121 -> 126, 5, 1>} : f64
    %303 = affine.load %arg1[%arg5 * 256 + 87] {partition_indices = [87], timing = #hlscpp.t<115 -> 117, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %304 = arith.mulf %303, %300 {timing = #hlscpp.t<117 -> 121, 4, 1>} : f64
    %305 = arith.addf %292, %304 {timing = #hlscpp.t<121 -> 126, 5, 1>} : f64
    %306 = affine.load %arg1[%arg5 * 256 + 151] {partition_indices = [151], timing = #hlscpp.t<115 -> 117, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %307 = arith.mulf %306, %300 {timing = #hlscpp.t<117 -> 121, 4, 1>} : f64
    %308 = arith.addf %295, %307 {timing = #hlscpp.t<121 -> 126, 5, 1>} : f64
    %309 = affine.load %arg1[%arg5 * 256 + 215] {partition_indices = [215], timing = #hlscpp.t<115 -> 117, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %310 = arith.mulf %309, %300 {timing = #hlscpp.t<117 -> 121, 4, 1>} : f64
    %311 = arith.addf %298, %310 {timing = #hlscpp.t<121 -> 126, 5, 1>} : f64
    %312 = affine.load %arg1[%arg5 * 256 + 24] {partition_indices = [24], timing = #hlscpp.t<120 -> 122, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %313 = affine.load %arg3[24] {partition_indices = [24], timing = #hlscpp.t<120 -> 122, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %314 = arith.mulf %312, %313 {timing = #hlscpp.t<122 -> 126, 4, 1>} : f64
    %315 = arith.addf %302, %314 {timing = #hlscpp.t<126 -> 131, 5, 1>} : f64
    %316 = affine.load %arg1[%arg5 * 256 + 88] {partition_indices = [88], timing = #hlscpp.t<120 -> 122, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %317 = arith.mulf %316, %313 {timing = #hlscpp.t<122 -> 126, 4, 1>} : f64
    %318 = arith.addf %305, %317 {timing = #hlscpp.t<126 -> 131, 5, 1>} : f64
    %319 = affine.load %arg1[%arg5 * 256 + 152] {partition_indices = [152], timing = #hlscpp.t<120 -> 122, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %320 = arith.mulf %319, %313 {timing = #hlscpp.t<122 -> 126, 4, 1>} : f64
    %321 = arith.addf %308, %320 {timing = #hlscpp.t<126 -> 131, 5, 1>} : f64
    %322 = affine.load %arg1[%arg5 * 256 + 216] {partition_indices = [216], timing = #hlscpp.t<120 -> 122, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %323 = arith.mulf %322, %313 {timing = #hlscpp.t<122 -> 126, 4, 1>} : f64
    %324 = arith.addf %311, %323 {timing = #hlscpp.t<126 -> 131, 5, 1>} : f64
    %325 = affine.load %arg1[%arg5 * 256 + 25] {partition_indices = [25], timing = #hlscpp.t<125 -> 127, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %326 = affine.load %arg3[25] {partition_indices = [25], timing = #hlscpp.t<125 -> 127, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %327 = arith.mulf %325, %326 {timing = #hlscpp.t<127 -> 131, 4, 1>} : f64
    %328 = arith.addf %315, %327 {timing = #hlscpp.t<131 -> 136, 5, 1>} : f64
    %329 = affine.load %arg1[%arg5 * 256 + 89] {partition_indices = [89], timing = #hlscpp.t<125 -> 127, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %330 = arith.mulf %329, %326 {timing = #hlscpp.t<127 -> 131, 4, 1>} : f64
    %331 = arith.addf %318, %330 {timing = #hlscpp.t<131 -> 136, 5, 1>} : f64
    %332 = affine.load %arg1[%arg5 * 256 + 153] {partition_indices = [153], timing = #hlscpp.t<125 -> 127, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %333 = arith.mulf %332, %326 {timing = #hlscpp.t<127 -> 131, 4, 1>} : f64
    %334 = arith.addf %321, %333 {timing = #hlscpp.t<131 -> 136, 5, 1>} : f64
    %335 = affine.load %arg1[%arg5 * 256 + 217] {partition_indices = [217], timing = #hlscpp.t<125 -> 127, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %336 = arith.mulf %335, %326 {timing = #hlscpp.t<127 -> 131, 4, 1>} : f64
    %337 = arith.addf %324, %336 {timing = #hlscpp.t<131 -> 136, 5, 1>} : f64
    %338 = affine.load %arg1[%arg5 * 256 + 26] {partition_indices = [26], timing = #hlscpp.t<130 -> 132, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %339 = affine.load %arg3[26] {partition_indices = [26], timing = #hlscpp.t<130 -> 132, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %340 = arith.mulf %338, %339 {timing = #hlscpp.t<132 -> 136, 4, 1>} : f64
    %341 = arith.addf %328, %340 {timing = #hlscpp.t<136 -> 141, 5, 1>} : f64
    %342 = affine.load %arg1[%arg5 * 256 + 90] {partition_indices = [90], timing = #hlscpp.t<130 -> 132, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %343 = arith.mulf %342, %339 {timing = #hlscpp.t<132 -> 136, 4, 1>} : f64
    %344 = arith.addf %331, %343 {timing = #hlscpp.t<136 -> 141, 5, 1>} : f64
    %345 = affine.load %arg1[%arg5 * 256 + 154] {partition_indices = [154], timing = #hlscpp.t<130 -> 132, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %346 = arith.mulf %345, %339 {timing = #hlscpp.t<132 -> 136, 4, 1>} : f64
    %347 = arith.addf %334, %346 {timing = #hlscpp.t<136 -> 141, 5, 1>} : f64
    %348 = affine.load %arg1[%arg5 * 256 + 218] {partition_indices = [218], timing = #hlscpp.t<130 -> 132, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %349 = arith.mulf %348, %339 {timing = #hlscpp.t<132 -> 136, 4, 1>} : f64
    %350 = arith.addf %337, %349 {timing = #hlscpp.t<136 -> 141, 5, 1>} : f64
    %351 = affine.load %arg1[%arg5 * 256 + 27] {partition_indices = [27], timing = #hlscpp.t<135 -> 137, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %352 = affine.load %arg3[27] {partition_indices = [27], timing = #hlscpp.t<135 -> 137, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %353 = arith.mulf %351, %352 {timing = #hlscpp.t<137 -> 141, 4, 1>} : f64
    %354 = arith.addf %341, %353 {timing = #hlscpp.t<141 -> 146, 5, 1>} : f64
    %355 = affine.load %arg1[%arg5 * 256 + 91] {partition_indices = [91], timing = #hlscpp.t<135 -> 137, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %356 = arith.mulf %355, %352 {timing = #hlscpp.t<137 -> 141, 4, 1>} : f64
    %357 = arith.addf %344, %356 {timing = #hlscpp.t<141 -> 146, 5, 1>} : f64
    %358 = affine.load %arg1[%arg5 * 256 + 155] {partition_indices = [155], timing = #hlscpp.t<135 -> 137, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %359 = arith.mulf %358, %352 {timing = #hlscpp.t<137 -> 141, 4, 1>} : f64
    %360 = arith.addf %347, %359 {timing = #hlscpp.t<141 -> 146, 5, 1>} : f64
    %361 = affine.load %arg1[%arg5 * 256 + 219] {partition_indices = [219], timing = #hlscpp.t<135 -> 137, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %362 = arith.mulf %361, %352 {timing = #hlscpp.t<137 -> 141, 4, 1>} : f64
    %363 = arith.addf %350, %362 {timing = #hlscpp.t<141 -> 146, 5, 1>} : f64
    %364 = affine.load %arg1[%arg5 * 256 + 28] {partition_indices = [28], timing = #hlscpp.t<140 -> 142, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %365 = affine.load %arg3[28] {partition_indices = [28], timing = #hlscpp.t<140 -> 142, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %366 = arith.mulf %364, %365 {timing = #hlscpp.t<142 -> 146, 4, 1>} : f64
    %367 = arith.addf %354, %366 {timing = #hlscpp.t<146 -> 151, 5, 1>} : f64
    %368 = affine.load %arg1[%arg5 * 256 + 92] {partition_indices = [92], timing = #hlscpp.t<140 -> 142, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %369 = arith.mulf %368, %365 {timing = #hlscpp.t<142 -> 146, 4, 1>} : f64
    %370 = arith.addf %357, %369 {timing = #hlscpp.t<146 -> 151, 5, 1>} : f64
    %371 = affine.load %arg1[%arg5 * 256 + 156] {partition_indices = [156], timing = #hlscpp.t<140 -> 142, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %372 = arith.mulf %371, %365 {timing = #hlscpp.t<142 -> 146, 4, 1>} : f64
    %373 = arith.addf %360, %372 {timing = #hlscpp.t<146 -> 151, 5, 1>} : f64
    %374 = affine.load %arg1[%arg5 * 256 + 220] {partition_indices = [220], timing = #hlscpp.t<140 -> 142, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %375 = arith.mulf %374, %365 {timing = #hlscpp.t<142 -> 146, 4, 1>} : f64
    %376 = arith.addf %363, %375 {timing = #hlscpp.t<146 -> 151, 5, 1>} : f64
    %377 = affine.load %arg1[%arg5 * 256 + 29] {partition_indices = [29], timing = #hlscpp.t<145 -> 147, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %378 = affine.load %arg3[29] {partition_indices = [29], timing = #hlscpp.t<145 -> 147, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %379 = arith.mulf %377, %378 {timing = #hlscpp.t<147 -> 151, 4, 1>} : f64
    %380 = arith.addf %367, %379 {timing = #hlscpp.t<151 -> 156, 5, 1>} : f64
    %381 = affine.load %arg1[%arg5 * 256 + 93] {partition_indices = [93], timing = #hlscpp.t<145 -> 147, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %382 = arith.mulf %381, %378 {timing = #hlscpp.t<147 -> 151, 4, 1>} : f64
    %383 = arith.addf %370, %382 {timing = #hlscpp.t<151 -> 156, 5, 1>} : f64
    %384 = affine.load %arg1[%arg5 * 256 + 157] {partition_indices = [157], timing = #hlscpp.t<145 -> 147, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %385 = arith.mulf %384, %378 {timing = #hlscpp.t<147 -> 151, 4, 1>} : f64
    %386 = arith.addf %373, %385 {timing = #hlscpp.t<151 -> 156, 5, 1>} : f64
    %387 = affine.load %arg1[%arg5 * 256 + 221] {partition_indices = [221], timing = #hlscpp.t<145 -> 147, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %388 = arith.mulf %387, %378 {timing = #hlscpp.t<147 -> 151, 4, 1>} : f64
    %389 = arith.addf %376, %388 {timing = #hlscpp.t<151 -> 156, 5, 1>} : f64
    %390 = affine.load %arg1[%arg5 * 256 + 30] {partition_indices = [30], timing = #hlscpp.t<150 -> 152, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %391 = affine.load %arg3[30] {partition_indices = [30], timing = #hlscpp.t<150 -> 152, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %392 = arith.mulf %390, %391 {timing = #hlscpp.t<152 -> 156, 4, 1>} : f64
    %393 = arith.addf %380, %392 {timing = #hlscpp.t<156 -> 161, 5, 1>} : f64
    %394 = affine.load %arg1[%arg5 * 256 + 94] {partition_indices = [94], timing = #hlscpp.t<150 -> 152, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %395 = arith.mulf %394, %391 {timing = #hlscpp.t<152 -> 156, 4, 1>} : f64
    %396 = arith.addf %383, %395 {timing = #hlscpp.t<156 -> 161, 5, 1>} : f64
    %397 = affine.load %arg1[%arg5 * 256 + 158] {partition_indices = [158], timing = #hlscpp.t<150 -> 152, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %398 = arith.mulf %397, %391 {timing = #hlscpp.t<152 -> 156, 4, 1>} : f64
    %399 = arith.addf %386, %398 {timing = #hlscpp.t<156 -> 161, 5, 1>} : f64
    %400 = affine.load %arg1[%arg5 * 256 + 222] {partition_indices = [222], timing = #hlscpp.t<150 -> 152, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %401 = arith.mulf %400, %391 {timing = #hlscpp.t<152 -> 156, 4, 1>} : f64
    %402 = arith.addf %389, %401 {timing = #hlscpp.t<156 -> 161, 5, 1>} : f64
    %403 = affine.load %arg1[%arg5 * 256 + 31] {partition_indices = [31], timing = #hlscpp.t<155 -> 157, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %404 = affine.load %arg3[31] {partition_indices = [31], timing = #hlscpp.t<155 -> 157, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %405 = arith.mulf %403, %404 {timing = #hlscpp.t<157 -> 161, 4, 1>} : f64
    %406 = arith.addf %393, %405 {timing = #hlscpp.t<161 -> 166, 5, 1>} : f64
    %407 = affine.load %arg1[%arg5 * 256 + 95] {partition_indices = [95], timing = #hlscpp.t<155 -> 157, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %408 = arith.mulf %407, %404 {timing = #hlscpp.t<157 -> 161, 4, 1>} : f64
    %409 = arith.addf %396, %408 {timing = #hlscpp.t<161 -> 166, 5, 1>} : f64
    %410 = affine.load %arg1[%arg5 * 256 + 159] {partition_indices = [159], timing = #hlscpp.t<155 -> 157, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %411 = arith.mulf %410, %404 {timing = #hlscpp.t<157 -> 161, 4, 1>} : f64
    %412 = arith.addf %399, %411 {timing = #hlscpp.t<161 -> 166, 5, 1>} : f64
    %413 = affine.load %arg1[%arg5 * 256 + 223] {partition_indices = [223], timing = #hlscpp.t<155 -> 157, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %414 = arith.mulf %413, %404 {timing = #hlscpp.t<157 -> 161, 4, 1>} : f64
    %415 = arith.addf %402, %414 {timing = #hlscpp.t<161 -> 166, 5, 1>} : f64
    %416 = affine.load %arg1[%arg5 * 256 + 32] {partition_indices = [32], timing = #hlscpp.t<160 -> 162, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %417 = affine.load %arg3[32] {partition_indices = [32], timing = #hlscpp.t<160 -> 162, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %418 = arith.mulf %416, %417 {timing = #hlscpp.t<162 -> 166, 4, 1>} : f64
    %419 = arith.addf %406, %418 {timing = #hlscpp.t<166 -> 171, 5, 1>} : f64
    %420 = affine.load %arg1[%arg5 * 256 + 96] {partition_indices = [96], timing = #hlscpp.t<160 -> 162, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %421 = arith.mulf %420, %417 {timing = #hlscpp.t<162 -> 166, 4, 1>} : f64
    %422 = arith.addf %409, %421 {timing = #hlscpp.t<166 -> 171, 5, 1>} : f64
    %423 = affine.load %arg1[%arg5 * 256 + 160] {partition_indices = [160], timing = #hlscpp.t<160 -> 162, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %424 = arith.mulf %423, %417 {timing = #hlscpp.t<162 -> 166, 4, 1>} : f64
    %425 = arith.addf %412, %424 {timing = #hlscpp.t<166 -> 171, 5, 1>} : f64
    %426 = affine.load %arg1[%arg5 * 256 + 224] {partition_indices = [224], timing = #hlscpp.t<160 -> 162, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %427 = arith.mulf %426, %417 {timing = #hlscpp.t<162 -> 166, 4, 1>} : f64
    %428 = arith.addf %415, %427 {timing = #hlscpp.t<166 -> 171, 5, 1>} : f64
    %429 = affine.load %arg1[%arg5 * 256 + 33] {partition_indices = [33], timing = #hlscpp.t<165 -> 167, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %430 = affine.load %arg3[33] {partition_indices = [33], timing = #hlscpp.t<165 -> 167, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %431 = arith.mulf %429, %430 {timing = #hlscpp.t<167 -> 171, 4, 1>} : f64
    %432 = arith.addf %419, %431 {timing = #hlscpp.t<171 -> 176, 5, 1>} : f64
    %433 = affine.load %arg1[%arg5 * 256 + 97] {partition_indices = [97], timing = #hlscpp.t<165 -> 167, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %434 = arith.mulf %433, %430 {timing = #hlscpp.t<167 -> 171, 4, 1>} : f64
    %435 = arith.addf %422, %434 {timing = #hlscpp.t<171 -> 176, 5, 1>} : f64
    %436 = affine.load %arg1[%arg5 * 256 + 161] {partition_indices = [161], timing = #hlscpp.t<165 -> 167, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %437 = arith.mulf %436, %430 {timing = #hlscpp.t<167 -> 171, 4, 1>} : f64
    %438 = arith.addf %425, %437 {timing = #hlscpp.t<171 -> 176, 5, 1>} : f64
    %439 = affine.load %arg1[%arg5 * 256 + 225] {partition_indices = [225], timing = #hlscpp.t<165 -> 167, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %440 = arith.mulf %439, %430 {timing = #hlscpp.t<167 -> 171, 4, 1>} : f64
    %441 = arith.addf %428, %440 {timing = #hlscpp.t<171 -> 176, 5, 1>} : f64
    %442 = affine.load %arg1[%arg5 * 256 + 34] {partition_indices = [34], timing = #hlscpp.t<170 -> 172, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %443 = affine.load %arg3[34] {partition_indices = [34], timing = #hlscpp.t<170 -> 172, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %444 = arith.mulf %442, %443 {timing = #hlscpp.t<172 -> 176, 4, 1>} : f64
    %445 = arith.addf %432, %444 {timing = #hlscpp.t<176 -> 181, 5, 1>} : f64
    %446 = affine.load %arg1[%arg5 * 256 + 98] {partition_indices = [98], timing = #hlscpp.t<170 -> 172, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %447 = arith.mulf %446, %443 {timing = #hlscpp.t<172 -> 176, 4, 1>} : f64
    %448 = arith.addf %435, %447 {timing = #hlscpp.t<176 -> 181, 5, 1>} : f64
    %449 = affine.load %arg1[%arg5 * 256 + 162] {partition_indices = [162], timing = #hlscpp.t<170 -> 172, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %450 = arith.mulf %449, %443 {timing = #hlscpp.t<172 -> 176, 4, 1>} : f64
    %451 = arith.addf %438, %450 {timing = #hlscpp.t<176 -> 181, 5, 1>} : f64
    %452 = affine.load %arg1[%arg5 * 256 + 226] {partition_indices = [226], timing = #hlscpp.t<170 -> 172, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %453 = arith.mulf %452, %443 {timing = #hlscpp.t<172 -> 176, 4, 1>} : f64
    %454 = arith.addf %441, %453 {timing = #hlscpp.t<176 -> 181, 5, 1>} : f64
    %455 = affine.load %arg1[%arg5 * 256 + 35] {partition_indices = [35], timing = #hlscpp.t<175 -> 177, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %456 = affine.load %arg3[35] {partition_indices = [35], timing = #hlscpp.t<175 -> 177, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %457 = arith.mulf %455, %456 {timing = #hlscpp.t<177 -> 181, 4, 1>} : f64
    %458 = arith.addf %445, %457 {timing = #hlscpp.t<181 -> 186, 5, 1>} : f64
    %459 = affine.load %arg1[%arg5 * 256 + 99] {partition_indices = [99], timing = #hlscpp.t<175 -> 177, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %460 = arith.mulf %459, %456 {timing = #hlscpp.t<177 -> 181, 4, 1>} : f64
    %461 = arith.addf %448, %460 {timing = #hlscpp.t<181 -> 186, 5, 1>} : f64
    %462 = affine.load %arg1[%arg5 * 256 + 163] {partition_indices = [163], timing = #hlscpp.t<175 -> 177, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %463 = arith.mulf %462, %456 {timing = #hlscpp.t<177 -> 181, 4, 1>} : f64
    %464 = arith.addf %451, %463 {timing = #hlscpp.t<181 -> 186, 5, 1>} : f64
    %465 = affine.load %arg1[%arg5 * 256 + 227] {partition_indices = [227], timing = #hlscpp.t<175 -> 177, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %466 = arith.mulf %465, %456 {timing = #hlscpp.t<177 -> 181, 4, 1>} : f64
    %467 = arith.addf %454, %466 {timing = #hlscpp.t<181 -> 186, 5, 1>} : f64
    %468 = affine.load %arg1[%arg5 * 256 + 36] {partition_indices = [36], timing = #hlscpp.t<180 -> 182, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %469 = affine.load %arg3[36] {partition_indices = [36], timing = #hlscpp.t<180 -> 182, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %470 = arith.mulf %468, %469 {timing = #hlscpp.t<182 -> 186, 4, 1>} : f64
    %471 = arith.addf %458, %470 {timing = #hlscpp.t<186 -> 191, 5, 1>} : f64
    %472 = affine.load %arg1[%arg5 * 256 + 100] {partition_indices = [100], timing = #hlscpp.t<180 -> 182, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %473 = arith.mulf %472, %469 {timing = #hlscpp.t<182 -> 186, 4, 1>} : f64
    %474 = arith.addf %461, %473 {timing = #hlscpp.t<186 -> 191, 5, 1>} : f64
    %475 = affine.load %arg1[%arg5 * 256 + 164] {partition_indices = [164], timing = #hlscpp.t<180 -> 182, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %476 = arith.mulf %475, %469 {timing = #hlscpp.t<182 -> 186, 4, 1>} : f64
    %477 = arith.addf %464, %476 {timing = #hlscpp.t<186 -> 191, 5, 1>} : f64
    %478 = affine.load %arg1[%arg5 * 256 + 228] {partition_indices = [228], timing = #hlscpp.t<180 -> 182, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %479 = arith.mulf %478, %469 {timing = #hlscpp.t<182 -> 186, 4, 1>} : f64
    %480 = arith.addf %467, %479 {timing = #hlscpp.t<186 -> 191, 5, 1>} : f64
    %481 = affine.load %arg1[%arg5 * 256 + 37] {partition_indices = [37], timing = #hlscpp.t<185 -> 187, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %482 = affine.load %arg3[37] {partition_indices = [37], timing = #hlscpp.t<185 -> 187, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %483 = arith.mulf %481, %482 {timing = #hlscpp.t<187 -> 191, 4, 1>} : f64
    %484 = arith.addf %471, %483 {timing = #hlscpp.t<191 -> 196, 5, 1>} : f64
    %485 = affine.load %arg1[%arg5 * 256 + 101] {partition_indices = [101], timing = #hlscpp.t<185 -> 187, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %486 = arith.mulf %485, %482 {timing = #hlscpp.t<187 -> 191, 4, 1>} : f64
    %487 = arith.addf %474, %486 {timing = #hlscpp.t<191 -> 196, 5, 1>} : f64
    %488 = affine.load %arg1[%arg5 * 256 + 165] {partition_indices = [165], timing = #hlscpp.t<185 -> 187, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %489 = arith.mulf %488, %482 {timing = #hlscpp.t<187 -> 191, 4, 1>} : f64
    %490 = arith.addf %477, %489 {timing = #hlscpp.t<191 -> 196, 5, 1>} : f64
    %491 = affine.load %arg1[%arg5 * 256 + 229] {partition_indices = [229], timing = #hlscpp.t<185 -> 187, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %492 = arith.mulf %491, %482 {timing = #hlscpp.t<187 -> 191, 4, 1>} : f64
    %493 = arith.addf %480, %492 {timing = #hlscpp.t<191 -> 196, 5, 1>} : f64
    %494 = affine.load %arg1[%arg5 * 256 + 38] {partition_indices = [38], timing = #hlscpp.t<190 -> 192, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %495 = affine.load %arg3[38] {partition_indices = [38], timing = #hlscpp.t<190 -> 192, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %496 = arith.mulf %494, %495 {timing = #hlscpp.t<192 -> 196, 4, 1>} : f64
    %497 = arith.addf %484, %496 {timing = #hlscpp.t<196 -> 201, 5, 1>} : f64
    %498 = affine.load %arg1[%arg5 * 256 + 102] {partition_indices = [102], timing = #hlscpp.t<190 -> 192, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %499 = arith.mulf %498, %495 {timing = #hlscpp.t<192 -> 196, 4, 1>} : f64
    %500 = arith.addf %487, %499 {timing = #hlscpp.t<196 -> 201, 5, 1>} : f64
    %501 = affine.load %arg1[%arg5 * 256 + 166] {partition_indices = [166], timing = #hlscpp.t<190 -> 192, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %502 = arith.mulf %501, %495 {timing = #hlscpp.t<192 -> 196, 4, 1>} : f64
    %503 = arith.addf %490, %502 {timing = #hlscpp.t<196 -> 201, 5, 1>} : f64
    %504 = affine.load %arg1[%arg5 * 256 + 230] {partition_indices = [230], timing = #hlscpp.t<190 -> 192, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %505 = arith.mulf %504, %495 {timing = #hlscpp.t<192 -> 196, 4, 1>} : f64
    %506 = arith.addf %493, %505 {timing = #hlscpp.t<196 -> 201, 5, 1>} : f64
    %507 = affine.load %arg1[%arg5 * 256 + 39] {partition_indices = [39], timing = #hlscpp.t<195 -> 197, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %508 = affine.load %arg3[39] {partition_indices = [39], timing = #hlscpp.t<195 -> 197, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %509 = arith.mulf %507, %508 {timing = #hlscpp.t<197 -> 201, 4, 1>} : f64
    %510 = arith.addf %497, %509 {timing = #hlscpp.t<201 -> 206, 5, 1>} : f64
    %511 = affine.load %arg1[%arg5 * 256 + 103] {partition_indices = [103], timing = #hlscpp.t<195 -> 197, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %512 = arith.mulf %511, %508 {timing = #hlscpp.t<197 -> 201, 4, 1>} : f64
    %513 = arith.addf %500, %512 {timing = #hlscpp.t<201 -> 206, 5, 1>} : f64
    %514 = affine.load %arg1[%arg5 * 256 + 167] {partition_indices = [167], timing = #hlscpp.t<195 -> 197, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %515 = arith.mulf %514, %508 {timing = #hlscpp.t<197 -> 201, 4, 1>} : f64
    %516 = arith.addf %503, %515 {timing = #hlscpp.t<201 -> 206, 5, 1>} : f64
    %517 = affine.load %arg1[%arg5 * 256 + 231] {partition_indices = [231], timing = #hlscpp.t<195 -> 197, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %518 = arith.mulf %517, %508 {timing = #hlscpp.t<197 -> 201, 4, 1>} : f64
    %519 = arith.addf %506, %518 {timing = #hlscpp.t<201 -> 206, 5, 1>} : f64
    %520 = affine.load %arg1[%arg5 * 256 + 40] {partition_indices = [40], timing = #hlscpp.t<200 -> 202, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %521 = affine.load %arg3[40] {partition_indices = [40], timing = #hlscpp.t<200 -> 202, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %522 = arith.mulf %520, %521 {timing = #hlscpp.t<202 -> 206, 4, 1>} : f64
    %523 = arith.addf %510, %522 {timing = #hlscpp.t<206 -> 211, 5, 1>} : f64
    %524 = affine.load %arg1[%arg5 * 256 + 104] {partition_indices = [104], timing = #hlscpp.t<200 -> 202, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %525 = arith.mulf %524, %521 {timing = #hlscpp.t<202 -> 206, 4, 1>} : f64
    %526 = arith.addf %513, %525 {timing = #hlscpp.t<206 -> 211, 5, 1>} : f64
    %527 = affine.load %arg1[%arg5 * 256 + 168] {partition_indices = [168], timing = #hlscpp.t<200 -> 202, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %528 = arith.mulf %527, %521 {timing = #hlscpp.t<202 -> 206, 4, 1>} : f64
    %529 = arith.addf %516, %528 {timing = #hlscpp.t<206 -> 211, 5, 1>} : f64
    %530 = affine.load %arg1[%arg5 * 256 + 232] {partition_indices = [232], timing = #hlscpp.t<200 -> 202, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %531 = arith.mulf %530, %521 {timing = #hlscpp.t<202 -> 206, 4, 1>} : f64
    %532 = arith.addf %519, %531 {timing = #hlscpp.t<206 -> 211, 5, 1>} : f64
    %533 = affine.load %arg1[%arg5 * 256 + 41] {partition_indices = [41], timing = #hlscpp.t<205 -> 207, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %534 = affine.load %arg3[41] {partition_indices = [41], timing = #hlscpp.t<205 -> 207, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %535 = arith.mulf %533, %534 {timing = #hlscpp.t<207 -> 211, 4, 1>} : f64
    %536 = arith.addf %523, %535 {timing = #hlscpp.t<211 -> 216, 5, 1>} : f64
    %537 = affine.load %arg1[%arg5 * 256 + 105] {partition_indices = [105], timing = #hlscpp.t<205 -> 207, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %538 = arith.mulf %537, %534 {timing = #hlscpp.t<207 -> 211, 4, 1>} : f64
    %539 = arith.addf %526, %538 {timing = #hlscpp.t<211 -> 216, 5, 1>} : f64
    %540 = affine.load %arg1[%arg5 * 256 + 169] {partition_indices = [169], timing = #hlscpp.t<205 -> 207, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %541 = arith.mulf %540, %534 {timing = #hlscpp.t<207 -> 211, 4, 1>} : f64
    %542 = arith.addf %529, %541 {timing = #hlscpp.t<211 -> 216, 5, 1>} : f64
    %543 = affine.load %arg1[%arg5 * 256 + 233] {partition_indices = [233], timing = #hlscpp.t<205 -> 207, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %544 = arith.mulf %543, %534 {timing = #hlscpp.t<207 -> 211, 4, 1>} : f64
    %545 = arith.addf %532, %544 {timing = #hlscpp.t<211 -> 216, 5, 1>} : f64
    %546 = affine.load %arg1[%arg5 * 256 + 42] {partition_indices = [42], timing = #hlscpp.t<210 -> 212, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %547 = affine.load %arg3[42] {partition_indices = [42], timing = #hlscpp.t<210 -> 212, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %548 = arith.mulf %546, %547 {timing = #hlscpp.t<212 -> 216, 4, 1>} : f64
    %549 = arith.addf %536, %548 {timing = #hlscpp.t<216 -> 221, 5, 1>} : f64
    %550 = affine.load %arg1[%arg5 * 256 + 106] {partition_indices = [106], timing = #hlscpp.t<210 -> 212, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %551 = arith.mulf %550, %547 {timing = #hlscpp.t<212 -> 216, 4, 1>} : f64
    %552 = arith.addf %539, %551 {timing = #hlscpp.t<216 -> 221, 5, 1>} : f64
    %553 = affine.load %arg1[%arg5 * 256 + 170] {partition_indices = [170], timing = #hlscpp.t<210 -> 212, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %554 = arith.mulf %553, %547 {timing = #hlscpp.t<212 -> 216, 4, 1>} : f64
    %555 = arith.addf %542, %554 {timing = #hlscpp.t<216 -> 221, 5, 1>} : f64
    %556 = affine.load %arg1[%arg5 * 256 + 234] {partition_indices = [234], timing = #hlscpp.t<210 -> 212, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %557 = arith.mulf %556, %547 {timing = #hlscpp.t<212 -> 216, 4, 1>} : f64
    %558 = arith.addf %545, %557 {timing = #hlscpp.t<216 -> 221, 5, 1>} : f64
    %559 = affine.load %arg1[%arg5 * 256 + 43] {partition_indices = [43], timing = #hlscpp.t<215 -> 217, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %560 = affine.load %arg3[43] {partition_indices = [43], timing = #hlscpp.t<215 -> 217, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %561 = arith.mulf %559, %560 {timing = #hlscpp.t<217 -> 221, 4, 1>} : f64
    %562 = arith.addf %549, %561 {timing = #hlscpp.t<221 -> 226, 5, 1>} : f64
    %563 = affine.load %arg1[%arg5 * 256 + 107] {partition_indices = [107], timing = #hlscpp.t<215 -> 217, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %564 = arith.mulf %563, %560 {timing = #hlscpp.t<217 -> 221, 4, 1>} : f64
    %565 = arith.addf %552, %564 {timing = #hlscpp.t<221 -> 226, 5, 1>} : f64
    %566 = affine.load %arg1[%arg5 * 256 + 171] {partition_indices = [171], timing = #hlscpp.t<215 -> 217, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %567 = arith.mulf %566, %560 {timing = #hlscpp.t<217 -> 221, 4, 1>} : f64
    %568 = arith.addf %555, %567 {timing = #hlscpp.t<221 -> 226, 5, 1>} : f64
    %569 = affine.load %arg1[%arg5 * 256 + 235] {partition_indices = [235], timing = #hlscpp.t<215 -> 217, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %570 = arith.mulf %569, %560 {timing = #hlscpp.t<217 -> 221, 4, 1>} : f64
    %571 = arith.addf %558, %570 {timing = #hlscpp.t<221 -> 226, 5, 1>} : f64
    %572 = affine.load %arg1[%arg5 * 256 + 44] {partition_indices = [44], timing = #hlscpp.t<220 -> 222, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %573 = affine.load %arg3[44] {partition_indices = [44], timing = #hlscpp.t<220 -> 222, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %574 = arith.mulf %572, %573 {timing = #hlscpp.t<222 -> 226, 4, 1>} : f64
    %575 = arith.addf %562, %574 {timing = #hlscpp.t<226 -> 231, 5, 1>} : f64
    %576 = affine.load %arg1[%arg5 * 256 + 108] {partition_indices = [108], timing = #hlscpp.t<220 -> 222, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %577 = arith.mulf %576, %573 {timing = #hlscpp.t<222 -> 226, 4, 1>} : f64
    %578 = arith.addf %565, %577 {timing = #hlscpp.t<226 -> 231, 5, 1>} : f64
    %579 = affine.load %arg1[%arg5 * 256 + 172] {partition_indices = [172], timing = #hlscpp.t<220 -> 222, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %580 = arith.mulf %579, %573 {timing = #hlscpp.t<222 -> 226, 4, 1>} : f64
    %581 = arith.addf %568, %580 {timing = #hlscpp.t<226 -> 231, 5, 1>} : f64
    %582 = affine.load %arg1[%arg5 * 256 + 236] {partition_indices = [236], timing = #hlscpp.t<220 -> 222, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %583 = arith.mulf %582, %573 {timing = #hlscpp.t<222 -> 226, 4, 1>} : f64
    %584 = arith.addf %571, %583 {timing = #hlscpp.t<226 -> 231, 5, 1>} : f64
    %585 = affine.load %arg1[%arg5 * 256 + 45] {partition_indices = [45], timing = #hlscpp.t<225 -> 227, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %586 = affine.load %arg3[45] {partition_indices = [45], timing = #hlscpp.t<225 -> 227, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %587 = arith.mulf %585, %586 {timing = #hlscpp.t<227 -> 231, 4, 1>} : f64
    %588 = arith.addf %575, %587 {timing = #hlscpp.t<231 -> 236, 5, 1>} : f64
    %589 = affine.load %arg1[%arg5 * 256 + 109] {partition_indices = [109], timing = #hlscpp.t<225 -> 227, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %590 = arith.mulf %589, %586 {timing = #hlscpp.t<227 -> 231, 4, 1>} : f64
    %591 = arith.addf %578, %590 {timing = #hlscpp.t<231 -> 236, 5, 1>} : f64
    %592 = affine.load %arg1[%arg5 * 256 + 173] {partition_indices = [173], timing = #hlscpp.t<225 -> 227, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %593 = arith.mulf %592, %586 {timing = #hlscpp.t<227 -> 231, 4, 1>} : f64
    %594 = arith.addf %581, %593 {timing = #hlscpp.t<231 -> 236, 5, 1>} : f64
    %595 = affine.load %arg1[%arg5 * 256 + 237] {partition_indices = [237], timing = #hlscpp.t<225 -> 227, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %596 = arith.mulf %595, %586 {timing = #hlscpp.t<227 -> 231, 4, 1>} : f64
    %597 = arith.addf %584, %596 {timing = #hlscpp.t<231 -> 236, 5, 1>} : f64
    %598 = affine.load %arg1[%arg5 * 256 + 46] {partition_indices = [46], timing = #hlscpp.t<230 -> 232, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %599 = affine.load %arg3[46] {partition_indices = [46], timing = #hlscpp.t<230 -> 232, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %600 = arith.mulf %598, %599 {timing = #hlscpp.t<232 -> 236, 4, 1>} : f64
    %601 = arith.addf %588, %600 {timing = #hlscpp.t<236 -> 241, 5, 1>} : f64
    %602 = affine.load %arg1[%arg5 * 256 + 110] {partition_indices = [110], timing = #hlscpp.t<230 -> 232, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %603 = arith.mulf %602, %599 {timing = #hlscpp.t<232 -> 236, 4, 1>} : f64
    %604 = arith.addf %591, %603 {timing = #hlscpp.t<236 -> 241, 5, 1>} : f64
    %605 = affine.load %arg1[%arg5 * 256 + 174] {partition_indices = [174], timing = #hlscpp.t<230 -> 232, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %606 = arith.mulf %605, %599 {timing = #hlscpp.t<232 -> 236, 4, 1>} : f64
    %607 = arith.addf %594, %606 {timing = #hlscpp.t<236 -> 241, 5, 1>} : f64
    %608 = affine.load %arg1[%arg5 * 256 + 238] {partition_indices = [238], timing = #hlscpp.t<230 -> 232, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %609 = arith.mulf %608, %599 {timing = #hlscpp.t<232 -> 236, 4, 1>} : f64
    %610 = arith.addf %597, %609 {timing = #hlscpp.t<236 -> 241, 5, 1>} : f64
    %611 = affine.load %arg1[%arg5 * 256 + 47] {partition_indices = [47], timing = #hlscpp.t<235 -> 237, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %612 = affine.load %arg3[47] {partition_indices = [47], timing = #hlscpp.t<235 -> 237, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %613 = arith.mulf %611, %612 {timing = #hlscpp.t<237 -> 241, 4, 1>} : f64
    %614 = arith.addf %601, %613 {timing = #hlscpp.t<241 -> 246, 5, 1>} : f64
    %615 = affine.load %arg1[%arg5 * 256 + 111] {partition_indices = [111], timing = #hlscpp.t<235 -> 237, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %616 = arith.mulf %615, %612 {timing = #hlscpp.t<237 -> 241, 4, 1>} : f64
    %617 = arith.addf %604, %616 {timing = #hlscpp.t<241 -> 246, 5, 1>} : f64
    %618 = affine.load %arg1[%arg5 * 256 + 175] {partition_indices = [175], timing = #hlscpp.t<235 -> 237, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %619 = arith.mulf %618, %612 {timing = #hlscpp.t<237 -> 241, 4, 1>} : f64
    %620 = arith.addf %607, %619 {timing = #hlscpp.t<241 -> 246, 5, 1>} : f64
    %621 = affine.load %arg1[%arg5 * 256 + 239] {partition_indices = [239], timing = #hlscpp.t<235 -> 237, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %622 = arith.mulf %621, %612 {timing = #hlscpp.t<237 -> 241, 4, 1>} : f64
    %623 = arith.addf %610, %622 {timing = #hlscpp.t<241 -> 246, 5, 1>} : f64
    %624 = affine.load %arg1[%arg5 * 256 + 48] {partition_indices = [48], timing = #hlscpp.t<240 -> 242, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %625 = affine.load %arg3[48] {partition_indices = [48], timing = #hlscpp.t<240 -> 242, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %626 = arith.mulf %624, %625 {timing = #hlscpp.t<242 -> 246, 4, 1>} : f64
    %627 = arith.addf %614, %626 {timing = #hlscpp.t<246 -> 251, 5, 1>} : f64
    %628 = affine.load %arg1[%arg5 * 256 + 112] {partition_indices = [112], timing = #hlscpp.t<240 -> 242, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %629 = arith.mulf %628, %625 {timing = #hlscpp.t<242 -> 246, 4, 1>} : f64
    %630 = arith.addf %617, %629 {timing = #hlscpp.t<246 -> 251, 5, 1>} : f64
    %631 = affine.load %arg1[%arg5 * 256 + 176] {partition_indices = [176], timing = #hlscpp.t<240 -> 242, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %632 = arith.mulf %631, %625 {timing = #hlscpp.t<242 -> 246, 4, 1>} : f64
    %633 = arith.addf %620, %632 {timing = #hlscpp.t<246 -> 251, 5, 1>} : f64
    %634 = affine.load %arg1[%arg5 * 256 + 240] {partition_indices = [240], timing = #hlscpp.t<240 -> 242, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %635 = arith.mulf %634, %625 {timing = #hlscpp.t<242 -> 246, 4, 1>} : f64
    %636 = arith.addf %623, %635 {timing = #hlscpp.t<246 -> 251, 5, 1>} : f64
    %637 = affine.load %arg1[%arg5 * 256 + 49] {partition_indices = [49], timing = #hlscpp.t<245 -> 247, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %638 = affine.load %arg3[49] {partition_indices = [49], timing = #hlscpp.t<245 -> 247, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %639 = arith.mulf %637, %638 {timing = #hlscpp.t<247 -> 251, 4, 1>} : f64
    %640 = arith.addf %627, %639 {timing = #hlscpp.t<251 -> 256, 5, 1>} : f64
    %641 = affine.load %arg1[%arg5 * 256 + 113] {partition_indices = [113], timing = #hlscpp.t<245 -> 247, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %642 = arith.mulf %641, %638 {timing = #hlscpp.t<247 -> 251, 4, 1>} : f64
    %643 = arith.addf %630, %642 {timing = #hlscpp.t<251 -> 256, 5, 1>} : f64
    %644 = affine.load %arg1[%arg5 * 256 + 177] {partition_indices = [177], timing = #hlscpp.t<245 -> 247, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %645 = arith.mulf %644, %638 {timing = #hlscpp.t<247 -> 251, 4, 1>} : f64
    %646 = arith.addf %633, %645 {timing = #hlscpp.t<251 -> 256, 5, 1>} : f64
    %647 = affine.load %arg1[%arg5 * 256 + 241] {partition_indices = [241], timing = #hlscpp.t<245 -> 247, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %648 = arith.mulf %647, %638 {timing = #hlscpp.t<247 -> 251, 4, 1>} : f64
    %649 = arith.addf %636, %648 {timing = #hlscpp.t<251 -> 256, 5, 1>} : f64
    %650 = affine.load %arg1[%arg5 * 256 + 50] {partition_indices = [50], timing = #hlscpp.t<250 -> 252, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %651 = affine.load %arg3[50] {partition_indices = [50], timing = #hlscpp.t<250 -> 252, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %652 = arith.mulf %650, %651 {timing = #hlscpp.t<252 -> 256, 4, 1>} : f64
    %653 = arith.addf %640, %652 {timing = #hlscpp.t<256 -> 261, 5, 1>} : f64
    %654 = affine.load %arg1[%arg5 * 256 + 114] {partition_indices = [114], timing = #hlscpp.t<250 -> 252, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %655 = arith.mulf %654, %651 {timing = #hlscpp.t<252 -> 256, 4, 1>} : f64
    %656 = arith.addf %643, %655 {timing = #hlscpp.t<256 -> 261, 5, 1>} : f64
    %657 = affine.load %arg1[%arg5 * 256 + 178] {partition_indices = [178], timing = #hlscpp.t<250 -> 252, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %658 = arith.mulf %657, %651 {timing = #hlscpp.t<252 -> 256, 4, 1>} : f64
    %659 = arith.addf %646, %658 {timing = #hlscpp.t<256 -> 261, 5, 1>} : f64
    %660 = affine.load %arg1[%arg5 * 256 + 242] {partition_indices = [242], timing = #hlscpp.t<250 -> 252, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %661 = arith.mulf %660, %651 {timing = #hlscpp.t<252 -> 256, 4, 1>} : f64
    %662 = arith.addf %649, %661 {timing = #hlscpp.t<256 -> 261, 5, 1>} : f64
    %663 = affine.load %arg1[%arg5 * 256 + 51] {partition_indices = [51], timing = #hlscpp.t<255 -> 257, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %664 = affine.load %arg3[51] {partition_indices = [51], timing = #hlscpp.t<255 -> 257, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %665 = arith.mulf %663, %664 {timing = #hlscpp.t<257 -> 261, 4, 1>} : f64
    %666 = arith.addf %653, %665 {timing = #hlscpp.t<261 -> 266, 5, 1>} : f64
    %667 = affine.load %arg1[%arg5 * 256 + 115] {partition_indices = [115], timing = #hlscpp.t<255 -> 257, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %668 = arith.mulf %667, %664 {timing = #hlscpp.t<257 -> 261, 4, 1>} : f64
    %669 = arith.addf %656, %668 {timing = #hlscpp.t<261 -> 266, 5, 1>} : f64
    %670 = affine.load %arg1[%arg5 * 256 + 179] {partition_indices = [179], timing = #hlscpp.t<255 -> 257, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %671 = arith.mulf %670, %664 {timing = #hlscpp.t<257 -> 261, 4, 1>} : f64
    %672 = arith.addf %659, %671 {timing = #hlscpp.t<261 -> 266, 5, 1>} : f64
    %673 = affine.load %arg1[%arg5 * 256 + 243] {partition_indices = [243], timing = #hlscpp.t<255 -> 257, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %674 = arith.mulf %673, %664 {timing = #hlscpp.t<257 -> 261, 4, 1>} : f64
    %675 = arith.addf %662, %674 {timing = #hlscpp.t<261 -> 266, 5, 1>} : f64
    %676 = affine.load %arg1[%arg5 * 256 + 52] {partition_indices = [52], timing = #hlscpp.t<260 -> 262, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %677 = affine.load %arg3[52] {partition_indices = [52], timing = #hlscpp.t<260 -> 262, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %678 = arith.mulf %676, %677 {timing = #hlscpp.t<262 -> 266, 4, 1>} : f64
    %679 = arith.addf %666, %678 {timing = #hlscpp.t<266 -> 271, 5, 1>} : f64
    %680 = affine.load %arg1[%arg5 * 256 + 116] {partition_indices = [116], timing = #hlscpp.t<260 -> 262, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %681 = arith.mulf %680, %677 {timing = #hlscpp.t<262 -> 266, 4, 1>} : f64
    %682 = arith.addf %669, %681 {timing = #hlscpp.t<266 -> 271, 5, 1>} : f64
    %683 = affine.load %arg1[%arg5 * 256 + 180] {partition_indices = [180], timing = #hlscpp.t<260 -> 262, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %684 = arith.mulf %683, %677 {timing = #hlscpp.t<262 -> 266, 4, 1>} : f64
    %685 = arith.addf %672, %684 {timing = #hlscpp.t<266 -> 271, 5, 1>} : f64
    %686 = affine.load %arg1[%arg5 * 256 + 244] {partition_indices = [244], timing = #hlscpp.t<260 -> 262, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %687 = arith.mulf %686, %677 {timing = #hlscpp.t<262 -> 266, 4, 1>} : f64
    %688 = arith.addf %675, %687 {timing = #hlscpp.t<266 -> 271, 5, 1>} : f64
    %689 = affine.load %arg1[%arg5 * 256 + 53] {partition_indices = [53], timing = #hlscpp.t<265 -> 267, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %690 = affine.load %arg3[53] {partition_indices = [53], timing = #hlscpp.t<265 -> 267, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %691 = arith.mulf %689, %690 {timing = #hlscpp.t<267 -> 271, 4, 1>} : f64
    %692 = arith.addf %679, %691 {timing = #hlscpp.t<271 -> 276, 5, 1>} : f64
    %693 = affine.load %arg1[%arg5 * 256 + 117] {partition_indices = [117], timing = #hlscpp.t<265 -> 267, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %694 = arith.mulf %693, %690 {timing = #hlscpp.t<267 -> 271, 4, 1>} : f64
    %695 = arith.addf %682, %694 {timing = #hlscpp.t<271 -> 276, 5, 1>} : f64
    %696 = affine.load %arg1[%arg5 * 256 + 181] {partition_indices = [181], timing = #hlscpp.t<265 -> 267, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %697 = arith.mulf %696, %690 {timing = #hlscpp.t<267 -> 271, 4, 1>} : f64
    %698 = arith.addf %685, %697 {timing = #hlscpp.t<271 -> 276, 5, 1>} : f64
    %699 = affine.load %arg1[%arg5 * 256 + 245] {partition_indices = [245], timing = #hlscpp.t<265 -> 267, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %700 = arith.mulf %699, %690 {timing = #hlscpp.t<267 -> 271, 4, 1>} : f64
    %701 = arith.addf %688, %700 {timing = #hlscpp.t<271 -> 276, 5, 1>} : f64
    %702 = affine.load %arg1[%arg5 * 256 + 54] {partition_indices = [54], timing = #hlscpp.t<270 -> 272, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %703 = affine.load %arg3[54] {partition_indices = [54], timing = #hlscpp.t<270 -> 272, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %704 = arith.mulf %702, %703 {timing = #hlscpp.t<272 -> 276, 4, 1>} : f64
    %705 = arith.addf %692, %704 {timing = #hlscpp.t<276 -> 281, 5, 1>} : f64
    %706 = affine.load %arg1[%arg5 * 256 + 118] {partition_indices = [118], timing = #hlscpp.t<270 -> 272, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %707 = arith.mulf %706, %703 {timing = #hlscpp.t<272 -> 276, 4, 1>} : f64
    %708 = arith.addf %695, %707 {timing = #hlscpp.t<276 -> 281, 5, 1>} : f64
    %709 = affine.load %arg1[%arg5 * 256 + 182] {partition_indices = [182], timing = #hlscpp.t<270 -> 272, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %710 = arith.mulf %709, %703 {timing = #hlscpp.t<272 -> 276, 4, 1>} : f64
    %711 = arith.addf %698, %710 {timing = #hlscpp.t<276 -> 281, 5, 1>} : f64
    %712 = affine.load %arg1[%arg5 * 256 + 246] {partition_indices = [246], timing = #hlscpp.t<270 -> 272, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %713 = arith.mulf %712, %703 {timing = #hlscpp.t<272 -> 276, 4, 1>} : f64
    %714 = arith.addf %701, %713 {timing = #hlscpp.t<276 -> 281, 5, 1>} : f64
    %715 = affine.load %arg1[%arg5 * 256 + 55] {partition_indices = [55], timing = #hlscpp.t<275 -> 277, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %716 = affine.load %arg3[55] {partition_indices = [55], timing = #hlscpp.t<275 -> 277, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %717 = arith.mulf %715, %716 {timing = #hlscpp.t<277 -> 281, 4, 1>} : f64
    %718 = arith.addf %705, %717 {timing = #hlscpp.t<281 -> 286, 5, 1>} : f64
    %719 = affine.load %arg1[%arg5 * 256 + 119] {partition_indices = [119], timing = #hlscpp.t<275 -> 277, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %720 = arith.mulf %719, %716 {timing = #hlscpp.t<277 -> 281, 4, 1>} : f64
    %721 = arith.addf %708, %720 {timing = #hlscpp.t<281 -> 286, 5, 1>} : f64
    %722 = affine.load %arg1[%arg5 * 256 + 183] {partition_indices = [183], timing = #hlscpp.t<275 -> 277, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %723 = arith.mulf %722, %716 {timing = #hlscpp.t<277 -> 281, 4, 1>} : f64
    %724 = arith.addf %711, %723 {timing = #hlscpp.t<281 -> 286, 5, 1>} : f64
    %725 = affine.load %arg1[%arg5 * 256 + 247] {partition_indices = [247], timing = #hlscpp.t<275 -> 277, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %726 = arith.mulf %725, %716 {timing = #hlscpp.t<277 -> 281, 4, 1>} : f64
    %727 = arith.addf %714, %726 {timing = #hlscpp.t<281 -> 286, 5, 1>} : f64
    %728 = affine.load %arg1[%arg5 * 256 + 56] {partition_indices = [56], timing = #hlscpp.t<280 -> 282, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %729 = affine.load %arg3[56] {partition_indices = [56], timing = #hlscpp.t<280 -> 282, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %730 = arith.mulf %728, %729 {timing = #hlscpp.t<282 -> 286, 4, 1>} : f64
    %731 = arith.addf %718, %730 {timing = #hlscpp.t<286 -> 291, 5, 1>} : f64
    %732 = affine.load %arg1[%arg5 * 256 + 120] {partition_indices = [120], timing = #hlscpp.t<280 -> 282, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %733 = arith.mulf %732, %729 {timing = #hlscpp.t<282 -> 286, 4, 1>} : f64
    %734 = arith.addf %721, %733 {timing = #hlscpp.t<286 -> 291, 5, 1>} : f64
    %735 = affine.load %arg1[%arg5 * 256 + 184] {partition_indices = [184], timing = #hlscpp.t<280 -> 282, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %736 = arith.mulf %735, %729 {timing = #hlscpp.t<282 -> 286, 4, 1>} : f64
    %737 = arith.addf %724, %736 {timing = #hlscpp.t<286 -> 291, 5, 1>} : f64
    %738 = affine.load %arg1[%arg5 * 256 + 248] {partition_indices = [248], timing = #hlscpp.t<280 -> 282, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %739 = arith.mulf %738, %729 {timing = #hlscpp.t<282 -> 286, 4, 1>} : f64
    %740 = arith.addf %727, %739 {timing = #hlscpp.t<286 -> 291, 5, 1>} : f64
    %741 = affine.load %arg1[%arg5 * 256 + 57] {partition_indices = [57], timing = #hlscpp.t<285 -> 287, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %742 = affine.load %arg3[57] {partition_indices = [57], timing = #hlscpp.t<285 -> 287, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %743 = arith.mulf %741, %742 {timing = #hlscpp.t<287 -> 291, 4, 1>} : f64
    %744 = arith.addf %731, %743 {timing = #hlscpp.t<291 -> 296, 5, 1>} : f64
    %745 = affine.load %arg1[%arg5 * 256 + 121] {partition_indices = [121], timing = #hlscpp.t<285 -> 287, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %746 = arith.mulf %745, %742 {timing = #hlscpp.t<287 -> 291, 4, 1>} : f64
    %747 = arith.addf %734, %746 {timing = #hlscpp.t<291 -> 296, 5, 1>} : f64
    %748 = affine.load %arg1[%arg5 * 256 + 185] {partition_indices = [185], timing = #hlscpp.t<285 -> 287, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %749 = arith.mulf %748, %742 {timing = #hlscpp.t<287 -> 291, 4, 1>} : f64
    %750 = arith.addf %737, %749 {timing = #hlscpp.t<291 -> 296, 5, 1>} : f64
    %751 = affine.load %arg1[%arg5 * 256 + 249] {partition_indices = [249], timing = #hlscpp.t<285 -> 287, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %752 = arith.mulf %751, %742 {timing = #hlscpp.t<287 -> 291, 4, 1>} : f64
    %753 = arith.addf %740, %752 {timing = #hlscpp.t<291 -> 296, 5, 1>} : f64
    %754 = affine.load %arg1[%arg5 * 256 + 58] {partition_indices = [58], timing = #hlscpp.t<290 -> 292, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %755 = affine.load %arg3[58] {partition_indices = [58], timing = #hlscpp.t<290 -> 292, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %756 = arith.mulf %754, %755 {timing = #hlscpp.t<292 -> 296, 4, 1>} : f64
    %757 = arith.addf %744, %756 {timing = #hlscpp.t<296 -> 301, 5, 1>} : f64
    %758 = affine.load %arg1[%arg5 * 256 + 122] {partition_indices = [122], timing = #hlscpp.t<290 -> 292, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %759 = arith.mulf %758, %755 {timing = #hlscpp.t<292 -> 296, 4, 1>} : f64
    %760 = arith.addf %747, %759 {timing = #hlscpp.t<296 -> 301, 5, 1>} : f64
    %761 = affine.load %arg1[%arg5 * 256 + 186] {partition_indices = [186], timing = #hlscpp.t<290 -> 292, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %762 = arith.mulf %761, %755 {timing = #hlscpp.t<292 -> 296, 4, 1>} : f64
    %763 = arith.addf %750, %762 {timing = #hlscpp.t<296 -> 301, 5, 1>} : f64
    %764 = affine.load %arg1[%arg5 * 256 + 250] {partition_indices = [250], timing = #hlscpp.t<290 -> 292, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %765 = arith.mulf %764, %755 {timing = #hlscpp.t<292 -> 296, 4, 1>} : f64
    %766 = arith.addf %753, %765 {timing = #hlscpp.t<296 -> 301, 5, 1>} : f64
    %767 = affine.load %arg1[%arg5 * 256 + 59] {partition_indices = [59], timing = #hlscpp.t<295 -> 297, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %768 = affine.load %arg3[59] {partition_indices = [59], timing = #hlscpp.t<295 -> 297, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %769 = arith.mulf %767, %768 {timing = #hlscpp.t<297 -> 301, 4, 1>} : f64
    %770 = arith.addf %757, %769 {timing = #hlscpp.t<301 -> 306, 5, 1>} : f64
    %771 = affine.load %arg1[%arg5 * 256 + 123] {partition_indices = [123], timing = #hlscpp.t<295 -> 297, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %772 = arith.mulf %771, %768 {timing = #hlscpp.t<297 -> 301, 4, 1>} : f64
    %773 = arith.addf %760, %772 {timing = #hlscpp.t<301 -> 306, 5, 1>} : f64
    %774 = affine.load %arg1[%arg5 * 256 + 187] {partition_indices = [187], timing = #hlscpp.t<295 -> 297, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %775 = arith.mulf %774, %768 {timing = #hlscpp.t<297 -> 301, 4, 1>} : f64
    %776 = arith.addf %763, %775 {timing = #hlscpp.t<301 -> 306, 5, 1>} : f64
    %777 = affine.load %arg1[%arg5 * 256 + 251] {partition_indices = [251], timing = #hlscpp.t<295 -> 297, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %778 = arith.mulf %777, %768 {timing = #hlscpp.t<297 -> 301, 4, 1>} : f64
    %779 = arith.addf %766, %778 {timing = #hlscpp.t<301 -> 306, 5, 1>} : f64
    %780 = affine.load %arg1[%arg5 * 256 + 60] {partition_indices = [60], timing = #hlscpp.t<300 -> 302, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %781 = affine.load %arg3[60] {partition_indices = [60], timing = #hlscpp.t<300 -> 302, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %782 = arith.mulf %780, %781 {timing = #hlscpp.t<302 -> 306, 4, 1>} : f64
    %783 = arith.addf %770, %782 {timing = #hlscpp.t<306 -> 311, 5, 1>} : f64
    %784 = affine.load %arg1[%arg5 * 256 + 124] {partition_indices = [124], timing = #hlscpp.t<300 -> 302, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %785 = arith.mulf %784, %781 {timing = #hlscpp.t<302 -> 306, 4, 1>} : f64
    %786 = arith.addf %773, %785 {timing = #hlscpp.t<306 -> 311, 5, 1>} : f64
    %787 = affine.load %arg1[%arg5 * 256 + 188] {partition_indices = [188], timing = #hlscpp.t<300 -> 302, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %788 = arith.mulf %787, %781 {timing = #hlscpp.t<302 -> 306, 4, 1>} : f64
    %789 = arith.addf %776, %788 {timing = #hlscpp.t<306 -> 311, 5, 1>} : f64
    %790 = affine.load %arg1[%arg5 * 256 + 252] {partition_indices = [252], timing = #hlscpp.t<300 -> 302, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %791 = arith.mulf %790, %781 {timing = #hlscpp.t<302 -> 306, 4, 1>} : f64
    %792 = arith.addf %779, %791 {timing = #hlscpp.t<306 -> 311, 5, 1>} : f64
    %793 = affine.load %arg1[%arg5 * 256 + 61] {partition_indices = [61], timing = #hlscpp.t<305 -> 307, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %794 = affine.load %arg3[61] {partition_indices = [61], timing = #hlscpp.t<305 -> 307, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %795 = arith.mulf %793, %794 {timing = #hlscpp.t<307 -> 311, 4, 1>} : f64
    %796 = arith.addf %783, %795 {timing = #hlscpp.t<311 -> 316, 5, 1>} : f64
    %797 = affine.load %arg1[%arg5 * 256 + 125] {partition_indices = [125], timing = #hlscpp.t<305 -> 307, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %798 = arith.mulf %797, %794 {timing = #hlscpp.t<307 -> 311, 4, 1>} : f64
    %799 = arith.addf %786, %798 {timing = #hlscpp.t<311 -> 316, 5, 1>} : f64
    %800 = affine.load %arg1[%arg5 * 256 + 189] {partition_indices = [189], timing = #hlscpp.t<305 -> 307, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %801 = arith.mulf %800, %794 {timing = #hlscpp.t<307 -> 311, 4, 1>} : f64
    %802 = arith.addf %789, %801 {timing = #hlscpp.t<311 -> 316, 5, 1>} : f64
    %803 = affine.load %arg1[%arg5 * 256 + 253] {partition_indices = [253], timing = #hlscpp.t<305 -> 307, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %804 = arith.mulf %803, %794 {timing = #hlscpp.t<307 -> 311, 4, 1>} : f64
    %805 = arith.addf %792, %804 {timing = #hlscpp.t<311 -> 316, 5, 1>} : f64
    %806 = affine.load %arg1[%arg5 * 256 + 62] {partition_indices = [62], timing = #hlscpp.t<310 -> 312, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %807 = affine.load %arg3[62] {partition_indices = [62], timing = #hlscpp.t<310 -> 312, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %808 = arith.mulf %806, %807 {timing = #hlscpp.t<312 -> 316, 4, 1>} : f64
    %809 = arith.addf %796, %808 {timing = #hlscpp.t<316 -> 321, 5, 1>} : f64
    %810 = affine.load %arg1[%arg5 * 256 + 126] {partition_indices = [126], timing = #hlscpp.t<310 -> 312, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %811 = arith.mulf %810, %807 {timing = #hlscpp.t<312 -> 316, 4, 1>} : f64
    %812 = arith.addf %799, %811 {timing = #hlscpp.t<316 -> 321, 5, 1>} : f64
    %813 = affine.load %arg1[%arg5 * 256 + 190] {partition_indices = [190], timing = #hlscpp.t<310 -> 312, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %814 = arith.mulf %813, %807 {timing = #hlscpp.t<312 -> 316, 4, 1>} : f64
    %815 = arith.addf %802, %814 {timing = #hlscpp.t<316 -> 321, 5, 1>} : f64
    %816 = affine.load %arg1[%arg5 * 256 + 254] {partition_indices = [254], timing = #hlscpp.t<310 -> 312, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %817 = arith.mulf %816, %807 {timing = #hlscpp.t<312 -> 316, 4, 1>} : f64
    %818 = arith.addf %805, %817 {timing = #hlscpp.t<316 -> 321, 5, 1>} : f64
    %819 = affine.load %arg1[%arg5 * 256 + 63] {partition_indices = [63], timing = #hlscpp.t<315 -> 317, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %820 = affine.load %arg3[63] {partition_indices = [63], timing = #hlscpp.t<315 -> 317, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %821 = arith.mulf %819, %820 {timing = #hlscpp.t<317 -> 321, 4, 1>} : f64
    %822 = arith.addf %809, %821 {timing = #hlscpp.t<321 -> 326, 5, 1>} : f64
    affine.store %822, %arg2[%arg5 * 4] {partition_indices = [0], timing = #hlscpp.t<326 -> 327, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 4, d0 floordiv 4)>, 1>
    %823 = affine.load %arg1[%arg5 * 256 + 127] {partition_indices = [127], timing = #hlscpp.t<315 -> 317, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %824 = arith.mulf %823, %820 {timing = #hlscpp.t<317 -> 321, 4, 1>} : f64
    %825 = arith.addf %812, %824 {timing = #hlscpp.t<321 -> 326, 5, 1>} : f64
    affine.store %825, %arg2[%arg5 * 4 + 1] {partition_indices = [1], timing = #hlscpp.t<326 -> 327, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 4, d0 floordiv 4)>, 1>
    %826 = affine.load %arg1[%arg5 * 256 + 191] {partition_indices = [191], timing = #hlscpp.t<315 -> 317, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %827 = arith.mulf %826, %820 {timing = #hlscpp.t<317 -> 321, 4, 1>} : f64
    %828 = arith.addf %815, %827 {timing = #hlscpp.t<321 -> 326, 5, 1>} : f64
    affine.store %828, %arg2[%arg5 * 4 + 2] {partition_indices = [2], timing = #hlscpp.t<326 -> 327, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 4, d0 floordiv 4)>, 1>
    %829 = affine.load %arg1[%arg5 * 256 + 255] {partition_indices = [255], timing = #hlscpp.t<315 -> 317, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %830 = arith.mulf %829, %820 {timing = #hlscpp.t<317 -> 321, 4, 1>} : f64
    %831 = arith.addf %818, %830 {timing = #hlscpp.t<321 -> 326, 5, 1>} : f64
    affine.store %831, %arg2[%arg5 * 4 + 3] {partition_indices = [3], timing = #hlscpp.t<326 -> 327, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 4, d0 floordiv 4)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=4, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=16, iterLatency=327, minII=4>, timing = #hlscpp.t<0 -> 389, 389, 389>}
  affine.store %cst, %arg4[0] {partition_indices = [0], timing = #hlscpp.t<389 -> 390, 1, 1>} : memref<1xf64, 1>
  return {timing = #hlscpp.t<390 -> 390, 0, 0>}
}
