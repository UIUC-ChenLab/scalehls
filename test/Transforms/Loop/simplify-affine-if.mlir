// RUN: scalehls-opt -scalehls-simplify-affine-if %s | FileCheck %s

#map = affine_map<(d0) -> (d0 + 1)>
#set0 = affine_set<(d0, d1) : (d0 - d1 >= 0)>
#set1 = affine_set<(d0) : (d0 == 0)>
module  {
  func @test_syrk(%arg0: f32, %arg1: f32, %arg2: memref<16x16xf32, 1>, %arg3: memref<16x16xf32, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false>, top_func} {
    affine.for %arg4 = 0 to 16 step 2 {
      affine.for %arg5 = 0 to 16 {
        affine.for %arg6 = 0 to 16 {
          // CHECK: affine.if #set0(%arg5, %arg6) {
          affine.if #set0(%arg5, %arg6) {

            // CHECK: %1 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
            %1 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
            %2 = arith.mulf %arg1, %1 : f32
            affine.if #set1(%arg4) {
              affine.store %2, %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
            }
            %3 = affine.load %arg2[%arg5, %arg4] : memref<16x16xf32, 1>
            %4 = affine.load %arg2[%arg6, %arg4] : memref<16x16xf32, 1>
            %5 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
            %6 = arith.mulf %arg0, %3 : f32
            %7 = arith.mulf %6, %4 : f32
            %8 = arith.addf %7, %5 : f32
            affine.store %8, %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
          }

          // CHECK-NOT: %0 = affine.apply #map(%arg4)
          // CHECK-NOT: affine.if #set0(%arg5, %arg6) {
          %0 = affine.apply #map(%arg4)
          affine.if #set0(%arg5, %arg6) {

            // CHECK-NOT: %1 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
            // CHECK: %9 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
            %1 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
            %2 = arith.mulf %arg1, %1 : f32
            affine.if #set1(%0) {
              affine.store %2, %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
            }
            %3 = affine.load %arg2[%arg5, %arg4 + 1] : memref<16x16xf32, 1>
            %4 = affine.load %arg2[%arg6, %arg4 + 1] : memref<16x16xf32, 1>
            %5 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
            %6 = arith.mulf %arg0, %3 : f32
            %7 = arith.mulf %6, %4 : f32
            %8 = arith.addf %7, %5 : f32
            affine.store %8, %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
          }
        } {loop_directive = #hlscpp.ld<pipeline=true, targetII=2, dataflow=false, flatten=false>, parallel}
      } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>}
    return
  }
}
