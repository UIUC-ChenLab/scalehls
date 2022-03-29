// RUN: scalehls-opt -scalehls-tosa-to-linalg-cleanup %s | FileCheck %s

  func @forward_node2(%arg0: tensor<1x32x32x64xi8>) -> tensor<1x34x34x64xi8> {
    // CHECK: %0 = linalg.init_tensor [1, 34, 34, 64] : tensor<1x34x34x64xi8>
    // CHECK: %1 = linalg.fill ins(%c0_i8 : i8) outs(%0 : tensor<1x34x34x64xi8>) -> tensor<1x34x34x64xi8> 
    // CHECK: %2 = linalg.generic {indexing_maps = [#map0, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%arg0 : tensor<1x32x32x64xi8>) outs(%1 : tensor<1x34x34x64xi8>) {
    // CHECK: ^bb0(%arg1: i8, %arg2: i8):
    // CHECK:   linalg.yield %arg1 : i8
    // CHECK: } -> tensor<1x34x34x64xi8>
    %c0_i8 = arith.constant 0 : i8
    %0 = tensor.pad %arg0 low[0, 1, 1, 0] high[0, 1, 1, 0] {
    ^bb0(%arg2: index, %arg3: index, %arg4: index, %arg5: index):
      tensor.yield %c0_i8 : i8
    } : tensor<1x32x32x64xi8> to tensor<1x34x34x64xi8>
    return %0 : tensor<1x34x34x64xi8>
  }

  func @forward_node6(%arg0: tensor<1x1x10xi8>) -> tensor<1x10xi8> {
    // CHECK: %cst = arith.constant dense<[1, 10]> : tensor<2xi32>
    // CHECK: %0 = tensor.reshape %arg0(%cst) : (tensor<1x1x10xi8>, tensor<2xi32>) -> tensor<1x10xi8>
    %0 = "tosa.reshape"(%arg0) {new_shape = [1, 10]} : (tensor<1x1x10xi8>) -> tensor<1x10xi8>
    return %0 : tensor<1x10xi8>
  }
