// RUN: scalehls-opt -legalize-onnx %s | FileCheck %s

// CHECK: module {

#map0 = affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>
#map1 = affine_map<() -> (0)>
#map2 = affine_map<() -> (230)>
#map3 = affine_map<() -> (3)>
#map4 = affine_map<() -> (1)>
#map5 = affine_map<(d0) -> (d0 + 3)>
#map6 = affine_map<() -> (224)>
#map7 = affine_map<(d0, d1) -> (d0 * 2 + d1)>
#map8 = affine_map<() -> (7)>
#map9 = affine_map<(d0) -> (d0)>
#map10 = affine_map<() -> (112)>
#map11 = affine_map<() -> (64)>
#map12 = affine_map<(d0)[s0, s1, s2, s3, s4] -> (0, d0 * s3 - s2)>
#map13 = affine_map<(d0) -> (112, -(d0 * 2 - 1) + 112, d0 * 2 + 2, d0 * 2 - (d0 * 2 - 1) + 2)>
#map14 = affine_map<() -> (56)>
#map15 = affine_map<() -> (58)>
#map16 = affine_map<(d0) -> (d0 + 1)>
#map17 = affine_map<(d0, d1) -> (d0 + d1)>
#map18 = affine_map<() -> (28)>
#map19 = affine_map<() -> (128)>
#map20 = affine_map<() -> (30)>
#map21 = affine_map<() -> (14)>
#map22 = affine_map<() -> (256)>
#map23 = affine_map<() -> (16)>
#map24 = affine_map<() -> (512)>
#map25 = affine_map<() -> (9)>
#map26 = affine_map<(d0, d1, d2)[s0, s1, s2] -> (d2 + d1 * s2 + d0 * (s1 * s2))>
#map27 = affine_map<(d0, d1) -> (d0, d1)>
#map28 = affine_map<() -> (1000)>
module {
  %0 = "krnl.packed_const"() {file_name = "/tmp/packed_const-84fa71.tmp", is_le = true, size_in_bytes = 46738848 : i64} : () -> i64
  func @main_graph(%arg0: memref<1x3x224x224xf32>) -> memref<1x1000xf32> attributes {input_names = ["data"], output_names = ["resnetv15_dense0_fwd"]} {
    %cst = constant 0xFF800000 : f32
    %c112 = constant 112 : index
    %c3 = constant 3 : index
    %c2 = constant 2 : index
    %c0 = constant 0 : index
    %c49_i64 = constant 49 : i64
    %c512 = constant 512 : index
    %c1 = constant 1 : index
    %cst_0 = constant 1.000000e+00 : f32
    %cst_1 = constant 0.000000e+00 : f32
    %1 = alloc() : memref<1x1000xf32>
    %2 = alloc() : memref<1x512xf32>
    %3 = alloc() : memref<1x512x1x1xf32>
    %4 = alloc() : memref<1x512x7x7xf32>
    %5 = alloc() : memref<1x512x7x7xf32>
    %6 = alloc() : memref<1x512x7x7xf32>
    %7 = alloc() : memref<1x512x9x9xf32>
    %8 = alloc() : memref<1x512x7x7xf32>
    %9 = alloc() : memref<1x512x7x7xf32>
    %10 = alloc() : memref<1x512x9x9xf32>
    %11 = alloc() : memref<1x512x7x7xf32>
    %12 = alloc() : memref<1x512x7x7xf32>
    %13 = alloc() : memref<1x512x7x7xf32>
    %14 = alloc() : memref<1x512x9x9xf32>
    %15 = alloc() : memref<1x512x7x7xf32>
    %16 = alloc() : memref<1x512x7x7xf32>
    %17 = alloc() : memref<1x256x16x16xf32>
    %18 = alloc() : memref<1x512x7x7xf32>
    %19 = alloc() : memref<1x256x14x14xf32>
    %20 = alloc() : memref<1x256x14x14xf32>
    %21 = alloc() : memref<1x256x14x14xf32>
    %22 = alloc() : memref<1x256x16x16xf32>
    %23 = alloc() : memref<1x256x14x14xf32>
    %24 = alloc() : memref<1x256x14x14xf32>
    %25 = alloc() : memref<1x256x16x16xf32>
    %26 = alloc() : memref<1x256x14x14xf32>
    %27 = alloc() : memref<1x256x14x14xf32>
    %28 = alloc() : memref<1x256x14x14xf32>
    %29 = alloc() : memref<1x256x16x16xf32>
    %30 = alloc() : memref<1x256x14x14xf32>
    %31 = alloc() : memref<1x256x14x14xf32>
    %32 = alloc() : memref<1x128x30x30xf32>
    %33 = alloc() : memref<1x256x14x14xf32>
    %34 = alloc() : memref<1x128x28x28xf32>
    %35 = alloc() : memref<1x128x28x28xf32>
    %36 = alloc() : memref<1x128x28x28xf32>
    %37 = alloc() : memref<1x128x30x30xf32>
    %38 = alloc() : memref<1x128x28x28xf32>
    %39 = alloc() : memref<1x128x28x28xf32>
    %40 = alloc() : memref<1x128x30x30xf32>
    %41 = alloc() : memref<1x128x28x28xf32>
    %42 = alloc() : memref<1x128x28x28xf32>
    %43 = alloc() : memref<1x128x28x28xf32>
    %44 = alloc() : memref<1x128x30x30xf32>
    %45 = alloc() : memref<1x128x28x28xf32>
    %46 = alloc() : memref<1x128x28x28xf32>
    %47 = alloc() : memref<1x64x58x58xf32>
    %48 = alloc() : memref<1x128x28x28xf32>
    %49 = alloc() : memref<1x64x56x56xf32>
    %50 = alloc() : memref<1x64x56x56xf32>
    %51 = alloc() : memref<1x64x56x56xf32>
    %52 = alloc() : memref<1x64x58x58xf32>
    %53 = alloc() : memref<1x64x56x56xf32>
    %54 = alloc() : memref<1x64x56x56xf32>
    %55 = alloc() : memref<1x64x58x58xf32>
    %56 = alloc() : memref<1x64x56x56xf32>
    %57 = alloc() : memref<1x64x56x56xf32>
    %58 = alloc() : memref<1x64x56x56xf32>
    %59 = alloc() : memref<1x64x58x58xf32>
    %60 = alloc() : memref<1x64x56x56xf32>
    %61 = alloc() : memref<1x64x56x56xf32>
    %62 = alloc() : memref<1x64x58x58xf32>
    %63 = alloc() : memref<1x64x56x56xf32>
    %64 = alloc() : memref<1x64x112x112xf32>
    %65 = alloc() : memref<1x64x112x112xf32>
    %66 = alloc() : memref<1x3x230x230xf32>
    %67 = "krnl.global"() {name = "constant_0", offset = 0 : i64, shape = [64, 3, 7, 7]} : () -> memref<64x3x7x7xf32>
    %68 = "krnl.global"() {name = "constant_1", offset = 37632 : i64, shape = [64]} : () -> memref<64xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 3 {
        affine.for %arg3 = 0 to 230 {
          affine.for %arg4 = 0 to 230 {
            affine.store %cst_1, %66[%arg1, %arg2, %arg3, %arg4] : memref<1x3x230x230xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 3 {
        affine.for %arg3 = 0 to 224 {
          affine.for %arg4 = 0 to 224 {
            %110 = affine.apply #map5(%arg3)
            %111 = affine.apply #map5(%arg4)
            %112 = affine.load %arg0[%arg1, %arg2, %arg3, %arg4] : memref<1x3x224x224xf32>
            affine.store %112, %66[%arg1, %arg2, %110, %111] : memref<1x3x230x230xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 112 {
          affine.for %arg4 = 0 to 112 {
            affine.store %cst_1, %65[%arg1, %arg2, %arg3, %arg4] : memref<1x64x112x112xf32>
            affine.for %arg5 = 0 to 3 {
              affine.for %arg6 = 0 to 7 {
                affine.for %arg7 = 0 to 7 {
                  %113 = affine.apply #map7(%arg3, %arg6)
                  %114 = affine.apply #map7(%arg4, %arg7)
                  %115 = affine.load %66[%arg1, %arg5, %113, %114] : memref<1x3x230x230xf32>
                  %116 = affine.load %67[%arg2, %arg5, %arg6, %arg7] : memref<64x3x7x7xf32>
                  %117 = affine.load %65[%arg1, %arg2, %arg3, %arg4] : memref<1x64x112x112xf32>
                  %118 = mulf %115, %116 : f32
                  %119 = addf %117, %118 : f32
                  affine.store %119, %65[%arg1, %arg2, %arg3, %arg4] : memref<1x64x112x112xf32>
                }
              }
            }
            %110 = affine.load %65[%arg1, %arg2, %arg3, %arg4] : memref<1x64x112x112xf32>
            %111 = affine.load %68[%arg2] : memref<64xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %65[%arg1, %arg2, %arg3, %arg4] : memref<1x64x112x112xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 112 {
          affine.for %arg4 = 0 to 112 {
            %110 = affine.load %65[%arg1, %arg2, %arg3, %arg4] : memref<1x64x112x112xf32>
            %111 = cmpf "olt", %110, %cst_1 : f32
            %112 = select %111, %cst_1, %110 : f32
            affine.store %112, %64[%arg1, %arg2, %arg3, %arg4] : memref<1x64x112x112xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 56 {
          affine.for %arg4 = 0 to 56 {
            affine.store %cst, %63[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
            %110 = affine.max #map12(%arg3)[%c112, %c3, %c1, %c2, %c1]
            %111 = affine.max #map12(%arg4)[%c112, %c3, %c1, %c2, %c1]
            affine.for %arg5 = 0 to min #map13(%arg3) {
              affine.for %arg6 = 0 to min #map13(%arg4) {
                %112 = addi %arg5, %110 : index
                %113 = addi %arg6, %111 : index
                %114 = load %64[%arg1, %arg2, %112, %113] : memref<1x64x112x112xf32>
                %115 = affine.load %63[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
                %116 = cmpf "ogt", %115, %114 : f32
                %117 = select %116, %115, %114 : f32
                affine.store %117, %63[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
              }
            }
          }
        }
      }
    }
    %69 = "krnl.global"() {name = "constant_2", offset = 37888 : i64, shape = [64, 64, 3, 3]} : () -> memref<64x64x3x3xf32>
    %70 = "krnl.global"() {name = "constant_3", offset = 185344 : i64, shape = [64]} : () -> memref<64xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 58 {
          affine.for %arg4 = 0 to 58 {
            affine.store %cst_1, %62[%arg1, %arg2, %arg3, %arg4] : memref<1x64x58x58xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 56 {
          affine.for %arg4 = 0 to 56 {
            %110 = affine.apply #map16(%arg3)
            %111 = affine.apply #map16(%arg4)
            %112 = affine.load %63[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
            affine.store %112, %62[%arg1, %arg2, %110, %111] : memref<1x64x58x58xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 56 {
          affine.for %arg4 = 0 to 56 {
            affine.store %cst_1, %61[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
            affine.for %arg5 = 0 to 64 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %113 = affine.apply #map17(%arg3, %arg6)
                  %114 = affine.apply #map17(%arg4, %arg7)
                  %115 = affine.load %62[%arg1, %arg5, %113, %114] : memref<1x64x58x58xf32>
                  %116 = affine.load %69[%arg2, %arg5, %arg6, %arg7] : memref<64x64x3x3xf32>
                  %117 = affine.load %61[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
                  %118 = mulf %115, %116 : f32
                  %119 = addf %117, %118 : f32
                  affine.store %119, %61[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
                }
              }
            }
            %110 = affine.load %61[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
            %111 = affine.load %70[%arg2] : memref<64xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %61[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 56 {
          affine.for %arg4 = 0 to 56 {
            %110 = affine.load %61[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
            %111 = cmpf "olt", %110, %cst_1 : f32
            %112 = select %111, %cst_1, %110 : f32
            affine.store %112, %60[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
          }
        }
      }
    }
    %71 = "krnl.global"() {name = "constant_4", offset = 185600 : i64, shape = [64, 64, 3, 3]} : () -> memref<64x64x3x3xf32>
    %72 = "krnl.global"() {name = "constant_5", offset = 333056 : i64, shape = [64]} : () -> memref<64xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 58 {
          affine.for %arg4 = 0 to 58 {
            affine.store %cst_1, %59[%arg1, %arg2, %arg3, %arg4] : memref<1x64x58x58xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 56 {
          affine.for %arg4 = 0 to 56 {
            %110 = affine.apply #map16(%arg3)
            %111 = affine.apply #map16(%arg4)
            %112 = affine.load %60[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
            affine.store %112, %59[%arg1, %arg2, %110, %111] : memref<1x64x58x58xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 56 {
          affine.for %arg4 = 0 to 56 {
            affine.store %cst_1, %58[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
            affine.for %arg5 = 0 to 64 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %113 = affine.apply #map17(%arg3, %arg6)
                  %114 = affine.apply #map17(%arg4, %arg7)
                  %115 = affine.load %59[%arg1, %arg5, %113, %114] : memref<1x64x58x58xf32>
                  %116 = affine.load %71[%arg2, %arg5, %arg6, %arg7] : memref<64x64x3x3xf32>
                  %117 = affine.load %58[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
                  %118 = mulf %115, %116 : f32
                  %119 = addf %117, %118 : f32
                  affine.store %119, %58[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
                }
              }
            }
            %110 = affine.load %58[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
            %111 = affine.load %72[%arg2] : memref<64xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %58[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 56 {
          affine.for %arg4 = 0 to 56 {
            %110 = affine.load %63[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
            %111 = affine.load %58[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %57[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 56 {
          affine.for %arg4 = 0 to 56 {
            %110 = affine.load %57[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
            %111 = cmpf "olt", %110, %cst_1 : f32
            %112 = select %111, %cst_1, %110 : f32
            affine.store %112, %56[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
          }
        }
      }
    }
    %73 = "krnl.global"() {name = "constant_6", offset = 333312 : i64, shape = [64, 64, 3, 3]} : () -> memref<64x64x3x3xf32>
    %74 = "krnl.global"() {name = "constant_7", offset = 480768 : i64, shape = [64]} : () -> memref<64xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 58 {
          affine.for %arg4 = 0 to 58 {
            affine.store %cst_1, %55[%arg1, %arg2, %arg3, %arg4] : memref<1x64x58x58xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 56 {
          affine.for %arg4 = 0 to 56 {
            %110 = affine.apply #map16(%arg3)
            %111 = affine.apply #map16(%arg4)
            %112 = affine.load %56[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
            affine.store %112, %55[%arg1, %arg2, %110, %111] : memref<1x64x58x58xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 56 {
          affine.for %arg4 = 0 to 56 {
            affine.store %cst_1, %54[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
            affine.for %arg5 = 0 to 64 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %113 = affine.apply #map17(%arg3, %arg6)
                  %114 = affine.apply #map17(%arg4, %arg7)
                  %115 = affine.load %55[%arg1, %arg5, %113, %114] : memref<1x64x58x58xf32>
                  %116 = affine.load %73[%arg2, %arg5, %arg6, %arg7] : memref<64x64x3x3xf32>
                  %117 = affine.load %54[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
                  %118 = mulf %115, %116 : f32
                  %119 = addf %117, %118 : f32
                  affine.store %119, %54[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
                }
              }
            }
            %110 = affine.load %54[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
            %111 = affine.load %74[%arg2] : memref<64xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %54[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 56 {
          affine.for %arg4 = 0 to 56 {
            %110 = affine.load %54[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
            %111 = cmpf "olt", %110, %cst_1 : f32
            %112 = select %111, %cst_1, %110 : f32
            affine.store %112, %53[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
          }
        }
      }
    }
    %75 = "krnl.global"() {name = "constant_8", offset = 481024 : i64, shape = [64, 64, 3, 3]} : () -> memref<64x64x3x3xf32>
    %76 = "krnl.global"() {name = "constant_9", offset = 628480 : i64, shape = [64]} : () -> memref<64xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 58 {
          affine.for %arg4 = 0 to 58 {
            affine.store %cst_1, %52[%arg1, %arg2, %arg3, %arg4] : memref<1x64x58x58xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 56 {
          affine.for %arg4 = 0 to 56 {
            %110 = affine.apply #map16(%arg3)
            %111 = affine.apply #map16(%arg4)
            %112 = affine.load %53[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
            affine.store %112, %52[%arg1, %arg2, %110, %111] : memref<1x64x58x58xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 56 {
          affine.for %arg4 = 0 to 56 {
            affine.store %cst_1, %51[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
            affine.for %arg5 = 0 to 64 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %113 = affine.apply #map17(%arg3, %arg6)
                  %114 = affine.apply #map17(%arg4, %arg7)
                  %115 = affine.load %52[%arg1, %arg5, %113, %114] : memref<1x64x58x58xf32>
                  %116 = affine.load %75[%arg2, %arg5, %arg6, %arg7] : memref<64x64x3x3xf32>
                  %117 = affine.load %51[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
                  %118 = mulf %115, %116 : f32
                  %119 = addf %117, %118 : f32
                  affine.store %119, %51[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
                }
              }
            }
            %110 = affine.load %51[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
            %111 = affine.load %76[%arg2] : memref<64xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %51[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 56 {
          affine.for %arg4 = 0 to 56 {
            %110 = affine.load %56[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
            %111 = affine.load %51[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %50[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 56 {
          affine.for %arg4 = 0 to 56 {
            %110 = affine.load %50[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
            %111 = cmpf "olt", %110, %cst_1 : f32
            %112 = select %111, %cst_1, %110 : f32
            affine.store %112, %49[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
          }
        }
      }
    }
    %77 = "krnl.global"() {name = "constant_10", offset = 628736 : i64, shape = [128, 64, 1, 1]} : () -> memref<128x64x1x1xf32>
    %78 = "krnl.global"() {name = "constant_11", offset = 661504 : i64, shape = [128]} : () -> memref<128xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 28 {
          affine.for %arg4 = 0 to 28 {
            affine.store %cst_1, %48[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
            affine.for %arg5 = 0 to 64 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %113 = affine.apply #map7(%arg3, %arg6)
                  %114 = affine.apply #map7(%arg4, %arg7)
                  %115 = affine.load %49[%arg1, %arg5, %113, %114] : memref<1x64x56x56xf32>
                  %116 = affine.load %77[%arg2, %arg5, %arg6, %arg7] : memref<128x64x1x1xf32>
                  %117 = affine.load %48[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
                  %118 = mulf %115, %116 : f32
                  %119 = addf %117, %118 : f32
                  affine.store %119, %48[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
                }
              }
            }
            %110 = affine.load %48[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
            %111 = affine.load %78[%arg2] : memref<128xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %48[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
          }
        }
      }
    }
    %79 = "krnl.global"() {name = "constant_12", offset = 662016 : i64, shape = [128, 64, 3, 3]} : () -> memref<128x64x3x3xf32>
    %80 = "krnl.global"() {name = "constant_13", offset = 956928 : i64, shape = [128]} : () -> memref<128xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 58 {
          affine.for %arg4 = 0 to 58 {
            affine.store %cst_1, %47[%arg1, %arg2, %arg3, %arg4] : memref<1x64x58x58xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 56 {
          affine.for %arg4 = 0 to 56 {
            %110 = affine.apply #map16(%arg3)
            %111 = affine.apply #map16(%arg4)
            %112 = affine.load %49[%arg1, %arg2, %arg3, %arg4] : memref<1x64x56x56xf32>
            affine.store %112, %47[%arg1, %arg2, %110, %111] : memref<1x64x58x58xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 28 {
          affine.for %arg4 = 0 to 28 {
            affine.store %cst_1, %46[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
            affine.for %arg5 = 0 to 64 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %113 = affine.apply #map7(%arg3, %arg6)
                  %114 = affine.apply #map7(%arg4, %arg7)
                  %115 = affine.load %47[%arg1, %arg5, %113, %114] : memref<1x64x58x58xf32>
                  %116 = affine.load %79[%arg2, %arg5, %arg6, %arg7] : memref<128x64x3x3xf32>
                  %117 = affine.load %46[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
                  %118 = mulf %115, %116 : f32
                  %119 = addf %117, %118 : f32
                  affine.store %119, %46[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
                }
              }
            }
            %110 = affine.load %46[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
            %111 = affine.load %80[%arg2] : memref<128xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %46[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 28 {
          affine.for %arg4 = 0 to 28 {
            %110 = affine.load %46[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
            %111 = cmpf "olt", %110, %cst_1 : f32
            %112 = select %111, %cst_1, %110 : f32
            affine.store %112, %45[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
          }
        }
      }
    }
    %81 = "krnl.global"() {name = "constant_14", offset = 957440 : i64, shape = [128, 128, 3, 3]} : () -> memref<128x128x3x3xf32>
    %82 = "krnl.global"() {name = "constant_15", offset = 1547264 : i64, shape = [128]} : () -> memref<128xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 30 {
          affine.for %arg4 = 0 to 30 {
            affine.store %cst_1, %44[%arg1, %arg2, %arg3, %arg4] : memref<1x128x30x30xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 28 {
          affine.for %arg4 = 0 to 28 {
            %110 = affine.apply #map16(%arg3)
            %111 = affine.apply #map16(%arg4)
            %112 = affine.load %45[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
            affine.store %112, %44[%arg1, %arg2, %110, %111] : memref<1x128x30x30xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 28 {
          affine.for %arg4 = 0 to 28 {
            affine.store %cst_1, %43[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
            affine.for %arg5 = 0 to 128 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %113 = affine.apply #map17(%arg3, %arg6)
                  %114 = affine.apply #map17(%arg4, %arg7)
                  %115 = affine.load %44[%arg1, %arg5, %113, %114] : memref<1x128x30x30xf32>
                  %116 = affine.load %81[%arg2, %arg5, %arg6, %arg7] : memref<128x128x3x3xf32>
                  %117 = affine.load %43[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
                  %118 = mulf %115, %116 : f32
                  %119 = addf %117, %118 : f32
                  affine.store %119, %43[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
                }
              }
            }
            %110 = affine.load %43[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
            %111 = affine.load %82[%arg2] : memref<128xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %43[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 28 {
          affine.for %arg4 = 0 to 28 {
            %110 = affine.load %48[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
            %111 = affine.load %43[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %42[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 28 {
          affine.for %arg4 = 0 to 28 {
            %110 = affine.load %42[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
            %111 = cmpf "olt", %110, %cst_1 : f32
            %112 = select %111, %cst_1, %110 : f32
            affine.store %112, %41[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
          }
        }
      }
    }
    %83 = "krnl.global"() {name = "constant_16", offset = 1547776 : i64, shape = [128, 128, 3, 3]} : () -> memref<128x128x3x3xf32>
    %84 = "krnl.global"() {name = "constant_17", offset = 2137600 : i64, shape = [128]} : () -> memref<128xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 30 {
          affine.for %arg4 = 0 to 30 {
            affine.store %cst_1, %40[%arg1, %arg2, %arg3, %arg4] : memref<1x128x30x30xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 28 {
          affine.for %arg4 = 0 to 28 {
            %110 = affine.apply #map16(%arg3)
            %111 = affine.apply #map16(%arg4)
            %112 = affine.load %41[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
            affine.store %112, %40[%arg1, %arg2, %110, %111] : memref<1x128x30x30xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 28 {
          affine.for %arg4 = 0 to 28 {
            affine.store %cst_1, %39[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
            affine.for %arg5 = 0 to 128 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %113 = affine.apply #map17(%arg3, %arg6)
                  %114 = affine.apply #map17(%arg4, %arg7)
                  %115 = affine.load %40[%arg1, %arg5, %113, %114] : memref<1x128x30x30xf32>
                  %116 = affine.load %83[%arg2, %arg5, %arg6, %arg7] : memref<128x128x3x3xf32>
                  %117 = affine.load %39[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
                  %118 = mulf %115, %116 : f32
                  %119 = addf %117, %118 : f32
                  affine.store %119, %39[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
                }
              }
            }
            %110 = affine.load %39[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
            %111 = affine.load %84[%arg2] : memref<128xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %39[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 28 {
          affine.for %arg4 = 0 to 28 {
            %110 = affine.load %39[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
            %111 = cmpf "olt", %110, %cst_1 : f32
            %112 = select %111, %cst_1, %110 : f32
            affine.store %112, %38[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
          }
        }
      }
    }
    %85 = "krnl.global"() {name = "constant_18", offset = 2138112 : i64, shape = [128, 128, 3, 3]} : () -> memref<128x128x3x3xf32>
    %86 = "krnl.global"() {name = "constant_19", offset = 2727936 : i64, shape = [128]} : () -> memref<128xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 30 {
          affine.for %arg4 = 0 to 30 {
            affine.store %cst_1, %37[%arg1, %arg2, %arg3, %arg4] : memref<1x128x30x30xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 28 {
          affine.for %arg4 = 0 to 28 {
            %110 = affine.apply #map16(%arg3)
            %111 = affine.apply #map16(%arg4)
            %112 = affine.load %38[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
            affine.store %112, %37[%arg1, %arg2, %110, %111] : memref<1x128x30x30xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 28 {
          affine.for %arg4 = 0 to 28 {
            affine.store %cst_1, %36[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
            affine.for %arg5 = 0 to 128 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %113 = affine.apply #map17(%arg3, %arg6)
                  %114 = affine.apply #map17(%arg4, %arg7)
                  %115 = affine.load %37[%arg1, %arg5, %113, %114] : memref<1x128x30x30xf32>
                  %116 = affine.load %85[%arg2, %arg5, %arg6, %arg7] : memref<128x128x3x3xf32>
                  %117 = affine.load %36[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
                  %118 = mulf %115, %116 : f32
                  %119 = addf %117, %118 : f32
                  affine.store %119, %36[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
                }
              }
            }
            %110 = affine.load %36[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
            %111 = affine.load %86[%arg2] : memref<128xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %36[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 28 {
          affine.for %arg4 = 0 to 28 {
            %110 = affine.load %41[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
            %111 = affine.load %36[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %35[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 28 {
          affine.for %arg4 = 0 to 28 {
            %110 = affine.load %35[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
            %111 = cmpf "olt", %110, %cst_1 : f32
            %112 = select %111, %cst_1, %110 : f32
            affine.store %112, %34[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
          }
        }
      }
    }
    %87 = "krnl.global"() {name = "constant_20", offset = 2728448 : i64, shape = [256, 128, 1, 1]} : () -> memref<256x128x1x1xf32>
    %88 = "krnl.global"() {name = "constant_21", offset = 2859520 : i64, shape = [256]} : () -> memref<256xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            affine.store %cst_1, %33[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
            affine.for %arg5 = 0 to 128 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %113 = affine.apply #map7(%arg3, %arg6)
                  %114 = affine.apply #map7(%arg4, %arg7)
                  %115 = affine.load %34[%arg1, %arg5, %113, %114] : memref<1x128x28x28xf32>
                  %116 = affine.load %87[%arg2, %arg5, %arg6, %arg7] : memref<256x128x1x1xf32>
                  %117 = affine.load %33[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
                  %118 = mulf %115, %116 : f32
                  %119 = addf %117, %118 : f32
                  affine.store %119, %33[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
                }
              }
            }
            %110 = affine.load %33[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
            %111 = affine.load %88[%arg2] : memref<256xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %33[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
          }
        }
      }
    }
    %89 = "krnl.global"() {name = "constant_22", offset = 2860544 : i64, shape = [256, 128, 3, 3]} : () -> memref<256x128x3x3xf32>
    %90 = "krnl.global"() {name = "constant_23", offset = 4040192 : i64, shape = [256]} : () -> memref<256xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 30 {
          affine.for %arg4 = 0 to 30 {
            affine.store %cst_1, %32[%arg1, %arg2, %arg3, %arg4] : memref<1x128x30x30xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 28 {
          affine.for %arg4 = 0 to 28 {
            %110 = affine.apply #map16(%arg3)
            %111 = affine.apply #map16(%arg4)
            %112 = affine.load %34[%arg1, %arg2, %arg3, %arg4] : memref<1x128x28x28xf32>
            affine.store %112, %32[%arg1, %arg2, %110, %111] : memref<1x128x30x30xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            affine.store %cst_1, %31[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
            affine.for %arg5 = 0 to 128 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %113 = affine.apply #map7(%arg3, %arg6)
                  %114 = affine.apply #map7(%arg4, %arg7)
                  %115 = affine.load %32[%arg1, %arg5, %113, %114] : memref<1x128x30x30xf32>
                  %116 = affine.load %89[%arg2, %arg5, %arg6, %arg7] : memref<256x128x3x3xf32>
                  %117 = affine.load %31[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
                  %118 = mulf %115, %116 : f32
                  %119 = addf %117, %118 : f32
                  affine.store %119, %31[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
                }
              }
            }
            %110 = affine.load %31[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
            %111 = affine.load %90[%arg2] : memref<256xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %31[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            %110 = affine.load %31[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
            %111 = cmpf "olt", %110, %cst_1 : f32
            %112 = select %111, %cst_1, %110 : f32
            affine.store %112, %30[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
          }
        }
      }
    }
    %91 = "krnl.global"() {name = "constant_24", offset = 4041216 : i64, shape = [256, 256, 3, 3]} : () -> memref<256x256x3x3xf32>
    %92 = "krnl.global"() {name = "constant_25", offset = 6400512 : i64, shape = [256]} : () -> memref<256xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            affine.store %cst_1, %29[%arg1, %arg2, %arg3, %arg4] : memref<1x256x16x16xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            %110 = affine.apply #map16(%arg3)
            %111 = affine.apply #map16(%arg4)
            %112 = affine.load %30[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
            affine.store %112, %29[%arg1, %arg2, %110, %111] : memref<1x256x16x16xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            affine.store %cst_1, %28[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
            affine.for %arg5 = 0 to 256 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %113 = affine.apply #map17(%arg3, %arg6)
                  %114 = affine.apply #map17(%arg4, %arg7)
                  %115 = affine.load %29[%arg1, %arg5, %113, %114] : memref<1x256x16x16xf32>
                  %116 = affine.load %91[%arg2, %arg5, %arg6, %arg7] : memref<256x256x3x3xf32>
                  %117 = affine.load %28[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
                  %118 = mulf %115, %116 : f32
                  %119 = addf %117, %118 : f32
                  affine.store %119, %28[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
                }
              }
            }
            %110 = affine.load %28[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
            %111 = affine.load %92[%arg2] : memref<256xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %28[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            %110 = affine.load %33[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
            %111 = affine.load %28[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %27[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            %110 = affine.load %27[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
            %111 = cmpf "olt", %110, %cst_1 : f32
            %112 = select %111, %cst_1, %110 : f32
            affine.store %112, %26[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
          }
        }
      }
    }
    %93 = "krnl.global"() {name = "constant_26", offset = 6401536 : i64, shape = [256, 256, 3, 3]} : () -> memref<256x256x3x3xf32>
    %94 = "krnl.global"() {name = "constant_27", offset = 8760832 : i64, shape = [256]} : () -> memref<256xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            affine.store %cst_1, %25[%arg1, %arg2, %arg3, %arg4] : memref<1x256x16x16xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            %110 = affine.apply #map16(%arg3)
            %111 = affine.apply #map16(%arg4)
            %112 = affine.load %26[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
            affine.store %112, %25[%arg1, %arg2, %110, %111] : memref<1x256x16x16xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            affine.store %cst_1, %24[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
            affine.for %arg5 = 0 to 256 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %113 = affine.apply #map17(%arg3, %arg6)
                  %114 = affine.apply #map17(%arg4, %arg7)
                  %115 = affine.load %25[%arg1, %arg5, %113, %114] : memref<1x256x16x16xf32>
                  %116 = affine.load %93[%arg2, %arg5, %arg6, %arg7] : memref<256x256x3x3xf32>
                  %117 = affine.load %24[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
                  %118 = mulf %115, %116 : f32
                  %119 = addf %117, %118 : f32
                  affine.store %119, %24[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
                }
              }
            }
            %110 = affine.load %24[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
            %111 = affine.load %94[%arg2] : memref<256xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %24[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            %110 = affine.load %24[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
            %111 = cmpf "olt", %110, %cst_1 : f32
            %112 = select %111, %cst_1, %110 : f32
            affine.store %112, %23[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
          }
        }
      }
    }
    %95 = "krnl.global"() {name = "constant_28", offset = 8761856 : i64, shape = [256, 256, 3, 3]} : () -> memref<256x256x3x3xf32>
    %96 = "krnl.global"() {name = "constant_29", offset = 11121152 : i64, shape = [256]} : () -> memref<256xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            affine.store %cst_1, %22[%arg1, %arg2, %arg3, %arg4] : memref<1x256x16x16xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            %110 = affine.apply #map16(%arg3)
            %111 = affine.apply #map16(%arg4)
            %112 = affine.load %23[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
            affine.store %112, %22[%arg1, %arg2, %110, %111] : memref<1x256x16x16xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            affine.store %cst_1, %21[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
            affine.for %arg5 = 0 to 256 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %113 = affine.apply #map17(%arg3, %arg6)
                  %114 = affine.apply #map17(%arg4, %arg7)
                  %115 = affine.load %22[%arg1, %arg5, %113, %114] : memref<1x256x16x16xf32>
                  %116 = affine.load %95[%arg2, %arg5, %arg6, %arg7] : memref<256x256x3x3xf32>
                  %117 = affine.load %21[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
                  %118 = mulf %115, %116 : f32
                  %119 = addf %117, %118 : f32
                  affine.store %119, %21[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
                }
              }
            }
            %110 = affine.load %21[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
            %111 = affine.load %96[%arg2] : memref<256xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %21[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            %110 = affine.load %26[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
            %111 = affine.load %21[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %20[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            %110 = affine.load %20[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
            %111 = cmpf "olt", %110, %cst_1 : f32
            %112 = select %111, %cst_1, %110 : f32
            affine.store %112, %19[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
          }
        }
      }
    }
    %97 = "krnl.global"() {name = "constant_30", offset = 11122176 : i64, shape = [512, 256, 1, 1]} : () -> memref<512x256x1x1xf32>
    %98 = "krnl.global"() {name = "constant_31", offset = 11646464 : i64, shape = [512]} : () -> memref<512xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 7 {
          affine.for %arg4 = 0 to 7 {
            affine.store %cst_1, %18[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
            affine.for %arg5 = 0 to 256 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %113 = affine.apply #map7(%arg3, %arg6)
                  %114 = affine.apply #map7(%arg4, %arg7)
                  %115 = affine.load %19[%arg1, %arg5, %113, %114] : memref<1x256x14x14xf32>
                  %116 = affine.load %97[%arg2, %arg5, %arg6, %arg7] : memref<512x256x1x1xf32>
                  %117 = affine.load %18[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
                  %118 = mulf %115, %116 : f32
                  %119 = addf %117, %118 : f32
                  affine.store %119, %18[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
                }
              }
            }
            %110 = affine.load %18[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
            %111 = affine.load %98[%arg2] : memref<512xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %18[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
          }
        }
      }
    }
    %99 = "krnl.global"() {name = "constant_32", offset = 11648512 : i64, shape = [512, 256, 3, 3]} : () -> memref<512x256x3x3xf32>
    %100 = "krnl.global"() {name = "constant_33", offset = 16367104 : i64, shape = [512]} : () -> memref<512xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            affine.store %cst_1, %17[%arg1, %arg2, %arg3, %arg4] : memref<1x256x16x16xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            %110 = affine.apply #map16(%arg3)
            %111 = affine.apply #map16(%arg4)
            %112 = affine.load %19[%arg1, %arg2, %arg3, %arg4] : memref<1x256x14x14xf32>
            affine.store %112, %17[%arg1, %arg2, %110, %111] : memref<1x256x16x16xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 7 {
          affine.for %arg4 = 0 to 7 {
            affine.store %cst_1, %16[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
            affine.for %arg5 = 0 to 256 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %113 = affine.apply #map7(%arg3, %arg6)
                  %114 = affine.apply #map7(%arg4, %arg7)
                  %115 = affine.load %17[%arg1, %arg5, %113, %114] : memref<1x256x16x16xf32>
                  %116 = affine.load %99[%arg2, %arg5, %arg6, %arg7] : memref<512x256x3x3xf32>
                  %117 = affine.load %16[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
                  %118 = mulf %115, %116 : f32
                  %119 = addf %117, %118 : f32
                  affine.store %119, %16[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
                }
              }
            }
            %110 = affine.load %16[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
            %111 = affine.load %100[%arg2] : memref<512xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %16[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 7 {
          affine.for %arg4 = 0 to 7 {
            %110 = affine.load %16[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
            %111 = cmpf "olt", %110, %cst_1 : f32
            %112 = select %111, %cst_1, %110 : f32
            affine.store %112, %15[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
          }
        }
      }
    }
    %101 = "krnl.global"() {name = "constant_34", offset = 16369152 : i64, shape = [512, 512, 3, 3]} : () -> memref<512x512x3x3xf32>
    %102 = "krnl.global"() {name = "constant_35", offset = 25806336 : i64, shape = [512]} : () -> memref<512xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 9 {
          affine.for %arg4 = 0 to 9 {
            affine.store %cst_1, %14[%arg1, %arg2, %arg3, %arg4] : memref<1x512x9x9xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 7 {
          affine.for %arg4 = 0 to 7 {
            %110 = affine.apply #map16(%arg3)
            %111 = affine.apply #map16(%arg4)
            %112 = affine.load %15[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
            affine.store %112, %14[%arg1, %arg2, %110, %111] : memref<1x512x9x9xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 7 {
          affine.for %arg4 = 0 to 7 {
            affine.store %cst_1, %13[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
            affine.for %arg5 = 0 to 512 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %113 = affine.apply #map17(%arg3, %arg6)
                  %114 = affine.apply #map17(%arg4, %arg7)
                  %115 = affine.load %14[%arg1, %arg5, %113, %114] : memref<1x512x9x9xf32>
                  %116 = affine.load %101[%arg2, %arg5, %arg6, %arg7] : memref<512x512x3x3xf32>
                  %117 = affine.load %13[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
                  %118 = mulf %115, %116 : f32
                  %119 = addf %117, %118 : f32
                  affine.store %119, %13[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
                }
              }
            }
            %110 = affine.load %13[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
            %111 = affine.load %102[%arg2] : memref<512xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %13[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 7 {
          affine.for %arg4 = 0 to 7 {
            %110 = affine.load %18[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
            %111 = affine.load %13[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %12[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 7 {
          affine.for %arg4 = 0 to 7 {
            %110 = affine.load %12[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
            %111 = cmpf "olt", %110, %cst_1 : f32
            %112 = select %111, %cst_1, %110 : f32
            affine.store %112, %11[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
          }
        }
      }
    }
    %103 = "krnl.global"() {name = "constant_36", offset = 25808384 : i64, shape = [512, 512, 3, 3]} : () -> memref<512x512x3x3xf32>
    %104 = "krnl.global"() {name = "constant_37", offset = 35245568 : i64, shape = [512]} : () -> memref<512xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 9 {
          affine.for %arg4 = 0 to 9 {
            affine.store %cst_1, %10[%arg1, %arg2, %arg3, %arg4] : memref<1x512x9x9xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 7 {
          affine.for %arg4 = 0 to 7 {
            %110 = affine.apply #map16(%arg3)
            %111 = affine.apply #map16(%arg4)
            %112 = affine.load %11[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
            affine.store %112, %10[%arg1, %arg2, %110, %111] : memref<1x512x9x9xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 7 {
          affine.for %arg4 = 0 to 7 {
            affine.store %cst_1, %9[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
            affine.for %arg5 = 0 to 512 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %113 = affine.apply #map17(%arg3, %arg6)
                  %114 = affine.apply #map17(%arg4, %arg7)
                  %115 = affine.load %10[%arg1, %arg5, %113, %114] : memref<1x512x9x9xf32>
                  %116 = affine.load %103[%arg2, %arg5, %arg6, %arg7] : memref<512x512x3x3xf32>
                  %117 = affine.load %9[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
                  %118 = mulf %115, %116 : f32
                  %119 = addf %117, %118 : f32
                  affine.store %119, %9[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
                }
              }
            }
            %110 = affine.load %9[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
            %111 = affine.load %104[%arg2] : memref<512xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %9[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 7 {
          affine.for %arg4 = 0 to 7 {
            %110 = affine.load %9[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
            %111 = cmpf "olt", %110, %cst_1 : f32
            %112 = select %111, %cst_1, %110 : f32
            affine.store %112, %8[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
          }
        }
      }
    }
    %105 = "krnl.global"() {name = "constant_38", offset = 35247616 : i64, shape = [512, 512, 3, 3]} : () -> memref<512x512x3x3xf32>
    %106 = "krnl.global"() {name = "constant_39", offset = 44684800 : i64, shape = [512]} : () -> memref<512xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 9 {
          affine.for %arg4 = 0 to 9 {
            affine.store %cst_1, %7[%arg1, %arg2, %arg3, %arg4] : memref<1x512x9x9xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 7 {
          affine.for %arg4 = 0 to 7 {
            %110 = affine.apply #map16(%arg3)
            %111 = affine.apply #map16(%arg4)
            %112 = affine.load %8[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
            affine.store %112, %7[%arg1, %arg2, %110, %111] : memref<1x512x9x9xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 7 {
          affine.for %arg4 = 0 to 7 {
            affine.store %cst_1, %6[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
            affine.for %arg5 = 0 to 512 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %113 = affine.apply #map17(%arg3, %arg6)
                  %114 = affine.apply #map17(%arg4, %arg7)
                  %115 = affine.load %7[%arg1, %arg5, %113, %114] : memref<1x512x9x9xf32>
                  %116 = affine.load %105[%arg2, %arg5, %arg6, %arg7] : memref<512x512x3x3xf32>
                  %117 = affine.load %6[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
                  %118 = mulf %115, %116 : f32
                  %119 = addf %117, %118 : f32
                  affine.store %119, %6[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
                }
              }
            }
            %110 = affine.load %6[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
            %111 = affine.load %106[%arg2] : memref<512xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %6[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 7 {
          affine.for %arg4 = 0 to 7 {
            %110 = affine.load %11[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
            %111 = affine.load %6[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
            %112 = addf %110, %111 : f32
            affine.store %112, %5[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 7 {
          affine.for %arg4 = 0 to 7 {
            %110 = affine.load %5[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
            %111 = cmpf "olt", %110, %cst_1 : f32
            %112 = select %111, %cst_1, %110 : f32
            affine.store %112, %4[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 1 {
          affine.for %arg4 = 0 to 1 {
            affine.store %cst_1, %3[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 7 {
          affine.for %arg4 = 0 to 7 {
            %110 = affine.load %4[%arg1, %arg2, %arg3, %arg4] : memref<1x512x7x7xf32>
            %111 = affine.load %3[%arg1, %arg2, %c0, %c0] : memref<1x512x1x1xf32>
            %112 = addf %111, %110 : f32
            affine.store %112, %3[%arg1, %arg2, %c0, %c0] : memref<1x512x1x1xf32>
          }
        }
      }
    }
    %107 = uitofp %c49_i64 : i64 to f32
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 1 {
          affine.for %arg4 = 0 to 1 {
            %110 = affine.load %3[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
            %111 = divf %110, %107 : f32
            affine.store %111, %3[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 1 {
          affine.for %arg4 = 0 to 1 {
            %110 = affine.load %3[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
            %111 = affine.apply #map26(%arg2, %arg3, %arg4)[%c512, %c1, %c1]
            affine.store %110, %2[%arg1, %111] : memref<1x512xf32>
          }
        }
      }
    }
    %108 = "krnl.global"() {name = "constant_40", offset = 44686848 : i64, shape = [1000, 512]} : () -> memref<1000x512xf32>
    %109 = "krnl.global"() {name = "constant_41", offset = 46734848 : i64, shape = [1000]} : () -> memref<1000xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 1000 {
        affine.store %cst_1, %1[%arg1, %arg2] : memref<1x1000xf32>
        affine.for %arg3 = 0 to 512 {
          %115 = affine.load %2[%arg1, %arg3] : memref<1x512xf32>
          %116 = affine.load %108[%arg2, %arg3] : memref<1000x512xf32>
          %117 = affine.load %1[%arg1, %arg2] : memref<1x1000xf32>
          %118 = mulf %115, %116 : f32
          %119 = addf %117, %118 : f32
          affine.store %119, %1[%arg1, %arg2] : memref<1x1000xf32>
        }
        %110 = affine.load %1[%arg1, %arg2] : memref<1x1000xf32>
        %111 = mulf %cst_0, %110 : f32
        %112 = affine.load %109[%arg2] : memref<1000xf32>
        %113 = mulf %cst_0, %112 : f32
        %114 = addf %111, %113 : f32
        affine.store %114, %1[%arg1, %arg2] : memref<1x1000xf32>
      }
    }
    dealloc %66 : memref<1x3x230x230xf32>
    dealloc %65 : memref<1x64x112x112xf32>
    dealloc %64 : memref<1x64x112x112xf32>
    dealloc %63 : memref<1x64x56x56xf32>
    dealloc %62 : memref<1x64x58x58xf32>
    dealloc %61 : memref<1x64x56x56xf32>
    dealloc %60 : memref<1x64x56x56xf32>
    dealloc %59 : memref<1x64x58x58xf32>
    dealloc %58 : memref<1x64x56x56xf32>
    dealloc %57 : memref<1x64x56x56xf32>
    dealloc %56 : memref<1x64x56x56xf32>
    dealloc %55 : memref<1x64x58x58xf32>
    dealloc %54 : memref<1x64x56x56xf32>
    dealloc %53 : memref<1x64x56x56xf32>
    dealloc %52 : memref<1x64x58x58xf32>
    dealloc %51 : memref<1x64x56x56xf32>
    dealloc %50 : memref<1x64x56x56xf32>
    dealloc %49 : memref<1x64x56x56xf32>
    dealloc %48 : memref<1x128x28x28xf32>
    dealloc %47 : memref<1x64x58x58xf32>
    dealloc %46 : memref<1x128x28x28xf32>
    dealloc %45 : memref<1x128x28x28xf32>
    dealloc %44 : memref<1x128x30x30xf32>
    dealloc %43 : memref<1x128x28x28xf32>
    dealloc %42 : memref<1x128x28x28xf32>
    dealloc %41 : memref<1x128x28x28xf32>
    dealloc %40 : memref<1x128x30x30xf32>
    dealloc %39 : memref<1x128x28x28xf32>
    dealloc %38 : memref<1x128x28x28xf32>
    dealloc %37 : memref<1x128x30x30xf32>
    dealloc %36 : memref<1x128x28x28xf32>
    dealloc %35 : memref<1x128x28x28xf32>
    dealloc %34 : memref<1x128x28x28xf32>
    dealloc %33 : memref<1x256x14x14xf32>
    dealloc %32 : memref<1x128x30x30xf32>
    dealloc %31 : memref<1x256x14x14xf32>
    dealloc %30 : memref<1x256x14x14xf32>
    dealloc %29 : memref<1x256x16x16xf32>
    dealloc %28 : memref<1x256x14x14xf32>
    dealloc %27 : memref<1x256x14x14xf32>
    dealloc %26 : memref<1x256x14x14xf32>
    dealloc %25 : memref<1x256x16x16xf32>
    dealloc %24 : memref<1x256x14x14xf32>
    dealloc %23 : memref<1x256x14x14xf32>
    dealloc %22 : memref<1x256x16x16xf32>
    dealloc %21 : memref<1x256x14x14xf32>
    dealloc %20 : memref<1x256x14x14xf32>
    dealloc %19 : memref<1x256x14x14xf32>
    dealloc %18 : memref<1x512x7x7xf32>
    dealloc %17 : memref<1x256x16x16xf32>
    dealloc %16 : memref<1x512x7x7xf32>
    dealloc %15 : memref<1x512x7x7xf32>
    dealloc %14 : memref<1x512x9x9xf32>
    dealloc %13 : memref<1x512x7x7xf32>
    dealloc %12 : memref<1x512x7x7xf32>
    dealloc %11 : memref<1x512x7x7xf32>
    dealloc %10 : memref<1x512x9x9xf32>
    dealloc %9 : memref<1x512x7x7xf32>
    dealloc %8 : memref<1x512x7x7xf32>
    dealloc %7 : memref<1x512x9x9xf32>
    dealloc %6 : memref<1x512x7x7xf32>
    dealloc %5 : memref<1x512x7x7xf32>
    dealloc %4 : memref<1x512x7x7xf32>
    dealloc %3 : memref<1x512x1x1xf32>
    dealloc %2 : memref<1x512xf32>
    return %1 : memref<1x1000xf32>
  }
  "krnl.entry_point"() {func = @main_graph, numInputs = 1 : i32, numOutputs = 1 : i32} : () -> ()
}
