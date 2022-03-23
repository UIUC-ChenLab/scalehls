// RUN: scalehls-opt -scalehls-loop-pipelining="pipeline-level=3 target-ii=2" %s | FileCheck %s

// CHECK-NOT: #map0 = affine_map<(d0) -> (d0)>
// CHECK-NOT: #map1 = affine_map<(d0) -> (d0 + 2)>
#map0 = affine_map<(d0) -> (d0)>
#map1 = affine_map<(d0) -> (d0 + 2)>
#map2 = affine_map<(d0) -> (d0 + 1)>
#set0 = affine_set<(d0, d1) : (d0 - d1 >= 0)>
#set1 = affine_set<(d0) : (d0 == 0)>
module  {
  func @test_syrk(%arg0: f32, %arg1: f32, %arg2: memref<16x16xf32>, %arg3: memref<16x16xf32>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false>, top_func} {
    affine.for %arg4 = 0 to 16 step 2 {
      affine.for %arg5 = 0 to 16 {
        affine.for %arg6 = 0 to 16 {

          // CHECK-NOT: affine.for %arg7 = #map0(%arg4) to #map1(%arg4) {
          // CHECK-NOT:   affine.for %arg8 = #map0(%arg5) to #map2(%arg5) {
          // CHECK-NOT:     affine.for %arg9 = #map0(%arg6) to #map2(%arg6) {
          affine.for %arg7 = #map0(%arg4) to #map1(%arg4) {
            affine.for %arg8 = #map0(%arg5) to #map2(%arg5) {
              affine.for %arg9 = #map0(%arg6) to #map2(%arg6) {
                affine.if #set0(%arg8, %arg9) {
                  %0 = affine.load %arg3[%arg8, %arg9] : memref<16x16xf32>
                  %1 = arith.mulf %arg1, %0 : f32
                  affine.if #set1(%arg7) {
                    affine.store %1, %arg3[%arg8, %arg9] : memref<16x16xf32>
                  }
                  %2 = affine.load %arg2[%arg8, %arg7] : memref<16x16xf32>
                  %3 = affine.load %arg2[%arg9, %arg7] : memref<16x16xf32>
                  %4 = affine.load %arg3[%arg8, %arg9] : memref<16x16xf32>
                  %5 = arith.mulf %arg0, %2 : f32
                  %6 = arith.mulf %5, %3 : f32
                  %7 = arith.addf %6, %4 : f32
                  affine.store %7, %arg3[%arg8, %arg9] : memref<16x16xf32>
                }

                // CHECK: %0 = affine.apply #map(%arg4)
                // CHECK: affine.if #set0(%arg5, %arg6) {
                // CHECK:   %1 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32>
                // CHECK:   %2 = arith.mulf %arg1, %1 : f32
                // CHECK:   affine.if #set1(%0) {
                // CHECK:     affine.store %2, %arg3[%arg5, %arg6] : memref<16x16xf32>
                // CHECK:   }
                // CHECK:   %3 = affine.load %arg2[%arg5, %0] : memref<16x16xf32>
                // CHECK:   %4 = affine.load %arg2[%arg6, %0] : memref<16x16xf32>
                // CHECK:   %5 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32>
                // CHECK:   %6 = arith.mulf %arg0, %3 : f32
                // CHECK:   %7 = arith.mulf %6, %4 : f32
                // CHECK:   %8 = arith.addf %7, %5 : f32
                // CHECK:   affine.store %8, %arg3[%arg5, %arg6] : memref<16x16xf32>
                // CHECK: }

          // CHECK-NOT:     } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=false>, parallel}
          // CHECK-NOT:   } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=false>, parallel}
          // CHECK-NOT: } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=false>}
              } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=false>, parallel}
            } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=false>, parallel}
          } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=false>}

    // CHECK:     } {loop_directive = #hlscpp.ld<pipeline=true, targetII=2, dataflow=false, flatten=false>, parallel}
    // CHECK:   } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    // CHECK: } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>}
        } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=false>, parallel}
      } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=false>, parallel}
    } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=false>}
    return
  }
}
