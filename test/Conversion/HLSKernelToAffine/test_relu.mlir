// RUN: scalehls-opt -hlskernel-to-affine %s | FileCheck %s

// CHECK: module {
func @test_relu(%I: memref<10x16x28x28xf32>, %O: memref<10x16x28x28xf32>) -> () {
  "hlskernel.relu" (%I, %O) {} : (memref<10x16x28x28xf32>, memref<10x16x28x28xf32>) -> ()
  return
}
