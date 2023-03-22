// RUN: scalehls-opt -scalehls-affine-loop-tile="tile-size=16" %s | FileCheck %s

// CHECK: #map = affine_map<(d0) -> (d0 * 16)>
// CHECK: #map1 = affine_map<(d0) -> (d0 * 14)>
// CHECK: #map2 = affine_map<(d0, d1) -> (d1 + d0)>
// CHECK: #map3 = affine_map<(d0) -> (d0 * 10)>
// CHECK: #set = affine_set<(d0, d1, d2) : (-d0 + 63 == 0, -d1 + 2 == 0, -d2 + 2 == 0)>
// CHECK: #set1 = affine_set<(d0) : (-d0 + 63 == 0)>
// CHECK: #set2 = affine_set<(d0, d1) : (-d0 + 27 == 0, -d1 + 27 == 0)>
// CHECK: #set3 = affine_set<(d0) : (d0 == 0)>
// CHECK: module attributes {torch.debug_module_name = "ResNet"} {
// CHECK:   func.func @forward(%arg0: memref<1x64x56x56xi8, 12>, %arg1: memref<1000x64xi8, 12>, %arg2: memref<64x64x1x1xi8, 12>, %arg3: memref<64x64x3x3xi8, 12>, %arg4: memref<64x64x3x3xi8, 12>, %arg5: memref<1x1000xi8, 12>) attributes {top_func} {
// CHECK:     %c-24_i8 = arith.constant -24 : i8
// CHECK:     hls.dataflow.dispatch {
// CHECK:       hls.dataflow.task {
// CHECK:         affine.for %arg6 = 0 to 4 {
// CHECK:           %5 = affine.apply #map(%arg6)
// CHECK:           affine.for %arg7 = 0 to 4 {
// CHECK:             %6 = affine.apply #map1(%arg7)
// CHECK:             affine.for %arg8 = 0 to 4 {
// CHECK:               %7 = affine.apply #map1(%arg8)
// CHECK:               affine.for %arg9 = 0 to 16 {
// CHECK:                 %8 = affine.apply #map2(%5, %arg9)
// CHECK:                 affine.for %arg10 = 0 to 14 {
// CHECK:                   %9 = affine.apply #map2(%6, %arg10)
// CHECK:                   affine.for %arg11 = 0 to 14 {
// CHECK:                     %10 = affine.apply #map2(%7, %arg11)
// CHECK:                     %11 = affine.load %arg0[0, %8, %9, %10] : memref<1x64x56x56xi8, 12>
// CHECK:                     %12 = arith.cmpi ugt, %11, %c-24_i8 : i8
// CHECK:                     %13 = arith.select %12, %11, %c-24_i8 : i8
// CHECK:                     affine.store %13, %arg0[0, %8, %9, %10] : memref<1x64x56x56xi8, 12>
// CHECK:                   } {parallel, point}
// CHECK:                 } {parallel, point}
// CHECK:               } {parallel, point}
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         } {parallel}
// CHECK:       }
// CHECK:       %0 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8, 12>
// CHECK:       hls.dataflow.task {
// CHECK:         affine.for %arg6 = 0 to 4 {
// CHECK:           %5 = affine.apply #map(%arg6)
// CHECK:           affine.for %arg7 = 0 to 3 {
// CHECK:             affine.for %arg8 = 0 to 3 {
// CHECK:               affine.for %arg9 = 0 to 4 {
// CHECK:                 %6 = affine.apply #map(%arg9)
// CHECK:                 affine.for %arg10 = 0 to 2 {
// CHECK:                   %7 = affine.apply #map1(%arg10)
// CHECK:                   affine.for %arg11 = 0 to 2 {
// CHECK:                     %8 = affine.apply #map1(%arg11)
// CHECK:                     affine.for %arg12 = 0 to 16 {
// CHECK:                       %9 = affine.apply #map2(%5, %arg12)
// CHECK:                       affine.for %arg13 = 0 to 1 {
// CHECK:                         %10 = affine.apply #map2(%arg7, %arg13)
// CHECK:                         affine.for %arg14 = 0 to 1 {
// CHECK:                           %11 = affine.apply #map2(%arg8, %arg14)
// CHECK:                           affine.for %arg15 = 0 to 16 {
// CHECK:                             %12 = affine.apply #map2(%6, %arg15)
// CHECK:                             affine.for %arg16 = 0 to 14 {
// CHECK:                               %13 = affine.apply #map2(%7, %arg16)
// CHECK:                               affine.for %arg17 = 0 to 14 {
// CHECK:                                 %14 = affine.apply #map2(%8, %arg17)
// CHECK:                                 %15 = affine.load %arg0[0, %9, %13 * 2 + %10 - 1, %14 * 2 + %11 - 1] : memref<1x64x56x56xi8, 12>
// CHECK:                                 %16 = affine.load %arg4[%12, %9, %10, %11] : memref<64x64x3x3xi8, 12>
// CHECK:                                 %17 = affine.load %0[0, %12, %13, %14] : memref<1x64x28x28xi8, 12>
// CHECK:                                 %18 = arith.muli %15, %16 : i8
// CHECK:                                 %19 = arith.addi %17, %18 : i8
// CHECK:                                 affine.store %19, %0[0, %12, %13, %14] : memref<1x64x28x28xi8, 12>
// CHECK:                                 %20 = affine.load %0[0, %12, %13, %14] : memref<1x64x28x28xi8, 12>
// CHECK:                                 %21 = arith.cmpi ugt, %20, %c-24_i8 : i8
// CHECK:                                 %22 = arith.select %21, %20, %c-24_i8 : i8
// CHECK:                                 affine.if #set(%9, %10, %11) {
// CHECK:                                   affine.store %22, %0[0, %12, %13, %14] : memref<1x64x28x28xi8, 12>
// CHECK:                                 }
// CHECK:                               } {parallel, point}
// CHECK:                             } {parallel, point}
// CHECK:                           } {parallel, point}
// CHECK:                         } {point}
// CHECK:                       } {point}
// CHECK:                     } {point}
// CHECK:                   } {parallel}
// CHECK:                 } {parallel}
// CHECK:               } {parallel}
// CHECK:             }
// CHECK:           }
// CHECK:         }
// CHECK:       }
// CHECK:       %1 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8, 12>
// CHECK:       hls.dataflow.task {
// CHECK:         affine.for %arg6 = 0 to 4 {
// CHECK:           %5 = affine.apply #map(%arg6)
// CHECK:           affine.for %arg7 = 0 to 3 {
// CHECK:             affine.for %arg8 = 0 to 3 {
// CHECK:               affine.for %arg9 = 0 to 4 {
// CHECK:                 %6 = affine.apply #map(%arg9)
// CHECK:                 affine.for %arg10 = 0 to 2 {
// CHECK:                   %7 = affine.apply #map1(%arg10)
// CHECK:                   affine.for %arg11 = 0 to 2 {
// CHECK:                     %8 = affine.apply #map1(%arg11)
// CHECK:                     affine.for %arg12 = 0 to 16 {
// CHECK:                       %9 = affine.apply #map2(%5, %arg12)
// CHECK:                       affine.for %arg13 = 0 to 1 {
// CHECK:                         %10 = affine.apply #map2(%arg7, %arg13)
// CHECK:                         affine.for %arg14 = 0 to 1 {
// CHECK:                           %11 = affine.apply #map2(%arg8, %arg14)
// CHECK:                           affine.for %arg15 = 0 to 16 {
// CHECK:                             %12 = affine.apply #map2(%6, %arg15)
// CHECK:                             affine.for %arg16 = 0 to 14 {
// CHECK:                               %13 = affine.apply #map2(%7, %arg16)
// CHECK:                               affine.for %arg17 = 0 to 14 {
// CHECK:                                 %14 = affine.apply #map2(%8, %arg17)
// CHECK:                                 %15 = affine.load %0[0, %9, %13 + %10 - 1, %14 + %11 - 1] : memref<1x64x28x28xi8, 12>
// CHECK:                                 %16 = affine.load %arg3[%12, %9, %10, %11] : memref<64x64x3x3xi8, 12>
// CHECK:                                 %17 = affine.load %1[0, %12, %13, %14] : memref<1x64x28x28xi8, 12>
// CHECK:                                 %18 = arith.muli %15, %16 : i8
// CHECK:                                 %19 = arith.addi %17, %18 : i8
// CHECK:                                 affine.store %19, %1[0, %12, %13, %14] : memref<1x64x28x28xi8, 12>
// CHECK:                               } {parallel, point}
// CHECK:                             } {parallel, point}
// CHECK:                           } {parallel, point}
// CHECK:                         } {point}
// CHECK:                       } {point}
// CHECK:                     } {point}
// CHECK:                   } {parallel}
// CHECK:                 } {parallel}
// CHECK:               } {parallel}
// CHECK:             }
// CHECK:           }
// CHECK:         }
// CHECK:       }
// CHECK:       %2 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x28x28xi8, 12>
// CHECK:       %3 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8, 12>
// CHECK:       hls.dataflow.task {
// CHECK:         affine.for %arg6 = 0 to 4 {
// CHECK:           %5 = affine.apply #map(%arg6)
// CHECK:           affine.for %arg7 = 0 to 4 {
// CHECK:             %6 = affine.apply #map(%arg7)
// CHECK:             affine.for %arg8 = 0 to 2 {
// CHECK:               %7 = affine.apply #map1(%arg8)
// CHECK:               affine.for %arg9 = 0 to 2 {
// CHECK:                 %8 = affine.apply #map1(%arg9)
// CHECK:                 affine.for %arg10 = 0 to 16 {
// CHECK:                   %9 = affine.apply #map2(%5, %arg10)
// CHECK:                   affine.for %arg11 = 0 to 16 {
// CHECK:                     %10 = affine.apply #map2(%6, %arg11)
// CHECK:                     affine.for %arg12 = 0 to 14 {
// CHECK:                       %11 = affine.apply #map2(%7, %arg12)
// CHECK:                       affine.for %arg13 = 0 to 14 {
// CHECK:                         %12 = affine.apply #map2(%8, %arg13)
// CHECK:                         %13 = affine.load %arg0[0, %9, %11 * 2, %12 * 2] : memref<1x64x56x56xi8, 12>
// CHECK:                         %14 = affine.load %arg2[%10, %9, 0, 0] : memref<64x64x1x1xi8, 12>
// CHECK:                         %15 = affine.load %3[0, %10, %11, %12] : memref<1x64x28x28xi8, 12>
// CHECK:                         %16 = arith.muli %13, %14 : i8
// CHECK:                         %17 = arith.addi %15, %16 : i8
// CHECK:                         affine.store %17, %3[0, %10, %11, %12] : memref<1x64x28x28xi8, 12>
// CHECK:                         %18 = affine.load %1[0, %10, %11, %12] : memref<1x64x28x28xi8, 12>
// CHECK:                         %19 = affine.load %3[0, %10, %11, %12] : memref<1x64x28x28xi8, 12>
// CHECK:                         %20 = arith.addi %18, %19 : i8
// CHECK:                         %21 = arith.cmpi ugt, %20, %c-24_i8 : i8
// CHECK:                         %22 = arith.select %21, %20, %c-24_i8 : i8
// CHECK:                         affine.if #set1(%9) {
// CHECK:                           affine.store %22, %2[0, %10, %11, %12] : memref<1x64x28x28xi8, 12>
// CHECK:                         }
// CHECK:                       } {parallel, point}
// CHECK:                     } {parallel, point}
// CHECK:                   } {parallel, point}
// CHECK:                 } {point}
// CHECK:               } {parallel}
// CHECK:             } {parallel}
// CHECK:           } {parallel}
// CHECK:         }
// CHECK:       }
// CHECK:       %4 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x1x1xi8, 7>
// CHECK:       hls.dataflow.task {
// CHECK:         affine.for %arg6 = 0 to 2 {
// CHECK:           %5 = affine.apply #map1(%arg6)
// CHECK:           affine.for %arg7 = 0 to 2 {
// CHECK:             %6 = affine.apply #map1(%arg7)
// CHECK:             affine.for %arg8 = 0 to 4 {
// CHECK:               %7 = affine.apply #map(%arg8)
// CHECK:               affine.for %arg9 = 0 to 14 {
// CHECK:                 %8 = affine.apply #map2(%5, %arg9)
// CHECK:                 affine.for %arg10 = 0 to 14 {
// CHECK:                   %9 = affine.apply #map2(%6, %arg10)
// CHECK:                   affine.for %arg11 = 0 to 16 {
// CHECK:                     %10 = affine.apply #map2(%7, %arg11)
// CHECK:                     %11 = affine.load %2[0, %10, %8, %9] : memref<1x64x28x28xi8, 12>
// CHECK:                     %12 = affine.load %4[0, %10, 0, 0] : memref<1x64x1x1xi8, 7>
// CHECK:                     %13 = arith.addi %12, %11 : i8
// CHECK:                     affine.store %13, %4[0, %10, 0, 0] : memref<1x64x1x1xi8, 7>
// CHECK:                     %14 = affine.load %4[0, %10, 0, 0] : memref<1x64x1x1xi8, 7>
// CHECK:                     %15 = arith.divui %14, %c-24_i8 : i8
// CHECK:                     affine.if #set2(%8, %9) {
// CHECK:                       affine.store %15, %4[0, %10, 0, 0] : memref<1x64x1x1xi8, 7>
// CHECK:                     }
// CHECK:                   } {parallel, point}
// CHECK:                 } {point}
// CHECK:               } {point}
// CHECK:             } {parallel}
// CHECK:           }
// CHECK:         }
// CHECK:       }
// CHECK:       hls.dataflow.task {
// CHECK:         affine.for %arg6 = 0 to 4 {
// CHECK:           %5 = affine.apply #map(%arg6)
// CHECK:           affine.for %arg7 = 0 to 100 {
// CHECK:             %6 = affine.apply #map3(%arg7)
// CHECK:             affine.for %arg8 = 0 to 16 {
// CHECK:               %7 = affine.apply #map2(%5, %arg8)
// CHECK:               affine.for %arg9 = 0 to 10 {
// CHECK:                 %8 = affine.apply #map2(%6, %arg9)
// CHECK:                 affine.if #set3(%7) {
// CHECK:                   affine.store %c-24_i8, %arg5[0, %8] : memref<1x1000xi8, 12>
// CHECK:                 }
// CHECK:                 %9 = affine.load %4[0, %7, 0, 0] : memref<1x64x1x1xi8, 7>
// CHECK:                 %10 = affine.load %arg1[%8, %7] : memref<1000x64xi8, 12>
// CHECK:                 %11 = affine.load %arg5[0, %8] : memref<1x1000xi8, 12>
// CHECK:                 %12 = arith.muli %9, %10 : i8
// CHECK:                 %13 = arith.addi %11, %12 : i8
// CHECK:                 affine.store %13, %arg5[0, %8] : memref<1x1000xi8, 12>
// CHECK:               } {parallel, point}
// CHECK:             } {point}
// CHECK:           } {parallel}
// CHECK:         }
// CHECK:       }
// CHECK:     }
// CHECK:     return
// CHECK:   }
// CHECK: }

