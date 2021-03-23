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
#map10 = affine_map<(d0)[s0, s1, s2, s3, s4] -> (0, d0 * s3 - s2)>
#map11 = affine_map<(d0) -> (32, d0 * -2 + 32, d0 * 2 + 2, 2)>
#map12 = affine_map<() -> (16)>
#map13 = affine_map<() -> (18)>
#map14 = affine_map<() -> (128)>
#map15 = affine_map<(d0) -> (16, d0 * -2 + 16, d0 * 2 + 2, 2)>
#map16 = affine_map<() -> (8)>
#map17 = affine_map<() -> (10)>
#map18 = affine_map<() -> (256)>
#map19 = affine_map<(d0) -> (8, d0 * -2 + 8, d0 * 2 + 2, 2)>
#map20 = affine_map<() -> (4)>
#map21 = affine_map<() -> (6)>
#map22 = affine_map<() -> (512)>
#map23 = affine_map<(d0) -> (4, d0 * -2 + 4, d0 * 2 + 2, 2)>
#map24 = affine_map<() -> (2)>
#map25 = affine_map<(d0) -> (2, d0 * -2 + 2, d0 * 2 + 2, 2)>
#map26 = affine_map<(d0, d1, d2)[s0, s1, s2] -> (d2 + d1 * s2 + d0 * (s1 * s2))>
#map27 = affine_map<(d0, d1) -> (d0, d1)>
module {
  %0 = "krnl.packed_const"() {file_name = "/tmp/packed_const-97f4ba.tmp", is_le = true, size_in_bytes = 36902400 : i64} : () -> i64
  func @main_graph(%arg0: memref<1x3x32x32xf32>) -> memref<1x10xf32> attributes {input_names = ["input.1"], output_names = ["41"]} {
    %c32 = constant 32 : index
    %c16 = constant 16 : index
    %c8 = constant 8 : index
    %c4 = constant 4 : index
    %cst = constant 0xFF800000 : f32
    %c0 = constant 0 : index
    %c2 = constant 2 : index
    %c512 = constant 512 : index
    %c1 = constant 1 : index
    %cst_0 = constant 1.000000e+00 : f32
    %cst_1 = constant 0.000000e+00 : f32
    %1 = memref.alloc() : memref<1x10xf32>
    %2 = memref.alloc() : memref<1x512xf32>
    %3 = memref.alloc() : memref<1x512x1x1xf32>
    %4 = memref.alloc() : memref<1x512x2x2xf32>
    %5 = memref.alloc() : memref<1x512x2x2xf32>
    %6 = memref.alloc() : memref<1x512x4x4xf32>
    %7 = memref.alloc() : memref<1x512x2x2xf32>
    %8 = memref.alloc() : memref<1x512x2x2xf32>
    %9 = memref.alloc() : memref<1x512x4x4xf32>
    %10 = memref.alloc() : memref<1x512x2x2xf32>
    %11 = memref.alloc() : memref<1x512x4x4xf32>
    %12 = memref.alloc() : memref<1x512x4x4xf32>
    %13 = memref.alloc() : memref<1x512x6x6xf32>
    %14 = memref.alloc() : memref<1x512x4x4xf32>
    %15 = memref.alloc() : memref<1x512x4x4xf32>
    %16 = memref.alloc() : memref<1x256x6x6xf32>
    %17 = memref.alloc() : memref<1x256x4x4xf32>
    %18 = memref.alloc() : memref<1x256x8x8xf32>
    %19 = memref.alloc() : memref<1x256x8x8xf32>
    %20 = memref.alloc() : memref<1x256x10x10xf32>
    %21 = memref.alloc() : memref<1x256x8x8xf32>
    %22 = memref.alloc() : memref<1x256x8x8xf32>
    %23 = memref.alloc() : memref<1x128x10x10xf32>
    %24 = memref.alloc() : memref<1x128x8x8xf32>
    %25 = memref.alloc() : memref<1x128x16x16xf32>
    %26 = memref.alloc() : memref<1x128x16x16xf32>
    %27 = memref.alloc() : memref<1x64x18x18xf32>
    %28 = memref.alloc() : memref<1x64x16x16xf32>
    %29 = memref.alloc() : memref<1x64x32x32xf32>
    %30 = memref.alloc() : memref<1x64x32x32xf32>
    %31 = memref.alloc() : memref<1x3x34x34xf32>
    %32 = "krnl.global"() {name = "constant_0", offset = 0 : i64, shape = [64, 3, 3, 3]} : () -> memref<64x3x3x3xf32>
    %33 = "krnl.global"() {name = "constant_1", offset = 6912 : i64, shape = [64]} : () -> memref<64xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 3 {
        affine.for %arg3 = 0 to 34 {
          affine.for %arg4 = 0 to 34 {
            affine.store %cst_1, %31[%arg1, %arg2, %arg3, %arg4] : memref<1x3x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 3 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %50 = affine.apply #map5(%arg3)
            %51 = affine.apply #map5(%arg4)
            %52 = affine.load %arg0[%arg1, %arg2, %arg3, %arg4] : memref<1x3x32x32xf32>
            affine.store %52, %31[%arg1, %arg2, %50, %51] : memref<1x3x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            affine.store %cst_1, %30[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            affine.for %arg5 = 0 to 3 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %53 = affine.apply #map7(%arg3, %arg6)
                  %54 = affine.apply #map7(%arg4, %arg7)
                  %55 = affine.load %31[%arg1, %arg5, %53, %54] : memref<1x3x34x34xf32>
                  %56 = affine.load %32[%arg2, %arg5, %arg6, %arg7] : memref<64x3x3x3xf32>
                  %57 = affine.load %30[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
                  %58 = mulf %55, %56 : f32
                  %59 = addf %57, %58 : f32
                  affine.store %59, %30[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
                }
              }
            }
            %50 = affine.load %30[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            %51 = affine.load %33[%arg2] : memref<64xf32>
            %52 = addf %50, %51 : f32
            affine.store %52, %30[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %50 = affine.load %30[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            %51 = cmpf "olt", %50, %cst_1 : f32
            %52 = select %51, %cst_1, %50 : f32
            affine.store %52, %29[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            affine.store %cst, %28[%arg1, %arg2, %arg3, %arg4] : memref<1x64x16x16xf32>
            %50 = affine.max #map10(%arg3)[%c32, %c2, %c0, %c2, %c1]
            %51 = affine.max #map10(%arg4)[%c32, %c2, %c0, %c2, %c1]
            affine.for %arg5 = 0 to min #map11(%arg3) {
              affine.for %arg6 = 0 to min #map11(%arg4) {
                %52 = addi %arg5, %50 : index
                %53 = addi %arg6, %51 : index
                %54 = memref.load %29[%arg1, %arg2, %52, %53] : memref<1x64x32x32xf32>
                %55 = affine.load %28[%arg1, %arg2, %arg3, %arg4] : memref<1x64x16x16xf32>
                %56 = cmpf "ogt", %55, %54 : f32
                %57 = select %56, %55, %54 : f32
                affine.store %57, %28[%arg1, %arg2, %arg3, %arg4] : memref<1x64x16x16xf32>
              }
            }
          }
        }
      }
    }
    %34 = "krnl.global"() {name = "constant_2", offset = 7168 : i64, shape = [128, 64, 3, 3]} : () -> memref<128x64x3x3xf32>
    %35 = "krnl.global"() {name = "constant_3", offset = 302080 : i64, shape = [128]} : () -> memref<128xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 18 {
          affine.for %arg4 = 0 to 18 {
            affine.store %cst_1, %27[%arg1, %arg2, %arg3, %arg4] : memref<1x64x18x18xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %50 = affine.apply #map5(%arg3)
            %51 = affine.apply #map5(%arg4)
            %52 = affine.load %28[%arg1, %arg2, %arg3, %arg4] : memref<1x64x16x16xf32>
            affine.store %52, %27[%arg1, %arg2, %50, %51] : memref<1x64x18x18xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            affine.store %cst_1, %26[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            affine.for %arg5 = 0 to 64 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %53 = affine.apply #map7(%arg3, %arg6)
                  %54 = affine.apply #map7(%arg4, %arg7)
                  %55 = affine.load %27[%arg1, %arg5, %53, %54] : memref<1x64x18x18xf32>
                  %56 = affine.load %34[%arg2, %arg5, %arg6, %arg7] : memref<128x64x3x3xf32>
                  %57 = affine.load %26[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
                  %58 = mulf %55, %56 : f32
                  %59 = addf %57, %58 : f32
                  affine.store %59, %26[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
                }
              }
            }
            %50 = affine.load %26[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            %51 = affine.load %35[%arg2] : memref<128xf32>
            %52 = addf %50, %51 : f32
            affine.store %52, %26[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %50 = affine.load %26[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            %51 = cmpf "olt", %50, %cst_1 : f32
            %52 = select %51, %cst_1, %50 : f32
            affine.store %52, %25[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst, %24[%arg1, %arg2, %arg3, %arg4] : memref<1x128x8x8xf32>
            %50 = affine.max #map10(%arg3)[%c16, %c2, %c0, %c2, %c1]
            %51 = affine.max #map10(%arg4)[%c16, %c2, %c0, %c2, %c1]
            affine.for %arg5 = 0 to min #map15(%arg3) {
              affine.for %arg6 = 0 to min #map15(%arg4) {
                %52 = addi %arg5, %50 : index
                %53 = addi %arg6, %51 : index
                %54 = memref.load %25[%arg1, %arg2, %52, %53] : memref<1x128x16x16xf32>
                %55 = affine.load %24[%arg1, %arg2, %arg3, %arg4] : memref<1x128x8x8xf32>
                %56 = cmpf "ogt", %55, %54 : f32
                %57 = select %56, %55, %54 : f32
                affine.store %57, %24[%arg1, %arg2, %arg3, %arg4] : memref<1x128x8x8xf32>
              }
            }
          }
        }
      }
    }
    %36 = "krnl.global"() {name = "constant_4", offset = 302592 : i64, shape = [256, 128, 3, 3]} : () -> memref<256x128x3x3xf32>
    %37 = "krnl.global"() {name = "constant_5", offset = 1482240 : i64, shape = [256]} : () -> memref<256xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 10 {
          affine.for %arg4 = 0 to 10 {
            affine.store %cst_1, %23[%arg1, %arg2, %arg3, %arg4] : memref<1x128x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %50 = affine.apply #map5(%arg3)
            %51 = affine.apply #map5(%arg4)
            %52 = affine.load %24[%arg1, %arg2, %arg3, %arg4] : memref<1x128x8x8xf32>
            affine.store %52, %23[%arg1, %arg2, %50, %51] : memref<1x128x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_1, %22[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            affine.for %arg5 = 0 to 128 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %53 = affine.apply #map7(%arg3, %arg6)
                  %54 = affine.apply #map7(%arg4, %arg7)
                  %55 = affine.load %23[%arg1, %arg5, %53, %54] : memref<1x128x10x10xf32>
                  %56 = affine.load %36[%arg2, %arg5, %arg6, %arg7] : memref<256x128x3x3xf32>
                  %57 = affine.load %22[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
                  %58 = mulf %55, %56 : f32
                  %59 = addf %57, %58 : f32
                  affine.store %59, %22[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
                }
              }
            }
            %50 = affine.load %22[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            %51 = affine.load %37[%arg2] : memref<256xf32>
            %52 = addf %50, %51 : f32
            affine.store %52, %22[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %50 = affine.load %22[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            %51 = cmpf "olt", %50, %cst_1 : f32
            %52 = select %51, %cst_1, %50 : f32
            affine.store %52, %21[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
          }
        }
      }
    }
    %38 = "krnl.global"() {name = "constant_6", offset = 1483264 : i64, shape = [256, 256, 3, 3]} : () -> memref<256x256x3x3xf32>
    %39 = "krnl.global"() {name = "constant_7", offset = 3842560 : i64, shape = [256]} : () -> memref<256xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 10 {
          affine.for %arg4 = 0 to 10 {
            affine.store %cst_1, %20[%arg1, %arg2, %arg3, %arg4] : memref<1x256x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %50 = affine.apply #map5(%arg3)
            %51 = affine.apply #map5(%arg4)
            %52 = affine.load %21[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            affine.store %52, %20[%arg1, %arg2, %50, %51] : memref<1x256x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_1, %19[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            affine.for %arg5 = 0 to 256 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %53 = affine.apply #map7(%arg3, %arg6)
                  %54 = affine.apply #map7(%arg4, %arg7)
                  %55 = affine.load %20[%arg1, %arg5, %53, %54] : memref<1x256x10x10xf32>
                  %56 = affine.load %38[%arg2, %arg5, %arg6, %arg7] : memref<256x256x3x3xf32>
                  %57 = affine.load %19[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
                  %58 = mulf %55, %56 : f32
                  %59 = addf %57, %58 : f32
                  affine.store %59, %19[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
                }
              }
            }
            %50 = affine.load %19[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            %51 = affine.load %39[%arg2] : memref<256xf32>
            %52 = addf %50, %51 : f32
            affine.store %52, %19[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %50 = affine.load %19[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            %51 = cmpf "olt", %50, %cst_1 : f32
            %52 = select %51, %cst_1, %50 : f32
            affine.store %52, %18[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst, %17[%arg1, %arg2, %arg3, %arg4] : memref<1x256x4x4xf32>
            %50 = affine.max #map10(%arg3)[%c8, %c2, %c0, %c2, %c1]
            %51 = affine.max #map10(%arg4)[%c8, %c2, %c0, %c2, %c1]
            affine.for %arg5 = 0 to min #map19(%arg3) {
              affine.for %arg6 = 0 to min #map19(%arg4) {
                %52 = addi %arg5, %50 : index
                %53 = addi %arg6, %51 : index
                %54 = memref.load %18[%arg1, %arg2, %52, %53] : memref<1x256x8x8xf32>
                %55 = affine.load %17[%arg1, %arg2, %arg3, %arg4] : memref<1x256x4x4xf32>
                %56 = cmpf "ogt", %55, %54 : f32
                %57 = select %56, %55, %54 : f32
                affine.store %57, %17[%arg1, %arg2, %arg3, %arg4] : memref<1x256x4x4xf32>
              }
            }
          }
        }
      }
    }
    %40 = "krnl.global"() {name = "constant_8", offset = 3843584 : i64, shape = [512, 256, 3, 3]} : () -> memref<512x256x3x3xf32>
    %41 = "krnl.global"() {name = "constant_9", offset = 8562176 : i64, shape = [512]} : () -> memref<512xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 6 {
          affine.for %arg4 = 0 to 6 {
            affine.store %cst_1, %16[%arg1, %arg2, %arg3, %arg4] : memref<1x256x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %50 = affine.apply #map5(%arg3)
            %51 = affine.apply #map5(%arg4)
            %52 = affine.load %17[%arg1, %arg2, %arg3, %arg4] : memref<1x256x4x4xf32>
            affine.store %52, %16[%arg1, %arg2, %50, %51] : memref<1x256x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_1, %15[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.for %arg5 = 0 to 256 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %53 = affine.apply #map7(%arg3, %arg6)
                  %54 = affine.apply #map7(%arg4, %arg7)
                  %55 = affine.load %16[%arg1, %arg5, %53, %54] : memref<1x256x6x6xf32>
                  %56 = affine.load %40[%arg2, %arg5, %arg6, %arg7] : memref<512x256x3x3xf32>
                  %57 = affine.load %15[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                  %58 = mulf %55, %56 : f32
                  %59 = addf %57, %58 : f32
                  affine.store %59, %15[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                }
              }
            }
            %50 = affine.load %15[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %51 = affine.load %41[%arg2] : memref<512xf32>
            %52 = addf %50, %51 : f32
            affine.store %52, %15[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %50 = affine.load %15[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %51 = cmpf "olt", %50, %cst_1 : f32
            %52 = select %51, %cst_1, %50 : f32
            affine.store %52, %14[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    %42 = "krnl.global"() {name = "constant_10", offset = 8564224 : i64, shape = [512, 512, 3, 3]} : () -> memref<512x512x3x3xf32>
    %43 = "krnl.global"() {name = "constant_11", offset = 18001408 : i64, shape = [512]} : () -> memref<512xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 6 {
          affine.for %arg4 = 0 to 6 {
            affine.store %cst_1, %13[%arg1, %arg2, %arg3, %arg4] : memref<1x512x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %50 = affine.apply #map5(%arg3)
            %51 = affine.apply #map5(%arg4)
            %52 = affine.load %14[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.store %52, %13[%arg1, %arg2, %50, %51] : memref<1x512x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_1, %12[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            affine.for %arg5 = 0 to 512 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %53 = affine.apply #map7(%arg3, %arg6)
                  %54 = affine.apply #map7(%arg4, %arg7)
                  %55 = affine.load %13[%arg1, %arg5, %53, %54] : memref<1x512x6x6xf32>
                  %56 = affine.load %42[%arg2, %arg5, %arg6, %arg7] : memref<512x512x3x3xf32>
                  %57 = affine.load %12[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                  %58 = mulf %55, %56 : f32
                  %59 = addf %57, %58 : f32
                  affine.store %59, %12[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
                }
              }
            }
            %50 = affine.load %12[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %51 = affine.load %43[%arg2] : memref<512xf32>
            %52 = addf %50, %51 : f32
            affine.store %52, %12[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %50 = affine.load %12[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %51 = cmpf "olt", %50, %cst_1 : f32
            %52 = select %51, %cst_1, %50 : f32
            affine.store %52, %11[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            affine.store %cst, %10[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            %50 = affine.max #map10(%arg3)[%c4, %c2, %c0, %c2, %c1]
            %51 = affine.max #map10(%arg4)[%c4, %c2, %c0, %c2, %c1]
            affine.for %arg5 = 0 to min #map23(%arg3) {
              affine.for %arg6 = 0 to min #map23(%arg4) {
                %52 = addi %arg5, %50 : index
                %53 = addi %arg6, %51 : index
                %54 = memref.load %11[%arg1, %arg2, %52, %53] : memref<1x512x4x4xf32>
                %55 = affine.load %10[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
                %56 = cmpf "ogt", %55, %54 : f32
                %57 = select %56, %55, %54 : f32
                affine.store %57, %10[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
              }
            }
          }
        }
      }
    }
    %44 = "krnl.global"() {name = "constant_12", offset = 18003456 : i64, shape = [512, 512, 3, 3]} : () -> memref<512x512x3x3xf32>
    %45 = "krnl.global"() {name = "constant_13", offset = 27440640 : i64, shape = [512]} : () -> memref<512xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_1, %9[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            %50 = affine.apply #map5(%arg3)
            %51 = affine.apply #map5(%arg4)
            %52 = affine.load %10[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            affine.store %52, %9[%arg1, %arg2, %50, %51] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            affine.store %cst_1, %8[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            affine.for %arg5 = 0 to 512 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %53 = affine.apply #map7(%arg3, %arg6)
                  %54 = affine.apply #map7(%arg4, %arg7)
                  %55 = affine.load %9[%arg1, %arg5, %53, %54] : memref<1x512x4x4xf32>
                  %56 = affine.load %44[%arg2, %arg5, %arg6, %arg7] : memref<512x512x3x3xf32>
                  %57 = affine.load %8[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
                  %58 = mulf %55, %56 : f32
                  %59 = addf %57, %58 : f32
                  affine.store %59, %8[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
                }
              }
            }
            %50 = affine.load %8[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            %51 = affine.load %45[%arg2] : memref<512xf32>
            %52 = addf %50, %51 : f32
            affine.store %52, %8[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            %50 = affine.load %8[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            %51 = cmpf "olt", %50, %cst_1 : f32
            %52 = select %51, %cst_1, %50 : f32
            affine.store %52, %7[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
          }
        }
      }
    }
    %46 = "krnl.global"() {name = "constant_14", offset = 27442688 : i64, shape = [512, 512, 3, 3]} : () -> memref<512x512x3x3xf32>
    %47 = "krnl.global"() {name = "constant_15", offset = 36879872 : i64, shape = [512]} : () -> memref<512xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_1, %6[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            %50 = affine.apply #map5(%arg3)
            %51 = affine.apply #map5(%arg4)
            %52 = affine.load %7[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            affine.store %52, %6[%arg1, %arg2, %50, %51] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            affine.store %cst_1, %5[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            affine.for %arg5 = 0 to 512 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %53 = affine.apply #map7(%arg3, %arg6)
                  %54 = affine.apply #map7(%arg4, %arg7)
                  %55 = affine.load %6[%arg1, %arg5, %53, %54] : memref<1x512x4x4xf32>
                  %56 = affine.load %46[%arg2, %arg5, %arg6, %arg7] : memref<512x512x3x3xf32>
                  %57 = affine.load %5[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
                  %58 = mulf %55, %56 : f32
                  %59 = addf %57, %58 : f32
                  affine.store %59, %5[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
                }
              }
            }
            %50 = affine.load %5[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            %51 = affine.load %47[%arg2] : memref<512xf32>
            %52 = addf %50, %51 : f32
            affine.store %52, %5[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            %50 = affine.load %5[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            %51 = cmpf "olt", %50, %cst_1 : f32
            %52 = select %51, %cst_1, %50 : f32
            affine.store %52, %4[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 1 {
          affine.for %arg4 = 0 to 1 {
            affine.store %cst, %3[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
            %50 = affine.max #map10(%arg3)[%c2, %c2, %c0, %c2, %c1]
            %51 = affine.max #map10(%arg4)[%c2, %c2, %c0, %c2, %c1]
            affine.for %arg5 = 0 to min #map25(%arg3) {
              affine.for %arg6 = 0 to min #map25(%arg4) {
                %52 = addi %arg5, %50 : index
                %53 = addi %arg6, %51 : index
                %54 = memref.load %4[%arg1, %arg2, %52, %53] : memref<1x512x2x2xf32>
                %55 = affine.load %3[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
                %56 = cmpf "ogt", %55, %54 : f32
                %57 = select %56, %55, %54 : f32
                affine.store %57, %3[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
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
            %50 = affine.load %3[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
            %51 = affine.apply #map26(%arg2, %arg3, %arg4)[%c512, %c1, %c1]
            affine.store %50, %2[%arg1, %51] : memref<1x512xf32>
          }
        }
      }
    }
    %48 = "krnl.global"() {name = "constant_16", offset = 36881920 : i64, shape = [10, 512]} : () -> memref<10x512xf32>
    %49 = "krnl.global"() {name = "constant_17", offset = 36902400 : i64, shape = [10], value = dense<[0.0239618793, -0.0176391881, 0.00156179885, 0.00835412181, -0.0334166288, -0.0275942627, 0.0127248131, 0.00812496897, 0.0337691046, 0.0120836589]> : tensor<10xf32>} : () -> memref<10xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 10 {
        affine.store %cst_1, %1[%arg1, %arg2] : memref<1x10xf32>
        affine.for %arg3 = 0 to 512 {
          %55 = affine.load %2[%arg1, %arg3] : memref<1x512xf32>
          %56 = affine.load %48[%arg2, %arg3] : memref<10x512xf32>
          %57 = affine.load %1[%arg1, %arg2] : memref<1x10xf32>
          %58 = mulf %55, %56 : f32
          %59 = addf %57, %58 : f32
          affine.store %59, %1[%arg1, %arg2] : memref<1x10xf32>
        }
        %50 = affine.load %1[%arg1, %arg2] : memref<1x10xf32>
        %51 = mulf %cst_0, %50 : f32
        %52 = affine.load %49[%arg2] : memref<10xf32>
        %53 = mulf %cst_0, %52 : f32
        %54 = addf %51, %53 : f32
        affine.store %54, %1[%arg1, %arg2] : memref<1x10xf32>
      }
    }
    memref.dealloc %31 : memref<1x3x34x34xf32>
    memref.dealloc %30 : memref<1x64x32x32xf32>
    memref.dealloc %29 : memref<1x64x32x32xf32>
    memref.dealloc %28 : memref<1x64x16x16xf32>
    memref.dealloc %27 : memref<1x64x18x18xf32>
    memref.dealloc %26 : memref<1x128x16x16xf32>
    memref.dealloc %25 : memref<1x128x16x16xf32>
    memref.dealloc %24 : memref<1x128x8x8xf32>
    memref.dealloc %23 : memref<1x128x10x10xf32>
    memref.dealloc %22 : memref<1x256x8x8xf32>
    memref.dealloc %21 : memref<1x256x8x8xf32>
    memref.dealloc %20 : memref<1x256x10x10xf32>
    memref.dealloc %19 : memref<1x256x8x8xf32>
    memref.dealloc %18 : memref<1x256x8x8xf32>
    memref.dealloc %17 : memref<1x256x4x4xf32>
    memref.dealloc %16 : memref<1x256x6x6xf32>
    memref.dealloc %15 : memref<1x512x4x4xf32>
    memref.dealloc %14 : memref<1x512x4x4xf32>
    memref.dealloc %13 : memref<1x512x6x6xf32>
    memref.dealloc %12 : memref<1x512x4x4xf32>
    memref.dealloc %11 : memref<1x512x4x4xf32>
    memref.dealloc %10 : memref<1x512x2x2xf32>
    memref.dealloc %9 : memref<1x512x4x4xf32>
    memref.dealloc %8 : memref<1x512x2x2xf32>
    memref.dealloc %7 : memref<1x512x2x2xf32>
    memref.dealloc %6 : memref<1x512x4x4xf32>
    memref.dealloc %5 : memref<1x512x2x2xf32>
    memref.dealloc %4 : memref<1x512x2x2xf32>
    memref.dealloc %3 : memref<1x512x1x1xf32>
    memref.dealloc %2 : memref<1x512xf32>
    return %1 : memref<1x10xf32>
  }
  "krnl.entry_point"() {func = @main_graph, numInputs = 1 : i32, numOutputs = 1 : i32} : () -> ()
}
