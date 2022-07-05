// RUN: scalehls-opt -scalehls-array-partition -split-input-file %s | FileCheck %s

// CHECK: #map0 = affine_map<(d0, d1) -> (0, d1 mod 2, d0, d1 floordiv 2)>
// CHECK: #map1 = affine_map<(d0, d1) -> (0, 0, d0, d1)>
#set0 = affine_set<(d0, d1) : (d0 - d1 >= 0)>
#set1 = affine_set<(d0) : (d0 == 0)>
module  {

  // CHECK-LABEL: func.func @test_syrk(
  // CHECK-SAME:  %arg0: f32, %arg1: f32, %arg2: memref<16x16xf32, #map0>, %arg3: memref<16x16xf32, #map1>) attributes {func_directive = #hls.fd<pipeline=false, targetInterval=1, dataflow=false>, top_func} {
  func.func @test_syrk(%arg0: f32, %arg1: f32, %arg2: memref<16x16xf32>, %arg3: memref<16x16xf32>) attributes {func_directive = #hls.fd<pipeline=false, targetInterval=1, dataflow=false>, top_func} {
    affine.for %arg4 = 0 to 16 step 2 {
      affine.for %arg5 = 0 to 16 {
        affine.for %arg6 = 0 to 16 {
          affine.if #set0(%arg5, %arg6) {

            // CHECK: %0 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32, #map1>
            %0 = affine.load %arg3[%arg5, %arg6] : memref<16x16xf32>
            %1 = arith.mulf %arg1, %0 : f32

            // CHECK: %2 = affine.load %arg2[%arg5, %arg4] : memref<16x16xf32, #map0>
            %2 = affine.load %arg2[%arg5, %arg4] : memref<16x16xf32>
            %3 = affine.load %arg2[%arg6, %arg4] : memref<16x16xf32>
            %4 = affine.if #set1(%arg4) -> f32 {
              affine.yield %1 : f32
            } else {
              affine.yield %0 : f32
            }
            %5 = arith.mulf %arg0, %2 : f32
            %6 = arith.mulf %5, %3 : f32
            %7 = arith.addf %6, %4 : f32
            %8 = affine.load %arg2[%arg5, %arg4 + 1] : memref<16x16xf32>
            %9 = affine.load %arg2[%arg6, %arg4 + 1] : memref<16x16xf32>
            %10 = arith.mulf %arg0, %8 : f32
            %11 = arith.mulf %10, %9 : f32
            %12 = arith.addf %11, %7 : f32

            // CHECK: affine.store %12, %arg3[%arg5, %arg6] : memref<16x16xf32, #map1>
            affine.store %12, %arg3[%arg5, %arg6] : memref<16x16xf32>
          }
        } {loop_directive = #hls.ld<pipeline=true, targetII=2, dataflow=false, flatten=false>, parallel}
      } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>, parallel}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>}
    return
  }
}

// -----

// #map0 = affine_map<(d0, d1, d2, d3) -> (0, 0, 0, 0, d0, d1, d2, d3)>
// #map1 = affine_map<(d0, d1, d2, d3) -> (0, 0, 0, d3 mod 2, d0, d1, d2, d3 floordiv 2)>
// #map2 = affine_map<(d0, d1, d2, d3) -> (0, d1 mod 2, 0, d3 mod 2, d0, d1 floordiv 2, d2, d3 floordiv 2)>
// #map3 = affine_map<(d0) -> (d0 + 1)>
#map = affine_map<(d0) -> (d0 + 1)>
module {
  func.func @test_conv2d(%arg0: memref<1x34x34x64xi8>, %arg1: memref<3x3x64x64xi8>, %arg2: memref<1x32x32x64xi8>) attributes {top_func} {
    %c0_i8 = arith.constant 0 : i8
    affine.for %arg3 = 0 to 1 {
      affine.for %arg4 = 0 to 32 step 2 {
        affine.for %arg5 = 0 to 32 {
          affine.for %arg6 = 0 to 64 step 2 {
            affine.for %arg7 = 0 to 3 {
              affine.for %arg8 = 0 to 3 {
                affine.for %arg9 = 0 to 64 {

                  // CHECK: %0 = affine.load %arg0[%arg3, %arg4 + %arg7, %arg5 + %arg8, %arg9] : memref<1x34x34x64xi8, #map0>
                  %0 = affine.load %arg0[%arg3, %arg4 + %arg7, %arg5 + %arg8, %arg9] : memref<1x34x34x64xi8>
                  %1 = vector.broadcast %0 : i8 to vector<2xi8>

                  // CHECK: %2 = vector.transfer_read %arg1[%arg7, %arg8, %arg9, %arg6], %c0_i8 : memref<3x3x64x64xi8, #map1>, vector<2xi8>
                  %2 = vector.transfer_read %arg1[%arg7, %arg8, %arg9, %arg6], %c0_i8 : memref<3x3x64x64xi8>, vector<2xi8>

                  // CHECK: %3 = vector.transfer_read %arg2[%arg3, %arg4, %arg5, %arg6], %c0_i8 : memref<1x32x32x64xi8, #map2>, vector<2xi8>
                  %3 = vector.transfer_read %arg2[%arg3, %arg4, %arg5, %arg6], %c0_i8 : memref<1x32x32x64xi8>, vector<2xi8>
                  %4 = arith.muli %1, %2 : vector<2xi8>
                  %5 = arith.addi %3, %4 : vector<2xi8>

                  // CHECK: vector.transfer_write %5, %arg2[%arg3, %arg4, %arg5, %arg6] : vector<2xi8>, memref<1x32x32x64xi8, #map2>
                  vector.transfer_write %5, %arg2[%arg3, %arg4, %arg5, %arg6] : vector<2xi8>, memref<1x32x32x64xi8>
                  %6 = affine.apply #map(%arg4)
                  %7 = affine.load %arg0[%arg3, %arg7 + %arg4 + 1, %arg5 + %arg8, %arg9] : memref<1x34x34x64xi8>
                  %8 = vector.broadcast %7 : i8 to vector<2xi8>
                  %9 = vector.transfer_read %arg1[%arg7, %arg8, %arg9, %arg6], %c0_i8 : memref<3x3x64x64xi8>, vector<2xi8>
                  %10 = vector.transfer_read %arg2[%arg3, %6, %arg5, %arg6], %c0_i8 : memref<1x32x32x64xi8>, vector<2xi8>
                  %11 = arith.muli %8, %9 : vector<2xi8>
                  %12 = arith.addi %10, %11 : vector<2xi8>
                  vector.transfer_write %12, %arg2[%arg3, %6, %arg5, %arg6] : vector<2xi8>, memref<1x32x32x64xi8>
                } {loop_directive = #hls.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>}
              } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>}
            } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>}
          } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>}
        } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>}
      } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>}
    } {loop_directive = #hls.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>}
    return
  }
}
