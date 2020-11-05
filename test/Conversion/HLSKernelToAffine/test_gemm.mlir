// RUN: scalehls-opt -hlskernel-to-affine %s | FileCheck %s

// CHECK: module {
func @test_gemm(%x: memref<10x128xf32>, %w: memref<16x128xf32>, %b: memref<16xf32>) -> (memref<10x16xf32>){
  %y = "hlskernel.gemm" (%x, %w, %b) {} : (memref<10x128xf32>, memref<16x128xf32>, memref<16xf32>) -> (memref<10x16xf32>)
  return %y : memref<10x16xf32>
}
