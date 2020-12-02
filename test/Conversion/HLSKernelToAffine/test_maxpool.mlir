// RUN: scalehls-opt -hlskernel-to-affine %s | FileCheck %s

// CHECK: module {
func @test_maxpool(%I: memref<10x16x28x28xf32>, %O: memref<10x16x14x14xf32>) -> () {
  "hlskernel.maxpool" (%I, %O) {kernel_shape=[2, 2], strides=[2, 2], padding=[0, 0, 0, 0]} : (memref<10x16x28x28xf32>, memref<10x16x14x14xf32>) -> ()
  return
}
