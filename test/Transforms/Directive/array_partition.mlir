// RUN: scalehls-opt -array-partition %s | FileCheck %s

// CHECK: #map0 = affine_map<(d0, d1) -> (0, d1 mod 2, d0, d1 floordiv 2)>
// CHECK: #map1 = affine_map<(d0, d1) -> (0, 0, d0, d1)>
#set0 = affine_set<(d0, d1) : (d0 - d1 >= 0)>
#set1 = affine_set<(d0) : (d0 == 0)>
module  {

  // CHECK-LABEL: func @test_syrk(
  // CHECK-SAME:  %arg0: f32, %arg1: f32, %arg2: memref<16x16xf32, #map0, 1>, %arg3: memref<16x16xf32, #map1, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>} {
  func @test_syrk(%arg0: f32, %arg1: f32, %arg2: memref<16x16xf32, 1>, %arg3: memref<16x16xf32, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>} {
    affine.for %arg4 = 0 to 16 step 2 {
      affine.for %arg5 = 0 to 16 {
        affine.for %arg6 = 0 to 16 {
          affine.if #set0(%arg5, %arg6) {

            // CHECK: %0 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, #map1, 1>
            %0 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
            %1 = arith.mulf %arg1, %0 : f32

            // CHECK: %2 = affine.load %arg2[%arg5, %arg4] : memref<16x16xf32, #map0, 1>
            %2 = affine.load %arg2[%arg5, %arg4] : memref<16x16xf32, 1>
            %3 = affine.load %arg2[%arg6, %arg4] : memref<16x16xf32, 1>
            %4 = affine.if #set1(%arg4) -> f32 {
              affine.yield %1 : f32
            } else {
              affine.yield %0 : f32
            }
            %5 = arith.mulf %arg0, %2 : f32
            %6 = arith.mulf %5, %3 : f32
            %7 = arith.addf %6, %4 : f32
            %8 = affine.load %arg2[%arg5, %arg4 + 1] : memref<16x16xf32, 1>
            %9 = affine.load %arg2[%arg6, %arg4 + 1] : memref<16x16xf32, 1>
            %10 = arith.mulf %arg0, %8 : f32
            %11 = arith.mulf %10, %9 : f32
            %12 = arith.addf %11, %7 : f32

            // CHECK: affine.store %12, %arg3[%arg5, %arg6] : memref<16x16xf32, #map1, 1>
            affine.store %12, %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
          }
        } {loop_directive = #hlscpp.ld<pipeline=true, targetII=2, dataflow=false, flatten=false, parallel=true>}
      } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true, parallel=true>}
    } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true, parallel=false>}
    return
  }
}
