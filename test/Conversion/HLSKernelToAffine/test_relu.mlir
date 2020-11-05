// RUN: scalehls-opt -hlskernel-to-affine %s | FileCheck %s

// CHECK: module {
func @test_relu(%x: memref<10x16x28x28xf32>) -> (memref<10x16x28x28xf32>){
  %y = "hlskernel.relu" (%x) {} : (memref<10x16x28x28xf32>) -> (memref<10x16x28x28xf32>)
  return %y : memref<10x16x28x28xf32>
}
