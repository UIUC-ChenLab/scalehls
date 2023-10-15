#map = affine_map<(d0) -> (d0)>
module attributes {llvm.data_layout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128", llvm.target_triple = "x86_64-unknown-linux-gnu"}  {
  func.func @kernel_symm(%arg0: i32 {scop.constant_value = 200 : i32}, %arg1: i32 {scop.constant_value = 240 : i32}, %arg2: f32, %arg3: f32, %arg4: memref<200x240xf32>, %arg5: memref<200x200xf32>, %arg6: memref<200x240xf32>) attributes {llvm.linkage = #llvm.linkage<external>, phism.top} {
    %c0_i32 = arith.constant 0 : i32
    %0 = memref.alloca() : memref<1xf32>
    %1 = arith.sitofp %c0_i32 : i32 to f32
    affine.for %arg7 = 0 to 200 {
      affine.for %arg8 = 0 to 240 {
        affine.store %1, %0[0] : memref<1xf32>
        affine.for %arg9 = 0 to #map(%arg7) {
          %12 = affine.load %arg6[%arg7, %arg8] : memref<200x240xf32>
          %13 = arith.mulf %arg2, %12 : f32
          %14 = affine.load %arg5[%arg7, %arg9] : memref<200x200xf32>
          %15 = arith.mulf %13, %14 : f32
          %16 = affine.load %arg4[%arg9, %arg8] : memref<200x240xf32>
          %17 = arith.addf %16, %15 : f32
          affine.store %17, %arg4[%arg9, %arg8] : memref<200x240xf32>
          %18 = affine.load %arg6[%arg9, %arg8] : memref<200x240xf32>
          %19 = affine.load %arg5[%arg7, %arg9] : memref<200x200xf32>
          %20 = arith.mulf %18, %19 : f32
          %21 = affine.load %0[0] : memref<1xf32>
          %22 = arith.addf %21, %20 : f32
          affine.store %22, %0[0] : memref<1xf32>
        }
        %2 = affine.load %arg4[%arg7, %arg8] : memref<200x240xf32>
        %3 = arith.mulf %arg3, %2 : f32
        %4 = affine.load %arg6[%arg7, %arg8] : memref<200x240xf32>
        %5 = arith.mulf %arg2, %4 : f32
        %6 = affine.load %arg5[%arg7, %arg7] : memref<200x200xf32>
        %7 = arith.mulf %5, %6 : f32
        %8 = arith.addf %3, %7 : f32
        %9 = affine.load %0[0] : memref<1xf32>
        %10 = arith.mulf %arg2, %9 : f32
        %11 = arith.addf %8, %10 : f32
        affine.store %11, %arg4[%arg7, %arg8] : memref<200x240xf32>
      }
    }
    return
  }
}

