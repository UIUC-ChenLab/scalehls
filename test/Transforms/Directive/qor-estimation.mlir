// RUN: scalehls-opt -scalehls-qor-estimation="target-spec=%S/config.json" %s | FileCheck %s

// CHECK: module {
// CHECK:   func.func @test_syrk(%arg0: f32, %arg1: f32, %arg2: memref<16x16xf32, #map, #hls.mem<bram_s2p>>, %arg3: memref<16x16xf32, #map1, #hls.mem<bram_s2p>>) attributes {func_directive = #hls.func<pipeline = false, target_interval = 1, dataflow = false>, resource = #hls.res<lut = 0, dsp = 11, bram = 0>, timing = #hls.time<0 -> 4119, latency = 4119, interval = 4119>, top_func} {
// CHECK:     affine.for %arg4 = 0 to 16 step 2 {
// CHECK:       affine.for %arg5 = 0 to 16 {
// CHECK:         affine.for %arg6 = 0 to 16 {
// CHECK:           affine.if #set(%arg5, %arg6) {
// CHECK:             %0 = affine.load %arg3[%arg5, %arg6] {partition_indices = [0, 0], timing = #hls.time<4 -> 6, latency = 2, interval = 1>} : memref<16x16xf32, #map1, #hls.mem<bram_s2p>>
// CHECK:             %1 = arith.mulf %arg1, %0 {timing = #hls.time<6 -> 10, latency = 4, interval = 1>} : f32
// CHECK:             %2 = affine.load %arg2[%arg5, %arg4] {partition_indices = [0, 0], timing = #hls.time<0 -> 2, latency = 2, interval = 1>} : memref<16x16xf32, #map, #hls.mem<bram_s2p>>
// CHECK:             %3 = affine.load %arg2[%arg6, %arg4] {partition_indices = [0, 0], timing = #hls.time<4 -> 6, latency = 2, interval = 1>} : memref<16x16xf32, #map, #hls.mem<bram_s2p>>
// CHECK:             %4 = affine.if #set1(%arg4) -> f32 {
// CHECK:               affine.yield {timing = #hls.time<10 -> 10, latency = 0, interval = 0>} %1 : f32
// CHECK:             } else {
// CHECK:               affine.yield {timing = #hls.time<10 -> 10, latency = 0, interval = 0>} %0 : f32
// CHECK:             } {timing = #hls.time<10 -> 10, latency = 0, interval = 0>}
// CHECK:             %5 = arith.mulf %arg0, %2 {timing = #hls.time<2 -> 6, latency = 4, interval = 1>} : f32
// CHECK:             %6 = arith.mulf %5, %3 {timing = #hls.time<6 -> 10, latency = 4, interval = 1>} : f32
// CHECK:             %7 = arith.addf %6, %4 {timing = #hls.time<10 -> 15, latency = 5, interval = 1>} : f32
// CHECK:             %8 = affine.load %arg2[%arg5, %arg4 + 1] {partition_indices = [0, 1], timing = #hls.time<5 -> 7, latency = 2, interval = 1>} : memref<16x16xf32, #map, #hls.mem<bram_s2p>>
// CHECK:             %9 = affine.load %arg2[%arg6, %arg4 + 1] {partition_indices = [0, 1], timing = #hls.time<9 -> 11, latency = 2, interval = 1>} : memref<16x16xf32, #map, #hls.mem<bram_s2p>>
// CHECK:             %10 = arith.mulf %arg0, %8 {timing = #hls.time<7 -> 11, latency = 4, interval = 1>} : f32
// CHECK:             %11 = arith.mulf %10, %9 {timing = #hls.time<11 -> 15, latency = 4, interval = 1>} : f32
// CHECK:             %12 = arith.addf %11, %7 {timing = #hls.time<15 -> 20, latency = 5, interval = 1>} : f32
// CHECK:             affine.store %12, %arg3[%arg5, %arg6] {partition_indices = [0, 0], timing = #hls.time<20 -> 21, latency = 1, interval = 1>} : memref<16x16xf32, #map1, #hls.mem<bram_s2p>>
// CHECK:           } {timing = #hls.time<0 -> 21, latency = 21, interval = 0>}
// CHECK:         } {loop_directive = #hls.loop<pipeline = true, target_ii = 2, dataflow = false, flatten = false>, loop_info = #hls.info<flatten_trip_count = 16, iter_latency = 21, min_ii = 2>, parallel, timing = #hls.time<0 -> 53, latency = 53, interval = 53>}
// CHECK:       } {loop_directive = #hls.loop<pipeline = false, target_ii = 1, dataflow = false, flatten = true>, loop_info = #hls.info<flatten_trip_count = 256, iter_latency = 21, min_ii = 2>, parallel, timing = #hls.time<0 -> 533, latency = 533, interval = 533>}
// CHECK:     } {loop_directive = #hls.loop<pipeline = false, target_ii = 1, dataflow = false, flatten = true>, loop_info = #hls.info<flatten_trip_count = 2048, iter_latency = 21, min_ii = 2>, timing = #hls.time<0 -> 4117, latency = 4117, interval = 4117>}
// CHECK:     return {timing = #hls.time<4117 -> 4117, latency = 0, interval = 0>}
// CHECK:   }
// CHECK: }

