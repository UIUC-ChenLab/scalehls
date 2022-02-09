// RUN: scalehls-opt -legalize-to-hlscpp="top-func=test_syrk" %s | FileCheck %s

#map0 = affine_map<(d0) -> (d0)>
#map1 = affine_map<(d0) -> (d0 + 2)>
#map2 = affine_map<(d0) -> (d0 + 1)>
#set0 = affine_set<(d0, d1) : (d0 - d1 >= 0)>
#set1 = affine_set<(d0) : (d0 == 0)>
module  {
  // CHECK: func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>
  func @test_syrk(%arg0: f32, %arg1: f32, %arg2: memref<16x16xf32>, %arg3: memref<16x16xf32>) {
    affine.for %arg4 = 0 to 16 step 2 {
      affine.for %arg5 = 0 to 16 {
        affine.for %arg6 = 0 to 16 {
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
    // CHECK:           } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=false, parallel=true>}
    // CHECK:         } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=false, parallel=true>}
    // CHECK:       } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=false, parallel=false>}
    // CHECK:     } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=false, parallel=true>}
    // CHECK:   } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=false, parallel=true>}
    // CHECK: } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=false, parallel=false>}
              }
            }
          }
        }
      }
    }
    return
  }
}
