// RUN: scalehls-opt -scalehls-parallelize-dataflow-node="max-unroll-factor=4 point-loop-only=true" %s | FileCheck %s

// CHECK: #map = affine_map<(d0, d1) -> (d1 + d0)>
// CHECK: #map1 = affine_map<(d0) -> (d0 + 1)>
// CHECK: #set = affine_set<(d0) : (d0 == 0)>
// CHECK: #set1 = affine_set<(d0, d1, d2, d3) : (-d2 - d3 * 16 + 63 == 0, -d0 + 2 == 0, -d1 + 2 == 0)>
// CHECK: #set2 = affine_set<(d0)[s0] : (-d0 - s0 * 16 + 63 == 0)>
// CHECK: #set3 = affine_set<(d0, d1, d2, d3) : (-d0 - d2 * 14 + 27 == 0, -d1 - d3 * 14 + 27 == 0)>
// CHECK: #set4 = affine_set<(d0, d1) : (d0 + d1 * 16 == 0)>
// CHECK: module attributes {torch.debug_module_name = "ResNet"} {
// CHECK:   func.func @forward(%arg0: memref<64x56x56xi8, #hls.mem<dram>>, %arg1: memref<1000x64xi8, #hls.mem<dram>>, %arg2: memref<64x64xi8, #hls.mem<dram>>, %arg3: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg4: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg5: memref<1000xi8, #hls.mem<dram>>) attributes {top_func} {
// CHECK:     hls.dataflow.schedule(%arg2, %arg5, %arg3, %arg1, %arg0, %arg4) : memref<64x64xi8, #hls.mem<dram>>, memref<1000xi8, #hls.mem<dram>>, memref<64x64x3x3xi8, #hls.mem<dram>>, memref<1000x64xi8, #hls.mem<dram>>, memref<64x56x56xi8, #hls.mem<dram>>, memref<64x64x3x3xi8, #hls.mem<dram>> {
// CHECK:     ^bb0(%arg6: memref<64x64xi8, #hls.mem<dram>>, %arg7: memref<1000xi8, #hls.mem<dram>>, %arg8: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg9: memref<1000x64xi8, #hls.mem<dram>>, %arg10: memref<64x56x56xi8, #hls.mem<dram>>, %arg11: memref<64x64x3x3xi8, #hls.mem<dram>>):
// CHECK:       hls.dataflow.node() -> (%arg10) {inputTaps = [], level = 6 : i32} : () -> memref<64x56x56xi8, #hls.mem<dram>> {
// CHECK:       ^bb0(%arg12: memref<64x56x56xi8, #hls.mem<dram>>):
// CHECK:         affine.for %arg13 = 0 to 4 {
// CHECK:           affine.for %arg14 = 0 to 4 {
// CHECK:             affine.for %arg15 = 0 to 4 {
// CHECK:               hls.dataflow.schedule(%arg13, %arg15, %arg12, %arg14) : index, index, memref<64x56x56xi8, #hls.mem<dram>>, index {
// CHECK:               ^bb0(%arg16: index, %arg17: index, %arg18: memref<64x56x56xi8, #hls.mem<dram>>, %arg19: index):
// CHECK:                 %7 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                 hls.dataflow.node(%arg18) -> (%7) [%arg16, %arg19, %arg17] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x56x56xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
// CHECK:                 ^bb0(%arg20: memref<64x56x56xi8, #hls.mem<dram>>, %arg21: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg22: index, %arg23: index, %arg24: index):
// CHECK:                   affine.for %arg25 = 0 to 16 {
// CHECK:                     affine.for %arg26 = 0 to 14 {
// CHECK:                       affine.for %arg27 = 0 to 14 {
// CHECK:                         %9 = affine.load %arg20[%arg25 + symbol(%arg22) * 16, %arg26 + symbol(%arg23) * 14, %arg27 + symbol(%arg24) * 14] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:                         affine.store %9, %arg21[%arg25, %arg26, %arg27] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   } {parallel}
// CHECK:                 }
// CHECK:                 %8 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                 hls.dataflow.node(%7) -> (%8) {inputTaps = [0 : i32], level = 1 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>> {
// CHECK:                 ^bb0(%arg20: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg21: memref<16x14x14xi8, #hls.mem<bram_t2p>>):
// CHECK:                   %c-24_i8 = arith.constant -24 : i8
// CHECK:                   affine.for %arg22 = 0 to 16 {
// CHECK:                     affine.for %arg23 = 0 to 14 {
// CHECK:                       affine.for %arg24 = 0 to 14 {
// CHECK:                         %9 = affine.load %arg20[%arg22, %arg23, %arg24] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                         %10 = arith.cmpi ugt, %9, %c-24_i8 : i8
// CHECK:                         %11 = arith.select %10, %9, %c-24_i8 : i8
// CHECK:                         affine.store %11, %arg21[%arg22, %arg23, %arg24] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                       } {parallel, point}
// CHECK:                     } {parallel, point}
// CHECK:                   } {parallel, point}
// CHECK:                 }
// CHECK:                 hls.dataflow.node(%8) -> (%arg18) [%arg16, %arg19, %arg17] {inputTaps = [0 : i32], level = 0 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<64x56x56xi8, #hls.mem<dram>>[index, index, index] {
// CHECK:                 ^bb0(%arg20: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg21: memref<64x56x56xi8, #hls.mem<dram>>, %arg22: index, %arg23: index, %arg24: index):
// CHECK:                   affine.for %arg25 = 0 to 16 {
// CHECK:                     affine.for %arg26 = 0 to 14 {
// CHECK:                       affine.for %arg27 = 0 to 14 {
// CHECK:                         %9 = affine.load %arg20[%arg25, %arg26, %arg27] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                         affine.store %9, %arg21[%arg25 + symbol(%arg22) * 16, %arg26 + symbol(%arg23) * 14, %arg27 + symbol(%arg24) * 14] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   } {parallel}
// CHECK:                 }
// CHECK:               }
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:       }
// CHECK:       %0 = hls.dataflow.buffer {depth = 3 : i32} : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:       %1 = hls.dataflow.buffer {depth = 1 : i32} : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:       hls.dataflow.node(%arg10) -> (%0, %1) {inputTaps = [0 : i32], level = 5 : i32} : (memref<64x56x56xi8, #hls.mem<dram>>) -> (memref<64x56x56xi8, #hls.mem<dram>>, memref<64x56x56xi8, #hls.mem<dram>>) {
// CHECK:       ^bb0(%arg12: memref<64x56x56xi8, #hls.mem<dram>>, %arg13: memref<64x56x56xi8, #hls.mem<dram>>, %arg14: memref<64x56x56xi8, #hls.mem<dram>>):
// CHECK:         affine.for %arg15 = 0 to 64 {
// CHECK:           affine.for %arg16 = 0 to 56 {
// CHECK:             affine.for %arg17 = 0 to 56 {
// CHECK:               %7 = affine.load %arg12[%arg15, %arg16, %arg17] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:               affine.store %7, %arg13[%arg15, %arg16, %arg17] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:         affine.for %arg15 = 0 to 64 {
// CHECK:           affine.for %arg16 = 0 to 56 {
// CHECK:             affine.for %arg17 = 0 to 56 {
// CHECK:               %7 = affine.load %arg12[%arg15, %arg16, %arg17] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:               affine.store %7, %arg14[%arg15, %arg16, %arg17] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:       }
// CHECK:       %2 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:       hls.dataflow.node(%1, %arg11) -> (%2) {inputTaps = [0 : i32, 0 : i32], level = 4 : i32} : (memref<64x56x56xi8, #hls.mem<dram>>, memref<64x64x3x3xi8, #hls.mem<dram>>) -> memref<64x28x28xi8, #hls.mem<dram>> {
// CHECK:       ^bb0(%arg12: memref<64x56x56xi8, #hls.mem<dram>>, %arg13: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg14: memref<64x28x28xi8, #hls.mem<dram>>):
// CHECK:         affine.for %arg15 = 0 to 4 {
// CHECK:           affine.for %arg16 = 0 to 3 {
// CHECK:             affine.for %arg17 = 0 to 3 {
// CHECK:               affine.for %arg18 = 0 to 4 {
// CHECK:                 affine.for %arg19 = 0 to 2 {
// CHECK:                   affine.for %arg20 = 0 to 2 {
// CHECK:                     hls.dataflow.schedule(%arg17, %arg14, %arg20, %arg16, %arg19, %arg12, %arg15, %arg13, %arg18) : index, memref<64x28x28xi8, #hls.mem<dram>>, index, index, index, memref<64x56x56xi8, #hls.mem<dram>>, index, memref<64x64x3x3xi8, #hls.mem<dram>>, index {
// CHECK:                     ^bb0(%arg21: index, %arg22: memref<64x28x28xi8, #hls.mem<dram>>, %arg23: index, %arg24: index, %arg25: index, %arg26: memref<64x56x56xi8, #hls.mem<dram>>, %arg27: index, %arg28: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg29: index):
// CHECK:                       %7 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                       %8 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:                       %9 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                       hls.dataflow.node(%arg26) -> (%9) [%arg27, %arg24, %arg25, %arg21, %arg23] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x56x56xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index, index, index] {
// CHECK:                       ^bb0(%arg30: memref<64x56x56xi8, #hls.mem<dram>>, %arg31: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg32: index, %arg33: index, %arg34: index, %arg35: index, %arg36: index):
// CHECK:                         affine.for %arg37 = 0 to 16 {
// CHECK:                           affine.for %arg38 = 0 to 14 {
// CHECK:                             affine.for %arg39 = 0 to 14 {
// CHECK:                               %11 = affine.load %arg30[%arg37 + symbol(%arg32) * 16, %arg38 * 2 + symbol(%arg33) + symbol(%arg34) * 28 - 1, %arg39 * 2 + symbol(%arg35) + symbol(%arg36) * 28 - 1] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:                               affine.store %11, %arg31[%arg37, %arg38, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                             } {parallel}
// CHECK:                           } {parallel}
// CHECK:                         } {parallel}
// CHECK:                       }
// CHECK:                       hls.dataflow.node(%arg28) -> (%8) [%arg29, %arg27, %arg24, %arg21] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x64x3x3xi8, #hls.mem<dram>>) -> memref<16x16xi8, #hls.mem<bram_t2p>>[index, index, index, index] {
// CHECK:                       ^bb0(%arg30: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg31: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg32: index, %arg33: index, %arg34: index, %arg35: index):
// CHECK:                         affine.for %arg36 = 0 to 16 {
// CHECK:                           affine.for %arg37 = 0 to 16 {
// CHECK:                             %11 = affine.load %arg30[%arg36 + symbol(%arg32) * 16, %arg37 + symbol(%arg33) * 16, symbol(%arg34), symbol(%arg35)] : memref<64x64x3x3xi8, #hls.mem<dram>>
// CHECK:                             affine.store %11, %arg31[%arg36, %arg37] : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:                           } {parallel}
// CHECK:                         } {parallel}
// CHECK:                       }
// CHECK:                       hls.dataflow.node(%arg22) -> (%7) [%arg29, %arg25, %arg23] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
// CHECK:                       ^bb0(%arg30: memref<64x28x28xi8, #hls.mem<dram>>, %arg31: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg32: index, %arg33: index, %arg34: index):
// CHECK:                         affine.for %arg35 = 0 to 16 {
// CHECK:                           affine.for %arg36 = 0 to 14 {
// CHECK:                             affine.for %arg37 = 0 to 14 {
// CHECK:                               %11 = affine.load %arg30[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14, %arg37 + symbol(%arg34) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                               affine.store %11, %arg31[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                             } {parallel}
// CHECK:                           } {parallel}
// CHECK:                         } {parallel}
// CHECK:                       }
// CHECK:                       %10 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                       hls.dataflow.node(%9, %8, %7) -> (%10) [%arg21, %arg27, %arg24] {inputTaps = [0 : i32, 0 : i32, 0 : i32], level = 1 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x16xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
// CHECK:                       ^bb0(%arg30: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg31: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg32: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg33: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg34: index, %arg35: index, %arg36: index):
// CHECK:                         %c0 = arith.constant 0 : index
// CHECK:                         %c0_0 = arith.constant 0 : index
// CHECK:                         %c-24_i8 = arith.constant -24 : i8
// CHECK:                         affine.for %arg37 = 0 to 16 {
// CHECK:                           affine.for %arg38 = 0 to 16 {
// CHECK:                             affine.for %arg39 = 0 to 14 step 2 {
// CHECK:                               affine.for %arg40 = 0 to 14 step 2 {
// CHECK:                                 %11 = affine.apply #map(%arg39, %c0)
// CHECK:                                 %12 = affine.apply #map(%arg40, %c0_0)
// CHECK:                                 %13 = affine.load %arg30[%arg37, %11, %12] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %14 = affine.load %arg31[%arg38, %arg37] : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %15 = affine.load %arg32[%arg38, %11, %12] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %16 = affine.load %arg33[%arg38, %11, %12] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %17 = hls.affine.select #set(%arg37) %15, %16 : i8
// CHECK:                                 %18 = arith.muli %13, %14 : i8
// CHECK:                                 %19 = arith.addi %17, %18 : i8
// CHECK:                                 %20 = arith.cmpi ugt, %19, %c-24_i8 : i8
// CHECK:                                 %21 = arith.select %20, %19, %c-24_i8 : i8
// CHECK:                                 %22 = hls.affine.select #set1(%arg36, %arg34, %arg37, %arg35) %21, %19 : i8
// CHECK:                                 affine.store %22, %arg33[%arg38, %11, %12] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %23 = affine.apply #map1(%c0_0)
// CHECK:                                 %24 = affine.apply #map(%arg40, %23)
// CHECK:                                 %25 = affine.load %arg30[%arg37, %11, %24] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %26 = affine.load %arg31[%arg38, %arg37] : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %27 = affine.load %arg32[%arg38, %11, %24] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %28 = affine.load %arg33[%arg38, %11, %24] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %29 = hls.affine.select #set(%arg37) %27, %28 : i8
// CHECK:                                 %30 = arith.muli %25, %26 : i8
// CHECK:                                 %31 = arith.addi %29, %30 : i8
// CHECK:                                 %32 = arith.cmpi ugt, %31, %c-24_i8 : i8
// CHECK:                                 %33 = arith.select %32, %31, %c-24_i8 : i8
// CHECK:                                 %34 = hls.affine.select #set1(%arg36, %arg34, %arg37, %arg35) %33, %31 : i8
// CHECK:                                 affine.store %34, %arg33[%arg38, %11, %24] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %35 = affine.apply #map1(%c0)
// CHECK:                                 %36 = affine.apply #map(%arg39, %35)
// CHECK:                                 %37 = affine.apply #map(%arg40, %c0_0)
// CHECK:                                 %38 = affine.load %arg30[%arg37, %36, %37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %39 = affine.load %arg31[%arg38, %arg37] : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %40 = affine.load %arg32[%arg38, %36, %37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %41 = affine.load %arg33[%arg38, %36, %37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %42 = hls.affine.select #set(%arg37) %40, %41 : i8
// CHECK:                                 %43 = arith.muli %38, %39 : i8
// CHECK:                                 %44 = arith.addi %42, %43 : i8
// CHECK:                                 %45 = arith.cmpi ugt, %44, %c-24_i8 : i8
// CHECK:                                 %46 = arith.select %45, %44, %c-24_i8 : i8
// CHECK:                                 %47 = hls.affine.select #set1(%arg36, %arg34, %arg37, %arg35) %46, %44 : i8
// CHECK:                                 affine.store %47, %arg33[%arg38, %36, %37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %48 = affine.apply #map1(%c0_0)
// CHECK:                                 %49 = affine.apply #map(%arg40, %48)
// CHECK:                                 %50 = affine.load %arg30[%arg37, %36, %49] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %51 = affine.load %arg31[%arg38, %arg37] : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %52 = affine.load %arg32[%arg38, %36, %49] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %53 = affine.load %arg33[%arg38, %36, %49] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %54 = hls.affine.select #set(%arg37) %52, %53 : i8
// CHECK:                                 %55 = arith.muli %50, %51 : i8
// CHECK:                                 %56 = arith.addi %54, %55 : i8
// CHECK:                                 %57 = arith.cmpi ugt, %56, %c-24_i8 : i8
// CHECK:                                 %58 = arith.select %57, %56, %c-24_i8 : i8
// CHECK:                                 %59 = hls.affine.select #set1(%arg36, %arg34, %arg37, %arg35) %58, %56 : i8
// CHECK:                                 affine.store %59, %arg33[%arg38, %36, %49] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                               } {parallel, point}
// CHECK:                             } {parallel, point}
// CHECK:                           } {parallel, point}
// CHECK:                         } {point}
// CHECK:                       }
// CHECK:                       hls.dataflow.node(%10) -> (%arg22) [%arg29, %arg25, %arg23] {inputTaps = [0 : i32], level = 0 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<64x28x28xi8, #hls.mem<dram>>[index, index, index] {
// CHECK:                       ^bb0(%arg30: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg31: memref<64x28x28xi8, #hls.mem<dram>>, %arg32: index, %arg33: index, %arg34: index):
// CHECK:                         affine.for %arg35 = 0 to 16 {
// CHECK:                           affine.for %arg36 = 0 to 14 {
// CHECK:                             affine.for %arg37 = 0 to 14 {
// CHECK:                               %11 = affine.load %arg30[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                               affine.store %11, %arg31[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14, %arg37 + symbol(%arg34) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
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
// CHECK:       %3 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:       hls.dataflow.node(%arg8, %2) -> (%3) {inputTaps = [0 : i32, 0 : i32], level = 3 : i32} : (memref<64x64x3x3xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>) -> memref<64x28x28xi8, #hls.mem<dram>> {
// CHECK:       ^bb0(%arg12: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg13: memref<64x28x28xi8, #hls.mem<dram>>, %arg14: memref<64x28x28xi8, #hls.mem<dram>>):
// CHECK:         affine.for %arg15 = 0 to 4 {
// CHECK:           affine.for %arg16 = 0 to 3 {
// CHECK:             affine.for %arg17 = 0 to 3 {
// CHECK:               affine.for %arg18 = 0 to 4 {
// CHECK:                 affine.for %arg19 = 0 to 2 {
// CHECK:                   affine.for %arg20 = 0 to 2 {
// CHECK:                     hls.dataflow.schedule(%arg20, %arg16, %arg15, %arg17, %arg19, %arg14, %arg12, %arg13, %arg18) : index, index, index, index, index, memref<64x28x28xi8, #hls.mem<dram>>, memref<64x64x3x3xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>, index {
// CHECK:                     ^bb0(%arg21: index, %arg22: index, %arg23: index, %arg24: index, %arg25: index, %arg26: memref<64x28x28xi8, #hls.mem<dram>>, %arg27: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg28: memref<64x28x28xi8, #hls.mem<dram>>, %arg29: index):
// CHECK:                       %7 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                       %8 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:                       %9 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                       hls.dataflow.node(%arg28) -> (%9) [%arg23, %arg22, %arg25, %arg24, %arg21] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index, index, index] {
// CHECK:                       ^bb0(%arg30: memref<64x28x28xi8, #hls.mem<dram>>, %arg31: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg32: index, %arg33: index, %arg34: index, %arg35: index, %arg36: index):
// CHECK:                         affine.for %arg37 = 0 to 16 {
// CHECK:                           affine.for %arg38 = 0 to 14 {
// CHECK:                             affine.for %arg39 = 0 to 14 {
// CHECK:                               %11 = affine.load %arg30[%arg37 + symbol(%arg32) * 16, %arg38 + symbol(%arg33) + symbol(%arg34) * 14 - 1, %arg39 + symbol(%arg35) + symbol(%arg36) * 14 - 1] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                               affine.store %11, %arg31[%arg37, %arg38, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                             } {parallel}
// CHECK:                           } {parallel}
// CHECK:                         } {parallel}
// CHECK:                       }
// CHECK:                       hls.dataflow.node(%arg27) -> (%8) [%arg29, %arg23, %arg22, %arg24] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x64x3x3xi8, #hls.mem<dram>>) -> memref<16x16xi8, #hls.mem<bram_t2p>>[index, index, index, index] {
// CHECK:                       ^bb0(%arg30: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg31: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg32: index, %arg33: index, %arg34: index, %arg35: index):
// CHECK:                         affine.for %arg36 = 0 to 16 {
// CHECK:                           affine.for %arg37 = 0 to 16 {
// CHECK:                             %11 = affine.load %arg30[%arg36 + symbol(%arg32) * 16, %arg37 + symbol(%arg33) * 16, symbol(%arg34), symbol(%arg35)] : memref<64x64x3x3xi8, #hls.mem<dram>>
// CHECK:                             affine.store %11, %arg31[%arg36, %arg37] : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:                           } {parallel}
// CHECK:                         } {parallel}
// CHECK:                       }
// CHECK:                       hls.dataflow.node(%arg26) -> (%7) [%arg29, %arg25, %arg21] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
// CHECK:                       ^bb0(%arg30: memref<64x28x28xi8, #hls.mem<dram>>, %arg31: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg32: index, %arg33: index, %arg34: index):
// CHECK:                         affine.for %arg35 = 0 to 16 {
// CHECK:                           affine.for %arg36 = 0 to 14 {
// CHECK:                             affine.for %arg37 = 0 to 14 {
// CHECK:                               %11 = affine.load %arg30[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14, %arg37 + symbol(%arg34) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                               affine.store %11, %arg31[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                             } {parallel}
// CHECK:                           } {parallel}
// CHECK:                         } {parallel}
// CHECK:                       }
// CHECK:                       %10 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                       hls.dataflow.node(%9, %8, %7) -> (%10) {inputTaps = [0 : i32, 0 : i32, 0 : i32], level = 1 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x16xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>> {
// CHECK:                       ^bb0(%arg30: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg31: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg32: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg33: memref<16x14x14xi8, #hls.mem<bram_t2p>>):
// CHECK:                         %c0 = arith.constant 0 : index
// CHECK:                         %c0_0 = arith.constant 0 : index
// CHECK:                         affine.for %arg34 = 0 to 16 {
// CHECK:                           affine.for %arg35 = 0 to 16 {
// CHECK:                             affine.for %arg36 = 0 to 14 step 2 {
// CHECK:                               affine.for %arg37 = 0 to 14 step 2 {
// CHECK:                                 %11 = affine.apply #map(%arg36, %c0)
// CHECK:                                 %12 = affine.apply #map(%arg37, %c0_0)
// CHECK:                                 %13 = affine.load %arg30[%arg34, %11, %12] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %14 = affine.load %arg31[%arg35, %arg34] : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %15 = affine.load %arg32[%arg35, %11, %12] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %16 = affine.load %arg33[%arg35, %11, %12] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %17 = hls.affine.select #set(%arg34) %15, %16 : i8
// CHECK:                                 %18 = arith.muli %13, %14 : i8
// CHECK:                                 %19 = arith.addi %17, %18 : i8
// CHECK:                                 affine.store %19, %arg33[%arg35, %11, %12] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %20 = affine.apply #map1(%c0_0)
// CHECK:                                 %21 = affine.apply #map(%arg37, %20)
// CHECK:                                 %22 = affine.load %arg30[%arg34, %11, %21] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %23 = affine.load %arg31[%arg35, %arg34] : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %24 = affine.load %arg32[%arg35, %11, %21] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %25 = affine.load %arg33[%arg35, %11, %21] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %26 = hls.affine.select #set(%arg34) %24, %25 : i8
// CHECK:                                 %27 = arith.muli %22, %23 : i8
// CHECK:                                 %28 = arith.addi %26, %27 : i8
// CHECK:                                 affine.store %28, %arg33[%arg35, %11, %21] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %29 = affine.apply #map1(%c0)
// CHECK:                                 %30 = affine.apply #map(%arg36, %29)
// CHECK:                                 %31 = affine.apply #map(%arg37, %c0_0)
// CHECK:                                 %32 = affine.load %arg30[%arg34, %30, %31] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %33 = affine.load %arg31[%arg35, %arg34] : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %34 = affine.load %arg32[%arg35, %30, %31] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %35 = affine.load %arg33[%arg35, %30, %31] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %36 = hls.affine.select #set(%arg34) %34, %35 : i8
// CHECK:                                 %37 = arith.muli %32, %33 : i8
// CHECK:                                 %38 = arith.addi %36, %37 : i8
// CHECK:                                 affine.store %38, %arg33[%arg35, %30, %31] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %39 = affine.apply #map1(%c0_0)
// CHECK:                                 %40 = affine.apply #map(%arg37, %39)
// CHECK:                                 %41 = affine.load %arg30[%arg34, %30, %40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %42 = affine.load %arg31[%arg35, %arg34] : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %43 = affine.load %arg32[%arg35, %30, %40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %44 = affine.load %arg33[%arg35, %30, %40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                                 %45 = hls.affine.select #set(%arg34) %43, %44 : i8
// CHECK:                                 %46 = arith.muli %41, %42 : i8
// CHECK:                                 %47 = arith.addi %45, %46 : i8
// CHECK:                                 affine.store %47, %arg33[%arg35, %30, %40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                               } {parallel, point}
// CHECK:                             } {parallel, point}
// CHECK:                           } {parallel, point}
// CHECK:                         } {point}
// CHECK:                       }
// CHECK:                       hls.dataflow.node(%10) -> (%arg26) [%arg29, %arg25, %arg21] {inputTaps = [0 : i32], level = 0 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<64x28x28xi8, #hls.mem<dram>>[index, index, index] {
// CHECK:                       ^bb0(%arg30: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg31: memref<64x28x28xi8, #hls.mem<dram>>, %arg32: index, %arg33: index, %arg34: index):
// CHECK:                         affine.for %arg35 = 0 to 16 {
// CHECK:                           affine.for %arg36 = 0 to 14 {
// CHECK:                             affine.for %arg37 = 0 to 14 {
// CHECK:                               %11 = affine.load %arg30[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                               affine.store %11, %arg31[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14, %arg37 + symbol(%arg34) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
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
// CHECK:       %4 = hls.dataflow.buffer {depth = 1 : i32} : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:       %5 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:       hls.dataflow.node(%0, %arg6, %3) -> (%4, %5) {inputTaps = [2 : i32, 0 : i32, 0 : i32], level = 2 : i32} : (memref<64x56x56xi8, #hls.mem<dram>>, memref<64x64xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>) -> (memref<64x28x28xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>) {
// CHECK:       ^bb0(%arg12: memref<64x56x56xi8, #hls.mem<dram>>, %arg13: memref<64x64xi8, #hls.mem<dram>>, %arg14: memref<64x28x28xi8, #hls.mem<dram>>, %arg15: memref<64x28x28xi8, #hls.mem<dram>>, %arg16: memref<64x28x28xi8, #hls.mem<dram>>):
// CHECK:         affine.for %arg17 = 0 to 4 {
// CHECK:           affine.for %arg18 = 0 to 4 {
// CHECK:             affine.for %arg19 = 0 to 2 {
// CHECK:               affine.for %arg20 = 0 to 2 {
// CHECK:                 hls.dataflow.schedule(%arg19, %arg20, %arg13, %arg14, %arg12, %arg17, %arg15, %arg16, %arg18) : index, index, memref<64x64xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>, memref<64x56x56xi8, #hls.mem<dram>>, index, memref<64x28x28xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>, index {
// CHECK:                 ^bb0(%arg21: index, %arg22: index, %arg23: memref<64x64xi8, #hls.mem<dram>>, %arg24: memref<64x28x28xi8, #hls.mem<dram>>, %arg25: memref<64x56x56xi8, #hls.mem<dram>>, %arg26: index, %arg27: memref<64x28x28xi8, #hls.mem<dram>>, %arg28: memref<64x28x28xi8, #hls.mem<dram>>, %arg29: index):
// CHECK:                   %7 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                   %8 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                   %9 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                   %10 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:                   %11 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                   hls.dataflow.node(%arg25) -> (%11) [%arg26, %arg21, %arg22] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x56x56xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
// CHECK:                   ^bb0(%arg30: memref<64x56x56xi8, #hls.mem<dram>>, %arg31: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg32: index, %arg33: index, %arg34: index):
// CHECK:                     affine.for %arg35 = 0 to 16 {
// CHECK:                       affine.for %arg36 = 0 to 14 {
// CHECK:                         affine.for %arg37 = 0 to 14 {
// CHECK:                           %13 = affine.load %arg30[%arg35 + symbol(%arg32) * 16, %arg36 * 2 + symbol(%arg33) * 28, %arg37 * 2 + symbol(%arg34) * 28] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:                           affine.store %13, %arg31[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                         } {parallel}
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   }
// CHECK:                   hls.dataflow.node(%arg23) -> (%10) [%arg29, %arg26] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x64xi8, #hls.mem<dram>>) -> memref<16x16xi8, #hls.mem<bram_t2p>>[index, index] {
// CHECK:                   ^bb0(%arg30: memref<64x64xi8, #hls.mem<dram>>, %arg31: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg32: index, %arg33: index):
// CHECK:                     affine.for %arg34 = 0 to 16 {
// CHECK:                       affine.for %arg35 = 0 to 16 {
// CHECK:                         %13 = affine.load %arg30[%arg34 + symbol(%arg32) * 16, %arg35 + symbol(%arg33) * 16] : memref<64x64xi8, #hls.mem<dram>>
// CHECK:                         affine.store %13, %arg31[%arg34, %arg35] : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   }
// CHECK:                   hls.dataflow.node(%arg28) -> (%9) [%arg29, %arg21, %arg22] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
// CHECK:                   ^bb0(%arg30: memref<64x28x28xi8, #hls.mem<dram>>, %arg31: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg32: index, %arg33: index, %arg34: index):
// CHECK:                     affine.for %arg35 = 0 to 16 {
// CHECK:                       affine.for %arg36 = 0 to 14 {
// CHECK:                         affine.for %arg37 = 0 to 14 {
// CHECK:                           %13 = affine.load %arg30[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14, %arg37 + symbol(%arg34) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                           affine.store %13, %arg31[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                         } {parallel}
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   }
// CHECK:                   hls.dataflow.node(%arg24) -> (%8) [%arg29, %arg21, %arg22] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
// CHECK:                   ^bb0(%arg30: memref<64x28x28xi8, #hls.mem<dram>>, %arg31: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg32: index, %arg33: index, %arg34: index):
// CHECK:                     affine.for %arg35 = 0 to 16 {
// CHECK:                       affine.for %arg36 = 0 to 14 {
// CHECK:                         affine.for %arg37 = 0 to 14 {
// CHECK:                           %13 = affine.load %arg30[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14, %arg37 + symbol(%arg34) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                           affine.store %13, %arg31[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                         } {parallel}
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   }
// CHECK:                   %12 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                   hls.dataflow.node(%8, %11, %10, %9) -> (%7, %12) [%arg26] {inputTaps = [0 : i32, 0 : i32, 0 : i32, 0 : i32], level = 1 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x16xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> (memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>)[index] {
// CHECK:                   ^bb0(%arg30: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg31: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg32: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg33: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg34: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg35: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg36: index):
// CHECK:                     %c-24_i8 = arith.constant -24 : i8
// CHECK:                     affine.for %arg37 = 0 to 16 {
// CHECK:                       affine.for %arg38 = 0 to 16 {
// CHECK:                         affine.for %arg39 = 0 to 14 {
// CHECK:                           affine.for %arg40 = 0 to 14 {
// CHECK:                             %13 = affine.load %arg31[%arg37, %arg39, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                             %14 = affine.load %arg32[%arg38, %arg37] : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:                             %15 = affine.load %arg33[%arg38, %arg39, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                             %16 = affine.load %arg35[%arg38, %arg39, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                             %17 = hls.affine.select #set(%arg37) %15, %16 : i8
// CHECK:                             %18 = arith.muli %13, %14 : i8
// CHECK:                             %19 = arith.addi %17, %18 : i8
// CHECK:                             affine.store %19, %arg35[%arg38, %arg39, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                             %20 = affine.load %arg30[%arg38, %arg39, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                             %21 = arith.addi %20, %19 : i8
// CHECK:                             %22 = arith.cmpi ugt, %21, %c-24_i8 : i8
// CHECK:                             %23 = arith.select %22, %21, %c-24_i8 : i8
// CHECK:                             affine.if #set2(%arg37)[%arg36] {
// CHECK:                               affine.store %23, %arg34[%arg38, %arg39, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                             }
// CHECK:                           } {parallel, point}
// CHECK:                         } {parallel, point}
// CHECK:                       } {parallel, point}
// CHECK:                     } {point}
// CHECK:                   }
// CHECK:                   hls.dataflow.node(%12) -> (%arg28) [%arg29, %arg21, %arg22] {inputTaps = [0 : i32], level = 0 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<64x28x28xi8, #hls.mem<dram>>[index, index, index] {
// CHECK:                   ^bb0(%arg30: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg31: memref<64x28x28xi8, #hls.mem<dram>>, %arg32: index, %arg33: index, %arg34: index):
// CHECK:                     affine.for %arg35 = 0 to 16 {
// CHECK:                       affine.for %arg36 = 0 to 14 {
// CHECK:                         affine.for %arg37 = 0 to 14 {
// CHECK:                           %13 = affine.load %arg30[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                           affine.store %13, %arg31[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14, %arg37 + symbol(%arg34) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                         } {parallel}
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   }
// CHECK:                   hls.dataflow.node(%7) -> (%arg27) [%arg29, %arg21, %arg22] {inputTaps = [0 : i32], level = 0 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<64x28x28xi8, #hls.mem<dram>>[index, index, index] {
// CHECK:                   ^bb0(%arg30: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg31: memref<64x28x28xi8, #hls.mem<dram>>, %arg32: index, %arg33: index, %arg34: index):
// CHECK:                     affine.for %arg35 = 0 to 16 {
// CHECK:                       affine.for %arg36 = 0 to 14 {
// CHECK:                         affine.for %arg37 = 0 to 14 {
// CHECK:                           %13 = affine.load %arg30[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                           affine.store %13, %arg31[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14, %arg37 + symbol(%arg34) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
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
// CHECK:       %6 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64xi8, #hls.mem<bram_t2p>>
// CHECK:       hls.dataflow.node(%4) -> (%6) {inputTaps = [0 : i32], level = 1 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<64xi8, #hls.mem<bram_t2p>> {
// CHECK:       ^bb0(%arg12: memref<64x28x28xi8, #hls.mem<dram>>, %arg13: memref<64xi8, #hls.mem<bram_t2p>>):
// CHECK:         affine.for %arg14 = 0 to 2 {
// CHECK:           affine.for %arg15 = 0 to 2 {
// CHECK:             affine.for %arg16 = 0 to 4 {
// CHECK:               hls.dataflow.schedule(%arg12, %arg14, %arg13, %arg15, %arg16) : memref<64x28x28xi8, #hls.mem<dram>>, index, memref<64xi8, #hls.mem<bram_t2p>>, index, index {
// CHECK:               ^bb0(%arg17: memref<64x28x28xi8, #hls.mem<dram>>, %arg18: index, %arg19: memref<64xi8, #hls.mem<bram_t2p>>, %arg20: index, %arg21: index):
// CHECK:                 %7 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                 hls.dataflow.node(%arg17) -> (%7) [%arg21, %arg18, %arg20] {inputTaps = [0 : i32], level = 1 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
// CHECK:                 ^bb0(%arg22: memref<64x28x28xi8, #hls.mem<dram>>, %arg23: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg24: index, %arg25: index, %arg26: index):
// CHECK:                   affine.for %arg27 = 0 to 16 {
// CHECK:                     affine.for %arg28 = 0 to 14 {
// CHECK:                       affine.for %arg29 = 0 to 14 {
// CHECK:                         %8 = affine.load %arg22[%arg27 + symbol(%arg24) * 16, %arg28 + symbol(%arg25) * 14, %arg29 + symbol(%arg26) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:                         affine.store %8, %arg23[%arg27, %arg28, %arg29] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                       } {parallel}
// CHECK:                     } {parallel}
// CHECK:                   } {parallel}
// CHECK:                 }
// CHECK:                 hls.dataflow.node(%7) -> (%arg19) [%arg21, %arg18, %arg20] {inputTaps = [0 : i32], level = 0 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<64xi8, #hls.mem<bram_t2p>>[index, index, index] {
// CHECK:                 ^bb0(%arg22: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg23: memref<64xi8, #hls.mem<bram_t2p>>, %arg24: index, %arg25: index, %arg26: index):
// CHECK:                   %c-24_i8 = arith.constant -24 : i8
// CHECK:                   affine.for %arg27 = 0 to 14 {
// CHECK:                     affine.for %arg28 = 0 to 14 {
// CHECK:                       affine.for %arg29 = 0 to 16 {
// CHECK:                         %8 = affine.load %arg22[%arg29, %arg27, %arg28] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:                         %9 = affine.load %arg23[%arg29 + symbol(%arg24) * 16] : memref<64xi8, #hls.mem<bram_t2p>>
// CHECK:                         %10 = arith.addi %9, %8 : i8
// CHECK:                         %11 = arith.divui %10, %c-24_i8 : i8
// CHECK:                         %12 = hls.affine.select #set3(%arg27, %arg28, %arg25, %arg26) %11, %10 : i8
// CHECK:                         affine.store %12, %arg23[%arg29 + symbol(%arg24) * 16] : memref<64xi8, #hls.mem<bram_t2p>>
// CHECK:                       } {parallel, point}
// CHECK:                     } {point}
// CHECK:                   } {point}
// CHECK:                 }
// CHECK:               }
// CHECK:             } {parallel}
// CHECK:           }
// CHECK:         }
// CHECK:       }
// CHECK:       hls.dataflow.node(%6, %arg9) -> (%arg7) {inputTaps = [0 : i32, 0 : i32], level = 0 : i32} : (memref<64xi8, #hls.mem<bram_t2p>>, memref<1000x64xi8, #hls.mem<dram>>) -> memref<1000xi8, #hls.mem<dram>> {
// CHECK:       ^bb0(%arg12: memref<64xi8, #hls.mem<bram_t2p>>, %arg13: memref<1000x64xi8, #hls.mem<dram>>, %arg14: memref<1000xi8, #hls.mem<dram>>):
// CHECK:         affine.for %arg15 = 0 to 4 {
// CHECK:           affine.for %arg16 = 0 to 100 {
// CHECK:             hls.dataflow.schedule(%arg15, %arg16, %arg12, %arg13, %arg14) : index, index, memref<64xi8, #hls.mem<bram_t2p>>, memref<1000x64xi8, #hls.mem<dram>>, memref<1000xi8, #hls.mem<dram>> {
// CHECK:             ^bb0(%arg17: index, %arg18: index, %arg19: memref<64xi8, #hls.mem<bram_t2p>>, %arg20: memref<1000x64xi8, #hls.mem<dram>>, %arg21: memref<1000xi8, #hls.mem<dram>>):
// CHECK:               %7 = hls.dataflow.buffer {depth = 1 : i32} : memref<10x16xi8, #hls.mem<bram_t2p>>
// CHECK:               %8 = hls.dataflow.buffer {depth = 1 : i32} : memref<10xi8, #hls.mem<bram_t2p>>
// CHECK:               hls.dataflow.node(%arg21) -> (%8) [%arg18] {inputTaps = [0 : i32], level = 2 : i32} : (memref<1000xi8, #hls.mem<dram>>) -> memref<10xi8, #hls.mem<bram_t2p>>[index] {
// CHECK:               ^bb0(%arg22: memref<1000xi8, #hls.mem<dram>>, %arg23: memref<10xi8, #hls.mem<bram_t2p>>, %arg24: index):
// CHECK:                 affine.for %arg25 = 0 to 10 {
// CHECK:                   %10 = affine.load %arg22[%arg25 + symbol(%arg24) * 10] : memref<1000xi8, #hls.mem<dram>>
// CHECK:                   affine.store %10, %arg23[%arg25] : memref<10xi8, #hls.mem<bram_t2p>>
// CHECK:                 } {parallel}
// CHECK:               }
// CHECK:               hls.dataflow.node(%arg20) -> (%7) [%arg18, %arg17] {inputTaps = [0 : i32], level = 2 : i32} : (memref<1000x64xi8, #hls.mem<dram>>) -> memref<10x16xi8, #hls.mem<bram_t2p>>[index, index] {
// CHECK:               ^bb0(%arg22: memref<1000x64xi8, #hls.mem<dram>>, %arg23: memref<10x16xi8, #hls.mem<bram_t2p>>, %arg24: index, %arg25: index):
// CHECK:                 affine.for %arg26 = 0 to 10 {
// CHECK:                   affine.for %arg27 = 0 to 16 {
// CHECK:                     %10 = affine.load %arg22[%arg26 + symbol(%arg24) * 10, %arg27 + symbol(%arg25) * 16] : memref<1000x64xi8, #hls.mem<dram>>
// CHECK:                     affine.store %10, %arg23[%arg26, %arg27] : memref<10x16xi8, #hls.mem<bram_t2p>>
// CHECK:                   } {parallel}
// CHECK:                 } {parallel}
// CHECK:               }
// CHECK:               %9 = hls.dataflow.buffer {depth = 1 : i32} : memref<10xi8, #hls.mem<bram_t2p>>
// CHECK:               hls.dataflow.node(%arg19, %7, %8) -> (%9) [%arg17] {inputTaps = [0 : i32, 0 : i32, 0 : i32], level = 1 : i32} : (memref<64xi8, #hls.mem<bram_t2p>>, memref<10x16xi8, #hls.mem<bram_t2p>>, memref<10xi8, #hls.mem<bram_t2p>>) -> memref<10xi8, #hls.mem<bram_t2p>>[index] {
// CHECK:               ^bb0(%arg22: memref<64xi8, #hls.mem<bram_t2p>>, %arg23: memref<10x16xi8, #hls.mem<bram_t2p>>, %arg24: memref<10xi8, #hls.mem<bram_t2p>>, %arg25: memref<10xi8, #hls.mem<bram_t2p>>, %arg26: index):
// CHECK:                 %c-24_i8 = arith.constant -24 : i8
// CHECK:                 affine.for %arg27 = 0 to 16 {
// CHECK:                   affine.for %arg28 = 0 to 10 {
// CHECK:                     %10 = affine.load %arg24[%arg28] : memref<10xi8, #hls.mem<bram_t2p>>
// CHECK:                     %11 = affine.load %arg25[%arg28] : memref<10xi8, #hls.mem<bram_t2p>>
// CHECK:                     %12 = hls.affine.select #set(%arg27) %10, %11 : i8
// CHECK:                     %13 = hls.affine.select #set4(%arg27, %arg26) %c-24_i8, %12 : i8
// CHECK:                     %14 = affine.load %arg22[%arg27 + symbol(%arg26) * 16] : memref<64xi8, #hls.mem<bram_t2p>>
// CHECK:                     %15 = affine.load %arg23[%arg28, %arg27] : memref<10x16xi8, #hls.mem<bram_t2p>>
// CHECK:                     %16 = arith.muli %14, %15 : i8
// CHECK:                     %17 = arith.addi %13, %16 : i8
// CHECK:                     affine.store %17, %arg25[%arg28] : memref<10xi8, #hls.mem<bram_t2p>>
// CHECK:                   } {parallel, point}
// CHECK:                 } {point}
// CHECK:               }
// CHECK:               hls.dataflow.node(%9) -> (%arg21) [%arg18] {inputTaps = [0 : i32], level = 0 : i32} : (memref<10xi8, #hls.mem<bram_t2p>>) -> memref<1000xi8, #hls.mem<dram>>[index] {
// CHECK:               ^bb0(%arg22: memref<10xi8, #hls.mem<bram_t2p>>, %arg23: memref<1000xi8, #hls.mem<dram>>, %arg24: index):
// CHECK:                 affine.for %arg25 = 0 to 10 {
// CHECK:                   %10 = affine.load %arg22[%arg25] : memref<10xi8, #hls.mem<bram_t2p>>
// CHECK:                   affine.store %10, %arg23[%arg25 + symbol(%arg24) * 10] : memref<1000xi8, #hls.mem<dram>>
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
  func.func @forward(%arg0: memref<64x56x56xi8, #hls.mem<dram>> {hls.buffer_info = #hls.buffer<tile = [16, 28, 28]>}, %arg1: memref<1000x64xi8, #hls.mem<dram>> {hls.buffer_info = #hls.buffer<tile = [10, 16]>}, %arg2: memref<64x64xi8, #hls.mem<dram>> {hls.buffer_info = #hls.buffer<tile = [16, 16]>}, %arg3: memref<64x64x3x3xi8, #hls.mem<dram>> {hls.buffer_info = #hls.buffer<tile = [16, 16, 1, 1]>}, %arg4: memref<64x64x3x3xi8, #hls.mem<dram>> {hls.buffer_info = #hls.buffer<tile = [16, 16, 1, 1]>}, %arg5: memref<1000xi8, #hls.mem<dram>> {hls.buffer_info = #hls.buffer<tile = [10]>}) attributes {top_func} {
    hls.dataflow.schedule(%arg2, %arg5, %arg3, %arg1, %arg0, %arg4) : memref<64x64xi8, #hls.mem<dram>>, memref<1000xi8, #hls.mem<dram>>, memref<64x64x3x3xi8, #hls.mem<dram>>, memref<1000x64xi8, #hls.mem<dram>>, memref<64x56x56xi8, #hls.mem<dram>>, memref<64x64x3x3xi8, #hls.mem<dram>> {
    ^bb0(%arg6: memref<64x64xi8, #hls.mem<dram>>, %arg7: memref<1000xi8, #hls.mem<dram>>, %arg8: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg9: memref<1000x64xi8, #hls.mem<dram>>, %arg10: memref<64x56x56xi8, #hls.mem<dram>>, %arg11: memref<64x64x3x3xi8, #hls.mem<dram>>):
      hls.dataflow.node() -> (%arg10) {inputTaps = [], level = 6 : i32} : () -> memref<64x56x56xi8, #hls.mem<dram>> {
      ^bb0(%arg12: memref<64x56x56xi8, #hls.mem<dram>>):
        affine.for %arg13 = 0 to 4 {
          affine.for %arg14 = 0 to 4 {
            affine.for %arg15 = 0 to 4 {
              hls.dataflow.schedule(%arg13, %arg15, %arg12, %arg14) : index, index, memref<64x56x56xi8, #hls.mem<dram>>, index {
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
      %2 = hls.dataflow.buffer {buffer_info = #hls.buffer<tile = [16, 14, 14]>, depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, #hls.mem<dram>>
      hls.dataflow.node(%1, %arg11) -> (%2) {inputTaps = [0 : i32, 0 : i32], level = 4 : i32} : (memref<64x56x56xi8, #hls.mem<dram>>, memref<64x64x3x3xi8, #hls.mem<dram>>) -> memref<64x28x28xi8, #hls.mem<dram>> {
      ^bb0(%arg12: memref<64x56x56xi8, #hls.mem<dram>>, %arg13: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg14: memref<64x28x28xi8, #hls.mem<dram>>):
        affine.for %arg15 = 0 to 4 {
          affine.for %arg16 = 0 to 3 {
            affine.for %arg17 = 0 to 3 {
              affine.for %arg18 = 0 to 4 {
                affine.for %arg19 = 0 to 2 {
                  affine.for %arg20 = 0 to 2 {
                    hls.dataflow.schedule(%arg17, %arg14, %arg20, %arg16, %arg19, %arg12, %arg15, %arg13, %arg18) : index, memref<64x28x28xi8, #hls.mem<dram>>, index, index, index, memref<64x56x56xi8, #hls.mem<dram>>, index, memref<64x64x3x3xi8, #hls.mem<dram>>, index {
                    ^bb0(%arg21: index, %arg22: memref<64x28x28xi8, #hls.mem<dram>>, %arg23: index, %arg24: index, %arg25: index, %arg26: memref<64x56x56xi8, #hls.mem<dram>>, %arg27: index, %arg28: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg29: index):
                      %7 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                      %8 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, #hls.mem<bram_t2p>>
                      %9 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                      hls.dataflow.node(%arg26) -> (%9) [%arg27, %arg24, %arg25, %arg21, %arg23] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x56x56xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index, index, index] {
                      ^bb0(%arg30: memref<64x56x56xi8, #hls.mem<dram>>, %arg31: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg32: index, %arg33: index, %arg34: index, %arg35: index, %arg36: index):
                        affine.for %arg37 = 0 to 16 {
                          affine.for %arg38 = 0 to 14 {
                            affine.for %arg39 = 0 to 14 {
                              %11 = affine.load %arg30[%arg37 + symbol(%arg32) * 16, %arg38 * 2 + symbol(%arg33) + symbol(%arg34) * 28 - 1, %arg39 * 2 + symbol(%arg35) + symbol(%arg36) * 28 - 1] : memref<64x56x56xi8, #hls.mem<dram>>
                              affine.store %11, %arg31[%arg37, %arg38, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
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
                          affine.for %arg36 = 0 to 14 {
                            affine.for %arg37 = 0 to 14 {
                              %11 = affine.load %arg30[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14, %arg37 + symbol(%arg34) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                              affine.store %11, %arg31[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
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
                            affine.for %arg39 = 0 to 14 {
                              affine.for %arg40 = 0 to 14 {
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
                              } {parallel, point}
                            } {parallel, point}
                          } {parallel, point}
                        } {point}
                      }
                      hls.dataflow.node(%10) -> (%arg22) [%arg29, %arg25, %arg23] {inputTaps = [0 : i32], level = 0 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<64x28x28xi8, #hls.mem<dram>>[index, index, index] {
                      ^bb0(%arg30: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg31: memref<64x28x28xi8, #hls.mem<dram>>, %arg32: index, %arg33: index, %arg34: index):
                        affine.for %arg35 = 0 to 16 {
                          affine.for %arg36 = 0 to 14 {
                            affine.for %arg37 = 0 to 14 {
                              %11 = affine.load %arg30[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              affine.store %11, %arg31[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14, %arg37 + symbol(%arg34) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
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
      %3 = hls.dataflow.buffer {buffer_info = #hls.buffer<tile = [16, 14, 14]>, depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, #hls.mem<dram>>
      hls.dataflow.node(%arg8, %2) -> (%3) {inputTaps = [0 : i32, 0 : i32], level = 3 : i32} : (memref<64x64x3x3xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>) -> memref<64x28x28xi8, #hls.mem<dram>> {
      ^bb0(%arg12: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg13: memref<64x28x28xi8, #hls.mem<dram>>, %arg14: memref<64x28x28xi8, #hls.mem<dram>>):
        affine.for %arg15 = 0 to 4 {
          affine.for %arg16 = 0 to 3 {
            affine.for %arg17 = 0 to 3 {
              affine.for %arg18 = 0 to 4 {
                affine.for %arg19 = 0 to 2 {
                  affine.for %arg20 = 0 to 2 {
                    hls.dataflow.schedule(%arg20, %arg16, %arg15, %arg17, %arg19, %arg14, %arg12, %arg13, %arg18) : index, index, index, index, index, memref<64x28x28xi8, #hls.mem<dram>>, memref<64x64x3x3xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>, index {
                    ^bb0(%arg21: index, %arg22: index, %arg23: index, %arg24: index, %arg25: index, %arg26: memref<64x28x28xi8, #hls.mem<dram>>, %arg27: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg28: memref<64x28x28xi8, #hls.mem<dram>>, %arg29: index):
                      %7 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                      %8 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, #hls.mem<bram_t2p>>
                      %9 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                      hls.dataflow.node(%arg28) -> (%9) [%arg23, %arg22, %arg25, %arg24, %arg21] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index, index, index] {
                      ^bb0(%arg30: memref<64x28x28xi8, #hls.mem<dram>>, %arg31: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg32: index, %arg33: index, %arg34: index, %arg35: index, %arg36: index):
                        affine.for %arg37 = 0 to 16 {
                          affine.for %arg38 = 0 to 14 {
                            affine.for %arg39 = 0 to 14 {
                              %11 = affine.load %arg30[%arg37 + symbol(%arg32) * 16, %arg38 + symbol(%arg33) + symbol(%arg34) * 14 - 1, %arg39 + symbol(%arg35) + symbol(%arg36) * 14 - 1] : memref<64x28x28xi8, #hls.mem<dram>>
                              affine.store %11, %arg31[%arg37, %arg38, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
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
                          affine.for %arg36 = 0 to 14 {
                            affine.for %arg37 = 0 to 14 {
                              %11 = affine.load %arg30[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14, %arg37 + symbol(%arg34) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                              affine.store %11, %arg31[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                            } {parallel}
                          } {parallel}
                        } {parallel}
                      }
                      %10 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                      hls.dataflow.node(%9, %8, %7) -> (%10) {inputTaps = [0 : i32, 0 : i32, 0 : i32], level = 1 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x16xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>> {
                      ^bb0(%arg30: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg31: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg32: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg33: memref<16x14x14xi8, #hls.mem<bram_t2p>>):
                        affine.for %arg34 = 0 to 16 {
                          affine.for %arg35 = 0 to 16 {
                            affine.for %arg36 = 0 to 14 {
                              affine.for %arg37 = 0 to 14 {
                                %11 = affine.load %arg30[%arg34, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %12 = affine.load %arg31[%arg35, %arg34] : memref<16x16xi8, #hls.mem<bram_t2p>>
                                %13 = affine.load %arg32[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %14 = affine.load %arg33[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %15 = hls.affine.select #set(%arg34) %13, %14 : i8
                                %16 = arith.muli %11, %12 : i8
                                %17 = arith.addi %15, %16 : i8
                                affine.store %17, %arg33[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              } {parallel, point}
                            } {parallel, point}
                          } {parallel, point}
                        } {point}
                      }
                      hls.dataflow.node(%10) -> (%arg26) [%arg29, %arg25, %arg21] {inputTaps = [0 : i32], level = 0 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<64x28x28xi8, #hls.mem<dram>>[index, index, index] {
                      ^bb0(%arg30: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg31: memref<64x28x28xi8, #hls.mem<dram>>, %arg32: index, %arg33: index, %arg34: index):
                        affine.for %arg35 = 0 to 16 {
                          affine.for %arg36 = 0 to 14 {
                            affine.for %arg37 = 0 to 14 {
                              %11 = affine.load %arg30[%arg35, %arg36, %arg37] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              affine.store %11, %arg31[%arg35 + symbol(%arg32) * 16, %arg36 + symbol(%arg33) * 14, %arg37 + symbol(%arg34) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
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
      %4 = hls.dataflow.buffer {buffer_info = #hls.buffer<tile = [16, 14, 14]>, depth = 1 : i32} : memref<64x28x28xi8, #hls.mem<dram>>
      %5 = hls.dataflow.buffer {buffer_info = #hls.buffer<tile = [16, 14, 14]>, depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, #hls.mem<dram>>
      hls.dataflow.node(%0, %arg6, %3) -> (%4, %5) {inputTaps = [2 : i32, 0 : i32, 0 : i32], level = 2 : i32} : (memref<64x56x56xi8, #hls.mem<dram>>, memref<64x64xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>) -> (memref<64x28x28xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>) {
      ^bb0(%arg12: memref<64x56x56xi8, #hls.mem<dram>>, %arg13: memref<64x64xi8, #hls.mem<dram>>, %arg14: memref<64x28x28xi8, #hls.mem<dram>>, %arg15: memref<64x28x28xi8, #hls.mem<dram>>, %arg16: memref<64x28x28xi8, #hls.mem<dram>>):
        affine.for %arg17 = 0 to 4 {
          affine.for %arg18 = 0 to 4 {
            affine.for %arg19 = 0 to 2 {
              affine.for %arg20 = 0 to 2 {
                hls.dataflow.schedule(%arg19, %arg20, %arg13, %arg14, %arg12, %arg17, %arg15, %arg16, %arg18) : index, index, memref<64x64xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>, memref<64x56x56xi8, #hls.mem<dram>>, index, memref<64x28x28xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>, index {
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
      %6 = hls.dataflow.buffer {buffer_info = #hls.buffer<tile = [16]>, depth = 1 : i32, init_value = -24 : i8} : memref<64xi8, #hls.mem<bram_t2p>>
      hls.dataflow.node(%4) -> (%6) {inputTaps = [0 : i32], level = 1 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<64xi8, #hls.mem<bram_t2p>> {
      ^bb0(%arg12: memref<64x28x28xi8, #hls.mem<dram>>, %arg13: memref<64xi8, #hls.mem<bram_t2p>>):
        affine.for %arg14 = 0 to 2 {
          affine.for %arg15 = 0 to 2 {
            affine.for %arg16 = 0 to 4 {
              hls.dataflow.schedule(%arg12, %arg14, %arg13, %arg15, %arg16) : memref<64x28x28xi8, #hls.mem<dram>>, index, memref<64xi8, #hls.mem<bram_t2p>>, index, index {
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
            hls.dataflow.schedule(%arg15, %arg16, %arg12, %arg13, %arg14) : index, index, memref<64xi8, #hls.mem<bram_t2p>>, memref<1000x64xi8, #hls.mem<dram>>, memref<1000xi8, #hls.mem<dram>> {
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