#map0 = affine_map<(d0, d1) -> (0, d1 mod 2, d0, d1 floordiv 2)>
#map1 = affine_map<(d0, d1) -> (0, 0, d0, d1)>
#set0 = affine_set<(d0, d1) : (d0 - d1 >= 0)>
#set1 = affine_set<(d0) : (d0 == 0)>
module  {
  func.func @test_syrk(%arg0: f32, %arg1: f32, %arg2: memref<16x16xf32, #map0, #hls.mem<bram_s2p>>, %arg3: memref<16x16xf32, #map1, #hls.mem<bram_s2p>>) attributes {func_directive = #hls.func<pipeline = false, target_interval = 1, dataflow = false>, top_func} {
    affine.for %arg4 = 0 to 16 step 2 {
      affine.for %arg5 = 0 to 16 {
        affine.for %arg6 = 0 to 16 {
          affine.if #set0(%arg5, %arg6) {
            %0 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, #map1, #hls.mem<bram_s2p>>
            %1 = arith.mulf %arg1, %0 : f32
            %2 = affine.load %arg2[%arg5, %arg4] : memref<16x16xf32, #map0, #hls.mem<bram_s2p>>
            %3 = affine.load %arg2[%arg6, %arg4] : memref<16x16xf32, #map0, #hls.mem<bram_s2p>>
            %4 = affine.if #set1(%arg4) -> f32 {
              affine.yield %1 : f32
            } else {
              affine.yield %0 : f32
            }
            %5 = arith.mulf %arg0, %2 : f32
            %6 = arith.mulf %5, %3 : f32
            %7 = arith.addf %6, %4 : f32
            %8 = affine.load %arg2[%arg5, %arg4 + 1] : memref<16x16xf32, #map0, #hls.mem<bram_s2p>>
            %9 = affine.load %arg2[%arg6, %arg4 + 1] : memref<16x16xf32, #map0, #hls.mem<bram_s2p>>
            %10 = arith.mulf %arg0, %8 : f32
            %11 = arith.mulf %10, %9 : f32
            %12 = arith.addf %11, %7 : f32
            affine.store %12, %arg3[%arg5, %arg6] : memref<16x16xf32, #map1, #hls.mem<bram_s2p>>
          }
        } {loop_directive = #hls.loop<pipeline = true, target_ii = 2, dataflow = false, flatten = false>, parallel}
      } {loop_directive = #hls.loop<pipeline = false, target_ii = 1, dataflow = false, flatten = true>, parallel}
    } {loop_directive = #hls.loop<pipeline = false, target_ii = 1, dataflow = false, flatten = true>}
    return
  }
}
