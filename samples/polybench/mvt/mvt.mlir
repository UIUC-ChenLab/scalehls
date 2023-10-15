module attributes {llvm.data_layout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128", llvm.target_triple = "x86_64-unknown-linux-gnu"}  {
  func.func @kernel_mvt(%arg0: i32 {scop.constant_value = 400 : i32}, %arg1: memref<400xf32>, %arg2: memref<400xf32>, %arg3: memref<400xf32>, %arg4: memref<400xf32>, %arg5: memref<400x400xf32>) attributes {llvm.linkage = #llvm.linkage<external>, phism.top} {
    affine.for %arg6 = 0 to 400 {
      affine.for %arg7 = 0 to 400 {
        %0 = affine.load %arg1[%arg6] : memref<400xf32>
        %1 = affine.load %arg5[%arg6, %arg7] : memref<400x400xf32>
        %2 = affine.load %arg3[%arg7] : memref<400xf32>
        %3 = arith.mulf %1, %2 : f32
        %4 = arith.addf %0, %3 : f32
        affine.store %4, %arg1[%arg6] : memref<400xf32>
      }
    }
    affine.for %arg6 = 0 to 400 {
      affine.for %arg7 = 0 to 400 {
        %0 = affine.load %arg2[%arg6] : memref<400xf32>
        %1 = affine.load %arg5[%arg7, %arg6] : memref<400x400xf32>
        %2 = affine.load %arg4[%arg7] : memref<400xf32>
        %3 = arith.mulf %1, %2 : f32
        %4 = arith.addf %0, %3 : f32
        affine.store %4, %arg2[%arg6] : memref<400xf32>
      }
    }
    return
  }
}

