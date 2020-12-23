// RUN: scalehls-opt %s | FileCheck %s

// CHECK: module {
func @test_bicg(%A: memref<16x16xf32>, %p: memref<16xf32>, %r: memref<16xf32>, %q: memref<16xf32>, %s: memref<16xf32>) {
  affine.for %i = 0 to 16 {
    %cst = constant 0.0 : f32
    affine.store %cst, %s[%i] : memref<16xf32>
  }
  affine.for %i = 0 to 16 {
    %cst = constant 0.0 : f32
    affine.store %cst, %q[%i] : memref<16xf32>
    affine.for %j = 0 to 16 {
      %0 = affine.load %A[%i, %j] : memref<16x16xf32>
      %1 = affine.load %r[%i] : memref<16xf32>
      %2 = affine.load %s[%j] : memref<16xf32>
      %3 = mulf %1, %0 : f32
      %4 = addf %3, %2 : f32
      affine.store %4, %s[%j] : memref<16xf32>
      %5 = affine.load %p[%j] : memref<16xf32>
      %6 = affine.load %q[%i] : memref<16xf32>
      %7 = mulf %5, %0 : f32
      %8 = addf %7, %6 : f32
      affine.store %8, %q[%i] : memref<16xf32>
    }
  }
  return
}
