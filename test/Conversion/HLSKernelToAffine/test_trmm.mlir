// RUN: scalehls-opt -hlskernel-to-affine %s | FileCheck %s

// CHECK: module {
func @test_trmm(%A: memref<32x32xf32>, %B: memref<32x8xf32>) -> () {
  %alpha = constant 11.0 : f32
  "hlskernel.trmm" (%alpha, %A, %B) {} : (f32, memref<32x32xf32>, memref<32x8xf32>) -> ()
  return
}
