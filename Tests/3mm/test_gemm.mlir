module attributes {dlti.dl_spec = #dlti.dl_spec<#dlti.dl_entry<"dlti.endianness", "little">, #dlti.dl_entry<i64, dense<64> : vector<2xi32>>, #dlti.dl_entry<f80, dense<128> : vector<2xi32>>, #dlti.dl_entry<i1, dense<8> : vector<2xi32>>, #dlti.dl_entry<i8, dense<8> : vector<2xi32>>, #dlti.dl_entry<i16, dense<16> : vector<2xi32>>, #dlti.dl_entry<i32, dense<32> : vector<2xi32>>, #dlti.dl_entry<f16, dense<16> : vector<2xi32>>, #dlti.dl_entry<f64, dense<64> : vector<2xi32>>, #dlti.dl_entry<f128, dense<128> : vector<2xi32>>>, llvm.data_layout = "e-m:e-p270:32:32-p271:32:32-p272:64:64-i64:64-f80:128-n8:16:32:64-S128", llvm.target_triple = "x86_64-unknown-linux-gnu"} {
  func @kernel_3mm(%arg0: memref<40x60xf32>, %arg1: memref<60x50xf32>, %arg2: memref<50x80xf32>, %arg3: memref<80x70xf32>, %arg4: memref<40x50xf32>, %arg5: memref<50x70xf32>, %arg6: memref<40x70xf32>) attributes {llvm.linkage = #llvm.linkage<external>} {
    %cst = arith.constant 0.000000e+00 : f32
    affine.for %arg7 = 0 to 40 {
      affine.for %arg8 = 0 to 50 {
        affine.store %cst, %arg4[%arg7, %arg8] : memref<40x50xf32>
        affine.for %arg9 = 0 to 60 {
          %0 = affine.load %arg0[%arg7, %arg9] : memref<40x60xf32>
          %1 = affine.load %arg1[%arg9, %arg8] : memref<60x50xf32>
          %2 = arith.mulf %0, %1 : f32
          %3 = affine.load %arg4[%arg7, %arg8] : memref<40x50xf32>
          %4 = arith.addf %3, %2 : f32
          affine.store %4, %arg4[%arg7, %arg8] : memref<40x50xf32>
        }
      }
    }
    affine.for %arg7 = 0 to 50 {
      affine.for %arg8 = 0 to 70 {
        affine.store %cst, %arg5[%arg7, %arg8] : memref<50x70xf32>
        affine.for %arg9 = 0 to 80 {
          %0 = affine.load %arg2[%arg7, %arg9] : memref<50x80xf32>
          %1 = affine.load %arg3[%arg9, %arg8] : memref<80x70xf32>
          %2 = arith.mulf %0, %1 : f32
          %3 = affine.load %arg5[%arg7, %arg8] : memref<50x70xf32>
          %4 = arith.addf %3, %2 : f32
          affine.store %4, %arg5[%arg7, %arg8] : memref<50x70xf32>
        }
      }
    }
    affine.for %arg7 = 0 to 40 {
      affine.for %arg8 = 0 to 70 {
        affine.store %cst, %arg6[%arg7, %arg8] : memref<40x70xf32>
        affine.for %arg9 = 0 to 50 {
          %0 = affine.load %arg4[%arg7, %arg9] : memref<40x50xf32>
          %1 = affine.load %arg5[%arg9, %arg8] : memref<50x70xf32>
          %2 = arith.mulf %0, %1 : f32
          %3 = affine.load %arg6[%arg7, %arg8] : memref<40x70xf32>
          %4 = arith.addf %3, %2 : f32
          affine.store %4, %arg6[%arg7, %arg8] : memref<40x70xf32>
        }
      }
    }
    return
  }
}
