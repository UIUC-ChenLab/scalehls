module attributes {llvm.data_layout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128", llvm.target_triple = "x86_64-unknown-linux-gnu"}  {
  func.func @kernel_seidel_2d(%arg0: i32 {scop.constant_value = 100 : i32}, %arg1: i32 {scop.constant_value = 400 : i32}, %arg2: memref<400x400xf32>) attributes {llvm.linkage = #llvm.linkage<external>, phism.top} {
    %cst = arith.constant 9.000000e+00 : f32
    affine.for %arg3 = 0 to 100 {
      affine.for %arg4 = 1 to 399 {
        affine.for %arg5 = 1 to 399 {
          %0 = affine.load %arg2[%arg4 - 1, %arg5 - 1] : memref<400x400xf32>
          %1 = affine.load %arg2[%arg4 - 1, %arg5] : memref<400x400xf32>
          %2 = arith.addf %0, %1 : f32
          %3 = affine.load %arg2[%arg4 - 1, %arg5 + 1] : memref<400x400xf32>
          %4 = arith.addf %2, %3 : f32
          %5 = affine.load %arg2[%arg4, %arg5 - 1] : memref<400x400xf32>
          %6 = arith.addf %4, %5 : f32
          %7 = affine.load %arg2[%arg4, %arg5] : memref<400x400xf32>
          %8 = arith.addf %6, %7 : f32
          %9 = affine.load %arg2[%arg4, %arg5 + 1] : memref<400x400xf32>
          %10 = arith.addf %8, %9 : f32
          %11 = affine.load %arg2[%arg4 + 1, %arg5 - 1] : memref<400x400xf32>
          %12 = arith.addf %10, %11 : f32
          %13 = affine.load %arg2[%arg4 + 1, %arg5] : memref<400x400xf32>
          %14 = arith.addf %12, %13 : f32
          %15 = affine.load %arg2[%arg4 + 1, %arg5 + 1] : memref<400x400xf32>
          %16 = arith.addf %14, %15 : f32
          %17 = arith.divf %16, %cst : f32
          affine.store %17, %arg2[%arg4, %arg5] : memref<400x400xf32>
        }
      }
    }
    return
  }
}

