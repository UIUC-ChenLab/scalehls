// RUN: scalehls-opt -scalehls-raise-affine-to-copy %s | FileCheck %s

// CHECK: module attributes {torch.debug_module_name = "ResNet"} {
// CHECK:   func.func @forward(%arg0: memref<1x64x56x56xi8>, %arg1: memref<1000x64xi8>, %arg2: memref<64x64x1x1xi8>, %arg3: memref<64x64x3x3xi8>, %arg4: memref<64x64x3x3xi8>, %arg5: memref<1x1000xi8>) attributes {top_func} {
// CHECK:     %c-24_i8 = arith.constant -24 : i8
// CHECK:     hls.dataflow.dispatch {
// CHECK:       hls.dataflow.task {
// CHECK:         affine.for %arg6 = 0 to 64 {
// CHECK:           affine.for %arg7 = 0 to 56 {
// CHECK:             affine.for %arg8 = 0 to 56 {
// CHECK:               %4 = affine.load %arg0[0, %arg6, %arg7, %arg8] : memref<1x64x56x56xi8>
// CHECK:               %5 = arith.cmpi ugt, %4, %c-24_i8 : i8
// CHECK:               %6 = arith.select %5, %4, %c-24_i8 : i8
// CHECK:               affine.store %6, %arg0[0, %arg6, %arg7, %arg8] : memref<1x64x56x56xi8>
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:       }
// CHECK:       %0 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
// CHECK:       hls.dataflow.task {
// CHECK:         %4 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x56x56xi8>
// CHECK:         affine.for %arg6 = 0 to 64 {
// CHECK:           memref.copy %arg0, %4 : memref<1x64x56x56xi8> to memref<1x64x56x56xi8>
// CHECK:           affine.for %arg7 = 0 to 28 {
// CHECK:             affine.for %arg8 = 0 to 28 {
// CHECK:               affine.for %arg9 = 0 to 64 {
// CHECK:                 affine.for %arg10 = 0 to 3 {
// CHECK:                   affine.for %arg11 = 0 to 3 {
// CHECK:                     %8 = affine.load %4[0, %arg9, %arg7 * 2 + %arg10 - 1, %arg8 * 2 + %arg11 - 1] : memref<1x64x56x56xi8>
// CHECK:                     %9 = affine.load %arg4[%arg6, %arg9, %arg10, %arg11] : memref<64x64x3x3xi8>
// CHECK:                     %10 = affine.load %0[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
// CHECK:                     %11 = arith.muli %8, %9 : i8
// CHECK:                     %12 = arith.addi %10, %11 : i8
// CHECK:                     affine.store %12, %0[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
// CHECK:                   }
// CHECK:                 }
// CHECK:               }
// CHECK:               %5 = affine.load %0[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
// CHECK:               %6 = arith.cmpi ugt, %5, %c-24_i8 : i8
// CHECK:               %7 = arith.select %6, %5, %c-24_i8 : i8
// CHECK:               affine.store %7, %0[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:       }
// CHECK:       %1 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
// CHECK:       hls.dataflow.task {
// CHECK:         %4 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
// CHECK:         affine.for %arg6 = 0 to 64 {
// CHECK:           affine.for %arg7 = 0 to 28 {
// CHECK:             affine.for %arg8 = 0 to 28 {
// CHECK:               memref.copy %0, %4 : memref<1x64x28x28xi8> to memref<1x64x28x28xi8>
// CHECK:               affine.for %arg9 = 0 to 64 {
// CHECK:                 affine.for %arg10 = 0 to 3 {
// CHECK:                   affine.for %arg11 = 0 to 3 {
// CHECK:                     %5 = affine.load %4[0, %arg9, %arg7 + %arg10 - 1, %arg8 + %arg11 - 1] : memref<1x64x28x28xi8>
// CHECK:                     %6 = affine.load %arg3[%arg6, %arg9, %arg10, %arg11] : memref<64x64x3x3xi8>
// CHECK:                     %7 = affine.load %1[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
// CHECK:                     %8 = arith.muli %5, %6 : i8
// CHECK:                     %9 = arith.addi %7, %8 : i8
// CHECK:                     affine.store %9, %1[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
// CHECK:                   }
// CHECK:                 }
// CHECK:               }
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:       }
// CHECK:       %2 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x28x28xi8>
// CHECK:       hls.dataflow.task {
// CHECK:         %4 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
// CHECK:         affine.for %arg6 = 0 to 64 {
// CHECK:           affine.for %arg7 = 0 to 28 {
// CHECK:             affine.for %arg8 = 0 to 28 {
// CHECK:               affine.for %arg9 = 0 to 64 {
// CHECK:                 %10 = affine.load %arg0[0, %arg9, %arg7 * 2, %arg8 * 2] : memref<1x64x56x56xi8>
// CHECK:                 %11 = affine.load %arg2[%arg6, %arg9, 0, 0] : memref<64x64x1x1xi8>
// CHECK:                 %12 = affine.load %4[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
// CHECK:                 %13 = arith.muli %10, %11 : i8
// CHECK:                 %14 = arith.addi %12, %13 : i8
// CHECK:                 affine.store %14, %4[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
// CHECK:               }
// CHECK:               %5 = affine.load %1[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
// CHECK:               %6 = affine.load %4[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
// CHECK:               %7 = arith.addi %5, %6 : i8
// CHECK:               %8 = arith.cmpi ugt, %7, %c-24_i8 : i8
// CHECK:               %9 = arith.select %8, %7, %c-24_i8 : i8
// CHECK:               affine.store %9, %2[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:       }
// CHECK:       %3 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x1x1xi8>
// CHECK:       hls.dataflow.task {
// CHECK:         affine.for %arg6 = 0 to 64 {
// CHECK:           affine.for %arg7 = 0 to 28 {
// CHECK:             affine.for %arg8 = 0 to 28 {
// CHECK:               %6 = affine.load %2[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
// CHECK:               %7 = affine.load %3[0, %arg6, 0, 0] : memref<1x64x1x1xi8>
// CHECK:               %8 = arith.addi %7, %6 : i8
// CHECK:               affine.store %8, %3[0, %arg6, 0, 0] : memref<1x64x1x1xi8>
// CHECK:             }
// CHECK:           }
// CHECK:           %4 = affine.load %3[0, %arg6, 0, 0] : memref<1x64x1x1xi8>
// CHECK:           %5 = arith.divui %4, %c-24_i8 : i8
// CHECK:           affine.store %5, %3[0, %arg6, 0, 0] : memref<1x64x1x1xi8>
// CHECK:         } {parallel}
// CHECK:       }
// CHECK:       hls.dataflow.task {
// CHECK:         affine.for %arg6 = 0 to 1000 {
// CHECK:           affine.store %c-24_i8, %arg5[0, %arg6] : memref<1x1000xi8>
// CHECK:           affine.for %arg7 = 0 to 64 {
// CHECK:             %4 = affine.load %3[0, %arg7, 0, 0] : memref<1x64x1x1xi8>
// CHECK:             %5 = affine.load %arg1[%arg6, %arg7] : memref<1000x64xi8>
// CHECK:             %6 = affine.load %arg5[0, %arg6] : memref<1x1000xi8>
// CHECK:             %7 = arith.muli %4, %5 : i8
// CHECK:             %8 = arith.addi %6, %7 : i8
// CHECK:             affine.store %8, %arg5[0, %arg6] : memref<1x1000xi8>
// CHECK:           }
// CHECK:         } {parallel}
// CHECK:       }
// CHECK:     }
// CHECK:     return
// CHECK:   }
// CHECK: }

