// RUN: scalehls-opt -legalize-dataflow="min-gran=2 insert-copy=true" -split-function -hlskernel-bufferize -hlskernel-to-affine -func-bufferize %s | FileCheck %s

// CHECK-LABEL: func @auto_gen_cnn
module  {
  func @auto_gen_cnn(%arg0: tensor<1x3x32x32xf32>, %arg1: memref<8x3x3x3xf32>, %arg2: memref<8x8x7x7xf32>, %arg3: memref<16x8x7x7xf32>, %arg4: memref<32x16x7x7xf32>, %arg5: memref<32x32x5x5xf32>, %arg6: memref<64x32x5x5xf32>, %arg7: memref<10x64x4x4xf32>, %arg8: memref<64x16x1x1xf32>, %arg9: memref<8xf32>, %arg10: memref<8xf32>, %arg11: memref<16xf32>, %arg12: memref<32xf32>, %arg13: memref<32xf32>, %arg14: memref<64xf32>, %arg15: memref<10xf32>, %arg16: memref<64xf32>) -> tensor<1x10xf32> {
    %0 = "hlskernel.conv"(%arg0, %arg1, %arg9) {padding = [1, 1, 1, 1], strides = [1, 1]} : (tensor<1x3x32x32xf32>, memref<8x3x3x3xf32>, memref<8xf32>) -> tensor<1x8x32x32xf32>
    %1 = "hlskernel.maxpool"(%0) {kernel_shape = [2, 2], padding = [0, 0, 0, 0], strides = [2, 2]} : (tensor<1x8x32x32xf32>) -> tensor<1x8x16x16xf32>
    %2 = "hlskernel.conv"(%1, %arg2, %arg10) {padding = [3, 3, 3, 3], strides = [1, 1]} : (tensor<1x8x16x16xf32>, memref<8x8x7x7xf32>, memref<8xf32>) -> tensor<1x8x16x16xf32>
    %3 = "hlskernel.conv"(%2, %arg3, %arg11) {padding = [3, 3, 3, 3], strides = [1, 1]} : (tensor<1x8x16x16xf32>, memref<16x8x7x7xf32>, memref<16xf32>) -> tensor<1x16x16x16xf32>
    %4 = "hlskernel.conv"(%3, %arg4, %arg12) {padding = [3, 3, 3, 3], strides = [1, 1]} : (tensor<1x16x16x16xf32>, memref<32x16x7x7xf32>, memref<32xf32>) -> tensor<1x32x16x16xf32>
    %5 = "hlskernel.conv"(%4, %arg5, %arg13) {padding = [2, 2, 2, 2], strides = [1, 1]} : (tensor<1x32x16x16xf32>, memref<32x32x5x5xf32>, memref<32xf32>) -> tensor<1x32x16x16xf32>
    %6 = "hlskernel.maxpool"(%5) {kernel_shape = [2, 2], padding = [0, 0, 0, 0], strides = [2, 2]} : (tensor<1x32x16x16xf32>) -> tensor<1x32x8x8xf32>
    %7 = "hlskernel.conv"(%6, %arg6, %arg14) {padding = [2, 2, 2, 2], strides = [1, 1]} : (tensor<1x32x8x8xf32>, memref<64x32x5x5xf32>, memref<64xf32>) -> tensor<1x64x8x8xf32>
    %8 = "hlskernel.maxpool"(%3) {kernel_shape = [2, 2], padding = [0, 0, 0, 0], strides = [2, 2]} : (tensor<1x16x16x16xf32>) -> tensor<1x16x8x8xf32>
    %9 = "hlskernel.conv"(%8, %arg8, %arg16) {padding = [0, 0, 0, 0], strides = [1, 1]} : (tensor<1x16x8x8xf32>, memref<64x16x1x1xf32>, memref<64xf32>) -> tensor<1x64x8x8xf32>
    %10 = "hlskernel.merge"(%9, %7) : (tensor<1x64x8x8xf32>, tensor<1x64x8x8xf32>) -> tensor<1x64x8x8xf32>
    %11 = "hlskernel.maxpool"(%10) {kernel_shape = [2, 2], padding = [0, 0, 0, 0], strides = [2, 2]} : (tensor<1x64x8x8xf32>) -> tensor<1x64x4x4xf32>
    %12 = "hlskernel.dense"(%11, %arg7, %arg15) : (tensor<1x64x4x4xf32>, memref<10x64x4x4xf32>, memref<10xf32>) -> tensor<1x10xf32>
    return %12 : tensor<1x10xf32>
  }
}
