// RUN: scalehls-opt -hlskernel-to-affine %s | FileCheck %s

// CHECK: module {
func @test_gemm(%A: memref<16x16xf32>, %B: memref<16x16xf32>, %C: memref<16x16xf32>) -> () {
  %alpha = constant 11.0 : f32
  %beta = constant 42.0 : f32
  "hlskernel.gemm" (%alpha, %beta, %A, %B, %C) {} : (f32, f32, memref<16x16xf32>, memref<16x16xf32>, memref<16x16xf32>) -> ()
  return
}
