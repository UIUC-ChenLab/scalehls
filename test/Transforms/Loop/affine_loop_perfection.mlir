// RUN: scalehls-opt -affine-loop-perfection %s | FileCheck %s

module {
  func @test_gemm(%arg0: f32, %arg1: f32, %arg2: memref<32x32xf32>, %arg3: memref<32x32xf32>, %arg4: memref<32x32xf32>) {
    // CHECK: %0 = memref.alloc() : memref<2xf32>
    // CHECK: %1 = memref.alloc() : memref<1xf32>
    affine.for %arg5 = 0 to 32 {
      affine.for %arg6 = 0 to 32 {
        %buf = memref.alloc() : memref<2xf32>
        // CHECK-NOT: %0 = affine.load %arg2[%arg5, %arg6] : memref<32x32xf32>
        // CHECK-NOT: %1 = arith.mulf %0, %arg0 : f32
        %0 = affine.load %arg2[%arg5, %arg6] : memref<32x32xf32>
        %1 = arith.mulf %0, %arg0 : f32
        affine.for %arg7 = 0 to 32 {
          // CHECK: %2 = affine.load %arg2[%arg5, %arg6] : memref<32x32xf32>
          // CHECK: %3 = arith.mulf %2, %arg0 : f32
          // CHECK: affine.if #set0(%arg7) {
          // CHECK:   affine.store %3, %1[0] : memref<1xf32>
          // CHECK: }
          %4 = affine.load %arg3[%arg5, %arg7] : memref<32x32xf32>
          %5 = arith.mulf %1, %4 : f32
          %6 = affine.load %arg4[%arg7, %arg6] : memref<32x32xf32>
          %7 = arith.mulf %5, %6 : f32
          %8 = affine.load %arg2[%arg5, %arg6] : memref<32x32xf32>
          %9 = arith.addf %8, %7 : f32
          %10 = affine.load %buf[0] : memref<2xf32>
          %11 = arith.addf %10, %9 : f32
          affine.store %11, %arg2[%arg5, %arg6] : memref<32x32xf32>
          // CHECK: %13 = affine.load %arg2[%arg5, %arg6] : memref<32x32xf32>
          // CHECK: %14 = arith.addf %13, %3 : f32
          // CHECK: affine.if #set1(%arg7) {
          // CHECK:   affine.store %14, %arg2[%arg5, %arg6] : memref<32x32xf32>
          // CHECK: }
        }
        // CHECK-NOT: %2 = affine.load %arg2[%arg5, %arg6] : memref<32x32xf32>
        // CHECK-NOT: %3 = arith.addf %2, %1 : f32
        // CHECK-NOT: affine.store %3, %arg2[%arg5, %arg6] : memref<32x32xf32>
        %2 = affine.load %arg2[%arg5, %arg6] : memref<32x32xf32>
        %3 = arith.addf %2, %1 : f32
        affine.store %3, %arg2[%arg5, %arg6] : memref<32x32xf32>
      }
    }
    return
  }
}
