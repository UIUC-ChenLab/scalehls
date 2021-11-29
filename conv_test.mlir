module attributes {llvm.data_layout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128", llvm.target_triple = "x86_64-unknown-linux-gnu"}  {
  func @conv5(%arg0: memref<16x5x5xf32>, %arg1: memref<120xf32>, %arg2: memref<120x400xf32>, %arg3: memref<120xf32>) attributes {llvm.linkage = #llvm.linkage<external>} {
    %c0_i32 = arith.constant 0 : i32
    %0 = arith.sitofp %c0_i32 : i32 to f32
    affine.for %arg4 = 0 to 120 {
      %1:2 = affine.for %arg5 = 0 to 16 iter_args(%arg6 = %0, %arg7 = %0) -> (f32, f32) {
        %6:2 = affine.for %arg8 = 0 to 5 iter_args(%arg9 = %arg6, %arg10 = %arg6) -> (f32, f32) {
          %7:2 = affine.for %arg11 = 0 to 5 iter_args(%arg12 = %arg9, %arg13 = %arg9) -> (f32, f32) {
            %8 = affine.load %arg2[%arg4, %arg11 + %arg5 * 25 + %arg8 * 5] : memref<120x400xf32>
            %9 = affine.load %arg0[%arg5, %arg8, %arg11] : memref<16x5x5xf32>
            %10 = arith.mulf %8, %9 : f32
            %11 = arith.addf %arg12, %10 : f32
            affine.yield %11, %11 : f32, f32
          }
          affine.yield %7#1, %7#1 : f32, f32
        }
        affine.yield %6#1, %6#1 : f32, f32
      }
      %2 = affine.load %arg3[%arg4] : memref<120xf32>
      %3 = arith.addf %1#1, %2 : f32
      %4 = arith.cmpf ugt, %3, %0 : f32
      %5 = select %4, %3, %0 : f32
      affine.store %5, %arg1[%arg4] : memref<120xf32>
    }
    return
  }
}