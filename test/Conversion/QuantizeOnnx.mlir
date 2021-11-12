// RUN: scalehls-opt -quantize-onnx %s | FileCheck %s

// CHECK: module  {
module  {
  func @dataflow2(%arg0: memref<1x120xf32>, %arg1: f32, %arg2: memref<1x84xf32>, %arg3: memref<84x120xf32>, %arg4: f32, %arg5: memref<84xf32>) {
    %0 = memref.alloc() : memref<1x120xf32>
    affine.for %arg6 = 0 to 120 {
      %1 = affine.load %arg0[0, %arg6] : memref<1x120xf32>
      %2 = arith.cmpf olt, %1, %arg1 : f32
      %3 = select %2, %arg1, %1 : f32
      affine.store %3, %0[0, %arg6] : memref<1x120xf32>
    }
    affine.for %arg6 = 0 to 84 {
      affine.store %arg1, %arg2[0, %arg6] : memref<1x84xf32>
      affine.for %arg7 = 0 to 120 {
        %6 = affine.load %0[0, %arg7] : memref<1x120xf32>
        %7 = affine.load %arg3[%arg6, %arg7] : memref<84x120xf32>
        %8 = affine.load %arg2[0, %arg6] : memref<1x84xf32>
        %9 = arith.mulf %6, %7 : f32
        %10 = arith.addf %8, %9 : f32
        affine.store %10, %arg2[0, %arg6] : memref<1x84xf32>
      }
      %1 = affine.load %arg2[0, %arg6] : memref<1x84xf32>
      %2 = arith.mulf %arg4, %1 : f32
      %3 = affine.load %arg5[%arg6] : memref<84xf32>
      %4 = arith.mulf %arg4, %3 : f32
      %5 = arith.addf %2, %4 : f32
      affine.store %5, %arg2[0, %arg6] : memref<1x84xf32>
    }
    return
  }
  func @dataflow4(%arg0: f32, %arg1: memref<1x6x14x14xf32>, %arg2: memref<16x6x5x5xf32>, %arg3: memref<1x16x5x5xf32>) {
    %0 = memref.alloc() : memref<1x16x5x5xf32>
    affine.for %arg4 = 0 to 16 {
      affine.for %arg5 = 0 to 5 {
        affine.for %arg6 = 0 to 5 {
          affine.store %arg0, %0[0, %arg4, %arg5, %arg6] : memref<1x16x5x5xf32>
          affine.for %arg7 = 0 to 6 {
            affine.for %arg8 = 0 to 5 {
              affine.for %arg9 = 0 to 5 {
                %1 = affine.load %arg1[0, %arg7, %arg5 * 2 + %arg8, %arg6 * 2 + %arg9] : memref<1x6x14x14xf32>
                %2 = affine.load %arg2[%arg4, %arg7, %arg8, %arg9] : memref<16x6x5x5xf32>
                %3 = affine.load %0[0, %arg4, %arg5, %arg6] : memref<1x16x5x5xf32>
                %4 = arith.mulf %1, %2 : f32
                %5 = arith.addf %3, %4 : f32
                affine.store %5, %0[0, %arg4, %arg5, %arg6] : memref<1x16x5x5xf32>
              }
            }
          }
        }
      }
    }
    affine.for %arg4 = 0 to 16 {
      affine.for %arg5 = 0 to 5 {
        affine.for %arg6 = 0 to 5 {
          %1 = affine.load %0[0, %arg4, %arg5, %arg6] : memref<1x16x5x5xf32>
          %2 = arith.cmpf olt, %1, %arg0 : f32
          %3 = select %2, %arg0, %1 : f32
          affine.store %3, %arg3[0, %arg4, %arg5, %arg6] : memref<1x16x5x5xf32>
        }
      }
    }
    return
  }
  func @dataflow1(%arg0: memref<1x84xf32>, %arg1: f32, %arg2: memref<1x10xf32>, %arg3: memref<10x84xf32>, %arg4: f32, %arg5: memref<10xf32>) {
    %0 = memref.alloc() : memref<1x84xf32>
    affine.for %arg6 = 0 to 84 {
      %1 = affine.load %arg0[0, %arg6] : memref<1x84xf32>
      %2 = arith.cmpf olt, %1, %arg1 : f32
      %3 = select %2, %arg1, %1 : f32
      affine.store %3, %0[0, %arg6] : memref<1x84xf32>
    }
    affine.for %arg6 = 0 to 10 {
      affine.store %arg1, %arg2[0, %arg6] : memref<1x10xf32>
      affine.for %arg7 = 0 to 84 {
        %6 = affine.load %0[0, %arg7] : memref<1x84xf32>
        %7 = affine.load %arg3[%arg6, %arg7] : memref<10x84xf32>
        %8 = affine.load %arg2[0, %arg6] : memref<1x10xf32>
        %9 = arith.mulf %6, %7 : f32
        %10 = arith.addf %8, %9 : f32
        affine.store %10, %arg2[0, %arg6] : memref<1x10xf32>
      }
      %1 = affine.load %arg2[0, %arg6] : memref<1x10xf32>
      %2 = arith.mulf %arg4, %1 : f32
      %3 = affine.load %arg5[%arg6] : memref<10xf32>
      %4 = arith.mulf %arg4, %3 : f32
      %5 = arith.addf %2, %4 : f32
      affine.store %5, %arg2[0, %arg6] : memref<1x10xf32>
    }
    return
  }
  func @dataflow3(%arg0: memref<1x16x5x5xf32>, %arg1: f32, %arg2: memref<1x120xf32>, %arg3: memref<120x400xf32>, %arg4: f32, %arg5: memref<120xf32>) {
    %0 = memref.alloc() : memref<1x400xf32>
    affine.for %arg6 = 0 to 16 {
      affine.for %arg7 = 0 to 5 {
        affine.for %arg8 = 0 to 5 {
          %1 = affine.load %arg0[0, %arg6, %arg7, %arg8] : memref<1x16x5x5xf32>
          affine.store %1, %0[0, %arg6 * 25 + %arg7 * 5 + %arg8] : memref<1x400xf32>
        }
      }
    }
    affine.for %arg6 = 0 to 120 {
      affine.store %arg1, %arg2[0, %arg6] : memref<1x120xf32>
      affine.for %arg7 = 0 to 400 {
        %6 = affine.load %0[0, %arg7] : memref<1x400xf32>
        %7 = affine.load %arg3[%arg6, %arg7] : memref<120x400xf32>
        %8 = affine.load %arg2[0, %arg6] : memref<1x120xf32>
        %9 = arith.mulf %6, %7 : f32
        %10 = arith.addf %8, %9 : f32
        affine.store %10, %arg2[0, %arg6] : memref<1x120xf32>
      }
      %1 = affine.load %arg2[0, %arg6] : memref<1x120xf32>
      %2 = arith.mulf %arg4, %1 : f32
      %3 = affine.load %arg5[%arg6] : memref<120xf32>
      %4 = arith.mulf %arg4, %3 : f32
      %5 = arith.addf %2, %4 : f32
      affine.store %5, %arg2[0, %arg6] : memref<1x120xf32>
    }
    return
  }
  func @dataflow5(%arg0: f32, %arg1: memref<1x3x32x32xf32>, %arg2: memref<6x3x5x5xf32>, %arg3: memref<1x6x14x14xf32>) {
    %0 = memref.alloc() : memref<1x6x14x14xf32>
    affine.for %arg4 = 0 to 6 {
      affine.for %arg5 = 0 to 14 {
        affine.for %arg6 = 0 to 14 {
          affine.store %arg0, %0[0, %arg4, %arg5, %arg6] : memref<1x6x14x14xf32>
          affine.for %arg7 = 0 to 3 {
            affine.for %arg8 = 0 to 5 {
              affine.for %arg9 = 0 to 5 {
                %1 = affine.load %arg1[0, %arg7, %arg5 * 2 + %arg8, %arg6 * 2 + %arg9] : memref<1x3x32x32xf32>
                %2 = affine.load %arg2[%arg4, %arg7, %arg8, %arg9] : memref<6x3x5x5xf32>
                %3 = affine.load %0[0, %arg4, %arg5, %arg6] : memref<1x6x14x14xf32>
                %4 = arith.mulf %1, %2 : f32
                %5 = arith.addf %3, %4 : f32
                affine.store %5, %0[0, %arg4, %arg5, %arg6] : memref<1x6x14x14xf32>
              }
            }
          }
        }
      }
    }
    affine.for %arg4 = 0 to 6 {
      affine.for %arg5 = 0 to 14 {
        affine.for %arg6 = 0 to 14 {
          %1 = affine.load %0[0, %arg4, %arg5, %arg6] : memref<1x6x14x14xf32>
          %2 = arith.cmpf olt, %1, %arg0 : f32
          %3 = select %2, %arg0, %1 : f32
          affine.store %3, %arg3[0, %arg4, %arg5, %arg6] : memref<1x6x14x14xf32>
        }
      }
    }
    return
  }
  func @main_graph(%arg0: memref<1x3x32x32xf32>, %arg1: memref<6x3x5x5xf32>, %arg2: memref<16x6x5x5xf32>, %arg3: memref<120x400xf32>, %arg4: memref<120xf32>, %arg5: memref<84x120xf32>, %arg6: memref<84xf32>, %arg7: memref<10x84xf32>) -> memref<1x10xf32> attributes {dataflow = true, input_names = ["input.1"], inputs_num = 1 : i64, output_names = ["18"], outputs_num = 1 : i64, top_function = true, weight_file_name = "/tmp/packed_const-b6b002.tmp", weight_index = [1, 2, 3, 4, 5, 6, 7], weight_offsets = [0, 1800, 11400, 203400, 203880, 244200, 244536], weight_size_in_bytes = 247896 : i64} {
    %cst = arith.constant 1.000000e+00 : f32
    %cst_0 = arith.constant 0.000000e+00 : f32
    %cst_1 = arith.constant dense<[0.0802067816, 0.0380531251, -0.0453170575, 0.0238099229, -0.0322267264, 0.0956416651, -0.0513828322, -0.00329447933, 0.0870032906, -0.100006074]> : tensor<10xf32>
    %0 = memref.alloc() : memref<1x10xf32>
    %1 = memref.alloc() : memref<1x84xf32>
    %2 = memref.alloc() : memref<1x120xf32>
    %3 = memref.alloc() : memref<1x16x5x5xf32>
    %4 = memref.alloc() : memref<1x6x14x14xf32>
    call @dataflow5(%cst_0, %arg0, %arg1, %4) : (f32, memref<1x3x32x32xf32>, memref<6x3x5x5xf32>, memref<1x6x14x14xf32>) -> ()
    call @dataflow4(%cst_0, %4, %arg2, %3) : (f32, memref<1x6x14x14xf32>, memref<16x6x5x5xf32>, memref<1x16x5x5xf32>) -> ()
    call @dataflow3(%3, %cst_0, %2, %arg3, %cst, %arg4) : (memref<1x16x5x5xf32>, f32, memref<1x120xf32>, memref<120x400xf32>, f32, memref<120xf32>) -> ()
    call @dataflow2(%2, %cst_0, %1, %arg5, %cst, %arg6) : (memref<1x120xf32>, f32, memref<1x84xf32>, memref<84x120xf32>, f32, memref<84xf32>) -> ()
    %5 = memref.buffer_cast %cst_1 : memref<10xf32>
    call @dataflow1(%1, %cst_0, %0, %arg7, %cst, %5) : (memref<1x84xf32>, f32, memref<1x10xf32>, memref<10x84xf32>, f32, memref<10xf32>) -> ()
    return %0 : memref<1x10xf32>
  }
}
