// RUN: scalehls-opt -simplify-memref-access %s | FileCheck %s

#map = affine_map<(d0) -> (d0 + 1)>
#set0 = affine_set<(d0, d1) : (d0 - d1 >= 0)>
#set1 = affine_set<(d0) : (d0 == 0)>
module  {
  func @test_syrk(%arg0: f32, %arg1: f32, %arg2: memref<16x16xf32, 1>, %arg3: memref<16x16xf32, 1>) attributes {dataflow = false, top_function = true} {
    affine.for %arg4 = 0 to 16 step 2 {
      affine.for %arg5 = 0 to 16 {
        affine.for %arg6 = 0 to 16 {
          %0 = affine.apply #map(%arg4)
          affine.if #set0(%arg5, %arg6) {

            // CHECK: %[[VAL_1:.*]] = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
            %1 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
            %2 = mulf %arg1, %1 : f32
            %3 = affine.load %arg2[%arg5, %arg4] : memref<16x16xf32, 1>
            %4 = affine.load %arg2[%arg6, %arg4] : memref<16x16xf32, 1>

            // CHECK-NOT:  %[[VAL_5:.*]] = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
            %5 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
            %6 = affine.if #set1(%arg4) -> f32 {

              // CHECK-NOT:  affine.store %[[VAL_2:.*]], %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
              affine.store %2, %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
              affine.yield %2 : f32
            } else {
              affine.yield %5 : f32
            }
            %7 = mulf %arg0, %3 : f32
            %8 = mulf %7, %4 : f32
            %9 = addf %8, %6 : f32

            // CHECK-NOT:  affine.store %[[VAL_9:.*]], %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
            affine.store %9, %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
            %10 = mulf %arg1, %9 : f32
            %11 = affine.load %arg2[%arg5, %arg4 + 1] : memref<16x16xf32, 1>
            %12 = affine.load %arg2[%arg6, %arg4 + 1] : memref<16x16xf32, 1>
            %13 = mulf %arg0, %11 : f32
            %14 = mulf %13, %12 : f32
            %15 = addf %14, %9 : f32

            // CHECK: affine.store %[[VAL_15:.*]], %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
            affine.store %15, %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
          }
        } {flatten = false, pipeline = true, target_ii = 1 : i64}
      } {flatten = true, pipeline = false}
    } {flatten = true, pipeline = false}
    return
  }
}
