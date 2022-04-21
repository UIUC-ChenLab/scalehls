func @soft_max(%arg0: memref<3xf64, affine_map<(d0) -> (0, d0)>, 1>, %arg1: memref<3xf64, affine_map<(d0) -> (0, d0)>, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>, llvm.linkage = #llvm.linkage<external>, resource = #hlscpp.r<lut=0, dsp=9, bram=0>, timing = #hlscpp.t<0 -> 69, 69, 69>} {
  %cst = arith.constant {timing = #hlscpp.t<0 -> 0, 0, 0>} 0.000000e+00 : f64
  %0 = memref.alloc() {timing = #hlscpp.t<0 -> 0, 0, 0>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  affine.store %cst, %0[0] {partition_indices = [0], timing = #hlscpp.t<0 -> 1, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  %1 = memref.alloc() {timing = #hlscpp.t<0 -> 0, 0, 0>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  affine.store %cst, %1[0] {partition_indices = [0], timing = #hlscpp.t<0 -> 1, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  affine.for %arg2 = 0 to 3 {
    %3 = affine.load %0[0] {partition_indices = [0], timing = #hlscpp.t<10 -> 11, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
    %4 = affine.load %arg1[%arg2] {max_mux_size = 1 : i64, partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<3xf64, affine_map<(d0) -> (0, d0)>, 1>
    %5 = arith.negf %4 {timing = #hlscpp.t<2 -> 2, 0, 0>} : f64
    %6 = math.exp %5 {timing = #hlscpp.t<2 -> 11, 9, 1>} : f64
    %7 = arith.addf %3, %6 {timing = #hlscpp.t<11 -> 16, 5, 1>} : f64
    affine.store %7, %0[0] {partition_indices = [0], timing = #hlscpp.t<16 -> 17, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
    affine.store %7, %1[0] {partition_indices = [0], timing = #hlscpp.t<16 -> 17, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=7, dataflow=false, flatten=false, parallel=false>, loop_info = #hlscpp.l<flattenTripCount=3, iterLatency=17, minII=7>, timing = #hlscpp.t<1 -> 34, 33, 33>}
  %2 = affine.load %1[0] {partition_indices = [0], timing = #hlscpp.t<34 -> 35, 1, 1>} : memref<1xf64, affine_map<(d0) -> (0, d0)>, 1>
  affine.for %arg2 = 0 to 3 {
    %3 = affine.load %arg1[%arg2] {max_mux_size = 1 : i64, partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<3xf64, affine_map<(d0) -> (0, d0)>, 1>
    %4 = arith.negf %3 {timing = #hlscpp.t<2 -> 2, 0, 0>} : f64
    %5 = math.exp %4 {timing = #hlscpp.t<2 -> 11, 9, 1>} : f64
    %6 = arith.divf %5, %2 {timing = #hlscpp.t<11 -> 27, 16, 1>} : f64
    affine.store %6, %arg0[%arg2] {max_mux_size = 1 : i64, partition_indices = [0], timing = #hlscpp.t<27 -> 28, 1, 1>} : memref<3xf64, affine_map<(d0) -> (0, d0)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=1, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=3, iterLatency=28, minII=1>, timing = #hlscpp.t<35 -> 67, 32, 32>}
  return {timing = #hlscpp.t<67 -> 67, 0, 0>}
}
