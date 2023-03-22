// RUN: scalehls-opt -scalehls-tosa-simplify-graph %s | FileCheck %s
// XFAIL: *

// CHECK: module {
// CHECK:   func.func @forward(%arg0: tensor<1x3x32x32xf32>) -> tensor<1x10xf32> {
// CHECK:     %0 = "tosa.const"() {value = dense<1.000000e+00> : tensor<1x64x10xf32>} : () -> tensor<1x64x10xf32>
// CHECK:     %1 = "tosa.const"() {value = dense<2.000000e+00> : tensor<64x3x3x64xf32>} : () -> tensor<64x3x3x64xf32>
// CHECK:     %2 = "tosa.const"() {value = dense<3.000000e+00> : tensor<64x3x3x64xf32>} : () -> tensor<64x3x3x64xf32>
// CHECK:     %3 = "tosa.const"() {value = dense<4.000000e+00> : tensor<64x3x3x3xf32>} : () -> tensor<64x3x3x3xf32>
// CHECK:     %4 = "tosa.const"() {value = dense<[0, 3, 1, 2]> : tensor<4xi32>} : () -> tensor<4xi32>
// CHECK:     %5 = "tosa.const"() {value = dense<[0, 2, 3, 1]> : tensor<4xi32>} : () -> tensor<4xi32>
// CHECK:     %6 = "tosa.const"() {value = dense<5.000000e+00> : tensor<64xf32>} : () -> tensor<64xf32>
// CHECK:     %7 = "tosa.transpose"(%arg0, %5) : (tensor<1x3x32x32xf32>, tensor<4xi32>) -> tensor<1x32x32x3xf32>
// CHECK:     %8 = "tosa.conv2d"(%7, %3, %6) {dilation = [1, 1], pad = [1, 1, 1, 1], stride = [1, 1]} : (tensor<1x32x32x3xf32>, tensor<64x3x3x3xf32>, tensor<64xf32>) -> tensor<1x32x32x64xf32>
// CHECK:     %9 = "tosa.clamp"(%8) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xf32>) -> tensor<1x32x32x64xf32>
// CHECK:     %10 = "tosa.conv2d"(%9, %2, %6) {dilation = [1, 1], pad = [1, 1, 1, 1], stride = [1, 1]} : (tensor<1x32x32x64xf32>, tensor<64x3x3x64xf32>, tensor<64xf32>) -> tensor<1x32x32x64xf32>
// CHECK:     %11 = "tosa.clamp"(%10) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xf32>) -> tensor<1x32x32x64xf32>
// CHECK:     %12 = "tosa.conv2d"(%11, %1, %6) {dilation = [1, 1], pad = [1, 1, 1, 1], stride = [1, 1]} : (tensor<1x32x32x64xf32>, tensor<64x3x3x64xf32>, tensor<64xf32>) -> tensor<1x32x32x64xf32>
// CHECK:     %13 = "tosa.add"(%12, %9) : (tensor<1x32x32x64xf32>, tensor<1x32x32x64xf32>) -> tensor<1x32x32x64xf32>
// CHECK:     %14 = "tosa.clamp"(%13) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xf32>) -> tensor<1x32x32x64xf32>
// CHECK:     %15 = "tosa.avg_pool2d"(%14) {kernel = [32, 32], pad = [0, 0, 0, 0], stride = [32, 32]} : (tensor<1x32x32x64xf32>) -> tensor<1x1x1x64xf32>
// CHECK:     %16 = "tosa.transpose"(%15, %4) : (tensor<1x1x1x64xf32>, tensor<4xi32>) -> tensor<1x64x1x1xf32>
// CHECK:     %17 = "tosa.reshape"(%16) {new_shape = [1, 1, 64]} : (tensor<1x64x1x1xf32>) -> tensor<1x1x64xf32>
// CHECK:     %18 = "tosa.matmul"(%17, %0) : (tensor<1x1x64xf32>, tensor<1x64x10xf32>) -> tensor<1x1x10xf32>
// CHECK:     %19 = "tosa.reshape"(%18) {new_shape = [1, 10]} : (tensor<1x1x10xf32>) -> tensor<1x10xf32>
// CHECK:     return %19 : tensor<1x10xf32>
// CHECK:   }
// CHECK: }

