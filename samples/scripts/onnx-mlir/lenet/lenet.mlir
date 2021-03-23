#map0 = affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>
#map1 = affine_map<(d0, d1) -> (d0 * 2 + d1)>
#map2 = affine_map<() -> (0)>
#map3 = affine_map<() -> (5)>
#map4 = affine_map<() -> (3)>
#map5 = affine_map<(d0) -> (d0)>
#map6 = affine_map<() -> (14)>
#map7 = affine_map<() -> (6)>
#map8 = affine_map<() -> (1)>
#map9 = affine_map<() -> (16)>
#map10 = affine_map<(d0, d1, d2)[s0, s1, s2] -> (d2 + d1 * s2 + d0 * (s1 * s2))>
#map11 = affine_map<(d0, d1) -> (d0, d1)>
#map12 = affine_map<() -> (400)>
#map13 = affine_map<() -> (120)>
#map14 = affine_map<() -> (84)>
#map15 = affine_map<() -> (10)>
module {
  %0 = "krnl.packed_const"() {file_name = "/tmp/packed_const-b0eaf2.tmp", is_le = true, size_in_bytes = 247896 : i64} : () -> i64
  func @main_graph(%arg0: memref<1x3x32x32xf32>) -> memref<1x10xf32> attributes {input_names = ["input.1"], output_names = ["20"]} {
    %c16 = constant 16 : index
    %c5 = constant 5 : index
    %cst = constant 1.000000e+00 : f32
    %cst_0 = constant 0.000000e+00 : f32
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
    %11 = "krnl.global"() {name = "constant_0", offset = 0 : i64, shape = [6, 3, 5, 5]} : () -> memref<6x3x5x5xf32>
    %12 = "krnl.global"() {name = "constant_1", offset = 1800 : i64, shape = [6], value = dense<[0.0205305405, -0.0166301429, 0.0338148549, 0.0864747688, 0.0496686064, -0.095398277]> : tensor<6xf32>} : () -> memref<6xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 6 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            affine.store %cst_0, %10[%arg1, %arg2, %arg3, %arg4] : memref<1x6x14x14xf32>
            affine.for %arg5 = 0 to 3 {
              affine.for %arg6 = 0 to 5 {
                affine.for %arg7 = 0 to 5 {
                  %24 = affine.apply #map1(%arg3, %arg6)
                  %25 = affine.apply #map1(%arg4, %arg7)
                  %26 = affine.load %arg0[%arg1, %arg5, %24, %25] : memref<1x3x32x32xf32>
                  %27 = affine.load %11[%arg2, %arg5, %arg6, %arg7] : memref<6x3x5x5xf32>
                  %28 = affine.load %10[%arg1, %arg2, %arg3, %arg4] : memref<1x6x14x14xf32>
                  %29 = mulf %26, %27 : f32
                  %30 = addf %28, %29 : f32
                  affine.store %30, %10[%arg1, %arg2, %arg3, %arg4] : memref<1x6x14x14xf32>
                }
              }
            }
            %21 = affine.load %10[%arg1, %arg2, %arg3, %arg4] : memref<1x6x14x14xf32>
            %22 = affine.load %12[%arg2] : memref<6xf32>
            %23 = addf %21, %22 : f32
            affine.store %23, %10[%arg1, %arg2, %arg3, %arg4] : memref<1x6x14x14xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 6 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            %21 = affine.load %10[%arg1, %arg2, %arg3, %arg4] : memref<1x6x14x14xf32>
            %22 = cmpf "olt", %21, %cst_0 : f32
            %23 = select %22, %cst_0, %21 : f32
            affine.store %23, %9[%arg1, %arg2, %arg3, %arg4] : memref<1x6x14x14xf32>
          }
        }
      }
    }
    %13 = "krnl.global"() {name = "constant_2", offset = 1800 : i64, shape = [16, 6, 5, 5]} : () -> memref<16x6x5x5xf32>
    %14 = "krnl.global"() {name = "constant_3", offset = 11400 : i64, shape = [16], value = dense<[0.076599285, 0.0307336431, -0.0778933688, 0.0357786864, 6.434800e-02, -0.0309270639, -0.0753422827, 0.0586509854, 0.0103354184, -0.0330900103, 0.0345541462, 0.00906073302, -0.035865508, 0.0216197465, -0.0386768654, -0.0369877405]> : tensor<16xf32>} : () -> memref<16xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 16 {
        affine.for %arg3 = 0 to 5 {
          affine.for %arg4 = 0 to 5 {
            affine.store %cst_0, %8[%arg1, %arg2, %arg3, %arg4] : memref<1x16x5x5xf32>
            affine.for %arg5 = 0 to 6 {
              affine.for %arg6 = 0 to 5 {
                affine.for %arg7 = 0 to 5 {
                  %24 = affine.apply #map1(%arg3, %arg6)
                  %25 = affine.apply #map1(%arg4, %arg7)
                  %26 = affine.load %9[%arg1, %arg5, %24, %25] : memref<1x6x14x14xf32>
                  %27 = affine.load %13[%arg2, %arg5, %arg6, %arg7] : memref<16x6x5x5xf32>
                  %28 = affine.load %8[%arg1, %arg2, %arg3, %arg4] : memref<1x16x5x5xf32>
                  %29 = mulf %26, %27 : f32
                  %30 = addf %28, %29 : f32
                  affine.store %30, %8[%arg1, %arg2, %arg3, %arg4] : memref<1x16x5x5xf32>
                }
              }
            }
            %21 = affine.load %8[%arg1, %arg2, %arg3, %arg4] : memref<1x16x5x5xf32>
            %22 = affine.load %14[%arg2] : memref<16xf32>
            %23 = addf %21, %22 : f32
            affine.store %23, %8[%arg1, %arg2, %arg3, %arg4] : memref<1x16x5x5xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 16 {
        affine.for %arg3 = 0 to 5 {
          affine.for %arg4 = 0 to 5 {
            %21 = affine.load %8[%arg1, %arg2, %arg3, %arg4] : memref<1x16x5x5xf32>
            %22 = cmpf "olt", %21, %cst_0 : f32
            %23 = select %22, %cst_0, %21 : f32
            affine.store %23, %7[%arg1, %arg2, %arg3, %arg4] : memref<1x16x5x5xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 16 {
        affine.for %arg3 = 0 to 5 {
          affine.for %arg4 = 0 to 5 {
            %21 = affine.load %7[%arg1, %arg2, %arg3, %arg4] : memref<1x16x5x5xf32>
            %22 = affine.apply #map10(%arg2, %arg3, %arg4)[%c16, %c5, %c5]
            affine.store %21, %6[%arg1, %22] : memref<1x400xf32>
          }
        }
      }
    }
    %15 = "krnl.global"() {name = "constant_4", offset = 11400 : i64, shape = [120, 400]} : () -> memref<120x400xf32>
    %16 = "krnl.global"() {name = "constant_5", offset = 203400 : i64, shape = [120]} : () -> memref<120xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 120 {
        affine.store %cst_0, %5[%arg1, %arg2] : memref<1x120xf32>
        affine.for %arg3 = 0 to 400 {
          %26 = affine.load %6[%arg1, %arg3] : memref<1x400xf32>
          %27 = affine.load %15[%arg2, %arg3] : memref<120x400xf32>
          %28 = affine.load %5[%arg1, %arg2] : memref<1x120xf32>
          %29 = mulf %26, %27 : f32
          %30 = addf %28, %29 : f32
          affine.store %30, %5[%arg1, %arg2] : memref<1x120xf32>
        }
        %21 = affine.load %5[%arg1, %arg2] : memref<1x120xf32>
        %22 = mulf %cst, %21 : f32
        %23 = affine.load %16[%arg2] : memref<120xf32>
        %24 = mulf %cst, %23 : f32
        %25 = addf %22, %24 : f32
        affine.store %25, %5[%arg1, %arg2] : memref<1x120xf32>
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 120 {
        %21 = affine.load %5[%arg1, %arg2] : memref<1x120xf32>
        %22 = cmpf "olt", %21, %cst_0 : f32
        %23 = select %22, %cst_0, %21 : f32
        affine.store %23, %4[%arg1, %arg2] : memref<1x120xf32>
      }
    }
    %17 = "krnl.global"() {name = "constant_6", offset = 203880 : i64, shape = [84, 120]} : () -> memref<84x120xf32>
    %18 = "krnl.global"() {name = "constant_7", offset = 244200 : i64, shape = [84]} : () -> memref<84xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 84 {
        affine.store %cst_0, %3[%arg1, %arg2] : memref<1x84xf32>
        affine.for %arg3 = 0 to 120 {
          %26 = affine.load %4[%arg1, %arg3] : memref<1x120xf32>
          %27 = affine.load %17[%arg2, %arg3] : memref<84x120xf32>
          %28 = affine.load %3[%arg1, %arg2] : memref<1x84xf32>
          %29 = mulf %26, %27 : f32
          %30 = addf %28, %29 : f32
          affine.store %30, %3[%arg1, %arg2] : memref<1x84xf32>
        }
        %21 = affine.load %3[%arg1, %arg2] : memref<1x84xf32>
        %22 = mulf %cst, %21 : f32
        %23 = affine.load %18[%arg2] : memref<84xf32>
        %24 = mulf %cst, %23 : f32
        %25 = addf %22, %24 : f32
        affine.store %25, %3[%arg1, %arg2] : memref<1x84xf32>
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 84 {
        %21 = affine.load %3[%arg1, %arg2] : memref<1x84xf32>
        %22 = cmpf "olt", %21, %cst_0 : f32
        %23 = select %22, %cst_0, %21 : f32
        affine.store %23, %2[%arg1, %arg2] : memref<1x84xf32>
      }
    }
    %19 = "krnl.global"() {name = "constant_8", offset = 244536 : i64, shape = [10, 84]} : () -> memref<10x84xf32>
    %20 = "krnl.global"() {name = "constant_9", offset = 247896 : i64, shape = [10], value = dense<[-0.0215814672, -0.0353261717, -0.1030894, -0.0490794294, -0.00723514939, 0.0333266333, 0.0195306465, 0.106940947, -0.0151493587, 0.0317494832]> : tensor<10xf32>} : () -> memref<10xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 10 {
        affine.store %cst_0, %1[%arg1, %arg2] : memref<1x10xf32>
        affine.for %arg3 = 0 to 84 {
          %26 = affine.load %2[%arg1, %arg3] : memref<1x84xf32>
          %27 = affine.load %19[%arg2, %arg3] : memref<10x84xf32>
          %28 = affine.load %1[%arg1, %arg2] : memref<1x10xf32>
          %29 = mulf %26, %27 : f32
          %30 = addf %28, %29 : f32
          affine.store %30, %1[%arg1, %arg2] : memref<1x10xf32>
        }
        %21 = affine.load %1[%arg1, %arg2] : memref<1x10xf32>
        %22 = mulf %cst, %21 : f32
        %23 = affine.load %20[%arg2] : memref<10xf32>
        %24 = mulf %cst, %23 : f32
        %25 = addf %22, %24 : f32
        affine.store %25, %1[%arg1, %arg2] : memref<1x10xf32>
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
