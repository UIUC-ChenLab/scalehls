// RUN: scalehls-opt -scalehls-simplify-affine-if %s | FileCheck %s

// CHECK: #set = affine_set<(d0, d1) : (d0 - d1 >= 0)>
// CHECK: #set1 = affine_set<(d0) : (d0 == 0)>
// CHECK: module {
// CHECK:   func.func @test_syrk(%arg0: f32, %arg1: f32, %arg2: memref<16x16xf32, 1>, %arg3: memref<16x16xf32, 1>) attributes {func_directive = #hls.fd<pipeline=false, targetInterval=1, dataflow=false>, top_func} {
// CHECK:     affine.for %arg4 = 0 to 16 step 2 {
// CHECK:       affine.for %arg5 = 0 to 16 {
// CHECK:         affine.for %arg6 = 0 to 16 {
// CHECK:           affine.if #set(%arg5, %arg6) {
// CHECK:             %0 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
// CHECK:             %1 = arith.mulf %arg1, %0 : f32
// CHECK:             affine.if #set1(%arg4) {
// CHECK:               affine.store %1, %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
// CHECK:             }
// CHECK:             %2 = affine.load %arg2[%arg5, %arg4] : memref<16x16xf32, 1>
// CHECK:             %3 = affine.load %arg2[%arg6, %arg4] : memref<16x16xf32, 1>
// CHECK:             %4 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
// CHECK:             %5 = arith.mulf %arg0, %2 : f32
// CHECK:             %6 = arith.mulf %5, %3 : f32
// CHECK:             %7 = arith.addf %6, %4 : f32
// CHECK:             affine.store %7, %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
// CHECK:           }
// CHECK:           affine.if #set(%arg5, %arg6) {
// CHECK:             %0 = affine.load %arg2[%arg5, %arg4 + 1] : memref<16x16xf32, 1>
// CHECK:             %1 = affine.load %arg2[%arg6, %arg4 + 1] : memref<16x16xf32, 1>
// CHECK:             %2 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
// CHECK:             %3 = arith.mulf %arg0, %0 : f32
// CHECK:             %4 = arith.mulf %3, %1 : f32
// CHECK:             %5 = arith.addf %4, %2 : f32
// CHECK:             affine.store %5, %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
// CHECK:           }
// CHECK:         } {loop_directive = #hls.ld<pipeline=true, targetII=2, dataflow=false, flatten=false>, parallel}
// CHECK:       } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
// CHECK:     } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>}
// CHECK:     return
// CHECK:   }
// CHECK: }

#map = affine_map<(d0) -> (d0 + 1)>
#set0 = affine_set<(d0, d1) : (d0 - d1 >= 0)>
#set1 = affine_set<(d0) : (d0 == 0)>
module  {
  func.func @test_syrk(%arg0: f32, %arg1: f32, %arg2: memref<16x16xf32, 1>, %arg3: memref<16x16xf32, 1>) attributes {func_directive = #hls.fd<pipeline=false, targetInterval=1, dataflow=false>, top_func} {
    affine.for %arg4 = 0 to 16 step 2 {
      affine.for %arg5 = 0 to 16 {
        affine.for %arg6 = 0 to 16 {
          affine.if #set0(%arg5, %arg6) {
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
          %0 = affine.apply #map(%arg4)
          affine.if #set0(%arg5, %arg6) {
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
        } {loop_directive = #hls.ld<pipeline=true, targetII=2, dataflow=false, flatten=false>, parallel}
      } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>}
    return
  }
}
