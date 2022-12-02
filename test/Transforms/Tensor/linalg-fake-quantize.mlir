// RUN: scalehls-opt -scalehls-linalg-fake-quantize %s | FileCheck %s

// CHECK: module attributes {torch.debug_module_name = "ResNet"} {
// CHECK:   func.func @forward(%arg0: tensor<1x64x56x56xi8>, %arg1: tensor<1000x64xi8>, %arg2: tensor<64x64x1x1xi8>, %arg3: tensor<64x64x3x3xi8>, %arg4: tensor<64x64x3x3xi8>) -> tensor<1x1000xi8> {
// CHECK:     [[CST_0:%.*]] = arith.constant
// CHECK:     %0 = tensor.empty() : tensor<1x64x56x56xi8>
// CHECK:     %1 = linalg.generic {indexing_maps = [#map, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%arg0 : tensor<1x64x56x56xi8>) outs(%0 : tensor<1x64x56x56xi8>) {
// CHECK:     ^bb0(%in: i8, %out: i8):
// CHECK:       %22 = arith.cmpi ugt, %in, [[CST_0]] : i8
// CHECK:       %23 = arith.select %22, %in, [[CST_0]] : i8
// CHECK:       linalg.yield %23 : i8
// CHECK:     } -> tensor<1x64x56x56xi8>
// CHECK:     %padded = tensor.pad %1 low[0, 0, 1, 1] high[0, 0, 1, 1] {
// CHECK:     ^bb0(%arg5: index, %arg6: index, %arg7: index, %arg8: index):
// CHECK:       tensor.yield [[CST_0]] : i8
// CHECK:     } : tensor<1x64x56x56xi8> to tensor<1x64x58x58xi8>
// CHECK:     %2 = tensor.empty() : tensor<1x64x28x28xi8>
// CHECK:     %3 = linalg.fill ins([[CST_0]] : i8) outs(%2 : tensor<1x64x28x28xi8>) -> tensor<1x64x28x28xi8>
// CHECK:     %4 = linalg.conv_2d_nchw_fchw {dilations = dense<1> : vector<2xi64>, strides = dense<2> : vector<2xi64>} ins(%padded, %arg4 : tensor<1x64x58x58xi8>, tensor<64x64x3x3xi8>) outs(%3 : tensor<1x64x28x28xi8>) -> tensor<1x64x28x28xi8>
// CHECK:     %5 = linalg.generic {indexing_maps = [#map, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%4 : tensor<1x64x28x28xi8>) outs(%2 : tensor<1x64x28x28xi8>) {
// CHECK:     ^bb0(%in: i8, %out: i8):
// CHECK:       %22 = arith.cmpi ugt, %in, [[CST_0]] : i8
// CHECK:       %23 = arith.select %22, %in, [[CST_0]] : i8
// CHECK:       linalg.yield %23 : i8
// CHECK:     } -> tensor<1x64x28x28xi8>
// CHECK:     %padded_0 = tensor.pad %5 low[0, 0, 1, 1] high[0, 0, 1, 1] {
// CHECK:     ^bb0(%arg5: index, %arg6: index, %arg7: index, %arg8: index):
// CHECK:       tensor.yield [[CST_0]] : i8
// CHECK:     } : tensor<1x64x28x28xi8> to tensor<1x64x30x30xi8>
// CHECK:     %6 = linalg.fill ins([[CST_0]] : i8) outs(%2 : tensor<1x64x28x28xi8>) -> tensor<1x64x28x28xi8>
// CHECK:     %7 = linalg.conv_2d_nchw_fchw {dilations = dense<1> : vector<2xi64>, strides = dense<1> : vector<2xi64>} ins(%padded_0, %arg3 : tensor<1x64x30x30xi8>, tensor<64x64x3x3xi8>) outs(%6 : tensor<1x64x28x28xi8>) -> tensor<1x64x28x28xi8>
// CHECK:     %8 = linalg.fill ins([[CST_0]] : i8) outs(%2 : tensor<1x64x28x28xi8>) -> tensor<1x64x28x28xi8>
// CHECK:     %9 = linalg.conv_2d_nchw_fchw {dilations = dense<1> : vector<2xi64>, strides = dense<2> : vector<2xi64>} ins(%1, %arg2 : tensor<1x64x56x56xi8>, tensor<64x64x1x1xi8>) outs(%8 : tensor<1x64x28x28xi8>) -> tensor<1x64x28x28xi8>
// CHECK:     %10 = linalg.generic {indexing_maps = [#map, #map, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%7, %9 : tensor<1x64x28x28xi8>, tensor<1x64x28x28xi8>) outs(%2 : tensor<1x64x28x28xi8>) {
// CHECK:     ^bb0(%in: i8, %in_1: i8, %out: i8):
// CHECK:       %22 = arith.addi %in, %in_1 : i8
// CHECK:       linalg.yield %22 : i8
// CHECK:     } -> tensor<1x64x28x28xi8>
// CHECK:     %11 = linalg.generic {indexing_maps = [#map, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%10 : tensor<1x64x28x28xi8>) outs(%2 : tensor<1x64x28x28xi8>) {
// CHECK:     ^bb0(%in: i8, %out: i8):
// CHECK:       %22 = arith.cmpi ugt, %in, [[CST_0]] : i8
// CHECK:       %23 = arith.select %22, %in, [[CST_0]] : i8
// CHECK:       linalg.yield %23 : i8
// CHECK:     } -> tensor<1x64x28x28xi8>
// CHECK:     %12 = tensor.empty() : tensor<1x64x1x1xi8>
// CHECK:     %13 = linalg.fill ins([[CST_0]] : i8) outs(%12 : tensor<1x64x1x1xi8>) -> tensor<1x64x1x1xi8>
// CHECK:     %14 = tensor.empty() : tensor<28x28xi8>
// CHECK:     %15 = linalg.pooling_nchw_sum {dilations = dense<1> : vector<2xi64>, strides = dense<1> : vector<2xi64>} ins(%11, %14 : tensor<1x64x28x28xi8>, tensor<28x28xi8>) outs(%13 : tensor<1x64x1x1xi8>) -> tensor<1x64x1x1xi8>
// CHECK:     %16 = linalg.generic {indexing_maps = [#map1, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%15 : tensor<1x64x1x1xi8>) outs(%12 : tensor<1x64x1x1xi8>) {
// CHECK:     ^bb0(%in: i8, %out: i8):
// CHECK:       %22 = arith.divui %in, [[CST_0]] : i8
// CHECK:       linalg.yield %22 : i8
// CHECK:     } -> tensor<1x64x1x1xi8>
// CHECK:     %collapsed = tensor.collapse_shape %16
// CHECK-SAME:  [0], [1, 2, 3]
// CHECK:     %17 = tensor.empty() : tensor<64x1000xi8>
// CHECK:     %18 = linalg.generic {indexing_maps = [#map2, #map3], iterator_types = ["parallel", "parallel"]} ins(%arg1 : tensor<1000x64xi8>) outs(%17 : tensor<64x1000xi8>) {
// CHECK:     ^bb0(%in: i8, %out: i8):
// CHECK:       linalg.yield %in : i8
// CHECK:     } -> tensor<64x1000xi8>
// CHECK:     %19 = tensor.empty() : tensor<1x1000xi8>
// CHECK:     %20 = linalg.fill ins([[CST_0]] : i8) outs(%19 : tensor<1x1000xi8>) -> tensor<1x1000xi8>
// CHECK:     %21 = linalg.matmul ins(%collapsed, %18 : tensor<1x64xi8>, tensor<64x1000xi8>) outs(%20 : tensor<1x1000xi8>) -> tensor<1x1000xi8>
// CHECK:     return %21 : tensor<1x1000xi8>
// CHECK:   }
// CHECK: }

