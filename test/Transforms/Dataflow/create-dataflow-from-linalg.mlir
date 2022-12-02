// RUN: scalehls-opt -scalehls-create-dataflow-from-linalg %s | FileCheck %s

// CHECK: module attributes {torch.debug_module_name = "ResNet"} {
// CHECK:   func.func @forward(%arg0: tensor<1x64x56x56xi8>, %arg1: tensor<1000x64xi8>, %arg2: tensor<64x64x1x1xi8>, %arg3: tensor<64x64x3x3xi8>, %arg4: tensor<64x64x3x3xi8>) -> tensor<1x1000xi8> {
// CHECK:     %c-24_i8 = arith.constant -24 : i8
// CHECK:     %0 = hls.dataflow.dispatch : tensor<1x1000xi8> {
// CHECK:       %1:2 = hls.dataflow.task : tensor<1x64x56x56xi8>, tensor<1x64x56x56xi8> {
// CHECK:         %7 = tensor.empty() : tensor<1x64x56x56xi8>
// CHECK:         %8 = linalg.generic {indexing_maps = [#map, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%arg0 : tensor<1x64x56x56xi8>) outs(%7 : tensor<1x64x56x56xi8>) {
// CHECK:         ^bb0(%in: i8, %out: i8):
// CHECK:           %9 = arith.cmpi ugt, %in, %c-24_i8 : i8
// CHECK:           %10 = arith.select %9, %in, %c-24_i8 : i8
// CHECK:           linalg.yield %10 : i8
// CHECK:         } -> tensor<1x64x56x56xi8>
// CHECK:         hls.dataflow.yield %7, %8 : tensor<1x64x56x56xi8>, tensor<1x64x56x56xi8>
// CHECK:       }
// CHECK:       %2:2 = hls.dataflow.task : tensor<1x64x28x28xi8>, tensor<1x64x28x28xi8> {
// CHECK:         %7 = tensor.empty() : tensor<1x64x28x28xi8>
// CHECK:         %padded = tensor.pad %1#1 low[0, 0, 1, 1] high[0, 0, 1, 1] {
// CHECK:         ^bb0(%arg5: index, %arg6: index, %arg7: index, %arg8: index):
// CHECK:           tensor.yield %c-24_i8 : i8
// CHECK:         } : tensor<1x64x56x56xi8> to tensor<1x64x58x58xi8>
// CHECK:         %8 = tensor.empty() : tensor<1x64x28x28xi8>
// CHECK:         %9 = linalg.fill ins(%c-24_i8 : i8) outs(%8 : tensor<1x64x28x28xi8>) -> tensor<1x64x28x28xi8>
// CHECK:         %10 = linalg.conv_2d_nchw_fchw {dilations = dense<1> : vector<2xi64>, strides = dense<2> : vector<2xi64>} ins(%padded, %arg4 : tensor<1x64x58x58xi8>, tensor<64x64x3x3xi8>) outs(%9 : tensor<1x64x28x28xi8>) -> tensor<1x64x28x28xi8>
// CHECK:         %11 = linalg.generic {indexing_maps = [#map, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%10 : tensor<1x64x28x28xi8>) outs(%7 : tensor<1x64x28x28xi8>) {
// CHECK:         ^bb0(%in: i8, %out: i8):
// CHECK:           %12 = arith.cmpi ugt, %in, %c-24_i8 : i8
// CHECK:           %13 = arith.select %12, %in, %c-24_i8 : i8
// CHECK:           linalg.yield %13 : i8
// CHECK:         } -> tensor<1x64x28x28xi8>
// CHECK:         hls.dataflow.yield %7, %11 : tensor<1x64x28x28xi8>, tensor<1x64x28x28xi8>
// CHECK:       }
// CHECK:       %3:2 = hls.dataflow.task : tensor<1x64x30x30xi8>, tensor<1x64x28x28xi8> {
// CHECK:         %padded = tensor.pad %2#1 low[0, 0, 1, 1] high[0, 0, 1, 1] {
// CHECK:         ^bb0(%arg5: index, %arg6: index, %arg7: index, %arg8: index):
// CHECK:           tensor.yield %c-24_i8 : i8
// CHECK:         } : tensor<1x64x28x28xi8> to tensor<1x64x30x30xi8>
// CHECK:         %7 = tensor.empty() : tensor<1x64x28x28xi8>
// CHECK:         %8 = linalg.fill ins(%c-24_i8 : i8) outs(%7 : tensor<1x64x28x28xi8>) -> tensor<1x64x28x28xi8>
// CHECK:         %9 = linalg.conv_2d_nchw_fchw {dilations = dense<1> : vector<2xi64>, strides = dense<1> : vector<2xi64>} ins(%padded, %arg3 : tensor<1x64x30x30xi8>, tensor<64x64x3x3xi8>) outs(%8 : tensor<1x64x28x28xi8>) -> tensor<1x64x28x28xi8>
// CHECK:         hls.dataflow.yield %padded, %9 : tensor<1x64x30x30xi8>, tensor<1x64x28x28xi8>
// CHECK:       }
// CHECK:       %4:2 = hls.dataflow.task : tensor<1x64x28x28xi8>, tensor<1x64x28x28xi8> {
// CHECK:         %7 = tensor.empty() : tensor<1x64x28x28xi8>
// CHECK:         %8 = tensor.empty() : tensor<1x64x28x28xi8>
// CHECK:         %9 = linalg.fill ins(%c-24_i8 : i8) outs(%8 : tensor<1x64x28x28xi8>) -> tensor<1x64x28x28xi8>
// CHECK:         %10 = linalg.conv_2d_nchw_fchw {dilations = dense<1> : vector<2xi64>, strides = dense<2> : vector<2xi64>} ins(%1#1, %arg2 : tensor<1x64x56x56xi8>, tensor<64x64x1x1xi8>) outs(%9 : tensor<1x64x28x28xi8>) -> tensor<1x64x28x28xi8>
// CHECK:         %11 = linalg.generic {indexing_maps = [#map, #map, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%3#1, %10 : tensor<1x64x28x28xi8>, tensor<1x64x28x28xi8>) outs(%7 : tensor<1x64x28x28xi8>) {
// CHECK:         ^bb0(%in: i8, %in_0: i8, %out: i8):
// CHECK:           %12 = arith.addi %in, %in_0 : i8
// CHECK:           %13 = arith.cmpi ugt, %12, %c-24_i8 : i8
// CHECK:           %14 = arith.select %13, %12, %c-24_i8 : i8
// CHECK:           linalg.yield %14 : i8
// CHECK:         } -> tensor<1x64x28x28xi8>
// CHECK:         hls.dataflow.yield %7, %11 : tensor<1x64x28x28xi8>, tensor<1x64x28x28xi8>
// CHECK:       }
// CHECK:       %5:2 = hls.dataflow.task : tensor<1x64x1x1xi8>, tensor<1x64x1x1xi8> {
// CHECK:         %7 = tensor.empty() : tensor<1x64x1x1xi8>
// CHECK:         %8 = tensor.empty() : tensor<1x64x1x1xi8>
// CHECK:         %9 = linalg.fill ins(%c-24_i8 : i8) outs(%8 : tensor<1x64x1x1xi8>) -> tensor<1x64x1x1xi8>
// CHECK:         %10 = tensor.empty() : tensor<28x28xi8>
// CHECK:         %11 = linalg.pooling_nchw_sum {dilations = dense<1> : vector<2xi64>, strides = dense<1> : vector<2xi64>} ins(%4#1, %10 : tensor<1x64x28x28xi8>, tensor<28x28xi8>) outs(%9 : tensor<1x64x1x1xi8>) -> tensor<1x64x1x1xi8>
// CHECK:         %12 = linalg.generic {indexing_maps = [#map1, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%11 : tensor<1x64x1x1xi8>) outs(%7 : tensor<1x64x1x1xi8>) {
// CHECK:         ^bb0(%in: i8, %out: i8):
// CHECK:           %13 = arith.divui %in, %c-24_i8 : i8
// CHECK:           linalg.yield %13 : i8
// CHECK:         } -> tensor<1x64x1x1xi8>
// CHECK:         hls.dataflow.yield %7, %12 : tensor<1x64x1x1xi8>, tensor<1x64x1x1xi8>
// CHECK:       }
// CHECK:       %6:2 = hls.dataflow.task : tensor<1x64xi8>, tensor<1x1000xi8> {
// CHECK:         %collapsed = tensor.collapse_shape %5#1
// CHECK-SAME:      [0], [1, 2, 3]
// CHECK:         %7 = tensor.empty() : tensor<64x1000xi8>
// CHECK:         %8 = linalg.generic {indexing_maps = [#map2, #map3], iterator_types = ["parallel", "parallel"]} ins(%arg1 : tensor<1000x64xi8>) outs(%7 : tensor<64x1000xi8>) {
// CHECK:         ^bb0(%in: i8, %out: i8):
// CHECK:           linalg.yield %in : i8
// CHECK:         } -> tensor<64x1000xi8>
// CHECK:         %9 = tensor.empty() : tensor<1x1000xi8>
// CHECK:         %10 = linalg.fill ins(%c-24_i8 : i8) outs(%9 : tensor<1x1000xi8>) -> tensor<1x1000xi8>
// CHECK:         %11 = linalg.matmul ins(%collapsed, %8 : tensor<1x64xi8>, tensor<64x1000xi8>) outs(%10 : tensor<1x1000xi8>) -> tensor<1x1000xi8>
// CHECK:         hls.dataflow.yield %collapsed, %11 : tensor<1x64xi8>, tensor<1x1000xi8>
// CHECK:       }
// CHECK:       hls.dataflow.yield %6#1 : tensor<1x1000xi8>
// CHECK:     }
// CHECK:     return %0 : tensor<1x1000xi8>
// CHECK:   }
// CHECK: }

