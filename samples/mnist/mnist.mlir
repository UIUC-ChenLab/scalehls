#map0 = affine_map<()[s0, s1, s2, s3] -> (s0, s1, s2, s3)>
#map1 = affine_map<() -> (0)>
#map2 = affine_map<() -> (32)>
#map3 = affine_map<() -> (1)>
#map4 = affine_map<()[s0, s1, s2, s3] -> (s0, s1, s2 + 2, s3 + 2)>
#map5 = affine_map<() -> (28)>
#map6 = affine_map<()[s0, s1, s2, s3, s4, s5] -> (s0, s1, s2 + s3, s4 + s5)>
#map7 = affine_map<() -> (5)>
#map8 = affine_map<() -> (8)>
#map9 = affine_map<()[s0, s1, s2] -> (0, s0, s1, s2)>
#map10 = affine_map<()[s0] -> (s0, 0, 0)>
#map11 = affine_map<()[s0] -> (0, s0 * 2)>
#map12 = affine_map<(d0) -> (28, d0 * -2 + 28, d0 * 2 + 2, 2)>
#map13 = affine_map<() -> (14)>
#map14 = affine_map<() -> (18)>
#map15 = affine_map<() -> (16)>
#map16 = affine_map<()[s0] -> (0, s0 * 3)>
#map17 = affine_map<(d0) -> (14, d0 * -3 + 14, d0 * 3 + 3, 3)>
#map18 = affine_map<() -> (4)>
#map19 = affine_map<()[s0, s1] -> (s0, s1)>
#map20 = affine_map<() -> (256)>
#map21 = affine_map<()[s0] -> (0, s0)>
#map22 = affine_map<() -> (10)>


