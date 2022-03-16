// RUN: scalehls-opt -scalehls-func-dataflow="min-gran=3 insert-copy=true" %s | FileCheck %s

module {
  // CHECK: func @dataflow2(%arg0: tensor<1x32x32x64xi8>) -> tensor<1x1x64xi8> {
  // CHECK:   %1 = "tosa.avg_pool2d"
  // CHECK:   %2 = "tosa.transpose"
  // CHECK:   %3 = tensor.reshape
  // CHECK:   return %3 : tensor<1x1x64xi8>
  // CHECK: }

  // CHECK: func @dataflow4(%arg0: tensor<1x32x32x64xi8>) -> (tensor<1x32x32x64xi8>, tensor<1x32x32x64xi8>) {
  // CHECK:   %2 = "tosa.clamp"
  // CHECK:   %3 = "tosa.conv2d"
  // CHECK:   %4 = "tosa.clamp"
  // CHECK:   %5 = "hlscpp.assign"
  // CHECK:   return %4, %5
  // CHECK: }

  // CHECK: func @dataflow1(%arg0: tensor<1x1x64xi8>) -> tensor<1x10xi8> {
  // CHECK:   %2 = "tosa.matmul"
  // CHECK:   %3 = tensor.reshape
  // CHECK:   %4 = "tosa.add"
  // CHECK:   return %4
  // CHECK: }

  // CHECK: func @dataflow3(%arg0: tensor<1x32x32x64xi8>, %arg1: tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8> {
  // CHECK:   %2 = "tosa.conv2d"
  // CHECK:   %3 = "hlscpp.assign"
  // CHECK:   %4 = "tosa.add"
  // CHECK:   %5 = "tosa.clamp"
  // CHECK:   return %5
  // CHECK: }

  // CHECK: func @dataflow5(%arg0: tensor<1x3x32x32xi8>) -> tensor<1x32x32x64xi8> {
  // CHECK:   %3 = "tosa.transpose"
  // CHECK:   %4 = "tosa.conv2d"
  // CHECK:   return %4
  // CHECK: }

  // CHECK: func @forward(%arg0: tensor<1x3x32x32xi8>) -> tensor<1x10xi8> attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=true>} {
  func @forward(%arg0: tensor<1x3x32x32xi8>) -> tensor<1x10xi8> {
    // CHECK-NOT: %0 = "tosa.const"() {value = dense<0> : tensor<1x10xi8>} : () -> tensor<1x10xi8>
    // CHECK-NOT: %1 = "tosa.const"() {value = dense<1> : tensor<1x64x10xi8>} : () -> tensor<1x64x10xi8>
    // CHECK-NOT: %2 = "tosa.const"() {value = dense<2> : tensor<64x3x3x64xi8>} : () -> tensor<64x3x3x64xi8>
    // CHECK-NOT: %3 = "tosa.const"() {value = dense<3> : tensor<64x3x3x64xi8>} : () -> tensor<64x3x3x64xi8>
    // CHECK-NOT: %4 = "tosa.const"() {value = dense<4> : tensor<64x3x3x3xi8>} : () -> tensor<64x3x3x3xi8>
    // CHECK-NOT: %5 = "tosa.const"() {value = dense<[0, 3, 1, 2]> : tensor<4xi32>} : () -> tensor<4xi32>
    // CHECK-NOT: %6 = "tosa.const"() {value = dense<[0, 2, 3, 1]> : tensor<4xi32>} : () -> tensor<4xi32>
    // CHECK-NOT: %7 = "tosa.const"() {value = dense<5> : tensor<64xi8>} : () -> tensor<64xi8>
    %0 = "tosa.const"() {value = dense<0> : tensor<1x10xi8>} : () -> tensor<1x10xi8>
    %1 = "tosa.const"() {value = dense<1> : tensor<1x64x10xi8>} : () -> tensor<1x64x10xi8>
    %2 = "tosa.const"() {value = dense<2> : tensor<64x3x3x64xi8>} : () -> tensor<64x3x3x64xi8>
    %3 = "tosa.const"() {value = dense<3> : tensor<64x3x3x64xi8>} : () -> tensor<64x3x3x64xi8>
    %4 = "tosa.const"() {value = dense<4> : tensor<64x3x3x3xi8>} : () -> tensor<64x3x3x3xi8>
    %5 = "tosa.const"() {value = dense<[0, 3, 1, 2]> : tensor<4xi32>} : () -> tensor<4xi32>
    %6 = "tosa.const"() {value = dense<[0, 2, 3, 1]> : tensor<4xi32>} : () -> tensor<4xi32>
    %7 = "tosa.const"() {value = dense<5> : tensor<64xi8>} : () -> tensor<64xi8>

    // CHECK:   %0 = call @dataflow5(%arg0) : (tensor<1x3x32x32xi8>) -> tensor<1x32x32x64xi8>
    %8 = "tosa.transpose"(%arg0, %6) : (tensor<1x3x32x32xi8>, tensor<4xi32>) -> tensor<1x32x32x3xi8>
    %9 = "tosa.conv2d"(%8, %4, %7) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x3xi8>, tensor<64x3x3x3xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>

    // CHECK:   %1:2 = call @dataflow4(%0) : (tensor<1x32x32x64xi8>) -> (tensor<1x32x32x64xi8>, tensor<1x32x32x64xi8>)
    %10 = "tosa.clamp"(%9) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    %11 = "tosa.conv2d"(%10, %3, %7) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x64xi8>, tensor<64x3x3x64xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>
    %12 = "tosa.clamp"(%11) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    %13 = "tosa.conv2d"(%12, %2, %7) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x64xi8>, tensor<64x3x3x64xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>

    // CHECK:   %2 = call @dataflow3(%1#0, %1#1) : (tensor<1x32x32x64xi8>, tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    %14 = "tosa.add"(%13, %10) : (tensor<1x32x32x64xi8>, tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    %15 = "tosa.clamp"(%14) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>

    // CHECK:   %3 = call @dataflow2(%2) : (tensor<1x32x32x64xi8>) -> tensor<1x1x64xi8>
    %16 = "tosa.avg_pool2d"(%15) {kernel = [32, 32], pad = [0, 0, 0, 0], quantization_info = {input_zp = 0 : i32, output_zp = 0 : i32}, stride = [32, 32]} : (tensor<1x32x32x64xi8>) -> tensor<1x1x1x64xi8>
    %17 = "tosa.transpose"(%16, %5) : (tensor<1x1x1x64xi8>, tensor<4xi32>) -> tensor<1x64x1x1xi8>
    %18 = "tosa.reshape"(%17) {new_shape = [1, 1, 64]} : (tensor<1x64x1x1xi8>) -> tensor<1x1x64xi8>

    // CHECK:   %4 = call @dataflow1(%3) : (tensor<1x1x64xi8>) -> tensor<1x10xi8>
    %19 = "tosa.matmul"(%18, %1) {quantization_info = {a_zp = 0 : i32, b_zp = 0 : i32}} : (tensor<1x1x64xi8>, tensor<1x64x10xi8>) -> tensor<1x1x10xi8>
    %20 = "tosa.reshape"(%19) {new_shape = [1, 10]} : (tensor<1x1x10xi8>) -> tensor<1x10xi8>
    %21 = "tosa.add"(%20, %0) : (tensor<1x10xi8>, tensor<1x10xi8>) -> tensor<1x10xi8>

    // CHECK:   return %4 : tensor<1x10xi8>
    return %21 : tensor<1x10xi8>
  }
}
