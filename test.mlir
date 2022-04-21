module attributes {llvm.data_layout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128", llvm.target_triple = "x86_64-unknown-linux-gnu"} {
  func @test(%arg0: memref<832xf64>, %arg1: memref<4096xf64>, %arg2: memref<192xf64>, %arg3: memref<64xf64>, %arg4: memref<64xf64>, %arg5: memref<3xf64>, %arg6: memref<2119xf64>, %arg7: memref<489xf64>) attributes {llvm.linkage = #llvm.linkage<external>} {
    %cst = arith.constant 0.000000e+00 : f64
    %0 = memref.alloca() : memref<64xf64>
    %1 = memref.alloca() : memref<64xf64>
    %2 = memref.alloca() : memref<192xf64>
    %3 = memref.alloca() : memref<4096xf64>
    %4 = memref.alloca() : memref<832xf64>
    %5 = memref.alloca() : memref<3xf64>
    %6 = memref.alloca() : memref<3xf64>
    %7 = memref.alloca() : memref<3xf64>
    %8 = memref.alloca() : memref<64xf64>
    %9 = memref.alloca() : memref<64xf64>
    %10 = memref.alloca() : memref<3xf64>
    %11 = memref.alloca() : memref<64xf64>
    %12 = memref.alloca() : memref<64xf64>
    %13 = memref.cast %10 : memref<3xf64> to memref<64xf64>
    %14 = memref.cast %7 : memref<3xf64> to memref<64xf64>
    affine.for %arg8 = 0 to 163 {
      affine.for %arg9 = 0 to 64 {
        affine.store %cst, %12[%arg9] : memref<64xf64>
        affine.store %cst, %11[%arg9] : memref<64xf64>
        affine.if affine_set<(d0) : (-d0 + 2 >= 0)>(%arg9) {
          affine.store %cst, %10[%arg9] : memref<3xf64>
        }
      }
      call @RELU(%13, %14) : (memref<64xf64>, memref<64xf64>) -> ()
      call @soft_max(%6, %10) : (memref<3xf64>, memref<3xf64>) -> ()
      call @get_delta_matrix_weights3(%2, %5, %11) : (memref<192xf64>, memref<3xf64>, memref<64xf64>) -> ()
      call @get_oracle_activations2(%arg2, %5, %0, %8) : (memref<192xf64>, memref<3xf64>, memref<64xf64>, memref<64xf64>) -> ()
      call @get_delta_matrix_weights2(%3, %0, %12) : (memref<4096xf64>, memref<64xf64>, memref<64xf64>) -> ()
      call @get_oracle_activations1(%arg1, %0, %1, %9) : (memref<4096xf64>, memref<64xf64>, memref<64xf64>, memref<64xf64>) -> ()
      call @update_weights(%arg0, %arg1, %arg2, %4, %3, %2, %arg3, %arg4, %arg5, %1, %0, %5) : (memref<832xf64>, memref<4096xf64>, memref<192xf64>, memref<832xf64>, memref<4096xf64>, memref<192xf64>, memref<64xf64>, memref<64xf64>, memref<3xf64>, memref<64xf64>, memref<64xf64>, memref<3xf64>) -> ()
    }
    return
  }
  func @RELU(%arg0: memref<64xf64>, %arg1: memref<64xf64>) attributes {llvm.linkage = #llvm.linkage<external>} {
    %cst = arith.constant 1.000000e+00 : f64
    affine.for %arg2 = 0 to 3 {
      %0 = affine.load %arg0[%arg2] : memref<64xf64>
      %1 = arith.subf %cst, %0 : f64
      %2 = arith.mulf %0, %1 : f64
      affine.store %2, %arg1[%arg2] : memref<64xf64>
      %3 = affine.load %arg0[%arg2] : memref<64xf64>
      %4 = arith.negf %3 : f64
      %5 = math.exp %4 : f64
      %6 = arith.addf %5, %cst : f64
      %7 = arith.divf %cst, %6 : f64
      affine.store %7, %arg0[%arg2] : memref<64xf64>
    }
    return
  }
  func @soft_max(%arg0: memref<3xf64>, %arg1: memref<3xf64>) attributes {llvm.linkage = #llvm.linkage<external>} {
    %cst = arith.constant 0.000000e+00 : f64
    %0:2 = affine.for %arg2 = 0 to 3 iter_args(%arg3 = %cst, %arg4 = %cst) -> (f64, f64) {
      %1 = affine.load %arg1[%arg2] : memref<3xf64>
      %2 = arith.negf %1 : f64
      %3 = math.exp %2 : f64
      %4 = arith.addf %arg3, %3 : f64
      affine.yield %4, %4 : f64, f64
    }
    affine.for %arg2 = 0 to 3 {
      %1 = affine.load %arg1[%arg2] : memref<3xf64>
      %2 = arith.negf %1 : f64
      %3 = math.exp %2 : f64
      %4 = arith.divf %3, %0#1 : f64
      affine.store %4, %arg0[%arg2] : memref<3xf64>
    }
    return
  }
  func @get_delta_matrix_weights3(%arg0: memref<192xf64>, %arg1: memref<3xf64>, %arg2: memref<64xf64>) attributes {llvm.linkage = #llvm.linkage<external>} {
    affine.for %arg3 = 0 to 64 {
      affine.for %arg4 = 0 to 3 {
        %0 = affine.load %arg2[%arg3] : memref<64xf64>
        %1 = affine.load %arg1[%arg4] : memref<3xf64>
        %2 = arith.mulf %0, %1 : f64
        affine.store %2, %arg0[%arg4 + %arg3 * 3] : memref<192xf64>
      }
    }
    return
  }
  func @get_oracle_activations2(%arg0: memref<192xf64>, %arg1: memref<3xf64>, %arg2: memref<64xf64>, %arg3: memref<64xf64>) attributes {llvm.linkage = #llvm.linkage<external>} {
    %cst = arith.constant 0.000000e+00 : f64
    affine.for %arg4 = 0 to 64 {
      affine.store %cst, %arg2[%arg4] : memref<64xf64>
      affine.for %arg5 = 0 to 3 {
        %3 = affine.load %arg1[%arg5] : memref<3xf64>
        %4 = affine.load %arg0[%arg5 + %arg4 * 3] : memref<192xf64>
        %5 = arith.mulf %3, %4 : f64
        %6 = affine.load %arg2[%arg4] : memref<64xf64>
        %7 = arith.addf %6, %5 : f64
        affine.store %7, %arg2[%arg4] : memref<64xf64>
      }
      %0 = affine.load %arg2[%arg4] : memref<64xf64>
      %1 = affine.load %arg3[%arg4] : memref<64xf64>
      %2 = arith.mulf %0, %1 : f64
      affine.store %2, %arg2[%arg4] : memref<64xf64>
    }
    return
  }
  func @get_delta_matrix_weights2(%arg0: memref<4096xf64>, %arg1: memref<64xf64>, %arg2: memref<64xf64>) attributes {llvm.linkage = #llvm.linkage<external>} {
    affine.for %arg3 = 0 to 64 {
      affine.for %arg4 = 0 to 64 {
        %0 = affine.load %arg2[%arg3] : memref<64xf64>
        %1 = affine.load %arg1[%arg4] : memref<64xf64>
        %2 = arith.mulf %0, %1 : f64
        affine.store %2, %arg0[%arg4 + %arg3 * 64] : memref<4096xf64>
      }
    }
    return
  }
  func @get_oracle_activations1(%arg0: memref<4096xf64>, %arg1: memref<64xf64>, %arg2: memref<64xf64>, %arg3: memref<64xf64>) attributes {llvm.linkage = #llvm.linkage<external>} {
    %cst = arith.constant 0.000000e+00 : f64
    affine.for %arg4 = 0 to 64 {
      affine.store %cst, %arg2[%arg4] : memref<64xf64>
      affine.for %arg5 = 0 to 64 {
        %3 = affine.load %arg1[%arg5] : memref<64xf64>
        %4 = affine.load %arg0[%arg5 + %arg4 * 64] : memref<4096xf64>
        %5 = arith.mulf %3, %4 : f64
        %6 = affine.load %arg2[%arg4] : memref<64xf64>
        %7 = arith.addf %6, %5 : f64
        affine.store %7, %arg2[%arg4] : memref<64xf64>
      }
      %0 = affine.load %arg2[%arg4] : memref<64xf64>
      %1 = affine.load %arg3[%arg4] : memref<64xf64>
      %2 = arith.mulf %0, %1 : f64
      affine.store %2, %arg2[%arg4] : memref<64xf64>
    }
    return
  }
  func @update_weights(%arg0: memref<832xf64>, %arg1: memref<4096xf64>, %arg2: memref<192xf64>, %arg3: memref<832xf64>, %arg4: memref<4096xf64>, %arg5: memref<192xf64>, %arg6: memref<64xf64>, %arg7: memref<64xf64>, %arg8: memref<3xf64>, %arg9: memref<64xf64>, %arg10: memref<64xf64>, %arg11: memref<3xf64>) attributes {llvm.linkage = #llvm.linkage<external>} {
    %cst = arith.constant 0.000000e+00 : f64
    %cst_0 = arith.constant 1.000000e-02 : f64
    %0:2 = affine.for %arg12 = 0 to 13 iter_args(%arg13 = %cst, %arg14 = %cst) -> (f64, f64) {
      %12:2 = affine.for %arg15 = 0 to 64 iter_args(%arg16 = %arg13, %arg17 = %arg13) -> (f64, f64) {
        %13 = affine.load %arg3[%arg15 + %arg12 * 64] : memref<832xf64>
        %14 = arith.mulf %13, %cst_0 : f64
        %15 = affine.load %arg0[%arg15 + %arg12 * 64] : memref<832xf64>
        %16 = arith.subf %15, %14 : f64
        affine.store %16, %arg0[%arg15 + %arg12 * 64] : memref<832xf64>
        %17 = arith.mulf %16, %16 : f64
        %18 = arith.addf %arg16, %17 : f64
        affine.yield %18, %18 : f64, f64
      }
      affine.yield %12#1, %12#1 : f64, f64
    }
    %1:2 = affine.for %arg12 = 0 to 64 iter_args(%arg13 = %cst, %arg14 = %cst) -> (f64, f64) {
      %12 = affine.load %arg9[%arg12] : memref<64xf64>
      %13 = arith.mulf %12, %cst_0 : f64
      %14 = affine.load %arg6[%arg12] : memref<64xf64>
      %15 = arith.subf %14, %13 : f64
      affine.store %15, %arg6[%arg12] : memref<64xf64>
      %16 = arith.mulf %15, %15 : f64
      %17 = arith.addf %arg13, %16 : f64
      affine.yield %17, %17 : f64, f64
    }
    %2 = math.sqrt %0#1 : f64
    %3 = math.sqrt %1#1 : f64
    affine.for %arg12 = 0 to 13 {
      affine.for %arg13 = 0 to 64 {
        %12 = affine.load %arg0[%arg13 + %arg12 * 64] : memref<832xf64>
        %13 = arith.divf %12, %2 : f64
        affine.store %13, %arg0[%arg13 + %arg12 * 64] : memref<832xf64>
      }
    }
    affine.for %arg12 = 0 to 64 {
      %12 = affine.load %arg6[%arg12] : memref<64xf64>
      %13 = arith.divf %12, %3 : f64
      affine.store %13, %arg6[%arg12] : memref<64xf64>
    }
    %4:2 = affine.for %arg12 = 0 to 64 iter_args(%arg13 = %cst, %arg14 = %cst) -> (f64, f64) {
      %12:2 = affine.for %arg15 = 0 to 64 iter_args(%arg16 = %arg13, %arg17 = %arg13) -> (f64, f64) {
        %13 = affine.load %arg4[%arg15 + %arg12 * 64] : memref<4096xf64>
        %14 = arith.mulf %13, %cst_0 : f64
        %15 = affine.load %arg1[%arg15 + %arg12 * 64] : memref<4096xf64>
        %16 = arith.subf %15, %14 : f64
        affine.store %16, %arg1[%arg15 + %arg12 * 64] : memref<4096xf64>
        %17 = arith.mulf %16, %16 : f64
        %18 = arith.addf %arg16, %17 : f64
        affine.yield %18, %18 : f64, f64
      }
      affine.yield %12#1, %12#1 : f64, f64
    }
    %5:2 = affine.for %arg12 = 0 to 64 iter_args(%arg13 = %cst, %arg14 = %cst) -> (f64, f64) {
      %12 = affine.load %arg10[%arg12] : memref<64xf64>
      %13 = arith.mulf %12, %cst_0 : f64
      %14 = affine.load %arg7[%arg12] : memref<64xf64>
      %15 = arith.subf %14, %13 : f64
      affine.store %15, %arg7[%arg12] : memref<64xf64>
      %16 = arith.mulf %15, %15 : f64
      %17 = arith.addf %arg13, %16 : f64
      affine.yield %17, %17 : f64, f64
    }
    %6 = math.sqrt %4#1 : f64
    %7 = math.sqrt %5#1 : f64
    affine.for %arg12 = 0 to 64 {
      affine.for %arg13 = 0 to 64 {
        %12 = affine.load %arg1[%arg13 + %arg12 * 64] : memref<4096xf64>
        %13 = arith.divf %12, %6 : f64
        affine.store %13, %arg1[%arg13 + %arg12 * 64] : memref<4096xf64>
      }
    }
    affine.for %arg12 = 0 to 64 {
      %12 = affine.load %arg7[%arg12] : memref<64xf64>
      %13 = arith.divf %12, %7 : f64
      affine.store %13, %arg7[%arg12] : memref<64xf64>
    }
    %8:2 = affine.for %arg12 = 0 to 64 iter_args(%arg13 = %cst, %arg14 = %cst) -> (f64, f64) {
      %12:2 = affine.for %arg15 = 0 to 3 iter_args(%arg16 = %arg13, %arg17 = %arg13) -> (f64, f64) {
        %13 = affine.load %arg5[%arg15 + %arg12 * 3] : memref<192xf64>
        %14 = arith.mulf %13, %cst_0 : f64
        %15 = affine.load %arg2[%arg15 + %arg12 * 3] : memref<192xf64>
        %16 = arith.subf %15, %14 : f64
        affine.store %16, %arg2[%arg15 + %arg12 * 3] : memref<192xf64>
        %17 = arith.mulf %16, %16 : f64
        %18 = arith.addf %arg16, %17 : f64
        affine.yield %18, %18 : f64, f64
      }
      affine.yield %12#1, %12#1 : f64, f64
    }
    %9:2 = affine.for %arg12 = 0 to 3 iter_args(%arg13 = %cst, %arg14 = %cst) -> (f64, f64) {
      %12 = affine.load %arg11[%arg12] : memref<3xf64>
      %13 = arith.mulf %12, %cst_0 : f64
      %14 = affine.load %arg8[%arg12] : memref<3xf64>
      %15 = arith.subf %14, %13 : f64
      affine.store %15, %arg8[%arg12] : memref<3xf64>
      %16 = arith.mulf %15, %15 : f64
      %17 = arith.addf %arg13, %16 : f64
      affine.yield %17, %17 : f64, f64
    }
    %10 = math.sqrt %8#1 : f64
    %11 = math.sqrt %9#1 : f64
    affine.for %arg12 = 0 to 64 {
      affine.for %arg13 = 0 to 3 {
        %12 = affine.load %arg2[%arg13 + %arg12 * 3] : memref<192xf64>
        %13 = arith.divf %12, %10 : f64
        affine.store %13, %arg2[%arg13 + %arg12 * 3] : memref<192xf64>
      }
    }
    affine.for %arg12 = 0 to 3 {
      %12 = affine.load %arg8[%arg12] : memref<3xf64>
      %13 = arith.divf %12, %11 : f64
      affine.store %13, %arg8[%arg12] : memref<3xf64>
    }
    return
  }
}