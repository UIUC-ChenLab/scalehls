// RUN: scalehls-opt -scalehls-promote-buffer %s | FileCheck %s

#map0 = affine_map<(d0, d1) -> (d0 + d1 * 4 - 1)>
#map1 = affine_map<(d0) -> (d0 * 4)>
#map2 = affine_map<(d0, d1, d2, d3)[s0] -> (d0 * 65536 + s0 + d1 * 2048 + d2 * 64 + d3)>
#map3 = affine_map<(d0, d1, d2, d3)[s0] -> (d0 * 12288 + s0 + d1 * 4096 + d2 * 64 + d3)>
#map4 = affine_map<(d0, d1) -> (d0 + d1 * 4)>
#set0 = affine_set<(d0, d1, d2) : (d0 == 0, d1 == 0, d2 == 0)>
#set1 = affine_set<(d0, d1, d2) : (-d0 + 2 == 0, -d1 + 2 == 0, -d2 + 63 == 0)>
module {
  func @forward_dataflow6(%arg0: memref<1x32x32x64xi8, 3>, %arg1: !hlscpp.stream<i1, 1>, %arg2: memref<3x3x64x64xi8, 3>, %arg3: memref<1x32x32x64xi8, 3>, %arg4: !hlscpp.stream<i1, 1>, %arg5: !hlscpp.stream<i1, 1>) attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=true>} {
    %false = arith.constant false
    %c0_i8 = arith.constant 0 : i8
    %cst = arith.constant dense<5> : tensor<64xi8>
    %c127_i8 = arith.constant 127 : i8
    %0 = memref.alloc() : memref<1x1x1x1xi8>
    %1 = bufferization.to_memref %cst : memref<64xi8>
    "hlscpp.stream.read"(%arg1) : (!hlscpp.stream<i1, 1>) -> ()
    affine.for %arg6 = 0 to 8 {
      affine.for %arg7 = 0 to 8 {
        affine.for %arg8 = 0 to 16 {
          affine.for %arg9 = 0 to 3 {
            affine.for %arg10 = 0 to 3 {
              affine.for %arg11 = 0 to 16 {
                %2 = affine.apply #map0(%arg9, %arg6)
                %3 = affine.apply #map0(%arg10, %arg7)
                %4 = affine.apply #map1(%arg11)
                %5 = memref.subview %arg0[0, %2, %3, %4] [1, 4, 4, 4] [1, 1, 1, 1] : memref<1x32x32x64xi8, 3> to memref<1x4x4x4xi8, #map2, 3>

                // CHECK: %6 = memref.alloc() : memref<1x4x4x4xi8>
                // CHECK: memref.copy %5, %6 : memref<1x4x4x4xi8, #map2, 3> to memref<1x4x4x4xi8>
                %6 = affine.apply #map1(%arg8)
                %7 = memref.subview %arg2[%arg9, %arg10, %4, %6] [1, 1, 4, 4] [1, 1, 1, 1] : memref<3x3x64x64xi8, 3> to memref<1x1x4x4xi8, #map3, 3>

                // CHECK: %9 = memref.alloc() : memref<1x1x4x4xi8>
                // CHECK: memref.copy %8, %9 : memref<1x1x4x4xi8, #map3, 3> to memref<1x1x4x4xi8>
                %8 = affine.apply #map1(%arg6)
                %9 = affine.apply #map1(%arg7)
                %10 = memref.subview %arg3[0, %8, %9, %6] [1, 4, 4, 4] [1, 1, 1, 1] : memref<1x32x32x64xi8, 3> to memref<1x4x4x4xi8, #map2, 3>

                // CHECK: %13 = memref.alloc() : memref<1x4x4x4xi8>
                affine.for %arg12 = 0 to 4 {
                  affine.for %arg13 = 0 to 4 {
                    affine.for %arg14 = 0 to 4 {
                      affine.for %arg15 = 0 to 4 {
                        %11 = affine.apply #map4(%arg15, %arg11)
                        affine.if #set0(%arg9, %arg10, %11) {
                          affine.store %c0_i8, %0[0, 0, 0, 0] : memref<1x1x1x1xi8>
                        }
                        %12 = affine.load %5[0, %arg12, %arg13, %arg15] : memref<1x4x4x4xi8, #map2, 3>
                        %13 = affine.load %7[0, 0, %arg15, %arg14] : memref<1x1x4x4xi8, #map3, 3>
                        %14 = affine.load %0[0, 0, 0, 0] : memref<1x1x1x1xi8>
                        %15 = arith.muli %12, %13 : i8
                        %16 = arith.addi %14, %15 : i8
                        affine.store %16, %0[0, 0, 0, 0] : memref<1x1x1x1xi8>
                        %17 = affine.load %1[%arg14 + %arg8 * 4] : memref<64xi8>
                        %18 = arith.addi %17, %16 : i8
                        %19 = arith.cmpi slt, %18, %c0_i8 : i8
                        %20 = arith.select %19, %c0_i8, %18 : i8
                        %21 = arith.cmpi slt, %c127_i8, %18 : i8
                        %22 = arith.select %21, %c127_i8, %20 : i8
                        affine.if #set1(%arg9, %arg10, %11) {
                          affine.store %22, %10[0, %arg12, %arg13, %arg14] : memref<1x4x4x4xi8, #map2, 3>
                        }
                      } {point}
                    } {point}
                  } {point}
                } {point}

                // CHECK: memref.copy %13, %12 : memref<1x4x4x4xi8> to memref<1x4x4x4xi8, #map2, 3>
              }
            }
          }
        }
      }
    }
    "hlscpp.stream.write"(%arg4, %false) : (!hlscpp.stream<i1, 1>, i1) -> ()
    "hlscpp.stream.write"(%arg5, %false) : (!hlscpp.stream<i1, 1>, i1) -> ()
    return
  }
}

