// RUN: scalehls-opt -scalehls-bufferize-dataflow %s | FileCheck %s

// CHECK: module attributes {torch.debug_module_name = "ResNet"} {
// CHECK:   func.func @forward(%arg0: memref<1x64x56x56xi8>, %arg1: memref<1000x64xi8>, %arg2: memref<64x64x1x1xi8>, %arg3: memref<64x64x3x3xi8>, %arg4: memref<64x64x3x3xi8>, %arg5: memref<1x1000xi8>) {
// CHECK:     %c-24_i8 = arith.constant -24 : i8
// CHECK:     %0 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x1000xi8>
// CHECK:     %1 = hls.dataflow.dispatch : memref<1x1000xi8> {
// CHECK:       %2 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x56x56xi8>
// CHECK:       %3 = hls.dataflow.task : memref<1x64x56x56xi8> {
// CHECK:         linalg.generic {indexing_maps = [#map, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%arg0 : memref<1x64x56x56xi8>) outs(%2 : memref<1x64x56x56xi8>) {
// CHECK:         ^bb0(%in: i8, %out: i8):
// CHECK:           %13 = arith.cmpi ugt, %in, %c-24_i8 : i8
// CHECK:           %14 = arith.select %13, %in, %c-24_i8 : i8
// CHECK:           linalg.yield %14 : i8
// CHECK:         }
// CHECK:         hls.dataflow.yield %2 : memref<1x64x56x56xi8>
// CHECK:       }
// CHECK:       %4 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x28x28xi8>
// CHECK:       %5 = hls.dataflow.task : memref<1x64x28x28xi8> {
// CHECK:         %13 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x58x58xi8>
// CHECK:         %14 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x58x58xi8>
// CHECK:         memref.copy %13, %14 : memref<1x64x58x58xi8> to memref<1x64x58x58xi8>
// CHECK:         %subview = memref.subview %14[0, 0, 1, 1] [1, 64, 56, 56] [1, 1, 1, 1] : memref<1x64x58x58xi8> to memref<1x64x56x56xi8, strided<[215296, 3364, 58, 1], offset: 59>>
// CHECK:         memref.copy %2, %subview : memref<1x64x56x56xi8> to memref<1x64x56x56xi8, strided<[215296, 3364, 58, 1], offset: 59>>
// CHECK:         %15 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
// CHECK:         %16 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x28x28xi8>
// CHECK:         memref.copy %15, %16 : memref<1x64x28x28xi8> to memref<1x64x28x28xi8>
// CHECK:         linalg.conv_2d_nchw_fchw {dilations = dense<1> : vector<2xi64>, strides = dense<2> : vector<2xi64>} ins(%14, %arg4 : memref<1x64x58x58xi8>, memref<64x64x3x3xi8>) outs(%16 : memref<1x64x28x28xi8>)
// CHECK:         linalg.generic {indexing_maps = [#map, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%16 : memref<1x64x28x28xi8>) outs(%4 : memref<1x64x28x28xi8>) {
// CHECK:         ^bb0(%in: i8, %out: i8):
// CHECK:           %17 = arith.cmpi ugt, %in, %c-24_i8 : i8
// CHECK:           %18 = arith.select %17, %in, %c-24_i8 : i8
// CHECK:           linalg.yield %18 : i8
// CHECK:         }
// CHECK:         hls.dataflow.yield %4 : memref<1x64x28x28xi8>
// CHECK:       }
// CHECK:       %6 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x28x28xi8>
// CHECK:       %7 = hls.dataflow.task : memref<1x64x28x28xi8> {
// CHECK:         %13 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x30x30xi8>
// CHECK:         %14 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x30x30xi8>
// CHECK:         memref.copy %13, %14 : memref<1x64x30x30xi8> to memref<1x64x30x30xi8>
// CHECK:         %subview = memref.subview %14[0, 0, 1, 1] [1, 64, 28, 28] [1, 1, 1, 1] : memref<1x64x30x30xi8> to memref<1x64x28x28xi8, strided<[57600, 900, 30, 1], offset: 31>>
// CHECK:         memref.copy %4, %subview : memref<1x64x28x28xi8> to memref<1x64x28x28xi8, strided<[57600, 900, 30, 1], offset: 31>>
// CHECK:         %15 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
// CHECK:         memref.copy %15, %6 : memref<1x64x28x28xi8> to memref<1x64x28x28xi8>
// CHECK:         linalg.conv_2d_nchw_fchw {dilations = dense<1> : vector<2xi64>, strides = dense<1> : vector<2xi64>} ins(%14, %arg3 : memref<1x64x30x30xi8>, memref<64x64x3x3xi8>) outs(%6 : memref<1x64x28x28xi8>)
// CHECK:         hls.dataflow.yield %6 : memref<1x64x28x28xi8>
// CHECK:       }
// CHECK:       %8 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x28x28xi8>
// CHECK:       %9 = hls.dataflow.task : memref<1x64x28x28xi8> {
// CHECK:         %13 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
// CHECK:         %14 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x28x28xi8>
// CHECK:         memref.copy %13, %14 : memref<1x64x28x28xi8> to memref<1x64x28x28xi8>
// CHECK:         linalg.conv_2d_nchw_fchw {dilations = dense<1> : vector<2xi64>, strides = dense<2> : vector<2xi64>} ins(%2, %arg2 : memref<1x64x56x56xi8>, memref<64x64x1x1xi8>) outs(%14 : memref<1x64x28x28xi8>)
// CHECK:         linalg.generic {indexing_maps = [#map, #map, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%6, %14 : memref<1x64x28x28xi8>, memref<1x64x28x28xi8>) outs(%8 : memref<1x64x28x28xi8>) {
// CHECK:         ^bb0(%in: i8, %in_0: i8, %out: i8):
// CHECK:           %15 = arith.addi %in, %in_0 : i8
// CHECK:           %16 = arith.cmpi ugt, %15, %c-24_i8 : i8
// CHECK:           %17 = arith.select %16, %15, %c-24_i8 : i8
// CHECK:           linalg.yield %17 : i8
// CHECK:         }
// CHECK:         hls.dataflow.yield %8 : memref<1x64x28x28xi8>
// CHECK:       }
// CHECK:       %10 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x1x1xi8>
// CHECK:       %11 = hls.dataflow.task : memref<1x64x1x1xi8> {
// CHECK:         %13 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x1x1xi8>
// CHECK:         %14 = hls.dataflow.buffer {depth = 1 : i32} : memref<28x28xi8>
// CHECK:         %15 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x1x1xi8>
// CHECK:         memref.copy %13, %15 : memref<1x64x1x1xi8> to memref<1x64x1x1xi8>
// CHECK:         linalg.pooling_nchw_sum {dilations = dense<1> : vector<2xi64>, strides = dense<1> : vector<2xi64>} ins(%8, %14 : memref<1x64x28x28xi8>, memref<28x28xi8>) outs(%15 : memref<1x64x1x1xi8>)
// CHECK:         linalg.generic {indexing_maps = [#map1, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%15 : memref<1x64x1x1xi8>) outs(%10 : memref<1x64x1x1xi8>) {
// CHECK:         ^bb0(%in: i8, %out: i8):
// CHECK:           %16 = arith.divui %in, %c-24_i8 : i8
// CHECK:           linalg.yield %16 : i8
// CHECK:         }
// CHECK:         hls.dataflow.yield %10 : memref<1x64x1x1xi8>
// CHECK:       }
// CHECK:       %12 = hls.dataflow.task : memref<1x1000xi8> {
// CHECK:         %collapse_shape = memref.collapse_shape %10
// CHECK-SAME:      [0], [1, 2, 3]
// CHECK:         %13 = hls.dataflow.buffer {depth = 1 : i32} : memref<64x1000xi8>
// CHECK:         linalg.generic {indexing_maps = [#map2, #map3], iterator_types = ["parallel", "parallel"]} ins(%arg1 : memref<1000x64xi8>) outs(%13 : memref<64x1000xi8>) {
// CHECK:         ^bb0(%in: i8, %out: i8):
// CHECK:           linalg.yield %in : i8
// CHECK:         }
// CHECK:         %14 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x1000xi8>
// CHECK:         memref.copy %14, %0 : memref<1x1000xi8> to memref<1x1000xi8>
// CHECK:         linalg.matmul ins(%collapse_shape, %13 : memref<1x64xi8>, memref<64x1000xi8>) outs(%0 : memref<1x1000xi8>)
// CHECK:         hls.dataflow.yield %0 : memref<1x1000xi8>
// CHECK:       }
// CHECK:       hls.dataflow.yield %0 : memref<1x1000xi8>
// CHECK:     }
// CHECK:     memref.copy %0, %arg5 : memref<1x1000xi8> to memref<1x1000xi8>
// CHECK:     return
// CHECK:   }
// CHECK: }

