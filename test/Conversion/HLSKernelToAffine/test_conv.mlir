// RUN: scalehls-opt -hlskernel-to-affine %s | FileCheck %s

// CHECK: module {
func @test_conv(%x: memref<10x3x32x32xf32>, %w: memref<16x3x5x5xf32>, %b: memref<16xf32>) -> (memref<10x16x28x28xf32>){
  %y = "hlskernel.conv" (%x, %w, %b) {} : (memref<10x3x32x32xf32>, memref<16x3x5x5xf32>, memref<16xf32>) -> (memref<10x16x28x28xf32>)
  return %y : memref<10x16x28x28xf32>
}
