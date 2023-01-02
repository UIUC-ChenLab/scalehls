// RUN: scalehls-opt -scalehls-convert-dataflow-to-func %s | FileCheck %s

// CHECK: #map = affine_map<() -> (4)>
// CHECK: #map1 = affine_map<() -> (100)>
// CHECK: #map2 = affine_map<(d0)[s0] -> (d0 * s0)>
// CHECK: #map3 = affine_map<(d0)[s0] -> (d0 mod s0)>
// CHECK: #map4 = affine_map<(d0)[s0] -> (d0 floordiv s0)>
// CHECK: #map5 = affine_map<() -> (2)>
// CHECK: #map6 = affine_map<() -> (3)>
// CHECK: #set = affine_set<(d0) : (d0 == 0)>
// CHECK: #set1 = affine_set<(d0, d1) : (d0 + d1 * 16 == 0)>
// CHECK: #set2 = affine_set<(d0, d1, d2, d3) : (-d0 - d2 * 14 + 27 == 0, -d1 - d3 * 14 + 27 == 0)>
// CHECK: #set3 = affine_set<(d0)[s0] : (-d0 - s0 * 16 + 63 == 0)>
// CHECK: #set4 = affine_set<(d0, d1, d2, d3) : (-d2 - d3 * 16 + 63 == 0, -d0 + 2 == 0, -d1 + 2 == 0)>
// CHECK: module attributes {torch.debug_module_name = "ResNet"} {
// CHECK:   func.func @forward_node1(%arg0: memref<10xi8, #hls.mem<bram_t2p>>, %arg1: memref<1000xi8, #hls.mem<dram>>, %arg2: index) attributes {inline} {
// CHECK:     affine.for %arg3 = 0 to 10 {
// CHECK:       %0 = affine.load %arg0[%arg3] : memref<10xi8, #hls.mem<bram_t2p>>
// CHECK:       affine.store %0, %arg1[%arg3 + symbol(%arg2) * 10] : memref<1000xi8, #hls.mem<dram>>
// CHECK:     } {parallel}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node2(%arg0: memref<64xi8, #hls.mem<bram_t2p>>, %arg1: memref<10x16xi8, #hls.mem<bram_t2p>>, %arg2: memref<10xi8, #hls.mem<bram_t2p>>, %arg3: memref<10xi8, #hls.mem<bram_t2p>>, %arg4: index) attributes {inline} {
// CHECK:     %c-24_i8 = arith.constant -24 : i8
// CHECK:     affine.for %arg5 = 0 to 16 {
// CHECK:       affine.for %arg6 = 0 to 10 {
// CHECK:         %0 = affine.load %arg2[%arg6] : memref<10xi8, #hls.mem<bram_t2p>>
// CHECK:         %1 = affine.load %arg3[%arg6] : memref<10xi8, #hls.mem<bram_t2p>>
// CHECK:         %2 = hls.affine.select #set(%arg5) %0, %1 : i8
// CHECK:         %3 = hls.affine.select #set1(%arg5, %arg4) %c-24_i8, %2 : i8
// CHECK:         %4 = affine.load %arg0[%arg5 + symbol(%arg4) * 16] : memref<64xi8, #hls.mem<bram_t2p>>
// CHECK:         %5 = affine.load %arg1[%arg6, %arg5] : memref<10x16xi8, #hls.mem<bram_t2p>>
// CHECK:         %6 = arith.muli %4, %5 : i8
// CHECK:         %7 = arith.addi %3, %6 : i8
// CHECK:         affine.store %7, %arg3[%arg6] : memref<10xi8, #hls.mem<bram_t2p>>
// CHECK:       } {parallel, point}
// CHECK:     } {point}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node3(%arg0: memref<1000x64xi8, #hls.mem<dram>>, %arg1: memref<10x16xi8, #hls.mem<bram_t2p>>, %arg2: index, %arg3: index) attributes {inline} {
// CHECK:     affine.for %arg4 = 0 to 10 {
// CHECK:       affine.for %arg5 = 0 to 16 {
// CHECK:         %0 = affine.load %arg0[%arg4 + symbol(%arg2) * 10, %arg5 + symbol(%arg3) * 16] : memref<1000x64xi8, #hls.mem<dram>>
// CHECK:         affine.store %0, %arg1[%arg4, %arg5] : memref<10x16xi8, #hls.mem<bram_t2p>>
// CHECK:       } {parallel}
// CHECK:     } {parallel}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node4(%arg0: memref<1000xi8, #hls.mem<dram>>, %arg1: memref<10xi8, #hls.mem<bram_t2p>>, %arg2: index) attributes {inline} {
// CHECK:     affine.for %arg3 = 0 to 10 {
// CHECK:       %0 = affine.load %arg0[%arg3 + symbol(%arg2) * 10] : memref<1000xi8, #hls.mem<dram>>
// CHECK:       affine.store %0, %arg1[%arg3] : memref<10xi8, #hls.mem<bram_t2p>>
// CHECK:     } {parallel}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node0(%arg0: memref<64xi8, #hls.mem<bram_t2p>>, %arg1: memref<1000x64xi8, #hls.mem<dram>>, %arg2: memref<1000xi8, #hls.mem<dram>>, %arg3: memref<1000xi8, #hls.mem<dram>>) {
// CHECK:     %0 = affine.apply #map()
// CHECK:     %1 = affine.apply #map1()
// CHECK:     %2 = affine.apply #map2(%0)[%1]
// CHECK:     affine.for %arg4 = 0 to %2 {
// CHECK:       %3 = affine.apply #map3(%arg4)[%1]
// CHECK:       %4 = affine.apply #map4(%arg4)[%1]
// CHECK:       %5 = hls.dataflow.buffer {depth = 1 : i32} : memref<10x16xi8, #hls.mem<bram_t2p>>
// CHECK:       %6 = hls.dataflow.buffer {depth = 1 : i32} : memref<10xi8, #hls.mem<bram_t2p>>
// CHECK:       func.call @forward_node4(%arg2, %6, %3) : (memref<1000xi8, #hls.mem<dram>>, memref<10xi8, #hls.mem<bram_t2p>>, index) -> ()
// CHECK:       func.call @forward_node3(%arg1, %5, %3, %4) : (memref<1000x64xi8, #hls.mem<dram>>, memref<10x16xi8, #hls.mem<bram_t2p>>, index, index) -> ()
// CHECK:       %7 = hls.dataflow.buffer {depth = 1 : i32} : memref<10xi8, #hls.mem<bram_t2p>>
// CHECK:       func.call @forward_node2(%arg0, %5, %6, %7, %4) : (memref<64xi8, #hls.mem<bram_t2p>>, memref<10x16xi8, #hls.mem<bram_t2p>>, memref<10xi8, #hls.mem<bram_t2p>>, memref<10xi8, #hls.mem<bram_t2p>>, index) -> ()
// CHECK:       func.call @forward_node1(%7, %arg3, %3) : (memref<10xi8, #hls.mem<bram_t2p>>, memref<1000xi8, #hls.mem<dram>>, index) -> ()
// CHECK:     } {loop_directive = #hls.loop<pipeline=false, targetII=1, dataflow=true, flatten=false>}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node6(%arg0: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg1: memref<64xi8, #hls.mem<bram_t2p>>, %arg2: index, %arg3: index, %arg4: index) attributes {inline} {
// CHECK:     %c-24_i8 = arith.constant -24 : i8
// CHECK:     affine.for %arg5 = 0 to 14 {
// CHECK:       affine.for %arg6 = 0 to 14 {
// CHECK:         affine.for %arg7 = 0 to 16 {
// CHECK:           %0 = affine.load %arg0[%arg7, %arg5, %arg6] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:           %1 = affine.load %arg1[%arg7 + symbol(%arg2) * 16] : memref<64xi8, #hls.mem<bram_t2p>>
// CHECK:           %2 = arith.addi %1, %0 : i8
// CHECK:           %3 = arith.divui %2, %c-24_i8 : i8
// CHECK:           %4 = hls.affine.select #set2(%arg5, %arg6, %arg3, %arg4) %3, %2 : i8
// CHECK:           affine.store %4, %arg1[%arg7 + symbol(%arg2) * 16] : memref<64xi8, #hls.mem<bram_t2p>>
// CHECK:         } {parallel, point}
// CHECK:       } {point}
// CHECK:     } {point}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node7(%arg0: memref<64x28x28xi8, #hls.mem<dram>>, %arg1: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg2: index, %arg3: index, %arg4: index) attributes {inline} {
// CHECK:     affine.for %arg5 = 0 to 16 {
// CHECK:       affine.for %arg6 = 0 to 14 {
// CHECK:         affine.for %arg7 = 0 to 14 {
// CHECK:           %0 = affine.load %arg0[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:           affine.store %0, %arg1[%arg5, %arg6, %arg7] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:         } {parallel}
// CHECK:       } {parallel}
// CHECK:     } {parallel}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node5(%arg0: !hls.stream<i1, 1>, %arg1: memref<64x28x28xi8, #hls.mem<dram>>, %arg2: memref<64xi8, #hls.mem<bram_t2p>>) {
// CHECK:     hls.dataflow.stream_read %arg0 : (!hls.stream<i1, 1>) -> ()
// CHECK:     %0 = affine.apply #map5()
// CHECK:     %1 = affine.apply #map5()
// CHECK:     %2 = affine.apply #map2(%0)[%1]
// CHECK:     %3 = affine.apply #map()
// CHECK:     %4 = affine.apply #map2(%2)[%3]
// CHECK:     affine.for %arg3 = 0 to %4 {
// CHECK:       %5 = affine.apply #map3(%arg3)[%3]
// CHECK:       %6 = affine.apply #map4(%arg3)[%3]
// CHECK:       %7 = affine.apply #map3(%6)[%1]
// CHECK:       %8 = affine.apply #map4(%6)[%1]
// CHECK:       %9 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:       func.call @forward_node7(%arg1, %9, %5, %8, %7) : (memref<64x28x28xi8, #hls.mem<dram>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>, index, index, index) -> ()
// CHECK:       func.call @forward_node6(%9, %arg2, %5, %8, %7) : (memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<64xi8, #hls.mem<bram_t2p>>, index, index, index) -> ()
// CHECK:     } {loop_directive = #hls.loop<pipeline=false, targetII=1, dataflow=true, flatten=false>}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node9(%arg0: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg1: memref<64x28x28xi8, #hls.mem<dram>>, %arg2: index, %arg3: index, %arg4: index) attributes {inline} {
// CHECK:     affine.for %arg5 = 0 to 16 {
// CHECK:       affine.for %arg6 = 0 to 14 {
// CHECK:         affine.for %arg7 = 0 to 14 {
// CHECK:           %0 = affine.load %arg0[%arg5, %arg6, %arg7] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:           affine.store %0, %arg1[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:         } {parallel}
// CHECK:       } {parallel}
// CHECK:     } {parallel}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node10(%arg0: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg1: memref<64x28x28xi8, #hls.mem<dram>>, %arg2: index, %arg3: index, %arg4: index) attributes {inline} {
// CHECK:     affine.for %arg5 = 0 to 16 {
// CHECK:       affine.for %arg6 = 0 to 14 {
// CHECK:         affine.for %arg7 = 0 to 14 {
// CHECK:           %0 = affine.load %arg0[%arg5, %arg6, %arg7] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:           affine.store %0, %arg1[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:         } {parallel}
// CHECK:       } {parallel}
// CHECK:     } {parallel}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node11(%arg0: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg1: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg2: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg3: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg4: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg5: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg6: index) attributes {inline} {
// CHECK:     %c-24_i8 = arith.constant -24 : i8
// CHECK:     affine.for %arg7 = 0 to 16 {
// CHECK:       affine.for %arg8 = 0 to 16 {
// CHECK:         affine.for %arg9 = 0 to 14 {
// CHECK:           affine.for %arg10 = 0 to 14 {
// CHECK:             %0 = affine.load %arg1[%arg7, %arg9, %arg10] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %1 = affine.load %arg2[%arg8, %arg7] : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:             %2 = affine.load %arg3[%arg8, %arg9, %arg10] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %3 = affine.load %arg5[%arg8, %arg9, %arg10] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %4 = hls.affine.select #set(%arg7) %2, %3 : i8
// CHECK:             %5 = arith.muli %0, %1 : i8
// CHECK:             %6 = arith.addi %4, %5 : i8
// CHECK:             affine.store %6, %arg5[%arg8, %arg9, %arg10] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %7 = affine.load %arg0[%arg8, %arg9, %arg10] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %8 = arith.addi %7, %6 : i8
// CHECK:             %9 = arith.cmpi ugt, %8, %c-24_i8 : i8
// CHECK:             %10 = arith.select %9, %8, %c-24_i8 : i8
// CHECK:             affine.if #set3(%arg7)[%arg6] {
// CHECK:               affine.store %10, %arg4[%arg8, %arg9, %arg10] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             }
// CHECK:           } {parallel, point}
// CHECK:         } {parallel, point}
// CHECK:       } {parallel, point}
// CHECK:     } {point}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node12(%arg0: memref<64x28x28xi8, #hls.mem<dram>>, %arg1: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg2: index, %arg3: index, %arg4: index) attributes {inline} {
// CHECK:     affine.for %arg5 = 0 to 16 {
// CHECK:       affine.for %arg6 = 0 to 14 {
// CHECK:         affine.for %arg7 = 0 to 14 {
// CHECK:           %0 = affine.load %arg0[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:           affine.store %0, %arg1[%arg5, %arg6, %arg7] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:         } {parallel}
// CHECK:       } {parallel}
// CHECK:     } {parallel}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node13(%arg0: memref<64x28x28xi8, #hls.mem<dram>>, %arg1: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg2: index, %arg3: index, %arg4: index) attributes {inline} {
// CHECK:     affine.for %arg5 = 0 to 16 {
// CHECK:       affine.for %arg6 = 0 to 14 {
// CHECK:         affine.for %arg7 = 0 to 14 {
// CHECK:           %0 = affine.load %arg0[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:           affine.store %0, %arg1[%arg5, %arg6, %arg7] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:         } {parallel}
// CHECK:       } {parallel}
// CHECK:     } {parallel}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node14(%arg0: memref<64x64xi8, #hls.mem<dram>>, %arg1: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg2: index, %arg3: index) attributes {inline} {
// CHECK:     affine.for %arg4 = 0 to 16 {
// CHECK:       affine.for %arg5 = 0 to 16 {
// CHECK:         %0 = affine.load %arg0[%arg4 + symbol(%arg2) * 16, %arg5 + symbol(%arg3) * 16] : memref<64x64xi8, #hls.mem<dram>>
// CHECK:         affine.store %0, %arg1[%arg4, %arg5] : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:       } {parallel}
// CHECK:     } {parallel}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node15(%arg0: memref<64x56x56xi8, #hls.mem<dram>>, %arg1: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg2: index, %arg3: index, %arg4: index) attributes {inline} {
// CHECK:     affine.for %arg5 = 0 to 16 {
// CHECK:       affine.for %arg6 = 0 to 14 {
// CHECK:         affine.for %arg7 = 0 to 14 {
// CHECK:           %0 = affine.load %arg0[%arg5 + symbol(%arg2) * 16, %arg6 * 2 + symbol(%arg3) * 28, %arg7 * 2 + symbol(%arg4) * 28] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:           affine.store %0, %arg1[%arg5, %arg6, %arg7] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:         } {parallel}
// CHECK:       } {parallel}
// CHECK:     } {parallel}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node8(%arg0: !hls.stream<i1, 3>, %arg1: memref<64x56x56xi8, #hls.mem<dram>>, %arg2: memref<64x64xi8, #hls.mem<dram>>, %arg3: !hls.stream<i1, 1>, %arg4: memref<64x28x28xi8, #hls.mem<dram>>, %arg5: memref<64x28x28xi8, #hls.mem<dram>>, %arg6: !hls.stream<i1, 1>, %arg7: memref<64x28x28xi8, #hls.mem<dram>>, %arg8: memref<64x28x28xi8, #hls.mem<dram>>) {
// CHECK:     %true = arith.constant true
// CHECK:     hls.dataflow.stream_read %arg3 : (!hls.stream<i1, 1>) -> ()
// CHECK:     hls.dataflow.stream_read %arg0 : (!hls.stream<i1, 3>) -> ()
// CHECK:     %0 = affine.apply #map()
// CHECK:     %1 = affine.apply #map()
// CHECK:     %2 = affine.apply #map2(%0)[%1]
// CHECK:     %3 = affine.apply #map5()
// CHECK:     %4 = affine.apply #map2(%2)[%3]
// CHECK:     %5 = affine.apply #map5()
// CHECK:     %6 = affine.apply #map2(%4)[%5]
// CHECK:     affine.for %arg9 = 0 to %6 {
// CHECK:       %7 = affine.apply #map3(%arg9)[%5]
// CHECK:       %8 = affine.apply #map4(%arg9)[%5]
// CHECK:       %9 = affine.apply #map3(%8)[%3]
// CHECK:       %10 = affine.apply #map4(%8)[%3]
// CHECK:       %11 = affine.apply #map3(%10)[%1]
// CHECK:       %12 = affine.apply #map4(%10)[%1]
// CHECK:       %13 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:       %14 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:       %15 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:       %16 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:       %17 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:       func.call @forward_node15(%arg1, %17, %12, %9, %7) : (memref<64x56x56xi8, #hls.mem<dram>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>, index, index, index) -> ()
// CHECK:       func.call @forward_node14(%arg2, %16, %11, %12) : (memref<64x64xi8, #hls.mem<dram>>, memref<16x16xi8, #hls.mem<bram_t2p>>, index, index) -> ()
// CHECK:       func.call @forward_node13(%arg5, %15, %11, %9, %7) : (memref<64x28x28xi8, #hls.mem<dram>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>, index, index, index) -> ()
// CHECK:       func.call @forward_node12(%arg4, %14, %11, %9, %7) : (memref<64x28x28xi8, #hls.mem<dram>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>, index, index, index) -> ()
// CHECK:       %18 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:       func.call @forward_node11(%14, %17, %16, %15, %13, %18, %12) : (memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x16xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>, index) -> ()
// CHECK:       func.call @forward_node10(%18, %arg8, %11, %9, %7) : (memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<64x28x28xi8, #hls.mem<dram>>, index, index, index) -> ()
// CHECK:       func.call @forward_node9(%13, %arg7, %11, %9, %7) : (memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<64x28x28xi8, #hls.mem<dram>>, index, index, index) -> ()
// CHECK:     } {loop_directive = #hls.loop<pipeline=false, targetII=1, dataflow=true, flatten=false>}
// CHECK:     hls.dataflow.stream_write %arg6, %true : <i1, 1>, i1
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node17(%arg0: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg1: memref<64x28x28xi8, #hls.mem<dram>>, %arg2: index, %arg3: index, %arg4: index) attributes {inline} {
// CHECK:     affine.for %arg5 = 0 to 16 {
// CHECK:       affine.for %arg6 = 0 to 14 step 2 {
// CHECK:         affine.for %arg7 = 0 to 14 step 2 {
// CHECK:           %0 = affine.load %arg0[%arg5, %arg6, %arg7] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:           affine.store %0, %arg1[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:           %1 = affine.load %arg0[%arg5, %arg6, %arg7 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:           affine.store %1, %arg1[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:           %2 = affine.load %arg0[%arg5, %arg6 + 1, %arg7] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:           affine.store %2, %arg1[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14 + 1, %arg7 + symbol(%arg4) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:           %3 = affine.load %arg0[%arg5, %arg6 + 1, %arg7 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:           affine.store %3, %arg1[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14 + 1, %arg7 + symbol(%arg4) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:         } {parallel}
// CHECK:       } {parallel}
// CHECK:     } {parallel}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node18(%arg0: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg1: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg2: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg3: memref<16x14x14xi8, #hls.mem<bram_t2p>>) attributes {inline} {
// CHECK:     affine.for %arg4 = 0 to 16 {
// CHECK:       affine.for %arg5 = 0 to 16 {
// CHECK:         affine.for %arg6 = 0 to 14 step 2 {
// CHECK:           affine.for %arg7 = 0 to 14 step 2 {
// CHECK:             %0 = affine.load %arg0[%arg4, %arg6, %arg7] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %1 = affine.load %arg1[%arg5, %arg4] : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:             %2 = affine.load %arg2[%arg5, %arg6, %arg7] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %3 = affine.load %arg3[%arg5, %arg6, %arg7] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %4 = hls.affine.select #set(%arg4) %2, %3 : i8
// CHECK:             %5 = arith.muli %0, %1 : i8
// CHECK:             %6 = arith.addi %4, %5 : i8
// CHECK:             affine.store %6, %arg3[%arg5, %arg6, %arg7] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %7 = affine.load %arg0[%arg4, %arg6, %arg7 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %8 = affine.load %arg2[%arg5, %arg6, %arg7 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %9 = affine.load %arg3[%arg5, %arg6, %arg7 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %10 = hls.affine.select #set(%arg4) %8, %9 : i8
// CHECK:             %11 = arith.muli %7, %1 : i8
// CHECK:             %12 = arith.addi %10, %11 : i8
// CHECK:             affine.store %12, %arg3[%arg5, %arg6, %arg7 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %13 = affine.load %arg0[%arg4, %arg6 + 1, %arg7] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %14 = affine.load %arg2[%arg5, %arg6 + 1, %arg7] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %15 = affine.load %arg3[%arg5, %arg6 + 1, %arg7] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %16 = hls.affine.select #set(%arg4) %14, %15 : i8
// CHECK:             %17 = arith.muli %13, %1 : i8
// CHECK:             %18 = arith.addi %16, %17 : i8
// CHECK:             affine.store %18, %arg3[%arg5, %arg6 + 1, %arg7] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %19 = affine.load %arg0[%arg4, %arg6 + 1, %arg7 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %20 = affine.load %arg2[%arg5, %arg6 + 1, %arg7 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %21 = affine.load %arg3[%arg5, %arg6 + 1, %arg7 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %22 = hls.affine.select #set(%arg4) %20, %21 : i8
// CHECK:             %23 = arith.muli %19, %1 : i8
// CHECK:             %24 = arith.addi %22, %23 : i8
// CHECK:             affine.store %24, %arg3[%arg5, %arg6 + 1, %arg7 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:           } {parallel, point}
// CHECK:         } {parallel, point}
// CHECK:       } {parallel, point}
// CHECK:     } {point}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node19(%arg0: memref<64x28x28xi8, #hls.mem<dram>>, %arg1: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg2: index, %arg3: index, %arg4: index) attributes {inline} {
// CHECK:     affine.for %arg5 = 0 to 16 {
// CHECK:       affine.for %arg6 = 0 to 14 step 2 {
// CHECK:         affine.for %arg7 = 0 to 14 step 2 {
// CHECK:           %0 = affine.load %arg0[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:           affine.store %0, %arg1[%arg5, %arg6, %arg7] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:           %1 = affine.load %arg0[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:           affine.store %1, %arg1[%arg5, %arg6, %arg7 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:           %2 = affine.load %arg0[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14 + 1, %arg7 + symbol(%arg4) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:           affine.store %2, %arg1[%arg5, %arg6 + 1, %arg7] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:           %3 = affine.load %arg0[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14 + 1, %arg7 + symbol(%arg4) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:           affine.store %3, %arg1[%arg5, %arg6 + 1, %arg7 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:         } {parallel}
// CHECK:       } {parallel}
// CHECK:     } {parallel}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node20(%arg0: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg1: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg2: index, %arg3: index, %arg4: index, %arg5: index) attributes {inline} {
// CHECK:     affine.for %arg6 = 0 to 16 {
// CHECK:       affine.for %arg7 = 0 to 16 {
// CHECK:         %0 = affine.load %arg0[%arg6 + symbol(%arg2) * 16, %arg7 + symbol(%arg3) * 16, symbol(%arg4), symbol(%arg5)] : memref<64x64x3x3xi8, #hls.mem<dram>>
// CHECK:         affine.store %0, %arg1[%arg6, %arg7] : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:       } {parallel}
// CHECK:     } {parallel}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node21(%arg0: memref<64x28x28xi8, #hls.mem<dram>>, %arg1: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg2: index, %arg3: index, %arg4: index, %arg5: index, %arg6: index) attributes {inline} {
// CHECK:     affine.for %arg7 = 0 to 16 {
// CHECK:       affine.for %arg8 = 0 to 14 step 2 {
// CHECK:         affine.for %arg9 = 0 to 14 step 2 {
// CHECK:           %0 = affine.load %arg0[%arg7 + symbol(%arg2) * 16, %arg8 + symbol(%arg3) + symbol(%arg4) * 14 - 1, %arg9 + symbol(%arg5) + symbol(%arg6) * 14 - 1] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:           affine.store %0, %arg1[%arg7, %arg8, %arg9] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:           %1 = affine.load %arg0[%arg7 + symbol(%arg2) * 16, %arg8 + symbol(%arg3) + symbol(%arg4) * 14 - 1, %arg9 + symbol(%arg5) + symbol(%arg6) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:           affine.store %1, %arg1[%arg7, %arg8, %arg9 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:           %2 = affine.load %arg0[%arg7 + symbol(%arg2) * 16, %arg8 + symbol(%arg3) + symbol(%arg4) * 14, %arg9 + symbol(%arg5) + symbol(%arg6) * 14 - 1] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:           affine.store %2, %arg1[%arg7, %arg8 + 1, %arg9] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:           %3 = affine.load %arg0[%arg7 + symbol(%arg2) * 16, %arg8 + symbol(%arg3) + symbol(%arg4) * 14, %arg9 + symbol(%arg5) + symbol(%arg6) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:           affine.store %3, %arg1[%arg7, %arg8 + 1, %arg9 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:         } {parallel}
// CHECK:       } {parallel}
// CHECK:     } {parallel}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node16(%arg0: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg1: !hls.stream<i1, 1>, %arg2: memref<64x28x28xi8, #hls.mem<dram>>, %arg3: memref<64x28x28xi8, #hls.mem<dram>>, %arg4: !hls.stream<i1, 1>, %arg5: memref<64x28x28xi8, #hls.mem<dram>>) {
// CHECK:     %true = arith.constant true
// CHECK:     hls.dataflow.stream_read %arg1 : (!hls.stream<i1, 1>) -> ()
// CHECK:     %0 = affine.apply #map()
// CHECK:     %1 = affine.apply #map6()
// CHECK:     %2 = affine.apply #map2(%0)[%1]
// CHECK:     %3 = affine.apply #map6()
// CHECK:     %4 = affine.apply #map2(%2)[%3]
// CHECK:     %5 = affine.apply #map()
// CHECK:     %6 = affine.apply #map2(%4)[%5]
// CHECK:     %7 = affine.apply #map5()
// CHECK:     %8 = affine.apply #map2(%6)[%7]
// CHECK:     %9 = affine.apply #map5()
// CHECK:     %10 = affine.apply #map2(%8)[%9]
// CHECK:     affine.for %arg6 = 0 to %10 {
// CHECK:       %11 = affine.apply #map3(%arg6)[%9]
// CHECK:       %12 = affine.apply #map4(%arg6)[%9]
// CHECK:       %13 = affine.apply #map3(%12)[%7]
// CHECK:       %14 = affine.apply #map4(%12)[%7]
// CHECK:       %15 = affine.apply #map3(%14)[%5]
// CHECK:       %16 = affine.apply #map4(%14)[%5]
// CHECK:       %17 = affine.apply #map3(%16)[%3]
// CHECK:       %18 = affine.apply #map4(%16)[%3]
// CHECK:       %19 = affine.apply #map3(%18)[%1]
// CHECK:       %20 = affine.apply #map4(%18)[%1]
// CHECK:       %21 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:       %22 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:       %23 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:       func.call @forward_node21(%arg2, %23, %20, %19, %13, %17, %11) : (memref<64x28x28xi8, #hls.mem<dram>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>, index, index, index, index, index) -> ()
// CHECK:       func.call @forward_node20(%arg0, %22, %15, %20, %19, %17) : (memref<64x64x3x3xi8, #hls.mem<dram>>, memref<16x16xi8, #hls.mem<bram_t2p>>, index, index, index, index) -> ()
// CHECK:       func.call @forward_node19(%arg3, %21, %15, %13, %11) : (memref<64x28x28xi8, #hls.mem<dram>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>, index, index, index) -> ()
// CHECK:       %24 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:       func.call @forward_node18(%23, %22, %21, %24) : (memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x16xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> ()
// CHECK:       func.call @forward_node17(%24, %arg5, %15, %13, %11) : (memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<64x28x28xi8, #hls.mem<dram>>, index, index, index) -> ()
// CHECK:     } {loop_directive = #hls.loop<pipeline=false, targetII=1, dataflow=true, flatten=false>}
// CHECK:     hls.dataflow.stream_write %arg4, %true : <i1, 1>, i1
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node23(%arg0: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg1: memref<64x28x28xi8, #hls.mem<dram>>, %arg2: index, %arg3: index, %arg4: index) attributes {inline} {
// CHECK:     affine.for %arg5 = 0 to 16 {
// CHECK:       affine.for %arg6 = 0 to 14 step 2 {
// CHECK:         affine.for %arg7 = 0 to 14 step 2 {
// CHECK:           %0 = affine.load %arg0[%arg5, %arg6, %arg7] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:           affine.store %0, %arg1[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:           %1 = affine.load %arg0[%arg5, %arg6, %arg7 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:           affine.store %1, %arg1[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:           %2 = affine.load %arg0[%arg5, %arg6 + 1, %arg7] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:           affine.store %2, %arg1[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14 + 1, %arg7 + symbol(%arg4) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:           %3 = affine.load %arg0[%arg5, %arg6 + 1, %arg7 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:           affine.store %3, %arg1[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14 + 1, %arg7 + symbol(%arg4) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:         } {parallel}
// CHECK:       } {parallel}
// CHECK:     } {parallel}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node24(%arg0: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg1: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg2: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg3: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg4: index, %arg5: index, %arg6: index) attributes {inline} {
// CHECK:     %c-24_i8 = arith.constant -24 : i8
// CHECK:     affine.for %arg7 = 0 to 16 {
// CHECK:       affine.for %arg8 = 0 to 16 {
// CHECK:         affine.for %arg9 = 0 to 14 step 2 {
// CHECK:           affine.for %arg10 = 0 to 14 step 2 {
// CHECK:             %0 = affine.load %arg0[%arg7, %arg9, %arg10] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %1 = affine.load %arg1[%arg8, %arg7] : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:             %2 = affine.load %arg2[%arg8, %arg9, %arg10] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %3 = affine.load %arg3[%arg8, %arg9, %arg10] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %4 = hls.affine.select #set(%arg7) %2, %3 : i8
// CHECK:             %5 = arith.muli %0, %1 : i8
// CHECK:             %6 = arith.addi %4, %5 : i8
// CHECK:             %7 = arith.cmpi ugt, %6, %c-24_i8 : i8
// CHECK:             %8 = arith.select %7, %6, %c-24_i8 : i8
// CHECK:             %9 = hls.affine.select #set4(%arg6, %arg4, %arg7, %arg5) %8, %6 : i8
// CHECK:             affine.store %9, %arg3[%arg8, %arg9, %arg10] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %10 = affine.load %arg0[%arg7, %arg9, %arg10 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %11 = affine.load %arg2[%arg8, %arg9, %arg10 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %12 = affine.load %arg3[%arg8, %arg9, %arg10 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %13 = hls.affine.select #set(%arg7) %11, %12 : i8
// CHECK:             %14 = arith.muli %10, %1 : i8
// CHECK:             %15 = arith.addi %13, %14 : i8
// CHECK:             %16 = arith.cmpi ugt, %15, %c-24_i8 : i8
// CHECK:             %17 = arith.select %16, %15, %c-24_i8 : i8
// CHECK:             %18 = hls.affine.select #set4(%arg6, %arg4, %arg7, %arg5) %17, %15 : i8
// CHECK:             affine.store %18, %arg3[%arg8, %arg9, %arg10 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %19 = affine.load %arg0[%arg7, %arg9 + 1, %arg10] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %20 = affine.load %arg2[%arg8, %arg9 + 1, %arg10] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %21 = affine.load %arg3[%arg8, %arg9 + 1, %arg10] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %22 = hls.affine.select #set(%arg7) %20, %21 : i8
// CHECK:             %23 = arith.muli %19, %1 : i8
// CHECK:             %24 = arith.addi %22, %23 : i8
// CHECK:             %25 = arith.cmpi ugt, %24, %c-24_i8 : i8
// CHECK:             %26 = arith.select %25, %24, %c-24_i8 : i8
// CHECK:             %27 = hls.affine.select #set4(%arg6, %arg4, %arg7, %arg5) %26, %24 : i8
// CHECK:             affine.store %27, %arg3[%arg8, %arg9 + 1, %arg10] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %28 = affine.load %arg0[%arg7, %arg9 + 1, %arg10 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %29 = affine.load %arg2[%arg8, %arg9 + 1, %arg10 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %30 = affine.load %arg3[%arg8, %arg9 + 1, %arg10 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:             %31 = hls.affine.select #set(%arg7) %29, %30 : i8
// CHECK:             %32 = arith.muli %28, %1 : i8
// CHECK:             %33 = arith.addi %31, %32 : i8
// CHECK:             %34 = arith.cmpi ugt, %33, %c-24_i8 : i8
// CHECK:             %35 = arith.select %34, %33, %c-24_i8 : i8
// CHECK:             %36 = hls.affine.select #set4(%arg6, %arg4, %arg7, %arg5) %35, %33 : i8
// CHECK:             affine.store %36, %arg3[%arg8, %arg9 + 1, %arg10 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:           } {parallel, point}
// CHECK:         } {parallel, point}
// CHECK:       } {parallel, point}
// CHECK:     } {point}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node25(%arg0: memref<64x28x28xi8, #hls.mem<dram>>, %arg1: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg2: index, %arg3: index, %arg4: index) attributes {inline} {
// CHECK:     affine.for %arg5 = 0 to 16 {
// CHECK:       affine.for %arg6 = 0 to 14 step 2 {
// CHECK:         affine.for %arg7 = 0 to 14 step 2 {
// CHECK:           %0 = affine.load %arg0[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:           affine.store %0, %arg1[%arg5, %arg6, %arg7] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:           %1 = affine.load %arg0[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:           affine.store %1, %arg1[%arg5, %arg6, %arg7 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:           %2 = affine.load %arg0[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14 + 1, %arg7 + symbol(%arg4) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:           affine.store %2, %arg1[%arg5, %arg6 + 1, %arg7] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:           %3 = affine.load %arg0[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14 + 1, %arg7 + symbol(%arg4) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:           affine.store %3, %arg1[%arg5, %arg6 + 1, %arg7 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:         } {parallel}
// CHECK:       } {parallel}
// CHECK:     } {parallel}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node26(%arg0: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg1: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg2: index, %arg3: index, %arg4: index, %arg5: index) attributes {inline} {
// CHECK:     affine.for %arg6 = 0 to 16 {
// CHECK:       affine.for %arg7 = 0 to 16 {
// CHECK:         %0 = affine.load %arg0[%arg6 + symbol(%arg2) * 16, %arg7 + symbol(%arg3) * 16, symbol(%arg4), symbol(%arg5)] : memref<64x64x3x3xi8, #hls.mem<dram>>
// CHECK:         affine.store %0, %arg1[%arg6, %arg7] : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:       } {parallel}
// CHECK:     } {parallel}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node27(%arg0: memref<64x56x56xi8, #hls.mem<dram>>, %arg1: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg2: index, %arg3: index, %arg4: index, %arg5: index, %arg6: index) attributes {inline} {
// CHECK:     affine.for %arg7 = 0 to 16 {
// CHECK:       affine.for %arg8 = 0 to 14 step 2 {
// CHECK:         affine.for %arg9 = 0 to 14 step 2 {
// CHECK:           %0 = affine.load %arg0[%arg7 + symbol(%arg2) * 16, %arg8 * 2 + symbol(%arg3) + symbol(%arg4) * 28 - 1, %arg9 * 2 + symbol(%arg5) + symbol(%arg6) * 28 - 1] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:           affine.store %0, %arg1[%arg7, %arg8, %arg9] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:           %1 = affine.load %arg0[%arg7 + symbol(%arg2) * 16, %arg8 * 2 + symbol(%arg3) + symbol(%arg4) * 28 - 1, %arg9 * 2 + symbol(%arg5) + symbol(%arg6) * 28 + 1] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:           affine.store %1, %arg1[%arg7, %arg8, %arg9 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:           %2 = affine.load %arg0[%arg7 + symbol(%arg2) * 16, %arg8 * 2 + symbol(%arg3) + symbol(%arg4) * 28 + 1, %arg9 * 2 + symbol(%arg5) + symbol(%arg6) * 28 - 1] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:           affine.store %2, %arg1[%arg7, %arg8 + 1, %arg9] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:           %3 = affine.load %arg0[%arg7 + symbol(%arg2) * 16, %arg8 * 2 + symbol(%arg3) + symbol(%arg4) * 28 + 1, %arg9 * 2 + symbol(%arg5) + symbol(%arg6) * 28 + 1] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:           affine.store %3, %arg1[%arg7, %arg8 + 1, %arg9 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:         } {parallel}
// CHECK:       } {parallel}
// CHECK:     } {parallel}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node22(%arg0: !hls.stream<i1, 1>, %arg1: memref<64x56x56xi8, #hls.mem<dram>>, %arg2: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg3: memref<64x28x28xi8, #hls.mem<dram>>, %arg4: !hls.stream<i1, 1>, %arg5: memref<64x28x28xi8, #hls.mem<dram>>) {
// CHECK:     %true = arith.constant true
// CHECK:     hls.dataflow.stream_read %arg0 : (!hls.stream<i1, 1>) -> ()
// CHECK:     %0 = affine.apply #map()
// CHECK:     %1 = affine.apply #map6()
// CHECK:     %2 = affine.apply #map2(%0)[%1]
// CHECK:     %3 = affine.apply #map6()
// CHECK:     %4 = affine.apply #map2(%2)[%3]
// CHECK:     %5 = affine.apply #map()
// CHECK:     %6 = affine.apply #map2(%4)[%5]
// CHECK:     %7 = affine.apply #map5()
// CHECK:     %8 = affine.apply #map2(%6)[%7]
// CHECK:     %9 = affine.apply #map5()
// CHECK:     %10 = affine.apply #map2(%8)[%9]
// CHECK:     affine.for %arg6 = 0 to %10 {
// CHECK:       %11 = affine.apply #map3(%arg6)[%9]
// CHECK:       %12 = affine.apply #map4(%arg6)[%9]
// CHECK:       %13 = affine.apply #map3(%12)[%7]
// CHECK:       %14 = affine.apply #map4(%12)[%7]
// CHECK:       %15 = affine.apply #map3(%14)[%5]
// CHECK:       %16 = affine.apply #map4(%14)[%5]
// CHECK:       %17 = affine.apply #map3(%16)[%3]
// CHECK:       %18 = affine.apply #map4(%16)[%3]
// CHECK:       %19 = affine.apply #map3(%18)[%1]
// CHECK:       %20 = affine.apply #map4(%18)[%1]
// CHECK:       %21 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:       %22 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, #hls.mem<bram_t2p>>
// CHECK:       %23 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:       func.call @forward_node27(%arg1, %23, %20, %19, %13, %17, %11) : (memref<64x56x56xi8, #hls.mem<dram>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>, index, index, index, index, index) -> ()
// CHECK:       func.call @forward_node26(%arg2, %22, %15, %20, %19, %17) : (memref<64x64x3x3xi8, #hls.mem<dram>>, memref<16x16xi8, #hls.mem<bram_t2p>>, index, index, index, index) -> ()
// CHECK:       func.call @forward_node25(%arg3, %21, %15, %13, %11) : (memref<64x28x28xi8, #hls.mem<dram>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>, index, index, index) -> ()
// CHECK:       %24 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:       func.call @forward_node24(%23, %22, %21, %24, %17, %20, %19) : (memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x16xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>, index, index, index) -> ()
// CHECK:       func.call @forward_node23(%24, %arg5, %15, %13, %11) : (memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<64x28x28xi8, #hls.mem<dram>>, index, index, index) -> ()
// CHECK:     } {loop_directive = #hls.loop<pipeline=false, targetII=1, dataflow=true, flatten=false>}
// CHECK:     hls.dataflow.stream_write %arg4, %true : <i1, 1>, i1
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node28(%arg0: !hls.stream<i1, 1>, %arg1: memref<64x56x56xi8, #hls.mem<dram>>, %arg2: !hls.stream<i1, 3>, %arg3: memref<64x56x56xi8, #hls.mem<dram>>, %arg4: !hls.stream<i1, 1>, %arg5: memref<64x56x56xi8, #hls.mem<dram>>) {
// CHECK:     %true = arith.constant true
// CHECK:     hls.dataflow.stream_read %arg0 : (!hls.stream<i1, 1>) -> ()
// CHECK:     affine.for %arg6 = 0 to 64 {
// CHECK:       affine.for %arg7 = 0 to 56 {
// CHECK:         affine.for %arg8 = 0 to 56 {
// CHECK:           %0 = affine.load %arg1[%arg6, %arg7, %arg8] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:           affine.store %0, %arg3[%arg6, %arg7, %arg8] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:         } {parallel}
// CHECK:       } {parallel}
// CHECK:     } {parallel}
// CHECK:     affine.for %arg6 = 0 to 64 {
// CHECK:       affine.for %arg7 = 0 to 56 {
// CHECK:         affine.for %arg8 = 0 to 56 {
// CHECK:           %0 = affine.load %arg1[%arg6, %arg7, %arg8] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:           affine.store %0, %arg5[%arg6, %arg7, %arg8] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:         } {parallel}
// CHECK:       } {parallel}
// CHECK:     } {parallel}
// CHECK:     hls.dataflow.stream_write %arg2, %true : <i1, 3>, i1
// CHECK:     hls.dataflow.stream_write %arg4, %true : <i1, 1>, i1
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node30(%arg0: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg1: memref<64x56x56xi8, #hls.mem<dram>>, %arg2: index, %arg3: index, %arg4: index) attributes {inline} {
// CHECK:     affine.for %arg5 = 0 to 16 {
// CHECK:       affine.for %arg6 = 0 to 14 {
// CHECK:         affine.for %arg7 = 0 to 14 {
// CHECK:           %0 = affine.load %arg0[%arg5, %arg6, %arg7] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:           affine.store %0, %arg1[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:         } {parallel}
// CHECK:       } {parallel}
// CHECK:     } {parallel}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node31(%arg0: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg1: memref<16x14x14xi8, #hls.mem<bram_t2p>>) attributes {inline} {
// CHECK:     %c-24_i8 = arith.constant -24 : i8
// CHECK:     affine.for %arg2 = 0 to 16 {
// CHECK:       affine.for %arg3 = 0 to 14 {
// CHECK:         affine.for %arg4 = 0 to 14 {
// CHECK:           %0 = affine.load %arg0[%arg2, %arg3, %arg4] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:           %1 = arith.cmpi ugt, %0, %c-24_i8 : i8
// CHECK:           %2 = arith.select %1, %0, %c-24_i8 : i8
// CHECK:           affine.store %2, %arg1[%arg2, %arg3, %arg4] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:         } {parallel, point}
// CHECK:       } {parallel, point}
// CHECK:     } {parallel, point}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node32(%arg0: memref<64x56x56xi8, #hls.mem<dram>>, %arg1: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg2: index, %arg3: index, %arg4: index) attributes {inline} {
// CHECK:     affine.for %arg5 = 0 to 16 {
// CHECK:       affine.for %arg6 = 0 to 14 {
// CHECK:         affine.for %arg7 = 0 to 14 {
// CHECK:           %0 = affine.load %arg0[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14] : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:           affine.store %0, %arg1[%arg5, %arg6, %arg7] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:         } {parallel}
// CHECK:       } {parallel}
// CHECK:     } {parallel}
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward_node29(%arg0: memref<64x56x56xi8, #hls.mem<dram>>, %arg1: !hls.stream<i1, 1>, %arg2: memref<64x56x56xi8, #hls.mem<dram>>) {
// CHECK:     %true = arith.constant true
// CHECK:     %0 = affine.apply #map()
// CHECK:     %1 = affine.apply #map()
// CHECK:     %2 = affine.apply #map2(%0)[%1]
// CHECK:     %3 = affine.apply #map()
// CHECK:     %4 = affine.apply #map2(%2)[%3]
// CHECK:     affine.for %arg3 = 0 to %4 {
// CHECK:       %5 = affine.apply #map3(%arg3)[%3]
// CHECK:       %6 = affine.apply #map4(%arg3)[%3]
// CHECK:       %7 = affine.apply #map3(%6)[%1]
// CHECK:       %8 = affine.apply #map4(%6)[%1]
// CHECK:       %9 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:       func.call @forward_node32(%arg0, %9, %8, %7, %5) : (memref<64x56x56xi8, #hls.mem<dram>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>, index, index, index) -> ()
// CHECK:       %10 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
// CHECK:       func.call @forward_node31(%9, %10) : (memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> ()
// CHECK:       func.call @forward_node30(%10, %arg2, %8, %7, %5) : (memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<64x56x56xi8, #hls.mem<dram>>, index, index, index) -> ()
// CHECK:     } {loop_directive = #hls.loop<pipeline=false, targetII=1, dataflow=true, flatten=false>, parallel}
// CHECK:     hls.dataflow.stream_write %arg1, %true : <i1, 1>, i1
// CHECK:     return
// CHECK:   }
// CHECK:   func.func @forward(%arg0: memref<64x56x56xi8, #hls.mem<dram>>, %arg1: memref<1000x64xi8, #hls.mem<dram>>, %arg2: memref<64x64xi8, #hls.mem<dram>>, %arg3: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg4: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg5: memref<1000xi8, #hls.mem<dram>>) attributes {func_directive = #hls.func<pipeline=false, targetInterval=1, dataflow=true>, top_func} {
// CHECK:     %0 = hls.dataflow.stream {depth = 1 : i32} : <i1, 1>
// CHECK:     call @forward_node29(%arg0, %0, %arg0) : (memref<64x56x56xi8, #hls.mem<dram>>, !hls.stream<i1, 1>, memref<64x56x56xi8, #hls.mem<dram>>) -> ()
// CHECK:     %1 = hls.dataflow.buffer {depth = 3 : i32} : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:     %2 = hls.dataflow.stream {depth = 3 : i32} : <i1, 3>
// CHECK:     %3 = hls.dataflow.buffer {depth = 1 : i32} : memref<64x56x56xi8, #hls.mem<dram>>
// CHECK:     %4 = hls.dataflow.stream {depth = 1 : i32} : <i1, 1>
// CHECK:     call @forward_node28(%0, %arg0, %2, %1, %4, %3) : (!hls.stream<i1, 1>, memref<64x56x56xi8, #hls.mem<dram>>, !hls.stream<i1, 3>, memref<64x56x56xi8, #hls.mem<dram>>, !hls.stream<i1, 1>, memref<64x56x56xi8, #hls.mem<dram>>) -> ()
// CHECK:     %5 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:     %6 = hls.dataflow.stream {depth = 1 : i32} : <i1, 1>
// CHECK:     call @forward_node22(%4, %3, %arg4, %5, %6, %5) : (!hls.stream<i1, 1>, memref<64x56x56xi8, #hls.mem<dram>>, memref<64x64x3x3xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>, !hls.stream<i1, 1>, memref<64x28x28xi8, #hls.mem<dram>>) -> ()
// CHECK:     %7 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:     %8 = hls.dataflow.stream {depth = 1 : i32} : <i1, 1>
// CHECK:     call @forward_node16(%arg3, %6, %5, %7, %8, %7) : (memref<64x64x3x3xi8, #hls.mem<dram>>, !hls.stream<i1, 1>, memref<64x28x28xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>, !hls.stream<i1, 1>, memref<64x28x28xi8, #hls.mem<dram>>) -> ()
// CHECK:     %9 = hls.dataflow.buffer {depth = 1 : i32} : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:     %10 = hls.dataflow.stream {depth = 1 : i32} : <i1, 1>
// CHECK:     %11 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, #hls.mem<dram>>
// CHECK:     call @forward_node8(%2, %1, %arg2, %8, %7, %11, %10, %9, %11) : (!hls.stream<i1, 3>, memref<64x56x56xi8, #hls.mem<dram>>, memref<64x64xi8, #hls.mem<dram>>, !hls.stream<i1, 1>, memref<64x28x28xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>, !hls.stream<i1, 1>, memref<64x28x28xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>) -> ()
// CHECK:     %12 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64xi8, #hls.mem<bram_t2p>>
// CHECK:     call @forward_node5(%10, %9, %12) : (!hls.stream<i1, 1>, memref<64x28x28xi8, #hls.mem<dram>>, memref<64xi8, #hls.mem<bram_t2p>>) -> ()
// CHECK:     call @forward_node0(%12, %arg1, %arg5, %arg5) : (memref<64xi8, #hls.mem<bram_t2p>>, memref<1000x64xi8, #hls.mem<dram>>, memref<1000xi8, #hls.mem<dram>>, memref<1000xi8, #hls.mem<dram>>) -> ()
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
      %0 = hls.dataflow.stream {depth = 1 : i32} : <i1, 1>
      hls.dataflow.node() -> (%0, %arg10) {inputTaps = [], level = 6 : i32} : () -> (!hls.stream<i1, 1>, memref<64x56x56xi8, #hls.mem<dram>>) {
      ^bb0(%arg12: !hls.stream<i1, 1>, %arg13: memref<64x56x56xi8, #hls.mem<dram>>):
        affine.for %arg14 = 0 to 4 {
          affine.for %arg15 = 0 to 4 {
            affine.for %arg16 = 0 to 4 {
              hls.dataflow.schedule legal(%arg14, %arg16, %arg13, %arg15) : index, index, memref<64x56x56xi8, #hls.mem<dram>>, index {
              ^bb0(%arg17: index, %arg18: index, %arg19: memref<64x56x56xi8, #hls.mem<dram>>, %arg20: index):
                %13 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                hls.dataflow.node(%arg19) -> (%13) [%arg17, %arg20, %arg18] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x56x56xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
                ^bb0(%arg21: memref<64x56x56xi8, #hls.mem<dram>>, %arg22: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg23: index, %arg24: index, %arg25: index):
                  affine.for %arg26 = 0 to 16 {
                    affine.for %arg27 = 0 to 14 {
                      affine.for %arg28 = 0 to 14 {
                        %15 = affine.load %arg21[%arg26 + symbol(%arg23) * 16, %arg27 + symbol(%arg24) * 14, %arg28 + symbol(%arg25) * 14] : memref<64x56x56xi8, #hls.mem<dram>>
                        affine.store %15, %arg22[%arg26, %arg27, %arg28] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                      } {parallel}
                    } {parallel}
                  } {parallel}
                }
                %14 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                hls.dataflow.node(%13) -> (%14) {inputTaps = [0 : i32], level = 1 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>> {
                ^bb0(%arg21: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg22: memref<16x14x14xi8, #hls.mem<bram_t2p>>):
                  %c-24_i8 = arith.constant -24 : i8
                  affine.for %arg23 = 0 to 16 {
                    affine.for %arg24 = 0 to 14 {
                      affine.for %arg25 = 0 to 14 {
                        %15 = affine.load %arg21[%arg23, %arg24, %arg25] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                        %16 = arith.cmpi ugt, %15, %c-24_i8 : i8
                        %17 = arith.select %16, %15, %c-24_i8 : i8
                        affine.store %17, %arg22[%arg23, %arg24, %arg25] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                      } {parallel, point}
                    } {parallel, point}
                  } {parallel, point}
                }
                hls.dataflow.node(%14) -> (%arg19) [%arg17, %arg20, %arg18] {inputTaps = [0 : i32], level = 0 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<64x56x56xi8, #hls.mem<dram>>[index, index, index] {
                ^bb0(%arg21: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg22: memref<64x56x56xi8, #hls.mem<dram>>, %arg23: index, %arg24: index, %arg25: index):
                  affine.for %arg26 = 0 to 16 {
                    affine.for %arg27 = 0 to 14 {
                      affine.for %arg28 = 0 to 14 {
                        %15 = affine.load %arg21[%arg26, %arg27, %arg28] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                        affine.store %15, %arg22[%arg26 + symbol(%arg23) * 16, %arg27 + symbol(%arg24) * 14, %arg28 + symbol(%arg25) * 14] : memref<64x56x56xi8, #hls.mem<dram>>
                      } {parallel}
                    } {parallel}
                  } {parallel}
                }
              }
            } {parallel}
          } {parallel}
        } {parallel}
        %true = arith.constant true
        hls.dataflow.stream_write %arg12, %true : <i1, 1>, i1
      }
      %1 = hls.dataflow.buffer {depth = 3 : i32} : memref<64x56x56xi8, #hls.mem<dram>>
      %2 = hls.dataflow.stream {depth = 3 : i32} : <i1, 3>
      %3 = hls.dataflow.buffer {depth = 1 : i32} : memref<64x56x56xi8, #hls.mem<dram>>
      %4 = hls.dataflow.stream {depth = 1 : i32} : <i1, 1>
      hls.dataflow.node(%0, %arg10) -> (%2, %1, %4, %3) {inputTaps = [0 : i32, 0 : i32], level = 5 : i32} : (!hls.stream<i1, 1>, memref<64x56x56xi8, #hls.mem<dram>>) -> (!hls.stream<i1, 3>, memref<64x56x56xi8, #hls.mem<dram>>, !hls.stream<i1, 1>, memref<64x56x56xi8, #hls.mem<dram>>) {
      ^bb0(%arg12: !hls.stream<i1, 1>, %arg13: memref<64x56x56xi8, #hls.mem<dram>>, %arg14: !hls.stream<i1, 3>, %arg15: memref<64x56x56xi8, #hls.mem<dram>>, %arg16: !hls.stream<i1, 1>, %arg17: memref<64x56x56xi8, #hls.mem<dram>>):
        hls.dataflow.stream_read %arg12 : (!hls.stream<i1, 1>) -> ()
        affine.for %arg18 = 0 to 64 {
          affine.for %arg19 = 0 to 56 {
            affine.for %arg20 = 0 to 56 {
              %13 = affine.load %arg13[%arg18, %arg19, %arg20] : memref<64x56x56xi8, #hls.mem<dram>>
              affine.store %13, %arg15[%arg18, %arg19, %arg20] : memref<64x56x56xi8, #hls.mem<dram>>
            } {parallel}
          } {parallel}
        } {parallel}
        affine.for %arg18 = 0 to 64 {
          affine.for %arg19 = 0 to 56 {
            affine.for %arg20 = 0 to 56 {
              %13 = affine.load %arg13[%arg18, %arg19, %arg20] : memref<64x56x56xi8, #hls.mem<dram>>
              affine.store %13, %arg17[%arg18, %arg19, %arg20] : memref<64x56x56xi8, #hls.mem<dram>>
            } {parallel}
          } {parallel}
        } {parallel}
        %true = arith.constant true
        hls.dataflow.stream_write %arg14, %true : <i1, 3>, i1
        %true_0 = arith.constant true
        hls.dataflow.stream_write %arg16, %true_0 : <i1, 1>, i1
      }
      %5 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, #hls.mem<dram>>
      %6 = hls.dataflow.stream {depth = 1 : i32} : <i1, 1>
      hls.dataflow.node(%4, %3, %arg11) -> (%6, %5) {inputTaps = [0 : i32, 0 : i32, 0 : i32], level = 4 : i32} : (!hls.stream<i1, 1>, memref<64x56x56xi8, #hls.mem<dram>>, memref<64x64x3x3xi8, #hls.mem<dram>>) -> (!hls.stream<i1, 1>, memref<64x28x28xi8, #hls.mem<dram>>) {
      ^bb0(%arg12: !hls.stream<i1, 1>, %arg13: memref<64x56x56xi8, #hls.mem<dram>>, %arg14: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg15: !hls.stream<i1, 1>, %arg16: memref<64x28x28xi8, #hls.mem<dram>>):
        hls.dataflow.stream_read %arg12 : (!hls.stream<i1, 1>) -> ()
        affine.for %arg17 = 0 to 4 {
          affine.for %arg18 = 0 to 3 {
            affine.for %arg19 = 0 to 3 {
              affine.for %arg20 = 0 to 4 {
                affine.for %arg21 = 0 to 2 {
                  affine.for %arg22 = 0 to 2 {
                    hls.dataflow.schedule legal(%arg19, %arg16, %arg22, %arg18, %arg21, %arg13, %arg17, %arg14, %arg20) : index, memref<64x28x28xi8, #hls.mem<dram>>, index, index, index, memref<64x56x56xi8, #hls.mem<dram>>, index, memref<64x64x3x3xi8, #hls.mem<dram>>, index {
                    ^bb0(%arg23: index, %arg24: memref<64x28x28xi8, #hls.mem<dram>>, %arg25: index, %arg26: index, %arg27: index, %arg28: memref<64x56x56xi8, #hls.mem<dram>>, %arg29: index, %arg30: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg31: index):
                      %13 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                      %14 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, #hls.mem<bram_t2p>>
                      %15 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                      hls.dataflow.node(%arg28) -> (%15) [%arg29, %arg26, %arg27, %arg23, %arg25] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x56x56xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index, index, index] {
                      ^bb0(%arg32: memref<64x56x56xi8, #hls.mem<dram>>, %arg33: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg34: index, %arg35: index, %arg36: index, %arg37: index, %arg38: index):
                        affine.for %arg39 = 0 to 16 {
                          affine.for %arg40 = 0 to 14 step 2 {
                            affine.for %arg41 = 0 to 14 step 2 {
                              %17 = affine.load %arg32[%arg39 + symbol(%arg34) * 16, %arg40 * 2 + symbol(%arg35) + symbol(%arg36) * 28 - 1, %arg41 * 2 + symbol(%arg37) + symbol(%arg38) * 28 - 1] : memref<64x56x56xi8, #hls.mem<dram>>
                              affine.store %17, %arg33[%arg39, %arg40, %arg41] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              %18 = affine.load %arg32[%arg39 + symbol(%arg34) * 16, %arg40 * 2 + symbol(%arg35) + symbol(%arg36) * 28 - 1, %arg41 * 2 + symbol(%arg37) + symbol(%arg38) * 28 + 1] : memref<64x56x56xi8, #hls.mem<dram>>
                              affine.store %18, %arg33[%arg39, %arg40, %arg41 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              %19 = affine.load %arg32[%arg39 + symbol(%arg34) * 16, %arg40 * 2 + symbol(%arg35) + symbol(%arg36) * 28 + 1, %arg41 * 2 + symbol(%arg37) + symbol(%arg38) * 28 - 1] : memref<64x56x56xi8, #hls.mem<dram>>
                              affine.store %19, %arg33[%arg39, %arg40 + 1, %arg41] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              %20 = affine.load %arg32[%arg39 + symbol(%arg34) * 16, %arg40 * 2 + symbol(%arg35) + symbol(%arg36) * 28 + 1, %arg41 * 2 + symbol(%arg37) + symbol(%arg38) * 28 + 1] : memref<64x56x56xi8, #hls.mem<dram>>
                              affine.store %20, %arg33[%arg39, %arg40 + 1, %arg41 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                            } {parallel}
                          } {parallel}
                        } {parallel}
                      }
                      hls.dataflow.node(%arg30) -> (%14) [%arg31, %arg29, %arg26, %arg23] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x64x3x3xi8, #hls.mem<dram>>) -> memref<16x16xi8, #hls.mem<bram_t2p>>[index, index, index, index] {
                      ^bb0(%arg32: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg33: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg34: index, %arg35: index, %arg36: index, %arg37: index):
                        affine.for %arg38 = 0 to 16 {
                          affine.for %arg39 = 0 to 16 {
                            %17 = affine.load %arg32[%arg38 + symbol(%arg34) * 16, %arg39 + symbol(%arg35) * 16, symbol(%arg36), symbol(%arg37)] : memref<64x64x3x3xi8, #hls.mem<dram>>
                            affine.store %17, %arg33[%arg38, %arg39] : memref<16x16xi8, #hls.mem<bram_t2p>>
                          } {parallel}
                        } {parallel}
                      }
                      hls.dataflow.node(%arg24) -> (%13) [%arg31, %arg27, %arg25] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
                      ^bb0(%arg32: memref<64x28x28xi8, #hls.mem<dram>>, %arg33: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg34: index, %arg35: index, %arg36: index):
                        affine.for %arg37 = 0 to 16 {
                          affine.for %arg38 = 0 to 14 step 2 {
                            affine.for %arg39 = 0 to 14 step 2 {
                              %17 = affine.load %arg32[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14, %arg39 + symbol(%arg36) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                              affine.store %17, %arg33[%arg37, %arg38, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              %18 = affine.load %arg32[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14, %arg39 + symbol(%arg36) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
                              affine.store %18, %arg33[%arg37, %arg38, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              %19 = affine.load %arg32[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14 + 1, %arg39 + symbol(%arg36) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                              affine.store %19, %arg33[%arg37, %arg38 + 1, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              %20 = affine.load %arg32[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14 + 1, %arg39 + symbol(%arg36) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
                              affine.store %20, %arg33[%arg37, %arg38 + 1, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                            } {parallel}
                          } {parallel}
                        } {parallel}
                      }
                      %16 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                      hls.dataflow.node(%15, %14, %13) -> (%16) [%arg23, %arg29, %arg26] {inputTaps = [0 : i32, 0 : i32, 0 : i32], level = 1 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x16xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
                      ^bb0(%arg32: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg33: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg34: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg35: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg36: index, %arg37: index, %arg38: index):
                        %c-24_i8 = arith.constant -24 : i8
                        affine.for %arg39 = 0 to 16 {
                          affine.for %arg40 = 0 to 16 {
                            affine.for %arg41 = 0 to 14 step 2 {
                              affine.for %arg42 = 0 to 14 step 2 {
                                %17 = affine.load %arg32[%arg39, %arg41, %arg42] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %18 = affine.load %arg33[%arg40, %arg39] : memref<16x16xi8, #hls.mem<bram_t2p>>
                                %19 = affine.load %arg34[%arg40, %arg41, %arg42] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %20 = affine.load %arg35[%arg40, %arg41, %arg42] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %21 = hls.affine.select #set(%arg39) %19, %20 : i8
                                %22 = arith.muli %17, %18 : i8
                                %23 = arith.addi %21, %22 : i8
                                %24 = arith.cmpi ugt, %23, %c-24_i8 : i8
                                %25 = arith.select %24, %23, %c-24_i8 : i8
                                %26 = hls.affine.select #set1(%arg38, %arg36, %arg39, %arg37) %25, %23 : i8
                                affine.store %26, %arg35[%arg40, %arg41, %arg42] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %27 = affine.load %arg32[%arg39, %arg41, %arg42 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %28 = affine.load %arg34[%arg40, %arg41, %arg42 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %29 = affine.load %arg35[%arg40, %arg41, %arg42 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %30 = hls.affine.select #set(%arg39) %28, %29 : i8
                                %31 = arith.muli %27, %18 : i8
                                %32 = arith.addi %30, %31 : i8
                                %33 = arith.cmpi ugt, %32, %c-24_i8 : i8
                                %34 = arith.select %33, %32, %c-24_i8 : i8
                                %35 = hls.affine.select #set1(%arg38, %arg36, %arg39, %arg37) %34, %32 : i8
                                affine.store %35, %arg35[%arg40, %arg41, %arg42 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %36 = affine.load %arg32[%arg39, %arg41 + 1, %arg42] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %37 = affine.load %arg34[%arg40, %arg41 + 1, %arg42] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %38 = affine.load %arg35[%arg40, %arg41 + 1, %arg42] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %39 = hls.affine.select #set(%arg39) %37, %38 : i8
                                %40 = arith.muli %36, %18 : i8
                                %41 = arith.addi %39, %40 : i8
                                %42 = arith.cmpi ugt, %41, %c-24_i8 : i8
                                %43 = arith.select %42, %41, %c-24_i8 : i8
                                %44 = hls.affine.select #set1(%arg38, %arg36, %arg39, %arg37) %43, %41 : i8
                                affine.store %44, %arg35[%arg40, %arg41 + 1, %arg42] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %45 = affine.load %arg32[%arg39, %arg41 + 1, %arg42 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %46 = affine.load %arg34[%arg40, %arg41 + 1, %arg42 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %47 = affine.load %arg35[%arg40, %arg41 + 1, %arg42 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %48 = hls.affine.select #set(%arg39) %46, %47 : i8
                                %49 = arith.muli %45, %18 : i8
                                %50 = arith.addi %48, %49 : i8
                                %51 = arith.cmpi ugt, %50, %c-24_i8 : i8
                                %52 = arith.select %51, %50, %c-24_i8 : i8
                                %53 = hls.affine.select #set1(%arg38, %arg36, %arg39, %arg37) %52, %50 : i8
                                affine.store %53, %arg35[%arg40, %arg41 + 1, %arg42 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              } {parallel, point}
                            } {parallel, point}
                          } {parallel, point}
                        } {point}
                      }
                      hls.dataflow.node(%16) -> (%arg24) [%arg31, %arg27, %arg25] {inputTaps = [0 : i32], level = 0 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<64x28x28xi8, #hls.mem<dram>>[index, index, index] {
                      ^bb0(%arg32: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg33: memref<64x28x28xi8, #hls.mem<dram>>, %arg34: index, %arg35: index, %arg36: index):
                        affine.for %arg37 = 0 to 16 {
                          affine.for %arg38 = 0 to 14 step 2 {
                            affine.for %arg39 = 0 to 14 step 2 {
                              %17 = affine.load %arg32[%arg37, %arg38, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              affine.store %17, %arg33[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14, %arg39 + symbol(%arg36) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                              %18 = affine.load %arg32[%arg37, %arg38, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              affine.store %18, %arg33[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14, %arg39 + symbol(%arg36) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
                              %19 = affine.load %arg32[%arg37, %arg38 + 1, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              affine.store %19, %arg33[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14 + 1, %arg39 + symbol(%arg36) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                              %20 = affine.load %arg32[%arg37, %arg38 + 1, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              affine.store %20, %arg33[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14 + 1, %arg39 + symbol(%arg36) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
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
        %true = arith.constant true
        hls.dataflow.stream_write %arg15, %true : <i1, 1>, i1
      }
      %7 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, #hls.mem<dram>>
      %8 = hls.dataflow.stream {depth = 1 : i32} : <i1, 1>
      hls.dataflow.node(%arg8, %6, %5) -> (%8, %7) {inputTaps = [0 : i32, 0 : i32, 0 : i32], level = 3 : i32} : (memref<64x64x3x3xi8, #hls.mem<dram>>, !hls.stream<i1, 1>, memref<64x28x28xi8, #hls.mem<dram>>) -> (!hls.stream<i1, 1>, memref<64x28x28xi8, #hls.mem<dram>>) {
      ^bb0(%arg12: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg13: !hls.stream<i1, 1>, %arg14: memref<64x28x28xi8, #hls.mem<dram>>, %arg15: !hls.stream<i1, 1>, %arg16: memref<64x28x28xi8, #hls.mem<dram>>):
        hls.dataflow.stream_read %arg13 : (!hls.stream<i1, 1>) -> ()
        affine.for %arg17 = 0 to 4 {
          affine.for %arg18 = 0 to 3 {
            affine.for %arg19 = 0 to 3 {
              affine.for %arg20 = 0 to 4 {
                affine.for %arg21 = 0 to 2 {
                  affine.for %arg22 = 0 to 2 {
                    hls.dataflow.schedule legal(%arg22, %arg18, %arg17, %arg19, %arg21, %arg16, %arg12, %arg14, %arg20) : index, index, index, index, index, memref<64x28x28xi8, #hls.mem<dram>>, memref<64x64x3x3xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>, index {
                    ^bb0(%arg23: index, %arg24: index, %arg25: index, %arg26: index, %arg27: index, %arg28: memref<64x28x28xi8, #hls.mem<dram>>, %arg29: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg30: memref<64x28x28xi8, #hls.mem<dram>>, %arg31: index):
                      %13 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                      %14 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, #hls.mem<bram_t2p>>
                      %15 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                      hls.dataflow.node(%arg30) -> (%15) [%arg25, %arg24, %arg27, %arg26, %arg23] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index, index, index] {
                      ^bb0(%arg32: memref<64x28x28xi8, #hls.mem<dram>>, %arg33: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg34: index, %arg35: index, %arg36: index, %arg37: index, %arg38: index):
                        affine.for %arg39 = 0 to 16 {
                          affine.for %arg40 = 0 to 14 step 2 {
                            affine.for %arg41 = 0 to 14 step 2 {
                              %17 = affine.load %arg32[%arg39 + symbol(%arg34) * 16, %arg40 + symbol(%arg35) + symbol(%arg36) * 14 - 1, %arg41 + symbol(%arg37) + symbol(%arg38) * 14 - 1] : memref<64x28x28xi8, #hls.mem<dram>>
                              affine.store %17, %arg33[%arg39, %arg40, %arg41] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              %18 = affine.load %arg32[%arg39 + symbol(%arg34) * 16, %arg40 + symbol(%arg35) + symbol(%arg36) * 14 - 1, %arg41 + symbol(%arg37) + symbol(%arg38) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                              affine.store %18, %arg33[%arg39, %arg40, %arg41 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              %19 = affine.load %arg32[%arg39 + symbol(%arg34) * 16, %arg40 + symbol(%arg35) + symbol(%arg36) * 14, %arg41 + symbol(%arg37) + symbol(%arg38) * 14 - 1] : memref<64x28x28xi8, #hls.mem<dram>>
                              affine.store %19, %arg33[%arg39, %arg40 + 1, %arg41] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              %20 = affine.load %arg32[%arg39 + symbol(%arg34) * 16, %arg40 + symbol(%arg35) + symbol(%arg36) * 14, %arg41 + symbol(%arg37) + symbol(%arg38) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                              affine.store %20, %arg33[%arg39, %arg40 + 1, %arg41 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                            } {parallel}
                          } {parallel}
                        } {parallel}
                      }
                      hls.dataflow.node(%arg29) -> (%14) [%arg31, %arg25, %arg24, %arg26] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x64x3x3xi8, #hls.mem<dram>>) -> memref<16x16xi8, #hls.mem<bram_t2p>>[index, index, index, index] {
                      ^bb0(%arg32: memref<64x64x3x3xi8, #hls.mem<dram>>, %arg33: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg34: index, %arg35: index, %arg36: index, %arg37: index):
                        affine.for %arg38 = 0 to 16 {
                          affine.for %arg39 = 0 to 16 {
                            %17 = affine.load %arg32[%arg38 + symbol(%arg34) * 16, %arg39 + symbol(%arg35) * 16, symbol(%arg36), symbol(%arg37)] : memref<64x64x3x3xi8, #hls.mem<dram>>
                            affine.store %17, %arg33[%arg38, %arg39] : memref<16x16xi8, #hls.mem<bram_t2p>>
                          } {parallel}
                        } {parallel}
                      }
                      hls.dataflow.node(%arg28) -> (%13) [%arg31, %arg27, %arg23] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
                      ^bb0(%arg32: memref<64x28x28xi8, #hls.mem<dram>>, %arg33: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg34: index, %arg35: index, %arg36: index):
                        affine.for %arg37 = 0 to 16 {
                          affine.for %arg38 = 0 to 14 step 2 {
                            affine.for %arg39 = 0 to 14 step 2 {
                              %17 = affine.load %arg32[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14, %arg39 + symbol(%arg36) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                              affine.store %17, %arg33[%arg37, %arg38, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              %18 = affine.load %arg32[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14, %arg39 + symbol(%arg36) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
                              affine.store %18, %arg33[%arg37, %arg38, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              %19 = affine.load %arg32[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14 + 1, %arg39 + symbol(%arg36) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                              affine.store %19, %arg33[%arg37, %arg38 + 1, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              %20 = affine.load %arg32[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14 + 1, %arg39 + symbol(%arg36) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
                              affine.store %20, %arg33[%arg37, %arg38 + 1, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                            } {parallel}
                          } {parallel}
                        } {parallel}
                      }
                      %16 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                      hls.dataflow.node(%15, %14, %13) -> (%16) {inputTaps = [0 : i32, 0 : i32, 0 : i32], level = 1 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x16xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>> {
                      ^bb0(%arg32: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg33: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg34: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg35: memref<16x14x14xi8, #hls.mem<bram_t2p>>):
                        affine.for %arg36 = 0 to 16 {
                          affine.for %arg37 = 0 to 16 {
                            affine.for %arg38 = 0 to 14 step 2 {
                              affine.for %arg39 = 0 to 14 step 2 {
                                %17 = affine.load %arg32[%arg36, %arg38, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %18 = affine.load %arg33[%arg37, %arg36] : memref<16x16xi8, #hls.mem<bram_t2p>>
                                %19 = affine.load %arg34[%arg37, %arg38, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %20 = affine.load %arg35[%arg37, %arg38, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %21 = hls.affine.select #set(%arg36) %19, %20 : i8
                                %22 = arith.muli %17, %18 : i8
                                %23 = arith.addi %21, %22 : i8
                                affine.store %23, %arg35[%arg37, %arg38, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %24 = affine.load %arg32[%arg36, %arg38, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %25 = affine.load %arg34[%arg37, %arg38, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %26 = affine.load %arg35[%arg37, %arg38, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %27 = hls.affine.select #set(%arg36) %25, %26 : i8
                                %28 = arith.muli %24, %18 : i8
                                %29 = arith.addi %27, %28 : i8
                                affine.store %29, %arg35[%arg37, %arg38, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %30 = affine.load %arg32[%arg36, %arg38 + 1, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %31 = affine.load %arg34[%arg37, %arg38 + 1, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %32 = affine.load %arg35[%arg37, %arg38 + 1, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %33 = hls.affine.select #set(%arg36) %31, %32 : i8
                                %34 = arith.muli %30, %18 : i8
                                %35 = arith.addi %33, %34 : i8
                                affine.store %35, %arg35[%arg37, %arg38 + 1, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %36 = affine.load %arg32[%arg36, %arg38 + 1, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %37 = affine.load %arg34[%arg37, %arg38 + 1, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %38 = affine.load %arg35[%arg37, %arg38 + 1, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                                %39 = hls.affine.select #set(%arg36) %37, %38 : i8
                                %40 = arith.muli %36, %18 : i8
                                %41 = arith.addi %39, %40 : i8
                                affine.store %41, %arg35[%arg37, %arg38 + 1, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              } {parallel, point}
                            } {parallel, point}
                          } {parallel, point}
                        } {point}
                      }
                      hls.dataflow.node(%16) -> (%arg28) [%arg31, %arg27, %arg23] {inputTaps = [0 : i32], level = 0 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<64x28x28xi8, #hls.mem<dram>>[index, index, index] {
                      ^bb0(%arg32: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg33: memref<64x28x28xi8, #hls.mem<dram>>, %arg34: index, %arg35: index, %arg36: index):
                        affine.for %arg37 = 0 to 16 {
                          affine.for %arg38 = 0 to 14 step 2 {
                            affine.for %arg39 = 0 to 14 step 2 {
                              %17 = affine.load %arg32[%arg37, %arg38, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              affine.store %17, %arg33[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14, %arg39 + symbol(%arg36) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                              %18 = affine.load %arg32[%arg37, %arg38, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              affine.store %18, %arg33[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14, %arg39 + symbol(%arg36) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
                              %19 = affine.load %arg32[%arg37, %arg38 + 1, %arg39] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              affine.store %19, %arg33[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14 + 1, %arg39 + symbol(%arg36) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                              %20 = affine.load %arg32[%arg37, %arg38 + 1, %arg39 + 1] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                              affine.store %20, %arg33[%arg37 + symbol(%arg34) * 16, %arg38 + symbol(%arg35) * 14 + 1, %arg39 + symbol(%arg36) * 14 + 1] : memref<64x28x28xi8, #hls.mem<dram>>
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
        %true = arith.constant true
        hls.dataflow.stream_write %arg15, %true : <i1, 1>, i1
      }
      %9 = hls.dataflow.buffer {depth = 1 : i32} : memref<64x28x28xi8, #hls.mem<dram>>
      %10 = hls.dataflow.stream {depth = 1 : i32} : <i1, 1>
      %11 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, #hls.mem<dram>>
      hls.dataflow.node(%2, %1, %arg6, %8, %7) -> (%10, %9, %11) {inputTaps = [2 : i32, 2 : i32, 0 : i32, 0 : i32, 0 : i32], level = 2 : i32} : (!hls.stream<i1, 3>, memref<64x56x56xi8, #hls.mem<dram>>, memref<64x64xi8, #hls.mem<dram>>, !hls.stream<i1, 1>, memref<64x28x28xi8, #hls.mem<dram>>) -> (!hls.stream<i1, 1>, memref<64x28x28xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>) {
      ^bb0(%arg12: !hls.stream<i1, 3>, %arg13: memref<64x56x56xi8, #hls.mem<dram>>, %arg14: memref<64x64xi8, #hls.mem<dram>>, %arg15: !hls.stream<i1, 1>, %arg16: memref<64x28x28xi8, #hls.mem<dram>>, %arg17: !hls.stream<i1, 1>, %arg18: memref<64x28x28xi8, #hls.mem<dram>>, %arg19: memref<64x28x28xi8, #hls.mem<dram>>):
        hls.dataflow.stream_read %arg15 : (!hls.stream<i1, 1>) -> ()
        hls.dataflow.stream_read %arg12 : (!hls.stream<i1, 3>) -> ()
        affine.for %arg20 = 0 to 4 {
          affine.for %arg21 = 0 to 4 {
            affine.for %arg22 = 0 to 2 {
              affine.for %arg23 = 0 to 2 {
                hls.dataflow.schedule legal(%arg22, %arg23, %arg14, %arg16, %arg13, %arg20, %arg18, %arg19, %arg21) : index, index, memref<64x64xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>, memref<64x56x56xi8, #hls.mem<dram>>, index, memref<64x28x28xi8, #hls.mem<dram>>, memref<64x28x28xi8, #hls.mem<dram>>, index {
                ^bb0(%arg24: index, %arg25: index, %arg26: memref<64x64xi8, #hls.mem<dram>>, %arg27: memref<64x28x28xi8, #hls.mem<dram>>, %arg28: memref<64x56x56xi8, #hls.mem<dram>>, %arg29: index, %arg30: memref<64x28x28xi8, #hls.mem<dram>>, %arg31: memref<64x28x28xi8, #hls.mem<dram>>, %arg32: index):
                  %13 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                  %14 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                  %15 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                  %16 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, #hls.mem<bram_t2p>>
                  %17 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                  hls.dataflow.node(%arg28) -> (%17) [%arg29, %arg24, %arg25] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x56x56xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
                  ^bb0(%arg33: memref<64x56x56xi8, #hls.mem<dram>>, %arg34: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg35: index, %arg36: index, %arg37: index):
                    affine.for %arg38 = 0 to 16 {
                      affine.for %arg39 = 0 to 14 {
                        affine.for %arg40 = 0 to 14 {
                          %19 = affine.load %arg33[%arg38 + symbol(%arg35) * 16, %arg39 * 2 + symbol(%arg36) * 28, %arg40 * 2 + symbol(%arg37) * 28] : memref<64x56x56xi8, #hls.mem<dram>>
                          affine.store %19, %arg34[%arg38, %arg39, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                        } {parallel}
                      } {parallel}
                    } {parallel}
                  }
                  hls.dataflow.node(%arg26) -> (%16) [%arg32, %arg29] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x64xi8, #hls.mem<dram>>) -> memref<16x16xi8, #hls.mem<bram_t2p>>[index, index] {
                  ^bb0(%arg33: memref<64x64xi8, #hls.mem<dram>>, %arg34: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg35: index, %arg36: index):
                    affine.for %arg37 = 0 to 16 {
                      affine.for %arg38 = 0 to 16 {
                        %19 = affine.load %arg33[%arg37 + symbol(%arg35) * 16, %arg38 + symbol(%arg36) * 16] : memref<64x64xi8, #hls.mem<dram>>
                        affine.store %19, %arg34[%arg37, %arg38] : memref<16x16xi8, #hls.mem<bram_t2p>>
                      } {parallel}
                    } {parallel}
                  }
                  hls.dataflow.node(%arg31) -> (%15) [%arg32, %arg24, %arg25] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
                  ^bb0(%arg33: memref<64x28x28xi8, #hls.mem<dram>>, %arg34: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg35: index, %arg36: index, %arg37: index):
                    affine.for %arg38 = 0 to 16 {
                      affine.for %arg39 = 0 to 14 {
                        affine.for %arg40 = 0 to 14 {
                          %19 = affine.load %arg33[%arg38 + symbol(%arg35) * 16, %arg39 + symbol(%arg36) * 14, %arg40 + symbol(%arg37) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                          affine.store %19, %arg34[%arg38, %arg39, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                        } {parallel}
                      } {parallel}
                    } {parallel}
                  }
                  hls.dataflow.node(%arg27) -> (%14) [%arg32, %arg24, %arg25] {inputTaps = [0 : i32], level = 2 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
                  ^bb0(%arg33: memref<64x28x28xi8, #hls.mem<dram>>, %arg34: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg35: index, %arg36: index, %arg37: index):
                    affine.for %arg38 = 0 to 16 {
                      affine.for %arg39 = 0 to 14 {
                        affine.for %arg40 = 0 to 14 {
                          %19 = affine.load %arg33[%arg38 + symbol(%arg35) * 16, %arg39 + symbol(%arg36) * 14, %arg40 + symbol(%arg37) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                          affine.store %19, %arg34[%arg38, %arg39, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                        } {parallel}
                      } {parallel}
                    } {parallel}
                  }
                  %18 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                  hls.dataflow.node(%14, %17, %16, %15) -> (%13, %18) [%arg29] {inputTaps = [0 : i32, 0 : i32, 0 : i32, 0 : i32], level = 1 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x16xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> (memref<16x14x14xi8, #hls.mem<bram_t2p>>, memref<16x14x14xi8, #hls.mem<bram_t2p>>)[index] {
                  ^bb0(%arg33: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg34: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg35: memref<16x16xi8, #hls.mem<bram_t2p>>, %arg36: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg37: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg38: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg39: index):
                    %c-24_i8 = arith.constant -24 : i8
                    affine.for %arg40 = 0 to 16 {
                      affine.for %arg41 = 0 to 16 {
                        affine.for %arg42 = 0 to 14 {
                          affine.for %arg43 = 0 to 14 {
                            %19 = affine.load %arg34[%arg40, %arg42, %arg43] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                            %20 = affine.load %arg35[%arg41, %arg40] : memref<16x16xi8, #hls.mem<bram_t2p>>
                            %21 = affine.load %arg36[%arg41, %arg42, %arg43] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                            %22 = affine.load %arg38[%arg41, %arg42, %arg43] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                            %23 = hls.affine.select #set(%arg40) %21, %22 : i8
                            %24 = arith.muli %19, %20 : i8
                            %25 = arith.addi %23, %24 : i8
                            affine.store %25, %arg38[%arg41, %arg42, %arg43] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                            %26 = affine.load %arg33[%arg41, %arg42, %arg43] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                            %27 = arith.addi %26, %25 : i8
                            %28 = arith.cmpi ugt, %27, %c-24_i8 : i8
                            %29 = arith.select %28, %27, %c-24_i8 : i8
                            affine.if #set2(%arg40)[%arg39] {
                              affine.store %29, %arg37[%arg41, %arg42, %arg43] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                            }
                          } {parallel, point}
                        } {parallel, point}
                      } {parallel, point}
                    } {point}
                  }
                  hls.dataflow.node(%18) -> (%arg31) [%arg32, %arg24, %arg25] {inputTaps = [0 : i32], level = 0 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<64x28x28xi8, #hls.mem<dram>>[index, index, index] {
                  ^bb0(%arg33: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg34: memref<64x28x28xi8, #hls.mem<dram>>, %arg35: index, %arg36: index, %arg37: index):
                    affine.for %arg38 = 0 to 16 {
                      affine.for %arg39 = 0 to 14 {
                        affine.for %arg40 = 0 to 14 {
                          %19 = affine.load %arg33[%arg38, %arg39, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                          affine.store %19, %arg34[%arg38 + symbol(%arg35) * 16, %arg39 + symbol(%arg36) * 14, %arg40 + symbol(%arg37) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                        } {parallel}
                      } {parallel}
                    } {parallel}
                  }
                  hls.dataflow.node(%13) -> (%arg30) [%arg32, %arg24, %arg25] {inputTaps = [0 : i32], level = 0 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<64x28x28xi8, #hls.mem<dram>>[index, index, index] {
                  ^bb0(%arg33: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg34: memref<64x28x28xi8, #hls.mem<dram>>, %arg35: index, %arg36: index, %arg37: index):
                    affine.for %arg38 = 0 to 16 {
                      affine.for %arg39 = 0 to 14 {
                        affine.for %arg40 = 0 to 14 {
                          %19 = affine.load %arg33[%arg38, %arg39, %arg40] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                          affine.store %19, %arg34[%arg38 + symbol(%arg35) * 16, %arg39 + symbol(%arg36) * 14, %arg40 + symbol(%arg37) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                        } {parallel}
                      } {parallel}
                    } {parallel}
                  }
                }
              } {parallel}
            } {parallel}
          } {parallel}
        }
        %true = arith.constant true
        hls.dataflow.stream_write %arg17, %true : <i1, 1>, i1
      }
      %12 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64xi8, #hls.mem<bram_t2p>>
      hls.dataflow.node(%10, %9) -> (%12) {inputTaps = [0 : i32, 0 : i32], level = 1 : i32} : (!hls.stream<i1, 1>, memref<64x28x28xi8, #hls.mem<dram>>) -> memref<64xi8, #hls.mem<bram_t2p>> {
      ^bb0(%arg12: !hls.stream<i1, 1>, %arg13: memref<64x28x28xi8, #hls.mem<dram>>, %arg14: memref<64xi8, #hls.mem<bram_t2p>>):
        hls.dataflow.stream_read %arg12 : (!hls.stream<i1, 1>) -> ()
        affine.for %arg15 = 0 to 2 {
          affine.for %arg16 = 0 to 2 {
            affine.for %arg17 = 0 to 4 {
              hls.dataflow.schedule legal(%arg13, %arg15, %arg14, %arg16, %arg17) : memref<64x28x28xi8, #hls.mem<dram>>, index, memref<64xi8, #hls.mem<bram_t2p>>, index, index {
              ^bb0(%arg18: memref<64x28x28xi8, #hls.mem<dram>>, %arg19: index, %arg20: memref<64xi8, #hls.mem<bram_t2p>>, %arg21: index, %arg22: index):
                %13 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                hls.dataflow.node(%arg18) -> (%13) [%arg22, %arg19, %arg21] {inputTaps = [0 : i32], level = 1 : i32} : (memref<64x28x28xi8, #hls.mem<dram>>) -> memref<16x14x14xi8, #hls.mem<bram_t2p>>[index, index, index] {
                ^bb0(%arg23: memref<64x28x28xi8, #hls.mem<dram>>, %arg24: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg25: index, %arg26: index, %arg27: index):
                  affine.for %arg28 = 0 to 16 {
                    affine.for %arg29 = 0 to 14 {
                      affine.for %arg30 = 0 to 14 {
                        %14 = affine.load %arg23[%arg28 + symbol(%arg25) * 16, %arg29 + symbol(%arg26) * 14, %arg30 + symbol(%arg27) * 14] : memref<64x28x28xi8, #hls.mem<dram>>
                        affine.store %14, %arg24[%arg28, %arg29, %arg30] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                      } {parallel}
                    } {parallel}
                  } {parallel}
                }
                hls.dataflow.node(%13) -> (%arg20) [%arg22, %arg19, %arg21] {inputTaps = [0 : i32], level = 0 : i32} : (memref<16x14x14xi8, #hls.mem<bram_t2p>>) -> memref<64xi8, #hls.mem<bram_t2p>>[index, index, index] {
                ^bb0(%arg23: memref<16x14x14xi8, #hls.mem<bram_t2p>>, %arg24: memref<64xi8, #hls.mem<bram_t2p>>, %arg25: index, %arg26: index, %arg27: index):
                  %c-24_i8 = arith.constant -24 : i8
                  affine.for %arg28 = 0 to 14 {
                    affine.for %arg29 = 0 to 14 {
                      affine.for %arg30 = 0 to 16 {
                        %14 = affine.load %arg23[%arg30, %arg28, %arg29] : memref<16x14x14xi8, #hls.mem<bram_t2p>>
                        %15 = affine.load %arg24[%arg30 + symbol(%arg25) * 16] : memref<64xi8, #hls.mem<bram_t2p>>
                        %16 = arith.addi %15, %14 : i8
                        %17 = arith.divui %16, %c-24_i8 : i8
                        %18 = hls.affine.select #set3(%arg28, %arg29, %arg26, %arg27) %17, %16 : i8
                        affine.store %18, %arg24[%arg30 + symbol(%arg25) * 16] : memref<64xi8, #hls.mem<bram_t2p>>
                      } {parallel, point}
                    } {point}
                  } {point}
                }
              }
            } {parallel}
          }
        }
      }
      hls.dataflow.node(%12, %arg9) -> (%arg7) {inputTaps = [0 : i32, 0 : i32], level = 0 : i32} : (memref<64xi8, #hls.mem<bram_t2p>>, memref<1000x64xi8, #hls.mem<dram>>) -> memref<1000xi8, #hls.mem<dram>> {
      ^bb0(%arg12: memref<64xi8, #hls.mem<bram_t2p>>, %arg13: memref<1000x64xi8, #hls.mem<dram>>, %arg14: memref<1000xi8, #hls.mem<dram>>):
        affine.for %arg15 = 0 to 4 {
          affine.for %arg16 = 0 to 100 {
            hls.dataflow.schedule legal(%arg15, %arg16, %arg12, %arg13, %arg14) : index, index, memref<64xi8, #hls.mem<bram_t2p>>, memref<1000x64xi8, #hls.mem<dram>>, memref<1000xi8, #hls.mem<dram>> {
            ^bb0(%arg17: index, %arg18: index, %arg19: memref<64xi8, #hls.mem<bram_t2p>>, %arg20: memref<1000x64xi8, #hls.mem<dram>>, %arg21: memref<1000xi8, #hls.mem<dram>>):
              %13 = hls.dataflow.buffer {depth = 1 : i32} : memref<10x16xi8, #hls.mem<bram_t2p>>
              %14 = hls.dataflow.buffer {depth = 1 : i32} : memref<10xi8, #hls.mem<bram_t2p>>
              hls.dataflow.node(%arg21) -> (%14) [%arg18] {inputTaps = [0 : i32], level = 2 : i32} : (memref<1000xi8, #hls.mem<dram>>) -> memref<10xi8, #hls.mem<bram_t2p>>[index] {
              ^bb0(%arg22: memref<1000xi8, #hls.mem<dram>>, %arg23: memref<10xi8, #hls.mem<bram_t2p>>, %arg24: index):
                affine.for %arg25 = 0 to 10 {
                  %16 = affine.load %arg22[%arg25 + symbol(%arg24) * 10] : memref<1000xi8, #hls.mem<dram>>
                  affine.store %16, %arg23[%arg25] : memref<10xi8, #hls.mem<bram_t2p>>
                } {parallel}
              }
              hls.dataflow.node(%arg20) -> (%13) [%arg18, %arg17] {inputTaps = [0 : i32], level = 2 : i32} : (memref<1000x64xi8, #hls.mem<dram>>) -> memref<10x16xi8, #hls.mem<bram_t2p>>[index, index] {
              ^bb0(%arg22: memref<1000x64xi8, #hls.mem<dram>>, %arg23: memref<10x16xi8, #hls.mem<bram_t2p>>, %arg24: index, %arg25: index):
                affine.for %arg26 = 0 to 10 {
                  affine.for %arg27 = 0 to 16 {
                    %16 = affine.load %arg22[%arg26 + symbol(%arg24) * 10, %arg27 + symbol(%arg25) * 16] : memref<1000x64xi8, #hls.mem<dram>>
                    affine.store %16, %arg23[%arg26, %arg27] : memref<10x16xi8, #hls.mem<bram_t2p>>
                  } {parallel}
                } {parallel}
              }
              %15 = hls.dataflow.buffer {depth = 1 : i32} : memref<10xi8, #hls.mem<bram_t2p>>
              hls.dataflow.node(%arg19, %13, %14) -> (%15) [%arg17] {inputTaps = [0 : i32, 0 : i32, 0 : i32], level = 1 : i32} : (memref<64xi8, #hls.mem<bram_t2p>>, memref<10x16xi8, #hls.mem<bram_t2p>>, memref<10xi8, #hls.mem<bram_t2p>>) -> memref<10xi8, #hls.mem<bram_t2p>>[index] {
              ^bb0(%arg22: memref<64xi8, #hls.mem<bram_t2p>>, %arg23: memref<10x16xi8, #hls.mem<bram_t2p>>, %arg24: memref<10xi8, #hls.mem<bram_t2p>>, %arg25: memref<10xi8, #hls.mem<bram_t2p>>, %arg26: index):
                %c-24_i8 = arith.constant -24 : i8
                affine.for %arg27 = 0 to 16 {
                  affine.for %arg28 = 0 to 10 {
                    %16 = affine.load %arg24[%arg28] : memref<10xi8, #hls.mem<bram_t2p>>
                    %17 = affine.load %arg25[%arg28] : memref<10xi8, #hls.mem<bram_t2p>>
                    %18 = hls.affine.select #set(%arg27) %16, %17 : i8
                    %19 = hls.affine.select #set4(%arg27, %arg26) %c-24_i8, %18 : i8
                    %20 = affine.load %arg22[%arg27 + symbol(%arg26) * 16] : memref<64xi8, #hls.mem<bram_t2p>>
                    %21 = affine.load %arg23[%arg28, %arg27] : memref<10x16xi8, #hls.mem<bram_t2p>>
                    %22 = arith.muli %20, %21 : i8
                    %23 = arith.addi %19, %22 : i8
                    affine.store %23, %arg25[%arg28] : memref<10xi8, #hls.mem<bram_t2p>>
                  } {parallel, point}
                } {point}
              }
              hls.dataflow.node(%15) -> (%arg21) [%arg18] {inputTaps = [0 : i32], level = 0 : i32} : (memref<10xi8, #hls.mem<bram_t2p>>) -> memref<1000xi8, #hls.mem<dram>>[index] {
              ^bb0(%arg22: memref<10xi8, #hls.mem<bram_t2p>>, %arg23: memref<1000xi8, #hls.mem<dram>>, %arg24: index):
                affine.for %arg25 = 0 to 10 {
                  %16 = affine.load %arg22[%arg25] : memref<10xi8, #hls.mem<bram_t2p>>
                  affine.store %16, %arg23[%arg25 + symbol(%arg24) * 10] : memref<1000xi8, #hls.mem<dram>>
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

