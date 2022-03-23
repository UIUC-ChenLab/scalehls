// RUN: scalehls-opt -scalehls-func-dataflow="gran=3 target-func=forward" -split-input-file %s | FileCheck %s

module {
  // CHECK: func @forward_dataflow2(%arg0: tensor<1x32x32x64xi8>) -> tensor<1x1x64xi8> attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=true>} {
  // CHECK:   %1 = "tosa.avg_pool2d"
  // CHECK:   %2 = "tosa.transpose"
  // CHECK:   %3 = "tosa.reshape"
  // CHECK:   return %3 : tensor<1x1x64xi8>
  // CHECK: }

  // CHECK: func @forward_dataflow4(%arg0: tensor<1x32x32x64xi8>) -> (tensor<1x32x32x64xi8>, tensor<1x32x32x64xi8>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=true>} {
  // CHECK:   %2 = "tosa.clamp"
  // CHECK:   %3 = "tosa.conv2d"
  // CHECK:   %4 = "tosa.clamp"
  // CHECK:   %5 = "hlscpp.buffer"
  // CHECK:   %6 = "hlscpp.buffer"
  // CHECK:   return %4, %6
  // CHECK: }

  // CHECK: func @forward_dataflow1(%arg0: tensor<1x1x64xi8>) -> tensor<1x10xi8> attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=true>} {
  // CHECK:   %2 = "tosa.matmul"
  // CHECK:   %3 = "tosa.reshape"
  // CHECK:   %4 = "tosa.add"
  // CHECK:   return %4
  // CHECK: }

  // CHECK: func @forward_dataflow3(%arg0: tensor<1x32x32x64xi8>, %arg1: tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8> attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=true>} {
  // CHECK:   %2 = "tosa.conv2d"
  // CHECK:   %3 = "hlscpp.buffer"
  // CHECK:   %4 = "tosa.add"
  // CHECK:   %5 = "tosa.clamp"
  // CHECK:   return %5
  // CHECK: }

  // CHECK: func @forward_dataflow5(%arg0: tensor<1x3x32x32xi8>) -> tensor<1x32x32x64xi8> attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=true>} {
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
    %0 = "tosa.const"() {value = dense<0> : tensor<1x10xi8>} : () -> tensor<1x10xi8>
    %1 = "tosa.const"() {value = dense<1> : tensor<1x64x10xi8>} : () -> tensor<1x64x10xi8>
    %2 = "tosa.const"() {value = dense<2> : tensor<64x3x3x64xi8>} : () -> tensor<64x3x3x64xi8>
    %3 = "tosa.const"() {value = dense<3> : tensor<64x3x3x64xi8>} : () -> tensor<64x3x3x64xi8>
    %4 = "tosa.const"() {value = dense<4> : tensor<64x3x3x3xi8>} : () -> tensor<64x3x3x3xi8>
    %5 = "tosa.const"() {value = dense<[0, 3, 1, 2]> : tensor<4xi32>} : () -> tensor<4xi32>
    %6 = "tosa.const"() {value = dense<[0, 2, 3, 1]> : tensor<4xi32>} : () -> tensor<4xi32>
    %7 = "tosa.const"() {value = dense<5> : tensor<64xi8>} : () -> tensor<64xi8>

    // CHECK:   %1 = call @forward_dataflow5(%arg0) : (tensor<1x3x32x32xi8>) -> tensor<1x32x32x64xi8>
    %8 = "tosa.transpose"(%arg0, %6) : (tensor<1x3x32x32xi8>, tensor<4xi32>) -> tensor<1x32x32x3xi8>
    %9 = "tosa.conv2d"(%8, %4, %7) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x3xi8>, tensor<64x3x3x3xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>

    // CHECK:   %2:2 = call @forward_dataflow4(%1) : (tensor<1x32x32x64xi8>) -> (tensor<1x32x32x64xi8>, tensor<1x32x32x64xi8>)
    %10 = "tosa.clamp"(%9) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    %11 = "tosa.conv2d"(%10, %3, %7) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x64xi8>, tensor<64x3x3x64xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>
    %12 = "tosa.clamp"(%11) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    %13 = "tosa.conv2d"(%12, %2, %7) {dilation = [1, 1], pad = [1, 1, 1, 1], quantization_info = {input_zp = 0 : i32, weight_zp = 0 : i32}, stride = [1, 1]} : (tensor<1x32x32x64xi8>, tensor<64x3x3x64xi8>, tensor<64xi8>) -> tensor<1x32x32x64xi8>

    // CHECK:   %3 = call @forward_dataflow3(%2#0, %2#1) : (tensor<1x32x32x64xi8>, tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    %14 = "tosa.add"(%13, %10) : (tensor<1x32x32x64xi8>, tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>
    %15 = "tosa.clamp"(%14) {max_fp = 3.40282347E+38 : f32, max_int = 2147483647 : i64, min_fp = 0.000000e+00 : f32, min_int = 0 : i64} : (tensor<1x32x32x64xi8>) -> tensor<1x32x32x64xi8>

    // CHECK:   %4 = call @forward_dataflow2(%3) : (tensor<1x32x32x64xi8>) -> tensor<1x1x64xi8>
    %16 = "tosa.avg_pool2d"(%15) {kernel = [32, 32], pad = [0, 0, 0, 0], quantization_info = {input_zp = 0 : i32, output_zp = 0 : i32}, stride = [32, 32]} : (tensor<1x32x32x64xi8>) -> tensor<1x1x1x64xi8>
    %17 = "tosa.transpose"(%16, %5) : (tensor<1x1x1x64xi8>, tensor<4xi32>) -> tensor<1x64x1x1xi8>
    %18 = "tosa.reshape"(%17) {new_shape = [1, 1, 64]} : (tensor<1x64x1x1xi8>) -> tensor<1x1x64xi8>

    // CHECK:   %5 = call @forward_dataflow1(%4) : (tensor<1x1x64xi8>) -> tensor<1x10xi8>
    %19 = "tosa.matmul"(%18, %1) {quantization_info = {a_zp = 0 : i32, b_zp = 0 : i32}} : (tensor<1x1x64xi8>, tensor<1x64x10xi8>) -> tensor<1x1x10xi8>
    %20 = "tosa.reshape"(%19) {new_shape = [1, 10]} : (tensor<1x1x10xi8>) -> tensor<1x10xi8>
    %21 = "tosa.add"(%20, %0) : (tensor<1x10xi8>, tensor<1x10xi8>) -> tensor<1x10xi8>

    // CHECK:   return %5 : tensor<1x10xi8>
    return %21 : tensor<1x10xi8>
  }
}

