// RUN: scalehls-opt -scalehls-create-memref-subview %s | FileCheck %s

// CHECK: #map = affine_map<() -> (0)>
// CHECK: #map1 = affine_map<(d0) -> (d0 * 16)>
// CHECK: #map2 = affine_map<(d0) -> (d0 * 14)>
// CHECK: #map3 = affine_map<(d0, d1) -> (d0 + d1 * 28 - 1)>
// CHECK: #map4 = affine_map<(d0) -> (d0)>
// CHECK: #map5 = affine_map<(d0, d1) -> (d0 + d1 * 14 - 1)>
// CHECK: #map6 = affine_map<(d0) -> (d0 * 28)>
// CHECK: #map7 = affine_map<(d0) -> (d0 * 10)>
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
// CHECK:               %5 = affine.apply #map()
// CHECK:               %6 = affine.apply #map1(%arg6)
// CHECK:               %7 = affine.apply #map2(%arg7)
// CHECK:               %8 = affine.apply #map2(%arg8)
// CHECK:               %subview = memref.subview %arg0[%5, %6, %7, %8] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x56x56xi8, 12> to memref<1x16x14x14xi8, strided<[200704, 3136, 56, 1], offset: ?>, 12>
// CHECK:               %9 = affine.apply #map()
// CHECK:               %10 = affine.apply #map1(%arg6)
// CHECK:               %11 = affine.apply #map2(%arg7)
// CHECK:               %12 = affine.apply #map2(%arg8)
// CHECK:               %subview_0 = memref.subview %arg0[%9, %10, %11, %12] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x56x56xi8, 12> to memref<1x16x14x14xi8, strided<[200704, 3136, 56, 1], offset: ?>, 12>
// CHECK:               affine.for %arg9 = 0 to 16 {
// CHECK:                 affine.for %arg10 = 0 to 14 {
// CHECK:                   affine.for %arg11 = 0 to 14 {
// CHECK:                     %13 = affine.load %subview[0, %arg9, %arg10, %arg11] : memref<1x16x14x14xi8, strided<[200704, 3136, 56, 1], offset: ?>, 12>
// CHECK:                     %14 = arith.cmpi ugt, %13, %c-24_i8 : i8
// CHECK:                     %15 = arith.select %14, %13, %c-24_i8 : i8
// CHECK:                     affine.store %15, %subview_0[0, %arg9, %arg10, %arg11] : memref<1x16x14x14xi8, strided<[200704, 3136, 56, 1], offset: ?>, 12>
// CHECK:                   } {parallel, point}
// CHECK:                 } {parallel, point}
// CHECK:               } {parallel, point}
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
// CHECK:                     %5 = affine.apply #map()
// CHECK:                     %6 = affine.apply #map1(%arg6)
// CHECK:                     %7 = affine.apply #map3(%arg7, %arg10)
// CHECK:                     %8 = affine.apply #map3(%arg8, %arg11)
// CHECK:                     %subview = memref.subview %arg0[%5, %6, %7, %8] [1, 16, 14, 14] [1, 1, 2, 2] : memref<1x64x56x56xi8, 12> to memref<1x16x14x14xi8, strided<[200704, 3136, 112, 2], offset: ?>, 12>
// CHECK:                     %9 = affine.apply #map1(%arg9)
// CHECK:                     %10 = affine.apply #map1(%arg6)
// CHECK:                     %11 = affine.apply #map4(%arg7)
// CHECK:                     %12 = affine.apply #map4(%arg8)
// CHECK:                     %subview_0 = memref.subview %arg4[%9, %10, %11, %12] [16, 16, 1, 1] [1, 1, 1, 1] : memref<64x64x3x3xi8, 12> to memref<16x16x1x1xi8, strided<[576, 9, 3, 1], offset: ?>, 12>
// CHECK:                     %13 = affine.apply #map()
// CHECK:                     %14 = affine.apply #map1(%arg9)
// CHECK:                     %15 = affine.apply #map2(%arg10)
// CHECK:                     %16 = affine.apply #map2(%arg11)
// CHECK:                     %subview_1 = memref.subview %0[%13, %14, %15, %16] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x28x28xi8, 12> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                     %17 = affine.apply #map()
// CHECK:                     %18 = affine.apply #map1(%arg9)
// CHECK:                     %19 = affine.apply #map2(%arg10)
// CHECK:                     %20 = affine.apply #map2(%arg11)
// CHECK:                     %subview_2 = memref.subview %0[%17, %18, %19, %20] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x28x28xi8, 12> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                     %21 = affine.apply #map()
// CHECK:                     %22 = affine.apply #map1(%arg9)
// CHECK:                     %23 = affine.apply #map2(%arg10)
// CHECK:                     %24 = affine.apply #map2(%arg11)
// CHECK:                     %subview_3 = memref.subview %0[%21, %22, %23, %24] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x28x28xi8, 12> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                     %25 = affine.apply #map()
// CHECK:                     %26 = affine.apply #map1(%arg9)
// CHECK:                     %27 = affine.apply #map2(%arg10)
// CHECK:                     %28 = affine.apply #map2(%arg11)
// CHECK:                     %subview_4 = memref.subview %0[%25, %26, %27, %28] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x28x28xi8, 12> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                     affine.for %arg12 = 0 to 16 {
// CHECK:                       affine.for %arg13 = 0 to 16 {
// CHECK:                         affine.for %arg14 = 0 to 14 {
// CHECK:                           affine.for %arg15 = 0 to 14 {
// CHECK:                             %29 = affine.load %subview[0, %arg12, %arg14, %arg15] : memref<1x16x14x14xi8, strided<[200704, 3136, 112, 2], offset: ?>, 12>
// CHECK:                             %30 = affine.load %subview_0[%arg13, %arg12, 0, 0] : memref<16x16x1x1xi8, strided<[576, 9, 3, 1], offset: ?>, 12>
// CHECK:                             %31 = affine.load %subview_1[0, %arg13, %arg14, %arg15] : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                             %32 = arith.muli %29, %30 : i8
// CHECK:                             %33 = arith.addi %31, %32 : i8
// CHECK:                             affine.store %33, %subview_2[0, %arg13, %arg14, %arg15] : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                             %34 = affine.load %subview_3[0, %arg13, %arg14, %arg15] : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                             %35 = arith.cmpi ugt, %34, %c-24_i8 : i8
// CHECK:                             %36 = arith.select %35, %34, %c-24_i8 : i8
// CHECK:                             affine.if #set(%arg7, %arg8, %arg12, %arg6) {
// CHECK:                               affine.store %36, %subview_4[0, %arg13, %arg14, %arg15] : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                             }
// CHECK:                           } {parallel, point}
// CHECK:                         } {parallel, point}
// CHECK:                       } {parallel, point}
// CHECK:                     } {point}
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
// CHECK:                     %5 = affine.apply #map()
// CHECK:                     %6 = affine.apply #map1(%arg6)
// CHECK:                     %7 = affine.apply #map5(%arg7, %arg10)
// CHECK:                     %8 = affine.apply #map5(%arg8, %arg11)
// CHECK:                     %subview = memref.subview %0[%5, %6, %7, %8] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x28x28xi8, 12> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                     %9 = affine.apply #map1(%arg9)
// CHECK:                     %10 = affine.apply #map1(%arg6)
// CHECK:                     %11 = affine.apply #map4(%arg7)
// CHECK:                     %12 = affine.apply #map4(%arg8)
// CHECK:                     %subview_0 = memref.subview %arg3[%9, %10, %11, %12] [16, 16, 1, 1] [1, 1, 1, 1] : memref<64x64x3x3xi8, 12> to memref<16x16x1x1xi8, strided<[576, 9, 3, 1], offset: ?>, 12>
// CHECK:                     %13 = affine.apply #map()
// CHECK:                     %14 = affine.apply #map1(%arg9)
// CHECK:                     %15 = affine.apply #map2(%arg10)
// CHECK:                     %16 = affine.apply #map2(%arg11)
// CHECK:                     %subview_1 = memref.subview %1[%13, %14, %15, %16] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x28x28xi8, 12> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                     %17 = affine.apply #map()
// CHECK:                     %18 = affine.apply #map1(%arg9)
// CHECK:                     %19 = affine.apply #map2(%arg10)
// CHECK:                     %20 = affine.apply #map2(%arg11)
// CHECK:                     %subview_2 = memref.subview %1[%17, %18, %19, %20] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x28x28xi8, 12> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                     affine.for %arg12 = 0 to 16 {
// CHECK:                       affine.for %arg13 = 0 to 16 {
// CHECK:                         affine.for %arg14 = 0 to 14 {
// CHECK:                           affine.for %arg15 = 0 to 14 {
// CHECK:                             %21 = affine.load %subview[0, %arg12, %arg14, %arg15] : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                             %22 = affine.load %subview_0[%arg13, %arg12, 0, 0] : memref<16x16x1x1xi8, strided<[576, 9, 3, 1], offset: ?>, 12>
// CHECK:                             %23 = affine.load %subview_1[0, %arg13, %arg14, %arg15] : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                             %24 = arith.muli %21, %22 : i8
// CHECK:                             %25 = arith.addi %23, %24 : i8
// CHECK:                             affine.store %25, %subview_2[0, %arg13, %arg14, %arg15] : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                           } {parallel, point}
// CHECK:                         } {parallel, point}
// CHECK:                       } {parallel, point}
// CHECK:                     } {point}
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
// CHECK:                 %5 = affine.apply #map()
// CHECK:                 %6 = affine.apply #map1(%arg6)
// CHECK:                 %7 = affine.apply #map6(%arg8)
// CHECK:                 %8 = affine.apply #map6(%arg9)
// CHECK:                 %subview = memref.subview %arg0[%5, %6, %7, %8] [1, 16, 14, 14] [1, 1, 2, 2] : memref<1x64x56x56xi8, 12> to memref<1x16x14x14xi8, strided<[200704, 3136, 112, 2], offset: ?>, 12>
// CHECK:                 %9 = affine.apply #map1(%arg7)
// CHECK:                 %10 = affine.apply #map1(%arg6)
// CHECK:                 %11 = affine.apply #map()
// CHECK:                 %12 = affine.apply #map()
// CHECK:                 %subview_0 = memref.subview %arg2[%9, %10, %11, %12] [16, 16, 1, 1] [1, 1, 1, 1] : memref<64x64x1x1xi8, 12> to memref<16x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 12>
// CHECK:                 %13 = affine.apply #map()
// CHECK:                 %14 = affine.apply #map1(%arg7)
// CHECK:                 %15 = affine.apply #map2(%arg8)
// CHECK:                 %16 = affine.apply #map2(%arg9)
// CHECK:                 %subview_1 = memref.subview %3[%13, %14, %15, %16] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x28x28xi8, 12> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                 %17 = affine.apply #map()
// CHECK:                 %18 = affine.apply #map1(%arg7)
// CHECK:                 %19 = affine.apply #map2(%arg8)
// CHECK:                 %20 = affine.apply #map2(%arg9)
// CHECK:                 %subview_2 = memref.subview %3[%17, %18, %19, %20] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x28x28xi8, 12> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                 %21 = affine.apply #map()
// CHECK:                 %22 = affine.apply #map1(%arg7)
// CHECK:                 %23 = affine.apply #map2(%arg8)
// CHECK:                 %24 = affine.apply #map2(%arg9)
// CHECK:                 %subview_3 = memref.subview %1[%21, %22, %23, %24] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x28x28xi8, 12> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                 %25 = affine.apply #map()
// CHECK:                 %26 = affine.apply #map1(%arg7)
// CHECK:                 %27 = affine.apply #map2(%arg8)
// CHECK:                 %28 = affine.apply #map2(%arg9)
// CHECK:                 %subview_4 = memref.subview %3[%25, %26, %27, %28] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x28x28xi8, 12> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                 %29 = affine.apply #map()
// CHECK:                 %30 = affine.apply #map1(%arg7)
// CHECK:                 %31 = affine.apply #map2(%arg8)
// CHECK:                 %32 = affine.apply #map2(%arg9)
// CHECK:                 %subview_5 = memref.subview %2[%29, %30, %31, %32] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x28x28xi8, 12> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                 affine.for %arg10 = 0 to 16 {
// CHECK:                   affine.for %arg11 = 0 to 16 {
// CHECK:                     affine.for %arg12 = 0 to 14 {
// CHECK:                       affine.for %arg13 = 0 to 14 {
// CHECK:                         %33 = affine.load %subview[0, %arg10, %arg12, %arg13] : memref<1x16x14x14xi8, strided<[200704, 3136, 112, 2], offset: ?>, 12>
// CHECK:                         %34 = affine.load %subview_0[%arg11, %arg10, 0, 0] : memref<16x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 12>
// CHECK:                         %35 = affine.load %subview_1[0, %arg11, %arg12, %arg13] : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                         %36 = arith.muli %33, %34 : i8
// CHECK:                         %37 = arith.addi %35, %36 : i8
// CHECK:                         affine.store %37, %subview_2[0, %arg11, %arg12, %arg13] : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                         %38 = affine.load %subview_3[0, %arg11, %arg12, %arg13] : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                         %39 = affine.load %subview_4[0, %arg11, %arg12, %arg13] : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                         %40 = arith.addi %38, %39 : i8
// CHECK:                         %41 = arith.cmpi ugt, %40, %c-24_i8 : i8
// CHECK:                         %42 = arith.select %41, %40, %c-24_i8 : i8
// CHECK:                         affine.if #set1(%arg10, %arg6) {
// CHECK:                           affine.store %42, %subview_5[0, %arg11, %arg12, %arg13] : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                         }
// CHECK:                       } {parallel, point}
// CHECK:                     } {parallel, point}
// CHECK:                   } {parallel, point}
// CHECK:                 } {point}
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
// CHECK:               %5 = affine.apply #map()
// CHECK:               %6 = affine.apply #map1(%arg8)
// CHECK:               %7 = affine.apply #map2(%arg6)
// CHECK:               %8 = affine.apply #map2(%arg7)
// CHECK:               %subview = memref.subview %2[%5, %6, %7, %8] [1, 16, 14, 14] [1, 1, 1, 1] : memref<1x64x28x28xi8, 12> to memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:               %9 = affine.apply #map()
// CHECK:               %10 = affine.apply #map1(%arg8)
// CHECK:               %11 = affine.apply #map()
// CHECK:               %12 = affine.apply #map()
// CHECK:               %subview_0 = memref.subview %4[%9, %10, %11, %12] [1, 16, 1, 1] [1, 1, 1, 1] : memref<1x64x1x1xi8, 7> to memref<1x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 7>
// CHECK:               %13 = affine.apply #map()
// CHECK:               %14 = affine.apply #map1(%arg8)
// CHECK:               %15 = affine.apply #map()
// CHECK:               %16 = affine.apply #map()
// CHECK:               %subview_1 = memref.subview %4[%13, %14, %15, %16] [1, 16, 1, 1] [1, 1, 1, 1] : memref<1x64x1x1xi8, 7> to memref<1x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 7>
// CHECK:               %17 = affine.apply #map()
// CHECK:               %18 = affine.apply #map1(%arg8)
// CHECK:               %19 = affine.apply #map()
// CHECK:               %20 = affine.apply #map()
// CHECK:               %subview_2 = memref.subview %4[%17, %18, %19, %20] [1, 16, 1, 1] [1, 1, 1, 1] : memref<1x64x1x1xi8, 7> to memref<1x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 7>
// CHECK:               %21 = affine.apply #map()
// CHECK:               %22 = affine.apply #map1(%arg8)
// CHECK:               %23 = affine.apply #map()
// CHECK:               %24 = affine.apply #map()
// CHECK:               %subview_3 = memref.subview %4[%21, %22, %23, %24] [1, 16, 1, 1] [1, 1, 1, 1] : memref<1x64x1x1xi8, 7> to memref<1x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 7>
// CHECK:               affine.for %arg9 = 0 to 14 {
// CHECK:                 affine.for %arg10 = 0 to 14 {
// CHECK:                   affine.for %arg11 = 0 to 16 {
// CHECK:                     %25 = affine.load %subview[0, %arg11, %arg9, %arg10] : memref<1x16x14x14xi8, strided<[50176, 784, 28, 1], offset: ?>, 12>
// CHECK:                     %26 = affine.load %subview_0[0, %arg11, 0, 0] : memref<1x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 7>
// CHECK:                     %27 = arith.addi %26, %25 : i8
// CHECK:                     affine.store %27, %subview_1[0, %arg11, 0, 0] : memref<1x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 7>
// CHECK:                     %28 = affine.load %subview_2[0, %arg11, 0, 0] : memref<1x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 7>
// CHECK:                     %29 = arith.divui %28, %c-24_i8 : i8
// CHECK:                     affine.if #set2(%arg9, %arg10, %arg6, %arg7) {
// CHECK:                       affine.store %29, %subview_3[0, %arg11, 0, 0] : memref<1x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 7>
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
// CHECK:             %5 = affine.apply #map()
// CHECK:             %6 = affine.apply #map7(%arg7)
// CHECK:             %subview = memref.subview %arg5[%5, %6] [1, 10] [1, 1] : memref<1x1000xi8, 12> to memref<1x10xi8, strided<[1000, 1], offset: ?>, 12>
// CHECK:             %7 = affine.apply #map()
// CHECK:             %8 = affine.apply #map1(%arg6)
// CHECK:             %9 = affine.apply #map()
// CHECK:             %10 = affine.apply #map()
// CHECK:             %subview_0 = memref.subview %4[%7, %8, %9, %10] [1, 16, 1, 1] [1, 1, 1, 1] : memref<1x64x1x1xi8, 7> to memref<1x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 7>
// CHECK:             %11 = affine.apply #map7(%arg7)
// CHECK:             %12 = affine.apply #map1(%arg6)
// CHECK:             %subview_1 = memref.subview %arg1[%11, %12] [10, 16] [1, 1] : memref<1000x64xi8, 12> to memref<10x16xi8, strided<[64, 1], offset: ?>, 12>
// CHECK:             %13 = affine.apply #map()
// CHECK:             %14 = affine.apply #map7(%arg7)
// CHECK:             %subview_2 = memref.subview %arg5[%13, %14] [1, 10] [1, 1] : memref<1x1000xi8, 12> to memref<1x10xi8, strided<[1000, 1], offset: ?>, 12>
// CHECK:             %15 = affine.apply #map()
// CHECK:             %16 = affine.apply #map7(%arg7)
// CHECK:             %subview_3 = memref.subview %arg5[%15, %16] [1, 10] [1, 1] : memref<1x1000xi8, 12> to memref<1x10xi8, strided<[1000, 1], offset: ?>, 12>
// CHECK:             affine.for %arg8 = 0 to 16 {
// CHECK:               affine.for %arg9 = 0 to 10 {
// CHECK:                 affine.if #set3(%arg8, %arg6) {
// CHECK:                   affine.store %c-24_i8, %subview[0, %arg9] : memref<1x10xi8, strided<[1000, 1], offset: ?>, 12>
// CHECK:                 }
// CHECK:                 %17 = affine.load %subview_0[0, %arg8, 0, 0] : memref<1x16x1x1xi8, strided<[64, 1, 1, 1], offset: ?>, 7>
// CHECK:                 %18 = affine.load %subview_1[%arg9, %arg8] : memref<10x16xi8, strided<[64, 1], offset: ?>, 12>
// CHECK:                 %19 = affine.load %subview_2[0, %arg9] : memref<1x10xi8, strided<[1000, 1], offset: ?>, 12>
// CHECK:                 %20 = arith.muli %17, %18 : i8
// CHECK:                 %21 = arith.addi %19, %20 : i8
// CHECK:                 affine.store %21, %subview_3[0, %arg9] : memref<1x10xi8, strided<[1000, 1], offset: ?>, 12>
// CHECK:               } {parallel, point}
// CHECK:             } {point}
// CHECK:           } {parallel}
// CHECK:         }
// CHECK:       }
// CHECK:     }
// CHECK:     return
// CHECK:   }
// CHECK: }

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
              affine.for %arg9 = 0 to 16 {
                affine.for %arg10 = 0 to 14 {
                  affine.for %arg11 = 0 to 14 {
                    %5 = affine.load %arg0[0, %arg9 + %arg6 * 16, %arg10 + %arg7 * 14, %arg11 + %arg8 * 14] : memref<1x64x56x56xi8, 12>
                    %6 = arith.cmpi ugt, %5, %c-24_i8 : i8
                    %7 = arith.select %6, %5, %c-24_i8 : i8
                    affine.store %7, %arg0[0, %arg9 + %arg6 * 16, %arg10 + %arg7 * 14, %arg11 + %arg8 * 14] : memref<1x64x56x56xi8, 12>
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
                    affine.for %arg12 = 0 to 16 {
                      affine.for %arg13 = 0 to 16 {
                        affine.for %arg14 = 0 to 14 {
                          affine.for %arg15 = 0 to 14 {
                            %5 = affine.load %arg0[0, %arg12 + %arg6 * 16, %arg7 + %arg14 * 2 + %arg10 * 28 - 1, %arg8 + %arg15 * 2 + %arg11 * 28 - 1] : memref<1x64x56x56xi8, 12>
                            %6 = affine.load %arg4[%arg13 + %arg9 * 16, %arg12 + %arg6 * 16, %arg7, %arg8] : memref<64x64x3x3xi8, 12>
                            %7 = affine.load %0[0, %arg13 + %arg9 * 16, %arg14 + %arg10 * 14, %arg15 + %arg11 * 14] : memref<1x64x28x28xi8, 12>
                            %8 = arith.muli %5, %6 : i8
                            %9 = arith.addi %7, %8 : i8
                            affine.store %9, %0[0, %arg13 + %arg9 * 16, %arg14 + %arg10 * 14, %arg15 + %arg11 * 14] : memref<1x64x28x28xi8, 12>
                            %10 = affine.load %0[0, %arg13 + %arg9 * 16, %arg14 + %arg10 * 14, %arg15 + %arg11 * 14] : memref<1x64x28x28xi8, 12>
                            %11 = arith.cmpi ugt, %10, %c-24_i8 : i8
                            %12 = arith.select %11, %10, %c-24_i8 : i8
                            affine.if #set(%arg7, %arg8, %arg12, %arg6) {
                              affine.store %12, %0[0, %arg13 + %arg9 * 16, %arg14 + %arg10 * 14, %arg15 + %arg11 * 14] : memref<1x64x28x28xi8, 12>
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
                    affine.for %arg12 = 0 to 16 {
                      affine.for %arg13 = 0 to 16 {
                        affine.for %arg14 = 0 to 14 {
                          affine.for %arg15 = 0 to 14 {
                            %5 = affine.load %0[0, %arg12 + %arg6 * 16, %arg7 + %arg14 + %arg10 * 14 - 1, %arg8 + %arg15 + %arg11 * 14 - 1] : memref<1x64x28x28xi8, 12>
                            %6 = affine.load %arg3[%arg13 + %arg9 * 16, %arg12 + %arg6 * 16, %arg7, %arg8] : memref<64x64x3x3xi8, 12>
                            %7 = affine.load %1[0, %arg13 + %arg9 * 16, %arg14 + %arg10 * 14, %arg15 + %arg11 * 14] : memref<1x64x28x28xi8, 12>
                            %8 = arith.muli %5, %6 : i8
                            %9 = arith.addi %7, %8 : i8
                            affine.store %9, %1[0, %arg13 + %arg9 * 16, %arg14 + %arg10 * 14, %arg15 + %arg11 * 14] : memref<1x64x28x28xi8, 12>
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
                affine.for %arg10 = 0 to 16 {
                  affine.for %arg11 = 0 to 16 {
                    affine.for %arg12 = 0 to 14 {
                      affine.for %arg13 = 0 to 14 {
                        %5 = affine.load %arg0[0, %arg10 + %arg6 * 16, %arg12 * 2 + %arg8 * 28, %arg13 * 2 + %arg9 * 28] : memref<1x64x56x56xi8, 12>
                        %6 = affine.load %arg2[%arg11 + %arg7 * 16, %arg10 + %arg6 * 16, 0, 0] : memref<64x64x1x1xi8, 12>
                        %7 = affine.load %3[0, %arg11 + %arg7 * 16, %arg12 + %arg8 * 14, %arg13 + %arg9 * 14] : memref<1x64x28x28xi8, 12>
                        %8 = arith.muli %5, %6 : i8
                        %9 = arith.addi %7, %8 : i8
                        affine.store %9, %3[0, %arg11 + %arg7 * 16, %arg12 + %arg8 * 14, %arg13 + %arg9 * 14] : memref<1x64x28x28xi8, 12>
                        %10 = affine.load %1[0, %arg11 + %arg7 * 16, %arg12 + %arg8 * 14, %arg13 + %arg9 * 14] : memref<1x64x28x28xi8, 12>
                        %11 = affine.load %3[0, %arg11 + %arg7 * 16, %arg12 + %arg8 * 14, %arg13 + %arg9 * 14] : memref<1x64x28x28xi8, 12>
                        %12 = arith.addi %10, %11 : i8
                        %13 = arith.cmpi ugt, %12, %c-24_i8 : i8
                        %14 = arith.select %13, %12, %c-24_i8 : i8
                        affine.if #set1(%arg10, %arg6) {
                          affine.store %14, %2[0, %arg11 + %arg7 * 16, %arg12 + %arg8 * 14, %arg13 + %arg9 * 14] : memref<1x64x28x28xi8, 12>
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
              affine.for %arg9 = 0 to 14 {
                affine.for %arg10 = 0 to 14 {
                  affine.for %arg11 = 0 to 16 {
                    %5 = affine.load %2[0, %arg11 + %arg8 * 16, %arg9 + %arg6 * 14, %arg10 + %arg7 * 14] : memref<1x64x28x28xi8, 12>
                    %6 = affine.load %4[0, %arg11 + %arg8 * 16, 0, 0] : memref<1x64x1x1xi8, 7>
                    %7 = arith.addi %6, %5 : i8
                    affine.store %7, %4[0, %arg11 + %arg8 * 16, 0, 0] : memref<1x64x1x1xi8, 7>
                    %8 = affine.load %4[0, %arg11 + %arg8 * 16, 0, 0] : memref<1x64x1x1xi8, 7>
                    %9 = arith.divui %8, %c-24_i8 : i8
                    affine.if #set2(%arg9, %arg10, %arg6, %arg7) {
                      affine.store %9, %4[0, %arg11 + %arg8 * 16, 0, 0] : memref<1x64x1x1xi8, 7>
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
            affine.for %arg8 = 0 to 16 {
              affine.for %arg9 = 0 to 10 {
                affine.if #set3(%arg8, %arg6) {
                  affine.store %c-24_i8, %arg5[0, %arg9 + %arg7 * 10] : memref<1x1000xi8, 12>
                }
                %5 = affine.load %4[0, %arg8 + %arg6 * 16, 0, 0] : memref<1x64x1x1xi8, 7>
                %6 = affine.load %arg1[%arg9 + %arg7 * 10, %arg8 + %arg6 * 16] : memref<1000x64xi8, 12>
                %7 = affine.load %arg5[0, %arg9 + %arg7 * 10] : memref<1x1000xi8, 12>
                %8 = arith.muli %5, %6 : i8
                %9 = arith.addi %7, %8 : i8
                affine.store %9, %arg5[0, %arg9 + %arg7 * 10] : memref<1x1000xi8, 12>
              } {parallel, point}
            } {point}
          } {parallel}
        }
      }
    }
    return
  }
}

