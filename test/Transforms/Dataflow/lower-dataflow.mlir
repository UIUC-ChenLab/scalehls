// RUN: scalehls-opt -scalehls-lower-dataflow %s | FileCheck %s

// CHECK: module attributes {torch.debug_module_name = "ResNet"} {
// CHECK: }

#set = affine_set<(d0, d1, d2, d3) : (-d2 - d3 * 16 + 63 == 0, -d0 + 2 == 0, -d1 + 2 == 0)>
#set1 = affine_set<(d0, d1) : (-d0 - d1 * 16 + 63 == 0)>
#set2 = affine_set<(d0, d1, d2, d3) : (-d0 - d2 * 14 + 27 == 0, -d1 - d3 * 14 + 27 == 0)>
#set3 = affine_set<(d0, d1) : (d0 + d1 * 16 == 0)>
module attributes {torch.debug_module_name = "ResNet"} {
  func.func @forward(%arg0: memref<64x56x56xi8, 12>, %arg1: memref<1000x64xi8, 12>, %arg2: memref<64x64xi8, 12>, %arg3: memref<64x64x3x3xi8, 12>, %arg4: memref<64x64x3x3xi8, 12>, %arg5: memref<1000xi8, 12>) attributes {top_func} {
    %c-24_i8 = arith.constant -24 : i8
    hls.dataflow.dispatch {
      hls.dataflow.task {
        affine.for %arg6 = 0 to 4 {
          affine.for %arg7 = 0 to 4 {
            affine.for %arg8 = 0 to 4 {
              hls.dataflow.dispatch {
                %5 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
                hls.dataflow.task {
                  affine.for %arg9 = 0 to 16 {
                    affine.for %arg10 = 0 to 14 {
                      affine.for %arg11 = 0 to 14 {
                        %6 = affine.load %arg0[%arg9 + %arg6 * 16, %arg10 + %arg7 * 14, %arg11 + %arg8 * 14] : memref<64x56x56xi8, 12>
                        affine.store %6, %5[%arg9, %arg10, %arg11] : memref<16x14x14xi8, 7>
                      } {parallel}
                    } {parallel}
                  } {parallel}
                }
                hls.dataflow.task {
                  affine.for %arg9 = 0 to 16 {
                    affine.for %arg10 = 0 to 14 {
                      affine.for %arg11 = 0 to 14 {
                        %6 = affine.load %5[%arg9, %arg10, %arg11] : memref<16x14x14xi8, 7>
                        %7 = arith.cmpi ugt, %6, %c-24_i8 : i8
                        %8 = arith.select %7, %6, %c-24_i8 : i8
                        affine.store %8, %5[%arg9, %arg10, %arg11] : memref<16x14x14xi8, 7>
                      } {parallel, point}
                    } {parallel, point}
                  } {parallel, point}
                }
                hls.dataflow.task {
                  affine.for %arg9 = 0 to 16 {
                    affine.for %arg10 = 0 to 14 {
                      affine.for %arg11 = 0 to 14 {
                        %6 = affine.load %5[%arg9, %arg10, %arg11] : memref<16x14x14xi8, 7>
                        affine.store %6, %arg0[%arg9 + %arg6 * 16, %arg10 + %arg7 * 14, %arg11 + %arg8 * 14] : memref<64x56x56xi8, 12>
                      } {parallel}
                    } {parallel}
                  } {parallel}
                }
              }
            } {parallel}
          } {parallel}
        } {parallel}
      }
      %0 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, 12>
      hls.dataflow.task {
        affine.for %arg6 = 0 to 4 {
          affine.for %arg7 = 0 to 3 {
            affine.for %arg8 = 0 to 3 {
              affine.for %arg9 = 0 to 4 {
                affine.for %arg10 = 0 to 2 {
                  affine.for %arg11 = 0 to 2 {
                    hls.dataflow.dispatch {
                      %5 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, 7>
                      %6 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, 7>
                      %7 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
                      hls.dataflow.task {
                        affine.for %arg12 = 0 to 16 {
                          affine.for %arg13 = 0 to 14 {
                            affine.for %arg14 = 0 to 14 {
                              %8 = affine.load %arg0[%arg12 + %arg6 * 16, %arg13 * 2 + %arg7 + %arg10 * 28 - 1, %arg14 * 2 + %arg8 + %arg11 * 28 - 1] : memref<64x56x56xi8, 12>
                              affine.store %8, %7[%arg12, %arg13, %arg14] : memref<16x14x14xi8, 7>
                            } {parallel}
                          } {parallel}
                        } {parallel}
                      }
                      hls.dataflow.task {
                        affine.for %arg12 = 0 to 16 {
                          affine.for %arg13 = 0 to 16 {
                            %8 = affine.load %arg4[%arg12 + %arg9 * 16, %arg13 + %arg6 * 16, %arg7, %arg8] : memref<64x64x3x3xi8, 12>
                            affine.store %8, %6[%arg12, %arg13] : memref<16x16xi8, 7>
                          } {parallel}
                        } {parallel}
                      }
                      hls.dataflow.task {
                        affine.for %arg12 = 0 to 16 {
                          affine.for %arg13 = 0 to 14 {
                            affine.for %arg14 = 0 to 14 {
                              %8 = affine.load %0[%arg12 + %arg9 * 16, %arg13 + %arg10 * 14, %arg14 + %arg11 * 14] : memref<64x28x28xi8, 12>
                              affine.store %8, %5[%arg12, %arg13, %arg14] : memref<16x14x14xi8, 7>
                            } {parallel}
                          } {parallel}
                        } {parallel}
                      }
                      hls.dataflow.task {
                        affine.for %arg12 = 0 to 16 {
                          affine.for %arg13 = 0 to 16 {
                            affine.for %arg14 = 0 to 14 {
                              affine.for %arg15 = 0 to 14 {
                                %8 = affine.load %7[%arg12, %arg14, %arg15] : memref<16x14x14xi8, 7>
                                %9 = affine.load %6[%arg13, %arg12] : memref<16x16xi8, 7>
                                %10 = affine.load %5[%arg13, %arg14, %arg15] : memref<16x14x14xi8, 7>
                                %11 = arith.muli %8, %9 : i8
                                %12 = arith.addi %10, %11 : i8
                                %13 = arith.cmpi ugt, %12, %c-24_i8 : i8
                                %14 = arith.select %13, %12, %c-24_i8 : i8
                                %15 = hls.affine.select #set(%arg7, %arg8, %arg12, %arg6) %14, %12 : i8
                                affine.store %15, %5[%arg13, %arg14, %arg15] : memref<16x14x14xi8, 7>
                              } {parallel, point}
                            } {parallel, point}
                          } {parallel, point}
                        } {point}
                      }
                      hls.dataflow.task {
                        affine.for %arg12 = 0 to 16 {
                          affine.for %arg13 = 0 to 14 {
                            affine.for %arg14 = 0 to 14 {
                              %8 = affine.load %5[%arg12, %arg13, %arg14] : memref<16x14x14xi8, 7>
                              affine.store %8, %0[%arg12 + %arg9 * 16, %arg13 + %arg10 * 14, %arg14 + %arg11 * 14] : memref<64x28x28xi8, 12>
                            } {parallel}
                          } {parallel}
                        } {parallel}
                      }
                    }
                  } {parallel}
                } {parallel}
              } {parallel}
            }
          }
        }
      }
      %1 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, 12>
      hls.dataflow.task {
        affine.for %arg6 = 0 to 4 {
          affine.for %arg7 = 0 to 3 {
            affine.for %arg8 = 0 to 3 {
              affine.for %arg9 = 0 to 4 {
                affine.for %arg10 = 0 to 2 {
                  affine.for %arg11 = 0 to 2 {
                    hls.dataflow.dispatch {
                      %5 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, 7>
                      %6 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, 7>
                      %7 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, 7>
                      hls.dataflow.task {
                        affine.for %arg12 = 0 to 16 {
                          affine.for %arg13 = 0 to 14 {
                            affine.for %arg14 = 0 to 14 {
                              %8 = affine.load %0[%arg12 + %arg6 * 16, %arg13 + %arg7 + %arg10 * 14 - 1, %arg14 + %arg8 + %arg11 * 14 - 1] : memref<64x28x28xi8, 12>
                              affine.store %8, %7[%arg12, %arg13, %arg14] : memref<16x14x14xi8, 7>
                            } {parallel}
                          } {parallel}
                        } {parallel}
                      }
                      hls.dataflow.task {
                        affine.for %arg12 = 0 to 16 {
                          affine.for %arg13 = 0 to 16 {
                            %8 = affine.load %arg3[%arg12 + %arg9 * 16, %arg13 + %arg6 * 16, %arg7, %arg8] : memref<64x64x3x3xi8, 12>
                            affine.store %8, %6[%arg12, %arg13] : memref<16x16xi8, 7>
                          } {parallel}
                        } {parallel}
                      }
                      hls.dataflow.task {
                        affine.for %arg12 = 0 to 16 {
                          affine.for %arg13 = 0 to 14 {
                            affine.for %arg14 = 0 to 14 {
                              %8 = affine.load %1[%arg12 + %arg9 * 16, %arg13 + %arg10 * 14, %arg14 + %arg11 * 14] : memref<64x28x28xi8, 12>
                              affine.store %8, %5[%arg12, %arg13, %arg14] : memref<16x14x14xi8, 7>
                            } {parallel}
                          } {parallel}
                        } {parallel}
                      }
                      hls.dataflow.task {
                        affine.for %arg12 = 0 to 16 {
                          affine.for %arg13 = 0 to 16 {
                            affine.for %arg14 = 0 to 14 {
                              affine.for %arg15 = 0 to 14 {
                                %8 = affine.load %7[%arg12, %arg14, %arg15] : memref<16x14x14xi8, 7>
                                %9 = affine.load %6[%arg13, %arg12] : memref<16x16xi8, 7>
                                %10 = affine.load %5[%arg13, %arg14, %arg15] : memref<16x14x14xi8, 7>
                                %11 = arith.muli %8, %9 : i8
                                %12 = arith.addi %10, %11 : i8
                                affine.store %12, %5[%arg13, %arg14, %arg15] : memref<16x14x14xi8, 7>
                              } {parallel, point}
                            } {parallel, point}
                          } {parallel, point}
                        } {point}
                      }
                      hls.dataflow.task {
                        affine.for %arg12 = 0 to 16 {
                          affine.for %arg13 = 0 to 14 {
                            affine.for %arg14 = 0 to 14 {
                              %8 = affine.load %5[%arg12, %arg13, %arg14] : memref<16x14x14xi8, 7>
                              affine.store %8, %1[%arg12 + %arg9 * 16, %arg13 + %arg10 * 14, %arg14 + %arg11 * 14] : memref<64x28x28xi8, 12>
                            } {parallel}
                          } {parallel}
                        } {parallel}
                      }
                    }
                  } {parallel}
                } {parallel}
              } {parallel}
            }
          }
        }
      }
      %2 = hls.dataflow.buffer {depth = 1 : i32} : memref<64x28x28xi8, 12>
      %3 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64x28x28xi8, 12>
      hls.dataflow.task {
        affine.for %arg6 = 0 to 4 {
          affine.for %arg7 = 0 to 4 {
            affine.for %arg8 = 0 to 2 {
              affine.for %arg9 = 0 to 2 {
                hls.dataflow.dispatch {
                  %5 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
                  %6 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, 7>
                  %7 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<16x14x14xi8, 7>
                  %8 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x16xi8, 7>
                  %9 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
                  hls.dataflow.task {
                    affine.for %arg10 = 0 to 16 {
                      affine.for %arg11 = 0 to 14 {
                        affine.for %arg12 = 0 to 14 {
                          %10 = affine.load %arg0[%arg10 + %arg6 * 16, %arg11 * 2 + %arg8 * 28, %arg12 * 2 + %arg9 * 28] : memref<64x56x56xi8, 12>
                          affine.store %10, %9[%arg10, %arg11, %arg12] : memref<16x14x14xi8, 7>
                        } {parallel}
                      } {parallel}
                    } {parallel}
                  }
                  hls.dataflow.task {
                    affine.for %arg10 = 0 to 16 {
                      affine.for %arg11 = 0 to 16 {
                        %10 = affine.load %arg2[%arg10 + %arg7 * 16, %arg11 + %arg6 * 16] : memref<64x64xi8, 12>
                        affine.store %10, %8[%arg10, %arg11] : memref<16x16xi8, 7>
                      } {parallel}
                    } {parallel}
                  }
                  hls.dataflow.task {
                    affine.for %arg10 = 0 to 16 {
                      affine.for %arg11 = 0 to 14 {
                        affine.for %arg12 = 0 to 14 {
                          %10 = affine.load %3[%arg10 + %arg7 * 16, %arg11 + %arg8 * 14, %arg12 + %arg9 * 14] : memref<64x28x28xi8, 12>
                          affine.store %10, %7[%arg10, %arg11, %arg12] : memref<16x14x14xi8, 7>
                        } {parallel}
                      } {parallel}
                    } {parallel}
                  }
                  hls.dataflow.task {
                    affine.for %arg10 = 0 to 16 {
                      affine.for %arg11 = 0 to 14 {
                        affine.for %arg12 = 0 to 14 {
                          %10 = affine.load %1[%arg10 + %arg7 * 16, %arg11 + %arg8 * 14, %arg12 + %arg9 * 14] : memref<64x28x28xi8, 12>
                          affine.store %10, %6[%arg10, %arg11, %arg12] : memref<16x14x14xi8, 7>
                        } {parallel}
                      } {parallel}
                    } {parallel}
                  }
                  hls.dataflow.task {
                    affine.for %arg10 = 0 to 16 {
                      affine.for %arg11 = 0 to 16 {
                        affine.for %arg12 = 0 to 14 {
                          affine.for %arg13 = 0 to 14 {
                            %10 = affine.load %9[%arg10, %arg12, %arg13] : memref<16x14x14xi8, 7>
                            %11 = affine.load %8[%arg11, %arg10] : memref<16x16xi8, 7>
                            %12 = affine.load %7[%arg11, %arg12, %arg13] : memref<16x14x14xi8, 7>
                            %13 = arith.muli %10, %11 : i8
                            %14 = arith.addi %12, %13 : i8
                            affine.store %14, %7[%arg11, %arg12, %arg13] : memref<16x14x14xi8, 7>
                            %15 = affine.load %6[%arg11, %arg12, %arg13] : memref<16x14x14xi8, 7>
                            %16 = arith.addi %15, %14 : i8
                            %17 = arith.cmpi ugt, %16, %c-24_i8 : i8
                            %18 = arith.select %17, %16, %c-24_i8 : i8
                            affine.if #set1(%arg10, %arg6) {
                              affine.store %18, %5[%arg11, %arg12, %arg13] : memref<16x14x14xi8, 7>
                            }
                          } {parallel, point}
                        } {parallel, point}
                      } {parallel, point}
                    } {point}
                  }
                  hls.dataflow.task {
                    affine.for %arg10 = 0 to 16 {
                      affine.for %arg11 = 0 to 14 {
                        affine.for %arg12 = 0 to 14 {
                          %10 = affine.load %7[%arg10, %arg11, %arg12] : memref<16x14x14xi8, 7>
                          affine.store %10, %3[%arg10 + %arg7 * 16, %arg11 + %arg8 * 14, %arg12 + %arg9 * 14] : memref<64x28x28xi8, 12>
                        } {parallel}
                      } {parallel}
                    } {parallel}
                  }
                  hls.dataflow.task {
                    affine.for %arg10 = 0 to 16 {
                      affine.for %arg11 = 0 to 14 {
                        affine.for %arg12 = 0 to 14 {
                          %10 = affine.load %5[%arg10, %arg11, %arg12] : memref<16x14x14xi8, 7>
                          affine.store %10, %2[%arg10 + %arg7 * 16, %arg11 + %arg8 * 14, %arg12 + %arg9 * 14] : memref<64x28x28xi8, 12>
                        } {parallel}
                      } {parallel}
                    } {parallel}
                  }
                }
              } {parallel}
            } {parallel}
          } {parallel}
        }
      }
      %4 = hls.dataflow.buffer {depth = 1 : i32, init_value = -24 : i8} : memref<64xi8, 7>
      hls.dataflow.task {
        affine.for %arg6 = 0 to 2 {
          affine.for %arg7 = 0 to 2 {
            affine.for %arg8 = 0 to 4 {
              hls.dataflow.dispatch {
                %5 = hls.dataflow.buffer {depth = 1 : i32} : memref<16x14x14xi8, 7>
                hls.dataflow.task {
                  affine.for %arg9 = 0 to 16 {
                    affine.for %arg10 = 0 to 14 {
                      affine.for %arg11 = 0 to 14 {
                        %6 = affine.load %2[%arg9 + %arg8 * 16, %arg10 + %arg6 * 14, %arg11 + %arg7 * 14] : memref<64x28x28xi8, 12>
                        affine.store %6, %5[%arg9, %arg10, %arg11] : memref<16x14x14xi8, 7>
                      } {parallel}
                    } {parallel}
                  } {parallel}
                }
                hls.dataflow.task {
                  affine.for %arg9 = 0 to 14 {
                    affine.for %arg10 = 0 to 14 {
                      affine.for %arg11 = 0 to 16 {
                        %6 = affine.load %5[%arg11, %arg9, %arg10] : memref<16x14x14xi8, 7>
                        %7 = affine.load %4[%arg11 + %arg8 * 16] : memref<64xi8, 7>
                        %8 = arith.addi %7, %6 : i8
                        %9 = arith.divui %8, %c-24_i8 : i8
                        %10 = hls.affine.select #set2(%arg9, %arg10, %arg6, %arg7) %9, %8 : i8
                        affine.store %10, %4[%arg11 + %arg8 * 16] : memref<64xi8, 7>
                      } {parallel, point}
                    } {point}
                  } {point}
                }
              }
            } {parallel}
          }
        }
      }
      hls.dataflow.task {
        affine.for %arg6 = 0 to 4 {
          affine.for %arg7 = 0 to 100 {
            hls.dataflow.dispatch {
              %5 = hls.dataflow.buffer {depth = 1 : i32} : memref<10x16xi8, 7>
              %6 = hls.dataflow.buffer {depth = 1 : i32} : memref<10xi8, 7>
              hls.dataflow.task {
                affine.for %arg8 = 0 to 10 {
                  %7 = affine.load %arg5[%arg8 + %arg7 * 10] : memref<1000xi8, 12>
                  affine.store %7, %6[%arg8] : memref<10xi8, 7>
                } {parallel}
              }
              hls.dataflow.task {
                affine.for %arg8 = 0 to 10 {
                  affine.for %arg9 = 0 to 16 {
                    %7 = affine.load %arg1[%arg8 + %arg7 * 10, %arg9 + %arg6 * 16] : memref<1000x64xi8, 12>
                    affine.store %7, %5[%arg8, %arg9] : memref<10x16xi8, 7>
                  } {parallel}
                } {parallel}
              }
              hls.dataflow.task {
                affine.for %arg8 = 0 to 16 {
                  affine.for %arg9 = 0 to 10 {
                    %7 = affine.load %6[%arg9] : memref<10xi8, 7>
                    %8 = hls.affine.select #set3(%arg8, %arg6) %c-24_i8, %7 : i8
                    %9 = affine.load %4[%arg8 + %arg6 * 16] : memref<64xi8, 7>
                    %10 = affine.load %5[%arg9, %arg8] : memref<10x16xi8, 7>
                    %11 = arith.muli %9, %10 : i8
                    %12 = arith.addi %8, %11 : i8
                    affine.store %12, %6[%arg9] : memref<10xi8, 7>
                  } {parallel, point}
                } {point}
              }
              hls.dataflow.task {
                affine.for %arg8 = 0 to 10 {
                  %7 = affine.load %6[%arg8] : memref<10xi8, 7>
                  affine.store %7, %arg5[%arg8 + %arg7 * 10] : memref<1000xi8, 12>
                } {parallel}
              }
            }
          } {parallel}
        }
      }
    }
    return
  }
}

