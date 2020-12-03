// RUN: scalehls-opt -hlskernel-to-affine %s | FileCheck %s

// CHECK: module {
func @test_dense(%I: memref<16x16xf32>, %K: memref<16x16xf32>, %B: memref<16xf32>, %O: memref<16x16xf32>) -> () {
  "hlskernel.dense" (%I, %K, %B, %O) {} : (memref<16x16xf32>, memref<16x16xf32>, memref<16xf32>, memref<16x16xf32>) -> ()
  return
}
