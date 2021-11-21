// RUN: scalehls-opt -affine-loop-perfection %s | FileCheck %s

#map = affine_map<(d0) -> (d0 + 1)>
module  {
  func @test_syrk(%arg0: f32, %arg1: f32, %arg2: memref<16x16xf32>, %arg3: memref<16x16xf32>) {
    affine.for %arg4 = 0 to 16 {
      affine.for %arg5 = 0 to #map(%arg4) {

        // CHECK-NOT: %0 = affine.load %arg3[%arg4, %arg5] : memref<16x16xf32>
        // CHECK-NOT: %1 = arith.mulf %arg1, %0 : f32
        // CHECK-NOT: affine.store %1, %arg3[%arg4, %arg5] : memref<16x16xf32>
        %0 = affine.load %arg3[%arg4, %arg5] : memref<16x16xf32>
        %1 = arith.mulf %arg1, %0 : f32
        affine.store %1, %arg3[%arg4, %arg5] : memref<16x16xf32>
        affine.for %arg6 = 0 to 16 {

          // CHECK: %0 = affine.load %arg3[%arg4, %arg5] : memref<16x16xf32>
          // CHECK: %1 = arith.mulf %arg1, %0 : f32
          // CHECK: affine.if #set(%arg6) {
          // CHECK:   affine.store %1, %arg3[%arg4, %arg5] : memref<16x16xf32>
          // CHECK: }
          %2 = affine.load %arg2[%arg4, %arg6] : memref<16x16xf32>
          %3 = affine.load %arg2[%arg5, %arg6] : memref<16x16xf32>
          %4 = affine.load %arg3[%arg4, %arg5] : memref<16x16xf32>
          %5 = arith.mulf %arg0, %2 : f32
          %6 = arith.mulf %5, %3 : f32
          %7 = arith.addf %6, %4 : f32
          affine.store %7, %arg3[%arg4, %arg5] : memref<16x16xf32>
        }
      }
    }
    return
  }
}
