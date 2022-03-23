// RUN: scalehls-opt -scalehls-heuristic-node-fusion %s | FileCheck %s

// CHECK: func @forward_node0(%arg0: tensor<1x3x32x32xi8>) -> tensor<1x32x32x64xi8> {
// CHECK:   %0 = "tosa.const"() {value = dense<4> : tensor<64x3x3x3xi8>}
// CHECK:   %1 = "tosa.const"() {value = dense<5> : tensor<64xi8>}
// CHECK:   %2 = "tosa.const"() {value = dense<[0, 2, 3, 1]> : tensor<4xi32>}
// CHECK:   %3 = "tosa.transpose"(%arg0, %2)
// CHECK:   %4 = "tosa.conv2d"(%3, %0, %1)
// CHECK:   %5 = "tosa.clamp"(%4)
// CHECK:   return %5
// CHECK: }

// CHECK: func @forward_node1(%arg0: tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8> {
// CHECK:   %0 = "tosa.const"() {value = dense<3> : tensor<64x3x3x64xi8>}
// CHECK:   %1 = "tosa.const"() {value = dense<5> : tensor<64xi8>}
// CHECK:   %2 = "tosa.conv2d"(%arg0, %0, %1)
// CHECK:   %3 = "tosa.clamp"(%2)
// CHECK:   return %3
// CHECK: }

// CHECK: func @forward_node2(%arg0: tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8> {
// CHECK:   %0 = "tosa.const"() {value = dense<2> : tensor<64x3x3x64xi8>}
// CHECK:   %1 = "tosa.const"() {value = dense<5> : tensor<64xi8>}
// CHECK:   %2 = "tosa.conv2d"(%arg0, %0, %1)
// CHECK:   return %2
// CHECK: }

// CHECK: func @forward_node3(%arg0: tensor<1x32x32x64xi8>, %arg1: tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8> {
// CHECK:   %0 = "tosa.add"(%arg0, %arg1)
// CHECK:   %1 = "tosa.clamp"(%0)
// CHECK:   return %1
// CHECK: }

// CHECK: func @forward_node4(%arg0: tensor<1x32x32x64xi8>) -> tensor<1x1x1x64xi8> {
// CHECK:   %0 = "tosa.avg_pool2d"(%arg0)
// CHECK:   return %0
// CHECK: }

// CHECK: func @forward_node5(%arg0: tensor<1x1x1x64xi8>) -> tensor<1x1x10xi8> {
// CHECK:   %0 = "tosa.const"() {value = dense<[0, 3, 1, 2]> : tensor<4xi32>}
// CHECK:   %1 = "tosa.transpose"(%arg0, %0)
// CHECK:   %2 = "tosa.const"() {value = dense<1> : tensor<1x64x10xi8>}
// CHECK:   %3 = "tosa.reshape"(%1)
// CHECK:   %4 = "tosa.matmul"(%3, %2)
// CHECK:   return %4
// CHECK: }

// CHECK: func @forward_node6(%arg0: tensor<1x1x10xi8>) -> tensor<1x10xi8> {
// CHECK:   %0 = "tosa.const"() {value = dense<0> : tensor<1x10xi8>}
// CHECK:   %1 = "tosa.reshape"(%arg0)
// CHECK:   %2 = "tosa.add"(%1, %0)
// CHECK:   return %2
// CHECK: }

module {
  // CHECK: func @forward(%arg0: tensor<1x3x32x32xi8>) -> tensor<1x10xi8> {
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

    // CHECK: %0 = call @forward_node0(%arg0) : (tensor<1x3x32x32xi8>) -> tensor<1x32x32x64xi8>
    %8 = "tosa.transpose"(%arg0, %6) : (tensor<1x3x32x32xi8>, tensor<4xi32>) -> tensor<1x32x32x3xi8>
    %9 = "tosa.conv2d"(%8, %4, %7) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x3xi8>, tensor<64x3x3x3xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>
    %10 = "tosa.clamp"(%9) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>

    // CHECK: %1 = call @forward_node1(%0) : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    %11 = "tosa.conv2d"(%10, %3, %7) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x64xi8>, tensor<64x3x3x64xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>
    %12 = "tosa.clamp"(%11) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>

    // CHECK: %2 = call @forward_node2(%1) : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    %13 = "tosa.conv2d"(%12, %2, %7) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x64xi8>, tensor<64x3x3x64xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>

    // CHECK: %3 = call @forward_node3(%2, %0) : (tensor<1x32x32x64xi8>, tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    %14 = "tosa.add"(%13, %10) : (tensor<1x32x32x64xi8>, tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    %15 = "tosa.clamp"(%14) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>

    // CHECK: %4 = call @forward_node4(%3) : (tensor<1x32x32x64xi8>) -> tensor<1x1x1x64xi8>
    %16 = "tosa.avg_pool2d"(%15) {kernel = [32, 32], pad = [0, 0, 0, 0], quantization_info = {input_zp = 0 : i32, output_zp = 0 : i32}, stride = [32, 32]} : (tensor<1x32x32x64xi8>) -> tensor<1x1x1x64xi8>

    // CHECK: %5 = call @forward_node5(%4) : (tensor<1x1x1x64xi8>) -> tensor<1x1x10xi8>
    %17 = "tosa.transpose"(%16, %5) : (tensor<1x1x1x64xi8>, tensor<4xi32>) -> tensor<1x64x1x1xi8>
    %18 = "tosa.reshape"(%17) {new_shape = [1, 1, 64]} : (tensor<1x64x1x1xi8>) -> tensor<1x1x64xi8>
    %19 = "tosa.matmul"(%18, %1) {quantization_info = {a_zp = 0 : i32, b_zp = 0 : i32}} : (tensor<1x1x64xi8>, tensor<1x64x10xi8>) -> tensor<1x1x10xi8>

    // CHECK: %6 = call @forward_node6(%5) : (tensor<1x1x10xi8>) -> tensor<1x10xi8>
    %20 = "tosa.reshape"(%19) {new_shape = [1, 10]} : (tensor<1x1x10xi8>) -> tensor<1x10xi8>
    %21 = "tosa.add"(%20, %0) : (tensor<1x10xi8>, tensor<1x10xi8>) -> tensor<1x10xi8>

    // CHECK: return %6 : tensor<1x10xi8>
    return %21 : tensor<1x10xi8>
  }
}
