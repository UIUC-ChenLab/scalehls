#map0 = affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>
#map1 = affine_map<() -> (0)>
#map2 = affine_map<() -> (34)>
#map3 = affine_map<() -> (3)>
#map4 = affine_map<() -> (1)>
#map5 = affine_map<(d0) -> (d0 + 1)>
#map6 = affine_map<() -> (32)>
#map7 = affine_map<(d0, d1) -> (d0 + d1)>
#map8 = affine_map<() -> (64)>
#map9 = affine_map<(d0, d1) -> (d0 * 2 + d1)>
#map10 = affine_map<() -> (16)>
#map11 = affine_map<() -> (128)>
#map12 = affine_map<() -> (18)>
#map13 = affine_map<() -> (8)>
#map14 = affine_map<() -> (256)>
#map15 = affine_map<() -> (10)>
#map16 = affine_map<() -> (4)>
#map17 = affine_map<() -> (512)>
#map18 = affine_map<() -> (6)>
#map19 = affine_map<(d0, d1, d2)[s0, s1, s2] -> (d2 + d1 * s2 + d0 * (s1 * s2))>
#map20 = affine_map<(d0, d1) -> (d0, d1)>
#map21 = affine_map<(d0) -> (d0)>
module {
  %0 = "krnl.packed_const"() {file_name = "/tmp/packed_const-175e48.tmp", is_le = true, size_in_bytes = 44657408 : i64} : () -> i64
  func @main_graph(%arg0: memref<1x3x32x32xf32>) -> memref<1x10xf32> attributes {input_names = ["input.1"], output_names = ["70"]} {
    %c0 = constant 0 : index
    %c16_i64 = constant 16 : i64
    %c512 = constant 512 : index
    %c1 = constant 1 : index
    %cst = constant 1.000000e+00 : f32
    %cst_0 = constant 0.000000e+00 : f32
    %1 = memref.alloc() : memref<1x10xf32>
    %2 = memref.alloc() : memref<1x512xf32>
    %3 = memref.alloc() : memref<1x512x1x1xf32>
    %4 = memref.alloc() : memref<1x512x4x4xf32>
    %5 = memref.alloc() : memref<1x512x4x4xf32>
    %6 = memref.alloc() : memref<1x512x4x4xf32>
    %7 = memref.alloc() : memref<1x512x6x6xf32>
    %8 = memref.alloc() : memref<1x512x4x4xf32>
    %9 = memref.alloc() : memref<1x512x4x4xf32>
    %10 = memref.alloc() : memref<1x512x6x6xf32>
    %11 = memref.alloc() : memref<1x512x4x4xf32>
    %12 = memref.alloc() : memref<1x512x4x4xf32>
    %13 = memref.alloc() : memref<1x512x4x4xf32>
    %14 = memref.alloc() : memref<1x512x4x4xf32>
    %15 = memref.alloc() : memref<1x512x6x6xf32>
    %16 = memref.alloc() : memref<1x512x4x4xf32>
    %17 = memref.alloc() : memref<1x512x4x4xf32>
    %18 = memref.alloc() : memref<1x256x10x10xf32>
    %19 = memref.alloc() : memref<1x256x8x8xf32>
    %20 = memref.alloc() : memref<1x256x8x8xf32>
    %21 = memref.alloc() : memref<1x256x8x8xf32>
    %22 = memref.alloc() : memref<1x256x10x10xf32>
    %23 = memref.alloc() : memref<1x256x8x8xf32>
    %24 = memref.alloc() : memref<1x256x8x8xf32>
    %25 = memref.alloc() : memref<1x256x10x10xf32>
    %26 = memref.alloc() : memref<1x256x8x8xf32>
    %27 = memref.alloc() : memref<1x256x8x8xf32>
    %28 = memref.alloc() : memref<1x256x8x8xf32>
    %29 = memref.alloc() : memref<1x256x8x8xf32>
    %30 = memref.alloc() : memref<1x256x10x10xf32>
    %31 = memref.alloc() : memref<1x256x8x8xf32>
    %32 = memref.alloc() : memref<1x256x8x8xf32>
    %33 = memref.alloc() : memref<1x128x18x18xf32>
    %34 = memref.alloc() : memref<1x128x16x16xf32>
    %35 = memref.alloc() : memref<1x128x16x16xf32>
    %36 = memref.alloc() : memref<1x128x16x16xf32>
    %37 = memref.alloc() : memref<1x128x18x18xf32>
    %38 = memref.alloc() : memref<1x128x16x16xf32>
    %39 = memref.alloc() : memref<1x128x16x16xf32>
    %40 = memref.alloc() : memref<1x128x18x18xf32>
    %41 = memref.alloc() : memref<1x128x16x16xf32>
    %42 = memref.alloc() : memref<1x128x16x16xf32>
    %43 = memref.alloc() : memref<1x128x16x16xf32>
    %44 = memref.alloc() : memref<1x128x16x16xf32>
    %45 = memref.alloc() : memref<1x128x18x18xf32>
    %46 = memref.alloc() : memref<1x128x16x16xf32>
    %47 = memref.alloc() : memref<1x128x16x16xf32>
    %48 = memref.alloc() : memref<1x64x34x34xf32>
    %49 = memref.alloc() : memref<1x64x32x32xf32>
    %50 = memref.alloc() : memref<1x64x32x32xf32>
    %51 = memref.alloc() : memref<1x64x32x32xf32>
    %52 = memref.alloc() : memref<1x64x34x34xf32>
    %53 = memref.alloc() : memref<1x64x32x32xf32>
    %54 = memref.alloc() : memref<1x64x32x32xf32>
    %55 = memref.alloc() : memref<1x64x34x34xf32>
    %56 = memref.alloc() : memref<1x64x32x32xf32>
    %57 = memref.alloc() : memref<1x64x32x32xf32>
    %58 = memref.alloc() : memref<1x64x32x32xf32>
    %59 = memref.alloc() : memref<1x64x34x34xf32>
    %60 = memref.alloc() : memref<1x64x32x32xf32>
    %61 = memref.alloc() : memref<1x64x32x32xf32>
    %62 = memref.alloc() : memref<1x64x34x34xf32>
    %63 = memref.alloc() : memref<1x64x32x32xf32>
    %64 = memref.alloc() : memref<1x64x32x32xf32>
    %65 = memref.alloc() : memref<1x3x34x34xf32>
    %66 = "krnl.global"() {name = "constant_0", offset = 0 : i64, shape = [64, 3, 3, 3]} : () -> memref<64x3x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 3 {
        affine.for %arg3 = 0 to 34 {
          affine.for %arg4 = 0 to 34 {
            affine.store %cst_0, %65[%arg1, %arg2, %arg3, %arg4] : memref<1x3x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 3 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %89 = affine.apply #map5(%arg3)
            %90 = affine.apply #map5(%arg4)
            %91 = affine.load %arg0[%arg1, %arg2, %arg3, %arg4] : memref<1x3x32x32xf32>
            affine.store %91, %65[%arg1, %arg2, %89, %90] : memref<1x3x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            affine.store %cst_0, %64[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            affine.for %arg5 = 0 to 3 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %89 = affine.apply #map7(%arg3, %arg6)
                  %90 = affine.apply #map7(%arg4, %arg7)
                  %91 = affine.load %65[%arg1, %arg5, %89, %90] : memref<1x3x34x34xf32>
                  %92 = affine.load %66[%arg2, %arg5, %arg6, %arg7] : memref<64x3x3x3xf32>
                  %93 = affine.load %64[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
                  %94 = mulf %91, %92 : f32
                  %95 = addf %93, %94 : f32
                  affine.store %95, %64[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
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
            %89 = affine.load %64[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            %90 = cmpf "olt", %89, %cst_0 : f32
            %91 = select %90, %cst_0, %89 : f32
            affine.store %91, %63[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
          }
        }
      }
    }
    %67 = "krnl.global"() {name = "constant_1", offset = 6912 : i64, shape = [64, 64, 3, 3]} : () -> memref<64x64x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 34 {
          affine.for %arg4 = 0 to 34 {
            affine.store %cst_0, %62[%arg1, %arg2, %arg3, %arg4] : memref<1x64x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %89 = affine.apply #map5(%arg3)
            %90 = affine.apply #map5(%arg4)
            %91 = affine.load %63[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            affine.store %91, %62[%arg1, %arg2, %89, %90] : memref<1x64x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            affine.store %cst_0, %61[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            affine.for %arg5 = 0 to 64 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %89 = affine.apply #map7(%arg3, %arg6)
                  %90 = affine.apply #map7(%arg4, %arg7)
                  %91 = affine.load %62[%arg1, %arg5, %89, %90] : memref<1x64x34x34xf32>
                  %92 = affine.load %67[%arg2, %arg5, %arg6, %arg7] : memref<64x64x3x3xf32>
                  %93 = affine.load %61[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
                  %94 = mulf %91, %92 : f32
                  %95 = addf %93, %94 : f32
                  affine.store %95, %61[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
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
            %89 = affine.load %61[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            %90 = cmpf "olt", %89, %cst_0 : f32
            %91 = select %90, %cst_0, %89 : f32
            affine.store %91, %60[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
          }
        }
      }
    }
    %68 = "krnl.global"() {name = "constant_2", offset = 154368 : i64, shape = [64, 64, 3, 3]} : () -> memref<64x64x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 34 {
          affine.for %arg4 = 0 to 34 {
            affine.store %cst_0, %59[%arg1, %arg2, %arg3, %arg4] : memref<1x64x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %89 = affine.apply #map5(%arg3)
            %90 = affine.apply #map5(%arg4)
            %91 = affine.load %60[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            affine.store %91, %59[%arg1, %arg2, %89, %90] : memref<1x64x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            affine.store %cst_0, %58[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            affine.for %arg5 = 0 to 64 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %89 = affine.apply #map7(%arg3, %arg6)
                  %90 = affine.apply #map7(%arg4, %arg7)
                  %91 = affine.load %59[%arg1, %arg5, %89, %90] : memref<1x64x34x34xf32>
                  %92 = affine.load %68[%arg2, %arg5, %arg6, %arg7] : memref<64x64x3x3xf32>
                  %93 = affine.load %58[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
                  %94 = mulf %91, %92 : f32
                  %95 = addf %93, %94 : f32
                  affine.store %95, %58[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
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
            %89 = affine.load %58[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            %90 = affine.load %63[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            %91 = addf %89, %90 : f32
            affine.store %91, %57[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %89 = affine.load %57[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            %90 = cmpf "olt", %89, %cst_0 : f32
            %91 = select %90, %cst_0, %89 : f32
            affine.store %91, %56[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
          }
        }
      }
    }
    %69 = "krnl.global"() {name = "constant_3", offset = 301824 : i64, shape = [64, 64, 3, 3]} : () -> memref<64x64x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 34 {
          affine.for %arg4 = 0 to 34 {
            affine.store %cst_0, %55[%arg1, %arg2, %arg3, %arg4] : memref<1x64x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %89 = affine.apply #map5(%arg3)
            %90 = affine.apply #map5(%arg4)
            %91 = affine.load %56[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            affine.store %91, %55[%arg1, %arg2, %89, %90] : memref<1x64x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            affine.store %cst_0, %54[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            affine.for %arg5 = 0 to 64 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %89 = affine.apply #map7(%arg3, %arg6)
                  %90 = affine.apply #map7(%arg4, %arg7)
                  %91 = affine.load %55[%arg1, %arg5, %89, %90] : memref<1x64x34x34xf32>
                  %92 = affine.load %69[%arg2, %arg5, %arg6, %arg7] : memref<64x64x3x3xf32>
                  %93 = affine.load %54[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
                  %94 = mulf %91, %92 : f32
                  %95 = addf %93, %94 : f32
                  affine.store %95, %54[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
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
            %89 = affine.load %54[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            %90 = cmpf "olt", %89, %cst_0 : f32
            %91 = select %90, %cst_0, %89 : f32
            affine.store %91, %53[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
          }
        }
      }
    }
    %70 = "krnl.global"() {name = "constant_4", offset = 449280 : i64, shape = [64, 64, 3, 3]} : () -> memref<64x64x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 34 {
          affine.for %arg4 = 0 to 34 {
            affine.store %cst_0, %52[%arg1, %arg2, %arg3, %arg4] : memref<1x64x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %89 = affine.apply #map5(%arg3)
            %90 = affine.apply #map5(%arg4)
            %91 = affine.load %53[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            affine.store %91, %52[%arg1, %arg2, %89, %90] : memref<1x64x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            affine.store %cst_0, %51[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            affine.for %arg5 = 0 to 64 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %89 = affine.apply #map7(%arg3, %arg6)
                  %90 = affine.apply #map7(%arg4, %arg7)
                  %91 = affine.load %52[%arg1, %arg5, %89, %90] : memref<1x64x34x34xf32>
                  %92 = affine.load %70[%arg2, %arg5, %arg6, %arg7] : memref<64x64x3x3xf32>
                  %93 = affine.load %51[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
                  %94 = mulf %91, %92 : f32
                  %95 = addf %93, %94 : f32
                  affine.store %95, %51[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
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
            %89 = affine.load %51[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            %90 = affine.load %56[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            %91 = addf %89, %90 : f32
            affine.store %91, %50[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %89 = affine.load %50[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            %90 = cmpf "olt", %89, %cst_0 : f32
            %91 = select %90, %cst_0, %89 : f32
            affine.store %91, %49[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
          }
        }
      }
    }
    %71 = "krnl.global"() {name = "constant_5", offset = 596736 : i64, shape = [128, 64, 3, 3]} : () -> memref<128x64x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 34 {
          affine.for %arg4 = 0 to 34 {
            affine.store %cst_0, %48[%arg1, %arg2, %arg3, %arg4] : memref<1x64x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %89 = affine.apply #map5(%arg3)
            %90 = affine.apply #map5(%arg4)
            %91 = affine.load %49[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            affine.store %91, %48[%arg1, %arg2, %89, %90] : memref<1x64x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            affine.store %cst_0, %47[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            affine.for %arg5 = 0 to 64 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %89 = affine.apply #map9(%arg3, %arg6)
                  %90 = affine.apply #map9(%arg4, %arg7)
                  %91 = affine.load %48[%arg1, %arg5, %89, %90] : memref<1x64x34x34xf32>
                  %92 = affine.load %71[%arg2, %arg5, %arg6, %arg7] : memref<128x64x3x3xf32>
                  %93 = affine.load %47[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
                  %94 = mulf %91, %92 : f32
                  %95 = addf %93, %94 : f32
                  affine.store %95, %47[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
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
            %89 = affine.load %47[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            %90 = cmpf "olt", %89, %cst_0 : f32
            %91 = select %90, %cst_0, %89 : f32
            affine.store %91, %46[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
          }
        }
      }
    }
    %72 = "krnl.global"() {name = "constant_6", offset = 891648 : i64, shape = [128, 128, 3, 3]} : () -> memref<128x128x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 18 {
          affine.for %arg4 = 0 to 18 {
            affine.store %cst_0, %45[%arg1, %arg2, %arg3, %arg4] : memref<1x128x18x18xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %89 = affine.apply #map5(%arg3)
            %90 = affine.apply #map5(%arg4)
            %91 = affine.load %46[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            affine.store %91, %45[%arg1, %arg2, %89, %90] : memref<1x128x18x18xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            affine.store %cst_0, %44[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            affine.for %arg5 = 0 to 128 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %89 = affine.apply #map7(%arg3, %arg6)
                  %90 = affine.apply #map7(%arg4, %arg7)
                  %91 = affine.load %45[%arg1, %arg5, %89, %90] : memref<1x128x18x18xf32>
                  %92 = affine.load %72[%arg2, %arg5, %arg6, %arg7] : memref<128x128x3x3xf32>
                  %93 = affine.load %44[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
                  %94 = mulf %91, %92 : f32
                  %95 = addf %93, %94 : f32
                  affine.store %95, %44[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
                }
              }
            }
          }
        }
      }
    }
    %73 = "krnl.global"() {name = "constant_7", offset = 1481472 : i64, shape = [128, 64, 1, 1]} : () -> memref<128x64x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            affine.store %cst_0, %43[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            affine.for %arg5 = 0 to 64 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %89 = affine.apply #map9(%arg3, %arg6)
                  %90 = affine.apply #map9(%arg4, %arg7)
                  %91 = affine.load %49[%arg1, %arg5, %89, %90] : memref<1x64x32x32xf32>
                  %92 = affine.load %73[%arg2, %arg5, %arg6, %arg7] : memref<128x64x1x1xf32>
                  %93 = affine.load %43[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
                  %94 = mulf %91, %92 : f32
                  %95 = addf %93, %94 : f32
                  affine.store %95, %43[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
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
            %89 = affine.load %44[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            %90 = affine.load %43[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            %91 = addf %89, %90 : f32
            affine.store %91, %42[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %89 = affine.load %42[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            %90 = cmpf "olt", %89, %cst_0 : f32
            %91 = select %90, %cst_0, %89 : f32
            affine.store %91, %41[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
          }
        }
      }
    }
    %74 = "krnl.global"() {name = "constant_8", offset = 1514240 : i64, shape = [128, 128, 3, 3]} : () -> memref<128x128x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 18 {
          affine.for %arg4 = 0 to 18 {
            affine.store %cst_0, %40[%arg1, %arg2, %arg3, %arg4] : memref<1x128x18x18xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %89 = affine.apply #map5(%arg3)
            %90 = affine.apply #map5(%arg4)
            %91 = affine.load %41[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            affine.store %91, %40[%arg1, %arg2, %89, %90] : memref<1x128x18x18xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            affine.store %cst_0, %39[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            affine.for %arg5 = 0 to 128 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %89 = affine.apply #map7(%arg3, %arg6)
                  %90 = affine.apply #map7(%arg4, %arg7)
                  %91 = affine.load %40[%arg1, %arg5, %89, %90] : memref<1x128x18x18xf32>
                  %92 = affine.load %74[%arg2, %arg5, %arg6, %arg7] : memref<128x128x3x3xf32>
                  %93 = affine.load %39[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
                  %94 = mulf %91, %92 : f32
                  %95 = addf %93, %94 : f32
                  affine.store %95, %39[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
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
            %89 = affine.load %39[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            %90 = cmpf "olt", %89, %cst_0 : f32
            %91 = select %90, %cst_0, %89 : f32
            affine.store %91, %38[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
          }
        }
      }
    }
    %75 = "krnl.global"() {name = "constant_9", offset = 2104064 : i64, shape = [128, 128, 3, 3]} : () -> memref<128x128x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 18 {
          affine.for %arg4 = 0 to 18 {
            affine.store %cst_0, %37[%arg1, %arg2, %arg3, %arg4] : memref<1x128x18x18xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %89 = affine.apply #map5(%arg3)
            %90 = affine.apply #map5(%arg4)
            %91 = affine.load %38[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            affine.store %91, %37[%arg1, %arg2, %89, %90] : memref<1x128x18x18xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            affine.store %cst_0, %36[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            affine.for %arg5 = 0 to 128 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %89 = affine.apply #map7(%arg3, %arg6)
                  %90 = affine.apply #map7(%arg4, %arg7)
                  %91 = affine.load %37[%arg1, %arg5, %89, %90] : memref<1x128x18x18xf32>
                  %92 = affine.load %75[%arg2, %arg5, %arg6, %arg7] : memref<128x128x3x3xf32>
                  %93 = affine.load %36[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
                  %94 = mulf %91, %92 : f32
                  %95 = addf %93, %94 : f32
                  affine.store %95, %36[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
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
            %89 = affine.load %36[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            %90 = affine.load %41[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            %91 = addf %89, %90 : f32
            affine.store %91, %35[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %89 = affine.load %35[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            %90 = cmpf "olt", %89, %cst_0 : f32
            %91 = select %90, %cst_0, %89 : f32
            affine.store %91, %34[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
          }
        }
      }
    }
    %76 = "krnl.global"() {name = "constant_10", offset = 2693888 : i64, shape = [256, 128, 3, 3]} : () -> memref<256x128x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 18 {
          affine.for %arg4 = 0 to 18 {
            affine.store %cst_0, %33[%arg1, %arg2, %arg3, %arg4] : memref<1x128x18x18xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %89 = affine.apply #map5(%arg3)
            %90 = affine.apply #map5(%arg4)
            %91 = affine.load %34[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            affine.store %91, %33[%arg1, %arg2, %89, %90] : memref<1x128x18x18xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_0, %32[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            affine.for %arg5 = 0 to 128 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %89 = affine.apply #map9(%arg3, %arg6)
                  %90 = affine.apply #map9(%arg4, %arg7)
                  %91 = affine.load %33[%arg1, %arg5, %89, %90] : memref<1x128x18x18xf32>
                  %92 = affine.load %76[%arg2, %arg5, %arg6, %arg7] : memref<256x128x3x3xf32>
                  %93 = affine.load %32[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
                  %94 = mulf %91, %92 : f32
                  %95 = addf %93, %94 : f32
                  affine.store %95, %32[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
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
            %89 = affine.load %32[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            %90 = cmpf "olt", %89, %cst_0 : f32
            %91 = select %90, %cst_0, %89 : f32
            affine.store %91, %31[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
          }
        }
      }
    }
    %77 = "krnl.global"() {name = "constant_11", offset = 3873536 : i64, shape = [256, 256, 3, 3]} : () -> memref<256x256x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 10 {
          affine.for %arg4 = 0 to 10 {
            affine.store %cst_0, %30[%arg1, %arg2, %arg3, %arg4] : memref<1x256x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %89 = affine.apply #map5(%arg3)
            %90 = affine.apply #map5(%arg4)
            %91 = affine.load %31[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            affine.store %91, %30[%arg1, %arg2, %89, %90] : memref<1x256x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_0, %29[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            affine.for %arg5 = 0 to 256 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %89 = affine.apply #map7(%arg3, %arg6)
                  %90 = affine.apply #map7(%arg4, %arg7)
                  %91 = affine.load %30[%arg1, %arg5, %89, %90] : memref<1x256x10x10xf32>
                  %92 = affine.load %77[%arg2, %arg5, %arg6, %arg7] : memref<256x256x3x3xf32>
                  %93 = affine.load %29[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
                  %94 = mulf %91, %92 : f32
                  %95 = addf %93, %94 : f32
                  affine.store %95, %29[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
                }
              }
            }
          }
        }
      }
    }
    %78 = "krnl.global"() {name = "constant_12", offset = 6232832 : i64, shape = [256, 128, 1, 1]} : () -> memref<256x128x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_0, %28[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            affine.for %arg5 = 0 to 128 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %89 = affine.apply #map9(%arg3, %arg6)
                  %90 = affine.apply #map9(%arg4, %arg7)
                  %91 = affine.load %34[%arg1, %arg5, %89, %90] : memref<1x128x16x16xf32>
                  %92 = affine.load %78[%arg2, %arg5, %arg6, %arg7] : memref<256x128x1x1xf32>
                  %93 = affine.load %28[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
                  %94 = mulf %91, %92 : f32
                  %95 = addf %93, %94 : f32
                  affine.store %95, %28[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
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
            %89 = affine.load %29[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            %90 = affine.load %28[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            %91 = addf %89, %90 : f32
            affine.store %91, %27[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %89 = affine.load %27[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            %90 = cmpf "olt", %89, %cst_0 : f32
            %91 = select %90, %cst_0, %89 : f32
            affine.store %91, %26[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
          }
        }
      }
    }
    %79 = "krnl.global"() {name = "constant_13", offset = 6363904 : i64, shape = [256, 256, 3, 3]} : () -> memref<256x256x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 10 {
          affine.for %arg4 = 0 to 10 {
            affine.store %cst_0, %25[%arg1, %arg2, %arg3, %arg4] : memref<1x256x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %89 = affine.apply #map5(%arg3)
            %90 = affine.apply #map5(%arg4)
            %91 = affine.load %26[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            affine.store %91, %25[%arg1, %arg2, %89, %90] : memref<1x256x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_0, %24[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            affine.for %arg5 = 0 to 256 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %89 = affine.apply #map7(%arg3, %arg6)
                  %90 = affine.apply #map7(%arg4, %arg7)
                  %91 = affine.load %25[%arg1, %arg5, %89, %90] : memref<1x256x10x10xf32>
                  %92 = affine.load %79[%arg2, %arg5, %arg6, %arg7] : memref<256x256x3x3xf32>
                  %93 = affine.load %24[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
                  %94 = mulf %91, %92 : f32
                  %95 = addf %93, %94 : f32
                  affine.store %95, %24[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
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
            %89 = affine.load %24[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            %90 = cmpf "olt", %89, %cst_0 : f32
            %91 = select %90, %cst_0, %89 : f32
            affine.store %91, %23[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
          }
        }
      }
    }
    %80 = "krnl.global"() {name = "constant_14", offset = 8723200 : i64, shape = [256, 256, 3, 3]} : () -> memref<256x256x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 10 {
          affine.for %arg4 = 0 to 10 {
            affine.store %cst_0, %22[%arg1, %arg2, %arg3, %arg4] : memref<1x256x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %89 = affine.apply #map5(%arg3)
            %90 = affine.apply #map5(%arg4)
            %91 = affine.load %23[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            affine.store %91, %22[%arg1, %arg2, %89, %90] : memref<1x256x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_0, %21[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            affine.for %arg5 = 0 to 256 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %89 = affine.apply #map7(%arg3, %arg6)
                  %90 = affine.apply #map7(%arg4, %arg7)
                  %91 = affine.load %22[%arg1, %arg5, %89, %90] : memref<1x256x10x10xf32>
                  %92 = affine.load %80[%arg2, %arg5, %arg6, %arg7] : memref<256x256x3x3xf32>
                  %93 = affine.load %21[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
                  %94 = mulf %91, %92 : f32
                  %95 = addf %93, %94 : f32
                  affine.store %95, %21[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
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
            %89 = affine.load %21[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            %90 = affine.load %26[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            %91 = addf %89, %90 : f32
            affine.store %91, %20[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %89 = affine.load %20[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            %90 = cmpf "olt", %89, %cst_0 : f32
            %91 = select %90, %cst_0, %89 : f32
            affine.store %91, %19[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
          }
        }
      }
    }
    %81 = "krnl.global"() {name = "constant_15", offset = 11082496 : i64, shape = [512, 256, 3, 3]} : () -> memref<512x256x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 10 {
          affine.for %arg4 = 0 to 10 {
            affine.store %cst_0, %18[%arg1, %arg2, %arg3, %arg4] : memref<1x256x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %89 = affine.apply #map5(%arg3)
            %90 = affine.apply #map5(%arg4)
            %91 = affine.load %19[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            affine.store %91, %18[%arg1, %arg2, %89, %90] : memref<1x256x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_0, %17[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.for %arg5 = 0 to 256 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %89 = affine.apply #map9(%arg3, %arg6)
                  %90 = affine.apply #map9(%arg4, %arg7)
                  %91 = affine.load %18[%arg1, %arg5, %89, %90] : memref<1x256x10x10xf32>
                  %92 = affine.load %81[%arg2, %arg5, %arg6, %arg7] : memref<512x256x3x3xf32>
                  %93 = affine.load %17[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                  %94 = mulf %91, %92 : f32
                  %95 = addf %93, %94 : f32
                  affine.store %95, %17[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
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
            %89 = affine.load %17[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %90 = cmpf "olt", %89, %cst_0 : f32
            %91 = select %90, %cst_0, %89 : f32
            affine.store %91, %16[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    %82 = "krnl.global"() {name = "constant_16", offset = 15801088 : i64, shape = [512, 512, 3, 3]} : () -> memref<512x512x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 6 {
          affine.for %arg4 = 0 to 6 {
            affine.store %cst_0, %15[%arg1, %arg2, %arg3, %arg4] : memref<1x512x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %89 = affine.apply #map5(%arg3)
            %90 = affine.apply #map5(%arg4)
            %91 = affine.load %16[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.store %91, %15[%arg1, %arg2, %89, %90] : memref<1x512x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_0, %14[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.for %arg5 = 0 to 512 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %89 = affine.apply #map7(%arg3, %arg6)
                  %90 = affine.apply #map7(%arg4, %arg7)
                  %91 = affine.load %15[%arg1, %arg5, %89, %90] : memref<1x512x6x6xf32>
                  %92 = affine.load %82[%arg2, %arg5, %arg6, %arg7] : memref<512x512x3x3xf32>
                  %93 = affine.load %14[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                  %94 = mulf %91, %92 : f32
                  %95 = addf %93, %94 : f32
                  affine.store %95, %14[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                }
              }
            }
          }
        }
      }
    }
    %83 = "krnl.global"() {name = "constant_17", offset = 25238272 : i64, shape = [512, 256, 1, 1]} : () -> memref<512x256x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_0, %13[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.for %arg5 = 0 to 256 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %89 = affine.apply #map9(%arg3, %arg6)
                  %90 = affine.apply #map9(%arg4, %arg7)
                  %91 = affine.load %19[%arg1, %arg5, %89, %90] : memref<1x256x8x8xf32>
                  %92 = affine.load %83[%arg2, %arg5, %arg6, %arg7] : memref<512x256x1x1xf32>
                  %93 = affine.load %13[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                  %94 = mulf %91, %92 : f32
                  %95 = addf %93, %94 : f32
                  affine.store %95, %13[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
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
            %89 = affine.load %14[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %90 = affine.load %13[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %91 = addf %89, %90 : f32
            affine.store %91, %12[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %89 = affine.load %12[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %90 = cmpf "olt", %89, %cst_0 : f32
            %91 = select %90, %cst_0, %89 : f32
            affine.store %91, %11[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    %84 = "krnl.global"() {name = "constant_18", offset = 25762560 : i64, shape = [512, 512, 3, 3]} : () -> memref<512x512x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 6 {
          affine.for %arg4 = 0 to 6 {
            affine.store %cst_0, %10[%arg1, %arg2, %arg3, %arg4] : memref<1x512x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %89 = affine.apply #map5(%arg3)
            %90 = affine.apply #map5(%arg4)
            %91 = affine.load %11[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.store %91, %10[%arg1, %arg2, %89, %90] : memref<1x512x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_0, %9[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.for %arg5 = 0 to 512 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %89 = affine.apply #map7(%arg3, %arg6)
                  %90 = affine.apply #map7(%arg4, %arg7)
                  %91 = affine.load %10[%arg1, %arg5, %89, %90] : memref<1x512x6x6xf32>
                  %92 = affine.load %84[%arg2, %arg5, %arg6, %arg7] : memref<512x512x3x3xf32>
                  %93 = affine.load %9[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                  %94 = mulf %91, %92 : f32
                  %95 = addf %93, %94 : f32
                  affine.store %95, %9[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
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
            %89 = affine.load %9[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %90 = cmpf "olt", %89, %cst_0 : f32
            %91 = select %90, %cst_0, %89 : f32
            affine.store %91, %8[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    %85 = "krnl.global"() {name = "constant_19", offset = 35199744 : i64, shape = [512, 512, 3, 3]} : () -> memref<512x512x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 6 {
          affine.for %arg4 = 0 to 6 {
            affine.store %cst_0, %7[%arg1, %arg2, %arg3, %arg4] : memref<1x512x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %89 = affine.apply #map5(%arg3)
            %90 = affine.apply #map5(%arg4)
            %91 = affine.load %8[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.store %91, %7[%arg1, %arg2, %89, %90] : memref<1x512x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_0, %6[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.for %arg5 = 0 to 512 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %89 = affine.apply #map7(%arg3, %arg6)
                  %90 = affine.apply #map7(%arg4, %arg7)
                  %91 = affine.load %7[%arg1, %arg5, %89, %90] : memref<1x512x6x6xf32>
                  %92 = affine.load %85[%arg2, %arg5, %arg6, %arg7] : memref<512x512x3x3xf32>
                  %93 = affine.load %6[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                  %94 = mulf %91, %92 : f32
                  %95 = addf %93, %94 : f32
                  affine.store %95, %6[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
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
            %89 = affine.load %6[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %90 = affine.load %11[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %91 = addf %89, %90 : f32
            affine.store %91, %5[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %89 = affine.load %5[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %90 = cmpf "olt", %89, %cst_0 : f32
            %91 = select %90, %cst_0, %89 : f32
            affine.store %91, %4[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 1 {
          affine.for %arg4 = 0 to 1 {
            affine.store %cst_0, %3[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %89 = affine.load %4[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %90 = affine.load %3[%arg1, %arg2, %c0, %c0] : memref<1x512x1x1xf32>
            %91 = addf %90, %89 : f32
            affine.store %91, %3[%arg1, %arg2, %c0, %c0] : memref<1x512x1x1xf32>
          }
        }
      }
    }
    %86 = uitofp %c16_i64 : i64 to f32
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 1 {
          affine.for %arg4 = 0 to 1 {
            %89 = affine.load %3[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
            %90 = divf %89, %86 : f32
            affine.store %90, %3[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 1 {
          affine.for %arg4 = 0 to 1 {
            %89 = affine.load %3[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
            %90 = affine.apply #map19(%arg2, %arg3, %arg4)[%c512, %c1, %c1]
            affine.store %89, %2[%arg1, %90] : memref<1x512xf32>
          }
        }
      }
    }
    %87 = "krnl.global"() {name = "constant_20", offset = 44636928 : i64, shape = [10, 512]} : () -> memref<10x512xf32>
    %88 = "krnl.global"() {name = "constant_21", offset = 44657408 : i64, shape = [10], value = dense<[-0.0278122574, -0.0410711654, -0.00870433543, -0.0383192934, -0.0207557045, 0.0408722125, 0.0364007317, 0.0409536846, 0.00303884572, -0.0432778746]> : tensor<10xf32>} : () -> memref<10xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 10 {
        affine.store %cst_0, %1[%arg1, %arg2] : memref<1x10xf32>
        affine.for %arg3 = 0 to 512 {
          %94 = affine.load %2[%arg1, %arg3] : memref<1x512xf32>
          %95 = affine.load %87[%arg2, %arg3] : memref<10x512xf32>
          %96 = affine.load %1[%arg1, %arg2] : memref<1x10xf32>
          %97 = mulf %94, %95 : f32
          %98 = addf %96, %97 : f32
          affine.store %98, %1[%arg1, %arg2] : memref<1x10xf32>
        }
        %89 = affine.load %1[%arg1, %arg2] : memref<1x10xf32>
        %90 = mulf %cst, %89 : f32
        %91 = affine.load %88[%arg2] : memref<10xf32>
        %92 = mulf %cst, %91 : f32
        %93 = addf %90, %92 : f32
        affine.store %93, %1[%arg1, %arg2] : memref<1x10xf32>
      }
    }
    memref.dealloc %65 : memref<1x3x34x34xf32>
    memref.dealloc %64 : memref<1x64x32x32xf32>
    memref.dealloc %63 : memref<1x64x32x32xf32>
    memref.dealloc %62 : memref<1x64x34x34xf32>
    memref.dealloc %61 : memref<1x64x32x32xf32>
    memref.dealloc %60 : memref<1x64x32x32xf32>
    memref.dealloc %59 : memref<1x64x34x34xf32>
    memref.dealloc %58 : memref<1x64x32x32xf32>
    memref.dealloc %57 : memref<1x64x32x32xf32>
    memref.dealloc %56 : memref<1x64x32x32xf32>
    memref.dealloc %55 : memref<1x64x34x34xf32>
    memref.dealloc %54 : memref<1x64x32x32xf32>
    memref.dealloc %53 : memref<1x64x32x32xf32>
    memref.dealloc %52 : memref<1x64x34x34xf32>
    memref.dealloc %51 : memref<1x64x32x32xf32>
    memref.dealloc %50 : memref<1x64x32x32xf32>
    memref.dealloc %49 : memref<1x64x32x32xf32>
    memref.dealloc %48 : memref<1x64x34x34xf32>
    memref.dealloc %47 : memref<1x128x16x16xf32>
    memref.dealloc %46 : memref<1x128x16x16xf32>
    memref.dealloc %45 : memref<1x128x18x18xf32>
    memref.dealloc %44 : memref<1x128x16x16xf32>
    memref.dealloc %43 : memref<1x128x16x16xf32>
    memref.dealloc %42 : memref<1x128x16x16xf32>
    memref.dealloc %41 : memref<1x128x16x16xf32>
    memref.dealloc %40 : memref<1x128x18x18xf32>
    memref.dealloc %39 : memref<1x128x16x16xf32>
    memref.dealloc %38 : memref<1x128x16x16xf32>
    memref.dealloc %37 : memref<1x128x18x18xf32>
    memref.dealloc %36 : memref<1x128x16x16xf32>
    memref.dealloc %35 : memref<1x128x16x16xf32>
    memref.dealloc %34 : memref<1x128x16x16xf32>
    memref.dealloc %33 : memref<1x128x18x18xf32>
    memref.dealloc %32 : memref<1x256x8x8xf32>
    memref.dealloc %31 : memref<1x256x8x8xf32>
    memref.dealloc %30 : memref<1x256x10x10xf32>
    memref.dealloc %29 : memref<1x256x8x8xf32>
    memref.dealloc %28 : memref<1x256x8x8xf32>
    memref.dealloc %27 : memref<1x256x8x8xf32>
    memref.dealloc %26 : memref<1x256x8x8xf32>
    memref.dealloc %25 : memref<1x256x10x10xf32>
    memref.dealloc %24 : memref<1x256x8x8xf32>
    memref.dealloc %23 : memref<1x256x8x8xf32>
    memref.dealloc %22 : memref<1x256x10x10xf32>
    memref.dealloc %21 : memref<1x256x8x8xf32>
    memref.dealloc %20 : memref<1x256x8x8xf32>
    memref.dealloc %19 : memref<1x256x8x8xf32>
    memref.dealloc %18 : memref<1x256x10x10xf32>
    memref.dealloc %17 : memref<1x512x4x4xf32>
    memref.dealloc %16 : memref<1x512x4x4xf32>
    memref.dealloc %15 : memref<1x512x6x6xf32>
    memref.dealloc %14 : memref<1x512x4x4xf32>
    memref.dealloc %13 : memref<1x512x4x4xf32>
    memref.dealloc %12 : memref<1x512x4x4xf32>
    memref.dealloc %11 : memref<1x512x4x4xf32>
    memref.dealloc %10 : memref<1x512x6x6xf32>
    memref.dealloc %9 : memref<1x512x4x4xf32>
    memref.dealloc %8 : memref<1x512x4x4xf32>
    memref.dealloc %7 : memref<1x512x6x6xf32>
    memref.dealloc %6 : memref<1x512x4x4xf32>
    memref.dealloc %5 : memref<1x512x4x4xf32>
    memref.dealloc %4 : memref<1x512x4x4xf32>
    memref.dealloc %3 : memref<1x512x1x1xf32>
    memref.dealloc %2 : memref<1x512xf32>
    return %1 : memref<1x10xf32>
  }
  "krnl.entry_point"() {func = @main_graph, numInputs = 1 : i32, numOutputs = 1 : i32} : () -> ()
}
