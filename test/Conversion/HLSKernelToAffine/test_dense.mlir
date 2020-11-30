// RUN: scalehls-opt -hlskernel-to-affine %s | FileCheck %s

// CHECK: module {
func @test_dense(%I: memref<10x128xf32>, %K: memref<16x128xf32>, %B: memref<16xf32>, %O: memref<10x16xf32>) -> () {
  "hlskernel.dense" (%I, %K, %B, %O) {} : (memref<10x128xf32>, memref<16x128xf32>, memref<16xf32>, memref<10x16xf32>) -> ()
  return
}
