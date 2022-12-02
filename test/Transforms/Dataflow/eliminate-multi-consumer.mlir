// RUN: scalehls-opt -scalehls-eliminate-multi-consumer %s | FileCheck %s
// XFAIL: *

// CHECK: #set = affine_set<(d0) : (d0 == 0)>
// CHECK: #set1 = affine_set<(d0, d1, d2, d3) : (-d2 - d3 * 16 + 63 == 0, -d0 + 2 == 0, -d1 + 2 == 0)>
// CHECK: #set2 = affine_set<(d0)[s0] : (-d0 - s0 * 16 + 63 == 0)>
// CHECK: #set3 = affine_set<(d0, d1, d2, d3) : (-d0 - d2 * 14 + 27 == 0, -d1 - d3 * 14 + 27 == 0)>
// CHECK: #set4 = affine_set<(d0, d1) : (d0 + d1 * 16 == 0)>
// CHECK: module attributes {torch.debug_module_name = "ResNet"} {
// CHECK:   func.func @forward(%arg0: memref<64x56x56xi8, 12>, %arg1: memref<1000x64xi8, 12>, %arg2: memref<64x64xi8, 12>, %arg3: memref<64x64x3x3xi8, 12>, %arg4: memref<64x64x3x3xi8, 12>, %arg5: memref<1000xi8, 12>) attributes {top_func} {
// CHECK:     hls.dataflow.schedule(%arg2, %arg5, %arg3, %arg1, %arg0, %arg4) : memref<64x64xi8, 12>, memref<1000xi8, 12>, memref<64x64x3x3xi8, 12>, memref<1000x64xi8, 12>, memref<64x56x56xi8, 12>, memref<64x64x3x3xi8, 12> {
// CHECK:     ^bb0(%arg6: memref<64x64xi8, 12>, %arg7: memref<1000xi8, 12>, %arg8: memref<64x64x3x3xi8, 12>, %arg9: memref<1000x64xi8, 12>, %arg10: memref<64x56x56xi8, 12>, %arg11: memref<64x64x3x3xi8, 12>):
// CHECK:       hls.dataflow.node() -> (%arg10) {inputTaps = []} : () -> memref<64x56x56xi8, 12> {
// CHECK:       ^bb0(%arg12: memref<64x56x56xi8, 12>):
// CHECK:         affine.for %arg13 = 0 to 4 {
// CHECK:           affine.for %arg14 = 0 to 4 {
// CHECK:             affine.for %arg15 = 0 to 4 {
// CHECK:               hls.dataflow.schedule(%arg13, %arg15, %arg12, %arg14) : index, index, memref<64x56x56xi8, 12>, index {
// CHECK:               ^bb0(%arg16: index, %arg17: index, %arg18: memref<64x56x56xi8, 12>, %arg19: index):
// CHECK:                 %7 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
// CHECK:                 hls.dataflow.node(%arg18) -> (%7) [%arg16, %arg19, %arg17] {inputTaps = [0 : i32]} : (memref<64x56x56xi8, 12>) -> memref<16x14x14xi8, 7>[index, index, index] {
// CHECK:                 ^bb0(%arg20: memref<64x56x56xi8, 12>, %arg21: memref<16x14x14xi8, 7>, %arg22: index, %arg23: index, %arg24: index):
// CHECK:                   affine.for %arg25 = 0 to 16 {
// CHECK:                     affine.for %arg26 = 0 to 14 {
// CHECK:                       affine.for %arg27 = 0 to 14 {
// CHECK:                         %9 = affine.load %arg20[%arg25 + %arg22 * 16, %arg26 + %arg23 * 14, %arg27 + %arg24 * 14] : memref<64x56x56xi8, 12>
// CHECK:                         affine.store %9, %arg21[%arg25, %arg26, %arg27] : memref<16x14x14xi8, 7>
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   } {parallel}
// CHECK:                 }
// CHECK:                 %8 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
// CHECK:                 hls.dataflow.node(%7) -> (%8) {inputTaps = [0 : i32]} : (memref<16x14x14xi8, 7>) -> memref<16x14x14xi8, 7> {
// CHECK:                 ^bb0(%arg20: memref<16x14x14xi8, 7>, %arg21: memref<16x14x14xi8, 7>):
// CHECK:                   %c-24_i8 = arith.constant -24 : i8
// CHECK:                   affine.for %arg22 = 0 to 16 {
// CHECK:                     affine.for %arg23 = 0 to 14 {
// CHECK:                       affine.for %arg24 = 0 to 14 {
// CHECK:                         %9 = affine.load %arg20[%arg22, %arg23, %arg24] : memref<16x14x14xi8, 7>
// CHECK:                         affine.store %9, %arg21[%arg22, %arg23, %arg24] : memref<16x14x14xi8, 7>
// CHECK:                         %10 = affine.load %arg21[%arg22, %arg23, %arg24] : memref<16x14x14xi8, 7>
// CHECK:                         %11 = arith.cmpi ugt, %10, %c-24_i8 : i8
// CHECK:                         %12 = arith.select %11, %10, %c-24_i8 : i8
// CHECK:                         affine.store %12, %arg21[%arg22, %arg23, %arg24] : memref<16x14x14xi8, 7>
// CHECK:                       } {parallel, point}
// CHECK:                     } {parallel, point}
// CHECK:                   } {parallel, point}
// CHECK:                 }
// CHECK:                 hls.dataflow.node(%8) -> (%arg18) [%arg16, %arg19, %arg17] {inputTaps = [0 : i32]} : (memref<16x14x14xi8, 7>) -> memref<64x56x56xi8, 12>[index, index, index] {
// CHECK:                 ^bb0(%arg20: memref<16x14x14xi8, 7>, %arg21: memref<64x56x56xi8, 12>, %arg22: index, %arg23: index, %arg24: index):
// CHECK:                   affine.for %arg25 = 0 to 16 {
// CHECK:                     affine.for %arg26 = 0 to 14 {
// CHECK:                       affine.for %arg27 = 0 to 14 {
// CHECK:                         %9 = affine.load %arg20[%arg25, %arg26, %arg27] : memref<16x14x14xi8, 7>
// CHECK:                         affine.store %9, %arg21[%arg25 + %arg22 * 16, %arg26 + %arg23 * 14, %arg27 + %arg24 * 14] : memref<64x56x56xi8, 12>
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   } {parallel}
// CHECK:                 }
// CHECK:               }
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:       }
// CHECK:       %0 = hls.dataflow.buffer {depth = 1 : i32} : memref<64x56x56xi8, 12>
// CHECK:       %1 = hls.dataflow.buffer {depth = 1 : i32} : memref<64x56x56xi8, 12>
// CHECK:       hls.dataflow.node(%arg10) -> (%0, %1) {inputTaps = [0 : i32]} : (memref<64x56x56xi8, 12>) -> (memref<64x56x56xi8, 12>, memref<64x56x56xi8, 12>) {
// CHECK:       ^bb0(%arg12: memref<64x56x56xi8, 12>, %arg13: memref<64x56x56xi8, 12>, %arg14: memref<64x56x56xi8, 12>):
// CHECK:         memref.copy %arg12, %arg13 : memref<64x56x56xi8, 12> to memref<64x56x56xi8, 12>
// CHECK:         memref.copy %arg12, %arg14 : memref<64x56x56xi8, 12> to memref<64x56x56xi8, 12>
// CHECK:       }
// CHECK:       %2 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, 12>
// CHECK:       hls.dataflow.node(%1, %arg11) -> (%2) {inputTaps = [0 : i32, 0 : i32]} : (memref<64x56x56xi8, 12>, memref<64x64x3x3xi8, 12>) -> memref<64x28x28xi8, 12> {
// CHECK:       ^bb0(%arg12: memref<64x56x56xi8, 12>, %arg13: memref<64x64x3x3xi8, 12>, %arg14: memref<64x28x28xi8, 12>):
// CHECK:         affine.for %arg15 = 0 to 4 {
// CHECK:           affine.for %arg16 = 0 to 3 {
// CHECK:             affine.for %arg17 = 0 to 3 {
// CHECK:               affine.for %arg18 = 0 to 4 {
// CHECK:                 affine.for %arg19 = 0 to 2 {
// CHECK:                   affine.for %arg20 = 0 to 2 {
// CHECK:                     hls.dataflow.schedule(%arg17, %arg14, %arg20, %arg16, %arg19, %arg12, %arg15, %arg13, %arg18) : index, memref<64x28x28xi8, 12>, index, index, index, memref<64x56x56xi8, 12>, index, memref<64x64x3x3xi8, 12>, index {
// CHECK:                     ^bb0(%arg21: index, %arg22: memref<64x28x28xi8, 12>, %arg23: index, %arg24: index, %arg25: index, %arg26: memref<64x56x56xi8, 12>, %arg27: index, %arg28: memref<64x64x3x3xi8, 12>, %arg29: index):
// CHECK:                       %7 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, 7>
// CHECK:                       %8 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, 7>
// CHECK:                       %9 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
// CHECK:                       hls.dataflow.node(%arg26) -> (%9) [%arg27, %arg24, %arg25, %arg21, %arg23] {inputTaps = [0 : i32]} : (memref<64x56x56xi8, 12>) -> memref<16x14x14xi8, 7>[index, index, index, index, index] {
// CHECK:                       ^bb0(%arg30: memref<64x56x56xi8, 12>, %arg31: memref<16x14x14xi8, 7>, %arg32: index, %arg33: index, %arg34: index, %arg35: index, %arg36: index):
// CHECK:                         affine.for %arg37 = 0 to 16 {
// CHECK:                           affine.for %arg38 = 0 to 14 {
// CHECK:                             affine.for %arg39 = 0 to 14 {
// CHECK:                               %11 = affine.load %arg30[%arg37 + %arg32 * 16, %arg38 * 2 + %arg33 + %arg34 * 28 - 1, %arg39 * 2 + %arg35 + %arg36 * 28 - 1] : memref<64x56x56xi8, 12>
// CHECK:                               affine.store %11, %arg31[%arg37, %arg38, %arg39] : memref<16x14x14xi8, 7>
// CHECK:                             } {parallel}
// CHECK:                           } {parallel}
// CHECK:                         } {parallel}
// CHECK:                       }
// CHECK:                       hls.dataflow.node(%arg28) -> (%8) [%arg29, %arg27, %arg24, %arg21] {inputTaps = [0 : i32]} : (memref<64x64x3x3xi8, 12>) -> memref<16x16xi8, 7>[index, index, index, index] {
// CHECK:                       ^bb0(%arg30: memref<64x64x3x3xi8, 12>, %arg31: memref<16x16xi8, 7>, %arg32: index, %arg33: index, %arg34: index, %arg35: index):
// CHECK:                         affine.for %arg36 = 0 to 16 {
// CHECK:                           affine.for %arg37 = 0 to 16 {
// CHECK:                             %11 = affine.load %arg30[%arg36 + %arg32 * 16, %arg37 + %arg33 * 16, %arg34, %arg35] : memref<64x64x3x3xi8, 12>
// CHECK:                             affine.store %11, %arg31[%arg36, %arg37] : memref<16x16xi8, 7>
// CHECK:                           } {parallel}
// CHECK:                         } {parallel}
// CHECK:                       }
// CHECK:                       hls.dataflow.node(%arg22) -> (%7) [%arg29, %arg25, %arg23] {inputTaps = [0 : i32]} : (memref<64x28x28xi8, 12>) -> memref<16x14x14xi8, 7>[index, index, index] {
// CHECK:                       ^bb0(%arg30: memref<64x28x28xi8, 12>, %arg31: memref<16x14x14xi8, 7>, %arg32: index, %arg33: index, %arg34: index):
// CHECK:                         affine.for %arg35 = 0 to 16 {
// CHECK:                           affine.for %arg36 = 0 to 14 {
// CHECK:                             affine.for %arg37 = 0 to 14 {
// CHECK:                               %11 = affine.load %arg30[%arg35 + %arg32 * 16, %arg36 + %arg33 * 14, %arg37 + %arg34 * 14] : memref<64x28x28xi8, 12>
// CHECK:                               affine.store %11, %arg31[%arg35, %arg36, %arg37] : memref<16x14x14xi8, 7>
// CHECK:                             } {parallel}
// CHECK:                           } {parallel}
// CHECK:                         } {parallel}
// CHECK:                       }
// CHECK:                       %10 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
// CHECK:                       hls.dataflow.node(%9, %8, %7) -> (%10) [%arg21, %arg27, %arg24] {inputTaps = [0 : i32, 0 : i32, 0 : i32]} : (memref<16x14x14xi8, 7>, memref<16x16xi8, 7>, memref<16x14x14xi8, 7>) -> memref<16x14x14xi8, 7>[index, index, index] {
// CHECK:                       ^bb0(%arg30: memref<16x14x14xi8, 7>, %arg31: memref<16x16xi8, 7>, %arg32: memref<16x14x14xi8, 7>, %arg33: memref<16x14x14xi8, 7>, %arg34: index, %arg35: index, %arg36: index):
// CHECK:                         %c-24_i8 = arith.constant -24 : i8
// CHECK:                         affine.for %arg37 = 0 to 16 {
// CHECK:                           affine.for %arg38 = 0 to 16 {
// CHECK:                             affine.for %arg39 = 0 to 14 {
// CHECK:                               affine.for %arg40 = 0 to 14 {
// CHECK:                                 %11 = affine.load %arg30[%arg37, %arg39, %arg40] : memref<16x14x14xi8, 7>
// CHECK:                                 %12 = affine.load %arg31[%arg38, %arg37] : memref<16x16xi8, 7>
// CHECK:                                 %13 = affine.load %arg32[%arg38, %arg39, %arg40] : memref<16x14x14xi8, 7>
// CHECK:                                 affine.if #set(%arg37) {
// CHECK:                                   affine.store %13, %arg33[%arg38, %arg39, %arg40] : memref<16x14x14xi8, 7>
// CHECK:                                 }
// CHECK:                                 %14 = affine.load %arg33[%arg38, %arg39, %arg40] : memref<16x14x14xi8, 7>
// CHECK:                                 %15 = arith.muli %11, %12 : i8
// CHECK:                                 %16 = arith.addi %14, %15 : i8
// CHECK:                                 %17 = arith.cmpi ugt, %16, %c-24_i8 : i8
// CHECK:                                 %18 = arith.select %17, %16, %c-24_i8 : i8
// CHECK:                                 %19 = hls.affine.select #set1(%arg36, %arg34, %arg37, %arg35) %18, %16 : i8
// CHECK:                                 affine.store %19, %arg33[%arg38, %arg39, %arg40] : memref<16x14x14xi8, 7>
// CHECK:                               } {parallel, point}
// CHECK:                             } {parallel, point}
// CHECK:                           } {parallel, point}
// CHECK:                         } {point}
// CHECK:                       }
// CHECK:                       hls.dataflow.node(%10) -> (%arg22) [%arg29, %arg25, %arg23] {inputTaps = [0 : i32]} : (memref<16x14x14xi8, 7>) -> memref<64x28x28xi8, 12>[index, index, index] {
// CHECK:                       ^bb0(%arg30: memref<16x14x14xi8, 7>, %arg31: memref<64x28x28xi8, 12>, %arg32: index, %arg33: index, %arg34: index):
// CHECK:                         affine.for %arg35 = 0 to 16 {
// CHECK:                           affine.for %arg36 = 0 to 14 {
// CHECK:                             affine.for %arg37 = 0 to 14 {
// CHECK:                               %11 = affine.load %arg30[%arg35, %arg36, %arg37] : memref<16x14x14xi8, 7>
// CHECK:                               affine.store %11, %arg31[%arg35 + %arg32 * 16, %arg36 + %arg33 * 14, %arg37 + %arg34 * 14] : memref<64x28x28xi8, 12>
// CHECK:                             } {parallel}
// CHECK:                           } {parallel}
// CHECK:                         } {parallel}
// CHECK:                       }
// CHECK:                     }
// CHECK:                   } {parallel}
// CHECK:                 } {parallel}
// CHECK:               } {parallel}
// CHECK:             }
// CHECK:           }
// CHECK:         }
// CHECK:       }
// CHECK:       %3 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, 12>
// CHECK:       hls.dataflow.node(%arg8, %2) -> (%3) {inputTaps = [0 : i32, 0 : i32]} : (memref<64x64x3x3xi8, 12>, memref<64x28x28xi8, 12>) -> memref<64x28x28xi8, 12> {
// CHECK:       ^bb0(%arg12: memref<64x64x3x3xi8, 12>, %arg13: memref<64x28x28xi8, 12>, %arg14: memref<64x28x28xi8, 12>):
// CHECK:         affine.for %arg15 = 0 to 4 {
// CHECK:           affine.for %arg16 = 0 to 3 {
// CHECK:             affine.for %arg17 = 0 to 3 {
// CHECK:               affine.for %arg18 = 0 to 4 {
// CHECK:                 affine.for %arg19 = 0 to 2 {
// CHECK:                   affine.for %arg20 = 0 to 2 {
// CHECK:                     hls.dataflow.schedule(%arg20, %arg16, %arg15, %arg17, %arg19, %arg14, %arg12, %arg13, %arg18) : index, index, index, index, index, memref<64x28x28xi8, 12>, memref<64x64x3x3xi8, 12>, memref<64x28x28xi8, 12>, index {
// CHECK:                     ^bb0(%arg21: index, %arg22: index, %arg23: index, %arg24: index, %arg25: index, %arg26: memref<64x28x28xi8, 12>, %arg27: memref<64x64x3x3xi8, 12>, %arg28: memref<64x28x28xi8, 12>, %arg29: index):
// CHECK:                       %7 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, 7>
// CHECK:                       %8 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, 7>
// CHECK:                       %9 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, 7>
// CHECK:                       hls.dataflow.node(%arg28) -> (%9) [%arg23, %arg22, %arg25, %arg24, %arg21] {inputTaps = [0 : i32]} : (memref<64x28x28xi8, 12>) -> memref<16x14x14xi8, 7>[index, index, index, index, index] {
// CHECK:                       ^bb0(%arg30: memref<64x28x28xi8, 12>, %arg31: memref<16x14x14xi8, 7>, %arg32: index, %arg33: index, %arg34: index, %arg35: index, %arg36: index):
// CHECK:                         affine.for %arg37 = 0 to 16 {
// CHECK:                           affine.for %arg38 = 0 to 14 {
// CHECK:                             affine.for %arg39 = 0 to 14 {
// CHECK:                               %11 = affine.load %arg30[%arg37 + %arg32 * 16, %arg38 + %arg33 + %arg34 * 14 - 1, %arg39 + %arg35 + %arg36 * 14 - 1] : memref<64x28x28xi8, 12>
// CHECK:                               affine.store %11, %arg31[%arg37, %arg38, %arg39] : memref<16x14x14xi8, 7>
// CHECK:                             } {parallel}
// CHECK:                           } {parallel}
// CHECK:                         } {parallel}
// CHECK:                       }
// CHECK:                       hls.dataflow.node(%arg27) -> (%8) [%arg29, %arg23, %arg22, %arg24] {inputTaps = [0 : i32]} : (memref<64x64x3x3xi8, 12>) -> memref<16x16xi8, 7>[index, index, index, index] {
// CHECK:                       ^bb0(%arg30: memref<64x64x3x3xi8, 12>, %arg31: memref<16x16xi8, 7>, %arg32: index, %arg33: index, %arg34: index, %arg35: index):
// CHECK:                         affine.for %arg36 = 0 to 16 {
// CHECK:                           affine.for %arg37 = 0 to 16 {
// CHECK:                             %11 = affine.load %arg30[%arg36 + %arg32 * 16, %arg37 + %arg33 * 16, %arg34, %arg35] : memref<64x64x3x3xi8, 12>
// CHECK:                             affine.store %11, %arg31[%arg36, %arg37] : memref<16x16xi8, 7>
// CHECK:                           } {parallel}
// CHECK:                         } {parallel}
// CHECK:                       }
// CHECK:                       hls.dataflow.node(%arg26) -> (%7) [%arg29, %arg25, %arg21] {inputTaps = [0 : i32]} : (memref<64x28x28xi8, 12>) -> memref<16x14x14xi8, 7>[index, index, index] {
// CHECK:                       ^bb0(%arg30: memref<64x28x28xi8, 12>, %arg31: memref<16x14x14xi8, 7>, %arg32: index, %arg33: index, %arg34: index):
// CHECK:                         affine.for %arg35 = 0 to 16 {
// CHECK:                           affine.for %arg36 = 0 to 14 {
// CHECK:                             affine.for %arg37 = 0 to 14 {
// CHECK:                               %11 = affine.load %arg30[%arg35 + %arg32 * 16, %arg36 + %arg33 * 14, %arg37 + %arg34 * 14] : memref<64x28x28xi8, 12>
// CHECK:                               affine.store %11, %arg31[%arg35, %arg36, %arg37] : memref<16x14x14xi8, 7>
// CHECK:                             } {parallel}
// CHECK:                           } {parallel}
// CHECK:                         } {parallel}
// CHECK:                       }
// CHECK:                       %10 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
// CHECK:                       hls.dataflow.node(%9, %8, %7) -> (%10) {inputTaps = [0 : i32, 0 : i32, 0 : i32]} : (memref<16x14x14xi8, 7>, memref<16x16xi8, 7>, memref<16x14x14xi8, 7>) -> memref<16x14x14xi8, 7> {
// CHECK:                       ^bb0(%arg30: memref<16x14x14xi8, 7>, %arg31: memref<16x16xi8, 7>, %arg32: memref<16x14x14xi8, 7>, %arg33: memref<16x14x14xi8, 7>):
// CHECK:                         affine.for %arg34 = 0 to 16 {
// CHECK:                           affine.for %arg35 = 0 to 16 {
// CHECK:                             affine.for %arg36 = 0 to 14 {
// CHECK:                               affine.for %arg37 = 0 to 14 {
// CHECK:                                 %11 = affine.load %arg30[%arg34, %arg36, %arg37] : memref<16x14x14xi8, 7>
// CHECK:                                 %12 = affine.load %arg31[%arg35, %arg34] : memref<16x16xi8, 7>
// CHECK:                                 %13 = affine.load %arg32[%arg35, %arg36, %arg37] : memref<16x14x14xi8, 7>
// CHECK:                                 affine.if #set(%arg34) {
// CHECK:                                   affine.store %13, %arg33[%arg35, %arg36, %arg37] : memref<16x14x14xi8, 7>
// CHECK:                                 }
// CHECK:                                 %14 = affine.load %arg33[%arg35, %arg36, %arg37] : memref<16x14x14xi8, 7>
// CHECK:                                 %15 = arith.muli %11, %12 : i8
// CHECK:                                 %16 = arith.addi %14, %15 : i8
// CHECK:                                 affine.store %16, %arg33[%arg35, %arg36, %arg37] : memref<16x14x14xi8, 7>
// CHECK:                               } {parallel, point}
// CHECK:                             } {parallel, point}
// CHECK:                           } {parallel, point}
// CHECK:                         } {point}
// CHECK:                       }
// CHECK:                       hls.dataflow.node(%10) -> (%arg26) [%arg29, %arg25, %arg21] {inputTaps = [0 : i32]} : (memref<16x14x14xi8, 7>) -> memref<64x28x28xi8, 12>[index, index, index] {
// CHECK:                       ^bb0(%arg30: memref<16x14x14xi8, 7>, %arg31: memref<64x28x28xi8, 12>, %arg32: index, %arg33: index, %arg34: index):
// CHECK:                         affine.for %arg35 = 0 to 16 {
// CHECK:                           affine.for %arg36 = 0 to 14 {
// CHECK:                             affine.for %arg37 = 0 to 14 {
// CHECK:                               %11 = affine.load %arg30[%arg35, %arg36, %arg37] : memref<16x14x14xi8, 7>
// CHECK:                               affine.store %11, %arg31[%arg35 + %arg32 * 16, %arg36 + %arg33 * 14, %arg37 + %arg34 * 14] : memref<64x28x28xi8, 12>
// CHECK:                             } {parallel}
// CHECK:                           } {parallel}
// CHECK:                         } {parallel}
// CHECK:                       }
// CHECK:                     }
// CHECK:                   } {parallel}
// CHECK:                 } {parallel}
// CHECK:               } {parallel}
// CHECK:             }
// CHECK:           }
// CHECK:         }
// CHECK:       }
// CHECK:       %4 = hls.dataflow.buffer {depth = 1 : i32} : memref<64x28x28xi8, 12>
// CHECK:       %5 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, 12>
// CHECK:       hls.dataflow.node(%0, %arg6, %3) -> (%4, %5) {inputTaps = [0 : i32, 0 : i32, 0 : i32]} : (memref<64x56x56xi8, 12>, memref<64x64xi8, 12>, memref<64x28x28xi8, 12>) -> (memref<64x28x28xi8, 12>, memref<64x28x28xi8, 12>) {
// CHECK:       ^bb0(%arg12: memref<64x56x56xi8, 12>, %arg13: memref<64x64xi8, 12>, %arg14: memref<64x28x28xi8, 12>, %arg15: memref<64x28x28xi8, 12>, %arg16: memref<64x28x28xi8, 12>):
// CHECK:         affine.for %arg17 = 0 to 4 {
// CHECK:           affine.for %arg18 = 0 to 4 {
// CHECK:             affine.for %arg19 = 0 to 2 {
// CHECK:               affine.for %arg20 = 0 to 2 {
// CHECK:                 hls.dataflow.schedule(%arg19, %arg20, %arg13, %arg14, %arg12, %arg17, %arg15, %arg16, %arg18) : index, index, memref<64x64xi8, 12>, memref<64x28x28xi8, 12>, memref<64x56x56xi8, 12>, index, memref<64x28x28xi8, 12>, memref<64x28x28xi8, 12>, index {
// CHECK:                 ^bb0(%arg21: index, %arg22: index, %arg23: memref<64x64xi8, 12>, %arg24: memref<64x28x28xi8, 12>, %arg25: memref<64x56x56xi8, 12>, %arg26: index, %arg27: memref<64x28x28xi8, 12>, %arg28: memref<64x28x28xi8, 12>, %arg29: index):
// CHECK:                   %7 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
// CHECK:                   %8 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, 7>
// CHECK:                   %9 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, 7>
// CHECK:                   %10 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, 7>
// CHECK:                   %11 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
// CHECK:                   hls.dataflow.node(%arg25) -> (%11) [%arg26, %arg21, %arg22] {inputTaps = [0 : i32]} : (memref<64x56x56xi8, 12>) -> memref<16x14x14xi8, 7>[index, index, index] {
// CHECK:                   ^bb0(%arg30: memref<64x56x56xi8, 12>, %arg31: memref<16x14x14xi8, 7>, %arg32: index, %arg33: index, %arg34: index):
// CHECK:                     affine.for %arg35 = 0 to 16 {
// CHECK:                       affine.for %arg36 = 0 to 14 {
// CHECK:                         affine.for %arg37 = 0 to 14 {
// CHECK:                           %13 = affine.load %arg30[%arg35 + %arg32 * 16, %arg36 * 2 + %arg33 * 28, %arg37 * 2 + %arg34 * 28] : memref<64x56x56xi8, 12>
// CHECK:                           affine.store %13, %arg31[%arg35, %arg36, %arg37] : memref<16x14x14xi8, 7>
// CHECK:                         } {parallel}
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   }
// CHECK:                   hls.dataflow.node(%arg23) -> (%10) [%arg29, %arg26] {inputTaps = [0 : i32]} : (memref<64x64xi8, 12>) -> memref<16x16xi8, 7>[index, index] {
// CHECK:                   ^bb0(%arg30: memref<64x64xi8, 12>, %arg31: memref<16x16xi8, 7>, %arg32: index, %arg33: index):
// CHECK:                     affine.for %arg34 = 0 to 16 {
// CHECK:                       affine.for %arg35 = 0 to 16 {
// CHECK:                         %13 = affine.load %arg30[%arg34 + %arg32 * 16, %arg35 + %arg33 * 16] : memref<64x64xi8, 12>
// CHECK:                         affine.store %13, %arg31[%arg34, %arg35] : memref<16x16xi8, 7>
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   }
// CHECK:                   hls.dataflow.node(%arg28) -> (%9) [%arg29, %arg21, %arg22] {inputTaps = [0 : i32]} : (memref<64x28x28xi8, 12>) -> memref<16x14x14xi8, 7>[index, index, index] {
// CHECK:                   ^bb0(%arg30: memref<64x28x28xi8, 12>, %arg31: memref<16x14x14xi8, 7>, %arg32: index, %arg33: index, %arg34: index):
// CHECK:                     affine.for %arg35 = 0 to 16 {
// CHECK:                       affine.for %arg36 = 0 to 14 {
// CHECK:                         affine.for %arg37 = 0 to 14 {
// CHECK:                           %13 = affine.load %arg30[%arg35 + %arg32 * 16, %arg36 + %arg33 * 14, %arg37 + %arg34 * 14] : memref<64x28x28xi8, 12>
// CHECK:                           affine.store %13, %arg31[%arg35, %arg36, %arg37] : memref<16x14x14xi8, 7>
// CHECK:                         } {parallel}
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   }
// CHECK:                   hls.dataflow.node(%arg24) -> (%8) [%arg29, %arg21, %arg22] {inputTaps = [0 : i32]} : (memref<64x28x28xi8, 12>) -> memref<16x14x14xi8, 7>[index, index, index] {
// CHECK:                   ^bb0(%arg30: memref<64x28x28xi8, 12>, %arg31: memref<16x14x14xi8, 7>, %arg32: index, %arg33: index, %arg34: index):
// CHECK:                     affine.for %arg35 = 0 to 16 {
// CHECK:                       affine.for %arg36 = 0 to 14 {
// CHECK:                         affine.for %arg37 = 0 to 14 {
// CHECK:                           %13 = affine.load %arg30[%arg35 + %arg32 * 16, %arg36 + %arg33 * 14, %arg37 + %arg34 * 14] : memref<64x28x28xi8, 12>
// CHECK:                           affine.store %13, %arg31[%arg35, %arg36, %arg37] : memref<16x14x14xi8, 7>
// CHECK:                         } {parallel}
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   }
// CHECK:                   %12 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
// CHECK:                   hls.dataflow.node(%8, %11, %10, %9) -> (%7, %12) [%arg26] {inputTaps = [0 : i32, 0 : i32, 0 : i32, 0 : i32]} : (memref<16x14x14xi8, 7>, memref<16x14x14xi8, 7>, memref<16x16xi8, 7>, memref<16x14x14xi8, 7>) -> (memref<16x14x14xi8, 7>, memref<16x14x14xi8, 7>)[index] {
// CHECK:                   ^bb0(%arg30: memref<16x14x14xi8, 7>, %arg31: memref<16x14x14xi8, 7>, %arg32: memref<16x16xi8, 7>, %arg33: memref<16x14x14xi8, 7>, %arg34: memref<16x14x14xi8, 7>, %arg35: memref<16x14x14xi8, 7>, %arg36: index):
// CHECK:                     %c-24_i8 = arith.constant -24 : i8
// CHECK:                     affine.for %arg37 = 0 to 16 {
// CHECK:                       affine.for %arg38 = 0 to 16 {
// CHECK:                         affine.for %arg39 = 0 to 14 {
// CHECK:                           affine.for %arg40 = 0 to 14 {
// CHECK:                             %13 = affine.load %arg31[%arg37, %arg39, %arg40] : memref<16x14x14xi8, 7>
// CHECK:                             %14 = affine.load %arg32[%arg38, %arg37] : memref<16x16xi8, 7>
// CHECK:                             %15 = affine.load %arg33[%arg38, %arg39, %arg40] : memref<16x14x14xi8, 7>
// CHECK:                             affine.if #set(%arg37) {
// CHECK:                               affine.store %15, %arg35[%arg38, %arg39, %arg40] : memref<16x14x14xi8, 7>
// CHECK:                             }
// CHECK:                             %16 = affine.load %arg35[%arg38, %arg39, %arg40] : memref<16x14x14xi8, 7>
// CHECK:                             %17 = arith.muli %13, %14 : i8
// CHECK:                             %18 = arith.addi %16, %17 : i8
// CHECK:                             affine.store %18, %arg35[%arg38, %arg39, %arg40] : memref<16x14x14xi8, 7>
// CHECK:                             %19 = affine.load %arg30[%arg38, %arg39, %arg40] : memref<16x14x14xi8, 7>
// CHECK:                             %20 = arith.addi %19, %18 : i8
// CHECK:                             %21 = arith.cmpi ugt, %20, %c-24_i8 : i8
// CHECK:                             %22 = arith.select %21, %20, %c-24_i8 : i8
// CHECK:                             affine.if #set2(%arg37)[%arg36] {
// CHECK:                               affine.store %22, %arg34[%arg38, %arg39, %arg40] : memref<16x14x14xi8, 7>
// CHECK:                             }
// CHECK:                           } {parallel, point}
// CHECK:                         } {parallel, point}
// CHECK:                       } {parallel, point}
// CHECK:                     } {point}
// CHECK:                   }
// CHECK:                   hls.dataflow.node(%12) -> (%arg28) [%arg29, %arg21, %arg22] {inputTaps = [0 : i32]} : (memref<16x14x14xi8, 7>) -> memref<64x28x28xi8, 12>[index, index, index] {
// CHECK:                   ^bb0(%arg30: memref<16x14x14xi8, 7>, %arg31: memref<64x28x28xi8, 12>, %arg32: index, %arg33: index, %arg34: index):
// CHECK:                     affine.for %arg35 = 0 to 16 {
// CHECK:                       affine.for %arg36 = 0 to 14 {
// CHECK:                         affine.for %arg37 = 0 to 14 {
// CHECK:                           %13 = affine.load %arg30[%arg35, %arg36, %arg37] : memref<16x14x14xi8, 7>
// CHECK:                           affine.store %13, %arg31[%arg35 + %arg32 * 16, %arg36 + %arg33 * 14, %arg37 + %arg34 * 14] : memref<64x28x28xi8, 12>
// CHECK:                         } {parallel}
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   }
// CHECK:                   hls.dataflow.node(%7) -> (%arg27) [%arg29, %arg21, %arg22] {inputTaps = [0 : i32]} : (memref<16x14x14xi8, 7>) -> memref<64x28x28xi8, 12>[index, index, index] {
// CHECK:                   ^bb0(%arg30: memref<16x14x14xi8, 7>, %arg31: memref<64x28x28xi8, 12>, %arg32: index, %arg33: index, %arg34: index):
// CHECK:                     affine.for %arg35 = 0 to 16 {
// CHECK:                       affine.for %arg36 = 0 to 14 {
// CHECK:                         affine.for %arg37 = 0 to 14 {
// CHECK:                           %13 = affine.load %arg30[%arg35, %arg36, %arg37] : memref<16x14x14xi8, 7>
// CHECK:                           affine.store %13, %arg31[%arg35 + %arg32 * 16, %arg36 + %arg33 * 14, %arg37 + %arg34 * 14] : memref<64x28x28xi8, 12>
// CHECK:                         } {parallel}
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   }
// CHECK:                 }
// CHECK:               } {parallel}
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         }
// CHECK:       }
// CHECK:       %6 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64xi8, 7>
// CHECK:       hls.dataflow.node(%4) -> (%6) {inputTaps = [0 : i32]} : (memref<64x28x28xi8, 12>) -> memref<64xi8, 7> {
// CHECK:       ^bb0(%arg12: memref<64x28x28xi8, 12>, %arg13: memref<64xi8, 7>):
// CHECK:         affine.for %arg14 = 0 to 2 {
// CHECK:           affine.for %arg15 = 0 to 2 {
// CHECK:             affine.for %arg16 = 0 to 4 {
// CHECK:               hls.dataflow.schedule(%arg12, %arg14, %arg13, %arg15, %arg16) : memref<64x28x28xi8, 12>, index, memref<64xi8, 7>, index, index {
// CHECK:               ^bb0(%arg17: memref<64x28x28xi8, 12>, %arg18: index, %arg19: memref<64xi8, 7>, %arg20: index, %arg21: index):
// CHECK:                 %7 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
// CHECK:                 hls.dataflow.node(%arg17) -> (%7) [%arg21, %arg18, %arg20] {inputTaps = [0 : i32]} : (memref<64x28x28xi8, 12>) -> memref<16x14x14xi8, 7>[index, index, index] {
// CHECK:                 ^bb0(%arg22: memref<64x28x28xi8, 12>, %arg23: memref<16x14x14xi8, 7>, %arg24: index, %arg25: index, %arg26: index):
// CHECK:                   affine.for %arg27 = 0 to 16 {
// CHECK:                     affine.for %arg28 = 0 to 14 {
// CHECK:                       affine.for %arg29 = 0 to 14 {
// CHECK:                         %8 = affine.load %arg22[%arg27 + %arg24 * 16, %arg28 + %arg25 * 14, %arg29 + %arg26 * 14] : memref<64x28x28xi8, 12>
// CHECK:                         affine.store %8, %arg23[%arg27, %arg28, %arg29] : memref<16x14x14xi8, 7>
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   } {parallel}
// CHECK:                 }
// CHECK:                 hls.dataflow.node(%7) -> (%arg19) [%arg21, %arg18, %arg20] {inputTaps = [0 : i32]} : (memref<16x14x14xi8, 7>) -> memref<64xi8, 7>[index, index, index] {
// CHECK:                 ^bb0(%arg22: memref<16x14x14xi8, 7>, %arg23: memref<64xi8, 7>, %arg24: index, %arg25: index, %arg26: index):
// CHECK:                   %c-24_i8 = arith.constant -24 : i8
// CHECK:                   affine.for %arg27 = 0 to 14 {
// CHECK:                     affine.for %arg28 = 0 to 14 {
// CHECK:                       affine.for %arg29 = 0 to 16 {
// CHECK:                         %8 = affine.load %arg22[%arg29, %arg27, %arg28] : memref<16x14x14xi8, 7>
// CHECK:                         %9 = affine.load %arg23[%arg29 + %arg24 * 16] : memref<64xi8, 7>
// CHECK:                         %10 = arith.addi %9, %8 : i8
// CHECK:                         %11 = arith.divui %10, %c-24_i8 : i8
// CHECK:                         %12 = hls.affine.select #set3(%arg27, %arg28, %arg25, %arg26) %11, %10 : i8
// CHECK:                         affine.store %12, %arg23[%arg29 + %arg24 * 16] : memref<64xi8, 7>
// CHECK:                       } {parallel, point}
// CHECK:                     } {point}
// CHECK:                   } {point}
// CHECK:                 }
// CHECK:               }
// CHECK:             } {parallel}
// CHECK:           }
// CHECK:         }
// CHECK:       }
// CHECK:       hls.dataflow.node(%6, %arg9) -> (%arg7) {inputTaps = [0 : i32, 0 : i32]} : (memref<64xi8, 7>, memref<1000x64xi8, 12>) -> memref<1000xi8, 12> {
// CHECK:       ^bb0(%arg12: memref<64xi8, 7>, %arg13: memref<1000x64xi8, 12>, %arg14: memref<1000xi8, 12>):
// CHECK:         affine.for %arg15 = 0 to 4 {
// CHECK:           affine.for %arg16 = 0 to 100 {
// CHECK:             hls.dataflow.schedule(%arg15, %arg16, %arg12, %arg13, %arg14) : index, index, memref<64xi8, 7>, memref<1000x64xi8, 12>, memref<1000xi8, 12> {
// CHECK:             ^bb0(%arg17: index, %arg18: index, %arg19: memref<64xi8, 7>, %arg20: memref<1000x64xi8, 12>, %arg21: memref<1000xi8, 12>):
// CHECK:               %7 = hls.dataflow.buffer {depth = 1 : i32} : memref<10x16xi8, 7>
// CHECK:               %8 = hls.dataflow.buffer {depth = 1 : i32} : memref<10xi8, 7>
// CHECK:               hls.dataflow.node(%arg21) -> (%8) [%arg18] {inputTaps = [0 : i32]} : (memref<1000xi8, 12>) -> memref<10xi8, 7>[index] {
// CHECK:               ^bb0(%arg22: memref<1000xi8, 12>, %arg23: memref<10xi8, 7>, %arg24: index):
// CHECK:                 affine.for %arg25 = 0 to 10 {
// CHECK:                   %10 = affine.load %arg22[%arg25 + %arg24 * 10] : memref<1000xi8, 12>
// CHECK:                   affine.store %10, %arg23[%arg25] : memref<10xi8, 7>
// CHECK:                 } {parallel}
// CHECK:               }
// CHECK:               hls.dataflow.node(%arg20) -> (%7) [%arg18, %arg17] {inputTaps = [0 : i32]} : (memref<1000x64xi8, 12>) -> memref<10x16xi8, 7>[index, index] {
// CHECK:               ^bb0(%arg22: memref<1000x64xi8, 12>, %arg23: memref<10x16xi8, 7>, %arg24: index, %arg25: index):
// CHECK:                 affine.for %arg26 = 0 to 10 {
// CHECK:                   affine.for %arg27 = 0 to 16 {
// CHECK:                     %10 = affine.load %arg22[%arg26 + %arg24 * 10, %arg27 + %arg25 * 16] : memref<1000x64xi8, 12>
// CHECK:                     affine.store %10, %arg23[%arg26, %arg27] : memref<10x16xi8, 7>
// CHECK:                   } {parallel}
// CHECK:                 } {parallel}
// CHECK:               }
// CHECK:               %9 = hls.dataflow.buffer {depth = 1 : i32} : memref<10xi8, 7>
// CHECK:               hls.dataflow.node(%arg19, %7, %8) -> (%9) [%arg17] {inputTaps = [0 : i32, 0 : i32, 0 : i32]} : (memref<64xi8, 7>, memref<10x16xi8, 7>, memref<10xi8, 7>) -> memref<10xi8, 7>[index] {
// CHECK:               ^bb0(%arg22: memref<64xi8, 7>, %arg23: memref<10x16xi8, 7>, %arg24: memref<10xi8, 7>, %arg25: memref<10xi8, 7>, %arg26: index):
// CHECK:                 %c-24_i8 = arith.constant -24 : i8
// CHECK:                 affine.for %arg27 = 0 to 16 {
// CHECK:                   affine.for %arg28 = 0 to 10 {
// CHECK:                     %10 = affine.load %arg24[%arg28] : memref<10xi8, 7>
// CHECK:                     affine.if #set(%arg27) {
// CHECK:                       affine.store %10, %arg25[%arg28] : memref<10xi8, 7>
// CHECK:                     }
// CHECK:                     %11 = affine.load %arg25[%arg28] : memref<10xi8, 7>
// CHECK:                     %12 = hls.affine.select #set4(%arg27, %arg26) %c-24_i8, %11 : i8
// CHECK:                     %13 = affine.load %arg22[%arg27 + %arg26 * 16] : memref<64xi8, 7>
// CHECK:                     %14 = affine.load %arg23[%arg28, %arg27] : memref<10x16xi8, 7>
// CHECK:                     %15 = arith.muli %13, %14 : i8
// CHECK:                     %16 = arith.addi %12, %15 : i8
// CHECK:                     affine.store %16, %arg25[%arg28] : memref<10xi8, 7>
// CHECK:                   } {parallel, point}
// CHECK:                 } {point}
// CHECK:               }
// CHECK:               hls.dataflow.node(%9) -> (%arg21) [%arg18] {inputTaps = [0 : i32]} : (memref<10xi8, 7>) -> memref<1000xi8, 12>[index] {
// CHECK:               ^bb0(%arg22: memref<10xi8, 7>, %arg23: memref<1000xi8, 12>, %arg24: index):
// CHECK:                 affine.for %arg25 = 0 to 10 {
// CHECK:                   %10 = affine.load %arg22[%arg25] : memref<10xi8, 7>
// CHECK:                   affine.store %10, %arg23[%arg25 + %arg24 * 10] : memref<1000xi8, 12>
// CHECK:                 } {parallel}
// CHECK:               }
// CHECK:             }
// CHECK:           } {parallel}
// CHECK:         }
// CHECK:       }
// CHECK:     }
// CHECK:     return
// CHECK:   }
// CHECK: }

