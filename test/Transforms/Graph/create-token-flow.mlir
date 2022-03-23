// RUN: scalehls-opt -scalehls-create-token-flow %s | FileCheck %s

module {
  // CHECK: func @forward_node0(%arg0: tensor<1x3x32x32xi8>) -> (tensor<1x32x32x64xi8>, !hlscpp.stream<i1, 1>) {
  func @forward_node0(%arg0: tensor<1x3x32x32xi8>) -> tensor<1x32x32x64xi8> {
    %0 = "tosa.const"() {value = dense<4> : tensor<64x3x3x3xi8>} : () -> tensor<64x3x3x3xi8>
    %1 = "tosa.const"() {value = dense<5> : tensor<64xi8>} : () -> tensor<64xi8>
    %2 = "tosa.const"() {value = dense<[0, 2, 3, 1]> : tensor<4xi32>} : () -> tensor<4xi32>
    %3 = "tosa.transpose"(%arg0, %2) : (tensor<1x3x32x32xi8>, tensor<4xi32>) -> tensor<1x32x32x3xi8>
    %4 = "tosa.conv2d"(%3, %0, %1) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x3xi8>, tensor<64x3x3x3xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>
    %5 = "tosa.clamp"(%4) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>

    // CHECK: %6 = "hlscpp.stream.channel"() : () -> !hlscpp.stream<i1, 1>
    // CHECK: %false = arith.constant false
    // CHECK: "hlscpp.stream.write"(%6, %false) : (!hlscpp.stream<i1, 1>, i1) -> ()
    // CHECK: return %5, %6 : tensor<1x32x32x64xi8>, !hlscpp.stream<i1, 1>
    return %5 : tensor<1x32x32x64xi8>
  }

  // CHECK: func @forward_node1(%arg0: tensor<1x32x32x64xi8>, %arg1: !hlscpp.stream<i1, 1>) -> (tensor<1x32x32x64xi8>, !hlscpp.stream<i1, 1>) {
  func @forward_node1(%arg0: tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8> {

    // CHECK: "hlscpp.stream.read"(%arg1) : (!hlscpp.stream<i1, 1>) -> ()
    %0 = "tosa.const"() {value = dense<3> : tensor<64x3x3x64xi8>} : () -> tensor<64x3x3x64xi8>
    %1 = "tosa.const"() {value = dense<5> : tensor<64xi8>} : () -> tensor<64xi8>
    %2 = "tosa.conv2d"(%arg0, %0, %1) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x64xi8>, tensor<64x3x3x64xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>
    %3 = "tosa.clamp"(%2) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>

    // CHECK: return %3, %4 : tensor<1x32x32x64xi8>, !hlscpp.stream<i1, 1>
    return %3 : tensor<1x32x32x64xi8>
  }

  // CHECK: func @forward_node2(%arg0: tensor<1x32x32x64xi8>, %arg1: !hlscpp.stream<i1, 1>) -> (tensor<1x32x32x64xi8>, !hlscpp.stream<i1, 1>) {
  func @forward_node2(%arg0: tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8> {
    // CHECK: "hlscpp.stream.read"(%arg1) : (!hlscpp.stream<i1, 1>) -> ()
    %0 = "tosa.const"() {value = dense<2> : tensor<64x3x3x64xi8>} : () -> tensor<64x3x3x64xi8>
    %1 = "tosa.const"() {value = dense<5> : tensor<64xi8>} : () -> tensor<64xi8>
    %2 = "tosa.conv2d"(%arg0, %0, %1) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x64xi8>, tensor<64x3x3x64xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>

    // CHECK: return %2, %3 : tensor<1x32x32x64xi8>, !hlscpp.stream<i1, 1>
    return %2 : tensor<1x32x32x64xi8>
  }

  // CHECK: func @forward_node3(%arg0: tensor<1x32x32x64xi8>, %arg1: tensor<1x32x32x64xi8>, %arg2: !hlscpp.stream<i1, 1>, %arg3: !hlscpp.stream<i1, 1>) -> (tensor<1x32x32x64xi8>, !hlscpp.stream<i1, 1>) {
  func @forward_node3(%arg0: tensor<1x32x32x64xi8>, %arg1: tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8> {

    // CHECK: "hlscpp.stream.read"(%arg3) : (!hlscpp.stream<i1, 1>) -> ()
    // CHECK: "hlscpp.stream.read"(%arg2) : (!hlscpp.stream<i1, 1>) -> ()
    %0 = "tosa.add"(%arg0, %arg1) : (tensor<1x32x32x64xi8>, tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    %1 = "tosa.clamp"(%0) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>

    // CHECK: return %1, %2 : tensor<1x32x32x64xi8>, !hlscpp.stream<i1, 1>
    return %1 : tensor<1x32x32x64xi8>
  }

  // CHECK: func @forward_node4(%arg0: tensor<1x32x32x64xi8>, %arg1: !hlscpp.stream<i1, 1>) -> (tensor<1x1x1x64xi8>, !hlscpp.stream<i1, 1>) {
  func @forward_node4(%arg0: tensor<1x32x32x64xi8>) -> tensor<1x1x1x64xi8> {

    // CHECK: "hlscpp.stream.read"(%arg1) : (!hlscpp.stream<i1, 1>) -> ()
    %0 = "tosa.avg_pool2d"(%arg0) {kernel = [32, 32], pad = [0, 0, 0, 0], quantization_info = {input_zp = 0 : i32, output_zp = 0 : i32}, stride = [32, 32]} : (tensor<1x32x32x64xi8>) -> tensor<1x1x1x64xi8>

    // CHECK: return %0, %1 : tensor<1x1x1x64xi8>, !hlscpp.stream<i1, 1>
    return %0 : tensor<1x1x1x64xi8>
  }

  // CHECK: func @forward_node5(%arg0: tensor<1x1x1x64xi8>, %arg1: !hlscpp.stream<i1, 1>) -> (tensor<1x1x10xi8>, !hlscpp.stream<i1, 1>) {
  func @forward_node5(%arg0: tensor<1x1x1x64xi8>) -> tensor<1x1x10xi8> {

    // CHECK: "hlscpp.stream.read"(%arg1) : (!hlscpp.stream<i1, 1>) -> ()
    %0 = "tosa.const"() {value = dense<[0, 3, 1, 2]> : tensor<4xi32>} : () -> tensor<4xi32>
    %1 = "tosa.transpose"(%arg0, %0) : (tensor<1x1x1x64xi8>, tensor<4xi32>) -> tensor<1x64x1x1xi8>
    %2 = "tosa.const"() {value = dense<1> : tensor<1x64x10xi8>} : () -> tensor<1x64x10xi8>
    %3 = "tosa.reshape"(%1) {new_shape = [1, 1, 64]} : (tensor<1x64x1x1xi8>) -> tensor<1x1x64xi8>
    %4 = "tosa.matmul"(%3, %2) {quantization_info = {a_zp = 0 : i32, b_zp = 0 : i32}} : (tensor<1x1x64xi8>, tensor<1x64x10xi8>) -> tensor<1x1x10xi8>

    // CHECK: return %4, %5 : tensor<1x1x10xi8>, !hlscpp.stream<i1, 1>
    return %4 : tensor<1x1x10xi8>
  }

  // CHECK: func @forward_node6(%arg0: tensor<1x1x10xi8>, %arg1: !hlscpp.stream<i1, 1>) -> (tensor<1x10xi8>, !hlscpp.stream<i1, 1>) {
  func @forward_node6(%arg0: tensor<1x1x10xi8>) -> tensor<1x10xi8> {

    // CHECK: "hlscpp.stream.read"(%arg1) : (!hlscpp.stream<i1, 1>) -> ()
    %0 = "tosa.const"() {value = dense<0> : tensor<1x10xi8>} : () -> tensor<1x10xi8>
    %1 = "tosa.reshape"(%arg0) {new_shape = [1, 10]} : (tensor<1x1x10xi8>) -> tensor<1x10xi8>
    %2 = "tosa.add"(%1, %0) : (tensor<1x10xi8>, tensor<1x10xi8>) -> tensor<1x10xi8>

    // CHECK: return %2, %3 : tensor<1x10xi8>, !hlscpp.stream<i1, 1>
    return %2 : tensor<1x10xi8>
  }
  
  // CHECK: func @forward(%arg0: tensor<1x3x32x32xi8>) -> tensor<1x10xi8> {
  func @forward(%arg0: tensor<1x3x32x32xi8>) -> tensor<1x10xi8> {

    // CHECK: %0:2 = call @forward_node0(%arg0) : (tensor<1x3x32x32xi8>) -> (tensor<1x32x32x64xi8>, !hlscpp.stream<i1, 1>)
    %0 = call @forward_node0(%arg0) : (tensor<1x3x32x32xi8>) -> tensor<1x32x32x64xi8>

    // CHECK: %1:2 = call @forward_node1(%0#0, %0#1) : (tensor<1x32x32x64xi8>, !hlscpp.stream<i1, 1>) -> (tensor<1x32x32x64xi8>, !hlscpp.stream<i1, 1>)
    %1 = call @forward_node1(%0) : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>

    // CHECK: %2:2 = call @forward_node2(%1#0, %1#1) : (tensor<1x32x32x64xi8>, !hlscpp.stream<i1, 1>) -> (tensor<1x32x32x64xi8>, !hlscpp.stream<i1, 1>)
    %2 = call @forward_node2(%1) : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>

    // CHECK: %3:2 = call @forward_node3(%2#0, %0#0, %0#1, %2#1) : (tensor<1x32x32x64xi8>, tensor<1x32x32x64xi8>, !hlscpp.stream<i1, 1>, !hlscpp.stream<i1, 1>) -> (tensor<1x32x32x64xi8>, !hlscpp.stream<i1, 1>)
    %3 = call @forward_node3(%2, %0) : (tensor<1x32x32x64xi8>, tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>

    // CHECK: %4:2 = call @forward_node4(%3#0, %3#1) : (tensor<1x32x32x64xi8>, !hlscpp.stream<i1, 1>) -> (tensor<1x1x1x64xi8>, !hlscpp.stream<i1, 1>)
    %4 = call @forward_node4(%3) : (tensor<1x32x32x64xi8>) -> tensor<1x1x1x64xi8>

    // CHECK: %5:2 = call @forward_node5(%4#0, %4#1) : (tensor<1x1x1x64xi8>, !hlscpp.stream<i1, 1>) -> (tensor<1x1x10xi8>, !hlscpp.stream<i1, 1>)
    %5 = call @forward_node5(%4) : (tensor<1x1x1x64xi8>) -> tensor<1x1x10xi8>

    // CHECK: %6:2 = call @forward_node6(%5#0, %5#1) : (tensor<1x1x10xi8>, !hlscpp.stream<i1, 1>) -> (tensor<1x10xi8>, !hlscpp.stream<i1, 1>)
    %6 = call @forward_node6(%5) : (tensor<1x1x10xi8>) -> tensor<1x10xi8>

    // CHECK: return %6#0 : tensor<1x10xi8>
    return %6 : tensor<1x10xi8>
  }
}
