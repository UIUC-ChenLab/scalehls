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
#map11 = affine_map<() -> (18)>
#map12 = affine_map<() -> (128)>
#map13 = affine_map<() -> (8)>
#map14 = affine_map<() -> (10)>
#map15 = affine_map<() -> (256)>
#map16 = affine_map<() -> (4)>
#map17 = affine_map<() -> (6)>
#map18 = affine_map<() -> (512)>
#map19 = affine_map<() -> (2)>
#map20 = affine_map<(d0, d1, d2)[s0, s1, s2] -> (d2 + d1 * s2 + d0 * (s1 * s2))>
#map21 = affine_map<(d0, d1) -> (d0, d1)>
#map22 = affine_map<(d0) -> (d0)>
module {
  %0 = "krnl.packed_const"() {file_name = "/tmp/packed_const-708c58.tmp", is_le = true, size_in_bytes = 58862336 : i64} : () -> i64
  func @main_graph(%arg0: memref<1x3x32x32xf32>) -> memref<1x10xf32> attributes {input_names = ["input.1"], output_names = ["44"]} {
    %c0 = arith.constant 0 : index
    %c1_i64 = arith.constant 1 : i64
    %c512 = arith.constant 512 : index
    %c1 = arith.constant 1 : index
    %cst = arith.constant 1.000000e+00 : f32
    %cst_0 = arith.constant 0.000000e+00 : f32
    %1 = memref.alloc() : memref<1x10xf32>
    %2 = memref.alloc() : memref<1x512xf32>
    %3 = memref.alloc() : memref<1x512x1x1xf32>
    %4 = memref.alloc() : memref<1x512x1x1xf32>
    %5 = memref.alloc() : memref<1x512x1x1xf32>
    %6 = memref.alloc() : memref<1x512x4x4xf32>
    %7 = memref.alloc() : memref<1x512x2x2xf32>
    %8 = memref.alloc() : memref<1x512x2x2xf32>
    %9 = memref.alloc() : memref<1x512x4x4xf32>
    %10 = memref.alloc() : memref<1x512x2x2xf32>
    %11 = memref.alloc() : memref<1x512x2x2xf32>
    %12 = memref.alloc() : memref<1x512x4x4xf32>
    %13 = memref.alloc() : memref<1x512x2x2xf32>
    %14 = memref.alloc() : memref<1x512x2x2xf32>
    %15 = memref.alloc() : memref<1x512x6x6xf32>
    %16 = memref.alloc() : memref<1x512x4x4xf32>
    %17 = memref.alloc() : memref<1x512x4x4xf32>
    %18 = memref.alloc() : memref<1x512x6x6xf32>
    %19 = memref.alloc() : memref<1x512x4x4xf32>
    %20 = memref.alloc() : memref<1x512x4x4xf32>
    %21 = memref.alloc() : memref<1x256x6x6xf32>
    %22 = memref.alloc() : memref<1x256x4x4xf32>
    %23 = memref.alloc() : memref<1x256x4x4xf32>
    %24 = memref.alloc() : memref<1x256x10x10xf32>
    %25 = memref.alloc() : memref<1x256x8x8xf32>
    %26 = memref.alloc() : memref<1x256x8x8xf32>
    %27 = memref.alloc() : memref<1x256x10x10xf32>
    %28 = memref.alloc() : memref<1x256x8x8xf32>
    %29 = memref.alloc() : memref<1x256x8x8xf32>
    %30 = memref.alloc() : memref<1x128x10x10xf32>
    %31 = memref.alloc() : memref<1x128x8x8xf32>
    %32 = memref.alloc() : memref<1x128x8x8xf32>
    %33 = memref.alloc() : memref<1x128x18x18xf32>
    %34 = memref.alloc() : memref<1x128x16x16xf32>
    %35 = memref.alloc() : memref<1x128x16x16xf32>
    %36 = memref.alloc() : memref<1x64x18x18xf32>
    %37 = memref.alloc() : memref<1x64x16x16xf32>
    %38 = memref.alloc() : memref<1x64x16x16xf32>
    %39 = memref.alloc() : memref<1x64x34x34xf32>
    %40 = memref.alloc() : memref<1x64x32x32xf32>
    %41 = memref.alloc() : memref<1x64x32x32xf32>
    %42 = memref.alloc() : memref<1x3x34x34xf32>
    %43 = "krnl.global"() {name = "arith.constant_0", offset = 0 : i64, shape = [64, 3, 3, 3]} : () -> memref<64x3x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 3 {
        affine.for %arg3 = 0 to 34 {
          affine.for %arg4 = 0 to 34 {
            affine.store %cst_0, %42[%arg1, %arg2, %arg3, %arg4] : memref<1x3x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 3 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %59 = affine.apply #map5(%arg3)
            %60 = affine.apply #map5(%arg4)
            %61 = affine.load %arg0[%arg1, %arg2, %arg3, %arg4] : memref<1x3x32x32xf32>
            affine.store %61, %42[%arg1, %arg2, %59, %60] : memref<1x3x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            affine.store %cst_0, %41[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            affine.for %arg5 = 0 to 3 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %59 = affine.apply #map7(%arg3, %arg6)
                  %60 = affine.apply #map7(%arg4, %arg7)
                  %61 = affine.load %42[%arg1, %arg5, %59, %60] : memref<1x3x34x34xf32>
                  %62 = affine.load %43[%arg2, %arg5, %arg6, %arg7] : memref<64x3x3x3xf32>
                  %63 = affine.load %41[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
                  %64 = arith.mulf %61, %62 : f32
                  %65 = arith.addf %63, %64 : f32
                  affine.store %65, %41[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
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
            %59 = affine.load %41[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            %60 = arith.cmpf "olt", %59, %cst_0 : f32
            %61 = select %60, %cst_0, %59 : f32
            affine.store %61, %40[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
          }
        }
      }
    }
    %44 = "krnl.global"() {name = "arith.constant_1", offset = 6912 : i64, shape = [64, 64, 3, 3]} : () -> memref<64x64x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 34 {
          affine.for %arg4 = 0 to 34 {
            affine.store %cst_0, %39[%arg1, %arg2, %arg3, %arg4] : memref<1x64x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %59 = affine.apply #map5(%arg3)
            %60 = affine.apply #map5(%arg4)
            %61 = affine.load %40[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            affine.store %61, %39[%arg1, %arg2, %59, %60] : memref<1x64x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            affine.store %cst_0, %38[%arg1, %arg2, %arg3, %arg4] : memref<1x64x16x16xf32>
            affine.for %arg5 = 0 to 64 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %59 = affine.apply #map9(%arg3, %arg6)
                  %60 = affine.apply #map9(%arg4, %arg7)
                  %61 = affine.load %39[%arg1, %arg5, %59, %60] : memref<1x64x34x34xf32>
                  %62 = affine.load %44[%arg2, %arg5, %arg6, %arg7] : memref<64x64x3x3xf32>
                  %63 = affine.load %38[%arg1, %arg2, %arg3, %arg4] : memref<1x64x16x16xf32>
                  %64 = arith.mulf %61, %62 : f32
                  %65 = arith.addf %63, %64 : f32
                  affine.store %65, %38[%arg1, %arg2, %arg3, %arg4] : memref<1x64x16x16xf32>
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
            %59 = affine.load %38[%arg1, %arg2, %arg3, %arg4] : memref<1x64x16x16xf32>
            %60 = arith.cmpf "olt", %59, %cst_0 : f32
            %61 = select %60, %cst_0, %59 : f32
            affine.store %61, %37[%arg1, %arg2, %arg3, %arg4] : memref<1x64x16x16xf32>
          }
        }
      }
    }
    %45 = "krnl.global"() {name = "arith.constant_2", offset = 154368 : i64, shape = [128, 64, 3, 3]} : () -> memref<128x64x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 18 {
          affine.for %arg4 = 0 to 18 {
            affine.store %cst_0, %36[%arg1, %arg2, %arg3, %arg4] : memref<1x64x18x18xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %59 = affine.apply #map5(%arg3)
            %60 = affine.apply #map5(%arg4)
            %61 = affine.load %37[%arg1, %arg2, %arg3, %arg4] : memref<1x64x16x16xf32>
            affine.store %61, %36[%arg1, %arg2, %59, %60] : memref<1x64x18x18xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            affine.store %cst_0, %35[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            affine.for %arg5 = 0 to 64 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %59 = affine.apply #map7(%arg3, %arg6)
                  %60 = affine.apply #map7(%arg4, %arg7)
                  %61 = affine.load %36[%arg1, %arg5, %59, %60] : memref<1x64x18x18xf32>
                  %62 = affine.load %45[%arg2, %arg5, %arg6, %arg7] : memref<128x64x3x3xf32>
                  %63 = affine.load %35[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
                  %64 = arith.mulf %61, %62 : f32
                  %65 = arith.addf %63, %64 : f32
                  affine.store %65, %35[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
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
            %59 = affine.load %35[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            %60 = arith.cmpf "olt", %59, %cst_0 : f32
            %61 = select %60, %cst_0, %59 : f32
            affine.store %61, %34[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
          }
        }
      }
    }
    %46 = "krnl.global"() {name = "arith.constant_3", offset = 449280 : i64, shape = [128, 128, 3, 3]} : () -> memref<128x128x3x3xf32>
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
            %59 = affine.apply #map5(%arg3)
            %60 = affine.apply #map5(%arg4)
            %61 = affine.load %34[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            affine.store %61, %33[%arg1, %arg2, %59, %60] : memref<1x128x18x18xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_0, %32[%arg1, %arg2, %arg3, %arg4] : memref<1x128x8x8xf32>
            affine.for %arg5 = 0 to 128 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %59 = affine.apply #map9(%arg3, %arg6)
                  %60 = affine.apply #map9(%arg4, %arg7)
                  %61 = affine.load %33[%arg1, %arg5, %59, %60] : memref<1x128x18x18xf32>
                  %62 = affine.load %46[%arg2, %arg5, %arg6, %arg7] : memref<128x128x3x3xf32>
                  %63 = affine.load %32[%arg1, %arg2, %arg3, %arg4] : memref<1x128x8x8xf32>
                  %64 = arith.mulf %61, %62 : f32
                  %65 = arith.addf %63, %64 : f32
                  affine.store %65, %32[%arg1, %arg2, %arg3, %arg4] : memref<1x128x8x8xf32>
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
            %59 = affine.load %32[%arg1, %arg2, %arg3, %arg4] : memref<1x128x8x8xf32>
            %60 = arith.cmpf "olt", %59, %cst_0 : f32
            %61 = select %60, %cst_0, %59 : f32
            affine.store %61, %31[%arg1, %arg2, %arg3, %arg4] : memref<1x128x8x8xf32>
          }
        }
      }
    }
    %47 = "krnl.global"() {name = "arith.constant_4", offset = 1039104 : i64, shape = [256, 128, 3, 3]} : () -> memref<256x128x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 10 {
          affine.for %arg4 = 0 to 10 {
            affine.store %cst_0, %30[%arg1, %arg2, %arg3, %arg4] : memref<1x128x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %59 = affine.apply #map5(%arg3)
            %60 = affine.apply #map5(%arg4)
            %61 = affine.load %31[%arg1, %arg2, %arg3, %arg4] : memref<1x128x8x8xf32>
            affine.store %61, %30[%arg1, %arg2, %59, %60] : memref<1x128x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_0, %29[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            affine.for %arg5 = 0 to 128 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %59 = affine.apply #map7(%arg3, %arg6)
                  %60 = affine.apply #map7(%arg4, %arg7)
                  %61 = affine.load %30[%arg1, %arg5, %59, %60] : memref<1x128x10x10xf32>
                  %62 = affine.load %47[%arg2, %arg5, %arg6, %arg7] : memref<256x128x3x3xf32>
                  %63 = affine.load %29[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
                  %64 = arith.mulf %61, %62 : f32
                  %65 = arith.addf %63, %64 : f32
                  affine.store %65, %29[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
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
            %59 = affine.load %29[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            %60 = arith.cmpf "olt", %59, %cst_0 : f32
            %61 = select %60, %cst_0, %59 : f32
            affine.store %61, %28[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
          }
        }
      }
    }
    %48 = "krnl.global"() {name = "arith.constant_5", offset = 2218752 : i64, shape = [256, 256, 3, 3]} : () -> memref<256x256x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 10 {
          affine.for %arg4 = 0 to 10 {
            affine.store %cst_0, %27[%arg1, %arg2, %arg3, %arg4] : memref<1x256x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %59 = affine.apply #map5(%arg3)
            %60 = affine.apply #map5(%arg4)
            %61 = affine.load %28[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            affine.store %61, %27[%arg1, %arg2, %59, %60] : memref<1x256x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_0, %26[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            affine.for %arg5 = 0 to 256 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %59 = affine.apply #map7(%arg3, %arg6)
                  %60 = affine.apply #map7(%arg4, %arg7)
                  %61 = affine.load %27[%arg1, %arg5, %59, %60] : memref<1x256x10x10xf32>
                  %62 = affine.load %48[%arg2, %arg5, %arg6, %arg7] : memref<256x256x3x3xf32>
                  %63 = affine.load %26[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
                  %64 = arith.mulf %61, %62 : f32
                  %65 = arith.addf %63, %64 : f32
                  affine.store %65, %26[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
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
            %59 = affine.load %26[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            %60 = arith.cmpf "olt", %59, %cst_0 : f32
            %61 = select %60, %cst_0, %59 : f32
            affine.store %61, %25[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
          }
        }
      }
    }
    %49 = "krnl.global"() {name = "arith.constant_6", offset = 4578048 : i64, shape = [256, 256, 3, 3]} : () -> memref<256x256x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 10 {
          affine.for %arg4 = 0 to 10 {
            affine.store %cst_0, %24[%arg1, %arg2, %arg3, %arg4] : memref<1x256x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %59 = affine.apply #map5(%arg3)
            %60 = affine.apply #map5(%arg4)
            %61 = affine.load %25[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            affine.store %61, %24[%arg1, %arg2, %59, %60] : memref<1x256x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_0, %23[%arg1, %arg2, %arg3, %arg4] : memref<1x256x4x4xf32>
            affine.for %arg5 = 0 to 256 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %59 = affine.apply #map9(%arg3, %arg6)
                  %60 = affine.apply #map9(%arg4, %arg7)
                  %61 = affine.load %24[%arg1, %arg5, %59, %60] : memref<1x256x10x10xf32>
                  %62 = affine.load %49[%arg2, %arg5, %arg6, %arg7] : memref<256x256x3x3xf32>
                  %63 = affine.load %23[%arg1, %arg2, %arg3, %arg4] : memref<1x256x4x4xf32>
                  %64 = arith.mulf %61, %62 : f32
                  %65 = arith.addf %63, %64 : f32
                  affine.store %65, %23[%arg1, %arg2, %arg3, %arg4] : memref<1x256x4x4xf32>
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
            %59 = affine.load %23[%arg1, %arg2, %arg3, %arg4] : memref<1x256x4x4xf32>
            %60 = arith.cmpf "olt", %59, %cst_0 : f32
            %61 = select %60, %cst_0, %59 : f32
            affine.store %61, %22[%arg1, %arg2, %arg3, %arg4] : memref<1x256x4x4xf32>
          }
        }
      }
    }
    %50 = "krnl.global"() {name = "arith.constant_7", offset = 6937344 : i64, shape = [512, 256, 3, 3]} : () -> memref<512x256x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 6 {
          affine.for %arg4 = 0 to 6 {
            affine.store %cst_0, %21[%arg1, %arg2, %arg3, %arg4] : memref<1x256x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %59 = affine.apply #map5(%arg3)
            %60 = affine.apply #map5(%arg4)
            %61 = affine.load %22[%arg1, %arg2, %arg3, %arg4] : memref<1x256x4x4xf32>
            affine.store %61, %21[%arg1, %arg2, %59, %60] : memref<1x256x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_0, %20[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.for %arg5 = 0 to 256 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %59 = affine.apply #map7(%arg3, %arg6)
                  %60 = affine.apply #map7(%arg4, %arg7)
                  %61 = affine.load %21[%arg1, %arg5, %59, %60] : memref<1x256x6x6xf32>
                  %62 = affine.load %50[%arg2, %arg5, %arg6, %arg7] : memref<512x256x3x3xf32>
                  %63 = affine.load %20[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                  %64 = arith.mulf %61, %62 : f32
                  %65 = arith.addf %63, %64 : f32
                  affine.store %65, %20[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
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
            %59 = affine.load %20[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %60 = arith.cmpf "olt", %59, %cst_0 : f32
            %61 = select %60, %cst_0, %59 : f32
            affine.store %61, %19[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    %51 = "krnl.global"() {name = "arith.constant_8", offset = 11655936 : i64, shape = [512, 512, 3, 3]} : () -> memref<512x512x3x3xf32>
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
            %59 = affine.apply #map5(%arg3)
            %60 = affine.apply #map5(%arg4)
            %61 = affine.load %19[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.store %61, %18[%arg1, %arg2, %59, %60] : memref<1x512x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_0, %17[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.for %arg5 = 0 to 512 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %59 = affine.apply #map7(%arg3, %arg6)
                  %60 = affine.apply #map7(%arg4, %arg7)
                  %61 = affine.load %18[%arg1, %arg5, %59, %60] : memref<1x512x6x6xf32>
                  %62 = affine.load %51[%arg2, %arg5, %arg6, %arg7] : memref<512x512x3x3xf32>
                  %63 = affine.load %17[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                  %64 = arith.mulf %61, %62 : f32
                  %65 = arith.addf %63, %64 : f32
                  affine.store %65, %17[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
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
            %59 = affine.load %17[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %60 = arith.cmpf "olt", %59, %cst_0 : f32
            %61 = select %60, %cst_0, %59 : f32
            affine.store %61, %16[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    %52 = "krnl.global"() {name = "arith.constant_9", offset = 21093120 : i64, shape = [512, 512, 3, 3]} : () -> memref<512x512x3x3xf32>
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
            %59 = affine.apply #map5(%arg3)
            %60 = affine.apply #map5(%arg4)
            %61 = affine.load %16[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.store %61, %15[%arg1, %arg2, %59, %60] : memref<1x512x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            affine.store %cst_0, %14[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            affine.for %arg5 = 0 to 512 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %59 = affine.apply #map9(%arg3, %arg6)
                  %60 = affine.apply #map9(%arg4, %arg7)
                  %61 = affine.load %15[%arg1, %arg5, %59, %60] : memref<1x512x6x6xf32>
                  %62 = affine.load %52[%arg2, %arg5, %arg6, %arg7] : memref<512x512x3x3xf32>
                  %63 = affine.load %14[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
                  %64 = arith.mulf %61, %62 : f32
                  %65 = arith.addf %63, %64 : f32
                  affine.store %65, %14[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
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
            %59 = affine.load %14[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            %60 = arith.cmpf "olt", %59, %cst_0 : f32
            %61 = select %60, %cst_0, %59 : f32
            affine.store %61, %13[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
          }
        }
      }
    }
    %53 = "krnl.global"() {name = "arith.constant_10", offset = 30530304 : i64, shape = [512, 512, 3, 3]} : () -> memref<512x512x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_0, %12[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            %59 = affine.apply #map5(%arg3)
            %60 = affine.apply #map5(%arg4)
            %61 = affine.load %13[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            affine.store %61, %12[%arg1, %arg2, %59, %60] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            affine.store %cst_0, %11[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            affine.for %arg5 = 0 to 512 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %59 = affine.apply #map7(%arg3, %arg6)
                  %60 = affine.apply #map7(%arg4, %arg7)
                  %61 = affine.load %12[%arg1, %arg5, %59, %60] : memref<1x512x4x4xf32>
                  %62 = affine.load %53[%arg2, %arg5, %arg6, %arg7] : memref<512x512x3x3xf32>
                  %63 = affine.load %11[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
                  %64 = arith.mulf %61, %62 : f32
                  %65 = arith.addf %63, %64 : f32
                  affine.store %65, %11[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
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
            %59 = affine.load %11[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            %60 = arith.cmpf "olt", %59, %cst_0 : f32
            %61 = select %60, %cst_0, %59 : f32
            affine.store %61, %10[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
          }
        }
      }
    }
    %54 = "krnl.global"() {name = "arith.constant_11", offset = 39967488 : i64, shape = [512, 512, 3, 3]} : () -> memref<512x512x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_0, %9[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            %59 = affine.apply #map5(%arg3)
            %60 = affine.apply #map5(%arg4)
            %61 = affine.load %10[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            affine.store %61, %9[%arg1, %arg2, %59, %60] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            affine.store %cst_0, %8[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            affine.for %arg5 = 0 to 512 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %59 = affine.apply #map7(%arg3, %arg6)
                  %60 = affine.apply #map7(%arg4, %arg7)
                  %61 = affine.load %9[%arg1, %arg5, %59, %60] : memref<1x512x4x4xf32>
                  %62 = affine.load %54[%arg2, %arg5, %arg6, %arg7] : memref<512x512x3x3xf32>
                  %63 = affine.load %8[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
                  %64 = arith.mulf %61, %62 : f32
                  %65 = arith.addf %63, %64 : f32
                  affine.store %65, %8[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
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
            %59 = affine.load %8[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            %60 = arith.cmpf "olt", %59, %cst_0 : f32
            %61 = select %60, %cst_0, %59 : f32
            affine.store %61, %7[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
          }
        }
      }
    }
    %55 = "krnl.global"() {name = "arith.constant_12", offset = 49404672 : i64, shape = [512, 512, 3, 3]} : () -> memref<512x512x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_0, %6[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            %59 = affine.apply #map5(%arg3)
            %60 = affine.apply #map5(%arg4)
            %61 = affine.load %7[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            affine.store %61, %6[%arg1, %arg2, %59, %60] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 1 {
          affine.for %arg4 = 0 to 1 {
            affine.store %cst_0, %5[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
            affine.for %arg5 = 0 to 512 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %59 = affine.apply #map9(%arg3, %arg6)
                  %60 = affine.apply #map9(%arg4, %arg7)
                  %61 = affine.load %6[%arg1, %arg5, %59, %60] : memref<1x512x4x4xf32>
                  %62 = affine.load %55[%arg2, %arg5, %arg6, %arg7] : memref<512x512x3x3xf32>
                  %63 = affine.load %5[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
                  %64 = arith.mulf %61, %62 : f32
                  %65 = arith.addf %63, %64 : f32
                  affine.store %65, %5[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 1 {
          affine.for %arg4 = 0 to 1 {
            %59 = affine.load %5[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
            %60 = arith.cmpf "olt", %59, %cst_0 : f32
            %61 = select %60, %cst_0, %59 : f32
            affine.store %61, %4[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
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
        affine.for %arg3 = 0 to 1 {
          affine.for %arg4 = 0 to 1 {
            %59 = affine.load %4[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
            %60 = affine.load %3[%arg1, %arg2, %c0, %c0] : memref<1x512x1x1xf32>
            %61 = arith.addf %60, %59 : f32
            affine.store %61, %3[%arg1, %arg2, %c0, %c0] : memref<1x512x1x1xf32>
          }
        }
      }
    }
    %56 = arith.uitofp %c1_i64 : i64 to f32
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 1 {
          affine.for %arg4 = 0 to 1 {
            %59 = affine.load %3[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
            %60 = arith.divf %59, %56 : f32
            affine.store %60, %3[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 1 {
          affine.for %arg4 = 0 to 1 {
            %59 = affine.load %3[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
            %60 = affine.apply #map20(%arg2, %arg3, %arg4)[%c512, %c1, %c1]
            affine.store %59, %2[%arg1, %60] : memref<1x512xf32>
          }
        }
      }
    }
    %57 = "krnl.global"() {name = "arith.constant_13", offset = 58841856 : i64, shape = [10, 512]} : () -> memref<10x512xf32>
    %58 = "krnl.global"() {name = "arith.constant_14", offset = 58862336 : i64, shape = [10], value = dense<[-0.0237901043, -0.0245888866, -0.0121503044, 0.0312467664, -0.0380312204, 0.0233059153, -0.0163965411, 0.0233793724, -0.0315366313, 0.0359465145]> : tensor<10xf32>} : () -> memref<10xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 10 {
        affine.store %cst_0, %1[%arg1, %arg2] : memref<1x10xf32>
        affine.for %arg3 = 0 to 512 {
          %64 = affine.load %2[%arg1, %arg3] : memref<1x512xf32>
          %65 = affine.load %57[%arg2, %arg3] : memref<10x512xf32>
          %66 = affine.load %1[%arg1, %arg2] : memref<1x10xf32>
          %67 = arith.mulf %64, %65 : f32
          %68 = arith.addf %66, %67 : f32
          affine.store %68, %1[%arg1, %arg2] : memref<1x10xf32>
        }
        %59 = affine.load %1[%arg1, %arg2] : memref<1x10xf32>
        %60 = arith.mulf %cst, %59 : f32
        %61 = affine.load %58[%arg2] : memref<10xf32>
        %62 = arith.mulf %cst, %61 : f32
        %63 = arith.addf %60, %62 : f32
        affine.store %63, %1[%arg1, %arg2] : memref<1x10xf32>
      }
    }
    memref.dealloc %42 : memref<1x3x34x34xf32>
    memref.dealloc %41 : memref<1x64x32x32xf32>
    memref.dealloc %40 : memref<1x64x32x32xf32>
    memref.dealloc %39 : memref<1x64x34x34xf32>
    memref.dealloc %38 : memref<1x64x16x16xf32>
    memref.dealloc %37 : memref<1x64x16x16xf32>
    memref.dealloc %36 : memref<1x64x18x18xf32>
    memref.dealloc %35 : memref<1x128x16x16xf32>
    memref.dealloc %34 : memref<1x128x16x16xf32>
    memref.dealloc %33 : memref<1x128x18x18xf32>
    memref.dealloc %32 : memref<1x128x8x8xf32>
    memref.dealloc %31 : memref<1x128x8x8xf32>
    memref.dealloc %30 : memref<1x128x10x10xf32>
    memref.dealloc %29 : memref<1x256x8x8xf32>
    memref.dealloc %28 : memref<1x256x8x8xf32>
    memref.dealloc %27 : memref<1x256x10x10xf32>
    memref.dealloc %26 : memref<1x256x8x8xf32>
    memref.dealloc %25 : memref<1x256x8x8xf32>
    memref.dealloc %24 : memref<1x256x10x10xf32>
    memref.dealloc %23 : memref<1x256x4x4xf32>
    memref.dealloc %22 : memref<1x256x4x4xf32>
    memref.dealloc %21 : memref<1x256x6x6xf32>
    memref.dealloc %20 : memref<1x512x4x4xf32>
    memref.dealloc %19 : memref<1x512x4x4xf32>
    memref.dealloc %18 : memref<1x512x6x6xf32>
    memref.dealloc %17 : memref<1x512x4x4xf32>
    memref.dealloc %16 : memref<1x512x4x4xf32>
    memref.dealloc %15 : memref<1x512x6x6xf32>
    memref.dealloc %14 : memref<1x512x2x2xf32>
    memref.dealloc %13 : memref<1x512x2x2xf32>
    memref.dealloc %12 : memref<1x512x4x4xf32>
    memref.dealloc %11 : memref<1x512x2x2xf32>
    memref.dealloc %10 : memref<1x512x2x2xf32>
    memref.dealloc %9 : memref<1x512x4x4xf32>
    memref.dealloc %8 : memref<1x512x2x2xf32>
    memref.dealloc %7 : memref<1x512x2x2xf32>
    memref.dealloc %6 : memref<1x512x4x4xf32>
    memref.dealloc %5 : memref<1x512x1x1xf32>
    memref.dealloc %4 : memref<1x512x1x1xf32>
    memref.dealloc %3 : memref<1x512x1x1xf32>
    memref.dealloc %2 : memref<1x512xf32>
    return %1 : memref<1x10xf32>
  }
  "krnl.entry_point"() {func = @main_graph, numInputs = 1 : i32, numOutputs = 1 : i32} : () -> ()
}
