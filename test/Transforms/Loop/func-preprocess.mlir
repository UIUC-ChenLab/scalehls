// RUN: scalehls-opt -scalehls-func-preprocess="top-func=test_syrk" -split-input-file %s | FileCheck %s

#map0 = affine_map<(d0) -> (d0)>
#map1 = affine_map<(d0) -> (d0 + 2)>
#map2 = affine_map<(d0) -> (d0 + 1)>
#set0 = affine_set<(d0, d1) : (d0 - d1 >= 0)>
#set1 = affine_set<(d0) : (d0 == 0)>
module  {
  // CHECK: attributes {top_func}
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
    // CHECK:           } {parallel}
    // CHECK:         } {parallel}
    // CHECK:       }
    // CHECK:     } {parallel}
    // CHECK:   } {parallel}
    // CHECK: }
              }
            }
          }
        }
      }
    }
    return
  }
}

// -----

// CHECK-LABEL: func @test_buffer(
// CHECK-SAME:  %arg0: f32, %arg1: memref<16xf32, 1>) -> (f32, memref<16xf32, 1>, i32, memref<2x2xi32, 1>)
func @test_buffer(%arg0: f32, %arg1: memref<16xf32, 1>) -> (f32, memref<16xf32, 1>, i32, memref<2x2xi32, 1>) {
  %c11_i32 = arith.constant 11 : i32
  %cst = arith.constant dense<[[11, 0], [0, -42]]> : tensor<2x2xi32>
  %cst_memref = bufferization.to_memref %cst : memref<2x2xi32, 1>

  // CHECK: %1 = "hls.dataflow.buffer"(%arg0) {depth = 1 : i32} : (f32) -> f32
  // CHECK: %2 = "hls.dataflow.buffer"(%arg1) {depth = 1 : i32} : (memref<16xf32, 1>) -> memref<16xf32, 1>
  // CHECK: %3 = "hls.dataflow.buffer"(%c11_i32) {depth = 1 : i32} : (i32) -> i32
  // CHECK: return %1, %2, %3, %0 : f32, memref<16xf32, 1>, i32, memref<2x2xi32, 1>
  return %arg0, %arg1, %c11_i32, %cst_memref : f32, memref<16xf32, 1>, i32, memref<2x2xi32, 1>
}
