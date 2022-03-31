// RUN: scalehls-opt -scalehls-create-runtime-main="top-func=forward" %s | FileCheck %s

module {
  // CHECK: func @forward(%arg0: tensor<1x3x32x32xi8>, %arg1: tensor<1x64x10xi8>, %arg2: tensor<4xi32>, %arg3: tensor<64x3x3x64xi8>, %arg4: tensor<64x3x3x64xi8>, %arg5: tensor<64xi8>, %arg6: tensor<64x3x3x3xi8>, %arg7: tensor<4xi32>) -> tensor<1x10xi8> attributes {top_func} {
  func @forward(%arg0: tensor<1x3x32x32xi8>) -> tensor<1x10xi8> {

    // CHECK-NOT: %cst = arith.constant dense<1> : tensor<1x64x10xi8>
    // CHECK-NOT: %cst_0 = arith.constant dense<[0, 3, 1, 2]> : tensor<4xi32>
    // CHECK-NOT: %cst_1 = arith.constant dense<2> : tensor<64x3x3x64xi8>
    // CHECK-NOT: %cst_2 = arith.constant dense<3> : tensor<64x3x3x64xi8>
    // CHECK-NOT: %cst_3 = arith.constant dense<5> : tensor<64xi8>
    // CHECK-NOT: %cst_4 = arith.constant dense<4> : tensor<64x3x3x3xi8>
    // CHECK-NOT: %cst_5 = arith.constant dense<[0, 2, 3, 1]> : tensor<4xi32>
    %cst = arith.constant dense<1> : tensor<1x64x10xi8>
    %cst_0 = arith.constant dense<[0, 3, 1, 2]> : tensor<4xi32>
    %cst_1 = arith.constant dense<2> : tensor<64x3x3x64xi8>
    %cst_2 = arith.constant dense<3> : tensor<64x3x3x64xi8>
    %cst_3 = arith.constant dense<5> : tensor<64xi8>
    %cst_4 = arith.constant dense<4> : tensor<64x3x3x3xi8>
    %cst_5 = arith.constant dense<[0, 2, 3, 1]> : tensor<4xi32>
    %0:2 = hls.dataflow.node() -> tensor<1x32x32x64xi8>, i1 {
      %8 = "tosa.transpose"(%arg0, %cst_5) : (tensor<1x3x32x32xi8>, tensor<4xi32>) -> tensor<1x32x32x3xi8>
      %9 = "tosa.conv2d"(%8, %cst_4, %cst_3) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x3xi8>, tensor<64x3x3x3xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>
      %10 = "tosa.clamp"(%9) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
      %11 = "hls.dataflow.source"() : () -> i1
      "hls.dataflow.output"(%10, %11) : (tensor<1x32x32x64xi8>, i1) -> ()
    }
    %1 = "hls.dataflow.buffer"(%0#0) {depth = 2 : i32} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    %2:2 = hls.dataflow.node() -> tensor<1x32x32x64xi8>, i1 {
      "hls.dataflow.sink"(%0#1) : (i1) -> ()
      %8 = "tosa.conv2d"(%0#0, %cst_2, %cst_3) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x64xi8>, tensor<64x3x3x64xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>
      %9 = "tosa.clamp"(%8) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
      %10 = "hls.dataflow.source"() : () -> i1
      "hls.dataflow.output"(%9, %10) : (tensor<1x32x32x64xi8>, i1) -> ()
    }
    %3:2 = hls.dataflow.node() -> tensor<1x32x32x64xi8>, i1 {
      "hls.dataflow.sink"(%2#1) : (i1) -> ()
      %8 = "tosa.conv2d"(%2#0, %cst_1, %cst_3) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x64xi8>, tensor<64x3x3x64xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>
      %9 = "hls.dataflow.source"() : () -> i1
      "hls.dataflow.output"(%8, %9) : (tensor<1x32x32x64xi8>, i1) -> ()
    }
    %4:2 = hls.dataflow.node() -> tensor<1x32x32x64xi8>, i1 {
      "hls.dataflow.sink"(%3#1) : (i1) -> ()
      %8 = "tosa.add"(%3#0, %1) : (tensor<1x32x32x64xi8>, tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
      %9 = "tosa.clamp"(%8) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
      %10 = "hls.dataflow.source"() : () -> i1
      "hls.dataflow.output"(%9, %10) : (tensor<1x32x32x64xi8>, i1) -> ()
    }
    %5:2 = hls.dataflow.node() -> tensor<1x1x1x64xi8>, i1 {
      "hls.dataflow.sink"(%4#1) : (i1) -> ()
      %8 = "tosa.avg_pool2d"(%4#0) {kernel = [32, 32], pad = [0, 0, 0, 0], quantization_info = {input_zp = 0 : i32, output_zp = 0 : i32}, stride = [32, 32]} : (tensor<1x32x32x64xi8>) -> tensor<1x1x1x64xi8>
      %9 = "hls.dataflow.source"() : () -> i1
      "hls.dataflow.output"(%8, %9) : (tensor<1x1x1x64xi8>, i1) -> ()
    }
    %6:2 = hls.dataflow.node() -> tensor<1x1x10xi8>, i1 {
      "hls.dataflow.sink"(%5#1) : (i1) -> ()
      %8 = "tosa.transpose"(%5#0, %cst_0) : (tensor<1x1x1x64xi8>, tensor<4xi32>) -> tensor<1x64x1x1xi8>
      %9 = "tosa.reshape"(%8) {new_shape = [1, 1, 64]} : (tensor<1x64x1x1xi8>) -> tensor<1x1x64xi8>
      %10 = "tosa.matmul"(%9, %cst) {quantization_info = {a_zp = 0 : i32, b_zp = 0 : i32}} : (tensor<1x1x64xi8>, tensor<1x64x10xi8>) -> tensor<1x1x10xi8>
      %11 = "hls.dataflow.source"() : () -> i1
      "hls.dataflow.output"(%10, %11) : (tensor<1x1x10xi8>, i1) -> ()
    }
    %7 = hls.dataflow.node() -> tensor<1x10xi8> {
      "hls.dataflow.sink"(%6#1) : (i1) -> ()
      %8 = "tosa.reshape"(%6#0) {new_shape = [1, 10]} : (tensor<1x1x10xi8>) -> tensor<1x10xi8>
      "hls.dataflow.output"(%8) : (tensor<1x10xi8>) -> ()
    }
    return %7 : tensor<1x10xi8>
  }
}

// CHECK: func @main(%arg0: tensor<1x3x32x32xi8>) -> tensor<1x10xi8> attributes {runtime} {
// CHECK:   %cst = arith.constant dense<1> : tensor<1x64x10xi8>
// CHECK:   %cst_0 = arith.constant dense<[0, 3, 1, 2]> : tensor<4xi32>
// CHECK:   %cst_1 = arith.constant dense<2> : tensor<64x3x3x64xi8>
// CHECK:   %cst_2 = arith.constant dense<3> : tensor<64x3x3x64xi8>
// CHECK:   %cst_3 = arith.constant dense<5> : tensor<64xi8>
// CHECK:   %cst_4 = arith.constant dense<4> : tensor<64x3x3x3xi8>
// CHECK:   %cst_5 = arith.constant dense<[0, 2, 3, 1]> : tensor<4xi32>
// CHECK:   %0 = call @forward(%arg0, %cst, %cst_0, %cst_1, %cst_2, %cst_3, %cst_4, %cst_5) : (tensor<1x3x32x32xi8>, tensor<1x64x10xi8>, tensor<4xi32>, tensor<64x3x3x64xi8>, tensor<64x3x3x64xi8>, tensor<64xi8>, tensor<64x3x3x3xi8>, tensor<4xi32>) -> tensor<1x10xi8>
// CHECK:   return %0 : tensor<1x10xi8>
// CHECK: }
