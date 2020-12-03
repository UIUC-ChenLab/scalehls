// RUN: scalehls-opt -hlskernel-to-affine %s | FileCheck %s

// CHECK: module {
func @test_syrk(%alpha: f32, %beta: f32, %A: memref<16x16xf32>, %C: memref<16x16xf32>) -> () {
  "hlskernel.syrk" (%alpha, %beta, %A, %C) {} : (f32, f32, memref<16x16xf32>, memref<16x16xf32>) -> ()
  return
}
