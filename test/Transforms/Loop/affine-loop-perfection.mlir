// RUN: scalehls-opt -buffer-loop-hoisting -scalehls-affine-loop-perfection %s | FileCheck %s

// CHECK: #set = affine_set<(d0) : (d0 == 0)>
// CHECK: #set1 = affine_set<(d0) : (-d0 + 31 == 0)>
// CHECK: module {
// CHECK:   func.func @test_perfection(%arg0: f32, %arg1: f32, %arg2: memref<32x32xf32>, %arg3: memref<32x32xf32>, %arg4: memref<32x32xf32>) {
// CHECK:     %alloc = memref.alloc() : memref<2xf32>
// CHECK:     %0 = hls.dataflow.buffer {depth = 1 : i32} : memref<1xf32>
// CHECK:     affine.for %arg5 = 0 to 32 {
// CHECK:       affine.for %arg6 = 0 to 32 {
// CHECK:         affine.for %arg7 = 0 to 32 {
// CHECK:           %1 = affine.load %arg2[%arg5, %arg6] : memref<32x32xf32>
// CHECK:           %2 = arith.mulf %1, %arg0 : f32
// CHECK:           affine.if #set(%arg7) {
// CHECK:             affine.store %2, %0[0] : memref<1xf32>
// CHECK:           }
// CHECK:           %3 = affine.load %arg3[%arg5, %arg7] : memref<32x32xf32>
// CHECK:           %4 = affine.load %0[0] : memref<1xf32>
// CHECK:           %5 = arith.mulf %4, %3 : f32
// CHECK:           %6 = affine.load %arg4[%arg7, %arg6] : memref<32x32xf32>
// CHECK:           %7 = arith.mulf %5, %6 : f32
// CHECK:           %8 = affine.load %arg2[%arg5, %arg6] : memref<32x32xf32>
// CHECK:           %9 = arith.addf %8, %7 : f32
// CHECK:           %10 = affine.load %alloc[0] : memref<2xf32>
// CHECK:           %11 = arith.addf %10, %9 : f32
// CHECK:           affine.store %11, %arg2[%arg5, %arg6] : memref<32x32xf32>
// CHECK:           %12 = affine.load %arg2[%arg5, %arg6] : memref<32x32xf32>
// CHECK:           %13 = arith.addf %12, %2 : f32
// CHECK:           affine.if #set1(%arg7) {
// CHECK:             affine.store %13, %arg2[%arg5, %arg6] : memref<32x32xf32>
// CHECK:           }
// CHECK:         }
// CHECK:       }
// CHECK:     }
// CHECK:     return
// CHECK:   }
// CHECK: }

module {
  func.func @test_perfection(%arg0: f32, %arg1: f32, %arg2: memref<32x32xf32>, %arg3: memref<32x32xf32>, %arg4: memref<32x32xf32>) {
    affine.for %arg5 = 0 to 32 {
      affine.for %arg6 = 0 to 32 {
        %buf = memref.alloc() : memref<2xf32>
        %0 = affine.load %arg2[%arg5, %arg6] : memref<32x32xf32>
        %1 = arith.mulf %0, %arg0 : f32
        affine.for %arg7 = 0 to 32 {
          %4 = affine.load %arg3[%arg5, %arg7] : memref<32x32xf32>
          %5 = arith.mulf %1, %4 : f32
          %6 = affine.load %arg4[%arg7, %arg6] : memref<32x32xf32>
          %7 = arith.mulf %5, %6 : f32
          %8 = affine.load %arg2[%arg5, %arg6] : memref<32x32xf32>
          %9 = arith.addf %8, %7 : f32
          %10 = affine.load %buf[0] : memref<2xf32>
          %11 = arith.addf %10, %9 : f32
          affine.store %11, %arg2[%arg5, %arg6] : memref<32x32xf32>
        }
        %2 = affine.load %arg2[%arg5, %arg6] : memref<32x32xf32>
        %3 = arith.addf %2, %1 : f32
        affine.store %3, %arg2[%arg5, %arg6] : memref<32x32xf32>
      }
    }
    return
  }
}
