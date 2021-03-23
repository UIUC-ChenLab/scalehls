#map0 = affine_map<(d0, d1) -> (0, d0)>
#map1 = affine_map<(d0, d1, d2, d3) -> (0, d2)>
#map2 = affine_map<(d0) -> (32, -d0 + 32, d0 + 5, 5)>
#map3 = affine_map<(d0, d1) -> (0, d0 * 2)>
#map4 = affine_map<(d0, d1, d2, d3) -> (0, d2 * 2)>
#map5 = affine_map<(d0) -> (28, d0 * -2 + 28, d0 * 2 + 2, 2)>
#map6 = affine_map<(d0) -> (14, -d0 + 14, d0 + 5, 5)>
#map7 = affine_map<(d0) -> (10, d0 * -2 + 10, d0 * 2 + 2, 2)>
#map8 = affine_map<(d0, d1, d2)[s0, s1, s2] -> (d2 + d1 * s2 + d0 * (s1 * s2))>
module  {
  %0 = "krnl.packed_const"() {file_name = "/tmp/packed_const-ae91f7.tmp", is_le = true, size_in_bytes = 247896 : i64} : () -> i64
  func @main_graph(%arg0: memref<1x3x32x32xf32>) -> memref<1x10xf32> attributes {input_names = ["input.1"], output_names = ["22"]} {
    %c32 = constant 32 : index
    %c28 = constant 28 : index
    %c14 = constant 14 : index
    %cst = constant 0xFF800000 : f32
    %c0 = constant 0 : index
    %c1 = constant 1 : index
    %c10 = constant 10 : index
    %c2 = constant 2 : index
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
    %14 = "krnl.global"() {name = "constant_1", offset = 1800 : i64, shape = [6], value = dense<[0.00242457143, -0.0667892396, -0.058878962, -0.00520410342, 0.0933633521, 9.559220e-02]> : tensor<6xf32>} : () -> memref<6xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 6 {
        affine.for %arg3 = 0 to 28 {
          affine.for %arg4 = 0 to 28 {
            affine.store %cst_1, %12[%arg1, %arg2, %arg3, %arg4] : memref<1x6x28x28xf32>
            %23 = memref.alloca() : memref<f32>
            affine.store %cst_1, %23[] : memref<f32>
            %24 = affine.max #map0(%arg3, %arg3)
            %25 = affine.min #map0(%arg3, %arg3)
            %26 = affine.max #map1(%arg3, %arg3, %arg4, %arg4)
            %27 = affine.min #map1(%arg3, %arg3, %arg4, %arg4)
            affine.for %arg5 = 0 to 3 {
              affine.for %arg6 = 0 to min #map2(%arg3) {
                affine.for %arg7 = 0 to min #map2(%arg4) {
                  %31 = addi %arg6, %24 : index
                  %32 = addi %arg7, %26 : index
                  %33 = subi %arg6, %25 : index
                  %34 = subi %arg7, %27 : index
                  %35 = memref.load %arg0[%arg1, %arg5, %31, %32] : memref<1x3x32x32xf32>
                  %36 = memref.load %13[%arg2, %arg5, %33, %34] : memref<6x3x5x5xf32>
                  %37 = affine.load %23[] : memref<f32>
                  %38 = mulf %35, %36 : f32
                  %39 = addf %37, %38 : f32
                  affine.store %39, %23[] : memref<f32>
                }
              }
            }
            %28 = affine.load %23[] : memref<f32>
            %29 = affine.load %14[%arg2] : memref<6xf32>
            %30 = addf %28, %29 : f32
            affine.store %30, %12[%arg1, %arg2, %arg3, %arg4] : memref<1x6x28x28xf32>
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
            %23 = memref.alloca() : memref<f32>
            affine.store %cst, %23[] : memref<f32>
            %24 = affine.max #map3(%arg3, %arg3)
            %25 = affine.max #map4(%arg3, %arg3, %arg4, %arg4)
            affine.for %arg5 = 0 to min #map5(%arg3) {
              affine.for %arg6 = 0 to min #map5(%arg4) {
                %27 = addi %arg5, %24 : index
                %28 = addi %arg6, %25 : index
                %29 = memref.load %11[%arg1, %arg2, %27, %28] : memref<1x6x28x28xf32>
                %30 = affine.load %23[] : memref<f32>
                %31 = cmpf "ogt", %30, %29 : f32
                %32 = select %31, %30, %29 : f32
                affine.store %32, %23[] : memref<f32>
              }
            }
            %26 = affine.load %23[] : memref<f32>
            affine.store %26, %10[%arg1, %arg2, %arg3, %arg4] : memref<1x6x14x14xf32>
          }
        }
      }
    }
    %15 = "krnl.global"() {name = "constant_2", offset = 1800 : i64, shape = [16, 6, 5, 5]} : () -> memref<16x6x5x5xf32>
    %16 = "krnl.global"() {name = "constant_3", offset = 11400 : i64, shape = [16], value = dense<[-0.0173466876, -0.0514908247, -0.0480147079, 0.0157364123, 0.0125454543, -0.0163226556, 0.0561440513, 0.0612348132, 0.00686503387, -0.0240725912, -0.0257562157, -0.0352682397, 0.0650300085, -0.0479633324, 0.0746948868, 0.0240472369]> : tensor<16xf32>} : () -> memref<16xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 16 {
        affine.for %arg3 = 0 to 10 {
          affine.for %arg4 = 0 to 10 {
            affine.store %cst_1, %9[%arg1, %arg2, %arg3, %arg4] : memref<1x16x10x10xf32>
            %23 = memref.alloca() : memref<f32>
            affine.store %cst_1, %23[] : memref<f32>
            %24 = affine.max #map0(%arg3, %arg3)
            %25 = affine.min #map0(%arg3, %arg3)
            %26 = affine.max #map1(%arg3, %arg3, %arg4, %arg4)
            %27 = affine.min #map1(%arg3, %arg3, %arg4, %arg4)
            affine.for %arg5 = 0 to 6 {
              affine.for %arg6 = 0 to min #map6(%arg3) {
                affine.for %arg7 = 0 to min #map6(%arg4) {
                  %31 = addi %arg6, %24 : index
                  %32 = addi %arg7, %26 : index
                  %33 = subi %arg6, %25 : index
                  %34 = subi %arg7, %27 : index
                  %35 = memref.load %10[%arg1, %arg5, %31, %32] : memref<1x6x14x14xf32>
                  %36 = memref.load %15[%arg2, %arg5, %33, %34] : memref<16x6x5x5xf32>
                  %37 = affine.load %23[] : memref<f32>
                  %38 = mulf %35, %36 : f32
                  %39 = addf %37, %38 : f32
                  affine.store %39, %23[] : memref<f32>
                }
              }
            }
            %28 = affine.load %23[] : memref<f32>
            %29 = affine.load %16[%arg2] : memref<16xf32>
            %30 = addf %28, %29 : f32
            affine.store %30, %9[%arg1, %arg2, %arg3, %arg4] : memref<1x16x10x10xf32>
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
            %23 = memref.alloca() : memref<f32>
            affine.store %cst, %23[] : memref<f32>
            %24 = affine.max #map3(%arg3, %arg3)
            %25 = affine.max #map4(%arg3, %arg3, %arg4, %arg4)
            affine.for %arg5 = 0 to min #map7(%arg3) {
              affine.for %arg6 = 0 to min #map7(%arg4) {
                %27 = addi %arg5, %24 : index
                %28 = addi %arg6, %25 : index
                %29 = memref.load %8[%arg1, %arg2, %27, %28] : memref<1x16x10x10xf32>
                %30 = affine.load %23[] : memref<f32>
                %31 = cmpf "ogt", %30, %29 : f32
                %32 = select %31, %30, %29 : f32
                affine.store %32, %23[] : memref<f32>
              }
            }
            %26 = affine.load %23[] : memref<f32>
            affine.store %26, %7[%arg1, %arg2, %arg3, %arg4] : memref<1x16x5x5xf32>
          }
        }
      }
    }
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 16 {
        affine.for %arg3 = 0 to 5 {
          affine.for %arg4 = 0 to 5 {
            %23 = affine.load %7[%arg1, %arg2, %arg3, %arg4] : memref<1x16x5x5xf32>
            %24 = affine.apply #map8(%arg2, %arg3, %arg4)[%c16, %c5, %c5]
            affine.store %23, %6[%arg1, %24] : memref<1x400xf32>
          }
        }
      }
    }
    %17 = "krnl.global"() {name = "constant_4", offset = 11400 : i64, shape = [120, 400]} : () -> memref<120x400xf32>
    %18 = "krnl.global"() {name = "constant_5", offset = 203400 : i64, shape = [120]} : () -> memref<120xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 120 {
        %23 = memref.alloca() : memref<f32>
        affine.store %cst_1, %23[] : memref<f32>
        affine.for %arg3 = 0 to 400 {
          %29 = affine.load %6[%arg1, %arg3] : memref<1x400xf32>
          %30 = affine.load %17[%arg2, %arg3] : memref<120x400xf32>
          %31 = affine.load %23[] : memref<f32>
          %32 = mulf %29, %30 : f32
          %33 = addf %31, %32 : f32
          affine.store %33, %23[] : memref<f32>
        }
        %24 = affine.load %23[] : memref<f32>
        %25 = mulf %cst_0, %24 : f32
        %26 = affine.load %18[%arg2] : memref<120xf32>
        %27 = mulf %cst_0, %26 : f32
        %28 = addf %25, %27 : f32
        affine.store %28, %5[%arg1, %arg2] : memref<1x120xf32>
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
        %23 = memref.alloca() : memref<f32>
        affine.store %cst_1, %23[] : memref<f32>
        affine.for %arg3 = 0 to 120 {
          %29 = affine.load %4[%arg1, %arg3] : memref<1x120xf32>
          %30 = affine.load %19[%arg2, %arg3] : memref<84x120xf32>
          %31 = affine.load %23[] : memref<f32>
          %32 = mulf %29, %30 : f32
          %33 = addf %31, %32 : f32
          affine.store %33, %23[] : memref<f32>
        }
        %24 = affine.load %23[] : memref<f32>
        %25 = mulf %cst_0, %24 : f32
        %26 = affine.load %20[%arg2] : memref<84xf32>
        %27 = mulf %cst_0, %26 : f32
        %28 = addf %25, %27 : f32
        affine.store %28, %3[%arg1, %arg2] : memref<1x84xf32>
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
    %22 = "krnl.global"() {name = "constant_9", offset = 247896 : i64, shape = [10], value = dense<[-0.0877175703, 0.0805240944, 0.0895289778, -0.0100614233, 0.0877776891, 0.0845330507, 0.0681114867, 0.102139458, -0.00870069116, 0.0728548169]> : tensor<10xf32>} : () -> memref<10xf32>
    affine.for %arg1 = 0 to 1 {
      affine.for %arg2 = 0 to 10 {
        %23 = memref.alloca() : memref<f32>
        affine.store %cst_1, %23[] : memref<f32>
        affine.for %arg3 = 0 to 84 {
          %29 = affine.load %2[%arg1, %arg3] : memref<1x84xf32>
          %30 = affine.load %21[%arg2, %arg3] : memref<10x84xf32>
          %31 = affine.load %23[] : memref<f32>
          %32 = mulf %29, %30 : f32
          %33 = addf %31, %32 : f32
          affine.store %33, %23[] : memref<f32>
        }
        %24 = affine.load %23[] : memref<f32>
        %25 = mulf %cst_0, %24 : f32
        %26 = affine.load %22[%arg2] : memref<10xf32>
        %27 = mulf %cst_0, %26 : f32
        %28 = addf %25, %27 : f32
        affine.store %28, %1[%arg1, %arg2] : memref<1x10xf32>
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

