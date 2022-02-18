module attributes {llvm.data_layout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128", llvm.target_triple = "x86_64-unknown-linux-gnu"}  {
  func @dataflow7(%arg0: f32, %arg1: memref<64x64x3x3xf32>) attributes {llvm.linkage = #llvm.linkage<external>} {
    %0 = memref.alloca() : memref<1x64x34x34xf32>
    %1 = memref.alloca() : memref<1x64x32x32xf32>
    affine.for %arg2 = 0 to 64 {
      affine.for %arg3 = 0 to 32 {
        affine.for %arg4 = 0 to 32 {
          affine.store %arg0, %1[0, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
          affine.for %arg5 = 0 to 64 {
            affine.for %arg6 = 0 to 3 {
              affine.for %arg7 = 0 to 3 {
                %2 = affine.load %0[0, %arg5, %arg3 + %arg6, %arg4 + %arg7] : memref<1x64x34x34xf32>
                %3 = affine.load %arg1[%arg2, %arg5, %arg6, %arg7] : memref<64x64x3x3xf32>
                %4 = affine.load %1[0, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
                %5 = arith.mulf %2, %3 : f32
                %6 = arith.addf %4, %5 : f32
                affine.store %6, %1[0, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
              }
            }
          }
        }
      }
    }
    return
  }
}