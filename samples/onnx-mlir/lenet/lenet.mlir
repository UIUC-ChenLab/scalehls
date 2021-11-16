#map0 = affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>
#map1 = affine_map<(d0, d1) -> (d0 * 2 + d1)>
#map2 = affine_map<() -> (0)>
#map3 = affine_map<() -> (5)>
#map4 = affine_map<() -> (3)>
#map5 = affine_map<() -> (14)>
#map6 = affine_map<() -> (6)>
#map7 = affine_map<() -> (1)>
#map8 = affine_map<() -> (16)>
#map9 = affine_map<(d0, d1, d2)[s0, s1, s2] -> (d2 + d1 * s2 + d0 * (s1 * s2))>
#map10 = affine_map<(d0, d1) -> (d0, d1)>
#map11 = affine_map<() -> (400)>
#map12 = affine_map<(d0) -> (d0)>
#map13 = affine_map<() -> (120)>
#map14 = affine_map<() -> (84)>
#map15 = affine_map<() -> (10)>
module {
  %0 = "krnl.packed_const"() {file_name = "/tmp/packed_const-b6b002.tmp", is_le = true, size_in_bytes = 247896 : i64} : () -> i64
  func @main_graph(%arg0: memref<1x3x32x32xf32>) -> memref<1x10xf32> attributes {input_names = ["input.1"], output_names = ["18"]} {
    %c16 = arith.constant 16 : index
    %c5 = arith.constant 5 : index
    %cst = arith.constant 1.000000e+00 : f32
    %cst_0 = arith.constant 0.000000e+00 : f32
    %1 = memref.alloc() : memref<1x10xf32>
    %2 = memref.alloc() : memref<1x84xf32>
    %3 = memref.alloc() : memref<1x84xf32>
    %4 = memref.alloc() : memref<1x120xf32>
    %5 = memref.alloc() : memref<1x120xf32>
    %6 = memref.alloc() : memref<1x400xf32>
    %7 = memref.alloc() : memref<1x16x5x5xf32>
    %8 = memref.alloc() : memref<1x16x5x5xf32>
    %9 = memref.alloc() : memref<1x6x14x14xf32>
    %10 = memref.alloc() : memref<1x6x14x14xf32>
    %11 = "krnl.global"() {name = "arith.constant_0", offset = 0 : i64, shape = [6, 3, 5, 5]} : () -> memref<6x3x5x5xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 6 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            affine.store %cst_0, %10[%arg1, %arg2, %arg3, %arg4] : memref<1x6x14x14xf32>
            affine.for %arg5 = 0 to 3 {
              affine.for %arg6 = 0 to 5 {
                affine.for %arg7 = 0 to 5 {
                  %19 = affine.apply #map1(%arg3, %arg6)
                  %20 = affine.apply #map1(%arg4, %arg7)
                  %21 = affine.load %arg0[%arg1, %arg5, %19, %20] : memref<1x3x32x32xf32>
                  %22 = affine.load %11[%arg2, %arg5, %arg6, %arg7] : memref<6x3x5x5xf32>
                  %23 = affine.load %10[%arg1, %arg2, %arg3, %arg4] : memref<1x6x14x14xf32>
                  %24 = arith.mulf %21, %22 : f32
                  %25 = arith.addf %23, %24 : f32
                  affine.store %25, %10[%arg1, %arg2, %arg3, %arg4] : memref<1x6x14x14xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 6 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            %19 = affine.load %10[%arg1, %arg2, %arg3, %arg4] : memref<1x6x14x14xf32>
            %20 = arith.cmpf "olt", %19, %cst_0 : f32
            %21 = select %20, %cst_0, %19 : f32
            affine.store %21, %9[%arg1, %arg2, %arg3, %arg4] : memref<1x6x14x14xf32>
          }
        }
      }
    }
    %12 = "krnl.global"() {name = "arith.constant_1", offset = 1800 : i64, shape = [16, 6, 5, 5]} : () -> memref<16x6x5x5xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 16 {
        affine.for %arg3 = 0 to 5 {
          affine.for %arg4 = 0 to 5 {
            affine.store %cst_0, %8[%arg1, %arg2, %arg3, %arg4] : memref<1x16x5x5xf32>
            affine.for %arg5 = 0 to 6 {
              affine.for %arg6 = 0 to 5 {
                affine.for %arg7 = 0 to 5 {
                  %19 = affine.apply #map1(%arg3, %arg6)
                  %20 = affine.apply #map1(%arg4, %arg7)
                  %21 = affine.load %9[%arg1, %arg5, %19, %20] : memref<1x6x14x14xf32>
                  %22 = affine.load %12[%arg2, %arg5, %arg6, %arg7] : memref<16x6x5x5xf32>
                  %23 = affine.load %8[%arg1, %arg2, %arg3, %arg4] : memref<1x16x5x5xf32>
                  %24 = arith.mulf %21, %22 : f32
                  %25 = arith.addf %23, %24 : f32
                  affine.store %25, %8[%arg1, %arg2, %arg3, %arg4] : memref<1x16x5x5xf32>
                }
              }
            }
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 16 {
        affine.for %arg3 = 0 to 5 {
          affine.for %arg4 = 0 to 5 {
            %19 = affine.load %8[%arg1, %arg2, %arg3, %arg4] : memref<1x16x5x5xf32>
            %20 = arith.cmpf "olt", %19, %cst_0 : f32
            %21 = select %20, %cst_0, %19 : f32
            affine.store %21, %7[%arg1, %arg2, %arg3, %arg4] : memref<1x16x5x5xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 16 {
        affine.for %arg3 = 0 to 5 {
          affine.for %arg4 = 0 to 5 {
            %19 = affine.load %7[%arg1, %arg2, %arg3, %arg4] : memref<1x16x5x5xf32>
            %20 = affine.apply #map9(%arg2, %arg3, %arg4)[%c16, %c5, %c5]
            affine.store %19, %6[%arg1, %20] : memref<1x400xf32>
          }
        }
      }
    }
    %13 = "krnl.global"() {name = "arith.constant_2", offset = 11400 : i64, shape = [120, 400]} : () -> memref<120x400xf32>
    %14 = "krnl.global"() {name = "arith.constant_3", offset = 203400 : i64, shape = [120]} : () -> memref<120xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 120 {
        affine.store %cst_0, %5[%arg1, %arg2] : memref<1x120xf32>
        affine.for %arg3 = 0 to 400 {
          %24 = affine.load %6[%arg1, %arg3] : memref<1x400xf32>
          %25 = affine.load %13[%arg2, %arg3] : memref<120x400xf32>
          %26 = affine.load %5[%arg1, %arg2] : memref<1x120xf32>
          %27 = arith.mulf %24, %25 : f32
          %28 = arith.addf %26, %27 : f32
          affine.store %28, %5[%arg1, %arg2] : memref<1x120xf32>
        }
        %19 = affine.load %5[%arg1, %arg2] : memref<1x120xf32>
        %20 = arith.mulf %cst, %19 : f32
        %21 = affine.load %14[%arg2] : memref<120xf32>
        %22 = arith.mulf %cst, %21 : f32
        %23 = arith.addf %20, %22 : f32
        affine.store %23, %5[%arg1, %arg2] : memref<1x120xf32>
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 120 {
        %19 = affine.load %5[%arg1, %arg2] : memref<1x120xf32>
        %20 = arith.cmpf "olt", %19, %cst_0 : f32
        %21 = select %20, %cst_0, %19 : f32
        affine.store %21, %4[%arg1, %arg2] : memref<1x120xf32>
      }
    }
    %15 = "krnl.global"() {name = "arith.constant_4", offset = 203880 : i64, shape = [84, 120]} : () -> memref<84x120xf32>
    %16 = "krnl.global"() {name = "arith.constant_5", offset = 244200 : i64, shape = [84]} : () -> memref<84xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 84 {
        affine.store %cst_0, %3[%arg1, %arg2] : memref<1x84xf32>
        affine.for %arg3 = 0 to 120 {
          %24 = affine.load %4[%arg1, %arg3] : memref<1x120xf32>
          %25 = affine.load %15[%arg2, %arg3] : memref<84x120xf32>
          %26 = affine.load %3[%arg1, %arg2] : memref<1x84xf32>
          %27 = arith.mulf %24, %25 : f32
          %28 = arith.addf %26, %27 : f32
          affine.store %28, %3[%arg1, %arg2] : memref<1x84xf32>
        }
        %19 = affine.load %3[%arg1, %arg2] : memref<1x84xf32>
        %20 = arith.mulf %cst, %19 : f32
        %21 = affine.load %16[%arg2] : memref<84xf32>
        %22 = arith.mulf %cst, %21 : f32
        %23 = arith.addf %20, %22 : f32
        affine.store %23, %3[%arg1, %arg2] : memref<1x84xf32>
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 84 {
        %19 = affine.load %3[%arg1, %arg2] : memref<1x84xf32>
        %20 = arith.cmpf "olt", %19, %cst_0 : f32
        %21 = select %20, %cst_0, %19 : f32
        affine.store %21, %2[%arg1, %arg2] : memref<1x84xf32>
      }
    }
    %17 = "krnl.global"() {name = "arith.constant_6", offset = 244536 : i64, shape = [10, 84]} : () -> memref<10x84xf32>
    %18 = "krnl.global"() {name = "arith.constant_7", offset = 247896 : i64, shape = [10], value = dense<[0.0802067816, 0.0380531251, -0.0453170575, 0.0238099229, -0.0322267264, 0.0956416651, -0.0513828322, -0.00329447933, 0.0870032906, -0.100006074]> : tensor<10xf32>} : () -> memref<10xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 10 {
        affine.store %cst_0, %1[%arg1, %arg2] : memref<1x10xf32>
        affine.for %arg3 = 0 to 84 {
          %24 = affine.load %2[%arg1, %arg3] : memref<1x84xf32>
          %25 = affine.load %17[%arg2, %arg3] : memref<10x84xf32>
          %26 = affine.load %1[%arg1, %arg2] : memref<1x10xf32>
          %27 = arith.mulf %24, %25 : f32
          %28 = arith.addf %26, %27 : f32
          affine.store %28, %1[%arg1, %arg2] : memref<1x10xf32>
        }
        %19 = affine.load %1[%arg1, %arg2] : memref<1x10xf32>
        %20 = arith.mulf %cst, %19 : f32
        %21 = affine.load %18[%arg2] : memref<10xf32>
        %22 = arith.mulf %cst, %21 : f32
        %23 = arith.addf %20, %22 : f32
        affine.store %23, %1[%arg1, %arg2] : memref<1x10xf32>
      }
    }
    memref.dealloc %10 : memref<1x6x14x14xf32>
    memref.dealloc %9 : memref<1x6x14x14xf32>
    memref.dealloc %8 : memref<1x16x5x5xf32>
    memref.dealloc %7 : memref<1x16x5x5xf32>
    memref.dealloc %6 : memref<1x400xf32>
    memref.dealloc %5 : memref<1x120xf32>
    memref.dealloc %4 : memref<1x120xf32>
    memref.dealloc %3 : memref<1x84xf32>
    memref.dealloc %2 : memref<1x84xf32>
    return %1 : memref<1x10xf32>
  }
  "krnl.entry_point"() {func = @main_graph, numInputs = 1 : i32, numOutputs = 1 : i32} : () -> ()
}
