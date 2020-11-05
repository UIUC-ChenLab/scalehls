// RUN: scalehls-opt -hlskernel-to-affine %s | FileCheck %s

// CHECK: module {
func @test_maxpool(%x: memref<10x16x28x28xf32>) -> (memref<10x16x14x14xf32>){
  %y = "hlskernel.maxpool" (%x) {kernel_shape=[2, 2]} : (memref<10x16x28x28xf32>) -> (memref<10x16x14x14xf32>)
  return %y : memref<10x16x14x14xf32>
}
