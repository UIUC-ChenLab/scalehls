module attributes {llvm.data_layout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128", llvm.target_triple = "x86_64-unknown-linux-gnu"}  {
  func.func @kernel_gesummv(%arg0: i32 {scop.constant_value = 250 : i32}, %arg1: f32, %arg2: f32, %arg3: memref<250x250xf32>, %arg4: memref<250x250xf32>, %arg5: memref<250xf32>, %arg6: memref<250xf32>, %arg7: memref<250xf32>) attributes {llvm.linkage = #llvm.linkage<external>, phism.top} {
    %cst = arith.constant 0.000000e+00 : f32
    affine.for %arg8 = 0 to 250 {
      affine.store %cst, %arg5[%arg8] : memref<250xf32>
      affine.store %cst, %arg7[%arg8] : memref<250xf32>
      affine.for %arg9 = 0 to 250 {
        %5 = affine.load %arg3[%arg8, %arg9] : memref<250x250xf32>
        %6 = affine.load %arg6[%arg9] : memref<250xf32>
        %7 = arith.mulf %5, %6 : f32
        %8 = affine.load %arg5[%arg8] : memref<250xf32>
        %9 = arith.addf %7, %8 : f32
        affine.store %9, %arg5[%arg8] : memref<250xf32>
        %10 = affine.load %arg4[%arg8, %arg9] : memref<250x250xf32>
        %11 = affine.load %arg6[%arg9] : memref<250xf32>
        %12 = arith.mulf %10, %11 : f32
        %13 = affine.load %arg7[%arg8] : memref<250xf32>
        %14 = arith.addf %12, %13 : f32
        affine.store %14, %arg7[%arg8] : memref<250xf32>
      }
      %0 = affine.load %arg5[%arg8] : memref<250xf32>
      %1 = arith.mulf %arg1, %0 : f32
      %2 = affine.load %arg7[%arg8] : memref<250xf32>
      %3 = arith.mulf %arg2, %2 : f32
      %4 = arith.addf %1, %3 : f32
      affine.store %4, %arg7[%arg8] : memref<250xf32>
    }
    return
  }
}

