// RUN: scalehls-opt -scalehls-simplify-copy -split-input-file %s | FileCheck %s

// CHECK: module attributes {torch.debug_module_name = "ResNet"} {
// CHECK:   func.func @forward(%arg0: memref<1x64x56x56xi8>, %arg1: memref<1000x64xi8>, %arg2: memref<64x64x1x1xi8>, %arg3: memref<64x64x3x3xi8>, %arg4: memref<64x64x3x3xi8>, %arg5: memref<1x1000xi8>) {
// CHECK:     %c-24_i8 = arith.constant -24 : i8
// CHECK:     hls.dataflow.dispatch {
// CHECK:       hls.dataflow.task {
// CHECK:         linalg.generic {indexing_maps = [#map, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%arg0 : memref<1x64x56x56xi8>) outs(%arg0 : memref<1x64x56x56xi8>) {
// CHECK:         ^bb0(%in: i8, %out: i8):
// CHECK:           %4 = arith.cmpi ugt, %in, %c-24_i8 : i8
// CHECK:           %5 = arith.select %4, %in, %c-24_i8 : i8
// CHECK:           linalg.yield %5 : i8
// CHECK:         }
// CHECK:       }
// CHECK:       %0 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
// CHECK:       hls.dataflow.task {
// CHECK:         %4 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x58x58xi8>
// CHECK:         %subview = memref.subview %4[0, 0, 1, 1] [1, 64, 56, 56] [1, 1, 1, 1] : memref<1x64x58x58xi8> to memref<1x64x56x56xi8, strided<[215296, 3364, 58, 1], offset: 59>>
// CHECK:         memref.copy %arg0, %subview : memref<1x64x56x56xi8> to memref<1x64x56x56xi8, strided<[215296, 3364, 58, 1], offset: 59>>
// CHECK:         linalg.generic {indexing_maps = [#map2, #map3, #map4], iterator_types = ["parallel", "parallel", "parallel", "parallel", "reduction", "reduction", "reduction"]} ins(%4, %arg4 : memref<1x64x58x58xi8>, memref<64x64x3x3xi8>) outs(%0 : memref<1x64x28x28xi8>) {
// CHECK:         ^bb0(%in: i8, %in_0: i8, %out: i8):
// CHECK:           %5 = arith.muli %in, %in_0 : i8
// CHECK:           %6 = arith.addi %out, %5 : i8
// CHECK:           linalg.yield %6 : i8
// CHECK:         }
// CHECK:         linalg.generic {indexing_maps = [#map, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%0 : memref<1x64x28x28xi8>) outs(%0 : memref<1x64x28x28xi8>) {
// CHECK:         ^bb0(%in: i8, %out: i8):
// CHECK:           %5 = arith.cmpi ugt, %in, %c-24_i8 : i8
// CHECK:           %6 = arith.select %5, %in, %c-24_i8 : i8
// CHECK:           linalg.yield %6 : i8
// CHECK:         }
// CHECK:       }
// CHECK:       %1 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
// CHECK:       hls.dataflow.task {
// CHECK:         %4 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x30x30xi8>
// CHECK:         %subview = memref.subview %4[0, 0, 1, 1] [1, 64, 28, 28] [1, 1, 1, 1] : memref<1x64x30x30xi8> to memref<1x64x28x28xi8, strided<[57600, 900, 30, 1], offset: 31>>
// CHECK:         memref.copy %0, %subview : memref<1x64x28x28xi8> to memref<1x64x28x28xi8, strided<[57600, 900, 30, 1], offset: 31>>
// CHECK:         linalg.generic {indexing_maps = [#map5, #map3, #map4], iterator_types = ["parallel", "parallel", "parallel", "parallel", "reduction", "reduction", "reduction"]} ins(%4, %arg3 : memref<1x64x30x30xi8>, memref<64x64x3x3xi8>) outs(%1 : memref<1x64x28x28xi8>) {
// CHECK:         ^bb0(%in: i8, %in_0: i8, %out: i8):
// CHECK:           %5 = arith.muli %in, %in_0 : i8
// CHECK:           %6 = arith.addi %out, %5 : i8
// CHECK:           linalg.yield %6 : i8
// CHECK:         }
// CHECK:       }
// CHECK:       %2 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x28x28xi8>
// CHECK:       hls.dataflow.task {
// CHECK:         %4 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
// CHECK:         linalg.generic {indexing_maps = [#map2, #map3, #map4], iterator_types = ["parallel", "parallel", "parallel", "parallel", "reduction", "reduction", "reduction"]} ins(%arg0, %arg2 : memref<1x64x56x56xi8>, memref<64x64x1x1xi8>) outs(%4 : memref<1x64x28x28xi8>) {
// CHECK:         ^bb0(%in: i8, %in_0: i8, %out: i8):
// CHECK:           %5 = arith.muli %in, %in_0 : i8
// CHECK:           %6 = arith.addi %out, %5 : i8
// CHECK:           linalg.yield %6 : i8
// CHECK:         }
// CHECK:         linalg.generic {indexing_maps = [#map, #map, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%1, %4 : memref<1x64x28x28xi8>, memref<1x64x28x28xi8>) outs(%2 : memref<1x64x28x28xi8>) {
// CHECK:         ^bb0(%in: i8, %in_0: i8, %out: i8):
// CHECK:           %5 = arith.addi %in, %in_0 : i8
// CHECK:           %6 = arith.cmpi ugt, %5, %c-24_i8 : i8
// CHECK:           %7 = arith.select %6, %5, %c-24_i8 : i8
// CHECK:           linalg.yield %7 : i8
// CHECK:         }
// CHECK:       }
// CHECK:       %3 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x1x1xi8>
// CHECK:       hls.dataflow.task {
// CHECK:         %4 = hls.dataflow.buffer {depth = 1 : i32} : memref<28x28xi8>
// CHECK:         linalg.generic {indexing_maps = [#map6, #map7, #map8], iterator_types = ["parallel", "parallel", "parallel", "parallel", "reduction", "reduction"]} ins(%2, %4 : memref<1x64x28x28xi8>, memref<28x28xi8>) outs(%3 : memref<1x64x1x1xi8>) {
// CHECK:         ^bb0(%in: i8, %in_0: i8, %out: i8):
// CHECK:           %5 = arith.addi %out, %in : i8
// CHECK:           linalg.yield %5 : i8
// CHECK:         }
// CHECK:         linalg.generic {indexing_maps = [#map1, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%3 : memref<1x64x1x1xi8>) outs(%3 : memref<1x64x1x1xi8>) {
// CHECK:         ^bb0(%in: i8, %out: i8):
// CHECK:           %5 = arith.divui %in, %c-24_i8 : i8
// CHECK:           linalg.yield %5 : i8
// CHECK:         }
// CHECK:       }
// CHECK:       hls.dataflow.task {
// CHECK:         %collapse_shape = memref.collapse_shape %3
// CHECK-SAME:      [0], [1, 2, 3]
// CHECK:         %4 = hls.dataflow.buffer {depth = 1 : i32} : memref<64x1000xi8>
// CHECK:         linalg.generic {indexing_maps = [#map9, #map10], iterator_types = ["parallel", "parallel"]} ins(%arg1 : memref<1000x64xi8>) outs(%4 : memref<64x1000xi8>) {
// CHECK:         ^bb0(%in: i8, %out: i8):
// CHECK:           linalg.yield %in : i8
// CHECK:         }
// CHECK:         %5 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x1000xi8>
// CHECK:         memref.copy %5, %arg5 : memref<1x1000xi8> to memref<1x1000xi8>
// CHECK:         linalg.generic {indexing_maps = [#map11, #map12, #map13], iterator_types = ["parallel", "parallel", "reduction"]} ins(%collapse_shape, %4 : memref<1x64xi8>, memref<64x1000xi8>) outs(%arg5 : memref<1x1000xi8>) {
// CHECK:         ^bb0(%in: i8, %in_0: i8, %out: i8):
// CHECK:           %6 = arith.muli %in, %in_0 : i8
// CHECK:           %7 = arith.addi %out, %6 : i8
// CHECK:           linalg.yield %7 : i8
// CHECK:         }
// CHECK:       }
// CHECK:     }
// CHECK:     return
// CHECK:   }
// CHECK: }

