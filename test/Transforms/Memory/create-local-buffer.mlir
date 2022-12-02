// RUN: scalehls-opt -scalehls-create-local-buffer %s | FileCheck %s

// CHECK: #map = affine_map<(d0) -> (d0 * 16)>
// CHECK: #map1 = affine_map<(d0) -> (d0 * 14)>
// CHECK: #map2 = affine_map<(d0, d1) -> (d0 + d1 * 28 - 1)>
// CHECK: #map3 = affine_map<(d0, d1) -> (d0 + d1 * 14 - 1)>
// CHECK: #map4 = affine_map<(d0) -> (d0 * 28)>
// CHECK: #map5 = affine_map<(d0) -> (d0 * 10)>
// CHECK: #set = affine_set<(d0, d1, d2, d3) : (-d2 - d3 * 16 + 63 == 0, -d0 + 2 == 0, -d1 + 2 == 0)>
// CHECK: #set1 = affine_set<(d0, d1) : (-d0 - d1 * 16 + 63 == 0)>
// CHECK: #set2 = affine_set<(d0, d1, d2, d3) : (-d0 - d2 * 14 + 27 == 0, -d1 - d3 * 14 + 27 == 0)>
// CHECK: #set3 = affine_set<(d0, d1) : (d0 + d1 * 16 == 0)>
// CHECK: module attributes {torch.debug_module_name = "ResNet"} {
// CHECK:   func.func @forward(%arg0: memref<1x64x56x56xi8, 12>, %arg1: memref<1000x64xi8, 12>, %arg2: memref<64x64x1x1xi8, 12>, %arg3: memref<64x64x3x3xi8, 12>, %arg4: memref<64x64x3x3xi8, 12>, %arg5: memref<1x1000xi8, 12>) attributes {top_func} {
// CHECK:     %c-24_i8 = arith.constant -24 : i8
// CHECK:     hls.dataflow.dispatch {
// CHECK:       hls.dataflow.task {
// CHECK:         affine.for %arg6 = 0 to 4 {
// CHECK:           affine.for %arg7 = 0 to 4 {
// CHECK:             affine.for %arg8 = 0 to 4 {
// CHECK:               %5 = affine.apply #map(%arg6)
// CHECK:               %6 = affine.apply #map1(%arg7)
// CHECK:               %7 = affine.apply #map1(%arg8)
// CHECK:               %subview = memref.subview %arg0[0, %5, %6, %7] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x56x56xi8, 12> to memref<1x16x14x14xi8, strided<[200704, 3136, 56, 1], offset: ?>, 12>
// CHECK:               %8 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x16x14x14xi8, 7>
// CHECK:               memref.copy %subview, %8 : memref<1x16x14x14xi8, strided<[200704, 3136, 56, 1], offset: ?>, 12> to memref<1x16x14x14xi8, 7>
// CHECK:               affine.for %arg9 = 0 to 16 {
// CHECK:                 affine.for %arg10 = 0 to 14 {
// CHECK:                   affine.for %arg11 = 0 to 14 {
// CHECK:                     %9 = affine.load %8[0, %arg9, %arg10, %arg11] : memref<1x16x14x14xi8, 7>
// CHECK:                     %10 = arith.cmpi ugt, %9, %c-24_i8 : i8
// CHECK:                     %11 = arith.select %10, %9, %c-24_i8 : i8
// CHECK:                     affine.store %11, %8[0, %arg9, %arg10, %arg11] : memref<1x16x14x14xi8, 7>
// CHECK:                   } {parallel, point}
// CHECK:                 } {parallel, point}
// CHECK:               } {parallel, point}
// CHECK:               memref.copy %8, %subview : memref<1x16x14x14xi8, 7> to memref<1x16x14x14xi8, strided<[200704, 3136, 56, 1], offset: ?>, 12>
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:       }
// CHECK:       %0 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8, 12>
// CHECK:       hls.dataflow.task {
// CHECK:         affine.for %arg6 = 0 to 4 {
// CHECK:           affine.for %arg7 = 0 to 3 {
// CHECK:             affine.for %arg8 = 0 to 3 {
// CHECK:               affine.for %arg9 = 0 to 4 {
// CHECK:                 affine.for %arg10 = 0 to 2 {
// CHECK:                   affine.for %arg11 = 0 to 2 {
// CHECK:                     %5 = affine.apply #map(%arg6)
// CHECK:                     %6 = affine.apply #map2(%arg7, %arg10)
// CHECK:                     %7 = affine.apply #map2(%arg8, %arg11)
// CHECK:                     %subview = memref.subview %arg0[0, %5, %6, %7] [1, 16, 14, 14] [1, 1, 2, 2] : memref<1x64x56x56xi8, 12> to memref<1x16x14x14xi8, strided<[200704, 3136, 112, 2], offset: ?>, 12>
// CHECK:                     %8 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x16x14x14xi8, 7>
// CHECK:                     memref.copy %subview, %8 : memref<1x16x14x14xi8, strided<[200704, 3136, 112, 2], offset: ?>, 12> to memref<1x16x14x14xi8, 7>
// CHECK:                     %9 = affine.apply #map(%arg9)
// CHECK:                     %subview_0 = memref.subview %arg4[%9, %5, %arg7, %arg8] [16, 16, 1, 1] [1, 1, 1, 1] : memref<64x64x3x3xi8, 12> to memref<16x16x1x1xi8, strided<[576, 9, 3, 1], offset: ?>, 12>
// CHECK:                     %10 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16x1x1xi8, 7>
// CHECK:                     memref.copy %subview_0, %10 : memref<16x16x1x1xi8, strided<[576, 9, 3, 1], offset: ?>, 12> to memref<16x16x1x1xi8, 7>
// CHECK:                     %11 = affine.apply #map1(%arg10)
// CHECK:                     %12 = affine.apply #map1(%arg11)
// CHECK:                     %subview_1 = memref.subview %0[0, %9, %11, %12] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x28x28xi8, 12> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                     %13 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x16x14x14xi8, 7>
// CHECK:                     memref.copy %subview_1, %13 : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12> to memref<1x16x14x14xi8, 7>
// CHECK:                     affine.for %arg12 = 0 to 16 {
// CHECK:                       affine.for %arg13 = 0 to 16 {
// CHECK:                         affine.for %arg14 = 0 to 14 {
// CHECK:                           affine.for %arg15 = 0 to 14 {
// CHECK:                             %14 = affine.load %8[0, %arg12, %arg14, %arg15] : memref<1x16x14x14xi8, 7>
// CHECK:                             %15 = affine.load %10[%arg13, %arg12, 0, 0] : memref<16x16x1x1xi8, 7>
// CHECK:                             %16 = affine.load %13[0, %arg13, %arg14, %arg15] : memref<1x16x14x14xi8, 7>
// CHECK:                             %17 = arith.muli %14, %15 : i8
// CHECK:                             %18 = arith.addi %16, %17 : i8
// CHECK:                             affine.store %18, %13[0, %arg13, %arg14, %arg15] : memref<1x16x14x14xi8, 7>
// CHECK:                             %19 = affine.load %13[0, %arg13, %arg14, %arg15] : memref<1x16x14x14xi8, 7>
// CHECK:                             %20 = arith.cmpi ugt, %19, %c-24_i8 : i8
// CHECK:                             %21 = arith.select %20, %19, %c-24_i8 : i8
// CHECK:                             affine.if #set(%arg7, %arg8, %arg12, %arg6) {
// CHECK:                               affine.store %21, %13[0, %arg13, %arg14, %arg15] : memref<1x16x14x14xi8, 7>
// CHECK:                             }
// CHECK:                           } {parallel, point}
// CHECK:                         } {parallel, point}
// CHECK:                       } {parallel, point}
// CHECK:                     } {point}
// CHECK:                     memref.copy %13, %subview_1 : memref<1x16x14x14xi8, 7> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                   } {parallel}
// CHECK:                 } {parallel}
// CHECK:               } {parallel}
// CHECK:             }
// CHECK:           }
// CHECK:         }
// CHECK:       }
// CHECK:       %1 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8, 12>
// CHECK:       hls.dataflow.task {
// CHECK:         affine.for %arg6 = 0 to 4 {
// CHECK:           affine.for %arg7 = 0 to 3 {
// CHECK:             affine.for %arg8 = 0 to 3 {
// CHECK:               affine.for %arg9 = 0 to 4 {
// CHECK:                 affine.for %arg10 = 0 to 2 {
// CHECK:                   affine.for %arg11 = 0 to 2 {
// CHECK:                     %5 = affine.apply #map(%arg6)
// CHECK:                     %6 = affine.apply #map3(%arg7, %arg10)
// CHECK:                     %7 = affine.apply #map3(%arg8, %arg11)
// CHECK:                     %subview = memref.subview %0[0, %5, %6, %7] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x28x28xi8, 12> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                     %8 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x16x14x14xi8, 7>
// CHECK:                     memref.copy %subview, %8 : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12> to memref<1x16x14x14xi8, 7>
// CHECK:                     %9 = affine.apply #map(%arg9)
// CHECK:                     %subview_0 = memref.subview %arg3[%9, %5, %arg7, %arg8] [16, 16, 1, 1] [1, 1, 1, 1] : memref<64x64x3x3xi8, 12> to memref<16x16x1x1xi8, strided<[576, 9, 3, 1], offset: ?>, 12>
// CHECK:                     %10 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16x1x1xi8, 7>
// CHECK:                     memref.copy %subview_0, %10 : memref<16x16x1x1xi8, strided<[576, 9, 3, 1], offset: ?>, 12> to memref<16x16x1x1xi8, 7>
// CHECK:                     %11 = affine.apply #map1(%arg10)
// CHECK:                     %12 = affine.apply #map1(%arg11)
// CHECK:                     %subview_1 = memref.subview %1[0, %9, %11, %12] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x28x28xi8, 12> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                     %13 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x16x14x14xi8, 7>
// CHECK:                     memref.copy %subview_1, %13 : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12> to memref<1x16x14x14xi8, 7>
// CHECK:                     affine.for %arg12 = 0 to 16 {
// CHECK:                       affine.for %arg13 = 0 to 16 {
// CHECK:                         affine.for %arg14 = 0 to 14 {
// CHECK:                           affine.for %arg15 = 0 to 14 {
// CHECK:                             %14 = affine.load %8[0, %arg12, %arg14, %arg15] : memref<1x16x14x14xi8, 7>
// CHECK:                             %15 = affine.load %10[%arg13, %arg12, 0, 0] : memref<16x16x1x1xi8, 7>
// CHECK:                             %16 = affine.load %13[0, %arg13, %arg14, %arg15] : memref<1x16x14x14xi8, 7>
// CHECK:                             %17 = arith.muli %14, %15 : i8
// CHECK:                             %18 = arith.addi %16, %17 : i8
// CHECK:                             affine.store %18, %13[0, %arg13, %arg14, %arg15] : memref<1x16x14x14xi8, 7>
// CHECK:                           } {parallel, point}
// CHECK:                         } {parallel, point}
// CHECK:                       } {parallel, point}
// CHECK:                     } {point}
// CHECK:                     memref.copy %13, %subview_1 : memref<1x16x14x14xi8, 7> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                   } {parallel}
// CHECK:                 } {parallel}
// CHECK:               } {parallel}
// CHECK:             }
// CHECK:           }
// CHECK:         }
// CHECK:       }
// CHECK:       %2 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x28x28xi8, 12>
// CHECK:       %3 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8, 12>
// CHECK:       hls.dataflow.task {
// CHECK:         affine.for %arg6 = 0 to 4 {
// CHECK:           affine.for %arg7 = 0 to 4 {
// CHECK:             affine.for %arg8 = 0 to 2 {
// CHECK:               affine.for %arg9 = 0 to 2 {
// CHECK:                 %5 = affine.apply #map(%arg6)
// CHECK:                 %6 = affine.apply #map4(%arg8)
// CHECK:                 %7 = affine.apply #map4(%arg9)
// CHECK:                 %subview = memref.subview %arg0[0, %5, %6, %7] [1, 16, 14, 14] [1, 1, 2, 2] : memref<1x64x56x56xi8, 12> to memref<1x16x14x14xi8, strided<[200704, 3136, 112, 2], offset: ?>, 12>
// CHECK:                 %8 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x16x14x14xi8, 7>
// CHECK:                 memref.copy %subview, %8 : memref<1x16x14x14xi8, strided<[200704, 3136, 112, 2], offset: ?>, 12> to memref<1x16x14x14xi8, 7>
// CHECK:                 %9 = affine.apply #map(%arg7)
// CHECK:                 %subview_0 = memref.subview %arg2[%9, %5, 0, 0] [16, 16, 1, 1] [1, 1, 1, 1] : memref<64x64x1x1xi8, 12> to memref<16x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 12>
// CHECK:                 %10 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16x1x1xi8, 7>
// CHECK:                 memref.copy %subview_0, %10 : memref<16x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 12> to memref<16x16x1x1xi8, 7>
// CHECK:                 %11 = affine.apply #map1(%arg8)
// CHECK:                 %12 = affine.apply #map1(%arg9)
// CHECK:                 %subview_1 = memref.subview %3[0, %9, %11, %12] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x28x28xi8, 12> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                 %13 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x16x14x14xi8, 7>
// CHECK:                 memref.copy %subview_1, %13 : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12> to memref<1x16x14x14xi8, 7>
// CHECK:                 %subview_2 = memref.subview %1[0, %9, %11, %12] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x28x28xi8, 12> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                 %14 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x16x14x14xi8, 7>
// CHECK:                 memref.copy %subview_2, %14 : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12> to memref<1x16x14x14xi8, 7>
// CHECK:                 %subview_3 = memref.subview %2[0, %9, %11, %12] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x28x28xi8, 12> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                 %15 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x16x14x14xi8, 7>
// CHECK:                 affine.for %arg10 = 0 to 16 {
// CHECK:                   affine.for %arg11 = 0 to 16 {
// CHECK:                     affine.for %arg12 = 0 to 14 {
// CHECK:                       affine.for %arg13 = 0 to 14 {
// CHECK:                         %16 = affine.load %8[0, %arg10, %arg12, %arg13] : memref<1x16x14x14xi8, 7>
// CHECK:                         %17 = affine.load %10[%arg11, %arg10, 0, 0] : memref<16x16x1x1xi8, 7>
// CHECK:                         %18 = affine.load %13[0, %arg11, %arg12, %arg13] : memref<1x16x14x14xi8, 7>
// CHECK:                         %19 = arith.muli %16, %17 : i8
// CHECK:                         %20 = arith.addi %18, %19 : i8
// CHECK:                         affine.store %20, %13[0, %arg11, %arg12, %arg13] : memref<1x16x14x14xi8, 7>
// CHECK:                         %21 = affine.load %14[0, %arg11, %arg12, %arg13] : memref<1x16x14x14xi8, 7>
// CHECK:                         %22 = affine.load %13[0, %arg11, %arg12, %arg13] : memref<1x16x14x14xi8, 7>
// CHECK:                         %23 = arith.addi %21, %22 : i8
// CHECK:                         %24 = arith.cmpi ugt, %23, %c-24_i8 : i8
// CHECK:                         %25 = arith.select %24, %23, %c-24_i8 : i8
// CHECK:                         affine.if #set1(%arg10, %arg6) {
// CHECK:                           affine.store %25, %15[0, %arg11, %arg12, %arg13] : memref<1x16x14x14xi8, 7>
// CHECK:                         }
// CHECK:                       } {parallel, point}
// CHECK:                     } {parallel, point}
// CHECK:                   } {parallel, point}
// CHECK:                 } {point}
// CHECK:                 memref.copy %13, %subview_1 : memref<1x16x14x14xi8, 7> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                 memref.copy %15, %subview_3 : memref<1x16x14x14xi8, 7> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:               } {parallel}
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         }
// CHECK:       }
// CHECK:       %4 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x1x1xi8, 7>
// CHECK:       hls.dataflow.task {
// CHECK:         affine.for %arg6 = 0 to 2 {
// CHECK:           affine.for %arg7 = 0 to 2 {
// CHECK:             affine.for %arg8 = 0 to 4 {
// CHECK:               %5 = affine.apply #map(%arg8)
// CHECK:               %6 = affine.apply #map1(%arg6)
// CHECK:               %7 = affine.apply #map1(%arg7)
// CHECK:               %subview = memref.subview %2[0, %5, %6, %7] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x28x28xi8, 12> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:               %8 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x16x14x14xi8, 7>
// CHECK:               memref.copy %subview, %8 : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12> to memref<1x16x14x14xi8, 7>
// CHECK:               %subview_0 = memref.subview %4[0, %5, 0, 0] [1, 16, 1, 1] [1, 1, 1, 1] : memref<1x64x1x1xi8, 7> to memref<1x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 7>
// CHECK:               affine.for %arg9 = 0 to 14 {
// CHECK:                 affine.for %arg10 = 0 to 14 {
// CHECK:                   affine.for %arg11 = 0 to 16 {
// CHECK:                     %9 = affine.load %8[0, %arg11, %arg9, %arg10] : memref<1x16x14x14xi8, 7>
// CHECK:                     %10 = affine.load %subview_0[0, %arg11, 0, 0] : memref<1x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 7>
// CHECK:                     %11 = arith.addi %10, %9 : i8
// CHECK:                     affine.store %11, %subview_0[0, %arg11, 0, 0] : memref<1x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 7>
// CHECK:                     %12 = affine.load %subview_0[0, %arg11, 0, 0] : memref<1x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 7>
// CHECK:                     %13 = arith.divui %12, %c-24_i8 : i8
// CHECK:                     affine.if #set2(%arg9, %arg10, %arg6, %arg7) {
// CHECK:                       affine.store %13, %subview_0[0, %arg11, 0, 0] : memref<1x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 7>
// CHECK:                     }
// CHECK:                   } {parallel, point}
// CHECK:                 } {point}
// CHECK:               } {point}
// CHECK:             } {parallel}
// CHECK:           }
// CHECK:         }
// CHECK:       }
// CHECK:       hls.dataflow.task {
// CHECK:         affine.for %arg6 = 0 to 4 {
// CHECK:           affine.for %arg7 = 0 to 100 {
// CHECK:             %5 = affine.apply #map5(%arg7)
// CHECK:             %subview = memref.subview %arg5[0, %5] [1, 10] [1, 1] : memref<1x1000xi8, 12> to memref<1x10xi8, strided<[1000, 1], offset: ?>, 12>
// CHECK:             %6 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x10xi8, 7>
// CHECK:             memref.copy %subview, %6 : memref<1x10xi8, strided<[1000, 1], offset: ?>, 12> to memref<1x10xi8, 7>
// CHECK:             %7 = affine.apply #map(%arg6)
// CHECK:             %subview_0 = memref.subview %4[0, %7, 0, 0] [1, 16, 1, 1] [1, 1, 1, 1] : memref<1x64x1x1xi8, 7> to memref<1x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 7>
// CHECK:             %subview_1 = memref.subview %arg1[%5, %7] [10, 16] [1, 1] : memref<1000x64xi8, 12> to memref<10x16xi8, strided<[64, 1], offset: ?>, 12>
// CHECK:             %8 = hls.dataflow.buffer {depth = 1 : i32} : memref<10x16xi8, 7>
// CHECK:             memref.copy %subview_1, %8 : memref<10x16xi8, strided<[64, 1], offset: ?>, 12> to memref<10x16xi8, 7>
// CHECK:             affine.for %arg8 = 0 to 16 {
// CHECK:               affine.for %arg9 = 0 to 10 {
// CHECK:                 affine.if #set3(%arg8, %arg6) {
// CHECK:                   affine.store %c-24_i8, %6[0, %arg9] : memref<1x10xi8, 7>
// CHECK:                 }
// CHECK:                 %9 = affine.load %subview_0[0, %arg8, 0, 0] : memref<1x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 7>
// CHECK:                 %10 = affine.load %8[%arg9, %arg8] : memref<10x16xi8, 7>
// CHECK:                 %11 = affine.load %6[0, %arg9] : memref<1x10xi8, 7>
// CHECK:                 %12 = arith.muli %9, %10 : i8
// CHECK:                 %13 = arith.addi %11, %12 : i8
// CHECK:                 affine.store %13, %6[0, %arg9] : memref<1x10xi8, 7>
// CHECK:               } {parallel, point}
// CHECK:             } {point}
// CHECK:             memref.copy %6, %subview : memref<1x10xi8, 7> to memref<1x10xi8, strided<[1000, 1], offset: ?>, 12>
// CHECK:           } {parallel}
// CHECK:         }
// CHECK:       }
// CHECK:     }
// CHECK:     return
// CHECK:   }
// CHECK: }

