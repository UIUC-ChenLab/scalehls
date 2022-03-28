// RUN: scalehls-opt -scalehls-affine-loop-tile="tile-size=4" %s | FileCheck %s

// CHECK: #map0 = affine_map<(d0) -> (d0)>
// CHECK: #map1 = affine_map<(d0) -> (d0 + 4)>
// CHECK: #map2 = affine_map<(d0) -> (d0 + 1)>
// CHECK: #set0 = affine_set<(d0, d1, d2) : (d0 == 0, d1 == 0, d2 == 0)>
// CHECK: #set1 = affine_set<(d0, d1, d2) : (-d0 + 2 == 0, -d1 + 2 == 0, -d2 + 63 == 0)>

#set0 = affine_set<(d0, d1, d2) : (d0 == 0, d1 == 0, d2 == 0)>
#set1 = affine_set<(d0, d1, d2) : (-d0 + 2 == 0, -d1 + 2 == 0, -d2 + 63 == 0)>
module {
  func @forward_dataflow6(%arg0: memref<1x32x32x64xi8, 3>, %arg1: !hls.stream<i1, 1>, %arg2: memref<3x3x64x64xi8, 3>, %arg3: memref<1x32x32x64xi8, 3>, %arg4: !hls.stream<i1, 1>, %arg5: !hls.stream<i1, 1>) attributes {func_directive = #hls.fd<pipeline=false, targetInterval=1, dataflow=true>} {
    %false = arith.constant false
    %c0_i8 = arith.constant 0 : i8
    %cst = arith.constant dense<5> : tensor<64xi8>
    %c127_i8 = arith.constant 127 : i8
    %0 = memref.alloc() : memref<1x1x1x1xi8>
    %1 = bufferization.to_memref %cst : memref<64xi8>
    "hls.stream.read"(%arg1) : (!hls.stream<i1, 1>) -> ()

    // CHECK: affine.for %arg6 = 0 to 32 step 4 {
    // CHECK:   affine.for %arg7 = 0 to 32 step 4 {
    // CHECK:     affine.for %arg8 = 0 to 64 step 4 {
    // CHECK:       affine.for %arg9 = 0 to 3 {
    // CHECK:         affine.for %arg10 = 0 to 3 {
    // CHECK:           affine.for %arg11 = 0 to 64 step 4 {
    affine.for %arg6 = 0 to 32 {
      affine.for %arg7 = 0 to 32 {
        affine.for %arg8 = 0 to 64 {
          affine.for %arg9 = 0 to 3 {
            affine.for %arg10 = 0 to 3 {
              affine.for %arg11 = 0 to 64 {

                // CHECK: affine.for %arg12 = #map0(%arg6) to #map1(%arg6) {
                // CHECK:   affine.for %arg13 = #map0(%arg7) to #map1(%arg7) {
                // CHECK:     affine.for %arg14 = #map0(%arg8) to #map1(%arg8) {
                // CHECK:       affine.for %arg15 = #map0(%arg9) to #map2(%arg9) {
                // CHECK:         affine.for %arg16 = #map0(%arg10) to #map2(%arg10) {
                // CHECK:           affine.for %arg17 = #map0(%arg11) to #map1(%arg11) {
                // CHECK:           } {point}
                // CHECK:         } {point}
                // CHECK:       } {point}
                // CHECK:     } {point}
                // CHECK:   } {point}
                // CHECK: } {point}
                affine.if #set0(%arg9, %arg10, %arg11) {
                  affine.store %c0_i8, %0[0, 0, 0, 0] : memref<1x1x1x1xi8>
                }
                %2 = affine.load %arg0[0, %arg6 + %arg9 - 1, %arg7 + %arg10 - 1, %arg11] : memref<1x32x32x64xi8, 3>
                %3 = affine.load %arg2[%arg9, %arg10, %arg11, %arg8] : memref<3x3x64x64xi8, 3>
                %4 = affine.load %0[0, 0, 0, 0] : memref<1x1x1x1xi8>
                %5 = arith.muli %2, %3 : i8
                %6 = arith.addi %4, %5 : i8
                affine.store %6, %0[0, 0, 0, 0] : memref<1x1x1x1xi8>
                %7 = affine.load %1[%arg8] : memref<64xi8>
                %8 = arith.addi %7, %6 : i8
                %9 = arith.cmpi slt, %8, %c0_i8 : i8
                %10 = arith.select %9, %c0_i8, %8 : i8
                %11 = arith.cmpi slt, %c127_i8, %8 : i8
                %12 = arith.select %11, %c127_i8, %10 : i8
                affine.if #set1(%arg9, %arg10, %arg11) {
                  affine.store %12, %arg3[0, %arg6, %arg7, %arg8] : memref<1x32x32x64xi8, 3>
                }
              }
            }
          }
        }
      }
    }
    "hls.stream.write"(%arg4, %false) : (!hls.stream<i1, 1>, i1) -> ()
    "hls.stream.write"(%arg5, %false) : (!hls.stream<i1, 1>, i1) -> ()
    return
  }
}
