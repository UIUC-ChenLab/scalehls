// RUN: scalehls-opt -hlskernel-to-affine %s | FileCheck %s

// CHECK: module {
func @test_trmm(%alpha: f32, %A: memref<16x16xf32>, %B: memref<16x16xf32>) -> () {
  "hlskernel.trmm" (%alpha, %A, %B) {} : (f32, memref<16x16xf32>, memref<16x16xf32>) -> ()
  return
}
