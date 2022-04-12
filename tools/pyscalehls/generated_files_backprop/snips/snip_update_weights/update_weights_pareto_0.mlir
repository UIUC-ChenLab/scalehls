func @update_weights(%arg0: memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>, %arg1: memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>, %arg2: memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>, %arg3: memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>, %arg4: memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>, %arg5: memref<192xf64, affine_map<(d0) -> (d0 mod 12, d0 floordiv 12)>, 1>, %arg6: memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>, %arg7: memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>, %arg8: memref<3xf64, affine_map<(d0) -> (0, d0)>, 1>, %arg9: memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>, %arg10: memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>, %arg11: memref<3xf64, affine_map<(d0) -> (0, d0)>, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>, llvm.linkage = #llvm.linkage<external>, resource = #hlscpp.r<lut=0, dsp=15, bram=0>, timing = #hlscpp.t<0 -> 30100, 30100, 30100>} {
  %cst = arith.constant {timing = #hlscpp.t<1 -> 1, 0, 0>} 1.000000e-02 : f64
  %cst_0 = arith.constant {timing = #hlscpp.t<0 -> 0, 0, 0>} 0.000000e+00 : f64
  %0 = memref.alloc() {timing = #hlscpp.t<0 -> 0, 0, 0>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  affine.store %cst_0, %0[0] {partition_indices = [0], timing = #hlscpp.t<0 -> 1, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  %1 = memref.alloc() {timing = #hlscpp.t<0 -> 0, 0, 0>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  affine.store %cst_0, %1[0] {partition_indices = [0], timing = #hlscpp.t<0 -> 1, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  %2 = memref.alloc() {timing = #hlscpp.t<1 -> 1, 0, 0>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  %3 = memref.alloc() {timing = #hlscpp.t<1 -> 1, 0, 0>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  affine.for %arg12 = 0 to 13 {
    affine.for %arg13 = 0 to 4 {
      %30 = affine.load %0[0] {partition_indices = [0], timing = #hlscpp.t<14 -> 15, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      %31 = affine.load %2[0] {partition_indices = [0], timing = #hlscpp.t<14 -> 15, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      %32 = affine.if affine_set<(d0) : (d0 * 16 == 0)>(%arg13) -> f64 {
        affine.yield {timing = #hlscpp.t<15 -> 15, 0, 0>} %30 : f64
      } else {
        affine.yield {timing = #hlscpp.t<15 -> 15, 0, 0>} %31 : f64
      } {timing = #hlscpp.t<15 -> 15, 0, 0>}
      %33 = affine.load %arg3[%arg12 * 64 + %arg13 * 16] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %34 = arith.mulf %33, %cst {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
      %35 = affine.load %arg0[%arg12 * 64 + %arg13 * 16] {partition_indices = [0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %36 = arith.subf %35, %34 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
      affine.store %36, %arg0[%arg12 * 64 + %arg13 * 16] {partition_indices = [0], timing = #hlscpp.t<95 -> 96, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %37 = arith.mulf %36, %36 {timing = #hlscpp.t<11 -> 15, 4, 1>} : f64
      %38 = arith.addf %32, %37 {timing = #hlscpp.t<15 -> 20, 5, 1>} : f64
      %39 = affine.load %arg3[%arg12 * 64 + %arg13 * 16 + 1] {partition_indices = [1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %40 = arith.mulf %39, %cst {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
      %41 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 1] {partition_indices = [1], timing = #hlscpp.t<9 -> 11, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %42 = arith.subf %41, %40 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
      affine.store %42, %arg0[%arg12 * 64 + %arg13 * 16 + 1] {partition_indices = [1], timing = #hlscpp.t<95 -> 96, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %43 = arith.mulf %42, %42 {timing = #hlscpp.t<16 -> 20, 4, 1>} : f64
      %44 = arith.addf %38, %43 {timing = #hlscpp.t<20 -> 25, 5, 1>} : f64
      %45 = affine.load %arg3[%arg12 * 64 + %arg13 * 16 + 2] {partition_indices = [2], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %46 = arith.mulf %45, %cst {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
      %47 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 2] {partition_indices = [2], timing = #hlscpp.t<14 -> 16, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %48 = arith.subf %47, %46 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
      affine.store %48, %arg0[%arg12 * 64 + %arg13 * 16 + 2] {partition_indices = [2], timing = #hlscpp.t<95 -> 96, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %49 = arith.mulf %48, %48 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
      %50 = arith.addf %44, %49 {timing = #hlscpp.t<25 -> 30, 5, 1>} : f64
      %51 = affine.load %arg3[%arg12 * 64 + %arg13 * 16 + 3] {partition_indices = [3], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %52 = arith.mulf %51, %cst {timing = #hlscpp.t<17 -> 21, 4, 1>} : f64
      %53 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 3] {partition_indices = [3], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %54 = arith.subf %53, %52 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f64
      affine.store %54, %arg0[%arg12 * 64 + %arg13 * 16 + 3] {partition_indices = [3], timing = #hlscpp.t<95 -> 96, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %55 = arith.mulf %54, %54 {timing = #hlscpp.t<26 -> 30, 4, 1>} : f64
      %56 = arith.addf %50, %55 {timing = #hlscpp.t<30 -> 35, 5, 1>} : f64
      %57 = affine.load %arg3[%arg12 * 64 + %arg13 * 16 + 4] {partition_indices = [4], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %58 = arith.mulf %57, %cst {timing = #hlscpp.t<22 -> 26, 4, 1>} : f64
      %59 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 4] {partition_indices = [4], timing = #hlscpp.t<24 -> 26, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %60 = arith.subf %59, %58 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f64
      affine.store %60, %arg0[%arg12 * 64 + %arg13 * 16 + 4] {partition_indices = [4], timing = #hlscpp.t<95 -> 96, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %61 = arith.mulf %60, %60 {timing = #hlscpp.t<31 -> 35, 4, 1>} : f64
      %62 = arith.addf %56, %61 {timing = #hlscpp.t<35 -> 40, 5, 1>} : f64
      %63 = affine.load %arg3[%arg12 * 64 + %arg13 * 16 + 5] {partition_indices = [5], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %64 = arith.mulf %63, %cst {timing = #hlscpp.t<27 -> 31, 4, 1>} : f64
      %65 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 5] {partition_indices = [5], timing = #hlscpp.t<29 -> 31, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %66 = arith.subf %65, %64 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f64
      affine.store %66, %arg0[%arg12 * 64 + %arg13 * 16 + 5] {partition_indices = [5], timing = #hlscpp.t<95 -> 96, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %67 = arith.mulf %66, %66 {timing = #hlscpp.t<36 -> 40, 4, 1>} : f64
      %68 = arith.addf %62, %67 {timing = #hlscpp.t<40 -> 45, 5, 1>} : f64
      %69 = affine.load %arg3[%arg12 * 64 + %arg13 * 16 + 6] {partition_indices = [6], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %70 = arith.mulf %69, %cst {timing = #hlscpp.t<32 -> 36, 4, 1>} : f64
      %71 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 6] {partition_indices = [6], timing = #hlscpp.t<34 -> 36, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %72 = arith.subf %71, %70 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f64
      affine.store %72, %arg0[%arg12 * 64 + %arg13 * 16 + 6] {partition_indices = [6], timing = #hlscpp.t<95 -> 96, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %73 = arith.mulf %72, %72 {timing = #hlscpp.t<41 -> 45, 4, 1>} : f64
      %74 = arith.addf %68, %73 {timing = #hlscpp.t<45 -> 50, 5, 1>} : f64
      %75 = affine.load %arg3[%arg12 * 64 + %arg13 * 16 + 7] {partition_indices = [7], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %76 = arith.mulf %75, %cst {timing = #hlscpp.t<37 -> 41, 4, 1>} : f64
      %77 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 7] {partition_indices = [7], timing = #hlscpp.t<39 -> 41, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %78 = arith.subf %77, %76 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f64
      affine.store %78, %arg0[%arg12 * 64 + %arg13 * 16 + 7] {partition_indices = [7], timing = #hlscpp.t<95 -> 96, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %79 = arith.mulf %78, %78 {timing = #hlscpp.t<46 -> 50, 4, 1>} : f64
      %80 = arith.addf %74, %79 {timing = #hlscpp.t<50 -> 55, 5, 1>} : f64
      %81 = affine.load %arg3[%arg12 * 64 + %arg13 * 16 + 8] {partition_indices = [8], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %82 = arith.mulf %81, %cst {timing = #hlscpp.t<42 -> 46, 4, 1>} : f64
      %83 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 8] {partition_indices = [8], timing = #hlscpp.t<44 -> 46, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %84 = arith.subf %83, %82 {timing = #hlscpp.t<46 -> 51, 5, 1>} : f64
      affine.store %84, %arg0[%arg12 * 64 + %arg13 * 16 + 8] {partition_indices = [8], timing = #hlscpp.t<95 -> 96, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %85 = arith.mulf %84, %84 {timing = #hlscpp.t<51 -> 55, 4, 1>} : f64
      %86 = arith.addf %80, %85 {timing = #hlscpp.t<55 -> 60, 5, 1>} : f64
      %87 = affine.load %arg3[%arg12 * 64 + %arg13 * 16 + 9] {partition_indices = [9], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %88 = arith.mulf %87, %cst {timing = #hlscpp.t<47 -> 51, 4, 1>} : f64
      %89 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 9] {partition_indices = [9], timing = #hlscpp.t<49 -> 51, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %90 = arith.subf %89, %88 {timing = #hlscpp.t<51 -> 56, 5, 1>} : f64
      affine.store %90, %arg0[%arg12 * 64 + %arg13 * 16 + 9] {partition_indices = [9], timing = #hlscpp.t<95 -> 96, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %91 = arith.mulf %90, %90 {timing = #hlscpp.t<56 -> 60, 4, 1>} : f64
      %92 = arith.addf %86, %91 {timing = #hlscpp.t<60 -> 65, 5, 1>} : f64
      %93 = affine.load %arg3[%arg12 * 64 + %arg13 * 16 + 10] {partition_indices = [10], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %94 = arith.mulf %93, %cst {timing = #hlscpp.t<52 -> 56, 4, 1>} : f64
      %95 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 10] {partition_indices = [10], timing = #hlscpp.t<54 -> 56, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %96 = arith.subf %95, %94 {timing = #hlscpp.t<56 -> 61, 5, 1>} : f64
      affine.store %96, %arg0[%arg12 * 64 + %arg13 * 16 + 10] {partition_indices = [10], timing = #hlscpp.t<95 -> 96, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %97 = arith.mulf %96, %96 {timing = #hlscpp.t<61 -> 65, 4, 1>} : f64
      %98 = arith.addf %92, %97 {timing = #hlscpp.t<65 -> 70, 5, 1>} : f64
      %99 = affine.load %arg3[%arg12 * 64 + %arg13 * 16 + 11] {partition_indices = [11], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %100 = arith.mulf %99, %cst {timing = #hlscpp.t<57 -> 61, 4, 1>} : f64
      %101 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 11] {partition_indices = [11], timing = #hlscpp.t<59 -> 61, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %102 = arith.subf %101, %100 {timing = #hlscpp.t<61 -> 66, 5, 1>} : f64
      affine.store %102, %arg0[%arg12 * 64 + %arg13 * 16 + 11] {partition_indices = [11], timing = #hlscpp.t<95 -> 96, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %103 = arith.mulf %102, %102 {timing = #hlscpp.t<66 -> 70, 4, 1>} : f64
      %104 = arith.addf %98, %103 {timing = #hlscpp.t<70 -> 75, 5, 1>} : f64
      %105 = affine.load %arg3[%arg12 * 64 + %arg13 * 16 + 12] {partition_indices = [12], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %106 = arith.mulf %105, %cst {timing = #hlscpp.t<62 -> 66, 4, 1>} : f64
      %107 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 12] {partition_indices = [12], timing = #hlscpp.t<64 -> 66, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %108 = arith.subf %107, %106 {timing = #hlscpp.t<66 -> 71, 5, 1>} : f64
      affine.store %108, %arg0[%arg12 * 64 + %arg13 * 16 + 12] {partition_indices = [12], timing = #hlscpp.t<95 -> 96, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %109 = arith.mulf %108, %108 {timing = #hlscpp.t<71 -> 75, 4, 1>} : f64
      %110 = arith.addf %104, %109 {timing = #hlscpp.t<75 -> 80, 5, 1>} : f64
      %111 = affine.load %arg3[%arg12 * 64 + %arg13 * 16 + 13] {partition_indices = [13], timing = #hlscpp.t<65 -> 67, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %112 = arith.mulf %111, %cst {timing = #hlscpp.t<67 -> 71, 4, 1>} : f64
      %113 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 13] {partition_indices = [13], timing = #hlscpp.t<69 -> 71, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %114 = arith.subf %113, %112 {timing = #hlscpp.t<71 -> 76, 5, 1>} : f64
      affine.store %114, %arg0[%arg12 * 64 + %arg13 * 16 + 13] {partition_indices = [13], timing = #hlscpp.t<95 -> 96, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %115 = arith.mulf %114, %114 {timing = #hlscpp.t<76 -> 80, 4, 1>} : f64
      %116 = arith.addf %110, %115 {timing = #hlscpp.t<80 -> 85, 5, 1>} : f64
      %117 = affine.load %arg3[%arg12 * 64 + %arg13 * 16 + 14] {partition_indices = [14], timing = #hlscpp.t<70 -> 72, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %118 = arith.mulf %117, %cst {timing = #hlscpp.t<72 -> 76, 4, 1>} : f64
      %119 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 14] {partition_indices = [14], timing = #hlscpp.t<74 -> 76, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %120 = arith.subf %119, %118 {timing = #hlscpp.t<76 -> 81, 5, 1>} : f64
      affine.store %120, %arg0[%arg12 * 64 + %arg13 * 16 + 14] {partition_indices = [14], timing = #hlscpp.t<95 -> 96, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %121 = arith.mulf %120, %120 {timing = #hlscpp.t<81 -> 85, 4, 1>} : f64
      %122 = arith.addf %116, %121 {timing = #hlscpp.t<85 -> 90, 5, 1>} : f64
      %123 = affine.load %arg3[%arg12 * 64 + %arg13 * 16 + 15] {partition_indices = [15], timing = #hlscpp.t<75 -> 77, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %124 = arith.mulf %123, %cst {timing = #hlscpp.t<77 -> 81, 4, 1>} : f64
      %125 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 15] {partition_indices = [15], timing = #hlscpp.t<79 -> 81, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %126 = arith.subf %125, %124 {timing = #hlscpp.t<81 -> 86, 5, 1>} : f64
      affine.store %126, %arg0[%arg12 * 64 + %arg13 * 16 + 15] {partition_indices = [15], timing = #hlscpp.t<95 -> 96, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %127 = arith.mulf %126, %126 {timing = #hlscpp.t<86 -> 90, 4, 1>} : f64
      %128 = arith.addf %122, %127 {timing = #hlscpp.t<90 -> 95, 5, 1>} : f64
      affine.store %128, %2[0] {partition_indices = [0], timing = #hlscpp.t<95 -> 96, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      affine.store %128, %3[0] {partition_indices = [0], timing = #hlscpp.t<95 -> 96, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      affine.if affine_set<(d0) : (-(d0 * 16 + 15) + 63 == 0)>(%arg13) {
        affine.store %128, %0[0] {partition_indices = [0], timing = #hlscpp.t<95 -> 96, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
        affine.store %128, %1[0] {partition_indices = [0], timing = #hlscpp.t<95 -> 96, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      } {timing = #hlscpp.t<95 -> 96, 1, 0>}
    } {loop_directive = #hlscpp.ld<pipeline=true, targetII=82, dataflow=false, flatten=false, parallel=false>, loop_info = #hlscpp.l<flattenTripCount=4, iterLatency=96, minII=82>, timing = #hlscpp.t<25817 -> 26161, 344, 344>}
  } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true, parallel=false>, loop_info = #hlscpp.l<flattenTripCount=52, iterLatency=96, minII=82>, timing = #hlscpp.t<1 -> 4281, 4280, 4280>}
  %4 = affine.load %1[0] {partition_indices = [0], timing = #hlscpp.t<4388 -> 4389, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  %5 = memref.alloc() {timing = #hlscpp.t<4281 -> 4281, 0, 0>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  affine.store %cst_0, %5[0] {partition_indices = [0], timing = #hlscpp.t<4281 -> 4282, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  %6 = memref.alloc() {timing = #hlscpp.t<4281 -> 4281, 0, 0>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  affine.store %cst_0, %6[0] {partition_indices = [0], timing = #hlscpp.t<4281 -> 4282, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  affine.for %arg12 = 0 to 8 {
    %30 = affine.load %arg9[%arg12 * 8] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %31 = arith.mulf %30, %cst {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %32 = affine.load %arg6[%arg12 * 8] {partition_indices = [0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %33 = arith.subf %32, %31 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    affine.store %33, %arg6[%arg12 * 8] {partition_indices = [0], timing = #hlscpp.t<55 -> 56, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %34 = arith.mulf %33, %33 {timing = #hlscpp.t<11 -> 15, 4, 1>} : f64
    %35 = affine.load %arg9[%arg12 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %36 = arith.mulf %35, %cst {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %37 = affine.load %arg6[%arg12 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %38 = arith.subf %37, %36 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    affine.store %38, %arg6[%arg12 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<55 -> 56, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %39 = arith.mulf %38, %38 {timing = #hlscpp.t<11 -> 15, 4, 1>} : f64
    %40 = arith.addf %34, %39 {timing = #hlscpp.t<15 -> 20, 5, 1>} : f64
    %41 = affine.load %arg9[%arg12 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %42 = arith.mulf %41, %cst {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %43 = affine.load %arg6[%arg12 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<9 -> 11, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %44 = arith.subf %43, %42 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    affine.store %44, %arg6[%arg12 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<55 -> 56, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %45 = arith.mulf %44, %44 {timing = #hlscpp.t<16 -> 20, 4, 1>} : f64
    %46 = arith.addf %40, %45 {timing = #hlscpp.t<20 -> 25, 5, 1>} : f64
    %47 = affine.load %arg9[%arg12 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %48 = arith.mulf %47, %cst {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %49 = affine.load %arg6[%arg12 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<14 -> 16, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %50 = arith.subf %49, %48 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    affine.store %50, %arg6[%arg12 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<55 -> 56, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %51 = arith.mulf %50, %50 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    %52 = arith.addf %46, %51 {timing = #hlscpp.t<25 -> 30, 5, 1>} : f64
    %53 = affine.load %arg9[%arg12 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %54 = arith.mulf %53, %cst {timing = #hlscpp.t<17 -> 21, 4, 1>} : f64
    %55 = affine.load %arg6[%arg12 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %56 = arith.subf %55, %54 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f64
    affine.store %56, %arg6[%arg12 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<55 -> 56, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %57 = arith.mulf %56, %56 {timing = #hlscpp.t<26 -> 30, 4, 1>} : f64
    %58 = arith.addf %52, %57 {timing = #hlscpp.t<30 -> 35, 5, 1>} : f64
    %59 = affine.load %arg9[%arg12 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %60 = arith.mulf %59, %cst {timing = #hlscpp.t<22 -> 26, 4, 1>} : f64
    %61 = affine.load %arg6[%arg12 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<24 -> 26, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %62 = arith.subf %61, %60 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f64
    affine.store %62, %arg6[%arg12 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<55 -> 56, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %63 = arith.mulf %62, %62 {timing = #hlscpp.t<31 -> 35, 4, 1>} : f64
    %64 = arith.addf %58, %63 {timing = #hlscpp.t<35 -> 40, 5, 1>} : f64
    %65 = affine.load %arg9[%arg12 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %66 = arith.mulf %65, %cst {timing = #hlscpp.t<27 -> 31, 4, 1>} : f64
    %67 = affine.load %arg6[%arg12 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<29 -> 31, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %68 = arith.subf %67, %66 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f64
    affine.store %68, %arg6[%arg12 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<55 -> 56, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %69 = arith.mulf %68, %68 {timing = #hlscpp.t<36 -> 40, 4, 1>} : f64
    %70 = arith.addf %64, %69 {timing = #hlscpp.t<40 -> 45, 5, 1>} : f64
    %71 = affine.load %arg9[%arg12 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %72 = arith.mulf %71, %cst {timing = #hlscpp.t<32 -> 36, 4, 1>} : f64
    %73 = affine.load %arg6[%arg12 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<34 -> 36, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %74 = arith.subf %73, %72 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f64
    affine.store %74, %arg6[%arg12 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<55 -> 56, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %75 = arith.mulf %74, %74 {timing = #hlscpp.t<41 -> 45, 4, 1>} : f64
    %76 = arith.addf %70, %75 {timing = #hlscpp.t<45 -> 50, 5, 1>} : f64
    %77 = affine.load %5[0] {partition_indices = [0], timing = #hlscpp.t<49 -> 50, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
    %78 = arith.addf %77, %76 {timing = #hlscpp.t<50 -> 55, 5, 1>} : f64
    affine.store %78, %5[0] {partition_indices = [0], timing = #hlscpp.t<55 -> 56, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
    affine.store %78, %6[0] {partition_indices = [0], timing = #hlscpp.t<55 -> 56, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=7, dataflow=false, flatten=false, parallel=false>, loop_info = #hlscpp.l<flattenTripCount=8, iterLatency=56, minII=7>, timing = #hlscpp.t<4282 -> 4389, 107, 107>}
  %7 = affine.load %6[0] {partition_indices = [0], timing = #hlscpp.t<4460 -> 4461, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  %8 = math.sqrt %4 {timing = #hlscpp.t<4389 -> 4389, 0, 0>} : f64
  %9 = math.sqrt %7 {timing = #hlscpp.t<4461 -> 4461, 0, 0>} : f64
  affine.for %arg12 = 0 to 13 {
    affine.for %arg13 = 0 to 4 {
      %30 = affine.load %arg0[%arg12 * 64 + %arg13 * 16] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %31 = arith.divf %30, %8 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
      affine.store %31, %arg0[%arg12 * 64 + %arg13 * 16] {partition_indices = [0], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %32 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 1] {partition_indices = [1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %33 = arith.divf %32, %8 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
      affine.store %33, %arg0[%arg12 * 64 + %arg13 * 16 + 1] {partition_indices = [1], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %34 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 2] {partition_indices = [2], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %35 = arith.divf %34, %8 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
      affine.store %35, %arg0[%arg12 * 64 + %arg13 * 16 + 2] {partition_indices = [2], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %36 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 3] {partition_indices = [3], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %37 = arith.divf %36, %8 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
      affine.store %37, %arg0[%arg12 * 64 + %arg13 * 16 + 3] {partition_indices = [3], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %38 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 4] {partition_indices = [4], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %39 = arith.divf %38, %8 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
      affine.store %39, %arg0[%arg12 * 64 + %arg13 * 16 + 4] {partition_indices = [4], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %40 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 5] {partition_indices = [5], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %41 = arith.divf %40, %8 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
      affine.store %41, %arg0[%arg12 * 64 + %arg13 * 16 + 5] {partition_indices = [5], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %42 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 6] {partition_indices = [6], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %43 = arith.divf %42, %8 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
      affine.store %43, %arg0[%arg12 * 64 + %arg13 * 16 + 6] {partition_indices = [6], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %44 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 7] {partition_indices = [7], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %45 = arith.divf %44, %8 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
      affine.store %45, %arg0[%arg12 * 64 + %arg13 * 16 + 7] {partition_indices = [7], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %46 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 8] {partition_indices = [8], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %47 = arith.divf %46, %8 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
      affine.store %47, %arg0[%arg12 * 64 + %arg13 * 16 + 8] {partition_indices = [8], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %48 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 9] {partition_indices = [9], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %49 = arith.divf %48, %8 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
      affine.store %49, %arg0[%arg12 * 64 + %arg13 * 16 + 9] {partition_indices = [9], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %50 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 10] {partition_indices = [10], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %51 = arith.divf %50, %8 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
      affine.store %51, %arg0[%arg12 * 64 + %arg13 * 16 + 10] {partition_indices = [10], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %52 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 11] {partition_indices = [11], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %53 = arith.divf %52, %8 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
      affine.store %53, %arg0[%arg12 * 64 + %arg13 * 16 + 11] {partition_indices = [11], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %54 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 12] {partition_indices = [12], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %55 = arith.divf %54, %8 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
      affine.store %55, %arg0[%arg12 * 64 + %arg13 * 16 + 12] {partition_indices = [12], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %56 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 13] {partition_indices = [13], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %57 = arith.divf %56, %8 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
      affine.store %57, %arg0[%arg12 * 64 + %arg13 * 16 + 13] {partition_indices = [13], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %58 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 14] {partition_indices = [14], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %59 = arith.divf %58, %8 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
      affine.store %59, %arg0[%arg12 * 64 + %arg13 * 16 + 14] {partition_indices = [14], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %60 = affine.load %arg0[%arg12 * 64 + %arg13 * 16 + 15] {partition_indices = [15], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
      %61 = arith.divf %60, %8 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
      affine.store %61, %arg0[%arg12 * 64 + %arg13 * 16 + 15] {partition_indices = [15], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<832xf64, affine_map<(d0) -> (d0 mod 16, d0 floordiv 16)>, 1>
    } {loop_directive = #hlscpp.ld<pipeline=true, targetII=1, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=4, iterLatency=19, minII=1>, timing = #hlscpp.t<25637 -> 25661, 24, 24>}
  } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=52, iterLatency=19, minII=1>, timing = #hlscpp.t<4389 -> 4461, 72, 72>}
  affine.for %arg12 = 0 to 8 {
    %30 = affine.load %arg6[%arg12 * 8] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %31 = arith.divf %30, %9 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %31, %arg6[%arg12 * 8] {partition_indices = [0], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %32 = affine.load %arg6[%arg12 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %33 = arith.divf %32, %9 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %33, %arg6[%arg12 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %34 = affine.load %arg6[%arg12 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %35 = arith.divf %34, %9 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %35, %arg6[%arg12 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %36 = affine.load %arg6[%arg12 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %37 = arith.divf %36, %9 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %37, %arg6[%arg12 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %38 = affine.load %arg6[%arg12 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %39 = arith.divf %38, %9 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %39, %arg6[%arg12 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %40 = affine.load %arg6[%arg12 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %41 = arith.divf %40, %9 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %41, %arg6[%arg12 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %42 = affine.load %arg6[%arg12 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %43 = arith.divf %42, %9 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %43, %arg6[%arg12 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %44 = affine.load %arg6[%arg12 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %45 = arith.divf %44, %9 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %45, %arg6[%arg12 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=1, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=8, iterLatency=19, minII=1>, timing = #hlscpp.t<4461 -> 4489, 28, 28>}
  %10 = memref.alloc() {timing = #hlscpp.t<4489 -> 4489, 0, 0>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  affine.store %cst_0, %10[0] {partition_indices = [0], timing = #hlscpp.t<4489 -> 4490, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  %11 = memref.alloc() {timing = #hlscpp.t<4489 -> 4489, 0, 0>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  affine.store %cst_0, %11[0] {partition_indices = [0], timing = #hlscpp.t<4489 -> 4490, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  %12 = memref.alloc() {timing = #hlscpp.t<4490 -> 4490, 0, 0>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  %13 = memref.alloc() {timing = #hlscpp.t<4490 -> 4490, 0, 0>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  affine.for %arg12 = 0 to 8 {
    affine.for %arg13 = 0 to 4 {
      %30 = affine.load %10[0] {partition_indices = [0], timing = #hlscpp.t<14 -> 15, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      %31 = affine.load %12[0] {partition_indices = [0], timing = #hlscpp.t<14 -> 15, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      %32 = affine.if affine_set<(d0) : (d0 * 16 == 0)>(%arg13) -> f64 {
        affine.yield {timing = #hlscpp.t<15 -> 15, 0, 0>} %30 : f64
      } else {
        affine.yield {timing = #hlscpp.t<15 -> 15, 0, 0>} %31 : f64
      } {timing = #hlscpp.t<15 -> 15, 0, 0>}
      %33 = affine.load %arg4[%arg13 * 16 + %arg12 * 512] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %34 = arith.mulf %33, %cst {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
      %35 = affine.load %arg1[%arg13 * 16 + %arg12 * 512] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %36 = arith.subf %35, %34 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
      affine.store %36, %arg1[%arg13 * 16 + %arg12 * 512] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<542 -> 543, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %37 = arith.mulf %36, %36 {timing = #hlscpp.t<11 -> 15, 4, 1>} : f64
      %38 = arith.addf %32, %37 {timing = #hlscpp.t<15 -> 20, 5, 1>} : f64
      %39 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 1] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %40 = arith.mulf %39, %cst {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
      %41 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 1] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<9 -> 11, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %42 = arith.subf %41, %40 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
      affine.store %42, %arg1[%arg13 * 16 + %arg12 * 512 + 1] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<543 -> 544, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %43 = arith.mulf %42, %42 {timing = #hlscpp.t<16 -> 20, 4, 1>} : f64
      %44 = arith.addf %38, %43 {timing = #hlscpp.t<20 -> 25, 5, 1>} : f64
      %45 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 2] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %46 = arith.mulf %45, %cst {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
      %47 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 2] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<14 -> 16, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %48 = arith.subf %47, %46 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
      affine.store %48, %arg1[%arg13 * 16 + %arg12 * 512 + 2] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<544 -> 545, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %49 = arith.mulf %48, %48 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
      %50 = arith.addf %44, %49 {timing = #hlscpp.t<25 -> 30, 5, 1>} : f64
      %51 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 3] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %52 = arith.mulf %51, %cst {timing = #hlscpp.t<17 -> 21, 4, 1>} : f64
      %53 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 3] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %54 = arith.subf %53, %52 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f64
      affine.store %54, %arg1[%arg13 * 16 + %arg12 * 512 + 3] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<545 -> 546, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %55 = arith.mulf %54, %54 {timing = #hlscpp.t<26 -> 30, 4, 1>} : f64
      %56 = arith.addf %50, %55 {timing = #hlscpp.t<30 -> 35, 5, 1>} : f64
      %57 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 4] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %58 = arith.mulf %57, %cst {timing = #hlscpp.t<22 -> 26, 4, 1>} : f64
      %59 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 4] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<24 -> 26, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %60 = arith.subf %59, %58 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f64
      affine.store %60, %arg1[%arg13 * 16 + %arg12 * 512 + 4] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<546 -> 547, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %61 = arith.mulf %60, %60 {timing = #hlscpp.t<31 -> 35, 4, 1>} : f64
      %62 = arith.addf %56, %61 {timing = #hlscpp.t<35 -> 40, 5, 1>} : f64
      %63 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 5] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %64 = arith.mulf %63, %cst {timing = #hlscpp.t<27 -> 31, 4, 1>} : f64
      %65 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 5] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<29 -> 31, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %66 = arith.subf %65, %64 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f64
      affine.store %66, %arg1[%arg13 * 16 + %arg12 * 512 + 5] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<547 -> 548, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %67 = arith.mulf %66, %66 {timing = #hlscpp.t<36 -> 40, 4, 1>} : f64
      %68 = arith.addf %62, %67 {timing = #hlscpp.t<40 -> 45, 5, 1>} : f64
      %69 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 6] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %70 = arith.mulf %69, %cst {timing = #hlscpp.t<32 -> 36, 4, 1>} : f64
      %71 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 6] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<34 -> 36, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %72 = arith.subf %71, %70 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f64
      affine.store %72, %arg1[%arg13 * 16 + %arg12 * 512 + 6] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<548 -> 549, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %73 = arith.mulf %72, %72 {timing = #hlscpp.t<41 -> 45, 4, 1>} : f64
      %74 = arith.addf %68, %73 {timing = #hlscpp.t<45 -> 50, 5, 1>} : f64
      %75 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 7] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %76 = arith.mulf %75, %cst {timing = #hlscpp.t<37 -> 41, 4, 1>} : f64
      %77 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 7] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<39 -> 41, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %78 = arith.subf %77, %76 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f64
      affine.store %78, %arg1[%arg13 * 16 + %arg12 * 512 + 7] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<549 -> 550, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %79 = arith.mulf %78, %78 {timing = #hlscpp.t<46 -> 50, 4, 1>} : f64
      %80 = arith.addf %74, %79 {timing = #hlscpp.t<50 -> 55, 5, 1>} : f64
      %81 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 8] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %82 = arith.mulf %81, %cst {timing = #hlscpp.t<42 -> 46, 4, 1>} : f64
      %83 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 8] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<44 -> 46, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %84 = arith.subf %83, %82 {timing = #hlscpp.t<46 -> 51, 5, 1>} : f64
      affine.store %84, %arg1[%arg13 * 16 + %arg12 * 512 + 8] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<550 -> 551, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %85 = arith.mulf %84, %84 {timing = #hlscpp.t<51 -> 55, 4, 1>} : f64
      %86 = arith.addf %80, %85 {timing = #hlscpp.t<55 -> 60, 5, 1>} : f64
      %87 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 9] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %88 = arith.mulf %87, %cst {timing = #hlscpp.t<47 -> 51, 4, 1>} : f64
      %89 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 9] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<49 -> 51, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %90 = arith.subf %89, %88 {timing = #hlscpp.t<51 -> 56, 5, 1>} : f64
      affine.store %90, %arg1[%arg13 * 16 + %arg12 * 512 + 9] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<551 -> 552, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %91 = arith.mulf %90, %90 {timing = #hlscpp.t<56 -> 60, 4, 1>} : f64
      %92 = arith.addf %86, %91 {timing = #hlscpp.t<60 -> 65, 5, 1>} : f64
      %93 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 10] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %94 = arith.mulf %93, %cst {timing = #hlscpp.t<52 -> 56, 4, 1>} : f64
      %95 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 10] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<54 -> 56, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %96 = arith.subf %95, %94 {timing = #hlscpp.t<56 -> 61, 5, 1>} : f64
      affine.store %96, %arg1[%arg13 * 16 + %arg12 * 512 + 10] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<552 -> 553, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %97 = arith.mulf %96, %96 {timing = #hlscpp.t<61 -> 65, 4, 1>} : f64
      %98 = arith.addf %92, %97 {timing = #hlscpp.t<65 -> 70, 5, 1>} : f64
      %99 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 11] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<55 -> 57, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %100 = arith.mulf %99, %cst {timing = #hlscpp.t<57 -> 61, 4, 1>} : f64
      %101 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 11] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<59 -> 61, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %102 = arith.subf %101, %100 {timing = #hlscpp.t<61 -> 66, 5, 1>} : f64
      affine.store %102, %arg1[%arg13 * 16 + %arg12 * 512 + 11] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<553 -> 554, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %103 = arith.mulf %102, %102 {timing = #hlscpp.t<66 -> 70, 4, 1>} : f64
      %104 = arith.addf %98, %103 {timing = #hlscpp.t<70 -> 75, 5, 1>} : f64
      %105 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 12] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<60 -> 62, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %106 = arith.mulf %105, %cst {timing = #hlscpp.t<62 -> 66, 4, 1>} : f64
      %107 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 12] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<64 -> 66, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %108 = arith.subf %107, %106 {timing = #hlscpp.t<66 -> 71, 5, 1>} : f64
      affine.store %108, %arg1[%arg13 * 16 + %arg12 * 512 + 12] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<554 -> 555, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %109 = arith.mulf %108, %108 {timing = #hlscpp.t<71 -> 75, 4, 1>} : f64
      %110 = arith.addf %104, %109 {timing = #hlscpp.t<75 -> 80, 5, 1>} : f64
      %111 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 13] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<65 -> 67, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %112 = arith.mulf %111, %cst {timing = #hlscpp.t<67 -> 71, 4, 1>} : f64
      %113 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 13] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<69 -> 71, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %114 = arith.subf %113, %112 {timing = #hlscpp.t<71 -> 76, 5, 1>} : f64
      affine.store %114, %arg1[%arg13 * 16 + %arg12 * 512 + 13] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<555 -> 556, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %115 = arith.mulf %114, %114 {timing = #hlscpp.t<76 -> 80, 4, 1>} : f64
      %116 = arith.addf %110, %115 {timing = #hlscpp.t<80 -> 85, 5, 1>} : f64
      %117 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 14] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<70 -> 72, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %118 = arith.mulf %117, %cst {timing = #hlscpp.t<72 -> 76, 4, 1>} : f64
      %119 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 14] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<74 -> 76, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %120 = arith.subf %119, %118 {timing = #hlscpp.t<76 -> 81, 5, 1>} : f64
      affine.store %120, %arg1[%arg13 * 16 + %arg12 * 512 + 14] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<556 -> 557, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %121 = arith.mulf %120, %120 {timing = #hlscpp.t<81 -> 85, 4, 1>} : f64
      %122 = arith.addf %116, %121 {timing = #hlscpp.t<85 -> 90, 5, 1>} : f64
      %123 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 15] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<75 -> 77, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %124 = arith.mulf %123, %cst {timing = #hlscpp.t<77 -> 81, 4, 1>} : f64
      %125 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 15] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<79 -> 81, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %126 = arith.subf %125, %124 {timing = #hlscpp.t<81 -> 86, 5, 1>} : f64
      affine.store %126, %arg1[%arg13 * 16 + %arg12 * 512 + 15] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<557 -> 558, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %127 = arith.mulf %126, %126 {timing = #hlscpp.t<86 -> 90, 4, 1>} : f64
      %128 = arith.addf %122, %127 {timing = #hlscpp.t<90 -> 95, 5, 1>} : f64
      affine.store %128, %12[0] {partition_indices = [0], timing = #hlscpp.t<95 -> 96, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      affine.store %128, %13[0] {partition_indices = [0], timing = #hlscpp.t<662 -> 663, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      affine.if affine_set<(d0) : (-(d0 * 16 + 15) + 63 == 0)>(%arg13) {
        affine.store %128, %11[0] {partition_indices = [0], timing = #hlscpp.t<669 -> 670, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      } {timing = #hlscpp.t<669 -> 670, 1, 0>}
      %129 = affine.if affine_set<(d0) : (-(d0 * 16 + 15) + 63 == 0)>(%arg13) -> f64 {
        affine.store %128, %10[0] {partition_indices = [0], timing = #hlscpp.t<96 -> 97, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
        affine.yield {timing = #hlscpp.t<97 -> 97, 0, 0>} %128 : f64
      } else {
        affine.yield {timing = #hlscpp.t<97 -> 97, 0, 0>} %30 : f64
      } {timing = #hlscpp.t<96 -> 97, 1, 0>}
      %130 = affine.load %12[0] {partition_indices = [0], timing = #hlscpp.t<96 -> 97, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      %131 = affine.if affine_set<(d0) : (d0 * 16 == 0)>(%arg13) -> f64 {
        affine.yield {timing = #hlscpp.t<97 -> 97, 0, 0>} %129 : f64
      } else {
        affine.yield {timing = #hlscpp.t<97 -> 97, 0, 0>} %130 : f64
      } {timing = #hlscpp.t<97 -> 97, 0, 0>}
      %132 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 64] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<82 -> 84, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %133 = arith.mulf %132, %cst {timing = #hlscpp.t<84 -> 88, 4, 1>} : f64
      %134 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 64] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<86 -> 88, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %135 = arith.subf %134, %133 {timing = #hlscpp.t<88 -> 93, 5, 1>} : f64
      affine.store %135, %arg1[%arg13 * 16 + %arg12 * 512 + 64] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<558 -> 559, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %136 = arith.mulf %135, %135 {timing = #hlscpp.t<93 -> 97, 4, 1>} : f64
      %137 = arith.addf %131, %136 {timing = #hlscpp.t<97 -> 102, 5, 1>} : f64
      %138 = affine.load %10[0] {partition_indices = [0], timing = #hlscpp.t<177 -> 178, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      %139 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 65] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<87 -> 89, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %140 = arith.mulf %139, %cst {timing = #hlscpp.t<89 -> 93, 4, 1>} : f64
      %141 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 65] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<91 -> 93, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %142 = arith.subf %141, %140 {timing = #hlscpp.t<93 -> 98, 5, 1>} : f64
      affine.store %142, %arg1[%arg13 * 16 + %arg12 * 512 + 65] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<559 -> 560, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %143 = arith.mulf %142, %142 {timing = #hlscpp.t<98 -> 102, 4, 1>} : f64
      %144 = arith.addf %137, %143 {timing = #hlscpp.t<102 -> 107, 5, 1>} : f64
      %145 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 66] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<92 -> 94, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %146 = arith.mulf %145, %cst {timing = #hlscpp.t<94 -> 98, 4, 1>} : f64
      %147 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 66] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<96 -> 98, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %148 = arith.subf %147, %146 {timing = #hlscpp.t<98 -> 103, 5, 1>} : f64
      affine.store %148, %arg1[%arg13 * 16 + %arg12 * 512 + 66] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<560 -> 561, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %149 = arith.mulf %148, %148 {timing = #hlscpp.t<103 -> 107, 4, 1>} : f64
      %150 = arith.addf %144, %149 {timing = #hlscpp.t<107 -> 112, 5, 1>} : f64
      %151 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 67] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<97 -> 99, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %152 = arith.mulf %151, %cst {timing = #hlscpp.t<99 -> 103, 4, 1>} : f64
      %153 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 67] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<101 -> 103, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %154 = arith.subf %153, %152 {timing = #hlscpp.t<103 -> 108, 5, 1>} : f64
      affine.store %154, %arg1[%arg13 * 16 + %arg12 * 512 + 67] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<561 -> 562, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %155 = arith.mulf %154, %154 {timing = #hlscpp.t<108 -> 112, 4, 1>} : f64
      %156 = arith.addf %150, %155 {timing = #hlscpp.t<112 -> 117, 5, 1>} : f64
      %157 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 68] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<102 -> 104, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %158 = arith.mulf %157, %cst {timing = #hlscpp.t<104 -> 108, 4, 1>} : f64
      %159 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 68] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<106 -> 108, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %160 = arith.subf %159, %158 {timing = #hlscpp.t<108 -> 113, 5, 1>} : f64
      affine.store %160, %arg1[%arg13 * 16 + %arg12 * 512 + 68] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<562 -> 563, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %161 = arith.mulf %160, %160 {timing = #hlscpp.t<113 -> 117, 4, 1>} : f64
      %162 = arith.addf %156, %161 {timing = #hlscpp.t<117 -> 122, 5, 1>} : f64
      %163 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 69] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<107 -> 109, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %164 = arith.mulf %163, %cst {timing = #hlscpp.t<109 -> 113, 4, 1>} : f64
      %165 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 69] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<111 -> 113, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %166 = arith.subf %165, %164 {timing = #hlscpp.t<113 -> 118, 5, 1>} : f64
      affine.store %166, %arg1[%arg13 * 16 + %arg12 * 512 + 69] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<563 -> 564, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %167 = arith.mulf %166, %166 {timing = #hlscpp.t<118 -> 122, 4, 1>} : f64
      %168 = arith.addf %162, %167 {timing = #hlscpp.t<122 -> 127, 5, 1>} : f64
      %169 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 70] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<112 -> 114, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %170 = arith.mulf %169, %cst {timing = #hlscpp.t<114 -> 118, 4, 1>} : f64
      %171 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 70] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<116 -> 118, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %172 = arith.subf %171, %170 {timing = #hlscpp.t<118 -> 123, 5, 1>} : f64
      affine.store %172, %arg1[%arg13 * 16 + %arg12 * 512 + 70] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<564 -> 565, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %173 = arith.mulf %172, %172 {timing = #hlscpp.t<123 -> 127, 4, 1>} : f64
      %174 = arith.addf %168, %173 {timing = #hlscpp.t<127 -> 132, 5, 1>} : f64
      %175 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 71] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<117 -> 119, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %176 = arith.mulf %175, %cst {timing = #hlscpp.t<119 -> 123, 4, 1>} : f64
      %177 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 71] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<121 -> 123, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %178 = arith.subf %177, %176 {timing = #hlscpp.t<123 -> 128, 5, 1>} : f64
      affine.store %178, %arg1[%arg13 * 16 + %arg12 * 512 + 71] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<565 -> 566, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %179 = arith.mulf %178, %178 {timing = #hlscpp.t<128 -> 132, 4, 1>} : f64
      %180 = arith.addf %174, %179 {timing = #hlscpp.t<132 -> 137, 5, 1>} : f64
      %181 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 72] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<122 -> 124, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %182 = arith.mulf %181, %cst {timing = #hlscpp.t<124 -> 128, 4, 1>} : f64
      %183 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 72] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<126 -> 128, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %184 = arith.subf %183, %182 {timing = #hlscpp.t<128 -> 133, 5, 1>} : f64
      affine.store %184, %arg1[%arg13 * 16 + %arg12 * 512 + 72] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<566 -> 567, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %185 = arith.mulf %184, %184 {timing = #hlscpp.t<133 -> 137, 4, 1>} : f64
      %186 = arith.addf %180, %185 {timing = #hlscpp.t<137 -> 142, 5, 1>} : f64
      %187 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 73] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<127 -> 129, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %188 = arith.mulf %187, %cst {timing = #hlscpp.t<129 -> 133, 4, 1>} : f64
      %189 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 73] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<131 -> 133, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %190 = arith.subf %189, %188 {timing = #hlscpp.t<133 -> 138, 5, 1>} : f64
      affine.store %190, %arg1[%arg13 * 16 + %arg12 * 512 + 73] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<567 -> 568, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %191 = arith.mulf %190, %190 {timing = #hlscpp.t<138 -> 142, 4, 1>} : f64
      %192 = arith.addf %186, %191 {timing = #hlscpp.t<142 -> 147, 5, 1>} : f64
      %193 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 74] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<132 -> 134, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %194 = arith.mulf %193, %cst {timing = #hlscpp.t<134 -> 138, 4, 1>} : f64
      %195 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 74] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<136 -> 138, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %196 = arith.subf %195, %194 {timing = #hlscpp.t<138 -> 143, 5, 1>} : f64
      affine.store %196, %arg1[%arg13 * 16 + %arg12 * 512 + 74] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<568 -> 569, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %197 = arith.mulf %196, %196 {timing = #hlscpp.t<143 -> 147, 4, 1>} : f64
      %198 = arith.addf %192, %197 {timing = #hlscpp.t<147 -> 152, 5, 1>} : f64
      %199 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 75] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<137 -> 139, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %200 = arith.mulf %199, %cst {timing = #hlscpp.t<139 -> 143, 4, 1>} : f64
      %201 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 75] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<141 -> 143, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %202 = arith.subf %201, %200 {timing = #hlscpp.t<143 -> 148, 5, 1>} : f64
      affine.store %202, %arg1[%arg13 * 16 + %arg12 * 512 + 75] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<569 -> 570, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %203 = arith.mulf %202, %202 {timing = #hlscpp.t<148 -> 152, 4, 1>} : f64
      %204 = arith.addf %198, %203 {timing = #hlscpp.t<152 -> 157, 5, 1>} : f64
      %205 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 76] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<142 -> 144, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %206 = arith.mulf %205, %cst {timing = #hlscpp.t<144 -> 148, 4, 1>} : f64
      %207 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 76] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<146 -> 148, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %208 = arith.subf %207, %206 {timing = #hlscpp.t<148 -> 153, 5, 1>} : f64
      affine.store %208, %arg1[%arg13 * 16 + %arg12 * 512 + 76] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<570 -> 571, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %209 = arith.mulf %208, %208 {timing = #hlscpp.t<153 -> 157, 4, 1>} : f64
      %210 = arith.addf %204, %209 {timing = #hlscpp.t<157 -> 162, 5, 1>} : f64
      %211 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 77] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<147 -> 149, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %212 = arith.mulf %211, %cst {timing = #hlscpp.t<149 -> 153, 4, 1>} : f64
      %213 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 77] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<151 -> 153, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %214 = arith.subf %213, %212 {timing = #hlscpp.t<153 -> 158, 5, 1>} : f64
      affine.store %214, %arg1[%arg13 * 16 + %arg12 * 512 + 77] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<571 -> 572, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %215 = arith.mulf %214, %214 {timing = #hlscpp.t<158 -> 162, 4, 1>} : f64
      %216 = arith.addf %210, %215 {timing = #hlscpp.t<162 -> 167, 5, 1>} : f64
      %217 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 78] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<152 -> 154, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %218 = arith.mulf %217, %cst {timing = #hlscpp.t<154 -> 158, 4, 1>} : f64
      %219 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 78] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<156 -> 158, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %220 = arith.subf %219, %218 {timing = #hlscpp.t<158 -> 163, 5, 1>} : f64
      affine.store %220, %arg1[%arg13 * 16 + %arg12 * 512 + 78] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<572 -> 573, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %221 = arith.mulf %220, %220 {timing = #hlscpp.t<163 -> 167, 4, 1>} : f64
      %222 = arith.addf %216, %221 {timing = #hlscpp.t<167 -> 172, 5, 1>} : f64
      %223 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 79] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<157 -> 159, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %224 = arith.mulf %223, %cst {timing = #hlscpp.t<159 -> 163, 4, 1>} : f64
      %225 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 79] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<161 -> 163, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %226 = arith.subf %225, %224 {timing = #hlscpp.t<163 -> 168, 5, 1>} : f64
      affine.store %226, %arg1[%arg13 * 16 + %arg12 * 512 + 79] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<573 -> 574, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %227 = arith.mulf %226, %226 {timing = #hlscpp.t<168 -> 172, 4, 1>} : f64
      %228 = arith.addf %222, %227 {timing = #hlscpp.t<172 -> 177, 5, 1>} : f64
      affine.store %228, %12[0] {partition_indices = [0], timing = #hlscpp.t<177 -> 178, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      affine.store %228, %13[0] {partition_indices = [0], timing = #hlscpp.t<663 -> 664, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      affine.if affine_set<(d0) : (-(d0 * 16 + 15) + 63 == 0)>(%arg13) {
        affine.store %228, %11[0] {partition_indices = [0], timing = #hlscpp.t<669 -> 670, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      } {timing = #hlscpp.t<669 -> 670, 1, 0>}
      %229 = affine.if affine_set<(d0) : (-(d0 * 16 + 15) + 63 == 0)>(%arg13) -> f64 {
        affine.store %228, %10[0] {partition_indices = [0], timing = #hlscpp.t<178 -> 179, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
        affine.yield {timing = #hlscpp.t<179 -> 179, 0, 0>} %228 : f64
      } else {
        affine.yield {timing = #hlscpp.t<179 -> 179, 0, 0>} %138 : f64
      } {timing = #hlscpp.t<178 -> 179, 1, 0>}
      %230 = affine.load %12[0] {partition_indices = [0], timing = #hlscpp.t<178 -> 179, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      %231 = affine.if affine_set<(d0) : (d0 * 16 == 0)>(%arg13) -> f64 {
        affine.yield {timing = #hlscpp.t<179 -> 179, 0, 0>} %229 : f64
      } else {
        affine.yield {timing = #hlscpp.t<179 -> 179, 0, 0>} %230 : f64
      } {timing = #hlscpp.t<179 -> 179, 0, 0>}
      %232 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 128] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<164 -> 166, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %233 = arith.mulf %232, %cst {timing = #hlscpp.t<166 -> 170, 4, 1>} : f64
      %234 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 128] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<168 -> 170, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %235 = arith.subf %234, %233 {timing = #hlscpp.t<170 -> 175, 5, 1>} : f64
      affine.store %235, %arg1[%arg13 * 16 + %arg12 * 512 + 128] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<574 -> 575, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %236 = arith.mulf %235, %235 {timing = #hlscpp.t<175 -> 179, 4, 1>} : f64
      %237 = arith.addf %231, %236 {timing = #hlscpp.t<179 -> 184, 5, 1>} : f64
      %238 = affine.load %10[0] {partition_indices = [0], timing = #hlscpp.t<259 -> 260, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      %239 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 129] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<169 -> 171, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %240 = arith.mulf %239, %cst {timing = #hlscpp.t<171 -> 175, 4, 1>} : f64
      %241 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 129] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<173 -> 175, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %242 = arith.subf %241, %240 {timing = #hlscpp.t<175 -> 180, 5, 1>} : f64
      affine.store %242, %arg1[%arg13 * 16 + %arg12 * 512 + 129] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<575 -> 576, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %243 = arith.mulf %242, %242 {timing = #hlscpp.t<180 -> 184, 4, 1>} : f64
      %244 = arith.addf %237, %243 {timing = #hlscpp.t<184 -> 189, 5, 1>} : f64
      %245 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 130] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<174 -> 176, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %246 = arith.mulf %245, %cst {timing = #hlscpp.t<176 -> 180, 4, 1>} : f64
      %247 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 130] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<178 -> 180, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %248 = arith.subf %247, %246 {timing = #hlscpp.t<180 -> 185, 5, 1>} : f64
      affine.store %248, %arg1[%arg13 * 16 + %arg12 * 512 + 130] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<576 -> 577, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %249 = arith.mulf %248, %248 {timing = #hlscpp.t<185 -> 189, 4, 1>} : f64
      %250 = arith.addf %244, %249 {timing = #hlscpp.t<189 -> 194, 5, 1>} : f64
      %251 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 131] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<179 -> 181, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %252 = arith.mulf %251, %cst {timing = #hlscpp.t<181 -> 185, 4, 1>} : f64
      %253 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 131] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<183 -> 185, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %254 = arith.subf %253, %252 {timing = #hlscpp.t<185 -> 190, 5, 1>} : f64
      affine.store %254, %arg1[%arg13 * 16 + %arg12 * 512 + 131] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<577 -> 578, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %255 = arith.mulf %254, %254 {timing = #hlscpp.t<190 -> 194, 4, 1>} : f64
      %256 = arith.addf %250, %255 {timing = #hlscpp.t<194 -> 199, 5, 1>} : f64
      %257 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 132] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<184 -> 186, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %258 = arith.mulf %257, %cst {timing = #hlscpp.t<186 -> 190, 4, 1>} : f64
      %259 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 132] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<188 -> 190, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %260 = arith.subf %259, %258 {timing = #hlscpp.t<190 -> 195, 5, 1>} : f64
      affine.store %260, %arg1[%arg13 * 16 + %arg12 * 512 + 132] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<578 -> 579, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %261 = arith.mulf %260, %260 {timing = #hlscpp.t<195 -> 199, 4, 1>} : f64
      %262 = arith.addf %256, %261 {timing = #hlscpp.t<199 -> 204, 5, 1>} : f64
      %263 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 133] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<189 -> 191, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %264 = arith.mulf %263, %cst {timing = #hlscpp.t<191 -> 195, 4, 1>} : f64
      %265 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 133] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<193 -> 195, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %266 = arith.subf %265, %264 {timing = #hlscpp.t<195 -> 200, 5, 1>} : f64
      affine.store %266, %arg1[%arg13 * 16 + %arg12 * 512 + 133] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<579 -> 580, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %267 = arith.mulf %266, %266 {timing = #hlscpp.t<200 -> 204, 4, 1>} : f64
      %268 = arith.addf %262, %267 {timing = #hlscpp.t<204 -> 209, 5, 1>} : f64
      %269 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 134] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<194 -> 196, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %270 = arith.mulf %269, %cst {timing = #hlscpp.t<196 -> 200, 4, 1>} : f64
      %271 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 134] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<198 -> 200, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %272 = arith.subf %271, %270 {timing = #hlscpp.t<200 -> 205, 5, 1>} : f64
      affine.store %272, %arg1[%arg13 * 16 + %arg12 * 512 + 134] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<580 -> 581, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %273 = arith.mulf %272, %272 {timing = #hlscpp.t<205 -> 209, 4, 1>} : f64
      %274 = arith.addf %268, %273 {timing = #hlscpp.t<209 -> 214, 5, 1>} : f64
      %275 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 135] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<199 -> 201, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %276 = arith.mulf %275, %cst {timing = #hlscpp.t<201 -> 205, 4, 1>} : f64
      %277 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 135] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<203 -> 205, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %278 = arith.subf %277, %276 {timing = #hlscpp.t<205 -> 210, 5, 1>} : f64
      affine.store %278, %arg1[%arg13 * 16 + %arg12 * 512 + 135] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<581 -> 582, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %279 = arith.mulf %278, %278 {timing = #hlscpp.t<210 -> 214, 4, 1>} : f64
      %280 = arith.addf %274, %279 {timing = #hlscpp.t<214 -> 219, 5, 1>} : f64
      %281 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 136] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<204 -> 206, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %282 = arith.mulf %281, %cst {timing = #hlscpp.t<206 -> 210, 4, 1>} : f64
      %283 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 136] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<208 -> 210, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %284 = arith.subf %283, %282 {timing = #hlscpp.t<210 -> 215, 5, 1>} : f64
      affine.store %284, %arg1[%arg13 * 16 + %arg12 * 512 + 136] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<582 -> 583, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %285 = arith.mulf %284, %284 {timing = #hlscpp.t<215 -> 219, 4, 1>} : f64
      %286 = arith.addf %280, %285 {timing = #hlscpp.t<219 -> 224, 5, 1>} : f64
      %287 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 137] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<209 -> 211, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %288 = arith.mulf %287, %cst {timing = #hlscpp.t<211 -> 215, 4, 1>} : f64
      %289 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 137] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<213 -> 215, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %290 = arith.subf %289, %288 {timing = #hlscpp.t<215 -> 220, 5, 1>} : f64
      affine.store %290, %arg1[%arg13 * 16 + %arg12 * 512 + 137] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<583 -> 584, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %291 = arith.mulf %290, %290 {timing = #hlscpp.t<220 -> 224, 4, 1>} : f64
      %292 = arith.addf %286, %291 {timing = #hlscpp.t<224 -> 229, 5, 1>} : f64
      %293 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 138] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<214 -> 216, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %294 = arith.mulf %293, %cst {timing = #hlscpp.t<216 -> 220, 4, 1>} : f64
      %295 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 138] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<218 -> 220, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %296 = arith.subf %295, %294 {timing = #hlscpp.t<220 -> 225, 5, 1>} : f64
      affine.store %296, %arg1[%arg13 * 16 + %arg12 * 512 + 138] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<584 -> 585, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %297 = arith.mulf %296, %296 {timing = #hlscpp.t<225 -> 229, 4, 1>} : f64
      %298 = arith.addf %292, %297 {timing = #hlscpp.t<229 -> 234, 5, 1>} : f64
      %299 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 139] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<219 -> 221, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %300 = arith.mulf %299, %cst {timing = #hlscpp.t<221 -> 225, 4, 1>} : f64
      %301 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 139] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<223 -> 225, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %302 = arith.subf %301, %300 {timing = #hlscpp.t<225 -> 230, 5, 1>} : f64
      affine.store %302, %arg1[%arg13 * 16 + %arg12 * 512 + 139] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<585 -> 586, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %303 = arith.mulf %302, %302 {timing = #hlscpp.t<230 -> 234, 4, 1>} : f64
      %304 = arith.addf %298, %303 {timing = #hlscpp.t<234 -> 239, 5, 1>} : f64
      %305 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 140] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<224 -> 226, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %306 = arith.mulf %305, %cst {timing = #hlscpp.t<226 -> 230, 4, 1>} : f64
      %307 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 140] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<228 -> 230, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %308 = arith.subf %307, %306 {timing = #hlscpp.t<230 -> 235, 5, 1>} : f64
      affine.store %308, %arg1[%arg13 * 16 + %arg12 * 512 + 140] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<586 -> 587, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %309 = arith.mulf %308, %308 {timing = #hlscpp.t<235 -> 239, 4, 1>} : f64
      %310 = arith.addf %304, %309 {timing = #hlscpp.t<239 -> 244, 5, 1>} : f64
      %311 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 141] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<229 -> 231, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %312 = arith.mulf %311, %cst {timing = #hlscpp.t<231 -> 235, 4, 1>} : f64
      %313 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 141] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<233 -> 235, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %314 = arith.subf %313, %312 {timing = #hlscpp.t<235 -> 240, 5, 1>} : f64
      affine.store %314, %arg1[%arg13 * 16 + %arg12 * 512 + 141] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<587 -> 588, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %315 = arith.mulf %314, %314 {timing = #hlscpp.t<240 -> 244, 4, 1>} : f64
      %316 = arith.addf %310, %315 {timing = #hlscpp.t<244 -> 249, 5, 1>} : f64
      %317 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 142] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<234 -> 236, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %318 = arith.mulf %317, %cst {timing = #hlscpp.t<236 -> 240, 4, 1>} : f64
      %319 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 142] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<238 -> 240, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %320 = arith.subf %319, %318 {timing = #hlscpp.t<240 -> 245, 5, 1>} : f64
      affine.store %320, %arg1[%arg13 * 16 + %arg12 * 512 + 142] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<588 -> 589, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %321 = arith.mulf %320, %320 {timing = #hlscpp.t<245 -> 249, 4, 1>} : f64
      %322 = arith.addf %316, %321 {timing = #hlscpp.t<249 -> 254, 5, 1>} : f64
      %323 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 143] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<239 -> 241, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %324 = arith.mulf %323, %cst {timing = #hlscpp.t<241 -> 245, 4, 1>} : f64
      %325 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 143] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<243 -> 245, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %326 = arith.subf %325, %324 {timing = #hlscpp.t<245 -> 250, 5, 1>} : f64
      affine.store %326, %arg1[%arg13 * 16 + %arg12 * 512 + 143] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<589 -> 590, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %327 = arith.mulf %326, %326 {timing = #hlscpp.t<250 -> 254, 4, 1>} : f64
      %328 = arith.addf %322, %327 {timing = #hlscpp.t<254 -> 259, 5, 1>} : f64
      affine.store %328, %12[0] {partition_indices = [0], timing = #hlscpp.t<259 -> 260, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      affine.store %328, %13[0] {partition_indices = [0], timing = #hlscpp.t<664 -> 665, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      affine.if affine_set<(d0) : (-(d0 * 16 + 15) + 63 == 0)>(%arg13) {
        affine.store %328, %11[0] {partition_indices = [0], timing = #hlscpp.t<669 -> 670, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      } {timing = #hlscpp.t<669 -> 670, 1, 0>}
      %329 = affine.if affine_set<(d0) : (-(d0 * 16 + 15) + 63 == 0)>(%arg13) -> f64 {
        affine.store %328, %10[0] {partition_indices = [0], timing = #hlscpp.t<260 -> 261, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
        affine.yield {timing = #hlscpp.t<261 -> 261, 0, 0>} %328 : f64
      } else {
        affine.yield {timing = #hlscpp.t<261 -> 261, 0, 0>} %238 : f64
      } {timing = #hlscpp.t<260 -> 261, 1, 0>}
      %330 = affine.load %12[0] {partition_indices = [0], timing = #hlscpp.t<260 -> 261, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      %331 = affine.if affine_set<(d0) : (d0 * 16 == 0)>(%arg13) -> f64 {
        affine.yield {timing = #hlscpp.t<261 -> 261, 0, 0>} %329 : f64
      } else {
        affine.yield {timing = #hlscpp.t<261 -> 261, 0, 0>} %330 : f64
      } {timing = #hlscpp.t<261 -> 261, 0, 0>}
      %332 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 192] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<246 -> 248, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %333 = arith.mulf %332, %cst {timing = #hlscpp.t<248 -> 252, 4, 1>} : f64
      %334 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 192] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<250 -> 252, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %335 = arith.subf %334, %333 {timing = #hlscpp.t<252 -> 257, 5, 1>} : f64
      affine.store %335, %arg1[%arg13 * 16 + %arg12 * 512 + 192] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<590 -> 591, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %336 = arith.mulf %335, %335 {timing = #hlscpp.t<257 -> 261, 4, 1>} : f64
      %337 = arith.addf %331, %336 {timing = #hlscpp.t<261 -> 266, 5, 1>} : f64
      %338 = affine.load %10[0] {partition_indices = [0], timing = #hlscpp.t<341 -> 342, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      %339 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 193] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<251 -> 253, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %340 = arith.mulf %339, %cst {timing = #hlscpp.t<253 -> 257, 4, 1>} : f64
      %341 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 193] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<255 -> 257, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %342 = arith.subf %341, %340 {timing = #hlscpp.t<257 -> 262, 5, 1>} : f64
      affine.store %342, %arg1[%arg13 * 16 + %arg12 * 512 + 193] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<591 -> 592, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %343 = arith.mulf %342, %342 {timing = #hlscpp.t<262 -> 266, 4, 1>} : f64
      %344 = arith.addf %337, %343 {timing = #hlscpp.t<266 -> 271, 5, 1>} : f64
      %345 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 194] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<256 -> 258, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %346 = arith.mulf %345, %cst {timing = #hlscpp.t<258 -> 262, 4, 1>} : f64
      %347 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 194] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<260 -> 262, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %348 = arith.subf %347, %346 {timing = #hlscpp.t<262 -> 267, 5, 1>} : f64
      affine.store %348, %arg1[%arg13 * 16 + %arg12 * 512 + 194] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<592 -> 593, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %349 = arith.mulf %348, %348 {timing = #hlscpp.t<267 -> 271, 4, 1>} : f64
      %350 = arith.addf %344, %349 {timing = #hlscpp.t<271 -> 276, 5, 1>} : f64
      %351 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 195] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<261 -> 263, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %352 = arith.mulf %351, %cst {timing = #hlscpp.t<263 -> 267, 4, 1>} : f64
      %353 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 195] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<265 -> 267, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %354 = arith.subf %353, %352 {timing = #hlscpp.t<267 -> 272, 5, 1>} : f64
      affine.store %354, %arg1[%arg13 * 16 + %arg12 * 512 + 195] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<593 -> 594, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %355 = arith.mulf %354, %354 {timing = #hlscpp.t<272 -> 276, 4, 1>} : f64
      %356 = arith.addf %350, %355 {timing = #hlscpp.t<276 -> 281, 5, 1>} : f64
      %357 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 196] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<266 -> 268, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %358 = arith.mulf %357, %cst {timing = #hlscpp.t<268 -> 272, 4, 1>} : f64
      %359 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 196] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<270 -> 272, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %360 = arith.subf %359, %358 {timing = #hlscpp.t<272 -> 277, 5, 1>} : f64
      affine.store %360, %arg1[%arg13 * 16 + %arg12 * 512 + 196] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<594 -> 595, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %361 = arith.mulf %360, %360 {timing = #hlscpp.t<277 -> 281, 4, 1>} : f64
      %362 = arith.addf %356, %361 {timing = #hlscpp.t<281 -> 286, 5, 1>} : f64
      %363 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 197] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<271 -> 273, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %364 = arith.mulf %363, %cst {timing = #hlscpp.t<273 -> 277, 4, 1>} : f64
      %365 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 197] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<275 -> 277, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %366 = arith.subf %365, %364 {timing = #hlscpp.t<277 -> 282, 5, 1>} : f64
      affine.store %366, %arg1[%arg13 * 16 + %arg12 * 512 + 197] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<595 -> 596, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %367 = arith.mulf %366, %366 {timing = #hlscpp.t<282 -> 286, 4, 1>} : f64
      %368 = arith.addf %362, %367 {timing = #hlscpp.t<286 -> 291, 5, 1>} : f64
      %369 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 198] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<276 -> 278, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %370 = arith.mulf %369, %cst {timing = #hlscpp.t<278 -> 282, 4, 1>} : f64
      %371 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 198] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<280 -> 282, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %372 = arith.subf %371, %370 {timing = #hlscpp.t<282 -> 287, 5, 1>} : f64
      affine.store %372, %arg1[%arg13 * 16 + %arg12 * 512 + 198] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<596 -> 597, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %373 = arith.mulf %372, %372 {timing = #hlscpp.t<287 -> 291, 4, 1>} : f64
      %374 = arith.addf %368, %373 {timing = #hlscpp.t<291 -> 296, 5, 1>} : f64
      %375 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 199] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<281 -> 283, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %376 = arith.mulf %375, %cst {timing = #hlscpp.t<283 -> 287, 4, 1>} : f64
      %377 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 199] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<285 -> 287, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %378 = arith.subf %377, %376 {timing = #hlscpp.t<287 -> 292, 5, 1>} : f64
      affine.store %378, %arg1[%arg13 * 16 + %arg12 * 512 + 199] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<597 -> 598, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %379 = arith.mulf %378, %378 {timing = #hlscpp.t<292 -> 296, 4, 1>} : f64
      %380 = arith.addf %374, %379 {timing = #hlscpp.t<296 -> 301, 5, 1>} : f64
      %381 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 200] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<286 -> 288, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %382 = arith.mulf %381, %cst {timing = #hlscpp.t<288 -> 292, 4, 1>} : f64
      %383 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 200] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<290 -> 292, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %384 = arith.subf %383, %382 {timing = #hlscpp.t<292 -> 297, 5, 1>} : f64
      affine.store %384, %arg1[%arg13 * 16 + %arg12 * 512 + 200] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<598 -> 599, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %385 = arith.mulf %384, %384 {timing = #hlscpp.t<297 -> 301, 4, 1>} : f64
      %386 = arith.addf %380, %385 {timing = #hlscpp.t<301 -> 306, 5, 1>} : f64
      %387 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 201] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<291 -> 293, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %388 = arith.mulf %387, %cst {timing = #hlscpp.t<293 -> 297, 4, 1>} : f64
      %389 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 201] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<295 -> 297, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %390 = arith.subf %389, %388 {timing = #hlscpp.t<297 -> 302, 5, 1>} : f64
      affine.store %390, %arg1[%arg13 * 16 + %arg12 * 512 + 201] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<599 -> 600, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %391 = arith.mulf %390, %390 {timing = #hlscpp.t<302 -> 306, 4, 1>} : f64
      %392 = arith.addf %386, %391 {timing = #hlscpp.t<306 -> 311, 5, 1>} : f64
      %393 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 202] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<296 -> 298, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %394 = arith.mulf %393, %cst {timing = #hlscpp.t<298 -> 302, 4, 1>} : f64
      %395 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 202] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<300 -> 302, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %396 = arith.subf %395, %394 {timing = #hlscpp.t<302 -> 307, 5, 1>} : f64
      affine.store %396, %arg1[%arg13 * 16 + %arg12 * 512 + 202] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<600 -> 601, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %397 = arith.mulf %396, %396 {timing = #hlscpp.t<307 -> 311, 4, 1>} : f64
      %398 = arith.addf %392, %397 {timing = #hlscpp.t<311 -> 316, 5, 1>} : f64
      %399 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 203] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<301 -> 303, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %400 = arith.mulf %399, %cst {timing = #hlscpp.t<303 -> 307, 4, 1>} : f64
      %401 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 203] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<305 -> 307, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %402 = arith.subf %401, %400 {timing = #hlscpp.t<307 -> 312, 5, 1>} : f64
      affine.store %402, %arg1[%arg13 * 16 + %arg12 * 512 + 203] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<601 -> 602, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %403 = arith.mulf %402, %402 {timing = #hlscpp.t<312 -> 316, 4, 1>} : f64
      %404 = arith.addf %398, %403 {timing = #hlscpp.t<316 -> 321, 5, 1>} : f64
      %405 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 204] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<306 -> 308, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %406 = arith.mulf %405, %cst {timing = #hlscpp.t<308 -> 312, 4, 1>} : f64
      %407 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 204] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<310 -> 312, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %408 = arith.subf %407, %406 {timing = #hlscpp.t<312 -> 317, 5, 1>} : f64
      affine.store %408, %arg1[%arg13 * 16 + %arg12 * 512 + 204] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<602 -> 603, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %409 = arith.mulf %408, %408 {timing = #hlscpp.t<317 -> 321, 4, 1>} : f64
      %410 = arith.addf %404, %409 {timing = #hlscpp.t<321 -> 326, 5, 1>} : f64
      %411 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 205] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<311 -> 313, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %412 = arith.mulf %411, %cst {timing = #hlscpp.t<313 -> 317, 4, 1>} : f64
      %413 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 205] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<315 -> 317, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %414 = arith.subf %413, %412 {timing = #hlscpp.t<317 -> 322, 5, 1>} : f64
      affine.store %414, %arg1[%arg13 * 16 + %arg12 * 512 + 205] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<603 -> 604, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %415 = arith.mulf %414, %414 {timing = #hlscpp.t<322 -> 326, 4, 1>} : f64
      %416 = arith.addf %410, %415 {timing = #hlscpp.t<326 -> 331, 5, 1>} : f64
      %417 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 206] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<316 -> 318, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %418 = arith.mulf %417, %cst {timing = #hlscpp.t<318 -> 322, 4, 1>} : f64
      %419 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 206] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<320 -> 322, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %420 = arith.subf %419, %418 {timing = #hlscpp.t<322 -> 327, 5, 1>} : f64
      affine.store %420, %arg1[%arg13 * 16 + %arg12 * 512 + 206] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<604 -> 605, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %421 = arith.mulf %420, %420 {timing = #hlscpp.t<327 -> 331, 4, 1>} : f64
      %422 = arith.addf %416, %421 {timing = #hlscpp.t<331 -> 336, 5, 1>} : f64
      %423 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 207] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<321 -> 323, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %424 = arith.mulf %423, %cst {timing = #hlscpp.t<323 -> 327, 4, 1>} : f64
      %425 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 207] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<325 -> 327, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %426 = arith.subf %425, %424 {timing = #hlscpp.t<327 -> 332, 5, 1>} : f64
      affine.store %426, %arg1[%arg13 * 16 + %arg12 * 512 + 207] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<605 -> 606, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %427 = arith.mulf %426, %426 {timing = #hlscpp.t<332 -> 336, 4, 1>} : f64
      %428 = arith.addf %422, %427 {timing = #hlscpp.t<336 -> 341, 5, 1>} : f64
      affine.store %428, %12[0] {partition_indices = [0], timing = #hlscpp.t<341 -> 342, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      affine.store %428, %13[0] {partition_indices = [0], timing = #hlscpp.t<665 -> 666, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      affine.if affine_set<(d0) : (-(d0 * 16 + 15) + 63 == 0)>(%arg13) {
        affine.store %428, %11[0] {partition_indices = [0], timing = #hlscpp.t<669 -> 670, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      } {timing = #hlscpp.t<669 -> 670, 1, 0>}
      %429 = affine.if affine_set<(d0) : (-(d0 * 16 + 15) + 63 == 0)>(%arg13) -> f64 {
        affine.store %428, %10[0] {partition_indices = [0], timing = #hlscpp.t<342 -> 343, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
        affine.yield {timing = #hlscpp.t<343 -> 343, 0, 0>} %428 : f64
      } else {
        affine.yield {timing = #hlscpp.t<343 -> 343, 0, 0>} %338 : f64
      } {timing = #hlscpp.t<342 -> 343, 1, 0>}
      %430 = affine.load %12[0] {partition_indices = [0], timing = #hlscpp.t<342 -> 343, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      %431 = affine.if affine_set<(d0) : (d0 * 16 == 0)>(%arg13) -> f64 {
        affine.yield {timing = #hlscpp.t<343 -> 343, 0, 0>} %429 : f64
      } else {
        affine.yield {timing = #hlscpp.t<343 -> 343, 0, 0>} %430 : f64
      } {timing = #hlscpp.t<343 -> 343, 0, 0>}
      %432 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 256] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<328 -> 330, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %433 = arith.mulf %432, %cst {timing = #hlscpp.t<330 -> 334, 4, 1>} : f64
      %434 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 256] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<332 -> 334, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %435 = arith.subf %434, %433 {timing = #hlscpp.t<334 -> 339, 5, 1>} : f64
      affine.store %435, %arg1[%arg13 * 16 + %arg12 * 512 + 256] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<606 -> 607, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %436 = arith.mulf %435, %435 {timing = #hlscpp.t<339 -> 343, 4, 1>} : f64
      %437 = arith.addf %431, %436 {timing = #hlscpp.t<343 -> 348, 5, 1>} : f64
      %438 = affine.load %10[0] {partition_indices = [0], timing = #hlscpp.t<423 -> 424, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      %439 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 257] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<333 -> 335, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %440 = arith.mulf %439, %cst {timing = #hlscpp.t<335 -> 339, 4, 1>} : f64
      %441 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 257] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<337 -> 339, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %442 = arith.subf %441, %440 {timing = #hlscpp.t<339 -> 344, 5, 1>} : f64
      affine.store %442, %arg1[%arg13 * 16 + %arg12 * 512 + 257] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<607 -> 608, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %443 = arith.mulf %442, %442 {timing = #hlscpp.t<344 -> 348, 4, 1>} : f64
      %444 = arith.addf %437, %443 {timing = #hlscpp.t<348 -> 353, 5, 1>} : f64
      %445 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 258] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<338 -> 340, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %446 = arith.mulf %445, %cst {timing = #hlscpp.t<340 -> 344, 4, 1>} : f64
      %447 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 258] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<342 -> 344, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %448 = arith.subf %447, %446 {timing = #hlscpp.t<344 -> 349, 5, 1>} : f64
      affine.store %448, %arg1[%arg13 * 16 + %arg12 * 512 + 258] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<608 -> 609, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %449 = arith.mulf %448, %448 {timing = #hlscpp.t<349 -> 353, 4, 1>} : f64
      %450 = arith.addf %444, %449 {timing = #hlscpp.t<353 -> 358, 5, 1>} : f64
      %451 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 259] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<343 -> 345, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %452 = arith.mulf %451, %cst {timing = #hlscpp.t<345 -> 349, 4, 1>} : f64
      %453 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 259] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<347 -> 349, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %454 = arith.subf %453, %452 {timing = #hlscpp.t<349 -> 354, 5, 1>} : f64
      affine.store %454, %arg1[%arg13 * 16 + %arg12 * 512 + 259] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<609 -> 610, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %455 = arith.mulf %454, %454 {timing = #hlscpp.t<354 -> 358, 4, 1>} : f64
      %456 = arith.addf %450, %455 {timing = #hlscpp.t<358 -> 363, 5, 1>} : f64
      %457 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 260] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<348 -> 350, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %458 = arith.mulf %457, %cst {timing = #hlscpp.t<350 -> 354, 4, 1>} : f64
      %459 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 260] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<352 -> 354, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %460 = arith.subf %459, %458 {timing = #hlscpp.t<354 -> 359, 5, 1>} : f64
      affine.store %460, %arg1[%arg13 * 16 + %arg12 * 512 + 260] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<610 -> 611, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %461 = arith.mulf %460, %460 {timing = #hlscpp.t<359 -> 363, 4, 1>} : f64
      %462 = arith.addf %456, %461 {timing = #hlscpp.t<363 -> 368, 5, 1>} : f64
      %463 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 261] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<353 -> 355, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %464 = arith.mulf %463, %cst {timing = #hlscpp.t<355 -> 359, 4, 1>} : f64
      %465 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 261] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<357 -> 359, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %466 = arith.subf %465, %464 {timing = #hlscpp.t<359 -> 364, 5, 1>} : f64
      affine.store %466, %arg1[%arg13 * 16 + %arg12 * 512 + 261] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<611 -> 612, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %467 = arith.mulf %466, %466 {timing = #hlscpp.t<364 -> 368, 4, 1>} : f64
      %468 = arith.addf %462, %467 {timing = #hlscpp.t<368 -> 373, 5, 1>} : f64
      %469 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 262] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<358 -> 360, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %470 = arith.mulf %469, %cst {timing = #hlscpp.t<360 -> 364, 4, 1>} : f64
      %471 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 262] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<362 -> 364, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %472 = arith.subf %471, %470 {timing = #hlscpp.t<364 -> 369, 5, 1>} : f64
      affine.store %472, %arg1[%arg13 * 16 + %arg12 * 512 + 262] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<612 -> 613, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %473 = arith.mulf %472, %472 {timing = #hlscpp.t<369 -> 373, 4, 1>} : f64
      %474 = arith.addf %468, %473 {timing = #hlscpp.t<373 -> 378, 5, 1>} : f64
      %475 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 263] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<363 -> 365, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %476 = arith.mulf %475, %cst {timing = #hlscpp.t<365 -> 369, 4, 1>} : f64
      %477 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 263] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<367 -> 369, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %478 = arith.subf %477, %476 {timing = #hlscpp.t<369 -> 374, 5, 1>} : f64
      affine.store %478, %arg1[%arg13 * 16 + %arg12 * 512 + 263] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<613 -> 614, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %479 = arith.mulf %478, %478 {timing = #hlscpp.t<374 -> 378, 4, 1>} : f64
      %480 = arith.addf %474, %479 {timing = #hlscpp.t<378 -> 383, 5, 1>} : f64
      %481 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 264] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<368 -> 370, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %482 = arith.mulf %481, %cst {timing = #hlscpp.t<370 -> 374, 4, 1>} : f64
      %483 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 264] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<372 -> 374, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %484 = arith.subf %483, %482 {timing = #hlscpp.t<374 -> 379, 5, 1>} : f64
      affine.store %484, %arg1[%arg13 * 16 + %arg12 * 512 + 264] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<614 -> 615, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %485 = arith.mulf %484, %484 {timing = #hlscpp.t<379 -> 383, 4, 1>} : f64
      %486 = arith.addf %480, %485 {timing = #hlscpp.t<383 -> 388, 5, 1>} : f64
      %487 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 265] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<373 -> 375, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %488 = arith.mulf %487, %cst {timing = #hlscpp.t<375 -> 379, 4, 1>} : f64
      %489 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 265] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<377 -> 379, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %490 = arith.subf %489, %488 {timing = #hlscpp.t<379 -> 384, 5, 1>} : f64
      affine.store %490, %arg1[%arg13 * 16 + %arg12 * 512 + 265] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<615 -> 616, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %491 = arith.mulf %490, %490 {timing = #hlscpp.t<384 -> 388, 4, 1>} : f64
      %492 = arith.addf %486, %491 {timing = #hlscpp.t<388 -> 393, 5, 1>} : f64
      %493 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 266] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<378 -> 380, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %494 = arith.mulf %493, %cst {timing = #hlscpp.t<380 -> 384, 4, 1>} : f64
      %495 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 266] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<382 -> 384, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %496 = arith.subf %495, %494 {timing = #hlscpp.t<384 -> 389, 5, 1>} : f64
      affine.store %496, %arg1[%arg13 * 16 + %arg12 * 512 + 266] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<616 -> 617, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %497 = arith.mulf %496, %496 {timing = #hlscpp.t<389 -> 393, 4, 1>} : f64
      %498 = arith.addf %492, %497 {timing = #hlscpp.t<393 -> 398, 5, 1>} : f64
      %499 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 267] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<383 -> 385, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %500 = arith.mulf %499, %cst {timing = #hlscpp.t<385 -> 389, 4, 1>} : f64
      %501 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 267] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<387 -> 389, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %502 = arith.subf %501, %500 {timing = #hlscpp.t<389 -> 394, 5, 1>} : f64
      affine.store %502, %arg1[%arg13 * 16 + %arg12 * 512 + 267] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<617 -> 618, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %503 = arith.mulf %502, %502 {timing = #hlscpp.t<394 -> 398, 4, 1>} : f64
      %504 = arith.addf %498, %503 {timing = #hlscpp.t<398 -> 403, 5, 1>} : f64
      %505 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 268] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<388 -> 390, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %506 = arith.mulf %505, %cst {timing = #hlscpp.t<390 -> 394, 4, 1>} : f64
      %507 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 268] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<392 -> 394, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %508 = arith.subf %507, %506 {timing = #hlscpp.t<394 -> 399, 5, 1>} : f64
      affine.store %508, %arg1[%arg13 * 16 + %arg12 * 512 + 268] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<618 -> 619, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %509 = arith.mulf %508, %508 {timing = #hlscpp.t<399 -> 403, 4, 1>} : f64
      %510 = arith.addf %504, %509 {timing = #hlscpp.t<403 -> 408, 5, 1>} : f64
      %511 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 269] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<393 -> 395, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %512 = arith.mulf %511, %cst {timing = #hlscpp.t<395 -> 399, 4, 1>} : f64
      %513 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 269] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<397 -> 399, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %514 = arith.subf %513, %512 {timing = #hlscpp.t<399 -> 404, 5, 1>} : f64
      affine.store %514, %arg1[%arg13 * 16 + %arg12 * 512 + 269] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<619 -> 620, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %515 = arith.mulf %514, %514 {timing = #hlscpp.t<404 -> 408, 4, 1>} : f64
      %516 = arith.addf %510, %515 {timing = #hlscpp.t<408 -> 413, 5, 1>} : f64
      %517 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 270] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<398 -> 400, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %518 = arith.mulf %517, %cst {timing = #hlscpp.t<400 -> 404, 4, 1>} : f64
      %519 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 270] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<402 -> 404, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %520 = arith.subf %519, %518 {timing = #hlscpp.t<404 -> 409, 5, 1>} : f64
      affine.store %520, %arg1[%arg13 * 16 + %arg12 * 512 + 270] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<620 -> 621, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %521 = arith.mulf %520, %520 {timing = #hlscpp.t<409 -> 413, 4, 1>} : f64
      %522 = arith.addf %516, %521 {timing = #hlscpp.t<413 -> 418, 5, 1>} : f64
      %523 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 271] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<403 -> 405, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %524 = arith.mulf %523, %cst {timing = #hlscpp.t<405 -> 409, 4, 1>} : f64
      %525 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 271] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<407 -> 409, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %526 = arith.subf %525, %524 {timing = #hlscpp.t<409 -> 414, 5, 1>} : f64
      affine.store %526, %arg1[%arg13 * 16 + %arg12 * 512 + 271] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<621 -> 622, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %527 = arith.mulf %526, %526 {timing = #hlscpp.t<414 -> 418, 4, 1>} : f64
      %528 = arith.addf %522, %527 {timing = #hlscpp.t<418 -> 423, 5, 1>} : f64
      affine.store %528, %12[0] {partition_indices = [0], timing = #hlscpp.t<423 -> 424, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      affine.store %528, %13[0] {partition_indices = [0], timing = #hlscpp.t<666 -> 667, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      affine.if affine_set<(d0) : (-(d0 * 16 + 15) + 63 == 0)>(%arg13) {
        affine.store %528, %11[0] {partition_indices = [0], timing = #hlscpp.t<669 -> 670, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      } {timing = #hlscpp.t<669 -> 670, 1, 0>}
      %529 = affine.if affine_set<(d0) : (-(d0 * 16 + 15) + 63 == 0)>(%arg13) -> f64 {
        affine.store %528, %10[0] {partition_indices = [0], timing = #hlscpp.t<424 -> 425, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
        affine.yield {timing = #hlscpp.t<425 -> 425, 0, 0>} %528 : f64
      } else {
        affine.yield {timing = #hlscpp.t<425 -> 425, 0, 0>} %438 : f64
      } {timing = #hlscpp.t<424 -> 425, 1, 0>}
      %530 = affine.load %12[0] {partition_indices = [0], timing = #hlscpp.t<424 -> 425, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      %531 = affine.if affine_set<(d0) : (d0 * 16 == 0)>(%arg13) -> f64 {
        affine.yield {timing = #hlscpp.t<425 -> 425, 0, 0>} %529 : f64
      } else {
        affine.yield {timing = #hlscpp.t<425 -> 425, 0, 0>} %530 : f64
      } {timing = #hlscpp.t<425 -> 425, 0, 0>}
      %532 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 320] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<410 -> 412, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %533 = arith.mulf %532, %cst {timing = #hlscpp.t<412 -> 416, 4, 1>} : f64
      %534 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 320] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<414 -> 416, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %535 = arith.subf %534, %533 {timing = #hlscpp.t<416 -> 421, 5, 1>} : f64
      affine.store %535, %arg1[%arg13 * 16 + %arg12 * 512 + 320] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<622 -> 623, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %536 = arith.mulf %535, %535 {timing = #hlscpp.t<421 -> 425, 4, 1>} : f64
      %537 = arith.addf %531, %536 {timing = #hlscpp.t<425 -> 430, 5, 1>} : f64
      %538 = affine.load %10[0] {partition_indices = [0], timing = #hlscpp.t<505 -> 506, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      %539 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 321] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<415 -> 417, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %540 = arith.mulf %539, %cst {timing = #hlscpp.t<417 -> 421, 4, 1>} : f64
      %541 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 321] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<419 -> 421, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %542 = arith.subf %541, %540 {timing = #hlscpp.t<421 -> 426, 5, 1>} : f64
      affine.store %542, %arg1[%arg13 * 16 + %arg12 * 512 + 321] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<623 -> 624, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %543 = arith.mulf %542, %542 {timing = #hlscpp.t<426 -> 430, 4, 1>} : f64
      %544 = arith.addf %537, %543 {timing = #hlscpp.t<430 -> 435, 5, 1>} : f64
      %545 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 322] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<420 -> 422, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %546 = arith.mulf %545, %cst {timing = #hlscpp.t<422 -> 426, 4, 1>} : f64
      %547 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 322] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<424 -> 426, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %548 = arith.subf %547, %546 {timing = #hlscpp.t<426 -> 431, 5, 1>} : f64
      affine.store %548, %arg1[%arg13 * 16 + %arg12 * 512 + 322] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<624 -> 625, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %549 = arith.mulf %548, %548 {timing = #hlscpp.t<431 -> 435, 4, 1>} : f64
      %550 = arith.addf %544, %549 {timing = #hlscpp.t<435 -> 440, 5, 1>} : f64
      %551 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 323] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<425 -> 427, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %552 = arith.mulf %551, %cst {timing = #hlscpp.t<427 -> 431, 4, 1>} : f64
      %553 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 323] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<429 -> 431, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %554 = arith.subf %553, %552 {timing = #hlscpp.t<431 -> 436, 5, 1>} : f64
      affine.store %554, %arg1[%arg13 * 16 + %arg12 * 512 + 323] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<625 -> 626, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %555 = arith.mulf %554, %554 {timing = #hlscpp.t<436 -> 440, 4, 1>} : f64
      %556 = arith.addf %550, %555 {timing = #hlscpp.t<440 -> 445, 5, 1>} : f64
      %557 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 324] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<430 -> 432, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %558 = arith.mulf %557, %cst {timing = #hlscpp.t<432 -> 436, 4, 1>} : f64
      %559 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 324] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<434 -> 436, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %560 = arith.subf %559, %558 {timing = #hlscpp.t<436 -> 441, 5, 1>} : f64
      affine.store %560, %arg1[%arg13 * 16 + %arg12 * 512 + 324] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<626 -> 627, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %561 = arith.mulf %560, %560 {timing = #hlscpp.t<441 -> 445, 4, 1>} : f64
      %562 = arith.addf %556, %561 {timing = #hlscpp.t<445 -> 450, 5, 1>} : f64
      %563 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 325] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<435 -> 437, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %564 = arith.mulf %563, %cst {timing = #hlscpp.t<437 -> 441, 4, 1>} : f64
      %565 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 325] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<439 -> 441, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %566 = arith.subf %565, %564 {timing = #hlscpp.t<441 -> 446, 5, 1>} : f64
      affine.store %566, %arg1[%arg13 * 16 + %arg12 * 512 + 325] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<627 -> 628, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %567 = arith.mulf %566, %566 {timing = #hlscpp.t<446 -> 450, 4, 1>} : f64
      %568 = arith.addf %562, %567 {timing = #hlscpp.t<450 -> 455, 5, 1>} : f64
      %569 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 326] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<440 -> 442, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %570 = arith.mulf %569, %cst {timing = #hlscpp.t<442 -> 446, 4, 1>} : f64
      %571 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 326] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<444 -> 446, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %572 = arith.subf %571, %570 {timing = #hlscpp.t<446 -> 451, 5, 1>} : f64
      affine.store %572, %arg1[%arg13 * 16 + %arg12 * 512 + 326] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<628 -> 629, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %573 = arith.mulf %572, %572 {timing = #hlscpp.t<451 -> 455, 4, 1>} : f64
      %574 = arith.addf %568, %573 {timing = #hlscpp.t<455 -> 460, 5, 1>} : f64
      %575 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 327] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<445 -> 447, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %576 = arith.mulf %575, %cst {timing = #hlscpp.t<447 -> 451, 4, 1>} : f64
      %577 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 327] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<449 -> 451, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %578 = arith.subf %577, %576 {timing = #hlscpp.t<451 -> 456, 5, 1>} : f64
      affine.store %578, %arg1[%arg13 * 16 + %arg12 * 512 + 327] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<629 -> 630, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %579 = arith.mulf %578, %578 {timing = #hlscpp.t<456 -> 460, 4, 1>} : f64
      %580 = arith.addf %574, %579 {timing = #hlscpp.t<460 -> 465, 5, 1>} : f64
      %581 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 328] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<450 -> 452, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %582 = arith.mulf %581, %cst {timing = #hlscpp.t<452 -> 456, 4, 1>} : f64
      %583 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 328] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<454 -> 456, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %584 = arith.subf %583, %582 {timing = #hlscpp.t<456 -> 461, 5, 1>} : f64
      affine.store %584, %arg1[%arg13 * 16 + %arg12 * 512 + 328] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<630 -> 631, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %585 = arith.mulf %584, %584 {timing = #hlscpp.t<461 -> 465, 4, 1>} : f64
      %586 = arith.addf %580, %585 {timing = #hlscpp.t<465 -> 470, 5, 1>} : f64
      %587 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 329] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<455 -> 457, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %588 = arith.mulf %587, %cst {timing = #hlscpp.t<457 -> 461, 4, 1>} : f64
      %589 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 329] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<459 -> 461, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %590 = arith.subf %589, %588 {timing = #hlscpp.t<461 -> 466, 5, 1>} : f64
      affine.store %590, %arg1[%arg13 * 16 + %arg12 * 512 + 329] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<631 -> 632, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %591 = arith.mulf %590, %590 {timing = #hlscpp.t<466 -> 470, 4, 1>} : f64
      %592 = arith.addf %586, %591 {timing = #hlscpp.t<470 -> 475, 5, 1>} : f64
      %593 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 330] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<460 -> 462, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %594 = arith.mulf %593, %cst {timing = #hlscpp.t<462 -> 466, 4, 1>} : f64
      %595 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 330] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<464 -> 466, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %596 = arith.subf %595, %594 {timing = #hlscpp.t<466 -> 471, 5, 1>} : f64
      affine.store %596, %arg1[%arg13 * 16 + %arg12 * 512 + 330] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<632 -> 633, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %597 = arith.mulf %596, %596 {timing = #hlscpp.t<471 -> 475, 4, 1>} : f64
      %598 = arith.addf %592, %597 {timing = #hlscpp.t<475 -> 480, 5, 1>} : f64
      %599 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 331] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<465 -> 467, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %600 = arith.mulf %599, %cst {timing = #hlscpp.t<467 -> 471, 4, 1>} : f64
      %601 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 331] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<469 -> 471, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %602 = arith.subf %601, %600 {timing = #hlscpp.t<471 -> 476, 5, 1>} : f64
      affine.store %602, %arg1[%arg13 * 16 + %arg12 * 512 + 331] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<633 -> 634, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %603 = arith.mulf %602, %602 {timing = #hlscpp.t<476 -> 480, 4, 1>} : f64
      %604 = arith.addf %598, %603 {timing = #hlscpp.t<480 -> 485, 5, 1>} : f64
      %605 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 332] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<470 -> 472, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %606 = arith.mulf %605, %cst {timing = #hlscpp.t<472 -> 476, 4, 1>} : f64
      %607 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 332] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<474 -> 476, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %608 = arith.subf %607, %606 {timing = #hlscpp.t<476 -> 481, 5, 1>} : f64
      affine.store %608, %arg1[%arg13 * 16 + %arg12 * 512 + 332] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<634 -> 635, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %609 = arith.mulf %608, %608 {timing = #hlscpp.t<481 -> 485, 4, 1>} : f64
      %610 = arith.addf %604, %609 {timing = #hlscpp.t<485 -> 490, 5, 1>} : f64
      %611 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 333] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<475 -> 477, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %612 = arith.mulf %611, %cst {timing = #hlscpp.t<477 -> 481, 4, 1>} : f64
      %613 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 333] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<479 -> 481, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %614 = arith.subf %613, %612 {timing = #hlscpp.t<481 -> 486, 5, 1>} : f64
      affine.store %614, %arg1[%arg13 * 16 + %arg12 * 512 + 333] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<635 -> 636, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %615 = arith.mulf %614, %614 {timing = #hlscpp.t<486 -> 490, 4, 1>} : f64
      %616 = arith.addf %610, %615 {timing = #hlscpp.t<490 -> 495, 5, 1>} : f64
      %617 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 334] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<480 -> 482, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %618 = arith.mulf %617, %cst {timing = #hlscpp.t<482 -> 486, 4, 1>} : f64
      %619 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 334] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<484 -> 486, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %620 = arith.subf %619, %618 {timing = #hlscpp.t<486 -> 491, 5, 1>} : f64
      affine.store %620, %arg1[%arg13 * 16 + %arg12 * 512 + 334] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<636 -> 637, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %621 = arith.mulf %620, %620 {timing = #hlscpp.t<491 -> 495, 4, 1>} : f64
      %622 = arith.addf %616, %621 {timing = #hlscpp.t<495 -> 500, 5, 1>} : f64
      %623 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 335] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<485 -> 487, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %624 = arith.mulf %623, %cst {timing = #hlscpp.t<487 -> 491, 4, 1>} : f64
      %625 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 335] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<489 -> 491, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %626 = arith.subf %625, %624 {timing = #hlscpp.t<491 -> 496, 5, 1>} : f64
      affine.store %626, %arg1[%arg13 * 16 + %arg12 * 512 + 335] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<637 -> 638, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %627 = arith.mulf %626, %626 {timing = #hlscpp.t<496 -> 500, 4, 1>} : f64
      %628 = arith.addf %622, %627 {timing = #hlscpp.t<500 -> 505, 5, 1>} : f64
      affine.store %628, %12[0] {partition_indices = [0], timing = #hlscpp.t<505 -> 506, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      affine.store %628, %13[0] {partition_indices = [0], timing = #hlscpp.t<667 -> 668, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      affine.if affine_set<(d0) : (-(d0 * 16 + 15) + 63 == 0)>(%arg13) {
        affine.store %628, %11[0] {partition_indices = [0], timing = #hlscpp.t<669 -> 670, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      } {timing = #hlscpp.t<669 -> 670, 1, 0>}
      %629 = affine.if affine_set<(d0) : (-(d0 * 16 + 15) + 63 == 0)>(%arg13) -> f64 {
        affine.store %628, %10[0] {partition_indices = [0], timing = #hlscpp.t<506 -> 507, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
        affine.yield {timing = #hlscpp.t<507 -> 507, 0, 0>} %628 : f64
      } else {
        affine.yield {timing = #hlscpp.t<507 -> 507, 0, 0>} %538 : f64
      } {timing = #hlscpp.t<506 -> 507, 1, 0>}
      %630 = affine.load %12[0] {partition_indices = [0], timing = #hlscpp.t<506 -> 507, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      %631 = affine.if affine_set<(d0) : (d0 * 16 == 0)>(%arg13) -> f64 {
        affine.yield {timing = #hlscpp.t<507 -> 507, 0, 0>} %629 : f64
      } else {
        affine.yield {timing = #hlscpp.t<507 -> 507, 0, 0>} %630 : f64
      } {timing = #hlscpp.t<507 -> 507, 0, 0>}
      %632 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 384] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<492 -> 494, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %633 = arith.mulf %632, %cst {timing = #hlscpp.t<494 -> 498, 4, 1>} : f64
      %634 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 384] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<496 -> 498, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %635 = arith.subf %634, %633 {timing = #hlscpp.t<498 -> 503, 5, 1>} : f64
      affine.store %635, %arg1[%arg13 * 16 + %arg12 * 512 + 384] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<638 -> 639, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %636 = arith.mulf %635, %635 {timing = #hlscpp.t<503 -> 507, 4, 1>} : f64
      %637 = arith.addf %631, %636 {timing = #hlscpp.t<507 -> 512, 5, 1>} : f64
      %638 = affine.load %10[0] {partition_indices = [0], timing = #hlscpp.t<587 -> 588, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      %639 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 385] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<497 -> 499, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %640 = arith.mulf %639, %cst {timing = #hlscpp.t<499 -> 503, 4, 1>} : f64
      %641 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 385] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<501 -> 503, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %642 = arith.subf %641, %640 {timing = #hlscpp.t<503 -> 508, 5, 1>} : f64
      affine.store %642, %arg1[%arg13 * 16 + %arg12 * 512 + 385] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<639 -> 640, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %643 = arith.mulf %642, %642 {timing = #hlscpp.t<508 -> 512, 4, 1>} : f64
      %644 = arith.addf %637, %643 {timing = #hlscpp.t<512 -> 517, 5, 1>} : f64
      %645 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 386] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<502 -> 504, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %646 = arith.mulf %645, %cst {timing = #hlscpp.t<504 -> 508, 4, 1>} : f64
      %647 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 386] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<506 -> 508, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %648 = arith.subf %647, %646 {timing = #hlscpp.t<508 -> 513, 5, 1>} : f64
      affine.store %648, %arg1[%arg13 * 16 + %arg12 * 512 + 386] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<640 -> 641, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %649 = arith.mulf %648, %648 {timing = #hlscpp.t<513 -> 517, 4, 1>} : f64
      %650 = arith.addf %644, %649 {timing = #hlscpp.t<517 -> 522, 5, 1>} : f64
      %651 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 387] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<507 -> 509, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %652 = arith.mulf %651, %cst {timing = #hlscpp.t<509 -> 513, 4, 1>} : f64
      %653 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 387] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<511 -> 513, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %654 = arith.subf %653, %652 {timing = #hlscpp.t<513 -> 518, 5, 1>} : f64
      affine.store %654, %arg1[%arg13 * 16 + %arg12 * 512 + 387] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<641 -> 642, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %655 = arith.mulf %654, %654 {timing = #hlscpp.t<518 -> 522, 4, 1>} : f64
      %656 = arith.addf %650, %655 {timing = #hlscpp.t<522 -> 527, 5, 1>} : f64
      %657 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 388] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<512 -> 514, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %658 = arith.mulf %657, %cst {timing = #hlscpp.t<514 -> 518, 4, 1>} : f64
      %659 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 388] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<516 -> 518, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %660 = arith.subf %659, %658 {timing = #hlscpp.t<518 -> 523, 5, 1>} : f64
      affine.store %660, %arg1[%arg13 * 16 + %arg12 * 512 + 388] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<642 -> 643, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %661 = arith.mulf %660, %660 {timing = #hlscpp.t<523 -> 527, 4, 1>} : f64
      %662 = arith.addf %656, %661 {timing = #hlscpp.t<527 -> 532, 5, 1>} : f64
      %663 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 389] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<517 -> 519, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %664 = arith.mulf %663, %cst {timing = #hlscpp.t<519 -> 523, 4, 1>} : f64
      %665 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 389] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<521 -> 523, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %666 = arith.subf %665, %664 {timing = #hlscpp.t<523 -> 528, 5, 1>} : f64
      affine.store %666, %arg1[%arg13 * 16 + %arg12 * 512 + 389] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<643 -> 644, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %667 = arith.mulf %666, %666 {timing = #hlscpp.t<528 -> 532, 4, 1>} : f64
      %668 = arith.addf %662, %667 {timing = #hlscpp.t<532 -> 537, 5, 1>} : f64
      %669 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 390] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<522 -> 524, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %670 = arith.mulf %669, %cst {timing = #hlscpp.t<524 -> 528, 4, 1>} : f64
      %671 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 390] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<526 -> 528, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %672 = arith.subf %671, %670 {timing = #hlscpp.t<528 -> 533, 5, 1>} : f64
      affine.store %672, %arg1[%arg13 * 16 + %arg12 * 512 + 390] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<644 -> 645, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %673 = arith.mulf %672, %672 {timing = #hlscpp.t<533 -> 537, 4, 1>} : f64
      %674 = arith.addf %668, %673 {timing = #hlscpp.t<537 -> 542, 5, 1>} : f64
      %675 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 391] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<527 -> 529, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %676 = arith.mulf %675, %cst {timing = #hlscpp.t<529 -> 533, 4, 1>} : f64
      %677 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 391] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<531 -> 533, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %678 = arith.subf %677, %676 {timing = #hlscpp.t<533 -> 538, 5, 1>} : f64
      affine.store %678, %arg1[%arg13 * 16 + %arg12 * 512 + 391] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<645 -> 646, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %679 = arith.mulf %678, %678 {timing = #hlscpp.t<538 -> 542, 4, 1>} : f64
      %680 = arith.addf %674, %679 {timing = #hlscpp.t<542 -> 547, 5, 1>} : f64
      %681 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 392] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<532 -> 534, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %682 = arith.mulf %681, %cst {timing = #hlscpp.t<534 -> 538, 4, 1>} : f64
      %683 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 392] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<536 -> 538, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %684 = arith.subf %683, %682 {timing = #hlscpp.t<538 -> 543, 5, 1>} : f64
      affine.store %684, %arg1[%arg13 * 16 + %arg12 * 512 + 392] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<646 -> 647, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %685 = arith.mulf %684, %684 {timing = #hlscpp.t<543 -> 547, 4, 1>} : f64
      %686 = arith.addf %680, %685 {timing = #hlscpp.t<547 -> 552, 5, 1>} : f64
      %687 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 393] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<537 -> 539, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %688 = arith.mulf %687, %cst {timing = #hlscpp.t<539 -> 543, 4, 1>} : f64
      %689 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 393] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<541 -> 543, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %690 = arith.subf %689, %688 {timing = #hlscpp.t<543 -> 548, 5, 1>} : f64
      affine.store %690, %arg1[%arg13 * 16 + %arg12 * 512 + 393] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<647 -> 648, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %691 = arith.mulf %690, %690 {timing = #hlscpp.t<548 -> 552, 4, 1>} : f64
      %692 = arith.addf %686, %691 {timing = #hlscpp.t<552 -> 557, 5, 1>} : f64
      %693 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 394] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<542 -> 544, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %694 = arith.mulf %693, %cst {timing = #hlscpp.t<544 -> 548, 4, 1>} : f64
      %695 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 394] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<546 -> 548, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %696 = arith.subf %695, %694 {timing = #hlscpp.t<548 -> 553, 5, 1>} : f64
      affine.store %696, %arg1[%arg13 * 16 + %arg12 * 512 + 394] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<648 -> 649, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %697 = arith.mulf %696, %696 {timing = #hlscpp.t<553 -> 557, 4, 1>} : f64
      %698 = arith.addf %692, %697 {timing = #hlscpp.t<557 -> 562, 5, 1>} : f64
      %699 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 395] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<547 -> 549, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %700 = arith.mulf %699, %cst {timing = #hlscpp.t<549 -> 553, 4, 1>} : f64
      %701 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 395] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<551 -> 553, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %702 = arith.subf %701, %700 {timing = #hlscpp.t<553 -> 558, 5, 1>} : f64
      affine.store %702, %arg1[%arg13 * 16 + %arg12 * 512 + 395] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<649 -> 650, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %703 = arith.mulf %702, %702 {timing = #hlscpp.t<558 -> 562, 4, 1>} : f64
      %704 = arith.addf %698, %703 {timing = #hlscpp.t<562 -> 567, 5, 1>} : f64
      %705 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 396] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<552 -> 554, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %706 = arith.mulf %705, %cst {timing = #hlscpp.t<554 -> 558, 4, 1>} : f64
      %707 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 396] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<556 -> 558, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %708 = arith.subf %707, %706 {timing = #hlscpp.t<558 -> 563, 5, 1>} : f64
      affine.store %708, %arg1[%arg13 * 16 + %arg12 * 512 + 396] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<650 -> 651, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %709 = arith.mulf %708, %708 {timing = #hlscpp.t<563 -> 567, 4, 1>} : f64
      %710 = arith.addf %704, %709 {timing = #hlscpp.t<567 -> 572, 5, 1>} : f64
      %711 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 397] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<557 -> 559, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %712 = arith.mulf %711, %cst {timing = #hlscpp.t<559 -> 563, 4, 1>} : f64
      %713 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 397] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<561 -> 563, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %714 = arith.subf %713, %712 {timing = #hlscpp.t<563 -> 568, 5, 1>} : f64
      affine.store %714, %arg1[%arg13 * 16 + %arg12 * 512 + 397] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<651 -> 652, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %715 = arith.mulf %714, %714 {timing = #hlscpp.t<568 -> 572, 4, 1>} : f64
      %716 = arith.addf %710, %715 {timing = #hlscpp.t<572 -> 577, 5, 1>} : f64
      %717 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 398] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<562 -> 564, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %718 = arith.mulf %717, %cst {timing = #hlscpp.t<564 -> 568, 4, 1>} : f64
      %719 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 398] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<566 -> 568, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %720 = arith.subf %719, %718 {timing = #hlscpp.t<568 -> 573, 5, 1>} : f64
      affine.store %720, %arg1[%arg13 * 16 + %arg12 * 512 + 398] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<652 -> 653, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %721 = arith.mulf %720, %720 {timing = #hlscpp.t<573 -> 577, 4, 1>} : f64
      %722 = arith.addf %716, %721 {timing = #hlscpp.t<577 -> 582, 5, 1>} : f64
      %723 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 399] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<567 -> 569, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %724 = arith.mulf %723, %cst {timing = #hlscpp.t<569 -> 573, 4, 1>} : f64
      %725 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 399] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<571 -> 573, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %726 = arith.subf %725, %724 {timing = #hlscpp.t<573 -> 578, 5, 1>} : f64
      affine.store %726, %arg1[%arg13 * 16 + %arg12 * 512 + 399] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<653 -> 654, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %727 = arith.mulf %726, %726 {timing = #hlscpp.t<578 -> 582, 4, 1>} : f64
      %728 = arith.addf %722, %727 {timing = #hlscpp.t<582 -> 587, 5, 1>} : f64
      affine.store %728, %12[0] {partition_indices = [0], timing = #hlscpp.t<587 -> 588, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      affine.store %728, %13[0] {partition_indices = [0], timing = #hlscpp.t<668 -> 669, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      affine.if affine_set<(d0) : (-(d0 * 16 + 15) + 63 == 0)>(%arg13) {
        affine.store %728, %11[0] {partition_indices = [0], timing = #hlscpp.t<669 -> 670, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      } {timing = #hlscpp.t<669 -> 670, 1, 0>}
      %729 = affine.if affine_set<(d0) : (-(d0 * 16 + 15) + 63 == 0)>(%arg13) -> f64 {
        affine.store %728, %10[0] {partition_indices = [0], timing = #hlscpp.t<588 -> 589, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
        affine.yield {timing = #hlscpp.t<589 -> 589, 0, 0>} %728 : f64
      } else {
        affine.yield {timing = #hlscpp.t<589 -> 589, 0, 0>} %638 : f64
      } {timing = #hlscpp.t<588 -> 589, 1, 0>}
      %730 = affine.load %12[0] {partition_indices = [0], timing = #hlscpp.t<588 -> 589, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      %731 = affine.if affine_set<(d0) : (d0 * 16 == 0)>(%arg13) -> f64 {
        affine.yield {timing = #hlscpp.t<589 -> 589, 0, 0>} %729 : f64
      } else {
        affine.yield {timing = #hlscpp.t<589 -> 589, 0, 0>} %730 : f64
      } {timing = #hlscpp.t<589 -> 589, 0, 0>}
      %732 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 448] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<574 -> 576, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %733 = arith.mulf %732, %cst {timing = #hlscpp.t<576 -> 580, 4, 1>} : f64
      %734 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 448] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<578 -> 580, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %735 = arith.subf %734, %733 {timing = #hlscpp.t<580 -> 585, 5, 1>} : f64
      affine.store %735, %arg1[%arg13 * 16 + %arg12 * 512 + 448] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<654 -> 655, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %736 = arith.mulf %735, %735 {timing = #hlscpp.t<585 -> 589, 4, 1>} : f64
      %737 = arith.addf %731, %736 {timing = #hlscpp.t<589 -> 594, 5, 1>} : f64
      %738 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 449] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<579 -> 581, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %739 = arith.mulf %738, %cst {timing = #hlscpp.t<581 -> 585, 4, 1>} : f64
      %740 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 449] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<583 -> 585, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %741 = arith.subf %740, %739 {timing = #hlscpp.t<585 -> 590, 5, 1>} : f64
      affine.store %741, %arg1[%arg13 * 16 + %arg12 * 512 + 449] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<655 -> 656, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %742 = arith.mulf %741, %741 {timing = #hlscpp.t<590 -> 594, 4, 1>} : f64
      %743 = arith.addf %737, %742 {timing = #hlscpp.t<594 -> 599, 5, 1>} : f64
      %744 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 450] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<584 -> 586, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %745 = arith.mulf %744, %cst {timing = #hlscpp.t<586 -> 590, 4, 1>} : f64
      %746 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 450] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<588 -> 590, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %747 = arith.subf %746, %745 {timing = #hlscpp.t<590 -> 595, 5, 1>} : f64
      affine.store %747, %arg1[%arg13 * 16 + %arg12 * 512 + 450] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<656 -> 657, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %748 = arith.mulf %747, %747 {timing = #hlscpp.t<595 -> 599, 4, 1>} : f64
      %749 = arith.addf %743, %748 {timing = #hlscpp.t<599 -> 604, 5, 1>} : f64
      %750 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 451] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<589 -> 591, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %751 = arith.mulf %750, %cst {timing = #hlscpp.t<591 -> 595, 4, 1>} : f64
      %752 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 451] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<593 -> 595, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %753 = arith.subf %752, %751 {timing = #hlscpp.t<595 -> 600, 5, 1>} : f64
      affine.store %753, %arg1[%arg13 * 16 + %arg12 * 512 + 451] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<657 -> 658, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %754 = arith.mulf %753, %753 {timing = #hlscpp.t<600 -> 604, 4, 1>} : f64
      %755 = arith.addf %749, %754 {timing = #hlscpp.t<604 -> 609, 5, 1>} : f64
      %756 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 452] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<594 -> 596, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %757 = arith.mulf %756, %cst {timing = #hlscpp.t<596 -> 600, 4, 1>} : f64
      %758 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 452] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<598 -> 600, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %759 = arith.subf %758, %757 {timing = #hlscpp.t<600 -> 605, 5, 1>} : f64
      affine.store %759, %arg1[%arg13 * 16 + %arg12 * 512 + 452] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<658 -> 659, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %760 = arith.mulf %759, %759 {timing = #hlscpp.t<605 -> 609, 4, 1>} : f64
      %761 = arith.addf %755, %760 {timing = #hlscpp.t<609 -> 614, 5, 1>} : f64
      %762 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 453] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<599 -> 601, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %763 = arith.mulf %762, %cst {timing = #hlscpp.t<601 -> 605, 4, 1>} : f64
      %764 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 453] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<603 -> 605, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %765 = arith.subf %764, %763 {timing = #hlscpp.t<605 -> 610, 5, 1>} : f64
      affine.store %765, %arg1[%arg13 * 16 + %arg12 * 512 + 453] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<659 -> 660, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %766 = arith.mulf %765, %765 {timing = #hlscpp.t<610 -> 614, 4, 1>} : f64
      %767 = arith.addf %761, %766 {timing = #hlscpp.t<614 -> 619, 5, 1>} : f64
      %768 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 454] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<604 -> 606, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %769 = arith.mulf %768, %cst {timing = #hlscpp.t<606 -> 610, 4, 1>} : f64
      %770 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 454] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<608 -> 610, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %771 = arith.subf %770, %769 {timing = #hlscpp.t<610 -> 615, 5, 1>} : f64
      affine.store %771, %arg1[%arg13 * 16 + %arg12 * 512 + 454] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<660 -> 661, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %772 = arith.mulf %771, %771 {timing = #hlscpp.t<615 -> 619, 4, 1>} : f64
      %773 = arith.addf %767, %772 {timing = #hlscpp.t<619 -> 624, 5, 1>} : f64
      %774 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 455] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<609 -> 611, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %775 = arith.mulf %774, %cst {timing = #hlscpp.t<611 -> 615, 4, 1>} : f64
      %776 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 455] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<613 -> 615, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %777 = arith.subf %776, %775 {timing = #hlscpp.t<615 -> 620, 5, 1>} : f64
      affine.store %777, %arg1[%arg13 * 16 + %arg12 * 512 + 455] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<661 -> 662, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %778 = arith.mulf %777, %777 {timing = #hlscpp.t<620 -> 624, 4, 1>} : f64
      %779 = arith.addf %773, %778 {timing = #hlscpp.t<624 -> 629, 5, 1>} : f64
      %780 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 456] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<614 -> 616, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %781 = arith.mulf %780, %cst {timing = #hlscpp.t<616 -> 620, 4, 1>} : f64
      %782 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 456] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<618 -> 620, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %783 = arith.subf %782, %781 {timing = #hlscpp.t<620 -> 625, 5, 1>} : f64
      affine.store %783, %arg1[%arg13 * 16 + %arg12 * 512 + 456] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<662 -> 663, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %784 = arith.mulf %783, %783 {timing = #hlscpp.t<625 -> 629, 4, 1>} : f64
      %785 = arith.addf %779, %784 {timing = #hlscpp.t<629 -> 634, 5, 1>} : f64
      %786 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 457] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<619 -> 621, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %787 = arith.mulf %786, %cst {timing = #hlscpp.t<621 -> 625, 4, 1>} : f64
      %788 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 457] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<623 -> 625, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %789 = arith.subf %788, %787 {timing = #hlscpp.t<625 -> 630, 5, 1>} : f64
      affine.store %789, %arg1[%arg13 * 16 + %arg12 * 512 + 457] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<663 -> 664, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %790 = arith.mulf %789, %789 {timing = #hlscpp.t<630 -> 634, 4, 1>} : f64
      %791 = arith.addf %785, %790 {timing = #hlscpp.t<634 -> 639, 5, 1>} : f64
      %792 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 458] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<624 -> 626, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %793 = arith.mulf %792, %cst {timing = #hlscpp.t<626 -> 630, 4, 1>} : f64
      %794 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 458] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<628 -> 630, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %795 = arith.subf %794, %793 {timing = #hlscpp.t<630 -> 635, 5, 1>} : f64
      affine.store %795, %arg1[%arg13 * 16 + %arg12 * 512 + 458] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<664 -> 665, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %796 = arith.mulf %795, %795 {timing = #hlscpp.t<635 -> 639, 4, 1>} : f64
      %797 = arith.addf %791, %796 {timing = #hlscpp.t<639 -> 644, 5, 1>} : f64
      %798 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 459] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<629 -> 631, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %799 = arith.mulf %798, %cst {timing = #hlscpp.t<631 -> 635, 4, 1>} : f64
      %800 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 459] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<633 -> 635, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %801 = arith.subf %800, %799 {timing = #hlscpp.t<635 -> 640, 5, 1>} : f64
      affine.store %801, %arg1[%arg13 * 16 + %arg12 * 512 + 459] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<665 -> 666, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %802 = arith.mulf %801, %801 {timing = #hlscpp.t<640 -> 644, 4, 1>} : f64
      %803 = arith.addf %797, %802 {timing = #hlscpp.t<644 -> 649, 5, 1>} : f64
      %804 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 460] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<634 -> 636, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %805 = arith.mulf %804, %cst {timing = #hlscpp.t<636 -> 640, 4, 1>} : f64
      %806 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 460] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<638 -> 640, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %807 = arith.subf %806, %805 {timing = #hlscpp.t<640 -> 645, 5, 1>} : f64
      affine.store %807, %arg1[%arg13 * 16 + %arg12 * 512 + 460] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<666 -> 667, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %808 = arith.mulf %807, %807 {timing = #hlscpp.t<645 -> 649, 4, 1>} : f64
      %809 = arith.addf %803, %808 {timing = #hlscpp.t<649 -> 654, 5, 1>} : f64
      %810 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 461] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<639 -> 641, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %811 = arith.mulf %810, %cst {timing = #hlscpp.t<641 -> 645, 4, 1>} : f64
      %812 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 461] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<643 -> 645, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %813 = arith.subf %812, %811 {timing = #hlscpp.t<645 -> 650, 5, 1>} : f64
      affine.store %813, %arg1[%arg13 * 16 + %arg12 * 512 + 461] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<667 -> 668, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %814 = arith.mulf %813, %813 {timing = #hlscpp.t<650 -> 654, 4, 1>} : f64
      %815 = arith.addf %809, %814 {timing = #hlscpp.t<654 -> 659, 5, 1>} : f64
      %816 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 462] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<644 -> 646, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %817 = arith.mulf %816, %cst {timing = #hlscpp.t<646 -> 650, 4, 1>} : f64
      %818 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 462] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<648 -> 650, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %819 = arith.subf %818, %817 {timing = #hlscpp.t<650 -> 655, 5, 1>} : f64
      affine.store %819, %arg1[%arg13 * 16 + %arg12 * 512 + 462] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<668 -> 669, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %820 = arith.mulf %819, %819 {timing = #hlscpp.t<655 -> 659, 4, 1>} : f64
      %821 = arith.addf %815, %820 {timing = #hlscpp.t<659 -> 664, 5, 1>} : f64
      %822 = affine.load %arg4[%arg13 * 16 + %arg12 * 512 + 463] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<649 -> 651, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %823 = arith.mulf %822, %cst {timing = #hlscpp.t<651 -> 655, 4, 1>} : f64
      %824 = affine.load %arg1[%arg13 * 16 + %arg12 * 512 + 463] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<653 -> 655, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %825 = arith.subf %824, %823 {timing = #hlscpp.t<655 -> 660, 5, 1>} : f64
      affine.store %825, %arg1[%arg13 * 16 + %arg12 * 512 + 463] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<669 -> 670, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %826 = arith.mulf %825, %825 {timing = #hlscpp.t<660 -> 664, 4, 1>} : f64
      %827 = arith.addf %821, %826 {timing = #hlscpp.t<664 -> 669, 5, 1>} : f64
      affine.store %827, %12[0] {partition_indices = [0], timing = #hlscpp.t<669 -> 670, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      affine.store %827, %13[0] {partition_indices = [0], timing = #hlscpp.t<669 -> 670, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      affine.if affine_set<(d0) : (-(d0 * 16 + 15) + 63 == 0)>(%arg13) {
        affine.store %827, %10[0] {partition_indices = [0], timing = #hlscpp.t<669 -> 670, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
        affine.store %827, %11[0] {partition_indices = [0], timing = #hlscpp.t<669 -> 670, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
      } {timing = #hlscpp.t<669 -> 670, 1, 0>}
    } {loop_directive = #hlscpp.ld<pipeline=true, targetII=649, dataflow=false, flatten=false, parallel=false>, loop_info = #hlscpp.l<flattenTripCount=4, iterLatency=670, minII=656>, timing = #hlscpp.t<4600 -> 7240, 2640, 2640>}
  } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true, parallel=false>, loop_info = #hlscpp.l<flattenTripCount=32, iterLatency=670, minII=656>, timing = #hlscpp.t<4490 -> 25498, 21008, 21008>}
  %14 = affine.load %11[0] {partition_indices = [0], timing = #hlscpp.t<25605 -> 25606, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  %15 = memref.alloc() {timing = #hlscpp.t<25498 -> 25498, 0, 0>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  affine.store %cst_0, %15[0] {partition_indices = [0], timing = #hlscpp.t<25498 -> 25499, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  %16 = memref.alloc() {timing = #hlscpp.t<25498 -> 25498, 0, 0>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  affine.store %cst_0, %16[0] {partition_indices = [0], timing = #hlscpp.t<25498 -> 25499, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  affine.for %arg12 = 0 to 8 {
    %30 = affine.load %arg10[%arg12 * 8] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %31 = arith.mulf %30, %cst {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %32 = affine.load %arg7[%arg12 * 8] {partition_indices = [0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %33 = arith.subf %32, %31 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    affine.store %33, %arg7[%arg12 * 8] {partition_indices = [0], timing = #hlscpp.t<55 -> 56, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %34 = arith.mulf %33, %33 {timing = #hlscpp.t<11 -> 15, 4, 1>} : f64
    %35 = affine.load %arg10[%arg12 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %36 = arith.mulf %35, %cst {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %37 = affine.load %arg7[%arg12 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %38 = arith.subf %37, %36 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    affine.store %38, %arg7[%arg12 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<55 -> 56, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %39 = arith.mulf %38, %38 {timing = #hlscpp.t<11 -> 15, 4, 1>} : f64
    %40 = arith.addf %34, %39 {timing = #hlscpp.t<15 -> 20, 5, 1>} : f64
    %41 = affine.load %arg10[%arg12 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %42 = arith.mulf %41, %cst {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %43 = affine.load %arg7[%arg12 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<9 -> 11, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %44 = arith.subf %43, %42 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    affine.store %44, %arg7[%arg12 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<55 -> 56, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %45 = arith.mulf %44, %44 {timing = #hlscpp.t<16 -> 20, 4, 1>} : f64
    %46 = arith.addf %40, %45 {timing = #hlscpp.t<20 -> 25, 5, 1>} : f64
    %47 = affine.load %arg10[%arg12 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %48 = arith.mulf %47, %cst {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %49 = affine.load %arg7[%arg12 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<14 -> 16, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %50 = arith.subf %49, %48 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    affine.store %50, %arg7[%arg12 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<55 -> 56, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %51 = arith.mulf %50, %50 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    %52 = arith.addf %46, %51 {timing = #hlscpp.t<25 -> 30, 5, 1>} : f64
    %53 = affine.load %arg10[%arg12 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %54 = arith.mulf %53, %cst {timing = #hlscpp.t<17 -> 21, 4, 1>} : f64
    %55 = affine.load %arg7[%arg12 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %56 = arith.subf %55, %54 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f64
    affine.store %56, %arg7[%arg12 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<55 -> 56, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %57 = arith.mulf %56, %56 {timing = #hlscpp.t<26 -> 30, 4, 1>} : f64
    %58 = arith.addf %52, %57 {timing = #hlscpp.t<30 -> 35, 5, 1>} : f64
    %59 = affine.load %arg10[%arg12 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %60 = arith.mulf %59, %cst {timing = #hlscpp.t<22 -> 26, 4, 1>} : f64
    %61 = affine.load %arg7[%arg12 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<24 -> 26, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %62 = arith.subf %61, %60 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f64
    affine.store %62, %arg7[%arg12 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<55 -> 56, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %63 = arith.mulf %62, %62 {timing = #hlscpp.t<31 -> 35, 4, 1>} : f64
    %64 = arith.addf %58, %63 {timing = #hlscpp.t<35 -> 40, 5, 1>} : f64
    %65 = affine.load %arg10[%arg12 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %66 = arith.mulf %65, %cst {timing = #hlscpp.t<27 -> 31, 4, 1>} : f64
    %67 = affine.load %arg7[%arg12 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<29 -> 31, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %68 = arith.subf %67, %66 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f64
    affine.store %68, %arg7[%arg12 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<55 -> 56, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %69 = arith.mulf %68, %68 {timing = #hlscpp.t<36 -> 40, 4, 1>} : f64
    %70 = arith.addf %64, %69 {timing = #hlscpp.t<40 -> 45, 5, 1>} : f64
    %71 = affine.load %arg10[%arg12 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %72 = arith.mulf %71, %cst {timing = #hlscpp.t<32 -> 36, 4, 1>} : f64
    %73 = affine.load %arg7[%arg12 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<34 -> 36, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %74 = arith.subf %73, %72 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f64
    affine.store %74, %arg7[%arg12 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<55 -> 56, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %75 = arith.mulf %74, %74 {timing = #hlscpp.t<41 -> 45, 4, 1>} : f64
    %76 = arith.addf %70, %75 {timing = #hlscpp.t<45 -> 50, 5, 1>} : f64
    %77 = affine.load %15[0] {partition_indices = [0], timing = #hlscpp.t<49 -> 50, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
    %78 = arith.addf %77, %76 {timing = #hlscpp.t<50 -> 55, 5, 1>} : f64
    affine.store %78, %15[0] {partition_indices = [0], timing = #hlscpp.t<55 -> 56, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
    affine.store %78, %16[0] {partition_indices = [0], timing = #hlscpp.t<55 -> 56, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=7, dataflow=false, flatten=false, parallel=false>, loop_info = #hlscpp.l<flattenTripCount=8, iterLatency=56, minII=7>, timing = #hlscpp.t<25499 -> 25606, 107, 107>}
  %17 = affine.load %16[0] {partition_indices = [0], timing = #hlscpp.t<29721 -> 29722, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  %18 = math.sqrt %14 {timing = #hlscpp.t<25606 -> 25606, 0, 0>} : f64
  %19 = math.sqrt %17 {timing = #hlscpp.t<29722 -> 29722, 0, 0>} : f64
  affine.for %arg12 = 0 to 64 {
    affine.for %arg13 = 0 to 4 {
      %30 = affine.load %arg1[%arg12 * 64 + %arg13 * 16] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %31 = arith.divf %30, %18 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
      affine.store %31, %arg1[%arg12 * 64 + %arg13 * 16] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %32 = affine.load %arg1[%arg12 * 64 + %arg13 * 16 + 1] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<1 -> 3, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %33 = arith.divf %32, %18 {timing = #hlscpp.t<3 -> 19, 16, 1>} : f64
      affine.store %33, %arg1[%arg12 * 64 + %arg13 * 16 + 1] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<19 -> 20, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %34 = affine.load %arg1[%arg12 * 64 + %arg13 * 16 + 2] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<2 -> 4, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %35 = arith.divf %34, %18 {timing = #hlscpp.t<4 -> 20, 16, 1>} : f64
      affine.store %35, %arg1[%arg12 * 64 + %arg13 * 16 + 2] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<20 -> 21, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %36 = affine.load %arg1[%arg12 * 64 + %arg13 * 16 + 3] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<3 -> 5, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %37 = arith.divf %36, %18 {timing = #hlscpp.t<5 -> 21, 16, 1>} : f64
      affine.store %37, %arg1[%arg12 * 64 + %arg13 * 16 + 3] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<21 -> 22, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %38 = affine.load %arg1[%arg12 * 64 + %arg13 * 16 + 4] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %39 = arith.divf %38, %18 {timing = #hlscpp.t<6 -> 22, 16, 1>} : f64
      affine.store %39, %arg1[%arg12 * 64 + %arg13 * 16 + 4] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<22 -> 23, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %40 = affine.load %arg1[%arg12 * 64 + %arg13 * 16 + 5] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %41 = arith.divf %40, %18 {timing = #hlscpp.t<7 -> 23, 16, 1>} : f64
      affine.store %41, %arg1[%arg12 * 64 + %arg13 * 16 + 5] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<23 -> 24, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %42 = affine.load %arg1[%arg12 * 64 + %arg13 * 16 + 6] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<6 -> 8, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %43 = arith.divf %42, %18 {timing = #hlscpp.t<8 -> 24, 16, 1>} : f64
      affine.store %43, %arg1[%arg12 * 64 + %arg13 * 16 + 6] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<24 -> 25, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %44 = affine.load %arg1[%arg12 * 64 + %arg13 * 16 + 7] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<7 -> 9, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %45 = arith.divf %44, %18 {timing = #hlscpp.t<9 -> 25, 16, 1>} : f64
      affine.store %45, %arg1[%arg12 * 64 + %arg13 * 16 + 7] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<25 -> 26, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %46 = affine.load %arg1[%arg12 * 64 + %arg13 * 16 + 8] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<8 -> 10, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %47 = arith.divf %46, %18 {timing = #hlscpp.t<10 -> 26, 16, 1>} : f64
      affine.store %47, %arg1[%arg12 * 64 + %arg13 * 16 + 8] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<26 -> 27, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %48 = affine.load %arg1[%arg12 * 64 + %arg13 * 16 + 9] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<9 -> 11, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %49 = arith.divf %48, %18 {timing = #hlscpp.t<11 -> 27, 16, 1>} : f64
      affine.store %49, %arg1[%arg12 * 64 + %arg13 * 16 + 9] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<27 -> 28, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %50 = affine.load %arg1[%arg12 * 64 + %arg13 * 16 + 10] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %51 = arith.divf %50, %18 {timing = #hlscpp.t<12 -> 28, 16, 1>} : f64
      affine.store %51, %arg1[%arg12 * 64 + %arg13 * 16 + 10] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<28 -> 29, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %52 = affine.load %arg1[%arg12 * 64 + %arg13 * 16 + 11] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<11 -> 13, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %53 = arith.divf %52, %18 {timing = #hlscpp.t<13 -> 29, 16, 1>} : f64
      affine.store %53, %arg1[%arg12 * 64 + %arg13 * 16 + 11] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<29 -> 30, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %54 = affine.load %arg1[%arg12 * 64 + %arg13 * 16 + 12] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<12 -> 14, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %55 = arith.divf %54, %18 {timing = #hlscpp.t<14 -> 30, 16, 1>} : f64
      affine.store %55, %arg1[%arg12 * 64 + %arg13 * 16 + 12] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<30 -> 31, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %56 = affine.load %arg1[%arg12 * 64 + %arg13 * 16 + 13] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<13 -> 15, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %57 = arith.divf %56, %18 {timing = #hlscpp.t<15 -> 31, 16, 1>} : f64
      affine.store %57, %arg1[%arg12 * 64 + %arg13 * 16 + 13] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<31 -> 32, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %58 = affine.load %arg1[%arg12 * 64 + %arg13 * 16 + 14] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<14 -> 16, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %59 = arith.divf %58, %18 {timing = #hlscpp.t<16 -> 32, 16, 1>} : f64
      affine.store %59, %arg1[%arg12 * 64 + %arg13 * 16 + 14] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<32 -> 33, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %60 = affine.load %arg1[%arg12 * 64 + %arg13 * 16 + 15] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
      %61 = arith.divf %60, %18 {timing = #hlscpp.t<17 -> 33, 16, 1>} : f64
      affine.store %61, %arg1[%arg12 * 64 + %arg13 * 16 + 15] {max_mux_size = 128 : i64, partition_indices = [-1], timing = #hlscpp.t<33 -> 34, 1, 1>} : memref<4096xf64, affine_map<(d0) -> (d0 floordiv 32, d0 mod 32)>, 1>
    } {loop_directive = #hlscpp.ld<pipeline=true, targetII=1, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=4, iterLatency=34, minII=16>, timing = #hlscpp.t<376 -> 460, 84, 84>}
  } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=256, iterLatency=34, minII=16>, timing = #hlscpp.t<25606 -> 29722, 4116, 4116>}
  affine.for %arg12 = 0 to 8 {
    %30 = affine.load %arg7[%arg12 * 8] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %31 = arith.divf %30, %19 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %31, %arg7[%arg12 * 8] {partition_indices = [0], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %32 = affine.load %arg7[%arg12 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %33 = arith.divf %32, %19 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %33, %arg7[%arg12 * 8 + 1] {partition_indices = [1], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %34 = affine.load %arg7[%arg12 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %35 = arith.divf %34, %19 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %35, %arg7[%arg12 * 8 + 2] {partition_indices = [2], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %36 = affine.load %arg7[%arg12 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %37 = arith.divf %36, %19 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %37, %arg7[%arg12 * 8 + 3] {partition_indices = [3], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %38 = affine.load %arg7[%arg12 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %39 = arith.divf %38, %19 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %39, %arg7[%arg12 * 8 + 4] {partition_indices = [4], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %40 = affine.load %arg7[%arg12 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %41 = arith.divf %40, %19 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %41, %arg7[%arg12 * 8 + 5] {partition_indices = [5], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %42 = affine.load %arg7[%arg12 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %43 = arith.divf %42, %19 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %43, %arg7[%arg12 * 8 + 6] {partition_indices = [6], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %44 = affine.load %arg7[%arg12 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
    %45 = arith.divf %44, %19 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %45, %arg7[%arg12 * 8 + 7] {partition_indices = [7], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<64xf64, affine_map<(d0) -> (d0 mod 8, d0 floordiv 8)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=1, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=8, iterLatency=19, minII=1>, timing = #hlscpp.t<29722 -> 29750, 28, 28>}
  %20 = memref.alloc() {timing = #hlscpp.t<29750 -> 29750, 0, 0>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  affine.store %cst_0, %20[0] {partition_indices = [0], timing = #hlscpp.t<29750 -> 29751, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  %21 = memref.alloc() {timing = #hlscpp.t<29750 -> 29750, 0, 0>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  affine.store %cst_0, %21[0] {partition_indices = [0], timing = #hlscpp.t<29750 -> 29751, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  %22 = memref.alloc() {timing = #hlscpp.t<29751 -> 29751, 0, 0>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  %23 = memref.alloc() {timing = #hlscpp.t<29751 -> 29751, 0, 0>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  affine.for %arg12 = 0 to 16 {
    %30 = affine.load %arg5[%arg12 * 12] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 12, d0 floordiv 12)>, 1>
    %31 = arith.mulf %30, %cst {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %32 = affine.load %arg2[%arg12 * 12] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<3 -> 5, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %33 = arith.subf %32, %31 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    affine.store %33, %arg2[%arg12 * 12] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<64 -> 65, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %34 = arith.mulf %33, %33 {timing = #hlscpp.t<11 -> 15, 4, 1>} : f64
    %35 = affine.load %arg5[%arg12 * 12 + 1] {partition_indices = [1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 12, d0 floordiv 12)>, 1>
    %36 = arith.mulf %35, %cst {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %37 = affine.load %arg2[%arg12 * 12 + 1] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %38 = arith.subf %37, %36 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    affine.store %38, %arg2[%arg12 * 12 + 1] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<65 -> 66, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %39 = arith.mulf %38, %38 {timing = #hlscpp.t<11 -> 15, 4, 1>} : f64
    %40 = arith.addf %34, %39 {timing = #hlscpp.t<15 -> 20, 5, 1>} : f64
    %41 = affine.load %arg5[%arg12 * 12 + 2] {partition_indices = [2], timing = #hlscpp.t<5 -> 7, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 12, d0 floordiv 12)>, 1>
    %42 = arith.mulf %41, %cst {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %43 = affine.load %arg2[%arg12 * 12 + 2] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<9 -> 11, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %44 = arith.subf %43, %42 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    affine.store %44, %arg2[%arg12 * 12 + 2] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<66 -> 67, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %45 = arith.mulf %44, %44 {timing = #hlscpp.t<16 -> 20, 4, 1>} : f64
    %46 = arith.addf %40, %45 {timing = #hlscpp.t<20 -> 25, 5, 1>} : f64
    %47 = affine.load %arg5[%arg12 * 12 + 3] {partition_indices = [3], timing = #hlscpp.t<10 -> 12, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 12, d0 floordiv 12)>, 1>
    %48 = arith.mulf %47, %cst {timing = #hlscpp.t<12 -> 16, 4, 1>} : f64
    %49 = affine.load %arg2[%arg12 * 12 + 3] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<14 -> 16, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %50 = arith.subf %49, %48 {timing = #hlscpp.t<16 -> 21, 5, 1>} : f64
    affine.store %50, %arg2[%arg12 * 12 + 3] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<67 -> 68, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %51 = arith.mulf %50, %50 {timing = #hlscpp.t<21 -> 25, 4, 1>} : f64
    %52 = arith.addf %46, %51 {timing = #hlscpp.t<25 -> 30, 5, 1>} : f64
    %53 = affine.load %arg5[%arg12 * 12 + 4] {partition_indices = [4], timing = #hlscpp.t<15 -> 17, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 12, d0 floordiv 12)>, 1>
    %54 = arith.mulf %53, %cst {timing = #hlscpp.t<17 -> 21, 4, 1>} : f64
    %55 = affine.load %arg2[%arg12 * 12 + 4] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<19 -> 21, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %56 = arith.subf %55, %54 {timing = #hlscpp.t<21 -> 26, 5, 1>} : f64
    affine.store %56, %arg2[%arg12 * 12 + 4] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<68 -> 69, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %57 = arith.mulf %56, %56 {timing = #hlscpp.t<26 -> 30, 4, 1>} : f64
    %58 = arith.addf %52, %57 {timing = #hlscpp.t<30 -> 35, 5, 1>} : f64
    %59 = affine.load %arg5[%arg12 * 12 + 5] {partition_indices = [5], timing = #hlscpp.t<20 -> 22, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 12, d0 floordiv 12)>, 1>
    %60 = arith.mulf %59, %cst {timing = #hlscpp.t<22 -> 26, 4, 1>} : f64
    %61 = affine.load %arg2[%arg12 * 12 + 5] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<24 -> 26, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %62 = arith.subf %61, %60 {timing = #hlscpp.t<26 -> 31, 5, 1>} : f64
    affine.store %62, %arg2[%arg12 * 12 + 5] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<69 -> 70, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %63 = arith.mulf %62, %62 {timing = #hlscpp.t<31 -> 35, 4, 1>} : f64
    %64 = arith.addf %58, %63 {timing = #hlscpp.t<35 -> 40, 5, 1>} : f64
    %65 = affine.load %arg5[%arg12 * 12 + 6] {partition_indices = [6], timing = #hlscpp.t<25 -> 27, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 12, d0 floordiv 12)>, 1>
    %66 = arith.mulf %65, %cst {timing = #hlscpp.t<27 -> 31, 4, 1>} : f64
    %67 = affine.load %arg2[%arg12 * 12 + 6] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<29 -> 31, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %68 = arith.subf %67, %66 {timing = #hlscpp.t<31 -> 36, 5, 1>} : f64
    affine.store %68, %arg2[%arg12 * 12 + 6] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<70 -> 71, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %69 = arith.mulf %68, %68 {timing = #hlscpp.t<36 -> 40, 4, 1>} : f64
    %70 = arith.addf %64, %69 {timing = #hlscpp.t<40 -> 45, 5, 1>} : f64
    %71 = affine.load %arg5[%arg12 * 12 + 7] {partition_indices = [7], timing = #hlscpp.t<30 -> 32, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 12, d0 floordiv 12)>, 1>
    %72 = arith.mulf %71, %cst {timing = #hlscpp.t<32 -> 36, 4, 1>} : f64
    %73 = affine.load %arg2[%arg12 * 12 + 7] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<34 -> 36, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %74 = arith.subf %73, %72 {timing = #hlscpp.t<36 -> 41, 5, 1>} : f64
    affine.store %74, %arg2[%arg12 * 12 + 7] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<71 -> 72, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %75 = arith.mulf %74, %74 {timing = #hlscpp.t<41 -> 45, 4, 1>} : f64
    %76 = arith.addf %70, %75 {timing = #hlscpp.t<45 -> 50, 5, 1>} : f64
    %77 = affine.load %arg5[%arg12 * 12 + 8] {partition_indices = [8], timing = #hlscpp.t<35 -> 37, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 12, d0 floordiv 12)>, 1>
    %78 = arith.mulf %77, %cst {timing = #hlscpp.t<37 -> 41, 4, 1>} : f64
    %79 = affine.load %arg2[%arg12 * 12 + 8] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<39 -> 41, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %80 = arith.subf %79, %78 {timing = #hlscpp.t<41 -> 46, 5, 1>} : f64
    affine.store %80, %arg2[%arg12 * 12 + 8] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<72 -> 73, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %81 = arith.mulf %80, %80 {timing = #hlscpp.t<46 -> 50, 4, 1>} : f64
    %82 = arith.addf %76, %81 {timing = #hlscpp.t<50 -> 55, 5, 1>} : f64
    %83 = affine.load %arg5[%arg12 * 12 + 9] {partition_indices = [9], timing = #hlscpp.t<40 -> 42, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 12, d0 floordiv 12)>, 1>
    %84 = arith.mulf %83, %cst {timing = #hlscpp.t<42 -> 46, 4, 1>} : f64
    %85 = affine.load %arg2[%arg12 * 12 + 9] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<44 -> 46, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %86 = arith.subf %85, %84 {timing = #hlscpp.t<46 -> 51, 5, 1>} : f64
    affine.store %86, %arg2[%arg12 * 12 + 9] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<73 -> 74, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %87 = arith.mulf %86, %86 {timing = #hlscpp.t<51 -> 55, 4, 1>} : f64
    %88 = arith.addf %82, %87 {timing = #hlscpp.t<55 -> 60, 5, 1>} : f64
    %89 = affine.load %arg5[%arg12 * 12 + 10] {partition_indices = [10], timing = #hlscpp.t<45 -> 47, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 12, d0 floordiv 12)>, 1>
    %90 = arith.mulf %89, %cst {timing = #hlscpp.t<47 -> 51, 4, 1>} : f64
    %91 = affine.load %arg2[%arg12 * 12 + 10] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<49 -> 51, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %92 = arith.subf %91, %90 {timing = #hlscpp.t<51 -> 56, 5, 1>} : f64
    affine.store %92, %arg2[%arg12 * 12 + 10] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<74 -> 75, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %93 = arith.mulf %92, %92 {timing = #hlscpp.t<56 -> 60, 4, 1>} : f64
    %94 = arith.addf %88, %93 {timing = #hlscpp.t<60 -> 65, 5, 1>} : f64
    %95 = affine.load %arg5[%arg12 * 12 + 11] {partition_indices = [11], timing = #hlscpp.t<50 -> 52, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 12, d0 floordiv 12)>, 1>
    %96 = arith.mulf %95, %cst {timing = #hlscpp.t<52 -> 56, 4, 1>} : f64
    %97 = affine.load %arg2[%arg12 * 12 + 11] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<54 -> 56, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %98 = arith.subf %97, %96 {timing = #hlscpp.t<56 -> 61, 5, 1>} : f64
    affine.store %98, %arg2[%arg12 * 12 + 11] {max_mux_size = 24 : i64, partition_indices = [-1], timing = #hlscpp.t<75 -> 76, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %99 = arith.mulf %98, %98 {timing = #hlscpp.t<61 -> 65, 4, 1>} : f64
    %100 = arith.addf %94, %99 {timing = #hlscpp.t<65 -> 70, 5, 1>} : f64
    %101 = affine.load %20[0] {partition_indices = [0], timing = #hlscpp.t<69 -> 70, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
    %102 = arith.addf %101, %100 {timing = #hlscpp.t<70 -> 75, 5, 1>} : f64
    affine.store %102, %22[0] {partition_indices = [0], timing = #hlscpp.t<75 -> 76, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
    affine.store %102, %23[0] {partition_indices = [0], timing = #hlscpp.t<75 -> 76, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
    affine.store %102, %20[0] {partition_indices = [0], timing = #hlscpp.t<75 -> 76, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
    affine.store %102, %21[0] {partition_indices = [0], timing = #hlscpp.t<75 -> 76, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=7, dataflow=false, flatten=false, parallel=false>, loop_info = #hlscpp.l<flattenTripCount=16, iterLatency=76, minII=12>, timing = #hlscpp.t<29751 -> 30009, 258, 258>}
  %24 = affine.load %21[0] {partition_indices = [0], timing = #hlscpp.t<30046 -> 30047, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  %25 = memref.alloc() {timing = #hlscpp.t<30009 -> 30009, 0, 0>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  affine.store %cst_0, %25[0] {partition_indices = [0], timing = #hlscpp.t<30009 -> 30010, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  %26 = memref.alloc() {timing = #hlscpp.t<30009 -> 30009, 0, 0>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  affine.store %cst_0, %26[0] {partition_indices = [0], timing = #hlscpp.t<30009 -> 30010, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  affine.for %arg12 = 0 to 3 {
    %30 = affine.load %25[0] {partition_indices = [0], timing = #hlscpp.t<14 -> 15, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
    %31 = affine.load %arg11[%arg12] {max_mux_size = 1 : i64, partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<3xf64, affine_map<(d0) -> (0, d0)>, 1>
    %32 = arith.mulf %31, %cst {timing = #hlscpp.t<2 -> 6, 4, 1>} : f64
    %33 = affine.load %arg8[%arg12] {max_mux_size = 1 : i64, partition_indices = [0], timing = #hlscpp.t<4 -> 6, 2, 1>} : memref<3xf64, affine_map<(d0) -> (0, d0)>, 1>
    %34 = arith.subf %33, %32 {timing = #hlscpp.t<6 -> 11, 5, 1>} : f64
    affine.store %34, %arg8[%arg12] {max_mux_size = 1 : i64, partition_indices = [0], timing = #hlscpp.t<20 -> 21, 1, 1>} : memref<3xf64, affine_map<(d0) -> (0, d0)>, 1>
    %35 = arith.mulf %34, %34 {timing = #hlscpp.t<11 -> 15, 4, 1>} : f64
    %36 = arith.addf %30, %35 {timing = #hlscpp.t<15 -> 20, 5, 1>} : f64
    affine.store %36, %25[0] {partition_indices = [0], timing = #hlscpp.t<20 -> 21, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
    affine.store %36, %26[0] {partition_indices = [0], timing = #hlscpp.t<20 -> 21, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=7, dataflow=false, flatten=false, parallel=false>, loop_info = #hlscpp.l<flattenTripCount=3, iterLatency=21, minII=7>, timing = #hlscpp.t<30010 -> 30047, 37, 37>}
  %27 = affine.load %26[0] {partition_indices = [0], timing = #hlscpp.t<30074 -> 30075, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  %28 = math.sqrt %24 {timing = #hlscpp.t<30047 -> 30047, 0, 0>} : f64
  %29 = math.sqrt %27 {timing = #hlscpp.t<30075 -> 30075, 0, 0>} : f64
  affine.for %arg12 = 0 to 8 {
    %30 = affine.load %arg2[%arg12 * 24] {partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %31 = arith.divf %30, %28 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %31, %arg2[%arg12 * 24] {partition_indices = [0], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %32 = affine.load %arg2[%arg12 * 24 + 1] {partition_indices = [1], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %33 = arith.divf %32, %28 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %33, %arg2[%arg12 * 24 + 1] {partition_indices = [1], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %34 = affine.load %arg2[%arg12 * 24 + 2] {partition_indices = [2], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %35 = arith.divf %34, %28 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %35, %arg2[%arg12 * 24 + 2] {partition_indices = [2], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %36 = affine.load %arg2[%arg12 * 24 + 3] {partition_indices = [3], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %37 = arith.divf %36, %28 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %37, %arg2[%arg12 * 24 + 3] {partition_indices = [3], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %38 = affine.load %arg2[%arg12 * 24 + 4] {partition_indices = [4], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %39 = arith.divf %38, %28 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %39, %arg2[%arg12 * 24 + 4] {partition_indices = [4], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %40 = affine.load %arg2[%arg12 * 24 + 5] {partition_indices = [5], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %41 = arith.divf %40, %28 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %41, %arg2[%arg12 * 24 + 5] {partition_indices = [5], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %42 = affine.load %arg2[%arg12 * 24 + 6] {partition_indices = [6], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %43 = arith.divf %42, %28 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %43, %arg2[%arg12 * 24 + 6] {partition_indices = [6], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %44 = affine.load %arg2[%arg12 * 24 + 7] {partition_indices = [7], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %45 = arith.divf %44, %28 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %45, %arg2[%arg12 * 24 + 7] {partition_indices = [7], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %46 = affine.load %arg2[%arg12 * 24 + 8] {partition_indices = [8], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %47 = arith.divf %46, %28 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %47, %arg2[%arg12 * 24 + 8] {partition_indices = [8], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %48 = affine.load %arg2[%arg12 * 24 + 9] {partition_indices = [9], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %49 = arith.divf %48, %28 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %49, %arg2[%arg12 * 24 + 9] {partition_indices = [9], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %50 = affine.load %arg2[%arg12 * 24 + 10] {partition_indices = [10], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %51 = arith.divf %50, %28 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %51, %arg2[%arg12 * 24 + 10] {partition_indices = [10], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %52 = affine.load %arg2[%arg12 * 24 + 11] {partition_indices = [11], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %53 = arith.divf %52, %28 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %53, %arg2[%arg12 * 24 + 11] {partition_indices = [11], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %54 = affine.load %arg2[%arg12 * 24 + 12] {partition_indices = [12], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %55 = arith.divf %54, %28 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %55, %arg2[%arg12 * 24 + 12] {partition_indices = [12], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %56 = affine.load %arg2[%arg12 * 24 + 13] {partition_indices = [13], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %57 = arith.divf %56, %28 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %57, %arg2[%arg12 * 24 + 13] {partition_indices = [13], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %58 = affine.load %arg2[%arg12 * 24 + 14] {partition_indices = [14], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %59 = arith.divf %58, %28 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %59, %arg2[%arg12 * 24 + 14] {partition_indices = [14], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %60 = affine.load %arg2[%arg12 * 24 + 15] {partition_indices = [15], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %61 = arith.divf %60, %28 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %61, %arg2[%arg12 * 24 + 15] {partition_indices = [15], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %62 = affine.load %arg2[%arg12 * 24 + 16] {partition_indices = [16], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %63 = arith.divf %62, %28 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %63, %arg2[%arg12 * 24 + 16] {partition_indices = [16], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %64 = affine.load %arg2[%arg12 * 24 + 17] {partition_indices = [17], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %65 = arith.divf %64, %28 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %65, %arg2[%arg12 * 24 + 17] {partition_indices = [17], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %66 = affine.load %arg2[%arg12 * 24 + 18] {partition_indices = [18], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %67 = arith.divf %66, %28 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %67, %arg2[%arg12 * 24 + 18] {partition_indices = [18], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %68 = affine.load %arg2[%arg12 * 24 + 19] {partition_indices = [19], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %69 = arith.divf %68, %28 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %69, %arg2[%arg12 * 24 + 19] {partition_indices = [19], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %70 = affine.load %arg2[%arg12 * 24 + 20] {partition_indices = [20], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %71 = arith.divf %70, %28 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %71, %arg2[%arg12 * 24 + 20] {partition_indices = [20], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %72 = affine.load %arg2[%arg12 * 24 + 21] {partition_indices = [21], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %73 = arith.divf %72, %28 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %73, %arg2[%arg12 * 24 + 21] {partition_indices = [21], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %74 = affine.load %arg2[%arg12 * 24 + 22] {partition_indices = [22], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %75 = arith.divf %74, %28 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %75, %arg2[%arg12 * 24 + 22] {partition_indices = [22], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %76 = affine.load %arg2[%arg12 * 24 + 23] {partition_indices = [23], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
    %77 = arith.divf %76, %28 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %77, %arg2[%arg12 * 24 + 23] {partition_indices = [23], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<192xf64, affine_map<(d0) -> (d0 mod 24, d0 floordiv 24)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=1, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=8, iterLatency=19, minII=1>, timing = #hlscpp.t<30047 -> 30075, 28, 28>}
  affine.for %arg12 = 0 to 3 {
    %30 = affine.load %arg8[%arg12] {max_mux_size = 1 : i64, partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<3xf64, affine_map<(d0) -> (0, d0)>, 1>
    %31 = arith.divf %30, %29 {timing = #hlscpp.t<2 -> 18, 16, 1>} : f64
    affine.store %31, %arg8[%arg12] {max_mux_size = 1 : i64, partition_indices = [0], timing = #hlscpp.t<18 -> 19, 1, 1>} : memref<3xf64, affine_map<(d0) -> (0, d0)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=1, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=3, iterLatency=19, minII=1>, timing = #hlscpp.t<30075 -> 30098, 23, 23>}
  return {timing = #hlscpp.t<30098 -> 30098, 0, 0>}
}
