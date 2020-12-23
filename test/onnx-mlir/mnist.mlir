// RUN: scalehls-opt -legalize-onnx %s | FileCheck %s

// CHECK: module {

#map0 = affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>
#map1 = affine_map<() -> (0)>
#map2 = affine_map<() -> (32)>
#map3 = affine_map<() -> (1)>
#map4 = affine_map<(d0) -> (d0 + 2)>
#map5 = affine_map<() -> (28)>
#map6 = affine_map<(d0, d1) -> (d0 + d1)>
#map7 = affine_map<() -> (5)>
#map8 = affine_map<() -> (8)>
#map9 = affine_map<(d0, d1, d2) -> (d0, d1, d2)>
#map10 = affine_map<(d0)[s0, s1, s2, s3, s4] -> (0, d0 * s3 - s2)>
#map11 = affine_map<(d0) -> (28, d0 * -2 + 28, d0 * 2 + 2, 2)>
#map12 = affine_map<() -> (14)>
#map13 = affine_map<() -> (18)>
#map14 = affine_map<() -> (16)>
#map15 = affine_map<(d0) -> (14, d0 * -3 + 14, d0 * 3 + 3, 3)>
#map16 = affine_map<() -> (4)>
#map17 = affine_map<(d0, d1) -> (d0, d1)>
#map18 = affine_map<() -> (256)>
#map19 = affine_map<() -> (10)>
module {
  %0 = "krnl.packed_const"() {file_name = "/tmp/packed_const-b8d8d9.tmp", is_le = true, size_in_bytes = 23840 : i64} : () -> i64
  func @main_graph(%arg0: memref<1x1x28x28xf32>) -> memref<1x10xf32> attributes {input_names = ["Input3"], output_names = ["Plus214_Output_0"]} {
    %c10240_i64 = constant 10240 : i64
    %c28 = constant 28 : index
    %c2 = constant 2 : index
    %cst = constant 0xFF800000 : f32
    %c14 = constant 14 : index
    %c3 = constant 3 : index
    %c1 = constant 1 : index
    %c1024_i64 = constant 1024 : i64
    %cst_0 = constant 1.000000e+00 : f32
    %cst_1 = constant 0.000000e+00 : f32
    %c0 = constant 0 : index
    %1 = alloc() : memref<1x10xf32>
    %2 = alloc() : memref<1x256xf32>
    %3 = alloc() : memref<1x16x4x4xf32>
    %4 = alloc() : memref<1x16x14x14xf32>
    %5 = alloc() : memref<1x16x14x14xf32>
    %6 = alloc() : memref<1x16x14x14xf32>
    %7 = alloc() : memref<1x8x18x18xf32>
    %8 = alloc() : memref<1x8x14x14xf32>
    %9 = alloc() : memref<1x8x28x28xf32>
    %10 = alloc() : memref<1x8x28x28xf32>
    %11 = alloc() : memref<1x8x28x28xf32>
    %12 = alloc() : memref<1x1x32x32xf32>
    %13 = alloc() : memref<256x10xf32>
    %14 = "krnl.global"() {name = "constant_0", offset = 0 : i64, shape = [16, 4, 4, 10]} : () -> memref<16x4x4x10xf32>
    "krnl.memcpy"(%13, %14, %c10240_i64) : (memref<256x10xf32>, memref<16x4x4x10xf32>, i64) -> ()
    %15 = "krnl.global"() {name = "constant_1", offset = 10240 : i64, shape = [8, 1, 5, 5]} : () -> memref<8x1x5x5xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 1 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            affine.store %cst_1, %12[%arg1, %arg2, %arg3, %arg4] : memref<1x1x32x32xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 1 {
        affine.for %arg3 = 0 to 28 {
          affine.for %arg4 = 0 to 28 {
            %20 = affine.apply #map4(%arg3)
            %21 = affine.apply #map4(%arg4)
            %22 = affine.load %arg0[%arg1, %arg2, %arg3, %arg4] : memref<1x1x28x28xf32>
            affine.store %22, %12[%arg1, %arg2, %20, %21] : memref<1x1x32x32xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 8 {
        affine.for %arg3 = 0 to 28 {
          affine.for %arg4 = 0 to 28 {
            affine.store %cst_1, %11[%arg1, %arg2, %arg3, %arg4] : memref<1x8x28x28xf32>
            affine.for %arg5 = 0 to 1 {
              affine.for %arg6 = 0 to 5 {
                affine.for %arg7 = 0 to 5 {
                  %20 = affine.apply #map6(%arg3, %arg6)
                  %21 = affine.apply #map6(%arg4, %arg7)
                  %22 = affine.load %12[%arg1, %arg5, %20, %21] : memref<1x1x32x32xf32>
                  %23 = affine.load %15[%arg2, %arg5, %arg6, %arg7] : memref<8x1x5x5xf32>
                  %24 = affine.load %11[%arg1, %arg2, %arg3, %arg4] : memref<1x8x28x28xf32>
                  %25 = mulf %22, %23 : f32
                  %26 = addf %24, %25 : f32
                  affine.store %26, %11[%arg1, %arg2, %arg3, %arg4] : memref<1x8x28x28xf32>
                }
              }
            }
          }
        }
      }
    }
    %16 = "krnl.global"() {name = "constant_2", offset = 11040 : i64, shape = [8, 1, 1], value = dense<[[[-0.161539719]], [[-0.433835655]], [[0.091641359]], [[-0.0168522168]], [[-0.0650264397]], [[-0.131737873]], [[0.0204175506]], [[-0.121110231]]]> : tensor<8x1x1xf32>} : () -> memref<8x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 8 {
        affine.for %arg3 = 0 to 28 {
          affine.for %arg4 = 0 to 28 {
            %20 = affine.load %11[%arg1, %arg2, %arg3, %arg4] : memref<1x8x28x28xf32>
            %21 = affine.load %16[%arg2, %c0, %c0] : memref<8x1x1xf32>
            %22 = addf %20, %21 : f32
            affine.store %22, %10[%arg1, %arg2, %arg3, %arg4] : memref<1x8x28x28xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 8 {
        affine.for %arg3 = 0 to 28 {
          affine.for %arg4 = 0 to 28 {
            %20 = affine.load %10[%arg1, %arg2, %arg3, %arg4] : memref<1x8x28x28xf32>
            %21 = cmpf "olt", %20, %cst_1 : f32
            %22 = select %21, %cst_1, %20 : f32
            affine.store %22, %9[%arg1, %arg2, %arg3, %arg4] : memref<1x8x28x28xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 8 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            affine.store %cst, %8[%arg1, %arg2, %arg3, %arg4] : memref<1x8x14x14xf32>
            %20 = affine.max #map10(%arg3)[%c28, %c2, %c0, %c2, %c1]
            %21 = affine.max #map10(%arg4)[%c28, %c2, %c0, %c2, %c1]
            affine.for %arg5 = 0 to min #map11(%arg3) {
              affine.for %arg6 = 0 to min #map11(%arg4) {
                %22 = addi %arg5, %20 : index
                %23 = addi %arg6, %21 : index
                %24 = load %9[%arg1, %arg2, %22, %23] : memref<1x8x28x28xf32>
                %25 = affine.load %8[%arg1, %arg2, %arg3, %arg4] : memref<1x8x14x14xf32>
                %26 = cmpf "ogt", %25, %24 : f32
                %27 = select %26, %25, %24 : f32
                affine.store %27, %8[%arg1, %arg2, %arg3, %arg4] : memref<1x8x14x14xf32>
              }
            }
          }
        }
      }
    }
    %17 = "krnl.global"() {name = "constant_3", offset = 11040 : i64, shape = [16, 8, 5, 5]} : () -> memref<16x8x5x5xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 8 {
        affine.for %arg3 = 0 to 18 {
          affine.for %arg4 = 0 to 18 {
            affine.store %cst_1, %7[%arg1, %arg2, %arg3, %arg4] : memref<1x8x18x18xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 8 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            %20 = affine.apply #map4(%arg3)
            %21 = affine.apply #map4(%arg4)
            %22 = affine.load %8[%arg1, %arg2, %arg3, %arg4] : memref<1x8x14x14xf32>
            affine.store %22, %7[%arg1, %arg2, %20, %21] : memref<1x8x18x18xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 16 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            affine.store %cst_1, %6[%arg1, %arg2, %arg3, %arg4] : memref<1x16x14x14xf32>
            affine.for %arg5 = 0 to 8 {
              affine.for %arg6 = 0 to 5 {
                affine.for %arg7 = 0 to 5 {
                  %20 = affine.apply #map6(%arg3, %arg6)
                  %21 = affine.apply #map6(%arg4, %arg7)
                  %22 = affine.load %7[%arg1, %arg5, %20, %21] : memref<1x8x18x18xf32>
                  %23 = affine.load %17[%arg2, %arg5, %arg6, %arg7] : memref<16x8x5x5xf32>
                  %24 = affine.load %6[%arg1, %arg2, %arg3, %arg4] : memref<1x16x14x14xf32>
                  %25 = mulf %22, %23 : f32
                  %26 = addf %24, %25 : f32
                  affine.store %26, %6[%arg1, %arg2, %arg3, %arg4] : memref<1x16x14x14xf32>
                }
              }
            }
          }
        }
      }
    }
    %18 = "krnl.global"() {name = "constant_4", offset = 23840 : i64, shape = [16, 1, 1], value = dense<[[[-0.0822488219]], [[-0.108868778]], [[-0.141039595]], [[-0.204869166]], [[-0.17913565]], [[-0.215438381]], [[-0.133805066]], [[-0.195724562]], [[-0.268250644]], [[-0.258212209]], [[-0.0761560649]], [[0.0132841459]], [[-0.00444464432]], [[-0.414740831]], [[-0.17879115]], [[-0.0386558883]]]> : tensor<16x1x1xf32>} : () -> memref<16x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 16 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            %20 = affine.load %6[%arg1, %arg2, %arg3, %arg4] : memref<1x16x14x14xf32>
            %21 = affine.load %18[%arg2, %c0, %c0] : memref<16x1x1xf32>
            %22 = addf %20, %21 : f32
            affine.store %22, %5[%arg1, %arg2, %arg3, %arg4] : memref<1x16x14x14xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 16 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            %20 = affine.load %5[%arg1, %arg2, %arg3, %arg4] : memref<1x16x14x14xf32>
            %21 = cmpf "olt", %20, %cst_1 : f32
            %22 = select %21, %cst_1, %20 : f32
            affine.store %22, %4[%arg1, %arg2, %arg3, %arg4] : memref<1x16x14x14xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 16 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst, %3[%arg1, %arg2, %arg3, %arg4] : memref<1x16x4x4xf32>
            %20 = affine.max #map10(%arg3)[%c14, %c3, %c0, %c3, %c1]
            %21 = affine.max #map10(%arg4)[%c14, %c3, %c0, %c3, %c1]
            affine.for %arg5 = 0 to min #map15(%arg3) {
              affine.for %arg6 = 0 to min #map15(%arg4) {
                %22 = addi %arg5, %20 : index
                %23 = addi %arg6, %21 : index
                %24 = load %4[%arg1, %arg2, %22, %23] : memref<1x16x14x14xf32>
                %25 = affine.load %3[%arg1, %arg2, %arg3, %arg4] : memref<1x16x4x4xf32>
                %26 = cmpf "ogt", %25, %24 : f32
                %27 = select %26, %25, %24 : f32
                affine.store %27, %3[%arg1, %arg2, %arg3, %arg4] : memref<1x16x4x4xf32>
              }
            }
          }
        }
      }
    }
    "krnl.memcpy"(%2, %3, %c1024_i64) : (memref<1x256xf32>, memref<1x16x4x4xf32>, i64) -> ()
    %19 = "krnl.global"() {name = "constant_5", offset = 23840 : i64, shape = [1, 10], value = dense<[[-0.0448560268, 0.00779166119, 0.0681008175, 0.0299937408, -0.126409635, 0.14021875, -0.0552849025, -0.0493838154, 0.0843220502, -0.0545404144]]> : tensor<1x10xf32>} : () -> memref<1x10xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 10 {
        affine.store %cst_1, %1[%arg1, %arg2] : memref<1x10xf32>
        affine.for %arg3 = 0 to 256 {
          %25 = affine.load %2[%arg1, %arg3] : memref<1x256xf32>
          %26 = affine.load %13[%arg3, %arg2] : memref<256x10xf32>
          %27 = affine.load %1[%arg1, %arg2] : memref<1x10xf32>
          %28 = mulf %25, %26 : f32
          %29 = addf %27, %28 : f32
          affine.store %29, %1[%arg1, %arg2] : memref<1x10xf32>
        }
        %20 = affine.load %1[%arg1, %arg2] : memref<1x10xf32>
        %21 = mulf %cst_0, %20 : f32
        %22 = affine.load %19[%c0, %arg2] : memref<1x10xf32>
        %23 = mulf %cst_0, %22 : f32
        %24 = addf %21, %23 : f32
        affine.store %24, %1[%arg1, %arg2] : memref<1x10xf32>
      }
    }
    dealloc %13 : memref<256x10xf32>
    dealloc %12 : memref<1x1x32x32xf32>
    dealloc %11 : memref<1x8x28x28xf32>
    dealloc %10 : memref<1x8x28x28xf32>
    dealloc %9 : memref<1x8x28x28xf32>
    dealloc %8 : memref<1x8x14x14xf32>
    dealloc %7 : memref<1x8x18x18xf32>
    dealloc %6 : memref<1x16x14x14xf32>
    dealloc %5 : memref<1x16x14x14xf32>
    dealloc %4 : memref<1x16x14x14xf32>
    dealloc %3 : memref<1x16x4x4xf32>
    dealloc %2 : memref<1x256xf32>
    return %1 : memref<1x10xf32>
  }
  "krnl.entry_point"() {func = @main_graph, numInputs = 1 : i32, numOutputs = 1 : i32} : () -> ()
}
