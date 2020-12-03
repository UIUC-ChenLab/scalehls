// RUN: scalehls-opt -hlskernel-to-affine %s | FileCheck %s

// CHECK: module {
func @test_maxpool(%I: memref<4x4x4x4xf32>, %O: memref<4x4x2x2xf32>) -> () {
  "hlskernel.maxpool" (%I, %O) {kernel_shape=[2, 2], strides=[2, 2], padding=[0, 0, 0, 0]} : (memref<4x4x4x4xf32>, memref<4x4x2x2xf32>) -> ()
  return
}
