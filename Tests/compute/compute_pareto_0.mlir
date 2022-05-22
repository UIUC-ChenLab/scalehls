func @compute(%arg0: memref<170xf32, affine_map<(d0) -> (d0 mod 2, d0 floordiv 2)>>, %arg1: memref<170xf32, affine_map<(d0) -> (d0 mod 2, d0 floordiv 2)>>) attributes {llvm.linkage = #llvm.linkage<external>, resource = #hls.r<lut=0, dsp=0, bram=0>, timing = #hls.t<0 -> 91, 91, 91>, top_func} {
  affine.for %arg2 = 0 to 5 {
    affine.for %arg3 = 0 to 17 {
      %0 = affine.load %arg1[%arg2 * 34 + %arg3 * 2] {partition_indices = [0], timing = #hls.t<0 -> 2, 2, 1>} : memref<170xf32, affine_map<(d0) -> (d0 mod 2, d0 floordiv 2)>>
      affine.store %0, %arg0[%arg2 * 34 + %arg3 * 2] {partition_indices = [0], timing = #hls.t<2 -> 3, 1, 1>} : memref<170xf32, affine_map<(d0) -> (d0 mod 2, d0 floordiv 2)>>
      %1 = affine.load %arg1[%arg2 * 34 + %arg3 * 2 + 1] {partition_indices = [1], timing = #hls.t<0 -> 2, 2, 1>} : memref<170xf32, affine_map<(d0) -> (d0 mod 2, d0 floordiv 2)>>
      affine.store %1, %arg0[%arg2 * 34 + %arg3 * 2 + 1] {partition_indices = [1], timing = #hls.t<2 -> 3, 1, 1>} : memref<170xf32, affine_map<(d0) -> (d0 mod 2, d0 floordiv 2)>>
    } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>, loop_info = #hls.l<flattenTripCount=17, iterLatency=3, minII=1>, parallel, timing = #hls.t<0 -> 21, 21, 21>}
  } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, loop_info = #hls.l<flattenTripCount=85, iterLatency=3, minII=1>, parallel, timing = #hls.t<0 -> 89, 89, 89>}
  return {timing = #hls.t<89 -> 89, 0, 0>}
}