#map = affine_map<(d0) -> (d0 * 16)>
#map1 = affine_map<(d0) -> (d0 * 14)>
#map2 = affine_map<(d0, d1) -> (d0 + d1 * 28 - 1)>
#map3 = affine_map<(d0, d1) -> (d0 + d1 * 14 - 1)>
#map4 = affine_map<(d0) -> (d0 * 28)>
#map5 = affine_map<(d0) -> (d0 * 10)>
#set = affine_set<(d0, d1, d2, d3) : (-d2 - d3 * 16 + 63 == 0, -d0 + 2 == 0, -d1 + 2 == 0)>
#set1 = affine_set<(d0, d1) : (-d0 - d1 * 16 + 63 == 0)>
#set2 = affine_set<(d0, d1, d2, d3) : (-d0 - d2 * 14 + 27 == 0, -d1 - d3 * 14 + 27 == 0)>
#set3 = affine_set<(d0, d1) : (d0 + d1 * 16 == 0)>
module attributes {torch.debug_module_name = "ResNet"} {
  func.func @forward(%arg0: memref<1x64x56x56xi8, 12>, %arg1: memref<1000x64xi8, 12>, %arg2: memref<64x64x1x1xi8, 12>, %arg3: memref<64x64x3x3xi8, 12>, %arg4: memref<64x64x3x3xi8, 12>, %arg5: memref<1x1000xi8, 12>) attributes {top_func} {
    %c-24_i8 = arith.constant -24 : i8
    hls.dataflow.dispatch {
      hls.dataflow.task {
        affine.for %arg6 = 0 to 4 {
          affine.for %arg7 = 0 to 4 {
            affine.for %arg8 = 0 to 4 {
              %5 = affine.apply #map(%arg6)
              %6 = affine.apply #map1(%arg7)
              %7 = affine.apply #map1(%arg8)
              %subview = memref.subview %arg0[0, %5, %6, %7] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x56x56xi8, 12> to memref<1x16x14x14xi8, strided<[200704, 3136, 56, 1], offset: ?>, 12>
              affine.for %arg9 = 0 to 16 {
                affine.for %arg10 = 0 to 14 {
                  affine.for %arg11 = 0 to 14 {
                    %8 = affine.load %subview[0, %arg9, %arg10, %arg11] : memref<1x16x14x14xi8, strided<[200704, 3136, 56, 1], offset: ?>, 12>
                    %9 = arith.cmpi ugt, %8, %c-24_i8 : i8
                    %10 = arith.select %9, %8, %c-24_i8 : i8
                    affine.store %10, %subview[0, %arg9, %arg10, %arg11] : memref<1x16x14x14xi8, strided<[200704, 3136, 56, 1], offset: ?>, 12>
                  } {parallel, point}
                } {parallel, point}
              } {parallel, point}
            } {parallel}
          } {parallel}
        } {parallel}
      }
      %0 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8, 12>
      hls.dataflow.task {
        affine.for %arg6 = 0 to 4 {
          affine.for %arg7 = 0 to 3 {
            affine.for %arg8 = 0 to 3 {
              affine.for %arg9 = 0 to 4 {
                affine.for %arg10 = 0 to 2 {
                  affine.for %arg11 = 0 to 2 {
                    %5 = affine.apply #map(%arg6)
                    %6 = affine.apply #map2(%arg7, %arg10)
                    %7 = affine.apply #map2(%arg8, %arg11)
                    %subview = memref.subview %arg0[0, %5, %6, %7] [1, 16, 14, 14] [1, 1, 2, 2] : memref<1x64x56x56xi8, 12> to memref<1x16x14x14xi8, strided<[200704, 3136, 112, 2], offset: ?>, 12>
                    %8 = affine.apply #map(%arg9)
                    %subview_0 = memref.subview %arg4[%8, %5, %arg7, %arg8] [16, 16, 1, 1] [1, 1, 1, 1] : memref<64x64x3x3xi8, 12> to memref<16x16x1x1xi8, strided<[576, 9, 3, 1], offset: ?>, 12>
                    %9 = affine.apply #map1(%arg10)
                    %10 = affine.apply #map1(%arg11)
                    %subview_1 = memref.subview %0[0, %8, %9, %10] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x28x28xi8, 12> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
                    affine.for %arg12 = 0 to 16 {
                      affine.for %arg13 = 0 to 16 {
                        affine.for %arg14 = 0 to 14 {
                          affine.for %arg15 = 0 to 14 {
                            %11 = affine.load %subview[0, %arg12, %arg14, %arg15] : memref<1x16x14x14xi8, strided<[200704, 3136, 112, 2], offset: ?>, 12>
                            %12 = affine.load %subview_0[%arg13, %arg12, 0, 0] : memref<16x16x1x1xi8, strided<[576, 9, 3, 1], offset: ?>, 12>
                            %13 = affine.load %subview_1[0, %arg13, %arg14, %arg15] : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
                            %14 = arith.muli %11, %12 : i8
                            %15 = arith.addi %13, %14 : i8
                            affine.store %15, %subview_1[0, %arg13, %arg14, %arg15] : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
                            %16 = affine.load %subview_1[0, %arg13, %arg14, %arg15] : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
                            %17 = arith.cmpi ugt, %16, %c-24_i8 : i8
                            %18 = arith.select %17, %16, %c-24_i8 : i8
                            affine.if #set(%arg7, %arg8, %arg12, %arg6) {
                              affine.store %18, %subview_1[0, %arg13, %arg14, %arg15] : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
                            }
                          } {parallel, point}
                        } {parallel, point}
                      } {parallel, point}
                    } {point}
                  } {parallel}
                } {parallel}
              } {parallel}
            }
          }
        }
      }
      %1 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8, 12>
      hls.dataflow.task {
        affine.for %arg6 = 0 to 4 {
          affine.for %arg7 = 0 to 3 {
            affine.for %arg8 = 0 to 3 {
              affine.for %arg9 = 0 to 4 {
                affine.for %arg10 = 0 to 2 {
                  affine.for %arg11 = 0 to 2 {
                    %5 = affine.apply #map(%arg6)
                    %6 = affine.apply #map3(%arg7, %arg10)
                    %7 = affine.apply #map3(%arg8, %arg11)
                    %subview = memref.subview %0[0, %5, %6, %7] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x28x28xi8, 12> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
                    %8 = affine.apply #map(%arg9)
                    %subview_0 = memref.subview %arg3[%8, %5, %arg7, %arg8] [16, 16, 1, 1] [1, 1, 1, 1] : memref<64x64x3x3xi8, 12> to memref<16x16x1x1xi8, strided<[576, 9, 3, 1], offset: ?>, 12>
                    %9 = affine.apply #map1(%arg10)
                    %10 = affine.apply #map1(%arg11)
                    %subview_1 = memref.subview %1[0, %8, %9, %10] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x28x28xi8, 12> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
                    affine.for %arg12 = 0 to 16 {
                      affine.for %arg13 = 0 to 16 {
                        affine.for %arg14 = 0 to 14 {
                          affine.for %arg15 = 0 to 14 {
                            %11 = affine.load %subview[0, %arg12, %arg14, %arg15] : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
                            %12 = affine.load %subview_0[%arg13, %arg12, 0, 0] : memref<16x16x1x1xi8, strided<[576, 9, 3, 1], offset: ?>, 12>
                            %13 = affine.load %subview_1[0, %arg13, %arg14, %arg15] : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
                            %14 = arith.muli %11, %12 : i8
                            %15 = arith.addi %13, %14 : i8
                            affine.store %15, %subview_1[0, %arg13, %arg14, %arg15] : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
                          } {parallel, point}
                        } {parallel, point}
                      } {parallel, point}
                    } {point}
                  } {parallel}
                } {parallel}
              } {parallel}
            }
          }
        }
      }
      %2 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x28x28xi8, 12>
      %3 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8, 12>
      hls.dataflow.task {
        affine.for %arg6 = 0 to 4 {
          affine.for %arg7 = 0 to 4 {
            affine.for %arg8 = 0 to 2 {
              affine.for %arg9 = 0 to 2 {
                %5 = affine.apply #map(%arg6)
                %6 = affine.apply #map4(%arg8)
                %7 = affine.apply #map4(%arg9)
                %subview = memref.subview %arg0[0, %5, %6, %7] [1, 16, 14, 14] [1, 1, 2, 2] : memref<1x64x56x56xi8, 12> to memref<1x16x14x14xi8, strided<[200704, 3136, 112, 2], offset: ?>, 12>
                %8 = affine.apply #map(%arg7)
                %subview_0 = memref.subview %arg2[%8, %5, 0, 0] [16, 16, 1, 1] [1, 1, 1, 1] : memref<64x64x1x1xi8, 12> to memref<16x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 12>
                %9 = affine.apply #map1(%arg8)
                %10 = affine.apply #map1(%arg9)
                %subview_1 = memref.subview %3[0, %8, %9, %10] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x28x28xi8, 12> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
                %subview_2 = memref.subview %1[0, %8, %9, %10] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x28x28xi8, 12> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
                %subview_3 = memref.subview %2[0, %8, %9, %10] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x28x28xi8, 12> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
                affine.for %arg10 = 0 to 16 {
                  affine.for %arg11 = 0 to 16 {
                    affine.for %arg12 = 0 to 14 {
                      affine.for %arg13 = 0 to 14 {
                        %11 = affine.load %subview[0, %arg10, %arg12, %arg13] : memref<1x16x14x14xi8, strided<[200704, 3136, 112, 2], offset: ?>, 12>
                        %12 = affine.load %subview_0[%arg11, %arg10, 0, 0] : memref<16x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 12>
                        %13 = affine.load %subview_1[0, %arg11, %arg12, %arg13] : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
                        %14 = arith.muli %11, %12 : i8
                        %15 = arith.addi %13, %14 : i8
                        affine.store %15, %subview_1[0, %arg11, %arg12, %arg13] : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
                        %16 = affine.load %subview_2[0, %arg11, %arg12, %arg13] : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
                        %17 = affine.load %subview_1[0, %arg11, %arg12, %arg13] : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
                        %18 = arith.addi %16, %17 : i8
                        %19 = arith.cmpi ugt, %18, %c-24_i8 : i8
                        %20 = arith.select %19, %18, %c-24_i8 : i8
                        affine.if #set1(%arg10, %arg6) {
                          affine.store %20, %subview_3[0, %arg11, %arg12, %arg13] : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
                        }
                      } {parallel, point}
                    } {parallel, point}
                  } {parallel, point}
                } {point}
              } {parallel}
            } {parallel}
          } {parallel}
        }
      }
      %4 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x1x1xi8, 7>
      hls.dataflow.task {
        affine.for %arg6 = 0 to 2 {
          affine.for %arg7 = 0 to 2 {
            affine.for %arg8 = 0 to 4 {
              %5 = affine.apply #map(%arg8)
              %6 = affine.apply #map1(%arg6)
              %7 = affine.apply #map1(%arg7)
              %subview = memref.subview %2[0, %5, %6, %7] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x28x28xi8, 12> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
              %subview_0 = memref.subview %4[0, %5, 0, 0] [1, 16, 1, 1] [1, 1, 1, 1] : memref<1x64x1x1xi8, 7> to memref<1x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 7>
              affine.for %arg9 = 0 to 14 {
                affine.for %arg10 = 0 to 14 {
                  affine.for %arg11 = 0 to 16 {
                    %8 = affine.load %subview[0, %arg11, %arg9, %arg10] : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
                    %9 = affine.load %subview_0[0, %arg11, 0, 0] : memref<1x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 7>
                    %10 = arith.addi %9, %8 : i8
                    affine.store %10, %subview_0[0, %arg11, 0, 0] : memref<1x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 7>
                    %11 = affine.load %subview_0[0, %arg11, 0, 0] : memref<1x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 7>
                    %12 = arith.divui %11, %c-24_i8 : i8
                    affine.if #set2(%arg9, %arg10, %arg6, %arg7) {
                      affine.store %12, %subview_0[0, %arg11, 0, 0] : memref<1x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 7>
                    }
                  } {parallel, point}
                } {point}
              } {point}
            } {parallel}
          }
        }
      }
      hls.dataflow.task {
        affine.for %arg6 = 0 to 4 {
          affine.for %arg7 = 0 to 100 {
            %5 = affine.apply #map5(%arg7)
            %subview = memref.subview %arg5[0, %5] [1, 10] [1, 1] : memref<1x1000xi8, 12> to memref<1x10xi8, strided<[1000, 1], offset: ?>, 12>
            %6 = affine.apply #map(%arg6)
            %subview_0 = memref.subview %4[0, %6, 0, 0] [1, 16, 1, 1] [1, 1, 1, 1] : memref<1x64x1x1xi8, 7> to memref<1x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 7>
            %subview_1 = memref.subview %arg1[%5, %6] [10, 16] [1, 1] : memref<1000x64xi8, 12> to memref<10x16xi8, strided<[64, 1], offset: ?>, 12>
            affine.for %arg8 = 0 to 16 {
              affine.for %arg9 = 0 to 10 {
                affine.if #set3(%arg8, %arg6) {
                  affine.store %c-24_i8, %subview[0, %arg9] : memref<1x10xi8, strided<[1000, 1], offset: ?>, 12>
                }
                %7 = affine.load %subview_0[0, %arg8, 0, 0] : memref<1x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 7>
                %8 = affine.load %subview_1[%arg9, %arg8] : memref<10x16xi8, strided<[64, 1], offset: ?>, 12>
                %9 = affine.load %subview[0, %arg9] : memref<1x10xi8, strided<[1000, 1], offset: ?>, 12>
                %10 = arith.muli %7, %8 : i8
                %11 = arith.addi %9, %10 : i8
                affine.store %11, %subview[0, %arg9] : memref<1x10xi8, strided<[1000, 1], offset: ?>, 12>
              } {parallel, point}
            } {point}
          } {parallel}
        }
      }
    }
    return
  }
}