#map = affine_map<(d0, d1, d2, d3) -> (0, d1, d2, d3)>
#map1 = affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>
#map2 = affine_map<(d0, d1) -> (d0, d1)>
#map3 = affine_map<(d0, d1) -> (d1, d0)>
module attributes {torch.debug_module_name = "ResNet"} {
  func.func @forward(%arg0: memref<1x64x56x56xi8>, %arg1: memref<1000x64xi8>, %arg2: memref<64x64x1x1xi8>, %arg3: memref<64x64x3x3xi8>, %arg4: memref<64x64x3x3xi8>, %arg5: memref<1x1000xi8>) {
    %c-24_i8 = arith.constant -24 : i8
    %0 = hls.dataflow.dispatch : tensor<1x1000xi8> {
      %2 = hls.dataflow.task : tensor<1x64x56x56xi8> {
        %alloc = memref.alloc() {alignment = 128 : i64} : memref<1x64x56x56xi8>
        linalg.generic {indexing_maps = [#map, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%arg0 : memref<1x64x56x56xi8>) outs(%alloc : memref<1x64x56x56xi8>) {
        ^bb0(%in: i8, %out: i8):
          %15 = arith.cmpi ugt, %in, %c-24_i8 : i8
          %16 = arith.select %15, %in, %c-24_i8 : i8
          linalg.yield %16 : i8
        }
        %14 = bufferization.to_tensor %alloc : memref<1x64x56x56xi8>
        hls.dataflow.yield %14 : tensor<1x64x56x56xi8>
      }
      %3 = bufferization.to_memref %2 : memref<1x64x56x56xi8>
      %4 = bufferization.to_memref %2 : memref<1x64x56x56xi8>
      %5 = hls.dataflow.task : tensor<1x64x28x28xi8> {
        %alloc = memref.alloc() {alignment = 128 : i64} : memref<1x64x58x58xi8>
        linalg.fill ins(%c-24_i8 : i8) outs(%alloc : memref<1x64x58x58xi8>)
        %alloc_0 = memref.alloc() {alignment = 128 : i64} : memref<1x64x58x58xi8>
        memref.copy %alloc, %alloc_0 : memref<1x64x58x58xi8> to memref<1x64x58x58xi8>
        %subview = memref.subview %alloc_0[0, 0, 1, 1] [1, 64, 56, 56] [1, 1, 1, 1] : memref<1x64x58x58xi8> to memref<1x64x56x56xi8, strided<[215296, 3364, 58, 1], offset: 59>>
        memref.copy %3, %subview : memref<1x64x56x56xi8> to memref<1x64x56x56xi8, strided<[215296, 3364, 58, 1], offset: 59>>
        %alloc_1 = memref.alloc() {alignment = 128 : i64} : memref<1x64x28x28xi8>
        linalg.fill ins(%c-24_i8 : i8) outs(%alloc_1 : memref<1x64x28x28xi8>)
        %alloc_2 = memref.alloc() {alignment = 128 : i64} : memref<1x64x28x28xi8>
        memref.copy %alloc_1, %alloc_2 : memref<1x64x28x28xi8> to memref<1x64x28x28xi8>
        linalg.conv_2d_nchw_fchw {dilations = dense<1> : vector<2xi64>, strides = dense<2> : vector<2xi64>} ins(%alloc_0, %arg4 : memref<1x64x58x58xi8>, memref<64x64x3x3xi8>) outs(%alloc_2 : memref<1x64x28x28xi8>)
        %alloc_3 = memref.alloc() {alignment = 128 : i64} : memref<1x64x28x28xi8>
        linalg.generic {indexing_maps = [#map, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%alloc_2 : memref<1x64x28x28xi8>) outs(%alloc_3 : memref<1x64x28x28xi8>) {
        ^bb0(%in: i8, %out: i8):
          %15 = arith.cmpi ugt, %in, %c-24_i8 : i8
          %16 = arith.select %15, %in, %c-24_i8 : i8
          linalg.yield %16 : i8
        }
        %14 = bufferization.to_tensor %alloc_3 : memref<1x64x28x28xi8>
        hls.dataflow.yield %14 : tensor<1x64x28x28xi8>
      }
      %6 = bufferization.to_memref %5 : memref<1x64x28x28xi8>
      %7 = hls.dataflow.task : tensor<1x64x28x28xi8> {
        %alloc = memref.alloc() {alignment = 128 : i64} : memref<1x64x30x30xi8>
        linalg.fill ins(%c-24_i8 : i8) outs(%alloc : memref<1x64x30x30xi8>)
        %alloc_0 = memref.alloc() {alignment = 128 : i64} : memref<1x64x30x30xi8>
        memref.copy %alloc, %alloc_0 : memref<1x64x30x30xi8> to memref<1x64x30x30xi8>
        %subview = memref.subview %alloc_0[0, 0, 1, 1] [1, 64, 28, 28] [1, 1, 1, 1] : memref<1x64x30x30xi8> to memref<1x64x28x28xi8, strided<[57600, 900, 30, 1], offset: 31>>
        memref.copy %6, %subview : memref<1x64x28x28xi8> to memref<1x64x28x28xi8, strided<[57600, 900, 30, 1], offset: 31>>
        %alloc_1 = memref.alloc() {alignment = 128 : i64} : memref<1x64x28x28xi8>
        linalg.fill ins(%c-24_i8 : i8) outs(%alloc_1 : memref<1x64x28x28xi8>)
        %alloc_2 = memref.alloc() {alignment = 128 : i64} : memref<1x64x28x28xi8>
        memref.copy %alloc_1, %alloc_2 : memref<1x64x28x28xi8> to memref<1x64x28x28xi8>
        linalg.conv_2d_nchw_fchw {dilations = dense<1> : vector<2xi64>, strides = dense<1> : vector<2xi64>} ins(%alloc_0, %arg3 : memref<1x64x30x30xi8>, memref<64x64x3x3xi8>) outs(%alloc_2 : memref<1x64x28x28xi8>)
        %14 = bufferization.to_tensor %alloc_2 : memref<1x64x28x28xi8>
        hls.dataflow.yield %14 : tensor<1x64x28x28xi8>
      }
      %8 = bufferization.to_memref %7 : memref<1x64x28x28xi8>
      %9 = hls.dataflow.task : tensor<1x64x28x28xi8> {
        %alloc = memref.alloc() {alignment = 128 : i64} : memref<1x64x28x28xi8>
        linalg.fill ins(%c-24_i8 : i8) outs(%alloc : memref<1x64x28x28xi8>)
        %alloc_0 = memref.alloc() {alignment = 128 : i64} : memref<1x64x28x28xi8>
        memref.copy %alloc, %alloc_0 : memref<1x64x28x28xi8> to memref<1x64x28x28xi8>
        linalg.conv_2d_nchw_fchw {dilations = dense<1> : vector<2xi64>, strides = dense<2> : vector<2xi64>} ins(%4, %arg2 : memref<1x64x56x56xi8>, memref<64x64x1x1xi8>) outs(%alloc_0 : memref<1x64x28x28xi8>)
        %alloc_1 = memref.alloc() {alignment = 128 : i64} : memref<1x64x28x28xi8>
        linalg.generic {indexing_maps = [#map, #map, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%8, %alloc_0 : memref<1x64x28x28xi8>, memref<1x64x28x28xi8>) outs(%alloc_1 : memref<1x64x28x28xi8>) {
        ^bb0(%in: i8, %in_2: i8, %out: i8):
          %15 = arith.addi %in, %in_2 : i8
          %16 = arith.cmpi ugt, %15, %c-24_i8 : i8
          %17 = arith.select %16, %15, %c-24_i8 : i8
          linalg.yield %17 : i8
        }
        %14 = bufferization.to_tensor %alloc_1 : memref<1x64x28x28xi8>
        hls.dataflow.yield %14 : tensor<1x64x28x28xi8>
      }
      %10 = bufferization.to_memref %9 : memref<1x64x28x28xi8>
      %11 = hls.dataflow.task : tensor<1x64x1x1xi8> {
        %alloc = memref.alloc() {alignment = 128 : i64} : memref<1x64x1x1xi8>
        linalg.fill ins(%c-24_i8 : i8) outs(%alloc : memref<1x64x1x1xi8>)
        %14 = tensor.empty() : tensor<28x28xi8>
        %15 = bufferization.to_memref %14 : memref<28x28xi8>
        %alloc_0 = memref.alloc() {alignment = 128 : i64} : memref<1x64x1x1xi8>
        memref.copy %alloc, %alloc_0 : memref<1x64x1x1xi8> to memref<1x64x1x1xi8>
        linalg.pooling_nchw_sum {dilations = dense<1> : vector<2xi64>, strides = dense<1> : vector<2xi64>} ins(%10, %15 : memref<1x64x28x28xi8>, memref<28x28xi8>) outs(%alloc_0 : memref<1x64x1x1xi8>)
        %alloc_1 = memref.alloc() {alignment = 128 : i64} : memref<1x64x1x1xi8>
        linalg.generic {indexing_maps = [#map1, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%alloc_0 : memref<1x64x1x1xi8>) outs(%alloc_1 : memref<1x64x1x1xi8>) {
        ^bb0(%in: i8, %out: i8):
          %17 = arith.divui %in, %c-24_i8 : i8
          linalg.yield %17 : i8
        }
        %16 = bufferization.to_tensor %alloc_1 : memref<1x64x1x1xi8>
        hls.dataflow.yield %16 : tensor<1x64x1x1xi8>
      }
      %12 = bufferization.to_memref %11 : memref<1x64x1x1xi8>
      %13 = hls.dataflow.task : tensor<1x1000xi8> {
        %collapse_shape = memref.collapse_shape %12 [[0], [1, 2, 3]] : memref<1x64x1x1xi8> into memref<1x64xi8>
        %alloc = memref.alloc() {alignment = 128 : i64} : memref<64x1000xi8>
        linalg.generic {indexing_maps = [#map2, #map3], iterator_types = ["parallel", "parallel"]} ins(%arg1 : memref<1000x64xi8>) outs(%alloc : memref<64x1000xi8>) {
        ^bb0(%in: i8, %out: i8):
          linalg.yield %in : i8
        }
        %alloc_0 = memref.alloc() {alignment = 128 : i64} : memref<1x1000xi8>
        linalg.fill ins(%c-24_i8 : i8) outs(%alloc_0 : memref<1x1000xi8>)
        %alloc_1 = memref.alloc() {alignment = 128 : i64} : memref<1x1000xi8>
        memref.copy %alloc_0, %alloc_1 : memref<1x1000xi8> to memref<1x1000xi8>
        linalg.matmul ins(%collapse_shape, %alloc : memref<1x64xi8>, memref<64x1000xi8>) outs(%alloc_1 : memref<1x1000xi8>)
        %14 = bufferization.to_tensor %alloc_1 : memref<1x1000xi8>
        hls.dataflow.yield %14 : tensor<1x1000xi8>
      }
      hls.dataflow.yield %13 : tensor<1x1000xi8>
    }
    %1 = bufferization.to_memref %0 : memref<1x1000xi8>
    memref.copy %1, %arg5 : memref<1x1000xi8> to memref<1x1000xi8>
    return
  }
}

