module attributes {llvm.data_layout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128", llvm.target_triple = "x86_64-unknown-linux-gnu"}  {
  func.func @kernel_atax(%arg0: i32 {scop.constant_value = 390 : i32}, %arg1: i32 {scop.constant_value = 410 : i32}, %arg2: memref<390x410xf32>, %arg3: memref<410xf32>, %arg4: memref<410xf32>, %arg5: memref<390xf32>) attributes {llvm.linkage = #llvm.linkage<external>, phism.top} {
    %c0_i32 = arith.constant 0 : i32
    %cst = arith.constant 0.000000e+00 : f32
    %0 = arith.sitofp %c0_i32 : i32 to f32
    affine.for %arg6 = 0 to 410 {
      affine.store %0, %arg4[%arg6] : memref<410xf32>
    }
    affine.for %arg6 = 0 to 390 {
      affine.store %cst, %arg5[%arg6] : memref<390xf32>
      affine.for %arg7 = 0 to 410 {
        %1 = affine.load %arg5[%arg6] : memref<390xf32>
        %2 = affine.load %arg2[%arg6, %arg7] : memref<390x410xf32>
        %3 = affine.load %arg3[%arg7] : memref<410xf32>
        %4 = arith.mulf %2, %3 : f32
        %5 = arith.addf %1, %4 : f32
        affine.store %5, %arg5[%arg6] : memref<390xf32>
      }
      affine.for %arg7 = 0 to 410 {
        %1 = affine.load %arg4[%arg7] : memref<410xf32>
        %2 = affine.load %arg2[%arg6, %arg7] : memref<390x410xf32>
        %3 = affine.load %arg5[%arg6] : memref<390xf32>
        %4 = arith.mulf %2, %3 : f32
        %5 = arith.addf %1, %4 : f32
        affine.store %5, %arg4[%arg7] : memref<410xf32>
      }
    }
    return
  }
}

