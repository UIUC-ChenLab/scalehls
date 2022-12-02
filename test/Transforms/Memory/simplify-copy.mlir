// RUN: scalehls-opt -scalehls-simplify-memref-access %s | FileCheck %s

#map = affine_map<(d0) -> (d0 + 1)>
#set0 = affine_set<(d0, d1) : (d0 - d1 >= 0)>
#set1 = affine_set<(d0) : (d0 == 0)>
module  {
  func.func @test_syrk(%arg0: f32, %arg1: f32, %arg2: memref<16x16xf32, 1>, %arg3: memref<16x16xf32, 1>) attributes {func_directive = #hls.fd<pipeline=false, targetInterval=1, dataflow=false>, top_func} {
    affine.for %arg4 = 0 to 16 step 2 {
      affine.for %arg5 = 0 to 16 {
        affine.for %arg6 = 0 to 16 {
          %0 = affine.apply #map(%arg4)
          affine.if #set0(%arg5, %arg6) {

            // CHECK: %1 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
            %1 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
            %2 = arith.mulf %arg1, %1 : f32
            %3 = affine.load %arg2[%arg5, %arg4] : memref<16x16xf32, 1>
            %4 = affine.load %arg2[%arg6, %arg4] : memref<16x16xf32, 1>

            // CHECK-NOT:  %5 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
            %5 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
            %6 = affine.if #set1(%arg4) -> f32 {

              // CHECK-NOT:  affine.store %2, %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
              affine.store %2, %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
              affine.yield %2 : f32
            } else {
              affine.yield %5 : f32
            }
            %7 = arith.mulf %arg0, %3 : f32
            %8 = arith.mulf %7, %4 : f32
            %9 = arith.addf %8, %6 : f32

            // CHECK-NOT:  affine.store %9, %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
            affine.store %9, %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
            %10 = arith.mulf %arg1, %9 : f32
            %11 = affine.load %arg2[%arg5, %arg4 + 1] : memref<16x16xf32, 1>
            %12 = affine.load %arg2[%arg6, %arg4 + 1] : memref<16x16xf32, 1>
            %13 = arith.mulf %arg0, %11 : f32
            %14 = arith.mulf %13, %12 : f32
            %15 = arith.addf %14, %9 : f32

            // CHECK: affine.store %[[VAL_15:.*]], %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
            affine.store %15, %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
          }
        } {loop_directive = #hls.ld<pipeline=true, targetII=2, dataflow=false, flatten=false>, parallel}
      } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>}
    return
  }
}