module {
  func.func @forward(%arg0: tensor<1x3x32x32xf32>) -> tensor<1x10xf32> {
    %0 = "tosa.const"() {value = dense<0.0> : tensor<1x10xf32>} : () -> tensor<1x10xf32>
    %1 = "tosa.const"() {value = dense<1.0> : tensor<1x64x10xf32>} : () -> tensor<1x64x10xf32>
    %2 = "tosa.const"() {value = dense<2.0> : tensor<64x3x3x64xf32>} : () -> tensor<64x3x3x64xf32>
    %3 = "tosa.const"() {value = dense<3.0> : tensor<64x3x3x64xf32>} : () -> tensor<64x3x3x64xf32>
    %4 = "tosa.const"() {value = dense<4.0> : tensor<64x3x3x3xf32>} : () -> tensor<64x3x3x3xf32>
    %5 = "tosa.const"() {value = dense<[0, 3, 1, 2]> : tensor<4xi32>} : () -> tensor<4xi32>
    %6 = "tosa.const"() {value = dense<[0, 2, 3, 1]> : tensor<4xi32>} : () -> tensor<4xi32>
    %7 = "tosa.const"() {value = dense<5.0> : tensor<64xf32>} : () -> tensor<64xf32>
    %8 = "tosa.transpose"(%arg0, %6) : (tensor<1x3x32x32xf32>, tensor<4xi32>) -> tensor<1x32x32x3xf32>
    %9 = "tosa.conv2d"(%8, %4, %7) {dilation = [1, 1], pad = [1, 1, 1, 1], stride = [1, 1]} : (tensor<1x32x32x3xf32>, tensor<64x3x3x3xf32>, tensor<64xf32>) -> tensor<1x32x32x64xf32>
    %10 = "tosa.transpose"(%9, %5) : (tensor<1x32x32x64xf32>, tensor<4xi32>) -> tensor<1x64x32x32xf32>
    %11 = "tosa.clamp"(%10) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x64x32x32xf32>) -> tensor<1x64x32x32xf32>
    %12 = "tosa.transpose"(%11, %6) : (tensor<1x64x32x32xf32>, tensor<4xi32>) -> tensor<1x32x32x64xf32>
    %13 = "tosa.conv2d"(%12, %3, %7) {dilation = [1, 1], pad = [1, 1, 1, 1], stride = [1, 1]} : (tensor<1x32x32x64xf32>, tensor<64x3x3x64xf32>, tensor<64xf32>) -> tensor<1x32x32x64xf32>
    %14 = "tosa.transpose"(%13, %5) : (tensor<1x32x32x64xf32>, tensor<4xi32>) -> tensor<1x64x32x32xf32>
    %15 = "tosa.clamp"(%14) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x64x32x32xf32>) -> tensor<1x64x32x32xf32>
    %16 = "tosa.transpose"(%15, %6) : (tensor<1x64x32x32xf32>, tensor<4xi32>) -> tensor<1x32x32x64xf32>
    %17 = "tosa.conv2d"(%16, %2, %7) {dilation = [1, 1], pad = [1, 1, 1, 1], stride = [1, 1]} : (tensor<1x32x32x64xf32>, tensor<64x3x3x64xf32>, tensor<64xf32>) -> tensor<1x32x32x64xf32>
    %18 = "tosa.transpose"(%17, %5) : (tensor<1x32x32x64xf32>, tensor<4xi32>) -> tensor<1x64x32x32xf32>
    %19 = "tosa.add"(%18, %11) : (tensor<1x64x32x32xf32>, tensor<1x64x32x32xf32>) -> tensor<1x64x32x32xf32>
    %20 = "tosa.clamp"(%19) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x64x32x32xf32>) -> tensor<1x64x32x32xf32>
    %21 = "tosa.transpose"(%20, %6) : (tensor<1x64x32x32xf32>, tensor<4xi32>) -> tensor<1x32x32x64xf32>
    %22 = "tosa.avg_pool2d"(%21) {kernel = [32, 32], pad = [0, 0, 0, 0], stride = [32, 32]} : (tensor<1x32x32x64xf32>) -> tensor<1x1x1x64xf32>
    %23 = "tosa.transpose"(%22, %5) : (tensor<1x1x1x64xf32>, tensor<4xi32>) -> tensor<1x64x1x1xf32>
    %24 = "tosa.reshape"(%23) {new_shape = [1, 1, 64]} : (tensor<1x64x1x1xf32>) -> tensor<1x1x64xf32>
    %25 = "tosa.matmul"(%24, %1) : (tensor<1x1x64xf32>, tensor<1x64x10xf32>) -> tensor<1x1x10xf32>
    %26 = "tosa.reshape"(%25) {new_shape = [1, 10]} : (tensor<1x1x10xf32>) -> tensor<1x10xf32>
    %27 = "tosa.add"(%26, %0) : (tensor<1x10xf32>, tensor<1x10xf32>) -> tensor<1x10xf32>
    return %27 : tensor<1x10xf32>
  }
}