#map = affine_map<(d0, d1, d2, d3) -> (0, d1, d2, d3)>
#map1 = affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>
#map2 = affine_map<(d0, d1) -> (d0, d1)>
#map3 = affine_map<(d0, d1) -> (d1, d0)>
module attributes {torch.debug_module_name = "ResNet"} {
  func.func @forward(%arg0: tensor<1x64x56x56xi8>, %arg1: tensor<1000x64xi8>, %arg2: tensor<64x64x1x1xi8>, %arg3: tensor<64x64x3x3xi8>, %arg4: tensor<64x64x3x3xi8>) -> tensor<1x1000xi8> {
    %c-24_i8 = arith.constant -24 : i8
    %0 = tensor.empty() : tensor<1x64x56x56xi8>
    %1 = linalg.generic {indexing_maps = [#map, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%arg0 : tensor<1x64x56x56xi8>) outs(%0 : tensor<1x64x56x56xi8>) {
    ^bb0(%in: i8, %out: i8):
      %21 = arith.cmpi ugt, %in, %c-24_i8 : i8
      %22 = arith.select %21, %in, %c-24_i8 : i8
      linalg.yield %22 : i8
    } -> tensor<1x64x56x56xi8>
    %padded = tensor.pad %1 low[0, 0, 1, 1] high[0, 0, 1, 1] {
    ^bb0(%arg5: index, %arg6: index, %arg7: index, %arg8: index):
      tensor.yield %c-24_i8 : i8
    } : tensor<1x64x56x56xi8> to tensor<1x64x58x58xi8>
    %2 = tensor.empty() : tensor<1x64x28x28xi8>
    %3 = linalg.fill ins(%c-24_i8 : i8) outs(%2 : tensor<1x64x28x28xi8>) -> tensor<1x64x28x28xi8>
    %4 = linalg.conv_2d_nchw_fchw {dilations = dense<1> : vector<2xi64>, strides = dense<2> : vector<2xi64>} ins(%padded, %arg4 : tensor<1x64x58x58xi8>, tensor<64x64x3x3xi8>) outs(%3 : tensor<1x64x28x28xi8>) -> tensor<1x64x28x28xi8>
    %5 = linalg.generic {indexing_maps = [#map, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%4 : tensor<1x64x28x28xi8>) outs(%2 : tensor<1x64x28x28xi8>) {
    ^bb0(%in: i8, %out: i8):
      %21 = arith.cmpi ugt, %in, %c-24_i8 : i8
      %22 = arith.select %21, %in, %c-24_i8 : i8
      linalg.yield %22 : i8
    } -> tensor<1x64x28x28xi8>
    %padded_0 = tensor.pad %5 low[0, 0, 1, 1] high[0, 0, 1, 1] {
    ^bb0(%arg5: index, %arg6: index, %arg7: index, %arg8: index):
      tensor.yield %c-24_i8 : i8
    } : tensor<1x64x28x28xi8> to tensor<1x64x30x30xi8>
    %6 = linalg.fill ins(%c-24_i8 : i8) outs(%2 : tensor<1x64x28x28xi8>) -> tensor<1x64x28x28xi8>
    %7 = linalg.conv_2d_nchw_fchw {dilations = dense<1> : vector<2xi64>, strides = dense<1> : vector<2xi64>} ins(%padded_0, %arg3 : tensor<1x64x30x30xi8>, tensor<64x64x3x3xi8>) outs(%6 : tensor<1x64x28x28xi8>) -> tensor<1x64x28x28xi8>
    %8 = linalg.fill ins(%c-24_i8 : i8) outs(%2 : tensor<1x64x28x28xi8>) -> tensor<1x64x28x28xi8>
    %9 = linalg.conv_2d_nchw_fchw {dilations = dense<1> : vector<2xi64>, strides = dense<2> : vector<2xi64>} ins(%1, %arg2 : tensor<1x64x56x56xi8>, tensor<64x64x1x1xi8>) outs(%8 : tensor<1x64x28x28xi8>) -> tensor<1x64x28x28xi8>
    %10 = linalg.generic {indexing_maps = [#map, #map, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%7, %9 : tensor<1x64x28x28xi8>, tensor<1x64x28x28xi8>) outs(%2 : tensor<1x64x28x28xi8>) {
    ^bb0(%in: i8, %in_1: i8, %out: i8):
      %21 = arith.addi %in, %in_1 : i8
      %22 = arith.cmpi ugt, %21, %c-24_i8 : i8
      %23 = arith.select %22, %21, %c-24_i8 : i8
      linalg.yield %23 : i8
    } -> tensor<1x64x28x28xi8>
    %11 = tensor.empty() : tensor<1x64x1x1xi8>
    %12 = linalg.fill ins(%c-24_i8 : i8) outs(%11 : tensor<1x64x1x1xi8>) -> tensor<1x64x1x1xi8>
    %13 = tensor.empty() : tensor<28x28xi8>
    %14 = linalg.pooling_nchw_sum {dilations = dense<1> : vector<2xi64>, strides = dense<1> : vector<2xi64>} ins(%10, %13 : tensor<1x64x28x28xi8>, tensor<28x28xi8>) outs(%12 : tensor<1x64x1x1xi8>) -> tensor<1x64x1x1xi8>
    %15 = linalg.generic {indexing_maps = [#map1, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%14 : tensor<1x64x1x1xi8>) outs(%11 : tensor<1x64x1x1xi8>) {
    ^bb0(%in: i8, %out: i8):
      %21 = arith.divui %in, %c-24_i8 : i8
      linalg.yield %21 : i8
    } -> tensor<1x64x1x1xi8>
    %collapsed = tensor.collapse_shape %15 [[0], [1, 2, 3]] : tensor<1x64x1x1xi8> into tensor<1x64xi8>
    %16 = tensor.empty() : tensor<64x1000xi8>
    %17 = linalg.generic {indexing_maps = [#map2, #map3], iterator_types = ["parallel", "parallel"]} ins(%arg1 : tensor<1000x64xi8>) outs(%16 : tensor<64x1000xi8>) {
    ^bb0(%in: i8, %out: i8):
      linalg.yield %in : i8
    } -> tensor<64x1000xi8>
    %18 = tensor.empty() : tensor<1x1000xi8>
    %19 = linalg.fill ins(%c-24_i8 : i8) outs(%18 : tensor<1x1000xi8>) -> tensor<1x1000xi8>
    %20 = linalg.matmul ins(%collapsed, %17 : tensor<1x64xi8>, tensor<64x1000xi8>) outs(%19 : tensor<1x1000xi8>) -> tensor<1x1000xi8>
    return %20 : tensor<1x1000xi8>
  }
}