#set = affine_set<(d0) : (d0 == 0)>
#set1 = affine_set<(d0, d1, d2, d3) : (-d2 - d3 * 16 + 63 == 0, -d0 + 2 == 0, -d1 + 2 == 0)>
#set2 = affine_set<(d0)[s0] : (-d0 - s0 * 16 + 63 == 0)>
#set3 = affine_set<(d0, d1, d2, d3) : (-d0 - d2 * 14 + 27 == 0, -d1 - d3 * 14 + 27 == 0)>
#set4 = affine_set<(d0, d1) : (d0 + d1 * 16 == 0)>
module attributes {torch.debug_module_name = "ResNet"} {
  func.func @forward(%arg0: memref<64x56x56xi8, 12>, %arg1: memref<1000x64xi8, 12>, %arg2: memref<64x64xi8, 12>, %arg3: memref<64x64x3x3xi8, 12>, %arg4: memref<64x64x3x3xi8, 12>, %arg5: memref<1000xi8, 12>) attributes {top_func} {
    hls.dataflow.schedule(%arg2, %arg5, %arg3, %arg1, %arg0, %arg4) : memref<64x64xi8, 12>, memref<1000xi8, 12>, memref<64x64x3x3xi8, 12>, memref<1000x64xi8, 12>, memref<64x56x56xi8, 12>, memref<64x64x3x3xi8, 12> {
    ^bb0(%arg6: memref<64x64xi8, 12>, %arg7: memref<1000xi8, 12>, %arg8: memref<64x64x3x3xi8, 12>, %arg9: memref<1000x64xi8, 12>, %arg10: memref<64x56x56xi8, 12>, %arg11: memref<64x64x3x3xi8, 12>):
      hls.dataflow.node() -> (%arg10) {inputTaps = []} : () -> memref<64x56x56xi8, 12> {
      ^bb0(%arg12: memref<64x56x56xi8, 12>):
        affine.for %arg13 = 0 to 4 {
          affine.for %arg14 = 0 to 4 {
            affine.for %arg15 = 0 to 4 {
              hls.dataflow.schedule(%arg13, %arg15, %arg12, %arg14) : index, index, memref<64x56x56xi8, 12>, index {
              ^bb0(%arg16: index, %arg17: index, %arg18: memref<64x56x56xi8, 12>, %arg19: index):
                %5 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
                hls.dataflow.node(%arg18) -> (%5) [%arg16, %arg19, %arg17] {inputTaps = [0 : i32]} : (memref<64x56x56xi8, 12>) -> memref<16x14x14xi8, 7>[index, index, index] {
                ^bb0(%arg20: memref<64x56x56xi8, 12>, %arg21: memref<16x14x14xi8, 7>, %arg22: index, %arg23: index, %arg24: index):
                  affine.for %arg25 = 0 to 16 {
                    affine.for %arg26 = 0 to 14 {
                      affine.for %arg27 = 0 to 14 {
                        %7 = affine.load %arg20[%arg25 + %arg22 * 16, %arg26 + %arg23 * 14, %arg27 + %arg24 * 14] : memref<64x56x56xi8, 12>
                        affine.store %7, %arg21[%arg25, %arg26, %arg27] : memref<16x14x14xi8, 7>
                      } {parallel}
                    } {parallel}
                  } {parallel}
                }
                %6 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
                hls.dataflow.node(%5) -> (%6) {inputTaps = [0 : i32]} : (memref<16x14x14xi8, 7>) -> memref<16x14x14xi8, 7> {
                ^bb0(%arg20: memref<16x14x14xi8, 7>, %arg21: memref<16x14x14xi8, 7>):
                  %c-24_i8 = arith.constant -24 : i8
                  affine.for %arg22 = 0 to 16 {
                    affine.for %arg23 = 0 to 14 {
                      affine.for %arg24 = 0 to 14 {
                        %7 = affine.load %arg20[%arg22, %arg23, %arg24] : memref<16x14x14xi8, 7>
                        affine.store %7, %arg21[%arg22, %arg23, %arg24] : memref<16x14x14xi8, 7>
                        %8 = affine.load %arg21[%arg22, %arg23, %arg24] : memref<16x14x14xi8, 7>
                        %9 = arith.cmpi ugt, %8, %c-24_i8 : i8
                        %10 = arith.select %9, %8, %c-24_i8 : i8
                        affine.store %10, %arg21[%arg22, %arg23, %arg24] : memref<16x14x14xi8, 7>
                      } {parallel, point}
                    } {parallel, point}
                  } {parallel, point}
                }
                hls.dataflow.node(%6) -> (%arg18) [%arg16, %arg19, %arg17] {inputTaps = [0 : i32]} : (memref<16x14x14xi8, 7>) -> memref<64x56x56xi8, 12>[index, index, index] {
                ^bb0(%arg20: memref<16x14x14xi8, 7>, %arg21: memref<64x56x56xi8, 12>, %arg22: index, %arg23: index, %arg24: index):
                  affine.for %arg25 = 0 to 16 {
                    affine.for %arg26 = 0 to 14 {
                      affine.for %arg27 = 0 to 14 {
                        %7 = affine.load %arg20[%arg25, %arg26, %arg27] : memref<16x14x14xi8, 7>
                        affine.store %7, %arg21[%arg25 + %arg22 * 16, %arg26 + %arg23 * 14, %arg27 + %arg24 * 14] : memref<64x56x56xi8, 12>
                      } {parallel}
                    } {parallel}
                  } {parallel}
                }
              }
            } {parallel}
          } {parallel}
        } {parallel}
      }
      %0 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, 12>
      hls.dataflow.node(%arg10, %arg11) -> (%0) {inputTaps = [0 : i32, 0 : i32]} : (memref<64x56x56xi8, 12>, memref<64x64x3x3xi8, 12>) -> memref<64x28x28xi8, 12> {
      ^bb0(%arg12: memref<64x56x56xi8, 12>, %arg13: memref<64x64x3x3xi8, 12>, %arg14: memref<64x28x28xi8, 12>):
        affine.for %arg15 = 0 to 4 {
          affine.for %arg16 = 0 to 3 {
            affine.for %arg17 = 0 to 3 {
              affine.for %arg18 = 0 to 4 {
                affine.for %arg19 = 0 to 2 {
                  affine.for %arg20 = 0 to 2 {
                    hls.dataflow.schedule(%arg17, %arg14, %arg20, %arg16, %arg19, %arg12, %arg15, %arg13, %arg18) : index, memref<64x28x28xi8, 12>, index, index, index, memref<64x56x56xi8, 12>, index, memref<64x64x3x3xi8, 12>, index {
                    ^bb0(%arg21: index, %arg22: memref<64x28x28xi8, 12>, %arg23: index, %arg24: index, %arg25: index, %arg26: memref<64x56x56xi8, 12>, %arg27: index, %arg28: memref<64x64x3x3xi8, 12>, %arg29: index):
                      %5 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, 7>
                      %6 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, 7>
                      %7 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
                      hls.dataflow.node(%arg26) -> (%7) [%arg27, %arg24, %arg25, %arg21, %arg23] {inputTaps = [0 : i32]} : (memref<64x56x56xi8, 12>) -> memref<16x14x14xi8, 7>[index, index, index, index, index] {
                      ^bb0(%arg30: memref<64x56x56xi8, 12>, %arg31: memref<16x14x14xi8, 7>, %arg32: index, %arg33: index, %arg34: index, %arg35: index, %arg36: index):
                        affine.for %arg37 = 0 to 16 {
                          affine.for %arg38 = 0 to 14 {
                            affine.for %arg39 = 0 to 14 {
                              %9 = affine.load %arg30[%arg37 + %arg32 * 16, %arg38 * 2 + %arg33 + %arg34 * 28 - 1, %arg39 * 2 + %arg35 + %arg36 * 28 - 1] : memref<64x56x56xi8, 12>
                              affine.store %9, %arg31[%arg37, %arg38, %arg39] : memref<16x14x14xi8, 7>
                            } {parallel}
                          } {parallel}
                        } {parallel}
                      }
                      hls.dataflow.node(%arg28) -> (%6) [%arg29, %arg27, %arg24, %arg21] {inputTaps = [0 : i32]} : (memref<64x64x3x3xi8, 12>) -> memref<16x16xi8, 7>[index, index, index, index] {
                      ^bb0(%arg30: memref<64x64x3x3xi8, 12>, %arg31: memref<16x16xi8, 7>, %arg32: index, %arg33: index, %arg34: index, %arg35: index):
                        affine.for %arg36 = 0 to 16 {
                          affine.for %arg37 = 0 to 16 {
                            %9 = affine.load %arg30[%arg36 + %arg32 * 16, %arg37 + %arg33 * 16, %arg34, %arg35] : memref<64x64x3x3xi8, 12>
                            affine.store %9, %arg31[%arg36, %arg37] : memref<16x16xi8, 7>
                          } {parallel}
                        } {parallel}
                      }
                      hls.dataflow.node(%arg22) -> (%5) [%arg29, %arg25, %arg23] {inputTaps = [0 : i32]} : (memref<64x28x28xi8, 12>) -> memref<16x14x14xi8, 7>[index, index, index] {
                      ^bb0(%arg30: memref<64x28x28xi8, 12>, %arg31: memref<16x14x14xi8, 7>, %arg32: index, %arg33: index, %arg34: index):
                        affine.for %arg35 = 0 to 16 {
                          affine.for %arg36 = 0 to 14 {
                            affine.for %arg37 = 0 to 14 {
                              %9 = affine.load %arg30[%arg35 + %arg32 * 16, %arg36 + %arg33 * 14, %arg37 + %arg34 * 14] : memref<64x28x28xi8, 12>
                              affine.store %9, %arg31[%arg35, %arg36, %arg37] : memref<16x14x14xi8, 7>
                            } {parallel}
                          } {parallel}
                        } {parallel}
                      }
                      %8 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
                      hls.dataflow.node(%7, %6, %5) -> (%8) [%arg21, %arg27, %arg24] {inputTaps = [0 : i32, 0 : i32, 0 : i32]} : (memref<16x14x14xi8, 7>, memref<16x16xi8, 7>, memref<16x14x14xi8, 7>) -> memref<16x14x14xi8, 7>[index, index, index] {
                      ^bb0(%arg30: memref<16x14x14xi8, 7>, %arg31: memref<16x16xi8, 7>, %arg32: memref<16x14x14xi8, 7>, %arg33: memref<16x14x14xi8, 7>, %arg34: index, %arg35: index, %arg36: index):
                        %c-24_i8 = arith.constant -24 : i8
                        affine.for %arg37 = 0 to 16 {
                          affine.for %arg38 = 0 to 16 {
                            affine.for %arg39 = 0 to 14 {
                              affine.for %arg40 = 0 to 14 {
                                %9 = affine.load %arg30[%arg37, %arg39, %arg40] : memref<16x14x14xi8, 7>
                                %10 = affine.load %arg31[%arg38, %arg37] : memref<16x16xi8, 7>
                                %11 = affine.load %arg32[%arg38, %arg39, %arg40] : memref<16x14x14xi8, 7>
                                affine.if #set(%arg37) {
                                  affine.store %11, %arg33[%arg38, %arg39, %arg40] : memref<16x14x14xi8, 7>
                                }
                                %12 = affine.load %arg33[%arg38, %arg39, %arg40] : memref<16x14x14xi8, 7>
                                %13 = arith.muli %9, %10 : i8
                                %14 = arith.addi %12, %13 : i8
                                %15 = arith.cmpi ugt, %14, %c-24_i8 : i8
                                %16 = arith.select %15, %14, %c-24_i8 : i8
                                %17 = hls.affine.select #set1(%arg36, %arg34, %arg37, %arg35) %16, %14 : i8
                                affine.store %17, %arg33[%arg38, %arg39, %arg40] : memref<16x14x14xi8, 7>
                              } {parallel, point}
                            } {parallel, point}
                          } {parallel, point}
                        } {point}
                      }
                      hls.dataflow.node(%8) -> (%arg22) [%arg29, %arg25, %arg23] {inputTaps = [0 : i32]} : (memref<16x14x14xi8, 7>) -> memref<64x28x28xi8, 12>[index, index, index] {
                      ^bb0(%arg30: memref<16x14x14xi8, 7>, %arg31: memref<64x28x28xi8, 12>, %arg32: index, %arg33: index, %arg34: index):
                        affine.for %arg35 = 0 to 16 {
                          affine.for %arg36 = 0 to 14 {
                            affine.for %arg37 = 0 to 14 {
                              %9 = affine.load %arg30[%arg35, %arg36, %arg37] : memref<16x14x14xi8, 7>
                              affine.store %9, %arg31[%arg35 + %arg32 * 16, %arg36 + %arg33 * 14, %arg37 + %arg34 * 14] : memref<64x28x28xi8, 12>
                            } {parallel}
                          } {parallel}
                        } {parallel}
                      }
                    }
                  } {parallel}
                } {parallel}
              } {parallel}
            }
          }
        }
      }
      %1 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, 12>
      hls.dataflow.node(%arg8, %0) -> (%1) {inputTaps = [0 : i32, 0 : i32]} : (memref<64x64x3x3xi8, 12>, memref<64x28x28xi8, 12>) -> memref<64x28x28xi8, 12> {
      ^bb0(%arg12: memref<64x64x3x3xi8, 12>, %arg13: memref<64x28x28xi8, 12>, %arg14: memref<64x28x28xi8, 12>):
        affine.for %arg15 = 0 to 4 {
          affine.for %arg16 = 0 to 3 {
            affine.for %arg17 = 0 to 3 {
              affine.for %arg18 = 0 to 4 {
                affine.for %arg19 = 0 to 2 {
                  affine.for %arg20 = 0 to 2 {
                    hls.dataflow.schedule(%arg20, %arg16, %arg15, %arg17, %arg19, %arg14, %arg12, %arg13, %arg18) : index, index, index, index, index, memref<64x28x28xi8, 12>, memref<64x64x3x3xi8, 12>, memref<64x28x28xi8, 12>, index {
                    ^bb0(%arg21: index, %arg22: index, %arg23: index, %arg24: index, %arg25: index, %arg26: memref<64x28x28xi8, 12>, %arg27: memref<64x64x3x3xi8, 12>, %arg28: memref<64x28x28xi8, 12>, %arg29: index):
                      %5 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, 7>
                      %6 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, 7>
                      %7 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, 7>
                      hls.dataflow.node(%arg28) -> (%7) [%arg23, %arg22, %arg25, %arg24, %arg21] {inputTaps = [0 : i32]} : (memref<64x28x28xi8, 12>) -> memref<16x14x14xi8, 7>[index, index, index, index, index] {
                      ^bb0(%arg30: memref<64x28x28xi8, 12>, %arg31: memref<16x14x14xi8, 7>, %arg32: index, %arg33: index, %arg34: index, %arg35: index, %arg36: index):
                        affine.for %arg37 = 0 to 16 {
                          affine.for %arg38 = 0 to 14 {
                            affine.for %arg39 = 0 to 14 {
                              %9 = affine.load %arg30[%arg37 + %arg32 * 16, %arg38 + %arg33 + %arg34 * 14 - 1, %arg39 + %arg35 + %arg36 * 14 - 1] : memref<64x28x28xi8, 12>
                              affine.store %9, %arg31[%arg37, %arg38, %arg39] : memref<16x14x14xi8, 7>
                            } {parallel}
                          } {parallel}
                        } {parallel}
                      }
                      hls.dataflow.node(%arg27) -> (%6) [%arg29, %arg23, %arg22, %arg24] {inputTaps = [0 : i32]} : (memref<64x64x3x3xi8, 12>) -> memref<16x16xi8, 7>[index, index, index, index] {
                      ^bb0(%arg30: memref<64x64x3x3xi8, 12>, %arg31: memref<16x16xi8, 7>, %arg32: index, %arg33: index, %arg34: index, %arg35: index):
                        affine.for %arg36 = 0 to 16 {
                          affine.for %arg37 = 0 to 16 {
                            %9 = affine.load %arg30[%arg36 + %arg32 * 16, %arg37 + %arg33 * 16, %arg34, %arg35] : memref<64x64x3x3xi8, 12>
                            affine.store %9, %arg31[%arg36, %arg37] : memref<16x16xi8, 7>
                          } {parallel}
                        } {parallel}
                      }
                      hls.dataflow.node(%arg26) -> (%5) [%arg29, %arg25, %arg21] {inputTaps = [0 : i32]} : (memref<64x28x28xi8, 12>) -> memref<16x14x14xi8, 7>[index, index, index] {
                      ^bb0(%arg30: memref<64x28x28xi8, 12>, %arg31: memref<16x14x14xi8, 7>, %arg32: index, %arg33: index, %arg34: index):
                        affine.for %arg35 = 0 to 16 {
                          affine.for %arg36 = 0 to 14 {
                            affine.for %arg37 = 0 to 14 {
                              %9 = affine.load %arg30[%arg35 + %arg32 * 16, %arg36 + %arg33 * 14, %arg37 + %arg34 * 14] : memref<64x28x28xi8, 12>
                              affine.store %9, %arg31[%arg35, %arg36, %arg37] : memref<16x14x14xi8, 7>
                            } {parallel}
                          } {parallel}
                        } {parallel}
                      }
                      %8 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
                      hls.dataflow.node(%7, %6, %5) -> (%8) {inputTaps = [0 : i32, 0 : i32, 0 : i32]} : (memref<16x14x14xi8, 7>, memref<16x16xi8, 7>, memref<16x14x14xi8, 7>) -> memref<16x14x14xi8, 7> {
                      ^bb0(%arg30: memref<16x14x14xi8, 7>, %arg31: memref<16x16xi8, 7>, %arg32: memref<16x14x14xi8, 7>, %arg33: memref<16x14x14xi8, 7>):
                        affine.for %arg34 = 0 to 16 {
                          affine.for %arg35 = 0 to 16 {
                            affine.for %arg36 = 0 to 14 {
                              affine.for %arg37 = 0 to 14 {
                                %9 = affine.load %arg30[%arg34, %arg36, %arg37] : memref<16x14x14xi8, 7>
                                %10 = affine.load %arg31[%arg35, %arg34] : memref<16x16xi8, 7>
                                %11 = affine.load %arg32[%arg35, %arg36, %arg37] : memref<16x14x14xi8, 7>
                                affine.if #set(%arg34) {
                                  affine.store %11, %arg33[%arg35, %arg36, %arg37] : memref<16x14x14xi8, 7>
                                }
                                %12 = affine.load %arg33[%arg35, %arg36, %arg37] : memref<16x14x14xi8, 7>
                                %13 = arith.muli %9, %10 : i8
                                %14 = arith.addi %12, %13 : i8
                                affine.store %14, %arg33[%arg35, %arg36, %arg37] : memref<16x14x14xi8, 7>
                              } {parallel, point}
                            } {parallel, point}
                          } {parallel, point}
                        } {point}
                      }
                      hls.dataflow.node(%8) -> (%arg26) [%arg29, %arg25, %arg21] {inputTaps = [0 : i32]} : (memref<16x14x14xi8, 7>) -> memref<64x28x28xi8, 12>[index, index, index] {
                      ^bb0(%arg30: memref<16x14x14xi8, 7>, %arg31: memref<64x28x28xi8, 12>, %arg32: index, %arg33: index, %arg34: index):
                        affine.for %arg35 = 0 to 16 {
                          affine.for %arg36 = 0 to 14 {
                            affine.for %arg37 = 0 to 14 {
                              %9 = affine.load %arg30[%arg35, %arg36, %arg37] : memref<16x14x14xi8, 7>
                              affine.store %9, %arg31[%arg35 + %arg32 * 16, %arg36 + %arg33 * 14, %arg37 + %arg34 * 14] : memref<64x28x28xi8, 12>
                            } {parallel}
                          } {parallel}
                        } {parallel}
                      }
                    }
                  } {parallel}
                } {parallel}
              } {parallel}
            }
          }
        }
      }
      %2 = hls.dataflow.buffer {depth = 1 : i32} : memref<64x28x28xi8, 12>
      %3 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, 12>
      hls.dataflow.node(%arg10, %arg6, %1) -> (%2, %3) {inputTaps = [0 : i32, 0 : i32, 0 : i32]} : (memref<64x56x56xi8, 12>, memref<64x64xi8, 12>, memref<64x28x28xi8, 12>) -> (memref<64x28x28xi8, 12>, memref<64x28x28xi8, 12>) {
      ^bb0(%arg12: memref<64x56x56xi8, 12>, %arg13: memref<64x64xi8, 12>, %arg14: memref<64x28x28xi8, 12>, %arg15: memref<64x28x28xi8, 12>, %arg16: memref<64x28x28xi8, 12>):
        affine.for %arg17 = 0 to 4 {
          affine.for %arg18 = 0 to 4 {
            affine.for %arg19 = 0 to 2 {
              affine.for %arg20 = 0 to 2 {
                hls.dataflow.schedule(%arg19, %arg20, %arg13, %arg14, %arg12, %arg17, %arg15, %arg16, %arg18) : index, index, memref<64x64xi8, 12>, memref<64x28x28xi8, 12>, memref<64x56x56xi8, 12>, index, memref<64x28x28xi8, 12>, memref<64x28x28xi8, 12>, index {
                ^bb0(%arg21: index, %arg22: index, %arg23: memref<64x64xi8, 12>, %arg24: memref<64x28x28xi8, 12>, %arg25: memref<64x56x56xi8, 12>, %arg26: index, %arg27: memref<64x28x28xi8, 12>, %arg28: memref<64x28x28xi8, 12>, %arg29: index):
                  %5 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
                  %6 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, 7>
                  %7 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, 7>
                  %8 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, 7>
                  %9 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
                  hls.dataflow.node(%arg25) -> (%9) [%arg26, %arg21, %arg22] {inputTaps = [0 : i32]} : (memref<64x56x56xi8, 12>) -> memref<16x14x14xi8, 7>[index, index, index] {
                  ^bb0(%arg30: memref<64x56x56xi8, 12>, %arg31: memref<16x14x14xi8, 7>, %arg32: index, %arg33: index, %arg34: index):
                    affine.for %arg35 = 0 to 16 {
                      affine.for %arg36 = 0 to 14 {
                        affine.for %arg37 = 0 to 14 {
                          %11 = affine.load %arg30[%arg35 + %arg32 * 16, %arg36 * 2 + %arg33 * 28, %arg37 * 2 + %arg34 * 28] : memref<64x56x56xi8, 12>
                          affine.store %11, %arg31[%arg35, %arg36, %arg37] : memref<16x14x14xi8, 7>
                        } {parallel}
                      } {parallel}
                    } {parallel}
                  }
                  hls.dataflow.node(%arg23) -> (%8) [%arg29, %arg26] {inputTaps = [0 : i32]} : (memref<64x64xi8, 12>) -> memref<16x16xi8, 7>[index, index] {
                  ^bb0(%arg30: memref<64x64xi8, 12>, %arg31: memref<16x16xi8, 7>, %arg32: index, %arg33: index):
                    affine.for %arg34 = 0 to 16 {
                      affine.for %arg35 = 0 to 16 {
                        %11 = affine.load %arg30[%arg34 + %arg32 * 16, %arg35 + %arg33 * 16] : memref<64x64xi8, 12>
                        affine.store %11, %arg31[%arg34, %arg35] : memref<16x16xi8, 7>
                      } {parallel}
                    } {parallel}
                  }
                  hls.dataflow.node(%arg28) -> (%7) [%arg29, %arg21, %arg22] {inputTaps = [0 : i32]} : (memref<64x28x28xi8, 12>) -> memref<16x14x14xi8, 7>[index, index, index] {
                  ^bb0(%arg30: memref<64x28x28xi8, 12>, %arg31: memref<16x14x14xi8, 7>, %arg32: index, %arg33: index, %arg34: index):
                    affine.for %arg35 = 0 to 16 {
                      affine.for %arg36 = 0 to 14 {
                        affine.for %arg37 = 0 to 14 {
                          %11 = affine.load %arg30[%arg35 + %arg32 * 16, %arg36 + %arg33 * 14, %arg37 + %arg34 * 14] : memref<64x28x28xi8, 12>
                          affine.store %11, %arg31[%arg35, %arg36, %arg37] : memref<16x14x14xi8, 7>
                        } {parallel}
                      } {parallel}
                    } {parallel}
                  }
                  hls.dataflow.node(%arg24) -> (%6) [%arg29, %arg21, %arg22] {inputTaps = [0 : i32]} : (memref<64x28x28xi8, 12>) -> memref<16x14x14xi8, 7>[index, index, index] {
                  ^bb0(%arg30: memref<64x28x28xi8, 12>, %arg31: memref<16x14x14xi8, 7>, %arg32: index, %arg33: index, %arg34: index):
                    affine.for %arg35 = 0 to 16 {
                      affine.for %arg36 = 0 to 14 {
                        affine.for %arg37 = 0 to 14 {
                          %11 = affine.load %arg30[%arg35 + %arg32 * 16, %arg36 + %arg33 * 14, %arg37 + %arg34 * 14] : memref<64x28x28xi8, 12>
                          affine.store %11, %arg31[%arg35, %arg36, %arg37] : memref<16x14x14xi8, 7>
                        } {parallel}
                      } {parallel}
                    } {parallel}
                  }
                  %10 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
                  hls.dataflow.node(%6, %9, %8, %7) -> (%5, %10) [%arg26] {inputTaps = [0 : i32, 0 : i32, 0 : i32, 0 : i32]} : (memref<16x14x14xi8, 7>, memref<16x14x14xi8, 7>, memref<16x16xi8, 7>, memref<16x14x14xi8, 7>) -> (memref<16x14x14xi8, 7>, memref<16x14x14xi8, 7>)[index] {
                  ^bb0(%arg30: memref<16x14x14xi8, 7>, %arg31: memref<16x14x14xi8, 7>, %arg32: memref<16x16xi8, 7>, %arg33: memref<16x14x14xi8, 7>, %arg34: memref<16x14x14xi8, 7>, %arg35: memref<16x14x14xi8, 7>, %arg36: index):
                    %c-24_i8 = arith.constant -24 : i8
                    affine.for %arg37 = 0 to 16 {
                      affine.for %arg38 = 0 to 16 {
                        affine.for %arg39 = 0 to 14 {
                          affine.for %arg40 = 0 to 14 {
                            %11 = affine.load %arg31[%arg37, %arg39, %arg40] : memref<16x14x14xi8, 7>
                            %12 = affine.load %arg32[%arg38, %arg37] : memref<16x16xi8, 7>
                            %13 = affine.load %arg33[%arg38, %arg39, %arg40] : memref<16x14x14xi8, 7>
                            affine.if #set(%arg37) {
                              affine.store %13, %arg35[%arg38, %arg39, %arg40] : memref<16x14x14xi8, 7>
                            }
                            %14 = affine.load %arg35[%arg38, %arg39, %arg40] : memref<16x14x14xi8, 7>
                            %15 = arith.muli %11, %12 : i8
                            %16 = arith.addi %14, %15 : i8
                            affine.store %16, %arg35[%arg38, %arg39, %arg40] : memref<16x14x14xi8, 7>
                            %17 = affine.load %arg30[%arg38, %arg39, %arg40] : memref<16x14x14xi8, 7>
                            %18 = arith.addi %17, %16 : i8
                            %19 = arith.cmpi ugt, %18, %c-24_i8 : i8
                            %20 = arith.select %19, %18, %c-24_i8 : i8
                            affine.if #set2(%arg37)[%arg36] {
                              affine.store %20, %arg34[%arg38, %arg39, %arg40] : memref<16x14x14xi8, 7>
                            }
                          } {parallel, point}
                        } {parallel, point}
                      } {parallel, point}
                    } {point}
                  }
                  hls.dataflow.node(%10) -> (%arg28) [%arg29, %arg21, %arg22] {inputTaps = [0 : i32]} : (memref<16x14x14xi8, 7>) -> memref<64x28x28xi8, 12>[index, index, index] {
                  ^bb0(%arg30: memref<16x14x14xi8, 7>, %arg31: memref<64x28x28xi8, 12>, %arg32: index, %arg33: index, %arg34: index):
                    affine.for %arg35 = 0 to 16 {
                      affine.for %arg36 = 0 to 14 {
                        affine.for %arg37 = 0 to 14 {
                          %11 = affine.load %arg30[%arg35, %arg36, %arg37] : memref<16x14x14xi8, 7>
                          affine.store %11, %arg31[%arg35 + %arg32 * 16, %arg36 + %arg33 * 14, %arg37 + %arg34 * 14] : memref<64x28x28xi8, 12>
                        } {parallel}
                      } {parallel}
                    } {parallel}
                  }
                  hls.dataflow.node(%5) -> (%arg27) [%arg29, %arg21, %arg22] {inputTaps = [0 : i32]} : (memref<16x14x14xi8, 7>) -> memref<64x28x28xi8, 12>[index, index, index] {
                  ^bb0(%arg30: memref<16x14x14xi8, 7>, %arg31: memref<64x28x28xi8, 12>, %arg32: index, %arg33: index, %arg34: index):
                    affine.for %arg35 = 0 to 16 {
                      affine.for %arg36 = 0 to 14 {
                        affine.for %arg37 = 0 to 14 {
                          %11 = affine.load %arg30[%arg35, %arg36, %arg37] : memref<16x14x14xi8, 7>
                          affine.store %11, %arg31[%arg35 + %arg32 * 16, %arg36 + %arg33 * 14, %arg37 + %arg34 * 14] : memref<64x28x28xi8, 12>
                        } {parallel}
                      } {parallel}
                    } {parallel}
                  }
                }
              } {parallel}
            } {parallel}
          } {parallel}
        }
      }
      %4 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64xi8, 7>
      hls.dataflow.node(%2) -> (%4) {inputTaps = [0 : i32]} : (memref<64x28x28xi8, 12>) -> memref<64xi8, 7> {
      ^bb0(%arg12: memref<64x28x28xi8, 12>, %arg13: memref<64xi8, 7>):
        affine.for %arg14 = 0 to 2 {
          affine.for %arg15 = 0 to 2 {
            affine.for %arg16 = 0 to 4 {
              hls.dataflow.schedule(%arg12, %arg14, %arg13, %arg15, %arg16) : memref<64x28x28xi8, 12>, index, memref<64xi8, 7>, index, index {
              ^bb0(%arg17: memref<64x28x28xi8, 12>, %arg18: index, %arg19: memref<64xi8, 7>, %arg20: index, %arg21: index):
                %5 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
                hls.dataflow.node(%arg17) -> (%5) [%arg21, %arg18, %arg20] {inputTaps = [0 : i32]} : (memref<64x28x28xi8, 12>) -> memref<16x14x14xi8, 7>[index, index, index] {
                ^bb0(%arg22: memref<64x28x28xi8, 12>, %arg23: memref<16x14x14xi8, 7>, %arg24: index, %arg25: index, %arg26: index):
                  affine.for %arg27 = 0 to 16 {
                    affine.for %arg28 = 0 to 14 {
                      affine.for %arg29 = 0 to 14 {
                        %6 = affine.load %arg22[%arg27 + %arg24 * 16, %arg28 + %arg25 * 14, %arg29 + %arg26 * 14] : memref<64x28x28xi8, 12>
                        affine.store %6, %arg23[%arg27, %arg28, %arg29] : memref<16x14x14xi8, 7>
                      } {parallel}
                    } {parallel}
                  } {parallel}
                }
                hls.dataflow.node(%5) -> (%arg19) [%arg21, %arg18, %arg20] {inputTaps = [0 : i32]} : (memref<16x14x14xi8, 7>) -> memref<64xi8, 7>[index, index, index] {
                ^bb0(%arg22: memref<16x14x14xi8, 7>, %arg23: memref<64xi8, 7>, %arg24: index, %arg25: index, %arg26: index):
                  %c-24_i8 = arith.constant -24 : i8
                  affine.for %arg27 = 0 to 14 {
                    affine.for %arg28 = 0 to 14 {
                      affine.for %arg29 = 0 to 16 {
                        %6 = affine.load %arg22[%arg29, %arg27, %arg28] : memref<16x14x14xi8, 7>
                        %7 = affine.load %arg23[%arg29 + %arg24 * 16] : memref<64xi8, 7>
                        %8 = arith.addi %7, %6 : i8
                        %9 = arith.divui %8, %c-24_i8 : i8
                        %10 = hls.affine.select #set3(%arg27, %arg28, %arg25, %arg26) %9, %8 : i8
                        affine.store %10, %arg23[%arg29 + %arg24 * 16] : memref<64xi8, 7>
                      } {parallel, point}
                    } {point}
                  } {point}
                }
              }
            } {parallel}
          }
        }
      }
      hls.dataflow.node(%4, %arg9) -> (%arg7) {inputTaps = [0 : i32, 0 : i32]} : (memref<64xi8, 7>, memref<1000x64xi8, 12>) -> memref<1000xi8, 12> {
      ^bb0(%arg12: memref<64xi8, 7>, %arg13: memref<1000x64xi8, 12>, %arg14: memref<1000xi8, 12>):
        affine.for %arg15 = 0 to 4 {
          affine.for %arg16 = 0 to 100 {
            hls.dataflow.schedule(%arg15, %arg16, %arg12, %arg13, %arg14) : index, index, memref<64xi8, 7>, memref<1000x64xi8, 12>, memref<1000xi8, 12> {
            ^bb0(%arg17: index, %arg18: index, %arg19: memref<64xi8, 7>, %arg20: memref<1000x64xi8, 12>, %arg21: memref<1000xi8, 12>):
              %5 = hls.dataflow.buffer {depth = 1 : i32} : memref<10x16xi8, 7>
              %6 = hls.dataflow.buffer {depth = 1 : i32} : memref<10xi8, 7>
              hls.dataflow.node(%arg21) -> (%6) [%arg18] {inputTaps = [0 : i32]} : (memref<1000xi8, 12>) -> memref<10xi8, 7>[index] {
              ^bb0(%arg22: memref<1000xi8, 12>, %arg23: memref<10xi8, 7>, %arg24: index):
                affine.for %arg25 = 0 to 10 {
                  %8 = affine.load %arg22[%arg25 + %arg24 * 10] : memref<1000xi8, 12>
                  affine.store %8, %arg23[%arg25] : memref<10xi8, 7>
                } {parallel}
              }
              hls.dataflow.node(%arg20) -> (%5) [%arg18, %arg17] {inputTaps = [0 : i32]} : (memref<1000x64xi8, 12>) -> memref<10x16xi8, 7>[index, index] {
              ^bb0(%arg22: memref<1000x64xi8, 12>, %arg23: memref<10x16xi8, 7>, %arg24: index, %arg25: index):
                affine.for %arg26 = 0 to 10 {
                  affine.for %arg27 = 0 to 16 {
                    %8 = affine.load %arg22[%arg26 + %arg24 * 10, %arg27 + %arg25 * 16] : memref<1000x64xi8, 12>
                    affine.store %8, %arg23[%arg26, %arg27] : memref<10x16xi8, 7>
                  } {parallel}
                } {parallel}
              }
              %7 = hls.dataflow.buffer {depth = 1 : i32} : memref<10xi8, 7>
              hls.dataflow.node(%arg19, %5, %6) -> (%7) [%arg17] {inputTaps = [0 : i32, 0 : i32, 0 : i32]} : (memref<64xi8, 7>, memref<10x16xi8, 7>, memref<10xi8, 7>) -> memref<10xi8, 7>[index] {
              ^bb0(%arg22: memref<64xi8, 7>, %arg23: memref<10x16xi8, 7>, %arg24: memref<10xi8, 7>, %arg25: memref<10xi8, 7>, %arg26: index):
                %c-24_i8 = arith.constant -24 : i8
                affine.for %arg27 = 0 to 16 {
                  affine.for %arg28 = 0 to 10 {
                    %8 = affine.load %arg24[%arg28] : memref<10xi8, 7>
                    affine.if #set(%arg27) {
                      affine.store %8, %arg25[%arg28] : memref<10xi8, 7>
                    }
                    %9 = affine.load %arg25[%arg28] : memref<10xi8, 7>
                    %10 = hls.affine.select #set4(%arg27, %arg26) %c-24_i8, %9 : i8
                    %11 = affine.load %arg22[%arg27 + %arg26 * 16] : memref<64xi8, 7>
                    %12 = affine.load %arg23[%arg28, %arg27] : memref<10x16xi8, 7>
                    %13 = arith.muli %11, %12 : i8
                    %14 = arith.addi %10, %13 : i8
                    affine.store %14, %arg25[%arg28] : memref<10xi8, 7>
                  } {parallel, point}
                } {point}
              }
              hls.dataflow.node(%7) -> (%arg21) [%arg18] {inputTaps = [0 : i32]} : (memref<10xi8, 7>) -> memref<1000xi8, 12>[index] {
              ^bb0(%arg22: memref<10xi8, 7>, %arg23: memref<1000xi8, 12>, %arg24: index):
                affine.for %arg25 = 0 to 10 {
                  %8 = affine.load %arg22[%arg25] : memref<10xi8, 7>
                  affine.store %8, %arg23[%arg25 + %arg24 * 10] : memref<1000xi8, 12>
                } {parallel}
              }
            }
          } {parallel}
        }
      }
    }
    return
  }
}

