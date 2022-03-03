// RUN: scalehls-opt -legalize-dataflow="min-gran=3 insert-copy=true" %s | FileCheck %s

module {
  // CHECK: func @forward(%arg0: tensor<1x3x32x32xi8>) -> tensor<1x10xi8> attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=true>} {
  func @forward(%arg0: tensor<1x3x32x32xi8>) -> tensor<1x10xi8> {
    %0 = "tosa.const"() {value = dense<0> : tensor<1x10xi8>} : () -> tensor<1x10xi8>
    %1 = "tosa.const"() {value = dense<1> : tensor<1x64x10xi8>} : () -> tensor<1x64x10xi8>
    %2 = "tosa.const"() {value = dense<2> : tensor<64x3x3x64xi8>} : () -> tensor<64x3x3x64xi8>
    %3 = "tosa.const"() {value = dense<3> : tensor<64x3x3x64xi8>} : () -> tensor<64x3x3x64xi8>
    %4 = "tosa.const"() {value = dense<4> : tensor<64x3x3x3xi8>} : () -> tensor<64x3x3x3xi8>
    %5 = "tosa.const"() {value = dense<[0, 3, 1, 2]> : tensor<4xi32>} : () -> tensor<4xi32>
    %6 = "tosa.const"() {value = dense<[0, 2, 3, 1]> : tensor<4xi32>} : () -> tensor<4xi32>
    %7 = "tosa.const"() {value = dense<5> : tensor<64xi8>} : () -> tensor<64xi8>

    // CHECK:   %8 = "tosa.transpose"(%arg0, %6)
    // CHECK-SAME: dataflow_level = 5
    %8 = "tosa.transpose"(%arg0, %6) : (tensor<1x3x32x32xi8>, tensor<4xi32>) -> tensor<1x32x32x3xi8>
    %9 = "tosa.conv2d"(%8, %4, %7) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x3xi8>, tensor<64x3x3x3xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>

    // CHECK:   %10 = "tosa.clamp"(%9)
    // CHECK-SAME: dataflow_level = 4
    %10 = "tosa.clamp"(%9) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    %11 = "tosa.conv2d"(%10, %3, %7) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x64xi8>, tensor<64x3x3x64xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>
    %12 = "tosa.clamp"(%11) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>

    // CHECK:   %13 = "tosa.conv2d"(%12, %2, %7)
    // CHECK-SAME: dataflow_level = 3
    %13 = "tosa.conv2d"(%12, %2, %7) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x64xi8>, tensor<64x3x3x64xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>

    // CHECK:   %14 = "hlscpp.assign"(%10)
    // CHECK-SAME: dataflow_level = 4
    // CHECK:   %15 = "hlscpp.assign"(%14)
    // CHECK-SAME: dataflow_level = 4
    // CHECK:   %16 = "hlscpp.assign"(%15)
    // CHECK-SAME: dataflow_level = 3
    // CHECK:   %17 = "tosa.add"(%13, %16)
    // CHECK-SAME: dataflow_level = 3
    %14 = "tosa.add"(%13, %10) : (tensor<1x32x32x64xi8>, tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    %15 = "tosa.clamp"(%14) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>

    // CHECK:   %19 = "tosa.avg_pool2d"(%18)
    // CHECK-SAME: dataflow_level = 2
    %16 = "tosa.avg_pool2d"(%15) {kernel = [32, 32], pad = [0, 0, 0, 0], quantization_info = {input_zp = 0 : i32, output_zp = 0 : i32}, stride = [32, 32]} : (tensor<1x32x32x64xi8>) -> tensor<1x1x1x64xi8>
    %17 = "tosa.transpose"(%16, %5) : (tensor<1x1x1x64xi8>, tensor<4xi32>) -> tensor<1x64x1x1xi8>
    %18 = "tosa.reshape"(%17) {new_shape = [1, 1, 64]} : (tensor<1x64x1x1xi8>) -> tensor<1x1x64xi8>

    // CHECK:   %22 = "tosa.matmul"(%21, %1)
    // CHECK-SAME: dataflow_level = 1
    %19 = "tosa.matmul"(%18, %1) {quantization_info = {a_zp = 0 : i32, b_zp = 0 : i32}} : (tensor<1x1x64xi8>, tensor<1x64x10xi8>) -> tensor<1x1x10xi8>
    %20 = "tosa.reshape"(%19) {new_shape = [1, 10]} : (tensor<1x1x10xi8>) -> tensor<1x10xi8>
    %21 = "tosa.add"(%20, %0) : (tensor<1x10xi8>, tensor<1x10xi8>) -> tensor<1x10xi8>
    return %21 : tensor<1x10xi8>
  }
}
