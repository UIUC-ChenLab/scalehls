func @matrix_vector_product_with_bias_output_layer(%arg0: memref<3xf64>, %arg1: memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>, %arg2: memref<3xf64, affine_map<(d0) -> (0, d0)>, 1>, %arg3: memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>, %arg4: memref<1xf64, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>, llvm.linkage = #llvm.linkage<external>, resource = #hlscpp.r<lut=0, dsp=320, bram=0>, timing = #hlscpp.t<0 -> 334, 334, 334>} {
  %cst = arith.constant {timing = #hlscpp.t<331 -> 331, 0, 0>} 42.424242419999999 : f64
  %cst_0 = arith.constant {timing = #hlscpp.t<0 -> 0, 0, 0>} 0.000000e+00 : f64
  affine.for %arg5 = 0 to 3 {
    %0 = affine.load %arg1[%arg5 * 64] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %1 = affine.load %arg3[0] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %2 = arith.mulf %0, %1 {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %3 = arith.addf %2, %cst_0 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    %4 = affine.load %arg1[%arg5 * 64 + 1] {partition_indices = [1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %5 = affine.load %arg3[1] {partition_indices = [1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %6 = arith.mulf %4, %5 {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %7 = arith.addf %3, %6 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    %8 = affine.load %arg1[%arg5 * 64 + 2] {partition_indices = [2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %9 = affine.load %arg3[2] {partition_indices = [2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %10 = arith.mulf %8, %9 {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %11 = arith.addf %7, %10 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    %12 = affine.load %arg1[%arg5 * 64 + 3] {partition_indices = [3], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %13 = affine.load %arg3[3] {partition_indices = [3], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %14 = arith.mulf %12, %13 {timing = #hlscpp.t<17 -> 21, 4, 1>} : f64
    %15 = arith.addf %11, %14 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f64
    %16 = affine.load %arg1[%arg5 * 64 + 4] {partition_indices = [4], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %17 = affine.load %arg3[4] {partition_indices = [4], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %18 = arith.mulf %16, %17 {timing = #hlscpp.t<22 -> 26, 4, 1>} : f64
    %19 = arith.addf %15, %18 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f64
    %20 = affine.load %arg1[%arg5 * 64 + 5] {partition_indices = [5], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %21 = affine.load %arg3[5] {partition_indices = [5], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %22 = arith.mulf %20, %21 {timing = #hlscpp.t<27 -> 31, 4, 1>} : f64
    %23 = arith.addf %19, %22 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f64
    %24 = affine.load %arg1[%arg5 * 64 + 6] {partition_indices = [6], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %25 = affine.load %arg3[6] {partition_indices = [6], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %26 = arith.mulf %24, %25 {timing = #hlscpp.t<32 -> 36, 4, 1>} : f64
    %27 = arith.addf %23, %26 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f64
    %28 = affine.load %arg1[%arg5 * 64 + 7] {partition_indices = [7], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %29 = affine.load %arg3[7] {partition_indices = [7], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %30 = arith.mulf %28, %29 {timing = #hlscpp.t<37 -> 41, 4, 1>} : f64
    %31 = arith.addf %27, %30 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f64
    %32 = affine.load %arg1[%arg5 * 64 + 8] {partition_indices = [8], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %33 = affine.load %arg3[8] {partition_indices = [8], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %34 = arith.mulf %32, %33 {timing = #hlscpp.t<42 -> 46, 4, 1>} : f64
    %35 = arith.addf %31, %34 {timing = #hlscpp.t<46 -> 51, 5, 1>} : f64
    %36 = affine.load %arg1[%arg5 * 64 + 9] {partition_indices = [9], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %37 = affine.load %arg3[9] {partition_indices = [9], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %38 = arith.mulf %36, %37 {timing = #hlscpp.t<47 -> 51, 4, 1>} : f64
    %39 = arith.addf %35, %38 {timing = #hlscpp.t<51 -> 56, 5, 1>} : f64
    %40 = affine.load %arg1[%arg5 * 64 + 10] {partition_indices = [10], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %41 = affine.load %arg3[10] {partition_indices = [10], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %42 = arith.mulf %40, %41 {timing = #hlscpp.t<52 -> 56, 4, 1>} : f64
    %43 = arith.addf %39, %42 {timing = #hlscpp.t<56 -> 61, 5, 1>} : f64
    %44 = affine.load %arg1[%arg5 * 64 + 11] {partition_indices = [11], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %45 = affine.load %arg3[11] {partition_indices = [11], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %46 = arith.mulf %44, %45 {timing = #hlscpp.t<57 -> 61, 4, 1>} : f64
    %47 = arith.addf %43, %46 {timing = #hlscpp.t<61 -> 66, 5, 1>} : f64
    %48 = affine.load %arg1[%arg5 * 64 + 12] {partition_indices = [12], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %49 = affine.load %arg3[12] {partition_indices = [12], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %50 = arith.mulf %48, %49 {timing = #hlscpp.t<62 -> 66, 4, 1>} : f64
    %51 = arith.addf %47, %50 {timing = #hlscpp.t<66 -> 71, 5, 1>} : f64
    %52 = affine.load %arg1[%arg5 * 64 + 13] {partition_indices = [13], timing = #hlscpp.t<65 -> 67, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %53 = affine.load %arg3[13] {partition_indices = [13], timing = #hlscpp.t<65 -> 67, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %54 = arith.mulf %52, %53 {timing = #hlscpp.t<67 -> 71, 4, 1>} : f64
    %55 = arith.addf %51, %54 {timing = #hlscpp.t<71 -> 76, 5, 1>} : f64
    %56 = affine.load %arg1[%arg5 * 64 + 14] {partition_indices = [14], timing = #hlscpp.t<70 -> 72, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %57 = affine.load %arg3[14] {partition_indices = [14], timing = #hlscpp.t<70 -> 72, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %58 = arith.mulf %56, %57 {timing = #hlscpp.t<72 -> 76, 4, 1>} : f64
    %59 = arith.addf %55, %58 {timing = #hlscpp.t<76 -> 81, 5, 1>} : f64
    %60 = affine.load %arg1[%arg5 * 64 + 15] {partition_indices = [15], timing = #hlscpp.t<75 -> 77, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %61 = affine.load %arg3[15] {partition_indices = [15], timing = #hlscpp.t<75 -> 77, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %62 = arith.mulf %60, %61 {timing = #hlscpp.t<77 -> 81, 4, 1>} : f64
    %63 = arith.addf %59, %62 {timing = #hlscpp.t<81 -> 86, 5, 1>} : f64
    %64 = affine.load %arg1[%arg5 * 64 + 16] {partition_indices = [16], timing = #hlscpp.t<80 -> 82, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %65 = affine.load %arg3[16] {partition_indices = [16], timing = #hlscpp.t<80 -> 82, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %66 = arith.mulf %64, %65 {timing = #hlscpp.t<82 -> 86, 4, 1>} : f64
    %67 = arith.addf %63, %66 {timing = #hlscpp.t<86 -> 91, 5, 1>} : f64
    %68 = affine.load %arg1[%arg5 * 64 + 17] {partition_indices = [17], timing = #hlscpp.t<85 -> 87, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %69 = affine.load %arg3[17] {partition_indices = [17], timing = #hlscpp.t<85 -> 87, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %70 = arith.mulf %68, %69 {timing = #hlscpp.t<87 -> 91, 4, 1>} : f64
    %71 = arith.addf %67, %70 {timing = #hlscpp.t<91 -> 96, 5, 1>} : f64
    %72 = affine.load %arg1[%arg5 * 64 + 18] {partition_indices = [18], timing = #hlscpp.t<90 -> 92, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %73 = affine.load %arg3[18] {partition_indices = [18], timing = #hlscpp.t<90 -> 92, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %74 = arith.mulf %72, %73 {timing = #hlscpp.t<92 -> 96, 4, 1>} : f64
    %75 = arith.addf %71, %74 {timing = #hlscpp.t<96 -> 101, 5, 1>} : f64
    %76 = affine.load %arg1[%arg5 * 64 + 19] {partition_indices = [19], timing = #hlscpp.t<95 -> 97, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %77 = affine.load %arg3[19] {partition_indices = [19], timing = #hlscpp.t<95 -> 97, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %78 = arith.mulf %76, %77 {timing = #hlscpp.t<97 -> 101, 4, 1>} : f64
    %79 = arith.addf %75, %78 {timing = #hlscpp.t<101 -> 106, 5, 1>} : f64
    %80 = affine.load %arg1[%arg5 * 64 + 20] {partition_indices = [20], timing = #hlscpp.t<100 -> 102, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %81 = affine.load %arg3[20] {partition_indices = [20], timing = #hlscpp.t<100 -> 102, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %82 = arith.mulf %80, %81 {timing = #hlscpp.t<102 -> 106, 4, 1>} : f64
    %83 = arith.addf %79, %82 {timing = #hlscpp.t<106 -> 111, 5, 1>} : f64
    %84 = affine.load %arg1[%arg5 * 64 + 21] {partition_indices = [21], timing = #hlscpp.t<105 -> 107, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %85 = affine.load %arg3[21] {partition_indices = [21], timing = #hlscpp.t<105 -> 107, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %86 = arith.mulf %84, %85 {timing = #hlscpp.t<107 -> 111, 4, 1>} : f64
    %87 = arith.addf %83, %86 {timing = #hlscpp.t<111 -> 116, 5, 1>} : f64
    %88 = affine.load %arg1[%arg5 * 64 + 22] {partition_indices = [22], timing = #hlscpp.t<110 -> 112, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %89 = affine.load %arg3[22] {partition_indices = [22], timing = #hlscpp.t<110 -> 112, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %90 = arith.mulf %88, %89 {timing = #hlscpp.t<112 -> 116, 4, 1>} : f64
    %91 = arith.addf %87, %90 {timing = #hlscpp.t<116 -> 121, 5, 1>} : f64
    %92 = affine.load %arg1[%arg5 * 64 + 23] {partition_indices = [23], timing = #hlscpp.t<115 -> 117, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %93 = affine.load %arg3[23] {partition_indices = [23], timing = #hlscpp.t<115 -> 117, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %94 = arith.mulf %92, %93 {timing = #hlscpp.t<117 -> 121, 4, 1>} : f64
    %95 = arith.addf %91, %94 {timing = #hlscpp.t<121 -> 126, 5, 1>} : f64
    %96 = affine.load %arg1[%arg5 * 64 + 24] {partition_indices = [24], timing = #hlscpp.t<120 -> 122, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %97 = affine.load %arg3[24] {partition_indices = [24], timing = #hlscpp.t<120 -> 122, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %98 = arith.mulf %96, %97 {timing = #hlscpp.t<122 -> 126, 4, 1>} : f64
    %99 = arith.addf %95, %98 {timing = #hlscpp.t<126 -> 131, 5, 1>} : f64
    %100 = affine.load %arg1[%arg5 * 64 + 25] {partition_indices = [25], timing = #hlscpp.t<125 -> 127, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %101 = affine.load %arg3[25] {partition_indices = [25], timing = #hlscpp.t<125 -> 127, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %102 = arith.mulf %100, %101 {timing = #hlscpp.t<127 -> 131, 4, 1>} : f64
    %103 = arith.addf %99, %102 {timing = #hlscpp.t<131 -> 136, 5, 1>} : f64
    %104 = affine.load %arg1[%arg5 * 64 + 26] {partition_indices = [26], timing = #hlscpp.t<130 -> 132, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %105 = affine.load %arg3[26] {partition_indices = [26], timing = #hlscpp.t<130 -> 132, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %106 = arith.mulf %104, %105 {timing = #hlscpp.t<132 -> 136, 4, 1>} : f64
    %107 = arith.addf %103, %106 {timing = #hlscpp.t<136 -> 141, 5, 1>} : f64
    %108 = affine.load %arg1[%arg5 * 64 + 27] {partition_indices = [27], timing = #hlscpp.t<135 -> 137, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %109 = affine.load %arg3[27] {partition_indices = [27], timing = #hlscpp.t<135 -> 137, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %110 = arith.mulf %108, %109 {timing = #hlscpp.t<137 -> 141, 4, 1>} : f64
    %111 = arith.addf %107, %110 {timing = #hlscpp.t<141 -> 146, 5, 1>} : f64
    %112 = affine.load %arg1[%arg5 * 64 + 28] {partition_indices = [28], timing = #hlscpp.t<140 -> 142, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %113 = affine.load %arg3[28] {partition_indices = [28], timing = #hlscpp.t<140 -> 142, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %114 = arith.mulf %112, %113 {timing = #hlscpp.t<142 -> 146, 4, 1>} : f64
    %115 = arith.addf %111, %114 {timing = #hlscpp.t<146 -> 151, 5, 1>} : f64
    %116 = affine.load %arg1[%arg5 * 64 + 29] {partition_indices = [29], timing = #hlscpp.t<145 -> 147, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %117 = affine.load %arg3[29] {partition_indices = [29], timing = #hlscpp.t<145 -> 147, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %118 = arith.mulf %116, %117 {timing = #hlscpp.t<147 -> 151, 4, 1>} : f64
    %119 = arith.addf %115, %118 {timing = #hlscpp.t<151 -> 156, 5, 1>} : f64
    %120 = affine.load %arg1[%arg5 * 64 + 30] {partition_indices = [30], timing = #hlscpp.t<150 -> 152, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %121 = affine.load %arg3[30] {partition_indices = [30], timing = #hlscpp.t<150 -> 152, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %122 = arith.mulf %120, %121 {timing = #hlscpp.t<152 -> 156, 4, 1>} : f64
    %123 = arith.addf %119, %122 {timing = #hlscpp.t<156 -> 161, 5, 1>} : f64
    %124 = affine.load %arg1[%arg5 * 64 + 31] {partition_indices = [31], timing = #hlscpp.t<155 -> 157, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %125 = affine.load %arg3[31] {partition_indices = [31], timing = #hlscpp.t<155 -> 157, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %126 = arith.mulf %124, %125 {timing = #hlscpp.t<157 -> 161, 4, 1>} : f64
    %127 = arith.addf %123, %126 {timing = #hlscpp.t<161 -> 166, 5, 1>} : f64
    %128 = affine.load %arg1[%arg5 * 64 + 32] {partition_indices = [32], timing = #hlscpp.t<160 -> 162, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %129 = affine.load %arg3[32] {partition_indices = [32], timing = #hlscpp.t<160 -> 162, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %130 = arith.mulf %128, %129 {timing = #hlscpp.t<162 -> 166, 4, 1>} : f64
    %131 = arith.addf %127, %130 {timing = #hlscpp.t<166 -> 171, 5, 1>} : f64
    %132 = affine.load %arg1[%arg5 * 64 + 33] {partition_indices = [33], timing = #hlscpp.t<165 -> 167, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %133 = affine.load %arg3[33] {partition_indices = [33], timing = #hlscpp.t<165 -> 167, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %134 = arith.mulf %132, %133 {timing = #hlscpp.t<167 -> 171, 4, 1>} : f64
    %135 = arith.addf %131, %134 {timing = #hlscpp.t<171 -> 176, 5, 1>} : f64
    %136 = affine.load %arg1[%arg5 * 64 + 34] {partition_indices = [34], timing = #hlscpp.t<170 -> 172, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %137 = affine.load %arg3[34] {partition_indices = [34], timing = #hlscpp.t<170 -> 172, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %138 = arith.mulf %136, %137 {timing = #hlscpp.t<172 -> 176, 4, 1>} : f64
    %139 = arith.addf %135, %138 {timing = #hlscpp.t<176 -> 181, 5, 1>} : f64
    %140 = affine.load %arg1[%arg5 * 64 + 35] {partition_indices = [35], timing = #hlscpp.t<175 -> 177, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %141 = affine.load %arg3[35] {partition_indices = [35], timing = #hlscpp.t<175 -> 177, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %142 = arith.mulf %140, %141 {timing = #hlscpp.t<177 -> 181, 4, 1>} : f64
    %143 = arith.addf %139, %142 {timing = #hlscpp.t<181 -> 186, 5, 1>} : f64
    %144 = affine.load %arg1[%arg5 * 64 + 36] {partition_indices = [36], timing = #hlscpp.t<180 -> 182, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %145 = affine.load %arg3[36] {partition_indices = [36], timing = #hlscpp.t<180 -> 182, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %146 = arith.mulf %144, %145 {timing = #hlscpp.t<182 -> 186, 4, 1>} : f64
    %147 = arith.addf %143, %146 {timing = #hlscpp.t<186 -> 191, 5, 1>} : f64
    %148 = affine.load %arg1[%arg5 * 64 + 37] {partition_indices = [37], timing = #hlscpp.t<185 -> 187, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %149 = affine.load %arg3[37] {partition_indices = [37], timing = #hlscpp.t<185 -> 187, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %150 = arith.mulf %148, %149 {timing = #hlscpp.t<187 -> 191, 4, 1>} : f64
    %151 = arith.addf %147, %150 {timing = #hlscpp.t<191 -> 196, 5, 1>} : f64
    %152 = affine.load %arg1[%arg5 * 64 + 38] {partition_indices = [38], timing = #hlscpp.t<190 -> 192, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %153 = affine.load %arg3[38] {partition_indices = [38], timing = #hlscpp.t<190 -> 192, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %154 = arith.mulf %152, %153 {timing = #hlscpp.t<192 -> 196, 4, 1>} : f64
    %155 = arith.addf %151, %154 {timing = #hlscpp.t<196 -> 201, 5, 1>} : f64
    %156 = affine.load %arg1[%arg5 * 64 + 39] {partition_indices = [39], timing = #hlscpp.t<195 -> 197, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %157 = affine.load %arg3[39] {partition_indices = [39], timing = #hlscpp.t<195 -> 197, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %158 = arith.mulf %156, %157 {timing = #hlscpp.t<197 -> 201, 4, 1>} : f64
    %159 = arith.addf %155, %158 {timing = #hlscpp.t<201 -> 206, 5, 1>} : f64
    %160 = affine.load %arg1[%arg5 * 64 + 40] {partition_indices = [40], timing = #hlscpp.t<200 -> 202, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %161 = affine.load %arg3[40] {partition_indices = [40], timing = #hlscpp.t<200 -> 202, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %162 = arith.mulf %160, %161 {timing = #hlscpp.t<202 -> 206, 4, 1>} : f64
    %163 = arith.addf %159, %162 {timing = #hlscpp.t<206 -> 211, 5, 1>} : f64
    %164 = affine.load %arg1[%arg5 * 64 + 41] {partition_indices = [41], timing = #hlscpp.t<205 -> 207, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %165 = affine.load %arg3[41] {partition_indices = [41], timing = #hlscpp.t<205 -> 207, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %166 = arith.mulf %164, %165 {timing = #hlscpp.t<207 -> 211, 4, 1>} : f64
    %167 = arith.addf %163, %166 {timing = #hlscpp.t<211 -> 216, 5, 1>} : f64
    %168 = affine.load %arg1[%arg5 * 64 + 42] {partition_indices = [42], timing = #hlscpp.t<210 -> 212, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %169 = affine.load %arg3[42] {partition_indices = [42], timing = #hlscpp.t<210 -> 212, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %170 = arith.mulf %168, %169 {timing = #hlscpp.t<212 -> 216, 4, 1>} : f64
    %171 = arith.addf %167, %170 {timing = #hlscpp.t<216 -> 221, 5, 1>} : f64
    %172 = affine.load %arg1[%arg5 * 64 + 43] {partition_indices = [43], timing = #hlscpp.t<215 -> 217, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %173 = affine.load %arg3[43] {partition_indices = [43], timing = #hlscpp.t<215 -> 217, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %174 = arith.mulf %172, %173 {timing = #hlscpp.t<217 -> 221, 4, 1>} : f64
    %175 = arith.addf %171, %174 {timing = #hlscpp.t<221 -> 226, 5, 1>} : f64
    %176 = affine.load %arg1[%arg5 * 64 + 44] {partition_indices = [44], timing = #hlscpp.t<220 -> 222, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %177 = affine.load %arg3[44] {partition_indices = [44], timing = #hlscpp.t<220 -> 222, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %178 = arith.mulf %176, %177 {timing = #hlscpp.t<222 -> 226, 4, 1>} : f64
    %179 = arith.addf %175, %178 {timing = #hlscpp.t<226 -> 231, 5, 1>} : f64
    %180 = affine.load %arg1[%arg5 * 64 + 45] {partition_indices = [45], timing = #hlscpp.t<225 -> 227, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %181 = affine.load %arg3[45] {partition_indices = [45], timing = #hlscpp.t<225 -> 227, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %182 = arith.mulf %180, %181 {timing = #hlscpp.t<227 -> 231, 4, 1>} : f64
    %183 = arith.addf %179, %182 {timing = #hlscpp.t<231 -> 236, 5, 1>} : f64
    %184 = affine.load %arg1[%arg5 * 64 + 46] {partition_indices = [46], timing = #hlscpp.t<230 -> 232, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %185 = affine.load %arg3[46] {partition_indices = [46], timing = #hlscpp.t<230 -> 232, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %186 = arith.mulf %184, %185 {timing = #hlscpp.t<232 -> 236, 4, 1>} : f64
    %187 = arith.addf %183, %186 {timing = #hlscpp.t<236 -> 241, 5, 1>} : f64
    %188 = affine.load %arg1[%arg5 * 64 + 47] {partition_indices = [47], timing = #hlscpp.t<235 -> 237, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %189 = affine.load %arg3[47] {partition_indices = [47], timing = #hlscpp.t<235 -> 237, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %190 = arith.mulf %188, %189 {timing = #hlscpp.t<237 -> 241, 4, 1>} : f64
    %191 = arith.addf %187, %190 {timing = #hlscpp.t<241 -> 246, 5, 1>} : f64
    %192 = affine.load %arg1[%arg5 * 64 + 48] {partition_indices = [48], timing = #hlscpp.t<240 -> 242, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %193 = affine.load %arg3[48] {partition_indices = [48], timing = #hlscpp.t<240 -> 242, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %194 = arith.mulf %192, %193 {timing = #hlscpp.t<242 -> 246, 4, 1>} : f64
    %195 = arith.addf %191, %194 {timing = #hlscpp.t<246 -> 251, 5, 1>} : f64
    %196 = affine.load %arg1[%arg5 * 64 + 49] {partition_indices = [49], timing = #hlscpp.t<245 -> 247, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %197 = affine.load %arg3[49] {partition_indices = [49], timing = #hlscpp.t<245 -> 247, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %198 = arith.mulf %196, %197 {timing = #hlscpp.t<247 -> 251, 4, 1>} : f64
    %199 = arith.addf %195, %198 {timing = #hlscpp.t<251 -> 256, 5, 1>} : f64
    %200 = affine.load %arg1[%arg5 * 64 + 50] {partition_indices = [50], timing = #hlscpp.t<250 -> 252, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %201 = affine.load %arg3[50] {partition_indices = [50], timing = #hlscpp.t<250 -> 252, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %202 = arith.mulf %200, %201 {timing = #hlscpp.t<252 -> 256, 4, 1>} : f64
    %203 = arith.addf %199, %202 {timing = #hlscpp.t<256 -> 261, 5, 1>} : f64
    %204 = affine.load %arg1[%arg5 * 64 + 51] {partition_indices = [51], timing = #hlscpp.t<255 -> 257, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %205 = affine.load %arg3[51] {partition_indices = [51], timing = #hlscpp.t<255 -> 257, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %206 = arith.mulf %204, %205 {timing = #hlscpp.t<257 -> 261, 4, 1>} : f64
    %207 = arith.addf %203, %206 {timing = #hlscpp.t<261 -> 266, 5, 1>} : f64
    %208 = affine.load %arg1[%arg5 * 64 + 52] {partition_indices = [52], timing = #hlscpp.t<260 -> 262, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %209 = affine.load %arg3[52] {partition_indices = [52], timing = #hlscpp.t<260 -> 262, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %210 = arith.mulf %208, %209 {timing = #hlscpp.t<262 -> 266, 4, 1>} : f64
    %211 = arith.addf %207, %210 {timing = #hlscpp.t<266 -> 271, 5, 1>} : f64
    %212 = affine.load %arg1[%arg5 * 64 + 53] {partition_indices = [53], timing = #hlscpp.t<265 -> 267, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %213 = affine.load %arg3[53] {partition_indices = [53], timing = #hlscpp.t<265 -> 267, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %214 = arith.mulf %212, %213 {timing = #hlscpp.t<267 -> 271, 4, 1>} : f64
    %215 = arith.addf %211, %214 {timing = #hlscpp.t<271 -> 276, 5, 1>} : f64
    %216 = affine.load %arg1[%arg5 * 64 + 54] {partition_indices = [54], timing = #hlscpp.t<270 -> 272, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %217 = affine.load %arg3[54] {partition_indices = [54], timing = #hlscpp.t<270 -> 272, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %218 = arith.mulf %216, %217 {timing = #hlscpp.t<272 -> 276, 4, 1>} : f64
    %219 = arith.addf %215, %218 {timing = #hlscpp.t<276 -> 281, 5, 1>} : f64
    %220 = affine.load %arg1[%arg5 * 64 + 55] {partition_indices = [55], timing = #hlscpp.t<275 -> 277, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %221 = affine.load %arg3[55] {partition_indices = [55], timing = #hlscpp.t<275 -> 277, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %222 = arith.mulf %220, %221 {timing = #hlscpp.t<277 -> 281, 4, 1>} : f64
    %223 = arith.addf %219, %222 {timing = #hlscpp.t<281 -> 286, 5, 1>} : f64
    %224 = affine.load %arg1[%arg5 * 64 + 56] {partition_indices = [56], timing = #hlscpp.t<280 -> 282, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %225 = affine.load %arg3[56] {partition_indices = [56], timing = #hlscpp.t<280 -> 282, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %226 = arith.mulf %224, %225 {timing = #hlscpp.t<282 -> 286, 4, 1>} : f64
    %227 = arith.addf %223, %226 {timing = #hlscpp.t<286 -> 291, 5, 1>} : f64
    %228 = affine.load %arg1[%arg5 * 64 + 57] {partition_indices = [57], timing = #hlscpp.t<285 -> 287, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %229 = affine.load %arg3[57] {partition_indices = [57], timing = #hlscpp.t<285 -> 287, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %230 = arith.mulf %228, %229 {timing = #hlscpp.t<287 -> 291, 4, 1>} : f64
    %231 = arith.addf %227, %230 {timing = #hlscpp.t<291 -> 296, 5, 1>} : f64
    %232 = affine.load %arg1[%arg5 * 64 + 58] {partition_indices = [58], timing = #hlscpp.t<290 -> 292, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %233 = affine.load %arg3[58] {partition_indices = [58], timing = #hlscpp.t<290 -> 292, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %234 = arith.mulf %232, %233 {timing = #hlscpp.t<292 -> 296, 4, 1>} : f64
    %235 = arith.addf %231, %234 {timing = #hlscpp.t<296 -> 301, 5, 1>} : f64
    %236 = affine.load %arg1[%arg5 * 64 + 59] {partition_indices = [59], timing = #hlscpp.t<295 -> 297, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %237 = affine.load %arg3[59] {partition_indices = [59], timing = #hlscpp.t<295 -> 297, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %238 = arith.mulf %236, %237 {timing = #hlscpp.t<297 -> 301, 4, 1>} : f64
    %239 = arith.addf %235, %238 {timing = #hlscpp.t<301 -> 306, 5, 1>} : f64
    %240 = affine.load %arg1[%arg5 * 64 + 60] {partition_indices = [60], timing = #hlscpp.t<300 -> 302, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %241 = affine.load %arg3[60] {partition_indices = [60], timing = #hlscpp.t<300 -> 302, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %242 = arith.mulf %240, %241 {timing = #hlscpp.t<302 -> 306, 4, 1>} : f64
    %243 = arith.addf %239, %242 {timing = #hlscpp.t<306 -> 311, 5, 1>} : f64
    %244 = affine.load %arg1[%arg5 * 64 + 61] {partition_indices = [61], timing = #hlscpp.t<305 -> 307, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %245 = affine.load %arg3[61] {partition_indices = [61], timing = #hlscpp.t<305 -> 307, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %246 = arith.mulf %244, %245 {timing = #hlscpp.t<307 -> 311, 4, 1>} : f64
    %247 = arith.addf %243, %246 {timing = #hlscpp.t<311 -> 316, 5, 1>} : f64
    %248 = affine.load %arg1[%arg5 * 64 + 62] {partition_indices = [62], timing = #hlscpp.t<310 -> 312, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %249 = affine.load %arg3[62] {partition_indices = [62], timing = #hlscpp.t<310 -> 312, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %250 = arith.mulf %248, %249 {timing = #hlscpp.t<312 -> 316, 4, 1>} : f64
    %251 = arith.addf %247, %250 {timing = #hlscpp.t<316 -> 321, 5, 1>} : f64
    %252 = affine.load %arg1[%arg5 * 64 + 63] {partition_indices = [63], timing = #hlscpp.t<315 -> 317, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %253 = affine.load %arg3[63] {partition_indices = [63], timing = #hlscpp.t<315 -> 317, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 64, d0 floordiv 64)>, 1>
    %254 = arith.mulf %252, %253 {timing = #hlscpp.t<317 -> 321, 4, 1>} : f64
    %255 = arith.addf %251, %254 {timing = #hlscpp.t<321 -> 326, 5, 1>} : f64
    affine.store %255, %arg2[%arg5] {max_mux_size = 1 : i64, partition_indices = [0], timing = #hlscpp.t<326 -> 327, 1, 1>} : memref<3xf64, affine_map<(d0) -> (0, d0)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=1, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=3, iterLatency=327, minII=1>, timing = #hlscpp.t<0 -> 331, 331, 331>}
  affine.store %cst, %arg4[0] {partition_indices = [0], timing = #hlscpp.t<331 -> 332, 1, 1>} : memref<1xf64, 1>
  return {timing = #hlscpp.t<332 -> 332, 0, 0>}
}