module attributes {torch.debug_module_name = "ResNet"} {
  func.func @forward(%arg0: memref<1x64x56x56xi8>, %arg1: memref<1000x64xi8>, %arg2: memref<64x64x1x1xi8>, %arg3: memref<64x64x3x3xi8>, %arg4: memref<64x64x3x3xi8>, %arg5: memref<1x1000xi8>) attributes {top_func} {
    %c-24_i8 = arith.constant -24 : i8
    hls.dataflow.dispatch {
      hls.dataflow.task {
        affine.for %arg6 = 0 to 64 {
          affine.for %arg7 = 0 to 56 {
            affine.for %arg8 = 0 to 56 {
              %4 = affine.load %arg0[0, %arg6, %arg7, %arg8] : memref<1x64x56x56xi8>
              %5 = arith.cmpi ugt, %4, %c-24_i8 : i8
              %6 = arith.select %5, %4, %c-24_i8 : i8
              affine.store %6, %arg0[0, %arg6, %arg7, %arg8] : memref<1x64x56x56xi8>
            } {parallel}
          } {parallel}
        } {parallel}
      }
      %0 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
      hls.dataflow.task {
        %4 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x56x56xi8>
        affine.for %arg6 = 0 to 64 {
          affine.for %arg7 = 0 to 64 {
            affine.for %arg8 = 0 to 56 {
              affine.for %arg9 = 0 to 56 {
                %5 = affine.load %arg0[0, %arg7, %arg8, %arg9] : memref<1x64x56x56xi8>
                affine.store %5, %4[0, %arg7, %arg8, %arg9] : memref<1x64x56x56xi8>
              } {parallel, point}
            } {parallel, point}
          } {parallel, point}
          affine.for %arg7 = 0 to 28 {
            affine.for %arg8 = 0 to 28 {
              affine.for %arg9 = 0 to 64 {
                affine.for %arg10 = 0 to 3 {
                  affine.for %arg11 = 0 to 3 {
                    %8 = affine.load %4[0, %arg9, %arg7 * 2 + %arg10 - 1, %arg8 * 2 + %arg11 - 1] : memref<1x64x56x56xi8>
                    %9 = affine.load %arg4[%arg6, %arg9, %arg10, %arg11] : memref<64x64x3x3xi8>
                    %10 = affine.load %0[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
                    %11 = arith.muli %8, %9 : i8
                    %12 = arith.addi %10, %11 : i8
                    affine.store %12, %0[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
                  }
                }
              }
              %5 = affine.load %0[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
              %6 = arith.cmpi ugt, %5, %c-24_i8 : i8
              %7 = arith.select %6, %5, %c-24_i8 : i8
              affine.store %7, %0[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
            } {parallel}
          } {parallel}
        } {parallel}
      }
      %1 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
      hls.dataflow.task {
        %4 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
        affine.for %arg6 = 0 to 64 {
          affine.for %arg7 = 0 to 28 {
            affine.for %arg8 = 0 to 28 {
              affine.for %arg9 = 0 to 64 {
                affine.for %arg10 = 0 to 28 {
                  affine.for %arg11 = 0 to 28 {
                    %5 = affine.load %0[0, %arg9, %arg10, %arg11] : memref<1x64x28x28xi8>
                    affine.store %5, %4[0, %arg9, %arg10, %arg11] : memref<1x64x28x28xi8>
                  } {parallel, point}
                } {parallel, point}
              } {parallel, point}
              affine.for %arg9 = 0 to 64 {
                affine.for %arg10 = 0 to 3 {
                  affine.for %arg11 = 0 to 3 {
                    %5 = affine.load %4[0, %arg9, %arg7 + %arg10 - 1, %arg8 + %arg11 - 1] : memref<1x64x28x28xi8>
                    %6 = affine.load %arg3[%arg6, %arg9, %arg10, %arg11] : memref<64x64x3x3xi8>
                    %7 = affine.load %1[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
                    %8 = arith.muli %5, %6 : i8
                    %9 = arith.addi %7, %8 : i8
                    affine.store %9, %1[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
                  }
                }
              }
            } {parallel}
          } {parallel}
        } {parallel}
      }
      %2 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x28x28xi8>
      hls.dataflow.task {
        %4 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8>
        affine.for %arg6 = 0 to 64 {
          affine.for %arg7 = 0 to 28 {
            affine.for %arg8 = 0 to 28 {
              affine.for %arg9 = 0 to 64 {
                %10 = affine.load %arg0[0, %arg9, %arg7 * 2, %arg8 * 2] : memref<1x64x56x56xi8>
                %11 = affine.load %arg2[%arg6, %arg9, 0, 0] : memref<64x64x1x1xi8>
                %12 = affine.load %4[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
                %13 = arith.muli %10, %11 : i8
                %14 = arith.addi %12, %13 : i8
                affine.store %14, %4[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
              }
              %5 = affine.load %1[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
              %6 = affine.load %4[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
              %7 = arith.addi %5, %6 : i8
              %8 = arith.cmpi ugt, %7, %c-24_i8 : i8
              %9 = arith.select %8, %7, %c-24_i8 : i8
              affine.store %9, %2[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
            } {parallel}
          } {parallel}
        } {parallel}
      }
      %3 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x1x1xi8>
      hls.dataflow.task {
        affine.for %arg6 = 0 to 64 {
          affine.for %arg7 = 0 to 28 {
            affine.for %arg8 = 0 to 28 {
              %6 = affine.load %2[0, %arg6, %arg7, %arg8] : memref<1x64x28x28xi8>
              %7 = affine.load %3[0, %arg6, 0, 0] : memref<1x64x1x1xi8>
              %8 = arith.addi %7, %6 : i8
              affine.store %8, %3[0, %arg6, 0, 0] : memref<1x64x1x1xi8>
            }
          }
          %4 = affine.load %3[0, %arg6, 0, 0] : memref<1x64x1x1xi8>
          %5 = arith.divui %4, %c-24_i8 : i8
          affine.store %5, %3[0, %arg6, 0, 0] : memref<1x64x1x1xi8>
        } {parallel}
      }
      hls.dataflow.task {
        affine.for %arg6 = 0 to 1000 {
          affine.store %c-24_i8, %arg5[0, %arg6] : memref<1x1000xi8>
          affine.for %arg7 = 0 to 64 {
            %5 = affine.load %3[0, %arg7, 0, 0] : memref<1x64x1x1xi8>
            %6 = affine.load %arg1[%arg6, %arg7] : memref<1000x64xi8>
            %7 = affine.load %arg5[0, %arg6] : memref<1x1000xi8>
            %8 = arith.muli %5, %6 : i8
            %9 = arith.addi %7, %8 : i8
            affine.store %9, %arg5[0, %arg6] : memref<1x1000xi8>
          }
        } {parallel}
      }
    }
    return
  }
}

