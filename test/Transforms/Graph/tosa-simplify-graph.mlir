// RUN: scalehls-opt -scalehls-tosa-simplify-graph %s | FileCheck %s

module {
  // CHECK: func @forward(%arg0: tensor<1x3x32x32xi8>) -> tensor<1x10xi8> {
  func @forward(%arg0: tensor<1x3x32x32xi8>) -> tensor<1x10xi8> {
    %0 = "tosa.const"() {value = dense<0> : tensor<1x10xi8>} : () -> tensor<1x10xi8>
    %1 = "tosa.const"() {value = dense<1> : tensor<1x64x10xi8>} : () -> tensor<1x64x10xi8>
    %2 = "tosa.const"() {value = dense<2> : tensor<64x3x3x64xi8>} : () -> tensor<64x3x3x64xi8>
    %3 = "tosa.const"() {value = dense<3> : tensor<64x3x3x64xi8>} : () -> tensor<64x3x3x64xi8>
    %4 = "tosa.const"() {value = dense<4> : tensor<64x3x3x3xi8>} : () -> tensor<64x3x3x3xi8>
    %5 = "tosa.const"() {value = dense<[0, 3, 1, 2]> : tensor<4xi32>} : () -> tensor<4xi32>
    %6 = "tosa.const"() {value = dense<[0, 2, 3, 1]> : tensor<4xi32>} : () -> tensor<4xi32>
    %7 = "tosa.const"() {value = dense<5> : tensor<64xi8>} : () -> tensor<64xi8>

    // CHECK: %[[VAL0:.*]] = "tosa.transpose"(%arg0, %6)
    %8 = "tosa.transpose"(%arg0, %6) : (tensor<1x3x32x32xi8>, tensor<4xi32>) -> tensor<1x32x32x3xi8>

    // CHECK: %[[VAL1:.*]] = "tosa.conv2d"(%[[VAL0]], %4, %7)
    %9 = "tosa.conv2d"(%8, %4, %7) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x3xi8>, tensor<64x3x3x3xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>

    // CHECK-NOT: %[[VAL2:.*]] = "tosa.transpose"(%[[VAL1]], %5)
    %10 = "tosa.transpose"(%9, %5) : (tensor<1x32x32x64xi8>, tensor<4xi32>) -> tensor<1x64x32x32xi8>

    // CHECK: %[[VAL3:.*]] = "tosa.clamp"(%[[VAL1]])
    %11 = "tosa.clamp"(%10) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x64x32x32xi8>) -> tensor<1x64x32x32xi8>

    // CHECK-NOT: %[[VAL4:.*]] = "tosa.transpose"(%[[VAL3]], %6)
    %12 = "tosa.transpose"(%11, %6) : (tensor<1x64x32x32xi8>, tensor<4xi32>) -> tensor<1x32x32x64xi8>

    // CHECK: %[[VAL5:.*]] = "tosa.conv2d"(%[[VAL3]], %3, %7)
    %13 = "tosa.conv2d"(%12, %3, %7) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x64xi8>, tensor<64x3x3x64xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>
    %14 = "tosa.transpose"(%13, %5) : (tensor<1x32x32x64xi8>, tensor<4xi32>) -> tensor<1x64x32x32xi8>
    %15 = "tosa.clamp"(%14) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x64x32x32xi8>) -> tensor<1x64x32x32xi8>
    %16 = "tosa.transpose"(%15, %6) : (tensor<1x64x32x32xi8>, tensor<4xi32>) -> tensor<1x32x32x64xi8>
    %17 = "tosa.conv2d"(%16, %2, %7) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x64xi8>, tensor<64x3x3x64xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>
    %18 = "tosa.transpose"(%17, %5) : (tensor<1x32x32x64xi8>, tensor<4xi32>) -> tensor<1x64x32x32xi8>
    %19 = "tosa.add"(%18, %11) : (tensor<1x64x32x32xi8>, tensor<1x64x32x32xi8>) -> tensor<1x64x32x32xi8>
    %20 = "tosa.clamp"(%19) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x64x32x32xi8>) -> tensor<1x64x32x32xi8>
    %21 = "tosa.transpose"(%20, %6) : (tensor<1x64x32x32xi8>, tensor<4xi32>) -> tensor<1x32x32x64xi8>
    %22 = "tosa.avg_pool2d"(%21) {kernel = [32, 32], pad = [0, 0, 0, 0], quantization_info = {input_zp = 0 : i32, output_zp = 0 : i32}, stride = [32, 32]} : (tensor<1x32x32x64xi8>) -> tensor<1x1x1x64xi8>

    // CHECK: %[[VAL7:.*]] = "tosa.transpose"(%[[VAL6:.*]], %5)
    %23 = "tosa.transpose"(%22, %5) : (tensor<1x1x1x64xi8>, tensor<4xi32>) -> tensor<1x64x1x1xi8>
    %24 = "tosa.reshape"(%23) {new_shape = [1, 1, 64]} : (tensor<1x64x1x1xi8>) -> tensor<1x1x64xi8>
    %25 = "tosa.matmul"(%24, %1) {quantization_info = {a_zp = 0 : i32, b_zp = 0 : i32}} : (tensor<1x1x64xi8>, tensor<1x64x10xi8>) -> tensor<1x1x10xi8>
    %26 = "tosa.reshape"(%25) {new_shape = [1, 10]} : (tensor<1x1x10xi8>) -> tensor<1x10xi8>
    %27 = "tosa.add"(%26, %0) : (tensor<1x10xi8>, tensor<1x10xi8>) -> tensor<1x10xi8>
    return %27 : tensor<1x10xi8>
  }
}