#map = affine_map<(d0, d1, d2, d3) -> (0, d1, d2, d3)>
#map1 = affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>
#map2 = affine_map<(d0, d1) -> (d0, d1)>
#map3 = affine_map<(d0, d1) -> (d1, d0)>
module attributes {torch.debug_module_name = "ResNet"} {
  func.func @forward(%arg0: tensor<1x64x56x56xf32>, %cst: tensor<1000x64xf32>, %cst_0: tensor<64x64x1x1xf32>, %cst_1: tensor<64x64x3x3xf32>, %cst_2: tensor<64x64x3x3xf32>) -> tensor<1x1000xf32> {
    %cst_3 = arith.constant 0.000000e+00 : f32
    %cst_4 = arith.constant 7.840000e+02 : f32
    %0 = tensor.empty() : tensor<1x64x56x56xf32>
    %1 = linalg.generic {indexing_maps = [#map, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%arg0 : tensor<1x64x56x56xf32>) outs(%0 : tensor<1x64x56x56xf32>) {
    ^bb0(%in: f32, %out: f32):
      %22 = arith.cmpf ugt, %in, %cst_3 : f32
      %23 = arith.select %22, %in, %cst_3 : f32
      linalg.yield %23 : f32
    } -> tensor<1x64x56x56xf32>
    %padded = tensor.pad %1 low[0, 0, 1, 1] high[0, 0, 1, 1] {
    ^bb0(%arg1: index, %arg2: index, %arg3: index, %arg4: index):
      tensor.yield %cst_3 : f32
    } : tensor<1x64x56x56xf32> to tensor<1x64x58x58xf32>
    %2 = tensor.empty() : tensor<1x64x28x28xf32>
    %3 = linalg.fill ins(%cst_3 : f32) outs(%2 : tensor<1x64x28x28xf32>) -> tensor<1x64x28x28xf32>
    %4 = linalg.conv_2d_nchw_fchw {dilations = dense<1> : vector<2xi64>, strides = dense<2> : vector<2xi64>} ins(%padded, %cst_2 : tensor<1x64x58x58xf32>, tensor<64x64x3x3xf32>) outs(%3 : tensor<1x64x28x28xf32>) -> tensor<1x64x28x28xf32>
    %5 = linalg.generic {indexing_maps = [#map, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%4 : tensor<1x64x28x28xf32>) outs(%2 : tensor<1x64x28x28xf32>) {
    ^bb0(%in: f32, %out: f32):
      %22 = arith.cmpf ugt, %in, %cst_3 : f32
      %23 = arith.select %22, %in, %cst_3 : f32
      linalg.yield %23 : f32
    } -> tensor<1x64x28x28xf32>
    %padded_5 = tensor.pad %5 low[0, 0, 1, 1] high[0, 0, 1, 1] {
    ^bb0(%arg1: index, %arg2: index, %arg3: index, %arg4: index):
      tensor.yield %cst_3 : f32
    } : tensor<1x64x28x28xf32> to tensor<1x64x30x30xf32>
    %6 = linalg.fill ins(%cst_3 : f32) outs(%2 : tensor<1x64x28x28xf32>) -> tensor<1x64x28x28xf32>
    %7 = linalg.conv_2d_nchw_fchw {dilations = dense<1> : vector<2xi64>, strides = dense<1> : vector<2xi64>} ins(%padded_5, %cst_1 : tensor<1x64x30x30xf32>, tensor<64x64x3x3xf32>) outs(%6 : tensor<1x64x28x28xf32>) -> tensor<1x64x28x28xf32>
    %8 = linalg.fill ins(%cst_3 : f32) outs(%2 : tensor<1x64x28x28xf32>) -> tensor<1x64x28x28xf32>
    %9 = linalg.conv_2d_nchw_fchw {dilations = dense<1> : vector<2xi64>, strides = dense<2> : vector<2xi64>} ins(%1, %cst_0 : tensor<1x64x56x56xf32>, tensor<64x64x1x1xf32>) outs(%8 : tensor<1x64x28x28xf32>) -> tensor<1x64x28x28xf32>
    %10 = linalg.generic {indexing_maps = [#map, #map, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%7, %9 : tensor<1x64x28x28xf32>, tensor<1x64x28x28xf32>) outs(%2 : tensor<1x64x28x28xf32>) {
    ^bb0(%in: f32, %in_6: f32, %out: f32):
      %22 = arith.addf %in, %in_6 : f32
      linalg.yield %22 : f32
    } -> tensor<1x64x28x28xf32>
    %11 = linalg.generic {indexing_maps = [#map, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%10 : tensor<1x64x28x28xf32>) outs(%2 : tensor<1x64x28x28xf32>) {
    ^bb0(%in: f32, %out: f32):
      %22 = arith.cmpf ugt, %in, %cst_3 : f32
      %23 = arith.select %22, %in, %cst_3 : f32
      linalg.yield %23 : f32
    } -> tensor<1x64x28x28xf32>
    %12 = tensor.empty() : tensor<1x64x1x1xf32>
    %13 = linalg.fill ins(%cst_3 : f32) outs(%12 : tensor<1x64x1x1xf32>) -> tensor<1x64x1x1xf32>
    %14 = tensor.empty() : tensor<28x28xf32>
    %15 = linalg.pooling_nchw_sum {dilations = dense<1> : vector<2xi64>, strides = dense<1> : vector<2xi64>} ins(%11, %14 : tensor<1x64x28x28xf32>, tensor<28x28xf32>) outs(%13 : tensor<1x64x1x1xf32>) -> tensor<1x64x1x1xf32>
    %16 = linalg.generic {indexing_maps = [#map1, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%15 : tensor<1x64x1x1xf32>) outs(%12 : tensor<1x64x1x1xf32>) {
    ^bb0(%in: f32, %out: f32):
      %22 = arith.divf %in, %cst_4 : f32
      linalg.yield %22 : f32
    } -> tensor<1x64x1x1xf32>
    %collapsed = tensor.collapse_shape %16 [[0], [1, 2, 3]] : tensor<1x64x1x1xf32> into tensor<1x64xf32>
    %17 = tensor.empty() : tensor<64x1000xf32>
    %18 = linalg.generic {indexing_maps = [#map2, #map3], iterator_types = ["parallel", "parallel"]} ins(%cst : tensor<1000x64xf32>) outs(%17 : tensor<64x1000xf32>) {
    ^bb0(%in: f32, %out: f32):
      linalg.yield %in : f32
    } -> tensor<64x1000xf32>
    %19 = tensor.empty() : tensor<1x1000xf32>
    %20 = linalg.fill ins(%cst_3 : f32) outs(%19 : tensor<1x1000xf32>) -> tensor<1x1000xf32>
    %21 = linalg.matmul ins(%collapsed, %18 : tensor<1x64xf32>, tensor<64x1000xf32>) outs(%20 : tensor<1x1000xf32>) -> tensor<1x1000xf32>
    return %21 : tensor<1x1000xf32>
  }
}

