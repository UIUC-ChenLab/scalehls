// RUN: scalehls-opt -scalehls-create-func-dataflow %s | FileCheck -check-prefix=FUNC %s
// RUN: scalehls-opt -scalehls-create-loop-dataflow -canonicalize %s | FileCheck -check-prefix=LOOP %s

#map = affine_map<(d0, d1) -> (d0 + d1 * 4)>
#set0 = affine_set<(d0, d1, d2) : (d0 == 0, d1 == 0, d2 == 0)>
#set1 = affine_set<(d0, d1, d2) : (-d0 + 2 == 0, -d1 + 2 == 0, -d2 + 63 == 0)>
module {
  // FUNC: func.func @forward_dataflow6(%arg0: memref<1x32x32x64xi8, 3>, %arg1: !hls.stream<i1, 1>, %arg2: memref<3x3x64x64xi8, 3>, %arg3: memref<1x32x32x64xi8, 3>, %arg4: !hls.stream<i1, 1>, %arg5: !hls.stream<i1, 1>) {
  func.func @forward_dataflow6(%arg0: memref<1x32x32x64xi8, 3>, %arg1: !hls.stream<i1, 1>, %arg2: memref<3x3x64x64xi8, 3>, %arg3: memref<1x32x32x64xi8, 3>, %arg4: !hls.stream<i1, 1>, %arg5: !hls.stream<i1, 1>) {
    %c127_i8 = arith.constant 127 : i8
    %cst = arith.constant dense<5> : tensor<64xi8>
    %c0_i8 = arith.constant 0 : i8
    %false = arith.constant false
    %0 = memref.alloc() : memref<1x1x1x1xi8>
    %1 = bufferization.to_memref %cst : memref<64xi8>
    "hls.stream.read"(%arg1) : (!hls.stream<i1, 1>) -> ()
    %2 = memref.alloc() : memref<1x4x4x4xi8>
    %3 = memref.alloc() : memref<1x1x4x4xi8>
    %4 = memref.alloc() : memref<1x4x4x4xi8>

    // FUNC: %5:5 = hls.dataflow.node() -> memref<1x4x4x4xi8>, memref<1x1x4x4xi8>, memref<1x1x1x1xi8>, memref<1x4x4x4xi8>, memref<1x32x32x64xi8, 3> {
    // FUNC:   "hls.stream.read"(%arg1) : (!hls.stream<i1, 1>) -> ()
    // FUNC:   affine.for %arg6 = 0 to 8
    // FUNC:   }
    // FUNC:   "hls.dataflow.output"(%2, %1, %3, %0, %arg3) : (memref<1x4x4x4xi8>, memref<1x1x4x4xi8>, memref<1x1x1x1xi8>, memref<1x4x4x4xi8>, memref<1x32x32x64xi8, 3>) -> ()
    // FUNC: }
    affine.for %arg6 = 0 to 8 {
      affine.for %arg7 = 0 to 8 {
        affine.for %arg8 = 0 to 16 {
          affine.for %arg9 = 0 to 3 {
            affine.for %arg10 = 0 to 3 {
              affine.for %arg11 = 0 to 16 {

                // LOOP: %5 = hls.dataflow.node() -> memref<1x4x4x4xi8> {
                // LOOP:   affine.for %arg12 = 0 to 4 {
                // LOOP:     affine.for %arg13 = 0 to 4 {
                // LOOP:       affine.for %arg14 = 0 to 4 {
                // LOOP:         %9 = affine.load %arg0[0, %arg12 + %arg9 + %arg6 * 4 - 1, %arg13 + %arg10 + %arg7 * 4 - 1, %arg14 + %arg11 * 4] : memref<1x32x32x64xi8, 3>
                // LOOP:         affine.store %9, %2[0, %arg12, %arg13, %arg14] : memref<1x4x4x4xi8>
                // LOOP:       }
                // LOOP:     }
                // LOOP:   }
                // LOOP:   "hls.dataflow.output"(%2) : (memref<1x4x4x4xi8>) -> ()
                // LOOP: }
                affine.for %arg12 = 0 to 4 {
                  affine.for %arg13 = 0 to 4 {
                    affine.for %arg14 = 0 to 4 {
                      %5 = affine.load %arg0[0, %arg12 + %arg9 + %arg6 * 4 - 1, %arg13 + %arg10 + %arg7 * 4 - 1, %arg14 + %arg11 * 4] : memref<1x32x32x64xi8, 3>
                      affine.store %5, %2[0, %arg12, %arg13, %arg14] : memref<1x4x4x4xi8>
                    }
                  }
                }

                // LOOP: %6 = hls.dataflow.node() -> memref<1x1x4x4xi8> {
                // LOOP:   affine.for %arg12 = 0 to 4 {
                // LOOP:     affine.for %arg13 = 0 to 4 {
                // LOOP:       %9 = affine.load %arg2[%arg9, %arg10, %arg12 + %arg11 * 4, %arg13 + %arg8 * 4] : memref<3x3x64x64xi8, 3>
                // LOOP:       affine.store %9, %3[0, 0, %arg12, %arg13] : memref<1x1x4x4xi8>
                // LOOP:     }
                // LOOP:   }
                // LOOP:   "hls.dataflow.output"(%3) : (memref<1x1x4x4xi8>) -> ()
                // LOOP: }
                affine.for %arg12 = 0 to 4 {
                  affine.for %arg13 = 0 to 4 {
                    %5 = affine.load %arg2[%arg9, %arg10, %arg12 + %arg11 * 4, %arg13 + %arg8 * 4] : memref<3x3x64x64xi8, 3>
                    affine.store %5, %3[0, 0, %arg12, %arg13] : memref<1x1x4x4xi8>
                  }
                }

                // LOOP: %7 = hls.dataflow.node() -> memref<1x4x4x4xi8> {
                // LOOP:     affine.for %arg12 = 0 to 4 {
                // LOOP:       affine.for %arg13 = 0 to 4 {
                // LOOP:         affine.for %arg14 = 0 to 4 {
                // LOOP:           affine.for %arg15 = 0 to 4 {
                // LOOP:           } {point}
                // LOOP:         } {point}
                // LOOP:       } {point}
                // LOOP:     } {point}
                // LOOP:     "hls.dataflow.output"(%4) : (memref<1x4x4x4xi8>) -> ()
                // LOOP:   }
                affine.for %arg12 = 0 to 4 {
                  affine.for %arg13 = 0 to 4 {
                    affine.for %arg14 = 0 to 4 {
                      affine.for %arg15 = 0 to 4 {
                        %5 = affine.apply #map(%arg15, %arg11)
                        affine.if #set0(%arg9, %arg10, %5) {
                          affine.store %c0_i8, %0[0, 0, 0, 0] : memref<1x1x1x1xi8>
                        }
                        %6 = affine.load %2[0, %arg12, %arg13, %arg15] : memref<1x4x4x4xi8>
                        %7 = affine.load %3[0, 0, %arg15, %arg14] : memref<1x1x4x4xi8>
                        %8 = affine.load %0[0, 0, 0, 0] : memref<1x1x1x1xi8>
                        %9 = arith.muli %6, %7 : i8
                        %10 = arith.addi %8, %9 : i8
                        affine.store %10, %0[0, 0, 0, 0] : memref<1x1x1x1xi8>
                        %11 = affine.load %1[%arg14 + %arg8 * 4] : memref<64xi8>
                        %12 = arith.addi %11, %10 : i8
                        %13 = arith.cmpi slt, %12, %c0_i8 : i8
                        %14 = arith.select %13, %c0_i8, %12 : i8
                        %15 = arith.cmpi slt, %c127_i8, %12 : i8
                        %16 = arith.select %15, %c127_i8, %14 : i8
                        affine.if #set1(%arg9, %arg10, %5) {
                          affine.store %16, %4[0, %arg12, %arg13, %arg14] : memref<1x4x4x4xi8>
                        }
                      } {point}
                    } {point}
                  } {point}
                } {point}

                // LOOP: %8 = hls.dataflow.node() -> memref<1x32x32x64xi8, 3> {
                // LOOP:   affine.for %arg12 = 0 to 4 {
                // LOOP:     affine.for %arg13 = 0 to 4 {
                // LOOP:       affine.for %arg14 = 0 to 4 {
                // LOOP:         %9 = affine.load %7[0, %arg12, %arg13, %arg14] : memref<1x4x4x4xi8>
                // LOOP:         affine.store %9, %arg3[0, %arg12 + %arg6 * 4, %arg13 + %arg7 * 4, %arg14 + %arg8 * 4] : memref<1x32x32x64xi8, 3>
                // LOOP:       }
                // LOOP:     }
                // LOOP:   }
                // LOOP:   "hls.dataflow.output"(%arg3) : (memref<1x32x32x64xi8, 3>) -> ()
                // LOOP: }
                affine.for %arg12 = 0 to 4 {
                  affine.for %arg13 = 0 to 4 {
                    affine.for %arg14 = 0 to 4 {
                      %5 = affine.load %4[0, %arg12, %arg13, %arg14] : memref<1x4x4x4xi8>
                      affine.store %5, %arg3[0, %arg12 + %arg6 * 4, %arg13 + %arg7 * 4, %arg14 + %arg8 * 4] : memref<1x32x32x64xi8, 3>
                    }
                  }
                }
              }
            }
          }
        }
      }
    }

    // FUNC: hls.dataflow.node() {
    // FUNC:   "hls.stream.write"(%arg4, %false) : (!hls.stream<i1, 1>, i1) -> ()
    // FUNC:   "hls.stream.write"(%arg5, %false) : (!hls.stream<i1, 1>, i1) -> ()
    // FUNC: }
    "hls.stream.write"(%arg4, %false) : (!hls.stream<i1, 1>, i1) -> ()
    "hls.stream.write"(%arg5, %false) : (!hls.stream<i1, 1>, i1) -> ()
    return
  }
}

