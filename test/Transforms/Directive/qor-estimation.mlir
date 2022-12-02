// RUN: scalehls-opt -scalehls-qor-estimation="target-spec=%S/config.json" %s | FileCheck %s

#map0 = affine_map<(d0, d1) -> (0, d1 mod 2, d0, d1 floordiv 2)>
#map1 = affine_map<(d0, d1) -> (0, 0, d0, d1)>
#set0 = affine_set<(d0, d1) : (d0 - d1 >= 0)>
#set1 = affine_set<(d0) : (d0 == 0)>
module  {
  // CHECK: attributes {func_directive = #hls.fd<pipeline=false, targetInterval=1, dataflow=false>, resource = #hls.r<lut=0, dsp=11, bram=0>, timing = #hls.t<0 -> 4119, 4119, 4119>, top_func}
  func.func @test_syrk(%arg0: f32, %arg1: f32, %arg2: memref<16x16xf32, #map0, 6>, %arg3: memref<16x16xf32, #map1, 6>) attributes {func_directive = #hls.fd<pipeline=false, targetInterval=1, dataflow=false>, top_func} {
    affine.for %arg4 = 0 to 16 step 2 {
      affine.for %arg5 = 0 to 16 {
        affine.for %arg6 = 0 to 16 {
          affine.if #set0(%arg5, %arg6) {
            %0 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, #map1, 6>
            %1 = arith.mulf %arg1, %0 : f32
            %2 = affine.load %arg2[%arg5, %arg4] : memref<16x16xf32, #map0, 6>
            %3 = affine.load %arg2[%arg6, %arg4] : memref<16x16xf32, #map0, 6>
            %4 = affine.if #set1(%arg4) -> f32 {
              affine.yield %1 : f32
            } else {
              affine.yield %0 : f32
            }
            %5 = arith.mulf %arg0, %2 : f32
            %6 = arith.mulf %5, %3 : f32
            %7 = arith.addf %6, %4 : f32
            %8 = affine.load %arg2[%arg5, %arg4 + 1] : memref<16x16xf32, #map0, 6>
            %9 = affine.load %arg2[%arg6, %arg4 + 1] : memref<16x16xf32, #map0, 6>
            %10 = arith.mulf %arg0, %8 : f32
            %11 = arith.mulf %10, %9 : f32
            %12 = arith.addf %11, %7 : f32
            affine.store %12, %arg3[%arg5, %arg6] : memref<16x16xf32, #map1, 6>
          }
        } {loop_directive = #hls.ld<pipeline=true, targetII=2, dataflow=false, flatten=false>, parallel}
      } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>}
    return
  }
}
