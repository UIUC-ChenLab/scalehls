func @take_difference(%arg0: memref<3xf64, affine_map<(d0) -> (0, d0)>, 1>, %arg1: memref<3xf64, affine_map<(d0) -> (0, d0)>, 1>, %arg2: memref<3xf64, affine_map<(d0) -> (0, d0)>, 1>, %arg3: memref<3xf64, affine_map<(d0) -> (0, d0)>, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=false, topFunc=true>, llvm.linkage = #llvm.linkage<external>, resource = #hlscpp.r<lut=0, dsp=8, bram=0>, timing = #hlscpp.t<0 -> 22, 22, 22>} {
  %cst = arith.constant {timing = #hlscpp.t<0 -> 0, 0, 0>} -1.000000e+00 : f64
  affine.for %arg4 = 0 to 3 {
    %0 = affine.load %arg0[%arg4] {max_mux_size = 1 : i64, partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<3xf64, affine_map<(d0) -> (0, d0)>, 1>
    %1 = affine.load %arg1[%arg4] {max_mux_size = 1 : i64, partition_indices = [0], timing = #hlscpp.t<0 -> 2, 2, 1>} : memref<3xf64, affine_map<(d0) -> (0, d0)>, 1>
    %2 = arith.subf %0, %1 {timing = #hlscpp.t<2 -> 7, 5, 1>} : f64
    %3 = arith.mulf %2, %cst {timing = #hlscpp.t<7 -> 11, 4, 1>} : f64
    %4 = affine.load %arg3[%arg4] {max_mux_size = 1 : i64, partition_indices = [0], timing = #hlscpp.t<9 -> 11, 2, 1>} : memref<3xf64, affine_map<(d0) -> (0, d0)>, 1>
    %5 = arith.mulf %3, %4 {timing = #hlscpp.t<11 -> 15, 4, 1>} : f64
    affine.store %5, %arg2[%arg4] {max_mux_size = 1 : i64, partition_indices = [0], timing = #hlscpp.t<15 -> 16, 1, 1>} : memref<3xf64, affine_map<(d0) -> (0, d0)>, 1>
  } {loop_directive = #hlscpp.ld<pipeline=true, targetII=1, dataflow=false, flatten=false, parallel=true>, loop_info = #hlscpp.l<flattenTripCount=3, iterLatency=16, minII=1>, timing = #hlscpp.t<0 -> 20, 20, 20>}
  return {timing = #hlscpp.t<20 -> 20, 0, 0>}
}
