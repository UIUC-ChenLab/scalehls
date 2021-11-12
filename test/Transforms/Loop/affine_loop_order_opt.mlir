// RUN: scalehls-opt -affine-loop-order-opt %s | FileCheck %s

#map = affine_map<(d0) -> (d0 + 1)>
#set = affine_set<(d0) : (d0 == 0)>
module  {
  func @test_syrk(%arg0: f32, %arg1: f32, %arg2: memref<16x16xf32>, %arg3: memref<16x16xf32>) {

    // CHECK: affine.for %arg4 = 0 to 16 {
    // CHECK:   affine.for %arg5 = 0 to 16 {
    // CHECK:     affine.for %arg6 = 0 to #map(%arg5) {
    affine.for %arg4 = 0 to 16 {
      affine.for %arg5 = 0 to #map(%arg4) {
        affine.for %arg6 = 0 to 16 {
          %0 = affine.load %arg3[%arg4, %arg5] : memref<16x16xf32>
          %1 = arith.mulf %arg1, %0 : f32
          affine.if #set(%arg6) {
            affine.store %1, %arg3[%arg4, %arg5] : memref<16x16xf32>
          }
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
