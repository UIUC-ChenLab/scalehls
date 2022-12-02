// RUN: scalehls-translate -scalehls-emit-hlscpp -emit-vitis-directives=true -enforce-false-dependency=true %s | FileCheck %s

#map = affine_map<(d0) -> (d0 mod 100)>
#map1 = affine_map<(d0) -> (d0 floordiv 100)>
#map2 = affine_map<(d0) -> (d0 mod 4)>
#map3 = affine_map<(d0) -> ((d0 floordiv 4) mod 2)>
#map4 = affine_map<(d0) -> ((d0 floordiv 4) floordiv 2)>
#map5 = affine_map<(d0) -> (d0 mod 2)>
#map6 = affine_map<(d0) -> ((d0 floordiv 2) mod 2)>
#map7 = affine_map<(d0) -> (((d0 floordiv 2) floordiv 2) mod 4)>
#map8 = affine_map<(d0) -> (((d0 floordiv 2) floordiv 2) floordiv 4)>
#map9 = affine_map<(d0, d1, d2) -> (0, d1 mod 2, d2 mod 2, d0, d1 floordiv 2, d2 floordiv 2)>
#map10 = affine_map<(d0) -> ((((d0 floordiv 2) floordiv 2) floordiv 4) mod 3)>
#map11 = affine_map<(d0) -> (((((d0 floordiv 2) floordiv 2) floordiv 4) floordiv 3) mod 3)>
#map12 = affine_map<(d0) -> (((((d0 floordiv 2) floordiv 2) floordiv 4) floordiv 3) floordiv 3)>
#map13 = affine_map<(d0, d1, d2) -> (0, d1 mod 4, d2 mod 4, d0, d1 floordiv 4, d2 floordiv 4)>
#map14 = affine_map<(d0) -> ((d0 floordiv 4) mod 4)>
#map15 = affine_map<(d0) -> ((d0 floordiv 4) floordiv 4)>
#set = affine_set<(d0) : (d0 == 0)>
#set1 = affine_set<(d0, d1) : (d0 + d1 * 16 == 0)>
#set2 = affine_set<(d0, d1, d2, d3) : (-d0 - d2 * 14 + 27 == 0, -d1 - d3 * 14 + 27 == 0)>
#set3 = affine_set<(d0)[s0] : (-d0 - s0 * 16 + 63 == 0)>
#set4 = affine_set<(d0, d1, d2, d3) : (-d2 - d3 * 16 + 63 == 0, -d0 + 2 == 0, -d1 + 2 == 0)>
module attributes {torch.debug_module_name = "ResNet"} {
  func.func @forward_node1(%arg0: memref<10xi8, 7>, %arg1: memref<1000xi8, 12>, %arg2: index) attributes {inline} {
    affine.for %arg3 = 0 to 10 {
      %0 = affine.load %arg0[%arg3] : memref<10xi8, 7>
      affine.store %0, %arg1[%arg3 + symbol(%arg2) * 10] : memref<1000xi8, 12>
    } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel}
    return
  }
  func.func @forward_node2(%arg0: memref<64xi8, 7>, %arg1: memref<10x16xi8, 7>, %arg2: memref<10xi8, 7>, %arg3: memref<10xi8, 7>, %arg4: index) attributes {inline} {
    %c-24_i8 = arith.constant -24 : i8
    affine.for %arg5 = 0 to 16 {
      affine.for %arg6 = 0 to 10 {
        %0 = affine.load %arg2[%arg6] : memref<10xi8, 7>
        %1 = affine.load %arg3[%arg6] : memref<10xi8, 7>
        %2 = hls.affine.select #set(%arg5) %0, %1 : i8
        %3 = hls.affine.select #set1(%arg5, %arg4) %c-24_i8, %2 : i8
        %4 = affine.load %arg0[%arg5 + symbol(%arg4) * 16] : memref<64xi8, 7>
        %5 = affine.load %arg1[%arg6, %arg5] : memref<10x16xi8, 7>
        %6 = "hls.prim.mul"(%4, %5) : (i8, i8) -> i16
        %7 = "hls.prim.cast"(%3) : (i8) -> i32
        %8 = "hls.prim.cast"(%6) : (i16) -> i32
        %9 = arith.addi %7, %8 : i32
        %10 = "hls.prim.cast"(%9) : (i32) -> i8
        affine.store %10, %arg3[%arg6] : memref<10xi8, 7>
      } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel, point}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, point}
    return
  }
  func.func @forward_node3(%arg0: memref<1000x64xi8, 12>, %arg1: memref<10x16xi8, 7>, %arg2: index, %arg3: index) attributes {inline} {
    affine.for %arg4 = 0 to 10 {
      affine.for %arg5 = 0 to 16 {
        %0 = affine.load %arg0[%arg4 + symbol(%arg2) * 10, %arg5 + symbol(%arg3) * 16] : memref<1000x64xi8, 12>
        affine.store %0, %arg1[%arg4, %arg5] : memref<10x16xi8, 7>
      } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    return
  }
  func.func @forward_node4(%arg0: memref<1000xi8, 12>, %arg1: memref<10xi8, 7>, %arg2: index) attributes {inline} {
    affine.for %arg3 = 0 to 10 {
      %0 = affine.load %arg0[%arg3 + symbol(%arg2) * 10] : memref<1000xi8, 12>
      affine.store %0, %arg1[%arg3] : memref<10xi8, 7>
    } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel}
    return
  }
  func.func @forward_node0(%arg0: memref<64xi8, 7>, %arg1: memref<1000x64xi8, 12>, %arg2: memref<1000xi8, 12>, %arg3: memref<1000xi8, 12>) {
    affine.for %arg4 = 0 to 400 {
      %0 = affine.apply #map(%arg4)
      %1 = affine.apply #map1(%arg4)
      %2 = hls.dataflow.buffer {depth = 1 : i32} : memref<10x16xi8, 7>
      %3 = hls.dataflow.buffer {depth = 1 : i32} : memref<10xi8, 7>
      func.call @forward_node4(%arg2, %3, %0) : (memref<1000xi8, 12>, memref<10xi8, 7>, index) -> ()
      func.call @forward_node3(%arg1, %2, %0, %1) : (memref<1000x64xi8, 12>, memref<10x16xi8, 7>, index, index) -> ()
      %4 = hls.dataflow.buffer {depth = 1 : i32} : memref<10xi8, 7>
      func.call @forward_node2(%arg0, %2, %3, %4, %1) : (memref<64xi8, 7>, memref<10x16xi8, 7>, memref<10xi8, 7>, memref<10xi8, 7>, index) -> ()
      func.call @forward_node1(%4, %arg3, %0) : (memref<10xi8, 7>, memref<1000xi8, 12>, index) -> ()
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=true, flatten=false>}
    return
  }
  func.func @forward_node6(%arg0: memref<16x14x14xi8, 7>, %arg1: memref<64xi8, 7>, %arg2: index, %arg3: index, %arg4: index) attributes {inline} {
    %c-24_i8 = arith.constant -24 : i8
    affine.for %arg5 = 0 to 14 {
      affine.for %arg6 = 0 to 14 {
        affine.for %arg7 = 0 to 16 {
          %0 = affine.load %arg0[%arg7, %arg5, %arg6] : memref<16x14x14xi8, 7>
          %1 = affine.load %arg1[%arg7 + symbol(%arg2) * 16] : memref<64xi8, 7>
          %2 = "hls.prim.cast"(%1) : (i8) -> i32
          %3 = "hls.prim.cast"(%0) : (i8) -> i32
          %4 = arith.addi %2, %3 : i32
          %5 = "hls.prim.cast"(%4) : (i32) -> i8
          %6 = arith.divui %5, %c-24_i8 : i8
          %7 = hls.affine.select #set2(%arg5, %arg6, %arg3, %arg4) %6, %5 : i8
          affine.store %7, %arg1[%arg7 + symbol(%arg2) * 16] : memref<64xi8, 7>
        } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel, point}
      } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, point}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, point}
    return
  }
  func.func @forward_node7(%arg0: memref<64x28x28xi8, 12>, %arg1: memref<16x14x14xi8, 7>, %arg2: index, %arg3: index, %arg4: index) attributes {inline} {
    affine.for %arg5 = 0 to 16 {
      affine.for %arg6 = 0 to 14 {
        affine.for %arg7 = 0 to 14 {
          %0 = affine.load %arg0[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14] : memref<64x28x28xi8, 12>
          affine.store %0, %arg1[%arg5, %arg6, %arg7] : memref<16x14x14xi8, 7>
        } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel}
      } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    return
  }
  func.func @forward_node5(%arg0: !hls.stream<i1, 1>, %arg1: memref<64x28x28xi8, 12>, %arg2: memref<64xi8, 7>) {
    hls.dataflow.stream_read %arg0 : (!hls.stream<i1, 1>) -> ()
    affine.for %arg3 = 0 to 16 {
      %0 = affine.apply #map2(%arg3)
      %1 = affine.apply #map3(%arg3)
      %2 = affine.apply #map4(%arg3)
      %3 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
      func.call @forward_node7(%arg1, %3, %0, %2, %1) : (memref<64x28x28xi8, 12>, memref<16x14x14xi8, 7>, index, index, index) -> ()
      func.call @forward_node6(%3, %arg2, %0, %2, %1) : (memref<16x14x14xi8, 7>, memref<64xi8, 7>, index, index, index) -> ()
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=true, flatten=false>}
    return
  }
  func.func @forward_node9(%arg0: memref<16x14x14xi8, 7>, %arg1: memref<64x28x28xi8, 12>, %arg2: index, %arg3: index, %arg4: index) attributes {inline} {
    affine.for %arg5 = 0 to 16 {
      affine.for %arg6 = 0 to 14 {
        affine.for %arg7 = 0 to 14 {
          %0 = affine.load %arg0[%arg5, %arg6, %arg7] : memref<16x14x14xi8, 7>
          affine.store %0, %arg1[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14] : memref<64x28x28xi8, 12>
        } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel}
      } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    return
  }
  func.func @forward_node10(%arg0: memref<16x14x14xi8, 7>, %arg1: memref<64x28x28xi8, 12>, %arg2: index, %arg3: index, %arg4: index) attributes {inline} {
    affine.for %arg5 = 0 to 16 {
      affine.for %arg6 = 0 to 14 {
        affine.for %arg7 = 0 to 14 {
          %0 = affine.load %arg0[%arg5, %arg6, %arg7] : memref<16x14x14xi8, 7>
          affine.store %0, %arg1[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14] : memref<64x28x28xi8, 12>
        } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel}
      } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    return
  }
  func.func @forward_node11(%arg0: memref<16x14x14xi8, 7>, %arg1: memref<16x14x14xi8, 7>, %arg2: memref<16x16xi8, 7>, %arg3: memref<16x14x14xi8, 7>, %arg4: memref<16x14x14xi8, 7>, %arg5: memref<16x14x14xi8, 7>, %arg6: index) attributes {inline} {
    %c-24_i8 = arith.constant -24 : i8
    affine.for %arg7 = 0 to 16 {
      affine.for %arg8 = 0 to 16 {
        affine.for %arg9 = 0 to 14 {
          affine.for %arg10 = 0 to 14 {
            %0 = affine.load %arg1[%arg7, %arg9, %arg10] : memref<16x14x14xi8, 7>
            %1 = affine.load %arg2[%arg8, %arg7] : memref<16x16xi8, 7>
            %2 = affine.load %arg3[%arg8, %arg9, %arg10] : memref<16x14x14xi8, 7>
            %3 = affine.load %arg5[%arg8, %arg9, %arg10] : memref<16x14x14xi8, 7>
            %4 = hls.affine.select #set(%arg7) %2, %3 : i8
            %5 = "hls.prim.mul"(%0, %1) : (i8, i8) -> i16
            %6 = "hls.prim.cast"(%4) : (i8) -> i32
            %7 = "hls.prim.cast"(%5) : (i16) -> i32
            %8 = arith.addi %6, %7 : i32
            %9 = "hls.prim.cast"(%8) : (i32) -> i8
            affine.store %9, %arg5[%arg8, %arg9, %arg10] : memref<16x14x14xi8, 7>
            %10 = affine.load %arg0[%arg8, %arg9, %arg10] : memref<16x14x14xi8, 7>
            %11 = "hls.prim.cast"(%10) : (i8) -> i32
            %12 = "hls.prim.cast"(%9) : (i8) -> i32
            %13 = arith.addi %11, %12 : i32
            %14 = "hls.prim.cast"(%13) : (i32) -> i8
            %15 = arith.cmpi ugt, %14, %c-24_i8 : i8
            %16 = arith.select %15, %14, %c-24_i8 : i8
            affine.if #set3(%arg7)[%arg6] {
              affine.store %16, %arg4[%arg8, %arg9, %arg10] : memref<16x14x14xi8, 7>
            }
          } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel, point}
        } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel, point}
      } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel, point}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, point}
    return
  }
  func.func @forward_node12(%arg0: memref<64x28x28xi8, 12>, %arg1: memref<16x14x14xi8, 7>, %arg2: index, %arg3: index, %arg4: index) attributes {inline} {
    affine.for %arg5 = 0 to 16 {
      affine.for %arg6 = 0 to 14 {
        affine.for %arg7 = 0 to 14 {
          %0 = affine.load %arg0[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14] : memref<64x28x28xi8, 12>
          affine.store %0, %arg1[%arg5, %arg6, %arg7] : memref<16x14x14xi8, 7>
        } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel}
      } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    return
  }
  func.func @forward_node13(%arg0: memref<64x28x28xi8, 12>, %arg1: memref<16x14x14xi8, 7>, %arg2: index, %arg3: index, %arg4: index) attributes {inline} {
    affine.for %arg5 = 0 to 16 {
      affine.for %arg6 = 0 to 14 {
        affine.for %arg7 = 0 to 14 {
          %0 = affine.load %arg0[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14] : memref<64x28x28xi8, 12>
          affine.store %0, %arg1[%arg5, %arg6, %arg7] : memref<16x14x14xi8, 7>
        } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel}
      } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    return
  }
  func.func @forward_node14(%arg0: memref<64x64xi8, 12>, %arg1: memref<16x16xi8, 7>, %arg2: index, %arg3: index) attributes {inline} {
    affine.for %arg4 = 0 to 16 {
      affine.for %arg5 = 0 to 16 {
        %0 = affine.load %arg0[%arg4 + symbol(%arg2) * 16, %arg5 + symbol(%arg3) * 16] : memref<64x64xi8, 12>
        affine.store %0, %arg1[%arg4, %arg5] : memref<16x16xi8, 7>
      } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    return
  }
  func.func @forward_node15(%arg0: memref<64x56x56xi8, 12>, %arg1: memref<16x14x14xi8, 7>, %arg2: index, %arg3: index, %arg4: index) attributes {inline} {
    affine.for %arg5 = 0 to 16 {
      affine.for %arg6 = 0 to 14 {
        affine.for %arg7 = 0 to 14 {
          %0 = affine.load %arg0[%arg5 + symbol(%arg2) * 16, %arg6 * 2 + symbol(%arg3) * 28, %arg7 * 2 + symbol(%arg4) * 28] : memref<64x56x56xi8, 12>
          affine.store %0, %arg1[%arg5, %arg6, %arg7] : memref<16x14x14xi8, 7>
        } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel}
      } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    return
  }
  func.func @forward_node8(%arg0: !hls.stream<i1, 3>, %arg1: memref<64x56x56xi8, 12>, %arg2: memref<64x64xi8, 12>, %arg3: !hls.stream<i1, 1>, %arg4: memref<64x28x28xi8, 12>, %arg5: memref<64x28x28xi8, 12>, %arg6: !hls.stream<i1, 1>, %arg7: memref<64x28x28xi8, 12>, %arg8: memref<64x28x28xi8, 12>) {
    %true = arith.constant true
    hls.dataflow.stream_read %arg3 : (!hls.stream<i1, 1>) -> ()
    hls.dataflow.stream_read %arg0 : (!hls.stream<i1, 3>) -> ()
    affine.for %arg9 = 0 to 64 {
      %0 = affine.apply #map5(%arg9)
      %1 = affine.apply #map6(%arg9)
      %2 = affine.apply #map7(%arg9)
      %3 = affine.apply #map8(%arg9)
      %4 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
      %5 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, 7>
      %6 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, 7>
      %7 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, 7>
      %8 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
      func.call @forward_node15(%arg1, %8, %3, %1, %0) : (memref<64x56x56xi8, 12>, memref<16x14x14xi8, 7>, index, index, index) -> ()
      func.call @forward_node14(%arg2, %7, %2, %3) : (memref<64x64xi8, 12>, memref<16x16xi8, 7>, index, index) -> ()
      func.call @forward_node13(%arg5, %6, %2, %1, %0) : (memref<64x28x28xi8, 12>, memref<16x14x14xi8, 7>, index, index, index) -> ()
      func.call @forward_node12(%arg4, %5, %2, %1, %0) : (memref<64x28x28xi8, 12>, memref<16x14x14xi8, 7>, index, index, index) -> ()
      %9 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
      func.call @forward_node11(%5, %8, %7, %6, %4, %9, %3) : (memref<16x14x14xi8, 7>, memref<16x14x14xi8, 7>, memref<16x16xi8, 7>, memref<16x14x14xi8, 7>, memref<16x14x14xi8, 7>, memref<16x14x14xi8, 7>, index) -> ()
      func.call @forward_node10(%9, %arg8, %2, %1, %0) : (memref<16x14x14xi8, 7>, memref<64x28x28xi8, 12>, index, index, index) -> ()
      func.call @forward_node9(%4, %arg7, %2, %1, %0) : (memref<16x14x14xi8, 7>, memref<64x28x28xi8, 12>, index, index, index) -> ()
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=true, flatten=false>}
    hls.dataflow.stream_write %arg6, %true : <i1, 1>, i1
    return
  }
  func.func @forward_node17(%arg0: memref<16x14x14xi8, #map9, 7>, %arg1: memref<64x28x28xi8, #map9, 12>, %arg2: index, %arg3: index, %arg4: index) attributes {inline} {
    affine.for %arg5 = 0 to 16 {
      affine.for %arg6 = 0 to 14 step 2 {
        affine.for %arg7 = 0 to 14 step 2 {
          %0 = affine.load %arg0[%arg5, %arg6, %arg7] : memref<16x14x14xi8, #map9, 7>
          affine.store %0, %arg1[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14] : memref<64x28x28xi8, #map9, 12>
          %1 = affine.load %arg0[%arg5, %arg6, %arg7 + 1] : memref<16x14x14xi8, #map9, 7>
          affine.store %1, %arg1[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14 + 1] : memref<64x28x28xi8, #map9, 12>
          %2 = affine.load %arg0[%arg5, %arg6 + 1, %arg7] : memref<16x14x14xi8, #map9, 7>
          affine.store %2, %arg1[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14 + 1, %arg7 + symbol(%arg4) * 14] : memref<64x28x28xi8, #map9, 12>
          %3 = affine.load %arg0[%arg5, %arg6 + 1, %arg7 + 1] : memref<16x14x14xi8, #map9, 7>
          affine.store %3, %arg1[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14 + 1, %arg7 + symbol(%arg4) * 14 + 1] : memref<64x28x28xi8, #map9, 12>
        } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel}
      } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    return
  }
  func.func @forward_node18(%arg0: memref<16x14x14xi8, #map9, 7>, %arg1: memref<16x16xi8, 7>, %arg2: memref<16x14x14xi8, #map9, 7>, %arg3: memref<16x14x14xi8, #map9, 7>) attributes {inline} {
    affine.for %arg4 = 0 to 16 {
      affine.for %arg5 = 0 to 16 {
        affine.for %arg6 = 0 to 14 step 2 {
          affine.for %arg7 = 0 to 14 step 2 {
            %0 = affine.load %arg0[%arg4, %arg6, %arg7] : memref<16x14x14xi8, #map9, 7>
            %1 = affine.load %arg1[%arg5, %arg4] : memref<16x16xi8, 7>
            %2 = affine.load %arg2[%arg5, %arg6, %arg7] : memref<16x14x14xi8, #map9, 7>
            %3 = affine.load %arg3[%arg5, %arg6, %arg7] : memref<16x14x14xi8, #map9, 7>
            %4 = hls.affine.select #set(%arg4) %2, %3 : i8
            %5 = "hls.prim.mul"(%0, %1) : (i8, i8) -> i16
            %6 = "hls.prim.cast"(%4) : (i8) -> i32
            %7 = "hls.prim.cast"(%5) : (i16) -> i32
            %8 = arith.addi %6, %7 : i32
            %9 = "hls.prim.cast"(%8) : (i32) -> i8
            affine.store %9, %arg3[%arg5, %arg6, %arg7] : memref<16x14x14xi8, #map9, 7>
            %10 = affine.load %arg0[%arg4, %arg6, %arg7 + 1] : memref<16x14x14xi8, #map9, 7>
            %11 = affine.load %arg2[%arg5, %arg6, %arg7 + 1] : memref<16x14x14xi8, #map9, 7>
            %12 = affine.load %arg3[%arg5, %arg6, %arg7 + 1] : memref<16x14x14xi8, #map9, 7>
            %13 = hls.affine.select #set(%arg4) %11, %12 : i8
            %14 = "hls.prim.mul"(%10, %1) : (i8, i8) -> i16
            %15 = "hls.prim.cast"(%13) : (i8) -> i32
            %16 = "hls.prim.cast"(%14) : (i16) -> i32
            %17 = arith.addi %15, %16 : i32
            %18 = "hls.prim.cast"(%17) : (i32) -> i8
            affine.store %18, %arg3[%arg5, %arg6, %arg7 + 1] : memref<16x14x14xi8, #map9, 7>
            %19 = affine.load %arg0[%arg4, %arg6 + 1, %arg7] : memref<16x14x14xi8, #map9, 7>
            %20 = affine.load %arg2[%arg5, %arg6 + 1, %arg7] : memref<16x14x14xi8, #map9, 7>
            %21 = affine.load %arg3[%arg5, %arg6 + 1, %arg7] : memref<16x14x14xi8, #map9, 7>
            %22 = hls.affine.select #set(%arg4) %20, %21 : i8
            %23 = "hls.prim.mul"(%19, %1) : (i8, i8) -> i16
            %24 = "hls.prim.cast"(%22) : (i8) -> i32
            %25 = "hls.prim.cast"(%23) : (i16) -> i32
            %26 = arith.addi %24, %25 : i32
            %27 = "hls.prim.cast"(%26) : (i32) -> i8
            affine.store %27, %arg3[%arg5, %arg6 + 1, %arg7] : memref<16x14x14xi8, #map9, 7>
            %28 = affine.load %arg0[%arg4, %arg6 + 1, %arg7 + 1] : memref<16x14x14xi8, #map9, 7>
            %29 = affine.load %arg2[%arg5, %arg6 + 1, %arg7 + 1] : memref<16x14x14xi8, #map9, 7>
            %30 = affine.load %arg3[%arg5, %arg6 + 1, %arg7 + 1] : memref<16x14x14xi8, #map9, 7>
            %31 = hls.affine.select #set(%arg4) %29, %30 : i8
            %32 = "hls.prim.mul"(%28, %1) : (i8, i8) -> i16
            %33 = "hls.prim.cast"(%31) : (i8) -> i32
            %34 = "hls.prim.cast"(%32) : (i16) -> i32
            %35 = arith.addi %33, %34 : i32
            %36 = "hls.prim.cast"(%35) : (i32) -> i8
            affine.store %36, %arg3[%arg5, %arg6 + 1, %arg7 + 1] : memref<16x14x14xi8, #map9, 7>
          } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel, point}
        } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel, point}
      } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel, point}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, point}
    return
  }
  func.func @forward_node19(%arg0: memref<64x28x28xi8, #map9, 12>, %arg1: memref<16x14x14xi8, #map9, 7>, %arg2: index, %arg3: index, %arg4: index) attributes {inline} {
    affine.for %arg5 = 0 to 16 {
      affine.for %arg6 = 0 to 14 step 2 {
        affine.for %arg7 = 0 to 14 step 2 {
          %0 = affine.load %arg0[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14] : memref<64x28x28xi8, #map9, 12>
          affine.store %0, %arg1[%arg5, %arg6, %arg7] : memref<16x14x14xi8, #map9, 7>
          %1 = affine.load %arg0[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14 + 1] : memref<64x28x28xi8, #map9, 12>
          affine.store %1, %arg1[%arg5, %arg6, %arg7 + 1] : memref<16x14x14xi8, #map9, 7>
          %2 = affine.load %arg0[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14 + 1, %arg7 + symbol(%arg4) * 14] : memref<64x28x28xi8, #map9, 12>
          affine.store %2, %arg1[%arg5, %arg6 + 1, %arg7] : memref<16x14x14xi8, #map9, 7>
          %3 = affine.load %arg0[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14 + 1, %arg7 + symbol(%arg4) * 14 + 1] : memref<64x28x28xi8, #map9, 12>
          affine.store %3, %arg1[%arg5, %arg6 + 1, %arg7 + 1] : memref<16x14x14xi8, #map9, 7>
        } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel}
      } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    return
  }
  func.func @forward_node20(%arg0: memref<64x64x3x3xi8, 12>, %arg1: memref<16x16xi8, 7>, %arg2: index, %arg3: index, %arg4: index, %arg5: index) attributes {inline} {
    affine.for %arg6 = 0 to 16 {
      affine.for %arg7 = 0 to 16 {
        %0 = affine.load %arg0[%arg6 + symbol(%arg2) * 16, %arg7 + symbol(%arg3) * 16, symbol(%arg4), symbol(%arg5)] : memref<64x64x3x3xi8, 12>
        affine.store %0, %arg1[%arg6, %arg7] : memref<16x16xi8, 7>
      } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    return
  }
  func.func @forward_node21(%arg0: memref<64x28x28xi8, #map9, 12>, %arg1: memref<16x14x14xi8, #map9, 7>, %arg2: index, %arg3: index, %arg4: index, %arg5: index, %arg6: index) attributes {inline} {
    affine.for %arg7 = 0 to 16 {
      affine.for %arg8 = 0 to 14 step 2 {
        affine.for %arg9 = 0 to 14 step 2 {
          %0 = affine.load %arg0[%arg7 + symbol(%arg2) * 16, %arg8 + symbol(%arg3) + symbol(%arg4) * 14 - 1, %arg9 + symbol(%arg5) + symbol(%arg6) * 14 - 1] : memref<64x28x28xi8, #map9, 12>
          affine.store %0, %arg1[%arg7, %arg8, %arg9] : memref<16x14x14xi8, #map9, 7>
          %1 = affine.load %arg0[%arg7 + symbol(%arg2) * 16, %arg8 + symbol(%arg3) + symbol(%arg4) * 14 - 1, %arg9 + symbol(%arg5) + symbol(%arg6) * 14] : memref<64x28x28xi8, #map9, 12>
          affine.store %1, %arg1[%arg7, %arg8, %arg9 + 1] : memref<16x14x14xi8, #map9, 7>
          %2 = affine.load %arg0[%arg7 + symbol(%arg2) * 16, %arg8 + symbol(%arg3) + symbol(%arg4) * 14, %arg9 + symbol(%arg5) + symbol(%arg6) * 14 - 1] : memref<64x28x28xi8, #map9, 12>
          affine.store %2, %arg1[%arg7, %arg8 + 1, %arg9] : memref<16x14x14xi8, #map9, 7>
          %3 = affine.load %arg0[%arg7 + symbol(%arg2) * 16, %arg8 + symbol(%arg3) + symbol(%arg4) * 14, %arg9 + symbol(%arg5) + symbol(%arg6) * 14] : memref<64x28x28xi8, #map9, 12>
          affine.store %3, %arg1[%arg7, %arg8 + 1, %arg9 + 1] : memref<16x14x14xi8, #map9, 7>
        } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel}
      } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    return
  }
  func.func @forward_node16(%arg0: memref<64x64x3x3xi8, 12>, %arg1: !hls.stream<i1, 1>, %arg2: memref<64x28x28xi8, #map9, 12>, %arg3: memref<64x28x28xi8, #map9, 12>, %arg4: !hls.stream<i1, 1>, %arg5: memref<64x28x28xi8, #map9, 12>) {
    %true = arith.constant true
    hls.dataflow.stream_read %arg1 : (!hls.stream<i1, 1>) -> ()
    affine.for %arg6 = 0 to 576 {
      %0 = affine.apply #map5(%arg6)
      %1 = affine.apply #map6(%arg6)
      %2 = affine.apply #map7(%arg6)
      %3 = affine.apply #map10(%arg6)
      %4 = affine.apply #map11(%arg6)
      %5 = affine.apply #map12(%arg6)
      %6 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #map9, 7>
      %7 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, 7>
      %8 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #map9, 7>
      func.call @forward_node21(%arg2, %8, %5, %4, %1, %3, %0) : (memref<64x28x28xi8, #map9, 12>, memref<16x14x14xi8, #map9, 7>, index, index, index, index, index) -> ()
      func.call @forward_node20(%arg0, %7, %2, %5, %4, %3) : (memref<64x64x3x3xi8, 12>, memref<16x16xi8, 7>, index, index, index, index) -> ()
      func.call @forward_node19(%arg3, %6, %2, %1, %0) : (memref<64x28x28xi8, #map9, 12>, memref<16x14x14xi8, #map9, 7>, index, index, index) -> ()
      %9 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #map9, 7>
      func.call @forward_node18(%8, %7, %6, %9) : (memref<16x14x14xi8, #map9, 7>, memref<16x16xi8, 7>, memref<16x14x14xi8, #map9, 7>, memref<16x14x14xi8, #map9, 7>) -> ()
      func.call @forward_node17(%9, %arg5, %2, %1, %0) : (memref<16x14x14xi8, #map9, 7>, memref<64x28x28xi8, #map9, 12>, index, index, index) -> ()
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=true, flatten=false>}
    hls.dataflow.stream_write %arg4, %true : <i1, 1>, i1
    return
  }
  func.func @forward_node23(%arg0: memref<16x14x14xi8, #map9, 7>, %arg1: memref<64x28x28xi8, #map9, 12>, %arg2: index, %arg3: index, %arg4: index) attributes {inline} {
    affine.for %arg5 = 0 to 16 {
      affine.for %arg6 = 0 to 14 step 2 {
        affine.for %arg7 = 0 to 14 step 2 {
          %0 = affine.load %arg0[%arg5, %arg6, %arg7] : memref<16x14x14xi8, #map9, 7>
          affine.store %0, %arg1[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14] : memref<64x28x28xi8, #map9, 12>
          %1 = affine.load %arg0[%arg5, %arg6, %arg7 + 1] : memref<16x14x14xi8, #map9, 7>
          affine.store %1, %arg1[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14 + 1] : memref<64x28x28xi8, #map9, 12>
          %2 = affine.load %arg0[%arg5, %arg6 + 1, %arg7] : memref<16x14x14xi8, #map9, 7>
          affine.store %2, %arg1[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14 + 1, %arg7 + symbol(%arg4) * 14] : memref<64x28x28xi8, #map9, 12>
          %3 = affine.load %arg0[%arg5, %arg6 + 1, %arg7 + 1] : memref<16x14x14xi8, #map9, 7>
          affine.store %3, %arg1[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14 + 1, %arg7 + symbol(%arg4) * 14 + 1] : memref<64x28x28xi8, #map9, 12>
        } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel}
      } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    return
  }
  func.func @forward_node24(%arg0: memref<16x14x14xi8, #map9, 7>, %arg1: memref<16x16xi8, 7>, %arg2: memref<16x14x14xi8, #map9, 7>, %arg3: memref<16x14x14xi8, #map9, 7>, %arg4: index, %arg5: index, %arg6: index) attributes {inline} {
    %c-24_i8 = arith.constant -24 : i8
    affine.for %arg7 = 0 to 16 {
      affine.for %arg8 = 0 to 16 {
        affine.for %arg9 = 0 to 14 step 2 {
          affine.for %arg10 = 0 to 14 step 2 {
            %0 = affine.load %arg0[%arg7, %arg9, %arg10] : memref<16x14x14xi8, #map9, 7>
            %1 = affine.load %arg1[%arg8, %arg7] : memref<16x16xi8, 7>
            %2 = affine.load %arg2[%arg8, %arg9, %arg10] : memref<16x14x14xi8, #map9, 7>
            %3 = affine.load %arg3[%arg8, %arg9, %arg10] : memref<16x14x14xi8, #map9, 7>
            %4 = hls.affine.select #set(%arg7) %2, %3 : i8
            %5 = "hls.prim.mul"(%0, %1) : (i8, i8) -> i16
            %6 = "hls.prim.cast"(%4) : (i8) -> i32
            %7 = "hls.prim.cast"(%5) : (i16) -> i32
            %8 = arith.addi %6, %7 : i32
            %9 = "hls.prim.cast"(%8) : (i32) -> i8
            %10 = arith.cmpi ugt, %9, %c-24_i8 : i8
            %11 = arith.select %10, %9, %c-24_i8 : i8
            %12 = hls.affine.select #set4(%arg6, %arg4, %arg7, %arg5) %11, %9 : i8
            affine.store %12, %arg3[%arg8, %arg9, %arg10] : memref<16x14x14xi8, #map9, 7>
            %13 = affine.load %arg0[%arg7, %arg9, %arg10 + 1] : memref<16x14x14xi8, #map9, 7>
            %14 = affine.load %arg2[%arg8, %arg9, %arg10 + 1] : memref<16x14x14xi8, #map9, 7>
            %15 = affine.load %arg3[%arg8, %arg9, %arg10 + 1] : memref<16x14x14xi8, #map9, 7>
            %16 = hls.affine.select #set(%arg7) %14, %15 : i8
            %17 = "hls.prim.mul"(%13, %1) : (i8, i8) -> i16
            %18 = "hls.prim.cast"(%16) : (i8) -> i32
            %19 = "hls.prim.cast"(%17) : (i16) -> i32
            %20 = arith.addi %18, %19 : i32
            %21 = "hls.prim.cast"(%20) : (i32) -> i8
            %22 = arith.cmpi ugt, %21, %c-24_i8 : i8
            %23 = arith.select %22, %21, %c-24_i8 : i8
            %24 = hls.affine.select #set4(%arg6, %arg4, %arg7, %arg5) %23, %21 : i8
            affine.store %24, %arg3[%arg8, %arg9, %arg10 + 1] : memref<16x14x14xi8, #map9, 7>
            %25 = affine.load %arg0[%arg7, %arg9 + 1, %arg10] : memref<16x14x14xi8, #map9, 7>
            %26 = affine.load %arg2[%arg8, %arg9 + 1, %arg10] : memref<16x14x14xi8, #map9, 7>
            %27 = affine.load %arg3[%arg8, %arg9 + 1, %arg10] : memref<16x14x14xi8, #map9, 7>
            %28 = hls.affine.select #set(%arg7) %26, %27 : i8
            %29 = "hls.prim.mul"(%25, %1) : (i8, i8) -> i16
            %30 = "hls.prim.cast"(%28) : (i8) -> i32
            %31 = "hls.prim.cast"(%29) : (i16) -> i32
            %32 = arith.addi %30, %31 : i32
            %33 = "hls.prim.cast"(%32) : (i32) -> i8
            %34 = arith.cmpi ugt, %33, %c-24_i8 : i8
            %35 = arith.select %34, %33, %c-24_i8 : i8
            %36 = hls.affine.select #set4(%arg6, %arg4, %arg7, %arg5) %35, %33 : i8
            affine.store %36, %arg3[%arg8, %arg9 + 1, %arg10] : memref<16x14x14xi8, #map9, 7>
            %37 = affine.load %arg0[%arg7, %arg9 + 1, %arg10 + 1] : memref<16x14x14xi8, #map9, 7>
            %38 = affine.load %arg2[%arg8, %arg9 + 1, %arg10 + 1] : memref<16x14x14xi8, #map9, 7>
            %39 = affine.load %arg3[%arg8, %arg9 + 1, %arg10 + 1] : memref<16x14x14xi8, #map9, 7>
            %40 = hls.affine.select #set(%arg7) %38, %39 : i8
            %41 = "hls.prim.mul"(%37, %1) : (i8, i8) -> i16
            %42 = "hls.prim.cast"(%40) : (i8) -> i32
            %43 = "hls.prim.cast"(%41) : (i16) -> i32
            %44 = arith.addi %42, %43 : i32
            %45 = "hls.prim.cast"(%44) : (i32) -> i8
            %46 = arith.cmpi ugt, %45, %c-24_i8 : i8
            %47 = arith.select %46, %45, %c-24_i8 : i8
            %48 = hls.affine.select #set4(%arg6, %arg4, %arg7, %arg5) %47, %45 : i8
            affine.store %48, %arg3[%arg8, %arg9 + 1, %arg10 + 1] : memref<16x14x14xi8, #map9, 7>
          } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel, point}
        } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel, point}
      } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel, point}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, point}
    return
  }
  func.func @forward_node25(%arg0: memref<64x28x28xi8, #map9, 12>, %arg1: memref<16x14x14xi8, #map9, 7>, %arg2: index, %arg3: index, %arg4: index) attributes {inline} {
    affine.for %arg5 = 0 to 16 {
      affine.for %arg6 = 0 to 14 step 2 {
        affine.for %arg7 = 0 to 14 step 2 {
          %0 = affine.load %arg0[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14] : memref<64x28x28xi8, #map9, 12>
          affine.store %0, %arg1[%arg5, %arg6, %arg7] : memref<16x14x14xi8, #map9, 7>
          %1 = affine.load %arg0[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14 + 1] : memref<64x28x28xi8, #map9, 12>
          affine.store %1, %arg1[%arg5, %arg6, %arg7 + 1] : memref<16x14x14xi8, #map9, 7>
          %2 = affine.load %arg0[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14 + 1, %arg7 + symbol(%arg4) * 14] : memref<64x28x28xi8, #map9, 12>
          affine.store %2, %arg1[%arg5, %arg6 + 1, %arg7] : memref<16x14x14xi8, #map9, 7>
          %3 = affine.load %arg0[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14 + 1, %arg7 + symbol(%arg4) * 14 + 1] : memref<64x28x28xi8, #map9, 12>
          affine.store %3, %arg1[%arg5, %arg6 + 1, %arg7 + 1] : memref<16x14x14xi8, #map9, 7>
        } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel}
      } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    return
  }
  func.func @forward_node26(%arg0: memref<64x64x3x3xi8, 12>, %arg1: memref<16x16xi8, 7>, %arg2: index, %arg3: index, %arg4: index, %arg5: index) attributes {inline} {
    affine.for %arg6 = 0 to 16 {
      affine.for %arg7 = 0 to 16 {
        %0 = affine.load %arg0[%arg6 + symbol(%arg2) * 16, %arg7 + symbol(%arg3) * 16, symbol(%arg4), symbol(%arg5)] : memref<64x64x3x3xi8, 12>
        affine.store %0, %arg1[%arg6, %arg7] : memref<16x16xi8, 7>
      } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    return
  }
  func.func @forward_node27(%arg0: memref<64x56x56xi8, #map13, 12>, %arg1: memref<16x14x14xi8, #map9, 7>, %arg2: index, %arg3: index, %arg4: index, %arg5: index, %arg6: index) attributes {inline} {
    affine.for %arg7 = 0 to 16 {
      affine.for %arg8 = 0 to 14 step 2 {
        affine.for %arg9 = 0 to 14 step 2 {
          %0 = affine.load %arg0[%arg7 + symbol(%arg2) * 16, %arg8 * 2 + symbol(%arg3) + symbol(%arg4) * 28 - 1, %arg9 * 2 + symbol(%arg5) + symbol(%arg6) * 28 - 1] : memref<64x56x56xi8, #map13, 12>
          affine.store %0, %arg1[%arg7, %arg8, %arg9] : memref<16x14x14xi8, #map9, 7>
          %1 = affine.load %arg0[%arg7 + symbol(%arg2) * 16, %arg8 * 2 + symbol(%arg3) + symbol(%arg4) * 28 - 1, %arg9 * 2 + symbol(%arg5) + symbol(%arg6) * 28 + 1] : memref<64x56x56xi8, #map13, 12>
          affine.store %1, %arg1[%arg7, %arg8, %arg9 + 1] : memref<16x14x14xi8, #map9, 7>
          %2 = affine.load %arg0[%arg7 + symbol(%arg2) * 16, %arg8 * 2 + symbol(%arg3) + symbol(%arg4) * 28 + 1, %arg9 * 2 + symbol(%arg5) + symbol(%arg6) * 28 - 1] : memref<64x56x56xi8, #map13, 12>
          affine.store %2, %arg1[%arg7, %arg8 + 1, %arg9] : memref<16x14x14xi8, #map9, 7>
          %3 = affine.load %arg0[%arg7 + symbol(%arg2) * 16, %arg8 * 2 + symbol(%arg3) + symbol(%arg4) * 28 + 1, %arg9 * 2 + symbol(%arg5) + symbol(%arg6) * 28 + 1] : memref<64x56x56xi8, #map13, 12>
          affine.store %3, %arg1[%arg7, %arg8 + 1, %arg9 + 1] : memref<16x14x14xi8, #map9, 7>
        } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel}
      } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    return
  }
  func.func @forward_node22(%arg0: !hls.stream<i1, 1>, %arg1: memref<64x56x56xi8, #map13, 12>, %arg2: memref<64x64x3x3xi8, 12>, %arg3: memref<64x28x28xi8, #map9, 12>, %arg4: !hls.stream<i1, 1>, %arg5: memref<64x28x28xi8, #map9, 12>) {
    %true = arith.constant true
    hls.dataflow.stream_read %arg0 : (!hls.stream<i1, 1>) -> ()
    affine.for %arg6 = 0 to 576 {
      %0 = affine.apply #map5(%arg6)
      %1 = affine.apply #map6(%arg6)
      %2 = affine.apply #map7(%arg6)
      %3 = affine.apply #map10(%arg6)
      %4 = affine.apply #map11(%arg6)
      %5 = affine.apply #map12(%arg6)
      %6 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, #map9, 7>
      %7 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, 7>
      %8 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #map9, 7>
      func.call @forward_node27(%arg1, %8, %5, %4, %1, %3, %0) : (memref<64x56x56xi8, #map13, 12>, memref<16x14x14xi8, #map9, 7>, index, index, index, index, index) -> ()
      func.call @forward_node26(%arg2, %7, %2, %5, %4, %3) : (memref<64x64x3x3xi8, 12>, memref<16x16xi8, 7>, index, index, index, index) -> ()
      func.call @forward_node25(%arg3, %6, %2, %1, %0) : (memref<64x28x28xi8, #map9, 12>, memref<16x14x14xi8, #map9, 7>, index, index, index) -> ()
      %9 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, #map9, 7>
      func.call @forward_node24(%8, %7, %6, %9, %3, %5, %4) : (memref<16x14x14xi8, #map9, 7>, memref<16x16xi8, 7>, memref<16x14x14xi8, #map9, 7>, memref<16x14x14xi8, #map9, 7>, index, index, index) -> ()
      func.call @forward_node23(%9, %arg5, %2, %1, %0) : (memref<16x14x14xi8, #map9, 7>, memref<64x28x28xi8, #map9, 12>, index, index, index) -> ()
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=true, flatten=false>}
    hls.dataflow.stream_write %arg4, %true : <i1, 1>, i1
    return
  }
  func.func @forward_node28(%arg0: !hls.stream<i1, 1>, %arg1: memref<64x56x56xi8, 12>, %arg2: !hls.stream<i1, 3>, %arg3: memref<64x56x56xi8, 12>, %arg4: !hls.stream<i1, 1>, %arg5: memref<64x56x56xi8, 12>) {
    %true = arith.constant true
    hls.dataflow.stream_read %arg0 : (!hls.stream<i1, 1>) -> ()
    affine.for %arg6 = 0 to 64 {
      affine.for %arg7 = 0 to 56 {
        affine.for %arg8 = 0 to 56 {
          %0 = affine.load %arg1[%arg6, %arg7, %arg8] : memref<64x56x56xi8, 12>
          affine.store %0, %arg3[%arg6, %arg7, %arg8] : memref<64x56x56xi8, 12>
        } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel}
      } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    affine.for %arg6 = 0 to 64 {
      affine.for %arg7 = 0 to 56 {
        affine.for %arg8 = 0 to 56 {
          %0 = affine.load %arg1[%arg6, %arg7, %arg8] : memref<64x56x56xi8, 12>
          affine.store %0, %arg5[%arg6, %arg7, %arg8] : memref<64x56x56xi8, 12>
        } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel}
      } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    hls.dataflow.stream_write %arg2, %true : <i1, 3>, i1
    hls.dataflow.stream_write %arg4, %true : <i1, 1>, i1
    return
  }
  func.func @forward_node30(%arg0: memref<16x14x14xi8, 7>, %arg1: memref<64x56x56xi8, 12>, %arg2: index, %arg3: index, %arg4: index) attributes {inline} {
    affine.for %arg5 = 0 to 16 {
      affine.for %arg6 = 0 to 14 {
        affine.for %arg7 = 0 to 14 {
          %0 = affine.load %arg0[%arg5, %arg6, %arg7] : memref<16x14x14xi8, 7>
          affine.store %0, %arg1[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14] : memref<64x56x56xi8, 12>
        } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel}
      } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    return
  }
  func.func @forward_node31(%arg0: memref<16x14x14xi8, 7>, %arg1: memref<16x14x14xi8, 7>) attributes {inline} {
    %c-24_i8 = arith.constant -24 : i8
    affine.for %arg2 = 0 to 16 {
      affine.for %arg3 = 0 to 14 {
        affine.for %arg4 = 0 to 14 {
          %0 = affine.load %arg0[%arg2, %arg3, %arg4] : memref<16x14x14xi8, 7>
          %1 = arith.cmpi ugt, %0, %c-24_i8 : i8
          %2 = arith.select %1, %0, %c-24_i8 : i8
          affine.store %2, %arg1[%arg2, %arg3, %arg4] : memref<16x14x14xi8, 7>
        } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel, point}
      } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel, point}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel, point}
    return
  }
  func.func @forward_node32(%arg0: memref<64x56x56xi8, 12>, %arg1: memref<16x14x14xi8, 7>, %arg2: index, %arg3: index, %arg4: index) attributes {inline} {
    affine.for %arg5 = 0 to 16 {
      affine.for %arg6 = 0 to 14 {
        affine.for %arg7 = 0 to 14 {
          %0 = affine.load %arg0[%arg5 + symbol(%arg2) * 16, %arg6 + symbol(%arg3) * 14, %arg7 + symbol(%arg4) * 14] : memref<64x56x56xi8, 12>
          affine.store %0, %arg1[%arg5, %arg6, %arg7] : memref<16x14x14xi8, 7>
        } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, parallel}
      } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    return
  }
  func.func @forward_node29(%arg0: memref<64x56x56xi8, 12>, %arg1: !hls.stream<i1, 1>, %arg2: memref<64x56x56xi8, 12>) {
    %true = arith.constant true
    affine.for %arg3 = 0 to 64 {
      %0 = affine.apply #map2(%arg3)
      %1 = affine.apply #map14(%arg3)
      %2 = affine.apply #map15(%arg3)
      %3 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
      func.call @forward_node32(%arg0, %3, %2, %1, %0) : (memref<64x56x56xi8, 12>, memref<16x14x14xi8, 7>, index, index, index) -> ()
      %4 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
      func.call @forward_node31(%3, %4) : (memref<16x14x14xi8, 7>, memref<16x14x14xi8, 7>) -> ()
      func.call @forward_node30(%4, %arg2, %2, %1, %0) : (memref<16x14x14xi8, 7>, memref<64x56x56xi8, 12>, index, index, index) -> ()
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=true, flatten=false>, parallel}
    hls.dataflow.stream_write %arg1, %true : <i1, 1>, i1
    return
  }
  func.func @forward(%arg0: !hls.axi<memref<64x56x56xi8, 12>, 0 : i32>, %arg1: !hls.axi<memref<64x56x56xi8, 12>, 0 : i32>, %arg2: !hls.axi<memref<64x56x56xi8, 12>, 0 : i32>, %arg3: !hls.axi<memref<1000x64xi8, 12>, 0 : i32>, %arg4: !hls.axi<memref<64x64xi8, 12>, 0 : i32>, %arg5: !hls.axi<memref<64x64x3x3xi8, 12>, 0 : i32>, %arg6: !hls.axi<memref<64x64x3x3xi8, 12>, 0 : i32>, %arg7: !hls.axi<memref<1000xi8, 12>, 0 : i32>, %arg8: !hls.axi<memref<1000xi8, 12>, 0 : i32>, %arg9: !hls.axi<memref<64x56x56xi8, 12>, 0 : i32>, %arg10: !hls.axi<memref<64x56x56xi8, 12>, 0 : i32>, %arg11: !hls.axi<memref<64x56x56xi8, 12>, 0 : i32>, %arg12: !hls.axi<memref<64x56x56xi8, 12>, 0 : i32>, %arg13: !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>, %arg14: !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>, %arg15: !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>, %arg16: !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>, %arg17: !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>, %arg18: !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>, %arg19: !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>, %arg20: !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>, %arg21: !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>, %arg22: !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>) attributes {func_directive = #hls.fd<pipeline=false, targetInterval=1, dataflow=true>, top_func} {
    %0 = hls.axi.bundle "axi22" : <0 : i32>
    %1 = hls.axi.port %0, %arg22 : <0 : i32>, (!hls.axi<memref<64x28x28xi8, 12>, 0 : i32>) -> memref<64x28x28xi8, 12>
    %2 = hls.axi.bundle "axi21" : <0 : i32>
    %3 = hls.axi.port %2, %arg21 : <0 : i32>, (!hls.axi<memref<64x28x28xi8, 12>, 0 : i32>) -> memref<64x28x28xi8, 12>
    %4 = hls.axi.bundle "axi20" : <0 : i32>
    %5 = hls.axi.port %4, %arg20 : <0 : i32>, (!hls.axi<memref<64x28x28xi8, 12>, 0 : i32>) -> memref<64x28x28xi8, 12>
    %6 = hls.axi.bundle "axi19" : <0 : i32>
    %7 = hls.axi.port %6, %arg19 : <0 : i32>, (!hls.axi<memref<64x28x28xi8, 12>, 0 : i32>) -> memref<64x28x28xi8, 12>
    %8 = hls.axi.bundle "axi18" : <0 : i32>
    %9 = hls.axi.port %8, %arg18 : <0 : i32>, (!hls.axi<memref<64x28x28xi8, 12>, 0 : i32>) -> memref<64x28x28xi8, #map9, 12>
    %10 = hls.axi.bundle "axi17" : <0 : i32>
    %11 = hls.axi.port %10, %arg17 : <0 : i32>, (!hls.axi<memref<64x28x28xi8, 12>, 0 : i32>) -> memref<64x28x28xi8, #map9, 12>
    %12 = hls.axi.bundle "axi16" : <0 : i32>
    %13 = hls.axi.port %12, %arg16 : <0 : i32>, (!hls.axi<memref<64x28x28xi8, 12>, 0 : i32>) -> memref<64x28x28xi8, 12>
    %14 = hls.axi.bundle "axi15" : <0 : i32>
    %15 = hls.axi.port %14, %arg15 : <0 : i32>, (!hls.axi<memref<64x28x28xi8, 12>, 0 : i32>) -> memref<64x28x28xi8, #map9, 12>
    %16 = hls.axi.bundle "axi14" : <0 : i32>
    %17 = hls.axi.port %16, %arg14 : <0 : i32>, (!hls.axi<memref<64x28x28xi8, 12>, 0 : i32>) -> memref<64x28x28xi8, #map9, 12>
    %18 = hls.axi.bundle "axi13" : <0 : i32>
    %19 = hls.axi.port %18, %arg13 : <0 : i32>, (!hls.axi<memref<64x28x28xi8, 12>, 0 : i32>) -> memref<64x28x28xi8, #map9, 12>
    %20 = hls.axi.bundle "axi12" : <0 : i32>
    %21 = hls.axi.port %20, %arg12 : <0 : i32>, (!hls.axi<memref<64x56x56xi8, 12>, 0 : i32>) -> memref<64x56x56xi8, 12>
    %22 = hls.axi.bundle "axi11" : <0 : i32>
    %23 = hls.axi.port %22, %arg11 : <0 : i32>, (!hls.axi<memref<64x56x56xi8, 12>, 0 : i32>) -> memref<64x56x56xi8, #map13, 12>
    %24 = hls.axi.bundle "axi10" : <0 : i32>
    %25 = hls.axi.port %24, %arg10 : <0 : i32>, (!hls.axi<memref<64x56x56xi8, 12>, 0 : i32>) -> memref<64x56x56xi8, 12>
    %26 = hls.axi.bundle "axi9" : <0 : i32>
    %27 = hls.axi.port %26, %arg9 : <0 : i32>, (!hls.axi<memref<64x56x56xi8, 12>, 0 : i32>) -> memref<64x56x56xi8, 12>
    %28 = hls.axi.bundle "axi8" : <0 : i32>
    %29 = hls.axi.port %28, %arg8 : <0 : i32>, (!hls.axi<memref<1000xi8, 12>, 0 : i32>) -> memref<1000xi8, 12>
    %30 = hls.axi.bundle "axi7" : <0 : i32>
    %31 = hls.axi.port %30, %arg7 : <0 : i32>, (!hls.axi<memref<1000xi8, 12>, 0 : i32>) -> memref<1000xi8, 12>
    %32 = hls.axi.bundle "axi6" : <0 : i32>
    %33 = hls.axi.port %32, %arg6 : <0 : i32>, (!hls.axi<memref<64x64x3x3xi8, 12>, 0 : i32>) -> memref<64x64x3x3xi8, 12>
    %34 = hls.axi.bundle "axi5" : <0 : i32>
    %35 = hls.axi.port %34, %arg5 : <0 : i32>, (!hls.axi<memref<64x64x3x3xi8, 12>, 0 : i32>) -> memref<64x64x3x3xi8, 12>
    %36 = hls.axi.bundle "axi4" : <0 : i32>
    %37 = hls.axi.port %36, %arg4 : <0 : i32>, (!hls.axi<memref<64x64xi8, 12>, 0 : i32>) -> memref<64x64xi8, 12>
    %38 = hls.axi.bundle "axi3" : <0 : i32>
    %39 = hls.axi.port %38, %arg3 : <0 : i32>, (!hls.axi<memref<1000x64xi8, 12>, 0 : i32>) -> memref<1000x64xi8, 12>
    %40 = hls.axi.bundle "axi2" : <0 : i32>
    %41 = hls.axi.port %40, %arg2 : <0 : i32>, (!hls.axi<memref<64x56x56xi8, 12>, 0 : i32>) -> memref<64x56x56xi8, 12>
    %42 = hls.axi.bundle "axi1" : <0 : i32>
    %43 = hls.axi.port %42, %arg1 : <0 : i32>, (!hls.axi<memref<64x56x56xi8, 12>, 0 : i32>) -> memref<64x56x56xi8, 12>
    %44 = hls.axi.bundle "axi0" : <0 : i32>
    %45 = hls.axi.port %44, %arg0 : <0 : i32>, (!hls.axi<memref<64x56x56xi8, 12>, 0 : i32>) -> memref<64x56x56xi8, 12>
    %46 = hls.dataflow.stream {depth = 1 : i32} : <i1, 1>
    call @forward_node29(%45, %46, %43) : (memref<64x56x56xi8, 12>, !hls.stream<i1, 1>, memref<64x56x56xi8, 12>) -> ()
    %47 = hls.dataflow.stream {depth = 3 : i32} : <i1, 3>
    %48 = hls.dataflow.stream {depth = 1 : i32} : <i1, 1>
    call @forward_node28(%46, %41, %47, %25, %48, %21) : (!hls.stream<i1, 1>, memref<64x56x56xi8, 12>, !hls.stream<i1, 3>, memref<64x56x56xi8, 12>, !hls.stream<i1, 1>, memref<64x56x56xi8, 12>) -> ()
    %49 = hls.dataflow.stream {depth = 1 : i32} : <i1, 1>
    call @forward_node22(%48, %23, %33, %15, %49, %17) : (!hls.stream<i1, 1>, memref<64x56x56xi8, #map13, 12>, memref<64x64x3x3xi8, 12>, memref<64x28x28xi8, #map9, 12>, !hls.stream<i1, 1>, memref<64x28x28xi8, #map9, 12>) -> ()
    %50 = hls.dataflow.stream {depth = 1 : i32} : <i1, 1>
    call @forward_node16(%35, %49, %19, %9, %50, %11) : (memref<64x64x3x3xi8, 12>, !hls.stream<i1, 1>, memref<64x28x28xi8, #map9, 12>, memref<64x28x28xi8, #map9, 12>, !hls.stream<i1, 1>, memref<64x28x28xi8, #map9, 12>) -> ()
    %51 = hls.dataflow.stream {depth = 1 : i32} : <i1, 1>
    call @forward_node8(%47, %27, %37, %50, %13, %1, %51, %5, %3) : (!hls.stream<i1, 3>, memref<64x56x56xi8, 12>, memref<64x64xi8, 12>, !hls.stream<i1, 1>, memref<64x28x28xi8, 12>, memref<64x28x28xi8, 12>, !hls.stream<i1, 1>, memref<64x28x28xi8, 12>, memref<64x28x28xi8, 12>) -> ()
    %52 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64xi8, 7>
    call @forward_node5(%51, %7, %52) : (!hls.stream<i1, 1>, memref<64x28x28xi8, 12>, memref<64xi8, 7>) -> ()
    call @forward_node0(%52, %39, %31, %29) : (memref<64xi8, 7>, memref<1000x64xi8, 12>, memref<1000xi8, 12>, memref<1000xi8, 12>) -> ()
    return
  }
  func.func @main(%arg0: memref<64x56x56xi8, 12>, %arg1: memref<1000x64xi8, 12>, %arg2: memref<64x64xi8, 12>, %arg3: memref<64x64x3x3xi8, 12>, %arg4: memref<64x64x3x3xi8, 12>, %arg5: memref<1000xi8, 12>) attributes {runtime} {
    %0 = hls.dataflow.buffer {depth = 3 : i32} : memref<64x56x56xi8, 12>
    %1 = hls.dataflow.buffer {depth = 1 : i32} : memref<64x56x56xi8, 12>
    %2 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, 12>
    %3 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, 12>
    %4 = hls.dataflow.buffer {depth = 1 : i32} : memref<64x28x28xi8, 12>
    %5 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, 12>
    %6 = hls.axi.pack %arg0 : (memref<64x56x56xi8, 12>) -> !hls.axi<memref<64x56x56xi8, 12>, 0 : i32>
    %7 = hls.axi.pack %arg0 : (memref<64x56x56xi8, 12>) -> !hls.axi<memref<64x56x56xi8, 12>, 0 : i32>
    %8 = hls.axi.pack %arg0 : (memref<64x56x56xi8, 12>) -> !hls.axi<memref<64x56x56xi8, 12>, 0 : i32>
    %9 = hls.axi.pack %arg1 : (memref<1000x64xi8, 12>) -> !hls.axi<memref<1000x64xi8, 12>, 0 : i32>
    %10 = hls.axi.pack %arg2 : (memref<64x64xi8, 12>) -> !hls.axi<memref<64x64xi8, 12>, 0 : i32>
    %11 = hls.axi.pack %arg3 : (memref<64x64x3x3xi8, 12>) -> !hls.axi<memref<64x64x3x3xi8, 12>, 0 : i32>
    %12 = hls.axi.pack %arg4 : (memref<64x64x3x3xi8, 12>) -> !hls.axi<memref<64x64x3x3xi8, 12>, 0 : i32>
    %13 = hls.axi.pack %arg5 : (memref<1000xi8, 12>) -> !hls.axi<memref<1000xi8, 12>, 0 : i32>
    %14 = hls.axi.pack %arg5 : (memref<1000xi8, 12>) -> !hls.axi<memref<1000xi8, 12>, 0 : i32>
    %15 = hls.axi.pack %0 : (memref<64x56x56xi8, 12>) -> !hls.axi<memref<64x56x56xi8, 12>, 0 : i32>
    %16 = hls.axi.pack %0 : (memref<64x56x56xi8, 12>) -> !hls.axi<memref<64x56x56xi8, 12>, 0 : i32>
    %17 = hls.axi.pack %1 : (memref<64x56x56xi8, 12>) -> !hls.axi<memref<64x56x56xi8, 12>, 0 : i32>
    %18 = hls.axi.pack %1 : (memref<64x56x56xi8, 12>) -> !hls.axi<memref<64x56x56xi8, 12>, 0 : i32>
    %19 = hls.axi.pack %2 : (memref<64x28x28xi8, 12>) -> !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>
    %20 = hls.axi.pack %2 : (memref<64x28x28xi8, 12>) -> !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>
    %21 = hls.axi.pack %2 : (memref<64x28x28xi8, 12>) -> !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>
    %22 = hls.axi.pack %3 : (memref<64x28x28xi8, 12>) -> !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>
    %23 = hls.axi.pack %3 : (memref<64x28x28xi8, 12>) -> !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>
    %24 = hls.axi.pack %3 : (memref<64x28x28xi8, 12>) -> !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>
    %25 = hls.axi.pack %4 : (memref<64x28x28xi8, 12>) -> !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>
    %26 = hls.axi.pack %4 : (memref<64x28x28xi8, 12>) -> !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>
    %27 = hls.axi.pack %5 : (memref<64x28x28xi8, 12>) -> !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>
    %28 = hls.axi.pack %5 : (memref<64x28x28xi8, 12>) -> !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>
    call @forward(%6, %7, %8, %9, %10, %11, %12, %13, %14, %15, %16, %17, %18, %19, %20, %21, %22, %23, %24, %25, %26, %27, %28) : (!hls.axi<memref<64x56x56xi8, 12>, 0 : i32>, !hls.axi<memref<64x56x56xi8, 12>, 0 : i32>, !hls.axi<memref<64x56x56xi8, 12>, 0 : i32>, !hls.axi<memref<1000x64xi8, 12>, 0 : i32>, !hls.axi<memref<64x64xi8, 12>, 0 : i32>, !hls.axi<memref<64x64x3x3xi8, 12>, 0 : i32>, !hls.axi<memref<64x64x3x3xi8, 12>, 0 : i32>, !hls.axi<memref<1000xi8, 12>, 0 : i32>, !hls.axi<memref<1000xi8, 12>, 0 : i32>, !hls.axi<memref<64x56x56xi8, 12>, 0 : i32>, !hls.axi<memref<64x56x56xi8, 12>, 0 : i32>, !hls.axi<memref<64x56x56xi8, 12>, 0 : i32>, !hls.axi<memref<64x56x56xi8, 12>, 0 : i32>, !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>, !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>, !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>, !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>, !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>, !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>, !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>, !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>, !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>, !hls.axi<memref<64x28x28xi8, 12>, 0 : i32>) -> ()
    return
  }
}

// CHECK: #include <algorithm>
// CHECK: #include <ap_axi_sdata.h>
// CHECK: #include <ap_fixed.h>
// CHECK: #include <ap_int.h>
// CHECK: #include <hls_math.h>
// CHECK: #include <hls_stream.h>
// CHECK: #include <math.h>
// CHECK: #include <stdint.h>
// CHECK: #include <string.h>

// CHECK: using namespace std;

// CHECK: void forward_node1(
// CHECK:   ap_int<8> v0[10],
// CHECK:   ap_int<8> v1[1000],
// CHECK:   int v2
// CHECK: ) {	// L25
// CHECK:   #pragma HLS inline
// CHECK:   #pragma HLS bind_storage variable=v0 type=ram_t2p impl=bram

// CHECK:   for (int v3 = 0; v3 < 10; v3 += 1) {	// L26
// CHECK:     #pragma HLS pipeline II=1
// CHECK:     ap_int<8> v4 = v0[v3];	// L27
// CHECK:     v1[(v3 + (v2 * 10))] = v4;	// L28
// CHECK:   }
// CHECK: }

// CHECK: void forward_node2(
// CHECK:   ap_int<8> v5[64],
// CHECK:   ap_int<8> v6[10][16],
// CHECK:   ap_int<8> v7[10],
// CHECK:   ap_int<8> v8[10],
// CHECK:   int v9
// CHECK: ) {	// L32
// CHECK:   #pragma HLS inline
// CHECK:   #pragma HLS bind_storage variable=v5 type=ram_t2p impl=bram

// CHECK:   #pragma HLS bind_storage variable=v6 type=ram_t2p impl=bram

// CHECK:   #pragma HLS bind_storage variable=v7 type=ram_t2p impl=bram

// CHECK:   #pragma HLS bind_storage variable=v8 type=ram_t2p impl=bram

// CHECK:   for (int v10 = 0; v10 < 16; v10 += 1) {	// L34
// CHECK:     #pragma HLS dependence false
// CHECK:     for (int v11 = 0; v11 < 10; v11 += 1) {	// L35
// CHECK:       #pragma HLS pipeline II=1
// CHECK:       ap_int<8> v12 = v7[v11];	// L36
// CHECK:       ap_int<8> v13 = v8[v11];	// L37
// CHECK:       ap_int<8> v14 = (v10 == 0) ? v12 : v13;	// L38
// CHECK:       ap_int<8> v15 = ((v10 + (v9 * 16)) == 0) ? (ap_int<8>)-24 : v14;	// L39
// CHECK:       ap_int<8> v16 = v5[(v10 + (v9 * 16))];	// L40
// CHECK:       ap_int<8> v17 = v6[v11][v10];	// L41
// CHECK:       ap_int<16> v18 = (ap_int<16>)v16 * (ap_int<16>)v17;	// L42
// CHECK:       ap_int<32> v19 = v15;	// L43
// CHECK:       ap_int<32> v20 = v18;	// L44
// CHECK:       ap_int<32> v21 = v19 + v20;	// L45
// CHECK:       ap_int<8> v22 = v21;	// L46
// CHECK:       v8[v11] = v22;	// L47
// CHECK:     }
// CHECK:   }
// CHECK: }

// CHECK: void forward_node3(
// CHECK:   ap_int<8> v23[1000][64],
// CHECK:   ap_int<8> v24[10][16],
// CHECK:   int v25,
// CHECK:   int v26
// CHECK: ) {	// L52
// CHECK:   #pragma HLS inline
// CHECK:   #pragma HLS bind_storage variable=v24 type=ram_t2p impl=bram

// CHECK:   for (int v27 = 0; v27 < 10; v27 += 1) {	// L53
// CHECK:     for (int v28 = 0; v28 < 16; v28 += 1) {	// L54
// CHECK:       #pragma HLS pipeline II=1
// CHECK:       ap_int<8> v29 = v23[(v27 + (v25 * 10))][(v28 + (v26 * 16))];	// L55
// CHECK:       v24[v27][v28] = v29;	// L56
// CHECK:     }
// CHECK:   }
// CHECK: }

// CHECK: void forward_node4(
// CHECK:   ap_int<8> v30[1000],
// CHECK:   ap_int<8> v31[10],
// CHECK:   int v32
// CHECK: ) {	// L61
// CHECK:   #pragma HLS inline
// CHECK:   #pragma HLS bind_storage variable=v31 type=ram_t2p impl=bram

// CHECK:   for (int v33 = 0; v33 < 10; v33 += 1) {	// L62
// CHECK:     #pragma HLS pipeline II=1
// CHECK:     ap_int<8> v34 = v30[(v33 + (v32 * 10))];	// L63
// CHECK:     v31[v33] = v34;	// L64
// CHECK:   }
// CHECK: }

// CHECK: void forward_node0(
// CHECK:   ap_int<8> v35[64],
// CHECK:   ap_int<8> v36[1000][64],
// CHECK:   ap_int<8> v37[1000],
// CHECK:   ap_int<8> v38[1000]
// CHECK: ) {	// L68
// CHECK:   #pragma HLS bind_storage variable=v35 type=ram_t2p impl=bram

// CHECK:   for (int v39 = 0; v39 < 400; v39 += 1) {	// L69
// CHECK:     #pragma HLS dataflow
// CHECK:     int v40 = (v39 % 100);	// L70
// CHECK:     int v41 = (v39 / 100);	// L71
// CHECK:     ap_int<8> v42[10][16];	// L72
// CHECK:     #pragma HLS bind_storage variable=v42 type=ram_t2p impl=bram

// CHECK:     ap_int<8> v43[10];	// L73
// CHECK:     #pragma HLS bind_storage variable=v43 type=ram_t2p impl=bram

// CHECK:     forward_node4(v37, v43, v40);	// L74
// CHECK:     forward_node3(v36, v42, v40, v41);	// L75
// CHECK:     ap_int<8> v44[10];	// L76
// CHECK:     #pragma HLS bind_storage variable=v44 type=ram_t2p impl=bram

// CHECK:     forward_node2(v35, v42, v43, v44, v41);	// L77
// CHECK:     forward_node1(v44, v38, v40);	// L78
// CHECK:   }
// CHECK: }

// CHECK: void forward_node6(
// CHECK:   ap_int<8> v45[16][14][14],
// CHECK:   ap_int<8> v46[64],
// CHECK:   int v47,
// CHECK:   int v48,
// CHECK:   int v49
// CHECK: ) {	// L82
// CHECK:   #pragma HLS inline
// CHECK:   #pragma HLS bind_storage variable=v45 type=ram_t2p impl=bram

// CHECK:   #pragma HLS bind_storage variable=v46 type=ram_t2p impl=bram

// CHECK:   for (int v50 = 0; v50 < 14; v50 += 1) {	// L84
// CHECK:     #pragma HLS dependence false
// CHECK:     for (int v51 = 0; v51 < 14; v51 += 1) {	// L85
// CHECK:       #pragma HLS dependence false
// CHECK:       for (int v52 = 0; v52 < 16; v52 += 1) {	// L86
// CHECK:         #pragma HLS pipeline II=1
// CHECK:         ap_int<8> v53 = v45[v52][v50][v51];	// L87
// CHECK:         ap_int<8> v54 = v46[(v52 + (v47 * 16))];	// L88
// CHECK:         ap_int<32> v55 = v54;	// L89
// CHECK:         ap_int<32> v56 = v53;	// L90
// CHECK:         ap_int<32> v57 = v55 + v56;	// L91
// CHECK:         ap_int<8> v58 = v57;	// L92
// CHECK:         ap_int<8> v59 = v58 / (ap_int<8>)-24;	// L93
// CHECK:         ap_int<8> v60 = ((((-v50) + (v48 * -14)) + 27) == 0 && (((-v51) + (v49 * -14)) + 27) == 0) ? v59 : v58;	// L94
// CHECK:         v46[(v52 + (v47 * 16))] = v60;	// L95
// CHECK:       }
// CHECK:     }
// CHECK:   }
// CHECK: }

// CHECK: void forward_node7(
// CHECK:   ap_int<8> v61[64][28][28],
// CHECK:   ap_int<8> v62[16][14][14],
// CHECK:   int v63,
// CHECK:   int v64,
// CHECK:   int v65
// CHECK: ) {	// L101
// CHECK:   #pragma HLS inline
// CHECK:   #pragma HLS bind_storage variable=v62 type=ram_t2p impl=bram

// CHECK:   for (int v66 = 0; v66 < 16; v66 += 1) {	// L102
// CHECK:     for (int v67 = 0; v67 < 14; v67 += 1) {	// L103
// CHECK:       for (int v68 = 0; v68 < 14; v68 += 1) {	// L104
// CHECK:         #pragma HLS pipeline II=1
// CHECK:         ap_int<8> v69 = v61[(v66 + (v63 * 16))][(v67 + (v64 * 14))][(v68 + (v65 * 14))];	// L105
// CHECK:         v62[v66][v67][v68] = v69;	// L106
// CHECK:       }
// CHECK:     }
// CHECK:   }
// CHECK: }

// CHECK: void forward_node5(
// CHECK:   hls::stream<bool> &v70,
// CHECK:   ap_int<8> v71[64][28][28],
// CHECK:   ap_int<8> v72[64]
// CHECK: ) {	// L112
// CHECK:   #pragma HLS bind_storage variable=v72 type=ram_t2p impl=bram

// CHECK:   v70.read();	// L113
// CHECK:   for (int v73 = 0; v73 < 16; v73 += 1) {	// L114
// CHECK:     #pragma HLS dataflow
// CHECK:     int v74 = (v73 % 4);	// L115
// CHECK:     int v75 = ((v73 / 4) % 2);	// L116
// CHECK:     int v76 = ((v73 / 4) / 2);	// L117
// CHECK:     ap_int<8> v77[16][14][14];	// L118
// CHECK:     #pragma HLS bind_storage variable=v77 type=ram_t2p impl=bram

// CHECK:     forward_node7(v71, v77, v74, v76, v75);	// L119
// CHECK:     forward_node6(v77, v72, v74, v76, v75);	// L120
// CHECK:   }
// CHECK: }

// CHECK: void forward_node9(
// CHECK:   ap_int<8> v78[16][14][14],
// CHECK:   ap_int<8> v79[64][28][28],
// CHECK:   int v80,
// CHECK:   int v81,
// CHECK:   int v82
// CHECK: ) {	// L124
// CHECK:   #pragma HLS inline
// CHECK:   #pragma HLS bind_storage variable=v78 type=ram_t2p impl=bram

// CHECK:   for (int v83 = 0; v83 < 16; v83 += 1) {	// L125
// CHECK:     for (int v84 = 0; v84 < 14; v84 += 1) {	// L126
// CHECK:       for (int v85 = 0; v85 < 14; v85 += 1) {	// L127
// CHECK:         #pragma HLS pipeline II=1
// CHECK:         ap_int<8> v86 = v78[v83][v84][v85];	// L128
// CHECK:         v79[(v83 + (v80 * 16))][(v84 + (v81 * 14))][(v85 + (v82 * 14))] = v86;	// L129
// CHECK:       }
// CHECK:     }
// CHECK:   }
// CHECK: }

// CHECK: void forward_node10(
// CHECK:   ap_int<8> v87[16][14][14],
// CHECK:   ap_int<8> v88[64][28][28],
// CHECK:   int v89,
// CHECK:   int v90,
// CHECK:   int v91
// CHECK: ) {	// L135
// CHECK:   #pragma HLS inline
// CHECK:   #pragma HLS bind_storage variable=v87 type=ram_t2p impl=bram

// CHECK:   for (int v92 = 0; v92 < 16; v92 += 1) {	// L136
// CHECK:     for (int v93 = 0; v93 < 14; v93 += 1) {	// L137
// CHECK:       for (int v94 = 0; v94 < 14; v94 += 1) {	// L138
// CHECK:         #pragma HLS pipeline II=1
// CHECK:         ap_int<8> v95 = v87[v92][v93][v94];	// L139
// CHECK:         v88[(v92 + (v89 * 16))][(v93 + (v90 * 14))][(v94 + (v91 * 14))] = v95;	// L140
// CHECK:       }
// CHECK:     }
// CHECK:   }
// CHECK: }

// CHECK: void forward_node11(
// CHECK:   ap_int<8> v96[16][14][14],
// CHECK:   ap_int<8> v97[16][14][14],
// CHECK:   ap_int<8> v98[16][16],
// CHECK:   ap_int<8> v99[16][14][14],
// CHECK:   ap_int<8> v100[16][14][14],
// CHECK:   ap_int<8> v101[16][14][14],
// CHECK:   int v102
// CHECK: ) {	// L146
// CHECK:   #pragma HLS inline
// CHECK:   #pragma HLS bind_storage variable=v96 type=ram_t2p impl=bram

// CHECK:   #pragma HLS bind_storage variable=v97 type=ram_t2p impl=bram

// CHECK:   #pragma HLS bind_storage variable=v98 type=ram_t2p impl=bram

// CHECK:   #pragma HLS bind_storage variable=v99 type=ram_t2p impl=bram

// CHECK:   #pragma HLS bind_storage variable=v100 type=ram_t2p impl=bram

// CHECK:   #pragma HLS bind_storage variable=v101 type=ram_t2p impl=bram

// CHECK:   for (int v103 = 0; v103 < 16; v103 += 1) {	// L148
// CHECK:     #pragma HLS dependence false
// CHECK:     for (int v104 = 0; v104 < 16; v104 += 1) {	// L149
// CHECK:       for (int v105 = 0; v105 < 14; v105 += 1) {	// L150
// CHECK:         for (int v106 = 0; v106 < 14; v106 += 1) {	// L151
// CHECK:           #pragma HLS pipeline II=1
// CHECK:           ap_int<8> v107 = v97[v103][v105][v106];	// L152
// CHECK:           ap_int<8> v108 = v98[v104][v103];	// L153
// CHECK:           ap_int<8> v109 = v99[v104][v105][v106];	// L154
// CHECK:           ap_int<8> v110 = v101[v104][v105][v106];	// L155
// CHECK:           ap_int<8> v111 = (v103 == 0) ? v109 : v110;	// L156
// CHECK:           ap_int<16> v112 = (ap_int<16>)v107 * (ap_int<16>)v108;	// L157
// CHECK:           ap_int<32> v113 = v111;	// L158
// CHECK:           ap_int<32> v114 = v112;	// L159
// CHECK:           ap_int<32> v115 = v113 + v114;	// L160
// CHECK:           ap_int<8> v116 = v115;	// L161
// CHECK:           v101[v104][v105][v106] = v116;	// L162
// CHECK:           ap_int<8> v117 = v96[v104][v105][v106];	// L163
// CHECK:           ap_int<32> v118 = v117;	// L164
// CHECK:           ap_int<32> v119 = v116;	// L165
// CHECK:           ap_int<32> v120 = v118 + v119;	// L166
// CHECK:           ap_int<8> v121 = v120;	// L167
// CHECK:           bool v122 = v121 > (ap_int<8>)-24;	// L168
// CHECK:           ap_int<8> v123 = v122 ? v121 : (ap_int<8>)-24;	// L169
// CHECK:           if ((((-v103) + (v102 * -16)) + 63) == 0) {	// L170
// CHECK:             v100[v104][v105][v106] = v123;	// L171
// CHECK:           }
// CHECK:         }
// CHECK:       }
// CHECK:     }
// CHECK:   }
// CHECK: }

// CHECK: void forward_node12(
// CHECK:   ap_int<8> v124[64][28][28],
// CHECK:   ap_int<8> v125[16][14][14],
// CHECK:   int v126,
// CHECK:   int v127,
// CHECK:   int v128
// CHECK: ) {	// L179
// CHECK:   #pragma HLS inline
// CHECK:   #pragma HLS bind_storage variable=v125 type=ram_t2p impl=bram

// CHECK:   for (int v129 = 0; v129 < 16; v129 += 1) {	// L180
// CHECK:     for (int v130 = 0; v130 < 14; v130 += 1) {	// L181
// CHECK:       for (int v131 = 0; v131 < 14; v131 += 1) {	// L182
// CHECK:         #pragma HLS pipeline II=1
// CHECK:         ap_int<8> v132 = v124[(v129 + (v126 * 16))][(v130 + (v127 * 14))][(v131 + (v128 * 14))];	// L183
// CHECK:         v125[v129][v130][v131] = v132;	// L184
// CHECK:       }
// CHECK:     }
// CHECK:   }
// CHECK: }

// CHECK: void forward_node13(
// CHECK:   ap_int<8> v133[64][28][28],
// CHECK:   ap_int<8> v134[16][14][14],
// CHECK:   int v135,
// CHECK:   int v136,
// CHECK:   int v137
// CHECK: ) {	// L190
// CHECK:   #pragma HLS inline
// CHECK:   #pragma HLS bind_storage variable=v134 type=ram_t2p impl=bram

// CHECK:   for (int v138 = 0; v138 < 16; v138 += 1) {	// L191
// CHECK:     for (int v139 = 0; v139 < 14; v139 += 1) {	// L192
// CHECK:       for (int v140 = 0; v140 < 14; v140 += 1) {	// L193
// CHECK:         #pragma HLS pipeline II=1
// CHECK:         ap_int<8> v141 = v133[(v138 + (v135 * 16))][(v139 + (v136 * 14))][(v140 + (v137 * 14))];	// L194
// CHECK:         v134[v138][v139][v140] = v141;	// L195
// CHECK:       }
// CHECK:     }
// CHECK:   }
// CHECK: }

// CHECK: void forward_node14(
// CHECK:   ap_int<8> v142[64][64],
// CHECK:   ap_int<8> v143[16][16],
// CHECK:   int v144,
// CHECK:   int v145
// CHECK: ) {	// L201
// CHECK:   #pragma HLS inline
// CHECK:   #pragma HLS bind_storage variable=v143 type=ram_t2p impl=bram

// CHECK:   for (int v146 = 0; v146 < 16; v146 += 1) {	// L202
// CHECK:     for (int v147 = 0; v147 < 16; v147 += 1) {	// L203
// CHECK:       #pragma HLS pipeline II=1
// CHECK:       ap_int<8> v148 = v142[(v146 + (v144 * 16))][(v147 + (v145 * 16))];	// L204
// CHECK:       v143[v146][v147] = v148;	// L205
// CHECK:     }
// CHECK:   }
// CHECK: }

// CHECK: void forward_node15(
// CHECK:   ap_int<8> v149[64][56][56],
// CHECK:   ap_int<8> v150[16][14][14],
// CHECK:   int v151,
// CHECK:   int v152,
// CHECK:   int v153
// CHECK: ) {	// L210
// CHECK:   #pragma HLS inline
// CHECK:   #pragma HLS bind_storage variable=v150 type=ram_t2p impl=bram

// CHECK:   for (int v154 = 0; v154 < 16; v154 += 1) {	// L211
// CHECK:     for (int v155 = 0; v155 < 14; v155 += 1) {	// L212
// CHECK:       for (int v156 = 0; v156 < 14; v156 += 1) {	// L213
// CHECK:         #pragma HLS pipeline II=1
// CHECK:         ap_int<8> v157 = v149[(v154 + (v151 * 16))][((v155 * 2) + (v152 * 28))][((v156 * 2) + (v153 * 28))];	// L214
// CHECK:         v150[v154][v155][v156] = v157;	// L215
// CHECK:       }
// CHECK:     }
// CHECK:   }
// CHECK: }

// CHECK: void forward_node8(
// CHECK:   hls::stream<bool> &v158,
// CHECK:   ap_int<8> v159[64][56][56],
// CHECK:   ap_int<8> v160[64][64],
// CHECK:   hls::stream<bool> &v161,
// CHECK:   ap_int<8> v162[64][28][28],
// CHECK:   ap_int<8> v163[64][28][28],
// CHECK:   hls::stream<bool> &v164,
// CHECK:   ap_int<8> v165[64][28][28],
// CHECK:   ap_int<8> v166[64][28][28]
// CHECK: ) {	// L221
// CHECK:   v161.read();	// L223
// CHECK:   v158.read();	// L224
// CHECK:   for (int v167 = 0; v167 < 64; v167 += 1) {	// L225
// CHECK:     #pragma HLS dataflow
// CHECK:     int v168 = (v167 % 2);	// L226
// CHECK:     int v169 = ((v167 / 2) % 2);	// L227
// CHECK:     int v170 = (((v167 / 2) / 2) % 4);	// L228
// CHECK:     int v171 = (((v167 / 2) / 2) / 4);	// L229
// CHECK:     ap_int<8> v172[16][14][14];	// L230
// CHECK:     #pragma HLS bind_storage variable=v172 type=ram_t2p impl=bram

// CHECK:     ap_int<8> v173[16][14][14];	// L231
// CHECK:     #pragma HLS bind_storage variable=v173 type=ram_t2p impl=bram

// CHECK:     ap_int<8> v174[16][14][14];	// L232
// CHECK:     #pragma HLS bind_storage variable=v174 type=ram_t2p impl=bram

// CHECK:     ap_int<8> v175[16][16];	// L233
// CHECK:     #pragma HLS bind_storage variable=v175 type=ram_t2p impl=bram

// CHECK:     ap_int<8> v176[16][14][14];	// L234
// CHECK:     #pragma HLS bind_storage variable=v176 type=ram_t2p impl=bram

// CHECK:     forward_node15(v159, v176, v171, v169, v168);	// L235
// CHECK:     forward_node14(v160, v175, v170, v171);	// L236
// CHECK:     forward_node13(v163, v174, v170, v169, v168);	// L237
// CHECK:     forward_node12(v162, v173, v170, v169, v168);	// L238
// CHECK:     ap_int<8> v177[16][14][14];	// L239
// CHECK:     #pragma HLS bind_storage variable=v177 type=ram_t2p impl=bram

// CHECK:     forward_node11(v173, v176, v175, v174, v172, v177, v171);	// L240
// CHECK:     forward_node10(v177, v166, v170, v169, v168);	// L241
// CHECK:     forward_node9(v172, v165, v170, v169, v168);	// L242
// CHECK:   }
// CHECK:   v164.write(true);	// L244
// CHECK: }

// CHECK: void forward_node17(
// CHECK:   ap_int<8> v178[16][14][14],
// CHECK:   ap_int<8> v179[64][28][28],
// CHECK:   int v180,
// CHECK:   int v181,
// CHECK:   int v182
// CHECK: ) {	// L247
// CHECK:   #pragma HLS inline
// CHECK:   #pragma HLS array_partition variable=v178 cyclic factor=2 dim=2
// CHECK:   #pragma HLS array_partition variable=v178 cyclic factor=2 dim=3
// CHECK:   #pragma HLS bind_storage variable=v178 type=ram_t2p impl=bram

// CHECK:   #pragma HLS array_partition variable=v179 cyclic factor=2 dim=2
// CHECK:   #pragma HLS array_partition variable=v179 cyclic factor=2 dim=3

// CHECK:   for (int v183 = 0; v183 < 16; v183 += 1) {	// L248
// CHECK:     for (int v184 = 0; v184 < 14; v184 += 2) {	// L249
// CHECK:       for (int v185 = 0; v185 < 14; v185 += 2) {	// L250
// CHECK:         #pragma HLS pipeline II=1
// CHECK:         ap_int<8> v186 = v178[v183][v184][v185];	// L251
// CHECK:         v179[(v183 + (v180 * 16))][(v184 + (v181 * 14))][(v185 + (v182 * 14))] = v186;	// L252
// CHECK:         ap_int<8> v187 = v178[v183][v184][(v185 + 1)];	// L253
// CHECK:         v179[(v183 + (v180 * 16))][(v184 + (v181 * 14))][((v185 + (v182 * 14)) + 1)] = v187;	// L254
// CHECK:         ap_int<8> v188 = v178[v183][(v184 + 1)][v185];	// L255
// CHECK:         v179[(v183 + (v180 * 16))][((v184 + (v181 * 14)) + 1)][(v185 + (v182 * 14))] = v188;	// L256
// CHECK:         ap_int<8> v189 = v178[v183][(v184 + 1)][(v185 + 1)];	// L257
// CHECK:         v179[(v183 + (v180 * 16))][((v184 + (v181 * 14)) + 1)][((v185 + (v182 * 14)) + 1)] = v189;	// L258
// CHECK:       }
// CHECK:     }
// CHECK:   }
// CHECK: }

// CHECK: void forward_node18(
// CHECK:   ap_int<8> v190[16][14][14],
// CHECK:   ap_int<8> v191[16][16],
// CHECK:   ap_int<8> v192[16][14][14],
// CHECK:   ap_int<8> v193[16][14][14]
// CHECK: ) {	// L264
// CHECK:   #pragma HLS inline
// CHECK:   #pragma HLS array_partition variable=v190 cyclic factor=2 dim=2
// CHECK:   #pragma HLS array_partition variable=v190 cyclic factor=2 dim=3
// CHECK:   #pragma HLS bind_storage variable=v190 type=ram_t2p impl=bram

// CHECK:   #pragma HLS bind_storage variable=v191 type=ram_t2p impl=bram

// CHECK:   #pragma HLS array_partition variable=v192 cyclic factor=2 dim=2
// CHECK:   #pragma HLS array_partition variable=v192 cyclic factor=2 dim=3
// CHECK:   #pragma HLS bind_storage variable=v192 type=ram_t2p impl=bram

// CHECK:   #pragma HLS array_partition variable=v193 cyclic factor=2 dim=2
// CHECK:   #pragma HLS array_partition variable=v193 cyclic factor=2 dim=3
// CHECK:   #pragma HLS bind_storage variable=v193 type=ram_t2p impl=bram

// CHECK:   for (int v194 = 0; v194 < 16; v194 += 1) {	// L265
// CHECK:     #pragma HLS dependence false
// CHECK:     for (int v195 = 0; v195 < 16; v195 += 1) {	// L266
// CHECK:       for (int v196 = 0; v196 < 14; v196 += 2) {	// L267
// CHECK:         for (int v197 = 0; v197 < 14; v197 += 2) {	// L268
// CHECK:           #pragma HLS pipeline II=1
// CHECK:           ap_int<8> v198 = v190[v194][v196][v197];	// L269
// CHECK:           ap_int<8> v199 = v191[v195][v194];	// L270
// CHECK:           ap_int<8> v200 = v192[v195][v196][v197];	// L271
// CHECK:           ap_int<8> v201 = v193[v195][v196][v197];	// L272
// CHECK:           ap_int<8> v202 = (v194 == 0) ? v200 : v201;	// L273
// CHECK:           ap_int<16> v203 = (ap_int<16>)v198 * (ap_int<16>)v199;	// L274
// CHECK:           ap_int<32> v204 = v202;	// L275
// CHECK:           ap_int<32> v205 = v203;	// L276
// CHECK:           ap_int<32> v206 = v204 + v205;	// L277
// CHECK:           ap_int<8> v207 = v206;	// L278
// CHECK:           v193[v195][v196][v197] = v207;	// L279
// CHECK:           ap_int<8> v208 = v190[v194][v196][(v197 + 1)];	// L280
// CHECK:           ap_int<8> v209 = v192[v195][v196][(v197 + 1)];	// L281
// CHECK:           ap_int<8> v210 = v193[v195][v196][(v197 + 1)];	// L282
// CHECK:           ap_int<8> v211 = (v194 == 0) ? v209 : v210;	// L283
// CHECK:           ap_int<16> v212 = (ap_int<16>)v208 * (ap_int<16>)v199;	// L284
// CHECK:           ap_int<32> v213 = v211;	// L285
// CHECK:           ap_int<32> v214 = v212;	// L286
// CHECK:           ap_int<32> v215 = v213 + v214;	// L287
// CHECK:           ap_int<8> v216 = v215;	// L288
// CHECK:           v193[v195][v196][(v197 + 1)] = v216;	// L289
// CHECK:           ap_int<8> v217 = v190[v194][(v196 + 1)][v197];	// L290
// CHECK:           ap_int<8> v218 = v192[v195][(v196 + 1)][v197];	// L291
// CHECK:           ap_int<8> v219 = v193[v195][(v196 + 1)][v197];	// L292
// CHECK:           ap_int<8> v220 = (v194 == 0) ? v218 : v219;	// L293
// CHECK:           ap_int<16> v221 = (ap_int<16>)v217 * (ap_int<16>)v199;	// L294
// CHECK:           ap_int<32> v222 = v220;	// L295
// CHECK:           ap_int<32> v223 = v221;	// L296
// CHECK:           ap_int<32> v224 = v222 + v223;	// L297
// CHECK:           ap_int<8> v225 = v224;	// L298
// CHECK:           v193[v195][(v196 + 1)][v197] = v225;	// L299
// CHECK:           ap_int<8> v226 = v190[v194][(v196 + 1)][(v197 + 1)];	// L300
// CHECK:           ap_int<8> v227 = v192[v195][(v196 + 1)][(v197 + 1)];	// L301
// CHECK:           ap_int<8> v228 = v193[v195][(v196 + 1)][(v197 + 1)];	// L302
// CHECK:           ap_int<8> v229 = (v194 == 0) ? v227 : v228;	// L303
// CHECK:           ap_int<16> v230 = (ap_int<16>)v226 * (ap_int<16>)v199;	// L304
// CHECK:           ap_int<32> v231 = v229;	// L305
// CHECK:           ap_int<32> v232 = v230;	// L306
// CHECK:           ap_int<32> v233 = v231 + v232;	// L307
// CHECK:           ap_int<8> v234 = v233;	// L308
// CHECK:           v193[v195][(v196 + 1)][(v197 + 1)] = v234;	// L309
// CHECK:         }
// CHECK:       }
// CHECK:     }
// CHECK:   }
// CHECK: }

// CHECK: void forward_node19(
// CHECK:   ap_int<8> v235[64][28][28],
// CHECK:   ap_int<8> v236[16][14][14],
// CHECK:   int v237,
// CHECK:   int v238,
// CHECK:   int v239
// CHECK: ) {	// L316
// CHECK:   #pragma HLS inline
// CHECK:   #pragma HLS array_partition variable=v235 cyclic factor=2 dim=2
// CHECK:   #pragma HLS array_partition variable=v235 cyclic factor=2 dim=3

// CHECK:   #pragma HLS array_partition variable=v236 cyclic factor=2 dim=2
// CHECK:   #pragma HLS array_partition variable=v236 cyclic factor=2 dim=3
// CHECK:   #pragma HLS bind_storage variable=v236 type=ram_t2p impl=bram

// CHECK:   for (int v240 = 0; v240 < 16; v240 += 1) {	// L317
// CHECK:     for (int v241 = 0; v241 < 14; v241 += 2) {	// L318
// CHECK:       for (int v242 = 0; v242 < 14; v242 += 2) {	// L319
// CHECK:         #pragma HLS pipeline II=1
// CHECK:         ap_int<8> v243 = v235[(v240 + (v237 * 16))][(v241 + (v238 * 14))][(v242 + (v239 * 14))];	// L320
// CHECK:         v236[v240][v241][v242] = v243;	// L321
// CHECK:         ap_int<8> v244 = v235[(v240 + (v237 * 16))][(v241 + (v238 * 14))][((v242 + (v239 * 14)) + 1)];	// L322
// CHECK:         v236[v240][v241][(v242 + 1)] = v244;	// L323
// CHECK:         ap_int<8> v245 = v235[(v240 + (v237 * 16))][((v241 + (v238 * 14)) + 1)][(v242 + (v239 * 14))];	// L324
// CHECK:         v236[v240][(v241 + 1)][v242] = v245;	// L325
// CHECK:         ap_int<8> v246 = v235[(v240 + (v237 * 16))][((v241 + (v238 * 14)) + 1)][((v242 + (v239 * 14)) + 1)];	// L326
// CHECK:         v236[v240][(v241 + 1)][(v242 + 1)] = v246;	// L327
// CHECK:       }
// CHECK:     }
// CHECK:   }
// CHECK: }

// CHECK: void forward_node20(
// CHECK:   ap_int<8> v247[64][64][3][3],
// CHECK:   ap_int<8> v248[16][16],
// CHECK:   int v249,
// CHECK:   int v250,
// CHECK:   int v251,
// CHECK:   int v252
// CHECK: ) {	// L333
// CHECK:   #pragma HLS inline
// CHECK:   #pragma HLS bind_storage variable=v248 type=ram_t2p impl=bram

// CHECK:   for (int v253 = 0; v253 < 16; v253 += 1) {	// L334
// CHECK:     for (int v254 = 0; v254 < 16; v254 += 1) {	// L335
// CHECK:       #pragma HLS pipeline II=1
// CHECK:       ap_int<8> v255 = v247[(v253 + (v249 * 16))][(v254 + (v250 * 16))][v251][v252];	// L336
// CHECK:       v248[v253][v254] = v255;	// L337
// CHECK:     }
// CHECK:   }
// CHECK: }

// CHECK: void forward_node21(
// CHECK:   ap_int<8> v256[64][28][28],
// CHECK:   ap_int<8> v257[16][14][14],
// CHECK:   int v258,
// CHECK:   int v259,
// CHECK:   int v260,
// CHECK:   int v261,
// CHECK:   int v262
// CHECK: ) {	// L342
// CHECK:   #pragma HLS inline
// CHECK:   #pragma HLS array_partition variable=v256 cyclic factor=2 dim=2
// CHECK:   #pragma HLS array_partition variable=v256 cyclic factor=2 dim=3

// CHECK:   #pragma HLS array_partition variable=v257 cyclic factor=2 dim=2
// CHECK:   #pragma HLS array_partition variable=v257 cyclic factor=2 dim=3
// CHECK:   #pragma HLS bind_storage variable=v257 type=ram_t2p impl=bram

// CHECK:   for (int v263 = 0; v263 < 16; v263 += 1) {	// L343
// CHECK:     for (int v264 = 0; v264 < 14; v264 += 2) {	// L344
// CHECK:       for (int v265 = 0; v265 < 14; v265 += 2) {	// L345
// CHECK:         #pragma HLS pipeline II=1
// CHECK:         ap_int<8> v266 = v256[(v263 + (v258 * 16))][(((v264 + v259) + (v260 * 14)) - 1)][(((v265 + v261) + (v262 * 14)) - 1)];	// L346
// CHECK:         v257[v263][v264][v265] = v266;	// L347
// CHECK:         ap_int<8> v267 = v256[(v263 + (v258 * 16))][(((v264 + v259) + (v260 * 14)) - 1)][((v265 + v261) + (v262 * 14))];	// L348
// CHECK:         v257[v263][v264][(v265 + 1)] = v267;	// L349
// CHECK:         ap_int<8> v268 = v256[(v263 + (v258 * 16))][((v264 + v259) + (v260 * 14))][(((v265 + v261) + (v262 * 14)) - 1)];	// L350
// CHECK:         v257[v263][(v264 + 1)][v265] = v268;	// L351
// CHECK:         ap_int<8> v269 = v256[(v263 + (v258 * 16))][((v264 + v259) + (v260 * 14))][((v265 + v261) + (v262 * 14))];	// L352
// CHECK:         v257[v263][(v264 + 1)][(v265 + 1)] = v269;	// L353
// CHECK:       }
// CHECK:     }
// CHECK:   }
// CHECK: }

// CHECK: void forward_node16(
// CHECK:   ap_int<8> v270[64][64][3][3],
// CHECK:   hls::stream<bool> &v271,
// CHECK:   ap_int<8> v272[64][28][28],
// CHECK:   ap_int<8> v273[64][28][28],
// CHECK:   hls::stream<bool> &v274,
// CHECK:   ap_int<8> v275[64][28][28]
// CHECK: ) {	// L359
// CHECK:   #pragma HLS array_partition variable=v272 cyclic factor=2 dim=2
// CHECK:   #pragma HLS array_partition variable=v272 cyclic factor=2 dim=3

// CHECK:   #pragma HLS array_partition variable=v273 cyclic factor=2 dim=2
// CHECK:   #pragma HLS array_partition variable=v273 cyclic factor=2 dim=3

// CHECK:   #pragma HLS array_partition variable=v275 cyclic factor=2 dim=2
// CHECK:   #pragma HLS array_partition variable=v275 cyclic factor=2 dim=3

// CHECK:   v271.read();	// L361
// CHECK:   for (int v276 = 0; v276 < 576; v276 += 1) {	// L362
// CHECK:     #pragma HLS dataflow
// CHECK:     int v277 = (v276 % 2);	// L363
// CHECK:     int v278 = ((v276 / 2) % 2);	// L364
// CHECK:     int v279 = (((v276 / 2) / 2) % 4);	// L365
// CHECK:     int v280 = ((((v276 / 2) / 2) / 4) % 3);	// L366
// CHECK:     int v281 = (((((v276 / 2) / 2) / 4) / 3) % 3);	// L367
// CHECK:     int v282 = (((((v276 / 2) / 2) / 4) / 3) / 3);	// L368
// CHECK:     ap_int<8> v283[16][14][14];	// L369
// CHECK:     #pragma HLS array_partition variable=v283 cyclic factor=2 dim=2
// CHECK:     #pragma HLS array_partition variable=v283 cyclic factor=2 dim=3
// CHECK:     #pragma HLS bind_storage variable=v283 type=ram_t2p impl=bram

// CHECK:     ap_int<8> v284[16][16];	// L370
// CHECK:     #pragma HLS bind_storage variable=v284 type=ram_t2p impl=bram

// CHECK:     ap_int<8> v285[16][14][14];	// L371
// CHECK:     #pragma HLS array_partition variable=v285 cyclic factor=2 dim=2
// CHECK:     #pragma HLS array_partition variable=v285 cyclic factor=2 dim=3
// CHECK:     #pragma HLS bind_storage variable=v285 type=ram_t2p impl=bram

// CHECK:     forward_node21(v272, v285, v282, v281, v278, v280, v277);	// L372
// CHECK:     forward_node20(v270, v284, v279, v282, v281, v280);	// L373
// CHECK:     forward_node19(v273, v283, v279, v278, v277);	// L374
// CHECK:     ap_int<8> v286[16][14][14];	// L375
// CHECK:     #pragma HLS array_partition variable=v286 cyclic factor=2 dim=2
// CHECK:     #pragma HLS array_partition variable=v286 cyclic factor=2 dim=3
// CHECK:     #pragma HLS bind_storage variable=v286 type=ram_t2p impl=bram

// CHECK:     forward_node18(v285, v284, v283, v286);	// L376
// CHECK:     forward_node17(v286, v275, v279, v278, v277);	// L377
// CHECK:   }
// CHECK:   v274.write(true);	// L379
// CHECK: }

// CHECK: void forward_node23(
// CHECK:   ap_int<8> v287[16][14][14],
// CHECK:   ap_int<8> v288[64][28][28],
// CHECK:   int v289,
// CHECK:   int v290,
// CHECK:   int v291
// CHECK: ) {	// L382
// CHECK:   #pragma HLS inline
// CHECK:   #pragma HLS array_partition variable=v287 cyclic factor=2 dim=2
// CHECK:   #pragma HLS array_partition variable=v287 cyclic factor=2 dim=3
// CHECK:   #pragma HLS bind_storage variable=v287 type=ram_t2p impl=bram

// CHECK:   #pragma HLS array_partition variable=v288 cyclic factor=2 dim=2
// CHECK:   #pragma HLS array_partition variable=v288 cyclic factor=2 dim=3

// CHECK:   for (int v292 = 0; v292 < 16; v292 += 1) {	// L383
// CHECK:     for (int v293 = 0; v293 < 14; v293 += 2) {	// L384
// CHECK:       for (int v294 = 0; v294 < 14; v294 += 2) {	// L385
// CHECK:         #pragma HLS pipeline II=1
// CHECK:         ap_int<8> v295 = v287[v292][v293][v294];	// L386
// CHECK:         v288[(v292 + (v289 * 16))][(v293 + (v290 * 14))][(v294 + (v291 * 14))] = v295;	// L387
// CHECK:         ap_int<8> v296 = v287[v292][v293][(v294 + 1)];	// L388
// CHECK:         v288[(v292 + (v289 * 16))][(v293 + (v290 * 14))][((v294 + (v291 * 14)) + 1)] = v296;	// L389
// CHECK:         ap_int<8> v297 = v287[v292][(v293 + 1)][v294];	// L390
// CHECK:         v288[(v292 + (v289 * 16))][((v293 + (v290 * 14)) + 1)][(v294 + (v291 * 14))] = v297;	// L391
// CHECK:         ap_int<8> v298 = v287[v292][(v293 + 1)][(v294 + 1)];	// L392
// CHECK:         v288[(v292 + (v289 * 16))][((v293 + (v290 * 14)) + 1)][((v294 + (v291 * 14)) + 1)] = v298;	// L393
// CHECK:       }
// CHECK:     }
// CHECK:   }
// CHECK: }

// CHECK: void forward_node24(
// CHECK:   ap_int<8> v299[16][14][14],
// CHECK:   ap_int<8> v300[16][16],
// CHECK:   ap_int<8> v301[16][14][14],
// CHECK:   ap_int<8> v302[16][14][14],
// CHECK:   int v303,
// CHECK:   int v304,
// CHECK:   int v305
// CHECK: ) {	// L399
// CHECK:   #pragma HLS inline
// CHECK:   #pragma HLS array_partition variable=v299 cyclic factor=2 dim=2
// CHECK:   #pragma HLS array_partition variable=v299 cyclic factor=2 dim=3
// CHECK:   #pragma HLS bind_storage variable=v299 type=ram_t2p impl=bram

// CHECK:   #pragma HLS bind_storage variable=v300 type=ram_t2p impl=bram

// CHECK:   #pragma HLS array_partition variable=v301 cyclic factor=2 dim=2
// CHECK:   #pragma HLS array_partition variable=v301 cyclic factor=2 dim=3
// CHECK:   #pragma HLS bind_storage variable=v301 type=ram_t2p impl=bram

// CHECK:   #pragma HLS array_partition variable=v302 cyclic factor=2 dim=2
// CHECK:   #pragma HLS array_partition variable=v302 cyclic factor=2 dim=3
// CHECK:   #pragma HLS bind_storage variable=v302 type=ram_t2p impl=bram

// CHECK:   for (int v306 = 0; v306 < 16; v306 += 1) {	// L401
// CHECK:     #pragma HLS dependence false
// CHECK:     for (int v307 = 0; v307 < 16; v307 += 1) {	// L402
// CHECK:       for (int v308 = 0; v308 < 14; v308 += 2) {	// L403
// CHECK:         for (int v309 = 0; v309 < 14; v309 += 2) {	// L404
// CHECK:           #pragma HLS pipeline II=1
// CHECK:           ap_int<8> v310 = v299[v306][v308][v309];	// L405
// CHECK:           ap_int<8> v311 = v300[v307][v306];	// L406
// CHECK:           ap_int<8> v312 = v301[v307][v308][v309];	// L407
// CHECK:           ap_int<8> v313 = v302[v307][v308][v309];	// L408
// CHECK:           ap_int<8> v314 = (v306 == 0) ? v312 : v313;	// L409
// CHECK:           ap_int<16> v315 = (ap_int<16>)v310 * (ap_int<16>)v311;	// L410
// CHECK:           ap_int<32> v316 = v314;	// L411
// CHECK:           ap_int<32> v317 = v315;	// L412
// CHECK:           ap_int<32> v318 = v316 + v317;	// L413
// CHECK:           ap_int<8> v319 = v318;	// L414
// CHECK:           bool v320 = v319 > (ap_int<8>)-24;	// L415
// CHECK:           ap_int<8> v321 = v320 ? v319 : (ap_int<8>)-24;	// L416
// CHECK:           ap_int<8> v322 = ((((-v306) + (v304 * -16)) + 63) == 0 && ((-v305) + 2) == 0 && ((-v303) + 2) == 0) ? v321 : v319;	// L417
// CHECK:           v302[v307][v308][v309] = v322;	// L418
// CHECK:           ap_int<8> v323 = v299[v306][v308][(v309 + 1)];	// L419
// CHECK:           ap_int<8> v324 = v301[v307][v308][(v309 + 1)];	// L420
// CHECK:           ap_int<8> v325 = v302[v307][v308][(v309 + 1)];	// L421
// CHECK:           ap_int<8> v326 = (v306 == 0) ? v324 : v325;	// L422
// CHECK:           ap_int<16> v327 = (ap_int<16>)v323 * (ap_int<16>)v311;	// L423
// CHECK:           ap_int<32> v328 = v326;	// L424
// CHECK:           ap_int<32> v329 = v327;	// L425
// CHECK:           ap_int<32> v330 = v328 + v329;	// L426
// CHECK:           ap_int<8> v331 = v330;	// L427
// CHECK:           bool v332 = v331 > (ap_int<8>)-24;	// L428
// CHECK:           ap_int<8> v333 = v332 ? v331 : (ap_int<8>)-24;	// L429
// CHECK:           ap_int<8> v334 = ((((-v306) + (v304 * -16)) + 63) == 0 && ((-v305) + 2) == 0 && ((-v303) + 2) == 0) ? v333 : v331;	// L430
// CHECK:           v302[v307][v308][(v309 + 1)] = v334;	// L431
// CHECK:           ap_int<8> v335 = v299[v306][(v308 + 1)][v309];	// L432
// CHECK:           ap_int<8> v336 = v301[v307][(v308 + 1)][v309];	// L433
// CHECK:           ap_int<8> v337 = v302[v307][(v308 + 1)][v309];	// L434
// CHECK:           ap_int<8> v338 = (v306 == 0) ? v336 : v337;	// L435
// CHECK:           ap_int<16> v339 = (ap_int<16>)v335 * (ap_int<16>)v311;	// L436
// CHECK:           ap_int<32> v340 = v338;	// L437
// CHECK:           ap_int<32> v341 = v339;	// L438
// CHECK:           ap_int<32> v342 = v340 + v341;	// L439
// CHECK:           ap_int<8> v343 = v342;	// L440
// CHECK:           bool v344 = v343 > (ap_int<8>)-24;	// L441
// CHECK:           ap_int<8> v345 = v344 ? v343 : (ap_int<8>)-24;	// L442
// CHECK:           ap_int<8> v346 = ((((-v306) + (v304 * -16)) + 63) == 0 && ((-v305) + 2) == 0 && ((-v303) + 2) == 0) ? v345 : v343;	// L443
// CHECK:           v302[v307][(v308 + 1)][v309] = v346;	// L444
// CHECK:           ap_int<8> v347 = v299[v306][(v308 + 1)][(v309 + 1)];	// L445
// CHECK:           ap_int<8> v348 = v301[v307][(v308 + 1)][(v309 + 1)];	// L446
// CHECK:           ap_int<8> v349 = v302[v307][(v308 + 1)][(v309 + 1)];	// L447
// CHECK:           ap_int<8> v350 = (v306 == 0) ? v348 : v349;	// L448
// CHECK:           ap_int<16> v351 = (ap_int<16>)v347 * (ap_int<16>)v311;	// L449
// CHECK:           ap_int<32> v352 = v350;	// L450
// CHECK:           ap_int<32> v353 = v351;	// L451
// CHECK:           ap_int<32> v354 = v352 + v353;	// L452
// CHECK:           ap_int<8> v355 = v354;	// L453
// CHECK:           bool v356 = v355 > (ap_int<8>)-24;	// L454
// CHECK:           ap_int<8> v357 = v356 ? v355 : (ap_int<8>)-24;	// L455
// CHECK:           ap_int<8> v358 = ((((-v306) + (v304 * -16)) + 63) == 0 && ((-v305) + 2) == 0 && ((-v303) + 2) == 0) ? v357 : v355;	// L456
// CHECK:           v302[v307][(v308 + 1)][(v309 + 1)] = v358;	// L457
// CHECK:         }
// CHECK:       }
// CHECK:     }
// CHECK:   }
// CHECK: }

// CHECK: void forward_node25(
// CHECK:   ap_int<8> v359[64][28][28],
// CHECK:   ap_int<8> v360[16][14][14],
// CHECK:   int v361,
// CHECK:   int v362,
// CHECK:   int v363
// CHECK: ) {	// L464
// CHECK:   #pragma HLS inline
// CHECK:   #pragma HLS array_partition variable=v359 cyclic factor=2 dim=2
// CHECK:   #pragma HLS array_partition variable=v359 cyclic factor=2 dim=3

// CHECK:   #pragma HLS array_partition variable=v360 cyclic factor=2 dim=2
// CHECK:   #pragma HLS array_partition variable=v360 cyclic factor=2 dim=3
// CHECK:   #pragma HLS bind_storage variable=v360 type=ram_t2p impl=bram

// CHECK:   for (int v364 = 0; v364 < 16; v364 += 1) {	// L465
// CHECK:     for (int v365 = 0; v365 < 14; v365 += 2) {	// L466
// CHECK:       for (int v366 = 0; v366 < 14; v366 += 2) {	// L467
// CHECK:         #pragma HLS pipeline II=1
// CHECK:         ap_int<8> v367 = v359[(v364 + (v361 * 16))][(v365 + (v362 * 14))][(v366 + (v363 * 14))];	// L468
// CHECK:         v360[v364][v365][v366] = v367;	// L469
// CHECK:         ap_int<8> v368 = v359[(v364 + (v361 * 16))][(v365 + (v362 * 14))][((v366 + (v363 * 14)) + 1)];	// L470
// CHECK:         v360[v364][v365][(v366 + 1)] = v368;	// L471
// CHECK:         ap_int<8> v369 = v359[(v364 + (v361 * 16))][((v365 + (v362 * 14)) + 1)][(v366 + (v363 * 14))];	// L472
// CHECK:         v360[v364][(v365 + 1)][v366] = v369;	// L473
// CHECK:         ap_int<8> v370 = v359[(v364 + (v361 * 16))][((v365 + (v362 * 14)) + 1)][((v366 + (v363 * 14)) + 1)];	// L474
// CHECK:         v360[v364][(v365 + 1)][(v366 + 1)] = v370;	// L475
// CHECK:       }
// CHECK:     }
// CHECK:   }
// CHECK: }

// CHECK: void forward_node26(
// CHECK:   ap_int<8> v371[64][64][3][3],
// CHECK:   ap_int<8> v372[16][16],
// CHECK:   int v373,
// CHECK:   int v374,
// CHECK:   int v375,
// CHECK:   int v376
// CHECK: ) {	// L481
// CHECK:   #pragma HLS inline
// CHECK:   #pragma HLS bind_storage variable=v372 type=ram_t2p impl=bram

// CHECK:   for (int v377 = 0; v377 < 16; v377 += 1) {	// L482
// CHECK:     for (int v378 = 0; v378 < 16; v378 += 1) {	// L483
// CHECK:       #pragma HLS pipeline II=1
// CHECK:       ap_int<8> v379 = v371[(v377 + (v373 * 16))][(v378 + (v374 * 16))][v375][v376];	// L484
// CHECK:       v372[v377][v378] = v379;	// L485
// CHECK:     }
// CHECK:   }
// CHECK: }

// CHECK: void forward_node27(
// CHECK:   ap_int<8> v380[64][56][56],
// CHECK:   ap_int<8> v381[16][14][14],
// CHECK:   int v382,
// CHECK:   int v383,
// CHECK:   int v384,
// CHECK:   int v385,
// CHECK:   int v386
// CHECK: ) {	// L490
// CHECK:   #pragma HLS inline
// CHECK:   #pragma HLS array_partition variable=v380 cyclic factor=4 dim=2
// CHECK:   #pragma HLS array_partition variable=v380 cyclic factor=4 dim=3

// CHECK:   #pragma HLS array_partition variable=v381 cyclic factor=2 dim=2
// CHECK:   #pragma HLS array_partition variable=v381 cyclic factor=2 dim=3
// CHECK:   #pragma HLS bind_storage variable=v381 type=ram_t2p impl=bram

// CHECK:   for (int v387 = 0; v387 < 16; v387 += 1) {	// L491
// CHECK:     for (int v388 = 0; v388 < 14; v388 += 2) {	// L492
// CHECK:       for (int v389 = 0; v389 < 14; v389 += 2) {	// L493
// CHECK:         #pragma HLS pipeline II=1
// CHECK:         ap_int<8> v390 = v380[(v387 + (v382 * 16))][((((v388 * 2) + v383) + (v384 * 28)) - 1)][((((v389 * 2) + v385) + (v386 * 28)) - 1)];	// L494
// CHECK:         v381[v387][v388][v389] = v390;	// L495
// CHECK:         ap_int<8> v391 = v380[(v387 + (v382 * 16))][((((v388 * 2) + v383) + (v384 * 28)) - 1)][((((v389 * 2) + v385) + (v386 * 28)) + 1)];	// L496
// CHECK:         v381[v387][v388][(v389 + 1)] = v391;	// L497
// CHECK:         ap_int<8> v392 = v380[(v387 + (v382 * 16))][((((v388 * 2) + v383) + (v384 * 28)) + 1)][((((v389 * 2) + v385) + (v386 * 28)) - 1)];	// L498
// CHECK:         v381[v387][(v388 + 1)][v389] = v392;	// L499
// CHECK:         ap_int<8> v393 = v380[(v387 + (v382 * 16))][((((v388 * 2) + v383) + (v384 * 28)) + 1)][((((v389 * 2) + v385) + (v386 * 28)) + 1)];	// L500
// CHECK:         v381[v387][(v388 + 1)][(v389 + 1)] = v393;	// L501
// CHECK:       }
// CHECK:     }
// CHECK:   }
// CHECK: }

// CHECK: void forward_node22(
// CHECK:   hls::stream<bool> &v394,
// CHECK:   ap_int<8> v395[64][56][56],
// CHECK:   ap_int<8> v396[64][64][3][3],
// CHECK:   ap_int<8> v397[64][28][28],
// CHECK:   hls::stream<bool> &v398,
// CHECK:   ap_int<8> v399[64][28][28]
// CHECK: ) {	// L507
// CHECK:   #pragma HLS array_partition variable=v395 cyclic factor=4 dim=2
// CHECK:   #pragma HLS array_partition variable=v395 cyclic factor=4 dim=3

// CHECK:   #pragma HLS array_partition variable=v397 cyclic factor=2 dim=2
// CHECK:   #pragma HLS array_partition variable=v397 cyclic factor=2 dim=3

// CHECK:   #pragma HLS array_partition variable=v399 cyclic factor=2 dim=2
// CHECK:   #pragma HLS array_partition variable=v399 cyclic factor=2 dim=3

// CHECK:   v394.read();	// L509
// CHECK:   for (int v400 = 0; v400 < 576; v400 += 1) {	// L510
// CHECK:     #pragma HLS dataflow
// CHECK:     int v401 = (v400 % 2);	// L511
// CHECK:     int v402 = ((v400 / 2) % 2);	// L512
// CHECK:     int v403 = (((v400 / 2) / 2) % 4);	// L513
// CHECK:     int v404 = ((((v400 / 2) / 2) / 4) % 3);	// L514
// CHECK:     int v405 = (((((v400 / 2) / 2) / 4) / 3) % 3);	// L515
// CHECK:     int v406 = (((((v400 / 2) / 2) / 4) / 3) / 3);	// L516
// CHECK:     ap_int<8> v407[16][14][14];	// L517
// CHECK:     #pragma HLS array_partition variable=v407 cyclic factor=2 dim=2
// CHECK:     #pragma HLS array_partition variable=v407 cyclic factor=2 dim=3
// CHECK:     #pragma HLS bind_storage variable=v407 type=ram_t2p impl=bram

// CHECK:     ap_int<8> v408[16][16];	// L518
// CHECK:     #pragma HLS bind_storage variable=v408 type=ram_t2p impl=bram

// CHECK:     ap_int<8> v409[16][14][14];	// L519
// CHECK:     #pragma HLS array_partition variable=v409 cyclic factor=2 dim=2
// CHECK:     #pragma HLS array_partition variable=v409 cyclic factor=2 dim=3
// CHECK:     #pragma HLS bind_storage variable=v409 type=ram_t2p impl=bram

// CHECK:     forward_node27(v395, v409, v406, v405, v402, v404, v401);	// L520
// CHECK:     forward_node26(v396, v408, v403, v406, v405, v404);	// L521
// CHECK:     forward_node25(v397, v407, v403, v402, v401);	// L522
// CHECK:     ap_int<8> v410[16][14][14];	// L523
// CHECK:     #pragma HLS array_partition variable=v410 cyclic factor=2 dim=2
// CHECK:     #pragma HLS array_partition variable=v410 cyclic factor=2 dim=3
// CHECK:     #pragma HLS bind_storage variable=v410 type=ram_t2p impl=bram

// CHECK:     forward_node24(v409, v408, v407, v410, v404, v406, v405);	// L524
// CHECK:     forward_node23(v410, v399, v403, v402, v401);	// L525
// CHECK:   }
// CHECK:   v398.write(true);	// L527
// CHECK: }

// CHECK: void forward_node28(
// CHECK:   hls::stream<bool> &v411,
// CHECK:   ap_int<8> v412[64][56][56],
// CHECK:   hls::stream<bool> &v413,
// CHECK:   ap_int<8> v414[64][56][56],
// CHECK:   hls::stream<bool> &v415,
// CHECK:   ap_int<8> v416[64][56][56]
// CHECK: ) {	// L530
// CHECK:   v411.read();	// L532
// CHECK:   for (int v417 = 0; v417 < 64; v417 += 1) {	// L533
// CHECK:     for (int v418 = 0; v418 < 56; v418 += 1) {	// L534
// CHECK:       for (int v419 = 0; v419 < 56; v419 += 1) {	// L535
// CHECK:         #pragma HLS pipeline II=1
// CHECK:         ap_int<8> v420 = v412[v417][v418][v419];	// L536
// CHECK:         v414[v417][v418][v419] = v420;	// L537
// CHECK:       }
// CHECK:     }
// CHECK:   }
// CHECK:   for (int v421 = 0; v421 < 64; v421 += 1) {	// L541
// CHECK:     for (int v422 = 0; v422 < 56; v422 += 1) {	// L542
// CHECK:       for (int v423 = 0; v423 < 56; v423 += 1) {	// L543
// CHECK:         #pragma HLS pipeline II=1
// CHECK:         ap_int<8> v424 = v412[v421][v422][v423];	// L544
// CHECK:         v416[v421][v422][v423] = v424;	// L545
// CHECK:       }
// CHECK:     }
// CHECK:   }
// CHECK:   v413.write(true);	// L549
// CHECK:   v415.write(true);	// L550
// CHECK: }

// CHECK: void forward_node30(
// CHECK:   ap_int<8> v425[16][14][14],
// CHECK:   ap_int<8> v426[64][56][56],
// CHECK:   int v427,
// CHECK:   int v428,
// CHECK:   int v429
// CHECK: ) {	// L553
// CHECK:   #pragma HLS inline
// CHECK:   #pragma HLS bind_storage variable=v425 type=ram_t2p impl=bram

// CHECK:   for (int v430 = 0; v430 < 16; v430 += 1) {	// L554
// CHECK:     for (int v431 = 0; v431 < 14; v431 += 1) {	// L555
// CHECK:       for (int v432 = 0; v432 < 14; v432 += 1) {	// L556
// CHECK:         #pragma HLS pipeline II=1
// CHECK:         ap_int<8> v433 = v425[v430][v431][v432];	// L557
// CHECK:         v426[(v430 + (v427 * 16))][(v431 + (v428 * 14))][(v432 + (v429 * 14))] = v433;	// L558
// CHECK:       }
// CHECK:     }
// CHECK:   }
// CHECK: }

// CHECK: void forward_node31(
// CHECK:   ap_int<8> v434[16][14][14],
// CHECK:   ap_int<8> v435[16][14][14]
// CHECK: ) {	// L564
// CHECK:   #pragma HLS inline
// CHECK:   #pragma HLS bind_storage variable=v434 type=ram_t2p impl=bram

// CHECK:   #pragma HLS bind_storage variable=v435 type=ram_t2p impl=bram

// CHECK:   for (int v436 = 0; v436 < 16; v436 += 1) {	// L566
// CHECK:     for (int v437 = 0; v437 < 14; v437 += 1) {	// L567
// CHECK:       for (int v438 = 0; v438 < 14; v438 += 1) {	// L568
// CHECK:         #pragma HLS pipeline II=1
// CHECK:         ap_int<8> v439 = v434[v436][v437][v438];	// L569
// CHECK:         bool v440 = v439 > (ap_int<8>)-24;	// L570
// CHECK:         ap_int<8> v441 = v440 ? v439 : (ap_int<8>)-24;	// L571
// CHECK:         v435[v436][v437][v438] = v441;	// L572
// CHECK:       }
// CHECK:     }
// CHECK:   }
// CHECK: }

// CHECK: void forward_node32(
// CHECK:   ap_int<8> v442[64][56][56],
// CHECK:   ap_int<8> v443[16][14][14],
// CHECK:   int v444,
// CHECK:   int v445,
// CHECK:   int v446
// CHECK: ) {	// L578
// CHECK:   #pragma HLS inline
// CHECK:   #pragma HLS bind_storage variable=v443 type=ram_t2p impl=bram

// CHECK:   for (int v447 = 0; v447 < 16; v447 += 1) {	// L579
// CHECK:     for (int v448 = 0; v448 < 14; v448 += 1) {	// L580
// CHECK:       for (int v449 = 0; v449 < 14; v449 += 1) {	// L581
// CHECK:         #pragma HLS pipeline II=1
// CHECK:         ap_int<8> v450 = v442[(v447 + (v444 * 16))][(v448 + (v445 * 14))][(v449 + (v446 * 14))];	// L582
// CHECK:         v443[v447][v448][v449] = v450;	// L583
// CHECK:       }
// CHECK:     }
// CHECK:   }
// CHECK: }

// CHECK: void forward_node29(
// CHECK:   ap_int<8> v451[64][56][56],
// CHECK:   hls::stream<bool> &v452,
// CHECK:   ap_int<8> v453[64][56][56]
// CHECK: ) {	// L589
// CHECK:   for (int v454 = 0; v454 < 64; v454 += 1) {	// L591
// CHECK:     #pragma HLS dataflow
// CHECK:     int v455 = (v454 % 4);	// L592
// CHECK:     int v456 = ((v454 / 4) % 4);	// L593
// CHECK:     int v457 = ((v454 / 4) / 4);	// L594
// CHECK:     ap_int<8> v458[16][14][14];	// L595
// CHECK:     #pragma HLS bind_storage variable=v458 type=ram_t2p impl=bram

// CHECK:     forward_node32(v451, v458, v457, v456, v455);	// L596
// CHECK:     ap_int<8> v459[16][14][14];	// L597
// CHECK:     #pragma HLS bind_storage variable=v459 type=ram_t2p impl=bram

// CHECK:     forward_node31(v458, v459);	// L598
// CHECK:     forward_node30(v459, v453, v457, v456, v455);	// L599
// CHECK:   }
// CHECK:   v452.write(true);	// L601
// CHECK: }

// CHECK: /// This is top function.
// CHECK: void forward(
// CHECK:   ap_int<8> v460[64][56][56],
// CHECK:   ap_int<8> v461[64][56][56],
// CHECK:   ap_int<8> v462[64][56][56],
// CHECK:   ap_int<8> v463[1000][64],
// CHECK:   ap_int<8> v464[64][64],
// CHECK:   ap_int<8> v465[64][64][3][3],
// CHECK:   ap_int<8> v466[64][64][3][3],
// CHECK:   ap_int<8> v467[1000],
// CHECK:   ap_int<8> v468[1000],
// CHECK:   ap_int<8> v469[64][56][56],
// CHECK:   ap_int<8> v470[64][56][56],
// CHECK:   ap_int<8> v471[64][56][56],
// CHECK:   ap_int<8> v472[64][56][56],
// CHECK:   ap_int<8> v473[64][28][28],
// CHECK:   ap_int<8> v474[64][28][28],
// CHECK:   ap_int<8> v475[64][28][28],
// CHECK:   ap_int<8> v476[64][28][28],
// CHECK:   ap_int<8> v477[64][28][28],
// CHECK:   ap_int<8> v478[64][28][28],
// CHECK:   ap_int<8> v479[64][28][28],
// CHECK:   ap_int<8> v480[64][28][28],
// CHECK:   ap_int<8> v481[64][28][28],
// CHECK:   ap_int<8> v482[64][28][28]
// CHECK: ) {	// L604
// CHECK:   #pragma HLS interface s_axilite port=return bundle=ctrl
// CHECK:   #pragma HLS interface s_axilite port=v460 bundle=ctrl
// CHECK:   #pragma HLS interface s_axilite port=v461 bundle=ctrl
// CHECK:   #pragma HLS interface s_axilite port=v462 bundle=ctrl
// CHECK:   #pragma HLS interface s_axilite port=v463 bundle=ctrl
// CHECK:   #pragma HLS interface s_axilite port=v464 bundle=ctrl
// CHECK:   #pragma HLS interface s_axilite port=v465 bundle=ctrl
// CHECK:   #pragma HLS interface s_axilite port=v466 bundle=ctrl
// CHECK:   #pragma HLS interface s_axilite port=v467 bundle=ctrl
// CHECK:   #pragma HLS interface s_axilite port=v468 bundle=ctrl
// CHECK:   #pragma HLS interface s_axilite port=v469 bundle=ctrl
// CHECK:   #pragma HLS interface s_axilite port=v470 bundle=ctrl
// CHECK:   #pragma HLS interface s_axilite port=v471 bundle=ctrl
// CHECK:   #pragma HLS interface s_axilite port=v472 bundle=ctrl
// CHECK:   #pragma HLS interface s_axilite port=v473 bundle=ctrl
// CHECK:   #pragma HLS interface s_axilite port=v474 bundle=ctrl
// CHECK:   #pragma HLS interface s_axilite port=v475 bundle=ctrl
// CHECK:   #pragma HLS interface s_axilite port=v476 bundle=ctrl
// CHECK:   #pragma HLS interface s_axilite port=v477 bundle=ctrl
// CHECK:   #pragma HLS interface s_axilite port=v478 bundle=ctrl
// CHECK:   #pragma HLS interface s_axilite port=v479 bundle=ctrl
// CHECK:   #pragma HLS interface s_axilite port=v480 bundle=ctrl
// CHECK:   #pragma HLS interface s_axilite port=v481 bundle=ctrl
// CHECK:   #pragma HLS interface s_axilite port=v482 bundle=ctrl
// CHECK:   #pragma HLS dataflow

// CHECK:   #pragma HLS interface ap_memory port=v482
// CHECK:   #pragma HLS stable variable=v482

// CHECK:   #pragma HLS interface ap_memory port=v481
// CHECK:   #pragma HLS stable variable=v481

// CHECK:   #pragma HLS interface ap_memory port=v480
// CHECK:   #pragma HLS stable variable=v480

// CHECK:   #pragma HLS interface ap_memory port=v479
// CHECK:   #pragma HLS stable variable=v479

// CHECK:   #pragma HLS interface ap_memory port=v478
// CHECK:   #pragma HLS stable variable=v478
// CHECK:   #pragma HLS array_partition variable=v478 cyclic factor=2 dim=2
// CHECK:   #pragma HLS array_partition variable=v478 cyclic factor=2 dim=3


// CHECK:   #pragma HLS interface ap_memory port=v477
// CHECK:   #pragma HLS stable variable=v477
// CHECK:   #pragma HLS array_partition variable=v477 cyclic factor=2 dim=2
// CHECK:   #pragma HLS array_partition variable=v477 cyclic factor=2 dim=3


// CHECK:   #pragma HLS interface ap_memory port=v476
// CHECK:   #pragma HLS stable variable=v476

// CHECK:   #pragma HLS interface ap_memory port=v475
// CHECK:   #pragma HLS stable variable=v475
// CHECK:   #pragma HLS array_partition variable=v475 cyclic factor=2 dim=2
// CHECK:   #pragma HLS array_partition variable=v475 cyclic factor=2 dim=3


// CHECK:   #pragma HLS interface ap_memory port=v474
// CHECK:   #pragma HLS stable variable=v474
// CHECK:   #pragma HLS array_partition variable=v474 cyclic factor=2 dim=2
// CHECK:   #pragma HLS array_partition variable=v474 cyclic factor=2 dim=3


// CHECK:   #pragma HLS interface ap_memory port=v473
// CHECK:   #pragma HLS stable variable=v473
// CHECK:   #pragma HLS array_partition variable=v473 cyclic factor=2 dim=2
// CHECK:   #pragma HLS array_partition variable=v473 cyclic factor=2 dim=3


// CHECK:   #pragma HLS interface ap_memory port=v472
// CHECK:   #pragma HLS stable variable=v472

// CHECK:   #pragma HLS interface ap_memory port=v471
// CHECK:   #pragma HLS stable variable=v471
// CHECK:   #pragma HLS array_partition variable=v471 cyclic factor=4 dim=2
// CHECK:   #pragma HLS array_partition variable=v471 cyclic factor=4 dim=3


// CHECK:   #pragma HLS interface ap_memory port=v470
// CHECK:   #pragma HLS stable variable=v470

// CHECK:   #pragma HLS interface ap_memory port=v469
// CHECK:   #pragma HLS stable variable=v469

// CHECK:   #pragma HLS interface ap_memory port=v468
// CHECK:   #pragma HLS stable variable=v468

// CHECK:   #pragma HLS interface ap_memory port=v467
// CHECK:   #pragma HLS stable variable=v467

// CHECK:   #pragma HLS interface ap_memory port=v466
// CHECK:   #pragma HLS stable variable=v466

// CHECK:   #pragma HLS interface ap_memory port=v465
// CHECK:   #pragma HLS stable variable=v465

// CHECK:   #pragma HLS interface ap_memory port=v464
// CHECK:   #pragma HLS stable variable=v464

// CHECK:   #pragma HLS interface ap_memory port=v463
// CHECK:   #pragma HLS stable variable=v463

// CHECK:   #pragma HLS interface ap_memory port=v462
// CHECK:   #pragma HLS stable variable=v462

// CHECK:   #pragma HLS interface ap_memory port=v461
// CHECK:   #pragma HLS stable variable=v461

// CHECK:   #pragma HLS interface ap_memory port=v460
// CHECK:   #pragma HLS stable variable=v460

// CHECK:   hls::stream<bool> v506;	// L651
// CHECK:   forward_node29(v460, v506, v461);	// L652
// CHECK:   hls::stream<bool> v507;	// L653
// CHECK:   hls::stream<bool> v508;	// L654
// CHECK:   forward_node28(v506, v462, v507, v470, v508, v472);	// L655
// CHECK:   hls::stream<bool> v509;	// L656
// CHECK:   forward_node22(v508, v471, v466, v475, v509, v474);	// L657
// CHECK:   hls::stream<bool> v510;	// L658
// CHECK:   forward_node16(v465, v509, v473, v478, v510, v477);	// L659
// CHECK:   hls::stream<bool> v511;	// L660
// CHECK:   forward_node8(v507, v469, v464, v510, v476, v482, v511, v480, v481);	// L661
// CHECK:   ap_int<8> v512[64];	// L662
// CHECK:   #pragma HLS bind_storage variable=v512 type=ram_t2p impl=bram

// CHECK:   forward_node5(v511, v479, v512);	// L663
// CHECK:   forward_node0(v512, v463, v467, v468);	// L664
// CHECK: }
