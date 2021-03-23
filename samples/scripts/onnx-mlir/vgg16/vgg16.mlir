#map0 = affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>
#map1 = affine_map<() -> (0)>
#map2 = affine_map<() -> (34)>
#map3 = affine_map<() -> (3)>
#map4 = affine_map<() -> (1)>
#map5 = affine_map<(d0) -> (d0 + 1)>
#map6 = affine_map<() -> (32)>
#map7 = affine_map<(d0, d1) -> (d0 + d1)>
#map8 = affine_map<(d0) -> (d0)>
#map9 = affine_map<() -> (64)>
#map10 = affine_map<(d0, d1) -> (d0 * 2 + d1)>
#map11 = affine_map<() -> (16)>
#map12 = affine_map<() -> (18)>
#map13 = affine_map<() -> (128)>
#map14 = affine_map<() -> (8)>
#map15 = affine_map<() -> (10)>
#map16 = affine_map<() -> (256)>
#map17 = affine_map<() -> (4)>
#map18 = affine_map<() -> (6)>
#map19 = affine_map<() -> (512)>
#map20 = affine_map<() -> (2)>
#map21 = affine_map<(d0, d1, d2)[s0, s1, s2] -> (d2 + d1 * s2 + d0 * (s1 * s2))>
#map22 = affine_map<(d0, d1) -> (d0, d1)>
module {
  %0 = "krnl.packed_const"() {file_name = "/tmp/packed_const-a2b20e.tmp", is_le = true, size_in_bytes = 58879232 : i64} : () -> i64
  func @main_graph(%arg0: memref<1x3x32x32xf32>) -> memref<1x10xf32> attributes {input_names = ["input.1"], output_names = ["57"]} {
    %c0 = constant 0 : index
    %c1_i64 = constant 1 : i64
    %c512 = constant 512 : index
    %c1 = constant 1 : index
    %cst = constant 1.000000e+00 : f32
    %cst_0 = constant 0.000000e+00 : f32
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
    %43 = "krnl.global"() {name = "constant_0", offset = 0 : i64, shape = [64, 3, 3, 3]} : () -> memref<64x3x3x3xf32>
    %44 = "krnl.global"() {name = "constant_1", offset = 6912 : i64, shape = [64]} : () -> memref<64xf32>
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
            %72 = affine.apply #map5(%arg3)
            %73 = affine.apply #map5(%arg4)
            %74 = affine.load %arg0[%arg1, %arg2, %arg3, %arg4] : memref<1x3x32x32xf32>
            affine.store %74, %42[%arg1, %arg2, %72, %73] : memref<1x3x34x34xf32>
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
                  %75 = affine.apply #map7(%arg3, %arg6)
                  %76 = affine.apply #map7(%arg4, %arg7)
                  %77 = affine.load %42[%arg1, %arg5, %75, %76] : memref<1x3x34x34xf32>
                  %78 = affine.load %43[%arg2, %arg5, %arg6, %arg7] : memref<64x3x3x3xf32>
                  %79 = affine.load %41[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
                  %80 = mulf %77, %78 : f32
                  %81 = addf %79, %80 : f32
                  affine.store %81, %41[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
                }
              }
            }
            %72 = affine.load %41[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            %73 = affine.load %44[%arg2] : memref<64xf32>
            %74 = addf %72, %73 : f32
            affine.store %74, %41[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %72 = affine.load %41[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            %73 = cmpf "olt", %72, %cst_0 : f32
            %74 = select %73, %cst_0, %72 : f32
            affine.store %74, %40[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
          }
        }
      }
    }
    %45 = "krnl.global"() {name = "constant_2", offset = 7168 : i64, shape = [64, 64, 3, 3]} : () -> memref<64x64x3x3xf32>
    %46 = "krnl.global"() {name = "constant_3", offset = 154624 : i64, shape = [64]} : () -> memref<64xf32>
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
            %72 = affine.apply #map5(%arg3)
            %73 = affine.apply #map5(%arg4)
            %74 = affine.load %40[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            affine.store %74, %39[%arg1, %arg2, %72, %73] : memref<1x64x34x34xf32>
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
                  %75 = affine.apply #map10(%arg3, %arg6)
                  %76 = affine.apply #map10(%arg4, %arg7)
                  %77 = affine.load %39[%arg1, %arg5, %75, %76] : memref<1x64x34x34xf32>
                  %78 = affine.load %45[%arg2, %arg5, %arg6, %arg7] : memref<64x64x3x3xf32>
                  %79 = affine.load %38[%arg1, %arg2, %arg3, %arg4] : memref<1x64x16x16xf32>
                  %80 = mulf %77, %78 : f32
                  %81 = addf %79, %80 : f32
                  affine.store %81, %38[%arg1, %arg2, %arg3, %arg4] : memref<1x64x16x16xf32>
                }
              }
            }
            %72 = affine.load %38[%arg1, %arg2, %arg3, %arg4] : memref<1x64x16x16xf32>
            %73 = affine.load %46[%arg2] : memref<64xf32>
            %74 = addf %72, %73 : f32
            affine.store %74, %38[%arg1, %arg2, %arg3, %arg4] : memref<1x64x16x16xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %72 = affine.load %38[%arg1, %arg2, %arg3, %arg4] : memref<1x64x16x16xf32>
            %73 = cmpf "olt", %72, %cst_0 : f32
            %74 = select %73, %cst_0, %72 : f32
            affine.store %74, %37[%arg1, %arg2, %arg3, %arg4] : memref<1x64x16x16xf32>
          }
        }
      }
    }
    %47 = "krnl.global"() {name = "constant_4", offset = 154880 : i64, shape = [128, 64, 3, 3]} : () -> memref<128x64x3x3xf32>
    %48 = "krnl.global"() {name = "constant_5", offset = 449792 : i64, shape = [128]} : () -> memref<128xf32>
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
            %72 = affine.apply #map5(%arg3)
            %73 = affine.apply #map5(%arg4)
            %74 = affine.load %37[%arg1, %arg2, %arg3, %arg4] : memref<1x64x16x16xf32>
            affine.store %74, %36[%arg1, %arg2, %72, %73] : memref<1x64x18x18xf32>
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
                  %75 = affine.apply #map7(%arg3, %arg6)
                  %76 = affine.apply #map7(%arg4, %arg7)
                  %77 = affine.load %36[%arg1, %arg5, %75, %76] : memref<1x64x18x18xf32>
                  %78 = affine.load %47[%arg2, %arg5, %arg6, %arg7] : memref<128x64x3x3xf32>
                  %79 = affine.load %35[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
                  %80 = mulf %77, %78 : f32
                  %81 = addf %79, %80 : f32
                  affine.store %81, %35[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
                }
              }
            }
            %72 = affine.load %35[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            %73 = affine.load %48[%arg2] : memref<128xf32>
            %74 = addf %72, %73 : f32
            affine.store %74, %35[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %72 = affine.load %35[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            %73 = cmpf "olt", %72, %cst_0 : f32
            %74 = select %73, %cst_0, %72 : f32
            affine.store %74, %34[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
          }
        }
      }
    }
    %49 = "krnl.global"() {name = "constant_6", offset = 450304 : i64, shape = [128, 128, 3, 3]} : () -> memref<128x128x3x3xf32>
    %50 = "krnl.global"() {name = "constant_7", offset = 1040128 : i64, shape = [128]} : () -> memref<128xf32>
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
            %72 = affine.apply #map5(%arg3)
            %73 = affine.apply #map5(%arg4)
            %74 = affine.load %34[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            affine.store %74, %33[%arg1, %arg2, %72, %73] : memref<1x128x18x18xf32>
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
                  %75 = affine.apply #map10(%arg3, %arg6)
                  %76 = affine.apply #map10(%arg4, %arg7)
                  %77 = affine.load %33[%arg1, %arg5, %75, %76] : memref<1x128x18x18xf32>
                  %78 = affine.load %49[%arg2, %arg5, %arg6, %arg7] : memref<128x128x3x3xf32>
                  %79 = affine.load %32[%arg1, %arg2, %arg3, %arg4] : memref<1x128x8x8xf32>
                  %80 = mulf %77, %78 : f32
                  %81 = addf %79, %80 : f32
                  affine.store %81, %32[%arg1, %arg2, %arg3, %arg4] : memref<1x128x8x8xf32>
                }
              }
            }
            %72 = affine.load %32[%arg1, %arg2, %arg3, %arg4] : memref<1x128x8x8xf32>
            %73 = affine.load %50[%arg2] : memref<128xf32>
            %74 = addf %72, %73 : f32
            affine.store %74, %32[%arg1, %arg2, %arg3, %arg4] : memref<1x128x8x8xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %72 = affine.load %32[%arg1, %arg2, %arg3, %arg4] : memref<1x128x8x8xf32>
            %73 = cmpf "olt", %72, %cst_0 : f32
            %74 = select %73, %cst_0, %72 : f32
            affine.store %74, %31[%arg1, %arg2, %arg3, %arg4] : memref<1x128x8x8xf32>
          }
        }
      }
    }
    %51 = "krnl.global"() {name = "constant_8", offset = 1040640 : i64, shape = [256, 128, 3, 3]} : () -> memref<256x128x3x3xf32>
    %52 = "krnl.global"() {name = "constant_9", offset = 2220288 : i64, shape = [256]} : () -> memref<256xf32>
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
            %72 = affine.apply #map5(%arg3)
            %73 = affine.apply #map5(%arg4)
            %74 = affine.load %31[%arg1, %arg2, %arg3, %arg4] : memref<1x128x8x8xf32>
            affine.store %74, %30[%arg1, %arg2, %72, %73] : memref<1x128x10x10xf32>
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
                  %75 = affine.apply #map7(%arg3, %arg6)
                  %76 = affine.apply #map7(%arg4, %arg7)
                  %77 = affine.load %30[%arg1, %arg5, %75, %76] : memref<1x128x10x10xf32>
                  %78 = affine.load %51[%arg2, %arg5, %arg6, %arg7] : memref<256x128x3x3xf32>
                  %79 = affine.load %29[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
                  %80 = mulf %77, %78 : f32
                  %81 = addf %79, %80 : f32
                  affine.store %81, %29[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
                }
              }
            }
            %72 = affine.load %29[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            %73 = affine.load %52[%arg2] : memref<256xf32>
            %74 = addf %72, %73 : f32
            affine.store %74, %29[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %72 = affine.load %29[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            %73 = cmpf "olt", %72, %cst_0 : f32
            %74 = select %73, %cst_0, %72 : f32
            affine.store %74, %28[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
          }
        }
      }
    }
    %53 = "krnl.global"() {name = "constant_10", offset = 2221312 : i64, shape = [256, 256, 3, 3]} : () -> memref<256x256x3x3xf32>
    %54 = "krnl.global"() {name = "constant_11", offset = 4580608 : i64, shape = [256]} : () -> memref<256xf32>
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
            %72 = affine.apply #map5(%arg3)
            %73 = affine.apply #map5(%arg4)
            %74 = affine.load %28[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            affine.store %74, %27[%arg1, %arg2, %72, %73] : memref<1x256x10x10xf32>
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
                  %75 = affine.apply #map7(%arg3, %arg6)
                  %76 = affine.apply #map7(%arg4, %arg7)
                  %77 = affine.load %27[%arg1, %arg5, %75, %76] : memref<1x256x10x10xf32>
                  %78 = affine.load %53[%arg2, %arg5, %arg6, %arg7] : memref<256x256x3x3xf32>
                  %79 = affine.load %26[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
                  %80 = mulf %77, %78 : f32
                  %81 = addf %79, %80 : f32
                  affine.store %81, %26[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
                }
              }
            }
            %72 = affine.load %26[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            %73 = affine.load %54[%arg2] : memref<256xf32>
            %74 = addf %72, %73 : f32
            affine.store %74, %26[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %72 = affine.load %26[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            %73 = cmpf "olt", %72, %cst_0 : f32
            %74 = select %73, %cst_0, %72 : f32
            affine.store %74, %25[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
          }
        }
      }
    }
    %55 = "krnl.global"() {name = "constant_12", offset = 4581632 : i64, shape = [256, 256, 3, 3]} : () -> memref<256x256x3x3xf32>
    %56 = "krnl.global"() {name = "constant_13", offset = 6940928 : i64, shape = [256]} : () -> memref<256xf32>
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
            %72 = affine.apply #map5(%arg3)
            %73 = affine.apply #map5(%arg4)
            %74 = affine.load %25[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            affine.store %74, %24[%arg1, %arg2, %72, %73] : memref<1x256x10x10xf32>
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
                  %75 = affine.apply #map10(%arg3, %arg6)
                  %76 = affine.apply #map10(%arg4, %arg7)
                  %77 = affine.load %24[%arg1, %arg5, %75, %76] : memref<1x256x10x10xf32>
                  %78 = affine.load %55[%arg2, %arg5, %arg6, %arg7] : memref<256x256x3x3xf32>
                  %79 = affine.load %23[%arg1, %arg2, %arg3, %arg4] : memref<1x256x4x4xf32>
                  %80 = mulf %77, %78 : f32
                  %81 = addf %79, %80 : f32
                  affine.store %81, %23[%arg1, %arg2, %arg3, %arg4] : memref<1x256x4x4xf32>
                }
              }
            }
            %72 = affine.load %23[%arg1, %arg2, %arg3, %arg4] : memref<1x256x4x4xf32>
            %73 = affine.load %56[%arg2] : memref<256xf32>
            %74 = addf %72, %73 : f32
            affine.store %74, %23[%arg1, %arg2, %arg3, %arg4] : memref<1x256x4x4xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %72 = affine.load %23[%arg1, %arg2, %arg3, %arg4] : memref<1x256x4x4xf32>
            %73 = cmpf "olt", %72, %cst_0 : f32
            %74 = select %73, %cst_0, %72 : f32
            affine.store %74, %22[%arg1, %arg2, %arg3, %arg4] : memref<1x256x4x4xf32>
          }
        }
      }
    }
    %57 = "krnl.global"() {name = "constant_14", offset = 6941952 : i64, shape = [512, 256, 3, 3]} : () -> memref<512x256x3x3xf32>
    %58 = "krnl.global"() {name = "constant_15", offset = 11660544 : i64, shape = [512]} : () -> memref<512xf32>
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
            %72 = affine.apply #map5(%arg3)
            %73 = affine.apply #map5(%arg4)
            %74 = affine.load %22[%arg1, %arg2, %arg3, %arg4] : memref<1x256x4x4xf32>
            affine.store %74, %21[%arg1, %arg2, %72, %73] : memref<1x256x6x6xf32>
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
                  %75 = affine.apply #map7(%arg3, %arg6)
                  %76 = affine.apply #map7(%arg4, %arg7)
                  %77 = affine.load %21[%arg1, %arg5, %75, %76] : memref<1x256x6x6xf32>
                  %78 = affine.load %57[%arg2, %arg5, %arg6, %arg7] : memref<512x256x3x3xf32>
                  %79 = affine.load %20[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                  %80 = mulf %77, %78 : f32
                  %81 = addf %79, %80 : f32
                  affine.store %81, %20[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                }
              }
            }
            %72 = affine.load %20[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %73 = affine.load %58[%arg2] : memref<512xf32>
            %74 = addf %72, %73 : f32
            affine.store %74, %20[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %72 = affine.load %20[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %73 = cmpf "olt", %72, %cst_0 : f32
            %74 = select %73, %cst_0, %72 : f32
            affine.store %74, %19[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    %59 = "krnl.global"() {name = "constant_16", offset = 11662592 : i64, shape = [512, 512, 3, 3]} : () -> memref<512x512x3x3xf32>
    %60 = "krnl.global"() {name = "constant_17", offset = 21099776 : i64, shape = [512]} : () -> memref<512xf32>
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
            %72 = affine.apply #map5(%arg3)
            %73 = affine.apply #map5(%arg4)
            %74 = affine.load %19[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.store %74, %18[%arg1, %arg2, %72, %73] : memref<1x512x6x6xf32>
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
                  %75 = affine.apply #map7(%arg3, %arg6)
                  %76 = affine.apply #map7(%arg4, %arg7)
                  %77 = affine.load %18[%arg1, %arg5, %75, %76] : memref<1x512x6x6xf32>
                  %78 = affine.load %59[%arg2, %arg5, %arg6, %arg7] : memref<512x512x3x3xf32>
                  %79 = affine.load %17[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                  %80 = mulf %77, %78 : f32
                  %81 = addf %79, %80 : f32
                  affine.store %81, %17[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                }
              }
            }
            %72 = affine.load %17[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %73 = affine.load %60[%arg2] : memref<512xf32>
            %74 = addf %72, %73 : f32
            affine.store %74, %17[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %72 = affine.load %17[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %73 = cmpf "olt", %72, %cst_0 : f32
            %74 = select %73, %cst_0, %72 : f32
            affine.store %74, %16[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    %61 = "krnl.global"() {name = "constant_18", offset = 21101824 : i64, shape = [512, 512, 3, 3]} : () -> memref<512x512x3x3xf32>
    %62 = "krnl.global"() {name = "constant_19", offset = 30539008 : i64, shape = [512]} : () -> memref<512xf32>
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
            %72 = affine.apply #map5(%arg3)
            %73 = affine.apply #map5(%arg4)
            %74 = affine.load %16[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.store %74, %15[%arg1, %arg2, %72, %73] : memref<1x512x6x6xf32>
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
                  %75 = affine.apply #map10(%arg3, %arg6)
                  %76 = affine.apply #map10(%arg4, %arg7)
                  %77 = affine.load %15[%arg1, %arg5, %75, %76] : memref<1x512x6x6xf32>
                  %78 = affine.load %61[%arg2, %arg5, %arg6, %arg7] : memref<512x512x3x3xf32>
                  %79 = affine.load %14[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
                  %80 = mulf %77, %78 : f32
                  %81 = addf %79, %80 : f32
                  affine.store %81, %14[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
                }
              }
            }
            %72 = affine.load %14[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            %73 = affine.load %62[%arg2] : memref<512xf32>
            %74 = addf %72, %73 : f32
            affine.store %74, %14[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            %72 = affine.load %14[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            %73 = cmpf "olt", %72, %cst_0 : f32
            %74 = select %73, %cst_0, %72 : f32
            affine.store %74, %13[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
          }
        }
      }
    }
    %63 = "krnl.global"() {name = "constant_20", offset = 30541056 : i64, shape = [512, 512, 3, 3]} : () -> memref<512x512x3x3xf32>
    %64 = "krnl.global"() {name = "constant_21", offset = 39978240 : i64, shape = [512]} : () -> memref<512xf32>
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
            %72 = affine.apply #map5(%arg3)
            %73 = affine.apply #map5(%arg4)
            %74 = affine.load %13[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            affine.store %74, %12[%arg1, %arg2, %72, %73] : memref<1x512x4x4xf32>
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
                  %75 = affine.apply #map7(%arg3, %arg6)
                  %76 = affine.apply #map7(%arg4, %arg7)
                  %77 = affine.load %12[%arg1, %arg5, %75, %76] : memref<1x512x4x4xf32>
                  %78 = affine.load %63[%arg2, %arg5, %arg6, %arg7] : memref<512x512x3x3xf32>
                  %79 = affine.load %11[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
                  %80 = mulf %77, %78 : f32
                  %81 = addf %79, %80 : f32
                  affine.store %81, %11[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
                }
              }
            }
            %72 = affine.load %11[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            %73 = affine.load %64[%arg2] : memref<512xf32>
            %74 = addf %72, %73 : f32
            affine.store %74, %11[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            %72 = affine.load %11[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            %73 = cmpf "olt", %72, %cst_0 : f32
            %74 = select %73, %cst_0, %72 : f32
            affine.store %74, %10[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
          }
        }
      }
    }
    %65 = "krnl.global"() {name = "constant_22", offset = 39980288 : i64, shape = [512, 512, 3, 3]} : () -> memref<512x512x3x3xf32>
    %66 = "krnl.global"() {name = "constant_23", offset = 49417472 : i64, shape = [512]} : () -> memref<512xf32>
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
            %72 = affine.apply #map5(%arg3)
            %73 = affine.apply #map5(%arg4)
            %74 = affine.load %10[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            affine.store %74, %9[%arg1, %arg2, %72, %73] : memref<1x512x4x4xf32>
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
                  %75 = affine.apply #map7(%arg3, %arg6)
                  %76 = affine.apply #map7(%arg4, %arg7)
                  %77 = affine.load %9[%arg1, %arg5, %75, %76] : memref<1x512x4x4xf32>
                  %78 = affine.load %65[%arg2, %arg5, %arg6, %arg7] : memref<512x512x3x3xf32>
                  %79 = affine.load %8[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
                  %80 = mulf %77, %78 : f32
                  %81 = addf %79, %80 : f32
                  affine.store %81, %8[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
                }
              }
            }
            %72 = affine.load %8[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            %73 = affine.load %66[%arg2] : memref<512xf32>
            %74 = addf %72, %73 : f32
            affine.store %74, %8[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            %72 = affine.load %8[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            %73 = cmpf "olt", %72, %cst_0 : f32
            %74 = select %73, %cst_0, %72 : f32
            affine.store %74, %7[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
          }
        }
      }
    }
    %67 = "krnl.global"() {name = "constant_24", offset = 49419520 : i64, shape = [512, 512, 3, 3]} : () -> memref<512x512x3x3xf32>
    %68 = "krnl.global"() {name = "constant_25", offset = 58856704 : i64, shape = [512]} : () -> memref<512xf32>
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
            %72 = affine.apply #map5(%arg3)
            %73 = affine.apply #map5(%arg4)
            %74 = affine.load %7[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            affine.store %74, %6[%arg1, %arg2, %72, %73] : memref<1x512x4x4xf32>
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
                  %75 = affine.apply #map10(%arg3, %arg6)
                  %76 = affine.apply #map10(%arg4, %arg7)
                  %77 = affine.load %6[%arg1, %arg5, %75, %76] : memref<1x512x4x4xf32>
                  %78 = affine.load %67[%arg2, %arg5, %arg6, %arg7] : memref<512x512x3x3xf32>
                  %79 = affine.load %5[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
                  %80 = mulf %77, %78 : f32
                  %81 = addf %79, %80 : f32
                  affine.store %81, %5[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
                }
              }
            }
            %72 = affine.load %5[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
            %73 = affine.load %68[%arg2] : memref<512xf32>
            %74 = addf %72, %73 : f32
            affine.store %74, %5[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 1 {
          affine.for %arg4 = 0 to 1 {
            %72 = affine.load %5[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
            %73 = cmpf "olt", %72, %cst_0 : f32
            %74 = select %73, %cst_0, %72 : f32
            affine.store %74, %4[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
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
            %72 = affine.load %4[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
            %73 = affine.load %3[%arg1, %arg2, %c0, %c0] : memref<1x512x1x1xf32>
            %74 = addf %73, %72 : f32
            affine.store %74, %3[%arg1, %arg2, %c0, %c0] : memref<1x512x1x1xf32>
          }
        }
      }
    }
    %69 = uitofp %c1_i64 : i64 to f32
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 1 {
          affine.for %arg4 = 0 to 1 {
            %72 = affine.load %3[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
            %73 = divf %72, %69 : f32
            affine.store %73, %3[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 1 {
          affine.for %arg4 = 0 to 1 {
            %72 = affine.load %3[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
            %73 = affine.apply #map21(%arg2, %arg3, %arg4)[%c512, %c1, %c1]
            affine.store %72, %2[%arg1, %73] : memref<1x512xf32>
          }
        }
      }
    }
    %70 = "krnl.global"() {name = "constant_26", offset = 58858752 : i64, shape = [10, 512]} : () -> memref<10x512xf32>
    %71 = "krnl.global"() {name = "constant_27", offset = 58879232 : i64, shape = [10], value = dense<[0.0102181714, 0.0325057395, 0.0397114865, 0.038894169, -0.0212061647, 0.03149065, 0.0205886923, -0.0322133042, -0.0328963362, -0.0439718105]> : tensor<10xf32>} : () -> memref<10xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 10 {
        affine.store %cst_0, %1[%arg1, %arg2] : memref<1x10xf32>
        affine.for %arg3 = 0 to 512 {
          %77 = affine.load %2[%arg1, %arg3] : memref<1x512xf32>
          %78 = affine.load %70[%arg2, %arg3] : memref<10x512xf32>
          %79 = affine.load %1[%arg1, %arg2] : memref<1x10xf32>
          %80 = mulf %77, %78 : f32
          %81 = addf %79, %80 : f32
          affine.store %81, %1[%arg1, %arg2] : memref<1x10xf32>
        }
        %72 = affine.load %1[%arg1, %arg2] : memref<1x10xf32>
        %73 = mulf %cst, %72 : f32
        %74 = affine.load %71[%arg2] : memref<10xf32>
        %75 = mulf %cst, %74 : f32
        %76 = addf %73, %75 : f32
        affine.store %76, %1[%arg1, %arg2] : memref<1x10xf32>
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