module {
  func @main_graph(%arg0: memref<1x1x28x28xf32>, %14: memref<256x10xf32>, %16: memref<8x1x5x5xf32>, %17: memref<8x1x1xf32>, %18: memref<16x8x5x5xf32>, %19: memref<16x1x1xf32>, %20: memref<1x10xf32>) -> memref<1x10xf32> {
    %cst = constant 0xFF800000 : f32
    %c1024_i64 = constant 1024 : i64
    %cst_0 = constant 1.000000e+00 : f32
    %cst_1 = constant 0.000000e+00 : f32
    %1 = alloc() : memref<1x10xf32>
    %3 = alloc() : memref<1x256xf32>
    %4 = alloc() : memref<1x16x4x4xf32>
    %5 = alloc() : memref<1x16x14x14xf32>
    %6 = alloc() : memref<1x16x14x14xf32>
    %7 = alloc() : memref<1x16x14x14xf32>
    %8 = alloc() : memref<1x8x18x18xf32>
    %9 = alloc() : memref<1x8x14x14xf32>
    %10 = alloc() : memref<1x8x28x28xf32>
    %11 = alloc() : memref<1x8x28x28xf32>
    %12 = alloc() : memref<1x8x28x28xf32>
    %13 = alloc() : memref<1x1x32x32xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 1 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            affine.store %cst_1, %13[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x1x32x32xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 1 {
        affine.for %arg3 = 0 to 28 {
          affine.for %arg4 = 0 to 28 {
            %21 = affine.load %arg0[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x1x28x28xf32>
            affine.store %21, %13[symbol(%arg1), symbol(%arg2), symbol(%arg3) + 2, symbol(%arg4) + 2] : memref<1x1x32x32xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 8 {
        affine.for %arg3 = 0 to 28 {
          affine.for %arg4 = 0 to 28 {
            affine.store %cst_1, %12[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x8x28x28xf32>
            affine.for %arg5 = 0 to 1 {
              affine.for %arg6 = 0 to 5 {
                affine.for %arg7 = 0 to 5 {
                  %21 = affine.load %13[symbol(%arg1), symbol(%arg5), symbol(%arg3) + symbol(%arg6), symbol(%arg4) + symbol(%arg7)] : memref<1x1x32x32xf32>
                  %22 = affine.load %16[symbol(%arg2), symbol(%arg5), symbol(%arg6), symbol(%arg7)] : memref<8x1x5x5xf32>
                  %23 = affine.load %12[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x8x28x28xf32>
                  %24 = mulf %21, %22 : f32
                  %25 = addf %23, %24 : f32
                  affine.store %25, %12[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x8x28x28xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 8 {
        affine.for %arg3 = 0 to 28 {
          affine.for %arg4 = 0 to 28 {
            %21 = affine.load %12[0, symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x8x28x28xf32>
            %22 = affine.load %17[symbol(%arg2), 0, 0] : memref<8x1x1xf32>
            %23 = addf %21, %22 : f32
            affine.store %23, %11[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x8x28x28xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 8 {
        affine.for %arg3 = 0 to 28 {
          affine.for %arg4 = 0 to 28 {
            %21 = affine.load %11[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x8x28x28xf32>
            %22 = cmpf "olt", %21, %cst_1 : f32
            %23 = select %22, %cst_1, %21 : f32
            affine.store %23, %10[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x8x28x28xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 8 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            affine.store %cst, %9[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x8x14x14xf32>
            %21 = affine.max #map11()[%arg3]
            %22 = affine.max #map11()[%arg4]
            affine.for %arg5 = 0 to min #map12(%arg3) {
              affine.for %arg6 = 0 to min #map12(%arg4) {
                %23 = addi %arg5, %21 : index
                %24 = addi %arg6, %22 : index
                %25 = load %10[%arg1, %arg2, %23, %24] : memref<1x8x28x28xf32>
                %26 = affine.load %9[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x8x14x14xf32>
                %27 = cmpf "ogt", %26, %25 : f32
                %28 = select %27, %26, %25 : f32
                affine.store %28, %9[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x8x14x14xf32>
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 8 {
        affine.for %arg3 = 0 to 18 {
          affine.for %arg4 = 0 to 18 {
            affine.store %cst_1, %8[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x8x18x18xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 8 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            %21 = affine.load %9[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x8x14x14xf32>
            affine.store %21, %8[symbol(%arg1), symbol(%arg2), symbol(%arg3) + 2, symbol(%arg4) + 2] : memref<1x8x18x18xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 16 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            affine.store %cst_1, %7[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x16x14x14xf32>
            affine.for %arg5 = 0 to 8 {
              affine.for %arg6 = 0 to 5 {
                affine.for %arg7 = 0 to 5 {
                  %21 = affine.load %8[symbol(%arg1), symbol(%arg5), symbol(%arg3) + symbol(%arg6), symbol(%arg4) + symbol(%arg7)] : memref<1x8x18x18xf32>
                  %22 = affine.load %18[symbol(%arg2), symbol(%arg5), symbol(%arg6), symbol(%arg7)] : memref<16x8x5x5xf32>
                  %23 = affine.load %7[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x16x14x14xf32>
                  %24 = mulf %21, %22 : f32
                  %25 = addf %23, %24 : f32
                  affine.store %25, %7[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x16x14x14xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 16 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            %21 = affine.load %7[0, symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x16x14x14xf32>
            %22 = affine.load %19[symbol(%arg2), 0, 0] : memref<16x1x1xf32>
            %23 = addf %21, %22 : f32
            affine.store %23, %6[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x16x14x14xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 16 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            %21 = affine.load %6[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x16x14x14xf32>
            %22 = cmpf "olt", %21, %cst_1 : f32
            %23 = select %22, %cst_1, %21 : f32
            affine.store %23, %5[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x16x14x14xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 16 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst, %4[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x16x4x4xf32>
            %21 = affine.max #map16()[%arg3]
            %22 = affine.max #map16()[%arg4]
            affine.for %arg5 = 0 to min #map17(%arg3) {
              affine.for %arg6 = 0 to min #map17(%arg4) {
                %23 = addi %arg5, %21 : index
                %24 = addi %arg6, %22 : index
                %25 = load %5[%arg1, %arg2, %23, %24] : memref<1x16x14x14xf32>
                %26 = affine.load %4[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x16x4x4xf32>
                %27 = cmpf "ogt", %26, %25 : f32
                %28 = select %27, %26, %25 : f32
                affine.store %28, %4[symbol(%arg1), symbol(%arg2), symbol(%arg3), symbol(%arg4)] : memref<1x16x4x4xf32>
              }
            }
          }
        }
      }
    }
    //"krnl.memcpy"(%3, %4, %c1024_i64) : (memref<1x256xf32>, memref<1x16x4x4xf32>, i64) -> ()
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 10 {
        affine.store %cst_1, %1[symbol(%arg1), symbol(%arg2)] : memref<1x10xf32>
        affine.for %arg3 = 0 to 256 {
          %26 = affine.load %3[symbol(%arg1), symbol(%arg3)] : memref<1x256xf32>
          %27 = affine.load %14[symbol(%arg3), symbol(%arg2)] : memref<256x10xf32>
          %28 = affine.load %1[symbol(%arg1), symbol(%arg2)] : memref<1x10xf32>
          %29 = mulf %26, %27 : f32
          %30 = addf %28, %29 : f32
          affine.store %30, %1[symbol(%arg1), symbol(%arg2)] : memref<1x10xf32>
        }
        %21 = affine.load %1[symbol(%arg1), symbol(%arg2)] : memref<1x10xf32>
        %22 = mulf %cst_0, %21 : f32
        %23 = affine.load %20[0, symbol(%arg2)] : memref<1x10xf32>
        %24 = mulf %cst_0, %23 : f32
        %25 = addf %22, %24 : f32
        affine.store %25, %1[symbol(%arg1), symbol(%arg2)] : memref<1x10xf32>
      }
    }
    return %1 : memref<1x10xf32>
  }
}