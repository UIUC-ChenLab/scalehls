// RUN: scalehls-opt -hlskernel-to-affine %s | FileCheck %s

// CHECK: module {
func @test_merge(%I0: memref<10x16x28x28xf32>, %I1: memref<10x16x28x28xf32>, %O: memref<10x16x28x28xf32>) -> () {
  "hlskernel.merge" (%I0, %I1, %O) {} : (memref<10x16x28x28xf32>, memref<10x16x28x28xf32>, memref<10x16x28x28xf32>) -> ()
  return
}
