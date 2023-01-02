// RUN: scalehls-opt -scalehls-create-token-stream %s | FileCheck %s

// CHECK: #set = affine_set<(d0) : (d0 == 0)>
// CHECK: #set1 = affine_set<(d0, d1, d2, d3) : (-d2 - d3 * 16 + 63 == 0, -d0 + 2 == 0, -d1 + 2 == 0)>
// CHECK: #set2 = affine_set<(d0)[s0] : (-d0 - s0 * 16 + 63 == 0)>
// CHECK: #set3 = affine_set<(d0, d1, d2, d3) : (-d0 - d2 * 14 + 27 == 0, -d1 - d3 * 14 + 27 == 0)>
// CHECK: #set4 = affine_set<(d0, d1) : (d0 + d1 * 16 == 0)>
// CHECK: module attributes {torch.debug_module_name = "ResNet"} {
// CHECK:   func.func @forward(%arg0: memref<64x56x56xi8, #hls.mem<dram>>, %arg1: memref<1000x64xi8, #hls.mem<dram>>, %arg2: memref<64x64xi8, #hls.mem<dram>>, %arg3: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg4: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg5: memref<1000xi8, #hls.mem<dram>>) attributes {top_func} {
// CHECK:     hls.dataflow.schedule legal(%arg2, %arg5, %arg3, %arg1, %arg0, %arg4) : memref<64x64xi8, #hls.mem<dram>>, memref<1000xi8, #hls.mem<dram>>, memref<64x64x3x3xi8, #hls.mem<dram>>, memref<1000x64xi8, #hls.mem<dram>>, memref<64x56x56xi8, #hls.mem<dram>>, memref<64x64x3x3xi8, #hls.mem<dram>> {
// CHECK:     ^bb0(%arg6: memref<64x64xi8, #hls.mem<dram>>, %arg7: memref<1000xi8, #hls.mem<dram>>, %arg8: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg9: memref<1000x64xi8, #hls.mem<dram>>, %arg10: memref<64x56x56xi8, #hls.mem<dram>>, %arg11: memref<64x64x3x3xi8, #hls.mem<dram>>):
// CHECK:       %0 = hls.dataflow.stream {depth = 1 : i32} : <i1, 1>
// CHECK:       hls.dataflow.node() -> (%0, %arg10) {inputTaps = [], level = 6 : i32} : () -> (!hls.stream<i1, 1>, memref<64x56x56xi8, #hls.mem<dram>>) {
// CHECK:       ^bb0(%arg12: !hls.stream<i1, 1>, %arg13: memref<64x56x56xi8, #hls.mem<dram>>):
// CHECK:         affine.for %arg14 = 0 to 4 {
// CHECK:           affine.for %arg15 = 0 to 4 {
// CHECK:             affine.for %arg16 = 0 to 4 {
// CHECK:               hls.dataflow.schedule legal(%arg14, %arg16, %arg13, %arg15) : index, index, memref<64x56x56xi8, #hls.mem<dram>>, index {
// CHECK:               ^bb0(%arg17: index, %arg18: index, %arg19: memref<64x56x56xi8, #hls.mem<dram>>, %arg20: index):
// CHECK:                 %13 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                 hls.dataflow.node(%arg19) -> (%13) [%arg17, %arg20, %arg18] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x56x56xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
// CHECK:                 ^bb0(%arg21: memref<64x56x56xi8, #hls.mem<dram>>, %arg22: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg23: index, %arg24: index, %arg25: index):
// CHECK:                   affine.for %arg26 = 0 to 16 {
// CHECK:                     affine.for %arg27 = 0 to 14 {
// CHECK:                       affine.for %arg28 = 0 to 14 {
// CHECK:                         %15 = affine.load %arg21[%arg26 + symbol(%arg23) * 16, %arg27 + symbol(%arg24) * 14, %arg28 + symbol(%arg25) * 14] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:                         affine.store %15, %arg22[%arg26, %arg27, %arg28] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   } {parallel}
// CHECK:                 }
// CHECK:                 %14 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                 hls.dataflow.node(%13) -> (%14) {inputTaps = [0 : i32], level = 1 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>> {
// CHECK:                 ^bb0(%arg21: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg22: memref<16x14x14xi8, #hls.mem<bram_t2p>>):
// CHECK:                   %c-24_i8 = arith.constant -24 : i8
// CHECK:                   affine.for %arg23 = 0 to 16 {
// CHECK:                     affine.for %arg24 = 0 to 14 {
// CHECK:                       affine.for %arg25 = 0 to 14 {
// CHECK:                         %15 = affine.load %arg21[%arg23, %arg24, %arg25] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                         %16 = arith.cmpi ugt, %15, %c-24_i8 : i8
// CHECK:                         %17 = arith.select %16, %15, %c-24_i8 : i8
// CHECK:                         affine.store %17, %arg22[%arg23, %arg24, %arg25] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                       } {parallel, point}
// CHECK:                     } {parallel, point}
// CHECK:                   } {parallel, point}
// CHECK:                 }
// CHECK:                 hls.dataflow.node(%14) -> (%arg19) [%arg17, %arg20, %arg18] {inputTaps = [0 : i32], level = 0 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<64x56x56xi8, #hls.mem<dram>>[index, index, index] {
// CHECK:                 ^bb0(%arg21: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg22: memref<64x56x56xi8, #hls.mem<dram>>, %arg23: index, %arg24: index, %arg25: index):
// CHECK:                   affine.for %arg26 = 0 to 16 {
// CHECK:                     affine.for %arg27 = 0 to 14 {
// CHECK:                       affine.for %arg28 = 0 to 14 {
// CHECK:                         %15 = affine.load %arg21[%arg26, %arg27, %arg28] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                         affine.store %15, %arg22[%arg26 + symbol(%arg23) * 16, %arg27 + symbol(%arg24) * 14, %arg28 + symbol(%arg25) * 14] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   } {parallel}
// CHECK:                 }
// CHECK:               }
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:         %true = arith.constant true
// CHECK:         hls.dataflow.stream_write %arg12, %true : <i1, 1>, i1
// CHECK:       }
// CHECK:       %1 = hls.dataflow.buffer {depth = 3 : i32} : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:       %2 = hls.dataflow.stream {depth = 3 : i32} : <i1, 3>
// CHECK:       %3 = hls.dataflow.buffer {depth = 1 : i32} : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:       %4 = hls.dataflow.stream {depth = 1 : i32} : <i1, 1>
// CHECK:       hls.dataflow.node(%0, %arg10) -> (%2, %1, %4, %3) {inputTaps = [0 : i32, 0 : i32], level = 5 : i32} : (!hls.stream<i1, 1>, memref<64x56x56xi8, #hls.mem<dram>>) -> (!hls.stream<i1, 3>, memref<64x56x56xi8, #hls.mem<dram>>, !hls.stream<i1, 1>, memref<64x56x56xi8, #hls.mem<dram>>) {
// CHECK:       ^bb0(%arg12: !hls.stream<i1, 1>, %arg13: memref<64x56x56xi8, #hls.mem<dram>>, %arg14: !hls.stream<i1, 3>, %arg15: memref<64x56x56xi8, #hls.mem<dram>>, %arg16: !hls.stream<i1, 1>, %arg17: memref<64x56x56xi8, #hls.mem<dram>>):
// CHECK:         hls.dataflow.stream_read %arg12 : (!hls.stream<i1, 1>) -> ()
// CHECK:         affine.for %arg18 = 0 to 64 {
// CHECK:           affine.for %arg19 = 0 to 56 {
// CHECK:             affine.for %arg20 = 0 to 56 {
// CHECK:               %13 = affine.load %arg13[%arg18, %arg19, %arg20] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:               affine.store %13, %arg15[%arg18, %arg19, %arg20] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:         affine.for %arg18 = 0 to 64 {
// CHECK:           affine.for %arg19 = 0 to 56 {
// CHECK:             affine.for %arg20 = 0 to 56 {
// CHECK:               %13 = affine.load %arg13[%arg18, %arg19, %arg20] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:               affine.store %13, %arg17[%arg18, %arg19, %arg20] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:         %true = arith.constant true
// CHECK:         hls.dataflow.stream_write %arg14, %true : <i1, 3>, i1
// CHECK:         %true_0 = arith.constant true
// CHECK:         hls.dataflow.stream_write %arg16, %true_0 : <i1, 1>, i1
// CHECK:       }
// CHECK:       %5 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:       %6 = hls.dataflow.stream {depth = 1 : i32} : <i1, 1>
// CHECK:       hls.dataflow.node(%4, %3, %arg11) -> (%6, %5) {inputTaps = [0 : i32, 0 : i32, 0 : i32], level = 4 : i32} : (!hls.stream<i1, 1>, memref<64x56x56xi8, #hls.mem<dram>>, memref<64x64x3x3xi8, #hls.mem<dram>>) -> (!hls.stream<i1, 1>, memref<64x28x28xi8, #hls.mem<dram>>) {
// CHECK:       ^bb0(%arg12: !hls.stream<i1, 1>, %arg13: memref<64x56x56xi8, #hls.mem<dram>>, %arg14: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg15: !hls.stream<i1, 1>, %arg16: memref<64x28x28xi8, #hls.mem<dram>>):
// CHECK:         hls.dataflow.stream_read %arg12 : (!hls.stream<i1, 1>) -> ()
// CHECK:         affine.for %arg17 = 0 to 4 {
// CHECK:           affine.for %arg18 = 0 to 3 {
// CHECK:             affine.for %arg19 = 0 to 3 {
// CHECK:               affine.for %arg20 = 0 to 4 {
// CHECK:                 affine.for %arg21 = 0 to 2 {
// CHECK:                   affine.for %arg22 = 0 to 2 {
// CHECK:                     hls.dataflow.schedule legal(%arg19, %arg16, %arg22, %arg18, %arg21, %arg13, %arg17, %arg14, %arg20) : index, memref<64x28x28xi8, #hls.mem<dram>>, index, index, index, memref<64x56x56xi8, #hls.mem<dram>>, index, memref<64x64x3x3xi8, #hls.mem<dram>>, index {
// CHECK:                     ^bb0(%arg23: index, %arg24: memref<64x28x28xi8, #hls.mem<dram>>, %arg25: index, %arg26: index, %arg27: index, %arg28: memref<64x56x56xi8, #hls.mem<dram>>, %arg29: index, %arg30: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg31: index):
// CHECK:                       %13 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                       %14 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:                       %15 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                       hls.dataflow.node(%arg28) -> (%15) [%arg29, %arg26, %arg27, %arg23, %arg25] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x56x56xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index, index, index] {
// CHECK:                       ^bb0(%arg32: memref<64x56x56xi8, #hls.mem<dram>>, %arg33: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg34: index, %arg35: index, %arg36: index, %arg37: index, %arg38: index):
// CHECK:                         affine.for %arg39 = 0 to 16 {
// CHECK:                           affine.for %arg40 = 0 to 14 step 2 {
// CHECK:                             affine.for %arg41 = 0 to 14 step 2 {
// CHECK:                               %17 = affine.load %arg32[%arg39 + symbol(%arg34) * 16, %arg40 * 2 + symbol(%arg35) + symbol(%arg36) * 28 - 1, %arg41 * 2 + symbol(%arg37) + symbol(%arg38) * 28 - 1] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:                               affine.store %17, %arg33[%arg39, %arg40, %arg41] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                               %18 = affine.load %arg32[%arg39 + symbol(%arg34) * 16, %arg40 * 2 + symbol(%arg35) + symbol(%arg36) * 28 - 1, %arg41 * 2 + symbol(%arg37) + symbol(%arg38) * 28 + 1] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:                               affine.store %18, %arg33[%arg39, %arg40, %arg41 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                               %19 = affine.load %arg32[%arg39 + symbol(%arg34) * 16, %arg40 * 2 + symbol(%arg35) + symbol(%arg36) * 28 + 1, %arg41 * 2 + symbol(%arg37) + symbol(%arg38) * 28 - 1] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:                               affine.store %19, %arg33[%arg39, %arg40 + 1, %arg41] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                               %20 = affine.load %arg32[%arg39 + symbol(%arg34) * 16, %arg40 * 2 + symbol(%arg35) + symbol(%arg36) * 28 + 1, %arg41 * 2 + symbol(%arg37) + symbol(%arg38) * 28 + 1] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:                               affine.store %20, %arg33[%arg39, %arg40 + 1, %arg41 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                             } {parallel}
// CHECK:                           } {parallel}
// CHECK:                         } {parallel}
// CHECK:                       }
// CHECK:                       hls.dataflow.node(%arg30) -> (%14) [%arg31, %arg29, %arg26, %arg23] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x64x3x3xi8, #hls.mem<dram>>) -> memref<16x16xi8, #hls.mem<bram_t2p>>[index, index, index, index] {
// CHECK:                       ^bb0(%arg32: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg33: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg34: index, %arg35: index, %arg36: index, %arg37: index):
// CHECK:                         affine.for %arg38 = 0 to 16 {
// CHECK:                           affine.for %arg39 = 0 to 16 {
// CHECK:                             %17 = affine.load %arg32[%arg38 + symbol(%arg34) * 16, %arg39 + symbol(%arg35) * 16, symbol(%arg36), symbol(%arg37)] : memref<64x64x3x3xi8, #hls.mem<dram>>
// CHECK:                             affine.store %17, %arg33[%arg38, %arg39] : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:                           } {parallel}
// CHECK:                         } {parallel}
// CHECK:                       }
// CHECK:                       hls.dataflow.node(%arg24) -> (%13) [%arg31, %arg27, %arg25] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
// CHECK:                       ^bb0(%arg32: memref<64x28x28xi8, #hls.mem<dram>>, %arg33: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg34: index, %arg35: index, %arg36: index):
// CHECK:                         affine.for %arg37 = 0 to 16 {
// CHECK:                           affine.for %arg38 = 0 to 14 step 2 {
// CHECK:                             affine.for %arg39 = 0 to 14 step 2 {
// CHECK:                               %17 = affine.load %arg32[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14, %arg39 + symbol(%arg36) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                               affine.store %17, %arg33[%arg37, %arg38, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                               %18 = affine.load %arg32[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14, %arg39 + symbol(%arg36) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                               affine.store %18, %arg33[%arg37, %arg38, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                               %19 = affine.load %arg32[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14 + 1, %arg39 + symbol(%arg36) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                               affine.store %19, %arg33[%arg37, %arg38 + 1, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                               %20 = affine.load %arg32[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14 + 1, %arg39 + symbol(%arg36) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                               affine.store %20, %arg33[%arg37, %arg38 + 1, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                             } {parallel}
// CHECK:                           } {parallel}
// CHECK:                         } {parallel}
// CHECK:                       }
// CHECK:                       %16 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                       hls.dataflow.node(%15, %14, %13) -> (%16) [%arg23, %arg29, %arg26] {inputTaps = [0 : i32, 0 : i32, 0 : i32], level = 1 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x16xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
// CHECK:                       ^bb0(%arg32: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg33: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg34: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg35: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg36: index, %arg37: index, %arg38: index):
// CHECK:                         %c-24_i8 = arith.constant -24 : i8
// CHECK:                         affine.for %arg39 = 0 to 16 {
// CHECK:                           affine.for %arg40 = 0 to 16 {
// CHECK:                             affine.for %arg41 = 0 to 14 step 2 {
// CHECK:                               affine.for %arg42 = 0 to 14 step 2 {
// CHECK:                                 %17 = affine.load %arg32[%arg39, %arg41, %arg42] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %18 = affine.load %arg33[%arg40, %arg39] : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %19 = affine.load %arg34[%arg40, %arg41, %arg42] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %20 = affine.load %arg35[%arg40, %arg41, %arg42] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %21 = hls.affine.select #set(%arg39) %19, %20 : i8
// CHECK:                                 %22 = arith.muli %17, %18 : i8
// CHECK:                                 %23 = arith.addi %21, %22 : i8
// CHECK:                                 %24 = arith.cmpi ugt, %23, %c-24_i8 : i8
// CHECK:                                 %25 = arith.select %24, %23, %c-24_i8 : i8
// CHECK:                                 %26 = hls.affine.select #set1(%arg38, %arg36, %arg39, %arg37) %25, %23 : i8
// CHECK:                                 affine.store %26, %arg35[%arg40, %arg41, %arg42] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %27 = affine.load %arg32[%arg39, %arg41, %arg42 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %28 = affine.load %arg34[%arg40, %arg41, %arg42 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %29 = affine.load %arg35[%arg40, %arg41, %arg42 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %30 = hls.affine.select #set(%arg39) %28, %29 : i8
// CHECK:                                 %31 = arith.muli %27, %18 : i8
// CHECK:                                 %32 = arith.addi %30, %31 : i8
// CHECK:                                 %33 = arith.cmpi ugt, %32, %c-24_i8 : i8
// CHECK:                                 %34 = arith.select %33, %32, %c-24_i8 : i8
// CHECK:                                 %35 = hls.affine.select #set1(%arg38, %arg36, %arg39, %arg37) %34, %32 : i8
// CHECK:                                 affine.store %35, %arg35[%arg40, %arg41, %arg42 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %36 = affine.load %arg32[%arg39, %arg41 + 1, %arg42] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %37 = affine.load %arg34[%arg40, %arg41 + 1, %arg42] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %38 = affine.load %arg35[%arg40, %arg41 + 1, %arg42] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %39 = hls.affine.select #set(%arg39) %37, %38 : i8
// CHECK:                                 %40 = arith.muli %36, %18 : i8
// CHECK:                                 %41 = arith.addi %39, %40 : i8
// CHECK:                                 %42 = arith.cmpi ugt, %41, %c-24_i8 : i8
// CHECK:                                 %43 = arith.select %42, %41, %c-24_i8 : i8
// CHECK:                                 %44 = hls.affine.select #set1(%arg38, %arg36, %arg39, %arg37) %43, %41 : i8
// CHECK:                                 affine.store %44, %arg35[%arg40, %arg41 + 1, %arg42] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %45 = affine.load %arg32[%arg39, %arg41 + 1, %arg42 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %46 = affine.load %arg34[%arg40, %arg41 + 1, %arg42 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %47 = affine.load %arg35[%arg40, %arg41 + 1, %arg42 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %48 = hls.affine.select #set(%arg39) %46, %47 : i8
// CHECK:                                 %49 = arith.muli %45, %18 : i8
// CHECK:                                 %50 = arith.addi %48, %49 : i8
// CHECK:                                 %51 = arith.cmpi ugt, %50, %c-24_i8 : i8
// CHECK:                                 %52 = arith.select %51, %50, %c-24_i8 : i8
// CHECK:                                 %53 = hls.affine.select #set1(%arg38, %arg36, %arg39, %arg37) %52, %50 : i8
// CHECK:                                 affine.store %53, %arg35[%arg40, %arg41 + 1, %arg42 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                               } {parallel, point}
// CHECK:                             } {parallel, point}
// CHECK:                           } {parallel, point}
// CHECK:                         } {point}
// CHECK:                       }
// CHECK:                       hls.dataflow.node(%16) -> (%arg24) [%arg31, %arg27, %arg25] {inputTaps = [0 : i32], level = 0 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<64x28x28xi8, #hls.mem<dram>>[index, index, index] {
// CHECK:                       ^bb0(%arg32: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg33: memref<64x28x28xi8, #hls.mem<dram>>, %arg34: index, %arg35: index, %arg36: index):
// CHECK:                         affine.for %arg37 = 0 to 16 {
// CHECK:                           affine.for %arg38 = 0 to 14 step 2 {
// CHECK:                             affine.for %arg39 = 0 to 14 step 2 {
// CHECK:                               %17 = affine.load %arg32[%arg37, %arg38, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                               affine.store %17, %arg33[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14, %arg39 + symbol(%arg36) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                               %18 = affine.load %arg32[%arg37, %arg38, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                               affine.store %18, %arg33[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14, %arg39 + symbol(%arg36) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                               %19 = affine.load %arg32[%arg37, %arg38 + 1, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                               affine.store %19, %arg33[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14 + 1, %arg39 + symbol(%arg36) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                               %20 = affine.load %arg32[%arg37, %arg38 + 1, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                               affine.store %20, %arg33[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14 + 1, %arg39 + symbol(%arg36) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
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
// CHECK:         %true = arith.constant true
// CHECK:         hls.dataflow.stream_write %arg15, %true : <i1, 1>, i1
// CHECK:       }
// CHECK:       %7 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:       %8 = hls.dataflow.stream {depth = 1 : i32} : <i1, 1>
// CHECK:       hls.dataflow.node(%arg8, %6, %5) -> (%8, %7) {inputTaps = [0 : i32, 0 : i32, 0 : i32], level = 3 : i32} : (memref<64x64x3x3xi8, #hls.mem<dram>>, !hls.stream<i1, 1>, memref<64x28x28xi8, #hls.mem<dram>>) -> (!hls.stream<i1, 1>, memref<64x28x28xi8, #hls.mem<dram>>) {
// CHECK:       ^bb0(%arg12: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg13: !hls.stream<i1, 1>, %arg14: memref<64x28x28xi8, #hls.mem<dram>>, %arg15: !hls.stream<i1, 1>, %arg16: memref<64x28x28xi8, #hls.mem<dram>>):
// CHECK:         hls.dataflow.stream_read %arg13 : (!hls.stream<i1, 1>) -> ()
// CHECK:         affine.for %arg17 = 0 to 4 {
// CHECK:           affine.for %arg18 = 0 to 3 {
// CHECK:             affine.for %arg19 = 0 to 3 {
// CHECK:               affine.for %arg20 = 0 to 4 {
// CHECK:                 affine.for %arg21 = 0 to 2 {
// CHECK:                   affine.for %arg22 = 0 to 2 {
// CHECK:                     hls.dataflow.schedule legal(%arg22, %arg18, %arg17, %arg19, %arg21, %arg16, %arg12, %arg14, %arg20) : index, index, index, index, index, memref<64x28x28xi8, #hls.mem<dram>>, memref<64x64x3x3xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>, index {
// CHECK:                     ^bb0(%arg23: index, %arg24: index, %arg25: index, %arg26: index, %arg27: index, %arg28: memref<64x28x28xi8, #hls.mem<dram>>, %arg29: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg30: memref<64x28x28xi8, #hls.mem<dram>>, %arg31: index):
// CHECK:                       %13 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                       %14 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:                       %15 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                       hls.dataflow.node(%arg30) -> (%15) [%arg25, %arg24, %arg27, %arg26, %arg23] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index, index, index] {
// CHECK:                       ^bb0(%arg32: memref<64x28x28xi8, #hls.mem<dram>>, %arg33: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg34: index, %arg35: index, %arg36: index, %arg37: index, %arg38: index):
// CHECK:                         affine.for %arg39 = 0 to 16 {
// CHECK:                           affine.for %arg40 = 0 to 14 step 2 {
// CHECK:                             affine.for %arg41 = 0 to 14 step 2 {
// CHECK:                               %17 = affine.load %arg32[%arg39 + symbol(%arg34) * 16, %arg40 + symbol(%arg35) + symbol(%arg36) * 14 - 1, %arg41 + symbol(%arg37) + symbol(%arg38) * 14 - 1] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                               affine.store %17, %arg33[%arg39, %arg40, %arg41] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                               %18 = affine.load %arg32[%arg39 + symbol(%arg34) * 16, %arg40 + symbol(%arg35) + symbol(%arg36) * 14 - 1, %arg41 + symbol(%arg37) + symbol(%arg38) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                               affine.store %18, %arg33[%arg39, %arg40, %arg41 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                               %19 = affine.load %arg32[%arg39 + symbol(%arg34) * 16, %arg40 + symbol(%arg35) + symbol(%arg36) * 14, %arg41 + symbol(%arg37) + symbol(%arg38) * 14 - 1] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                               affine.store %19, %arg33[%arg39, %arg40 + 1, %arg41] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                               %20 = affine.load %arg32[%arg39 + symbol(%arg34) * 16, %arg40 + symbol(%arg35) + symbol(%arg36) * 14, %arg41 + symbol(%arg37) + symbol(%arg38) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                               affine.store %20, %arg33[%arg39, %arg40 + 1, %arg41 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                             } {parallel}
// CHECK:                           } {parallel}
// CHECK:                         } {parallel}
// CHECK:                       }
// CHECK:                       hls.dataflow.node(%arg29) -> (%14) [%arg31, %arg25, %arg24, %arg26] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x64x3x3xi8, #hls.mem<dram>>) -> memref<16x16xi8, #hls.mem<bram_t2p>>[index, index, index, index] {
// CHECK:                       ^bb0(%arg32: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg33: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg34: index, %arg35: index, %arg36: index, %arg37: index):
// CHECK:                         affine.for %arg38 = 0 to 16 {
// CHECK:                           affine.for %arg39 = 0 to 16 {
// CHECK:                             %17 = affine.load %arg32[%arg38 + symbol(%arg34) * 16, %arg39 + symbol(%arg35) * 16, symbol(%arg36), symbol(%arg37)] : memref<64x64x3x3xi8, #hls.mem<dram>>
// CHECK:                             affine.store %17, %arg33[%arg38, %arg39] : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:                           } {parallel}
// CHECK:                         } {parallel}
// CHECK:                       }
// CHECK:                       hls.dataflow.node(%arg28) -> (%13) [%arg31, %arg27, %arg23] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
// CHECK:                       ^bb0(%arg32: memref<64x28x28xi8, #hls.mem<dram>>, %arg33: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg34: index, %arg35: index, %arg36: index):
// CHECK:                         affine.for %arg37 = 0 to 16 {
// CHECK:                           affine.for %arg38 = 0 to 14 step 2 {
// CHECK:                             affine.for %arg39 = 0 to 14 step 2 {
// CHECK:                               %17 = affine.load %arg32[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14, %arg39 + symbol(%arg36) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                               affine.store %17, %arg33[%arg37, %arg38, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                               %18 = affine.load %arg32[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14, %arg39 + symbol(%arg36) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                               affine.store %18, %arg33[%arg37, %arg38, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                               %19 = affine.load %arg32[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14 + 1, %arg39 + symbol(%arg36) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                               affine.store %19, %arg33[%arg37, %arg38 + 1, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                               %20 = affine.load %arg32[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14 + 1, %arg39 + symbol(%arg36) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                               affine.store %20, %arg33[%arg37, %arg38 + 1, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                             } {parallel}
// CHECK:                           } {parallel}
// CHECK:                         } {parallel}
// CHECK:                       }
// CHECK:                       %16 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                       hls.dataflow.node(%15, %14, %13) -> (%16) {inputTaps = [0 : i32, 0 : i32, 0 : i32], level = 1 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x16xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>> {
// CHECK:                       ^bb0(%arg32: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg33: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg34: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg35: memref<16x14x14xi8, #hls.mem<bram_t2p>>):
// CHECK:                         affine.for %arg36 = 0 to 16 {
// CHECK:                           affine.for %arg37 = 0 to 16 {
// CHECK:                             affine.for %arg38 = 0 to 14 step 2 {
// CHECK:                               affine.for %arg39 = 0 to 14 step 2 {
// CHECK:                                 %17 = affine.load %arg32[%arg36, %arg38, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %18 = affine.load %arg33[%arg37, %arg36] : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %19 = affine.load %arg34[%arg37, %arg38, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %20 = affine.load %arg35[%arg37, %arg38, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %21 = hls.affine.select #set(%arg36) %19, %20 : i8
// CHECK:                                 %22 = arith.muli %17, %18 : i8
// CHECK:                                 %23 = arith.addi %21, %22 : i8
// CHECK:                                 affine.store %23, %arg35[%arg37, %arg38, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %24 = affine.load %arg32[%arg36, %arg38, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %25 = affine.load %arg34[%arg37, %arg38, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %26 = affine.load %arg35[%arg37, %arg38, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %27 = hls.affine.select #set(%arg36) %25, %26 : i8
// CHECK:                                 %28 = arith.muli %24, %18 : i8
// CHECK:                                 %29 = arith.addi %27, %28 : i8
// CHECK:                                 affine.store %29, %arg35[%arg37, %arg38, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %30 = affine.load %arg32[%arg36, %arg38 + 1, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %31 = affine.load %arg34[%arg37, %arg38 + 1, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %32 = affine.load %arg35[%arg37, %arg38 + 1, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %33 = hls.affine.select #set(%arg36) %31, %32 : i8
// CHECK:                                 %34 = arith.muli %30, %18 : i8
// CHECK:                                 %35 = arith.addi %33, %34 : i8
// CHECK:                                 affine.store %35, %arg35[%arg37, %arg38 + 1, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %36 = affine.load %arg32[%arg36, %arg38 + 1, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %37 = affine.load %arg34[%arg37, %arg38 + 1, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %38 = affine.load %arg35[%arg37, %arg38 + 1, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %39 = hls.affine.select #set(%arg36) %37, %38 : i8
// CHECK:                                 %40 = arith.muli %36, %18 : i8
// CHECK:                                 %41 = arith.addi %39, %40 : i8
// CHECK:                                 affine.store %41, %arg35[%arg37, %arg38 + 1, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                               } {parallel, point}
// CHECK:                             } {parallel, point}
// CHECK:                           } {parallel, point}
// CHECK:                         } {point}
// CHECK:                       }
// CHECK:                       hls.dataflow.node(%16) -> (%arg28) [%arg31, %arg27, %arg23] {inputTaps = [0 : i32], level = 0 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<64x28x28xi8, #hls.mem<dram>>[index, index, index] {
// CHECK:                       ^bb0(%arg32: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg33: memref<64x28x28xi8, #hls.mem<dram>>, %arg34: index, %arg35: index, %arg36: index):
// CHECK:                         affine.for %arg37 = 0 to 16 {
// CHECK:                           affine.for %arg38 = 0 to 14 step 2 {
// CHECK:                             affine.for %arg39 = 0 to 14 step 2 {
// CHECK:                               %17 = affine.load %arg32[%arg37, %arg38, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                               affine.store %17, %arg33[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14, %arg39 + symbol(%arg36) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                               %18 = affine.load %arg32[%arg37, %arg38, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                               affine.store %18, %arg33[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14, %arg39 + symbol(%arg36) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                               %19 = affine.load %arg32[%arg37, %arg38 + 1, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                               affine.store %19, %arg33[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14 + 1, %arg39 + symbol(%arg36) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                               %20 = affine.load %arg32[%arg37, %arg38 + 1, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                               affine.store %20, %arg33[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14 + 1, %arg39 + symbol(%arg36) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
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
// CHECK:         %true = arith.constant true
// CHECK:         hls.dataflow.stream_write %arg15, %true : <i1, 1>, i1
// CHECK:       }
// CHECK:       %9 = hls.dataflow.buffer {depth = 1 : i32} : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:       %10 = hls.dataflow.stream {depth = 1 : i32} : <i1, 1>
// CHECK:       %11 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:       hls.dataflow.node(%2, %1, %arg6, %8, %7) -> (%10, %9, %11) {inputTaps = [2 : i32, 2 : i32, 0 : i32, 0 : i32, 0 : i32], level = 2 : i32} : (!hls.stream<i1, 3>, memref<64x56x56xi8, #hls.mem<dram>>, memref<64x64xi8, #hls.mem<dram>>, !hls.stream<i1, 1>, memref<64x28x28xi8, #hls.mem<dram>>) -> (!hls.stream<i1, 1>, memref<64x28x28xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>) {
// CHECK:       ^bb0(%arg12: !hls.stream<i1, 3>, %arg13: memref<64x56x56xi8, #hls.mem<dram>>, %arg14: memref<64x64xi8, #hls.mem<dram>>, %arg15: !hls.stream<i1, 1>, %arg16: memref<64x28x28xi8, #hls.mem<dram>>, %arg17: !hls.stream<i1, 1>, %arg18: memref<64x28x28xi8, #hls.mem<dram>>, %arg19: memref<64x28x28xi8, #hls.mem<dram>>):
// CHECK:         hls.dataflow.stream_read %arg15 : (!hls.stream<i1, 1>) -> ()
// CHECK:         hls.dataflow.stream_read %arg12 : (!hls.stream<i1, 3>) -> ()
// CHECK:         affine.for %arg20 = 0 to 4 {
// CHECK:           affine.for %arg21 = 0 to 4 {
// CHECK:             affine.for %arg22 = 0 to 2 {
// CHECK:               affine.for %arg23 = 0 to 2 {
// CHECK:                 hls.dataflow.schedule legal(%arg22, %arg23, %arg14, %arg16, %arg13, %arg20, %arg18, %arg19, %arg21) : index, index, memref<64x64xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>, memref<64x56x56xi8, #hls.mem<dram>>, index, memref<64x28x28xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>, index {
// CHECK:                 ^bb0(%arg24: index, %arg25: index, %arg26: memref<64x64xi8, #hls.mem<dram>>, %arg27: memref<64x28x28xi8, #hls.mem<dram>>, %arg28: memref<64x56x56xi8, #hls.mem<dram>>, %arg29: index, %arg30: memref<64x28x28xi8, #hls.mem<dram>>, %arg31: memref<64x28x28xi8, #hls.mem<dram>>, %arg32: index):
// CHECK:                   %13 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                   %14 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                   %15 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                   %16 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:                   %17 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                   hls.dataflow.node(%arg28) -> (%17) [%arg29, %arg24, %arg25] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x56x56xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
// CHECK:                   ^bb0(%arg33: memref<64x56x56xi8, #hls.mem<dram>>, %arg34: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg35: index, %arg36: index, %arg37: index):
// CHECK:                     affine.for %arg38 = 0 to 16 {
// CHECK:                       affine.for %arg39 = 0 to 14 {
// CHECK:                         affine.for %arg40 = 0 to 14 {
// CHECK:                           %19 = affine.load %arg33[%arg38 + symbol(%arg35) * 16, %arg39 * 2 + symbol(%arg36) * 28, %arg40 * 2 + symbol(%arg37) * 28] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:                           affine.store %19, %arg34[%arg38, %arg39, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                         } {parallel}
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   }
// CHECK:                   hls.dataflow.node(%arg26) -> (%16) [%arg32, %arg29] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x64xi8, #hls.mem<dram>>) -> memref<16x16xi8, #hls.mem<bram_t2p>>[index, index] {
// CHECK:                   ^bb0(%arg33: memref<64x64xi8, #hls.mem<dram>>, %arg34: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg35: index, %arg36: index):
// CHECK:                     affine.for %arg37 = 0 to 16 {
// CHECK:                       affine.for %arg38 = 0 to 16 {
// CHECK:                         %19 = affine.load %arg33[%arg37 + symbol(%arg35) * 16, %arg38 + symbol(%arg36) * 16] : memref<64x64xi8, #hls.mem<dram>>
// CHECK:                         affine.store %19, %arg34[%arg37, %arg38] : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   }
// CHECK:                   hls.dataflow.node(%arg31) -> (%15) [%arg32, %arg24, %arg25] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
// CHECK:                   ^bb0(%arg33: memref<64x28x28xi8, #hls.mem<dram>>, %arg34: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg35: index, %arg36: index, %arg37: index):
// CHECK:                     affine.for %arg38 = 0 to 16 {
// CHECK:                       affine.for %arg39 = 0 to 14 {
// CHECK:                         affine.for %arg40 = 0 to 14 {
// CHECK:                           %19 = affine.load %arg33[%arg38 + symbol(%arg35) * 16, %arg39 + symbol(%arg36) * 14, %arg40 + symbol(%arg37) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                           affine.store %19, %arg34[%arg38, %arg39, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                         } {parallel}
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   }
// CHECK:                   hls.dataflow.node(%arg27) -> (%14) [%arg32, %arg24, %arg25] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
// CHECK:                   ^bb0(%arg33: memref<64x28x28xi8, #hls.mem<dram>>, %arg34: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg35: index, %arg36: index, %arg37: index):
// CHECK:                     affine.for %arg38 = 0 to 16 {
// CHECK:                       affine.for %arg39 = 0 to 14 {
// CHECK:                         affine.for %arg40 = 0 to 14 {
// CHECK:                           %19 = affine.load %arg33[%arg38 + symbol(%arg35) * 16, %arg39 + symbol(%arg36) * 14, %arg40 + symbol(%arg37) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                           affine.store %19, %arg34[%arg38, %arg39, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                         } {parallel}
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   }
// CHECK:                   %18 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                   hls.dataflow.node(%14, %17, %16, %15) -> (%13, %18) [%arg29] {inputTaps = [0 : i32, 0 : i32, 0 : i32, 0 : i32], level = 1 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x16xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> (memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>)[index] {
// CHECK:                   ^bb0(%arg33: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg34: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg35: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg36: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg37: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg38: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg39: index):
// CHECK:                     %c-24_i8 = arith.constant -24 : i8
// CHECK:                     affine.for %arg40 = 0 to 16 {
// CHECK:                       affine.for %arg41 = 0 to 16 {
// CHECK:                         affine.for %arg42 = 0 to 14 {
// CHECK:                           affine.for %arg43 = 0 to 14 {
// CHECK:                             %19 = affine.load %arg34[%arg40, %arg42, %arg43] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                             %20 = affine.load %arg35[%arg41, %arg40] : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:                             %21 = affine.load %arg36[%arg41, %arg42, %arg43] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                             %22 = affine.load %arg38[%arg41, %arg42, %arg43] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                             %23 = hls.affine.select #set(%arg40) %21, %22 : i8
// CHECK:                             %24 = arith.muli %19, %20 : i8
// CHECK:                             %25 = arith.addi %23, %24 : i8
// CHECK:                             affine.store %25, %arg38[%arg41, %arg42, %arg43] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                             %26 = affine.load %arg33[%arg41, %arg42, %arg43] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                             %27 = arith.addi %26, %25 : i8
// CHECK:                             %28 = arith.cmpi ugt, %27, %c-24_i8 : i8
// CHECK:                             %29 = arith.select %28, %27, %c-24_i8 : i8
// CHECK:                             affine.if #set2(%arg40)[%arg39] {
// CHECK:                               affine.store %29, %arg37[%arg41, %arg42, %arg43] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                             }
// CHECK:                           } {parallel, point}
// CHECK:                         } {parallel, point}
// CHECK:                       } {parallel, point}
// CHECK:                     } {point}
// CHECK:                   }
// CHECK:                   hls.dataflow.node(%18) -> (%arg31) [%arg32, %arg24, %arg25] {inputTaps = [0 : i32], level = 0 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<64x28x28xi8, #hls.mem<dram>>[index, index, index] {
// CHECK:                   ^bb0(%arg33: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg34: memref<64x28x28xi8, #hls.mem<dram>>, %arg35: index, %arg36: index, %arg37: index):
// CHECK:                     affine.for %arg38 = 0 to 16 {
// CHECK:                       affine.for %arg39 = 0 to 14 {
// CHECK:                         affine.for %arg40 = 0 to 14 {
// CHECK:                           %19 = affine.load %arg33[%arg38, %arg39, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                           affine.store %19, %arg34[%arg38 + symbol(%arg35) * 16, %arg39 + symbol(%arg36) * 14, %arg40 + symbol(%arg37) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                         } {parallel}
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   }
// CHECK:                   hls.dataflow.node(%13) -> (%arg30) [%arg32, %arg24, %arg25] {inputTaps = [0 : i32], level = 0 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<64x28x28xi8, #hls.mem<dram>>[index, index, index] {
// CHECK:                   ^bb0(%arg33: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg34: memref<64x28x28xi8, #hls.mem<dram>>, %arg35: index, %arg36: index, %arg37: index):
// CHECK:                     affine.for %arg38 = 0 to 16 {
// CHECK:                       affine.for %arg39 = 0 to 14 {
// CHECK:                         affine.for %arg40 = 0 to 14 {
// CHECK:                           %19 = affine.load %arg33[%arg38, %arg39, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                           affine.store %19, %arg34[%arg38 + symbol(%arg35) * 16, %arg39 + symbol(%arg36) * 14, %arg40 + symbol(%arg37) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                         } {parallel}
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   }
// CHECK:                 }
// CHECK:               } {parallel}
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         }
// CHECK:         %true = arith.constant true
// CHECK:         hls.dataflow.stream_write %arg17, %true : <i1, 1>, i1
// CHECK:       }
// CHECK:       %12 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64xi8, #hls.mem<bram_t2p>>
// CHECK:       hls.dataflow.node(%10, %9) -> (%12) {inputTaps = [0 : i32, 0 : i32], level = 1 : i32} : (!hls.stream<i1, 1>, memref<64x28x28xi8, #hls.mem<dram>>) -> memref<64xi8, #hls.mem<bram_t2p>> {
// CHECK:       ^bb0(%arg12: !hls.stream<i1, 1>, %arg13: memref<64x28x28xi8, #hls.mem<dram>>, %arg14: memref<64xi8, #hls.mem<bram_t2p>>):
// CHECK:         hls.dataflow.stream_read %arg12 : (!hls.stream<i1, 1>) -> ()
// CHECK:         affine.for %arg15 = 0 to 2 {
// CHECK:           affine.for %arg16 = 0 to 2 {
// CHECK:             affine.for %arg17 = 0 to 4 {
// CHECK:               hls.dataflow.schedule legal(%arg13, %arg15, %arg14, %arg16, %arg17) : memref<64x28x28xi8, #hls.mem<dram>>, index, memref<64xi8, #hls.mem<bram_t2p>>, index, index {
// CHECK:               ^bb0(%arg18: memref<64x28x28xi8, #hls.mem<dram>>, %arg19: index, %arg20: memref<64xi8, #hls.mem<bram_t2p>>, %arg21: index, %arg22: index):
// CHECK:                 %13 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                 hls.dataflow.node(%arg18) -> (%13) [%arg22, %arg19, %arg21] {inputTaps = [0 : i32], level = 1 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
// CHECK:                 ^bb0(%arg23: memref<64x28x28xi8, #hls.mem<dram>>, %arg24: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg25: index, %arg26: index, %arg27: index):
// CHECK:                   affine.for %arg28 = 0 to 16 {
// CHECK:                     affine.for %arg29 = 0 to 14 {
// CHECK:                       affine.for %arg30 = 0 to 14 {
// CHECK:                         %14 = affine.load %arg23[%arg28 + symbol(%arg25) * 16, %arg29 + symbol(%arg26) * 14, %arg30 + symbol(%arg27) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                         affine.store %14, %arg24[%arg28, %arg29, %arg30] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   } {parallel}
// CHECK:                 }
// CHECK:                 hls.dataflow.node(%13) -> (%arg20) [%arg22, %arg19, %arg21] {inputTaps = [0 : i32], level = 0 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<64xi8, #hls.mem<bram_t2p>>[index, index, index] {
// CHECK:                 ^bb0(%arg23: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg24: memref<64xi8, #hls.mem<bram_t2p>>, %arg25: index, %arg26: index, %arg27: index):
// CHECK:                   %c-24_i8 = arith.constant -24 : i8
// CHECK:                   affine.for %arg28 = 0 to 14 {
// CHECK:                     affine.for %arg29 = 0 to 14 {
// CHECK:                       affine.for %arg30 = 0 to 16 {
// CHECK:                         %14 = affine.load %arg23[%arg30, %arg28, %arg29] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                         %15 = affine.load %arg24[%arg30 + symbol(%arg25) * 16] : memref<64xi8, #hls.mem<bram_t2p>>
// CHECK:                         %16 = arith.addi %15, %14 : i8
// CHECK:                         %17 = arith.divui %16, %c-24_i8 : i8
// CHECK:                         %18 = hls.affine.select #set3(%arg28, %arg29, %arg26, %arg27) %17, %16 : i8
// CHECK:                         affine.store %18, %arg24[%arg30 + symbol(%arg25) * 16] : memref<64xi8, #hls.mem<bram_t2p>>
// CHECK:                       } {parallel, point}
// CHECK:                     } {point}
// CHECK:                   } {point}
// CHECK:                 }
// CHECK:               }
// CHECK:             } {parallel}
// CHECK:           }
// CHECK:         }
// CHECK:       }
// CHECK:       hls.dataflow.node(%12, %arg9) -> (%arg7) {inputTaps = [0 : i32, 0 : i32], level = 0 : i32} : (memref<64xi8, #hls.mem<bram_t2p>>, memref<1000x64xi8, #hls.mem<dram>>) -> memref<1000xi8, #hls.mem<dram>> {
// CHECK:       ^bb0(%arg12: memref<64xi8, #hls.mem<bram_t2p>>, %arg13: memref<1000x64xi8, #hls.mem<dram>>, %arg14: memref<1000xi8, #hls.mem<dram>>):
// CHECK:         affine.for %arg15 = 0 to 4 {
// CHECK:           affine.for %arg16 = 0 to 100 {
// CHECK:             hls.dataflow.schedule legal(%arg15, %arg16, %arg12, %arg13, %arg14) : index, index, memref<64xi8, #hls.mem<bram_t2p>>, memref<1000x64xi8, #hls.mem<dram>>, memref<1000xi8, #hls.mem<dram>> {
// CHECK:             ^bb0(%arg17: index, %arg18: index, %arg19: memref<64xi8, #hls.mem<bram_t2p>>, %arg20: memref<1000x64xi8, #hls.mem<dram>>, %arg21: memref<1000xi8, #hls.mem<dram>>):
// CHECK:               %13 = hls.dataflow.buffer {depth = 1 : i32} : memref<10x16xi8, #hls.mem<bram_t2p>>
// CHECK:               %14 = hls.dataflow.buffer {depth = 1 : i32} : memref<10xi8, #hls.mem<bram_t2p>>
// CHECK:               hls.dataflow.node(%arg21) -> (%14) [%arg18] {inputTaps = [0 : i32], level = 2 : i32} : (memref<1000xi8, #hls.mem<dram>>) -> memref<10xi8, #hls.mem<bram_t2p>>[index] {
// CHECK:               ^bb0(%arg22: memref<1000xi8, #hls.mem<dram>>, %arg23: memref<10xi8, #hls.mem<bram_t2p>>, %arg24: index):
// CHECK:                 affine.for %arg25 = 0 to 10 {
// CHECK:                   %16 = affine.load %arg22[%arg25 + symbol(%arg24) * 10] : memref<1000xi8, #hls.mem<dram>>
// CHECK:                   affine.store %16, %arg23[%arg25] : memref<10xi8, #hls.mem<bram_t2p>>
// CHECK:                 } {parallel}
// CHECK:               }
// CHECK:               hls.dataflow.node(%arg20) -> (%13) [%arg18, %arg17] {inputTaps = [0 : i32], level = 2 : i32} : (memref<1000x64xi8, #hls.mem<dram>>) -> memref<10x16xi8, #hls.mem<bram_t2p>>[index, index] {
// CHECK:               ^bb0(%arg22: memref<1000x64xi8, #hls.mem<dram>>, %arg23: memref<10x16xi8, #hls.mem<bram_t2p>>, %arg24: index, %arg25: index):
// CHECK:                 affine.for %arg26 = 0 to 10 {
// CHECK:                   affine.for %arg27 = 0 to 16 {
// CHECK:                     %16 = affine.load %arg22[%arg26 + symbol(%arg24) * 10, %arg27 + symbol(%arg25) * 16] : memref<1000x64xi8, #hls.mem<dram>>
// CHECK:                     affine.store %16, %arg23[%arg26, %arg27] : memref<10x16xi8, #hls.mem<bram_t2p>>
// CHECK:                   } {parallel}
// CHECK:                 } {parallel}
// CHECK:               }
// CHECK:               %15 = hls.dataflow.buffer {depth = 1 : i32} : memref<10xi8, #hls.mem<bram_t2p>>
// CHECK:               hls.dataflow.node(%arg19, %13, %14) -> (%15) [%arg17] {inputTaps = [0 : i32, 0 : i32, 0 : i32], level = 1 : i32} : (memref<64xi8, #hls.mem<bram_t2p>>, memref<10x16xi8, #hls.mem<bram_t2p>>, memref<10xi8, #hls.mem<bram_t2p>>) -> memref<10xi8, #hls.mem<bram_t2p>>[index] {
// CHECK:               ^bb0(%arg22: memref<64xi8, #hls.mem<bram_t2p>>, %arg23: memref<10x16xi8, #hls.mem<bram_t2p>>, %arg24: memref<10xi8, #hls.mem<bram_t2p>>, %arg25: memref<10xi8, #hls.mem<bram_t2p>>, %arg26: index):
// CHECK:                 %c-24_i8 = arith.constant -24 : i8
// CHECK:                 affine.for %arg27 = 0 to 16 {
// CHECK:                   affine.for %arg28 = 0 to 10 {
// CHECK:                     %16 = affine.load %arg24[%arg28] : memref<10xi8, #hls.mem<bram_t2p>>
// CHECK:                     %17 = affine.load %arg25[%arg28] : memref<10xi8, #hls.mem<bram_t2p>>
// CHECK:                     %18 = hls.affine.select #set(%arg27) %16, %17 : i8
// CHECK:                     %19 = hls.affine.select #set4(%arg27, %arg26) %c-24_i8, %18 : i8
// CHECK:                     %20 = affine.load %arg22[%arg27 + symbol(%arg26) * 16] : memref<64xi8, #hls.mem<bram_t2p>>
// CHECK:                     %21 = affine.load %arg23[%arg28, %arg27] : memref<10x16xi8, #hls.mem<bram_t2p>>
// CHECK:                     %22 = arith.muli %20, %21 : i8
// CHECK:                     %23 = arith.addi %19, %22 : i8
// CHECK:                     affine.store %23, %arg25[%arg28] : memref<10xi8, #hls.mem<bram_t2p>>
// CHECK:                   } {parallel, point}
// CHECK:                 } {point}
// CHECK:               }
// CHECK:               hls.dataflow.node(%15) -> (%arg21) [%arg18] {inputTaps = [0 : i32], level = 0 : i32} : (memref<10xi8, #hls.mem<bram_t2p>>) -> memref<1000xi8, #hls.mem<dram>>[index] {
// CHECK:               ^bb0(%arg22: memref<10xi8, #hls.mem<bram_t2p>>, %arg23: memref<1000xi8, #hls.mem<dram>>, %arg24: index):
// CHECK:                 affine.for %arg25 = 0 to 10 {
// CHECK:                   %16 = affine.load %arg22[%arg25] : memref<10xi8, #hls.mem<bram_t2p>>
// CHECK:                   affine.store %16, %arg23[%arg25 + symbol(%arg24) * 10] : memref<1000xi8, #hls.mem<dram>>
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
  func.func @forward(%arg0: memref<64x56x56xi8, #hls.mem<dram>>, %arg1: memref<1000x64xi8, #hls.mem<dram>>, %arg2: memref<64x64xi8, #hls.mem<dram>>, %arg3: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg4: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg5: memref<1000xi8, #hls.mem<dram>>) attributes {top_func} {
    hls.dataflow.schedule legal(%arg2, %arg5, %arg3, %arg1, %arg0, %arg4) : memref<64x64xi8, #hls.mem<dram>>, memref<1000xi8, #hls.mem<dram>>, memref<64x64x3x3xi8, #hls.mem<dram>>, memref<1000x64xi8, #hls.mem<dram>>, memref<64x56x56xi8, #hls.mem<dram>>, memref<64x64x3x3xi8, #hls.mem<dram>> {
    ^bb0(%arg6: memref<64x64xi8, #hls.mem<dram>>, %arg7: memref<1000xi8, #hls.mem<dram>>, %arg8: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg9: memref<1000x64xi8, #hls.mem<dram>>, %arg10: memref<64x56x56xi8, #hls.mem<dram>>, %arg11: memref<64x64x3x3xi8, #hls.mem<dram>>):
      hls.dataflow.node() -> (%arg10) {inputTaps = [], level = 6 : i32} : () -> memref<64x56x56xi8, #hls.mem<dram>> {
      ^bb0(%arg12: memref<64x56x56xi8, #hls.mem<dram>>):
        affine.for %arg13 = 0 to 4 {
          affine.for %arg14 = 0 to 4 {
            affine.for %arg15 = 0 to 4 {
              hls.dataflow.schedule legal(%arg13, %arg15, %arg12, %arg14) : index, index, memref<64x56x56xi8, #hls.mem<dram>>, index {
              ^bb0(%arg16: index, %arg17: index, %arg18: memref<64x56x56xi8, #hls.mem<dram>>, %arg19: index):
                %7 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                hls.dataflow.node(%arg18) -> (%7) [%arg16, %arg19, %arg17] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x56x56xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
                ^bb0(%arg20: memref<64x56x56xi8, #hls.mem<dram>>, %arg21: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg22: index, %arg23: index, %arg24: index):
                  affine.for %arg25 = 0 to 16 {
                    affine.for %arg26 = 0 to 14 {
                      affine.for %arg27 = 0 to 14 {
                        %9 = affine.load %arg20[%arg25 + symbol(%arg22) * 16, %arg26 + symbol(%arg23) * 14, %arg27 + symbol(%arg24) * 14] : memref<64x56x56xi8, #hls.mem<dram>>
                        affine.store %9, %arg21[%arg25, %arg26, %arg27] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                      } {parallel}
                    } {parallel}
                  } {parallel}
                }
                %8 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                hls.dataflow.node(%7) -> (%8) {inputTaps = [0 : i32], level = 1 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>> {
                ^bb0(%arg20: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg21: memref<16x14x14xi8, #hls.mem<bram_t2p>>):
                  %c-24_i8 = arith.constant -24 : i8
                  affine.for %arg22 = 0 to 16 {
                    affine.for %arg23 = 0 to 14 {
                      affine.for %arg24 = 0 to 14 {
                        %9 = affine.load %arg20[%arg22, %arg23, %arg24] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                        %10 = arith.cmpi ugt, %9, %c-24_i8 : i8
                        %11 = arith.select %10, %9, %c-24_i8 : i8
                        affine.store %11, %arg21[%arg22, %arg23, %arg24] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                      } {parallel, point}
                    } {parallel, point}
                  } {parallel, point}
                }
                hls.dataflow.node(%8) -> (%arg18) [%arg16, %arg19, %arg17] {inputTaps = [0 : i32], level = 0 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<64x56x56xi8, #hls.mem<dram>>[index, index, index] {
                ^bb0(%arg20: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg21: memref<64x56x56xi8, #hls.mem<dram>>, %arg22: index, %arg23: index, %arg24: index):
                  affine.for %arg25 = 0 to 16 {
                    affine.for %arg26 = 0 to 14 {
                      affine.for %arg27 = 0 to 14 {
                        %9 = affine.load %arg20[%arg25, %arg26, %arg27] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                        affine.store %9, %arg21[%arg25 + symbol(%arg22) * 16, %arg26 + symbol(%arg23) * 14, %arg27 + symbol(%arg24) * 14] : memref<64x56x56xi8, #hls.mem<dram>>
                      } {parallel}
                    } {parallel}
                  } {parallel}
                }
              }
            } {parallel}
          } {parallel}
        } {parallel}
      }
      %0 = hls.dataflow.buffer {depth = 3 : i32} : memref<64x56x56xi8, #hls.mem<dram>>
      %1 = hls.dataflow.buffer {depth = 1 : i32} : memref<64x56x56xi8, #hls.mem<dram>>
      hls.dataflow.node(%arg10) -> (%0, %1) {inputTaps = [0 : i32], level = 5 : i32} : (memref<64x56x56xi8, #hls.mem<dram>>) -> (memref<64x56x56xi8, #hls.mem<dram>>, memref<64x56x56xi8, #hls.mem<dram>>) {
      ^bb0(%arg12: memref<64x56x56xi8, #hls.mem<dram>>, %arg13: memref<64x56x56xi8, #hls.mem<dram>>, %arg14: memref<64x56x56xi8, #hls.mem<dram>>):
        affine.for %arg15 = 0 to 64 {
          affine.for %arg16 = 0 to 56 {
            affine.for %arg17 = 0 to 56 {
              %7 = affine.load %arg12[%arg15, %arg16, %arg17] : memref<64x56x56xi8, #hls.mem<dram>>
              affine.store %7, %arg13[%arg15, %arg16, %arg17] : memref<64x56x56xi8, #hls.mem<dram>>
            } {parallel}
          } {parallel}
        } {parallel}
        affine.for %arg15 = 0 to 64 {
          affine.for %arg16 = 0 to 56 {
            affine.for %arg17 = 0 to 56 {
              %7 = affine.load %arg12[%arg15, %arg16, %arg17] : memref<64x56x56xi8, #hls.mem<dram>>
              affine.store %7, %arg14[%arg15, %arg16, %arg17] : memref<64x56x56xi8, #hls.mem<dram>>
            } {parallel}
          } {parallel}
        } {parallel}
      }
      %2 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, #hls.mem<dram>>
      hls.dataflow.node(%1, %arg11) -> (%2) {inputTaps = [0 : i32, 0 : i32], level = 4 : i32} : (memref<64x56x56xi8, #hls.mem<dram>>, memref<64x64x3x3xi8, #hls.mem<dram>>) -> memref<64x28x28xi8, #hls.mem<dram>> {
      ^bb0(%arg12: memref<64x56x56xi8, #hls.mem<dram>>, %arg13: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg14: memref<64x28x28xi8, #hls.mem<dram>>):
        affine.for %arg15 = 0 to 4 {
          affine.for %arg16 = 0 to 3 {
            affine.for %arg17 = 0 to 3 {
              affine.for %arg18 = 0 to 4 {
                affine.for %arg19 = 0 to 2 {
                  affine.for %arg20 = 0 to 2 {
                    hls.dataflow.schedule legal(%arg17, %arg14, %arg20, %arg16, %arg19, %arg12, %arg15, %arg13, %arg18) : index, memref<64x28x28xi8, #hls.mem<dram>>, index, index, index, memref<64x56x56xi8, #hls.mem<dram>>, index, memref<64x64x3x3xi8, #hls.mem<dram>>, index {
                    ^bb0(%arg21: index, %arg22: memref<64x28x28xi8, #hls.mem<dram>>, %arg23: index, %arg24: index, %arg25: index, %arg26: memref<64x56x56xi8, #hls.mem<dram>>, %arg27: index, %arg28: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg29: index):
                      %7 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                      %8 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, #hls.mem<bram_t2p>>
                      %9 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                      hls.dataflow.node(%arg26) -> (%9) [%arg27, %arg24, %arg25, %arg21, %arg23] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x56x56xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index, index, index] {
                      ^bb0(%arg30: memref<64x56x56xi8, #hls.mem<dram>>, %arg31: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg32: index, %arg33: index, %arg34: index, %arg35: index, %arg36: index):
                        affine.for %arg37 = 0 to 16 {
                          affine.for %arg38 = 0 to 14 step 2 {
                            affine.for %arg39 = 0 to 14 step 2 {
                              %11 = affine.load %arg30[%arg37 + symbol(%arg32) * 16, %arg38 * 2 + symbol(%arg33) + symbol(%arg34) * 28 - 1, %arg39 * 2 + symbol(%arg35) + symbol(%arg36) * 28 - 1] : memref<64x56x56xi8, #hls.mem<dram>>
                              affine.store %11, %arg31[%arg37, %arg38, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              %12 = affine.load %arg30[%arg37 + symbol(%arg32) * 16, %arg38 * 2 + symbol(%arg33) + symbol(%arg34) * 28 - 1, %arg39 * 2 + symbol(%arg35) + symbol(%arg36) * 28 + 1] : memref<64x56x56xi8, #hls.mem<dram>>
                              affine.store %12, %arg31[%arg37, %arg38, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              %13 = affine.load %arg30[%arg37 + symbol(%arg32) * 16, %arg38 * 2 + symbol(%arg33) + symbol(%arg34) * 28 + 1, %arg39 * 2 + symbol(%arg35) + symbol(%arg36) * 28 - 1] : memref<64x56x56xi8, #hls.mem<dram>>
                              affine.store %13, %arg31[%arg37, %arg38 + 1, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              %14 = affine.load %arg30[%arg37 + symbol(%arg32) * 16, %arg38 * 2 + symbol(%arg33) + symbol(%arg34) * 28 + 1, %arg39 * 2 + symbol(%arg35) + symbol(%arg36) * 28 + 1] : memref<64x56x56xi8, #hls.mem<dram>>
                              affine.store %14, %arg31[%arg37, %arg38 + 1, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                            } {parallel}
                          } {parallel}
                        } {parallel}
                      }
                      hls.dataflow.node(%arg28) -> (%8) [%arg29, %arg27, %arg24, %arg21] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x64x3x3xi8, #hls.mem<dram>>) -> memref<16x16xi8, #hls.mem<bram_t2p>>[index, index, index, index] {
                      ^bb0(%arg30: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg31: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg32: index, %arg33: index, %arg34: index, %arg35: index):
                        affine.for %arg36 = 0 to 16 {
                          affine.for %arg37 = 0 to 16 {
                            %11 = affine.load %arg30[%arg36 + symbol(%arg32) * 16, %arg37 + symbol(%arg33) * 16, symbol(%arg34), symbol(%arg35)] : memref<64x64x3x3xi8, #hls.mem<dram>>
                            affine.store %11, %arg31[%arg36, %arg37] : memref<16x16xi8, #hls.mem<bram_t2p>>
                          } {parallel}
                        } {parallel}
                      }
                      hls.dataflow.node(%arg22) -> (%7) [%arg29, %arg25, %arg23] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
                      ^bb0(%arg30: memref<64x28x28xi8, #hls.mem<dram>>, %arg31: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg32: index, %arg33: index, %arg34: index):
                        affine.for %arg35 = 0 to 16 {
                          affine.for %arg36 = 0 to 14 step 2 {
                            affine.for %arg37 = 0 to 14 step 2 {
                              %11 = affine.load %arg30[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14, %arg37 + symbol(%arg34) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                              affine.store %11, %arg31[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              %12 = affine.load %arg30[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14, %arg37 + symbol(%arg34) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
                              affine.store %12, %arg31[%arg35, %arg36, %arg37 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              %13 = affine.load %arg30[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14 + 1, %arg37 + symbol(%arg34) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                              affine.store %13, %arg31[%arg35, %arg36 + 1, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              %14 = affine.load %arg30[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14 + 1, %arg37 + symbol(%arg34) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
                              affine.store %14, %arg31[%arg35, %arg36 + 1, %arg37 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                            } {parallel}
                          } {parallel}
                        } {parallel}
                      }
                      %10 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                      hls.dataflow.node(%9, %8, %7) -> (%10) [%arg21, %arg27, %arg24] {inputTaps = [0 : i32, 0 : i32, 0 : i32], level = 1 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x16xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
                      ^bb0(%arg30: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg31: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg32: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg33: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg34: index, %arg35: index, %arg36: index):
                        %c-24_i8 = arith.constant -24 : i8
                        affine.for %arg37 = 0 to 16 {
                          affine.for %arg38 = 0 to 16 {
                            affine.for %arg39 = 0 to 14 step 2 {
                              affine.for %arg40 = 0 to 14 step 2 {
                                %11 = affine.load %arg30[%arg37, %arg39, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %12 = affine.load %arg31[%arg38, %arg37] : memref<16x16xi8, #hls.mem<bram_t2p>>
                                %13 = affine.load %arg32[%arg38, %arg39, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %14 = affine.load %arg33[%arg38, %arg39, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %15 = hls.affine.select #set(%arg37) %13, %14 : i8
                                %16 = arith.muli %11, %12 : i8
                                %17 = arith.addi %15, %16 : i8
                                %18 = arith.cmpi ugt, %17, %c-24_i8 : i8
                                %19 = arith.select %18, %17, %c-24_i8 : i8
                                %20 = hls.affine.select #set1(%arg36, %arg34, %arg37, %arg35) %19, %17 : i8
                                affine.store %20, %arg33[%arg38, %arg39, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %21 = affine.load %arg30[%arg37, %arg39, %arg40 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %22 = affine.load %arg32[%arg38, %arg39, %arg40 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %23 = affine.load %arg33[%arg38, %arg39, %arg40 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %24 = hls.affine.select #set(%arg37) %22, %23 : i8
                                %25 = arith.muli %21, %12 : i8
                                %26 = arith.addi %24, %25 : i8
                                %27 = arith.cmpi ugt, %26, %c-24_i8 : i8
                                %28 = arith.select %27, %26, %c-24_i8 : i8
                                %29 = hls.affine.select #set1(%arg36, %arg34, %arg37, %arg35) %28, %26 : i8
                                affine.store %29, %arg33[%arg38, %arg39, %arg40 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %30 = affine.load %arg30[%arg37, %arg39 + 1, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %31 = affine.load %arg32[%arg38, %arg39 + 1, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %32 = affine.load %arg33[%arg38, %arg39 + 1, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %33 = hls.affine.select #set(%arg37) %31, %32 : i8
                                %34 = arith.muli %30, %12 : i8
                                %35 = arith.addi %33, %34 : i8
                                %36 = arith.cmpi ugt, %35, %c-24_i8 : i8
                                %37 = arith.select %36, %35, %c-24_i8 : i8
                                %38 = hls.affine.select #set1(%arg36, %arg34, %arg37, %arg35) %37, %35 : i8
                                affine.store %38, %arg33[%arg38, %arg39 + 1, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %39 = affine.load %arg30[%arg37, %arg39 + 1, %arg40 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %40 = affine.load %arg32[%arg38, %arg39 + 1, %arg40 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %41 = affine.load %arg33[%arg38, %arg39 + 1, %arg40 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %42 = hls.affine.select #set(%arg37) %40, %41 : i8
                                %43 = arith.muli %39, %12 : i8
                                %44 = arith.addi %42, %43 : i8
                                %45 = arith.cmpi ugt, %44, %c-24_i8 : i8
                                %46 = arith.select %45, %44, %c-24_i8 : i8
                                %47 = hls.affine.select #set1(%arg36, %arg34, %arg37, %arg35) %46, %44 : i8
                                affine.store %47, %arg33[%arg38, %arg39 + 1, %arg40 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              } {parallel, point}
                            } {parallel, point}
                          } {parallel, point}
                        } {point}
                      }
                      hls.dataflow.node(%10) -> (%arg22) [%arg29, %arg25, %arg23] {inputTaps = [0 : i32], level = 0 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<64x28x28xi8, #hls.mem<dram>>[index, index, index] {
                      ^bb0(%arg30: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg31: memref<64x28x28xi8, #hls.mem<dram>>, %arg32: index, %arg33: index, %arg34: index):
                        affine.for %arg35 = 0 to 16 {
                          affine.for %arg36 = 0 to 14 step 2 {
                            affine.for %arg37 = 0 to 14 step 2 {
                              %11 = affine.load %arg30[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              affine.store %11, %arg31[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14, %arg37 + symbol(%arg34) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                              %12 = affine.load %arg30[%arg35, %arg36, %arg37 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              affine.store %12, %arg31[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14, %arg37 + symbol(%arg34) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
                              %13 = affine.load %arg30[%arg35, %arg36 + 1, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              affine.store %13, %arg31[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14 + 1, %arg37 + symbol(%arg34) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                              %14 = affine.load %arg30[%arg35, %arg36 + 1, %arg37 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              affine.store %14, %arg31[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14 + 1, %arg37 + symbol(%arg34) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
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
      %3 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, #hls.mem<dram>>
      hls.dataflow.node(%arg8, %2) -> (%3) {inputTaps = [0 : i32, 0 : i32], level = 3 : i32} : (memref<64x64x3x3xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>) -> memref<64x28x28xi8, #hls.mem<dram>> {
      ^bb0(%arg12: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg13: memref<64x28x28xi8, #hls.mem<dram>>, %arg14: memref<64x28x28xi8, #hls.mem<dram>>):
        affine.for %arg15 = 0 to 4 {
          affine.for %arg16 = 0 to 3 {
            affine.for %arg17 = 0 to 3 {
              affine.for %arg18 = 0 to 4 {
                affine.for %arg19 = 0 to 2 {
                  affine.for %arg20 = 0 to 2 {
                    hls.dataflow.schedule legal(%arg20, %arg16, %arg15, %arg17, %arg19, %arg14, %arg12, %arg13, %arg18) : index, index, index, index, index, memref<64x28x28xi8, #hls.mem<dram>>, memref<64x64x3x3xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>, index {
                    ^bb0(%arg21: index, %arg22: index, %arg23: index, %arg24: index, %arg25: index, %arg26: memref<64x28x28xi8, #hls.mem<dram>>, %arg27: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg28: memref<64x28x28xi8, #hls.mem<dram>>, %arg29: index):
                      %7 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                      %8 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, #hls.mem<bram_t2p>>
                      %9 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                      hls.dataflow.node(%arg28) -> (%9) [%arg23, %arg22, %arg25, %arg24, %arg21] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index, index, index] {
                      ^bb0(%arg30: memref<64x28x28xi8, #hls.mem<dram>>, %arg31: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg32: index, %arg33: index, %arg34: index, %arg35: index, %arg36: index):
                        affine.for %arg37 = 0 to 16 {
                          affine.for %arg38 = 0 to 14 step 2 {
                            affine.for %arg39 = 0 to 14 step 2 {
                              %11 = affine.load %arg30[%arg37 + symbol(%arg32) * 16, %arg38 + symbol(%arg33) + symbol(%arg34) * 14 - 1, %arg39 + symbol(%arg35) + symbol(%arg36) * 14 - 1] : memref<64x28x28xi8, #hls.mem<dram>>
                              affine.store %11, %arg31[%arg37, %arg38, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              %12 = affine.load %arg30[%arg37 + symbol(%arg32) * 16, %arg38 + symbol(%arg33) + symbol(%arg34) * 14 - 1, %arg39 + symbol(%arg35) + symbol(%arg36) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                              affine.store %12, %arg31[%arg37, %arg38, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              %13 = affine.load %arg30[%arg37 + symbol(%arg32) * 16, %arg38 + symbol(%arg33) + symbol(%arg34) * 14, %arg39 + symbol(%arg35) + symbol(%arg36) * 14 - 1] : memref<64x28x28xi8, #hls.mem<dram>>
                              affine.store %13, %arg31[%arg37, %arg38 + 1, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              %14 = affine.load %arg30[%arg37 + symbol(%arg32) * 16, %arg38 + symbol(%arg33) + symbol(%arg34) * 14, %arg39 + symbol(%arg35) + symbol(%arg36) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                              affine.store %14, %arg31[%arg37, %arg38 + 1, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                            } {parallel}
                          } {parallel}
                        } {parallel}
                      }
                      hls.dataflow.node(%arg27) -> (%8) [%arg29, %arg23, %arg22, %arg24] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x64x3x3xi8, #hls.mem<dram>>) -> memref<16x16xi8, #hls.mem<bram_t2p>>[index, index, index, index] {
                      ^bb0(%arg30: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg31: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg32: index, %arg33: index, %arg34: index, %arg35: index):
                        affine.for %arg36 = 0 to 16 {
                          affine.for %arg37 = 0 to 16 {
                            %11 = affine.load %arg30[%arg36 + symbol(%arg32) * 16, %arg37 + symbol(%arg33) * 16, symbol(%arg34), symbol(%arg35)] : memref<64x64x3x3xi8, #hls.mem<dram>>
                            affine.store %11, %arg31[%arg36, %arg37] : memref<16x16xi8, #hls.mem<bram_t2p>>
                          } {parallel}
                        } {parallel}
                      }
                      hls.dataflow.node(%arg26) -> (%7) [%arg29, %arg25, %arg21] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
                      ^bb0(%arg30: memref<64x28x28xi8, #hls.mem<dram>>, %arg31: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg32: index, %arg33: index, %arg34: index):
                        affine.for %arg35 = 0 to 16 {
                          affine.for %arg36 = 0 to 14 step 2 {
                            affine.for %arg37 = 0 to 14 step 2 {
                              %11 = affine.load %arg30[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14, %arg37 + symbol(%arg34) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                              affine.store %11, %arg31[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              %12 = affine.load %arg30[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14, %arg37 + symbol(%arg34) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
                              affine.store %12, %arg31[%arg35, %arg36, %arg37 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              %13 = affine.load %arg30[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14 + 1, %arg37 + symbol(%arg34) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                              affine.store %13, %arg31[%arg35, %arg36 + 1, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              %14 = affine.load %arg30[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14 + 1, %arg37 + symbol(%arg34) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
                              affine.store %14, %arg31[%arg35, %arg36 + 1, %arg37 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                            } {parallel}
                          } {parallel}
                        } {parallel}
                      }
                      %10 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                      hls.dataflow.node(%9, %8, %7) -> (%10) {inputTaps = [0 : i32, 0 : i32, 0 : i32], level = 1 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x16xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>> {
                      ^bb0(%arg30: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg31: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg32: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg33: memref<16x14x14xi8, #hls.mem<bram_t2p>>):
                        affine.for %arg34 = 0 to 16 {
                          affine.for %arg35 = 0 to 16 {
                            affine.for %arg36 = 0 to 14 step 2 {
                              affine.for %arg37 = 0 to 14 step 2 {
                                %11 = affine.load %arg30[%arg34, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %12 = affine.load %arg31[%arg35, %arg34] : memref<16x16xi8, #hls.mem<bram_t2p>>
                                %13 = affine.load %arg32[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %14 = affine.load %arg33[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %15 = hls.affine.select #set(%arg34) %13, %14 : i8
                                %16 = arith.muli %11, %12 : i8
                                %17 = arith.addi %15, %16 : i8
                                affine.store %17, %arg33[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %18 = affine.load %arg30[%arg34, %arg36, %arg37 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %19 = affine.load %arg32[%arg35, %arg36, %arg37 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %20 = affine.load %arg33[%arg35, %arg36, %arg37 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %21 = hls.affine.select #set(%arg34) %19, %20 : i8
                                %22 = arith.muli %18, %12 : i8
                                %23 = arith.addi %21, %22 : i8
                                affine.store %23, %arg33[%arg35, %arg36, %arg37 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %24 = affine.load %arg30[%arg34, %arg36 + 1, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %25 = affine.load %arg32[%arg35, %arg36 + 1, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %26 = affine.load %arg33[%arg35, %arg36 + 1, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %27 = hls.affine.select #set(%arg34) %25, %26 : i8
                                %28 = arith.muli %24, %12 : i8
                                %29 = arith.addi %27, %28 : i8
                                affine.store %29, %arg33[%arg35, %arg36 + 1, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %30 = affine.load %arg30[%arg34, %arg36 + 1, %arg37 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %31 = affine.load %arg32[%arg35, %arg36 + 1, %arg37 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %32 = affine.load %arg33[%arg35, %arg36 + 1, %arg37 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %33 = hls.affine.select #set(%arg34) %31, %32 : i8
                                %34 = arith.muli %30, %12 : i8
                                %35 = arith.addi %33, %34 : i8
                                affine.store %35, %arg33[%arg35, %arg36 + 1, %arg37 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              } {parallel, point}
                            } {parallel, point}
                          } {parallel, point}
                        } {point}
                      }
                      hls.dataflow.node(%10) -> (%arg26) [%arg29, %arg25, %arg21] {inputTaps = [0 : i32], level = 0 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<64x28x28xi8, #hls.mem<dram>>[index, index, index] {
                      ^bb0(%arg30: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg31: memref<64x28x28xi8, #hls.mem<dram>>, %arg32: index, %arg33: index, %arg34: index):
                        affine.for %arg35 = 0 to 16 {
                          affine.for %arg36 = 0 to 14 step 2 {
                            affine.for %arg37 = 0 to 14 step 2 {
                              %11 = affine.load %arg30[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              affine.store %11, %arg31[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14, %arg37 + symbol(%arg34) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                              %12 = affine.load %arg30[%arg35, %arg36, %arg37 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              affine.store %12, %arg31[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14, %arg37 + symbol(%arg34) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
                              %13 = affine.load %arg30[%arg35, %arg36 + 1, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              affine.store %13, %arg31[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14 + 1, %arg37 + symbol(%arg34) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                              %14 = affine.load %arg30[%arg35, %arg36 + 1, %arg37 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              affine.store %14, %arg31[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14 + 1, %arg37 + symbol(%arg34) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
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
      %4 = hls.dataflow.buffer {depth = 1 : i32} : memref<64x28x28xi8, #hls.mem<dram>>
      %5 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, #hls.mem<dram>>
      hls.dataflow.node(%0, %arg6, %3) -> (%4, %5) {inputTaps = [2 : i32, 0 : i32, 0 : i32], level = 2 : i32} : (memref<64x56x56xi8, #hls.mem<dram>>, memref<64x64xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>) -> (memref<64x28x28xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>) {
      ^bb0(%arg12: memref<64x56x56xi8, #hls.mem<dram>>, %arg13: memref<64x64xi8, #hls.mem<dram>>, %arg14: memref<64x28x28xi8, #hls.mem<dram>>, %arg15: memref<64x28x28xi8, #hls.mem<dram>>, %arg16: memref<64x28x28xi8, #hls.mem<dram>>):
        affine.for %arg17 = 0 to 4 {
          affine.for %arg18 = 0 to 4 {
            affine.for %arg19 = 0 to 2 {
              affine.for %arg20 = 0 to 2 {
                hls.dataflow.schedule legal(%arg19, %arg20, %arg13, %arg14, %arg12, %arg17, %arg15, %arg16, %arg18) : index, index, memref<64x64xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>, memref<64x56x56xi8, #hls.mem<dram>>, index, memref<64x28x28xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>, index {
                ^bb0(%arg21: index, %arg22: index, %arg23: memref<64x64xi8, #hls.mem<dram>>, %arg24: memref<64x28x28xi8, #hls.mem<dram>>, %arg25: memref<64x56x56xi8, #hls.mem<dram>>, %arg26: index, %arg27: memref<64x28x28xi8, #hls.mem<dram>>, %arg28: memref<64x28x28xi8, #hls.mem<dram>>, %arg29: index):
                  %7 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                  %8 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                  %9 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                  %10 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, #hls.mem<bram_t2p>>
                  %11 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                  hls.dataflow.node(%arg25) -> (%11) [%arg26, %arg21, %arg22] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x56x56xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
                  ^bb0(%arg30: memref<64x56x56xi8, #hls.mem<dram>>, %arg31: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg32: index, %arg33: index, %arg34: index):
                    affine.for %arg35 = 0 to 16 {
                      affine.for %arg36 = 0 to 14 {
                        affine.for %arg37 = 0 to 14 {
                          %13 = affine.load %arg30[%arg35 + symbol(%arg32) * 16, %arg36 * 2 + symbol(%arg33) * 28, %arg37 * 2 + symbol(%arg34) * 28] : memref<64x56x56xi8, #hls.mem<dram>>
                          affine.store %13, %arg31[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                        } {parallel}
                      } {parallel}
                    } {parallel}
                  }
                  hls.dataflow.node(%arg23) -> (%10) [%arg29, %arg26] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x64xi8, #hls.mem<dram>>) -> memref<16x16xi8, #hls.mem<bram_t2p>>[index, index] {
                  ^bb0(%arg30: memref<64x64xi8, #hls.mem<dram>>, %arg31: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg32: index, %arg33: index):
                    affine.for %arg34 = 0 to 16 {
                      affine.for %arg35 = 0 to 16 {
                        %13 = affine.load %arg30[%arg34 + symbol(%arg32) * 16, %arg35 + symbol(%arg33) * 16] : memref<64x64xi8, #hls.mem<dram>>
                        affine.store %13, %arg31[%arg34, %arg35] : memref<16x16xi8, #hls.mem<bram_t2p>>
                      } {parallel}
                    } {parallel}
                  }
                  hls.dataflow.node(%arg28) -> (%9) [%arg29, %arg21, %arg22] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
                  ^bb0(%arg30: memref<64x28x28xi8, #hls.mem<dram>>, %arg31: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg32: index, %arg33: index, %arg34: index):
                    affine.for %arg35 = 0 to 16 {
                      affine.for %arg36 = 0 to 14 {
                        affine.for %arg37 = 0 to 14 {
                          %13 = affine.load %arg30[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14, %arg37 + symbol(%arg34) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                          affine.store %13, %arg31[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                        } {parallel}
                      } {parallel}
                    } {parallel}
                  }
                  hls.dataflow.node(%arg24) -> (%8) [%arg29, %arg21, %arg22] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
                  ^bb0(%arg30: memref<64x28x28xi8, #hls.mem<dram>>, %arg31: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg32: index, %arg33: index, %arg34: index):
                    affine.for %arg35 = 0 to 16 {
                      affine.for %arg36 = 0 to 14 {
                        affine.for %arg37 = 0 to 14 {
                          %13 = affine.load %arg30[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14, %arg37 + symbol(%arg34) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                          affine.store %13, %arg31[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                        } {parallel}
                      } {parallel}
                    } {parallel}
                  }
                  %12 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                  hls.dataflow.node(%8, %11, %10, %9) -> (%7, %12) [%arg26] {inputTaps = [0 : i32, 0 : i32, 0 : i32, 0 : i32], level = 1 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x16xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> (memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>)[index] {
                  ^bb0(%arg30: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg31: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg32: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg33: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg34: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg35: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg36: index):
                    %c-24_i8 = arith.constant -24 : i8
                    affine.for %arg37 = 0 to 16 {
                      affine.for %arg38 = 0 to 16 {
                        affine.for %arg39 = 0 to 14 {
                          affine.for %arg40 = 0 to 14 {
                            %13 = affine.load %arg31[%arg37, %arg39, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                            %14 = affine.load %arg32[%arg38, %arg37] : memref<16x16xi8, #hls.mem<bram_t2p>>
                            %15 = affine.load %arg33[%arg38, %arg39, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                            %16 = affine.load %arg35[%arg38, %arg39, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                            %17 = hls.affine.select #set(%arg37) %15, %16 : i8
                            %18 = arith.muli %13, %14 : i8
                            %19 = arith.addi %17, %18 : i8
                            affine.store %19, %arg35[%arg38, %arg39, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                            %20 = affine.load %arg30[%arg38, %arg39, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                            %21 = arith.addi %20, %19 : i8
                            %22 = arith.cmpi ugt, %21, %c-24_i8 : i8
                            %23 = arith.select %22, %21, %c-24_i8 : i8
                            affine.if #set2(%arg37)[%arg36] {
                              affine.store %23, %arg34[%arg38, %arg39, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                            }
                          } {parallel, point}
                        } {parallel, point}
                      } {parallel, point}
                    } {point}
                  }
                  hls.dataflow.node(%12) -> (%arg28) [%arg29, %arg21, %arg22] {inputTaps = [0 : i32], level = 0 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<64x28x28xi8, #hls.mem<dram>>[index, index, index] {
                  ^bb0(%arg30: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg31: memref<64x28x28xi8, #hls.mem<dram>>, %arg32: index, %arg33: index, %arg34: index):
                    affine.for %arg35 = 0 to 16 {
                      affine.for %arg36 = 0 to 14 {
                        affine.for %arg37 = 0 to 14 {
                          %13 = affine.load %arg30[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                          affine.store %13, %arg31[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14, %arg37 + symbol(%arg34) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                        } {parallel}
                      } {parallel}
                    } {parallel}
                  }
                  hls.dataflow.node(%7) -> (%arg27) [%arg29, %arg21, %arg22] {inputTaps = [0 : i32], level = 0 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<64x28x28xi8, #hls.mem<dram>>[index, index, index] {
                  ^bb0(%arg30: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg31: memref<64x28x28xi8, #hls.mem<dram>>, %arg32: index, %arg33: index, %arg34: index):
                    affine.for %arg35 = 0 to 16 {
                      affine.for %arg36 = 0 to 14 {
                        affine.for %arg37 = 0 to 14 {
                          %13 = affine.load %arg30[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                          affine.store %13, %arg31[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14, %arg37 + symbol(%arg34) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
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
      %6 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64xi8, #hls.mem<bram_t2p>>
      hls.dataflow.node(%4) -> (%6) {inputTaps = [0 : i32], level = 1 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<64xi8, #hls.mem<bram_t2p>> {
      ^bb0(%arg12: memref<64x28x28xi8, #hls.mem<dram>>, %arg13: memref<64xi8, #hls.mem<bram_t2p>>):
        affine.for %arg14 = 0 to 2 {
          affine.for %arg15 = 0 to 2 {
            affine.for %arg16 = 0 to 4 {
              hls.dataflow.schedule legal(%arg12, %arg14, %arg13, %arg15, %arg16) : memref<64x28x28xi8, #hls.mem<dram>>, index, memref<64xi8, #hls.mem<bram_t2p>>, index, index {
              ^bb0(%arg17: memref<64x28x28xi8, #hls.mem<dram>>, %arg18: index, %arg19: memref<64xi8, #hls.mem<bram_t2p>>, %arg20: index, %arg21: index):
                %7 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                hls.dataflow.node(%arg17) -> (%7) [%arg21, %arg18, %arg20] {inputTaps = [0 : i32], level = 1 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
                ^bb0(%arg22: memref<64x28x28xi8, #hls.mem<dram>>, %arg23: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg24: index, %arg25: index, %arg26: index):
                  affine.for %arg27 = 0 to 16 {
                    affine.for %arg28 = 0 to 14 {
                      affine.for %arg29 = 0 to 14 {
                        %8 = affine.load %arg22[%arg27 + symbol(%arg24) * 16, %arg28 + symbol(%arg25) * 14, %arg29 + symbol(%arg26) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                        affine.store %8, %arg23[%arg27, %arg28, %arg29] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                      } {parallel}
                    } {parallel}
                  } {parallel}
                }
                hls.dataflow.node(%7) -> (%arg19) [%arg21, %arg18, %arg20] {inputTaps = [0 : i32], level = 0 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<64xi8, #hls.mem<bram_t2p>>[index, index, index] {
                ^bb0(%arg22: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg23: memref<64xi8, #hls.mem<bram_t2p>>, %arg24: index, %arg25: index, %arg26: index):
                  %c-24_i8 = arith.constant -24 : i8
                  affine.for %arg27 = 0 to 14 {
                    affine.for %arg28 = 0 to 14 {
                      affine.for %arg29 = 0 to 16 {
                        %8 = affine.load %arg22[%arg29, %arg27, %arg28] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                        %9 = affine.load %arg23[%arg29 + symbol(%arg24) * 16] : memref<64xi8, #hls.mem<bram_t2p>>
                        %10 = arith.addi %9, %8 : i8
                        %11 = arith.divui %10, %c-24_i8 : i8
                        %12 = hls.affine.select #set3(%arg27, %arg28, %arg25, %arg26) %11, %10 : i8
                        affine.store %12, %arg23[%arg29 + symbol(%arg24) * 16] : memref<64xi8, #hls.mem<bram_t2p>>
                      } {parallel, point}
                    } {point}
                  } {point}
                }
              }
            } {parallel}
          }
        }
      }
      hls.dataflow.node(%6, %arg9) -> (%arg7) {inputTaps = [0 : i32, 0 : i32], level = 0 : i32} : (memref<64xi8, #hls.mem<bram_t2p>>, memref<1000x64xi8, #hls.mem<dram>>) -> memref<1000xi8, #hls.mem<dram>> {
      ^bb0(%arg12: memref<64xi8, #hls.mem<bram_t2p>>, %arg13: memref<1000x64xi8, #hls.mem<dram>>, %arg14: memref<1000xi8, #hls.mem<dram>>):
        affine.for %arg15 = 0 to 4 {
          affine.for %arg16 = 0 to 100 {
            hls.dataflow.schedule legal(%arg15, %arg16, %arg12, %arg13, %arg14) : index, index, memref<64xi8, #hls.mem<bram_t2p>>, memref<1000x64xi8, #hls.mem<dram>>, memref<1000xi8, #hls.mem<dram>> {
            ^bb0(%arg17: index, %arg18: index, %arg19: memref<64xi8, #hls.mem<bram_t2p>>, %arg20: memref<1000x64xi8, #hls.mem<dram>>, %arg21: memref<1000xi8, #hls.mem<dram>>):
              %7 = hls.dataflow.buffer {depth = 1 : i32} : memref<10x16xi8, #hls.mem<bram_t2p>>
              %8 = hls.dataflow.buffer {depth = 1 : i32} : memref<10xi8, #hls.mem<bram_t2p>>
              hls.dataflow.node(%arg21) -> (%8) [%arg18] {inputTaps = [0 : i32], level = 2 : i32} : (memref<1000xi8, #hls.mem<dram>>) -> memref<10xi8, #hls.mem<bram_t2p>>[index] {
              ^bb0(%arg22: memref<1000xi8, #hls.mem<dram>>, %arg23: memref<10xi8, #hls.mem<bram_t2p>>, %arg24: index):
                affine.for %arg25 = 0 to 10 {
                  %10 = affine.load %arg22[%arg25 + symbol(%arg24) * 10] : memref<1000xi8, #hls.mem<dram>>
                  affine.store %10, %arg23[%arg25] : memref<10xi8, #hls.mem<bram_t2p>>
                } {parallel}
              }
              hls.dataflow.node(%arg20) -> (%7) [%arg18, %arg17] {inputTaps = [0 : i32], level = 2 : i32} : (memref<1000x64xi8, #hls.mem<dram>>) -> memref<10x16xi8, #hls.mem<bram_t2p>>[index, index] {
              ^bb0(%arg22: memref<1000x64xi8, #hls.mem<dram>>, %arg23: memref<10x16xi8, #hls.mem<bram_t2p>>, %arg24: index, %arg25: index):
                affine.for %arg26 = 0 to 10 {
                  affine.for %arg27 = 0 to 16 {
                    %10 = affine.load %arg22[%arg26 + symbol(%arg24) * 10, %arg27 + symbol(%arg25) * 16] : memref<1000x64xi8, #hls.mem<dram>>
                    affine.store %10, %arg23[%arg26, %arg27] : memref<10x16xi8, #hls.mem<bram_t2p>>
                  } {parallel}
                } {parallel}
              }
              %9 = hls.dataflow.buffer {depth = 1 : i32} : memref<10xi8, #hls.mem<bram_t2p>>
              hls.dataflow.node(%arg19, %7, %8) -> (%9) [%arg17] {inputTaps = [0 : i32, 0 : i32, 0 : i32], level = 1 : i32} : (memref<64xi8, #hls.mem<bram_t2p>>, memref<10x16xi8, #hls.mem<bram_t2p>>, memref<10xi8, #hls.mem<bram_t2p>>) -> memref<10xi8, #hls.mem<bram_t2p>>[index] {
              ^bb0(%arg22: memref<64xi8, #hls.mem<bram_t2p>>, %arg23: memref<10x16xi8, #hls.mem<bram_t2p>>, %arg24: memref<10xi8, #hls.mem<bram_t2p>>, %arg25: memref<10xi8, #hls.mem<bram_t2p>>, %arg26: index):
                %c-24_i8 = arith.constant -24 : i8
                affine.for %arg27 = 0 to 16 {
                  affine.for %arg28 = 0 to 10 {
                    %10 = affine.load %arg24[%arg28] : memref<10xi8, #hls.mem<bram_t2p>>
                    %11 = affine.load %arg25[%arg28] : memref<10xi8, #hls.mem<bram_t2p>>
                    %12 = hls.affine.select #set(%arg27) %10, %11 : i8
                    %13 = hls.affine.select #set4(%arg27, %arg26) %c-24_i8, %12 : i8
                    %14 = affine.load %arg22[%arg27 + symbol(%arg26) * 16] : memref<64xi8, #hls.mem<bram_t2p>>
                    %15 = affine.load %arg23[%arg28, %arg27] : memref<10x16xi8, #hls.mem<bram_t2p>>
                    %16 = arith.muli %14, %15 : i8
                    %17 = arith.addi %13, %16 : i8
                    affine.store %17, %arg25[%arg28] : memref<10xi8, #hls.mem<bram_t2p>>
                  } {parallel, point}
                } {point}
              }
              hls.dataflow.node(%9) -> (%arg21) [%arg18] {inputTaps = [0 : i32], level = 0 : i32} : (memref<10xi8, #hls.mem<bram_t2p>>) -> memref<1000xi8, #hls.mem<dram>>[index] {
              ^bb0(%arg22: memref<10xi8, #hls.mem<bram_t2p>>, %arg23: memref<1000xi8, #hls.mem<dram>>, %arg24: index):
                affine.for %arg25 = 0 to 10 {
                  %10 = affine.load %arg22[%arg25] : memref<10xi8, #hls.mem<bram_t2p>>
                  affine.store %10, %arg23[%arg25 + symbol(%arg24) * 10] : memref<1000xi8, #hls.mem<dram>>
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

