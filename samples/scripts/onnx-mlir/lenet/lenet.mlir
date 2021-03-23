#map0 = affine_map<(d0, d1, d2, d3) -> (d0, d1, d2, d3)>
#map1 = affine_map<(d0, d1) -> (d0 + d1)>
#map2 = affine_map<() -> (0)>
#map3 = affine_map<() -> (5)>
#map4 = affine_map<() -> (3)>
#map5 = affine_map<(d0) -> (d0)>
#map6 = affine_map<() -> (28)>
#map7 = affine_map<() -> (6)>
#map8 = affine_map<() -> (1)>
#map9 = affine_map<(d0)[s0, s1, s2, s3, s4] -> (0, d0 * s3 - s2)>
#map10 = affine_map<(d0) -> (28, d0 * -2 + 28, d0 * 2 + 2, 2)>
#map11 = affine_map<() -> (14)>
#map12 = affine_map<() -> (10)>
#map13 = affine_map<() -> (16)>
#map14 = affine_map<(d0) -> (10, d0 * -2 + 10, d0 * 2 + 2, 2)>
#map15 = affine_map<(d0, d1, d2)[s0, s1, s2] -> (d2 + d1 * s2 + d0 * (s1 * s2))>
#map16 = affine_map<(d0, d1) -> (d0, d1)>
#map17 = affine_map<() -> (400)>
#map18 = affine_map<() -> (120)>
#map19 = affine_map<() -> (84)>
module {
  %0 = "krnl.packed_const"() {file_name = "/tmp/packed_const-914984.tmp", is_le = true, size_in_bytes = 247896 : i64} : () -> i64
  func @main_graph(%arg0: memref<1x3x32x32xf32>) -> memref<1x10xf32> attributes {input_names = ["input.1"], output_names = ["22"]} {
    %c28 = constant 28 : index
    %cst = constant 0xFF800000 : f32
    %c10 = constant 10 : index
    %c0 = constant 0 : index
    %c2 = constant 2 : index
    %c1 = constant 1 : index
    %c16 = constant 16 : index
    %c5 = constant 5 : index
    %cst_0 = constant 1.000000e+00 : f32
    %cst_1 = constant 0.000000e+00 : f32
    %1 = memref.alloc() : memref<1x10xf32>
    %2 = memref.alloc() : memref<1x84xf32>
    %3 = memref.alloc() : memref<1x84xf32>
    %4 = memref.alloc() : memref<1x120xf32>
    %5 = memref.alloc() : memref<1x120xf32>
    %6 = memref.alloc() : memref<1x400xf32>
    %7 = memref.alloc() : memref<1x16x5x5xf32>
    %8 = memref.alloc() : memref<1x16x10x10xf32>
    %9 = memref.alloc() : memref<1x16x10x10xf32>
    %10 = memref.alloc() : memref<1x6x14x14xf32>
    %11 = memref.alloc() : memref<1x6x28x28xf32>
    %12 = memref.alloc() : memref<1x6x28x28xf32>
    %13 = "krnl.global"() {name = "constant_0", offset = 0 : i64, shape = [6, 3, 5, 5]} : () -> memref<6x3x5x5xf32>
    %14 = "krnl.global"() {name = "constant_1", offset = 1800 : i64, shape = [6], value = dense<[0.0960158855, -0.0978673473, 0.021009896, 0.0668891519, -0.101221204, -0.00156840961]> : tensor<6xf32>} : () -> memref<6xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 6 {
        affine.for %arg3 = 0 to 28 {
          affine.for %arg4 = 0 to 28 {
            affine.store %cst_1, %12[%arg1, %arg2, %arg3, %arg4] : memref<1x6x28x28xf32>
            affine.for %arg5 = 0 to 3 {
              affine.for %arg6 = 0 to 5 {
                affine.for %arg7 = 0 to 5 {
                  %26 = affine.apply #map1(%arg3, %arg6)
                  %27 = affine.apply #map1(%arg4, %arg7)
                  %28 = affine.load %arg0[%arg1, %arg5, %26, %27] : memref<1x3x32x32xf32>
                  %29 = affine.load %13[%arg2, %arg5, %arg6, %arg7] : memref<6x3x5x5xf32>
                  %30 = affine.load %12[%arg1, %arg2, %arg3, %arg4] : memref<1x6x28x28xf32>
                  %31 = mulf %28, %29 : f32
                  %32 = addf %30, %31 : f32
                  affine.store %32, %12[%arg1, %arg2, %arg3, %arg4] : memref<1x6x28x28xf32>
                }
              }
            }
            %23 = affine.load %12[%arg1, %arg2, %arg3, %arg4] : memref<1x6x28x28xf32>
            %24 = affine.load %14[%arg2] : memref<6xf32>
            %25 = addf %23, %24 : f32
            affine.store %25, %12[%arg1, %arg2, %arg3, %arg4] : memref<1x6x28x28xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 6 {
        affine.for %arg3 = 0 to 28 {
          affine.for %arg4 = 0 to 28 {
            %23 = affine.load %12[%arg1, %arg2, %arg3, %arg4] : memref<1x6x28x28xf32>
            %24 = cmpf "olt", %23, %cst_1 : f32
            %25 = select %24, %cst_1, %23 : f32
            affine.store %25, %11[%arg1, %arg2, %arg3, %arg4] : memref<1x6x28x28xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 6 {
        affine.for %arg3 = 0 to 14 {
          affine.for %arg4 = 0 to 14 {
            affine.store %cst, %10[%arg1, %arg2, %arg3, %arg4] : memref<1x6x14x14xf32>
            %23 = affine.max #map9(%arg3)[%c28, %c2, %c0, %c2, %c1]
            %24 = affine.max #map9(%arg4)[%c28, %c2, %c0, %c2, %c1]
            affine.for %arg5 = 0 to min #map10(%arg3) {
              affine.for %arg6 = 0 to min #map10(%arg4) {
                %25 = addi %arg5, %23 : index
                %26 = addi %arg6, %24 : index
                %27 = memref.load %11[%arg1, %arg2, %25, %26] : memref<1x6x28x28xf32>
                %28 = affine.load %10[%arg1, %arg2, %arg3, %arg4] : memref<1x6x14x14xf32>
                %29 = cmpf "ogt", %28, %27 : f32
                %30 = select %29, %28, %27 : f32
                affine.store %30, %10[%arg1, %arg2, %arg3, %arg4] : memref<1x6x14x14xf32>
              }
            }
          }
        }
      }
    }
    %15 = "krnl.global"() {name = "constant_2", offset = 1800 : i64, shape = [16, 6, 5, 5]} : () -> memref<16x6x5x5xf32>
    %16 = "krnl.global"() {name = "constant_3", offset = 11400 : i64, shape = [16], value = dense<[-0.0425458886, -1.0622057E-4, 0.0557706282, 0.00405254913, -0.0675742328, 0.0557717085, 7.307590e-02, 0.00432055816, 0.0693110898, -0.0665955693, 0.0204374585, -0.026400255, -0.0262101237, -0.0462883636, -0.038955085, 0.0659427494]> : tensor<16xf32>} : () -> memref<16xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 16 {
        affine.for %arg3 = 0 to 10 {
          affine.for %arg4 = 0 to 10 {
            affine.store %cst_1, %9[%arg1, %arg2, %arg3, %arg4] : memref<1x16x10x10xf32>
            affine.for %arg5 = 0 to 6 {
              affine.for %arg6 = 0 to 5 {
                affine.for %arg7 = 0 to 5 {
                  %26 = affine.apply #map1(%arg3, %arg6)
                  %27 = affine.apply #map1(%arg4, %arg7)
                  %28 = affine.load %10[%arg1, %arg5, %26, %27] : memref<1x6x14x14xf32>
                  %29 = affine.load %15[%arg2, %arg5, %arg6, %arg7] : memref<16x6x5x5xf32>
                  %30 = affine.load %9[%arg1, %arg2, %arg3, %arg4] : memref<1x16x10x10xf32>
                  %31 = mulf %28, %29 : f32
                  %32 = addf %30, %31 : f32
                  affine.store %32, %9[%arg1, %arg2, %arg3, %arg4] : memref<1x16x10x10xf32>
                }
              }
            }
            %23 = affine.load %9[%arg1, %arg2, %arg3, %arg4] : memref<1x16x10x10xf32>
            %24 = affine.load %16[%arg2] : memref<16xf32>
            %25 = addf %23, %24 : f32
            affine.store %25, %9[%arg1, %arg2, %arg3, %arg4] : memref<1x16x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 16 {
        affine.for %arg3 = 0 to 10 {
          affine.for %arg4 = 0 to 10 {
            %23 = affine.load %9[%arg1, %arg2, %arg3, %arg4] : memref<1x16x10x10xf32>
            %24 = cmpf "olt", %23, %cst_1 : f32
            %25 = select %24, %cst_1, %23 : f32
            affine.store %25, %8[%arg1, %arg2, %arg3, %arg4] : memref<1x16x10x10xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 16 {
        affine.for %arg3 = 0 to 5 {
          affine.for %arg4 = 0 to 5 {
            affine.store %cst, %7[%arg1, %arg2, %arg3, %arg4] : memref<1x16x5x5xf32>
            %23 = affine.max #map9(%arg3)[%c10, %c2, %c0, %c2, %c1]
            %24 = affine.max #map9(%arg4)[%c10, %c2, %c0, %c2, %c1]
            affine.for %arg5 = 0 to min #map14(%arg3) {
              affine.for %arg6 = 0 to min #map14(%arg4) {
                %25 = addi %arg5, %23 : index
                %26 = addi %arg6, %24 : index
                %27 = memref.load %8[%arg1, %arg2, %25, %26] : memref<1x16x10x10xf32>
                %28 = affine.load %7[%arg1, %arg2, %arg3, %arg4] : memref<1x16x5x5xf32>
                %29 = cmpf "ogt", %28, %27 : f32
                %30 = select %29, %28, %27 : f32
                affine.store %30, %7[%arg1, %arg2, %arg3, %arg4] : memref<1x16x5x5xf32>
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
            %23 = affine.load %7[%arg1, %arg2, %arg3, %arg4] : memref<1x16x5x5xf32>
            %24 = affine.apply #map15(%arg2, %arg3, %arg4)[%c16, %c5, %c5]
            affine.store %23, %6[%arg1, %24] : memref<1x400xf32>
          }
        }
      }
    }
    %17 = "krnl.global"() {name = "constant_4", offset = 11400 : i64, shape = [120, 400]} : () -> memref<120x400xf32>
    %18 = "krnl.global"() {name = "constant_5", offset = 203400 : i64, shape = [120]} : () -> memref<120xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 120 {
        affine.store %cst_1, %5[%arg1, %arg2] : memref<1x120xf32>
        affine.for %arg3 = 0 to 400 {
          %28 = affine.load %6[%arg1, %arg3] : memref<1x400xf32>
          %29 = affine.load %17[%arg2, %arg3] : memref<120x400xf32>
          %30 = affine.load %5[%arg1, %arg2] : memref<1x120xf32>
          %31 = mulf %28, %29 : f32
          %32 = addf %30, %31 : f32
          affine.store %32, %5[%arg1, %arg2] : memref<1x120xf32>
        }
        %23 = affine.load %5[%arg1, %arg2] : memref<1x120xf32>
        %24 = mulf %cst_0, %23 : f32
        %25 = affine.load %18[%arg2] : memref<120xf32>
        %26 = mulf %cst_0, %25 : f32
        %27 = addf %24, %26 : f32
        affine.store %27, %5[%arg1, %arg2] : memref<1x120xf32>
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 120 {
        %23 = affine.load %5[%arg1, %arg2] : memref<1x120xf32>
        %24 = cmpf "olt", %23, %cst_1 : f32
        %25 = select %24, %cst_1, %23 : f32
        affine.store %25, %4[%arg1, %arg2] : memref<1x120xf32>
      }
    }
    %19 = "krnl.global"() {name = "constant_6", offset = 203880 : i64, shape = [84, 120]} : () -> memref<84x120xf32>
    %20 = "krnl.global"() {name = "constant_7", offset = 244200 : i64, shape = [84]} : () -> memref<84xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 84 {
        affine.store %cst_1, %3[%arg1, %arg2] : memref<1x84xf32>
        affine.for %arg3 = 0 to 120 {
          %28 = affine.load %4[%arg1, %arg3] : memref<1x120xf32>
          %29 = affine.load %19[%arg2, %arg3] : memref<84x120xf32>
          %30 = affine.load %3[%arg1, %arg2] : memref<1x84xf32>
          %31 = mulf %28, %29 : f32
          %32 = addf %30, %31 : f32
          affine.store %32, %3[%arg1, %arg2] : memref<1x84xf32>
        }
        %23 = affine.load %3[%arg1, %arg2] : memref<1x84xf32>
        %24 = mulf %cst_0, %23 : f32
        %25 = affine.load %20[%arg2] : memref<84xf32>
        %26 = mulf %cst_0, %25 : f32
        %27 = addf %24, %26 : f32
        affine.store %27, %3[%arg1, %arg2] : memref<1x84xf32>
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 84 {
        %23 = affine.load %3[%arg1, %arg2] : memref<1x84xf32>
        %24 = cmpf "olt", %23, %cst_1 : f32
        %25 = select %24, %cst_1, %23 : f32
        affine.store %25, %2[%arg1, %arg2] : memref<1x84xf32>
      }
    }
    %21 = "krnl.global"() {name = "constant_8", offset = 244536 : i64, shape = [10, 84]} : () -> memref<10x84xf32>
    %22 = "krnl.global"() {name = "constant_9", offset = 247896 : i64, shape = [10], value = dense<[0.00266060606, 0.0776943415, -0.00205811812, 0.0829209163, -0.0209625009, 0.0374473445, 0.104985334, 4.755800e-02, 6.968890e-02, 0.0946019441]> : tensor<10xf32>} : () -> memref<10xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 10 {
        affine.store %cst_1, %1[%arg1, %arg2] : memref<1x10xf32>
        affine.for %arg3 = 0 to 84 {
          %28 = affine.load %2[%arg1, %arg3] : memref<1x84xf32>
          %29 = affine.load %21[%arg2, %arg3] : memref<10x84xf32>
          %30 = affine.load %1[%arg1, %arg2] : memref<1x10xf32>
          %31 = mulf %28, %29 : f32
          %32 = addf %30, %31 : f32
          affine.store %32, %1[%arg1, %arg2] : memref<1x10xf32>
        }
        %23 = affine.load %1[%arg1, %arg2] : memref<1x10xf32>
        %24 = mulf %cst_0, %23 : f32
        %25 = affine.load %22[%arg2] : memref<10xf32>
        %26 = mulf %cst_0, %25 : f32
        %27 = addf %24, %26 : f32
        affine.store %27, %1[%arg1, %arg2] : memref<1x10xf32>
      }
    }
    memref.dealloc %12 : memref<1x6x28x28xf32>
    memref.dealloc %11 : memref<1x6x28x28xf32>
    memref.dealloc %10 : memref<1x6x14x14xf32>
    memref.dealloc %9 : memref<1x16x10x10xf32>
    memref.dealloc %8 : memref<1x16x10x10xf32>
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
