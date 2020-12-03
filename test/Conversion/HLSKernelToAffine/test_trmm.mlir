// RUN: scalehls-opt -hlskernel-to-affine %s | FileCheck %s

// CHECK: module {
func @test_trmm(%A: memref<16x16xf32>, %B: memref<16x16xf32>) -> () {
  %alpha = constant 11.0 : f32
  "hlskernel.trmm" (%alpha, %A, %B) {} : (f32, memref<16x16xf32>, memref<16x16xf32>) -> ()
  return
}
