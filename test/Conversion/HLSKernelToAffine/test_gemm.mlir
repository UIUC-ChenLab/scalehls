// RUN: scalehls-opt -hlskernel-to-affine %s | FileCheck %s

// CHECK: module {
func @test_gemm(%alpha: f32, %beta: f32, %A: memref<16x16xf32>, %B: memref<16x16xf32>, %C: memref<16x16xf32>) -> () {
  "hlskernel.gemm" (%alpha, %beta, %A, %B, %C) {} : (f32, f32, memref<16x16xf32>, memref<16x16xf32>, memref<16x16xf32>) -> ()
  return
}