// -----

// RUN: scalehls-opt -scalehls-func-dataflow="target-func=forward" -split-input-file %s | FileCheck %s --check-prefix=CALL

module {
  func private @forward_node0(%arg0: memref<1x3x32x32xi8>, %arg1: memref<3x3x3x64xi8>, %arg2: memref<1x32x32x64xi8>) -> !hlscpp.stream<i1, 1>
  func private @forward_node1(%arg0: memref<1x32x32x64xi8>, %arg1: !hlscpp.stream<i1, 1>, %arg2: memref<3x3x64x64xi8>, %arg3: memref<1x32x32x64xi8>) -> !hlscpp.stream<i1, 1>
  func private @forward_node2(%arg0: memref<1x32x32x64xi8>, %arg1: !hlscpp.stream<i1, 1>, %arg2: memref<3x3x64x64xi8>, %arg3: memref<1x32x32x64xi8>) -> !hlscpp.stream<i1, 1>
  func private @forward_node3(%arg0: memref<1x32x32x64xi8>, %arg1: memref<1x32x32x64xi8>, %arg2: !hlscpp.stream<i1, 1>, %arg3: !hlscpp.stream<i1, 1>, %arg4: memref<1x32x32x64xi8>) -> !hlscpp.stream<i1, 1>
  func private @forward_node4(%arg0: memref<1x32x32x64xi8>, %arg1: !hlscpp.stream<i1, 1>, %arg2: memref<1x1x1x64xi8>) -> !hlscpp.stream<i1, 1>
  func private @forward_node5(%arg0: memref<1x1x1x64xi8>, %arg1: !hlscpp.stream<i1, 1>, %arg2: memref<1x64x10xi8>, %arg3: memref<1x1x10xi8>) -> !hlscpp.stream<i1, 1>
  func private @forward_node6(%arg0: memref<1x1x10xi8>, %arg1: !hlscpp.stream<i1, 1>, %arg2: memref<1x10xi8>) -> !hlscpp.stream<i1, 1>

  // CALL: func @forward_dataflow7(%arg0: memref<1x3x32x32xi8>, %arg1: memref<3x3x3x64xi8>, %arg2: memref<1x32x32x64xi8>) -> !hlscpp.stream<i1, 1> attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=true>} {
  // CALL:   %0 = call @forward_node0(%arg0, %arg1, %arg2) : (memref<1x3x32x32xi8>, memref<3x3x3x64xi8>, memref<1x32x32x64xi8>) -> !hlscpp.stream<i1, 1>
  // CALL:   return %0 : !hlscpp.stream<i1, 1>
  // CALL: }

  // CALL: func @forward_dataflow2(%arg0: memref<1x1x1x64xi8>, %arg1: !hlscpp.stream<i1, 1>, %arg2: memref<1x64x10xi8>, %arg3: memref<1x1x10xi8>) -> !hlscpp.stream<i1, 1> attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=true>} {
  // CALL:   %0 = call @forward_node5(%arg0, %arg1, %arg2, %arg3) : (memref<1x1x1x64xi8>, !hlscpp.stream<i1, 1>, memref<1x64x10xi8>, memref<1x1x10xi8>) -> !hlscpp.stream<i1, 1>
  // CALL:   return %0 : !hlscpp.stream<i1, 1>
  // CALL: }

  // CALL: func @forward_dataflow4(%arg0: memref<1x32x32x64xi8>, %arg1: memref<1x32x32x64xi8>, %arg2: !hlscpp.stream<i1, 1>, %arg3: !hlscpp.stream<i1, 1>, %arg4: memref<1x32x32x64xi8>) -> !hlscpp.stream<i1, 1> attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=true>} {
  // CALL:   %0 = call @forward_node3(%arg0, %arg1, %arg2, %arg3, %arg4) : (memref<1x32x32x64xi8>, memref<1x32x32x64xi8>, !hlscpp.stream<i1, 1>, !hlscpp.stream<i1, 1>, memref<1x32x32x64xi8>) -> !hlscpp.stream<i1, 1>
  // CALL:   return %0 : !hlscpp.stream<i1, 1>
  // CALL: }

  // CALL: func @forward_dataflow6(%arg0: memref<1x32x32x64xi8>, %arg1: !hlscpp.stream<i1, 1>, %arg2: memref<3x3x64x64xi8>, %arg3: memref<1x32x32x64xi8>) -> (!hlscpp.stream<i1, 1>, !hlscpp.stream<i1, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=true>} {
  // CALL:   %0 = call @forward_node1(%arg0, %arg1, %arg2, %arg3) : (memref<1x32x32x64xi8>, !hlscpp.stream<i1, 1>, memref<3x3x64x64xi8>, memref<1x32x32x64xi8>) -> !hlscpp.stream<i1, 1>
  // CALL:   %1 = "hlscpp.stream.buffer"(%arg1) : (!hlscpp.stream<i1, 1>) -> !hlscpp.stream<i1, 1>
  // CALL:   return %0, %1 : !hlscpp.stream<i1, 1>, !hlscpp.stream<i1, 1>
  // CALL: }

  // CALL: func @forward_dataflow1(%arg0: memref<1x1x10xi8>, %arg1: !hlscpp.stream<i1, 1>, %arg2: memref<1x10xi8>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=true>} {
  // CALL:   %0 = call @forward_node6(%arg0, %arg1, %arg2) : (memref<1x1x10xi8>, !hlscpp.stream<i1, 1>, memref<1x10xi8>) -> !hlscpp.stream<i1, 1>
  // CALL:   return
  // CALL: }

  // CALL: func @forward_dataflow3(%arg0: memref<1x32x32x64xi8>, %arg1: !hlscpp.stream<i1, 1>, %arg2: memref<1x1x1x64xi8>) -> !hlscpp.stream<i1, 1> attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=true>} {
  // CALL:   %0 = call @forward_node4(%arg0, %arg1, %arg2) : (memref<1x32x32x64xi8>, !hlscpp.stream<i1, 1>, memref<1x1x1x64xi8>) -> !hlscpp.stream<i1, 1>
  // CALL:   return %0 : !hlscpp.stream<i1, 1>
  // CALL: }

  // CALL: func @forward_dataflow5(%arg0: memref<1x32x32x64xi8>, %arg1: !hlscpp.stream<i1, 1>, %arg2: memref<3x3x64x64xi8>, %arg3: memref<1x32x32x64xi8>, %arg4: !hlscpp.stream<i1, 1>) -> (!hlscpp.stream<i1, 1>, !hlscpp.stream<i1, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=true>} {
  // CALL:   %0 = call @forward_node2(%arg0, %arg1, %arg2, %arg3) : (memref<1x32x32x64xi8>, !hlscpp.stream<i1, 1>, memref<3x3x64x64xi8>, memref<1x32x32x64xi8>) -> !hlscpp.stream<i1, 1>
  // CALL:   %1 = "hlscpp.stream.buffer"(%arg4) : (!hlscpp.stream<i1, 1>) -> !hlscpp.stream<i1, 1>
  // CALL:   return %0, %1 : !hlscpp.stream<i1, 1>, !hlscpp.stream<i1, 1>
  // CALL: }

  // CALL: func @forward(%arg0: memref<1x3x32x32xi8>, %arg1: memref<3x3x3x64xi8>, %arg2: memref<3x3x64x64xi8>, %arg3: memref<3x3x64x64xi8>, %arg4: memref<1x64x10xi8>, %arg5: memref<1x10xi8>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=true>, top_func} {
  func @forward(%arg0: memref<1x3x32x32xi8>, %arg1: memref<3x3x3x64xi8>, %arg2: memref<3x3x64x64xi8>, %arg3: memref<3x3x64x64xi8>, %arg4: memref<1x64x10xi8>, %arg5: memref<1x10xi8>) attributes {top_func} {
    %0 = memref.alloc() : memref<1x32x32x64xi8>

    // CALL: %1 = call @forward_dataflow7(%arg0, %arg1, %0) : (memref<1x3x32x32xi8>, memref<3x3x3x64xi8>, memref<1x32x32x64xi8>) -> !hlscpp.stream<i1, 1>
    %1 = call @forward_node0(%arg0, %arg1, %0) : (memref<1x3x32x32xi8>, memref<3x3x3x64xi8>, memref<1x32x32x64xi8>) -> !hlscpp.stream<i1, 1>
    %2 = memref.alloc() : memref<1x32x32x64xi8>

    // CALL: %5:2 = call @forward_dataflow6(%0, %1, %arg2, %2) : (memref<1x32x32x64xi8>, !hlscpp.stream<i1, 1>, memref<3x3x64x64xi8>, memref<1x32x32x64xi8>) -> (!hlscpp.stream<i1, 1>, !hlscpp.stream<i1, 1>)
    %3 = call @forward_node1(%0, %1, %arg2, %2) : (memref<1x32x32x64xi8>, !hlscpp.stream<i1, 1>, memref<3x3x64x64xi8>, memref<1x32x32x64xi8>) -> !hlscpp.stream<i1, 1>
    %4 = memref.alloc() : memref<1x32x32x64xi8>

    // CALL: %6:2 = call @forward_dataflow5(%2, %5#0, %arg3, %3, %5#1) : (memref<1x32x32x64xi8>, !hlscpp.stream<i1, 1>, memref<3x3x64x64xi8>, memref<1x32x32x64xi8>, !hlscpp.stream<i1, 1>) -> (!hlscpp.stream<i1, 1>, !hlscpp.stream<i1, 1>)
    %5 = call @forward_node2(%2, %3, %arg3, %4) : (memref<1x32x32x64xi8>, !hlscpp.stream<i1, 1>, memref<3x3x64x64xi8>, memref<1x32x32x64xi8>) -> !hlscpp.stream<i1, 1>
    %6 = memref.alloc() : memref<1x32x32x64xi8>

    // CALL: %7 = call @forward_dataflow4(%3, %0, %6#1, %6#0, %4) : (memref<1x32x32x64xi8>, memref<1x32x32x64xi8>, !hlscpp.stream<i1, 1>, !hlscpp.stream<i1, 1>, memref<1x32x32x64xi8>) -> !hlscpp.stream<i1, 1>
    %7 = call @forward_node3(%4, %0, %1, %5, %6) : (memref<1x32x32x64xi8>, memref<1x32x32x64xi8>, !hlscpp.stream<i1, 1>, !hlscpp.stream<i1, 1>, memref<1x32x32x64xi8>) -> !hlscpp.stream<i1, 1>
    %8 = memref.alloc() : memref<1x1x1x64xi8>

    // CALL: %9 = call @forward_dataflow3(%4, %7, %8) : (memref<1x32x32x64xi8>, !hlscpp.stream<i1, 1>, memref<1x1x1x64xi8>) -> !hlscpp.stream<i1, 1>
    %9 = call @forward_node4(%6, %7, %8) : (memref<1x32x32x64xi8>, !hlscpp.stream<i1, 1>, memref<1x1x1x64xi8>) -> !hlscpp.stream<i1, 1>
    %10 = memref.alloc() : memref<1x1x10xi8>

    // CALL: %11 = call @forward_dataflow2(%8, %9, %arg4, %10) : (memref<1x1x1x64xi8>, !hlscpp.stream<i1, 1>, memref<1x64x10xi8>, memref<1x1x10xi8>) -> !hlscpp.stream<i1, 1>
    %11 = call @forward_node5(%8, %9, %arg4, %10) : (memref<1x1x1x64xi8>, !hlscpp.stream<i1, 1>, memref<1x64x10xi8>, memref<1x1x10xi8>) -> !hlscpp.stream<i1, 1>

    // CALL: call @forward_dataflow1(%10, %11, %arg5) : (memref<1x1x10xi8>, !hlscpp.stream<i1, 1>, memref<1x10xi8>) -> ()
    %12 = call @forward_node6(%10, %11, %arg5) : (memref<1x1x10xi8>, !hlscpp.stream<i1, 1>, memref<1x10xi8>) -> !hlscpp.stream<i1, 1>
    return
  }
}
