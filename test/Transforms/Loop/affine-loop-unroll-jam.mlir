// RUN: scalehls-opt -scalehls-affine-loop-unroll-jam="unroll-factor=2" %s | FileCheck %s

// CHECK: #map = affine_map<(d0, d1) -> (d1 + d0)>
// CHECK: #map1 = affine_map<(d0) -> (d0 + 1)>
// CHECK: #set = affine_set<(d0, d1) : (d0 - d1 >= 0)>
// CHECK: #set1 = affine_set<(d0) : (d0 == 0)>
// CHECK: module {
// CHECK:   func.func @test_syrk(%arg0: f32, %arg1: f32, %arg2: memref<16x16xf32>, %arg3: memref<16x16xf32>) {
// CHECK:     %c0 = arith.constant 0 : index
// CHECK:     affine.for %arg4 = 0 to 16 {
// CHECK:       affine.for %arg5 = 0 to 16 {
// CHECK:         affine.for %arg6 = 0 to 16 step 2 {
// CHECK:           %0 = affine.apply #map(%arg6, %c0)
// CHECK:           affine.if #set(%arg5, %0) {
// CHECK:             %3 = affine.load %arg3[%arg5, %0] : memref<16x16xf32>
// CHECK:             %4 = arith.mulf %arg1, %3 : f32
// CHECK:             affine.if #set1(%arg4) {
// CHECK:               affine.store %4, %arg3[%arg5, %0] : memref<16x16xf32>
// CHECK:             }
// CHECK:             %5 = affine.load %arg2[%arg5, %arg4] : memref<16x16xf32>
// CHECK:             %6 = affine.load %arg2[%0, %arg4] : memref<16x16xf32>
// CHECK:             %7 = affine.load %arg3[%arg5, %0] : memref<16x16xf32>
// CHECK:             %8 = arith.mulf %arg0, %5 : f32
// CHECK:             %9 = arith.mulf %8, %6 : f32
// CHECK:             %10 = arith.addf %9, %7 : f32
// CHECK:             affine.store %10, %arg3[%arg5, %0] : memref<16x16xf32>
// CHECK:           }
// CHECK:           %1 = affine.apply #map1(%c0)
// CHECK:           %2 = affine.apply #map(%arg6, %1)
// CHECK:           affine.if #set(%arg5, %2) {
// CHECK:             %3 = affine.load %arg3[%arg5, %2] : memref<16x16xf32>
// CHECK:             %4 = arith.mulf %arg1, %3 : f32
// CHECK:             affine.if #set1(%arg4) {
// CHECK:               affine.store %4, %arg3[%arg5, %2] : memref<16x16xf32>
// CHECK:             }
// CHECK:             %5 = affine.load %arg2[%arg5, %arg4] : memref<16x16xf32>
// CHECK:             %6 = affine.load %arg2[%2, %arg4] : memref<16x16xf32>
// CHECK:             %7 = affine.load %arg3[%arg5, %2] : memref<16x16xf32>
// CHECK:             %8 = arith.mulf %arg0, %5 : f32
// CHECK:             %9 = arith.mulf %8, %6 : f32
// CHECK:             %10 = arith.addf %9, %7 : f32
// CHECK:             affine.store %10, %arg3[%arg5, %2] : memref<16x16xf32>
// CHECK:           }
// CHECK:         }
// CHECK:       }
// CHECK:     }
// CHECK:     return
// CHECK:   }
// CHECK: }

#set0 = affine_set<(d0, d1) : (d0 - d1 >= 0)>
#set1 = affine_set<(d0) : (d0 == 0)>
module  {
  func.func @test_syrk(%arg0: f32, %arg1: f32, %arg2: memref<16x16xf32>, %arg3: memref<16x16xf32>) {
    affine.for %arg4 = 0 to 16 {
      affine.for %arg5 = 0 to 16 {
        affine.for %arg6 = 0 to 16 {
          affine.if #set0(%arg5, %arg6) {
            %0 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32>
            %1 = arith.mulf %arg1, %0 : f32
            affine.if #set1(%arg4) {
              affine.store %1, %arg3[%arg5, %arg6] : memref<16x16xf32>
            }
            %2 = affine.load %arg2[%arg5, %arg4] : memref<16x16xf32>
            %3 = affine.load %arg2[%arg6, %arg4] : memref<16x16xf32>
            %4 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32>
            %5 = arith.mulf %arg0, %2 : f32
            %6 = arith.mulf %5, %3 : f32
            %7 = arith.addf %6, %4 : f32
            affine.store %7, %arg3[%arg5, %arg6] : memref<16x16xf32>
          }
        }
      }
    }
    return
  }
}
