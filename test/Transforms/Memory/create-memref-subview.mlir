// RUN: scalehls-opt -scalehls-create-memref-subview %s | FileCheck %s

// CHECK: #map0 = affine_map<() -> (0)>
// CHECK: #map1 = affine_map<(d0, d1) -> (d0 + d1 * 4 - 1)>
// CHECK: #map2 = affine_map<(d0) -> (d0 * 4)>
// CHECK: #map3 = affine_map<(d0, d1, d2, d3)[s0] -> (d0 * 65536 + s0 + d1 * 2048 + d2 * 64 + d3)>
// CHECK: #map4 = affine_map<(d0) -> (d0)>
// CHECK: #map5 = affine_map<(d0, d1, d2, d3)[s0] -> (d0 * 12288 + s0 + d1 * 4096 + d2 * 64 + d3)>
// CHECK: #map6 = affine_map<(d0, d1) -> (d0 + d1 * 4)>
// CHECK: #set0 = affine_set<(d0, d1, d2) : (d0 == 0, d1 == 0, d2 == 0)>
// CHECK: #set1 = affine_set<(d0, d1, d2) : (-d0 + 2 == 0, -d1 + 2 == 0, -d2 + 63 == 0)>
#map = affine_map<(d0, d1) -> (d0 + d1 * 4)>
#set0 = affine_set<(d0, d1, d2) : (d0 == 0, d1 == 0, d2 == 0)>
#set1 = affine_set<(d0, d1, d2) : (-d0 + 2 == 0, -d1 + 2 == 0, -d2 + 63 == 0)>
module {
  func @forward_dataflow6(%arg0: memref<1x32x32x64xi8, 3>, %arg1: !hls.stream<i1, 1>, %arg2: memref<3x3x64x64xi8, 3>, %arg3: memref<1x32x32x64xi8, 3>, %arg4: !hls.stream<i1, 1>, %arg5: !hls.stream<i1, 1>) attributes {func_directive = #hls.fd<pipeline=false, targetInterval=1, dataflow=true>} {
    %c127_i8 = arith.constant 127 : i8
    %cst = arith.constant dense<5> : tensor<64xi8>
    %c0_i8 = arith.constant 0 : i8
    %false = arith.constant false
    %0 = memref.alloc() : memref<1x1x1x1xi8>
    %1 = bufferization.to_memref %cst : memref<64xi8>
    "hls.stream.read"(%arg1) : (!hls.stream<i1, 1>) -> ()
    affine.for %arg6 = 0 to 8 {
      affine.for %arg7 = 0 to 8 {
        affine.for %arg8 = 0 to 16 {
          affine.for %arg9 = 0 to 3 {
            affine.for %arg10 = 0 to 3 {
              affine.for %arg11 = 0 to 16 {

                // CHECK: %2 = affine.apply #map0()
                // CHECK: %3 = affine.apply #map1(%arg9, %arg6)
                // CHECK: %4 = affine.apply #map1(%arg10, %arg7)
                // CHECK: %5 = affine.apply #map2(%arg11)
                // CHECK: %6 = memref.subview %arg0[%2, %3, %4, %5] [1, 4, 4, 4] [1, 1, 1, 1] : memref<1x32x32x64xi8, 3> to memref<1x4x4x4xi8, #map3, 3>
                // CHECK: %7 = affine.apply #map4(%arg9)
                // CHECK: %8 = affine.apply #map4(%arg10)
                // CHECK: %9 = affine.apply #map2(%arg11)
                // CHECK: %10 = affine.apply #map2(%arg8)
                // CHECK: %11 = memref.subview %arg2[%7, %8, %9, %10] [1, 1, 4, 4] [1, 1, 1, 1] : memref<3x3x64x64xi8, 3> to memref<1x1x4x4xi8, #map5, 3>
                // CHECK: %12 = affine.apply #map0()
                // CHECK: %13 = affine.apply #map2(%arg6)
                // CHECK: %14 = affine.apply #map2(%arg7)
                // CHECK: %15 = affine.apply #map2(%arg8)
                // CHECK: %16 = memref.subview %arg3[%12, %13, %14, %15] [1, 4, 4, 4] [1, 1, 1, 1] : memref<1x32x32x64xi8, 3> to memref<1x4x4x4xi8, #map3, 3>
                affine.for %arg12 = 0 to 4 {
                  affine.for %arg13 = 0 to 4 {
                    affine.for %arg14 = 0 to 4 {
                      affine.for %arg15 = 0 to 4 {
                        %2 = affine.apply #map(%arg15, %arg11)
                        affine.if #set0(%arg9, %arg10, %2) {
                          affine.store %c0_i8, %0[0, 0, 0, 0] : memref<1x1x1x1xi8>
                        }

                        // CHECK: %18 = affine.load %6[0, %arg12, %arg13, %arg15] : memref<1x4x4x4xi8, #map3, 3>
                        %3 = affine.load %arg0[0, %arg9 + %arg12 + %arg6 * 4 - 1, %arg10 + %arg13 + %arg7 * 4 - 1, %arg15 + %arg11 * 4] : memref<1x32x32x64xi8, 3>

                        // CHECK: %19 = affine.load %11[0, 0, %arg15, %arg14] : memref<1x1x4x4xi8, #map5, 3>
                        %4 = affine.load %arg2[%arg9, %arg10, %arg15 + %arg11 * 4, %arg14 + %arg8 * 4] : memref<3x3x64x64xi8, 3>
                        %5 = affine.load %0[0, 0, 0, 0] : memref<1x1x1x1xi8>
                        %6 = arith.muli %3, %4 : i8
                        %7 = arith.addi %5, %6 : i8
                        affine.store %7, %0[0, 0, 0, 0] : memref<1x1x1x1xi8>
                        %8 = affine.load %1[%arg14 + %arg8 * 4] : memref<64xi8>
                        %9 = arith.addi %8, %7 : i8
                        %10 = arith.cmpi slt, %9, %c0_i8 : i8
                        %11 = arith.select %10, %c0_i8, %9 : i8
                        %12 = arith.cmpi slt, %c127_i8, %9 : i8
                        %13 = arith.select %12, %c127_i8, %11 : i8
                        affine.if #set1(%arg9, %arg10, %2) {

                          // CHECK: affine.store %28, %16[0, %arg12, %arg13, %arg14] : memref<1x4x4x4xi8, #map3, 3>
                          affine.store %13, %arg3[0, %arg12 + %arg6 * 4, %arg13 + %arg7 * 4, %arg14 + %arg8 * 4] : memref<1x32x32x64xi8, 3>
                        }
                      } {point}
                    } {point}
                  } {point}
                } {point}
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
