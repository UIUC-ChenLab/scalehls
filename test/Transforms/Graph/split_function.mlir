// RUN: scalehls-opt -split-function %s | FileCheck %s

module {
  // CHECK-LABEL: func @dataflow2(
  // CHECK-LABEL: func @dataflow4(
  // CHECK-LABEL: func @dataflow1(
  // CHECK-LABEL: func @dataflow3(

  // CHECK-LABEL: func @main_graph(
  // CHECK-LABEL:   call @dataflow4
  // CHECK-LABEL:   call @dataflow3
  // CHECK-LABEL:   call @dataflow2
  // CHECK-LABEL:   call @dataflow1
  func @main_graph(%arg0: memref<1x3x32x32xf32>, %arg1: memref<6x3x5x5xf32>, %arg2: memref<16x6x5x5xf32>, %arg3: memref<120x400xf32>, %arg4: memref<120xf32>, %arg5: memref<84x120xf32>, %arg6: memref<84xf32>, %arg7: memref<10x84xf32>) -> memref<1x10xf32> attributes {func_directive = #hlscpp.fd<pipeline=false, targetInterval=1, dataflow=true>, input_names = ["input.1"], inputs_num = 1 : i64, output_names = ["18"], outputs_num = 1 : i64, weight_file_name = "/tmp/packed_const-b6b002.tmp", weight_index = [1, 2, 3, 4, 5, 6, 7], weight_offsets = [0, 1800, 11400, 203400, 203880, 244200, 244536], weight_size_in_bytes = 247896 : i64} {
    %cst = arith.constant dense<[0.0802067816, 0.0380531251, -0.0453170575, 0.0238099229, -0.0322267264, 0.0956416651, -0.0513828322, -0.00329447933, 0.0870032906, -0.100006074]> : tensor<10xf32>
    %cst_0 = arith.constant 0.000000e+00 : f32
    %cst_1 = arith.constant 1.000000e+00 : f32
    %0 = memref.alloc() : memref<1x10xf32>
    %1 = memref.alloc() : memref<1x84xf32>
    %2 = memref.alloc() : memref<1x84xf32>
    %3 = memref.alloc() : memref<1x120xf32>
    %4 = memref.alloc() : memref<1x120xf32>
    %5 = memref.alloc() : memref<1x400xf32>
    %6 = memref.alloc() : memref<1x16x5x5xf32>
    %7 = memref.alloc() : memref<1x16x5x5xf32>
    %8 = memref.alloc() : memref<1x6x14x14xf32>
    %9 = memref.alloc() : memref<1x6x14x14xf32>
    affine.for %arg8 = 0 to 6 {
      affine.for %arg9 = 0 to 14 {
        affine.for %arg10 = 0 to 14 {
          affine.store %cst_0, %9[0, %arg8, %arg9, %arg10] : memref<1x6x14x14xf32>
          affine.for %arg11 = 0 to 3 {
            affine.for %arg12 = 0 to 5 {
              affine.for %arg13 = 0 to 5 {
                %11 = affine.load %arg0[0, %arg11, %arg9 * 2 + %arg12, %arg10 * 2 + %arg13] : memref<1x3x32x32xf32>
                %12 = affine.load %arg1[%arg8, %arg11, %arg12, %arg13] : memref<6x3x5x5xf32>
                %13 = affine.load %9[0, %arg8, %arg9, %arg10] : memref<1x6x14x14xf32>
                %14 = arith.mulf %11, %12 : f32
                %15 = arith.addf %13, %14 : f32
                affine.store %15, %9[0, %arg8, %arg9, %arg10] : memref<1x6x14x14xf32>
              }
            }
          }
        }
      }
    } {dataflow_level = 4 : i64}
    affine.for %arg8 = 0 to 6 {
      affine.for %arg9 = 0 to 14 {
        affine.for %arg10 = 0 to 14 {
          %11 = affine.load %9[0, %arg8, %arg9, %arg10] : memref<1x6x14x14xf32>
          %12 = arith.cmpf olt, %11, %cst_0 : f32
          %13 = arith.select %12, %cst_0, %11 : f32
          affine.store %13, %8[0, %arg8, %arg9, %arg10] : memref<1x6x14x14xf32>
        }
      }
    } {dataflow_level = 3 : i64}
    affine.for %arg8 = 0 to 16 {
      affine.for %arg9 = 0 to 5 {
        affine.for %arg10 = 0 to 5 {
          affine.store %cst_0, %7[0, %arg8, %arg9, %arg10] : memref<1x16x5x5xf32>
          affine.for %arg11 = 0 to 6 {
            affine.for %arg12 = 0 to 5 {
              affine.for %arg13 = 0 to 5 {
                %11 = affine.load %8[0, %arg11, %arg9 * 2 + %arg12, %arg10 * 2 + %arg13] : memref<1x6x14x14xf32>
                %12 = affine.load %arg2[%arg8, %arg11, %arg12, %arg13] : memref<16x6x5x5xf32>
                %13 = affine.load %7[0, %arg8, %arg9, %arg10] : memref<1x16x5x5xf32>
                %14 = arith.mulf %11, %12 : f32
                %15 = arith.addf %13, %14 : f32
                affine.store %15, %7[0, %arg8, %arg9, %arg10] : memref<1x16x5x5xf32>
              }
            }
          }
        }
      }
    } {dataflow_level = 3 : i64}
    affine.for %arg8 = 0 to 16 {
      affine.for %arg9 = 0 to 5 {
        affine.for %arg10 = 0 to 5 {
          %11 = affine.load %7[0, %arg8, %arg9, %arg10] : memref<1x16x5x5xf32>
          %12 = arith.cmpf olt, %11, %cst_0 : f32
          %13 = arith.select %12, %cst_0, %11 : f32
          affine.store %13, %6[0, %arg8, %arg9, %arg10] : memref<1x16x5x5xf32>
        }
      }
    } {dataflow_level = 3 : i64}
    affine.for %arg8 = 0 to 16 {
      affine.for %arg9 = 0 to 5 {
        affine.for %arg10 = 0 to 5 {
          %11 = affine.load %6[0, %arg8, %arg9, %arg10] : memref<1x16x5x5xf32>
          affine.store %11, %5[0, %arg8 * 25 + %arg9 * 5 + %arg10] : memref<1x400xf32>
        }
      }
    } {dataflow_level = 2 : i64}
    affine.for %arg8 = 0 to 120 {
      affine.store %cst_0, %4[0, %arg8] : memref<1x120xf32>
      affine.for %arg9 = 0 to 400 {
        %16 = affine.load %5[0, %arg9] : memref<1x400xf32>
        %17 = affine.load %arg3[%arg8, %arg9] : memref<120x400xf32>
        %18 = affine.load %4[0, %arg8] : memref<1x120xf32>
        %19 = arith.mulf %16, %17 : f32
        %20 = arith.addf %18, %19 : f32
        affine.store %20, %4[0, %arg8] : memref<1x120xf32>
      }
      %11 = affine.load %4[0, %arg8] : memref<1x120xf32>
      %12 = arith.mulf %cst_1, %11 : f32
      %13 = affine.load %arg4[%arg8] : memref<120xf32>
      %14 = arith.mulf %cst_1, %13 : f32
      %15 = arith.addf %12, %14 : f32
      affine.store %15, %4[0, %arg8] : memref<1x120xf32>
    } {dataflow_level = 2 : i64}
    affine.for %arg8 = 0 to 120 {
      %11 = affine.load %4[0, %arg8] : memref<1x120xf32>
      %12 = arith.cmpf olt, %11, %cst_0 : f32
      %13 = arith.select %12, %cst_0, %11 : f32
      affine.store %13, %3[0, %arg8] : memref<1x120xf32>
    } {dataflow_level = 2 : i64}
    affine.for %arg8 = 0 to 84 {
      affine.store %cst_0, %2[0, %arg8] : memref<1x84xf32>
      affine.for %arg9 = 0 to 120 {
        %16 = affine.load %3[0, %arg9] : memref<1x120xf32>
        %17 = affine.load %arg5[%arg8, %arg9] : memref<84x120xf32>
        %18 = affine.load %2[0, %arg8] : memref<1x84xf32>
        %19 = arith.mulf %16, %17 : f32
        %20 = arith.addf %18, %19 : f32
        affine.store %20, %2[0, %arg8] : memref<1x84xf32>
      }
      %11 = affine.load %2[0, %arg8] : memref<1x84xf32>
      %12 = arith.mulf %cst_1, %11 : f32
      %13 = affine.load %arg6[%arg8] : memref<84xf32>
      %14 = arith.mulf %cst_1, %13 : f32
      %15 = arith.addf %12, %14 : f32
      affine.store %15, %2[0, %arg8] : memref<1x84xf32>
    } {dataflow_level = 1 : i64}
    affine.for %arg8 = 0 to 84 {
      %11 = affine.load %2[0, %arg8] : memref<1x84xf32>
      %12 = arith.cmpf olt, %11, %cst_0 : f32
      %13 = arith.select %12, %cst_0, %11 : f32
      affine.store %13, %1[0, %arg8] : memref<1x84xf32>
    } {dataflow_level = 1 : i64}
    %10 = bufferization.to_memref %cst : memref<10xf32>
    affine.for %arg8 = 0 to 10 {
      affine.store %cst_0, %0[0, %arg8] : memref<1x10xf32>
      affine.for %arg9 = 0 to 84 {
        %16 = affine.load %1[0, %arg9] : memref<1x84xf32>
        %17 = affine.load %arg7[%arg8, %arg9] : memref<10x84xf32>
        %18 = affine.load %0[0, %arg8] : memref<1x10xf32>
        %19 = arith.mulf %16, %17 : f32
        %20 = arith.addf %18, %19 : f32
        affine.store %20, %0[0, %arg8] : memref<1x10xf32>
      }
      %11 = affine.load %0[0, %arg8] : memref<1x10xf32>
      %12 = arith.mulf %cst_1, %11 : f32
      %13 = affine.load %10[%arg8] : memref<10xf32>
      %14 = arith.mulf %cst_1, %13 : f32
      %15 = arith.addf %12, %14 : f32
      affine.store %15, %0[0, %arg8] : memref<1x10xf32>
    } {dataflow_level = 1 : i64}
    return %0 : memref<1x10xf32>
  }
}
