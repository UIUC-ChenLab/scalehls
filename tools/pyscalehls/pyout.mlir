#map0 = affine_map<(d0, d1) -> (d0 mod 5, 0, d0 floordiv 5, d1)>
#map1 = affine_map<(d0, d1) -> (0, d1 mod 10, d0, d1 floordiv 10)>
#map2 = affine_map<(d0, d1) -> (d0 mod 8, 0, d0 floordiv 8, d1)>
#map3 = affine_map<(d0, d1) -> (d0 mod 5, d1 mod 14, d0 floordiv 5, d1 floordiv 14)>
#map4 = affine_map<(d0, d1) -> (d0 mod 8, d1 mod 14, d0 floordiv 8, d1 floordiv 14)>
module attributes {dlti.dl_spec = #dlti.dl_spec<#dlti.dl_entry<"dlti.endianness", "little">, #dlti.dl_entry<i64, dense<64> : vector<2xi32>>, #dlti.dl_entry<f80, dense<128> : vector<2xi32>>, #dlti.dl_entry<i1, dense<8> : vector<2xi32>>, #dlti.dl_entry<i8, dense<8> : vector<2xi32>>, #dlti.dl_entry<i16, dense<16> : vector<2xi32>>, #dlti.dl_entry<i32, dense<32> : vector<2xi32>>, #dlti.dl_entry<f16, dense<16> : vector<2xi32>>, #dlti.dl_entry<f64, dense<64> : vector<2xi32>>, #dlti.dl_entry<f128, dense<128> : vector<2xi32>>>, llvm.data_layout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128", llvm.target_triple = "x86_64-unknown-linux-gnu"} {
  func @kernel_3mm(%arg0: memref<40x60xf32>, %arg1: memref<60x50xf32>, %arg2: memref<50x80xf32, #map0>, %arg3: memref<80x70xf32, #map1>, %arg4: memref<40x50xf32, #map2>, %arg5: memref<50x70xf32, #map3>, %arg6: memref<40x70xf32, #map4>) attributes {llvm.linkage = #llvm.linkage<external>, top_func} {
    %cst = arith.constant 0.000000e+00 : f32
    affine.for %arg7 = 0 to 80 {
      affine.for %arg8 = 0 to 10 {
        affine.for %arg9 = 0 to 7 {
          affine.store %cst, %arg5[%arg8 * 5, %arg9 * 10] : memref<50x70xf32, #map3>
          %0 = affine.load %arg2[%arg8 * 5, %arg7] : memref<50x80xf32, #map0>
          %1 = affine.load %arg3[%arg7, %arg9 * 10] : memref<80x70xf32, #map1>
          %2 = arith.mulf %0, %1 : f32
          %3 = affine.load %arg5[%arg8 * 5, %arg9 * 10] : memref<50x70xf32, #map3>
          %4 = arith.addf %3, %2 : f32
          affine.store %4, %arg5[%arg8 * 5, %arg9 * 10] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5, %arg9 * 10 + 1] : memref<50x70xf32, #map3>
          %5 = affine.load %arg2[%arg8 * 5, %arg7] : memref<50x80xf32, #map0>
          %6 = affine.load %arg3[%arg7, %arg9 * 10 + 1] : memref<80x70xf32, #map1>
          %7 = arith.mulf %5, %6 : f32
          %8 = affine.load %arg5[%arg8 * 5, %arg9 * 10 + 1] : memref<50x70xf32, #map3>
          %9 = arith.addf %8, %7 : f32
          affine.store %9, %arg5[%arg8 * 5, %arg9 * 10 + 1] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5, %arg9 * 10 + 2] : memref<50x70xf32, #map3>
          %10 = affine.load %arg2[%arg8 * 5, %arg7] : memref<50x80xf32, #map0>
          %11 = affine.load %arg3[%arg7, %arg9 * 10 + 2] : memref<80x70xf32, #map1>
          %12 = arith.mulf %10, %11 : f32
          %13 = affine.load %arg5[%arg8 * 5, %arg9 * 10 + 2] : memref<50x70xf32, #map3>
          %14 = arith.addf %13, %12 : f32
          affine.store %14, %arg5[%arg8 * 5, %arg9 * 10 + 2] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5, %arg9 * 10 + 3] : memref<50x70xf32, #map3>
          %15 = affine.load %arg2[%arg8 * 5, %arg7] : memref<50x80xf32, #map0>
          %16 = affine.load %arg3[%arg7, %arg9 * 10 + 3] : memref<80x70xf32, #map1>
          %17 = arith.mulf %15, %16 : f32
          %18 = affine.load %arg5[%arg8 * 5, %arg9 * 10 + 3] : memref<50x70xf32, #map3>
          %19 = arith.addf %18, %17 : f32
          affine.store %19, %arg5[%arg8 * 5, %arg9 * 10 + 3] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5, %arg9 * 10 + 4] : memref<50x70xf32, #map3>
          %20 = affine.load %arg2[%arg8 * 5, %arg7] : memref<50x80xf32, #map0>
          %21 = affine.load %arg3[%arg7, %arg9 * 10 + 4] : memref<80x70xf32, #map1>
          %22 = arith.mulf %20, %21 : f32
          %23 = affine.load %arg5[%arg8 * 5, %arg9 * 10 + 4] : memref<50x70xf32, #map3>
          %24 = arith.addf %23, %22 : f32
          affine.store %24, %arg5[%arg8 * 5, %arg9 * 10 + 4] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5, %arg9 * 10 + 5] : memref<50x70xf32, #map3>
          %25 = affine.load %arg2[%arg8 * 5, %arg7] : memref<50x80xf32, #map0>
          %26 = affine.load %arg3[%arg7, %arg9 * 10 + 5] : memref<80x70xf32, #map1>
          %27 = arith.mulf %25, %26 : f32
          %28 = affine.load %arg5[%arg8 * 5, %arg9 * 10 + 5] : memref<50x70xf32, #map3>
          %29 = arith.addf %28, %27 : f32
          affine.store %29, %arg5[%arg8 * 5, %arg9 * 10 + 5] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5, %arg9 * 10 + 6] : memref<50x70xf32, #map3>
          %30 = affine.load %arg2[%arg8 * 5, %arg7] : memref<50x80xf32, #map0>
          %31 = affine.load %arg3[%arg7, %arg9 * 10 + 6] : memref<80x70xf32, #map1>
          %32 = arith.mulf %30, %31 : f32
          %33 = affine.load %arg5[%arg8 * 5, %arg9 * 10 + 6] : memref<50x70xf32, #map3>
          %34 = arith.addf %33, %32 : f32
          affine.store %34, %arg5[%arg8 * 5, %arg9 * 10 + 6] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5, %arg9 * 10 + 7] : memref<50x70xf32, #map3>
          %35 = affine.load %arg2[%arg8 * 5, %arg7] : memref<50x80xf32, #map0>
          %36 = affine.load %arg3[%arg7, %arg9 * 10 + 7] : memref<80x70xf32, #map1>
          %37 = arith.mulf %35, %36 : f32
          %38 = affine.load %arg5[%arg8 * 5, %arg9 * 10 + 7] : memref<50x70xf32, #map3>
          %39 = arith.addf %38, %37 : f32
          affine.store %39, %arg5[%arg8 * 5, %arg9 * 10 + 7] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5, %arg9 * 10 + 8] : memref<50x70xf32, #map3>
          %40 = affine.load %arg2[%arg8 * 5, %arg7] : memref<50x80xf32, #map0>
          %41 = affine.load %arg3[%arg7, %arg9 * 10 + 8] : memref<80x70xf32, #map1>
          %42 = arith.mulf %40, %41 : f32
          %43 = affine.load %arg5[%arg8 * 5, %arg9 * 10 + 8] : memref<50x70xf32, #map3>
          %44 = arith.addf %43, %42 : f32
          affine.store %44, %arg5[%arg8 * 5, %arg9 * 10 + 8] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5, %arg9 * 10 + 9] : memref<50x70xf32, #map3>
          %45 = affine.load %arg2[%arg8 * 5, %arg7] : memref<50x80xf32, #map0>
          %46 = affine.load %arg3[%arg7, %arg9 * 10 + 9] : memref<80x70xf32, #map1>
          %47 = arith.mulf %45, %46 : f32
          %48 = affine.load %arg5[%arg8 * 5, %arg9 * 10 + 9] : memref<50x70xf32, #map3>
          %49 = arith.addf %48, %47 : f32
          affine.store %49, %arg5[%arg8 * 5, %arg9 * 10 + 9] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 1, %arg9 * 10] : memref<50x70xf32, #map3>
          %50 = affine.load %arg2[%arg8 * 5 + 1, %arg7] : memref<50x80xf32, #map0>
          %51 = affine.load %arg3[%arg7, %arg9 * 10] : memref<80x70xf32, #map1>
          %52 = arith.mulf %50, %51 : f32
          %53 = affine.load %arg5[%arg8 * 5 + 1, %arg9 * 10] : memref<50x70xf32, #map3>
          %54 = arith.addf %53, %52 : f32
          affine.store %54, %arg5[%arg8 * 5 + 1, %arg9 * 10] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 1, %arg9 * 10 + 1] : memref<50x70xf32, #map3>
          %55 = affine.load %arg2[%arg8 * 5 + 1, %arg7] : memref<50x80xf32, #map0>
          %56 = affine.load %arg3[%arg7, %arg9 * 10 + 1] : memref<80x70xf32, #map1>
          %57 = arith.mulf %55, %56 : f32
          %58 = affine.load %arg5[%arg8 * 5 + 1, %arg9 * 10 + 1] : memref<50x70xf32, #map3>
          %59 = arith.addf %58, %57 : f32
          affine.store %59, %arg5[%arg8 * 5 + 1, %arg9 * 10 + 1] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 1, %arg9 * 10 + 2] : memref<50x70xf32, #map3>
          %60 = affine.load %arg2[%arg8 * 5 + 1, %arg7] : memref<50x80xf32, #map0>
          %61 = affine.load %arg3[%arg7, %arg9 * 10 + 2] : memref<80x70xf32, #map1>
          %62 = arith.mulf %60, %61 : f32
          %63 = affine.load %arg5[%arg8 * 5 + 1, %arg9 * 10 + 2] : memref<50x70xf32, #map3>
          %64 = arith.addf %63, %62 : f32
          affine.store %64, %arg5[%arg8 * 5 + 1, %arg9 * 10 + 2] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 1, %arg9 * 10 + 3] : memref<50x70xf32, #map3>
          %65 = affine.load %arg2[%arg8 * 5 + 1, %arg7] : memref<50x80xf32, #map0>
          %66 = affine.load %arg3[%arg7, %arg9 * 10 + 3] : memref<80x70xf32, #map1>
          %67 = arith.mulf %65, %66 : f32
          %68 = affine.load %arg5[%arg8 * 5 + 1, %arg9 * 10 + 3] : memref<50x70xf32, #map3>
          %69 = arith.addf %68, %67 : f32
          affine.store %69, %arg5[%arg8 * 5 + 1, %arg9 * 10 + 3] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 1, %arg9 * 10 + 4] : memref<50x70xf32, #map3>
          %70 = affine.load %arg2[%arg8 * 5 + 1, %arg7] : memref<50x80xf32, #map0>
          %71 = affine.load %arg3[%arg7, %arg9 * 10 + 4] : memref<80x70xf32, #map1>
          %72 = arith.mulf %70, %71 : f32
          %73 = affine.load %arg5[%arg8 * 5 + 1, %arg9 * 10 + 4] : memref<50x70xf32, #map3>
          %74 = arith.addf %73, %72 : f32
          affine.store %74, %arg5[%arg8 * 5 + 1, %arg9 * 10 + 4] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 1, %arg9 * 10 + 5] : memref<50x70xf32, #map3>
          %75 = affine.load %arg2[%arg8 * 5 + 1, %arg7] : memref<50x80xf32, #map0>
          %76 = affine.load %arg3[%arg7, %arg9 * 10 + 5] : memref<80x70xf32, #map1>
          %77 = arith.mulf %75, %76 : f32
          %78 = affine.load %arg5[%arg8 * 5 + 1, %arg9 * 10 + 5] : memref<50x70xf32, #map3>
          %79 = arith.addf %78, %77 : f32
          affine.store %79, %arg5[%arg8 * 5 + 1, %arg9 * 10 + 5] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 1, %arg9 * 10 + 6] : memref<50x70xf32, #map3>
          %80 = affine.load %arg2[%arg8 * 5 + 1, %arg7] : memref<50x80xf32, #map0>
          %81 = affine.load %arg3[%arg7, %arg9 * 10 + 6] : memref<80x70xf32, #map1>
          %82 = arith.mulf %80, %81 : f32
          %83 = affine.load %arg5[%arg8 * 5 + 1, %arg9 * 10 + 6] : memref<50x70xf32, #map3>
          %84 = arith.addf %83, %82 : f32
          affine.store %84, %arg5[%arg8 * 5 + 1, %arg9 * 10 + 6] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 1, %arg9 * 10 + 7] : memref<50x70xf32, #map3>
          %85 = affine.load %arg2[%arg8 * 5 + 1, %arg7] : memref<50x80xf32, #map0>
          %86 = affine.load %arg3[%arg7, %arg9 * 10 + 7] : memref<80x70xf32, #map1>
          %87 = arith.mulf %85, %86 : f32
          %88 = affine.load %arg5[%arg8 * 5 + 1, %arg9 * 10 + 7] : memref<50x70xf32, #map3>
          %89 = arith.addf %88, %87 : f32
          affine.store %89, %arg5[%arg8 * 5 + 1, %arg9 * 10 + 7] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 1, %arg9 * 10 + 8] : memref<50x70xf32, #map3>
          %90 = affine.load %arg2[%arg8 * 5 + 1, %arg7] : memref<50x80xf32, #map0>
          %91 = affine.load %arg3[%arg7, %arg9 * 10 + 8] : memref<80x70xf32, #map1>
          %92 = arith.mulf %90, %91 : f32
          %93 = affine.load %arg5[%arg8 * 5 + 1, %arg9 * 10 + 8] : memref<50x70xf32, #map3>
          %94 = arith.addf %93, %92 : f32
          affine.store %94, %arg5[%arg8 * 5 + 1, %arg9 * 10 + 8] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 1, %arg9 * 10 + 9] : memref<50x70xf32, #map3>
          %95 = affine.load %arg2[%arg8 * 5 + 1, %arg7] : memref<50x80xf32, #map0>
          %96 = affine.load %arg3[%arg7, %arg9 * 10 + 9] : memref<80x70xf32, #map1>
          %97 = arith.mulf %95, %96 : f32
          %98 = affine.load %arg5[%arg8 * 5 + 1, %arg9 * 10 + 9] : memref<50x70xf32, #map3>
          %99 = arith.addf %98, %97 : f32
          affine.store %99, %arg5[%arg8 * 5 + 1, %arg9 * 10 + 9] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 2, %arg9 * 10] : memref<50x70xf32, #map3>
          %100 = affine.load %arg2[%arg8 * 5 + 2, %arg7] : memref<50x80xf32, #map0>
          %101 = affine.load %arg3[%arg7, %arg9 * 10] : memref<80x70xf32, #map1>
          %102 = arith.mulf %100, %101 : f32
          %103 = affine.load %arg5[%arg8 * 5 + 2, %arg9 * 10] : memref<50x70xf32, #map3>
          %104 = arith.addf %103, %102 : f32
          affine.store %104, %arg5[%arg8 * 5 + 2, %arg9 * 10] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 2, %arg9 * 10 + 1] : memref<50x70xf32, #map3>
          %105 = affine.load %arg2[%arg8 * 5 + 2, %arg7] : memref<50x80xf32, #map0>
          %106 = affine.load %arg3[%arg7, %arg9 * 10 + 1] : memref<80x70xf32, #map1>
          %107 = arith.mulf %105, %106 : f32
          %108 = affine.load %arg5[%arg8 * 5 + 2, %arg9 * 10 + 1] : memref<50x70xf32, #map3>
          %109 = arith.addf %108, %107 : f32
          affine.store %109, %arg5[%arg8 * 5 + 2, %arg9 * 10 + 1] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 2, %arg9 * 10 + 2] : memref<50x70xf32, #map3>
          %110 = affine.load %arg2[%arg8 * 5 + 2, %arg7] : memref<50x80xf32, #map0>
          %111 = affine.load %arg3[%arg7, %arg9 * 10 + 2] : memref<80x70xf32, #map1>
          %112 = arith.mulf %110, %111 : f32
          %113 = affine.load %arg5[%arg8 * 5 + 2, %arg9 * 10 + 2] : memref<50x70xf32, #map3>
          %114 = arith.addf %113, %112 : f32
          affine.store %114, %arg5[%arg8 * 5 + 2, %arg9 * 10 + 2] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 2, %arg9 * 10 + 3] : memref<50x70xf32, #map3>
          %115 = affine.load %arg2[%arg8 * 5 + 2, %arg7] : memref<50x80xf32, #map0>
          %116 = affine.load %arg3[%arg7, %arg9 * 10 + 3] : memref<80x70xf32, #map1>
          %117 = arith.mulf %115, %116 : f32
          %118 = affine.load %arg5[%arg8 * 5 + 2, %arg9 * 10 + 3] : memref<50x70xf32, #map3>
          %119 = arith.addf %118, %117 : f32
          affine.store %119, %arg5[%arg8 * 5 + 2, %arg9 * 10 + 3] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 2, %arg9 * 10 + 4] : memref<50x70xf32, #map3>
          %120 = affine.load %arg2[%arg8 * 5 + 2, %arg7] : memref<50x80xf32, #map0>
          %121 = affine.load %arg3[%arg7, %arg9 * 10 + 4] : memref<80x70xf32, #map1>
          %122 = arith.mulf %120, %121 : f32
          %123 = affine.load %arg5[%arg8 * 5 + 2, %arg9 * 10 + 4] : memref<50x70xf32, #map3>
          %124 = arith.addf %123, %122 : f32
          affine.store %124, %arg5[%arg8 * 5 + 2, %arg9 * 10 + 4] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 2, %arg9 * 10 + 5] : memref<50x70xf32, #map3>
          %125 = affine.load %arg2[%arg8 * 5 + 2, %arg7] : memref<50x80xf32, #map0>
          %126 = affine.load %arg3[%arg7, %arg9 * 10 + 5] : memref<80x70xf32, #map1>
          %127 = arith.mulf %125, %126 : f32
          %128 = affine.load %arg5[%arg8 * 5 + 2, %arg9 * 10 + 5] : memref<50x70xf32, #map3>
          %129 = arith.addf %128, %127 : f32
          affine.store %129, %arg5[%arg8 * 5 + 2, %arg9 * 10 + 5] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 2, %arg9 * 10 + 6] : memref<50x70xf32, #map3>
          %130 = affine.load %arg2[%arg8 * 5 + 2, %arg7] : memref<50x80xf32, #map0>
          %131 = affine.load %arg3[%arg7, %arg9 * 10 + 6] : memref<80x70xf32, #map1>
          %132 = arith.mulf %130, %131 : f32
          %133 = affine.load %arg5[%arg8 * 5 + 2, %arg9 * 10 + 6] : memref<50x70xf32, #map3>
          %134 = arith.addf %133, %132 : f32
          affine.store %134, %arg5[%arg8 * 5 + 2, %arg9 * 10 + 6] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 2, %arg9 * 10 + 7] : memref<50x70xf32, #map3>
          %135 = affine.load %arg2[%arg8 * 5 + 2, %arg7] : memref<50x80xf32, #map0>
          %136 = affine.load %arg3[%arg7, %arg9 * 10 + 7] : memref<80x70xf32, #map1>
          %137 = arith.mulf %135, %136 : f32
          %138 = affine.load %arg5[%arg8 * 5 + 2, %arg9 * 10 + 7] : memref<50x70xf32, #map3>
          %139 = arith.addf %138, %137 : f32
          affine.store %139, %arg5[%arg8 * 5 + 2, %arg9 * 10 + 7] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 2, %arg9 * 10 + 8] : memref<50x70xf32, #map3>
          %140 = affine.load %arg2[%arg8 * 5 + 2, %arg7] : memref<50x80xf32, #map0>
          %141 = affine.load %arg3[%arg7, %arg9 * 10 + 8] : memref<80x70xf32, #map1>
          %142 = arith.mulf %140, %141 : f32
          %143 = affine.load %arg5[%arg8 * 5 + 2, %arg9 * 10 + 8] : memref<50x70xf32, #map3>
          %144 = arith.addf %143, %142 : f32
          affine.store %144, %arg5[%arg8 * 5 + 2, %arg9 * 10 + 8] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 2, %arg9 * 10 + 9] : memref<50x70xf32, #map3>
          %145 = affine.load %arg2[%arg8 * 5 + 2, %arg7] : memref<50x80xf32, #map0>
          %146 = affine.load %arg3[%arg7, %arg9 * 10 + 9] : memref<80x70xf32, #map1>
          %147 = arith.mulf %145, %146 : f32
          %148 = affine.load %arg5[%arg8 * 5 + 2, %arg9 * 10 + 9] : memref<50x70xf32, #map3>
          %149 = arith.addf %148, %147 : f32
          affine.store %149, %arg5[%arg8 * 5 + 2, %arg9 * 10 + 9] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 3, %arg9 * 10] : memref<50x70xf32, #map3>
          %150 = affine.load %arg2[%arg8 * 5 + 3, %arg7] : memref<50x80xf32, #map0>
          %151 = affine.load %arg3[%arg7, %arg9 * 10] : memref<80x70xf32, #map1>
          %152 = arith.mulf %150, %151 : f32
          %153 = affine.load %arg5[%arg8 * 5 + 3, %arg9 * 10] : memref<50x70xf32, #map3>
          %154 = arith.addf %153, %152 : f32
          affine.store %154, %arg5[%arg8 * 5 + 3, %arg9 * 10] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 3, %arg9 * 10 + 1] : memref<50x70xf32, #map3>
          %155 = affine.load %arg2[%arg8 * 5 + 3, %arg7] : memref<50x80xf32, #map0>
          %156 = affine.load %arg3[%arg7, %arg9 * 10 + 1] : memref<80x70xf32, #map1>
          %157 = arith.mulf %155, %156 : f32
          %158 = affine.load %arg5[%arg8 * 5 + 3, %arg9 * 10 + 1] : memref<50x70xf32, #map3>
          %159 = arith.addf %158, %157 : f32
          affine.store %159, %arg5[%arg8 * 5 + 3, %arg9 * 10 + 1] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 3, %arg9 * 10 + 2] : memref<50x70xf32, #map3>
          %160 = affine.load %arg2[%arg8 * 5 + 3, %arg7] : memref<50x80xf32, #map0>
          %161 = affine.load %arg3[%arg7, %arg9 * 10 + 2] : memref<80x70xf32, #map1>
          %162 = arith.mulf %160, %161 : f32
          %163 = affine.load %arg5[%arg8 * 5 + 3, %arg9 * 10 + 2] : memref<50x70xf32, #map3>
          %164 = arith.addf %163, %162 : f32
          affine.store %164, %arg5[%arg8 * 5 + 3, %arg9 * 10 + 2] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 3, %arg9 * 10 + 3] : memref<50x70xf32, #map3>
          %165 = affine.load %arg2[%arg8 * 5 + 3, %arg7] : memref<50x80xf32, #map0>
          %166 = affine.load %arg3[%arg7, %arg9 * 10 + 3] : memref<80x70xf32, #map1>
          %167 = arith.mulf %165, %166 : f32
          %168 = affine.load %arg5[%arg8 * 5 + 3, %arg9 * 10 + 3] : memref<50x70xf32, #map3>
          %169 = arith.addf %168, %167 : f32
          affine.store %169, %arg5[%arg8 * 5 + 3, %arg9 * 10 + 3] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 3, %arg9 * 10 + 4] : memref<50x70xf32, #map3>
          %170 = affine.load %arg2[%arg8 * 5 + 3, %arg7] : memref<50x80xf32, #map0>
          %171 = affine.load %arg3[%arg7, %arg9 * 10 + 4] : memref<80x70xf32, #map1>
          %172 = arith.mulf %170, %171 : f32
          %173 = affine.load %arg5[%arg8 * 5 + 3, %arg9 * 10 + 4] : memref<50x70xf32, #map3>
          %174 = arith.addf %173, %172 : f32
          affine.store %174, %arg5[%arg8 * 5 + 3, %arg9 * 10 + 4] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 3, %arg9 * 10 + 5] : memref<50x70xf32, #map3>
          %175 = affine.load %arg2[%arg8 * 5 + 3, %arg7] : memref<50x80xf32, #map0>
          %176 = affine.load %arg3[%arg7, %arg9 * 10 + 5] : memref<80x70xf32, #map1>
          %177 = arith.mulf %175, %176 : f32
          %178 = affine.load %arg5[%arg8 * 5 + 3, %arg9 * 10 + 5] : memref<50x70xf32, #map3>
          %179 = arith.addf %178, %177 : f32
          affine.store %179, %arg5[%arg8 * 5 + 3, %arg9 * 10 + 5] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 3, %arg9 * 10 + 6] : memref<50x70xf32, #map3>
          %180 = affine.load %arg2[%arg8 * 5 + 3, %arg7] : memref<50x80xf32, #map0>
          %181 = affine.load %arg3[%arg7, %arg9 * 10 + 6] : memref<80x70xf32, #map1>
          %182 = arith.mulf %180, %181 : f32
          %183 = affine.load %arg5[%arg8 * 5 + 3, %arg9 * 10 + 6] : memref<50x70xf32, #map3>
          %184 = arith.addf %183, %182 : f32
          affine.store %184, %arg5[%arg8 * 5 + 3, %arg9 * 10 + 6] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 3, %arg9 * 10 + 7] : memref<50x70xf32, #map3>
          %185 = affine.load %arg2[%arg8 * 5 + 3, %arg7] : memref<50x80xf32, #map0>
          %186 = affine.load %arg3[%arg7, %arg9 * 10 + 7] : memref<80x70xf32, #map1>
          %187 = arith.mulf %185, %186 : f32
          %188 = affine.load %arg5[%arg8 * 5 + 3, %arg9 * 10 + 7] : memref<50x70xf32, #map3>
          %189 = arith.addf %188, %187 : f32
          affine.store %189, %arg5[%arg8 * 5 + 3, %arg9 * 10 + 7] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 3, %arg9 * 10 + 8] : memref<50x70xf32, #map3>
          %190 = affine.load %arg2[%arg8 * 5 + 3, %arg7] : memref<50x80xf32, #map0>
          %191 = affine.load %arg3[%arg7, %arg9 * 10 + 8] : memref<80x70xf32, #map1>
          %192 = arith.mulf %190, %191 : f32
          %193 = affine.load %arg5[%arg8 * 5 + 3, %arg9 * 10 + 8] : memref<50x70xf32, #map3>
          %194 = arith.addf %193, %192 : f32
          affine.store %194, %arg5[%arg8 * 5 + 3, %arg9 * 10 + 8] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 3, %arg9 * 10 + 9] : memref<50x70xf32, #map3>
          %195 = affine.load %arg2[%arg8 * 5 + 3, %arg7] : memref<50x80xf32, #map0>
          %196 = affine.load %arg3[%arg7, %arg9 * 10 + 9] : memref<80x70xf32, #map1>
          %197 = arith.mulf %195, %196 : f32
          %198 = affine.load %arg5[%arg8 * 5 + 3, %arg9 * 10 + 9] : memref<50x70xf32, #map3>
          %199 = arith.addf %198, %197 : f32
          affine.store %199, %arg5[%arg8 * 5 + 3, %arg9 * 10 + 9] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 4, %arg9 * 10] : memref<50x70xf32, #map3>
          %200 = affine.load %arg2[%arg8 * 5 + 4, %arg7] : memref<50x80xf32, #map0>
          %201 = affine.load %arg3[%arg7, %arg9 * 10] : memref<80x70xf32, #map1>
          %202 = arith.mulf %200, %201 : f32
          %203 = affine.load %arg5[%arg8 * 5 + 4, %arg9 * 10] : memref<50x70xf32, #map3>
          %204 = arith.addf %203, %202 : f32
          affine.store %204, %arg5[%arg8 * 5 + 4, %arg9 * 10] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 4, %arg9 * 10 + 1] : memref<50x70xf32, #map3>
          %205 = affine.load %arg2[%arg8 * 5 + 4, %arg7] : memref<50x80xf32, #map0>
          %206 = affine.load %arg3[%arg7, %arg9 * 10 + 1] : memref<80x70xf32, #map1>
          %207 = arith.mulf %205, %206 : f32
          %208 = affine.load %arg5[%arg8 * 5 + 4, %arg9 * 10 + 1] : memref<50x70xf32, #map3>
          %209 = arith.addf %208, %207 : f32
          affine.store %209, %arg5[%arg8 * 5 + 4, %arg9 * 10 + 1] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 4, %arg9 * 10 + 2] : memref<50x70xf32, #map3>
          %210 = affine.load %arg2[%arg8 * 5 + 4, %arg7] : memref<50x80xf32, #map0>
          %211 = affine.load %arg3[%arg7, %arg9 * 10 + 2] : memref<80x70xf32, #map1>
          %212 = arith.mulf %210, %211 : f32
          %213 = affine.load %arg5[%arg8 * 5 + 4, %arg9 * 10 + 2] : memref<50x70xf32, #map3>
          %214 = arith.addf %213, %212 : f32
          affine.store %214, %arg5[%arg8 * 5 + 4, %arg9 * 10 + 2] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 4, %arg9 * 10 + 3] : memref<50x70xf32, #map3>
          %215 = affine.load %arg2[%arg8 * 5 + 4, %arg7] : memref<50x80xf32, #map0>
          %216 = affine.load %arg3[%arg7, %arg9 * 10 + 3] : memref<80x70xf32, #map1>
          %217 = arith.mulf %215, %216 : f32
          %218 = affine.load %arg5[%arg8 * 5 + 4, %arg9 * 10 + 3] : memref<50x70xf32, #map3>
          %219 = arith.addf %218, %217 : f32
          affine.store %219, %arg5[%arg8 * 5 + 4, %arg9 * 10 + 3] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 4, %arg9 * 10 + 4] : memref<50x70xf32, #map3>
          %220 = affine.load %arg2[%arg8 * 5 + 4, %arg7] : memref<50x80xf32, #map0>
          %221 = affine.load %arg3[%arg7, %arg9 * 10 + 4] : memref<80x70xf32, #map1>
          %222 = arith.mulf %220, %221 : f32
          %223 = affine.load %arg5[%arg8 * 5 + 4, %arg9 * 10 + 4] : memref<50x70xf32, #map3>
          %224 = arith.addf %223, %222 : f32
          affine.store %224, %arg5[%arg8 * 5 + 4, %arg9 * 10 + 4] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 4, %arg9 * 10 + 5] : memref<50x70xf32, #map3>
          %225 = affine.load %arg2[%arg8 * 5 + 4, %arg7] : memref<50x80xf32, #map0>
          %226 = affine.load %arg3[%arg7, %arg9 * 10 + 5] : memref<80x70xf32, #map1>
          %227 = arith.mulf %225, %226 : f32
          %228 = affine.load %arg5[%arg8 * 5 + 4, %arg9 * 10 + 5] : memref<50x70xf32, #map3>
          %229 = arith.addf %228, %227 : f32
          affine.store %229, %arg5[%arg8 * 5 + 4, %arg9 * 10 + 5] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 4, %arg9 * 10 + 6] : memref<50x70xf32, #map3>
          %230 = affine.load %arg2[%arg8 * 5 + 4, %arg7] : memref<50x80xf32, #map0>
          %231 = affine.load %arg3[%arg7, %arg9 * 10 + 6] : memref<80x70xf32, #map1>
          %232 = arith.mulf %230, %231 : f32
          %233 = affine.load %arg5[%arg8 * 5 + 4, %arg9 * 10 + 6] : memref<50x70xf32, #map3>
          %234 = arith.addf %233, %232 : f32
          affine.store %234, %arg5[%arg8 * 5 + 4, %arg9 * 10 + 6] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 4, %arg9 * 10 + 7] : memref<50x70xf32, #map3>
          %235 = affine.load %arg2[%arg8 * 5 + 4, %arg7] : memref<50x80xf32, #map0>
          %236 = affine.load %arg3[%arg7, %arg9 * 10 + 7] : memref<80x70xf32, #map1>
          %237 = arith.mulf %235, %236 : f32
          %238 = affine.load %arg5[%arg8 * 5 + 4, %arg9 * 10 + 7] : memref<50x70xf32, #map3>
          %239 = arith.addf %238, %237 : f32
          affine.store %239, %arg5[%arg8 * 5 + 4, %arg9 * 10 + 7] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 4, %arg9 * 10 + 8] : memref<50x70xf32, #map3>
          %240 = affine.load %arg2[%arg8 * 5 + 4, %arg7] : memref<50x80xf32, #map0>
          %241 = affine.load %arg3[%arg7, %arg9 * 10 + 8] : memref<80x70xf32, #map1>
          %242 = arith.mulf %240, %241 : f32
          %243 = affine.load %arg5[%arg8 * 5 + 4, %arg9 * 10 + 8] : memref<50x70xf32, #map3>
          %244 = arith.addf %243, %242 : f32
          affine.store %244, %arg5[%arg8 * 5 + 4, %arg9 * 10 + 8] : memref<50x70xf32, #map3>
          affine.store %cst, %arg5[%arg8 * 5 + 4, %arg9 * 10 + 9] : memref<50x70xf32, #map3>
          %245 = affine.load %arg2[%arg8 * 5 + 4, %arg7] : memref<50x80xf32, #map0>
          %246 = affine.load %arg3[%arg7, %arg9 * 10 + 9] : memref<80x70xf32, #map1>
          %247 = arith.mulf %245, %246 : f32
          %248 = affine.load %arg5[%arg8 * 5 + 4, %arg9 * 10 + 9] : memref<50x70xf32, #map3>
          %249 = arith.addf %248, %247 : f32
          affine.store %249, %arg5[%arg8 * 5 + 4, %arg9 * 10 + 9] : memref<50x70xf32, #map3>
        } {parallel}
      } {parallel}
    }
    affine.for %arg7 = 0 to 50 {
      affine.for %arg8 = 0 to 5 {
        affine.for %arg9 = 0 to 5 {
          affine.store %cst, %arg6[%arg8 * 8, %arg9 * 14] : memref<40x70xf32, #map4>
          %0 = affine.load %arg4[%arg8 * 8, %arg7] : memref<40x50xf32, #map2>
          %1 = affine.load %arg5[%arg7, %arg9 * 14] : memref<50x70xf32, #map3>
          %2 = arith.mulf %0, %1 : f32
          %3 = affine.load %arg6[%arg8 * 8, %arg9 * 14] : memref<40x70xf32, #map4>
          %4 = arith.addf %3, %2 : f32
          affine.store %4, %arg6[%arg8 * 8, %arg9 * 14] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8, %arg9 * 14 + 1] : memref<40x70xf32, #map4>
          %5 = affine.load %arg4[%arg8 * 8, %arg7] : memref<40x50xf32, #map2>
          %6 = affine.load %arg5[%arg7, %arg9 * 14 + 1] : memref<50x70xf32, #map3>
          %7 = arith.mulf %5, %6 : f32
          %8 = affine.load %arg6[%arg8 * 8, %arg9 * 14 + 1] : memref<40x70xf32, #map4>
          %9 = arith.addf %8, %7 : f32
          affine.store %9, %arg6[%arg8 * 8, %arg9 * 14 + 1] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8, %arg9 * 14 + 2] : memref<40x70xf32, #map4>
          %10 = affine.load %arg4[%arg8 * 8, %arg7] : memref<40x50xf32, #map2>
          %11 = affine.load %arg5[%arg7, %arg9 * 14 + 2] : memref<50x70xf32, #map3>
          %12 = arith.mulf %10, %11 : f32
          %13 = affine.load %arg6[%arg8 * 8, %arg9 * 14 + 2] : memref<40x70xf32, #map4>
          %14 = arith.addf %13, %12 : f32
          affine.store %14, %arg6[%arg8 * 8, %arg9 * 14 + 2] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8, %arg9 * 14 + 3] : memref<40x70xf32, #map4>
          %15 = affine.load %arg4[%arg8 * 8, %arg7] : memref<40x50xf32, #map2>
          %16 = affine.load %arg5[%arg7, %arg9 * 14 + 3] : memref<50x70xf32, #map3>
          %17 = arith.mulf %15, %16 : f32
          %18 = affine.load %arg6[%arg8 * 8, %arg9 * 14 + 3] : memref<40x70xf32, #map4>
          %19 = arith.addf %18, %17 : f32
          affine.store %19, %arg6[%arg8 * 8, %arg9 * 14 + 3] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8, %arg9 * 14 + 4] : memref<40x70xf32, #map4>
          %20 = affine.load %arg4[%arg8 * 8, %arg7] : memref<40x50xf32, #map2>
          %21 = affine.load %arg5[%arg7, %arg9 * 14 + 4] : memref<50x70xf32, #map3>
          %22 = arith.mulf %20, %21 : f32
          %23 = affine.load %arg6[%arg8 * 8, %arg9 * 14 + 4] : memref<40x70xf32, #map4>
          %24 = arith.addf %23, %22 : f32
          affine.store %24, %arg6[%arg8 * 8, %arg9 * 14 + 4] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8, %arg9 * 14 + 5] : memref<40x70xf32, #map4>
          %25 = affine.load %arg4[%arg8 * 8, %arg7] : memref<40x50xf32, #map2>
          %26 = affine.load %arg5[%arg7, %arg9 * 14 + 5] : memref<50x70xf32, #map3>
          %27 = arith.mulf %25, %26 : f32
          %28 = affine.load %arg6[%arg8 * 8, %arg9 * 14 + 5] : memref<40x70xf32, #map4>
          %29 = arith.addf %28, %27 : f32
          affine.store %29, %arg6[%arg8 * 8, %arg9 * 14 + 5] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8, %arg9 * 14 + 6] : memref<40x70xf32, #map4>
          %30 = affine.load %arg4[%arg8 * 8, %arg7] : memref<40x50xf32, #map2>
          %31 = affine.load %arg5[%arg7, %arg9 * 14 + 6] : memref<50x70xf32, #map3>
          %32 = arith.mulf %30, %31 : f32
          %33 = affine.load %arg6[%arg8 * 8, %arg9 * 14 + 6] : memref<40x70xf32, #map4>
          %34 = arith.addf %33, %32 : f32
          affine.store %34, %arg6[%arg8 * 8, %arg9 * 14 + 6] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8, %arg9 * 14 + 7] : memref<40x70xf32, #map4>
          %35 = affine.load %arg4[%arg8 * 8, %arg7] : memref<40x50xf32, #map2>
          %36 = affine.load %arg5[%arg7, %arg9 * 14 + 7] : memref<50x70xf32, #map3>
          %37 = arith.mulf %35, %36 : f32
          %38 = affine.load %arg6[%arg8 * 8, %arg9 * 14 + 7] : memref<40x70xf32, #map4>
          %39 = arith.addf %38, %37 : f32
          affine.store %39, %arg6[%arg8 * 8, %arg9 * 14 + 7] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8, %arg9 * 14 + 8] : memref<40x70xf32, #map4>
          %40 = affine.load %arg4[%arg8 * 8, %arg7] : memref<40x50xf32, #map2>
          %41 = affine.load %arg5[%arg7, %arg9 * 14 + 8] : memref<50x70xf32, #map3>
          %42 = arith.mulf %40, %41 : f32
          %43 = affine.load %arg6[%arg8 * 8, %arg9 * 14 + 8] : memref<40x70xf32, #map4>
          %44 = arith.addf %43, %42 : f32
          affine.store %44, %arg6[%arg8 * 8, %arg9 * 14 + 8] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8, %arg9 * 14 + 9] : memref<40x70xf32, #map4>
          %45 = affine.load %arg4[%arg8 * 8, %arg7] : memref<40x50xf32, #map2>
          %46 = affine.load %arg5[%arg7, %arg9 * 14 + 9] : memref<50x70xf32, #map3>
          %47 = arith.mulf %45, %46 : f32
          %48 = affine.load %arg6[%arg8 * 8, %arg9 * 14 + 9] : memref<40x70xf32, #map4>
          %49 = arith.addf %48, %47 : f32
          affine.store %49, %arg6[%arg8 * 8, %arg9 * 14 + 9] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8, %arg9 * 14 + 10] : memref<40x70xf32, #map4>
          %50 = affine.load %arg4[%arg8 * 8, %arg7] : memref<40x50xf32, #map2>
          %51 = affine.load %arg5[%arg7, %arg9 * 14 + 10] : memref<50x70xf32, #map3>
          %52 = arith.mulf %50, %51 : f32
          %53 = affine.load %arg6[%arg8 * 8, %arg9 * 14 + 10] : memref<40x70xf32, #map4>
          %54 = arith.addf %53, %52 : f32
          affine.store %54, %arg6[%arg8 * 8, %arg9 * 14 + 10] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8, %arg9 * 14 + 11] : memref<40x70xf32, #map4>
          %55 = affine.load %arg4[%arg8 * 8, %arg7] : memref<40x50xf32, #map2>
          %56 = affine.load %arg5[%arg7, %arg9 * 14 + 11] : memref<50x70xf32, #map3>
          %57 = arith.mulf %55, %56 : f32
          %58 = affine.load %arg6[%arg8 * 8, %arg9 * 14 + 11] : memref<40x70xf32, #map4>
          %59 = arith.addf %58, %57 : f32
          affine.store %59, %arg6[%arg8 * 8, %arg9 * 14 + 11] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8, %arg9 * 14 + 12] : memref<40x70xf32, #map4>
          %60 = affine.load %arg4[%arg8 * 8, %arg7] : memref<40x50xf32, #map2>
          %61 = affine.load %arg5[%arg7, %arg9 * 14 + 12] : memref<50x70xf32, #map3>
          %62 = arith.mulf %60, %61 : f32
          %63 = affine.load %arg6[%arg8 * 8, %arg9 * 14 + 12] : memref<40x70xf32, #map4>
          %64 = arith.addf %63, %62 : f32
          affine.store %64, %arg6[%arg8 * 8, %arg9 * 14 + 12] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8, %arg9 * 14 + 13] : memref<40x70xf32, #map4>
          %65 = affine.load %arg4[%arg8 * 8, %arg7] : memref<40x50xf32, #map2>
          %66 = affine.load %arg5[%arg7, %arg9 * 14 + 13] : memref<50x70xf32, #map3>
          %67 = arith.mulf %65, %66 : f32
          %68 = affine.load %arg6[%arg8 * 8, %arg9 * 14 + 13] : memref<40x70xf32, #map4>
          %69 = arith.addf %68, %67 : f32
          affine.store %69, %arg6[%arg8 * 8, %arg9 * 14 + 13] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 1, %arg9 * 14] : memref<40x70xf32, #map4>
          %70 = affine.load %arg4[%arg8 * 8 + 1, %arg7] : memref<40x50xf32, #map2>
          %71 = affine.load %arg5[%arg7, %arg9 * 14] : memref<50x70xf32, #map3>
          %72 = arith.mulf %70, %71 : f32
          %73 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14] : memref<40x70xf32, #map4>
          %74 = arith.addf %73, %72 : f32
          affine.store %74, %arg6[%arg8 * 8 + 1, %arg9 * 14] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 1] : memref<40x70xf32, #map4>
          %75 = affine.load %arg4[%arg8 * 8 + 1, %arg7] : memref<40x50xf32, #map2>
          %76 = affine.load %arg5[%arg7, %arg9 * 14 + 1] : memref<50x70xf32, #map3>
          %77 = arith.mulf %75, %76 : f32
          %78 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14 + 1] : memref<40x70xf32, #map4>
          %79 = arith.addf %78, %77 : f32
          affine.store %79, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 1] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 2] : memref<40x70xf32, #map4>
          %80 = affine.load %arg4[%arg8 * 8 + 1, %arg7] : memref<40x50xf32, #map2>
          %81 = affine.load %arg5[%arg7, %arg9 * 14 + 2] : memref<50x70xf32, #map3>
          %82 = arith.mulf %80, %81 : f32
          %83 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14 + 2] : memref<40x70xf32, #map4>
          %84 = arith.addf %83, %82 : f32
          affine.store %84, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 2] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 3] : memref<40x70xf32, #map4>
          %85 = affine.load %arg4[%arg8 * 8 + 1, %arg7] : memref<40x50xf32, #map2>
          %86 = affine.load %arg5[%arg7, %arg9 * 14 + 3] : memref<50x70xf32, #map3>
          %87 = arith.mulf %85, %86 : f32
          %88 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14 + 3] : memref<40x70xf32, #map4>
          %89 = arith.addf %88, %87 : f32
          affine.store %89, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 3] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 4] : memref<40x70xf32, #map4>
          %90 = affine.load %arg4[%arg8 * 8 + 1, %arg7] : memref<40x50xf32, #map2>
          %91 = affine.load %arg5[%arg7, %arg9 * 14 + 4] : memref<50x70xf32, #map3>
          %92 = arith.mulf %90, %91 : f32
          %93 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14 + 4] : memref<40x70xf32, #map4>
          %94 = arith.addf %93, %92 : f32
          affine.store %94, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 4] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 5] : memref<40x70xf32, #map4>
          %95 = affine.load %arg4[%arg8 * 8 + 1, %arg7] : memref<40x50xf32, #map2>
          %96 = affine.load %arg5[%arg7, %arg9 * 14 + 5] : memref<50x70xf32, #map3>
          %97 = arith.mulf %95, %96 : f32
          %98 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14 + 5] : memref<40x70xf32, #map4>
          %99 = arith.addf %98, %97 : f32
          affine.store %99, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 5] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 6] : memref<40x70xf32, #map4>
          %100 = affine.load %arg4[%arg8 * 8 + 1, %arg7] : memref<40x50xf32, #map2>
          %101 = affine.load %arg5[%arg7, %arg9 * 14 + 6] : memref<50x70xf32, #map3>
          %102 = arith.mulf %100, %101 : f32
          %103 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14 + 6] : memref<40x70xf32, #map4>
          %104 = arith.addf %103, %102 : f32
          affine.store %104, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 6] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 7] : memref<40x70xf32, #map4>
          %105 = affine.load %arg4[%arg8 * 8 + 1, %arg7] : memref<40x50xf32, #map2>
          %106 = affine.load %arg5[%arg7, %arg9 * 14 + 7] : memref<50x70xf32, #map3>
          %107 = arith.mulf %105, %106 : f32
          %108 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14 + 7] : memref<40x70xf32, #map4>
          %109 = arith.addf %108, %107 : f32
          affine.store %109, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 7] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 8] : memref<40x70xf32, #map4>
          %110 = affine.load %arg4[%arg8 * 8 + 1, %arg7] : memref<40x50xf32, #map2>
          %111 = affine.load %arg5[%arg7, %arg9 * 14 + 8] : memref<50x70xf32, #map3>
          %112 = arith.mulf %110, %111 : f32
          %113 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14 + 8] : memref<40x70xf32, #map4>
          %114 = arith.addf %113, %112 : f32
          affine.store %114, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 8] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 9] : memref<40x70xf32, #map4>
          %115 = affine.load %arg4[%arg8 * 8 + 1, %arg7] : memref<40x50xf32, #map2>
          %116 = affine.load %arg5[%arg7, %arg9 * 14 + 9] : memref<50x70xf32, #map3>
          %117 = arith.mulf %115, %116 : f32
          %118 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14 + 9] : memref<40x70xf32, #map4>
          %119 = arith.addf %118, %117 : f32
          affine.store %119, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 9] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 10] : memref<40x70xf32, #map4>
          %120 = affine.load %arg4[%arg8 * 8 + 1, %arg7] : memref<40x50xf32, #map2>
          %121 = affine.load %arg5[%arg7, %arg9 * 14 + 10] : memref<50x70xf32, #map3>
          %122 = arith.mulf %120, %121 : f32
          %123 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14 + 10] : memref<40x70xf32, #map4>
          %124 = arith.addf %123, %122 : f32
          affine.store %124, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 10] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 11] : memref<40x70xf32, #map4>
          %125 = affine.load %arg4[%arg8 * 8 + 1, %arg7] : memref<40x50xf32, #map2>
          %126 = affine.load %arg5[%arg7, %arg9 * 14 + 11] : memref<50x70xf32, #map3>
          %127 = arith.mulf %125, %126 : f32
          %128 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14 + 11] : memref<40x70xf32, #map4>
          %129 = arith.addf %128, %127 : f32
          affine.store %129, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 11] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 12] : memref<40x70xf32, #map4>
          %130 = affine.load %arg4[%arg8 * 8 + 1, %arg7] : memref<40x50xf32, #map2>
          %131 = affine.load %arg5[%arg7, %arg9 * 14 + 12] : memref<50x70xf32, #map3>
          %132 = arith.mulf %130, %131 : f32
          %133 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14 + 12] : memref<40x70xf32, #map4>
          %134 = arith.addf %133, %132 : f32
          affine.store %134, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 12] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 13] : memref<40x70xf32, #map4>
          %135 = affine.load %arg4[%arg8 * 8 + 1, %arg7] : memref<40x50xf32, #map2>
          %136 = affine.load %arg5[%arg7, %arg9 * 14 + 13] : memref<50x70xf32, #map3>
          %137 = arith.mulf %135, %136 : f32
          %138 = affine.load %arg6[%arg8 * 8 + 1, %arg9 * 14 + 13] : memref<40x70xf32, #map4>
          %139 = arith.addf %138, %137 : f32
          affine.store %139, %arg6[%arg8 * 8 + 1, %arg9 * 14 + 13] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 2, %arg9 * 14] : memref<40x70xf32, #map4>
          %140 = affine.load %arg4[%arg8 * 8 + 2, %arg7] : memref<40x50xf32, #map2>
          %141 = affine.load %arg5[%arg7, %arg9 * 14] : memref<50x70xf32, #map3>
          %142 = arith.mulf %140, %141 : f32
          %143 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14] : memref<40x70xf32, #map4>
          %144 = arith.addf %143, %142 : f32
          affine.store %144, %arg6[%arg8 * 8 + 2, %arg9 * 14] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 1] : memref<40x70xf32, #map4>
          %145 = affine.load %arg4[%arg8 * 8 + 2, %arg7] : memref<40x50xf32, #map2>
          %146 = affine.load %arg5[%arg7, %arg9 * 14 + 1] : memref<50x70xf32, #map3>
          %147 = arith.mulf %145, %146 : f32
          %148 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14 + 1] : memref<40x70xf32, #map4>
          %149 = arith.addf %148, %147 : f32
          affine.store %149, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 1] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 2] : memref<40x70xf32, #map4>
          %150 = affine.load %arg4[%arg8 * 8 + 2, %arg7] : memref<40x50xf32, #map2>
          %151 = affine.load %arg5[%arg7, %arg9 * 14 + 2] : memref<50x70xf32, #map3>
          %152 = arith.mulf %150, %151 : f32
          %153 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14 + 2] : memref<40x70xf32, #map4>
          %154 = arith.addf %153, %152 : f32
          affine.store %154, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 2] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 3] : memref<40x70xf32, #map4>
          %155 = affine.load %arg4[%arg8 * 8 + 2, %arg7] : memref<40x50xf32, #map2>
          %156 = affine.load %arg5[%arg7, %arg9 * 14 + 3] : memref<50x70xf32, #map3>
          %157 = arith.mulf %155, %156 : f32
          %158 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14 + 3] : memref<40x70xf32, #map4>
          %159 = arith.addf %158, %157 : f32
          affine.store %159, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 3] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 4] : memref<40x70xf32, #map4>
          %160 = affine.load %arg4[%arg8 * 8 + 2, %arg7] : memref<40x50xf32, #map2>
          %161 = affine.load %arg5[%arg7, %arg9 * 14 + 4] : memref<50x70xf32, #map3>
          %162 = arith.mulf %160, %161 : f32
          %163 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14 + 4] : memref<40x70xf32, #map4>
          %164 = arith.addf %163, %162 : f32
          affine.store %164, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 4] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 5] : memref<40x70xf32, #map4>
          %165 = affine.load %arg4[%arg8 * 8 + 2, %arg7] : memref<40x50xf32, #map2>
          %166 = affine.load %arg5[%arg7, %arg9 * 14 + 5] : memref<50x70xf32, #map3>
          %167 = arith.mulf %165, %166 : f32
          %168 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14 + 5] : memref<40x70xf32, #map4>
          %169 = arith.addf %168, %167 : f32
          affine.store %169, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 5] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 6] : memref<40x70xf32, #map4>
          %170 = affine.load %arg4[%arg8 * 8 + 2, %arg7] : memref<40x50xf32, #map2>
          %171 = affine.load %arg5[%arg7, %arg9 * 14 + 6] : memref<50x70xf32, #map3>
          %172 = arith.mulf %170, %171 : f32
          %173 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14 + 6] : memref<40x70xf32, #map4>
          %174 = arith.addf %173, %172 : f32
          affine.store %174, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 6] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 7] : memref<40x70xf32, #map4>
          %175 = affine.load %arg4[%arg8 * 8 + 2, %arg7] : memref<40x50xf32, #map2>
          %176 = affine.load %arg5[%arg7, %arg9 * 14 + 7] : memref<50x70xf32, #map3>
          %177 = arith.mulf %175, %176 : f32
          %178 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14 + 7] : memref<40x70xf32, #map4>
          %179 = arith.addf %178, %177 : f32
          affine.store %179, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 7] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 8] : memref<40x70xf32, #map4>
          %180 = affine.load %arg4[%arg8 * 8 + 2, %arg7] : memref<40x50xf32, #map2>
          %181 = affine.load %arg5[%arg7, %arg9 * 14 + 8] : memref<50x70xf32, #map3>
          %182 = arith.mulf %180, %181 : f32
          %183 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14 + 8] : memref<40x70xf32, #map4>
          %184 = arith.addf %183, %182 : f32
          affine.store %184, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 8] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 9] : memref<40x70xf32, #map4>
          %185 = affine.load %arg4[%arg8 * 8 + 2, %arg7] : memref<40x50xf32, #map2>
          %186 = affine.load %arg5[%arg7, %arg9 * 14 + 9] : memref<50x70xf32, #map3>
          %187 = arith.mulf %185, %186 : f32
          %188 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14 + 9] : memref<40x70xf32, #map4>
          %189 = arith.addf %188, %187 : f32
          affine.store %189, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 9] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 10] : memref<40x70xf32, #map4>
          %190 = affine.load %arg4[%arg8 * 8 + 2, %arg7] : memref<40x50xf32, #map2>
          %191 = affine.load %arg5[%arg7, %arg9 * 14 + 10] : memref<50x70xf32, #map3>
          %192 = arith.mulf %190, %191 : f32
          %193 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14 + 10] : memref<40x70xf32, #map4>
          %194 = arith.addf %193, %192 : f32
          affine.store %194, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 10] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 11] : memref<40x70xf32, #map4>
          %195 = affine.load %arg4[%arg8 * 8 + 2, %arg7] : memref<40x50xf32, #map2>
          %196 = affine.load %arg5[%arg7, %arg9 * 14 + 11] : memref<50x70xf32, #map3>
          %197 = arith.mulf %195, %196 : f32
          %198 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14 + 11] : memref<40x70xf32, #map4>
          %199 = arith.addf %198, %197 : f32
          affine.store %199, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 11] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 12] : memref<40x70xf32, #map4>
          %200 = affine.load %arg4[%arg8 * 8 + 2, %arg7] : memref<40x50xf32, #map2>
          %201 = affine.load %arg5[%arg7, %arg9 * 14 + 12] : memref<50x70xf32, #map3>
          %202 = arith.mulf %200, %201 : f32
          %203 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14 + 12] : memref<40x70xf32, #map4>
          %204 = arith.addf %203, %202 : f32
          affine.store %204, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 12] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 13] : memref<40x70xf32, #map4>
          %205 = affine.load %arg4[%arg8 * 8 + 2, %arg7] : memref<40x50xf32, #map2>
          %206 = affine.load %arg5[%arg7, %arg9 * 14 + 13] : memref<50x70xf32, #map3>
          %207 = arith.mulf %205, %206 : f32
          %208 = affine.load %arg6[%arg8 * 8 + 2, %arg9 * 14 + 13] : memref<40x70xf32, #map4>
          %209 = arith.addf %208, %207 : f32
          affine.store %209, %arg6[%arg8 * 8 + 2, %arg9 * 14 + 13] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 3, %arg9 * 14] : memref<40x70xf32, #map4>
          %210 = affine.load %arg4[%arg8 * 8 + 3, %arg7] : memref<40x50xf32, #map2>
          %211 = affine.load %arg5[%arg7, %arg9 * 14] : memref<50x70xf32, #map3>
          %212 = arith.mulf %210, %211 : f32
          %213 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14] : memref<40x70xf32, #map4>
          %214 = arith.addf %213, %212 : f32
          affine.store %214, %arg6[%arg8 * 8 + 3, %arg9 * 14] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 1] : memref<40x70xf32, #map4>
          %215 = affine.load %arg4[%arg8 * 8 + 3, %arg7] : memref<40x50xf32, #map2>
          %216 = affine.load %arg5[%arg7, %arg9 * 14 + 1] : memref<50x70xf32, #map3>
          %217 = arith.mulf %215, %216 : f32
          %218 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14 + 1] : memref<40x70xf32, #map4>
          %219 = arith.addf %218, %217 : f32
          affine.store %219, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 1] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 2] : memref<40x70xf32, #map4>
          %220 = affine.load %arg4[%arg8 * 8 + 3, %arg7] : memref<40x50xf32, #map2>
          %221 = affine.load %arg5[%arg7, %arg9 * 14 + 2] : memref<50x70xf32, #map3>
          %222 = arith.mulf %220, %221 : f32
          %223 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14 + 2] : memref<40x70xf32, #map4>
          %224 = arith.addf %223, %222 : f32
          affine.store %224, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 2] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 3] : memref<40x70xf32, #map4>
          %225 = affine.load %arg4[%arg8 * 8 + 3, %arg7] : memref<40x50xf32, #map2>
          %226 = affine.load %arg5[%arg7, %arg9 * 14 + 3] : memref<50x70xf32, #map3>
          %227 = arith.mulf %225, %226 : f32
          %228 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14 + 3] : memref<40x70xf32, #map4>
          %229 = arith.addf %228, %227 : f32
          affine.store %229, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 3] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 4] : memref<40x70xf32, #map4>
          %230 = affine.load %arg4[%arg8 * 8 + 3, %arg7] : memref<40x50xf32, #map2>
          %231 = affine.load %arg5[%arg7, %arg9 * 14 + 4] : memref<50x70xf32, #map3>
          %232 = arith.mulf %230, %231 : f32
          %233 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14 + 4] : memref<40x70xf32, #map4>
          %234 = arith.addf %233, %232 : f32
          affine.store %234, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 4] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 5] : memref<40x70xf32, #map4>
          %235 = affine.load %arg4[%arg8 * 8 + 3, %arg7] : memref<40x50xf32, #map2>
          %236 = affine.load %arg5[%arg7, %arg9 * 14 + 5] : memref<50x70xf32, #map3>
          %237 = arith.mulf %235, %236 : f32
          %238 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14 + 5] : memref<40x70xf32, #map4>
          %239 = arith.addf %238, %237 : f32
          affine.store %239, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 5] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 6] : memref<40x70xf32, #map4>
          %240 = affine.load %arg4[%arg8 * 8 + 3, %arg7] : memref<40x50xf32, #map2>
          %241 = affine.load %arg5[%arg7, %arg9 * 14 + 6] : memref<50x70xf32, #map3>
          %242 = arith.mulf %240, %241 : f32
          %243 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14 + 6] : memref<40x70xf32, #map4>
          %244 = arith.addf %243, %242 : f32
          affine.store %244, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 6] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 7] : memref<40x70xf32, #map4>
          %245 = affine.load %arg4[%arg8 * 8 + 3, %arg7] : memref<40x50xf32, #map2>
          %246 = affine.load %arg5[%arg7, %arg9 * 14 + 7] : memref<50x70xf32, #map3>
          %247 = arith.mulf %245, %246 : f32
          %248 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14 + 7] : memref<40x70xf32, #map4>
          %249 = arith.addf %248, %247 : f32
          affine.store %249, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 7] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 8] : memref<40x70xf32, #map4>
          %250 = affine.load %arg4[%arg8 * 8 + 3, %arg7] : memref<40x50xf32, #map2>
          %251 = affine.load %arg5[%arg7, %arg9 * 14 + 8] : memref<50x70xf32, #map3>
          %252 = arith.mulf %250, %251 : f32
          %253 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14 + 8] : memref<40x70xf32, #map4>
          %254 = arith.addf %253, %252 : f32
          affine.store %254, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 8] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 9] : memref<40x70xf32, #map4>
          %255 = affine.load %arg4[%arg8 * 8 + 3, %arg7] : memref<40x50xf32, #map2>
          %256 = affine.load %arg5[%arg7, %arg9 * 14 + 9] : memref<50x70xf32, #map3>
          %257 = arith.mulf %255, %256 : f32
          %258 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14 + 9] : memref<40x70xf32, #map4>
          %259 = arith.addf %258, %257 : f32
          affine.store %259, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 9] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 10] : memref<40x70xf32, #map4>
          %260 = affine.load %arg4[%arg8 * 8 + 3, %arg7] : memref<40x50xf32, #map2>
          %261 = affine.load %arg5[%arg7, %arg9 * 14 + 10] : memref<50x70xf32, #map3>
          %262 = arith.mulf %260, %261 : f32
          %263 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14 + 10] : memref<40x70xf32, #map4>
          %264 = arith.addf %263, %262 : f32
          affine.store %264, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 10] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 11] : memref<40x70xf32, #map4>
          %265 = affine.load %arg4[%arg8 * 8 + 3, %arg7] : memref<40x50xf32, #map2>
          %266 = affine.load %arg5[%arg7, %arg9 * 14 + 11] : memref<50x70xf32, #map3>
          %267 = arith.mulf %265, %266 : f32
          %268 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14 + 11] : memref<40x70xf32, #map4>
          %269 = arith.addf %268, %267 : f32
          affine.store %269, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 11] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 12] : memref<40x70xf32, #map4>
          %270 = affine.load %arg4[%arg8 * 8 + 3, %arg7] : memref<40x50xf32, #map2>
          %271 = affine.load %arg5[%arg7, %arg9 * 14 + 12] : memref<50x70xf32, #map3>
          %272 = arith.mulf %270, %271 : f32
          %273 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14 + 12] : memref<40x70xf32, #map4>
          %274 = arith.addf %273, %272 : f32
          affine.store %274, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 12] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 13] : memref<40x70xf32, #map4>
          %275 = affine.load %arg4[%arg8 * 8 + 3, %arg7] : memref<40x50xf32, #map2>
          %276 = affine.load %arg5[%arg7, %arg9 * 14 + 13] : memref<50x70xf32, #map3>
          %277 = arith.mulf %275, %276 : f32
          %278 = affine.load %arg6[%arg8 * 8 + 3, %arg9 * 14 + 13] : memref<40x70xf32, #map4>
          %279 = arith.addf %278, %277 : f32
          affine.store %279, %arg6[%arg8 * 8 + 3, %arg9 * 14 + 13] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 4, %arg9 * 14] : memref<40x70xf32, #map4>
          %280 = affine.load %arg4[%arg8 * 8 + 4, %arg7] : memref<40x50xf32, #map2>
          %281 = affine.load %arg5[%arg7, %arg9 * 14] : memref<50x70xf32, #map3>
          %282 = arith.mulf %280, %281 : f32
          %283 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14] : memref<40x70xf32, #map4>
          %284 = arith.addf %283, %282 : f32
          affine.store %284, %arg6[%arg8 * 8 + 4, %arg9 * 14] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 1] : memref<40x70xf32, #map4>
          %285 = affine.load %arg4[%arg8 * 8 + 4, %arg7] : memref<40x50xf32, #map2>
          %286 = affine.load %arg5[%arg7, %arg9 * 14 + 1] : memref<50x70xf32, #map3>
          %287 = arith.mulf %285, %286 : f32
          %288 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14 + 1] : memref<40x70xf32, #map4>
          %289 = arith.addf %288, %287 : f32
          affine.store %289, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 1] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 2] : memref<40x70xf32, #map4>
          %290 = affine.load %arg4[%arg8 * 8 + 4, %arg7] : memref<40x50xf32, #map2>
          %291 = affine.load %arg5[%arg7, %arg9 * 14 + 2] : memref<50x70xf32, #map3>
          %292 = arith.mulf %290, %291 : f32
          %293 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14 + 2] : memref<40x70xf32, #map4>
          %294 = arith.addf %293, %292 : f32
          affine.store %294, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 2] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 3] : memref<40x70xf32, #map4>
          %295 = affine.load %arg4[%arg8 * 8 + 4, %arg7] : memref<40x50xf32, #map2>
          %296 = affine.load %arg5[%arg7, %arg9 * 14 + 3] : memref<50x70xf32, #map3>
          %297 = arith.mulf %295, %296 : f32
          %298 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14 + 3] : memref<40x70xf32, #map4>
          %299 = arith.addf %298, %297 : f32
          affine.store %299, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 3] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 4] : memref<40x70xf32, #map4>
          %300 = affine.load %arg4[%arg8 * 8 + 4, %arg7] : memref<40x50xf32, #map2>
          %301 = affine.load %arg5[%arg7, %arg9 * 14 + 4] : memref<50x70xf32, #map3>
          %302 = arith.mulf %300, %301 : f32
          %303 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14 + 4] : memref<40x70xf32, #map4>
          %304 = arith.addf %303, %302 : f32
          affine.store %304, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 4] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 5] : memref<40x70xf32, #map4>
          %305 = affine.load %arg4[%arg8 * 8 + 4, %arg7] : memref<40x50xf32, #map2>
          %306 = affine.load %arg5[%arg7, %arg9 * 14 + 5] : memref<50x70xf32, #map3>
          %307 = arith.mulf %305, %306 : f32
          %308 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14 + 5] : memref<40x70xf32, #map4>
          %309 = arith.addf %308, %307 : f32
          affine.store %309, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 5] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 6] : memref<40x70xf32, #map4>
          %310 = affine.load %arg4[%arg8 * 8 + 4, %arg7] : memref<40x50xf32, #map2>
          %311 = affine.load %arg5[%arg7, %arg9 * 14 + 6] : memref<50x70xf32, #map3>
          %312 = arith.mulf %310, %311 : f32
          %313 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14 + 6] : memref<40x70xf32, #map4>
          %314 = arith.addf %313, %312 : f32
          affine.store %314, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 6] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 7] : memref<40x70xf32, #map4>
          %315 = affine.load %arg4[%arg8 * 8 + 4, %arg7] : memref<40x50xf32, #map2>
          %316 = affine.load %arg5[%arg7, %arg9 * 14 + 7] : memref<50x70xf32, #map3>
          %317 = arith.mulf %315, %316 : f32
          %318 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14 + 7] : memref<40x70xf32, #map4>
          %319 = arith.addf %318, %317 : f32
          affine.store %319, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 7] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 8] : memref<40x70xf32, #map4>
          %320 = affine.load %arg4[%arg8 * 8 + 4, %arg7] : memref<40x50xf32, #map2>
          %321 = affine.load %arg5[%arg7, %arg9 * 14 + 8] : memref<50x70xf32, #map3>
          %322 = arith.mulf %320, %321 : f32
          %323 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14 + 8] : memref<40x70xf32, #map4>
          %324 = arith.addf %323, %322 : f32
          affine.store %324, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 8] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 9] : memref<40x70xf32, #map4>
          %325 = affine.load %arg4[%arg8 * 8 + 4, %arg7] : memref<40x50xf32, #map2>
          %326 = affine.load %arg5[%arg7, %arg9 * 14 + 9] : memref<50x70xf32, #map3>
          %327 = arith.mulf %325, %326 : f32
          %328 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14 + 9] : memref<40x70xf32, #map4>
          %329 = arith.addf %328, %327 : f32
          affine.store %329, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 9] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 10] : memref<40x70xf32, #map4>
          %330 = affine.load %arg4[%arg8 * 8 + 4, %arg7] : memref<40x50xf32, #map2>
          %331 = affine.load %arg5[%arg7, %arg9 * 14 + 10] : memref<50x70xf32, #map3>
          %332 = arith.mulf %330, %331 : f32
          %333 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14 + 10] : memref<40x70xf32, #map4>
          %334 = arith.addf %333, %332 : f32
          affine.store %334, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 10] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 11] : memref<40x70xf32, #map4>
          %335 = affine.load %arg4[%arg8 * 8 + 4, %arg7] : memref<40x50xf32, #map2>
          %336 = affine.load %arg5[%arg7, %arg9 * 14 + 11] : memref<50x70xf32, #map3>
          %337 = arith.mulf %335, %336 : f32
          %338 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14 + 11] : memref<40x70xf32, #map4>
          %339 = arith.addf %338, %337 : f32
          affine.store %339, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 11] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 12] : memref<40x70xf32, #map4>
          %340 = affine.load %arg4[%arg8 * 8 + 4, %arg7] : memref<40x50xf32, #map2>
          %341 = affine.load %arg5[%arg7, %arg9 * 14 + 12] : memref<50x70xf32, #map3>
          %342 = arith.mulf %340, %341 : f32
          %343 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14 + 12] : memref<40x70xf32, #map4>
          %344 = arith.addf %343, %342 : f32
          affine.store %344, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 12] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 13] : memref<40x70xf32, #map4>
          %345 = affine.load %arg4[%arg8 * 8 + 4, %arg7] : memref<40x50xf32, #map2>
          %346 = affine.load %arg5[%arg7, %arg9 * 14 + 13] : memref<50x70xf32, #map3>
          %347 = arith.mulf %345, %346 : f32
          %348 = affine.load %arg6[%arg8 * 8 + 4, %arg9 * 14 + 13] : memref<40x70xf32, #map4>
          %349 = arith.addf %348, %347 : f32
          affine.store %349, %arg6[%arg8 * 8 + 4, %arg9 * 14 + 13] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 5, %arg9 * 14] : memref<40x70xf32, #map4>
          %350 = affine.load %arg4[%arg8 * 8 + 5, %arg7] : memref<40x50xf32, #map2>
          %351 = affine.load %arg5[%arg7, %arg9 * 14] : memref<50x70xf32, #map3>
          %352 = arith.mulf %350, %351 : f32
          %353 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14] : memref<40x70xf32, #map4>
          %354 = arith.addf %353, %352 : f32
          affine.store %354, %arg6[%arg8 * 8 + 5, %arg9 * 14] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 1] : memref<40x70xf32, #map4>
          %355 = affine.load %arg4[%arg8 * 8 + 5, %arg7] : memref<40x50xf32, #map2>
          %356 = affine.load %arg5[%arg7, %arg9 * 14 + 1] : memref<50x70xf32, #map3>
          %357 = arith.mulf %355, %356 : f32
          %358 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14 + 1] : memref<40x70xf32, #map4>
          %359 = arith.addf %358, %357 : f32
          affine.store %359, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 1] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 2] : memref<40x70xf32, #map4>
          %360 = affine.load %arg4[%arg8 * 8 + 5, %arg7] : memref<40x50xf32, #map2>
          %361 = affine.load %arg5[%arg7, %arg9 * 14 + 2] : memref<50x70xf32, #map3>
          %362 = arith.mulf %360, %361 : f32
          %363 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14 + 2] : memref<40x70xf32, #map4>
          %364 = arith.addf %363, %362 : f32
          affine.store %364, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 2] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 3] : memref<40x70xf32, #map4>
          %365 = affine.load %arg4[%arg8 * 8 + 5, %arg7] : memref<40x50xf32, #map2>
          %366 = affine.load %arg5[%arg7, %arg9 * 14 + 3] : memref<50x70xf32, #map3>
          %367 = arith.mulf %365, %366 : f32
          %368 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14 + 3] : memref<40x70xf32, #map4>
          %369 = arith.addf %368, %367 : f32
          affine.store %369, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 3] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 4] : memref<40x70xf32, #map4>
          %370 = affine.load %arg4[%arg8 * 8 + 5, %arg7] : memref<40x50xf32, #map2>
          %371 = affine.load %arg5[%arg7, %arg9 * 14 + 4] : memref<50x70xf32, #map3>
          %372 = arith.mulf %370, %371 : f32
          %373 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14 + 4] : memref<40x70xf32, #map4>
          %374 = arith.addf %373, %372 : f32
          affine.store %374, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 4] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 5] : memref<40x70xf32, #map4>
          %375 = affine.load %arg4[%arg8 * 8 + 5, %arg7] : memref<40x50xf32, #map2>
          %376 = affine.load %arg5[%arg7, %arg9 * 14 + 5] : memref<50x70xf32, #map3>
          %377 = arith.mulf %375, %376 : f32
          %378 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14 + 5] : memref<40x70xf32, #map4>
          %379 = arith.addf %378, %377 : f32
          affine.store %379, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 5] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 6] : memref<40x70xf32, #map4>
          %380 = affine.load %arg4[%arg8 * 8 + 5, %arg7] : memref<40x50xf32, #map2>
          %381 = affine.load %arg5[%arg7, %arg9 * 14 + 6] : memref<50x70xf32, #map3>
          %382 = arith.mulf %380, %381 : f32
          %383 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14 + 6] : memref<40x70xf32, #map4>
          %384 = arith.addf %383, %382 : f32
          affine.store %384, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 6] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 7] : memref<40x70xf32, #map4>
          %385 = affine.load %arg4[%arg8 * 8 + 5, %arg7] : memref<40x50xf32, #map2>
          %386 = affine.load %arg5[%arg7, %arg9 * 14 + 7] : memref<50x70xf32, #map3>
          %387 = arith.mulf %385, %386 : f32
          %388 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14 + 7] : memref<40x70xf32, #map4>
          %389 = arith.addf %388, %387 : f32
          affine.store %389, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 7] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 8] : memref<40x70xf32, #map4>
          %390 = affine.load %arg4[%arg8 * 8 + 5, %arg7] : memref<40x50xf32, #map2>
          %391 = affine.load %arg5[%arg7, %arg9 * 14 + 8] : memref<50x70xf32, #map3>
          %392 = arith.mulf %390, %391 : f32
          %393 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14 + 8] : memref<40x70xf32, #map4>
          %394 = arith.addf %393, %392 : f32
          affine.store %394, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 8] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 9] : memref<40x70xf32, #map4>
          %395 = affine.load %arg4[%arg8 * 8 + 5, %arg7] : memref<40x50xf32, #map2>
          %396 = affine.load %arg5[%arg7, %arg9 * 14 + 9] : memref<50x70xf32, #map3>
          %397 = arith.mulf %395, %396 : f32
          %398 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14 + 9] : memref<40x70xf32, #map4>
          %399 = arith.addf %398, %397 : f32
          affine.store %399, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 9] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 10] : memref<40x70xf32, #map4>
          %400 = affine.load %arg4[%arg8 * 8 + 5, %arg7] : memref<40x50xf32, #map2>
          %401 = affine.load %arg5[%arg7, %arg9 * 14 + 10] : memref<50x70xf32, #map3>
          %402 = arith.mulf %400, %401 : f32
          %403 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14 + 10] : memref<40x70xf32, #map4>
          %404 = arith.addf %403, %402 : f32
          affine.store %404, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 10] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 11] : memref<40x70xf32, #map4>
          %405 = affine.load %arg4[%arg8 * 8 + 5, %arg7] : memref<40x50xf32, #map2>
          %406 = affine.load %arg5[%arg7, %arg9 * 14 + 11] : memref<50x70xf32, #map3>
          %407 = arith.mulf %405, %406 : f32
          %408 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14 + 11] : memref<40x70xf32, #map4>
          %409 = arith.addf %408, %407 : f32
          affine.store %409, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 11] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 12] : memref<40x70xf32, #map4>
          %410 = affine.load %arg4[%arg8 * 8 + 5, %arg7] : memref<40x50xf32, #map2>
          %411 = affine.load %arg5[%arg7, %arg9 * 14 + 12] : memref<50x70xf32, #map3>
          %412 = arith.mulf %410, %411 : f32
          %413 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14 + 12] : memref<40x70xf32, #map4>
          %414 = arith.addf %413, %412 : f32
          affine.store %414, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 12] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 13] : memref<40x70xf32, #map4>
          %415 = affine.load %arg4[%arg8 * 8 + 5, %arg7] : memref<40x50xf32, #map2>
          %416 = affine.load %arg5[%arg7, %arg9 * 14 + 13] : memref<50x70xf32, #map3>
          %417 = arith.mulf %415, %416 : f32
          %418 = affine.load %arg6[%arg8 * 8 + 5, %arg9 * 14 + 13] : memref<40x70xf32, #map4>
          %419 = arith.addf %418, %417 : f32
          affine.store %419, %arg6[%arg8 * 8 + 5, %arg9 * 14 + 13] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 6, %arg9 * 14] : memref<40x70xf32, #map4>
          %420 = affine.load %arg4[%arg8 * 8 + 6, %arg7] : memref<40x50xf32, #map2>
          %421 = affine.load %arg5[%arg7, %arg9 * 14] : memref<50x70xf32, #map3>
          %422 = arith.mulf %420, %421 : f32
          %423 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14] : memref<40x70xf32, #map4>
          %424 = arith.addf %423, %422 : f32
          affine.store %424, %arg6[%arg8 * 8 + 6, %arg9 * 14] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 1] : memref<40x70xf32, #map4>
          %425 = affine.load %arg4[%arg8 * 8 + 6, %arg7] : memref<40x50xf32, #map2>
          %426 = affine.load %arg5[%arg7, %arg9 * 14 + 1] : memref<50x70xf32, #map3>
          %427 = arith.mulf %425, %426 : f32
          %428 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14 + 1] : memref<40x70xf32, #map4>
          %429 = arith.addf %428, %427 : f32
          affine.store %429, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 1] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 2] : memref<40x70xf32, #map4>
          %430 = affine.load %arg4[%arg8 * 8 + 6, %arg7] : memref<40x50xf32, #map2>
          %431 = affine.load %arg5[%arg7, %arg9 * 14 + 2] : memref<50x70xf32, #map3>
          %432 = arith.mulf %430, %431 : f32
          %433 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14 + 2] : memref<40x70xf32, #map4>
          %434 = arith.addf %433, %432 : f32
          affine.store %434, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 2] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 3] : memref<40x70xf32, #map4>
          %435 = affine.load %arg4[%arg8 * 8 + 6, %arg7] : memref<40x50xf32, #map2>
          %436 = affine.load %arg5[%arg7, %arg9 * 14 + 3] : memref<50x70xf32, #map3>
          %437 = arith.mulf %435, %436 : f32
          %438 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14 + 3] : memref<40x70xf32, #map4>
          %439 = arith.addf %438, %437 : f32
          affine.store %439, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 3] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 4] : memref<40x70xf32, #map4>
          %440 = affine.load %arg4[%arg8 * 8 + 6, %arg7] : memref<40x50xf32, #map2>
          %441 = affine.load %arg5[%arg7, %arg9 * 14 + 4] : memref<50x70xf32, #map3>
          %442 = arith.mulf %440, %441 : f32
          %443 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14 + 4] : memref<40x70xf32, #map4>
          %444 = arith.addf %443, %442 : f32
          affine.store %444, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 4] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 5] : memref<40x70xf32, #map4>
          %445 = affine.load %arg4[%arg8 * 8 + 6, %arg7] : memref<40x50xf32, #map2>
          %446 = affine.load %arg5[%arg7, %arg9 * 14 + 5] : memref<50x70xf32, #map3>
          %447 = arith.mulf %445, %446 : f32
          %448 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14 + 5] : memref<40x70xf32, #map4>
          %449 = arith.addf %448, %447 : f32
          affine.store %449, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 5] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 6] : memref<40x70xf32, #map4>
          %450 = affine.load %arg4[%arg8 * 8 + 6, %arg7] : memref<40x50xf32, #map2>
          %451 = affine.load %arg5[%arg7, %arg9 * 14 + 6] : memref<50x70xf32, #map3>
          %452 = arith.mulf %450, %451 : f32
          %453 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14 + 6] : memref<40x70xf32, #map4>
          %454 = arith.addf %453, %452 : f32
          affine.store %454, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 6] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 7] : memref<40x70xf32, #map4>
          %455 = affine.load %arg4[%arg8 * 8 + 6, %arg7] : memref<40x50xf32, #map2>
          %456 = affine.load %arg5[%arg7, %arg9 * 14 + 7] : memref<50x70xf32, #map3>
          %457 = arith.mulf %455, %456 : f32
          %458 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14 + 7] : memref<40x70xf32, #map4>
          %459 = arith.addf %458, %457 : f32
          affine.store %459, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 7] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 8] : memref<40x70xf32, #map4>
          %460 = affine.load %arg4[%arg8 * 8 + 6, %arg7] : memref<40x50xf32, #map2>
          %461 = affine.load %arg5[%arg7, %arg9 * 14 + 8] : memref<50x70xf32, #map3>
          %462 = arith.mulf %460, %461 : f32
          %463 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14 + 8] : memref<40x70xf32, #map4>
          %464 = arith.addf %463, %462 : f32
          affine.store %464, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 8] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 9] : memref<40x70xf32, #map4>
          %465 = affine.load %arg4[%arg8 * 8 + 6, %arg7] : memref<40x50xf32, #map2>
          %466 = affine.load %arg5[%arg7, %arg9 * 14 + 9] : memref<50x70xf32, #map3>
          %467 = arith.mulf %465, %466 : f32
          %468 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14 + 9] : memref<40x70xf32, #map4>
          %469 = arith.addf %468, %467 : f32
          affine.store %469, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 9] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 10] : memref<40x70xf32, #map4>
          %470 = affine.load %arg4[%arg8 * 8 + 6, %arg7] : memref<40x50xf32, #map2>
          %471 = affine.load %arg5[%arg7, %arg9 * 14 + 10] : memref<50x70xf32, #map3>
          %472 = arith.mulf %470, %471 : f32
          %473 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14 + 10] : memref<40x70xf32, #map4>
          %474 = arith.addf %473, %472 : f32
          affine.store %474, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 10] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 11] : memref<40x70xf32, #map4>
          %475 = affine.load %arg4[%arg8 * 8 + 6, %arg7] : memref<40x50xf32, #map2>
          %476 = affine.load %arg5[%arg7, %arg9 * 14 + 11] : memref<50x70xf32, #map3>
          %477 = arith.mulf %475, %476 : f32
          %478 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14 + 11] : memref<40x70xf32, #map4>
          %479 = arith.addf %478, %477 : f32
          affine.store %479, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 11] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 12] : memref<40x70xf32, #map4>
          %480 = affine.load %arg4[%arg8 * 8 + 6, %arg7] : memref<40x50xf32, #map2>
          %481 = affine.load %arg5[%arg7, %arg9 * 14 + 12] : memref<50x70xf32, #map3>
          %482 = arith.mulf %480, %481 : f32
          %483 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14 + 12] : memref<40x70xf32, #map4>
          %484 = arith.addf %483, %482 : f32
          affine.store %484, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 12] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 13] : memref<40x70xf32, #map4>
          %485 = affine.load %arg4[%arg8 * 8 + 6, %arg7] : memref<40x50xf32, #map2>
          %486 = affine.load %arg5[%arg7, %arg9 * 14 + 13] : memref<50x70xf32, #map3>
          %487 = arith.mulf %485, %486 : f32
          %488 = affine.load %arg6[%arg8 * 8 + 6, %arg9 * 14 + 13] : memref<40x70xf32, #map4>
          %489 = arith.addf %488, %487 : f32
          affine.store %489, %arg6[%arg8 * 8 + 6, %arg9 * 14 + 13] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 7, %arg9 * 14] : memref<40x70xf32, #map4>
          %490 = affine.load %arg4[%arg8 * 8 + 7, %arg7] : memref<40x50xf32, #map2>
          %491 = affine.load %arg5[%arg7, %arg9 * 14] : memref<50x70xf32, #map3>
          %492 = arith.mulf %490, %491 : f32
          %493 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14] : memref<40x70xf32, #map4>
          %494 = arith.addf %493, %492 : f32
          affine.store %494, %arg6[%arg8 * 8 + 7, %arg9 * 14] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 1] : memref<40x70xf32, #map4>
          %495 = affine.load %arg4[%arg8 * 8 + 7, %arg7] : memref<40x50xf32, #map2>
          %496 = affine.load %arg5[%arg7, %arg9 * 14 + 1] : memref<50x70xf32, #map3>
          %497 = arith.mulf %495, %496 : f32
          %498 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14 + 1] : memref<40x70xf32, #map4>
          %499 = arith.addf %498, %497 : f32
          affine.store %499, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 1] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 2] : memref<40x70xf32, #map4>
          %500 = affine.load %arg4[%arg8 * 8 + 7, %arg7] : memref<40x50xf32, #map2>
          %501 = affine.load %arg5[%arg7, %arg9 * 14 + 2] : memref<50x70xf32, #map3>
          %502 = arith.mulf %500, %501 : f32
          %503 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14 + 2] : memref<40x70xf32, #map4>
          %504 = arith.addf %503, %502 : f32
          affine.store %504, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 2] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 3] : memref<40x70xf32, #map4>
          %505 = affine.load %arg4[%arg8 * 8 + 7, %arg7] : memref<40x50xf32, #map2>
          %506 = affine.load %arg5[%arg7, %arg9 * 14 + 3] : memref<50x70xf32, #map3>
          %507 = arith.mulf %505, %506 : f32
          %508 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14 + 3] : memref<40x70xf32, #map4>
          %509 = arith.addf %508, %507 : f32
          affine.store %509, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 3] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 4] : memref<40x70xf32, #map4>
          %510 = affine.load %arg4[%arg8 * 8 + 7, %arg7] : memref<40x50xf32, #map2>
          %511 = affine.load %arg5[%arg7, %arg9 * 14 + 4] : memref<50x70xf32, #map3>
          %512 = arith.mulf %510, %511 : f32
          %513 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14 + 4] : memref<40x70xf32, #map4>
          %514 = arith.addf %513, %512 : f32
          affine.store %514, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 4] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 5] : memref<40x70xf32, #map4>
          %515 = affine.load %arg4[%arg8 * 8 + 7, %arg7] : memref<40x50xf32, #map2>
          %516 = affine.load %arg5[%arg7, %arg9 * 14 + 5] : memref<50x70xf32, #map3>
          %517 = arith.mulf %515, %516 : f32
          %518 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14 + 5] : memref<40x70xf32, #map4>
          %519 = arith.addf %518, %517 : f32
          affine.store %519, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 5] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 6] : memref<40x70xf32, #map4>
          %520 = affine.load %arg4[%arg8 * 8 + 7, %arg7] : memref<40x50xf32, #map2>
          %521 = affine.load %arg5[%arg7, %arg9 * 14 + 6] : memref<50x70xf32, #map3>
          %522 = arith.mulf %520, %521 : f32
          %523 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14 + 6] : memref<40x70xf32, #map4>
          %524 = arith.addf %523, %522 : f32
          affine.store %524, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 6] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 7] : memref<40x70xf32, #map4>
          %525 = affine.load %arg4[%arg8 * 8 + 7, %arg7] : memref<40x50xf32, #map2>
          %526 = affine.load %arg5[%arg7, %arg9 * 14 + 7] : memref<50x70xf32, #map3>
          %527 = arith.mulf %525, %526 : f32
          %528 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14 + 7] : memref<40x70xf32, #map4>
          %529 = arith.addf %528, %527 : f32
          affine.store %529, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 7] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 8] : memref<40x70xf32, #map4>
          %530 = affine.load %arg4[%arg8 * 8 + 7, %arg7] : memref<40x50xf32, #map2>
          %531 = affine.load %arg5[%arg7, %arg9 * 14 + 8] : memref<50x70xf32, #map3>
          %532 = arith.mulf %530, %531 : f32
          %533 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14 + 8] : memref<40x70xf32, #map4>
          %534 = arith.addf %533, %532 : f32
          affine.store %534, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 8] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 9] : memref<40x70xf32, #map4>
          %535 = affine.load %arg4[%arg8 * 8 + 7, %arg7] : memref<40x50xf32, #map2>
          %536 = affine.load %arg5[%arg7, %arg9 * 14 + 9] : memref<50x70xf32, #map3>
          %537 = arith.mulf %535, %536 : f32
          %538 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14 + 9] : memref<40x70xf32, #map4>
          %539 = arith.addf %538, %537 : f32
          affine.store %539, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 9] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 10] : memref<40x70xf32, #map4>
          %540 = affine.load %arg4[%arg8 * 8 + 7, %arg7] : memref<40x50xf32, #map2>
          %541 = affine.load %arg5[%arg7, %arg9 * 14 + 10] : memref<50x70xf32, #map3>
          %542 = arith.mulf %540, %541 : f32
          %543 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14 + 10] : memref<40x70xf32, #map4>
          %544 = arith.addf %543, %542 : f32
          affine.store %544, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 10] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 11] : memref<40x70xf32, #map4>
          %545 = affine.load %arg4[%arg8 * 8 + 7, %arg7] : memref<40x50xf32, #map2>
          %546 = affine.load %arg5[%arg7, %arg9 * 14 + 11] : memref<50x70xf32, #map3>
          %547 = arith.mulf %545, %546 : f32
          %548 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14 + 11] : memref<40x70xf32, #map4>
          %549 = arith.addf %548, %547 : f32
          affine.store %549, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 11] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 12] : memref<40x70xf32, #map4>
          %550 = affine.load %arg4[%arg8 * 8 + 7, %arg7] : memref<40x50xf32, #map2>
          %551 = affine.load %arg5[%arg7, %arg9 * 14 + 12] : memref<50x70xf32, #map3>
          %552 = arith.mulf %550, %551 : f32
          %553 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14 + 12] : memref<40x70xf32, #map4>
          %554 = arith.addf %553, %552 : f32
          affine.store %554, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 12] : memref<40x70xf32, #map4>
          affine.store %cst, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 13] : memref<40x70xf32, #map4>
          %555 = affine.load %arg4[%arg8 * 8 + 7, %arg7] : memref<40x50xf32, #map2>
          %556 = affine.load %arg5[%arg7, %arg9 * 14 + 13] : memref<50x70xf32, #map3>
          %557 = arith.mulf %555, %556 : f32
          %558 = affine.load %arg6[%arg8 * 8 + 7, %arg9 * 14 + 13] : memref<40x70xf32, #map4>
          %559 = arith.addf %558, %557 : f32
          affine.store %559, %arg6[%arg8 * 8 + 7, %arg9 * 14 + 13] : memref<40x70xf32, #map4>
        } {parallel}
      } {parallel}
    }
    return
  }
}

