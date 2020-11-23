// RUN: scalehls-opt -hlskernel-to-linalg %s | FileCheck %s

// CHECK: module {
func @test_symm(%A: memref<16x16xf32>, %B: memref<16x32xf32>, %C: memref<16x32xf32>) -> (memref<16x32xf32>){
  %alpha = constant 1.1 : f32
  %beta = constant 4.2 : f32
  %Cout = "hlskernel.symm" (%alpha, %beta, %A, %B, %C) {} : (f32, f32, memref<16x16xf32>, memref<16x32xf32>, memref<16x32xf32>) -> (memref<16x32xf32>)
  return %Cout : memref<16x32xf32>
}
