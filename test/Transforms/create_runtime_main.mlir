// RUN: scalehls-opt -scalehls-create-runtime-main="top-func=forward" %s | FileCheck %s

module {
  func @dataflow2(%arg0: tensor<1x32x32x64xi8>) -> tensor<1x1x64xi8> {
    %cst = arith.constant dense<[0, 3, 1, 2]> : tensor<4xi32>
    %cst_0 = arith.constant dense<[1, 1, 64]> : tensor<3xi32>
    %0 = "tosa.avg_pool2d"(%arg0) {kernel = [32, 32], pad = [0, 0, 0, 0], quantization_info = {input_zp = 0 : i32, output_zp = 0 : i32}, stride = [32, 32]} : (tensor<1x32x32x64xi8>) -> tensor<1x1x1x64xi8>
    %1 = "tosa.transpose"(%0, %cst) : (tensor<1x1x1x64xi8>, tensor<4xi32>) -> tensor<1x64x1x1xi8>
    %2 = tensor.reshape %1(%cst_0) : (tensor<1x64x1x1xi8>, tensor<3xi32>) -> tensor<1x1x64xi8>
    return %2 : tensor<1x1x64xi8>
  }

  func @dataflow4(%arg0: tensor<1x32x32x64xi8>) -> (tensor<1x32x32x64xi8>, tensor<1x32x32x64xi8>) {

    // CHECK-NOT: %cst = arith.constant dense<3> : tensor<64x3x3x64xi8>
    %cst = arith.constant dense<3> : tensor<64x3x3x64xi8>
    %cst_0 = arith.constant dense<5> : tensor<64xi8>
    %0 = "tosa.clamp"(%arg0) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    %1 = "tosa.conv2d"(%0, %cst, %cst_0) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x64xi8>, tensor<64x3x3x64xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>
    %2 = "tosa.clamp"(%1) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    %3 = "hlscpp.buffer"(%0) : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    return %2, %3 : tensor<1x32x32x64xi8>, tensor<1x32x32x64xi8>
  }

  func @dataflow1(%arg0: tensor<1x1x64xi8>) -> tensor<1x10xi8> {

    // CHECK-NOT: %cst = arith.constant dense<1> : tensor<1x64x10xi8>
    %cst = arith.constant dense<1> : tensor<1x64x10xi8>
    %cst_0 = arith.constant dense<0> : tensor<1x10xi8>
    %cst_1 = arith.constant dense<[1, 10]> : tensor<2xi32>
    %0 = "tosa.matmul"(%arg0, %cst) {quantization_info = {a_zp = 0 : i32, b_zp = 0 : i32}} : (tensor<1x1x64xi8>, tensor<1x64x10xi8>) -> tensor<1x1x10xi8>
    %1 = tensor.reshape %0(%cst_1) : (tensor<1x1x10xi8>, tensor<2xi32>) -> tensor<1x10xi8>
    %2 = "tosa.add"(%1, %cst_0) : (tensor<1x10xi8>, tensor<1x10xi8>) -> tensor<1x10xi8>
    return %2 : tensor<1x10xi8>
  }

  func @dataflow3(%arg0: tensor<1x32x32x64xi8>, %arg1: tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8> {
  
    // CHECK-NOT: %cst = arith.constant dense<2> : tensor<64x3x3x64xi8>
    %cst = arith.constant dense<2> : tensor<64x3x3x64xi8>
    %cst_0 = arith.constant dense<5> : tensor<64xi8>
    %0 = "tosa.conv2d"(%arg0, %cst, %cst_0) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x64xi8>, tensor<64x3x3x64xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>
    %1 = "hlscpp.buffer"(%arg1) : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    %2 = "tosa.add"(%0, %1) : (tensor<1x32x32x64xi8>, tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    %3 = "tosa.clamp"(%2) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    return %3 : tensor<1x32x32x64xi8>
  }

  func @dataflow5(%arg0: tensor<1x3x32x32xi8>) -> tensor<1x32x32x64xi8> {
    %cst = arith.constant dense<[0, 2, 3, 1]> : tensor<4xi32>

    // CHECK-NOT: %cst_0 = arith.constant dense<4> : tensor<64x3x3x3xi8>  
    %cst_0 = arith.constant dense<4> : tensor<64x3x3x3xi8>
    %cst_1 = arith.constant dense<5> : tensor<64xi8>
    %0 = "tosa.transpose"(%arg0, %cst) : (tensor<1x3x32x32xi8>, tensor<4xi32>) -> tensor<1x32x32x3xi8>
    %1 = "tosa.conv2d"(%0, %cst_0, %cst_1) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x3xi8>, tensor<64x3x3x3xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>
    return %1 : tensor<1x32x32x64xi8>
  }

  // CHECK: func @forward(%arg0: tensor<1x3x32x32xi8>, %arg1: tensor<64x3x3x3xi8>, %arg2: tensor<64x3x3x64xi8>, %arg3: tensor<64x3x3x64xi8>, %arg4: tensor<1x64x10xi8>) -> tensor<1x10xi8> attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=true>} {
  // CHECK:   %0 = call @dataflow5(%arg0, %arg1) : (tensor<1x3x32x32xi8>, tensor<64x3x3x3xi8>) -> tensor<1x32x32x64xi8>
  // CHECK:   %1:2 = call @dataflow4(%0, %arg2) : (tensor<1x32x32x64xi8>, tensor<64x3x3x64xi8>) -> (tensor<1x32x32x64xi8>, tensor<1x32x32x64xi8>)
  // CHECK:   %2 = call @dataflow3(%1#0, %1#1, %arg3) : (tensor<1x32x32x64xi8>, tensor<1x32x32x64xi8>, tensor<64x3x3x64xi8>) -> tensor<1x32x32x64xi8>
  // CHECK:   %3 = call @dataflow2(%2) : (tensor<1x32x32x64xi8>) -> tensor<1x1x64xi8>
  // CHECK:   %4 = call @dataflow1(%3, %arg4) : (tensor<1x1x64xi8>, tensor<1x64x10xi8>) -> tensor<1x10xi8>
  // CHECK:   return %4 : tensor<1x10xi8>
  // CHECK: }
  func @forward(%arg0: tensor<1x3x32x32xi8>) -> tensor<1x10xi8> attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=true>} {
    %0 = call @dataflow5(%arg0) : (tensor<1x3x32x32xi8>) -> tensor<1x32x32x64xi8>
    %1:2 = call @dataflow4(%0) : (tensor<1x32x32x64xi8>) -> (tensor<1x32x32x64xi8>, tensor<1x32x32x64xi8>)
    %2 = call @dataflow3(%1#0, %1#1) : (tensor<1x32x32x64xi8>, tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    %3 = call @dataflow2(%2) : (tensor<1x32x32x64xi8>) -> tensor<1x1x64xi8>
    %4 = call @dataflow1(%3) : (tensor<1x1x64xi8>) -> tensor<1x10xi8>
    return %4 : tensor<1x10xi8>
  }

  // CHECK: func @main(%arg0: tensor<1x3x32x32xi8>) -> tensor<1x10xi8> {
  // CHECK:   %cst = arith.constant dense<4> : tensor<64x3x3x3xi8>
  // CHECK:   %cst_0 = arith.constant dense<3> : tensor<64x3x3x64xi8>
  // CHECK:   %cst_1 = arith.constant dense<2> : tensor<64x3x3x64xi8>
  // CHECK:   %cst_2 = arith.constant dense<1> : tensor<1x64x10xi8>
  // CHECK:   %0 = call @forward(%arg0, %cst, %cst_0, %cst_1, %cst_2) : (tensor<1x3x32x32xi8>, tensor<64x3x3x3xi8>, tensor<64x3x3x64xi8>, tensor<64x3x3x64xi8>, tensor<1x64x10xi8>) -> tensor<1x10xi8>
  // CHECK:   return %0 : tensor<1x10xi8>
  // CHECK: }
}
