// RUN: scalehls-opt -hlskernel-to-affine %s | FileCheck %s

// CHECK: module {
func @test_relu(%I: memref<4x4x4x4xf32>, %O: memref<4x4x4x4xf32>) -> () {
  "hlskernel.relu" (%I, %O) {} : (memref<4x4x4x4xf32>, memref<4x4x4x4xf32>) -> ()
  return
}