#map = affine_map<(d0, d1, d2, d3) -> (0, d1, d2, d3)>
#map1 = affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>
#map2 = affine_map<(d0, d1, d2, d3, d4, d5, d6) -> (d0, d4, d2 * 2 + d5, d3 * 2 + d6)>
#map3 = affine_map<(d0, d1, d2, d3, d4, d5, d6) -> (d1, d4, d5, d6)>
#map4 = affine_map<(d0, d1, d2, d3, d4, d5, d6) -> (d0, d1, d2, d3)>
#map5 = affine_map<(d0, d1, d2, d3, d4, d5, d6) -> (d0, d4, d2 + d5, d3 + d6)>
#map6 = affine_map<(d0, d1, d2, d3, d4, d5) -> (d0, d1, d2 + d4, d3 + d5)>
#map7 = affine_map<(d0, d1, d2, d3, d4, d5) -> (d4, d5)>
#map8 = affine_map<(d0, d1, d2, d3, d4, d5) -> (d0, d1, d2, d3)>
#map9 = affine_map<(d0, d1) -> (d0, d1)>
#map10 = affine_map<(d0, d1) -> (d1, d0)>
#map11 = affine_map<(d0, d1, d2) -> (d0, d2)>
#map12 = affine_map<(d0, d1, d2) -> (d2, d1)>
#map13 = affine_map<(d0, d1, d2) -> (d0, d1)>
module attributes {torch.debug_module_name = "ResNet"} {
  func.func @forward(%arg0: memref<1x64x56x56xi8>, %arg1: memref<1000x64xi8>, %arg2: memref<64x64x1x1xi8>, %arg3: memref<64x64x3x3xi8>, %arg4: memref<64x64x3x3xi8>, %arg5: memref<1x1000xi8>) {
    %c-24_i8 = arith.constant -24 : i8
    %0 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x1000xi8>
    hls.dataflow.dispatch {
      %1 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x56x56xi8>
      hls.dataflow.task {
        linalg.generic {indexing_maps = [#map, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%arg0 : memref<1x64x56x56xi8>) outs(%1 : memref<1x64x56x56xi8>) {
        ^bb0(%in: i8, %out: i8):
          %6 = arith.cmpi ugt, %in, %c-24_i8 : i8
          %7 = arith.select %6, %in, %c-24_i8 : i8
          linalg.yield %7 : i8
        }
      }
      %2 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x28x28xi8>
      hls.dataflow.task {
        %6 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x58x58xi8>
        %7 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x58x58xi8>
        memref.copy %6, %7 : memref<1x64x58x58xi8> to memref<1x64x58x58xi8>
        %subview = memref.subview %7[0, 0, 1, 1] [1, 64, 56, 56] [1, 1, 1, 1] : memref<1x64x58x58xi8> to memref<1x64x56x56xi8, strided<[215296, 3364, 58, 1], offset: 59>>
        memref.copy %1, %subview : memref<1x64x56x56xi8> to memref<1x64x56x56xi8, strided<[215296, 3364, 58, 1], offset: 59>>
        %8 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
        %9 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x28x28xi8>
        memref.copy %8, %9 : memref<1x64x28x28xi8> to memref<1x64x28x28xi8>
        linalg.generic {indexing_maps = [#map2, #map3, #map4], iterator_types = ["parallel", "parallel", "parallel", "parallel", "reduction", "reduction", "reduction"]} ins(%7, %arg4 : memref<1x64x58x58xi8>, memref<64x64x3x3xi8>) outs(%9 : memref<1x64x28x28xi8>) {
        ^bb0(%in: i8, %in_0: i8, %out: i8):
          %10 = arith.muli %in, %in_0 : i8
          %11 = arith.addi %out, %10 : i8
          linalg.yield %11 : i8
        }
        linalg.generic {indexing_maps = [#map, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%9 : memref<1x64x28x28xi8>) outs(%2 : memref<1x64x28x28xi8>) {
        ^bb0(%in: i8, %out: i8):
          %10 = arith.cmpi ugt, %in, %c-24_i8 : i8
          %11 = arith.select %10, %in, %c-24_i8 : i8
          linalg.yield %11 : i8
        }
      }
      %3 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x28x28xi8>
      hls.dataflow.task {
        %6 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x30x30xi8>
        %7 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x30x30xi8>
        memref.copy %6, %7 : memref<1x64x30x30xi8> to memref<1x64x30x30xi8>
        %subview = memref.subview %7[0, 0, 1, 1] [1, 64, 28, 28] [1, 1, 1, 1] : memref<1x64x30x30xi8> to memref<1x64x28x28xi8, strided<[57600, 900, 30, 1], offset: 31>>
        memref.copy %2, %subview : memref<1x64x28x28xi8> to memref<1x64x28x28xi8, strided<[57600, 900, 30, 1], offset: 31>>
        %8 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
        memref.copy %8, %3 : memref<1x64x28x28xi8> to memref<1x64x28x28xi8>
        linalg.generic {indexing_maps = [#map5, #map3, #map4], iterator_types = ["parallel", "parallel", "parallel", "parallel", "reduction", "reduction", "reduction"]} ins(%7, %arg3 : memref<1x64x30x30xi8>, memref<64x64x3x3xi8>) outs(%3 : memref<1x64x28x28xi8>) {
        ^bb0(%in: i8, %in_0: i8, %out: i8):
          %9 = arith.muli %in, %in_0 : i8
          %10 = arith.addi %out, %9 : i8
          linalg.yield %10 : i8
        }
      }
      %4 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x28x28xi8>
      hls.dataflow.task {
        %6 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
        %7 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x28x28xi8>
        memref.copy %6, %7 : memref<1x64x28x28xi8> to memref<1x64x28x28xi8>
        linalg.generic {indexing_maps = [#map2, #map3, #map4], iterator_types = ["parallel", "parallel", "parallel", "parallel", "reduction", "reduction", "reduction"]} ins(%1, %arg2 : memref<1x64x56x56xi8>, memref<64x64x1x1xi8>) outs(%7 : memref<1x64x28x28xi8>) {
        ^bb0(%in: i8, %in_0: i8, %out: i8):
          %8 = arith.muli %in, %in_0 : i8
          %9 = arith.addi %out, %8 : i8
          linalg.yield %9 : i8
        }
        linalg.generic {indexing_maps = [#map, #map, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%3, %7 : memref<1x64x28x28xi8>, memref<1x64x28x28xi8>) outs(%4 : memref<1x64x28x28xi8>) {
        ^bb0(%in: i8, %in_0: i8, %out: i8):
          %8 = arith.addi %in, %in_0 : i8
          %9 = arith.cmpi ugt, %8, %c-24_i8 : i8
          %10 = arith.select %9, %8, %c-24_i8 : i8
          linalg.yield %10 : i8
        }
      }
      %5 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x1x1xi8>
      hls.dataflow.task {
        %6 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x1x1xi8>
        %7 = hls.dataflow.buffer {depth = 1 : i32} : memref<28x28xi8>
        %8 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x1x1xi8>
        memref.copy %6, %8 : memref<1x64x1x1xi8> to memref<1x64x1x1xi8>
        linalg.generic {indexing_maps = [#map6, #map7, #map8], iterator_types = ["parallel", "parallel", "parallel", "parallel", "reduction", "reduction"]} ins(%4, %7 : memref<1x64x28x28xi8>, memref<28x28xi8>) outs(%8 : memref<1x64x1x1xi8>) {
        ^bb0(%in: i8, %in_0: i8, %out: i8):
          %9 = arith.addi %out, %in : i8
          linalg.yield %9 : i8
        }
        linalg.generic {indexing_maps = [#map1, #map1], iterator_types = ["parallel", "parallel", "parallel", "parallel"]} ins(%8 : memref<1x64x1x1xi8>) outs(%5 : memref<1x64x1x1xi8>) {
        ^bb0(%in: i8, %out: i8):
          %9 = arith.divui %in, %c-24_i8 : i8
          linalg.yield %9 : i8
        }
      }
      hls.dataflow.task {
        %collapse_shape = memref.collapse_shape %5 [[0], [1, 2, 3]] : memref<1x64x1x1xi8> into memref<1x64xi8>
        %6 = hls.dataflow.buffer {depth = 1 : i32} : memref<64x1000xi8>
        linalg.generic {indexing_maps = [#map9, #map10], iterator_types = ["parallel", "parallel"]} ins(%arg1 : memref<1000x64xi8>) outs(%6 : memref<64x1000xi8>) {
        ^bb0(%in: i8, %out: i8):
          linalg.yield %in : i8
        }
        %7 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x1000xi8>
        memref.copy %7, %0 : memref<1x1000xi8> to memref<1x1000xi8>
        linalg.generic {indexing_maps = [#map11, #map12, #map13], iterator_types = ["parallel", "parallel", "reduction"]} ins(%collapse_shape, %6 : memref<1x64xi8>, memref<64x1000xi8>) outs(%0 : memref<1x1000xi8>) {
        ^bb0(%in: i8, %in_0: i8, %out: i8):
          %8 = arith.muli %in, %in_0 : i8
          %9 = arith.addi %out, %8 : i8
          linalg.yield %9 : i8
        }
      }
    }
    memref.copy %0, %arg5 : memref<1x1000xi8> to memref<1x1000xi8>
    return
  }
}

// -----

// CHECK: module attributes {torch.debug_module_name = "ResNet"} {
// CHECK:   func.func @forward(%arg0: memref<1x64x56x56xi8>, %arg1: memref<1000x64xi8>, %arg2: memref<64x64x1x1xi8>, %arg3: memref<64x64x3x3xi8>, %arg4: memref<64x64x3x3xi8>, %arg5: memref<1x1000xi8>) attributes {top_func} {
// CHECK:     %c-24_i8 = arith.constant -24 : i8
// CHECK:     hls.dataflow.dispatch {
// CHECK:       hls.dataflow.task {
// CHECK:         affine.for %arg6 = 0 to 64 {
// CHECK:           affine.for %arg7 = 0 to 56 {
// CHECK:             affine.for %arg8 = 0 to 56 {
// CHECK:               %4 = affine.load %arg0[0, %arg6, %arg7, %arg8] : memref<1x64x56x56xi8>
// CHECK:               %5 = arith.cmpi ugt, %4, %c-24_i8 : i8
// CHECK:               %6 = arith.select %5, %4, %c-24_i8 : i8
// CHECK:               affine.store %6, %arg0[0, %arg6, %arg7, %arg8] : memref<1x64x56x56xi8>
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:       }
// CHECK:       %0 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
// CHECK:       hls.dataflow.task {
// CHECK:         affine.for %arg6 = 0 to 64 {
// CHECK:           affine.for %arg7 = 0 to 28 {
// CHECK:             affine.for %arg8 = 0 to 28 {
// CHECK:               affine.for %arg9 = 0 to 64 {
// CHECK:                 affine.for %arg10 = 0 to 3 {
// CHECK:                   affine.for %arg11 = 0 to 3 {
// CHECK:                     %7 = affine.load %arg0[0, %arg9, %arg7 * 2 + %arg10 - 1, %arg8 * 2 + %arg11 - 1] : memref<1x64x56x56xi8>
// CHECK:                     %8 = affine.load %arg4[%arg6, %arg9, %arg10, %arg11] : memref<64x64x3x3xi8>
// CHECK:                     %9 = affine.load %0[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
// CHECK:                     %10 = arith.muli %7, %8 : i8
// CHECK:                     %11 = arith.addi %9, %10 : i8
// CHECK:                     affine.store %11, %0[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
// CHECK:                   }
// CHECK:                 }
// CHECK:               }
// CHECK:               %4 = affine.load %0[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
// CHECK:               %5 = arith.cmpi ugt, %4, %c-24_i8 : i8
// CHECK:               %6 = arith.select %5, %4, %c-24_i8 : i8
// CHECK:               affine.store %6, %0[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:       }
// CHECK:       %1 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
// CHECK:       hls.dataflow.task {
// CHECK:         affine.for %arg6 = 0 to 64 {
// CHECK:           affine.for %arg7 = 0 to 28 {
// CHECK:             affine.for %arg8 = 0 to 28 {
// CHECK:               affine.for %arg9 = 0 to 64 {
// CHECK:                 affine.for %arg10 = 0 to 3 {
// CHECK:                   affine.for %arg11 = 0 to 3 {
// CHECK:                     %4 = affine.load %0[0, %arg9, %arg7 + %arg10 - 1, %arg8 + %arg11 - 1] : memref<1x64x28x28xi8>
// CHECK:                     %5 = affine.load %arg3[%arg6, %arg9, %arg10, %arg11] : memref<64x64x3x3xi8>
// CHECK:                     %6 = affine.load %1[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
// CHECK:                     %7 = arith.muli %4, %5 : i8
// CHECK:                     %8 = arith.addi %6, %7 : i8
// CHECK:                     affine.store %8, %1[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
// CHECK:                   }
// CHECK:                 }
// CHECK:               }
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:       }
// CHECK:       %2 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x28x28xi8>
// CHECK:       hls.dataflow.task {
// CHECK:         %4 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
// CHECK:         affine.for %arg6 = 0 to 64 {
// CHECK:           affine.for %arg7 = 0 to 28 {
// CHECK:             affine.for %arg8 = 0 to 28 {
// CHECK:               affine.for %arg9 = 0 to 64 {
// CHECK:                 %10 = affine.load %arg0[0, %arg9, %arg7 * 2, %arg8 * 2] : memref<1x64x56x56xi8>
// CHECK:                 %11 = affine.load %arg2[%arg6, %arg9, 0, 0] : memref<64x64x1x1xi8>
// CHECK:                 %12 = affine.load %4[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
// CHECK:                 %13 = arith.muli %10, %11 : i8
// CHECK:                 %14 = arith.addi %12, %13 : i8
// CHECK:                 affine.store %14, %4[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
// CHECK:               }
// CHECK:               %5 = affine.load %1[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
// CHECK:               %6 = affine.load %4[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
// CHECK:               %7 = arith.addi %5, %6 : i8
// CHECK:               %8 = arith.cmpi ugt, %7, %c-24_i8 : i8
// CHECK:               %9 = arith.select %8, %7, %c-24_i8 : i8
// CHECK:               affine.store %9, %2[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:       }
// CHECK:       %3 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x1x1xi8>
// CHECK:       hls.dataflow.task {
// CHECK:         affine.for %arg6 = 0 to 64 {
// CHECK:           affine.for %arg7 = 0 to 28 {
// CHECK:             affine.for %arg8 = 0 to 28 {
// CHECK:               %6 = affine.load %2[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
// CHECK:               %7 = affine.load %3[0, %arg6, 0, 0] : memref<1x64x1x1xi8>
// CHECK:               %8 = arith.addi %7, %6 : i8
// CHECK:               affine.store %8, %3[0, %arg6, 0, 0] : memref<1x64x1x1xi8>
// CHECK:             }
// CHECK:           }
// CHECK:           %4 = affine.load %3[0, %arg6, 0, 0] : memref<1x64x1x1xi8>
// CHECK:           %5 = arith.divui %4, %c-24_i8 : i8
// CHECK:           affine.store %5, %3[0, %arg6, 0, 0] : memref<1x64x1x1xi8>
// CHECK:         } {parallel}
// CHECK:       }
// CHECK:       hls.dataflow.task {
// CHECK:         affine.for %arg6 = 0 to 1000 {
// CHECK:           affine.store %c-24_i8, %arg5[0, %arg6] : memref<1x1000xi8>
// CHECK:           affine.for %arg7 = 0 to 64 {
// CHECK:             %4 = affine.load %3[0, %arg7, 0, 0] : memref<1x64x1x1xi8>
// CHECK:             %5 = affine.load %arg1[%arg6, %arg7] : memref<1000x64xi8>
// CHECK:             %6 = affine.load %arg5[0, %arg6] : memref<1x1000xi8>
// CHECK:             %7 = arith.muli %4, %5 : i8
// CHECK:             %8 = arith.addi %6, %7 : i8
// CHECK:             affine.store %8, %arg5[0, %arg6] : memref<1x1000xi8>
// CHECK:           }
// CHECK:         } {parallel}
// CHECK:       }
// CHECK:     }
// CHECK:     return
// CHECK:   }
// CHECK: }

module attributes {torch.debug_module_name = "ResNet"} {
  func.func @forward(%arg0: memref<1x64x56x56xi8>, %arg1: memref<1000x64xi8>, %arg2: memref<64x64x1x1xi8>, %arg3: memref<64x64x3x3xi8>, %arg4: memref<64x64x3x3xi8>, %arg5: memref<1x1000xi8>) attributes {top_func} {
    %c-24_i8 = arith.constant -24 : i8
    hls.dataflow.dispatch {
      hls.dataflow.task {
        affine.for %arg6 = 0 to 64 {
          affine.for %arg7 = 0 to 56 {
            affine.for %arg8 = 0 to 56 {
              %4 = affine.load %arg0[0, %arg6, %arg7, %arg8] : memref<1x64x56x56xi8>
              %5 = arith.cmpi ugt, %4, %c-24_i8 : i8
              %6 = arith.select %5, %4, %c-24_i8 : i8
              affine.store %6, %arg0[0, %arg6, %arg7, %arg8] : memref<1x64x56x56xi8>
            } {parallel}
          } {parallel}
        } {parallel}
      }
      %0 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
      hls.dataflow.task {
        %4 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x56x56xi8>
        affine.for %arg6 = 0 to 64 {
          memref.copy %arg0, %4 : memref<1x64x56x56xi8> to memref<1x64x56x56xi8>
          affine.for %arg7 = 0 to 28 {
            affine.for %arg8 = 0 to 28 {
              affine.for %arg9 = 0 to 64 {
                affine.for %arg10 = 0 to 3 {
                  affine.for %arg11 = 0 to 3 {
                    %8 = affine.load %4[0, %arg9, %arg7 * 2 + %arg10 - 1, %arg8 * 2 + %arg11 - 1] : memref<1x64x56x56xi8>
                    %9 = affine.load %arg4[%arg6, %arg9, %arg10, %arg11] : memref<64x64x3x3xi8>
                    %10 = affine.load %0[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
                    %11 = arith.muli %8, %9 : i8
                    %12 = arith.addi %10, %11 : i8
                    affine.store %12, %0[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
                  }
                }
              }
              %5 = affine.load %0[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
              %6 = arith.cmpi ugt, %5, %c-24_i8 : i8
              %7 = arith.select %6, %5, %c-24_i8 : i8
              affine.store %7, %0[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
            } {parallel}
          } {parallel}
        } {parallel}
      }
      %1 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
      hls.dataflow.task {
        %4 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
        affine.for %arg6 = 0 to 64 {
          affine.for %arg7 = 0 to 28 {
            affine.for %arg8 = 0 to 28 {
              memref.copy %0, %4 : memref<1x64x28x28xi8> to memref<1x64x28x28xi8>
              affine.for %arg9 = 0 to 64 {
                affine.for %arg10 = 0 to 3 {
                  affine.for %arg11 = 0 to 3 {
                    %5 = affine.load %4[0, %arg9, %arg7 + %arg10 - 1, %arg8 + %arg11 - 1] : memref<1x64x28x28xi8>
                    %6 = affine.load %arg3[%arg6, %arg9, %arg10, %arg11] : memref<64x64x3x3xi8>
                    %7 = affine.load %1[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
                    %8 = arith.muli %5, %6 : i8
                    %9 = arith.addi %7, %8 : i8
                    affine.store %9, %1[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
                  }
                }
              }
            } {parallel}
          } {parallel}
        } {parallel}
      }
      %2 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x28x28xi8>
      hls.dataflow.task {
        %4 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
        affine.for %arg6 = 0 to 64 {
          affine.for %arg7 = 0 to 28 {
            affine.for %arg8 = 0 to 28 {
              affine.for %arg9 = 0 to 64 {
                %10 = affine.load %arg0[0, %arg9, %arg7 * 2, %arg8 * 2] : memref<1x64x56x56xi8>
                %11 = affine.load %arg2[%arg6, %arg9, 0, 0] : memref<64x64x1x1xi8>
                %12 = affine.load %4[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
                %13 = arith.muli %10, %11 : i8
                %14 = arith.addi %12, %13 : i8
                affine.store %14, %4[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
              }
              %5 = affine.load %1[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
              %6 = affine.load %4[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
              %7 = arith.addi %5, %6 : i8
              %8 = arith.cmpi ugt, %7, %c-24_i8 : i8
              %9 = arith.select %8, %7, %c-24_i8 : i8
              affine.store %9, %2[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
            } {parallel}
          } {parallel}
        } {parallel}
      }
      %3 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x1x1xi8>
      hls.dataflow.task {
        affine.for %arg6 = 0 to 64 {
          affine.for %arg7 = 0 to 28 {
            affine.for %arg8 = 0 to 28 {
              %6 = affine.load %2[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
              %7 = affine.load %3[0, %arg6, 0, 0] : memref<1x64x1x1xi8>
              %8 = arith.addi %7, %6 : i8
              affine.store %8, %3[0, %arg6, 0, 0] : memref<1x64x1x1xi8>
            }
          }
          %4 = affine.load %3[0, %arg6, 0, 0] : memref<1x64x1x1xi8>
          %5 = arith.divui %4, %c-24_i8 : i8
          affine.store %5, %3[0, %arg6, 0, 0] : memref<1x64x1x1xi8>
        } {parallel}
      }
      hls.dataflow.task {
        affine.for %arg6 = 0 to 1000 {
          affine.store %c-24_i8, %arg5[0, %arg6] : memref<1x1000xi8>
          affine.for %arg7 = 0 to 64 {
            %4 = affine.load %3[0, %arg7, 0, 0] : memref<1x64x1x1xi8>
            %5 = affine.load %arg1[%arg6, %arg7] : memref<1000x64xi8>
            %6 = affine.load %arg5[0, %arg6] : memref<1x1000xi8>
            %7 = arith.muli %4, %5 : i8
            %8 = arith.addi %6, %7 : i8
            affine.store %8, %arg5[0, %arg6] : memref<1x1000xi8>
          }
        } {parallel}
      }
    }
    return
  }
}
