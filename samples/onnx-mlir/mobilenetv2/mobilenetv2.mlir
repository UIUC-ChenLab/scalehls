#map0 = affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>
#map1 = affine_map<() -> (0)>
#map2 = affine_map<() -> (34)>
#map3 = affine_map<() -> (3)>
#map4 = affine_map<() -> (1)>
#map5 = affine_map<(d0) -> (d0 + 1)>
#map6 = affine_map<() -> (32)>
#map7 = affine_map<(d0, d1) -> (d0 + d1)>
#map8 = affine_map<(d0, d1)[s0] -> (d0 * s0 + d1)>
#map9 = affine_map<() -> (16)>
#map10 = affine_map<() -> (96)>
#map11 = affine_map<() -> (24)>
#map12 = affine_map<() -> (144)>
#map13 = affine_map<(d0, d1) -> (d0 * 2 + d1)>
#map14 = affine_map<() -> (192)>
#map15 = affine_map<() -> (18)>
#map16 = affine_map<() -> (8)>
#map17 = affine_map<() -> (64)>
#map18 = affine_map<() -> (384)>
#map19 = affine_map<() -> (10)>
#map20 = affine_map<() -> (576)>
#map21 = affine_map<() -> (4)>
#map22 = affine_map<() -> (160)>
#map23 = affine_map<() -> (960)>
#map24 = affine_map<() -> (6)>
#map25 = affine_map<() -> (320)>
#map26 = affine_map<() -> (1280)>
#map27 = affine_map<(d0, d1, d2)[s0, s1, s2] -> (d2 + d1 * s2 + d0 * (s1 * s2))>
#map28 = affine_map<(d0, d1) -> (d0, d1)>
#map29 = affine_map<(d0) -> (d0)>
module {
  %0 = "krnl.packed_const"() {file_name = "/tmp/packed_const-d42300.tmp", is_le = true, size_in_bytes = 9047296 : i64} : () -> i64
  func @main_graph(%arg0: memref<1x3x32x32xf32>) -> memref<1x10xf32> attributes {input_names = ["input.1"], output_names = ["169"]} {
    %c0 = arith.constant 0 : index
    %c16_i64 = arith.constant 16 : i64
    %c1280 = arith.constant 1280 : index
    %c1 = arith.constant 1 : index
    %cst = arith.constant 1.000000e+00 : f32
    %cst_0 = arith.constant 0.000000e+00 : f32
    %1 = memref.alloc() : memref<1x10xf32>
    %2 = memref.alloc() : memref<1x1280xf32>
    %3 = memref.alloc() : memref<1x1280x1x1xf32>
    %4 = memref.alloc() : memref<1x1280x4x4xf32>
    %5 = memref.alloc() : memref<1x1280x4x4xf32>
    %6 = memref.alloc() : memref<1x320x4x4xf32>
    %7 = memref.alloc() : memref<1x320x4x4xf32>
    %8 = memref.alloc() : memref<1x320x4x4xf32>
    %9 = memref.alloc() : memref<1x960x4x4xf32>
    %10 = memref.alloc() : memref<1x960x4x4xf32>
    %11 = memref.alloc() : memref<1x960x6x6xf32>
    %12 = memref.alloc() : memref<1x960x4x4xf32>
    %13 = memref.alloc() : memref<1x960x4x4xf32>
    %14 = memref.alloc() : memref<1x160x4x4xf32>
    %15 = memref.alloc() : memref<1x160x4x4xf32>
    %16 = memref.alloc() : memref<1x960x4x4xf32>
    %17 = memref.alloc() : memref<1x960x4x4xf32>
    %18 = memref.alloc() : memref<1x960x6x6xf32>
    %19 = memref.alloc() : memref<1x960x4x4xf32>
    %20 = memref.alloc() : memref<1x960x4x4xf32>
    %21 = memref.alloc() : memref<1x160x4x4xf32>
    %22 = memref.alloc() : memref<1x160x4x4xf32>
    %23 = memref.alloc() : memref<1x960x4x4xf32>
    %24 = memref.alloc() : memref<1x960x4x4xf32>
    %25 = memref.alloc() : memref<1x960x6x6xf32>
    %26 = memref.alloc() : memref<1x960x4x4xf32>
    %27 = memref.alloc() : memref<1x960x4x4xf32>
    %28 = memref.alloc() : memref<1x160x4x4xf32>
    %29 = memref.alloc() : memref<1x576x4x4xf32>
    %30 = memref.alloc() : memref<1x576x4x4xf32>
    %31 = memref.alloc() : memref<1x576x10x10xf32>
    %32 = memref.alloc() : memref<1x576x8x8xf32>
    %33 = memref.alloc() : memref<1x576x8x8xf32>
    %34 = memref.alloc() : memref<1x96x8x8xf32>
    %35 = memref.alloc() : memref<1x96x8x8xf32>
    %36 = memref.alloc() : memref<1x576x8x8xf32>
    %37 = memref.alloc() : memref<1x576x8x8xf32>
    %38 = memref.alloc() : memref<1x576x10x10xf32>
    %39 = memref.alloc() : memref<1x576x8x8xf32>
    %40 = memref.alloc() : memref<1x576x8x8xf32>
    %41 = memref.alloc() : memref<1x96x8x8xf32>
    %42 = memref.alloc() : memref<1x96x8x8xf32>
    %43 = memref.alloc() : memref<1x576x8x8xf32>
    %44 = memref.alloc() : memref<1x576x8x8xf32>
    %45 = memref.alloc() : memref<1x576x10x10xf32>
    %46 = memref.alloc() : memref<1x576x8x8xf32>
    %47 = memref.alloc() : memref<1x576x8x8xf32>
    %48 = memref.alloc() : memref<1x96x8x8xf32>
    %49 = memref.alloc() : memref<1x96x8x8xf32>
    %50 = memref.alloc() : memref<1x96x8x8xf32>
    %51 = memref.alloc() : memref<1x384x8x8xf32>
    %52 = memref.alloc() : memref<1x384x8x8xf32>
    %53 = memref.alloc() : memref<1x384x10x10xf32>
    %54 = memref.alloc() : memref<1x384x8x8xf32>
    %55 = memref.alloc() : memref<1x384x8x8xf32>
    %56 = memref.alloc() : memref<1x64x8x8xf32>
    %57 = memref.alloc() : memref<1x64x8x8xf32>
    %58 = memref.alloc() : memref<1x384x8x8xf32>
    %59 = memref.alloc() : memref<1x384x8x8xf32>
    %60 = memref.alloc() : memref<1x384x10x10xf32>
    %61 = memref.alloc() : memref<1x384x8x8xf32>
    %62 = memref.alloc() : memref<1x384x8x8xf32>
    %63 = memref.alloc() : memref<1x64x8x8xf32>
    %64 = memref.alloc() : memref<1x64x8x8xf32>
    %65 = memref.alloc() : memref<1x384x8x8xf32>
    %66 = memref.alloc() : memref<1x384x8x8xf32>
    %67 = memref.alloc() : memref<1x384x10x10xf32>
    %68 = memref.alloc() : memref<1x384x8x8xf32>
    %69 = memref.alloc() : memref<1x384x8x8xf32>
    %70 = memref.alloc() : memref<1x64x8x8xf32>
    %71 = memref.alloc() : memref<1x64x8x8xf32>
    %72 = memref.alloc() : memref<1x384x8x8xf32>
    %73 = memref.alloc() : memref<1x384x8x8xf32>
    %74 = memref.alloc() : memref<1x384x10x10xf32>
    %75 = memref.alloc() : memref<1x384x8x8xf32>
    %76 = memref.alloc() : memref<1x384x8x8xf32>
    %77 = memref.alloc() : memref<1x64x8x8xf32>
    %78 = memref.alloc() : memref<1x192x8x8xf32>
    %79 = memref.alloc() : memref<1x192x8x8xf32>
    %80 = memref.alloc() : memref<1x192x18x18xf32>
    %81 = memref.alloc() : memref<1x192x16x16xf32>
    %82 = memref.alloc() : memref<1x192x16x16xf32>
    %83 = memref.alloc() : memref<1x32x16x16xf32>
    %84 = memref.alloc() : memref<1x32x16x16xf32>
    %85 = memref.alloc() : memref<1x192x16x16xf32>
    %86 = memref.alloc() : memref<1x192x16x16xf32>
    %87 = memref.alloc() : memref<1x192x18x18xf32>
    %88 = memref.alloc() : memref<1x192x16x16xf32>
    %89 = memref.alloc() : memref<1x192x16x16xf32>
    %90 = memref.alloc() : memref<1x32x16x16xf32>
    %91 = memref.alloc() : memref<1x32x16x16xf32>
    %92 = memref.alloc() : memref<1x192x16x16xf32>
    %93 = memref.alloc() : memref<1x192x16x16xf32>
    %94 = memref.alloc() : memref<1x192x18x18xf32>
    %95 = memref.alloc() : memref<1x192x16x16xf32>
    %96 = memref.alloc() : memref<1x192x16x16xf32>
    %97 = memref.alloc() : memref<1x32x16x16xf32>
    %98 = memref.alloc() : memref<1x144x16x16xf32>
    %99 = memref.alloc() : memref<1x144x16x16xf32>
    %100 = memref.alloc() : memref<1x144x34x34xf32>
    %101 = memref.alloc() : memref<1x144x32x32xf32>
    %102 = memref.alloc() : memref<1x144x32x32xf32>
    %103 = memref.alloc() : memref<1x24x32x32xf32>
    %104 = memref.alloc() : memref<1x24x32x32xf32>
    %105 = memref.alloc() : memref<1x144x32x32xf32>
    %106 = memref.alloc() : memref<1x144x32x32xf32>
    %107 = memref.alloc() : memref<1x144x34x34xf32>
    %108 = memref.alloc() : memref<1x144x32x32xf32>
    %109 = memref.alloc() : memref<1x144x32x32xf32>
    %110 = memref.alloc() : memref<1x24x32x32xf32>
    %111 = memref.alloc() : memref<1x24x32x32xf32>
    %112 = memref.alloc() : memref<1x24x32x32xf32>
    %113 = memref.alloc() : memref<1x96x32x32xf32>
    %114 = memref.alloc() : memref<1x96x32x32xf32>
    %115 = memref.alloc() : memref<1x96x34x34xf32>
    %116 = memref.alloc() : memref<1x96x32x32xf32>
    %117 = memref.alloc() : memref<1x96x32x32xf32>
    %118 = memref.alloc() : memref<1x16x32x32xf32>
    %119 = memref.alloc() : memref<1x16x32x32xf32>
    %120 = memref.alloc() : memref<1x16x32x32xf32>
    %121 = memref.alloc() : memref<1x32x32x32xf32>
    %122 = memref.alloc() : memref<1x32x32x32xf32>
    %123 = memref.alloc() : memref<1x32x34x34xf32>
    %124 = memref.alloc() : memref<1x32x32x32xf32>
    %125 = memref.alloc() : memref<1x32x32x32xf32>
    %126 = memref.alloc() : memref<1x32x32x32xf32>
    %127 = memref.alloc() : memref<1x32x32x32xf32>
    %128 = memref.alloc() : memref<1x3x34x34xf32>
    %129 = "krnl.global"() {name = "arith.constant_0", offset = 0 : i64, shape = [32, 3, 3, 3]} : () -> memref<32x3x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 3 {
        affine.for %arg3 = 0 to 34 {
          affine.for %arg4 = 0 to 34 {
            affine.store %cst_0, %128[%arg1, %arg2, %arg3, %arg4] : memref<1x3x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 3 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %189 = affine.apply #map5(%arg3)
            %190 = affine.apply #map5(%arg4)
            %191 = affine.load %arg0[%arg1, %arg2, %arg3, %arg4] : memref<1x3x32x32xf32>
            affine.store %191, %128[%arg1, %arg2, %189, %190] : memref<1x3x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 32 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            affine.store %cst_0, %127[%arg1, %arg2, %arg3, %arg4] : memref<1x32x32x32xf32>
            affine.for %arg5 = 0 to 3 {
              affine.for %arg6 = 0 to 3 {
                affine.for %arg7 = 0 to 3 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %128[%arg1, %arg5, %189, %190] : memref<1x3x34x34xf32>
                  %192 = affine.load %129[%arg2, %arg5, %arg6, %arg7] : memref<32x3x3x3xf32>
                  %193 = affine.load %127[%arg1, %arg2, %arg3, %arg4] : memref<1x32x32x32xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %127[%arg1, %arg2, %arg3, %arg4] : memref<1x32x32x32xf32>
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
            %189 = affine.load %127[%arg1, %arg2, %arg3, %arg4] : memref<1x32x32x32xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %126[%arg1, %arg2, %arg3, %arg4] : memref<1x32x32x32xf32>
          }
        }
      }
    }
    %130 = "krnl.global"() {name = "arith.constant_1", offset = 3456 : i64, shape = [32, 32, 1, 1]} : () -> memref<32x32x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 32 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            affine.store %cst_0, %125[%arg1, %arg2, %arg3, %arg4] : memref<1x32x32x32xf32>
            affine.for %arg5 = 0 to 32 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %126[%arg1, %arg5, %189, %190] : memref<1x32x32x32xf32>
                  %192 = affine.load %130[%arg2, %arg5, %arg6, %arg7] : memref<32x32x1x1xf32>
                  %193 = affine.load %125[%arg1, %arg2, %arg3, %arg4] : memref<1x32x32x32xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %125[%arg1, %arg2, %arg3, %arg4] : memref<1x32x32x32xf32>
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
            %189 = affine.load %125[%arg1, %arg2, %arg3, %arg4] : memref<1x32x32x32xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %124[%arg1, %arg2, %arg3, %arg4] : memref<1x32x32x32xf32>
          }
        }
      }
    }
    %131 = "krnl.global"() {name = "arith.constant_2", offset = 7552 : i64, shape = [32, 1, 3, 3]} : () -> memref<32x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 32 {
        affine.for %arg3 = 0 to 34 {
          affine.for %arg4 = 0 to 34 {
            affine.store %cst_0, %123[%arg1, %arg2, %arg3, %arg4] : memref<1x32x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 32 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %189 = affine.apply #map5(%arg3)
            %190 = affine.apply #map5(%arg4)
            %191 = affine.load %124[%arg1, %arg2, %arg3, %arg4] : memref<1x32x32x32xf32>
            affine.store %191, %123[%arg1, %arg2, %189, %190] : memref<1x32x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 32 {
        affine.for %arg3 = 0 to 1 {
          %189 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 32 {
            affine.for %arg5 = 0 to 32 {
              affine.store %cst_0, %122[%arg1, %189, %arg4, %arg5] : memref<1x32x32x32xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %190 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %191 = affine.apply #map7(%arg4, %arg7)
                    %192 = affine.apply #map7(%arg5, %arg8)
                    %193 = affine.load %123[%arg1, %190, %191, %192] : memref<1x32x34x34xf32>
                    %194 = affine.load %131[%189, %arg6, %arg7, %arg8] : memref<32x1x3x3xf32>
                    %195 = affine.load %122[%arg1, %189, %arg4, %arg5] : memref<1x32x32x32xf32>
                    %196 = arith.mulf %193, %194 : f32
                    %197 = arith.addf %195, %196 : f32
                    affine.store %197, %122[%arg1, %189, %arg4, %arg5] : memref<1x32x32x32xf32>
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
            %189 = affine.load %122[%arg1, %arg2, %arg3, %arg4] : memref<1x32x32x32xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %121[%arg1, %arg2, %arg3, %arg4] : memref<1x32x32x32xf32>
          }
        }
      }
    }
    %132 = "krnl.global"() {name = "arith.constant_3", offset = 8704 : i64, shape = [16, 32, 1, 1]} : () -> memref<16x32x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 16 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            affine.store %cst_0, %120[%arg1, %arg2, %arg3, %arg4] : memref<1x16x32x32xf32>
            affine.for %arg5 = 0 to 32 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %121[%arg1, %arg5, %189, %190] : memref<1x32x32x32xf32>
                  %192 = affine.load %132[%arg2, %arg5, %arg6, %arg7] : memref<16x32x1x1xf32>
                  %193 = affine.load %120[%arg1, %arg2, %arg3, %arg4] : memref<1x16x32x32xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %120[%arg1, %arg2, %arg3, %arg4] : memref<1x16x32x32xf32>
                }
              }
            }
          }
        }
      }
    }
    %133 = "krnl.global"() {name = "arith.constant_4", offset = 10752 : i64, shape = [16, 32, 1, 1]} : () -> memref<16x32x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 16 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            affine.store %cst_0, %119[%arg1, %arg2, %arg3, %arg4] : memref<1x16x32x32xf32>
            affine.for %arg5 = 0 to 32 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %126[%arg1, %arg5, %189, %190] : memref<1x32x32x32xf32>
                  %192 = affine.load %133[%arg2, %arg5, %arg6, %arg7] : memref<16x32x1x1xf32>
                  %193 = affine.load %119[%arg1, %arg2, %arg3, %arg4] : memref<1x16x32x32xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %119[%arg1, %arg2, %arg3, %arg4] : memref<1x16x32x32xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 16 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %189 = affine.load %120[%arg1, %arg2, %arg3, %arg4] : memref<1x16x32x32xf32>
            %190 = affine.load %119[%arg1, %arg2, %arg3, %arg4] : memref<1x16x32x32xf32>
            %191 = arith.addf %189, %190 : f32
            affine.store %191, %118[%arg1, %arg2, %arg3, %arg4] : memref<1x16x32x32xf32>
          }
        }
      }
    }
    %134 = "krnl.global"() {name = "arith.constant_5", offset = 12800 : i64, shape = [96, 16, 1, 1]} : () -> memref<96x16x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 96 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            affine.store %cst_0, %117[%arg1, %arg2, %arg3, %arg4] : memref<1x96x32x32xf32>
            affine.for %arg5 = 0 to 16 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %118[%arg1, %arg5, %189, %190] : memref<1x16x32x32xf32>
                  %192 = affine.load %134[%arg2, %arg5, %arg6, %arg7] : memref<96x16x1x1xf32>
                  %193 = affine.load %117[%arg1, %arg2, %arg3, %arg4] : memref<1x96x32x32xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %117[%arg1, %arg2, %arg3, %arg4] : memref<1x96x32x32xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 96 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %189 = affine.load %117[%arg1, %arg2, %arg3, %arg4] : memref<1x96x32x32xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %116[%arg1, %arg2, %arg3, %arg4] : memref<1x96x32x32xf32>
          }
        }
      }
    }
    %135 = "krnl.global"() {name = "arith.constant_6", offset = 18944 : i64, shape = [96, 1, 3, 3]} : () -> memref<96x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 96 {
        affine.for %arg3 = 0 to 34 {
          affine.for %arg4 = 0 to 34 {
            affine.store %cst_0, %115[%arg1, %arg2, %arg3, %arg4] : memref<1x96x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 96 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %189 = affine.apply #map5(%arg3)
            %190 = affine.apply #map5(%arg4)
            %191 = affine.load %116[%arg1, %arg2, %arg3, %arg4] : memref<1x96x32x32xf32>
            affine.store %191, %115[%arg1, %arg2, %189, %190] : memref<1x96x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 96 {
        affine.for %arg3 = 0 to 1 {
          %189 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 32 {
            affine.for %arg5 = 0 to 32 {
              affine.store %cst_0, %114[%arg1, %189, %arg4, %arg5] : memref<1x96x32x32xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %190 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %191 = affine.apply #map7(%arg4, %arg7)
                    %192 = affine.apply #map7(%arg5, %arg8)
                    %193 = affine.load %115[%arg1, %190, %191, %192] : memref<1x96x34x34xf32>
                    %194 = affine.load %135[%189, %arg6, %arg7, %arg8] : memref<96x1x3x3xf32>
                    %195 = affine.load %114[%arg1, %189, %arg4, %arg5] : memref<1x96x32x32xf32>
                    %196 = arith.mulf %193, %194 : f32
                    %197 = arith.addf %195, %196 : f32
                    affine.store %197, %114[%arg1, %189, %arg4, %arg5] : memref<1x96x32x32xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 96 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %189 = affine.load %114[%arg1, %arg2, %arg3, %arg4] : memref<1x96x32x32xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %113[%arg1, %arg2, %arg3, %arg4] : memref<1x96x32x32xf32>
          }
        }
      }
    }
    %136 = "krnl.global"() {name = "arith.constant_7", offset = 22400 : i64, shape = [24, 96, 1, 1]} : () -> memref<24x96x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 24 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            affine.store %cst_0, %112[%arg1, %arg2, %arg3, %arg4] : memref<1x24x32x32xf32>
            affine.for %arg5 = 0 to 96 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %113[%arg1, %arg5, %189, %190] : memref<1x96x32x32xf32>
                  %192 = affine.load %136[%arg2, %arg5, %arg6, %arg7] : memref<24x96x1x1xf32>
                  %193 = affine.load %112[%arg1, %arg2, %arg3, %arg4] : memref<1x24x32x32xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %112[%arg1, %arg2, %arg3, %arg4] : memref<1x24x32x32xf32>
                }
              }
            }
          }
        }
      }
    }
    %137 = "krnl.global"() {name = "arith.constant_8", offset = 31616 : i64, shape = [24, 16, 1, 1]} : () -> memref<24x16x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 24 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            affine.store %cst_0, %111[%arg1, %arg2, %arg3, %arg4] : memref<1x24x32x32xf32>
            affine.for %arg5 = 0 to 16 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %118[%arg1, %arg5, %189, %190] : memref<1x16x32x32xf32>
                  %192 = affine.load %137[%arg2, %arg5, %arg6, %arg7] : memref<24x16x1x1xf32>
                  %193 = affine.load %111[%arg1, %arg2, %arg3, %arg4] : memref<1x24x32x32xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %111[%arg1, %arg2, %arg3, %arg4] : memref<1x24x32x32xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 24 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %189 = affine.load %112[%arg1, %arg2, %arg3, %arg4] : memref<1x24x32x32xf32>
            %190 = affine.load %111[%arg1, %arg2, %arg3, %arg4] : memref<1x24x32x32xf32>
            %191 = arith.addf %189, %190 : f32
            affine.store %191, %110[%arg1, %arg2, %arg3, %arg4] : memref<1x24x32x32xf32>
          }
        }
      }
    }
    %138 = "krnl.global"() {name = "arith.constant_9", offset = 33152 : i64, shape = [144, 24, 1, 1]} : () -> memref<144x24x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 144 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            affine.store %cst_0, %109[%arg1, %arg2, %arg3, %arg4] : memref<1x144x32x32xf32>
            affine.for %arg5 = 0 to 24 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %110[%arg1, %arg5, %189, %190] : memref<1x24x32x32xf32>
                  %192 = affine.load %138[%arg2, %arg5, %arg6, %arg7] : memref<144x24x1x1xf32>
                  %193 = affine.load %109[%arg1, %arg2, %arg3, %arg4] : memref<1x144x32x32xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %109[%arg1, %arg2, %arg3, %arg4] : memref<1x144x32x32xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 144 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %189 = affine.load %109[%arg1, %arg2, %arg3, %arg4] : memref<1x144x32x32xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %108[%arg1, %arg2, %arg3, %arg4] : memref<1x144x32x32xf32>
          }
        }
      }
    }
    %139 = "krnl.global"() {name = "arith.constant_10", offset = 46976 : i64, shape = [144, 1, 3, 3]} : () -> memref<144x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 144 {
        affine.for %arg3 = 0 to 34 {
          affine.for %arg4 = 0 to 34 {
            affine.store %cst_0, %107[%arg1, %arg2, %arg3, %arg4] : memref<1x144x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 144 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %189 = affine.apply #map5(%arg3)
            %190 = affine.apply #map5(%arg4)
            %191 = affine.load %108[%arg1, %arg2, %arg3, %arg4] : memref<1x144x32x32xf32>
            affine.store %191, %107[%arg1, %arg2, %189, %190] : memref<1x144x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 144 {
        affine.for %arg3 = 0 to 1 {
          %189 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 32 {
            affine.for %arg5 = 0 to 32 {
              affine.store %cst_0, %106[%arg1, %189, %arg4, %arg5] : memref<1x144x32x32xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %190 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %191 = affine.apply #map7(%arg4, %arg7)
                    %192 = affine.apply #map7(%arg5, %arg8)
                    %193 = affine.load %107[%arg1, %190, %191, %192] : memref<1x144x34x34xf32>
                    %194 = affine.load %139[%189, %arg6, %arg7, %arg8] : memref<144x1x3x3xf32>
                    %195 = affine.load %106[%arg1, %189, %arg4, %arg5] : memref<1x144x32x32xf32>
                    %196 = arith.mulf %193, %194 : f32
                    %197 = arith.addf %195, %196 : f32
                    affine.store %197, %106[%arg1, %189, %arg4, %arg5] : memref<1x144x32x32xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 144 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %189 = affine.load %106[%arg1, %arg2, %arg3, %arg4] : memref<1x144x32x32xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %105[%arg1, %arg2, %arg3, %arg4] : memref<1x144x32x32xf32>
          }
        }
      }
    }
    %140 = "krnl.global"() {name = "arith.constant_11", offset = 52160 : i64, shape = [24, 144, 1, 1]} : () -> memref<24x144x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 24 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            affine.store %cst_0, %104[%arg1, %arg2, %arg3, %arg4] : memref<1x24x32x32xf32>
            affine.for %arg5 = 0 to 144 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %105[%arg1, %arg5, %189, %190] : memref<1x144x32x32xf32>
                  %192 = affine.load %140[%arg2, %arg5, %arg6, %arg7] : memref<24x144x1x1xf32>
                  %193 = affine.load %104[%arg1, %arg2, %arg3, %arg4] : memref<1x24x32x32xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %104[%arg1, %arg2, %arg3, %arg4] : memref<1x24x32x32xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 24 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %189 = affine.load %104[%arg1, %arg2, %arg3, %arg4] : memref<1x24x32x32xf32>
            %190 = affine.load %110[%arg1, %arg2, %arg3, %arg4] : memref<1x24x32x32xf32>
            %191 = arith.addf %189, %190 : f32
            affine.store %191, %103[%arg1, %arg2, %arg3, %arg4] : memref<1x24x32x32xf32>
          }
        }
      }
    }
    %141 = "krnl.global"() {name = "arith.constant_12", offset = 65984 : i64, shape = [144, 24, 1, 1]} : () -> memref<144x24x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 144 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            affine.store %cst_0, %102[%arg1, %arg2, %arg3, %arg4] : memref<1x144x32x32xf32>
            affine.for %arg5 = 0 to 24 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %103[%arg1, %arg5, %189, %190] : memref<1x24x32x32xf32>
                  %192 = affine.load %141[%arg2, %arg5, %arg6, %arg7] : memref<144x24x1x1xf32>
                  %193 = affine.load %102[%arg1, %arg2, %arg3, %arg4] : memref<1x144x32x32xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %102[%arg1, %arg2, %arg3, %arg4] : memref<1x144x32x32xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 144 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %189 = affine.load %102[%arg1, %arg2, %arg3, %arg4] : memref<1x144x32x32xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %101[%arg1, %arg2, %arg3, %arg4] : memref<1x144x32x32xf32>
          }
        }
      }
    }
    %142 = "krnl.global"() {name = "arith.constant_13", offset = 79808 : i64, shape = [144, 1, 3, 3]} : () -> memref<144x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 144 {
        affine.for %arg3 = 0 to 34 {
          affine.for %arg4 = 0 to 34 {
            affine.store %cst_0, %100[%arg1, %arg2, %arg3, %arg4] : memref<1x144x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 144 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %189 = affine.apply #map5(%arg3)
            %190 = affine.apply #map5(%arg4)
            %191 = affine.load %101[%arg1, %arg2, %arg3, %arg4] : memref<1x144x32x32xf32>
            affine.store %191, %100[%arg1, %arg2, %189, %190] : memref<1x144x34x34xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 144 {
        affine.for %arg3 = 0 to 1 {
          %189 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 16 {
            affine.for %arg5 = 0 to 16 {
              affine.store %cst_0, %99[%arg1, %189, %arg4, %arg5] : memref<1x144x16x16xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %190 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %191 = affine.apply #map13(%arg4, %arg7)
                    %192 = affine.apply #map13(%arg5, %arg8)
                    %193 = affine.load %100[%arg1, %190, %191, %192] : memref<1x144x34x34xf32>
                    %194 = affine.load %142[%189, %arg6, %arg7, %arg8] : memref<144x1x3x3xf32>
                    %195 = affine.load %99[%arg1, %189, %arg4, %arg5] : memref<1x144x16x16xf32>
                    %196 = arith.mulf %193, %194 : f32
                    %197 = arith.addf %195, %196 : f32
                    affine.store %197, %99[%arg1, %189, %arg4, %arg5] : memref<1x144x16x16xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 144 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %189 = affine.load %99[%arg1, %arg2, %arg3, %arg4] : memref<1x144x16x16xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %98[%arg1, %arg2, %arg3, %arg4] : memref<1x144x16x16xf32>
          }
        }
      }
    }
    %143 = "krnl.global"() {name = "arith.constant_14", offset = 84992 : i64, shape = [32, 144, 1, 1]} : () -> memref<32x144x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 32 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            affine.store %cst_0, %97[%arg1, %arg2, %arg3, %arg4] : memref<1x32x16x16xf32>
            affine.for %arg5 = 0 to 144 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %98[%arg1, %arg5, %189, %190] : memref<1x144x16x16xf32>
                  %192 = affine.load %143[%arg2, %arg5, %arg6, %arg7] : memref<32x144x1x1xf32>
                  %193 = affine.load %97[%arg1, %arg2, %arg3, %arg4] : memref<1x32x16x16xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %97[%arg1, %arg2, %arg3, %arg4] : memref<1x32x16x16xf32>
                }
              }
            }
          }
        }
      }
    }
    %144 = "krnl.global"() {name = "arith.constant_15", offset = 103424 : i64, shape = [192, 32, 1, 1]} : () -> memref<192x32x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 192 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            affine.store %cst_0, %96[%arg1, %arg2, %arg3, %arg4] : memref<1x192x16x16xf32>
            affine.for %arg5 = 0 to 32 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %97[%arg1, %arg5, %189, %190] : memref<1x32x16x16xf32>
                  %192 = affine.load %144[%arg2, %arg5, %arg6, %arg7] : memref<192x32x1x1xf32>
                  %193 = affine.load %96[%arg1, %arg2, %arg3, %arg4] : memref<1x192x16x16xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %96[%arg1, %arg2, %arg3, %arg4] : memref<1x192x16x16xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 192 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %189 = affine.load %96[%arg1, %arg2, %arg3, %arg4] : memref<1x192x16x16xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %95[%arg1, %arg2, %arg3, %arg4] : memref<1x192x16x16xf32>
          }
        }
      }
    }
    %145 = "krnl.global"() {name = "arith.constant_16", offset = 128000 : i64, shape = [192, 1, 3, 3]} : () -> memref<192x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 192 {
        affine.for %arg3 = 0 to 18 {
          affine.for %arg4 = 0 to 18 {
            affine.store %cst_0, %94[%arg1, %arg2, %arg3, %arg4] : memref<1x192x18x18xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 192 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %189 = affine.apply #map5(%arg3)
            %190 = affine.apply #map5(%arg4)
            %191 = affine.load %95[%arg1, %arg2, %arg3, %arg4] : memref<1x192x16x16xf32>
            affine.store %191, %94[%arg1, %arg2, %189, %190] : memref<1x192x18x18xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 192 {
        affine.for %arg3 = 0 to 1 {
          %189 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 16 {
            affine.for %arg5 = 0 to 16 {
              affine.store %cst_0, %93[%arg1, %189, %arg4, %arg5] : memref<1x192x16x16xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %190 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %191 = affine.apply #map7(%arg4, %arg7)
                    %192 = affine.apply #map7(%arg5, %arg8)
                    %193 = affine.load %94[%arg1, %190, %191, %192] : memref<1x192x18x18xf32>
                    %194 = affine.load %145[%189, %arg6, %arg7, %arg8] : memref<192x1x3x3xf32>
                    %195 = affine.load %93[%arg1, %189, %arg4, %arg5] : memref<1x192x16x16xf32>
                    %196 = arith.mulf %193, %194 : f32
                    %197 = arith.addf %195, %196 : f32
                    affine.store %197, %93[%arg1, %189, %arg4, %arg5] : memref<1x192x16x16xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 192 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %189 = affine.load %93[%arg1, %arg2, %arg3, %arg4] : memref<1x192x16x16xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %92[%arg1, %arg2, %arg3, %arg4] : memref<1x192x16x16xf32>
          }
        }
      }
    }
    %146 = "krnl.global"() {name = "arith.constant_17", offset = 134912 : i64, shape = [32, 192, 1, 1]} : () -> memref<32x192x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 32 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            affine.store %cst_0, %91[%arg1, %arg2, %arg3, %arg4] : memref<1x32x16x16xf32>
            affine.for %arg5 = 0 to 192 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %92[%arg1, %arg5, %189, %190] : memref<1x192x16x16xf32>
                  %192 = affine.load %146[%arg2, %arg5, %arg6, %arg7] : memref<32x192x1x1xf32>
                  %193 = affine.load %91[%arg1, %arg2, %arg3, %arg4] : memref<1x32x16x16xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %91[%arg1, %arg2, %arg3, %arg4] : memref<1x32x16x16xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 32 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %189 = affine.load %91[%arg1, %arg2, %arg3, %arg4] : memref<1x32x16x16xf32>
            %190 = affine.load %97[%arg1, %arg2, %arg3, %arg4] : memref<1x32x16x16xf32>
            %191 = arith.addf %189, %190 : f32
            affine.store %191, %90[%arg1, %arg2, %arg3, %arg4] : memref<1x32x16x16xf32>
          }
        }
      }
    }
    %147 = "krnl.global"() {name = "arith.constant_18", offset = 159488 : i64, shape = [192, 32, 1, 1]} : () -> memref<192x32x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 192 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            affine.store %cst_0, %89[%arg1, %arg2, %arg3, %arg4] : memref<1x192x16x16xf32>
            affine.for %arg5 = 0 to 32 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %90[%arg1, %arg5, %189, %190] : memref<1x32x16x16xf32>
                  %192 = affine.load %147[%arg2, %arg5, %arg6, %arg7] : memref<192x32x1x1xf32>
                  %193 = affine.load %89[%arg1, %arg2, %arg3, %arg4] : memref<1x192x16x16xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %89[%arg1, %arg2, %arg3, %arg4] : memref<1x192x16x16xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 192 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %189 = affine.load %89[%arg1, %arg2, %arg3, %arg4] : memref<1x192x16x16xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %88[%arg1, %arg2, %arg3, %arg4] : memref<1x192x16x16xf32>
          }
        }
      }
    }
    %148 = "krnl.global"() {name = "arith.constant_19", offset = 184064 : i64, shape = [192, 1, 3, 3]} : () -> memref<192x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 192 {
        affine.for %arg3 = 0 to 18 {
          affine.for %arg4 = 0 to 18 {
            affine.store %cst_0, %87[%arg1, %arg2, %arg3, %arg4] : memref<1x192x18x18xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 192 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %189 = affine.apply #map5(%arg3)
            %190 = affine.apply #map5(%arg4)
            %191 = affine.load %88[%arg1, %arg2, %arg3, %arg4] : memref<1x192x16x16xf32>
            affine.store %191, %87[%arg1, %arg2, %189, %190] : memref<1x192x18x18xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 192 {
        affine.for %arg3 = 0 to 1 {
          %189 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 16 {
            affine.for %arg5 = 0 to 16 {
              affine.store %cst_0, %86[%arg1, %189, %arg4, %arg5] : memref<1x192x16x16xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %190 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %191 = affine.apply #map7(%arg4, %arg7)
                    %192 = affine.apply #map7(%arg5, %arg8)
                    %193 = affine.load %87[%arg1, %190, %191, %192] : memref<1x192x18x18xf32>
                    %194 = affine.load %148[%189, %arg6, %arg7, %arg8] : memref<192x1x3x3xf32>
                    %195 = affine.load %86[%arg1, %189, %arg4, %arg5] : memref<1x192x16x16xf32>
                    %196 = arith.mulf %193, %194 : f32
                    %197 = arith.addf %195, %196 : f32
                    affine.store %197, %86[%arg1, %189, %arg4, %arg5] : memref<1x192x16x16xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 192 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %189 = affine.load %86[%arg1, %arg2, %arg3, %arg4] : memref<1x192x16x16xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %85[%arg1, %arg2, %arg3, %arg4] : memref<1x192x16x16xf32>
          }
        }
      }
    }
    %149 = "krnl.global"() {name = "arith.constant_20", offset = 190976 : i64, shape = [32, 192, 1, 1]} : () -> memref<32x192x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 32 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            affine.store %cst_0, %84[%arg1, %arg2, %arg3, %arg4] : memref<1x32x16x16xf32>
            affine.for %arg5 = 0 to 192 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %85[%arg1, %arg5, %189, %190] : memref<1x192x16x16xf32>
                  %192 = affine.load %149[%arg2, %arg5, %arg6, %arg7] : memref<32x192x1x1xf32>
                  %193 = affine.load %84[%arg1, %arg2, %arg3, %arg4] : memref<1x32x16x16xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %84[%arg1, %arg2, %arg3, %arg4] : memref<1x32x16x16xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 32 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %189 = affine.load %84[%arg1, %arg2, %arg3, %arg4] : memref<1x32x16x16xf32>
            %190 = affine.load %90[%arg1, %arg2, %arg3, %arg4] : memref<1x32x16x16xf32>
            %191 = arith.addf %189, %190 : f32
            affine.store %191, %83[%arg1, %arg2, %arg3, %arg4] : memref<1x32x16x16xf32>
          }
        }
      }
    }
    %150 = "krnl.global"() {name = "arith.constant_21", offset = 215552 : i64, shape = [192, 32, 1, 1]} : () -> memref<192x32x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 192 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            affine.store %cst_0, %82[%arg1, %arg2, %arg3, %arg4] : memref<1x192x16x16xf32>
            affine.for %arg5 = 0 to 32 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %83[%arg1, %arg5, %189, %190] : memref<1x32x16x16xf32>
                  %192 = affine.load %150[%arg2, %arg5, %arg6, %arg7] : memref<192x32x1x1xf32>
                  %193 = affine.load %82[%arg1, %arg2, %arg3, %arg4] : memref<1x192x16x16xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %82[%arg1, %arg2, %arg3, %arg4] : memref<1x192x16x16xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 192 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %189 = affine.load %82[%arg1, %arg2, %arg3, %arg4] : memref<1x192x16x16xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %81[%arg1, %arg2, %arg3, %arg4] : memref<1x192x16x16xf32>
          }
        }
      }
    }
    %151 = "krnl.global"() {name = "arith.constant_22", offset = 240128 : i64, shape = [192, 1, 3, 3]} : () -> memref<192x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 192 {
        affine.for %arg3 = 0 to 18 {
          affine.for %arg4 = 0 to 18 {
            affine.store %cst_0, %80[%arg1, %arg2, %arg3, %arg4] : memref<1x192x18x18xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 192 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %189 = affine.apply #map5(%arg3)
            %190 = affine.apply #map5(%arg4)
            %191 = affine.load %81[%arg1, %arg2, %arg3, %arg4] : memref<1x192x16x16xf32>
            affine.store %191, %80[%arg1, %arg2, %189, %190] : memref<1x192x18x18xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 192 {
        affine.for %arg3 = 0 to 1 {
          %189 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 8 {
            affine.for %arg5 = 0 to 8 {
              affine.store %cst_0, %79[%arg1, %189, %arg4, %arg5] : memref<1x192x8x8xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %190 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %191 = affine.apply #map13(%arg4, %arg7)
                    %192 = affine.apply #map13(%arg5, %arg8)
                    %193 = affine.load %80[%arg1, %190, %191, %192] : memref<1x192x18x18xf32>
                    %194 = affine.load %151[%189, %arg6, %arg7, %arg8] : memref<192x1x3x3xf32>
                    %195 = affine.load %79[%arg1, %189, %arg4, %arg5] : memref<1x192x8x8xf32>
                    %196 = arith.mulf %193, %194 : f32
                    %197 = arith.addf %195, %196 : f32
                    affine.store %197, %79[%arg1, %189, %arg4, %arg5] : memref<1x192x8x8xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 192 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %189 = affine.load %79[%arg1, %arg2, %arg3, %arg4] : memref<1x192x8x8xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %78[%arg1, %arg2, %arg3, %arg4] : memref<1x192x8x8xf32>
          }
        }
      }
    }
    %152 = "krnl.global"() {name = "arith.constant_23", offset = 247040 : i64, shape = [64, 192, 1, 1]} : () -> memref<64x192x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_0, %77[%arg1, %arg2, %arg3, %arg4] : memref<1x64x8x8xf32>
            affine.for %arg5 = 0 to 192 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %78[%arg1, %arg5, %189, %190] : memref<1x192x8x8xf32>
                  %192 = affine.load %152[%arg2, %arg5, %arg6, %arg7] : memref<64x192x1x1xf32>
                  %193 = affine.load %77[%arg1, %arg2, %arg3, %arg4] : memref<1x64x8x8xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %77[%arg1, %arg2, %arg3, %arg4] : memref<1x64x8x8xf32>
                }
              }
            }
          }
        }
      }
    }
    %153 = "krnl.global"() {name = "arith.constant_24", offset = 296192 : i64, shape = [384, 64, 1, 1]} : () -> memref<384x64x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 384 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_0, %76[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
            affine.for %arg5 = 0 to 64 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %77[%arg1, %arg5, %189, %190] : memref<1x64x8x8xf32>
                  %192 = affine.load %153[%arg2, %arg5, %arg6, %arg7] : memref<384x64x1x1xf32>
                  %193 = affine.load %76[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %76[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 384 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %189 = affine.load %76[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %75[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
          }
        }
      }
    }
    %154 = "krnl.global"() {name = "arith.constant_25", offset = 394496 : i64, shape = [384, 1, 3, 3]} : () -> memref<384x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 384 {
        affine.for %arg3 = 0 to 10 {
          affine.for %arg4 = 0 to 10 {
            affine.store %cst_0, %74[%arg1, %arg2, %arg3, %arg4] : memref<1x384x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 384 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %189 = affine.apply #map5(%arg3)
            %190 = affine.apply #map5(%arg4)
            %191 = affine.load %75[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
            affine.store %191, %74[%arg1, %arg2, %189, %190] : memref<1x384x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 384 {
        affine.for %arg3 = 0 to 1 {
          %189 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 8 {
            affine.for %arg5 = 0 to 8 {
              affine.store %cst_0, %73[%arg1, %189, %arg4, %arg5] : memref<1x384x8x8xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %190 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %191 = affine.apply #map7(%arg4, %arg7)
                    %192 = affine.apply #map7(%arg5, %arg8)
                    %193 = affine.load %74[%arg1, %190, %191, %192] : memref<1x384x10x10xf32>
                    %194 = affine.load %154[%189, %arg6, %arg7, %arg8] : memref<384x1x3x3xf32>
                    %195 = affine.load %73[%arg1, %189, %arg4, %arg5] : memref<1x384x8x8xf32>
                    %196 = arith.mulf %193, %194 : f32
                    %197 = arith.addf %195, %196 : f32
                    affine.store %197, %73[%arg1, %189, %arg4, %arg5] : memref<1x384x8x8xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 384 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %189 = affine.load %73[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %72[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
          }
        }
      }
    }
    %155 = "krnl.global"() {name = "arith.constant_26", offset = 408320 : i64, shape = [64, 384, 1, 1]} : () -> memref<64x384x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_0, %71[%arg1, %arg2, %arg3, %arg4] : memref<1x64x8x8xf32>
            affine.for %arg5 = 0 to 384 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %72[%arg1, %arg5, %189, %190] : memref<1x384x8x8xf32>
                  %192 = affine.load %155[%arg2, %arg5, %arg6, %arg7] : memref<64x384x1x1xf32>
                  %193 = affine.load %71[%arg1, %arg2, %arg3, %arg4] : memref<1x64x8x8xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %71[%arg1, %arg2, %arg3, %arg4] : memref<1x64x8x8xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %189 = affine.load %71[%arg1, %arg2, %arg3, %arg4] : memref<1x64x8x8xf32>
            %190 = affine.load %77[%arg1, %arg2, %arg3, %arg4] : memref<1x64x8x8xf32>
            %191 = arith.addf %189, %190 : f32
            affine.store %191, %70[%arg1, %arg2, %arg3, %arg4] : memref<1x64x8x8xf32>
          }
        }
      }
    }
    %156 = "krnl.global"() {name = "arith.constant_27", offset = 506624 : i64, shape = [384, 64, 1, 1]} : () -> memref<384x64x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 384 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_0, %69[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
            affine.for %arg5 = 0 to 64 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %70[%arg1, %arg5, %189, %190] : memref<1x64x8x8xf32>
                  %192 = affine.load %156[%arg2, %arg5, %arg6, %arg7] : memref<384x64x1x1xf32>
                  %193 = affine.load %69[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %69[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 384 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %189 = affine.load %69[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %68[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
          }
        }
      }
    }
    %157 = "krnl.global"() {name = "arith.constant_28", offset = 604928 : i64, shape = [384, 1, 3, 3]} : () -> memref<384x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 384 {
        affine.for %arg3 = 0 to 10 {
          affine.for %arg4 = 0 to 10 {
            affine.store %cst_0, %67[%arg1, %arg2, %arg3, %arg4] : memref<1x384x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 384 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %189 = affine.apply #map5(%arg3)
            %190 = affine.apply #map5(%arg4)
            %191 = affine.load %68[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
            affine.store %191, %67[%arg1, %arg2, %189, %190] : memref<1x384x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 384 {
        affine.for %arg3 = 0 to 1 {
          %189 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 8 {
            affine.for %arg5 = 0 to 8 {
              affine.store %cst_0, %66[%arg1, %189, %arg4, %arg5] : memref<1x384x8x8xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %190 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %191 = affine.apply #map7(%arg4, %arg7)
                    %192 = affine.apply #map7(%arg5, %arg8)
                    %193 = affine.load %67[%arg1, %190, %191, %192] : memref<1x384x10x10xf32>
                    %194 = affine.load %157[%189, %arg6, %arg7, %arg8] : memref<384x1x3x3xf32>
                    %195 = affine.load %66[%arg1, %189, %arg4, %arg5] : memref<1x384x8x8xf32>
                    %196 = arith.mulf %193, %194 : f32
                    %197 = arith.addf %195, %196 : f32
                    affine.store %197, %66[%arg1, %189, %arg4, %arg5] : memref<1x384x8x8xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 384 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %189 = affine.load %66[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %65[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
          }
        }
      }
    }
    %158 = "krnl.global"() {name = "arith.constant_29", offset = 618752 : i64, shape = [64, 384, 1, 1]} : () -> memref<64x384x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_0, %64[%arg1, %arg2, %arg3, %arg4] : memref<1x64x8x8xf32>
            affine.for %arg5 = 0 to 384 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %65[%arg1, %arg5, %189, %190] : memref<1x384x8x8xf32>
                  %192 = affine.load %158[%arg2, %arg5, %arg6, %arg7] : memref<64x384x1x1xf32>
                  %193 = affine.load %64[%arg1, %arg2, %arg3, %arg4] : memref<1x64x8x8xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %64[%arg1, %arg2, %arg3, %arg4] : memref<1x64x8x8xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %189 = affine.load %64[%arg1, %arg2, %arg3, %arg4] : memref<1x64x8x8xf32>
            %190 = affine.load %70[%arg1, %arg2, %arg3, %arg4] : memref<1x64x8x8xf32>
            %191 = arith.addf %189, %190 : f32
            affine.store %191, %63[%arg1, %arg2, %arg3, %arg4] : memref<1x64x8x8xf32>
          }
        }
      }
    }
    %159 = "krnl.global"() {name = "arith.constant_30", offset = 717056 : i64, shape = [384, 64, 1, 1]} : () -> memref<384x64x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 384 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_0, %62[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
            affine.for %arg5 = 0 to 64 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %63[%arg1, %arg5, %189, %190] : memref<1x64x8x8xf32>
                  %192 = affine.load %159[%arg2, %arg5, %arg6, %arg7] : memref<384x64x1x1xf32>
                  %193 = affine.load %62[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %62[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 384 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %189 = affine.load %62[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %61[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
          }
        }
      }
    }
    %160 = "krnl.global"() {name = "arith.constant_31", offset = 815360 : i64, shape = [384, 1, 3, 3]} : () -> memref<384x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 384 {
        affine.for %arg3 = 0 to 10 {
          affine.for %arg4 = 0 to 10 {
            affine.store %cst_0, %60[%arg1, %arg2, %arg3, %arg4] : memref<1x384x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 384 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %189 = affine.apply #map5(%arg3)
            %190 = affine.apply #map5(%arg4)
            %191 = affine.load %61[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
            affine.store %191, %60[%arg1, %arg2, %189, %190] : memref<1x384x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 384 {
        affine.for %arg3 = 0 to 1 {
          %189 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 8 {
            affine.for %arg5 = 0 to 8 {
              affine.store %cst_0, %59[%arg1, %189, %arg4, %arg5] : memref<1x384x8x8xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %190 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %191 = affine.apply #map7(%arg4, %arg7)
                    %192 = affine.apply #map7(%arg5, %arg8)
                    %193 = affine.load %60[%arg1, %190, %191, %192] : memref<1x384x10x10xf32>
                    %194 = affine.load %160[%189, %arg6, %arg7, %arg8] : memref<384x1x3x3xf32>
                    %195 = affine.load %59[%arg1, %189, %arg4, %arg5] : memref<1x384x8x8xf32>
                    %196 = arith.mulf %193, %194 : f32
                    %197 = arith.addf %195, %196 : f32
                    affine.store %197, %59[%arg1, %189, %arg4, %arg5] : memref<1x384x8x8xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 384 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %189 = affine.load %59[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %58[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
          }
        }
      }
    }
    %161 = "krnl.global"() {name = "arith.constant_32", offset = 829184 : i64, shape = [64, 384, 1, 1]} : () -> memref<64x384x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_0, %57[%arg1, %arg2, %arg3, %arg4] : memref<1x64x8x8xf32>
            affine.for %arg5 = 0 to 384 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %58[%arg1, %arg5, %189, %190] : memref<1x384x8x8xf32>
                  %192 = affine.load %161[%arg2, %arg5, %arg6, %arg7] : memref<64x384x1x1xf32>
                  %193 = affine.load %57[%arg1, %arg2, %arg3, %arg4] : memref<1x64x8x8xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %57[%arg1, %arg2, %arg3, %arg4] : memref<1x64x8x8xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %189 = affine.load %57[%arg1, %arg2, %arg3, %arg4] : memref<1x64x8x8xf32>
            %190 = affine.load %63[%arg1, %arg2, %arg3, %arg4] : memref<1x64x8x8xf32>
            %191 = arith.addf %189, %190 : f32
            affine.store %191, %56[%arg1, %arg2, %arg3, %arg4] : memref<1x64x8x8xf32>
          }
        }
      }
    }
    %162 = "krnl.global"() {name = "arith.constant_33", offset = 927488 : i64, shape = [384, 64, 1, 1]} : () -> memref<384x64x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 384 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_0, %55[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
            affine.for %arg5 = 0 to 64 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %56[%arg1, %arg5, %189, %190] : memref<1x64x8x8xf32>
                  %192 = affine.load %162[%arg2, %arg5, %arg6, %arg7] : memref<384x64x1x1xf32>
                  %193 = affine.load %55[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %55[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 384 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %189 = affine.load %55[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %54[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
          }
        }
      }
    }
    %163 = "krnl.global"() {name = "arith.constant_34", offset = 1025792 : i64, shape = [384, 1, 3, 3]} : () -> memref<384x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 384 {
        affine.for %arg3 = 0 to 10 {
          affine.for %arg4 = 0 to 10 {
            affine.store %cst_0, %53[%arg1, %arg2, %arg3, %arg4] : memref<1x384x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 384 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %189 = affine.apply #map5(%arg3)
            %190 = affine.apply #map5(%arg4)
            %191 = affine.load %54[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
            affine.store %191, %53[%arg1, %arg2, %189, %190] : memref<1x384x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 384 {
        affine.for %arg3 = 0 to 1 {
          %189 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 8 {
            affine.for %arg5 = 0 to 8 {
              affine.store %cst_0, %52[%arg1, %189, %arg4, %arg5] : memref<1x384x8x8xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %190 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %191 = affine.apply #map7(%arg4, %arg7)
                    %192 = affine.apply #map7(%arg5, %arg8)
                    %193 = affine.load %53[%arg1, %190, %191, %192] : memref<1x384x10x10xf32>
                    %194 = affine.load %163[%189, %arg6, %arg7, %arg8] : memref<384x1x3x3xf32>
                    %195 = affine.load %52[%arg1, %189, %arg4, %arg5] : memref<1x384x8x8xf32>
                    %196 = arith.mulf %193, %194 : f32
                    %197 = arith.addf %195, %196 : f32
                    affine.store %197, %52[%arg1, %189, %arg4, %arg5] : memref<1x384x8x8xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 384 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %189 = affine.load %52[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %51[%arg1, %arg2, %arg3, %arg4] : memref<1x384x8x8xf32>
          }
        }
      }
    }
    %164 = "krnl.global"() {name = "arith.constant_35", offset = 1039616 : i64, shape = [96, 384, 1, 1]} : () -> memref<96x384x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 96 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_0, %50[%arg1, %arg2, %arg3, %arg4] : memref<1x96x8x8xf32>
            affine.for %arg5 = 0 to 384 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %51[%arg1, %arg5, %189, %190] : memref<1x384x8x8xf32>
                  %192 = affine.load %164[%arg2, %arg5, %arg6, %arg7] : memref<96x384x1x1xf32>
                  %193 = affine.load %50[%arg1, %arg2, %arg3, %arg4] : memref<1x96x8x8xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %50[%arg1, %arg2, %arg3, %arg4] : memref<1x96x8x8xf32>
                }
              }
            }
          }
        }
      }
    }
    %165 = "krnl.global"() {name = "arith.constant_36", offset = 1187072 : i64, shape = [96, 64, 1, 1]} : () -> memref<96x64x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 96 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_0, %49[%arg1, %arg2, %arg3, %arg4] : memref<1x96x8x8xf32>
            affine.for %arg5 = 0 to 64 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %56[%arg1, %arg5, %189, %190] : memref<1x64x8x8xf32>
                  %192 = affine.load %165[%arg2, %arg5, %arg6, %arg7] : memref<96x64x1x1xf32>
                  %193 = affine.load %49[%arg1, %arg2, %arg3, %arg4] : memref<1x96x8x8xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %49[%arg1, %arg2, %arg3, %arg4] : memref<1x96x8x8xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 96 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %189 = affine.load %50[%arg1, %arg2, %arg3, %arg4] : memref<1x96x8x8xf32>
            %190 = affine.load %49[%arg1, %arg2, %arg3, %arg4] : memref<1x96x8x8xf32>
            %191 = arith.addf %189, %190 : f32
            affine.store %191, %48[%arg1, %arg2, %arg3, %arg4] : memref<1x96x8x8xf32>
          }
        }
      }
    }
    %166 = "krnl.global"() {name = "arith.constant_37", offset = 1211648 : i64, shape = [576, 96, 1, 1]} : () -> memref<576x96x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 576 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_0, %47[%arg1, %arg2, %arg3, %arg4] : memref<1x576x8x8xf32>
            affine.for %arg5 = 0 to 96 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %48[%arg1, %arg5, %189, %190] : memref<1x96x8x8xf32>
                  %192 = affine.load %166[%arg2, %arg5, %arg6, %arg7] : memref<576x96x1x1xf32>
                  %193 = affine.load %47[%arg1, %arg2, %arg3, %arg4] : memref<1x576x8x8xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %47[%arg1, %arg2, %arg3, %arg4] : memref<1x576x8x8xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 576 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %189 = affine.load %47[%arg1, %arg2, %arg3, %arg4] : memref<1x576x8x8xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %46[%arg1, %arg2, %arg3, %arg4] : memref<1x576x8x8xf32>
          }
        }
      }
    }
    %167 = "krnl.global"() {name = "arith.constant_38", offset = 1432832 : i64, shape = [576, 1, 3, 3]} : () -> memref<576x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 576 {
        affine.for %arg3 = 0 to 10 {
          affine.for %arg4 = 0 to 10 {
            affine.store %cst_0, %45[%arg1, %arg2, %arg3, %arg4] : memref<1x576x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 576 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %189 = affine.apply #map5(%arg3)
            %190 = affine.apply #map5(%arg4)
            %191 = affine.load %46[%arg1, %arg2, %arg3, %arg4] : memref<1x576x8x8xf32>
            affine.store %191, %45[%arg1, %arg2, %189, %190] : memref<1x576x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 576 {
        affine.for %arg3 = 0 to 1 {
          %189 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 8 {
            affine.for %arg5 = 0 to 8 {
              affine.store %cst_0, %44[%arg1, %189, %arg4, %arg5] : memref<1x576x8x8xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %190 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %191 = affine.apply #map7(%arg4, %arg7)
                    %192 = affine.apply #map7(%arg5, %arg8)
                    %193 = affine.load %45[%arg1, %190, %191, %192] : memref<1x576x10x10xf32>
                    %194 = affine.load %167[%189, %arg6, %arg7, %arg8] : memref<576x1x3x3xf32>
                    %195 = affine.load %44[%arg1, %189, %arg4, %arg5] : memref<1x576x8x8xf32>
                    %196 = arith.mulf %193, %194 : f32
                    %197 = arith.addf %195, %196 : f32
                    affine.store %197, %44[%arg1, %189, %arg4, %arg5] : memref<1x576x8x8xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 576 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %189 = affine.load %44[%arg1, %arg2, %arg3, %arg4] : memref<1x576x8x8xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %43[%arg1, %arg2, %arg3, %arg4] : memref<1x576x8x8xf32>
          }
        }
      }
    }
    %168 = "krnl.global"() {name = "arith.constant_39", offset = 1453568 : i64, shape = [96, 576, 1, 1]} : () -> memref<96x576x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 96 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_0, %42[%arg1, %arg2, %arg3, %arg4] : memref<1x96x8x8xf32>
            affine.for %arg5 = 0 to 576 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %43[%arg1, %arg5, %189, %190] : memref<1x576x8x8xf32>
                  %192 = affine.load %168[%arg2, %arg5, %arg6, %arg7] : memref<96x576x1x1xf32>
                  %193 = affine.load %42[%arg1, %arg2, %arg3, %arg4] : memref<1x96x8x8xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %42[%arg1, %arg2, %arg3, %arg4] : memref<1x96x8x8xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 96 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %189 = affine.load %42[%arg1, %arg2, %arg3, %arg4] : memref<1x96x8x8xf32>
            %190 = affine.load %48[%arg1, %arg2, %arg3, %arg4] : memref<1x96x8x8xf32>
            %191 = arith.addf %189, %190 : f32
            affine.store %191, %41[%arg1, %arg2, %arg3, %arg4] : memref<1x96x8x8xf32>
          }
        }
      }
    }
    %169 = "krnl.global"() {name = "arith.constant_40", offset = 1674752 : i64, shape = [576, 96, 1, 1]} : () -> memref<576x96x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 576 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_0, %40[%arg1, %arg2, %arg3, %arg4] : memref<1x576x8x8xf32>
            affine.for %arg5 = 0 to 96 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %41[%arg1, %arg5, %189, %190] : memref<1x96x8x8xf32>
                  %192 = affine.load %169[%arg2, %arg5, %arg6, %arg7] : memref<576x96x1x1xf32>
                  %193 = affine.load %40[%arg1, %arg2, %arg3, %arg4] : memref<1x576x8x8xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %40[%arg1, %arg2, %arg3, %arg4] : memref<1x576x8x8xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 576 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %189 = affine.load %40[%arg1, %arg2, %arg3, %arg4] : memref<1x576x8x8xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %39[%arg1, %arg2, %arg3, %arg4] : memref<1x576x8x8xf32>
          }
        }
      }
    }
    %170 = "krnl.global"() {name = "arith.constant_41", offset = 1895936 : i64, shape = [576, 1, 3, 3]} : () -> memref<576x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 576 {
        affine.for %arg3 = 0 to 10 {
          affine.for %arg4 = 0 to 10 {
            affine.store %cst_0, %38[%arg1, %arg2, %arg3, %arg4] : memref<1x576x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 576 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %189 = affine.apply #map5(%arg3)
            %190 = affine.apply #map5(%arg4)
            %191 = affine.load %39[%arg1, %arg2, %arg3, %arg4] : memref<1x576x8x8xf32>
            affine.store %191, %38[%arg1, %arg2, %189, %190] : memref<1x576x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 576 {
        affine.for %arg3 = 0 to 1 {
          %189 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 8 {
            affine.for %arg5 = 0 to 8 {
              affine.store %cst_0, %37[%arg1, %189, %arg4, %arg5] : memref<1x576x8x8xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %190 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %191 = affine.apply #map7(%arg4, %arg7)
                    %192 = affine.apply #map7(%arg5, %arg8)
                    %193 = affine.load %38[%arg1, %190, %191, %192] : memref<1x576x10x10xf32>
                    %194 = affine.load %170[%189, %arg6, %arg7, %arg8] : memref<576x1x3x3xf32>
                    %195 = affine.load %37[%arg1, %189, %arg4, %arg5] : memref<1x576x8x8xf32>
                    %196 = arith.mulf %193, %194 : f32
                    %197 = arith.addf %195, %196 : f32
                    affine.store %197, %37[%arg1, %189, %arg4, %arg5] : memref<1x576x8x8xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 576 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %189 = affine.load %37[%arg1, %arg2, %arg3, %arg4] : memref<1x576x8x8xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %36[%arg1, %arg2, %arg3, %arg4] : memref<1x576x8x8xf32>
          }
        }
      }
    }
    %171 = "krnl.global"() {name = "arith.constant_42", offset = 1916672 : i64, shape = [96, 576, 1, 1]} : () -> memref<96x576x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 96 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_0, %35[%arg1, %arg2, %arg3, %arg4] : memref<1x96x8x8xf32>
            affine.for %arg5 = 0 to 576 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %36[%arg1, %arg5, %189, %190] : memref<1x576x8x8xf32>
                  %192 = affine.load %171[%arg2, %arg5, %arg6, %arg7] : memref<96x576x1x1xf32>
                  %193 = affine.load %35[%arg1, %arg2, %arg3, %arg4] : memref<1x96x8x8xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %35[%arg1, %arg2, %arg3, %arg4] : memref<1x96x8x8xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 96 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %189 = affine.load %35[%arg1, %arg2, %arg3, %arg4] : memref<1x96x8x8xf32>
            %190 = affine.load %41[%arg1, %arg2, %arg3, %arg4] : memref<1x96x8x8xf32>
            %191 = arith.addf %189, %190 : f32
            affine.store %191, %34[%arg1, %arg2, %arg3, %arg4] : memref<1x96x8x8xf32>
          }
        }
      }
    }
    %172 = "krnl.global"() {name = "arith.constant_43", offset = 2137856 : i64, shape = [576, 96, 1, 1]} : () -> memref<576x96x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 576 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_0, %33[%arg1, %arg2, %arg3, %arg4] : memref<1x576x8x8xf32>
            affine.for %arg5 = 0 to 96 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %34[%arg1, %arg5, %189, %190] : memref<1x96x8x8xf32>
                  %192 = affine.load %172[%arg2, %arg5, %arg6, %arg7] : memref<576x96x1x1xf32>
                  %193 = affine.load %33[%arg1, %arg2, %arg3, %arg4] : memref<1x576x8x8xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %33[%arg1, %arg2, %arg3, %arg4] : memref<1x576x8x8xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 576 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %189 = affine.load %33[%arg1, %arg2, %arg3, %arg4] : memref<1x576x8x8xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %32[%arg1, %arg2, %arg3, %arg4] : memref<1x576x8x8xf32>
          }
        }
      }
    }
    %173 = "krnl.global"() {name = "arith.constant_44", offset = 2359040 : i64, shape = [576, 1, 3, 3]} : () -> memref<576x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 576 {
        affine.for %arg3 = 0 to 10 {
          affine.for %arg4 = 0 to 10 {
            affine.store %cst_0, %31[%arg1, %arg2, %arg3, %arg4] : memref<1x576x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 576 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %189 = affine.apply #map5(%arg3)
            %190 = affine.apply #map5(%arg4)
            %191 = affine.load %32[%arg1, %arg2, %arg3, %arg4] : memref<1x576x8x8xf32>
            affine.store %191, %31[%arg1, %arg2, %189, %190] : memref<1x576x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 576 {
        affine.for %arg3 = 0 to 1 {
          %189 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 4 {
            affine.for %arg5 = 0 to 4 {
              affine.store %cst_0, %30[%arg1, %189, %arg4, %arg5] : memref<1x576x4x4xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %190 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %191 = affine.apply #map13(%arg4, %arg7)
                    %192 = affine.apply #map13(%arg5, %arg8)
                    %193 = affine.load %31[%arg1, %190, %191, %192] : memref<1x576x10x10xf32>
                    %194 = affine.load %173[%189, %arg6, %arg7, %arg8] : memref<576x1x3x3xf32>
                    %195 = affine.load %30[%arg1, %189, %arg4, %arg5] : memref<1x576x4x4xf32>
                    %196 = arith.mulf %193, %194 : f32
                    %197 = arith.addf %195, %196 : f32
                    affine.store %197, %30[%arg1, %189, %arg4, %arg5] : memref<1x576x4x4xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 576 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %189 = affine.load %30[%arg1, %arg2, %arg3, %arg4] : memref<1x576x4x4xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %29[%arg1, %arg2, %arg3, %arg4] : memref<1x576x4x4xf32>
          }
        }
      }
    }
    %174 = "krnl.global"() {name = "arith.constant_45", offset = 2379776 : i64, shape = [160, 576, 1, 1]} : () -> memref<160x576x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 160 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_0, %28[%arg1, %arg2, %arg3, %arg4] : memref<1x160x4x4xf32>
            affine.for %arg5 = 0 to 576 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %29[%arg1, %arg5, %189, %190] : memref<1x576x4x4xf32>
                  %192 = affine.load %174[%arg2, %arg5, %arg6, %arg7] : memref<160x576x1x1xf32>
                  %193 = affine.load %28[%arg1, %arg2, %arg3, %arg4] : memref<1x160x4x4xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %28[%arg1, %arg2, %arg3, %arg4] : memref<1x160x4x4xf32>
                }
              }
            }
          }
        }
      }
    }
    %175 = "krnl.global"() {name = "arith.constant_46", offset = 2748416 : i64, shape = [960, 160, 1, 1]} : () -> memref<960x160x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 960 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_0, %27[%arg1, %arg2, %arg3, %arg4] : memref<1x960x4x4xf32>
            affine.for %arg5 = 0 to 160 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %28[%arg1, %arg5, %189, %190] : memref<1x160x4x4xf32>
                  %192 = affine.load %175[%arg2, %arg5, %arg6, %arg7] : memref<960x160x1x1xf32>
                  %193 = affine.load %27[%arg1, %arg2, %arg3, %arg4] : memref<1x960x4x4xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %27[%arg1, %arg2, %arg3, %arg4] : memref<1x960x4x4xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 960 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %189 = affine.load %27[%arg1, %arg2, %arg3, %arg4] : memref<1x960x4x4xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %26[%arg1, %arg2, %arg3, %arg4] : memref<1x960x4x4xf32>
          }
        }
      }
    }
    %176 = "krnl.global"() {name = "arith.constant_47", offset = 3362816 : i64, shape = [960, 1, 3, 3]} : () -> memref<960x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 960 {
        affine.for %arg3 = 0 to 6 {
          affine.for %arg4 = 0 to 6 {
            affine.store %cst_0, %25[%arg1, %arg2, %arg3, %arg4] : memref<1x960x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 960 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %189 = affine.apply #map5(%arg3)
            %190 = affine.apply #map5(%arg4)
            %191 = affine.load %26[%arg1, %arg2, %arg3, %arg4] : memref<1x960x4x4xf32>
            affine.store %191, %25[%arg1, %arg2, %189, %190] : memref<1x960x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 960 {
        affine.for %arg3 = 0 to 1 {
          %189 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 4 {
            affine.for %arg5 = 0 to 4 {
              affine.store %cst_0, %24[%arg1, %189, %arg4, %arg5] : memref<1x960x4x4xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %190 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %191 = affine.apply #map7(%arg4, %arg7)
                    %192 = affine.apply #map7(%arg5, %arg8)
                    %193 = affine.load %25[%arg1, %190, %191, %192] : memref<1x960x6x6xf32>
                    %194 = affine.load %176[%189, %arg6, %arg7, %arg8] : memref<960x1x3x3xf32>
                    %195 = affine.load %24[%arg1, %189, %arg4, %arg5] : memref<1x960x4x4xf32>
                    %196 = arith.mulf %193, %194 : f32
                    %197 = arith.addf %195, %196 : f32
                    affine.store %197, %24[%arg1, %189, %arg4, %arg5] : memref<1x960x4x4xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 960 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %189 = affine.load %24[%arg1, %arg2, %arg3, %arg4] : memref<1x960x4x4xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %23[%arg1, %arg2, %arg3, %arg4] : memref<1x960x4x4xf32>
          }
        }
      }
    }
    %177 = "krnl.global"() {name = "arith.constant_48", offset = 3397376 : i64, shape = [160, 960, 1, 1]} : () -> memref<160x960x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 160 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_0, %22[%arg1, %arg2, %arg3, %arg4] : memref<1x160x4x4xf32>
            affine.for %arg5 = 0 to 960 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %23[%arg1, %arg5, %189, %190] : memref<1x960x4x4xf32>
                  %192 = affine.load %177[%arg2, %arg5, %arg6, %arg7] : memref<160x960x1x1xf32>
                  %193 = affine.load %22[%arg1, %arg2, %arg3, %arg4] : memref<1x160x4x4xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %22[%arg1, %arg2, %arg3, %arg4] : memref<1x160x4x4xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 160 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %189 = affine.load %22[%arg1, %arg2, %arg3, %arg4] : memref<1x160x4x4xf32>
            %190 = affine.load %28[%arg1, %arg2, %arg3, %arg4] : memref<1x160x4x4xf32>
            %191 = arith.addf %189, %190 : f32
            affine.store %191, %21[%arg1, %arg2, %arg3, %arg4] : memref<1x160x4x4xf32>
          }
        }
      }
    }
    %178 = "krnl.global"() {name = "arith.constant_49", offset = 4011776 : i64, shape = [960, 160, 1, 1]} : () -> memref<960x160x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 960 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_0, %20[%arg1, %arg2, %arg3, %arg4] : memref<1x960x4x4xf32>
            affine.for %arg5 = 0 to 160 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %21[%arg1, %arg5, %189, %190] : memref<1x160x4x4xf32>
                  %192 = affine.load %178[%arg2, %arg5, %arg6, %arg7] : memref<960x160x1x1xf32>
                  %193 = affine.load %20[%arg1, %arg2, %arg3, %arg4] : memref<1x960x4x4xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %20[%arg1, %arg2, %arg3, %arg4] : memref<1x960x4x4xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 960 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %189 = affine.load %20[%arg1, %arg2, %arg3, %arg4] : memref<1x960x4x4xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %19[%arg1, %arg2, %arg3, %arg4] : memref<1x960x4x4xf32>
          }
        }
      }
    }
    %179 = "krnl.global"() {name = "arith.constant_50", offset = 4626176 : i64, shape = [960, 1, 3, 3]} : () -> memref<960x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 960 {
        affine.for %arg3 = 0 to 6 {
          affine.for %arg4 = 0 to 6 {
            affine.store %cst_0, %18[%arg1, %arg2, %arg3, %arg4] : memref<1x960x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 960 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %189 = affine.apply #map5(%arg3)
            %190 = affine.apply #map5(%arg4)
            %191 = affine.load %19[%arg1, %arg2, %arg3, %arg4] : memref<1x960x4x4xf32>
            affine.store %191, %18[%arg1, %arg2, %189, %190] : memref<1x960x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 960 {
        affine.for %arg3 = 0 to 1 {
          %189 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 4 {
            affine.for %arg5 = 0 to 4 {
              affine.store %cst_0, %17[%arg1, %189, %arg4, %arg5] : memref<1x960x4x4xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %190 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %191 = affine.apply #map7(%arg4, %arg7)
                    %192 = affine.apply #map7(%arg5, %arg8)
                    %193 = affine.load %18[%arg1, %190, %191, %192] : memref<1x960x6x6xf32>
                    %194 = affine.load %179[%189, %arg6, %arg7, %arg8] : memref<960x1x3x3xf32>
                    %195 = affine.load %17[%arg1, %189, %arg4, %arg5] : memref<1x960x4x4xf32>
                    %196 = arith.mulf %193, %194 : f32
                    %197 = arith.addf %195, %196 : f32
                    affine.store %197, %17[%arg1, %189, %arg4, %arg5] : memref<1x960x4x4xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 960 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %189 = affine.load %17[%arg1, %arg2, %arg3, %arg4] : memref<1x960x4x4xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %16[%arg1, %arg2, %arg3, %arg4] : memref<1x960x4x4xf32>
          }
        }
      }
    }
    %180 = "krnl.global"() {name = "arith.constant_51", offset = 4660736 : i64, shape = [160, 960, 1, 1]} : () -> memref<160x960x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 160 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_0, %15[%arg1, %arg2, %arg3, %arg4] : memref<1x160x4x4xf32>
            affine.for %arg5 = 0 to 960 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %16[%arg1, %arg5, %189, %190] : memref<1x960x4x4xf32>
                  %192 = affine.load %180[%arg2, %arg5, %arg6, %arg7] : memref<160x960x1x1xf32>
                  %193 = affine.load %15[%arg1, %arg2, %arg3, %arg4] : memref<1x160x4x4xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %15[%arg1, %arg2, %arg3, %arg4] : memref<1x160x4x4xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 160 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %189 = affine.load %15[%arg1, %arg2, %arg3, %arg4] : memref<1x160x4x4xf32>
            %190 = affine.load %21[%arg1, %arg2, %arg3, %arg4] : memref<1x160x4x4xf32>
            %191 = arith.addf %189, %190 : f32
            affine.store %191, %14[%arg1, %arg2, %arg3, %arg4] : memref<1x160x4x4xf32>
          }
        }
      }
    }
    %181 = "krnl.global"() {name = "arith.constant_52", offset = 5275136 : i64, shape = [960, 160, 1, 1]} : () -> memref<960x160x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 960 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_0, %13[%arg1, %arg2, %arg3, %arg4] : memref<1x960x4x4xf32>
            affine.for %arg5 = 0 to 160 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %14[%arg1, %arg5, %189, %190] : memref<1x160x4x4xf32>
                  %192 = affine.load %181[%arg2, %arg5, %arg6, %arg7] : memref<960x160x1x1xf32>
                  %193 = affine.load %13[%arg1, %arg2, %arg3, %arg4] : memref<1x960x4x4xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %13[%arg1, %arg2, %arg3, %arg4] : memref<1x960x4x4xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 960 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %189 = affine.load %13[%arg1, %arg2, %arg3, %arg4] : memref<1x960x4x4xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %12[%arg1, %arg2, %arg3, %arg4] : memref<1x960x4x4xf32>
          }
        }
      }
    }
    %182 = "krnl.global"() {name = "arith.constant_53", offset = 5889536 : i64, shape = [960, 1, 3, 3]} : () -> memref<960x1x3x3xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 960 {
        affine.for %arg3 = 0 to 6 {
          affine.for %arg4 = 0 to 6 {
            affine.store %cst_0, %11[%arg1, %arg2, %arg3, %arg4] : memref<1x960x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 960 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %189 = affine.apply #map5(%arg3)
            %190 = affine.apply #map5(%arg4)
            %191 = affine.load %12[%arg1, %arg2, %arg3, %arg4] : memref<1x960x4x4xf32>
            affine.store %191, %11[%arg1, %arg2, %189, %190] : memref<1x960x6x6xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 960 {
        affine.for %arg3 = 0 to 1 {
          %189 = affine.apply #map8(%arg2, %arg3)[%c1]
          affine.for %arg4 = 0 to 4 {
            affine.for %arg5 = 0 to 4 {
              affine.store %cst_0, %10[%arg1, %189, %arg4, %arg5] : memref<1x960x4x4xf32>
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 3 {
                  affine.for %arg8 = 0 to 3 {
                    %190 = affine.apply #map8(%arg2, %arg6)[%c1]
                    %191 = affine.apply #map7(%arg4, %arg7)
                    %192 = affine.apply #map7(%arg5, %arg8)
                    %193 = affine.load %11[%arg1, %190, %191, %192] : memref<1x960x6x6xf32>
                    %194 = affine.load %182[%189, %arg6, %arg7, %arg8] : memref<960x1x3x3xf32>
                    %195 = affine.load %10[%arg1, %189, %arg4, %arg5] : memref<1x960x4x4xf32>
                    %196 = arith.mulf %193, %194 : f32
                    %197 = arith.addf %195, %196 : f32
                    affine.store %197, %10[%arg1, %189, %arg4, %arg5] : memref<1x960x4x4xf32>
                  }
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 960 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %189 = affine.load %10[%arg1, %arg2, %arg3, %arg4] : memref<1x960x4x4xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %9[%arg1, %arg2, %arg3, %arg4] : memref<1x960x4x4xf32>
          }
        }
      }
    }
    %183 = "krnl.global"() {name = "arith.constant_54", offset = 5924096 : i64, shape = [320, 960, 1, 1]} : () -> memref<320x960x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 320 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_0, %8[%arg1, %arg2, %arg3, %arg4] : memref<1x320x4x4xf32>
            affine.for %arg5 = 0 to 960 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %9[%arg1, %arg5, %189, %190] : memref<1x960x4x4xf32>
                  %192 = affine.load %183[%arg2, %arg5, %arg6, %arg7] : memref<320x960x1x1xf32>
                  %193 = affine.load %8[%arg1, %arg2, %arg3, %arg4] : memref<1x320x4x4xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %8[%arg1, %arg2, %arg3, %arg4] : memref<1x320x4x4xf32>
                }
              }
            }
          }
        }
      }
    }
    %184 = "krnl.global"() {name = "arith.constant_55", offset = 7152896 : i64, shape = [320, 160, 1, 1]} : () -> memref<320x160x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 320 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_0, %7[%arg1, %arg2, %arg3, %arg4] : memref<1x320x4x4xf32>
            affine.for %arg5 = 0 to 160 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %14[%arg1, %arg5, %189, %190] : memref<1x160x4x4xf32>
                  %192 = affine.load %184[%arg2, %arg5, %arg6, %arg7] : memref<320x160x1x1xf32>
                  %193 = affine.load %7[%arg1, %arg2, %arg3, %arg4] : memref<1x320x4x4xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %7[%arg1, %arg2, %arg3, %arg4] : memref<1x320x4x4xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 320 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %189 = affine.load %8[%arg1, %arg2, %arg3, %arg4] : memref<1x320x4x4xf32>
            %190 = affine.load %7[%arg1, %arg2, %arg3, %arg4] : memref<1x320x4x4xf32>
            %191 = arith.addf %189, %190 : f32
            affine.store %191, %6[%arg1, %arg2, %arg3, %arg4] : memref<1x320x4x4xf32>
          }
        }
      }
    }
    %185 = "krnl.global"() {name = "arith.constant_56", offset = 7357696 : i64, shape = [1280, 320, 1, 1]} : () -> memref<1280x320x1x1xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 1280 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_0, %5[%arg1, %arg2, %arg3, %arg4] : memref<1x1280x4x4xf32>
            affine.for %arg5 = 0 to 320 {
              affine.for %arg6 = 0 to 1 {
                affine.for %arg7 = 0 to 1 {
                  %189 = affine.apply #map7(%arg3, %arg6)
                  %190 = affine.apply #map7(%arg4, %arg7)
                  %191 = affine.load %6[%arg1, %arg5, %189, %190] : memref<1x320x4x4xf32>
                  %192 = affine.load %185[%arg2, %arg5, %arg6, %arg7] : memref<1280x320x1x1xf32>
                  %193 = affine.load %5[%arg1, %arg2, %arg3, %arg4] : memref<1x1280x4x4xf32>
                  %194 = arith.mulf %191, %192 : f32
                  %195 = arith.addf %193, %194 : f32
                  affine.store %195, %5[%arg1, %arg2, %arg3, %arg4] : memref<1x1280x4x4xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 1280 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %189 = affine.load %5[%arg1, %arg2, %arg3, %arg4] : memref<1x1280x4x4xf32>
            %190 = arith.cmpf "olt", %189, %cst_0 : f32
            %191 = select %190, %cst_0, %189 : f32
            affine.store %191, %4[%arg1, %arg2, %arg3, %arg4] : memref<1x1280x4x4xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 1280 {
        affine.for %arg3 = 0 to 1 {
          affine.for %arg4 = 0 to 1 {
            affine.store %cst_0, %3[%arg1, %arg2, %arg3, %arg4] : memref<1x1280x1x1xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 1280 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %189 = affine.load %4[%arg1, %arg2, %arg3, %arg4] : memref<1x1280x4x4xf32>
            %190 = affine.load %3[%arg1, %arg2, %c0, %c0] : memref<1x1280x1x1xf32>
            %191 = arith.addf %190, %189 : f32
            affine.store %191, %3[%arg1, %arg2, %c0, %c0] : memref<1x1280x1x1xf32>
          }
        }
      }
    }
    %186 = arith.uitofp %c16_i64 : i64 to f32
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 1280 {
        affine.for %arg3 = 0 to 1 {
          affine.for %arg4 = 0 to 1 {
            %189 = affine.load %3[%arg1, %arg2, %arg3, %arg4] : memref<1x1280x1x1xf32>
            %190 = arith.divf %189, %186 : f32
            affine.store %190, %3[%arg1, %arg2, %arg3, %arg4] : memref<1x1280x1x1xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 1280 {
        affine.for %arg3 = 0 to 1 {
          affine.for %arg4 = 0 to 1 {
            %189 = affine.load %3[%arg1, %arg2, %arg3, %arg4] : memref<1x1280x1x1xf32>
            %190 = affine.apply #map27(%arg2, %arg3, %arg4)[%c1280, %c1, %c1]
            affine.store %189, %2[%arg1, %190] : memref<1x1280xf32>
          }
        }
      }
    }
    %187 = "krnl.global"() {name = "arith.constant_57", offset = 8996096 : i64, shape = [10, 1280]} : () -> memref<10x1280xf32>
    %188 = "krnl.global"() {name = "arith.constant_58", offset = 9047296 : i64, shape = [10], value = dense<[0.00767956255, -0.0161089376, 0.0238970947, 0.0218298435, 0.0218633767, -0.00991072319, -0.0239866674, -0.00694712857, 0.0266246572, -0.0205942709]> : tensor<10xf32>} : () -> memref<10xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 10 {
        affine.store %cst_0, %1[%arg1, %arg2] : memref<1x10xf32>
        affine.for %arg3 = 0 to 1280 {
          %194 = affine.load %2[%arg1, %arg3] : memref<1x1280xf32>
          %195 = affine.load %187[%arg2, %arg3] : memref<10x1280xf32>
          %196 = affine.load %1[%arg1, %arg2] : memref<1x10xf32>
          %197 = arith.mulf %194, %195 : f32
          %198 = arith.addf %196, %197 : f32
          affine.store %198, %1[%arg1, %arg2] : memref<1x10xf32>
        }
        %189 = affine.load %1[%arg1, %arg2] : memref<1x10xf32>
        %190 = arith.mulf %cst, %189 : f32
        %191 = affine.load %188[%arg2] : memref<10xf32>
        %192 = arith.mulf %cst, %191 : f32
        %193 = arith.addf %190, %192 : f32
        affine.store %193, %1[%arg1, %arg2] : memref<1x10xf32>
      }
    }
    memref.dealloc %128 : memref<1x3x34x34xf32>
    memref.dealloc %127 : memref<1x32x32x32xf32>
    memref.dealloc %126 : memref<1x32x32x32xf32>
    memref.dealloc %125 : memref<1x32x32x32xf32>
    memref.dealloc %124 : memref<1x32x32x32xf32>
    memref.dealloc %123 : memref<1x32x34x34xf32>
    memref.dealloc %122 : memref<1x32x32x32xf32>
    memref.dealloc %121 : memref<1x32x32x32xf32>
    memref.dealloc %120 : memref<1x16x32x32xf32>
    memref.dealloc %119 : memref<1x16x32x32xf32>
    memref.dealloc %118 : memref<1x16x32x32xf32>
    memref.dealloc %117 : memref<1x96x32x32xf32>
    memref.dealloc %116 : memref<1x96x32x32xf32>
    memref.dealloc %115 : memref<1x96x34x34xf32>
    memref.dealloc %114 : memref<1x96x32x32xf32>
    memref.dealloc %113 : memref<1x96x32x32xf32>
    memref.dealloc %112 : memref<1x24x32x32xf32>
    memref.dealloc %111 : memref<1x24x32x32xf32>
    memref.dealloc %110 : memref<1x24x32x32xf32>
    memref.dealloc %109 : memref<1x144x32x32xf32>
    memref.dealloc %108 : memref<1x144x32x32xf32>
    memref.dealloc %107 : memref<1x144x34x34xf32>
    memref.dealloc %106 : memref<1x144x32x32xf32>
    memref.dealloc %105 : memref<1x144x32x32xf32>
    memref.dealloc %104 : memref<1x24x32x32xf32>
    memref.dealloc %103 : memref<1x24x32x32xf32>
    memref.dealloc %102 : memref<1x144x32x32xf32>
    memref.dealloc %101 : memref<1x144x32x32xf32>
    memref.dealloc %100 : memref<1x144x34x34xf32>
    memref.dealloc %99 : memref<1x144x16x16xf32>
    memref.dealloc %98 : memref<1x144x16x16xf32>
    memref.dealloc %97 : memref<1x32x16x16xf32>
    memref.dealloc %96 : memref<1x192x16x16xf32>
    memref.dealloc %95 : memref<1x192x16x16xf32>
    memref.dealloc %94 : memref<1x192x18x18xf32>
    memref.dealloc %93 : memref<1x192x16x16xf32>
    memref.dealloc %92 : memref<1x192x16x16xf32>
    memref.dealloc %91 : memref<1x32x16x16xf32>
    memref.dealloc %90 : memref<1x32x16x16xf32>
    memref.dealloc %89 : memref<1x192x16x16xf32>
    memref.dealloc %88 : memref<1x192x16x16xf32>
    memref.dealloc %87 : memref<1x192x18x18xf32>
    memref.dealloc %86 : memref<1x192x16x16xf32>
    memref.dealloc %85 : memref<1x192x16x16xf32>
    memref.dealloc %84 : memref<1x32x16x16xf32>
    memref.dealloc %83 : memref<1x32x16x16xf32>
    memref.dealloc %82 : memref<1x192x16x16xf32>
    memref.dealloc %81 : memref<1x192x16x16xf32>
    memref.dealloc %80 : memref<1x192x18x18xf32>
    memref.dealloc %79 : memref<1x192x8x8xf32>
    memref.dealloc %78 : memref<1x192x8x8xf32>
    memref.dealloc %77 : memref<1x64x8x8xf32>
    memref.dealloc %76 : memref<1x384x8x8xf32>
    memref.dealloc %75 : memref<1x384x8x8xf32>
    memref.dealloc %74 : memref<1x384x10x10xf32>
    memref.dealloc %73 : memref<1x384x8x8xf32>
    memref.dealloc %72 : memref<1x384x8x8xf32>
    memref.dealloc %71 : memref<1x64x8x8xf32>
    memref.dealloc %70 : memref<1x64x8x8xf32>
    memref.dealloc %69 : memref<1x384x8x8xf32>
    memref.dealloc %68 : memref<1x384x8x8xf32>
    memref.dealloc %67 : memref<1x384x10x10xf32>
    memref.dealloc %66 : memref<1x384x8x8xf32>
    memref.dealloc %65 : memref<1x384x8x8xf32>
    memref.dealloc %64 : memref<1x64x8x8xf32>
    memref.dealloc %63 : memref<1x64x8x8xf32>
    memref.dealloc %62 : memref<1x384x8x8xf32>
    memref.dealloc %61 : memref<1x384x8x8xf32>
    memref.dealloc %60 : memref<1x384x10x10xf32>
    memref.dealloc %59 : memref<1x384x8x8xf32>
    memref.dealloc %58 : memref<1x384x8x8xf32>
    memref.dealloc %57 : memref<1x64x8x8xf32>
    memref.dealloc %56 : memref<1x64x8x8xf32>
    memref.dealloc %55 : memref<1x384x8x8xf32>
    memref.dealloc %54 : memref<1x384x8x8xf32>
    memref.dealloc %53 : memref<1x384x10x10xf32>
    memref.dealloc %52 : memref<1x384x8x8xf32>
    memref.dealloc %51 : memref<1x384x8x8xf32>
    memref.dealloc %50 : memref<1x96x8x8xf32>
    memref.dealloc %49 : memref<1x96x8x8xf32>
    memref.dealloc %48 : memref<1x96x8x8xf32>
    memref.dealloc %47 : memref<1x576x8x8xf32>
    memref.dealloc %46 : memref<1x576x8x8xf32>
    memref.dealloc %45 : memref<1x576x10x10xf32>
    memref.dealloc %44 : memref<1x576x8x8xf32>
    memref.dealloc %43 : memref<1x576x8x8xf32>
    memref.dealloc %42 : memref<1x96x8x8xf32>
    memref.dealloc %41 : memref<1x96x8x8xf32>
    memref.dealloc %40 : memref<1x576x8x8xf32>
    memref.dealloc %39 : memref<1x576x8x8xf32>
    memref.dealloc %38 : memref<1x576x10x10xf32>
    memref.dealloc %37 : memref<1x576x8x8xf32>
    memref.dealloc %36 : memref<1x576x8x8xf32>
    memref.dealloc %35 : memref<1x96x8x8xf32>
    memref.dealloc %34 : memref<1x96x8x8xf32>
    memref.dealloc %33 : memref<1x576x8x8xf32>
    memref.dealloc %32 : memref<1x576x8x8xf32>
    memref.dealloc %31 : memref<1x576x10x10xf32>
    memref.dealloc %30 : memref<1x576x4x4xf32>
    memref.dealloc %29 : memref<1x576x4x4xf32>
    memref.dealloc %28 : memref<1x160x4x4xf32>
    memref.dealloc %27 : memref<1x960x4x4xf32>
    memref.dealloc %26 : memref<1x960x4x4xf32>
    memref.dealloc %25 : memref<1x960x6x6xf32>
    memref.dealloc %24 : memref<1x960x4x4xf32>
    memref.dealloc %23 : memref<1x960x4x4xf32>
    memref.dealloc %22 : memref<1x160x4x4xf32>
    memref.dealloc %21 : memref<1x160x4x4xf32>
    memref.dealloc %20 : memref<1x960x4x4xf32>
    memref.dealloc %19 : memref<1x960x4x4xf32>
    memref.dealloc %18 : memref<1x960x6x6xf32>
    memref.dealloc %17 : memref<1x960x4x4xf32>
    memref.dealloc %16 : memref<1x960x4x4xf32>
    memref.dealloc %15 : memref<1x160x4x4xf32>
    memref.dealloc %14 : memref<1x160x4x4xf32>
    memref.dealloc %13 : memref<1x960x4x4xf32>
    memref.dealloc %12 : memref<1x960x4x4xf32>
    memref.dealloc %11 : memref<1x960x6x6xf32>
    memref.dealloc %10 : memref<1x960x4x4xf32>
    memref.dealloc %9 : memref<1x960x4x4xf32>
    memref.dealloc %8 : memref<1x320x4x4xf32>
    memref.dealloc %7 : memref<1x320x4x4xf32>
    memref.dealloc %6 : memref<1x320x4x4xf32>
    memref.dealloc %5 : memref<1x1280x4x4xf32>
    memref.dealloc %4 : memref<1x1280x4x4xf32>
    memref.dealloc %3 : memref<1x1280x1x1xf32>
    memref.dealloc %2 : memref<1x1280xf32>
    return %1 : memref<1x10xf32>
  }
  "krnl.entry_point"() {func = @main_graph, numInputs = 1 : i32, numOutputs = 1 : i32} : () -> ()
}
