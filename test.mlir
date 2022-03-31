  func @test(%arg0: memref<?xf64>, %arg1: memref<?xf64>, %arg2: memref<?xf64>, %arg3: memref<?xf64>) attributes {llvm.linkage = #llvm.linkage<external>} {
    %c64_i32 = arith.constant 64 : i32
    %cst = arith.constant 0.000000e+00 : f64
    affine.for %arg4 = 0 to 64 {
      affine.store %cst, %arg2[%arg4] : memref<?xf64>
      affine.for %arg5 = 0 to 13 {
        %0 = affine.load %arg1[%arg5 + %arg4 * 13] : memref<?xf64>
        %1 = affine.load %arg3[%arg5] : memref<?xf64>
        %2 = arith.mulf %0, %1 : f64
        %3 = affine.load %arg2[%arg4] : memref<?xf64>
        %4 = arith.addf %3, %2 : f64
        affine.store %4, %arg2[%arg4] : memref<?xf64>
      }
    }
    call @add_bias_to_activations(%arg0, %arg2, %c64_i32) : (memref<?xf64>, memref<?xf64>, i32) -> ()
    return
  }
  func private @add_bias_to_activations(memref<?xf64>, memref<?xf64>, i32) attributes {llvm.linkage = #llvm.linkage<external>}