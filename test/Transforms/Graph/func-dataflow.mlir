// RUN: scalehls-opt -scalehls-func-dataflow="target-func=forward" %s | FileCheck %s

module {
  // CHECK: func @forward(%arg0: tensor<1x3x32x32xi8>) -> tensor<1x10xi8> attributes {func_directive = #hls.fd<pipeline=false, targetInterval=1, dataflow=true>} {
  func @forward(%arg0: tensor<1x3x32x32xi8>) -> tensor<1x10xi8> {
    %0 = "tosa.const"() {value = dense<[0, 2, 3, 1]> : tensor<4xi32>} : () -> tensor<4xi32>
    %1 = "tosa.const"() {value = dense<4> : tensor<64x3x3x3xi8>} : () -> tensor<64x3x3x3xi8>
    %2 = "tosa.const"() {value = dense<5> : tensor<64xi8>} : () -> tensor<64xi8>
    %3 = "tosa.const"() {value = dense<3> : tensor<64x3x3x64xi8>} : () -> tensor<64x3x3x64xi8>
    %4 = "tosa.const"() {value = dense<2> : tensor<64x3x3x64xi8>} : () -> tensor<64x3x3x64xi8>
    %5 = "tosa.const"() {value = dense<[0, 3, 1, 2]> : tensor<4xi32>} : () -> tensor<4xi32>
    %6 = "tosa.const"() {value = dense<1> : tensor<1x64x10xi8>} : () -> tensor<1x64x10xi8>
    %7 = "tosa.const"() {value = dense<0> : tensor<1x10xi8>} : () -> tensor<1x10xi8>

    // CHECK: %0 = hls.dataflow.node() -> tensor<1x32x32x64xi8> {
    // CHECK:   %8 = "tosa.const"() {value = dense<[0, 2, 3, 1]> : tensor<4xi32>} : () -> tensor<4xi32>
    // CHECK:   %9 = "tosa.transpose"(%arg0, %8) : (tensor<1x3x32x32xi8>, tensor<4xi32>) -> tensor<1x32x32x3xi8>
    // CHECK:   %10 = "tosa.const"() {value = dense<4> : tensor<64x3x3x3xi8>} : () -> tensor<64x3x3x3xi8>
    // CHECK:   %11 = "tosa.const"() {value = dense<5> : tensor<64xi8>} : () -> tensor<64xi8>
    // CHECK:   %12 = "tosa.conv2d"(%9, %10, %11) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x3xi8>, tensor<64x3x3x3xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>
    // CHECK:   %13 = "tosa.clamp"(%12) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    // CHECK:   "hls.dataflow.output"(%13) : (tensor<1x32x32x64xi8>) -> ()
    // CHECK: }
    // CHECK: %1 = "hls.dataflow.buffer"(%0) {depth = 2 : i32} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    %8 = hls.dataflow.node() -> tensor<1x32x32x64xi8> {
      %15 = "tosa.transpose"(%arg0, %0) : (tensor<1x3x32x32xi8>, tensor<4xi32>) -> tensor<1x32x32x3xi8>
      %16 = "tosa.conv2d"(%15, %1, %2) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x3xi8>, tensor<64x3x3x3xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>
      %17 = "tosa.clamp"(%16) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
      "hls.dataflow.output"(%17) : (tensor<1x32x32x64xi8>) -> ()
    }

    // CHECK: %2 = hls.dataflow.node() -> tensor<1x32x32x64xi8> {
    // CHECK:   %8 = "tosa.const"() {value = dense<5> : tensor<64xi8>} : () -> tensor<64xi8>
    // CHECK:   %9 = "tosa.const"() {value = dense<3> : tensor<64x3x3x64xi8>} : () -> tensor<64x3x3x64xi8>
    // CHECK:   %10 = "tosa.conv2d"(%0, %9, %8) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x64xi8>, tensor<64x3x3x64xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>
    // CHECK:   %11 = "tosa.clamp"(%10) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    // CHECK:   "hls.dataflow.output"(%11) : (tensor<1x32x32x64xi8>) -> ()
    // CHECK: }
    %9 = hls.dataflow.node() -> tensor<1x32x32x64xi8> {
      %15 = "tosa.conv2d"(%8, %3, %2) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x64xi8>, tensor<64x3x3x64xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>
      %16 = "tosa.clamp"(%15) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
      "hls.dataflow.output"(%16) : (tensor<1x32x32x64xi8>) -> ()
    }

    // CHECK: %3 = hls.dataflow.node() -> tensor<1x32x32x64xi8> {
    // CHECK:   %8 = "tosa.const"() {value = dense<5> : tensor<64xi8>} : () -> tensor<64xi8>
    // CHECK:   %9 = "tosa.const"() {value = dense<2> : tensor<64x3x3x64xi8>} : () -> tensor<64x3x3x64xi8>
    // CHECK:   %10 = "tosa.conv2d"(%2, %9, %8) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x64xi8>, tensor<64x3x3x64xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>
    // CHECK:   "hls.dataflow.output"(%10) : (tensor<1x32x32x64xi8>) -> ()
    // CHECK: }
    %10 = hls.dataflow.node() -> tensor<1x32x32x64xi8> {
      %15 = "tosa.conv2d"(%9, %4, %2) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x64xi8>, tensor<64x3x3x64xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>
      "hls.dataflow.output"(%15) : (tensor<1x32x32x64xi8>) -> ()
    }

    // CHECK: %4 = hls.dataflow.node() -> tensor<1x32x32x64xi8> {
    // CHECK:   %8 = "tosa.add"(%3, %1) : (tensor<1x32x32x64xi8>, tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    // CHECK:   %9 = "tosa.clamp"(%8) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    // CHECK:   "hls.dataflow.output"(%9) : (tensor<1x32x32x64xi8>) -> ()
    // CHECK: }
    %11 = hls.dataflow.node() -> tensor<1x32x32x64xi8> {
      %15 = "tosa.add"(%10, %8) : (tensor<1x32x32x64xi8>, tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
      %16 = "tosa.clamp"(%15) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
      "hls.dataflow.output"(%16) : (tensor<1x32x32x64xi8>) -> ()
    }

    // CHECK: %5 = hls.dataflow.node() -> tensor<1x1x1x64xi8> {
    // CHECK:   %8 = "tosa.avg_pool2d"(%4) {kernel = [32, 32], pad = [0, 0, 0, 0], quantization_info = {input_zp = 0 : i32, output_zp = 0 : i32}, stride = [32, 32]} : (tensor<1x32x32x64xi8>) -> tensor<1x1x1x64xi8>
    // CHECK:   "hls.dataflow.output"(%8) : (tensor<1x1x1x64xi8>) -> ()
    // CHECK: }
    %12 = hls.dataflow.node() -> tensor<1x1x1x64xi8> {
      %15 = "tosa.avg_pool2d"(%11) {kernel = [32, 32], pad = [0, 0, 0, 0], quantization_info = {input_zp = 0 : i32, output_zp = 0 : i32}, stride = [32, 32]} : (tensor<1x32x32x64xi8>) -> tensor<1x1x1x64xi8>
      "hls.dataflow.output"(%15) : (tensor<1x1x1x64xi8>) -> ()
    }

    // CHECK: %6 = hls.dataflow.node() -> tensor<1x1x10xi8> {
    // CHECK:   %8 = "tosa.const"() {value = dense<[0, 3, 1, 2]> : tensor<4xi32>} : () -> tensor<4xi32>
    // CHECK:   %9 = "tosa.transpose"(%5, %8) : (tensor<1x1x1x64xi8>, tensor<4xi32>) -> tensor<1x64x1x1xi8>
    // CHECK:   %10 = "tosa.reshape"(%9) {new_shape = [1, 1, 64]} : (tensor<1x64x1x1xi8>) -> tensor<1x1x64xi8>
    // CHECK:   %11 = "tosa.const"() {value = dense<1> : tensor<1x64x10xi8>} : () -> tensor<1x64x10xi8>
    // CHECK:   %12 = "tosa.matmul"(%10, %11) {quantization_info = {a_zp = 0 : i32, b_zp = 0 : i32}} : (tensor<1x1x64xi8>, tensor<1x64x10xi8>) -> tensor<1x1x10xi8>
    // CHECK:   "hls.dataflow.output"(%12) : (tensor<1x1x10xi8>) -> ()
    // CHECK: }
    %13 = hls.dataflow.node() -> tensor<1x1x10xi8> {
      %15 = "tosa.transpose"(%12, %5) : (tensor<1x1x1x64xi8>, tensor<4xi32>) -> tensor<1x64x1x1xi8>
      %16 = "tosa.reshape"(%15) {new_shape = [1, 1, 64]} : (tensor<1x64x1x1xi8>) -> tensor<1x1x64xi8>
      %17 = "tosa.matmul"(%16, %6) {quantization_info = {a_zp = 0 : i32, b_zp = 0 : i32}} : (tensor<1x1x64xi8>, tensor<1x64x10xi8>) -> tensor<1x1x10xi8>
      "hls.dataflow.output"(%17) : (tensor<1x1x10xi8>) -> ()
    }

    // CHECK: %7 = hls.dataflow.node() -> tensor<1x10xi8> {
    // CHECK:   %8 = "tosa.reshape"(%6) {new_shape = [1, 10]} : (tensor<1x1x10xi8>) -> tensor<1x10xi8>
    // CHECK:   %9 = "tosa.const"() {value = dense<0> : tensor<1x10xi8>} : () -> tensor<1x10xi8>
    // CHECK:   %10 = "tosa.add"(%8, %9) : (tensor<1x10xi8>, tensor<1x10xi8>) -> tensor<1x10xi8>
    // CHECK:   "hls.dataflow.output"(%10) : (tensor<1x10xi8>) -> ()
    // CHECK: }
    %14 = hls.dataflow.node() -> tensor<1x10xi8> {
      %15 = "tosa.reshape"(%13) {new_shape = [1, 10]} : (tensor<1x1x10xi8>) -> tensor<1x10xi8>
      %16 = "tosa.add"(%15, %7) : (tensor<1x10xi8>, tensor<1x10xi8>) -> tensor<1x10xi8>
      "hls.dataflow.output"(%16) : (tensor<1x10xi8>) -> ()
    }

    // CHECK: return %7 : tensor<1x10xi8>
    return %14 : tensor<1x10xi8>
  }
}
