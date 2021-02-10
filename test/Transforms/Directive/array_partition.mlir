// RUN: scalehls-opt -array-partition %s | FileCheck %s

// CHECK: #map0 = affine_map<(d0, d1) -> (0, d1 mod 2, d0, d1 floordiv 2)>
// CHECK: #map1 = affine_map<(d0, d1) -> (0, 0, d0, d1)>
#set0 = affine_set<(d0, d1) : (d0 - d1 >= 0)>
#set1 = affine_set<(d0) : (d0 == 0)>
module  {

  // CHECK-LABEL: func @test_syrk(
  // CHECK-SAME:  %arg0: f32, %arg1: f32, %arg2: memref<16x16xf32, #map0, 1>, %arg3: memref<16x16xf32, #map1, 1>) attributes {dataflow = false, top_function = true} {
  func @test_syrk(%arg0: f32, %arg1: f32, %arg2: memref<16x16xf32, 1>, %arg3: memref<16x16xf32, 1>) attributes {dataflow = false, top_function = true} {
    affine.for %arg4 = 0 to 16 step 2 {
      affine.for %arg5 = 0 to 16 {
        affine.for %arg6 = 0 to 16 {
          affine.if #set0(%arg5, %arg6) {

            // CHECK: %0 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, #map1, 1>
            %0 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
            %1 = mulf %arg1, %0 : f32

            // CHECK: %2 = affine.load %arg2[%arg5, %arg4] : memref<16x16xf32, #map0, 1>
            %2 = affine.load %arg2[%arg5, %arg4] : memref<16x16xf32, 1>
            %3 = affine.load %arg2[%arg6, %arg4] : memref<16x16xf32, 1>
            %4 = affine.if #set1(%arg4) -> f32 {
              affine.yield %1 : f32
            } else {
              affine.yield %0 : f32
            }
            %5 = mulf %arg0, %2 : f32
            %6 = mulf %5, %3 : f32
            %7 = addf %6, %4 : f32
            %8 = affine.load %arg2[%arg5, %arg4 + 1] : memref<16x16xf32, 1>
            %9 = affine.load %arg2[%arg6, %arg4 + 1] : memref<16x16xf32, 1>
            %10 = mulf %arg0, %8 : f32
            %11 = mulf %10, %9 : f32
            %12 = addf %11, %7 : f32

            // CHECK: affine.store %12, %arg3[%arg5, %arg6] : memref<16x16xf32, #map1, 1>
            affine.store %12, %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
          }
        } {flatten = false, pipeline = true, target_ii = 1 : i64}
      } {flatten = true, pipeline = false}
    } {flatten = true, pipeline = false}
    return
  }
}
