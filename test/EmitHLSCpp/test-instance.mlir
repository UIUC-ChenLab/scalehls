// RUN: scalehls-translate -scalehls-emit-hlscpp %s | FileCheck %s


#map = affine_map<() -> ()>
#map1 = affine_map<(d0, d1) -> (d0, d1)>

module attributes { torch.debug_module_name = "MLP" } {
  hls.uip.library @testLib {
    hls.uip.declare @testIp {
      hls.uip.include ["Path/to/test.hpp"]
      %1 = hls.dse.param @template1 <template> candidates [f32] : !hls.float_param
      %2 = hls.dse.param @template2 <template> candidates [index] : !hls.int_param
      %3 = hls.dse.param @template3 <template> candidates [4 : index] : index
      %4 = hls.uip.port @para1 <param> type %2 memory_layout #map : !hls.int_param () -> !hls.port
      %5 = hls.uip.port @para2 <param> type %2 memory_layout #map : !hls.int_param () -> !hls.port
      %6 = hls.uip.port @input1 <input> type %1 [%4, %5] memory_layout #map1 : !hls.float_param [!hls.port, !hls.port] () -> !hls.port
      %7 = hls.uip.port @input2 <input> type %1 [%4, %5] memory_layout #map1 : !hls.float_param [!hls.port, !hls.port] () -> !hls.port
      %8 = hls.uip.port @output1 <output> type %1 [%4, %5] memory_layout #map1 : !hls.float_param [!hls.port, !hls.port] () -> !hls.port
      hls.uip.semantics<%1, %2, %3> (%4, %5, %6, %7, %8) [2 : index, 3 : index, 4 : index] : <!hls.float_param, !hls.int_param, index> (!hls.port, !hls.port, !hls.port, !hls.port, !hls.port) {
      ^bb0(%arg0: tensor<?x?xf32>, %arg1: tensor<?x?xf32>, %arg2: tensor<?x?xf32>):
        %9 = linalg.generic {indexing_maps = [#map1, #map1], iterator_types = ["parallel", "parallel"]} ins(%arg0 : tensor<?x?xf32>) outs(%arg1 : tensor<?x?xf32>) {
        ^bb0(%in: f32, %out: f32):
          %10 = arith.addf %out, %in : f32
          linalg.yield %10 : f32
        } -> tensor<?x?xf32>
        hls.uip.semantics.output %9 -> %arg2 : (tensor<?x?xf32>) -> tensor<?x?xf32>
      }
    }
    hls.uip.declare @not_used_Ip {
      hls.uip.include ["Path/to/no_used_test.hpp"]
      %1 = hls.dse.param @template1 <template> candidates [f32] : !hls.float_param
      %2 = hls.dse.param @template2 <template> candidates [index] : !hls.int_param
      %3 = hls.dse.param @template3 <template> candidates [4 : index] : index
      %4 = hls.uip.port @para1 <param> type %2 memory_layout #map : !hls.int_param () -> !hls.port
      %5 = hls.uip.port @para2 <param> type %2 memory_layout #map : !hls.int_param () -> !hls.port
      %6 = hls.uip.port @input1 <input> type %1 [%4, %5] memory_layout #map1 : !hls.float_param [!hls.port, !hls.port] () -> !hls.port
      %7 = hls.uip.port @input2 <input> type %1 [%4, %5] memory_layout #map1 : !hls.float_param [!hls.port, !hls.port] () -> !hls.port
      %8 = hls.uip.port @output1 <output> type %1 [%4, %5] memory_layout #map1 : !hls.float_param [!hls.port, !hls.port] () -> !hls.port
      hls.uip.semantics<%1, %2, %3> (%4, %5, %6, %7, %8) [2 : index, 3 : index, 4 : index] : <!hls.float_param, !hls.int_param, index> (!hls.port, !hls.port, !hls.port, !hls.port, !hls.port) {
      ^bb0(%arg0: tensor<?x?xf32>, %arg1: tensor<?x?xf32>, %arg2: tensor<?x?xf32>):
        %9 = linalg.generic {indexing_maps = [#map1, #map1], iterator_types = ["parallel", "parallel"]} ins(%arg0 : tensor<?x?xf32>) outs(%arg1 : tensor<?x?xf32>) {
        ^bb0(%in: f32, %out: f32):
          %10 = arith.addf %out, %in : f32
          linalg.yield %10 : f32
        } -> tensor<?x?xf32>
        hls.uip.semantics.output %9 -> %arg2 : (tensor<?x?xf32>) -> tensor<?x?xf32>
      }
    }
  }
    // CHECK: #include "Path/to/test.hpp"
    // CHECK-NOT: #include "Path/to/no_used_test.hpp"
    
    // CHECK: testIp<float, int, (int)4>((int)1, (int)2, v0, v1);
    // CHECK-NOT: not_used_Ip<float, int, 4>((int)1, (int)2, v0, v1);
  func.func @forward(%input: memref<1x10xf32>, %output: memref<1x10xf32>) {
    %c1 = arith.constant 1 : index
    %c2 = arith.constant 2 : index
    %c4 = arith.constant 4 : index
    hls.uip.instance @testLib::@testIp<f32, index, %c4>(%c1, %c2, %input, %output) : <index>(index, index, memref<1x10xf32>, memref<1x10xf32>) -> ()
    return
  }
    
}
