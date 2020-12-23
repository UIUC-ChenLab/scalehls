// RUN: scalehls-opt %s | FileCheck %s

// CHECK: module {
func @test_gesummv(%alpha: f32, %beta: f32, %A: memref<16x16xf32>, %B: memref<16x16xf32>, %x: memref<16xf32>, %y: memref<16xf32>, %tmp: memref<16xf32>) {
  affine.for %i = 0 to 16 {
    %cst = constant 0.0 : f32
    affine.store %cst, %tmp[%i] : memref<16xf32>
    affine.store %cst, %y[%i] : memref<16xf32>
    affine.for %j = 0 to 16 {
      %0 = affine.load %A[%i, %j] : memref<16x16xf32>
      %1 = affine.load %x[%j] : memref<16xf32>
      %2 = affine.load %tmp[%i] : memref<16xf32>
      %3 = mulf %1, %0 : f32
      %4 = addf %3, %2 : f32
      affine.store %4, %tmp[%i] : memref<16xf32>
      %5 = affine.load %B[%i, %j] : memref<16x16xf32>
      %6 = affine.load %x[%j] : memref<16xf32>
      %7 = affine.load %y[%i] : memref<16xf32>
      %8 = mulf %6, %5 : f32
      %9 = addf %8, %7 : f32
      affine.store %9, %y[%i] : memref<16xf32>
    }
    %10 = affine.load %tmp[%i] : memref<16xf32>
    %11 = affine.load %y[%i] : memref<16xf32>
    %12 = mulf %alpha, %10 : f32
    %13 = mulf %beta, %11 : f32
    %14 = addf %13, %12 : f32
    affine.store %14, %y[%i] : memref<16xf32>
  }
  return
}
