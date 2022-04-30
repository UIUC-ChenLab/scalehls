func @get_oracle_activations1(%arg0: memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>, %arg1: memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>, %arg2: memref<64xf64, affine_map<(d0) -> (d0 mod 2, d0 floordiv 2)>, 1>, %arg3: memref<64xf64, affine_map<(d0) -> (d0 mod 2, d0 floordiv 2)>, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>, llvm.linkage = #llvm.linkage<external>, resource = #hlscpp.r<lut=0, dsp=323, bram=0>, timing = #hlscpp.t<0 -> 397, 397, 397>} {
  %cst = arith.constant {timing = #hlscpp.t<0 -> 0, 0, 0>} 0.000000e+00 : f64
  affine.for %arg4 = 0 to 32 {
    %0 = affine.load %arg1[0] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %1 = affine.load %arg0[%arg4 * 128] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %2 = arith.mulf %0, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %3 = arith.addf %2, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %4 = affine.load %arg3[%arg4 * 2] {partition_indices = [0], timing = #hlscpp.t<324 -> 326, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 2, d0 floordiv 2)>, 1>
    %5 = affine.load %arg0[%arg4 * 128 + 64] {partition_indices = [64], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %6 = arith.mulf %0, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %7 = arith.addf %6, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %8 = affine.load %arg3[%arg4 * 2 + 1] {partition_indices = [1], timing = #hlscpp.t<324 -> 326, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 2, d0 floordiv 2)>, 1>
    %9 = affine.load %arg1[1] {partition_indices = [1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %10 = affine.load %arg0[%arg4 * 128 + 1] {partition_indices = [1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %11 = arith.mulf %9, %10 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %12 = arith.addf %3, %11 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %13 = affine.load %arg0[%arg4 * 128 + 65] {partition_indices = [65], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %14 = arith.mulf %9, %13 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %15 = arith.addf %7, %14 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %16 = affine.load %arg1[2] {partition_indices = [2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %17 = affine.load %arg0[%arg4 * 128 + 2] {partition_indices = [2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %18 = arith.mulf %16, %17 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %19 = arith.addf %12, %18 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %20 = affine.load %arg0[%arg4 * 128 + 66] {partition_indices = [66], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %21 = arith.mulf %16, %20 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %22 = arith.addf %15, %21 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %23 = affine.load %arg1[3] {partition_indices = [3], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %24 = affine.load %arg0[%arg4 * 128 + 3] {partition_indices = [3], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %25 = arith.mulf %23, %24 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f64
    %26 = arith.addf %19, %25 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f64
    %27 = affine.load %arg0[%arg4 * 128 + 67] {partition_indices = [67], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %28 = arith.mulf %23, %27 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f64
    %29 = arith.addf %22, %28 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f64
    %30 = affine.load %arg1[4] {partition_indices = [4], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %31 = affine.load %arg0[%arg4 * 128 + 4] {partition_indices = [4], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %32 = arith.mulf %30, %31 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f64
    %33 = arith.addf %26, %32 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f64
    %34 = affine.load %arg0[%arg4 * 128 + 68] {partition_indices = [68], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %35 = arith.mulf %30, %34 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f64
    %36 = arith.addf %29, %35 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f64
    %37 = affine.load %arg1[5] {partition_indices = [5], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %38 = affine.load %arg0[%arg4 * 128 + 5] {partition_indices = [5], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %39 = arith.mulf %37, %38 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f64
    %40 = arith.addf %33, %39 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f64
    %41 = affine.load %arg0[%arg4 * 128 + 69] {partition_indices = [69], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %42 = arith.mulf %37, %41 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f64
    %43 = arith.addf %36, %42 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f64
    %44 = affine.load %arg1[6] {partition_indices = [6], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %45 = affine.load %arg0[%arg4 * 128 + 6] {partition_indices = [6], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %46 = arith.mulf %44, %45 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f64
    %47 = arith.addf %40, %46 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f64
    %48 = affine.load %arg0[%arg4 * 128 + 70] {partition_indices = [70], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %49 = arith.mulf %44, %48 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f64
    %50 = arith.addf %43, %49 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f64
    %51 = affine.load %arg1[7] {partition_indices = [7], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %52 = affine.load %arg0[%arg4 * 128 + 7] {partition_indices = [7], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %53 = arith.mulf %51, %52 {timing = #hlscpp.t<37 -> 41, 4, 1>} : f64
    %54 = arith.addf %47, %53 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f64
    %55 = affine.load %arg0[%arg4 * 128 + 71] {partition_indices = [71], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %56 = arith.mulf %51, %55 {timing = #hlscpp.t<37 -> 41, 4, 1>} : f64
    %57 = arith.addf %50, %56 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f64
    %58 = affine.load %arg1[8] {partition_indices = [8], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %59 = affine.load %arg0[%arg4 * 128 + 8] {partition_indices = [8], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %60 = arith.mulf %58, %59 {timing = #hlscpp.t<42 -> 46, 4, 1>} : f64
    %61 = arith.addf %54, %60 {timing = #hlscpp.t<46 -> 51, 5, 1>} : f64
    %62 = affine.load %arg0[%arg4 * 128 + 72] {partition_indices = [72], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %63 = arith.mulf %58, %62 {timing = #hlscpp.t<42 -> 46, 4, 1>} : f64
    %64 = arith.addf %57, %63 {timing = #hlscpp.t<46 -> 51, 5, 1>} : f64
    %65 = affine.load %arg1[9] {partition_indices = [9], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %66 = affine.load %arg0[%arg4 * 128 + 9] {partition_indices = [9], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %67 = arith.mulf %65, %66 {timing = #hlscpp.t<47 -> 51, 4, 1>} : f64
    %68 = arith.addf %61, %67 {timing = #hlscpp.t<51 -> 56, 5, 1>} : f64
    %69 = affine.load %arg0[%arg4 * 128 + 73] {partition_indices = [73], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %70 = arith.mulf %65, %69 {timing = #hlscpp.t<47 -> 51, 4, 1>} : f64
    %71 = arith.addf %64, %70 {timing = #hlscpp.t<51 -> 56, 5, 1>} : f64
    %72 = affine.load %arg1[10] {partition_indices = [10], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %73 = affine.load %arg0[%arg4 * 128 + 10] {partition_indices = [10], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %74 = arith.mulf %72, %73 {timing = #hlscpp.t<52 -> 56, 4, 1>} : f64
    %75 = arith.addf %68, %74 {timing = #hlscpp.t<56 -> 61, 5, 1>} : f64
    %76 = affine.load %arg0[%arg4 * 128 + 74] {partition_indices = [74], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %77 = arith.mulf %72, %76 {timing = #hlscpp.t<52 -> 56, 4, 1>} : f64
    %78 = arith.addf %71, %77 {timing = #hlscpp.t<56 -> 61, 5, 1>} : f64
    %79 = affine.load %arg1[11] {partition_indices = [11], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %80 = affine.load %arg0[%arg4 * 128 + 11] {partition_indices = [11], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %81 = arith.mulf %79, %80 {timing = #hlscpp.t<57 -> 61, 4, 1>} : f64
    %82 = arith.addf %75, %81 {timing = #hlscpp.t<61 -> 66, 5, 1>} : f64
    %83 = affine.load %arg0[%arg4 * 128 + 75] {partition_indices = [75], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %84 = arith.mulf %79, %83 {timing = #hlscpp.t<57 -> 61, 4, 1>} : f64
    %85 = arith.addf %78, %84 {timing = #hlscpp.t<61 -> 66, 5, 1>} : f64
    %86 = affine.load %arg1[12] {partition_indices = [12], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %87 = affine.load %arg0[%arg4 * 128 + 12] {partition_indices = [12], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %88 = arith.mulf %86, %87 {timing = #hlscpp.t<62 -> 66, 4, 1>} : f64
    %89 = arith.addf %82, %88 {timing = #hlscpp.t<66 -> 71, 5, 1>} : f64
    %90 = affine.load %arg0[%arg4 * 128 + 76] {partition_indices = [76], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %91 = arith.mulf %86, %90 {timing = #hlscpp.t<62 -> 66, 4, 1>} : f64
    %92 = arith.addf %85, %91 {timing = #hlscpp.t<66 -> 71, 5, 1>} : f64
    %93 = affine.load %arg1[13] {partition_indices = [13], timing = #hlscpp.t<65 -> 67, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %94 = affine.load %arg0[%arg4 * 128 + 13] {partition_indices = [13], timing = #hlscpp.t<65 -> 67, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %95 = arith.mulf %93, %94 {timing = #hlscpp.t<67 -> 71, 4, 1>} : f64
    %96 = arith.addf %89, %95 {timing = #hlscpp.t<71 -> 76, 5, 1>} : f64
    %97 = affine.load %arg0[%arg4 * 128 + 77] {partition_indices = [77], timing = #hlscpp.t<65 -> 67, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %98 = arith.mulf %93, %97 {timing = #hlscpp.t<67 -> 71, 4, 1>} : f64
    %99 = arith.addf %92, %98 {timing = #hlscpp.t<71 -> 76, 5, 1>} : f64
    %100 = affine.load %arg1[14] {partition_indices = [14], timing = #hlscpp.t<70 -> 72, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %101 = affine.load %arg0[%arg4 * 128 + 14] {partition_indices = [14], timing = #hlscpp.t<70 -> 72, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %102 = arith.mulf %100, %101 {timing = #hlscpp.t<72 -> 76, 4, 1>} : f64
    %103 = arith.addf %96, %102 {timing = #hlscpp.t<76 -> 81, 5, 1>} : f64
    %104 = affine.load %arg0[%arg4 * 128 + 78] {partition_indices = [78], timing = #hlscpp.t<70 -> 72, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %105 = arith.mulf %100, %104 {timing = #hlscpp.t<72 -> 76, 4, 1>} : f64
    %106 = arith.addf %99, %105 {timing = #hlscpp.t<76 -> 81, 5, 1>} : f64
    %107 = affine.load %arg1[15] {partition_indices = [15], timing = #hlscpp.t<75 -> 77, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %108 = affine.load %arg0[%arg4 * 128 + 15] {partition_indices = [15], timing = #hlscpp.t<75 -> 77, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %109 = arith.mulf %107, %108 {timing = #hlscpp.t<77 -> 81, 4, 1>} : f64
    %110 = arith.addf %103, %109 {timing = #hlscpp.t<81 -> 86, 5, 1>} : f64
    %111 = affine.load %arg0[%arg4 * 128 + 79] {partition_indices = [79], timing = #hlscpp.t<75 -> 77, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %112 = arith.mulf %107, %111 {timing = #hlscpp.t<77 -> 81, 4, 1>} : f64
    %113 = arith.addf %106, %112 {timing = #hlscpp.t<81 -> 86, 5, 1>} : f64
    %114 = affine.load %arg1[16] {partition_indices = [16], timing = #hlscpp.t<80 -> 82, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %115 = affine.load %arg0[%arg4 * 128 + 16] {partition_indices = [16], timing = #hlscpp.t<80 -> 82, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %116 = arith.mulf %114, %115 {timing = #hlscpp.t<82 -> 86, 4, 1>} : f64
    %117 = arith.addf %110, %116 {timing = #hlscpp.t<86 -> 91, 5, 1>} : f64
    %118 = affine.load %arg0[%arg4 * 128 + 80] {partition_indices = [80], timing = #hlscpp.t<80 -> 82, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %119 = arith.mulf %114, %118 {timing = #hlscpp.t<82 -> 86, 4, 1>} : f64
    %120 = arith.addf %113, %119 {timing = #hlscpp.t<86 -> 91, 5, 1>} : f64
    %121 = affine.load %arg1[17] {partition_indices = [17], timing = #hlscpp.t<85 -> 87, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %122 = affine.load %arg0[%arg4 * 128 + 17] {partition_indices = [17], timing = #hlscpp.t<85 -> 87, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %123 = arith.mulf %121, %122 {timing = #hlscpp.t<87 -> 91, 4, 1>} : f64
    %124 = arith.addf %117, %123 {timing = #hlscpp.t<91 -> 96, 5, 1>} : f64
    %125 = affine.load %arg0[%arg4 * 128 + 81] {partition_indices = [81], timing = #hlscpp.t<85 -> 87, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %126 = arith.mulf %121, %125 {timing = #hlscpp.t<87 -> 91, 4, 1>} : f64
    %127 = arith.addf %120, %126 {timing = #hlscpp.t<91 -> 96, 5, 1>} : f64
    %128 = affine.load %arg1[18] {partition_indices = [18], timing = #hlscpp.t<90 -> 92, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %129 = affine.load %arg0[%arg4 * 128 + 18] {partition_indices = [18], timing = #hlscpp.t<90 -> 92, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %130 = arith.mulf %128, %129 {timing = #hlscpp.t<92 -> 96, 4, 1>} : f64
    %131 = arith.addf %124, %130 {timing = #hlscpp.t<96 -> 101, 5, 1>} : f64
    %132 = affine.load %arg0[%arg4 * 128 + 82] {partition_indices = [82], timing = #hlscpp.t<90 -> 92, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %133 = arith.mulf %128, %132 {timing = #hlscpp.t<92 -> 96, 4, 1>} : f64
    %134 = arith.addf %127, %133 {timing = #hlscpp.t<96 -> 101, 5, 1>} : f64
    %135 = affine.load %arg1[19] {partition_indices = [19], timing = #hlscpp.t<95 -> 97, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %136 = affine.load %arg0[%arg4 * 128 + 19] {partition_indices = [19], timing = #hlscpp.t<95 -> 97, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %137 = arith.mulf %135, %136 {timing = #hlscpp.t<97 -> 101, 4, 1>} : f64
    %138 = arith.addf %131, %137 {timing = #hlscpp.t<101 -> 106, 5, 1>} : f64
    %139 = affine.load %arg0[%arg4 * 128 + 83] {partition_indices = [83], timing = #hlscpp.t<95 -> 97, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %140 = arith.mulf %135, %139 {timing = #hlscpp.t<97 -> 101, 4, 1>} : f64
    %141 = arith.addf %134, %140 {timing = #hlscpp.t<101 -> 106, 5, 1>} : f64
    %142 = affine.load %arg1[20] {partition_indices = [20], timing = #hlscpp.t<100 -> 102, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %143 = affine.load %arg0[%arg4 * 128 + 20] {partition_indices = [20], timing = #hlscpp.t<100 -> 102, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %144 = arith.mulf %142, %143 {timing = #hlscpp.t<102 -> 106, 4, 1>} : f64
    %145 = arith.addf %138, %144 {timing = #hlscpp.t<106 -> 111, 5, 1>} : f64
    %146 = affine.load %arg0[%arg4 * 128 + 84] {partition_indices = [84], timing = #hlscpp.t<100 -> 102, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %147 = arith.mulf %142, %146 {timing = #hlscpp.t<102 -> 106, 4, 1>} : f64
    %148 = arith.addf %141, %147 {timing = #hlscpp.t<106 -> 111, 5, 1>} : f64
    %149 = affine.load %arg1[21] {partition_indices = [21], timing = #hlscpp.t<105 -> 107, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %150 = affine.load %arg0[%arg4 * 128 + 21] {partition_indices = [21], timing = #hlscpp.t<105 -> 107, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %151 = arith.mulf %149, %150 {timing = #hlscpp.t<107 -> 111, 4, 1>} : f64
    %152 = arith.addf %145, %151 {timing = #hlscpp.t<111 -> 116, 5, 1>} : f64
    %153 = affine.load %arg0[%arg4 * 128 + 85] {partition_indices = [85], timing = #hlscpp.t<105 -> 107, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %154 = arith.mulf %149, %153 {timing = #hlscpp.t<107 -> 111, 4, 1>} : f64
    %155 = arith.addf %148, %154 {timing = #hlscpp.t<111 -> 116, 5, 1>} : f64
    %156 = affine.load %arg1[22] {partition_indices = [22], timing = #hlscpp.t<110 -> 112, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %157 = affine.load %arg0[%arg4 * 128 + 22] {partition_indices = [22], timing = #hlscpp.t<110 -> 112, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %158 = arith.mulf %156, %157 {timing = #hlscpp.t<112 -> 116, 4, 1>} : f64
    %159 = arith.addf %152, %158 {timing = #hlscpp.t<116 -> 121, 5, 1>} : f64
    %160 = affine.load %arg0[%arg4 * 128 + 86] {partition_indices = [86], timing = #hlscpp.t<110 -> 112, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %161 = arith.mulf %156, %160 {timing = #hlscpp.t<112 -> 116, 4, 1>} : f64
    %162 = arith.addf %155, %161 {timing = #hlscpp.t<116 -> 121, 5, 1>} : f64
    %163 = affine.load %arg1[23] {partition_indices = [23], timing = #hlscpp.t<115 -> 117, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %164 = affine.load %arg0[%arg4 * 128 + 23] {partition_indices = [23], timing = #hlscpp.t<115 -> 117, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %165 = arith.mulf %163, %164 {timing = #hlscpp.t<117 -> 121, 4, 1>} : f64
    %166 = arith.addf %159, %165 {timing = #hlscpp.t<121 -> 126, 5, 1>} : f64
    %167 = affine.load %arg0[%arg4 * 128 + 87] {partition_indices = [87], timing = #hlscpp.t<115 -> 117, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %168 = arith.mulf %163, %167 {timing = #hlscpp.t<117 -> 121, 4, 1>} : f64
    %169 = arith.addf %162, %168 {timing = #hlscpp.t<121 -> 126, 5, 1>} : f64
    %170 = affine.load %arg1[24] {partition_indices = [24], timing = #hlscpp.t<120 -> 122, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %171 = affine.load %arg0[%arg4 * 128 + 24] {partition_indices = [24], timing = #hlscpp.t<120 -> 122, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %172 = arith.mulf %170, %171 {timing = #hlscpp.t<122 -> 126, 4, 1>} : f64
    %173 = arith.addf %166, %172 {timing = #hlscpp.t<126 -> 131, 5, 1>} : f64
    %174 = affine.load %arg0[%arg4 * 128 + 88] {partition_indices = [88], timing = #hlscpp.t<120 -> 122, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %175 = arith.mulf %170, %174 {timing = #hlscpp.t<122 -> 126, 4, 1>} : f64
    %176 = arith.addf %169, %175 {timing = #hlscpp.t<126 -> 131, 5, 1>} : f64
    %177 = affine.load %arg1[25] {partition_indices = [25], timing = #hlscpp.t<125 -> 127, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %178 = affine.load %arg0[%arg4 * 128 + 25] {partition_indices = [25], timing = #hlscpp.t<125 -> 127, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %179 = arith.mulf %177, %178 {timing = #hlscpp.t<127 -> 131, 4, 1>} : f64
    %180 = arith.addf %173, %179 {timing = #hlscpp.t<131 -> 136, 5, 1>} : f64
    %181 = affine.load %arg0[%arg4 * 128 + 89] {partition_indices = [89], timing = #hlscpp.t<125 -> 127, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %182 = arith.mulf %177, %181 {timing = #hlscpp.t<127 -> 131, 4, 1>} : f64
    %183 = arith.addf %176, %182 {timing = #hlscpp.t<131 -> 136, 5, 1>} : f64
    %184 = affine.load %arg1[26] {partition_indices = [26], timing = #hlscpp.t<130 -> 132, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %185 = affine.load %arg0[%arg4 * 128 + 26] {partition_indices = [26], timing = #hlscpp.t<130 -> 132, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %186 = arith.mulf %184, %185 {timing = #hlscpp.t<132 -> 136, 4, 1>} : f64
    %187 = arith.addf %180, %186 {timing = #hlscpp.t<136 -> 141, 5, 1>} : f64
    %188 = affine.load %arg0[%arg4 * 128 + 90] {partition_indices = [90], timing = #hlscpp.t<130 -> 132, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %189 = arith.mulf %184, %188 {timing = #hlscpp.t<132 -> 136, 4, 1>} : f64
    %190 = arith.addf %183, %189 {timing = #hlscpp.t<136 -> 141, 5, 1>} : f64
    %191 = affine.load %arg1[27] {partition_indices = [27], timing = #hlscpp.t<135 -> 137, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %192 = affine.load %arg0[%arg4 * 128 + 27] {partition_indices = [27], timing = #hlscpp.t<135 -> 137, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %193 = arith.mulf %191, %192 {timing = #hlscpp.t<137 -> 141, 4, 1>} : f64
    %194 = arith.addf %187, %193 {timing = #hlscpp.t<141 -> 146, 5, 1>} : f64
    %195 = affine.load %arg0[%arg4 * 128 + 91] {partition_indices = [91], timing = #hlscpp.t<135 -> 137, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %196 = arith.mulf %191, %195 {timing = #hlscpp.t<137 -> 141, 4, 1>} : f64
    %197 = arith.addf %190, %196 {timing = #hlscpp.t<141 -> 146, 5, 1>} : f64
    %198 = affine.load %arg1[28] {partition_indices = [28], timing = #hlscpp.t<140 -> 142, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %199 = affine.load %arg0[%arg4 * 128 + 28] {partition_indices = [28], timing = #hlscpp.t<140 -> 142, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %200 = arith.mulf %198, %199 {timing = #hlscpp.t<142 -> 146, 4, 1>} : f64
    %201 = arith.addf %194, %200 {timing = #hlscpp.t<146 -> 151, 5, 1>} : f64
    %202 = affine.load %arg0[%arg4 * 128 + 92] {partition_indices = [92], timing = #hlscpp.t<140 -> 142, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %203 = arith.mulf %198, %202 {timing = #hlscpp.t<142 -> 146, 4, 1>} : f64
    %204 = arith.addf %197, %203 {timing = #hlscpp.t<146 -> 151, 5, 1>} : f64
    %205 = affine.load %arg1[29] {partition_indices = [29], timing = #hlscpp.t<145 -> 147, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %206 = affine.load %arg0[%arg4 * 128 + 29] {partition_indices = [29], timing = #hlscpp.t<145 -> 147, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %207 = arith.mulf %205, %206 {timing = #hlscpp.t<147 -> 151, 4, 1>} : f64
    %208 = arith.addf %201, %207 {timing = #hlscpp.t<151 -> 156, 5, 1>} : f64
    %209 = affine.load %arg0[%arg4 * 128 + 93] {partition_indices = [93], timing = #hlscpp.t<145 -> 147, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %210 = arith.mulf %205, %209 {timing = #hlscpp.t<147 -> 151, 4, 1>} : f64
    %211 = arith.addf %204, %210 {timing = #hlscpp.t<151 -> 156, 5, 1>} : f64
    %212 = affine.load %arg1[30] {partition_indices = [30], timing = #hlscpp.t<150 -> 152, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %213 = affine.load %arg0[%arg4 * 128 + 30] {partition_indices = [30], timing = #hlscpp.t<150 -> 152, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %214 = arith.mulf %212, %213 {timing = #hlscpp.t<152 -> 156, 4, 1>} : f64
    %215 = arith.addf %208, %214 {timing = #hlscpp.t<156 -> 161, 5, 1>} : f64
    %216 = affine.load %arg0[%arg4 * 128 + 94] {partition_indices = [94], timing = #hlscpp.t<150 -> 152, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %217 = arith.mulf %212, %216 {timing = #hlscpp.t<152 -> 156, 4, 1>} : f64
    %218 = arith.addf %211, %217 {timing = #hlscpp.t<156 -> 161, 5, 1>} : f64
    %219 = affine.load %arg1[31] {partition_indices = [31], timing = #hlscpp.t<155 -> 157, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %220 = affine.load %arg0[%arg4 * 128 + 31] {partition_indices = [31], timing = #hlscpp.t<155 -> 157, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %221 = arith.mulf %219, %220 {timing = #hlscpp.t<157 -> 161, 4, 1>} : f64
    %222 = arith.addf %215, %221 {timing = #hlscpp.t<161 -> 166, 5, 1>} : f64
    %223 = affine.load %arg0[%arg4 * 128 + 95] {partition_indices = [95], timing = #hlscpp.t<155 -> 157, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %224 = arith.mulf %219, %223 {timing = #hlscpp.t<157 -> 161, 4, 1>} : f64
    %225 = arith.addf %218, %224 {timing = #hlscpp.t<161 -> 166, 5, 1>} : f64
    %226 = affine.load %arg1[32] {partition_indices = [32], timing = #hlscpp.t<160 -> 162, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %227 = affine.load %arg0[%arg4 * 128 + 32] {partition_indices = [32], timing = #hlscpp.t<160 -> 162, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %228 = arith.mulf %226, %227 {timing = #hlscpp.t<162 -> 166, 4, 1>} : f64
    %229 = arith.addf %222, %228 {timing = #hlscpp.t<166 -> 171, 5, 1>} : f64
    %230 = affine.load %arg0[%arg4 * 128 + 96] {partition_indices = [96], timing = #hlscpp.t<160 -> 162, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %231 = arith.mulf %226, %230 {timing = #hlscpp.t<162 -> 166, 4, 1>} : f64
    %232 = arith.addf %225, %231 {timing = #hlscpp.t<166 -> 171, 5, 1>} : f64
    %233 = affine.load %arg1[33] {partition_indices = [33], timing = #hlscpp.t<165 -> 167, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %234 = affine.load %arg0[%arg4 * 128 + 33] {partition_indices = [33], timing = #hlscpp.t<165 -> 167, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %235 = arith.mulf %233, %234 {timing = #hlscpp.t<167 -> 171, 4, 1>} : f64
    %236 = arith.addf %229, %235 {timing = #hlscpp.t<171 -> 176, 5, 1>} : f64
    %237 = affine.load %arg0[%arg4 * 128 + 97] {partition_indices = [97], timing = #hlscpp.t<165 -> 167, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %238 = arith.mulf %233, %237 {timing = #hlscpp.t<167 -> 171, 4, 1>} : f64
    %239 = arith.addf %232, %238 {timing = #hlscpp.t<171 -> 176, 5, 1>} : f64
    %240 = affine.load %arg1[34] {partition_indices = [34], timing = #hlscpp.t<170 -> 172, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %241 = affine.load %arg0[%arg4 * 128 + 34] {partition_indices = [34], timing = #hlscpp.t<170 -> 172, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %242 = arith.mulf %240, %241 {timing = #hlscpp.t<172 -> 176, 4, 1>} : f64
    %243 = arith.addf %236, %242 {timing = #hlscpp.t<176 -> 181, 5, 1>} : f64
    %244 = affine.load %arg0[%arg4 * 128 + 98] {partition_indices = [98], timing = #hlscpp.t<170 -> 172, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %245 = arith.mulf %240, %244 {timing = #hlscpp.t<172 -> 176, 4, 1>} : f64
    %246 = arith.addf %239, %245 {timing = #hlscpp.t<176 -> 181, 5, 1>} : f64
    %247 = affine.load %arg1[35] {partition_indices = [35], timing = #hlscpp.t<175 -> 177, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %248 = affine.load %arg0[%arg4 * 128 + 35] {partition_indices = [35], timing = #hlscpp.t<175 -> 177, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %249 = arith.mulf %247, %248 {timing = #hlscpp.t<177 -> 181, 4, 1>} : f64
    %250 = arith.addf %243, %249 {timing = #hlscpp.t<181 -> 186, 5, 1>} : f64
    %251 = affine.load %arg0[%arg4 * 128 + 99] {partition_indices = [99], timing = #hlscpp.t<175 -> 177, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %252 = arith.mulf %247, %251 {timing = #hlscpp.t<177 -> 181, 4, 1>} : f64
    %253 = arith.addf %246, %252 {timing = #hlscpp.t<181 -> 186, 5, 1>} : f64
    %254 = affine.load %arg1[36] {partition_indices = [36], timing = #hlscpp.t<180 -> 182, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %255 = affine.load %arg0[%arg4 * 128 + 36] {partition_indices = [36], timing = #hlscpp.t<180 -> 182, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %256 = arith.mulf %254, %255 {timing = #hlscpp.t<182 -> 186, 4, 1>} : f64
    %257 = arith.addf %250, %256 {timing = #hlscpp.t<186 -> 191, 5, 1>} : f64
    %258 = affine.load %arg0[%arg4 * 128 + 100] {partition_indices = [100], timing = #hlscpp.t<180 -> 182, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %259 = arith.mulf %254, %258 {timing = #hlscpp.t<182 -> 186, 4, 1>} : f64
    %260 = arith.addf %253, %259 {timing = #hlscpp.t<186 -> 191, 5, 1>} : f64
    %261 = affine.load %arg1[37] {partition_indices = [37], timing = #hlscpp.t<185 -> 187, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %262 = affine.load %arg0[%arg4 * 128 + 37] {partition_indices = [37], timing = #hlscpp.t<185 -> 187, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %263 = arith.mulf %261, %262 {timing = #hlscpp.t<187 -> 191, 4, 1>} : f64
    %264 = arith.addf %257, %263 {timing = #hlscpp.t<191 -> 196, 5, 1>} : f64
    %265 = affine.load %arg0[%arg4 * 128 + 101] {partition_indices = [101], timing = #hlscpp.t<185 -> 187, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %266 = arith.mulf %261, %265 {timing = #hlscpp.t<187 -> 191, 4, 1>} : f64
    %267 = arith.addf %260, %266 {timing = #hlscpp.t<191 -> 196, 5, 1>} : f64
    %268 = affine.load %arg1[38] {partition_indices = [38], timing = #hlscpp.t<190 -> 192, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %269 = affine.load %arg0[%arg4 * 128 + 38] {partition_indices = [38], timing = #hlscpp.t<190 -> 192, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %270 = arith.mulf %268, %269 {timing = #hlscpp.t<192 -> 196, 4, 1>} : f64
    %271 = arith.addf %264, %270 {timing = #hlscpp.t<196 -> 201, 5, 1>} : f64
    %272 = affine.load %arg0[%arg4 * 128 + 102] {partition_indices = [102], timing = #hlscpp.t<190 -> 192, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %273 = arith.mulf %268, %272 {timing = #hlscpp.t<192 -> 196, 4, 1>} : f64
    %274 = arith.addf %267, %273 {timing = #hlscpp.t<196 -> 201, 5, 1>} : f64
    %275 = affine.load %arg1[39] {partition_indices = [39], timing = #hlscpp.t<195 -> 197, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %276 = affine.load %arg0[%arg4 * 128 + 39] {partition_indices = [39], timing = #hlscpp.t<195 -> 197, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %277 = arith.mulf %275, %276 {timing = #hlscpp.t<197 -> 201, 4, 1>} : f64
    %278 = arith.addf %271, %277 {timing = #hlscpp.t<201 -> 206, 5, 1>} : f64
    %279 = affine.load %arg0[%arg4 * 128 + 103] {partition_indices = [103], timing = #hlscpp.t<195 -> 197, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %280 = arith.mulf %275, %279 {timing = #hlscpp.t<197 -> 201, 4, 1>} : f64
    %281 = arith.addf %274, %280 {timing = #hlscpp.t<201 -> 206, 5, 1>} : f64
    %282 = affine.load %arg1[40] {partition_indices = [40], timing = #hlscpp.t<200 -> 202, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %283 = affine.load %arg0[%arg4 * 128 + 40] {partition_indices = [40], timing = #hlscpp.t<200 -> 202, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %284 = arith.mulf %282, %283 {timing = #hlscpp.t<202 -> 206, 4, 1>} : f64
    %285 = arith.addf %278, %284 {timing = #hlscpp.t<206 -> 211, 5, 1>} : f64
    %286 = affine.load %arg0[%arg4 * 128 + 104] {partition_indices = [104], timing = #hlscpp.t<200 -> 202, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %287 = arith.mulf %282, %286 {timing = #hlscpp.t<202 -> 206, 4, 1>} : f64
    %288 = arith.addf %281, %287 {timing = #hlscpp.t<206 -> 211, 5, 1>} : f64
    %289 = affine.load %arg1[41] {partition_indices = [41], timing = #hlscpp.t<205 -> 207, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %290 = affine.load %arg0[%arg4 * 128 + 41] {partition_indices = [41], timing = #hlscpp.t<205 -> 207, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %291 = arith.mulf %289, %290 {timing = #hlscpp.t<207 -> 211, 4, 1>} : f64
    %292 = arith.addf %285, %291 {timing = #hlscpp.t<211 -> 216, 5, 1>} : f64
    %293 = affine.load %arg0[%arg4 * 128 + 105] {partition_indices = [105], timing = #hlscpp.t<205 -> 207, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %294 = arith.mulf %289, %293 {timing = #hlscpp.t<207 -> 211, 4, 1>} : f64
    %295 = arith.addf %288, %294 {timing = #hlscpp.t<211 -> 216, 5, 1>} : f64
    %296 = affine.load %arg1[42] {partition_indices = [42], timing = #hlscpp.t<210 -> 212, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %297 = affine.load %arg0[%arg4 * 128 + 42] {partition_indices = [42], timing = #hlscpp.t<210 -> 212, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %298 = arith.mulf %296, %297 {timing = #hlscpp.t<212 -> 216, 4, 1>} : f64
    %299 = arith.addf %292, %298 {timing = #hlscpp.t<216 -> 221, 5, 1>} : f64
    %300 = affine.load %arg0[%arg4 * 128 + 106] {partition_indices = [106], timing = #hlscpp.t<210 -> 212, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %301 = arith.mulf %296, %300 {timing = #hlscpp.t<212 -> 216, 4, 1>} : f64
    %302 = arith.addf %295, %301 {timing = #hlscpp.t<216 -> 221, 5, 1>} : f64
    %303 = affine.load %arg1[43] {partition_indices = [43], timing = #hlscpp.t<215 -> 217, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %304 = affine.load %arg0[%arg4 * 128 + 43] {partition_indices = [43], timing = #hlscpp.t<215 -> 217, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %305 = arith.mulf %303, %304 {timing = #hlscpp.t<217 -> 221, 4, 1>} : f64
    %306 = arith.addf %299, %305 {timing = #hlscpp.t<221 -> 226, 5, 1>} : f64
    %307 = affine.load %arg0[%arg4 * 128 + 107] {partition_indices = [107], timing = #hlscpp.t<215 -> 217, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %308 = arith.mulf %303, %307 {timing = #hlscpp.t<217 -> 221, 4, 1>} : f64
    %309 = arith.addf %302, %308 {timing = #hlscpp.t<221 -> 226, 5, 1>} : f64
    %310 = affine.load %arg1[44] {partition_indices = [44], timing = #hlscpp.t<220 -> 222, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %311 = affine.load %arg0[%arg4 * 128 + 44] {partition_indices = [44], timing = #hlscpp.t<220 -> 222, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %312 = arith.mulf %310, %311 {timing = #hlscpp.t<222 -> 226, 4, 1>} : f64
    %313 = arith.addf %306, %312 {timing = #hlscpp.t<226 -> 231, 5, 1>} : f64
    %314 = affine.load %arg0[%arg4 * 128 + 108] {partition_indices = [108], timing = #hlscpp.t<220 -> 222, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %315 = arith.mulf %310, %314 {timing = #hlscpp.t<222 -> 226, 4, 1>} : f64
    %316 = arith.addf %309, %315 {timing = #hlscpp.t<226 -> 231, 5, 1>} : f64
    %317 = affine.load %arg1[45] {partition_indices = [45], timing = #hlscpp.t<225 -> 227, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %318 = affine.load %arg0[%arg4 * 128 + 45] {partition_indices = [45], timing = #hlscpp.t<225 -> 227, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %319 = arith.mulf %317, %318 {timing = #hlscpp.t<227 -> 231, 4, 1>} : f64
    %320 = arith.addf %313, %319 {timing = #hlscpp.t<231 -> 236, 5, 1>} : f64
    %321 = affine.load %arg0[%arg4 * 128 + 109] {partition_indices = [109], timing = #hlscpp.t<225 -> 227, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %322 = arith.mulf %317, %321 {timing = #hlscpp.t<227 -> 231, 4, 1>} : f64
    %323 = arith.addf %316, %322 {timing = #hlscpp.t<231 -> 236, 5, 1>} : f64
    %324 = affine.load %arg1[46] {partition_indices = [46], timing = #hlscpp.t<230 -> 232, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %325 = affine.load %arg0[%arg4 * 128 + 46] {partition_indices = [46], timing = #hlscpp.t<230 -> 232, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %326 = arith.mulf %324, %325 {timing = #hlscpp.t<232 -> 236, 4, 1>} : f64
    %327 = arith.addf %320, %326 {timing = #hlscpp.t<236 -> 241, 5, 1>} : f64
    %328 = affine.load %arg0[%arg4 * 128 + 110] {partition_indices = [110], timing = #hlscpp.t<230 -> 232, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %329 = arith.mulf %324, %328 {timing = #hlscpp.t<232 -> 236, 4, 1>} : f64
    %330 = arith.addf %323, %329 {timing = #hlscpp.t<236 -> 241, 5, 1>} : f64
    %331 = affine.load %arg1[47] {partition_indices = [47], timing = #hlscpp.t<235 -> 237, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %332 = affine.load %arg0[%arg4 * 128 + 47] {partition_indices = [47], timing = #hlscpp.t<235 -> 237, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %333 = arith.mulf %331, %332 {timing = #hlscpp.t<237 -> 241, 4, 1>} : f64
    %334 = arith.addf %327, %333 {timing = #hlscpp.t<241 -> 246, 5, 1>} : f64
    %335 = affine.load %arg0[%arg4 * 128 + 111] {partition_indices = [111], timing = #hlscpp.t<235 -> 237, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %336 = arith.mulf %331, %335 {timing = #hlscpp.t<237 -> 241, 4, 1>} : f64
    %337 = arith.addf %330, %336 {timing = #hlscpp.t<241 -> 246, 5, 1>} : f64
    %338 = affine.load %arg1[48] {partition_indices = [48], timing = #hlscpp.t<240 -> 242, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %339 = affine.load %arg0[%arg4 * 128 + 48] {partition_indices = [48], timing = #hlscpp.t<240 -> 242, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %340 = arith.mulf %338, %339 {timing = #hlscpp.t<242 -> 246, 4, 1>} : f64
    %341 = arith.addf %334, %340 {timing = #hlscpp.t<246 -> 251, 5, 1>} : f64
    %342 = affine.load %arg0[%arg4 * 128 + 112] {partition_indices = [112], timing = #hlscpp.t<240 -> 242, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %343 = arith.mulf %338, %342 {timing = #hlscpp.t<242 -> 246, 4, 1>} : f64
    %344 = arith.addf %337, %343 {timing = #hlscpp.t<246 -> 251, 5, 1>} : f64
    %345 = affine.load %arg1[49] {partition_indices = [49], timing = #hlscpp.t<245 -> 247, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %346 = affine.load %arg0[%arg4 * 128 + 49] {partition_indices = [49], timing = #hlscpp.t<245 -> 247, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %347 = arith.mulf %345, %346 {timing = #hlscpp.t<247 -> 251, 4, 1>} : f64
    %348 = arith.addf %341, %347 {timing = #hlscpp.t<251 -> 256, 5, 1>} : f64
    %349 = affine.load %arg0[%arg4 * 128 + 113] {partition_indices = [113], timing = #hlscpp.t<245 -> 247, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %350 = arith.mulf %345, %349 {timing = #hlscpp.t<247 -> 251, 4, 1>} : f64
    %351 = arith.addf %344, %350 {timing = #hlscpp.t<251 -> 256, 5, 1>} : f64
    %352 = affine.load %arg1[50] {partition_indices = [50], timing = #hlscpp.t<250 -> 252, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %353 = affine.load %arg0[%arg4 * 128 + 50] {partition_indices = [50], timing = #hlscpp.t<250 -> 252, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %354 = arith.mulf %352, %353 {timing = #hlscpp.t<252 -> 256, 4, 1>} : f64
    %355 = arith.addf %348, %354 {timing = #hlscpp.t<256 -> 261, 5, 1>} : f64
    %356 = affine.load %arg0[%arg4 * 128 + 114] {partition_indices = [114], timing = #hlscpp.t<250 -> 252, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %357 = arith.mulf %352, %356 {timing = #hlscpp.t<252 -> 256, 4, 1>} : f64
    %358 = arith.addf %351, %357 {timing = #hlscpp.t<256 -> 261, 5, 1>} : f64
    %359 = affine.load %arg1[51] {partition_indices = [51], timing = #hlscpp.t<255 -> 257, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %360 = affine.load %arg0[%arg4 * 128 + 51] {partition_indices = [51], timing = #hlscpp.t<255 -> 257, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %361 = arith.mulf %359, %360 {timing = #hlscpp.t<257 -> 261, 4, 1>} : f64
    %362 = arith.addf %355, %361 {timing = #hlscpp.t<261 -> 266, 5, 1>} : f64
    %363 = affine.load %arg0[%arg4 * 128 + 115] {partition_indices = [115], timing = #hlscpp.t<255 -> 257, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %364 = arith.mulf %359, %363 {timing = #hlscpp.t<257 -> 261, 4, 1>} : f64
    %365 = arith.addf %358, %364 {timing = #hlscpp.t<261 -> 266, 5, 1>} : f64
    %366 = affine.load %arg1[52] {partition_indices = [52], timing = #hlscpp.t<260 -> 262, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %367 = affine.load %arg0[%arg4 * 128 + 52] {partition_indices = [52], timing = #hlscpp.t<260 -> 262, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %368 = arith.mulf %366, %367 {timing = #hlscpp.t<262 -> 266, 4, 1>} : f64
    %369 = arith.addf %362, %368 {timing = #hlscpp.t<266 -> 271, 5, 1>} : f64
    %370 = affine.load %arg0[%arg4 * 128 + 116] {partition_indices = [116], timing = #hlscpp.t<260 -> 262, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %371 = arith.mulf %366, %370 {timing = #hlscpp.t<262 -> 266, 4, 1>} : f64
    %372 = arith.addf %365, %371 {timing = #hlscpp.t<266 -> 271, 5, 1>} : f64
    %373 = affine.load %arg1[53] {partition_indices = [53], timing = #hlscpp.t<265 -> 267, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %374 = affine.load %arg0[%arg4 * 128 + 53] {partition_indices = [53], timing = #hlscpp.t<265 -> 267, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %375 = arith.mulf %373, %374 {timing = #hlscpp.t<267 -> 271, 4, 1>} : f64
    %376 = arith.addf %369, %375 {timing = #hlscpp.t<271 -> 276, 5, 1>} : f64
    %377 = affine.load %arg0[%arg4 * 128 + 117] {partition_indices = [117], timing = #hlscpp.t<265 -> 267, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %378 = arith.mulf %373, %377 {timing = #hlscpp.t<267 -> 271, 4, 1>} : f64
    %379 = arith.addf %372, %378 {timing = #hlscpp.t<271 -> 276, 5, 1>} : f64
    %380 = affine.load %arg1[54] {partition_indices = [54], timing = #hlscpp.t<270 -> 272, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %381 = affine.load %arg0[%arg4 * 128 + 54] {partition_indices = [54], timing = #hlscpp.t<270 -> 272, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %382 = arith.mulf %380, %381 {timing = #hlscpp.t<272 -> 276, 4, 1>} : f64
    %383 = arith.addf %376, %382 {timing = #hlscpp.t<276 -> 281, 5, 1>} : f64
    %384 = affine.load %arg0[%arg4 * 128 + 118] {partition_indices = [118], timing = #hlscpp.t<270 -> 272, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %385 = arith.mulf %380, %384 {timing = #hlscpp.t<272 -> 276, 4, 1>} : f64
    %386 = arith.addf %379, %385 {timing = #hlscpp.t<276 -> 281, 5, 1>} : f64
    %387 = affine.load %arg1[55] {partition_indices = [55], timing = #hlscpp.t<275 -> 277, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %388 = affine.load %arg0[%arg4 * 128 + 55] {partition_indices = [55], timing = #hlscpp.t<275 -> 277, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %389 = arith.mulf %387, %388 {timing = #hlscpp.t<277 -> 281, 4, 1>} : f64
    %390 = arith.addf %383, %389 {timing = #hlscpp.t<281 -> 286, 5, 1>} : f64
    %391 = affine.load %arg0[%arg4 * 128 + 119] {partition_indices = [119], timing = #hlscpp.t<275 -> 277, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %392 = arith.mulf %387, %391 {timing = #hlscpp.t<277 -> 281, 4, 1>} : f64
    %393 = arith.addf %386, %392 {timing = #hlscpp.t<281 -> 286, 5, 1>} : f64
    %394 = affine.load %arg1[56] {partition_indices = [56], timing = #hlscpp.t<280 -> 282, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %395 = affine.load %arg0[%arg4 * 128 + 56] {partition_indices = [56], timing = #hlscpp.t<280 -> 282, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %396 = arith.mulf %394, %395 {timing = #hlscpp.t<282 -> 286, 4, 1>} : f64
    %397 = arith.addf %390, %396 {timing = #hlscpp.t<286 -> 291, 5, 1>} : f64
    %398 = affine.load %arg0[%arg4 * 128 + 120] {partition_indices = [120], timing = #hlscpp.t<280 -> 282, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %399 = arith.mulf %394, %398 {timing = #hlscpp.t<282 -> 286, 4, 1>} : f64
    %400 = arith.addf %393, %399 {timing = #hlscpp.t<286 -> 291, 5, 1>} : f64
    %401 = affine.load %arg1[57] {partition_indices = [57], timing = #hlscpp.t<285 -> 287, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %402 = affine.load %arg0[%arg4 * 128 + 57] {partition_indices = [57], timing = #hlscpp.t<285 -> 287, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %403 = arith.mulf %401, %402 {timing = #hlscpp.t<287 -> 291, 4, 1>} : f64
    %404 = arith.addf %397, %403 {timing = #hlscpp.t<291 -> 296, 5, 1>} : f64
    %405 = affine.load %arg0[%arg4 * 128 + 121] {partition_indices = [121], timing = #hlscpp.t<285 -> 287, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %406 = arith.mulf %401, %405 {timing = #hlscpp.t<287 -> 291, 4, 1>} : f64
    %407 = arith.addf %400, %406 {timing = #hlscpp.t<291 -> 296, 5, 1>} : f64
    %408 = affine.load %arg1[58] {partition_indices = [58], timing = #hlscpp.t<290 -> 292, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %409 = affine.load %arg0[%arg4 * 128 + 58] {partition_indices = [58], timing = #hlscpp.t<290 -> 292, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %410 = arith.mulf %408, %409 {timing = #hlscpp.t<292 -> 296, 4, 1>} : f64
    %411 = arith.addf %404, %410 {timing = #hlscpp.t<296 -> 301, 5, 1>} : f64
    %412 = affine.load %arg0[%arg4 * 128 + 122] {partition_indices = [122], timing = #hlscpp.t<290 -> 292, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %413 = arith.mulf %408, %412 {timing = #hlscpp.t<292 -> 296, 4, 1>} : f64
    %414 = arith.addf %407, %413 {timing = #hlscpp.t<296 -> 301, 5, 1>} : f64
    %415 = affine.load %arg1[59] {partition_indices = [59], timing = #hlscpp.t<295 -> 297, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %416 = affine.load %arg0[%arg4 * 128 + 59] {partition_indices = [59], timing = #hlscpp.t<295 -> 297, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %417 = arith.mulf %415, %416 {timing = #hlscpp.t<297 -> 301, 4, 1>} : f64
    %418 = arith.addf %411, %417 {timing = #hlscpp.t<301 -> 306, 5, 1>} : f64
    %419 = affine.load %arg0[%arg4 * 128 + 123] {partition_indices = [123], timing = #hlscpp.t<295 -> 297, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %420 = arith.mulf %415, %419 {timing = #hlscpp.t<297 -> 301, 4, 1>} : f64
    %421 = arith.addf %414, %420 {timing = #hlscpp.t<301 -> 306, 5, 1>} : f64
    %422 = affine.load %arg1[60] {partition_indices = [60], timing = #hlscpp.t<300 -> 302, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %423 = affine.load %arg0[%arg4 * 128 + 60] {partition_indices = [60], timing = #hlscpp.t<300 -> 302, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %424 = arith.mulf %422, %423 {timing = #hlscpp.t<302 -> 306, 4, 1>} : f64
    %425 = arith.addf %418, %424 {timing = #hlscpp.t<306 -> 311, 5, 1>} : f64
    %426 = affine.load %arg0[%arg4 * 128 + 124] {partition_indices = [124], timing = #hlscpp.t<300 -> 302, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %427 = arith.mulf %422, %426 {timing = #hlscpp.t<302 -> 306, 4, 1>} : f64
    %428 = arith.addf %421, %427 {timing = #hlscpp.t<306 -> 311, 5, 1>} : f64
    %429 = affine.load %arg1[61] {partition_indices = [61], timing = #hlscpp.t<305 -> 307, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %430 = affine.load %arg0[%arg4 * 128 + 61] {partition_indices = [61], timing = #hlscpp.t<305 -> 307, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %431 = arith.mulf %429, %430 {timing = #hlscpp.t<307 -> 311, 4, 1>} : f64
    %432 = arith.addf %425, %431 {timing = #hlscpp.t<311 -> 316, 5, 1>} : f64
    %433 = affine.load %arg0[%arg4 * 128 + 125] {partition_indices = [125], timing = #hlscpp.t<305 -> 307, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %434 = arith.mulf %429, %433 {timing = #hlscpp.t<307 -> 311, 4, 1>} : f64
    %435 = arith.addf %428, %434 {timing = #hlscpp.t<311 -> 316, 5, 1>} : f64
    %436 = affine.load %arg1[62] {partition_indices = [62], timing = #hlscpp.t<310 -> 312, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %437 = affine.load %arg0[%arg4 * 128 + 62] {partition_indices = [62], timing = #hlscpp.t<310 -> 312, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %438 = arith.mulf %436, %437 {timing = #hlscpp.t<312 -> 316, 4, 1>} : f64
    %439 = arith.addf %432, %438 {timing = #hlscpp.t<316 -> 321, 5, 1>} : f64
    %440 = affine.load %arg0[%arg4 * 128 + 126] {partition_indices = [126], timing = #hlscpp.t<310 -> 312, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %441 = arith.mulf %436, %440 {timing = #hlscpp.t<312 -> 316, 4, 1>} : f64
    %442 = arith.addf %435, %441 {timing = #hlscpp.t<316 -> 321, 5, 1>} : f64
    %443 = affine.load %arg1[63] {partition_indices = [63], timing = #hlscpp.t<315 -> 317, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %444 = affine.load %arg0[%arg4 * 128 + 63] {partition_indices = [63], timing = #hlscpp.t<315 -> 317, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %445 = arith.mulf %443, %444 {timing = #hlscpp.t<317 -> 321, 4, 1>} : f64
    %446 = arith.addf %439, %445 {timing = #hlscpp.t<321 -> 326, 5, 1>} : f64
    %447 = arith.mulf %446, %4 {timing = #hlscpp.t<326 -> 330, 4, 1>} : f64
    affine.store %447, %arg2[%arg4 * 2] {partition_indices = [0], timing = #hlscpp.t<330 -> 331, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 2, d0 floordiv 2)>, 1>
    %448 = affine.load %arg0[%arg4 * 128 + 127] {partition_indices = [127], timing = #hlscpp.t<315 -> 317, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 128, d0 floordiv 128)>, 1>
    %449 = arith.mulf %443, %448 {timing = #hlscpp.t<317 -> 321, 4, 1>} : f64
    %450 = arith.addf %442, %449 {timing = #hlscpp.t<321 -> 326, 5, 1>} : f64
    %451 = arith.mulf %450, %8 {timing = #hlscpp.t<326 -> 330, 4, 1>} : f64
    affine.store %451, %arg2[%arg4 * 2 + 1] {partition_indices = [1], timing = #hlscpp.t<330 -> 331, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 2, d0 floordiv 2)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=2, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=32, iterLatency=331, minII=2>, timing = #hlscpp.t<0 -> 395, 395, 395>}
  return {timing = #hlscpp.t<395 -> 395, 0, 0>}
}
