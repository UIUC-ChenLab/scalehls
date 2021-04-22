// RUN: scalehls-opt -loop-pipelining="pipeline-level=3 target-ii=2" %s | FileCheck %s

// CHECK-NOT: #map0 = affine_map<(d0) -> (d0)>
// CHECK-NOT: #map1 = affine_map<(d0) -> (d0 + 2)>
#map0 = affine_map<(d0) -> (d0)>
#map1 = affine_map<(d0) -> (d0 + 2)>
#map2 = affine_map<(d0) -> (d0 + 1)>
#set0 = affine_set<(d0, d1) : (d0 - d1 >= 0)>
#set1 = affine_set<(d0) : (d0 == 0)>
module  {
  func @test_syrk(%arg0: f32, %arg1: f32, %arg2: memref<16x16xf32, 1>, %arg3: memref<16x16xf32, 1>) attributes {func_directive = #hlscpp.fd<pipeline=0, targetInterval=1, dataflow=0, topFunc=1>} {
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
                  %0 = affine.load %arg3[%arg8, %arg9] : memref<16x16xf32, 1>
                  %1 = mulf %arg1, %0 : f32
                  affine.if #set1(%arg7) {
                    affine.store %1, %arg3[%arg8, %arg9] : memref<16x16xf32, 1>
                  }
                  %2 = affine.load %arg2[%arg8, %arg7] : memref<16x16xf32, 1>
                  %3 = affine.load %arg2[%arg9, %arg7] : memref<16x16xf32, 1>
                  %4 = affine.load %arg3[%arg8, %arg9] : memref<16x16xf32, 1>
                  %5 = mulf %arg0, %2 : f32
                  %6 = mulf %5, %3 : f32
                  %7 = addf %6, %4 : f32
                  affine.store %7, %arg3[%arg8, %arg9] : memref<16x16xf32, 1>
                }

                // CHECK: %0 = affine.apply #map(%arg4)
                // CHECK: affine.if #set0(%arg5, %arg6) {
                // CHECK:   %1 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
                // CHECK:   %2 = mulf %arg1, %1 : f32
                // CHECK:   affine.if #set1(%0) {
                // CHECK:     affine.store %2, %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
                // CHECK:   }
                // CHECK:   %3 = affine.load %arg2[%arg5, %0] : memref<16x16xf32, 1>
                // CHECK:   %4 = affine.load %arg2[%arg6, %0] : memref<16x16xf32, 1>
                // CHECK:   %5 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
                // CHECK:   %6 = mulf %arg0, %3 : f32
                // CHECK:   %7 = mulf %6, %4 : f32
                // CHECK:   %8 = addf %7, %5 : f32
                // CHECK:   affine.store %8, %arg3[%arg5, %arg6] : memref<16x16xf32, 1>
                // CHECK: }

          // CHECK-NOT:     } {loop_directive = #hlscpp.ld<pipeline=0, targetII=1, dataflow=0, flatten=0, parallel=1>}
          // CHECK-NOT:   } {loop_directive = #hlscpp.ld<pipeline=0, targetII=1, dataflow=0, flatten=0, parallel=1>}
          // CHECK-NOT: } {loop_directive = #hlscpp.ld<pipeline=0, targetII=1, dataflow=0, flatten=0, parallel=0>}
              } {loop_directive = #hlscpp.ld<pipeline=0, targetII=1, dataflow=0, flatten=0, parallel=1>}
            } {loop_directive = #hlscpp.ld<pipeline=0, targetII=1, dataflow=0, flatten=0, parallel=1>}
          } {loop_directive = #hlscpp.ld<pipeline=0, targetII=1, dataflow=0, flatten=0, parallel=0>}

    // CHECK:     } {loop_directive = #hlscpp.ld<pipeline=1, targetII=2, dataflow=0, flatten=0, parallel=1>}
    // CHECK:   } {loop_directive = #hlscpp.ld<pipeline=0, targetII=1, dataflow=0, flatten=1, parallel=1>}
    // CHECK: } {loop_directive = #hlscpp.ld<pipeline=0, targetII=1, dataflow=0, flatten=1, parallel=0>}
        } {loop_directive = #hlscpp.ld<pipeline=0, targetII=1, dataflow=0, flatten=0, parallel=1>}
      } {loop_directive = #hlscpp.ld<pipeline=0, targetII=1, dataflow=0, flatten=0, parallel=1>}
    } {loop_directive = #hlscpp.ld<pipeline=0, targetII=1, dataflow=0, flatten=0, parallel=0>}
    return
  }
}
