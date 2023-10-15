module attributes {llvm.data_layout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128", llvm.target_triple = "x86_64-unknown-linux-gnu"}  {
  func.func @kernel_2mm(%arg0: i32 {scop.constant_value = 180 : i32}, %arg1: i32 {scop.constant_value = 190 : i32}, %arg2: i32 {scop.constant_value = 210 : i32}, %arg3: i32 {scop.constant_value = 220 : i32}, %arg4: f32, %arg5: f32, %arg6: memref<180x190xf32>, %arg7: memref<180x210xf32>, %arg8: memref<210x190xf32>, %arg9: memref<190x220xf32>, %arg10: memref<180x220xf32>) attributes {llvm.linkage = #llvm.linkage<external>, phism.top} {
    %cst = arith.constant 0.000000e+00 : f32
    affine.for %arg11 = 0 to 180 {
      affine.for %arg12 = 0 to 190 {
        affine.store %cst, %arg6[%arg11, %arg12] : memref<180x190xf32>
        affine.for %arg13 = 0 to 210 {
          %0 = affine.load %arg7[%arg11, %arg13] : memref<180x210xf32>
          %1 = arith.mulf %arg4, %0 : f32
          %2 = affine.load %arg8[%arg13, %arg12] : memref<210x190xf32>
          %3 = arith.mulf %1, %2 : f32
          %4 = affine.load %arg6[%arg11, %arg12] : memref<180x190xf32>
          %5 = arith.addf %4, %3 : f32
          affine.store %5, %arg6[%arg11, %arg12] : memref<180x190xf32>
        }
      }
    }
    affine.for %arg11 = 0 to 180 {
      affine.for %arg12 = 0 to 220 {
        %0 = affine.load %arg10[%arg11, %arg12] : memref<180x220xf32>
        %1 = arith.mulf %0, %arg5 : f32
        affine.store %1, %arg10[%arg11, %arg12] : memref<180x220xf32>
        affine.for %arg13 = 0 to 190 {
          %2 = affine.load %arg6[%arg11, %arg13] : memref<180x190xf32>
          %3 = affine.load %arg9[%arg13, %arg12] : memref<190x220xf32>
          %4 = arith.mulf %2, %3 : f32
          %5 = affine.load %arg10[%arg11, %arg12] : memref<180x220xf32>
          %6 = arith.addf %5, %4 : f32
          affine.store %6, %arg10[%arg11, %arg12] : memref<180x220xf32>
        }
      }
    }
    return
  }
}

