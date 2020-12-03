// RUN: scalehls-opt -hlskernel-to-affine %s | FileCheck %s

// CHECK: module {
func @test_merge(%I0: memref<4x4x4x4xf32>, %I1: memref<4x4x4x4xf32>, %O: memref<4x4x4x4xf32>) -> () {
  "hlskernel.merge" (%I0, %I1, %O) {} : (memref<4x4x4x4xf32>, memref<4x4x4x4xf32>, memref<4x4x4x4xf32>) -> ()
  return
}
