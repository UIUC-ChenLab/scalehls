module attributes {llvm.data_layout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128", llvm.target_triple = "x86_64-unknown-linux-gnu"}  {
  func.func @kernel_3mm(%arg0: i32 {scop.constant_value = 180 : i32}, %arg1: i32 {scop.constant_value = 190 : i32}, %arg2: i32 {scop.constant_value = 200 : i32}, %arg3: i32 {scop.constant_value = 210 : i32}, %arg4: i32 {scop.constant_value = 220 : i32}, %arg5: memref<180x190xf32>, %arg6: memref<180x200xf32>, %arg7: memref<200x190xf32>, %arg8: memref<190x210xf32>, %arg9: memref<190x220xf32>, %arg10: memref<220x210xf32>, %arg11: memref<180x210xf32>) attributes {llvm.linkage = #llvm.linkage<external>, phism.top} {
    %cst = arith.constant 0.000000e+00 : f32
    affine.for %arg12 = 0 to 180 {
      affine.for %arg13 = 0 to 190 {
        affine.store %cst, %arg5[%arg12, %arg13] : memref<180x190xf32>
        affine.for %arg14 = 0 to 200 {
          %0 = affine.load %arg6[%arg12, %arg14] : memref<180x200xf32>
          %1 = affine.load %arg7[%arg14, %arg13] : memref<200x190xf32>
          %2 = arith.mulf %0, %1 : f32
          %3 = affine.load %arg5[%arg12, %arg13] : memref<180x190xf32>
          %4 = arith.addf %3, %2 : f32
          affine.store %4, %arg5[%arg12, %arg13] : memref<180x190xf32>
        }
      }
    }
    affine.for %arg12 = 0 to 190 {
      affine.for %arg13 = 0 to 210 {
        affine.store %cst, %arg8[%arg12, %arg13] : memref<190x210xf32>
        affine.for %arg14 = 0 to 220 {
          %0 = affine.load %arg9[%arg12, %arg14] : memref<190x220xf32>
          %1 = affine.load %arg10[%arg14, %arg13] : memref<220x210xf32>
          %2 = arith.mulf %0, %1 : f32
          %3 = affine.load %arg8[%arg12, %arg13] : memref<190x210xf32>
          %4 = arith.addf %3, %2 : f32
          affine.store %4, %arg8[%arg12, %arg13] : memref<190x210xf32>
        }
      }
    }
    affine.for %arg12 = 0 to 180 {
      affine.for %arg13 = 0 to 210 {
        affine.store %cst, %arg11[%arg12, %arg13] : memref<180x210xf32>
        affine.for %arg14 = 0 to 190 {
          %0 = affine.load %arg5[%arg12, %arg14] : memref<180x190xf32>
          %1 = affine.load %arg8[%arg14, %arg13] : memref<190x210xf32>
          %2 = arith.mulf %0, %1 : f32
          %3 = affine.load %arg11[%arg12, %arg13] : memref<180x210xf32>
          %4 = arith.addf %3, %2 : f32
          affine.store %4, %arg11[%arg12, %arg13] : memref<180x210xf32>
        }
      }
    }
    return
  }
}

