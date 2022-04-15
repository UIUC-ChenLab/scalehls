func @get_oracle_activations1(%arg0: memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>, %arg1: memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>, %arg2: memref<64xf64, affine_map<(d0) -> (d0 mod 4, d0 floordiv 4)>, 1>, %arg3: memref<64xf64, affine_map<(d0) -> (d0 mod 4, d0 floordiv 4)>, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>, llvm.linkage = #llvm.linkage<external>, resource = #hlscpp.r<lut=0, dsp=323, bram=0>, timing = #hlscpp.t<0 -> 395, 395, 395>} {
  %cst = arith.constant {timing = #hlscpp.t<0 -> 0, 0, 0>} 0.000000e+00 : f64
  affine.for %arg4 = 0 to 16 {
    %0 = affine.load %arg1[0] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %1 = affine.load %arg0[%arg4 * 256] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %2 = arith.mulf %0, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %3 = arith.addf %2, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %4 = affine.load %arg3[%arg4 * 4] {partition_indices = [0], timing = #hlscpp.t<324 -> 326, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 4, d0 floordiv 4)>, 1>
    %5 = affine.load %arg0[%arg4 * 256 + 64] {partition_indices = [64], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %6 = arith.mulf %0, %5 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %7 = arith.addf %6, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %8 = affine.load %arg3[%arg4 * 4 + 1] {partition_indices = [1], timing = #hlscpp.t<324 -> 326, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 4, d0 floordiv 4)>, 1>
    %9 = affine.load %arg0[%arg4 * 256 + 128] {partition_indices = [128], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %10 = arith.mulf %0, %9 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %11 = arith.addf %10, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %12 = affine.load %arg3[%arg4 * 4 + 2] {partition_indices = [2], timing = #hlscpp.t<324 -> 326, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 4, d0 floordiv 4)>, 1>
    %13 = affine.load %arg0[%arg4 * 256 + 192] {partition_indices = [192], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %14 = arith.mulf %0, %13 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %15 = arith.addf %14, %cst {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %16 = affine.load %arg3[%arg4 * 4 + 3] {partition_indices = [3], timing = #hlscpp.t<324 -> 326, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 4, d0 floordiv 4)>, 1>
    %17 = affine.load %arg1[1] {partition_indices = [1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %18 = affine.load %arg0[%arg4 * 256 + 1] {partition_indices = [1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %19 = arith.mulf %17, %18 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %20 = arith.addf %3, %19 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %21 = affine.load %arg0[%arg4 * 256 + 65] {partition_indices = [65], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %22 = arith.mulf %17, %21 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %23 = arith.addf %7, %22 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %24 = affine.load %arg0[%arg4 * 256 + 129] {partition_indices = [129], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %25 = arith.mulf %17, %24 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %26 = arith.addf %11, %25 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %27 = affine.load %arg0[%arg4 * 256 + 193] {partition_indices = [193], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %28 = arith.mulf %17, %27 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %29 = arith.addf %15, %28 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %30 = affine.load %arg1[2] {partition_indices = [2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %31 = affine.load %arg0[%arg4 * 256 + 2] {partition_indices = [2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %32 = arith.mulf %30, %31 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %33 = arith.addf %20, %32 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %34 = affine.load %arg0[%arg4 * 256 + 66] {partition_indices = [66], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %35 = arith.mulf %30, %34 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %36 = arith.addf %23, %35 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %37 = affine.load %arg0[%arg4 * 256 + 130] {partition_indices = [130], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %38 = arith.mulf %30, %37 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %39 = arith.addf %26, %38 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %40 = affine.load %arg0[%arg4 * 256 + 194] {partition_indices = [194], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %41 = arith.mulf %30, %40 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %42 = arith.addf %29, %41 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %43 = affine.load %arg1[3] {partition_indices = [3], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %44 = affine.load %arg0[%arg4 * 256 + 3] {partition_indices = [3], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %45 = arith.mulf %43, %44 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f64
    %46 = arith.addf %33, %45 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f64
    %47 = affine.load %arg0[%arg4 * 256 + 67] {partition_indices = [67], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %48 = arith.mulf %43, %47 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f64
    %49 = arith.addf %36, %48 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f64
    %50 = affine.load %arg0[%arg4 * 256 + 131] {partition_indices = [131], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %51 = arith.mulf %43, %50 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f64
    %52 = arith.addf %39, %51 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f64
    %53 = affine.load %arg0[%arg4 * 256 + 195] {partition_indices = [195], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %54 = arith.mulf %43, %53 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f64
    %55 = arith.addf %42, %54 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f64
    %56 = affine.load %arg1[4] {partition_indices = [4], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %57 = affine.load %arg0[%arg4 * 256 + 4] {partition_indices = [4], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %58 = arith.mulf %56, %57 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f64
    %59 = arith.addf %46, %58 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f64
    %60 = affine.load %arg0[%arg4 * 256 + 68] {partition_indices = [68], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %61 = arith.mulf %56, %60 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f64
    %62 = arith.addf %49, %61 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f64
    %63 = affine.load %arg0[%arg4 * 256 + 132] {partition_indices = [132], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %64 = arith.mulf %56, %63 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f64
    %65 = arith.addf %52, %64 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f64
    %66 = affine.load %arg0[%arg4 * 256 + 196] {partition_indices = [196], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %67 = arith.mulf %56, %66 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f64
    %68 = arith.addf %55, %67 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f64
    %69 = affine.load %arg1[5] {partition_indices = [5], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %70 = affine.load %arg0[%arg4 * 256 + 5] {partition_indices = [5], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %71 = arith.mulf %69, %70 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f64
    %72 = arith.addf %59, %71 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f64
    %73 = affine.load %arg0[%arg4 * 256 + 69] {partition_indices = [69], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %74 = arith.mulf %69, %73 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f64
    %75 = arith.addf %62, %74 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f64
    %76 = affine.load %arg0[%arg4 * 256 + 133] {partition_indices = [133], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %77 = arith.mulf %69, %76 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f64
    %78 = arith.addf %65, %77 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f64
    %79 = affine.load %arg0[%arg4 * 256 + 197] {partition_indices = [197], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %80 = arith.mulf %69, %79 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f64
    %81 = arith.addf %68, %80 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f64
    %82 = affine.load %arg1[6] {partition_indices = [6], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %83 = affine.load %arg0[%arg4 * 256 + 6] {partition_indices = [6], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %84 = arith.mulf %82, %83 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f64
    %85 = arith.addf %72, %84 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f64
    %86 = affine.load %arg0[%arg4 * 256 + 70] {partition_indices = [70], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %87 = arith.mulf %82, %86 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f64
    %88 = arith.addf %75, %87 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f64
    %89 = affine.load %arg0[%arg4 * 256 + 134] {partition_indices = [134], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %90 = arith.mulf %82, %89 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f64
    %91 = arith.addf %78, %90 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f64
    %92 = affine.load %arg0[%arg4 * 256 + 198] {partition_indices = [198], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %93 = arith.mulf %82, %92 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f64
    %94 = arith.addf %81, %93 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f64
    %95 = affine.load %arg1[7] {partition_indices = [7], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %96 = affine.load %arg0[%arg4 * 256 + 7] {partition_indices = [7], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %97 = arith.mulf %95, %96 {timing = #hlscpp.t<37 -> 41, 4, 1>} : f64
    %98 = arith.addf %85, %97 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f64
    %99 = affine.load %arg0[%arg4 * 256 + 71] {partition_indices = [71], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %100 = arith.mulf %95, %99 {timing = #hlscpp.t<37 -> 41, 4, 1>} : f64
    %101 = arith.addf %88, %100 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f64
    %102 = affine.load %arg0[%arg4 * 256 + 135] {partition_indices = [135], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %103 = arith.mulf %95, %102 {timing = #hlscpp.t<37 -> 41, 4, 1>} : f64
    %104 = arith.addf %91, %103 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f64
    %105 = affine.load %arg0[%arg4 * 256 + 199] {partition_indices = [199], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %106 = arith.mulf %95, %105 {timing = #hlscpp.t<37 -> 41, 4, 1>} : f64
    %107 = arith.addf %94, %106 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f64
    %108 = affine.load %arg1[8] {partition_indices = [8], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %109 = affine.load %arg0[%arg4 * 256 + 8] {partition_indices = [8], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %110 = arith.mulf %108, %109 {timing = #hlscpp.t<42 -> 46, 4, 1>} : f64
    %111 = arith.addf %98, %110 {timing = #hlscpp.t<46 -> 51, 5, 1>} : f64
    %112 = affine.load %arg0[%arg4 * 256 + 72] {partition_indices = [72], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %113 = arith.mulf %108, %112 {timing = #hlscpp.t<42 -> 46, 4, 1>} : f64
    %114 = arith.addf %101, %113 {timing = #hlscpp.t<46 -> 51, 5, 1>} : f64
    %115 = affine.load %arg0[%arg4 * 256 + 136] {partition_indices = [136], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %116 = arith.mulf %108, %115 {timing = #hlscpp.t<42 -> 46, 4, 1>} : f64
    %117 = arith.addf %104, %116 {timing = #hlscpp.t<46 -> 51, 5, 1>} : f64
    %118 = affine.load %arg0[%arg4 * 256 + 200] {partition_indices = [200], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %119 = arith.mulf %108, %118 {timing = #hlscpp.t<42 -> 46, 4, 1>} : f64
    %120 = arith.addf %107, %119 {timing = #hlscpp.t<46 -> 51, 5, 1>} : f64
    %121 = affine.load %arg1[9] {partition_indices = [9], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %122 = affine.load %arg0[%arg4 * 256 + 9] {partition_indices = [9], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %123 = arith.mulf %121, %122 {timing = #hlscpp.t<47 -> 51, 4, 1>} : f64
    %124 = arith.addf %111, %123 {timing = #hlscpp.t<51 -> 56, 5, 1>} : f64
    %125 = affine.load %arg0[%arg4 * 256 + 73] {partition_indices = [73], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %126 = arith.mulf %121, %125 {timing = #hlscpp.t<47 -> 51, 4, 1>} : f64
    %127 = arith.addf %114, %126 {timing = #hlscpp.t<51 -> 56, 5, 1>} : f64
    %128 = affine.load %arg0[%arg4 * 256 + 137] {partition_indices = [137], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %129 = arith.mulf %121, %128 {timing = #hlscpp.t<47 -> 51, 4, 1>} : f64
    %130 = arith.addf %117, %129 {timing = #hlscpp.t<51 -> 56, 5, 1>} : f64
    %131 = affine.load %arg0[%arg4 * 256 + 201] {partition_indices = [201], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %132 = arith.mulf %121, %131 {timing = #hlscpp.t<47 -> 51, 4, 1>} : f64
    %133 = arith.addf %120, %132 {timing = #hlscpp.t<51 -> 56, 5, 1>} : f64
    %134 = affine.load %arg1[10] {partition_indices = [10], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %135 = affine.load %arg0[%arg4 * 256 + 10] {partition_indices = [10], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %136 = arith.mulf %134, %135 {timing = #hlscpp.t<52 -> 56, 4, 1>} : f64
    %137 = arith.addf %124, %136 {timing = #hlscpp.t<56 -> 61, 5, 1>} : f64
    %138 = affine.load %arg0[%arg4 * 256 + 74] {partition_indices = [74], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %139 = arith.mulf %134, %138 {timing = #hlscpp.t<52 -> 56, 4, 1>} : f64
    %140 = arith.addf %127, %139 {timing = #hlscpp.t<56 -> 61, 5, 1>} : f64
    %141 = affine.load %arg0[%arg4 * 256 + 138] {partition_indices = [138], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %142 = arith.mulf %134, %141 {timing = #hlscpp.t<52 -> 56, 4, 1>} : f64
    %143 = arith.addf %130, %142 {timing = #hlscpp.t<56 -> 61, 5, 1>} : f64
    %144 = affine.load %arg0[%arg4 * 256 + 202] {partition_indices = [202], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %145 = arith.mulf %134, %144 {timing = #hlscpp.t<52 -> 56, 4, 1>} : f64
    %146 = arith.addf %133, %145 {timing = #hlscpp.t<56 -> 61, 5, 1>} : f64
    %147 = affine.load %arg1[11] {partition_indices = [11], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %148 = affine.load %arg0[%arg4 * 256 + 11] {partition_indices = [11], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %149 = arith.mulf %147, %148 {timing = #hlscpp.t<57 -> 61, 4, 1>} : f64
    %150 = arith.addf %137, %149 {timing = #hlscpp.t<61 -> 66, 5, 1>} : f64
    %151 = affine.load %arg0[%arg4 * 256 + 75] {partition_indices = [75], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %152 = arith.mulf %147, %151 {timing = #hlscpp.t<57 -> 61, 4, 1>} : f64
    %153 = arith.addf %140, %152 {timing = #hlscpp.t<61 -> 66, 5, 1>} : f64
    %154 = affine.load %arg0[%arg4 * 256 + 139] {partition_indices = [139], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %155 = arith.mulf %147, %154 {timing = #hlscpp.t<57 -> 61, 4, 1>} : f64
    %156 = arith.addf %143, %155 {timing = #hlscpp.t<61 -> 66, 5, 1>} : f64
    %157 = affine.load %arg0[%arg4 * 256 + 203] {partition_indices = [203], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %158 = arith.mulf %147, %157 {timing = #hlscpp.t<57 -> 61, 4, 1>} : f64
    %159 = arith.addf %146, %158 {timing = #hlscpp.t<61 -> 66, 5, 1>} : f64
    %160 = affine.load %arg1[12] {partition_indices = [12], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %161 = affine.load %arg0[%arg4 * 256 + 12] {partition_indices = [12], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %162 = arith.mulf %160, %161 {timing = #hlscpp.t<62 -> 66, 4, 1>} : f64
    %163 = arith.addf %150, %162 {timing = #hlscpp.t<66 -> 71, 5, 1>} : f64
    %164 = affine.load %arg0[%arg4 * 256 + 76] {partition_indices = [76], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %165 = arith.mulf %160, %164 {timing = #hlscpp.t<62 -> 66, 4, 1>} : f64
    %166 = arith.addf %153, %165 {timing = #hlscpp.t<66 -> 71, 5, 1>} : f64
    %167 = affine.load %arg0[%arg4 * 256 + 140] {partition_indices = [140], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %168 = arith.mulf %160, %167 {timing = #hlscpp.t<62 -> 66, 4, 1>} : f64
    %169 = arith.addf %156, %168 {timing = #hlscpp.t<66 -> 71, 5, 1>} : f64
    %170 = affine.load %arg0[%arg4 * 256 + 204] {partition_indices = [204], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %171 = arith.mulf %160, %170 {timing = #hlscpp.t<62 -> 66, 4, 1>} : f64
    %172 = arith.addf %159, %171 {timing = #hlscpp.t<66 -> 71, 5, 1>} : f64
    %173 = affine.load %arg1[13] {partition_indices = [13], timing = #hlscpp.t<65 -> 67, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %174 = affine.load %arg0[%arg4 * 256 + 13] {partition_indices = [13], timing = #hlscpp.t<65 -> 67, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %175 = arith.mulf %173, %174 {timing = #hlscpp.t<67 -> 71, 4, 1>} : f64
    %176 = arith.addf %163, %175 {timing = #hlscpp.t<71 -> 76, 5, 1>} : f64
    %177 = affine.load %arg0[%arg4 * 256 + 77] {partition_indices = [77], timing = #hlscpp.t<65 -> 67, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %178 = arith.mulf %173, %177 {timing = #hlscpp.t<67 -> 71, 4, 1>} : f64
    %179 = arith.addf %166, %178 {timing = #hlscpp.t<71 -> 76, 5, 1>} : f64
    %180 = affine.load %arg0[%arg4 * 256 + 141] {partition_indices = [141], timing = #hlscpp.t<65 -> 67, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %181 = arith.mulf %173, %180 {timing = #hlscpp.t<67 -> 71, 4, 1>} : f64
    %182 = arith.addf %169, %181 {timing = #hlscpp.t<71 -> 76, 5, 1>} : f64
    %183 = affine.load %arg0[%arg4 * 256 + 205] {partition_indices = [205], timing = #hlscpp.t<65 -> 67, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %184 = arith.mulf %173, %183 {timing = #hlscpp.t<67 -> 71, 4, 1>} : f64
    %185 = arith.addf %172, %184 {timing = #hlscpp.t<71 -> 76, 5, 1>} : f64
    %186 = affine.load %arg1[14] {partition_indices = [14], timing = #hlscpp.t<70 -> 72, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %187 = affine.load %arg0[%arg4 * 256 + 14] {partition_indices = [14], timing = #hlscpp.t<70 -> 72, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %188 = arith.mulf %186, %187 {timing = #hlscpp.t<72 -> 76, 4, 1>} : f64
    %189 = arith.addf %176, %188 {timing = #hlscpp.t<76 -> 81, 5, 1>} : f64
    %190 = affine.load %arg0[%arg4 * 256 + 78] {partition_indices = [78], timing = #hlscpp.t<70 -> 72, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %191 = arith.mulf %186, %190 {timing = #hlscpp.t<72 -> 76, 4, 1>} : f64
    %192 = arith.addf %179, %191 {timing = #hlscpp.t<76 -> 81, 5, 1>} : f64
    %193 = affine.load %arg0[%arg4 * 256 + 142] {partition_indices = [142], timing = #hlscpp.t<70 -> 72, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %194 = arith.mulf %186, %193 {timing = #hlscpp.t<72 -> 76, 4, 1>} : f64
    %195 = arith.addf %182, %194 {timing = #hlscpp.t<76 -> 81, 5, 1>} : f64
    %196 = affine.load %arg0[%arg4 * 256 + 206] {partition_indices = [206], timing = #hlscpp.t<70 -> 72, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %197 = arith.mulf %186, %196 {timing = #hlscpp.t<72 -> 76, 4, 1>} : f64
    %198 = arith.addf %185, %197 {timing = #hlscpp.t<76 -> 81, 5, 1>} : f64
    %199 = affine.load %arg1[15] {partition_indices = [15], timing = #hlscpp.t<75 -> 77, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %200 = affine.load %arg0[%arg4 * 256 + 15] {partition_indices = [15], timing = #hlscpp.t<75 -> 77, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %201 = arith.mulf %199, %200 {timing = #hlscpp.t<77 -> 81, 4, 1>} : f64
    %202 = arith.addf %189, %201 {timing = #hlscpp.t<81 -> 86, 5, 1>} : f64
    %203 = affine.load %arg0[%arg4 * 256 + 79] {partition_indices = [79], timing = #hlscpp.t<75 -> 77, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %204 = arith.mulf %199, %203 {timing = #hlscpp.t<77 -> 81, 4, 1>} : f64
    %205 = arith.addf %192, %204 {timing = #hlscpp.t<81 -> 86, 5, 1>} : f64
    %206 = affine.load %arg0[%arg4 * 256 + 143] {partition_indices = [143], timing = #hlscpp.t<75 -> 77, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %207 = arith.mulf %199, %206 {timing = #hlscpp.t<77 -> 81, 4, 1>} : f64
    %208 = arith.addf %195, %207 {timing = #hlscpp.t<81 -> 86, 5, 1>} : f64
    %209 = affine.load %arg0[%arg4 * 256 + 207] {partition_indices = [207], timing = #hlscpp.t<75 -> 77, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %210 = arith.mulf %199, %209 {timing = #hlscpp.t<77 -> 81, 4, 1>} : f64
    %211 = arith.addf %198, %210 {timing = #hlscpp.t<81 -> 86, 5, 1>} : f64
    %212 = affine.load %arg1[16] {partition_indices = [16], timing = #hlscpp.t<80 -> 82, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %213 = affine.load %arg0[%arg4 * 256 + 16] {partition_indices = [16], timing = #hlscpp.t<80 -> 82, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %214 = arith.mulf %212, %213 {timing = #hlscpp.t<82 -> 86, 4, 1>} : f64
    %215 = arith.addf %202, %214 {timing = #hlscpp.t<86 -> 91, 5, 1>} : f64
    %216 = affine.load %arg0[%arg4 * 256 + 80] {partition_indices = [80], timing = #hlscpp.t<80 -> 82, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %217 = arith.mulf %212, %216 {timing = #hlscpp.t<82 -> 86, 4, 1>} : f64
    %218 = arith.addf %205, %217 {timing = #hlscpp.t<86 -> 91, 5, 1>} : f64
    %219 = affine.load %arg0[%arg4 * 256 + 144] {partition_indices = [144], timing = #hlscpp.t<80 -> 82, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %220 = arith.mulf %212, %219 {timing = #hlscpp.t<82 -> 86, 4, 1>} : f64
    %221 = arith.addf %208, %220 {timing = #hlscpp.t<86 -> 91, 5, 1>} : f64
    %222 = affine.load %arg0[%arg4 * 256 + 208] {partition_indices = [208], timing = #hlscpp.t<80 -> 82, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %223 = arith.mulf %212, %222 {timing = #hlscpp.t<82 -> 86, 4, 1>} : f64
    %224 = arith.addf %211, %223 {timing = #hlscpp.t<86 -> 91, 5, 1>} : f64
    %225 = affine.load %arg1[17] {partition_indices = [17], timing = #hlscpp.t<85 -> 87, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %226 = affine.load %arg0[%arg4 * 256 + 17] {partition_indices = [17], timing = #hlscpp.t<85 -> 87, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %227 = arith.mulf %225, %226 {timing = #hlscpp.t<87 -> 91, 4, 1>} : f64
    %228 = arith.addf %215, %227 {timing = #hlscpp.t<91 -> 96, 5, 1>} : f64
    %229 = affine.load %arg0[%arg4 * 256 + 81] {partition_indices = [81], timing = #hlscpp.t<85 -> 87, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %230 = arith.mulf %225, %229 {timing = #hlscpp.t<87 -> 91, 4, 1>} : f64
    %231 = arith.addf %218, %230 {timing = #hlscpp.t<91 -> 96, 5, 1>} : f64
    %232 = affine.load %arg0[%arg4 * 256 + 145] {partition_indices = [145], timing = #hlscpp.t<85 -> 87, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %233 = arith.mulf %225, %232 {timing = #hlscpp.t<87 -> 91, 4, 1>} : f64
    %234 = arith.addf %221, %233 {timing = #hlscpp.t<91 -> 96, 5, 1>} : f64
    %235 = affine.load %arg0[%arg4 * 256 + 209] {partition_indices = [209], timing = #hlscpp.t<85 -> 87, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %236 = arith.mulf %225, %235 {timing = #hlscpp.t<87 -> 91, 4, 1>} : f64
    %237 = arith.addf %224, %236 {timing = #hlscpp.t<91 -> 96, 5, 1>} : f64
    %238 = affine.load %arg1[18] {partition_indices = [18], timing = #hlscpp.t<90 -> 92, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %239 = affine.load %arg0[%arg4 * 256 + 18] {partition_indices = [18], timing = #hlscpp.t<90 -> 92, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %240 = arith.mulf %238, %239 {timing = #hlscpp.t<92 -> 96, 4, 1>} : f64
    %241 = arith.addf %228, %240 {timing = #hlscpp.t<96 -> 101, 5, 1>} : f64
    %242 = affine.load %arg0[%arg4 * 256 + 82] {partition_indices = [82], timing = #hlscpp.t<90 -> 92, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %243 = arith.mulf %238, %242 {timing = #hlscpp.t<92 -> 96, 4, 1>} : f64
    %244 = arith.addf %231, %243 {timing = #hlscpp.t<96 -> 101, 5, 1>} : f64
    %245 = affine.load %arg0[%arg4 * 256 + 146] {partition_indices = [146], timing = #hlscpp.t<90 -> 92, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %246 = arith.mulf %238, %245 {timing = #hlscpp.t<92 -> 96, 4, 1>} : f64
    %247 = arith.addf %234, %246 {timing = #hlscpp.t<96 -> 101, 5, 1>} : f64
    %248 = affine.load %arg0[%arg4 * 256 + 210] {partition_indices = [210], timing = #hlscpp.t<90 -> 92, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %249 = arith.mulf %238, %248 {timing = #hlscpp.t<92 -> 96, 4, 1>} : f64
    %250 = arith.addf %237, %249 {timing = #hlscpp.t<96 -> 101, 5, 1>} : f64
    %251 = affine.load %arg1[19] {partition_indices = [19], timing = #hlscpp.t<95 -> 97, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %252 = affine.load %arg0[%arg4 * 256 + 19] {partition_indices = [19], timing = #hlscpp.t<95 -> 97, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %253 = arith.mulf %251, %252 {timing = #hlscpp.t<97 -> 101, 4, 1>} : f64
    %254 = arith.addf %241, %253 {timing = #hlscpp.t<101 -> 106, 5, 1>} : f64
    %255 = affine.load %arg0[%arg4 * 256 + 83] {partition_indices = [83], timing = #hlscpp.t<95 -> 97, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %256 = arith.mulf %251, %255 {timing = #hlscpp.t<97 -> 101, 4, 1>} : f64
    %257 = arith.addf %244, %256 {timing = #hlscpp.t<101 -> 106, 5, 1>} : f64
    %258 = affine.load %arg0[%arg4 * 256 + 147] {partition_indices = [147], timing = #hlscpp.t<95 -> 97, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %259 = arith.mulf %251, %258 {timing = #hlscpp.t<97 -> 101, 4, 1>} : f64
    %260 = arith.addf %247, %259 {timing = #hlscpp.t<101 -> 106, 5, 1>} : f64
    %261 = affine.load %arg0[%arg4 * 256 + 211] {partition_indices = [211], timing = #hlscpp.t<95 -> 97, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %262 = arith.mulf %251, %261 {timing = #hlscpp.t<97 -> 101, 4, 1>} : f64
    %263 = arith.addf %250, %262 {timing = #hlscpp.t<101 -> 106, 5, 1>} : f64
    %264 = affine.load %arg1[20] {partition_indices = [20], timing = #hlscpp.t<100 -> 102, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %265 = affine.load %arg0[%arg4 * 256 + 20] {partition_indices = [20], timing = #hlscpp.t<100 -> 102, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %266 = arith.mulf %264, %265 {timing = #hlscpp.t<102 -> 106, 4, 1>} : f64
    %267 = arith.addf %254, %266 {timing = #hlscpp.t<106 -> 111, 5, 1>} : f64
    %268 = affine.load %arg0[%arg4 * 256 + 84] {partition_indices = [84], timing = #hlscpp.t<100 -> 102, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %269 = arith.mulf %264, %268 {timing = #hlscpp.t<102 -> 106, 4, 1>} : f64
    %270 = arith.addf %257, %269 {timing = #hlscpp.t<106 -> 111, 5, 1>} : f64
    %271 = affine.load %arg0[%arg4 * 256 + 148] {partition_indices = [148], timing = #hlscpp.t<100 -> 102, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %272 = arith.mulf %264, %271 {timing = #hlscpp.t<102 -> 106, 4, 1>} : f64
    %273 = arith.addf %260, %272 {timing = #hlscpp.t<106 -> 111, 5, 1>} : f64
    %274 = affine.load %arg0[%arg4 * 256 + 212] {partition_indices = [212], timing = #hlscpp.t<100 -> 102, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %275 = arith.mulf %264, %274 {timing = #hlscpp.t<102 -> 106, 4, 1>} : f64
    %276 = arith.addf %263, %275 {timing = #hlscpp.t<106 -> 111, 5, 1>} : f64
    %277 = affine.load %arg1[21] {partition_indices = [21], timing = #hlscpp.t<105 -> 107, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %278 = affine.load %arg0[%arg4 * 256 + 21] {partition_indices = [21], timing = #hlscpp.t<105 -> 107, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %279 = arith.mulf %277, %278 {timing = #hlscpp.t<107 -> 111, 4, 1>} : f64
    %280 = arith.addf %267, %279 {timing = #hlscpp.t<111 -> 116, 5, 1>} : f64
    %281 = affine.load %arg0[%arg4 * 256 + 85] {partition_indices = [85], timing = #hlscpp.t<105 -> 107, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %282 = arith.mulf %277, %281 {timing = #hlscpp.t<107 -> 111, 4, 1>} : f64
    %283 = arith.addf %270, %282 {timing = #hlscpp.t<111 -> 116, 5, 1>} : f64
    %284 = affine.load %arg0[%arg4 * 256 + 149] {partition_indices = [149], timing = #hlscpp.t<105 -> 107, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %285 = arith.mulf %277, %284 {timing = #hlscpp.t<107 -> 111, 4, 1>} : f64
    %286 = arith.addf %273, %285 {timing = #hlscpp.t<111 -> 116, 5, 1>} : f64
    %287 = affine.load %arg0[%arg4 * 256 + 213] {partition_indices = [213], timing = #hlscpp.t<105 -> 107, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %288 = arith.mulf %277, %287 {timing = #hlscpp.t<107 -> 111, 4, 1>} : f64
    %289 = arith.addf %276, %288 {timing = #hlscpp.t<111 -> 116, 5, 1>} : f64
    %290 = affine.load %arg1[22] {partition_indices = [22], timing = #hlscpp.t<110 -> 112, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %291 = affine.load %arg0[%arg4 * 256 + 22] {partition_indices = [22], timing = #hlscpp.t<110 -> 112, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %292 = arith.mulf %290, %291 {timing = #hlscpp.t<112 -> 116, 4, 1>} : f64
    %293 = arith.addf %280, %292 {timing = #hlscpp.t<116 -> 121, 5, 1>} : f64
    %294 = affine.load %arg0[%arg4 * 256 + 86] {partition_indices = [86], timing = #hlscpp.t<110 -> 112, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %295 = arith.mulf %290, %294 {timing = #hlscpp.t<112 -> 116, 4, 1>} : f64
    %296 = arith.addf %283, %295 {timing = #hlscpp.t<116 -> 121, 5, 1>} : f64
    %297 = affine.load %arg0[%arg4 * 256 + 150] {partition_indices = [150], timing = #hlscpp.t<110 -> 112, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %298 = arith.mulf %290, %297 {timing = #hlscpp.t<112 -> 116, 4, 1>} : f64
    %299 = arith.addf %286, %298 {timing = #hlscpp.t<116 -> 121, 5, 1>} : f64
    %300 = affine.load %arg0[%arg4 * 256 + 214] {partition_indices = [214], timing = #hlscpp.t<110 -> 112, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %301 = arith.mulf %290, %300 {timing = #hlscpp.t<112 -> 116, 4, 1>} : f64
    %302 = arith.addf %289, %301 {timing = #hlscpp.t<116 -> 121, 5, 1>} : f64
    %303 = affine.load %arg1[23] {partition_indices = [23], timing = #hlscpp.t<115 -> 117, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %304 = affine.load %arg0[%arg4 * 256 + 23] {partition_indices = [23], timing = #hlscpp.t<115 -> 117, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %305 = arith.mulf %303, %304 {timing = #hlscpp.t<117 -> 121, 4, 1>} : f64
    %306 = arith.addf %293, %305 {timing = #hlscpp.t<121 -> 126, 5, 1>} : f64
    %307 = affine.load %arg0[%arg4 * 256 + 87] {partition_indices = [87], timing = #hlscpp.t<115 -> 117, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %308 = arith.mulf %303, %307 {timing = #hlscpp.t<117 -> 121, 4, 1>} : f64
    %309 = arith.addf %296, %308 {timing = #hlscpp.t<121 -> 126, 5, 1>} : f64
    %310 = affine.load %arg0[%arg4 * 256 + 151] {partition_indices = [151], timing = #hlscpp.t<115 -> 117, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %311 = arith.mulf %303, %310 {timing = #hlscpp.t<117 -> 121, 4, 1>} : f64
    %312 = arith.addf %299, %311 {timing = #hlscpp.t<121 -> 126, 5, 1>} : f64
    %313 = affine.load %arg0[%arg4 * 256 + 215] {partition_indices = [215], timing = #hlscpp.t<115 -> 117, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %314 = arith.mulf %303, %313 {timing = #hlscpp.t<117 -> 121, 4, 1>} : f64
    %315 = arith.addf %302, %314 {timing = #hlscpp.t<121 -> 126, 5, 1>} : f64
    %316 = affine.load %arg1[24] {partition_indices = [24], timing = #hlscpp.t<120 -> 122, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %317 = affine.load %arg0[%arg4 * 256 + 24] {partition_indices = [24], timing = #hlscpp.t<120 -> 122, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %318 = arith.mulf %316, %317 {timing = #hlscpp.t<122 -> 126, 4, 1>} : f64
    %319 = arith.addf %306, %318 {timing = #hlscpp.t<126 -> 131, 5, 1>} : f64
    %320 = affine.load %arg0[%arg4 * 256 + 88] {partition_indices = [88], timing = #hlscpp.t<120 -> 122, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %321 = arith.mulf %316, %320 {timing = #hlscpp.t<122 -> 126, 4, 1>} : f64
    %322 = arith.addf %309, %321 {timing = #hlscpp.t<126 -> 131, 5, 1>} : f64
    %323 = affine.load %arg0[%arg4 * 256 + 152] {partition_indices = [152], timing = #hlscpp.t<120 -> 122, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %324 = arith.mulf %316, %323 {timing = #hlscpp.t<122 -> 126, 4, 1>} : f64
    %325 = arith.addf %312, %324 {timing = #hlscpp.t<126 -> 131, 5, 1>} : f64
    %326 = affine.load %arg0[%arg4 * 256 + 216] {partition_indices = [216], timing = #hlscpp.t<120 -> 122, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %327 = arith.mulf %316, %326 {timing = #hlscpp.t<122 -> 126, 4, 1>} : f64
    %328 = arith.addf %315, %327 {timing = #hlscpp.t<126 -> 131, 5, 1>} : f64
    %329 = affine.load %arg1[25] {partition_indices = [25], timing = #hlscpp.t<125 -> 127, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %330 = affine.load %arg0[%arg4 * 256 + 25] {partition_indices = [25], timing = #hlscpp.t<125 -> 127, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %331 = arith.mulf %329, %330 {timing = #hlscpp.t<127 -> 131, 4, 1>} : f64
    %332 = arith.addf %319, %331 {timing = #hlscpp.t<131 -> 136, 5, 1>} : f64
    %333 = affine.load %arg0[%arg4 * 256 + 89] {partition_indices = [89], timing = #hlscpp.t<125 -> 127, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %334 = arith.mulf %329, %333 {timing = #hlscpp.t<127 -> 131, 4, 1>} : f64
    %335 = arith.addf %322, %334 {timing = #hlscpp.t<131 -> 136, 5, 1>} : f64
    %336 = affine.load %arg0[%arg4 * 256 + 153] {partition_indices = [153], timing = #hlscpp.t<125 -> 127, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %337 = arith.mulf %329, %336 {timing = #hlscpp.t<127 -> 131, 4, 1>} : f64
    %338 = arith.addf %325, %337 {timing = #hlscpp.t<131 -> 136, 5, 1>} : f64
    %339 = affine.load %arg0[%arg4 * 256 + 217] {partition_indices = [217], timing = #hlscpp.t<125 -> 127, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %340 = arith.mulf %329, %339 {timing = #hlscpp.t<127 -> 131, 4, 1>} : f64
    %341 = arith.addf %328, %340 {timing = #hlscpp.t<131 -> 136, 5, 1>} : f64
    %342 = affine.load %arg1[26] {partition_indices = [26], timing = #hlscpp.t<130 -> 132, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %343 = affine.load %arg0[%arg4 * 256 + 26] {partition_indices = [26], timing = #hlscpp.t<130 -> 132, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %344 = arith.mulf %342, %343 {timing = #hlscpp.t<132 -> 136, 4, 1>} : f64
    %345 = arith.addf %332, %344 {timing = #hlscpp.t<136 -> 141, 5, 1>} : f64
    %346 = affine.load %arg0[%arg4 * 256 + 90] {partition_indices = [90], timing = #hlscpp.t<130 -> 132, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %347 = arith.mulf %342, %346 {timing = #hlscpp.t<132 -> 136, 4, 1>} : f64
    %348 = arith.addf %335, %347 {timing = #hlscpp.t<136 -> 141, 5, 1>} : f64
    %349 = affine.load %arg0[%arg4 * 256 + 154] {partition_indices = [154], timing = #hlscpp.t<130 -> 132, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %350 = arith.mulf %342, %349 {timing = #hlscpp.t<132 -> 136, 4, 1>} : f64
    %351 = arith.addf %338, %350 {timing = #hlscpp.t<136 -> 141, 5, 1>} : f64
    %352 = affine.load %arg0[%arg4 * 256 + 218] {partition_indices = [218], timing = #hlscpp.t<130 -> 132, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %353 = arith.mulf %342, %352 {timing = #hlscpp.t<132 -> 136, 4, 1>} : f64
    %354 = arith.addf %341, %353 {timing = #hlscpp.t<136 -> 141, 5, 1>} : f64
    %355 = affine.load %arg1[27] {partition_indices = [27], timing = #hlscpp.t<135 -> 137, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %356 = affine.load %arg0[%arg4 * 256 + 27] {partition_indices = [27], timing = #hlscpp.t<135 -> 137, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %357 = arith.mulf %355, %356 {timing = #hlscpp.t<137 -> 141, 4, 1>} : f64
    %358 = arith.addf %345, %357 {timing = #hlscpp.t<141 -> 146, 5, 1>} : f64
    %359 = affine.load %arg0[%arg4 * 256 + 91] {partition_indices = [91], timing = #hlscpp.t<135 -> 137, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %360 = arith.mulf %355, %359 {timing = #hlscpp.t<137 -> 141, 4, 1>} : f64
    %361 = arith.addf %348, %360 {timing = #hlscpp.t<141 -> 146, 5, 1>} : f64
    %362 = affine.load %arg0[%arg4 * 256 + 155] {partition_indices = [155], timing = #hlscpp.t<135 -> 137, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %363 = arith.mulf %355, %362 {timing = #hlscpp.t<137 -> 141, 4, 1>} : f64
    %364 = arith.addf %351, %363 {timing = #hlscpp.t<141 -> 146, 5, 1>} : f64
    %365 = affine.load %arg0[%arg4 * 256 + 219] {partition_indices = [219], timing = #hlscpp.t<135 -> 137, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %366 = arith.mulf %355, %365 {timing = #hlscpp.t<137 -> 141, 4, 1>} : f64
    %367 = arith.addf %354, %366 {timing = #hlscpp.t<141 -> 146, 5, 1>} : f64
    %368 = affine.load %arg1[28] {partition_indices = [28], timing = #hlscpp.t<140 -> 142, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %369 = affine.load %arg0[%arg4 * 256 + 28] {partition_indices = [28], timing = #hlscpp.t<140 -> 142, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %370 = arith.mulf %368, %369 {timing = #hlscpp.t<142 -> 146, 4, 1>} : f64
    %371 = arith.addf %358, %370 {timing = #hlscpp.t<146 -> 151, 5, 1>} : f64
    %372 = affine.load %arg0[%arg4 * 256 + 92] {partition_indices = [92], timing = #hlscpp.t<140 -> 142, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %373 = arith.mulf %368, %372 {timing = #hlscpp.t<142 -> 146, 4, 1>} : f64
    %374 = arith.addf %361, %373 {timing = #hlscpp.t<146 -> 151, 5, 1>} : f64
    %375 = affine.load %arg0[%arg4 * 256 + 156] {partition_indices = [156], timing = #hlscpp.t<140 -> 142, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %376 = arith.mulf %368, %375 {timing = #hlscpp.t<142 -> 146, 4, 1>} : f64
    %377 = arith.addf %364, %376 {timing = #hlscpp.t<146 -> 151, 5, 1>} : f64
    %378 = affine.load %arg0[%arg4 * 256 + 220] {partition_indices = [220], timing = #hlscpp.t<140 -> 142, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %379 = arith.mulf %368, %378 {timing = #hlscpp.t<142 -> 146, 4, 1>} : f64
    %380 = arith.addf %367, %379 {timing = #hlscpp.t<146 -> 151, 5, 1>} : f64
    %381 = affine.load %arg1[29] {partition_indices = [29], timing = #hlscpp.t<145 -> 147, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %382 = affine.load %arg0[%arg4 * 256 + 29] {partition_indices = [29], timing = #hlscpp.t<145 -> 147, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %383 = arith.mulf %381, %382 {timing = #hlscpp.t<147 -> 151, 4, 1>} : f64
    %384 = arith.addf %371, %383 {timing = #hlscpp.t<151 -> 156, 5, 1>} : f64
    %385 = affine.load %arg0[%arg4 * 256 + 93] {partition_indices = [93], timing = #hlscpp.t<145 -> 147, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %386 = arith.mulf %381, %385 {timing = #hlscpp.t<147 -> 151, 4, 1>} : f64
    %387 = arith.addf %374, %386 {timing = #hlscpp.t<151 -> 156, 5, 1>} : f64
    %388 = affine.load %arg0[%arg4 * 256 + 157] {partition_indices = [157], timing = #hlscpp.t<145 -> 147, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %389 = arith.mulf %381, %388 {timing = #hlscpp.t<147 -> 151, 4, 1>} : f64
    %390 = arith.addf %377, %389 {timing = #hlscpp.t<151 -> 156, 5, 1>} : f64
    %391 = affine.load %arg0[%arg4 * 256 + 221] {partition_indices = [221], timing = #hlscpp.t<145 -> 147, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %392 = arith.mulf %381, %391 {timing = #hlscpp.t<147 -> 151, 4, 1>} : f64
    %393 = arith.addf %380, %392 {timing = #hlscpp.t<151 -> 156, 5, 1>} : f64
    %394 = affine.load %arg1[30] {partition_indices = [30], timing = #hlscpp.t<150 -> 152, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %395 = affine.load %arg0[%arg4 * 256 + 30] {partition_indices = [30], timing = #hlscpp.t<150 -> 152, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %396 = arith.mulf %394, %395 {timing = #hlscpp.t<152 -> 156, 4, 1>} : f64
    %397 = arith.addf %384, %396 {timing = #hlscpp.t<156 -> 161, 5, 1>} : f64
    %398 = affine.load %arg0[%arg4 * 256 + 94] {partition_indices = [94], timing = #hlscpp.t<150 -> 152, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %399 = arith.mulf %394, %398 {timing = #hlscpp.t<152 -> 156, 4, 1>} : f64
    %400 = arith.addf %387, %399 {timing = #hlscpp.t<156 -> 161, 5, 1>} : f64
    %401 = affine.load %arg0[%arg4 * 256 + 158] {partition_indices = [158], timing = #hlscpp.t<150 -> 152, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %402 = arith.mulf %394, %401 {timing = #hlscpp.t<152 -> 156, 4, 1>} : f64
    %403 = arith.addf %390, %402 {timing = #hlscpp.t<156 -> 161, 5, 1>} : f64
    %404 = affine.load %arg0[%arg4 * 256 + 222] {partition_indices = [222], timing = #hlscpp.t<150 -> 152, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %405 = arith.mulf %394, %404 {timing = #hlscpp.t<152 -> 156, 4, 1>} : f64
    %406 = arith.addf %393, %405 {timing = #hlscpp.t<156 -> 161, 5, 1>} : f64
    %407 = affine.load %arg1[31] {partition_indices = [31], timing = #hlscpp.t<155 -> 157, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %408 = affine.load %arg0[%arg4 * 256 + 31] {partition_indices = [31], timing = #hlscpp.t<155 -> 157, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %409 = arith.mulf %407, %408 {timing = #hlscpp.t<157 -> 161, 4, 1>} : f64
    %410 = arith.addf %397, %409 {timing = #hlscpp.t<161 -> 166, 5, 1>} : f64
    %411 = affine.load %arg0[%arg4 * 256 + 95] {partition_indices = [95], timing = #hlscpp.t<155 -> 157, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %412 = arith.mulf %407, %411 {timing = #hlscpp.t<157 -> 161, 4, 1>} : f64
    %413 = arith.addf %400, %412 {timing = #hlscpp.t<161 -> 166, 5, 1>} : f64
    %414 = affine.load %arg0[%arg4 * 256 + 159] {partition_indices = [159], timing = #hlscpp.t<155 -> 157, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %415 = arith.mulf %407, %414 {timing = #hlscpp.t<157 -> 161, 4, 1>} : f64
    %416 = arith.addf %403, %415 {timing = #hlscpp.t<161 -> 166, 5, 1>} : f64
    %417 = affine.load %arg0[%arg4 * 256 + 223] {partition_indices = [223], timing = #hlscpp.t<155 -> 157, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %418 = arith.mulf %407, %417 {timing = #hlscpp.t<157 -> 161, 4, 1>} : f64
    %419 = arith.addf %406, %418 {timing = #hlscpp.t<161 -> 166, 5, 1>} : f64
    %420 = affine.load %arg1[32] {partition_indices = [32], timing = #hlscpp.t<160 -> 162, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %421 = affine.load %arg0[%arg4 * 256 + 32] {partition_indices = [32], timing = #hlscpp.t<160 -> 162, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %422 = arith.mulf %420, %421 {timing = #hlscpp.t<162 -> 166, 4, 1>} : f64
    %423 = arith.addf %410, %422 {timing = #hlscpp.t<166 -> 171, 5, 1>} : f64
    %424 = affine.load %arg0[%arg4 * 256 + 96] {partition_indices = [96], timing = #hlscpp.t<160 -> 162, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %425 = arith.mulf %420, %424 {timing = #hlscpp.t<162 -> 166, 4, 1>} : f64
    %426 = arith.addf %413, %425 {timing = #hlscpp.t<166 -> 171, 5, 1>} : f64
    %427 = affine.load %arg0[%arg4 * 256 + 160] {partition_indices = [160], timing = #hlscpp.t<160 -> 162, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %428 = arith.mulf %420, %427 {timing = #hlscpp.t<162 -> 166, 4, 1>} : f64
    %429 = arith.addf %416, %428 {timing = #hlscpp.t<166 -> 171, 5, 1>} : f64
    %430 = affine.load %arg0[%arg4 * 256 + 224] {partition_indices = [224], timing = #hlscpp.t<160 -> 162, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %431 = arith.mulf %420, %430 {timing = #hlscpp.t<162 -> 166, 4, 1>} : f64
    %432 = arith.addf %419, %431 {timing = #hlscpp.t<166 -> 171, 5, 1>} : f64
    %433 = affine.load %arg1[33] {partition_indices = [33], timing = #hlscpp.t<165 -> 167, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %434 = affine.load %arg0[%arg4 * 256 + 33] {partition_indices = [33], timing = #hlscpp.t<165 -> 167, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %435 = arith.mulf %433, %434 {timing = #hlscpp.t<167 -> 171, 4, 1>} : f64
    %436 = arith.addf %423, %435 {timing = #hlscpp.t<171 -> 176, 5, 1>} : f64
    %437 = affine.load %arg0[%arg4 * 256 + 97] {partition_indices = [97], timing = #hlscpp.t<165 -> 167, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %438 = arith.mulf %433, %437 {timing = #hlscpp.t<167 -> 171, 4, 1>} : f64
    %439 = arith.addf %426, %438 {timing = #hlscpp.t<171 -> 176, 5, 1>} : f64
    %440 = affine.load %arg0[%arg4 * 256 + 161] {partition_indices = [161], timing = #hlscpp.t<165 -> 167, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %441 = arith.mulf %433, %440 {timing = #hlscpp.t<167 -> 171, 4, 1>} : f64
    %442 = arith.addf %429, %441 {timing = #hlscpp.t<171 -> 176, 5, 1>} : f64
    %443 = affine.load %arg0[%arg4 * 256 + 225] {partition_indices = [225], timing = #hlscpp.t<165 -> 167, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %444 = arith.mulf %433, %443 {timing = #hlscpp.t<167 -> 171, 4, 1>} : f64
    %445 = arith.addf %432, %444 {timing = #hlscpp.t<171 -> 176, 5, 1>} : f64
    %446 = affine.load %arg1[34] {partition_indices = [34], timing = #hlscpp.t<170 -> 172, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %447 = affine.load %arg0[%arg4 * 256 + 34] {partition_indices = [34], timing = #hlscpp.t<170 -> 172, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %448 = arith.mulf %446, %447 {timing = #hlscpp.t<172 -> 176, 4, 1>} : f64
    %449 = arith.addf %436, %448 {timing = #hlscpp.t<176 -> 181, 5, 1>} : f64
    %450 = affine.load %arg0[%arg4 * 256 + 98] {partition_indices = [98], timing = #hlscpp.t<170 -> 172, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %451 = arith.mulf %446, %450 {timing = #hlscpp.t<172 -> 176, 4, 1>} : f64
    %452 = arith.addf %439, %451 {timing = #hlscpp.t<176 -> 181, 5, 1>} : f64
    %453 = affine.load %arg0[%arg4 * 256 + 162] {partition_indices = [162], timing = #hlscpp.t<170 -> 172, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %454 = arith.mulf %446, %453 {timing = #hlscpp.t<172 -> 176, 4, 1>} : f64
    %455 = arith.addf %442, %454 {timing = #hlscpp.t<176 -> 181, 5, 1>} : f64
    %456 = affine.load %arg0[%arg4 * 256 + 226] {partition_indices = [226], timing = #hlscpp.t<170 -> 172, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %457 = arith.mulf %446, %456 {timing = #hlscpp.t<172 -> 176, 4, 1>} : f64
    %458 = arith.addf %445, %457 {timing = #hlscpp.t<176 -> 181, 5, 1>} : f64
    %459 = affine.load %arg1[35] {partition_indices = [35], timing = #hlscpp.t<175 -> 177, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %460 = affine.load %arg0[%arg4 * 256 + 35] {partition_indices = [35], timing = #hlscpp.t<175 -> 177, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %461 = arith.mulf %459, %460 {timing = #hlscpp.t<177 -> 181, 4, 1>} : f64
    %462 = arith.addf %449, %461 {timing = #hlscpp.t<181 -> 186, 5, 1>} : f64
    %463 = affine.load %arg0[%arg4 * 256 + 99] {partition_indices = [99], timing = #hlscpp.t<175 -> 177, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %464 = arith.mulf %459, %463 {timing = #hlscpp.t<177 -> 181, 4, 1>} : f64
    %465 = arith.addf %452, %464 {timing = #hlscpp.t<181 -> 186, 5, 1>} : f64
    %466 = affine.load %arg0[%arg4 * 256 + 163] {partition_indices = [163], timing = #hlscpp.t<175 -> 177, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %467 = arith.mulf %459, %466 {timing = #hlscpp.t<177 -> 181, 4, 1>} : f64
    %468 = arith.addf %455, %467 {timing = #hlscpp.t<181 -> 186, 5, 1>} : f64
    %469 = affine.load %arg0[%arg4 * 256 + 227] {partition_indices = [227], timing = #hlscpp.t<175 -> 177, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %470 = arith.mulf %459, %469 {timing = #hlscpp.t<177 -> 181, 4, 1>} : f64
    %471 = arith.addf %458, %470 {timing = #hlscpp.t<181 -> 186, 5, 1>} : f64
    %472 = affine.load %arg1[36] {partition_indices = [36], timing = #hlscpp.t<180 -> 182, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %473 = affine.load %arg0[%arg4 * 256 + 36] {partition_indices = [36], timing = #hlscpp.t<180 -> 182, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %474 = arith.mulf %472, %473 {timing = #hlscpp.t<182 -> 186, 4, 1>} : f64
    %475 = arith.addf %462, %474 {timing = #hlscpp.t<186 -> 191, 5, 1>} : f64
    %476 = affine.load %arg0[%arg4 * 256 + 100] {partition_indices = [100], timing = #hlscpp.t<180 -> 182, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %477 = arith.mulf %472, %476 {timing = #hlscpp.t<182 -> 186, 4, 1>} : f64
    %478 = arith.addf %465, %477 {timing = #hlscpp.t<186 -> 191, 5, 1>} : f64
    %479 = affine.load %arg0[%arg4 * 256 + 164] {partition_indices = [164], timing = #hlscpp.t<180 -> 182, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %480 = arith.mulf %472, %479 {timing = #hlscpp.t<182 -> 186, 4, 1>} : f64
    %481 = arith.addf %468, %480 {timing = #hlscpp.t<186 -> 191, 5, 1>} : f64
    %482 = affine.load %arg0[%arg4 * 256 + 228] {partition_indices = [228], timing = #hlscpp.t<180 -> 182, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %483 = arith.mulf %472, %482 {timing = #hlscpp.t<182 -> 186, 4, 1>} : f64
    %484 = arith.addf %471, %483 {timing = #hlscpp.t<186 -> 191, 5, 1>} : f64
    %485 = affine.load %arg1[37] {partition_indices = [37], timing = #hlscpp.t<185 -> 187, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %486 = affine.load %arg0[%arg4 * 256 + 37] {partition_indices = [37], timing = #hlscpp.t<185 -> 187, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %487 = arith.mulf %485, %486 {timing = #hlscpp.t<187 -> 191, 4, 1>} : f64
    %488 = arith.addf %475, %487 {timing = #hlscpp.t<191 -> 196, 5, 1>} : f64
    %489 = affine.load %arg0[%arg4 * 256 + 101] {partition_indices = [101], timing = #hlscpp.t<185 -> 187, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %490 = arith.mulf %485, %489 {timing = #hlscpp.t<187 -> 191, 4, 1>} : f64
    %491 = arith.addf %478, %490 {timing = #hlscpp.t<191 -> 196, 5, 1>} : f64
    %492 = affine.load %arg0[%arg4 * 256 + 165] {partition_indices = [165], timing = #hlscpp.t<185 -> 187, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %493 = arith.mulf %485, %492 {timing = #hlscpp.t<187 -> 191, 4, 1>} : f64
    %494 = arith.addf %481, %493 {timing = #hlscpp.t<191 -> 196, 5, 1>} : f64
    %495 = affine.load %arg0[%arg4 * 256 + 229] {partition_indices = [229], timing = #hlscpp.t<185 -> 187, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %496 = arith.mulf %485, %495 {timing = #hlscpp.t<187 -> 191, 4, 1>} : f64
    %497 = arith.addf %484, %496 {timing = #hlscpp.t<191 -> 196, 5, 1>} : f64
    %498 = affine.load %arg1[38] {partition_indices = [38], timing = #hlscpp.t<190 -> 192, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %499 = affine.load %arg0[%arg4 * 256 + 38] {partition_indices = [38], timing = #hlscpp.t<190 -> 192, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %500 = arith.mulf %498, %499 {timing = #hlscpp.t<192 -> 196, 4, 1>} : f64
    %501 = arith.addf %488, %500 {timing = #hlscpp.t<196 -> 201, 5, 1>} : f64
    %502 = affine.load %arg0[%arg4 * 256 + 102] {partition_indices = [102], timing = #hlscpp.t<190 -> 192, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %503 = arith.mulf %498, %502 {timing = #hlscpp.t<192 -> 196, 4, 1>} : f64
    %504 = arith.addf %491, %503 {timing = #hlscpp.t<196 -> 201, 5, 1>} : f64
    %505 = affine.load %arg0[%arg4 * 256 + 166] {partition_indices = [166], timing = #hlscpp.t<190 -> 192, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %506 = arith.mulf %498, %505 {timing = #hlscpp.t<192 -> 196, 4, 1>} : f64
    %507 = arith.addf %494, %506 {timing = #hlscpp.t<196 -> 201, 5, 1>} : f64
    %508 = affine.load %arg0[%arg4 * 256 + 230] {partition_indices = [230], timing = #hlscpp.t<190 -> 192, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %509 = arith.mulf %498, %508 {timing = #hlscpp.t<192 -> 196, 4, 1>} : f64
    %510 = arith.addf %497, %509 {timing = #hlscpp.t<196 -> 201, 5, 1>} : f64
    %511 = affine.load %arg1[39] {partition_indices = [39], timing = #hlscpp.t<195 -> 197, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %512 = affine.load %arg0[%arg4 * 256 + 39] {partition_indices = [39], timing = #hlscpp.t<195 -> 197, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %513 = arith.mulf %511, %512 {timing = #hlscpp.t<197 -> 201, 4, 1>} : f64
    %514 = arith.addf %501, %513 {timing = #hlscpp.t<201 -> 206, 5, 1>} : f64
    %515 = affine.load %arg0[%arg4 * 256 + 103] {partition_indices = [103], timing = #hlscpp.t<195 -> 197, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %516 = arith.mulf %511, %515 {timing = #hlscpp.t<197 -> 201, 4, 1>} : f64
    %517 = arith.addf %504, %516 {timing = #hlscpp.t<201 -> 206, 5, 1>} : f64
    %518 = affine.load %arg0[%arg4 * 256 + 167] {partition_indices = [167], timing = #hlscpp.t<195 -> 197, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %519 = arith.mulf %511, %518 {timing = #hlscpp.t<197 -> 201, 4, 1>} : f64
    %520 = arith.addf %507, %519 {timing = #hlscpp.t<201 -> 206, 5, 1>} : f64
    %521 = affine.load %arg0[%arg4 * 256 + 231] {partition_indices = [231], timing = #hlscpp.t<195 -> 197, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %522 = arith.mulf %511, %521 {timing = #hlscpp.t<197 -> 201, 4, 1>} : f64
    %523 = arith.addf %510, %522 {timing = #hlscpp.t<201 -> 206, 5, 1>} : f64
    %524 = affine.load %arg1[40] {partition_indices = [40], timing = #hlscpp.t<200 -> 202, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %525 = affine.load %arg0[%arg4 * 256 + 40] {partition_indices = [40], timing = #hlscpp.t<200 -> 202, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %526 = arith.mulf %524, %525 {timing = #hlscpp.t<202 -> 206, 4, 1>} : f64
    %527 = arith.addf %514, %526 {timing = #hlscpp.t<206 -> 211, 5, 1>} : f64
    %528 = affine.load %arg0[%arg4 * 256 + 104] {partition_indices = [104], timing = #hlscpp.t<200 -> 202, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %529 = arith.mulf %524, %528 {timing = #hlscpp.t<202 -> 206, 4, 1>} : f64
    %530 = arith.addf %517, %529 {timing = #hlscpp.t<206 -> 211, 5, 1>} : f64
    %531 = affine.load %arg0[%arg4 * 256 + 168] {partition_indices = [168], timing = #hlscpp.t<200 -> 202, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %532 = arith.mulf %524, %531 {timing = #hlscpp.t<202 -> 206, 4, 1>} : f64
    %533 = arith.addf %520, %532 {timing = #hlscpp.t<206 -> 211, 5, 1>} : f64
    %534 = affine.load %arg0[%arg4 * 256 + 232] {partition_indices = [232], timing = #hlscpp.t<200 -> 202, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %535 = arith.mulf %524, %534 {timing = #hlscpp.t<202 -> 206, 4, 1>} : f64
    %536 = arith.addf %523, %535 {timing = #hlscpp.t<206 -> 211, 5, 1>} : f64
    %537 = affine.load %arg1[41] {partition_indices = [41], timing = #hlscpp.t<205 -> 207, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %538 = affine.load %arg0[%arg4 * 256 + 41] {partition_indices = [41], timing = #hlscpp.t<205 -> 207, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %539 = arith.mulf %537, %538 {timing = #hlscpp.t<207 -> 211, 4, 1>} : f64
    %540 = arith.addf %527, %539 {timing = #hlscpp.t<211 -> 216, 5, 1>} : f64
    %541 = affine.load %arg0[%arg4 * 256 + 105] {partition_indices = [105], timing = #hlscpp.t<205 -> 207, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %542 = arith.mulf %537, %541 {timing = #hlscpp.t<207 -> 211, 4, 1>} : f64
    %543 = arith.addf %530, %542 {timing = #hlscpp.t<211 -> 216, 5, 1>} : f64
    %544 = affine.load %arg0[%arg4 * 256 + 169] {partition_indices = [169], timing = #hlscpp.t<205 -> 207, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %545 = arith.mulf %537, %544 {timing = #hlscpp.t<207 -> 211, 4, 1>} : f64
    %546 = arith.addf %533, %545 {timing = #hlscpp.t<211 -> 216, 5, 1>} : f64
    %547 = affine.load %arg0[%arg4 * 256 + 233] {partition_indices = [233], timing = #hlscpp.t<205 -> 207, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %548 = arith.mulf %537, %547 {timing = #hlscpp.t<207 -> 211, 4, 1>} : f64
    %549 = arith.addf %536, %548 {timing = #hlscpp.t<211 -> 216, 5, 1>} : f64
    %550 = affine.load %arg1[42] {partition_indices = [42], timing = #hlscpp.t<210 -> 212, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %551 = affine.load %arg0[%arg4 * 256 + 42] {partition_indices = [42], timing = #hlscpp.t<210 -> 212, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %552 = arith.mulf %550, %551 {timing = #hlscpp.t<212 -> 216, 4, 1>} : f64
    %553 = arith.addf %540, %552 {timing = #hlscpp.t<216 -> 221, 5, 1>} : f64
    %554 = affine.load %arg0[%arg4 * 256 + 106] {partition_indices = [106], timing = #hlscpp.t<210 -> 212, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %555 = arith.mulf %550, %554 {timing = #hlscpp.t<212 -> 216, 4, 1>} : f64
    %556 = arith.addf %543, %555 {timing = #hlscpp.t<216 -> 221, 5, 1>} : f64
    %557 = affine.load %arg0[%arg4 * 256 + 170] {partition_indices = [170], timing = #hlscpp.t<210 -> 212, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %558 = arith.mulf %550, %557 {timing = #hlscpp.t<212 -> 216, 4, 1>} : f64
    %559 = arith.addf %546, %558 {timing = #hlscpp.t<216 -> 221, 5, 1>} : f64
    %560 = affine.load %arg0[%arg4 * 256 + 234] {partition_indices = [234], timing = #hlscpp.t<210 -> 212, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %561 = arith.mulf %550, %560 {timing = #hlscpp.t<212 -> 216, 4, 1>} : f64
    %562 = arith.addf %549, %561 {timing = #hlscpp.t<216 -> 221, 5, 1>} : f64
    %563 = affine.load %arg1[43] {partition_indices = [43], timing = #hlscpp.t<215 -> 217, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %564 = affine.load %arg0[%arg4 * 256 + 43] {partition_indices = [43], timing = #hlscpp.t<215 -> 217, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %565 = arith.mulf %563, %564 {timing = #hlscpp.t<217 -> 221, 4, 1>} : f64
    %566 = arith.addf %553, %565 {timing = #hlscpp.t<221 -> 226, 5, 1>} : f64
    %567 = affine.load %arg0[%arg4 * 256 + 107] {partition_indices = [107], timing = #hlscpp.t<215 -> 217, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %568 = arith.mulf %563, %567 {timing = #hlscpp.t<217 -> 221, 4, 1>} : f64
    %569 = arith.addf %556, %568 {timing = #hlscpp.t<221 -> 226, 5, 1>} : f64
    %570 = affine.load %arg0[%arg4 * 256 + 171] {partition_indices = [171], timing = #hlscpp.t<215 -> 217, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %571 = arith.mulf %563, %570 {timing = #hlscpp.t<217 -> 221, 4, 1>} : f64
    %572 = arith.addf %559, %571 {timing = #hlscpp.t<221 -> 226, 5, 1>} : f64
    %573 = affine.load %arg0[%arg4 * 256 + 235] {partition_indices = [235], timing = #hlscpp.t<215 -> 217, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %574 = arith.mulf %563, %573 {timing = #hlscpp.t<217 -> 221, 4, 1>} : f64
    %575 = arith.addf %562, %574 {timing = #hlscpp.t<221 -> 226, 5, 1>} : f64
    %576 = affine.load %arg1[44] {partition_indices = [44], timing = #hlscpp.t<220 -> 222, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %577 = affine.load %arg0[%arg4 * 256 + 44] {partition_indices = [44], timing = #hlscpp.t<220 -> 222, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %578 = arith.mulf %576, %577 {timing = #hlscpp.t<222 -> 226, 4, 1>} : f64
    %579 = arith.addf %566, %578 {timing = #hlscpp.t<226 -> 231, 5, 1>} : f64
    %580 = affine.load %arg0[%arg4 * 256 + 108] {partition_indices = [108], timing = #hlscpp.t<220 -> 222, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %581 = arith.mulf %576, %580 {timing = #hlscpp.t<222 -> 226, 4, 1>} : f64
    %582 = arith.addf %569, %581 {timing = #hlscpp.t<226 -> 231, 5, 1>} : f64
    %583 = affine.load %arg0[%arg4 * 256 + 172] {partition_indices = [172], timing = #hlscpp.t<220 -> 222, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %584 = arith.mulf %576, %583 {timing = #hlscpp.t<222 -> 226, 4, 1>} : f64
    %585 = arith.addf %572, %584 {timing = #hlscpp.t<226 -> 231, 5, 1>} : f64
    %586 = affine.load %arg0[%arg4 * 256 + 236] {partition_indices = [236], timing = #hlscpp.t<220 -> 222, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %587 = arith.mulf %576, %586 {timing = #hlscpp.t<222 -> 226, 4, 1>} : f64
    %588 = arith.addf %575, %587 {timing = #hlscpp.t<226 -> 231, 5, 1>} : f64
    %589 = affine.load %arg1[45] {partition_indices = [45], timing = #hlscpp.t<225 -> 227, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %590 = affine.load %arg0[%arg4 * 256 + 45] {partition_indices = [45], timing = #hlscpp.t<225 -> 227, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %591 = arith.mulf %589, %590 {timing = #hlscpp.t<227 -> 231, 4, 1>} : f64
    %592 = arith.addf %579, %591 {timing = #hlscpp.t<231 -> 236, 5, 1>} : f64
    %593 = affine.load %arg0[%arg4 * 256 + 109] {partition_indices = [109], timing = #hlscpp.t<225 -> 227, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %594 = arith.mulf %589, %593 {timing = #hlscpp.t<227 -> 231, 4, 1>} : f64
    %595 = arith.addf %582, %594 {timing = #hlscpp.t<231 -> 236, 5, 1>} : f64
    %596 = affine.load %arg0[%arg4 * 256 + 173] {partition_indices = [173], timing = #hlscpp.t<225 -> 227, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %597 = arith.mulf %589, %596 {timing = #hlscpp.t<227 -> 231, 4, 1>} : f64
    %598 = arith.addf %585, %597 {timing = #hlscpp.t<231 -> 236, 5, 1>} : f64
    %599 = affine.load %arg0[%arg4 * 256 + 237] {partition_indices = [237], timing = #hlscpp.t<225 -> 227, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %600 = arith.mulf %589, %599 {timing = #hlscpp.t<227 -> 231, 4, 1>} : f64
    %601 = arith.addf %588, %600 {timing = #hlscpp.t<231 -> 236, 5, 1>} : f64
    %602 = affine.load %arg1[46] {partition_indices = [46], timing = #hlscpp.t<230 -> 232, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %603 = affine.load %arg0[%arg4 * 256 + 46] {partition_indices = [46], timing = #hlscpp.t<230 -> 232, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %604 = arith.mulf %602, %603 {timing = #hlscpp.t<232 -> 236, 4, 1>} : f64
    %605 = arith.addf %592, %604 {timing = #hlscpp.t<236 -> 241, 5, 1>} : f64
    %606 = affine.load %arg0[%arg4 * 256 + 110] {partition_indices = [110], timing = #hlscpp.t<230 -> 232, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %607 = arith.mulf %602, %606 {timing = #hlscpp.t<232 -> 236, 4, 1>} : f64
    %608 = arith.addf %595, %607 {timing = #hlscpp.t<236 -> 241, 5, 1>} : f64
    %609 = affine.load %arg0[%arg4 * 256 + 174] {partition_indices = [174], timing = #hlscpp.t<230 -> 232, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %610 = arith.mulf %602, %609 {timing = #hlscpp.t<232 -> 236, 4, 1>} : f64
    %611 = arith.addf %598, %610 {timing = #hlscpp.t<236 -> 241, 5, 1>} : f64
    %612 = affine.load %arg0[%arg4 * 256 + 238] {partition_indices = [238], timing = #hlscpp.t<230 -> 232, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %613 = arith.mulf %602, %612 {timing = #hlscpp.t<232 -> 236, 4, 1>} : f64
    %614 = arith.addf %601, %613 {timing = #hlscpp.t<236 -> 241, 5, 1>} : f64
    %615 = affine.load %arg1[47] {partition_indices = [47], timing = #hlscpp.t<235 -> 237, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %616 = affine.load %arg0[%arg4 * 256 + 47] {partition_indices = [47], timing = #hlscpp.t<235 -> 237, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %617 = arith.mulf %615, %616 {timing = #hlscpp.t<237 -> 241, 4, 1>} : f64
    %618 = arith.addf %605, %617 {timing = #hlscpp.t<241 -> 246, 5, 1>} : f64
    %619 = affine.load %arg0[%arg4 * 256 + 111] {partition_indices = [111], timing = #hlscpp.t<235 -> 237, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %620 = arith.mulf %615, %619 {timing = #hlscpp.t<237 -> 241, 4, 1>} : f64
    %621 = arith.addf %608, %620 {timing = #hlscpp.t<241 -> 246, 5, 1>} : f64
    %622 = affine.load %arg0[%arg4 * 256 + 175] {partition_indices = [175], timing = #hlscpp.t<235 -> 237, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %623 = arith.mulf %615, %622 {timing = #hlscpp.t<237 -> 241, 4, 1>} : f64
    %624 = arith.addf %611, %623 {timing = #hlscpp.t<241 -> 246, 5, 1>} : f64
    %625 = affine.load %arg0[%arg4 * 256 + 239] {partition_indices = [239], timing = #hlscpp.t<235 -> 237, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %626 = arith.mulf %615, %625 {timing = #hlscpp.t<237 -> 241, 4, 1>} : f64
    %627 = arith.addf %614, %626 {timing = #hlscpp.t<241 -> 246, 5, 1>} : f64
    %628 = affine.load %arg1[48] {partition_indices = [48], timing = #hlscpp.t<240 -> 242, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %629 = affine.load %arg0[%arg4 * 256 + 48] {partition_indices = [48], timing = #hlscpp.t<240 -> 242, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %630 = arith.mulf %628, %629 {timing = #hlscpp.t<242 -> 246, 4, 1>} : f64
    %631 = arith.addf %618, %630 {timing = #hlscpp.t<246 -> 251, 5, 1>} : f64
    %632 = affine.load %arg0[%arg4 * 256 + 112] {partition_indices = [112], timing = #hlscpp.t<240 -> 242, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %633 = arith.mulf %628, %632 {timing = #hlscpp.t<242 -> 246, 4, 1>} : f64
    %634 = arith.addf %621, %633 {timing = #hlscpp.t<246 -> 251, 5, 1>} : f64
    %635 = affine.load %arg0[%arg4 * 256 + 176] {partition_indices = [176], timing = #hlscpp.t<240 -> 242, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %636 = arith.mulf %628, %635 {timing = #hlscpp.t<242 -> 246, 4, 1>} : f64
    %637 = arith.addf %624, %636 {timing = #hlscpp.t<246 -> 251, 5, 1>} : f64
    %638 = affine.load %arg0[%arg4 * 256 + 240] {partition_indices = [240], timing = #hlscpp.t<240 -> 242, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %639 = arith.mulf %628, %638 {timing = #hlscpp.t<242 -> 246, 4, 1>} : f64
    %640 = arith.addf %627, %639 {timing = #hlscpp.t<246 -> 251, 5, 1>} : f64
    %641 = affine.load %arg1[49] {partition_indices = [49], timing = #hlscpp.t<245 -> 247, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %642 = affine.load %arg0[%arg4 * 256 + 49] {partition_indices = [49], timing = #hlscpp.t<245 -> 247, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %643 = arith.mulf %641, %642 {timing = #hlscpp.t<247 -> 251, 4, 1>} : f64
    %644 = arith.addf %631, %643 {timing = #hlscpp.t<251 -> 256, 5, 1>} : f64
    %645 = affine.load %arg0[%arg4 * 256 + 113] {partition_indices = [113], timing = #hlscpp.t<245 -> 247, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %646 = arith.mulf %641, %645 {timing = #hlscpp.t<247 -> 251, 4, 1>} : f64
    %647 = arith.addf %634, %646 {timing = #hlscpp.t<251 -> 256, 5, 1>} : f64
    %648 = affine.load %arg0[%arg4 * 256 + 177] {partition_indices = [177], timing = #hlscpp.t<245 -> 247, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %649 = arith.mulf %641, %648 {timing = #hlscpp.t<247 -> 251, 4, 1>} : f64
    %650 = arith.addf %637, %649 {timing = #hlscpp.t<251 -> 256, 5, 1>} : f64
    %651 = affine.load %arg0[%arg4 * 256 + 241] {partition_indices = [241], timing = #hlscpp.t<245 -> 247, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %652 = arith.mulf %641, %651 {timing = #hlscpp.t<247 -> 251, 4, 1>} : f64
    %653 = arith.addf %640, %652 {timing = #hlscpp.t<251 -> 256, 5, 1>} : f64
    %654 = affine.load %arg1[50] {partition_indices = [50], timing = #hlscpp.t<250 -> 252, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %655 = affine.load %arg0[%arg4 * 256 + 50] {partition_indices = [50], timing = #hlscpp.t<250 -> 252, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %656 = arith.mulf %654, %655 {timing = #hlscpp.t<252 -> 256, 4, 1>} : f64
    %657 = arith.addf %644, %656 {timing = #hlscpp.t<256 -> 261, 5, 1>} : f64
    %658 = affine.load %arg0[%arg4 * 256 + 114] {partition_indices = [114], timing = #hlscpp.t<250 -> 252, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %659 = arith.mulf %654, %658 {timing = #hlscpp.t<252 -> 256, 4, 1>} : f64
    %660 = arith.addf %647, %659 {timing = #hlscpp.t<256 -> 261, 5, 1>} : f64
    %661 = affine.load %arg0[%arg4 * 256 + 178] {partition_indices = [178], timing = #hlscpp.t<250 -> 252, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %662 = arith.mulf %654, %661 {timing = #hlscpp.t<252 -> 256, 4, 1>} : f64
    %663 = arith.addf %650, %662 {timing = #hlscpp.t<256 -> 261, 5, 1>} : f64
    %664 = affine.load %arg0[%arg4 * 256 + 242] {partition_indices = [242], timing = #hlscpp.t<250 -> 252, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %665 = arith.mulf %654, %664 {timing = #hlscpp.t<252 -> 256, 4, 1>} : f64
    %666 = arith.addf %653, %665 {timing = #hlscpp.t<256 -> 261, 5, 1>} : f64
    %667 = affine.load %arg1[51] {partition_indices = [51], timing = #hlscpp.t<255 -> 257, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %668 = affine.load %arg0[%arg4 * 256 + 51] {partition_indices = [51], timing = #hlscpp.t<255 -> 257, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %669 = arith.mulf %667, %668 {timing = #hlscpp.t<257 -> 261, 4, 1>} : f64
    %670 = arith.addf %657, %669 {timing = #hlscpp.t<261 -> 266, 5, 1>} : f64
    %671 = affine.load %arg0[%arg4 * 256 + 115] {partition_indices = [115], timing = #hlscpp.t<255 -> 257, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %672 = arith.mulf %667, %671 {timing = #hlscpp.t<257 -> 261, 4, 1>} : f64
    %673 = arith.addf %660, %672 {timing = #hlscpp.t<261 -> 266, 5, 1>} : f64
    %674 = affine.load %arg0[%arg4 * 256 + 179] {partition_indices = [179], timing = #hlscpp.t<255 -> 257, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %675 = arith.mulf %667, %674 {timing = #hlscpp.t<257 -> 261, 4, 1>} : f64
    %676 = arith.addf %663, %675 {timing = #hlscpp.t<261 -> 266, 5, 1>} : f64
    %677 = affine.load %arg0[%arg4 * 256 + 243] {partition_indices = [243], timing = #hlscpp.t<255 -> 257, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %678 = arith.mulf %667, %677 {timing = #hlscpp.t<257 -> 261, 4, 1>} : f64
    %679 = arith.addf %666, %678 {timing = #hlscpp.t<261 -> 266, 5, 1>} : f64
    %680 = affine.load %arg1[52] {partition_indices = [52], timing = #hlscpp.t<260 -> 262, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %681 = affine.load %arg0[%arg4 * 256 + 52] {partition_indices = [52], timing = #hlscpp.t<260 -> 262, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %682 = arith.mulf %680, %681 {timing = #hlscpp.t<262 -> 266, 4, 1>} : f64
    %683 = arith.addf %670, %682 {timing = #hlscpp.t<266 -> 271, 5, 1>} : f64
    %684 = affine.load %arg0[%arg4 * 256 + 116] {partition_indices = [116], timing = #hlscpp.t<260 -> 262, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %685 = arith.mulf %680, %684 {timing = #hlscpp.t<262 -> 266, 4, 1>} : f64
    %686 = arith.addf %673, %685 {timing = #hlscpp.t<266 -> 271, 5, 1>} : f64
    %687 = affine.load %arg0[%arg4 * 256 + 180] {partition_indices = [180], timing = #hlscpp.t<260 -> 262, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %688 = arith.mulf %680, %687 {timing = #hlscpp.t<262 -> 266, 4, 1>} : f64
    %689 = arith.addf %676, %688 {timing = #hlscpp.t<266 -> 271, 5, 1>} : f64
    %690 = affine.load %arg0[%arg4 * 256 + 244] {partition_indices = [244], timing = #hlscpp.t<260 -> 262, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %691 = arith.mulf %680, %690 {timing = #hlscpp.t<262 -> 266, 4, 1>} : f64
    %692 = arith.addf %679, %691 {timing = #hlscpp.t<266 -> 271, 5, 1>} : f64
    %693 = affine.load %arg1[53] {partition_indices = [53], timing = #hlscpp.t<265 -> 267, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %694 = affine.load %arg0[%arg4 * 256 + 53] {partition_indices = [53], timing = #hlscpp.t<265 -> 267, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %695 = arith.mulf %693, %694 {timing = #hlscpp.t<267 -> 271, 4, 1>} : f64
    %696 = arith.addf %683, %695 {timing = #hlscpp.t<271 -> 276, 5, 1>} : f64
    %697 = affine.load %arg0[%arg4 * 256 + 117] {partition_indices = [117], timing = #hlscpp.t<265 -> 267, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %698 = arith.mulf %693, %697 {timing = #hlscpp.t<267 -> 271, 4, 1>} : f64
    %699 = arith.addf %686, %698 {timing = #hlscpp.t<271 -> 276, 5, 1>} : f64
    %700 = affine.load %arg0[%arg4 * 256 + 181] {partition_indices = [181], timing = #hlscpp.t<265 -> 267, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %701 = arith.mulf %693, %700 {timing = #hlscpp.t<267 -> 271, 4, 1>} : f64
    %702 = arith.addf %689, %701 {timing = #hlscpp.t<271 -> 276, 5, 1>} : f64
    %703 = affine.load %arg0[%arg4 * 256 + 245] {partition_indices = [245], timing = #hlscpp.t<265 -> 267, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %704 = arith.mulf %693, %703 {timing = #hlscpp.t<267 -> 271, 4, 1>} : f64
    %705 = arith.addf %692, %704 {timing = #hlscpp.t<271 -> 276, 5, 1>} : f64
    %706 = affine.load %arg1[54] {partition_indices = [54], timing = #hlscpp.t<270 -> 272, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %707 = affine.load %arg0[%arg4 * 256 + 54] {partition_indices = [54], timing = #hlscpp.t<270 -> 272, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %708 = arith.mulf %706, %707 {timing = #hlscpp.t<272 -> 276, 4, 1>} : f64
    %709 = arith.addf %696, %708 {timing = #hlscpp.t<276 -> 281, 5, 1>} : f64
    %710 = affine.load %arg0[%arg4 * 256 + 118] {partition_indices = [118], timing = #hlscpp.t<270 -> 272, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %711 = arith.mulf %706, %710 {timing = #hlscpp.t<272 -> 276, 4, 1>} : f64
    %712 = arith.addf %699, %711 {timing = #hlscpp.t<276 -> 281, 5, 1>} : f64
    %713 = affine.load %arg0[%arg4 * 256 + 182] {partition_indices = [182], timing = #hlscpp.t<270 -> 272, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %714 = arith.mulf %706, %713 {timing = #hlscpp.t<272 -> 276, 4, 1>} : f64
    %715 = arith.addf %702, %714 {timing = #hlscpp.t<276 -> 281, 5, 1>} : f64
    %716 = affine.load %arg0[%arg4 * 256 + 246] {partition_indices = [246], timing = #hlscpp.t<270 -> 272, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %717 = arith.mulf %706, %716 {timing = #hlscpp.t<272 -> 276, 4, 1>} : f64
    %718 = arith.addf %705, %717 {timing = #hlscpp.t<276 -> 281, 5, 1>} : f64
    %719 = affine.load %arg1[55] {partition_indices = [55], timing = #hlscpp.t<275 -> 277, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %720 = affine.load %arg0[%arg4 * 256 + 55] {partition_indices = [55], timing = #hlscpp.t<275 -> 277, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %721 = arith.mulf %719, %720 {timing = #hlscpp.t<277 -> 281, 4, 1>} : f64
    %722 = arith.addf %709, %721 {timing = #hlscpp.t<281 -> 286, 5, 1>} : f64
    %723 = affine.load %arg0[%arg4 * 256 + 119] {partition_indices = [119], timing = #hlscpp.t<275 -> 277, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %724 = arith.mulf %719, %723 {timing = #hlscpp.t<277 -> 281, 4, 1>} : f64
    %725 = arith.addf %712, %724 {timing = #hlscpp.t<281 -> 286, 5, 1>} : f64
    %726 = affine.load %arg0[%arg4 * 256 + 183] {partition_indices = [183], timing = #hlscpp.t<275 -> 277, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %727 = arith.mulf %719, %726 {timing = #hlscpp.t<277 -> 281, 4, 1>} : f64
    %728 = arith.addf %715, %727 {timing = #hlscpp.t<281 -> 286, 5, 1>} : f64
    %729 = affine.load %arg0[%arg4 * 256 + 247] {partition_indices = [247], timing = #hlscpp.t<275 -> 277, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %730 = arith.mulf %719, %729 {timing = #hlscpp.t<277 -> 281, 4, 1>} : f64
    %731 = arith.addf %718, %730 {timing = #hlscpp.t<281 -> 286, 5, 1>} : f64
    %732 = affine.load %arg1[56] {partition_indices = [56], timing = #hlscpp.t<280 -> 282, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %733 = affine.load %arg0[%arg4 * 256 + 56] {partition_indices = [56], timing = #hlscpp.t<280 -> 282, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %734 = arith.mulf %732, %733 {timing = #hlscpp.t<282 -> 286, 4, 1>} : f64
    %735 = arith.addf %722, %734 {timing = #hlscpp.t<286 -> 291, 5, 1>} : f64
    %736 = affine.load %arg0[%arg4 * 256 + 120] {partition_indices = [120], timing = #hlscpp.t<280 -> 282, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %737 = arith.mulf %732, %736 {timing = #hlscpp.t<282 -> 286, 4, 1>} : f64
    %738 = arith.addf %725, %737 {timing = #hlscpp.t<286 -> 291, 5, 1>} : f64
    %739 = affine.load %arg0[%arg4 * 256 + 184] {partition_indices = [184], timing = #hlscpp.t<280 -> 282, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %740 = arith.mulf %732, %739 {timing = #hlscpp.t<282 -> 286, 4, 1>} : f64
    %741 = arith.addf %728, %740 {timing = #hlscpp.t<286 -> 291, 5, 1>} : f64
    %742 = affine.load %arg0[%arg4 * 256 + 248] {partition_indices = [248], timing = #hlscpp.t<280 -> 282, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %743 = arith.mulf %732, %742 {timing = #hlscpp.t<282 -> 286, 4, 1>} : f64
    %744 = arith.addf %731, %743 {timing = #hlscpp.t<286 -> 291, 5, 1>} : f64
    %745 = affine.load %arg1[57] {partition_indices = [57], timing = #hlscpp.t<285 -> 287, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %746 = affine.load %arg0[%arg4 * 256 + 57] {partition_indices = [57], timing = #hlscpp.t<285 -> 287, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %747 = arith.mulf %745, %746 {timing = #hlscpp.t<287 -> 291, 4, 1>} : f64
    %748 = arith.addf %735, %747 {timing = #hlscpp.t<291 -> 296, 5, 1>} : f64
    %749 = affine.load %arg0[%arg4 * 256 + 121] {partition_indices = [121], timing = #hlscpp.t<285 -> 287, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %750 = arith.mulf %745, %749 {timing = #hlscpp.t<287 -> 291, 4, 1>} : f64
    %751 = arith.addf %738, %750 {timing = #hlscpp.t<291 -> 296, 5, 1>} : f64
    %752 = affine.load %arg0[%arg4 * 256 + 185] {partition_indices = [185], timing = #hlscpp.t<285 -> 287, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %753 = arith.mulf %745, %752 {timing = #hlscpp.t<287 -> 291, 4, 1>} : f64
    %754 = arith.addf %741, %753 {timing = #hlscpp.t<291 -> 296, 5, 1>} : f64
    %755 = affine.load %arg0[%arg4 * 256 + 249] {partition_indices = [249], timing = #hlscpp.t<285 -> 287, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %756 = arith.mulf %745, %755 {timing = #hlscpp.t<287 -> 291, 4, 1>} : f64
    %757 = arith.addf %744, %756 {timing = #hlscpp.t<291 -> 296, 5, 1>} : f64
    %758 = affine.load %arg1[58] {partition_indices = [58], timing = #hlscpp.t<290 -> 292, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %759 = affine.load %arg0[%arg4 * 256 + 58] {partition_indices = [58], timing = #hlscpp.t<290 -> 292, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %760 = arith.mulf %758, %759 {timing = #hlscpp.t<292 -> 296, 4, 1>} : f64
    %761 = arith.addf %748, %760 {timing = #hlscpp.t<296 -> 301, 5, 1>} : f64
    %762 = affine.load %arg0[%arg4 * 256 + 122] {partition_indices = [122], timing = #hlscpp.t<290 -> 292, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %763 = arith.mulf %758, %762 {timing = #hlscpp.t<292 -> 296, 4, 1>} : f64
    %764 = arith.addf %751, %763 {timing = #hlscpp.t<296 -> 301, 5, 1>} : f64
    %765 = affine.load %arg0[%arg4 * 256 + 186] {partition_indices = [186], timing = #hlscpp.t<290 -> 292, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %766 = arith.mulf %758, %765 {timing = #hlscpp.t<292 -> 296, 4, 1>} : f64
    %767 = arith.addf %754, %766 {timing = #hlscpp.t<296 -> 301, 5, 1>} : f64
    %768 = affine.load %arg0[%arg4 * 256 + 250] {partition_indices = [250], timing = #hlscpp.t<290 -> 292, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %769 = arith.mulf %758, %768 {timing = #hlscpp.t<292 -> 296, 4, 1>} : f64
    %770 = arith.addf %757, %769 {timing = #hlscpp.t<296 -> 301, 5, 1>} : f64
    %771 = affine.load %arg1[59] {partition_indices = [59], timing = #hlscpp.t<295 -> 297, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %772 = affine.load %arg0[%arg4 * 256 + 59] {partition_indices = [59], timing = #hlscpp.t<295 -> 297, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %773 = arith.mulf %771, %772 {timing = #hlscpp.t<297 -> 301, 4, 1>} : f64
    %774 = arith.addf %761, %773 {timing = #hlscpp.t<301 -> 306, 5, 1>} : f64
    %775 = affine.load %arg0[%arg4 * 256 + 123] {partition_indices = [123], timing = #hlscpp.t<295 -> 297, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %776 = arith.mulf %771, %775 {timing = #hlscpp.t<297 -> 301, 4, 1>} : f64
    %777 = arith.addf %764, %776 {timing = #hlscpp.t<301 -> 306, 5, 1>} : f64
    %778 = affine.load %arg0[%arg4 * 256 + 187] {partition_indices = [187], timing = #hlscpp.t<295 -> 297, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %779 = arith.mulf %771, %778 {timing = #hlscpp.t<297 -> 301, 4, 1>} : f64
    %780 = arith.addf %767, %779 {timing = #hlscpp.t<301 -> 306, 5, 1>} : f64
    %781 = affine.load %arg0[%arg4 * 256 + 251] {partition_indices = [251], timing = #hlscpp.t<295 -> 297, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %782 = arith.mulf %771, %781 {timing = #hlscpp.t<297 -> 301, 4, 1>} : f64
    %783 = arith.addf %770, %782 {timing = #hlscpp.t<301 -> 306, 5, 1>} : f64
    %784 = affine.load %arg1[60] {partition_indices = [60], timing = #hlscpp.t<300 -> 302, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %785 = affine.load %arg0[%arg4 * 256 + 60] {partition_indices = [60], timing = #hlscpp.t<300 -> 302, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %786 = arith.mulf %784, %785 {timing = #hlscpp.t<302 -> 306, 4, 1>} : f64
    %787 = arith.addf %774, %786 {timing = #hlscpp.t<306 -> 311, 5, 1>} : f64
    %788 = affine.load %arg0[%arg4 * 256 + 124] {partition_indices = [124], timing = #hlscpp.t<300 -> 302, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %789 = arith.mulf %784, %788 {timing = #hlscpp.t<302 -> 306, 4, 1>} : f64
    %790 = arith.addf %777, %789 {timing = #hlscpp.t<306 -> 311, 5, 1>} : f64
    %791 = affine.load %arg0[%arg4 * 256 + 188] {partition_indices = [188], timing = #hlscpp.t<300 -> 302, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %792 = arith.mulf %784, %791 {timing = #hlscpp.t<302 -> 306, 4, 1>} : f64
    %793 = arith.addf %780, %792 {timing = #hlscpp.t<306 -> 311, 5, 1>} : f64
    %794 = affine.load %arg0[%arg4 * 256 + 252] {partition_indices = [252], timing = #hlscpp.t<300 -> 302, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %795 = arith.mulf %784, %794 {timing = #hlscpp.t<302 -> 306, 4, 1>} : f64
    %796 = arith.addf %783, %795 {timing = #hlscpp.t<306 -> 311, 5, 1>} : f64
    %797 = affine.load %arg1[61] {partition_indices = [61], timing = #hlscpp.t<305 -> 307, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %798 = affine.load %arg0[%arg4 * 256 + 61] {partition_indices = [61], timing = #hlscpp.t<305 -> 307, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %799 = arith.mulf %797, %798 {timing = #hlscpp.t<307 -> 311, 4, 1>} : f64
    %800 = arith.addf %787, %799 {timing = #hlscpp.t<311 -> 316, 5, 1>} : f64
    %801 = affine.load %arg0[%arg4 * 256 + 125] {partition_indices = [125], timing = #hlscpp.t<305 -> 307, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %802 = arith.mulf %797, %801 {timing = #hlscpp.t<307 -> 311, 4, 1>} : f64
    %803 = arith.addf %790, %802 {timing = #hlscpp.t<311 -> 316, 5, 1>} : f64
    %804 = affine.load %arg0[%arg4 * 256 + 189] {partition_indices = [189], timing = #hlscpp.t<305 -> 307, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %805 = arith.mulf %797, %804 {timing = #hlscpp.t<307 -> 311, 4, 1>} : f64
    %806 = arith.addf %793, %805 {timing = #hlscpp.t<311 -> 316, 5, 1>} : f64
    %807 = affine.load %arg0[%arg4 * 256 + 253] {partition_indices = [253], timing = #hlscpp.t<305 -> 307, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %808 = arith.mulf %797, %807 {timing = #hlscpp.t<307 -> 311, 4, 1>} : f64
    %809 = arith.addf %796, %808 {timing = #hlscpp.t<311 -> 316, 5, 1>} : f64
    %810 = affine.load %arg1[62] {partition_indices = [62], timing = #hlscpp.t<310 -> 312, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %811 = affine.load %arg0[%arg4 * 256 + 62] {partition_indices = [62], timing = #hlscpp.t<310 -> 312, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %812 = arith.mulf %810, %811 {timing = #hlscpp.t<312 -> 316, 4, 1>} : f64
    %813 = arith.addf %800, %812 {timing = #hlscpp.t<316 -> 321, 5, 1>} : f64
    %814 = affine.load %arg0[%arg4 * 256 + 126] {partition_indices = [126], timing = #hlscpp.t<310 -> 312, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %815 = arith.mulf %810, %814 {timing = #hlscpp.t<312 -> 316, 4, 1>} : f64
    %816 = arith.addf %803, %815 {timing = #hlscpp.t<316 -> 321, 5, 1>} : f64
    %817 = affine.load %arg0[%arg4 * 256 + 190] {partition_indices = [190], timing = #hlscpp.t<310 -> 312, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %818 = arith.mulf %810, %817 {timing = #hlscpp.t<312 -> 316, 4, 1>} : f64
    %819 = arith.addf %806, %818 {timing = #hlscpp.t<316 -> 321, 5, 1>} : f64
    %820 = affine.load %arg0[%arg4 * 256 + 254] {partition_indices = [254], timing = #hlscpp.t<310 -> 312, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %821 = arith.mulf %810, %820 {timing = #hlscpp.t<312 -> 316, 4, 1>} : f64
    %822 = arith.addf %809, %821 {timing = #hlscpp.t<316 -> 321, 5, 1>} : f64
    %823 = affine.load %arg1[63] {partition_indices = [63], timing = #hlscpp.t<315 -> 317, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %824 = affine.load %arg0[%arg4 * 256 + 63] {partition_indices = [63], timing = #hlscpp.t<315 -> 317, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %825 = arith.mulf %823, %824 {timing = #hlscpp.t<317 -> 321, 4, 1>} : f64
    %826 = arith.addf %813, %825 {timing = #hlscpp.t<321 -> 326, 5, 1>} : f64
    %827 = arith.mulf %826, %4 {timing = #hlscpp.t<326 -> 330, 4, 1>} : f64
    affine.store %827, %arg2[%arg4 * 4] {partition_indices = [0], timing = #hlscpp.t<330 -> 331, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 4, d0 floordiv 4)>, 1>
    %828 = affine.load %arg0[%arg4 * 256 + 127] {partition_indices = [127], timing = #hlscpp.t<315 -> 317, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %829 = arith.mulf %823, %828 {timing = #hlscpp.t<317 -> 321, 4, 1>} : f64
    %830 = arith.addf %816, %829 {timing = #hlscpp.t<321 -> 326, 5, 1>} : f64
    %831 = arith.mulf %830, %8 {timing = #hlscpp.t<326 -> 330, 4, 1>} : f64
    affine.store %831, %arg2[%arg4 * 4 + 1] {partition_indices = [1], timing = #hlscpp.t<330 -> 331, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 4, d0 floordiv 4)>, 1>
    %832 = affine.load %arg0[%arg4 * 256 + 191] {partition_indices = [191], timing = #hlscpp.t<315 -> 317, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %833 = arith.mulf %823, %832 {timing = #hlscpp.t<317 -> 321, 4, 1>} : f64
    %834 = arith.addf %819, %833 {timing = #hlscpp.t<321 -> 326, 5, 1>} : f64
    %835 = arith.mulf %834, %12 {timing = #hlscpp.t<326 -> 330, 4, 1>} : f64
    affine.store %835, %arg2[%arg4 * 4 + 2] {partition_indices = [2], timing = #hlscpp.t<330 -> 331, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 4, d0 floordiv 4)>, 1>
    %836 = affine.load %arg0[%arg4 * 256 + 255] {partition_indices = [255], timing = #hlscpp.t<315 -> 317, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 mod 256, d0 floordiv 256)>, 1>
    %837 = arith.mulf %823, %836 {timing = #hlscpp.t<317 -> 321, 4, 1>} : f64
    %838 = arith.addf %822, %837 {timing = #hlscpp.t<321 -> 326, 5, 1>} : f64
    %839 = arith.mulf %838, %16 {timing = #hlscpp.t<326 -> 330, 4, 1>} : f64
    affine.store %839, %arg2[%arg4 * 4 + 3] {partition_indices = [3], timing = #hlscpp.t<330 -> 331, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 4, d0 floordiv 4)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=4, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=16, iterLatency=331, minII=4>, timing = #hlscpp.t<0 -> 393, 393, 393>}
  return {timing = #hlscpp.t<393 -> 393, 0, 0>}
}
