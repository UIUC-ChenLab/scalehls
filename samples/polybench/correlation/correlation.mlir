#map = affine_map<(d0) -> (d0 + 1)>
module attributes {llvm.data_layout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128", llvm.target_triple = "x86_64-unknown-linux-gnu"}  {
  func.func @kernel_correlation(%arg0: i32 {scop.constant_value = 240 : i32}, %arg1: i32 {scop.constant_value = 260 : i32}, %arg2: f32, %arg3: memref<260x240xf32>, %arg4: memref<240x240xf32>, %arg5: memref<240xf32>, %arg6: memref<240xf32>) attributes {llvm.linkage = #llvm.linkage<external>, phism.top} {
    %cst = arith.constant 1.000000e-01 : f32
    %cst_0 = arith.constant 0.000000e+00 : f32
    %cst_1 = arith.constant 1.000000e+00 : f32
    affine.for %arg7 = 0 to 240 {
      affine.store %cst_0, %arg5[%arg7] : memref<240xf32>
      affine.for %arg8 = 0 to 260 {
        %3 = affine.load %arg3[%arg8, %arg7] : memref<260x240xf32>
        %4 = affine.load %arg5[%arg7] : memref<240xf32>
        %5 = arith.addf %4, %3 : f32
        affine.store %5, %arg5[%arg7] : memref<240xf32>
      }
      %1 = affine.load %arg5[%arg7] : memref<240xf32>
      %2 = arith.divf %1, %arg2 : f32
      affine.store %2, %arg5[%arg7] : memref<240xf32>
    }
    affine.for %arg7 = 0 to 240 {
      affine.store %cst_0, %arg6[%arg7] : memref<240xf32>
      affine.for %arg8 = 0 to 260 {
        %6 = affine.load %arg3[%arg8, %arg7] : memref<260x240xf32>
        %7 = affine.load %arg5[%arg7] : memref<240xf32>
        %8 = arith.subf %6, %7 : f32
        %9 = arith.subf %6, %7 : f32
        %10 = arith.mulf %8, %9 : f32
        %11 = affine.load %arg6[%arg7] : memref<240xf32>
        %12 = arith.addf %11, %10 : f32
        affine.store %12, %arg6[%arg7] : memref<240xf32>
      }
      %1 = affine.load %arg6[%arg7] : memref<240xf32>
      %2 = arith.divf %1, %arg2 : f32
      %3 = math.sqrt %2 : f32
      %4 = arith.cmpf ule, %3, %cst : f32
      %5 = arith.select %4, %cst_1, %3 : f32
      affine.store %5, %arg6[%arg7] : memref<240xf32>
    }
    %0 = math.sqrt %arg2 : f32
    affine.for %arg7 = 0 to 260 {
      affine.for %arg8 = 0 to 240 {
        %1 = affine.load %arg5[%arg8] : memref<240xf32>
        %2 = affine.load %arg3[%arg7, %arg8] : memref<260x240xf32>
        %3 = arith.subf %2, %1 : f32
        affine.store %3, %arg3[%arg7, %arg8] : memref<260x240xf32>
        %4 = affine.load %arg6[%arg8] : memref<240xf32>
        %5 = arith.mulf %0, %4 : f32
        %6 = arith.divf %3, %5 : f32
        affine.store %6, %arg3[%arg7, %arg8] : memref<260x240xf32>
      }
    }
    affine.for %arg7 = 0 to 239 {
      affine.store %cst_1, %arg4[%arg7, %arg7] : memref<240x240xf32>
      affine.for %arg8 = #map(%arg7) to 240 {
        affine.store %cst_0, %arg4[%arg7, %arg8] : memref<240x240xf32>
        affine.for %arg9 = 0 to 260 {
          %2 = affine.load %arg3[%arg9, %arg7] : memref<260x240xf32>
          %3 = affine.load %arg3[%arg9, %arg8] : memref<260x240xf32>
          %4 = arith.mulf %2, %3 : f32
          %5 = affine.load %arg4[%arg7, %arg8] : memref<240x240xf32>
          %6 = arith.addf %5, %4 : f32
          affine.store %6, %arg4[%arg7, %arg8] : memref<240x240xf32>
        }
        %1 = affine.load %arg4[%arg7, %arg8] : memref<240x240xf32>
        affine.store %1, %arg4[%arg8, %arg7] : memref<240x240xf32>
      }
    }
    affine.store %cst_1, %arg4[239, 239] : memref<240x240xf32>
    return
  }
}

