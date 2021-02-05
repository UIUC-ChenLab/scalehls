// RUN: scalehls-opt %s | FileCheck %s

// CHECK: module {
func @test_gemm(%alpha: f32, %beta: f32, %A: memref<4x4xf32>, %B: memref<4x4xf32>, %C: memref<4x4xf32>) {
  affine.for %i = 0 to 4 {
    affine.for %j = 0 to 4 {
      %0 = affine.load %C[%i, %j] : memref<4x4xf32>
      %1 = mulf %beta, %0 : f32
      affine.store %1, %C[%i, %j] : memref<4x4xf32>
      affine.for %k = 0 to 4 {
        %2 = affine.load %A[%i, %k] : memref<4x4xf32>
        %3 = affine.load %B[%k, %j] : memref<4x4xf32>
        %4 = affine.load %C[%i, %j] : memref<4x4xf32>
        %5 = mulf %alpha, %2 : f32
        %6 = mulf %5, %3 : f32
        %7 = addf %6, %4 : f32
        affine.store %7, %C[%i, %j] : memref<4x4xf32>
      }
    }
  }
  return
}
