// RUN: scalehls-opt -hlskernel-to-affine %s | FileCheck %s

// CHECK: module {
func @test_conv(%I: memref<4x4x4x4xf32>, %K: memref<4x4x3x3xf32>, %B: memref<4xf32>, %O: memref<4x4x4x4xf32>) -> () {
  "hlskernel.conv" (%I, %K, %B, %O) {strides=[1, 1], padding=[1, 1, 1, 1]} : (memref<4x4x4x4xf32>, memref<4x4x3x3xf32>, memref<4xf32>, memref<4x4x4x4xf32>) -> ()
  return
}
