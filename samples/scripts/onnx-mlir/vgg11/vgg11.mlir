#map0 = affine_map<(d0, d1) -> (0, d0 - 1)>
#map1 = affine_map<(d0, d1, d2, d3) -> (0, d2 - 1)>
#map2 = affine_map<(d0) -> (32, -(d0 - 1) + 32, d0 + 2, d0 - (d0 - 1) + 2)>
#map3 = affine_map<(d0, d1) -> (0, d0 * 2)>
#map4 = affine_map<(d0, d1, d2, d3) -> (0, d2 * 2)>
#map5 = affine_map<(d0) -> (32, d0 * -2 + 32, d0 * 2 + 2, 2)>
#map6 = affine_map<(d0) -> (16, -(d0 - 1) + 16, d0 + 2, d0 - (d0 - 1) + 2)>
#map7 = affine_map<(d0) -> (16, d0 * -2 + 16, d0 * 2 + 2, 2)>
#map8 = affine_map<(d0) -> (8, -(d0 - 1) + 8, d0 + 2, d0 - (d0 - 1) + 2)>
#map9 = affine_map<(d0) -> (8, d0 * -2 + 8, d0 * 2 + 2, 2)>
#map10 = affine_map<(d0) -> (4, -(d0 - 1) + 4, d0 + 2, d0 - (d0 - 1) + 2)>
#map11 = affine_map<(d0) -> (4, d0 * -2 + 4, d0 * 2 + 2, 2)>
#map12 = affine_map<(d0) -> (2, -(d0 - 1) + 2, d0 + 2, d0 - (d0 - 1) + 2)>
#map13 = affine_map<(d0) -> (2, d0 * -2 + 2, d0 * 2 + 2, 2)>
#map14 = affine_map<(d0, d1, d2)[s0, s1, s2] -> (d2 + d1 * s2 + d0 * (s1 * s2))>
module  {
  %0 = "krnl.packed_const"() {file_name = "/tmp/packed_const-91d1d1.tmp", is_le = true, size_in_bytes = 36902400 : i64} : () -> i64
  func @main_graph(%arg0: memref<1x3x32x32xf32>) -> memref<1x10xf32> attributes {input_names = ["input.1"], output_names = ["41"]} {
    %c32 = constant 32 : index
    %c16 = constant 16 : index
    %c8 = constant 8 : index
    %c4 = constant 4 : index
    %c3 = constant 3 : index
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
    %6 = memref.alloc() : memref<1x512x2x2xf32>
    %7 = memref.alloc() : memref<1x512x2x2xf32>
    %8 = memref.alloc() : memref<1x512x2x2xf32>
    %9 = memref.alloc() : memref<1x512x4x4xf32>
    %10 = memref.alloc() : memref<1x512x4x4xf32>
    %11 = memref.alloc() : memref<1x512x4x4xf32>
    %12 = memref.alloc() : memref<1x512x4x4xf32>
    %13 = memref.alloc() : memref<1x256x4x4xf32>
    %14 = memref.alloc() : memref<1x256x8x8xf32>
    %15 = memref.alloc() : memref<1x256x8x8xf32>
    %16 = memref.alloc() : memref<1x256x8x8xf32>
    %17 = memref.alloc() : memref<1x256x8x8xf32>
    %18 = memref.alloc() : memref<1x128x8x8xf32>
    %19 = memref.alloc() : memref<1x128x16x16xf32>
    %20 = memref.alloc() : memref<1x128x16x16xf32>
    %21 = memref.alloc() : memref<1x64x16x16xf32>
    %22 = memref.alloc() : memref<1x64x32x32xf32>
    %23 = memref.alloc() : memref<1x64x32x32xf32>
    %24 = "krnl.global"() {name = "constant_0", offset = 0 : i64, shape = [64, 3, 3, 3]} : () -> memref<64x3x3x3xf32>
    %25 = "krnl.global"() {name = "constant_1", offset = 6912 : i64, shape = [64]} : () -> memref<64xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            affine.store %cst_1, %23[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            %42 = memref.alloca() : memref<f32>
            affine.store %cst_1, %42[] : memref<f32>
            %43 = affine.max #map0(%arg3, %arg3)
            %44 = affine.min #map0(%arg3, %arg3)
            %45 = affine.max #map1(%arg3, %arg3, %arg4, %arg4)
            %46 = affine.min #map1(%arg3, %arg3, %arg4, %arg4)
            affine.for %arg5 = 0 to 3 {
              affine.for %arg6 = 0 to min #map2(%arg3) {
                affine.for %arg7 = 0 to min #map2(%arg4) {
                  %50 = addi %arg6, %43 : index
                  %51 = addi %arg7, %45 : index
                  %52 = subi %arg6, %44 : index
                  %53 = subi %arg7, %46 : index
                  %54 = memref.load %arg0[%arg1, %arg5, %50, %51] : memref<1x3x32x32xf32>
                  %55 = memref.load %24[%arg2, %arg5, %52, %53] : memref<64x3x3x3xf32>
                  %56 = affine.load %42[] : memref<f32>
                  %57 = mulf %54, %55 : f32
                  %58 = addf %56, %57 : f32
                  affine.store %58, %42[] : memref<f32>
                }
              }
            }
            %47 = affine.load %42[] : memref<f32>
            %48 = affine.load %25[%arg2] : memref<64xf32>
            %49 = addf %47, %48 : f32
            affine.store %49, %23[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 32 {
          affine.for %arg4 = 0 to 32 {
            %42 = affine.load %23[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
            %43 = cmpf "olt", %42, %cst_1 : f32
            %44 = select %43, %cst_1, %42 : f32
            affine.store %44, %22[%arg1, %arg2, %arg3, %arg4] : memref<1x64x32x32xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 64 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %42 = memref.alloca() : memref<f32>
            affine.store %cst, %42[] : memref<f32>
            %43 = affine.max #map3(%arg3, %arg3)
            %44 = affine.max #map4(%arg3, %arg3, %arg4, %arg4)
            affine.for %arg5 = 0 to min #map5(%arg3) {
              affine.for %arg6 = 0 to min #map5(%arg4) {
                %46 = addi %arg5, %43 : index
                %47 = addi %arg6, %44 : index
                %48 = memref.load %22[%arg1, %arg2, %46, %47] : memref<1x64x32x32xf32>
                %49 = affine.load %42[] : memref<f32>
                %50 = cmpf "ogt", %49, %48 : f32
                %51 = select %50, %49, %48 : f32
                affine.store %51, %42[] : memref<f32>
              }
            }
            %45 = affine.load %42[] : memref<f32>
            affine.store %45, %21[%arg1, %arg2, %arg3, %arg4] : memref<1x64x16x16xf32>
          }
        }
      }
    }
    %26 = "krnl.global"() {name = "constant_2", offset = 7168 : i64, shape = [128, 64, 3, 3]} : () -> memref<128x64x3x3xf32>
    %27 = "krnl.global"() {name = "constant_3", offset = 302080 : i64, shape = [128]} : () -> memref<128xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            affine.store %cst_1, %20[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            %42 = memref.alloca() : memref<f32>
            affine.store %cst_1, %42[] : memref<f32>
            %43 = affine.max #map0(%arg3, %arg3)
            %44 = affine.min #map0(%arg3, %arg3)
            %45 = affine.max #map1(%arg3, %arg3, %arg4, %arg4)
            %46 = affine.min #map1(%arg3, %arg3, %arg4, %arg4)
            affine.for %arg5 = 0 to 64 {
              affine.for %arg6 = 0 to min #map6(%arg3) {
                affine.for %arg7 = 0 to min #map6(%arg4) {
                  %50 = addi %arg6, %43 : index
                  %51 = addi %arg7, %45 : index
                  %52 = subi %arg6, %44 : index
                  %53 = subi %arg7, %46 : index
                  %54 = memref.load %21[%arg1, %arg5, %50, %51] : memref<1x64x16x16xf32>
                  %55 = memref.load %26[%arg2, %arg5, %52, %53] : memref<128x64x3x3xf32>
                  %56 = affine.load %42[] : memref<f32>
                  %57 = mulf %54, %55 : f32
                  %58 = addf %56, %57 : f32
                  affine.store %58, %42[] : memref<f32>
                }
              }
            }
            %47 = affine.load %42[] : memref<f32>
            %48 = affine.load %27[%arg2] : memref<128xf32>
            %49 = addf %47, %48 : f32
            affine.store %49, %20[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 16 {
          affine.for %arg4 = 0 to 16 {
            %42 = affine.load %20[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
            %43 = cmpf "olt", %42, %cst_1 : f32
            %44 = select %43, %cst_1, %42 : f32
            affine.store %44, %19[%arg1, %arg2, %arg3, %arg4] : memref<1x128x16x16xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 128 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %42 = memref.alloca() : memref<f32>
            affine.store %cst, %42[] : memref<f32>
            %43 = affine.max #map3(%arg3, %arg3)
            %44 = affine.max #map4(%arg3, %arg3, %arg4, %arg4)
            affine.for %arg5 = 0 to min #map7(%arg3) {
              affine.for %arg6 = 0 to min #map7(%arg4) {
                %46 = addi %arg5, %43 : index
                %47 = addi %arg6, %44 : index
                %48 = memref.load %19[%arg1, %arg2, %46, %47] : memref<1x128x16x16xf32>
                %49 = affine.load %42[] : memref<f32>
                %50 = cmpf "ogt", %49, %48 : f32
                %51 = select %50, %49, %48 : f32
                affine.store %51, %42[] : memref<f32>
              }
            }
            %45 = affine.load %42[] : memref<f32>
            affine.store %45, %18[%arg1, %arg2, %arg3, %arg4] : memref<1x128x8x8xf32>
          }
        }
      }
    }
    %28 = "krnl.global"() {name = "constant_4", offset = 302592 : i64, shape = [256, 128, 3, 3]} : () -> memref<256x128x3x3xf32>
    %29 = "krnl.global"() {name = "constant_5", offset = 1482240 : i64, shape = [256]} : () -> memref<256xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_1, %17[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            %42 = memref.alloca() : memref<f32>
            affine.store %cst_1, %42[] : memref<f32>
            %43 = affine.max #map0(%arg3, %arg3)
            %44 = affine.min #map0(%arg3, %arg3)
            %45 = affine.max #map1(%arg3, %arg3, %arg4, %arg4)
            %46 = affine.min #map1(%arg3, %arg3, %arg4, %arg4)
            affine.for %arg5 = 0 to 128 {
              affine.for %arg6 = 0 to min #map8(%arg3) {
                affine.for %arg7 = 0 to min #map8(%arg4) {
                  %50 = addi %arg6, %43 : index
                  %51 = addi %arg7, %45 : index
                  %52 = subi %arg6, %44 : index
                  %53 = subi %arg7, %46 : index
                  %54 = memref.load %18[%arg1, %arg5, %50, %51] : memref<1x128x8x8xf32>
                  %55 = memref.load %28[%arg2, %arg5, %52, %53] : memref<256x128x3x3xf32>
                  %56 = affine.load %42[] : memref<f32>
                  %57 = mulf %54, %55 : f32
                  %58 = addf %56, %57 : f32
                  affine.store %58, %42[] : memref<f32>
                }
              }
            }
            %47 = affine.load %42[] : memref<f32>
            %48 = affine.load %29[%arg2] : memref<256xf32>
            %49 = addf %47, %48 : f32
            affine.store %49, %17[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %42 = affine.load %17[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            %43 = cmpf "olt", %42, %cst_1 : f32
            %44 = select %43, %cst_1, %42 : f32
            affine.store %44, %16[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
          }
        }
      }
    }
    %30 = "krnl.global"() {name = "constant_6", offset = 1483264 : i64, shape = [256, 256, 3, 3]} : () -> memref<256x256x3x3xf32>
    %31 = "krnl.global"() {name = "constant_7", offset = 3842560 : i64, shape = [256]} : () -> memref<256xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            affine.store %cst_1, %15[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            %42 = memref.alloca() : memref<f32>
            affine.store %cst_1, %42[] : memref<f32>
            %43 = affine.max #map0(%arg3, %arg3)
            %44 = affine.min #map0(%arg3, %arg3)
            %45 = affine.max #map1(%arg3, %arg3, %arg4, %arg4)
            %46 = affine.min #map1(%arg3, %arg3, %arg4, %arg4)
            affine.for %arg5 = 0 to 256 {
              affine.for %arg6 = 0 to min #map8(%arg3) {
                affine.for %arg7 = 0 to min #map8(%arg4) {
                  %50 = addi %arg6, %43 : index
                  %51 = addi %arg7, %45 : index
                  %52 = subi %arg6, %44 : index
                  %53 = subi %arg7, %46 : index
                  %54 = memref.load %16[%arg1, %arg5, %50, %51] : memref<1x256x8x8xf32>
                  %55 = memref.load %30[%arg2, %arg5, %52, %53] : memref<256x256x3x3xf32>
                  %56 = affine.load %42[] : memref<f32>
                  %57 = mulf %54, %55 : f32
                  %58 = addf %56, %57 : f32
                  affine.store %58, %42[] : memref<f32>
                }
              }
            }
            %47 = affine.load %42[] : memref<f32>
            %48 = affine.load %31[%arg2] : memref<256xf32>
            %49 = addf %47, %48 : f32
            affine.store %49, %15[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 8 {
          affine.for %arg4 = 0 to 8 {
            %42 = affine.load %15[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
            %43 = cmpf "olt", %42, %cst_1 : f32
            %44 = select %43, %cst_1, %42 : f32
            affine.store %44, %14[%arg1, %arg2, %arg3, %arg4] : memref<1x256x8x8xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 256 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %42 = memref.alloca() : memref<f32>
            affine.store %cst, %42[] : memref<f32>
            %43 = affine.max #map3(%arg3, %arg3)
            %44 = affine.max #map4(%arg3, %arg3, %arg4, %arg4)
            affine.for %arg5 = 0 to min #map9(%arg3) {
              affine.for %arg6 = 0 to min #map9(%arg4) {
                %46 = addi %arg5, %43 : index
                %47 = addi %arg6, %44 : index
                %48 = memref.load %14[%arg1, %arg2, %46, %47] : memref<1x256x8x8xf32>
                %49 = affine.load %42[] : memref<f32>
                %50 = cmpf "ogt", %49, %48 : f32
                %51 = select %50, %49, %48 : f32
                affine.store %51, %42[] : memref<f32>
              }
            }
            %45 = affine.load %42[] : memref<f32>
            affine.store %45, %13[%arg1, %arg2, %arg3, %arg4] : memref<1x256x4x4xf32>
          }
        }
      }
    }
    %32 = "krnl.global"() {name = "constant_8", offset = 3843584 : i64, shape = [512, 256, 3, 3]} : () -> memref<512x256x3x3xf32>
    %33 = "krnl.global"() {name = "constant_9", offset = 8562176 : i64, shape = [512]} : () -> memref<512xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_1, %12[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %42 = memref.alloca() : memref<f32>
            affine.store %cst_1, %42[] : memref<f32>
            %43 = affine.max #map0(%arg3, %arg3)
            %44 = affine.min #map0(%arg3, %arg3)
            %45 = affine.max #map1(%arg3, %arg3, %arg4, %arg4)
            %46 = affine.min #map1(%arg3, %arg3, %arg4, %arg4)
            affine.for %arg5 = 0 to 256 {
              affine.for %arg6 = 0 to min #map10(%arg3) {
                affine.for %arg7 = 0 to min #map10(%arg4) {
                  %50 = addi %arg6, %43 : index
                  %51 = addi %arg7, %45 : index
                  %52 = subi %arg6, %44 : index
                  %53 = subi %arg7, %46 : index
                  %54 = memref.load %13[%arg1, %arg5, %50, %51] : memref<1x256x4x4xf32>
                  %55 = memref.load %32[%arg2, %arg5, %52, %53] : memref<512x256x3x3xf32>
                  %56 = affine.load %42[] : memref<f32>
                  %57 = mulf %54, %55 : f32
                  %58 = addf %56, %57 : f32
                  affine.store %58, %42[] : memref<f32>
                }
              }
            }
            %47 = affine.load %42[] : memref<f32>
            %48 = affine.load %33[%arg2] : memref<512xf32>
            %49 = addf %47, %48 : f32
            affine.store %49, %12[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %42 = affine.load %12[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %43 = cmpf "olt", %42, %cst_1 : f32
            %44 = select %43, %cst_1, %42 : f32
            affine.store %44, %11[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    %34 = "krnl.global"() {name = "constant_10", offset = 8564224 : i64, shape = [512, 512, 3, 3]} : () -> memref<512x512x3x3xf32>
    %35 = "krnl.global"() {name = "constant_11", offset = 18001408 : i64, shape = [512]} : () -> memref<512xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            affine.store %cst_1, %10[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %42 = memref.alloca() : memref<f32>
            affine.store %cst_1, %42[] : memref<f32>
            %43 = affine.max #map0(%arg3, %arg3)
            %44 = affine.min #map0(%arg3, %arg3)
            %45 = affine.max #map1(%arg3, %arg3, %arg4, %arg4)
            %46 = affine.min #map1(%arg3, %arg3, %arg4, %arg4)
            affine.for %arg5 = 0 to 512 {
              affine.for %arg6 = 0 to min #map10(%arg3) {
                affine.for %arg7 = 0 to min #map10(%arg4) {
                  %50 = addi %arg6, %43 : index
                  %51 = addi %arg7, %45 : index
                  %52 = subi %arg6, %44 : index
                  %53 = subi %arg7, %46 : index
                  %54 = memref.load %11[%arg1, %arg5, %50, %51] : memref<1x512x4x4xf32>
                  %55 = memref.load %34[%arg2, %arg5, %52, %53] : memref<512x512x3x3xf32>
                  %56 = affine.load %42[] : memref<f32>
                  %57 = mulf %54, %55 : f32
                  %58 = addf %56, %57 : f32
                  affine.store %58, %42[] : memref<f32>
                }
              }
            }
            %47 = affine.load %42[] : memref<f32>
            %48 = affine.load %35[%arg2] : memref<512xf32>
            %49 = addf %47, %48 : f32
            affine.store %49, %10[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 4 {
          affine.for %arg4 = 0 to 4 {
            %42 = affine.load %10[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
            %43 = cmpf "olt", %42, %cst_1 : f32
            %44 = select %43, %cst_1, %42 : f32
            affine.store %44, %9[%arg1, %arg2, %arg3, %arg4] : memref<1x512x4x4xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            %42 = memref.alloca() : memref<f32>
            affine.store %cst, %42[] : memref<f32>
            %43 = affine.max #map3(%arg3, %arg3)
            %44 = affine.max #map4(%arg3, %arg3, %arg4, %arg4)
            affine.for %arg5 = 0 to min #map11(%arg3) {
              affine.for %arg6 = 0 to min #map11(%arg4) {
                %46 = addi %arg5, %43 : index
                %47 = addi %arg6, %44 : index
                %48 = memref.load %9[%arg1, %arg2, %46, %47] : memref<1x512x4x4xf32>
                %49 = affine.load %42[] : memref<f32>
                %50 = cmpf "ogt", %49, %48 : f32
                %51 = select %50, %49, %48 : f32
                affine.store %51, %42[] : memref<f32>
              }
            }
            %45 = affine.load %42[] : memref<f32>
            affine.store %45, %8[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
          }
        }
      }
    }
    %36 = "krnl.global"() {name = "constant_12", offset = 18003456 : i64, shape = [512, 512, 3, 3]} : () -> memref<512x512x3x3xf32>
    %37 = "krnl.global"() {name = "constant_13", offset = 27440640 : i64, shape = [512]} : () -> memref<512xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            affine.store %cst_1, %7[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            %42 = memref.alloca() : memref<f32>
            affine.store %cst_1, %42[] : memref<f32>
            %43 = affine.max #map0(%arg3, %arg3)
            %44 = affine.min #map0(%arg3, %arg3)
            %45 = affine.max #map1(%arg3, %arg3, %arg4, %arg4)
            %46 = affine.min #map1(%arg3, %arg3, %arg4, %arg4)
            affine.for %arg5 = 0 to 512 {
              affine.for %arg6 = 0 to min #map12(%arg3) {
                affine.for %arg7 = 0 to min #map12(%arg4) {
                  %50 = addi %arg6, %43 : index
                  %51 = addi %arg7, %45 : index
                  %52 = subi %arg6, %44 : index
                  %53 = subi %arg7, %46 : index
                  %54 = memref.load %8[%arg1, %arg5, %50, %51] : memref<1x512x2x2xf32>
                  %55 = memref.load %36[%arg2, %arg5, %52, %53] : memref<512x512x3x3xf32>
                  %56 = affine.load %42[] : memref<f32>
                  %57 = mulf %54, %55 : f32
                  %58 = addf %56, %57 : f32
                  affine.store %58, %42[] : memref<f32>
                }
              }
            }
            %47 = affine.load %42[] : memref<f32>
            %48 = affine.load %37[%arg2] : memref<512xf32>
            %49 = addf %47, %48 : f32
            affine.store %49, %7[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            %42 = affine.load %7[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            %43 = cmpf "olt", %42, %cst_1 : f32
            %44 = select %43, %cst_1, %42 : f32
            affine.store %44, %6[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
          }
        }
      }
    }
    %38 = "krnl.global"() {name = "constant_14", offset = 27442688 : i64, shape = [512, 512, 3, 3]} : () -> memref<512x512x3x3xf32>
    %39 = "krnl.global"() {name = "constant_15", offset = 36879872 : i64, shape = [512]} : () -> memref<512xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            affine.store %cst_1, %5[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            %42 = memref.alloca() : memref<f32>
            affine.store %cst_1, %42[] : memref<f32>
            %43 = affine.max #map0(%arg3, %arg3)
            %44 = affine.min #map0(%arg3, %arg3)
            %45 = affine.max #map1(%arg3, %arg3, %arg4, %arg4)
            %46 = affine.min #map1(%arg3, %arg3, %arg4, %arg4)
            affine.for %arg5 = 0 to 512 {
              affine.for %arg6 = 0 to min #map12(%arg3) {
                affine.for %arg7 = 0 to min #map12(%arg4) {
                  %50 = addi %arg6, %43 : index
                  %51 = addi %arg7, %45 : index
                  %52 = subi %arg6, %44 : index
                  %53 = subi %arg7, %46 : index
                  %54 = memref.load %6[%arg1, %arg5, %50, %51] : memref<1x512x2x2xf32>
                  %55 = memref.load %38[%arg2, %arg5, %52, %53] : memref<512x512x3x3xf32>
                  %56 = affine.load %42[] : memref<f32>
                  %57 = mulf %54, %55 : f32
                  %58 = addf %56, %57 : f32
                  affine.store %58, %42[] : memref<f32>
                }
              }
            }
            %47 = affine.load %42[] : memref<f32>
            %48 = affine.load %39[%arg2] : memref<512xf32>
            %49 = addf %47, %48 : f32
            affine.store %49, %5[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 2 {
          affine.for %arg4 = 0 to 2 {
            %42 = affine.load %5[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
            %43 = cmpf "olt", %42, %cst_1 : f32
            %44 = select %43, %cst_1, %42 : f32
            affine.store %44, %4[%arg1, %arg2, %arg3, %arg4] : memref<1x512x2x2xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 1 {
          affine.for %arg4 = 0 to 1 {
            %42 = memref.alloca() : memref<f32>
            affine.store %cst, %42[] : memref<f32>
            %43 = affine.max #map3(%arg3, %arg3)
            %44 = affine.max #map4(%arg3, %arg3, %arg4, %arg4)
            affine.for %arg5 = 0 to min #map13(%arg3) {
              affine.for %arg6 = 0 to min #map13(%arg4) {
                %46 = addi %arg5, %43 : index
                %47 = addi %arg6, %44 : index
                %48 = memref.load %4[%arg1, %arg2, %46, %47] : memref<1x512x2x2xf32>
                %49 = affine.load %42[] : memref<f32>
                %50 = cmpf "ogt", %49, %48 : f32
                %51 = select %50, %49, %48 : f32
                affine.store %51, %42[] : memref<f32>
              }
            }
            %45 = affine.load %42[] : memref<f32>
            affine.store %45, %3[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 512 {
        affine.for %arg3 = 0 to 1 {
          affine.for %arg4 = 0 to 1 {
            %42 = affine.load %3[%arg1, %arg2, %arg3, %arg4] : memref<1x512x1x1xf32>
            %43 = affine.apply #map14(%arg2, %arg3, %arg4)[%c512, %c1, %c1]
            affine.store %42, %2[%arg1, %43] : memref<1x512xf32>
          }
        }
      }
    }
    %40 = "krnl.global"() {name = "constant_16", offset = 36881920 : i64, shape = [10, 512]} : () -> memref<10x512xf32>
    %41 = "krnl.global"() {name = "constant_17", offset = 36902400 : i64, shape = [10], value = dense<[0.02706003, 0.00665123109, 0.00127255032, 0.0145233562, 0.028272111, 0.00267754705, 4.243600e-02, 0.013703784, 0.0207483657, -0.0375925265]> : tensor<10xf32>} : () -> memref<10xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 10 {
        %42 = memref.alloca() : memref<f32>
        affine.store %cst_1, %42[] : memref<f32>
        affine.for %arg3 = 0 to 512 {
          %48 = affine.load %2[%arg1, %arg3] : memref<1x512xf32>
          %49 = affine.load %40[%arg2, %arg3] : memref<10x512xf32>
          %50 = affine.load %42[] : memref<f32>
          %51 = mulf %48, %49 : f32
          %52 = addf %50, %51 : f32
          affine.store %52, %42[] : memref<f32>
        }
        %43 = affine.load %42[] : memref<f32>
        %44 = mulf %cst_0, %43 : f32
        %45 = affine.load %41[%arg2] : memref<10xf32>
        %46 = mulf %cst_0, %45 : f32
        %47 = addf %44, %46 : f32
        affine.store %47, %1[%arg1, %arg2] : memref<1x10xf32>
      }
    }
    memref.dealloc %23 : memref<1x64x32x32xf32>
    memref.dealloc %22 : memref<1x64x32x32xf32>
    memref.dealloc %21 : memref<1x64x16x16xf32>
    memref.dealloc %20 : memref<1x128x16x16xf32>
    memref.dealloc %19 : memref<1x128x16x16xf32>
    memref.dealloc %18 : memref<1x128x8x8xf32>
    memref.dealloc %17 : memref<1x256x8x8xf32>
    memref.dealloc %16 : memref<1x256x8x8xf32>
    memref.dealloc %15 : memref<1x256x8x8xf32>
    memref.dealloc %14 : memref<1x256x8x8xf32>
    memref.dealloc %13 : memref<1x256x4x4xf32>
    memref.dealloc %12 : memref<1x512x4x4xf32>
    memref.dealloc %11 : memref<1x512x4x4xf32>
    memref.dealloc %10 : memref<1x512x4x4xf32>
    memref.dealloc %9 : memref<1x512x4x4xf32>
    memref.dealloc %8 : memref<1x512x2x2xf32>
    memref.dealloc %7 : memref<1x512x2x2xf32>
    memref.dealloc %6 : memref<1x512x2x2xf32>
    memref.dealloc %5 : memref<1x512x2x2xf32>
    memref.dealloc %4 : memref<1x512x2x2xf32>
    memref.dealloc %3 : memref<1x512x1x1xf32>
    memref.dealloc %2 : memref<1x512xf32>
    return %1 : memref<1x10xf32>
  }
  "krnl.entry_point"() {func = @main_graph, numInputs = 1 : i32, numOutputs = 1 : i32} : () -> ()
}

