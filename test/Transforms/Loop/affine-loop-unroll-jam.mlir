// RUN: scalehls-opt -scalehls-affine-loop-unroll-jam="unroll-factor=2" %s | FileCheck %s

// CHECK: #map0 = affine_map<(d0) -> (d0 * 2)>
// CHECK: #map1 = affine_map<(d0) -> (d0 + 1)>
// CHECK: #set0 = affine_set<(d0, d1) : (d0 - d1 >= 0)>
// CHECK: #set1 = affine_set<(d0) : (d0 == 0)>

#set0 = affine_set<(d0, d1) : (d0 - d1 >= 0)>
#set1 = affine_set<(d0) : (d0 == 0)>
module  {
  func @test_syrk(%arg0: f32, %arg1: f32, %arg2: memref<16x16xf32>, %arg3: memref<16x16xf32>) {

    // CHECK: affine.for %arg4 = 0 to 16 {
    // CHECK-NEXT: affine.for %arg5 = 0 to 16 {
    // CHECK-NEXt: affine.for %arg6 = 0 to 8 {
    // CHECK-NOT: affine.for %arg7 = 0 to 2 {
    affine.for %arg4 = 0 to 16 {
      affine.for %arg5 = 0 to 16 {
        affine.for %arg6 = 0 to 16 {
          affine.if #set0(%arg5, %arg6) {
            %0 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32>
            %1 = arith.mulf %arg1, %0 : f32
            affine.if #set1(%arg4) {
              affine.store %1, %arg3[%arg5, %arg6] : memref<16x16xf32>
            }
            %2 = affine.load %arg2[%arg5, %arg4] : memref<16x16xf32>
            %3 = affine.load %arg2[%arg6, %arg4] : memref<16x16xf32>
            %4 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32>
            %5 = arith.mulf %arg0, %2 : f32
            %6 = arith.mulf %5, %3 : f32
            %7 = arith.addf %6, %4 : f32
            affine.store %7, %arg3[%arg5, %arg6] : memref<16x16xf32>
          }

          // CHECK: %1 = affine.apply #map1(%0)
        }
      }
    }
    return
  }
}
