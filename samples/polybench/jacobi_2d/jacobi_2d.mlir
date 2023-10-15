module attributes {llvm.data_layout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128", llvm.target_triple = "x86_64-unknown-linux-gnu"}  {
  func.func @kernel_jacobi_2d(%arg0: i32 {scop.constant_value = 100 : i32}, %arg1: i32 {scop.constant_value = 250 : i32}, %arg2: memref<250x250xf32>, %arg3: memref<250x250xf32>) attributes {llvm.linkage = #llvm.linkage<external>, phism.top} {
    %cst = arith.constant 2.000000e-01 : f32
    affine.for %arg4 = 0 to 100 {
      affine.for %arg5 = 1 to 249 {
        affine.for %arg6 = 1 to 249 {
          %0 = affine.load %arg2[%arg5, %arg6] : memref<250x250xf32>
          %1 = affine.load %arg2[%arg5, %arg6 - 1] : memref<250x250xf32>
          %2 = arith.addf %0, %1 : f32
          %3 = affine.load %arg2[%arg5, %arg6 + 1] : memref<250x250xf32>
          %4 = arith.addf %2, %3 : f32
          %5 = affine.load %arg2[%arg5 + 1, %arg6] : memref<250x250xf32>
          %6 = arith.addf %4, %5 : f32
          %7 = affine.load %arg2[%arg5 - 1, %arg6] : memref<250x250xf32>
          %8 = arith.addf %6, %7 : f32
          %9 = arith.mulf %cst, %8 : f32
          affine.store %9, %arg3[%arg5, %arg6] : memref<250x250xf32>
        }
      }
      affine.for %arg5 = 1 to 249 {
        affine.for %arg6 = 1 to 249 {
          %0 = affine.load %arg3[%arg5, %arg6] : memref<250x250xf32>
          %1 = affine.load %arg3[%arg5, %arg6 - 1] : memref<250x250xf32>
          %2 = arith.addf %0, %1 : f32
          %3 = affine.load %arg3[%arg5, %arg6 + 1] : memref<250x250xf32>
          %4 = arith.addf %2, %3 : f32
          %5 = affine.load %arg3[%arg5 + 1, %arg6] : memref<250x250xf32>
          %6 = arith.addf %4, %5 : f32
          %7 = affine.load %arg3[%arg5 - 1, %arg6] : memref<250x250xf32>
          %8 = arith.addf %6, %7 : f32
          %9 = arith.mulf %cst, %8 : f32
          affine.store %9, %arg2[%arg5, %arg6] : memref<250x250xf32>
        }
      }
    }
    return
  }
}

