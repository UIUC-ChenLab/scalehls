// RUN: scalehls-opt -hlskernel-to-affine %s | FileCheck %s

// CHECK: module {
func @test_syrk(%A: memref<32x8xf32>, %C: memref<32x32xf32>) -> () {
  %alpha = constant 11.0 : f32
  %beta = constant 42.0 : f32
  "hlskernel.syrk" (%alpha, %beta, %A, %C) {} : (f32, f32, memref<32x8xf32>, memref<32x32xf32>) -> ()
  return
}
