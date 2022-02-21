#map0 = affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>
#map1 = affine_map<() -> (0)>
#map2 = affine_map<() -> (34)>
#map3 = affine_map<() -> (3)>
#map4 = affine_map<() -> (1)>
#map5 = affine_map<(d0) -> (d0 + 1)>
#map6 = affine_map<() -> (32)>
#map7 = affine_map<(d0, d1) -> (d0 + d1)>
#map8 = affine_map<(d0, d1)[s0] -> (d0 * s0 + d1)>
#map9 = affine_map<() -> (64)>
#map10 = affine_map<(d0, d1) -> (d0 * 2 + d1)>
#map11 = affine_map<() -> (16)>
#map12 = affine_map<() -> (128)>
#map13 = affine_map<() -> (18)>
#map14 = affine_map<() -> (8)>
#map15 = affine_map<() -> (256)>
#map16 = affine_map<() -> (10)>
#map17 = affine_map<() -> (4)>
#map18 = affine_map<() -> (512)>
#map19 = affine_map<() -> (6)>
#map20 = affine_map<() -> (2)>
#map21 = affine_map<() -> (1024)>
#map22 = affine_map<(d0, d1, d2)[s0, s1, s2] -> (d2 + d1 * s2 + d0 * (s1 * s2))>
#map23 = affine_map<(d0, d1) -> (d0, d1)>
#map24 = affine_map<(d0) -> (d0)>
module {
  %0 = "krnl.packed_const"() {file_name = "/tmp/packed_const-0f2051.tmp", is_le = true, size_in_bytes = 12781312 : i64} : () -> i64
  func @main_graph(%arg0: memref<1x3x32x32xf32>) -> memref<1x10xf32> attributes {input_names = ["input.1"], output_names = ["86"]} {
    %c0 = arith.constant 0 : index
    %c4_i64 = arith.constant 4 : i64
    %c1024 = arith.constant 1024 : index
    %c1 = arith.constant 1 : index
    %cst = arith.constant 1.000000e+00 : f32
    %cst_0 = arith.constant 0.000000e+00 : f32
    %1 = memref.alloc() : memref<1x10xf32>
    %2 = memref.alloc() : memref<1x1024xf32>
    %3 = memref.alloc() : memref<1x1024x1x1xf32>
    %4 = memref.alloc() : memref<1x1024x2x2xf32>
    %5 = memref.alloc() : memref<1x1024x2x2xf32>
    %6 = memref.alloc() : memref<1x1024x2x2xf32>
    %7 = memref.alloc() : memref<1x1024x2x2xf32>
    %8 = memref.alloc() : memref<1x1024x4x4xf32>
    %9 = memref.alloc() : memref<1x1024x2x2xf32>
    %10 = memref.alloc() : memref<1x1024x2x2xf32>
    %11 = memref.alloc() : memref<1x512x2x2xf32>
    %12 = memref.alloc() : memref<1x512x2x2xf32>
    %13 = memref.alloc() : memref<1x512x6x6xf32>
    %14 = memref.alloc() : memref<1x512x4x4xf32>
    %15 = memref.alloc() : memref<1x512x4x4xf32>
    %16 = memref.alloc() : memref<1x512x4x4xf32>
    %17 = memref.alloc() : memref<1x512x4x4xf32>
    %18 = memref.alloc() : memref<1x512x6x6xf32>
    %19 = memref.alloc() : memref<1x512x4x4xf32>
    %20 = memref.alloc() : memref<1x512x4x4xf32>
    %21 = memref.alloc() : memref<1x512x4x4xf32>
    %22 = memref.alloc() : memref<1x512x4x4xf32>
    %23 = memref.alloc() : memref<1x512x6x6xf32>
    %24 = memref.alloc() : memref<1x512x4x4xf32>
    %25 = memref.alloc() : memref<1x512x4x4xf32>
    %26 = memref.alloc() : memref<1x512x4x4xf32>
    %27 = memref.alloc() : memref<1x512x4x4xf32>
    %28 = memref.alloc() : memref<1x512x6x6xf32>
    %29 = memref.alloc() : memref<1x512x4x4xf32>
    %30 = memref.alloc() : memref<1x512x4x4xf32>
    %31 = memref.alloc() : memref<1x512x4x4xf32>
    %32 = memref.alloc() : memref<1x512x4x4xf32>
    %33 = memref.alloc() : memref<1x512x6x6xf32>
    %34 = memref.alloc() : memref<1x512x4x4xf32>
    %35 = memref.alloc() : memref<1x512x4x4xf32>
    %36 = memref.alloc() : memref<1x512x4x4xf32>
    %37 = memref.alloc() : memref<1x512x4x4xf32>
    %38 = memref.alloc() : memref<1x512x6x6xf32>
    %39 = memref.alloc() : memref<1x512x4x4xf32>
    %40 = memref.alloc() : memref<1x512x4x4xf32>
    %41 = memref.alloc() : memref<1x256x4x4xf32>
    %42 = memref.alloc() : memref<1x256x4x4xf32>
    %43 = memref.alloc() : memref<1x256x10x10xf32>
    %44 = memref.alloc() : memref<1x256x8x8xf32>
    %45 = memref.alloc() : memref<1x256x8x8xf32>
    %46 = memref.alloc() : memref<1x256x8x8xf32>
    %47 = memref.alloc() : memref<1x256x8x8xf32>
    %48 = memref.alloc() : memref<1x256x10x10xf32>
    %49 = memref.alloc() : memref<1x256x8x8xf32>
    %50 = memref.alloc() : memref<1x256x8x8xf32>
    %51 = memref.alloc() : memref<1x128x8x8xf32>
    %52 = memref.alloc() : memref<1x128x8x8xf32>
    %53 = memref.alloc() : memref<1x128x18x18xf32>
    %54 = memref.alloc() : memref<1x128x16x16xf32>
    %55 = memref.alloc() : memref<1x128x16x16xf32>
    %56 = memref.alloc() : memref<1x128x16x16xf32>
    %57 = memref.alloc() : memref<1x128x16x16xf32>
    %58 = memref.alloc() : memref<1x128x18x18xf32>
    %59 = memref.alloc() : memref<1x128x16x16xf32>
    %60 = memref.alloc() : memref<1x128x16x16xf32>
    %61 = memref.alloc() : memref<1x64x16x16xf32>
    %62 = memref.alloc() : memref<1x64x16x16xf32>
    %63 = memref.alloc() : memref<1x64x34x34xf32>
    %64 = memref.alloc() : memref<1x64x32x32xf32>
    %65 = memref.alloc() : memref<1x64x32x32xf32>
    %66 = memref.alloc() : memref<1x32x32x32xf32>
    %67 = memref.alloc() : memref<1x32x32x32xf32>
    %68 = memref.alloc() : memref<1x32x34x34xf32>
    %69 = memref.alloc() : memref<1x32x32x32xf32>
    %70 = memref.alloc() : memref<1x32x32x32xf32>
    %71 = memref.alloc() : memref<1x3x34x34xf32>
    %72 = "krnl.global"() {name = "arith.constant_0", offset = 0 : i64, shape = [32, 3, 3, 3]} : () -> memref<32x3x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 3 {
        affine.for %arg3 = 0 to 34 {
          affine.for %arg4 = 0 to 34 {
            affine.store %cst_0, %71[%arg1, %arg2, %arg3, %arg4] : memref<1x3x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 3 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %102 = affine.apply #map5(%arg3)
            %103 = affine.apply #map5(%arg4)
            %104 = affine.load %arg0[%arg1, %arg2, %arg3, %arg4] : memref<1x3x32x32xf32>
            affine.store %104, %71[%arg1, %arg2, %102, %103] : memref<1x3x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 32 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            affine.store %cst_0, %70[%arg1, %arg2, %arg3, %arg4] : memref<1x32x32x32xf32>
            affine.for %arg5 = 0 to 3 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %102 = affine.apply #map7(%arg3, %arg6)
                  %103 = affine.apply #map7(%arg4, %arg7)
                  %104 = affine.load %71[%arg1, %arg5, %102, %103] : memref<1x3x34x34xf32>
                  %105 = affine.load %72[%arg2, %arg5, %arg6, %arg7] : memref<32x3x3x3xf32>
                  %106 = affine.load %70[%arg1, %arg2, %arg3, %arg4] : memref<1x32x32x32xf32>
                  %107 = arith.mulf %104, %105 : f32
                  %108 = arith.addf %106, %107 : f32
                  affine.store %108, %70[%arg1, %arg2, %arg3, %arg4] : memref<1x32x32x32xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 32 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %102 = affine.load %70[%arg1, %arg2, %arg3, %arg4] : memref<1x32x32x32xf32>
            %103 = arith.cmpf "olt", %102, %cst_0 : f32
            %104 = select %103, %cst_0, %102 : f32
            affine.store %104, %69[%arg1, %arg2, %arg3, %arg4] : memref<1x32x32x32xf32>
          }
        }
      }
    }
    %73 = "krnl.global"() {name = "arith.constant_1", offset = 3456 : i64, shape = [32, 1, 3, 3]} : () -> memref<32x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 32 {
        affine.for %arg3 = 0 to 34 {
          affine.for %arg4 = 0 to 34 {
            affine.store %cst_0, %68[%arg1, %arg2, %arg3, %arg4] : memref<1x32x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 32 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %102 = affine.apply #map5(%arg3)
            %103 = affine.apply #map5(%arg4)
            %104 = affine.load %69[%arg1, %arg2, %arg3, %arg4] : memref<1x32x32x32xf32>
            affine.store %104, %68[%arg1, %arg2, %102, %103] : memref<1x32x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 32 {
        affine.for %arg3 = 0 to 1 {
          %102 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 32 {
            affine.for %arg5 = 0 to 32 {
              affine.store %cst_0, %67[%arg1, %102, %arg4, %arg5] : memref<1x32x32x32xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %103 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %104 = affine.apply #map7(%arg4, %arg7)
                    %105 = affine.apply #map7(%arg5, %arg8)
                    %106 = affine.load %68[%arg1, %103, %104, %105] : memref<1x32x34x34xf32>
                    %107 = affine.load %73[%102, %arg6, %arg7, %arg8] : memref<32x1x3x3xf32>
                    %108 = affine.load %67[%arg1, %102, %arg4, %arg5] : memref<1x32x32x32xf32>
                    %109 = arith.mulf %106, %107 : f32
                    %110 = arith.addf %108, %109 : f32
                    affine.store %110, %67[%arg1, %102, %arg4, %arg5] : memref<1x32x32x32xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 32 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %102 = affine.load %67[%arg1, %arg2, %arg3, %arg4] : memref<1x32x32x32xf32>
            %103 = arith.cmpf "olt", %102, %cst_0 : f32
            %104 = select %103, %cst_0, %102 : f32
            affine.store %104, %66[%arg1, %arg2, %arg3, %arg4] : memref<1x32x32x32xf32>
          }
        }
      }
    }
    %74 = "krnl.global"() {name = "arith.constant_2", offset = 4608 : i64, shape = [64, 32, 1, 1]} : () -> memref<64x32x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            affine.store %cst_0, %65[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            affine.for %arg5 = 0 to 32 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %102 = affine.apply #map7(%arg3, %arg6)
                  %103 = affine.apply #map7(%arg4, %arg7)
                  %104 = affine.load %66[%arg1, %arg5, %102, %103] : memref<1x32x32x32xf32>
                  %105 = affine.load %74[%arg2, %arg5, %arg6, %arg7] : memref<64x32x1x1xf32>
                  %106 = affine.load %65[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
                  %107 = arith.mulf %104, %105 : f32
                  %108 = arith.addf %106, %107 : f32
                  affine.store %108, %65[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %102 = affine.load %65[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            %103 = arith.cmpf "olt", %102, %cst_0 : f32
            %104 = select %103, %cst_0, %102 : f32
            affine.store %104, %64[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
          }
        }
      }
    }
    %75 = "krnl.global"() {name = "arith.constant_3", offset = 12800 : i64, shape = [64, 1, 3, 3]} : () -> memref<64x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 34 {
          affine.for %arg4 = 0 to 34 {
            affine.store %cst_0, %63[%arg1, %arg2, %arg3, %arg4] : memref<1x64x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %102 = affine.apply #map5(%arg3)
            %103 = affine.apply #map5(%arg4)
            %104 = affine.load %64[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            affine.store %104, %63[%arg1, %arg2, %102, %103] : memref<1x64x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 1 {
          %102 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 16 {
            affine.for %arg5 = 0 to 16 {
              affine.store %cst_0, %62[%arg1, %102, %arg4, %arg5] : memref<1x64x16x16xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %103 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %104 = affine.apply #map10(%arg4, %arg7)
                    %105 = affine.apply #map10(%arg5, %arg8)
                    %106 = affine.load %63[%arg1, %103, %104, %105] : memref<1x64x34x34xf32>
                    %107 = affine.load %75[%102, %arg6, %arg7, %arg8] : memref<64x1x3x3xf32>
                    %108 = affine.load %62[%arg1, %102, %arg4, %arg5] : memref<1x64x16x16xf32>
                    %109 = arith.mulf %106, %107 : f32
                    %110 = arith.addf %108, %109 : f32
                    affine.store %110, %62[%arg1, %102, %arg4, %arg5] : memref<1x64x16x16xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %102 = affine.load %62[%arg1, %arg2, %arg3, %arg4] : memref<1x64x16x16xf32>
            %103 = arith.cmpf "olt", %102, %cst_0 : f32
            %104 = select %103, %cst_0, %102 : f32
            affine.store %104, %61[%arg1, %arg2, %arg3, %arg4] : memref<1x64x16x16xf32>
          }
        }
      }
    }
    %76 = "krnl.global"() {name = "arith.constant_4", offset = 15104 : i64, shape = [128, 64, 1, 1]} : () -> memref<128x64x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            affine.store %cst_0, %60[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            affine.for %arg5 = 0 to 64 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %102 = affine.apply #map7(%arg3, %arg6)
                  %103 = affine.apply #map7(%arg4, %arg7)
                  %104 = affine.load %61[%arg1, %arg5, %102, %103] : memref<1x64x16x16xf32>
                  %105 = affine.load %76[%arg2, %arg5, %arg6, %arg7] : memref<128x64x1x1xf32>
                  %106 = affine.load %60[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
                  %107 = arith.mulf %104, %105 : f32
                  %108 = arith.addf %106, %107 : f32
                  affine.store %108, %60[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %102 = affine.load %60[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            %103 = arith.cmpf "olt", %102, %cst_0 : f32
            %104 = select %103, %cst_0, %102 : f32
            affine.store %104, %59[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
          }
        }
      }
    }
    %77 = "krnl.global"() {name = "arith.constant_5", offset = 47872 : i64, shape = [128, 1, 3, 3]} : () -> memref<128x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 18 {
          affine.for %arg4 = 0 to 18 {
            affine.store %cst_0, %58[%arg1, %arg2, %arg3, %arg4] : memref<1x128x18x18xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %102 = affine.apply #map5(%arg3)
            %103 = affine.apply #map5(%arg4)
            %104 = affine.load %59[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            affine.store %104, %58[%arg1, %arg2, %102, %103] : memref<1x128x18x18xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 1 {
          %102 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 16 {
            affine.for %arg5 = 0 to 16 {
              affine.store %cst_0, %57[%arg1, %102, %arg4, %arg5] : memref<1x128x16x16xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %103 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %104 = affine.apply #map7(%arg4, %arg7)
                    %105 = affine.apply #map7(%arg5, %arg8)
                    %106 = affine.load %58[%arg1, %103, %104, %105] : memref<1x128x18x18xf32>
                    %107 = affine.load %77[%102, %arg6, %arg7, %arg8] : memref<128x1x3x3xf32>
                    %108 = affine.load %57[%arg1, %102, %arg4, %arg5] : memref<1x128x16x16xf32>
                    %109 = arith.mulf %106, %107 : f32
                    %110 = arith.addf %108, %109 : f32
                    affine.store %110, %57[%arg1, %102, %arg4, %arg5] : memref<1x128x16x16xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %102 = affine.load %57[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            %103 = arith.cmpf "olt", %102, %cst_0 : f32
            %104 = select %103, %cst_0, %102 : f32
            affine.store %104, %56[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
          }
        }
      }
    }
    %78 = "krnl.global"() {name = "arith.constant_6", offset = 52480 : i64, shape = [128, 128, 1, 1]} : () -> memref<128x128x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            affine.store %cst_0, %55[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            affine.for %arg5 = 0 to 128 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %102 = affine.apply #map7(%arg3, %arg6)
                  %103 = affine.apply #map7(%arg4, %arg7)
                  %104 = affine.load %56[%arg1, %arg5, %102, %103] : memref<1x128x16x16xf32>
                  %105 = affine.load %78[%arg2, %arg5, %arg6, %arg7] : memref<128x128x1x1xf32>
                  %106 = affine.load %55[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
                  %107 = arith.mulf %104, %105 : f32
                  %108 = arith.addf %106, %107 : f32
                  affine.store %108, %55[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %102 = affine.load %55[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            %103 = arith.cmpf "olt", %102, %cst_0 : f32
            %104 = select %103, %cst_0, %102 : f32
            affine.store %104, %54[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
          }
        }
      }
    }
    %79 = "krnl.global"() {name = "arith.constant_7", offset = 118016 : i64, shape = [128, 1, 3, 3]} : () -> memref<128x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 18 {
          affine.for %arg4 = 0 to 18 {
            affine.store %cst_0, %53[%arg1, %arg2, %arg3, %arg4] : memref<1x128x18x18xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %102 = affine.apply #map5(%arg3)
            %103 = affine.apply #map5(%arg4)
            %104 = affine.load %54[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            affine.store %104, %53[%arg1, %arg2, %102, %103] : memref<1x128x18x18xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 1 {
          %102 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 8 {
            affine.for %arg5 = 0 to 8 {
              affine.store %cst_0, %52[%arg1, %102, %arg4, %arg5] : memref<1x128x8x8xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %103 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %104 = affine.apply #map10(%arg4, %arg7)
                    %105 = affine.apply #map10(%arg5, %arg8)
                    %106 = affine.load %53[%arg1, %103, %104, %105] : memref<1x128x18x18xf32>
                    %107 = affine.load %79[%102, %arg6, %arg7, %arg8] : memref<128x1x3x3xf32>
                    %108 = affine.load %52[%arg1, %102, %arg4, %arg5] : memref<1x128x8x8xf32>
                    %109 = arith.mulf %106, %107 : f32
                    %110 = arith.addf %108, %109 : f32
                    affine.store %110, %52[%arg1, %102, %arg4, %arg5] : memref<1x128x8x8xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %102 = affine.load %52[%arg1, %arg2, %arg3, %arg4] : memref<1x128x8x8xf32>
            %103 = arith.cmpf "olt", %102, %cst_0 : f32
            %104 = select %103, %cst_0, %102 : f32
            affine.store %104, %51[%arg1, %arg2, %arg3, %arg4] : memref<1x128x8x8xf32>
          }
        }
      }
    }
    %80 = "krnl.global"() {name = "arith.constant_8", offset = 122624 : i64, shape = [256, 128, 1, 1]} : () -> memref<256x128x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_0, %50[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            affine.for %arg5 = 0 to 128 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %102 = affine.apply #map7(%arg3, %arg6)
                  %103 = affine.apply #map7(%arg4, %arg7)
                  %104 = affine.load %51[%arg1, %arg5, %102, %103] : memref<1x128x8x8xf32>
                  %105 = affine.load %80[%arg2, %arg5, %arg6, %arg7] : memref<256x128x1x1xf32>
                  %106 = affine.load %50[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
                  %107 = arith.mulf %104, %105 : f32
                  %108 = arith.addf %106, %107 : f32
                  affine.store %108, %50[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %102 = affine.load %50[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            %103 = arith.cmpf "olt", %102, %cst_0 : f32
            %104 = select %103, %cst_0, %102 : f32
            affine.store %104, %49[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
          }
        }
      }
    }
    %81 = "krnl.global"() {name = "arith.constant_9", offset = 253696 : i64, shape = [256, 1, 3, 3]} : () -> memref<256x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 10 {
          affine.for %arg4 = 0 to 10 {
            affine.store %cst_0, %48[%arg1, %arg2, %arg3, %arg4] : memref<1x256x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %102 = affine.apply #map5(%arg3)
            %103 = affine.apply #map5(%arg4)
            %104 = affine.load %49[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            affine.store %104, %48[%arg1, %arg2, %102, %103] : memref<1x256x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 1 {
          %102 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 8 {
            affine.for %arg5 = 0 to 8 {
              affine.store %cst_0, %47[%arg1, %102, %arg4, %arg5] : memref<1x256x8x8xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %103 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %104 = affine.apply #map7(%arg4, %arg7)
                    %105 = affine.apply #map7(%arg5, %arg8)
                    %106 = affine.load %48[%arg1, %103, %104, %105] : memref<1x256x10x10xf32>
                    %107 = affine.load %81[%102, %arg6, %arg7, %arg8] : memref<256x1x3x3xf32>
                    %108 = affine.load %47[%arg1, %102, %arg4, %arg5] : memref<1x256x8x8xf32>
                    %109 = arith.mulf %106, %107 : f32
                    %110 = arith.addf %108, %109 : f32
                    affine.store %110, %47[%arg1, %102, %arg4, %arg5] : memref<1x256x8x8xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %102 = affine.load %47[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            %103 = arith.cmpf "olt", %102, %cst_0 : f32
            %104 = select %103, %cst_0, %102 : f32
            affine.store %104, %46[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
          }
        }
      }
    }
    %82 = "krnl.global"() {name = "arith.constant_10", offset = 262912 : i64, shape = [256, 256, 1, 1]} : () -> memref<256x256x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_0, %45[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            affine.for %arg5 = 0 to 256 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %102 = affine.apply #map7(%arg3, %arg6)
                  %103 = affine.apply #map7(%arg4, %arg7)
                  %104 = affine.load %46[%arg1, %arg5, %102, %103] : memref<1x256x8x8xf32>
                  %105 = affine.load %82[%arg2, %arg5, %arg6, %arg7] : memref<256x256x1x1xf32>
                  %106 = affine.load %45[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
                  %107 = arith.mulf %104, %105 : f32
                  %108 = arith.addf %106, %107 : f32
                  affine.store %108, %45[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %102 = affine.load %45[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            %103 = arith.cmpf "olt", %102, %cst_0 : f32
            %104 = select %103, %cst_0, %102 : f32
            affine.store %104, %44[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
          }
        }
      }
    }
    %83 = "krnl.global"() {name = "arith.constant_11", offset = 525056 : i64, shape = [256, 1, 3, 3]} : () -> memref<256x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 10 {
          affine.for %arg4 = 0 to 10 {
            affine.store %cst_0, %43[%arg1, %arg2, %arg3, %arg4] : memref<1x256x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %102 = affine.apply #map5(%arg3)
            %103 = affine.apply #map5(%arg4)
            %104 = affine.load %44[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            affine.store %104, %43[%arg1, %arg2, %102, %103] : memref<1x256x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 1 {
          %102 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 4 {
            affine.for %arg5 = 0 to 4 {
              affine.store %cst_0, %42[%arg1, %102, %arg4, %arg5] : memref<1x256x4x4xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %103 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %104 = affine.apply #map10(%arg4, %arg7)
                    %105 = affine.apply #map10(%arg5, %arg8)
                    %106 = affine.load %43[%arg1, %103, %104, %105] : memref<1x256x10x10xf32>
                    %107 = affine.load %83[%102, %arg6, %arg7, %arg8] : memref<256x1x3x3xf32>
                    %108 = affine.load %42[%arg1, %102, %arg4, %arg5] : memref<1x256x4x4xf32>
                    %109 = arith.mulf %106, %107 : f32
                    %110 = arith.addf %108, %109 : f32
                    affine.store %110, %42[%arg1, %102, %arg4, %arg5] : memref<1x256x4x4xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %102 = affine.load %42[%arg1, %arg2, %arg3, %arg4] : memref<1x256x4x4xf32>
            %103 = arith.cmpf "olt", %102, %cst_0 : f32
            %104 = select %103, %cst_0, %102 : f32
            affine.store %104, %41[%arg1, %arg2, %arg3, %arg4] : memref<1x256x4x4xf32>
          }
        }
      }
    }
    %84 = "krnl.global"() {name = "arith.constant_12", offset = 534272 : i64, shape = [512, 256, 1, 1]} : () -> memref<512x256x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_0, %40[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.for %arg5 = 0 to 256 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %102 = affine.apply #map7(%arg3, %arg6)
                  %103 = affine.apply #map7(%arg4, %arg7)
                  %104 = affine.load %41[%arg1, %arg5, %102, %103] : memref<1x256x4x4xf32>
                  %105 = affine.load %84[%arg2, %arg5, %arg6, %arg7] : memref<512x256x1x1xf32>
                  %106 = affine.load %40[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                  %107 = arith.mulf %104, %105 : f32
                  %108 = arith.addf %106, %107 : f32
                  affine.store %108, %40[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %102 = affine.load %40[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %103 = arith.cmpf "olt", %102, %cst_0 : f32
            %104 = select %103, %cst_0, %102 : f32
            affine.store %104, %39[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    %85 = "krnl.global"() {name = "arith.constant_13", offset = 1058560 : i64, shape = [512, 1, 3, 3]} : () -> memref<512x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 6 {
          affine.for %arg4 = 0 to 6 {
            affine.store %cst_0, %38[%arg1, %arg2, %arg3, %arg4] : memref<1x512x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %102 = affine.apply #map5(%arg3)
            %103 = affine.apply #map5(%arg4)
            %104 = affine.load %39[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.store %104, %38[%arg1, %arg2, %102, %103] : memref<1x512x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 1 {
          %102 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 4 {
            affine.for %arg5 = 0 to 4 {
              affine.store %cst_0, %37[%arg1, %102, %arg4, %arg5] : memref<1x512x4x4xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %103 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %104 = affine.apply #map7(%arg4, %arg7)
                    %105 = affine.apply #map7(%arg5, %arg8)
                    %106 = affine.load %38[%arg1, %103, %104, %105] : memref<1x512x6x6xf32>
                    %107 = affine.load %85[%102, %arg6, %arg7, %arg8] : memref<512x1x3x3xf32>
                    %108 = affine.load %37[%arg1, %102, %arg4, %arg5] : memref<1x512x4x4xf32>
                    %109 = arith.mulf %106, %107 : f32
                    %110 = arith.addf %108, %109 : f32
                    affine.store %110, %37[%arg1, %102, %arg4, %arg5] : memref<1x512x4x4xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %102 = affine.load %37[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %103 = arith.cmpf "olt", %102, %cst_0 : f32
            %104 = select %103, %cst_0, %102 : f32
            affine.store %104, %36[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    %86 = "krnl.global"() {name = "arith.constant_14", offset = 1076992 : i64, shape = [512, 512, 1, 1]} : () -> memref<512x512x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_0, %35[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.for %arg5 = 0 to 512 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %102 = affine.apply #map7(%arg3, %arg6)
                  %103 = affine.apply #map7(%arg4, %arg7)
                  %104 = affine.load %36[%arg1, %arg5, %102, %103] : memref<1x512x4x4xf32>
                  %105 = affine.load %86[%arg2, %arg5, %arg6, %arg7] : memref<512x512x1x1xf32>
                  %106 = affine.load %35[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                  %107 = arith.mulf %104, %105 : f32
                  %108 = arith.addf %106, %107 : f32
                  affine.store %108, %35[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %102 = affine.load %35[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %103 = arith.cmpf "olt", %102, %cst_0 : f32
            %104 = select %103, %cst_0, %102 : f32
            affine.store %104, %34[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    %87 = "krnl.global"() {name = "arith.constant_15", offset = 2125568 : i64, shape = [512, 1, 3, 3]} : () -> memref<512x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 6 {
          affine.for %arg4 = 0 to 6 {
            affine.store %cst_0, %33[%arg1, %arg2, %arg3, %arg4] : memref<1x512x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %102 = affine.apply #map5(%arg3)
            %103 = affine.apply #map5(%arg4)
            %104 = affine.load %34[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.store %104, %33[%arg1, %arg2, %102, %103] : memref<1x512x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 1 {
          %102 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 4 {
            affine.for %arg5 = 0 to 4 {
              affine.store %cst_0, %32[%arg1, %102, %arg4, %arg5] : memref<1x512x4x4xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %103 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %104 = affine.apply #map7(%arg4, %arg7)
                    %105 = affine.apply #map7(%arg5, %arg8)
                    %106 = affine.load %33[%arg1, %103, %104, %105] : memref<1x512x6x6xf32>
                    %107 = affine.load %87[%102, %arg6, %arg7, %arg8] : memref<512x1x3x3xf32>
                    %108 = affine.load %32[%arg1, %102, %arg4, %arg5] : memref<1x512x4x4xf32>
                    %109 = arith.mulf %106, %107 : f32
                    %110 = arith.addf %108, %109 : f32
                    affine.store %110, %32[%arg1, %102, %arg4, %arg5] : memref<1x512x4x4xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %102 = affine.load %32[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %103 = arith.cmpf "olt", %102, %cst_0 : f32
            %104 = select %103, %cst_0, %102 : f32
            affine.store %104, %31[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    %88 = "krnl.global"() {name = "arith.constant_16", offset = 2144000 : i64, shape = [512, 512, 1, 1]} : () -> memref<512x512x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_0, %30[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.for %arg5 = 0 to 512 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %102 = affine.apply #map7(%arg3, %arg6)
                  %103 = affine.apply #map7(%arg4, %arg7)
                  %104 = affine.load %31[%arg1, %arg5, %102, %103] : memref<1x512x4x4xf32>
                  %105 = affine.load %88[%arg2, %arg5, %arg6, %arg7] : memref<512x512x1x1xf32>
                  %106 = affine.load %30[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                  %107 = arith.mulf %104, %105 : f32
                  %108 = arith.addf %106, %107 : f32
                  affine.store %108, %30[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %102 = affine.load %30[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %103 = arith.cmpf "olt", %102, %cst_0 : f32
            %104 = select %103, %cst_0, %102 : f32
            affine.store %104, %29[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    %89 = "krnl.global"() {name = "arith.constant_17", offset = 3192576 : i64, shape = [512, 1, 3, 3]} : () -> memref<512x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 6 {
          affine.for %arg4 = 0 to 6 {
            affine.store %cst_0, %28[%arg1, %arg2, %arg3, %arg4] : memref<1x512x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %102 = affine.apply #map5(%arg3)
            %103 = affine.apply #map5(%arg4)
            %104 = affine.load %29[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.store %104, %28[%arg1, %arg2, %102, %103] : memref<1x512x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 1 {
          %102 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 4 {
            affine.for %arg5 = 0 to 4 {
              affine.store %cst_0, %27[%arg1, %102, %arg4, %arg5] : memref<1x512x4x4xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %103 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %104 = affine.apply #map7(%arg4, %arg7)
                    %105 = affine.apply #map7(%arg5, %arg8)
                    %106 = affine.load %28[%arg1, %103, %104, %105] : memref<1x512x6x6xf32>
                    %107 = affine.load %89[%102, %arg6, %arg7, %arg8] : memref<512x1x3x3xf32>
                    %108 = affine.load %27[%arg1, %102, %arg4, %arg5] : memref<1x512x4x4xf32>
                    %109 = arith.mulf %106, %107 : f32
                    %110 = arith.addf %108, %109 : f32
                    affine.store %110, %27[%arg1, %102, %arg4, %arg5] : memref<1x512x4x4xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %102 = affine.load %27[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %103 = arith.cmpf "olt", %102, %cst_0 : f32
            %104 = select %103, %cst_0, %102 : f32
            affine.store %104, %26[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    %90 = "krnl.global"() {name = "arith.constant_18", offset = 3211008 : i64, shape = [512, 512, 1, 1]} : () -> memref<512x512x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_0, %25[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.for %arg5 = 0 to 512 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %102 = affine.apply #map7(%arg3, %arg6)
                  %103 = affine.apply #map7(%arg4, %arg7)
                  %104 = affine.load %26[%arg1, %arg5, %102, %103] : memref<1x512x4x4xf32>
                  %105 = affine.load %90[%arg2, %arg5, %arg6, %arg7] : memref<512x512x1x1xf32>
                  %106 = affine.load %25[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                  %107 = arith.mulf %104, %105 : f32
                  %108 = arith.addf %106, %107 : f32
                  affine.store %108, %25[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %102 = affine.load %25[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %103 = arith.cmpf "olt", %102, %cst_0 : f32
            %104 = select %103, %cst_0, %102 : f32
            affine.store %104, %24[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    %91 = "krnl.global"() {name = "arith.constant_19", offset = 4259584 : i64, shape = [512, 1, 3, 3]} : () -> memref<512x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 6 {
          affine.for %arg4 = 0 to 6 {
            affine.store %cst_0, %23[%arg1, %arg2, %arg3, %arg4] : memref<1x512x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %102 = affine.apply #map5(%arg3)
            %103 = affine.apply #map5(%arg4)
            %104 = affine.load %24[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.store %104, %23[%arg1, %arg2, %102, %103] : memref<1x512x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 1 {
          %102 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 4 {
            affine.for %arg5 = 0 to 4 {
              affine.store %cst_0, %22[%arg1, %102, %arg4, %arg5] : memref<1x512x4x4xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %103 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %104 = affine.apply #map7(%arg4, %arg7)
                    %105 = affine.apply #map7(%arg5, %arg8)
                    %106 = affine.load %23[%arg1, %103, %104, %105] : memref<1x512x6x6xf32>
                    %107 = affine.load %91[%102, %arg6, %arg7, %arg8] : memref<512x1x3x3xf32>
                    %108 = affine.load %22[%arg1, %102, %arg4, %arg5] : memref<1x512x4x4xf32>
                    %109 = arith.mulf %106, %107 : f32
                    %110 = arith.addf %108, %109 : f32
                    affine.store %110, %22[%arg1, %102, %arg4, %arg5] : memref<1x512x4x4xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %102 = affine.load %22[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %103 = arith.cmpf "olt", %102, %cst_0 : f32
            %104 = select %103, %cst_0, %102 : f32
            affine.store %104, %21[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    %92 = "krnl.global"() {name = "arith.constant_20", offset = 4278016 : i64, shape = [512, 512, 1, 1]} : () -> memref<512x512x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_0, %20[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.for %arg5 = 0 to 512 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %102 = affine.apply #map7(%arg3, %arg6)
                  %103 = affine.apply #map7(%arg4, %arg7)
                  %104 = affine.load %21[%arg1, %arg5, %102, %103] : memref<1x512x4x4xf32>
                  %105 = affine.load %92[%arg2, %arg5, %arg6, %arg7] : memref<512x512x1x1xf32>
                  %106 = affine.load %20[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                  %107 = arith.mulf %104, %105 : f32
                  %108 = arith.addf %106, %107 : f32
                  affine.store %108, %20[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %102 = affine.load %20[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %103 = arith.cmpf "olt", %102, %cst_0 : f32
            %104 = select %103, %cst_0, %102 : f32
            affine.store %104, %19[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    %93 = "krnl.global"() {name = "arith.constant_21", offset = 5326592 : i64, shape = [512, 1, 3, 3]} : () -> memref<512x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 6 {
          affine.for %arg4 = 0 to 6 {
            affine.store %cst_0, %18[%arg1, %arg2, %arg3, %arg4] : memref<1x512x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %102 = affine.apply #map5(%arg3)
            %103 = affine.apply #map5(%arg4)
            %104 = affine.load %19[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.store %104, %18[%arg1, %arg2, %102, %103] : memref<1x512x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 1 {
          %102 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 4 {
            affine.for %arg5 = 0 to 4 {
              affine.store %cst_0, %17[%arg1, %102, %arg4, %arg5] : memref<1x512x4x4xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %103 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %104 = affine.apply #map7(%arg4, %arg7)
                    %105 = affine.apply #map7(%arg5, %arg8)
                    %106 = affine.load %18[%arg1, %103, %104, %105] : memref<1x512x6x6xf32>
                    %107 = affine.load %93[%102, %arg6, %arg7, %arg8] : memref<512x1x3x3xf32>
                    %108 = affine.load %17[%arg1, %102, %arg4, %arg5] : memref<1x512x4x4xf32>
                    %109 = arith.mulf %106, %107 : f32
                    %110 = arith.addf %108, %109 : f32
                    affine.store %110, %17[%arg1, %102, %arg4, %arg5] : memref<1x512x4x4xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %102 = affine.load %17[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %103 = arith.cmpf "olt", %102, %cst_0 : f32
            %104 = select %103, %cst_0, %102 : f32
            affine.store %104, %16[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    %94 = "krnl.global"() {name = "arith.constant_22", offset = 5345024 : i64, shape = [512, 512, 1, 1]} : () -> memref<512x512x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_0, %15[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.for %arg5 = 0 to 512 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %102 = affine.apply #map7(%arg3, %arg6)
                  %103 = affine.apply #map7(%arg4, %arg7)
                  %104 = affine.load %16[%arg1, %arg5, %102, %103] : memref<1x512x4x4xf32>
                  %105 = affine.load %94[%arg2, %arg5, %arg6, %arg7] : memref<512x512x1x1xf32>
                  %106 = affine.load %15[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                  %107 = arith.mulf %104, %105 : f32
                  %108 = arith.addf %106, %107 : f32
                  affine.store %108, %15[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %102 = affine.load %15[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %103 = arith.cmpf "olt", %102, %cst_0 : f32
            %104 = select %103, %cst_0, %102 : f32
            affine.store %104, %14[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    %95 = "krnl.global"() {name = "arith.constant_23", offset = 6393600 : i64, shape = [512, 1, 3, 3]} : () -> memref<512x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 6 {
          affine.for %arg4 = 0 to 6 {
            affine.store %cst_0, %13[%arg1, %arg2, %arg3, %arg4] : memref<1x512x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %102 = affine.apply #map5(%arg3)
            %103 = affine.apply #map5(%arg4)
            %104 = affine.load %14[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.store %104, %13[%arg1, %arg2, %102, %103] : memref<1x512x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 1 {
          %102 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 2 {
            affine.for %arg5 = 0 to 2 {
              affine.store %cst_0, %12[%arg1, %102, %arg4, %arg5] : memref<1x512x2x2xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %103 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %104 = affine.apply #map10(%arg4, %arg7)
                    %105 = affine.apply #map10(%arg5, %arg8)
                    %106 = affine.load %13[%arg1, %103, %104, %105] : memref<1x512x6x6xf32>
                    %107 = affine.load %95[%102, %arg6, %arg7, %arg8] : memref<512x1x3x3xf32>
                    %108 = affine.load %12[%arg1, %102, %arg4, %arg5] : memref<1x512x2x2xf32>
                    %109 = arith.mulf %106, %107 : f32
                    %110 = arith.addf %108, %109 : f32
                    affine.store %110, %12[%arg1, %102, %arg4, %arg5] : memref<1x512x2x2xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            %102 = affine.load %12[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            %103 = arith.cmpf "olt", %102, %cst_0 : f32
            %104 = select %103, %cst_0, %102 : f32
            affine.store %104, %11[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
          }
        }
      }
    }
    %96 = "krnl.global"() {name = "arith.constant_24", offset = 6412032 : i64, shape = [1024, 512, 1, 1]} : () -> memref<1024x512x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 1024 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            affine.store %cst_0, %10[%arg1, %arg2, %arg3, %arg4] : memref<1x1024x2x2xf32>
            affine.for %arg5 = 0 to 512 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %102 = affine.apply #map7(%arg3, %arg6)
                  %103 = affine.apply #map7(%arg4, %arg7)
                  %104 = affine.load %11[%arg1, %arg5, %102, %103] : memref<1x512x2x2xf32>
                  %105 = affine.load %96[%arg2, %arg5, %arg6, %arg7] : memref<1024x512x1x1xf32>
                  %106 = affine.load %10[%arg1, %arg2, %arg3, %arg4] : memref<1x1024x2x2xf32>
                  %107 = arith.mulf %104, %105 : f32
                  %108 = arith.addf %106, %107 : f32
                  affine.store %108, %10[%arg1, %arg2, %arg3, %arg4] : memref<1x1024x2x2xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 1024 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            %102 = affine.load %10[%arg1, %arg2, %arg3, %arg4] : memref<1x1024x2x2xf32>
            %103 = arith.cmpf "olt", %102, %cst_0 : f32
            %104 = select %103, %cst_0, %102 : f32
            affine.store %104, %9[%arg1, %arg2, %arg3, %arg4] : memref<1x1024x2x2xf32>
          }
        }
      }
    }
    %97 = "krnl.global"() {name = "arith.constant_25", offset = 8509184 : i64, shape = [1024, 1, 3, 3]} : () -> memref<1024x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 1024 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_0, %8[%arg1, %arg2, %arg3, %arg4] : memref<1x1024x4x4xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 1024 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            %102 = affine.apply #map5(%arg3)
            %103 = affine.apply #map5(%arg4)
            %104 = affine.load %9[%arg1, %arg2, %arg3, %arg4] : memref<1x1024x2x2xf32>
            affine.store %104, %8[%arg1, %arg2, %102, %103] : memref<1x1024x4x4xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 1024 {
        affine.for %arg3 = 0 to 1 {
          %102 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 2 {
            affine.for %arg5 = 0 to 2 {
              affine.store %cst_0, %7[%arg1, %102, %arg4, %arg5] : memref<1x1024x2x2xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %103 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %104 = affine.apply #map7(%arg4, %arg7)
                    %105 = affine.apply #map7(%arg5, %arg8)
                    %106 = affine.load %8[%arg1, %103, %104, %105] : memref<1x1024x4x4xf32>
                    %107 = affine.load %97[%102, %arg6, %arg7, %arg8] : memref<1024x1x3x3xf32>
                    %108 = affine.load %7[%arg1, %102, %arg4, %arg5] : memref<1x1024x2x2xf32>
                    %109 = arith.mulf %106, %107 : f32
                    %110 = arith.addf %108, %109 : f32
                    affine.store %110, %7[%arg1, %102, %arg4, %arg5] : memref<1x1024x2x2xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 1024 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            %102 = affine.load %7[%arg1, %arg2, %arg3, %arg4] : memref<1x1024x2x2xf32>
            %103 = arith.cmpf "olt", %102, %cst_0 : f32
            %104 = select %103, %cst_0, %102 : f32
            affine.store %104, %6[%arg1, %arg2, %arg3, %arg4] : memref<1x1024x2x2xf32>
          }
        }
      }
    }
    %98 = "krnl.global"() {name = "arith.constant_26", offset = 8546048 : i64, shape = [1024, 1024, 1, 1]} : () -> memref<1024x1024x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 1024 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            affine.store %cst_0, %5[%arg1, %arg2, %arg3, %arg4] : memref<1x1024x2x2xf32>
            affine.for %arg5 = 0 to 1024 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %102 = affine.apply #map7(%arg3, %arg6)
                  %103 = affine.apply #map7(%arg4, %arg7)
                  %104 = affine.load %6[%arg1, %arg5, %102, %103] : memref<1x1024x2x2xf32>
                  %105 = affine.load %98[%arg2, %arg5, %arg6, %arg7] : memref<1024x1024x1x1xf32>
                  %106 = affine.load %5[%arg1, %arg2, %arg3, %arg4] : memref<1x1024x2x2xf32>
                  %107 = arith.mulf %104, %105 : f32
                  %108 = arith.addf %106, %107 : f32
                  affine.store %108, %5[%arg1, %arg2, %arg3, %arg4] : memref<1x1024x2x2xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 1024 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            %102 = affine.load %5[%arg1, %arg2, %arg3, %arg4] : memref<1x1024x2x2xf32>
            %103 = arith.cmpf "olt", %102, %cst_0 : f32
            %104 = select %103, %cst_0, %102 : f32
            affine.store %104, %4[%arg1, %arg2, %arg3, %arg4] : memref<1x1024x2x2xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 1024 {
        affine.for %arg3 = 0 to 1 {
          affine.for %arg4 = 0 to 1 {
            affine.store %cst_0, %3[%arg1, %arg2, %arg3, %arg4] : memref<1x1024x1x1xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 1024 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            %102 = affine.load %4[%arg1, %arg2, %arg3, %arg4] : memref<1x1024x2x2xf32>
            %103 = affine.load %3[%arg1, %arg2, %c0, %c0] : memref<1x1024x1x1xf32>
            %104 = arith.addf %103, %102 : f32
            affine.store %104, %3[%arg1, %arg2, %c0, %c0] : memref<1x1024x1x1xf32>
          }
        }
      }
    }
    %99 = arith.uitofp %c4_i64 : i64 to f32
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 1024 {
        affine.for %arg3 = 0 to 1 {
          affine.for %arg4 = 0 to 1 {
            %102 = affine.load %3[%arg1, %arg2, %arg3, %arg4] : memref<1x1024x1x1xf32>
            %103 = arith.divf %102, %99 : f32
            affine.store %103, %3[%arg1, %arg2, %arg3, %arg4] : memref<1x1024x1x1xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 1024 {
        affine.for %arg3 = 0 to 1 {
          affine.for %arg4 = 0 to 1 {
            %102 = affine.load %3[%arg1, %arg2, %arg3, %arg4] : memref<1x1024x1x1xf32>
            %103 = affine.apply #map22(%arg2, %arg3, %arg4)[%c1024, %c1, %c1]
            affine.store %102, %2[%arg1, %103] : memref<1x1024xf32>
          }
        }
      }
    }
    %100 = "krnl.global"() {name = "arith.constant_27", offset = 12740352 : i64, shape = [10, 1024]} : () -> memref<10x1024xf32>
    %101 = "krnl.global"() {name = "arith.constant_28", offset = 12781312 : i64, shape = [10], value = dense<[-0.0178910494, 0.00394501537, 0.0126184784, -0.0173512287, -0.00768596306, -0.0264055394, 0.00475354865, -0.0243351571, -0.0252915286, 0.0226600058]> : tensor<10xf32>} : () -> memref<10xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 10 {
        affine.store %cst_0, %1[%arg1, %arg2] : memref<1x10xf32>
        affine.for %arg3 = 0 to 1024 {
          %107 = affine.load %2[%arg1, %arg3] : memref<1x1024xf32>
          %108 = affine.load %100[%arg2, %arg3] : memref<10x1024xf32>
          %109 = affine.load %1[%arg1, %arg2] : memref<1x10xf32>
          %110 = arith.mulf %107, %108 : f32
          %111 = arith.addf %109, %110 : f32
          affine.store %111, %1[%arg1, %arg2] : memref<1x10xf32>
        }
        %102 = affine.load %1[%arg1, %arg2] : memref<1x10xf32>
        %103 = arith.mulf %cst, %102 : f32
        %104 = affine.load %101[%arg2] : memref<10xf32>
        %105 = arith.mulf %cst, %104 : f32
        %106 = arith.addf %103, %105 : f32
        affine.store %106, %1[%arg1, %arg2] : memref<1x10xf32>
      }
    }
    memref.dealloc %71 : memref<1x3x34x34xf32>
    memref.dealloc %70 : memref<1x32x32x32xf32>
    memref.dealloc %69 : memref<1x32x32x32xf32>
    memref.dealloc %68 : memref<1x32x34x34xf32>
    memref.dealloc %67 : memref<1x32x32x32xf32>
    memref.dealloc %66 : memref<1x32x32x32xf32>
    memref.dealloc %65 : memref<1x64x32x32xf32>
    memref.dealloc %64 : memref<1x64x32x32xf32>
    memref.dealloc %63 : memref<1x64x34x34xf32>
    memref.dealloc %62 : memref<1x64x16x16xf32>
    memref.dealloc %61 : memref<1x64x16x16xf32>
    memref.dealloc %60 : memref<1x128x16x16xf32>
    memref.dealloc %59 : memref<1x128x16x16xf32>
    memref.dealloc %58 : memref<1x128x18x18xf32>
    memref.dealloc %57 : memref<1x128x16x16xf32>
    memref.dealloc %56 : memref<1x128x16x16xf32>
    memref.dealloc %55 : memref<1x128x16x16xf32>
    memref.dealloc %54 : memref<1x128x16x16xf32>
    memref.dealloc %53 : memref<1x128x18x18xf32>
    memref.dealloc %52 : memref<1x128x8x8xf32>
    memref.dealloc %51 : memref<1x128x8x8xf32>
    memref.dealloc %50 : memref<1x256x8x8xf32>
    memref.dealloc %49 : memref<1x256x8x8xf32>
    memref.dealloc %48 : memref<1x256x10x10xf32>
    memref.dealloc %47 : memref<1x256x8x8xf32>
    memref.dealloc %46 : memref<1x256x8x8xf32>
    memref.dealloc %45 : memref<1x256x8x8xf32>
    memref.dealloc %44 : memref<1x256x8x8xf32>
    memref.dealloc %43 : memref<1x256x10x10xf32>
    memref.dealloc %42 : memref<1x256x4x4xf32>
    memref.dealloc %41 : memref<1x256x4x4xf32>
    memref.dealloc %40 : memref<1x512x4x4xf32>
    memref.dealloc %39 : memref<1x512x4x4xf32>
    memref.dealloc %38 : memref<1x512x6x6xf32>
    memref.dealloc %37 : memref<1x512x4x4xf32>
    memref.dealloc %36 : memref<1x512x4x4xf32>
    memref.dealloc %35 : memref<1x512x4x4xf32>
    memref.dealloc %34 : memref<1x512x4x4xf32>
    memref.dealloc %33 : memref<1x512x6x6xf32>
    memref.dealloc %32 : memref<1x512x4x4xf32>
    memref.dealloc %31 : memref<1x512x4x4xf32>
    memref.dealloc %30 : memref<1x512x4x4xf32>
    memref.dealloc %29 : memref<1x512x4x4xf32>
    memref.dealloc %28 : memref<1x512x6x6xf32>
    memref.dealloc %27 : memref<1x512x4x4xf32>
    memref.dealloc %26 : memref<1x512x4x4xf32>
    memref.dealloc %25 : memref<1x512x4x4xf32>
    memref.dealloc %24 : memref<1x512x4x4xf32>
    memref.dealloc %23 : memref<1x512x6x6xf32>
    memref.dealloc %22 : memref<1x512x4x4xf32>
    memref.dealloc %21 : memref<1x512x4x4xf32>
    memref.dealloc %20 : memref<1x512x4x4xf32>
    memref.dealloc %19 : memref<1x512x4x4xf32>
    memref.dealloc %18 : memref<1x512x6x6xf32>
    memref.dealloc %17 : memref<1x512x4x4xf32>
    memref.dealloc %16 : memref<1x512x4x4xf32>
    memref.dealloc %15 : memref<1x512x4x4xf32>
    memref.dealloc %14 : memref<1x512x4x4xf32>
    memref.dealloc %13 : memref<1x512x6x6xf32>
    memref.dealloc %12 : memref<1x512x2x2xf32>
    memref.dealloc %11 : memref<1x512x2x2xf32>
    memref.dealloc %10 : memref<1x1024x2x2xf32>
    memref.dealloc %9 : memref<1x1024x2x2xf32>
    memref.dealloc %8 : memref<1x1024x4x4xf32>
    memref.dealloc %7 : memref<1x1024x2x2xf32>
    memref.dealloc %6 : memref<1x1024x2x2xf32>
    memref.dealloc %5 : memref<1x1024x2x2xf32>
    memref.dealloc %4 : memref<1x1024x2x2xf32>
    memref.dealloc %3 : memref<1x1024x1x1xf32>
    memref.dealloc %2 : memref<1x1024xf32>
    return %1 : memref<1x10xf32>
  }
  "krnl.entry_point"() {func = @main_graph, numInputs = 1 : i32, numOutputs = 1 : i32} : () -> ()
}
