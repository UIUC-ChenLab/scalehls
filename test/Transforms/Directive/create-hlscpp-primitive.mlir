// RUN: scalehls-opt -scalehls-create-hlscpp-primitive %s | FileCheck %s

#map0 = affine_map<(d0, d1, d2, d3) -> (0, 0, 0, 0, d0, d1, d2, d3)>
#map1 = affine_map<(d0, d1, d2, d3) -> (0, 0, 0, d3 mod 2, d0, d1, d2, d3 floordiv 2)>
#map2 = affine_map<(d0, d1, d2, d3) -> (0, d1 mod 2, 0, d3 mod 2, d0, d1 floordiv 2, d2, d3 floordiv 2)>
#map3 = affine_map<(d0) -> (d0 + 1)>
module {
  func @test_conv2d(%arg0: memref<1x34x34x64xi8, #map0>, %arg1: memref<3x3x64x64xi8, #map1>, %arg2: memref<1x32x32x64xi8, #map2>) attributes {top_func} {
    %c0_i8 = arith.constant 0 : i8
    affine.for %arg3 = 0 to 1 {
      affine.for %arg4 = 0 to 32 step 2 {
        affine.for %arg5 = 0 to 32 {
          affine.for %arg6 = 0 to 64 step 2 {
            affine.for %arg7 = 0 to 3 {
              affine.for %arg8 = 0 to 3 {
                affine.for %arg9 = 0 to 64 {
                  %0 = affine.load %arg0[%arg3, %arg4 + %arg7, %arg5 + %arg8, %arg9] : memref<1x34x34x64xi8, #map0>

                  // CHECK-NOT: %1 = vector.broadcast %0 : i8 to vector<2xi8>
                  %1 = vector.broadcast %0 : i8 to vector<2xi8>
                  %2 = vector.transfer_read %arg1[%arg7, %arg8, %arg9, %arg6], %c0_i8 : memref<3x3x64x64xi8, #map1>, vector<2xi8>
                  %3 = vector.transfer_read %arg2[%arg3, %arg4, %arg5, %arg6], %c0_i8 : memref<1x32x32x64xi8, #map2>, vector<2xi8>
                  
                  // CHECK: %3 = "hlscpp.prim.mul"(%0, %1) : (i8, vector<2xi8>) -> vector<2xi16>
                  // CHECK: %4 = "hlscpp.prim.cast"(%3) : (vector<2xi16>) -> vector<2xi8>
                  %4 = arith.muli %1, %2 : vector<2xi8>

                  // CHECK: %5 = "hlscpp.prim.cast"(%2) : (vector<2xi8>) -> vector<2xi32>
                  // CHECK: %6 = "hlscpp.prim.cast"(%4) : (vector<2xi8>) -> vector<2xi32>
                  // CHECK: %7 = arith.addi %5, %6 : vector<2xi32>
                  // CHECK: %8 = "hlscpp.prim.cast"(%7) : (vector<2xi32>) -> vector<2xi8>
                  %5 = arith.addi %3, %4 : vector<2xi8>
                  vector.transfer_write %5, %arg2[%arg3, %arg4, %arg5, %arg6] : vector<2xi8>, memref<1x32x32x64xi8, #map2>
                  %6 = affine.apply #map3(%arg4)
                  %7 = affine.load %arg0[%arg3, %arg7 + %arg4 + 1, %arg5 + %arg8, %arg9] : memref<1x34x34x64xi8, #map0>
                  %8 = vector.broadcast %7 : i8 to vector<2xi8>
                  %9 = vector.transfer_read %arg1[%arg7, %arg8, %arg9, %arg6], %c0_i8 : memref<3x3x64x64xi8, #map1>, vector<2xi8>
                  %10 = vector.transfer_read %arg2[%arg3, %6, %arg5, %arg6], %c0_i8 : memref<1x32x32x64xi8, #map2>, vector<2xi8>
                  %11 = arith.muli %8, %9 : vector<2xi8>
                  %12 = arith.addi %10, %11 : vector<2xi8>
                  vector.transfer_write %12, %arg2[%arg3, %6, %arg5, %arg6] : vector<2xi8>, memref<1x32x32x64xi8, #map2>
                } {loop_directive = #hlscpp.ld<pipeline=true, targetII=1, dataflow=false, flatten=false>}
              } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>}
            } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>}
          } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>}
        } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>}
      } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>}
    } {loop_directive = #hlscpp.ld<pipeline=false, targetII=1, dataflow=false, flatten=true>}
    return
  }
}
