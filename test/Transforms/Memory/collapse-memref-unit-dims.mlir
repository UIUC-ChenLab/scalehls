// RUN: scalehls-opt -scalehls-collapse-memref-unit-dims %s | FileCheck %s

// CHECK: #set = affine_set<(d0, d1, d2, d3) : (-d2 - d3 * 16 + 63 == 0, -d0 + 2 == 0, -d1 + 2 == 0)>
// CHECK: #set1 = affine_set<(d0, d1) : (-d0 - d1 * 16 + 63 == 0)>
// CHECK: #set2 = affine_set<(d0, d1, d2, d3) : (-d0 - d2 * 14 + 27 == 0, -d1 - d3 * 14 + 27 == 0)>
// CHECK: #set3 = affine_set<(d0, d1) : (d0 + d1 * 16 == 0)>
// CHECK: module attributes {torch.debug_module_name = "ResNet"} {
// CHECK:   func.func @forward(%arg0: memref<64x56x56xi8, 12>, %arg1: memref<1000x64xi8, 12>, %arg2: memref<64x64xi8, 12>, %arg3: memref<64x64x3x3xi8, 12>, %arg4: memref<64x64x3x3xi8, 12>, %arg5: memref<1000xi8, 12>) attributes {top_func} {
// CHECK:     %c-24_i8 = arith.constant -24 : i8
// CHECK:     hls.dataflow.dispatch {
// CHECK:       hls.dataflow.task {
// CHECK:         affine.for %arg6 = 0 to 4 {
// CHECK:           affine.for %arg7 = 0 to 4 {
// CHECK:             affine.for %arg8 = 0 to 4 {
// CHECK:               %5 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
// CHECK:               affine.for %arg9 = 0 to 16 {
// CHECK:                 affine.for %arg10 = 0 to 14 {
// CHECK:                   affine.for %arg11 = 0 to 14 {
// CHECK:                     %6 = affine.load %arg0[%arg9 + %arg6 * 16, %arg10 + %arg7 * 14, %arg11 + %arg8 * 14] : memref<64x56x56xi8, 12>
// CHECK:                     affine.store %6, %5[%arg9, %arg10, %arg11] : memref<16x14x14xi8, 7>
// CHECK:                   } {parallel}
// CHECK:                 } {parallel}
// CHECK:               } {parallel}
// CHECK:               affine.for %arg9 = 0 to 16 {
// CHECK:                 affine.for %arg10 = 0 to 14 {
// CHECK:                   affine.for %arg11 = 0 to 14 {
// CHECK:                     %6 = affine.load %5[%arg9, %arg10, %arg11] : memref<16x14x14xi8, 7>
// CHECK:                     %7 = arith.cmpi ugt, %6, %c-24_i8 : i8
// CHECK:                     %8 = arith.select %7, %6, %c-24_i8 : i8
// CHECK:                     affine.store %8, %5[%arg9, %arg10, %arg11] : memref<16x14x14xi8, 7>
// CHECK:                   } {parallel, point}
// CHECK:                 } {parallel, point}
// CHECK:               } {parallel, point}
// CHECK:               affine.for %arg9 = 0 to 16 {
// CHECK:                 affine.for %arg10 = 0 to 14 {
// CHECK:                   affine.for %arg11 = 0 to 14 {
// CHECK:                     %6 = affine.load %5[%arg9, %arg10, %arg11] : memref<16x14x14xi8, 7>
// CHECK:                     affine.store %6, %arg0[%arg9 + %arg6 * 16, %arg10 + %arg7 * 14, %arg11 + %arg8 * 14] : memref<64x56x56xi8, 12>
// CHECK:                   } {parallel}
// CHECK:                 } {parallel}
// CHECK:               } {parallel}
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:       }
// CHECK:       %0 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, 12>
// CHECK:       hls.dataflow.task {
// CHECK:         affine.for %arg6 = 0 to 4 {
// CHECK:           affine.for %arg7 = 0 to 3 {
// CHECK:             affine.for %arg8 = 0 to 3 {
// CHECK:               affine.for %arg9 = 0 to 4 {
// CHECK:                 affine.for %arg10 = 0 to 2 {
// CHECK:                   affine.for %arg11 = 0 to 2 {
// CHECK:                     %5 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
// CHECK:                     affine.for %arg12 = 0 to 16 {
// CHECK:                       affine.for %arg13 = 0 to 14 {
// CHECK:                         affine.for %arg14 = 0 to 14 {
// CHECK:                           %8 = affine.load %arg0[%arg12 + %arg6 * 16, %arg13 * 2 + %arg7 + %arg10 * 28 - 1, %arg14 * 2 + %arg8 + %arg11 * 28 - 1] : memref<64x56x56xi8, 12>
// CHECK:                           affine.store %8, %5[%arg12, %arg13, %arg14] : memref<16x14x14xi8, 7>
// CHECK:                         } {parallel}
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                     %6 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, 7>
// CHECK:                     affine.for %arg12 = 0 to 16 {
// CHECK:                       affine.for %arg13 = 0 to 16 {
// CHECK:                         %8 = affine.load %arg4[%arg12 + %arg9 * 16, %arg13 + %arg6 * 16, %arg7, %arg8] : memref<64x64x3x3xi8, 12>
// CHECK:                         affine.store %8, %6[%arg12, %arg13] : memref<16x16xi8, 7>
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                     %7 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, 7>
// CHECK:                     affine.for %arg12 = 0 to 16 {
// CHECK:                       affine.for %arg13 = 0 to 14 {
// CHECK:                         affine.for %arg14 = 0 to 14 {
// CHECK:                           %8 = affine.load %0[%arg12 + %arg9 * 16, %arg13 + %arg10 * 14, %arg14 + %arg11 * 14] : memref<64x28x28xi8, 12>
// CHECK:                           affine.store %8, %7[%arg12, %arg13, %arg14] : memref<16x14x14xi8, 7>
// CHECK:                         } {parallel}
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                     affine.for %arg12 = 0 to 16 {
// CHECK:                       affine.for %arg13 = 0 to 16 {
// CHECK:                         affine.for %arg14 = 0 to 14 {
// CHECK:                           affine.for %arg15 = 0 to 14 {
// CHECK:                             %8 = affine.load %5[%arg12, %arg14, %arg15] : memref<16x14x14xi8, 7>
// CHECK:                             %9 = affine.load %6[%arg13, %arg12] : memref<16x16xi8, 7>
// CHECK:                             %10 = affine.load %7[%arg13, %arg14, %arg15] : memref<16x14x14xi8, 7>
// CHECK:                             %11 = arith.muli %8, %9 : i8
// CHECK:                             %12 = arith.addi %10, %11 : i8
// CHECK:                             affine.store %12, %7[%arg13, %arg14, %arg15] : memref<16x14x14xi8, 7>
// CHECK:                             %13 = affine.load %7[%arg13, %arg14, %arg15] : memref<16x14x14xi8, 7>
// CHECK:                             %14 = arith.cmpi ugt, %13, %c-24_i8 : i8
// CHECK:                             %15 = arith.select %14, %13, %c-24_i8 : i8
// CHECK:                             affine.if #set(%arg7, %arg8, %arg12, %arg6) {
// CHECK:                               affine.store %15, %7[%arg13, %arg14, %arg15] : memref<16x14x14xi8, 7>
// CHECK:                             }
// CHECK:                           } {parallel, point}
// CHECK:                         } {parallel, point}
// CHECK:                       } {parallel, point}
// CHECK:                     } {point}
// CHECK:                     affine.for %arg12 = 0 to 16 {
// CHECK:                       affine.for %arg13 = 0 to 14 {
// CHECK:                         affine.for %arg14 = 0 to 14 {
// CHECK:                           %8 = affine.load %7[%arg12, %arg13, %arg14] : memref<16x14x14xi8, 7>
// CHECK:                           affine.store %8, %0[%arg12 + %arg9 * 16, %arg13 + %arg10 * 14, %arg14 + %arg11 * 14] : memref<64x28x28xi8, 12>
// CHECK:                         } {parallel}
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   } {parallel}
// CHECK:                 } {parallel}
// CHECK:               } {parallel}
// CHECK:             }
// CHECK:           }
// CHECK:         }
// CHECK:       }
// CHECK:       %1 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, 12>
// CHECK:       hls.dataflow.task {
// CHECK:         affine.for %arg6 = 0 to 4 {
// CHECK:           affine.for %arg7 = 0 to 3 {
// CHECK:             affine.for %arg8 = 0 to 3 {
// CHECK:               affine.for %arg9 = 0 to 4 {
// CHECK:                 affine.for %arg10 = 0 to 2 {
// CHECK:                   affine.for %arg11 = 0 to 2 {
// CHECK:                     %5 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, 7>
// CHECK:                     affine.for %arg12 = 0 to 16 {
// CHECK:                       affine.for %arg13 = 0 to 14 {
// CHECK:                         affine.for %arg14 = 0 to 14 {
// CHECK:                           %8 = affine.load %0[%arg12 + %arg6 * 16, %arg13 + %arg7 + %arg10 * 14 - 1, %arg14 + %arg8 + %arg11 * 14 - 1] : memref<64x28x28xi8, 12>
// CHECK:                           affine.store %8, %5[%arg12, %arg13, %arg14] : memref<16x14x14xi8, 7>
// CHECK:                         } {parallel}
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                     %6 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, 7>
// CHECK:                     affine.for %arg12 = 0 to 16 {
// CHECK:                       affine.for %arg13 = 0 to 16 {
// CHECK:                         %8 = affine.load %arg3[%arg12 + %arg9 * 16, %arg13 + %arg6 * 16, %arg7, %arg8] : memref<64x64x3x3xi8, 12>
// CHECK:                         affine.store %8, %6[%arg12, %arg13] : memref<16x16xi8, 7>
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                     %7 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, 7>
// CHECK:                     affine.for %arg12 = 0 to 16 {
// CHECK:                       affine.for %arg13 = 0 to 14 {
// CHECK:                         affine.for %arg14 = 0 to 14 {
// CHECK:                           %8 = affine.load %1[%arg12 + %arg9 * 16, %arg13 + %arg10 * 14, %arg14 + %arg11 * 14] : memref<64x28x28xi8, 12>
// CHECK:                           affine.store %8, %7[%arg12, %arg13, %arg14] : memref<16x14x14xi8, 7>
// CHECK:                         } {parallel}
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                     affine.for %arg12 = 0 to 16 {
// CHECK:                       affine.for %arg13 = 0 to 16 {
// CHECK:                         affine.for %arg14 = 0 to 14 {
// CHECK:                           affine.for %arg15 = 0 to 14 {
// CHECK:                             %8 = affine.load %5[%arg12, %arg14, %arg15] : memref<16x14x14xi8, 7>
// CHECK:                             %9 = affine.load %6[%arg13, %arg12] : memref<16x16xi8, 7>
// CHECK:                             %10 = affine.load %7[%arg13, %arg14, %arg15] : memref<16x14x14xi8, 7>
// CHECK:                             %11 = arith.muli %8, %9 : i8
// CHECK:                             %12 = arith.addi %10, %11 : i8
// CHECK:                             affine.store %12, %7[%arg13, %arg14, %arg15] : memref<16x14x14xi8, 7>
// CHECK:                           } {parallel, point}
// CHECK:                         } {parallel, point}
// CHECK:                       } {parallel, point}
// CHECK:                     } {point}
// CHECK:                     affine.for %arg12 = 0 to 16 {
// CHECK:                       affine.for %arg13 = 0 to 14 {
// CHECK:                         affine.for %arg14 = 0 to 14 {
// CHECK:                           %8 = affine.load %7[%arg12, %arg13, %arg14] : memref<16x14x14xi8, 7>
// CHECK:                           affine.store %8, %1[%arg12 + %arg9 * 16, %arg13 + %arg10 * 14, %arg14 + %arg11 * 14] : memref<64x28x28xi8, 12>
// CHECK:                         } {parallel}
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   } {parallel}
// CHECK:                 } {parallel}
// CHECK:               } {parallel}
// CHECK:             }
// CHECK:           }
// CHECK:         }
// CHECK:       }
// CHECK:       %2 = hls.dataflow.buffer {depth = 1 : i32} : memref<64x28x28xi8, 12>
// CHECK:       %3 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, 12>
// CHECK:       hls.dataflow.task {
// CHECK:         affine.for %arg6 = 0 to 4 {
// CHECK:           affine.for %arg7 = 0 to 4 {
// CHECK:             affine.for %arg8 = 0 to 2 {
// CHECK:               affine.for %arg9 = 0 to 2 {
// CHECK:                 %5 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
// CHECK:                 affine.for %arg10 = 0 to 16 {
// CHECK:                   affine.for %arg11 = 0 to 14 {
// CHECK:                     affine.for %arg12 = 0 to 14 {
// CHECK:                       %10 = affine.load %arg0[%arg10 + %arg6 * 16, %arg11 * 2 + %arg8 * 28, %arg12 * 2 + %arg9 * 28] : memref<64x56x56xi8, 12>
// CHECK:                       affine.store %10, %5[%arg10, %arg11, %arg12] : memref<16x14x14xi8, 7>
// CHECK:                     } {parallel}
// CHECK:                   } {parallel}
// CHECK:                 } {parallel}
// CHECK:                 %6 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, 7>
// CHECK:                 affine.for %arg10 = 0 to 16 {
// CHECK:                   affine.for %arg11 = 0 to 16 {
// CHECK:                     %10 = affine.load %arg2[%arg10 + %arg7 * 16, %arg11 + %arg6 * 16] : memref<64x64xi8, 12>
// CHECK:                     affine.store %10, %6[%arg10, %arg11] : memref<16x16xi8, 7>
// CHECK:                   } {parallel}
// CHECK:                 } {parallel}
// CHECK:                 %7 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, 7>
// CHECK:                 affine.for %arg10 = 0 to 16 {
// CHECK:                   affine.for %arg11 = 0 to 14 {
// CHECK:                     affine.for %arg12 = 0 to 14 {
// CHECK:                       %10 = affine.load %3[%arg10 + %arg7 * 16, %arg11 + %arg8 * 14, %arg12 + %arg9 * 14] : memref<64x28x28xi8, 12>
// CHECK:                       affine.store %10, %7[%arg10, %arg11, %arg12] : memref<16x14x14xi8, 7>
// CHECK:                     } {parallel}
// CHECK:                   } {parallel}
// CHECK:                 } {parallel}
// CHECK:                 %8 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, 7>
// CHECK:                 affine.for %arg10 = 0 to 16 {
// CHECK:                   affine.for %arg11 = 0 to 14 {
// CHECK:                     affine.for %arg12 = 0 to 14 {
// CHECK:                       %10 = affine.load %1[%arg10 + %arg7 * 16, %arg11 + %arg8 * 14, %arg12 + %arg9 * 14] : memref<64x28x28xi8, 12>
// CHECK:                       affine.store %10, %8[%arg10, %arg11, %arg12] : memref<16x14x14xi8, 7>
// CHECK:                     } {parallel}
// CHECK:                   } {parallel}
// CHECK:                 } {parallel}
// CHECK:                 %9 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
// CHECK:                 affine.for %arg10 = 0 to 16 {
// CHECK:                   affine.for %arg11 = 0 to 16 {
// CHECK:                     affine.for %arg12 = 0 to 14 {
// CHECK:                       affine.for %arg13 = 0 to 14 {
// CHECK:                         %10 = affine.load %5[%arg10, %arg12, %arg13] : memref<16x14x14xi8, 7>
// CHECK:                         %11 = affine.load %6[%arg11, %arg10] : memref<16x16xi8, 7>
// CHECK:                         %12 = affine.load %7[%arg11, %arg12, %arg13] : memref<16x14x14xi8, 7>
// CHECK:                         %13 = arith.muli %10, %11 : i8
// CHECK:                         %14 = arith.addi %12, %13 : i8
// CHECK:                         affine.store %14, %7[%arg11, %arg12, %arg13] : memref<16x14x14xi8, 7>
// CHECK:                         %15 = affine.load %8[%arg11, %arg12, %arg13] : memref<16x14x14xi8, 7>
// CHECK:                         %16 = affine.load %7[%arg11, %arg12, %arg13] : memref<16x14x14xi8, 7>
// CHECK:                         %17 = arith.addi %15, %16 : i8
// CHECK:                         %18 = arith.cmpi ugt, %17, %c-24_i8 : i8
// CHECK:                         %19 = arith.select %18, %17, %c-24_i8 : i8
// CHECK:                         affine.if #set1(%arg10, %arg6) {
// CHECK:                           affine.store %19, %9[%arg11, %arg12, %arg13] : memref<16x14x14xi8, 7>
// CHECK:                         }
// CHECK:                       } {parallel, point}
// CHECK:                     } {parallel, point}
// CHECK:                   } {parallel, point}
// CHECK:                 } {point}
// CHECK:                 affine.for %arg10 = 0 to 16 {
// CHECK:                   affine.for %arg11 = 0 to 14 {
// CHECK:                     affine.for %arg12 = 0 to 14 {
// CHECK:                       %10 = affine.load %7[%arg10, %arg11, %arg12] : memref<16x14x14xi8, 7>
// CHECK:                       affine.store %10, %3[%arg10 + %arg7 * 16, %arg11 + %arg8 * 14, %arg12 + %arg9 * 14] : memref<64x28x28xi8, 12>
// CHECK:                     } {parallel}
// CHECK:                   } {parallel}
// CHECK:                 } {parallel}
// CHECK:                 affine.for %arg10 = 0 to 16 {
// CHECK:                   affine.for %arg11 = 0 to 14 {
// CHECK:                     affine.for %arg12 = 0 to 14 {
// CHECK:                       %10 = affine.load %9[%arg10, %arg11, %arg12] : memref<16x14x14xi8, 7>
// CHECK:                       affine.store %10, %2[%arg10 + %arg7 * 16, %arg11 + %arg8 * 14, %arg12 + %arg9 * 14] : memref<64x28x28xi8, 12>
// CHECK:                     } {parallel}
// CHECK:                   } {parallel}
// CHECK:                 } {parallel}
// CHECK:               } {parallel}
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         }
// CHECK:       }
// CHECK:       %4 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64xi8, 7>
// CHECK:       hls.dataflow.task {
// CHECK:         affine.for %arg6 = 0 to 2 {
// CHECK:           affine.for %arg7 = 0 to 2 {
// CHECK:             affine.for %arg8 = 0 to 4 {
// CHECK:               %5 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
// CHECK:               affine.for %arg9 = 0 to 16 {
// CHECK:                 affine.for %arg10 = 0 to 14 {
// CHECK:                   affine.for %arg11 = 0 to 14 {
// CHECK:                     %6 = affine.load %2[%arg9 + %arg8 * 16, %arg10 + %arg6 * 14, %arg11 + %arg7 * 14] : memref<64x28x28xi8, 12>
// CHECK:                     affine.store %6, %5[%arg9, %arg10, %arg11] : memref<16x14x14xi8, 7>
// CHECK:                   } {parallel}
// CHECK:                 } {parallel}
// CHECK:               } {parallel}
// CHECK:               affine.for %arg9 = 0 to 14 {
// CHECK:                 affine.for %arg10 = 0 to 14 {
// CHECK:                   affine.for %arg11 = 0 to 16 {
// CHECK:                     %6 = affine.load %5[%arg11, %arg9, %arg10] : memref<16x14x14xi8, 7>
// CHECK:                     %7 = affine.load %4[%arg11 + %arg8 * 16] : memref<64xi8, 7>
// CHECK:                     %8 = arith.addi %7, %6 : i8
// CHECK:                     affine.store %8, %4[%arg11 + %arg8 * 16] : memref<64xi8, 7>
// CHECK:                     %9 = affine.load %4[%arg11 + %arg8 * 16] : memref<64xi8, 7>
// CHECK:                     %10 = arith.divui %9, %c-24_i8 : i8
// CHECK:                     affine.if #set2(%arg9, %arg10, %arg6, %arg7) {
// CHECK:                       affine.store %10, %4[%arg11 + %arg8 * 16] : memref<64xi8, 7>
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
// CHECK:             %5 = hls.dataflow.buffer {depth = 1 : i32} : memref<10xi8, 7>
// CHECK:             affine.for %arg8 = 0 to 10 {
// CHECK:               %7 = affine.load %arg5[%arg8 + %arg7 * 10] : memref<1000xi8, 12>
// CHECK:               affine.store %7, %5[%arg8] : memref<10xi8, 7>
// CHECK:             } {parallel}
// CHECK:             %6 = hls.dataflow.buffer {depth = 1 : i32} : memref<10x16xi8, 7>
// CHECK:             affine.for %arg8 = 0 to 10 {
// CHECK:               affine.for %arg9 = 0 to 16 {
// CHECK:                 %7 = affine.load %arg1[%arg8 + %arg7 * 10, %arg9 + %arg6 * 16] : memref<1000x64xi8, 12>
// CHECK:                 affine.store %7, %6[%arg8, %arg9] : memref<10x16xi8, 7>
// CHECK:               } {parallel}
// CHECK:             } {parallel}
// CHECK:             affine.for %arg8 = 0 to 16 {
// CHECK:               affine.for %arg9 = 0 to 10 {
// CHECK:                 affine.if #set3(%arg8, %arg6) {
// CHECK:                   affine.store %c-24_i8, %5[%arg9] : memref<10xi8, 7>
// CHECK:                 }
// CHECK:                 %7 = affine.load %4[%arg8 + %arg6 * 16] : memref<64xi8, 7>
// CHECK:                 %8 = affine.load %6[%arg9, %arg8] : memref<10x16xi8, 7>
// CHECK:                 %9 = affine.load %5[%arg9] : memref<10xi8, 7>
// CHECK:                 %10 = arith.muli %7, %8 : i8
// CHECK:                 %11 = arith.addi %9, %10 : i8
// CHECK:                 affine.store %11, %5[%arg9] : memref<10xi8, 7>
// CHECK:               } {parallel, point}
// CHECK:             } {point}
// CHECK:             affine.for %arg8 = 0 to 10 {
// CHECK:               %7 = affine.load %5[%arg8] : memref<10xi8, 7>
// CHECK:               affine.store %7, %arg5[%arg8 + %arg7 * 10] : memref<1000xi8, 12>
// CHECK:             } {parallel}
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
              %5 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x16x14x14xi8, 7>
              affine.for %arg9 = 0 to 16 {
                affine.for %arg10 = 0 to 14 {
                  affine.for %arg11 = 0 to 14 {
                    %6 = affine.load %arg0[0, %arg9 + %arg6 * 16, %arg10 + %arg7 * 14, %arg11 + %arg8 * 14] : memref<1x64x56x56xi8, 12>
                    affine.store %6, %5[0, %arg9, %arg10, %arg11] : memref<1x16x14x14xi8, 7>
                  } {parallel}
                } {parallel}
              } {parallel}
              affine.for %arg9 = 0 to 16 {
                affine.for %arg10 = 0 to 14 {
                  affine.for %arg11 = 0 to 14 {
                    %6 = affine.load %5[0, %arg9, %arg10, %arg11] : memref<1x16x14x14xi8, 7>
                    %7 = arith.cmpi ugt, %6, %c-24_i8 : i8
                    %8 = arith.select %7, %6, %c-24_i8 : i8
                    affine.store %8, %5[0, %arg9, %arg10, %arg11] : memref<1x16x14x14xi8, 7>
                  } {parallel, point}
                } {parallel, point}
              } {parallel, point}
              affine.for %arg9 = 0 to 16 {
                affine.for %arg10 = 0 to 14 {
                  affine.for %arg11 = 0 to 14 {
                    %6 = affine.load %5[0, %arg9, %arg10, %arg11] : memref<1x16x14x14xi8, 7>
                    affine.store %6, %arg0[0, %arg9 + %arg6 * 16, %arg10 + %arg7 * 14, %arg11 + %arg8 * 14] : memref<1x64x56x56xi8, 12>
                  } {parallel}
                } {parallel}
              } {parallel}
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
                    %5 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x16x14x14xi8, 7>
                    affine.for %arg12 = 0 to 16 {
                      affine.for %arg13 = 0 to 14 {
                        affine.for %arg14 = 0 to 14 {
                          %8 = affine.load %arg0[0, %arg12 + %arg6 * 16, %arg13 * 2 + %arg7 + %arg10 * 28 - 1, %arg14 * 2 + %arg8 + %arg11 * 28 - 1] : memref<1x64x56x56xi8, 12>
                          affine.store %8, %5[0, %arg12, %arg13, %arg14] : memref<1x16x14x14xi8, 7>
                        } {parallel}
                      } {parallel}
                    } {parallel}
                    %6 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16x1x1xi8, 7>
                    affine.for %arg12 = 0 to 16 {
                      affine.for %arg13 = 0 to 16 {
                        %8 = affine.load %arg4[%arg12 + %arg9 * 16, %arg13 + %arg6 * 16, %arg7, %arg8] : memref<64x64x3x3xi8, 12>
                        affine.store %8, %6[%arg12, %arg13, 0, 0] : memref<16x16x1x1xi8, 7>
                      } {parallel}
                    } {parallel}
                    %7 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x16x14x14xi8, 7>
                    affine.for %arg12 = 0 to 16 {
                      affine.for %arg13 = 0 to 14 {
                        affine.for %arg14 = 0 to 14 {
                          %8 = affine.load %0[0, %arg12 + %arg9 * 16, %arg13 + %arg10 * 14, %arg14 + %arg11 * 14] : memref<1x64x28x28xi8, 12>
                          affine.store %8, %7[0, %arg12, %arg13, %arg14] : memref<1x16x14x14xi8, 7>
                        } {parallel}
                      } {parallel}
                    } {parallel}
                    affine.for %arg12 = 0 to 16 {
                      affine.for %arg13 = 0 to 16 {
                        affine.for %arg14 = 0 to 14 {
                          affine.for %arg15 = 0 to 14 {
                            %8 = affine.load %5[0, %arg12, %arg14, %arg15] : memref<1x16x14x14xi8, 7>
                            %9 = affine.load %6[%arg13, %arg12, 0, 0] : memref<16x16x1x1xi8, 7>
                            %10 = affine.load %7[0, %arg13, %arg14, %arg15] : memref<1x16x14x14xi8, 7>
                            %11 = arith.muli %8, %9 : i8
                            %12 = arith.addi %10, %11 : i8
                            affine.store %12, %7[0, %arg13, %arg14, %arg15] : memref<1x16x14x14xi8, 7>
                            %13 = affine.load %7[0, %arg13, %arg14, %arg15] : memref<1x16x14x14xi8, 7>
                            %14 = arith.cmpi ugt, %13, %c-24_i8 : i8
                            %15 = arith.select %14, %13, %c-24_i8 : i8
                            affine.if #set(%arg7, %arg8, %arg12, %arg6) {
                              affine.store %15, %7[0, %arg13, %arg14, %arg15] : memref<1x16x14x14xi8, 7>
                            }
                          } {parallel, point}
                        } {parallel, point}
                      } {parallel, point}
                    } {point}
                    affine.for %arg12 = 0 to 16 {
                      affine.for %arg13 = 0 to 14 {
                        affine.for %arg14 = 0 to 14 {
                          %8 = affine.load %7[0, %arg12, %arg13, %arg14] : memref<1x16x14x14xi8, 7>
                          affine.store %8, %0[0, %arg12 + %arg9 * 16, %arg13 + %arg10 * 14, %arg14 + %arg11 * 14] : memref<1x64x28x28xi8, 12>
                        } {parallel}
                      } {parallel}
                    } {parallel}
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
                    %5 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x16x14x14xi8, 7>
                    affine.for %arg12 = 0 to 16 {
                      affine.for %arg13 = 0 to 14 {
                        affine.for %arg14 = 0 to 14 {
                          %8 = affine.load %0[0, %arg12 + %arg6 * 16, %arg13 + %arg7 + %arg10 * 14 - 1, %arg14 + %arg8 + %arg11 * 14 - 1] : memref<1x64x28x28xi8, 12>
                          affine.store %8, %5[0, %arg12, %arg13, %arg14] : memref<1x16x14x14xi8, 7>
                        } {parallel}
                      } {parallel}
                    } {parallel}
                    %6 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16x1x1xi8, 7>
                    affine.for %arg12 = 0 to 16 {
                      affine.for %arg13 = 0 to 16 {
                        %8 = affine.load %arg3[%arg12 + %arg9 * 16, %arg13 + %arg6 * 16, %arg7, %arg8] : memref<64x64x3x3xi8, 12>
                        affine.store %8, %6[%arg12, %arg13, 0, 0] : memref<16x16x1x1xi8, 7>
                      } {parallel}
                    } {parallel}
                    %7 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x16x14x14xi8, 7>
                    affine.for %arg12 = 0 to 16 {
                      affine.for %arg13 = 0 to 14 {
                        affine.for %arg14 = 0 to 14 {
                          %8 = affine.load %1[0, %arg12 + %arg9 * 16, %arg13 + %arg10 * 14, %arg14 + %arg11 * 14] : memref<1x64x28x28xi8, 12>
                          affine.store %8, %7[0, %arg12, %arg13, %arg14] : memref<1x16x14x14xi8, 7>
                        } {parallel}
                      } {parallel}
                    } {parallel}
                    affine.for %arg12 = 0 to 16 {
                      affine.for %arg13 = 0 to 16 {
                        affine.for %arg14 = 0 to 14 {
                          affine.for %arg15 = 0 to 14 {
                            %8 = affine.load %5[0, %arg12, %arg14, %arg15] : memref<1x16x14x14xi8, 7>
                            %9 = affine.load %6[%arg13, %arg12, 0, 0] : memref<16x16x1x1xi8, 7>
                            %10 = affine.load %7[0, %arg13, %arg14, %arg15] : memref<1x16x14x14xi8, 7>
                            %11 = arith.muli %8, %9 : i8
                            %12 = arith.addi %10, %11 : i8
                            affine.store %12, %7[0, %arg13, %arg14, %arg15] : memref<1x16x14x14xi8, 7>
                          } {parallel, point}
                        } {parallel, point}
                      } {parallel, point}
                    } {point}
                    affine.for %arg12 = 0 to 16 {
                      affine.for %arg13 = 0 to 14 {
                        affine.for %arg14 = 0 to 14 {
                          %8 = affine.load %7[0, %arg12, %arg13, %arg14] : memref<1x16x14x14xi8, 7>
                          affine.store %8, %1[0, %arg12 + %arg9 * 16, %arg13 + %arg10 * 14, %arg14 + %arg11 * 14] : memref<1x64x28x28xi8, 12>
                        } {parallel}
                      } {parallel}
                    } {parallel}
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
                %5 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x16x14x14xi8, 7>
                affine.for %arg10 = 0 to 16 {
                  affine.for %arg11 = 0 to 14 {
                    affine.for %arg12 = 0 to 14 {
                      %10 = affine.load %arg0[0, %arg10 + %arg6 * 16, %arg11 * 2 + %arg8 * 28, %arg12 * 2 + %arg9 * 28] : memref<1x64x56x56xi8, 12>
                      affine.store %10, %5[0, %arg10, %arg11, %arg12] : memref<1x16x14x14xi8, 7>
                    } {parallel}
                  } {parallel}
                } {parallel}
                %6 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16x1x1xi8, 7>
                affine.for %arg10 = 0 to 16 {
                  affine.for %arg11 = 0 to 16 {
                    %10 = affine.load %arg2[%arg10 + %arg7 * 16, %arg11 + %arg6 * 16, 0, 0] : memref<64x64x1x1xi8, 12>
                    affine.store %10, %6[%arg10, %arg11, 0, 0] : memref<16x16x1x1xi8, 7>
                  } {parallel}
                } {parallel}
                %7 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x16x14x14xi8, 7>
                affine.for %arg10 = 0 to 16 {
                  affine.for %arg11 = 0 to 14 {
                    affine.for %arg12 = 0 to 14 {
                      %10 = affine.load %3[0, %arg10 + %arg7 * 16, %arg11 + %arg8 * 14, %arg12 + %arg9 * 14] : memref<1x64x28x28xi8, 12>
                      affine.store %10, %7[0, %arg10, %arg11, %arg12] : memref<1x16x14x14xi8, 7>
                    } {parallel}
                  } {parallel}
                } {parallel}
                %8 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x16x14x14xi8, 7>
                affine.for %arg10 = 0 to 16 {
                  affine.for %arg11 = 0 to 14 {
                    affine.for %arg12 = 0 to 14 {
                      %10 = affine.load %1[0, %arg10 + %arg7 * 16, %arg11 + %arg8 * 14, %arg12 + %arg9 * 14] : memref<1x64x28x28xi8, 12>
                      affine.store %10, %8[0, %arg10, %arg11, %arg12] : memref<1x16x14x14xi8, 7>
                    } {parallel}
                  } {parallel}
                } {parallel}
                %9 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x16x14x14xi8, 7>
                affine.for %arg10 = 0 to 16 {
                  affine.for %arg11 = 0 to 16 {
                    affine.for %arg12 = 0 to 14 {
                      affine.for %arg13 = 0 to 14 {
                        %10 = affine.load %5[0, %arg10, %arg12, %arg13] : memref<1x16x14x14xi8, 7>
                        %11 = affine.load %6[%arg11, %arg10, 0, 0] : memref<16x16x1x1xi8, 7>
                        %12 = affine.load %7[0, %arg11, %arg12, %arg13] : memref<1x16x14x14xi8, 7>
                        %13 = arith.muli %10, %11 : i8
                        %14 = arith.addi %12, %13 : i8
                        affine.store %14, %7[0, %arg11, %arg12, %arg13] : memref<1x16x14x14xi8, 7>
                        %15 = affine.load %8[0, %arg11, %arg12, %arg13] : memref<1x16x14x14xi8, 7>
                        %16 = affine.load %7[0, %arg11, %arg12, %arg13] : memref<1x16x14x14xi8, 7>
                        %17 = arith.addi %15, %16 : i8
                        %18 = arith.cmpi ugt, %17, %c-24_i8 : i8
                        %19 = arith.select %18, %17, %c-24_i8 : i8
                        affine.if #set1(%arg10, %arg6) {
                          affine.store %19, %9[0, %arg11, %arg12, %arg13] : memref<1x16x14x14xi8, 7>
                        }
                      } {parallel, point}
                    } {parallel, point}
                  } {parallel, point}
                } {point}
                affine.for %arg10 = 0 to 16 {
                  affine.for %arg11 = 0 to 14 {
                    affine.for %arg12 = 0 to 14 {
                      %10 = affine.load %7[0, %arg10, %arg11, %arg12] : memref<1x16x14x14xi8, 7>
                      affine.store %10, %3[0, %arg10 + %arg7 * 16, %arg11 + %arg8 * 14, %arg12 + %arg9 * 14] : memref<1x64x28x28xi8, 12>
                    } {parallel}
                  } {parallel}
                } {parallel}
                affine.for %arg10 = 0 to 16 {
                  affine.for %arg11 = 0 to 14 {
                    affine.for %arg12 = 0 to 14 {
                      %10 = affine.load %9[0, %arg10, %arg11, %arg12] : memref<1x16x14x14xi8, 7>
                      affine.store %10, %2[0, %arg10 + %arg7 * 16, %arg11 + %arg8 * 14, %arg12 + %arg9 * 14] : memref<1x64x28x28xi8, 12>
                    } {parallel}
                  } {parallel}
                } {parallel}
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
              %5 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x16x14x14xi8, 7>
              affine.for %arg9 = 0 to 16 {
                affine.for %arg10 = 0 to 14 {
                  affine.for %arg11 = 0 to 14 {
                    %6 = affine.load %2[0, %arg9 + %arg8 * 16, %arg10 + %arg6 * 14, %arg11 + %arg7 * 14] : memref<1x64x28x28xi8, 12>
                    affine.store %6, %5[0, %arg9, %arg10, %arg11] : memref<1x16x14x14xi8, 7>
                  } {parallel}
                } {parallel}
              } {parallel}
              affine.for %arg9 = 0 to 14 {
                affine.for %arg10 = 0 to 14 {
                  affine.for %arg11 = 0 to 16 {
                    %6 = affine.load %5[0, %arg11, %arg9, %arg10] : memref<1x16x14x14xi8, 7>
                    %7 = affine.load %4[0, %arg11 + %arg8 * 16, 0, 0] : memref<1x64x1x1xi8, 7>
                    %8 = arith.addi %7, %6 : i8
                    affine.store %8, %4[0, %arg11 + %arg8 * 16, 0, 0] : memref<1x64x1x1xi8, 7>
                    %9 = affine.load %4[0, %arg11 + %arg8 * 16, 0, 0] : memref<1x64x1x1xi8, 7>
                    %10 = arith.divui %9, %c-24_i8 : i8
                    affine.if #set2(%arg9, %arg10, %arg6, %arg7) {
                      affine.store %10, %4[0, %arg11 + %arg8 * 16, 0, 0] : memref<1x64x1x1xi8, 7>
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
            %5 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x10xi8, 7>
            affine.for %arg8 = 0 to 10 {
              %7 = affine.load %arg5[0, %arg8 + %arg7 * 10] : memref<1x1000xi8, 12>
              affine.store %7, %5[0, %arg8] : memref<1x10xi8, 7>
            } {parallel}
            %6 = hls.dataflow.buffer {depth = 1 : i32} : memref<10x16xi8, 7>
            affine.for %arg8 = 0 to 10 {
              affine.for %arg9 = 0 to 16 {
                %7 = affine.load %arg1[%arg8 + %arg7 * 10, %arg9 + %arg6 * 16] : memref<1000x64xi8, 12>
                affine.store %7, %6[%arg8, %arg9] : memref<10x16xi8, 7>
              } {parallel}
            } {parallel}
            affine.for %arg8 = 0 to 16 {
              affine.for %arg9 = 0 to 10 {
                affine.if #set3(%arg8, %arg6) {
                  affine.store %c-24_i8, %5[0, %arg9] : memref<1x10xi8, 7>
                }
                %7 = affine.load %4[0, %arg8 + %arg6 * 16, 0, 0] : memref<1x64x1x1xi8, 7>
                %8 = affine.load %6[%arg9, %arg8] : memref<10x16xi8, 7>
                %9 = affine.load %5[0, %arg9] : memref<1x10xi8, 7>
                %10 = arith.muli %7, %8 : i8
                %11 = arith.addi %9, %10 : i8
                affine.store %11, %5[0, %arg9] : memref<1x10xi8, 7>
              } {parallel, point}
            } {point}
            affine.for %arg8 = 0 to 10 {
              %7 = affine.load %5[0, %arg8] : memref<1x10xi8, 7>
              affine.store %7, %arg5[0, %arg8 + %arg7 * 10] : memref<1x1000xi8, 12>
            } {parallel}
          } {parallel}
        }
      }
    }
    return
  }
}

