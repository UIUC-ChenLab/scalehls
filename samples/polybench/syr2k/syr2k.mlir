#map = affine_map<(d0) -> (d0 + 1)>
module attributes {llvm.data_layout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128", llvm.target_triple = "x86_64-unknown-linux-gnu"}  {
  func.func @kernel_syr2k(%arg0: i32 {scop.constant_value = 240 : i32}, %arg1: i32 {scop.constant_value = 200 : i32}, %arg2: f32, %arg3: f32, %arg4: memref<240x240xf32>, %arg5: memref<240x200xf32>, %arg6: memref<240x200xf32>) attributes {llvm.linkage = #llvm.linkage<external>, phism.top} {
    affine.for %arg7 = 0 to 240 {
      affine.for %arg8 = 0 to #map(%arg7) {
        %0 = affine.load %arg4[%arg7, %arg8] : memref<240x240xf32>
        %1 = arith.mulf %0, %arg3 : f32
        affine.store %1, %arg4[%arg7, %arg8] : memref<240x240xf32>
      }
      affine.for %arg8 = 0 to 200 {
        affine.for %arg9 = 0 to #map(%arg7) {
          %0 = affine.load %arg5[%arg9, %arg8] : memref<240x200xf32>
          %1 = arith.mulf %0, %arg2 : f32
          %2 = affine.load %arg6[%arg7, %arg8] : memref<240x200xf32>
          %3 = arith.mulf %1, %2 : f32
          %4 = affine.load %arg6[%arg9, %arg8] : memref<240x200xf32>
          %5 = arith.mulf %4, %arg2 : f32
          %6 = affine.load %arg5[%arg7, %arg8] : memref<240x200xf32>
          %7 = arith.mulf %5, %6 : f32
          %8 = arith.addf %3, %7 : f32
          %9 = affine.load %arg4[%arg7, %arg9] : memref<240x240xf32>
          %10 = arith.addf %9, %8 : f32
          affine.store %10, %arg4[%arg7, %arg9] : memref<240x240xf32>
        }
      }
    }
    return
  }
}