#set = affine_set<(d0, d1, d2) : (-d0 + 63 == 0, -d1 + 2 == 0, -d2 + 2 == 0)>
#set1 = affine_set<(d0) : (-d0 + 63 == 0)>
#set2 = affine_set<(d0, d1) : (-d0 + 27 == 0, -d1 + 27 == 0)>
#set3 = affine_set<(d0) : (d0 == 0)>
module attributes {torch.debug_module_name = "ResNet"} {
  func.func @forward(%arg0: memref<1x64x56x56xi8, 12>, %arg1: memref<1000x64xi8, 12>, %arg2: memref<64x64x1x1xi8, 12>, %arg3: memref<64x64x3x3xi8, 12>, %arg4: memref<64x64x3x3xi8, 12>, %arg5: memref<1x1000xi8, 12>) attributes {top_func} {
    %c-24_i8 = arith.constant -24 : i8
    hls.dataflow.dispatch {
      hls.dataflow.task {
        affine.for %arg6 = 0 to 64 {
          affine.for %arg7 = 0 to 56 {
            affine.for %arg8 = 0 to 56 {
              %5 = affine.load %arg0[0, %arg6, %arg7, %arg8] : memref<1x64x56x56xi8, 12>
              %6 = arith.cmpi ugt, %5, %c-24_i8 : i8
              %7 = arith.select %6, %5, %c-24_i8 : i8
              affine.store %7, %arg0[0, %arg6, %arg7, %arg8] : memref<1x64x56x56xi8, 12>
            } {parallel}
          } {parallel}
        } {parallel}
      }
      %0 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8, 12>
      hls.dataflow.task {
        affine.for %arg6 = 0 to 64 {
          affine.for %arg7 = 0 to 3 {
            affine.for %arg8 = 0 to 3 {
              affine.for %arg9 = 0 to 64 {
                affine.for %arg10 = 0 to 28 {
                  affine.for %arg11 = 0 to 28 {
                    %5 = affine.load %arg0[0, %arg6, %arg10 * 2 + %arg7 - 1, %arg11 * 2 + %arg8 - 1] : memref<1x64x56x56xi8, 12>
                    %6 = affine.load %arg4[%arg9, %arg6, %arg7, %arg8] : memref<64x64x3x3xi8, 12>
                    %7 = affine.load %0[0, %arg9, %arg10, %arg11] : memref<1x64x28x28xi8, 12>
                    %8 = arith.muli %5, %6 : i8
                    %9 = arith.addi %7, %8 : i8
                    affine.store %9, %0[0, %arg9, %arg10, %arg11] : memref<1x64x28x28xi8, 12>
                    %10 = affine.load %0[0, %arg9, %arg10, %arg11] : memref<1x64x28x28xi8, 12>
                    %11 = arith.cmpi ugt, %10, %c-24_i8 : i8
                    %12 = arith.select %11, %10, %c-24_i8 : i8
                    affine.if #set(%arg6, %arg7, %arg8) {
                      affine.store %12, %0[0, %arg9, %arg10, %arg11] : memref<1x64x28x28xi8, 12>
                    }
                  } {parallel}
                } {parallel}
              } {parallel}
            }
          }
        }
      }
      %1 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8, 12>
      hls.dataflow.task {
        affine.for %arg6 = 0 to 64 {
          affine.for %arg7 = 0 to 3 {
            affine.for %arg8 = 0 to 3 {
              affine.for %arg9 = 0 to 64 {
                affine.for %arg10 = 0 to 28 {
                  affine.for %arg11 = 0 to 28 {
                    %5 = affine.load %0[0, %arg6, %arg10 + %arg7 - 1, %arg11 + %arg8 - 1] : memref<1x64x28x28xi8, 12>
                    %6 = affine.load %arg3[%arg9, %arg6, %arg7, %arg8] : memref<64x64x3x3xi8, 12>
                    %7 = affine.load %1[0, %arg9, %arg10, %arg11] : memref<1x64x28x28xi8, 12>
                    %8 = arith.muli %5, %6 : i8
                    %9 = arith.addi %7, %8 : i8
                    affine.store %9, %1[0, %arg9, %arg10, %arg11] : memref<1x64x28x28xi8, 12>
                  } {parallel}
                } {parallel}
              } {parallel}
            }
          }
        }
      }
      %2 = hls.dataflow.buffer {depth = 1 : i32} : memref<1x64x28x28xi8, 12>
      %3 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x28x28xi8, 12>
      hls.dataflow.task {
        affine.for %arg6 = 0 to 64 {
          affine.for %arg7 = 0 to 64 {
            affine.for %arg8 = 0 to 28 {
              affine.for %arg9 = 0 to 28 {
                %5 = affine.load %arg0[0, %arg6, %arg8 * 2, %arg9 * 2] : memref<1x64x56x56xi8, 12>
                %6 = affine.load %arg2[%arg7, %arg6, 0, 0] : memref<64x64x1x1xi8, 12>
                %7 = affine.load %3[0, %arg7, %arg8, %arg9] : memref<1x64x28x28xi8, 12>
                %8 = arith.muli %5, %6 : i8
                %9 = arith.addi %7, %8 : i8
                affine.store %9, %3[0, %arg7, %arg8, %arg9] : memref<1x64x28x28xi8, 12>
                %10 = affine.load %1[0, %arg7, %arg8, %arg9] : memref<1x64x28x28xi8, 12>
                %11 = affine.load %3[0, %arg7, %arg8, %arg9] : memref<1x64x28x28xi8, 12>
                %12 = arith.addi %10, %11 : i8
                %13 = arith.cmpi ugt, %12, %c-24_i8 : i8
                %14 = arith.select %13, %12, %c-24_i8 : i8
                affine.if #set1(%arg6) {
                  affine.store %14, %2[0, %arg7, %arg8, %arg9] : memref<1x64x28x28xi8, 12>
                }
              } {parallel}
            } {parallel}
          } {parallel}
        }
      }
      %4 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<1x64x1x1xi8, 7>
      hls.dataflow.task {
        affine.for %arg6 = 0 to 28 {
          affine.for %arg7 = 0 to 28 {
            affine.for %arg8 = 0 to 64 {
              %5 = affine.load %2[0, %arg8, %arg6, %arg7] : memref<1x64x28x28xi8, 12>
              %6 = affine.load %4[0, %arg8, 0, 0] : memref<1x64x1x1xi8, 7>
              %7 = arith.addi %6, %5 : i8
              affine.store %7, %4[0, %arg8, 0, 0] : memref<1x64x1x1xi8, 7>
              %8 = affine.load %4[0, %arg8, 0, 0] : memref<1x64x1x1xi8, 7>
              %9 = arith.divui %8, %c-24_i8 : i8
              affine.if #set2(%arg6, %arg7) {
                affine.store %9, %4[0, %arg8, 0, 0] : memref<1x64x1x1xi8, 7>
              }
            } {parallel}
          }
        }
      }
      hls.dataflow.task {
        affine.for %arg6 = 0 to 64 {
          affine.for %arg7 = 0 to 1000 {
            affine.if #set3(%arg6) {
              affine.store %c-24_i8, %arg5[0, %arg7] : memref<1x1000xi8, 12>
            }
            %5 = affine.load %4[0, %arg6, 0, 0] : memref<1x64x1x1xi8, 7>
            %6 = affine.load %arg1[%arg7, %arg6] : memref<1000x64xi8, 12>
            %7 = affine.load %arg5[0, %arg7] : memref<1x1000xi8, 12>
            %8 = arith.muli %5, %6 : i8
            %9 = arith.addi %7, %8 : i8
            affine.store %9, %arg5[0, %arg7] : memref<1x1000xi8, 12>
          } {parallel}
        }
      }
    }
    return
  }
}

